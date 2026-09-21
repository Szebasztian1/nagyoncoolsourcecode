Config = {}

Config.Locale = 'hu'

Config.NeedLockPick = true 
Config.LockPickItem = "lockpick"
Config.ChanceToBreakLockPick = 90 --in precent

Config.TimeAfterRob = 12*60 --in sec
Config.RobTime = 8*60 --in sec
Config.TimeNotify = 60 --in sec

Config.PedArmour = 400

Config.MinPolice = 0
Config.PoliceJobs = {'police', "fbi", "fbiuj", "detective", "orosz", "usms", "servicess", "orosz"}

Config.Garages = {
    { coords = vector3(-739.6879, -2475.086, 13.92969), level = 'high', label = 'Nehéz' },
   -- { coords = vector3(-5.564832, 1.252747, 71.1853), level = 'high', label = 'Nehéz' },
    --{ coords = vector3(138.2505, 273.7187, 109.9736), level = 'low', label = 'Könnyü' },	
    --{ coords = vector3(1587.6914, 6465.9067, 25.317169), level = 'mid', label = 'Közepes' },
    { coords = vector3(1945.4702148438, 3847.6750488281, 32.161586761475), level = 'mid', label = 'Közepes' },
}

Config.ShellSpawnOffset = vector3(0.0, 0.0, 350.0)
Config.Levels = {
    ["high"] = {
        shell = GetHashKey("shell_garagel"),
        locks = 5,
        inside = vector3(11.901889648437, -14.554438476562, -1.0),
        crates = {
            { offset = vector3(-4.0, 0.0, -1.95), heading = 10.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "bat", count = function() return math.random(2, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(220000, 280000) end  },
                    { loottype = "item", name = "at_suppressor_heavy", count = function() return math.random(1, 2) end  },
                }
            },
            { offset = vector3(3.6428, 6.2758, -1.95), heading = 0.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "drill", count = function() return math.random(2, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(220000, 280000) end  },
                    { loottype = "item", name = "at_suppressor_light", count = function() return math.random(1, 2) end  },
                }
            },
            { offset = vector3(3.3, 0.0, -1.95), heading = 10.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "flashlight", count = function() return math.random(2, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(220000, 280000) end  },
                }
            },
            { offset = vector3(-3.6755, 5.1535, -1.95), heading = 300.49963378906, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "hackerDevice", count = function() return math.random(2, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(220000, 280000) end  },
                }
            },
            { offset = vector3(3.8241, -7.3605, -1.95), heading = 300.49963378906, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "lockpick", count = function() return math.random(2, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(220000, 280000) end  },
                }
            },
            { offset = vector3(-3.7123681640626, -4.757197265625, -1.95), heading = 307.99975, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "pistolbelso", count = function() return math.random(2, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(220000, 280000) end  },
                }
            },
            { offset = vector3(-3.3634912109376, -13.566340332031, -1.95), heading = 307.99975, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "pistolcso", count = function() return math.random(2, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(220000, 280000) end  },
                }
            },
            { offset = vector3(0.69729980468742, 13.812993164063, -1.95), heading = 0.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "pistoltar", count = function() return math.random(2, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(220000, 280000) end  },
                }
            },
        },
        peds = {
            { offset = vector3(1.0, 24.0, -1.95), heading = 10.0, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') }, --vector3(-1153.9799804688, -907.71380615234, -46.209983825684)
            { offset = vector3(1.0, 20.88, -1.95), heading = 160.0, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') }, --vector3(-1153.1186523438, -910.24432373047, -46.210029602051)
            { offset = vector3(-1.0, 20.88, -1.95), heading = 160.0, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') }, --vector3(-1155.9398193359, -910.22680664063, -46.210029602051)
            { offset = vector3(-4.0, 21.35, -1.95), heading = 140.0, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') }, --vector3(-1158.3111572266, -909.77398681641, -46.210029602051)
            { offset = vector3(-3.0, 24.04, -1.95), heading = 1.0, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') }, --vector3(-1157.4786376953, -907.08923339844, -46.210029602051)
            { offset = vector3(-1.0, 24.04, -1.95), heading = 2.0, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') }, --vector3(-1155.6259765625, -907.09497070313, -46.210029602051)
        },
        decoration = {
            { offset = vector3(7.605, 7.163, -1.95), heading = 267.49, model = GetHashKey('prop_cratepile_07a_l1') },
            { offset = vector3(7.64737, -4.26409, -1.95), heading = 267.49, model = GetHashKey('xs_prop_arena_car_wall_02a') },
            { offset = vector3(3.2864, -3.7681, -1.95), heading = 54.99, model = GetHashKey('prop_rub_carwreck_11') },
            { offset = vector3(4.627, 10.976, -1.95), heading = 147.99, model = GetHashKey('prop_rub_carwreck_14') },
            { offset = vector3(-6.2974, -7.8608, -1.95), heading = 267.49, model = GetHashKey('xs_prop_arena_car_wall_02a') },
            { offset = vector3(-6.248, 7.018, -1.95), heading = 267.49, model = GetHashKey('xs_prop_arena_car_wall_02a') },
            { offset = vector3(-2.7736, -8.6696, -1.95), heading = 301.99, model = GetHashKey('prop_rub_carwreck_3') },
            { offset = vector3(-1.5564, 8.399, -1.955), heading = 243.49, model = GetHashKey('prop_rub_carwreck_10') },
            { offset = vector3(5.2086, 3.5805, -1.95), heading = 0.0, model = GetHashKey('ba_prop_battle_crate_beer_02') },
        },
        gas = {
            damage = 0,
            points = {
                {offset = vector3(0.0, 0.0, 1.0), scale = 3.0},
                {offset = vector3(10.0, 0.0, 1.0), scale = 3.0},
                {offset = vector3(15.0, -10.0, 1.0), scale = 3.0},
                {offset = vector3(-10.0, 0.0, 1.0), scale = 3.0},
                {offset = vector3(0.0, 10.0, 1.0), scale = 3.0},
                {offset = vector3(0.0, 20.0, 1.0), scale = 3.0},
                {offset = vector3(0.0, -10.0, 1.0), scale = 3.0},
                {offset = vector3(0.0, -20.0, 1.0), scale = 3.0},
            }
        }
    },
    ["mid"] = {
        shell = GetHashKey("shell_garagem"),
        locks = 3,
        inside = vector3(13.032016601562, 1.4325, -1.0),
        crates = {
            { offset = vector3(0.0, 5.0, -1.95), heading = 10.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "lsd", count = function() return math.random(5, 10) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(160000, 220000) end  },
                }
            },
            { offset = vector3(4.2532080078124, -5.9392041015625, -1.95), heading = 0.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "ujtracker", count = function() return math.random(0, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(160000, 220000) end  },
                }
            },
            { offset = vector3(8.1744726562499, -2.3878735351562, -1.95), heading = 268.4986, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "c4", count = function() return math.random(3, 3) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(160000, 220000) end  },
                }
            },
            { offset = vector3(-3.9054833984376, -2.2080029296875, -1.95), heading = 69.999, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "cocaine", count = function() return math.random(1, 1) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(160000, 220000) end  },
                }
            },
            { offset = vector3(-7.8804589843751, 6.4859057617188, -1.95), heading = 0.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "meth", count = function() return math.random(5, 10) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(160000, 220000) end  },
                }
            },
        },
        peds = {
            { offset = vector3(-7.3818017578126, -5.804072265625, -1.95), heading = 140.99877929688, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') },
            { offset = vector3(-5.0559960937501, -4.5540112304687, -1.95), heading = 280.9993, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') },
            { offset = vector3(-7.2712060546876, -3.1803540039062, -1.95), heading = 19.4998, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') },
        },
        decoration = {
            { offset = vector3(5.1465185546874, 3.8068896484375, -1.955), heading = 140.9986, model = GetHashKey('prop_rub_carwreck_10') },
            { offset = vector3(-5.4277001953126, 3.5165454101563, -1.95), heading = 208.4982, model = GetHashKey('prop_rub_carwreck_3') },
            { offset = vector3(-1.33797851562508, -2.5400952148437, -1.95), heading = 210.997863, model = GetHashKey('prop_rub_carwreck_11') },
            { offset = vector3(7.4453466796874, -7.541376953125, -1.95), heading = 179.49952697754, model = GetHashKey('ba_prop_batle_crates_pounder') },
            { offset = vector3(-8.5238916015626, 1.4509326171875, -1.95), heading = 91.99893951416, model = GetHashKey('bkr_prop_biker_garage_locker_01') },
        },
        gas = {
            damage = 0,
            points = {
                {offset = vector3(0.0, 0.0, 1.0), scale = 3.0},
                {offset = vector3(0.0, -5.0, 1.0), scale = 3.0},
                {offset = vector3(5.0, 0.0, 1.0), scale = 3.0},
            }
        }
    },
    ["low"] = {
        shell = GetHashKey("shell_garages"),
        locks = 2,
        inside = vector3(6.0881689453124, 3.067509765625, -1.0),
        crates = {
            { offset = vector3(0.0, 3.0, -1.0), heading = 10.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "weed_lemonhaze", count = function() return math.random(1, 1) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(100000, 160000) end  },
                }
            },
            { offset = vector3(-3.9491845703126, 0.0080615234375045, -1.0), heading = 267.49908, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "pistol_ammo", count = function() return math.random(300, 500) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(100000, 160000) end  },
                }
            },
            { offset = vector3(3.6510351562499, -3.9600170898437, -1.0), heading = 0.0, range = 2.5, locks = 1, model = GetHashKey('ex_prop_crate_closed_bc'),
                loot = {
                    { loottype = "item", name = "rifle_ammo", count = function() return math.random(600, 800) end  },
                    { loottype = "money", name = "black_money", count = function() return math.random(100000, 160000) end  },
                }
            },
        },
        peds = {
            { offset = vector3(-4.1203271484376, 3.2558642578125, -1.0), heading = 60.999008, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') },
            { offset = vector3(-2.2367822265626, 3.5609790039063, -1.0), heading = 0.0, pedweapon = GetHashKey('WEAPON_PISTOL'), pedmodel = GetHashKey('s_m_m_chemsec_01'), chairmodel = GetHashKey('apa_mp_h_din_chair_09') },
        },
        decoration = {
            { offset = vector3(2.9263037109374, 1.0974780273438, -1.0), heading = 163.499, model = GetHashKey('prop_rub_carwreck_11') },
            { offset = vector3(-2.3304101562501, -3.1074169921875, -1.0), heading = 246.998703, model = GetHashKey('prop_rub_carwreck_3') },
            { offset = vector3(0.76907714843742, 1.1233569335938, -1.0), heading = 0.0, model = GetHashKey('ba_prop_battle_crate_beer_02') },
            { offset = vector3(7.6102636718749, 3.1099291992188, -1.0), heading = 0.0, model = GetHashKey('prop_plant_int_01a') },
        },
        gas = {
            damage = 0,
            points = {
                {offset = vector3(0.0, 0.0, 1.0), scale = 3.0},
                {offset = vector3(0.0, -5.0, 1.0), scale = 3.0},
                {offset = vector3(5.0, 0.0, 1.0), scale = 3.0},
            }
        }
    },
}

Config.Notify = function(msg)
    ESX.ShowNotification(msg)
end 