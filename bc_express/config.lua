Config = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- BC EXPRESS – Futár munka
-- Stack: ESX + ox_lib (callback/progress) + ox_target + bc_ppshop (telep-feloldás PP-díja) + bc_jobboost (boost) + roadphone (app+SMS)
-- Minden játékos felé menő ÉRTESÍTÉS a telefonon (roadphone) megy. Telefon nélkül a munka nem vehető fel.
-----------------------------------------------------------------------------------------------------------------------------------------

Config.Debug = false

-- Telefon item(ek) – ezek valamelyike kell a munka felvételéhez (roadphone Config.Items)
Config.PhoneItems = { 'ujphone', 'phone' }

-- Fizetési számla a kör végi kifizetéshez: 'bank' | 'money'
Config.PayAccount = 'bank'

-- Jármű (lehívó/spawn név)
Config.VehicleModel = 'bcexpres'

-- A doboz prop, amit a kocsi hátuljából vesznek ki és az automatába raknak (sima, zárt karton)
Config.BoxProp = 'prop_cs_cardbox_01'

-- Az automaták (lerakó pontok) PROP MODELLJE – erre kerül az ox_target "Doboz behelyezése"
Config.AutomataModel = 'bc_express'

-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPO
-----------------------------------------------------------------------------------------------------------------------------------------

-- A 4 indító marker (E lenyomásra indul a munka + kapják a kocsit). typ = 39
Config.StartMarkers = {
    vector4(59.770656, 125.65084, 79.249603, 157.33393),
    vector4(63.872200, 124.03718, 79.169067, 157.00810),
    vector4(70.473823, 121.39526, 79.171691, 160.45671),
    vector4(74.462371, 119.83629, 79.186660, 157.94265),
}

-- Statisztikai/menedzsment NPC helye (x,y,z,heading) – ox_target → kinyíló NUI panel
Config.StatsPanel = vector4(69.034042, 127.42824, 78.209419, 162.06971)

-- (Nem használt: a kocsi annál a StartMarkernél spawnol, amelyiknél felveszed a munkát.)
Config.VehicleSpawn = vector4(74.462371, 119.83629, 79.186660, 157.94265)

-- Ár-számítási origó (a táv-alapú díjhoz). A LEADÁS a felvétel markeréhez kötött, nem ehhez.
Config.ReturnPoint = vector4(74.462371, 119.83629, 79.186660, 157.94265)
-- A kocsi-leadó zóna sugara: ezen belül jelenik meg az [E] felirat, és a szerver is ehhez (+3.0) mér
Config.ReturnRadius = 8.0

-----------------------------------------------------------------------------------------------------------------------------------------
-- CÍMEK – ezek közül kapnak körönként véletlenszerűen
-----------------------------------------------------------------------------------------------------------------------------------------

Config.Addresses = {
    vector3(451.103119, -794.45510, 26.3574028),
    vector3(-8.5482235, -1079.68262, 25.6737633),
    vector3(-302.496338, -927.406067, 30.0777817),
    vector3(-402.149170, -128.186966, 37.5337524),
    vector3(-2191.99048, 4248.24951, 46.9742900),
    vector3(-735.170000, 5540.66064, 32.5232000),
    vector3(40.4869300, 6664.141000, 30.7112700),
    vector3(1695.49951, 6430.15771, 31.6375800),
    vector3(2306.91260, 4867.725000, 40.8169200),
    vector3(1725.62427, 4723.74170, 41.1252556),
    vector3(1525.06616, 3774.29028, 33.5149269),
    vector3(1962.11800, 3830.30469, 31.1818218),
    vector3(2571.96362, 473.652900, 107.679565),
    vector3(1210.89551, -3196.69727, 5.02598200),
}

-- A cím leadásához ennyire kell megközelíteni az automatát (szerveroldali ellenőrzés is)
Config.DeliverRadius = 8.0

-----------------------------------------------------------------------------------------------------------------------------------------
-- SZINTRENDSZER (mint a truck_logistics) – minél nagyobb a szint, annál több cím és pénz, de időbe telik.
-- ExpPerLevel[L] = ennyi TOVÁBBI EXP kell az L. szinthez (L-1-ről L-re). Az utolsó a max szint.
-----------------------------------------------------------------------------------------------------------------------------------------

