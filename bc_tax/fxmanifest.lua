fx_version 'adamant'

game 'gta5'

description 'by 6osvillamos'

version '1.0'

lua54 'yes'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'server_nui.lua',
    'server_exam.lua'
}

client_scripts {
    'client.lua',
    'client_nui.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/vue.global.prod.js',
    'html/js/app.js',
    'html/fonts/*.woff2'
}
