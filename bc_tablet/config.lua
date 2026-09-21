Config = {}

Config.Commands = {
    { command = "pputal",      description = "PP addolás másik játékos javára [ID - mennyiség]" },
    { command = "auctions",    description = "Aukciós ház megnyitása" },
    { command = "nameinradio", description = "Rádión való becenév adás saját magamnak [név]" },
    { command = "nameofradio", description = "Rádión való becenév eltörlése saját magamról [név]" },
    { command = "zsakle",      description = "Zsák levétele a fejről" },
    { command = "petmenu",     description = "Háziállat menü megnyitása" },
    { command = "jelol",       description = "Játékos ismerős jelölése [ID]" },
    { command = "jarmuado",    description = "Járművekre vonatkozó adó befizetése" },
    { command = "becenev",     description = "Beceneved beállítása [név]" },
    { command = "megaphone",   description = "Megafon használata" },
    { command = "frakciojump", description = "Frakció Jump időtartamának lekérése" },
    { command = "kozivasarlas", description = "Közmunka levásárlása" },
    { command = "dm",          description = "Jelzi, hogy az adott DM rabláson hányan vannak kint" },
    { command = "twt",         description = "Twitter" },
    { command = "htwt",        description = "Titkos twitter, nem ír ki nevet" },
    { command = "ad",          description = "Hirdetés" },
    { command = "report",      description = "Segítségkérés az adminisztrátoroktól" },
    { command = "foldre",      description = "Ha beesel a textúra alá, ezzel visszakerülsz" },
    { command = "th",          description = "A túszul ejtett játékos fejéhez szegezed a fegyvert" },
    { command = "panel",       description = "Játékos lista, PP bolt, információs panel" },
    { command = "jelol",       description = "Bemutatkozás egy játékosnak [ID]" },
    { command = "elfogad",     description = "A barátfelkérés elfogadása" },
    { command = "fps",         description = "FPS boost panel" },
    { command = "hud",         description = "HUD beállítások" },
    { command = "idk",         description = "Játékos IDK elrejtése" },
    { command = "carry",       description = "Játékos lerakása" },
    { command = "vip",         description = "VIP menü, napi ajándék és egyéb jutalmak" },
}

Config.DMZones = {
    {
        name = '🔫 Humane',
        location = 'Humane rablás helyén',
        zonename = 'human',
    },
    {
        name = '🗡️ Bobcat',
        location = 'Bobcat rablás helyén',
        zonename = 'bobcat',
    },
    {
        name = '🏹 Rogers',
        location = 'Rogers rablás helyén',
        zonename = 'rogo',
    },
    {
        name = '🚢 Anyahajó',
        location = 'Cayo Perico és Los Santos között a tengeren',
        zonename = 'ship',
    },
    {
        name = '⛵ Yacht',
        location = 'Vidámpark mellett a vízen',
        zonename = 'yacht',
    },
    {
        name = '🚆 Vonat',
        location = 'Régi bánya mellett',
        zonename = 'metro',
    },
    {
        name = '🐔 Csirkés',
        location = 'Piros blipnél (csirkés rablás)',
        zonename = 'csirkes',
    },
}