Config.ExpPerLevel = {
    5000, 8000, 12000, 17000, 23000, 30000, 38000, 47000, 57000, 68000,
    80000, 95000, 115000, 140000, 170000,   -- 15. szint = max
}

-- Tier-ek: a SZINTHEZ kötött kedvezmények. A jelenlegi tier = a legmagasabb, aminek minLevel <= szint.
--   addresses    = ennyi címet kapsz egy körben (max #Config.Addresses)
--   payMult      = pénzszorzó a táv-alapú díjra
--   fragileChance = esély (%), hogy a körben legyen egy törékeny (értékes, jól fizető) csomag
Config.Tiers = {
    { minLevel = 0,  label = 'Gyakornok',  addresses = 3,  payMult = 1.00, fragileChance = 0  },
    { minLevel = 3,  label = 'Futár',      addresses = 5,  payMult = 1.10, fragileChance = 15 },
    { minLevel = 6,  label = 'Tapasztalt', addresses = 7,  payMult = 1.25, fragileChance = 25 },
    { minLevel = 9,  label = 'Profi',      addresses = 9,  payMult = 1.45, fragileChance = 35 },
    { minLevel = 12, label = 'Mester',     addresses = 11, payMult = 1.70, fragileChance = 45 },
    { minLevel = 15, label = 'Elit',       addresses = 14, payMult = 2.00, fragileChance = 60 },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- FIZETÉS – távolság-alapú (mint a truck_logistics, kicsivel többre) × tier.payMult × boost.
-- reward(cím) = (depo→cím km) * véletlen ár/km * payMult. Kör végén, kocsi leadásakor egyben fizet.
-----------------------------------------------------------------------------------------------------------------------------------------

Config.PricePerKmMin = 13000
Config.PricePerKmMax = 14000
Config.MinRewardPerAddress = 2500

-- EXP minden leadott cím után (belső szintrendszer, bc_express_stats.xp)
Config.ExpPerDelivery = 1000

-- VIP XP minden leadott cím után (bc_vip:addXp szerver-event) – pénzarányos, mint a truck_logistics.
-- A cím reward-ja ÷ ezzel az osztóval = kapott VIP XP. 0 = kikapcsolva.
Config.VipXpDivisor = 50

-- Battlepass XP minden leadott cím után (esx_gamepass:BCaddXp szerver-event) – pénzarányos.
-- A cím reward-ja ÷ ezzel az osztóval = kapott battlepass XP (a gamepass maga notyzik). 0 = kikapcsolva.
Config.BattlepassXpDivisor = 100

-----------------------------------------------------------------------------------------------------------------------------------------
-- TÖRÉKENY (értékes) CSOMAG + SEBESSÉG
-- Ha a körben van törékeny csomag, óvatosan kell vezetni. Túl gyorsan → a diszpécser SMS-t küld és a
-- csomag károsodik (levonás a fizetségből). Leadáskor SMS, hogy mehet gyorsabban.
-----------------------------------------------------------------------------------------------------------------------------------------

Config.FragileBonusMult     = 1.6     -- a törékeny csomag ennyiszer annyit fizet
Config.FragileSpeedLimit    = 22.0    -- m/s (~80 km/h) felett károsodik
Config.FragileDamagePerHit  = 2000    -- levonás egy túlsebesség-jelzésenként ($)
Config.FragileStressInterval = 2500   -- ms – ilyen gyakran jelez a kliens túlsebességet (kevés net event)
Config.FragileWarnCooldown  = 12      -- s – ennyi időnként jön a "lassíts" SMS

-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMER – ha kiszáll a kocsiból, ennyi ideje van visszaülni, különben megszakad a munka
-----------------------------------------------------------------------------------------------------------------------------------------

Config.ReturnTime  = 180   -- másodperc (3 perc) – ennyi a visszaszámláló
Config.ReturnGrace = 30    -- csak ennyi mp folyamatos kiszállás UTÁN indul el a visszaszámláló

-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKER (saját rendszer: client/markers.lua, typ = 39). EGY jelölés elve: a célt CSAK waypoint jelöli (nincs külön blip+útvonal).
-----------------------------------------------------------------------------------------------------------------------------------------

Config.Marker = {
    typ            = 39,
    scale          = vector3(0.7, 0.7, 0.6),
    streamDistance = 15.0,
    bob            = 0.18,   -- (nem használt: a lebegtetés natív marker-flag lett)
    startColor     = { 255, 165, 0, 160 },   -- depo indító marker
    returnIdle     = { 200, 200, 200, 120 }, -- leadó marker, amíg NEM ülnek a kocsiban
    returnActive   = { 60, 200, 90, 180 },   -- leadó marker, amíg a kocsiban ülnek
    carColor       = { 80, 140, 255, 170 },  -- kiszállás után a kocsit jelölő marker
}

-- A felirat, ami a depo markeren megjelenik (DrawText3D, nem ox_lib)
Config.StartPrompt = '~y~[E]~w~ Munka felvétele'

-- A felirat a kocsi-leadó ponton (a zóna sugara = Config.ReturnRadius)
Config.ReturnPrompt = '~g~[E]~w~ Kocsi leadása'

-----------------------------------------------------------------------------------------------------------------------------------------
-- MUNKARUHA – a kocsi felvételekor kerül a játékosra, a munka végén (leadás / időtúllépés) az eredeti ruha áll vissza.
-- CSAK az itt felsorolt komponensek cserélődnek, minden más érintetlen marad. A 0-s darabok (maszk,
-- lánc, táska, páncél, matrica) szándékosan ÜRESRE váltanak munka alatt – a végén ezek is visszaállnak.
-- component: GTA komponens-ID → 1 maszk, 3 kezek, 4 nadrág, 5 táska/ejtőernyő, 6 cipő, 7 sál/láncok,
-- 8 póló, 9 testpáncél, 10 matricák, 11 kabát/felső.
-----------------------------------------------------------------------------------------------------------------------------------------

Config.Uniform = {
    enabled = true,
    male = {
        { component = 1,  drawable = 0,   texture = 0 },  -- maszk (üres)
        { component = 3,  drawable = 19,  texture = 0 },  -- kezek
        { component = 4,  drawable = 457, texture = 0 },  -- nadrág
        { component = 5,  drawable = 0,   texture = 0 },  -- táska és ejtőernyő (üres)
        { component = 6,  drawable = 25,  texture = 0 },  -- cipő
        { component = 7,  drawable = 0,   texture = 0 },  -- sál és láncok (üres)
        { component = 8,  drawable = 15,  texture = 0 },  -- póló
        { component = 9,  drawable = 0,   texture = 0 },  -- testpáncél (üres)
        { component = 10, drawable = 0,   texture = 0 },  -- matricák (üres)
        { component = 11, drawable = 923, texture = 0 },  -- kabát
    },
    -- ha a női ruháknak más a száma, itt írd át
    female = {
        { component = 1,  drawable = 0,   texture = 0 },  -- maszk (üres)
        { component = 3,  drawable = 19,  texture = 0 },  -- kezek
        { component = 4,  drawable = 457, texture = 0 },  -- nadrág
        { component = 5,  drawable = 0,   texture = 0 },  -- táska és ejtőernyő (üres)
        { component = 6,  drawable = 25,  texture = 0 },  -- cipő
        { component = 7,  drawable = 0,   texture = 0 },  -- sál és láncok (üres)
        { component = 8,  drawable = 15,  texture = 0 },  -- póló
        { component = 9,  drawable = 0,   texture = 0 },  -- testpáncél (üres)
        { component = 10, drawable = 0,   texture = 0 },  -- matricák (üres)
        { component = 11, drawable = 923, texture = 0 },  -- kabát
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- NPC a statisztika/menedzsment panelnél + térkép blip
-----------------------------------------------------------------------------------------------------------------------------------------

Config.StatsNpc = {
    model  = 's_m_m_dockwork_01',
    radius = 20.0,   -- csak ekkora távolságon belül spawnol; kilépéskor (+15 m hiszterézis) törlődik
    -- az irány (heading) a Config.StatsPanel.w-ből jön
}

Config.Blip = {
    coords = vector3(69.034042, 125.0, 79.21),
    sprite = 478,   -- doboz/csomag ikon
    color  = 47,
    scale  = 0.85,
    label  = 'Futár Munka',
}

-- Kiszálláskor a futár-kocsira kerülő térkép-blip (azonnal megjelenik, visszaüléskor eltűnik)
Config.CarBlip = {
    sprite     = 225,            -- személyautó/jármű ikon
    color      = 3,              -- kék
    scale      = 0.9,
    shortRange = false,          -- a teljes térképen is látszódjon
    label      = 'Futár Jármű',
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- MENEDZSMENT – 3 feloldható céges TELEP, sofőrök bérlése passzív bevételért (mint a truck_logistics).
-- A bérelt sofőrök időszakosan pénzt termelnek (km-alapon), amit a panelen lehet beszedni.
-- A telepeket SORBAN kell feloldani (1→2→3): mindegyikhez ár + leadott fuvarszám feltétel kell.
-- Minél jobb a telep, annál jobb (több ár/km-ű) sofőröket lehet hozzá felvenni, telepenkénti kapacitással.
-----------------------------------------------------------------------------------------------------------------------------------------

-- TELEPEK – a sofőr "szintje" (depot 1–3) = melyik telephez tartozik. A jelölt gazdasága (díj, ár/km)
-- a telep szintje szerint skálázódik; a capacity a telepenkénti max sofőrszám.
Config.Depots = {
    {
        label = 'Belvárosi Telep', img = 'nui://bc_express/html/img/depo1.webp',
        unlockPrice = 2000000,  reqDeliveries = 50,
        capacity = 3, hireCostMin = 40000,  hireCostMax = 80000,  pricePerKmMin = 800,  pricePerKmMax = 1400,
    },
    {
        label = 'Kikötői Telep',   img = 'nui://bc_express/html/img/depo2.webp',
        unlockPrice = 8000000,  reqDeliveries = 250,
        capacity = 4, hireCostMin = 80000,  hireCostMax = 150000, pricePerKmMin = 1400, pricePerKmMax = 2200,
    },
    {
        label = 'Reptéri Telep',   img = 'nui://bc_express/html/img/depo3.webp',
        unlockPrice = 30000000, reqDeliveries = 750, reqPP = 5000,   -- a legfelső telep PP-be is kerül (bc_ppshop)
        capacity = 5, hireCostMin = 150000, hireCostMax = 300000, pricePerKmMin = 2200, pricePerKmMax = 3500,
    },
}

-- PP (bc_ppshop) erőforrás – kizárólag a telep-feloldás PP-feltételéhez (leadásért NEM jár PP)
Config.PPResource = 'bc_ppshop'

-----------------------------------------------------------------------------------------------------------------------------------------
-- CÉG ELADÁSA – a felépített céget egyben el lehet adni. A játékos visszakapja a cégkasszát teljesen,
-- a befektetett eszközök (telepek, gépek, kapcsolatok, munkások, engedély, sofőr-felvételi díjak) egy
-- részét, majd MINDEN céges adat nullázódik (a személyes futár-statok megmaradnak).
-----------------------------------------------------------------------------------------------------------------------------------------

Config.SellCompany = {
    assetRecovery = 0.60,   -- a befektetett eszközök ennyi része térül meg eladáskor
    minDepots     = 1,      -- legalább ennyi feloldott telep kell az eladáshoz
}

-- Cégátadási ajánlat élettartama (mp). Ennyi ideje van a fogadónak elfogadni, különben lejár.
Config.TransferOfferTTL = 60

-----------------------------------------------------------------------------------------------------------------------------------------
-- ALKALMAZOTTAK (VALÓDI JÁTÉKOSOK) – a tulaj a depo-panelen a LEGKÖZELEBBI online játékost veszi fel.
-- Az alkalmazott a telefonján CSAK LÁTJA, kinél van felvéve + a statokat; a depo-panelen (NPC) tudja a
-- karbantartást (a tulaj gépeit javítja / kapcsolatait ápolja a tulaj kasszájából). Pénzhez NEM fér hozzá.
-- Cserébe fix bért kap a bankjába minden kifizetési ciklusban (a tulaj cégkasszájából).
-----------------------------------------------------------------------------------------------------------------------------------------

Config.Employees = {
    maxPerOwner   = 5,      -- max valódi alkalmazott / tulaj
    maxEmployers  = 3,      -- max ennyi CÉGNÉL lehet egy játékos egyszerre alkalmazott
    hireRange     = 3.0,    -- a tulajtól ekkora körön belüli játékost lehet felvenni (szerveroldali ellenőrzés is)
    wagePerCycle  = 8000,   -- fix bér / alkalmazott / ciklus (a cégkasszából a felvehető béredbe gyűlik)
    -- A bér OFFLINE is gyűlik: minden ciklusban a cégkasszából az alkalmazott "felvehető bér" egyenlegébe
    -- kerül, amit a depón bármikor felvehet a saját bankjába.
}

Config.Manager = {
    payoutInterval = 30,        -- PERC két passzív kifizetés között (nagy wait)
    -- a kifizetés képlete (truck_logistics-szerű): alapdíj + km*ár/km (az ár/km a telep szintjéből jön)
    payMin        = 9000,
    payMax        = 16000,

    -- a sofőrök NAGYON APRÓ EXP-et is termelnek a tulajnak ciklusonként (a BC Express szinthez)
    expMin        = 5,
    expMax        = 15,
    distanceKmMin = 3,
    distanceKmMax = 22,
    offlineEarn   = false,      -- true: offline is termel; false: csak ha a tulaj online

    -- BÉR: minden kifizetési ciklusban ennyit FIZETSZ a sofőrnek a CÉGKASSZÁBÓL (költség).
    -- A sofőr bevétele (km-alapú) viszont a kasszába FOLYIK BE → nettó pozitív, ha jól megy.
    -- Ha a kassza nem fedezi a bért, a sofőr nem dolgozik abban a ciklusban (és szólunk).
    wageMin       = 3000,
    wageMax       = 7000,

    -- KÖZÖS, ELÉRHETŐ SOFŐR-POOL (mint a kamionos): jelöltek generálódnak, ezekből lehet választani.
    -- Ha valaki előbb felveszi, addig nem érhető el, amíg új nem generálódik.
    poolSize      = 6,          -- ennyi elérhető jelölt legyen egyszerre a poolban
    genInterval   = 5,          -- PERC – ennyi időnként generálódik új jelölt, ha a pool nincs tele

    -- véletlen sofőrnevek
    names = {
        'Pedro Aquino', 'Jorge Fernandes', 'Lucas Silva', 'Kirk Cook', 'Davis Guerrero',
        'Norton Anthony', 'Parks Dale', 'Moon Acevedo', 'Wells Wyatt', 'Jordan Hyde',
        'Holden Lynch', 'Chapman Preston', 'Blake Stuart', 'Russell Bowen', 'Stone Robinson',
        'Young Hines', 'Potter Wagner', 'Kerr Kemp', 'Goff Raymond', 'Reilly Callahan',
    },
    -- sofőr avatarok (a jelöltekhez random; ha nincs net, a NUI elrejti a törött képet)
    avatars = {
        'https://bootdey.com/img/Content/avatar/avatar1.png',
        'https://bootdey.com/img/Content/avatar/avatar2.png',
        'https://bootdey.com/img/Content/avatar/avatar3.png',
        'https://bootdey.com/img/Content/avatar/avatar4.png',
        'https://bootdey.com/img/Content/avatar/avatar5.png',
        'https://bootdey.com/img/Content/avatar/avatar6.png',
        'https://bootdey.com/img/Content/avatar/avatar7.png',
        'https://bootdey.com/img/Content/avatar/avatar8.png',
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- TELEPHELY ÜZEMELTETÉS – telepenként: szortírozó gépek (romlanak, javítani kell), munkások (üzemeltetik
-- a gépeket), kapcsolatok (romlanak, ápolni kell, felszorozzák a hozamot). Együtt egy "szortírozó vonal"
-- passzív bevételt adnak a CÉGKASSZÁBA (a sofőr-kifizetéssel közös ciklusban). + törékeny-engedély.
-- A per-telep limitek tömbök: index = telep-szint (1–3).
-----------------------------------------------------------------------------------------------------------------------------------------

Config.Operations = {
    machine = {
        buyCost          = 250000,        -- egy gép ára (cégkasszából)
        maxPerDepot      = { 2, 3, 4 },   -- max gép telep-szintenként
        decayPerCycle    = 8,             -- ennyit romlik a kondíció ciklusonként (%)
        breakBelow       = 20,            -- ez alatt a gép nem termel (javítani kell)
        repairCostPerPct = 1500,          -- 1% kondíció visszaállítása ennyibe kerül (cégkassza)
        incomePerCycle   = 40000,         -- egy MŰKÖDŐ gép (munkással) ennyit termel ciklusonként
    },
    worker = {
        hireCost     = 50000,             -- felvételi díj (cégkassza)
        maxPerDepot  = { 3, 4, 6 },       -- max munkás telep-szintenként
        wagePerCycle = 6000,              -- bér / munkás / ciklus (cégkassza)
    },
    connection = {
        formCost              = 300000,   -- új kapcsolat kötése (cégkassza)
        maxPerDepot           = { 1, 2, 3 },
        decayPerCycle         = 10,       -- kapcsolat-szint romlása ciklusonként (%)
        nurtureCostPerPct     = 1000,     -- 1% kapcsolat-szint visszaállítása (cégkassza)
        perConnectionBonusPct = 20,       -- teli (100%) kapcsolat = +20% a telep szalag-bevételére
    },
    permit = {
        -- törékeny-engedély szintek. Ár a BANKBÓL (mint a telep-feloldás). A max szintet a feloldott
        -- telep-szinted sapkázza. Magasabb engedély: nagyobb esély ÉS nagyobb érték a saját törékenyekre.
        tiers = {
            { label = 'Alap',     price = 1000000,  fragileChanceAdd = 10, valueMultAdd = 0.3 },
            { label = 'Bővített', price = 5000000,  fragileChanceAdd = 20, valueMultAdd = 0.6 },
            { label = 'Prémium',  price = 20000000, fragileChanceAdd = 35, valueMultAdd = 1.0 },
        },
    },
}

-- Discord webhook a szerveroldali logokhoz: munka indítás/leadás/megszakadás, telep-feloldás, sofőrök,
-- cégkassza be/ki, gép/munkás/összeköttetés/engedély vásárlás, alkalmazottak, cégeladás/átadás.
-- Üresen hagyva nincs logolás.
Config.LogWebhook = 'https://discord.com/api/webhooks/1522328710190207056/7mNCaNDmD_vFzb97DGWJ-zPuxlMIK4btWazpnbhhn8fr-t-zLGoFZ4t7kmi2_bPWrkZN'

-----------------------------------------------------------------------------------------------------------------------------------------
-- BOOST KÁRTYÁK (bc_jobboost) – ugyanúgy, mint a truck_logistics.
-----------------------------------------------------------------------------------------------------------------------------------------

Config.BoostResource   = 'bc_jobboost'
Config.BoostMoneyField = 'moneyBoost'
Config.BoostExpField   = 'expBoost'

-----------------------------------------------------------------------------------------------------------------------------------------
-- AI HANGOK – lásd AI_VOICES.md
-----------------------------------------------------------------------------------------------------------------------------------------

Config.Voices = {
    welcome   = 'bcx_welcome',
    pickup    = 'bcx_pickup',
    delivered = 'bcx_delivered',
    payday    = 'bcx_payday',
    fired     = 'bcx_fired',
}

-- KÖZÖS hang-id: így egyszerre csak EGY BCX-hang szól. Új hang előtt az előzőt leállítjuk,
-- különben gyors egymásutánban (pl. felvétel → azonnali leadás) összeakadnak.
local VOICE_ID = 'bcx_voice'

function Config.PlayVoice(key)
    local file = Config.Voices and Config.Voices[key]
    if not file then return end
    if GetResourceState('xsound') == 'started' then
        if exports.xsound:soundExists(VOICE_ID) then exports.xsound:Destroy(VOICE_ID) end
        local url = ('nui://%s/sounds/%s.ogg'):format(GetCurrentResourceName(), file)
        exports.xsound:PlayUrl(VOICE_ID, url, 0.4, false)
    elseif GetResourceState('interact-sound') == 'started' then
        TriggerEvent('InteractSound_CL:PlayOnOne', 'bcx/' .. file, 0.4)
    end
end
