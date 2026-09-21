-- BlackCity | Playtime Shop
-- Játékidő alapján gyűjthető érme + bolt.

Config = {}

Config.Framework = "esx" -- esx / newEsx | newEsx = export system | esx = triggerevent system
Config.Mysql = "oxmysql" -- Check fxmanifest.lua when you change it! | ghmattimysql / oxmysql / mysql-async

Config.OpenCommand = "playtimeShop"
Config.WeaponsAreItem = true
Config.RewardCoin = 35        -- Coins granted per completed interval
Config.NeededPlayTime = 120   -- Minutes of playtime per reward

-- /addcoin <id> <mennyiség> — ezek a csoportok használhatják. A konzol mindig jogosult.
Config.AdminCommand = "addcoin"
Config.AdminMaxGrant = 100000 -- Elgépelés-védelem: egy parancs ennél többet nem mozgathat
Config.AdminGroups = {
    "owner",
    "coowner",
    "superadmin",
    "communitymanager",
    "serverdirector",
    "headadmin",
    "developer",
}

Config.Language = {
    brand = "BlackCity",
    title = "Játékidő shop",
    coin = "érme",

    shopEyebrow = "Elérhető termékek",
    shopTitle = "BOLT",
    topEyebrow = "Ranglista",
    topTitle = "TOP JÁTÉKOSOK",

    nextReward = "Következő érmejutalomig",
    reward = "Jutalom",
    player = "Játékos",

    buy = "Vásárlás",
    cancel = "Mégse",
    confirmTitle = "Megerősíted a vásárlást?",

    nextPage = "Következő",
    previousPage = "Előző",
    emptyCategory = "Ebben a kategóriában nincs termék.",

    purchased = "Sikeres vásárlás",
    youDntHvEngMoney = "Nincs elég érméd!",
    inventoryFull = "Nincs elég hely a táskádban!",
}

-- `label` shows on the sidebar nav; `icon` is a Font Awesome class.
Config.Categories = {
    { category = "items",    label = "Tárgyak",  icon = "fa-solid fa-cookie-bite", items = {} }, -- do not touch items section..
    { category = "weapons",  label = "Fegyverek", icon = "fa-solid fa-gun",        items = {} }, -- do not touch items section..
    { category = "vehicles", label = "Járművek",  icon = "fa-solid fa-car",        items = {} }, -- do not touch items section..
}

