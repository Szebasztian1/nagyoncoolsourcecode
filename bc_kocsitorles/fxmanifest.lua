fx_version 'cerulean'

game 'gta5'

description 'csak a majmos gifert <3'

version '1.0.0'
lua54 "yes"

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/init.lua',
    'server/vehicleCover.lua',
    'server/utils.lua',
    'server/plate.lua',
    'server/avhd.lua',
    'server/vehicle_persist.lua',
    'server/cleanup.lua',
    'server/safezone_callback.lua',
    'server/logs.lua',
    'server/items.lua',
    'server/new_player.lua',
    'server/casino.lua',
    'server/anticheat.lua',
    'objectguard_config.lua',
    'server/objectguard.lua',
    'server/debug_commands.lua',
    'server/_zombie.lua',
}

client_scripts {
    'client/vehicleCover.lua',
    'client/keymapping.lua',
    'client/safezone.lua',
    'client/towing.lua',
    'client/task_clear.lua',
    'client/plate_guard.lua',
    'client/area_clear.lua',
    'client/npc_suppress.lua',
    'client/snow_chain.lua',
    'client/ped_report.lua',
    'client/crane.lua',
    'client/voice.lua',
    'client/vehicle_hud.lua',
    'client/_zombie.lua',
    'client/objectguard_test.lua',
}
