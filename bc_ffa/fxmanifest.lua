fx_version 'adamant'

game 'gta5'

description 'by 6osvillamos'

version '1.1'

lua54 "yes"

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'stats.lua',      -- a Stats táblát a server.lua használja, ezért előbb tölt
    'server.lua'
}

dependencies {
    'oxmysql',
    'es_extended',
    'ox_lib',
}
