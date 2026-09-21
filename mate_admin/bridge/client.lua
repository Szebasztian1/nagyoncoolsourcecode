
Bridge = {}

Framework = nil
Inventory = nil

PlayerLoaded = false
PlayerData = {}

local function InitializeFramework()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'esx'

        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
            PlayerLoaded = true
            TriggerEvent('mate-admin:onPlayerLoaded')
        end)

        RegisterNetEvent('esx:onPlayerLogout', function()
            table.wipe(PlayerData)
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerData = Bridge.GetPlayerData()
            PlayerLoaded = true
            TriggerEvent('mate-admin:onPlayerLoaded')
        end)
    elseif GetResourceState('qbx_core') == 'started' then
        Framework = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb'
    elseif GetResourceState('ox_core') == 'started' then
        Ox = require '@ox_core.lib.init'
        Framework = 'ox'
    else
    end
end

local function InitializeInventory()
    if GetResourceState('ox_inventory') == 'started' then
        Inventory = 'ox_inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Inventory = 'qb-inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        Inventory = 'qs-inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        Inventory = 'ps-inventory'
    elseif GetResourceState('origen_inventory') == 'started' then
        Inventory = 'origen_inventory'
    elseif GetResourceState('codem-inventory') == 'started' then
        Inventory = 'codem-inventory'
    elseif GetResourceState('core_inventory') == 'started' then
        Inventory = 'core_inventory'
    else
    end
end

---@return table
function Bridge.GetPlayerData()
    if Framework == 'esx' then
        return ESX.GetPlayerData()
    else
        return {}
    end
end

---@return any
function Bridge.GetPlayerInventory()
    if Inventory then
        if Inventory == 'ox_inventory' then
            return exports.ox_inventory:GetPlayerItems()
        elseif Inventory == 'qb-inventory' or Inventory == 'ps-inventory' then
            return Bridge.GetPlayerData().items
        elseif Inventory == 'qs-inventory' then
            return exports['qs-inventory']:getUserInventory()
        elseif Inventory == 'origen_inventory' then
            return exports.origen_inventory:GetInventory()
        elseif Inventory == 'codem-inventory' then
            return exports['codem-inventory']:GetClientPlayerInventory()
        else
            return nil
        end
    else
        if Framework == 'esx' then
            return Bridge.GetPlayerData().inventory
        else
            return nil
        end
    end
end

---@param item string
---@return table?
function Bridge.GetItemData(item)
    if not item then return nil end
    if Inventory then
        if Inventory == 'ox_inventory' then
            return exports.ox_inventory:Items(item)
        elseif Inventory == 'qb-inventory' or Inventory == 'ps-inventory' then
            return QBCore.Shared.Items[item]
        elseif Inventory == 'qs-inventory' then
            local items = exports['qs-inventory']:GetItemList()
            if not items then return nil end
            return items[item]
        elseif Inventory == 'origen_inventory' then
            local items = exports.origen_inventory:GetItems()
            if not items then return nil end
            return items[item]
        elseif Inventory == 'codem-inventory' then
            local items = exports['codem-inventory']:GetItemList()
            if not items then return nil end
            return items[item]
        elseif Inventory == 'core_inventory' then
            if Framework == 'qb' then
                return QBCore.Shared.Items[item]
            else
                print('^1[mate-admin][ERROR]^7 core_inventory has no client item-list export outside QB; add a custom lookup here.')
            end
        else
        end
    else
        if Framework == 'qb' then
            return QBCore.Shared.Items[item]
        else
        end
    end
    return nil
end

---@param item string
---@param amount number
---@return boolean
function Bridge.HasItem(item, amount)
    if not item or not amount then return false end
    if Inventory then
        if Inventory == 'ox_inventory' then
            return exports.ox_inventory:Search('count', item) >= amount
        elseif Inventory == 'core_inventory' then
            return exports['core_inventory']:hasItem(item, amount)
        elseif Inventory == 'qs-inventory' then
            return exports['qs-inventory']:Search(item) >= amount
        elseif Inventory == 'origen_inventory' then
            return exports.origen_inventory:Search('count', item) >= amount
        else
            return exports[Inventory]:HasItem(item, amount)
        end
    else
        local player = Bridge.GetPlayerData()
        if not player then return false end
        local inventory = Framework == 'esx' and player.inventory or player.items
        if not inventory then return false end
        for _, item_data in pairs(inventory) do
            if item_data and item_data.name == item then
                local count = item_data.amount or item_data.count or 0
                if count >= amount then
                    return true
                end
            end
        end
        return false
    end
end

InitializeFramework()
InitializeInventory()
