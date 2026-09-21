



























fx_version 'cerulean'
game 'gta5'

name "FiveStar-SpawnSelector"
description "Spawn Selector System by FiveStar"
author "FiveStar Development Team"
website "5star.Codes"
discord "discord.5star.codes"
tebex "5star.tebex.io"
version "1.0"
lua54 'yes'

client_scripts {
	'client/customspawn.lua',
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
	'server/customspawn.lua'
}

shared_scripts {
	'@ox_lib/init.lua',
	'shared/config.lua',
	'shared/customspawn.lua'
}

ui_page "ui/index.html"

files {
	"ui/index.html",
	"ui/images/*.*",
	"ui/sounds/*.*",
	"ui/css/*.*",
	"ui/js/*.*"
}