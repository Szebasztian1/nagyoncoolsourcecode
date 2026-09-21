



























fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
}

ui_page 'web/dist/index.html'

files {
    'shared/config.lua',
    'client/*.lua',
    --'client/modules/*.lua',
    --'client/addons/*.lua',
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
}
