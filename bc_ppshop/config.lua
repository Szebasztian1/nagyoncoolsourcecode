Config = {}

Config.WhileOpenUpdateTick = 2000
Config.CacheTimeout = {
  CharData = 30 * 60 * 1000,
  PlayerData = 5*60 * 1000,
  PremiumPoint = 15 * 1000,
  Cars = 2*60 * 1000,
  Counters = 60 * 1000,
  Uptime = 60 * 1000,
  PPItems = 60 * 1000,
  Vip = 2 * 60 * 1000,
  OtherPlayerData = 3*60 * 1000,
  WeeklyDiscount = 60 * 1000
}

-- Az /addppcar-ral felvett autó ennyi ideig (mp) "Új" jelzéssel, a lista elején látszik
Config.NewItemDuration = 7 * 24 * 60 * 60

-- HETI AKCIÓ
-- Minden hétfő 00:00-kor (szerveridő) a szerver slotonként kisorsol egy
-- elérhető autót a premiumcars.json-ból, és a megadott százalékkal leárazza.
-- A heti ár mellé semmilyen más kedvezmény (VIP, partner stb.) nem jön.
Config.WeeklyDiscount = {
  Enabled = true,
  Slots = { -- a sorrend egyben a slide-ok sorrendje
    { category = "egyedi", label = "Egyedi autó",   percent = 25 },
    { category = "limit",  label = "Limitált autó", percent = 25 },
  },
  AvoidLastWeek = true,           -- az előző heti autókat lehetőleg ne sorsolja újra
  CheckInterval = 5 * 60 * 1000,  -- hetváltás ellenőrzése (ms)
}

Config.Infos = {
  --[[{label = "Szabályok", rules = {
        {label = "PG", text = "Hősködés"}
    }},
    {label = "Támogatás", text = "Discordon az ezzel kapcsolatos szobában mindent megtalálsz!"},]]
  {
    label = "Általános Billentyűzet kiosztás",
    rules = {
      { label = "F1",   text = "Telefon" },
      { label = "F2",   text = "Inventory megnyitása" },
      { label = "F3",   text = "Animáció menü" },
      { label = "F5",   text = "Rendvédelmi menü" },
      { label = "F6",   text = "Frakció panel (Motozás, bilincs stb.)" },
      { label = "F7",   text = "Számlák megnyitása" },
      { label = "F11",  text = "Player és PP panel" },
      { label = "T",    text = "Chat-re való írás" },
      { label = "P",    text = "Térkép megnyitása" },
      { label = "F",    text = "Kocsiba beszállás" },
      { label = "G",    text = "Kocsi lezárása / nyitása (közel kell állni és az autóra kell nézni)" },
      { label = "K",    text = "Öltözék menü megnyitása (lenyomva kell tartani)" },
      { label = "L",    text = "Dokumentumok panel megnyitása" },
      { label = "X",    text = "Kéz feltétele" },
      { label = "B",    text = "Mutatás" },
      { label = ",",    text = "Összeesés" },
      { label = "0-6",  text = "Action bar gombok" },
      { label = "Home", text = "Háziállat menü megnyitása" },
      { label = "Ctrl", text = "Gugolás" },
      { label = "ALT",  text = "Fűültetésnél ezzel lehet lenyomva tartva a kezelő menüt klikkelni" },
    }
  },
  {
    label = "Autós Billentyűzet kiosztás",
    rules = {
      { label = "U",     text = "Motor indítása/leállítása" },
      { label = "K",     text = "Biztonsági öv be/kikapcsolása" },
      { label = "H",     text = "Reflektor állítása" },
      { label = "E",     text = "Duda" },
      { label = "F9",    text = "Autó action bar" },
      { label = "F10",   text = "Rendőrségi megafon" },
      { label = "B",     text = "Tempomat" },
      { label = "X",     text = "Kocsiban előrehajolás" },
      { label = "SHIFT", text = "Hosszan nyomva átülsz a melletted lévő ülésre" },
      { label = "SPACE", text = "Kézifék" },
    }
  },
  {
    label = "Chat típusok",
    rules = {
      { label = "/twt",  text = "Twitter chat, kiírja a neved" },
      { label = "/htwt", text = "Titkos chat, nem írja ki a neved" },
      { label = "/ad",   text = "Fizetett hirdetés" },
    }
  },
  {
    label = "Hasznos parancsok",
    rules = {
      { label = "/report",         text = "Report írása adminok számára. Egy report nyitva marad amíg egy admin nem megy ki, így felesleges több embernek írnia, valamint spamelni, mert ahogy lesz szabad admin ki fog menni, még akkor is látni fogja ha később lett online mint ahogy elküldted a reportot!" },
      { label = "/foldre",         text = "Ha esetleg beesnél a textúra alá, ezzel azonnal a felszínre tudsz kerülni" },
      { label = "/hostage",        text = "Ha fegyverrel ejtettél NPC túszt ezzel tudod megnyitni a kezelő menüjét" },
      { label = "/takehostage",    text = "Ha pisztoly van a kezedben ezzel fegyvert tudsz tartani az ember fejéhez (csak játékosnak)" },
      { label = "/panel",          text = "F11 gombnak felel meg" },
      { label = "/jelol [ID]",     text = "Barát kérelem küldése" },
      { label = "/fps",            text = "FPS boost panel megnyitása, a beállításokkal több FPS-t tudsz csinálni" },
      { label = "/notifysettings", text = "Notify beállítások, hol jelenjen meg, stb." },
      { label = "/checknotify",    text = "Notify tesztelése" },
      { label = "/hud",            text = "HUD beállítások megnyitása" },
      { label = "/idk",            text = "ID-k elrejtése a fejek fölül" },
    }
  },
  {
    label = "Kisállat parancsok",
    rules = {
      { label = "/petanim",        text = "Kisállat animációs menü megnyitása" },
      { label = "/petruha",        text = "Kisállat ruha menü megnyitása" },
      { label = "/petmenu",        text = "Kisállat főmenü megnyitása" },
      { label = "/pethud",         text = "Kisállat HUD pozíciójának módosítása" },
      { label = "/petk9",          text = "K9 támadás indítása" },
      { label = "/k9drog",         text = "K9 keresés indítása" },
    }
  },
}

Config.VIPDiscount = 10

Config.InsertTo = 45

Config.PPCategories = {
  ["egyedik"] = {label = "EGYEDI JÁRMŰVEK", catids = {"egyedi"}},
  ["limits"] = {label = "LIMITÁLT JÁRMŰVEK", catids = {"limit"}},
  ["sounds"] = {label = "JÁRMŰ HANGOK", catids = {"sound"}},
  ["cars"] = {label = "PPS JÁRMŰVEK", catids = {"car"}},
  ["vipk"] = {label = "VIP", catids = {"vip"}},
  ["hazak"] = {label = "SAJÁT HÁZAK", catids = {"haz"}},
  ["ladak"] = {label = "LÁDA", catids = {"lada"}},
  ["taskak"] = {label = "TRASH TÁSKA", catids = {"taska"}},
  ["premium"] = {label = "PRÉMIUM TÁRGYAK", catids = {"premium"}},
  ["petek"] = {label = "HÁZI KEDVENCEK", catids = {"pet"}},
  ["egyebek"] = {label = "EGYÉB", catids = {"egyeb"}},
  ["pedek"] = {label = "PED", catids = {"pedek"}},
  ["weapons"] = {label = "Egyedi fegyverek", catids = {"weapon"}},
}

