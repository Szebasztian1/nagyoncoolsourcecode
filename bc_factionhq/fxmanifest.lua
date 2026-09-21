fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'custom'
description 'FactionHQ - purchasable faction HQ shell interiors with entry CP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'shared/require.lua', -- module loader (vanilla FiveM has no file-aware require)
    'config.lua',
}

-- Only entry files are scripts; modules load via require
-- (client modules must be in files{} so the client can require them)
client_scripts {
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/breach.css',
    'html/breach.js',
    'html/img/house.png',
    'client/modules/menu.lua',
    'client/modules/menus.lua',
    'client/modules/marker.lua',
    'client/modules/placement.lua',
    'client/modules/shell.lua',
    'client/modules/furniture.lua',
    'client/modules/minigame.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'es_extended',
}

-- Soft runtime dependencies (checked with GetResourceState, never hard-required):
--   esx_job_creator  -> free CP round (its boss2 moveCP asks our ConsumeFreeMove export)
--   bc_ppshop        -> PP currency (getpp/removepp only, addpp is never called)
--   rota_loading     -> loading screen during enter/exit teleports
-- Shell asset packs must be ensured in server.cfg:
--   Shell5, k4mb1_shells, avp_house_shell_pack_03, avp_house_shell_03_props
-- SQL: tables are created automatically on first start (sql/ is reference only).
