Config = {}

Config.Target = true

-- Multiplier per minutes/hours
Config.mpMinutes = 60 -- price * Config.Minutes * time >> es. 30000 * 60 * 15 / 200
Config.mpHours = 360  -- price * Config.Hours * time >> es. 30000 * 360 * 15 / 360

Config.PlatePrefix = "BC-"

Config.Rentals = {
    {
        pos = vector4(-520.1216, -262.2217, 34.5076, 313.3504),
        pedModel = "a_m_m_bevhills_02",
        blip = {
            enable = false,
            type   = 778,
            color  = 54,
            scale  = 0.8,
            name   = "Bérlő"
        },
        vehicles = {
            {
                label = "Motor",
                car = "double",
                price = 500,
                image = "https://cdn.discordapp.com/attachments/1043065822127599676/1254392627747623005/roller.png?ex=667953ab&is=6678022b&hm=97c3c6e2dc0a0a7c75c17bb9a33d693bfa57c46f88bb2523d160fe6e3c821ee2&",
                spawnPosition = vector4(-517.3399, -263.3632, 35.3648, 202.5198)
            },
        }
    },

    {
        pos = vector4(182.19439, 7031.1328, 1.0563344, 313.3504),
        pedModel = "a_m_m_bevhills_02",
        blip = {
            enable = false,
            type   = 778,
            color  = 54,
            scale  = 0.8,
            name   = "Bérlő"
        },
        vehicles = {
            {
                label = "Teherautó",
                car = "speedo",
                price = 500,
                image = "https://cdn.discordapp.com/attachments/1043065822127599676/1254392627747623005/roller.png?ex=667953ab&is=6678022b&hm=97c3c6e2dc0a0a7c75c17bb9a33d693bfa57c46f88bb2523d160fe6e3c821ee2&",
                spawnPosition = vector4(185.9465, 7040.5649, 2.1711981, 64.04808)
            },
            {
                label = "Hajó",
                car = "dinghy",
                price = 500,
                image = "https://cdn.discordapp.com/attachments/1043065822127599676/1254392627747623005/roller.png?ex=667953ab&is=6678022b&hm=97c3c6e2dc0a0a7c75c17bb9a33d693bfa57c46f88bb2523d160fe6e3c821ee2&",
                spawnPosition = vector4(247.60252, 7106.3657, -0.201935, 315.39908)
            },
        }
    },

    {
        pos = vector4(324.64874, -569.481, 27.742137, 337.53404),
        pedModel = "a_m_m_bevhills_02",
        blip = {
            enable = false,
            type   = 778,
            color  = 54,
            scale  = 0.8,
            name   = "Bérlő"
        },
        job = "ambulance",
        vehicles = {
            {
                label = "Mentőautó",
                car = "bran7",
                price = 20000,
                image = "https://cdn.discordapp.com/attachments/1043065822127599676/1254392627747623005/roller.png?ex=667953ab&is=6678022b&hm=97c3c6e2dc0a0a7c75c17bb9a33d693bfa57c46f88bb2523d160fe6e3c821ee2&",
                spawnPosition = vector4(336.71032, -572.5498, 28.742136, 342.8644)
            },
        }
    },
}
