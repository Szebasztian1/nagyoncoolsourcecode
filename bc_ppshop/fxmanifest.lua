

fx_version 'bodacious'
games { 'gta5' }

lua54 'yes'


ui_page('dist/index.html') 

shared_scripts {
	'@ox_lib/init.lua',
}


files({
  'dist/index.html',
  'dist/js/app.js',
  'dist/js/chunk-vendors.js',
  'dist/js/ppshop-customize.js',
  'dist/css/*.css',
  'dist/img/*.webp',
})

client_scripts {
  'config.lua',
  'client.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server.lua'
}