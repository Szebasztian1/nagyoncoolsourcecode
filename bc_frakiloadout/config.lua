Config = {}

-- Ha true, a /loadouts csak duty állapotban nyitható (ESX meta 'duty' = true)
Config.RequireDuty   = false

-- Fizetési mód: 'money' | 'bank' | 'society'
-- 'society' esetén Config.Society táblát kell kitölteni
Config.Payment       = 'bank'

-- Frakció kasszák (esx_society event-alapú)
Config.Society = {
}

-- Engedélyezett jobok
--   minGrade        : minimum rang a használathoz
--   canShare        : hozhat-e létre shared (frakciós) loadoutot
--   canEditAll      : szerkeszthet-e más shared loadoutot
--   deleteGrade     : ettől a rangtól törölhet más shared loadoutot
Config.Jobs = {
    fbiuj = {
        minGrade    = 0,
        canShare    = true,
        canEditAll  = true,
        deleteGrade = 3,
        coords = vector3(123.82373, -770.2733, 242.15196)
    },
    detective = {
        minGrade    = 0,
        canShare    = true,
        canEditAll  = true,
        deleteGrade = 3,
        coords = vector3(430.3182, -979.4423, 21.55861)
    },
    fbi = {
        minGrade    = 0,
        canShare    = true,
        canEditAll  = true,
        deleteGrade = 3,
        coords = vector3(-447.8894, 6010.5947, 36.995655)
    },
    atf = {
        minGrade    = 0,
        canShare    = true,
        canEditAll  = true,
        deleteGrade = 3,
        coords = vector3(1838.4936, 3682.0456, 34.189262)
    },
    usms = {
        minGrade    = 0,
        canShare    = true,
        canEditAll  = true,
        deleteGrade = 3,
        coords = vector3(850.92266, -1313.075, 28.244935)
    },
    guardarmy = {
        minGrade    = 0,
        canShare    = true,
        canEditAll  = true,
        deleteGrade = 3,
        coords = vector3(240.98802, -332.1473, 54.162059)
    },
    servicess = {
        minGrade    = 0,
        canShare    = true,
        canEditAll  = true,
        deleteGrade = 3,
        coords = vector3(363.71456, -1604.516, 25.451717)
    },
    navi = {
        minGrade    = 0,
        canShare    = true,
        canEditAll  = true,
        deleteGrade = 3,
        coords = vector3(-2305.423, 344.53662, 174.59275)
    },
}

-- Elérhető itemek kategóriánként
--   name      : ox_inventory item neve
--   label     : megjelenített név
--   price     : egységár ($)
--   max       : max darab egy loadoutban
--   grade     : minimum job grade (elhagyható, default 0)
--   meta      : ox_inventory metadata (elhagyható)
Config.Items = {
    {
        cat = 'Fegyverek',
        items = {
            { name='weapon_combatpistol',          label='Combat Pistol',      price=50000,  max=1,   grade=0 },
            { name='weapon_vintagepistol',         label='Vintage Pistol',     price=50000,  max=1,   grade=0 },
            { name='weapon_bullpupshotgun',        label='Bullpup Shotgun',    price=50000,  max=1,   grade=0 },
            { name='weapon_carbinerifle_mk2',      label='Carbine Rifle MK2',  price=50000,  max=1,   grade=0 },
            { name='weapon_appistol',              label='AP Pistol',          price=50000,  max=1,   grade=0 },
            { name='weapon_specialcarbine',        label='Special Carbine',    price=50000,  max=1,   grade=0 },
            { name='weapon_stungun',               label='Stun Gun',           price=500,    max=1,   grade=0 },
            { name='weapon_assaultshotgun', label='Assault Shotgun',    price=50000,  max=1,   grade=0 },
            { name='WEAPON_BEANBAGSHOTGUN', label='Beanbag Shotgun',    price=50000,  max=1,   grade=0 },
            { name='weapon_nightstick',            label='Nightstick',         price=400,    max=1,   grade=0 },
            { name='weapon_carbinerifle',          label='Carbine Rifle',      price=50000,  max=1,   grade=0 },
            { name='weapon_pistol50',       label='Pistol .50',         price=50000,  max=1,   grade=0 },
        }
    },
    {
        cat = 'Lőszer',
        items = {
            { name='rifle_ammo',   label='Rifle Ammo',    price=3000,  max=350, grade=0 },
            { name='pistol_ammo',  label='Pistol Ammo',   price=3000,  max=350, grade=0 },
            { name='smg_ammo',     label='SMG Ammo',      price=3000,  max=350, grade=0 },
            { name='shotgun_ammo', label='Shotgun Ammo',  price=3000,  max=350, grade=0 },
            { name='ammo-bb',      label='BB Ammo',       price=3000,  max=350, grade=0 },
        }
    },
    {
        cat = 'Felszerelés',
        items = {
            { name='spike',                label='Spike Strip',         price=15000, max=2,  grade=0 },
            { name='dashcam',              label='Dashcam',             price=100000, max=1,  grade=0 },
            { name='parachute',            label='Parachute',           price=25000, max=10,  grade=0 },
            { name='szajtapasz',           label='Duct Tape',           price=50000, max=5,  grade=0 },
            { name='nyomkoveto_gps',       label='GPS Tracker',         price=100000, max=1,  grade=0 },
            { name='rendvedelmi_kit1',     label='Protection Kit L1',   price=1000000, max=1,  grade=0 },
            { name='hullazsak',            label='Body Bag',            price=1500,  max=5,  grade=0 },
            { name='gps_nyomkovetolathato',label='Visible GPS Tracker', price=100000, max=3,  grade=0 },
            { name='bilincs',              label='Handcuffs',           price=250,   max=3,  grade=0 },
            { name='WEAPON_FLASHLIGHT',           label='Flashlight',          price=500,   max=1,  grade=0 },
            { name='rendvedelmi_kit2',     label='Protection Kit L2',   price=1200000, max=1,  grade=0 },
            { name='lockpick',             label='Lockpick',            price=8000,  max=5,  grade=0 },
            { name='panicbutton',          label='Panic Button',        price=3000,  max=1,  grade=0 },
            { name='finger_scanner',       label='Finger Scanner',      price=2000,  max=1,  grade=0 },
            { name='mdt',                  label='MDT',                 price=10000, max=1,  grade=0 },
            { name='traffipax',            label='Traffic Radar',       price=100000, max=1,  grade=0 },
            { name='policeshield',         label='Police Shield',       price=1500,  max=1,  grade=0 },
            { name='bodycam',              label='Bodycam',             price=100000, max=1,  grade=0 },
            { name='adr',                  label='ADR Device',          price=30000, max=10,  grade=0 },
            { name='radiozavaro',          label='Radio Jammer',        price=30000, max=1,  grade=0 },
            { name='pd_tracker',           label='PD Tracker',          price=15000, max=10,  grade=0 },
            { name='pd_screwdriver',       label='Screwdriver',         price=2000,  max=20,  grade=0 },
        }
    },
    {
        cat = 'Páncél',
        items = {
            { name='bulletproofvest', label='Bulletproof Vest', price=400, max=25, grade=0 },
        }
    },
}

-- Debug logolás konzolon
Config.Debug = false
