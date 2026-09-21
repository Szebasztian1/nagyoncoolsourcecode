fx_version 'adamant'
game 'gta5'
lua54 'yes'
description '6osvillamos'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    "rpc/shared.lua",
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "rpc/server.lua",
    'server/tradeban.lua',
    'server/main.lua',
    'server/antilaunder.lua'
}

client_scripts {
    "rpc/client.lua",
    'client/main.lua'
}


ui_page "web/dist/index.html"

files {
    "web/dist/**.*",
    "web/contract/*",
}
