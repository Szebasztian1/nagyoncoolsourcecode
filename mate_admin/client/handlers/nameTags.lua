local isOnDuty        = false
-- Off by default: the render loop is the resource's only meaningful idle cost, so it
-- stays dormant until an admin explicitly turns name tags on (F9 / panel toggle).
local nameTagsEnabled = false
local UNARMED_HASH    = GetHashKey("WEAPON_UNARMED")

---@type table<integer, string>
local playerJobLabels = {}

RegisterNetEvent('mate-admin:player:jobs')
AddEventHandler('mate-admin:player:jobs', function(data)
    playerJobLabels = data
end)

---@param serverId integer
---@return string|nil
local function getJobLabel(serverId)
    local st = Player(serverId).state
    if st then
        if st.job and st.job.label then return st.job.label end
        if st.job_label then return st.job_label end
    end
    return playerJobLabels[serverId]
end

---@class TagSlotDef
---@field id      string
---@field label   string
---@field enabled boolean
---@field scope   "foot"|"vehicle"|"both"

---@type table<string, TagSlotDef>
local TAG_SLOTS = {
    serverId  = { id = 'serverId', label = 'Server ID', enabled = true, scope = 'both', order = 1 },
    job       = { id = 'job', label = 'Job Label', enabled = true, scope = 'both', order = 2 },
    armed     = { id = 'armed', label = 'Armed Badge', enabled = true, scope = 'both', order = 3 },
    reporter  = { id = 'reporter', label = 'Reporter Badge', enabled = true, scope = 'both', order = 4 },
    role      = { id = 'role', label = 'Role (D/P)', enabled = true, scope = 'vehicle', order = 5 },
    healthBar = { id = 'healthBar', label = 'Health Bar', enabled = true, scope = 'foot', order = 6 },
    armorBar  = { id = 'armorBar', label = 'Armor Bar', enabled = true, scope = 'foot', order = 7 },
}

local function loadSlotPrefs()
    for id in pairs(TAG_SLOTS) do
        local saved = GetResourceKvpString('nametag_slot_' .. id)
        if saved ~= nil and saved ~= '' then
            TAG_SLOTS[id].enabled = saved == '1'
        end
    end
end

---@param id string
---@return boolean
local function slotEnabled(id)
    local s = TAG_SLOTS[id]
    return s ~= nil and s.enabled
end

local TAG_REFRESH_MS <const> = 250

---@class TagCacheEntry
---@field at           number   GetGameTimer() of last rebuild
---@field isDriver     boolean|nil  nil = on foot
---@field line1Talking string
---@field line1Normal  string
---@field badgeLine    string|nil  All badges pre-joined into one drawable string
---@field badgeScale   number

---@type table<integer, TagCacheEntry>
local tagCache = {}

local function clearTagCache()
    tagCache = {}
end

Rpc:Register("nameTags:getSlots", function()
    local out = {}
    for id, slot in pairs(TAG_SLOTS) do
        out[id] = { id = id, label = slot.label, enabled = slot.enabled, scope = slot.scope, order = slot.order }
    end
    return { success = true, data = out }
end)


Rpc:Register("nameTags:setSlot", function(data)
    if type(data.id) ~= 'string' or type(data.enabled) ~= 'boolean' then
        return { success = false }
    end
    local slot = TAG_SLOTS[data.id]
    if not slot then
        return { success = false }
    end
    slot.enabled = data.enabled
    SetResourceKvp('nametag_slot_' .. data.id, data.enabled and '1' or '0')
    clearTagCache()

    return { success = true }
end)

loadSlotPrefs()

---@type table<integer, integer>
local playerBlips = {}

---@param ped integer
---@return vector3
local function getPredictedHeadCoords(ped)
    local bone   = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, 31086))
    local coords = (bone == vec3(0, 0, 0)) and (GetEntityCoords(ped) + vec3(0, 0, 0.9)) or (bone + vec3(0, 0, 0.35))
    local vel    = GetEntityVelocity(ped)
    local ft     = GetFrameTime()
    return vec3(coords.x + vel.x * ft, coords.y + vel.y * ft, coords.z + vel.z * ft)
