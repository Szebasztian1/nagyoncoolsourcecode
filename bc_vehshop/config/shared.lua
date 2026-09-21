Config = {}

Config.Locale = "hu" -- en, hu

--- How much the /kormolas toggle smokes during a test drive. 0-10, clamped by vms_tuning
--- to its own maxLevel. Local preview only — nothing is bought and nobody else sees it.
Config.TestKormolasLevel = 10

Config.Shops = {
    --[[   ["tester"] = {
        label = "Egyedi/Limit Tesztvezetés",
        coords = vector3(886.05004, -0.953823, 78.765045),
        outsidecoords = vector4(0.0, 0.0, 0.0, 0.0), --vector4(-50.93605, -1077.04, 26.908241, 71.600097)
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81), -- set false to disable testing
        testtime = 60*1000, --in ms
        showroom = vector4(-46.1, -1096.43, 26.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = false,
        enablebank = false,
        enablefaction = false,
        sell = false,
        blip = false,
        job = false,
        vehtype = "car",
    },--]]
    ["carshop"] = {
        label = "Autókereskedés",
        description = "Prémium autókereskedés. Vásárolj készpénzzel vagy bankból.",
        coords = vector4(-360.4041, -98.23502, 38.546573, 70.583992),
        outsidecoords = vector4(-376.9519, -142.6118, 38.685863, 294.65081), --vector4(-50.93605, -1077.04, 26.908241, 71.600097)
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81),              -- set false to disable testing
        testtime = 60 * 1000,                                                --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        sell = {
            coords = vector3(-365.9841, -108.5191, 38.68264),
            pricemultiplier = 0.35,
        },
        blip = { sprite = 225, color = 24 },
        job = false,
        vehtype = "car",
    },
    ["bmcarshop"] = {
        label = "Autókereskedés",
        description = "Black Mamba exkluzív autókereskedése.",
        coords = vector4(-361.0115, -99.90409, 38.546695, 67.022888),
        outsidecoords = vector4(-376.9519, -142.6118, 38.685863, 294.65081), --vector4(-50.93605, -1077.04, 26.908241, 71.600097)
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81),              -- set false to disable testing
        testtime = 60 * 1000,                                                --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        sell = {
            coords = vector3(-389.0895, -101.8882, 38.754467),
            pricemultiplier = 0.35,
        },
        job = false,
        management = {
            ["blackmamba"] = {
                "boss",
            },
        },
        vehtype = "car",
        safe = 408
    },
    ["bennyscarshop"] = {
        label = "Autókereskedés",
        description = "Benny's autókereskedése. Széles választék, remek árak.",
        coords = vector4(-202.9667, -1371.114, 29.590059, 92.661903),
        outsidecoords = vector4(-243.2709, -1371.612, 30.971338, 270.33358), --vector4(-50.93605, -1077.04, 26.908241, 71.600097)
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81),              -- set false to disable testing
        testtime = 60 * 1000,                                                --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        sell = {
            coords = vector3(-894.3497, -2034.085, 9.2994098),
            pricemultiplier = 0.35,
        },
        blip = { sprite = 225, color = 24 },
        job = false,
        management = {
            ["bennysservice"] = {
                "boss",
            },
        },
        vehtype = "car",
        safe = 2851
    },
    ["sonsofanarchy"] = {
        label = "Autókereskedés",
        description = "Gabee KFT autókereskedése. Széles választék, remek árak.",
        coords = vector4(-1105.769, -2035.508, 12.347587, 235.00854),
        outsidecoords = vector4(-1110.257, -2012.445, 13.179997, 286.78082), --vector4(-50.93605, -1077.04, 26.908241, 71.600097)
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81),              -- set false to disable testing
        testtime = 60 * 1000,                                                --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        sell = {
            coords = vector3(-894.3497, -2034.085, 9.2994098),
            pricemultiplier = 0.35,
        },
        blip = { sprite = 225, color = 24 },
        job = false,
        management = {
            ["sonsofanarchy"] = {
                "boss",
            },
        },
        vehtype = "car",
        safe = 3484
    },
    ["topgear"] = {
        label = "Autókereskedés",
        description = "Top Gear kereskedés – a legjobb sportautók egy helyen.",
        coords = vector4(94.122825, 6505.9887, 30.620349, 310.95166),
        outsidecoords = vector4(91.565628, 6559.5449, 31.620063, 312.98245), --vector4(-50.93605, -1077.04, 26.908241, 71.600097)
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81),              -- set false to disable testing
        testtime = 60 * 1000,                                                --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        sell = {
            coords = vector3(-894.3497, -2034.085, 9.2994098),
            pricemultiplier = 0.35,
        },
        blip = false,
        job = false,
        management = {
            ["topgear"] = {
                "boss",
            },
        },
        vehtype = "car",
        safe = 3187
    },
    ["ms13"] = {
        label = "Autókereskedés",
        description = "Danni – minőségi járművek elérhető áron.",
        coords = vector4(2741.7749, 3468.1584, 54.717227, 342.03897),
        outsidecoords = vector4(2777.2917, 3461.6755, 55.497478, 157.35102), --vector4(-50.93605, -1077.04, 26.908241, 71.600097) ahova meg vegye
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81),              -- set false to disable testing
        testtime = 60 * 1000,                                                --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        sell = {
            coords = vector3(-1380.789, -456.224, 34.47805),
            pricemultiplier = 0.35,
        },
        blip = { sprite = 225, color = 24 },
        job = false,
        management = {
            ["ms13"] = {
                "boss",
            },
        },
        vehtype = "car",
        safe = 3529
    },
    ["ujfrakciodawe3"] = {
        label = "Autókereskedés",
        description = "Exkluzív autókereskedés válogatott modellekkel.",
        coords = vector4(-65.58247, -1814.037, 26.358648, 138.80372),
        outsidecoords = vector4(-53.73785, -1835.262, 26.570074, 320.7138), --vector4(-50.93605, -1077.04, 26.908241, 71.600097) ahova meg vegye
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81),             -- set false to disable testing
        testtime = 60 * 1000,                                               --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        sell = {
            coords = vector3(-1380.789, -456.224, 34.47805),
            pricemultiplier = 0.35,
        },
        blip = { sprite = 225, color = 24 },
        job = false,
        management = {
            ["ujfrakciodawe3"] = {
                "boss",
            },
        },
        vehtype = "car",
        safe = 3107
    },
    ["moscar"] = {
        label = "Autókereskedés",
        description = "Exkluzív autókereskedés válogatott modellekkel.",
        coords = vector4(-3068.307, 458.30618, 5.9731197, 242.92562), --npc
        outsidecoords = vector4(-3051.728, 455.18157, 6.7827939, 151.442), --vector4(-50.93605, -1077.04, 26.908241, 71.600097) ahova meg vegye
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81),             -- set false to disable testing
        testtime = 60 * 1000,                                               --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        sell = {
            coords = vector3(-1380.789, -456.224, 34.47805),
            pricemultiplier = 0.35,
        },
        blip = { sprite = 225, color = 24 },
        job = false,
        management = {
            ["moscar"] = {
                "boss",
            },
        },
        vehtype = "car",
        safe = 3174
    },
    --[[["boatshop"] = {
        label = "Hajókereskedés",
        coords = vector3(-753.863708, -1511.775879, 4.016113),
        outsidecoords = vector4(-805.503296, -1504.958252, 0.912793, 104.881889),
        testcoords = vector4(-888.421997, -1565.841797, 0.112793, 144.566910), -- set false to disable testing
        testtime = 60*1000, --in ms
        showroom = vector4(-816.843933, -1421.037354, 0.112793, 167.244080),
        showroomcam = vector3(-810.105469, -1428.474731, 5.268921),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        blip = {sprite = 410, color = 24},
        job = false,
        vehtype = "boat",
        safe = 408
    },]]
    ["helishop"] = {
        label = "Repülökereskedés",
        description = "Helikopter és repülő kereskedés – szárnyalj magasba!",
        coords = vector4(-1026.536, -3019.545, 12.945084, 328.99676),
        outsidecoords = vector4(-1031.579, -2957.952, 13.948442, 60.643287),
        testcoords = vector4(-1049.872, -3308.972, 13.990063, 57.632839), -- set false to disable testing
        testtime = 60 * 1000,                                             --in ms
        showroom = vector4(-968.8558, -2988.864, 13.945075, 112.46096),
        showroomcam = vector3(-1000.361, -2995.599, 13.945065),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        blip = { sprite = 43, color = 24 },
        job = false,
        vehtype = "helicopter"
    },

    ["bm_boatshop"] = {
        label = "Hajókereskedés",
        description = "Black Mamba hajókereskedése – vízi kalandok kezdőpontja.",
        coords = vector4(-95.26172, -2767.659, 5.0821204, 87.559593),
        outsidecoords = vector4(472.70971, -3486.521, 5.8355622, 161.11137),
        testcoords = vector4(-91.13708, -3418.935, 0.1247946, 0.0461599), -- set false to disable testing
        testtime = 60 * 1000,                                             --in ms
        showroom = vector4(-816.843933, -1421.037354, 0.112793, 167.244080),
        showroomcam = vector3(-810.105469, -1428.474731, 5.268921),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        blip = { sprite = 410, color = 24 },
        job = false,
        management = {
            ["blackmamba"] = {
                "boss",
            },
        },
        vehtype = "boat",
        safe = 1798
    },
    ["bm_helishop"] = {
        label = "Repülökereskedés",
        description = "Black Mamba repülő kereskedése – exkluzív légi járművek.",
        coords = vector4(-1621.42, -3152.782, 12.991746, 46.693996),
        outsidecoords = vector4(-1617.588, -3091.352, 13.944, 60.643287),
        testcoords = vector4(-1049.872, -3308.972, 13.990063, 57.632839), -- set false to disable testing
        testtime = 60 * 1000,                                             --in ms
        showroom = vector4(-968.8558, -2988.864, 13.945075, 112.46096),
        showroomcam = vector3(-1000.361, -2995.599, 13.945065),
        enablecash = true,
        enablebank = true,
        enablefaction = false,
        blip = { sprite = 43, color = 24 },
        job = false,
        management = {
            ["blackmamba"] = {
                "boss",
            },
        },
        vehtype = "helicopter",
        safe = 1799
    },

    ["faction_carshop"] = {
        label = "Frakcios autokereskedés",
        description = "Frakciók számára elérhető járművek – csak jogosult tagoknak.",
        coords = vector4(-31.16277, -1106.544, 25.422357, 339.41821),
        outsidecoords = vector4(-50.93605, -1077.04, 26.908241, 71.600097),
        testcoords = false,
        testtime = 60 * 1000, --in ms
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = false,
        enablebank = false,
        enablefaction = { "ambulance", "army", "bahamas", "akuma95fraki",
            "balen", "blackmamba", "bloods", "bratva", "conte",
            "crips", "dd", "detective", "guardarmy", "doa", "setjob2", "exotic",
            "fbi", "fbiuj", "uss", "irs", "atf", "navi", "gomorra", "gorilla", "gov", "groove",
            "gym", "khc", "kingmaffia", "kingsman", "kingston", "loscuba",
            "lostmc", "mechanic", "mob", "ms", "ms13", "orosz", "peakybb", "police",
            "pollos", "raven", "russian", "rh", "soa", "szeged", "ujfrakcio",
            "ujfrakciodawe1", "ujfrakciodawe3", "usms", "servicess", "vagoos", "metamechanic", "huligan", "offluxduty",
            "pearlsillegal", "ssouls"
        },
        blip = false,
        --blip = {sprite = 225, color = 22},
        job = {
            ["ambulance"] = {
                "boss"
            },
            ["ssouls"] = {
                "boss"
            },
            ["army"] = {
                "boss"
            },
            ["offluxduty"] = {
                "boss"
            },
            ["bahamas"] = {
                "boss"
            },
            ["akuma95fraki"] = {
                "boss"
            },
            ["balen"] = {
                "boss"
            },
            ["blackmamba"] = {
                "boss"
            },
            ["bloods"] = {
                "boss"
            },
            ["bratva"] = {
                "boss"
            },
            ["conte"] = {
                "boss"
            },
            ["crips"] = {
                "boss"
            },
            ["dd"] = {
                "boss"
            },
            ["detective"] = {
                "boss"
            },
            ["guardarmy"] = {
                "boss"
            },
            ["doa"] = {
                "boss"
            },
            ["setjob2"] = {
                "boss"
            },
            ["exotic"] = {
                "boss"
            },
            ["fbi"] = {
                "boss"
            },
            ["fbiuj"] = {
                "boss"
            },
            ["uss"] = {
                "boss"
            },
            ["irs"] = {
                "boss"
            },
            ["atf"] = {
                "boss"
            },
            ["navi"] = {
                "boss"
            },
            ["gomorra"] = {
                "boss"
            },
            ["gorilla"] = {
                "boss"
            },
            ["gov"] = {
                "boss"
            },
            ["groove"] = {
                "boss"
            },
            ["gym"] = {
                "boss"
            },
            ["khc"] = {
                "boss"
            },
            ["kingmaffia"] = {
                "boss"
            },
            ["kingsman"] = {
                "boss"
            },
            ["kingston"] = {
                "boss"
            },
            ["loscuba"] = {
                "boss"
            },
            ["lostmc"] = {
                "boss"
            },
            ["mechanic"] = {
                "boss"
            },
            ["mob"] = {
                "boss"
            },
            ["ms"] = {
                "boss"
            },
            ["ms13"] = {
                "boss"
            },
            ["orosz"] = {
                "boss"
            },
            ["peakybb"] = {
                "boss"
            },
            ["police"] = {
                "boss"
            },
            ["pollos"] = {
                "boss"
            },
            ["raven"] = {
                "boss"
            },
            ["russian"] = {
                "boss"
            },
            ["rh"] = {
                "boss"
            },
            ["soa"] = {
                "boss"
            },
            ["szeged"] = {
                "boss"
            },
            ["ujfrakcio"] = {
                "boss"
            },
            ["ujfrakciodawe1"] = {
                "boss"
            },
            ["ujfrakciodawe3"] = {
                "boss"
            },
            ["usms"] = {
                "boss"
            },
            ["servicess"] = {
                "boss"
            },
            ["vagoos"] = {
                "boss"
            },
            ["metamechanic"] = {
                "boss"
            },
            ["huligan"] = {
                "boss"
            },
            ["pearlsillegal"] = {
                "boss"
            },
            ["mskcars"] = {
                "boss"
            },
        },
        vehtype = "car"
    },
}

if not IsDuplicityVersion() then
    Config.Notify = function(msg)
        TriggerEvent("esx:showNotification", msg)
    end
end
