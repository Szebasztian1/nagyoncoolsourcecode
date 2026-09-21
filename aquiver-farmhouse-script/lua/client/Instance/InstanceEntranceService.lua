local InstancePresenceService = require("lua.client.Instance.InstancePresenceService")

local InstanceEntranceService = {}
---@type table<number, CPoint>
InstanceEntranceService._entities = {}
---@type CPoint | nil
InstanceEntranceService._exit = nil

---@param instance C_Instance
function InstanceEntranceService:create(instance)
    local id = instance.id

    if self._entities[id] then
        self._entities[id]:remove()
        self._entities[id] = nil
    end

    self._entities[id] = self:createPoint(instance, instance:getPosition())
end

---@param instance C_Instance
function InstanceEntranceService:createExit(instance)
    self:removeExit()
    self._exit = self:createPoint(instance, instance:getInteriorPosition())
end

function InstanceEntranceService:remove(id)
    self._entities[id]:remove()
    self._entities[id] = nil
end

function InstanceEntranceService:removeExit()
    if self._exit then
        self._exit:remove()
        self._exit = nil
    end
end

---@private
---@param instance C_Instance
---@param position vector3
---@return CPoint
function InstanceEntranceService:createPoint(instance, position)
    local point = lib.points.new(
        {
            coords = position,
            distance = 10.0,
            nearby = function(point)
                local distance = point.currentDistance

                Graphics:drawMarker(
                    1,
                    position,
                    vector3(1, 1, 1),
                    { 125, 125, 125, 85 }
                )

                Graphics:drawSprite3D(
                    "aquiver_farmhouse",
                    "farmhouse",
                    position + vector3(0, 0, 0.75),
                    3.0,
                    { 255, 255, 255, 255 }
                )

                Graphics:drawSprite3D(
                    "mpsafecracking",
                    instance.lockState and "lock_closed" or "lock_open",
                    position + vector3(0, 0, 0.5),
                    1.0,
                    { 255, 255, 255, 255 }
                )

                Graphics:drawTextThisFrame3D(
                    position + vector3(0, 0, 0.4),
                    locale('GAME_FARMHOUSE_ENTRANCE', instance.id, instance:getName()),
                    0.2,
                    true
                )

                if distance < 1.5 and IsRawKeyPressed(0x45) then
                    Citizen.CreateThreadNow(function()
                        self:show(instance)
                    end)
                end
            end
        }
    )

    return point
end

---@private
---@param instance C_Instance
function InstanceEntranceService:show(instance)
    local isInAnyHouse = InstancePresenceService:isInAny()
    local isLocalOwner = lib.callback.await("Farmhouse::GetIsLocalOwner", false, instance.id)

    lib.registerContext({
        id = 'farmhouse',
        title = instance:getName(),
        options = {
            {
                title = not isInAnyHouse and locale("MENU_ENTER_INSTANCE") or locale("MENU_LEAVE_INSTANCE"),
                description = not isInAnyHouse and locale("MENU_ENTER_INSTANCE_DESCRIPTION") or
                    locale("MENU_LEAVE_INSTANCE_DESCRIPTION"),
                icon = 'right-to-bracket',
                disabled = false,
                onSelect = function()
                    lib.callback.await(
                        isInAnyHouse and "Farmhouse::Leaving" or "Farmhouse::Entering",
                        false,
                        instance.id
                    )
                end
            },
            {
                title = locale("MENU_PURCHASE_INSTANCE"),
                description = instance:getIsOwnedBySomeone() and locale("MENU_PURCHASE_INSTANCE_NOT_FOR_SALE") or
                    locale("MENU_PURCHASE_INSTANCE_FOR_SALE", locale("CURRENCY", instance.price)),
                icon = 'cart-shopping',
                disabled = instance:getIsOwnedBySomeone(),
                onSelect = function()
                    local status = lib.alertDialog({
                        header = locale("MENU_DIALOG_PURCHASE_TITLE"),
                        content = locale("MENU_DIALOG_PURCHASE_DESCRIPTION"),
                        centered = true,
                        cancel = true
                    })

                    if status == "confirm" then
                        lib.callback.await("Farmhouse::Purchase", false, instance.id)
                    end
                end
            },
            {
                title = locale("MENU_SELL_INSTANCE"),
                description = locale("MENU_SELL_INSTANCE_DESCRIPTION"),
                icon = "hand-holding-dollar",
                disabled = not isLocalOwner,
                onSelect = function()
                    local input = lib.inputDialog(locale("MENU_INPUT_SELL_TITLE"), {
                        {
                            type = "number",
                            label = locale("MENU_INPUT_TARGET"),
                            description = locale("MENU_INPUT_TARGET_DESCRIPTION"),
                            icon = "user",
                            placeholder = locale("MENU_INPUT_TARGET"),
                            required = true,
                            min = 0
                        }
                    })

                    if not input then return end

                    local targetSource = input[1]

                    TriggerServerEvent("Farmhouse::TradeTo", instance.id, targetSource)
                end
            },
            {
                title = locale("MENU_LOCKSTATUS"),
                description = locale("MENU_LOCKSTATUS_DESCRIPTION",
                    instance.lockState and locale("MENU_INSTANCE_LOCKED") or locale("MENU_INSTANCE_UNLOCKED")),
                icon = 'lock',
                onSelect = function()
                    lib.callback.await("Farmhouse::ChangeLockState", false, instance.id)
                end
            },
            {
                title = locale("MENU_RENAME_INSTANCE"),
                description = locale("MENU_RENAME_INSTANCE_DESCRIPTION"),
                icon = 'signature',
                disabled = not isLocalOwner,
                onSelect = function()
                    local input = lib.inputDialog(locale("MENU_INPUT_RENAME_TITLE"), {
                        {
                            type = 'input',
                            label = locale("MENU_INPUT_RENAME_PLACEHOLDER"),
                            description = locale("MENU_INPUT_RENAME_DESCRIPTION"),
                            icon = "signature",
                            placeholder = locale("MENU_INPUT_RENAME_PLACEHOLDER"),
                            required = true
                        }
                    })

                    if not input then return end

                    local newName = input[1]

                    TriggerServerEvent("Farmhouse::Rename", instance.id, newName)
                end
            }
        }
    })

    lib.showContext("farmhouse")
end

return InstanceEntranceService
