

fx_version 'adamant'

game 'gta5'

version "1.0"

lua54 "yes"

escrow_ignore {
    "**.lua"
}

shared_scripts {

}

client_scripts {
    "client/GameCursor.lua"
}

server_scripts {
    "links/frameworks/esx/server.lua",
    "links/frameworks/qbcore/server.lua",
    "links/frameworks/qbox/server.lua",

    "links/inventories/ox_inventory/server.lua",

    "server/exports.lua"
}

files {
    "client/**.lua"
}

dependency '/assetpacks'