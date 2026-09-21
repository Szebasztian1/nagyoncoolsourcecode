













fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

server_scripts {
    "rpc/server.lua",
    'server/main.lua',
}

client_scripts {
    "rpc/client.lua",
    'client/main.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    "rpc/shared.lua",
    'config.lua',
    'config_static.lua', -- must load after config.lua (config.lua resets Config)
}

ui_page "web/dist/index.html"

files {
    "web/dist/**.*",
    "client/filter.lua",   -- loaded via require
    "client/work.lua",     -- loaded via require
    "client/external.lua", -- loaded via require
}
