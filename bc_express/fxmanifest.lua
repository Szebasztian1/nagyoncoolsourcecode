


fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Scriptjavit'
description 'BC Express – futár munka + beépített RoadPhone app (ESX + ox_lib + ox_target)'
version '1.4.0'

-- A depo statisztika/karrier panel (a resource saját NUI-ja). A telefon-app külön, iframe-ből (html/index.html).
ui_page 'html/panel.html'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua',
}

-- Csak az entry fájlok kerülnek ide; a modulok require-rel töltődnek (client modulok a files-ban).
client_scripts {
    'client/munkablip.lua',
    'client/markers.lua',   -- saját marker rendszer (a mate-markers helyett)
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

-- Client modulok (require-hez a kliensnek le kell töltenie) + RoadPhone app UI + depo panel + AI hangok
files {
    'client/modules/*.lua',
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/panel.html',
    'html/panel.css',
    'html/panel.js',
    'html/img/*.webp',
    'sounds/*.ogg',
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
}
