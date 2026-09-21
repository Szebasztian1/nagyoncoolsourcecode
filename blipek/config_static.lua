-- Static config kept OUT of config.lua on purpose: the admin panel save
-- (serializeBlips in server/main.lua) fully rewrites config.lua and would
-- wipe any extra keys. This file is never rewritten at runtime.

-- Groups allowed to use the blip admin panel RPCs
Config.AllowedGroups = {
    owner = true,
}

-- Map filter categories shown to players (order = UI order).
-- 'egyeb' is the fallback bucket for unmapped titles and must always exist.
Config.Categories = {
    { key = 'boltok',     label = 'Boltok & Szolgáltatások' },
    { key = 'allami',     label = 'Állami' },
    { key = 'illegalis',  label = 'Illegális' },
    { key = 'munkak',     label = 'Munkák' },
    { key = 'szorakozas', label = 'Szórakozás & Vendéglátás' },
    { key = 'jarmuvek',   label = 'Jármüvek & Garázsok' },
    { key = 'szervizek',  label = 'Szervizek' },
    { key = 'ingatlanok', label = 'Ingatlanok' },
    { key = 'egyeb',      label = 'Egyéb' },
}

-- Blip title -> category key (exact match against Config.Blips titles;
-- unmapped titles fall into 'egyeb')
Config.BlipCategories = {
    -- Boltok & Szolgáltatások
    ['Antik kereskedö']          = 'boltok',
    ['Szerszám kereskedö']       = 'boltok',
    ['Ékszer kereskedö']         = 'boltok',
    ['Privát Fegyver Bolt']      = 'boltok',
    ['Informatikai áruház']      = 'boltok',
    ['Piac']                     = 'boltok',
    ['Motor Bérlés']             = 'boltok',
    ['Kisállat-kereskedés']      = 'boltok',

    -- Állami
    ['Városháza']                = 'allami',
    ['Rendvédelem']              = 'allami',
    ['St. Fiacre Kórház']        = 'allami',
    ['Kiképzö központ']          = 'allami',

    -- Illegális
    ['DM Rablás']                = 'illegalis',
    ['Olajtársasági rablás']     = 'illegalis',
    ['Vonat Rablás']             = 'illegalis',
    ['Kamu Müszaki']             = 'illegalis',
    ['Hacker képzö']             = 'illegalis',

    -- Munkák
    ['Áruszállító jármübérlés']  = 'munkak',
    ['Étel/ital készítö']        = 'munkak',
    ['Méhészet']                 = 'munkak',

    -- Szórakozás & Vendéglátás
    ['Szórakozóhely']            = 'szorakozas',
    ['Étterem']                  = 'szorakozas',
    ['Esküvö helyszín']          = 'szorakozas',
    ['Black Ring']               = 'szorakozas',
    ['Club']                     = 'szorakozas',
    ['Pearls']                   = 'szorakozas',
    ['Black Coffee']             = 'szorakozas',
    ['Neverland Burger']         = 'szorakozas',

    -- Szervizek
    ['Szerelö Telep [Elérhetö]'] = 'szervizek',
}

