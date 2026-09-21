



fx_version "cerulean"
game "gta5"
lua54 "yes"

name "mate-slot"
author "MateHUN"
version "1.0.0"
description "No project description has been set"


use_experimental_fxv2_oal 'yes'


shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "shared/config.lua",
    "utils/math.lua",
    "rpc/shared.lua",
}

server_scripts {
    "core/SlotEngine.lua",
    "core/PlayerSession.lua",
    "core/SessionManager.lua",
    "core/RtpVariance.lua",
    "core/RtpSimulator.lua",
    "rpc/server.lua",
    "modules/server.lua",
}

client_scripts {
    "rpc/client.lua",
    "client/animations.lua",
    "client/world.lua",
    "client/session.lua",
    "client/admin.lua",
    "modules/client.lua",
}

ui_page "web/dist/index.html"

files {
    "web/dist/**.*",
    "web/public/**.*",
    "web/public/symbols/*.png",
    "web/public/*.png",
    "web/public/sounds/*.mp3",
}
