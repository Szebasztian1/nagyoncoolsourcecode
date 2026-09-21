





























fx_version 'adamant'
game 'gta5'
lua54 'yes'

description 'placeable safes by 6osvillamos#9280'
version '1.0.0'

shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

client_scripts {
  'shared/config.lua',
  'client/client.lua',
  'client/place.lua',
  'client/lockpick.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'shared/config.lua',
  'server/server.lua',
  'server/safe.lua',
}

dependencies {
  'es_extended',
  'ox_target',
  'ox_inventory',
  'ox_lib'
}