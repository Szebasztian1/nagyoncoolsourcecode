Config = {}

Config.Locale = "hu" -- en, hu

Config.Shops = {

    --[[ KIKAPCSOLVA 2026-09-06 - Autokereskedes (-75.02, -1825.47) - nem hasznaljuk
    ["carshop"] = {
        label = "Autókereskedés",
        coords = vector3(-75.0163, -1825.469, 26.9419),
        outsidecoords = vector4(-56.4746, -1838.638, 26.571907, 314.70781), --vector4(-50.93605, -1077.04, 26.908241, 71.600097)
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81), -- set false to disable testing
        testtime = 60*1000, --in ms 
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true, 
        enablebank = true,
        enablefaction = false, 
        sell = {
            coords = vector3(-56.4746, -1838.638, 26.5719),
            pricemultiplier = 0.8,
        },
        blip = {sprite = 225, color = 24},
        job = false,
        vehtype = "car",
        safe = 3130
    },
    --]]
    
}

if not IsDuplicityVersion() then 
    Config.Notify = function(msg)
        TriggerEvent("esx:showNotification", msg)
    end 
end 