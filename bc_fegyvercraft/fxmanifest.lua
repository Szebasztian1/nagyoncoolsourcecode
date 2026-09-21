fx_version 'cerulean'

game 'gta5'

description 'script by 6osvillamos#9280'

version '1.1'

ui_page 'html/index.html'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua'
}


server_scripts {
	'@mysql-async/lib/MySQL.lua',
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
