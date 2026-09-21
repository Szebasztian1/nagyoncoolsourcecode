











fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'frakció-loadout'
description 'Rendvédelmi loadout rendszer – ESX + ox_lib + ox_inventory'
version     '1.0.0'

shared_scripts { '@es_extended/imports.lua','@ox_lib/init.lua', 'config.lua', 'shared/utils.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/db.lua', 'server/main.lua' }

ui_page 'ui/index.html'
files   { 'ui/index.html', 'ui/style.css', 'ui/app.js' }

dependencies { 'ox_lib', 'ox_inventory', 'oxmysql', 'es_extended' }
