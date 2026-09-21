function OpenKeyManagement()
    SetNuiFocus(true, true)
    SendNUIMessage({
		action = "show",
		enable = true
	})
end

exports("OpenKeyManagement", OpenKeyManagement)

--[[RegisterCommand("keymanagement", function(s, a, r)
    OpenKeyManagement()
end, false)
RegisterKeyMapping('keymanagement', 'Autó kulcsok kezelése', 'keyboard', '')]]
