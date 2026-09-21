





























fx_version 'bodacious'
games { 'gta5' }

lua54 'yes'

author 'csontvazharcos'
description 'ATM Robbery'
version '0.0.1'

client_scripts {
    'client.lua',
}

shared_scripts { 'config.lua',
    '@es_extended/imports.lua', '@ox_lib/init.lua',
}

server_scripts {
    'server.lua',
    '@mysql-async/lib/MySQL.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
    'config.lua',
}
