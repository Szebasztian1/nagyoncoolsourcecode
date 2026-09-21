





























fx_version 'adamant'

game 'gta5'

lua54 'yes'

shared_scripts { '@es_extended/imports.lua', '@ox_lib/init.lua' }

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'server/main.lua',
    --'server/drugs.lua',
}

client_scripts {
    '@es_extended/locale.lua',
    'client/main.lua',
    'locales/en.lua',
    'locales/sv.lua',
    'locales/de.lua',
    'config.lua'
}
