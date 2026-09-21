games {
    "gta5"
}

version "1.0.0"

fx_version "cerulean"

files 
{
    'stream/*.ytyp',
    'stream/*.ydr',
    
 }
 
data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'

this_is_a_map 'yes'

escrow_ignore {
    "--animations list config--/*.lua",
    "--animations list config--/*.txt",
}

dependency '/assetpacks'