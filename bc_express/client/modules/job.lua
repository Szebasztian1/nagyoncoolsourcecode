-- BC Express – kliens munka-életciklus: start/return/abandon, fő munka-loop, timer-HUD.
-- A markerek ezt a modult a Core.startJob / Core.returnCar slotokon át érik el.

local Core    = require 'client.modules.core'
local Markers = require 'client.modules.markers'
local Vehicle = require 'client.modules.vehicle'
local Box     = require 'client.modules.box'
local Outfit  = require 'client.modules.outfit'

local Job = {}

local AbandonJob   -- forward (a munka-loop hivatkozik rá timeoutnál)

-----------------------------------------------------------------------------------------------------------------------------------------
-- Timer HUD (native, Wait(0) csak amíg ki van szállva)
-----------------------------------------------------------------------------------------------------------------------------------------

local function startTimerHud()
    if Core.hudRunning then return end
    Core.hudRunning = true
    CreateThread(function()
        while Core.jobActive and Core.returnEndAt do
            local left = math.ceil((Core.returnEndAt - GetGameTimer()) / 1000)
            if left < 0 then left = 0 end
            Core.DrawTimer2D(('VISSZA A KOCSIBA: %d:%02d'):format(math.floor(left / 60), left % 60))
            Wait(0)
        end
        Core.hudRunning = false
    end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Fő munka-loop (Wait 500): timer, leadó marker szín, törékeny sebesség-figyelés
-----------------------------------------------------------------------------------------------------------------------------------------

local function startJobLoop()
    CreateThread(function()
        while Core.jobActive do
            local incar = Core.inJobCar()

            BCMarker.Update('return', 'color',
                incar and Config.Marker.returnActive or Config.Marker.returnIdle)

            if incar then
                if Core.returnEndAt or Core.outSince then
                    Core.returnEndAt = nil
                    Core.outSince = nil
                    Markers.removeCarMarker()
                    Markers.removeCarBlip()
                end
                -- törékeny csomag + túl gyors → throttle-olt jelzés a szervernek
                if Core.fragileActive then
                    local speed = GetEntitySpeed(Core.jobVeh)
                    if speed > Config.FragileSpeedLimit then
                        local now = GetGameTimer()
                        if (now - Core.lastStressAt) >= Config.FragileStressInterval then
                            Core.lastStressAt = now
                            TriggerServerEvent('bc_express:fragileStress')
                        end
                    end
                end
                -- kocsi-leadás: a leadó marker csak vizuális, az E-t itt figyeljük nagyobb zónában
                -- (Wait(0) csak amíg tényleg a leadó ponton áll a kocsival)
                -- Indulás után 2 mp türelmi idő: a kocsi a felvétel markerénél spawnol (= leadó zóna),
                -- így a munkafelvétel E-je (nyomva tartva / duplán ütve) azonnal le is adná a kocsit.
                local rp = Core.returnPos
                if rp and (GetGameTimer() - Core.jobStartedAt) >= 2000
                    and #(GetEntityCoords(PlayerPedId()) - rp) < Config.ReturnRadius then
                    while Core.jobActive and Core.inJobCar()
                        and #(GetEntityCoords(PlayerPedId()) - rp) < Config.ReturnRadius do
                        Core.DrawText3D(rp.x, rp.y, rp.z + 0.9, Config.ReturnPrompt)
                        if IsControlJustReleased(0, 38) then
                            Core.returnCar()
                            break
                        end
                        Wait(0)
                    end
                end
            else
                -- a visszaszámláló csak min. ReturnGrace mp folyamatos kiszállás UTÁN indul
                if not Core.outSince then
                    Core.outSince = GetGameTimer()
                    Markers.addCarBlip()   -- azonnali térkép-blip kiszálláskor
                end
                if not Core.returnEndAt then
                    if (GetGameTimer() - Core.outSince) >= (Config.ReturnGrace * 1000) then
                        Core.returnEndAt = GetGameTimer() + (Config.ReturnTime * 1000)
                        Markers.addCarMarker()
                        startTimerHud()
                    end
                elseif (Core.returnEndAt - GetGameTimer()) <= 0 then
                    AbandonJob()
                    return
                end
            end

            Wait(500)
        end
    end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Munka életciklus
-----------------------------------------------------------------------------------------------------------------------------------------

local function endJob()
    Core.jobActive = false
    Outfit.restore()
    Box.clearBox()
    Vehicle.deleteCar()
    Markers.removeCarMarker()
    Markers.removeCarBlip()
    Markers.removeReturnMarker()
    Core.returnEndAt = nil
    Core.outSince = nil
    Core.returnPos = nil
    Core.jobStartedAt = 0
    Core.fragileActive = false
    Core.jobData = nil
end
Job.endJob = endJob

local function TryStartJob(markerIndex)
    if Core.jobActive or Core.jobStarting then return end
    Core.jobStarting = true
    local res = lib.callback.await('bc_express:startJob', false, markerIndex)
    Core.jobStarting = false
    -- telefon nélkül NINCS értesítés (és nincs munka) – csendben kilépünk
    if not res or not res.ok then return end

    Core.jobActive = true
    Core.fragileActive = res.hasFragile == true
    Core.jobData = {
        addresses    = res.addresses,
        currentIndex = res.current,
        size         = res.size,
        state        = 'driving',
    }

    if not Vehicle.spawnCar(res.spawn, res.model) then
        -- a modell nem töltődött be: azonnal bontjuk a szerver-oldali munkát is,
        -- különben kocsi nélkül ragadna be a 3 perces timeoutig
        TriggerServerEvent('bc_express:abandon')
        endJob()
        return
    end
    Core.returnPos = vector3(res.spawn.x, res.spawn.y, res.spawn.z)   -- ide kell visszahozni a kocsit
    Core.jobStartedAt = GetGameTimer()
    Outfit.apply()
    Config.PlayVoice('welcome')
    Markers.addReturnMarker(Core.returnPos)
    startJobLoop()

    -- életében először ül be a kocsiba: egyszeri, képernyő-közepi bemutató az automatáról
    if res.intro then
        lib.alertDialog({
            header = 'Csomagautomaták',
            content = table.concat({
                '![automata](nui://bc_express/html/img/automata.webp)',
                '',
                'Minden címen egy ilyen **csomagautomatát** találsz – ide kell betenned a kiszállítandó dobozt.',
                'Vedd ki a dobozt a furgon rakteréből, hajts a kijelölt címhez, és a közelben keresd meg az automatát a lerakáshoz.',
            }, '\n'),
            centered = true,
            size = 'md',
        })
    end

    local a = Core.jobData.addresses[Core.jobData.currentIndex]
    if a then Core.markCoords(vector3(a.x, a.y, a.z)) end
end

local function TryReturnCar()
    if not Core.jobActive then return end
    -- bármikor leadható: a már teljesített címek díját fizeti ki a szerver (részleges kör is)
    if not Core.inJobCar() then return end
    local res = lib.callback.await('bc_express:returnCar', false)
    if not res or not res.ok then
        Core.phoneNotify('BC Express', 'A leadás sikertelen.')
        return
    end
    Config.PlayVoice('payday')
    endJob()
end

AbandonJob = function()
    TriggerServerEvent('bc_express:abandon')
    Config.PlayVoice('fired')
    endJob()
end

-- a markerek ezeken a slotokon át indítják/zárják a munkát
Core.startJob  = TryStartJob
Core.returnCar = TryReturnCar

return Job
