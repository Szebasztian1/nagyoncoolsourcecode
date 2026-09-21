RegisterNuiCallback("loaded", function(_, cb)
    UiLoaded = true
    ResetHudMessageCache()
    cb(Config)
end)

RegisterNuiCallback("close", function()
    SetNuiFocus(false, false)
end)

RegisterNuiCallback("setAlwaysMapOn", function(status)
    MapAlwaysOn = status
end)

RegisterNuiCallback("cinematicMode", function(status)
    CinematicMode = status

    TriggerEvent("bc_eventdisp:block", CinematicMode)
    TriggerEvent("disablenotys", CinematicMode)
    --TriggerEvent("hideChat", CinematicMode)
    if CinematicMode then
        TriggerEvent('hideChat', false)
    else
        TriggerEvent('hideChat', true)
    end

    -- A mozi mod minden frame-ben elrejti a radart. A vehicle.lua csak akkor teszi
    -- vissza JARMUBEN, ha `MapOn` hamis -- az viszont vegig true maradt, ezert a
    -- mozi modbol kilepve a terkep eltunve maradt, es csak terkep-alakvaltaskor
    -- (loadMap -> DisplayRadar(true)) jott vissza. Bejelentve 2026-09-20.
    if CinematicMode then
        MapOn = false
    end

    while CinematicMode do
        DisplayRadar(0)
		for i = 0, 1.0, 1.0 do
			DrawRect(0.0, 0.0, 2.0, 0.2, 0, 0, 0, 255)
			DrawRect(0.0, i, 2.0, 0.2, 0, 0, 0, 255)
		end

		Wait(0)
	end

    -- Kilepeskor azonnal vissza, nem varjuk meg a vehicle.lua kovetkezo koret.
    -- (A pause menu sajat agon kezeli a radart, ott nem szolunk bele.)
    if not IsPSMenu() then
        MapOn = true
        DisplayRadar(true)
    end
end)

RegisterNuiCallback("setSpeedUnit", function(status)
    SpeedMultiplier = status == "kmh" and 3.6 or 2.236936
end)

-- "square" (the stock frame), "bordered" (bordermap.ytd) or "circle" (the joemap-style round map). Sent once when the UI
-- loads with the player's saved choice, then again on every click in the settings menu.
RegisterNuiCallback("setMapShape", function(shape, cb)
    SetMapShape(shape)
    cb("ok")
end)
