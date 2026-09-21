Config = {}

---@type boolean
Config.Debug = false

---@type number
Config.NpcLoadDistance = 25.0 -- This value determines how far away the NPC is loaded from the player.

---@type vector4
Config.NpcPosition = vector4(-793.2625, -2418.895, 14.736451, 298.39129)

Config.Item = "contract2"

Config.BlacklistJobs = {
    "unemployed",
    "garbage",
    "delivery"
}

Config.DisableOffDuty = false

Config.ResellFactions = {
    ["kingmaffia"] = {
        GetHashKey("agerars"),
        GetHashKey("fd"),
        GetHashKey("mk2100"),
        GetHashKey("nzp"),
        GetHashKey("sultanrsv8"),
        GetHashKey("pulsarhr"),
        GetHashKey("dyne"),
        GetHashKey("durango18"),
        GetHashKey("e800eprezmo"),
        GetHashKey("bmwm8hycade"),
        GetHashKey("revuelto"),
        GetHashKey("impreza2019"),
        GetHashKey("pcmansory"),
        GetHashKey("skyline"),
    },
    ["blackmamba"] = {
        GetHashKey("hycurus"),
        GetHashKey("r50"),
        GetHashKey("cls500s"),
        GetHashKey("cayenne"),
        GetHashKey("godzeskyvwb"),
        GetHashKey("benze55"),
        GetHashKey("bdivo"),
        GetHashKey("m330i21"),
        GetHashKey("m2dy"),
        GetHashKey("rmodbugatti"),
        GetHashKey("fk8"),
        GetHashKey("750il"),
        GetHashKey("x3mache21"),
        GetHashKey("oycklnk"),
        GetHashKey("lamks"),
        GetHashKey("g812"),
        GetHashKey("alpinab7"),
        GetHashKey("velar"),
        GetHashKey("vwstance"),
        GetHashKey("mansgt"),
        GetHashKey("gs_wbsubn"),
        GetHashKey("aperta"),
        GetHashKey("19z4s"),
        GetHashKey("contgt2011"),
        GetHashKey("gcmr107amg"),
        GetHashKey("m5f90"),
        GetHashKey("evoque"),
        GetHashKey("f430scuderia"),
        GetHashKey("f250"),
        GetHashKey("rmodm4gts"),
        GetHashKey("q8prior"),
        GetHashKey("kmro"),
        GetHashKey("r8ppi"),
        GetHashKey("mbc63"),
    },
    ["russian"] = {
        GetHashKey("valkyrietp"),
    },
    ["mechanic"] = {
        GetHashKey("190e"),
        GetHashKey("a70"),
        GetHashKey("22b"),
        GetHashKey("rmod918spyder"),
        GetHashKey("evija"),
    },
    ["lifthouse"] = {
        GetHashKey("mustangc19"),
        GetHashKey("ocnetrongt"),
    },
    ["ms13"] = {
        GetHashKey("zondarevo1"),
    },
    --[[    ["exotic"] = {
        GetHashKey("agera11"),
        GetHashKey("M8Demon"),
        GetHashKey("c8pdy"),
        GetHashKey("2022rs3h"),
        GetHashKey("m5dmnk"),
        GetHashKey("jhpxx47"),
    },--]]
    ["mskcars"] = {
        GetHashKey("Terror"),
        GetHashKey("hdx_bmwalpd3s"),
    },
    ["lostmc"] = {
        GetHashKey("m2cs"),
        GetHashKey("ikx3urus23"),
    },
    ["bennysservice"] = {
        GetHashKey("fordh"),
        GetHashKey("rt70"),
        GetHashKey("mgt17"),
        GetHashKey("964rwbh"),
        GetHashKey("lexusnx"),
        GetHashKey("lb750sv"),
        GetHashKey("golf8beast"),
        GetHashKey("alpinad3s"),
        GetHashKey("am187"),
        GetHashKey("GC_AMG87HAMMER"),
        GetHashKey("gstrs21"),
        GetHashKey("rrbroncowide"),
        GetHashKey("slystancee30t"),
        GetHashKey("StormTrooperHawk"),
        GetHashKey("s150s"),
        GetHashKey("rikorwb"),
        GetHashKey("huracanpriorbeast"),
        GetHashKey("GODzRZRPRORDSTR"),
        GetHashKey("dc_vwt1wb"),
        GetHashKey("ktkfxxk"),
        GetHashKey("bmwe92bb10"),
    },
    ["alkaidaoff"] = {
        GetHashKey("ikx3_mk24b"),
        GetHashKey("ikx3gobstopper"),
        GetHashKey("nm_audir8"),
        GetHashKey("redeye"),
        GetHashKey("veneno"),
        GetHashKey("599xxevo"),
        GetHashKey("21rsq8"),
    },
}

Config.BuyResellCars = {
    ["kingmaffia"] = {
        coords = vector3(-532.1198, -888.47, 24.979892),
        minrank = 2
    },
    ["ms13"] = {
        coords = vector3(532.07641, -191.0112, 53.521968),
        minrank = 4
    },
    ["russian"] = {
        coords = vector3(827.7987, -942.2151, 26.498922),
        minrank = 3
    },
    ["mechanic"] = {
        coords = vector3(-212.515, -1171.705, 23.049919),
        minrank = 3
    },
    ["ujfrakciodawe3"] = {
        coords = vector3(-66.84804, -1834.043, 26.897),
        minrank = 3
    },
    ["lifthouse"] = {
        coords = vector3(247.97427, -1803.397, 28.064788),
        minrank = 3
    },
    --[[["exotic"] = {
        coords = vector3(-763.4304, -243.3076, 37.242786),
        minrank = 3
    },--]]
    ["mskcars"] = {
        coords = vector3(-31.62688, -1675.02, 29.491714),
        minrank = 3
    },
    --[[["lostmc"] = {
        coords = vector3(910.23773, -967.3891, 39.499908),
        minrank = 3
    },--]]
    ["bennysservice"] = {
        coords = vector3(-211.1232, -1295.781, 31.296546),
        minrank = 5
    },
    ["alkaidaoff"] = {
        coords = vector3(-50.77992, -1116.656, 26.434299),
        minrank = 10
    },
}

-- Pénzmosás / RMT detektor (anti-launder). Lásd: server/antilaunder.lua
Config.AntiLaunder = {
    ---@type boolean
    Enabled = true,

    -- Ettől az összegtől (bank pénz) "gyanús" egy eladás. Alap: 1 milliárd.
    ---@type number
    HugeSaleThreshold = 1000000000,

    ---@type number
    QuickFlipWindow = 6 * 3600,

    ---@type number
    RoundTripWindow = 3 * 24 * 3600,

    -- Pénz-visszautalásnál: a visszautalt összeg legalább ekkora hányada legyen az
    -- eredeti eladási árnak, hogy kör-trade-nek számítson (részleges visszaadás is gyanús).
    ---@type number
    MoneyMatchRatio = 0.5,

    -- Kereskedési tiltás hossza másodpercben (0 = végleges).
    ---@type number
    BanSeconds = 0,

    FlipBanBuyer = false,

    -- 2. esetnél mindkét felet tiltsuk-e (kör-trade = két fél összejátszása).
    ---@type boolean
    RoundTripBanBoth = true,

    -- Ezek a csoportok kapnak in-game riasztást detektáláskor.
    ---@type table<string, boolean>
    AlertGroups = {
        ["owner"] = true,
        ["coowner"] = true,
        ["servermanager"] = true,
        ["developer"] = true,
        ["serverdirector"] = true,
    },
}
