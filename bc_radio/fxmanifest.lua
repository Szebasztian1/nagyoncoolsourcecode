fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'custom'
description 'bc_radio - Q radio panel with Hungarian stations, 3D-synced via xsound'
version '1.0.0'

-- Only entry files are scripts; client modules load via require() and so must
-- also be listed in files{} for LoadResourceFile to read them.
shared_scripts {
    'shared/require.lua', -- module loader (vanilla FiveM has no file-aware require)
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/vue.global.prod.js',
    'html/js/app.js',
    'html/fonts/*.woff2',
    'client/modules/playback.lua',
}

-- Soft dependency (checked at runtime with GetResourceState, never hard-required):
--   xsound -> the actual audio playback. Without it the panel still opens, but
--             selecting a station only shows a notice. Ensure xsound in server.cfg.
