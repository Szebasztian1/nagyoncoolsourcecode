



























fx_version 'bodacious'
games { 'gta5' }

lua54 'yes'

version '1.0.0'

ui_page('html/index.html')
files {
	'html/**'
}

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
    "config.lua"
}

client_script "client.lua"
server_script "server.lua"
