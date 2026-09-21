



























fx_version 'adamant'

game 'gta5'

description 'auctionsystem by 6osvillamos'

version '1.0'

--ui_page 'http://localhost:5173/'
ui_page 'html/dist/index.html'

lua54 "yes"

files {
	"html/dist/**"
}

shared_scripts {
    '@ox_lib/init.lua',
	'@es_extended/imports.lua',
	'config/shared.lua',
	'@es_extended/locale.lua',
}

server_scripts {
    'config/server.lua',
    '@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

client_scripts {
	'client/*.lua'
}

