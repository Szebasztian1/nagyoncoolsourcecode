function Notify(msg)
    ESX.ShowNotification(msg)
end 

RegisterCommand(Config.Command, function(s, a, r)
    OpenVIPMenu()
end)
if Config.OpenKey then
    RegisterKeyMapping(Config.Command, Translate("command_desc"), 'keyboard', Config.OpenKey)
end

RegisterNUICallback('getautorenewinfo', function(data, cb)
    ESX.TriggerServerCallback('bc_vip:getautorenewinfo', cb)
end)
RegisterNUICallback('toggleautorenew', function(data, cb)
    ESX.TriggerServerCallback('bc_vip:toggleautorenew', cb)
end)
RegisterNUICallback('cancelvip', function(data, cb)
    ESX.TriggerServerCallback('bc_vip:cancelvip', cb)
end)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/'..Config.Command, Translate("command_desc"), {})
    TriggerEvent('chat:addSuggestion', '/claimvip', "Claim a VIP membership", {
        { name="code", help="The VIP code" },
    })

    TriggerEvent('chat:addSuggestion', '/addvip', "Add VIP to player", {
        { name="playerid", help="the player's server id" },
        { name="bundle", help="VIP bundle (from config)" },
        { name="time", help="in hours" },
    })
    TriggerEvent('chat:addSuggestion', '/delvip', "Remove VIP from player", {
        { name="playerid", help="the player's server id" },
    })
    TriggerEvent('chat:addSuggestion', '/addvipxp', "Add VIP XP to player", {
        { name="playerid", help="the player's server id" },
        { name="count", help="XP count" },
    })
    TriggerEvent('chat:addSuggestion', '/createvipcode', "Create a new VIP code", {
        { name="bundle", help="VIP bundle (from config)" },
        { name="time", help="in hours" },
    })
    TriggerEvent('chat:addSuggestion', '/deletevipcode', "Delete a VIP code", {
        { name="code", help="The VIP code" },
    })
end)