Config.Jobs = {
    ["bc_express"] = {
        name = 'BC Express',
        icon = '🚛',
        color = 'linear-gradient(135deg, #2c3f50 0%, #4a6372 100%)',
        location = 'BC Express központ',
        description = 'Töltsd fel a város csomagautómatáit!',
        requirements = 'Jogosítvány',
        coords = vector3(69.034042, 127.42824, 78.20985),
    },
    ["mate-crabjob"] = {
        name = 'Rákászat',
        icon = '🦀',
        color = 'linear-gradient(135deg, #502c2c 0%, #725d4a 100%)',
        location = 'Kikötö',
        description = 'Merészkedj ki a tengerre és fogj értékes rákokat!',
        requirements = 'Valamilyen rák kötél szükséges (vegyél a boltban)',
        coords = vector3(-484.126, -2919.488, 6.00038385),
    },
    ["hobby_banyaszat"] = {
        name = 'Bányász',
        icon = '⛏️',
        color = 'linear-gradient(135deg, #2c3e50 0%, #4a6572 100%)',
        location = 'Sandy Shores - Bánya',
        description = 'Merülj alá a föld mélyére és termelj ki értékes érceket a város iparának!',
        requirements = 'Semmi sem szükséges',
        coords = vector3(-596.5556, 2090.9079, 131.41285),
    },
    ["bc_lumberjack"] = {
        name = 'Favágó',
        icon = '🪓',
        color = 'linear-gradient(135deg, #4e2900 0%, #7b6c19 100%)',
        location = 'Paleto - Fa Telep',
        description = 'Vágd ki a legerősebb fákat és szállítsd le őket a fűrésztelepre! Kitartás és izomerő kell hozzá.',
        requirements = 'Érdemes minimális készpénzzel készülni',
        coords = vector3(-574.6677, 5329.039, 70.21450),
    },
    ["bc_detector"] = {
        name = 'Fémdetektorozás',
        icon = '🔍',
        color = 'linear-gradient(135deg, #8b6912 0%, #b8860b 100%)',
        location = 'Vespucci Beach',
        description = 'Kutasd át a partokat és mezőket fémdetektoroddal, hátha egy kincset rejt a föld!',
        requirements = 'Fémdetektor (vegyél a boltban)',
        coords = vector3(-1742.511, -725.2033, 10.43330),
    },
    ["bc_bus"] = {
        name = 'Buszozás',
        icon = '🚌',
        color = 'linear-gradient(135deg, #f39c12 0%, #e67e22 100%)',
        location = 'Los Santos - Buszpályaudvar',
        description = 'Vezesd a város lakóit biztonságosan A-ból B-be. A pontos járatvezetőket mindig megjutalmazzák!',
        requirements = 'Buszvezetői jogosítvány',
        coords = vector3(975.10198, -1467.424, 31.079767),
    },
    ["truck_logisics"] = {
        name = 'Kamionozás',
        icon = '🚛',
        color = 'linear-gradient(135deg, #2980b9 0%, #3498db 100%)',
        location = 'Nagy Autópálya - Kamionos Telep',
        description = 'Szállíts rakományokat az ország minden pontjára, legyél te a fuvarozás királya!',
        requirements = 'Teherautó jogosítvány',
        coords = vector3(1204.0429, -3099.038, 5.851551),
    },
    ["sd-beekeeping"] = {
        name = 'Méhészet',
        icon = '🍯',
        color = 'linear-gradient(135deg, #f1c40f 0%, #e67e22 100%)',
        location = 'Grapeseed - Méhészet',
        description = 'Gondozd a méhcsaládokat, gyűjtsd be az aranyló mézet és add el a legjobb árért!',
        requirements = 'Védőruha (ajánlott)',
        coords = vector3(426.61276, 6478.3271, 28.823898),
    },
    ["ars_hunting"] = {
        name = 'Vadászat',
        icon = '🏹',
        color = 'linear-gradient(135deg, #2d5a27 0%, #3f7845 100%)',
        location = 'Paleto - Vadászterület',
        description =
        'A térképen 3 blip van jelölve: az első a bolt, a második a küldetésfelvevő (nem kötelező), a harmadik pedig a vadászterület. Irány vadászni!',
        requirements = 'Vadászpuska / Íj',
        coords = vector3(956.96264, -2108.609, 30.551551),
    },
    ["ed_scuba"] = {
        name = 'Búvárkodás',
        icon = '🤿',
        color = 'linear-gradient(135deg, #0e4d8f 0%, #1a759f 100%)',
        location = 'Paleto-öböl / Vízpartok',
        description =
        'Merülj a víz alá és gyűjts értékes tárgyakat, kincseket a tóban vagy a tengerben. Figyelj az oxigénre és a veszélyekre!',
        requirements = 'Búvárfelszerelés',
        coords = vector3(-1264.021, -1436.435, 4.3520655),
    },
    ["phoenix_trasherjob"] = {
        name = 'Kukás Munka',
        icon = '🗑️',
        color = 'linear-gradient(135deg, #34495e 0%, #2c3e50 100%)',
        location = 'Los Santos - Hulladékkezelő',
        description =
        'Gyűjtsd össze a szemetet a kijelölt területeken, és szállítsd a hulladéklerakóba. Tartsd tisztán a várost, miközben pénzt keresel.',
        requirements = 'Szemetesautó',
        coords = vector3(975.10198, -1467.424, 31.079767),
    },

}

