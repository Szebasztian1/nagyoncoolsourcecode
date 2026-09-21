local Weapons = {
	{'WEAPON_PISTOL', 'Pistol'},
	{'WEAPON_AUTOSHOTGUN', 'Auto Shotgun'},
	{'WEAPON_ASSAULTRIFLE', 'Assault Rifle'},
	{'WEAPON_ASSAULTRIFLE_MK2', 'Assault Rifle MK2'},
	{'WEAPON_ADVANCEDRIFLE', 'Advanced Rifle'},
	{'WEAPON_PISTOL50', 'Pistol 50'},
	{'WEAPON_HEAVYPISTOL', 'Heavy Pistol'},
	{'WEAPON_GUSENBERG', 'Gusenberg'},
	{'WEAPON_CARBINERIFLE', 'Carbine Pistol'},
	{'WEAPON_COMPACTRIFLE', 'Comapct Pistol'},
	{'WEAPON_MICROSMG', 'Micro SMG'},
	{'WEAPON_PUMPSHOTGUN', 'Pump Shotgun'},
	{'WEAPON_HEAVYSHOTGUN', 'Heavy Shotgun'},
	{'WEAPON_COMBATPDW', 'Combatpdw'},
	{'WEAPON_PISTOL_MK2', 'Pistol MK2'},
	{'WEAPON_MINISMG', 'Mini SMG'},
	{'WEAPON_BULLPUPRIFLE', 'Bullpup Rifle'},
	{'WEAPON_ASSAULTSHOTGUN', 'Assault Shotgun'},
	{'WEAPON_APPISTOL', 'AP Pistol'},
	{'WEAPON_SMG', 'SMG'},
	{'WEAPON_SPECIALCARBINE', 'Special Carbine'},
	{'WEAPON_BULLPUPSHOTGUN', 'Kel-Tec KSG'},
	{'WEAPON_MACHINEPISTOL', 'Machine Pistol'},
	{'WEAPON_MG', 'MG'},
	{'WEAPON_GUSENBERG', 'Gusenberg'},
	{'WEAPON_CARBINERIFLE_MK2', 'Carbine Rifle Mk2'},
	{'WEAPON_PRECISIONRIFLE', 'Precision Rifle'},
	{'WEAPON_PISTOL_MK2', 'Pisztoly MK2'},
	{'WEAPON_SMG_MK2', 'SMG MK2'},
	{'WEAPON_TACTICALRIFLE', 'Tactical Rifle'},
	{'WEAPON_ASSAULTRIFLE_MK2', 'Assault Rifle MK2'},
	{'WEAPON_SPECIALCARBINE_MK2', 'Special Carbine MK2'},
	{'WEAPON_PUMPSHOTGUN_MK2', 'Pump Shotgun MK2'},
	{'WEAPON_COMBATPISTOL', 'Combat Pistol'},
	{'WEAPON_M47V2', 'M47 V2'},
	{'WEAPON_M270D', 'Syndicate'},

	{'WEAPON_DEADSHOT', 'deadshot'},
	{'WEAPON_HFSMGV2', 'hfsmg'},
	{'weapon_vintagepistol', 'Vintage Pistol'},
	{'WEAPON_COMBATMG_MK2', 'Combat MG'},
	{'weapon_tecpistol', 'Tec Pistol'},
	{'weapon_marksmanrifle', 'Marksman Rifle'},
	{'weapon_marksmanrifle_mk2', 'Marksman Rifle MK2'},--
	{'WEAPON_HFAP', 'HFAP'},
	{'WEAPON_BLOCKAP', 'BlockAP'},
	{'weapon_heavysniper_mk2', 'Heavy Sniper MK2'},
	{'WEAPON_MACHINE_PISTOL_RED_CHR', 'Machine Pistol red'},
	{'WEAPON_GYS', 'GYS'},
	{'WEAPON_M9_P_CHROMIUM', 'M9'},
	{'WEAPON_H05117_P', 'H05117'},
	{'WEAPON_COMBAT_PISTOL_CHROMIUM', 'Combat Pistol Chromium'},
	{'WEAPON_999AP', '999AP'},
	{'WEAPON_BLOCKAP', 'Block AP'},
	{'WEAPON_1441', '1441'},
	{'WEAPON_AT4S_BANSHEE', 'AT4S'},
	{'WEAPON_VICTUSXMR', 'Victus XMR'},
	{'WEAPON_FIVESEVEN', 'FiveSeven'},
	{'WEAPON_GLDXN', 'Pusztító pisztoly'},
}
local Components = {
    { "COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_CARBINERIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_ASSAULTRIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_MICROSMG_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_SNIPERRIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_PISTOL_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_PISTOL50_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_APPISTOL_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_HEAVYPISTOL_VARMOD_LUXE", "Yusuf Amir Luxury Finish " },
	{ "COMPONENT_SMG_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },
	{ "COMPONENT_MARKSMANRIFLE_VARMOD_LUXE", "Yusuf Amir Luxury Finish" },

	{ "COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_SPECIALCARBINE_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_SNSPISTOL_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_MG_COMBATMG_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_BULLPUPRIFLE_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_MG_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER", "Lowrider Finish" },
	{ "COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER", "Lowrider Finish" },

	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SMG_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_PISTOL_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_PISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ASSAULTSHOTGUN_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_HEAVYSHOTGUN_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_PISTOL50_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMBATPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_APPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMBATPDW_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SNSPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SNSPISTOL_MK2_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ASSAULTRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMBATMG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_MG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ASSAULTSMG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_GUSENBERG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_MICROSMG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_BULLPUPRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_COMPACTRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_HEAVYPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_VINTAGEPISTOL_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_CARBINERIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_ADVANCEDRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_MARKSMANRIFLE_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SMG_CLIP_02", "Extended Magazine" },
	{ "COMPONENT_SPECIALCARBINE_CLIP_02", "Extended Magazine" },

	{ "COMPONENT_SPECIALCARBINE_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_COMPACTRIFLE_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_COMBATPDW_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_ASSAULTRIFLE_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_HEAVYSHOTGUN_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_CARBINERIFLE_CLIP_03", "Drum Magazine" },
	{ "COMPONENT_SMG_CLIP_03", "Drum Magazine" },

	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_MARKSMANRIFLE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_PISTOL_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_PISTOL_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_PISTOL_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_PISTOL_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_PUMPSHOTGUN_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CLIP_HOLLOWPOINT", "Hollowpoint Rounds" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE", "Explosive Rounds" },

	{ "COMPONENT_SNSPISTOL_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_SNSPISTOL_MK2_CLIP_HOLLOWPOINT", "Hollowpoint Rounds" },
	{ "COMPONENT_SNSPISTOL_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_REVOLVER_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_REVOLVER_MK2_CLIP_HOLLOWPOINT", "Hollowpoint Rounds" },
	{ "COMPONENT_REVOLVER_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_SMG_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_SMG_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_SMG_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_SMG_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_TRACER", "Tracer Rounds" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_TRACER", "Tracer Rounds" },

	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY", "Incendiary Rounds" },

	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_ARMORPIERCING", "Armor Piercing Rounds" },

	{ "COMPONENT_ASSAULTRIFLE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },
	{ "COMPONENT_CARBINERIFLE_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },
	{ "COMPONENT_COMBATMG_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_FMJ", "Full Metal Jacket Rounds" },

	{ "COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE", "Explosive Rounds" },

	{ "COMPONENT_AT_PI_FLSH_02", "Flashlight" },
	{ "COMPONENT_AT_AR_FLSH	", "Flashlight" },
	{ "COMPONENT_AT_PI_FLSH", "Flashlight" },
	{ "COMPONENT_AT_AR_FLSH", "Flashlight" },
	{ "COMPONENT_AT_PI_FLSH_03", "Flashlight" },

	{ "COMPONENT_AT_PI_SUPP", "Suppressor" },
	{ "COMPONENT_AT_PI_SUPP_02", "Suppressor" },
	{ "COMPONENT_AT_AR_SUPP", "Suppressor" },
	{ "COMPONENT_AT_AR_SUPP_02", "Suppressor" },
	{ "COMPONENT_AT_SR_SUPP", "Suppressor" },
	{ "COMPONENT_AT_SR_SUPP_03", "Suppressor" },

	{ "COMPONENT_AT_PI_COMP", "Compensator" },
	{ "COMPONENT_AT_PI_COMP_02", "Compensator" },
	{ "COMPONENT_AT_PI_COMP_03", "Compensator" },
	{ "COMPONENT_AT_MRFL_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_MRFL_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_SR_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_BP_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_BP_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_SC_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_SC_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_AR_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_SB_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_CR_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_MG_BARREL_01", "Barrel Attachment 1" },
	{ "COMPONENT_AT_MG_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_CR_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_SR_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_SB_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_AR_BARREL_02", "Barrel Attachment 2" },
	{ "COMPONENT_AT_MUZZLE_01", "Muzzle Attachment 1" },
	{ "COMPONENT_AT_MUZZLE_02", "Muzzle Attachment 2" },
	{ "COMPONENT_AT_MUZZLE_03", "Muzzle Attachment 3" },
	{ "COMPONENT_AT_MUZZLE_04", "Muzzle Attachment 4" },
	{ "COMPONENT_AT_MUZZLE_05", "Muzzle Attachment 5" },
	{ "COMPONENT_AT_MUZZLE_06", "Muzzle Attachment 6" },
	{ "COMPONENT_AT_MUZZLE_07", "Muzzle Attachment 7" },

	{ "COMPONENT_AT_AR_AFGRIP", "Grip" },
	{ "COMPONENT_AT_AR_AFGRIP_02", "Grip" },

	{ "COMPONENT_AT_PI_RAIL", "Holographic Sight" },
	{ "COMPONENT_AT_SCOPE_MACRO_MK2", "Holographic Sight" },
	{ "COMPONENT_AT_PI_RAIL_02", "Holographic Sight" },
	{ "COMPONENT_AT_SIGHTS_SMG", "Holographic Sight" },
	{ "COMPONENT_AT_SIGHTS", "Holographic Sight" },

	{ "COMPONENT_AT_SCOPE_SMALL", "Scope Small" },
	{ "COMPONENT_AT_SCOPE_SMALL_02", "Scope Small" },

	{ "COMPONENT_AT_SCOPE_MACRO_02", "Scope" },
	{ "COMPONENT_AT_SCOPE_SMALL_02", "Scope" },
	{ "COMPONENT_AT_SCOPE_MACRO", "Scope" },
	{ "COMPONENT_AT_SCOPE_MEDIUM", "Scope" },
	{ "COMPONENT_AT_SCOPE_LARGE", "Scope" },
	{ "COMPONENT_AT_SCOPE_SMALL", "Scope" },

	{ "COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2", "2x Scope" },
	{ "COMPONENT_AT_SCOPE_SMALL_MK2", "2x Scope" },

	{ "COMPONENT_AT_SCOPE_SMALL_SMG_MK2", "4x Scope" },
	{ "COMPONENT_AT_SCOPE_MEDIUM_MK2", "4x Scope" },

	{ "COMPONENT_AT_SCOPE_MAX", "Advanced Scope" },
	{ "COMPONENT_AT_SCOPE_LARGE", "Scope Large" },
	{ "COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2", "Scope Large" },
	{ "COMPONENT_AT_SCOPE_LARGE_MK2", "8x Scope" },

	{ "COMPONENT_AT_SCOPE_NV", "Nightvision Scope" },
	{ "COMPONENT_AT_SCOPE_THERMAL", "Thermal Scope" },

	{ "COMPONENT_KNUCKLE_VARMOD_PLAYER", "Default Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_LOVE", "Love Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_DOLLAR", "Dollar Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_VAGOS", "Vagos Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_HATE", "Hate Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_DIAMOND", "Diamond Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_PIMP", "Pimp Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_KING", "King Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_BALLAS", "Ballas Skin" },
	{ "COMPONENT_KNUCKLE_VARMOD_BASE", "Base Skin" },
	{ "COMPONENT_SWITCHBLADE_VARMOD_VAR1", "Default Skin" },
	{ "COMPONENT_SWITCHBLADE_VARMOD_VAR2", "Variant 2 Skin" },
	{ "COMPONENT_SWITCHBLADE_VARMOD_BASE", "Base Skin" },

	{ "w_ar_m47v2_mag1", "Clip def" },
	{ "w_ar_m47v2_mag2", "Clip ext" },
	{ "w_at_ar_m47v2_supp", "Suppressor" },
	{ "w_at_ar_m47v2_grip", "Grip" },
	{ "w_at_m47v2_scope_small", "Scope" },

	{ "w_pi_gldxn_mag1", "Mag 1" },
	{ "w_pi_gldxn_mag2", "Mag 2" },
	{ "w_pi_gldxn_mag3", "Mag 3" },
	{ "w_at_pi_gldxn_supp", "Suppressor" },
	{ "w_at_pi_gldxn_flsh", "Flash" },
	{ "w_at_pi_gldxn_scope", "Scope" },


	{ "COMPONENT_VICTUSXMR_CLIP_01", "Clip" },
	{ "COMPONENT_VICTUSXMR_SCOPE_01", "Scope" },


	--[[{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_MARKSMANRIFLERIFLE_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_BULLPUPRIFLE_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_PUMPSHOTGUN_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_REVOLVER_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_REVOLVER_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_SPECIALCARBINE_MK2_CAMO_IND_01", "American Camo" },

	{ "COMPONENT_PISTOL_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_SMG_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_COMBATMG_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO", "Camo 1" },
	{ "COMPONENT_PISTOL_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_SMG_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_02", "Camo 2" },
	{ "COMPONENT_PISTOL_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_SMG_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_03", "Camo 3" },
	{ "COMPONENT_PISTOL_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_SMG_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_04", "Camo 4" },
	{ "COMPONENT_PISTOL_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_SMG_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_05", "Camo 5" },
	{ "COMPONENT_PISTOL_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_SMG_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_06", "Camo 6" },
	{ "COMPONENT_PISTOL_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_SMG_MK2_CAMO_07", "Camo 7" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_PISTOL_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_SMG_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_08", "Camo 8" },
	{ "COMPONENT_PISTOL_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_SMG_MK2_CAMO_09", "Camo 9" },
	{ "COMPONENT_PISTOL_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_SMG_MK2_CAMO_10", "Camo 10" },
	{ "COMPONENT_PISTOL_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_SMG_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_ASSAULTRIFLE_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_CARBINERIFLE_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_COMBATMG_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_HEAVYSNIPER_MK2_CAMO_IND_01", "American Camo" },
	{ "COMPONENT_SNSPISTOL_MK2_CAMO_IND_01", "American Camo" } ]]
}

local weas = {}

CreateThread(function() 
    Wait(1000)
    for i=1, #Weapons do
        local w = GetHashKey(Weapons[i][1])

        local comp = {}

        for d=1, #Components do 
            local c = GetHashKey(Components[d][1])

            if DoesWeaponTakeWeaponComponent(w, c) then
                table.insert(comp, {
                    hash = c,
                    label = Components[d][2]
                })
            end
        end 

        weas[w] = { label = Weapons[i][2], tints = GetWeaponTintCount(w), components = comp}
    end 
end)

function IsWeaponWhitelisted(weaponHash)
    if weas[weaponHash] then 
        return true
    else 
        return false
    end
end 

local weaponupgrades = {}

function OpenWeaponUpgradeMenu()
    local me = PlayerPedId()
    local weapon = GetSelectedPedWeapon(me)
    local elements = {}
    if IsWeaponWhitelisted(weapon) then 
        local weaponData = weas[weapon]
        table.insert(elements, { label = Translate("weapon", weaponData.label) })
        if weaponData.tints > 0 then 
            table.insert(elements, { label = Translate("weapon_tint"), type = "slider", value = GetPedWeaponTintIndex(me, weapon), min = 0, max = weaponData.tints, action = "tint"})
        end
        for d=1, #weaponData.components do 
            if HasPedGotWeaponComponent(me, weapon, weaponData.components[d].hash) then 
                table.insert(elements, { label = '<span style="color: green;">' .. weaponData.components[d].label .. '</span>', value = weaponData.components[d].hash, action = "remove_component"})
            else 
                table.insert(elements, { label = '<span style="color: red;">' .. weaponData.components[d].label .. '</span>', value = weaponData.components[d].hash, action = "add_component"})
            end
        end 
    else 
        elements = {{ label = Translate("cant_modify") }}
    end 
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'weapon', {
        title    = Translate("weapon_menu"),
        align    = "bottom-right",
        elements = elements
    }, function(data, menu)
        if weapon == GetSelectedPedWeapon(me) then 
            if data.current.action == 'tint' then 
				if not weaponupgrades[weapon] then 
					weaponupgrades[weapon] = {}
				end 
				weaponupgrades[weapon].tint = data.current.value
                SetPedWeaponTintIndex(me, weapon, data.current.value)
            elseif data.current.action == 'remove_component' then 
				if not weaponupgrades[weapon] then 
					weaponupgrades[weapon] = {}
				end 
				weaponupgrades[weapon][data.current.value] = false 
                RemoveWeaponComponentFromPed(me, weapon, data.current.value)
            elseif data.current.action == 'add_component' then 
				if not weaponupgrades[weapon] then 
					weaponupgrades[weapon] = {}
				end 
				weaponupgrades[weapon][data.current.value] = true  
                GiveWeaponComponentToPed(me, weapon, data.current.value)
            end
        else 
            Notify(Translate("changed_weapon"))
        end 
        menu.close()
        OpenWeaponUpgradeMenu()
    end, function(data, menu)
        menu.close()
    end)
end 

AddEventHandler('playerSpawned', function()
	local me = PlayerPedId()
	for weapon, components in pairs(weaponupgrades) do 
		GiveWeaponToPed(me, weapon, 0, false) 
		for component, val in pairs(components) do 
			if val then 
				if val == "tint" then 
					SetPedWeaponTintIndex(me, weapon, val)
				else 
					GiveWeaponComponentToPed(me, weapon, component)
				end 
			end 
		end 
	end 
end)

AddEventHandler("bc:reloadedskin", function()
	local me = PlayerPedId()
	for weapon, components in pairs(weaponupgrades) do
		GiveWeaponToPed(me, weapon, 0, false ) 
		for component, val in pairs(components) do 
			if val then 
				if val == "tint" then 
					SetPedWeaponTintIndex(me, weapon, val)
				else 
					print("weaponcomponent add", weapon, component)
					GiveWeaponComponentToPed(me, weapon, component)
				end 
			end 
		end 
	end 
end)