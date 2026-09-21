Config = {}

Config.Locale = 'hu' -- Language for the game. Options: 'en', 'es', 'fr', etc.

-- Metres per step of the "walk" / "drive" daily tasks, counted from the achievement tracker's
-- server-checked distances (server/editable.lua). Live values, as before: 500 m on foot, 5 km driven.
Config.MovementSteps = {
    walk = 500,
    drive = 5000,
}

Config.DailyResetHour = 1
Config.DailyResetMinute = 10 -- Minute of the hour to reset daily tasks (0-59)
Config.DailyTasks = {
    ['complete_daily_tasks'] = { 
        name = "Kemény nap!", 
        description = "Teljesíts és vegyél át 5 napi küldetést", 
        required = 5,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 600000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_tasksystem:addTask", source, "WeeklyTasks", "complete_daily_tasks_in_row", 1)
                    TriggerEvent("bc_activitypoints:add", source, 15)
                end },
            }
        },
        autocount = false
    },
    ['bus_job'] = { 
        name = "Sofőrök királya!", 
        description = "Menj egy kör buszos munkát, ahol legalább 5 megállót érintesz.", 
        required = 1,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 90000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_tasksystem:addTask", source, "DailyTasks", "complete_daily_tasks", 1)
                    TriggerEvent("bc_activitypoints:add", source, 15)
                end },
            }
        },
        autocount = false
    },
    ['collect_diamond'] = { 
        name = "Ragyogó gyémánt!", 
        description = "Bányássz 1 gyémántot", 
        required = 1,
        reward = {
            label = false,
            add = {
                { type = "item", item = 'diamond', amount = 1 },
                { type = "money", account = 'money', amount = 50000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_tasksystem:addTask", source, "DailyTasks", "complete_daily_tasks", 1)
                    TriggerEvent("bc_activitypoints:add", source, 15)
                end },
            }
        },
        autocount = false
    },
    ['walk'] = { 
        name = "Kis edzés!", 
        description = "Sétálj 10 x 500 métert", 
        required = 10,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 90000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_tasksystem:addTask", source, "DailyTasks", "complete_daily_tasks", 1)
                    TriggerEvent("bc_activitypoints:add", source, 15)
                end },
            }
        },
        autocount = false
    },
    ['drive'] = { 
        name = "Chilles autózás!", 
        description = "Vezess 20x 5 km-t", 
        required = 20,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 90000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_tasksystem:addTask", source, "DailyTasks", "complete_daily_tasks", 1)
                    TriggerEvent("bc_activitypoints:add", source, 15)
                end },
            }
        },
        autocount = false
    },
    ['metal_detector'] = { 
        name = "Aki keres az talál!", 
        description = "Detektorozz 5-ször", 
        required = 5,
        reward = {
            label = false,
            add = {
                { type = "item", item = 'copper', amount = 5 },
                { type = "money", account = 'money', amount = 70000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_tasksystem:addTask", source, "DailyTasks", "complete_daily_tasks", 1)
                    TriggerEvent("bc_activitypoints:add", source, 15)
                end },
            }
        },
        autocount = false
    },
    ['daily_zombies'] = { 
        name = "Ezek csak zombik!", 
        description = "Ölj meg 5 zombit", 
        required = 5,
        reward = {
            label = false,
            add = {
                { type = "item", item = 'fegyverterv', amount = 1 },
                { type = "money", account = 'money', amount = 50000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_tasksystem:addTask", source, "DailyTasks", "complete_daily_tasks", 1)
                    TriggerEvent("bc_activitypoints:add", source, 15)
                end },
            }
        },
        autocount = false
    },
    ['daily_trucking'] = { 
        name = "Fuvarozzunk!", 
        description = "Szállíts le egy kaminos fuvart", 
        required = 1,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 90000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_tasksystem:addTask", source, "DailyTasks", "complete_daily_tasks", 1)
                    TriggerEvent("bc_activitypoints:add", source, 15)
                end },
            }
        },
        autocount = false
    },

}

Config.WeeklyResetDay = 1 -- 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
Config.WeeklyResetHour = 0 -- Hour of the day to reset weekly tasks (0-23)
Config.WeeklyResetMinute = 1 -- Minute of the hour to reset weekly tasks (0-59)
Config.WeeklyTasks = {
    ['complete_daily_tasks_in_row'] = { 
        name = "Munkás ember!", 
        description = "Teljesítsd és vedd át 5x a héten a Kemény nap! küldetést", 
        required = 5,
        reward = {
            label = "600 PP + 6.000.000 $",
            add = {
                { type = "money", account = 'money', amount = 6000000 },
                { type = "custom", cb = function(source)
                    exports["bc_ppshop"]:addpp(source, 600)
                end },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_activitypoints:add", source, 40)
                end },
            }
        },
        autocount = false
    },
    ['weekly_trucking'] = { 
        name = "Kamionos mester!", 
        description = "Szállíts le 12 kaminos fuvart", 
        required = 12,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 400000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_activitypoints:add", source, 40)
                end },
            }
        },
        autocount = false
    },
    ['weekly_zombies'] = { 
        name = "Zombik félelme!", 
        description = "Ölj meg 200 zombit", 
        required = 200,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 400000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_activitypoints:add", source, 40)
                end },
            }
        },
        autocount = false
    },
    ['buy_car'] = { 
        name = "Új kocsi!", 
        description = "Vegyél egy autót az autókereskedésben", 
        required = 1,
        reward = {
            label = false,
            add = {
                { type = "item", item = 'contract2', amount = 1 },
                { type = "money", account = 'money', amount = 300000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_activitypoints:add", source, 40)
                end },
            }
        },
        autocount = false
    },
    ['beekeeping'] = { 
        name = "Méhészkedjünk!", 
        description = "Rakj le 20 kaptárat vagy kast!", 
        required = 20,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 2500000 },
                { type = "item", item = 'bee-hive', amount = 3 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_activitypoints:add", source, 40)
                end },
            }
        },
        autocount = false
    },
    ['trashman'] = { 
        name = "Tisztítsuk az utcákat!", 
        description = "A kukásmunkában vigyél el 50 kukát", 
        required = 50,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 4000000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_activitypoints:add", source, 40)
                end },
            }
        },
        autocount = false
    },
    ['diving'] = { 
        name = "Irány a tenger feneke!", 
        description = "Menj búvárkodni és szedj össze 50 kincset", 
        required = 50,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 4000000 },
                { type = "custom", cb = function(source)
                    TriggerEvent("bc_activitypoints:add", source, 40)
                end },
            }
        },
        autocount = false
    },



}


Config.PermanentTasks = {
    ['shop_robbery'] = { 
        name = "Boltok réme!", 
        description = "Rabolj ki 50 boltot", 
        required = 50,
        reward = {
            label = false,
            add = {
                { type = "money", account = 'money', amount = 34000000 },
            }
        },
        autocount = false
    },
}