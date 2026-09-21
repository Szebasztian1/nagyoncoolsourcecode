

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Használtautó'
description 'Használtautó - használtautó hirdető RoadPhone app (ESX)'
version '2.0.0'

shared_script 'config.lua'

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}

dependencies {
    'es_extended',
    'oxmysql',
    'screenshot-basic'
}
