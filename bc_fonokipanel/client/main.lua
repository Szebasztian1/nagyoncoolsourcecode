--[[
    Egyesitett fonoki panel (NUI) - kliens

    - A esx_job_creator boss menubol nyilik: TriggerEvent('bc_fonokipanel:open', markerId)
    - A panel a meglevo, biztonsagos esx_job_creator szerver-callbackekre / eventekre kot ra
      (PP, CP move/buy/rang/kuldetes, tarolo/szef hozzaferes), itt nincs uj szerver-logika.
    - A CP lehelyezes a jatekterben tortenik (a panel becsukodik, lerakod, ujranyilik).
]]

local currentMarkerId = nil
local panelOpen = false
local placing = false
local panelConfig = nil
-- Csak az Alkalmazottak fulon van ertelme a hattervedelmi frissitesnek.
-- A NUI fulvaltaskor kuld egy-egy adatkerest (html/script.js), abbol tudjuk,
-- melyik fulon all a fonok - igy nem kell a NUI-t modositani.
local empTabActive = false

local function notify(msg)
    if ESX and ESX.ShowNotification then ESX.ShowNotification(msg) else
        TriggerEvent('esx:showNotification', msg) end
end

--======================================================================
-- Panel nyitas / zaras
--======================================================================
local function pushData(data)
    SendNUIMessage({ action = 'data', data = data })
end

function OpenPanel(markerId)
    if placing then return end
    currentMarkerId = markerId

    ESX.TriggerServerCallback('esx_job_creator:boss2:getPanelData', function(data)
        if not data then
            return notify('Ehhez nincs jogosultsagod.')
        end
        panelConfig = data.config
        panelOpen = true
        -- A NUI mindig az attekintes fulon nyit
        empTabActive = false
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'open', data = data })
    end, markerId)
end
RegisterNetEvent('bc_fonokipanel:open')
AddEventHandler('bc_fonokipanel:open', function(markerId)
    OpenPanel(markerId)
end)

local function closePanel()
    panelOpen = false
    empTabActive = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function refreshPanel()
    if not currentMarkerId then return end
    ESX.TriggerServerCallback('esx_job_creator:boss2:getPanelData', function(data)
        if data then
            panelConfig = data.config
            pushData(data)
        end
    end, currentMarkerId)
end

