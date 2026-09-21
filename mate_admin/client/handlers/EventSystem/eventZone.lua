local zoneBlip = nil
local radiusBlip = nil

local function removeEventZoneBlip()
    if zoneBlip and DoesBlipExist(zoneBlip) then
        RemoveBlip(zoneBlip)
    end
    zoneBlip = nil

    if radiusBlip and DoesBlipExist(radiusBlip) then
        RemoveBlip(radiusBlip)
    end
    radiusBlip = nil
end

---@param data { pos: { x: number, y: number, z: number }, radius: number, speed: number }
local function createEventZoneBlip(data)
    removeEventZoneBlip()

    local pos = data.pos

    radiusBlip = AddBlipForRadius(pos.x, pos.y, pos.z, data.radius + 0.0)
    SetBlipColour(radiusBlip, 1)
    SetBlipAlpha(radiusBlip, 128)

    zoneBlip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(zoneBlip, 269)
    SetBlipScale(zoneBlip, 1.0)
    SetBlipColour(zoneBlip, 1)
    SetBlipAsShortRange(zoneBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(locale('eventzone.blip_name'))
    EndTextCommandSetBlipName(zoneBlip)
end

RegisterNetEvent('mate-admin:eventzone:create')
AddEventHandler('mate-admin:eventzone:create', function(data)
    createEventZoneBlip(data)
end)

RegisterNetEvent('mate-admin:eventzone:remove')
AddEventHandler('mate-admin:eventzone:remove', function()
    removeEventZoneBlip()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    removeEventZoneBlip()
end)
