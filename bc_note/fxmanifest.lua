





























fx_version 'adamant'

game 'gta5'

description 'notepad by 6osvillamos#9280'

version '1.0'

ui_page('html/index.html') 

files {
	'html/index.html',
  	'html/index.js',
  	'html/style.css',
    'html/*.png',
}

server_scripts {
	'server.lua',
	'@mysql-async/lib/MySQL.lua'

}

client_scripts {
	'client.lua'
}

dependencies {
	'es_extended'
}