





























fx_version 'adamant'

game 'gta5'

description 'Adds a Hunger & Thrist system'
lua54 'yes'
version '1.0'
legacyversion '1.9.1'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'server/main.lua',
    'server/drugs.lua',
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'client/main.lua',
    'client/drugs.lua',
}

dependencies {
    'es_extended',
    'esx_status'
}
