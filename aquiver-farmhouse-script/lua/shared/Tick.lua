---@class Tick : OxClass
---@field ms number
---@field cb fun()
---@field private _isRunning boolean
local Tick = lib.class("Tick")

---@param ms number
---@param cb fun()
function Tick:constructor(ms, cb)
    self.ms = ms
    self.cb = cb

    self._isRunning = false
end

function Tick:start()
    if self._isRunning then return end

    self._isRunning = true

    Citizen.CreateThread(function()
        while self._isRunning do
            self:cb()

            Citizen.Wait(self.ms)
        end
    end)
end

function Tick:stop()
    self._isRunning = false
end

function Tick:isRunning()
    return self._isRunning
end

return Tick
