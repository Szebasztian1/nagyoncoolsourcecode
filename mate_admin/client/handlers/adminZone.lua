---@class AdminZone
---@field id        string
---@field adminSrc  number
---@field adminName string
---@field pos       vector3
---@field radius    number

---@type table<string, AdminZone>
local zones                = {}

local isRendering          = false

---@type table<integer, true>
local activeNoCollision    = {}

---@type table<string, integer>
local blips                = {}

local lastScanTime         = 0
local ScanInterval <const> = 300
local InspectLineH <const> = 0.020
local VisibleDist <const>  = Config.AdminZone.visibleDistance
local MarkerHeight <const> = Config.AdminZone.markerHeight
local MarkerColor <const>  = Config.AdminZone.markerColor

---@param zone  AdminZone
---@param alpha integer
local function drawZoneMarker(zone, alpha)
    DrawMarker(
        28,
        zone.pos.x, zone.pos.y, zone.pos.z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        zone.radius * 2.0, zone.radius * 2.0, zone.radius * 2.0,
        MarkerColor.r, MarkerColor.g, MarkerColor.b, alpha,
        false, false, 2, false, nil, nil, false
    )
end

---@param myPed     integer
---@param myVehicle integer
local function applyControlRestrictions(myPed, myVehicle)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 257, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)
    DisableControlAction(0, 143, true)
    DisableControlAction(0, 263, true)
    SetPedCanSwitchWeapon(myPed, false)

    if myVehicle ~= 0 then
        SetPlayerCanDoDriveBy(PlayerId(), false)
    end
end

---@param myPed     integer
---@param myVehicle integer
---@param entity    integer
local function applyNoCollisionNatives(myPed, myVehicle, entity)
    SetEntityNoCollisionEntity(myPed, entity, false)
    SetEntityNoCollisionEntity(entity, myPed, false)
    if myVehicle ~= 0 then
        SetEntityNoCollisionEntity(myVehicle, entity, false)
        SetEntityNoCollisionEntity(entity, myVehicle, false)
    end
end

---@param myPed     integer
---@param myVehicle integer
---@param entity    integer
local function clearNoCollision(myPed, myVehicle, entity)
    SetEntityNoCollisionEntity(myPed, entity, true)
    SetEntityNoCollisionEntity(entity, myPed, true)
    if myVehicle ~= 0 then
        SetEntityNoCollisionEntity(myVehicle, entity, true)
        SetEntityNoCollisionEntity(entity, myVehicle, true)
    end
    ResetEntityAlpha(entity)
end

---@param myPed     integer
---@param myVehicle integer
---@param myPos     vector3
local function scanAndApplyNoCollision(myPed, myVehicle, myPos)
    local newActive = {}

    for _, zone in pairs(zones) do
        if #(myPos - zone.pos) <= zone.radius * 2 then
            for _, ped in ipairs(GetGamePool('CPed')) do
                if ped ~= myPed and DoesEntityExist(ped) and not newActive[ped] then
                    if #(GetEntityCoords(ped) - zone.pos) <= zone.radius * 2 then
                        applyNoCollisionNatives(myPed, myVehicle, ped)
                        if not activeNoCollision[ped] then
                            SetEntityAlpha(ped, 170, false)
                        end
                        newActive[ped] = true
                    end
                end
            end

            for _, veh in ipairs(GetGamePool('CVehicle')) do
                if veh ~= myVehicle and DoesEntityExist(veh) and not newActive[veh] then
                    if #(GetEntityCoords(veh) - zone.pos) <= zone.radius * 2 then
                        applyNoCollisionNatives(myPed, myVehicle, veh)
                        if not activeNoCollision[veh] then
                            SetEntityAlpha(veh, 170, false)
                        end
                        newActive[veh] = true
                    end
                end
            end
        end
    end

    for entity in pairs(activeNoCollision) do
        if not newActive[entity] then
            if DoesEntityExist(entity) then
                clearNoCollision(myPed, myVehicle, entity)
            end
        end
    end

    activeNoCollision = newActive
end

---@param myPed integer
local function resetZoneEffects(myPed)
    SetPedCanSwitchWeapon(myPed, true)
    SetPlayerCanDoDriveBy(PlayerId(), true)

    local myVehicle = GetVehiclePedIsIn(myPed, false)
    for entity in pairs(activeNoCollision) do
        if DoesEntityExist(entity) then
            clearNoCollision(myPed, myVehicle, entity)
        end
    end

    activeNoCollision = {}
