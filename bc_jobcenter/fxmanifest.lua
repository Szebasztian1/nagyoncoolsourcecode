





























fx_version 'adamant'

game 'gta5'

lua54 "yes"

description 'Jobcenter by 6osvillamos'

version '1.1'

ui_page 'html/index.html'

files {
  	'html/**'
}

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
	'config/shared.lua',	
	'@es_extended/locale.lua',
	'locales/*.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'server.lua'
}

dependencies {
	'es_extended',
	'ox_lib'
}
