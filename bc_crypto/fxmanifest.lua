






















fx_version 'adamant'

game 'gta5'

description 'auctionsystem by 6osvillamos'

version '1.0'

ui_page 'html/index.html'

lua54 "yes"

files {
	"html/**",
	"html/cryptoapp/*"
}

shared_scripts {
	'shared/*.lua',
	'locales/*.lua',
	'config/shared.lua',
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
}

server_scripts {
    'config/server.lua',
    '@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

client_scripts {
	'client/*.lua'
}