Config.PPItems = {
  {
    name = "namechange",          --mindegyik különböző
    img = "img/namechange.webp", --kép
    label = "Névváltoztatás",
    text = "Legyen teljesen új neved!",
    price = 1500,
    category = "egyeb",
    event = "villamos_pp:nameChange",
    data = { client = "esx_identity" }
  },
  {
    name = "vip30",          --mindegyik különböző
    img = "img/goldvip.webp", --kép
    label = "30 napos Gold VIP tagság",
    text = "30 napos Gold VIP tagság",
    price = 3000,
    category = "vip",
    event = "villamos_pp:buyVip",
    data = { time = 30 * 24 * 60 * 60, bundle = "gold" }
  },
  {
    name = "vipplatina30",      --mindegyik különböző
    img = "img/platinavip.webp", --kép
    label = "30 napos Platina VIP tagság",
    text = "30 napos Platina VIP tagság",
    price = 11500,
    category = "vip",
    event = "villamos_pp:buyVip",
    data = { time = 30 * 24 * 60 * 60, bundle = "platina" }
  },
  {
    name = "fullskill",      --mindegyik különböző
    img = "img/fullskill.webp", --kép
    label = "Full Skill",
    text = "Fejleszd maximális szintre az összes képességedet.",
    price = 10000,
    category = "vip",
    event = "villamos_pp:fullSkill",
    data = {  }
  },
  {
    name = "customrank",                 --mindegyik különböző
    img = "img/customrank.webp", --kép
    label = "Egyedi rang a fejed fölött (30 nap)",
    text = "Egyedi rang a fejed fölött (30 nap)",
    price = 5000,
    category = "egyeb",
    event = "villamos_pp:buyCsutomRank",
    data = {}
  },
  {
    name = "muszaki",                 --mindegyik különböző
    img = "img/muszaki.webp", --kép
    label = "Összes autód műszakiztatása",
    text = "Összes autód műszakiztatása, 1-honapra",
    price = 10000,
    category = "premium",
    event = "bc_tax:addMassPremiumInspection",
    data = {}
  },
  {
    name = "teletank",                 --mindegyik különböző
    img = "img/teletank.webp", --kép
    label = "Teli benzines kanna",
    text = "Teli benzines kanna",
    price = 1250,
    category = "premium",
    event = "villamos_pp:teletank",
    data = {}
  },
  {
    name = "moneywash",             --mindegyik különböző
    img = "img/moneywash.webp", --kép
    label = "0% os pénzmosás frakcióba (30 nap)",
    text = "Nem vállalunk felelősséget hogyha rossz frakcióba veszed",
    price = 10000,
    category = "egyeb",
    event = "bc_moneywash:buymonth",
    data = { time = 30 * 24 }
  },
  {
    name = "avhd",             --mindegyik különböző
    img = "img/no_delete.webp", --kép
    label = "Kocsi törlés mentesség (30nap)",
    text = "Kocsi törlés mentesség (30nap)",
    price = 3000,
    category = "egyeb",
    event = "bc_kocsitroles:vasarlas",
    data = { time = 30 * 24 }
  },
  {
    name = "phonenum",                 --mindegyik különböző
    img = "img/egyediteloszam.webp", --kép
    label = "Egyedi telefonszám",
    text = "Egyedi telefonszám",
    price = 3000,
    category = "egyeb",
    event = "villamos_pp:buyPhoneNum",
    data = {}
  },
  {
    name = "plate",                 --mindegyik különböző
    img = "img/egyedirendszam.webp", --kép
    label = "Egyedi rendszám",
    text = "Tedd egyedivé a járművedet.",
    price = 3000,
    category = "egyeb",
    event = "villamos_pp:buyPlate",
    data = {}
  },
  {
    name = "extraspeed5",                 --mindegyik különböző
    img = "img/extraspeed5.webp", --kép
    label = "Extrasebesség 5",
    text = "+5km/h sebesség",
    price = 10000,
    category = "egyeb",
    event = "villamos_pp:buyExtraSpeed5",
    data = {}
  },
  {
    name = "extraspeed10",                 --mindegyik különböző
    img = "img/extraspeed10.webp", --kép
    label = "Extrasebesség 10",
    text = "+10km/h sebesség",
    price = 15000,
    category = "egyeb",
    event = "villamos_pp:buyExtraSpeed10",
    data = {}
  },
  {
    name = "extraarmor",                 --mindegyik különböző
    img = "img/extraarmor.webp", --kép
    label = "Extra páncél autóra",
    text = "Extra páncél Növeli az autó lövésállóságát.",
    price = 10000,
    category = "egyeb",
    event = "villamos_pp:buyArmor",
    data = {}
  },
  {
    name = "weaponunban",          --mindegyik különböző
    img = "img/weaponunban.webp", --kép
    label = "Fegyver tiltás törlése",
    text = "Fegyver tiltás törlése",
    price = 10000,
    category = "egyeb",
    event = "villamos_pp:weaponunban",
    data = {}
  },
  --{
  --  name = "pedreset",          --mindegyik különböző
  --  img = "img/ped_change.webp", --kép
  --  label = "Ped csere reset",
  --  text = "Ped csere reset",
  --  price = 3000,
  --  category = "egyeb",
  --  event = "bc_peds:resetped",
  --  data = {}
  --},
  {
    name = "frakijump",          --mindegyik különböző
    img = "img/frakciojump.webp", --kép
    label = "Frakció jump levétel",
    text = "Ha van rajtad discordon frakció jump, ezzel le tudod vetetni",
    price = 5000,
    category = "egyeb",
    event = "villamos_pp:frakijump",
    data = {}
  },
  --[[{
    name = "ujrepairkitpremium",        --mindegyik különböző
    img = "img/ujrepairkitpremium.webp", --kép
    label = "Prémium Szerelő láda",
    text = "Szereléshez tökéletes láda. Bármikor használható, nincs időhöz kötve, ez egy prémium tárgy. A tárgy lejáratos!",
    price = 3000,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "ujrepairkitpremium", count = 1 }
  },--]]
  {
    name = "job_xp_boost_small",
    img = "img/job_xp_boost_small.webp",
    label = "Prémium Munkajegy (1.5x EXP)",
    text = "24 órán keresztül 1.5x EXP minden munkánál.",
    price = 2000,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "job_xp_boost_small", count = 1 }
  },
  {
      name = "job_money_boost_small",
      img = "img/job_money_boost_small.webp",
      label = "Prémium Munkajegy (1.5x Pénz)",
      text = "24 órán keresztül 1.5x pénzjutalom minden munkánál.",
      price = 2000,
      category = "premium",
      event = "villamos_pp:buyItem",
      data = { item = "job_money_boost_small", count = 1 }
  },
  {
      name = "job_extra_boost_small",
      img = "img/job_extra_boost_small.webp",
      label = "Prémium Munkajegy (1.5x EXP + 1.5x Pénz)",
      text = "24 órán keresztül 1.5x EXP és 1.5x pénzjutalom minden munkánál.",
      price = 4500,
      category = "premium",
      event = "villamos_pp:buyItem",
      data = { item = "job_extra_boost_small", count = 1 }
  },
  {
    name = "weaponrepairkit",        --mindegyik különböző
    img = "img/weaponrepairkit.webp", --kép
    label = "Fegyver javító készlet",
    text = "Fegyver javító készlet",
    price = 3500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "weaponrepairkit", count = 1 }
  },
  {
    name = "ujrepairkit",        --mindegyik különböző
    img = "img/ujrepairkit.webp", --kép
    label = "Szerelő láda",
    text = "Szereléshez tökéletes láda. A tárgy lejáratos!",
    price = 1500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "ujrepairkit", count = 1 }
  },
  {
    name = "deployable_light",        --mindegyik különböző
    img = "img/deployable_light.webp", --kép
    label = "Levehető sziréna",
    text = "Sziréna rendvédelmiseknek. Itemként működik, bármikor le- és felszerelhető.",
    price = 10000,
    category = "egyeb",
    event = "villamos_pp:buyItem",
    data = { item = "deployable_light", count = 1 }
  },
  {
    name = "szovigps",
    img = "img/szovigps.webp",
    label = "Szövi GPS",
    text = "Speciális GPS, amely szövetségi funkciókat biztosít. A szövetség megkötéséhez továbbra is ki kell fizetni a 100.000.000$-t, ez csak egy tárgy.",
    price = 4000,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "szovigps", count = 1 }
  },
  {
    name = "ujphone",
    img = "img/ujphone.webp",
    label = "Új Telefon",
    text = "Modern telefon, amely rengeteg hasznos funkciót és lehetőséget rejt a mindennapi játék során.",
    price = 500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "ujphone", count = 1 }
  },
  {
    name = "small_safe",
    img = "img/small_safe.webp",
    label = "Kis Széf",
    text = "Hordozható kis széf (20-kg), amelyben biztonságosan tárolhatod a tárgyaidat bárhol, interiorokon kívül.",
    price = 4500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "small_safe", count = 1 }
  },
  {
    name = "big_safe",
    img = "img/big_safe.webp",
    label = "Nagy Széf",
    text = "Nagy kapacitású széf (50-kg), amely ideális nagyobb mennyiségű tárgy tárolására. Bárhol lehelyezhető, interiorokon kívül.",
    price = 6500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "big_safe", count = 1 }
  },
  {
    name = "emelo",        --mindegyik különböző
    img = "img/emelo.webp", --kép
    label = "Emelő",
    text = "Fordítsd vissza az autód",
    price = 1000,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "emelo", count = 1 }
  },
  {
    name = "ppammolada",        --mindegyik különböző
    img = "img/ppammolada.webp", --kép
    label = "PP-s Ammo Láda",
    text = "A láda tartalma lehet véletlenszerű lőszer és egy Box láda.",
    price = 2000,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "ppammolada", count = 1 }
  },
  {
    name = "tetto_jegy",        --mindegyik különböző
    img = "img/tetto2.webp", --kép
    label = "Teljes Tetoválás 1",
    text = "Legyél te a legmenőbb a szerveren.",
    price = 10000,
    category = "egyeb",
    event = "villamos_pp:buyItem",
    data = { item = "tetto_jegy", count = 1 }
  },
  {
    name = "craftingtable",        --mindegyik különböző
    img = "img/craftingtable.webp", --kép
    label = "Craft Asztal",
    text = "Saját Craft Asztal",
    price = 20000,
    category = "egyeb",
    event = "villamos_pp:buyItem",
    data = { item = "craftingtable", count = 1 }
  },
  {
    name = "blackoldlimit",       --mindegyik különböző
    img = "img/blackoldlimit.webp", --kép
    label = "Régi Limitált Autók",
    text = "(2022-2025)",
    price = 30000,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "blackoldlimit", count = 1 }
  },
  {
    name = "bc_newbackpack_1",
    img = "img/bc_newbackpack_1.webp",
    label = "Sárkány Trash Piros",
    text = "Egy különleges piros sárkány hátizsák. Stílusos megjelenés és praktikus tárolás egyben.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_1", count = 1 }
  },

  {
    name = "bc_newbackpack_2",
    img = "img/bc_newbackpack_2.webp",
    label = "Sárkány Trash Kék",
    text = "Kék színű sárkány hátizsák, amely ötvözi a stílust és a funkcionalitást.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_2", count = 1 }
  },

  {
    name = "bc_newbackpack_3",
    img = "img/bc_newbackpack_3.webp",
    label = "Sárkány Trash Fehér",
    text = "Elegáns fehér sárkány hátizsák, letisztult és egyedi megjelenéssel.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_3", count = 1 }
  },

  {
    name = "bc_newbackpack_4",
    img = "img/bc_newbackpack_4.webp",
    label = "Sárkány Trash Zöld",
    text = "Zöld sárkány hátizsák, természetközeli stílussal és strapabíró kialakítással.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_4", count = 1 }
  },

  {
    name = "bc_newbackpack_5",
    img = "img/bc_newbackpack_5.webp",
    label = "Sárkány Trash Lila",
    text = "Lila sárkány hátizsák, feltűnő és egyedi megjelenéssel.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_5", count = 1 }
  },

  {
    name = "bc_newbackpack_6",
    img = "img/bc_newbackpack_6.webp",
    label = "Sárkány Trash Sötét Zöld",
    text = "Sötétzöld sárkány hátizsák, komolyabb és letisztult stílus kedvelőinek.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_6", count = 1 }
  },

  {
    name = "bc_newbackpack_7",
    img = "img/bc_newbackpack_7.webp",
    label = "Sárkány Trash Szürke",
    text = "Szürke sárkány hátizsák, minden öltözethez illő univerzális választás.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_7", count = 1 }
  },

  {
    name = "bc_newbackpack_8",
    img = "img/bc_newbackpack_8.webp",
    label = "Tehén Trash Táska",
    text = "Rózsaszín-fekete foltos tehén plüss hátizsák.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_8", count = 1 }
  },

  {
    name = "bc_newbackpack_9",
    img = "img/bc_newbackpack_9.webp",
    label = "Cica Trash Táska Korall",
    text = "Korallszínű cicás hátizsák, elöl ablakos hordozóval.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_9", count = 1 }
  },

  {
    name = "bc_newbackpack_10",
    img = "img/bc_newbackpack_10.webp",
    label = "Szív Trash Táska",
    text = "Piros hátizsák nagy szív alakú előzsebbel.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_10", count = 1 }
  },

  {
    name = "bc_newbackpack_11",
    img = "img/bc_newbackpack_11.webp",
    label = "Graffiti Trash Fekete",
    text = "Fekete hátizsák füstös, graffitis koponyamintával.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_11", count = 1 }
  },

  {
    name = "bc_newbackpack_12",
    img = "img/bc_newbackpack_12.webp",
    label = "Bálna Trash Táska",
    text = "Sárga bálna formájú plüss hátizsák, kék uszonyokkal.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_12", count = 1 }
  },

  {
    name = "bc_newbackpack_13",
    img = "img/bc_newbackpack_13.webp",
    label = "Sárkány Trash Menta",
    text = "Mentazöld sárkány plüss hátizsák fehér szárnyakkal.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_13", count = 1 }
  },

  {
    name = "bc_newbackpack_14",
    img = "img/bc_newbackpack_14.webp",
    label = "Koponyás Maci Trash",
    text = "Barna maci plüss hátizsák koponya fejjel.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_14", count = 1 }
  },

  {
    name = "bc_newbackpack_15",
    img = "img/bc_newbackpack_15.webp",
    label = "Városi Trash Fekete",
    text = "Letisztult fekete városi hátizsák, mindennapokra.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_15", count = 1 }
  },

  {
    name = "bc_newbackpack_16",
    img = "img/bc_newbackpack_16.webp",
    label = "Cica Trash Táska Kék",
    text = "Kék cicás hátizsák, fekete-fehér cicával.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_16", count = 1 }
  },

  {
    name = "bc_newbackpack_17",
    img = "img/bc_newbackpack_17.webp",
    label = "Cica Trash Rózsaszín",
    text = "Rózsaszín cicás hátizsák, elöl ablakos hordozóval.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_17", count = 1 }
  },

  {
    name = "bc_newbackpack_18",
    img = "img/bc_newbackpack_18.webp",
    label = "Cica Trash Táska Fehér",
    text = "Fehér cicás hátizsák narancs fülekkel.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_18", count = 1 }
  },

  {
    name = "bc_newbackpack_19",
    img = "img/bc_newbackpack_19.webp",
    label = "Cica Trash Táska Foltos",
    text = "Narancs-fehér foltos cicás hátizsák.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_19", count = 1 }
  },

  {
    name = "bc_newbackpack_20",
    img = "img/bc_newbackpack_20.webp",
    label = "Városi Trash Szürke",
    text = "Világosszürke városi hátizsák türkiz cipzárbetéttel.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_20", count = 1 }
  },

  {
    name = "bc_newbackpack_21",
    img = "img/bc_newbackpack_21.webp",
    label = "Városi Trash Barna",
    text = "Sötétbarna városi hátizsák, visszafogott stílusban.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_21", count = 1 }
  },

  {
    name = "bc_newbackpack_22",
    img = "img/bc_newbackpack_22.webp",
    label = "Városi Trash Kék",
    text = "Élénkkék városi hátizsák, hétköznapi praktikummal.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_22", count = 1 }
  },

  {
    name = "bc_newbackpack_23",
    img = "img/bc_newbackpack_23.webp",
    label = "Városi Trash Sötétkék",
    text = "Sötétkék városi hátizsák szürke cipzárbetéttel.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_23", count = 1 }
  },

  {
    name = "bc_newbackpack_24",
    img = "img/bc_newbackpack_24.webp",
    label = "Graffiti Trash Piros",
    text = "Sötét hátizsák piros-lila graffitis koponyamintával.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_24", count = 1 }
  },

  {
    name = "bc_newbackpack_25",
    img = "img/bc_newbackpack_25.webp",
    label = "Graffiti Trash Fehér",
    text = "Fehér hátizsák pasztell graffitis koponyamintával.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_25", count = 1 }
  },

  {
    name = "bc_newbackpack_26",
    img = "img/bc_newbackpack_26.webp",
    label = "Graffiti Trash Zöld",
    text = "Sötétzöld hátizsák graffitis koponyamintával.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "bc_newbackpack_26", count = 1 }
  },
  
  {
  name = "toxic_grinch_bag_01",
  img = "img/toxic_grinch_bag_01.webp",
  label = "Grin Trash Táska",
  text = "Hátra vehető Táska.",
  price = 10000,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_grinch_bag_01", count = 1 }
  },
  {
  name = "toxic_grinch_bag_02",
  img = "img/toxic_grinch_bag_02.webp",
  label = "Grin Trash Táska",
  text = "Hátra vehető Táska.",
  price = 10000,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_grinch_bag_02", count = 1 }
  },
  {
  name = "toxic_grinch_bag_03",
  img = "img/toxic_grinch_bag_03.webp",
  label = "Grin Trash Táska",
  text = "Hátra vehető Táska.",
  price = 10000,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_grinch_bag_03", count = 1 }
  },
  {
  name = "toxic_grinch_bag_04",
  img = "img/toxic_grinch_bag_04.webp",
  label = "Grin Trash Táska",
  text = "Hátra vehető Táska.",
  price = 10000,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_grinch_bag_04", count = 1 }
  },
  {
  name = "toxic_grinch_bag_05",
  img = "img/toxic_grinch_bag_05.webp",
  label = "Grin Trash Táska",
  text = "Hátra vehető Táska.",
  price = 10000,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_grinch_bag_05", count = 1 }
  },
  {
  name = "toxic_alyx_bag_01",
  img = "img/toxic_alyx_bag_01.webp",
  label = "Alyx Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_alyx_bag_01", count = 1 }
  },
  {
    name = "toxic_baby_shark_bag_01",
    img = "img/toxic_baby_shark_bag_01.webp",
    label = "Baba Cápa Táska",
    text = "Hátra vehető Cápa Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_baby_shark_bag_01", count = 1 }
  },
  {
    name = "toxic_baby_shark_bag_02",
    img = "img/toxic_baby_shark_bag_02.webp",
    label = "Baba Cápa Táska 2",
    text = "Hátra vehető Cápa Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_baby_shark_bag_02", count = 1 }
  },
  {
    name = "toxic_doom_daze_fur_bag_01",
    img = "img/toxic_doom_daze_fur_bag_01.webp",
    label = "Doom Daze Szőrme Táska",
    text = "Hátra vehető Szőrme Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_doom_daze_fur_bag_01", count = 1 }
  },
  {
    name = "toxic_doom_daze_fur_bag_02",
    img = "img/toxic_doom_daze_fur_bag_02.webp",
    label = "Doom Daze Szőrme Táska 2",
    text = "Hátra vehető Szőrme Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_doom_daze_fur_bag_02", count = 1 }
  },
  {
    name = "toxic_doom_daze_fur_bag_03",
    img = "img/toxic_doom_daze_fur_bag_03.webp",
    label = "Doom Daze Szőrme Táska 3",
    text = "Hátra vehető Szőrme Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_doom_daze_fur_bag_03", count = 1 }
  },
  {
    name = "toxic_doom_daze_leather_bag_01",
    img = "img/toxic_doom_daze_leather_bag_01.webp",
    label = "Doom Daze Bőr Táska",
    text = "Hátra vehető Bőr Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_doom_daze_leather_bag_01", count = 1 }
  },
  {
    name = "toxic_doom_daze_leather_bag_02",
    img = "img/toxic_doom_daze_leather_bag_02.webp",
    label = "Doom Daze Bőr Táska 2",
    text = "Hátra vehető Bőr Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_doom_daze_leather_bag_02", count = 1 }
  },
  {
    name = "toxic_hearth_bag_01",
    img = "img/toxic_hearth_bag_01.webp",
    label = "Szív Táska",
    text = "Hátra vehető Szív Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_hearth_bag_01", count = 1 }
  },
  {
    name = "toxic_hearth_bag_02",
    img = "img/toxic_hearth_bag_02.webp",
    label = "Szív Táska 2",
    text = "Hátra vehető Szív Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_hearth_bag_02", count = 1 }
  },
  {
    name = "toxic_katana_bag_01",
    img = "img/toxic_katana_bag_01.webp",
    label = "Katana Táska",
    text = "Hátra vehető Katana Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_katana_bag_01", count = 1 }
  },
  {
    name = "toxic_minecraft_hearth_bag_01",
    img = "img/toxic_minecraft_hearth_bag_01.webp",
    label = "Minecraft Szív Táska",
    text = "Hátra vehető MinCraft Szív Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_minecraft_hearth_bag_01", count = 1 }
  },
  {
    name = "toxic_neon_shark_bag_01",
    img = "img/toxic_neon_shark_bag_01.webp",
    label = "Neon Cápa Táska",
    text = "Hátra vehető Neon Cápa Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_neon_shark_bag_01", count = 1 }
  },
  {
    name = "toxic_neon_shark_bag_02",
    img = "img/toxic_neon_shark_bag_02.webp",
    label = "Neon Cápa Táska 2",
    text = "Hátra vehető Neon Cápa Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_neon_shark_bag_02", count = 1 }
  },
  {
    name = "toxic_neon_shark_bag_03",
    img = "img/toxic_neon_shark_bag_03.webp",
    label = "Neon Cápa Táska 3",
    text = "Hátra vehető Neon Cápa Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_neon_shark_bag_03", count = 1 }
  },
  {
    name = "toxic_skateboard_bag_01",
    img = "img/toxic_skateboard_bag_01.webp",
    label = "Deszka Táska",
    text = "Hátra vehető Deszka Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_skateboard_bag_01", count = 1 }
  },
  {
    name = "toxic_skateboard_bag_02",
    img = "img/toxic_skateboard_bag_02.webp",
    label = "Deszka Táska 2",
    text = "Hátra vehető Deszka Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_skateboard_bag_02", count = 1 }
  },
  {
    name = "toxic_skateboard_bag_03",
    img = "img/toxic_skateboard_bag_03.webp",
    label = "Deszka Táska 3",
    text = "Hátra vehető Deszka Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_skateboard_bag_03", count = 1 }
  },
  {
    name = "toxic_skateboard_bag_04",
    img = "img/toxic_skateboard_bag_04.webp",
    label = "Deszka Táska 4",
    text = "Hátra vehető Deszka Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_skateboard_bag_04", count = 1 }
  },
  {
    name = "toxic_skateboard_bag_05",
    img = "img/toxic_skateboard_bag_05.webp",
    label = "Deszka Táska 5",
    text = "Hátra vehető Deszka Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_skateboard_bag_05", count = 1 }
  },
  {
    name = "toxic_skateboard_bag_06",
    img = "img/toxic_skateboard_bag_06.webp",
    label = "Deszka Táska 6",
    text = "Hátra vehető Deszka Táska változat.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_skateboard_bag_06", count = 1 }
  },
  {
    name = "toxic_spray_ground_bag_01",
    img = "img/toxic_spray_ground_bag_01.webp",
    label = "Spray Ground Táska",
    text = "Hátra vehető Spray Ground Táska.",
    price = 15000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_spray_ground_bag_01", count = 1 }
  },
  {
  name = "toxic_cat_bag_01",
  img = "img/toxic_cat_bag_01.webp",
  label = "Cat Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_cat_bag_01", count = 1 }
  },
  {
  name = "toxic_hello_kitty_bag_01",
  img = "img/toxic_hello_kitty_bag_01.webp",
  label = "HelloKitty Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_hello_kitty_bag_01", count = 1 }
  },
  {
  name = "toxic_tactical_bag_01",
  img = "img/toxic_tactical_bag_01.webp",
  label = "Tactical Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_tactical_bag_01", count = 1 }
  },
  {
  name = "toxic_watchdog_bag_01",
  img = "img/toxic_watchdog_bag_01.webp",
  label = "Watchdog Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_watchdog_bag_01", count = 1 }
  },
  {
  name = "toxic_dino_bag_01",
  img = "img/toxic_dino_bag_01.webp",
  label = "Dino Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_dino_bag_01", count = 1 }
  },
  {
  name = "toxic_mobidick_bag_01",
  img = "img/toxic_mobidick_bag_01.webp",
  label = "Mobidick Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_mobidick_bag_01", count = 1 }
  },
  {
  name = "toxic_pig_bag_01",
  img = "img/toxic_pig_bag_01.webp",
  label = "Malac Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_pig_bag_01", count = 1 }
  },
  {
  name = "toxic_skull_teddy_bag_01",
  img = "img/toxic_skull_teddy_bag_01.webp",
  label = "Skull Teddy Trash Táska",
  text = "Hátra vehető Táska.",
  price = 12500,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_skull_teddy_bag_01", count = 1 }
  },
  {
  name = "toxic_usahanna_bag_01",
  img = "img/toxic_usahanna_bag_01.webp",
  label = "Usahanna Trash Táska",
  text = "Hátra vehető Táska.",
  price = 10000,
  category = "taska",
  event = "villamos_pp:buyItem",
  data = { item = "toxic_usahanna_bag_01", count = 1 }
  },
  {
    name = "toxic_teddy_bag_01",
    img = "img/toxic_teddy_bag_01.webp",
    label = "Teddy Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_teddy_bag_01", count = 1 }
  },
  {
    name = "toxic_snorlax_bag_01",
    img = "img/toxic_snorlax_bag_01.webp",
    label = "Snorlax Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_snorlax_bag_01", count = 1 }
  },
  {
    name = "toxic_polar_bear_bag_01",
    img = "img/toxic_polar_bear_bag_01.webp",
    label = "Jegesmedve Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_polar_bear_bag_01", count = 1 }
  },
  {
    name = "toxic_mew_bag_01",
    img = "img/toxic_mew_bag_01.webp",
    label = "Mew Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_mew_bag_01", count = 1 }
  },
  {
    name = "toxic_kuma_bag_01",
    img = "img/toxic_kuma_bag_01.webp",
    label = "Kuma Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_kuma_bag_01", count = 1 }
  },
  {
    name = "toxic_gloomy_bear_bag_02",
    img = "img/toxic_gloomy_bear_bag_02.webp",
    label = "Gloomy Bear Trash 2 Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_gloomy_bear_bag_02", count = 1 }
  },
  {
    name = "toxic_gloomy_bear_bag_01",
    img = "img/toxic_gloomy_bear_bag_01.webp",
    label = "Gloomy Bear Trash 1 Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "toxic_gloomy_bear_bag_01", count = 1 }
  },
  {
    name = "hnganh_axolo1t",  --mindegyik különböző
    img = "img/hnganh_axolot.webp", --kép
    label = "Axolo1t Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_axolo1t", count = 1 }
  },
  {
    name = "hnganh_cowboy",  --mindegyik különböző
    img = "img/hnganh_cowboy.webp", --kép
    label = "Cowboy Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_cowboy", count = 1 }
  },
  {
    name = "hnganh_cutefeline",  --mindegyik különböző
    img = "img/hnganh_cutefeline.webp", --kép
    label = "Cutefeline Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_cutefeline", count = 1 }
  },
  {
    name = "hnganh_yellow",  --mindegyik különböző
    img = "img/hnganh_yellow.webp", --kép
    label = "Yellow Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_yellow", count = 1 }
  },
  {
    name = "hnganh_canhcutgs",  --mindegyik különböző
    img = "img/hnganh_canhcutgs.webp", --kép
    label = "Canhcutgs Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_canhcutgs", count = 1 }
  },
  {
    name = "hnganh_grinch",  --mindegyik különböző
    img = "img/hnganh_grinch.webp", --kép
    label = "Grinch Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_grinch", count = 1 }
  },
  {
    name = "hnganh_reindeer",  --mindegyik különböző
    img = "img/hnganh_reindeer.webp", --kép
    label = "Reindeer Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_reindeer", count = 1 }
  },
  {
    name = "hnganh_snowman",  --mindegyik különböző
    img = "img/hnganh_snowman.webp", --kép
    label = "Snowman Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_snowman", count = 1 }
  },
  {
    name = "hnganh_dachshund",  --mindegyik különböző
    img = "img/hnganh_dachshund.webp", --kép
    label = "Dachshund Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_dachshund", count = 1 }
  },
  {
    name = "hnganh_polarbear",  --mindegyik különböző
    img = "img/hnganh_polarbear.webp", --kép
    label = "Polarbear Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_polarbear", count = 1 }
  },
  {
    name = "hnganh_puppyv3",  --mindegyik különböző
    img = "img/hnganh_puppyv3.webp", --kép
    label = "PuppyV3 Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_puppyv3", count = 1 }
  },
  {
    name = "hnganh_sealbag",  --mindegyik különböző
    img = "img/hnganh_sealbag.webp", --kép
    label = "Sealbag Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_sealbag", count = 1 }
  },
  {
    name = "hnganh_squirrel",  --mindegyik különböző
    img = "img/hnganh_squirrel.webp", --kép
    label = "Squirrel Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_squirrel", count = 1 }
  },
  {
    name = "hnganh_walle",  --mindegyik különböző
    img = "img/hnganh_walle.webp", --kép
    label = "Vándor Táska (2) Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_walle", count = 1 }
  },
  {
    name = "hnganh_naughty",  --mindegyik különböző
    img = "img/hnganh_naughty.webp", --kép
    label = "Naughty Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_naughty", count = 1 }
  },
  {
    name = "hnganh_politoed",  --mindegyik különböző
    img = "img/hnganh_politoed.webp", --kép
    label = "Politoed Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_politoed", count = 1 }
  },
  {
    name = "hnganh_toddler",  --mindegyik különböző
    img = "img/hnganh_toddler.webp", --kép
    label = "Toddler Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_toddler", count = 1 }
  },
  {
    name = "hnganh_bee2",  --mindegyik különböző
    img = "img/hnganh_bee2.webp", --kép
    label = "Bee Trash Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_bee2", count = 1 }
  },
  {
    name = "hnganh_magickitty",  --mindegyik különböző
    img = "img/hnganh_magickitty.webp", --kép
    label = "Magic Kitty Táska",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_magickitty", count = 1 }
  },
  {
    name = "hnganh_stichv2",  --mindegyik különböző
    img = "img/hnganh_stichv2.webp", --kép
    label = "Vándor Táska (1) Trash",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_stichv2", count = 1 }
  },
  {
    name = "hnganh_scooby",  --mindegyik különböző
    img = "img/hnganh_scooby.webp", --kép
    label = "Vándor Táska (3) Trash",
    text = "Hátra vehető Táska.",
    price = 10000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_scooby", count = 1 }
  },
  {
    name = "hnganh_puppysssv3",  --mindegyik különböző
    img = "img/puppystrash.webp", --kép
    label = "Vándor Táska (4) Trash",
    text = "Hátra vehető Táska.",
    price = 7000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_puppysssv3", count = 1 }
  },
  {
    name = "hnganh_anya",  --mindegyik különböző
    img = "img/hnganh_anya.webp", --kép
    label = "Anya Trash Táska",
    text = "Hátra vehető Táska.",
    price = 7000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_anya", count = 1 }
  },
  {
    name = "hnganh_bagdino",  --mindegyik különböző
    img = "img/hnganh_bagdino.webp", --kép
    label = "Bagdino Trash Táska",
    text = "Hátra vehető Táska.",
    price = 7000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_bagdino", count = 1 }
  },
  {
    name = "hnganh_bmo",  --mindegyik különböző
    img = "img/hnganh_bmo.webp", --kép
    label = "Bmo Trash Táska",
    text = "Hátra vehető Táska.",
    price = 7000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_bmo", count = 1 }
  },
  {
    name = "hnganh_goose",      --mindegyik különböző
    img = "img/goosetrash.webp", --kép
    label = "Goose Trash Táska",
    text = "Hátra vehető Táska.",
    price = 7000,
    category = "taska",
    event = "villamos_pp:buyItem",
    data = { item = "hnganh_goose", count = 1 }
  },
  {
    name = "monky",        --mindegyik különböző
    img = "img/monky.webp", --kép
    label = "Monky Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "monky", count = 1 }
  },
  {
    name = "fox",        --mindegyik különböző
    img = "img/fox.webp", --kép
    label = "Fox Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "fox", count = 1 }
  },
  {
    name = "questing_mouse",       --mindegyik különböző
    img = "img/questingmouse.webp", --kép
    label = "Questing Mouse Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "questing_mouse", count = 1 }
  },
  {
    name = "armored_cat",       --mindegyik különböző
    img = "img/armoredcat.webp", --kép
    label = "Armored Cat Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "armored_cat", count = 1 }
  },
  {
    name = "hollow_knight",       --mindegyik különböző
    img = "img/hollowknight.webp", --kép
    label = "Hollow Knight Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "hollow_knight", count = 1 }
  },
  {
    name = "knight_cat",       --mindegyik különböző
    img = "img/knightcat.webp", --kép
    label = "Knight Cat Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "knight_cat", count = 1 }
  },
  {
    name = "dino",        --mindegyik különböző
    img = "img/dino.webp", --kép
    label = "Dino Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "dino", count = 1 }
  },
  {
    name = "dino_student",        --mindegyik különböző
    img = "img/dino_student.webp", --kép
    label = "Dino Student Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "dino_student", count = 1 }
  },
  {
    name = "pig_angel",       --mindegyik különböző
    img = "img/pigangel.webp", --kép
    label = "Pig Angel Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pig_angel", count = 1 }
  },
  {
    name = "mickey_mouse",       --mindegyik különböző
    img = "img/mickeymouse.webp", --kép
    label = "Mickey Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "mickey_mouse", count = 1 }
  },
  {
    name = "blossom",        --mindegyik különböző
    img = "img/blossom.webp", --kép
    label = "Blossom Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "blossom", count = 1 }
  },
  {
    name = "buttercup",        --mindegyik különböző
    img = "img/buttercup.webp", --kép
    label = "Buttercup Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "buttercup", count = 1 }
  },
  {
    name = "bubbles",        --mindegyik különböző
    img = "img/bubbles.webp", --kép
    label = "Bubbles Pet",
    text = "Válra vehető kisháziállat.",
    price = 5000,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "bubbles", count = 1 }
  },
  {
    name = "pet_bunny",        --mindegyik különböző
    img = "img/pet_bunny.webp", --kép
    label = "Nyuszi Pet",
    text = "Masnis plüssnyuszi, csupa fül és jókedv.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_bunny", count = 1 }
  },
  {
    name = "pet_bunnypop",        --mindegyik különböző
    img = "img/pet_bunnypop.webp", --kép
    label = "Nyuszi Pop Pet",
    text = "Kertésznadrágos nyuszi egy szál répával. A répa nem alku tárgya.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_bunnypop", count = 1 }
  },
  {
    name = "pet_catcute",        --mindegyik különböző
    img = "img/pet_catcute.webp", --kép
    label = "Cuki Cica Pet",
    text = "Pizsamás cica, aki bárhol elalszik.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_catcute", count = 1 }
  },
  {
    name = "pet_cat1",        --mindegyik különböző
    img = "img/pet_cat1.webp", --kép
    label = "Cica 1 Pet",
    text = "Hópárduc kölyök. Csendes, de mindent figyel.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_cat1", count = 1 }
  },
  {
    name = "pet_cat2",        --mindegyik különböző
    img = "img/pet_cat2.webp", --kép
    label = "Cica 2 Pet",
    text = "Szürke kiscica, nagy szemekkel bámulja a világot.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_cat2", count = 1 }
  },
  {
    name = "pet_cat3",        --mindegyik különböző
    img = "img/pet_cat3.webp", --kép
    label = "Cica 3 Pet",
    text = "Sötét bundás, szárnyas cica. Éjszaka is ébren van.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_cat3", count = 1 }
  },
  {
    name = "pet_chefdog",        --mindegyik különböző
    img = "img/pet_chefdog.webp", --kép
    label = "Szakács Kutya Pet",
    text = "Szakácssapkás kutyus. Minden ételszagra megfordul.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_chefdog", count = 1 }
  },
  {
    name = "pet_demongoat",        --mindegyik különböző
    img = "img/pet_demongoat.webp", --kép
    label = "Démon Kecske Pet",
    text = "Vörös szemű démonkecske. Jobb, ha nem nézel a szemébe.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_demongoat", count = 1 }
  },
  {
    name = "pet_dragon",        --mindegyik különböző
    img = "img/pet_dragon.webp", --kép
    label = "Sárkány Pet",
    text = "Lila kissárkány. Még csak füstöl, tüzet nem okád.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_dragon", count = 1 }
  },
  {
    name = "pet_kitsune",        --mindegyik különböző
    img = "img/pet_kitsune.webp", --kép
    label = "Kitsune Róka Pet",
    text = "Csöngős nyakörves rókaszellem, mini kiadásban.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_kitsune", count = 1 }
  },
  {
    name = "pet_mollie",        --mindegyik különböző
    img = "img/pet_mollie.webp", --kép
    label = "Mollie Pet",
    text = "Vámpírgalléros cica. Éjszakai műszakban dolgozik.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_mollie", count = 1 }
  },
  {
    name = "pet_monkey",        --mindegyik különböző
    img = "img/pet_monkey.webp", --kép
    label = "Majom Pet",
    text = "Kismajom banánnal. Ne hagyd őrizetlenül a zsebedet.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_monkey", count = 1 }
  },
  {
    name = "pet_mummies",        --mindegyik különböző
    img = "img/pet_mummies.webp", --kép
    label = "Múmia Pet",
    text = "Bepólyált kis múmia. Több ezer éves, mégis jókedvű.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_mummies", count = 1 }
  },
  {
    name = "pet_otter",        --mindegyik különböző
    img = "img/pet_otter.webp", --kép
    label = "Vidra Pet",
    text = "Barna vidra. Imád mindent a mancsában forgatni.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_otter", count = 1 }
  },
  {
    name = "pet_panda",        --mindegyik különböző
    img = "img/pet_panda.webp", --kép
    label = "Panda Pet",
    text = "Panda egy szál bambusszal. Eszik, alszik, ismétel.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_panda", count = 1 }
  },
  {
    name = "pet_penguin",        --mindegyik különböző
    img = "img/pet_penguin.webp", --kép
    label = "Pingvin Pet",
    text = "Sísapkás pingvin. A hideget bírja, a meleget nem.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_penguin", count = 1 }
  },
  {
    name = "pet_pumpkinmonster",        --mindegyik különböző
    img = "img/pet_pumpkinmonster.webp", --kép
    label = "Tökszörny Pet",
    text = "Tökfejű kis szörny. Halloween óta nem hajlandó hazamenni.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_pumpkinmonster", count = 1 }
  },
  {
    name = "pet_shark",        --mindegyik különböző
    img = "img/pet_shark.webp", --kép
    label = "Cápa Pet",
    text = "Cápajelmezes plüss. Sokkal veszélyesebbnek hiszi magát.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_shark", count = 1 }
  },
  {
    name = "pet_skeletons",        --mindegyik különböző
    img = "img/pet_skeletons.webp", --kép
    label = "Csontváz Pet",
    text = "Táncoló csontváz. Csontig ható humorérzékkel.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_skeletons", count = 1 }
  },
  {
    name = "pet_strawberry",        --mindegyik különböző
    img = "img/pet_strawberry.webp", --kép
    label = "Eper Szörny Pet",
    text = "Eperjelmezes kis szörny. Édesebb, mint amilyennek látszik.",
    price = 6500,
    category = "pet",
    event = "villamos_pp:buyItem",
    data = { item = "pet_strawberry", count = 1 }
  },
  {
    name = "ujmedikit",        --mindegyik különböző
    img = "img/ujmedikit.webp", --kép
    label = "Mentőkészlet",
    text = "Mentőkészlet",
    price = 800,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "ujmedikit", count = 1 }
  },
  {
    name = "aranysepru",        --mindegyik különböző
    img = "img/aranysepru.webp", --kép
    label = "Aranyseprű",
    text = "Ha van rajtad közmunka és ezt megvásárolod 50-től megszabadulsz",
    price = 2000,
    category = "egyeb",
    event = "villamos_pp:aranysepru",
    data = {}
  },
  {
    name = "keslada",        --mindegyik különböző
    img = "img/keslada.webp", --kép
    label = "CS Kés láda",
    text = "1.000 PP",
    price = 1000,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "keslada", count = 1 }
  },
  {
    name = "pfegyverlada",        --mindegyik különböző
    img = "img/pfegyverlada.webp", --kép
    label = "Pérmium Fegyverláda",
    text = "Ez egy Prémium pisztolyláda, 11 darabos. 300 méterig lő el – a legjobb választás!",
    price = 1650,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "pfegyverlada", count = 1 }
  },
  {
    name = "bennystaska",        --mindegyik különböző
    img = "img/bennystaska.webp", --kép
    label = "Táska láda",
    text = "Ez a láda rengeteg táskát tartalmaz. Vegyél egyet, és nyiss egy értékes vagy akár egy értéktelen táskát!",
    price = 7000,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "bennystaska", count = 1 }
  },
  {
    name = "fegyverlada",        --mindegyik különböző
    img = "img/fegyverlada.webp", --kép
    label = "Fegyverláda",
    text = "Ebben a ládában különféle sima fegyverek találhatók. Próbálj szerencsét, és szerezz meg egy értékes fegyvert!",
    price = 1500,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "fegyverlada", count = 1 }
  },
  {
    name = "autolada",        --mindegyik különböző
    img = "img/autolada.webp", --kép
    label = "Autóláda",
    text = "Ebben a ládában különféle olcsóbb kategóriás járművek találhatók. Nyisd ki, és szerezz egy autót a gyűjteményedbe!",
    price = 5000,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "autolada", count = 1 }
  },
  {
    name = "autolada2",        --mindegyik különböző
    img = "img/autolada2.webp", --kép
    label = "Autóláda Prémium2",
    text = "Ebben a kiemelt autóládában 10.000 feletti értékű járművek találhatók. Próbálj szerencsét, és szerezz egy igazán különleges autót!",
    price = 11000,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "autolada2", count = 1 }
  },
  --[[{
    name = "csgocase",        --mindegyik különböző
    img = "img/csgocase.webp", --kép
    label = "Fegyverláda",
    text = "1.500 PP",
    price = 0,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "csgocase", count = 1 }
  },
  {
    name = "csgocase2",       --mindegyik különböző
    img = "img/csgocase.webp", --kép
    label = "Autóláda",
    text = "5.000 PP",
    price = 0,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "csgocase2", count = 1 }
  },
  {
    name = "csgocase3",       --mindegyik különböző
    img = "img/csgocase.webp", --kép
    label = "Autóláda kiemelt (10.000 feletti autók)",
    text = "11.000 PP",
    price = 0,
    category = "lada",
    event = "villamos_pp:buyItem",
    data = { item = "csgocase3", count = 1 }
  },--]]

  {
    name = "pctp",        --mindegyik különböző
    img = "img/pctp.webp", --kép
    label = "PC 2016 (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 40000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "pctp" }
  },
  {
    name = "ikx3speed22nob",        --mindegyik különböző
    img = "img/ikx3speed22nob.webp", --kép
    label = "BC Speed 2022 (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 40000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ikx3speed22nob" }
  },
  {
    name = "ikx3model",        --mindegyik különböző
    img = "img/ikx3model.webp", --kép
    label = "TM S (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 40000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ikx3model" }
  },
  {
    name = "ikx3abt20",        --mindegyik különböző
    img = "img/ikx3abt20.webp", --kép
    label = "AAR 2020 (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 40000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ikx3abt20" }
  },
  {
    name = "rs4avant",        --mindegyik különböző
    img = "img/rs4avant.webp", --kép
    label = "ARA (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rs4avant" }
  },
  {
    name = "centslyrs4",        --mindegyik különböző
    img = "img/centslyrs4.webp", --kép
    label = "AR4 (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "centslyrs4" }
  },
  {
    name = "ray",        --mindegyik különböző
    img = "img/ray.webp", --kép
    label = "C C8",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ray" }
  },
  {
    name = "404_suprawb",        --mindegyik különböző
    img = "img/404_suprawb.webp", --kép
    label = "TSM5 (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "404_suprawb" }
  },
  {
    name = "thettrs20",        --mindegyik különböző
    img = "img/thettrs20.webp", --kép
    label = "2018 ATRS (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "thettrs20" }
  },
  {
    name = "ikx3bgt3",        --mindegyik különböző
    img = "img/ikx3bgt3.webp", --kép
    label = "2021 BCG3",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ikx3bgt3" }
  },
  {
    name = "ram226x6",        --mindegyik különböző
    img = "img/ram226x6.webp", --kép
    label = "DRT6 2020 (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 19000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ram226x6" }
  },
  {
    name = "lambobarbie",        --mindegyik különböző
    img = "img/lambobarbie.webp", --kép
    label = "LGB (Az autón dinamic lights található, matrica levehető)",
    text = "PP-s autó",
    price = 19000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "lambobarbie" }
  },
  {
    name = "renegadetrax",        --mindegyik különböző
    img = "img/renegadetrax.webp", --kép
    label = "GODZQUAD",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "renegadetrax" }
  },
  {
    name = "benefacgt",        --mindegyik különböző
    img = "img/benefacgt.webp", --kép
    label = "BGT (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "benefacgt" }
  },
  {
    name = "g650barbie",        --mindegyik különböző
    img = "img/g650barbie.webp", --kép
    label = "MBGB6 (Az autón egyedi hang és dinamic lights található, matrica levehető)",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "g650barbie" }
  },
  {
    name = "tdbhummer",        --mindegyik különböző
    img = "img/tdbhummer.webp", --kép
    label = "H EV",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "tdbhummer" }
  },
  {
    name = "dodge68",        --mindegyik különböző
    img = "img/dodge68.webp", --kép
    label = "DC 1968",
    text = "PP-s autó",
    price = 18000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "dodge68" }
  },
  {
    name = "gsttac1",        --mindegyik különböző
    img = "img/gsttac1.webp", --kép
    label = "TTP 2024 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "gsttac1" }
  },
  {
    name = "23teslapf",        --mindegyik különböző
    img = "img/23teslapf.webp", --kép
    label = "TM Y 2023",
    text = "PP-s autó",
    price = 16000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "23teslapf" }
  },
 -- {
 --   name = "dre2jze30",        --mindegyik különböző
 --   img = "img/dre2jze30.webp", --kép
 --   label = "BMW M3 E30 Custom (Az autón egyedi hang található)",
 --   text = "PP-s autó",
 --   price = 19000,
 --   event = "villamos_pp:buyCar",
 --   data = { model = "dre2jze30" }
 -- },
  {
    name = "bs900convertible",        --mindegyik különböző
    img = "img/bs900convertible.webp", --kép
    label = "BSC (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 28000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "bs900convertible" }
  },
  {
    name = "rmod240sx",        --mindegyik különböző
    img = "img/rmod240sx.webp", --kép
    label = "N 240SX (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rmod240sx" }
  },
  {
    name = "m3ven",        --mindegyik különböző
    img = "img/m3ven.webp", --kép
    label = "BMV Touring",
    text = "PP-s autó",
    price = 25000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "m3ven" }
  },
  {
    name = "MH8GCP",        --mindegyik különböző
    img = "img/MH8GCP.webp", --kép
    label = "BMMG Cupe (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 33000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "MH8GCP" }
  },
  {
    name = "nba4",        --mindegyik különböző
    img = "img/nba4.webp", --kép
    label = "AAA4 2020 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 26000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "nba4" }
  },
  {
    name = "mk1rabbit",        --mindegyik különböző
    img = "img/mk1rabbit.webp", --kép
    label = "VGM (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 16000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "mk1rabbit" }
  },
  {
    name = "sou_23s63",        --mindegyik különböző
    img = "img/sou_23s63.webp", --kép
    label = "BSA63 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 22000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "sou_23s63" }
  },
  {
    name = "80020",        --mindegyik különböző
    img = "img/80020.webp", --kép
    label = "BGR 900 2022 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 28000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "80020" }
  },
  {
    name = "PriorRSQ3",        --mindegyik különböző
    img = "img/PriorRSQ3.webp", --kép
    label = "ARPQ3 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "PriorRSQ3" }
  },
  {
    name = "nm_190evo",        --mindegyik különböző
    img = "img/nm_190evo.webp", --kép
    label = "MB190 (Az autó rendőrségi jelöletlen autó, rendőrök számára elérhető!)",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "nm_190evo" }
  },
  {
    name = "Domyah_TiffanyRange",        --mindegyik különböző
    img = "img/Domyah_TiffanyRange.webp", --kép
    label = "2024 RRM (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "Domyah_TiffanyRange" }
  },
  {
    name = "cuprabkt",        --mindegyik különböző
    img = "img/cuprabkt.webp", --kép
    label = "CLW (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "cuprabkt" }
  },
  {
    name = "16m3f80",        --mindegyik különböző
    img = "img/16m3f80.webp", --kép
    label = "BM3f80 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "16m3f80" }
  },
  {
    name = "slsblackseries",        --mindegyik különböző
    img = "img/slsblackseries.webp", --kép
    label = "MBLSAM (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "slsblackseries" }
  },
  {
    name = "gmchycade",        --mindegyik különböző
    img = "img/gmchycade.webp", --kép
    label = "GS (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "gmchycade" }
  },
  {
    name = "evcs65",        --mindegyik különböző
    img = "img/evcs65.webp", --kép
    label = "MB65AM (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "evcs65" }
  },
  {
    name = "rmodc63amg",        --mindegyik különböző
    img = "img/rmodc63amg.webp", --kép
    label = "MBCA63 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rmodc63amg" }
  },
  {
    name = "m5e60",        --mindegyik különböző
    img = "img/m5e60.webp", --kép
    label = "BM5 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "m5e60" }
  },
  {
    name = "e92lb",        --mindegyik különböző
    img = "img/e92lb.webp", --kép
    label = "BM392 Libertywak",
    text = "PP-s autó",
    price = 30000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "e92lb" }
  },
  {
    name = "ApertaDRCustoM",        --mindegyik különböző
    img = "img/ApertaDRCustoM.webp", --kép
    label = "FLAW (Egyedi Hang)",
    text = "PP-s autó",
    price = 28000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ApertaDRCustoM" }
  },
  {
    name = "rs5mafia",        --mindegyik különböző
    img = "img/rs5mafia.webp", --kép
    label = "ARSW(egyedi hang)",
    text = "PP-s autó",
    price = 25000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rs5mafia" }
  },
  {
    name = "zent765",        --mindegyik különböző
    img = "img/zent765.webp", --kép
    label = "mm765",
    text = "PP-s autó",
    price = 25000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "zent765" }
  },
  {
    name = "supervolito",        --mindegyik különböző
    img = "img/supervolito.webp", --kép
    label = "Supervolito Carbon",
    text = "PP-s autó",
    price = 25000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "supervolito" }
  },
  {
    name = "f430",        --mindegyik különböző
    img = "img/f430.webp", --kép
    label = "FF430 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 25000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "f430" }
  },
  {
    name = "fpaceprior",        --mindegyik különböző
    img = "img/fpaceprior.webp", --kép
    label = "JFPP Edition (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 25000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "fpaceprior" }
  },
  {
    name = "RS322sedanCarbont",        --mindegyik különböző
    img = "img/RS322sedanCarbont.webp", --kép
    label = "ARS63 (Az autón egyedi hang található)",
    text = "PP-s autó",
    price = 25000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "RS322sedanCarbont" }
  },

