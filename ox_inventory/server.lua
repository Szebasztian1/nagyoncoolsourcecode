if not lib then return end

if GetConvar('inventory:versioncheck', 'true') == 'true' then
	lib.versionCheck('overextended/ox_inventory')
end

require 'modules.bridge.server'
require 'modules.pefcl.server'

local TriggerEventHooks = require 'modules.hooks.server'
local db = require 'modules.mysql.server'
local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'

require 'modules.crafting.server'
require 'modules.shops.server'

---@param player table
---@param data table?
--- player requires source, identifier, and name
--- optionally, it should contain jobs/groups, sex, and dateofbirth
function server.setPlayerInventory(player, data)
	while not shared.ready do Wait(0) end

	if not data then
		data = db.loadPlayer(player.identifier)
	end

	local inventory = {}
	local totalWeight = 0

	if type(data) == 'table' then
		local ostime = os.time()

		for _, v in pairs(data) do
			if type(v) == 'number' or not v.count or not v.slot then
				if server.convertInventory then
					inventory, totalWeight = server.convertInventory(player.source, data)
					break
				else
					return error(('Inventory for player.%s (%s) contains invalid data. Ensure you have converted inventories to the correct format.'):format(player.source, GetPlayerName(player.source)))
				end
			else
				local item = Items(v.name)

				if item then
					v.metadata = Items.CheckMetadata(v.metadata or {}, item, v.name, ostime)
					local weight = Inventory.SlotWeight(item, v)
					totalWeight = totalWeight + weight

					inventory[v.slot] = {name = item.name, label = item.label, weight = weight, slot = v.slot, count = v.count, description = item.description, metadata = v.metadata, stack = item.stack, close = item.close}
				end
			end
		end
	end

	player.source = tonumber(player.source)
	local inv = Inventory.Create(player.source, player.name, 'player', shared.playerslots, totalWeight, shared.playerweight, player.identifier, inventory)

	if inv then
		inv.player = server.setPlayerData(player)
		inv.player.ped = GetPlayerPed(player.source)

		if server.syncInventory then server.syncInventory(inv) end
		TriggerClientEvent('ox_inventory:setPlayerInventory', player.source, Inventory.Drops, inventory, totalWeight, inv.player)
	end
end
exports('setPlayerInventory', server.setPlayerInventory)
AddEventHandler('ox_inventory:setPlayerInventory', server.setPlayerInventory)

---@param playerPed number
---@param coordinates vector3|vector3[]
---@param distance? number
---@return vector3|false
local function getClosestStashCoords(playerPed, coordinates, distance)
	local playerCoords = GetEntityCoords(playerPed)

	if not distance then distance = 10 end

	if type(coordinates) == 'table' then
		for i = 1, #coordinates do
			local coords = coordinates[i] --[[@as vector3]]

			if #(coords - playerCoords) < distance then
				return coords
			end
		end

		return false
	end

	return #(coordinates - playerCoords) < distance and coordinates
end

---@param source number
---@param invType string
---@param data? string|number|table
---@param ignoreSecurityChecks boolean?
---@return table | false | nil, table | false | nil, string?
-----------------------------------------------------------------------------------------------
-- Jármű-ládák (csomagtartó, kesztyűtartó) szerveroldali ellenőrzése -- 2026-09-21
--
-- A láda azonosítója 'trunk'/'glove' + rendszám, és ezt a kliens küldi. Mod menüvel a saját
-- autó rendszámát átírva (akár üresre) más játékos ládája volt kifosztható, mielőtt a
-- kliensoldali plate_guard (2 mp-es ciklus) észbe kapott volna. Ezért a szerver a megnyitás
-- pillanatában ellenőriz:
--   1. üres / csak szóköz rendszám -> nem nyílik (különben minden ilyen jármű egy közös
--      ládán osztozna);
--   2. a kért rendszám = a járművön a szerver által látott rendszám, és a jármű
--      VEHICLE_STASH_MAX_DISTANCE-en belül van (hamis netid-del ne lehessen távolról nyitni);
--   3. a rendszám önmagában nem azonosít: tulajdonolt rendszámnál a jármű modellje egyezzen
--      az owned_vehicles-ben tárolttal, és a rendszám ne változzon meg azóta, hogy a jármű
--      "beállt" (VEHICLE_PLATE_SETTLE_MS).
-----------------------------------------------------------------------------------------------

local VEHICLE_STASH_MAX_DISTANCE = 15.0
local VEHICLE_PLATE_SETTLE_MS = 15000

---@param text any
---@return string
local function trimPlate(text)
	return (tostring(text or ''):gsub('^%s+', ''):gsub('%s+$', ''))
end

--- A modell-hash előjelesen és előjel nélkül is előfordul (a kliens előjelesen menti a
--- járműadatba), ezért mindig 32 bites előjel nélküli alakra hozzuk.
---@param value any
---@return integer
local function toHash(value)
	return (math.tointeger(tonumber(value)) or 0) & 0xFFFFFFFF
end

-- [entity] = { model, plate, since, settled, logged }: a jármű rendszáma, ahogy a szerver
-- látja. "Beállt" = VEHICLE_PLATE_SETTLE_MS óta nem változott; a spawnoló scriptek a
-- születés után azonnal beállítják a rendszámot, azt még nem tekintjük cserének.
local vehiclePlates = {}

