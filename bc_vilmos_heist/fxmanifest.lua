



















fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'bc_vilmos_heist'
description 'Vilmos auto heist'
version '3.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_target'
}
