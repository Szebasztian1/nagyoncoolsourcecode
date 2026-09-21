fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'bc_forgalmi'
description 'Forgalmi engedely - ox_inventory metadata viewer'
version '1.0.0'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/index.js',
}

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
	'client.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua',
}

dependencies {
	'ox_lib',
	'ox_inventory',
	'oxmysql',
}
