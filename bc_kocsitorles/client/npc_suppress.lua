--- @type string[]
local SUPPRESSED_NPC_VEHICLE_MODELS = {
    "blimp",
    "blimp2",
    "frogger",
    "supervolito",
    "swift",
    "blimp3",
}

CreateThread(function()
    while true do
        for _, modelName in pairs(SUPPRESSED_NPC_VEHICLE_MODELS) do
            SetVehicleModelIsSuppressed(modelName, true)
        end
        Wait(5000)
    end
end)

