











fx_version 'adamant'

game 'gta5'

description 'by 6osvillamos'

version '1.0'

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
	'server.lua'
}

client_scripts {
	'@PolyZone/client.lua',
	'munkablip.lua',
	'client.lua'
}

dependencies {
    'PolyZone',
	'es_extended'
}