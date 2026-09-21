--[[
    Fönöki Panel 2 - kliens oldal

    - Lehelyezö mód: a szellem-CP elötted lebeg és követ, ahogy sétálsz (WASD a karaktert
      mozgatja, egér forgat). Egérgörgö = távolság. Enter = lerak, Backspace = mégse.
      config.bossPanel2.placeTimeLimit másodperc után lejár.
    - Menük: CP áthelyezés, CP vásárlás, rang label átírás, küldetések.
    - A menük csak akkor nyílnak meg, ha van elég PP (a vásárlás/áthelyezés/átírás árához).

    Minden tényleges müvelet a szerveren van újraellenörizve.
]]

local P2 = config.bossPanel2
local placing = false

--======================================================================
-- Segéd: 2D szöveg kirajzolás (natív DrawText - itt a ~szín~ kódok müködnek)
--======================================================================
local function draw2DText(x, y, text, scale, center)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    if center then SetTextCentre(true) end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

--====================================================================--
-- Szöveges bekérö (rang label-hez)
--======================================================================
local function askText(title, cb)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'boss2_text_' .. math.random(100000), {
        title = title,
    }, function(data, menu)
        local value = data.value
        if value and #value > 0 then
            menu.close()
            cb(value)
        else
            notifyClient("Adj meg egy érvényes szöveget!")
        end
    end, function(data, menu)
        menu.close()
        cb(nil)
    end)
end

-- HSV -> RGB (h: 0-360, s/v: 0-1) a szabad szín-állításhoz
local function hsvToRgb(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs(((h / 60) % 2) - 1))
    local m = v - c
    local r, g, b = 0, 0, 0
    if h < 60 then r, g, b = c, x, 0
    elseif h < 120 then r, g, b = x, c, 0
    elseif h < 180 then r, g, b = 0, c, x
    elseif h < 240 then r, g, b = 0, x, c
    elseif h < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end
    return math.floor((r + m) * 255), math.floor((g + m) * 255), math.floor((b + m) * 255)
end

--======================================================================
-- Segédfüggvények a lehelyezö módhoz
--======================================================================

local function getAppearancePresets()
    return P2.appearancePresets or { { label = "Alap", markerType = 1, color = { r = 0, g = 200, b = 0, a = 120 } } }
end

local function getDefaultAppearance()
    local presets = getAppearancePresets()
    local preset = presets[1] or { markerType = 1, color = { r = 255, g = 255, b = 0, a = 50 } }
    return {
        markerType = preset.markerType,
        r = preset.color.r,
        g = preset.color.g,
        b = preset.color.b,
        a = preset.color.a,
        scale = 1.5
    }
end

-- Kontroll-listák egyszer felépítve (nem frame-enként), így a lehelyezö loop nem allokál
local BLOCKED_CONTROLS = { 24, 25, 257, 263, 264, 14, 15, 16, 17, 99, 100, 75 } -- mozgás + támadás
local BLOCKED_APPEARANCE_CONTROLS = { 15, 14, 99, 100, 172, 173, 44, 38, 175, 174 } -- görgö + szín/méret

-- Blokkolja a kontrollokat (alapvető mozgás + opcionálisan kinézet-állítás)
local function blockControls(allowAppearance)
    for _, control in ipairs(BLOCKED_CONTROLS) do
        DisableControlAction(0, control, true)
    end
    if allowAppearance then
        for _, control in ipairs(BLOCKED_APPEARANCE_CONTROLS) do
            DisableControlAction(0, control, true)
        end
    end
end

-- Pozíció kiszámítása a játékos előtt
local function calculateMarkerPosition(fwdDist)
    local ped = PlayerPedId()
    local pc = GetEntityCoords(ped)
    local r = math.rad(GetEntityHeading(ped))
    return vector3(
        pc.x - math.sin(r) * fwdDist,
        pc.y + math.cos(r) * fwdDist,
        pc.z
    )
end

-- Színek számítása (preset szín vagy szabad HSV szín)
local function calculateAppearanceColors(preset, hue)
    if hue then
        local r, g, b = hsvToRgb(hue, 1.0, 1.0)
        return r, g, b, preset.color.a or 150
    else
        return preset.color.r, preset.color.g, preset.color.b, preset.color.a
    end
end

