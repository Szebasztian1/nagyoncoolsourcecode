-- BC Express – kliens közös állapot + rajz/segéd-helperek.
-- Minden modul ezt a táblát osztja (állapot-mezők), így a mutációk láthatók mindenhol.
-- A startJob/returnCar "slot"-okat a job (életciklus) modul tölti fel → így a markers nem
-- függ körkörösen az életciklustól.

local Core = {}

-- megosztott állapot
Core.jobActive    = false
Core.jobStarting  = false -- startJob callback folyamatban (dupla E-nyomás elleni védelem)
Core.jobStartedAt = 0     -- a kocsi átvételének ideje (a leadó E-figyelő türelmi idejéhez)
Core.jobData      = nil   -- { addresses, currentIndex, size, state }
Core.jobVeh       = nil
Core.carryingBox  = false
Core.boxObj       = nil
Core.carMarkerOn  = false
Core.carBlip      = nil   -- a kiszálláskor a kocsira tett térkép-blip handle
Core.returnEndAt  = nil
Core.outSince     = nil   -- mióta van kiszállva (grace-hez)
Core.hudRunning   = false
Core.fragileActive = false
Core.lastStressAt = 0
-- (a lebegtetés natív marker-flag lett, a régi bobMarkers tábla megszűnt)
Core.returnPos    = nil   -- a használt indító marker koordinátája (spawn + leadás)

Core.CARRY_DICT   = 'anim@heists@box_carry@'

-- életciklus-belépők (a job modul tölti); a markerek ezeken keresztül indítják/zárják a munkát
Core.startJob  = function(markerIndex) end
Core.returnCar = function() end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Értesítés CSAK telefonra (roadphone) – nincs ox_lib notify
-----------------------------------------------------------------------------------------------------------------------------------------

function Core.phoneNotify(title, msg)
    TriggerEvent('roadphone:sendNotification', {
        apptitle = 'BC Express',
        title    = title,
        message  = msg,
        img      = '/public/img/Apps/light_mode/service.webp',
    })
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Rajzoló segédek (native, nem ox_lib)
-----------------------------------------------------------------------------------------------------------------------------------------

function Core.DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.34, 0.34)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 220)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)   -- nincs háttér-doboz (árnyék)
    ClearDrawOrigin()
end

function Core.DrawTimer2D(text)
    SetTextFont(4)
    SetTextScale(0.6, 0.6)
    SetTextColour(255, 90, 90, 235)
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(0.5, 0.46)   -- képernyő közepére, háttér/árnyék nélkül
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Állapot-olvasó segédek
-----------------------------------------------------------------------------------------------------------------------------------------

function Core.inJobCar()
    if not Core.jobVeh or not DoesEntityExist(Core.jobVeh) then return false end
    return GetVehiclePedIsIn(PlayerPedId(), false) == Core.jobVeh
end

function Core.hasActiveTarget()
    if not Core.jobActive or not Core.jobData or Core.jobData.state ~= 'driving' then return false end
    local a = Core.jobData.addresses[Core.jobData.currentIndex]
    return a ~= nil and not a.done
end

-- csak az aktuális cím közelében lehet dobozt kivenni a kocsiból (oda kell érni előbb)
function Core.nearActiveAddress(maxDist)
    if not Core.jobData then return false end
    local a = Core.jobData.addresses[Core.jobData.currentIndex]
    if not a then return false end
    return #(GetEntityCoords(PlayerPedId()) - vector3(a.x, a.y, a.z)) <= maxDist
end

-- EGY jelölés elve: csak waypoint (a játék rajzol hozzá útvonalat), nincs külön blip + lila route.
function Core.markCoords(coords)
    SetNewWaypoint(coords.x, coords.y)
end

function Core.SetReturnPhase()
    Core.jobData.state = 'returning'
    local r = Core.returnPos or Config.ReturnPoint   -- a felvétel markeréhez vezet vissza
    Core.markCoords(vector3(r.x, r.y, r.z))
end

return Core
