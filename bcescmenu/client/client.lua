-- Térkép a kézben, amíg az ESC (pause) menü nyitva van.
--
-- 2026-09-21: a térkép beragadhatott a kézbe. Okok és javítás:
--  * a propot hálózati objektumként hozzuk létre (mások is lássák), de hálózati objektumot
--    csak az törölhet, akié épp a hálózati tulajdon -- ha az átvándorolt, a DeleteEntity
--    csendben nem csinált semmit. Törlés előtt ezért visszakérjük az irányítást;
--  * a PlayerProps tábla sosem ürült, így fél másodpercenként újra "törölte" a régi
--    handle-öket, amiket közben más entitás is megkaphatott. Törlés után ürítjük;
--  * biztonsági háló: bezáráskor pár másodpercig minden, a karakterünkre csatolt
--    térkép-propot törlünk, akkor is, ha a handle-je elveszett.

local MAP_PROP = GetHashKey('p_tourist_map_01_s')
local MAP_PROP_BONE = 28422
local MAP_ANIM_DICT = 'amb@world_human_tourist_map@male@idle_b'
local MAP_ANIM = 'idle_d'
local SWEEP_AFTER_CLOSE_MS = 3000

local inMenuMode = false
local Animation = false
local PlayerProps = {}
local sweepUntil = 0

local function LoadAnim(dict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        RequestAnimDict(dict)
        Wait(10)
    end
    return HasAnimDictLoaded(dict)
end

local function LoadPropModel(model)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        RequestModel(model)
        Wait(10)
    end
    return HasModelLoaded(model)
end

--- Deletes one prop even if its network ownership has wandered off meanwhile.
local function DeleteProp(obj)
    if not obj or obj == 0 or not DoesEntityExist(obj) then return end

    if NetworkGetEntityIsNetworked(obj) and not NetworkHasControlOfEntity(obj) then
        local timeout = GetGameTimer() + 500
        repeat
            NetworkRequestControlOfEntity(obj)
            Wait(0)
        until NetworkHasControlOfEntity(obj) or GetGameTimer() > timeout or not DoesEntityExist(obj)
    end

    if not DoesEntityExist(obj) then return end
    DetachEntity(obj, true, false)
    SetEntityAsMissionEntity(obj, true, true)
    DeleteEntity(obj)
end

local function DestroyAllProps()
    for _, obj in pairs(PlayerProps) do
        DeleteProp(obj)
    end
    PlayerProps = {}
end

--- Every map prop still hanging on our ped, whether we still know its handle or not.
local function DeleteAttachedMapProps()
    local ped = PlayerPedId()
    for _, obj in ipairs(GetGamePool('CObject')) do
        if GetEntityModel(obj) == MAP_PROP and GetEntityAttachedTo(obj) == ped then
            DeleteProp(obj)
        end
    end
end

local function AddPropToPlayer()
    if not LoadPropModel(MAP_PROP) then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local obj = CreateObject(MAP_PROP, coords.x, coords.y, coords.z + 0.2, true, true, true)
    -- bc_kocsitorles: legalis spawn jelolese
    if obj and obj ~= 0 and NetworkGetEntityIsNetworked(obj) then Entity(obj).state:set('bc_spawned', true, true) end
    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, MAP_PROP_BONE), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        true, true, false, true, 1, true)
    PlayerProps[#PlayerProps + 1] = obj
    SetModelAsNoLongerNeeded(MAP_PROP)
end

local function AnimMode()
    if inMenuMode then return end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsTryingToEnter(ped)
    if IsPedInAnyVehicle(ped, false) or (veh and veh ~= 0) then return end

    inMenuMode = true
    Animation = true

    if not LoadAnim(MAP_ANIM_DICT) then return end
    -- A menü a betöltés alatt bezárulhatott: ilyenkor már ne adjunk térképet a kézbe.
    if not IsPauseMenuActive() then return end

    AddPropToPlayer()
    TaskPlayAnim(ped, MAP_ANIM_DICT, MAP_ANIM, 2.0, 8.0, -1, 53, 0, false, false, false)
end

CreateThread(function()
    -- Egy korábbi futásból (pl. resource-restart) itt maradt árva térkép.
    DeleteAttachedMapProps()

    while true do
        Wait(500)

        if IsPauseMenuActive() then
            AnimMode()
        else
            if inMenuMode or Animation then
                if Animation then
                    Animation = false
                    StopAnimTask(PlayerPedId(), MAP_ANIM_DICT, MAP_ANIM, 1.0)
                end
                inMenuMode = false
                DestroyAllProps()
                sweepUntil = GetGameTimer() + SWEEP_AFTER_CLOSE_MS
            end

            if GetGameTimer() < sweepUntil then
                DeleteAttachedMapProps()
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    -- Itt nem lehet várni az irányításra, ezért csak a sima törlés.
    for _, obj in pairs(PlayerProps) do
        if DoesEntityExist(obj) then DeleteEntity(obj) end
    end
end)