--======================================================================
-- Segedek: szoveg, HSV->RGB
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
-- Lehelyezo mod (kovet teged). allowAppearance -> forma/szin/meret allithato.
-- cb(coords, appearance) vagy cb(nil)
-- A nativ DrawText nem kezeli az o/u-t, ezert itt o/u szerepel a feliratokban.
--======================================================================
local function startPlacement(typeLabel, allowAppearance, cb)
    if placing then return cb(nil) end
    placing = true

    local presets = (panelConfig and panelConfig.appearancePresets) or {}
    if #presets == 0 then
        presets = { { label = "Alap", markerType = 1, color = { r = 0, g = 200, b = 0, a = 120 } } }
    end

    local appIndex = 1
    local hue = nil
    local scaleVal = 1.5
    local fwdDist = 1.2
    local timeLimit = 60
    local startTime = GetGameTimer()
    local limitMs = timeLimit * 1000

    Citizen.CreateThread(function()
        while placing do
            Citizen.Wait(0)

            local elapsed = GetGameTimer() - startTime
            local remaining = math.ceil((limitMs - elapsed) / 1000)
            if elapsed >= limitMs then
                placing = false
                notify('Lejart az ido, a CP lehelyezes megszakadt.')
                cb(nil)
                return
            end

            local block = { 24, 25, 257, 263, 264, 14, 15, 16, 17, 99, 100, 75 }
            if allowAppearance then
                block[#block + 1] = 172; block[#block + 1] = 173
                block[#block + 1] = 174; block[#block + 1] = 175
                block[#block + 1] = 44;  block[#block + 1] = 38
            end
            for _, c in ipairs(block) do DisableControlAction(0, c, true) end

            if IsDisabledControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 99) then
                fwdDist = math.min(fwdDist + 0.3, 6.0)
            end
            if IsDisabledControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 100) then
                fwdDist = math.max(fwdDist - 0.3, 0.0)
            end

            if allowAppearance then
                if #presets > 1 then
                    if IsDisabledControlJustPressed(0, 175) then appIndex = (appIndex % #presets) + 1; hue = nil end
                    if IsDisabledControlJustPressed(0, 174) then appIndex = ((appIndex - 2) % #presets) + 1; hue = nil end
                end
                if IsDisabledControlPressed(0, 44) then hue = ((hue or 0) - 3) % 360 end
                if IsDisabledControlPressed(0, 38) then hue = ((hue or 0) + 3) % 360 end
                if IsDisabledControlPressed(0, 172) then scaleVal = math.min(scaleVal + 0.03, 4.0) end
                if IsDisabledControlPressed(0, 173) then scaleVal = math.max(scaleVal - 0.03, 0.4) end
            end

            local preset = presets[appIndex]
            local colR, colG, colB, colA
            if hue then
                colR, colG, colB = hsvToRgb(hue, 1.0, 1.0)
                colA = (preset.color and preset.color.a) or 150
            else
                colR = preset.color.r; colG = preset.color.g; colB = preset.color.b; colA = preset.color.a
            end

            local ped = PlayerPedId()
            local pc = GetEntityCoords(ped)
            local r = math.rad(GetEntityHeading(ped))
            local pos = vector3(pc.x - math.sin(r) * fwdDist, pc.y + math.cos(r) * fwdDist, pc.z)

            DrawMarker(preset.markerType or 1, pos.x, pos.y, pos.z - 0.95, 0, 0, 0, 0, 0, 0,
                scaleVal, scaleVal, scaleVal * 0.5, colR, colG, colB, colA, false, false, 2, false, nil, nil, false)

            draw2DText(0.5, 0.50, "Lerakod: ~g~" .. (typeLabel or "CP") .. "~s~", 0.5, true)
            local line = 0.55
            if allowAppearance then
                draw2DText(0.5, line, "Forma: ~b~" .. (preset.label or "Alap") .. "~s~   (bal/jobb nyil)", 0.45, true)
                line = line + 0.05
                draw2DText(0.5, line, "Szin: ~b~Q / E~s~   |   Meret: ~b~fel / le nyil~s~ (" .. string.format("%.1f", scaleVal) .. ")", 0.45, true)
                line = line + 0.05
            end
            draw2DText(0.5, line, "Hatralevo ido: ~y~" .. remaining .. " mp", 0.45, true)
            draw2DText(0.5, line + 0.05, "Gorgo: tavolsag  |  ~g~Enter~s~: lerak  |  ~r~Backspace~s~: megse", 0.4, true)

            if IsControlJustPressed(0, 201) or IsControlJustPressed(0, 18) then
                placing = false
                local appearance = nil
                if allowAppearance then
                    appearance = { markerType = preset.markerType or 1, r = colR, g = colG, b = colB, a = colA, scale = scaleVal }
                end
                -- A tarolt z a talajhoz normalizalt ped-kozep (igy a ped
                -- tipusu CP-k nem lebegnek pl. a HQ shell padlojan sem)
                local zOut = pos.z
                local probe = StartExpensiveSynchronousShapeTestLosProbe(
                    pos.x, pos.y, pos.z + 1.5, pos.x, pos.y, pos.z - 4.0, 17, ped, 4)
                local _, hit, hitCoords = GetShapeTestResult(probe)
                if hit == 1 or hit == true then
                    zOut = hitCoords.z + 1.0
                end
                cb({ x = pos.x, y = pos.y, z = zOut }, appearance)
                return
            end
            if IsControlJustPressed(0, 202) or IsControlJustPressed(0, 177) then
                placing = false
                notify('CP lehelyezes megszakitva.')
                cb(nil)
                return
            end
        end
    end)
end

-- Panelt becsukja, lehelyez, majd ujranyitja
local function placeThenReopen(typeLabel, allowAppearance, sendFn)
    closePanel()
    startPlacement(typeLabel, allowAppearance, function(coords, appearance)
        if coords then
            sendFn(coords, appearance)
        end
        Citizen.SetTimeout(600, function()
            if currentMarkerId then OpenPanel(currentMarkerId) end
        end)
    end)
end

--======================================================================
-- NUI callbackek
--======================================================================
RegisterNUICallback('close', function(_, cb)
    closePanel()
    cb('ok')
end)

RegisterNUICallback('refresh', function(_, cb)
    refreshPanel()
    cb('ok')
end)

RegisterNUICallback('moveCP', function(d, cb)
    cb('ok')
    placeThenReopen(d.cpLabel or 'CP', false, function(coords)
        TriggerServerEvent('esx_job_creator:boss2:moveCP', currentMarkerId, d.cpId, coords)
    end)
end)

RegisterNUICallback('buyCP', function(d, cb)
    cb('ok')
    placeThenReopen(d.typeLabel or 'CP', true, function(coords, appearance)
        TriggerServerEvent('esx_job_creator:boss2:buyCP', currentMarkerId, d.typeIndex, coords, appearance)
    end)
end)

RegisterNUICallback('renameRank', function(d, cb)
    if d.grade ~= nil and d.label and #d.label > 0 then
        TriggerServerEvent('esx_job_creator:boss2:renameRank', currentMarkerId, d.grade, d.label)
        Citizen.SetTimeout(500, refreshPanel)
    end
    cb('ok')
end)

RegisterNUICallback('renameFaction', function(d, cb)
    if d.label and #d.label > 0 then
        TriggerServerEvent('esx_job_creator:boss2:renameFaction', currentMarkerId, d.label)
        Citizen.SetTimeout(500, refreshPanel)
    end
    cb('ok')
end)

RegisterNUICallback('claimMission', function(d, cb)
    cb('ok')
    placeThenReopen('Kuldetes jutalom', true, function(coords, appearance)
        TriggerServerEvent('esx_job_creator:boss2:claimMission', currentMarkerId, d.missionId, coords, appearance)
    end)
end)

RegisterNUICallback('buyRank', function(d, cb)
    cb('ok')
    ESX.TriggerServerCallback('esx_job_creator:boss2:buyRank', function(res)
        if res and res.msg then notify(res.msg) end
        refreshPanel()
    end, currentMarkerId, d.label, d.insertGrade)
end)

RegisterNUICallback('deleteRank', function(d, cb)
    cb('ok')
    ESX.TriggerServerCallback('esx_job_creator:boss2:deleteRank', function(res)
        if res and res.msg then notify(res.msg) end
        refreshPanel()
    end, currentMarkerId, d.rankId)
end)

RegisterNUICallback('moveRank', function(d, cb)
    cb('ok')
    ESX.TriggerServerCallback('esx_job_creator:boss2:moveRank', function(res)
        if res and res.msg then notify(res.msg) end
        refreshPanel()
    end, currentMarkerId, d.grade, d.dir)
end)

RegisterNUICallback('setLimit', function(d, cb)
    cb('ok')
    local callbackName = (d.stype == 'safe') and 'esx_job_creator:safe:setLimit' or 'esx_job_creator:stash:setLimit'
    ESX.TriggerServerCallback(callbackName, function(info)
        if info and info.isBoss and info.ranks then
            SendNUIMessage({ action = 'access', id = d.id, stype = d.stype, info = info })
        end
    end, d.id, d.grade, d.limit)
end)

--======================================================================
-- Pénzügyek (társasági számla) - esx_job_creator meglévő logikája
--======================================================================
local function pushMoney()
    ESX.TriggerServerCallback('esx_job_creator:getBossData', function(_, jobMoney)
        SendNUIMessage({ action = 'money', balance = tonumber(jobMoney) or 0 })
    end, currentMarkerId)
end

RegisterNUICallback('getMoney', function(_, cb)
    cb('ok'); empTabActive = false; pushMoney()
end)

RegisterNUICallback('deposit', function(d, cb)
    cb('ok')
    local amount = math.floor(tonumber(d.amount) or 0)
    if amount > 0 then
        TriggerServerEvent('esx_job_creator:depositSocietyMoney', currentMarkerId, amount)
        Citizen.SetTimeout(500, function() pushMoney(); refreshPanel() end)
    end
end)

RegisterNUICallback('withdraw', function(d, cb)
    cb('ok')
    local amount = math.floor(tonumber(d.amount) or 0)
    if amount > 0 then
        TriggerServerEvent('esx_job_creator:withdrawSocietyMoney', currentMarkerId, amount)
        Citizen.SetTimeout(500, function() pushMoney(); refreshPanel() end)
    end
end)

--======================================================================
-- Alkalmazottak - esx_job_creator meglévő logikája
--======================================================================
-- Az alkalmazott-listat a users tablabol kerjuk (szerver oldal), hogy a
-- /setjob-bal bekerult tagok is megjelenjenek, ne csak a panelon felvettek.
--
-- force = true  -> felhasznaloi muvelet, a szerver mindig valaszol
-- force = false -> hattervedelmi ciklus, a szerver csak valtozas eseten kuld
local function pushEmployees(force)
    TriggerServerEvent('bc_fonokipanel:reqEmployees', force == true)
end

RegisterNetEvent('bc_fonokipanel:employeesData')
AddEventHandler('bc_fonokipanel:employeesData', function(employees, gradesLabels, myIdentifier)
    SendNUIMessage({
        action = 'employees',
        employees = employees or {},
        gradesLabels = gradesLabels or {},
        myIdentifier = myIdentifier,
    })
end)

RegisterNUICallback('getEmployees', function(_, cb)
    cb('ok'); empTabActive = true; pushEmployees(true)
end)

RegisterNUICallback('promote', function(d, cb)
    cb('ok')
    TriggerServerEvent('esx_job_creator:boss:changeGradeToEmployee', currentMarkerId, d.identifier, tonumber(d.grade))
    -- Discord rang frissites (regi vms_bossmenu: bc:onrankchange)
    TriggerServerEvent('bc_fonokipanel:rankChange', d.identifier, tonumber(d.grade))
    Citizen.SetTimeout(500, function() pushEmployees(true) end)
end)

RegisterNUICallback('fire', function(d, cb)
    cb('ok')
    -- Boss can never fire themselves (the NUI also hides the button)
    local me = ESX.GetPlayerData()
    if me and me.identifier and me.identifier == d.identifier then
        return notify('Sajat magadat nem rughatod ki.')
    end
    -- A tenyleges kirugas valtozatlan, mukodo uton (esx_job_creator).
    TriggerServerEvent('esx_job_creator:boss:fireEmployee', currentMarkerId, d.identifier)
    -- Discord rang levetel + factionjump melle (regi vms_bossmenu: bc:onfireplayer).
    TriggerServerEvent('bc_fonokipanel:fired', d.identifier)
    Citizen.SetTimeout(500, function() pushEmployees(true); refreshPanel() end)
end)

RegisterNUICallback('giveBonus', function(d, cb)
    cb('ok')
    local amount = tonumber(d.amount)
    if type(d.identifier) ~= 'string' or not amount or amount < 1 then return end
    -- Sajat szerver oldali esemeny, ott a teljes validacio (kassza, online, frakcio).
    TriggerServerEvent('Fonokipanel:Server:GiveBonus', d.identifier, math.floor(amount))
    Citizen.SetTimeout(600, function() pushEmployees(true) end)
end)

RegisterNUICallback('getNearby', function(_, cb)
    cb('ok')
    local coords = GetEntityCoords(PlayerPedId())
    local players = ESX.Game.GetPlayersInArea(coords, 10.0)
    local ids = {}
    for _, p in ipairs(players) do
        local sid = GetPlayerServerId(p)
        if sid ~= GetPlayerServerId(PlayerId()) then ids[#ids + 1] = sid end
    end
    -- Sajat callback: a mar felvett (azonos frakcios) tagok nem szerepelnek
    ESX.TriggerServerCallback('bc_fonokipanel:getNearbyHireable', function(names)
        SendNUIMessage({ action = 'nearby', list = names or {} })
    end, ids)
end)

RegisterNUICallback('recruit', function(d, cb)
    cb('ok')
    local serverId = tonumber(d.serverId)
    -- Elofeltetel szerver oldalon: csak unemployed, frakciojump rang nelkul.
    ESX.TriggerServerCallback('bc_fonokipanel:canRecruit', function(allowed, reason)
        if not allowed then
            return notify(reason or 'A jatekos nem veheto fel.')
        end
        -- A tenyleges felvetel valtozatlan, mukodo uton (esx_job_creator).
        TriggerServerEvent('esx_job_creator:boss:recruitPlayer', currentMarkerId, serverId)
        -- Discord rang felrakas melle (regi vms_bossmenu: bc:onhireplayer).
        TriggerServerEvent('bc_fonokipanel:hired', serverId)
        Citizen.SetTimeout(600, function() pushEmployees(true); refreshPanel() end)
    end, serverId)
end)

--======================================================================
-- Fizetések rangonként - esx_job_creator meglévő logikája
--======================================================================
local function pushSalaries()
    ESX.TriggerServerCallback('esx_job_creator:boss:getJobGrades', function(grades)
        SendNUIMessage({ action = 'salaries', grades = grades or {} })
    end, currentMarkerId)
end

RegisterNUICallback('getSalaries', function(_, cb)
    cb('ok'); empTabActive = false; pushSalaries()
end)

--======================================================================
-- Aktivitás - esx_job_creator meglévő bc:getPlayerActivities callbackje
--======================================================================
RegisterNUICallback('getActivity', function(_, cb)
    cb('ok')
    empTabActive = false
    ESX.TriggerServerCallback('bc:getPlayerActivities', function(list)
        SendNUIMessage({ action = 'activity', list = list or {} })
    end)
end)

RegisterNUICallback('setSalary', function(d, cb)
    cb('ok')
    local amount = math.floor(tonumber(d.amount) or 0)
    TriggerServerEvent('esx_job_creator:updateGradeSalary', currentMarkerId, tonumber(d.gradeId), tonumber(d.grade), amount)
    Citizen.SetTimeout(500, pushSalaries)
end)

RegisterNUICallback('getAccess', function(d, cb)
    cb('ok')
    local callbackName = (d.stype == 'safe') and 'esx_job_creator:safe:getAccessInfo' or 'esx_job_creator:stash:getAccessInfo'
    ESX.TriggerServerCallback(callbackName, function(info)
        if info and info.isBoss and info.ranks then
            SendNUIMessage({ action = 'access', id = d.id, stype = d.stype, info = info })
        else
            SendNUIMessage({ action = 'access', id = d.id, stype = d.stype, info = false })
        end
    end, d.id)
end)

RegisterNUICallback('setAccess', function(d, cb)
    cb('ok')
    local callbackName = (d.stype == 'safe') and 'esx_job_creator:safe:setAccess' or 'esx_job_creator:stash:setAccess'
    ESX.TriggerServerCallback(callbackName, function(info)
        if info and info.isBoss and info.ranks then
            SendNUIMessage({ action = 'access', id = d.id, stype = d.stype, info = info })
        end
    end, d.id, d.kind, d.grade, d.allowed)
end)

--======================================================================
-- Automatikus alkalmazott-lista frissites, amig az Alkalmazottak ful nyitva.
-- Igy ha valaki kilep a frakciobol (pl. /setjob magat kiszedi), eltunik
-- a listabol a panel ujranyitasa nelkul is. A tenyleges muveletek (felvetel/
-- kirugas/leptetes) amugy is azonnal frissitenek, ezert eleg ritka (30mp)
-- hattervedelem a kulso valtozasokra.
--
-- Mas fulon allva nem kerdezunk: a NUI fulvaltaskor ugyis friss adatot ker,
-- igy egy nyitva felejtett panel nem terheli a szervert.
--======================================================================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        if panelOpen and not placing and currentMarkerId and empTabActive then
            pushEmployees(false)
        end
    end
end)

--======================================================================
-- Frakcio HQ ful (bc_factionhq) - thin UI wiring only. Buying happens
-- in the world at the admin-placed spot, so the tab only manages an
-- owned HQ: entry CP relocation, free CP round, guest access.
--
-- Free CP move: same placement + esx_job_creator:boss2:moveCP flow as
-- the normal move tab; the jobcreator-side ConsumeFreeMove hook skips
-- the PP charge while the CP still has its free ticket (no PP moves).
--======================================================================
local function hqReady()
    return GetResourceState('bc_factionhq') == 'started'
end

local function pushHQ()
    if not hqReady() then
        return SendNUIMessage({ action = 'hq', data = false })
    end
    ESX.TriggerServerCallback('FactionHQ:Server:GetPanelData', function(data)
        SendNUIMessage({ action = 'hq', data = data or false })
    end)
end

RegisterNUICallback('getHQ', function(_, cb)
    cb('ok'); empTabActive = false; pushHQ()
end)

RegisterNUICallback('hqMoveEntry', function(_, cb)
    cb('ok')
    if not hqReady() then return end
    closePanel()
    exports.bc_factionhq:StartEntryMove()
end)

RegisterNUICallback('hqFreeMove', function(d, cb)
    cb('ok')
    placeThenReopen(d.cpLabel or 'CP', false, function(coords)
        TriggerServerEvent('esx_job_creator:boss2:moveCP', currentMarkerId, tonumber(d.cpId), coords)
    end)
end)

RegisterNUICallback('hqRevoke', function(d, cb)
    cb('ok')
    if type(d.identifier) == 'string' and #d.identifier > 0 then
        TriggerServerEvent('FactionHQ:Server:RevokeAccess', d.identifier)
    end
end)

-- Reopen the panel after the entry relocation flow ended
AddEventHandler('FactionHQ:Client:FlowFinished', function()
    if currentMarkerId and not panelOpen then
        OpenPanel(currentMarkerId)
    end
end)
