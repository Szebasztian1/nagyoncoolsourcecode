--[[ ============================================================
     bc_fegyvercraft_wl — konfiguráció

     Egy craftoló NPC. Aki rajta van a lenti identifier-listán, az
     látja az NPC-t és korlátlanul gyárthat: az alapanyag elfogy,
     a kész tétel a táskájába kerül. Akin nincs rajta, annak az NPC
     meg sem jelenik.

     A kínálat fülekre bomlik (Alapanyag / Lőszer / Alkatrész / Fegyverek) —
     lásd Config.Categories, és minden tétel `category` mezőjét.
     ============================================================ ]]

Config = {}

--- Az NPC, akinél a craftolás történik.
--- FIGYELEM: ha a régi bc_fegyvercraft is fut, ide más koordinátát adj meg,
--- különben a két NPC egymásba lógna.
Config.NPC = {
    model = GetHashKey('a_m_y_business_02'),
    coords = vector4(-797.0107, 186.43904, 71.60556, 112.79056),
    label = 'Fegyver Craft',
    scenario = 'WORLD_HUMAN_CLIPBOARD',
}

--- Meddig fogadja el a szerver a gyártást az NPC-től (méter).
Config.MaxDistance = 8.0

--- Egy gombnyomással legfeljebb ennyi darab készíthető, az alapanyag ennyiszer fogy.
--- 1 = nincs mennyiség-léptető, mindig egyesével gyárt.
Config.MaxCraftAmount = 100

--- Külön ox_inventory tároló a jogosultaknak, egy másik ponton.
--- Csak az látja és tudja megnyitni, aki rajta van a lenti listán.
Config.Stash = {
    enabled = true,
    id = 'bc_fegyvercraft_wl',                     -- ox_inventory tároló azonosító
    label = 'Fegyvercraft raktár',
    slots = 1000,
    weight = 5000000,                              -- grammban: 1 000 000 = 1000 kg
    shared = true,                                 -- true: EGY közös tároló mindenkinek
                                                   -- false: minden jogosultnak saját tárolója
    coords = vector3(-809.2609, 190.48513, 72.478569),       -- a pont, ahol megnyitható (nem az NPC helye)
    radius = 1.2,
    targetLabel = 'Raktár megnyitása',
    targetIcon = 'fas fa-box-open',
}

--[[ ------------------------------------------------------------
     KATEGÓRIÁK

     A panel bal oldalán ezek a fülek jelennek meg, ebben a sorrendben.
     Minden Config.Items bejegyzés `category` mezője ezekre az id-kra
     hivatkozik; ha hiányzik, a Config.DefaultCategory alá kerül.
     Az a kategória, amelyben a játékos egyetlen tételt sem gyárthat,
     meg sem jelenik.
     ------------------------------------------------------------ ]]
Config.Categories = {
    { id = 'materials', label = 'Alapanyag' },
    { id = 'ammo',      label = 'Lőszer' },
    { id = 'parts',     label = 'Alkatrész' },
    { id = 'eszkozok',  label = 'Eszköz' },
    { id = 'weapons',   label = 'Fegyverek' },
}

--- Ide kerül minden olyan tétel, amelynél nincs megadva `category`.
Config.DefaultCategory = 'weapons'

--[[ ------------------------------------------------------------
     JOGOSULTSÁGOK

     Ide írod be, ki craftolhat. Kulcs a játékos identifier-e: ezen a
     szerveren a users tábla `identifier` oszlopa (40 karakteres hex),
     de a "license:xxxx" formátum is jó — a script levágja az előtagot.

     Érték:  '*'                        -> mindent gyárthat
             { 'item_a', 'WEAPON_X' }    -> csak a felsoroltakat
                                            (a nevek a Config.Items kulcsai)

     Aki nincs a listán, annak az NPC és a raktár meg sem jelenik.
     Módosítás után: restart bc_fegyvercraft_wl
     ------------------------------------------------------------ ]]
