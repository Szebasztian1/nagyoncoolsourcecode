fx_version 'cerulean'
game 'gta5'

name 'bc_playtimeshop'
description 'BlackCity | Játékidő shop'

shared_script {
	'config.lua',
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
}

dependencies {
	'es_extended',
	'oxmysql', -- start order matters: server/db.lua queries the schema on start
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	-- '@mysql-async/lib/MySQL.lua',
	'server_config.lua',
	'server/db.lua',
	'server/main.lua',
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/font/*.ttf',
	'html/font/*.otf',
	'html/css/*.css',
	'html/images/*.jpg',
	'html/images/*.png',
	'html/images/*.webp',
	'html/js/*.js',
}

escrow_ignore {
	'config.lua',
	'server_config.lua',

	'client/main.lua',
	'server/main.lua',
}

lua54 'on'
dependency '/assetpacks'