-- Más resource-ok által létrehozott blipek. A nevüket a játékból NEM lehet
-- visszaolvasni, ezért SPRITE (és ha kell, SZÍN) alapján azonosítjuk őket.
-- Csak az itt felsorolt sprite-ok kezelhetők; minden más érintetlen marad,
-- így a küldetés- és útvonal-blipek biztonságban vannak.
--
-- Egy sor = egy kapcsolható tétel a játékos Blip menüjében:
--   id       egyedi azonosító (a mentés ehhez kötődik, ne írd át utólag)
--   label    ez látszik a menüben
--   category melyik kategória-gombra hallgat (Config.Categories kulcsai)
--   sprite   a blip ikon azonosítója
--   colours  opcionális; csak ezekre a blip-színekre vonatkozik a sor
--            (egy sprite-on több rendszer is osztozhat, pl. a 225 = autó)
--
-- Felderítés a játékban: /blipsprites kilistázza az összes idegen sprite-ot,
-- a /blipmiez pedig a waypoint alatti blipet azonosítja és be is sorolja
-- (/blipmiez munkak, vagy szín szerint: /blipmiez szin munkak). A futásidejű
-- besorolás a restartig él — a kiírt sort másold be ide, hogy megmaradjon.
--
-- NE sorolj be általános sprite-okat (1 = sima pont, 8 = waypoint, 9 = nagy kör).
Config.ForeignBlips = {
    -- Boltok & Szolgáltatások
    { id = 'bank',            label = 'Bank',                     category = 'boltok',     sprite = 108 },
    { id = 'benzinkut',       label = 'Benzinkút',                category = 'boltok',     sprite = 361 },
    { id = 'publik_bolt',     label = 'Publik Bolt 0-24',         category = 'boltok',     sprite = 52 },
    { id = 'npc_bolt',        label = 'NPC bolt',                 category = 'boltok',     sprite = 110 },
    { id = 'ruhabolt',        label = 'Ruhabolt',                 category = 'boltok',     sprite = 366 },
    { id = 'barber',          label = 'Barber szalon',            category = 'boltok',     sprite = 71 },
    { id = 'tetovalo',        label = 'Tetováló szalon',          category = 'boltok',     sprite = 75 },
    { id = 'plasztika',       label = 'Plasztikai sebészet',      category = 'boltok',     sprite = 102 },
    { id = 'butoraruhaz',     label = 'Kikötöi bútoráruház',      category = 'boltok',     sprite = 266 },
    { id = 'kereskedok',      label = 'Kereskedök',               category = 'boltok',     sprite = 480 },
    { id = 'csonak_kolcsonzo',label = 'Csónak- és repülöbérlés',  category = 'boltok',     sprite = 410 },
    { id = 'sim_bolt',        label = 'SIM kártya bolt',          category = 'boltok',     sprite = 817 },

    -- Állami
    { id = 'korhaz',          label = 'Kórház',                   category = 'allami',     sprite = 61 },
    { id = 'rendorseg_kulso', label = 'Rendvédelem (reptér)',     category = 'allami',     sprite = 60 },
    { id = 'lefoglaltak',     label = 'Lefoglalt jármüvek',       category = 'allami',     sprite = 67 },
    { id = 'borton',          label = 'Börtön',                   category = 'allami',     sprite = 188 },
    { id = 'jobcenter',       label = 'Munkaközvetítö',           category = 'allami',     sprite = 408, colours = { 26 } },

    -- Jármüvek & Garázsok
    { id = 'autokereskedes',  label = 'Autókereskedés',           category = 'jarmuvek',   sprite = 225, colours = { 24 } },
    { id = 'auto_bonto',      label = 'Autó bontó',               category = 'jarmuvek',   sprite = 225, colours = { 2 } },
    { id = 'publikus_garazs', label = 'Publikus garázs',          category = 'jarmuvek',   sprite = 289 },
    { id = 'garazs_egyeb',    label = 'Garázs / eladó üzlet',     category = 'jarmuvek',   sprite = 374 },

    -- Szervizek
    { id = 'tuning',          label = 'Tuning mühely',            category = 'szervizek',  sprite = 72 },
    { id = 'tuning_kuldetes', label = 'Tuning küldetés',          category = 'szervizek',  sprite = 380 },
    { id = 'repteri_szerelo', label = 'Reptéri szerelö',          category = 'szervizek',  sprite = 446 },
    { id = 'moso' ,            label = 'Magasnyomású mosó',        category = 'szervizek',  sprite = 100 },
    { id = 'trailer',         label = 'Trailer leadó',            category = 'szervizek',  sprite = 479 },
    { id = 'telefon_szerelo', label = 'Telefon technikus',        category = 'szervizek',  sprite = 402 },
    { id = 'gabee_kft',       label = 'Gabee KFT',                category = 'szervizek',  sprite = 351 },

    -- Munkák
    { id = 'vadaszat_zona',   label = 'Vadászterület',            category = 'munkak',     sprite = 141 },
    { id = 'banya',           label = 'Bánya',                    category = 'munkak',     sprite = 85 },
    { id = 'erc_leado',       label = 'Érc leadó',                category = 'munkak',     sprite = 605 },
    { id = 'favagas',         label = 'Favágás',                  category = 'munkak',     sprite = 280 },
    { id = 'buvarkodas',      label = 'Búvárkodás',               category = 'munkak',     sprite = 317 },
    { id = 'buvar_zona',      label = 'Búvár zóna',               category = 'munkak',     sprite = 597 },
    { id = 'horgaszat',       label = 'Horgászzóna',              category = 'munkak',     sprite = 68 },
    { id = 'rak_csapda',      label = 'Rák csapda',               category = 'munkak',     sprite = 501 },
    { id = 'tengeri_ceg',     label = 'Tengerkereskedelmi Vállalat', category = 'munkak',  sprite = 356 },
    { id = 'meheszet_kulso',  label = 'Méhészet / Tanya',         category = 'munkak',     sprite = 106 },
    { id = 'kukas',           label = 'Kukás munka',              category = 'munkak',     sprite = 318 },
    { id = 'busz',            label = 'Buszmunka',                category = 'munkak',     sprite = 513 },
    { id = 'kamionos',        label = 'Kamionos / tengeri szállítás', category = 'munkak', sprite = 477 },
    { id = 'craft',           label = 'Craft pont',               category = 'munkak',     sprite = 365 },
    { id = 'crypto',          label = 'Crypto bányászat',         category = 'munkak',     sprite = 521 },
    { id = 'gyarak',          label = 'Gyárak',                   category = 'munkak',     sprite = 476 },
    { id = 'oilrig',          label = 'Oil Rig torony',           category = 'munkak',     sprite = 767 },

    -- Szórakozás & Vendéglátás
    { id = 'kaszino',         label = 'Kaszinó',                  category = 'szorakozas', sprite = 679 },
    { id = 'edzoterem',       label = 'Edzöterem',                category = 'szorakozas', sprite = 311 },
    { id = 'jacht',           label = 'Jacht',                    category = 'szorakozas', sprite = 455 },
    -- 'etterem_kulso' (463, dusa_pet kisállatbolt) kivéve 2026-09-17: a blipjét már a
    -- Config.Blips "Kisállat-kereskedés" sora rajzolja, azt a saját cím-kapcsolója kezeli.
    { id = 'event_jegy',      label = 'Event jegy beváltó',       category = 'szorakozas', sprite = 186 },

    -- Ingatlanok & Cégek
    { id = 'hazak',           label = 'Házak',                    category = 'ingatlanok', sprite = 40 },
    { id = 'cegek',           label = 'Cégek',                    category = 'ingatlanok', sprite = 475 },

    -- Illegális
    { id = 'diller',          label = 'Diller',                   category = 'illegalis',  sprite = 140 },
    { id = 'illegal_piac',    label = 'Illegál piac',             category = 'illegalis',  sprite = 310 },
    { id = 'drog_farm',       label = 'Drog farm',                category = 'illegalis',  sprite = 496 },
    { id = 'penzmoso',        label = 'Pénzmosó',                 category = 'illegalis',  sprite = 408, colours = { 0 } },
    { id = 'rabolhato_auto',  label = 'Rabolható autó',           category = 'illegalis',  sprite = 225, colours = { 5 } },
    { id = 'garazs_rablas',   label = 'Garázs rablás',            category = 'illegalis',  sprite = 357 },
    { id = 'haz_rablas',      label = 'Ház rablás',               category = 'illegalis',  sprite = 418 },
    { id = 'ekszer_rablas',   label = 'Ékszer rablás',            category = 'illegalis',  sprite = 617 },
    { id = 'rablas_celpont',  label = 'Rablási célpont',          category = 'illegalis',  sprite = 304 },
    { id = 'csempeszaru',     label = 'Csempészáru',              category = 'illegalis',  sprite = 478 },

    -- Egyéb
    { id = 'taxi',            label = 'Taxi',                     category = 'egyeb',      sprite = 198 },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- EGYSÉGESÍTETT MUNKA-BLIPEK
--
-- Ezek a blipeket nem mi hozzuk létre, hanem a munka-resource-ok -- viszont
-- utána ideszólnak (lásd az ottani munkablip.lua-t), és innen kapják a KÖZÖS
-- nevet/ikont/színt. A GTA a név + ikon + szín hármas alapján vonja össze a
-- blipeket a térkép jelmagyarázatában, ezért lesz belőlük egyetlen "Munka" sor.
--
-- `unify = false` eseten MINDEN munka-blip megtartja a SAJAT nevet es ikonjat
-- (ugy, ahogy a sajat resource-a letrehozta) -- a Blip menuben viszont attol
-- meg egyenkent kapcsolhato marad. Ez az alapertelmezes.
-- `unify = true` eseten kapjak meg a lenti kozos nevet/ikont/szint, es a GTA
-- egyetlen sorba vonja oket a terkep jelmagyarazataban.
--
-- FIGYELEM: a GTA blip-fontjában nincs "ő" és "ű" -- a name mezőbe ne kerüljön.
-----------------------------------------------------------------------------------------------------------------------------------------
Config.WorkStyle = {
    unify      = false,   -- false: marad mindegyik sajat neve/ikonja
    name       = 'Munka',
    sprite     = 478,
    colour     = 5,
    scale      = 0.85,
    shortRange = true,
    display    = 4,       -- látható állapot display-értéke (4 = térkép + minimap)
    blipCategory = 0,     -- 0 = NE vonja egy térkép-kategóriába öket (a 10 összevonná)
}

-- A menüben megjelenő sorok. A `label` a RÉGI blipnév -- a játékos ez alapján
-- ismeri fel, mit kapcsol. Az `id`-t a munka-resource-ok adják át
-- regisztrációkor (MunkaBlip('...', blip)), tehát ha átírod, ott is át kell.
-- Mind a 'munkak' kategóriába kerül.
Config.WorkBlips = {
    { id = 'vadaszat',         label = 'Vadászat',            resource = 'ars_hunting' },
    { id = 'buszallomas',      label = 'Buszállomás',         resource = 'bc_bus' },
    -- 'antik_kereskedo' (bc_detector) kivéve 2026-09-16: a Mark NPC blipjét már a
    -- Config.Blips "Antik kereskedö" sora rajzolja, azt a saját cím-kapcsolója kezeli.
    { id = 'femdetektorozas',  label = 'Fémdetektorozás',     resource = 'bc_detector' },
    { id = 'futar_munka',      label = 'Futár Munka',         resource = 'bc_express' },
    { id = 'favago_oltozo',    label = 'Hobby favágó öltözö', resource = 'bc_lumberjack' },
    { id = 'buvarfelszereles', label = 'Búvárfelszerelés',    resource = 'ed_scuba' },
    { id = 'banyaszat',        label = 'Bányászat',           resource = 'hobby_banyaszat' },
    { id = 'kikoto',           label = 'Kikötö',              resource = 'lunar_fishing' },
    { id = 'rakasz',           label = 'Rákász',              resource = 'mate-crabjob' },
    { id = 'kukas_munka',      label = 'Kukás Munka',         resource = 'phoenix_trasherjob' },
    -- 'meheszet' (sd-beekeeping) kivéve 2026-09-16: a Méhész NPC blipjét már a
    -- Config.Blips "Méhészet" sora rajzolja, azt a saját cím-kapcsolója kezeli.
    { id = 'kamionos',         label = 'Kamionos (Hobby)',    resource = 'truck_logistics' },
}

-- Idegen blipek, amiket a Config.Blips egy saját, AZONOS kinézetű sora vált ki.
-- A térkép két különböző resource azonos nevű/ikonú/színű/méretű blipjét nem vonja
-- egy sorba, ezért a blipet a blipek rajzolja, az idegent pedig elrejti
-- (display 0, 5 mp-enként újraellenőrizve, a Blip menü nem kapcsolja vissza).
--   sprite, colour  az idegen blip ikonja és színe
--   coords, radius  ennyi méteren belül a ponttól
Config.ReplacedForeignBlips = {
    -- dusa_pet kisállatbolt -> Config.Blips "Kisállat-kereskedés" (2026-09-17). A dusa_pet titkosított,
    -- nincs blip-kapcsolója, és a betöltéskor létrehozott blipjének elveszett a neve a jelmagyarázatból.
    -- Szín nélkül: a saját blipünket az isOwned úgyis kihagyja, a pont 5 m-en belül egyedi.
    { sprite = 463, coords = vector3(-807.0059, -2406.139, 14.641688), radius = 5.0 },
    -- esx_ambulancejob Pillbox kórház -> Config.Blips "St. Fiacre Kórház" (2026-09-14)
    { sprite = 61, colour = 1, coords = vector3(299.762634, -581.195618, 43.248291), radius = 5.0 },
}

-- Sprite-ok, amiket SOHA nem szabad elrejteni, még téves besorolás esetén sem
-- (161 = a játékos saját követett autója, 8 = waypoint)
Config.ProtectedSprites = {
    [8]   = true,
    [161] = true,
}

-- /blipmiez-re hagyva: 43 (repülök: Lefoglaltak/Publikus garázs/kereskedés
-- osztozik rajta -- színenként sorold be: /blipmiez szin <kategoria>),
-- 309/419/436/461/494/525/795 (ezeket a blipek sajat Config.Blips-e adja).
