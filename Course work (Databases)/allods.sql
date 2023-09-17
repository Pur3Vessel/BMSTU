/*-----    Игроки    -----*/

drop table if exists players cascade;

create table players (
    Player_ID serial primary key,
    Login varchar(30) unique not null CHECK (Login ~* '^[^@]+$'),
    Password varchar(30) not null,
    Registration_date date not null,
    E_mail varchar(50) unique not null CHECK (E_mail ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')
);

/*-----    Гильдии    -----*/

drop table if exists guilds cascade;

create table guilds (
    Guild_ID serial primary key,
    Guild_name varchar(30) unique not null,
    Number_of_members integer not null check (Number_of_members > 0 and Number_of_members < 51),
    Description varchar(200) null,
    Minimal_level integer not null constraint min_gl check (Minimal_level > 0 and Minimal_level < 6),
    Leader_ID integer null
);

/*-----    Персонажи    -----*/

drop table if exists characters cascade;

create table characters (
    Character_ID serial primary key,
    Character_name varchar(30) unique not null,
    Fraction integer not null constraint fraction_c check (Fraction >= 0 and Fraction < 2),
    Race integer not null constraint race_c check (Race >=0 and Race < 5),
    Gender integer not null check (Gender >=0 and Gender < 2),
    Class integer not null constraint class_c check (Class >= 0 and Class < 2),
    Level integer not null constraint level_c check (Level > 0 and Level < 7),
    Exp integer not null check (Exp >= 0),
    Hp integer not null check (Hp > 0),
    Mana integer not null check (Mana > 0),
    Location integer not null constraint loc_c check (Location >= 0 and Location < 5),
    Gold integer not null check (gold >= 0),
    X_pos double precision not null check (X_pos > -500 and X_pos < 500),
    Y_pos double precision not null check (Y_pos > -500 and  Y_pos <= 500),
    Z_pos double precision not null check (Z_pos > -50 and Z_pos < 50),
    Guild_ID integer null references guilds(Guild_ID) on update cascade on delete set null,
    Player_ID integer not null references players(Player_ID) on update cascade on delete cascade
);

alter table guilds add constraint guild_leader foreign key (Leader_ID)
    references characters(Character_ID) on update cascade on delete set null;


CREATE OR REPLACE FUNCTION update_guild_id()
RETURNS TRIGGER AS $$
DECLARE
    new_guild_id INT;
    current_members INT;
    new_leader_id INT;
BEGIN
    new_guild_id := NEW.Guild_ID;

    IF new_guild_id IS NOT NULL THEN
        IF OLD.level < (SELECT Minimal_level from guilds where Guild_ID = NEW.guild_id) then
            RAISE EXCEPTION 'Your level is less than minimal in this guild';
        end if;

        SELECT Number_of_members INTO current_members
        FROM guilds
        WHERE Guild_ID = new_guild_id;

        IF current_members >= 50 THEN
            RAISE EXCEPTION 'The guild already has the maximum number of members (50)';
        END IF;

        IF OLD.Character_ID != (SELECT Leader_ID FROM guilds WHERE Guild_ID = NEW.Guild_ID) THEN
           UPDATE guilds
            SET Number_of_members = Number_of_members + 1
            WHERE Guild_ID = new_guild_id;
        end if;

    END IF;

    IF new_guild_id IS NULL THEN
        IF OLD.Guild_ID IS NOT NULL THEN
            SELECT Number_of_members INTO current_members
            FROM guilds
            WHERE Guild_ID = OLD.Guild_ID;

            IF current_members > 1 THEN
                UPDATE guilds
                SET Number_of_members = Number_of_members - 1
                WHERE Guild_ID = OLD.Guild_ID;
            ELSE
                DELETE FROM guilds
                WHERE Guild_ID = OLD.Guild_ID;
            END IF;

            IF OLD.Character_ID = (SELECT Leader_ID FROM guilds WHERE Guild_ID = OLD.Guild_ID) THEN
                SELECT Character_ID INTO new_leader_id
                FROM characters
                WHERE Guild_ID = OLD.Guild_ID
                ORDER BY Level DESC
                LIMIT 1;

                UPDATE guilds
                SET Leader_ID = new_leader_id
                WHERE Guild_ID = OLD.Guild_ID;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_guild_id_trigger
AFTER UPDATE ON characters
FOR EACH ROW
WHEN ((NEW.Guild_ID IS NULL AND OLD.Guild_ID IS NOT NULL) or ((NEW.Guild_ID IS NOT NULL AND OLD.Guild_ID IS NULL)))
EXECUTE FUNCTION update_guild_id();



CREATE OR REPLACE FUNCTION delete_character()
RETURNS TRIGGER AS $$
DECLARE
    current_members INT;
    new_leader_id INT;
BEGIN
    SELECT Number_of_members INTO current_members
    FROM guilds
    WHERE Guild_ID = OLD.Guild_ID;

    IF (SELECT Leader_ID FROM guilds WHERE Guild_ID = OLD.Guild_ID) is null AND current_members > 1 THEN
        SELECT Character_ID INTO new_leader_id
        FROM characters
        WHERE Guild_ID = OLD.Guild_ID and Character_ID != OLD.character_id
        ORDER BY Level DESC
        LIMIT 1;

        UPDATE guilds
        SET Leader_ID = new_leader_id
        WHERE Guild_ID = OLD.Guild_ID;
    END IF;

    IF current_members > 1 THEN
        UPDATE guilds
        SET Number_of_members = current_members - 1
        WHERE Guild_ID = OLD.Guild_ID;
    ELSE
        DELETE FROM guilds
        WHERE Guild_ID = OLD.Guild_ID;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER delete_character_trigger
AFTER DELETE ON characters
FOR EACH ROW
EXECUTE FUNCTION delete_character();


drop table if exists characters_friends cascade;

create table characters_friends (
     Character_ID integer references characters(Character_ID) on delete cascade on update cascade ,
    Friend_ID integer references characters(Character_ID) on delete cascade on update cascade,
    PRIMARY KEY (Character_ID, Friend_ID)
);

CREATE OR REPLACE FUNCTION check_duplicate_friendship()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM characters_friends
    WHERE (Character_ID = NEW.Friend_ID AND Friend_ID = NEW.Character_ID)
    OR (Character_ID = NEW.Character_ID AND Friend_ID = NEW.Friend_ID)
  ) THEN
    RAISE EXCEPTION 'Duplicate friendship';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_duplicate_friendship
