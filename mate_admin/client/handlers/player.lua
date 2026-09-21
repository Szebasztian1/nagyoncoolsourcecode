---@param data { x: number, y: number, z: number }
handlers['teleportSafe'] = function(data)
    local ped        = PlayerPedId()
    local veh        = GetVehiclePedIsIn(ped, false)
    local entity     = veh ~= 0 and veh or ped
    local noclipping = IsFreecamActive()

    CreateThread(function()
        if not noclipping then
            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do Wait(0) end
        end

        FreezeEntityPosition(entity, true)
        SetPedCoordsKeepVehicle(ped, data.x, data.y, data.z)
        RequestCollisionAtCoord(data.x, data.y, data.z)

        local deadline = GetGameTimer() + 5000
        while not HasCollisionLoadedAroundEntity(entity) and GetGameTimer() < deadline do
            Wait(0)
        end

        -- Always unfreeze: the freeze above is unconditional, so skipping it in the
        -- noclip branch left the ped stuck for good once freecam was turned off.
        FreezeEntityPosition(entity, false)

        if noclipping then
            -- Move the freecam itself, otherwise its periodic ped-sync snaps the ped right back
            SetFreecamPosition(data.x, data.y, data.z)
        else
            DoScreenFadeIn(500)
        end
    end)
end

---@param data? { x: number, y: number }
handlers['tpm']          = function(data)
    local x, y

    if data and data.x and data.y then
        x, y = data.x, data.y
    else
        local handle = GetFirstBlipInfoId(8)
        if not DoesBlipExist(handle) then
            lib.notify({ title = locale('cmd.tpm.notify_title'), description = locale('cmd.bringtomarker.no_waypoint'), type = 'error', duration = 3000 })
            return
        end
        local blipPos = GetBlipCoords(handle)
        x, y = blipPos.x, blipPos.y
    end

    local ped         = PlayerPedId()
    local vehicle     = GetVehiclePedIsIn(ped, false)
    local entity      = vehicle ~= 0 and vehicle or ped
    local backupPos   = GetEntityCoords(entity)
    local noclipping  = IsFreecamActive()

    ---@param ox number
    ---@param oy number
    ---@param oz number
    ---@return boolean
    ---@return vector3?
    local function findGroundZ(ox, oy, oz)
        local ray                    = StartShapeTestRay(ox, oy, oz + 1.0, ox, oy, oz - 20.0, 511, ped, 7)
        local retval, hit, hitCoords = GetShapeTestResult(ray)
        if retval == 0 then
            Wait(0)
            retval, hit, hitCoords = GetShapeTestResult(ray)
        end
        return hit == 1, hit == 1 and hitCoords or nil
    end

    CreateThread(function()
        if not noclipping then
            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do Wait(0) end
        end

        FreezeEntityPosition(entity, true)

        local found       = false
        local foundCoords = nil

        for z = -100, 1500, 15 do
            SetPedCoordsKeepVehicle(ped, x, y, z)
            RequestCollisionAtCoord(x, y, z)

            local deadline = GetGameTimer() + 300
            while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < deadline do
                Wait(0)
            end

            local hit, coords = findGroundZ(x, y, z)
            if hit then
                found       = true
                foundCoords = coords
                break
            end

            Wait(0)
        end

        local finalCoords = backupPos

        if found and foundCoords then
            finalCoords = vector3(foundCoords.x, foundCoords.y, foundCoords.z + 0.5)
            SetPedCoordsKeepVehicle(ped, finalCoords.x, finalCoords.y, finalCoords.z)
        else
            SetPedCoordsKeepVehicle(ped, backupPos.x, backupPos.y, backupPos.z)
            lib.notify({
                title       = locale('cmd.tpm.notify_title'),
                description = locale('player.ground_z_failed'),
                type        = 'error',
                duration    = 4000,
            })
        end

        -- Always unfreeze, same reason as in teleportSafe.
        FreezeEntityPosition(entity, false)

        if noclipping then
            -- Move the freecam itself, otherwise its periodic ped-sync snaps the ped right back
            SetFreecamPosition(finalCoords.x, finalCoords.y, finalCoords.z)
        else
            DoScreenFadeIn(500)
        end
    end)
end

handlers['kill']         = function()
    SetEntityHealth(PlayerPedId(), 0)
end

handlers['toggleFreeze'] = function()
    local ped    = PlayerPedId()
    local frozen = not IsEntityPositionFrozen(ped)

    FreezeEntityPosition(ped, frozen)

    lib.notify({
        title       = locale('player.freeze_title'),
        description = frozen and locale('player.frozen') or locale('player.unfrozen'),
        type        = 'inform',
        duration    = 4000,
    })
end

---@param data { amount: number }
handlers['setArmor']     = function(data)
    local amount = math.max(0, math.min(100, data.amount))
    SetPedArmour(PlayerPedId(), amount)
    lib.notify({ title = locale('player.armor_title'), description = locale('player.armor_set', amount), type = 'success', duration = 3000 })
end

handlers['heal']         = function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 100)
    lib.notify({ title = locale('player.heal_title'), description = locale('player.healed'), type = 'success', duration = 3000 })
end

