Config = {}
Peds = {}
Loot = {}
Jobs = {}

Config.Locale = 'hu'

Config.whitelisted = true
Config.Cooldown = 5 * 60 * 60 * 1000
Config.RestartTime = 600 -- MÁSODPERCBEN VAN

Config.BoatRenterPos = vector4(1279.68, -3348.83, 4.9, 0.0)
Config.SpawnBoatPos = vector4(1275.86, -3361.76, 5.46, 170.0)
Config.MotherShipPos = vector3(3058.2, -4715.86, 15.26)

Loot.positions = {
	{ name = 1,  id = 0,  x = 3119.71, y = -4774.37, z = 16.76, loottype = 'high',   locks = 1, opened = false },
	{ name = 2,  id = 1,  x = 3070.86, y = -4761.61, z = 7.56,  loottype = 'medium', locks = 3, opened = false },
	{ name = 3,  id = 2,  x = 3081.99, y = -4748.25, z = 7.56,  loottype = 'medium', locks = 3, opened = false },
	{ name = 4,  id = 3,  x = 3067.18, y = -4749.04, z = 7.25,  loottype = 'normal', locks = 2, opened = false },
	{ name = 5,  id = 4,  x = 3073.76, y = -4726.08, z = 7.25,  loottype = 'normal', locks = 2, opened = false },
	{ name = 6,  id = 5,  x = 3078.01, y = -4737.54, z = 7.23,  loottype = 'low',    locks = 1, opened = false },
	{ name = 7,  id = 6,  x = 3060.76, y = -4714.62, z = 7.56,  loottype = 'medium', locks = 3, opened = false },
	{ name = 8,  id = 7,  x = 3065.18, y = -4699.09, z = 6.53,  loottype = 'normal', locks = 2, opened = false },
	{ name = 9,  id = 8,  x = 3094.71, y = -4795.97, z = 7.25,  loottype = 'normal', locks = 2, opened = false },
	{ name = 10, id = 9,  x = 3066.85, y = -4807.35, z = 16.44, loottype = 'normal', locks = 2, opened = false },
	{ name = 11, id = 10, x = 3064.57, y = -4823.67, z = 16.76, loottype = 'medium', locks = 3, opened = false },
	{ name = 12, id = 11, x = 3057.35, y = -4781.34, z = 16.42, loottype = 'normal', locks = 2, opened = false },
	{ name = 13, id = 12, x = 3085.59, y = -4659.23, z = 16.44, loottype = 'low',    locks = 1, opened = false },
	{ name = 14, id = 13, x = 3018.57, y = -4688.85, z = 15.46, loottype = 'low',    locks = 1, opened = false },
	{ name = 15, id = 14, x = 3026.92, y = -4720.88, z = 15.46, loottype = 'low',    locks = 1, opened = false },
	{ name = 16, id = 15, x = 3089.28, y = -4722.59, z = 15.81, loottype = 'low',    locks = 1, opened = false },
	{ name = 17, id = 16, x = 3041.19, y = -4693.06, z = 7.25,  loottype = 'low',    locks = 1, opened = false },
	{ name = 18, id = 17, x = 3122.19, y = -4799.14, z = 16.44, loottype = 'low',    locks = 1, opened = false },
	{ name = 19, id = 18, x = 3062.25, y = -4594.9,  z = 15.81, loottype = 'low',    locks = 1, opened = false }
}

Loot.MaxRewards = {
	["high"] = 5,
	["medium"] = 3,
	["low"] = 2
}

