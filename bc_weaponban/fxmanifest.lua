



























fx_version 'adamant'
game 'gta5'
lua54 'yes'

description 'placeable safes by 6osvillamos#9280'
version '1.0.0'

shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

client_scripts {
  'config.lua',
  'client.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server.lua',
}

ui_page 'ui/index.html'

files {
  'ui/index.html',
  'ui/style.css',
  'ui/script.js'
}