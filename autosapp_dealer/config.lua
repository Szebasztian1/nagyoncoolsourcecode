Config = {}

-- ============================================================
--  HASZNÁLTOK — autóhirdető RoadPhone app (ESX)
--  Minden ár / korlát / szöveg innen állítható.
-- ============================================================
Config.Debug = false               -- extra konzol log

-- Megnyitás: CSAK a RoadPhone appból (a teljes képernyős parancs kikapcsolva,
-- hogy belépéskor/parancsra ne üljön rá a játékra).
Config.Command       = false        -- /hasznaltok (false = kikapcsol)
Config.UseKeyMapping = false
Config.OpenKey       = 'F7'
Config.OpenItem      = nil

-- ============================================================
--  PÉNZ  (minden díj bankról megy; az AUTÓ ÁRÁT az eladó adja meg)
-- ============================================================
Config.Account = 'bank'            -- 'bank' vagy 'money'

-- (17) Az app HASZNÁLATA heti díjas — ennyiért oldható fel 1 hétre.
Config.AccessWeeklyPrice = 1000000        -- 1.000.000 / hét

-- (9) Kiemelt hirdetés ára: 1 hét = 15.000.000
Config.PromoWeeklyPrice = 15000000        -- 15 millió / hét
Config.MaxPromoWeeks    = 8
Config.WeekMs           = 7 * 24 * 60 * 60 * 1000

-- ============================================================
--  KORLÁTOK / VALIDÁCIÓ (szerveroldalon kényszerítve)
-- ============================================================
Config.MaxImages        = 1         -- 1 autó = 1 kép; ha nem tetszik, törölhető és újra fotózható
Config.MaxDescription   = 600
Config.MaxReviewLength  = 300       -- eladói vélemény max hossz
Config.MaxActiveCars    = 15
Config.PriceMin         = 1
Config.PriceMax         = 7000000000
Config.ActionCooldownMs = 1200

-- (12) Hirdetés-típus kategóriák (az ELADÓ választja). value -> címke
Config.Categories = {
    { value = 'egyedi',        label = 'Egyedi' },
    { value = 'limitalt',      label = 'Limitált' },
    { value = 'pps',           label = 'PP-s' },
    { value = 'keres_sima',    label = 'Autókereskedés Sima' },
    { value = 'keres_szerelo', label = 'Autókereskedés Szerelő' },
}

-- ============================================================
--  (11) ADMIN — ezek a csoportok BÁRKI hirdetését törölhetik.
--  Nem kell semmit a server.cfg-be írni: ESX getGroup() alapján megy.
--  (Tartalék: 'autosapp.admin' ACE jog is elfogad.)
-- ============================================================
Config.AdminGroups = {
    ['superadmin']     = true,
    ['admincontroller']= true,
    ['developer']      = true,
    ['coowner']        = true,
    ['owner']          = true,
}
Config.AdminAce = 'autosapp.admin'  -- opcionális tartalék ACE jog

-- ============================================================
--  PROFILKÉP — karakter fej-portré (mint az okokChat-ben)
--  Az image-to-txn resource GetPlayerMugshot(source) exportja adja a képet.
--  Ha nincs telepítve, a profil a 👤 ikont mutatja.
-- ============================================================
Config.Mugshot = {
    Enabled  = true,
    Resource = 'image-to-txn',
    Export   = 'GetPlayerMugshot',
}

-- ============================================================
--  ESX adatbázis-mezők (állítsd a szervered sémájához, ha eltér)
-- ============================================================
-- owned_vehicles: a játékos autói, a tuning a `vehicle` JSON-ban (ESX props)
Config.OwnedVehicles = {
    table     = 'owned_vehicles',
    ownerCol  = 'owner',     -- ESX identifier oszlop
    plateCol  = 'plate',
    propsCol  = 'vehicle',   -- JSON (ESX.Game.GetVehicleProperties)
    -- (NEW) Extra sebesség oszlop az owned_vehicles-ben. Érték: 0 = nincs, 5 = +5, 10 = +10.
    -- Ha a szervereden más a neve, írd át; ha nincs ilyen oszlop, állítsd false-ra (akkor mindig 'nincs').
    speedCol  = 'extraspeed',
}

-- (13) CHIP tuning tábla — rendszám alapján. JSON: {"turbo":{...},"fuel":{...}}
-- (ellenőrizve a szerver dumpból: oszlop neve `datas`)
Config.ChipTable = {
    table    = 'asdasd_chiptuning',
    plateCol = 'plate',
    dataCol  = 'datas',      -- a JSON-t tároló oszlop neve
}

-- (14) Anti-lag tábla — rendszám alapján. JSON: {"Antilag":5.0,"Fuel":5.0,"Muffler":1,"TwoStep":5.0}
Config.AntilagTable = {
    table    = 'unifried_tunning',
    plateCol = 'plate',
    dataCol  = 'datas',
}