-- Feliratok rajzolása a képernyő közepén
local function drawPlacementHUD(typeLabel, allowAppearance, appIndex, preset, hue, scaleVal, fwdDist, remaining)
    -- Fő felirat
    draw2DText(0.5, 0.50, "Lerakod: ~g~" .. (typeLabel or "CP") .. "~s~", 0.5, true)

    local line = 0.55
    if allowAppearance then
        -- Forma
        draw2DText(0.5, line, "Forma: ~b~" .. (preset.label or "Alap") .. "~s~   (bal/jobb nyíl)", 0.45, true)
        line = line + 0.05

        -- Szín és méret
        local colorInfo = ""
        if hue then
            colorInfo = string.format("Szín: ~b~Q/E~s~ (%d°)", hue or 0)
        else
            colorInfo = string.format("Szín: ~b~%d,%d,%d~s~", preset.color.r, preset.color.g, preset.color.b)
        end
        draw2DText(0.5, line, colorInfo .. "   |   Méret: ~b~fel/le nyíl~s~ (" .. string.format("%.1f", scaleVal) .. ")", 0.45, true)
        line = line + 0.05
    end

    -- Idő
    draw2DText(0.5, line, "Hátralévö idö: ~y~" .. remaining .. " mp", 0.45, true)

    -- Utasítások
    draw2DText(0.5, line + 0.05,
        "Görgö: távolság  |  ~g~Enter~s~: lerak  |  ~r~Backspace~s~: mégse", 0.4, true)
end

--======================================================================
-- Lehelyezö mód: a marker követi a játékost, Enter = lerak ahol állsz.
-- typeLabel: mit helyezünk le (kiírja).
-- allowAppearance: ha true -> forma (nyilak balra/jobbra), szín (Q/E), méret (fel/le nyíl).
-- cb(coords, appearance) vagy cb(nil); appearance = { markerType, r, g, b, a, scale }
--======================================================================
function startCPPlacement(typeLabel, allowAppearance, cb)
    if placing then
        notifyClient("Már folyamatban van egy lehelyezés.")
        return cb(nil)
    end
    placing = true

    ESX.UI.Menu.CloseAll()

    local presets = getAppearancePresets()
    local appIndex = 1
    local hue = nil          -- nil = preset szín; szám = szabad HSV szín (Q/E)
    local scaleVal = 1.5     -- marker méret (x/y), z = scaleVal * 0.33
    local fwdDist = 1.2      -- kezdeti tároló eltolás

    local startTime = GetGameTimer()
    local limitMs = (P2.placeTimeLimit or 60) * 1000

    Citizen.CreateThread(function()
        while placing do
            Citizen.Wait(0)

            local elapsed = GetGameTimer() - startTime
            local remaining = math.ceil((limitMs - elapsed) / 1000)

            if elapsed >= limitMs then
                placing = false
                notifyClient("Lejárt az idő, a CP lehelyezés megszakadt.")
                cb(nil)
                return
            end

            -- Blokkoljuk a kontrollokat
            blockControls(allowAppearance)

            -- Görgövel a marker távolsága állítható
            if IsDisabledControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 99) then
                fwdDist = math.min(fwdDist + 0.3, 6.0)
            end
            if IsDisabledControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 100) then
                fwdDist = math.max(fwdDist - 0.3, 0.0)
            end

            if allowAppearance then
                -- Forma (preset) váltás bal/jobb nyíllal -> szín visszaáll a preset színére
                if #presets > 1 then
                    if IsDisabledControlJustPressed(0, 175) then appIndex = (appIndex % #presets) + 1; hue = nil end
                    if IsDisabledControlJustPressed(0, 174) then appIndex = ((appIndex - 2) % #presets) + 1; hue = nil end
                end
                -- Szabad szín Q/E-vel (folyamatos)
                if IsDisabledControlPressed(0, 44) then hue = ((hue or 0) - 3) % 360 end -- Q
                if IsDisabledControlPressed(0, 38) then hue = ((hue or 0) + 3) % 360 end -- E
                -- Méret fel/le nyíllal
                if IsDisabledControlPressed(0, 172) then scaleVal = math.min(scaleVal + 0.03, 4.0) end
                if IsDisabledControlPressed(0, 173) then scaleVal = math.max(scaleVal - 0.03, 0.4) end
            end

            local preset = presets[appIndex]
            local colR, colG, colB, colA = calculateAppearanceColors(preset, hue)

            local pos = calculateMarkerPosition(fwdDist)

            -- Szellem marker a kiválasztott formával / színekkel / mérettel
            DrawMarker(preset.markerType or 1, pos.x, pos.y, pos.z - 0.95, 0, 0, 0, 0, 0, 0,
                scaleVal, scaleVal, scaleVal * 0.5, colR, colG, colB, colA, false, false, 2, false, nil, nil, false)

            -- Feliratok feljebb (ne lógjanak a HUD-ba), ö/ü-vel (DrawText nem kezeli az ő/ű-t)
            drawPlacementHUD(typeLabel, allowAppearance, appIndex, preset, hue, scaleVal, fwdDist, remaining)

            if IsControlJustPressed(0, 201) or IsControlJustPressed(0, 18) then -- Enter
                placing = false
                local appearance = nil
                if allowAppearance then
                    appearance = {
                        markerType = preset.markerType or 1,
                        r = colR, g = colG, b = colB, a = colA,
                        scale = scaleVal
                    }
                end
                cb({ x = pos.x, y = pos.y, z = pos.z }, appearance)
                return
            end

            if IsControlJustPressed(0, 202) or IsControlJustPressed(0, 177) then -- Backspace
                placing = false
                notifyClient("CP lehelyezés megszakítva.")
                cb(nil)
                return
            end
        end
    end)
end

--======================================================================
-- Menü segédfüggvények (csökkentett kódduplikáció)
--======================================================================

local function openSelectionMenu(title, elements, confirmCb, cancelCb)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss2_menu_' .. math.random(100000), {
        title = title,
        align = 'bottom-right',
        elements = elements
    }, confirmCb, cancelCb)
