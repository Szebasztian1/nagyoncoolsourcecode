









fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

name "ChristmasPropsControl"
author "Sarish for Patamods"
version "1.0.0"


client_scripts {
	'config.lua',
	'target.lua',
	'client.lua'
}
server_scripts {
	'server.lua',
}

escrow_ignore {
	'config.lua',
	'target.lua',
 }
dependency '/assetpacks'