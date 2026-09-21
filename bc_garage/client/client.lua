local lastGarage
local nuiReady = false
local vehicleimgs = {}
local policeImpoundCooldownUntil = 0

-- Jarmu-kivetel spamvedelem (csak visszajelzes, a szerver a hiteles forras).
local takeoutCooldownUntil = 0

local function GetTakeoutCooldownLeft()
    local cd = Config.TakeoutCooldown or 0
    if cd <= 0 then return 0 end
    local remaining = math.ceil((takeoutCooldownUntil - GetGameTimer()) / 1000)
    return remaining > 0 and remaining or 0
end

local function StartTakeoutCooldown()
    local cd = Config.TakeoutCooldown or 0
    if cd <= 0 then return end
    takeoutCooldownUntil = GetGameTimer() + cd * 1000
end

RegisterNUICallback('exit', function(data, cb)
    SetNuiFocus(false, false) 
    SendNUIMessage({
        type = "show",
        enable = false
    })
    lastGarage = nil
    cb('ok')
end)


RegisterNUICallback('delcar', function(data, cb)
    local plate = data.plate 
    SetNuiFocus(false, false) 
    SendNUIMessage({
        type = "show",
        enable = false
    })
    lastGarage = nil
    cb('ok')

    local eles = {
        {
            unselectable = true,
            icon = "fas fa-info-circle",
            title = "Biztosan örökre törölni szeretnéd a garázsból a következő rendszámú autót: "..plate.."?",
        },
        {
            icon = "fas fa-check",
            title = "Igen",
            name = "yes"
        },
        {
            icon = "fas fa-times",
            title = "Nem",
            name = "no"
        },
    }

    ESX.OpenContext("right", eles, function(menu, ele)
        if ele and ele.name and ele.name == "yes" then 
            TriggerServerEvent("villamos_garage:deleteCar", plate)
        end
        ESX.CloseContext()
    end, function(menu)
    end)
end)

RegisterNUICallback('takeoutimpound', function(data, cb)
    local plate = data.plate 
    local vehtype = Config.Garages[lastGarage].type
    SetNuiFocus(false, false) 
    SendNUIMessage({
        type = "show",
        enable = false
    })
    lastGarage = nil
    cb('ok')
    if not vehtype then 
        return 
    end 

    if not Config.ReturnToGaragePrice[vehtype] then 
        TriggerEvent("esx:showNotification", "Ez a funkció ennél a járműtípusnál nem elérhető!")
        return 
    end 

    local eles = {
        {
            unselectable = true,
            icon = "fas fa-info-circle",
            title = "Biztosan vissza szeretnéd hozni a lefogalatakból a "..plate.." rendszámú autódat "..Config.ReturnToGaragePrice[vehtype].."$ ért?",
        },
        {
            icon = "fas fa-check",
            title = "Igen",
            name = "yes"
        },
        {
            icon = "fas fa-times",
            title = "Nem",
            name = "no"
        },
    }

    ESX.OpenContext("right", eles, function(menu, ele)
        if ele and ele.name and ele.name == "yes" then 
            TriggerServerEvent("villamos_garage:buyOutImpound", plate, vehtype)
        end
        ESX.CloseContext()
    end, function(menu)
    end)
end)

RegisterNUICallback('namecar', function(data, cb)
    local plate = data.plate 
    SetNuiFocus(false, false) 
    SendNUIMessage({
        type = "show",
        enable = false
    })
    lastGarage = nil
    cb('ok')

    local input = lib.inputDialog('Autó elnevezése', {'Becenév a következő autóhoz: '..plate})
 
    local newname = nil
    if  input and input[1] then 
        newname = input[1]
    end

    TriggerServerEvent("villamos_garage:nickname", plate, newname)
end)

RegisterNUICallback('fav', function(data, cb)
    local plate = data.plate 
    SetNuiFocus(false, false) 
    SendNUIMessage({
        type = "show",
        enable = false
    })
    lastGarage = nil
    cb('ok')

    TriggerServerEvent("villamos_garage:fav", plate)
end)

RegisterCommand("tstvehspawns", function()
    print(json.encode(GetAllVehicleModels()))
end)

RegisterNUICallback('taxmenu', function(data, cb)
    local plate = data.plate 
    SetNuiFocus(false, false) 
    SendNUIMessage({
        type = "show",
        enable = false
    })
    lastGarage = nil
    cb('ok')

    TriggerEvent("bc_tax:openVeh", plate)
end)
RegisterNUICallback('takeout', function(data, cb)
    local plate = data.plate 
    SetNuiFocus(false, false) 
    SendNUIMessage({
        type = "show",
        enable = false
    })
    local gar = lastGarage
    lastGarage = nil

    local cdleft = GetTakeoutCooldownLeft()
    if cdleft > 0 then
        cb('ok')
        return TriggerEvent("esx:showNotification", "Még "..cdleft.." másodpercet várnod kell a következő autó kivételéig!")
    end

    if not ESX.Game.IsSpawnPointClear(vector3(Config.Garages[gar].spawn.x, Config.Garages[gar].spawn.y, Config.Garages[gar].spawn.z), 2.0) then
            return TriggerEvent("esx:showNotification", "Valaki áll már ott ahova az autót kivennéd!")
        end
    ESX.TriggerServerCallback("villamos_garage:getVehicleOut", function(data)
        if not data or not gar or not Config.Garages[gar] then 
            return 
        end 
        data.vehicle = json.decode(data.vehicle)
        if not data.vehicle then 
            return 
        end 
        

        local model = data.vehicle.model
        if not IsModelInCdimage(model) then 
            TriggerEvent("esx:showNotification", "Ez az autó valószínűleg nincs bent a szerveren!")
            return print("^1SCRIPT ERROR: Invalid model: "..model)
        end 
        while not HasModelLoaded(model) do 
            RequestModel(model)
            Wait(10)
        end 
        local vehicle = CreateVehicle(model, GetAvailableVehicleSpawnPoint(Config.Garages[gar].spawn), true, true)
        -- bc_kocsitorles: legalis spawn jelolese
        if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
        SetVehicleNumberPlateText(vehicle, data.plate)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetVehicleData(vehicle, data.vehicle)
        CreateTracker(data.plate)
        SetModelAsNoLongerNeeded(model)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetEntityAsMissionEntity(vehicle, true)
        SetVehRadioStation(vehicle, 'OFF')
        StartTakeoutCooldown()
        TriggerServerEvent("bc:vehOut", GetDisplayNameFromVehicleModel(model))
        exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_garage:outV", NetworkGetNetworkIdFromEntity(vehicle), data.plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
    end, plate)
    cb('ok')
end)

function HaveAccessToGarage(i)
    if not Config.Garages[i] then 
        return false  
    end 
    if not Config.Garages[i].job then 
        return true  
    end 
    if Config.Garages[i].job ~= ESX.PlayerData.job.name then 
        return false 
    end 
    if not Config.Garages[i].minrank then 
        return true 
    end 
    if Config.Garages[i].minrank > ESX.PlayerData.job.grade then 
        return false 
    end 
    return true 
end 