CreateThread(function()
	while true do
		Wait(2000)
		local now = GetGameTimer()
		local seen = {}

		for _, vehicle in ipairs(GetAllVehicles()) do
			seen[vehicle] = true
			local model = GetEntityModel(vehicle)
			local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
			local rec = vehiclePlates[vehicle]

			if not rec or rec.model ~= model then
				vehiclePlates[vehicle] = { model = model, plate = plate, since = now }
			elseif not rec.settled then
				if rec.plate ~= plate then
					rec.plate, rec.since = plate, now
				elseif now - rec.since >= VEHICLE_PLATE_SETTLE_MS then
					rec.settled = true
				end
			elseif rec.plate ~= plate and not rec.logged then
				rec.logged = true
				local owner = NetworkGetEntityOwner(vehicle)
				print(('^3[ox_inventory] beállt jármű rendszáma lecserélve: "%s" -> "%s" (modell %s, hálózati tulaj: %s [%s])^0')
					:format(rec.plate, plate, model, owner and owner > 0 and GetPlayerName(owner) or '?', owner or '?'))
			end
		end

		for vehicle in pairs(vehiclePlates) do
			if not seen[vehicle] then vehiclePlates[vehicle] = nil end
		end
	end
end)

---@param src number
---@param invType string 'trunk' | 'glovebox'
---@param data table
---@return boolean
local function verifyVehicleStash(src, invType, data)
	local function deny(reason, detail)
		print(('^3[ox_inventory] %s megtagadva: %s | játékos %s [%s] | %s^0')
			:format(invType, reason, GetPlayerName(src) or '?', src, detail or ''))
		return false
	end

	local entity = NetworkGetEntityFromNetworkId(data.netid)
	if not entity or entity <= 0 or not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then
		return deny('nincs ilyen jármű', ('netid %s'):format(tostring(data.netid)))
	end

	local requested = trimPlate(type(data.id) == 'string' and data.id:sub(6) or '')
	local rawPlate = GetVehicleNumberPlateText(entity) or ''
	local actual = trimPlate(rawPlate)

	-- 1. üres rendszám
	if actual == '' or requested == '' then
		return deny('üres rendszám', ('kért "%s", jármű "%s"'):format(requested, actual))
	end

	-- 2. a kért rendszám a járművön lévő legyen, a jármű pedig a közelben
	if requested ~= actual then
		return deny('rendszám-eltérés', ('kért "%s", jármű "%s"'):format(requested, actual))
	end

	local distance = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(entity))
	if distance > VEHICLE_STASH_MAX_DISTANCE then
		return deny('túl messze', ('"%s", %.1f m'):format(actual, distance))
	end

	-- 3a. beállt jármű rendszámát utólag lecserélték
	local rec = vehiclePlates[entity]
	if rec and rec.settled and rec.model == GetEntityModel(entity) and rec.plate ~= actual then
		return deny('utólag lecserélt rendszám', ('eredeti "%s", most "%s"'):format(rec.plate, actual))
	end

	-- 3b. tulajdonolt rendszámnál a jármű modellje egyezzen a tárolttal
	local row = MySQL.single.await('SELECT `vehicle` FROM `owned_vehicles` WHERE `plate` = ? OR `plate` = ? LIMIT 1',
		{ actual, rawPlate })
	if row then
		local ok, props = pcall(json.decode, row.vehicle or '')
		local stored = ok and type(props) == 'table' and props.model
		if stored and toHash(stored) ~= toHash(GetEntityModel(entity)) then
			return deny('modell-eltérés', ('"%s": tárolt %s, jármű %s'):format(actual, stored, GetEntityModel(entity)))
		end
	end

	return true
end

