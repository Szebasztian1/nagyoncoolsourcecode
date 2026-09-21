




















-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'NAT2K15'
description 'FiveM Discord bot v2'

shared_scripts {
    './config/config.lua',
}

client_scripts  {
    './backend/client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'index.js',
    './backend/server.lua',
    './backend/backend.js'
} 