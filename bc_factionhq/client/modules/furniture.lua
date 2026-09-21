--[[
    FactionHQ - HQ furniture (client): the placed pieces are LOCAL,
    non-networked frozen objects, spawned only while the player is
    inside (same pattern as the shell itself). Live add/remove events
    arrive only for players currently inside.
]]

local HQFurniture = {}

local objects = {}   -- [furnitureId] = entity handle
local anchor = nil   -- vector3 while inside, nil otherwise

local function loadModel(modelName)
    local model = joaat(modelName)
    if not IsModelValid(model) then return nil end
    RequestModel(model)
    local deadline = GetGameTimer() + 8000
    while not HasModelLoaded(model) and GetGameTimer() < deadline do Wait(25) end
    return HasModelLoaded(model) and model or nil
end

local function spawnPiece(item)
    if not anchor or objects[item.id] then return end
    local model = loadModel(item.model)
    if not model then
        print(('[bc_factionhq] furniture model "%s" did not load'):format(item.model))
        return
    end
    -- FONTOS: CreateObjectNoOffset, NEM CreateObject!
    -- A lerakaskor mentett pozicio a szellem-prop PONTOS entitas-poziciója
    -- (GetEntityCoords a PlaceObjectOnGroundProperly utan). A CreateObject
    -- viszont a modell magassagaval eltolja felfele a kapott koordinatat,
    -- ezert a butor a levegoben lebegve jelent meg, pedig a lerakasnal a
    -- foldon allt. A NoOffset valtozat pontosan oda teszi, ahova kertuk.
    -- (Ugyanez a minta a loaf_housing kertbutoroknal is.)
    local obj = CreateObjectNoOffset(model,
        anchor.x + item.offset.x, anchor.y + item.offset.y, anchor.z + item.offset.z,
        false, false, false)
    SetEntityHeading(obj, (item.heading or 0.0) + 0.0)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(model)
    objects[item.id] = obj
end

-- Called by the shell right after the interior spawned
function HQFurniture.SpawnAll(anchorVec, list)
    anchor = anchorVec
    for _, item in ipairs(list or {}) do
        spawnPiece(item)
    end
end

-- Called by the shell on every exit path
function HQFurniture.Clear()
    for _, obj in pairs(objects) do
        if DoesEntityExist(obj) then DeleteEntity(obj) end
    end
    objects = {}
    anchor = nil
end

-- Live updates while inside (server targets only the insiders)
RegisterNetEvent('FactionHQ:Client:FurnitureAdded')
AddEventHandler('FactionHQ:Client:FurnitureAdded', function(item)
    if anchor and type(item) == 'table' then
        spawnPiece(item)
    end
end)

RegisterNetEvent('FactionHQ:Client:FurnitureRemoved')
AddEventHandler('FactionHQ:Client:FurnitureRemoved', function(furnitureId)
    local obj = objects[furnitureId]
    if obj then
        if DoesEntityExist(obj) then DeleteEntity(obj) end
        objects[furnitureId] = nil
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        HQFurniture.Clear()
    end
end)

return HQFurniture
