-- Everything a player can earn. Pure data, read by the server, the client and
-- (forwarded once, locally) the NUI. Adding an achievement = adding a row here.
--
-- Achievement fields
--   id        unique, lowercase, never rename it (it is the database key)
--   category  Config.Categories id
--   tier      Config.Tiers id, decides points and colour
--   icon      icon name from html/js/icons.js
--   hidden    true = shown as a secret until unlocked
--   noFirst   true = never a server first (milestones that only count other unlocks)
-- and exactly one trigger
--   stat + goal   progress on a Config.Stats key ('all' = every visible landmark)
--   jobs          Config.Jobs.Groups key, unlocked while holding such a job
--   boss          true, unlocked at the highest grade of any job
--   landmark      Config.Landmarks id
--   manual        true, only another resource unlocks it (exports.bc_tasksystem:Unlock)

Config.Tiers = {
	bronze = { label = 'Bronz',    points = 10,  rank = 1 },
	silver = { label = 'Ezüst',    points = 25,  rank = 2 },
	gold   = { label = 'Arany',    points = 50,  rank = 3 },
	legend = { label = 'Legendás', points = 100, rank = 4 },
}

Config.Categories = {
	{ id = 'start',     label = 'Első lépések', desc = 'Az első napok a városban',     icon = 'flag' },
	{ id = 'drive',     label = 'Közlekedés',   desc = 'Autók, motorok, hajók, gépek', icon = 'steering' },
	{ id = 'explore',   label = 'Felfedezés',   desc = 'Gyalog a város körül',         icon = 'compass' },
	{ id = 'adventure', label = 'Kaland',       desc = 'Víz, ég és vakmerőség',        icon = 'parachute' },
	{ id = 'time',      label = 'Idő és hűség', desc = 'Játékidő, napok, éjszakák',    icon = 'clock' },
	{ id = 'career',    label = 'Karrier',      desc = 'Munka, fizetés, vagyon',       icon = 'briefcase' },
	{ id = 'missions',  label = 'Küldetések',   desc = 'Jutalmak, munkák, rablások',   icon = 'target' },
	{ id = 'legacy',    label = 'Mérföldkövek', desc = 'Gyűjtés és szerver-elsők',     icon = 'crown' },
}

-- Stats ----------------------------------------------------------------------------------
--
-- source  'client'  collected by client/tracker.lua, clamped by the server
--         'server'  counted by the server from framework events or the clock
--         'external' only other resources move it (exports.AddProgress / SetRecord)
-- kind    'sum' (default) | 'max' (record) | 'set' (distinct members) | 'value' (set by the domain)
-- format  how the NUI prints it: distance (m) | time (s) | speed (km/h) | depth (m) | money | days | count
-- rate    client distance only: the fastest plausible speed in m/s
-- parent  client distance only: a subset of another stat, never more than the parent
-- cooldown client count only: at least this many seconds between two
-- limit   client record only: anything above is rejected

Config.Stats = {
	walk        = { label = 'Gyalog',                  format = 'distance', source = 'client', rate = 12 },
	walk_rain   = { label = 'Gyalog esőben',           format = 'distance', source = 'client', rate = 12, parent = 'walk' },
	swim        = { label = 'Úszás',                   format = 'distance', source = 'client', rate = 6 },
	drive       = { label = 'Autóval',                 format = 'distance', source = 'client', rate = 140 },
	drive_night = { label = 'Éjszakai vezetés',        format = 'distance', source = 'client', rate = 140, parent = 'drive' },
	offroad     = { label = 'Terepjáróval',            format = 'distance', source = 'client', rate = 100, parent = 'drive' },
	truck       = { label = 'Teherautóval',            format = 'distance', source = 'client', rate = 80,  parent = 'drive' },
	emergency   = { label = 'Szirénás járművel',       format = 'distance', source = 'client', rate = 120, parent = 'drive' },
	moto        = { label = 'Motorral',                format = 'distance', source = 'client', rate = 120 },
	bicycle     = { label = 'Kerékpárral',             format = 'distance', source = 'client', rate = 30 },
	boat        = { label = 'Hajóval',                 format = 'distance', source = 'client', rate = 70 },
	heli        = { label = 'Helikopterrel',           format = 'distance', source = 'client', rate = 100 },
	plane       = { label = 'Repülővel',               format = 'distance', source = 'client', rate = 320 },
	passenger   = { label = 'Utasként',                format = 'distance', source = 'client', rate = 320 },
	parachute   = { label = 'Ejtőernyős ugrás',        format = 'count',    source = 'client', cooldown = 15 },
	topspeed    = { label = 'Végsebesség',             format = 'speed',    source = 'client', kind = 'max', limit = 600 },
	depth       = { label = 'Legmélyebb merülés',      format = 'depth',    source = 'client', kind = 'max', limit = 400 },

	car_enter   = { label = 'Beszállás autóba',        format = 'count', source = 'server' },
	veh_enter   = { label = 'Beszállás járműbe',       format = 'count', source = 'server' },
	jumps       = { label = 'Ugrás',                   format = 'count', source = 'server' },
	deaths      = { label = 'Halál',                   format = 'count', source = 'server' },
	paychecks   = { label = 'Fizetés',                 format = 'count', source = 'server' },
	playtime    = { label = 'Játékidő',                format = 'time',  source = 'server' },
	session_max = { label = 'Leghosszabb játékmenet',  format = 'time',  source = 'server', kind = 'max' },
	days        = { label = 'Aktív nap',               format = 'days',  source = 'server' },
	streak      = { label = 'Jelenlegi sorozat',       format = 'days',  source = 'server', kind = 'value' },
	streak_max  = { label = 'Leghosszabb sorozat',     format = 'days',  source = 'server', kind = 'max' },
	midnights   = { label = 'Éjfél online',            format = 'count', source = 'server' },
	dawns       = { label = 'Hajnal online',           format = 'count', source = 'server' },
	newyears    = { label = 'Szilveszter online',      format = 'count', source = 'server' },
	bank_max    = { label = 'Legnagyobb egyenleg',     format = 'money', source = 'server', kind = 'max' },
	jobs        = { label = 'Kipróbált munka',         format = 'count', source = 'server', kind = 'set' },
	-- bc_tasksystem rewards (server/server.lua) and the success events of jobs, robberies and ox_fuel
	tasks           = { label = 'Átvett küldetés-jutalom', format = 'count', source = 'server' },
	tasks_weekly    = { label = 'Átvett heti jutalom',     format = 'count', source = 'server' },
	tasks_permanent = { label = 'Átvett örökös jutalom',   format = 'count', source = 'server' },
	work            = { label = 'Elvégzett munkafeladat',  format = 'count', source = 'server' },
	work_types      = { label = 'Kipróbált legális munka', format = 'count', source = 'server', kind = 'set' },
	robberies       = { label = 'Rablás',                  format = 'count', source = 'server' },
	robbery_types   = { label = 'Rablás-fajta',            format = 'count', source = 'server', kind = 'set' },
	refuels         = { label = 'Tankolás',                format = 'count', source = 'server' },
	landmarks   = { label = 'Felfedezett hely',        format = 'count', source = 'server', kind = 'set' },
	secrets     = { label = 'Titkos hely',             format = 'count', source = 'server', kind = 'set' },
	unlocks     = { label = 'Feloldott teljesítmény',  format = 'count', source = 'server', kind = 'value' },
	firsts      = { label = 'Szerver-első',            format = 'count', source = 'server', kind = 'value' },
	points      = { label = 'Pontszám',                format = 'count', source = 'server', kind = 'value' },
}