Config.Whitelist = {
    ['468816aa139fb04baf94caf53da6deea30f67aa1'] = '*',
    ['e01016ca7c0ac0f0b4938016deaa1e95bd904b4f'] = '*',
    ['2d0f44a454e0319c37d28a553454c71e6aec8b8c'] = '*',
    ['8ea9057a43e99a48acedfcb190261cddaca4ae43'] = '*',
    -- ['4e8ef06e5e6fd8d352c702d5c21e70ade783ace2'] = { 'pistol_ammo_box', 'WEAPON_PISTOL' },
    -- ['license:812522113112071baa3171dd6832fe218b86b51b'] = '*',
}

Config.Items = {
    --[[ ---------------------------------------------------------------
         ALAPANYAG — hulladékból nyersanyag.

         1:1 a publikus barkácsasztal receptjeivel (jobs_data #3006,
         public_marker "Craft", 1216.97 / -1269.5 / 34.37), hogy a
         whitelistesek ne kényszerüljenek odajárni az alapanyagért.

         A lánc: hulladék -> nyersanyag -> fém hulladék -> elektronika.
         --------------------------------------------------------------- ]]
    ['steel'] = {name = 'Acél', amount = 20, category = 'materials', items = {
        {name = "cartire", label = "Kocsi kerék", amount = 10},
    }},
    ['copper'] = {name = 'Réz', amount = 20, category = 'materials', items = {
        {name = "deadbatteries", label = "Lemerült elemek", amount = 10},
    }},
    ['iron'] = {name = 'Vas', amount = 20, category = 'materials', items = {
        {name = "oldring", label = "Régi gyűrű", amount = 10},
    }},
    ['plastic'] = {name = 'Műanyag', amount = 20, category = 'materials', items = {
        {name = "petpalack", label = "Visszaváltós palack", amount = 10},
    }},
    ['femforgacs'] = {name = 'Fém hulladék', amount = 10, category = 'materials', items = {
        {name = "steel", label = "Acél", amount = 10},
    }},
    ['electronics'] = {name = 'Elektronika', amount = 1, category = 'materials', items = {
        {name = "femforgacs", label = "Fém hulladék", amount = 5},
        {name = "plastic", label = "Műanyag", amount = 20},
        {name = "copper", label = "Réz", amount = 10},
        {name = "iron", label = "Vas", amount = 5},
        {name = "deadbatteries", label = "Lemerült elemek", amount = 20},
        {name = "steel", label = "Acél", amount = 2},
    }},

    --[[ ---------------------------------------------------------------
         LŐSZER — 12 acél + 12 vas + 12 réz / doboz
         --------------------------------------------------------------- ]]
    ['pistol_ammo_box'] = {name = 'Pisztoly Töltény Doboz', amount = 1, category = 'ammo', items = {
        {name = "steel", label = "Acél", amount = 12},
        {name = "iron", label = "Vas", amount = 12},
        {name = "copper", label = "Réz", amount = 12},
    }},
    ['smg_ammo_box'] = {name = 'SMG Lőszer Doboz', amount = 1, category = 'ammo', items = {
        {name = "steel", label = "Acél", amount = 12},
        {name = "iron", label = "Vas", amount = 12},
        {name = "copper", label = "Réz", amount = 12},
    }},
    ['shotgun_ammo_box'] = {name = 'Shotgun Töltény Doboz', amount = 1, category = 'ammo', items = {
        {name = "steel", label = "Acél", amount = 12},
        {name = "iron", label = "Vas", amount = 12},
        {name = "copper", label = "Réz", amount = 12},
    }},
    ['rifle_ammo_box'] = {name = 'Nagykaliber Lőszer Doboz', amount = 1, category = 'ammo', items = {
        {name = "steel", label = "Acél", amount = 12},
        {name = "iron", label = "Vas", amount = 12},
        {name = "copper", label = "Réz", amount = 12},
    }},

    --[[ ---------------------------------------------------------------
         ALKATRÉSZ — 20 acél + 20 vas + 20 réz / darab
         --------------------------------------------------------------- ]]
    -- Pisztoly
    ['pistolcso'] = {name = 'Pisztoly Cső', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['pistolbelso'] = {name = 'Pisztoly Belsőszerkezet', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['pistoltar'] = {name = 'Pisztoly Tár', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    -- AP Pistol
    ['apvaz'] = {name = 'AP Váz', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['apmarkolat'] = {name = 'AP Markolat', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['apravasz'] = {name = 'AP Ravasz', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['aptar'] = {name = 'AP Tár', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    -- Vintage Pistol
    ['vivaz'] = {name = 'Vintage Váz', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['vimarkolat'] = {name = 'Vintage Markolat', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['viravasz'] = {name = 'Vintage Ravasz', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['vitar'] = {name = 'Vintage Tár', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    -- Machine Pistol (TEC9)
    ['tec9cso'] = {name = 'TEC9 Cső', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['tec9belso'] = {name = 'TEC9 Belsőszerkezet', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['tec9tar'] = {name = 'TEC9 Tár', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    -- Micro SMG
    ['uzicso'] = {name = 'Micro SMG Cső', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['uzibelso'] = {name = 'Micro SMG Belsőszerkezet', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['uziravasz'] = {name = 'Micro SMG Ravasz', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['uzitar'] = {name = 'Micro SMG Tár', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    -- Combat PDW
    ['cbcso'] = {name = 'Combat PDW Cső', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['cbmarkolat'] = {name = 'Combat PDW Markolat', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['cbrravasz'] = {name = 'Combat PDW Ravasz', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['cbtarto'] = {name = 'Combat PDW Tártartó', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    -- Pump Shotgun
    ['shotguncso'] = {name = 'UTAS UTS-15 Cső', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['shotgunbelso'] = {name = 'UTAS UTS-15 Belsőszerkezet', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['shotgunravasz'] = {name = 'UTAS UTS-15 Ravasz', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    -- Assault Rifle (AK47)
    ['ak47cso'] = {name = 'AK47 Cső', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['ak47belso'] = {name = 'AK47 Belsőszerkezet', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},
    ['ak47ravasz'] = {name = 'AK47 Ravasz', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 20},
        {name = "iron", label = "Vas", amount = 20},
        {name = "copper", label = "Réz", amount = 20},
    }},

    --[[ ---------------------------------------------------------------
         EGYEDI ALKATRÉSZEK — a lenti három egyedi fegyverhez.
         A receptek a szerveren már meglévő craft-táblákból jönnek:
           67g17* és crackng20*  -> public_marker "Craft" (jobs_data 3355), 100/100/100
           machinepistolred*     -> public_marker "Craft" (jobs_data 3191), 50/50/50
         --------------------------------------------------------------- ]]
    -- G67 G17GRIP
    ['67g17cso'] = {name = '67G17 Cső (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    ['67g17ravasz'] = {name = '67G17 Ravasz (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
        {name = "wood", label = "Fa", amount = 50},
    }},
    ['67g17tar'] = {name = '67G17 Tár (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    -- Machine Pistol Red CHR
    ['machinepistolredcso'] = {name = 'Machine Cső (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    ['machinepistolredravasz'] = {name = 'Machine Ravasz (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    ['machinepistolredtar'] = {name = 'Machine Tár (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    ['machinepistolredvaltamasz'] = {name = 'Machine Válltámasz (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    -- Duranda AP (Döngölő AP) -- a mate-weaponparts szerint ehhez a fegyverhez
    -- a duranda2* harmas tartozik (shared/config.lua WEAPON_DURANDA_AP).
    ['duranda2cso'] = {name = 'Duranda2 Cső (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    ['duranda2tar'] = {name = 'Duranda2 Tár (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    ['duranda2ravasz'] = {name = 'Duranda2 Ravasz (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    -- CrackNG20
    ['crackng20cso'] = {name = 'CrackNG20 Cső (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    ['crackng20egesz'] = {name = 'CrackNG20 Egész (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},
    ['crackng20vaz'] = {name = 'CrackNG20 Váz (Egyedi)', amount = 1, category = 'parts', items = {
        {name = "steel", label = "Acél", amount = 50},
        {name = "iron", label = "Vas", amount = 50},
        {name = "copper", label = "Réz", amount = 50},
    }},

    --[[ ---------------------------------------------------------------
         ESZKÖZ — a barkácsasztal receptje 1:1 (2026-09-16).
         A készítési idő (70 mp) nem jön át: ez a panel azonnal gyárt.
         --------------------------------------------------------------- ]]
    ['xae12'] = {name = 'XAE12 Laptop', amount = 1, category = 'eszkozok', items = {
        {name = "electronics", label = "Elektronika", amount = 2},
        {name = "deadbatteries", label = "Lemerült elemek", amount = 40},
        {name = "steel", label = "Acél", amount = 30},
        {name = "iron", label = "Vas", amount = 30},
        {name = "copper", label = "Réz", amount = 30},
        {name = "femforgacs", label = "Fém hulladék", amount = 20},
    }},

    --[[ ---------------------------------------------------------------
         FEGYVEREK — alap fegyverek 4-4 alkatrészből + 1.500.000 pénz
         --------------------------------------------------------------- ]]
    ['WEAPON_PISTOL'] = {name = 'Pistol', amount = 1, category = 'weapons', items = {
        {name = "pistolcso", label = "Pisztoly Cső", amount = 4},
        {name = "pistolbelso", label = "Pisztoly Belsőszerkezet", amount = 4},
        {name = "pistoltar", label = "Pisztoly Tár", amount = 4},
        {name = "money", label = "Pénz", amount = 1500000},
    }},
    ['WEAPON_APPISTOL'] = {name = 'AP Pistol', amount = 1, category = 'weapons', items = {
        {name = "apvaz", label = "AP Váz", amount = 4},
        {name = "apmarkolat", label = "AP Markolat", amount = 4},
        {name = "apravasz", label = "AP Ravasz", amount = 4},
        {name = "aptar", label = "AP Tár", amount = 4},
        {name = "money", label = "Pénz", amount = 1500000},
    }},
    ['WEAPON_VINTAGEPISTOL'] = {name = 'Vintage Pistol', amount = 1, category = 'weapons', items = {
        {name = "vivaz", label = "Vintage Váz", amount = 4},
        {name = "vimarkolat", label = "Vintage Markolat", amount = 4},
        {name = "viravasz", label = "Vintage Ravasz", amount = 4},
        {name = "vitar", label = "Vintage Tár", amount = 4},
        {name = "money", label = "Pénz", amount = 1500000},
    }},
    ['WEAPON_MACHINEPISTOL'] = {name = 'Machine Pistol', amount = 1, category = 'weapons', items = {
        {name = "tec9cso", label = "TEC9 Cső", amount = 4},
        {name = "tec9belso", label = "TEC9 Belsőszerkezet", amount = 4},
        {name = "tec9tar", label = "TEC9 Tár", amount = 4},
        {name = "money", label = "Pénz", amount = 1500000},
    }},
    ['WEAPON_MICROSMG'] = {name = 'Micro SMG', amount = 1, category = 'weapons', items = {
        {name = "uzicso", label = "Micro SMG Cső", amount = 4},
        {name = "uzibelso", label = "Micro SMG Belsőszerkezet", amount = 4},
        {name = "uziravasz", label = "Micro SMG Ravasz", amount = 4},
        {name = "uzitar", label = "Micro SMG Tár", amount = 4},
        {name = "money", label = "Pénz", amount = 1500000},
    }},
    ['WEAPON_COMBATPDW'] = {name = 'Combat PDW', amount = 1, category = 'weapons', items = {
        {name = "cbcso", label = "Combat PDW Cső", amount = 4},
        {name = "cbmarkolat", label = "Combat PDW Markolat", amount = 4},
        {name = "cbrravasz", label = "Combat PDW Ravasz", amount = 4},
        {name = "cbtarto", label = "Combat PDW Tártartó", amount = 4},
        {name = "money", label = "Pénz", amount = 1500000},
    }},
    ['WEAPON_PUMPSHOTGUN'] = {name = 'Pump Shotgun', amount = 1, category = 'weapons', items = {
        {name = "shotguncso", label = "UTAS UTS-15 Cső", amount = 4},
        {name = "shotgunbelso", label = "UTAS UTS-15 Belsőszerkezet", amount = 4},
        {name = "shotgunravasz", label = "UTAS UTS-15 Ravasz", amount = 4},
        {name = "shotguntar", label = "UTAS UTS-15 Tár", amount = 4},
        {name = "shotgunvaltamasz", label = "UTAS UTS-15 Válltámasz", amount = 4},
        {name = "money", label = "Pénz", amount = 1500000},
    }},
    ['WEAPON_ASSAULTRIFLE'] = {name = 'Assault Rifle', amount = 1, category = 'weapons', items = {
        {name = "ak47cso", label = "AK47 Cső", amount = 4},
        {name = "ak47belso", label = "AK47 Belsőszerkezet", amount = 4},
        {name = "ak47ravasz", label = "AK47 Ravasz", amount = 4},
        {name = "ak47tar", label = "AK47 Tár", amount = 4},
        {name = "ak47valtamasz", label = "AK47 Válltámasz", amount = 4},
        {name = "money", label = "Pénz", amount = 1500000},
    }},

    --[[ ---------------------------------------------------------------
         EGYEDI FEGYVEREK — Jackson Marco (468816aa…67aa1) blueprintjei,
         a bc_fegyvercraft-ból áthozva, változatlan recepttel.
         Mivel a Config.Whitelist-ben mind a négy identifier '*'-ot kapott,
         ezt a hármat mind a négyen gyárthatják.
         --------------------------------------------------------------- ]]
    ['WEAPON_67_G17GRIP'] = {name = 'G67 G17GRIP', amount = 1, category = 'weapons', items = {
        {name = "67g17cso", label = "67G17 cső (Egyedi)", amount = 1},
        {name = "67g17ravasz", label = "67G17 ravasz (Egyedi)", amount = 1},
        {name = "67g17tar", label = "67G17 tár (Egyedi)", amount = 1},
        {name = "steel", label = "Acél", amount = 40},
        {name = "iron", label = "Vas", amount = 40},
        {name = "copper", label = "Réz", amount = 40},
        {name = "money", label = "Pénz", amount = 2000000},
    }},
    ['WEAPON_MACHINE_PISTOL_RED_CHR'] = {name = 'Machine Pistol Red CHR', amount = 1, category = 'weapons', items = {
        {name = "machinepistolredvaltamasz", label = "Machine válltámasz (Egyedi)", amount = 1},
        {name = "machinepistolredtar", label = "Machine tár (Egyedi)", amount = 1},
        {name = "machinepistolredravasz", label = "Machine ravasz (Egyedi)", amount = 1},
        {name = "machinepistolredcso", label = "Machine cső (Egyedi)", amount = 1},
        {name = "steel", label = "Acél", amount = 40},
        {name = "iron", label = "Vas", amount = 40},
        {name = "copper", label = "Réz", amount = 40},
        {name = "money", label = "Pénz", amount = 2000000},
    }},
    ['WEAPON_DURANDA_AP'] = {name = 'Duranda AP', amount = 1, category = 'weapons', items = {
        {name = "duranda2cso", label = "Duranda2 cső (Egyedi)", amount = 1},
        {name = "duranda2tar", label = "Duranda2 tár (Egyedi)", amount = 1},
        {name = "duranda2ravasz", label = "Duranda2 ravasz (Egyedi)", amount = 1},
        {name = "steel", label = "Acél", amount = 40},
        {name = "iron", label = "Vas", amount = 40},
        {name = "copper", label = "Réz", amount = 40},
        {name = "money", label = "Pénz", amount = 2000000},
    }},
    ['WEAPON_CRACKN_G20'] = {name = 'CrackNG20', amount = 1, category = 'weapons', items = {
        {name = "crackng20cso", label = "CrackNG20 Cső (Egyedi)", amount = 1},
        {name = "crackng20egesz", label = "CrackNG20 Egész (Egyedi)", amount = 1},
        {name = "crackng20vaz", label = "CrackNG20 Váz (Egyedi)", amount = 1},
        {name = "steel", label = "Acél", amount = 40},
        {name = "iron", label = "Vas", amount = 40},
        {name = "copper", label = "Réz", amount = 40},
        {name = "money", label = "Pénz", amount = 2000000},
    }},
}