BEFORE INSERT ON characters_friends
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_friendship();

/*-----    Сообщения    -----*/

drop table if exists messages cascade;

create table messages (
    Message_ID serial primary key,
    Sending_time timestamp unique not null,
    Receiver_type integer not null check (Receiver_type >= 0 and Receiver_type < 3),
    Text varchar(200) not null,
    Sender_ID integer not null references characters(Character_ID) on delete cascade on update cascade
);

drop table if exists to_other cascade;

create table to_other (
    Message_ID serial primary key references messages(Message_ID) on delete cascade on update cascade,
    Receiver_ID integer not null references characters(Character_ID) on update cascade on delete cascade
);

drop table if exists to_loc cascade;

create table to_loc (
    Message_ID serial primary key references messages(Message_ID) on delete cascade on update cascade,
    Loc integer not null constraint loc_c check (Loc >= 0 and Loc < 3)
);

drop table if exists to_guild cascade;

create table to_guild (
    Message_ID serial primary key references messages(Message_ID) on delete cascade on update cascade,
    Guild_ID integer not null references guilds(Guild_ID) on update cascade on delete cascade
);


CREATE OR REPLACE FUNCTION delete_message()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM messages where messages.Message_ID = OlD.Message_ID;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_other_message
AFTER DELETE ON to_other
FOR EACH ROW
EXECUTE FUNCTION delete_message();

CREATE TRIGGER delete_guild_message
AFTER DELETE ON to_guild
FOR EACH ROW
EXECUTE FUNCTION delete_message();
/*-----    Способности    -----*/

drop table if exists skills cascade;

create table skills (
    Skill_ID serial primary key,
    Skill_name varchar(40) unique not null,
    Description varchar(100) null,
    Cooldown integer not null check (Cooldown > 0),
    Class integer not null constraint class_c check (Class >= 0 and Class < 2),
    Manacost integer not null check (Manacost >= 0)
);

drop table if exists skill_learned cascade;

create table skill_learned (
    Skill_ID integer references skills(Skill_ID) on delete cascade on update cascade,
    Character_ID integer references characters(Character_ID) on delete cascade on update cascade,
    Skill_level integer not null check (Skill_level > 0 and Skill_level < 4),
    primary key (Skill_ID, Character_ID)
);

drop table if exists skill_need cascade;

create table skill_need (
    Skill_ID integer references skills(Skill_ID) on delete cascade on update cascade,
    Access_ID integer references skills(Skill_ID) on delete cascade on update cascade,
    primary key (Skill_ID, Access_ID)
);


