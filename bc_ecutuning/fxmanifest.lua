fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'rota_ecutuning'
author 'rota'
version '1.0.0'
description 'Pop & Bang + Flammenwerfer exhaust tuning with a React NUI'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/**',
    'client/modules/*.lua',
    'sounds/**'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'es_extended',
    'oxmysql'
}
