Config = {
    Framework = "esx", -- esx or qb
    Locale = "hu",

    UseCruiseControl = false,
    UseSeatBelt = false,
    UseNitro = true,
    UseStress = false,
    UseMenuKey = true,
    MoneyAsItem = false,
    UseInGameTimer = true, -- if you set this to true then the hour and minutes will be shown as in game time
    
    MoneyItem = "money", -- If you set MoneyAsItem to true, you need to set the item name here
    NitroItem = "nitro", -- If you set UseNitro to true, you need to set the item name here
    
    -- ## These keys will be saved into the game files. ## --
    CruiseKey = "9",
    SeatBeltKey = "",
    NitroKey = "X",
    MenuKey = "O",
    -- ## ## --
    MenuCommand = "hud",

    -- /terkepbeallitas: a kor alaku terkepet es a kore rajzolt keretet lehet vele egymasra
    -- igazitani, kliens oldalon, ujraindito nelkul. Amit beallitasz, csak nalad marad meg.
    MapAlignTool = true,

    MinSpeedToThrowFromVehicle = 100, -- In KM/H
    NitroForce = 50.0,
    RemoveNitroOnMilliseconds = 0.2,

    UseCustomFuel = true, -- If you want to use custom fuel script, set this to true and set the export name below
    CustomFuel = function(vehicle)
        --return exports['LegacyFuel']:GetFuel(vehicle)
        return GetVehicleFuelLevel(vehicle)
    end,

    BikeModels = {
        "bmx", "cruiser", "fixter", "scorcher",
        "tribike", "tribike2", "tribike3",
    },

    HeliModels = {
        "maverick", "buzzard", "buzzard2", "polmav",
        "annihilator", "annihilator2", "frogger", "frogger2",
        "supervolito", "supervolito2", "volatus", "swift", "swift2",
        "valkyrie", "valkyrie2", "savage", "akula", "hunter",
        "seasparrow", "seasparrow2", "seasparrow3",
        "helicopter", "skylift",
        "cargobob", "cargobob2", "cargobob3", "cargobob4",
    },

    Keys = {
        --{
        --    title = "Cruise Control",
        --    key = "N",
        --},
        --{
        --    title = "Seat Belt",
        --    key = "K",
        --},
        --{
        --    title = "Nitro",
        --    key = "X",
        --},
    },

    StressNotify = false, -- If you want to notify the player when they get stressed, set this to true
    MinStressToBlur = 50, -- If the player's stress level is higher than this, the screen will blur
    WhitelistedWeaponStress = { -- Weapons that won't stress
        `weapon_petrolcan`,
        `weapon_hazardcan`,
        `weapon_fireextinguisher`,
        `weapon_candycane`,
        `weapon_flashlight`,
        `weapon_ball`,
        `weapon_acidpackage`,
        `weapon_snowball`,
        `weapon_fertilizercan`,
        `gadget_parachute`,
        `WEAPON_67_G17GRIP`,
        `WEAPON_ELK_G17`,
        `WEAPON_GK19_BLOODPRINT`,
        `WEAPON_M4_STORMBORN`,
        `WEAPON_SALENA_G17`,
    },

    AddStress = { -- These are the values that will add stress to the player.
        ["on_shoot"] = {
            min = 1,
            max = 2,
            enable = false,
            chance = 20, -- Change to get stressed
        },
        ["on_fastdrive"] = {
            min = 1,
            max = 3,
            enable = false ,
            minSpeed = 110, -- Minimum speed to get stressed
            chance = 50, -- Change to get stressed
        },
    },

    RemoveStress = { -- These are the values that will be removed from the stress level
        ["on_eat"] = {
            min = 5,
            max = 10,
            enable = true,
        },
        ["on_drink"] = {
            min = 5,
            max = 10,
            enable = true,

        },
        ["on_swim"] = {
            min = 5,
            max = 10,
            enable = true,

        },
        ["on_run"] = {
            min = 5,
            max = 10,
            enable = true,
        }
    },

    Notify = function(title, message, type, length, icon, color) -- Icons are selected from https://fontawesome.com/icons?d=gallery&m=free
        TriggerEvent("aty_hud:sendNotify", message, icon, color, length)
    end,
}