insert into skills(Skill_name, Description, Cooldown, Class, Manacost) values
                                            ('Shield bash', 'Warrior deals a powerful blow that stuns the enemy for 1 second', 4, 0, 5),
                                            ('Charge', 'Warrior makes a dash towards the enemy and stuns him for 2 seconds', 10, 0, 15),
                                            ('Roar', 'Warrior emits a roar and reduces the armor of surrounding enemies', 12, 0, 20),
                                            ('Parry', 'Warrior parries the opponent next strike and takes no damage', 5, 0, 5),
                                            ('Invisible', 'Rouge become invisible. His next attack deals 140% damage', 25, 1, 10),
                                            ('Back stab', 'Rouge attacks the enemy in the back and deals 180% damage', 7, 1, 0),
                                            ('Teleport', 'Rouge teleports behind the enemy back', 20, 1, 5),
                                            ('Shadow step', 'Rouge instantly spares the next skill cooldown', 30, 1, 15);


insert into skill_need(Skill_ID, Access_ID) values (1, 2),
                                                   (1, 3),
                                                   (2, 4),
                                                   (3, 4),
                                                   (5, 6),
                                                   (5, 7),
                                                   (6, 8),
                                                   (7, 8);


CREATE OR REPLACE FUNCTION check_need_learn()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM skill_need sn
        LEFT JOIN skill_learned sl ON sn.Skill_ID = sl.Skill_ID AND sl.Character_ID = NEW.Character_ID
        WHERE sn.Access_ID = NEW.Skill_ID
        AND sl.Skill_ID IS NULL
    ) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Character does not have access to the required skill';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_character_learned_trigger
BEFORE INSERT ON skill_learned
FOR EACH ROW
EXECUTE FUNCTION check_need_learn();

/*-----    Предметы    -----*/

drop table if exists items cascade;

create table items (
    Item_ID serial primary key,
    Item_name varchar(40) not null,
    Item_level integer not null constraint iteml_c check (Item_level > 0 and Item_level < 6),
    Rarity integer not null check (Rarity >= 0 and Rarity < 4),
    Description varchar(60) null,
    Item_type integer not null check (Item_type >= 0 and Item_type < 3),
    unique(Item_name, Item_level, Rarity)
);

drop table if exists weapon cascade;

create table weapon (
    Item_ID serial primary key references items(Item_ID) on delete cascade on update cascade,
    Damage integer not null check (Damage > 0),
    Attack_speed double precision not null check (Attack_speed > 0),
    Attack_range double precision not null check (Attack_range > 0),
    Weapon_type integer not null constraint weapont_c check (Weapon_type >= 0 and Weapon_type < 3)
);

drop table if exists weather cascade;

create table weather (
    Item_ID serial primary key references items(Item_ID) on delete cascade on update cascade,
    Weather_type integer not null constraint weathert_c check (Weather_type >= 0 and Weather_type < 5),
    Armor integer not null check (Armor >= 0),
    Attribute_bonus integer not null check (Attribute_bonus > 0)
);

drop table if exists other_table cascade;

create table other_table (
    Item_ID serial primary key references items(Item_ID) on delete cascade on update cascade,
    Is_quest integer not null check (Is_quest >= 0 and Is_quest < 2)
);

insert into items(item_name, item_level, rarity, description, item_type) values
('Report', 1, 0, '', 2),
('Iron dagger', 1, 0, '', 0),
('Leather helmet', 1, 0, '', 1),
('Leather chest', 1, 0, '', 1),
('Leather greaves', 1, 0, '', 1),
('Leather boots', 1, 0, '', 1),
('Leather cape', 1, 0, '', 1),
('Sharpened spear', 2, 1, '', 0),
('The keeper tear', 3, 1, '',  2),
('Speed boots', 3, 3, '', 1),
('Scarlet cape', 4, 2, '', 1),
('Sword of a Thousand Truths', 5, 3, '', 0);

insert into weapon(item_id, damage, attack_speed, attack_range, weapon_type) values
(2, 3, 0.5, 1.2, 0),
(8, 9, 2.0, 2.0, 1),
(12, 20, 1.0, 1.8, 2);

insert into weather(item_id, weather_type, armor, attribute_bonus) values
(3, 0, 2, 1),
(4, 1, 4, 2),
(5, 2, 3, 2),
(6, 3, 1, 2),
(7, 4, 0, 4),
(10, 3, 2, 6),
(11, 4, 1, 10);

insert into other_table(item_id, is_quest) VALUES
(1, 1),
(9, 0);

drop table if exists item_in_inventory cascade;

create table item_in_inventory (
    Character_ID integer references characters(Character_ID) on delete cascade on update cascade,
    Item_ID integer references items(Item_ID) on delete cascade on update cascade,
    Amount integer not null check (Amount > 0),
    Is_equipped integer null check (Is_equipped >= 0 and Is_equipped < 2),
    primary key (Character_ID, Item_ID)
);

