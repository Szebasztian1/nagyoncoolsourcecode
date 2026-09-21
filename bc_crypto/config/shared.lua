Config = {}

Config.Locale = 'hu'

Config.OnlyMineWhenOnline = false
Config.TickTime = 60*1000 -- 1 min

Config.SafeForRobbing = 60*24 -- 1 day

Config.RefreshPrice = 30*60

-- Containers sit this high above the ground. Matches the ped's centre Z (GetEntityCoords on a ped is
-- ~1.0 above its feet), so the [E] range check works when standing on the marker. A container saved at
-- exact ground level looks buried and cannot be opened.
Config.ContainerGroundOffset = 1.0
Config.ContainerAutoFixZ = true              -- a mar lerakott konteneereket a talajra igazitja (fel ES le is)

-- NPC shop: buy a placeable mining container ("CP") for PP (bc_ppshop).
-- The PP price drifts every few hours and is announced in chat (okokChat design).
Config.NPCShop = {
    ped         = `a_m_m_business_01`,          -- ped model spawned at the shop
    npc         = vector4(1027.2869, -3013.518, 5.900803, 4.2359213),
    spawnDist   = 25.0,                          -- ped only exists within this range (proximity load, see docs/npc-scripts.md)
    interactDist = 2.5,                          -- ox_target interaction distance for the shop ped

    containerType = 'hobby',                     -- Config.Containers key created on placement
    placedPrice   = 0,                           -- $ resale value of the placed container (0 = not resellable, blocks PP->$ laundering)

    -- PP price (bc_ppshop). Cheaper prices are rarer (skew biases toward the max).
    priceMin      = 7000,
    priceMax      = 10000,
    priceSkew     = 3,                           -- higher = cheap prices rarer
    priceInterval = 2 * 60 * 60,                 -- seconds between price changes (2h)
    announceChat  = true,                        -- broadcast the new price to chat

    -- Placement (client): carry the CP in front of you, then drop it inside the allowed zone.
    placeCenter = vector3(1030.5799, -3007.55, 5.9007921),
    placeRadius = 300.0,                         -- CP can only be dropped within this radius of placeCenter
    placeTime   = 3 * 60,                        -- seconds to place before it is cancelled (no charge)
    placeDist   = 2.0,                           -- how far in front of the player the ghost floats
    placeMaxLift = 3.0,                          -- highest the CP can be raised above the ground (arrow keys)

    -- Moving an owned container (owner only, free, same drop rules as placement).
    moveEnabled  = true,
    moveCooldown = 60,                           -- seconds between two moves of the same container
    -- Containers that were not placed at the shop (admin-created, bought for cash) may only be
    -- repositioned this far from their original spot, so they cannot be walked across the map.
    moveLocalRadius = 60.0,
}

-- Phone app (RoadPhone): one-time paid unlock for the read-only Crypto guide.
Config.CryptoApp = {
    unlockPrice = 10000000,                      -- one-time price to unlock the app
    account     = 'bank',                        -- ESX account charged
}
Config.Cryptos = {
    ['bitcoin'] = {
        name = 'Bitcoin',
        symbol = 'BTC',
        price = {type = "real", symbol = 'BTC'}, --real price
        icon = 'bitcoin.png',
        color = '#F7931A',
        reward = 0.0000034333*2 --hash*reward / tick 
    },
    ['ethereum'] = {
        name = 'Ethereum',
        symbol = 'ETH',
        price = {type = "real", symbol = 'ETH'}, --fix price
        icon = 'ethereum.png',
        color = '#3C3C3D',
        reward = 0.000203333*2, --hash*reward / tick
    },
}
--3000 hash

