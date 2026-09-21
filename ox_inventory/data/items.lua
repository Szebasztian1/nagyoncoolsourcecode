return {
	--[[['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			}
		}
	},]]

	['bandage'] = {
		label = 'Kötszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Sebek gyors ellátására; használatával némi életerőt visszanyersz."
	},

	["bloodbag"] = {
		label = "Vérzsák",
		weight = 100,
		stack = true,
		close = true,
		description = "Életmentő vérkészítmény, amelyet sérülések kezelésére használnak."
	},

	['black_money'] = {
		label = 'Piszkos Pénz',
		description = "Illegális úton szerzett készpénz; tisztára kell mosni, mielőtt elköltenéd.",
	},

	['burger'] = {
		label = 'Burger',
		weight = 1,
		stack = true,
		close = true,
		description = "Gyorséttermi hamburger; mára csak gyűjtögetni lehet, megenni nem."
	},

	['cola'] = {
		label = 'eCola',
		weight = 1,
		stack = true,
		close = true,
		description = "Szénsavas kóla, 40%-kal oltja a szomjúságot."
	},

	['parachute'] = {
		label = 'Ejtőernyő',
		weight = 1,
		stack = true,
		close = true,
		consume = 0,
		description = "Amíg nálad van, ejtőernyő kerül a hátadra. Használatkor nem fogy el."
	},

	['garbage'] = {
		label = 'Szemét',
		description = "Összegyűjtött hulladék; munkák és horgászat közben akad a kezedbe.",
	},

	['paperbag'] = {
		label = 'Papírtáska',
		weight = 1,
		stack = false,
		close = false,
		consume = 0,
		description = "Papírtáska: 5 rekesz, legfeljebb 1 kg fér bele.",
	},

	['identification'] = {
		label = 'Azonosítás',
		description = "Azonosításra szolgáló régi adatlap.",
	},

	['panties'] = {
		label = 'Bugyi',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		},
		description = "Vicces gyűjtői darab; oldja a stresszt, cserébe megszomjazol tőle.",
	},