local function openInventory(source, invType, data, ignoreSecurityChecks)
	if Inventory.Lock then return false end

	local left = Inventory(source) --[[@as OxInventory]]
	local right, closestCoords

	-- 'playercontainer' (motozáskor a másik játékos táskája) esetén tudnunk kell, kinél
	-- voltunk épp, mielőtt a closeInventory törli az `open` mezőt.
	local previouslyOpen = left.open

    left:closeInventory(true)
	Inventory.CloseAll(left, source)

    if invType == 'player' and data == source then
        data = nil
    end

	if data then
        local isDataTable = type(data) == 'table'

		if invType == 'stash' then
			right = Inventory(data, left)
			if right == false then return false end
		elseif isDataTable then
			

			if data.netid then
                if invType == 'trunk' then
                    local entity = NetworkGetEntityFromNetworkId(data.netid)
                    local lockStatus = entity > 0 and GetVehicleDoorLockStatus(entity)

                    -- 0: no lock; 1: unlocked; 8: boot unlocked
                    if type(lockStatus) == "number" and lockStatus > 1 and lockStatus ~= 8 then
						--print("zarva 1")
                        return false, false, 'vehicle_locked'
                    end
                end

				-- Jármű-láda: a kliens által küldött rendszám nem dönthet egyedül arról, kinek a ládája nyílik.
				if (invType == 'trunk' or invType == 'glovebox') and not ignoreSecurityChecks
					and not verifyVehicleStash(source, invType, data) then
					return false, false, 'inventory_right_access'
				end

				data.type = invType
				right = Inventory(data)
			elseif invType == 'drop' then
				right = Inventory(data.id)
			else
				if invType == "trunk" and not data.netid then 
					local ply = server.GetPlayerFromId(source)
					local plate = data.id:sub(6)
					local res = MySQL.prepare.await("SELECT plate FROM `owned_vehicles` WHERE `plate` = ? AND `owner` = ? AND `job` = ?", { plate, ply.identifier, "civ" })
					if not res then 
						--print("zarva 2", res, plate, ply.identifier, "civ")
						return  false, false, 'vehicle_locked'
					end 
					right = Inventory(data)
				else 
					return
				end 
				
			end
		elseif invType == 'policeevidence' then
			if server.hasGroup(left, shared.police) then
				right = Inventory(('evidence-%s'):format(data))
			end
		elseif invType == 'dumpster' then
			---@cast data string
			right = Inventory(data)

			if not right then
				local netid = tonumber(data:sub(9))

				-- dumpsters do not work with entity lockdown. need to rewrite, but having to do
				-- distance checks to some ~7000 dumpsters and freeze the entities isn't ideal
				if netid and NetworkGetEntityFromNetworkId(netid) > 0 then
					right = Inventory.Create(data, locale('dumpster'), invType, 15, 0, 100000, false)
				end
			end
		elseif invType == 'container' then
			left.containerSlot = data --[[@as number]]
			left.containerOwner = nil
			data = left.items[data]

			if data then
				right = Inventory(data.metadata.container)

				if not right then
					right = Inventory.Create(data.metadata.container, data.label, invType, data.metadata.size[1], 0, data.metadata.size[2], false)
				end
			else left.containerSlot = nil end
		elseif invType == 'playercontainer' then
			-- Motozás: a MOTOZOTT játékos táskájának kinyitása. Csak akkor engedjük, ha
			-- épp az ő inventoryja volt nyitva, és még mellette állunk.
			local target = previouslyOpen and Inventory(previouslyOpen) --[[@as OxInventory?]]

			if not target or not target.player or target.id == left.id then return end

			if not ignoreSecurityChecks then
				local targetCoords = GetEntityCoords(GetPlayerPed(target.id))
				local sourceCoords = GetEntityCoords(GetPlayerPed(source))

				if #(targetCoords - sourceCoords) > 3.0 then return false, false, 'inventory_right_access' end
			end

			local slotId = data --[[@as number]]
			local slotData = type(slotId) == 'number' and target.items[slotId]

			if not slotData or not slotData.metadata?.container then return end

			left.containerSlot = slotId
			left.containerOwner = target.id
			data = slotData
			right = Inventory(slotData.metadata.container)

			if not right then
				right = Inventory.Create(slotData.metadata.container, slotData.label, 'container', slotData.metadata.size[1], 0, slotData.metadata.size[2], false)
			end
		else right = Inventory(data) end

		if not right then return end

		if not ignoreSecurityChecks and right.groups and not server.hasGroup(left, right.groups) then return end

		local hookPayload = {
			source = source,
			inventoryId = right.id,
			inventoryType = right.type,
		}

		if invType == 'container' or invType == 'playercontainer' then hookPayload.slot = left.containerSlot end
		if isDataTable and data.netid then hookPayload.netId = data.netid end

		if not TriggerEventHooks('openInventory', hookPayload) then return end

        if left == right then return end

		if right.player then
			if right.open then return end

			right.coords = not ignoreSecurityChecks and GetEntityCoords(right.player.ped) or nil
		end

		if not ignoreSecurityChecks and right.coords then
			closestCoords = getClosestStashCoords(left.player.ped, right.coords)

			if not closestCoords then return end
		end

		left:openInventory(right)
	else
		left:openInventory(left)
	end

	return {
		id = left.id,
		label = left.label,
		type = left.type,
		slots = left.slots,
		weight = left.weight,
		maxWeight = left.maxWeight
	}, right and {
		id = right.id,
		label = right.player and '' or right.label,
		type = right.player and 'otherplayer' or right.type,
		slots = right.slots,
		weight = right.weight,
		maxWeight = right.maxWeight,
		items = right.items,
		coords = closestCoords or right.coords,
		distance = right.distance
	}
end

---@param source number
---@param invType string
---@param data string|number|table
lib.callback.register('ox_inventory:openInventory', function(source, invType, data)
	return openInventory(source, invType, data)
end)

