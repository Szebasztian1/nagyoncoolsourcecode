INSPECTIONTIME                = 60 * 60 * 24 * 60
INSPECTIONPERCAR              = 750000

MEDCLEARANCE_TIME             = 60 * 60 * 24 * 14
MEDCLEARANCE_COST             = 7000000
MEDCLEARANCE_SOCIETY_CUT      = 5000000

MECHANICCLEARANCE_TIME        = 60 * 60 * 24 * 14
MECHANICCLEARANCE_COST        = 7000000
MECHANICCLEARANCE_SOCIETY_CUT = 5000000

---@type table<string, boolean>
MEDCLEARANCE_WEAPON_WHITELIST = {
    ["WEAPON_SNOWBALL"]      = true,
    ["WEAPON_BALL"]          = true,
    ["WEAPON_FERTILIZERCAN"] = true,
    ["WEAPON_PETROLCAN"]     = true,
    ["WEAPON_HAZARDCAN"]     = true,
    ["WEAPON_NIGHTSTICK"]    = true,
    ["WEAPON_STUNGUN"]       = true,
    ["WEAPON_STUNGUN_MP"]    = true,
    ["WEAPON_UNARMED"]       = true,
    ["WEAPON_BATTLEAXE"]     = true,
    ["WEAPON_KNIFE"]         = true,
    ["WEAPON_BAT"]           = true,
    ["WEAPON_MACHETE"]       = true,
    ["WEAPON_SWITCHBLADE"]   = true,
    ["WEAPON_BOTTLE"]        = true,
    ["WEAPON_PRESSURE1"]        = true,
}

---@type table<string, boolean>
MEDCLEARANCE_JOB_WHITELIST    = {
    ["fbiuj"] = true,
    ["uss"] = true,
    ["irs"] = true,
    ["atf"] = true,
    ["navi"] = true,
    ["fbi"] = true,
    ["detective"] = true,
    ["guardarmy"] = true,
    ["usms"] = true,
    ["servicess"] = true,
    ["sheriff"] = true,
    ["state"] = true,
    ["ambulance"] = true,
    ["mechanic"] = true,
    ["kingmaffia"] = true,
    ["lifthouse"] = true,
    ["blackmamba"] = true,
    ["exotic"] = true,
    ["lostmc"] = true,
    ["ujfrakciodawe3"] = true,
    ["themetalshop"] = true,
    ["bennysservice"] = true,
    ["alkaida"] = true,
    ["topgear"] = true,
    ["sonsofanarchy"] = true,
    ["umechanic"] = true,
    ["wsqmechanic"] = true,
}

FAKE_INSPECTION_PRICE         = 200000
FAKE_INSPECTION_TIME          = 60 * 60 * 24 * 5

---@class FakeInspectionNpcConfig
---@field coords vector4
---@field model  string
FAKE_INSPECTION_NPC           = {
    coords = vector4(1463.1221, 6566.3647, 13.316267, 129.41156),
    model  = "a_f_m_ktown_01",
}

NPC_MIN_MECHANICS             = 3
NPC_MIN_CLEARANCE_COPS        = 20
NPC_MIN_CLEARANCE_AMB        = 3

---@class NpcInspectionConfig
---@field coords vector4
---@field model string
---@field cost number
---@field progressTime number
---@field blipSprite number
---@field blipColour number
---@field blipScale number
---@field blipLabel string
NPC_INSPECTION                = {
    coords       = vector4(-794.7792, -2415.981, 14.736455, 296.24758),
    model        = "a_f_m_ktown_01",
    cost         = 2000000,
    progressTime = 5 * 60 * 1000,
    blipSprite   = 446,
    blipColour   = 5,
    blipScale    = 0.8,
    blipLabel    = "Müszaki/Engedély NPC", -- ez jelöli a mellette álló szerelési engedélyes NPC-t is
}

---@class NpcClearanceConfig
---@field coords vector4
---@field model string
---@field cost number
---@field progressTime number
---@field blipSprite number
---@field blipColour number
---@field blipScale number
---@field blipLabel string
NPC_MECHANIC_CLEARANCE        = {
    coords       = vector4(-795.7602, -2413.618, 14.736469, 296.57464),
    model        = "a_f_m_ktown_01",
    cost         = 7000000,
    progressTime = 5 * 60 * 1000,
    blipSprite   = 0, -- 0 = nincs blip: a 2,5 m-re álló NPC_INSPECTION blipje jelöli (régen 60)
    blipColour   = 3,
    blipScale    = 0.8,
    blipLabel    = "NPC Szerelési Engedély",
}

NPC_AMBULANCE_CLEARANCE        = {
    coords       = vector4(290.29479, -613.2044, 43.416107, 67.909492),
    model        = "a_f_m_ktown_01",
    cost         = 7000000,
    progressTime = 5 * 60 * 1000,
    blipSprite   = 61,
    blipColour   = 3,
    blipScale    = 0.8,
    blipLabel    = "NPC Alkalmassági",
}

