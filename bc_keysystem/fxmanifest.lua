










fx_version 'adamant'
game 'gta5'
description 'by 6osvillamos'
lua54 'yes'
version '1.0'

ui_page 'html/index.html'

files {
	"html/**"
}


shared_scripts {
	'@es_extended/imports.lua',
    '@ox_lib/init.lua',
	'config.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}

dependencies {
	'oxmysql',
	'es_extended',
	'ox_lib',
	'ox_inventory'
}