Config.Menus = {
    ["report"] = {
        name = 'Report',
        icon = '☎️',
        gradient = 'linear-gradient(135deg, #fe4f4f 0%, #fe5000 100%)',
        description = 'Hívj admint probléma esetén!',
        Open = function()
            ExecuteCommand('report')
        end
    },
    ["playtime"] = {
        name = 'Játékidő shop',
        icon = '⏱️',
        gradient = 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
        description = 'Váltsd be a játékidődet izgalmas jutalmakra a shopban!',
        Open = function()
            ExecuteCommand('playtimeShop')
        end
    },
    ["illegal"] = {
        name = 'Illegál/Rendvédelmi Küldetés',
        icon = '🔫',
        gradient = 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
        description = 'Vállalj illegális vagy rendvédelmi küldetéseket!',
        Open = function()
            exports["bc_hitman"]:openUI()
        end
    },
    ["adozas"] = {
        name = 'Adózás',
        icon = '💰',
        gradient = 'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)',
        description = 'Fizesd be a járműadót, hogy elkerüld a büntetéseket!',
        Open = function()
            ExecuteCommand('jarmuado')
        end
    },
    ["auctions"] = {
        name = 'Aukciós ház',
        icon = '🏦',
        gradient = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        description = 'Bocsáss áruba a tárgyaid, vagy licitálj másokéra az aukciós házban!',
        Open = function()
            ExecuteCommand('auctions')
        end
    },
    ["missions"] = {
        name = 'Küldetések',
        icon = '📋',
        gradient = 'linear-gradient(135deg, #fbc2eb 0%, #a6c1ee 100%)',
        description = 'Nézd meg az elérhető küldetéseket és vállalj belőlük!',
        Open = function()
            ExecuteCommand('taskmenu')
        end
    },
    ["crosshair"] = {
        name = 'Célkereszt',
        icon = '🎯',
        gradient = 'linear-gradient(135deg, #ff7272 0%, #ffa200 100%)',
        description = 'Változtasd a célkereszted szabadon!',
        Open = function()
            ExecuteCommand('kereszt')
        end
    },
    ["radioanim"] = {
        name = 'Rádiós animáció',
        icon = '📢',
        gradient = 'linear-gradient(135deg, #72b1ff 0%, #00e1ff 100%)',
        description = 'Változtasd a rádiós animációd szabadon!',
        Open = function()
            ExecuteCommand('radiomenu')
        end
    },

}

