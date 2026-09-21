local bannedUntil = 0
ESX = exports["es_extended"]:getSharedObject()

-- Belépéskor és parancsnál is szinkronizálunk
RegisterNetEvent("bcs_weaponban:update", function(untilTime)
    bannedUntil = untilTime or 0
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do 
        Wait(100)
    end 
    Wait(5000)
    ESX.TriggerServerCallback('bcs_weaponban:checkMyBan', function(banData)
        if banData then
            bannedUntil = banData.untilTime 
        end
    end)
end)

-- /fegyvertiltasom JAVÍTVA
RegisterCommand("fegyvertiltasom", function()
    ESX.TriggerServerCallback('bcs_weaponban:checkMyBan', function(banData)
        if banData then
            local remaining = math.ceil((banData.untilTime - GetCloudTimeAsInt()) / 60)
            if remaining > 0 then
                ESX.ShowNotification("~r~Fegyvertiltásod van!~s~\nAdmin: ~y~" .. (banData.bannedBy or "Ismeretlen") .. "~s~\nHátralévő: ~o~" .. remaining .. " perc.")
            else
                ESX.ShowNotification("~g~Nincs aktív fegyvertiltásod.")
            end
        else
            ESX.ShowNotification("~g~Nincs aktív fegyvertiltásod.")
        end
    end)
end)

-- Admin panel megnyitása és frissítése
local function refreshAdminPanel()
    ESX.TriggerServerCallback('bcs_weaponban:getBans', function(banData)
        SendNUIMessage({ type = "open", bans = banData })
    end)
end

RegisterCommand("fegyvertiltas", function()
    ESX.TriggerServerCallback('bcs_weaponban:getBans', function(banData)
        if banData then
            SetNuiFocus(true, true)
            SendNUIMessage({ type = "open", bans = banData })
        else
            ESX.ShowNotification("~r~Nincs jogosultságod!")
        end
    end)
end)

RegisterNUICallback('submitBan', function(data, cb)
    if data.id and data.time then
        ExecuteCommand(string.format("weaponban %s %s %s", data.id, data.time, data.reason or "Nincs indok"))
        Citizen.Wait(500)
        refreshAdminPanel() -- Azonnali frissítés a beküldés után
    end
    cb('ok')
end)

RegisterNUICallback('unban', function(data, cb)
    if data.identifier then
        ExecuteCommand("fegyverunban " .. data.identifier)
        Citizen.Wait(500)
        refreshAdminPanel()
    end
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Tiltás érvényesítése
CreateThread(function()
    while true do
        local wait = 1000
        if bannedUntil > GetCloudTimeAsInt() then
            wait = 0
            DisableControlAction(0, 24, true)
            DisablePlayerFiring(PlayerId(), true)
            if GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey("WEAPON_UNARMED") then
                SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
            end
        end
        Wait(wait)
    end
end)