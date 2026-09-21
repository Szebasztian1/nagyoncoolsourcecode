-- BC Express – client entry.
-- Modulok betöltése (require) + resource start/stop bekötése. Csak ez van a client_scripts-ben.

local Core    = require 'client.modules.core'
local Markers = require 'client.modules.markers'
local Job     = require 'client.modules.job'        -- behúzza: box, vehicle
local Panel   = require 'client.modules.panel'
require 'client.modules.phoneapp'

AddEventHandler('onClientResourceStart', function(res)
    if res == GetCurrentResourceName() then
        Markers.registerStartMarkers()
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if Core.jobActive then Job.endJob() end
    Panel.onStop()
end)
