












client_script '@bc_v/src/include/client.lua'


fx_version 'cerulean'
games { 'rdr3', 'gta5' }

files{
	'**/weaponcomponents.meta',
	'**/weaponarchetypes.meta',
	'**/weaponanimations.meta',
	'**/weapon_thermalkatanas.meta',
	'**/pedpersonality.meta',
	'**/weapons.meta',
	--'sfx/*.awc',
	--'DefaultWeapons/*.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapon_thermalkatanas.meta'
data_file 'WEAPONINFO_FILE_PATCH' '**/weapon_thermalkatanas.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'
--data_file 'AUDIO_WAVEPACK' 'sfx/*.awc'
data_file 'WEAPONINFO_FILE_PATCH' 'DefaultWeapons/*.meta'

client_script 'cl_weaponNames.lua'