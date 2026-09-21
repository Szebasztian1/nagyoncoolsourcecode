function IsVehicleSecured(veh)
    local class = GetVehicleClass(veh)
    for i = 1, #Config.SecuredVehClasses do
        if Config.SecuredVehClasses[i] == class then
            return true
        end
    end
    return false
end

CreateThread(function()
    exports.ox_target:addGlobalVehicle({{
        label = "Autó feltörése",
        name = "car_lockpicking",
        icon = "fa-solid fa-user-ninja",
        distance = 5,
        canInteract = function(entity, distance, coords, name, bone)
            if GetEntityType(entity) ~= 2 or not NetworkGetEntityIsNetworked(entity) or IsVehicleSecured(entity) then
                return false
            end
            if Entity(entity).state.vilmos_heist_locked then
                return false end
            if Entity(entity).state.vilmos_heist then
                return false end
            local state = Entity(entity).state
            if state and state.hijacked then
                return false
            end
            return true
        end,
        onSelect = function(data)
            StartLockPicking(data.entity)
        end
    }})
end)

function StartLockPicking(entity)
    if not DoesEntityExist(entity) then
        return
    end
    if GetEntityType(entity) ~= 2 or not NetworkGetEntityIsNetworked(entity) or IsVehicleSecured(entity) then
        return
    end
    local state = Entity(entity).state
    if state and state.hijacked then
        return
    end
    if exports.ox_inventory:GetItemCount(Config.Lockpick) < 1 then
        return TriggerEvent("esx:showNotification", "Nincs nálad lockpick!")
    end
    local success = lib.skillCheck({ 'easy', 'easy', 'medium' }, { 'w', 'a', 's', 'd' })
    local netid = NetworkGetNetworkIdFromEntity(entity)
    TriggerServerEvent("carkeys:lockpick", netid, success)
end
