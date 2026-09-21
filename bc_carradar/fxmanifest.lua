

















-- 
-- 










fx_version 'adamant'

game 'gta5'

version '1.0'

lua54 "yes"

ui_page 'web/dist/index.html'

files {
    'web/dist/**'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'shared.lua'
}

client_script "client.lua"
server_script "server.lua"