---@param netId number
lib.callback.register('ox_inventory:isVehicleATrailer', function(source, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local retval = GetVehicleType(entity)
	return retval == 'trailer'
end)

---@param playerId number
---@param invType string
---@param data string|number|table
exports('forceOpenInventory', function(playerId, invType, data)
	local left, right = openInventory(playerId, invType, data, true)

	if left and right then
		TriggerClientEvent('ox_inventory:forceOpenInventory', playerId, left, right)
		return right.id
	end
end)

local Licenses = lib.load('data.licenses')

lib.callback.register('ox_inventory:buyLicense', function(source, id)
	local license = Licenses[id]
	if not license then return end

	local inventory = Inventory(source)
	if not inventory then return end

	return server.buyLicense(inventory, license)
end)

lib.callback.register('ox_inventory:getItemCount', function(source, item, metadata, target)
	local inventory = target and Inventory(target) or Inventory(source)
	return (inventory and Inventory.GetItem(inventory, item, metadata, true)) or 0
end)

lib.callback.register('ox_inventory:getInventory', function(source, id)
	local inventory = Inventory(id or source)
	return inventory and {
		id = inventory.id,
		label = inventory.label,
		type = inventory.type,
		slots = inventory.slots,
		weight = inventory.weight,
		maxWeight = inventory.maxWeight,
		owned = inventory.owner and true or false,
		items = inventory.items
	}
end)

RegisterNetEvent('ox_inventory:usedItemInternal', function(slot)
    local inventory = Inventory(source)

    if not inventory then return end

    local item = inventory.usingItem

    if not item or item.slot ~= slot then
        ---@todo
        DropPlayer(inventory.id, 'sussy')

        return
    end

    TriggerEvent('ox_inventory:usedItem', inventory.id, item.name, item.slot, next(item.metadata) and item.metadata)

    inventory.usingItem = nil
end)

---@param source number
---@param itemName string
---@param slot number?
---@param metadata { [string]: any }?
---@return table | boolean | nil
---@

local FOODS = {
  ["water"] = 60 * 60 * 24 * 14,
  ["bread"] = 60 * 60 * 24 * 14,
  ["champagne"] = 60 * 60 * 24 * 14,
  ["pepsi"] = 60 * 60 * 24 * 14,
  ["cola"] = 60 * 60 * 24 * 14,
  ["hotdog"] = 60 * 60 * 24 * 14,
  ["upreggeli"] = 60 * 60 * 24 * 14,
  ["urizs"] = 60 * 60 * 24 * 14,
  ["upmenu"] = 60 * 60 * 24 * 14,
  ["lassagne"] = 60 * 60 * 24 * 14,
  ["profit"] = 60 * 60 * 24 * 14,
  ["minest"] = 60 * 60 * 24 * 14,
  ["fank"] = 60 * 60 * 24 * 14,
  ["hagyma"] = 60 * 60 * 24 * 14,
  ["haribo"] = 60 * 60 * 24 * 14,
  ["kolbasz"] = 60 * 60 * 24 * 14,
  ["husimado"] = 60 * 60 * 24 * 14,
  ["4sajtos"] = 60 * 60 * 24 * 14,
  ["margapizza"] = 60 * 60 * 24 * 14,
  ["magyarospizza"] = 60 * 60 * 24 * 14,
  ["hawaipizza"] = 60 * 60 * 24 * 14,
  ["langos"] = 60 * 60 * 24 * 14,
  ["lays"] = 60 * 60 * 24 * 14,
  ["ramen"] = 60 * 60 * 24 * 14,
  ["antiblackbox"] = 60 * 60 * 24 * 14,
  ["hamburger"] = 60 * 60 * 24 * 14,
  ["cookedmeat"] = 60 * 60 * 24 * 14,
  ["weed_cookie"] = 60 * 60 * 24 * 14,
  ["muffin"] = 60 * 60 * 24 * 14,
  ["zsiroskenyer"] = 60 * 60 * 24 * 14,
  ["hurka"] = 60 * 60 * 24 * 14,
  ["amfk"] = 60 * 60 * 24 * 14,
  ["brownie"] = 60 * 60 * 24 * 14,
  ["smuffin"] = 60 * 60 * 24 * 14,
  ["oretor"] = 60 * 60 * 24 * 14,
  ["jegeskavec"] = 60 * 60 * 24 * 14,
  ["naracslee"] = 60 * 60 * 24 * 14,
  ["msmcs"] = 60 * 60 * 24 * 14,
  ["mcffem"] = 60 * 60 * 24 * 14,
  ["fetort"] = 60 * 60 * 24 * 14,
  ["mcshse"] = 60 * 60 * 24 * 14,
  ["macaron"] = 60 * 60 * 24 * 14,
  ["epressajttorta"] = 60 * 60 * 24 * 14,
  ["cocacola"] = 60 * 60 * 24 * 14,
  ["fshake"] = 60 * 60 * 24 * 14,
  ["bshake"] = 60 * 60 * 24 * 14,
  ["gymei"] = 60 * 60 * 24 * 14,
  ["csshake"] = 60 * 60 * 24 * 14,
  ["fcsoki"] = 60 * 60 * 24 * 14,
  ["fanta"] = 60 * 60 * 24 * 14,
  ["mjuice"] = 60 * 60 * 24 * 14,
  ["kcsiga"] = 60 * 60 * 24 * 14,
  ["water"] = 60 * 60 * 24 * 14,
  ["redbull"] = 60 * 60 * 24 * 14,
  ["monster"] = 60 * 60 * 24 * 14,
  ["cappuccino"] = 60 * 60 * 24 * 14,
  ["espresso"] = 60 * 60 * 24 * 14,
  ["jegeskave"] = 60 * 60 * 24 * 14,
  ["limonade"] = 60 * 60 * 24 * 14,
  ["matchatea"] = 60 * 60 * 24 * 14,
  ["gyulyasleves"] = 60 * 60 * 24 * 14,
  ["paradicsomleves"] = 60 * 60 * 24 * 14,
  ["halaszle"] = 60 * 60 * 24 * 14,
  ["tyukhusleves"] = 60 * 60 * 24 * 14,
  ["marhaporkolt"] = 60 * 60 * 24 * 14,
  ["toltottkaposzta"] = 60 * 60 * 24 * 14,
  ["rantottszelet"] = 60 * 60 * 24 * 14,
  ["rantotta"] = 60 * 60 * 24 * 14,
  ["bundaskenyer"] = 60 * 60 * 24 * 14,
  ["langos"] = 60 * 60 * 24 * 14,
  ["rakott_krumpli"] = 60 * 60 * 24 * 14,
  ["rantott_sajt"] = 60 * 60 * 24 * 14,
  ["turos_teszta"] = 60 * 60 * 24 * 14,
  ["somloigaluska"] = 60 * 60 * 24 * 14,
  ["zserbo"] = 60 * 60 * 24 * 14,
  ["palacsinta"] = 60 * 60 * 24 * 14,
  ["tiramisu"] = 60 * 60 * 24 * 14,
  ["aranygaluska"] = 60 * 60 * 24 * 14,
  ["bannans"] = 60 * 60 * 24 * 14,
  ["cezarsali"] = 60 * 60 * 24 * 14,
  ["cpecsenye"] = 60 * 60 * 24 * 14,
  ["fagylaltkehely"] = 60 * 60 * 24 * 14,
  ["halaszle"] = 60 * 60 * 24 * 14,
  ["hotdog"] = 60 * 60 * 24 * 14,
  ["raksalata"] = 60 * 60 * 24 * 14,
  ["rostely"] = 60 * 60 * 24 * 14,
  ["yallowcoronasor"] = 60 * 60 * 24 * 14,
  ["yellowwhisky"] = 60 * 60 * 24 * 14,
  ["yellowvodka"] = 60 * 60 * 24 * 14,
  ["yellownaracsle"] = 60 * 60 * 24 * 14,
  ["yellowlimonade"] = 60 * 60 * 24 * 14,
  ["yellowcola"] = 60 * 60 * 24 * 14,
  ["yellowbbyribs"] = 60 * 60 * 24 * 14,
  ["beleskedvence"] = 60 * 60 * 24 * 14,
  ["yellowtaco"] = 60 * 60 * 24 * 14,
  ["yellowhotdog"] = 60 * 60 * 24 * 14,
  ["tako"] = 60 * 60 * 24 * 14,
  ["tonhalaspizza"] = 60 * 60 * 24 * 14,
  ["pizza"] = 60 * 60 * 24 * 14,
  ["sajtgombocleves"] = 60 * 60 * 24 * 14,
  ["mouldybread"] = 60 * 60 * 24 * 14,
  ["tokospite"] = 60 * 60 * 24 * 14,
  ["smallbrother"] = 60 * 60 * 24 * 14,
  ["soaburger"] = 60 * 60 * 24 * 14,
  ["oldnorth"] = 60 * 60 * 24 * 14,
  ["soaproni"] = 60 * 60 * 24 * 14,
  ["buffalotrace"] = 60 * 60 * 24 * 14,
  ["gyombereskinley"] = 60 * 60 * 24 * 14,
  ["lattemachiato"] = 60 * 60 * 24 * 14,
  ["babgulyasleves"] = 60 * 60 * 24 * 14,
  ["cordonblue"] = 60 * 60 * 24 * 14,
  ["epermocktail"] = 60 * 60 * 24 * 14,
  ["franciakremes"] = 60 * 60 * 24 * 14,
  ["zebrasteak"] = 60 * 60 * 24 * 14,
  ["csokisshakenespresso"] = 60 * 60 * 24 * 14,
  ["cabarnetsauvignon"] = 60 * 60 * 24 * 14,
  ["dewmountaindew"] = 60 * 60 * 24 * 14,
  ["sprite"] = 60 * 60 * 24 * 14,
  ["kakao"] = 60 * 60 * 24 * 14,
  ["kubu"] = 60 * 60 * 24 * 14,
  ["tea"] = 60 * 60 * 24 * 14,
  ["cappy"] = 60 * 60 * 24 * 14,
  ["siocappuchino"] = 60 * 60 * 24 * 14,
  ["kave"] = 60 * 60 * 24 * 14,
  ["ayran"] = 60 * 60 * 24 * 14,
  ["bloodymary"] = 60 * 60 * 24 * 14,
  ["cuba"] = 60 * 60 * 24 * 14,
  ["icetea"] = 60 * 60 * 24 * 14,
  ["itea"] = 60 * 60 * 24 * 14,
  ["mojito"] = 60 * 60 * 24 * 14,
  ["pinacola"] = 60 * 60 * 24 * 14,
  ["rumoskola"] = 60 * 60 * 24 * 14,
  ["sexonbeach"] = 60 * 60 * 24 * 14,
  ["tputony"] = 60 * 60 * 24 * 14,
  ["whiskycola"] = 60 * 60 * 24 * 14,
  ["aranyaszok"] = 60 * 60 * 24 * 14,
  ["soproni"] = 60 * 60 * 24 * 14,
  ["bor"] = 60 * 60 * 24 * 14,
  ["torleypezsgo"] = 60 * 60 * 24 * 14,
  ["beer"] = 60 * 60 * 24 * 14,
  ["jager"] = 60 * 60 * 24 * 14,
  ["palinka"] = 60 * 60 * 24 * 14,
  ["milkshake"] = 60 * 60 * 24 * 14,
  ["smoothie"] = 60 * 60 * 24 * 14,
  ["chukkasalata"] = 60 * 60 * 24 * 14,
  ["domino"] = 60 * 60 * 24 * 14,
  ["ebiamai"] = 60 * 60 * 24 * 14,
  ["ebimiso"] = 60 * 60 * 24 * 14,
  ["kawaii"] = 60 * 60 * 24 * 14,
  ["kyodai"] = 60 * 60 * 24 * 14,
  ["laksa"] = 60 * 60 * 24 * 14,
  ["makifuagra"] = 60 * 60 * 24 * 14,
  ["makirainbow"] = 60 * 60 * 24 * 14,
  ["makiwasabiko"] = 60 * 60 * 24 * 14,
  ["megumisan"] = 60 * 60 * 24 * 14,
  ["midori"] = 60 * 60 * 24 * 14,
  ["nabeudon"] = 60 * 60 * 24 * 14,
  ["padthai"] = 60 * 60 * 24 * 14,
  ["planetset"] = 60 * 60 * 24 * 14,
  ["premiumset"] = 60 * 60 * 24 * 14,
  ["tomkha"] = 60 * 60 * 24 * 14,
  ["toriharumaki"] = 60 * 60 * 24 * 14,
  ["torimisosarada"] = 60 * 60 * 24 * 14,
  ["whiteorchid"] = 60 * 60 * 24 * 14,
  ["borutogranatalmas"] = 60 * 60 * 24 * 14,
  ["hatakosengorogdinnyeramuneszoda"] = 60 * 60 * 24 * 14,
  ["iichiko"] = 60 * 60 * 24 * 14,
  ["machetee"] = 60 * 60 * 24 * 14,
  ["ozekishake"] = 60 * 60 * 24 * 14,
  ["saka"] = 60 * 60 * 24 * 14,
  ["senchatea"] = 60 * 60 * 24 * 14,
  ["soju"] = 60 * 60 * 24 * 14,
  ["zoldtea"] = 60 * 60 * 24 * 14,
  ["steak"] = 60 * 60 * 24 * 14,
  ["tatratea"] = 60 * 60 * 24 * 14,
  ["drpepper"] = 60 * 60 * 24 * 14,
  ["cappystrawberry"] = 60 * 60 * 24 * 14,
  ["rum"] = 60 * 60 * 24 * 14,
  ["wine"] = 60 * 60 * 24 * 14,
  ["orangelimonade"] = 60 * 60 * 24 * 14,
  ["fishandchips"] = 60 * 60 * 24 * 14,
  ["fishsoup"] = 60 * 60 * 24 * 14,
  ["fegyverterv"] = 60 * 60 * 24 * 14,
  ["fegyverterv2"] = 60 * 60 * 24 * 14,
  ["fegyverterv3"] = 60 * 60 * 24 * 14,
  ["fegyverterv4"] = 60 * 60 * 24 * 14,
  ["fegyverterv5"] = 60 * 60 * 24 * 14,
  ["fegyverterv6"] = 60 * 60 * 24 * 14,
  ["fegyverterv7"] = 60 * 60 * 24 * 14,

  ["homar"] = 60 * 60 * 24 * 14,
  ["sushi"] = 60 * 60 * 24 * 14,
  ["kaviar"] = 60 * 60 * 24 * 14,
  ["kiralyrak"] = 60 * 60 * 24 * 14,
  ["osztriga"] = 60 * 60 * 24 * 14,
  ["rantotthus"] = 60 * 60 * 24 * 14,
  ["kokuszviz"] = 60 * 60 * 24 * 14,
  ["kinleytonic"] = 60 * 60 * 24 * 14,
  ["vodkaredbull"] = 60 * 60 * 24 * 14,
  ["jamesonwhiskey"] = 60 * 60 * 24 * 14,
  ["bacardirum"] = 60 * 60 * 24 * 14,
  ["pilsnersor"] = 60 * 60 * 24 * 14,
  ["fank"] = 60 * 60 * 24 * 14,
  ["churros"] = 60 * 60 * 24 * 14,
  ["bubbletea"] = 60 * 60 * 24 * 14,
  ["topjoy"] = 60 * 60 * 24 * 14,
  ["mentoscukor"] = 60 * 60 * 24 * 1,

  ["itbonbon"] = 60 * 60 * 24 * 14,
  ["itenergydrink"] = 60 * 60 * 24 * 14,
  ["itkokuszgolyo"] = 60 * 60 * 24 * 14,
  ["itbananashake"] = 60 * 60 * 24 * 14,
  ["zabkasa"] = 60 * 60 * 24 * 1,
  ["egeszsegessahke"] = 60 * 60 * 24 * 1,

  ["mcfish"] = 60 * 60 * 24 * 14,
  ["bigmac"] = 60 * 60 * 24 * 14,
  ["chicken"] = 60 * 60 * 24 * 14,
  ["mcflurrymm"] = 60 * 60 * 24 * 14,
  ["nagyburgonya"] = 60 * 60 * 24 * 14,
  ["mccrips"] = 60 * 60 * 24 * 14,
  ["falmaspite"] = 60 * 60 * 24 * 14,
  ["kisburgonya"] = 60 * 60 * 24 * 14,
  ["dsajtburger"] = 60 * 60 * 24 * 14,
  ["sonkastost"] = 60 * 60 * 24 * 14,
  ["smcfarm"] = 60 * 60 * 24 * 14,
  ["csalata"] = 60 * 60 * 24 * 14,
  ["sajtburger"] = 60 * 60 * 24 * 14,
  ["mcfreezecs"] = 60 * 60 * 24 * 14,
  ["cnuggets"] = 60 * 60 * 24 * 14,
}

lib.callback.register('ox_inventory:useItem', function(source, itemName, slot, metadata, noAnim)
	local inventory = Inventory(source) --[[@as OxInventory]]

	if inventory.player then
		local item = Items(itemName)
		local data = item and (slot and inventory.items[slot] or Inventory.GetSlotWithItem(inventory, item.name, metadata, true))

		if not data then return end

		slot = data.slot
		local durability = data.metadata.durability --[[@as number|boolean|nil]]
		local consume = item.consume
		local label = data.metadata.label or item.label

		--[[print("usedata")
		print(slot)
		print(durability)
		print(consume)
		print(label)]]
		if durability and durability > 100 then
			local ostime = os.time()

			if ostime > durability then
				if not FOODS[item.name] then 
					--Items.UpdateDurability(inventory, data, item, 0)
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
				else 
					TriggerClientEvent("bc:poisonedfood", source, item.name)
				end
			end
		end
		if durability and durability <= 0 then 
			if item.name ~= "WEAPON_PETROLCAN" then 
				if not FOODS[item.name] then 
					--Items.UpdateDurability(inventory, data, item, 0)
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
				else 
					TriggerClientEvent("bc:poisonedfood", source, item.name)
				end
		
			end 
		end 

		if durability and consume then
			if durability > 100 then
				local ostime = os.time()

				if ostime > durability then
                    Items.UpdateDurability(inventory, data, item, 0)
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
				elseif consume ~= 0 and consume < 1 then
					local degrade = (data.metadata.degrade or item.degrade) * 60
					local percentage = ((durability - ostime) * 100) / degrade

					if percentage < consume * 100 then
						return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('not_enough_durability', label) })
					end
				end
			elseif durability <= 0 then
				if item.name ~= "WEAPON_PETROLCAN" then
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
				end 
			elseif consume ~= 0 and consume < 1 and durability < consume * 100 then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('not_enough_durability', label) })
			end

			if data.count > 1 and consume < 1 and consume > 0 and not Inventory.GetEmptySlot(inventory) then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('cannot_use', label) })
			end
		end

		if item and data and data.count > 0 and data.name == item.name then
			data = {name=data.name, label=label, count=data.count, slot=slot, metadata=data.metadata, weight=data.weight}

			if item.weapon then 
				--[[if item.ammoname == "rifle_ammo" then 
					local fff = false 
					local found = Inventory.Search(source, 'slots', "licensecard", {mcard="weaponlicense"})
					if not found or #found < 1 then 
						return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = "Ehhez fegyverengedélyre van szükséged!" })
					end 
					for i=1, #found do 
						local slotid = found[i]
						local slot = Inventory.GetSlot(source, slotid)
						if slot and slot.metadata and slot.metadata.exp and slot.metadata.exp > os.time() then 
							fff = true 
						end 
					end 

					if not fff then 
						return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = "Ehhez fegyverengedélyre van szükséged!" })
					end 
				end ]]

			
				if data.metadata.componenttimes then 
					for id, time in pairs(data.metadata.componenttimes) do 
						if time < (os.time() - 60*5) then 
							local modmeta = data.metadata
							table.remove(modmeta.components, id)
							modmeta.componenttimes[id] = nil
							data.weight = Inventory.SlotWeight(item, data)
							
							Inventory.SetMetadata(source, slot, modmeta)

							inventory.changed = true

							inventory:syncSlotsWithPlayer({
								{ item = data }
							}, inventory.weight)
							if server.syncInventory then server.syncInventory(inventory) end
							return false 
						end 
					end 
				end 
			end 

			if item.ammo then
				if inventory.weapon then
					local weapon = inventory.items[inventory.weapon]

					if weapon and weapon?.metadata.durability > 0 then
						consume = nil
					end
				else return false end
			elseif item.component or item.tint then
				consume = 1
				data.component = true
			elseif consume then
				if data.count >= consume then
					local result = item.cb and item.cb('usingItem', item, inventory, slot)

					if result == false then return end

					if result ~= nil then
						data.server = result
					end
				else
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('item_not_enough', item.name) })
				end
			elseif not item.weapon and server.UseItem then
                inventory.usingItem = data
				-- This is used to call an external useItem function, i.e. ESX.UseItem / QBCore.Functions.CanUseItem
				-- If an error is being thrown on item use there is no internal solution. We previously kept a list
				-- of usable items which led to issues when restarting resources (for obvious reasons), but config
				-- developers complained the inventory broke their items. Safely invoking registered item callbacks
				-- should resolve issues, i.e. https://github.com/esx-framework/esx-legacy/commit/9fc382bbe0f5b96ff102dace73c424a53458c96e
				return pcall(server.UseItem, source, data.name, data)
			end

			data.consume = consume

            ---@type boolean
			local success = lib.callback.await('ox_inventory:usingItem', source, data, noAnim)

			if item.weapon then
				inventory.weapon = success and slot or nil
			end

			if not success then return end

            inventory.usingItem = data

			if consume and consume ~= 0 and not data.component then
				data = inventory.items[data.slot]

				if not data then return end

				durability = consume ~= 0 and consume < 1 and data.metadata.durability --[[@as number | false]]

				if durability then
					if durability > 100 then
						local degrade = (data.metadata.degrade or item.degrade) * 60
						durability -= degrade * consume
					else
						durability -= consume * 100
					end

					if data.count > 1 then
						local emptySlot = Inventory.GetEmptySlot(inventory)

						if emptySlot then
							local newItem = Inventory.SetSlot(inventory, item, 1, table.deepclone(data.metadata), emptySlot)

							if newItem then
                                Items.UpdateDurability(inventory, newItem, item, durability)
							end
						end

						durability = 0
					else
                        Items.UpdateDurability(inventory, data, item, durability)
					end

					if durability <= 0 then
						durability = false
					end
				end

				if not durability then
					Inventory.RemoveItem(inventory.id, data.name, consume < 1 and 1 or consume, nil, data.slot)
				else
					inventory.changed = true

					if server.syncInventory then server.syncInventory(inventory) end
				end

				if item?.cb then
					item.cb('usedItem', item, inventory, data.slot)
				end
			end

			return true
		end
	end
