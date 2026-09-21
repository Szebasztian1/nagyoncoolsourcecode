





























fx_version 'adamant'

game 'gta5'

description 'by 6osvillamos'

lua54 'yes'

ui_page 'index.html'

files {
	'index.html'
}

shared_scripts {
	'@es_extended/imports.lua',
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