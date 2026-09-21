









fx_version 'adamant'
game 'gta5'
lua54 'yes'

description 'Lumberjack job by Black City Scripts'

author 'https://black-city-scripts.tebex.io/'

version '1.1' 

shared_scripts {
	'@es_extended/imports.lua',
}

client_scripts {
    'munkablip.lua',
    'shared/config.lua',
    'locales/*.lua',
    'client/main.lua'
}

server_scripts {
    'shared/config.lua',
    'locales/*.lua',
    'server/main.lua'
}

dependencies {
    'es_extended'
}

escrow_ignore {
    'shared/config.lua',
    'locales/*.lua'
}