--[[  {
    name = "m3e30",        --mindegyik különböző
    img = "img/m3e30.webp", --kép
    label = "BMW M3 E30",
    text = "PP-s autó",
    price = 25000,
    event = "villamos_pp:buyCar",
    data = { model = "m3e30" }
  },--]]
  {
    name = "S500",        --mindegyik különböző
    img = "img/S500.webp", --kép
    label = "MB S500",
    text = "PP-s autó",
    price = 25000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "S500" }
  },
  {
    name = "gstzl1cade1",        --mindegyik különböző
    img = "img/gstzl1cade1.webp", --kép
    label = "2018 CC ZL1 (Az autón egyedi hang található.)",
    text = "PP-s autó",
    price = 23000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "gstzl1cade1" }
  },
  {
    name = "GODz22LIGHTNINGWB",        --mindegyik különböző
    img = "img/GODz22LIGHTNINGWB.webp", --kép
    label = "FPL (egyedi hang)",
    text = "PP-s autó",
    price = 23000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "GODz22LIGHTNINGWB" }
  },
  {
    name = "cl65",        --mindegyik különböző
    img = "img/cl65.webp", --kép
    label = "MB65AM [Animated Light]",
    text = "PP-s autó",
    price = 23000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "cl65" }
  },
  {
    name = "hycadensx",        --mindegyik különböző
    img = "img/hycadensx.webp", --kép
    label = "HNH",
    text = "PP-s autó",
    price = 22000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "hycadensx" }
  },
  {
    name = "maverick",        --mindegyik különböző
    img = "img/maverick.webp", --kép
    label = "Maverick",
    text = "PP-s autó",
    price = 22000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "maverick" }
  },
  {
    name = "BMWI4GC",               --mindegyik különböző
    img = "img/BMWI4GC.webp", --kép
    label = "2022 BIGC (Elektromos)",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "BMWI4GC" }
  },
  {
    name = "ugc13gt",               --mindegyik különböző
    img = "img/ugc13gt.webp", --kép
    label = "MGR",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ugc13gt" }
  },
  {
    name = "m3sh",        --mindegyik különböző
    img = "img/m3sh.webp", --kép
    label = "BM3W",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "m3sh" }
  },
  {
    name = "cis_e63w214",        --mindegyik különböző
    img = "img/cis_e63w214.webp", --kép
    label = "MW214",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "cis_e63w214" }
  },
  {
    name = "lcdefender",        --mindegyik különböző
    img = "img/lcdefender.webp", --kép
    label = "LRUB",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "lcdefender" }
  },
  {
    name = "lfa",        --mindegyik különböző
    img = "img/lfa.webp", --kép
    label = "LLFA",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "lfa" }
  },
  {
    name = "huracantecnica",        --mindegyik különböző
    img = "img/huracantecnica.webp", --kép
    label = "LHT",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "huracantecnica" }
  },
  {
    name = "fbm52016touring",        --mindegyik különböző
    img = "img/fbm52016touring.webp", --kép
    label = "bm5f10",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "fbm52016touring" }
  },
  {
    name = "senna",        --mindegyik különböző
    img = "img/senna.webp", --kép
    label = "MCSS",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "senna" }
  },
  {
    name = "e60",        --mindegyik különböző
    img = "img/e60.webp", --kép
    label = "BME60",
    text = "PP-s autó",
    price = 20000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "e60" }
  },
  {
    name = "20chevyhigh",        --mindegyik különböző
    img = "img/20chevyhigh.webp", --kép
    label = "CL (egyedi hang)",
    text = "PP-s autó",
    price = 19000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "20chevyhigh" }
  },
  {
    name = "insurgent2",        --mindegyik különböző
    img = "img/insurgent2.webp", --kép
    label = "Insurgent Páncélozott autó",
    text = "PP-s autó",
    price = 19000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "insurgent2" }
  },
  {
    name = "masgranturfe",        --mindegyik különböző
    img = "img/masgranturfe.webp", --kép
    label = "MG S",
    text = "PP-s autó",
    price = 19000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "masgranturfe" }
  },
  {
    name = "cls19",
    img = "img/cls19.webp",
    label = "MBCA",
    text = "PP-s autó",
    price = 18500,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "cls19" }
  },
  {
    name = "b800",
    img = "img/b800.webp",
    label = "MBB63",
    text = "PP-s autó",
    price = 18500,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "b800" }
  },
  {
    name = "fraptor",
    img = "img/fraptor.webp",
    label = "FF150 2012",
    text = "PP-s autó",
    price = 18000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "fraptor" }
  },
  {
    name = "rmodrs6r",
    img = "img/rmodrs6r.webp",
    label = "AR Avant",
    text = "PP-s autó",
    price = 18000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rmodrs6r" }
  },
  {
    name = "s63mansory18",
    img = "img/s63mansory18.webp",
    label = "MBW222M",
    text = "PP-s autó",
    price = 18000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "s63mansory18" }
  },
  {
    name = "ftype15",               --mindegyik különböző
    img = "img/ftype15.webp", --kép
    label = "JF Type R",
    text = "PP-s autó",
    price = 17000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ftype15" }
  },
  {
    name = "s60",
    img = "img/s60.webp",
    label = "VS60BlackEdition",
    text = "PP-s autó",
    price = 17000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "s60" }
  },
  {
    name = "M422",
    img = "img/M422.webp",
    label = "M4s",
    text = "PP-s autó",
    price = 17000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "M422" }
  },
  {
    name = "E500",
    img = "img/E500.webp",
    label = "MB E50 (Egyedi Hang)",
    text = "PP-s autó",
    price = 16000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "E500" }
  },
  {
    name = "rmodjeep",
    img = "img/rmodjeep.webp",
    label = "JGC",
    text = "PP-s autó",
    price = 16000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rmodjeep" }
  },
  {
    name = "idx",
    img = "img/idx.webp",
    label = "V ID4",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "idx" }
  },
  {
    name = "sultanrs2",
    img = "img/sultanrs2.webp",
    label = "SRSWidebody",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "sultanrs2" }
  },
  {
    name = "zrgpr",
    img = "img/zrgpr.webp",
    label = "A gpr",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "zrgpr" }
  },
  {
    name = "c63wagon",
    img = "img/c63wagon.webp",
    label = "MCAMWagon",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "c63wagon" }
  },
  {
    name = "911t4s",
    img = "img/911t4s.webp",
    label = "P911T4S",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "911t4s" }
  },
  {
    name = "4x4range",
    img = "img/4x4range.webp",
    label = "RREC44",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "4x4range" }
  },
  {
    name = "m4cg83",
    img = "img/m4cg83.webp",
    label = "BM4G",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "m4cg83" }
  },
  {
    name = "contss18c",
    img = "img/contss18c.webp",
    label = "BCGT",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "contss18c" }
  },
  {
    name = "rs7abt",
    img = "img/rs7abt.webp",
    label = "ARABT",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rs7abt" }
  },
  {
    name = "rocket",        --mindegyik különböző
    img = "img/rocket.webp", --kép
    label = "BR900",
    text = "PP-s autó",
    price = 15000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rocket" }
  },
  {
    name = "pts21",        --mindegyik különböző
    img = "img/pts21.webp", --kép
    label = "P911",
    text = "PP-s autó",
    price = 14000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "pts21" }
  },
  {
    name = "africat",        --mindegyik különböző
    img = "img/africat.webp", --kép
    label = "2017 HCA",
    text = "PP-s autó",
    price = 13000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "africat" }
  },
  {
    name = "rd",        --mindegyik különböző
    img = "img/rd.webp", --kép
    label = "HD",
    text = "PP-s autó",
    price = 13000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rd" }
  },
  {
    name = "diavel",        --mindegyik különböző
    img = "img/diavel.webp", --kép
    label = "DDC",
    text = "PP-s autó",
    price = 13000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "diavel" }
  },
  {
    name = "adv1502023",        --mindegyik különböző
    img = "img/adv1502023.webp", --kép
    label = "HA 150 2023",
    text = "PP-s autó",
    price = 10000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "adv1502023" }
  },
  {
    name = "gcstinger",        --mindegyik különböző
    img = "img/gcstinger.webp", --kép
    label = "KGW",
    text = "PP-s autó",
    price = 13000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "gcstinger" }
  },
  {
    name = "cls17",        --mindegyik különböző
    img = "img/cls17.webp", --kép
    label = "MC17",
    text = "PP-s autó",
    price = 12500,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "cls17" }
  },
  {
    name = "rmodf40",        --mindegyik különböző
    img = "img/rmodf40.webp", --kép
    label = "FF40",
    text = "PP-s autó",
    price = 11000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rmodf40" }
  },
  {
    name = "tampa3",        --mindegyik különböző
    img = "img/tampa3.webp", --kép
    label = "TED",
    text = "PP-s autó",
    price = 11000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "tampa3" }
  },
  {
    name = "fc13",        --mindegyik különböző
    img = "img/fc13.webp", --kép
    label = "FC",
    text = "PP-s autó",
    price = 11000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "fc13" }
  },
  {
    name = "darkfate",        --mindegyik különböző
    img = "img/darkfate.webp", --kép
    label = "MD",
    text = "PP-s autó",
    price = 10000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "darkfate" }
  },
  {
    name = "porrs73",        --mindegyik különböző
    img = "img/porrs73.webp", --kép
    label = "P1973",
    text = "PP-s autó",
    price = 10000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "porrs73" }
  },
  {
    name = "srt8",        --mindegyik különböző
    img = "img/srt8.webp", --kép
    label = "JGC",
    text = "PP-s autó",
    price = 11000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "srt8" }
  },
  {
    name = "s8d2",        --mindegyik különböző
    img = "img/s8d2.webp", --kép
    label = "AS8",
    text = "PP-s autó",
    price = 10000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "s8d2" }
  },
  {
    name = "g5502019",        --mindegyik különböző
    img = "img/g5502019.webp", --kép
    label = "MBG550",
    text = "PP-s autó",
    price = 10000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "g5502019" }
  },
  {
    name = "f12ber",        --mindegyik különböző
    img = "img/f12ber.webp", --kép
    label = "FF12",
    text = "PP-s autó",
    price = 10000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "f12ber" }
  },
  {
    name = "jeep392",        --mindegyik különböző
    img = "img/jeep392.webp", --kép
    label = "JW",
    text = "PP-s autó",
    price = 7500,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "jeep392" }
  },
  {
    name = "ek9",        --mindegyik különböző
    img = "img/ek9.webp", --kép
    label = "HC",
    text = "PP-s autó",
    price = 7000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "ek9" }
  },
  {
    name = "s63amg18",        --mindegyik különböző
    img = "img/s63amg18.webp", --kép
    label = "MSS63AM",
    text = "PP-s autó",
    price = 6000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "s63amg18" }
  },
  {
    name = "dawn",        --mindegyik különböző
    img = "img/dawn.webp", --kép
    label = "RRD",
    text = "PP-s autó",
    price = 6000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "dawn" }
  }, {
  name = "brabus700",        --mindegyik különböző
  img = "img/brabus700.webp", --kép
  label = "B7004.066",
  text = "PP-s autó",
  price = 6000,
  category = "car",
  event = "villamos_pp:buyCar",
  data = { model = "brabus700" }
},
  {
    name = "RAPTOR150",        --mindegyik különböző
    img = "img/RAPTOR150.webp", --kép
    label = "FR 150",
    text = "PP-s autó",
    price = 6000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "RAPTOR150" }
  },
  {
    name = "lowriderb",        --mindegyik különböző
    img = "img/lowriderb.webp", --kép
    label = "LRB",
    text = "PP-s autó",
    price = 5000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "lowriderb" }
  },
  {
    name = "MTBZaiko",        --mindegyik különböző
    img = "img/MTBZaiko.webp", --kép
    label = "ZMTB",
    text = "PP-s autó",
    price = 5000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "MTBZaiko" }
  },
  {
    name = "smc690",        --mindegyik különböző
    img = "img/smc690.webp", --kép
    label = "KS 690",
    text = "PP-s autó",
    price = 4500,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "smc690" }
  },
  {
    name = "rmodm5e34",        --mindegyik különböző
    img = "img/rmodm5e34.webp", --kép
    label = "BM5E34",
    text = "PP-s autó",
    price = 4000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "rmodm5e34" }
  },
  {
    name = "FOXHARLEY1",        --mindegyik különböző
    img = "img/FOXHARLEY1.webp", --kép
    label = "HDFox 1",
    text = "PP-s autó",
    price = 4000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "FOXHARLEY1" }
  },
  {
    name = "fatboy",        --mindegyik különböző
    img = "img/fatboy.webp", --kép
    label = "HDF (Terminátor)",
    text = "PP-s autó",
    price = 4000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "fatboy" }
  },
  {
    name = "niva",        --mindegyik különböző
    img = "img/niva.webp", --kép
    label = "LNiva",
    text = "PP-s autó",
    price = 10000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "niva" }
  },
  {
    name = "springer",        --mindegyik különböző
    img = "img/springer.webp", --kép
    label = "HDFXSTS Springer",
    text = "PP-s autó",
    price = 4000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "springer" }
  },
  {
    name = "crawler",        --mindegyik különböző
    img = "img/crawler.webp", --kép
    label = "JC Terepjáró",
    text = "PP-s autó",
    price = 3000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "crawler" }
  },
  {
    name = "e36gda",        --mindegyik különböző
    img = "img/e36gda.webp", --kép
    label = "BME36",
    text = "PP-s autó",
    price = 3000,
    category = "car",
    event = "villamos_pp:buyCar",
    data = { model = "e36gda" }
  },
  {
  name = "demon",        --mindegyik különböző
  img = "img/demon.webp", --kép
  label = "DD",
  text = "PP-s autó",
  price = 3000,
  category = "car",
  event = "villamos_pp:buyCar",
  data = { model = "demon" }
},
{
  name = "rmodmk7",        --mindegyik különböző
  img = "img/rmodmk7.webp", --kép
  label = "GMK7RS",
  text = "PP-s autó",
  price = 3000,
  category = "car",
  event = "villamos_pp:buyCar",
  data = { model = "rmodmk7" }
}, 
{
  name = "s1000drag",        --mindegyik különböző
  img = "img/s1000drag.webp", --kép
  label = "BS1000Drag",
  text = "PP-s autó",
  price = 2000,
  category = "car",
  event = "villamos_pp:buyCar",
  data = { model = "s1000drag" }
}, 
{
  name = "nh2r",        --mindegyik különböző
  img = "img/nh2r.webp", --kép
  label = "KN",
  text = "PP-s autó",
  price = 2000,
  category = "car",
  event = "villamos_pp:buyCar",
  data = { model = "nh2r" }
},
  {
    name = "contract2",        --mindegyik különböző
    img = "img/contract2.webp", --kép
    label = "Szerződés",
    text = "Autóeladáshoz szükséges.",
    price = 1500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "contract2", count = 1 }
  },
  {
    name = "xae12",        --mindegyik különböző
    img = "img/xae12.webp", --kép
    label = "XAE12 Laptop",
    text = "Rablás segítő",
    price = 1500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "xae12", count = 1 }
  },
  {
    name = "lockpick",        --mindegyik különböző
    img = "img/lockpick.webp", --kép
    label = "Zár feltörő",
    text = "Rablás segítő",
    price = 500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "lockpick", count = 1 }
  },
  {
    name = "hackerDevice",        --mindegyik különböző
    img = "img/hackerDevice.webp", --kép
    label = "Hacker laptop",
    text = "Vonat Rablás segítő",
    price = 1500,
    category = "premium",
    event = "villamos_pp:buyItem",
    data = { item = "hackerDevice", count = 1 }
  },
}

