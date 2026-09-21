Config = {}

Config.Locale = "hu"

Config.EnableCommands = true
Config.PutInCommand = "kozi"
Config.RealseCommand = "kozivege"

Config.OxInventory = true
Config.Minigame = false
Config.OxLib = true

Config.ServiceExtensionOnEscape = false 

Config.ServiceLocation = {
    coords = vector3(-1205.3660, 47.5565, 52.1200),
    radius = 130.0
}

Config.ReleaseLocation = vector3(235.3532, -785.3375, 30.6210)

Config.ServiceLocations = {
    vector3(-1221.8159, 87.4543, 55.3501),
    vector3(-1245.9701, 75.8682, 51.9220),
    vector3(-1247.4808, 58.2077, 50.3955),
    vector3(-1230.2429, 53.8902, 51.8616),
    vector3(-1205.3660, 47.5565, 52.1200),
    vector3(-1219.8380, 33.3729, 48.3469),
    vector3(-1244.6625, 33.8081, 47.4234),
    vector3(-1260.2498, 48.9849, 49.4270),
    vector3(-1191.4972, 67.8594, 54.5472),
    vector3(-1193.3695, 94.0772, 56.8978),
}

Config.AnimTimeAfterMinigame = 10000 --in ms
Config.DeactiveServiceTime = 40000 --in ms

Config.Uniforms = {
	male = {
		['tshirt_1'] = 59, ['tshirt_2'] = 1,
		['torso_1'] = 56, ['torso_2'] = 0,
		['decals_1'] = 0, ['decals_2'] = 0,
		['arms'] = 134,
		['pants_1'] = 98, ['pants_2'] = 16,
		['shoes_1'] = 51, ['shoes_2'] = 0,
		['chain_1'] = 0, ['chain_2'] = 0,
		['mask_1'] = 0, ['mask_2'] = 0,
		['glasses_1'] = 0, ['glasses_2'] = 0,
		['helmet_1'] = -1, ['helmet_2'] = -1,
		['bproof_1'] = 0, ['bproof_2'] = 0
	},
	female = {
		['tshirt_1'] = 14, ['tshirt_2'] = 0,
		['torso_1'] = 75 , ['torso_2'] = 0,
		['decals_1'] = 0, ['decals_2'] = 0,
		['arms'] = 67, ['pants_1'] = 80,
		['pants_2'] = 2, ['shoes_1'] = 3,
		['shoes_2'] = 0, ['chain_1'] = 0,
		['chain_2'] = 0
	}
}
