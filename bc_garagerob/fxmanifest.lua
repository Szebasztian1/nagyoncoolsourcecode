





fx_version 'adamant'

game 'gta5'

description 'garage robbery by 6osvillamos#9280'

version '1.0'

shared_scripts {
    "@es_extended/imports.lua"
}

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'server.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'client.lua',
    'lib/lockpick.lua',
}

files {
    --'shellpropsv8.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'shellpropsv8.ytyp'
