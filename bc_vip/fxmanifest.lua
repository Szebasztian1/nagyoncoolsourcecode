





























fx_version 'adamant'
game 'gta5'
lua54 'yes'

description 'VIP System by Black City Scripts'

author 'https://black-city-scripts.tebex.io/'

version '1.2' 

ui_page 'html/index.html'
files {
	'html/**'
}

shared_scripts {
	'shared/*.lua',
	'locales/*.lua',
	'config/shared.lua',
	'@es_extended/imports.lua',
	--'@ox_lib/init.lua' --if you use ox_lib
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config/server.lua',
	'server/*.lua'
}

client_scripts {
	'client/*.lua',
    'client/menus/*.lua',
}

dependencies {
	'es_extended',
	'bc_ppshop',
	'/assetpacks'
}

escrow_ignore {
	'config/**',
	'client/editable.lua',
	'client/menus/**',
	'server/editable.lua',
	'locales/*.lua'
}
dependency '/assetpacks'