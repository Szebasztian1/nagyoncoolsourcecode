-- Teleports the player (or the vehicle they drive) to a marker.
-- Marker coords sit on the ground, so the ped goes 1.0 above it.
function teleportToCoords(coords)
    CreateThread(function()
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local entity = (vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped) and vehicle or ped

        DoScreenFadeOut(300)
        Wait(350)

        FreezeEntityPosition(entity, true)
        SetEntityCoords(entity, coords.x, coords.y, coords.z + 1.0, false, false, false, false)

        -- Wait for the world to stream in, otherwise you fall through it
        local timeout = GetGameTimer() + 5000

        repeat
            RequestCollisionAtCoord(coords.x, coords.y, coords.z)
            Wait(100)
        until HasCollisionLoadedAroundEntity(entity) or GetGameTimer() > timeout

        FreezeEntityPosition(entity, false)
        DoScreenFadeIn(300)
    end)
end
