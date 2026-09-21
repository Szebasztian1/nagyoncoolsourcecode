
---@type integer
local noclipVeh = 0
local isVehAHorse = false

---@param height number
local function getFallImpulse(height)
    local coefficient = 1.6428571428571428
    local intercept = 3.5714285714285836
    return coefficient * height + intercept
end

---@param keepInvincible boolean? don't clear invincibility at the end if another toggle (godMode) still needs it
local function disableRagdollingWhileFall(keepInvincible)
    CreateThread(function()
        local ped = PlayerPedId()
        local pedHeight = GetEntityHeightAboveGround(ped)
        if pedHeight == nil or pedHeight < 4.0 then
            DebugPrint('[noclip] Ped is too close to the ground, skipping forced fall')
            return
        end

        local pid = PlayerId()
        SetEntityInvincible(ped, true)
        SetPlayerFallDistance(pid, 9000.0)

        local downForce = getFallImpulse(pedHeight)
        ApplyForceToEntity(
            ped,
            3,
            vector3(0.0, 0.0, -downForce),
            vector3(0.0, 0.0, 0.0),
            0,
            true,
            true,
            true,
            false,
            true
        )

        local fallAwaitLimit = 1000
        local fallAwaitStep = 25
        local fallAwaitElapsed = 0
        while not IsPedFalling(ped) do
            if fallAwaitElapsed >= fallAwaitLimit then
                if not keepInvincible then SetEntityInvincible(ped, false) end
                SetPlayerFallDistance(pid, -1)
                return
            end
            fallAwaitElapsed = fallAwaitElapsed + fallAwaitStep
            Wait(fallAwaitStep)
        end

        repeat
            Wait(50)
        until not IsPedFalling(ped)

        Wait(750)
        if not keepInvincible then SetEntityInvincible(ped, false) end
        SetPlayerFallDistance(pid, -1)
    end)
end

---@param enabled boolean
---@param keepInvincible boolean? don't clear invincibility if another toggle (godMode) still needs it
---@param keepInvisible boolean? don't clear visibility if another toggle (invisible) still needs it
local function toggleFreecam(enabled, keepInvincible, keepInvisible)
    local ped = PlayerPedId()

    if enabled then
        -- Not SetEntityVisible: that is replicated and would hide the ped from on-duty
        -- colleagues too. The per-frame SetEntityLocallyInvisible below already keeps it
        -- out of our own view, and the server hides it from ordinary players.
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)

        noclipVeh = GetVehiclePedIsIn(ped, false)
        if IsPedOnMount(ped) then
            isVehAHorse = true
            noclipVeh = GetMount(ped)
        end

        if noclipVeh > 0 then
            NetworkSetEntityInvisibleToNetwork(noclipVeh, true)
            SetEntityCollision(noclipVeh, false, false)
            SetEntityVisible(noclipVeh, false, false)
            FreezeEntityPosition(noclipVeh, true)
            if not isVehAHorse then
                SetVehicleCanBreak(noclipVeh, false)
                SetVehicleWheelsCanBreak(noclipVeh, false)
            end
        end

        SetFreecamActive(true)
        StartFreecamThread()

        CreateThread(function()
            while IsFreecamActive() do
                SetEntityLocallyInvisible(ped, true)
                if noclipVeh > 0 then
                    if DoesEntityExist(noclipVeh) then
                        SetEntityLocallyInvisible(noclipVeh, true)
                    else
                        noclipVeh = 0
                    end
                end
                Wait(0)
            end

            if noclipVeh > 0 and DoesEntityExist(noclipVeh) then
                local coords = GetEntityCoords(ped)
                NetworkSetEntityInvisibleToNetwork(noclipVeh, false)
                SetEntityCoords(noclipVeh, coords.x, coords.y, coords.z, false, false, false, false)
                SetVehicleOnGroundProperly(noclipVeh)
                SetEntityCollision(noclipVeh, true, true)
                SetEntityVisible(noclipVeh, true, false)
                FreezeEntityPosition(noclipVeh, false)

                if isVehAHorse then
                    Citizen.InvokeNative(0x028F76B6E78246EB, ped, noclipVeh, -1)
                else
                    SetEntityAlpha(noclipVeh, 125)
                    SetPedIntoVehicle(ped, noclipVeh, -1)
                    local persistVeh = noclipVeh
                    CreateThread(function()
                        Wait(2000)
                        ResetEntityAlpha(persistVeh)
                        SetVehicleCanBreak(persistVeh, true)
                        SetVehicleWheelsCanBreak(persistVeh, true)
                    end)
                end
            end

            noclipVeh = 0
            isVehAHorse = false
        end)
    else
        SetFreecamActive(false)
        SetGameplayCamRelativeHeading(0)

        if not keepInvisible then
            SetEntityVisible(ped, true, false)
            ResetEntityAlpha(ped)
        end
        if not keepInvincible then
            SetEntityInvincible(ped, false)
        end
        FreezeEntityPosition(ped, false)

        if noclipVeh == 0 then
            disableRagdollingWhileFall(keepInvincible)
        end
    end
end

---@param data { value: boolean, keepInvincible: boolean?, keepInvisible: boolean? }
handlers['mate-admin:noclip:toggle'] = function(data)
    toggleFreecam(data.value == true, data.keepInvincible == true, data.keepInvisible == true)
end
