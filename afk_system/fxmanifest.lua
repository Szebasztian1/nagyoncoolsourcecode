

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'lakat'
description 'AFK rendszer - 3D felirat a fej felett ha a jatekos nem mozog'
version '1.0.0'


shared_scripts {
	'@es_extended/imports.lua',
}


client_script 'client.lua'
server_script 'server.lua'

shared_script 'config.lua'

dependency 'es_extended'
