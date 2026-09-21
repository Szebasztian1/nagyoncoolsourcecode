



























fx_version 'adamant'

game 'gta5'

description '6osvillamos'

version '1.0.0'
lua54 "yes"


shared_scripts {
    '@ox_lib/init.lua',
	'@es_extended/imports.lua'
}

server_scripts {
	'server.lua',
	'@mysql-async/lib/MySQL.lua'
}

client_scripts {
	'client.lua'
}