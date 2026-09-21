











fx_version 'cerulean'

game 'gta5'

lua54 'yes'

description 'by 6osvillamos#9280'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'rpc/shared.lua',
}

server_scripts {
    'config.lua',
    'rpc/server.lua',
    'server.lua',
}

client_scripts {
    'config.lua',
    'rpc/client.lua',
    'client.lua',
}

ui_page "web/dist/index.html"
files {
    "web/dist/**.*",
}
