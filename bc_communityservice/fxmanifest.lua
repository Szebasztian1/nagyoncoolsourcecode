





























--client_script '@bc_heartbeat/addon.lua'
fx_version 'adamant'
game 'gta5'
lua54 'yes'

description 'Communityservice by Black City Scripts'

author 'https://black-city-scripts.tebex.io/'

version '1.2' 

ui_page('html/index.html')
files {
	'html/**'
}

shared_scripts {
	'shared/*.lua',
	'locales/*.lua',
	'config/shared.lua',
	'@es_extended/imports.lua',
	'@ox_lib/init.lua' --if you use ox_lib
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config/server.lua',
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}

dependencies {
	'es_extended',
	'/assetpacks'
}

escrow_ignore {
	'config/**',
	'client/editable.lua',
	'server/editable.lua',
	'locales/*.lua'
}
