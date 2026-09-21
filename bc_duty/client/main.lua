---@type boolean
local AdminPanelOpen = false

---A "license:" előtag nélküli, kisbetűs licenc-hash (az ESX identifier ezen a szerveren
---maga a license hash, így a kettő összehasonlítható).
---@param license string|nil
---@return string|nil
local function normalizeLicense(license)
    if not license then return nil end
    local s = tostring(license):lower()
    s = s:gsub('%s+', '')
    s = s:gsub('^license2?:', '')
    s = s:gsub('^char%d+:', '')
    s = s:gsub('[^%w]', '')
    if s == '' then return nil end
    return s
end

---Van-e a zónán license-korlátozás.
---@param zone table
---@return boolean
local function isZoneLocked(zone)
    return type(zone.Licenses) == 'table' and #zone.Licenses > 0
end

---Használhatja-e a helyi játékos a zónát. A szerver újra ellenőrzi, ez csak azért van,
---hogy ne induljon el feleslegesen a kártyás minijáték.
---@param zone table
---@return boolean
local function canUseZone(zone)
    if not isZoneLocked(zone) then return true end

    local ident = normalizeLicense(ESX.PlayerData and ESX.PlayerData.identifier)
    if not ident then return false end

    for _, lic in ipairs(zone.Licenses) do
        if normalizeLicense(lic) == ident then return true end
    end

    return false
end

RegisterNetEvent('duty:syncZonesClient')
AddEventHandler('duty:syncZonesClient', function(zones)
    if zones and type(zones) == 'table' then
        Config.Zones = zones
    end
end)

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do
        Wait(10)
    end
    while true do
        Wait(0)

        local coords = GetEntityCoords(PlayerPedId())
        local sleep  = true

        for k, v in pairs(Config.Zones) do
            local dis = #(coords - vector3(v.Pos.x, v.Pos.y, v.Pos.z))
            if dis < Config.DrawDistance then
                local jobName = ESX.PlayerData.job.name
                local grade   = ESX.PlayerData.job.grade

                if v.FirstJob == jobName or v.SecondJob == jobName then
                    if not v.Mingrade or v.Mingrade <= grade then
                        sleep = false

                        DrawMarker(
                            v.Type,
                            v.Pos.x, v.Pos.y, v.Pos.z - 0.98,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            v.Size.x + 0.0, v.Size.y + 0.0, v.Size.z + 0.0,
                            v.Color.r, v.Color.g, v.Color.b, 100,
                            true, true, 2,
                            false, false, false, false
                        )
                        if dis < v.Size.x then
                            if canUseZone(v) then
                                ESX.ShowHelpNotification(_U('duty'), true)
                                if IsControlJustReleased(0, 38) then
                                    local count = exports.ox_inventory:Search('count', 'changeaccesscard')
                                    if count > 0 then
                                        exports['rota_cardminigame']:openCardMinigame(jobName, function(success)
                                            if success then
                                                TriggerServerEvent('esx_advanced_duty:changeDutyStatus', k)
                                            end
                                        end)
                                    else
                                        lib.notify({
                                            title = 'Duty',
                                            description = 'Nincs elég kártya nálad',
                                            type = 'error'
                                        })
                                    end
                                    Wait(10000)
                                end
                            else
                                ESX.ShowHelpNotification(_U('duty_locked'), true)
                                if IsControlJustReleased(0, 38) then
                                    TriggerEvent('bc:notify', 'Duty',
                                        'Ez a duty pont license-hez kötött, neked nincs rá jogod.', 5000, 'error')
                                    Wait(3000)
                                end
                            end
                        end
                    end
                end
            end
        end

        if sleep then
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.identifier do
        Wait(10)
    end
    if not Config.IdentifierDuties[ESX.PlayerData.identifier] then
        return
    end

    local v = Config.IdentifierDuties[ESX.PlayerData.identifier]

    while true do
        Wait(0)

        local coords = GetEntityCoords(PlayerPedId())
        local sleep  = true

        local dis    = #(coords - vector3(v.Pos.x, v.Pos.y, v.Pos.z))
        if dis < Config.DrawDistance then
            sleep = false

            DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x + 0.0,
                v.Size.y + 0.0,
                v.Size.z + 0.0,
                v.Color.r, v.Color.g, v.Color.b, 100, true, true, 2, false, false, false, false)
            if dis < v.Size.x then
                ESX.ShowHelpNotification(_U('duty'), true)
                if IsControlJustReleased(0, 38) then
                    local count = exports.ox_inventory:Search('count', 'changeaccesscard')
                    if count > 0 then
                        local ownJob = ESX.PlayerData.job and ESX.PlayerData.job.name or ''
                        exports['rota_cardminigame']:openCardMinigame(ownJob, function(success)
                            if success then
                                TriggerServerEvent('esx_advanced_duty:changeDutyStatusOwn')
                            end
                        end)
                    else
                        lib.notify({
                            title = 'Duty',
                            description = 'Nincs kártya nálad.',
                            type = 'error'
                        })
                    end
                    Wait(10000)
                end
            end
        end

        if sleep then
            Wait(1000)
        end
    end
end)

RegisterNetEvent('bc_duty:openAdminPanel')
AddEventHandler('bc_duty:openAdminPanel', function(zones, jobs)
    AdminPanelOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open:admin', data = { zones = zones, jobs = jobs } })
end)

Rpc:Register('exit', function()
    AdminPanelOpen = false
    SetNuiFocus(false, false)
end)

Rpc:Register('admin:teleport', function(data)
    local ped = PlayerPedId()
    SetEntityCoords(ped, data.x, data.y, data.z, false, false, false, false)
    SetEntityHeading(ped, 0.0)
end)

Rpc:Register('admin:getPlayerCoords', function(_)
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped, true)
    return { x = coords.x, y = coords.y, z = coords.z }
end)

RegisterNUICallback('admin:createZone', function(data, cb)
    CreateThread(function()
        local ok, result = pcall(function()
            return Rpc:CallServer('admin:createZone', data)
        end)
        cb({ success = ok, data = ok and result or tostring(result) })
    end)
end)

RegisterNUICallback('admin:updateZone', function(data, cb)
    CreateThread(function()
        local ok, result = pcall(function()
            return Rpc:CallServer('admin:updateZone', data)
        end)
        cb({ success = ok, data = ok and result or tostring(result) })
    end)
end)

RegisterNUICallback('admin:deleteZone', function(data, cb)
    CreateThread(function()
        local ok, result = pcall(function()
            return Rpc:CallServer('admin:deleteZone', data)
        end)
        cb({ success = ok, data = ok and result or tostring(result) })
    end)
end)