end

local function openBossPanel2WithPPCheck(bossMarkerId, menuTitle, menuElements, actionCb)
    ESX.TriggerServerCallback('esx_job_creator:boss2:getPP', function(pp)
        pp = tonumber(pp) or 0

        local elements = {}
        for _, elem in ipairs(menuElements) do
            elements[#elements + 1] = {
                label = elem.label,
                value = elem.value,
                cost = elem.cost or 0
            }
        end

        openSelectionMenu(menuTitle, elements, function(data, menu)
            local action = data.current.value
            local cost = data.current.cost or 0

            if cost > 0 and pp < cost then
                return notifyClient(("Nincs elég PP-d ehhez! (%d PP kell, neked %d van)"):format(cost, pp))
            end

            menu.close()
            Citizen.SetTimeout(50, function() actionCb(action, data.current) end)
        end, function(data, menu)
            menu.close()
        end)
    end, bossMarkerId)
end

--======================================================================
-- CP áthelyezés
--======================================================================
local function openMoveCP(bossMarkerId)
    ESX.TriggerServerCallback('esx_job_creator:boss2:getJobCPs', function(cps)
        if not cps or #cps == 0 then
            return notifyClient("Nincs áthelyezhető CP.")
        end

        local elements = {}
        for _, cp in ipairs(cps) do
            elements[#elements + 1] = {
                label = ("#%d - %s (%s)"):format(cp.id, cp.label or "CP", cp.type),
                value = cp.id,
                cpId = cp.id,
                cpLabel = cp.label or "CP",
                cost = P2.movePrice
            }
        end

        openBossPanel2WithPPCheck(bossMarkerId, ("CP áthelyezés (%d PP)"):format(P2.movePrice), elements,
            function(action, data)
                local cpId = data.cpId
                local cpLabel = data.cpLabel
                -- Áthelyezésnél nem változtatunk kinézetet
                startCPPlacement(cpLabel, false, function(coords)
                    if coords then
                        TriggerServerEvent('esx_job_creator:boss2:moveCP', bossMarkerId, cpId, coords)
                    end
                    Citizen.SetTimeout(150, function() openBossPanel2(bossMarkerId) end)
                end)
            end)
    end, bossMarkerId)
end

--======================================================================
-- CP vásárlás
--======================================================================
local function openBuyCP(bossMarkerId)
    local elements = {}
    for i, t in ipairs(P2.buyableTypes) do
        elements[#elements + 1] = {
            label = t.label,
            value = i,
            typeIndex = i,
            typeLabel = t.label,
            cost = P2.buyPrice
        }
    end

    openBossPanel2WithPPCheck(bossMarkerId, ("CP vásárlás (%d PP)"):format(P2.buyPrice), elements,
        function(action, data)
            local typeIndex = data.typeIndex
            local typeLabel = data.typeLabel
            -- Vásárlásnál forma/szín/méret is választható
            startCPPlacement(typeLabel, true, function(coords, appearance)
                if coords then
                    TriggerServerEvent('esx_job_creator:boss2:buyCP', bossMarkerId, typeIndex, coords, appearance)
                end
                Citizen.SetTimeout(150, function() openBossPanel2(bossMarkerId) end)
            end)
        end)
end

