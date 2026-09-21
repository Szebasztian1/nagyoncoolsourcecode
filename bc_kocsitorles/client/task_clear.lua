---@diagnostic disable: undefined-global

Citizen.CreateThread(function()
    while true do
        Wait(500)
        local playerPed = PlayerPedId()
        local scriptTaskStatus = GetScriptTaskStatus(playerPed, 0x491A782D)
        if scriptTaskStatus ~= 7 then
            ClearPedTasksImmediately(playerPed)
        end
    end
end)