function OpenGarage(i)
    if not Config.Garages[i] then return end 
    if exports["TakeHostage"]:isActive() then 
        return 
    end 
    ESX.TriggerServerCallback("villamos_garage:getVehicles", function(vehicles)
        local nuiVehicles = {}
        local missingModels = {} -- Batch missing model reports

        for _, v in pairs(vehicles) do
            v.vehicle = json.decode(v.vehicle) or {}
            local rare = ""
            if VEHICLESRARE and VEHICLESRARE[v.vehicle.model] then
                rare = "("..VEHICLESRARE[v.vehicle.model]..")"
            end

            nuiVehicles[#nuiVehicles+1] = {
                stored = v.stored,
                plate = v.plate or "Ismeretlen",
                fav = v.fav or false,
                label = (v.fav and "⭐" or "")..(v.label and v.label or (vehicleimgs[v.vehicle.model] and vehicleimgs[v.vehicle.model].name or GetDisplayNameFromVehicleModel(v.vehicle.model)))..rare,
                model = GetDisplayNameFromVehicleModel(v.vehicle.model),
                img = (vehicleimgs[v.vehicle.model] and vehicleimgs[v.vehicle.model].img or Config.UNKpng),
                bodyHealth = v.vehicle.bodyHealth or 1000,
                engineHealth = v.vehicle.engineHealth or 1000,
                tankHealth = v.vehicle.tankHealth or 1000,
                fuelLevel = v.vehicle.fuelLevel or -1,
                modEngine = v.vehicle.modEngine or 0,
                modBrakes = v.vehicle.modBrakes or 0,
                modTransmission = v.vehicle.modTransmission or 0,
                modTurbo = v.vehicle.modTurbo or false
            }
            if not vehicleimgs[v.vehicle.model] then
                missingModels[#missingModels+1] = v.vehicle.model
            end
        end

        -- Single netevent for all missing models instead of one per model
        if #missingModels > 0 then
            TriggerServerEvent("villamos_garage:reportVehicleImageBatch", missingModels)
        end

        SetNuiFocus(true, true)
        lastGarage = i
        SendNUIMessage({
            type = "show",
            enable = true,
            cars = nuiVehicles,
            label = Config.Garages[lastGarage].label
        })
    end, Config.Garages[i].type, Config.Garages[i].job)
end 

RegisterNetEvent("villamos_garage:setVehicleImages", function(data)
    for k=1, #data, 1 do
        if type(data[k].model) ~= "number" then 
            data[k].model = GetHashKey(data[k].model)
        end 
        vehicleimgs[data[k].model] = { img = data[k].image, name = data[k].name or false }
    end 
end)

local spawnedProps = {}
local garageBlips = {}

local function RefreshGarages()
    for k, blip in pairs(garageBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    garageBlips = {}

    for k, v in pairs(Config.Garages) do
        if v and v.blip then
            local blip = AddBlipForCoord(v.coords)
            SetBlipSprite(blip, v.blip.sprite)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, v.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.blip.label)
            EndTextCommandSetBlipName(blip)
            garageBlips[k] = blip
        end
    end
end

RegisterNetEvent("villamos_garage:updateGarages", function(data) 
    Config.Garages = data
    RefreshGarages()
end)

RegisterNetEvent("bc_garage:housing", function(data) 
    Config.Garages["housing"] = data
    RefreshGarages()
end)

local isinzone = false 
exports("isinzone", function()
    return isinzone
end)

local function GetGarageFromProp(entity)
    for k, prop in pairs(spawnedProps) do
        if prop == entity then
            return k
        end
    end
    return nil
end

local function amIAdmin()
    if not ESX or not ESX.PlayerData then return false end
    local g = LocalPlayer.state.group
    if not g or not Config.AdminGroups then return false end
    for _, allowed in ipairs(Config.AdminGroups) do
        if g == allowed then return true end
    end
    return false
end

-- Prop placement mode: spawns a preview prop that follows the player.
-- onConfirm(pos, heading) is called when the admin presses E to confirm.
-- Press Backspace to cancel.
local function StartPropPlacement(onConfirm)
    CreateThread(function()
        local model = `prop_park_ticket_01`
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local previewProp = CreateObject(model, pos.x, pos.y, pos.z, false, false, false)
        SetEntityHeading(previewProp, 0.0)
        SetEntityAlpha(previewProp, 180, false)
        SetEntityInvincible(previewProp, true)
        SetBlockingOfNonTemporaryEvents(previewProp, true)
        SetModelAsNoLongerNeeded(model)

        AddTextEntry('bc_garage_place_hint', '~INPUT_PICKUP~ Elhelyezés    ~INPUT_CELLPHONE_CANCEL~ Mégse')

        while true do
            Wait(0)
            ped = PlayerPedId()
            pos = GetEntityCoords(ped)
            -- Keep the preview prop 0.3 units in front of the player so it's visible
            local fwd = GetEntityForwardVector(ped)
            local propPos = vector3(pos.x + fwd.x * 0.7, pos.y + fwd.y * 0.7, pos.z - 0.9)
            SetEntityCoords(previewProp, propPos.x, propPos.y, propPos.z, false, false, false, false)
            SetEntityHeading(previewProp, GetEntityHeading(ped))
            SetEntityNoCollisionEntity(previewProp, ped, true)
            FreezeEntityPosition(previewProp, true)

            DisplayHelpTextThisFrame('bc_garage_place_hint')

            -- E (INPUT_PICKUP = 38) to confirm
            if IsControlJustReleased(0, 38) then
                local finalPos = GetEntityCoords(previewProp)
                local finalH   = GetEntityHeading(previewProp)
                DeleteObject(previewProp)
                onConfirm(finalPos, finalH)
                break
            end

            -- Backspace (INPUT_CELLPHONE_CANCEL = 177) to cancel
            if IsControlJustReleased(0, 177) then
                DeleteObject(previewProp)
                TriggerEvent("esx:showNotification", "Prop elhelyezés megszakítva.")
                break
            end
        end
    end)
end

local garageAdminFilter = ""

local function buildGarageAdminRootOptions()
    local filterLower = garageAdminFilter:lower()
    local options = {
        -- "Új garázs" action
        {
            title = "Új garázs hozzáadása",
            description = "Elhelyezési mód: sétálj oda ahol legyen a prop, majd nyomj E-t.",
            icon = "plus",
            onSelect = function()
                if not amIAdmin() then return end
                local input = lib.inputDialog('Új garázs', {'Garázs neve'})
                if not input or not input[1] or input[1] == "" then return end
                local garageName = input[1]
                StartPropPlacement(function(pos, h)
                    TriggerServerEvent("bc_garage:adminAddGarage", garageName, pos, pos,
                        vector4(pos.x, pos.y, pos.z, h), false, h)
                end)
            end
        },
        -- Search button
        {
            title = garageAdminFilter == "" and "🔍 Keresés..." or ("🔍 Szűrő: '" .. garageAdminFilter .. "'"),
            description = garageAdminFilter == "" and "Kattints a garázs neve vagy ID-ja alapján való szűréshez."
                                                    or "Kattints az új szűrőhöz.",
            icon = "search",
            onSelect = function()
                if not amIAdmin() then return end
                local input = lib.inputDialog('Garázs keresés', {
                    {type = 'input', label = 'Névre vagy ID-re szűrés', default = garageAdminFilter}
                })
                if input then
                    garageAdminFilter = input[1] or ""
                end
                OpenGarageAdminRoot()
            end
        },
    }

    -- Clear-filter button (only shown when a filter is active)
    if garageAdminFilter ~= "" then
        options[#options+1] = {
            title = "✖ Szűrő törlése",
            description = "Összes garázs megjelenítése.",
            icon = "times",
            onSelect = function()
                garageAdminFilter = ""
                OpenGarageAdminRoot()
            end
        }
    end

    -- Garage list, filtered
    local matchCount = 0
    for k, v in ipairs(Config.Garages) do
        if v then
            local shortId = (type(v.id) == "string" and #v.id >= 8) and v.id:sub(1, 8) or tostring(k)
            local labelLower = (v.label or ""):lower()
            local idLower    = (v.id or ""):lower()

            if filterLower == ""
                or labelLower:find(filterLower, 1, true)
                or idLower:find(filterLower, 1, true) then

                matchCount = matchCount + 1
                options[#options+1] = {
                    title = string.format("#%s %s", shortId, v.label or "(névtelen)"),
                    description = string.format("%s | x=%.2f y=%.2f z=%.2f",
                        tostring(v.type or "?"), v.coords.x, v.coords.y, v.coords.z),
                    icon = "warehouse",
                    onSelect = function() OpenGarageAdminSub(v) end
                }
            end
        end
    end

    -- No results feedback
    if filterLower ~= "" and matchCount == 0 then
        options[#options+1] = {
            title = "Nincs találat: '" .. garageAdminFilter .. "'",
            description = "Próbálj más szűrőt.",
            icon = "exclamation-circle",
            disabled = true
        }
    end

    return options
end

function OpenGarageAdminRoot()
    if not amIAdmin() then
        TriggerEvent("esx:showNotification", "Nincs ehhez jogod!")
        return
    end
    lib.registerContext({
        id = 'garageadmin_root',
        title = 'Garázs admin',
        options = buildGarageAdminRootOptions(),
    })
    lib.showContext('garageadmin_root')
end

function OpenGarageAdminSub(garageObj)
    local v = garageObj
    if not v or type(v.id) ~= "string" or v.id == "" then return end
    local id = v.id
    local shortId = id:sub(1, 8)
    local subid = 'garageadmin_sub_' .. id
    local blipLabel
    if v.blip then
        blipLabel = string.format("Blip: %d/%d '%s'",
            v.blip.sprite or 0, v.blip.color or 0, v.blip.label or "")
    else
        blipLabel = "Blip: kikapcsolva"
    end
    local options = {
        {title = "Prop ide áthelyezése", description = "Elhelyezési mód: sétálj oda ahol legyen a prop, majd nyomj E-t.",
         icon = "arrow-right",
         onSelect = function()
            if not amIAdmin() then return end
            StartPropPlacement(function(pos, h)
                TriggerServerEvent("bc_garage:adminUpdateGarage", id, "coords", pos)
                TriggerServerEvent("bc_garage:adminUpdateGarage", id, "propHeading", h)
            end)
         end},
        {title = "Prop forgatás (heading)", description = string.format("Jelenlegi: %.1f°", v.propHeading or 0.0),
         icon = "rotate",
         onSelect = function()
            if not amIAdmin() then return end
            local input = lib.inputDialog('Prop heading', {
                {type = 'number', label = 'Heading (0-360)', default = v.propHeading or 0.0}
            })
            if not input or input[1] == nil then return end
            TriggerServerEvent("bc_garage:adminUpdateGarage", id, "propHeading", tonumber(input[1]) or 0.0)
         end},
        {title = "Store marker ide", description = "Járműleadó marker áthelyezése.", icon = "warehouse",
         onSelect = function()
            if not amIAdmin() then return end
            local ped = PlayerPedId()
            TriggerServerEvent("bc_garage:adminUpdateGarage", id, "store", GetEntityCoords(ped))
         end},
        {title = "Spawn marker ide (heading = facing)", icon = "car",
         onSelect = function()
            if not amIAdmin() then return end
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local h = GetEntityHeading(ped)
            TriggerServerEvent("bc_garage:adminUpdateGarage", id, "spawn",
                vector4(pos.x, pos.y, pos.z, h))
         end},
        {title = "Név átírása", icon = "tag",
         onSelect = function()
            if not amIAdmin() then return end
            local input = lib.inputDialog('Garázs neve', {'Név'}, {v.label or ''})
            if not input or not input[1] or input[1] == "" then return end
            TriggerServerEvent("bc_garage:adminUpdateGarage", id, "label", input[1])
         end},
        {title = "Típus: " .. tostring(v.type or "?"),
         description = "Kattints a ciklikus váltáshoz: car > boat > helicopter", icon = "cog",
         onSelect = function()
            if not amIAdmin() then return end
            local newtype = v.type == "car" and "boat" or
                            v.type == "boat" and "helicopter" or "car"
            TriggerServerEvent("bc_garage:adminUpdateGarage", id, "type", newtype)
         end},
        {title = blipLabel, icon = "map-marker-alt",
         onSelect = function()
            if not amIAdmin() then return end
            local cur = v.blip or {}
            local input = lib.inputDialog('Blip szerkesztése', {
                {type = 'number', label = 'Sprite', default = cur.sprite or 289},
                {type = 'number', label = 'Color', default = cur.color or 26},
                {type = 'input',  label = 'Label', default = cur.label or (v.label or '')},
            })
            if not input or not input[1] or not input[2] or not input[3] then return end
            TriggerServerEvent("bc_garage:adminUpdateGarage", id, "blip", {
                sprite = tonumber(input[1]),
                color = tonumber(input[2]),
                label = input[3]
            })
         end},
        {title = "Blip kikapcsolása", icon = "eye-slash",
         onSelect = function()
            if not amIAdmin() then return end
            if v.blip then
                TriggerServerEvent("bc_garage:adminUpdateGarage", id, "blip", false)
            end
         end},
        {title = "Törlés", icon = "trash",
         onSelect = function()
            if not amIAdmin() then return end
            local alert = lib.alertDialog({
                header = 'Garázs törlése',
                content = 'Biztosan törlöd a(z) ' ..
                    (v.label or ('#' .. shortId)) .. ' garázst? Minden beállítás elveszik!',
                centered = true, cancel = true,
            })
            if alert == "confirm" then
                TriggerServerEvent("bc_garage:adminRemoveGarage", id)
            end
         end},
        {title = "Vissza", icon = "arrow-left",
         onSelect = function() OpenGarageAdminRoot() end}
    }
    lib.registerContext({
        id = subid,
        title = '#' .. shortId .. ' - ' .. (v.label or '?'),
        options = options,
    })
    lib.showContext(subid)
end

RegisterCommand("garazsadmin", function()
    OpenGarageAdminRoot()
end, false)

RegisterNetEvent("bc_garage:adminRefresh", function()
    -- Re-open root menu with fresh data after server processed an action
    OpenGarageAdminRoot()
end)

CreateThread(function()
    while not ESX or not ESX.PlayerLoaded do 
        Wait(500)
    end

    exports.ox_target:addModel('prop_park_ticket_01', {
        {
            icon = "fas fa-door-open",
            label = "Belépés a garázsba",
            canInteract = function(entity, distance, coords, name, bone)
                if IsPedInAnyVehicle(PlayerPedId(), false) then return false end
                local closestGarage = GetGarageFromProp(entity)
                if closestGarage then
                    local g = Config.Garages[closestGarage]
                    if not (g.job or g.type ~= "car") then
                        return HaveAccessToGarage(closestGarage)
                    end
                end
                return false
            end,
            onSelect = function(data)
                local closestGarage = GetGarageFromProp(data.entity)
                if closestGarage then
                    OpenInteriorGarage(closestGarage)
                end
            end
        },
        {
            icon = "fas fa-warehouse",
            label = "Garázs panel",
            canInteract = function(entity, distance, coords, name, bone)
                if IsPedInAnyVehicle(PlayerPedId(), false) then return false end
                local closestGarage = GetGarageFromProp(entity)
                if closestGarage then
                    return HaveAccessToGarage(closestGarage)
                end
                return false
            end,
            onSelect = function(data)
                local closestGarage = GetGarageFromProp(data.entity)
                if closestGarage then
                    OpenGarage(closestGarage)
                end
            end
        },
        {
            icon = "fas fa-key",
            label = "Kulcsok kezelése",
            canInteract = function(entity, distance, coords, name, bone)
                if IsPedInAnyVehicle(PlayerPedId(), false) then return false end
                local closestGarage = GetGarageFromProp(entity)
                if closestGarage then
                    return HaveAccessToGarage(closestGarage)
                end
                return false
            end,
            onSelect = function(data)
                exports["bc_keysystem"]:OpenKeyManagement()
            end
        },
        {
            icon = "fas fa-cog",
            label = "Admin szerkesztés",
            canInteract = function(entity, distance, coords, name, bone)
                if not amIAdmin() then return false end
                return GetGarageFromProp(entity) ~= nil
            end,
            onSelect = function(data)
                local closestGarage = GetGarageFromProp(data.entity)
                if closestGarage and Config.Garages[closestGarage] then
                    OpenGarageAdminSub(Config.Garages[closestGarage])
                end
            end
        }
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, prop in pairs(spawnedProps) do
            if DoesEntityExist(prop) then
                DeleteObject(prop)
            end
        end
    end
end)

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do 
        Wait(10)
    end 

    local jsonimgs = json.decode(LoadResourceFile(GetCurrentResourceName(), "config/vehicleimgs.json"))
    for k=1, #jsonimgs, 1 do
        if type(jsonimgs[k].model) ~= "number" then 
            jsonimgs[k].model = GetHashKey(jsonimgs[k].model)
        end 
        vehicleimgs[jsonimgs[k].model] = { img = jsonimgs[k].img, name = jsonimgs[k].name or false }
    end 
    ESX.TriggerServerCallback("villamos_garage:getVehicleImages", function(data) 
        for k=1, #data, 1 do
            if type(data[k].model) ~= "number" then 
                data[k].model = GetHashKey(data[k].model)
            end 
            vehicleimgs[data[k].model] = { img = data[k].image, name = data[k].name or false }
        end 
    end)

    ESX.TriggerServerCallback("villamos_garage:getGarages", function(data) 
        Config.Garages = data
        RefreshGarages()
    end)

    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local nearGarage = false
        
        -- Clean up spawned props for garages that were deleted or moved
        for k, prop in pairs(spawnedProps) do
            if not Config.Garages[k] then
                if DoesEntityExist(prop) then
                    DeleteObject(prop)
                end
                spawnedProps[k] = nil
            elseif prop and DoesEntityExist(prop) then
                local g = Config.Garages[k]
                if g and g.coords and #(GetEntityCoords(prop) - g.coords) > 0.5 then
                    DeleteObject(prop)
                    spawnedProps[k] = nil
                elseif g then
                    -- Keep heading synced with config (e.g. after admin edit)
                    SetEntityHeading(prop, g.propHeading or 0.0)
                end
            end
        end

        if not lastGarage then 
            for k, v in pairs(Config.Garages) do
                if v then 
                    local dis = #(coords - v.coords)
                    if HaveAccessToGarage(k) then
                        if dis < 6.5 and not IsPedInAnyVehicle(ped, false) then
                            nearGarage = true
                        end

                        if dis < 50.0 then
                            if not spawnedProps[k] then
                                local model = `prop_park_ticket_01`
                                RequestModel(model)
                                while not HasModelLoaded(model) do
                                    Wait(0)
                                end
                                local obj = CreateObject(model, v.coords.x, v.coords.y, v.coords.z, false, false, false)
                                SetEntityHeading(obj, v.propHeading or 0.0)
                                FreezeEntityPosition(obj, true)
                                SetEntityInvincible(obj, true)
                                SetBlockingOfNonTemporaryEvents(obj, true)
                                SetModelAsNoLongerNeeded(model)
                                PlaceObjectOnGroundProperly(obj)
                                spawnedProps[k] = obj
                            end
                        else
                            if spawnedProps[k] then
                                if DoesEntityExist(spawnedProps[k]) then
                                    DeleteObject(spawnedProps[k])
                                end
                                spawnedProps[k] = nil
                            end
                        end
                    end 
                end 
            end 
        end 

        isinzone = nearGarage
        Wait(1000)
    end
end)

function StoreVehicle(garageid)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle or not DoesEntityExist(vehicle) then return false end 
    if GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return false end 
    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
    local vehicledata = GetVehicleData(vehicle)
    local ret = 3000

    if Entity(vehicle) and Entity(vehicle).state then 
        local deployedLightNetId = Entity(vehicle).state.deployedLightNetId or false
        if deployedLightNetId then 
            TriggerEvent("esx:showNotification", "Elsőnek vedd le a szirénát az autóról")
            return 
        end 
    end 

    if not NetworkGetEntityIsNetworked(vehicle) then 
        ESX.TriggerServerCallback("villamos_garage:storeVehicle", function(success) 
            if not success then 
                ret = false 
                return 
            end 
            ret = true 
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
            TriggerEvent("interact:sound")
        end, garageid, plate, vehicledata, false)
    else 
        local nid = NetworkGetNetworkIdFromEntity(vehicle)
        ESX.TriggerServerCallback("villamos_garage:storeVehicle", function(success) 
            if not success then 
                ret = false 
                return 
            end 
            ret = true 
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
            TriggerEvent("interact:sound")
        end, garageid, plate, vehicledata, nid)
    end 
    --Wait(1000)
    --SetEntityAsMissionEntity(vehicle, true, true)
    --DeleteVehicle(vehicle)
    while type(ret) == "number" and ret > 0 do 
        ret = ret - 100
        Wait(100)
    end 
    if type(ret) == "number" then 
        ret = false 
    end 
    return ret 
end 

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do 
        Wait(10)
    end 
    AddTextEntry('garage_store_msg', '~INPUT_PICKUP~ a jármuved eltárolásához')
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local sleep = 1000

        if not lastGarage and IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped then 
            --for k=1, #Config.Garages, 1 do
            for k, v in pairs(Config.Garages) do
                if Config.Garages[k] then 
                    local dis = #(coords - Config.Garages[k].store)
                    if HaveAccessToGarage(k) and dis < 50 then 
                        sleep = 2
                        if Config.Garages[k].type == "boat" then 
                            DrawMarker(6, Config.Garages[k].store+vector3(0.0,0.0,-0.6), 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 12.0, 12.0, 12.0,  181, 24, 13, 100, false, true, 2, false, false, false, false)
                        else 
                            DrawMarker(6, Config.Garages[k].store+vector3(0.0,0.0,-0.6), 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 6.0, 6.0, 6.0,  181, 24, 13, 100, false, true, 2, false, false, false, false)
                        end 
                        DrawMarker(21, Config.Garages[k].store, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 181, 24, 13, 100, false, true, 2, false, false, false, false)
                        if dis < 6.0 then 
                            DisplayHelpTextThisFrame('garage_store_msg')
                            if IsControlJustReleased(0, 38) then
                                StoreVehicle(k)
                            end  
                        elseif Config.Garages[k].type == "boat" and dis < 12.0 then 
                            DisplayHelpTextThisFrame('garage_store_msg')
                            if IsControlJustReleased(0, 38) then
                                StoreVehicle(k)
                            end  
                        end 
                    end 
                end 
            end 
        end 

        Wait(sleep)
    end
end)

function OpenImpound(k)
    ESX.TriggerServerCallback("villamos_garage:getImpounds", function(vehicles) 
        if not vehicles then 
            return 
        end 
        local elements = {
            {unselectable = true, title = "Lefoglaltak ("..Config.Impounds[k].label..") a kiváltás ára "..Config.Impounds[k].price.."$ (fizetés csak készpénzben, ha nincs nálad elég akkor bankkártyával)"}
        }
        for i=1, #vehicles do 
            local veh = vehicles[i]
            veh.vehicle = json.decode(veh.vehicle) or {}
            local isjobveh = ""
            if veh.job and veh.job ~= "civ" then 
                isjobveh = " (Frakció)"
            end 
            elements[#elements+1] = {
                icon = "fas fa-car",
                title = (vehicleimgs[veh.vehicle.model] and vehicleimgs[veh.vehicle.model].name or GetDisplayNameFromVehicleModel(veh.vehicle.model)) .. " | " .. veh.plate .. isjobveh,
                value = veh.plate
            }
        end 

        ESX.OpenContext("right", elements, function(menu,element)
            ESX.CloseContext()

            local cdleft = GetTakeoutCooldownLeft()
            if cdleft > 0 then
                return TriggerEvent("esx:showNotification", "Még "..cdleft.." másodpercet várnod kell a következő autó kivételéig!")
            end

            local data = {current = element}
            ESX.TriggerServerCallback("villamos_garage:getOutImpound", function(data)
                if not data then 
                    return 
                end 
                data.vehicle = json.decode(data.vehicle)
                if not data.vehicle then 
                    return 
                end 
                local model = data.vehicle.model
                if not IsModelInCdimage(model) then 
                    TriggerEvent("esx:showNotification", "Ez az autó valószínűleg nincs bent a szerveren!")
                    return print("^1SCRIPT ERROR: Invalid model: "..model)
                end 
                while not HasModelLoaded(model) do 
                    RequestModel(model)
                    Wait(10)
                end 
                local vehicle = CreateVehicle(model, Config.Impounds[k].spawn, true, true)
                -- bc_kocsitorles: legalis spawn jelolese
                if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
                SetVehicleNumberPlateText(vehicle, data.plate)
                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                SetVehicleData(vehicle, data.vehicle)
                CreateTracker(data.plate)
                SetModelAsNoLongerNeeded(model)
                SetVehRadioStation(vehicle, 'OFF')
                StartTakeoutCooldown()
                TriggerServerEvent("bc:vehOut", GetDisplayNameFromVehicleModel(model))
                exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_garage:outV", NetworkGetNetworkIdFromEntity(vehicle), data.plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
            end, k, data.current.value)
        end)
    end, Config.Impounds[k].type)
end 

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do 
        Wait(10)
    end 

    for k=1, #Config.Impounds, 1 do
        if Config.Impounds[k].blip then 
            local blip = AddBlipForCoord(Config.Impounds[k].coords)
            SetBlipSprite(blip, Config.Impounds[k].blip.sprite)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, Config.Impounds[k].blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.Impounds[k].blip.label)
            EndTextCommandSetBlipName(blip)
        end
    end
    
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local sleep = 1000

        for k=1, #Config.Impounds, 1 do
            local dis = #(coords - Config.Impounds[k].coords)
            if dis < 20 then 
                sleep = 2
                --DrawMarker(6, Config.Impounds[k].coords+vector3(0.0,0.0,-0.6), 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 2.0, 2.0, 2.0, 181, 24, 13, 100, false, true, 2, false, false, false, false)
                DrawMarker(21, Config.Impounds[k].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 181, 24, 13, 100, false, true, 2, false, false, false, false)
                if dis < 2.0 then 
                    AddTextEntry('garage_impound_msg', '~INPUT_PICKUP~ a lefoglaltak ('..Config.Impounds[k].label..") megnyitásához")
                    DisplayHelpTextThisFrame('garage_impound_msg')
                    if IsControlJustReleased(0, 38) then
                        OpenImpound(k)
                    end  
                end 
            end 
        end 

        Wait(sleep)
    end
end)

