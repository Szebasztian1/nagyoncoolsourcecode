fx_version 'adamant'
game 'gta5'
lua54 'yes'
description '6osvillamos'
version '1.0.0'

ui_page 'html/index.html' 

files {
  'html/**',
  'config/vehicleimgs.json',
}

shared_scripts {
  '@es_extended/imports.lua',
  'config/shared.lua',
  'config/vehtype.lua',
  '@ox_lib/init.lua',
} 

client_scripts {
  'client/*.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  --'@oxmysql/lib/MySQL.lua',
  'config/server.lua',
  'server.lua'
}

dependencies {
  'es_extended'
}