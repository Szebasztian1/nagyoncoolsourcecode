fx_version 'bodacious'
games { 'gta5' }
description 'ESX Ambulance Job'

version '1.2.0'
lua54 'yes'
ui_page 'html/index.html'

files {
    'html/**',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',

}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/br.lua',
    'locales/en.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/es.lua',
    'locales/sv.lua',
    'locales/pl.lua',
    'locales/cs.lua',
    'locales/de.lua',
    'config.lua',
    'server/main.lua',
    'server/revive_auth.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/br.lua',
    'locales/en.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/es.lua',
    'locales/sv.lua',
    'locales/pl.lua',
    'locales/cs.lua',
    'locales/de.lua',
    'config.lua',
    'client/markers.lua',
    'client/main.lua',
    'client/job.lua'
}

dependencies {
    'es_extended'
}
