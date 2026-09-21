



















fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'bc_billing'
author 'Black City Billing'
description 'Secure billing system'
version '1.0.1'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}