version '1.0.0'
fx_version 'cerulean'
author 'Strain'
games { 'gta5' }
description 'FiveM GTA V Weapon GK18 BLACKGOLD'
version '1.0.0'
this_is_a_map 'no'
lua54 'yes'

escrow_ignore {
    'weapon_name.lua',
    'EXTRA_FILES/**.*'
}

files{
    '**/weaponcomponents.meta',
    '**/weaponarchetypes.meta',
    '**/weaponanimations.meta',
    '**/pedpersonality.meta',
    '**/weapons.meta',
    'stream/did_blackgold_gk18_anim.ytyp',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'
data_file 'DLC_ITYP_REQUEST' 'stream/did_blackgold_gk18_anim.ytyp'

client_script 'weapon_name.lua'
client_script 'blackgold_gk18.lua'
dependency '/assetpacks'