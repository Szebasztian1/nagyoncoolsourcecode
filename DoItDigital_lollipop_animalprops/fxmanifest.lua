version '1.0.0'
fx_version 'cerulean'
game 'gta5'

lua54 'yes'
escrow_ignore {
    'readme',
    'images'
}

files {
    'stream/**/*.ytyp',
    'stream/**/*.ydr',
    'stream/**/*.ytd'
}

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'

dependency '/assetpacks'