Config.Containers = {
    ['hobby'] = { --{"x":435.8769226074219,"z":2028.7069091796875,"y":-628.04833984375}
        name = 'Hobby',
        icon = 'hobby.png',
        shell = GetHashKey('container_shell'),
        spawn = vector3(0.0, 0.0, 2000.0),
        tp = vector3(0.0, -4.0, 0.9),
        slots = {
            {
                offset = vector3(-0.9890136,-1.1604612, 0.0), --vec4(434.887909, -629.208801, 2029.824951, 272.125977)
                heading = 90.0,
            },
            
            {
                offset = vector3(-0.9890136, 1.8329468, 0.0), --vec4(436.879120, -626.215393, 2029.824951, 90.708656
                heading = 90.0,
            },
            {
                offset = vector3(-0.9890136, 3.4929468, 0.0), --vec4(436.879120, -626.215393, 2029.824951, 90.708656
                heading = 90.0,
            },
            {
                offset = vector3(-0.9758296, 5.1692508, 0.0), --vec4(434.901093, -622.879089, 2029.824951, 266.456696)
                heading = 90.0,
            },
        }
    },
    --[[['professional'] = {
        name = 'Professional',
        icon = 'professional.png',
        shell = GetHashKey('shell_warehouse1'),
        spawn = vector3(0.0, 0.0, 2000.0),
        tp = vector3(0.0, 0.0, 0.9),
        slots = {
            {
                offset = vector3(0.0, 0.0, 0.0),
                heading = 0.0,
            },
            {
                offset = vector3(0.0, 0.0, 0.0),
                heading = 0.0,
            },
            {
                offset = vector3(0.0, 0.0, 0.0),
                heading = 0.0,
            },
            {
                offset = vector3(0.0, 0.0, 0.0),
                heading = 0.0,
            },
            {
                offset = vector3(0.0, 0.0, 0.0),
                heading = 0.0,
            },
            {
                offset = vector3(0.0, 0.0, 0.0),
                heading = 0.0,
            },
        }
    },]]
}

Config.SecuritySystems = {
    ['basic'] = {
        name = 'Basic Security System',
        icon = 'security.png',
        price = 1000,
        diffuculity = 0.5,
        maxrob = 0.6
    },
    ['advanced'] = {
        name = 'Advanced Security System',
        icon = 'security.png',
        price = 2000,
        diffuculity = 0.7,
        maxrob = 0.4
    },
    ['pro'] = {
        name = 'Pro Security System',
        icon = 'security.png',
        price = 3000,
        diffuculity = 0.9,
        maxrob = 0.2
    },
}

Config.Computers = {
    ['hobby_miningcomputer'] = {
        name = 'Hobby Mining Computer',
        icon = 'motherboard.png',
        model = GetHashKey('xm_base_cia_server_01'),
        acceptedcoolers = {'small_cooler', 'medium_cooler'},
        numberofcoolers = 2,
        acceptedgpus = {'small_gpu', 'medium_gpu'},
        numberofgpus = 3,
        price = 1500000,
        durability =  0.00684181,
    },
    --[[['professional_miningcomputer'] = {
        name = 'Professional Mining Computer',
        icon = 'motherboard.png',
        model = GetHashKey('xm_base_cia_server_01'),
        acceptedcoolers = {'medium_cooler', 'large_cooler'},
        numberofcoolers = 2,
        acceptedgpus = {'medium_gpu', 'large_gpu'},
        numberofgpus = 6,
        price = 2000,
        durability = 0.0095,
    },]]
}

Config.Coolers = {
    ['small_cooler'] = {
        name = 'Kis hűtés',
        icon = 'cooler.png',
        price = 165000,
        cooling = 1.08,
        durability = 0.00784181,
    },
    ['medium_cooler'] = {
        name = 'Közepes hűtés',
        icon = 'cooler.png',
        price = 200000,
        cooling = 1.15,
        durability =  0.00684181,
    },
    --[[['large_cooler'] = {
        name = 'Large Cooler',
        icon = 'cooler.png',
        price = 3000,
        cooling = 1.18,
        durability = 0.0095,
    },]]
}--1.45

--10080

Config.GPUs = {
    ['small_gpu'] = {
        name = 'Kis GPU',
        icon = 'gpu.png',
        price = 300000,
        hashrate = 700,
        heat = 1.15,
        durability = 0.00784181,
    },
    ['medium_gpu'] = {
        name = 'Közepes GPU',
        icon = 'gpu.png',
        price = 360000,
        hashrate = 1000,
        heat = 1.3,
        durability = 0.00684181,
    },
   --[[ ['large_gpu'] = {
        name = 'Large GPU',
        icon = 'gpu.png',
        price = 3000,
        hashrate = 500,
        heat = 1.4,
        durability = 0.0095,
    },]]
}
--[[
["hobby_miningcomputer"] = {
		label = "Bányász gép",
		weight = 2,
		stack = true,
		close = true,
	},
    ["small_cooler"] = {
		label = "Kis hűtés (crypto bányászat)",
		weight = 2,
		stack = true,
		close = true,
	},
    ["medium_cooler"] = {
        label = "Közepes hűtés (crypto bányászat)",
        weight = 2,
        stack = true,
        close = true,
    },
    ["small_gpu"] = {
        label = "Kis GPU (crypto bányászat)",
        weight = 2,
        stack = true,
        close = true,
    },
    ["medium_gpu"] = {
        label = "Közepes GPU (crypto bányászat)",
        weight = 2,
        stack = true,
        close = true,
    },]]