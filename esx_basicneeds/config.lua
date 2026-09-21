Config = {}
Config.Locale = "hu"
Config.Visible = true

Config.UseTimeout = 60 * 60 * 2

Config.Items = {
	["egeszsegessahke"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 250000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["zabkasa"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 250000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},

	["mentoscukor"] = {
		type = "food",
		prop = "prop_candy_pqs",
		status = 2500,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
		}
	},

	["topjoy"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},

	["itbonbon"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["itkokuszgolyo"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},

	["fank"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["churros"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["homar"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["sushi"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["kaviar"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["kiralyrak"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["osztriga"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["rantotthus"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["itenergydrink"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["itbananashake"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["bubbletea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["kokuszviz"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["kinleytonic"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["vodkaredbull"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["jamesonwhiskey"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["bacardirum"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["pilsnersor"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},



	["ramen"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["amfk"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["brownie"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["smuffin"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["oretor"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["fetort"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["macaron"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["yellowhotdog"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["yellowtaco"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["beleskedvence"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["yellowbbyribs"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["profit"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["lassagne"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["minest"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["taco"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["hotdog"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},

	["whiskycola"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["yellowcola"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["yellownaracsle"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["yellowvodka"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["yellowwhisky"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["yallowcoronasor"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["egribika"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},
	["rumoskola"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
			{ "drunk",    5 * 60000 },
		}
	},
	["limonade"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 200000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["yellowlimonade"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["jegeskavec"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["naracslee"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["msmcs"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["mcffem"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},
	["mcshse"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},

	["smallbrother"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["soaburger"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["oldnorth"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["soaproni"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},

	["buffalotrace"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},

	["upreggeli"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["urizs"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["upmenu"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["fank"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["hagyma"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["haribo"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["kolbasz"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["langos"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["lays"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["hamburger"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["cookedmeat"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["weed_cookie"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["muffin"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["zsiroskenyer"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["hurka"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["epressajttorta"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["kcsiga"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["gyulyasleves"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["paradicsomleves"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["halaszle"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["tyukhusleves"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["marhaporkolt"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["toltottkaposzta"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["rantottszelet"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["rantotta"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["bundaskenyer"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["langos"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["rakott_krumpli"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["turos_teszta"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["rantott_sajt"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["somloigaluska"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["zserbo"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["tiramisu"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["palacsinta"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["aranygaluska"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["bannans"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["cezarsali"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["cpecsenye"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["fagylaltkehely"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["halaszle"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["rostely"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["raksalata"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["tako"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},
	["tonhalaspizza"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["chukkasalata"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["ebimiso"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["domino"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["ebiamai"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["kawaii"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["kyodai"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["laksa"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["makifuagra"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["makirainbow"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["makiwasabiko"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["megumisan"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["midori"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["padthai"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["nabeudon"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["planetset"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["premiumset"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["tomkha"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["toriharumaki"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["torimisosarada"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["whiteorchid"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["toriharumaki"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["pizza"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["4sajtos"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["hawaipizza"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["husimado"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["magyarospizza"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["margapizza"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["cooked_meat"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["sajtgombocleves"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["mouldybread"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["babgulyasleves"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["cordonblue"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["bolognaisertesborda"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["zebrasteak"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["franciakremes"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["tokospite"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["bread"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["protein_shake"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["fshake"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["bshake"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["gymei"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["csshake"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["fcsoki"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["fanta"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["water"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["csokisshakenespresso"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 200000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["epermocktail"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["cabarnetsauvignon"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["pepsi"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["cocacola"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["cola"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["gyombereskinley"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["lattemachiato"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["mjuice"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["borutogranatalmas"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["hatakosengorogdinnyeramuneszoda"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["iichiko"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},

	["ozekishake"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},

	["machetee"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["saka"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},

	["senchatea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},

	["soju"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},

	["zoldtea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["redbull"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["monster"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["cappuccino"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["jegeskave"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["espresso"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["matchatea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["milkshake"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["dewmountaindew"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["sprite"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["kakao"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["kubu"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["tea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["cappy"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["kave"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["siocappuchino"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["ayran"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["cuba"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["bloodymary"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},

	["icetea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["itea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["mojito"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["pinacola"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["sexonbeach"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },

			{ "drunk",    5 * 60000 },
		}
	},

	["tputony"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["bor"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},
	["henessy"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},
	["beer"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},
	["palinka"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},
	["jager"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},
	["torleypezsgo"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},
	["champagne"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},
	["soproni"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},
	["aranyaszok"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk", 5 * 60000 },
		}
	},

	["smoothie"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		},
	},

	["steak"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["fishandchips"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["fishsoup"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["cappystrawberry"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["orangelimonade"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["drpepper"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["tatratea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk",    5 * 60000 },
			{ "running",  5 * 60000 },
			{ "armor",    25 },
			{ "swimming", 5 * 60000 },
		}
	},

	["rum"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk",    6 * 60000 },
			{ "running",  6 * 60000 },
			{ "armor",    30 },
			{ "swimming", 5 * 60000 },
		}
	},

	["wine"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
		effects = {
			{ "drunk",    4 * 60000 },
			{ "running",  5 * 60000 },
			{ "armor",    15 },
			{ "swimming", 5 * 60000 },
		}
	},

	["pompelmo"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = { dict = 'mp_player_intdrink', name = 'loop_bottle', settings = { 1.0, -1.0, 2000, 0, 1, true, true, true } },
	},

	["sajtburger"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["chicken"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["sonkastost"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["dsajtburger"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["bigmac"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["smcfarm"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["mcfish"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["mccrips"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["falmaspite"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["mcflurrymm"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["vshake"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["csalata"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["mcfreezecs"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["nagyburgonya"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["kisburgonya"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

	["cnuggets"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 400000,
		remove = true,
		anim = { dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = { 8.0, -8, -1, 49, 0, 0, 0, 0 } },
	},

}