RegisterNetEvent("villamos_garage:takePhotos", function(shop, webhook, cars) 
    DisplayHud(false)
    DisplayRadar(false)
    FreezeEntityPosition(PlayerPedId(), true)

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, Config.Photos.showroomcam)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)

    local taked = {}

    for i=1, #cars, 1 do 
        local model = cars[i]
        local hash = model
        if type(model) ~= "number" then 
            hash = GetHashKey(model)
        end 
        if IsModelInCdimage(hash) and IsModelValid(hash) then 
            if not HasModelLoaded(hash) then
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Wait(0)
                end
            end

            local vehicle = CreateVehicle(hash, Config.Photos.showroom, false, true)
            -- bc_kocsitorles: legalis spawn jelolese
            if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
            if vehicle and vehicle ~= 0 then TriggerEvent("bc:localVehSpawn", vehicle) end
            SetModelAsNoLongerNeeded(hash)
            FreezeEntityPosition(vehicle, true)
            PointCamAtEntity(cam, vehicle, 0.0, 0.0, 0.0, true)
            SetFocusEntity(vehicle)

            local vehname = GetDisplayNameFromVehicleModel(hash)
            if GetLabelText(vehname) ~= "NULL" then 
                vehname = GetLabelText(vehname)
            end     

            local p = promise.new()
            Wait(500)

            exports['screenshot-basic']:requestScreenshotUpload(webhook, "files[]", function(data)
                if not data then 
                    print("^1SCRIPT ERROR: Error while uploadin image to discord")
                    return p:resolve(false)
                end 
                local resp = json.decode(data)
                if not resp or not resp.url then 
                    print("^1SCRIPT ERROR: Error while uploadin image to discord")
                    return p:resolve(false)
                end 
                local img = resp.url
                if not img then 
                    print("^1SCRIPT ERROR: Error while uploadin image to discord")
                    return p:resolve(false)
                end 
                p:resolve(img)
            end)

            local image = Citizen.Await(p)
            if image then 
                taked[#taked+1] = {model = hash, img = image, name = vehname}
            end 
            DeleteEntity(vehicle)
            SetModelAsNoLongerNeeded(hash)
        else 
            print("^1SCRIPT ERROR: Invalid model: "..model)
        end 
    end 

    Wait(2000)

    ClearFocus()
    DisplayHud(true)
    DisplayRadar(true)
    FreezeEntityPosition(PlayerPedId(), false)
    RenderScriptCams(false)
    DestroyCam(cam, true)
    SetCamActive(cam, false)
    TriggerServerEvent("villamos_garage:savePhotos", taked)
end)

