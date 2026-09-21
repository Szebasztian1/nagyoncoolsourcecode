Config = {}

Config.UNKpng = "http://clipart-library.com/images/8TGb9bdzc.png"

Config.SharedJobGarages = true

Config.AdminGroups = {    
    "owner",
    --"serverdirector",
    --"coowner",
    --"manager",
    --"communitymanager",
    --"admincontroller",
    --"headadmin",
    --"operator",
    --"superadmin",
    --"developer",
    --"frakciougyintezo",
    --"admin4"
}

Config.ReturnToGaragePrice = {
    ["car"] = 30000,
    ["boat"] = 70000,
    --["helicopter"] = 130000,
}

-- Jarmu-kivetel spamvedelem: ennyi masodpercet kell varni ket kivetel kozott.
-- Kozos idozito a garazsra, a belso garazsra, a lefoglaltakra es a rendorsegi lefoglaltakra.
-- 0 = kikapcsolva. A cooldown csak SIKERES kivetel utan indul.
Config.TakeoutCooldown = 35

-- Ezek az admin csoportok mentesulnek a fenti cooldown alol.
Config.TakeoutCooldownBypass = {
    --"owner",
}

-- Belso garazs = instance. Minden bemeno jatekos sajat routing bucketbe kerul (base + serverId),
-- kulonben mindenki ugyanabban a szobaban all: lattak/hallottak es le tudtak loni egymast.
-- Foglalt tartomanyok a szerveren: 60000 = vilmos_plants, 61000 = vilmos_gyar, 1..1024 = illenium-appearance.
Config.InteriorBucketBase = 70000

-- Ennyi masodperc utan a szerver kirakja a jatekost a garazsbol (0 = kikapcsolva).
-- Egy perccel a lejarat elott figyelmeztetest kap.
Config.InteriorMaxTime = 600

-- Ha a jatekos ennyinel messzebb kerul a garazs-interior kozeppontjatol (kifagyott kliens,
-- teleport, manipulalt kilepes), a szerver visszateszi az eredeti bucketbe es kirakja a bejarathoz.
Config.InteriorMaxDistance = 150.0

Config.PoliceNPC = {
    heading = 96.99565,
    model = `a_m_m_business_01`,
    coords = vector3(416.28912, -968.7433, 28.552753),
    spawn = vector4(408.09838, -984.5836, 29.266099, 44.466781),
    price = 15000,
    cooldown = 20 -- másodperc, ennyi ideig nem lehet másik lefoglalt autót kivenni
}

Config.Garages = {}

Config.Impounds = {
    --Autók
    {
        label = "Lefoglaltak",
        coords = vector3(410.86962, -1622.51, 29.291927),
        spawn = vector4(407.14489, -1634.481, 29.291927, 318.3742),
        type = 'car',
        price = 10000,
        blip = { sprite = 67, color = 28, label = "Lefoglaltak" },
    },
    {
        label = "Lefoglaltak Sandy",
        coords = vector3(1651.38, 3804.84, 37.657),
        spawn = vector4(1627.84, 3788.45, 33.7, 308.3742),
        type = 'car',
        price = 10000,
        blip = { sprite = 67, color = 28, label = "Lefoglaltak" },
    },
    {
        label = "Lefoglaltak Paleto",
        coords = vector3(-234.82, 6198.65, 30.94),
        spawn = vector4(-230.08, 6190.24, 30.49, 140.3742),
        type = 'car',
        price = 10000,
        blip = { sprite = 67, color = 28, label = "Lefoglaltak" },
    },

    --Hajók
    {
        label = "Lefoglaltak (Hajók)",
        coords = vector3(-748.7891, -1417.636, 5.0005216),
        spawn = vector4(-792.1344, -1431.894, 0.474913, 110.14446),
        type = 'boat',
        price = 21000,
        blip = { sprite = 410, color = 28, label = "Lefoglaltak (Hajók)" },
    },

    --Repülők
    {
        label = "Lefoglaltak (o)",
        coords = vector3(-1239.524, -3384.504, 13.940158),
        spawn = vector4(-1222.649, -3331.526, 13.940056, 326.23986),
        type = 'helicopter',
        price = 100000,
        blip = { sprite = 43, color = 28, label = "Lefoglaltak (Repülok)" },
    },
    {
        label = "Lefoglaltak (Repülok) Sandy",
        coords = vector3(1755.9367, 3236.3608, 42.039997),
        spawn = vector4(1770.3148, 3239.6823, 42.129608, 13.344519),
        type = 'helicopter',
        price = 100000,
        blip = { sprite = 43, color = 28, label = "Lefoglaltak (Repülok)" },
    },
}

Config.Photos = {
    showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
    showroomcam = vector3(-45.54, -1100.37, 27.42),
}


