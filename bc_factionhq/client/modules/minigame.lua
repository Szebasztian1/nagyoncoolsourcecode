--[[
    FactionHQ - breach minigame bridge (client)

    A self-contained NUI lockpick/breach minigame (no ox_lib on the live
    server). The NUI owns the gameplay; this module only opens it, forwards
    the tuning config and returns the pass/fail result. Keyboard focus is
    always released here so it can never leak.

    HQMinigame.Start(cfg, cb)  -> cb(success:boolean)
    HQMinigame.Abort()         -> force-cancel (player left the door / died)
    HQMinigame.IsActive()      -> true while the minigame runs
]]

local HQMinigame = { active = false }

local currentCb = nil

local function finish(success)
    if not HQMinigame.active then return end
    HQMinigame.active = false
    SetNuiFocus(false, false)
    local fn = currentCb
    currentCb = nil
    if fn then fn(success == true) end
end

function HQMinigame.IsActive()
    return HQMinigame.active
end

function HQMinigame.Start(cfg, cb)
    if HQMinigame.active then return cb(false) end
    HQMinigame.active = true
    currentCb = cb
    -- Keyboard focus without a mouse cursor: the minigame is key-driven
    SetNuiFocus(true, false)
    SendNUIMessage({ action = 'breachStart', cfg = cfg or {} })
end

-- Tell the NUI to stop; it posts breachDone(false) which cleans up. The
-- guard flag in finish() makes a double result harmless.
function HQMinigame.Abort()
    if not HQMinigame.active then return end
    SendNUIMessage({ action = 'breachAbort' })
end

RegisterNUICallback('breachDone', function(data, cb)
    cb('ok')
    finish(data and data.success == true)
end)

-- Never leave the game with stuck NUI focus if the resource stops mid-breach
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and HQMinigame.active then
        HQMinigame.active = false
        currentCb = nil
        SetNuiFocus(false, false)
    end
end)

return HQMinigame