end)

local function conversionScript()
	shared.ready = false

	local file = 'setup/convert.lua'
	local import = LoadResourceFile(shared.resource, file)
	local func = load(import, ('@@%s/%s'):format(shared.resource, file)) --[[@as function]]

	conversionScript = func()
end

RegisterCommand('convertinventory', function(source, args)
	if source ~= 0 then return warn('This command can only be executed with the server console.') end
	if type(conversionScript) == 'function' then conversionScript() end
	local arg = args[1]

	local convert = arg and conversionScript[arg]

	if not convert then
		return warn('Invalid conversion argument. Valid options: esx, esxproperty, qb, linden')
	end

	CreateThread(convert)
end, true)


lib.addCommand({'additem', 'giveitem'}, {
	help = 'Gives an item to a player with the given id',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to receive the item' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of the item to give', optional = true },
		{ name = 'type', help = 'Sets the "type" metadata to the value', optional = true },
	},
	restricted = 'group.superadmin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local count = args.count or 1
		local success, response = Inventory.AddItem(inventory, item.name, count, args.type and { type = tonumber(args.type) or args.type })

		if not success then
			return Citizen.Trace(('Failed to give %sx %s to player %s (%s)'):format(count, item.name, args.target, response))
		end
        
		
		source = Inventory(source) or { label = 'console', owner = 'console' }

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" gave %sx %s to "%s"'):format(source.label, count, item.name, inventory.label))
		end

		local tarstring = args.target
		if type(args.target) or tonumber(args.target) then 
			tarstring = args.target .. " | " .. GetPlayerName(args.target)
		end
		local needstag = false 
		if item.name  == "money" and count > 1000000000 then 
			needstag = true 
		end 
		TriggerEvent('esx:toDiscord', (needstag and "@everyone" or "")..'```diff\n- ITEM ADDOLÁS\n```\n```css\n [ADMIN]: '..(GetPlayerName(source) or source)..'\n[ITEM]: '..item.name..'\n[MENNYISÉG]: '..count..'\n[PLAYER]: '..tarstring..'```', 'https://discord.com/api/webhooks/1391182044335177888/pfgnJi8A29HVSftABVV8yf0l9Tj32T_HwMPvnpIQXTd8DbIxYPgHpsmgwoogvBv5siIo')

	end
