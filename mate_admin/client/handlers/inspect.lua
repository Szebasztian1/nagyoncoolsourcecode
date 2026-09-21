AdminInspectEnabled        = false
local isEnabled            = false
local isRendering          = false
local isHandling           = false
local isScanning           = false

local ScanDist <const>     = 60.0
local LineHeight <const>   = 0.020
local ScanInterval <const> = 500

---@type table<string, true>
local Pools <const>        = { 'CPed', 'CObject', 'CVehicle' }

---@type { entity: integer, data: table, dist: number }[]
local inspectCache         = {}

---@param entity integer
---@return vector3
local function getDrawPos(entity)
    local t = GetEntityType(entity)
    if t == 1 then
        return GetPedHeadCoords(entity)
    elseif t == 2 then
        return GetEntityCoords(entity) + vector3(0.0, 0.0, 2.0)
    end
    return GetEntityCoords(entity) + vector3(0.0, 0.0, 0.8)
end

---@param sx    number  normalized 0-1
---@param sy    number  normalized 0-1
---@param lines string[]
---@param alpha integer
local function drawInspectLabel(sx, sy, lines, alpha)
    for i, line in ipairs(lines) do
        DrawText({
            value   = line,
            font    = BebasNeueFont,
            scale   = 0.8,
            outline = true,
            center  = true,
            color   = { r = 255, g = 200, b = 50, a = alpha },
            pos     = {
                x = sx * screenX,
                y = (sy - (#lines - i) * LineHeight) * screenY,
            },
        })
    end
end

local SceneMenuDeleteRadius <const> = 5.0
local HandleDist <const>            = 3.0

---@return integer?, table?, number?
local function getClosestInspectable()
    local best, bestData, bestDist = nil, nil, ScanDist
    for _, entry in ipairs(inspectCache) do
        if entry.dist < bestDist then
            bestDist = entry.dist
            best     = entry.entity
            bestData = entry.data
        end
    end
    return best, bestData, bestDist
end

---@param entity integer
local function deleteInspectable(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if netId and netId ~= 0 then
        TriggerServerEvent('mate-admin:deleteEntity', netId)
    else
        DeleteEntity(entity)
    end
end

local function deleteSceneObjectsInRadius()
    local myPos = GetEntityCoords(PlayerPedId())
    for _, obj in ipairs(GetGamePool('CObject')) do
        if DoesEntityExist(obj) and #(GetEntityCoords(obj) - myPos) <= SceneMenuDeleteRadius then
            local netId = NetworkGetNetworkIdFromEntity(obj)
           exports["gs_eventprotect"]:GS_TriggerServerEvent('scmenu:removeobj', netId)
            DeleteObject(obj)
        end
    end
end

---@param myPos vector3
local function rebuildCache(myPos)
    local newCache = {}
    for _, pool in ipairs(Pools) do
        for _, entity in ipairs(GetGamePool(pool)) do
            if DoesEntityExist(entity) then
                local d = #(GetEntityCoords(entity) - myPos)
                if d <= ScanDist then
                    local data = Entity(entity).state.mhAdminInspection
                    if data then
                        newCache[#newCache + 1] = { entity = entity, data = data, dist = d }
                    end
                end
            end
        end
    end
    inspectCache = newCache
end

local function renderLoop()
    isRendering = true

    while true do
        local cache = inspectCache

        if #cache == 0 or not isEnabled then break end

        local myPos = GetEntityCoords(PlayerPedId())

        for _, entry in ipairs(cache) do
            if DoesEntityExist(entry.entity) then
                local dist = #(GetEntityCoords(entry.entity) - myPos)

                if dist <= ScanDist then
                    local pos              = getDrawPos(entry.entity)
                    local onScreen, sx, sy = World3dToScreen2d(pos.x, pos.y, pos.z)

                    if onScreen then
                        local alpha = math.max(40, math.floor(255 * (1.0 - dist / ScanDist)))
                        local lines = { '[ mhADMIN INSPECT ]' }
                        for k, v in pairs(entry.data) do
                            lines[#lines + 1] = ('%s: %s'):format(k, tostring(v))
                        end
                        drawInspectLabel(sx, sy, lines, alpha)
                    end
                end
            end
        end

        Wait(0)
    end

    isRendering = false
end

local function handleLoop()
    isHandling = true

    while true do
        local entity, data, dist = getClosestInspectable()

        if not entity or not isEnabled then break end

        local inRange = dist <= HandleDist

        if inRange then
            local sceneActive = GetResourceState('scenemenu') == 'started'
            local removeLabel = sceneActive and ('~INPUT_PICKUP~ ' .. locale('inspect.remove_nearby')) or
                ('~INPUT_PICKUP~ ' .. locale('inspect.remove_from_world'))

            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName('~INPUT_MAP_POI~ ' .. locale('inspect.copy_identifier') .. '\n' .. removeLabel)
            EndTextCommandDisplayHelp(0, false, true, -1)

            if IsControlJustPressed(0, 348) then
                local identifier = data.adminIdentifier
                    or data.identifier
                    or tostring(NetworkGetNetworkIdFromEntity(entity))
                lib.setClipboard(identifier)
                lib.notify({
                    title       = locale('inspect.title'),
                    description = locale('inspect.copied', identifier),
                    type        = 'success',
                    duration    = 3000,
                })
            end

            if IsControlJustPressed(0, 38) then
                if sceneActive then
                    deleteSceneObjectsInRadius()
                else
                    deleteInspectable(entity)
                end
            end
        end

        Wait(0)
    end

    isHandling = false
end

CreateThread(function()
    while true do
        -- Inspect is off by default; idle long instead of scanning every 500ms forever.
        if not isEnabled then
            if #inspectCache > 0 then inspectCache = {} end
            Wait(2000)
            goto continue
        end

        local myPos = GetEntityCoords(PlayerPedId())
        rebuildCache(myPos)

        if #inspectCache > 0 then
            if not isRendering then CreateThread(renderLoop) end
            if not isHandling then CreateThread(handleLoop) end
        end

        Wait(ScanInterval)
        ::continue::
    end
end)

handlers['mate-admin:inspect:toggle'] = function(_data)
    isEnabled           = not isEnabled
    AdminInspectEnabled = isEnabled

    lib.notify({
        title       = locale('inspect.toggle_title'),
        description = isEnabled and locale('common.enabled') or locale('common.disabled'),
        type        = isEnabled and 'success' or 'inform',
        duration    = 3000,
    })
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    isEnabled           = false
    AdminInspectEnabled = false
end)
