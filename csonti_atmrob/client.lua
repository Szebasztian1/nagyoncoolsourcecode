loaded = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    loaded = true
    ESX.PlayerData = xPlayer
    loadTarget()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    ESX.PlayerData = ESX.GetPlayerData()
    loadTarget()
end)

local proc = {}
AddEventHandler("bc:protectedATMs", function(asd)
    proc = asd 
end)


function loadTarget()
    exports.ox_target:addModel({ 'prop_atm_03', 'prop_fleeca_atm', 'prop_atm_01', 'prop_atm_02' }, {
        {
            label = 'ATM Rablása',
            icon = 'fa-solid  fa-money-bill',
            distance = 5.0,
            --items = 'cutter',
            onSelect = function(data)
                local count = exports.ox_inventory:Search('count', 'cutter')
                if count < 1 then 
                    TriggerEvent("esx:showNotification", "Nincs nálad plazmavágó (ATM)")
                    return 
                end 
                local en = data.entity 
                for k, v in pairs(proc) do 
                    if v == en then 
                        TriggerEvent("esx:showNotification", "Ez egy frakciós ATM!")
                        return 
                    end 
                end 
                ESX.TriggerServerCallback('atmrob:isatmrobbed', function(robbed)
                    if robbed == false then
                        TaskGoToEntity(cache.ped, data.entity, 3000, 0.1, 1.0)
                        TaskTurnPedToFaceEntity(cache.ped, data.entity, -1)
                        Citizen.Wait(1500)
                        TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_WELDING")

                        welding = true

                        Citizen.CreateThread(function()
                                while welding do
                                    Citizen.Wait(1000)
                                    InvalidateIdleCam()
                                end
                        end)

                        local player = PlayerPedId()
                        local playerLoc = GetEntityCoords(player)
                        TriggerEvent("bc:alertpolicerobbery")
                        exports["gs_eventprotect"]:GS_TriggerServerEvent('atmrob:alertPolice', playerLoc)

                        SetNuiFocus(true, true)
                        SendNUIMessage({
                            type = "weld",
                            start = true,
                            weldSpeed = Config.weldSpeed,
                            weldError = Config.weldError
                        })
                    else
                        --exports['okokNotify']:Alert("ATM", "Ezt az ATM-et már kirabolták!", 5000, 'hiba')
                        TriggerEvent("esx:showNotification", "Ezt az ATM-et már kirabolták!")
                    end
                end, atm)
            end
        }
    })
end

local welding = false
--[[Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        while welding do
            Citizen.Wait(1000)
            InvalidateIdleCam()
        end
    end
end)]]

function getNearestATM(dist)
    local player = PlayerPedId()
    local playerLoc = GetEntityCoords(player, 0)
    for i, atmModel in pairs(Config.atm) do
        atm = GetClosestObjectOfType(playerLoc, dist, GetHashKey(atmModel), false)
        if DoesEntityExist(atm) then
            return atm
        end
    end
    return false
end

function policeAlert(x, y, z)
    Citizen.CreateThread(function()
        local blip = AddBlipForCoord(x, y, z)
        SetBlipSprite(blip, 161)
        SetBlipColour(blip, 1)
        SetBlipDisplay(blip, 10)
        TriggerEvent('esx:showNotification', "ATM Rablás folyamatban!")
        Citizen.Wait(60000)
        RemoveBlip(blip)
    end)
end

RegisterNUICallback("welddone", function()
    TriggerServerEvent('atmrob:atmrobbed', getNearestATM(1.5))
    SendNUIMessage({
        type = "cells",
        start = true,
        cellOpenSpeed = Config.cellOpenSpeed,
        cellMoney = Config.cellMoney
    })
    local ped = PlayerPedId(-1)
    TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL")
end)

RegisterNUICallback("esc", function()
    SetNuiFocus(false, false)
    local ped = PlayerPedId(-1)
    ClearPedTasks(ped)
    welding = false
    TriggerServerEvent('atmrob:end')
    --exports['okokNotify']:Alert("ATM", "Rablás félbe szakítva!", 5000, 'hiba')
    TriggerEvent("esx:showNotification", "Rablás félbe szakítva!")
end)

RegisterNUICallback("cellsEmpty", function()
    SetNuiFocus(false, false)
    local ped = PlayerPedId(-1)
    ClearPedTasks(ped)
    welding = false
    TriggerServerEvent('atmrob:end')
end)

RegisterNUICallback("cellOpened", function()
    local payment = math.random(Config.cellMoney[1], Config.cellMoney[2])
    exports["gs_eventprotect"]:GS_TriggerServerEvent('atmrob:giveMoney', payment)
   -- exports['okokNotify']:Alert("ATM", ("A cellában volt: %s"):format(moneyFormat(payment)), 5000, 'hiba')
   TriggerEvent("esx:showNotification", ("A cellában volt: %s"):format(moneyFormat(payment)))
end)


RegisterNetEvent("atmrob:policeAlert")
AddEventHandler("atmrob:policeAlert", function(x, y, z)
    policeAlert(x, y, z)
end)

function moneyFormat(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end
