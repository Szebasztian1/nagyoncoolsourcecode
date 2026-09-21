








fx_version 'adamant'
lua54 'yes'
game 'gta5'

description 'by 6osvillamos'

file 'i.lua'
file 'i_c.lua'
file 'i_s.lua'

shared_scripts {
	'sevents.lua',
	'utils.lua',
}

server_scripts {
	's.lua',
	's_u.lua'
}

client_scripts {
	'c.lua'
}

escrow_ignore {
	's_u.lua',
	'sevents.lua',
	'i_c.lua',
	'i_s.lua',
}
dependency '/assetpacks'
dependency '/assetpacks'