Config.GroupPrefix = {
  ['moderator'] = { color = "red", text = "[Event Mananger] " },
  ['mod'] = { color = "red", text = "[Event Mananger] " },
  ['admin'] = { color = "red", text = "[Moderator] " },
  ['admin1'] = { color = "red", text = "[ADMIN1] " },
  ['admin2'] = { color = "red", text = "[ADMIN2] " },
  ['admin3'] = { color = "red", text = "[ADMIN3] " },
  ['admin4'] = { color = "red", text = "[ADMIN4] " },
  ['headadmin'] = { color = "blue", text = "[HEADADMIN] " },
  ['communitymanager'] = { color = "yellow", text = "[Community manager] " },
  ['superadmin'] = { color = "green", text = "[SUPERADMIN] " },
  ['operator'] = { color = "purple", text = "[Operator] " },
  ['admincontroller'] = { color = "purple", text = "[ADMIN CONTROLLER] " },
  ['frakciougyintezo'] = { color = "pink", text = "[Frakció Ügyintéző] " },
  ['manager'] = { color = "orange", text = "[Server Manager] " },
  ['developer'] = { color = "black", text = "[Assist] " },
  ['serverdirector'] = { color = "orange", text = "[Server Manager] " },
  ['coowner'] = { color = "orange", text = "[Server Manager] " },
  ['owner'] = { color = "white", text = "[Tulajdonos] " },
}

