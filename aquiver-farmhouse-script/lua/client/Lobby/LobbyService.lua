local Config = require("lua.shared.Config")

local LobbyService = {}
LobbyService._position = Config.LOBBY_POSITION
LobbyService._blip = -1
LobbyService._point = -1

function LobbyService:onMounted()
    SetNuiFocus(true, true)
end

function LobbyService:onUnmounted()
    SetNuiFocus(false, false)
end

---@private
function LobbyService:open()
    SendNUIMessage(
        {
            eventName = "SET_ROUTE",
            args = { "/lobby" }
        }
    )
end

function LobbyService:onResourceStart()
    if not Config.USE_LOBBY_ENTRANCE then return end

    self._blip = AddBlipForCoord(self._position.x, self._position.y, self._position.z)
    SetBlipSprite(self._blip, Config.LOBBY_BLIP_SPRITE)
    SetBlipAsShortRange(self._blip, Config.LOBBY_BLIP_SHORTRANGE)
    SetBlipColour(self._blip, Config.LOBBY_BLIP_COLOR)
    AddTextEntry('MYBLIP', locale("LOBBY_BLIP_NAME"))
    BeginTextCommandSetBlipName('MYBLIP')
    EndTextCommandSetBlipName(self._blip)

    self._point = lib.points.new({
        coords = self._position,
        distance = 12.5,
        nearby = function(point)
            local distance = point.currentDistance

            Graphics:drawSprite3D(
                "aquiver_farmhouse",
                "farmhouse",
                self._position,
                3.0,
                { 255, 255, 255, 255 }
            )

            Graphics:drawMarker(
                1,
                self._position + vector3(0, 0, -0.75),
                vector3(1.5, 1.5, 1.5),
                { 100, 100, 100, 100 },
                vector3(0, 0, 0),
                vector3(0, 0, 0),
                false,
                false,
                false
            )

            if distance < 5.0 then
                Graphics:drawTextThisFrame3D(
                    self._position + vector3(0, 0, 0.5),
                    locale("LOBBY_TEXTLABEL"),
                    0.25,
                    true
                )
            end

            if distance < 1.5 then
                if IsRawKeyPressed(0x45) then
                    self:open()
                end
            end
        end
    })
end

return LobbyService
