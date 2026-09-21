





























fx_version 'adamant'

game 'gta5'

description 'ESX Service'

version 'legacy'

shared_script '@es_extended/imports.lua'

server_scripts {
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

dependency 'es_extended'
server_scripts { '@mysql-async/lib/MySQL.lua' }server_scripts { '@mysql-async/lib/MySQL.lua' }