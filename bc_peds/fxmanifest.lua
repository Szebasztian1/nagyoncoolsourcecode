



fx_version 'adamant'

game 'gta5'

description 'Ped System '

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'luas/config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'luas/server/main.lua'
}

client_scripts {
    'luas/client/main.lua'
}
