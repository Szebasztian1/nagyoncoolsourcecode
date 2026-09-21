-- Add weapons to the 'compatable_weapon_hashes' table below to make them show up on a player's back (can use GetHashKey(...) if you don't know the hash) --
local SETTINGS = {
    back_bone = 24816,
    x = 0.2,
    y = -0.18,
    z = -0.02,
    x_rotation = 0.0,
    y_rotation = 165.0,
    z_rotation = 0.0,
    compatable_weapon_hashes = {
      ---- melee:
      ----["prop_golf_iron_01"] = 1141786504, -- positioning still needs work
      --["w_me_bat"] = 'WEAPON_BAT',
	    ["w_me_cherrykat_lr"] = 'WEAPON_CHERRYKATANAS',
	    ["w_me_thermalkat_lr"] = 'WEAPON_THERMALKATANAS',
      ----["prop_ld_jerrycan_01"] = 883325847,
      ---- assault rifles:
      --["w_ar_carbinerifle"] = 'WEAPON_CARBINERIFLE',
      --["w_ar_carbineriflemk2"] = "WEAPON_CARBINERIFLE_MK2",
      --["w_ar_assaultrifle"] = 'WEAPON_ASSAULTRIFLE',
      --["w_ar_specialcarbine"] = 'WEAPON_SPECIALCARBINE',
      --["w_ar_bullpuprifle"] = 'WEAPON_BULLPUPRIFLE',
      --["w_ar_advancedrifle"] = 'WEAPON_ADVANCEDRIFLE',
      ---- sub machine guns:
      --["w_sb_microsmg"] = 'WEAPON_MICROSMG',
      --["w_sb_assaultsmg"] = 'WEAPON_ASSAULTSMG',
      --["w_sb_smg"] = 'WEAPON_SMG',
      --["w_sb_smgmk2"] = "WEAPON_SMGMK2",
      --["w_sb_gusenberg"] = 'WEAPON_GUSENBERG',
      ---- sniper rifles:
      ["w_sr_sniperrifle"] = 'WEAPON_SNIPERRIFLE',
      ---- shotguns:
      --["w_sg_assaultshotgun"] = 'WEAPON_ASSAULTSHOTGUN',
      --["w_sg_bullpupshotgun"] = 'WEAPON_BULLPUPSHOTGUN',
      --["w_sg_pumpshotgun"] = 'WEAPON_PUMPSHOTGUN',
      --["w_ar_musket"] = 'WEAPON_MUSKET',
      --["w_sg_heavyshotgun"] = "WEAPON_HEAVYSHOTGUN",

      --["w_pi_pistol"] = "WEAPON_PISTOL",
      -- ["w_sg_sawnoff"] = 2017895192 don't show, maybe too small?
      -- launchers:
      --["w_lr_firework"] = 2138347493
    },
    custom2 = {
        WEAPON_ASSAULTSHOTGUN = {
        Model = "w_sg_assaultshotgun",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = 0.13,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_BULLPUPSHOTGUN = {
        Model = "w_sg_bullpupshotgun",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = 0.0,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_PUMPSHOTGUN = {
        Model = "w_sg_pumpshotgun",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = -0.13,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_MUSKET = {
        Model = "w_ar_musket",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = -0.13,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_HEAVYSHOTGUN = {
        Model = "w_sg_heavyshotgun",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = 0.13,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_CARBINERIFLE = {
        Model = "w_ar_carbinerifle",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = 0.13,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_CARBINERIFLE_MK2 = {
        Model = "w_ar_carbineriflemk2",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = 0.13,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_ASSAULTRIFLE = {
        Model = "w_ar_assaultrifle",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = 0.0,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_SPECIALCARBINE = {
        Model = "w_ar_specialcarbine",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = 0.0,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_BULLPUPRIFLE = {
        Model = "w_ar_bullpuprifle",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = -0.13,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },
      WEAPON_ADVANCEDRIFLE = {
        Model = "w_ar_advancedrifle",
        Bone = 24816,
    xPos = 0.285,
    yPos = -0.17,
    zPos = -0.13,
    xRot = 0.0,
    yRot = 170.0,
    zRot = 0.0,
      },


    },
    custom3 = {
        WEAPON_MICROSMG = {
        Model = "w_sb_microsmg",
        Bone = 24818,
    xPos = -0.03,
    yPos = 0.19,
    zPos = 0.0,
    xRot = -10.0,
    yRot = 40.0,
    zRot = 5.0,
      },
      WEAPON_ASSAULTSMG = {
        Model = "w_sb_assaultsmg",
        Bone = 24818,
    xPos = -0.03,
    yPos = 0.19,
    zPos = 0.0,
    xRot = -10.0,
    yRot = 40.0,
    zRot = 5.0,
      },
      WEAPON_SMG = {
        Model = "w_sb_smg",
        Bone = 24818,
    xPos = -0.03,
    yPos = 0.19,
    zPos = 0.0,
    xRot = -10.0,
    yRot = 40.0,
    zRot = 5.0,
      },
      WEAPON_SMGMK2 = {
        Model = "w_sb_smgmk2",
        Bone = 24818,
    xPos = -0.03,
    yPos = 0.19,
    zPos = 0.0,
    xRot = -10.0,
    yRot = 40.0,
    zRot = 5.0,
      },
      WEAPON_GUSENBERG = {
        Model = "w_sb_gusenberg",
        Bone = 24818,
    xPos = -0.03,
    yPos = 0.19,
    zPos = 0.0,
    xRot = -10.0,
    yRot = 40.0,
    zRot = 5.0,
      },
    },
    customs = { 
      --[[WEAPON_PISTOL = {
        Model = "w_pi_pistol",
        Bone = 24816,
    xPos = 0.0,
    yPos = -0.18,
    zPos = 0.0,
    xRot = 0.0,
    yRot = 165.0,
    zRot = 0.0,
      },]]
      

    


     

      
      hnganh_puppysssv3 = {   
        Model = "hnganh_puppysssv3", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.28, yPos = -0.300, zPos = 0.0, xRot = 0.0, yRot = 90.000, zRot = 0.000,
      },
      hnganh_goose = {   
        Model = "hnganh_goose", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_anya = {   
        Model = "hnganh_anya", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_bagdino = {   
        Model = "hnganh_bagdino", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_bmo = {   
        Model = "hnganh_bmo", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_dragonsun = {   
        Model = "hnganh_dragonsun", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_scooby = {   
        Model = "hnganh_scooby", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.28, yPos = -0.300, zPos = 0.0, xRot = 0.0, yRot = 90.000, zRot = 0.000,
      },
      hnganh_bee2 = {   
        Model = "hnganh_bee2", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_magickitty = {   
        Model = "hnganh_magickitty", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_stichv2 = {   
        Model = "hnganh_stichv2", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.28, yPos = -0.300, zPos = 0.0, xRot = 0.0, yRot = 90.000, zRot = 0.000,
      },
      hnganh_naughty = {   
        Model = "hnganh_naughty", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_politoed = {   
        Model = "hnganh_politoed", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_toddler = {   
        Model = "hnganh_toddler", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_bird = {   
        Model = "hnganh_bird", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_bunny = {   
        Model = "hnganh_bunny", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_dachshund = {   
        Model = "hnganh_dachshund", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_gingerbread = {   
        Model = "hnganh_gingerbread", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_polarbear = {   
        Model = "hnganh_polarbear", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_puppyv3 = {   
        Model = "hnganh_puppyv3", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_santaclaus = {   
        Model = "hnganh_santaclaus", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_sealbag = {   
        Model = "hnganh_sealbag", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_squirrel = {   
        Model = "hnganh_squirrel", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_walle = {   
        Model = "hnganh_walle", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.28, yPos = -0.300, zPos = 0.0, xRot = 0.0, yRot = 90.000, zRot = 0.000,
      },
      hnganh_canhcutgs = {   
        Model = "hnganh_canhcutgs", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_axolo1t = {   
        Model = "hnganh_axolo1t", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_cowboy = {   
        Model = "hnganh_cowboy", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_cutefeline = {   
        Model = "hnganh_cutefeline", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_yellow = {   
        Model = "hnganh_yellow", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_grinch = {   
        Model = "hnganh_grinch", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_reindeer = {   
        Model = "hnganh_reindeer", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      hnganh_snowman = {   
        Model = "hnganh_snowman", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      toxic_gloomy_bear_bag_01 = {   
        Model = "toxic_gloomy_bear_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_gloomy_bear_bag_02 = {   
        Model = "toxic_gloomy_bear_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_kuma_bag_01 = {   
        Model = "toxic_kuma_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_mew_bag_01 = {   
        Model = "toxic_mew_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_polar_bear_bag_01 = {   
        Model = "toxic_polar_bear_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_snorlax_bag_01 = {   
        Model = "toxic_snorlax_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_teddy_bag_01 = {   
        Model = "toxic_teddy_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_usahanna_bag_01 = {   
        Model = "toxic_usahanna_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_dino_bag_01 = {   
        Model = "toxic_dino_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_mobidick_bag_01 = {   
        Model = "toxic_mobidick_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_pig_bag_01 = {   
        Model = "toxic_pig_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_skull_teddy_bag_01 = {   
        Model = "toxic_skull_teddy_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_alyx_bag_01 = {   
        Model = "toxic_alyx_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_cat_bag_01 = {   
        Model = "toxic_cat_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_hello_kitty_bag_01 = {   
        Model = "toxic_hello_kitty_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_tactical_bag_01 = {   
        Model = "toxic_tactical_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_watchdog_bag_01 = {   
        Model = "toxic_watchdog_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_baby_shark_bag_01 = {   
        Model = "toxic_baby_shark_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_baby_shark_bag_02 = {   
        Model = "toxic_baby_shark_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_doom_daze_fur_bag_01 = {   
        Model = "toxic_doom_daze_fur_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_doom_daze_fur_bag_02 = {   
        Model = "toxic_doom_daze_fur_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_doom_daze_fur_bag_03 = {   
        Model = "toxic_doom_daze_fur_bag_03", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_doom_daze_leather_bag_01 = {   
        Model = "toxic_doom_daze_leather_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_doom_daze_leather_bag_02 = {   
        Model = "toxic_doom_daze_leather_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_hearth_bag_01 = {   
        Model = "toxic_hearth_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_hearth_bag_02 = {   
        Model = "toxic_hearth_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_katana_bag_01 = {   
        Model = "toxic_katana_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_minecraft_hearth_bag_01 = {   
        Model = "toxic_minecraft_hearth_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_neon_shark_bag_01 = {   
        Model = "toxic_neon_shark_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_neon_shark_bag_02 = {   
        Model = "toxic_neon_shark_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_neon_shark_bag_03 = {   
        Model = "toxic_neon_shark_bag_03", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_skateboard_bag_01 = {   
        Model = "toxic_skateboard_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_skateboard_bag_02 = {   
        Model = "toxic_skateboard_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_skateboard_bag_03 = {   
        Model = "toxic_skateboard_bag_03", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_skateboard_bag_04 = {   
        Model = "toxic_skateboard_bag_04", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_skateboard_bag_05 = {   
        Model = "toxic_skateboard_bag_05", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_skateboard_bag_06 = {   
        Model = "toxic_skateboard_bag_06", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_spray_ground_bag_01 = {   
        Model = "toxic_spray_ground_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 190.000,
      },
      toxic_grinch_bag_01 = {   
        Model = "toxic_grinch_bag_01", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_grinch_bag_02 = {   
        Model = "toxic_grinch_bag_02", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_grinch_bag_03 = {   
        Model = "toxic_grinch_bag_03", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_grinch_bag_04 = {   
        Model = "toxic_grinch_bag_04", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      toxic_grinch_bag_05 = {   
        Model = "toxic_grinch_bag_05", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 90.000,
      },
      --bc_newbackpack_1 = {   
      --  Model = "bc_newbackpack_1", --[[ Modelname ]]
      --  Bone = 24818,
      --  xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      --},
      --bc_newbackpack_2 = {   
      --  Model = "bc_newbackpack_2", --[[ Modelname ]]
      --  Bone = 24818,
      --  xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      --},
      --bc_newbackpack_3 = {   
      --  Model = "bc_newbackpack_3", --[[ Modelname ]]
      --  Bone = 24818,
      --  xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      --},
      --bc_newbackpack_4 = {   
      --  Model = "bc_newbackpack_4", --[[ Modelname ]]
      --  Bone = 24818,
      --  xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      --},
      --bc_newbackpack_5 = {   
      --  Model = "bc_newbackpack_5", --[[ Modelname ]]
      --  Bone = 24818,
      --  xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      --},
      --bc_newbackpack_6 = {   
      --  Model = "bc_newbackpack_6", --[[ Modelname ]]
      --  Bone = 24818,
      --  xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      --},
      --  bc_newbackpack_7 = {   
      --  Model = "bc_newbackpack_7", --[[ Modelname ]]
      --  Bone = 24818,
      --  xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000, -- 1. előre hátra,2. jobra balra, 3. tengely, 
      --},
      bc_newbackpack_8 = {
        Model = "bc_newbackpack_8", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_9 = {
        Model = "bc_newbackpack_9", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_10 = {
        Model = "bc_newbackpack_10", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_11 = {
        Model = "bc_newbackpack_11", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_12 = {
        Model = "bc_newbackpack_12", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_13 = {
        Model = "bc_newbackpack_13", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_14 = {
        Model = "bc_newbackpack_14", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_15 = {
        Model = "bc_newbackpack_15", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_16 = {
        Model = "bc_newbackpack_16", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_17 = {
        Model = "bc_newbackpack_17", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_18 = {
        Model = "bc_newbackpack_18", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_19 = {
        Model = "bc_newbackpack_19", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_20 = {
        Model = "bc_newbackpack_20", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_21 = {
        Model = "bc_newbackpack_21", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_22 = {
        Model = "bc_newbackpack_22", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_23 = {
        Model = "bc_newbackpack_23", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_24 = {
        Model = "bc_newbackpack_24", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_25 = {
        Model = "bc_newbackpack_25", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
      bc_newbackpack_26 = {
        Model = "bc_newbackpack_26", --[[ Modelname ]]
        Bone = 24818,
        xPos = -0.289, yPos = 0.000, zPos = 0.003, xRot = 183.500, yRot = 90.000, zRot = 0.000,
      },
    }
}

local attached_weapons = {}

--[[Citizen.CreateThread(function()
  while true do
      local me = GetPlayerPed(-1)
      ---------------------------------------
      -- attach if player has large weapon --
      ---------------------------------------
      for wep_name, wep_hash in pairs(SETTINGS.compatable_weapon_hashes) do
          if HasPedGotWeapon(me, wep_hash, false) then
              if not attached_weapons[wep_name] then
                  AttachWeapon(wep_name, wep_hash, SETTINGS.back_bone, SETTINGS.x, SETTINGS.y, SETTINGS.z, SETTINGS.x_rotation, SETTINGS.y_rotation, SETTINGS.z_rotation, isMeleeWeapon(wep_name))
              end
          end
      end
      --------------------------------------------
      -- remove from back if equipped / dropped --
      --------------------------------------------
      for name, attached_object in pairs(attached_weapons) do
          -- equipped? delete it from back:
          if GetSelectedPedWeapon(me) ==  attached_object.hash or not HasPedGotWeapon(me, attached_object.hash, false) then -- equipped or not in weapon wheel
            DeleteObject(attached_object.handle)
            attached_weapons[name] = nil
          end
      end
  Wait(0)
  end
end)]]

local induty = false 
local ingar = false 

AddEventHandler('esx:removeInventoryItem', function(item, count)
  Wait(10)
  Update()
end)
AddEventHandler('esx:addInventoryItem', function(item, count)
  Wait(10)
  Update()
end)
AddEventHandler('ox_inventory:currentWeapon', function(item)
  Wait(10)
  Update()
end)
AddEventHandler('esx:setPlayerData', function(key, val, last)
  if GetInvokingResource() == 'es_extended' then
    Wait(10)
    Update()
  end
end)
AddEventHandler('oxinventoryloaded', function()
  Wait(10000)
  Update()
end)
RegisterNetEvent("bc_duty:on", function()
  Wait(10)
  induty = true 
  Update()
end)
RegisterNetEvent("bc_duty:off", function()
  Wait(10)
  induty = false 
  Update()
end)

RegisterNetEvent("bc:enteredgar", function()
  Wait(10)
  ingar = false 
  Update()
end)
RegisterNetEvent("bc:leftgar", function()
  Wait(10)
  ingar = false 
  Update()
end)


function Update()

  if induty or ingar then 
    for name, attached_object in pairs(attached_weapons) do 
        DeleteObject(attached_object.handle)
        attached_weapons[name] = nil
    end
  else 
  local mycoords = GetEntityCoords(PlayerPedId())
  for name, attached_object in pairs(attached_weapons) do
    if not DoesEntityExist(attached_object.handle) or (GetEntityAttachedTo(attached_object.handle) ~= PlayerPedId()) or #(GetEntityCoords(attached_object.handle) - mycoords) > 1.0 then 
      DeleteObject(attached_object.handle)
      attached_weapons[name] = nil
    
    end 
  end

  for k, v in pairs(SETTINGS.compatable_weapon_hashes) do 
    local count = exports.ox_inventory:Search('count', v)
    --print("Fegyver: "..v.." count: "..count)
    if count > 0 and not attached_weapons[k] then 
      AttachWeapon(k, v, SETTINGS.back_bone, SETTINGS.x, SETTINGS.y, SETTINGS.z, SETTINGS.x_rotation, SETTINGS.y_rotation, SETTINGS.z_rotation, isMeleeWeapon(k)) 
    end 
  end 
  local c1s = false
  for k, v in pairs(SETTINGS.customs) do 
    if not c1s then 
      local count = exports.ox_inventory:Search('count', k)
      --print("Item: "..k.." count: "..count)
      if type(count) == "number" and count > 0 and not attached_weapons[v.Model] then 
        AttachWeapon(v.Model, k, v.Bone, v.xPos, v.yPos, v.zPos, v.xRot, v.yRot, v.zRot, false) 
        c1s = true 
      end 
    end 
  end 
  local c2s = false 
  for k, v in pairs(SETTINGS.custom2) do 
    if not c2s then 
      local count = exports.ox_inventory:Search('count', k)
      --print("Item: "..k.." count: "..count)
      if type(count) == "number" and count > 0 and not attached_weapons[v.Model] then 
        AttachWeapon(v.Model, k, v.Bone, v.xPos, v.yPos, v.zPos, v.xRot, v.yRot, v.zRot, false) 
      end 
      c2s = true  
    end 
  end
  
   local c3s = false 
  for k, v in pairs(SETTINGS.custom3) do 
    if not c3s then 
      local count = exports.ox_inventory:Search('count', k)
      --print("Item: "..k.." count: "..count)
      if type(count) == "number" and count > 0 and not attached_weapons[v.Model] then 
        AttachWeapon(v.Model, k, v.Bone, v.xPos, v.yPos, v.zPos, v.xRot, v.yRot, v.zRot, false) 
      end 
      c3s = true  
    end 
  end 

  for name, attached_object in pairs(attached_weapons) do
    -- equipped? delete it from back:
    local count = exports.ox_inventory:Search('count', attached_object.name)
    --print("Fegyver: "..attached_object.name.." count: "..count)

    if not count or GetSelectedPedWeapon(PlayerPedId()) == attached_object.hash or (count or 0) < 1 then
      DeleteObject(attached_object.handle)
      attached_weapons[name] = nil
    end
  end

  local netobjs = {}
  --print("sendnetobjs")
  for name, attached_object in pairs(attached_weapons) do
    -- attached_object.handle
    local netId = NetworkGetNetworkIdFromEntity(attached_object.handle)
    if netId then 
      netobjs[#netobjs+1] = netId
    end 
  end
 -- print("netobjlist: ", json.encode(netobjs))
  TriggerServerEvent("bc_weapon:myprops", netobjs)
end 
  --print(json.encode(attached_weapons))
end 

function AttachWeapon(attachModel,modelHash,boneNumber,x,y,z,xR,yR,zR, isMelee)
	local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)

  if attached_weapons[attachModel] and attached_weapons[attachModel].handle and DoesEntityExist(attached_weapons[attachModel].handle) then 
    DeleteObject(attached_weapons[attachModel].handle)
  end 
 -- print("model laoding", attachModel)
	RequestModel(GetHashKey(attachModel))
	while not HasModelLoaded(GetHashKey(attachModel)) do
		Wait(100)
	end
 -- print("model laoded", attachModel)

  attached_weapons[attachModel] = {
    name = modelHash,
    hash = GetHashKey(modelHash),
    handle = CreateObject(GetHashKey(attachModel), GetEntityCoords(PlayerPedId()), true, true, false)
  }
  -- bc_kocsitorles: legalis spawn jelolese
  local backProp = attached_weapons[attachModel].handle
  if backProp and backProp ~= 0 and NetworkGetEntityIsNetworked(backProp) then Entity(backProp).state:set('bc_spawned', true, true) end

  if isMelee then x = 0.51 y = -0.17 z = 0.17 xR = 0.0 yR = -116.07 zR = 0.0 end -- reposition for melee items
  if attachModel == "prop_ld_jerrycan_01" then x = x + 0.3 end
	AttachEntityToEntity(attached_weapons[attachModel].handle, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
end

function isMeleeWeapon(wep_name)
    if wep_name == "prop_golf_iron_01" then
        return true
    elseif wep_name == "w_me_bat" then
        return true
    elseif wep_name == "prop_ld_jerrycan_01" then
      return true
    elseif wep_name == "w_me_cherrykat_lr" then
      return true
    elseif wep_name == "w_me_thermalkat_lr" then
      return true
    else
        return false
    end
end

--=====================================================================================
-- Ped-csere (/reloadskin, ruhabolt, job-ped, spawn) - 2026-09-07
--
-- A SetPlayerModel nem atoltoztet, hanem KICSERELI a ped entitast: a haton levo
-- fegyver- es taska-propok gazdatlanul a levegoben maradnak.
--
-- Az Update() ezt mar kezeli (eldobja, ami nem a mostani peden log, es ujra felrakja),
-- csak eddig senki nem szolt neki ped-csere utan. A frissitett netId-lista a szerverre
-- is kimegy, igy az s.lua az arvakat vegleg el tudja tuntetni.
--=====================================================================================

CreateThread(function()
    local lastPed = PlayerPedId()

    while true do
        Wait(500)

        local ped = PlayerPedId()

        if ped ~= lastPed then
            lastPed = ped

            -- megvarjuk, hogy a ruha es a loadout is a helyere keruljon
            Wait(1500)
            Update()
        end
    end
end)
