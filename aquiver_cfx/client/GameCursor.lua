GameCursor = {}
GameCursor._currentState = false

function GameCursor:set(newState)
    if self._currentState == newState then return end

    self._currentState = newState

    Citizen.CreateThread(function()
        while self._currentState do
            if not IsNuiFocused() then
                SetMouseCursorThisFrame()
            end

            DisableAllControlActions(0)

            EnableControlAction(0, 30, true)
            EnableControlAction(0, 31, true)

            Citizen.Wait(0)
        end
    end)
end

function GameCursor:get()
    return self._currentState
end

function GameCursor:toggle()
    self:set(not self:get())
end

--RegisterCommand("TOGGLE_GAME_CURSOR_STATE", function()
--    GameCursor:toggle()
--end, false)

--RegisterKeyMapping("TOGGLE_GAME_CURSOR_STATE", "Game Interact Cursor", "keyboard", "m")