end)

lib.addCommand('removeitem', {
	help = 'Removes an item to a player with the given id',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to remove the item from' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of the item to take' },
		{ name = 'type', help = 'Only remove items with a matching metadata "type"', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item and args.count > 0 then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local success, response = Inventory.RemoveItem(inventory, item.name, args.count, args.type and { type = tonumber(args.type) or args.type }, nil, true)

		if not success then
			return Citizen.Trace(('Failed to remove %sx %s from player %s (%s)'):format(args.count, item.name, args.target, response))
		end

		source = Inventory(source) or {label = 'console', owner = 'console'}

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" removed %sx %s from "%s"'):format(source.label, args.count, item.name, inventory.label))
		end
	end
end)

lib.addCommand('setitem', {
	help = 'Sets the item count for a player, removing or adding as needed',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to set the items for' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of items to set', optional = true },
		{ name = 'type', help = 'Add or remove items with the metadata "type"', optional = true },
	},
	restricted = 'group.superadmin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local success, response = Inventory.SetItem(inventory, item.name, args.count or 0, args.type and { type = tonumber(args.type) or args.type })

		if not success then
			return Citizen.Trace(('Failed to set %s count to %sx for player %s (%s)'):format(item.name, args.count, args.target, response))
		end

		source = Inventory(source) or {label = 'console', owner = 'console'}

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" set "%s" %s count to %sx'):format(source.label, inventory.label, item.name, args.count))
		end
	end
end)

