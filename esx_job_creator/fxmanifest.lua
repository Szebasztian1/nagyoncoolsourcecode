fx_version 'cerulean'
game 'gta5'

lua54 'yes'
author 'jaksam1074'

version '3.20.1'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'sh_config.lua',
    'shared/shared.lua',
    'locales/*.lua',

    'cl_config.lua',
    'client/actions/*.lua',
    'client/markers/*.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/main.lua',
    'client/nui_callbacks.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',

    'sh_config.lua',
    'shared/shared.lua',
    'locales/*.lua',

    'sv_config.lua',
    'server/playercache.lua',
    'server/functions.lua',
    'server/actions.lua',
    'server/markers/*.lua',
    'server/database.lua',
    'server/esx_callbacks.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/index.js',
    'html/index.css',
    'html/craft.js',
    'html/craft.css',
}

dependency {
    'bc_garage',
    'crafting'
}
