Config = {}

Config.FFAs = {
    {
        Name = "Minden fegyveres FFA Téttel, 30k$/halál",
        Coords = vector3(4062.749, 19.19011, 42.65364),
        Range = 200.0,
        SpawnPoints = {
            vector3(4062.749, 15.19011, 43.95364),
            vector3(4075.749, 19.19011, 43.95364),
        },
        SpawnTime = 2000,
        Weapons = {
            `WEAPON_KNIFE`,
            `WEAPON_APPISTOL`,
            `WEAPON_ASSAULTRIFLE`,
            `WEAPON_MICROSMG`,
        },
        BetPerLife = 30000
    },
    {
        Name = "AP Pistol FFA Téttel, 30k$/halál",
        Coords = vector3(3222.01, -127.3112, 1386.5584),
        Range = 200.0,
        SpawnPoints = {
            vector3(3222.01, -127.3112, 1387.5584),
            vector3(3222.01, -125.3112, 1387.5584),
            vector3(3222.01, -130.3112, 1387.5584),
        },
        SpawnTime = 2000,
        Weapons = {
            `WEAPON_KNIFE`,
            `WEAPON_APPISTOL`,
        },
        FallOut = true,
        BetPerLife = 30000
    },
    {
        Name = "Pistol Rámpák",
        Coords = vector3(-2100.0312, -1788.0159, 650.9290),
        Range = 100.0,
        SpawnPoints = {
            vector3(-2103.9771, -1796.8651, 645.9204),
            vector3(-2103.6333, -1797.8767, 655.9295),
            vector3(-2099.6699, -1779.4414, 651.1330),
            vector3(-2096.8264, -1781.9287, 640.9147),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_HEAVYPISTOL',
            'WEAPON_PISTOL',
            'WEAPON_PISTOL_MK2',
        },
        FallOut = true
    },
    {
        Name = "Pistol Rámpák V2",
        Coords = vector3(-3353.2354, -813.8094, 102.6334),
        Range = 100.0,
        SpawnPoints = {
            vector3(-3353.5364, -815.8737, 102.6333),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_HEAVYPISTOL',
            'WEAPON_PISTOL',
            'WEAPON_PISTOL_MK2',
        },
        FallOut = true
    },
    {
        Name = "Nagykali Rámpák Téttel, 30k$/halál",
        Coords = vector3(-2912.6274, -1034.4459, 101.0002),
        Range = 100.0,
        SpawnPoints = {
            vector3(-2913.3230, -1024.5481, 101.0002),
            vector3(-2913.9448, -1048.1384, 101.0002),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_SPECIALCARBINE',
            'WEAPON_SPECIALCARBINE_MK2',
            'WEAPON_TACTICALRIFLE',
        },
        FallOut = true,
        BetPerLife = 30000
    },
    {
        Name = "OneTap Aréna",
        Coords = vector3(5367.0469, -1106.3682, 357.5930),
        Range = 220.0,
        SpawnPoints = {
            vector3(5406.1582, -1101.6439, 355.2099),
            vector3(5410.2114, -1113.5693, 358.4356),
            vector3(5386.8672, -1155.9111, 355.2094),
            vector3(5327.2520, -1154.9930, 355.2091),
            vector3(5307.5801, -1084.2496, 355.2091),
            vector3(5331.6465, -1055.2963, 355.2091),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_NAVYREVOLVER',
            'WEAPON_DOUBLEACTION',
            'WEAPON_GADGETPISTOL',
        },
        FallOut = true
    },
    {
        Name = "P90 Towerek",
        Coords = vector3(4065.9116, -2.3286, 195.9935),
        Range = 100.0,
        SpawnPoints = {
            vector3(4107.4956, 0.0798, 195.9935),
            vector3(3992.9309, -0.9725, 195.9923),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_ASSAULTSMG',
        },
        FallOut = true
    },
    {
        Name = "AP Nagy Aréna",
        Coords = vector3(-149.2349, -4348.5771, 191.5013),
        Range = 100.0,
        SpawnPoints = {
            vector3(-195.9929, -4368.0596, 191.5012),
            vector3(-195.8251, -4328.2090, 191.5012),
            vector3(-96.3559, -4327.9961, 191.5005),
            vector3(-97.3017, -4368.2417, 191.5012),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_APPISTOL',
        },
        FallOut = true
    },
    {
        Name = "Pistol Fortniteos",
        Coords = vector3(4400.9795, 2809.7500, 548.1950),
        Range = 100.0,
        SpawnPoints = {
            vector3(4422.5234, 2820.6243, 549.1684),
            vector3(4384.2466, 2809.8276, 549.1682),
            vector3(4418.6138, 2772.1226, 549.3312),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_PISTOL50',
            'WEAPON_VINTAGEPISTOL',
        },
        FallOut = true
    },
    {
        Name = "MiniSMG Warzoneos",
        Coords = vector3(4014.5117, 1311.2064, 678.6651),
        Range = 100.0,
        SpawnPoints = {
            vector3(3999.6384, 1336.5453, 679.9691),
            vector3(4036.2651, 1282.6371, 680.0492),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_MINISMG',
        },
        FallOut = true
    },
    {
        Name = "Shotgun Game",
        Coords = vector3(4277.2622, 1484.4078, 678.6669),
        Range = 100.0,
        SpawnPoints = {
            vector3(4260.5679, 1492.8325, 679.6404),
            vector3(4299.0537, 1459.5983, 679.6336),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_PUMPSHOTGUN',
        },
        FallOut = true
    },
    --[[{
        Name = "Muskétás Nyalóka",
        Coords = vector3(-3545.0081, 1360.2357, 310.8942),
        Range = 100.0,
        SpawnPoints = {
            vector3(-3544.0449, 1371.1405, 315.1303),
            vector3(-3543.1187, 1350.4193, 315.1306),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_MUSKET',
        },
        FallOut = true
    },]]
    {
        Name = "Dust 2",
        Coords = vector3(-3180.3472, -349.8619, 555.3407),
        Range = 100.0,
        SpawnPoints = {
            vector3(-3180.8027, -364.3129, 556.5305),
            vector3(-3180.0356, -330.5692, 556.5299),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_TECPISTOL',
        },
        FallOut = true
    },
    {
        Name = "Sniper Placc",
        Coords = vector3(1831.8828, -3153.7673, 399.5186),
        Range = 150.0,
        SpawnPoints = {
            vector3(1859.1968, -3110.0020, 403.2083),
            vector3(1805.2704, -3108.5833, 403.2672),
            vector3(1854.9252, -3183.2742, 403.2092),
            vector3(1804.9323, -3183.8936, 403.2261),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_PRECISIONRIFLE',
        },
        FallOut = true
    },
    {
        Name = "PDW Platform",
        Coords = vector3(-2560.6807, -1408.0283, 419.5103),
        Range = 150.0,
        SpawnPoints = {
            vector3(-2563.8782, -1439.9537, 422.6179),
            vector3(-2564.2188, -1370.1044, 422.6423),
            vector3(-2512.3838, -1371.1235, 421.7009),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_COMBATPDW',
        },
        FallOut = true
    },
    {
        Name = "Lego AWP",
        Coords = vector3(-2360.9785, -1153.1781, 329.4494),
        Range = 100.0,
        SpawnPoints = {
            vector3(-2374.1655, -1155.0146, 328.6613),
            vector3(-2346.2532, -1154.1714, 328.6607),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_SNIPERRIFLE',
        },
        FallOut = true
    },
    {
        Name = "Késelős Minecraft",
        Coords = vector3(-1951.1775, -1503.5642, 320.8734),
        Range = 100.0,
        SpawnPoints = {
            vector3(-1938.2784, -1504.5885, 321.0604),
            vector3(-1963.2646, -1503.1406, 321.0603),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_SWITCHBLADE',
            'WEAPON_KNIFE',
        },
        FallOut = true
    },
    {
        Name = "Piros Neon",
        Coords = vector3(-2442.2896, -1807.2855, 100.3661),
        Range = 150.0,
        SpawnPoints = {
            vector3(-2410.5596, -1827.7144, 100.3631),
            vector3(-2478.0896, -1788.4475, 100.3521),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_APPISTOL',
            'WEAPON_MACHINEPISTOL',
            'WEAPON_MICROSMG',
        },
        FallOut = true
    },
    {
        Name = "Pink Neon",
        Coords = vector3(-230.7114, -3397.4639, 558.4603),
        Range = 150.0,
        SpawnPoints = {
            vector3(-189.6757, -3395.0537, 558.3040),
            vector3(-276.6762, -3396.5544, 558.4564),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_APPISTOL',
            'WEAPON_MACHINEPISTOL',
            'WEAPON_MICROSMG',
        },
        FallOut = true
    },
    {
        Name = "Sárga Neon",
        Coords = vector3(-2174.8250, -2369.4927, 500.7294),
        Range = 150.0,
        SpawnPoints = {
            vector3(-2129.8062, -2365.8169, 500.7267),
            vector3(-2219.9604, -2368.1216, 500.6814),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_APPISTOL',
            'WEAPON_MACHINEPISTOL',
            'WEAPON_MICROSMG',
        },
        FallOut = true
    },
    {
        Name = "Aqua Neon",
        Coords = vector3(-3199.8311, -479.6236, 318.8808),
        Range = 150.0,
        SpawnPoints = {
            vector3(-3243.8552, -474.1602, 318.8814),
            vector3(-3168.3176, -475.5847, 318.8763),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_APPISTOL',
            'WEAPON_MACHINEPISTOL',
            'WEAPON_MICROSMG',
        },
        FallOut = true
    },
    {
        Name = "Pistol Wager",
        Coords = vector3(-2583.8540, -2223.8979, 1271.5992),
        Range = 150.0,
        SpawnPoints = {
            vector3(-2602.2432, -2198.5391, 1271.6630),
            vector3(-2565.4331, -2197.4854, 1271.6584),
            vector3(-2611.7993, -2260.0962, 1267.6499),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_HEAVYPISTOL',
            'WEAPON_PISTOL',
            'WEAPON_PISTOL_MK2',
        },
        FallOut = true
    },
    {
        Name = "Bolide",
        Coords = vector3(-2769.396, 2512.7299, 2.7173528),
        Range = 150.0,
        SpawnPoints = {
            vector3(-2781.539, 2515.7478, 2.7375519),
            vector3(-2764.62, 2512.5363, 2.7445523),
            vector3(-2760.042, 2521.5461, 2.683458),
        },
        SpawnTime = 2000,
        Weapons = {
            'WEAPON_HEAVYPISTOL',
            'WEAPON_PISTOL',
            'WEAPON_PISTOL_MK2',
        },
        FallOut = true,
        Vehicle = `dtdbolide`
    },
}

Config.EnterCoords = vector4(124.60644, 6624.2021, 30.815013, 225.75895)
