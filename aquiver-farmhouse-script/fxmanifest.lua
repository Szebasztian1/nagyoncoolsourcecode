

fx_version 'adamant'

game 'gta5'

provide "aquiver-farmhouse-script"

version "1.0.8-pre.1"

lua54 "yes"

escrow_ignore {
    "lua/**",

    "bridge/**"
}

files {
    "txd/**",

    "data/images/**",

    "resource/dui/**",
    "resource/html/**",

    "locales/*.json",
    "lua/client/**.lua",
    "lua/shared/**.lua"
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    "@aquiver_cfx/client/Graphics.lua",
    "@aquiver_cfx/client/GameplayCamera.lua",
    "@aquiver_cfx/client/DrawSpriteMeter.lua",
    "@aquiver_cfx/client/DrawSpriteMeter3D.lua",

    "lua/client/main.lua"
}

server_scripts {
    "lua/server/main.lua",

    "bridge/esx.lua",
    "bridge/qbcore.lua"
}

dependencies {
    "aquiver-farmhouse-mlo",
    "aquiver-farmhouse-props",
    "aquiver-farmhouse-sounds",
    "aquiver_cfx",
    "ox_target"
}

ui_page 'resource/html/index.html'
-- ui_page 'http://localhost:5173' -- Used for developing


--[[
    1.0.1:
    - tickState was wrongly initialized at some case, it may resulted in some enter/leave issues in the instance.
    - frontend had some callback error (nui) fixed.
    - Config now has an INTERACTION_KEY, and LOCK_KEY variable (to switch up the keybinds if needed)

    1.0.2:
    - Scraped entire renting system
    - You can purchase the farmhouses for lifetime from now on
    - You can trade the bought farmhouses with other players
    - You can now rename your owned farmhouse(s)
    - Removed the NUI when you are near the farmhouse entrance/exit
    - Entrance NUI is switched for ox_lib contextMenu, which has more options (like rename farmhouse, trading, etc.)
    - Fixed some missing localization keys. (Blip category, and others.)
    - You can now set the pitchfork maximum content limit in the Config file. (Config.MAX_PITCHFORK_COUNT)
    - You can now change the blip sprite in the Config file. (Config.BLIP_SPRITE_ID)
    - You can now change the blip category id in the Config file. (Config.BLIP_CATEGORY_ID)
    - Removed some unused Config variable(s)

    Note:
    - Missing localization key(s) were added at the end of the `en.json` file.
    - .sql file got an update (expiresAt was deleted)

    1.0.3:
    - Entire code got refactored to the base ox_lib class design
    - Interior ID checker (if you died inside you were stuck, and instance did not reset for you.)
    - DrawSprite txd textures are registered with the runtime Cfx native (and can be directly changed in the `txd` folder)
    This means that you no longer need the aquiver-farmhouse-sprite dependency folder

    - Fixed the .sql file with DECIMAL values
    - AudioBank was not unloading when you left the instance and it caused some memory issues after time
    - HandOccupiedState was not resetted when the resource stopped and it caused interaction issues with the entities
    - Removed some unneccessary texts and bars from the entities (watertrough, etc.), they use the new DrawSpriteMeter from now on
    - There was an issue during purchasing the livestock entity from the market, and it gave a serverside error message, it was fixed.
    - Fixed an issue where the player was given the wrong cash value when selling storage entity. (Milk, Egg)
    - Animals died automatically after an hour because there was a setter bug, this has been fixed (**This was the most reported issue towards us**)

    1.0.4:
    - Gathering process percentage was stuck between 0-10%, it was fixed.

    1.0.5:
    - Removed the bridge folder with its framework functions.
    - aquiver_cfx library now handles the cursor interaction(s) differently, it wont mess with other resources. (lb-phone was reported)
    - Our aquiver_cfx library was updated, now it contains the framework link(s) and should handle many frameworks automatically.
    - Fixed the nui promise callback error.

    **Important**
    ox_target version is now ready for this script. If you are missing this version of the script, please feel free to open a ticket, we will re-send you the package.

    1.0.6:
    - Missing commands (farmhouse_create, etc.) have been returned to the `bridge˙ folder.

    1.0.7:
    ** Lobby entrance system **
    - The lobby system has been implemented with UI, allowing all greenhouses to be accessed and entered from a single central hub.
    - You can toggle this feature in the Config.lua file, and there are also some additional configuration variables.

    - Performance improved; the entrance coordinates now use lib.points (0.00 ms idle state)
    - There was also some code refactoring, just to make the code cleaner

    1.0.8:
    - Added new Config variable(s) to modify the balance and other things easily
    - Config.AGE_INCREASE_ON_TICK
    - Config.CHICKEN_GATHER_INCREASE_ON_TICK
    - Config.COW_GATHER_INCREASE_ON_TICK
    - There was a minor bug in the animals' tick, which meant there was no random increase on the gather value at all

]]

dependency '/assetpacks'