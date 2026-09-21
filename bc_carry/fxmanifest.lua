

-- Resource Metadata
fx_version 'bodacious'
games { 'gta5' }

lua54 'yes'

author 'rubbertoe98'
description 'CarryPeople'
version '1.0.0'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua'
}

client_script "cl_carry.lua"
server_script "sv_carry.lua"
