-- Sub-flow: the one BC Küldetések panel. Tasks and achievements share it: every open asks the
-- server for fresh task progress (client/client.lua) and a fresh achievement view, hands both to
-- the NUI and gives the mouse back on close.

local open = false

local function Notify(message)
	lib.notify({ title = 'Küldetések', description = message, type = 'inform', duration = 4000 })
end

-- page: daily | weekly | permanent (tasks), overview | list | map | leaderboard | stats (achievements)
local function OpenPanel(page)
	if open then return end
	if not IsNuiReady() then
		Notify('A panel még töltődik, próbáld újra pár másodperc múlva.')
		return
	end

	-- The tasks never wait for the achievements: while those still load, their pages say so.
	local view = nil
	if IsAchievementReady() then
		view = lib.callback.await('Achievements:GetPanel', false)
		if type(view) ~= 'table' then
			Notify('Egy pillanat, a panel épp frissül.')
			return
		end

		local coords = GetEntityCoords(cache.ped)
		view.position = { x = coords.x, y = coords.y }
	end

	local tasks = FetchTaskLists()
	if open then return end

	open = true
	SetNuiFocus(true, true)
	SendNUIMessage({ action = 'open', data = { view = view, tasks = tasks, page = page } })
end

local function ClosePanel()
	if not open then return end
	open = false
	SetNuiFocus(false, false)
	SendNUIMessage({ action = 'close' })
end

-- Command handlers must not block the command dispatcher.
function OpenMissionPanel(page)
	CreateThread(function() OpenPanel(page) end)
end

local function OpenAchievements()
	OpenMissionPanel('overview')
end

RegisterCommand(Config.Panel.Command, OpenAchievements, false)
for _, alias in ipairs(Config.Panel.Aliases) do
	RegisterCommand(alias, OpenAchievements, false)
end
RegisterKeyMapping(Config.Panel.Command, 'Teljesítmények megnyitása', 'keyboard', Config.Panel.Key)

RegisterNUICallback('close', function(_, cb)
	cb('ok')
	ClosePanel()
end)

RegisterNUICallback('leaderboard', function(_, cb)
	cb(lib.callback.await('Achievements:GetLeaderboard', false) or false)
end)

RegisterNUICallback('waypoint', function(data, cb)
	cb('ok')
	local landmark = type(data) == 'table' and FindLandmarkDefinition(data.id)
	if not landmark or landmark.hidden then return end

	SetNewWaypoint(landmark.coords.x, landmark.coords.y)
	ClosePanel()
end)

exports('OpenPanel', function(page)
	OpenMissionPanel(type(page) == 'string' and page or 'overview')
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() or not open then return end
	SetNuiFocus(false, false)
end)
