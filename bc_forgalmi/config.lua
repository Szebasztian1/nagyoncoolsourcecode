Config = {}

-- ox_inventory item neve
Config.Item = 'forgalmi'

-- Megmutatas masik jatekosnak
Config.ShowDistance = 3.0    -- meter, a legkozelebbi jatekos keresesehez
Config.ShowCooldown = 1500   -- ms, spam vedelem

-- Automatikus kiadas (garazsbol valo kivetelkor)
Config.AutoGive   = true     -- false eseten a bc_forgalmi:vehicleTakenOut event nem ad itemet
Config.ValidHours = 24       -- ennyi oraig ervenyes egy forgalmi
Config.NotifyOnIssue = true  -- ertesites amikor uj forgalmit kap a jatekos

-- Ujra kiadas: CSAK az utolso kiadas ota eltelt ido szamit. Ha a jatekos
-- eldobta / elvesztette a forgalmit, akkor is varnia kell ennyit.
Config.ReissueHours = 24

-- Ha uj kiadaskor van meg regi peldany ugyanarra a rendszamra, az torlodik
Config.RemoveOldOnIssue = true

-- Cache-eles: ennyi masodpercig nem kerdezi le ujra DB-bol / exportbol a
-- jatekos lakcimet (loaf_bought_houses + loaf_housing export), illetve a
-- jarmu ado/muszaki/km adatait (owned_vehicles). Csokkenti a DB terhelest,
-- kis kesessel a friss adatokban (uj hazvasarlas, adobefizetes stb.).
Config.AddressCacheSeconds = 300
Config.TaxDataCacheSeconds = 30

-- /forgalmitest parancs (csak teszteleshez, ace: bc_forgalmi.debug)
Config.Debug = false

Config.Locale = {
	no_player     = 'Nincs a kozeledben senki.',
	shown         = 'Megmutattad a forgalmit.',
	shown_to_you  = 'Megmutattak neked egy forgalmi engedelyt.',
	issued        = 'Megkaptad a jarmu forgalmi engedelyet.',
	no_document   = 'Ez a dokumentum nem olvashato.',
}

-- Modellenkent egyszer legeneralodo, utana adatbazisban tarolt muszaki adatok.
-- Azonos model = azonos adatok. A generalas determinisztikus (model nevbol
-- szarmaztatott seed), tehat DB nelkul is ugyanazt adna.
Config.Generate = {
	evjaratMin = 2004,
	evjaratMax = 2024,

	ccMin = 998,
	ccMax = 6500,

	tomegMin = 900,
	tomegMax = 2600,

	hajtoanyag = {
		'BENZIN', 'BENZIN', 'BENZIN',
		'DIZEL', 'DIZEL',
		'HIBRID',
		'ELEKTROMOS',
	},

	karosszeria = {
		'2 AJTOS COUPE',
		'4 AJTOS SEDAN',
		'5 AJTOS FERDEHATU',
		'KOMBI',
		'SUV',
		'PICK-UP',
		'CABRIO',
	},

	szin = {
		'FEKETE', 'FEHER', 'SZURKE', 'EZUST', 'PIROS',
		'KEK', 'ZOLD', 'SARGA', 'NARANCS', 'BARNA',
	},

	-- muszaki vizsga lejarata: ennyi nap egy fix alapdatumtol szamitva (rendszam alapjan)
	muszakiMinNap = 60,
	muszakiMaxNap = 900,

	-- km ora allas
	kmMin = 1200,
	kmMax = 240000,
}

-- Gepjarmuado: a hengerurtartalombol szamolva, modellenkent fix
Config.Tax = {
	perCc = 0.12,
	min   = 40,
	max   = 1400,
	format = '$ %d',
}

-- Jarmutipus fuggo alapadatok. A vehicleTakenOut event 4. parametereben
-- atadhato tipus (owned_vehicles.type: 'car', 'bike', 'boat', 'aircraft').
Config.VehicleTypes = {
	car      = { jarmufajta = 'SZEMELYGEPKOCSI', kategoria = 'M1',  tengelyek = '2' },
	bike     = { jarmufajta = 'MOTORKEREKPAR',   kategoria = 'L3e', tengelyek = '2' },
	boat     = { jarmufajta = 'VIZIJARMU',       kategoria = 'H',   tengelyek = '0' },
	aircraft = { jarmufajta = 'LEGIJARMU',       kategoria = 'A',   tengelyek = '3' },
	default  = { jarmufajta = 'SZEMELYGEPKOCSI', kategoria = 'M1',  tengelyek = '2' },
}

-- A dokumentum osszes mezoje. Az elrendezes a html/index.html-ben van kezzel
-- megszerkesztve (data-field attributumok), ez a lista a metadata kulcsok
-- dokumentalasahoz es a teszt parancshoz kell.
-- { metadata kulcs, kartya felirat }
Config.Fields = {
	{ 'ervenyes_tol',       'ERVENYES ETTOL' },
	{ 'ervenyes_ig',        'ERVENYES EDDIG' },
	{ 'rendszam',           'RENDSZAM' },
	{ 'alvazszam',          'ALVAZSZAM (VIN)' },
	{ 'evjarat',            'EVJARAT' },
	{ 'gyartmany',          'GYARTMANY' },
	{ 'tipus',              'TIPUS' },
	{ 'karosszeria',        'KAROSSZERIA' },
	{ 'jarmufajta',         'JARMUFAJTA' },
	{ 'hajtoanyag',         'HAJTOANYAG' },
	{ 'kategoria',          'KATEGORIA' },
	{ 'tengelyek',          'TENGELYEK' },
	{ 'hengerurtartalom',   'HENGERURTARTALOM' },
	{ 'sajat_tomeg',        'SAJAT TOMEG' },
	{ 'elso_forgalomba',    'ELSO FORGALOMBA HELYEZES' },
	{ 'kiallitva',          'KIALLITVA' },
	{ 'km_ora',             'KM ORA ALLAS' },
	{ 'szin',               'SZIN' },
	{ 'torzskonyv_szam',    'TORZSKONYV SZAMA' },
	{ 'muszaki_lejarat',    'MUSZAKI VIZSGA LEJARATA' },
	{ 'tulajdonos_nev',     'BEJEGYZETT TULAJDONOS - nev' },
	{ 'tulajdonos_cim',     'BEJEGYZETT TULAJDONOS - cim' },
	{ 'tulajdonos_varos',   'BEJEGYZETT TULAJDONOS - varos / iranyitoszam' },
	{ 'gepjarmuado',        'GEPJARMUADO' },
	{ 'befizetes_datuma',   'BEFIZETVE' },
	{ 'okmanyazonosito',    'OKMANYAZONOSITO' },
	-- nem jelenik meg mezokent, de a metadataban ott van:
	{ 'expires_at',         '(unix timestamp, ebbol szamolodik a LEJART pecset)' },
}