-- YOU SHOULD SET ITEMS! THESE ARE JUST EXAMPLE!
-- itemType : vehicle, weapon, item, money
Config.Items = {
    { id = 1,  itemName = "weapon_heavypistol",   label = "Heavy Pisztoly",       price = 120,   count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_heavypistol.webp" },
    { id = 2,  itemName = "weapon_bat",  label = "Baseball ütő",      price = 30,  count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_bat.webp" },
    { id = 3,  itemName = "weapon_pistol_mk2",      label = "Pisztoly MK2",          price = 120,  count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_pistol_mk2.webp" },
    { id = 4,  itemName = "weapon_vintagepistol", label = "Vintage Pisztoly",     price = 100,   count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_vintagepistol.webp" },
    { id = 5,  itemName = "weapon_combatmg",           label = "Combat MG M249",                price = 200,  count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_combatmg.webp" },
    { id = 6,  itemName = "weapon_minismg",     label = "Mini SMG",         price = 150,  count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_minismg.webp" },
    { id = 7,  itemName = "weapon_specialcarbine",  label = "G36C",      price = 150,  count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_specialcarbine.webp" },
    { id = 8,  itemName = "weapon_pumpshotgun",         label = "Pump Shotgun",              price = 150,  count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_pumpshotgun.webp" },
    { id = 9, itemName = "weapon_tacticalrifle",       label = "M16A4",            price = 150,   count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_tacticalrifle.webp" },
    { id = 10, itemName = "weapon_smg",       label = "SMG",            price = 100,   count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_smg.webp" },
    { id = 11, itemName = "weapon_switchblade",       label = "Rúgos kés",            price = 60,   count = 1,  itemType = "item",    category = "weapons",  image = "nui://ox_inventory/web/images/weapon_switchblade.webp" },

    { id = 12, itemName = "ujrepairkit",            label = "Szerelő láda",       price = 80,   count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/ujrepairkit.webp" },
    { id = 13, itemName = "monky",           label = "Monky Pet",        price = 100,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/monky.webp" },
    { id = 14, itemName = "buttercup",        label = "Buttercup Pet",                price = 115,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/buttercup.webp" },
    { id = 15, itemName = "cocaine",       label = "Kokain 1x",              price = 50,   count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/cocaine.webp" },
    { id = 16, itemName = "hnganh_politoed",         label = "Politoed Táska",  price = 1500,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/hnganh_politoed.webp" },
    { id = 17, itemName = "bandage",              label = "Kötszer",            price = 30,   count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/bandage.webp" },
    { id = 18, itemName = "ujmedikit",              label = "Mentőkészlet",       price = 50,   count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/ujmedikit.webp" },
    { id = 19, itemName = "lockpick",             label = "Zár Feltoro",        price = 25,   count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/lockpick.webp" },
    { id = 20, itemName = "carplay",             label = "Autó tablet",            price = 30,    count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/carplay.webp" },
    --{ id = 21, itemName = "phone",                label = "Telefon",            price = 35,   count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/phone.webp" },
    { id = 22, itemName = "pistol_ammo",          label = "Pistol Töltény",     price = 30,   count = 50, itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/pistol_ammo.webp" },
    { id = 23, itemName = "rifle_ammo",             label = "Nagykaliberű Töltény",        price = 45,   count = 50, itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/rifle_ammo.webp" },
    { id = 24, itemName = "hnganh_scooby",     label = "Vándor Táska (3) Trash",    price = 500,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/hnganh_scooby.webp" },
    { id = 25, itemName = "nitro",     label = "Nitro",    price = 125,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/nitro.webp" },
    { id = 26, itemName = "bag",     label = "Táksa",    price = 50,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/bag.webp" },
    { id = 27, itemName = "rozsa1",     label = "Kézben tartott rózsa",    price = 400,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/rozsa1.webp" },
    { id = 28, itemName = "shotgun_ammo",     label = "Shothun lőszer",    price = 50,  count = 50,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/shotgun_ammo.webp" },
    { id = 29, itemName = "mg_ammo",     label = "MG lőszer",    price = 50,  count = 50,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/mg_ammo.webp" },
    { id = 30, itemName = "ujphone",     label = "Telefon",    price = 15,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/ujphone.webp" },
    { id = 31, itemName = "ujtracker",     label = "GPS jeladó",    price = 15,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/ujtracker.webp" },
    { id = 32, itemName = "parachute",     label = "Ejtőernyő",    price = 20,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/parachute.webp" },



    { id = 33, itemName = "nm_190evo",               label = "Mercedes-Benz 190-Class (Police)",      price = 6000, count = 1,  itemType = "vehicle", category = "vehicles", image = "./images/car.png" },
    { id = 34, itemName = "S500",            label = "Mercedes-Benz S500", price = 6000, count = 1,  itemType = "vehicle", category = "vehicles", image = "./images/car.png" },
    { id = 35, itemName = "toxic_watchdog_bag_01",     label = "Watchdog Trash Táska",    price = 5000,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/toxic_watchdog_bag_01.webp" },
    { id = 36, itemName = "toxic_tactical_bag_01",     label = "Tactical Trash Táska",    price = 5000,  count = 1,  itemType = "item",    category = "items",    image = "nui://ox_inventory/web/images/toxic_tactical_bag_01.webp" },
    { id = 37, itemName = "tdbhummer",            label = "Hummer EV", price = 6000, count = 1,  itemType = "vehicle", category = "vehicles", image = "./images/car.png" },
}