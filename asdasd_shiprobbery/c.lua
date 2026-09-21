Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

local MissionDatas = {}
local mothershipBlip = nil

local boatPedEntity = nil

CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    -- Spawn the boat renter ped only when the player is nearby (ox_lib zone)
    local x, y, z, h = table.unpack(Config.BoatRenterPos)
    lib.zones.sphere({
        coords = vector3(x, y, z),
        radius = 20.0,
        onEnter = function()
            if not DoesEntityExist(boatPedEntity) then
                LoadModel("a_m_m_og_boss_01")
                boatPedEntity = CreatePed(4, "a_m_m_og_boss_01", Config.BoatRenterPos, false, false)
                FreezeEntityPosition(boatPedEntity, true)
                SetBlockingOfNonTemporaryEvents(boatPedEntity, true)
            end
        end,
        onExit = function()
            if DoesEntityExist(boatPedEntity) then
                DeleteEntity(boatPedEntity)
                boatPedEntity = nil
            end
        end,
    })

    -- ElectronAC antiKill zona: a szervernek jelzunk, ha valaki a hajo kore er, hogy
    -- ne kelljen ott az OSSZES jatekost vegigpasztaznia. A tenyleges tavolsag-
    -- ellenorzes a szerveren tortenik (s.lua), ez csak jelzes.
    lib.zones.sphere({
        coords = Config.MotherShipPos,
        radius = 150.0,
        onEnter = function()
            TriggerServerEvent("asdasd_shiprobbery:ackZoneEnter")
        end,
        onExit = function()
            TriggerServerEvent("asdasd_shiprobbery:ackZoneExit")
        end,
        debug = false
    })

    MissionDatas["started"] = false
    CreateThread(MissionLoops)
    CreateThread(LootLoops)
    CreateThread(BoatPedInteract)
end)

------------------ LOOPS ---------------------

function LootLoops()
    while true do
        sleep = 1000

        if MissionDatas["lootable"] and MissionDatas["looted"] then
            local myped = PlayerPedId()
            local mycoords = GetEntityCoords(myped)


            for i, v in ipairs(Loot.positions) do
                local distance = #(mycoords - vector3(v.x, v.y, v.z))

                if distance < 30.0 and not IsLooted(v.id) then
                    sleep = 0

                    DrawMarker(0, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 0, 255, 255, 200, 1, 0, 0, 0)

                    if distance < 5.5 then
                        DrawText3D(v.x, v.y, v.z - 1.0,
                            'Nyomj [~g~E~s~] gombot a láda ~b~Feltöréséhez \n ~g~Minöség: ~s~' .. v.loottype)

                        if IsControlJustReleased(1, 38) then
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            local attach = GetEntityAttachedTo(myped)
                            local thactive = false
                            if closestDistance > 5.0 or closestPlayer == -1 then
                                if attach and attach ~= 0 and DoesEntityExist(attach) then
                                    -- exports['okokNotify']:Alert("Anyahajó Rablás",
                                    -- 	"Túl közel van hozzád egy játékos!", 3000, 'error')
                                else
                                    if thactive then
                                        -- exports['okokNotify']:Alert("Anyahajó Rablás",
                                        -- 	"Túl közel van hozzád egy játékos!", 3000, 'error')
                                    else
                                        local success = startpicklock(v.locks)

                                        if success then
                                            exports["gs_eventprotect"]:GS_TriggerServerEvent(
                                                'asdasd_shiprobbery_loot', success, v.loottype, v.id)
                                        else
                                            exports["gs_eventprotect"]:GS_TriggerServerEvent(
                                                'asdasd_shiprobbery_loot', success, v.loottype, v.id)
                                            exports['okokNotify']:Alert("Anyahajó Rablás",
                                                "Nem sikerült feltörnöd a ládát!", 5000, 'error')
                                        end
                                        Wait(1000)
                                    end
                                end
                            else
                                exports['okokNotify']:Alert("Anyahajó Rablás", "Túl közel van hozzád egy játékos!",
                                    3000, 'error')
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end

local blips = {}