-- ============================================================
--  (16) KATEGÓRIA-TIPP a handling fMass alapján (csak TIPP!)
--  A kliens a kiválasztott autó tömegét olvassa (ha beleülsz),
--  a szerver ez alapján sorol be. A vásárlók is látják a tippet.
-- ============================================================
Config.MassCategories = {
    -- { min, max(zárt felső), kulcs, címke }
    { 2000, 2599, 'autokeres',  'Autokeres' },
    { 2600, 2999, 'privat',     'Privát Autokeres' },
    { 3000, 3889, 'limitalt',   'Limitált' },
    { 3890, 5000, 'egyedi',     'Egyedi' },
}

-- ============================================================
--  (18) TAGSÁGOK — 5 szint, nehéz lépni. A pontot a használat hozza.
--  A felső szintek KAPUZÁRVA: nem elég a pont, hirdetni/feladatozni is kell.
-- ============================================================
Config.Points = {
    AccessWeek = 40,    -- heti hozzáférés vásárlása
    AdPosted   = 35,    -- új hirdetés
    Sale       = 70,    -- eladás (eladottnak jelölés, autónként egyszer)
    PromoWeek  = 50,    -- kiemelés / hét
    Task       = 120,   -- egy teljesített feladat
}

-- Sorrendben (alulról fölfelé). minTasks = ennyi feladat KELL a szinthez.
Config.Tiers = {
    { key = 'ujonc',   name = 'Újonc',            color = '#9aa6b2', minPoints = 0,    minAds = 0,  minTasks = 0 },
    { key = 'bronz',   name = 'Bronz Kereskedő',  color = '#cd7f32', minPoints = 150,  minAds = 0,  minTasks = 0 },
    { key = 'ezust',   name = 'Ezüst Kereskedő',  color = '#c0c7d0', minPoints = 500,  minAds = 0,  minTasks = 0 },
    -- (18) utolsó előtti: hirdetés is KELL, nem csak pont
    { key = 'arany',   name = 'Arany Kereskedő',  color = '#ffce4d', minPoints = 1500, minAds = 12, minTasks = 0 },
    -- (18) utolsó: feladatok is KELLENEK
    { key = 'gyemant', name = 'Gyémánt Legenda',  color = '#5fd0ff', minPoints = 4000, minAds = 30, minTasks = 5 },
}

-- (18) Kis feladatok (a felső tagsághoz is kellenek). A kulcsokat a szerver tölti.
Config.Tasks = {
    { key = 'first_post', label = 'Add fel az első autódat',            hint = '1 hirdetés feladása' },
    { key = 'post_10',    label = 'Hirdess összesen 10 autót',          hint = '10 hirdetés összesen' },
    { key = 'first_sale', label = 'Adj el egy autót',                   hint = 'jelölj egy hirdetést eladottnak' },
    { key = 'promote',    label = 'Emelj ki egy hirdetést',             hint = 'indíts 1 kiemelést' },
    { key = 'views_250',  label = 'Érj el összesen 250 megtekintést',   hint = 'a hirdetéseiden összesen' },
}

-- ============================================================
--  (6) FOTÓ — csak in-game screenshot (kép URL KIVÉVE).
-- ============================================================
Config.Fivemanage = {
    -- Ugyanaz, mint a roadphone/API.lua -> Cfg.uploadMethodKey
    ApiKey = 'FHNQPfj149j5wkOxJkdb32D1zi7f6J3u',
    Url    = 'https://api.fivemanage.com/api/image',
}
Config.PhotoHideDelayMs = 350

-- ============================================================
--  ROADPHONE INTEGRÁCIÓ (védett, pcall-os hívások)
-- ============================================================
-- Értesítések: ONLINE eladónál kis, app-stílusú RoadPhone értesítés (nem a fél
-- telefont elfoglaló SMS-banner). A véleménynél offline esetben SMS a tartalék,
-- hogy ne maradjon le róla; a like/kedvenc offline-nál nem küld semmit (apróság).
Config.Phone = {
    Resource     = 'roadphone',
    SystemNumber = 'Használtautó',
    SmsOnLike     = true,          -- értesítés, ha valaki lájkol (online: kis értesítés)
    SmsOnFavorite = true,          -- értesítés, ha valaki kedvencnek jelöl
    SmsOnReview   = true,          -- értesítés, ha értékelést kap (offline: SMS)
    NotifyOnPromote = true,
    -- Értesítés stílusa:
    --   'phone'  = RoadPhone telefonos banner ikonnal (a telefon képernyője felvillan)
    --   'simple' = sima ESX értesítés (kicsi, a telefon NEM jelenik meg, nincs ikon)
    NotifyStyle = 'phone',
    NotifyIcon  = '/public/img/Apps/light_mode/hasznaltauto.svg',  -- a banner ikonja (a roadphone public mappájához képest)
    -- Kapcsolatfelvételkor automatikusan tárcsázza az eladó számát (RoadPhone startCall)
    AutoCallOnContact = true,
}
