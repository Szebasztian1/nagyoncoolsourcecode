config = config or {}

config.locale = 'en'

-- Rendvédelmi frakciók (a Panel2 rendvédelmi küldetésekhez)
local lawEnforcementJobs = { "police", "fbi", "fbiuj", "uss", "irs", "atf", "detective", "guardarmy", "navi", "servicess", "usms" }
--[[
    Szerelő / tuning-shop frakciók (saját, szerelős küldetésekkel).
    Ezek NEM az illegál küldiket kapják, hanem a szerelő-specifikusakat
    (autó javítás / tuning / festés / lefoglalás). A haladást a vms_tuning
    (SV.updateVehicle hook, config.server.lua) és a lefoglalás jelenti.
]]
local mechanicJobs = {
    -- Minden vms_tuning tuning-boltos job (a gangek is, saját tuning-ponttal),
    -- plusz a mechanic-nevű frakciók. Ezek a szerelős küldiket kapják, NEM az illegált.
    "mechanic",
    "acabmechanic",
    "umechanic",
    "metamechanic",
    "speedmechanicoff",
    "wsqcustoms",
    "topgear",
    "moscar",
    "sipsics",
    "bennysservice",
    "themetalshop",
    "blackmamba",
    "ms13",
    "alkaida",
    "exotic",
    "gabee",
    "kingston",
    "sonsofanarchy",
    "ujfrakciodawe3",
}
-- Illegal missions. Emergency services (EMS / fire, on and off duty) are excluded on purpose.
local nonLawEnforcementJobs = {
    "acabmechanic",
    "akuma95fraki",
    "alfafegyverbolt",
    "alkaidaoff",
    "asian",
    "bahamas",
    "balen",
    "bloods",
    "boonkgang",
    "bratva",
    "camorra1",
    "conte",
    "corleone",
    "crips",
    "cronos",
    "dd",
    "depapel",
    "doa",
    "egyhaz",
    "farm",
    "gentle",
    "gomorra",
    "groove",
    "guardarmyoff",
    "gym",
    "hpizza",
    "irspub",
    "khc",
    "killenc",
    "kingsman",
    "lee",
    "leoguns",
    "lifthouse",
    "lkings",
    "loscuba",
    "lostmc",
    "mob",
    "ms",
    "neverland",
    "ngz",
    "offdutyuwu",
    "offluxduty",
    "orosz",
    "pbgang",
    "peakybb",
    "pearls",
    "pearlsillegal",
    "piekarz",
    "pollos",
    "reapers",
    "remmo",
    "russian",
    "saliers",
    "shadow",
    "snssoff",
    "soa",
    "ssouls",
    "szeged",
    "taxi",
    "test",
    "testjob",
    "thelost",
    "tongva",
    "ugyved",
    "ujfrakcio",
    "unicorn",
    "unicornoff",
    "ussoff",
    "uwu",
    "vagoos",
}
--[[
    Do you want to enable automatic harvest and process marker farming?
    false will force the player to press E each time
    true will allow the player to NOT press E each time
]]
config.allowAfkFarming = true

