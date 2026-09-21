-- AFK rendszer client oldal
-- A SAJAT mozgast a kliens figyeli (olcso, es csak spawn utan indul -> nincs AFK
-- a betolto/welcome kepernyon). A szerver csak szetosztja a tobbieknek es admin
-- duty eseten elrejti. A felirat kirajzolasa is itt tortenik.

--local ESX = exports['es_extended']:getSharedObject()

-- [serverId] = afkStartTime (server os.time / unix) ; csak az AFK jatekosokat tartalmazza
local afkList = {}

-- Sajat allapot
local isAfk = false
local forcedAfk = false          -- /afk teszt parancs (szerver engedelyezi)
local spawned = false            -- csak betoltott karakternel szamolunk
local lastPos = nil
local lastMoveTime = GetGameTimer()

-----------------------------------------------------------
-- Szinkronizacio a szerverrel
-----------------------------------------------------------

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    TriggerServerEvent('afk:requestState')
end)

RegisterNetEvent('afk:syncAll', function(list)
    afkList = list or {}
end)

RegisterNetEvent('afk:update', function(serverId, startTime)
    afkList[serverId] = startTime
end)

-- Betoltes jelzese -> innentol szamolhatunk AFK-t
RegisterNetEvent('esx:playerLoaded', function()
    spawned = true
    lastPos = nil
    lastMoveTime = GetGameTimer()
end)

AddEventHandler('playerSpawned', function()
    spawned = true
    lastPos = nil
    lastMoveTime = GetGameTimer()
end)

-- /afk forced toggle a szervertol (a jogosultsag mar ellenorizve szerver oldalon)
RegisterNetEvent('afk:forceToggle', function()
    forcedAfk = not forcedAfk
    isAfk = forcedAfk
    lastMoveTime = GetGameTimer()
    TriggerServerEvent('afk:setState', isAfk)
end)

-----------------------------------------------------------
-- Sajat mozgas figyelese (csak betoltott, elo karakternel)
-----------------------------------------------------------


CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(500) end

    local threshold = Config.MoveThreshold
    local afkMs = Config.AfkTime * 1000
    local selectEnd = 0 -- a spawn-valaszto veget jelzo ido (GetGameTimer)

    while true do
        local ped = PlayerPedId()
        -- halott jatekosnal (ESX) ne szamoljon es ne jelezzen AFK-t
        local dead = ESX.PlayerData and ESX.PlayerData.dead
        -- a SpawnSelector alatt (LocalPlayer.state.spawnSelecting) a karakter szandekosan all
        -- es a jatek nem kap inputot (a NUI kapja az egeret) -> ez nem AFK
        local selecting = LocalPlayer.state.spawnSelecting == true
        if selecting then selectEnd = GetGameTimer() end
        local active = spawned and not selecting and not dead and ped ~= 0 and DoesEntityExist(ped) and not IsEntityDead(ped) and not forcedAfk


        if active then
            -- a valaszto vegetol szamolunk, kulonben a megjelenes utan azonnal AFK lenne
            local diff = math.min(GetTimeSinceLastInput(0), GetGameTimer() - selectEnd)

            if diff < afkMs then
                if isAfk then
                    isAfk = false
                    TriggerServerEvent('afk:setState', false)
                end
            end 

            if not isAfk and diff >= afkMs then
                isAfk = true
                TriggerServerEvent('afk:setState', true)
            end
        else
            -- betoltes / halal alatt ne szamoljunk, es ne ragadjon be AFK
            --lastPos = nil
            --lastMoveTime = GetGameTimer()
            if isAfk and not forcedAfk then
                isAfk = false
                TriggerServerEvent('afk:setState', false)
            end
        end

        Wait(1000)
    end
end)

-----------------------------------------------------------
-- 3D felirat kirajzolasa az AFK jatekosok feje felett
-----------------------------------------------------------

-- yOffset: fuggoleges eltolas a kepernyon (kisebb = feljebb), igy egy DrawOrigin-bol
-- ket sort tudunk rajzolni (AFK felul, szamlalo alatta).
local function drawText3D(x, y, z, text, scale, yOffset)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.0, scale)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(0.0, yOffset)
    ClearDrawOrigin()
end

local function formatTimer(seconds)
    if seconds < 0 then seconds = 0 end
    return string.format('%02d:%02d', math.floor(seconds / 60), seconds % 60)
end

local drawplayers = {}
CreateThread(function()
    local drawDist = Config.DrawDistance
    local label = Config.Label
    local showTimer = Config.ShowTimer
    local heightOffset = Config.HeightOffset or 1.20

    while true do 
        if next(drawplayers) then 
            for ped, elapsed in pairs(drawplayers) do 
                local pos = GetEntityCoords(ped)
                local zTop = pos.z + heightOffset
                drawText3D(pos.x, pos.y, zTop, label, 0.35, -0.018)
                            if elapsed then
                                drawText3D(pos.x, pos.y, zTop, '~y~' .. formatTimer(elapsed), 0.32, 0.0)
                            end
            end 
            Wait(0)
        else 
            Wait(1000)
        end 
    end 
end)

CreateThread(function()
    local drawDist = Config.DrawDistance
    local label = Config.Label
    local showTimer = Config.ShowTimer
    local heightOffset = Config.HeightOffset or 1.20

    while true do
        local sleep = 500 -- ha senki sem AFK a kozelben, lassu thread
        local hasAfk = next(afkList) ~= nil
        drawplayers = {}
        -- a spawn-valaszto varosra nezo kameraja alatt ne rajzoljunk feliratot
        if hasAfk and LocalPlayer.state.spawnSelecting ~= true then
            local myPed = PlayerPedId()
            local myPos = GetEntityCoords(myPed)

            for serverId, startTime in pairs(afkList) do
                local playerId = GetPlayerFromServerId(serverId)
                if playerId ~= -1 then
                    local ped = GetPlayerPed(playerId)
                    if DoesEntityExist(ped) then
                        local pos = GetEntityCoords(ped)
                        local dist = #(myPos - pos)

                        if dist <= drawDist then
                            if showTimer and startTime then
                                drawplayers[ped] = (GetCloudTimeAsInt() - startTime)

                            else 
                                drawplayers[ped] = false 
                            end 

                            --[[sleep = 0 -- van mit rajzolni, gyors thread
                            local zTop = pos.z + heightOffset

                            -- Mindket sort FELFELE rajzoljuk az ankerbol, hogy a nev/ID
                            -- plakat fole keruljon es ne logjon bele.
                            -- Felso sor: AFK
                            drawText3D(pos.x, pos.y, zTop, label, 0.35, -0.018)

                            -- Also sor: szamlalo (kozvetlenul az AFK alatt, de meg a nev felett)
                            if showTimer and startTime then
                                -- client oldalon nincs os.time(), a GetCloudTimeAsInt() ad UTC unix idot
                                local elapsed = GetCloudTimeAsInt() - startTime
                                drawText3D(pos.x, pos.y, zTop, '~y~' .. formatTimer(elapsed), 0.32, 0.0)
                            end]]
                        end
                    end
                end
            end
        end

        Wait(1000)
    end
end)