Loot.Rewards = {
	["high"] = {

		["ak47ravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["ak47valtamasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["ak47belso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["ak47cso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["ak47tar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["cbcso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["cbmarkolat"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["cbrravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["cbtarto"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["docso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["dotar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["doravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["tacticcso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["tactictar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["tacticravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["mncso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["mntar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["mnravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},

		["specialmk2cso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["specialmk2belsoszerkezet"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["specialmk2csoravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["combatshotguntar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["combatshotguncso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["combatshotgunbelsoszerkezet"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["combatshotgunravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["kochcso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["kochravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["kochtar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["kochbelso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["comk2belsoszerkezet"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["comk2markolat"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["comk2rravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["comk2valtamasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["shotmk2belso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["shotmk2cso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["shotmk2ravaszmk"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["shotmk2szerkezet"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 1, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},

		["black_money"] = {
			type = "account", -- weapon, item, account
			maxcount = 20000, -- ha fegyver akkor ammo mennyiség
			mincount = 5000
		}

	},

	["medium"] = {

		["uzicso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["uziravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["uzibelso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["uzitar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["vimarkolat"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["viravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["vitar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["vivaz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},

		["black_money"] = {
			type = "account", -- weapon, item, account
			maxcount = 15000, -- ha fegyver akkor ammo mennyiség
			mincount = 3000
		}

	},

	["normal"] = {

		["uzicso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["uziravasz"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["uzibelso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},

		["uzitar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		}

	},

	["low"] = {

		["pistoltar"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["pistolcso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},
		["pistolbelso"] = {
			type = "item", -- weapon,item,money,blackmoney
			maxcount = 2, -- ha fegyver akkor ammo mennyiség
			mincount = 0
		},

		["black_money"] = {
			type = "account", -- weapon, item, account
			maxcount = 8000, -- ha fegyver akkor ammo mennyiség
			mincount = 2000
		}

	}

}

Peds.positions = {
	{ x = 3092.28, y = -4718.72, z = 15.28 },
	{ x = 3092.28, y = -4718.72, z = 15.28 },
	{ x = 3087.4,  y = -4718.0,  z = 15.28 },
	{ x = 3087.4,  y = -4718.0,  z = 15.28 },
	{ x = 3073.44, y = -4738.52, z = 15.28 },
	{ x = 3073.44, y = -4738.52, z = 15.28 },
	{ x = 3053.8,  y = -4698.72, z = 15.28 },
	{ x = 3053.8,  y = -4698.72, z = 15.28 },
	{ x = 3053.8,  y = -4698.72, z = 15.28 },
	{ x = 3080.88, y = -4790.32, z = 15.28 },
	{ x = 3080.88, y = -4790.32, z = 15.28 },
	{ x = 3080.88, y = -4790.32, z = 15.28 },
	{ x = 3101.84, y = -4777.16, z = 15.28 },
	{ x = 3101.84, y = -4777.16, z = 15.28 },
	{ x = 3101.84, y = -4777.16, z = 15.28 },
	{ x = 3093.36, y = -4704.56, z = 18.32 },
	{ x = 3093.36, y = -4704.56, z = 18.32 },
	{ x = 3086.56, y = -4708.44, z = 21.28 },
	{ x = 3086.56, y = -4708.44, z = 21.28 },
	{ x = 3093.08, y = -4696.48, z = 24.24 },
	{ x = 3093.68, y = -4702.8,  z = 24.28 },
	{ x = 3093.68, y = -4702.8,  z = 24.28 },
	{ x = 3093.68, y = -4702.8,  z = 24.28 },
	{ x = 3099.92, y = -4720.6,  z = 24.24 },
	{ x = 3094.4,  y = -4724.52, z = 24.24 },
	{ x = 3093.28, y = -4703.12, z = 27.28 }
	--{x = 3093.28, y = -4703.12, z = 27.28},
	--{x = 3093.28, y = -4703.12, z = 27.28},
	--{x = 3095.56, y = -4706.24, z = 12.24},
	--{x = 3095.56, y = -4706.24, z = 12.24},
	--{x = 3095.16, y = -4702.28, z = 12.24},
	--{x = 3095.16, y = -4702.28, z = 12.24},
	--{x = 3073.72, y = -4723.24, z = 6.08},
	--{x = 3073.72, y = -4723.24, z = 6.08},
	--{x = 3073.72, y = -4723.24, z = 6.08},
	--{x = 3065.4, y = -4770.72, z = 6.08},
	--{x = 3065.4, y = -4770.72, z = 6.08},
	--{x = 3065.4, y = -4770.72, z = 6.08},
	--{x = 3046.92, y = -4659.48, z = 6.08},
	--{x = 3046.92, y = -4659.48, z = 6.08},
	--{x = 3044.24, y = -4628.0, z = 6.08},
	--{x = 3044.24, y = -4628.0, z = 6.08},
	--{x = 3044.24, y = -4628.0, z = 6.08}
}