-- Order and grouping of the Statisztikák page.
Config.StatGroups = {
	{ label = 'Járművel',          icon = 'steering',  stats = { 'drive', 'moto', 'bicycle', 'boat', 'heli', 'plane', 'passenger', 'topspeed' } },
	{ label = 'Különleges utak',   icon = 'route',     stats = { 'drive_night', 'offroad', 'truck', 'emergency', 'veh_enter', 'car_enter' } },
	{ label = 'Gyalog és vízben',  icon = 'walk',      stats = { 'walk', 'walk_rain', 'swim', 'depth', 'parachute', 'jumps' } },
	{ label = 'Idő',               icon = 'clock',     stats = { 'playtime', 'session_max', 'days', 'streak', 'streak_max', 'midnights' } },
	{ label = 'Élet és karrier',   icon = 'briefcase', stats = { 'jobs', 'paychecks', 'bank_max', 'deaths', 'landmarks', 'firsts' } },
	{ label = 'Küldetések és munka', icon = 'target',  stats = { 'tasks', 'tasks_weekly', 'tasks_permanent', 'work', 'work_types', 'robberies', 'robbery_types', 'refuels' } },
}

-- Landmarks ------------------------------------------------------------------------------
--
-- radius is horizontal (2D), so a wrong height never hides a landmark; minZ
-- asks for a real climb. onFoot = not in a vehicle. hidden ones never show on
-- the map and fill the `secrets` set instead of `landmarks`. hours/rain are
-- extra client-side conditions (in-game hour range, rain) for secrets.

Config.Landmarks = {
	{ id = 'summit',      label = 'A hegy csúcsa',        coords = vec3(501.5, 5593.9, 796.2),    radius = 45.0,  minZ = 770.0, onFoot = true },
	{ id = 'observatory', label = 'Csillagvizsgáló',      coords = vec3(-438.8, 1076.1, 352.4),   radius = 70.0 },
	{ id = 'letters',     label = 'Az óriásbetűk',        coords = vec3(711.4, 1198.1, 348.5),    radius = 70.0,  onFoot = true },
	{ id = 'skyline',     label = 'A város teteje',       coords = vec3(-75.0, -818.2, 326.2),    radius = 60.0,  minZ = 290.0 },
	{ id = 'pier',        label = 'A móló',               coords = vec3(-1663.0, -1126.0, 13.0),  radius = 80.0 },
	{ id = 'legion',      label = 'A főtér',              coords = vec3(195.2, -933.8, 30.7),     radius = 90.0 },
	{ id = 'bowl',        label = 'Szabadtéri színpad',   coords = vec3(686.2, 577.9, 130.5),     radius = 90.0 },
	{ id = 'casino',      label = 'Kaszinó',              coords = vec3(924.7, 44.9, 81.5),       radius = 90.0 },
	{ id = 'museum',      label = 'Múzeum a dombon',      coords = vec3(-2243.8, 264.5, 174.6),   radius = 90.0 },
	{ id = 'beach',       label = 'Vespucci strand',      coords = vec3(-1350.0, -1450.0, 4.5),   radius = 250.0 },
	{ id = 'airport',     label = 'Nemzetközi repülőtér', coords = vec3(-1336.0, -3044.0, 13.9),  radius = 350.0 },
	{ id = 'port',        label = 'Konténerkikötő',       coords = vec3(1010.0, -3100.0, 5.9),    radius = 250.0 },
	{ id = 'dam',         label = 'A gát',                coords = vec3(1660.4, -12.0, 170.0),    radius = 150.0 },
	{ id = 'prison',      label = 'Börtönfal',            coords = vec3(1690.0, 2565.0, 45.6),    radius = 260.0 },
	{ id = 'airfield',    label = 'Sivatagi reptér',      coords = vec3(1500.0, 3230.0, 40.4),    radius = 300.0 },
	{ id = 'sandy',       label = 'Sandy Shores',         coords = vec3(1853.0, 3686.0, 34.3),    radius = 300.0 },
	{ id = 'lab',         label = 'Kutatólabor',          coords = vec3(3616.0, 3738.0, 28.7),    radius = 120.0 },
	{ id = 'grapeseed',   label = 'Grapeseed farmjai',    coords = vec3(1690.0, 4785.0, 42.0),    radius = 300.0 },
	{ id = 'paleto',      label = 'Paleto Bay',           coords = vec3(-275.0, 6225.0, 31.5),    radius = 350.0 },

	{ id = 'apparition',  label = 'Égi jelenés',          coords = vec3(501.5, 5593.9, 796.2),    radius = 60.0,  minZ = 770.0, hidden = true, hours = { 3, 4 }, rain = true },
}