--======================================================================
-- Rang label átírás
--======================================================================
local function openRenameRank(bossMarkerId)
    ESX.TriggerServerCallback('esx_job_creator:boss2:getRanks', function(ranks)
        if not ranks or #ranks == 0 then
            return notifyClient("Nincs átírható rang.")
        end

        local elements = {}
        for _, rk in ipairs(ranks) do
            table.insert(elements, {
                label = ("[%d] %s"):format(rk.grade, rk.label),
                value = rk.grade,
                grade = rk.grade,
                cost = P2.renamePrice
            })
        end

        openBossPanel2WithPPCheck(bossMarkerId, ("Rang átírás (%d PP)"):format(P2.renamePrice), elements,
            function(action, data)
                local grade = data.grade
                askText("Új rang név", function(newLabel)
                    if newLabel then
                        TriggerServerEvent('esx_job_creator:boss2:renameRank', bossMarkerId, grade, newLabel)
                        Citizen.SetTimeout(300, function() openBossPanel2(bossMarkerId) end)
                    end
                end)
            end)
    end, bossMarkerId)
end

--======================================================================
-- Frakció átnevezés (label)
--======================================================================
local function openRenameFaction(bossMarkerId)
    askText("Új frakció név", function(newLabel)
        if newLabel then
            TriggerServerEvent('esx_job_creator:boss2:renameFaction', bossMarkerId, newLabel)
            Citizen.SetTimeout(300, function() openBossPanel2(bossMarkerId) end)
        end
    end)
end

--======================================================================
-- Küldetések
--======================================================================
local function openMissions(bossMarkerId)
    ESX.TriggerServerCallback('esx_job_creator:boss2:getMissions', function(missions)
        if not missions or #missions == 0 then
            return notifyClient("Nincsenek küldetések.")
        end

        local elements = {}
        for _, m in ipairs(missions) do
            local progress
            if m.claimed then
                progress = "megszerezve"
            elseif m.ready then
                progress = "BEGYÜJTHETŐ!"
            else
                progress = ("%d/%d"):format(m.current, m.required)
            end

            local label = ("%s  [%s]  ->  %s"):format(m.label, progress, m.rewardLabel)

            -- hátralévő idő az újraindulásig (resetDays-es küldetéseknél)
            if m.resetsAt and m.now then
                local remaining = m.resetsAt - m.now
                if remaining > 0 then
                    local days = math.floor(remaining / 86400)
                    local hours = math.floor((remaining % 86400) / 3600)
                    label = ("%s  (újraindul: %d nap %d óra)"):format(label, days, hours)
                end
            end

            table.insert(elements, {
                label = label,
                value = m.id,
                missionId = m.id,
                ready = m.ready,
                hasCP = m.hasCP
            })
        end

        openSelectionMenu("Küldetések", elements, function(data, menu)
            if not data.current.ready then
                return notifyClient("Ez a küldetés még nem gyüjthető be.")
            end

            local missionId = data.current.missionId

            if data.current.hasCP then
                notifyClient("Helyezd le a jutalom CP-t!")
                -- Küldetés-jutalomnál is választható forma/szín/méret
                startCPPlacement("Küldetés jutalom", true, function(coords, appearance)
                    if coords then
                        TriggerServerEvent('esx_job_creator:boss2:claimMission', bossMarkerId, missionId, coords, appearance)
                    end
                    Citizen.SetTimeout(150, function() openBossPanel2(bossMarkerId) end)
                end)
            else
                -- csak pénz jutalom: nincs CP lehelyezés
                TriggerServerEvent('esx_job_creator:boss2:claimMission', bossMarkerId, missionId, nil, nil)
                Citizen.SetTimeout(300, function() openBossPanel2(bossMarkerId) end)
            end
        end, function(data, menu)
            menu.close()
        end)
    end, bossMarkerId)
end

--======================================================================
-- Főmenü - elöbb lekéri a PP-t, kiírja, és gate-eli a műveleteket
--======================================================================
function openBossPanel2(bossMarkerId)
    openBossPanel2WithPPCheck(bossMarkerId, "Főnöki Panel 2", {
        { label = ("CP áthelyezés (%d PP)"):format(P2.movePrice),  value = "move",  cost = P2.movePrice },
        { label = ("CP vásárlás (%d PP)"):format(P2.buyPrice),    value = "buy",   cost = P2.buyPrice },
        { label = ("Rang átírás (%d PP)"):format(P2.renamePrice), value = "rank",  cost = P2.renamePrice },
        { label = ("Frakció átnevezés (%d PP)"):format(P2.renameFactionPrice), value = "renameFaction", cost = P2.renameFactionPrice },
        { label = "Küldetések",                                   value = "missions", cost = 0 }
    }, function(action, data)
        if action == "move" then
            openMoveCP(bossMarkerId)
        elseif action == "buy" then
            openBuyCP(bossMarkerId)
        elseif action == "rank" then
            openRenameRank(bossMarkerId)
        elseif action == "renameFaction" then
            openRenameFaction(bossMarkerId)
        elseif action == "missions" then
            openMissions(bossMarkerId)
        end
    end)
end