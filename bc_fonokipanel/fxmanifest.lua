
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'custom'
description 'Egyesitett fonoki panel (CP kezeles + tarolo/szef hozzaferes) - NUI'
version '1.0.0'

shared_script '@es_extended/imports.lua'

dependencies {
    'es_extended',
    'esx_job_creator',
}

-- Opcionalis fuggoseg: bc_factionjump (Discord rang levetel + factionjump kirugaskor).
-- Nem hard dependency, hogy a panel akkor is elinduljon, ha nincs telepitve.

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}