Config.Robberies = {
    {
        name = '💎 Ékszerrablás',
        location = 'Ékszer bolt (térkép)',
        players = '-',
        tools = 'Nagy kaliberű lőfegyver',
        start =
        'Törd be a vitrineket, vidd el az ékszereket, majd szállítsd le a vásárlóknak.',
        difficulty = 'medium',
        res = "rota_jewellery",
    },
    {
        name = '🚘 Vonatrablás',
        location = 'Állomás mellett',
        players = 'Nem kell hozzá',
        tools = 'Vágó, táska',
        start = 'Indítás után meg kell ölnöd az őröket majd betörnöd a vagonokba.',
        difficulty = 'medium',
    },
    {
        name = '🚘 Vilmos autórablás',
        location = 'Paletoba',
        players = 'Nem kell hozzá',
        tools = 'Sima zártörő',
        start = 'Oda kell menned, fel kell törnöd Vilmos autóját majd elmenekülnöd vele.',
        difficulty = 'medium',
    },
    {
        name = '🏧 ATM rablás',
        location = 'Bármelyik ATM',
        players = 'Nem szükséges túsz',
        tools = 'Plazmavágó (1 db)',
        start = 'Menj az ATM-hez, nézz rá harmadik szemmel és indítható.',
        difficulty = 'easy',
        res = "csonti_atmrob",
    },
    {
        name = '🏪 Bolt rablás',
        location = 'Bármely bolt',
        players = '1 élő túsz',
        tools = 'Zárfeltörő',
        start =
        'Nézz a kasszára harmadik szemmel, majd hátul a számítógépet törd fel. A kapott kóddal nyisd ki a széfet.',
        difficulty = 'easy',
        res = "lation_247robbery",
    },
    {
        name = '🏦 Bankrablás',
        location = 'Minden bank (térkép jelzi)',
        players = '2 élő túsz',
        tools = 'XAE12 Laptop',
        start = 'A hátsó széfhez mész és harmadik szemmel elindítod a hackelést.',
        difficulty = 'medium',
        res = "exp_bank_robbery",
    },
    {
        name = '🏛️ Nemzeti Bank rablás',
        location = 'Nemzeti Bank (térkép jelzi)',
        players = '4 élő túsz',
        tools = 'Hacker USB, éles lőfegyver',
        start = 'Menj le a széf ajtajához, nézz rá harmadik szemmel és hajtsd végre a hack minijátékot.',
        difficulty = 'hard',
        res = "rota_robbery",
    },
    {
        name = '🏠 Ház rablás',
        location = 'Piros ház blipnél egy NPC-nél',
        players = 'Nem muszáj, de lehet vinni',
        tools = 'Zárfeltörő',
        start = 'Odamész a kijelölt házhoz, harmadik szemmel ránézel az ajtóra, majd zárfeltörővel feltöröd a zárat.',
        difficulty = 'easy',
        res = "house_robbery",
    },
    {
        name = '🚢 Anyahajó rablás',
        location = 'Cayo Perico és Los Santos között a tengeren',
        players = 'Nem kell hozzá',
        tools = 'Semmi',
        start = 'Elmész a hajóra, és egy fegyverrel lelövöd az egyik NPC-t.',
        difficulty = 'medium',
        res = "asdasd_shiprobbery",
    },
    {
        name = '🚆 Vonat rablás',
        location = 'Régi bánya mellett',
        players = 'Nem kell hozzá',
        tools = 'Sima fúró',
        start = 'Felmész a toronyba, megcsinálod a hackelést, majd felszállsz a vonatra és megfúrod az elejét.',
        difficulty = 'medium',
    },
    {
        name = '🧰 Garázs rablás',
        location = 'Térképen minden piros garázs blip',
        players = 'Nem kell hozzá',
        tools = 'Zárfeltörő (Nehezebb szinteken több kell)',
        start = 'Odamész a bliphez és a zöld körbe beleállva el tudod indítani a rablást.',
        difficulty = 'easy',
        res = "bc_garagerob",
    },
    {
        name = '🛢️ Oil Rig rablás',
        location = 'Paleto mellett (blip jelzi)',
        players = 'Nem szükséges túsz',
        tools = 'Semmi (őrök vannak)',
        start =
        'Menj a bliphez Paletóban, közelítsd meg hajóval/repülővel, öld meg az őröket, hackeld meg a laptopot a toronyban.',
        difficulty = 'hard',
        res = "rigHeist",
    },
    {
        name = '🏦 Paleto-i olajtársasági bank',
        location = 'Paleto, zöld körrel jelzett terület (piros dollárjel blip)',
        players = '2 túsz',
        tools = '1 db XAE12 laptop',
        start =
        'NPC-nél indítható, öld meg az őröket, törd fel a rendszert. Védett NPC-s rablás, végén túsztárgyalás kötelező.',
        difficulty = 'hard',
        res = "paletorablas",
    },
}

