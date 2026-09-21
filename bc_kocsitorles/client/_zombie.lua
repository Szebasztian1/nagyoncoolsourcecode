-- I kept everything what has been commented out originally

--[[
Citizen.CreateThread(function()
    for _, info in pairs(Config.Zones) do
      local blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(blip, 0)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 1.0)
      SetBlipColour(blip, 2)
      SetBlipAsShortRange(blip, true)
	   BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Publik")
      EndTextCommandSetBlipName(blip)

      blip = AddBlipForRadius(info.x,info.y,info.z, info.r)
      SetBlipHighDetail(blip, true)
	  SetBlipColour(blip, 2)
	  SetBlipAlpha (blip, 128)
    end
end)
]]


--[[
    local trucks = { `man`, `daf`, `t680d`, `W900`, `vnl780`, `hauler`, `phantom3` }
    local closevehlist = {}

    CreateThread(function()
        while issafe do
          Wait(500)
          local veh = GetVehiclePedIsIn(PlayerPedId(), false)
          closevehlist = {}
          if veh and DoesEntityExist(veh) then
            local vehcoords = GetEntityCoords(veh)
            local vehList = GetGamePool('CVehicle')
            for k,v in pairs(vehList) do
              local distance = #(vehcoords - GetEntityCoords(v))
              if distance < 100 and veh ~= v then
                closevehlist[#closevehlist+1] = v
              end
            end
          else
            Wait(2000)
          end
        end
      end)

      CreateThread(function()
        while issafe do
          Wait(1)
          local veh = GetVehiclePedIsIn(PlayerPedId(), false)
          local istruck = IsInTable(GetEntityModel(veh), trucks)
          --local towing = IsTowing(veh)
          --Entity(vehicle).state.kq_attached_to
          if veh and DoesEntityExist(veh) then
            local vehcoords = GetEntityCoords(veh)
            local vehList = GetGamePool('CVehicle')
            for k,v in pairs(closevehlist) do
              local distance = #(vehcoords - GetEntityCoords(v))
                if istruck then
                  if not IsInTable(GetEntityModel(v), Config.WhiteModels) then
                    SetEntityNoCollisionEntity(v, veh, true)
                    DisableCamCollisionForEntity(v)
                  end
                else
                  --if Entity(v).state.kq_attached_to ~= veh and Entity(veh).state.kq_attached_to ~= v then
                    SetEntityNoCollisionEntity(v, veh, true)
                    DisableCamCollisionForEntity(v)
                  --end
                end
            end
          else
            Wait(200)
          end
        end
      end)
]]


--[[
    Halloween notification
    TriggerEvent("halloweennotify", "warning", "Publikus területre értél", 4000)
    TriggerEvent("halloweennotify", "warning", "Kiléptél a publikus területről", 4000)
]]


--[[
    RegisterCommand("holanc", function(s,a,r)
        TriggerEvent("holanc:onoff")
    end)
]]


--[[
    CreateThread(function()
      while true do
        local vvvv = GetVehiclePedIsTryingToEnter(PlayerPedId())
        if DoesEntityExist(vvvv) then
          local ssss = GetSeatPedIsTryingToEnter(PlayerPedId())
          print(vvvv, ssss, GetPedInVehicleSeat(vvvv, ssss))
          if GetPedInVehicleSeat(vvvv, ssss) ~= 0 and DoesEntityExist(GetPedInVehicleSeat(vvvv, ssss)) then
            ClearPedTasksImmediately(PlayerPedId())
          end
        end
        Wait(20)
      end
    end)
]]


--[[
    CreateThread(function()
        while true do
          local pool = GetGamePool("CVehicle")
            for i = 1, #pool do
              local v = pool[i]
                if DoesEntityExist(v) and NetworkGetEntityIsNetworked(v) and not DoesEntityExist(GetPedInVehicleSeat(v, -1)) and not IsVehicleOnAllWheels(v) and GetEntitySpeed(v) > 25 and not DoesEntityExist(GetEntityAttachedTo(v)) then
                  TriggerServerEvent("bc_ved:fveh", NetworkGetNetworkIdFromEntity(v))
                    Wait(10)
                end
            end
            --TriggerServerEvent("bc_ved:fcarlist", apedlist)
            Wait(100)
        end
    end)
]]
