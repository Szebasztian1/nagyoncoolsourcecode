



























fx_version 'adamant'

game 'gta5'

ui_page 'html/index.html'
shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua"
}
server_script {
    'settings/config.lua',
    's.lua'
}

client_script {
    'settings/config.lua',
    'c.lua',
    'minigame/minigame.lua'
}

files {
    'html/style.css',
    'html/index.html',
    'html/script.js',
    'html/imgs/*.png'
}
server_scripts { '@mysql-async/lib/MySQL.lua' }
server_scripts { '@mysql-async/lib/MySQL.lua' }
server_scripts { '@mysql-async/lib/MySQL.lua' }
