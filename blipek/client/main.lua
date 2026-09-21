local Filter = require 'client.filter'
local Work = require 'client.work'
local External = require 'client.external'

local playerData = {}
local npcPoints = {}
local spawnedBlips = {}
local currentStates = {}
local cooldownEnd = 0 -- GetGameTimer() timestamp when the local toggle cooldown ends
local ClientRuntimeBlips = {}
local createNpcPoint -- forward declaration: the blipUpdated handler above the definition calls it

local function initClientRuntimeBlips()
    ClientRuntimeBlips = {}
    for i, blip in ipairs(Config.Blips) do
        ClientRuntimeBlips[i] = { index = i, npc = blip.npc, show = blip.show }
    end
end

---@param info table
---@param tempTable table
local function createSingleBlip(info, tempTable)
    tempTable.blip = AddBlipForCoord(info.coords.x, info.coords.y, info.coords.z)
    SetBlipSprite(tempTable.blip, info.id)
    SetBlipDisplay(tempTable.blip, 2)
    -- per-blip `scale` (config.lua): the legend only merges same-named blips of equal size
    SetBlipScale(tempTable.blip, (tonumber(info.scale) or 0.8) + 0.0)
    SetBlipColour(tempTable.blip, info.colour)
    SetBlipAsShortRange(tempTable.blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(info.title)
    EndTextCommandSetBlipName(tempTable.blip)

    if info.radiusBlip then
        tempTable.zoneblip = AddBlipForRadius(info.coords.x, info.coords.y, info.coords.z, info.radiusBlip.radius)
        SetBlipHighDetail(tempTable.zoneblip, true)
        SetBlipColour(tempTable.zoneblip, info.radiusBlip.color)
        SetBlipAlpha(tempTable.zoneblip, info.radiusBlip.alpha)
    end
end

---@param blipData table
local function removeBlips(blipData)
    if blipData.blip and DoesBlipExist(blipData.blip) then
        RemoveBlip(blipData.blip)
    end
    if blipData.zoneblip and DoesBlipExist(blipData.zoneblip) then
        RemoveBlip(blipData.zoneblip)
    end
    blipData.blip = nil
    blipData.zoneblip = nil
end

--- Latszik-e ez a blip? A szuro (kategoria + tetel) es a job-allapot
--- (szerelo telep nyitva/zarva) egyutt dont.
---@param info table
---@return boolean
local function shouldShowBlip(info)
    if not Filter.IsShown(info.title) then return false end
    if not info.npc then return true end
    return info.npc.job ~= nil and currentStates[info.npc.job] == true
end

--- Az esx:playerLoaded es az onResourceStart is hivja: a korabbi peldanyokat
--- eloszor toroljuk, igy barmelyik ag fut (akar mindketto), egy peldany marad.
local function createBlips()
    for _, blipData in pairs(spawnedBlips) do
        removeBlips(blipData)
    end
    spawnedBlips = {}

    for i, info in ipairs(Config.Blips) do
        local tempTable = {
            coords = info.coords,
            info = info
        }

        if shouldShowBlip(info) then
            createSingleBlip(info, tempTable)
        end

        if info.npc and info.npc.job then
            tempTable.job = info.npc.job
        end

        spawnedBlips[i] = tempTable
    end
end

--- Letrehozza/eltavolitja a blipeket, hogy a terkep kovesse a szurot es a
--- job-allapotokat.
local function updateBlip()
    for _, blipData in pairs(spawnedBlips) do
        local show = shouldShowBlip(blipData.info)
        local exists = blipData.blip ~= nil and DoesBlipExist(blipData.blip)

        if show and not exists then
            createSingleBlip(blipData.info, blipData)
        elseif not show and exists then
            removeBlips(blipData)
        end
    end
end

--- Blip-darabszam kategoriankent: eloszor az idegen (mas resource-ok) blipjei,
--- aztan a sajatjaink, vegul az egysegesitett munka-blipek.
---@return table<string, number>
local function categoryCounts()
    local counts = External.Counts()
    for _, blipData in pairs(spawnedBlips) do
        local key = Filter.CategoryOf(blipData.info.title)
        counts[key] = (counts[key] or 0) + 1
    end
    counts.munkak = (counts.munkak or 0) + Work.Counts()
    return counts
end

---@param handle number
---@return boolean
local function isOwnBlip(handle)
    for _, blipData in pairs(spawnedBlips) do
        if blipData.blip == handle or blipData.zoneblip == handle then
            return true
        end
    end
    return false
end

External.Init(isOwnBlip)

Filter.Init(function()
    updateBlip()
    Work.Apply()
    External.Apply()
end, categoryCounts)

---@param index number
local function removeNpcPoint(index)
    local entry = npcPoints[index]
    if not entry then return end
    if entry.ped and DoesEntityExist(entry.ped) then
        exports.ox_target:removeLocalEntity(entry.ped)
        DeleteEntity(entry.ped)
    end
    if entry.point then
        entry.point:remove()
    end
    npcPoints[index] = nil
end

RegisterNetEvent('blipek:client:handleBlipState', function(job, state)
    currentStates[job] = state
    updateBlip()
end)

RegisterNetEvent('blipek:client:handleBlipState:all', function(states)
    currentStates = states
    updateBlip()
end)

---@param index number
---@param blipData table
RegisterNetEvent('blipek:client:blipUpdated', function(index, blipData)
    print(('[blipek] blip update received | index: %d | title: %s | coords: %.2f, %.2f, %.2f')
        :format(index, blipData.title or '?', blipData.coords.x, blipData.coords.y, blipData.coords.z))

    if spawnedBlips[index] then
        removeBlips(spawnedBlips[index])
    end

    local coords = vector3(blipData.coords.x, blipData.coords.y, blipData.coords.z)

    local info = {
        title  = blipData.title,
        colour = blipData.colour,
        id     = blipData.id,
        coords = coords,
        scale  = blipData.scale,
    }

    if blipData.radiusBlip then
        info.radiusBlip = blipData.radiusBlip
    end

    if blipData.npc then
        info.npc = blipData.npc
    end

    local tempTable = { coords = coords, info = info }

    if not info.npc or (info.npc.job and currentStates[info.npc.job]) then
        createSingleBlip(info, tempTable)
    end

    if info.npc and info.npc.job then
        tempTable.job = info.npc.job
    end

    removeNpcPoint(index)
    if info.npc and playerData and playerData.job and playerData.job.name == info.npc.job then
        createNpcPoint(index, blipData.npc)
    end

    spawnedBlips[index] = tempTable
    print(('[blipek] blip %d ("%s") updated and re-rendered'):format(index, blipData.title or '?'))
    if ClientRuntimeBlips[index] then
        ClientRuntimeBlips[index].npc  = blipData.npc
        ClientRuntimeBlips[index].show = blipData.show
    end
end)

---@param npcDef table
local function spawnSingleNpc(npcDef)
    RequestModel(npcDef.model)

    local timeout = 0
    while not HasModelLoaded(npcDef.model) do
        Wait(0)
        timeout = timeout + 1
        if timeout > 500 then break end
    end

    if not HasModelLoaded(npcDef.model) then return end

    local cx = npcDef.coords.x
    local cy = npcDef.coords.y
    local cz = npcDef.coords.z
    local cw = npcDef.coords.w or 0.0

    local npc = CreatePed(4, npcDef.model, cx, cy, cz, cw, false, false)
    Wait(0)

    if not DoesEntityExist(npc) then return end

    SetEntityCoordsNoOffset(npc, cx, cy, cz, false, false, false)
    Wait(0)

    SetEntityHeading(npc, cw)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    SetModelAsNoLongerNeeded(npcDef.model)

    exports.ox_target:addLocalEntity(npc, {
        {
            label    = 'Blip be/ki kapcsolás',
            icon     = 'fas fa-power-off',
            job      = npcDef.job,
            onSelect = function()
                if currentStates[npcDef.job] == nil then return end

                local now = GetGameTimer()
                if now < cooldownEnd then
                    local remaining = math.ceil((cooldownEnd - now) / 1000)
                    local text
                    if remaining >= 60 then
                        local mins, secs = math.floor(remaining / 60), remaining % 60
                        text = secs > 0
                            and ('Újra használható %d perc %d másodperc múlva.'):format(mins, secs)
                            or ('Újra használható %d perc múlva.'):format(mins)
                    else
                        text = ('Újra használható %d másodperc múlva.'):format(remaining)
                    end
                    lib.notify({
                        title       = 'Blip Állapota',
                        description = text,
                        type        = 'inform'
                    })
                    return
                end

                cooldownEnd = now + Config.Wait
                lib.callback.await('blipek:callback:setBlipState', false, npcDef.job)
            end
        }
    })

    return npc
end

---@param index number
---@param npcDef table
function createNpcPoint(index, npcDef)
    npcPoints[index] = { point = nil, ped = nil, npcDef = npcDef }

    local coords = vector3(npcDef.coords.x, npcDef.coords.y, npcDef.coords.z)

    npcPoints[index].point = lib.points.new({
        coords   = coords,
        distance = 25,
        onEnter  = function()
            local ped = spawnSingleNpc(npcDef)
            if ped and npcPoints[index] then
                npcPoints[index].ped = ped
            end
        end,
        onExit   = function()
            local entry = npcPoints[index]
            if not entry then return end
            if entry.ped and DoesEntityExist(entry.ped) then
                exports.ox_target:removeLocalEntity(entry.ped)
                DeleteEntity(entry.ped)
            end
            entry.ped = nil
        end,
    })
end



---@param index number
---@param blipData table
RegisterNetEvent('blipek:client:blipCreated', function(index, blipData)
    local coords = vector3(blipData.coords.x, blipData.coords.y, blipData.coords.z)

    local info = {
        title  = blipData.title,
        colour = blipData.colour,
        id     = blipData.id,
        coords = coords,
        scale  = blipData.scale,
    }

    if blipData.radiusBlip then
        info.radiusBlip = blipData.radiusBlip
    end

    if blipData.npc then
        info.npc = blipData.npc
    end

    local tempTable = { coords = coords, info = info }

    if not info.npc then
        createSingleBlip(info, tempTable)
    elseif blipData.show then
        currentStates[info.npc.job] = true
        createSingleBlip(info, tempTable)
    end

    if info.npc and info.npc.job then
        tempTable.job = info.npc.job
        if playerData and playerData.job and playerData.job.name == info.npc.job then
            createNpcPoint(index, blipData.npc)
        end
    end

    spawnedBlips[index] = tempTable
    ClientRuntimeBlips[index] = { index = index, npc = blipData.npc, show = blipData.show }
end)

RegisterNetEvent('blipek:client:openAdminPanel', function()
    SetNuiFocus(true, true)
    Rpc:Send('open', {})
end)

RegisterNUICallback('exit', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

Rpc:Register('getJobs', function(_)
    return Rpc:CallServer('getJobs', {})
end)

Rpc:Register('getBlips', function(_)
    return Rpc:CallServer('getBlips', {})
end)

Rpc:Register('updateBlip', function(data)
    return Rpc:CallServer('updateBlip', data)
end)

Rpc:Register('getPlayerCoords', function(_)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped, true)
    return { x = coords.x, y = coords.y, z = coords.z }
end)

Rpc:Register('createBlip', function(data)
    return Rpc:CallServer('createBlip', data)
end)

Rpc:Register('deleteBlip', function(data)
    return Rpc:CallServer('deleteBlip', data)
end)

---@param index number
RegisterNetEvent('blipek:client:blipDeleted', function(index)
    local blipData = spawnedBlips[index]

    if blipData then
        removeBlips(blipData)

        removeNpcPoint(index)
    end

    local newBlips = {}
    for k, v in pairs(spawnedBlips) do
        if k < index then
            newBlips[k] = v
        elseif k > index then
            newBlips[k - 1] = v
        end
    end
    spawnedBlips = newBlips

    local newRuntime = {}
    for k, v in pairs(ClientRuntimeBlips) do
        if k < index then
            newRuntime[k] = v
        elseif k > index then
            newRuntime[k - 1] = v
        end
    end
    ClientRuntimeBlips = newRuntime

    local newPoints = {}
    for k, v in pairs(npcPoints) do
        if k < index then
            newPoints[k] = v
        elseif k > index then
            newPoints[k - 1] = v
        end
    end
    npcPoints = newPoints
end)

Rpc:Register('teleportToBlip', function(data)
    local ped = PlayerPedId()
    SetEntityCoords(ped, data.x, data.y, data.z, false, false, false, true)
    return { success = true }
end)

local placementMode = false

Rpc:Register('startNpcPlacement', function(_)
    if placementMode then
        return { ok = false }
    end

    placementMode = true
    Rpc:Send('hidePanel', {})
    SetNuiFocus(false, false)

    lib.showTextUI('[E] Pozíció megerősítése  |  [BACKSPACE] Mégse', {
        position = 'top-center',
        icon     = 'map-pin',
    })

    CreateThread(function()
        while placementMode do
            Wait(0)

            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped, true)

            DrawMarker(
                1,
                pos.x, pos.y, pos.z,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.0, 1.0, 0.5,
                34, 139, 34, 180,
                true, true, 2, false, nil, nil, false
            )

            if IsControlJustPressed(0, 38) then
                placementMode = false
                lib.hideTextUI()

                local heading = GetEntityHeading(ped)

                Wait(100)
                SetNuiFocus(true, true)
                Rpc:Send('showPanel', {})
                Rpc:Send('npcPlacementResult', {
                    x         = pos.x,
                    y         = pos.y,
                    z         = pos.z,
                    w         = heading,
                    cancelled = false,
                })
            elseif IsControlJustPressed(0, 177) then
                placementMode = false
                lib.hideTextUI()

                Wait(100)
                SetNuiFocus(true, true)
                Rpc:Send('showPanel', {})
                Rpc:Send('npcPlacementResult', { cancelled = true })
            end
        end
    end)

    return { ok = true }
end)

local function createNpcs()
    for index, _ in pairs(npcPoints) do
        removeNpcPoint(index)
    end
    npcPoints = {}

    if not playerData or not playerData.job then return end

    for _, v in pairs(ClientRuntimeBlips) do
        if v.npc and playerData.job.name == v.npc.job then
            createNpcPoint(v.index, v.npc)
        end
    end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    playerData = xPlayer
    currentStates = lib.callback.await('blipek:callback:getBlipStates', false)
    initClientRuntimeBlips()
    createBlips()
    External.HideReplaced()
    createNpcs()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    playerData = ESX.GetPlayerData()
    currentStates = lib.callback.await('blipek:callback:getBlipStates', false)
    initClientRuntimeBlips()
    createBlips()
    External.HideReplaced()
    createNpcs()
end)

RegisterNetEvent('esx:setJob', function(job, lastJob)
    playerData.job = job
    createNpcs()
end)
