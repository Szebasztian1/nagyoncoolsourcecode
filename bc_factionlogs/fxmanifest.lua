



























fx_version 'adamant'

game 'gta5'

description 'by 6osvillamos'

version '1.0'

ui_page 'html/index.html'

lua54 "yes"

files {
	"html/**"
}

shared_scripts {
    '@ox_lib/init.lua',
	'@es_extended/imports.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

client_scripts {
	'client.lua'
}