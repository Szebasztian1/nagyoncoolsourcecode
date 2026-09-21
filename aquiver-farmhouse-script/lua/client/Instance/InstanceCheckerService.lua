local Config = require("lua.shared.Config")

local INTERIOR_ID = GetInteriorAtCoords(Config.INTERIOR_ORIGO.x, Config.INTERIOR_ORIGO.y, Config.INTERIOR_ORIGO.z)

local InstanceCheckerService = {}
InstanceCheckerService._isActive = false

---@private
function InstanceCheckerService:checkNow()
    local localPed = PlayerPedId()
    local interior = GetInteriorFromEntity(localPed)

    if INTERIOR_ID ~= interior then
        TriggerServerEvent("Farmhouse::PlayerLeftInterior")
    end
end

function InstanceCheckerService:onEnteringInstance()
    if not self._isActive then
        self._isActive = true

        Citizen.CreateThread(function()
            while self._isActive do
                Citizen.Wait(2500)

                self:checkNow()
            end
        end)
    end
end

function InstanceCheckerService:onLeavingInstance()
    self._isActive = false
end

return InstanceCheckerService