CREATE OR REPLACE FUNCTION update_equipped()
RETURNS TRIGGER AS $$
DECLARE
    item_level INT;
    character_level INT;
BEGIN
    IF NEW.Is_equipped = 1 THEN
        SELECT items.Item_level INTO item_level
        FROM items
        WHERE Item_ID = NEW.Item_ID;

        SELECT characters.Level INTO character_level
        FROM characters
        WHERE Character_ID = NEW.Character_ID;

        IF item_level > character_level THEN
            RAISE EXCEPTION 'You can not equip item with a level higher than the character level';
        end if;

        IF (SELECT Item_type FROM items WHERE Item_ID = NEW.Item_ID) = 0 THEN
            UPDATE item_in_inventory
            SET Is_equipped = 0
            WHERE Character_ID = NEW.Character_ID
            AND Item_ID != NEW.Item_ID
            AND (SELECT Item_type FROM items WHERE Item_ID = Item_in_inventory.Item_ID) = 0;
            END IF;

        IF (SELECT Item_type FROM items WHERE Item_ID = NEW.Item_ID) = 1 THEN
            UPDATE item_in_inventory
            SET Is_equipped = 0
            WHERE Character_ID = NEW.Character_ID
            AND Item_ID != NEW.Item_ID
            AND (SELECT Item_type FROM items WHERE Item_ID = Item_in_inventory.Item_ID) = 1
            AND (SELECT Weather_type FROM weather WHERE Item_ID = Item_in_inventory.Item_ID) = (SELECT Weather_type FROM weather WHERE Item_ID = NEW.Item_ID);
            END IF;

        IF (SELECT Item_type FROM items WHERE Item_ID = NEW.Item_ID) = 2 THEN
            RAISE EXCEPTION 'This item can not be equipped';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER equipped_trigger
BEFORE UPDATE ON item_in_inventory
FOR EACH ROW
WHEN (NEW.Is_equipped <> OLD.Is_equipped)
EXECUTE FUNCTION update_equipped();

/*-----    Квесты    -----*/

drop table if exists quests cascade;

create table quests (
    Quest_ID serial primary key,
    Quest_name varchar(50) unique not null,
    Level integer not null constraint questl_c check (Level > 0 and Level < 6),
    Is_storyline integer not null check (Is_storyline >= 0 and Is_storyline < 2),
    Gold_reward integer not null check (Gold_reward >= 0),
    Exp_reward integer not null check (Exp_reward >= 0),
    Description varchar(1000) null
);

insert into quests(quest_name, level, is_storyline, gold_reward, exp_reward, description)
VALUES ('Bring a report', 1, 1, 50, 80, 'You were sent to an outpost in the barrens to report to the patrol commander'),
       ('Boar hunting', 2, 0, 100, 80, 'The сommander has sent you to collect 10 boar skins'),
       ('Destroying elementals', 3, 0, 100, 80, 'The commander sent you to clear the gorge of water elementals'),
       ('Find Olgra', 4, 0, 120, 80, 'Mancrick asked you to find his missing wife'),
       ('Deflect the attack', 5, 1, 200, 80, 'Repel the undead attack on the outpost');

drop table if exists quest_taken cascade;

create table quest_taken (
    Character_ID integer references characters(Character_ID) on delete cascade on update cascade,
    Quest_ID integer references quests(Quest_ID) on delete cascade on update cascade,
    Is_completed integer not null check (Is_completed >= 0 and Is_completed < 2),
    primary key (Character_ID, Quest_ID)
);

CREATE OR REPLACE FUNCTION check_quest_level()
RETURNS TRIGGER AS $$
BEGIN
    DECLARE
        character_level integer;
        quest_level integer;
    BEGIN
        SELECT Level INTO character_level
        FROM characters
        WHERE Character_ID = NEW.Character_ID;

        SELECT Level INTO quest_level
        FROM quests
        WHERE Quest_ID = NEW.Quest_ID;

        IF character_level < quest_level THEN
            RAISE EXCEPTION 'Level is too low';
        END IF;

        RETURN NEW;
    END;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_quest_level_trigger
BEFORE INSERT ON quest_taken
FOR EACH ROW
EXECUTE FUNCTION check_quest_level();

drop table if exists item_reward cascade;

create table item_reward (
    Item_ID integer references items(Item_ID) on delete cascade on update cascade,
    Quest_ID integer references quests(Quest_ID) on delete cascade on update cascade,
    primary key (Item_ID, Quest_ID)
);

insert into item_reward(item_id, quest_id) VALUES
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 2),
(9, 3),
(10, 3),
(11, 4),
(12, 5);