-- ===================== Műszaki Terminál (NUI) =====================

-- Item that opens the inspection terminal when used (ox_inventory usable).
-- Mechanics buy it from a player-run shop; only mechanic jobs can use it.
TERMINAL_ITEM = 'szerelotablet'

-- Mechanic jobs allowed to open the terminal and issue inspections.
-- Single source of truth (server.lua references this list too). Keep the exact
-- entries: #MEJOBS is used as a divisor in the NPC society payout, so removing
-- the duplicate "exotic" would change the split — leave the list untouched.
MEJOBS = { "mechanic", "moscar", "kingmaffia", "lifthouse", "themetalshop", "blackmamba", "exotic", "wsqcustoms",
    "ujfrakciodawe3", "bennysservice", "alkaida", "exotic", "topgear", "sonsofanarchy", "ms13", "umechanic",
    "acabmechanic" }

-- Diagnostic checklist shown in the terminal. Every point must be marked
-- "passed" before an inspection can be issued (enforced client + server side).
INSPECTION_CHECKLIST = {
    "Fékrendszer",
    "Világítás",
    "Futómű",
    "Kipufogó / emisszió",
    "Karosszéria",
}

-- ===================== NPC engedély-vizsgák =====================

-- Exams taken at the clearance NPCs. Two independent kinds, each with its own
-- question pool, fee, lockout and DB column:
--   mechanic -> szerelési engedély  (NPC_MECHANIC_CLEARANCE)  – szerelős kérdések
--   med      -> fegyver-alkalmassági (NPC_AMBULANCE_CLEARANCE) – fegyveres kérdések
--
-- The fee is charged up front and is NOT refunded on failure; a perfect test
-- then rolls `passChance` for the licence. A failed attempt locks the player out
-- for `retryHours` (stored in the DB, so it survives restarts).
--
-- `correct` is the 1-based index in `answers` and is NEVER sent to the client —
-- the server keeps it and grades the submission. Vary it across questions.
CLEARANCE_EXAMS = {
    mechanic = {
        eyebrow       = "Rendvédelmi hatóság",
        title         = "Szerelési",
        titleAccent   = "vizsga",
        questionCount = 5,
        passChance    = 70,
        retryHours    = 10,
        cost          = MECHANICCLEARANCE_COST, -- 7.000.000
        questions     = {
            {
                q = "Mikor kezdheted meg egy jármű javítását?",
                answers = { "Ha az ügyfél megbízott vele", "Ha megtetszik az autó", "Bármikor, ha nyitva a műhely" },
                correct = 1,
            },
            {
                q = "Mit teszel, ha az alvázszám nem egyezik a papírokkal?",
                answers = { "Megjavítod és hallgatsz róla", "Jelented a hatóságnak", "Átütöd az alvázszámot" },
                correct = 2,
            },
            {
                q = "Mi kötelező emelőn végzett munka előtt?",
                answers = { "Alátámasztás bakkal", "Semmi, elég az emelő", "Csak a kézifék behúzása" },
                correct = 1,
            },
            {
                q = "Milyen járművet nem adhatsz ki a műhelyből?",
                answers = { "A régi típusúakat", "A nem közlekedésbiztos járművet", "A festetlen járművet" },
                correct = 2,
            },
            {
                q = "Mire jogosít a szerelési engedély?",
                answers = { "Fegyver tartására", "Járműjavítási munka végzésére", "Gyorshajtásra munka közben" },
                correct = 2,
            },
            {
                q = "Mit kezdesz a fáradt olajjal olajcsere után?",
                answers = { "Kiöntöd a csatornába", "Elégeted", "Szabályos gyűjtőbe adod" },
                correct = 3,
            },
            {
                q = "Meddig érvényes a szerelési engedély?",
                answers = { "Örökre szól", "Két hétig, utána újra kell váltani", "Egy napig" },
                correct = 2,
            },
            {
                q = "Mit ellenőrzöl kötelezően fékjavítás után?",
                answers = { "A fékek működését próbaúton", "Csak a lámpákat", "Semmit, ha beépült" },
                correct = 1,
            },
            {
                q = "Végezhetsz teljesítménynövelő átalakítást?",
                answers = { "Igen, bármikor", "Csak engedéllyel és dokumentálva", "Csak éjszaka" },
                correct = 2,
            },
            {
                q = "Mit teszel, ha lopott járművet hoznak javításra?",
                answers = { "Megjavítod", "Szétszereled alkatrésznek", "Értesíted a hatóságot" },
                correct = 3,
            },
        },
    },

    med = {
        eyebrow       = "Fegyver-alkalmassági",
        title         = "Fegyvertartási",
        titleAccent   = "vizsga",
        questionCount = 5,
        passChance    = 70,
        retryHours    = 10,
        cost          = MEDCLEARANCE_COST, -- 7.000.000
        questions     = {
            {
                q = "Hol tarthatod jogszerűen a fegyvered a városban?",
                answers = { "Szabadon, a kezedben", "Elrejtve, a hozzá tartozó tokban", "A jármű motorháztetején" },
                correct = 2,
            },
            {
                q = "Mit teszel, ha rendvédelmi igazoltat és fegyver van nálad?",
                answers = { "Szólsz róla és felmutatod az engedélyt", "Azonnal előveszed", "Letagadod" },
                correct = 1,
            },
            {
                q = "Kinek adhatod át a fegyvered?",
                answers = { "Bárkinek, aki kéri", "Csak a barátaidnak", "Csak érvényes engedéllyel rendelkezőnek" },
                correct = 3,
            },
            {
                q = "Mi a teendő, ha elvesztetted a fegyvered?",
                answers = { "Semmi, majd előkerül", "Haladéktalanul bejelented a rendvédelemnél", "Veszel egy újat" },
                correct = 2,
            },
            {
                q = "Mikor használhatod jogszerűen a fegyvered?",
                answers = { "Jogos védelmi helyzetben", "Ha valaki felidegesít", "Vita eldöntésére" },
                correct = 1,
            },
            {
                q = "Meddig érvényes a kiváltott engedély?",
                answers = { "Örökre szól", "Egy napig", "Két hétig, utána újra kell váltani" },
                correct = 3,
            },
            {
                q = "Leadhatsz-e figyelmeztető lövést lakott területen?",
                answers = { "Igen, bármikor", "Nem, tilos", "Csak éjszaka" },
                correct = 2,
            },
            {
                q = "Mi a biztonságos fegyverkezelés alapszabálya?",
                answers = { "Minden fegyvert töltöttnek tekintünk", "Csak a töltött fegyver veszélyes", "Tár nélkül nincs kockázat" },
                correct = 1,
            },
            {
                q = "Merre kell irányítani a csövet tisztítás közben?",
                answers = { "Amerre kényelmes", "A társad felé", "Biztonságos irányba" },
                correct = 3,
            },
            {
                q = "Mit jelent, ha lejárt az engedélyed?",
                answers = { "Semmit, marad a fegyver", "Nem tarthatsz fegyvert, le kell adnod", "Még egy hónapig érvényes" },
                correct = 2,
            },
        },
    },
}

