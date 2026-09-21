if not Config.AimBlock.enable then return end
function aimBlock(global)
    CreateThread(function()
        while cache.weapon and (global and true or currentZone) do
            local aiming, entity = GetEntityPlayerIsFreeAimingAt(cache.playerId)
            local freeAiming = IsPlayerFreeAiming(cache.playerId)
            local type = GetEntityType(entity)

            if not freeAiming or IsPedAPlayer(entity) or type == 2 or (type == 1 and IsPedInAnyVehicle(entity, false)) then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 47, true)
                DisableControlAction(0, 58, true)
                DisablePlayerFiring(cache.ped, true)
            end
            Wait(1)
        end
    end)
end


-- ox_lib already tracks the equipped weapon hash, so reading it needs no per-3s export
-- call across the resource boundary into ox_inventory.
local BLOCKED_WEAPON = GetHashKey("WEAPON_HEAVYSNIPER_MK2")

Citizen.CreateThread(function()

	while true do
		if cache.weapon == BLOCKED_WEAPON and not currentZone then 
			TriggerEvent("ox_inventory:disarm")
			TriggerEvent("esx:showNotification", "Ezt a fegyvert itt nem használhatod!")
		end 

		Wait(3000)
	end
end)