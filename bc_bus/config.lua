Config = {}

Config.pedModel = `a_f_m_bevhills_01`
Config.busModel = "bcbus"
Config.Levels = { -- [level] = {xp = 50, multiplier = 1.0}
    [1] = {
        minXP = 0,
        multiplier = 1.0
    },
    [2] = {
        minXP = 50,
        multiplier = 1.1
    },
    [3] = {
        minXP = 100,
        multiplier = 1.2
    },
    [4] = {
        minXP = 150,
        multiplier = 1.3
    },
    [5] = {
        minXP = 200,
        multiplier = 1.4
    },
    [6] = {
        minXP = 250,
        multiplier = 1.5
    },
    [7] = {
        minXP = 300,
        multiplier = 2.0
    },
    [8] = {
        minXP = 350,
        multiplier = 2.2
    },
    [9] = {
        minXP = 400,
        multiplier = 2.5
    },
    [10] = {
        minXP = 450,
        multiplier = 3.0
    },
}

Config.translations = {
    ["startjob"] = "Menü megnyitása",
    ["endjob"] = "[E] - Munka befejezése",
    ["notincar"] = "Nem vagy járműben!",
    ["notservicecar"] = "Nem szolgálati jármű!",
    ["canspawnservice"] =
    "Nem tudsz lehívni szolgálati járművet, sétálj a leadási pontba fejezd be a munkát és kezd újra!",
    ["notinservicecar"] = "Nem veheted fel ebben az utasokat! Nem szolgálati a te járműved!",
    ["waitforpassengers"] = "Várd meg míg felszállnak az utasok!",
    ["passengersboarding"] = "Felszállnak az utasok...",
    ["passengersboarded"] = "Az utasok felszálltak indulhatsz!",
    ["nomorestops"] = "Végeztél az összes megállóval, indulj vissza a pályaudvarra",
    ["lib_title"] = "Buszos munka",
    ["startjoblib"] = "Munka elkezdése",
    ["currenlevel"] = "Jelenlegi szint: %s",
    ["tonextlevel"] = "Következő szintig %s XP kell."

}

Config.blipSettings = {
    color = 33,
    sprite = 513,
    size = 0.8,
    busstop = {
        label = "Megálló",
        color = 57,
        sprite = 480,
        size = 0.8
    }
}

Config.busStations = {
    [1] = {
        label = "Buszállomás",
        pedCoords = vec(977.54797, -1500.153, 30.370071, 91.103721),
        spawnPoint = vec(970.91137, -1499.786, 31.280958, 0.9201992),
        deleteCars = { coords = vec(970.91137, -1499.786, 31.280958, 2.8935375), rotation = 90, size = vec3(5, 20, 5) },
        busStops = {
            [1] = { coords = vec(307.4201, -763.5170, 29.2029, 157.0227), done = false },
            [2] = { coords = vec(116.0271, -784.8989, 31.3076, 73.8565), done = false },
            [3] = { coords = vec(-271.0628, -823.1900, 31.7330, 338.2346), done = false },
            [4] = { coords = vec(-523.0645, -267.3224, 35.3076, 121.1547), done = false },
            [5] = { coords = vec(-930.8007, -125.7128, 37.5829, 110.8893), done = false },
            [6] = { coords = vec(-250.6056, -882.7994, 30.5995, 251.1977), done = false },
            [7] = { coords = vec(439.5895, -2030.7855, 23.4273, 229.1299), done = false },
            [8] = { coords = vec(807.4982, -1352.3506, 26.2484, 358.0927), done = false },
            [9] = { coords = vec(785.8290, -777.4388, 26.3257, 0.8813), done = false },
            [10] = { coords = vec(354.5258, -1064.3940, 29.4026, 268.5034), done = false }

        }
    }
}
