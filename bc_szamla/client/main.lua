local uiOpen = false

local function closeUI()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeAll'
    })
end

local function getNearbyPlayers()
    local result = {}
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)

    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)

        if ped ~= myPed then
            local coords = GetEntityCoords(ped)
            local dist = #(myCoords - coords)

            if dist <= Config.NearbyDistance then
                result[#result + 1] = {
                    id = GetPlayerServerId(player),
                    name = nil,
                    distance = math.floor(dist * 10) / 10
                }
            end
        end
    end

    table.sort(result, function(a, b)
        return a.distance < b.distance
    end)

    return result
end

RegisterNetEvent('bc_billing:client:openMainMenu', function(data)
    uiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'openMainMenu',
        theme = data.theme or Config.Theme,
        canIssue = data.canIssue == true
    })
end)

RegisterNetEvent('bc_billing:client:openCreate', function(data)
    uiOpen = true
    SetNuiFocus(true, true)

    local nearby = getNearbyPlayers()

    SendNUIMessage({
        action = 'openCreate',
        theme = data.theme or Config.Theme,
        players = nearby
    })

    TriggerServerEvent('bc_billing:server:resolveICNames', nearby)
end)

RegisterNetEvent('bc_billing:client:updateNearbyPlayers', function(players)
    SendNUIMessage({
        action = 'updateNearbyPlayers',
        players = players or {}
    })
end)

RegisterNetEvent('bc_billing:client:openInvoices', function(data)
    uiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'openInvoices',
        theme = data.theme or Config.Theme,
        invoices = data.invoices or {},
        canIssue = data.canIssue == true
    })
end)

RegisterNetEvent('bc_billing:client:openTrackedInvoices', function(data)
    uiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'openTrackedInvoices',
        theme = data.theme or Config.Theme,
        tracked = data.tracked or {}
    })
end)

RegisterNetEvent('bc_billing:client:incomingInvoice', function(data)
    uiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'openIncoming',
        theme = data.theme or Config.Theme,
        invoice = data.invoice
    })
end)

RegisterNUICallback('close', function(_, cb)
    closeUI()
    cb('ok')
end)

RegisterNUICallback('openMainMenu', function(_, cb)
    TriggerServerEvent('bc_billing:server:openMain')
    cb('ok')
end)

RegisterNUICallback('openCreateMenu', function(_, cb)
    TriggerServerEvent('bc_billing:server:openCreate')
    cb('ok')
end)

RegisterNUICallback('openMyInvoicesMenu', function(_, cb)
    TriggerServerEvent('bc_billing:server:openList')
    cb('ok')
end)

RegisterNUICallback('openTrackedMenu', function(_, cb)
    TriggerServerEvent('bc_billing:server:openTracked')
    cb('ok')
end)

RegisterNUICallback('refreshNearby', function(_, cb)
    local nearby = getNearbyPlayers()
    cb(nearby)
    TriggerServerEvent('bc_billing:server:resolveICNames', nearby)
end)

RegisterNUICallback('createInvoice', function(data, cb)
    TriggerServerEvent('bc_billing:server:createInvoice', {
        targetId = tonumber(data.targetId),
        reason = tostring(data.reason or ''),
        amount = tonumber(data.amount)
    })

    closeUI()
    cb('ok')
end)

RegisterNUICallback('respondInvoice', function(data, cb)
    TriggerServerEvent('bc_billing:server:respondInvoice', {
        id = tonumber(data.id),
        accepted = data.accepted == true
    })

    closeUI()
    cb('ok')
end)

RegisterNUICallback('payInvoice', function(data, cb)
    TriggerServerEvent('bc_billing:server:payInvoice', {
        id = tonumber(data.id)
    })
    cb('ok')
end)

RegisterNUICallback('deleteInvoice', function(data, cb)
    TriggerServerEvent('bc_billing:server:deleteInvoice', {
        id = tonumber(data.id)
    })
    cb('ok')
end)

RegisterNetEvent('bc_billing:client:notify', function(msg, typ)
    if Config.NotifyType == 'okokNotify' and GetResourceState('okokNotify') == 'started' then
        local notifyType = 'info'

        if typ == 'success' then
            notifyType = 'success'
        elseif typ == 'error' then
            notifyType = 'error'
        elseif typ == 'warning' then
            notifyType = 'warning'
        end

        exports['okokNotify']:Alert('Black City Számla', msg, 5000, notifyType)
        return
    end

    if Config.UseOxLibNotify and GetResourceState('ox_lib') == 'started' then
        lib.notify({
            title = 'Black City Számla',
            description = msg,
            type = typ == 'error' and 'error' or (typ == 'success' and 'success' or 'inform')
        })
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(false, false)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        closeUI()
    end
end)

CreateThread(function()
    while true do
        if uiOpen then
            Wait(0)
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 18, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 68, true)
            DisableControlAction(0, 69, true)
            DisableControlAction(0, 70, true)
            DisableControlAction(0, 91, true)
            DisableControlAction(0, 92, true)
            DisableControlAction(0, 106, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 322, true)
        else
            Wait(500)
        end
    end
end)