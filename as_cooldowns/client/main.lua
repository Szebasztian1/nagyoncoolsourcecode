ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

function GetCooldown(cb, type, format)
	ESX.TriggerServerCallback('as_cooldowns:getCooldown', function(cooldown)
		cb(cooldown)
	end, type, format)
end

function GetTime(cb, type, format)
	ESX.TriggerServerCallback('as_cooldowns:getTime', function(time)
		cb(time)
	end, type, format)
end

RegisterNetEvent('as_cooldowns:getCooldown')
AddEventHandler('as_cooldowns:getCooldown', function(cb, type, format)
	GetCooldown(function(cooldown)
		cb(cooldown)
	end, type, format)
end)

RegisterNetEvent('as_cooldowns:getTime')
AddEventHandler('as_cooldowns:getTime', function(cb, type, format)
	GetTime(function(cooldown)
		cb(cooldown)
	end, type, format)
end)

if Config.Debug then
	RegisterCommand('testgetcooldown', function(source, args, rawCommand)
		GetCooldown(function(cooldown)
			print(cooldown)
		end, args[1], args[2])
	end, false)
	
	RegisterCommand('testgettime', function(source, args, rawCommand)
		GetTime(function(time)
			print(time)
		end, args[1], args[2])
	end, false)
end


RegisterNetEvent('as_cooldowns:getRobberies')
AddEventHandler('as_cooldowns:getRobberies', function(cb, type, format)
	ESX.TriggerServerCallback('as_cooldowns:getrob', function(cooldown)
		cb(cooldown)
	end)
end)


-- A jutalom-zóna jelzése állapotváltásra megy ki, nem minden ciklusban: a
-- korábbi változat 0,5 mp-enként küldött értesítést 10 percen át (rablásonként
-- ~1200 db), és minden rablás új szálat indított, így párhuzamos zónáknál
-- többszörösen spammelt.
local rewZones = {}

RegisterNetEvent("bc:policerewzone", function(c, rad, tim)
	-- A hibás szerverhívás korábban a coords-ot tette a rad helyére; ha megint
	-- félrecsúsznak az argumentumok, inkább ne induljon el a szál.
	if not c or type(rad) ~= "number" then
		return
	end

	local key = string.format("%.1f:%.1f:%.1f", c.x, c.y, c.z)

	-- Ugyanarra a pontra ne induljon második szál (ismételt esemény vagy két
	-- rablás egy helyen), csak az érvényesség tolódjon ki.
	if rewZones[key] then
		rewZones[key].expires = GetGameTimer() + (10*60000)
		return
	end

	local zone = { expires = GetGameTimer() + (10*60000), inside = false }
	rewZones[key] = zone

	CreateThread(function()
		while GetGameTimer() < zone.expires do
			local dist = #(GetEntityCoords(PlayerPedId()) - c)

			-- Kilépéshez 15 méterrel nagyobb sugár kell, különben a zóna
			-- szélén álldogálva oda-vissza billegne az üzenet.
			local inside = zone.inside and dist < (rad + 15.0) or dist < rad

			if inside ~= zone.inside then
				zone.inside = inside
				if inside then
					TriggerEvent("esx:showNotification", "Rablás közeli területre értél, maradj a rablás közelében eddig: "..tim..", hogy megkapd a jutalmad")
				else
					TriggerEvent("esx:showNotification", "Elhagytad a rablás területét, eddig térj vissza a jutalomért: "..tim)
				end
			end

			Wait(1000)
		end

		rewZones[key] = nil
	end)
end)