-- ===================== Üzembehelyezési Engedély =====================

-- Egy hónapig érvényes, autónkénti díja a tulaj (vagy frakciós autónál a
-- frakció) vagyonának UZEMBEHELYEZES_FEE_RATE-je, min/max korlátok között.
UZEMBEHELYEZESTIME            = 60 * 60 * 24 * 30
UZEMBEHELYEZES_MIN_FEE        = 1000000
UZEMBEHELYEZES_MAX_FEE        = 15000000
UZEMBEHELYEZES_FEE_RATE       = 0.003 -- vagyon 0,3%-a

-- 2+ autós egyszerre kiváltásnál ekkora eséllyel jár ekkora kedvezmény a
-- végösszegből (panel batch és self-service tömeges kiállításnál egyaránt,
-- szerver-oldali roll).
UZEMBEHELYEZES_BATCH_CHANCE   = 15
UZEMBEHELYEZES_BATCH_DISCOUNT = 10

-- Identifier(ek) (pl. license:...), akik a panelt használhatják és
-- kiállíthatják az engedélyt. Amíg egyikük sincs online, az NPC saját maga
-- (rendszám alapján) kiállíthatja civil ügyfeleknek. Placeholder —
-- véglegesítendő.
---@type table<number, string>
UZEMBEHELYEZESJOBS = { "506e57d972f2c940e564c033c6277e57d8764aab", "6732f56fbd0e16fc54d6feccedf32edd93694d1b" }

-- Az üzembehelyezésből befolyt összes díj (self-service NPC + panel, minden
-- mód) egy license-hez kötött "cp" (céges pénz) kasszába megy a
-- bc_tax_cp táblában, nem a kiállító job társadalmi számlájára. Placeholder —
-- véglegesítendő a valós license-re.
UZEMBEHELYEZES_CP_LICENSE = "506e57d972f2c940e564c033c6277e57d8764aab"

---@class NpcUzembehelyezesConfig
---@field coords vector4
---@field model string
NPC_UZEMBEHELYEZES = {
    coords     = vector4(-1106.721, -2036.659, 13.347585, 237.486), -- TODO: végleges koordináta beállítása
    model      = "a_f_m_ktown_01",
    blipSprite = 0, -- 0 = nincs blip, a térkép ne jelölje (régen 351)
    blipColour = 2,
    blipScale  = 1.2,
    blipLabel  = "Gabee KFT",
}

