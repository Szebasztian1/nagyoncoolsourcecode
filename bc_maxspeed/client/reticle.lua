--- @module reticle

--- @type boolean
local disableCrosshair = false

--- @type boolean
local hasWeapon = false

--- @type thread | nil
local crosshairThread = nil

--- @type thread | nil
local coverThread = nil

--- @param ped integer
local function hideCrosshair(ped)
    if DoesEntityExist(ped) and not IsEntityDead(ped) then
        if GetFollowPedCamViewMode() ~= 4 and IsPlayerFreeAiming() then
            HideHudComponentThisFrame(14)
        end
    end
end

local function startCrosshairThread()
    if crosshairThread then return end
    crosshairThread = CreateThread(function()
        while disableCrosshair and hasWeapon do
            hideCrosshair(PlayerPedId())
            Wait(1)
        end
        crosshairThread = nil
    end)
end

local function startCoverThread()
    if coverThread then return end
    coverThread = CreateThread(function()
        while hasWeapon do
            local ped = PlayerPedId()

            if IsPedInCover(ped, 1) and not IsPedAimingFromCover(ped, 1) then
                DisableControlAction(2, 24, true)
                DisableControlAction(2, 142, true)
                DisableControlAction(2, 257, true)
                Wait(5)
            else
                Wait(250)
            end
        end
        coverThread = nil
    end)
end

local function stopActiveThreads()
    hasWeapon = false
end

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    if weapon then
        hasWeapon = true
        startCoverThread()
        if disableCrosshair then
            startCrosshairThread()
        end
    else
        stopActiveThreads()
    end
end)

RegisterCommand("celkereszt", function()
    disableCrosshair = not disableCrosshair

    if disableCrosshair and hasWeapon then
        startCrosshairThread()
    end
end)
