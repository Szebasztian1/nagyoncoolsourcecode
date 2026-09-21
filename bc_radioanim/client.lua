local ESX = exports["es_extended"]:getSharedObject()

---@type string
local selanim = "default"

---@type string[]
local unlockedAnims = {}

---@param animId string
---@return boolean
local function IsUnlocked(animId)
    if animId == "default" then return true end
    for _, v in ipairs(unlockedAnims) do
        if v == animId then return true end
    end
    return false
end

RegisterCommand('radiomenu', function()
    ESX.TriggerServerCallback('radio:getData', function(data)
        selanim       = data.selected or 'default'
        unlockedAnims = data.unlocked or {}

        SetNuiFocus(true, true)
        SendNUIMessage({
            type     = "openUI",
            config   = Config.Animations,
            current  = selanim,
            unlocked = unlockedAnims,
            price    = Config.Price .. Config.Currency
        })
    end)
end)

RegisterNUICallback('select', function(data, cb)
    local animId = data.animation

    if IsUnlocked(animId) then
        local alert = lib.alertDialog({
            header   = 'Rádió animáció',
            content  = 'Lecseréled a rádió animációdat?',
            centered = true,
            cancel   = true
        })
        if alert == "confirm" then
            TriggerServerEvent('radio:saveSelection', animId)
        end
    else
        local alert = lib.alertDialog({
            header   = 'Rádió animáció',
            content  = 'Megveszed ezt az animációt **' .. Config.Price .. Config.Currency .. '** ért?',
            centered = true,
            cancel   = true
        })
        if alert == "confirm" then
            TriggerServerEvent('radio:saveSelection', animId)
        end
    end

    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('radio:updateUI')
AddEventHandler('radio:updateUI', function(data)
    selanim       = data.selected or 'default'
    unlockedAnims = data.unlocked or {}
end)

AddEventHandler("playerSpawned", function()
    Wait(5000)
    ESX.TriggerServerCallback('radio:getData', function(data)
        selanim       = data.selected or 'default'
        unlockedAnims = data.unlocked or {}
    end)
end)

exports('anim', function()
    if not selanim then return false end
    if selanim == "default" then return false end
    if Config.Animations[selanim] then
        return Config.Animations[selanim].dict, Config.Animations[selanim].anim,
            (Config.Animations[selanim].lefthand or false)
    end
    return false
end)