Config.BlacklistJobs = {
  "unemployed",
  "piekarz",
  "garbage",
  "delivery"
}

Config.GroupOrder = { 'owner', 'coowner', 'serverdirector', 'developer', 'manager', 'operator', 'communitymanager', 'admincontroller',
  'headadmin', 'superadmin', 'frakciougyintezo', 'admin4', 'admin3', 'admin2', 'admin1', "moderator", "mod", 'admin' }

Config.JobCounters = {
  --['police'] = 'Rendőr (Rendvédelem)', servicess
  ['detective'] = 'LSPD (Rendvédelem)',
  ['servicess'] = 'SNSS (Rendvédelem)',
  ['police'] = 'N.D.A. (Rendvédelem)',
  ['usms'] = 'T.A.C.T (Rendvédelem)',
  ['fbi'] = 'CSO (Rendvédelem)',
  ['fbiuj'] = 'FBI (Rendvédelem)',
  ['irs'] = 'F.T.A (Rendvédelem)',
  ['atf'] = 'FEA (Rendvédelem)',
  ['navi'] = 'U.S.M (Rendvédelem)',
  ['uss'] = 'N.M.S (Rendvédelem)',
  ['guardarmy'] = 'N.D.U (Rendvédelem)',
  ['ambulance'] = 'Mentős',


  ['r'] = 'Rablás mp múlva', --ezt ne szedd ki mert szájba ruglak
}

Config.VehShopCoords = { coords = vector3(-787.9506, -2401.201, 14.570749), radius = 120.0 }
Config.TestTime = 60 * 1000
Config.TestCoords = { x = -1735.94, y = -2926.65, z = 13.5, h = 314.81 } 


Config.AuthorizedAdmins = { "owner" }


--
