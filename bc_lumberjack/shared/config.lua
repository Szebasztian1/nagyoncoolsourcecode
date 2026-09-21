Config = {}

Config.locales = "hu"

Config.ClothRoom = { x = -566.12414550781, y = 5326.0908203125, z = 72.892842102051, blip = true }

Config.NPC = {
    name = "[~b~Mark~s~]~n~Favágó főnök",
    model = GetHashKey("a_m_y_business_02"),
    x = -606.78,
    y = 5300.2,
    z = 69.5,
    h = 221.2
}

Config.TreeZone = { x = -513.57, y = 5523.58, z = 70.06, radius = 40, blip = true }
Config.AxeItem = "axe" --  IMPORTANT! Database item name for tree cut
Config.AxePrice = 390
Config.AxeObject = GetHashKey('w_me_battleaxe')
Config.ChanceToBreakAxe = 3 -- Percentage to break the axe 0-100

Config.Process = {
    Blip = { x = -576.77, y = 5249.45, z = 70.47 },
    Pos = {
        { x = -587.66, y = 5245.43, z = 69.96 },
        { x = -583.5203, y = 5255.3701, z = 69.966018 },
    }
}

Config.TreeObject = GetHashKey('prop_tree_pine_02')

-- IMPORTANT! Need to add the wood and cutted_wood to database!
Config.Rewards = {
    ['treezone'] = { item = 'wood', min = 1, max = 2 },
    ['process'] = { item = 'cutted_wood', count = 1, required = 3 },
    ['sell'] = { price = 5000 },
}

Config.JobCloth = {
    male = {
        ['tshirt_1'] = 15, ['tshirt_2'] = 0,
        ['torso_1'] = 43, ['torso_2'] = 0,
        ['decals_1'] = 0, ['decals_2'] = 0,
        ['arms'] = 11,
        ['pants_1'] = 47, ['pants_2'] = 1,
        ['shoes_1'] = 54, ['shoes_2'] = 0,
    },
    female = {
        ['tshirt_1'] = 15, ['tshirt_2'] = 0,
        ['torso_1'] = 43, ['torso_2'] = 0,
        ['decals_1'] = 0, ['decals_2'] = 0,
        ['arms'] = 11,
        ['pants_1'] = 47, ['pants_2'] = 1,
        ['shoes_1'] = 54, ['shoes_2'] = 0,
    }
}
