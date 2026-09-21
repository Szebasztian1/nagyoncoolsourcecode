local TeleportPoints <const> = {
    vector3(1554.606567, 3591.257080, 39.715698),
    vector3(1119.204346, -3193.476807, -40.394165)
}

-- Terkep-blip a bejaratnal. A user kerte le (2026-09-16): true-ra allitva
-- visszajon, a blipek menu "Pénzmosó" (illegalis) sora ilyenkor kapcsolja.
local SHOW_BLIP <const> = false

CreateThread(function()
    if not SHOW_BLIP then return end

    local blip = AddBlipForCoord(1554.606567, 3591.257080, 38.715698)

    SetBlipSprite(blip, 408)
    SetBlipColour(blip, 0)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Pénzmosó")
    EndTextCommandSetBlipName(blip)
end)

for i = 1, #TeleportPoints do
    local targetIndex = (i == #TeleportPoints) and 1 or (i + 1)
    local targetPoint = TeleportPoints[targetIndex]
    local title <const> = targetIndex == 2 and 'Belépés a pénzmosóba' or 'Pénzmosó elhagyása'

    -- Sajat marker rendszer (markers.lua). A mate-markers a `help` mezot soha nem
    -- rajzolta ki -- itt `label`, es tenyleg megjelenik, amig a jatekos benne all.
    BCMarker.Add({
        id             = "teleport_" .. i,
        pos            = TeleportPoints[i],
        typ            = 2,
        scale          = vector3(1.5, 1.5, 1.5),
        color          = { 0, 150, 255, 150 },
        streamDistance = 20.0,
        upDown         = true,
        label          = "Nyomj ~INPUT_CONTEXT~ hogy be/kimenj a pénzmosodából",
        onInteract     = function()
            exports['rota_loading']:TeleportWithLoading(targetPoint, 500, title)
        end
    })
end

BCMarker.Add({
    id             = "moneywash_interact",
    pos            = vector3(1122.210938, -3194.716553, -40.411011),
    typ            = 2,
    scale          = vector3(1.5, 1.5, 1.5),
    color          = { 0, 150, 255, 150 },
    streamDistance = 10.0,
    upDown         = true,
    label          = "Nyomj ~INPUT_CONTEXT~ a pénzmosáshoz",
    onInteract     = function()
        OpenMoneyWash()
    end
})

function OpenMoneyWash()
    local input = lib.inputDialog('Pénzmosás', {
        { type = 'number', label = 'Összeg', description = 'Mekkora összeget mosnál? 10% díj érvényben!', required = true }
    })
    if not input then return end
    local amount = input[1]
    if not amount or amount <= 0 then
        return
    end

    local suc = lib.callback.await('bc_moneywash:start', false, amount)
    if not suc then
        lib.notify({
            title = 'Pénzmosás',
            description = 'Nincs elég tisztítandó pénzed vagy foglalt a pénzmosó!',
            type = 'error'
        })
    end

    Citizen.CreateThread(function()
        lib.progressCircle({
            duration = 120 * 1000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
            },
            anim = {
                scenario = 'PROP_HUMAN_BUM_BIN'
            },
        })
    end)

    DeactivateInteriorEntitySet(247809, "dryera_off")
    DeactivateInteriorEntitySet(247809, "dryera_on")
    ActivateInteriorEntitySet(247809, "dryera_open")
    RefreshInterior(247809)

    SetEntityHeading(PlayerPedId(), 2.1)

    TaskStartScenarioInPlace(PlayerPedId(), 'PROP_HUMAN_BUM_BIN', 0, true)

    Citizen.Wait(10 * 1000)

    ClearPedTasks(PlayerPedId())

    DeactivateInteriorEntitySet(247809, "dryera_off")
    ActivateInteriorEntitySet(247809, "dryera_on")
    DeactivateInteriorEntitySet(247809, "dryera_open")
    RefreshInterior(247809)

    Citizen.Wait(100 * 1000)

    DeactivateInteriorEntitySet(247809, "dryera_off")
    DeactivateInteriorEntitySet(247809, "dryera_on")
    ActivateInteriorEntitySet(247809, "dryera_open")
    RefreshInterior(247809)

    TaskStartScenarioInPlace(PlayerPedId(), 'PROP_HUMAN_BUM_BIN', 0, true)

    Citizen.Wait(10 * 1000)

    ClearPedTasks(PlayerPedId())
end
