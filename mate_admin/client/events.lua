-- Per-viewer visibility of invisible admins.
--
-- The hide is the same trick the freecam uses on its own ped: a per-frame
-- SetEntityLocallyInvisible. Everything cheaper was tried live and failed - a one-shot
-- SetPlayerVisibleLocally does not hide at all, NetworkSetEntityInvisibleToNetwork is
-- ignored on a player ped, and a viewer-side SetEntityVisible gets overwritten by the
-- sync node once a second, which shows up as a flicker. The render loop is the price.
--
-- So the whole game is making sure nothing runs unless an invisible admin is genuinely
-- streamed here. That question cannot be answered locally: a culled player still resolves
-- to an index, still reports active, and still has a ped handle frozen at the position it
-- was culled at. The server answers it instead, via playerEnteredScope / playerLeftScope
-- (server/main.lua) - out of scope means no override at all, and every thread below goes
-- back to sleep.

local HIDDEN <const>  = 0
local SCAN_MS <const> = 300

-- Scope alone is not a tight enough bound: OneSync keeps a player in scope far past the
-- point where the game still draws them, so the loop would keep running while the admin
-- is already a dot on the horizon. Inside scope the reported position is live and
-- accurate (unlike a culled ped, which freezes where it was dropped), so distance is a
-- usable test here - it was not before the server started managing scope.
local hideRangeSq     = (Config.Invisible.hideRange or 200.0) ^ 2

---@type table<integer, integer>  serverId -> alpha (0 = hide completely)
local overrides       = {}

---@type integer[]  peds to hide this frame, rebuilt by the scan
local hiddenPeds      = {}
local hiddenPedCount  = 0

---@param serverId integer
---@return integer|nil ped
local function resolvePed(serverId)
    local pid = GetPlayerFromServerId(serverId)
    if pid == -1 then return nil end

    local ped = GetPlayerPed(pid)
    if ped == 0 or not DoesEntityExist(ped) then return nil end

    return ped
end

---One-off check, only on the order that starts a hide. An order can arrive for a player
---who was never in scope here (the toggle is broadcast to everyone), and storing that
---would leave the threads polling for someone this client cannot even see.
---@param serverId integer
---@return boolean
local function isStreamed(serverId)
    for _, pid in ipairs(GetActivePlayers()) do
        if GetPlayerServerId(pid) == serverId then return true end
    end

    return false
end

---Rebuild the hide list and re-apply the ghost alpha. Only exists to catch a respawned
---ped; scope is handled by the server, not here.
local function scanOverrides()
    local n     = 0
    local myPos = GetEntityCoords(PlayerPedId())

    for serverId, alpha in pairs(overrides) do
        local ped = resolvePed(serverId)

        if ped then
            if alpha == HIDDEN then
                local pos = GetEntityCoords(ped)
                local dx, dy, dz = pos.x - myPos.x, pos.y - myPos.y, pos.z - myPos.z

                if dx * dx + dy * dy + dz * dz <= hideRangeSq then
                    n = n + 1
                    hiddenPeds[n] = ped
                end
            else
                -- Colleague ghost: never hidden for us, just drawn see-through. Alpha is
                -- lost on respawn, hence the re-apply.
                SetEntityAlpha(ped, alpha, false)
            end
        end
    end

    for i = n + 1, hiddenPedCount do
        hiddenPeds[i] = nil
    end

    hiddenPedCount = n
end

---@param serverId integer
local function clearOverride(serverId)
    local ped = resolvePed(serverId)
    if ped then ResetEntityAlpha(ped) end
end

---Is this client hiding `serverId`'s ped completely right now?
---
---Anything that builds a "who is around me" list has to ask, and has no other way to:
---the ped of an invisible admin stays network-visible on purpose (see the header), so
---DoesEntityExist, the position and the distance all answer normally for them. Only this
---table knows. It is the same table the render loop reads, so such a list can never
---disagree with what the player is actually shown - and an on-duty colleague, who gets
---the ghost instead of the hide, still gets false here.
---@param serverId number
---@return boolean
exports('IsPlayerHiddenHere', function(serverId)
    return overrides[tonumber(serverId)] == HIDDEN
end)

RegisterNetEvent('mate-admin:setPlayerVisible')
AddEventHandler('mate-admin:setPlayerVisible', function(targetSrc, visible, alpha, fromScope)
    if targetSrc == GetPlayerServerId(PlayerId()) then return end

    if visible and not alpha then
        if overrides[targetSrc] then
            overrides[targetSrc] = nil
            clearOverride(targetSrc)
        end
    elseif fromScope or overrides[targetSrc] or isStreamed(targetSrc) then
        overrides[targetSrc] = visible and alpha or HIDDEN
    else
        return
    end

    -- Straight away, so a toggle takes effect now rather than on the next scan.
    scanOverrides()
end)

-- The render loop. One native per hidden ped, no lookups, no allocation. Ticks every
-- frame even while idle - checking an integer is free, and sleeping here is what let a
-- freshly-scoped admin render for up to SCAN_MS before the hide ever reached them.
CreateThread(function()
    while true do
        local did = false 
        for i = 1, hiddenPedCount do
            did = true 
            SetEntityLocallyInvisible(hiddenPeds[i])
        end

        if not did then 
            Wait(250)
        end 
        Wait(0)
    end
end)

-- The scan. Idles long while nothing is overridden.
CreateThread(function()
    while true do
        if not next(overrides) then
            if hiddenPedCount > 0 then
                for i = 1, hiddenPedCount do hiddenPeds[i] = nil end
                hiddenPedCount = 0
            end

            Wait(2000)
            goto continue
        end

        scanOverrides()

        Wait(SCAN_MS)
        ::continue::
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for serverId in pairs(overrides) do
        clearOverride(serverId)
    end

    overrides      = {}
    hiddenPedCount = 0
end)

RegisterNetEvent('mate-admin:notify')
AddEventHandler('mate-admin:notify', function(data)
    if source == '' then return end
    lib.notify({
        title       = data.title,
        description = data.description,
        type        = data.type,
        duration    = data.duration,
    })
end)

RegisterNetEvent('mate-admin:plateinfo')
AddEventHandler('mate-admin:plateinfo', function(data)
    if source == '' then return end
    lib.notify({
        title       = locale('plateinfo.title', data.plate),
        description = locale('plateinfo.desc',
            data.ownerName,
            tostring(data.ownerServerId),
            data.ownerIdf,
            data.vehicleType or 'N/A'
        ),
        type        = 'inform',
        duration    = 12000,
    })
end)
