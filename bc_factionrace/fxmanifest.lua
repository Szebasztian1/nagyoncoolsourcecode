





























fx_version 'adamant'
game 'gta5'
lua54 'yes'
description '6osvillamos'
version '1.0.0'

ui_page 'html/index.html' 

files {
  'html/**',
}

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
} 

client_scripts {
  'config.lua',
  'client.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server.lua'
}

dependencies {
  'es_extended'
}