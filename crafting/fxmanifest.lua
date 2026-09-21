

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'utils.lua',
    'recipes.lua',
    'config.lua',
    'client.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'utils.lua',
    'recipes.lua',
    'config.lua',
    'server.lua',
}

files {
    "html/index.html",

    --"html/img/weed.png",
    --"-html/img/bagofdope.png",
    --"html/img/drugscales.png",
    --"html/img/dopebag.png",

    "html/img/craft_button.png",
    "html/img/reset_button.png",
    "html/img/left_arrow.png",
    "html/img/right_arrow.png",

    "html/img/pistolcso.png",
    "html/img/pistolbelso.png",
    "html/img/pistoltar.png",

    "html/img/tec9belso.png",
    "html/img/tec9cso.png",
    "html/img/tec9tar.png",

    "html/img/ak47cso.png",
    "html/img/ak47belso.png",
    "html/img/ak47ravasz.png",
    "html/img/ak47valtamasz.png",
    "html/img/ak47tar.png",

    "html/img/shotguncso.png",
    "html/img/shotgunbelso.png",
    "html/img/shotgunravasz.png",
    "html/img/shotgunvaltamasz.png",
    "html/img/shotguntar.png",

    "html/img/uzicso.png",
    "html/img/uzibelso.png",
    "html/img/uziravasz.png",
    "html/img/uzitar.png",
}

dependency "esx_job_creator"