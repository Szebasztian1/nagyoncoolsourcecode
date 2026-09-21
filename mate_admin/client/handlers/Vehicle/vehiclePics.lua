local STUDIO_CAM_COORDS = vector3(-45.54, -1100.37, 27.42)
local STUDIO_SPAWN_COORDS = vector4(-46.1, -1096.43, 25.71, 230.0)

local activeVehicle = nil
local activeCam = nil
local capturing = false

-- Runs only while a capture session is open. This used to be an unconditional
-- `while true ... Wait(0)` thread, which burned a per-frame tick on EVERY player
-- forever just to read a flag that is false outside the photo studio.
local function startFrontendBlocker()
    CreateThread(function()
        while capturing do
            DisableFrontendThisFrame()
            Wait(0)
        end
    end)
end

local function CleanupStudio()
    capturing = false

    if DoesEntityExist(activeVehicle) then
        DeleteEntity(activeVehicle)
    end
    activeVehicle = nil

    ClearFocus()
    DisplayHud(true)
    DisplayRadar(true)
    RenderScriptCams(false)

    if activeCam then
        DestroyCam(activeCam, true)
        SetCamActive(activeCam, false)
        activeCam = nil
    end
end

lib.callback.register('mate_admin:vehiclePic:getAllModels', function()
    local ok, names = pcall(GetAllVehicleModels)

    if not ok then
        return {}
    end

    return names
end)

---@param model string
---@param uploadUrl string
lib.callback.register('mate_admin:vehiclePic:capture', function(model, uploadUrl)
    if not IsModelInCdimage(model) or not IsModelValid(model) then
        return { ok = false, message = 'Ervenytelen modell.' }
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(model) then
        return { ok = false, message = 'A modell nem toltodott be.' }
    end

    capturing = true
    startFrontendBlocker()
    DisplayHud(false)
    DisplayRadar(false)

    activeCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(activeCam, STUDIO_CAM_COORDS)
    SetCamActive(activeCam, true)
    RenderScriptCams(true, false, 0, true, false)

    activeVehicle = CreateVehicle(
        model,
        STUDIO_SPAWN_COORDS.x, STUDIO_SPAWN_COORDS.y, STUDIO_SPAWN_COORDS.z, STUDIO_SPAWN_COORDS.w,
        false, true
    )
    -- bc_kocsitorles: legalis spawn jelolese
    if activeVehicle and activeVehicle ~= 0 then Entity(activeVehicle).state:set('bc_spawned', true, true) end
    if activeVehicle and activeVehicle ~= 0 then TriggerEvent("bc:localVehSpawn", activeVehicle) end
    SetModelAsNoLongerNeeded(model)

    if not DoesEntityExist(activeVehicle) then
        CleanupStudio()
        return { ok = false, message = 'A jarmu nem jott letre.' }
    end

    FreezeEntityPosition(activeVehicle, true)
    SetVehicleDirtLevel(activeVehicle, 0.0)
    SetVehicleOnGroundProperly(activeVehicle)
    PointCamAtEntity(activeCam, activeVehicle, 0.0, 0.0, 0.0, true)
    SetFocusEntity(activeVehicle)

    Wait(1500)

    local p = promise.new()
    local settled = false

    exports['screenshot-basic']:requestScreenshotUpload(uploadUrl, 'file', {
        encoding = 'webp',
    }, function(imgdata)
        if settled then return end
        settled = true
        p:resolve(imgdata)
    end)

    CreateThread(function()
        Wait(15000)
        if settled then return end
        settled = true
        p:resolve(false)
    end)

    local imgdata = Citizen.Await(p)

    CleanupStudio()

    if not imgdata then
        return { ok = false, message = 'Nem sikerult feltolteni a kepet.' }
    end

    local ok, resp = pcall(json.decode, imgdata)
    if not ok or type(resp) ~= 'table' then
        return { ok = false, message = 'Ervenytelen valasz a fivemanage-tol.' }
    end

    local url = resp.data and resp.data.url
    if not url then
        return { ok = false, message = 'A fivemanage valasz nem tartalmazott URL-t.' }
    end

    return { ok = true, url = url }
end)