function MissionLoops()
    while true do
        sleep = 1000

        local myped = PlayerPedId()
        local mycoords = GetEntityCoords(myped)

        local distance = #(mycoords - Config.MotherShipPos)

        if MissionDatas["firstKillHappened"] and not mothershipBlip then
            mothershipBlip = AddBlipForCoord(Config.MotherShipPos)
            SetBlipSprite(mothershipBlip, 161)
            SetBlipDisplay(mothershipBlip, 4)
            SetBlipScale(mothershipBlip, 1.0)
            SetBlipColour(mothershipBlip, 1)
            SetBlipAsShortRange(mothershipBlip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Anyahajó Rablás")
            EndTextCommandSetBlipName(mothershipBlip)
        end

        if distance <= 250.0 then
            -- PAYLOAD (2026-09-06): a szerver mar nem a teljes guardpeds tablat
            -- kuldi (benne a kliensen ertelmetlen szerveroldali "id" mezovel),
            -- hanem egy sima netid-tombot. A debug printek is kikerultek: ez a
            -- ciklus masodpercenkent fut, oronkent 4 sort irt a konzolba.
            if MissionDatas["playersinship"] and MissionDatas["guardnetids"] and MissionDatas["allpedspawned"] then
                local validnetids = {}
                for i = 1, #MissionDatas["guardnetids"] do
                    local netid = MissionDatas["guardnetids"][i]
                    if netid then
                        local rentity = NetworkGetEntityFromNetworkId(netid)
                        if rentity and DoesEntityExist(rentity) and not IsPedDeadOrDying(rentity, true) and (GetEntityHealth(rentity) > 1) then
                            validnetids[netid] = true
                            if not blips[netid] then
                                blips[netid] = AddBlipForEntity(rentity)
                                SetBlipSprite(blips[netid], 1)
                                SetBlipScale(blips[netid], 0.6)
                                SetBlipColour(blips[netid], 2)
                                SetBlipAsShortRange(blips[netid], true)
                            end
                        else
                            validnetids[netid] = false
                            if blips[netid] then
                                RemoveBlip(blips[netid])
                                blips[netid] = nil
                            end
                        end
                    end
                end

                for k, v in pairs(blips) do
                    if not validnetids[k] then
                        RemoveBlip(v)
                        blips[k] = nil
                    end
                end

                if #MissionDatas["guardnetids"] <= 0 then
                    if not MissionDatas["lootable"] then
                        MissionDatas["lootable"] = true

                        TriggerServerEvent("asdasd_shiprobbery_lootable")
                    end
                end

                local stats = {}

                if #MissionDatas["playersinship"] >= 2 then
                    table.sort(MissionDatas["playersinship"], function(a, b) return a.kill > b.kill end)
                end

                for i, v in ipairs(MissionDatas["playersinship"]) do
                    if i <= 5 then
                        table.insert(stats, { rank = i, name = v.playername, kill = v.kill })
                    end
                end

                SendNUIMessage({
                    type = "open",
                    remaining = #MissionDatas["guardnetids"],
                    stats = stats
                })
            end

            if not MissionDatas["started"] or not OnShip() then
                MissionDatas["started"] = true

                TriggerServerEvent("asdasd_shiprobbery_start")
            end
        else
            for k, v in pairs(blips) do
                RemoveBlip(v)
            end
            blips = {}

            SendNUIMessage({
                type = "close"
            })
        end
        Wait(sleep)
    end
end

function OnShip()
    if not MissionDatas["playersinship"] then
        return false
    end

    for i, v in ipairs(MissionDatas["playersinship"]) do
        if v.serverid == GetPlayerServerId(PlayerId()) then
            return true
        end
    end
    return false
end

-- Interaction loop for the boat renter ped (runs independently of zone)
function BoatPedInteract()
    while true do
        sleep = 1000

        if DoesEntityExist(boatPedEntity) then
            local myped = PlayerPedId()
            local mycoords = GetEntityCoords(myped)
            local x, y, z, h = table.unpack(Config.BoatRenterPos)

            local distance = #(mycoords - vector3(x, y, z))

            if distance < 2.0 then
                sleep = 0

                Draw3DText(vector3(x, y, z + 1.5), "Nyomj [~g~E~s~] gombot a hajó bérléséhez")

                if IsControlJustReleased(0, 38) then
                    OpenBoatRenterMenu()
                end
            end
        end
        Wait(sleep)
    end
end

----------------------- FUNCTIONS ----------------


function startpicklock(locks)
    local needcrack = 0

    megy = false
    _locks = locks

    while not successminigame do
        if not megy then
            megy = true
            local minigame = exports["asdasd_shiprobbery"]:createSafe({ math.random(0, 99) }, _locks)
            if minigame then
                needcrack = needcrack + 1

                local hatravan = _locks - needcrack
                exports['okokNotify']:Alert("Anyahajó Rablás",
                    'Sikeresen feltörtél egy Zárat, hátra van még: ' .. hatravan, 5000, 'success')

                megy = false
                if needcrack >= _locks then
                    exports['okokNotify']:Alert("Anyahajó Rablás", 'Sikeresen kinyitottad a ládát!', 5000, 'success')
                    needcrack = 0
                    return true
                end
            else
                return false
            end
        end
        Citizen.Wait(500)
    end
end

function IsLooted(lootid)
    if not MissionDatas["looted"] or #MissionDatas["looted"] <= 0 then
        return false
    end

    -- PAYLOAD (2026-09-06): a szerver mar sima lootid-tombot kuld,
    -- nem { lootid = ... } tablakat.
    for i = 1, #MissionDatas["looted"] do
        if MissionDatas["looted"][i] == lootid then
            return true
        end
    end
    return false
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

function OpenBoatRenterMenu()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menuname',
        {
            title    = "Szeretnél egy hajót kibérelni?",
            align    = 'center',
            elements = {
                { label = ('Igen'),   value = true },
                { label = ('Mégsem'), value = false },
            }
        },
        function(data, menu)
            menu.close()

            if data.current.value then
                LoadModel("dinghy2")

                local boat = CreateVehicle(GetHashKey("dinghy2"), Config.SpawnBoatPos, true, true)
                -- bc_kocsitorles: legalis spawn jelolese
                if boat and boat ~= 0 then Entity(boat).state:set('bc_spawned', true, true) end
                exports["gs_eventprotect"]:GS_TriggerServerEvent("asdasd_shiprobbery:spawnedboat",
                    NetworkGetNetworkIdFromEntity(boat))
                SetVehicleFuelLevel(boat, 1000.0)
                SetPedIntoVehicle(PlayerPedId(), boat, -1)
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function Draw3DText(coords, text)
    AddTextEntry(GetCurrentResourceName(), text)
    BeginTextCommandDisplayHelp(GetCurrentResourceName())
    EndTextCommandDisplayHelp(2, false, false, -1)

    SetFloatingHelpTextWorldPosition(1, coords + vector3(0, 0, 0.3))
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
end

function LoadModel(modelname)
    local model = GetHashKey(modelname)

    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

-------- EVENTS -------

RegisterNetEvent('asdasd_shiprobbery_refresh')
AddEventHandler('asdasd_shiprobbery_refresh', function(MissionDatasS)
    MissionDatas = MissionDatasS

    -- If mission ended, remove mothership blip
    if not MissionDatas["started"] and mothershipBlip then
        RemoveBlip(mothershipBlip)
        mothershipBlip = nil
    end
end)
