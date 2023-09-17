fraction2idx = {
    "Empire": 0,
    "Liga": 1
}

idx2fraction = {value: key for key, value in fraction2idx.items()}

gender2idx = {
    "Male": 0,
    "Female": 1
}

idx2gender = {value: key for key, value in gender2idx.items()}

race2idx = {
    "Kanian": 0,
    "Elf": 1,
    "Zen": 2,
    "Orc": 3
}

idx2race = {value: key for key, value in race2idx.items()}

class2idx = {
    "Warrior": 0,
    "Rouge": 1
}

idx2class = {value: key for key, value in class2idx.items()}

loc2idx = {
    "Barrens": 0,
    "Caverns": 1,
    "Nezebgrad": 2,
    "Gospital": 3,
    "Asee-teph": 4
}

idx2loc = {value: key for key, value in loc2idx.items()}


rarity2idx = {
    "Common": 0,
    "Rare": 1,
    "Epic": 2,
    "Legendary": 3
}

idx2rarity = {value: key for key, value in rarity2idx.items()}

item_type2idx = {
    "weapon": 0,
    'weather': 1,
    "other": 2
}

idx2item_type = {value: key for key, value in item_type2idx.items()}

weapon2idx = {
    "dagger": 0,
    "sword": 1,
    "spear": 2
}

idx2weapon = {value: key for key, value in weapon2idx.items()}

weather2idx = {
    "helmet": 0,
    "chest": 1,
    "greaves": 2,
    "boots": 3,
    "cape": 4
}

idx2weather = {value: key for key, value in weather2idx.items()}
