Cursor = {}
Cursor._currentState = false
Cursor._forceState = false
Cursor._tickState = false

---@param newState boolean
function Cursor:set(newState)
    self._currentState = newState

    if self._currentState then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)

        if not self._tickState then
            self._tickState = true

            Citizen.CreateThread(function()
                while self._tickState do
                    DisableAllControlActions(0)

                    EnableControlAction(0, 30, true)
                    EnableControlAction(0, 31, true)

                    Citizen.Wait(0)
                end
            end)
        end
    else
        self._tickState = false

        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
end

function Cursor:get()
    return self._currentState
end

function Cursor:toggle()
    self:set(not self._currentState)
end

---@param forceState boolean
function Cursor:force(forceState)
    self._forceState = forceState
end

RegisterCommand("TOGGLE_CURSOR_STATE", function()
    Cursor:toggle()
end, false)
--
--RegisterKeyMapping("TOGGLE_CURSOR_STATE", "Cursor", "keyboard", "m")

return Cursor
