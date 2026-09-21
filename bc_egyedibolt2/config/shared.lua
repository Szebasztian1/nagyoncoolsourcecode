Config = {}

Config.Locale = "hu" -- en, hu

Config.Shops = {

    --[[ KIKAPCSOLVA 2026-09-01 - MSK Cars autokereskedes (-38.67, -1672.77)
    ["carshop"] = {
        label = "Autókereskedés",
        coords = vector3(-38.67369, -1672.772, 29.479727),
        outsidecoords = vector4(-35.82835, -1682.984, 29.409189, 209.98918), --vector4(-50.93605, -1077.04, 26.908241, 71.600097)
        testcoords = vector4(-1735.94, -2926.65, 13.5, 314.81), -- set false to disable testing
        testtime = 60*1000, --in ms 
        showroom = vector4(-46.1, -1096.43, 25.71, 230.0),
        showroomcam = vector3(-45.54, -1100.37, 27.42),
        enablecash = true, 
        enablebank = true,
        enablefaction = false, 
        sell = {
            coords = vector3(-29.84478, -1674.838, 29.491825),
            pricemultiplier = 0.8,
        },
        blip = {sprite = 225, color = 24},
        job = false,
        vehtype = "car",
        safe = 3174
    },
    --]]

}

if not IsDuplicityVersion() then 
    Config.Notify = function(msg)
        TriggerEvent("esx:showNotification", msg)
    end 
end 