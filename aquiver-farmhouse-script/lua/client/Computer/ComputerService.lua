local GetOffsetFromOrigo = require("lua.shared.GetOffsetFromOrigo")

local ComputerService = {}
ComputerService._position = GetOffsetFromOrigo(
    vector3(1.656, 7.75, -1.937)
)
ComputerService._target = -1

function ComputerService:open()
    local canUse = lib.callback.await("Farmhouse::Computer::CanUse", false, true)

    if canUse then
        SendNUIMessage({
            eventName = "SET_ROUTE",
            args = { "/house" }
        })
    end
end

function ComputerService:onNuiMounted()
    SetNuiFocus(true, true)
end

function ComputerService:onNuiUnmounted()
    SetNuiFocus(false, false)
end

function ComputerService:onEnteringInstance()
    self._target = exports["ox_target"]:addSphereZone(
        {
            coords = self._position,
            radius = 0.35,
            drawSprite = true,
            options = {
                {
                    label = locale("OX_COMPUTER_USE"),
                    icon = "fas fa-hand",
                    distance = 2.0,
                    onSelect = function()
                        self:open()
                    end
                }
            }
        }
    )
end

function ComputerService:onLeavingInstance()
    exports["ox_target"]:removeZone(self._target)
end

RegisterNuiCallback("ComputerService::OnMount", function(data, cb)
    ComputerService:onNuiMounted()

    cb("ok")
end)
RegisterNuiCallback("ComputerService::OnUnmount", function(data, cb)
    ComputerService:onNuiUnmounted()

    cb("ok")
end)

return ComputerService