--##újrablás Tradehouse
	["gang-keychain"] = {
		label = "Banda Kulcstartó",
		weight = 50,
		stack = true,
		close = true,
		client = {
			image = "gang-keychain.png",
		},
		description = "Bandához köthető kulcstartó, tagsági emlék.",
	 },
	 
	 ["safecracker"] = {
		label = "Széftörő",
		weight = 500,
		stack = true,
		close = true,
		client = {
		 image = "safecracker.png",
		},
		description = "Széfek zárjának feltörésére szolgáló szerszám.",
	 },

	['lockpick'] = {
		label = 'Zár feltörő',
		weight = 160,
		description = "Univerzális zárnyitó járművekhez, házakhoz, garázsokhoz és boltkasszákhoz. Könnyen eltörik.",
	},

	['phone'] = {
		label = 'Telefon',
		weight = 190,
		stack = true,
		close = true,
		description = "Régi mobiltelefon; ma már csak a futármunkához fogadják el."
	},

	['ujphone'] = {
		label = 'Iphon Pro 17',
		weight = 190,
		stack = true,
		close = true,
		description = "Mobiltelefon: hívások, üzenetek, alkalmazások – és a rádió is ezzel működik."
	},

	['phone2'] = {
		label = 'Gyár Telefon',
		weight = 190,
		stack = true,
		close = true,
		description = "A gyárban összeszerelt telefon, eladásra szánt késztermék."
	},

	['rpfelejtolegal'] = {
    	label = 'RP Felejtő (Legál)',
    	weight = 190,
    	stack = true,
    	close = true,
    	description = 'Ezzel a tárggyal el tudod felejteni az elmúlt 1 órát.'
	},

	['rpfelejtoillegal'] = {
    	label = 'RP Felejtő (Illegál)',
    	weight = 190,
    	stack = true,
    	close = true,
    	description = 'Ezzel a tárggyal el tudod felejteni az elmúlt 1 órát.'
	},
	
	['carplay'] = {
		label = 'Autó Tablet',
		weight = 190,
		stack = true,
		close = true,
		description = "Járműbe szerelhető multimédia rendszer, zenét játszhatsz le vele."
	},

	['megaphone'] = {
		label = 'Megaphone',
		weight = 190,
		stack = true,
		close = true,
		description = "Kézi hangosbeszélő, amellyel messzire elhallatszik a szavad."
	},

	['money'] = {
		label = 'Money',
		description = "Zsebben tartott készpénz.",
	},

	--[[ ['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	}, ]]

	['water'] = {
		label = 'Víz',
		weight = 2,
		stack = true,
		close = true,
		description = "Palackozott ivóvíz, 10%-kal oltja a szomjúságot."
	},

	['etteremfokaja'] = {
		label = 'Éttermi főétel alapanyag',
		weight = 2,
		stack = true,
		close = true,
		description = 'Ebből az alapanyagból az éttermek főételeket készíthetnek, amelyeket értékesíteni tudnak.',
	},

	['etteremfoital'] = {
		label = 'Éttermi ital alapanyag',
		weight = 2,
		stack = true,
		close = true,
		description = 'Ebből az alapanyagból az éttermek italokat készíthetnek, amelyeket értékesíteni tudnak.',
	},

	['urespalack'] = {
		label = 'Üres Palack',
		weight = 2,
		stack = true,
		close = true,
		description = 'Üres palack, amely kizárólag vízzel tölthető meg.',
	},

	['naturviz'] = {
		label = 'Natur Víz',
		weight = 2,
		stack = true,
		close = true,
		description = 'Természetes forrásból gyűjtött víz. Fogyasztás előtt fel kell forralni.',
	},

	['licensecard'] = {
		label = 'Személy Igazolvány',
		weight = 2,
		stack = true,
		close = true,
		description = "Személyi igazolvány; felmutatható, és a börtönben sem veszik el.",
		consume = 0
	},

	['changeaccesscard'] = {
		label = 'Beléptető kártya',
		weight = 0.1,
		stack = true,
		close = true,
		degrade = 10080,  -- 7 nap percben
		decay = true,     -- lejáratkor magától törlődik
		description = "Szolgálatba lépéshez szükséges kártya a duty ponton. 7 nap után lejár.",
		consume = 0
	},

	['radio'] = {
		label = 'Radio',
		weight = 80,
		stack = true,
		allowArmed = true,
		description = "Kézi adóvevő rádió a csoportos beszélgetéshez.",
	},

	['armour'] = {
		label = 'Bulletproof Vest',
		weight = 3000,
		stack = false,
		close = true,
		description = "Golyóálló mellény, mára használaton kívül."
	},

	['clothing'] = {
		label = 'Ruha',
		consume = 1,
		description = "Ruhadarab átöltözéshez.",
	},

	['mastercard'] = {
		label = 'Mastercard',
		stack = false,
		weight = 10,
		description = "Bankkártya; a számládhoz tartozó fizetőeszköz.",
	},


--DIVING OXYGÉNPALACK MERÜLÉS STB--

	-- Diving
	
	["kuz_divinggear"] = {
		label = "Kezdő Búvárfelszerelés",
		weight = 3,
		stack = true,
		close = true,
		description = "Egyszerű búvárfelszerelés a víz alatti merüléshez.",
	},
	["kuz_divinggeargood"] = {
		label = "Búvárfelszerelés",
		weight = 3,
		stack = true,
		close = true,
		description = "Profi búvárfelszerelés; hosszabb merülést tesz lehetővé.",
	},
	["kuz_goldcoin"] = {
		label = "Arany Érme",
		weight = 3,
		stack = true,
		close = true,
		description = "Tengerből előkerült aranyérme; gyűjtőknek jó pénzért eladható.",
	},
	["kuz_jewelry"] = {
		label = "Régi Ékszer",
		weight = 3,
		stack = true,
		close = true,
		description = "Roncsból mentett régi ékszer, orgazdának továbbadható.",
	},
	["kuz_laptop"] = {
		label = "Merryweather Laptop",
		weight = 3,
		stack = true,
		close = true,
		description = "A Merryweather roncsából szerzett laptop; értékes zsákmány.",
	},
	["kuz_merryweather"] = {
		label = "Merryweather alkatrészek",
		weight = 3,
		stack = true,
		close = true,
		description = "A Merryweather hajóroncsból származó alkatrészek.",
	},
	["kuz_merryweatherbroken"] = {
		label = "Romlott Merryweather alkatrészek",
		weight = 3,
		stack = true,
		close = true,
		description = "Tönkrement Merryweather alkatrészek; töredék áron veszik meg.",
	},
	["kuz_pearl"] = {
		label = "Gyöngy",
		weight = 3,
		stack = true,
		close = true,
		description = "Kagylóból kibontott gyöngy, a merülések keresett zsákmánya.",
	},
	["kuz_rarecoin"] = {
		label = "Ritka Pénzérme",
		weight = 3,
		stack = true,
		close = true,
		description = "Ritka gyűjtői pénzérme a tengerfenékről.",
	},
	["kuz_silvercoin"] = {
		label = "Ezüst érme",
		weight = 3,
		stack = true,
		close = true,
		description = "Tengerből előkerült ezüstérme.",
	},
	["kuz_watch"] = {
		label = "Hypernova Óra",
		weight = 3,
		stack = true,
		close = true,
		description = "Vízből kiemelt luxusóra; szép summát ér.",
	},

------------------------------------------------------vége-------	

--### Ruhabolt rablás
	['luxury_stolen_bag'] = {
		label = 'Luxus ruházati táska',
		stack = false,
		weight = 1.0, -- Példa súly, módosítható az igényeid szerint
		description = "Lopott luxus ruhaszállítmány egy táskában.",
	},

	['gucci_tshirt'] = {
		label = 'Gucci póló',
		stack = false,
		weight = 0.5, -- Példa súly, módosítható az igényeid szerint
		description = "Márkás dizájner póló; feketén jó pénzt ér.",
	},

	['gucci_flipflops'] = {
		label = 'Gucci papucs',
		stack = false,
		weight = 0.3, -- Példa súly, módosítható az igényeid szerint
		description = "Márkás papucs; gyűjtők és orgazdák keresik.",
	},

	['louis_vuitton_bag'] = {
		label = 'Louis Vuitton táska',
		stack = false,
		weight = 1.2, -- Példa súly, módosítható az igényeid szerint
		description = "Dizájner kézitáska; borsos árat kérnek érte.",
	},

	['louis_vuitton_tshirt'] = {
		label = 'Louis Vuitton póló',
		stack = false,
		weight = 0.5, -- Példa súly, módosítható az igényeid szerint
		description = "Dizájner póló a luxusmárkától.",
	},

	['valentino_pants'] = {
		label = 'Valentino nadrág',
		stack = false,
		weight = 0.8, -- Példa súly, módosítható az igényeid szerint
		description = "Dizájner nadrág a luxusmárkától.",
	},

	['prada_shoes'] = {
		label = 'Prada cipő',
		stack = false,
		weight = 0.6, -- Példa súly, módosítható az igényeid szerint
		description = "Dizájner cipő; a divatrajongók kedvence.",
	},

	['prada_bag'] = {
		label = 'Prada táska',
		stack = false,
		weight = 1.0, -- Példa súly, módosítható az igényeid szerint
		description = "Dizájner táska; a feketepiacon értékes.",
	},

	['gyemantruha'] = {
		label = 'Gyémánt Ruha',
		stack = true,
		weight = 1,
		description = "Gyémántokkal díszített ruha; ládából nyerhető ritkaság.",
	},

---------------------------------------------------------------------------------------------------

	['fivesevenscopemini'] = {
		label = 'FiveSeven Scope Mini',
		weight = 1,
		stack = true,
		close = true,
		description = "A FiveSeven pisztolyhoz való kis céltávcső."
	},
	['fivesevensup'] = {
		label = 'FiveSeven Sup',
		weight = 1,
		stack = true,
		close = true,
		description = "A FiveSeven pisztolyhoz való hangtompító."
	},
	['fivesevensp'] = {
		label = 'FiveSeven SP',
		weight = 1,
		stack = true,
		close = true,
		description = "A FiveSeven pisztoly egyedi alkatrésze."
	},

	['whiteaptar'] = {
		label = 'WhiteAP Tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "WhiteAP elkészítéséhez szükséges tár."
	},

	['whiteapcso'] = {
		label = 'WhiteAP Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "WhiteAP elkészítéséhez szükséges cső."
	},
	
	['whiteapmarkolat'] = {
		label = 'WhiteAP Markolat (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "WhiteAP elkészítéséhez szükséges markolat."
	},

	['xv3cso'] = {
		label = 'XV3 Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP XV3 HOLY WIRE elkészítéséhez szükséges cső."
	},
	
	['xv3markolat'] = {
		label = 'XV3 Markolat (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP XV3 HOLY WIRE elkészítéséhez szükséges markolat."
	},

	['xv3tar'] = {
		label = 'XV3 Tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP XV3 HOLY WIRE elkészítéséhez szükséges tár."
	},

	['cxp77cso'] = {
		label = 'CXP77 Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP CXP77 elkészítéséhez szükséges cső."
	},

	['cxp77hang'] = {
		label = 'CXP77 Hang (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP CXP77 elkészítéséhez szükséges hangtompító."
	},

	['cxp77tar'] = {
		label = 'CXP77 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP CXP77 elkészítéséhez szükséges tár."
	},

	['glockyuncso'] = {
		label = 'Glockyun Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP GLOCKYUN elkészítéséhez szükséges cső."
	},

	['glockyunmarkol'] = {
		label = 'Glockyun Markolat (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP GLOCKYUN elkészítéséhez szükséges markolat."
	},

	['glockyuntar'] = {
		label = 'Glockyun Tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP GLOCKYUN elkészítéséhez szükséges tár."
	},

	['skycso'] = {
		label = 'Sky Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP SKYPISTOL elkészítéséhez szükséges cső."
	},

	['skyhatso'] = {
		label = 'Sky Hátsó (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP SKYPISTOL elkészítéséhez szükséges hátsó rész."
	},

	['skymarkolat'] = {
		label = 'Sky Markolat (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "AP SKYPISTOL elkészítéséhez szükséges markolat."
	},

	['devilswitchcso'] = {
		label = 'Devilswitch Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "DEVILSWITCH elkészítéséhez szükséges cső."
	},

	['devilswitchmarkolat'] = {
		label = 'Devilswitch Markolat (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "DEVILSWITCH elkészítéséhez szükséges markolat."
	},

	['devilswitchtar'] = {
		label = 'Devilswitch Tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "DEVILSWITCH elkészítéséhez szükséges tár."
	},

	['devilswitchlampa'] = {
		label = 'Devilswitch Lámpa (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "DEVILSWITCH elkészítéséhez szükséges lámpa."
	},

	['blackgoldcso'] = {
		label = 'BlackGold Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GK18 BlackGold elkészítéséhez szükséges cső."
	},

	['blackgoldmarkolat'] = {
		label = 'BlackGold Markolat (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GK18 BlackGold elkészítéséhez szükséges markolat."
	},

	['blackgolddobtar'] = {
		label = 'BlackGold Dobtár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GK18 BlackGold elkészítéséhez szükséges dobtár."
	},

	['blackgoldhang'] = {
		label = 'BlackGold Hangtompító (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GK18 BlackGold elkészítéséhez szükséges hangtompító."
	},

	['biohazardcso'] = {
		label = 'Biohazard Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GK20 Biohazard elkészítéséhez szükséges cső."
	},

	['biohazardmarkolat'] = {
		label = 'Biohazard Markolat (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GK20 Biohazard elkészítéséhez szükséges markolat."
	},

	['biohazardtar'] = {
		label = 'Biohazard Tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GK20 Biohazard elkészítéséhez szükséges tár."
	},

	['biohazardkomp'] = {
		label = 'Biohazard Kompenzátor (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GK20 Biohazard elkészítéséhez szükséges kompenzátor."
	},

	['g17ptar'] = {
		label = 'G17 P Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "A G17 pisztoly tára; a fegyver összeszereléséhez kell."
	},

	['g17pcso'] = {
		label = 'G17 P Cső',
		weight = 1,
		stack = true,
		close = true,
		description = "A G17 pisztoly csöve; a fegyver összeszereléséhez kell."
	},

	['g17pvaz'] = {
		label = 'G17 P Váz',
		weight = 1,
		stack = true,
		close = true,
		description = "A G17 pisztoly váza; a fegyver összeszereléséhez kell."
	},

	['patar'] = {
		label = 'Punisher AR Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "Punisher AR elkészítéséhez szükséges tár."
	},

	['pavaz'] = {
		label = 'Punisher AR Váz',
		weight = 1,
		stack = true,
		close = true,
		description = "Punisher AR elkészítéséhez szükséges váz."
	},

	['pascope'] = {
		label = 'Punisher AR Scope',
		weight = 1,
		stack = true,
		close = true,
		description = "Punisher AR elkészítéséhez szükséges céltávcső."
	},

	['patamasz'] = {
		label = 'Punisher AR Támasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Punisher AR elkészítéséhez szükséges támasz."
	},

	['bptar'] = {
		label = 'Burst Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "Burst pisztoly elkészítéséhez szükséges tár."
	},

	['bpvaz'] = {
		label = 'Burst Váz',
		weight = 1,
		stack = true,
		close = true,
		description = "Burst pisztoly elkészítéséhez szükséges váz."
	},

	['bpcso'] = {
		label = 'Burst Cső',
		weight = 1,
		stack = true,
		close = true,
		description = "Burst pisztoly elkészítéséhez szükséges cső."
	},

	['activia'] = {
		label = 'aktívia',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Gyümölcsös joghurt, könnyű reggeli."
	},

	['advancedrifle'] = {
		label = 'ctar-21',
		weight = 3.18,
		stack = true,
		close = true,
		description = "CTAR-21 gépkarabély."
	},

	['blockmusketbelso'] = {
		label = 'BlockMusket belsőszerkezet',
		weight = 1,
		stack = true,
		close = true,
		description = "Block Musketa elkészítéséhez szükséges belső szerkezet."
	},

	['blockmusketcso'] = {
		label = 'BlockMusket Cső',
		weight = 1,
		stack = true,
		close = true,
		description = "Block Musketa elkészítéséhez szükséges cső."
	},

	['blockmusketravasz'] = {
		label = 'BlockMusket Ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Block Musketa elkészítéséhez szükséges ravasz."
	},

	['blockmuskettar'] = {
		label = 'BlockMusket Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "Block Musketa elkészítéséhez szükséges tár."
	},

	['blockmusketvaltamasz'] = {
		label = 'BlockMusket Váltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Block Musketa elkészítéséhez szükséges válltámasz."
	},

	['wang17cso'] = {
		label = 'Twang G17 Cső',
		weight = 1,
		stack = true,
		close = true,
		description = "Twan G17 elkészítéséhez szükséges cső."
	},

	['wang17ravasz'] = {
		label = 'Twang G17 Ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Twan G17 elkészítéséhez szükséges ravasz."
	},

	['wang17tar'] = {
		label = 'Twang G17 Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "Twan G17 elkészítéséhez szükséges tár."
	},

	['crackng20cso'] = {
		label = 'CrackNG20 CSŐ',
		weight = 1,
		stack = true,
		close = true,
		description = "Crackn G20 pisztoly elkészítéséhez szükséges cső."
	},

	['crackng20egesz'] = {
		label = 'CrackNG20 EGÉSZ',
		weight = 1,
		stack = true,
		close = true,
		description = "Crackn G20 pisztoly elkészítéséhez szükséges fő egység."
	},

	['crackng20vaz'] = {
		label = 'CrackNG20 VÁZ',
		weight = 1,
		stack = true,
		close = true,
		description = "Crackn G20 pisztoly elkészítéséhez szükséges váz."
	},

	['crimg17egesz'] = {
		label = 'Crim G17 EGÉSZ',
		weight = 1,
		stack = true,
		close = true,
		description = "Crim G17 pisztoly elkészítéséhez szükséges fő egység."
	},

	['crimg17scoop'] = {
		label = 'Crim G17 SCOPE',
		weight = 1,
		stack = true,
		close = true,
		description = "Crim G17 pisztoly elkészítéséhez szükséges céltávcső."
	},

	['crimg17tar'] = {
		label = 'Crim G17 TÁR',
		weight = 1,
		stack = true,
		close = true,
		description = "Crim G17 pisztoly elkészítéséhez szükséges tár."
	},

	['gldxnvaz'] = {
		label = 'Pusztító Váz',
		weight = 1,
		stack = true,
		close = true,
		description = "Pusztító pisztoly elkészítéséhez szükséges váz."
	},

	['gldxnvazscoop'] = {
		label = 'Pusztító Scope',
		weight = 1,
		stack = true,
		close = true,
		description = "Pusztító pisztoly elkészítéséhez szükséges céltávcső."
	},

	['gldxnvazcso'] = {
		label = 'Pusztító Cső',
		weight = 1,
		stack = true,
		close = true,
		description = "Pusztító pisztoly elkészítéséhez szükséges cső."
	},

	['gluegunegesz'] = {
		label = 'Glue Gun EGÉSZ',
		weight = 1,
		stack = true,
		close = true,
		description = "Glue Gun pisztoly elkészítéséhez szükséges fő egység."
	},

	['gluegunravaz'] = {
		label = 'Glue Gun RAVAZ',
		weight = 1,
		stack = true,
		close = true,
		description = "Glue Gun pisztoly elkészítéséhez szükséges váz."
	},

	['gluegunscoop'] = {
		label = 'Glue Gun SCOOP',
		weight = 1,
		stack = true,
		close = true,
		description = "Glue Gun pisztoly elkészítéséhez szükséges alkatrész."
	},

	['luckyg19xcso'] = {
		label = 'Lucky G19X CSŐ',
		weight = 1,
		stack = true,
		close = true,
		description = "Lucky G19X pisztoly elkészítéséhez szükséges cső."
	},

	['luckyg19xegesz'] = {
		label = 'Lucky G19X EGÉSZ',
		weight = 1,
		stack = true,
		close = true,
		description = "Lucky G19X pisztoly elkészítéséhez szükséges fő egység."
	},

	['luckyg19xtar'] = {
		label = 'Lucky G19X TÁR',
		weight = 1,
		stack = true,
		close = true,
		description = "Lucky G19X pisztoly elkészítéséhez szükséges tár."
	},

	['crosscso'] = {
		label = 'CROSSFIREX Cső',
		weight = 1,
		stack = true,
		close = true,
		description = "A CrossfireX fegyver csöve."
	},

	['crossbelso'] = {
		label = 'CROSSFIREX Belső',
		weight = 1,
		stack = true,
		close = true,
		description = "A CrossfireX fegyver belső szerkezete."
	},

	['crosskulso'] = {
		label = 'CROSSFIREX Külső',
		weight = 1,
		stack = true,
		close = true,
		description = "A CrossfireX fegyver külső burkolata."
	},

	['crosstar'] = {
		label = 'CROSSFIREX Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "A CrossfireX fegyver tára."
	},

	['ak47belso'] = {
		label = 'ak47 belsőszerkezet',
		weight = 1,
		stack = true,
		close = true,
		description = "Assault Rifle elkészítéséhez szükséges belső szerkezet."
	},

	['ak47cso'] = {
		label = 'ak47 cső',
		weight = 1,
		stack = true,
		close = true,
		description = "Assault Rifle elkészítéséhez szükséges cső."
	},

	['ak47ravasz'] = {
		label = 'ak47 ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Assault Rifle elkészítéséhez szükséges ravasz."
	},

	['ak47tar'] = {
		label = 'ak47 tár',
		weight = 1,
		stack = true,
		close = true,
		description = "Assault Rifle elkészítéséhez szükséges tár."
	},

	['ak47valtamasz'] = {
		label = 'ak47 válltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Assault Rifle elkészítéséhez szükséges támasz."
	},

--##Újfegyver egyedi:
	['m47belso'] = {
		label = 'M47 belsőszerkezet (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M47V2 elkészítéséhez szükséges belső szerkezet."
	},

	['m47cso'] = {
		label = 'M47 cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M47V2 elkészítéséhez szükséges cső."
	},

	['m47ravasz'] = {
		label = 'M47 ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M47V2 elkészítéséhez szükséges ravasz."
	},

	['m47tar'] = {
		label = 'M47 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M47V2 elkészítéséhez szükséges tár."
	},

	['m47valtamasz'] = {
		label = 'M47 válltámasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M47V2 elkészítéséhez szükséges támasz."
	},

	['sytar'] = {
		label = 'Syndicate tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "A Syndicate fegyver tára."
	},

	['sycso'] = {
		label = 'Syndicate Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "A Syndicate fegyver csöve."
	},

	['syravasz'] = {
		label = 'Syndicate Ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Syndicate Pisztoly elkészítéséhez szükséges ravasz."
	},

	['999ravasz'] = {
		label = '999 ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Pisztoly 999 elkészítéséhez szükséges ravasz."
	},

	['999tar'] = {
		label = '999 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Pisztoly 999 elkészítéséhez szükséges tár."
	},

	['999cso'] = {
		label = '999 cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Pisztoly 999 elkészítéséhez szükséges cső."
	},

	['duranda2ravasz'] = {
		label = 'Duranda2 ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Döngölő AP elkészítéséhez szükséges ravasz."
	},

	['duranda2tar'] = {
		label = 'Duranda2 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Döngölő AP elkészítéséhez szükséges tár."
	},

	['duranda2cso'] = {
		label = 'Duranda2 cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Döngölő AP elkészítéséhez szükséges cső."
	},
	
	['alkaidacso'] = {
		label = 'Ghost cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Ghost Pisztoly elkészítéséhez szükséges cső."
	},

	['alkaidatar'] = {
		label = 'Ghost tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Ghost Pisztoly elkészítéséhez szükséges tár."
	},

	['alkaidaravasz'] = {
		label = 'Ghost Ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Ghost Pisztoly elkészítéséhez szükséges ravasz."
	},

	['alkaidaravaszap'] = {
		label = 'Ghost AP Ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Ghost AP Pisztoly elkészítéséhez szükséges ravasz."
	},

	['alkaidatarap'] = {
		label = 'Ghost AP Tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Ghost AP Pisztoly elkészítéséhez szükséges tár."
	},

	['alkaidacsoap'] = {
		label = 'Ghost AP Cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Ghost AP Pisztoly elkészítéséhez szükséges cső."
	},

	['durandcso'] = {
		label = 'Durand cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Döngölő Pisztoly elkészítéséhez szükséges cső."
	},

	['durandtar'] = {
		label = 'Durand Tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Döngölő Pisztoly elkészítéséhez szükséges tár."
	},

	['durandravasz'] = {
		label = 'Durand Ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Döngölő Pisztoly elkészítéséhez szükséges ravasz."
	},

	['at4s_dobt'] = {
		label = 'AT4S Dob',
		weight = 1,
		stack = true,
		close = true,
		description = "AT4S Pisztoly elkészítéséhez szükséges dobtár."
	},

	['at4s_tar'] = {
		label = 'AT4S Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "AT4S Pisztoly elkészítéséhez szükséges tár."
	},

	['at4s_cso'] = {
		label = 'AT4S Cső',
		weight = 1,
		stack = true,
		close = true,
		description = "AT4S Pisztoly elkészítéséhez szükséges cső."
	},
	
	['at4s_vaz'] = {
		label = 'AT4S Váz',
		weight = 1,
		stack = true,
		close = true,
		description = "AT4S Pisztoly elkészítéséhez szükséges váz."
	},


--###########################################

	['gk19cso'] = {
		label = 'GK19 cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "REDPEARL AP elkészítéséhez szükséges cső."
	},

	['gk19ravasz'] = {
		label = 'GK19 ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "REDPEARL AP elkészítéséhez szükséges ravasz."
	},

	['gk19ctar'] = {
		label = 'GK19 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "REDPEARL AP elkészítéséhez szükséges tár."
	},

	['m4strmborncso'] = {
		label = 'M4 Stormborn cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "PHANTOM M4 elkészítéséhez szükséges cső."
	},

	['m4strmbornravasz'] = {
		label = 'M4 Stormborn ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "PHANTOM M4 elkészítéséhez szükséges ravasz."
	},

	['m4strmborntar'] = {
		label = 'M4 Stormborn tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "PHANTOM M4 elkészítéséhez szükséges tár."
	},

	['67g17cso'] = {
		label = '67G17 cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "G67 G17GRIP elkészítéséhez szükséges cső."
	},

	['67g17ravasz'] = {
		label = '67G17 ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "G67 G17GRIP elkészítéséhez szükséges ravasz."
	},

	['67g17tar'] = {
		label = '67G17 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "G67 G17GRIP elkészítéséhez szükséges tár."
	},

	['elkg17cso'] = {
		label = 'elkg17 cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "ELK G17 elkészítéséhez szükséges cső."
	},

	['elkg17ravas'] = {
		label = 'elkg17 ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "ELK G17 elkészítéséhez szükséges ravasz."
	},

	['elkg17tar'] = {
		label = 'elkg17 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "ELK G17 elkészítéséhez szükséges tár."
	},

	['salenag17cso'] = {
		label = 'SalenaG17 cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "SALENA G17 elkészítéséhez szükséges cső."
	},

	['salenag17ravasz'] = {
		label = 'SalenaG17 ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "SALENA G17 elkészítéséhez szükséges ravasz."
	},

	['salenag17tar'] = {
		label = 'SalenaG17 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "SALENA G17 elkészítéséhez szükséges tár."
	},

	['machinepistolredcso'] = {
		label = 'Machine cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Machine Pistol Red CHR elkészítéséhez szükséges cső."
	},

	['machinepistolredravasz'] = {
		label = 'Machine ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Machine Pistol Red CHR elkészítéséhez szükséges ravasz."
	},

	['machinepistolredtar'] = {
		label = 'Machine tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Machine Pistol Red CHR elkészítéséhez szükséges tár."
	},

	['machinepistolredvaltamasz'] = {
		label = 'Machine válltámasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "Machine Pistol Red CHR elkészítéséhez szükséges támasz."
	},

	['gyscso'] = {
		label = 'GYS cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GYS Fegyver elkészítéséhez szükséges cső."
	},

	['gysravasz'] = {
		label = 'GYS ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GYS Fegyver elkészítéséhez szükséges ravasz."
	},

	['gystar'] = {
		label = 'GYS tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GYS Fegyver elkészítéséhez szükséges tár."
	},

	['gysvaltamasz'] = {
		label = 'GYS válltámasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "GYS Fegyver elkészítéséhez szükséges támasz."
	},

	['m9pchromiumcso'] = {
		label = 'M9 cső (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M9 P Chromium elkészítéséhez szükséges cső."
	},

	['m9pchromiumravasz'] = {
		label = 'M9 ravasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M9 P Chromium elkészítéséhez szükséges ravasz."
	},

	['m9pchromiumtar'] = {
		label = 'M9 tár (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M9 P Chromium elkészítéséhez szükséges tár."
	},

	['m9pchromiumvaltamasz'] = {
		label = 'M9 válltámasz (Egyedi)',
		weight = 1,
		stack = true,
		close = true,
		description = "M9 P Chromium elkészítéséhez szükséges támasz."
	},

-------------------------------------------------

['1441pistolcso'] = {
	label = '1441 cső (Egyedi)',
	weight = 1,
	stack = true,
	close = true,
	description = "Pisztoly 1441 elkészítéséhez szükséges cső."
},

['1441pistolravasz'] = {
	label = '1441 ravasz (Egyedi)',
	weight = 1,
	stack = true,
	close = true,
	description = "Pisztoly 1441 elkészítéséhez szükséges ravasz."
},

['1441pistoltar'] = {
	label = '1441 tár (Egyedi)',
	weight = 1,
	stack = true,
	close = true,
	description = "Pisztoly 1441 elkészítéséhez szükséges tár."
},

['1441pistolvalltamasz'] = {
	label = '1441 válltámasz (Egyedi)',
	weight = 1,
	stack = true,
	close = true,
	description = "Pisztoly 1441 elkészítéséhez szükséges támasz."
},

--######################################

	['alive_chicken'] = {
		label = 'Élő csirke',
		weight = 1,
		stack = true,
		close = true,
		description = "Élő csirke a baromfifarmról; feldolgozásra vár."
	},

	['hgk63cso'] = {
		label = 'HKG63 cső',
		weight = 1,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez használható cső."
	},

	['hgk63ravasz'] = {
		label = 'HKG63 ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez használható ravasz."
	},

	['hgk63tar'] = {
		label = 'HKG63 tár',
		weight = 1,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez használható tár."
	},

	['hgk63valltamasz'] = {
		label = 'HKG63 válltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez használható támasz."
	},


	-------------------------------------------ujegyedifegyverek
	['deadcso'] = {
		label = 'Dead Cso',
		weight = 1,
		stack = true,
		close = true,
		description = "DEADSHOT elkészítéséhez szükséges cső."
	},

	['deadravasz'] = {
		label = 'Dead Ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "DEADSHOT elkészítéséhez szükséges ravasz."
	},

	['deadtar'] = {
		label = 'Dead Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "DEADSHOT elkészítéséhez szükséges tár."
	},

	['deadvaltamasz'] = {
		label = 'Dead válltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "DEADSHOT elkészítéséhez szükséges támasz."
	},

	['999apcso'] = {
		label = '999AP Cso',
		weight = 1,
		stack = true,
		close = true,
		description = "999 AP elkészítéséhez szükséges cső."
	},

	['999apravasz'] = {
		label = '999AP Ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "999 AP elkészítéséhez szükséges ravasz."
	},

	['999aptar'] = {
		label = '999AP Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "999 AP elkészítéséhez szükséges tár."
	},

	['blocktar'] = {
		label = 'Block Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "Block AP elkészítéséhez szükséges tár."
	},

	['blockravasz'] = {
		label = 'Block Ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Block AP elkészítéséhez szükséges ravasz."
	},

	['blockcso'] = {
		label = 'Block Cső',
		weight = 1,
		stack = true,
		close = true,
		description = "Block AP elkészítéséhez szükséges cső."
	},

	['hfscso'] = {
		label = 'HFS Cso',
		weight = 1,
		stack = true,
		close = true,
		description = "HFSMGV2 ICE elkészítéséhez szükséges cső."
	},

	['h05117cso'] = {
		label = 'H05 Cso',
		weight = 1,
		stack = true,
		close = true,
		description = "H05117 AP elkészítéséhez szükséges cső."
	},

	['h05117ravasz'] = {
		label = 'H05 ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "H05117 AP elkészítéséhez szükséges ravasz."
	},

	['h05117tar'] = {
		label = 'H05 tár',
		weight = 1,
		stack = true,
		close = true,
		description = "H05117 AP elkészítéséhez szükséges tár."
	},

	['h05117valtamasz'] = {
		label = 'H05 Váltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "H05117 AP elkészítéséhez szükséges válltámasz."
	},

	['combatpistolccso'] = {
		label = 'CombatPC cso',
		weight = 1,
		stack = true,
		close = true,
		description = "Combat Pistol Chromium AP elkészítéséhez szükséges cső."
	},

	['combatpistolcravasz'] = {
		label = 'CombatPC ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Combat Pistol Chromium AP elkészítéséhez szükséges ravasz."
	},

	['combatpistolctar'] = {
		label = 'CombatPC tar',
		weight = 1,
		stack = true,
		close = true,
		description = "Combat Pistol Chromium AP elkészítéséhez szükséges tár."
	},

	['combatpistolcvaltamasz'] = {
		label = 'CombatPC Váltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Combat Pistol Chromium AP elkészítéséhez szükséges válltámasz."
	},

	['hfsravasz'] = {
		label = 'HFS Ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "HFSMGV2 ICE elkészítéséhez szükséges ravasz."
	},

	['hfstar'] = {
		label = 'HFS Tár',
		weight = 1,
		stack = true,
		close = true,
		description = "HFSMGV2 ICE elkészítéséhez szükséges tár."
	},

	['hfsvaltamasz'] = {
		label = 'HFS válltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "HFSMGV2 ICE elkészítéséhez szükséges támasz."
	},
	-------------------------------------------
	['ammunition_fireextinguisher'] = {
		label = 'tűzoltó készülék',
		weight = 1,
		stack = true,
		close = true,
		description = "Tűzoltó készülék a lángok eloltásához."
	},

	['ammunition_pistol'] = {
		label = 'pisztoly lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Pisztolyhoz való lőszer."
	},

	['ammunition_pistol_large'] = {
		label = 'nagykaliberű lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Nagyobb kaliberű pisztolylőszer."
	},

	['ammunition_rifle'] = {
		label = 'nagykaliberű lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Gépkarabélyhoz való lőszer."
	},

	['ammunition_rifle_large'] = {
		label = 'nagykaliberű lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Nagy kaliberű puskalőszer."
	},

	['ammunition_shotgun'] = {
		label = 'shotgun lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Sörétes puskához való töltény."
	},

	['ammunition_shotgun_large'] = {
		label = 'shotgun lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Nagyobb adag sörétes töltény."
	},

	['ammunition_smg'] = {
		label = 'smg lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Géppisztolyhoz való lőszer."
	},

	['ammunition_smg_large'] = {
		label = 'smg lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Nagyobb adag géppisztoly-lőszer."
	},

	['ammunition_snp'] = {
		label = 'sniper lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Mesterlövész-puskához való lőszer."
	},

	['ammunition_snp_large'] = {
		label = 'sniper lőszer',
		weight = 1,
		stack = true,
		close = true,
		description = "Nagyobb adag mesterlövész-lőszer."
	},

	['amur'] = {
		label = 'amur',
		weight = 0,
		stack = true,
		close = true,
		description = "Amur; húsos édesvízi hal, a horgászok fogása."
	},

	['angolna'] = {
		label = 'angolna',
		weight = 0,
		stack = true,
		close = true,
		description = "Angolna; nyúlánk édesvízi hal."
	},

	['animal_bait'] = {
		label = 'Állat hús',
		weight = 1,
		stack = true,
		close = true,
		description = "Csalihús, amellyel vadat lehet odacsalogatni."
	},

	['appistol'] = {
		label = 'colt scamp',
		weight = 1.02,
		stack = true,
		close = true,
		description = "Colt Scamp géppisztoly."
	},

	['aranyhal'] = {
		label = 'aranyhal',
		weight = 0,
		stack = true,
		close = true,
		description = "Aranyhal; díszhal, ritka fogás."
	},

	['armbrace'] = {
		label = 'karmerevítő',
		weight = 0,
		stack = true,
		close = true,
		description = "Karmerevítő a sérült kar rögzítésére."
	},

	['armor'] = {
		label = 'páncélzat',
		weight = 0,
		stack = true,
		close = true,
		description = "Golyóálló páncél; felvéve 50 páncélt ad."
	},

	['asdasdlockpick'] = {
		label = 'zár feltörő',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszerű zárfeltörő szerszám."
	},

	['asdasdstetoscope'] = {
		label = 'sztetoszkóp',
		weight = 1,
		stack = true,
		close = true,
		description = "Sztetoszkóp; szívhang és zárszerkezet hallgatásához."
	},

	['assaultrifle'] = {
		label = 'ak 47',
		weight = 4.3,
		stack = true,
		close = true,
		description = "AK-47 gépkarabély."
	},

	['assaultrifle_mk2'] = {
		label = 'ak47 mk2',
		weight = 4.3,
		stack = true,
		close = true,
		description = "Felújított AK-47 MK2 gépkarabély."
	},

	['assaultshotgun'] = {
		label = 'utas uts-15',
		weight = 4.1,
		stack = true,
		close = true,
		description = "UTS-15 sörétes puska."
	},

	['assaultsmg'] = {
		label = 'magpul pdr',
		weight = 5.1,
		stack = true,
		close = true,
		description = "Magpul PDR géppisztoly."
	},

	['autoshotgun'] = {
		label = 'aa-12',
		weight = 7.3,
		stack = true,
		close = true,
		description = "AA-12 automata sörétes puska."
	},

	['bag'] = {
		label = 'táska',
		weight = 0,
		stack = true,
		close = true,
		description = "Egyszerű táska a holmid tárolásához."
	},

	['bat'] = {
		label = 'baseball Ütő',
		weight = 3,
		stack = true,
		close = true,
		description = "Baseballütő; ütőfegyverként is beválik."
	},

	['battleaxe'] = {
		label = 'balta',
		weight = 1,
		stack = true,
		close = true,
		description = "Csatabárd; közelharci fegyver."
	},

	['bean_machine_coffe'] = {
		label = 'bean machine coffe',
		weight = 1,
		stack = true,
		close = true,
		description = "Bean Machine kávé, elvitelre."
	},

	['beer'] = {
		label = 'sör',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Hideg dobozos sör, 40%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['big_drill'] = {
		label = 'big_drill',
		weight = 1,
		stack = true,
		close = true,
		description = "Nagy fúrógép széfek és falak megbontásához."
	},

	['blowpipe'] = {
		label = 'lángvágó',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Lángvágó fémzárak és rácsok átvágásához."
	},

	['bodybandage'] = {
		label = 'test kötszer',
		weight = 0,
		stack = true,
		close = true,
		description = "Nagyobb kötszer a súlyosabb sérülések ellátására."
	},

	['bolt_cutter'] = {
		label = 'Csavar Vágó',
		weight = 1,
		stack = true,
		close = true,
		description = "Csavarvágó lakatok és láncok elvágásához."
	},

	--[[['boombox'] = {
		label = 'boombox',
		weight = 0,
		stack = true,
		close = true,
		description = nil
	},]]

	['bottle'] = {
		label = 'Üveg',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Üres üveg; szükség esetén ütőfegyver."
	},

	['bread'] = {
		label = 'kenyér',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Friss kenyér, 10%-kal csillapítja az éhséget."
	},

	['amfk'] = {
		label = 'AMERIKAI MÁZAS FÁNK',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Amerikai mázas fánk, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['brownie'] = {
		label = 'BROWNIE',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Csokis brownie, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['smuffin'] = {
		label = 'SCHOKOBONS MUFFIN',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Csokis muffin, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['oretor'] = {
		label = 'OREOTORTA',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Oreós torta, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['fetort'] = {
		label = 'FEKETE ERDŐTORTA',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Feketeerdő torta, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['yellowhotdog'] = {
		label = 'Yellow Hotdog',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Hot dog a Yellow étteremből, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['yellowtaco'] = {
		label = 'Yellow Taco',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Taco a Yellow étteremből, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['beleskedvence'] = {
		label = 'Beles Kedvence',
		weight = 0.2,
		stack = true,
		close = true,
		description = "A ház specialitása a Yellow étteremből, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['yellowbbyribs'] = {
		label = 'Yellow BBQ ribs',
		weight = 0.2,
		stack = true,
		close = true,
		description = "BBQ oldalas a Yellow étteremből, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},


	['breadfresh'] = {
		label = 'tégla',
		weight = 0,
		stack = true,
		close = true,
		description = "Frissen sült kenyér, egy egész vekni."
	},

	['brokenfishingrod'] = {
		label = 'törött horgászbot',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Elhasznált horgászbot; javításra vagy leadásra vár."
	},

	['bshake'] = {
		label = 'banános shake',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Banános turmix, 10%-kal oltja a szomjúságot."
	},

	['bulletproof'] = {
		label = 'golyóálló mellény',
		weight = 100,
		stack = true,
		close = true,
		description = "Golyóálló mellény."
	},

	['bulletproofvest'] = {
		label = 'golyóálló mellény',
		weight = 100,
		stack = true,
		close = true,
		description = "Golyóálló mellény; felvéve páncélt ad."
	},

	['bullpuprifle'] = {
		label = 'type 86-s',
		weight = 3.59,
		stack = true,
		close = true,
		description = "Type 86 bullpup gépkarabély."
	},

	['bullpupshotgun'] = {
		label = 'kel-tec ksg',
		weight = 3.1,
		stack = true,
		close = true,
		description = "Kel-Tec KSG sörétes puska."
	},

	['c4'] = {
		label = 'c4 (Sima)',
		weight = 1,
		stack = true,
		close = true,
		description = "C4 robbanótöltet ajtók és széfek felnyitásához."
	},

	['cannabis'] = {
		label = 'kannabisz',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Nyers kannabisz; feldolgozásra vár."
	},

	['capa'] = {
		label = 'cápa',
		weight = 0,
		stack = true,
		close = true,
		description = "Cápa; a nyílt tenger ritka fogása."
	},

	['carbinerifle'] = {
		label = 'm4a1',
		weight = 3.6,
		stack = true,
		close = true,
		description = "M4A1 gépkarabély."
	},

	['carbinerifle_mk2'] = {
		label = 'carbinerifle_mk2',
		weight = 3.52,
		stack = true,
		close = true,
		description = "M4A1 MK2, felújított gépkarabély."
	},

	['card'] = {
		label = 'belépőkártya',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Belépőkártya zárt területekhez."
	},

	['carotool'] = {
		label = 'eszközök',
		weight = 2,
		stack = true,
		close = true,
		description = "Szerszámkészlet apróbb javításokhoz."
	},

	['carparts'] = {
		label = 'autóalkatrész',
		weight = 0,
		stack = true,
		close = true,
		description = "Autóalkatrész javításhoz és összeszereléshez."
	},

	['carteidentite'] = {
		label = 'személyi igazolvány',
		weight = 1,
		stack = true,
		close = true,
		description = "Személyazonosító igazolvány."
	},

	['cartire'] = {
		label = 'kocsi kerék',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Autógumi kerékcseréhez."
	},

	['ceruza'] = {
		label = 'ceruza',
		weight = 1,
		stack = true,
		close = true,
		description = "Ceruza jegyzeteléshez."
	},

	['champagne'] = {
		label = 'pezsgő',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Habzó pezsgő, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['chaser'] = {
		label = 'chaser choco bar',
		weight = 1,
		stack = true,
		close = true,
		description = "Csokoládészelet a gyors energiához."
	},

	['clothe'] = {
		label = 'Öltöztet',
		weight = 1,
		stack = true,
		close = true,
		description = "Ruhacsomag átöltözéshez."
	},

	['coca'] = {
		label = 'kokain levél',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kokacserje levele; a kokain alapanyaga."
	},

	['coca_seed'] = {
		label = 'kokain mag',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kokamag ültetéshez."
	},

	['cocacola'] = {
		label = 'Street Cola',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Utcai kóla, 40%-kal oltja a szomjúságot."
	},

	['jegeskavec'] = {
		label = 'JEGESKÁVÉ',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Jeges kávé, 40%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['naracslee'] = {
		label = 'NARANCSLÉ',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Frissen facsart narancslé, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['msmcs'] = {
		label = 'MANGOS SÁRKÁNYGYÜMÖLCSÖS JUICE',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Mangós-sárkánygyümölcsös juice, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['mcffem'] = {
		label = 'MOZART-COFFE',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Kávékülönlegesség, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['mcshse'] = {
		label = 'MILK CARAMEL SHAKE',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Karamellás tejturmix, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['yellowcola'] = {
		label = 'Yellow Cola',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Kóla a Yellow étteremből, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['yellowlimonade'] = {
		label = 'Yellow Limonádé',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Limonádé a Yellow étteremből, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['yellownaracsle'] = {
		label = 'Yellow Narancslé',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Narancslé a Yellow étteremből, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['yellowvodka'] = {
		label = 'Yellow Vodka',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Vodka a Yellow étteremből, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['yellowwhisky'] = {
		label = 'Yellow Whiskey',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Whiskey a Yellow étteremből, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['yallowcoronasor'] = {
		label = 'Yellow Corona Sör',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Corona sör a Yellow étteremből, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['seed_ecstasy'] = {
		label = 'Mag Ecstasy',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Ecstasy alapanyagának magja; ültetvényen termeszthető."
	},

	['seed_varazsfagyi'] = {
		label = 'Mag Varázs Fagyi',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Varázs Fagyi alapanyagának magja; ültetvényen termeszthető."
	},

	['seed_varazsgomba'] = {
		label = 'Mag Varázs Gomba',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Varázs Gomba magja; ültetvényen termeszthető."
	},
	
	['seed_gatya'] = {
		label = 'Mag Gatya',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Gatya alapanyagának magja; ültetvényen termeszthető."
	},

	['gatya'] = {
		label = 'Gatya',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Erős utcai szer; 45 másodpercig gyorsabb futás, gyógyulás és páncél, de tántorogsz tőle."
	},

	['ecstasy'] = {
		label = 'Ecstasy',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Tabletta a bulikra; 45 másodpercig gyorsabban futsz és páncélt kapsz, cserébe imbolyogsz."
	},

	['varazsfagyi'] = {
		label = 'Varázs Fagyi',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kábító hatású fagylalt; 45 másodpercre elszáll a valóság, közben páncélt ad."
	},

	['varazsgomba'] = {
		label = 'Varázs Gomba',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Hallucinogén gomba; 45 másodpercig kábít, közben regenerálja az életerődet."
	},

	['drogtomb_ecstasy'] = {
		label = 'Drog Tömb',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Feldolgozott ecstasy tömb; adagokra bontható."
	},

	['drogtomb_varazsfagyi'] = {
		label = 'Drog Tömb',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Feldolgozott Varázs Fagyi tömb; adagokra bontható."
	},

	['drogtomb_varazsgomba'] = {
		label = 'Drog Tömb',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Feldolgozott Varázs Gomba tömb; adagokra bontható."
	},

	['drogtomb_gatya'] = {
		label = 'Drog Tömb',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Feldolgozott Gatya tömb; adagokra bontható."
	},	

	['cocaine'] = {
		label = 'Kokain',
		weight = 0.1,
		stack = true,
		close = true,
		degrade = 10080,  -- 7 nap percben
		decay = true,     -- lejáratkor magától törlődik
		-- consume-ot NEM kap: a használatot az esx_basicneeds drugs.lua kezeli (effekt+anim+levonás)
		description = "Kokain; felszippantva 55 másodpercig gyorsabb futás, gyógyulás és páncél, de zavaros lesz a látásod."
	},

	['cocainebrick'] = {
		label = 'Kokain Tömb',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Préselt kokaintömb; adagokra bontható."
	},

	['cocaine_processing_table'] = {
		label = 'kokain feldolgozó asztal',
		weight = 5,
		stack = true,
		close = true,
		description = "Kokain feldolgozó asztal; a nyers levélből készít terméket."
	},

	['coke10g'] = {
		label = 'kokain (10g)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Tíz gramm kokain utcai eladásra."
	},

	['coke1g'] = {
		label = 'kokain (1g)',
		weight = 0.001,
		stack = true,
		close = true,
		description = "Egy gramm kokain, egyetlen adag."
	},

	['cokebrick'] = {
		label = 'kokain tégla (100g)',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Száz grammos kokaintégla nagybani eladásra."
	},

	['colis'] = {
		label = 'colis',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Csomag, amely kézbesítésre vár."
	},

	['combatmg'] = {
		label = 'm249e1',
		weight = 1,
		stack = true,
		close = true,
		description = "M249E1 könnyű géppuska."
	},

	['combatpdw'] = {
		label = 'sig sauer mpx',
		weight = 1,
		stack = true,
		close = true,
		description = "SIG Sauer MPX géppisztoly."
	},

	['combatpistol'] = {
		label = 'sig sauer p228',
		weight = 1.01,
		stack = true,
		close = true,
		description = "SIG Sauer P228 pisztoly."
	},

	['compactrifle'] = {
		label = 'micro draco ak pisztoly',
		weight = 3.2,
		stack = true,
		close = true,
		description = "Micro Draco, rövidített AK pisztoly."
	},

	['contract'] = {
		label = 'Szerződés',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Aláírásra váró szerződés."
	},

	['contract2'] = {
		label = 'Szerződés Új',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Új típusú szerződés üzletek és megállapodások rögzítéséhez.",
		consume = 0,
		server = {
            export = "bc_contract.useContract"
        },
	},

	['contrat'] = {
		label = 'salvage',
		weight = 0,
		stack = true,
		close = true,
		description = "Bontási szerződés a roncstelepre."
	},

	['cookedmeat'] = {
		label = 'főtt hús',
		weight = 1,
		stack = true,
		close = true,
		description = "Tűzön sült hús, 10%-kal csillapítja az éhséget."
	},

	['copper'] = {
		label = 'Réz',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Réz; fegyver- és eszközgyártás alapanyaga."
	},

	['costa_del_perro'] = {
		label = 'costa del perro',
		weight = 1,
		stack = true,
		close = true,
		description = "Costa del Perro bor, egy egész üveggel."
	},

	['croquettes'] = {
		label = 'croquettes',
		weight = 20,
		stack = true,
		close = true,
		description = "Száraz állateledel."
	},

	['pethealth'] = {
		label = 'Állatélet',
		weight = 20,
		stack = true,
		close = true,
		description = "Kisállat gyógyszere; visszatölti az életerejét."
	},

	['petfood'] = {
		label = 'Állateledel',
		weight = 20,
		stack = true,
		close = true,
		description = "Kisállat eledele; csillapítja az éhségét."
	},

	['petthirst'] = {
		label = 'Állatvíz',
		weight = 20,
		stack = true,
		close = true,
		description = "Kisállat itala; oltja a szomjúságát."
	},

	['petrope'] = {
		label = 'Állatporáz',
		weight = 20,
		stack = true,
		close = true,
		description = "Póráz a kisállat sétáltatásához."
	},

	['petball'] = {
		label = 'Állatlabda',
		weight = 20,
		stack = true,
		close = true,
		description = "Labda, amivel a kisállatod játszani tud."
	},

	['crowbar'] = {
		label = 'pajszer',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Pajszer feszítéshez és betöréshez."
	},

	['atmjavito'] = {
		label = 'ATM javító',
		weight = 1,
		stack = true,
		close = true,
		description = "ATM javító készlet a meghibásodott bankautomatákhoz."
	},

	['pajszerr'] = {
		label = 'Feszítővas (AirDrop)',
		weight = 2,
		stack = true,
		close = true,
		description = "Feszítővas az airdrop ládák felnyitásához."
	},

	['crushedstone'] = {
		label = 'tört kő',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Zúzott kő; építőanyag."
	},

	['pfegyverlada'] = {
		label = 'Pérmium Fegyverláda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Prémium fegyverláda; ritka fegyvereket rejt."
	},

	['fegyverlada'] = {
		label = 'Fegyverláda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Fegyverláda; nyitáskor véletlenszerű fegyvert ad."
	},

	['autolada'] = {
		label = 'Autóláda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Autóláda; véletlenszerű jármű nyerhető belőle."
	},

	['autolada2'] = {
		label = 'Autóláda Prémium2',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Prémium autóláda, értékesebb járművek esélyével."
	},
	
	['csgocase'] = {
		label = 'fegyverláda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Fegyverláda; nyitáskor véletlenszerű fegyvert ad."
	},

	['karacsonyilada'] = {
		label = 'Karácsonyi Láda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Karácsonyi ajándékláda ünnepi jutalmakkal."
	},

	['keslada'] = {
		label = 'CS Kés láda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Késláda; egyedi kések közül sorsol egyet."
	},

	['bennystaska'] = {
		label = 'Táska láda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Táskaláda; egy véletlenszerű hátizsákot rejt."
	},

	['blackmambataska'] = {
		label = 'BlackMamba Táska láda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "BlackMamba táskaláda különleges hátizsákokkal."
	},

	['csgocase2'] = {
		label = 'autó láda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Autóláda; véletlenszerű járművet ad."
	},

	['csgocase3'] = {
		label = 'autó láda (kiemelt)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Kiemelt autóláda, a jobb járművek esélyével."
	},

	['blackoldlimit'] = {
		label = 'Black Láda Limit',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Limitált Black láda ritka nyereményekkel."
	},

	['csshake'] = {
		label = 'csokis shake',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Csokis turmix, 10%-kal oltja a szomjúságot."
	},

	['cukorka2'] = {
		label = 'Cukorka (Halloween Event)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Halloweeni cukorka; az esemény gyűjthető darabja."
	},

	['cukorka3'] = {
		label = 'Cukorka (Halloween Event 2025)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "A 2025-ös halloweeni esemény cukorkája."
	},

	['cutted_wood'] = {
		label = 'vágott fa',
		weight = 1,
		stack = true,
		close = true,
		description = "Kivágott farönk; feldolgozásra vár."
	},

	['dagger'] = {
		label = 'tőr',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Tőr; rejthető szúrófegyver."
	},

	['deadbatteries'] = {
		label = 'lemerült elemek',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Lemerült elemek; hulladékként leadható."
	},

	['deer_horn'] = {
		label = 'Őz agancs',
		weight = 1,
		stack = true,
		close = true,
		description = "Őzagancs; vadászzsákmány, felvásárlónál értékes."
	},

	['digiscanner'] = {
		label = 'digitális szkenner',
		weight = 0,
		stack = true,
		close = true,
		description = "Digitális szkenner jelek és eszközök felderítéséhez."
	},

	['disabler'] = {
		label = 'jelkövető eltávolító',
		weight = 0,
		stack = true,
		close = true,
		description = "Jeladó-eltávolító; leszedi a járműre tett nyomkövetőt."
	},

	['dlcard'] = {
		label = 'vezetöiengedély',
		weight = 0,
		stack = true,
		close = true,
		description = "Vezetői engedély kártya."
	},

	['doubleaction'] = {
		label = 'doubleaction',
		weight = 0,
		stack = true,
		close = true,
		description = "Double Action revolver."
	},

	['dragonballcocktail'] = {
		label = 'dragon ball cocktail',
		weight = 5,
		stack = true,
		close = true,
		description = "Dragon Ball koktél a bárpultról."
	},

	['drill'] = {
		label = 'fúró (Sima)',
		weight = 1,
		stack = true,
		close = true,
		description = "Fúrógép széfek és zárak megbontásához."
	},

	['hackingphone'] = {
		label = 'Fekete Phone',
		weight = 1,
		stack = true,
		close = true,
		description = 'Vonat rabláshoz szükséges.'
		},

	['drivelicense'] = {
		label = 'jogosítvány',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Jogosítvány; vezetéshez szükséges okmány."
	},

	['drugbags'] = {
		label = 'tasak',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Üres tasak a drogok adagolásához."
	},

	['drugitem'] = {
		label = 'fekete usb-c',
		weight = 1,
		stack = true,
		close = true,
		description = "Fekete USB-C eszköz; illegális adatokat tárol."
	},

	['duffbeer'] = {
		label = 'duff beer',
		weight = 5,
		stack = true,
		close = true,
		description = "Duff sör, egy egész dobozzal."
	},

	['dvrcocktail'] = {
		label = 'dvr cocktail',
		weight = 5,
		stack = true,
		close = true,
		description = "DVR koktél a bárpultról."
	},

	['efdrive'] = {
		label = 'encrypted flash drive',
		weight = 50,
		stack = true,
		close = true,
		description = "Titkosított pendrive érzékeny adatokkal."
	},

	['electronics'] = {
		label = 'elektronika',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Elektronikai alkatrészek gyártáshoz és javításhoz."
	},

	['emerald'] = {
		label = 'smaragd',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Smaragd; bányászott drágakő."
	},

	['emerald2'] = {
		label = 'Emeráld',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Csiszolt smaragd; ékszerésznél értékes."
	},

	['essence'] = {
		label = 'gáz',
		weight = 1,
		stack = true,
		close = true,
		description = "Üzemanyag kannában."
	},

	['fabric'] = {
		label = 'szövet',
		weight = 1,
		stack = true,
		close = true,
		description = "Szövet; ruhagyártás alapanyaga."
	},

	['fank'] = {
		label = 'fánk',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Cukros fánk, 10%-kal csillapítja az éhséget."
	},

	['fanta'] = {
		label = 'Citrus Spark',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Citrusos üdítő, 40%-kal oltja a szomjúságot."
	},

	['egribika'] = {
		label = 'Egri bikavér',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Egri bikavér, testes vörösbor, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['pepsi'] = {
		label = 'Pep Cola',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Szénsavas kóla, 40%-kal oltja a szomjúságot."
	},

	['fcsoki'] = {
		label = 'forró csoki',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Gőzölgő forró csoki, 40%-kal oltja a szomjúságot."
	},

	['fdrive'] = {
		label = 'flash drive',
		weight = 50,
		stack = true,
		close = true,
		description = "Pendrive adatok tárolására."
	},

	['fertilizer'] = {
		label = 'tápanyag',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Tápanyag a növényeknek; gyorsítja a növekedést."
	},

	['firework'] = {
		label = 'tüzijáték',
		weight = 0,
		stack = true,
		close = true,
		description = "Tűzijáték; látványos égi show."
	},

	['fish'] = {
		label = 'hal',
		weight = 1,
		stack = true,
		close = true,
		description = "Kifogott hal, a horgászok zsákmánya."
	},

	['fixkit'] = {
		label = 'javító készlet',
		weight = 3,
		stack = true,
		close = true,
		description = "Javítókészlet a jármű helyreállításához."
	},

	['fixserver'] = {
		label = 'szerverdoboz javítása',
		weight = 1,
		stack = true,
		close = true,
		description = "Szerverjavító készlet a meghibásodott géphez."
	},

	['fixtool'] = {
		label = 'javító készlet',
		weight = 2,
		stack = true,
		close = true,
		description = "Szerszámkészlet javításokhoz."
	},

	['flashlight'] = {
		label = 'zseblámpa',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Zseblámpa; sötétben világít."
	},

	['fshake'] = {
		label = 'fehérje shake',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Fehérjeturmix edzés utánra, 10%-kal oltja a szomjúságot."
	},

	['fsuger'] = {
		label = 'fekete sügér',
		weight = 0,
		stack = true,
		close = true,
		description = "Fekete sügér; ragadozó édesvízi hal."
	},

	['fuel'] = {
		label = 'benzin',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Üzemanyag kannában, tankoláshoz."
	},

	['fuzet'] = {
		label = 'fuzet',
		weight = 1,
		stack = true,
		close = true,
		description = "Füzet jegyzetek és feljegyzések tárolására."
	},

	['gameboyadvance'] = {
		label = 'gameboy advance',
		weight = 1,
		stack = true,
		close = true,
		description = "Game Boy Advance; retro kézikonzol."
	},

	['garbagebag'] = {
		label = 'szemeteszsák',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Szemeteszsák a hulladék összegyűjtéséhez."
	},

	['gazbottle'] = {
		label = 'gázpalack',
		weight = 2,
		stack = true,
		close = true,
		description = "Gázpalack vágáshoz és fűtéshez."
	},

	['glass_costa_del_perro'] = {
		label = 'bor',
		weight = 1,
		stack = true,
		close = true,
		description = "Pohár Costa del Perro bor."
	},

	['glass_rockford_hill'] = {
		label = 'vodka',
		weight = 1,
		stack = true,
		close = true,
		description = "Pohár Rockford Hill vodka."
	},

	['glass_vinewood_blanc'] = {
		label = 'glass vinewood sauvignon blanc',
		weight = 1,
		stack = true,
		close = true,
		description = "Pohár Vinewood Sauvignon Blanc."
	},

	['glass_vinewood_red'] = {
		label = 'whisky',
		weight = 1,
		stack = true,
		close = true,
		description = "Pohár Vinewood vörösbor."
	},

	['glassbottle'] = {
		label = 'Üveg palack',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Üres üvegpalack; újratölthető."
	},

	['gold'] = {
		label = 'Bank Arany',
		weight = 1,
		stack = true,
		close = true,
		description = "Bankból származó aranyrúd; nehéz, de rengeteget ér."
	},

	['aranyrogdarab'] = {
		label = 'Arany Rög Darab',
		weight = 1,
		stack = true,
		close = true,
		description = "Aranyrög darabja; beolvasztásra vár."
	},

	['goldnecklace'] = {
		label = 'arany nyaklánc',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Arany nyaklánc; ékszerésznél pénzzé tehető."
	},

	['goldwatch'] = {
		label = 'arany óra',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Arany karóra; a házrablások keresett zsákmánya."
	},

	['golfclub'] = {
		label = 'golfütő',
		weight = 1,
		stack = true,
		close = true,
		description = "Golfütő; szükség esetén ütőfegyver."
	},

	['grip'] = {
		label = 'markolat',
		weight = 2,
		stack = true,
		close = true,
		description = "Markolat; fegyverre szerelhető kiegészítő."
	},

	['gtagamecard'] = {
		label = 'gta game card',
		weight = 1,
		stack = true,
		close = true,
		description = "GTA játékkártya a retro konzolhoz."
	},

	['gusenberg'] = {
		label = 'm1928a1 thompson smg',
		weight = 4.9,
		stack = true,
		close = true,
		description = "M1928A1 Thompson géppisztoly."
	},

	['gym_membership'] = {
		label = 'gym jegy',
		weight = 0,
		stack = true,
		close = true,
		description = "Konditermi bérlet; belépést ad az edzésekhez."
	},

	['gymei'] = {
		label = 'gym energia ital',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Energiaital a konditerembe, 10%-kal oltja a szomjúságot."
	},

	['hackerdevice'] = {
		label = 'hacker laptop',
		weight = 1,
		stack = true,
		close = true,
		description = "Hacker laptop rendszerek feltöréséhez."
	},

	['hagyma'] = {
		label = 'hagyma',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Nyers vöröshagyma, 10%-kal csillapítja az éhséget."
	},

	['hammerwirecutter'] = {
		label = 'kalapács és drótvágó',
		weight = 1,
		stack = true,
		close = true,
		description = "Kalapács és drótvágó bontáshoz."
	},

	['handcuff'] = {
		label = 'bilincs',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bilincs; a megbilincselt személy nem tud elmenekülni."
	},

	['bilincs'] = {
		label = 'bilincs',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bilincs; a megbilincselt személy nem tud elmenekülni."
	},

	['harcsa'] = {
		label = 'harcsa',
		weight = 0,
		stack = true,
		close = true,
		description = "Harcsa; nagy testű ragadozó hal."
	},

	['haribo'] = {
		label = 'Gumi Cuki',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Színes gumicukor, 40%-kal csillapítja az éhséget."
	},


	['heavypistol'] = {
		label = 'ewb 1911',
		weight = 1.1,
		stack = true,
		close = true,
		description = "EWB 1911 nehézpisztoly."
	},

	['heavyshotgun'] = {
		label = 'saiga-12k',
		weight = 3.5,
		stack = true,
		close = true,
		description = "Saiga-12K automata sörétes puska."
	},

	['henessy'] = {
		label = 'henessy',
		weight = 0.6,
		stack = true,
		close = true,
		description = "Nemes konyak, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['hotdog'] = {
		label = 'hotdog',
		weight = 1,
		stack = true,
		close = true,
		description = "Extra: Gyors futás,Gyors uszás, Pajzs"
	},

	['hqscale'] = {
		label = 'high quality scale',
		weight = 1,
		stack = true,
		close = true,
		description = "Pontos digitális mérleg az adagoláshoz."
	},

	['hulkcockail'] = {
		label = 'hulk cockail',
		weight = 5,
		stack = true,
		close = true,
		description = "Hulk koktél a bárpultról."
	},

	['idcard'] = {
		label = 'személyi igazolvány2',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Személyi igazolvány; hivatalos azonosító okmány."
	},

	['buvarengedely'] = {
		label = 'Buvár igazolvány2',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Búvárigazolvány; a merüléshez szükséges engedély."
	},

	['horgaszengedely'] = {
		label = 'Horgász igazolvány2',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Horgászengedély; a horgászathoz kötelező."
	},

	['kamionengedely'] = {
		label = 'Kamion igazolvány2',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kamionos jogosítvány a nehéz járművek vezetéséhez."
	},

	['buszosmunka'] = {
		label = 'Buszos engedély',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Buszvezetői engedély a tömegközlekedési munkához."
	},

	['banyaszengedely'] = {
		label = 'Bányász igazolvány2',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bányászengedély a bányában végzett munkához."
	},

	['vadaszengedely'] = {
		label = 'Vadász igazolvány2',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Vadászengedély; a vadászathoz szükséges papír."
	},

	['identitycard'] = {
		label = 'személyi igazolvány',
		weight = 1,
		stack = true,
		close = true,
		description = "Személyazonosító igazolvány."
	},

	['iron'] = {
		label = 'Vas',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Vas; gyártás és fegyverkészítés alapanyaga."
	},

	['jamesbondcocktail'] = {
		label = 'jamesbond cocktail',
		weight = 5,
		stack = true,
		close = true,
		description = "James Bond koktél a bárpultról."
	},

	['jeton'] = {
		label = 'zseton',
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinózseton; a játékasztaloknál használható."
	},

	['jewels'] = {
		label = 'Ékszer Arany',
		weight = 1,
		stack = true,
		close = true,
		description = "Ékszerboltból származó arany, a rablások zsákmánya."
	},

	['nemzetiarany'] = {
		label = 'Nemzeti Arany',
		weight = 1,
		stack = true,
		close = true,
		description = "A nemzeti bank aranyrúdja; a legnagyobb fogások egyike."
	},

	['joint2g'] = {
		label = 'dzsoint (2g)',
		weight = 0.02,
		stack = true,
		close = true,
		description = "Kétgrammos dzsoint, elszívásra kész."
	},

	['karasz'] = {
		label = 'kárász',
		weight = 0,
		stack = true,
		close = true,
		description = "Kárász; gyakori édesvízi hal."
	},

	['kcsiga'] = {
		label = 'kakaós csiga',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Kakaós csiga, 40%-kal csillapítja az éhséget."
	},

	['kitavanzato'] = {
		label = 'speciális javítókészlet',
		weight = 0,
		stack = true,
		close = true,
		description = "Speciális javítókészlet; a súlyosabb hibákat is orvosolja."
	},

	['knife'] = {
		label = 'kés',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Kés; közelharci penge."
	},

	['kolbasz'] = {
		label = 'kolbász',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Füstölt kolbász, 10%-kal csillapítja az éhséget."
	},

	['labsample'] = {
		label = 'lab sample',
		weight = 50,
		stack = true,
		close = true,
		description = "Laborminta; vizsgálatra váró anyag."
	},

	['langos'] = {
		label = 'lángos',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Fokhagymás lángos, 10%-kal csillapítja az éhséget."
	},

	['laptop'] = {
		label = 'Laptop (Nemzeti/Bank)',
		weight = 0,
		stack = true,
		close = true,
		description = "Laptop a bankrabláshoz; a rendszerek feltöréséhez kell."
	},

	['keycard'] = {
		label = 'Keycard (Nemzeti)',
		weight = 0,
		stack = true,
		close = true,
		description = "Belépőkártya a nemzeti bank zárt ajtajaihoz."
	},

	['robbery_ingot_silver_01'] = {
		label = 'Ezüst Rúd',
		weight = 0,
		stack = true,
		close = true,
		description = "Ezüstrúd; rablásból származó nemesfém."
	},

	['robbery_ingot_gold_01'] = {
		label = 'Arany Rúd',
		weight = 0,
		stack = true,
		close = true,
		description = "Aranyrúd; rablásból származó nemesfém."
	},

	['lays'] = {
		label = 'Csipsz',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Sós burgonyachips, 40%-kal csillapítja az éhséget."
	},

	['cappuccino'] = {
		label = 'Cappuccino',
		weight = 2,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	['espresso'] = {
		label = 'espresso',
		weight = 2,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	['limonade'] = {
		label = 'limonade',
		weight = 2,
		stack = true,
		close = true,
		description = "Extra: Gyors futás,Gyors uszás, Pajzs, Töltés 20%"
	},

	['smoothie'] = {
		label = 'Smoothie',
		weight = 2,
		stack = true,
		close = true,
		description = "Extra: Gyors futás,Gyors uszás, Pajzs, Töltés 20%"
	},

	['milkshake'] = {
		label = 'Milkshake',
		weight = 2,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	['leather_boar_bad'] = {
		label = 'rossz disznó bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Sérült vaddisznóbőr; keveset fizetnek érte."
	},

	['leather_boar_good'] = {
		label = 'jó disznó bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Jó minőségű vaddisznóbőr; tisztes árat ad."
	},

	['leather_boar_perfect'] = {
		label = 'tökéletes disznó bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Hibátlan vaddisznóbőr; a legjobb árat éri el."
	},

	['leather_chickenhawk_bad'] = {
		label = 'rossz csirkekötő bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Sérült csirkeölyv-bőr; keveset fizetnek érte."
	},

	['leather_chickenhawk_good'] = {
		label = 'jó csirkekötő bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Jó minőségű csirkeölyv-bőr; tisztes árat ad."
	},

	['leather_chickenhawk_perfect'] = {
		label = 'tökéletes csirkekötő bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Hibátlan csirkeölyv-bőr; a legjobb árat éri el."
	},

	['leather_cormorant_bad'] = {
		label = 'rossz kormorán bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Sérült kárókatona-bőr; keveset fizetnek érte."
	},

	['leather_cormorant_good'] = {
		label = 'jó kormorán bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Jó minőségű kárókatona-bőr; tisztes árat ad."
	},

	['leather_cormorant_perfect'] = {
		label = 'tökéletes kormorán bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Hibátlan kárókatona-bőr; a legjobb árat éri el."
	},

	['leather_coyote_bad'] = {
		label = 'rossz prérifarkas bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Sérült prérifarkasbőr; keveset fizetnek érte."
	},

	['leather_coyote_good'] = {
		label = 'jó prérifarkas bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Jó minőségű prérifarkasbőr; tisztes árat ad."
	},

	['leather_coyote_perfect'] = {
		label = 'tökéletes prérifarkas bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Hibátlan prérifarkasbőr; a legjobb árat éri el."
	},

	['leather_deer_bad'] = {
		label = 'rossz őz bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Sérült őzbőr; keveset fizetnek érte."
	},

	['leather_deer_good'] = {
		label = 'jó őz bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Jó minőségű őzbőr; tisztes árat ad."
	},

	['leather_deer_perfect'] = {
		label = 'tökéletes őz bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Hibátlan őzbőr; a legjobb árat éri el."
	},

	['leather_mlion_bad'] = {
		label = 'rossz hegyi oroszlán bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Sérült hegyioroszlán-bőr; keveset fizetnek érte."
	},

	['leather_mlion_good'] = {
		label = 'jó hegyi oroszlán bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Jó minőségű hegyioroszlán-bőr; tisztes árat ad."
	},

	['leather_mlion_perfect'] = {
		label = 'tökéletes hegyi oroszlán bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Hibátlan hegyioroszlán-bőr; a legjobb árat éri el."
	},

	['leather_rabbit_bad'] = {
		label = 'rossz nyúl bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Sérült nyúlbőr; keveset fizetnek érte."
	},

	['leather_rabbit_good'] = {
		label = 'jó nyúl bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Jó minőségű nyúlbőr; tisztes árat ad."
	},

	['leather_rabbit_perfect'] = {
		label = 'tökéletes nyúl bőr',
		weight = 1,
		stack = true,
		close = true,
		description = "Hibátlan nyúlbőr; a legjobb árat éri el."
	},

	['legbrace'] = {
		label = 'lábmerevítő',
		weight = 0,
		stack = true,
		close = true,
		description = "Lábmerevítő a sérült láb rögzítésére."
	},

	['letter'] = {
		label = 'levél',
		weight = 0,
		stack = true,
		close = true,
		description = "Kézzel írt levél; elolvasható üzenet."
	},

	['license'] = {
		label = 'vezetői engedély',
		weight = 1,
		stack = true,
		close = true,
		description = "Vezetői engedély; ellenőrzéskor felmutatható."
	},

	['machete'] = {
		label = 'bozótvágó',
		weight = 3,
		stack = true,
		close = true,
		description = "Machete; közelharci vágófegyver."
	},

	['machinepistol'] = {
		label = 'tec-9',
		weight = 1.23,
		stack = true,
		close = true,
		description = "TEC-9 géppisztoly."
	},

	['maka'] = {
		label = 'cement',
		weight = 0,
		stack = true,
		close = true,
		description = "Cement; építkezéshez és felújításhoz."
	},

	['makrsmanrifle'] = {
		label = 'm39 emr',
		weight = 5.9,
		stack = true,
		close = true,
		description = "M39 EMR mesterlövész-puska."
	},

	['marijuana'] = {
		label = 'marihuána',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Szárított marihuána, eladásra kész."
	},

	['mariogamecard'] = {
		label = 'mario game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Mario játékkártya a retro konzolhoz."
	},

	['mariokart64gamecard'] = {
		label = 'mario kart 64 game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Mario Kart 64 játékkártya a retro konzolhoz."
	},

	['marksmanpistol'] = {
		label = 'thompson-center contender g2',
		weight = 2.1,
		stack = true,
		close = true,
		description = "Thompson Center Contender G2 távolsági pisztoly."
	},

	['marksmanrifle_mk2'] = {
		label = 'marksmanrifle_mk2',
		weight = 5.9,
		stack = true,
		close = true,
		description = "Felújított mesterlövész-puska MK2."
	},

	['marvelcocktail'] = {
		label = 'marvel cocktail',
		weight = 5,
		stack = true,
		close = true,
		description = "Marvel koktél a bárpultról."
	},

	['meat'] = {
		label = 'friss hús',
		weight = 1,
		stack = true,
		close = true,
		description = "Friss hús; főzéshez és feldolgozáshoz."
	},

	['medikit'] = {
		label = 'Mentőkészlet Régi',
		weight = 0.1,
		stack = true,
		close = true,
		description = 'Ez már egy használhatatlan tárgy, vásárold meg az új verzióját.'
	},

	['ujmedikit'] = {
		label = 'Mentőkészlet',
		weight = 0.1,
		stack = true,
		close = true,
		description = 'Ez a tárgy arra szolgált, hogy elsősegélyt tudj nyújtani.'
	},

	['meteorite'] = {
		label = 'meteorite choco bar',
		weight = 1,
		stack = true,
		close = true,
		description = "Meteorite csokoládészelet."
	},

	['meth10g'] = {
		label = 'meth (10g)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Tíz gramm metamfetamin utcai eladásra."
	},

	['meth1g'] = {
		label = 'meth (1g)',
		weight = 0.001,
		stack = true,
		close = true,
		description = "Egy gramm metamfetamin, egyetlen adag."
	},

	['methbrick'] = {
		label = 'meth tégla (100g)',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Száz grammos meth tégla nagybani eladásra."
	},

	['mg'] = {
		label = 'pkp pecheneg',
		weight = 8.7,
		stack = true,
		close = true,
		description = "PKP Pecheneg géppuska."
	},

	['microsmg'] = {
		label = 'micro smg',
		weight = 1.5,
		stack = true,
		close = true,
		description = "Micro SMG géppisztoly."
	},

	['milk'] = {
		label = 'tej',
		weight = 1,
		stack = true,
		close = true,
		description = "Friss tej a farmról."
	},

	['milkbucket'] = {
		label = 'vödör tej',
		weight = 1,
		stack = true,
		close = true,
		description = "Vödörnyi frissen fejt tej."
	},

	['milkdragon'] = {
		label = 'milk dragon',
		weight = 5,
		stack = true,
		close = true,
		description = "Milk Dragon tejes ital."
	},

	['minismg'] = {
		label = 'skorpion vz. 61',
		weight = 1.3,
		stack = true,
		close = true,
		description = "Skorpion vz. 61 géppisztoly."
	},

	['mjuice'] = {
		label = 'mangó juice',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Mangóital, 10%-kal oltja a szomjúságot."
	},

	['monitor'] = {
		label = 'monitor',
		weight = 1,
		stack = true,
		close = true,
		description = "Számítógép-monitor; elektronikai alkatrész."
	},

	['mortalcombatgamecard'] = {
		label = 'mortal combat game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Mortal Kombat játékkártya a retro konzolhoz."
	},

	['mouldybread'] = {
		label = 'Penészes kenyér',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Megpenészedett kenyér, 10%-kal csillapítja az éhséget."
	},

	['mount_whisky'] = {
		label = 'the mount whisky',
		weight = 1,
		stack = true,
		close = true,
		description = "The Mount whisky, egy egész üveggel."
	},

	['muffin'] = {
		label = 'muffin',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	['neckbrace'] = {
		label = 'nyakmerevítő',
		weight = 0,
		stack = true,
		close = true,
		description = "Nyakmerevítő a sérült nyak rögzítésére."
	},

	['needforspeedgamecard'] = {
		label = 'need for speed game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Need for Speed játékkártya a retro konzolhoz."
	},

	['nightstick'] = {
		label = 'gumibot',
		weight = 1,
		stack = true,
		close = true,
		description = "Gumibot; rendvédelmi kényszerítő eszköz."
	},

	['nitro'] = {
		label = 'nitro üveg',
		weight = 5,
		stack = true,
		close = true,
		description = "Nitro palack; a járműbe töltve rövid gyorsítást ad."
	},

	['nogo_vodka'] = {
		label = 'nogo vodka',
		weight = 1,
		stack = true,
		close = true,
		description = "NoGo vodka, egy egész üveggel."
	},

	['notepad'] = {
		label = 'notepad',
		weight = 1,
		stack = true,
		close = true,
		description = "Jegyzettömb feljegyzések írásához."
	},

	['oldring'] = {
		label = 'régi gyürü',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Régi gyűrű; ékszerésznél pénzzé tehető."
	},

	['oldshoe'] = {
		label = 'régi cipö',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Elhasznált cipő; a horgászzsákmány gyengébb fele."
	},

	['onepunchman'] = {
		label = 'one punch man cocktail',
		weight = 5,
		stack = true,
		close = true,
		description = "One Punch Man koktél a bárpultról."
	},

	['packaged_chicken'] = {
		label = 'csirkefilé',
		weight = 1,
		stack = true,
		close = true,
		description = "Csomagolt csirkefilé; boltba szállítható áru."
	},

	['packaged_plank'] = {
		label = 'csomagolt fa',
		weight = 1,
		stack = true,
		close = true,
		description = "Csomagolt faáru; feldolgozott alapanyag."
	},

	['pacmangamecard'] = {
		label = 'pacman game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Pac-Man játékkártya a retro konzolhoz."
	},

	['paintingf'] = {
		label = 'festmény nő',
		weight = 1,
		stack = true,
		close = true,
		description = "Női portré festmény; keresett műkincs."
	},

	['paintingg'] = {
		label = 'festmény',
		weight = 1,
		stack = true,
		close = true,
		description = "Festmény; orgazdánál értékes műkincs."
	},

	['patochebeer'] = {
		label = 'patoche beer',
		weight = 5,
		stack = true,
		close = true,
		description = "Patoche sör, egy egész üveggel."
	},

	['petrol'] = {
		label = 'olaj',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyersolaj; finomításra vár."
	},

	['petrol_raffin'] = {
		label = 'feldolgozott olaj',
		weight = 1,
		stack = true,
		close = true,
		description = "Finomított olaj; üzemanyag alapanyaga."
	},

	['pickaxe'] = {
		label = 'csákány',
		weight = 1,
		stack = true,
		close = true,
		description = "Csákány a bányászathoz."
	},

	['pistol'] = {
		label = 'colt m1911',
		weight = 1.2,
		stack = true,
		close = true,
		description = "Colt M1911 pisztoly."
	},

	['pistol_ammo_box'] = {
		label = 'pisztoly töltény doboz',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Doboznyi pisztolylőszer."
	},

	['pistol_mk2'] = {
		label = 'sig sauer p226',
		weight = 1,
		stack = true,
		close = true,
		description = "SIG Sauer P226 pisztoly."
	},

	['pistol50'] = {
		label = 'desert eagle',
		weight = 1.8,
		stack = true,
		close = true,
		description = "Desert Eagle, nagy kaliberű pisztoly."
	},

	['pistolbelso'] = {
		label = 'pisztoly Belsőszerkezet',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez szükséges belső szerkezet (Pistol, Pistol MK2, Heavy Pistol)."
	},

	['pistolcso'] = {
		label = 'pisztoly Cső',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez szükséges cső (Pistol, Pistol MK2, Heavy Pistol)."
	},

	['pistoltar'] = {
		label = 'pisztoly Tár',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez szükséges tár (Pistol, Pistol MK2, Heavy Pistol)."
	},

	['fnsevetar'] = {
		label = 'FnSeven Tár',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fnseven elkészítéséhez szükséges tár."
	},

	['fnsevecso'] = {
		label = 'FnSeven Cső',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fnseven elkészítéséhez szükséges cső."
	},

	['fnsevebelso'] = {
		label = 'FnSeven Belsőszerkezet',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fnseven elkészítéséhez szükséges belső szerkezet."
	},

	['piswasser'] = {
		label = 'pißwasser',
		weight = 1,
		stack = true,
		close = true,
		description = "Pißwasser sör, egy egész üveggel."
	},

	['pixellaptop'] = {
		label = 'autó hacker laptop',
		weight = 0,
		stack = true,
		close = true,
		description = "Hacker laptop járművek feltöréséhez."
	},

	['plasmacutter'] = {
		label = 'hegesztő',
		weight = 1,
		stack = true,
		close = true,
		description = "Plazmavágó fém átvágásához."
	},

	['plastic'] = {
		label = 'müanyag',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Műanyag alapanyag a gyártósorokhoz."
	},

	['plongee1'] = {
		label = 'plongee courte',
		weight = 1,
		stack = true,
		close = true,
		description = "Rövid merüléshez való búvárpalack."
	},

	['plongee2'] = {
		label = 'plongee longue',
		weight = 1,
		stack = true,
		close = true,
		description = "Hosszú merüléshez való búvárpalack."
	},

	['pokemonfireredgamecard'] = {
		label = 'pokemon fire red game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Pokémon Fire Red játékkártya a retro konzolhoz."
	},

	['ponty'] = {
		label = 'ponty',
		weight = 0,
		stack = true,
		close = true,
		description = "Ponty; a horgászok gyakori fogása."
	},

	['poolcue'] = {
		label = 'biliárd dákó',
		weight = 0,
		stack = true,
		close = true,
		description = "Biliárddákó; ütőfegyvernek is beválik."
	},

	['powerade'] = {
		label = 'powerade',
		weight = 0,
		stack = true,
		close = true,
		description = "Powerade sportital."
	},

	['ppa'] = {
		label = 'ppa',
		weight = 1,
		stack = true,
		close = true,
		description = "Ismeretlen tartalmú régi csomag; jelenleg nincs funkciója."
	},

	['protein_shake'] = {
		label = 'protein shake',
		weight = 0,
		stack = true,
		close = true,
		description = "Proteinturmix, 10%-kal oltja a szomjúságot."
	},

	['protein'] = {
		label = 'Fehérjepor',
		weight = 0,
		stack = true,
		close = true,
		description = "Fehérjepor turmixhoz és edzéshez."
	},

	['runbooster'] = {
		label = 'Erőnövelő ital',
		weight = 0,
		stack = true,
		close = true,
		description = "Erőnövelő ital; egy időre feljavítja a teljesítményed."
	},

	['pszenica'] = {
		label = 'sóder',
		weight = 0,
		stack = true,
		close = true,
		description = "Sóder; építkezéshez használt alapanyag."
	},

	['pumpshotgun'] = {
		label = 'remington 870',
		weight = 3.6,
		stack = true,
		close = true,
		description = "Remington 870 sörétes puska."
	},

	['pumpshotgun_mk2'] = {
		label = 'pumpshotgun mk2',
		weight = 3.6,
		stack = true,
		close = true,
		description = "Remington 870 MK2, felújított sörétes puska."
	},

	['raine'] = {
		label = 'raine water',
		weight = 1,
		stack = true,
		close = true,
		description = "Raine ásványvíz."
	},

	['regal'] = {
		label = 'chivas regal',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Skót whisky; 110 másodpercig alaposan a fejedbe száll."
	},

	['repairkit'] = {
		label = 'Szerelő láda Régi',
		weight = 3,
		stack = true,
		close = true,
		description = 'Ez már egy használhatatlan tárgy, vásárold meg az új verzióját.'
	},

	['ujrepairkit'] = {
		label = 'Szerelő láda',
		weight = 3,
		stack = true,
		close = true,
		description = 'Ez a tárgy arra szolgált, hogy a járművedet meg tudd vele javítani. 18–22 óra között nem használható.'
	},

	['ujrepairkitpremium'] = {
		label = 'Prémium Szerelő láda',
		weight = 3,
		stack = true,
		close = true,
		description = 'Ez egy értékes prémium szerelő láda, amelyet bármikor használhatsz, nincs időkorláthoz kötve. A tárgy kereskedhető, azonban lejárattal rendelkezik.'
	},

	['cleaningkit'] = {
		label = 'Autómosó rongy',
		weight = 1,
		stack = true,
		close = true,
		description = "Autómosó rongy a jármű külsejének tisztításához."
	},

	['revolver'] = {
		label = 'taurus raging bull',
		weight = 2.2,
		stack = true,
		close = true,
		description = "Taurus Raging Bull revolver."
	},

	['revolver_mk2'] = {
		label = 'revolver mk2',
		weight = 2.2,
		stack = true,
		close = true,
		description = "Felújított revolver MK2."
	},

	['rifle_ammo_box'] = {
		label = 'nagykaliber lőszer doboz',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Doboznyi nagy kaliberű puskalőszer."
	},

	['rockford_hill'] = {
		label = 'rockford hill reserve',
		weight = 1,
		stack = true,
		close = true,
		description = "Rockford Hill Reserve, minőségi bor."
	},

	['rolpaper'] = {
		label = 'rolling paper',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Cigarettapapír sodráshoz."
	},

	['rubber'] = {
		label = 'radír',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Gumi alapanyag a gyártósorokhoz."
	},

	['ruby'] = {
		label = 'rubint',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Rubin; csiszolt drágakő, ékszerésznél értékes."
	},

	['sawnoffshotgun'] = {
		label = 'mossberg 500',
		weight = 3.4,
		stack = true,
		close = true,
		description = "Lefűrészelt csövű Mossberg 500."
	},

	['scarfacecolada'] = {
		label = 'scarface colada',
		weight = 5,
		stack = true,
		close = true,
		description = "Scarface Colada koktél."
	},

	['scope'] = {
		label = 'scope',
		weight = 2,
		stack = true,
		close = true,
		description = "Céltávcső; fegyverre szerelhető."
	},

	['scratch_ticket'] = {
		label = 'sorsjegy',
		weight = 2,
		stack = true,
		close = true,
		description = "Kaparós sorsjegy; szerencsével nyereményt ér."
	},

	['sorsjegy_penzeso'] = {
		label = 'Pénzeső sorsjegy',
		weight = 2,
		stack = true,
		close = true,
		description = "Kaparós sorsjegy 5 bankjegyes játékkal; főnyeremény 150 000 $."
	},

	['sorsjegy_piramis'] = {
		label = 'Piramis sorsjegy',
		weight = 2,
		stack = true,
		close = true,
		description = "Kaparós sorsjegy; 3 egyforma szimbólum nyer. Főnyeremény 50 000 $."
	},

	['sorsjegy_casino'] = {
		label = 'Casino sorsjegy',
		weight = 2,
		stack = true,
		close = true,
		description = "Kaparós sorsjegy; egy sorban 3 egyforma nyer. Főnyeremény 90 000 $."
	},

	['sorsjegy_rubint'] = {
		label = 'Rubint sorsjegy',
		weight = 2,
		stack = true,
		close = true,
		description = "Kaparós sorsjegy; 9 kőből 3-at választhatsz. Főnyeremény 100 000 $."
	},

	['sorsjegy_aranyszef'] = {
		label = 'Aranyszéf sorsjegy',
		weight = 2,
		stack = true,
		close = true,
		description = "Kaparós sorsjegy 4 játékkal; főnyeremény 500 000 $."
	},

	['sorsjegy_platina'] = {
		label = 'Platina sorsjegy',
		weight = 2,
		stack = true,
		close = true,
		description = "Kaparós sorsjegy nyerőszámokkal; főnyeremény 450 000 $."
	},

	['tetto_jegy'] = {
		label = 'Teljes Tetoválás jegy (PP)',
		weight = 2,
		stack = true,
		close = true,
		description = "Jegy egy teljes tetoválás-szettre, a PP boltból."
	},

	['server'] = {
		label = 'szerver',
		weight = 1,
		stack = true,
		close = true,
		description = "Szervergép; elektronikai alkatrész."
	},

	['serverfan'] = {
		label = 'ventilátor',
		weight = 1,
		stack = true,
		close = true,
		description = "Szerverventilátor a hűtéshez."
	},

	['servergpu'] = {
		label = 'gpu',
		weight = 1,
		stack = true,
		close = true,
		description = "Videokártya; a szervergép alkatrésze."
	},

	['shot_mount_whisky'] = {
		label = 'shot mount whisky',
		weight = 1,
		stack = true,
		close = true,
		description = "Egy felest a The Mount whiskyből."
	},

	['shot_nogo_vodka'] = {
		label = 'shot nogo vodka',
		weight = 1,
		stack = true,
		close = true,
		description = "Egy felest a NoGo vodkából."
	},

	['shot_tequila'] = {
		label = 'shot tequilya',
		weight = 1,
		stack = true,
		close = true,
		description = "Egy felest a tequilából."
	},

	['shotgun_ammo_box'] = {
		label = 'shotgun töltény doboz',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Doboznyi sörétes töltény."
	},

	['shotgunbelso'] = {
		label = 'utas uts-15 belsőszerkezet',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Pump Shotgun elkészítéséhez szükséges belső szerkezet."
	},

	['shotguncso'] = {
		label = 'utas uts-15 cső',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Pump Shotgun elkészítéséhez szükséges cső."
	},

	['shotgunravasz'] = {
		label = 'utas uts-15 ravasz',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Pump Shotgun elkészítéséhez szükséges ravasz."
	},

	['shotguntar'] = {
		label = 'utas uts-15 tár',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Pump Shotgun elkészítéséhez szükséges tár."
	},

	['shotgunvaltamasz'] = {
		label = 'utas uts-15 válltámasz',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Pump Shotgun elkészítéséhez szükséges támasz."
	},

	['skin'] = {
		label = 'skin',
		weight = 2,
		stack = true,
		close = true,
		description = "Kinézet-csomag a megjelenés testreszabásához."
	},

	['slaughtered_chicken'] = {
		label = 'levágott csirke',
		weight = 1,
		stack = true,
		close = true,
		description = "Levágott csirke; feldolgozásra vár."
	},

	['smg'] = {
		label = 'mp5a3',
		weight = 2.4,
		stack = true,
		close = true,
		description = "MP5A3 géppisztoly."
	},

	['smg_ammo_box'] = {
		label = 'smg lőszer doboz',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Doboznyi géppisztoly-lőszer."
	},

	['mg_ammo_box'] = {
		label = 'smg lőszer doboz',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Doboznyi géppuska-lőszer."
	},

	['smk_mk2'] = {
		label = 'smg mk1',
		weight = 2.1,
		stack = true,
		close = true,
		description = "Felújított géppisztoly MK2."
	},

	['sniperrifle'] = {
		label = 'sniper',
		weight = 7,
		stack = true,
		close = true,
		description = "Mesterlövész-puska nagy távolságra."
	},

	['snspistol'] = {
		label = 'h&k p7',
		weight = 0.8,
		stack = true,
		close = true,
		description = "Heckler & Koch P7 pisztoly."
	},

	['sonicmaniacamecard'] = {
		label = 'sonic mania game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Sonic Mania játékkártya a retro konzolhoz."
	},

	['specialcarbine'] = {
		label = 'h&k g36c',
		weight = 3,
		stack = true,
		close = true,
		description = "Heckler & Koch G36C gépkarabély."
	},

	['sportlunch'] = {
		label = 'sportlunch',
		weight = 0,
		stack = true,
		close = true,
		description = "Sportlunch csokoládészelet."
	},

	['spray'] = {
		label = 'spray',
		weight = 1,
		stack = true,
		close = true,
		description = "Festékspray graffitihez."
	},

	['spray_remover'] = {
		label = 'spray remover',
		weight = 1,
		stack = true,
		close = true,
		description = "Festékoldó a felfújt graffiti eltávolításához."
	},

	['sprunk'] = {
		label = 'sprunk',
		weight = 1,
		stack = true,
		close = true,
		description = "Sprunk szénsavas üdítő."
	},

	['steel'] = {
		label = 'Acél',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Acél; fegyver- és gépgyártás alapanyaga."
	},

	['stinger'] = {
		label = 'stinger',
		weight = 0,
		stack = true,
		close = true,
		description = "Szögesakadály; kiterítve kilyukasztja a jármű gumijait."
	},

	['stone'] = {
		label = 'kő',
		weight = 1,
		stack = true,
		close = true,
		description = "Kő; bányászott alapanyag."
	},

	['stungun'] = {
		label = 'sokkoló',
		weight = 1.1,
		stack = true,
		close = true,
		description = "Sokkoló; rövid időre harcképtelenné teszi a célpontot."
	},


	['supersmashbrosgamecard'] = {
		label = 'super smash bros game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Super Smash Bros játékkártya a retro konzolhoz."
	},

	['superunocamecard'] = {
		label = 'super uno game card',
		weight = 1,
		stack = true,
		close = true,
		description = "Super Uno játékkártya a retro konzolhoz."
	},

	['supressor'] = {
		label = 'suppressor',
		weight = 2,
		stack = true,
		close = true,
		description = "Hangtompító; fegyverre szerelhető."
	},

	['switchblade'] = {
		label = 'pillangókés',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Pillangókés; könnyen rejthető közelharci penge."
	},

	['szemet'] = {
		label = 'szemét',
		weight = 0,
		stack = true,
		close = true,
		description = "Összeszedett szemét; a fémdetektoros keresés mellékterméke."
	},

	['tablet'] = {
		label = 'tablet',
		weight = 150,
		stack = true,
		close = true,
		description = "Tablet; a gyártósorok készterméke és használható eszköz."
	},

	['taco'] = {
		label = 'taco',
		weight = 1,
		stack = true,
		close = true,
		description = "Extra: Gyors futás,Gyors uszás, Pajzs"
	},

	['tec9belso'] = {
		label = 'tec9 belsőszerkezet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Machine Pistol elkészítéséhez szükséges belső szerkezet."
	},

	['tec9cso'] = {
		label = 'tec9 cső',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Machine Pistol elkészítéséhez szükséges cső."
	},

	['minismg_belso'] = {
		label = 'Minismg Belso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Mini SMG elkészítéséhez szükséges belső szerkezet."
	},

	['minismg_tar'] = {
		label = 'Minismg tar',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Mini SMG elkészítéséhez szükséges tár."
	},

	['minismg_cso'] = {
		label = 'Minismg cső',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Mini SMG elkészítéséhez szükséges cső."
	},

	['minismg_ravasz'] = {
		label = 'Minismg Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Mini SMG elkészítéséhez szükséges ravasz."
	},

	['tec9tar'] = {
		label = 'tec9 tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Machine Pistol elkészítéséhez szükséges tár."
	},

	['apmarkolat'] = {
		label = 'AP markolat',
		weight = 0.3,
		stack = true,
		close = true,
		description = "AP Pistol elkészítéséhez szükséges markolat."
	},

	['apravasz'] = {
		label = 'AP ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "AP Pistol elkészítéséhez szükséges ravasz."
	},

	['aptar'] = {
		label = 'AP tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "AP Pistol elkészítéséhez szükséges tár."
	},

	['apvaz'] = {
		label = 'AP Váz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "AP Pistol elkészítéséhez szükséges váz."
	},

	['teknos'] = {
		label = 'teknös',
		weight = 0,
		stack = true,
		close = true,
		description = "Teknős; ritka vízi fogás."
	},

	['tequila'] = {
		label = 'tequilya',
		weight = 1,
		stack = true,
		close = true,
		description = "Tequila, egy egész üveggel."
	},

	['thermite_bomb'] = {
		label = 'thermit bomba',
		weight = 1,
		stack = true,
		close = true,
		description = "Termit bomba zárak és ajtók átégetéséhez."
	},

	['ticket'] = {
		label = 'börtönjegy',
		weight = 0,
		stack = true,
		close = true,
		description = "Börtönjegy; a letöltendő büntetéshez tartozó papír."
	},

--Humaneuj---


	['robbery_keycard_01'] = {
		label = 'Humane Kártya',
		weight = 1,
		stack = true,
		close = true,
		description = "Belépőkártya a Humane Labs rablásához."
	},

	['hack_phone'] = {
		label = 'Humane Hacker Telefon',
		weight = 1,
		stack = true,
		close = true,
		description = "Hackertelefon a Humane Labs biztonsági rendszeréhez."
	},

	['thermite_humane'] = {
		label = 'Humane thermit',
		weight = 1,
		stack = true,
		close = true,
		description = "Termit töltet a Humane Labs ajtajaihoz."
	},

	['robbery_gascutter_01'] = {
		label = 'Humane Gázvágó',
		weight = 1,
		stack = true,
		close = true,
		description = "Gázvágó a Humane Labs rablásához."
	},
---humaneeeee vége-----

	['eventjegy'] = {
		label = 'Event Jegy',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Belépőjegy a szerver eseményeire."
	},

	['tok2'] = {
		label = 'Tök (Halloween Event)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Halloweeni tök; az esemény gyűjthető darabja."
	},

	['tok3'] = {
		label = 'Tök (Halloween Event 2025)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "A 2025-ös halloweeni esemény tökje."
	},

	['zselescukorka'] = {
		label = 'Zselés Cukorka (Karácsonyi Event 2025)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Zselés cukorka a 2025-ös karácsonyi eseményről."
	},

	['karicukor1'] = {
		label = 'Karácsonyi (Event 2025)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Karácsonyi cukorka a 2025-ös eseményről."
	},

	['tracker'] = {
		label = 'gps jeladó',
		weight = 0.2,
		stack = true,
		close = true,
		description = "GPS jeladó; járműre rögzítve követhető a mozgása."
	},

	["car_tracker"] = {
		label = "GPS Nyomkövető",
		weight = 1000,
		stack = true,
		close = true,
		description = "Járművek követésére alkalmas GPS nyomkövető eszköz."
	},

	["car_tracker_remover"] = {
		label = "GPS Nyomkövető Eltávolító",
		weight = 1000,
		stack = true,
		close = true,
		description = "A járművekre szerelt GPS nyomkövetők eltávolítására szolgáló eszköz."
	},

	['nyomkoveto_gps'] = {
		label = 'GPS lábbilincs',
		weight = 0.2,
		stack = true,
		close = true,
		description = 'Elektronikus lábbilincs beépített GPS-szel. Felhelyezve folyamatosan követhető a célpont tartózkodási helye.'
	},

	['gps_nyomkovetolathato'] = {
		label = 'GPS megfigyelő készülék',
		weight = 0.2,
		stack = true,
		close = true,
		description = 'Rendvédelmi nyomkövető eszköz, amely megjeleníti az aktív GPS lábbilincsek helyzetét a térképen.'
	},

	['ujtracker'] = {
		label = 'Gps jeladó',
		weight = 0.2,
		stack = true,
		close = true,
		description = 'Ez a tárgy arra szolgál, hogy a szervezetedet nyomon tudd követni.'
	},

	['szovigps'] = {
		label = 'Szövetséges GPS',
		weight = 0.2,
		stack = true,
		close = true,
		description = 'Ez a tárgy arra szolgál, hogy egy szervezettel szövetséget tudj kötni, illetve megszüntetni azt.'
	},

    ['traffipax'] = {
        label = 'Traffipax',
        weight = 3000,
        client = {
            event = 'rota_traffipax:startPlacer'
        },
        description = "Traffipax; kihelyezve méri az elhaladók sebességét.",
    },

	['uncutgem'] = {
		label = 'csiszolatlan értékes kő',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Csiszolatlan drágakő; feldolgozás után sokat ér."
	},

	['upmenu'] = {
		label = 'update menu',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Komplett menü, 10%-kal csillapítja az éhséget."
	},

	['upreggeli'] = {
		label = 'update reggeli',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bőséges reggeli, 10%-kal csillapítja az éhséget."
	},

	['urizs'] = {
		label = 'update rizs',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Rizses fogás, 10%-kal csillapítja az éhséget."
	},

	['uvlight'] = {
		label = 'uv zseblámpa',
		weight = 0.2,
		stack = true,
		close = true,
		description = "UV-lámpa rejtett nyomok láthatóvá tételére."
	},

	['uzibelso'] = {
		label = 'micro smg belsőszerkezet',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez szükséges belső szerkezet (Micro SMG, SMG Mk2)."
	},

	['uzicso'] = {
		label = 'micro smg cső',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez szükséges cső (Micro SMG, SMG Mk2)."
	},

	['uziravasz'] = {
		label = 'micro smg ravasz',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez szükséges ravasz (Micro SMG, SMG Mk2)."
	},

	['uzitar'] = {
		label = 'micro smg tár',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Fegyverkészítéshez szükséges tár (Micro SMG, SMG Mk2)."
	},

--Vásároltujfegyveralkatrész

	['assaultcso'] = {
		label = 'Assault SMG Cső',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Assault SMG elkészítéséhez szükséges cső."
	},

	['assaulttar'] = {
		label = 'Assault SMG Tár',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Assault SMG elkészítéséhez szükséges tár."
	},

	['assaulttarto'] = {
		label = 'Assault SMG Tartó',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Assault SMG elkészítéséhez szükséges tartó."
	},

	['assaultvaz'] = {
		label = 'Assault SMG Váz',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Assault SMG elkészítéséhez szükséges váz."
	},

	['militarycso'] = {
		label = 'Military Rifle Cső',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Military Rifle elkészítéséhez szükséges cső."
	},

	['militaryravasz'] = {
		label = 'Military Rifle Ravasz',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Military Rifle elkészítéséhez szükséges ravasz."
	},

	['militarytar'] = {
		label = 'Military Rifle Tár',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Military Rifle elkészítéséhez szükséges tár."
	},

	['militaryscop'] = {
		label = 'Military Rifle Scop',
		weight = 0.7,
		stack = true,
		close = true,
		description = "Military Rifle elkészítéséhez szükséges céltávcső."
	},

	['videorecord'] = {
		label = 'videó felvétel',
		weight = 1,
		stack = true,
		close = true,
		description = "Videófelvétel; bizonyítékként használható."
	},

	['vinewood_blanc'] = {
		label = 'vinewood sauvignon blanc',
		weight = 1,
		stack = true,
		close = true,
		description = "Vinewood Sauvignon Blanc, száraz fehérbor."
	},

	['vinewood_red'] = {
		label = 'vinewood red zinfadel',
		weight = 1,
		stack = true,
		close = true,
		description = "Vinewood Red Zinfandel, testes vörösbor."
	},

	['vitodaiquiri'] = {
		label = 'vito daiquiri',
		weight = 5,
		stack = true,
		close = true,
		description = "Vito Daiquiri koktél a bárpultról."
	},

	['wallet'] = {
		label = 'pénztárca',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pénztárca iratok és készpénz tárolására."
	},

	['washed_stone'] = {
		label = 'mosott kő',
		weight = 1,
		stack = true,
		close = true,
		description = "Mosott kő; feldolgozott bányászati anyag."
	},

	['weapon_paintgun'] = {
		label = 'paintball fegyver',
		weight = 1,
		stack = true,
		close = true,
		description = "Paintball fegyver festéklövedékkel."
	},

	['weaponlicense'] = {
		label = 'fegyverengedély',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Fegyverviselési engedély."
	},

	['veresrejtelyeslevel'] = {
		label = 'Véres rejtélyes levél',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Véres, rejtélyes levél; a darabjaiból állt össze."
	},

	['veresrejtelyesleveldarab'] = {
		label = 'Véres rejtélyes levél darab',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Egy véres rejtélyes levél darabja; a többivel összeilleszthető."
	},

	['vizbenazottlevel'] = {
		label = 'Vízben ázott levél',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Vízben ázott levél; a darabjaiból állt össze."
	},

	['vizileveldarab'] = {
		label = 'Vízben ázott levél darab',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Egy vízben ázott levél darabja; a többivel összeilleszthető."
	},

	['weed_lemonhaze'] = {
		label = 'Sativa',
		weight = 0.1,
		stack = true,
		close = true,
		degrade = 10080,  -- 7 nap percben
		decay = true,     -- lejáratkor magától törlődik
		-- consume-ot NEM kap: a használatot az esx_basicneeds drugs.lua kezeli (effekt+anim+levonás)
		description = "Marihuána; elszívva 45 másodpercre bekábulsz, közben kis páncélt ad, de tántorogsz tőle."
	},

	['szuretlenfu'] = {
		label = 'Szűretlen fű',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Szűretlen fű; tisztításra vár, mielőtt eladható lenne."
	},

	['weed_lemonhaze_seed'] = {
		label = 'fű mag',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Marihuána magja; ültetvényen termeszthető."
	},

	['weed20g'] = {
		label = 'fű (20g)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Húsz gramm fű; nagyobb adag eladásra."
	},

	['weed4g'] = {
		label = 'fű (4g)',
		weight = 0.4,
		stack = true,
		close = true,
		description = "Négy gramm fű; egy utcai adag."
	},

	['weedbrick'] = {
		label = 'fű csomag (200g)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Kétszáz grammos fűcsomag nagybani eladásra."
	},

	['wood'] = {
		label = 'fa',
		weight = 1,
		stack = true,
		close = true,
		description = "Fa alapanyag építéshez és gyártáshoz."
	},

	['wool'] = {
		label = 'gyapjú',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Gyapjú; textilgyártás alapanyaga."
	},

	['wrench'] = {
		label = 'villáskulcs',
		weight = 0,
		stack = true,
		close = true,
		description = "Villáskulcs szereléshez."
	},

	['bucket'] = {
		label = 'horgász vödör',
		weight = 3000,
		stack = false,
		close = true,
		consume = 0,
		description = "Horgászvödör a kifogott halaknak.",
	},

	['yoshishooter'] = {
		label = 'yoshi shooter',
		weight = 5,
		stack = true,
		close = true,
		description = "Yoshi Shooter koktél a bárpultról."
	},

	['zetony'] = {
		label = 'zseton',
		weight = 1,
		stack = true,
		close = true,
		description = "Zseton; a játékasztaloknál használható."
	},

	['acetone'] = {
		label = 'acetone',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Aceton; vegyi alapanyag a drogfőzéshez."
	},

	['tiramisu'] = {
		label = 'tiramisu',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Olasz tiramisu, 10%-kal csillapítja az éhséget."
	},

	['femforgacs'] = {
		label = 'fém hulladék',
		weight = 0.8,
		stack = true,
		close = true,
		description = "Fémforgács; hulladékként leadható vagy újrahasznosítható."
	},

	['tokospite'] = {
		label = 'tökös pite',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Házi tökös pite, 10%-kal csillapítja az éhséget."
	},


	['toltottkaposzta'] = {
		label = 'töltöttkáposzta',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Töltött káposzta, 10%-kal csillapítja az éhséget."
	},

	['torleypezsgo'] = {
		label = 'törley pezsgő',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Törley pezsgő, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['towing_rope'] = {
		label = 'Vontató Kötél',
		weight = 1,
		stack = true,
		close = true,
		description = "Vontatókötél a járművek elszállításához."
	},

	['kq_winch'] = {
		label = 'Vontató Kábel',
		weight = 1,
		stack = true,
		close = true,
		description = "Vontatókábel a csörlős autómentéshez."
	},

	['kq_tow_rope'] = {
		label = 'Vontató Kötél 2.0',
		weight = 1,
		stack = true,
		close = true,
		description = "Erősebb vontatókötél a nehezebb járművekhez."
	},

	['neonbox'] = {
		label = 'neon box',
		weight = 1,
		stack = true,
		close = true,
		description = "Neon doboz; a jármű díszvilágításának alkatrésze."
	},

	['neoncontroller'] = {
		label = 'neon controller',
		weight = 1,
		stack = true,
		close = true,
		description = "Neon vezérlő a jármű fényeinek beállításához."
	},

	['turos_teszta'] = {
		label = 'túrós tészta',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Túrós tészta, 10%-kal csillapítja az éhséget."
	},

	['alkatresz'] = {
		label = 'alkatrész',
		weight = 1,
		stack = true,
		close = true,
		description = "Általános alkatrész javításhoz és összeszereléshez."
	},

	['gadgetpistol '] = {
		label = 'gadget pisztoly',
		weight = 1.4,
		stack = true,
		close = true,
		description = "Gadget pisztoly; rejtett szerkezetű kézifegyver."
	},

	['palacsinta'] = {
		label = 'palacsinta',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	['palinka'] = {
		label = 'pálinka',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Erős házi pálinka, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['paradicsomleves'] = {
		label = 'paradicsomleves',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Paradicsomleves, 10%-kal csillapítja az éhséget."
	},

	['aranyaszok'] = {
		label = 'aranyászok',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Dobozos sör, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['aranygaluska'] = {
		label = 'aranygaluska',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Aranygaluska, 10%-kal csillapítja az éhséget."
	},

	['weed'] = {
		label = 'fű',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Szárított fű; eladásra kész adag."
	},

	['weed_cookie'] = {
		label = 'füves brownie',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Füves brownie, 10%-kal csillapítja az éhséget."
	},

	['weed_seed'] = {
		label = 'fű (mag)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fűmag ültetéshez."
	},

	['gyulyasleves'] = {
		label = 'gulyásleves',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bográcsos gulyásleves, 10%-kal csillapítja az éhséget."
	},

	['pizza'] = {
		label = 'pizza',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Sajtos pizza, 10%-kal csillapítja az éhséget."
	},

	['axe'] = {
		label = 'balta',
		weight = 2,
		stack = true,
		close = true,
		description = "Balta fa kivágásához."
	},

	['policeshield'] = {
		label = 'rendőrségi pajzs',
		weight = 3,
		stack = true,
		close = true,
		description = "Rendőrségi pajzs; véd a lövésektől."
	},

	['zserbo'] = {
		label = 'zserbó',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Zserbószelet, 10%-kal csillapítja az éhséget."
	},

	['heavyrifle'] = {
		label = 'bren 2',
		weight = 4.7,
		stack = true,
		close = true,
		description = "Bren 2 gépkarabély."
	},

	['bor'] = {
		label = 'bor',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pohár vörösbor, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['rakott_krumpli'] = {
		label = 'rakott krumpli',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Rakott krumpli, 10%-kal csillapítja az éhséget."
	},

	['rantott_sajt'] = {
		label = 'rántott sajt',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Rántott sajt, 10%-kal csillapítja az éhséget."
	},

	['jager'] = {
		label = 'jager',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Gyógynövényes likőr, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['rantottszelet'] = {
		label = 'rántott szelet',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Rántott szelet, 10%-kal csillapítja az éhséget."
	},

	['redw'] = {
		label = 'Piros Heist (Dobozos cigi)',
		weight = 1,
		stack = true,
		close = true,
		description = "20 szálas dobozos cigaretta, a BC City városába készült."
	},

	['redwcig'] = {
		label = 'Piros Heis Cigi',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Ez egy szálcigaretta. Minél hamarabb szokjon le róla, mert káros lehet az egészségére."
	},

	['kakao'] = {
		label = 'kakaó',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Meleg kakaó, 10%-kal oltja a szomjúságot."
	},

	['bundaskenyer'] = {
		label = 'bundáskenyér',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bundás kenyér, 10%-kal csillapítja az éhséget."
	},

	['kave'] = {
		label = 'kávé',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Feketekávé, 10%-kal oltja a szomjúságot."
	},

	['knuckle'] = {
		label = 'boxer',
		weight = 1,
		stack = true,
		close = true,
		description = "Boxer; közelharci ütőeszköz."
	},

	['cappy'] = {
		label = 'cappy',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Dobozos gyümölcslé, 10%-kal oltja a szomjúságot."
	},

	['kubu'] = {
		label = 'kubu',
		weight = 0.4,
		stack = true,
		close = true,
		description = "Gyümölcsös gyerekital, 10%-kal oltja a szomjúságot."
	},

	['sajtgombocleves'] = {
		label = 'sajtgombóc leves',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Sajtgombóc leves, 10%-kal csillapítja az éhséget."
	},

	['sheriffshield'] = {
		label = 'sheriff shield',
		weight = 3,
		stack = true,
		close = true,
		description = "Seriffpajzs; véd a lövésektől."
	},

	['chips'] = {
		label = 'poker zseton',
		weight = 0,
		stack = true,
		close = true,
		description = "Pókerzseton a kaszinó asztalaihoz."
	},

	['darkchips'] = {
		label = 'Illegális Zseton',
		weight = 0,
		stack = true,
		close = true,
		description = "Illegális zseton; a földalatti játékbarlangokban ér valamit."
	},

	['siocappuchino'] = {
		label = 'sió cappuchino',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Dobozos cappuccino, 10%-kal oltja a szomjúságot."
	},

	['smg_mk2'] = {
		label = 'smg mk2',
		weight = 2.3,
		stack = true,
		close = true,
		description = "Felújított géppisztoly MK2."
	},

	['smokegrenade'] = {
		label = 'smokegrenade',
		weight = 1,
		stack = true,
		close = true,
		description = "Füstgránát; sűrű füstfüggönyt vet."
	},

	['lighter'] = {
		label = 'Öngyújtó',
		weight = 1,
		stack = true,
		close = true,
		description = "Öngyújtó; cigaretta meggyújtásához."
	},

	['box'] = {
		label = 'Doboz',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Doboz tárgyak tárolására."
	},

	['smoke2'] = {
		label = 'Cigi',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Szál cigaretta; rágyújtásra."
	},

	['lithium'] = {
		label = 'lítium akkumulátorok',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Lítium akkumulátor; elektronikai alapanyag."
	},

	['somloigaluska'] = {
		label = 'somlói galuska',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Somlói galuska, 10%-kal csillapítja az éhséget."
	},

	['soproni'] = {
		label = 'soproni',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Dobozos sör, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['marhaporkolt'] = {
		label = 'marhapörkölt nokedlivel',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Marhapörkölt nokedlivel, 10%-kal csillapítja az éhséget."
	},

	['cubancigar'] = {
		label = 'Kubai szivar',
		weight = 1,
		stack = true,
		close = true,
		description = "Kubában készült, jó minőségű szivar."
	},

	['sprite'] = {
		label = 'sprite',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Citromos szénsavas üdítő, 40%-kal oltja a szomjúságot."
	},

	['stickybomb'] = {
		label = 'stickybomb',
		weight = 1,
		stack = true,
		close = true,
		description = "Ragadós bomba; felragasztható robbanótöltet."
	},

	['marlborocig'] = {
		label = 'Kék Heis Cigi',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Ez egy szálcigaretta. Minél hamarabb szokjon le róla, mert káros lehet az egészségére."
	},

	['dewmountaindew'] = {
		label = 'mountain',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Zöld energiaital, 10%-kal oltja a szomjúságot."
	},

	['meth'] = {
		label = 'meth',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Metamfetamin; 55 másodpercig felpörget – gyorsabb futás, gyógyulás és egy kevés páncél, kásás látás mellett."
	},

	['vintagepistol'] = {
		label = 'vintage pisztoly',
		weight = 1.1,
		stack = true,
		close = true,
		description = "Vintage pisztoly; szép, régi darab."
	},

	['kasztni'] = {
		label = 'kasztni',
		weight = 1,
		stack = true,
		close = true,
		description = "Kasztni; a jármű karosszéria eleme."
	},

	['methlab'] = {
		label = 'hordozható methlab',
		weight = 5,
		stack = true,
		close = true,
		description = "Hordozható methlabor; bárhol beindítható a főzéshez."
	},

	['tea'] = {
		label = 'tea',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Forró tea, 40%-kal oltja a szomjúságot."
	},

	['rantotta'] = {
		label = 'rántotta',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Rántotta, 10%-kal csillapítja az éhséget."
	},

	['militaryrifle'] = {
		label = 'bc56',
		weight = 5.2,
		stack = true,
		close = true,
		description = "BC56 katonai gépkarabély."
	},

	['halaszle'] = {
		label = 'halászlé',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bográcsban főtt halászlé, 10%-kal csillapítja az éhséget."
	},

	['davidoffcigar'] = {
		label = 'Dávid szivar',
		weight = 1,
		stack = true,
		close = true,
		description = "Márkás szivar, az egyik legjobb gyártótól."
	},

	['marlboro'] = {
		label = 'Kék Heist (dobozos cigi)',
		weight = 1,
		stack = true,
		close = true,
		description = "20 szálas dobozos cigaretta, a BC City városába készült."
	},

	['motor'] = {
		label = 'motor',
		weight = 1,
		stack = true,
		close = true,
		description = "Motorblokk; a jármű szíve, javításhoz kell."
	},

	['tyukhusleves'] = {
		label = 'tyúkhúsleves',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Tyúkhúsleves, 10%-kal csillapítja az éhséget."
	},

	['christmasdecorativeballsred'] = {
		label = 'piros golyó',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi dísz: piros gömb."
	},

	['christmasdecorativeballsyellow'] = {
		label = 'sárga golyó',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi dísz: sárga gömb."
	},

	['christmasdecorativebells'] = {
		label = 'harangok',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi dísz: csengettyűk."
	},

	['christmasdecorativecandy'] = {
		label = 'cukorka',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi dísz: cukorka."
	},

	['christmasdecorativelightsred'] = {
		label = 'piros lámpák',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi dísz: piros fényfüzér."
	},

	['christmasdecorativelightswhite'] = {
		label = 'fehér fények',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi dísz: fehér fényfüzér."
	},

	['christmasdecorativelightsyellow'] = {
		label = 'sárga fények',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi dísz: sárga fényfüzér."
	},

	['christmasdecorativestar'] = {
		label = 'csillag',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi dísz: csúcsdísz csillag."
	},

	['christmasigloo'] = {
		label = 'igloo',
		weight = 1,
		stack = true,
		close = true,
		description = "Iglu; téli dekoráció."
	},

	['christmassnow'] = {
		label = 'hó',
		weight = 1,
		stack = true,
		close = true,
		description = "Hó; téli dekorációhoz."
	},

	['christmassnowball'] = {
		label = 'hógolyó',
		weight = 1,
		stack = true,
		close = true,
		description = "Hógolyó; télen jól elhajítható."
	},

	['christmassnowman'] = {
		label = 'hóember',
		weight = 1,
		stack = true,
		close = true,
		description = "Hóember; téli dekoráció."
	},

	['christmastree'] = {
		label = 'karácsony fa',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyfa; ünnepi dekoráció."
	},

	['csgocase4'] = {
		label = 'fegyver alaktrész láda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Fegyveralkatrész-láda; véletlenszerű alkatrészt ad."
	},

	['csgocase5'] = {
		label = 'limitált autó láda',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Limitált autóláda ritka járművek esélyével."
	},

	['summerlada2026'] = {
		label = 'Summer Láda 2026',
		weight = 0.01,
		stack = true,
		close = true,
		description = 'Applikációs küldetésekből szerezhető. Ritka járműutalványokat tartalmaz.'
	},

	['virgacs'] = {
		label = 'virgács',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Virgács; a Mikulás ajándéka a rosszaknak."
	},

	['szaloncukor'] = {
		label = 'szalon cukor',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Szaloncukor; karácsonyi édesség."
	},

	['dietilamid'] = {
		label = 'dietilamid',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Dietil-amid; az LSD előállításának alapanyaga."
	},

	['kesztyu'] = {
		label = 'kesztyű',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kesztyű; nyomok hátrahagyása nélkül dolgozhatsz vele."
	},

	['lizergsav'] = {
		label = 'lizergsav',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Lizergsav; az LSD előállításának alapanyaga."
	},

	['lsd'] = {
		label = 'lsd',
		weight = 0.1,
		stack = true,
		close = true,
		description = "LSD; 55 másodpercre kifehéredik a világ – gyorsabb futás, gyógyulás és páncél mellett."
	},

	['speed'] = {
		label = 'speed',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Speed; 55 másodpercig sokkal gyorsabban futsz, cserébe elmosódik a látásod."
	},
-----	 TAHOÚJ! DROG ----
	['seed_gomba'] = {
		label = 'Gomba Mag',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Gombamag; ültetvényen termeszthető."
	},

	['lilacsoda_mag'] = {
		label = 'Lila Csoda Mag',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Lila Csoda magja; ültetvényen termeszthető."
	},

	['lilacsoda_port'] = {
		label = 'Lila Csoda Port',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Lila Csoda por; feldolgozott alapanyag."
	},

	['por_gomba'] = {
		label = 'Gomba Por',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Gombapor; feldolgozott alapanyag."
	},

	['gomba'] = {
		label = 'Gomba',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Szárított bódító gomba; 45 másodpercig kábít, közben páncélt ad."
	},

	['lilacsoda'] = {
		label = 'Lila Csoda',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Lila szintetikus szer; 45 másodpercig kábít és páncélt ad, tántorgó járás mellett."
	},

	['adr'] = {
		label = 'Adrenalin injekció',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Adrenalin injekció; 55 másodpercig gyorsabb futás és gyógyulás, egy kevés páncéllal."
	},


	['opium'] = {
		label = 'opium',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Ópium; 55 másodpercig tompít és regenerál, de bizonytalanná teszi a járásodat."
	},

	['morfin'] = {
		label = 'morfin',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Morfin; erős fájdalomcsillapító."
	},

	['kodein'] = {
		label = 'kodein',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kodein; köhögéscsillapító hatóanyag."
	},

	['crystal'] = {
		label = 'Crystal',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kristály; feldolgozott kábítószer."
	},

	['crank'] = {
		label = 'Crank',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Crank; utcai stimuláns."
	},

	['ontozoviz'] = {
		label = 'Öntöző víz',
		weight = 0.8,
		stack = true,
		close = true,
		description = "Öntözővíz a növények locsolásához."
	},

	['blowtorch'] = {
		label = 'Vas hegesztő (Sima)',
		weight = 1,
		stack = true,
		close = true,
		description = "Hegesztőpisztoly fém megmunkálásához."
	},

	['nightvision'] = {
		label = 'Éjjellátóx-eye',
		weight = 1,
		stack = true,
		close = true,
		description = "Éjjellátó szemüveg; sötétben is látsz vele."
	},

	['coral'] = {
		label = 'korall',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Korall; a merülések színes zsákmánya."
	},

	['red_lamp'] = {
		label = 'fű lámpa',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Növénylámpa a fű beltéri termesztéséhez."
	},

	['red_pot'] = {
		label = 'fű cserép',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Cserép a fű elültetéséhez."
	},

	['shovel'] = {
		label = 'lapát',
		weight = 1,
		stack = true,
		close = true,
		description = "Lapát ásáshoz."
	},

	['clam'] = {
		label = 'Kagyló',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Kagyló; gyöngyöt rejthet."
	},

	['small_safe'] = {
		label = 'Széf',
		weight = 1,
		stack = true,
		close = true,
		description = "Kis széf értékek biztonságos tárolására."
	},

	['big_safe'] = {
		label = 'Széf',
		weight = 1,
		stack = true,
		close = true,
		description = "Nagy széf; sok érték biztonságos tárolására."
	},

	['drone_flyer_7'] = {
		label = 'Dron',
		weight = 1,
		stack = true,
		close = true,
		description = "Drón; a magasból figyelheted vele a terepet."
	},

	['macaron'] = {
		label = 'Macaron',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Extra: Gyors futás,Gyors uszás, Pajzs, Töltés 20%"
	},

	['matchatea'] = {
		label = 'matchatea',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Matcha tea, 10%-kal oltja a szomjúságot."
	},

	['epressajttorta'] = {
		label = 'Epres sajttorta',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	['ramen'] = {
		label = 'Ramen',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Extra: Gyors futás,Gyors uszás, Pajzs, Töltés 20%"
	},

	['eteltermes'] = {
		label = 'Étel termés (Farm)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Beszerezhető a farmon"
	},

	['etelalapanyag'] = {
		label = 'Étel alapanyag (Farm)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Beszerezhető a farmon"
	},

	['jegeskave'] = {
		label = 'jegeskave',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	['zsiroskenyer'] = {
		label = 'Zsíros kenyér',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	['hurka'] = {
		label = 'Hurka',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Sült hurka, 10%-kal csillapítja az éhséget."
	},

	['kokaincserje'] = {
		label = 'Kokain Cserje',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kokaincserje; ültetvényen nő, a kokain alapanyaga."
	},

	['pd_tracker'] = {
		label = 'járműkövető eszköz',
		weight = 1,
		stack = true,
		close = true,
		description = "Járműkövető eszköz; felszerelve követhető az autó."
	},

	['pd_mili_tracker'] = {
		label = 'military vehicle tracking device',
		weight = 1,
		stack = true,
		close = true,
		description = "Katonai járműkövető, nagyobb hatótávval."
	},

	['pd_adpt_tracker'] = {
		label = 'adept vehicle tracking device',
		weight = 1,
		stack = true,
		close = true,
		description = "Adaptív járműkövető eszköz."
	},

	['pd_jammer'] = {
		label = 'vehicle tracking device jammer',
		weight = 1,
		stack = true,
		close = true,
		description = "Jelzavaró; elnyomja a járműkövetők jelét."
	},

	['pd_scanner'] = {
		label = 'járműkövető eszköz szkenner',
		weight = 1,
		stack = true,
		close = true,
		description = "Szkenner; kimutatja a járműre szerelt követőt."
	},

	['pd_screwdriver'] = {
		label = 'csavarhúzó',
		weight = 1,
		stack = true,
		close = true,
		client = {
			event = "pd_tracker:remove"
		},
		description = "Csavarhúzó a követők fel- és leszereléséhez."
	},

	['pd_adv_tracker'] = {
		label = 'advanced vehicle tracking device',
		weight = 1,
		stack = true,
		close = true,
		description = "Fejlett járműkövető eszköz."
	},

	['keritesitem'] = {
		label = 'keritesitem',
		weight = 1,
		stack = true,
		close = true,
		description = "Kerítéselem; lerakható a helyszínen."
	},

	['piacitem'] = {
		label = 'piacitem',
		weight = 1,
		stack = true,
		close = true,
		description = "Piaci stand; lerakható árusítóhely."
	},

	['piac2item'] = {
		label = 'piac2item',
		weight = 1,
		stack = true,
		close = true,
		description = "Nagyobb piaci stand; lerakható árusítóhely."
	},

	['epitoitem'] = {
		label = 'epitoitem',
		weight = 1,
		stack = true,
		close = true,
		description = "Építőelem; lerakható a helyszínen."
	},

	['takaroitem'] = {
		label = 'takaroitem',
		weight = 1,
		stack = true,
		close = true,
		description = "Takaróponyva; lerakható a helyszínen."
	},

	['pancelajtoitem'] = {
		label = 'pancelajtoitem',
		weight = 1,
		stack = true,
		close = true,
		description = "Páncélajtó; lerakható zárható nyílás."
	},

	['vasajtoitem'] = {
		label = 'vasajtoitem',
		weight = 1,
		stack = true,
		close = true,
		description = "Vasajtó; lerakható zárható nyílás."
	},

	['atmitem'] = {
		label = 'atmitem',
		weight = 1,
		stack = true,
		close = true,
		description = "Bankautomata; kihelyezhető a helyszínen."
	},

	['vehkey'] = {
		label = 'Kocsi kulcs',
		weight = 1,
		stack = true,
		close = true,
		description = "Járműkulcs; a hozzá tartozó autót nyitja."
	},

	['victustar'] = {
		label = 'Victus Tar',
		weight = 1,
		stack = true,
		close = true,
		description = "Victus XMR elkészítéséhez szükséges tár."
	},

	['victuscso'] = {
		label = 'Victus Cso',
		weight = 1,
		stack = true,
		close = true,
		description = "Victus XMR elkészítéséhez szükséges cső."
	},

	['victusbelsoszerkezet'] = {
		label = 'Victus Belsoszerkezet',
		weight = 1,
		stack = true,
		close = true,
		description = "Victus XMR elkészítéséhez szükséges belső szerkezet."
	},

	['victustavcso'] = {
		label = 'Victus Tavcso',
		weight = 1,
		stack = true,
		close = true,
		description = "Victus XMR elkészítéséhez szükséges céltávcső."
	},

	['apple'] = {
		label = 'Alma',
		weight = 0.1,
		stack = true,
		close = true,
		description = 'Friss, érett alma. Feldolgozható különböző ételek és italok készítéséhez, valamint közvetlen fogyasztásra is alkalmas.',
	},

	['green_apple'] = {
		label = 'Zöld Alma',
		weight = 0.1,
		stack = true,
		close = true,
    	description = 'Friss, éretlen zöld alma. Feldolgozható különböző termékek készítéséhez.',
	},

	['rotten_apple'] = {
		label = 'Romlot Alma',
		weight = 0.1,
		stack = true,
		close = true,
		description = 'Feldolgozható alapanyag. Felhasználható receptekhez vagy nyersen is elfogyasztható.',
	},

	['apple_juice'] = {
		label = 'Alma juice',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Almalé."
	},

	['fireworks_box_normal'] = {
		label = 'tűzijáték doboz normál',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Tűzijáték doboz; alap show az égen."
	},

	['fireworks_box_mega'] = {
		label = 'tűzijáték doboz mega',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Mega tűzijáték doboz; látványosabb show."
	},

	['fireworks_box_ultimate'] = {
		label = 'tűzijáték doboz ultimate',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Ultimate tűzijáték doboz; a leglátványosabb show."
	},

	['fireworks_solar_flare'] = {
		label = 'tűzijáték napkitörés',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Napkitörés tűzijáték; erős fényjelenség."
	},

	['fireworks_rocket'] = {
		label = 'tűzijáték rakéta',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Tűzijáték rakéta; magasra száll."
	},

	['fireworks_pyro_small'] = {
		label = 'tűzijáték pyro kicsi',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kis pirotechnikai szökőkút."
	},

	['fireworks_pyro_medium'] = {
		label = 'tűzijáték pyro medium',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Közepes pirotechnikai szökőkút."
	},

	['fireworks_pyro_large'] = {
		label = 'tűzijáték pyro nagy',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Nagy pirotechnikai szökőkút."
	},

	['fireworks_pyro_mega'] = {
		label = 'tűzijáték pyro mega',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Mega pirotechnikai szökőkút."
	},

	['fireworks_pyro_pirate'] = {
		label = 'tűzijáték piro kalóz',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kalóz témájú pirotechnika."
	},

	['fireworks_pyro_rug'] = {
		label = 'tűzijáték piro',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pirotechnikai tűzfüggöny."
	},

	['fireworks_pyro_ruglong'] = {
		label = 'tűzijáték piro hosszú',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Hosszú pirotechnikai tűzfüggöny."
	},

	['fireworks_pyro_flare1'] = {
		label = 'tűzijáték pyro fáklya 1',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pirotechnikai fáklya, első változat."
	},

	['fireworks_pyro_flare2'] = {
		label = 'tűzijáték pyro fáklya 2',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pirotechnikai fáklya, második változat."
	},

	['fireworks_pyro_flare3'] = {
		label = 'tűzijáték pyro fáklya 3',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pirotechnikai fáklya, harmadik változat."
	},

	['fireworks_pyro_fontain'] = {
		label = 'tűzijáték pyro szökőkút',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pirotechnikai szikraszökőkút."
	},

	['acyclovir'] = {
		label = 'acyclovir',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Aciklovir; vírusos fertőzésre szedett gyógyszer."
	},

	['aspirin'] = {
		label = 'aspirin',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Aszpirin; láz- és fájdalomcsillapító."
	},

	['azithromycin'] = {
		label = 'azithromycin',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Azitromicin; antibiotikum bakteriális fertőzésre."
	},

	['covidvaccine'] = {
		label = 'covid védőoltás',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Védőoltás; megelőzi a fertőzést."
	},

	['doxycycline'] = {
		label = 'doxiciklin',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Doxiciklin; széles hatású antibiotikum."
	},

	['dramamine'] = {
		label = 'dramamine',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Dramamine; utazási rosszullét ellen."
	},

	['ibuprofen'] = {
		label = 'ibuprofen',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Ibuprofén; gyulladás- és fájdalomcsillapító."
	},

	['loperamide'] = {
		label = 'loperamide',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Loperamid; hasmenés elleni szer."
	},

	['peptobismol'] = {
		label = 'peptobismol',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pepto-Bismol; gyomorpanaszokra."
	},

	['tylenol'] = {
		label = 'tylenol',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Tylenol; láz- és fájdalomcsillapító."
	},

	['monster'] = {
		label = 'Manstar Energy',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Energiaital, 10%-kal oltja a szomjúságot."
	},

	['redbull'] = {
		label = 'Bull Hell',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Energiaital, 40%-kal oltja a szomjúságot."
	},

	['deff'] = {
		label = 'Defibrillátor',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Defibrillátor; újraélesztéshez."
	},

	['tu'] = {
		label = 'Injekciós tű',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Injekciós tű vérvételhez és beadáshoz."
	},

	['ver'] = {
		label = 'Vér',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Vérminta laborvizsgálathoz."
	},

	['sulfuricacid_bottle'] = {
		label = 'sulfuricacid_bottle',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kénsav; vegyi alapanyag a laborhoz."
	},

	['empty_weed_bag'] = {
		label = 'empty_weed_bag',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Üres fűtasak a csomagoláshoz."
	},

	['docso'] = {
		label = 'Doubleaction Cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Double Action Revolver elkészítéséhez szükséges cső."
	},

	['dotar'] = {
		label = 'Doubleaction Tar',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Double Action Revolver elkészítéséhez szükséges tár."
	},

	['doravasz'] = {
		label = 'Doubleaction Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Double Action Revolver elkészítéséhez szükséges ravasz."
	},

	['tacticcso'] = {
		label = 'Tacticalrifle Cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Tactical Rifle elkészítéséhez szükséges cső."
	},

	['tactictar'] = {
		label = 'Tacticalrifle Tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Tactical Rifle elkészítéséhez szükséges tár."
	},

	['tacticravasz'] = {
		label = 'Tacticalrifle Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Tactical Rifle elkészítéséhez szükséges ravasz."
	},

	['mncso'] = {
		label = 'Marksman Cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Marksman Pistol elkészítéséhez szükséges cső."
	},

	['mntar'] = {
		label = 'Marksman Tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Marksman Pistol elkészítéséhez szükséges tár."
	},

	['mnravasz'] = {
		label = 'Marksman Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Marksman Pistol elkészítéséhez szükséges ravasz."
	},

	['chip_laptop'] = {
		label = 'tuning laptop',
		weight = 1,
		stack = true,
		close = true,
		degrade = 10080,  -- 7 nap percben
		decay = true,     -- lejáratkor magától törlődik
		description = "Chiptuning laptop a motorvezérlő átprogramozásához."
	},

	['chip_obd2'] = {
		label = 'obd ii csatlakozó',
		weight = 1,
		stack = true,
		close = true,
		degrade = 10080,  -- 7 nap percben
		decay = true,     -- lejáratkor magától törlődik
		description = "OBD-II csatlakozó; a laptopot köti össze a járművel."
	},

	['gasmask'] = {
		label = 'Gáz Maszk',
		weight = 1,
		stack = true,
		close = true,
		description = "Gázmaszk; véd a füsttől és a gáztól."
	},

	['rtxcso'] = {
		label = 'RTX Cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az RTX fegyver csöve."
	},

	['rtxravasz'] = {
		label = 'RTX Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az RTX fegyver ravasza."
	},

	['rtxbelsoszerkezet'] = {
		label = 'RTX Belsoszerkezet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az RTX fegyver belső szerkezete."
	},

	['jammer'] = {
		label = 'Rádió Jelzavaró',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Rádió jelzavaró; elnémítja a közeli rádióforgalmat."
	},

	['radiozavaro'] = {
		label = 'Rádió Jelzavaró',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Rádió jelzavaró; elnémítja a közeli rádióforgalmat.",
		client = {
            export = 'bc_radioblocker.placeBlocker'
        },
	},

	['radiochip'] = {
		label = 'Jelzavaró chip (Felvevő)',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Jelzavaró chip; rögzíti a lehallgatott rádióforgalmat."
	},

	['babystroller'] = {
		label = 'Baba Kocsi',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Babakocsi."
	},

	['babytoys'] = {
		label = 'Baba Játék',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Bébijáték."
	},

	['babyvitamin'] = {
		label = 'Baba Vitamin',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Bébivitamin."
	},

	['comfortdiaper'] = {
		label = 'Baba Pelenka',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Babapelenka."
	},

	['healthybabyfood'] = {
		label = 'Baba étel',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Bébiétel a csecsemő táplálásához."
	},

	['healthybabymineral'] = {
		label = 'Baba Gyogyszer',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Bébi gyógyszer a kicsi ellátásához."
	},

	--[[['mdt'] = {
		label = 'mdt',
		weight = 0.3,
		stack = true,
		close = true,
		description = nil
	},]]
	["mdt"] = {
		label = "MDT",
		weight = 250,
		client = {
			export = "ox_mdt.openMDT"
		},
		description = "MDT terminál; a rendvédelmi adatbázis elérésére.",
	},

	['m4animtar'] = {
		label = 'M4anim tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az M4 elkészítéséhez szükséges tár."
	},

	['m4animcso'] = {
		label = 'M4anim Cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az M4 elkészítéséhez szükséges cső."
	},

	['m4animbelsoszerkezet'] = {
		label = 'M4anim Belsőszerekzet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az M4 elkészítéséhez szükséges belső szerkezet."
	},

	['m4animravasz'] = {
		label = 'M4anim Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az M4 elkészítéséhez szükséges ravasz."
	},

	['specialmk2cso'] = {
		label = 'Specialcarbine cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Special Carbine MK2 elkészítéséhez szükséges cső."
	},

	['specialmk2belsoszerkezet'] = {
		label = 'Specialcarbine Belsőszerekzet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Special Carbine MK2 elkészítéséhez szükséges belső szerkezet."
	},

	['specialmk2csoravasz'] = {
		label = 'Specialcarbine Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Special Carbine MK2 elkészítéséhez szükséges ravasz."
	},

	['rgxvaltar1'] = {
		label = 'RGX tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az RGX elkészítéséhez szükséges tár."
	},

	['rgxvalcso1'] = {
		label = 'RGX Cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az RGX elkészítéséhez szükséges cső."
	},

	['rgxvaltarbelsoszerkezet1'] = {
		label = 'RGX Belsőszerekzet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az RGX elkészítéséhez szükséges belső szerkezet."
	},

	['snsravasz'] = {
		label = 'SNS Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "SNS Pistol elkészítéséhez szükséges ravasz."
	},

	['snscso'] = {
		label = 'SNS Cső',
		weight = 0.3,
		stack = true,
		close = true,
		description = "SNS Pistol elkészítéséhez szükséges cső."
	},

	['snstar'] = {
		label = 'SNS Tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "SNS Pistol elkészítéséhez szükséges tár."
	},

	['rgxvalravasz1'] = {
		label = 'RGX Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Az RGX elkészítéséhez szükséges ravasz."
	},

	['kochcso'] = {
		label = 'Koch G3 cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "A Koch G3 elkészítéséhez szükséges cső."
	},

	['kochravasz'] = {
		label = 'Koch G3 Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "A Koch G3 elkészítéséhez szükséges ravasz."
	},

	['kochtar'] = {
		label = 'Koch G3 tar',
		weight = 0.3,
		stack = true,
		close = true,
		description = "A Koch G3 elkészítéséhez szükséges tár."
	},

	['kochbelso'] = {
		label = 'Koch G3 Belsőszerekzet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "A Koch G3 elkészítéséhez szükséges belső szerkezet."
	},

	['vitar'] = {
		label = 'vitar',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Vintage Pistol elkészítéséhez szükséges tár."
	},

	['vimarkolat'] = {
		label = 'vimarkolat',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Vintage Pistol elkészítéséhez szükséges markolat."
	},

	['viravasz'] = {
		label = 'viravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Vintage Pistol elkészítéséhez szükséges ravasz."
	},

	['vivaz'] = {
		label = 'vivaz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Vintage Pistol elkészítéséhez szükséges váz."
	},

	['cbcso'] = {
		label = 'cbcso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat PDW elkészítéséhez szükséges cső."
	},

	['cbmarkolat'] = {
		label = 'cbmarkolat',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat PDW elkészítéséhez szükséges markolat."
	},

	['cbrravasz'] = {
		label = '12312312312',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat PDW elkészítéséhez szükséges ravasz."
	},

	['cbtarto'] = {
		label = '12312312312',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat PDW elkészítéséhez szükséges tartó."
	},

	['bannans'] = {
		label = 'Banánsplit',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Banánsplit fagylalt, 10%-kal csillapítja az éhséget."
	},

	['cezarsali'] = {
		label = 'Caesar saláta',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Cézár saláta, 10%-kal csillapítja az éhséget."
	},

	['cpecsenye'] = {
		label = 'Romapecsenye',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Római pecsenye, 10%-kal csillapítja az éhséget."
	},

	['fagylaltkehely'] = {
		label = 'Fagyi kehely',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fagylaltkehely, 10%-kal csillapítja az éhséget."
	},

	['halaszle'] = {
		label = 'Halászlé',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Bográcsban főtt halászlé, 10%-kal csillapítja az éhséget."
	},

	['hotdog'] = {
		label = 'HotDog',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Klasszikus hot dog, 40%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['raksalata'] = {
		label = 'Ráksaláta',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Ráksaláta, 10%-kal csillapítja az éhséget."
	},

	['rostely'] = {
		label = 'Hagymás rostélyos',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Hagymás rostélyos, 10%-kal csillapítja az éhséget."
	},

	['tako'] = {
		label = 'Tako',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Mexikói taco, 10%-kal csillapítja az éhséget.",
		consume = 0
	},

	['tonhalaspizza'] = {
		label = 'Tonhalas pizza',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Tonhalas pizza, 10%-kal csillapítja az éhséget."
	},

	['4sajtos'] = {
		label = '4 Sajtos pizza',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Négysajtos pizza, 10%-kal csillapítja az éhséget."
	},

	['hawaipizza'] = {
		label = 'Hawai pizza',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Hawaii pizza, 10%-kal csillapítja az éhséget."
	},

	['husimado'] = {
		label = 'Húsimádó pizza',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Húsimádó pizza, 10%-kal csillapítja az éhséget."
	},

	['magyarospizza'] = {
		label = 'Magyaros pizza',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Magyaros pizza, 10%-kal csillapítja az éhséget."
	},

	['margapizza'] = {
		label = 'Margaréta pizza',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Margaréta pizza, 10%-kal csillapítja az éhséget."
	},

	['ayran'] = {
		label = 'Ayran',
		weight = 2,
		stack = true,
		close = true,
		description = "Sós joghurtital, 10%-kal oltja a szomjúságot."
	},

	['bloodymary'] = {
		label = 'Bloody Mary',
		weight = 2,
		stack = true,
		close = true,
		description = "Bloody Mary koktél, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['cuba'] = {
		label = 'Cuba Libre',
		weight = 2,
		stack = true,
		close = true,
		description = "Cuba Libre koktél, 10%-kal oltja a szomjúságot."
	},

	['icetea'] = {
		label = 'Ice Tea',
		weight = 2,
		stack = true,
		close = true,
		description = "Jeges tea, 10%-kal oltja a szomjúságot."
	},

	['itea'] = {
		label = 'Long Island Iced Tea',
		weight = 2,
		stack = true,
		close = true,
		description = "Long Island koktél, 10%-kal oltja a szomjúságot."
	},

	['mojito'] = {
		label = 'Mojito',
		weight = 2,
		stack = true,
		close = true,
		description = "Mentás mojito, 10%-kal oltja a szomjúságot."
	},

	['pinacola'] = {
		label = 'Pinacolada',
		weight = 2,
		stack = true,
		close = true,
		description = "Pina colada koktél, 10%-kal oltja a szomjúságot."
	},

	['rumoskola'] = {
		label = 'Rumos Cola',
		weight = 2,
		stack = true,
		close = true,
		description = "Extra: Gyors futás,Gyors uszás, Pajzs"
	},

	['sexonbeach'] = {
		label = 'Sex on the Beach',
		weight = 2,
		stack = true,
		close = true,
		description = "Sex on the Beach koktél, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['tputony'] = {
		label = 'Tokaji Aszu 5 Puttonyos',
		weight = 2,
		stack = true,
		close = true,
		description = "Tokaji aszú, édes desszertbor, 10%-kal oltja a szomjúságot."
	},

	['whiskycola'] = {
		label = 'Whisky Cola',
		weight = 2,
		stack = true,
		close = true,
		description = "Extra: Gyors futás,Gyors uszás, Pajzs"
	},

	['combatshotguntar'] = {
		label = 'Combatshotgun tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat Shotgun elkészítéséhez szükséges tár."
	},

	['combatshotguncso'] = {
		label = 'Combatshotgun Cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat Shotgun elkészítéséhez szükséges cső."
	},

	['combatshotgunbelsoszerkezet'] = {
		label = 'Combatshotgun Belsőszerekzet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat Shotgun elkészítéséhez szükséges belső szerkezet."
	},

	['combatshotgunravasz'] = {
		label = 'Combatshotgun Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat Shotgun elkészítéséhez szükséges ravasz."
	},

	['carnival_ticket'] = {
		label = 'carnival tickets',
		weight = 0,
		stack = true,
		close = true,
		description = "Vidámparki jegy; a játékokra váltható."
	},

	['plush_01'] = {
		label = 'plush 1',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['plush_03'] = {
		label = 'plush 3',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['plush_04'] = {
		label = 'plush 4',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['plush_05'] = {
		label = 'plush 5',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['plush_06'] = {
		label = 'plush 6',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['plush_07'] = {
		label = 'plush 7',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['plush_08'] = {
		label = 'plush 8',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['plush_09'] = {
		label = 'plush 9',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['teddy'] = {
		label = 'teddy',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssmaci; ajándéknak való."
	},

	['bunch_of_flowers'] = {
		label = 'bunch of flowers',
		weight = 1,
		stack = true,
		close = true,
		description = "Virágcsokor ajándékozásra."
	},

	['plush_02'] = {
		label = 'plush 2',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssfigura; vidámparki nyeremény."
	},

	['comk2belsoszerkezet'] = {
		label = 'comk2belsoszerkezet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat MG MK2 elkészítéséhez szükséges belső szerkezet."
	},

	['comk2markolat'] = {
		label = 'comk2markolat',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat MG MK2 elkészítéséhez szükséges markolat."
	},

	['comk2rravasz'] = {
		label = 'comk2rravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat MG MK2 elkészítéséhez szükséges ravasz."
	},

	['comk2valtamasz'] = {
		label = 'comk2valtamasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Combat MG MK2 elkészítéséhez szükséges válltámasz."
	},

	['shotmk2belso'] = {
		label = 'shotmk2belso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Pump Shotgun MK2 elkészítéséhez szükséges belső szerkezet."
	},

	['shotmk2cso'] = {
		label = 'shotmk2cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Pump Shotgun MK2 elkészítéséhez szükséges cső."
	},

	['shotmk2ravaszmk'] = {
		label = 'shotmk2ravaszmk',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Pump Shotgun MK2 elkészítéséhez szükséges ravasz."
	},

	['shotmk2szerkezet'] = {
		label = 'shotmk2szerkezet',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Pump Shotgun MK2 elkészítéséhez szükséges belső szerkezet."
	},

	["backpack1"] = {
		label = "backpack1",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos hátizsák"
	},

	["backpack2"] = {
		label = "backpack2",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos hátizsák"
	},

	["backpack3"] = {
		label = "backpack3",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos hátizsák"
	},

	["backpack4"] = {
		label = "backpack4",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos hátizsák"
	},

	["backpack5"] = {
		label = "backpack5",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos hátizsák"
	},

	["backpack6"] = {
		label = "backpack6",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos hátizsák"
	},

	["backpack7"] = {
		label = "backpack7",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos hátizsák"
	},

	["duffle1"] = {
		label = "Duffle bag",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos táska"
	},

	["duffle2"] = {
		label = "Duffle bag",
		weight = 15,
		stack = false,
		close = true,
		description = "Stílusos táska"
	},

	["briefcase"] = {
		label = "Briefcase",
		weight = 10,
		stack = false,
		close = true,
		description =
		"A portable rectangular case used for carrying important documents, files, or other personal belongings."
	},

	["paramedicbag"] = {
		label = "Paramedic bag",
		weight = 5,
		stack = false,
		close = true,
		description = "A medical bag used by paramedics, containing essential supplies for emergency care."
	},

	["policepouches"] = {
		label = "Police Pouch",
		weight = 5,
		stack = false,
		close = true,
		description =
		"A pouch used by police officers to store and carry essential supplies such as handcuffs, pepper spray, and other tactical equipment."
	},

	["policepouches1"] = {
		label = "Police Pouch",
		weight = 5,
		stack = false,
		close = true,
		description = "A larger version of the police pouch used to store additional tactical gear and equipment."
	},

	["briefcaselockpicker"] = {
		label = "Briefcase Lockpicker",
		weight = 0.5,
		stack = true,
		close = true,
		description = "Briefcase Lockpicker"
	},

	['alkatreszladakicsi'] = {
		label = 'Alkatrész Láda (Kicsi)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Kis alkatrészláda; néhány alkatrészt rejt."
	},

	['alkatreszladanagy'] = {
		label = 'Alkatrész Láda (Nagy)',
		weight = 0.01,
		stack = true,
		close = true,
		description = "Nagy alkatrészláda; több és jobb alkatrésszel."
	},

	['metaldetector'] = {
		label = 'Fém detektor',
		weight = 2,
		stack = false,
		close = true,
		description = "Segítségével fém tárgyak után kutathatsz a tengerparton"
	},
	['antik_mask'] = {
		label = 'Antik maszk',
		weight = 0.8,
		stack = true,
		close = true,
		description = "Antik maszk; a fémdetektoros kutatás lelete."
	},
	['antik_etkeszlet'] = {
		label = 'Antik étkészlet',
		weight = 0.8,
		stack = true,
		close = true,
		description = "Antik étkészlet; a fémdetektoros kutatás lelete."
	},
	['maja_mask'] = {
		label = 'Maja maszk',
		weight = 0.8,
		stack = true,
		close = true,
		description = "Maja maszk; ritka régészeti lelet."
	},
	['haborus_loszer'] = {
		label = 'Háborús lőszer',
		weight = 0.8,
		stack = true,
		close = true,
		description = "Háborús lőszer; a földből előkerült régiség."
	},
	['aranyrog'] = {
		label = 'Aranyrög',
		weight = 0.8,
		stack = true,
		close = true,
		description = "Aranyrög; a fémdetektoros kutatás legjobb lelete."
	},
	['halloweenlada'] = {
		label = 'Halloween láda',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Halloween láda ünnepi jutalmakkal."
	},
	['horgaszlada'] = {
		label = 'Horgász Láda',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Horgászláda; felszerelést és fogásokat rejt."
	},
	['ppammolada'] = {
		label = 'PP-s Ammo Láda',
		weight = 0.3,
		stack = true,
		close = true,
		description = "PP-s lőszerláda; lőszercsomagot ad."
	},
	['banyalada'] = {
		label = 'Öreg Bányász Láda',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Öreg bányászláda a bányában talált jutalmakkal."
	},
	['carkey'] = {
		label = 'Kocsi kulcs',
		weight = 1,
		stack = true,
		close = true,
		description = "Járműkulcs; a hozzá tartozó autót indítja."
	},
	['alarmremover'] = {
		label = 'Riasztó eltávolító',
		weight = 1,
		stack = true,
		close = true,
		description = "Riasztó eltávolító; leszereli a jármű riasztóját."
	},
	['lacasa'] = {
		label = 'La Casa de Papel',
		weight = 1,
		stack = true,
		close = true,
		description = "La Casa de Papel maszk az arcod elrejtésére."
	},

	['gyorskotozo'] = {
		label = 'Gyorskötöző',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Gyorskötöző a kezek megkötözésére."
	},

	['uwumenu'] = {
		label = 'UWU Étlap',
		weight = 0.01,
		stack = true,
		close = true,
		description = "UWU étlap; a kávézó kínálata."
	},

	['alkatreszszerel'] = {
		label = 'Szerelőkészlet',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Szerelőkészlet alkatrészek beszereléséhez."
	},


	['bundaskenyer'] = {
		label = 'Bundáskenyér',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bundás kenyér, 10%-kal csillapítja az éhséget."
	},

	['lassagne'] = {
		label = 'Lassagne',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Olasz lasagne, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['profit'] = {
		label = 'Profiterol édesség',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Profiterol desszert, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['minest'] = {
		label = 'Minestrone Leves',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Minestrone leves, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},


	['chukkasalata'] = {
		label = 'Chuk Saláta',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Friss saláta, 10%-kal csillapítja az éhséget."
	},


	['domino'] = {
		label = 'Domino',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Az étterem különlegessége, 10%-kal csillapítja az éhséget."
	},


	['ebiamai'] = {
		label = 'Ebiamai',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Rákos sushi fogás, 10%-kal csillapítja az éhséget."
	},


	['ebimiso'] = {
		label = 'Ebimiso',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Rákos miso leves, 10%-kal csillapítja az éhséget."
	},


	['kawaii'] = {
		label = 'Kawaii',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Ázsiai desszert, 10%-kal csillapítja az éhséget."
	},

	['kyodai'] = {
		label = 'Kyodai',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Sushi tál, 10%-kal csillapítja az éhséget."
	},


	['laksa'] = {
		label = 'Laksa',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Fűszeres laksa leves, 10%-kal csillapítja az éhséget."
	},


	['makifuagra'] = {
		label = 'Makifuagra',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Libamájas maki sushi, 10%-kal csillapítja az éhséget."
	},


	['makirainbow'] = {
		label = 'Makirainbow',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Szivárvány maki sushi, 10%-kal csillapítja az éhséget."
	},


	['makiwasabiko'] = {
		label = 'Makiwasabiko',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Wasabis maki sushi, 10%-kal csillapítja az éhséget."
	},


	['megumisan'] = {
		label = 'Megumisan',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Sushi különlegesség, 10%-kal csillapítja az éhséget."
	},


	['midori'] = {
		label = 'Midori',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Zöld sushi tál, 10%-kal csillapítja az éhséget."
	},


	['nabeudon'] = {
		label = 'Nabeudon',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Udon tésztaleves, 10%-kal csillapítja az éhséget."
	},


	['padthai'] = {
		label = 'Padthai',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Pad thai tészta, 10%-kal csillapítja az éhséget."
	},

	['planetset'] = {
		label = 'Planetset',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Nagy sushi szett, 10%-kal csillapítja az éhséget."
	},

	['premiumset'] = {
		label = 'Premiumset',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Prémium sushi szett, 10%-kal csillapítja az éhséget."
	},

	['tomkha'] = {
		label = 'Tomkha',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Tom kha leves, 10%-kal csillapítja az éhséget."
	},

	['toriharumaki'] = {
		label = 'Toriharumaki',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Csirkés tavaszi tekercs, 10%-kal csillapítja az éhséget."
	},

	['torimisosarada'] = {
		label = 'Torimisosarada',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Csirkés miso saláta, 10%-kal csillapítja az éhséget."
	},

	['whiteorchid'] = {
		label = 'Whiteorchid',
		weight = 0.1,
		stack = true,
		close = true,
		description = "A ház sushi különlegessége, 10%-kal csillapítja az éhséget."
	},

	['borutogranatalmas'] = {
		label = 'Borutogránát Almás',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Gránátalmás ital, 10%-kal oltja a szomjúságot."
	},

	['hatakosengorogdinnyeramuneszoda'] = {
		label = 'Hatakosen Görögdinnye',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Görögdinnyés japán szóda, 10%-kal oltja a szomjúságot."
	},

	['iichiko'] = {
		label = 'Iichiko',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Japán shochu, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['machetee'] = {
		label = 'Matcha Tee',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Matcha tea, 10%-kal oltja a szomjúságot."
	},

	['ozekishake'] = {
		label = 'Ozekishake',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Szakés turmix, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['saka'] = {
		label = 'Saka',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Japán szaké, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['senchatea'] = {
		label = 'Senchatea',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Szakéval kevert zöld tea, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['soju'] = {
		label = 'Soju',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Koreai soju, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['zoldtea'] = {
		label = 'Zold Tea',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Zöld tea, 10%-kal oltja a szomjúságot."
	},

	['kiscraftkulcs'] = {
		label = 'Kis Craft Kulcs',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kis craft kulcs a kisebb ládák és craftok nyitásához."
	},
	
	['drogtasak'] = {
		label = 'Drog Tasak',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Drogtasak az adagok csomagolásához."
	},

	['nagycraftkulcs'] = {
		label = 'Nagy Craft Kulcs',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Nagy craft kulcs a nagyobb ládák és craftok nyitásához."
	},

	['controller'] = {
		label = 'Vezérlő',
		weight = 1,
		stack = true,
		close = true,
		description = "Vezérlő; elektronikai eszközök irányításához."
	},

	['hat'] = {
		label = 'kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Kalap; fejre húzható viselet."
	},

	['hat2'] = {
		label = 'kalap2',
		weight = 1,
		stack = true,
		close = true,
		description = "Kalap, másik változatban."
	},

	['teddybear'] = {
		label = 'Teddi maci',
		weight = 1,
		stack = true,
		close = true,
		description = "Plüssmaci; a kisállat kedvence."
	},

	['glasses'] = {
		label = 'szemüveg',
		weight = 1,
		stack = true,
		close = true,
		description = "Szemüveg."
	},

	['glasses2'] = {
		label = 'szemüveg2',
		weight = 1,
		stack = true,
		close = true,
		description = "Szemüveg, másik változatban."
	},

	['tennisball'] = {
		label = 'Labda',
		weight = 1,
		stack = true,
		close = true,
		description = "Teniszlabda; a kisállat imád utána szaladni."
	},

	['petbowl'] = {
		label = 'Pet Takarmány tál',
		weight = 1,
		stack = true,
		close = true,
		description = "Etetőtál a kisállatnak."
	},
	['petbed'] = {
		label = 'Pet Ágy',
		weight = 1,
		stack = true,
		close = true,
		description = "Kisállat ágy a pihenéshez."
	},
	['petbed2'] = {
		label = 'Pet Ágy2',
		weight = 1,
		stack = true,
		close = true,
		description = "Kisállat ágy, másik változatban."
	},
	['nametag'] = {
		label = 'Névtábla',
		weight = 1,
		stack = true,
		close = true,
		description = "Névtábla a kisállat nyakörvére."
	},
	['coolglasses'] = {
		label = 'Menő szemüvegek',
		weight = 1,
		stack = true,
		close = true,
		description = "Menő napszemüveg a kisállatnak."
	},
	['collar'] = {
		label = 'Pet Gallér',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyakörv a kisállatnak."
	},
	['collar2'] = {
		label = 'Pet Gallér2',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyakörv a kisállatnak, másik változatban."
	},
	['collar3'] = {
		label = 'Pet Gallér3',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyakörv a kisállatnak, harmadik változatban."
	},
	['collar4'] = {
		label = 'Pet Gallér4',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyakörv a kisállatnak, negyedik változatban."
	},
	['collar5'] = {
		label = 'Pet Gallér5',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyakörv a kisállatnak, ötödik változatban."
	},
	['collar6'] = {
		label = 'Pet Gallér6',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyakörv a kisállatnak, hatodik változatban."
	},
	['collar7'] = {
		label = 'Pet Gallér7',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyakörv a kisállatnak, hetedik változatban."
	},
	['bluebandana'] = {
		label = 'Kék Bandana',
		weight = 1,
		stack = true,
		close = true,
		description = "Kék bandana a kisállatnak."
	},
	['unihorn'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak."
	},
	['unihorn2'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak, másik változatban."
	},
	['unihorn3'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak, harmadik változatban."
	},
	['unihorn4'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak, negyedik változatban."
	},
	['unihorn5'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak, ötödik változatban."
	},
	['unihorn6'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak, hatodik változatban."
	},
	['unihorn7'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak, hetedik változatban."
	},
	['unihorn8'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak, nyolcadik változatban."
	},
	['unihorn9'] = {
		label = 'Egyszarvú kürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Egyszarvú kürt a kisállatnak, kilencedik változatban."
	},
	['tinyhat'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak."
	},
	['tinyhat2'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, másik változatban."
	},
	['tinyhat3'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, harmadik változatban."
	},
	['tinyhat4'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, negyedik változatban."
	},
	['tinyhat5'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, ötödik változatban."
	},
	['tinyhat6'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, hatodik változatban."
	},
	['tinyhat7'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, hetedik változatban."
	},
	['tinyhat8'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, nyolcadik változatban."
	},
	['tinyhat9'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, kilencedik változatban."
	},
	['tinyhat10'] = {
		label = 'Apró kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Apró kalap a kisállatnak, tizedik változatban."
	},
	['beewings'] = {
		label = 'Méh Szárnyak',
		weight = 1,
		stack = true,
		close = true,
		description = "Méhszárnyak a kisállatnak."
	},
	['batmanvest'] = {
		label = 'Batman mellény',
		weight = 1,
		stack = true,
		close = true,
		description = "Batman mellény a kisállatnak."
	},
	['redvest'] = {
		label = 'Vörös mellény',
		weight = 1,
		stack = true,
		close = true,
		description = "Vörös mellény a kisállatnak."
	},
	['elytecollar'] = {
		label = 'Elyte nyakörv',
		weight = 1,
		stack = true,
		close = true,
		description = "Elyte nyakörv a kisállatnak."
	},
	['blackvest'] = {
		label = 'Fekete mellény',
		weight = 1,
		stack = true,
		close = true,
		description = "Fekete mellény a kisállatnak."
	},
	['bowtie'] = {
		label = 'Csokornyakkendő',
		weight = 1,
		stack = true,
		close = true,
		description = "Csokornyakkendő a kisállatnak."
	},
	['daisyvest'] = {
		label = 'Százszorszép Mellény',
		weight = 1,
		stack = true,
		close = true,
		description = "Százszorszép mintás mellény a kisállatnak."
	},
	['petchef'] = {
		label = 'Séf Kalap',
		weight = 1,
		stack = true,
		close = true,
		description = "Séfsapka a kisállatnak."
	},
	['daisycrown'] = {
		label = 'Százszorszép korona',
		weight = 1,
		stack = true,
		close = true,
		description = "Százszorszép korona a kisállatnak."
	},
	['petdeer'] = {
		label = 'Szarvaskürt',
		weight = 1,
		stack = true,
		close = true,
		description = "Szarvasagancs a kisállatnak."
	},
	['petchain'] = {
		label = 'Kisállat lánc',
		weight = 1,
		stack = true,
		close = true,
		description = "Nyaklánc a kisállatnak."
	},
	['partyglasses'] = {
		label = 'Party szemüveg',
		weight = 1,
		stack = true,
		close = true,
		description = "Party szemüveg a kisállatnak."
	},
	['beetail'] = {
		label = 'Méh Farok',
		weight = 1,
		stack = true,
		close = true,
		description = "Méhfarok a kisállatnak."
	},
	['beadnecklace'] = {
		label = 'Gyöngy nyaklánc',
		weight = 1,
		stack = true,
		close = true,
		description = "Gyöngy nyaklánc a kisállatnak."
	},
	['pinksweater'] = {
		label = 'Rózsaszín pulóver',
		weight = 1,
		stack = true,
		close = true,
		description = "Rózsaszín pulóver a kisállatnak."
	},
	['xmasvest'] = {
		label = 'Karácsonyi mellény',
		weight = 1,
		stack = true,
		close = true,
		description = "Karácsonyi mellény a kisállatnak."
	},
	['brownshoes'] = {
		label = 'Barna cipők',
		weight = 1,
		stack = true,
		close = true,
		description = "Barna cipők a kisállatnak."
	},
	['fairyvest'] = {
		label = 'Tündérmellény',
		weight = 1,
		stack = true,
		close = true,
		description = "Tündérmellény a kisállatnak."
	},
	['k9vest'] = {
		label = 'K9 Mellény',
		weight = 1,
		stack = true,
		close = true,
		description = "K9 szolgálati mellény a kisállatnak."
	},


	-- Treat items
	['treatmentkit'] = {
		label = 'Kezelőkészlet',
		weight = 1,
		stack = true,
		close = true,
		description = "Kezelőkészlet; ellátja a sérült kisállatot."
	},
	['revivekit'] = {
		label = 'Felélesztő láda',
		weight = 1,
		stack = true,
		close = true,
		description = "Felélesztő készlet; visszahozza az eszméletlen kisállatot."
	},
	['treatmentpills'] = {
		label = 'Kezelő tabletták',
		weight = 1,
		stack = true,
		close = true,
		description = "Kezelő tabletta a beteg kisállatnak."
	},

	-- Leashes (Update v1.5)
	['leash'] = {
		label = 'Kisállat Póráz',
		weight = 1,
		stack = true,
		close = true,
		description = "Póráz a kisállat sétáltatásához."
	},
	['leash2'] = {
		label = 'Kisállat Póráz',
		weight = 1,
		stack = true,
		close = true,
		description = "Póráz a kisállat sétáltatásához, másik változatban."
	},
	['leash3'] = {
		label = 'Kisállat Póráz',
		weight = 1,
		stack = true,
		close = true,
		description = "Póráz a kisállat sétáltatásához, harmadik változatban."
	},

	['handcuffs'] = {
		label = 'bilincs',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bilincs; a megbilincselt személy nem tud elmenekülni."
	},

	['ls_weed_block'] = {
		label = 'Fű blokk',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Préselt fűtömb a kartell árujából."
	},

	['ls_weed_bag'] = {
		label = 'Weed Táska',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Fűvel teli táska; a kartell szállítmánya."
	},

	['ls_coke_block'] = {
		label = 'Coke Blokk',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Préselt kokaintömb a kartell raktárából."
	},

	['ls_coke_powder'] = {
		label = 'Coke',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kokainpor a kartell árujából."
	},

	['ls_jewellery'] = {
		label = 'Ékszerek',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Ékszerek a kartell zsákmányából."
	},

	['ls_entrance_key'] = {
		label = 'Cartel Kulcs',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kulcs a kartell bejáratához."
	},

	['ls_emp_blocker'] = {
		label = 'EMP blokkoló',
		weight = 0.1,
		stack = true,
		close = true,
		description = "EMP blokkoló; kivédi az elektromos zavarást."
	},

	['ls_wire_cutters'] = {
		label = 'Drótvágók',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Drótvágó kerítések és vezetékek átvágásához."
	},

	['ls_thermite'] = {
		label = 'Termit gyújtóbomba',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Termit gyújtóbomba ajtók átégetéséhez."
	},

	['ls_card'] = {
		label = 'Belépőkártya',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Belépőkártya a kartell zárt ajtajaihoz."
	},

	['husvetipalinka'] = {
		label = 'Húsvéti Pálinka',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Húsvéti pálinka; ünnepi itóka."
	},

	['zombilada'] = {
		label = 'Zombi Láda',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Zombi láda az esemény jutalmaival."
	},

	['faslada'] = {
		label = 'Favágók Ládája',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Favágók ládája; a fakitermelés jutalma."
	},

	['zombiticket'] = {
		label = 'Zombi Ticket',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Zombi jegy; az esemény jutalmára váltható."
	},

	['jelveny'] = {
		label = 'Jelvény',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Jelvény; a viselője rangját mutatja."
	},

	['animal_tracker'] = {
		label = 'Állatkövető',
		weight = 200,
		allowArmed = true,
		stack = false,
		description = "Állatkövető a vad nyomainak követéséhez.",
	},
	['campfire'] = {
		label = 'Tábortűz',
		weight = 200,
		allowArmed = true,
		stack = false,
		description = "Tábortűz; vadászat közben rakható.",
	},

	['huntingbait'] = {
		label = 'Vadászcsali',
		weight = 100,
		allowArmed = true,
		description = "Vadászcsali; odacsalogatja a vadat.",
	},

	['cooked_meat'] = {
		label = 'Főtt hús',
		weight = 200,
		description = "Megsütött hús, 10%-kal csillapítja az éhséget.",
	},
	['raw_meat'] = {
		label = 'Nyers hús',
		weight = 200,
		description = "Nyers hús; a vadászzsákmány feldolgozatlan része.",
	},

	['skin_deer_ruined'] = {
		label = 'Kopott szarvasbőr',
		weight = 200,
		description = "Tönkrement szarvasbőr; alig ér valamit.",
	},
	['skin_deer_low'] = {
		label = 'Kopott szarvasbőr',
		weight = 200,
		description = "Kopott szarvasbőr; gyenge minőség.",
	},
	['skin_deer_medium'] = {
		label = 'Rugalmas szarvasbőr',
		weight = 200,
		description = "Rugalmas szarvasbőr; közepes minőség.",
	},
	['skin_deer_good'] = {
		label = 'Prémium Szarvasbőr',
		weight = 200,
		description = "Prémium szarvasbőr; jó árat ad.",
	},
	['skin_deer_perfect'] = {
		label = 'Hibátlan szarvasbőr',
		weight = 200,
		description = "Hibátlan szarvasbőr; a legjobb árat éri el.",
	},

	['deer_horn'] = {
		label = 'Szarvaskürt',
		weight = 1000,
		description = "Őzagancs; vadászzsákmány, felvásárlónál értékes.",
	},

	['smallbrother'] = {
		label = 'Small brother (burger)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Kisebb burger, 10%-kal csillapítja az éhséget."
	},

	['soaburger'] = {
		label = 'SOA burger (burger)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "A ház burgere, 10%-kal csillapítja az éhséget."
	},

	['oldnorth'] = {
		label = 'Old north (steak)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Marhasteak, 10%-kal csillapítja az éhséget."
	},

	['soaproni'] = {
		label = 'Soaproni (Soproni sőr)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Dobozos sör, 10%-kal oltja a szomjúságot. Alkoholos, berúgsz tőle."
	},

	['buffalotrace'] = {
		label = 'Buffalo Trace (Whiskey)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Bourbon whiskey, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['babgulyasleves'] = {
		label = 'Babgulyás leves',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Babgulyás, 10%-kal csillapítja az éhséget."
	},

--##ZOMBI meg mutatja a craft tárgyakat

	['fegyverterv'] = {
		label = 'Craft Segítő darab',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Craft segítő darab; a fegyvertervrajz része."
	},

	['fegyverterv2'] = {
		label = 'Craft Segítő (Pisztoly)',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Craft segítő: pisztoly tervrajza."
	},
	['fegyverterv3'] = {
		label = 'Craft Segítő (Tech)',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Craft segítő: tech eszközök tervrajza."
	},
	['fegyverterv4'] = {
		label = 'Craft Segítő (Ak47)',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Craft segítő: AK-47 tervrajza."
	},
	['fegyverterv5'] = {
		label = 'Craft Segítő (PumpShotGun)',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Craft segítő: Pump Shotgun tervrajza."
	},
	['fegyverterv6'] = {
		label = 'Craft Segítő (Micro Smg)',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Craft segítő: Micro SMG tervrajza."
	},
	['fegyverterv7'] = {
		label = 'Craft Segítő (Ap Pisztoly)',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Craft segítő: AP pisztoly tervrajza."
	},
--##ZOMBI meg mutatja a craft tárgyakat	

	['cordonblue'] = {
		label = 'Cordon Blue',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Cordon bleu, 10%-kal csillapítja az éhséget."
	},

	['zebrasteak'] = {
		label = 'Zebra Steak',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Zebra steak, 10%-kal csillapítja az éhséget."
	},

	['franciakremes'] = {
		label = 'Francia Krémes',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Francia krémes, 10%-kal csillapítja az éhséget."
	},

	['csokisshakenespresso'] = {
		label = 'Csokis Shakenespresso',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Csokis-eszpresszós turmix, 20%-kal oltja a szomjúságot."
	},

	['epermocktail'] = {
		label = 'Eper Mocktail',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Alkoholmentes eper koktél, 10%-kal oltja a szomjúságot."
	},

	['cabarnetsauvignon'] = {
		label = 'Cabarnet Sauvignon',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Cabernet Sauvignon vörösbor, 10%-kal oltja a szomjúságot."
	},

	['gyombereskinley'] = {
		label = 'Gyömbéres Kinley (ital)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Gyömbéres üdítő, 10%-kal oltja a szomjúságot."
	},

	['lattemachiato'] = {
		label = 'Latte machiato (Kávé)',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Latte macchiato, 10%-kal oltja a szomjúságot."
	},

	['bc_newbackpack_1'] = {
		label = 'Sárkány Trash Piros',
		description = 'Egy különleges, piros színű sárkány hátizsák. Egyedi megjelenésével kitűnsz a tömegből, miközben praktikus tárolóhelyet biztosít számodra.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_2'] = {
		label = 'Sárkány Trash Kék',
		description = 'Kék színű sárkány hátizsák, amely a stílust és a funkcionalitást ötvözi. Ideális választás mindennapi használatra.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_3'] = {
		label = 'Sárkány Trash Fehér',
		description = 'Elegáns, fehér sárkány hátizsák. Letisztult megjelenése miatt tökéletes választás azoknak, akik a minimalista stílust kedvelik.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_4'] = {
		label = 'Sárkány Trash Zöld',
		description = 'Zöld színű sárkány hátizsák, amely természetközeli megjelenést biztosít. Strapabíró és praktikus társ a mindennapokban.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_5'] = {
		label = 'Sárkány Trash Lila',
		description = 'Lila sárkány hátizsák, amely egyedi és feltűnő stílust képvisel. Tökéletes választás, ha ki akarsz emelkedni a tömegből.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_6'] = {
		label = 'Sárkány Trash Sötét Zöld',
		description = 'Sötétzöld sárkány hátizsák, komolyabb és letisztult megjelenéssel. Ideális azok számára, akik visszafogott, mégis különleges stílust keresnek.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_7'] = {
		label = 'Sárkány Trash Szürke',
		description = 'Szürke sárkány hátizsák, amely minden öltözethez passzol. Egyszerű, mégis különleges kialakításának köszönhetően bárhol megállja a helyét.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_8'] = {
		label = 'Tehén Trash Táska',
		description = 'Rózsaszín-fekete foltos tehén plüss hátizsák. Puha, feltűnő darab, ami mellett nehéz elmenni.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_9'] = {
		label = 'Cica Trash Táska Korall',
		description = 'Korallszínű cicás hátizsák, elöl ablakos hordozóval és nyuszi függővel.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_10'] = {
		label = 'Szív Trash Táska',
		description = 'Piros hátizsák nagy szív alakú előzsebbel. Kerek formák, vidám megjelenés.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_11'] = {
		label = 'Graffiti Trash Fekete',
		description = 'Fekete hátizsák füstös, graffitis koponyamintával. Utcai stílus.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_12'] = {
		label = 'Bálna Trash Táska',
		description = 'Sárga bálna formájú plüss hátizsák, kék uszonyokkal. Puha és jókedvű darab.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_13'] = {
		label = 'Sárkány Trash Menta',
		description = 'Mentazöld sárkány plüss hátizsák fehér szárnyakkal és lila tüskesorral.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_14'] = {
		label = 'Koponyás Maci Trash',
		description = 'Barna maci plüss hátizsák koponya fejjel. Cukiság és morbid egy darabban.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_15'] = {
		label = 'Városi Trash Fekete',
		description = 'Letisztult fekete városi hátizsák. Diszkrét, strapabíró, mindennapokra való.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_16'] = {
		label = 'Cica Trash Táska Kék',
		description = 'Kék cicás hátizsák, elöl ablakos hordozóval és fekete-fehér cicával.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_17'] = {
		label = 'Cica Trash Rózsaszín',
		description = 'Rózsaszín cicás hátizsák, elöl ablakos hordozóval és nyuszi függővel.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_18'] = {
		label = 'Cica Trash Táska Fehér',
		description = 'Fehér cicás hátizsák narancs fülekkel, elöl ablakos hordozóval.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_19'] = {
		label = 'Cica Trash Táska Foltos',
		description = 'Narancs-fehér foltos cicás hátizsák, elöl ablakos hordozóval.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_20'] = {
		label = 'Városi Trash Szürke',
		description = 'Világosszürke városi hátizsák türkiz cipzárbetéttel. Könnyű és letisztult.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_21'] = {
		label = 'Városi Trash Barna',
		description = 'Sötétbarna városi hátizsák. Visszafogott szín, kényelmes hordás.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_22'] = {
		label = 'Városi Trash Kék',
		description = 'Élénkkék városi hátizsák. Feltűnő szín, hétköznapi praktikum.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_23'] = {
		label = 'Városi Trash Sötétkék',
		description = 'Sötétkék városi hátizsák szürke cipzárbetéttel. Komoly, letisztult megjelenés.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_24'] = {
		label = 'Graffiti Trash Piros',
		description = 'Sötét hátizsák piros és lila graffitis koponyamintával. Utcai stílus.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_25'] = {
		label = 'Graffiti Trash Fehér',
		description = 'Fehér hátizsák halvány, pasztell graffitis koponyamintával.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['bc_newbackpack_26'] = {
		label = 'Graffiti Trash Zöld',
		description = 'Sötétzöld hátizsák graffitis koponyamintával. Utcai stílus.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['hnganh_axolo1t'] = {
		label = 'Axolo1t Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Axolo1t mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_cowboy'] = {
		label = 'Cowboy Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Cowboy mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_cutefeline'] = {
		label = 'Cutefeline Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Cutefeline mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_yellow'] = {
		label = 'Yellow Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Yellow mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_canhcutgs'] = {
		label = 'Canhcutgs Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Canhcutgs mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_grinch'] = {
		label = 'Grinch Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Grinch mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_reindeer'] = {
		label = 'Reindeer Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Reindeer mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_snowman'] = {
		label = 'Snowman Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Snowman mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_alyx_bag_01'] = {
		label = 'Alyx Tash',
    	weight = 1.0,
		weightmult = 0.8,
		description = "Alyx mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},
	['toxic_cat_bag_01'] = {
		label = 'Cat Tash',
  		weight = 1.0,
		weightmult = 0.8,
		description = "Cat mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},
	['toxic_hello_kitty_bag_01'] = {
		label = 'Hello Kitty Tash',
    	weight = 1.0,
		weightmult = 0.8,
		description = "Hello Kitty mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},
	['toxic_tactical_bag_01'] = {
		label = 'Tactical Tash',
  		weight = 1.0,
		weightmult = 0.8,
		description = "Tactical mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},
	['toxic_watchdog_bag_01'] = {
		label = 'Watchdog Tash',
  		weight = 1.0,
		weightmult = 0.8,
		description = "Watchdog mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_dino_bag_01'] = {
		label = 'Béka Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Béka mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_mobidick_bag_01'] = {
		label = 'Mobidick Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Mobidick mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_pig_bag_01'] = {
		label = 'Pig Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Pig mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_skull_teddy_bag_01'] = {
		label = 'Skull Teddy Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Skull Teddy mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['toxic_usahanna_bag_01'] = {
		label = 'Usahanna Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Usahanna mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_teddy_bag_01'] = {
		label = 'Teddy Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Teddy mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_snorlax_bag_01'] = {
		label = 'Snorlax Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Snorlax mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_polar_bear_bag_01'] = {
		label = 'Jegesmedve Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Jegesmedve mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_mew_bag_01'] = {
		label = 'Mew Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Mew mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_kuma_bag_01'] = {
		label = 'Kuma Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Kuma mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_gloomy_bear_bag_02'] = {
		label = 'Gloomy Bear Trash 2',
		weight = 1.0,
		weightmult = 0.8,
		description = "Gloomy Bear 2 mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_gloomy_bear_bag_01'] = {
		label = 'Gloomy Bear Trash 1',
		weight = 1.0,
		weightmult = 0.8,
		description = "Gloomy Bear 1 mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_baby_shark_bag_01'] = {
		label = 'Baby Shark hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Baby Shark mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_baby_shark_bag_02'] = {
		label = 'Baby Shark prémium hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Baby Shark prémium mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_doom_daze_fur_bag_01'] = {
		label = 'Doom Daze szőrme hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Doom Daze szőrme mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_doom_daze_fur_bag_02'] = {
		label = 'Doom Daze fekete szőrme hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Doom Daze fekete szőrme mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_doom_daze_fur_bag_03'] = {
		label = 'Doom Daze limitált szőrme hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Doom Daze limitált szőrme mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_doom_daze_leather_bag_01'] = {
		label = 'Doom Daze bőr hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Doom Daze bőr mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_doom_daze_leather_bag_02'] = {
		label = 'Doom Daze prémium bőr hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Doom Daze prémium bőr mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_hearth_bag_01'] = {
		label = 'Heart mintás hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Heart mintás mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_hearth_bag_02'] = {
		label = 'Prémium Heart hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Prémium Heart mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_katana_bag_01'] = {
		label = 'Katana stílusú hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Katana stílusú mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_minecraft_hearth_bag_01'] = {
		label = 'Pixel Heart hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Pixel Heart mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_neon_shark_bag_01'] = {
		label = 'Neon Shark hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Neon Shark mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_neon_shark_bag_02'] = {
		label = 'Neon Shark kék hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Neon Shark kék mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_neon_shark_bag_03'] = {
		label = 'Neon Shark limitált hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Neon Shark limitált mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_skateboard_bag_01'] = {
		label = 'Skateboard hátizsák I',
		weight = 1.0,
		weightmult = 0.8,
		description = "Skateboard I mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_skateboard_bag_02'] = {
		label = 'Skateboard hátizsák II',
		weight = 1.0,
		weightmult = 0.8,
		description = "Skateboard II mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_skateboard_bag_03'] = {
		label = 'Skateboard hátizsák III',
		weight = 1.0,
		weightmult = 0.8,
		description = "Skateboard III mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_skateboard_bag_04'] = {
		label = 'Skateboard graffiti hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Skateboard graffiti mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_skateboard_bag_05'] = {
		label = 'Skateboard urban hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Skateboard urban mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_skateboard_bag_06'] = {
		label = 'Skateboard pro hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Skateboard pro mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['toxic_spray_ground_bag_01'] = {
		label = 'Sprayground stílusú hátizsák',
		weight = 1.0,
		weightmult = 0.8,
		description = "Sprayground stílusú mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_bird'] = {
		label = 'Bird Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Bird mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_bunny'] = {
		label = 'Bunny Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Bunny mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_dachshund'] = {
		label = 'Dachshund Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Dachshund mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_gingerbread'] = {
		label = 'Gingerbread Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Gingerbread mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_polarbear'] = {
		label = 'Polarbear Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Polarbear mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_puppyv3'] = {
		label = 'PuppyV3 Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "PuppyV3 mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_santaclaus'] = {
		label = 'Mikulás Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Mikulás mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

--##GRINCS:
	['toxic_grinch_bag_01'] = {
		label = 'Grincs Zsák',
		description = 'Egy koszos, zsák, amit a Grincs hagyott maga után.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['toxic_grinch_bag_02'] = {
		label = 'Grincs Zsák 2',
		description = 'Egy koszos, zsák, amit a Grincs hagyott maga után.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['toxic_grinch_bag_03'] = {
		label = 'Grincs Zsák 3',
		description = 'Egy koszos, zsák, amit a Grincs hagyott maga után.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['toxic_grinch_bag_04'] = {
		label = 'Grincs  Zsák 4',
		description = 'Egy koszos, zsák, amit a Grincs hagyott maga után.',
		weight = 1.0,
		weightmult = 0.8,
	},

	['toxic_grinch_bag_05'] = {
		label = 'Grincs Zsák 5',
		description = 'Egy koszos, zsák, amit a Grincs hagyott maga után.',
		weight = 1.0,
		weightmult = 0.8,
	},

--##2025 karitaska

	['hnganh_puppysssv3'] = {
		label = 'Vándor Táska (4) Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Vándor mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},
	
	['hnganh_anya'] = {
		label = 'Milf Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Milf mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},
	
	['hnganh_bagdino'] = {
		label = 'Bagdino Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Bagdino mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},
	
	['hnganh_bmo'] = {
		label = 'Bmo Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Bmo mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},
	
	['hnganh_dragonsun'] = {
		label = 'Dragonsun Trash',
		weight = 1.0,
		weightmult = 0.9,
		description = "Dragonsun mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 10%-kal könnyebbnek számít.",
	},
	
	['hnganh_scooby'] = {
		label = 'Vándor Táska (3) Trash',
		weight = 1.0,
		weightmult = 0.75,
		description = "Vándor mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 25%-kal könnyebbnek számít.",
	},

	['hnganh_goose'] = {
		label = 'Goose Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Goose mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_sealbag'] = {
		label = 'Sealbag Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Sealbag mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_squirrel'] = {
		label = 'Squirrel Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Squirrel mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_walle'] = {
		label = 'Vándor Táska (2) Trash',
		weight = 1.0,
		weightmult = 0.8,
		description = "Vándor mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 20%-kal könnyebbnek számít.",
	},

	['hnganh_goose2'] = {
		label = 'Goose2 Trash',
		weight = 1.0,
		weightmult = 0.9,
		description = "Liba mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['hnganh_bee2'] = {
		label = 'Bee Trash',
		weight = 1.0,
		weightmult = 0.75,
		description = "Bee mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 25%-kal könnyebbnek számít.",
	},

	['hnganh_magickitty'] = {
		label = 'Magic Kitty Trash',
		weight = 1.0,
		weightmult = 0.75,
		description = "Magic Kitty mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 25%-kal könnyebbnek számít.",
	},

	['hnganh_naughty'] = {
		label = 'Naughty Trash',
		weight = 1.0,
		weightmult = 0.75,
		description = "Naughty mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 25%-kal könnyebbnek számít.",
	},

	['hnganh_politoed'] = {
		label = 'Politoed Trash',
		weight = 1.0,
		weightmult = 0.75,
		description = "Politoed mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 25%-kal könnyebbnek számít.",
	},

	['hnganh_toddler'] = {
		label = 'Toddler Trash',
		weight = 1.0,
		weightmult = 0.75,
		description = "Toddler mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 25%-kal könnyebbnek számít.",
	},

	['hnganh_stichv2'] = {
		label = 'Vándor Táska (1) Trash',
		weight = 1.0,
		weightmult = 0.75,
		description = "Vándor mintájú hátizsák: 20 rekesz, legfeljebb 10 kg fér bele. A benne tárolt holmi 25%-kal könnyebbnek számít.",
	},

	['shark_boi'] = {
		label = 'Shark Boi',
		weight = 1.0,
		description = "Cápa mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['monkey_punk'] = {
		label = 'Monkey Punk',
		weight = 1.0,
		description = "Punk majom mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['monky'] = {
		label = 'Monky',
		weight = 1.0,
		description = "Majom mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['fox'] = {
		label = 'Fox',
		weight = 1.0,
		description = "Róka mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['questing_mouse'] = {
		label = 'Questing Mouse',
		weight = 1.0,
		description = "Kalandor egér mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['armored_cat'] = {
		label = 'Armored Cat',
		weight = 1.0,
		description = "Páncélos macska mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['hollow_knight'] = {
		label = 'Hollow Knight',
		weight = 1.0,
		description = "Hollow Knight mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['knight_cat'] = {
		label = 'Knight Cat',
		weight = 1.0,
		description = "Lovag macska mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['dino'] = {
		label = 'Dino',
		weight = 1.0,
		description = "Dínó mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['dino_student'] = {
		label = 'Student Dino',
		weight = 1.0,
		description = "Diák dínó mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['pig_angel'] = {
		label = 'Pig Angel',
		weight = 1.0,
		description = "Angyalmalac mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['mickey_mouse'] = {
		label = 'Mickey Mouse',
		weight = 1.0,
		description = "Egér mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['blossom'] = {
		label = 'Blossom',
		weight = 1.0,
		description = "Blossom mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['buttercup'] = {
		label = 'Buttercup',
		weight = 1.0,
		description = "Buttercup mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	['bubbles'] = {
		label = 'Bubbles',
		weight = 1.0,
		description = "Bubbles mintájú hátizsák-kinézet; a hátadon látszik, tárhelyet nem ad.",
	},

	-- === DoItDigital animalt petek (rm_pets) - 2026-09-04 ===

	['pet_bunny'] = {
		label = 'Nyuszi',
		weight = 1.0,
		description = 'Masnis plüssnyuszi, csupa fül és jókedv. Használd, hogy a válladra ültesd.',
	},

	['pet_bunnypop'] = {
		label = 'Nyuszi Pop',
		weight = 1.0,
		description = 'Kertésznadrágos nyuszi egy szál répával. A répa nem alku tárgya. Használd, hogy a válladra ültesd.',
	},

	['pet_catcute'] = {
		label = 'Cuki Cica',
		weight = 1.0,
		description = 'Pizsamás cica, aki bárhol elalszik. Használd, hogy a válladra ültesd.',
	},

	['pet_cat1'] = {
		label = 'Cica 1',
		weight = 1.0,
		description = 'Hópárduc kölyök. Csendes, de mindent figyel. Használd, hogy a válladra ültesd.',
	},

	['pet_cat2'] = {
		label = 'Cica 2',
		weight = 1.0,
		description = 'Szürke kiscica, nagy szemekkel bámulja a világot. Használd, hogy a válladra ültesd.',
	},

	['pet_cat3'] = {
		label = 'Cica 3',
		weight = 1.0,
		description = 'Sötét bundás, szárnyas cica. Éjszaka is ébren van. Használd, hogy a válladra ültesd.',
	},

	['pet_chefdog'] = {
		label = 'Szakács Kutya',
		weight = 1.0,
		description = 'Szakácssapkás kutyus. Minden ételszagra megfordul. Használd, hogy a válladra ültesd.',
	},

	['pet_demongoat'] = {
		label = 'Démon Kecske',
		weight = 1.0,
		description = 'Vörös szemű démonkecske. Jobb, ha nem nézel a szemébe. Használd, hogy a válladra ültesd.',
	},

	['pet_dragon'] = {
		label = 'Sárkány Kedvenc',
		weight = 1.0,
		description = 'Lila kissárkány. Még csak füstöl, tüzet nem okád. Használd, hogy a válladra ültesd.',
	},

	['pet_kitsune'] = {
		label = 'Kitsune Róka',
		weight = 1.0,
		description = 'Csöngős nyakörves rókaszellem, mini kiadásban. Állítólag szerencsét hoz. Használd, hogy a válladra ültesd.',
	},

	['pet_mollie'] = {
		label = 'Mollie',
		weight = 1.0,
		description = 'Vámpírgalléros cica. Éjszakai műszakban dolgozik. Használd, hogy a válladra ültesd.',
	},

	['pet_monkey'] = {
		label = 'Majom',
		weight = 1.0,
		description = 'Kismajom banánnal. Ne hagyd őrizetlenül a zsebedet. Használd, hogy a válladra ültesd.',
	},

	['pet_mummies'] = {
		label = 'Múmiák',
		weight = 1.0,
		description = 'Bepólyált kis múmia. Több ezer éves, mégis jókedvű. Használd, hogy a válladra ültesd.',
	},

	['pet_otter'] = {
		label = 'Vidra',
		weight = 1.0,
		description = 'Barna vidra. Imád mindent a mancsában forgatni. Használd, hogy a válladra ültesd.',
	},

	['pet_panda'] = {
		label = 'Panda',
		weight = 1.0,
		description = 'Panda egy szál bambusszal. Eszik, alszik, ismétel. Használd, hogy a válladra ültesd.',
	},

	['pet_penguin'] = {
		label = 'Pingvin',
		weight = 1.0,
		description = 'Sísapkás pingvin. A hideget bírja, a meleget nem. Használd, hogy a válladra ültesd.',
	},

	['pet_pumpkinmonster'] = {
		label = 'Tökszörny',
		weight = 1.0,
		description = 'Tökfejű kis szörny. Halloween óta nem hajlandó hazamenni. Használd, hogy a válladra ültesd.',
	},

	['pet_shark'] = {
		label = 'Cápa Kedvenc',
		weight = 1.0,
		description = 'Cápajelmezes plüss. Sokkal veszélyesebbnek hiszi magát. Használd, hogy a válladra ültesd.',
	},

	['pet_skeletons'] = {
		label = 'Csontvázak',
		weight = 1.0,
		description = 'Táncoló csontváz. Csontig ható humorérzékkel. Használd, hogy a válladra ültesd.',
	},

	['pet_strawberry'] = {
		label = 'Eper Szörny',
		weight = 1.0,
		description = 'Eperjelmezes kis szörny. Édesebb, mint amilyennek látszik. Használd, hogy a válladra ültesd.',
	},


	["sbtablet"] = {
		label = "S Tablet",
		weight = 250,
		stack = false,
		close = true,
		description = "S Tablet; hordozható érintőképernyős eszköz.",
	},

	['spike'] = {
		label = 'Szögesdrót',
		weight = 1600,
		description = "Szögesdrót; kiterítve kilyukasztja az áthajtó járművek gumijait.",
	},

	['steak'] = {
		label = 'Steak sültburgonyával',
		weight = 2,
		stack = true,
		close = true,
		description = "Steak sültburgonyával, 10%-kal csillapítja az éhséget."
	},

	['fishandchips'] = {
		label = 'Fish and Chips',
		weight = 2,
		stack = true,
		close = true,
		description = "Fish and chips, 10%-kal csillapítja az éhséget."
	},

	['fishsoup'] = {
		label = 'Halászlé',
		weight = 2,
		stack = true,
		close = true,
		description = "Bográcsban főtt halászlé, 10%-kal csillapítja az éhséget."
	},

	['bolognaisertesborda'] = {
		label = 'Bolognai Sertesborda',
		weight = 200,
		stack = true,
		close = true,
		description = "Bolognai sertésborda, 10%-kal csillapítja az éhséget."
	},

	['drpepper'] = {
		label = 'Dr. Peppers',
		weight = 2,
		stack = true,
		close = true,
		description = "Fűszeres kóla, 10%-kal oltja a szomjúságot."
	},
	['cappystrawberry'] = {
		label = 'Cappy erdeigyümölcsös',
		weight = 2,
		stack = true,
		close = true,
		description = "Erdei gyümölcsös gyümölcslé, 10%-kal oltja a szomjúságot."
	},

	['orangelimonade'] = {
		label = 'Narancsos Limonádé',
		weight = 2,
		stack = true,
		close = true,
		description = "Narancsos limonádé, 40%-kal oltja a szomjúságot."
	},

	['tatratea'] = {
		label = 'Tátra Tea',
		weight = 2,
		stack = true,
		close = true,
		description = "Tátra tea, erős gyógynövényes likőr, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle."
	},

	['rum'] = {
		label = 'Captain Morgan Rum',
		weight = 2,
		stack = true,
		close = true,
		description = "Karibi rum, 10%-kal oltja a szomjúságot. Extra: 6 percig gyorsabb futás és úszás, +30 páncél. Alkoholos, berúgsz tőle."
	},

	['wine'] = {
		label = 'Villányi Cuvée',
		weight = 2,
		stack = true,
		close = true,
		description = "Villányi vörösbor, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +15 páncél. Alkoholos, berúgsz tőle."
	},

	['sajtburger'] = {
		label = 'Sajtburger',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Sajtburger, 40%-kal csillapítja az éhséget."
	},
	['chicken'] = {
		label = 'My Chicken Burger',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Csirkeburger, 40%-kal csillapítja az éhséget."
	},
	['hamburger'] = {
		label = 'Hamburger',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Hamburger, 40%-kal csillapítja az éhséget."
	},
	['sonkastost'] = {
		label = 'Sonkás Toast',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Sonkás melegszendvics, 40%-kal csillapítja az éhséget."
	},
	['dsajtburger'] = {
		label = 'My Dupla Sajtburger',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Dupla sajtburger, 40%-kal csillapítja az éhséget."
	},
	['bigmac'] = {
		label = 'My Big Mac',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Nagy hamburger, 40%-kal csillapítja az éhséget."
	},
	['smcfarm'] = {
		label = 'Sertés MyFarm',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Sertéshúsos burger, 40%-kal csillapítja az éhséget."
	},
	['mcfish'] = {
		label = 'MyFish',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Halas burger, 40%-kal csillapítja az éhséget."
	},
	['mccrips'] = {
		label = 'MyCripsy',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Ropogós csirkeburger, 40%-kal csillapítja az éhséget."
	},
	['falmaspite'] = {
		label = 'Forró Almás Pite',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Forró almás pite, 40%-kal csillapítja az éhséget."
	},
	['mcflurrymm'] = {
		label = 'MyFlurry',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Fagylaltkehely, 40%-kal csillapítja az éhséget."
	},
	['vshake'] = {
		label = 'Vanílliaízű shake',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Vaníliás turmix, 40%-kal csillapítja az éhséget."
	},
	['csalata'] = {
		label = 'Cézár saláta',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Cézár saláta, 40%-kal csillapítja az éhséget."
	},
	['mcfreezecs'] = {
		label = 'MyFreeze csokoládéizű',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Csokis jégkása, 40%-kal csillapítja az éhséget."
	},
	['jegeskave'] = {
		label = 'Jegeskávé',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Jeges kávé, 40%-kal oltja a szomjúságot."
	},
	['nagyburgonya'] = {
		label = 'Nagy burgonya',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Nagy adag sültkrumpli, 40%-kal csillapítja az éhséget."
	},
	['kisburgonya'] = {
		label = 'Kis burgonya',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Kis adag sültkrumpli, 40%-kal csillapítja az éhséget."
	},
	['cnuggets'] = {
		label = 'Chicken MyNuggets',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Csirkefalatok, 40%-kal csillapítja az éhséget."
	},
	['pompelmo'] = {
		label = 'Pompelmo',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Grapefruit üdítő, 10%-kal oltja a szomjúságot."
	},

	['identity card'] = {
		label = 'személyi igazolvány',
		weight = 1,
		stack = true,
		close = true,
		description = "Személyazonosító igazolvány."
	},

	["carokit"] = {
		label = "Body Kit",
		weight = 3,
		stack = true,
		close = true,
		description = "Body kit a jármű karosszériájának átalakításához.",
	},

	["Halaszle"] = {
		label = "Halászlé",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Bográcsban főtt halászlé.",
	},

	["Tiramisu"] = {
		label = "Tiramisu",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Olasz tiramisu.",
	},

	["Toltottkaposzta"] = {
		label = "Töltöttkáposzta",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Töltött káposzta.",
	},

	["Cappy"] = {
		label = "Cappy",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Dobozos gyümölcslé.",
	},

	["Sprite"] = {
		label = "Prite",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Citromos szénsavas üdítő.",
	},

	["Marhaporkolt"] = {
		label = "Marhapörkölt nokedlivel",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Marhapörkölt nokedlivel.",
	},

	["Tyukhusleves"] = {
		label = "Tyúkhúsleves",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Tyúkhúsleves.",
	},

	["Zserbo"] = {
		label = "Zserbó",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Zserbószelet.",
	},

	["Nightvision"] = {
		label = "ÉjjellátóX-Eye",
		weight = 1,
		stack = true,
		close = true,
		description = "Éjjellátó szemüveg; sötétben is látsz vele.",
	},

	["Rantottszelet"] = {
		label = "Rántott szelet",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Rántott szelet.",
	},

	["Somloigaluska"] = {
		label = "Somlói galuska",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Somlói galuska.",
	},

	["drugItem"] = {
		label = "Fekete USB-C",
		weight = 1,
		stack = true,
		close = true,
		description = "Fekete USB-C eszköz; illegális adatokat tárol.",
	},

	["cookedMeat"] = {
		label = "Főtt hús",
		weight = 1,
		stack = true,
		close = true,
		description = "Tűzön sült hús.",
	},

	["SioCappuchino"] = {
		label = "Sió Cappuchino",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Dobozos cappuccino.",
	},

	["Rantotta"] = {
		label = "Rántotta",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Rántotta.",
	},

	["DewMountainDew"] = {
		label = "Mountain",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Zöld energiaital.",
	},

	["Aranygaluska"] = {
		label = "Aranygaluska",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Aranygaluska.",
	},

	["Palacsinta"] = {
		label = "Palacsinta",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Töltés 20%"
	},

	["Kave"] = {
		label = "Kávé",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Feketekávé.",
	},

	["Paradicsomleves"] = {
		label = "Paradicsomleves",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Paradicsomleves.",
	},

	["hackerDevice"] = {
		label = "Hacker Laptop (Sima)",
		weight = 1,
		stack = true,
		close = true,
		description = "Hacker laptop rendszerek és zárak feltöréséhez.",
	},

	["Kesztyu"] = {
		label = "Kesztyű",
		weight = 0.1,
		stack = true,
		close = true,
		description = "Kesztyű; nyomok hátrahagyása nélkül dolgozhatsz vele.",
	},

	--[[["vibrator"] = {
		label = "Vibrátor",
		weight = 0.1,
		stack = true,
		close = true,
		client = {
			anim = 'dildo',
			prop = 'dildo',
			usetime = 250000,
			cancel = true
		},
	},

	["mufasz"] = {
		label = "Mű fasz",
		weight = 0.1,
		stack = true,
		close = true,
		client = {
			anim = 'dildo',
			prop = 'dildo',
			usetime = 250000,
			cancel = true
		},
	},

	["gezsagolyo"] = {
		label = "Gézsa golyó",
		weight = 0.1,
		stack = true,
		close = true,
		client = {
			anim = 'ball',
			prop = 'ball',
			usetime = 250000,
			cancel = true
		},
	},

	["korbacs"] = {
		label = "Korbács",
		weight = 0.1,
		stack = true,
		close = true,
	},

	["szorosbilincsp"] = {
		label = "Szörös bilics Piros",
		weight = 0.1,
		stack = true,
		close = true,
		client = {
			anim = 'cuff',
			--prop = 'cuff',
			usetime = 250000,
			cancel = true
		},
	},

	["szorosbilincsr"] = {
		label = "Szörös bilics Rozsaszín",
		weight = 0.1,
		stack = true,
		close = true,
		client = {
			anim = 'cuff',
			--prop = 'cuff',
			usetime = 250000,
			cancel = true
		},
	},

	["szorosbilincsl"] = {
		label = "Szörös bilics Lila",
		weight = 0.1,
		stack = true,
		close = true,
		client = {
			anim = 'cuff',
			--prop = 'cuff',
			usetime = 250000,
			cancel = true
		},
	},]]

	['rozsa'] = {
		label = 'Rózsa',
		weight = 220,
		client = {
			anim = 'rose',
			prop = 'rose',
			usetime = 250000,
			cancel = true
		},
		description = "Szál rózsa ajándékozásra.",
	},
	['rozsa1'] = {
		label = 'Rózsa (kézben)',
		weight = 220,
		client = {
			anim = 'rose1',
			prop = 'rose1',
			usetime = 250000,
			cancel = true
		},
		description = "Szál rózsa, kézben tartva.",
	},
	['nyaloka'] = {
		label = 'Nyaloka (kézben)',
		weight = 220,
		client = {
			anim = 'lollipop',
			prop = 'lollipop',
			usetime = 250000,
			cancel = true
		},
		description = "Nyalóka, kézben tartva.",
	},
	['maci'] = {
		label = 'Teddy maci',
		weight = 220,
		client = {
			anim = 'teddy2',
			prop = 'teddy2',
			usetime = 250000,
			cancel = true
		},
		description = "Plüssmaci; ajándéknak való.",
	},
	['maci2'] = {
		label = 'Teddy maci 2',
		weight = 220,
		client = {
			anim = 'teddy',
			prop = 'teddy',
			usetime = 250000,
			cancel = true
		},
		description = "Plüssmaci, másik változatban.",
	},
	['gyuru'] = {
		label = 'Esküvői gyűrű',
		weight = 220,
		client = {
			anim = 'propose',
			prop = 'propose',
			usetime = 250000,
			cancel = true
		},
		description = "Esküvői gyűrű; a nagy pillanathoz.",
	},


	['scuba_set'] = {
		label = 'Búvárfelszerelés',
		weight = 2000,
		description = 'Búvárfelszerelés,víz alatt kell használni',
		stack = false,
		client = {
			export = 'esx_scuba.wear'
		},
	},
	['scuba_fins'] = {
		label = 'Búváruszonyok',
		weight = 200,
		description = 'Búvárfelszerelés, úszássegítés',
		stack = false,
		client = {
			export = 'esx_scuba.wear'
		},
	},
	["scuba"] = {
		label = "Búvárfelszerelés",
		weight = 500,
		stack = true,
		close = true,
		description = "Búvárfelszerelés a víz alatti merüléshez.",
	},

	["hullazsak"] = {
		label = "Hullazsák",
		weight = 250,
		stack = true,
		close = true,
		description = "Hullazsák az elhunyt elszállításához.",
	},

	["basketball"] = {
		label = "Basketball",
		weight = 0,
		stack = true,
		close = true,
		description = "Kosárlabda; a pályán pattogtatható.",
	},

	["basketball_hoop"] = {
		label = "Basketball Hoop",
		weight = 0,
		stack = true,
		close = true,
		description = "Kosárpalánk; lerakva játszani lehet rajta.",
	},

	['tvremote'] = {
		label = 'TV Törlés',
		weight = 5000,
		stack = true,
		close = true,
		description = "Távirányító; leszedi a kihelyezett TV-t."
	},

	['vehicletv'] = {
		label = 'Autó TV',
		weight = 5000,
		stack = true,
		close = true,
		description = "Autós TV; a járműbe szerelhető képernyő."
	},

	['smalltv'] = {
		label = '1998 TV',
		weight = 5000,
		stack = true,
		close = true,
		description = "Régi, 1998-as televízió."
	},

	['mediumtv'] = {
		label = '2010 TV',
		weight = 7500,
		stack = true,
		close = true,
		description = "2010-es évjáratú televízió."
	},

	['bigtv'] = {
		label = '2024 TV',
		weight = 10000,
		stack = true,
		close = true,
		description = "Modern, 2024-es nagyképernyős televízió."
	},

    ['antiblackbox'] = {
        label = 'Traffipax Radar',
        weight = 1000,
        client = {
            event = 'rota_traffipax:startRadarInstall'
        },
        description = "Traffipax radar; méri az elhaladók sebességét.",
    },

	--['headbag'] = {
	--	label = 'Zsák',
	--	description = 'Lehet mások fejére is rá lehet húzni, ki tudja',
	--	weight = 100,
	--	stack = false,
	--	close = true,
	--	server = {
	--		export = 'cad-headbag.useItem'
	--	}
	--},

	['panicbutton'] = {
		label = 'Pánik gomb',
		weight = 100,
		stack = false,
		close = true,
		client = {
			event = 'bc:panikgomb'
		},
		description = "Pánikgomb; vészhelyzetben riasztja az egységeket.",
	},
	
	["bee-hive"] = {
        label = "Méhkaptár",
        weight = 2500,
        stack = true,
        close = true,
        description = "Méhkaptár; a méhészet alapja.",
    },

    ["bee-honey"] = {
        label = "Méz",
        weight = 20,
        stack = true,
        close = true,
        description = "Méz; a kaptárból kinyert termék.",
    },

    ["bee-house"] = {
        label = "Méhkas",
        weight = 200,
        stack = true,
        close = true,
        description = "Méhkas; a méhek otthona.",
    },

    ["bee-queen"] = {
        label = "Méh királynő",
        weight = 20,
        stack = true,
        close = true,
        description = "Méhkirálynő; nélküle nem népesül be a kaptár.",
    },

    ["bee-wax"] = {
        label = "Méh viasz",
        weight = 20,
        stack = true,
        close = true,
        description = "Méhviasz; gyertyához és eladásra.",
    },

    ["bee-worker"] = {
        label = "Méh",
        weight = 20,
        stack = true,
        close = true,
        description = "Dolgozó méh a kaptár népesítéséhez.",
    },
	["bee-smoker"] = {
        label = "Méh füstölő",
        weight = 20,
        stack = true,
        close = true,
        description = "Méhfüstölő; megnyugtatja a méheket munka közben.",
    },
	["thymol"] = {
        label = "Timol",
        weight = 20,
        stack = true,
        close = true,
        description = "Timol; méhészeti kezelőszer a kaptár atkái ellen.",
    },

	['pregtest'] = {
		label = 'Terhességi teszt',
		weight = 5,
		stack = true,
		close = true,
		description = "Terhességi teszt; néhány perc, és kiderül az eredmény."
	},

	['planb'] = {
		label = 'B terv',
		weight = 5,
		stack = true,
		close = true,
		description = "Esemény utáni tabletta."
	},
	
	['condom'] = {
		label = 'Óvszer',
		weight = 10,
		stack = true,
		close = true,
		description = "Óvszer; a biztonság kedvéért."
	},

    ['xtremehorgaszbot'] = {
        label = 'Horgászbot LVL 1',
        weight = 2000,
        stack = false,
        description = "Egyszerű horgászbot a kezdő fogásokhoz.",
    },

    ['fishingrodlvl2'] = {
        label = 'Horgászbot LVL 2',
        weight = 2000,
        stack = false,
        description = "Jobb horgászbot; értékesebb halakat is kifoghatsz vele.",
    },

    ['fishingrodlvl3'] = {
        label = 'Horgászbot LVL 3 (Prémium)',
        weight = 2000,
        stack = false,
        description = "Prémium horgászbot a legjobb fogások esélyével.",
    },

	['craftingtable'] = {
        label = 'Craft asztal',
        weight = 2000,
        stack = false,
        description = "Craft asztal; lerakva tárgyakat készíthetsz rajta.",
    },

	['recipe_pistol'] = {
        label = 'Pisztoly Recept',
        weight = 1,
        stack = true,
        description = "Recept a pisztoly elkészítéséhez.",
    },

	['recipe_micro'] = {
        label = 'MicroSMG Recept',
        weight = 1,
        stack = true,
        description = "Recept a Micro SMG elkészítéséhez.",
    },

	['recipe_rfile'] = {
        label = 'Assault Rifle Recept',
        weight = 1,
        stack = true,
        description = "Recept az Assault Rifle elkészítéséhez.",
    },

	['recipe_tech'] = {
        label = 'Tech Recept',
        weight = 1,
        stack = true,
        description = "Recept a tech eszközök elkészítéséhez.",
    },

	['recipe_appistol'] = {
        label = 'AP Pisztoly Recept',
        weight = 1,
        stack = true,
        description = "Recept az AP pisztoly elkészítéséhez.",
    },

    ['xtremecsali'] = {
        label = 'Horgász Csali',
        weight = 100,
        stack = true,
        description = "Horgászcsali; nélküle nem harap a hal.",
    },

    ['pike'] = {
        label = 'Pike',
        weight = 100,
        stack = false,
        description = "Csuka; ragadozó édesvízi hal.",
    },

    ['roach'] = {
        label = 'Roach',
        weight = 100,
        stack = false,
        description = "Bodorka; apró édesvízi hal.",
    },

    ['silver_carp'] = {
        label = 'Silver Carp',
        weight = 100,
        stack = false,
        description = "Ezüstkárász; gyakori fogás.",
    },

    ['black_carp'] = {
        label = 'Black Carp',
        weight = 100,
        stack = false,
        description = "Fekete amur; ritkább fogás.",
    },

    ['catfish'] = {
        label = 'Catfish',
        weight = 100,
        stack = false,
        description = "Harcsa; nagy testű ragadozó hal.",
    },

    ['grapple'] = {
        label = 'Csörlő fegyver',
        weight = 100,
        stack = false,
        description = "Csörlőfegyver; kötelet lő ki a rögzítéshez.",
    },

    ['pikeperch'] = {
        label = 'pikeperch',
        weight = 100,
        stack = false,
        description = "Süllő; ízletes ragadozó hal.",
    },

    ['nile_tilapia'] = {
        label = 'Catfish',
        weight = 100,
        stack = false,
        description = "Nílusi tilápia; melegvízi hal.",
    },

    ['carp'] = {
        label = 'Carp',
        weight = 100,
        stack = false,
        description = "Ponty; a horgászok kedvence.",
    },

    ['kq_outfitbag'] = {
        label = 'Ruházati táska',
        weight = 100,
        stack = false,
        description = "Ruházati táska a ruhaszettek tárolására.",
    },

    ['rainbow_trout'] = {
        label = 'Rainbow Trout',
        weight = 100,
        stack = false,
        description = "Szivárványos pisztráng; hegyi vizek hala.",
    },

	['clothr'] = {
		label = 'Drága ruhák',
		weight = 300,
		stack = true,
		description = "Drága ruhák; jó áron továbbadhatók.",
	},

    ['perc'] = {
        label = 'Perc',
        weight = 100,
        stack = false,
        description = "Perc; recept nélkül árult erős fájdalomcsillapító.",
    },

	["pet_water"] = {
		label = "Háziállat Víz",
		weight = 1,
		stack = true,
		close = false,
		description = "Víz a háziállatnak.",
	},
	
	["pet_food"] = {
		label = "Háziállat Étel",
		weight = 1,
		stack = true,
		close = false,
		description = "Étel a háziállatnak.",
	},
	
	["pet_medikit"] = {
		label = "Háziállat Gyógyszer",
		weight = 1,
		stack = true,
		close = false,
		description = "Gyógyszer a háziállatnak.",
	},

	["sim"] = {
		label = "SIM Kártya",
		weight = 1,
		stack = true,
		close = false,
		description = "SIM kártya; a telefon működéséhez szükséges.",
	},

	["secure_card"] = {
		label = "Banki id kártya",
		weight = 1,
		stack = true,
		close = false,
		description = "Banki azonosító kártya zárt területek nyitásához.",
	},

	["id_card_f"] = {
		label = "Fertőzött banki id kártya",
		weight = 1,
		stack = true,
		close = false,
		description = "Manipulált banki kártya; a rablásokhoz használják.",
	},

	["pet_leash"] = {
		label = "Háziállat Póráz",
		weight = 1,
		description = "Póráz a háziállat sétáltatásához.",
	},
	
	["pet_food"] = {
		label = "Háziállat Étel",
		weight = 1,
		description = "Étel a háziállatnak.",
	},
	
	["doghouse_1"] = {
		label = "Kutyaház",
		weight = 3,
		description = "Kutyaház; lerakható a kisállatnak.",
	},
	
	["prop_michael_backpack"] = {
		label = "Michael Hátizsákja",
		weight = 2,
		description = "Viselhető hátizsák-kinézet a karakteredre.",
	},
	
	["prop_parapack_01"] = {
		label = "Ejtőernyős Táska",
		weight = 2,
		description = "Viselhető ejtőernyős táska kinézet.",
	},
	
	["p_ld_heist_bag_01"] = {
		label = "Fosztogatós Táska",
		weight = 3,
		description = "Viselhető rablótáska kinézet.",
	},
	
	["xm_prop_x17_bag_med_01a"] = {
		label = "Közepes Méretű Táska",
		weight = 2,
		description = "Viselhető közepes táska kinézet.",
	},
	
	["prop_proxy_hat_01"] = {
		label = "Proxi Kalap",
		weight = 1,
		description = "Viselhető kalap a karakteredre.",
	},
	
	["reh_prop_reh_hat_cowboy_01a"] = {
		label = "Kovboj Kalap",
		weight = 1,
		description = "Viselhető cowboy kalap.",
	},
	
	["prop_hard_hat_01"] = {
		label = "Kemény Kalap",
		weight = 1,
		description = "Viselhető védősisak.",
	},
	
	["sf_prop_sf_helmet_01a"] = {
		label = "SF Sisak",
		weight = 1,
		description = "Viselhető sisak.",
	},
	
	["sf_prop_art_cap_01a"] = {
		label = "Művész Kalap",
		weight = 1,
		description = "Viselhető művész sapka.",
	},
	
	["ba_prop_battle_headphones_dj"] = {
		label = "DJ Fejhallgató",
		weight = 1,
		description = "Viselhető DJ fejhallgató.",
	},
	
	["prop_safety_glasses"] = {
		label = "Biztonsági Szemüveg",
		weight = 1,
		description = "Viselhető védőszemüveg.",
	},
	
	["xm_prop_x17_b_glasses_01"] = {
		label = "X17 Szemüveg",
		weight = 1,
		description = "Viselhető szemüveg.",
	},
	
	["xm3_prop_xm3_glasses_ron_01a"] = {
		label = "Ron Szemüvegei",
		weight = 1,
		description = "Viselhető szemüveg, Ron stílusában.",
	},
	
	["prop_ld_hat_01"] = {
		label = "LD Kalap",
		weight = 1,
		description = "Viselhető kalap.",
	},
	
	["m23_2_prop_m32_hat_captain_01a"] = {
		label = "Kapitány Kalapja",
		weight = 1,
		description = "Viselhető kapitányi sapka.",
	},
	
	["prop_cs_panties_03"] = {
		label = "Bugyi",
		weight = 1,
		description = "Bugyi; vicces gyűjtői darab.",
	},
	
	["v_26_cophelmet2"] = {
		label = "Rendőrségi Sisak",
		weight = 1,
		description = "Viselhető rendőrségi sisak.",
	},
	
	["v_ret_gc_ear01"] = {
		label = "GC Fülhallgató",
		weight = 1,
		description = "Viselhető fülhallgató.",
	},
	
	["xm3_prop_xm3_hat_ron_01a"] = {
		label = "Ron Kalapja",
		weight = 1,
		description = "Viselhető kalap, Ron stílusában.",
	},
	
	["p_jewel_necklace_02"] = {
		label = "Ékszer Nyaklánc",
		weight = 1,
		description = "Viselhető ékszer nyaklánc.",
	},
	
	["p_omega_neck_01_s"] = {
		label = "Omega Nyaklánc",
		weight = 1,
		description = "Viselhető Omega nyaklánc.",
	},
	
	["p_oscar_necklace_s"] = {
		label = "Oscar Nyaklánc",
		weight = 1,
		description = "Viselhető Oscar nyaklánc.",
	},
	
	["prop_player_gasmask"] = {
		label = "Gázálarc",
		weight = 1,
		description = "Viselhető gázálarc.",
	},
	
	["xm3_prop_xm3_helmet_01a"] = {
		label = "Xm3 Sisak",
		weight = 1,
		description = "Viselhető sisak.",
	},
	
	["m23_2_prop_m32_peterscap_01a"] = {
		label = "Péter Kalapja",
		weight = 1,
		description = "Viselhető sapka.",
	},
	
	["prop_ear_defenders_01"] = {
		label = "Fülvédő",
		weight = 1,
		description = "Viselhető fülvédő.",
	},
	
	["xm3_int1_mask_new"] = {
		label = "Új Maszk",
		weight = 1,
		description = "Viselhető maszk az arc elrejtésére.",
	},
	
	["p_single_rose_s"] = {
		label = "Egyetlen Rózsa",
		weight = 1,
		description = "Kézben tartható szál rózsa.",
	},
	
	["ch_prop_drills_hat02x"] = {
		label = "Fúrósisak",
		weight = 1,
		description = "Viselhető fúrósisak.",
	},
	
	["ch_prop_drills_hat01x"] = {
		label = "Fúrósisak",
		weight = 1,
		description = "Viselhető fúrósisak, másik változatban.",
	},
	
	["ch_p_m_bag_var01_arm_s"] = {
		label = "Táska Változat",
		weight = 2,
		description = "Viselhető táska kinézet, első változat.",
	},
	
	["ch_p_m_bag_var03_arm_s"] = {
		label = "Táska Változat",
		weight = 2,
		description = "Viselhető táska kinézet, harmadik változat.",
	},
	
	["ch_p_m_bag_var04_arm_s"] = {
		label = "Táska Változat",
		weight = 2,
		description = "Viselhető táska kinézet, negyedik változat.",
	},
	
	["ch_p_m_bag_var06_arm_s"] = {
		label = "Táska Változat",
		weight = 2,
		description = "Viselhető táska kinézet, hatodik változat.",
	},
	
	["ch_p_m_bag_var07_arm_s"] = {
		label = "Táska Változat",
		weight = 2,
		description = "Viselhető táska kinézet, hetedik változat.",
	},
	
	["ch_p_m_bag_var08_arm_s"] = {
		label = "Táska Változat",
		weight = 2,
		description = "Viselhető táska kinézet, nyolcadik változat.",
	},
	
	["ch_p_m_bag_var09_arm_s"] = {
		label = "Táska Változat",
		weight = 2,
		description = "Viselhető táska kinézet, kilencedik változat.",
	},
	
	["ch_p_m_bag_var10_arm_s"] = {
		label = "Táska Változat",
		weight = 2,
		description = "Viselhető táska kinézet, tizedik változat.",
	},
	
	["prop_stat_pack_01"] = {
		label = "Statisztikai Csomag",
		weight = 2,
		description = "Viselhető hátizsák kinézet.",
	},
	
	["p_stretch_necklace_s"] = {
		label = "Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc.",
	},
	
	["p_omega_neck_02_s"] = {
		label = "Omega Nyaklánc",
		weight = 1,
		description = "Viselhető Omega nyaklánc, másik változatban.",
	},
	
	["sf_prop_sf_necklace_01a"] = {
		label = "SF Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc.",
	},
	
	["p_jewel_necklace01_s"] = {
		label = "Ékszer Nyaklánc",
		weight = 1,
		description = "Viselhető ékszer nyaklánc.",
	},
	
	["tr_prop_tr_dd_necklace_01a"] = {
		label = "DD Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc.",
	},
	
	["p_wade_necklace_s"] = {
		label = "Wade Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc.",
	},
	
	["h4_prop_h4_necklace_01a"] = {
		label = "H4 Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc.",
	},
	
	["ch_p_ch_jimmy_necklace_2_s"] = {
		label = "Jimmy Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc.",
	},
	
	["prop_luggage_04a"] = {
		label = "Bőrönd",
		weight = 3,
		description = "Viselhető bőrönd.",
	},
	
	["prop_cap_01"] = {
		label = "Sapka",
		weight = 1,
		description = "Viselhető sapka.",
	},
	
	["xm3_prop_xm3_backpack_01a"] = {
		label = "Xm3 Hátizsák",
		weight = 2,
		description = "Viselhető hátizsák kinézet.",
	},
	
	["h4_prop_h4_pouch_01a"] = {
		label = "H4 Pénztárca",
		weight = 1,
		description = "Viselhető övtáska.",
	},
	
	["p_cs_tracy_neck2_s"] = {
		label = "Tracy Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc.",
	},
	
	["p_jimmy_necklace_s"] = {
		label = "Jimmy Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc.",
	},
	
	["prop_cs_sol_glasses"] = {
		label = "Sol Szemüveg",
		weight = 1,
		description = "Viselhető napszemüveg.",
	},
	
	["p_cs_beverly_lanyard_s"] = {
		label = "Beverly Névjegykártya Tartója",
		weight = 1,
		description = "Viselhető nyakpántos névjegykártya-tartó.",
	},
	
	["p_lamarneck_01_s"] = {
		label = "Lamar Nyaklánc",
		weight = 1,
		description = "Viselhető nyaklánc, Lamar stílusában.",
	},
	
	["reh_prop_reh_rebreather_01a"] = {
		label = "Lélegzőkészülék",
		weight = 1,
		description = "Viselhető lélegzőkészülék.",
	},
	
	["prop_beach_bag_01b"] = {
		label = "Strand Táska",
		weight = 2,
		description = "Viselhető strandtáska.",
	},
	
	["collar_brown"] = {
		label = "Barna Nyakörv",
		weight = 1,
		description = "Barna nyakörv a kisállatnak.",
	},
	
	["collar_black"] = {
		label = "Fekete Nyakörv",
		weight = 1,
		description = "Fekete nyakörv a kisállatnak.",
	},
	
	["collar_red"] = {
		label = "Piros Nyakörv",
		weight = 1,
		description = "Piros nyakörv a kisállatnak.",
	},
	
	["collar_white"] = {
		label = "Fehér Nyakörv",
		weight = 1,
		description = "Fehér nyakörv a kisállatnak.",
	},
	
	["collar_blue"] = {
		label = "Kék Nyakörv",
		weight = 1,
		description = "Kék nyakörv a kisállatnak.",
	},
	
	["collar_orange"] = {
		label = "Narancssárga Nyakörv",
		weight = 1,
		description = "Narancssárga nyakörv a kisállatnak.",
	},
	
	["collar_pink"] = {
		label = "Rózsaszín Nyakörv",
		weight = 1,
		description = "Rózsaszín nyakörv a kisállatnak.",
	},
	
	["collar_green"] = {
		label = "Zöld Nyakörv",
		weight = 1,
		description = "Zöld nyakörv a kisállatnak.",
	},

	['marksmanriflecso'] = {
		label = 'Marksmanrifle cső',
		weight = 1,
		stack = true,
		close = true,
		description = "MARKSMANRIFLE elkészítéséhez szükséges cső."
	},

	['marksmanrifleravasz'] = {
		label = 'Marksmanrifle ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "MARKSMANRIFLE elkészítéséhez szükséges ravasz."
	},

	['marksmanrifletar'] = {
		label = 'Marksmanrifle tár',
		weight = 1,
		stack = true,
		close = true,
		description = "MARKSMANRIFLE elkészítéséhez szükséges tár."
	},

	['marksmanriflevaltamasz'] = {
		label = 'Marksmanrifle válltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "MARKSMANRIFLE elkészítéséhez szükséges támasz."
	},

	['combatmgcso'] = {
		label = 'Combat cső',
		weight = 1,
		stack = true,
		close = true,
		description = "Combat MG elkészítéséhez szükséges cső."
	},

	['combatmgravasz'] = {
		label = 'Combat ravasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Combat MG elkészítéséhez szükséges ravasz."
	},

	['combatmgtar'] = {
		label = 'Combat tár',
		weight = 1,
		stack = true,
		close = true,
		description = "Combat MG elkészítéséhez szükséges tár."
	},

	['combatmgvaltamasz'] = {
		label = 'Combat válltámasz',
		weight = 1,
		stack = true,
		close = true,
		description = "Combat MG elkészítéséhez szükséges támasz."
	},

	['campfire'] = {
		label = 'Tábortűz',
		weight = 1,
		stack = true,
		close = true,
		description = 'Tábortűz, amin főzni lehet.'
	},
	
	['campingchair'] = {
		label = 'Szék',
		weight = 1,
		stack = true,
		close = true,
		description = 'Kempingszék, amin ülni lehet.'
	},
	
	['campingtent'] = {
		label = 'Sátor',
		weight = 1,
		stack = true,
		close = true,
		description = 'Kempingsátor, amiben tárgyakat tárolhat vagy elbújhat.'
	},
	
	['campingsleepingbag'] = {
		label = 'Hálózsák',
		weight = 1,
		stack = true,
		close = true,
		description = 'Kemping hálózsák, amiben aludni lehet.'
	},
	
	['campingshower'] = {
		label = 'Zuhany',
		weight = 1,
		stack = true,
		close = true,
		description = 'Kemping zuhany, amiben meg lehet tisztálkodni.'
	},
	
	['campingcooler'] = {
		label = 'Hűtőtáska',
		weight = 1,
		stack = true,
		close = true,
		description = 'Kemping hűtőtáska, amiben hidegen tarthatja az italokat.'
	},
	
	['campingbeerbarrel'] = {
		label = 'Söröshordó',
		weight = 1,
		stack = true,
		close = true,
		description = 'Kemping söröshordó, amiből megtöltheti a poharát.'
	},
	
	-- Opcionális tárgyak (Ha nem használja őket, állítsa be a config.lua fájlban)
	
	['rawmeat'] = {
		label = 'Nyers Hús',
		weight = 1,
		stack = true,
		close = true,
		description = 'Nyers hús, amit a tábortűznél meg lehet főzni.'
	},
	
	['cookedmeat'] = {
		label = 'Sült Hús',
		weight = 1,
		stack = true,
		close = true,
		description = 'Sült hús.'
	},
	
	['smores'] = {
		label = 'Smores',
		weight = 1,
		stack = true,
		close = true,
		description = 'Smores.'
	},
	
	['cookedsmores'] = {
		label = 'Sült Smores',
		weight = 1,
		stack = true,
		close = true,
		description = 'Sült smores.'
	},
	
	['emptybeercup'] = {
		label = 'Üres Pohár',
		weight = 1,
		stack = true,
		close = true,
		description = 'Üres söröspohár.'
	},
	
	['fullbeercup'] = {
		label = 'Teli Pohár',
		weight = 1,
		stack = true,
		close = true,
		description = 'Teli söröspohár.'
	},
	
	['matches'] = {
		label = 'Gyufa',
		weight = 1,
		stack = true,
		close = true,
		description = 'Gyufa a tábortűz meggyújtásához.'
	},
	
	['liquid'] = {
		label = 'Liquid',
		weight = 0.1,
		stack = true,
		close = true,
		description = "A Poco töltéséhez szükséges: fogd meg, töltsd bele, és élvezd a füstölést!"
	},

	['vape'] = {
		label = 'Poco (Orcys)',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Az Orczy piacon vásárolt, Magyarországi illegális áru."
	},

	['lighter'] = {
		label = 'Öngyújtó',
		weight = 1,
		stack = true,
		close = true,
		description = 'Öngyújtó a tábortűz meggyújtásához.'
	},
	
	['metal'] = {
		label = 'Fém',
		weight = 1,
		stack = true,
		close = true,
		description = "Fém alapanyag gyártáshoz és javításhoz."
	},
	
	['rope'] = {
		label = 'Kötél',
		weight = 1,
		stack = true,
		close = true,
		description = "Kötél megkötözéshez és rögzítéshez."
	},

	['sharkrepelent'] = {
		label = 'Cápavédő',
		weight = 1,
		stack = true,
		close = true,
		description = "Cápariasztó; merülés közben távol tartja a ragadozókat."
	},

	['finger_scanner'] = {
		label = 'Ujjszkenner',
		weight = 0,
		stack = true,
		close = true,
		description = "Ujjlenyomat-olvasó; azonosítja a személyt."
	},

	['teddy'] = {
		label = 'Mackó',
		weight = 969,
		consume = 0,
		description = "Egy mackó a szerelmednek!",
		client = {
			anim = { dict = 'impexp_int-0', clip = 'mp_m_waremech_01_dual-0', flag = 50 },
			prop = { model = 'v_ilev_mr_rasberryclean',
			pos = vec3(-0.20, 0.46, -0.016), rot = vec3(-180.0, -90.0, 0.0), bone = 24817 },
			disable = { move = false, car = false, combat = false },
			usetime = 10000,
		}
	}, 

	['rose'] = {
		label = 'Rózsa',
		weight = 969,
		consume = 0,
		description = "Egy szál rózsa a szerelmednek!",
		client = {
			anim = { dict = 'anim@heists@humane_labs@finale@keycards', clip = 'ped_a_enter_loop', flag = 50 },
			prop = { model = 'prop_single_rose',
			pos = vec3(0.13, 0.15, 0.0), rot = vec3(-100.0, 0.0, -20.0), bone = 18905 },
			disable = { move = false, car = false, combat = false },
			usetime = 10000,
		}
	}, 

	['roses'] = {
		label = 'Csokor Rózsa',
		weight = 969,
		consume = 0,
		description = "Egy csokor rózsa a szerelmednek!",
		client = {
			anim = { dict = 'impexp_int-0', clip = 'mp_m_waremech_01_dual-0', flag = 50 },
			prop = { model = 'prop_snow_flower_02',
			pos = vec3(-0.29, 0.40, -0.02), rot = vec3(-90.0, -90.0, 0.0), bone = 24817 },
			disable = { move = false, car = false, combat = false },
			usetime = 10000,
		}
	},

	['bonbons'] = {
		label = 'Cherry Queen',
		description = "Egy kis bonbon a szerelmednek!",
		weight = 400,
		stack = true,
		close = true,
		client = {
			status = { drunk = 150000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'prop_beer_patriot', 
			pos = vec3(0.01, -0.02, -0.15), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 7500,
		},
	},

	['cat_purple'] = {
		label = 'Lila Macska Figura',
		weight = 150,
		stack = true,
		description = "Lila macska figura; gyűjthető darab.",
	},

	['cat_yellow'] = {
		label = 'Yellow Macska Figura',
		weight = 150,
		stack = true,
		description = "Sárga macska figura; gyűjthető darab.",
	},

	['cat_brown'] = {
		label = 'Brown Macska Figura',
		weight = 150,
		stack = true,
		description = "Barna macska figura; gyűjthető darab.",
	},

	['cat_blue'] = {
		label = 'Blue Macska Figura',
		weight = 150,
		stack = true,
		description = "Kék macska figura; gyűjthető darab.",
	},

	['cat_red'] = {
		label = 'Red Macska Figura',
		weight = 150,
		stack = true,
		description = "Piros macska figura; gyűjthető darab.",
	},

	['cat_green'] = {
		label = 'Green Macska Figura',
		weight = 150,
		stack = true,
		description = "Zöld macska figura; gyűjthető darab.",
	},

	['princess_robo'] = {
		label = 'Hercegnő Robo Figura',
		weight = 150,
		stack = true,
		description = "Hercegnő Robo figura; gyűjthető darab.",
	},

	['shiny_wasabi'] = {
		label = 'Ragyogó Wasabi Figura',
		weight = 150,
		stack = true,
		description = "Ragyogó Wasabi figura; ritka gyűjthető darab.",
	},

	['uwu_mysterybox'] = {
		label = 'Figura Mystery Box',
		weight = 10,
		stack = true,
		close = true,
		description = "Figura mystery box; véletlenszerű gyűjthető figurát rejt.",
	},

	['roadpods'] = {
		label = 'RoadPods',
		weight = 150,
		stack = true,
		consume = 0,
		description = "Vezeték nélküli fülhallgató a telefonhoz.",
	},


	['vehicle_manual'] = {
		label = 'Jármű kézikönyv',
		weight = 50,
		close = true,
		consume = 0,
		client = {},
		server = {
			--export = 'rcore_fuel.vehicle_manual',
		},
		description = "Jármű kézikönyv; a kocsihoz tartozó papírok.",
	},
	
	['window_cleaner'] = {
		label = 'Ablaktisztító',
		weight = 50,
		close = true,
		consume = 0,
		client = {},
		server = {
			--export = 'rcore_fuel.window_cleaner',
		},
		description = "Ablaktisztító a szélvédő letisztításához.",
	},
	
	['fuel_pump'] = {
		label = 'Üzemanyag pumpa',
		weight = 10000,
		close = true,
		consume = 0,
		client = {},
		server = {
			--export = 'rcore_fuel.fuel_pump',
		},
		description = "Üzemanyagpumpa a tankoláshoz.",
	},

	['driftsmoke'] = {
		label = 'Gumi füst',
		weight = 100,
		close = true,
		consume = 0,
		client = {
			event = "driftsmoke:onoff"
		},
		description = "Gumifüst; a driftelés látványához.",
	},

	['receipt'] = {
        label = 'Számla',
        weight = 20, 
        stack = true,
        close = true,
        description = "Számla; az elvégzett munka bizonylata.",
        buttons = {
            {
                label = 'Számla mutatása!',
                action = function(slot)
                    TriggerEvent('envi-receipts:showReceiptToClosestPlayer', slot)
                end
            }
        }
    },

    ['payment_terminal'] = {
        label = 'Fizetési terminál',
        weight = 500, 
        stack = false,
        close = true,
        description = 'Terminál a számla nyomtatásához!',
        buttons = {
            {
                label = 'Számla mutatása!',
                action = function()
                    TriggerEvent('envi-receipts:quickPrint')
                end
            }
        }
    },

	--[[["headbag"] = {
		label = "Zsák",
		weight = 10,
		stack = true,
		close = true,
	},]]

	["weapon_pistol_recipe"] = {
		label = "Pisztoly recept",
		weight = 1,
		stack = false,
		close = true,
		description = "Recept a pisztoly elkészítéséhez.",
	},
--## Új casino
	["casino_beer"] = {
		label = "Kaszinó Sör",
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinóban csapolt sör.",
	},

	["casino_burger"] = {
		label = "Kaszinó Burger",
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinóban kapható burger.",
	},

	["casino_chips"] = {
		label = "Kaszinó zsetonok",
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinó zseton a játékasztalokhoz.",
	},

	["casino_coffee"] = {
		label = "Kaszinó Kávé",
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinóban felszolgált kávé.",
	},

	["casino_coke"] = {
		label = "Kaszinó Cola",
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinóban kapható kóla.",
	},

	["casino_donut"] = {
		label = "Kaszinó Donut",
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinóban kapható fánk.",
	},

	["casino_ego_chaser"] = {
		label = "Casino Ego Chaser",
		weight = 0,
		stack = true,
		close = true,
		description = "Ego Chaser koktél a kaszinó bárjából.",
	},

	["casino_luckypotion"] = {
		label = "Casino Lucky Potion",
		weight = 0,
		stack = true,
		close = true,
		description = "Lucky Potion koktél a kaszinó bárjából.",
	},

	["casino_psqs"] = {
		label = "Casino Ps & Qs",
		weight = 0,
		stack = true,
		close = true,
		description = "Ps & Qs koktél a kaszinó bárjából.",
	},

	["casino_sandwitch"] = {
		label = "Casino Sandwitch",
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinóban kapható szendvics.",
	},

	["casino_sprite"] = {
		label = "Casino Sprite",
		weight = 0,
		stack = true,
		close = true,
		description = "Kaszinóban kapható citromos üdítő.",
	},

	["handmap"] = {
		label = "Map",
		weight = 1,
		stack = true,
		close = true,
		client = {
			event = "map:onoff"
		},
		description = "Kézi térkép a környék áttekintéséhez.",
	},

	["cukorka"] = {
		label = "Cukorka",
		weight = 0.01,
		stack = true,
		close = true,
		description = "Cukorka; édes nassolnivaló.",
	},

	["tok"] = {
		label = "Tök",
		weight = 0,
		stack = true,
		close = true,
		description = "Tök; halloweeni dekoráció.",
	},

-- ##újboltrágyak##
	['wing_gb_green'] = {
		label = 'Szárny GB Zöld',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Zöld szárnyak; viselhető hátdísz.",
	},
	['wing_gb_pink'] = {
		label = 'Szárny GB Rózsaszín',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Rózsaszín szárnyak; viselhető hátdísz.",
	},
	['wing_gb_blue'] = {
		label = 'Szárny GB Kék',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Kék szárnyak; viselhető hátdísz.",
	},
	['fashion_angelwing19'] = {
		label = 'Angyalszárny 19',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Angyalszárny; viselhető hátdísz.",
	},
	['dragon'] = {
		label = 'Sárkány',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Sárkány; viselhető hátdísz.",
	},
	['Digger'] = {
		label = 'Fúró',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Fúró figura; viselhető dísz.",
	},
	['Seal'] = {
		label = 'Fóka',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Fóka figura; viselhető dísz.",
	},
	['fashion_chii'] = {
		label = 'Chii',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Chii; viselhető divatkiegészítő.",
	},
	['fashion_birdcooper'] = {
		label = 'Madár Cooper',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Madár Cooper; viselhető divatkiegészítő.",
	},
	['fashion_wingsrender'] = {
		label = 'Renderelt Szárnyak',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Renderelt szárnyak; viselhető hátdísz.",
	},
	['fashion_hellwing'] = {
		label = 'Pokoli Szárny',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Pokoli szárnyak; viselhető hátdísz.",
	},
	['fashion_anglewing'] = {
		label = 'Szögletes Szárny',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Szögletes szárnyak; viselhető hátdísz.",
	},
	['fashion_heartpink'] = {
		label = 'Rózsaszín Szív',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Rózsaszín szív; viselhető divatkiegészítő.",
	},
	['fashion_demonwing'] = {
		label = 'Démon Szárny',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Démonszárnyak; viselhető hátdísz.",
	},
	['fashion_angelwing3'] = {
		label = 'Angyalszárny 3',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Angyalszárny, harmadik változat; viselhető hátdísz.",
	},
	['fashion_angelwing2'] = {
		label = 'Angyalszárny 2',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Angyalszárny, második változat; viselhető hátdísz.",
	},
	['fashion_pcube2222'] = {
		label = 'PC Fejhallgató Sárga',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Sárga PC fejhallgató; viselhető divatkiegészítő.",
	},
	['fashion_pcube222'] = {
		label = 'PC Fejhallgató Zöld',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Zöld PC fejhallgató; viselhető divatkiegészítő.",
	},
	['fashion_pcube22'] = {
		label = 'PC Fejhallgató Rózsaszín',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Rózsaszín PC fejhallgató; viselhető divatkiegészítő.",
	},
	['fashion_pcube2'] = {
		label = 'PC Fejhallgató Kék',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Kék PC fejhallgató; viselhető divatkiegészítő.",
	},
	['fashion_angelwing'] = {
		label = 'Angyalszárny',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Angyalszárny; viselhető hátdísz.",
	},
	['fashion_bearhat'] = {
		label = 'Maci Sapka',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Maci sapka; viselhető divatkiegészítő.",
	},
	['fashion_arcadeahri'] = {
		label = 'Arcade Ahri',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Arcade Ahri; viselhető divatkiegészítő.",
	},
	['fashion_sunglasses'] = {
		label = 'Napszemüveg',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Napszemüveg; viselhető divatkiegészítő.",
	},
	['fashion_angelring'] = {
		label = 'Angyalkorona',
		weight = 0.1,
		stack = true,
		close = false,
		description = "Angyalkorona; viselhető fejdísz.",
	},
--###újhorgászscript
	["bass"] = {
		label = "Sügér",
		weight = 100,
		stack = true,
		close = true,
		description = "Sügér; gyakori édesvízi hal.",
		client = {
			image = "bass.png",
		}
	},
	["carp"] = {
		label = "Ponty",
		weight = 100,
		stack = true,
		close = true,
		description = "Ponty; a horgászok kedvence.",
		client = {
			image = "carp.png",
		}
	},
	["crab"] = {
		label = "Rák",
		weight = 100,
		stack = true,
		close = true,
		description = "Rák; a rákászat zsákmánya.",
		client = {
			image = "crab.png",
		}
	},
	["lobster"] = {
		label = "Homár",
		weight = 100,
		stack = true,
		close = true,
		description = "Homár; értékes tengeri fogás.",
		client = {
			image = "lobster.png",
		}
	},
	["mullet"] = {
		label = "Márna",
		weight = 100,
		stack = true,
		close = true,
		description = "Márna; tengeri hal.",
		client = {
			image = "mullet.png",
		}
	},
	["perch"] = {
		label = "Süllő",
		weight = 100,
		stack = true,
		close = true,
		description = "Süllő; ízletes ragadozó hal.",
		client = {
			image = "perch.png",
		}
	},
	["turtle"] = {
		label = "Teknős",
		weight = 100,
		stack = true,
		close = true,
		description = "Teknős; ritka vízi fogás.",
		client = {
			image = "turtle.png",
		}
	},
	["octopus"] = {
		label = "Polip",
		weight = 100,
		stack = true,
		close = true,
		description = "Polip; a mélyebb vizek fogása.",
		client = {
			image = "octopus.png",
		}
	},
	["rod_1"] = {
		label = "Bot 1. szint",
		weight = 100,
		stack = true,
		close = true,
		description = "Horgászbot, 1. szint; a kezdő fogásokhoz.",
		client = {
			image = "rod_1.png",
		}
	},
	["rod_2"] = {
		label = "Bot 2. szint",
		weight = 100,
		stack = true,
		close = true,
		description = "Horgászbot, 2. szint; jobb kapási eséllyel.",
		client = {
			image = "rod_2.png",
		}
	},
	["rod_3"] = {
		label = "Bot 3. szint",
		weight = 100,
		stack = true,
		close = true,
		description = "Horgászbot, 3. szint; értékesebb halakhoz.",
		client = {
			image = "rod_3.png",
		}
	},
	["rod_4"] = {
		label = "Bot 4. szint",
		weight = 100,
		stack = true,
		close = true,
		description = "Horgászbot, 4. szint; a legjobb fogásokhoz.",
		client = {
			image = "rod_4.png",
		}
	},
	["worm"] = {
		label = "Giliszta",
		weight = 1,
		stack = true,
		close = true,
		description = "Giliszta; a legegyszerűbb horgászcsali.",
		client = {
			image = "worm.png",
		}
	},
	["shrimp_lure"] = {
		label = "Garnélacsali",
		weight = 100,
		stack = true,
		close = true,
		description = "Garnélacsali; a nagyobb halakat vonzza.",
		client = {
			image = "shrimp_lure.png",
		}
	},
	["illegalbait"] = {
		label = "Illegális csali",
		weight = 100,
		stack = true,
		close = true,
		description = "Illegális csali; tiltott, de nagyon fogós.",
		client = {
			image = "illegalbait.png",
		}
	},
	["tackle_box"] = {
		label = "Horgászdoboz",
		weight = 100,
		stack = true,
		close = true,
		description = "Horgászdoboz a felszerelés tárolására.",
		client = {
			image = "tackle_box.png",
		}
	},
--##Karácsony
    ['xmas_gift'] = {
        label = 'Kicsomagolt Ajándék',
        weight = 100,
        stack = false,
        close = true,
        consume = 0,
        server = {
            export = 'rcore_xmas.xmas_gift'
        },
        description = "Kicsomagolt ajándék a karácsonyi meglepetésből.",
    },

    ['xmas_packed_gift'] = {
        label = 'Becsomagolt Ajándék',
        weight = 250,
        stack = false,
        close = true,
        consume = 0,
        server = {
            export = 'rcore_xmas.xmas_packed_gift',
        },
        description = "Becsomagolt ajándék; bontásra vár.",
    },

    ['xmas_tree'] = {
        label = 'Karácsonyfa',
        weight = 350,
        stack = true,
        close = true,
        consume = 0,
        server = {
            export = 'rcore_xmas.xmas_tree'
        },
        description = "Karácsonyfa; ünnepi dekoráció.",
    },

    ['xmas_star'] = {
        label = 'Karácsonyi Csillag',
        weight = 50,
        stack = true,
        close = true,
        consume = 0,
        export = 'rcore_xmas.xmas_star',
        description = "Karácsonyi csillag; a fa csúcsdísze.",
    },

    ['xmas_decor'] = {
        label = 'Karácsonyi Dekoráció',
        weight = 50,
        stack = true,
        close = true,
        consume = 0,
        export = 'rcore_xmas.xmas_decor',
        description = "Karácsonyi dekoráció.",
    },


	['szanko'] = {
        label = 'Szánkó',
        weight = 100,
        stack = true,
        close = true,
        description = "Szánkó; télen csúszkálásra.",
    },

	['petpalack'] = {
		label = 'Visszaváltós palack',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Visszaváltós palack; az automatánál pénzre váltható."
	},

	['holanc'] = {
		label = 'Hó lánc',
		weight = 50,
		stack = true,
		close = true,
		description = "Autóban ülva használd",
		client = {
			event = "holanc:onoff"
		}
	},

	['gorkorcsolya'] = {
		label = 'Görkorcsolya',
		weight = 50,
		stack = true,
		close = true,
		description = "Csak Karácsonykor!",
		client = {
			event = "pata_roller:roller"
		}
	},
	['korcsolya'] = {
		label = 'Korcsolya',
		weight = 50,
		stack = true,
		close = true,
		description = "Csak Karácsonykor!",
		client = {
			event = "pata_roller:iceroller"
		}
	},

	['bodycam'] = {
		label = 'Test Kamera',
		weight = 20,
		stack = false,
		close = true,
		description = 'Bodycam rögzítéshez',
	},
	
	['dashcam'] = {
		label = 'Autós Kamera',
		weight = 20,
		stack = false,
		close = true,
		description = 'Műszerkamera streameléshez',
	},

	['homar'] = {
		label = 'Homár',
		weight = 20,
		stack = true,
		close = true,
		description = "Párolt homár, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél.",
	},

	['sushi'] = {
		label = 'Sushi',
		weight = 20,
		stack = true,
		close = true,
		description = "Sushi tál, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél.",
	},

	['kaviar'] = {
		label = 'Kaviár',
		weight = 20,
		stack = true,
		close = true,
		description = "Fekete kaviár, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél.",
	},

	['kiralyrak'] = {
		label = 'Királyrák',
		weight = 20,
		stack = true,
		close = true,
		description = "Királyrák, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél.",
	},

	['osztriga'] = {
		label = 'Osztriga',
		weight = 20,
		stack = true,
		close = true,
		description = "Friss osztriga, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél.",
	},

	['rantotthus'] = {
		label = 'Rántott hús hasábburgonyával',
		weight = 20,
		stack = true,
		close = true,
		description = "Rántott hús hasábburgonyával, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél.",
	},

	['kokuszviz'] = {
		label = 'Kókusz víz',
		weight = 20,
		stack = true,
		close = true,
		description = "Kókuszvíz, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél.",
	},

	['kinleytonic'] = {
		label = 'Tonic (kinley)',
		weight = 20,
		stack = true,
		close = true,
		description = "Tonic, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél.",
	},

	['vodkaredbull'] = {
		label = 'Vodka redbull',
		weight = 20,
		stack = true,
		close = true,
		description = "Vodka energiaitallal, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle.",
	},

	['jamesonwhiskey'] = {
		label = 'Whiskey (Jameson)',
		weight = 20,
		stack = true,
		close = true,
		description = "Ír whiskey, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle.",
	},

	['bacardirum'] = {
		label = 'Rum (bacardi)',
		weight = 20,
		stack = true,
		close = true,
		description = "Fehér rum, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle.",
	},

	['pilsnersor'] = {
		label = 'Sör (Pilsner)',
		weight = 20,
		stack = true,
		close = true,
		description = "Csapolt sör, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél. Alkoholos, berúgsz tőle.",
	},

--##újfegyveregyedimate

	['hfapteljestest'] = {
		label = 'HFAP TeljesTest',
		weight = 0.3,
		stack = true,
		close = true,
		description = "HFAP elkészítéséhez szükséges teljes váz."
	},

	['hfaptar'] = {
		label = 'HFAP Tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "HFAP elkészítéséhez szükséges tár."
	},

	['hfapvazalap'] = {
		label = 'HFAP Váz alap',
		weight = 0.3,
		stack = true,
		close = true,
		description = "HFAP elkészítéséhez szükséges váz."
	},

	['hfapvaz'] = {
		label = 'HFAP Váz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "HFAP elkészítéséhez szükséges váz."
	},
--##újmunkafunyiras
	['lawnmower'] = {
		label = 'Fűnyíró',
		weight = 1,
		stack = false,
		close = true,
		description = "Fűnyíró a kert rendben tartásához."
	},
	
	['leafblower'] = {
		label = 'Lombfújó',
		weight = 1,
		stack = false,
		close = true,
		description = "Lombfújó a lehullott levelek összefújásához."
	},
	
	['garden_pitcher'] = {
		label = 'Locsoló Kanna',
		weight = 1,
		stack = false,
		close = true,
		description = "Locsolókanna a növények öntözéséhez."
	},
--##Lotto
	['lottery_keno'] = {
		label = 'Keno Jegy',
		weight = 1,
		stack = true,
		description = "Keno lottószelvény a számsorsolásra."
	},

	['lottery_moneyball'] = {
		label = 'Moneyball Jegy',
		weight = 1,
		stack = true,
		description = "Moneyball lottószelvény."
	},

	['lottery_pickle'] = {
		label = 'Pickle Kaparós',
		weight = 1,
		stack = false,
		description = "Pickle kaparós sorsjegy."
	},

	['lottery_wildcherry'] = {
		label = 'Wild Cherry Kaparós',
		weight = 1,
		stack = false,
		description = "Wild Cherry kaparós sorsjegy."
	},

	['lottery_luckyseven'] = {
		label = 'Lucky 7\'s Kaparós',
		weight = 1,
		stack = false,
		description = "Lucky 7 kaparós sorsjegy."
	},

	['lottery_receipt'] = {
		label = 'Lottózó Blokk',
		weight = 1,
		stack = false,
		description = "Lottózói blokk; a megjátszott szelvény bizonylata."
	},

	["feher_szollo"] = {
        label = "Fehér Szöllő",
        weight = 1,
        stack = true,
        close = false,
        description = "Fehér szőlő; a borkészítés alapanyaga.",
    },

	["voros_szollo"] = {
        label = "Vörös Szöllő",
        weight = 1,
        stack = true,
        close = false,
        description = "Vörös szőlő; a borkészítés alapanyaga.",
    },

	["romlott_szollo"] = {
        label = "Romlott Szöllő",
        weight = 1,
        stack = true,
        close = false,
        description = "Romlott szőlő; borkészítésre már alkalmatlan.",
    },

	['havycso'] = {
		label = 'Heavy Cso',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Heavy Sniper MK2 elkészítéséhez szükséges cső."
	},

	['havytar'] = {
		label = 'Heavy Tár',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Heavy Sniper MK2 elkészítéséhez szükséges tár."
	},

	['havyravasz'] = {
		label = 'Heavy Ravasz',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Heavy Sniper MK2 elkészítéséhez szükséges ravasz."
	},

	['fank'] = {
		label = 'Fánk',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Cukros fánk, 10%-kal csillapítja az éhséget."
	},

	['churros'] = {
		label = 'Churros',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Churros fahéjas cukorral, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['bubbletea'] = {
		label = 'Bubble Tea',
		weight = 0.3,
		stack = true,
		close = true,
		description = "Bubble tea, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},
	--##TV uj rc
	['remote'] = {
    	label = 'Távirányító',
    	weight = 1,
    	stack = true,
    	close = false,
    	description = 'Egy távirányító, amelyet különféle eszközökhöz használhatsz.'
	},
	--##újfarmrendszer
	["wateringcan"] = {
		label = "Locsolókanna",
		weight = 100,
		stack = true,
		close = true,
		description = "Egy kanna, amivel meg tudod locsolni a növényeket.",
	},
	["raker"] = {
		label = "Gereblye",
		weight = 100,
		stack = true,
		close = true,
		description = "Egy szerszám, amely a talaj egyengetésére és tisztítására használható.",
	},
	["shovel"] = {
		label = "Ásó",
		weight = 100,
		stack = true,
		close = true,
		description = "Egy alapvető szerszám, amely a föld ásására szolgál.",
	},
	["melonseed"] = {
		label = "Dinnye Mag",
		weight = 100,
		stack = true,
		close = true,
		description = "Dinnye termesztéséhez szükséges mag.",
	},
	["pumpkinseed"] = {
		label = "Tök Mag",
		weight = 100,
		stack = true,
		close = true,
		description = "Tök termesztéséhez szükséges mag.",
	},
	["wheatseed"] = {
		label = "Búza Mag",
		weight = 100,
		stack = true,
		close = true,
		description = "Búza termesztéséhez szükséges mag.",
	},
	["churn"] = {
		label = "Vajköpülő",
		weight = 100,
		stack = true,
		close = true,
		description = "Egy eszköz, amely vaj készítésére szolgál a tejből.",
	},
	["milkbottle"] = {
		label = "Tejesüveg",
		weight = 100,
		stack = true,
		close = true,
		description = "Egy üveg frissen fejt tej tárolására.",
	},
	["melon"] = {
		label = "Szeletelt Dinnye",
		weight = 100,
		stack = true,
		close = true,
		description = "Frissen szeletelt, érett dinnye darabok.",
	},
	["pumpkin"] = {
		label = "Szeletelt Tök",
		weight = 100,
		stack = true,
		close = true,
		description = "Frissen szeletelt tök darabok.",
	},
	["wheat"] = {
		label = "Búza",
		weight = 2,
		stack = true,
		close = true,
		description = "Frissen betakarított búza, amely feldolgozásra vár.",
	},
	["rosszbuza"] = {
		label = "Rossz Búza",
		weight = 2,
		stack = true,
		close = true,
		description = "Használhatatlan, megpenészedett búza. Semmilyen formában nem dolgozható fel, csak kidobásra alkalmas.",
	},
	
--######	
	["squid"] = {
		label = "Squid kártya",
		weight = 1,
		stack = true,
		close = true,
		description = "Squid kártya; belépő a játékba.",
	},
	["dalgona_circle"] = {
		label = "Dalgona Kör",
		weight = 1,
		stack = true,
		close = true,
		description = "Dalgona cukorka kör alakú mintával; ki kell törni a formát.",
	},
	["dalgona_square"] = {
		label = "Dalgona Négyzet",
		weight = 1,
		stack = true,
		close = true,
		description = "Dalgona cukorka négyzet mintával; ki kell törni a formát.",
	},
	["dalgona_star"] = {
		label = "Dalgona Csillag",
		weight = 1,
		stack = true,
		close = true,
		description = "Dalgona cukorka csillag mintával; ki kell törni a formát.",
	},
	["dalgona_triangle"] = {
		label = "Dalgona Háromszög",
		weight = 1,
		stack = true,
		close = true,
		description = "Dalgona cukorka háromszög mintával; ki kell törni a formát.",
	},
	["dalgona_umbrella"] = {
		label = "Dalgona Esernyő",
		weight = 1,
		stack = true,
		close = true,
		description = "Dalgona cukorka esernyő mintával; ki kell törni a formát.",
	},	

	["aranycsakany"] = {
		label = "Arany csákány",
		weight = 1000,
		stack = true,
		close = true,
		description = "Arany csákány; ritka bányászszerszám.",
	},	
	["narany"] = {
		label = "Nemzet Aranya",
		weight = 1000,
		stack = true,
		close = true,
		description = "A nemzet aranya; a legnagyobb fogások egyike.",
	},	
--### Dron és Alkatrészek.
	['drone1'] = {
        label = 'Drone 1',
        weight = 220,
        server = {
            export = 'smartdrone.OxUseSmartDrone',
        },
        description = "Drón; a magasból figyelheted vele a terepet.",
	},

	['drone2'] = {
        label = 'Drone 2',
        weight = 220,
        server = {
            export = 'smartdrone.OxUseSmartDrone',
        },
        description = "Drón, másik változatban.",
	},

	['dronalkatresz'] = {
		label = 'Dron Keret',
		weight = 1,
		stack = true,
		close = true,
		description = "Drón keret; az összeszereléshez kell."
	},

	['dronalkatresz1'] = {
		label = 'Dron Talp',
		weight = 1,
		stack = true,
		close = true,
		description = "Drón talp; az összeszereléshez kell."
	},

	['dronalkatresz2'] = {
		label = 'Dron Motor',
		weight = 1,
		stack = true,
		close = true,
		description = "Drón motor; az összeszereléshez kell."
	},

	['dronalkatresz3'] = {
		label = 'Dron Kamera',
		weight = 1,
		stack = true,
		close = true,
		description = "Drón kamera; az összeszereléshez kell."
	},

	['drone'] = {
		label = 'Drón',
		weight = 10,
		stack = false,   -- minden drón saját sorozatszámmal / metaadattal rendelkezik
		close = true,
		client = {
			event = 'nzkfc_drone:useItem',
		},
		description = "Drón; felszállva a magasból figyelheted a terepet.",
	},

	['drone_battery'] = {
		label = 'Drón Akkumulátor',
		weight = 3,
		stack = false,   -- minden akkumulátor külön töltöttséget tárol metaadatban
		close = true,
		description = "Drón akkumulátor; feltöltve indítja a drónt.",
	},

	['drone_battery_empty'] = {
		label = 'Drón Akkumulátor (Lemerült)',
		weight = 3,
		stack = true,
		close = true,
		description = "Lemerült drón akkumulátor; töltésre szorul.",
	},

	['itbonbon'] = {
		label = 'Italiano BonBon',
		weight = 1,
		stack = true,
		close = true,
		description = "Olasz bonbon, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},
	['itenergydrink'] = {
		label = 'Italiano Energiaital',
		weight = 1,
		stack = true,
		close = true,
		description = "Energiaital, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},
	['itkokuszgolyo'] = {
		label = 'Italiano Kókuszgolyó',
		weight = 1,
		stack = true,
		close = true,
		description = "Kókuszgolyó, 10%-kal csillapítja az éhséget. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},
	['itbananashake'] = {
		label = 'Italiano Shake (Banános)',
		weight = 1,
		stack = true,
		close = true,
		description = "Banános turmix, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},
----####xÚj horgászat
	['basic_rod'] = {
		label = 'Horgászbot (Lv1)',
		stack = false,
		weight = 250,
		description = "Horgászbot (Lv1) a kezdő fogásokhoz.",
	},

	['graphite_rod'] = {
		label = 'Grafit horgászbot (Lv30)',
		stack = false,
		weight = 350,
		description = "Grafit horgászbot; 30-as szinttől használható.",
	},

	['titanium_rod'] = {
		label = 'Titán horgászbot (Lv60)',
		stack = false,
		weight = 450,
		description = "Titán horgászbot; 60-as szinttől használható.",
	},

	['worms'] = {
		label = 'Féreg',
		weight = 10,
		stack = true,
		description = "Féreg; a legegyszerűbb horgászcsali.",
	},

	['artificial_bait'] = {
		label = 'Mesterséges csali',
		weight = 30,
		stack = true,
		description = "Mesterséges csali; tartósabb a féregnél.",
	},

	['anchovy'] = {
		label = 'Anchovya',
		weight = 20,
		stack = true,
		description = "Szardella; apró tengeri hal.",
	},

	['grouper'] = {
		label = 'Gróper',
		weight = 50,
		stack = true,
		description = "Fűrészfogú sügér; tengeri fogás.",
	},

	['haddock'] = {
		label = 'Tőkehal',
		weight = 100,
		stack = true,
		description = "Foltos tőkehal; tengeri fogás.",
	},

	['mahi_mahi'] = {
		label = 'Mahi Mahi',
		weight = 450,
		stack = true,
		description = "Mahi-mahi; trópusi tengeri hal.",
	},

	['piranha'] = {
		label = 'Piránya',
		weight = 500,
		stack = true,
		description = "Piranha; ragadozó édesvízi hal.",
	},

	['red_snapper'] = {
		label = 'Vörös sügér',
		weight = 700,
		stack = true,
		description = "Vörös csattogóhal; tengeri fogás.",
	},

	['salmon'] = {
		label = 'Lazac',
		weight = 1000,
		stack = true,
		description = "Lazac; keresett tengeri hal.",
	},

	['shark'] = {
		label = 'Cápa',
		weight = 7500,
		stack = true,
		description = "Cápa; a nyílt tenger ritka fogása.",
	},

	['trout'] = {
		label = 'Pisztráng',
		weight = 750,
		stack = true,
		description = "Pisztráng; hegyi vizek hala.",
	},

	['tuna'] = {
		label = 'Tonhal',
		weight = 10000,
		stack = true,
		description = "Tonhal; nagy testű tengeri hal.",
	},

	['itbananashake'] = {
		label = 'Italiano Shake (Banános)',
		weight = 1,
		stack = true,
		close = true,
		description = "Banános turmix, 10%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},
--##ujbankrablas
	['green_laptop'] = {
		label = 'Zöld Laptop',
		weight = 100,
		stack = true,
		close = true,
		description = "Hacker laptop"
	},

	['xae12'] = {
		label = 'XAE12 Laptop',
		weight = 100,
		stack = true,
		close = true,
		description = "Hacker laptop"
	},

	['goldbar'] = {
		label = 'Aranyrúd',
		weight = 100,
		stack = true,
		close = true,
		description = "Elég drágának tűnik."
	},

	['diamondbar'] = {
		label = 'Gyémántrúd',
		weight = 100,
		stack = true,
		close = true,
		description = "Elég drágának tűnik."
	},

	['advanced_drill'] = {
		label = 'Fejlett Fúró (Bank)',
		weight = 100,
		stack = true,
		close = true,
		description = "Fejlett fúró"
	},

--## új ékszer
	["goldbull"] = {
		label = "Aranyérmék",
		weight = 100,
		stack = true,
		close = false,
		description = "Néhány aranyérme."
	},
--###Új nemzeti
	['dia_box_pacific'] = {
		label = 'Zárt doboz',
		weight = 150,
		stack = false,
		close = false,
		description = 'Zárt doboz tele gyémántokkal'
	},
	['gold_bar'] = {
		label = 'Aranyrúd',
		weight = 100,
		stack = true,
		close = false,
		description = 'Aranyrudakból készült'
	},
	['bluediamond'] = {
		label = 'Kék gyémánt',
		weight = 50,
		stack = true,
		close = false,
		description = 'Drága gyémánt'
	},
	['diamond'] = {
		label = 'Gyémánt',
		weight = 50,
		stack = true,
		close = false,
		description = 'Gyémánt'
	},
	['large_drill'] = {
		label = 'Fúró (Nemzeti)',
		weight = 2050,
		stack = false,
		close = false,
		description = 'Nagy ipari fúró'
	},
	['bombed_money_pacific'] = {
		label = 'Festékkel bombázott pénz',
		weight = 0,
		stack = true,
		close = false,
		description = 'Pénzkötegek rejtett festékbombákkal'
	},
	['ruined_money'] = {
		label = 'Tönkrement pénz',
		weight = 0,
		stack = true,
		close = false,
		description = 'Pénzkötegek, amelyeket letisztíthatatlan festék roncsolt'
	},
	['pinkdiamond'] = {
		label = 'Rózsaszín gyémánt',
		weight = 1000,
		stack = true,
		close = true,
		description = "Nagyon drága rózsaszín gyémánt"
	},
	['panther'] = {
		label = 'Párduc szobor',
		weight = 1000,
		stack = true,
		close = true,
		description = "Nagyon drága párduc szobor"
	},
	['pbottle'] = {
		label = 'Palack',
		weight = 1000,
		stack = true,
		close = true,
		description = "Nagyon drága palack, apró gyémántokkal borítva"
	},
	['pnecklace'] = {
		label = 'Nyaklánc',
		weight = 1000,
		stack = true,
		close = true,
		description = "Nagyon drága nyaklánc, tele drága gyémántokkal"
	},
	['pmonkey'] = {
		label = 'Majom szobor',
		weight = 1000,
		stack = true,
		close = true,
		description = "Nagyon drága majom szobor, tiszta aranyból készült!"
	},
	['necklace'] = {
		label = 'Nyaklánc',
		weight = 1000,
		stack = true,
		close = true,
		description = "Tiszta aranyból készült nyaklánc"
	},
	['ring'] = {
		label = 'Gyűrű',
		weight = 1000,
		stack = true,
		close = true,
		description = "Gyémántból készült gyűrű"
	},
	['rolex'] = {
		label = 'Rolex',
		weight = 1000,
		stack = true,
		close = true,
		description = "Rolex óra speciális arany kiadásban"
	},
	["thermite"] = {
		label = "Termit",
		weight = 1000,
		stack = true,
		close = true,
		description = "Néha azt kívánod, hogy minden égjen..."
	},
	["c4_bomb"] = {
		label = "C4 (PSZ)",
		weight = 1000,
		stack = true,
		close = true,
		description = "Robbants fel valamit!"
	},
	["cutter"] = {
		label = "Plazmavágó",
		weight = 1000,
		stack = true,
		close = true,
		description = "Nagyon hasznos páncélozott üveg vágásához."
	},
	['hack_usb'] = {
		label = 'Hackelő USB',
		weight = 50,
		stack = false,
		close = false,
		description = 'USB eszköz különféle hackelő szoftverekkel'
	},

	["boombox"] = {
		label = "Boombox",
		weight = 0,
		stack = true,
		close = true,
		description = "Boombox; hordozható hangfal a zenéhez.",
	},

	["szajtapasz"] = {
		label = "Szájtapasz",
		weight = 0,
		stack = true,
		close = true,
		description = "Szájtapasz; elnémítja a foglyot.",
	},

	--#husvet

	['nyuszitojas'] = {
		label = 'Nyuszi Tojás',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Húsvéti nyuszitojás; az esemény gyűjthető darabja."
	},

	['romlotttojas'] = {
		label = 'Romlott Tojás',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Romlott tojás; a húsvéti esemény vicces darabja."
	},

	['budoskolni'] = {
		label = 'Büdös kölni',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Büdös kölni; senki nem örül neki."
	},

	['illatoskolni'] = {
		label = 'Illatos kölni',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Illatos kölni; kellemes ajándék."
	},

	['nyuszitojas2'] = {
		label = 'Nyuszi Tojás 2026',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Húsvéti nyuszitojás a 2026-os eseményről."
	},

	['romlotttojas2'] = {
		label = 'Romlott Tojás 2026',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Romlott tojás a 2026-os húsvéti eseményről."
	},

	['budoskolni2'] = {
		label = 'Büdös kölni 2026',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Büdös kölni a 2026-os húsvéti eseményről."
	},

	['illatoskolni2'] = {
		label = 'Illatos kölni 2026',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Illatos kölni a 2026-os húsvéti eseményről."
	},

	['husvetilada'] = {
		label = 'Húsvéti Láda',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Húsvéti láda ünnepi jutalmakkal."
	},

	['husvetiszerencselada'] = {
		label = 'Husvéti Szerencse Láda',
		weight = 0.1,
		stack = true,
		close = true,
		description = "Húsvéti szerencseláda ritkább nyereményekkel."
	},


	["hobby_miningcomputer"] = {
		label = "Bányász gép",
		weight = 2,
		stack = true,
		close = true,
		description = "Bányászgép a kriptovaluta bányászásához.",
	},
    ["small_cooler"] = {
		label = "Kis hűtés (crypto bányászat)",
		weight = 2,
		stack = true,
		close = true,
		description = "Kis hűtés a bányászgéphez; csökkenti a túlmelegedést.",
	},
    ["medium_cooler"] = {
        label = "Közepes hűtés (crypto bányászat)",
        weight = 2,
        stack = true,
        close = true,
        description = "Közepes hűtés a bányászgéphez; jobban visszafogja a hőt.",
    },
    ["small_gpu"] = {
        label = "Kis GPU (crypto bányászat)",
        weight = 2,
        stack = true,
        close = true,
        description = "Kis GPU a bányászgépbe; növeli a bányászott mennyiséget.",
    },
    ["medium_gpu"] = {
        label = "Közepes GPU (crypto bányászat)",
        weight = 2,
        stack = true,
        close = true,
        description = "Közepes GPU a bányászgépbe; nagyobb teljesítménnyel.",
    },
	---SISA
	["hookah_apple"] = { 
		label = "Almás Vízipipa",
		weight = 10, 
		stack = true, 
		close = false, 
		description = "Alma ízesítésű vízipipa",
	},

	["hookah_blueberry"] = { 
		label = "Áfonyás Vízipipa",
		weight = 10, 
		stack = true, 
		close = false, 
		description = "Áfonya ízesítésű vízipipa",
	},

	["hookah_mangomint"] = { 
		label = "Mangó-Menta Vízipipa",
		weight = 10, 
		stack = true, 
		close = false, 
		description = "Mangó és menta ízesítésű vízipipa",
	},

	["hookah_starburst"] = { 
		label = "Gyümölcs Mix Vízipipa",
		weight = 10, 
		stack = true, 
		close = false, 
		description = "Gyümölcs mix ízesítésű vízipipa",
	},

	["hookah_watermelon"] = { 
		label = "Görögdinnyés Vízipipa",
		weight = 10, 
		stack = true, 
		close = false, 
		description = "Görögdinnye ízesítésű vízipipa",
	},

	["coal"] = { 
		label = "Szén",
		weight = 10, 
		stack = true, 
		close = false, 
		description = "Vízipipához való szén",
	},
	--ÚJ FŰ RENDSZER:
	["joint_roller"] = {
		label = "Joint Tekerő",
		weight = 50, 
		stack = true, 
		close = true, 
		description = "Joint tekerésére használható eszköz",
		client = {
			image = 'joint_roller.png',
		} 
	},
	["rolling_paper"] = {
		label = "Tekerőpapír",
		weight = 10, 
		stack = true, 
		close = false, 
		description = "Joint készítéséhez szükséges papír",
		client = {
			image = 'rolling_paper.png',
		} 
	},
	['viccesjoint'] = {
		label = 'Vicces Cigi',
		weight = 0.1,
		stack = true,
		close = true,
		degrade = 10080,  -- 7 nap percben, mint a Sativa és a Kokain
		description = "Vicces cigi; ártalmatlan tréfa."
	},

	['dead_chicken'] = {
		label = 'Döglött csirke',
		weight = 1,
		stack = true,
		close = true,
		description = "Döglött csirke; feldolgozásra vár."
	},
	['dead_rabbit'] = {
		label = 'Döglött nyúl',
		weight = 2,
		stack = true,
		close = true,
		description = "Döglött nyúl; a vadászat zsákmánya."
	},
	['dead_pig'] = {
		label = 'Döglött malac',
		weight = 10,
		stack = true,
		close = true,
		description = "Döglött malac; feldolgozásra vár."
	},

	['topjoy'] = {
		label = 'HighJoy',
		weight = 0.2,
		stack = true,
		close = true,
		description = "Gyümölcslé, 40%-kal oltja a szomjúságot. Extra: 5 percig gyorsabb futás és úszás, +25 páncél."
	},

	['rendvedelmi_kit1'] = {
		label = 'Rendvédelmi felszerelés 1',
		weight = 10000,
		stack = true,
		close = true,
		description = "Rendvédelmi felszereléscsomag a szolgálathoz."
	},

	['rendvedelmi_kit2'] = {
		label = 'Rendvédelmi felszerelés 2',
		weight = 10000,
		stack = true,
		close = true,
		description = "Bővített rendvédelmi felszereléscsomag."
	},

	['felejto_injekcio'] = {
		label = 'Felejtő injekció',
		weight = 0.5,
		stack = true,
		close = true,
		description = "Injekció, amely után elhalványulnak az elmúlt időszak emlékei."
	},

	['goldbull'] = {
	label = 'Aranyérmék',
	weight = 100,
	stack = true,
	close = false,
	description = 'Néhány aranyérme',
},
['large_drill'] = {
	label = 'Fúró',
	weight = 2050,
	stack = false,
	close = false,
	description = 'Egy nagy ipari fúró',
},
['thermaldrill'] = {
	label = 'Hőfúró',
	weight = 2050,
	stack = false,
	close = false,
	description = 'Egy nagy ipari hőfúró',
},
['necklace'] = {
	label = 'Nyaklánc',
	description = "Tisztán aranyból készült nyaklánc",
	weight = 1000,
	stack = true,
	close = true
},
['ring'] = {
	label = 'Gyűrű',
	description = "Gyémántból készült gyűrű",
	weight = 1000,
	stack = true,
	close = true
},
['rolex'] = {
	label = 'Rolex',
	description = "Különleges arany Rolex óra",
	weight = 1000,
	stack = true,
	close = true
},
['gold_bar'] = {
	label = 'Aranyrúd',
	description = "Aranyból készült rúd",
	weight = 1000,
	stack = true,
	close = true
},
['hack_usb'] = {
	label = 'Hackelő USB',
	weight = 50,
	stack = false,
	close = false,
	description = 'USB eszköz, ami különféle hackelő programokat tartalmaz',
},
['casino_seccard'] = {
	label = 'Biztonsági kártya',
	weight = 50,
	stack = false,
	close = false,
	description = 'Kaszinó biztonsági kártya, mellyel hozzáférhetsz a menedzsment szobákhoz',
},

["cutter"] = {
	label = "Plazmavágó (ATM,Vonat)",
	weight = 1000,
	stack = true,
	close = true,
	description = "Nagyon hasznos vastag, páncélozott üveg vágásakor.",
},
['pinkdiamond'] = {
	label = 'Rózsaszín gyémánt',
	description = "Nagyon drága rózsaszín gyémánt",
	weight = 1000,
	stack = true,
	close = true
},
['panther'] = {
	label = 'Párduc szobor',
	description = "Nagyon értékes párduc szobor",
	weight = 1000,
	stack = true,
	close = true
},
['pbottle'] = {
	label = 'Üveg',
	description = "Nagyon értékes üveg, apró gyémántokkal borítva",
	weight = 1000,
	stack = true,
	close = true
},
['pnecklace'] = {
	label = 'Nyaklánc',
	description = "Nagyon értékes nyaklánc, drága gyémántokkal kirakva",
	weight = 1000,
	stack = true,
	close = true
},
['pmonkey'] = {
	label = 'Majom szobor',
	description = "Nagyon értékes majom szobor, tiszta aranyból készült!",
	weight = 1000,
	stack = true,
	close = true
},


['fajdalomcsillapito'] = {
	label = 'Fájdalom csillapító',
	description = "Fájdalomcsillapító tabletta; bevéve enyhíti a fájdalmat.",
	weight = 0.1,
	stack = true,
	close = true
},
['lazcsillapito'] = {
	label = 'Láz csillapító',
	description = "Lázcsillapító tabletta; leviszi a lázat.",
	weight = 0.1,
	stack = true,
	close = true
},
['gyulladascsokkento'] = {
	label = 'Gyulladás csökkentő',
	description = "Gyulladáscsökkentő tabletta; enyhíti a gyulladást.",
	weight = 0.1,
	stack = true,
	close = true
},





['empty_watering_can'] = {
		label = 'Üres öntözőkanna',
		weight = 100,
		stack = false,
		close = true,
		description = 'Egy üres öntözőkanna, amelyet fel kell tölteni vízzel a használathoz.'
	},

	['watering_can'] = {
		label = 'Öntözőkanna',
		weight = 200,
		stack = false,
		close = true,
		description = 'Egy vízzel teli öntözőkanna, amelyet a növények öntözésére használhatsz.'
	},

	['premuimform'] = {
		label = 'Prémium tápoldat',
		weight = 50,
		stack = true,
		close = true,
		description = 'Különleges tápoldat, amely felgyorsítja a növények fejlődését.'
	},

	['cherry_tomato_seed'] = {
		label = 'Koktélparadicsom mag',
		weight = 10,
		stack = true,
		close = true,
		description = 'Koktélparadicsom termesztéséhez szükséges mag.'
	},

	['tomato_seed'] = {
		label = 'Paradicsom mag',
		weight = 10,
		stack = true,
		close = true,
		description = 'Paradicsom termesztéséhez szükséges mag.'
	},

	['coca_seed'] = {
		label = 'Koka mag',
		weight = 10,
		stack = true,
		close = true,
		description = 'Kokacserje termesztéséhez szükséges mag (illegális).'
	},

	['salad_seed'] = {
		label = 'Saláta mag',
		weight = 10,
		stack = true,
		close = true,
		description = 'Saláta termesztéséhez szükséges mag.'
	},

	['corn_seed'] = {
		label = 'Kukorica mag',
		weight = 10,
		stack = true,
		close = true,
		description = 'Kukorica termesztéséhez szükséges mag.'
	},

	['barley_seed'] = {
		label = 'Árpa mag',
		weight = 10,
		stack = true,
		close = true,
		description = 'Árpa termesztéséhez szükséges mag.'
	},

	['cherry_tomato'] = {
		label = 'Koktélparadicsom',
		weight = 50,
		stack = true,
		close = true,
		description = 'Friss koktélparadicsom, amit felhasználhatsz vagy eladhatsz.'
	},

	['tomato'] = {
		label = 'Paradicsom',
		weight = 50,
		stack = true,
		close = true,
		description = 'Érett paradicsom, amely étkezéshez vagy kereskedelemhez használható.'
	},

	['coca'] = {
		label = 'Koka levél',
		weight = 50,
		stack = true,
		close = true,
		description = 'Kokacserjéből származó levél, feldolgozás után illegális anyaggá válhat.'
	},

	['salad'] = {
		label = 'Saláta',
		weight = 50,
		stack = true,
		close = true,
		description = 'Friss zöld saláta'
	},

	['corn'] = {
		label = 'Kukorica',
		weight = 50,
		stack = true,
		close = true,
		description = 'Érett kukorica'
	},

	['barley'] = {
		label = 'Árpa',
		weight = 50,
		stack = true,
		close = true,
		description = 'Árpa'
	},


	['zabkasa'] = {
		label = 'Zabkása',
		weight = 50,
		stack = true,
		close = true,
		description = 'Egyik legjobb tápértékű étel.'
	},
	['egeszsegessahke'] = {
		label = 'Egészséges Shake',
		weight = 50,
		stack = true,
		close = true,
		description = 'Egyik legjobb tápértékű ital.'
	},

	['emelo'] = {
		label = 'Emelő',
		weight = 3000,
		stack = true,
		close = true,
		description = 'Fordítsd vissza az autód'
	},


	--- muszaki cuccok
['csavarhuzo_keszlet'] = {
    label = 'Csavarhúzó készlet',
    weight = 500,
    stack = true,
    close = true,
    description = 'Egy alap szerszámkészlet kisebb munkákhoz.',
},

['izzodoboz'] = {
    label = 'Izzó doboz',
    weight = 200,
    stack = true,
    close = true,
    description = 'Néhány tartalék izzó.',
},

['zseblampa'] = {
    label = 'Használt zseblámpa',
    weight = 300,
    stack = true,
    close = true,
    description = 'Még működik, de nem a legjobb állapotban.',
},

['szerszamoslada'] = {
    label = 'Szerszámosláda',
    weight = 2500,
    stack = false,
    close = true,
    description = 'Egy komolyabb, komplett szerszámosláda.',
},

['emelokar'] = {
    label = 'Emelőkar',
    weight = 1500,
    stack = false,
    close = true,
    description = 'Autók felemelésére szolgáló eszköz.',
},
--- antik cuccok
['regiujsag'] = {
    label = 'Régi újság',
    weight = 100,
    stack = true,
    close = true,
    description = 'Elsárgult papírlapok, talán értékes lehet gyűjtőknek.',
},

['antik_bogre'] = {
    label = 'Antik bögre',
    weight = 200,
    stack = true,
    close = true,
    description = 'Porcelán bögre a múlt századból.',
},

['zsebora_rossz'] = {
    label = 'Régi faóra',
    weight = 150,
    stack = true,
    close = true,
    description = 'Nem működik, megették a termeszek, de könnyen megjavítható, hogy ketyegjen újra a kicsike!',
},

['antik_irogep'] = {
    label = 'Antik írógép',
    weight = 4000,
    stack = false,
    close = true,
    description = 'Régi mechanikus írógép, gyűjtők kincse.',
},

['antik_festmeny'] = {
    label = 'Antik festmény',
    weight = 2500,
    stack = false,
    close = true,
    description = 'Egy kisméretű, régi festmény, értékes lehet.',
},
--- ekszerek
['ezustgyuru'] = {
    label = 'Ezüst gyűrű',
    weight = 50,
    stack = true,
    close = true,
    description = 'Egyszerű ezüstgyűrű.',
},

['fulbevalo'] = {
    label = 'Ezüst fülbevaló',
    weight = 50,
    stack = true,
    close = true,
    description = 'Egy egyszerű fülbevaló pár.',
},

['aranylanc'] = {
    label = 'Aranylánc',
    weight = 100,
    stack = true,
    close = true,
    description = 'Egy szép aranylánc, értékes darab.',
},

['brilians_gyuru'] = {
    label = 'Briliáns gyűrű',
    weight = 80,
    stack = false,
    close = true,
    description = 'Drága gyűrű briliáns kővel.',
},

['ekszerlada'] = {
    label = 'Ékszeres ládika',
    weight = 500,
    stack = false,
    close = true,
    description = 'Egy kisméretű ládika tele különböző ékszerekkel.',
},

 ['scuba_set'] = {
 	label = 'Búvárfelszerelés',
 	weight = 2000,
 	description = "Búvárfelszerelés a víz alatti merüléshez.",
 	stack = false,
 	client = {
 		export = 'ed_scuba.wear'
 	}
 },
 ['scuba_fins'] = {
 	label = 'Búváruszonyok',
 	weight = 200,
 	description = "Búváruszonyok; gyorsabban úszol velük a víz alatt.",
 	stack = false,
 	client = {
 		export = 'ed_scuba.wear'
 	}
 },

['kagylonyaklanc'] = {
    label = 'Kagyló nyaklánc',
    weight = 100,
    stack = true,
    close = true,
    description = 'Kézzel készített nyaklánc különleges tengeri kagylókból.',
},

['aranytallo'] = {
    label = 'Arany tallér',
    weight = 50,
    stack = true,
    close = true,
    description = 'Egy régi aranypénz, valószínűleg egy elsüllyedt hajóról származik.',
},

['aranykupa'] = {
    label = 'Arany kupa',
    weight = 700,
    stack = true,
    close = true,
    description = 'Díszes arany kupa, gazdagon díszítve drágakövekkel.',
},

['gyemantmedal'] = {
    label = 'Gyémánt medál',
    weight = 80,
    stack = true,
    close = true,
    description = 'Egy fényűző medál, amit valószínűleg egy nemes viselt.',
},

['archeologiai_lelet'] = {
    label = 'Archeológiai lelet',
    weight = 300,
    stack = true,
    close = true,
    description = 'Egy régi, felismerhetetlen tárgy a tenger mélyéről – lehet, hogy múzeumi érték.',
},

['deployable_light'] = {
        label = 'Levehető sziréna',
        weight = 250,
		consume = 0,
		server = {
            export = 'gs_deployablelight.deployable_light',
        },
        description = "Levehető sziréna; a helyszín megvilágítására és jelzésre.",
    },

	['deployable_light_blue'] = {
        label = 'Blue Deployable Light',
        weight = 250,
        consume = 0,
        server = {
            export = 'gs_deployablelight.deployable_light_blue',
        },
        description = "Kék jelzőfény; lerakható a helyszínen.",
    },
    ['deployable_light_red'] = {
        label = 'Red Deployable Light',
        weight = 250,
        consume = 0,
        server = {
            export = 'gs_deployablelight.deployable_light_red',
        },
        description = "Piros jelzőfény; lerakható a helyszínen.",
    },
    ['deployable_light_orange'] = {
        label = 'Orange Deployable Light',
        weight = 250,
        consume = 0,
        server = {
            export = 'gs_deployablelight.deployable_light_orange',
        },
        description = "Narancssárga jelzőfény; lerakható a helyszínen.",
    },

	--[[['ghostcam'] = {
		label = 'Szellem kamera',
		weight = 100,
		stack = true,
		close = true,
		consume = 0,
		description = '',
		server = {
			export = 'randol_ghosthunting.ghostcam',
		},
	},--]]
	
	['strecher'] = {
        label = 'Hordágy',
        weight = 5000,
        stack = false,
        close = true,
        description = 'Egy összecsukható hordágy',
        server = {
            export = 'rota_hordagy:server:createStretcher',
        }
    },
	
	['torture_kit'] = {
		label = 'Kínzókészlet',
		weight = 1000,
		stack = false,
		close = true,
        description = 'Professzionális kínzókészlet.',
	},

	['dolaj'] = {
		label = 'Dubai olaj',
		weight = 0.5,
		stack = true,
		close = true,
		description = 'Kiváló minőségű, prémium dubai olaj.',
	},

	['firework_1'] = {
		label = 'Tűzijáték 1',
		weight = 1000,
		stack = false,
		description = 'Egy színes tűzijáték 50 lövéssel'
	},

	['firework_2'] = {
		label = 'Tűzijáték 2',
		weight = 1000,
		stack = false,
		description = 'Egy speciális tűzijáték 80 lövéssel'
	},

	['firework_3'] = {
		label = 'Tűzijáték 3',
		weight = 1000,
		stack = false,
		description = 'Egy változatos tűzijáték 80 lövéssel'
	},

	['firework_4'] = {
		label = 'Tűzijáték 4',
		weight = 1000,
		stack = false,
		description = 'Egy intenzív tűzijáték 50 lövéssel'
	},

	['fontain_4'] = {
		label = 'Szökőkút tűzijáték',
		weight = 1000,
		stack = false,
		description = 'Egy szökőkút stílusú tűzijáték 80 lövéssel'
	},

	['karacsonyfa'] = {
		label = 'Karácsonyfa',
		weight = 100,
		stack = false,
		description = 'Állíts fel egy karácsonyfát ahol csak szeretnél'
	},

	['snowman'] = {
		label = 'Hóember',
		weight = 100,
		stack = false,
		description = 'Építs egy hóembert ahol csak szeretnél'
	},

	['bctablet'] = {
		label = 'BC Tablet',
		weight = 1,
		stack = true,
		description = 'Ismerd meg a szervert!'
	},

	['szerencsekasza'] = {
		label = 'Mágikus kasza',
		weight = 100,
		stack = true,
		description = 'Szerencshozó kasza'
	},
	['szerencsekosar'] = {
		label = 'Mágikus kosár',
		weight = 100,
		stack = true,
		description = 'Szerencshozó kosár'
	},
	['mentoscukor'] = {
		label = 'Kis Cukorka',
		weight = 100,
		stack = true,
		description = "Ügyes voltál az ellátás során :)"
	},
    ['crab'] = {
        label       = 'Rák',
        weight      = 500,
        stack       = true,
        description = 'Egy frissen fogott rák. Súlya és minősége változó.',
    },

    ['crab_rope'] = {
        label       = 'Rákcsapda Kötél',
        weight      = 100,
        stack       = true,
        description = 'Egy erős kötél, amellyel rákcsapdát lehet a vízbe ereszteni.',
    },

    ['crab_rope_steel'] = {
        label       = 'Acél Rákcsapda Kötél',
        weight      = 200,
        stack       = true,
        description = 'Megerősített acélkötél. Nehezebb elszakítani és több rákot húz fel.',
    },

    ['crab_rope_pro'] = {
        label       = 'Profi Rákcsapda Kötél',
        weight      = 350,
        stack       = true,
        description = 'Professzionális minőségű rákcsapda kötél. Maximális hozam és szinte szakíthatatlan.',
    },

	["headbag"] = {
		label = "Zsák",
		weight = 0,
		stack = true,
		close = true,
		description = "Fejre húzható zsák; a fogoly nem lát vele.",
	},

	["weaponrepairkit"] = {
		label = "Fegyver javító készlet",
		weight = 10,
		stack = true,
		close = true,
		description = "A használatához, jobb klikelj a javítani kívánt fegyverre majd válaszd a javítás opciót!",
	},

	['aurora_necklace'] = {
		label = 'Aurora Gyémánt Nyaklánc',
		weight = 250,
		stack = true,
		close = true,
		description = 'Ritka és rendkívül értékes gyémánt nyaklánc.',
	},

	['obsidian_ring'] = {
		label = 'Obsidian Királyi Gyűrű',
		weight = 100,
		stack = true,
		close = true,
		description = 'Fekete obszidiánnal díszített luxus gyűrű.',
	},

	['eclipse_pendant'] = {
		label = 'Eclipse Zafír Medál',
		weight = 180,
		stack = true,
		close = true,
		description = 'Prémium zafír medál.',
	},

    ['vehicle_coverer'] = {
        label  = 'Autólepedő',
        weight = 500,
        stack  = false,
        description = "Autólepedő; letakarja a parkoló járművet.",
    },

	['job_extra_boost_small'] = {
		label  = 'Prémium Munkajegy (1,5x EXP + 1,5x Pénz)',
		weight = 10,
		stack  = true,
		description = 'Aktiválás után 24 órán keresztül 1,5x EXP és 1,5x pénzjutalmat biztosít minden munkánál.',
		server = {
			export     = "bc_jobboost.useJobBoost",
			moneyBoost = 1.5,
			xpBoost    = 1.5,
			duration   = 1440,
		},
	},

	['job_xp_boost_small'] = {
		label  = 'Prémium Munkajegy (1,5x EXP)',
		weight = 10,
		stack  = true,
		description = 'Aktiválás után 24 órán keresztül 1,5x EXP jutalmat biztosít minden munkánál.',
		server = {
			export   = "bc_jobboost.useJobBoost",
			xpBoost  = 1.5,
			duration = 1440,
		},
	},

	['job_money_boost_small'] = {
		label  = 'Prémium Munkajegy (1,5x Pénz)',
		weight = 10,
		stack  = true,
		description = 'Aktiválás után 24 órán keresztül 1,5x pénzjutalmat biztosít minden munkánál.',
		server = {
			export     = "bc_jobboost.useJobBoost",
			moneyBoost = 1.5,
			duration   = 1440,
		},
	},

	['szerelotablet'] = {
		label = 'Szerelő tablet',
		weight = 500,
		stack = true,
		close = true,
		degrade = 10080,  -- 7 nap percben
		decay = true,     -- lejáratkor magától törlődik
		description = 'Műszaki vizsgáztató terminál. Csak szerelők tudják használni.',
	},

	['rendvedelmi_kordon'] = {
		label = 'Kordon',
		weight = 3000,
		stack = true,
		close = true,
		consume = 0,
		client = { event = 'SceneMenu:Client:UseItem' },
		description = 'Rendvédelmi kordon a helyszín lezárásához. Használd a lerakáshoz.'
	},

	['rendvedelmi_bolya'] = {
		label = 'Bólya',
		weight = 1000,
		stack = true,
		close = true,
		consume = 0,
		client = { event = 'SceneMenu:Client:UseItem' },
		description = 'Rendvédelmi bólya a helyszín lezárásához. Használd a lerakáshoz.'
	},

	['rendvedelmi_sator'] = {
		label = 'Helyszínelő sátor',
		weight = 5000,
		stack = true,
		close = true,
		consume = 0,
		client = { event = 'SceneMenu:Client:UseItem' },
		description = 'Helyszínelő sátor a bizonyítékok védelmére. Használd a lerakáshoz.'
	},

	['rendvedelmi_lampa'] = {
		label = 'Helyszíni világítás',
		weight = 2000,
		stack = true,
		close = true,
		consume = 0,
		client = { event = 'SceneMenu:Client:UseItem' },
		description = 'Hordozható munkalámpa a helyszín megvilágításához. Használd a lerakáshoz.'
	},

	['rendvedelmi_karton'] = {
		label = 'Karton tábla',
		weight = 500,
		stack = true,
		close = true,
		consume = 0,
		client = { event = 'SceneMenu:Client:UseItem' },
		description = 'Rendvédelmi karton tábla és jelzés. Használd a lerakáshoz.'
	},

	['forgalmi'] = {
		label = 'Forgalmi engedély',
		weight = 5,
		stack = false,          -- KÖTELEZŐ false, mert minden példánynak saját metadatája van
		close = true,
		consume = 0,            -- használatkor nem fogy el
		description = 'Jármű forgalmi engedélye',
		client = { export = 'bc_forgalmi.useForgalmi' }
	},

    ['traffipax_ticket'] = {
        label = 'Sebességmérő Csekk',
        weight = 10,
        stack = false,
        consume = 0,
        close = true,
        description = 'Traffipax által készített fotó a szabálysértésről.',
        client = {
            event = 'rota_traffipax:viewTicketPhoto'
        }
    },

	['ppszerzodes'] = {
		label = 'PP Szerződés',
		weight = 30,
		stack = true,
		close = true,
		description = 'Prémium pont utaláshoz szükséges szerződés.',
	},

}