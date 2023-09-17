import psycopg2
import socket
import threading
import json
from datetime import date
from psycopg2 import Error

host = '127.0.0.1'
port = 12345
players = []
lock = threading.Lock()

def send_message(message, player_socket):
    message = json.dumps(message)
    player_socket.send(message.encode('utf-8'))


def try_change_query(query, cursor, db_conn, player_socket):
    try:
        cursor.execute(query)
        db_conn.commit()
        message = {
            'status': True
        }
        send_message(message, player_socket)
    except (Exception, Error) as error:
        db_conn.rollback()
        message = {
            "status": False,
            "reason": str(error)
        }
        send_message(message, player_socket)


def handle_player(player_socket):
    global players
    player_id = None
    character_id = None
    try:
        db_conn = psycopg2.connect(user='postgres',
                                   host="localhost",
                                   password='2128506Vc',
                                   port="5432",
                                   dbname="allods")
        cursor = db_conn.cursor()
        while True:
            data = player_socket.recv(1024).decode('utf-8')
            if not data:
                break
            data = json.loads(data)
            print(f"Received from client: {data}")
            match data['type']:
                # Блок регистрации
                case 'reg':
                    login = data['login']
                    password = data['password']
                    e_mail = data['e_mail']
                    reg_date = date.today()
                    query = f"INSERT INTO players (login, password, registration_date, e_mail) VALUES " \
                            f"('{login}', '{password}', '{reg_date}', '{e_mail}')"
                    try_change_query(query, cursor, db_conn, player_socket)
                # Конец блока регистрации
                # Блок аутентификации
                case 'auth':
                    login = data['login']
                    password = data['password']
                    query = f"SELECT player_ID, password, registration_date FROM players " \
                            f"where login = '{login}' or e_mail = '{login}'"
                    cursor.execute(query)
                    selected = cursor.fetchall()
                    if len(selected) > 1:
                        print("Found more than one account")
                    else:
                        if len(selected) == 0:
                            message = {
                                "status": False,
                                "reason": "Login not found"
                            }
                            send_message(message, player_socket)
                        elif selected[0][1] != password:
                            message = {
                                "status": False,
                                "reason": "Wrong password"
                            }
                            send_message(message, player_socket)
                        elif selected[0][0] in players:
                            message = {
                                "status": False,
                                "reason": "player is already authorised"
                            }
                            send_message(message, player_socket)
                        else:
                            message = {
                                "status": True
                            }
                            send_message(message, player_socket)
                            player_id = selected[0][0]
                            with lock:
                                players.append(player_id)
                # Конец блока аутентификации
                # Блок создания персонажа
                case 'create_ch':
                    name = data['name']
                    query = f"INSERT INTO characters(character_name, fraction, race, gender, class, level, exp, " \
                            f"hp, mana, location, gold, x_pos, y_pos, z_pos, player_id) values " \
                            f"('{name}', {data['fraction']}, {data['race']}, {data['gender']}, {data['cl']}," \
                            f"1, 0, 150, 100, 0, 0, 0.0, 30.0, 5.0, {player_id})" \
                            f"RETURNING character_id"
                    try:
                        cursor.execute(query)
                        id = cursor.fetchone()[0]
                        query = f"INSERT INTO item_in_inventory(character_id, item_id, is_equipped, amount)" \
                                f"values ({id}, 1, null, 1)"
                        cursor.execute(query)
                        query = f"INSERT INTO quest_taken(character_id, quest_id, is_completed)" \
                                f"values ({id}, 1, 0)"
                        cursor.execute(query)
                        db_conn.commit()
                        message = {
                            'status': True
                        }
                        send_message(message, player_socket)
                    except (Exception, Error) as error:
                        db_conn.rollback()
                        message = {
                            "status": False,
                            "reason": str(error)
                        }
                        send_message(message, player_socket)
                # Конец блока создания персонажа
                # Блок запроса списка персонажей
                case 'ch_list':
                    query = f"SELECT character_name, fraction, race, class, level FROM characters WHERE player_id = {player_id}"
                    cursor.execute(query)
                    selected = cursor.fetchall()
                    message = {
                        'status': True,
                        'selected': selected
                    }
                    send_message(message, player_socket)
                # Конец блока запроса списка персонажей
                # Блок выбора персонажа
                case 'choose_ch':
                    name = data['name']
                    query = f"SELECT * FROM characters where character_name = '{name}'"
                    cursor.execute(query)
                    selected = cursor.fetchall()
                    character_id = selected[0][0]
                    cl = selected[0][5]
                    query_learned = f"select skills.skill_id, skill_name, description, cooldown, class, manacost, character_id, skill_level " \
                                    f"from skills left join skill_learned sl on skills.skill_id = sl.skill_id " \
                                    f"and sl.character_id = {character_id} where skills.class = {cl}"
                    cursor.execute(query_learned)
                    selected_learned = cursor.fetchall()
                    skills = []
                    for skill in selected_learned:
                         learned = skill[6] is not None
                         new_skill = {
                            'id': skill[0],
                            'name': skill[1],
                            'description': skill[2],
                            'cooldown': skill[3],
                            'class': skill[4],
                            'manacost': skill[5],
                            'learned': learned,
                            'level': skill[7]
                         }
                         skills.append(new_skill)
                    query_quests = f"SELECT quests.quest_id, is_completed, quest_name, level, is_storyline, gold_reward, exp_reward, description " \
                                   f"FROM quest_taken JOIN quests ON quest_taken.quest_id = quests.quest_id where quest_taken.character_id = {character_id}"
                    cursor.execute(query_quests)
                    selected_quests = cursor.fetchall()
                    quests = []
                    for quest in selected_quests:
                        new_quest = {
                            'id': quest[0],
                            'completed': quest[1],
                            'name': quest[2],
                            'level': quest[3],
                            'storyline': bool(quest[4]),
                            'gold_reward': quest[5],
                            'exp_reward': quest[6],
                            'description': quest[7]
                        }
                        quests.append(new_quest)

                    if selected[0][15] is None:
                        guild = None
                    else:
                        id = selected[0][15]
                        query = f"Select guild_name from guilds where guild_id = {id}"
                        cursor.execute(query)
                        name = cursor.fetchone()[0]
                        guild = {
                            'id': id,
                            'name': name
                        }

                    items = []
                    query_weapon = f"SELECT i.Item_ID, i.Item_name, i.Item_level, i.Rarity, i.Description, i.Item_type, " \
                                  f"w.Damage, w.Attack_speed, w.Attack_range, w.Weapon_type, iii.is_equipped, iii.amount " \
                                  f"FROM item_in_inventory iii " \
                                  f"JOIN items i ON iii.Item_ID = i.Item_ID " \
                                  f"JOIN weapon w ON i.Item_ID = w.Item_ID " \
                                  f"WHERE iii.Character_ID = {character_id}"
                    cursor.execute(query_weapon)
                    weapons_selected = cursor.fetchall()
                    for item in weapons_selected:
                        new = {
                            'id': item[0],
                            'name': item[1],
                            'level': item[2],
                            'rarity': item[3],
                            'description': item[4],
                            'type': item[5],
                            'damage': item[6],
                            'attack_s': item[7],
                            'attack_r': item[8],
                            'weapon_type': item[9],
                            'equipped': item[10],
                            'quest': None,
                            'amount': item[11]
                        }
                        items.append(new)
                    print('weather')
                    query_weather = f"SELECT i.Item_ID, i.Item_name, i.Item_level, i.Rarity, i.Description, i.Item_type, " \
                                       f"w.Weather_type, w.Armor, w.Attribute_bonus, iii.is_equipped, iii.amount " \
                                       f"FROM item_in_inventory iii " \
                                       f"JOIN items i ON iii.Item_ID = i.Item_ID " \
                                       f"JOIN weather w ON i.Item_ID = w.Item_ID " \
                                       f"WHERE iii.Character_ID = {character_id} "
                    cursor.execute(query_weather)
                    weather_selected = cursor.fetchall()
                    for item in weather_selected:
                        new = {
                                'id': item[0],
                                'name': item[1],
                                'level': item[2],
                                'rarity': item[3],
                                'description': item[4],
                                'type': item[5],
                                'weather_type': item[6],
                                'armor': item[7],
                                'bonus': item[8],
                                'equipped': item[9],
                                'quest': None,
                                'amount': item[10]
                        }
                        items.append(new)
                    query_other = f"SELECT i.Item_ID, i.Item_name, i.Item_level, i.Rarity, i.Description, i.Item_type, " \
                                            f"o.is_quest, iii.amount " \
                                            f"FROM item_in_inventory iii " \
                                            f"JOIN items i ON iii.Item_ID = i.Item_ID " \
                                            f"JOIN other_table o ON i.Item_ID = o.Item_ID " \
                                            f"WHERE iii.Character_ID = {character_id}"
                    cursor.execute(query_other)
                    selected_other = cursor.fetchall()
                    for item in selected_other:
                        new = {
                                    'id': item[0],
                                    'name': item[1],
                                    'level': item[2],
                                    'rarity': item[3],
                                    'description': item[4],
                                    'type': item[5],
                                    'equipped': None,
                                    'quest': item[6],
                                    'amount': item[7]
                        }
                        items.append(new)
                    message = {
                        'status': True,
                        'id': selected[0][0],
                        'name': selected[0][1],
                        'fraction': selected[0][2],
                        'race': selected[0][3],
                        'gender': selected[0][4],
                        'class': selected[0][5],
                        'level': selected[0][6],
                        'exp': selected[0][7],
                        'hp': selected[0][8],
                        'mana': selected[0][9],
                        'loc': selected[0][10],
                        'gold': selected[0][11],
                        'x_pos': selected[0][12],
                        'y_pos': selected[0][13],
                        'z_pos': selected[0][14],
                        'skills': skills,
                        'quests': quests,
                        'guild': guild,
                        'items': items
                    }
                    send_message(message, player_socket)
                # Конец блока выбора персонажа

                # Блок удаления аккаунта
                case 'delete_acc':
                    login = data['login']
                    password = data['password']
                    query = f"SELECT password FROM players " \
                            f"where login = '{login}' or e_mail = '{login}' limit 1"
                    cursor.execute(query)
                    selected = cursor.fetchall()
                    if len(selected) > 1:
                        print('Найдено больше одного аккаунта')
                    else:
                        if len(selected) == 0:
                            message = {
                                'status': False,
                                'reason': "Login not found"
                            }
                            send_message(message, player_socket)
                        elif selected[0][0] != password:
                            message = {
                                'status': False,
                                'reason': 'Wrong password'
                            }
                            send_message(message, player_socket)
                        else:
                            query = f"DELETE FROM players " \
                                    f"where login = '{login}' or e_mail = '{login}'"
                            try_change_query(query, cursor, db_conn, player_socket)

                # Конец блока удаления аккаунта
                # Блок удаления персонажа
                case 'delete_ch':
                    name = data['name']
                    query = f"DELETE FROM characters where character_name = '{name}'"
                    try_change_query(query, cursor, db_conn, player_socket)
                # Конец блока удаления персонажа
                # Блок смены локации
                case 'change_loc':
                    loc = data['loc']
                    query = f"UPDATE characters SET location = {loc} where character_id = {character_id}"
                    try_change_query(query, cursor, db_conn, player_socket)
                # Конец блока смены локации
                # Блоки со способностями
                case 'learn_skill':
                    id = data['id']
                    query = f"INSERT INTO skill_learned(skill_id, character_id, skill_level) " \
                            f"values ({id}, {character_id}, 1)"
                    try_change_query(query, cursor, db_conn, player_socket)
                case 'increase_skill_level':
                    id = data['id']
                    level = data['level']
                    query = f"UPDATE skill_learned SET skill_level = {level + 1} where skill_id = {id} and character_id = {character_id}"
                    try_change_query(query, cursor, db_conn, player_socket)
                # Конец блоков со способностями
                # Блоки с квестами
                case 'complete_quest':
                    id = data['id']
                    reward = data['gold']
                    query = f"UPDATE quest_taken SET is_completed = 1 where character_id = {character_id} and quest_id = {id}"
                    try:
                        cursor.execute(query)
                        query = f"SELECT item_id FROM item_reward where quest_id = {id}"
                        cursor.execute(query)
                        selected = cursor.fetchall()
                        idx = [i[0] for i in selected]
                        query = "INSERT INTO item_in_inventory(character_id, item_id, is_equipped, amount) values "
                        for i, item_id in enumerate(idx):
                            if item_id == 9:
                                amount = 3
                            else:
                                amount = 1
                            query += f"({character_id}, {item_id}, 0, {amount})"
                            if i != (len(idx) - 1):
                                query += ", "
                        cursor.execute(query)
                        query = f"UPDATE characters SET level = level + 1, gold = gold + {reward} where character_id = {character_id}"
                        cursor.execute(query)
                        db_conn.commit()
                        items = []
                        query_weapon = f"SELECT i.Item_ID, i.Item_name, i.Item_level, i.Rarity, i.Description, i.Item_type, " \
                                       f"w.Damage, w.Attack_speed, w.Attack_range, w.Weapon_type, iii.is_equipped, iii.amount " \
                                       f"FROM item_in_inventory iii " \
                                       f"JOIN items i ON iii.Item_ID = i.Item_ID " \
                                       f"JOIN weapon w ON i.Item_ID = w.Item_ID " \
                                       f"WHERE iii.Character_ID = {character_id}"
                        cursor.execute(query_weapon)
                        weapons_selected = cursor.fetchall()
                        for item in weapons_selected:
                            new = {
                                'id': item[0],
                                'name': item[1],
                                'level': item[2],
                                'rarity': item[3],
                                'description': item[4],
                                'type': item[5],
                                'damage': item[6],
                                'attack_s': item[7],
                                'attack_r': item[8],
                                'weapon_type': item[9],
                                'equipped': item[10],
                                'quest': None,
                                'amount': item[11]
                            }
                            items.append(new)
                        print('weather')
                        query_weather = f"SELECT i.Item_ID, i.Item_name, i.Item_level, i.Rarity, i.Description, i.Item_type, " \
                                        f"w.Weather_type, w.Armor, w.Attribute_bonus, iii.is_equipped, iii.amount " \
                                        f"FROM item_in_inventory iii " \
                                        f"JOIN items i ON iii.Item_ID = i.Item_ID " \
                                        f"JOIN weather w ON i.Item_ID = w.Item_ID " \
                                        f"WHERE iii.Character_ID = {character_id} "
                        cursor.execute(query_weather)
                        weather_selected = cursor.fetchall()
                        for item in weather_selected:
                            new = {
                                'id': item[0],
                                'name': item[1],
                                'level': item[2],
                                'rarity': item[3],
                                'description': item[4],
                                'type': item[5],
                                'weather_type': item[6],
                                'armor': item[7],
                                'bonus': item[8],
                                'equipped': item[9],
                                'quest': None,
                                'amount': item[10]
                            }
                            items.append(new)
                        query_other = f"SELECT i.Item_ID, i.Item_name, i.Item_level, i.Rarity, i.Description, i.Item_type, " \
                                      f"o.is_quest, iii.amount " \
                                      f"FROM item_in_inventory iii " \
                                      f"JOIN items i ON iii.Item_ID = i.Item_ID " \
                                      f"JOIN other_table o ON i.Item_ID = o.Item_ID " \
                                      f"WHERE iii.Character_ID = {character_id}"
                        cursor.execute(query_other)
                        selected_other = cursor.fetchall()
                        for item in selected_other:
                            new = {
                                'id': item[0],
                                'name': item[1],
                                'level': item[2],
                                'rarity': item[3],
                                'description': item[4],
                                'type': item[5],
                                'equipped': None,
                                'quest': item[6],
                                'amount': item[7]
                            }
                            items.append(new)
                        message = {
                            'status': True,
                            'items': items
                        }
                        send_message(message, player_socket)
                    except (Exception, Error) as error:
                        db_conn.rollback()
                        message = {
                            "status": False,
                            "reason": str(error)
                        }
                        send_message(message, player_socket)
                case 'take_quest':
                    id = data['id']
                    query = f"INSERT INTO quest_taken(character_id, quest_id, is_completed) VALUES " \
                            f"({character_id}, {id}, 0)"
                    try_change_query(query, cursor, db_conn, player_socket)
                case 'quest_list':
                    query = "SELECT * FROM quests"
                    cursor.execute(query)
                    selected = cursor.fetchall()
                    quests = []
                    for quest in selected:
                        new_quest = {
                            'id': quest[0],
                            'completed': 0,
                            'name': quest[1],
                            'level': quest[2],
                            'storyline': bool(quest[3]),
                            'gold_reward': quest[4],
                            'exp_reward': quest[5],
                            'description': quest[6]
                        }
                        quests.append(new_quest)
                    message = {
                        'status': True,
                        'quests': quests
                    }
                    send_message(message, player_socket)
                # Конец блоков с квестами
                # Блоки с друзьями
                case 'friend_list':
                    query = f"SELECT CASE WHEN Character_ID = {character_id} THEN Friend_ID ELSE Character_ID END " \
                            f"FROM characters_friends WHERE Character_ID = {character_id} OR Friend_ID = {character_id}"
                    cursor.execute(query)
                    friend_idx = cursor.fetchall()
                    friends = []
                    for friend_id in friend_idx:
                        query = f"Select character_id, character_name, fraction, race, level FROM characters " \
                                f"where character_id = {friend_id[0]}"
                        cursor.execute(query)
                        friend = cursor.fetchone()
                        new_friend = {
                            'id': friend[0],
                            'name': friend[1],
                            'fraction': friend[2],
                            'race': friend[3],
                            'level': friend[4]
                        }
                        friends.append(new_friend)
                    message = {
                        'status': True,
                        'friends': friends
                    }
                    send_message(message, player_socket)
                case 'add_friend':
                    name = data['name']
                    id_query = f"SELECT character_ID from characters where character_name = '{name}' limit 1"
                    cursor.execute(id_query)
                    selected = cursor.fetchall()
                    if len(selected) == 0:
                        message = {
                            'status': False,
                            'reason': 'character not exists'
                        }
                        send_message(message, player_socket)
                    else:
                        query = f"INSERT INTO characters_friends(Character_ID, Friend_ID) " \
                            f"VALUES ({character_id}, {selected[0][0]})"
                        try_change_query(query, cursor, db_conn, player_socket)
                case 'delete_friend':
                    id = data['id']
                    query = f"DELETE FROM characters_friends " \
                            f"WHERE (Character_ID = {character_id} AND Friend_ID = {id}) OR (Character_ID = {id} AND Friend_ID = {character_id})"
                    try_change_query(query, cursor, db_conn, player_socket)
                # Конец блоков с друзьями
                # Блоки с гильдией
                case "quit_guild":
                    query = f"UPDATE characters SET guild_id = null where character_id = {character_id}"
                    try_change_query(query, cursor, db_conn, player_socket)
                case 'create_guild':
                    query = f"INSERT INTO guilds(guild_name, number_of_members, description, minimal_level, leader_id)" \
                            f"values ('{data['name']}', 1, '{data['desc']}', {data['level']}, {character_id})" \
                            f"returning guild_id"
                    try:
                        cursor.execute(query)
                        guild_id = cursor.fetchone()[0]
                        query = f"UPDATE characters SET guild_id = {guild_id} where character_id = {character_id}"
                        cursor.execute(query)
                        db_conn.commit()
                        message = {
                            'status': True,
                            "id": guild_id
                        }
                        send_message(message, player_socket)
                    except (Exception, Error) as error:
                        db_conn.rollback()
                        message = {
                            "status": False,
                            "reason": str(error)
                        }
                        send_message(message, player_socket)
                case 'drop_player':
                    id = data['id']
                    query = f"UPDATE characters SET guild_id = null where character_id = {id}"
                    try_change_query(query, cursor, db_conn, player_socket)
                case 'make_leader':
                    id = data['id']
                    guild_id = data['guild_id']
                    query = f"UPDATE guilds SET leader_id= {id} where guild_id = {guild_id}"
                    try_change_query(query, cursor, db_conn, player_socket)
                case 'join_guild':
                    guild_name = data['name']
                    id_query = f"SELECT guild_id FROM guilds where guild_name = '{guild_name}' limit 1"
                    cursor.execute(id_query)
                    selected = cursor.fetchall()
                    if len(selected) == 0:
                        message = {
                            'status': False,
                            'reason': 'guild not exists'
                        }
                        send_message(message, player_socket)
                    else:
                        guild_id = selected[0][0]
                        query = f"UPDATE characters SET guild_id = {guild_id} where character_id = {character_id}"
                        try:
                            cursor.execute(query)
                            db_conn.commit()
                            message = {
                                'status': True,
                                'id': guild_id
                            }
                            send_message(message, player_socket)
                        except (Exception, Error) as error:
                            db_conn.rollback()
                            message = {
                                "status": False,
                                "reason": str(error)
                            }
                            send_message(message, player_socket)
                case "get_guild_info":
                    id = data['id']
                    query = f"SELECT guild_name, number_of_members, description, minimal_level, leader_id, character_name " \
                            f"FROM guilds JOIN characters ON leader_id = character_id WHERE guilds.guild_id = {id}"
                    cursor.execute(query)
                    guild = cursor.fetchall()[0]
                    players_query = f"SELECT character_id, character_name from characters where guild_id = {id}"
                    cursor.execute(players_query)
                    pl = cursor.fetchall()
                    players = []
                    for p in pl:
                        new_p = {
                            'id': p[0],
                            'name': p[1]
                        }
                        players.append(new_p)
                    message = {
                        'status': True,
                        'name': guild[0],
                        'number': guild[1],
                        'desc': guild[2],
                        'min_level': guild[3],
                        'leader': {
                            'id': guild[4],
                            'name': guild[5]
                        },
                        'players': players
                    }
                    send_message(message, player_socket)
                # Конец блоков с гильдией
                # Блоки с чатом
                case 'get_messages':
                    id = data['id']
                    k = data['k']
                    if data['receiver'] == 0:
                        query = f"SELECT m.Sending_time, sender.Character_Name AS Sender_Name, m.Text, receiver.Character_Name AS Receiver_Name " \
                                f"FROM messages m " \
                                f"JOIN characters AS sender ON m.Sender_ID = sender.Character_ID " \
                                f"JOIN to_other AS t1 ON m.Message_ID = t1.Message_ID " \
                                f"JOIN characters AS receiver ON t1.Receiver_ID = receiver.Character_ID " \
                                f"WHERE (" \
                                f"(m.Sender_ID = {id} AND t1.Receiver_ID = {character_id}) " \
                                f"OR" \
                                f"(m.Sender_ID = {character_id} AND t1.Receiver_ID = {id})) " \
                                f"ORDER BY m.Sending_time DESC " \
                                f"LIMIT {k}"
                    elif data['receiver'] == 1:
                        query = f"SELECT m.Sending_time, c.Character_Name, m.Text " \
                                f"FROM messages m " \
                                f"JOIN to_loc tl ON m.Message_ID = tl.Message_ID " \
                                f"JOIN characters c ON m.Sender_ID = c.Character_ID " \
                                f"WHERE tl.loc = {id} " \
                                f"ORDER BY m.Sending_time DESC " \
                                f"LIMIT {k}"
                    else:
                        query = f"SELECT m.Sending_time, c.Character_Name, m.Text " \
                                f"FROM messages m " \
                                f"JOIN to_guild tg ON m.Message_ID = tg.Message_ID " \
                                f"JOIN characters c ON m.Sender_ID = c.Character_ID " \
                                f"WHERE tg.Guild_ID = {id} " \
                                f"ORDER BY m.Sending_time DESC " \
                                f"LIMIT {k}"
                    cursor.execute(query)
                    selected_messages = cursor.fetchall()
                    messages = []
                    for m in selected_messages:
                        message = {
                            'name': m[1],
                            'text': m[2]
                        }
                        messages.append(message)
                    message = {
                        'status': True,
                        'messages': messages
                    }
                    send_message(message, player_socket)
                case 'send_message':
                    id = data['id']
                    text = data['text']
                    try:
                        id = data['id']
                        text = data['text']
                        query = f"INSERT INTO messages(sending_time, receiver_type, text, sender_id) " \
                                f"values (CURRENT_TIMESTAMP, {data['receiver']}, '{text}', {character_id}) " \
                                f"RETURNING message_id"
                        cursor.execute(query)
                        message_id = cursor.fetchone()[0]
                        if data['receiver'] == 0:
                            query = f"INSERT INTO to_other (message_id, receiver_id) " \
                                    f"values ({message_id}, {id})"
                        elif data['receiver'] == 1:
                            query = f"INSERT INTO to_loc (message_id, loc) " \
                                    f"values ({message_id}, {id})"
                        else:
                            query = f"INSERT INTO to_guild (message_id, guild_id) " \
                                    f"values ({message_id}, {id})"
                        cursor.execute(query)
                        db_conn.commit()
                        message = {
                            'status': True
                        }
                        send_message(message, player_socket)
                    except (Exception, Error) as error:
                        db_conn.rollback()
                        message = {
                            "status": False,
                            "reason": str(error)
                        }
                        send_message(message, player_socket)
                # Блоки с предметами
                case "equip_item":
                    id = data['id']
                    query = f"UPDATE item_in_inventory SET is_equipped = 1 where item_id = {id} and character_id = {character_id}"
                    try_change_query(query, cursor, db_conn, player_socket)
                case "drop_item":
                    id = data['id']
                    amount = data['amount']
                    if amount > 1:
                        query = f"UPDATE item_in_inventory SET amount = amount - 1 WHERE item_id = {id} and character_id = {character_id}"
                    else:
                        query = f"DELETE FROM item_in_inventory WHERE item_id = {id} and character_id = {character_id}"
                    try_change_query(query, cursor, db_conn, player_socket)
                # Конец блоков с предметами
                # Конец блоков с чатом
                case _:
                    print('Do not understand this message')

        cursor.close()
        db_conn.close()
    except (Exception, Error) as error:
        print(f'Found error: {error}')
    finally:
        if player_id is not None:
            with lock:
                players.remove(player_id)
        player_socket.close()


if __name__ == "__main__":
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((host, port))
    server.listen()

    print(f"Server listening on {host}:{port}")

    while True:
        client_socket, client_address = server.accept()
        print(f"Accepted connection from {client_address[0]}:{client_address[1]}")
        client_handler = threading.Thread(target=handle_player, args=(client_socket,))
        client_handler.start()