end

local function renderLoop()
    isRendering = true

    local wasInside = false

    while true do
        local myPed     = PlayerPedId()
        local myVehicle = GetVehiclePedIsIn(myPed, false)
        local myPos     = GetEntityCoords(myPed)
        local anyNear   = false
        local insideAny = false

        for _, zone in pairs(zones) do
            local dist = #(myPos - zone.pos)

            if dist <= VisibleDist then
                anyNear = true
                local alpha = math.max(15, math.floor(MarkerColor.a * (1.0 - dist / VisibleDist)))
                drawZoneMarker(zone, alpha)

                if AdminInspectEnabled then
                    local labelPos            = vector3(zone.pos.x, zone.pos.y, zone.pos.z + 1.2)
                    local onScreen, sx, sy    = World3dToScreen2d(labelPos.x, labelPos.y, labelPos.z)
                    if onScreen then
                        local labelAlpha = math.max(60, math.floor(255 * (1.0 - dist / VisibleDist)))
                        local lines      = {
                            locale('adminzone.hud_label'),
                            zone.adminName,
                            ('ID: %d'):format(zone.adminSrc),
                        }
                        for i, line in ipairs(lines) do
                            DrawText({
                                value   = line,
                                font    = BebasNeueFont,
                                scale   = 0.75,
                                outline = true,
                                center  = true,
                                color   = { r = 255, g = 200, b = 50, a = labelAlpha },
                                pos     = {
                                    x = sx * screenX,
                                    y = (sy - (#lines - i) * InspectLineH) * screenY,
                                },
                            })
                        end
                    end
                end
            end

            if dist <= zone.radius * 2 then
                insideAny = true
            end
        end

        if insideAny then
            applyControlRestrictions(myPed, myVehicle)

            if GetGameTimer() - lastScanTime >= ScanInterval then
                lastScanTime = GetGameTimer()
                scanAndApplyNoCollision(myPed, myVehicle, myPos)
            end

            for entity in pairs(activeNoCollision) do
                if DoesEntityExist(entity) then
                    applyNoCollisionNatives(myPed, myVehicle, entity)
                else
                    activeNoCollision[entity] = nil
                end
            end
        end

        if wasInside and not insideAny then
            resetZoneEffects(myPed)
        end

        wasInside = insideAny

        if not anyNear then break end
        Wait(0)
    end

    isRendering = false
end

CreateThread(function()
    while true do
        -- No zones defined: idle long instead of waking up twice a second forever.
        if not next(zones) then
            Wait(2000)
            goto continue
        end

        local myPos  = GetEntityCoords(PlayerPedId())
        local nearby = false

        for _, zone in pairs(zones) do
            if #(myPos - zone.pos) <= VisibleDist then
                nearby = true
                break
            end
        end

        if nearby and not isRendering then
            CreateThread(renderLoop)
        end

        Wait(500)
        ::continue::
    end
end)

---@param zone AdminZone
local function addZoneBlip(zone)
    local blip = AddBlipForCoord(zone.pos.x, zone.pos.y, zone.pos.z)
    SetBlipSprite(blip, 269)
    SetBlipScale(blip, 1.1)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(locale('cmd.adminzone.title'))
    EndTextCommandSetBlipName(blip)
    blips[zone.id] = blip
end

---@param zoneId string
local function removeZoneBlip(zoneId)
    local blip = blips[zoneId]
    if not blip then return end
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    blips[zoneId] = nil
end

RegisterNetEvent('mate-admin:zone:create')
AddEventHandler('mate-admin:zone:create', function(zone)
    zones[zone.id] = zone
    addZoneBlip(zone)
end)

RegisterNetEvent('mate-admin:zone:remove')
AddEventHandler('mate-admin:zone:remove', function(zoneId)
    zones[zoneId] = nil
    removeZoneBlip(zoneId)
end)

RegisterNetEvent('mate-admin:zone:sync')
AddEventHandler('mate-admin:zone:sync', function(syncData)
    for zoneId in pairs(zones) do
        removeZoneBlip(zoneId)
    end
    zones = {}
    for _, zone in ipairs(syncData) do
        zones[zone.id] = zone
        addZoneBlip(zone)
    end
end)
