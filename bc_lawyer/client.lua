CreateThread(function()
	while true do 
		if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "ugyved" and ESX.PlayerData.job.grade == 0 then 
			while ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "ugyved" and ESX.PlayerData.job.grade == 0 do 
				--local veh = GetVehiclePedIsIn(PlayerPedId(), false)
				--if DoesEntityExist(veh) then 
				--	local model = GetEntityModel(veh)
				--	if model ~= GetHashKey("Bran7") then 
				--		ClearPedTasksImmediately(PlayerPedId())
				--		TriggerEvent("esx:showNotification", "Beugrós mentősként csak az erre kijelölt autót használhatod!")
				--	end 
				--end 
				--if exports["pma-voice"]:getRadioChannel() ~= 2 then 
				--	exports["pma-voice"]:setRadioChannel(2)
				--end 
				--TriggerEvent("skinchanger:getSkin", function(skin)
					if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then 
						--TriggerEvent("skinchanger:loadClothes", false, skinmale)

						exports["illenium-appearance"]:setPedComponents(PlayerPedId(), json.decode([[
						[{"drawable":0,"texture":0,"component_id":0},{"drawable":0,"texture":0,"component_id":1},{"drawable":0,"texture":0,"component_id":2},{"drawable":27,"texture":0,"component_id":3},{"drawable":28,"texture":0,"component_id":4},{"drawable":0,"texture":0,"component_id":5},{"drawable":111,"texture":0,"component_id":6},{"drawable":0,"texture":0,"component_id":7},{"drawable":96,"texture":16,"component_id":8},{"drawable":0,"texture":0,"component_id":9},{"drawable":0,"texture":0,"component_id":10},{"drawable":102,"texture":2,"component_id":11}]
						]]))
					else 
						--TriggerEvent("skinchanger:loadClothes", false, skinfemale)

						exports["illenium-appearance"]:setPedComponents(PlayerPedId(), json.decode([[
						[{"drawable":0,"texture":0,"component_id":0},{"drawable":0,"texture":0,"component_id":1},{"drawable":0,"texture":0,"component_id":2},{"drawable":27,"texture":0,"component_id":3},{"drawable":28,"texture":0,"component_id":4},{"drawable":0,"texture":0,"component_id":5},{"drawable":111,"texture":0,"component_id":6},{"drawable":0,"texture":0,"component_id":7},{"drawable":96,"texture":16,"component_id":8},{"drawable":0,"texture":0,"component_id":9},{"drawable":0,"texture":0,"component_id":10},{"drawable":102,"texture":2,"component_id":11}]
						]]))
					end 
				--end)
				Wait(1000)
			end 
			TriggerEvent("illenium-appearance:client:reloadSkin")
		--else 
		--	if exports["pma-voice"]:getRadioChannel() == 2 and ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name ~= "ambulance" then 
		--		exports["pma-voice"]:removePlayerFromRadio()
		--	end 
		end 
		Wait(1000)
	end 
end)

local ped = nil

CreateThread(function()
    lib.zones.sphere({
        coords = vec3(-556.3975, -193.3496, 37.326936),
        radius = 50.0,
        debug = false,
        onEnter = function()
            local model = GetHashKey("mp_m_bogdangoon")
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
            
            ped = CreatePed(4, model, vector4(-556.3975, -193.3496, 37.326936, 232.79173), false, true)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)

            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'bc_gov_jumpin',
                    icon = 'fa-solid fa-circle',
                    label = 'Beugrós ügyvéd felvétele/leadása',
                    distance = 2.0,
                    onSelect = function()
                        TriggerServerEvent("bc_gov:jumpin")
                    end
                },
            })
        end,
        onExit = function()
            if ped then
                exports.ox_target:removeLocalEntity(ped, 'bc_gov_jumpin')
                DeleteEntity(ped)
                ped = nil
            end
        end
    })
end)