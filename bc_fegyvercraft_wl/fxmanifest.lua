fx_version 'cerulean'

game 'gta5'

description 'bc_fegyvercraft_wl - identifier alapu jogosultsagos fegyvercraft'

version '2.0'

ui_page 'html/index.html'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua'
}

server_scripts {
	'config.lua',
	'server.lua'
}

client_scripts {
	'config.lua',
	'client.lua'
}

files {
	'html/index.html',
	'html/style.css',
	'html/app.js'
}

dependencies {
	'es_extended'
}
