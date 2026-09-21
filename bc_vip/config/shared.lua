Config = {}

Config.Locale = 'hu'

Config.Command = 'vip'
Config.OpenKey = false --false if you dont want

Config.DalyGiftTime = 24*60*60--in sec

Config.XPGiftTime = 60*60*1000 --in ms

Config.AutoRenewDuration = 30*24*60*60 --1 month, in sec

Config.Bundles = {
    ["silver"] = {
        label = "Silver VIP",
        giftxp = 250,
        price = 12000000,
        currency = "money",
        dalygift = {
            {type = "money", item = "money", count = 100000, label = "100k dollár"},
        },
        levels = {
            {
                xp = 2800,
                label = "1x Switchblade + 1x Ütő + 1x Szerelő láda",
                img = "nui://ox_inventory/web/images/weapon_switchblade.webp",
                reward = {
                    {type = "item", item = "weapon_switchblade", count = 1},
			        {type = "item", item = "weapon_golfclub", count = 1},
			        {type = "item", item = "ujrepairkit", count = 1},
                }
            },
            {
                xp = 4800,
                label = "1x Vintage Pisztoly + 200x pisztoly lőszer + 1x Mentőkészlet",
                img = "nui://ox_inventory/web/images/weapon_vintagepistol.webp",
                reward = {
                    {type = "item", item = "weapon_vintagepistol", count = 1},
			        {type = "item", item = "pistol_ammo", count = 200},
			        {type = "item", item = "ujmedikit", count = 1},
                }
            },
            {
                xp = 14800,
                label = "30x Meth + 200k pénz",
                img = "nui://ox_inventory/web/images/meth.webp",
                reward = {
                    {type = "item", item = "meth", count = 30},
			        {type = "money", item = "money", count = 200000},
                }
            },
            {
                xp = 17800,
                label = "1x Kokain + 300k pénz + 300 SMG lőszer",
                img = "nui://ox_inventory/web/images/cocaine.webp",
                reward = {
                    {type = "item", item = "cocaine", count = 1},
			        {type = "money", item = "money", count = 300000},
                    {type = "item", item = "smg_ammo", count = 300},
                }
            },
            {
                xp = 20800,
                label = "2x fegyver láda + 300k pénz + 100 Shotgun lőszer",
                img = "nui://ox_inventory/web/images/csgocase.webp",
                reward = {
                    {type = "item", item = "csgocase", count = 2},
			        {type = "money", item = "money", count = 300000},
                    {type = "item", item = "shotgun_ammo", count = 100},
                }
            },
            {
                xp = 25800,
                label = "1x Pump Shotgun + 1 Autó láda",
                img = "nui://ox_inventory/web/images/csgocase2.webp",
                reward = {
                    {type = "item", item = "weapon_pumpshotgun", count = 1},
			        {type = "item", item = "csgocase2", count = 1},
                }
            },
            {
                xp = 87800,
                label = "1x Nagykaliberű lőszer + 1x Ak47",
                img = "nui://ox_inventory/web/images/weapon_assaultrifle.webp",
                reward = {
                    {type = "item", item = "rifle_ammo", count = 200},
			        {type = "item", item = "weapon_assaultrifle", count = 1},
                }
            },
        },
        menus = {
            ['car_headlight'] = {
                label = "Autó fényszóró szinezés",
                desc = "Szinezd át autód fényszóróját!",
                img = "nui://bc_vip/html/img/michael.e0e9999c.png",
                cb = function()
                    OpenCarHeadlightMenu()
                end 
            },
        }
    },
    ["gold"] = {
        label = "Gold VIP",
        giftxp = 350,
        price = 3000,
        currency = "pp",
        dalygift = {
            {type = "money", item = "money", count = 120000, label = "120k dollár"},
        },
        levels = {
            {
                xp = 2800,
                label = "3x Pisztoly Mk2 + 300x pisztoly lőszer + 2x Szerelő láda",
                img = "nui://ox_inventory/web/images/weapon_pistol_mk2.webp",
                reward = {
                    {type = "item", item = "weapon_pistol_mk2", count = 3},
			        {type = "item", item = "pistol_ammo", count = 300},
			        {type = "item", item = "ujrepairkit", count = 2},
                }
            },
            {
                xp = 5800,
                label = "3x SMG + 300x smg lőszer + 2x Mentőkészlet",
                img = "nui://ox_inventory/web/images/weapon_smg.webp",
                reward = {
                    {type = "item", item = "weapon_smg", count = 3},
			        {type = "item", item = "smg_ammo", count = 300},
			        {type = "item", item = "ujmedikit", count = 2},
                }
            },
            {
                xp = 9800,
                label = "1x Kokain + 600k pénz + 300x Nagykaliberű lőszer",
                img = "nui://ox_inventory/web/images/cocaine.webp",
                reward = {
                    {type = "item", item = "cocaine", count = 1},
			        {type = "money", item = "money", count = 600000},
                    {type = "item", item = "rifle_ammo", count = 300},
                }
            },
            {
                xp = 13800,
                label = "50x Speed + 650k pénz + 200x Shotgun ammo",
                img = "nui://ox_inventory/web/images/speed.webp",
                reward = {
                    {type = "item", item = "speed", count = 50},
			        {type = "money", item = "money", count = 650000},
                    {type = "item", item = "shotgun_ammo", count = 200},
                }
            },
            {
                xp = 17800,
                label = "4x fegyver láda + 700k pénz + 100x MG lőszer",
                img = "nui://ox_inventory/web/images/csgocase.webp",
                reward = {
                    {type = "item", item = "csgocase", count = 4},
                    {type = "item", item = "mg_ammo", count = 100},
			        {type = "money", item = "money", count = 700000},
                }
            },
            {
                xp = 21800,
                label = "2x Bullpup Rifle + 2x Mini SMG",
                img = "nui://ox_inventory/web/images/weapon_bullpuprifle.webp",
                reward = {
                    {type = "item", item = "weapon_bullpuprifle", count = 2},
			        {type = "item", item = "weapon_minismg", count = 2},
                }
            },
            {
                xp = 50800,
                label = "3x autó láda + 2x Pump Shotgun MK2",
                img = "nui://ox_inventory/web/images/csgocase2.webp",
                reward = {
                    {type = "item", item = "csgocase2", count = 3},
                    {type = "item", item = "weapon_pumpshotgun_mk2", count = 2},
                }
            },
        },
        menus = {
            ['weapon_upgrade'] = {
                label = "Fegyver fejlesztés",
                desc = "Fejleszd fegyvereidet!",
                img = "nui://bc_vip/html/img/michael.e0e9999c.png",
                cb = function()
                    OpenWeaponUpgradeMenu()
                end 
            },
            ['car_headlight'] = {
                label = "Autó fényszóró szinezés",
                desc = "Szinezd át autód fényszóróját!",
                img = "nui://bc_vip/html/img/michael.e0e9999c.png",
                cb = function()
                    OpenCarHeadlightMenu()
                end 
            },
        }
    },
    ["platina"] = {
        label = "Platina VIP",
        giftxp = 450,
        price = 11500,
        currency = "pp",
        dalygift = {
            {type = "money", item = "money", count = 200000, label = "200k dollár"},
        },
        levels = {
            {
                xp = 1800,
                label = "3x AP Pistol + 600x pisztoly lőszer + 3x Szerelő láda", 
                img = "nui://ox_inventory/web/images/weapon_appistol.webp",
                reward = {
                    {type = "item", item = "weapon_appistol", count = 3},
			        {type = "item", item = "pistol_ammo", count = 600},
			        {type = "item", item = "ujrepairkit", count = 3},
                }
            },
            {
                xp = 5800,
                label = "3x Assault SMG + 600x smg lőszer + 8x Mentőkészlet",
                img = "nui://ox_inventory/web/images/weapon_assaultsmg.webp",
                reward = {
                    {type = "item", item = "weapon_assaultsmg", count = 3},
			        {type = "item", item = "smg_ammo", count = 600},
			        {type = "item", item = "ujmedikit", count = 8},
                }
            },
            {
                xp = 9800,
                label = "1x Kokain + 750k pénz + 600x Nagykaliberű lőszer",
                img = "nui://ox_inventory/web/images/cocaine.webp",
                reward = {
                    {type = "item", item = "cocaine", count = 1},
                    {type = "money", item = "money", count = 750000},
                    {type = "item", item = "rifle_ammo", count = 600},
                }
            },
            {
                xp = 13800,
                label = "100x Meth + 1 millió pénz + 300 Shotgun lőszer",
                img = "nui://ox_inventory/web/images/meth.webp",
                reward = {
                    {type = "item", item = "meth", count = 80},
			        {type = "money", item = "money", count = 1000000},
                    {type = "item", item = "shotgun_ammo", count = 300},
                }
            },
            {
                xp = 17800,
                label = "8x fegyver láda + 1 Millio pénz + 300 MG lőszer",
                img = "nui://ox_inventory/web/images/csgocase.webp",
                reward = {
                    {type = "item", item = "csgocase", count = 8},
			        {type = "money", item = "money", count = 1000000},
                    {type = "item", item = "mg_ammo", count = 300},
                }
            },
            {
                xp = 21800,
                label = "2x M16A4 + 2x Heavy Pisztoly + 4 Autó láda",
                img = "nui://ox_inventory/web/images/weapon_heavypistol.webp",
                reward = {
                    {type = "item", item = "weapon_tacticalrifle", count = 2},
                    {type = "item", item = "weapon_heavypistol", count = 2},
                    {type = "item", item = "csgocase2", count = 4},
                }
            },
            {
                xp = 45800,
                label = "1x M249 + 2x Sweeper Shotgun + 7x fegyverlada",
                img = "nui://ox_inventory/web/images/weapon_autoshotgun.webp",
                reward = {
                    {type = "item", item = "weapon_combatmg", count = 1},
			        {type = "item", item = "csgocase", count = 7},
			        {type = "item", item = "weapon_autoshotgun", count = 2},
                }
            },
        },
        menus = {
            ['weapon_upgrade'] = {
                label = "Fegyver fejlesztés",
                desc = "Fejleszd fegyvereidet!",
                img = "nui://bc_vip/html/img/michael.e0e9999c.png",
                cb = function()
                    OpenWeaponUpgradeMenu()
                end 
            },
            ['car_headlight'] = {
                label = "Autó fényszóró szinezés",
                desc = "Szinezd át autód fényszóróját!",
                img = "nui://bc_vip/html/img/michael.e0e9999c.png",
                cb = function()
                    OpenCarHeadlightMenu()
                end 
            },
            ['wheel_stancer'] = {
                label = "Kerék döntés",
                desc = "Döntsd be autód kerekeit!",
                img = "nui://bc_vip/html/img/michael.e0e9999c.png",
                cb = function()
                    OpenWheelStancerMenu()
                end 
            },
            ["skins"] = {
                label = "Fegyver skin",
                desc = "Rakj egyedi kinézetet fegyvereidre!",
                img = "nui://bc_vip/html/img/michael.e0e9999c.png",
                cb = function()
                    TriggerEvent("bc_weaponskin:open")
                end 
            },
        }
    },
}