end

local function cleanupAllBlips()
    for _, blip in pairs(playerBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    playerBlips = {}
end

---@param serverId integer
---@param player   integer
---@param ped      integer
local function addPlayerBlip(serverId, player, ped)
    if playerBlips[serverId] then return end
    local blip = AddBlipForEntity(ped)
    SetBlipSprite(blip, 185)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(('[%d] %s'):format(serverId, GetPlayerName(player)))
    EndTextCommandSetBlipName(blip)
    playerBlips[serverId] = blip
end

---@param serverId integer
local function removePlayerBlip(serverId)
    local blip = playerBlips[serverId]
    if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
    playerBlips[serverId] = nil
end

---@param ped      integer
---@param player   integer
---@param serverId integer
---@param isDriver boolean|nil  nil = on foot
---@return TagCacheEntry
local function buildTagEntry(ped, player, serverId, isDriver)
    local inVehicle = isDriver ~= nil

    local rest      = { GetPlayerName(player) }

    if slotEnabled('job') then
        local jLabel = getJobLabel(serverId)
        if jLabel then
            local sep = inVehicle and '—' or '-'
            rest[#rest + 1] = ('<font color="#adb5bd">%s %s</font>'):format(sep, jLabel)
        end
    end

    local restStr = table.concat(rest, ' ')
    local line1Normal, line1Talking

    if slotEnabled('serverId') then
        line1Normal  = ('[%d] '):format(serverId) .. restStr
        line1Talking = ('<font color="#228be6">[%d] </font> '):format(serverId) .. restStr
    else
        line1Normal, line1Talking = restStr, restStr
    end

    local badges = {}

    if slotEnabled('armed') then
        local _, weaponHash = GetCurrentPedWeapon(ped, true)
        if weaponHash ~= UNARMED_HASH then
            badges[#badges + 1] = '<font color="#ff6b6b">[ARMED]</font>'
        end
    end

    if inVehicle and slotEnabled('role') then
        badges[#badges + 1] = isDriver
            and '<font color="#74c0fc">[DRIVER]</font>'
            or '<font color="#adb5bd">[PASSENGER]</font>'
    end

    if slotEnabled('reporter') then
        if Player(serverId).state.mhReporter then
            badges[#badges + 1] = '<font color="#ff6b6b">[REPORTER]</font>'
        end
    end

    -- Badges are concatenated into ONE centred string: the game's text renderer honours
    -- the inline <font color> markup, so a single DrawText replaces one draw call per
    -- badge. Each DrawText is ~10 natives, and this runs per visible player per frame.
    return {
        line1Normal  = line1Normal,
        line1Talking = line1Talking,
        badgeLine    = #badges > 0 and table.concat(badges, ' ') or nil,
        badgeScale   = inVehicle and 0.50 or 0.55,
    }
end

---@param ped      integer
---@param player   integer
---@param serverId integer
---@param isDriver boolean|nil
---@param now      number  GetGameTimer()
---@return TagCacheEntry
local function getTagEntry(ped, player, serverId, isDriver, now)
    local entry = tagCache[serverId]
    if not entry or now - entry.at > TAG_REFRESH_MS or entry.isDriver ~= isDriver then
        entry          = buildTagEntry(ped, player, serverId, isDriver)
        entry.at       = now
        entry.isDriver = isDriver
        tagCache[serverId] = entry
    end
    return entry
end

---@param entry TagCacheEntry
---@param y     number
-- Draw params are rebuilt every frame for every visible player, so the tables below are
-- allocated once and mutated in place instead of being recreated per draw call.
local COLOR_WHITE <const> = { r = 255, g = 255, b = 255, a = 255 }
local COLOR_DEAD  <const> = { r = 255, g = 50, b = 50, a = 255 }

local textPos    = { x = 0, y = 0 }
local textParams = { outline = true, center = true, color = COLOR_WHITE, pos = textPos }

local badgePos    = { x = 0, y = 0 }
local badgeParams = { outline = true, center = true, color = COLOR_WHITE, pos = badgePos }

local healthBarParams = {
    x = 0.0, y = -0.026, width = 0.055, height = 0.005, value = 0, max = 100,
    bg = { r = 0, g = 0, b = 0, a = 180 }, fill = { r = 80, g = 200, b = 120, a = 255 },
}

local armorBarParams = {
    x = 0.0, y = -0.018, width = 0.055, height = 0.005, value = 0, max = 100,
    bg = { r = 0, g = 0, b = 0, a = 180 }, fill = { r = 80, g = 140, b = 255, a = 255 },
}

local function drawBadgeRow(entry, y)
    local line = entry.badgeLine
    if not line then return end

    badgeParams.value = line
    badgeParams.font  = BebasNeueFont
    badgeParams.scale = entry.badgeScale
    badgePos.x        = 0
    badgePos.y        = y
    DrawText(badgeParams)
end

---@param ped       integer
---@param coords    vector3
---@param playerIdx integer
---@param serverId  integer
---@param now       number
local function drawNameTag(ped, coords, playerIdx, serverId, now)
    local rawHealth    = GetEntityHealth(ped)
    local rawMaxHealth = GetEntityMaxHealth(ped)
    if not rawHealth or not rawMaxHealth then
        return
    end

    local health    = math.max(0, rawHealth - 100)
    local maxHealth = math.max(100, rawMaxHealth - 100)
    local armor     = GetPedArmour(ped) or 0
    local entry     = getTagEntry(ped, playerIdx, serverId, nil, now)
    local line1     = NetworkIsPlayerTalking(playerIdx) and entry.line1Talking or entry.line1Normal
    local color     = IsEntityDead(ped) and COLOR_DEAD or COLOR_WHITE

    SetDrawOrigin(coords.x, coords.y, coords.z + 0.2, 0)

    if slotEnabled('healthBar') then
        healthBarParams.value = health
        healthBarParams.max   = maxHealth
        DrawWorldProgress(healthBarParams)
    end

    if slotEnabled('armorBar') and armor > 0 then
        armorBarParams.value = armor
        DrawWorldProgress(armorBarParams)
    end

    textParams.value = line1
    textParams.font  = BebasNeueFont
    textParams.scale = 0.65
    textParams.color = color
    textPos.y        = -14
    DrawText(textParams)

    drawBadgeRow(entry, 0)

    ClearDrawOrigin()
end

---@param vehicle   integer
---@param occupants { player: integer, ped: integer, serverId: integer }[]
---@param now       number
local function drawVehicleTag(vehicle, occupants, now)
    local _, modelMax = GetModelDimensions(GetEntityModel(vehicle))
    local coords      = GetEntityCoords(vehicle)
    local driverPed   = GetPedInVehicleSeat(vehicle, -1)

    for i = 2, #occupants do
        if occupants[i].ped == driverPed then
            occupants[1], occupants[i] = occupants[i], occupants[1]
            break
        end
    end

    SetDrawOrigin(coords.x, coords.y, coords.z + modelMax.z + 0.25, 0)

    for i, occ in ipairs(occupants) do
        local entry = getTagEntry(occ.ped, occ.player, occ.serverId, occ.ped == driverPed, now)
        local yBase = -(i - 1) * 28

        textParams.value = NetworkIsPlayerTalking(occ.player) and entry.line1Talking or entry.line1Normal
        textParams.font  = BebasNeueFont
        textParams.scale = 0.60
        textParams.color = COLOR_WHITE
        textPos.y        = yBase
        DrawText(textParams)

        drawBadgeRow(entry, yBase + 13)
    end

    ClearDrawOrigin()
end

RegisterNetEvent('mate-admin:tag:onDuty')
AddEventHandler('mate-admin:tag:onDuty', function(adminSrc)
    if adminSrc == GetPlayerServerId(PlayerId()) then
        isOnDuty = true
    end
end)

RegisterNetEvent('mate-admin:tag:offDuty')
AddEventHandler('mate-admin:tag:offDuty', function(adminSrc)
    if adminSrc == GetPlayerServerId(PlayerId()) then
        isOnDuty = false
        cleanupAllBlips()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    cleanupAllBlips()
end)

handlers['mate-admin:nameTags:toggle'] = function(data)
    nameTagsEnabled = type(data.value) == 'boolean' and data.value or not nameTagsEnabled
    if not nameTagsEnabled then cleanupAllBlips() end
end

local isRendering = false

-- The render loop runs every frame. Rebuilding the player list and allocating a fresh
-- table per player per frame was the bulk of the on-duty cost, so the roster scan is
-- throttled and every buffer below is reused instead of reallocated.
local SCAN_INTERVAL <const> = 250

-- Hard ceiling on tags drawn in one frame. Each tag costs ~50 natives (text + bars),
-- so a crowded spot with 40 players in range is what spikes the frame time. Candidates
-- are sorted nearest-first, so the cap drops the farthest, least useful tags.
local MAX_TAGS <const> = 20

---@type { player: integer, ped: integer, serverId: integer }[]
local candidates     = {}
local candidateCount = 0
local renderDistSq   = 0

---@type table<integer, { player: integer, ped: integer, serverId: integer }[]>
local vehicleGroups = {}
---@type integer[]
local vehicleKeys   = {}
---@type { player: integer, ped: integer, serverId: integer }[]
local onFootPlayers = {}

---@param a table
---@param b table
---@return boolean
local function byDistance(a, b)
    return a.dist2 < b.dist2
end

---Refresh the list of players worth considering. The natives here (GetActivePlayers,
---IsPedAPlayer, GetPlayerServerId, IsDutyAdmin) are the expensive part and the roster
---changes slowly, so this runs a few times a second rather than every frame.
---Sorted nearest-first so the per-frame draw cap keeps the closest players.
---@param myServerId integer
---@param myPos vector3
local function rebuildCandidates(myServerId, myPos)
    local dist   = Config.NameTags.renderDistance
    renderDistSq = dist * dist

    local prevCount = #candidates
    local n         = 0
    for _, player in ipairs(GetActivePlayers()) do
        local ped      = GetPlayerPed(player)
        local serverId = GetPlayerServerId(player)

        if IsPedAPlayer(ped) and DoesEntityExist(ped) and serverId ~= myServerId and not IsDutyAdmin(serverId) then
            local pos = GetEntityCoords(ped)
            local dx, dy, dz = pos.x - myPos.x, pos.y - myPos.y, pos.z - myPos.z

            n = n + 1
            local slot = candidates[n]

            if slot then
                slot.player, slot.ped, slot.serverId = player, ped, serverId
                slot.dist2 = dx * dx + dy * dy + dz * dz
            else
                candidates[n] = {
                    player = player, ped = ped, serverId = serverId,
                    dist2  = dx * dx + dy * dy + dz * dz,
                }
            end
        end
    end

    candidateCount = n

    -- Drop stale slots from a previous, longer scan: table.sort would otherwise mix
    -- their outdated distances into the live range.
    for i = n + 1, prevCount do
        candidates[i] = nil
    end

    if n > 1 then
        table.sort(candidates, byDistance)
    end
end

local function renderLoop()
    isRendering = true

    local myServerId = GetPlayerServerId(PlayerId())
    local nextScan   = 0

    while true do
        local now   = GetGameTimer()
        local myPos = GetEntityCoords(PlayerPedId())

        if now >= nextScan then
            rebuildCandidates(myServerId, myPos)
            nextScan = now + SCAN_INTERVAL
        end

        local hasNearby = false
        local vehCount  = 0
        local footCount = 0
        local drawn     = 0

        for i = 1, candidateCount do
            if drawn >= MAX_TAGS then break end

            local c   = candidates[i]
            local ped = c.ped

            if DoesEntityExist(ped) then
                -- Squared compare: avoids a sqrt per player per frame.
                local pos = GetEntityCoords(ped)
                local dx, dy, dz = pos.x - myPos.x, pos.y - myPos.y, pos.z - myPos.z

                if dx * dx + dy * dy + dz * dz <= renderDistSq then
                    hasNearby = true
                    drawn     = drawn + 1

                    if IsPedInAnyVehicle(ped, false) then
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        local group   = vehicleGroups[vehicle]

                        if not group then
                            group                  = {}
                            vehicleGroups[vehicle] = group
                            vehCount               = vehCount + 1
                            vehicleKeys[vehCount]  = vehicle
                        end

                        group[#group + 1] = c
                    else
                        footCount                = footCount + 1
                        onFootPlayers[footCount] = c
                    end
                end
            end
        end

        for i = 1, vehCount do
            local vehicle = vehicleKeys[i]

            if IsEntityOnScreen(vehicle) then
                local vPos = GetEntityCoords(vehicle)
                if IsSphereVisible(vPos.x, vPos.y, vPos.z, 1.5) then
                    drawVehicleTag(vehicle, vehicleGroups[vehicle], now)
                end
            end

            vehicleGroups[vehicle] = nil
        end

        for i = 1, footCount do
            local p = onFootPlayers[i]

            if IsEntityOnScreen(p.ped) then
                local headPos = getPredictedHeadCoords(p.ped)
                if IsSphereVisible(headPos.x, headPos.y, headPos.z, 0.01) then
                    drawNameTag(p.ped, headPos, p.player, p.serverId, now)
                end
            end

            onFootPlayers[i] = nil
        end

        if not hasNearby or not nameTagsEnabled then break end
        Wait(0)
    end

    clearTagCache()
    isRendering = false
end

CreateThread(function()
    while true do
        -- Off duty this scanner has nothing to do; idle long instead of every 300ms.
        if not (isOnDuty and nameTagsEnabled) then
            Wait(2000)
            goto continue
        end

        if not isRendering then
            local myServerId = GetPlayerServerId(PlayerId())
            local myPos      = GetEntityCoords(PlayerPedId())
            local nearby     = false

            for _, player in ipairs(GetActivePlayers()) do
                local ped      = GetPlayerPed(player)
                local serverId = GetPlayerServerId(player)

                if IsPedAPlayer(ped) and DoesEntityExist(ped) and serverId ~= myServerId and not IsDutyAdmin(serverId) then
                    if #(GetEntityCoords(ped) - myPos) <= Config.NameTags.renderDistance then
                        nearby = true
                        break
                    end
                end
            end

            if nearby then
                CreateThread(renderLoop)
            end
        end

        Wait(300)
        ::continue::
    end
end)

CreateThread(function()
    while true do
        -- Idle at 2s while there is nothing to rotate; only tighten to 150ms when blips
        -- actually exist. Previously this spun at 150ms on every client forever, even for
        -- players who are not admins and never have a single blip.
        if not next(playerBlips) then
            Wait(2000)
            goto continue
        end

        for serverId, blip in pairs(playerBlips) do
            if DoesBlipExist(blip) then
                local player = GetPlayerFromServerId(serverId)
                if player ~= -1 then
                    local ped = GetPlayerPed(player)
                    if DoesEntityExist(ped) then
                        SetBlipRotation(blip, math.floor(GetEntityHeading(ped)))
                    end
                end
            end
        end

        Wait(150)
        ::continue::
    end
end)

CreateThread(function()
    while true do
        if isOnDuty and nameTagsEnabled then
            local myServerId = GetPlayerServerId(PlayerId())
            local myPed      = PlayerPedId()
            local myPos      = GetEntityCoords(myPed)

            ---@type table<integer, boolean>
            local seenIds    = {}

            for _, player in ipairs(GetActivePlayers()) do
                local ped      = GetPlayerPed(player)
                local serverId = GetPlayerServerId(player)

                if IsPedAPlayer(ped) and DoesEntityExist(ped) and serverId ~= myServerId then
                    local dist = #(GetEntityCoords(ped) - myPos)

                    if dist <= Config.NameTags.blipRange then
                        seenIds[serverId] = true
                        addPlayerBlip(serverId, player, ped)
                    end
                end
            end

            for serverId in pairs(playerBlips) do
                if not seenIds[serverId] then
                    removePlayerBlip(serverId)
                end
            end
        else
            if next(playerBlips) then cleanupAllBlips() end
        end

        Wait(2000)
    end
end)
