CreateThread(AM.InitSubmix)
CreateThread(AM.InitMenu)

----- EVENTS ------

RegisterNetEvent('am-megaphone:client:setSubmix', function(state, source)
    AM.VoiceOverMegaphone(state, source)
end)

--- KEYBINDS -----
RegisterCommand('megaphone', AM.OpenMenu)
RegisterKeyMapping('megaphone', AM.Translate['keymapp_desc'], 'keyboard', AM.OpenMenuBind)

----- EXPORTS -----

exports('OpenMenu', function()
    lib.showMenu('am_megaphone_menu')

    if AM.UseProp then
        AM.PlayAnimation(myped)
    end
end)

exports('IsWhitelisted', AM.IsWhitelisted)
exports('IsVehicleClassAllowed', AM.CheckVehicle)
exports('IsVehicleModelAllowed', AM.CheckVehicleModel)