Config.InteriorGarages = {
    --[[["base"] = {
        label = "",
        enableleveling = true,
        coords = vector3(229.9559, -981.7928, -99.6607),
        menuoffset = vector3(7.43, -23.168, -0.6),
        spawnoffset = vector3(10.59, -23.168, 0.0),
        vehslots = {
            vector4(3.0, -20.0, -0.20, 90.0),
            vector4(3.0, -15.0, -0.20, 90.0),
            vector4(3.0, -10.0, -0.20, 90.0),
            vector4(3.0, -5.0, -0.20, 90.0),
            vector4(3.0, 0.0, -0.20, 90.0),

            vector4(-6.0, -20.0, -0.20, 270.0),
            vector4(-6.0, -15.0, -0.20, 270.0),
            vector4(-6.0, -10.0, -0.20, 270.0),
            vector4(-6.0, -5.0, -0.20, 270.0),
            vector4(-6.0, 0.0, -0.20, 270.0),
        }
    }]]

    ["base"] = {
        label = "Műhely garázs (csak városban)",
        img = "nui://bc_garage/html/imgs/base.png",
        enableleveling = true,
        coords = vector3(229.9559, -981.7928, -99.6607),
        menuoffset = vector3(7.894655, -22.870957, 0.6461),
        spawnoffset = vector3(10.558382, -23.081895, 1.6467),
        vehslots = {
            -- Első oszlop (272.1259 heading)
            vector4(-5.608640, 0.206008, -0.325861, 272.1259),
            vector4(-5.587543, -4.441026, -0.325861, 272.1259),
            vector4(-5.566446, -9.088059, -0.325861, 272.1259),
            vector4(-5.545350, -13.735093, -0.325861, 272.1259),
            vector4(-5.524253, -18.382126, -0.325861, 272.1259),
            vector4(-5.503156, -23.029160, -0.325861, 272.1259),

            -- Második oszlop (90.7086 heading)
            vector4(2.606737, -22.963242, -0.325861, 90.7086),
            vector4(2.759703, -18.355771, -0.325861, 90.7086),
            vector4(2.912670, -13.748301, -0.325861, 90.7086),
            vector4(3.065636, -9.140830, -0.325861, 90.7086),
            vector4(3.218603, -4.533360, -0.325861, 90.7086),
            vector4(3.371569, 0.074111, -0.325861, 90.7086),
        }
    },
    ["base_farm"] = {
        label = "Farm garázs (csak vidéken)",
        img = "nui://bc_garage/html/imgs/base_farm.png",
        enableleveling = true,
        coords = vector3(1000.5916, 7574.2646, 80.5127),
        menuoffset = vector3(-2.2993, -11.0039, -0.0627),
        spawnoffset = vector3(-0.1041, -10.1206, 0.8424),
        vehslots = {
            vector4(-5.7569, 7.4800, -0.3801, 271.07925),
            vector4(-6.3933, 1.6538, -0.4145, 268.66372),
            vector4(-6.3283, -2.4507, -0.4377, 270.96893),
            vector4(-6.4915, -6.4023, -0.4604, 270.47329),
            vector4(-6.6096, -10.5557, -0.4838, 272.85745),

            vector4(5.4802, -10.1313, -0.4814, 89.586479),
            vector4(5.3704, -6.7808, -0.4623, 89.927886),
            vector4(5.2639, -2.7334, -0.4391, 88.674011),
            vector4(4.7152, 1.9912, -0.4125, 87.154533),
            vector4(5.0752, 7.0488, -0.3830, 90.360687),

            vector4(-0.1347, 5.0591, -0.3945, 178.92234),
            vector4(-0.3382, -4.2979, -0.4482, 178.81541),
        }
    },

    ["officegarage"] = {
        label = "Irodaház garázs",
        img = "nui://bc_garage/html/imgs/office.png",
        enableleveling = true,
        coords = vector3(-186.4757, -581.4171, 141.34785),
        menuoffset = vector3(-3.5967, -6.5312, -6.34732),
        spawnoffset = vector3(-11.1800, 0.6348, -5.34729),
        vehslots = {
            vector4(-6.2749, 2.5902, -5.34732, 254.73364),
            vector4(7.0590, 7.0011, -5.34734, 166.82481),
            vector4(12.6975, 4.3371, -5.34734, 115.47432),
            vector4(13.3378, -2.3525, -5.34734, 71.608688),
            vector4(-5.5621, 2.3332, -0.00198, 253.71072),
            vector4(0.3162, 7.6415, -0.00214, 209.79743),
            vector4(7.2224, 8.7907, -0.00211, 159.47967),
            vector4(7.2224, 8.7907, -0.00211, 159.47967),
            vector4(-5.3947, 2.4933, 5.34363, 253.84918),
            vector4(0.4217, 7.8924, 5.34363, 209.29357),
            vector4(7.1674, 8.2072, 5.34363, 157.44471),
            vector4(12.2498, 4.3021, 5.34369, 116.37227),

        }
    },

    ["ncgarage"] = {
        label = "Exkluzív garázs",
        img = "nui://bc_garage/html/imgs/nightclub.png",
        enableleveling = true,
        coords = vector3(-1505.783, -3012.587, -80.00),
        menuoffset = vector3(-2.089559, -1.219641, 0.75025),
        spawnoffset = vector3(-1.957601, -4.450354, 1.75025),
        vehslots = {
            vector4(-9.619222, 14.274988, -2.535522, 272.12597),
            vector4(-2.485188, 14.011072, -2.535522, 269.29131),
            vector4(5.057780, 13.958338, -2.535522, 272.12592),
            vector4(-9.553304, 19.734217, -2.535522, 272.12588),
            vector4(-2.472005, 19.167322, -2.535522, 269.2913),
            vector4(5.229167, 18.639734, -2.535522, 269.2913),
            vector4(-9.592854, 25.022059, -2.535522, 272.1259),
            vector4(-2.260945, 24.929773, -2.535522, 269.291),
            vector4(5.229167, 24.481531, -2.535522, 272.1259),
            vector4(8.235759, 31.444178, -2.535522, 53.8582),
            vector4(-2.050008, 34.015467, -1.945801, 87.87401),
        }
    },

    ["hangargarage"] = {
        label = "Hangár garázs",
        img = "nui://bc_garage/html/imgs/hangar.png",
        enableleveling = true,
        coords = vector3(-1266.802, -3014.837, -49.000),
        menuoffset = vector3(-23.580446, -3.004797, 0.5011),
        spawnoffset = vector3(-17.435305, -30.604650, -0.4989),
        vehslots = {
            -- Első sor (300.4 heading)
            vector4(-11.249547, -18.719818, 0.09668, 300.4),
            vector4(-11.314277, -12.136171, 0.09668, 300.4),
            vector4(-11.379008, -5.552405, 0.09668, 300.4),
            vector4(-11.443738, 1.031602, 0.09668, 300.4),
            vector4(-11.508469, 7.615409, 0.09668, 300.4),
            vector4(-11.573199, 14.199216, 0.09668, 300.4),
            vector4(-11.637930, 20.783023, 0.09668, 300.4),
            vector4(-11.702661, 27.366830, 0.09668, 300.4),
            vector4(-11.767391, 33.950636, 0.09668, 300.4),
            vector4(-11.832122, 40.534443, 0.09668, 300.4),

            -- Második sor (175.748 heading)
            vector4(4.204222, 48.173182, 0.09668, 175.7480),
            vector4(3.760266, 40.026670, 0.09668, 175.748),
            vector4(3.316310, 31.880159, 0.09668, 175.748),
            vector4(2.872353, 23.733647, 0.09668, 175.748),
            vector4(2.428397, 15.587136, 0.09668, 175.748),
            vector4(1.984441, 7.440624, 0.09668, 175.748),
            vector4(1.540485, -0.705887, 0.09668, 175.748),
            vector4(1.096528, -8.852399, 0.09668, 175.748),
            vector4(0.652572, -16.998910, 0.09668, 175.748),
            vector4(0.208616, -25.145422, 0.09668, 175.7480),

            -- Harmadik sor (124.724411 heading)
            vector4(11.351438, 46.709559, 0.09668, 124.724411),
            vector4(11.090097, 40.286365, 0.09668, 124.724411),
            vector4(10.828755, 33.863172, 0.09668, 124.724411),
            vector4(10.567414, 27.439978, 0.09668, 124.724411),
            vector4(10.306073, 21.016785, 0.09668, 124.724411),
            vector4(10.044731, 14.593591, 0.09668, 124.724411),
            vector4(9.783390, 8.170397, 0.09668, 124.724411),
            vector4(9.522049, 1.747204, 0.09668, 124.724411),
            vector4(9.260707, -4.675989, 0.09668, 124.724411),
            vector4(8.999366, -11.099183, 0.09668, 124.724411),
            vector4(8.738025, -17.522377, 0.09668, 124.724411),
            vector4(8.476683, -23.945571, 0.09668, 124.724411),
        }
    },
}

Config.ChangePrice = 100000000

--[[
vec4(233.050552, -1000.391235, -99.419067, 104.881889)

vec4(232.984619, -995.683533, -99.419067, 110.551186)

vec4(232.417587, -991.569214, -99.419067, 104.881889)

vec4(232.786819, -987.481323, -99.419067, 87.874016)

vec4(232.549454, -982.707703, -99.419067, 90.708656)



vec4(223.490112, -983.142822, -99.419067, 272.125977)

vec4(223.226379, -987.415405, -99.419067, 272.125977)

vec4(223.410995, -991.556030, -99.419067, 272.125977)

vec4(223.635162, -996.052734, -99.419067, 272.125977)

vec4(223.450546, -1000.312073, -99.419067, 272.125977)]]


Config.Wrecking = {
    coords = vector3(1374.5126, 3601.0314, 34.8944927),
    --blip = false,
    blip = { sprite = 225, color = 2, label = "Autó bontó" },
    reward = {
        {item = "iron", count = 70},
        {item = "copper", count = 18},
    }
}
