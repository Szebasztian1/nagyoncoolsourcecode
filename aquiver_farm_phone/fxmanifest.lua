

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Custom - Farm Phone App'
description 'RoadPhone custom app: animal farm (aquiver-farmhouse) statistics'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

dependency 'ox_lib'
