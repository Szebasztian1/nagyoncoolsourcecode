fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ox_lib 'locale'

name 'mate-admin'
description 'Not set'
author 'MateHUN & Rota'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    "rpc/shared.lua",
    'config/config.lua',
    'config/debug.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server.lua',
    "rpc/server.lua",
    'config/server.lua',
    'config/runtime_overrides.lua',
    'core/HookBus.lua',
    'core/AceCheck.lua',
    'core/PlayerLog.lua',
    'core/PlayerNotes.lua',
    'core/DutyGroupSkin.lua',
    'core/AdminFunction.lua',
    'core/Command.lua',
    'core/AuditLog.lua',
    'core/SecureEvent.lua',
    'core/Duty.lua',
    'core/Report.lua',
    'core/ReportAI.lua',
    'core/Scheduler.lua',
    'core/VehicleWorldCache.lua',
    'core/AntiDutyAfk.lua',
    'core/AdminAbuse.lua',
    'core/ElectronAC.lua',
    'core/Event.lua',
    'core/EventTeam.lua',
    'core/VehiclePics.lua',
    'server/settings.lua',
    'server/managers.lua',
    'server/main.lua',
    'server/scheduler.lua',
    'server/spectate.lua',
    'server/players.lua',
    'server/admins.lua',
    'server/metrics.lua',
    'server/itemlist.lua',
    'server/vehiclelist.lua',
    'server/events.lua',
    'server/eventteam.lua',
    'server/dutyGroupSkin.lua',
    'commands/*.lua',
    'server/exports.lua',
    'server/editable/*.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/vendor/freecam/utils.lua',
    'client/vendor/freecam/config.lua',
    'client/vendor/freecam/camera.lua',
    'client/vendor/freecam_instructional.lua',
    'client/vendor/freecam/main.lua',
    "rpc/client.lua",
    'client/main.lua',
    'client/utils/*.lua',
    'client/handlers/*.lua',
    'client/handlers/EventSystem/*.lua',
    'client/handlers/Vehicle/*.lua',
    'client/handlers/Report/*.lua',
    'client/events.lua',
    'client/callbacks.lua',
    'client/editable/*.lua',
}


ui_page 'web/dist/index.html'

files {
    'locales/*.json',
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'assets/logo.png',
    'stream/*'
}


escrow_ignore {
    "config/*.lua",
    "locales/*.json",
    "server/editable/*.lua",
    "client/editable/*.lua",
    "bridge/*.lua",

}