lib.addCommand('clearevidence', {
	help = 'Clears a police evidence locker with the given id',
	params = {
		{ name = 'locker', type = 'number', help = 'The locker id to clear' },
	},
}, function(source, args)
	if not server.isPlayerBoss then return end

	local inventory = Inventory(source)
	local group, grade = server.hasGroup(inventory, shared.police)
	local hasPermission = group and server.isPlayerBoss(source, group, grade)

	if hasPermission then
		MySQL.query('DELETE FROM ox_inventory WHERE name = ?', {('evidence-%s'):format(args.locker)})
	end
end)

lib.addCommand('takeinv', {
	help = 'Confiscates the target inventory, to restore with /restoreinv',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to confiscate items from' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.Confiscate(args.target)
end)

lib.addCommand({'restoreinv', 'returninv'}, {
	help = 'Restores a previously confiscated inventory for the target',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to restore items to' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.Return(args.target)
end)

lib.addCommand('clearinv', {
	help = 'Wipes all items from the target inventory',
	params = {
		{ name = 'invId', help = 'The inventory to wipe items from' },
	},
	restricted = 'group.admin4',
}, function(source, args)
	Inventory.Clear(tonumber(args.invId) or args.invId == 'me' and source or args.invId)
end)

lib.addCommand('saveinv', {
	help = 'Save all pending inventory changes to the database',
	params = {
		{ name = 'lock', help = 'Lock inventory access, until restart or saved without a lock', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.SaveInventories(args.lock == 'true', false)
end)

lib.addCommand('viewinv', {
	help = 'Inspect the target inventory without allowing interactions',
	params = {
		{ name = 'invId', help = 'The inventory to inspect' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.InspectInventory(source, tonumber(args.invId) or args.invId)
end)
