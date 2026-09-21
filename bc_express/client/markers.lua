-----------------------------------------------------------------------------------------------------------------------------------------
-- SAJAT MARKER RENDSZER  --  a `mate-markers` resource kivaltasa
--
-- Ugyanaz a felepites, mint a vilmos_gyar/client/markers.lua-ban, ami mar
-- honapok ota fut elesben. Miert kap minden resource sajatot:
--
--   1. NINCS EXPORT-HATARATLEPES. A mate-markers minden lekerdezese
--      (`getCurrentMarker`) resource-hatart lepett at, es ez masodpercenkent
--      tobbszor ment, orakon at, minden kliensen -- akkor is, ha egyetlen
--      marker sem volt a kozelben. Itt ez egy tabla-olvasas ugyanabban a Lua
--      allapotban: nulla hataratlepes.
--
--   2. URESJARATBAN ALSZIK. A mate-markers streamelo szala 250 ms-enkent
--      vegigment MINDEN markeren akkor is, ha egy sem volt a kozelben, es
--      minden korben uj tablat allokalt. Itt ha nincs kozeli marker, a
--      streamelo szal 1000 ms-re lassul, a rajzolo szal pedig LE IS ALL --
--      alapallapotban nincs per-frame ciklus.
--
--   3. A MERET ES AZ INTERAKCIOS SUGAR KULON SZAM. A mate-markersnel a ketto
--      ugyanaz volt (`inMarker = dist <= scale.z`), ezert egy 0.5 magas lapos
--      korlapra pontosan ra kellett allni. Itt `scale` = amit RAJZOLUNK,
--      `radius` = ahonnan HASZNALHATO (vizszintes tavolsag), `height` = a
--      fuggoleges tures -- igy a marker nem hasznalhato a felette levo
--      erkelyrol, de egy kamion magas ulesebol igen.
--
--   4. A FELIRAT AZONNAL JON. A mate-markersnel kulon poll-szal kerdezte le
--      (750 ms), ezert a szoveg keses utan jelent meg. Itt a rajzolo szal
--      teszi ki ugyanabban a frame-ben.
--
-- MUKODES -- ket szal:
--
--   STREAM (500 ms)  vegigmegy a markereken es osszeszedi a kozelieket.
--                    Ha egy sincs a kozelben, 1000 ms-re lassul.
--   RENDER (frame)   csak akkor letezik, ha van kozeli marker: az rajzol, az
--                    figyeli az [E]-t es az teszi ki a feliratot. Amint
--                    elfogynak a kozeli markerek, a szal KILEP (nem alszik).
-----------------------------------------------------------------------------------------------------------------------------------------

local INTERACT_KEY <const> = 38      -- E
local STREAM_TICK  <const> = 500     -- ms, ha van kozeli marker
local IDLE_TICK    <const> = 1000    -- ms, ha egy marker sincs a kozelben
local BLIND_TICK   <const> = 250     -- ms, ha van kozeli marker, de egyik sem lathato (pl. nyitott panel)

-- alapertekek, ha a hivo nem ad meg valamit
local DEFAULT_TYPE   <const> = 1
local DEFAULT_COLOR  <const> = { 255, 165, 0, 150 }
local DEFAULT_STREAM <const> = 10.0
local DEFAULT_HEIGHT <const> = 1.5   -- fuggoleges tures az interakciohoz
local MIN_RADIUS     <const> = 1.0   -- ennel kisebb interakcios sugarat nem engedunk (a mate-nel 0.5 is volt)

-- markerek: tomb a gyors bejarashoz, hash az azonosito szerinti kereseshez
local list  = {}
local index = {}

-- a stream szal termeke: csak a kozeli markerek
local streamed      = {}
local streamedCount = 0

local rendering = false

-- amelyik markerben eppen allunk (a legkozelebbi, ahol az interakcio is engedett)
local currentMarker = nil

-----------------------------------------------------------------------------------------------------------------------------------------
-- NYILVANOS FELULET
--
-- Globalis tabla, mert a resource minden kliens-scriptje ugyanabban a Lua
-- allapotban fut -- nem kell hozza export.
-----------------------------------------------------------------------------------------------------------------------------------------

