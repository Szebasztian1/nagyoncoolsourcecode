Config                           = {}

Config.DrawDistance              = 40.0

Config.Marker                    = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }

Config.ReviveReward              = 150000 -- revive reward, set to 0 if you don't want it enabled
Config.AntiCombatLog             = true   -- enable anti-combat logging?
Config.LoadIpl                   = true   -- disable if you're using fivem-ipl or other IPL loaders

Config.Locale                    = 'en'

local second                     = 1000
local minute                     = 60 * second

Config.PericoCoords              = { x = 4483.095, y = -4478.809, z = 4.207275, r = 2500.0 }
Config.PericoRespawn             = { coords = vector3(4900.811, -4940.843, 3.361873) }

Config.EarlyRespawnTimer         = 5 * minute  -- Time til respawn is available
Config.BleedoutTimer             = 10 * minute -- Time til the player bleeds out

Config.DeathTime                 = {
	{
		coords = vector3(-2721.015, 6614.5078, 15.0389),
		radius = 150,
		EarlyRespawnTimer = 2 * minute,
		BleedoutTimer = 10 * minute,
	},
	{
		coords = vector3(3610.7604, 3719.9367, 29.688673),
		radius = 200,
		EarlyRespawnTimer = 2 * minute,
		BleedoutTimer = 10 * minute,
	},
	{
		coords = vector3(1399.811, -2619.921, 49.674747),
		radius = 200,
		EarlyRespawnTimer = 2 * minute,
		BleedoutTimer = 10 * minute,
	},
	{
		coords = vector3(-613.8726, -1621.013, 31.010417),
		radius = 200,
		EarlyRespawnTimer = 2 * minute,
		BleedoutTimer = 10 * minute,
	},
	{
		coords = vector3(-243.9401, -348.9781, 30.001401),
		radius = 200,
		EarlyRespawnTimer = 2 * minute,
		BleedoutTimer = 10 * minute,
	},
	{
		coords = vector3(-64.8582, 6206.9956, 31.260429),
		radius = 90,
		EarlyRespawnTimer = 2 * minute,
		BleedoutTimer = 10 * minute,
	},
	{
		coords = vector3(-1098.413, -1634.649, 4.3984303),
		radius = 90,
		EarlyRespawnTimer = 2 * minute,
		BleedoutTimer = 10 * minute,
	},
}

Config.EnablePlayerManagement    = true

Config.RemoveWeaponsAfterRPDeath = true
Config.RemoveCashAfterRPDeath    = true
Config.RemoveItemsAfterRPDeath   = true

-- Let the player pay for respawning early, only if he can afford it.
Config.EarlyRespawnFine          = false
Config.EarlyRespawnFineAmount    = 5000

Config.RespawnPoint              = { coords = vector3(337.872528, -591.560425, 43.24829), heading = 45.354328 } --halálcoords

Config.DeadPoint                 = vector3(337.872528, -591.560425, 43.24829)                                   --halálcoords2

-- Halottan a targetelés itt is engedélyezett, a Config.Hospitals blipjein felül.
-- A jelzőt a client/main.lua állítja (deadTargetBlocked), az ox_target olvassa.
Config.DeadTargetExtraZones      = {
	{ coords = vector3(-65.56357, 6516.5346, 36.268524), radius = 50.0 }, -- Paleto kórház
}


Config.Respawns = {
	{
		coords = vector3(-159.13816833496, -986.78057861328, 254.1315),
		radius = 100.0,
		respawn = vector3(-159.13816833496, -986.78057861328, 254.1315),
	},

	{
		coords = vector3(979.5, -3037.7, 5.9),
		radius = 190.0,
		respawn = vector3(979.5, -3037.7, 5.9),
	},

	{
		coords = vector3(-757.9, 254.4, 132.3),
		radius = 75.0,
		respawn = vector3(-757.9, 254.4, 132.3),
	},

	{
		coords = vector3(-251.1634, -299.2185, 21.62639),
		radius = 80.0,
		respawn = vector3(-245.7493, -337.0607, 29.974962),
	},
}

