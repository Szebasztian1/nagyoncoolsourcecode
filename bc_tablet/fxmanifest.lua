



























fx_version 'adamant'
game 'gta5'
lua54 'yes'
description '6osvillamos'
version '1.0.0'

ui_page 'dist/index.html' 

files {
  'dist/**',
}

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'config.lua',
} 

client_scripts {
  'client/*.lua'
}

server_scripts {
  'server/*.lua'
}
