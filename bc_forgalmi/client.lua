local isOpen = false
local currentSlot = nil

local function openDocument(metadata, expired, readOnly, slot)
	if isOpen then return end

	isOpen = true
	currentSlot = not readOnly and slot or nil

	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'open',
		readOnly = readOnly or false,
		expired = expired or false,
		fields = metadata or {},
	})
end

local function closeDocument()
	if not isOpen then return end

	isOpen = false
	currentSlot = nil

	SetNuiFocus(false, false)
	SendNUIMessage({ action = 'close' })
end

-- ox_inventory hivja: data/items.lua -> client = { export = 'bc_forgalmi.useForgalmi' }
-- slot = { name = ..., slot = ..., metadata = ... }
-- Az adatokat a szervertol kerjuk el, hogy a lejarat a szerver orajan mulljon.
exports('useForgalmi', function(_, slot)
	if isOpen then return end

	CreateThread(function()
		local doc = lib.callback.await('bc_forgalmi:getDocument', false, slot.slot)

		if not doc then
			return lib.notify({ type = 'error', description = Config.Locale.no_document })
		end

		openDocument(doc.metadata, doc.expired, false, slot.slot)
	end)
end)

-- Masik jatekos mutatja meg (szerver validalta)
RegisterNetEvent('bc_forgalmi:open', function(metadata, expired)
	openDocument(metadata, expired, true)
end)

RegisterNUICallback('close', function(_, cb)
	cb(1)
	closeDocument()
end)

RegisterNUICallback('show', function(_, cb)
	cb(1)

	local slot = currentSlot
	if not slot then return end

	local player = lib.getClosestPlayer(GetEntityCoords(cache.ped), Config.ShowDistance, false)

	if not player then
		return lib.notify({ type = 'error', description = Config.Locale.no_player })
	end

	TriggerServerEvent('bc_forgalmi:showTo', GetPlayerServerId(player), slot)
	lib.notify({ type = 'success', description = Config.Locale.shown })
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() and isOpen then
		SetNuiFocus(false, false)
	end
end)
