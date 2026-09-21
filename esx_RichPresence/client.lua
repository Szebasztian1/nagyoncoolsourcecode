local WaitTime = 5000


Citizen.CreateThread(function()
while true do
		local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))))
		if VehName == "NULL" then VehName = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))) end
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
		local StreetHash = GetStreetNameAtCoord(x, y, z)
		local pId = GetPlayerServerId(PlayerId())
		local pName = GetPlayerName(PlayerId())
		local playerCount = #GetActivePlayers()
		Citizen.Wait(WaitTime)
		if StreetHash ~= nil then
			StreetName = GetStreetNameFromHashKey(StreetHash)
			if IsPedOnFoot(PlayerPedId()) and not IsEntityInWater(PlayerPedId()) then
           if IsPedSprinting(PlayerPedId()) then
					SetRichPresence("ID: "..pId.." | "..pName.." rohan "..StreetName.." utcáin")
				elseif IsPedRunning(PlayerPedId()) then
					SetRichPresence("ID: "..pId.." | "..pName.." itt fut "..StreetName.." utcáin")
				elseif IsPedWalking(PlayerPedId()) then
					SetRichPresence("ID: "..pId.." | "..pName.." itt sétál "..StreetName.." utcáin")
				elseif IsPedStill(PlayerPedId()) then
					SetRichPresence("ID: "..pId.." | "..pName.." itt dekkol "..StreetName.." utcáin")
				end
elseif GetVehiclePedIsUsing(PlayerPedId()) ~= nil and not IsPedInAnyHeli(PlayerPedId()) and not IsPedInAnyPlane(PlayerPedId()) and not IsPedOnFoot(PlayerPedId()) and not IsPedInAnySub(PlayerPedId()) and not IsPedInAnyBoat(PlayerPedId()) then
				local KMH = math.ceil(GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId())) * 3.636936)
				if KMH > 50 then
					SetRichPresence("ID: "..pId.." | "..pName.." épp gyorsan hajt itt "..StreetName.." utcáin "..KMH.."KMH ezzel "..VehName)
				elseif KMH <= 50 and KMH > 0 then
					SetRichPresence("ID: "..pId.." | "..pName.." épp utazik itt "..StreetName.." utcáin "..KMH.."KMH ezzel "..VehName)
				elseif KMH == 0 then
					SetRichPresence("ID: "..pId.." | "..pName.." épp parkol itt "..StreetName.." utcáin ezzel "..VehName)
				end
			elseif IsPedInAnyHeli(PlayerPedId()) or IsPedInAnyPlane(PlayerPedId()) then
				if IsEntityInAir(GetVehiclePedIsUsing(PlayerPedId())) or GetEntityHeightAboveGround(GetVehiclePedIsUsing(PlayerPedId())) > 5.0 then
					SetRichPresence("ID: "..pId.." | "..pName.." épp át repül "..StreetName.." utcái felet ezzel "..VehName)
				else
					SetRichPresence("ID: "..pId.." | "..pName.." épp landol itt "..StreetName.." ezzel "..VehName)
				end
			elseif IsEntityInWater(PlayerPedId()) then
				SetRichPresence("ID: "..pId.." | "..pName.." épp úszik")
			elseif IsPedInAnyBoat(PlayerPedId()) and IsEntityInWater(GetVehiclePedIsUsing(PlayerPedId())) then
				SetRichPresence("ID: "..pId.." | "..pName.." épp hajókázik ezzel "..VehName)
			elseif IsPedInAnySub(PlayerPedId()) and IsEntityInWater(GetVehiclePedIsUsing(PlayerPedId())) then
				SetRichPresence("ID: "..pId.." | "..pName.." épp egy sárga tengeralattjáróban van")
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
        --Application--->Egyik botod--->General Information--->APPLICATION ID(kicsit hosszabb mint amennyitirtam) 
		SetDiscordAppId(1205810310678712340) 

        --Application-->Egyik botod-->Rich Presence--->Art Assets--->Add image--> és beirod ide a nevét amit megadtál
		SetDiscordRichPresenceAsset('mentes')
        

        -- Nagy ikon mit irjon ki ha rá huzod az egeret(példát irtam csak oda) 
        SetDiscordRichPresenceAssetText('Black City RolePlay')
       
        -- Ugyan az legyen mint ami az SetDiscordRichPresenceAsset
        SetDiscordRichPresenceAssetSmall('mentes')

        -- Kicsi ikon mit irjon ki ha rá huzod az egeret(példát irtam) 
        SetDiscordRichPresenceAssetSmallText('Csatlakozz!')


        -- Fejlesztve(2021.07.21) 
       --Cseréld ki az IP szöveget a te szerver ipdre  és működni fog. 
        SetDiscordRichPresenceAction(0, "Csatlakozz!", "fivem://connect/185.221.21.199:30120")
        --https://discord.io/servers itt ha beleirod a sajátod akkor működni fog és egyedi is lehet
        SetDiscordRichPresenceAction(1, "Discord!", "https://discord.gg/black-city-roleplay-672837883144437760")

        -- 
		Citizen.Wait(60000)
	end
end)

--KÉK logo---