function callScaleformMethod(scaleform, method, ...)
    BeginScaleformMovieMethod(scaleform, method)
    for _, v in ipairs { ... } do
        local valueType  = type(v)
        if valueType == 'string' then
            PushScaleformMovieMethodParameterString(v)
        elseif valueType == 'number' then
            (string.find(tostring(v), "%.") and PushScaleformMovieFunctionParameterFloat or PushScaleformMovieFunctionParameterInt)(v)
        elseif valueType == 'boolean' then
            PushScaleformMovieMethodParameterBool(v)
        end
    end
    EndScaleformMovieMethod()
end


local lastinterior = nil
local lastilevel = 0

local spawnedcars = {}
local platetofslots = {}

exports("lastinterior", function()
    return lastinterior
end)

Citizen.CreateThread(function()

	while true do
		local wea = exports.ox_inventory:getCurrentWeapon()
		if wea and wea.name == "WEAPON_STUNGUN" and lastinterior then 
			TriggerEvent("ox_inventory:disarm")
			TriggerEvent("esx:showNotification", "Ezt a fegyvert itt nem használhatod!")
		end 

		Wait(3000)
	end
end)

exports("isInInterior", function()
    return lastinterior
end)

--- Kilepes a szerveroldali instance-bol (routing bucket vissza az eredetire).
--- Idempotens: minden kilepesi agrol nyugodtan hivhato, a masodik hivas mar nem csinal semmit.
--- FONTOS: a kivett jarmuvet CSAK ezutan szabad letrehozni, kulonben a halozati entitas
--- a garazs bucketjeben szuletne meg, es a jatekos egy senki masnak nem letezo autoban ulne.
function LeaveInteriorInstance()
    local ok = pcall(function()
        return lib.callback.await('bc_garage:leaveInterior', false)
    end)
    if not ok then
        -- ha a callback barmiert elszall, a regi uton is szoljunk a szervernek
        TriggerServerEvent("bc_garage:saveInteriorData")
    end
