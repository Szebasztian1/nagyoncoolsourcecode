-- NPC shop (client): proximity-spawned ped that sells a placeable mining container ("CP").
-- The ped only exists while a player is near (see docs/npc-scripts.md).
-- Buying starts a placement mode: carry the CP, rotate/raise it, drop it inside the zone within 3 min.

local placing = false          -- placement state table while dropping a CP

local function comma(n)
    local s = tostring(math.floor(n or 0))
    return s:reverse():gsub('(%d%d%d)', '%1 '):reverse():gsub('^%s+', '')
end

local function drawTxt(text, x, y, scale, r, g, b, center)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextOutline()
    if center then SetTextCentre(true) end
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PLACEMENT
-----------------------------------------------------------------------------------------------------------------------------------------

local function stopPlacement()
    placing = false
end

-- moveId: reposition that already placed container instead of dropping a freshly bought one.
-- zone ({x, y, radius}): allowed drop area, defaults to the shop's (the server re-checks it).
local function startPlacement(moveId, zone)
    if placing then return end

    -- height is measured from the ground; never below ContainerGroundOffset, otherwise the dropped CP
    -- ends up buried and its [E] prompt is out of reach.
    placing = { height = Config.ContainerGroundOffset, moveId = moveId, deadline = GetGameTimer() + Config.NPCShop.placeTime * 1000 }

    CreateThread(function()
        local center = zone or Config.NPCShop.placeCenter
        local radius = zone and zone.radius or Config.NPCShop.placeRadius
        while placing do
            Wait(0)
            local ped = PlayerPedId()
            local pcoords = GetEntityCoords(ped)
            local fwd = GetEntityForwardVector(ped)
            local target = pcoords + fwd * Config.NPCShop.placeDist
            -- fall back to the player's own feet when the ground cannot be probed
            local gz = GetSurfaceZ(target.x, target.y, pcoords.z) or (pcoords.z - Config.ContainerGroundOffset)
            local z = gz + placing.height

            -- height fine-tune (up/down arrows)
            if IsControlPressed(0, 172) then placing.height = math.min(placing.height + 0.02, Config.NPCShop.placeMaxLift) end
            if IsControlPressed(0, 173) then placing.height = math.max(placing.height - 0.02, Config.ContainerGroundOffset) end
            DisableControlAction(0, 24, true)  -- block attack

            local inzone = #(vector2(target.x, target.y) - vector2(center.x, center.y)) <= radius

            -- preview marker (same style the placed container will use): green in zone, red outside
            local r, g, b = 50, 255, 50
            if not inzone then r, g, b = 235, 40, 40 end
            DrawMarker(2, target.x, target.y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, r, g, b, 120, true, true, 2, false, false, false, false)

            local remaining = math.ceil((placing.deadline - GetGameTimer()) / 1000)
            if remaining <= 0 then
                stopPlacement()
                TriggerEvent('bc_crypto:notification', moveId and 'Lejárt az idő, az áthelyezés megszakadt.' or 'Lejárt az idő, a lerakás megszakadt.')
                break
            end

            -- red countdown (top) + instructions (bottom)
            drawTxt(('~r~%d:%02d'):format(math.floor(remaining / 60), remaining % 60), 0.5, 0.045, 0.7, 235, 40, 40, true)
            drawTxt(('~w~[~b~E~w~] %s   [~b~X~w~] Mégse   [~b~▲ ▼~w~] Magasság'):format(moveId and 'Áthelyez' or 'Lerak'), 0.5, 0.88, 0.42, 255, 255, 255, true)
            if not inzone then
                drawTxt('~r~A megengedett zónán kívül vagy!', 0.5, 0.83, 0.5, 235, 40, 40, true)
            end

            if IsControlJustPressed(0, 38) then           -- E: place
                if inzone then
                    local coords = { x = target.x, y = target.y, z = z }
                    stopPlacement()
                    if moveId then
                        TriggerServerEvent('Crypto:Server:MoveCP', moveId, coords)
                    else
                        TriggerServerEvent('Crypto:Server:PlaceCP', coords)
                    end
                    break
                else
                    TriggerEvent('bc_crypto:notification', 'Itt nem rakhatod le a CP-t!')
                end
            elseif IsControlJustPressed(0, 73) then        -- X: cancel
                stopPlacement()
                TriggerEvent('bc_crypto:notification', moveId and 'Áthelyezés megszakítva.' or 'Lerakás megszakítva.')
                break
            end
        end
    end)
end

-- Server tells us whether the placement/charge succeeded (charge happens server-side).
RegisterNetEvent('bc_crypto:cpPlaceResult', function(success)
    -- placement ghost is already removed on confirm; this is only for feedback flow if needed
end)

