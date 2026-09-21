





























fx_version 'adamant'

game 'gta5'

description 'faction jump by 6osvillamos'

version '1.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
	'config.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

client_scripts {
	'client.lua'
}
