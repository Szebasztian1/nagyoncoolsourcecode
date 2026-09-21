Config = {}

Config.DetectorZones = {
    vector2(-2072.439, -475.978),
    vector2(-2115.059, -554.7165),
    vector2(-1800.501, -962.2),
    vector2(-1712.29, -793.21),
}

Config.DetectorItem = "metaldetector"

Config.ChanceToBreak = 200 -- 1 : Config.ChanceToBreak

Config.ChanceToFound = 60 --%ban
Config.FoundedItems = {--femforgacs szemet breadfresh carparts copper iron
    {item = "femforgacs", min = 1, max = 4},
    {item = "femforgacs", min = 1, max = 4},
    {item = "femforgacs", min = 1, max = 4},
    {item = "femforgacs", min = 1, max = 4},
    {item = "femforgacs", min = 1, max = 4},
    {item = "femforgacs", min = 1, max = 4},
    {item = "femforgacs", min = 1, max = 4},
    {item = "szemet", min = 1, max = 4},
    {item = "szemet", min = 1, max = 4},
    {item = "szemet", min = 1, max = 4},
    {item = "szemet", min = 1, max = 4},
    {item = "szemet", min = 1, max = 4},
    {item = "szemet", min = 1, max = 4},
    {item = "szemet", min = 1, max = 4},
    {item = "szemet", min = 1, max = 4},
    {item = "breadfresh", min = 1, max = 2},
    {item = "breadfresh", min = 1, max = 2},
    {item = "breadfresh", min = 1, max = 2},
    {item = "breadfresh", min = 1, max = 2},
    {item = "breadfresh", min = 1, max = 2},
    {item = "breadfresh", min = 1, max = 2},
    {item = "breadfresh", min = 1, max = 2},
    {item = "copper", min = 1, max = 3},
    {item = "copper", min = 1, max = 3},
    {item = "copper", min = 1, max = 3},
    {item = "copper", min = 1, max = 3},
    {item = "iron", min = 1, max = 2},
    {item = "iron", min = 1, max = 2},
    {item = "iron", min = 1, max = 2},
    {item = "antik_mask", min = 1, max = 1},
    {item = "antik_etkeszlet", min = 1, max = 1},
    {item = "maja_mask", min = 1, max = 1},
    {item = "haborus_loszer", min = 1, max = 1},
    {item = "aranyrog", min = 1, max = 1},
}

Config.NPC = {model = `a_m_m_hasjew_01`, coords = vector4(780.13067, 570.06066, 126.52029, 341.31213), label = "[Mark]~n~Antik kereskedo"}

Config.RetryTime = 60*60 --in sec

Config.SellItems = {
    ["antik_mask"] = {
        label = "Antik Maszk",
        baseprice = {
            min = 500,
            max = 850
        },
        offers = { --[multipier] = acceptrate in %
            [1.1] = 60,
            [1.2] = 40,
            [1.3] = 20,
            [1.4] = 10,
        }
    },
    ["antik_etkeszlet"] = {
        label = "Antik Étkészlet",
        baseprice = {
            min = 500,
            max = 850
        },
        offers = { --[multipier] = acceptrate in %
            [1.1] = 60,
            [1.2] = 40,
            [1.3] = 20,
            [1.4] = 10,
        }
    },
    ["maja_mask"] = {
        label = "Maja maszk",
        baseprice = {
            min = 500,
            max = 850
        },
        offers = { --[multipier] = acceptrate in %
            [1.1] = 60,
            [1.2] = 40,
            [1.3] = 20,
            [1.4] = 10,
        }
    },
    ["haborus_loszer"] = {
        label = "Háborús lőszer",
        baseprice = {
            min = 500,
            max = 850
        },
        offers = { --[multipier] = acceptrate in %
            [1.1] = 60,
            [1.2] = 40,
            [1.3] = 20,
            [1.4] = 10,
        }
    },
    ["femforgacs"] = {
        label = "Fém hulladék",
        baseprice = {
            min = 500,
            max = 850
        },
        offers = { --[multipier] = acceptrate in %
            [1.1] = 60,
            [1.2] = 40,
            [1.3] = 20,
            [1.4] = 10,
        }
    },
    ["femforgacs"] = {
        label = "Fém hulladék",
        baseprice = {
            min = 500,
            max = 850
        },
        offers = { --[multipier] = acceptrate in %
            [1.1] = 60,
            [1.2] = 40,
            [1.3] = 20,
            [1.4] = 10,
        }
    },
    ["aranyrog"] = {
        label = "Aranyrög",
        baseprice = {
            min = 500,
            max = 850
        },
        offers = { --[multipier] = acceptrate in %
            [1.1] = 60,
            [1.2] = 40,
            [1.3] = 20,
            [1.4] = 10,
        }
    },
}

Config.Buy = {
    model = `a_m_m_malibu_01`, 
    coords = vector4(-1743.468, -727.51, 9.5, 60.00), 
    price = 45000
}