end

--- A szerver kenyszeriti a kilepest: tul messze kerult az interiortol, letelt a bent tolthető
--- ido, vagy ujraindult a resource. A lathatosag visszaallitasa akkor is lefut, ha a kliens
--- mar nem tud a garazsrol -- a regi (bucket nelkuli) verzio ott hagyhatta lathatatlanul a pedet.
RegisterNetEvent("bc_garage:forceLeaveInterior", function(garageId, reason)
    SetEntityVisible(PlayerPedId(), true)
    SetLocalPlayerVisibleLocally(true)

    if not lastinterior then
        return
    end

    DoScreenFadeOut(500)
    Wait(500)
    DeleteSpawnedCars()

    local g = Config.Garages[garageId or lastinterior]
    if g and g.coords then
        SetEntityCoords(PlayerPedId(), g.coords)
    end
    SetEntityVisible(PlayerPedId(), true)
    SetLocalPlayerVisibleLocally(true)
    lastilevel = 1
    lastinterior = nil
    DoScreenFadeIn(500)

    if reason == "time" then
        TriggerEvent("esx:showNotification", "Lejárt a garázsban tölthető idő, kiléptettünk.")
    elseif reason == "far" then
        TriggerEvent("esx:showNotification", "Kikerültél a garázs területéről, visszahoztunk a bejárathoz.")
    end
end)