Config.Hospitals = {

	CentralLosSantos = {

		Blip = {
			coords = vector3(299.762634, -581.195618, 43.248291), --blip
			sprite = 61,
			scale  = 1.0,
			color  = 1
		},

		AmbulanceActions = {
			vector3(301.58, -598.85, 42.2)
		},

		Pharmacies = {
			--vector3(306.91, -601.04, 42.2)
		},

		Vehicles = {
			{
				Spawner = vector3(-2659.73, -1500.891, 727.5323),
				InsideShop = vector3(292.23, -609.86, 43.1),
				Marker = { type = 306, x = 1.0, y = 1.0, z = 1.0, r = 100, g = 50, b = 200, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(290.2, -609.01, 43.1), heading = 67.8,  radius = 4.0 },
					{ coords = vector3(294.0, -1433.1, 29.8), heading = 227.6, radius = 4.0 },
					{ coords = vector3(309.4, -1442.5, 29.8), heading = 227.6, radius = 6.0 }
				}
			}
		},

		Helicopters = {
			{
				Spawner = vector3(5632.2607, -3241.597, -120.6399), --ezt
				InsideShop = vector3(350.3, -586.7, 73.9),
				Marker = { type = 34, x = 1.5, y = 1.5, z = 1.5, r = 100, g = 150, b = 150, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(350.3, -586.7, 73.9), heading = 142.7, radius = 10.0 },
					{ coords = vector3(350.3, -586.7, 73.9), heading = 142.7, radius = 10.0 }
				}
			}
		},

		FastTravels = {
			{
				From = vector3(329.63, -600.58, 42.2),
				To = { coords = vector3(340.0, -585.38, 73.9), heading = 0.0 },
				Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(5663.999, -3249.438, -127.6608),
				To = { coords = vector3(329.63, -595.81, 42.5), heading = 0.0 },
				Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(247.3, -1371.5, 23.5),
				To = { coords = vector3(333.1, -1434.9, 45.5), heading = 138.6 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(335.5, -1432.0, 45.50),
				To = { coords = vector3(249.1, -1369.6, 23.5), heading = 0.0 },
				Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(234.5, -1373.7, 20.9),
				To = { coords = vector3(320.9, -1478.6, 28.8), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, a = 100, rotate = false }
			},

			{
				From = vector3(317.9, -1476.1, 28.9),
				To = { coords = vector3(238.6, -1368.4, 23.5), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, a = 100, rotate = false }
			}
		},

		FastTravelsPrompt = {
			{
				From = vector3(237.4, -1373.8, 26.0),
				To = { coords = vector3(251.9, -1363.3, 38.5), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false },
				Prompt = _U('fast_travel')
			},

			{
				From = vector3(256.5, -1357.7, 36.0),
				To = { coords = vector3(235.4, -1372.8, 26.3), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false },
				Prompt = _U('fast_travel')
			}
		}

	}
}

Config.AuthorizedVehicles = {

	ambulance = {
		{ model = 'EMSF250',  label = 'EMS Ford',  price = 20000 },
		{ model = 'dodgeEMS', label = 'EMS Dodge', price = 20000 },
	},

	doctor = {
		{ model = 'EMSF250',  label = 'EMS Ford',  price = 20000 },
		{ model = 'dodgeEMS', label = 'EMS Dodge', price = 20000 },
	},

	chief_doctor = {
		{ model = 'EMSF250',  label = 'EMS Ford',  price = 20000 },
		{ model = 'dodgeEMS', label = 'EMS Dodge', price = 20000 },
	},

	boss = {
		{ model = 'EMSF250',   label = 'EMS Ford',  price = 20000 },
		{ model = 'dodgeEMS',  label = 'EMS Dodge', price = 20000 },
		{ model = 'skodaambo', label = 'EMS Skoda', price = 25000 },
	}

}

Config.AuthorizedHelicopters = {

	ambulance = {},

	doctor = {
		{ model = 'lguardmav', label = 'Mento Helikopter', price = 1 },
	},

	chief_doctor = {
		{ model = 'lguardmav', label = 'Mento Helikopter', price = 1 },
	},

	boss = {
		{ model = 'lguardmav', label = 'Mento Helikopter', price = 1 },
	}

}
