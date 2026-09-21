-- ! ███████╗██╗██╗   ██╗███████╗███████╗████████╗ █████╗ ██████╗ 
-- ! ██╔════╝██║██║   ██║██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗
-- ! █████╗  ██║██║   ██║█████╗  ███████╗   ██║   ███████║██████╔╝
-- ! ██╔══╝  ██║╚██╗ ██╔╝██╔══╝  ╚════██║   ██║   ██╔══██║██╔══██╗
-- ! ██║     ██║ ╚████╔╝ ███████╗███████║   ██║   ██║  ██║██║  ██║
-- ! ╚═╝     ╚═╝  ╚═══╝  ╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝
-- ! 		   Copyright ® 2023 Lorem All rights FiveStar
-- ! 		      5star.tebex.io | Discord/HdEzqEJBdh
Config = {}

-- * If an update is released for the script, it will not allow the script to start and will cause the server to shut down
Config.CheckVersion = true

Config.Location = {
    [1] = {
        Coords = vector4(253.34117, -760.935, 34.641967, 163.94244),
        Name = "Fő publik",
        Description = "A város szíve",
        Image = "public.webp"
    },
    [2] = {
        Coords = vector4(-803.3491, -2355.489, 14.63182, 241.38693),
        Name = "Autós piac",
        Description = "A kereskedők otthona",
        Image = "piac.webp"
    },
    [3] = {
        Coords = vector4(112.68743, 6597.5136, 32.132909, 201.03),
        Name = "Paleto publik",
        Description = "Kis chill a városon kívül",
        Image = "paleto.webp"
    },
    [4] = {
        Coords = vector4(1737.9691, 3727.5141, 33.9379909, 201.03),
        Name = "Sandy publik",
        Description = "Irány a sivatag",
        Image = "sandy.webp"
    }
}

Config.LastLocation = {
    Name = "Utolsó helyszín",
    Description = "Az utolsó hely, ahol tartózkodtál",
    MiniTxt = "fő"
}

-- A választó beépített GTA hangjai: { hangnév, hangkészlet } (PlaySoundFrontend).
-- Egy sort kikommentelve az a hang elnémul.
-- A ráhúzás és a kiválasztás hangja saját fájl: ui/sounds/rahuzod.mp3 és kivalasztod.mp3
-- (azokat a NUI játssza le; a hangerejüket a játékos a Testreszabás menüben állítja).
Config.UiSounds = {
    open   = { "Hit_Out", "PLAYER_SWITCH_CUSTOM_SOUNDSET" },              -- megnyílik a választó (a kamera fent az égen)
    -- nav    = { "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET" },    -- helyette: ui/sounds/kivalasztod.mp3
    -- select = { "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET" },            -- helyette: ui/sounds/kivalasztod.mp3
    deny   = { "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET" },                -- zárolt helyre kattintás
    travel = { "Short_Transition_Out", "PLAYER_SWITCH_CUSTOM_SOUNDSET" }, -- elsötétül, indul a töltés
    switch = { "Short_Transition_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET" },  -- a kamera leereszkedik a helyszínre
    arrive = { "Hit_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET" },               -- megérkeztél, visszakapod az irányítást
}

-- Rövid GTA képernyő-effekt nyitáskor és érkezéskor (animpostfx); nil = nincs effekt
Config.UiEffect = { name = "SwitchHUDIn", duration = 300 }

-- A választó háttere: élő játékkamera a város fölött (mindig éles, bármilyen felbontáson).
-- A választó alatt CSAK ennél a játékosnál éjszaka és tiszta idő van; a töltésnél visszaáll.
-- enabled = false -> a NUI háttérképe (ui/images/hatter.webp) látszik helyette.
Config.BackgroundCam = {
    enabled = true,
    coords  = vector3(-120.0, -1900.0, 650.0), -- kamera helye (délről, a belváros előtt, magasan)
    rot     = vector3(-34.0, 0.0, -8.0),       -- dőlés (negatív = lefelé néz), billenés, irány (0 = észak)
    fov     = 50.0,
    focus   = vector3(-60.0, -850.0, 40.0),    -- ide töltődik be részletesen a város (belváros)
    hour    = 23, minute = 30,                 -- helyi idő a választó alatt (nil = marad a szerveré)
    weather = "CLEAR",                         -- helyi időjárás a választó alatt (nil = marad)
    drag      = true,                          -- nyomva tartott egérrel forgatható a város (a kép közepe körül)
    dragSpeed = 0.12,                          -- érzékenység: fok / képpont
    minPitch  = -80.0, maxPitch = -12.0,       -- meddig dönthető (-80 = szinte felülnézet, -12 = majdnem vízszintes)
    zoomSpeed = 0.0012,                        -- görgő érzékenysége (egy kattanás kb. 12% közelebb/messzebb)
    minDist   = 300.0, maxDist = 2500.0,       -- legközelebb / legmesszebb a kép közepétől (méter)
    minHeight = 250.0,                         -- a kamera legalább ilyen magasan marad (ne menjen a tornyok közé)
    -- beállítás-segéd (élesen legyen false):
    --   /spawnkamera -> a mostani nézet adatait config-sorként az F8 konzolba írja (noclip/freecam után)
    --   /spawnhatter -> 15 mp-ig megmutatja a háttér-kamerát a fenti beállítással
    debug   = false,
}