BCMarker = {}

--- A `label` kiirasa. Frame-enkent hivodik, amig a jatekos a markerben all.
--- A resource felulirhatja (pl. ESX.ShowHelpNotification-re) -- ugyanaz a
--- natv help-doboz a kepernyo bal felso sarkaban.
function BCMarker.ShowLabel(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, false, -1)
end

-- A 3D szoveget a game sajat renderele rajzolja, aminek NINCS o/u hosszu
-- glifaja: itt irjuk at automatikusan, hogy a hivonak ne kelljen ket
-- valtozatot tartania ugyanabbol a szovegbol.
local function nativeSafe(text)
    return (text:gsub('ő', 'ö'):gsub('ű', 'ü'):gsub('Ő', 'Ö'):gsub('Ű', 'Ü'))
end

--- Lebego felirat egy vilagpontra (a marker folott).
local function drawText3d(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    SetTextFont(4)
    SetTextScale(0.0, 0.32)
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(sx, sy)
end

-- A szin lehet { r, g, b, a } tomb VAGY { r = , g = , b = , a = } tabla is:
-- a mate-markers csak az elsot olvasta, ezert a nevvel atadott szinek ott
-- ervenytelenek voltak (vilmos_pressurewasher).
local function normColor(c)
    if type(c) ~= 'table' then return DEFAULT_COLOR end

    return {
        tonumber(c[1] or c.r) or DEFAULT_COLOR[1],
        tonumber(c[2] or c.g) or DEFAULT_COLOR[2],
        tonumber(c[3] or c.b) or DEFAULT_COLOR[3],
        tonumber(c[4] or c.a) or DEFAULT_COLOR[4],
    }
end

-- A meret lehet egyetlen szam, vector3, vagy { x, y, z } / { 1, 2, 3 } tabla.
local function normScale(scale)
    local sx, sy, sz

    if type(scale) == 'number' then
        sx, sy, sz = scale, scale, scale
    elseif type(scale) == 'table' then
        sx, sy, sz = tonumber(scale.x or scale[1]), tonumber(scale.y or scale[2]), tonumber(scale.z or scale[3])
    elseif scale ~= nil then
        sx, sy, sz = scale.x, scale.y, scale.z   -- vector3
    end

    return vector3((sx or 0.5) + 0.0, (sy or 0.5) + 0.0, (sz or 0.5) + 0.0)
end

-- vector3 / vector4 / { x, y, z } -> vector3
local function normPos(pos)
    if type(pos) == 'table' then
        return vector3(tonumber(pos.x or pos[1]) or 0.0, tonumber(pos.y or pos[2]) or 0.0, tonumber(pos.z or pos[3]) or 0.0)
    end

    return vector3(pos.x + 0.0, pos.y + 0.0, pos.z + 0.0)
end

--- Egy marker felvetele. Azonos `id`-vel ujra hivva FELULIRJA a regit, tehat a
--- hivonak nem kell elotte torolnie.
---
--- @param props table
---   id             string    kotelezo, egyedi
---   pos            vector3   a marker kozeppontja
---   typ            number    marker tipus (alap: 1)
---   scale          number|vector3  a KIRAJZOLT meret
---   radius         number    az INTERAKCIOS sugar (alap: a scale.z, de legalabb 1.0; vizszintes tavolsag)
---   height         number    fuggoleges tures az interakciohoz (alap: 1.5)
---   color          table     { r, g, b, a } vagy { r = , g = , b = , a = }
---   streamDistance number    ennyitol latszik
---   upDown         boolean   fel-le mozog
---   rotate         boolean   forog
---   label          string    felirat, ha a jatekos beleall (opcionalis)
---   text3d         string    a marker folott lebego szoveg (opcionalis; o/u hosszu automatikusan atirva)
---   text3dZ        number    a szoveg magassaga a `pos` folott (alap: 0.55)
---   markerWhere    function  false -> nem rajzolunk (opcionalis)
---   canInteract    function  false -> nincs [E] es nincs felirat (opcionalis)
---   onInteract     function  [E] lenyomasara fut, sajat szalban (opcionalis)
function BCMarker.Add(props)
    local id = props.id
    if type(id) ~= 'string' or not props.pos then return end

    local scale  = normScale(props.scale)
    local radius = tonumber(props.radius) or scale.z
    local stream = (tonumber(props.streamDistance) or DEFAULT_STREAM) + 0.0

    if radius < MIN_RADIUS then radius = MIN_RADIUS end

    local marker = {
        id          = id,
        pos         = normPos(props.pos),
        typ         = tonumber(props.typ) or DEFAULT_TYPE,
        scale       = scale,
        color       = normColor(props.color),
        stream      = stream,
        stream2     = stream * stream,
        radius2     = radius * radius,
        height      = tonumber(props.height) or DEFAULT_HEIGHT,
        upDown      = props.upDown or false,
        rotate      = props.rotate or false,
        label       = props.label,
        text3d      = props.text3d and nativeSafe(props.text3d) or nil,
        text3dZ     = tonumber(props.text3dZ) or 0.55,
        markerWhere = props.markerWhere,
        canInteract = props.canInteract,
        onInteract  = props.onInteract,
    }

    local i = index[id]

    if i then
        -- csere helyben: a regi peldany `dead`, hatha a rajzolo szal meg fogja
        list[i].dead = true
        list[i] = marker
    else
        list[#list + 1] = marker
        index[id] = #list
    end
end

--- Egy marker torlese. Ismeretlen azonositora nem csinal semmit.
function BCMarker.Remove(id)
    local i = index[id]
    if not i then return end

    local marker = list[i]
    marker.dead = true

    -- helycsere az utolsoval, hogy ne kelljen tombot eltolni
    local last = #list

    if i ~= last then
        list[i] = list[last]
        index[list[i].id] = i
    end

    list[last] = nil
    index[id] = nil

    if currentMarker == marker then
        currentMarker = nil
    end
end

--- Uj pozicio egy markernek (a mate-markers `MoveMarker`-je -- ott nil-guard
--- nelkul indexelt, itt ismeretlen azonositora egyszeruen nem csinal semmit).
function BCMarker.Move(id, pos)
    local i = index[id]
    if not i or not pos then return end

    list[i].pos = normPos(pos)
end

--- Egy tetszoleges mezo frissitese (szin, felirat, ...). A `pos`, `scale`,
--- `color` es `streamDistance` at van vezetve a normalizaloon, hogy a hivo
--- ugyanugy adhassa at oket, mint az Add-ban.
function BCMarker.Update(id, key, value)
    local i = index[id]
    if not i then return end

    local marker = list[i]

    if key == 'pos' then
        marker.pos = normPos(value)
    elseif key == 'color' then
        marker.color = normColor(value)
    elseif key == 'scale' then
        marker.scale = normScale(value)
    elseif key == 'streamDistance' then
        local stream = (tonumber(value) or DEFAULT_STREAM) + 0.0
        marker.stream  = stream
        marker.stream2 = stream * stream
    elseif key == 'radius' then
        local radius = tonumber(value) or marker.scale.z
        if radius < MIN_RADIUS then radius = MIN_RADIUS end
        marker.radius2 = radius * radius
    else
        marker[key] = value
    end
end

--- @return table|nil a marker, amiben a jatekos eppen all
function BCMarker.Current()
    return currentMarker
end

--- @return boolean all-e a jatekos ilyen azonositoju markerben
function BCMarker.IsIn(id)
    return currentMarker ~= nil and currentMarker.id == id
end

--- @return boolean van-e egyaltalan ilyen azonositoju marker
function BCMarker.Has(id)
    return index[id] ~= nil
end

--- Lebego felirat egy vilagpontra, frame-enkent hivhato (a hivo maga
--- tisztitson o/u hosszut a Safe-fel, ne minden frame-ben).
BCMarker.Text3d = drawText3d

--- o/u hosszu -> o/u rovid, a game szovegrenderelojenek.
BCMarker.Safe = nativeSafe

-----------------------------------------------------------------------------------------------------------------------------------------
-- RAJZOLAS + [E]
--
-- Csak akkor letezik, ha van kozeli marker. Amint elfogynak, a szal kilep
-- (nem alszik, nem var) -- a stream szal inditja ujra, ha kell.
-----------------------------------------------------------------------------------------------------------------------------------------

local function render()
    rendering = true

    while streamedCount > 0 do
        local coords = GetEntityCoords(PlayerPedId())
        local px, py, pz = coords.x, coords.y, coords.z

        local best, bestDist = nil, nil
        local visible = false

        for i = 1, streamedCount do
            local marker = streamed[i]

            if not marker.dead then
                local pos = marker.pos
                local dx, dy, dz = pos.x - px, pos.y - py, pos.z - pz
                local flat2 = dx * dx + dy * dy
                local dist2 = flat2 + dz * dz

                -- 1. rajzolas -- a `markerWhere` tilthatja (pl. nyitott panel)
                if dist2 <= marker.stream2 and (not marker.markerWhere or marker.markerWhere()) then
                    local color = marker.color
                    -- ugyanaz a halvanyodas, mint a mate-markersnel: tavolodva atlatszo lesz
                    local alpha = color[4] * (1.0 - math.sqrt(dist2) / marker.stream)

                    if alpha >= 1.0 then
                        DrawMarker(
                            marker.typ,
                            pos.x, pos.y, pos.z,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            marker.scale.x, marker.scale.y, marker.scale.z,
                            color[1], color[2], color[3], math.floor(alpha),
                            marker.upDown, false, 0, marker.rotate,
                            nil, nil, false
                        )
                        visible = true

                        if marker.text3d then
                            drawText3d(pos.x, pos.y, pos.z + marker.text3dZ, marker.text3d)
                        end
                    end
                end

                -- 2. benne allunk-e? Vizszintes tavolsag + fuggoleges tures.
                if flat2 <= marker.radius2 and (dz < 0 and -dz or dz) <= marker.height then
                    if (not bestDist or flat2 < bestDist)
                        and (not marker.canInteract or marker.canInteract()) then
                        best, bestDist = marker, flat2
                    end
                end
            end
        end

        -- 3. felirat: mindig a legkozelebbi markere
        currentMarker = best

        if best and best.label then
            BCMarker.ShowLabel(best.label)
        end

        -- 4. [E]
        if best and best.onInteract and IsControlJustPressed(0, INTERACT_KEY) then
            local fn = best.onInteract
            -- sajat szalban: ha az onInteract var (callback, NUI), az ne
            -- akassza meg a rajzolast
            CreateThread(fn)
        end

        -- Ha semmi nem latszik es nincs mibe belealni (jellemzoen: nyitva a
        -- panel), nem kell frame-enkent porgetni.
        Wait((visible or best) and 0 or BLIND_TICK)
    end

    currentMarker = nil
    rendering = false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- STREAMELES
--
-- Egyetlen szal az EGESZ resource-ra. Nincs benne Wait a cikluson belul, tehat
-- egy korben latja az osszes markert.
-----------------------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
    while true do
        local count = #list
        local wait = IDLE_TICK

        if count > 0 then
            local coords = GetEntityCoords(PlayerPedId())
            local px, py, pz = coords.x, coords.y, coords.z

            local near, nearCount = {}, 0

            for i = 1, count do
                local marker = list[i]
                local pos = marker.pos
                local dx, dy, dz = pos.x - px, pos.y - py, pos.z - pz

                -- +5.0: a streamelesi hatarnal egy kis raadas, hogy a rajzolo
                -- szal mar elindulva erje el a jatekos a lathato tartomanyt --
                -- kulonben a marker fel masodperccel keson jelenne meg.
                local edge = marker.stream + 5.0

                if dx * dx + dy * dy + dz * dz <= edge * edge then
                    nearCount = nearCount + 1
                    near[nearCount] = marker
                end
            end

            streamed, streamedCount = near, nearCount

            if nearCount > 0 then
                wait = STREAM_TICK

                if not rendering then
                    CreateThread(render)
                end
            end
        else
            streamed, streamedCount = {}, 0
        end

        Wait(wait)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    list, index = {}, {}
    streamed, streamedCount = {}, 0
    currentMarker = nil
end)
