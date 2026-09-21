local config = {}

config.missionTimeLimit = 30 * 60 * 1000
config.warningTime = 25 * 60 * 1000
config.regenerationTime = 60 * 60 * 1000
config.maximumMissions = 10

config.npcModels = {
    "g_m_y_mexgoon_01",
    "g_m_y_mexgoon_02",
    "g_m_y_mexgoon_03",
    "g_m_y_lost_01",
    "g_m_y_lost_02",
    "g_m_y_lost_03",
    "g_m_y_salvagoon_01",
    "g_m_y_salvagoon_02",
    "g_m_y_salvagoon_03",
    "g_m_m_armboss_01",
    "g_m_m_armgoon_01",
    "g_m_m_armlieut_01",
    "g_m_y_azteca_01",
    "g_m_y_ballaeast_01",
    "g_m_y_ballaorig_01",
    "g_m_y_ballasout_01",
    "g_m_y_famca_01",
    "g_m_y_famdnf_01",
    "g_m_y_famfor_01"
}

config.types = {
    {
        label = 'Könnyű',
        value = "easy",
        chance = 20,
        settings = {
            money = { min = 50000, max = 100000 },
            exp = { min = 50, max = 70 },
            npcs = {
                min = 1,
                max = 3,
                values = {
                    health = 300,
                    weapons = {
                        "WEAPON_PISTOL",
                        "WEAPON_KNIFE",
                        "WEAPON_BAT"
                    }
                }
            }
        }
    },
    {
        label = 'Közepes',
        value = "medium",
        chance = 10,
        settings = {
            money = { min = 150000, max = 250000 },
            exp = { min = 70, max = 90 },
            npcs = {
                min = 3,
                max = 5,
                values = {
                    health = 400,
                    weapons = {
                        "WEAPON_PISTOL",
                        "WEAPON_APPISTOL",
                        "WEAPON_MICROSMG",
                        "WEAPON_MACHETE"
                    }
                }
            }
        }
    },
    {
        label = 'Nehéz',
        value = "hard",
        chance = 5,
        settings = {
            money = { min = 300000, max = 400000 },
            exp = { min = 90, max = 140 },
            npcs = {
                min = 5,
                max = 8,
                values = {
                    health = 600,
                    weapons = {
                        "WEAPON_APPISTOL",
                        "WEAPON_MICROSMG",
                        "WEAPON_SMG",
                        "WEAPON_PUMPSHOTGUN"
                    }
                }
            }
        }
    },

    {
        label = 'Rendvédelmi munka',
        value = "police_job",
        chance = 80,
        onlypolice = true,
        settings = {
            money = { min = 600000, max = 800000 },
            exp = { min = 200, max = 350 },
            npcs = {
                min = 5,
                max = 8,
                values = {
                    health = 600,
                    weapons = {
                        "WEAPON_APPISTOL",
                        "WEAPON_MICROSMG",
                        "WEAPON_SMG",
                        "WEAPON_PUMPSHOTGUN"
                    }
                }
            }
        }
    }
}

config.locations = {
    vec3(1633.1318, -2280.3811, 106.1040),
    vec3(1535.5283, -2098.9834, 77.1088),
    vec3(1588.6763, -1719.0233, 88.0902),
    vec3(1914.2173, 588.4070, 181.3460),
    vec3(2129.7964, 1938.7059, 93.7884),
    vec3(2330.9756, 2552.8149, 46.7452),
    vec3(1583.3599, 2901.1794, 56.9131),
    vec3(403.4976, 2988.5212, 40.7161),
    vec3(-282.5113, 2543.7793, 74.4349),
    --vec3(-1124.1207, 4922.9722, 218.8409),
    vec3(1444.8920, 6346.4341, 23.7279),
    vec3(1517.4150, 6334.3892, 24.1137),
    vec3(2210.0481, 5595.7983, 54.4300),
}

config.names = {
    "Árulók likvidálása",
    "Bandatagok kiiktatása",
    "Tiszta munka",
    "Névtelen munka",
    "Zavaró tényezők",
    "Csendben, gyorsan",
    "Bizonyítékok nélkül",
    "Csak profiknak",
    "Veszélyes elemek",
    "Nincs túlélő"
}

config.descriptions = {
    "Iktasd ki a célpontokat nyomok hagyása nélkül.",
    "Ezek a személyek túl sokat tudnak. Hallgattasd el őket.",
    "A célpontok veszélyt jelentenek. Töröld el őket.",
    "Gyors akció, fegyverrel. Nem kell finomkodni.",
    "Ezek az emberek megérdemelték a sorsukat. Hajtsd végre.",
    "Eredményes munkánál bónusz jár. Légy alapos.",
    "A megbízó teljes diszkréciót kér.",
    "Két világunk van: az élők és a holtak. Ők az utóbbiba tartanak.",
    "Gyors munka, jó fizetés. Kérdések nélkül."
}

return config
