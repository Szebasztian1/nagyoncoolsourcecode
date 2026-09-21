-- BC Express – depo indító + leadó + kiszállás-kocsi marker.
--
-- Saját marker rendszer (client/markers.lua), a mate-markers helyett: nincs export-
-- határátlépés, üresjáratban alszik, a lebegtetés pedig natív marker-flag (`upDown`) –
-- ezért tűnt el az a külön szál, ami 15 ms-enként tologatta a markerek pozícióját.

local Core = require 'client.modules.core'

local Markers = {}

function Markers.registerStartMarkers()
    for i = 1, #Config.StartMarkers do
        local m = Config.StartMarkers[i]
        local base = vector3(m.x, m.y, m.z)
        BCMarker.Add({
            id             = 'start_' .. i,
            pos            = base,
            typ            = Config.Marker.typ,
            scale          = Config.Marker.scale,
            color          = Config.Marker.startColor,
            streamDistance = Config.Marker.streamDistance,
            upDown         = true,
            canInteract    = function()
                if Core.jobActive then return false end
                Core.DrawText3D(base.x, base.y, base.z + 0.9, Config.StartPrompt)   -- "[E] Munka felvétele" a marker fölött
                return true
            end,
            onInteract     = function() Core.startJob(i) end,
        })
    end
end

function Markers.addReturnMarker(pos)
    local r = pos or Config.ReturnPoint
    BCMarker.Add({
        id             = 'return',
        pos            = vector3(r.x, r.y, r.z),
        typ            = Config.Marker.typ,
        scale          = Config.Marker.scale,
        color          = Config.Marker.returnIdle,
        streamDistance = Config.Marker.streamDistance,
        upDown         = true,
        -- csak vizuális jelzés: az E-t a munka-loop figyeli nagyobb zónában (Config.ReturnRadius),
        -- mert a marker saját zónája furgonnal túl szűk
        canInteract    = function() return false end,
    })
end

function Markers.removeReturnMarker()
    BCMarker.Remove('return')
end

function Markers.addCarMarker()
    if Core.carMarkerOn or not Core.jobVeh or not DoesEntityExist(Core.jobVeh) then return end
    local c = GetEntityCoords(Core.jobVeh)
    BCMarker.Add({
        id             = 'jobcar',
        pos            = vector3(c.x, c.y, c.z + 1.0),
        typ            = Config.Marker.typ,
        scale          = Config.Marker.scale,
        color          = Config.Marker.carColor,
        streamDistance = 80.0,
        upDown         = true,
    })
    Core.carMarkerOn = true
end

function Markers.removeCarMarker()
    if not Core.carMarkerOn then return end
    BCMarker.Remove('jobcar')
    Core.carMarkerOn = false
end

-- Térkép-blip a kocsira (azonnal kiszálláskor). Entity-blip: követi a járművet, törléskor magától eltűnik.
function Markers.addCarBlip()
    if Core.carBlip or not Core.jobVeh or not DoesEntityExist(Core.jobVeh) then return end
    local b = AddBlipForEntity(Core.jobVeh)
    SetBlipSprite(b, Config.CarBlip.sprite)
    SetBlipColour(b, Config.CarBlip.color)
    SetBlipScale(b, Config.CarBlip.scale)
    SetBlipAsShortRange(b, Config.CarBlip.shortRange)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.CarBlip.label)
    EndTextCommandSetBlipName(b)
    Core.carBlip = b
end

function Markers.removeCarBlip()
    if Core.carBlip then
        RemoveBlip(Core.carBlip)
        Core.carBlip = nil
    end
end

-- A lebegtetés natív marker-flag (`upDown` a fenti Add hívásokban), ezért az a szál,
-- ami 15 ms-enként új pozíciót írt minden markerre, megszűnt.

return Markers
