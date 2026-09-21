local eWarehouseUnit = require("lua.shared.enums.eWarehouseUnit")
local eLivestock = require("lua.shared.enums.eLivestock")

local Config = {
    -- Enter position
    INTERIOR_POSITION                       = vector3(400, 6508.5, -103.1),
    -- Interior MLO origo (do not change)
    INTERIOR_ORIGO                          = vector3(400, 6500, -100),

    USE_LOBBY_ENTRANCE                      = false,
    LOBBY_POSITION                          = vector3(408.176, 6497.299, 27.807),
    LOBBY_BLIP_SPRITE                       = 20,
    LOBBY_BLIP_COLOR                        = 25,
    LOBBY_BLIP_SHORTRANGE                   = true,

    COMPOST_PRICE                           = 65000,
    MILK_PRICE                              = 115000,
    EGG_PRICE                               = 75000,

    -- How often tick the house (livestock, water trough, etc...)
    HOUSE_TICK_TIME                         = 60000 * 58,

    -- Default 58 minute cycle
    LIVESTOCK_RESTOCK_TIME                  = 60000 * 30,

    -- 1.0.8 (update)
    AGE_INCREASE_ON_TICK                    = 3.0,
    CHICKEN_GATHER_INCREASE_ON_TICK         = { 25, 40 },
    COW_GATHER_INCREASE_ON_TICK             = { 25, 40 },
    -------------------------------------------

    REDUCE_LIVESTOCK_HEALTH_ON_GATHER_REACH = 5,

    -- Limit the storage count (Milk, Egg, etc.)
    MAX_STORAGE_COUNT                       = 100,

    -- Limit the pitchfork content to integer
    MAX_PITCHFORK_COUNT                     = 10,
    -- Limit the bucket content to integer
    MAX_BUCKET_COUNT                        = 15,
    -- Amount to fill to the trough per tick.
    FOOD_UNIT_PER_BUCKET_TICK               = 5,
    -- Amount to fill to the water trough per tick
    WATER_UNIT_PER_BUCKET_TICK              = 5,

    -- Interaction key (Compost, Enter instance, etc.): Default key 'E'
    INTERACTION_KEY                         = 0x45,

    -- If you have custom blip categories, you may need to change this. (or blips wont show up on the minimap)
    BLIP_CATEGORY_ID                        = 20,
    BLIP_SPRITE_ID                          = 374,

    -- How often refresh the warehouse price(s)
    WAREHOUSE_PRICE_CYCLE_TIME              = 60000 * 1,

    -- 1.0 (if you need fast balancing for the animal sell prices)
    LIVESTOCK_SELL_MULTIPLIER               = 0.5,

    -- You can modify them, but we calculated many things with it.
    LIVESTOCK_REQUIREMENT_FOOD_MULTIPLIER   = 0.020,
    LIVESTOCK_REQUIREMENT_WATER_MULTIPLIER  = 0.020,

    ---@type table<eLivestock, number>
    LIVESTOCK_BASE_PRICE                    = {
        [eLivestock.Cattle]       = 1200000,
        [eLivestock.Chicken]      = 800000,
        [eLivestock.Cow]          = 2500000,
        [eLivestock.PigHampshire] = 2000000,
        [eLivestock.PigLandrace]  = 1500000,
        [eLivestock.PigPietrain]  = 1800000
    },

    -- Randomised price between these two values
    ---@type table<eWarehouseUnit, [number, number]>
    WAREHOUSE                               = {
        [eWarehouseUnit.CHICKEN_FEED] = { 800, 1200 },
        [eWarehouseUnit.PIG_FEED] = { 800, 1200 },
        [eWarehouseUnit.COW_FEED] = { 800, 1200 },
        [eWarehouseUnit.UNIVERSAL_FEED] = { 800, 1200 },
        [eWarehouseUnit.GRAIN_MIX_FEED] = { 800, 1200 },
        [eWarehouseUnit.PROTEIN_FEED] = { 800, 1200 }
    },

    LIVESTOCK_SPAWN                         = {
        vector3(-1.583, 2.718, -2.23),
        vector3(-1.126, -1.281, -2.232),
        vector3(1.829, 2.843, -2.232),
        vector3(-0.893, 1.189, -2.232),
        vector3(0.941, 0.820, -2.232),
        vector3(0.446, -0.573, -2.232),
        vector3(2.189, -1.201, -2.232),
        vector3(-2.037, -2.311, -2.232),
        vector3(-0.749, -3.448, -2.232),
        vector3(0.980, -2.691, -2.232),
        vector3(-0.004, -5.136, -2.232),
        vector3(2.275, -6.169, -2.232),
        vector3(-2.017, -5.768, -2.232),
        vector3(-1.127, -7.486, -2.232),
        vector3(1.050, -7.462, -2.232)
    },

    COMPOST_SPAWN                           = {
        {
            POSITION = vector3(-6.336, 5.1391, -3.119),
            ROTATION = vector3(0, 0, 0)
        },
        {
            POSITION = vector3(-4.644, 5.128, -3.119),
            ROTATION = vector3(0, 0, 0)
        }
    },
    BUCKET_SPAWN                            = {
        {
            POSITION = vector3(1.516, 8.586, -3.116),
            ROTATION = vector3(0, 0, 0)
        },
        {
            POSITION = vector3(2.326, 4.78633, -3.116),
            ROTATION = vector3(0, 0, 0)
        }
    },
    FOOD_TROUGH_SPAWN                       = {
        {
            POSITION = vector3(3.48382, -5.46772671, -3.11693931),
            ROTATION = vector3(0, 0, 0)
        },
        {
            POSITION = vector3(3.48382, 1.03849936, -3.11693931),
            ROTATION = vector3(0, 0, 0)
        }
    },
    WATER_TROUGH_SPAWN                      = {
        {
            POSITION = vector3(-3.580816, 2.294584, -3.116939),
            ROTATION = vector3(0, 0, 0)
        },
        {
            POSITION = vector3(-3.580816, -2.165429, -3.116939),
            ROTATION = vector3(0, 0, 0)
        },
        {
            POSITION = vector3(-3.580816, -6.593034, -3.116939),
            ROTATION = vector3(0, 0, 0)
        }
    },
    PITCHFORK_SPAWN                         = {
        {
            POSITION = vector3(-3.012, 4.906, -3.142),
            ROTATION = vector3(-15, 0, -180)
        },
        {
            POSITION = vector3(-3.523, 4.906, -3.142),
            ROTATION = vector3(-15, 0, -180)
        }
    },
    STRAW_SPAWN                             = {
        {
            POSITION = vector3(2.85, 7.64, -3.35),
            ROTATION = vector3(0, 0, 0)
        }
    },
    WATERTIP_SPAWN                          = {
        {
            POSITION = vector3(3.807, 5.446, -3.117),
            ROTATION = vector3(0, 0, -90)
        }
    }
}

return Config
