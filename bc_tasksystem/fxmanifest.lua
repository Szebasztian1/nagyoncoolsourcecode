fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Task system by Black City Scripts, with the achievements in the same panel'

author 'https://black-city-scripts.tebex.io/'

version '2.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/js/*.js',
    'html/img/map.webp',
    'html/sounds/unlock.mp3',
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
    'locales/*.lua',
    'config/shared.lua',
    '@es_extended/imports.lua',
    -- after config/shared.lua: they add to its Config table
    'achievements/shared/config.lua',
    'achievements/shared/catalog.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'db/migrations.lua',
    'server/*.lua',
    'achievements/server/storage.lua',
    'achievements/server/registry.lua',
    'achievements/server/progress.lua',
    'achievements/server/leaderboard.lua',
    'achievements/server/schedule.lua',
    'achievements/server/rewards.lua',
    'achievements/server/commands.lua',
    'achievements/server/main.lua',
}

client_scripts {
    'client/*.lua',
    'achievements/client/main.lua',
    'achievements/client/tracker.lua',
    'achievements/client/panel.lua',
}

dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib',
    '/assetpacks'
}

escrow_ignore {
    'config/**',
    'client/editable.lua',
    'server/editable.lua',
    'locales/*.lua',
    'achievements/shared/*.lua',
}
