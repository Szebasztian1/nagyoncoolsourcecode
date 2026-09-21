AM = {}

AM.MenuLocation = 'top-right'                                               --'top-left' or 'top-right' or 'bottom-left' or 'bottom-right'
AM.OpenMenuBind = 'I'                                               --Whitch button should you press to open the menu
AM.AlloweMiniGame = false                                                    --Allow minigame if player isnt in the right job?
AM.ForcedProximity = 50.0                                                   --Proximity of the own voice megaphone

AM.Langauge = 'hu'

AM.UseProp = false
AM.PropModel = `prop_megaphone_01`

AM.OnlyInVehicle = false

AM.AllowedJobs = {                                                          --Allowed jobs to use the Megaphone
    ['gov'] = true,
    ['police'] = true,
    ['fbi'] = true,
    ['fbiuj'] = true,
    ['uss'] = true,
    ['detective'] = true,
    ['guardarmy'] = true,
    ['irs'] = true,
    ['dea'] = true,
    ['sheriff'] = true,
    ['navi'] = true,
    ['usms'] = true,
    ['servicess'] = true,
    ['atf'] = true,
    ['ambulance'] = true
}

AM.AllowedVehicles = {                                                      --Allowed vehicles to use the Megaphone
    [`police`] = true
}

AM.AllowedVehClass = {                                                      --Allowed vehicle classes to use the Megaphone
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [19] = true,
    [20] = true,
    [21] = true,
    [22] = true
}

AM.Translate = { 
    ["en"] = {
        ['menu_title'] = 'Police Megaphone',
        ['keymapp_desc'] = 'Police Megaphone',
        ['hacking_succ'] = 'You failed to hack the megaphone system!',
        ['no_whitelisted_job'] = 'You are not an officer!',
        ['own_voice'] = 'Use your own voice!',
        ['log_message'] = 'A player turned on the megaphone.',
    },

    ["hu"] = {
        ['menu_title'] = 'Rendőrségi Megafon',
        ['keymapp_desc'] = 'Rendőrségi Megafon',
        ['hacking_succ'] = 'Nem sikerült feltörnöd a megafon rendszerét!',
        ['no_whitelisted_job'] = 'Nem vagy rendőr!',
        ['own_voice'] = 'Saját hang használata',
        ['log_message'] = 'Egy játékos bekapcsolta a megafont.',
    },
} AM.Translate = AM.Translate[AM.Langauge]

AM.SubmixSettings = {
    [`default`] = 1,
    [`freq_low`] = 300.0,
    [`freq_hi`] = 5000.0,
    [`rm_mod_freq`] = 0.0,
    [`rm_mix`] = 0.2,
    [`fudge`] = 0.0,
    [`o_freq_lo`] = 550.0,
    [`o_freq_hi`] = 0.0,
}

AM.Notification = function(text, time, type)
   --ESX.ShowNotification(text)
   TriggerEvent("esx:showNotification", text)
end