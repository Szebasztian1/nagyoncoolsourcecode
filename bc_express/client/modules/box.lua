-- BC Express – doboz: kivétel a raktérből (carry-anim + prop), behelyezés az automatába.

local Core = require 'client.modules.core'

local Box = {}

local function carryLoop()
    CreateThread(function()
        RequestAnimDict(Core.CARRY_DICT)
        local t = 0
        while not HasAnimDictLoaded(Core.CARRY_DICT) and t < 100 do Wait(10) t = t + 1 end
        local ped = PlayerPedId()
        while Core.carryingBox and DoesEntityExist(ped) do
            if not IsEntityPlayingAnim(ped, Core.CARRY_DICT, 'idle', 3) then
                TaskPlayAnim(ped, Core.CARRY_DICT, 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
            end
            Wait(700)
        end
    end)
end

function Box.clearBox()
    if Core.boxObj and DoesEntityExist(Core.boxObj) then
        DetachEntity(Core.boxObj, true, true)
        DeleteEntity(Core.boxObj)
    end
    Core.boxObj = nil
    Core.carryingBox = false
    ClearPedTasks(PlayerPedId())
end

function Box.pickupBox()
    if Core.carryingBox or not Core.hasActiveTarget() then return end

    -- előbb a carry-anim, hogy a kéz a helyén legyen, utána tapad a doboz (így nem buggos)
    local ped = PlayerPedId()
    RequestAnimDict(Core.CARRY_DICT)
    local t = 0
    while not HasAnimDictLoaded(Core.CARRY_DICT) and t < 100 do Wait(10) t = t + 1 end
    TaskPlayAnim(ped, Core.CARRY_DICT, 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)

    local ok = lib.progressBar({
        duration = 2000, label = 'Doboz kivétele a raktérből...',
        useWhileDead = false, canCancel = true,
        disable = { move = true, car = true, combat = true },
    })
    if not ok then ClearPedTasks(ped) return end

    local model = joaat(Config.BoxProp)
    RequestModel(model)
    t = 0
    while not HasModelLoaded(model) and t < 100 do Wait(10) t = t + 1 end

    local c = GetEntityCoords(ped)
    Core.boxObj = CreateObject(model, c.x, c.y, c.z + 0.2, true, true, false)
    -- bc_kocsitorles: legalis spawn jelolese
    if Core.boxObj and Core.boxObj ~= 0 and NetworkGetEntityIsNetworked(Core.boxObj) then Entity(Core.boxObj).state:set('bc_spawned', true, true) end
    -- jobb kéz csontja (60309) + bevált carry-offset, hogy a kéz előtt, két kézzel fogva legyen
    AttachEntityToEntity(Core.boxObj, ped, GetPedBoneIndex(ped, 60309),
        0.025, 0.08, 0.255, -145.0, -85.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)

    Core.carryingBox = true
    carryLoop()
    Config.PlayVoice('pickup')
    Core.phoneNotify('BC Express', 'Doboz felvéve – vidd az automatához!')
end

function Box.depositBox(entityCoords)
    if not Core.carryingBox then return end
    local a = Core.jobData.addresses[Core.jobData.currentIndex]
    if not a or #(entityCoords - vector3(a.x, a.y, a.z)) > Config.DeliverRadius then
        Core.phoneNotify('BC Express', 'Ez nem a te címed automatája.')
        return
    end

    local ok = lib.progressBar({
        duration = 2500, label = 'Doboz behelyezése az automatába...',
        useWhileDead = false, canCancel = true,
        disable = { move = true, car = true, combat = true },
    })
    if not ok then return end

    local res = lib.callback.await('bc_express:deliverBox', false)
    if not res or not res.ok then
        Core.phoneNotify('BC Express', 'Sikertelen leadás. Állj közelebb az automatához.')
        return
    end

    Box.clearBox()

    if a then a.done = true end
    if res.fragile then Core.fragileActive = false end   -- a törékenyt leadtuk, mehet gyorsabban

    if res.done then
        -- utolsó cím: nincs "delivered" hang, csak az SMS (szerver küldi: "vidd vissza a kocsit...")
        Core.SetReturnPhase()
    else
        Config.PlayVoice('delivered')
        Core.jobData.currentIndex = res.nextIndex
        local n = Core.jobData.addresses[res.nextIndex]
        if n then Core.markCoords(vector3(n.x, n.y, n.z)) end
    end
end

-- ox_target: automata prop (egyszer regisztrálva). A "Doboz behelyezése" csak munka közben, dobozzal.
CreateThread(function()
    exports.ox_target:addModel(Config.AutomataModel, {
        {
            name = 'bcx_deposit', icon = 'fa-solid fa-box-open', label = 'Doboz behelyezése', distance = 2.5,
            canInteract = function() return Core.jobActive and Core.carryingBox end,
            onSelect = function(data) Box.depositBox(GetEntityCoords(data.entity)) end,
        }
    })
end)

return Box