--[[local WaitTime = 5000


Citizen.CreateThread(function()
while true do
		local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))))
		if VehName == "NULL" then VehName = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))) end
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
		local StreetHash = GetStreetNameAtCoord(x, y, z)
		local pId = GetPlayerServerId(PlayerId())
		local pName = GetPlayerName(PlayerId())
		local playerCount = #GetActivePlayers()
		Citizen.Wait(WaitTime)
		if StreetHash ~= nil then
			StreetName = GetStreetNameFromHashKey(StreetHash)
			if IsPedOnFoot(PlayerPedId()) and not IsEntityInWater(PlayerPedId()) then
           if IsPedSprinting(PlayerPedId()) then
					SetRichPresence("ID: "..pId.." | "..pName.." rohan "..StreetName..StreetName.." utcáin")
				elseif IsPedRunning(PlayerPedId()) then
					SetRichPresence("ID: "..pId.." | "..pName.." itt fut "..StreetName..StreetName.." utcáin")
				elseif IsPedWalking(PlayerPedId()) then
					SetRichPresence("ID: "..pId.." | "..pName.." itt sétál "..StreetName..StreetName.." utcáin")
				elseif IsPedStill(PlayerPedId()) then
					SetRichPresence("ID: "..pId.." | "..pName.." itt dekkol "..StreetName..StreetName.." utcáin")
				end
elseif GetVehiclePedIsUsing(PlayerPedId()) ~= nil and not IsPedInAnyHeli(PlayerPedId()) and not IsPedInAnyPlane(PlayerPedId()) and not IsPedOnFoot(PlayerPedId()) and not IsPedInAnySub(PlayerPedId()) and not IsPedInAnyBoat(PlayerPedId()) then
				local KMH = math.ceil(GetEntitySpeed(GetVehiclePedIsUsing(PlayerPedId())) * 3.636936)
				if KMH > 50 then
					SetRichPresence("ID: "..pId.." | "..pName.." épp gyorsan hajt itt "..StreetName.." utcáin "..KMH.."KMH ezzel "..VehName)
				elseif KMH <= 50 and KMH > 0 then
					SetRichPresence("ID: "..pId.." | "..pName.." épp utazik itt "..StreetName.." utcáin "..KMH.."KMH ezzel "..VehName)
				elseif KMH == 0 then
					SetRichPresence("ID: "..pId.." | "..pName.." épp parkol itt "..StreetName.." utcáin ezzel "..VehName)
				end
			elseif IsPedInAnyHeli(PlayerPedId()) or IsPedInAnyPlane(PlayerPedId()) then
				if IsEntityInAir(GetVehiclePedIsUsing(PlayerPedId())) or GetEntityHeightAboveGround(GetVehiclePedIsUsing(PlayerPedId())) > 5.0 then
					SetRichPresence("ID: "..pId.." | "..pName.." épp át repül "..StreetName.." utcái felet ezzel "..VehName)
				else
					SetRichPresence("ID: "..pId.." | "..pName.." épp landol itt "..StreetName.." ezzel "..VehName)
				end
			elseif IsEntityInWater(PlayerPedId()) then
				SetRichPresence("ID: "..pId.." | "..pName.." épp úszik")
			elseif IsPedInAnyBoat(PlayerPedId()) and IsEntityInWater(GetVehiclePedIsUsing(PlayerPedId())) then
				SetRichPresence("ID: "..pId.." | "..pName.." épp hajókázik ezzel "..VehName)
			elseif IsPedInAnySub(PlayerPedId()) and IsEntityInWater(GetVehiclePedIsUsing(PlayerPedId())) then
				SetRichPresence("ID: "..pId.." | "..pName.." épp egy sárga tengeralattjáróban van")
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
        --Application--->Egyik botod--->General Information--->APPLICATION ID(kicsit hosszabb mint amennyitirtam) 
		SetDiscordAppId(1107675004532953270) 

        --Application-->Egyik botod-->Rich Presence--->Art Assets--->Add image--> és beirod ide a nevét amit megadtál
		SetDiscordRichPresenceAsset('_nvite_backround')
        

        -- Nagy ikon mit irjon ki ha rá huzod az egeret(példát irtam csak oda) 
        SetDiscordRichPresenceAssetText('Black City RolePlay')
       
        -- Ugyan az legyen mint ami az SetDiscordRichPresenceAsset
        SetDiscordRichPresenceAssetSmall('_nvite_backroundddd')

        -- Kicsi ikon mit irjon ki ha rá huzod az egeret(példát irtam) 
        SetDiscordRichPresenceAssetSmallText('Csatlakozz!')


        -- Fejlesztve(2021.07.21) 
       --Cseréld ki az IP szöveget a te szerver ipdre  és működni fog. 
        SetDiscordRichPresenceAction(0, "Csatlakozz!", "fivem://connect/79.172.220.39:30120")
        --https://discord.io/servers itt ha beleirod a sajátod akkor működni fog és egyedi is lehet
        SetDiscordRichPresenceAction(1, "Discord!", "https://discord.gg/blackcityrp")

        -- 
		Citizen.Wait(60000)
	end
end)--]]