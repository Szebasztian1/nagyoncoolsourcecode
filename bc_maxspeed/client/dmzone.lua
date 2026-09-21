--- @module dmzone

--- @type boolean
local isInDMZone = false

--- @return boolean
local function IsInDMZone()
    return isInDMZone
end

exports("isInDMZone", IsInDMZone)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local inside = false

        for _, zone in ipairs(Config.DMZones) do
            if #(zone.c - coords) < zone.r then
                inside = true
                break
            end
        end

        isInDMZone = inside

        SetPedConfigFlag(PlayerPedId(), 438, true)

        Wait(1000)
    end
end)
