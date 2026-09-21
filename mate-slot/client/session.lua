SlotSession          = {}

local _chair         = nil
local _spinning      = false
local _transitioning = false
local _seated        = false

local forceLeave
local leaveMachine
local playSlotMachine

---@param msg string
local function dbg(msg)
    if Config.Debug then
        print(("[mate-slot:session] %s"):format(msg))
    end
end

local function startInputLoop()
    CreateThread(function()
        while _seated do
            DisableFrontendThisFrame()

            if not _transitioning then
                if IsControlJustReleased(0, 202) and not _spinning then
                    leaveMachine()
                elseif IsControlJustReleased(0, 18) and not _spinning then
                    playSlotMachine()
                end
            end

            Wait(0)
        end
    end)
end

playSlotMachine = function()
    if _spinning or not _chair then return end

    _spinning = true

    dbg(("playSlotMachine — machineIndex=%d"):format(_chair.machineIndex))

    local animResult = SlotAnims:PlaySpinAnim(
        _chair.machineObj,
        _chair.machineCoords,
        _chair.machineRot
    )

    Rpc:Send("triggerSpin", {})

    Wait(math.floor(animResult.duration * 1000))
    SlotAnims:StopLeverScene(animResult.leverScene)

    _spinning = false

    dbg("playSlotMachine — complete")
end

---@param chairData table
function SlotSession:Enter(chairData)
    if _seated then
        dbg("Enter — already seated, ignoring")
        return
    end

    dbg(("Enter — machineIndex=%d, obj=%d"):format(
        chairData.machineIndex, chairData.machineObj
    ))

    local syncOk, syncResult = pcall(Rpc.CallServer, Rpc, "getOccupiedMachines", {})

    if syncOk and syncResult and syncResult.locks then
        for machineIndex, occupantSrc in pairs(syncResult.locks) do
            SlotWorld:SetMachineOccupied(machineIndex, true, occupantSrc)
        end
        dbg(("Enter — synced %d occupied machine(s) from server"):format((function()
            local n = 0
            for _ in pairs(syncResult.locks) do n = n + 1 end
            return n
        end)()))
    else
        dbg(("Enter — failed to sync occupied machines: %s"):format(tostring(syncResult)))
    end

    if SlotWorld:IsMachineOccupied(chairData.machineIndex) then
        lib.notify({
            title       = "Slot Gép",
            description = "Ez a gép már foglalt!",
            type        = "error",
        })
        dbg(("Enter — rejected client-side, machineIndex=%d is occupied"):format(chairData.machineIndex))
        return
    end

    local ok, result = pcall(Rpc.CallServer, Rpc, "openSession", {
        machineIndex = chairData.machineIndex,
    })

    if not ok then
        local msg = type(result) == "string" and result or "This machine is currently unavailable."
        local isBusy = msg:find("already in use") ~= nil

        lib.notify({
            title       = "Slot Gép",
            description = isBusy and "Ez a gép már foglalt!" or msg,
            type        = "error",
        })

        dbg(("Enter — server rejected seat reservation: %s"):format(msg))
        return
    end

    _chair         = chairData
    _seated        = true
    _spinning      = false
    _transitioning = true

    SlotAnims:SitDown(_chair.seatPos, _chair.seatRot)

    _transitioning = false

    TriggerEvent("mate-slot:internal:openUI")

    startInputLoop()

    dbg("Enter — seated, UI open")
end

leaveMachine = function()
    if not _seated then return end
    if _transitioning then return end

    if _spinning then
        dbg("leaveMachine — blocked, spin in progress")
        return
    end

    dbg("leaveMachine — beginning stand-up sequence")

    _transitioning = true

    TriggerEvent("mate-slot:internal:closeUI")

    local pos = _chair.seatPos
    local rot = _chair.seatRot

    SlotAnims:StandUp(pos, rot)

    Rpc:SendServer("closeSession", {})

    _chair         = nil
    _seated        = false
    _spinning      = false
    _transitioning = false

    dbg("leaveMachine — complete")
end

Rpc:Register("onSpinStarted", function(data)
    if not _chair then
        dbg("onSpinStarted — no active chair, ignoring")
        return
    end

    dbg(("onSpinStarted — bet=%s"):format(tostring(data and data.bet or "?")))

    CreateThread(function()
        local animResult = SlotAnims:PlaySpinAnim(
            _chair.machineObj,
            _chair.machineCoords,
            _chair.machineRot
        )

        if animResult.animName == "pull_spin_a" or animResult.animName == "pull_spin_b" then
            Wait(math.floor(animResult.duration * 320))
        end

        Wait(math.floor(animResult.duration * 1000))
        SlotAnims:StopLeverScene(animResult.leverScene)

        dbg("onSpinStarted — anim and sound complete")
    end)
end)

---@param result { winAmount: number, winTier: string }
function SlotSession:OnSpinResult(result)
    if not _chair then return end

    if result.winAmount and result.winAmount > 0 then
        dbg(("OnSpinResult — win=%d tier=%s"):format(result.winAmount, result.winTier or "normal"))
    else
        dbg("OnSpinResult — no win")
    end
end

Rpc:Register("exit", function(_)
    if _spinning then
        dbg("exit RPC — blocked, spin in progress")
        return
    end
    SlotSession:Leave()
end)

function SlotSession:Leave()
    leaveMachine()
end

function SlotSession:IsSeated()
    return _seated
end

function SlotSession:IsSpinning()
    return _spinning
end

function SlotSession:ForceReset()
    _chair         = nil
    _seated        = false
    _spinning      = false
    _transitioning = false

    dbg("ForceReset — state cleared")
end

forceLeave = function()
    if not _seated then
        _chair         = nil
        _spinning      = false
        _transitioning = false
        dbg("forceLeave — not seated, state cleared")
        return
    end

    local savedPos = _chair and _chair.seatPos
    local savedRot = _chair and _chair.seatRot

    _chair         = nil
    _seated        = false
    _spinning      = false
    _transitioning = false

    if savedPos and savedRot then
        CreateThread(function()
            local ok, err = pcall(SlotAnims.StandUp, SlotAnims, savedPos, savedRot)
            if not ok then
                ClearPedTasksImmediately(cache.ped)
                dbg(("forceLeave — StandUp pcall failed: %s"):format(tostring(err)))
            else
                dbg("forceLeave — StandUp complete")
            end
        end)
    else
        ClearPedTasksImmediately(cache.ped)
        dbg("forceLeave — no seat coords, cleared ped tasks immediately")
    end

    dbg("forceLeave — state cleared")
end

function SlotSession:ForceLeave()
    forceLeave()
end
