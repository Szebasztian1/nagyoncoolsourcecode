Config = {}

Config.DisableDeleteBeforeAuction = 60 * 60 * 12 -- 12 hours

function deepcopy(orig, seen)
    if type(orig) ~= 'table' then -- number, string, boolean, etc
        return orig
    end

    -- Korkoros hivatkozas elleni vedelem. A json.decode (lua_rapidjson) altal visszaadott
    -- tablak metatablaja onmagara hivatkozik, e nelkul a masolas vegtelen rekurzioba fut
    -- (stack overflow).
    seen = seen or {}
    if seen[orig] then
        return seen[orig]
    end

    local copy = {}
    seen[orig] = copy
    for orig_key, orig_value in next, orig, nil do
        copy[deepcopy(orig_key, seen)] = deepcopy(orig_value, seen)
    end

    -- A metatablat megosztjuk, NEM masoljuk (a json __jsontype jelolese igy is megmarad).
    return setmetatable(copy, getmetatable(orig))
end

local TRASHBAGS = {
    hnganh_puppysssv3 = {
        Model = "hnganh_puppysssv3", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_goose = {
        Model = "hnganh_goose", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_anya = {
        Model = "hnganh_anya", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_bagdino = {
        Model = "hnganh_bagdino", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_bmo = {
        Model = "hnganh_bmo", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_dragonsun = {
        Model = "hnganh_dragonsun", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_scooby = {
        Model = "hnganh_scooby", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_bee2 = {
        Model = "hnganh_bee2", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_magickitty = {
        Model = "hnganh_magickitty", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_stichv2 = {
        Model = "hnganh_stichv2", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_naughty = {
        Model = "hnganh_naughty", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_politoed = {
        Model = "hnganh_politoed", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_toddler = {
        Model = "hnganh_toddler", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_bird = {
        Model = "hnganh_bird", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_bunny = {
        Model = "hnganh_bunny", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_dachshund = {
        Model = "hnganh_dachshund", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_gingerbread = {
        Model = "hnganh_gingerbread", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_polarbear = {
        Model = "hnganh_polarbear", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_puppyv3 = {
        Model = "hnganh_puppyv3", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_santaclaus = {
        Model = "hnganh_santaclaus", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_sealbag = {
        Model = "hnganh_sealbag", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_squirrel = {
        Model = "hnganh_squirrel", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_walle = {
        Model = "hnganh_walle", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_canhcutgs = {
        Model = "hnganh_canhcutgs", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_axolo1t = {
        Model = "hnganh_axolo1t", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_cowboy = {
        Model = "hnganh_cowboy", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_cutefeline = {
        Model = "hnganh_cutefeline", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_yellow = {
        Model = "hnganh_yellow", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_grinch = {
        Model = "hnganh_grinch", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_reindeer = {
        Model = "hnganh_reindeer", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    hnganh_snowman = {
        Model = "hnganh_snowman", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    toxic_gloomy_bear_bag_01 = {
        Model = "toxic_gloomy_bear_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_gloomy_bear_bag_02 = {
        Model = "toxic_gloomy_bear_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_kuma_bag_01 = {
        Model = "toxic_kuma_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_mew_bag_01 = {
        Model = "toxic_mew_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_polar_bear_bag_01 = {
        Model = "toxic_polar_bear_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_snorlax_bag_01 = {
        Model = "toxic_snorlax_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_teddy_bag_01 = {
        Model = "toxic_teddy_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_usahanna_bag_01 = {
        Model = "toxic_usahanna_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_dino_bag_01 = {
        Model = "toxic_dino_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_mobidick_bag_01 = {
        Model = "toxic_mobidick_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_pig_bag_01 = {
        Model = "toxic_pig_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_skull_teddy_bag_01 = {
        Model = "toxic_skull_teddy_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_alyx_bag_01 = {
        Model = "toxic_alyx_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_cat_bag_01 = {
        Model = "toxic_cat_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_hello_kitty_bag_01 = {
        Model = "toxic_hello_kitty_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_tactical_bag_01 = {
        Model = "toxic_tactical_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_watchdog_bag_01 = {
        Model = "toxic_watchdog_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_baby_shark_bag_01 = {
        Model = "toxic_baby_shark_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_baby_shark_bag_02 = {
        Model = "toxic_baby_shark_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_doom_daze_fur_bag_01 = {
        Model = "toxic_doom_daze_fur_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_doom_daze_fur_bag_02 = {
        Model = "toxic_doom_daze_fur_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_doom_daze_fur_bag_03 = {
        Model = "toxic_doom_daze_fur_bag_03", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_doom_daze_leather_bag_01 = {
        Model = "toxic_doom_daze_leather_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_doom_daze_leather_bag_02 = {
        Model = "toxic_doom_daze_leather_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_hearth_bag_01 = {
        Model = "toxic_hearth_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_hearth_bag_02 = {
        Model = "toxic_hearth_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_katana_bag_01 = {
        Model = "toxic_katana_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_minecraft_hearth_bag_01 = {
        Model = "toxic_minecraft_hearth_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_neon_shark_bag_01 = {
        Model = "toxic_neon_shark_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_neon_shark_bag_02 = {
        Model = "toxic_neon_shark_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_neon_shark_bag_03 = {
        Model = "toxic_neon_shark_bag_03", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_skateboard_bag_01 = {
        Model = "toxic_skateboard_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_skateboard_bag_02 = {
        Model = "toxic_skateboard_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_skateboard_bag_03 = {
        Model = "toxic_skateboard_bag_03", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_skateboard_bag_04 = {
        Model = "toxic_skateboard_bag_04", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_skateboard_bag_05 = {
        Model = "toxic_skateboard_bag_05", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_skateboard_bag_06 = {
        Model = "toxic_skateboard_bag_06", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_spray_ground_bag_01 = {
        Model = "toxic_spray_ground_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 190.000,
    },
    toxic_grinch_bag_01 = {
        Model = "toxic_grinch_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_grinch_bag_02 = {
        Model = "toxic_grinch_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_grinch_bag_03 = {
        Model = "toxic_grinch_bag_03", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    toxic_grinch_bag_04 = {
        Model = "toxic_grinch_bag_04", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 90.000,
    },
    bc_newbackpack_1 = {
        Model = "bc_newbackpack_1", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    bc_newbackpack_2 = {
        Model = "bc_newbackpack_2", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    bc_newbackpack_3 = {
        Model = "bc_newbackpack_3", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    bc_newbackpack_4 = {
        Model = "bc_newbackpack_4", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    bc_newbackpack_5 = {
        Model = "bc_newbackpack_5", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    bc_newbackpack_6 = {
        Model = "bc_newbackpack_6", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000,
    },
    bc_newbackpack_7 = {
        Model = "bc_newbackpack_7", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_8 = {
        Model = "bc_newbackpack_8", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_9 = {
        Model = "bc_newbackpack_9", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_10 = {
        Model = "bc_newbackpack_10", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_11 = {
        Model = "bc_newbackpack_11", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_12 = {
        Model = "bc_newbackpack_12", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_13 = {
        Model = "bc_newbackpack_13", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_14 = {
        Model = "bc_newbackpack_14", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_15 = {
        Model = "bc_newbackpack_15", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_16 = {
        Model = "bc_newbackpack_16", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_17 = {
        Model = "bc_newbackpack_17", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_18 = {
        Model = "bc_newbackpack_18", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_19 = {
        Model = "bc_newbackpack_19", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_20 = {
        Model = "bc_newbackpack_20", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_21 = {
        Model = "bc_newbackpack_21", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_22 = {
        Model = "bc_newbackpack_22", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_23 = {
        Model = "bc_newbackpack_23", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_24 = {
        Model = "bc_newbackpack_24", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_25 = {
        Model = "bc_newbackpack_25", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    bc_newbackpack_26 = {
        Model = "bc_newbackpack_26", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289,
        yPos = 0.000,
        zPos = 0.003,
        xRot = 183.500,
        yRot = 90.000,
        zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely,
    },
    toxic_grinch_bag_05 = true,
}

local itemNames


Config.AuctionItems = {
    ["pp"] = {
        label = "PrémiumPont (-5% adó)",

        sellprice = 1.0,
        -- minBidPercent = 0.01,

        GetItemLabel = function(src, item, count)
            return count .. "x PP (-5% adó)"
        end,                        -- false player set the label in the menu
        GetItemDescription = false, -- false player set the label in the menu
        GetItemImage = function(src, item, count)
            return "https://cdn-icons-png.freepik.com/256/11039/11039447.png?semt=ais_hybrid"
        end,                              -- false player set the label in the menu

        GetPlayerItems = function(source) -- {{id="asd", label="asd", count=1}}
            local count = exports["bc_ppshop"]:getpp(source)
            if count < 1 then
                return {}
            end
            return { { id = "pp", label = "PP", count = count } }
        end,

        TakePlayerItem = function(source, item, count)
            if item ~= "pp" then
                return false
            end
            local c = exports["bc_ppshop"]:getpp(source)
            if c < count then
                return false
            end

            return exports["bc_ppshop"]:removepp(source, count)
        end,

        GivePlayerItem = function(identifier, item, count, saved, sold)
            print("ppadd", identifier)
            local user = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
                ['@identifier'] = identifier,
            })
            if not user and not user[1] then
                return false
            end
            local steam = user[1].steam
            print("ppadd", steam)
            if not steam then return false end

            TriggerEvent('esx:toDiscord',
                '```diff\n- PP ADD\n```\n```css\n [PLAYER]: ' ..
                steam .. '\n[PONT]: ' .. count .. '\n[SCRIPT]: ' .. "bc_auction" .. '```',
                'https://discord.com/api/webhooks/1356763464055656648/TduUWJcjiI7Nd2ItmptT0oGqWu6ZXzec_DAN4aDTbRjz4v0oC8SCckcvzsMbJ5DZxmI7')

            MySQL.Async.fetchAll('SELECT 1 FROM premiumpont WHERE identifier = @identifier', {
                ['@identifier'] = steam
            }, function(result)
                print("ppadd", result)
                if result[1] then
                    MySQL.Async.execute('UPDATE premiumpont SET pont = pont + @pont WHERE identifier = @identifier', {
                        ['@identifier'] = steam,
                        ['@pont'] = (sold and math.floor(count * 0.95) or count)
                    })

                    print("ppadd", count, "added")
                else
                    MySQL.Async.execute('INSERT INTO premiumpont (identifier, pont) VALUES (@identifier, @pont)', {
                        ['@identifier'] = steam,
                        ['@pont'] = (sold and math.floor(count * 0.95) or count)
                    })

                    print("ppadd", count, "inserted")
                end
            end)
        end,

        properties = {
        },

        GetAutoProperties = function(source, item)
            return {}
        end,

    },
    ["car"] = {
        label = "Autó",

        sellprice = 1.0,
        minBidPercent = 0.01,

        GetItemLabel = false,                                                  -- false player set the label in the menu
        GetItemDescription = false,                                            -- false player set the label in the menu
        GetItemImage = function(src, plate, count)
            local pic = lib.callback.await('bc_auction:getVehPic', src, plate) --TODO
            if not pic then
                return
                "https://static.vecteezy.com/system/resources/previews/024/281/833/non_2x/3d-question-mark-sign-in-black-and-white-color-vector.jpg"
            end
            return pic
        end,                              -- false player set the label in the menu

        GetPlayerItems = function(source) -- {{id="asd", label="asd", count=1}}
            local xPlayer = ESX.GetPlayerFromId(source)
            local data = {}
            local vehicles = MySQL.Sync.fetchAll(
                'SELECT * FROM owned_vehicles WHERE owner = @owner AND `type` = @type AND job = @job AND stored = @stored',
                {
                    ['@owner'] = xPlayer.identifier,
                    ['@type'] = "car",
                    ['@job'] = 'civ',
                    ['@stored'] = true
                })
            for i = 1, #vehicles do
                data[#data + 1] = { id = vehicles[i].plate, label = vehicles[i].plate }
            end
            return data
        end,

        TakePlayerItem = function(source, item, count)
            local ar = MySQL.Sync.execute('UPDATE owned_vehicles SET owner = @owner WHERE plate = @plate', {
                ['@owner'] = "bc_auction",
                ['@plate'] = item
            })

            if ar < 1 then
                return false
            end

            return item
        end,

        GivePlayerItem = function(identifier, item, count, saved, sold)
            MySQL.Async.execute('UPDATE owned_vehicles SET owner = @owner WHERE plate = @plate', {
                ['@owner'] = identifier,
                ['@plate'] = item
            })
        end,

        properties = {
            {
                name = "carRarity",
                label = "Autó Ritkasága",
                type = "select",
                options = { "Egyedi", "Limitált", "Alap" },
                important = true,
                searchable = true,
                default = "Alap",
                playerEditable = true
            },
            {
                name = "modTurbo",
                label = "Turbó",
                type = "boolean",
                important = false,
                searchable = true,
                default = false,
                playerEditable = false
            },
            {
                name = "modEngine",
                label = "Motor tuning",
                type = "number",
                min = 0,
                max = 4,
                important = false,
                searchable = true,
                default = 0,
                playerEditable = false
            },
            {
                name = "modBrakes",
                label = "Fék tuning",
                type = "number",
                min = 0,
                max = 4,
                important = false,
                searchable = true,
                default = 0,
                playerEditable = false
            },
            {
                name = "TEST",
                label = "Tesztelhető",
                type = "boolean",
                important = false,
                searchable = false,
                default = true,
                playerEditable = false
            },
        },

        GetAutoProperties = function(source, item)
            local xPlayer = ESX.GetPlayerFromId(source)
            local vehicle = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {
                ['@plate'] = item
            })
            if vehicle[1] then
                local veh = json.decode(vehicle[1].vehicle)
                return {
                    modTurbo = veh.modTurbo,
                    modEngine = veh.modEngine,
                    modBrakes = veh.modBrakes
                }
            end
            return false
        end,

        PlayerTest = function(source, item, count, saved)
            local vehicle = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {
                ['@plate'] = item
            })

            if not vehicle[1] then
                return false
            end
            print("playertest", item, source)
            TriggerClientEvent('bc_auction:spawnVehicle', source, json.decode(vehicle[1].vehicle))
        end

    },


    ["haz"] = {
        label = "Ház",

        sellprice = 1.0,
        minBidPercent = 0.001,

        GetItemLabel = function(src, item, count)
            return "Ház - " .. item
        end,                        -- false player set the label in the menu
        GetItemDescription = false, -- false player set the label in the menu
        GetItemImage = function(src, item, count)
            return
            "https://thumbs.dreamstime.com/b/house-icon-flat-style-home-vector-illustration-isolated-background-building-sign-business-concept-372515313.jpg"
        end, -- false player set the label in the menu

        GetPlayerItems = function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            local houses = MySQL.Sync.fetchAll('SELECT * FROM loaf_housing WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier,
            })
            if not houses or not houses[1] or not houses[1].housedata then
                return {}
            end
            local h = json.decode(houses[1].housedata)
            if not h then return {} end
            local s = {}
            for k, v in pairs(h) do
                s[#s + 1] = { id = k, label = "Ház " .. k }
            end
            return s
        end,

        TakePlayerItem = function(source, item, count)
            item = tostring(item)
            local xPlayer = ESX.GetPlayerFromId(source)
            local houses = MySQL.Sync.fetchAll('SELECT * FROM loaf_housing WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier,
            })
            if not houses or not houses[1] or not houses[1].housedata then
                return false
            end

            local h = json.decode(houses[1].housedata)
            -- Ha a jatekosnak nincs meg ez a haza, ne nyuljunk a tulajdonoshoz es a kulcsokhoz.
            if type(h) ~= 'table' or not h[item] then
                return false
            end

            local saved = deepcopy(h[item])
            h[item] = nil
            MySQL.Async.execute('UPDATE loaf_housing SET housedata = @housedata WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier,
                ['@housedata'] = json.encode(h)
            })
            MySQL.Async.execute('UPDATE loaf_bought_houses SET owner = @owner WHERE houseid = @houseid', {
                ['@owner'] = "bc_auction",
                ['@houseid'] = item
            })
            MySQL.Async.execute('DELETE FROM loaf_keys WHERE key_id = @key_id', {
                ['@key_id'] = "house_" .. item
            })

            return saved
        end,

        GivePlayerItem = function(identifier, item, count, saved, sold)
            item = tostring(item)
            local houses = MySQL.Sync.fetchAll('SELECT * FROM loaf_housing WHERE identifier = @identifier', {
                ['@identifier'] = identifier,
            })
            if not houses or not houses[1] then
                local h = {}
                h[item] = saved
                MySQL.Async.execute('INSERT INTO loaf_housing (identifier, housedata) VALUES (@identifier, @housedata)',
                    {
                        ['@identifier'] = identifier,
                        ['@housedata'] = json.encode(h)
                    })
            else
                local h = json.decode(houses[1].housedata)
                h[item] = saved
                MySQL.Async.execute('UPDATE loaf_housing SET housedata = @housedata WHERE identifier = @identifier', {
                    ['@identifier'] = identifier,
                    ['@housedata'] = json.encode(h)
                })
            end

            MySQL.Async.execute('UPDATE loaf_bought_houses SET owner = @owner WHERE houseid = @houseid', {
                ['@owner'] = identifier,
                ['@houseid'] = item
            })
            return saved
        end,

        properties = {
            {
                name = "TEST",
                label = "Tesztelhető",
                type = "boolean",
                important = false,
                searchable = false,
                default = true,
                playerEditable = false
            },
        },

        GetAutoProperties = function(source, item)
            return {}
        end,

        PlayerTest = function(source, item, count, saved)
            item = tostring(item)
            TriggerClientEvent("bc_house:pingonmap", source, tonumber(item))
        end
    },

    ["taska"] = {
        label = "Trash Táska",

        sellprice = 1.0,
        minBidPercent = 0.001,

        GetItemLabel = function(src, item, count)
            if not itemNames then
                itemNames = {}
                for item, data in pairs(exports.ox_inventory:Items()) do
                    itemNames[item] = data.label
                end
            end
            if not itemNames[item] then
                return "?"
            end
            return "Táska - " .. itemNames[item]
        end,                        -- false player set the label in the menu
        GetItemDescription = false, -- false player set the label in the menu
        GetItemImage = function(src, item, count)
            return "nui://ox_inventory/web/images/" .. item .. ".webp"
        end,                              -- false player set the label in the menu

        GetPlayerItems = function(source) -- {{id="asd", label="asd", count=1}}
            if not itemNames then
                itemNames = {}
                for item, data in pairs(exports.ox_inventory:Items()) do
                    itemNames[item] = data.label
                end
            end
            local s = {}
            local playerItems = exports.ox_inventory:GetInventoryItems(source)
            local itemok = false
            for _, slotData in pairs(playerItems) do
                if slotData and TRASHBAGS[slotData.name] then
                    if slotData.count == 1 then
                        s[#s + 1] = { id = slotData.slot, label = "Táska - " .. itemNames[slotData.name] }
                    end
                end
            end

            return s
        end,

        TakePlayerItem = function(source, item, count)
            local saved = false
            local slotdata = exports.ox_inventory:GetSlot(source, item)
            if not slotdata then
                return false
            end
            if not TRASHBAGS[slotdata.name] then
                return false
            end

            if exports.ox_inventory:RemoveItem(source, slotdata.name, 1, slotdata.metadata, item) then
                saved = slotdata
                return saved
            end

            return false
        end,

        GivePlayerItem = function(identifier, item, count, saved, sold)
            local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
            if xPlayer then
                xPlayer.addInventoryItem(item, 1)
            end

            local inv = MySQL.Sync.fetchAll('SELECT inventory FROM users WHERE identifier = @identifier', {
                ['@identifier'] = identifier,
            })
            if not inv or not inv[1] then
                return
            end
            inv = json.decode(inv[1].inventory)

            local freeslot = 51
            local usedslots = {}
            for k, v in pairs(inv) do
                usedslots[v.slot] = true
            end
            for i = 1, 50 do
                if not usedslots[i] then
                    freeslot = i
                    break
                end
            end
            inv[#inv + 1] = {
                name = item,
                slot = freeslot,
                count = 1,
                metadata = saved.metadata
            }

            return saved
        end,

        properties = {
        },

        GetAutoProperties = function(source, item)
            return {}
        end,

        PlayerTest = false
    },
}