-- Achievements -----------------------------------------------------------------------------

Config.Achievements = {
	-- Első lépések
	{ id = 'welcome',         category = 'start', tier = 'bronze', icon = 'door',      title = 'Üdv a városban!',       desc = 'Lépj be először a szerverre.',                      stat = 'days',      goal = 1 },
	{ id = 'first_car',       category = 'start', tier = 'bronze', icon = 'car',       title = 'Az első verda',         desc = 'Ülj be egy autóba.',                                stat = 'car_enter', goal = 1 },
	{ id = 'first_walk',      category = 'start', tier = 'bronze', icon = 'walk',      title = 'Első lépések',          desc = 'Tegyél meg 1 km-t gyalog.',                         stat = 'walk',      goal = 1000 },
	{ id = 'first_drive',     category = 'start', tier = 'bronze', icon = 'steering',  title = 'Volán mögött',          desc = 'Vezess 1 km-t autóval.',                            stat = 'drive',     goal = 1000 },
	{ id = 'first_passenger', category = 'start', tier = 'bronze', icon = 'users',     title = 'Potyautas',             desc = 'Utazz utasként 1 km-t.',                            stat = 'passenger', goal = 1000 },
	{ id = 'first_job',       category = 'start', tier = 'bronze', icon = 'briefcase', title = 'Első munkanap',         desc = 'Vállalj el egy munkát.',                            stat = 'jobs',      goal = 1 },
	{ id = 'first_paycheck',  category = 'start', tier = 'bronze', icon = 'cash',      title = 'Első fizetés',          desc = 'Kapd meg az első fizetésed egy munkahelyen.',       stat = 'paychecks', goal = 1 },
	{ id = 'first_death',     category = 'start', tier = 'bronze', icon = 'skull',     title = 'Senki sem tökéletes',   desc = 'Halj meg először.',                                 stat = 'deaths',    goal = 1 },
	{ id = 'first_landmark',  category = 'start', tier = 'bronze', icon = 'pin',       title = 'Turista',               desc = 'Fedezz fel egy nevezetességet.',                    stat = 'landmarks', goal = 1 },

	-- Közlekedés
	{ id = 'drive_25',        category = 'drive', tier = 'bronze', icon = 'car',       title = 'Hétvégi sofőr',         desc = 'Vezess 25 km-t autóval.',                           stat = 'drive',       goal = 25000 },
	{ id = 'drive_100',       category = 'drive', tier = 'silver', icon = 'road',      title = 'Úton otthon',           desc = 'Vezess 100 km-t autóval.',                          stat = 'drive',       goal = 100000 },
	{ id = 'drive_500',       category = 'drive', tier = 'gold',   icon = 'road',      title = 'Országúti vándor',      desc = 'Vezess 500 km-t autóval.',                          stat = 'drive',       goal = 500000 },
	{ id = 'drive_1000',      category = 'drive', tier = 'gold',   icon = 'road',      title = 'Ezer kilométer',        desc = 'Vezess 1 000 km-t autóval.',                        stat = 'drive',       goal = 1000000 },
	{ id = 'drive_2500',      category = 'drive', tier = 'legend', icon = 'steering',  title = 'Aszfaltkirály',         desc = 'Vezess 2 500 km-t autóval.',                        stat = 'drive',       goal = 2500000 },
	{ id = 'moto_25',         category = 'drive', tier = 'bronze', icon = 'moto',      title = 'Két keréken',           desc = 'Motorozz 25 km-t.',                                 stat = 'moto',        goal = 25000 },
	{ id = 'moto_250',        category = 'drive', tier = 'gold',   icon = 'moto',      title = 'Szél a hajamban',       desc = 'Motorozz 250 km-t.',                                stat = 'moto',        goal = 250000 },
	{ id = 'bicycle_10',      category = 'drive', tier = 'bronze', icon = 'bike',      title = 'Tekerj!',               desc = 'Kerékpározz 10 km-t.',                              stat = 'bicycle',     goal = 10000 },
	{ id = 'bicycle_100',     category = 'drive', tier = 'gold',   icon = 'bike',      title = 'Acélcomb',              desc = 'Kerékpározz 100 km-t.',                             stat = 'bicycle',     goal = 100000 },
	{ id = 'boat_10',         category = 'drive', tier = 'bronze', icon = 'ship',      title = 'Hajóra fel!',           desc = 'Hajózz 10 km-t.',                                   stat = 'boat',        goal = 10000 },
	{ id = 'boat_100',        category = 'drive', tier = 'gold',   icon = 'ship',      title = 'Kapitány',              desc = 'Hajózz 100 km-t.',                                  stat = 'boat',        goal = 100000 },
	{ id = 'heli_25',         category = 'drive', tier = 'silver', icon = 'heli',      title = 'Forgószárny',           desc = 'Repülj 25 km-t helikopterrel.',                     stat = 'heli',        goal = 25000 },
	{ id = 'heli_250',        category = 'drive', tier = 'gold',   icon = 'heli',      title = 'Légi mentő',            desc = 'Repülj 250 km-t helikopterrel.',                    stat = 'heli',        goal = 250000 },
	{ id = 'plane_100',       category = 'drive', tier = 'gold',   icon = 'plane',     title = 'Pilótaszem',            desc = 'Repülj 100 km-t repülőgéppel.',                     stat = 'plane',       goal = 100000 },
	{ id = 'plane_1000',      category = 'drive', tier = 'legend', icon = 'plane',     title = 'Felhők felett',         desc = 'Repülj 1 000 km-t repülőgéppel.',                   stat = 'plane',       goal = 1000000 },
	{ id = 'speed_150',       category = 'drive', tier = 'bronze', icon = 'gauge',     title = 'Gyorshajtó',            desc = 'Vezess 150 km/h-val.',                              stat = 'topspeed',    goal = 150 },
	{ id = 'speed_250',       category = 'drive', tier = 'silver', icon = 'gauge',     title = 'Villám',                desc = 'Vezess 250 km/h-val.',                              stat = 'topspeed',    goal = 250 },
	{ id = 'speed_320',       category = 'drive', tier = 'gold',   icon = 'rocket',    title = 'Rakéta',                desc = 'Vezess 320 km/h-val.',                              stat = 'topspeed',    goal = 320 },
	{ id = 'night_50',        category = 'drive', tier = 'silver', icon = 'moon',      title = 'Éjszakai lovas',        desc = 'Vezess 50 km-t éjszaka.',                           stat = 'drive_night', goal = 50000 },
	{ id = 'offroad_25',      category = 'drive', tier = 'silver', icon = 'mountain',  title = 'Terepjáró',             desc = 'Vezess 25 km-t terepjáróval.',                      stat = 'offroad',     goal = 25000 },
	{ id = 'truck_100',       category = 'drive', tier = 'gold',   icon = 'truck',     title = 'Kamionos',              desc = 'Vezess 100 km-t teherautóval.',                     stat = 'truck',       goal = 100000 },
	{ id = 'emergency_25',    category = 'drive', tier = 'silver', icon = 'siren',     title = 'Szirénázva',            desc = 'Vezess 25 km-t megkülönböztető jelzésű járművel.',  stat = 'emergency',   goal = 25000 },
	{ id = 'passenger_100',   category = 'drive', tier = 'silver', icon = 'users',     title = 'Hivatásos utas',        desc = 'Utazz utasként 100 km-t.',                          stat = 'passenger',   goal = 100000 },
	{ id = 'enter_100',       category = 'drive', tier = 'silver', icon = 'key',       title = 'Kulcsmester',           desc = 'Szállj be 100-szor egy járműbe.',                   stat = 'veh_enter',   goal = 100 },
	{ id = 'refuel_1',        category = 'drive', tier = 'bronze', icon = 'fuel',      title = 'Tele tankkal',          desc = 'Tankolj meg egy járművet.',                         stat = 'refuels',     goal = 1 },
	{ id = 'refuel_100',      category = 'drive', tier = 'silver', icon = 'fuel',      title = 'Benzingőz',             desc = 'Tankolj 100-szor.',                                 stat = 'refuels',     goal = 100 },

	-- Felfedezés
	{ id = 'walk_10',         category = 'explore', tier = 'bronze', icon = 'walk',       title = 'Kiránduló',          desc = 'Tegyél meg 10 km-t gyalog.',                        stat = 'walk',      goal = 10000 },
	{ id = 'walk_42',         category = 'explore', tier = 'silver', icon = 'shoe',       title = 'Maratonista',        desc = 'Tegyél meg 42 km-t gyalog.',                        stat = 'walk',      goal = 42195 },
	{ id = 'walk_150',        category = 'explore', tier = 'gold',   icon = 'shoe',       title = 'Vándor',             desc = 'Tegyél meg 150 km-t gyalog.',                       stat = 'walk',      goal = 150000 },
	{ id = 'walk_500',        category = 'explore', tier = 'legend', icon = 'route',      title = 'Zarándok',           desc = 'Tegyél meg 500 km-t gyalog.',                       stat = 'walk',      goal = 500000 },
	{ id = 'rain_5',          category = 'explore', tier = 'silver', icon = 'rain',       title = 'Ázott kabát',        desc = 'Sétálj 5 km-t esőben.',                             stat = 'walk_rain', goal = 5000 },
	{ id = 'landmarks_5',     category = 'explore', tier = 'bronze', icon = 'binoculars', title = 'Városnéző',          desc = 'Fedezz fel 5 nevezetességet.',                      stat = 'landmarks', goal = 5 },
	{ id = 'landmarks_12',    category = 'explore', tier = 'silver', icon = 'map',        title = 'Idegenvezető',       desc = 'Fedezz fel 12 nevezetességet.',                     stat = 'landmarks', goal = 12 },
	{ id = 'landmarks_all',   category = 'explore', tier = 'gold',   icon = 'compass',    title = 'Térképész',          desc = 'Fedezd fel az összes nevezetességet.',              stat = 'landmarks', goal = 'all' },
	{ id = 'lm_observatory',  category = 'explore', tier = 'bronze', icon = 'telescope',  title = 'Csillagles',         desc = 'Látogass el a csillagvizsgálóhoz.',                 landmark = 'observatory' },
	{ id = 'lm_pier',         category = 'explore', tier = 'bronze', icon = 'ferris',     title = 'Óriáskerék',         desc = 'Sétálj ki a mólóra.',                               landmark = 'pier' },
	{ id = 'lm_letters',      category = 'explore', tier = 'silver', icon = 'letters',    title = 'Óriásbetűk',         desc = 'Mássz fel a hegyoldal óriásbetűihez.',              landmark = 'letters' },
	{ id = 'lm_summit',       category = 'explore', tier = 'gold',   icon = 'mountain',   title = 'Csúcshódító',        desc = 'Állj gyalog a legmagasabb hegy csúcsán.',           landmark = 'summit' },
	{ id = 'lm_skyline',      category = 'explore', tier = 'gold',   icon = 'building',   title = 'A város teteje',     desc = 'Állj a legmagasabb felhőkarcoló tetején.',          landmark = 'skyline' },
	{ id = 'lm_apparition',   category = 'explore', tier = 'legend', icon = 'ufo',        title = 'Égi jelenés',        desc = 'Hajnali háromkor, esőben állj a hegy csúcsán.',     landmark = 'apparition', hidden = true },

	-- Kaland
	{ id = 'swim_500',        category = 'adventure', tier = 'bronze', icon = 'swim',      title = 'Csobbanás',          desc = 'Ússz 500 métert.',                                  stat = 'swim',      goal = 500 },
	{ id = 'swim_10',         category = 'adventure', tier = 'gold',   icon = 'swim',      title = 'Hosszútávúszó',      desc = 'Ússz 10 km-t.',                                     stat = 'swim',      goal = 10000 },
	{ id = 'dive_20',         category = 'adventure', tier = 'silver', icon = 'anchor',    title = 'Búvárkodás',         desc = 'Merülj 20 méter mélyre.',                           stat = 'depth',     goal = 20 },
	{ id = 'dive_60',         category = 'adventure', tier = 'gold',   icon = 'anchor',    title = 'A mélység hívása',   desc = 'Merülj 60 méter mélyre.',                           stat = 'depth',     goal = 60 },
	{ id = 'parachute_1',     category = 'adventure', tier = 'bronze', icon = 'parachute', title = 'Ugrás a semmibe',    desc = 'Nyiss ki egy ejtőernyőt.',                          stat = 'parachute', goal = 1 },
	{ id = 'parachute_25',    category = 'adventure', tier = 'gold',   icon = 'parachute', title = 'Adrenalinfüggő',     desc = 'Nyiss ki 25-ször ejtőernyőt.',                      stat = 'parachute', goal = 25 },
	{ id = 'jumps_500',       category = 'adventure', tier = 'silver', icon = 'jump',      title = 'Rugós talpak',       desc = 'Ugorj 500-at.',                                     stat = 'jumps',     goal = 500 },
	{ id = 'jumps_5000',      category = 'adventure', tier = 'gold',   icon = 'jump',      title = 'Gravitáció? Az mi?', desc = 'Ugorj 5 000-et.',                                   stat = 'jumps',     goal = 5000 },
	{ id = 'deaths_25',       category = 'adventure', tier = 'silver', icon = 'skull',     title = 'Kilenc élet kevés',  desc = 'Halj meg 25-ször.',                                 stat = 'deaths',    goal = 25 },
	{ id = 'deaths_100',      category = 'adventure', tier = 'gold',   icon = 'ghost',     title = 'Visszajáró lélek',   desc = 'Halj meg 100-szor.',                                stat = 'deaths',    goal = 100, hidden = true },

	-- Idő és hűség
	{ id = 'play_1h',         category = 'time', tier = 'bronze', icon = 'hourglass', title = 'Ismerkedés',           desc = 'Tölts 1 órát a szerveren.',                         stat = 'playtime',    goal = 3600 },
	{ id = 'play_10h',        category = 'time', tier = 'bronze', icon = 'hourglass', title = 'Beköltöző',            desc = 'Tölts 10 órát a szerveren.',                        stat = 'playtime',    goal = 36000 },
	{ id = 'play_50h',        category = 'time', tier = 'silver', icon = 'clock',     title = 'Törzsvendég',          desc = 'Tölts 50 órát a szerveren.',                        stat = 'playtime',    goal = 180000 },
	{ id = 'play_150h',       category = 'time', tier = 'gold',   icon = 'clock',     title = 'Lakos',                desc = 'Tölts 150 órát a szerveren.',                       stat = 'playtime',    goal = 540000 },
	{ id = 'play_500h',       category = 'time', tier = 'legend', icon = 'crown',     title = 'Városi legenda',       desc = 'Tölts 500 órát a szerveren.',                       stat = 'playtime',    goal = 1800000 },
	{ id = 'session_4h',      category = 'time', tier = 'silver', icon = 'coffee',    title = 'Hosszú műszak',        desc = 'Maradj 4 órát egyhuzamban a szerveren.',            stat = 'session_max', goal = 14400 },
	{ id = 'session_8h',      category = 'time', tier = 'gold',   icon = 'hourglass', title = 'Maratoni műszak',      desc = 'Maradj 8 órát egyhuzamban a szerveren.',            stat = 'session_max', goal = 28800 },
	{ id = 'days_7',          category = 'time', tier = 'bronze', icon = 'calendar',  title = 'Egy hét a városban',   desc = 'Lépj be 7 különböző napon.',                        stat = 'days',        goal = 7 },
	{ id = 'days_30',         category = 'time', tier = 'silver', icon = 'calendar',  title = 'Havi bérlet',          desc = 'Lépj be 30 különböző napon.',                       stat = 'days',        goal = 30 },
	{ id = 'days_100',        category = 'time', tier = 'gold',   icon = 'calendar',  title = 'Száz nap',             desc = 'Lépj be 100 különböző napon.',                      stat = 'days',        goal = 100 },
	{ id = 'days_365',        category = 'time', tier = 'legend', icon = 'calendar',  title = 'Egy év a városban',    desc = 'Lépj be 365 különböző napon.',                      stat = 'days',        goal = 365 },
	{ id = 'streak_3',        category = 'time', tier = 'bronze', icon = 'flame',     title = 'Visszatérő',           desc = 'Lépj be 3 egymást követő napon.',                   stat = 'streak_max',  goal = 3 },
	{ id = 'streak_7',        category = 'time', tier = 'silver', icon = 'flame',     title = 'Megszakítás nélkül',   desc = 'Lépj be 7 egymást követő napon.',                   stat = 'streak_max',  goal = 7 },
	{ id = 'streak_14',       category = 'time', tier = 'gold',   icon = 'flame',     title = 'Két hét egyhuzamban',  desc = 'Lépj be 14 egymást követő napon.',                  stat = 'streak_max',  goal = 14 },
	{ id = 'streak_30',       category = 'time', tier = 'legend', icon = 'flame',     title = 'Hűséges lakos',        desc = 'Lépj be 30 egymást követő napon.',                  stat = 'streak_max',  goal = 30 },
	{ id = 'midnight_1',      category = 'time', tier = 'silver', icon = 'moon',      title = 'Éjféli bagoly',        desc = 'Légy fent a szerveren éjfélkor.',                   stat = 'midnights',   goal = 1 },
	{ id = 'midnight_25',     category = 'time', tier = 'gold',   icon = 'moonstar',  title = 'Éjszakai műszak',      desc = 'Légy fent a szerveren 25 éjfélkor.',                stat = 'midnights',   goal = 25 },
	{ id = 'dawn_1',          category = 'time', tier = 'gold',   icon = 'sunrise',   title = 'Álmatlan hajnal',      desc = 'Légy fent a szerveren hajnali 4-kor.',              stat = 'dawns',       goal = 1, hidden = true },
	{ id = 'newyear',         category = 'time', tier = 'legend', icon = 'confetti',  title = 'Boldog új évet!',      desc = 'Légy fent a szerveren szilveszter éjfélkor.',       stat = 'newyears',    goal = 1, hidden = true },

	-- Karrier
	{ id = 'jobs_5',          category = 'career', tier = 'silver', icon = 'briefcase', title = 'Sokoldalú',           desc = 'Próbálj ki 5 különböző munkát.',                    stat = 'jobs',      goal = 5 },
	{ id = 'job_mechanic',    category = 'career', tier = 'bronze', icon = 'wrench',    title = 'Csavarkulcs',         desc = 'Dolgozz szerelőként egy műhelyben.',                jobs = 'mechanic' },
	{ id = 'job_law',         category = 'career', tier = 'silver', icon = 'shield',    title = 'A törvény őre',       desc = 'Csatlakozz egy rendvédelmi szervhez.',              jobs = 'law' },
	{ id = 'job_ems',         category = 'career', tier = 'silver', icon = 'medkit',    title = 'Életmentő',           desc = 'Csatlakozz a mentőszolgálathoz.',                   jobs = 'ems' },
	{ id = 'job_fire',        category = 'career', tier = 'silver', icon = 'flame',     title = 'Lángok ellen',        desc = 'Csatlakozz a tűzoltósághoz.',                       jobs = 'fire' },
	{ id = 'job_legal',       category = 'career', tier = 'silver', icon = 'gavel',     title = 'Paragrafusok',        desc = 'Dolgozz az államnál vagy az ügyvédi kamaránál.',    jobs = 'legal' },
	{ id = 'job_boss',        category = 'career', tier = 'gold',   icon = 'crown',     title = 'A főnök',             desc = 'Érd el egy frakció legmagasabb rangját.',           boss = true },
	{ id = 'paycheck_50',     category = 'career', tier = 'silver', icon = 'coins',     title = 'Megbízható munkaerő', desc = 'Kapj 50 fizetést.',                                 stat = 'paychecks', goal = 50 },
	{ id = 'paycheck_250',    category = 'career', tier = 'gold',   icon = 'coins',     title = 'Veterán dolgozó',     desc = 'Kapj 250 fizetést.',                                stat = 'paychecks', goal = 250 },

	-- Bank ladder. Tiers follow how many players active in the last 30 days already had the balance
	-- (live database, 2026-09-15): 1M 84%, 10M 57%, 100M 27%, 1B 8.3%, 5B 1.4%, 10B 0.45%.
	-- noFirst: the balances existed before this resource, so a first would only reflect login order.
	{ id = 'bank_100k',       category = 'career', tier = 'bronze', icon = 'piggy',     title = 'Megtakarítás',        desc = 'Legyen 100 000 $ a bankszámládon.',                 stat = 'bank_max',  goal = 100000,      noFirst = true },
	{ id = 'bank_1m',         category = 'career', tier = 'bronze', icon = 'cash',      title = 'Milliomos',           desc = 'Legyen 1 000 000 $ a bankszámládon.',               stat = 'bank_max',  goal = 1000000,     noFirst = true },
	{ id = 'bank_10m',        category = 'career', tier = 'bronze', icon = 'coins',     title = 'Tízmilliomos',        desc = 'Legyen 10 000 000 $ a bankszámládon.',              stat = 'bank_max',  goal = 10000000,    noFirst = true },
	{ id = 'bank_50m',        category = 'career', tier = 'bronze', icon = 'bank',      title = 'Vagyonos',            desc = 'Legyen 50 000 000 $ a bankszámládon.',              stat = 'bank_max',  goal = 50000000,    noFirst = true },
	{ id = 'bank_100m',       category = 'career', tier = 'bronze', icon = 'diamond',   title = 'Százmilliomos',       desc = 'Legyen 100 000 000 $ a bankszámládon.',             stat = 'bank_max',  goal = 100000000,   noFirst = true },
	{ id = 'bank_200m',       category = 'career', tier = 'silver', icon = 'chart',     title = 'Befektető',           desc = 'Legyen 200 000 000 $ a bankszámládon.',             stat = 'bank_max',  goal = 200000000,   noFirst = true },
	{ id = 'bank_400m',       category = 'career', tier = 'silver', icon = 'briefcase', title = 'Nagytőkés',           desc = 'Legyen 400 000 000 $ a bankszámládon.',             stat = 'bank_max',  goal = 400000000,   noFirst = true },
	{ id = 'bank_600m',       category = 'career', tier = 'silver', icon = 'building',  title = 'Mágnás',              desc = 'Legyen 600 000 000 $ a bankszámládon.',             stat = 'bank_max',  goal = 600000000,   noFirst = true },
	{ id = 'bank_800m',       category = 'career', tier = 'silver', icon = 'key',       title = 'Kincstárnok',         desc = 'Legyen 800 000 000 $ a bankszámládon.',             stat = 'bank_max',  goal = 800000000,   noFirst = true },
	{ id = 'bank_1b',         category = 'career', tier = 'gold',   icon = 'star',      title = 'Milliárdos',          desc = 'Legyen 1 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 1000000000,  noFirst = true },
	{ id = 'bank_2b',         category = 'career', tier = 'gold',   icon = 'diamond',   title = 'Kétmilliárdos',       desc = 'Legyen 2 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 2000000000,  noFirst = true },
	{ id = 'bank_3b',         category = 'career', tier = 'gold',   icon = 'diamond',   title = 'Hárommilliárdos',     desc = 'Legyen 3 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 3000000000,  noFirst = true },
	{ id = 'bank_4b',         category = 'career', tier = 'gold',   icon = 'diamond',   title = 'Négymilliárdos',      desc = 'Legyen 4 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 4000000000,  noFirst = true },
	{ id = 'bank_5b',         category = 'career', tier = 'gold',   icon = 'crown',     title = 'Ötmilliárdos',        desc = 'Legyen 5 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 5000000000,  noFirst = true },
	{ id = 'bank_6b',         category = 'career', tier = 'gold',   icon = 'crown',     title = 'Hatmilliárdos',       desc = 'Legyen 6 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 6000000000,  noFirst = true },
	{ id = 'bank_7b',         category = 'career', tier = 'gold',   icon = 'crown',     title = 'Hétmilliárdos',       desc = 'Legyen 7 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 7000000000,  noFirst = true },
	{ id = 'bank_8b',         category = 'career', tier = 'gold',   icon = 'crown',     title = 'Nyolcmilliárdos',     desc = 'Legyen 8 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 8000000000,  noFirst = true },
	{ id = 'bank_9b',         category = 'career', tier = 'gold',   icon = 'crown',     title = 'Kilencmilliárdos',    desc = 'Legyen 9 000 000 000 $ a bankszámládon.',           stat = 'bank_max',  goal = 9000000000,  noFirst = true },
	{ id = 'bank_10b',        category = 'career', tier = 'legend', icon = 'trophy',    title = 'Tízmilliárdos',       desc = 'Legyen 10 000 000 000 $ a bankszámládon.',          stat = 'bank_max',  goal = 10000000000, noFirst = true },

	-- Küldetések: the task rewards of this resource, the legal jobs (bc:legalQuestDoProgress) and the
	-- robberies (bc:questDone). Everybody starts these at zero, so their server firsts are a fair race.
	{ id = 'task_1',          category = 'missions', tier = 'bronze', icon = 'gift',         title = 'Első jutalom',        desc = 'Vegyél át egy küldetés-jutalmat.',                  stat = 'tasks',           goal = 1 },
	{ id = 'task_50',         category = 'missions', tier = 'silver', icon = 'gift',         title = 'Szavatartó',          desc = 'Vegyél át 50 küldetés-jutalmat.',                   stat = 'tasks',           goal = 50 },
	{ id = 'task_250',        category = 'missions', tier = 'gold',   icon = 'gift',         title = 'Küldetésvadász',      desc = 'Vegyél át 250 küldetés-jutalmat.',                  stat = 'tasks',           goal = 250 },
	{ id = 'task_1000',       category = 'missions', tier = 'legend', icon = 'gift',         title = 'Küldetések mestere',  desc = 'Vegyél át 1 000 küldetés-jutalmat.',                stat = 'tasks',           goal = 1000 },
	{ id = 'weekly_10',       category = 'missions', tier = 'silver', icon = 'calendarWeek', title = 'Hétről hétre',        desc = 'Vegyél át 10 heti küldetés-jutalmat.',              stat = 'tasks_weekly',    goal = 10 },
	{ id = 'weekly_50',       category = 'missions', tier = 'gold',   icon = 'calendarWeek', title = 'Heti rutin',          desc = 'Vegyél át 50 heti küldetés-jutalmat.',              stat = 'tasks_weekly',    goal = 50 },
	{ id = 'permanent_1',     category = 'missions', tier = 'gold',   icon = 'star',         title = 'Örök érvényű',        desc = 'Vegyél át egy örökös küldetés-jutalmat.',           stat = 'tasks_permanent', goal = 1 },
	{ id = 'work_1',          category = 'missions', tier = 'bronze', icon = 'wrench',       title = 'Kétkezi munka',       desc = 'Végezz el egy feladatot egy legális munkában.',     stat = 'work',            goal = 1 },
	{ id = 'work_100',        category = 'missions', tier = 'silver', icon = 'wrench',       title = 'Szorgos kezek',       desc = 'Végezz el 100 feladatot legális munkákban.',        stat = 'work',            goal = 100 },
	{ id = 'work_1000',       category = 'missions', tier = 'gold',   icon = 'wrench',       title = 'Munkagép',            desc = 'Végezz el 1 000 feladatot legális munkákban.',      stat = 'work',            goal = 1000 },
	{ id = 'worktypes_3',     category = 'missions', tier = 'silver', icon = 'briefcase',    title = 'Szakmák útján',       desc = 'Dolgozz 3 különböző legális munkában.',             stat = 'work_types',      goal = 3 },
	{ id = 'worktypes_7',     category = 'missions', tier = 'gold',   icon = 'briefcase',    title = 'Ezermester',          desc = 'Dolgozz 7 különböző legális munkában.',             stat = 'work_types',      goal = 7 },
	{ id = 'rob_1',           category = 'missions', tier = 'bronze', icon = 'skull',        title = 'Első balhé',          desc = 'Hajts végre egy rablást.',                          stat = 'robberies',       goal = 1 },
	{ id = 'rob_25',          category = 'missions', tier = 'gold',   icon = 'skull',        title = 'Rutinos rabló',       desc = 'Hajts végre 25 rablást.',                           stat = 'robberies',       goal = 25 },
	{ id = 'robtypes_5',      category = 'missions', tier = 'gold',   icon = 'key',          title = 'Minden zár nyílik',   desc = 'Hajts végre 5 különböző fajta rablást.',            stat = 'robbery_types',   goal = 5 },

	-- Mérföldkövek
	{ id = 'unlock_10',       category = 'legacy', tier = 'bronze', icon = 'medal',  title = 'Gyűjtögető',       desc = 'Oldj fel 10 teljesítményt.',                      stat = 'unlocks', goal = 10,   noFirst = true },
	{ id = 'unlock_25',       category = 'legacy', tier = 'silver', icon = 'medal',  title = 'Trófeavadász',     desc = 'Oldj fel 25 teljesítményt.',                      stat = 'unlocks', goal = 25,   noFirst = true },
	{ id = 'unlock_50',       category = 'legacy', tier = 'gold',   icon = 'trophy', title = 'Trófeagyűjtő',     desc = 'Oldj fel 50 teljesítményt.',                      stat = 'unlocks', goal = 50,   noFirst = true },
	{ id = 'unlock_75',       category = 'legacy', tier = 'legend', icon = 'trophy', title = 'Élő legenda',      desc = 'Oldj fel 75 teljesítményt.',                      stat = 'unlocks', goal = 75,   noFirst = true },
	{ id = 'unlock_100',      category = 'legacy', tier = 'legend', icon = 'trophy', title = 'Gyűjtőszenvedély', desc = 'Oldj fel 100 teljesítményt.',                     stat = 'unlocks', goal = 100,  noFirst = true },
	{ id = 'points_1000',     category = 'legacy', tier = 'gold',   icon = 'star',   title = 'Ezer pont',        desc = 'Gyűjts 1 000 teljesítménypontot.',                stat = 'points',  goal = 1000, noFirst = true },
	{ id = 'points_2500',     category = 'legacy', tier = 'legend', icon = 'star',   title = 'Pontkirály',       desc = 'Gyűjts 2 500 teljesítménypontot.',                stat = 'points',  goal = 2500, noFirst = true },
	{ id = 'first_1',         category = 'legacy', tier = 'gold',   icon = 'flag',   title = 'Úttörő',           desc = 'Teljesíts elsőként valamit a szerveren.',         stat = 'firsts',  goal = 1,    noFirst = true },
	{ id = 'first_5',         category = 'legacy', tier = 'legend', icon = 'crown',  title = 'Mindig az első',   desc = 'Szerezz 5 szerver-első teljesítményt.',           stat = 'firsts',  goal = 5,    noFirst = true },
}