function OpenInteriorGarage(k)
    if lastinterior then
        return
    end
    if exports["TakeHostage"]:isActive() then
        return
    end
    if ESX.PlayerData.dead then return end

    -- A szerver donti el, melyik interiorba kerulunk (farm/varos is nala dol el), es itt
    -- kerulunk a sajat routing bucketunkbe. false = nem lephetunk be (pl. nem a garazsnal allunk).
    local igarage = lib.callback.await('bc_garage:enterInterior', false, k)
    if not igarage or not Config.InteriorGarages[igarage] then
        TriggerEvent("esx:showNotification", "Most nem tudsz belépni a garázsba.")
        return
    end

    local interiordata = Config.InteriorGarages[igarage]
    interiordata.id = igarage

    lastinterior = k
    lastilevel = 1

    -- Instance-ben vagyunk, tehat NEM rejtjuk el a pedet: a regi SetEntityVisible-hack miatt
    -- alltak lathatatlanul egymas mellett a jatekosok ugyanabban a szobaban (lelohetoen),
    -- es ott ragadt a lathatatlansag, ha a szal meghalt.
    SetEntityVisible(PlayerPedId(), true)
    SetLocalPlayerVisibleLocally(true)
    SetPlayerInvincible(PlayerId(), true)

    SetInteriorLevel(lastilevel, interiordata)
    TriggerEvent("bc:enteredgar")

    CreateThread(function()
        Wait(5000)
        while lastinterior do
            Wait(1)
            local coords = GetEntityCoords(PlayerPedId())

            if #(coords - interiordata.coords) > 250 then 
                lastilevel = 1
                lastinterior = nil
            end 
            DrawMarker(2, interiordata.coords+interiordata.menuoffset, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 0, 155, 20, 100, false, true, 2, false, false, false, false)
            if #(coords - (interiordata.coords+interiordata.menuoffset)) < 2.0 then 
                AddTextEntry('garage_interior_msg', '~INPUT_PICKUP~ a garázs panel megnyitásához')
                DisplayHelpTextThisFrame('garage_interior_msg')
                if IsControlJustReleased(0, 38) then
                    OpenInteriorMenu(interiordata)
                end  
            end
            if IsPedInAnyVehicle(PlayerPedId()) then 
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                local plate = ESX.Math.Trim(GetVehicleNumberPlateText(veh))
                
                while not HasStreamedTextureDictLoaded("bcbc") do 
                    RequestStreamedTextureDict("bcbc", false)
                    Wait(100)
                end 

                local vehstats = {
                    MaxSpeed        = GetVehicleEstimatedMaxSpeed(veh) * 2.236936 / 1.2,
					MaxAcceleration = GetVehicleAcceleration(veh) * 200,
					MaxBreaking     = GetVehicleMaxBraking(veh) * 50, -- Simplified 100 / 2.5 to 50
					Traction        = GetVehicleMaxTraction(veh) * 100 / 3.5,
					Name            = GetDisplayNameFromVehicleModel(GetEntityModel(veh)),
                }

                local scaleform = RequestScaleformMovie("MP_CAR_STATS_01")
                while not HasScaleformMovieLoaded(scaleform) do 
                    Wait(100)
                end 

                while GetVehiclePedIsIn(PlayerPedId(), false) == veh do 
                    local displayCoords  = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, 'windscreen'))
					local camRotation    = GetFinalRenderedCamRot(2)

                    local slottext = "Nincs fix helye"
                    if platetofslots[plate] then 
                        local maxslots = #interiordata.vehslots
                        local s = platetofslots[plate] % maxslots 
                        local l = math.floor((platetofslots[plate]-s)/maxslots)+1
                        slottext = l..". Épület "..s..". Hely"
                    end 

                    callScaleformMethod(scaleform, 'SET_VEHICLE_INFOR_AND_STATS',
                            plate.." - "..vehstats.Name, slottext, "",
							"", "Max sebesség", "Gyorsulás", "Fék", "Traction",
							vehstats.MaxSpeed, vehstats.MaxAcceleration, vehstats.MaxBreaking,
							vehstats.Traction)

					DrawScaleformMovie_3dSolid(scaleform,
						displayCoords.x, displayCoords.y, displayCoords.z + 2.5,
						camRotation.x, 0.0, camRotation.z,
						0.0, 1.0, 0.0,
						6.0, 4.0, 5.0,
						0
					)
                    AddTextEntry('garage_interior_takeout_msg', '~INPUT_PICKUP~ hogy kivedd az autót a garázsból ~INPUT_COVER~ hogy átparkold')
                    DisplayHelpTextThisFrame('garage_interior_takeout_msg')
                    if IsControlJustReleased(0, 38) then
                        --local plate = ESX.Math.Trim(GetVehicleNumberPlateText(veh))
                        local llint = lastinterior
                        local cdleft = GetTakeoutCooldownLeft()
                        if cdleft > 0 then
                            -- Meg a fade/teleport elott, kulonben auto nelkul kerulne ki az utcara.
                            TriggerEvent("esx:showNotification", "Még "..cdleft.." másodpercet várnod kell a következő autó kivételéig!")
                        elseif not ESX.Game.IsSpawnPointClear(vector3(Config.Garages[llint].spawn.x, Config.Garages[llint].spawn.y, Config.Garages[llint].spawn.z), 2.0) then
                            TriggerEvent("esx:showNotification", "Valaki áll már ott ahova az autót kivennéd!")
                        else
                        local outcoords = Config.Garages[lastinterior].coords
                        
                        DoScreenFadeOut(500)
                        Wait(500)
                        DeleteSpawnedCars()
                        SetEntityCoords(PlayerPedId(), outcoords)
                        SetEntityVisible(PlayerPedId(), true)
                        SetLocalPlayerVisibleLocally(true)

                        -- Elobb ki az instance-bol, csak utana szuletjen meg a jarmu:
                        -- a halozati entitas a letrehozo bucketjebe kerul.
                        LeaveInteriorInstance()

                        ESX.TriggerServerCallback("villamos_garage:getVehicleOut", function(data)
                            if not data or not llint or not Config.Garages[llint] then 
                                return 
                            end 
                            data.vehicle = json.decode(data.vehicle)
                            if not data.vehicle then 
                                return 
                            end 
                            local model = data.vehicle.model
                            

                            if not IsModelInCdimage(model) then 
                                return print("^1SCRIPT ERROR: Invalid model: "..model)
                            end 
                            while not HasModelLoaded(model) do 
                                RequestModel(model)
                                Wait(10)
                            end 
                            local vehicle = CreateVehicle(model, GetAvailableVehicleSpawnPoint(Config.Garages[llint].spawn), true, true)
                            -- bc_kocsitorles: legalis spawn jelolese
                            if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
                            SetVehicleNumberPlateText(vehicle, data.plate)
                            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                            SetVehicleData(vehicle, data.vehicle)
                            CreateTracker(data.plate)
                            SetModelAsNoLongerNeeded(model)
                            SetVehRadioStation(vehicle, 'OFF')
                            StartTakeoutCooldown()
                            TriggerServerEvent("bc:vehOut", GetDisplayNameFromVehicleModel(model))
                            exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_garage:outV", NetworkGetNetworkIdFromEntity(vehicle),data.plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                        end, plate)
                        lastilevel = 1
                        lastinterior = nil
                        DoScreenFadeIn(500)
                        end 
                    end 
                    if IsControlJustReleased(0, 44) or IsDisabledControlJustReleased(0, 44) then
                        --local plate = ESX.Math.Trim(GetVehicleNumberPlateText(veh))
                        local input = lib.inputDialog('Átparkolás', {
                            {type = 'number', label = 'Épület', description = 'Hanyas épületbe szeretnéd rakni?', required = true, icon = 'hashtag', min = 1, max = 15},
                            {type = 'number', label = 'Hely', description = 'Hanyas helyre szeretnéd rakni az, a helyek a bejárattól távoldva nőnek, ha egy másik autó van már azon a helyen automatikusan egy szabad helyre áll át?', required = true, icon = 'hashtag', min = 1, max = #interiordata.vehslots},
                        })
                        --if not input then return end
                        --if not input[1] or not input[2] then return end 
                        if input and input[1] and input[2] then
                        local targetslot = ((input[1]-1)*#interiordata.vehslots)+input[2]
                        TriggerServerEvent("villamos_garage:parkInteriorVeh", plate, targetslot)
                        end 
                    end  
                    Wait(1)
                end

                SetScaleformMovieAsNoLongerNeeded(scaleform)
            end
        end
        SetEntityVisible(PlayerPedId(), true)
        SetLocalPlayerVisibleLocally(true)
        SetPlayerInvincible(PlayerId(), false)
        LeaveInteriorInstance()
        TriggerEvent("bc:leftgar")

    end)
end 



function SetInteriorLevel(level, interiordata)
    --DoScreenFadeOut(500)
    RequestCollisionAtCoord(interiordata.coords+interiordata.spawnoffset)
    Wait(1000)
    SetEntityCoords(PlayerPedId(), interiordata.coords+interiordata.spawnoffset)
    if GetResourceState("rota_loading") == "started" then 
        exports["rota_loading"]:LoadingShow(700, "Betöltés a garázsba...")
    end 
    Wait(2000)
    SetEntityCoords(PlayerPedId(), interiordata.coords+interiordata.spawnoffset)
    lastilevel = level
    DeleteSpawnedCars()
    platetofslots = {}
    --print("get")
    ESX.TriggerServerCallback("villamos_garage:getInteriorVehicles", function(vehicles) 
        --print("ret")
        local removeatstart = (lastilevel - 1) * #interiordata.vehslots
        for i=1, #interiordata.vehslots, 1 do 
            local slot = interiordata.vehslots[i]
            local veh = vehicles[removeatstart+i]
            print(i, veh)
            if veh and veh.stored and (veh.stored == true or veh.stored == 1) then 
                print("veh valid")
                veh.vehicle = json.decode(veh.vehicle) or {}
                local model = veh.vehicle.model
                if IsModelInCdimage(model) then 
                    print("veh load started", model)
                    local loadstart = GetGameTimer()
                    while not HasModelLoaded(model) do 
                        if (GetGameTimer() - loadstart) > 4000 then
                            break  
                        end 
                        RequestModel(model)
                        Wait(10)
                    end 
                    if HasModelLoaded(model) then
                    local vehicle = CreateVehicle(model, (interiordata.coords+vector3(slot.x, slot.y, slot.z)), slot.w, false, false)
                    -- bc_kocsitorles: legalis spawn jelolese
                    if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
                    if vehicle and vehicle ~= 0 then TriggerEvent("bc:localVehSpawn", vehicle) end
                    SetVehicleNumberPlateText(vehicle, veh.plate)
                    SetVehicleData(vehicle, veh.vehicle)
                    SetModelAsNoLongerNeeded(model)
                    FreezeEntityPosition(vehicle, true)
                    print("veh spawned", vehicle)
                    if veh.garagespot then 
                        platetofslots[veh.plate] = veh.garagespot
                    end 
                    spawnedcars[#spawnedcars+1] = vehicle
                    end 
                else 
                    print("^1SCRIPT ERROR: Invalid model: "..model)
                end 
            end 
        end
    end)
    if GetResourceState("rota_loading") == "started" then 
        exports["rota_loading"]:LoadingHide(500)
    end 
    --DoScreenFadeIn(500)
end 

function DeleteSpawnedCars()
    for k,v in pairs(spawnedcars) do 
        if DoesEntityExist(v) then 
            DeleteEntity(v)
        end 
    end 
    spawnedcars = {}
end

function IsGarageAFarm(id)
    if not Config.Garages then return false end 
    if not Config.Garages[id] then return false end 
    if Config.Garages[id].job then return false end 
    if #(Config.Garages[id].coords - vector3(755.95104,4820.1538,203.51339)) < 2300 then 
        return true 
    end 
    return false 
end 


function OpenInteriorMenu(interiordata)
    if not lastinterior then return end
    local elements = {
        {unselectable = true, title = "Épület: "..lastilevel},
        {title = "Kilépés", value = "exit"},
        {title = "Következő épület", value = "up"},
        {title = "Előző épület", value = "down"},
        {title = "Kinézet cseréje", value = "change"},
    }

    ESX.OpenContext("right", elements, function(menu,element)
        ESX.CloseContext()
        if not lastinterior then 
            return 
        end
        local data = {current = element}
        if data.current.value == "exit" then 
           -- DoScreenFadeOut(500)
            --Wait(500)
            DeleteSpawnedCars()
            local outcoords = Config.Garages[lastinterior].coords
            local h = math.rad((Config.Garages[lastinterior].propHeading or 0.0))
            SetEntityCoords(PlayerPedId(), outcoords.x + math.sin(h), outcoords.y - math.cos(h), outcoords.z)
            LeaveInteriorInstance()
            if GetResourceState("rota_loading") == "started" then
                exports["rota_loading"]:LoadingShow(700, "Kilépés...")
            end 
            Wait(2000)
            SetEntityVisible(PlayerPedId(), true)
            SetLocalPlayerVisibleLocally(true)
            lastilevel = 1
            lastinterior = nil
           -- DoScreenFadeIn(500)
            if GetResourceState("rota_loading") == "started" then 
                exports["rota_loading"]:LoadingHide(500)
            end
            return 
        elseif data.current.value == "up" then 
            --if lastilevel >= 9 then 
            --    return ESX.ShowNotification("Ez az utolsó épület")
            --end 
            SetInteriorLevel(lastilevel+1, interiordata)
        elseif data.current.value == "down" then
            if lastilevel <= 1 then 
                return ESX.ShowNotification("Ez az első épület")
            end 
            SetInteriorLevel(lastilevel-1, interiordata)
        elseif data.current.value == "change" then
            local options = {}
            local farm = IsGarageAFarm(lastinterior)

            for k, v in pairs(Config.InteriorGarages) do 
                if k == "base" and farm then 
                    goto cont
                end 
                if k == "base_farm" and not farm then 
                    goto cont
                end 
                options[#options+1] = {
                    title = v.label..(k == interiordata.id and " - Jelenlegi" or ""), 
                    image = v.img, 
                    onSelect = function()
                        if k == interiordata.id then 
                            return 
                        end 
                        local alert = lib.alertDialog({
                            header = 'Garázs kinézet',
                            content = 'Lecseréled a garázsod kinézetét '..Config.ChangePrice..'$ ért?',
                            centered = true,
                            cancel = true
                        })
                        if alert ~= "confirm" then 
                            return 
                        end 
                        TriggerServerEvent("bc_garage:changeInterior", k)

                        DoScreenFadeOut(500)
                        Wait(500)
                        DeleteSpawnedCars()
                        local outcoords = Config.Garages[lastinterior].coords
                        SetEntityCoords(PlayerPedId(), outcoords)
                        SetEntityVisible(PlayerPedId(), true)
                        SetLocalPlayerVisibleLocally(true)
                        LeaveInteriorInstance()
                        lastilevel = 1
                        lastinterior = nil
                        DoScreenFadeIn(500)
                        return 
                    end 
                }
                ::cont::
            end 
            lib.registerContext({
                id = 'garagechange',
                title = 'Garázs kinézete',
                options = options
            })

            lib.showContext('garagechange')
        end
    end)
end 


local repairpoints = {
    vector3(264.94696, -750.1589, 30.819902),
}

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do 
        Wait(10)
    end 
    AddTextEntry('repair_msg', '~INPUT_PICKUP~ a jármuved megjavíttatásához (50.000$) csak készpénz')
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local sleep = 1000

        if not lastGarage and IsPedInAnyVehicle(ped) then 
            for k=1, #repairpoints, 1 do
                if repairpoints[k] then 
                    local dis = #(coords - repairpoints[k])
                    local veh = GetVehiclePedIsIn(ped, false)
                    if DoesEntityExist(veh) and GetPedInVehicleSeat(veh, -1) == ped and dis < 20 then 
                        sleep = 2
                        DrawMarker(21, repairpoints[k], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 155, 20, 100, false, true, 2, false, false, false, false)
                        if dis < 4.0 then 
                            DisplayHelpTextThisFrame('repair_msg')
                            if IsControlJustReleased(0, 38) then
                                ESX.TriggerServerCallback("bc_garage:repair", function(d)
                                    if d then 
                                        SetVehicleFixed(veh)
	                                    SetVehicleDeformationFixed(veh)
                                    end 
                                end)
                                Wait(4000)
                            end  
                        end 
                    end 
                end 
            end 
        end 

        Wait(sleep)
    end
end)

RegisterNetEvent("bc_garage:setWaypoint", function(x,y)
    SetNewWaypoint(x,y)
end)

CreateThread(function()
    while not ESX or not ESX.PlayerLoaded do 
        Wait(500)
    end

    RequestModel(Config.PoliceNPC.model)
    while not HasModelLoaded(Config.PoliceNPC.model) do
        Wait(500)
    end

    local ped = CreatePed(4, Config.PoliceNPC.model, Config.PoliceNPC.coords, Config.PoliceNPC.heading, false, false)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)

    exports.ox_target:addLocalEntity(ped, {
            {
                event = "bc_garagepoliceimpound",
                icon = "fas fa-circle",
                label = "Rendvédelmi lefoglaltak",
                onSelect = function()
                    OpenPoliceImpound()
                end
            }
    })
end)

function OpenPoliceImpound()
    ESX.TriggerServerCallback("villamos_garage:getPoliceImpounds", function(vehicles) 
        if not vehicles then 
            return 
        end 
        local elements = {
            {unselectable = true, title = "Rendvédelmi lefoglaltak a kiváltás ára "..Config.PoliceNPC.price.."$ (fizetés csak készpénzben, ha nincs nálad elég akkor bankkártyával)"}
        }
        for i=1, #vehicles do 
            local veh = vehicles[i]
            veh.vehicle = json.decode(veh.vehicle) or {}
            local isjobveh = ""
            if veh.job and veh.job ~= "civ" then 
                isjobveh = " (Frakció)"
            end 
            elements[#elements+1] = {
                icon = "fas fa-car",
                title = (vehicleimgs[veh.vehicle.model] and vehicleimgs[veh.vehicle.model].name or GetDisplayNameFromVehicleModel(veh.vehicle.model)) .. " | " .. veh.plate .. isjobveh,
                value = veh.plate
            }
        end 

        ESX.OpenContext("right", elements, function(menu,element)
            ESX.CloseContext()

            local remaining = math.ceil((policeImpoundCooldownUntil - GetGameTimer()) / 1000)
            if remaining > 0 then
                return TriggerEvent("esx:showNotification", "Még várnod kell "..remaining.." másodpercet, mielőtt kiveszel egy másik lefoglalt autót!")
            end

            local cdleft = GetTakeoutCooldownLeft()
            if cdleft > 0 then
                return TriggerEvent("esx:showNotification", "Még "..cdleft.." másodpercet várnod kell a következő autó kivételéig!")
            end

            local data = {current = element}
            ESX.TriggerServerCallback("villamos_garage:getOutPoliceImpound", function(data)
                if not data then
                    return
                end
                data.vehicle = json.decode(data.vehicle)
                if not data.vehicle then
                    return
                end
                local model = data.vehicle.model
                if not IsModelInCdimage(model) then
                    TriggerEvent("esx:showNotification", "Ez az autó valószínűleg nincs bent a szerveren!")
                    return print("^1SCRIPT ERROR: Invalid model: "..model)
                end
                while not HasModelLoaded(model) do
                    RequestModel(model)
                    Wait(10)
                end
                local vehicle = CreateVehicle(model, Config.PoliceNPC.spawn, true, true)
                -- bc_kocsitorles: legalis spawn jelolese
                if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
                SetVehicleNumberPlateText(vehicle, data.plate)
                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                SetVehicleData(vehicle, data.vehicle)
                CreateTracker(data.plate)
                SetModelAsNoLongerNeeded(model)
                SetVehRadioStation(vehicle, 'OFF')
                policeImpoundCooldownUntil = GetGameTimer() + (Config.PoliceNPC.cooldown or 20) * 1000
                StartTakeoutCooldown()
                exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_garage:outV", NetworkGetNetworkIdFromEntity(vehicle), data.plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
            end, data.current.value)
        end)
    end)
end 



function WreckVehicle()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle or not DoesEntityExist(vehicle) then return false end 
    if GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return false end 

    local shopprice = exports['bc_vehshop']:GetVehPrice(GetEntityModel(vehicle))
    if shopprice and shopprice < 500000 then 
        return TriggerEvent('esx:showNotification', "Ez már most egy bontószökevény, ezt nem tudjuk bontani :)")
    end 

    local alert = lib.alertDialog({
        header = 'Bontás megerősítése',
        content = 'Biztosan bontóba küldöd a kocsit? (örökre el fog veszni)',
        centered = true,
        cancel = true
    })

    if alert == true or alert == "confirm" then 
        local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
        local ret = 3000
        if not NetworkGetEntityIsNetworked(vehicle) then 
            ESX.TriggerServerCallback("villamos_garage:wreckVehicle", function(success) 
                if not success then 
                    ret = false 
                    return 
                end 
                ret = true 
                SetEntityAsMissionEntity(vehicle, true, true)
                DeleteVehicle(vehicle)
            end, plate, false)
        else 
            local nid = NetworkGetNetworkIdFromEntity(vehicle)
            ESX.TriggerServerCallback("villamos_garage:wreckVehicle", function(success) 
                if not success then 
                    ret = false 
                    return 
                end 
                ret = true 
                SetEntityAsMissionEntity(vehicle, true, true)
                DeleteVehicle(vehicle)
            end, plate)
        end 
        while type(ret) == "number" and ret > 0 do 
            ret = ret - 100
            Wait(100)
        end 
        if type(ret) == "number" then 
            ret = false 
        end 
        return ret 
    end

    
end 

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do 
        Wait(10)
    end 
    AddTextEntry('garage_wreck_msg', '~INPUT_PICKUP~ a jármuved bontóba küldéséhez, (örökre törlődik)')
    if Config.Wrecking.blip then 
    local blip = AddBlipForCoord(Config.Wrecking.coords)
            SetBlipSprite(blip, Config.Wrecking.blip.sprite)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, Config.Wrecking.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.Wrecking.blip.label)
            EndTextCommandSetBlipName(blip)
    end 
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local sleep = 1000

        if  IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped then 
            --for k=1, #Config.Garages, 1 do
                if Config.Wrecking then 
                    local dis = #(coords - Config.Wrecking.coords)
                    if dis < 50 then 
                        sleep = 2
                        DrawMarker(6, Config.Wrecking.coords+vector3(0.0,0.0,-0.6), 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 6.0, 6.0, 6.0,  181, 24, 13, 100, false, true, 2, false, false, false, false)
                        DrawMarker(21, Config.Wrecking.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 181, 24, 13, 100, false, true, 2, false, false, false, false)
                        if dis < 6.0 then 
                            DisplayHelpTextThisFrame('garage_wreck_msg')
                            if IsControlJustReleased(0, 38) then
                                WreckVehicle()
                            end 
                        end 
                    end 
                end 
            --end 
        end 

        Wait(sleep)
    end
end)