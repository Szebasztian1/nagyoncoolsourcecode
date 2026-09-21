



fx_version 'bodacious'
games { 'gta5' }

lua54 'yes'

author '6osvillamos'
description 'easy moneywash script for esx'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

client_scripts {
    "markers.lua",   -- sajat marker rendszer (a mate-markers helyett)
    "client.lua",
}

server_script "server.lua"
