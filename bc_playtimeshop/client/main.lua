-- imports.lua already defines ESX; only fall back to the legacy event if it did not.
if Config.Framework == "newEsx" then
    ESX = exports["es_extended"]:getSharedObject()
end

local rewardDeadline = 0 -- GetGameTimer() value at which the next coin reward is due

local function resetRewardTimer()
    rewardDeadline = GetGameTimer() + (Config.NeededPlayTime * 60000)
end

local function sendTranslations()
    SendNUIMessage({
        type = 'translate',
        translate = Config.Language,
    })
end

Citizen.CreateThread(function()
    while ESX == nil do
        if Config.Framework == "esx" then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
        Citizen.Wait(100)
    end

    resetRewardTimer()
    Wait(10000)
    sendTranslations()
end)

RegisterNetEvent('esx:playerLoaded', function()
    resetRewardTimer()
    Wait(5000)
    sendTranslations()
end)

local function isPlayerCuffed()
    local ok, cuffed = pcall(function()
        return exports["esx_job_creator"]:isCuffed()
    end)
    if ok and cuffed then return true end
    return LocalPlayer.state.handcuff == true
end

-- Seconds left until the next coin reward.
local function getRemainingSeconds()
    local remaining = math.floor((rewardDeadline - GetGameTimer()) / 1000)
    return remaining > 0 and remaining or 0
end

local openMenuSpamProtect = 0
local function openMenu()
    if isPlayerCuffed() then
        TriggerEvent("esx:showNotification", "Meg vagy bilincselve, nem nyithatod meg a boltot!")
        return
    end
    if openMenuSpamProtect > GetGameTimer() then return end
    openMenuSpamProtect = GetGameTimer() + 1500

    ESX.TriggerServerCallback("PlaytimeShop:Server:GetPlayerDetails", function(result)
        if not result then return end

        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openui',
            -- Sent again here: the startup `translate` message races the NUI becoming ready.
            translate = Config.Language,
            coin = result.coin,
            categories = Config.Categories,
            items = Config.Items,
            avatar = result.avatar,
            firstname = result.firstName,
            remaining = getRemainingSeconds(),
            coinReward = Config.RewardCoin,
            topPlayers = result.topPlayers,
        })
    end)
end

RegisterCommand(Config.OpenCommand, function()
    openMenu()
end)

-- Sleeps until the reward is actually due instead of polling on a short timer.
Citizen.CreateThread(function()
    while true do
        -- rewardDeadline is 0 until ESX is up; claiming then would hand out a free reward.
        if rewardDeadline == 0 then
            Wait(1000)
        else
            local remaining = getRemainingSeconds()
            if remaining <= 0 then
                resetRewardTimer()
                exports["gs_eventprotect"]:GS_TriggerServerEvent('PlaytimeShop:Server:AddCoin', Config.RewardCoin)
                Wait(60000)
            else
                -- The deadline only ever moves later, so sleeping the whole way is safe.
                Wait(remaining * 1000)
            end
        end
    end
end)

local buyItemSpamProtect = 0
RegisterNUICallback('buyItem', function(data, cb)
    if buyItemSpamProtect > GetGameTimer() then return cb(false) end
    buyItemSpamProtect = GetGameTimer() + 1500

    -- Only the id is used server side; don't ship the whole item object over the network.
    local itemId = type(data) == "table" and type(data.itemInfo) == "table" and data.itemInfo.id
    if not itemId then return cb(false) end

    ESX.TriggerServerCallback("PlaytimeShop:Server:BuyItem", function(result)
        cb(result)
    end, { itemInfo = { id = itemId } })
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