--[[
    Főnöki Panel 2 beállítások
    Itt a boss rangok PP-ért (bc_ppshop) tudnak CP-ket (markereket) áthelyezni,
    venni, rang labelt átírni, és küldetésekkel CP-ket feloldani.
]]
config.bossPanel2 = {
    movePrice   = 500,   -- PP egy CP áthelyezéséért
    renamePrice = 500,   -- PP egy rang label átírásáért
    buyPrice    = 2000,  -- PP egy új CP megvásárlásáért
    renameFactionPrice = 10000, -- PP a frakció label átírásáért (CSAK a label, a jobName nem változik)
    buyRankPrice    = 500,  -- PP egy új rang vásárlásáért
    deleteRankPrice = 250,  -- PP egy rang törléséért (boss/coboss nem törölhető)
    newRankLabel    = "Új rang", -- az újonnan vett rang alap labelje (a boss átírhatja)

    placeTimeLimit = 60, -- másodperc: ennyi ideje van lehelyezni a CP-t (utána eltűnik a lehelyezés)

    placeMaxDistance = 60.0, -- méter: ennél messzebb a játékostól nem rakható le CP (anti-abuse)

    -- Milyen típusú CP-ket lehet venni a buyPrice-ért (a játékos választ a listából)
    buyableTypes = {
        { type = "safe",           label = "Széf CP" },
        { type = "stash",          label = "Tároló CP" },
        { type = "wardrobe",       label = "Ruhatár CP" },
        { type = "garage_buyable", label = "Garázs CP" },
    },

    -- Maximális rang label hossz (a job_grades.label oszlop 50 karakter)
    maxRankLabelLength = 50,

    --[[
        Marker kinézet presetek - lehelyezés közben a nyilakkal (bal/jobb) válthatók.
        markerType = GTA marker típus (1 = henger, 2 = nyíl, 25 = kör, stb.)
        color = {r,g,b,a}
        Az elsö preset az alapértelmezett.
    ]]
    appearancePresets = {
        { label = "Zöld henger",  markerType = 1,  color = { r = 0,   g = 200, b = 0,   a = 120 } },
        { label = "Kék henger",   markerType = 1,  color = { r = 0,   g = 120, b = 255, a = 120 } },
        { label = "Piros henger", markerType = 1,  color = { r = 255, g = 0,   b = 0,   a = 120 } },
        { label = "Sárga nyíl",   markerType = 2,  color = { r = 255, g = 200, b = 0,   a = 160 } },
        { label = "Fehér kör",    markerType = 25, color = { r = 255, g = 255, b = 255, a = 120 } },
        { label = "Lila henger",  markerType = 1,  color = { r = 180, g = 0,   b = 220, a = 120 } },
    },

    --[[
        Küldetések.
        type:
          "members"  -> required = szükséges tagszám
          "activity" -> requiredMembers tag, akik az adott napon requiredHours órát aktívak voltak
          "tasks"    -> required = szükséges feladatszám; a haladást MÁS resource-ok jelentik:
                          exports.esx_job_creator:AddMissionProgress(jobName, missionId, mennyiség)
                          exports.esx_job_creator:AddMissionProgressForPlayer(playerId, missionId, mennyiség)
                          TriggerEvent('esx_job_creator:addMissionProgress', jobName, missionId, mennyiség)
                        (csak szerver oldalról hívható, a haladás DB-be mentödik)

        Minden küldetésnél megadható (opcionális):
          jobs      = { "police", ... } -> csak ezeknek a frakcióknak jelenik meg (nil = mindenkinek)
          resetDays = 7                 -> ennyi naponta nullázódik a haladás és újra begyüjthetö
                                           (nil = soha nem indul újra, egyszeri küldetés)

        reward mezök (kombinálhatók):
          type + label     -> a boss által lehelyezett CP (eddigi müködés)
          moneyPerMember   -> pénz a frakció kasszájába (society), egy összegben:
                              kifizetés = moneyPerMember * frakció taglétszáma (DB, offline tagokkal együtt)

        A csak CP-jutalmas, resetDays nélküli küldetések a régi módon müködnek:
        ha a jutalom CP 0 tagnál törlődik, újra megszerezhetök.
    ]]
    missions = {
        {
            id = "members10",
            label = "10 tag elérése",
            type = "members",
            required = 10,
            reward = { type = "safe", label = "Széf CP (küldetés)" },
        },
        {
            id = "members20",
            label = "20 tag elérése",
            type = "members",
            required = 20,
            reward = { type = "stash", label = "Tároló CP (küldetés)" },
        },
        {
            id = "active5",
            label = "5 tag napi 10 óra aktivitás",
            type = "activity",
            requiredMembers = 5,
            requiredHours = 10,
            reward = { type = "wardrobe", label = "Ruhatár CP (küldetés)" },
        },
        --[[
            Rendvédelmi küldetések (hetente újraindulnak, pénz a frakció kasszájába).
            A moneyPerMember összegek szabadon állíthatók.
        ]]
        {
            id = "le_handcuff20",
            label = "Bilincseljetek meg 20 embert",
            type = "tasks",
            required = 20,
            jobs = lawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            
            id = "le_jail20",
            label = "Rakjatok 20 embert börtönbe",
            type = "tasks",
            required = 20,
            jobs = lawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "le_platecheck10",
            label = "Kérjétek le 10 autó rendszámát",
            type = "tasks",
            required = 10,
            jobs = lawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "le_impound20",
            label = "Foglaljatok le 20 autót",
            type = "tasks",
            required = 20,
            jobs = lawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },

        {
            id = "boltrablas",
            label = "Raboljatok ki 10 boltot",
            type = "tasks",
            required = 10,
            jobs = nonLawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "dmkill",
            label = "Öljetek meg 25 embert DM zonákban",
            type = "tasks",
            required = 25,
            jobs = nonLawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "ekszerrablas",
            label = "Raboljatok ki 2 ékszerboltot",
            type = "tasks",
            required = 2,
            jobs = nonLawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "nemzetirablas",
            label = "Raboljátok ki a nemzetit",
            type = "tasks",
            required = 1,
            jobs = nonLawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "bankrablas",
            label = "Raboljatok ki 5 bankot",
            type = "tasks",
            required = 5,
            jobs = nonLawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "atmrablas",
            label = "Raboljatok ki 10 ATM-et",
            type = "tasks",
            required = 10,
            jobs = nonLawEnforcementJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },

        --[[
            Szerelő küldetések (hetente újraindulnak, pénz a frakció kasszájába).
            A haladást a vms_tuning jelenti (SV.updateVehicle -> AddMissionProgressForPlayer),
            a lefoglalást a jobcreator (server/actions.lua, impoundcar_police).
            Ezek a mission id-k fixek, a hookok ezekre hivatkoznak.
        ]]
        {
            id = "mech_repair30",
            label = "Szereljetek meg 30 autót",
            type = "tasks",
            required = 30,
            jobs = mechanicJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "mech_tune40",
            label = "Tuningoljatok fel 40 autót",
            type = "tasks",
            required = 40,
            jobs = mechanicJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "mech_paint10",
            label = "Fessetek le 10 autót",
            type = "tasks",
            required = 10,
            jobs = mechanicJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "mech_impound30",
            label = "Foglaljatok le 30 autót",
            type = "tasks",
            required = 30,
            jobs = mechanicJobs,
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },

        {
            id = "revive",
            label = "Élesszetek fel 25 embert",
            type = "tasks",
            required = 25,
            jobs = {"ambulance"},
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
        {
            id = "heal",
            label = "Lássatok el (gyógyítsatok meg) 25 embert",
            type = "tasks",
            required = 25,
            jobs = {"ambulance"},
            resetDays = 7,
            reward = { moneyPerMember = 15000000 },
        },
    },
}

--[[
    Napi csapat-jutalmak.
    Amikor a frakció egy adott napon ELÖSZÖR eléri az egyidejűleg online tagszámot,
    minden ÉPP online tag megkapja a jutalmat. Naponta egyszer (a dátum váltásakor
    automatikusan újra elérhető). A létszámot ~percenként ellenőrzi a rendszer.

    reward mezök (bármelyik kombinálható):
      bankMoney  -> ennyi pénz a bank számlára
      gamepassXp -> esx_gamepass:BCaddXp (ha az esx_gamepass fut)
      vipXp      -> bc_vip:addXp
]]
config.dailyTeamRewards = {
    {
        id = "concurrent10",
        label = "10 egyidejű tag",
        concurrent = 10,
        -- "3 misi" = bank pénz. Állítsd a kívánt összegre (alap: 3 000 000).
        reward = { bankMoney = 3000000 },
    },
    {
        id = "concurrent5",
        label = "5 egyidejű tag",
        concurrent = 5,
        reward = { gamepassXp = 10000, vipXp = 2500 },
    },
}


