import json
import socket
import tkinter as tk
import dicts
from tkinter import messagebox
from character import Character

host = '127.0.0.1'
port = 12345
client = None
max_level = 5


def show_message(text):
    if text.find("CONTEXT") != -1:
        text = text[:text.find("CONTEXT")]
    messagebox.showinfo("Message", text)


def send_message(message):
    message = json.dumps(message)
    client.send(message.encode('utf-8'))


def get_message():
    response = client.recv(32768).decode('utf-8')
    return json.loads(response)


class GuildJoinApp:
    def __init__(self, root, character):
        self.root = root
        self.character = character
        self.root.title('Join guild')
        self.name_label = tk.Label(root, text='Enter name of guild')
        self.name_label.pack()
        self.name_entry = tk.Entry(root)
        self.name_entry.pack()
        self.join_button = tk.Button(root, text='Join guild', command=self.join)
        self.join_button.pack()

    def join(self):
        name = self.name_entry.get()
        if len(name) == 0:
            pass
        else:
            message = {
                'type': 'join_guild',
                'name': name
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                self.character.guild = {
                    'id': answer['id'],
                    'name': name
                }
                self.root.destroy()
                guild_window = tk.Tk()
                guild_app = GuildApp(guild_window, self.character)
            else:
                show_message(answer['reason'])


class GuildInfoApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title("Guild info")
        self.character = character
        self.guild = self.character.guild
        message = {
            'type': 'get_guild_info',
            'id': self.guild['id']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            name_label = tk.Label(root, text=f"Guild name: {answer['name']}")
            name_label.pack()
            level_label = tk.Label(root, text=f"Minimal level: {answer['min_level']}")
            level_label.pack()
            number_label = tk.Label(root, text=f"Number of members: {answer['number']}")
            number_label.pack()
            desc_label = tk.Label(root, text=f"Description: {answer['desc']}")
            desc_label.pack()
            leader_label = tk.Label(root, text=f"Leader: {answer['leader']['name']}")
            leader_label.pack()
            for player in answer['players']:
                if player['id'] != answer['leader']['id']:
                    player_label = tk.Label(root, text=f"{player['name']}")
                    player_label.pack()
                    if answer['leader']['id'] == self.character.id:
                        make_button = tk.Button(root, text="Make leader",
                                                command=lambda player=player: self.make_leader(player))
                        make_button.pack()
                        drop_button = tk.Button(root, text="Drop",
                                                command=lambda player=player: self.drop_player(player))
                        drop_button.pack()
        else:
            show_message(answer['reason'])

    def make_leader(self, player):
        message = {
            "type": "make_leader",
            "id": player['id'],
            "guild_id": self.guild['id']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            self.root.destroy()
            window = tk.Tk()
            guild_info_app = GuildInfoApp(window, self.character)
        else:
            show_message(answer)

    def drop_player(self, player):
        message = {
            "type": "drop_player",
            "id": player['id']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            self.root.destroy()
            window = tk.Tk()
            guild_info_app = GuildInfoApp(window, self.character)
        else:
            show_message(answer)


class GuildCreateApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title('Guild creation')
        self.character = character
        self.name_label = tk.Label(root, text='Enter name of your guild')
        self.name_label.pack()
        self.name_entry = tk.Entry(root)
        self.name_entry.pack()
        self.desc_label = tk.Label(root, text="Enter description")
        self.desc_label.pack()
        self.desc_entry = tk.Text(root, wrap=tk.WORD, width=40, height=10)
        self.desc_entry.pack()
        self.level_scale = tk.Scale(root, from_=1, to=max_level)
        self.level_scale.pack()
        self.create_button = tk.Button(root, text='Create guild', command=self.create_guild)
        self.create_button.pack()

    def create_guild(self):
        name = self.name_entry.get()
        desc = self.desc_entry.get('1.0', tk.END)
        level = self.level_scale.get()
        if len(name) == 0:
            pass
        else:
            desc = desc if len(desc) > 0 else None
            message = {
                'type': 'create_guild',
                'name': name,
                'desc': desc,
                'level': level
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                self.root.destroy()
                self.character.guild = {
                    'id': answer['id'],
                    'name': name
                }
                guild_window = tk.Tk()
                guild_app = GuildApp(guild_window, self.character)
            else:
                show_message(answer['reason'])


class GuildApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title("Guilds")
        self.character = character
        guild_name = 'No guild' if self.character.guild is None else self.character.guild['name']
        self.guild_label = tk.Label(root, text=f"Your guild: {guild_name}")
        self.guild_label.pack()
        if self.character.guild is None:
            create_button = tk.Button(root, text='Create guild', command=self.create_guild)
            create_button.pack()
            join_button = tk.Button(root, text='Join guild', command=self.join_guild)
            join_button.pack()
        else:
            info_button = tk.Button(root, text='Guild info', command=self.open_info)
            info_button.pack()
            quit_button = tk.Button(root, text='Quit guild', command=self.quit_guild)
            quit_button.pack()

    def create_guild(self):
        self.root.destroy()
        window = tk.Tk()
        app = GuildCreateApp(window, self.character)

    def join_guild(self):
        self.root.destroy()
        window = tk.Tk()
        app = GuildJoinApp(window, self.character)

    def quit_guild(self):
        message = {
            'type': "quit_guild"
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            self.character.guild = None
            self.root.destroy()
            window = tk.Tk()
            app = GuildApp(window, self.character)
        else:
            show_message(answer['reason'])

    def open_info(self):
        window = tk.Tk()
        app = GuildInfoApp(window, self.character)


class ChatApp:
    def __init__(self, root, title, info):
        self.root = root
        self.title = title
        self.root.title(title)
        self.info = info
        message = {
            'type': 'get_messages',
            'receiver': info['receiver'],
            'id': info['id'],
            'k': 20
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            messages = answer['messages']
            for message in messages:
                message_label = tk.Label(root, text=f"{message['name']}: {message['text']}")
                message_label.pack()
        else:
            show_message(answer['reason'])
        self.send_label = tk.Label(root, text='Enter your message')
        self.send_label.pack()
        self.entry_message = tk.Text(root, wrap=tk.WORD, width=40, height=10)
        self.entry_message.pack()
        self.entry_button = tk.Button(root, text="Send message", command=self.send_message)
        self.entry_button.pack()

    def send_message(self):
        text = self.entry_message.get('1.0', tk.END)
        if len(text) == 0:
            pass
        else:
            message = {
                'type': 'send_message',
                'receiver': self.info['receiver'],
                'id': self.info['id'],
                'text': text
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                self.root.destroy()
                chat_window = tk.Tk()
                chat_app = ChatApp(chat_window, self.title, self.info)
            else:
                show_message(answer['reason'])


class MessageApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title("Messages")
        self.character = character
        self.loc_button = tk.Button(root, text="Open location chat", command=self.open_loc_chat)
        self.loc_button.pack()
        self.guild_button = tk.Button(root, text="Open guild chat", command=self.open_guild_chat)
        self.guild_button.pack()

    def open_loc_chat(self):
        info = {
            'receiver': 1,
            'id': self.character.loc
        }
        self.root.destroy()
        chat_window = tk.Tk()
        chat_app = ChatApp(chat_window, f'Chat on location: {dicts.idx2loc[self.character.loc]}', info)

    def open_guild_chat(self):
        if self.character.guild is None:
            show_message('You are not member of guild')
        else:
            info = {
                'receiver': 2,
                'id': self.character.guild['id']
            }
            self.root.destroy()
            chat_window = tk.Tk()
            chat_app = ChatApp(chat_window, f"Chat on guild: {self.character.guild['name']}", info)


class AddFriendApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Add friend")
        self.label = tk.Label(root, text='Entry name of your future friend')
        self.label.pack()
        self.entry = tk.Entry(root)
        self.entry.pack()
        self.button = tk.Button(root, text="Add friend", command=self.add_friend)
        self.button.pack()

    def add_friend(self):
        name = self.entry.get()
        if len(name) == 0:
            pass
        else:
            message = {
                'type': 'add_friend',
                'name': name
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                self.root.destroy()
                friends_window = tk.Tk()
                friends_app = FriendsApp(friends_window)
            else:
                show_message(answer['reason'])


class FriendsApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Friends")
        message = {
            'type': 'friend_list'
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            for friend in answer['friends']:
                label = tk.Label(root, text=f"{friend['name']}, {friend['level']} level, {dicts.idx2fraction[friend['fraction']]}, "
                                            f"{dicts.idx2race[friend['race']]}")
                label.pack()
                message_button = tk.Button(root, text="Open chat", command=lambda friend=friend: self.open_chat(friend))
                message_button.pack()
                delete_button = tk.Button(root, text="Delete friend",
                                          command=lambda friend=friend: self.delete_friend(friend))
                delete_button.pack()
            add_button = tk.Button(root, text="Add friend", command=self.add_friend)
            add_button.pack()
        else:
            show_message(answer['reason'])

    def open_chat(self, friend):
        info = {
            'receiver': 0,
            'id': friend['id']
        }
        self.root.destroy()
        chat_window = tk.Tk()
        chat_app = ChatApp(chat_window, f"Chat with character: {friend['name']}", info)

    def delete_friend(self, friend):
        message = {
            'type': 'delete_friend',
            'id': friend['id']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            self.root.destroy()
            friends_window = tk.Tk()
            friends_app = FriendsApp(friends_window)
        else:
            show_message(answer['reason'])

    def add_friend(self):
        self.root.destroy()
        add_window = tk.Tk()
        add_app = AddFriendApp(add_window)


class QuestTakeApp:
    def __init__(self, root, quests, character):
        self.root = root
        self.root.title("Take quest")
        self.character = character
        for quest in quests:
            storyline = 'storyline' if quest['storyline'] else 'not storyline'
            label = tk.Label(root, text=f"{quest['name']}, {quest['level']} level, {storyline}")
            label.pack()
            info_button = tk.Button(root, text="Info", command=lambda quest=quest: self.info(quest))
            info_button.pack()
            button = tk.Button(root, text=f"Take", command=lambda quest=quest: self.take(quest))
            button.pack()

    def info(self, quest):
        desc = "" if quest['description'] is None else quest['description']
        message_text = f"Description: {desc}\nGold_reward: {quest['gold_reward']}\nExp_reward: {quest['exp_reward']}"
        show_message(message_text)

    def take(self, quest):
        message = {
            'type': 'take_quest',
            'id': quest['id']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            self.character.quests.append(quest)
            self.root.destroy()
            quests_window = tk.Tk()
            quests_app = QuestApp(quests_window, self.character)
        else:
            show_message(answer['reason'])


class QuestApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title('Quests')
        self.character = character
        sorted(self.character.quests, key=lambda x: x['completed'])
        for quest in character.quests:
            completed = 'completed' if quest['completed'] else 'not completed'
            storyline = 'storyline' if quest['storyline'] else 'not storyline'
            quest_label = tk.Label(root, text=f"{quest['name']}, {quest['level']} level, {storyline}, {completed}")
            quest_label.pack()
            info_button = tk.Button(root, text='Info', command=lambda quest=quest: self.info(quest))
            info_button.pack()
            if not quest['completed']:
                complete_button = tk.Button(root, text='Complete', command=lambda quest=quest: self.complete(quest))
                complete_button.pack()

        self.take_button = tk.Button(root, text="New quest", command=self.take_quest)
        self.take_button.pack()

    def info(self, quest):
        message_text = f"Description: {quest['description']}\nGold_reward: {quest['gold_reward']}\nExp_reward: {quest['exp_reward']}"
        show_message(message_text)

    def complete(self, quest):
        message = {
            'type': 'complete_quest',
            'id': quest['id'],
            'gold': quest['gold_reward']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            for i in range(len(self.character.quests)):
                if self.character.quests[i]['id'] == quest['id']:
                    self.character.quests[i]['completed'] = 1
            self.character.level += 1
            self.character.gold += quest['gold_reward']
            self.character.items = answer['items']
            self.root.destroy()
            quests_window = tk.Tk()
            quests_app = QuestApp(quests_window, self.character)
        else:
            show_message(answer['reason'])

    def take_quest(self):
        idxs = []
        for quest in self.character.quests:
            idxs.append(quest['id'])
        message = {
            'type': 'quest_list'
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            quests = []
            for quest in answer['quests']:
                if quest['id'] not in idxs:
                    quests.append(quest)
            self.root.destroy()
            quests_window = tk.Tk()
            quests_app = QuestTakeApp(quests_window, quests, self.character)
        else:
            print(answer['reason'])


class InventoryApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title('Inventory')
        self.character = character
        for item in self.character.items:
            item_type = dicts.idx2item_type[item['type']] if item['type'] != 1 else dicts.idx2weather[item["weather_type"]]
            quest = "" if item['quest'] is None or not item['quest'] else ", quest"
            equiped = "" if item['equipped'] is None or not item['equipped'] else ", equipped"
            item_label = tk.Label(root, text=f"{item['name']}, {item_type}, {dicts.idx2rarity[item['rarity']]}, "
                                             f"{item['level']} level, amount: {item['amount']}" + quest + equiped)
            item_label.pack()
            info_button = tk.Button(root, text="Info", command=lambda item=item: self.info(item))
            info_button.pack()
            if item['equipped'] is not None and item['equipped'] == 0:
                equip_button = tk.Button(root, text="Equip", command=lambda item=item: self.equip(item))
                equip_button.pack()
            drop_button = tk.Button(root, text="Drop", command=lambda item=item: self.drop(item))
            drop_button.pack()

    def info(self, item):
        item_type = dicts.idx2item_type[item['type']] if item['type'] != 1 else item["weather_type"]
        quest = "no" if item['quest'] is None or not item['quest'] else "yes"
        equiped = "no" if item['equipped'] is None or not item['equipped'] else "yes"
        info_message = f"{item['name']}\nType: {item_type}\nLevel: {item['level']}\nRarity: {dicts.idx2rarity[item['rarity']]}\nAmount: {item['amount']}\n"
        if item['type'] == 2:
            info_message += f"Quest: {quest}\n"
        else:
            info_message += f"Equipped: {equiped}\n"
            if item['type'] == 0:
                info_message += f"Damage: {item['damage']}\nAttack_speed: {item['attack_s']}\nAttack_range: {item['attack_r']}\n" \
                                f"Weapon type: {dicts.idx2weapon[item['weapon_type']]}\n"
            else:
                info_message += f"Armor: {item['armor']}\nAttribute bonus: {item['bonus']}\n"
        description = "" if item['description'] is None else item['description']
        info_message += f"Description: {description}"
        show_message(info_message)

    def equip(self, item):
        message = {
            'type': 'equip_item',
            'id': item['id']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            item['equipped'] = 1
            for item_i in self.character.items:
                if item_i['type'] == item['type'] and item['id'] != item_i['id'] and item['type'] == 0:
                    if item_i['equipped']:
                        item_i['equipped'] = 0
                elif item_i['type'] == item['type'] and item['id'] != item_i['id'] and item['weather_type'] == item_i['weather_type']:
                    if item_i['equipped']:
                        item_i['equipped'] = 0
            self.root.destroy()
            window = tk.Tk()
            app = InventoryApp(window, self.character)
        else:
            show_message(answer['reason'])

    def drop(self, item):
        if item['quest'] is not None and item['quest']:
            show_message('You can not drop quest item')
        else:
            message = {
                'type': 'drop_item',
                'id': item['id'],
                'amount': item['amount']
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                for i in range(len(self.character.items)):
                    if item['id'] == self.character.items[i]['id']:
                        if self.character.items[i]['amount'] > 1:
                            self.character.items[i]['amount'] -= 1
                        else:
                            self.character.items.pop(i)
                        break
                self.root.destroy()
                window = tk.Tk()
                app = InventoryApp(window, self.character)
            else:
                show_message(answer['reason'])


class SKillApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title('Skills')
        self.character = character
        for skill in character.skills:
            if skill['learned']:
                skill_label = tk.Label(root, text=f"{skill['name']}, learned {skill['level']} level")
                skill_label.pack()
                skill_info = tk.Button(root, text='Info', command=lambda skill=skill: self.info(skill))
                skill_info.pack()
                if skill['level'] < 3:
                    increase_button = tk.Button(root, text='Increase level',
                                                command=lambda skill=skill: self.increase_level(skill))
                    increase_button.pack()
            else:
                skill_label = tk.Label(root, text=f"{skill['name']}")
                skill_label.pack()
                skill_info = tk.Button(root, text='Info', command=lambda skill=skill: self.info(skill))
                skill_info.pack()
                skill_learn = tk.Button(root, text='Learn', command=lambda skill=skill: self.learn(skill))
                skill_learn.pack()

    def info(self, skill):
        learned_label = 'Yes' if skill['learned'] else 'No'
        desc = "" if skill['description'] is None else skill['description']
        info_message = f"Skill name: {skill['name']}\nDescription: {desc}\n" \
                       f"Cooldown: {skill['cooldown']}\nManacost: {skill['manacost']}\nLearned: {learned_label}"
        show_message(info_message)

    def learn(self, skill):
        message = {
            'type': 'learn_skill',
            'id': skill['id']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            for i in range(len(self.character.skills)):
                if self.character.skills[i]['id'] == skill['id']:
                    self.character.skills[i]['learned'] = True
                    self.character.skills[i]['level'] = 1
            self.root.destroy()
            skill_window = tk.Tk()
            skill_app = SKillApp(skill_window, self.character)
        else:
            show_message(answer['reason'])

    def increase_level(self, skill):
        message = {
            'type': 'increase_skill_level',
            'id': skill['id'],
            'level': skill['level']
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            for i in range(len(self.character.skills)):
                if self.character.skills[i]['id'] == skill['id']:
                    self.character.skills[i]['level'] += 1
            self.root.destroy()
            skill_window = tk.Tk()
            skill_app = SKillApp(skill_window, self.character)
        else:
            show_message(answer['reason'])


class LocChooseApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title("Change location")
        self.character = character
        for location, idx in dicts.loc2idx.items():
            if idx != character.loc:
                loc_button = tk.Button(root, text=f"{location}", command=lambda idx=idx: self.choose(idx))
                loc_button.pack()

    def choose(self, loc):
        message = {
            "type": "change_loc",
            "loc": loc
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            self.character.loc = loc
            self.root.destroy()
            loc_window = tk.Tk()
            loc_app = LocApp(loc_window, self.character)
        else:
            show_message(answer['reason'])


class LocApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title("Location info")
        self.character = character
        self.current_label = tk.Label(root, text=f"Current location: {dicts.idx2loc[self.character.loc]}")
        self.current_label.pack()
        self.change_button = tk.Button(root, text="Change location", command=self.change_loc)
        self.change_button.pack()

    def change_loc(self):
        self.root.destroy()
        choose_window = tk.Tk()
        loc_choose_app = LocChooseApp(choose_window, self.character)


class InfoApp:
    def __init__(self, root, character):
        self.root = root
        self.root.title("Info")
        self.name_label = tk.Label(root, text=f"Name: {character.name}")
        self.name_label.pack()
        self.fraction_label = tk.Label(root, text=f"Fraction: {dicts.idx2fraction[character.fraction]}")
        self.fraction_label.pack()
        self.race_label = tk.Label(root, text=f"Race: {dicts.idx2race[character.race]}")
        self.race_label.pack()
        self.class_label = tk.Label(root, text=f"Class: {dicts.idx2class[character.cl]}")
        self.class_label.pack()
        self.gender_label = tk.Label(root, text=f"Gender: {dicts.idx2gender[character.gender]}")
        self.gender_label.pack()
        self.level_label = tk.Label(root, text=f"Level: {character.level}/50")
        self.level_label.pack()
        self.exp_label = tk.Label(root, text=f"Exp: {character.exp}/80")
        self.exp_label.pack()
        self.hp_label = tk.Label(root, text=f"HP: {character.hp}/150")
        self.hp_label.pack()
        self.mana_label = tk.Label(root, text=f"Mana: {character.mana}/100")
        self.mana_label.pack()
        self.loc_label = tk.Label(root, text=f"Location: {dicts.idx2loc[character.loc]}")
        self.loc_label.pack()
        self.gold_label = tk.Label(root, text=f"Gold: {character.gold}")
        self.gold_label.pack()
        self.x_label = tk.Label(root, text=f"X: {character.x_pos}")
        self.x_label.pack()
        self.y_label = tk.Label(root, text=f"Y: {character.y_pos}")
        self.y_label.pack()
        self.z_label = tk.Label(root, text=f"Z: {character.z_pos}")
        self.z_label.pack()


class GameApp:
    def __init__(self, root, character):
        self.root = root
        self.character = character
        self.root.title("Game")

        self.info_button = tk.Button(root, text='Character info', command=self.open_info)
        self.info_button.pack()
        self.quest_button = tk.Button(root, text='Quests', command=self.open_quests)
        self.quest_button.pack()
        self.inventory_button = tk.Button(root, text='Inventory', command=self.open_inventory)
        self.inventory_button.pack()
        self.skill_button = tk.Button(root, text='Skills', command=self.open_skills)
        self.skill_button.pack()
        self.friend_button = tk.Button(root, text='Friends', command=self.open_friends)
        self.friend_button.pack()
        self.message_button = tk.Button(root, text='Messages', command=self.open_messages)
        self.message_button.pack()
        self.guild_button = tk.Button(root, text='Guild', command=self.open_guild)
        self.guild_button.pack()
        self.loc_button = tk.Button(root, text='Change location', command=self.open_loc)
        self.loc_button.pack()

    def open_info(self):
        info_window = tk.Tk()
        info_app = InfoApp(info_window, self.character)

    def open_quests(self):
        quests_window = tk.Tk()
        quests_app = QuestApp(quests_window, self.character)

    def open_inventory(self):
        inventory_window = tk.Tk()
        inventory_window = InventoryApp(inventory_window, self.character)

    def open_skills(self):
        skill_window = tk.Tk()
        skill_app = SKillApp(skill_window, self.character)

    def open_friends(self):
        friends_window = tk.Tk()
        friens_app = FriendsApp(friends_window)

    def open_messages(self):
        messages_window = tk.Tk()
        messages_app = MessageApp(messages_window, self.character)

    def open_guild(self):
        guild_window = tk.Tk()
        guild_app = GuildApp(guild_window, self.character)

    def open_loc(self):
        loc_window = tk.Tk()
        loc_app = LocApp(loc_window, self.character)


class CharactersApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Characters Window")
        self.characters = []
        message = {
            'type': 'ch_list'
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            for ch in answer['selected']:
                character_label = tk.Label(root, text=f'{ch[0]}, level {ch[4]}, {dicts.idx2fraction[ch[1]]}, '
                                                      f'{dicts.idx2race[ch[2]]}, {dicts.idx2class[ch[3]]}')
                character_label.pack()
                choose_button = tk.Button(root, text="Choose", command=lambda ch=ch: self.choose(ch[0]))
                choose_button.pack()
                delete_button = tk.Button(root, text="Delete", command=lambda ch=ch: self.delete(ch[0]))
                delete_button.pack()
                self.characters.append(character_label)
        self.register_button = tk.Button(root, text="Create character", command=self.create_character)
        self.register_button.pack()

    def choose(self, name):
        message = {
            'type': 'choose_ch',
            'name': name
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            character = Character(answer)
            self.root.destroy()
            game_window = tk.Tk()
            gameApp = GameApp(game_window, character)
        else:
            show_message(answer['reason'])

    def delete(self, name):
        message = {
            'type': 'delete_ch',
            'name': name
        }
        send_message(message)
        answer = get_message()
        if answer['status']:
            self.root.destroy()
            characters_window = tk.Tk()
            characters_app = CharactersApp(characters_window)
        else:
            show_message(answer['reason'])

    def create_character(self):
        self.root.destroy()
        create_window = tk.Tk()
        createApp = CharacterCreateApp(create_window)


class CharacterCreateApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Character create Window")

        self.name_label = tk.Label(root, text="Enter name of your character")
        self.name_label.pack()
        self.name_entry = tk.Entry(root)
        self.name_entry.pack()

        self.fraction_label = tk.Label(root, text="Choose fraction")
        self.fraction_label.pack()
        self.fraction_choice = tk.StringVar()
        self.fraction_choice.set('Empire')
        self.fraction_box = tk.OptionMenu(root, self.fraction_choice, 'Empire', 'Liga')
        self.fraction_box.pack()

        self.race_label = tk.Label(root, text="Choose race")
        self.race_label.pack()
        self.race_choice = tk.StringVar()
        self.race_choice.set('Kanian')
        self.race_box = tk.OptionMenu(root, self.race_choice, 'Kanian', 'Elf', 'Zen', 'Orc')
        self.race_box.pack()

        self.gender_label = tk.Label(root, text="Choose gender")
        self.gender_label.pack()
        self.gender_choice = tk.StringVar()
        self.gender_choice.set('Male')
        self.gender_box = tk.OptionMenu(root, self.gender_choice, 'Male', 'Female')
        self.gender_box.pack()

        self.class_label = tk.Label(root, text="Choose class")
        self.class_label.pack()
        self.class_choice = tk.StringVar()
        self.class_choice.set('Warrior')
        self.class_box = tk.OptionMenu(root, self.class_choice, 'Warrior', 'Rouge')
        self.class_box.pack()

        self.create_button = tk.Button(root, text="Create", command=self.create)
        self.create_button.pack()

    def create(self):
        character_name = self.name_entry.get()
        if len(character_name) == 0:
            show_message('Please entry character name')
        else:
            fraction = dicts.fraction2idx[self.fraction_choice.get()]
            race = dicts.race2idx[self.race_choice.get()]
            gender = dicts.gender2idx[self.gender_choice.get()]
            cl = dicts.class2idx[self.class_choice.get()]
            message = {
                "type": "create_ch",
                "name": character_name,
                "fraction": fraction,
                "race": race,
                "gender": gender,
                "cl": cl
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                self.root.destroy()
                characters_window = tk.Tk()
                characters_app = CharactersApp(characters_window)
            else:
                show_message(answer['reason'])


class AuthorizationApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Authorization Window")

        self.username_label = tk.Label(root, text="Login or e-mail:")
        self.username_label.pack()

        self.username_entry = tk.Entry(root)
        self.username_entry.pack()

        self.password_label = tk.Label(root, text="Password:")
        self.password_label.pack()

        self.password_entry = tk.Entry(root, show="*")
        self.password_entry.pack()

        self.login_button = tk.Button(root, text="Login", command=self.login)
        self.login_button.pack()

        self.register_button = tk.Button(root, text="Register", command=self.switch_to_registration)
        self.register_button.pack()

        self.delete_button = tk.Button(root, text="Delete", command=self.delete)
        self.delete_button.pack()

    def delete(self):
        username = self.username_entry.get()
        password = self.password_entry.get()
        if len(username) == 0 or len(password) == 0:
            show_message('Please entry login and password')
        else:
            message = {
                "type": "delete_acc",
                "login": username,
                "password": password
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                show_message('Your acc is succesfully deleted')
            else:
                show_message(answer['reason'])

    def login(self):
        username = self.username_entry.get()
        password = self.password_entry.get()
        if len(username) == 0 or len(password) == 0:
            show_message('Please entry login and password')
        else:
            message = {
                "type": "auth",
                "login": username,
                "password": password
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                self.root.destroy()
                characters_window = tk.Tk()
                characters_app = CharactersApp(characters_window)
            else:
                show_message(answer['reason'])

    def switch_to_registration(self):
        self.root.destroy()
        registration_window = tk.Tk()
        registration_app = RegistrationApp(registration_window)


class RegistrationApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Registration Window")

        self.username_label = tk.Label(root, text="New Username:")
        self.username_label.pack()

        self.new_username_entry = tk.Entry(root)
        self.new_username_entry.pack()

        self.e_mail_label = tk.Label(root, text="Your e-mail")
        self.e_mail_label.pack()

        self.e_mail_entry = tk.Entry(root)
        self.e_mail_entry.pack()

        self.password_label = tk.Label(root, text="New Password:")
        self.password_label.pack()

        self.new_password_entry = tk.Entry(root, show="*")
        self.new_password_entry.pack()

        self.register_button = tk.Button(root, text="Register", command=self.register)
        self.register_button.pack()

    def register(self):
        new_username = self.new_username_entry.get()
        e_mail = self.e_mail_entry.get()
        new_password = self.new_password_entry.get()
        if len(new_username) == 0 or len(e_mail) == 0 or len(new_password) == 0:
            show_message('Please fill all entries')
        else:
            message = {
                "type": "reg",
                "login": new_username,
                "password": new_password,
                "e_mail": e_mail
            }
            send_message(message)
            answer = get_message()
            if answer['status']:
                show_message('Registration success')
                self.root.destroy()
                login_window = tk.Tk()
                login_app = AuthorizationApp(login_window)
            else:
                show_message(answer['reason'])


if __name__ == "__main__":
    try:
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.connect((host, port))
        root = tk.Tk()
        app = AuthorizationApp(root)
        root.mainloop()
    except TimeoutError as e:
        print(e)
    except InterruptedError as e:
        print(e)