---@type table<integer, { id: string, name: string, icon: string, description: string, reward: table }>
Config.Quests = {
    {
        id = "bc_garagerob",
        name = "Garázs Rablás",
        icon = "🧰",
        description = "Törj be az egyik garázba és szedd össze az értékeket!",
        reward = { black_money = 2000000 },
    },
    {
        id = "house_robbery",
        name = "Ház Rablás",
        icon = "🏠",
        description = "Törj be egy lakóházba és vidd el az értékeket.",
        reward = { black_money = 3000000 },
    },
    {
        id = "csonti_atmrob",
        name = "ATM Rablás",
        icon = "🏧",
        description = "Hajtsd végre az ATM rablást egy plazmavágóval.",
        reward = { black_money = 4000000 },
    },
    {
        id = "lation_247robbery",
        name = "Bolt Rablás",
        icon = "🏪",
        description = "Rabolj ki egy 24/7 boltot egy tússzal!",
        reward = { black_money = 2500000 },
    },
    {
        id = "asdasd_shiprobbery",
        name = "Anyahajó Rablás",
        icon = "🚢",
        description = "Szállj fel az anyahajóra és szerezd meg az árut.",
        reward = { black_money = 7000000 },
    },
    {
        id = "exp_bank_robbery",
        name = "Bank Rablás",
        icon = "🏦",
        description = "Hackeld meg a bank rendszerét és törd fel a széfet.",
        reward = { black_money = 40000000 },
    },
    {
        id = "rigHeist",
        name = "Oil Rig Rablás",
        icon = "🛢️",
        description = "Hajtsd végre az olajfúró platformon végrehajtott rablást.",
        reward = { black_money = 7000000 },
    },
    {
        id = "paletorablas",
        name = "Paleto-i Bank",
        icon = "🏛️",
        description = "Robbantsd ki a Paleto-i bank széfjét!",
        reward = { black_money = 7000000 },
    },
    {
        id = "rota_robbery",
        name = "Nemzeti Bank",
        icon = "🏛️",
        description = "Hajtsd végre a legnehezebb rablást, a Nemzeti Bankot!",
        reward = { black_money = 100000000 },
    },
}

Config.LegalQuests = {
    { id = "bc_lumberjack", name = "Favágó", icon = "🪓", description = "Vágj ki fákat és add el a feldolgozott deszkákat!", reward = { money = 3000000 }, goal = 20 },
    { id = "bc_bus", name = "Buszozás", icon = "🚌", description = "Teljesíts egy buszjáratot legalább 5 megállóval!", reward = { money = 3000000 }, goal = 15 },
    { id = "phoenix_trasherjob", name = "Kukás Munka", icon = "🗑️", description = "Fejezz be egy teljes kukás munkanapot!", reward = { money = 3000000 }, goal = 10 },
    { id = "hobby_banyaszat", name = "Bányászat", icon = "⛏️", description = "Bányássz érceket és add el a zsákmányt!", reward = { money = 3000000 }, goal = 20 },
    { id = "bc_detector", name = "Fémdetektoros", icon = "🔍", description = "Fedezz fel értékes tárgyakat és add el őket!", reward = { money = 3000000 }, goal = 20 },
    { id = "mate-crabjob", name = "Rákászat", icon = "🦀", description = "Fogj rákokat és add el a fogást!", reward = { money = 3000000 }, goal = 30 },
    { id = "ars_hunting", name = "Vadászat", icon = "🏹", description = "Vadássz állatokat a kijelölt területen!", reward = { money = 3000000 }, goal = 15 },
    { id = "lunar_fishing", name = "Horgászat", icon = "🎣", description = "Fogj halat a horgászterületen!", reward = { money = 3000000 }, goal = 30 },
    { id = "sd-beekeeping", name = "Méhészet", icon = "🍯", description = "Adj el méhészeti termékeket a kereskedőnél!", reward = { money = 3000000 }, goal = 15 },
    { id = "ed_scuba", name = "Búvárkodás", icon = "🤿", description = "Búvárkodj és gyűjts tárgyakat a víz alatt!", reward = { money = 3000000 }, goal = 20 },
    { id = "truck_logistics", name = "Kamionozás", icon = "🚛", description = "Teljesíts egy kamionos fuvarozási megbízást!", reward = { money = 3000000 }, goal = 5 },
    { id = "esx_ambulancejob", name = "Életmentő Szolgálat", icon = "🚑", description = "Láss el sérülteket, élessz újra játékosokat és ments életeket a városban!", reward = { money = 3000000 }, goal = 150 },
    { id = "vms_tuning", name = "Tuningolas", icon = "🔧", description = "Alakítsd át az autókat egyedi tuningokkal és hozd ki belőlük a maximumot!", reward = { money = 3000000 }, goal = 150 },
}
