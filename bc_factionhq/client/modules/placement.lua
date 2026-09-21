--[[
    FactionHQ - placement mode (client)

    Marker mode (CP-k): a marker follows the player, scroll adjusts
    distance, Enter places, Backspace cancels, 60 s timeout.
    Ghost mode (furniture): pass ghostModel - a transparent local prop
    follows instead, left/right arrows rotate it, the confirmed position
    is the ghost's exact placed-on-ground position.

    The confirmed z is normalized to the surface below (raycast), stored
    in the ped-center convention (+1.0) the jobcreator markers also use.
]]

local HQMarker = require 'client.modules.marker'

local HQPlacement = { active = false }

-- z of the surface below the point, or nil (17 = world + objects)
local function groundZAt(x, y, z, ignoreEntity)
    local probe = StartExpensiveSynchronousShapeTestLosProbe(
        x, y, z + 1.5, x, y, z - 4.0, 17, ignoreEntity or 0, 4)
    local _, hit, hitCoords = GetShapeTestResult(probe)
    if hit == 1 or hit == true then
        return hitCoords.z
    end
    return nil
end

function HQPlacement.Start(labelText, cb, ghostModel)
    if HQPlacement.active then return cb(nil) end
    HQPlacement.active = true

    local fwdDist = 1.2
    local heading = 0.0
    local timeLimit = 60
    local startTime = GetGameTimer()
    local limitMs = timeLimit * 1000
    local cfg = Config.Marker

    local ghost = nil
    if ghostModel then
        local model = joaat(ghostModel)
        if IsModelValid(model) then
            RequestModel(model)
            local deadline = GetGameTimer() + 5000
            while not HasModelLoaded(model) and GetGameTimer() < deadline do Wait(25) end
            if HasModelLoaded(model) then
                local pc = GetEntityCoords(PlayerPedId())
                ghost = CreateObject(model, pc.x, pc.y, pc.z, false, false, false)
                SetEntityAlpha(ghost, 160, false)
                SetEntityCollision(ghost, false, false)
                FreezeEntityPosition(ghost, true)
                SetModelAsNoLongerNeeded(model)
            end
        end
        if not ghost then
            HQPlacement.active = false
            return cb(nil)
        end
    end

    local function finish(result)
        HQPlacement.active = false
        if ghost and DoesEntityExist(ghost) then DeleteEntity(ghost) end
        cb(result)
    end

    CreateThread(function()
        while HQPlacement.active do
            Wait(0)

            local elapsed = GetGameTimer() - startTime
            local remaining = math.ceil((limitMs - elapsed) / 1000)
            if elapsed >= limitMs then
                return finish(nil)
            end

            -- Block attack/aim/weapon-wheel (+ arrows in ghost mode)
            for _, c in ipairs({ 24, 25, 257, 263, 264, 14, 15, 16, 17, 99, 100, 75, 174, 175 }) do
                DisableControlAction(0, c, true)
            end

            if IsDisabledControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 99) then
                fwdDist = math.min(fwdDist + 0.3, 6.0)
            end
            if IsDisabledControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 100) then
                fwdDist = math.max(fwdDist - 0.3, 0.0)
            end
            if ghost then
                if IsDisabledControlPressed(0, 174) then heading = (heading - 1.5) % 360.0 end
                if IsDisabledControlPressed(0, 175) then heading = (heading + 1.5) % 360.0 end
            end

            local ped = PlayerPedId()
            local pc = GetEntityCoords(ped)
            local r = math.rad(GetEntityHeading(ped))
            local pos = vector3(pc.x - math.sin(r) * fwdDist, pc.y + math.cos(r) * fwdDist, pc.z)
            local groundZ = groundZAt(pos.x, pos.y, pos.z, ghost or ped)

            if ghost then
                SetEntityCoords(ghost, pos.x, pos.y, (groundZ or (pos.z - 1.0)), false, false, false, false)
                SetEntityHeading(ghost, heading)
                PlaceObjectOnGroundProperly(ghost)
                FreezeEntityPosition(ghost, true)
            else
                DrawMarker(cfg.type, pos.x, pos.y, pos.z - 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    cfg.size + 0.0, cfg.size + 0.0, cfg.height + 0.0,
                    cfg.color.r, cfg.color.g, cfg.color.b, cfg.color.a,
                    false, false, 2, false, nil, nil, false)
            end

            HQMarker.DrawText2D(0.5, 0.50, 'Lerakod: ~g~' .. (labelText or 'CP') .. '~s~', 0.5, true)
            if ghost then
                HQMarker.DrawText2D(0.5, 0.55, 'Forgatas: ~b~bal/jobb nyil~s~', 0.45, true)
            end
            HQMarker.DrawText2D(0.5, ghost and 0.60 or 0.55, 'Hatralevo ido: ~y~' .. remaining .. ' mp', 0.45, true)
            HQMarker.DrawText2D(0.5, ghost and 0.65 or 0.60, 'Gorgo: tavolsag  |  ~g~Enter~s~: lerak  |  ~r~Backspace~s~: megse', 0.4, true)

            if IsControlJustPressed(0, 201) or IsControlJustPressed(0, 18) then
                if ghost then
                    local gc = GetEntityCoords(ghost)
                    return finish({ x = gc.x, y = gc.y, z = gc.z, h = GetEntityHeading(ghost) })
                end
                -- Normalize the stored z to the surface below (ped-center convention)
                local z = groundZ and (groundZ + 1.0) or pos.z
                return finish({ x = pos.x, y = pos.y, z = z, h = GetEntityHeading(ped) })
            end
            if IsControlJustPressed(0, 202) or IsControlJustPressed(0, 177) then
                return finish(nil)
            end
        end
    end)
end

return HQPlacement