-- Placement mode owns [E] and draws its own ghost, so client.lua hides the container prompts.
function IsPlacingCP()
    return placing and true or false
end

-- Entry point for the container manage menu (client/client.lua): reposition an owned container for
-- free, inside the zone the server sent with it. The server re-checks owner, zone and cooldown.
function StartCPMove(id, zone)
    if placing then return end
    startPlacement(id, zone)
    TriggerEvent('bc_crypto:notification', 'Keresd meg az új helyet, és rakd le a bányászatod!')
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOP MENU
-----------------------------------------------------------------------------------------------------------------------------------------

local function openShop()
    if placing then return end
    local info = TriggerServerCallback('bc_crypto:getShopInfo')
    if not info then return end

    local e = info.earnings
    local earnLine = 'Kereset becslés jelenleg nem elérhető.'
    if e and e.perHour then
        earnLine = ('Fullos setup (%d× %s, %d hashrate): **kb. $%s / óra**, ~$%s / nap (%s bányászásával).'):format(
            e.gpuCount, e.gpuName, e.hashrate, comma(e.perHour), comma(e.perDay), e.cryptoName)
    end

    local alert = lib.alertDialog({
        header = 'Crypto Bányászat',
        content = ('Ár: **%d PP**\n\n%s\n\nVásárlás után a helyszínen kell leraknod a bányászatod (%d perc). A PP csak sikeres lerakáskor vonódik le.'):format(
            info.price, earnLine, math.floor(Config.NPCShop.placeTime / 60)),
        centered = true,
        cancel = true,
        labels = { confirm = 'Vásárlás', cancel = 'Mégse' }
    })
    if alert == 'confirm' then
        startPlacement()
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PROXIMITY NPC (only spawned while a player is near)
-----------------------------------------------------------------------------------------------------------------------------------------

local shopPed = nil

local function deleteShopPed()
    if not shopPed then return end
    exports.ox_target:removeLocalEntity(shopPed, 'bc_crypto_shop')
    if DoesEntityExist(shopPed) then DeleteEntity(shopPed) end
    shopPed = nil
end

-- A blipet csak a jatekos spawnja utan (+1-2 mp) hozzuk letre: a betolteskori
-- torlodasban a blip neve elveszhet a terkep jelmagyarazatabol. A firstName-et az
-- ESX a karakter betoltesekor allitja be; a spawn es a SpawnSelector alatt a kep el
-- van sotetitve, vagy player switch / spawnSelecting fut. Az 1-2 mp resource-onkent mas.
local function WaitForSpawnBeforeBlips()
    while LocalPlayer.state.firstName == nil
        or not IsScreenFadedIn()
        or IsPlayerSwitchInProgress()
        or LocalPlayer.state.spawnSelecting == true do
        Wait(500)
    end
    Wait(1000 + GetHashKey(GetCurrentResourceName()) % 1000)
end

CreateThread(function()
    local S = Config.NPCShop
    local npcCoords = vector3(S.npc.x, S.npc.y, S.npc.z)

    -- static blip for the shop (a jatekos spawnja utan)
    CreateThread(function()
        WaitForSpawnBeforeBlips()
        local blip = AddBlipForCoord(npcCoords)
        SetBlipSprite(blip, 521)
        SetBlipColour(blip, 46)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Crypto Bányászat Bolt')
        EndTextCommandSetBlipName(blip)
    end)

    -- proximity spawn (see docs/npc-scripts.md): ped exists only while a player is near
    while true do
        local dist = #(GetEntityCoords(PlayerPedId()) - npcCoords)

        if dist < S.spawnDist then
            if not shopPed or not DoesEntityExist(shopPed) then
                RequestModel(S.ped)
                local timeout = GetGameTimer() + 5000
                while not HasModelLoaded(S.ped) and GetGameTimer() < timeout do Wait(10) end
                if HasModelLoaded(S.ped) then
                    shopPed = CreatePed(4, S.ped, S.npc.x, S.npc.y, S.npc.z - 1.0, S.npc.w, false, true)
                    FreezeEntityPosition(shopPed, true)
                    SetEntityInvincible(shopPed, true)
                    SetBlockingOfNonTemporaryEvents(shopPed, true)
                    SetModelAsNoLongerNeeded(S.ped)
                    exports.ox_target:addLocalEntity(shopPed, {
                        {
                            name = 'bc_crypto_shop',
                            icon = 'fa-solid fa-coins',
                            label = 'Crypto bányászat vásárlása',
                            distance = S.interactDist,
                            onSelect = function()
                                if not placing then openShop() end
                            end,
                        }
                    })
                end
            end
        elseif shopPed then
            deleteShopPed()
        end

        Wait(1000)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        stopPlacement()
        deleteShopPed()
    end
end)
