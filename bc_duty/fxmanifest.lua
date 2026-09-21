

fx_version 'cerulean'
game 'gta5'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    "rpc/shared.lua",
    'config.lua',
    '@es_extended/locale.lua',
    'locales/*.lua',
}



client_scripts {
    "rpc/client.lua",
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/imports.lua',
    "rpc/server.lua",
    'server/main.lua',
}

dependency 'es_extended'

ui_page "web/dist/index.html"

files {
    "web/dist/**.*",
}
