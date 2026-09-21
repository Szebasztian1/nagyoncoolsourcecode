local cam = 0

-- A NUI-nak éppen kiküldött helyszínek (config + esetleges egyedi spawn),
-- a teleport callback ebből dolgozik
local Locations = {}


local register = false 
RegisterNetEvent('esx_identity:showRegisterIdentity')
AddEventHandler('esx_identity:showRegisterIdentity', function()
register = true
end)

local dead = false 
RegisterNetEvent('bc:setDead')
AddEventHandler('bc:setDead', function()
dead = true
end)

local loaded = false
RegisterNUICallback("loaded", function(data)
loaded = true
end)

-- Beépített GTA hangok (Config.UiSounds) és rövid képernyő-effekt (Config.UiEffect).
-- A NUI csak jelez ("nav" / "select" / "deny"), a hangot mindig a kliens játssza le.
local function PlayUiSound(key)
    local s = Config.UiSounds and Config.UiSounds[key]
    if s then
        PlaySoundFrontend(-1, s[1], s[2], true)
    end
end

local function PlayUiEffect()
    local fx = Config.UiEffect
    if not fx or not fx.name then
        return
    end
    local duration = fx.duration or 300
    AnimpostfxPlay(fx.name, duration, false)
    CreateThread(function()
        Wait(duration + 700)
        AnimpostfxStop(fx.name)
    end)
end

-- A játékos saját felület-beállításai (Testreszabás: méretek, helyek, hangerő) — csak az ő gépén, KVP-ben
local UI_KVP <const> = 'ui_settings'

local function LoadUiSettings()
    local raw = GetResourceKvpString(UI_KVP)
    if not raw or raw == '' then
        return nil
    end
    local ok, t = pcall(json.decode, raw)
    return (ok and type(t) == 'table') and t or nil
end

RegisterNUICallback('saveSettings', function(data, cb)
    cb('ok')
    if type(data) ~= 'table' then
        return
    end
    -- csak rövid kulcsú szám/logikai értékek (a NUI a tartományokat is ellenőrzi betöltéskor)
    local clean, n = {}, 0
    for k, v in pairs(data) do
        local okNum = type(v) == 'number' and v == v and v > -1000 and v < 1000
        if type(k) == 'string' and #k <= 24 and (okNum or type(v) == 'boolean') then
            clean[k] = v
            n = n + 1
            if n >= 40 then break end
        end
    end
    SetResourceKvp(UI_KVP, json.encode(clean))
end)

local NUI_SOUNDS <const> = { nav = true, select = true, deny = true }
RegisterNUICallback("sound", function(data, cb)
    cb("ok")
    local key = type(data) == "table" and data.name or nil
    if key and NUI_SOUNDS[key] then
        PlayUiSound(key)
    end
end)

-- Élő háttér a választó alatt (Config.BackgroundCam): a kamera a város fölött áll, a város
-- oda töltődik be (focus), és csak ennél a játékosnál éjszaka + tiszta idő van. A ped addig
-- fagyasztva marad, mert a focus áthelyezése miatt a saját környéke kiürülhet.
local bgSceneActive = false

-- Nyomva tartott egérrel forgatható háttér (Config.BackgroundCam.drag): a kamera a kép közepén
-- látszó talajpont körül kering, így a kiinduló nézet pontosan a configban megadott marad.
local orbit = nil        -- { px, py, pz, r, h, p, th, tp }
local orbitThread = false

local function RotToDir(pitch, heading)
    local rp, rh = math.rad(pitch), math.rad(heading)
    return -math.sin(rh) * math.cos(rp), math.cos(rh) * math.cos(rp), math.sin(rp)
end

local function OrbitInit(bc)
    local fx, fy, fz = RotToDir(bc.rot.x, bc.rot.z)
    local groundZ = bc.focus and bc.focus.z or 40.0
    local dist = 1000.0
    if fz < -0.05 then
        dist = (groundZ - bc.coords.z) / fz
    end
    orbit = {
        px = bc.coords.x + fx * dist, py = bc.coords.y + fy * dist, pz = bc.coords.z + fz * dist,
        r = dist, tr = dist, h = bc.rot.z, p = bc.rot.x, th = bc.rot.z, tp = bc.rot.x,
    }
end

-- távolság-korlát: ne legyen túl messze, és közel se menjen a házak közé
-- (a kamera legalább minHeight magasan maradjon a dőlésszögtől függően)
local function OrbitClampRadius(bc)
    local down = math.max(0.05, -math.sin(math.rad(orbit.tp)))
    local minR = math.max(bc.minDist or 300.0, ((bc.minHeight or 250.0) - orbit.pz) / down)
    orbit.tr = math.max(minR, math.min(bc.maxDist or 2500.0, orbit.tr))
end

local function OrbitApply(camHandle)
    local fx, fy, fz = RotToDir(orbit.p, orbit.h)
    SetCamCoord(camHandle, orbit.px - fx * orbit.r, orbit.py - fy * orbit.r, orbit.pz - fz * orbit.r)
    SetCamRot(camHandle, orbit.p, 0.0, orbit.h, 2)
end

local function StartBackgroundScene(camHandle)
    local bc = Config.BackgroundCam
    if not bc or not bc.enabled then
        SetCamCoord(camHandle, 0.0, 0.0, 500.0)
        return false
    end
    SetCamCoord(camHandle, bc.coords.x, bc.coords.y, bc.coords.z)
    SetCamRot(camHandle, bc.rot.x, bc.rot.y, bc.rot.z, 2)
    SetCamFov(camHandle, bc.fov or 50.0)
    local f = bc.focus or bc.coords
    SetFocusPosAndVel(f.x, f.y, f.z, 0.0, 0.0, 0.0)
    if bc.hour then
        NetworkOverrideClockTime(bc.hour, bc.minute or 0, 0)
    end
    if bc.weather then
        SetOverrideWeather(bc.weather)
    end
    FreezeEntityPosition(PlayerPedId(), true)
    orbit = nil
    if bc.drag ~= false then
        OrbitInit(bc)
    end
    bgSceneActive = true
    return true
end

local function StopBackgroundScene()
    if not bgSceneActive then
        return
    end
    bgSceneActive = false
    orbit = nil
    ClearFocus()
    local bc = Config.BackgroundCam
    if bc.hour then
        NetworkClearClockTimeOverride()
    end
    if bc.weather then
        ClearOverrideWeather()
    end
end

-- a focus visszaállítása után megvárjuk a ped körüli kollíziót, és csak utána engedjük el
local function WaitCollisionAndRelease(ped)
    local pc = GetEntityCoords(ped)
    RequestCollisionAtCoord(pc.x, pc.y, pc.z)
    local start_time = GetGameTimer()
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() - start_time < 5000 do
        Wait(5)
    end
    FreezeEntityPosition(ped, false)
end

-- a húzás a célszöget állítja, ez a szál képkockánként puhán odaviszi a kamerát;
-- csak a választó alatt fut, nyugalomban ritkán ébred
local function EnsureOrbitThread()
    if orbitThread then
        return
    end
    orbitThread = true
    CreateThread(function()
        while bgSceneActive and orbit and cam ~= 0 do
            local dh, dp, dr = orbit.th - orbit.h, orbit.tp - orbit.p, orbit.tr - orbit.r
            if math.abs(dh) > 0.01 or math.abs(dp) > 0.01 or math.abs(dr) > 0.5 then
                local a = 1.0 - math.exp(-12.0 * GetFrameTime())
                orbit.h = orbit.h + dh * a
                orbit.p = orbit.p + dp * a
                orbit.r = orbit.r + dr * a
                OrbitApply(cam)
                Wait(0)
            else
                Wait(50)
            end
        end
        orbitThread = false
    end)
end

RegisterNUICallback("camdrag", function(data, cb)
    cb("ok")
    if not bgSceneActive or not orbit or cam == 0 or type(data) ~= "table" then
        return
    end
    local bc = Config.BackgroundCam
    local speed = bc.dragSpeed or 0.12
    local dx, dy, dz = tonumber(data.dx) or 0.0, tonumber(data.dy) or 0.0, tonumber(data.dz) or 0.0
    -- jobbra húzás: a város jobbra fordul; lefelé húzás: meredekebb, felülnézetibb kép
    orbit.th = orbit.th - dx * speed
    orbit.tp = math.max(bc.minPitch or -80.0, math.min(bc.maxPitch or -12.0, orbit.tp - dy * speed * 0.6))
    -- görgő: előre (fel) közelebb, hátra (le) messzebb — arányos lépés, így közel és távol is egyforma érzés
    if dz ~= 0.0 then
        orbit.tr = orbit.tr * math.exp(dz * (bc.zoomSpeed or 0.0012))
    end
    OrbitClampRadius(bc)
    EnsureOrbitThread()
end)

-- Segéd a kamera beállításához (Config.BackgroundCam.debug = true):
--   /spawnkamera  -> a mostani nézet (pl. noclip/freecam) adatait config-sorként az F8 konzolba írja
--   /spawnhatter  -> 15 mp-ig megmutatja a háttér-kamerát a jelenlegi config szerint
if Config.BackgroundCam and Config.BackgroundCam.debug then
    RegisterCommand('spawnkamera', function()
        local p = GetFinalRenderedCamCoord()
        local r = GetFinalRenderedCamRot(2)
        print(('coords = vector3(%.1f, %.1f, %.1f), rot = vector3(%.1f, %.1f, %.1f), fov = %.1f,'):format(
            p.x, p.y, p.z, r.x, r.y, r.z, GetFinalRenderedCamFov()))
    end, false)

    RegisterCommand('spawnhatter', function()
        if bgSceneActive or cam ~= 0 or not Config.BackgroundCam.enabled then
            return
        end
        local previewCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        StartBackgroundScene(previewCam)
        SetCamActive(previewCam, true)
        RenderScriptCams(true, false, 0, true, false)
        Wait(15000)
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(previewCam, true)
        StopBackgroundScene()
        WaitCollisionAndRelease(PlayerPedId())
    end, false)
end

-- Ezekben a zonakban az "Utolso pozicio" nem valaszthato: a NUI zart csikot
-- mutat a `reason` szoveggel (ha nincs reason, altalanos szoveg megy).
-- A minZ opcionalis: csak akkor szamit a zona, ha a jatekos legalabb ilyen
-- magasan all -- igy a lebego belso terek alatti utcaszint nem esik bele.
local fixselectzones = {
    {c = vector3(229.9559, -981.7928, -99.6607), r = 30.0},
    {c = vector3(-186.4757, -581.4171, 141.34785), r = 25.0},
    {c = vector3(-1505.783, -3012.587, -80.00), r = 40.0},
    {c = vector3(-1266.802, -3014.837, -49.000), r = 60.0},
    -- a gyar-muhely belseje (vilmos_gyar / bc_garageworkshop shell): MINDEN
    -- gyar ugyanezen a koordinatan van, csak a routing bucket mas. Aki bent
    -- lepett ki, visszalepeskor itt all -- az "utolso pozicio" beragadna.
    {c = vector3(-287.725769, -3830.756, 29.6118126), r = 45.0, minZ = 24.0,
     reason = 'A gyár belsejében léptél ki — válassz másik helyet.'},
}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    --print("esx:playerLoaded", xPlayer, isNew, skin)
    if isNew then
        return
    end

    -- a megvásárolt spawn lekérése már itt elindul, hogy a UI nyitásakor kész legyen
    CustomSpawn.Prefetch()

    Wait(5000)

    if register then 
        return 
    end

    if dead then 
        return 
    end


    while not loaded do
        Wait(100)
    end 
    Wait(100)
    if exports["bc_communityservice"]:isPlayerOnCommunityservice() then 
        return 
    end 

    local ingar = false
    local lockreason = nil
    local c = GetEntityCoords(PlayerPedId())
    for k, v in pairs(fixselectzones) do
        if #(c - v.c) < v.r and (not v.minZ or c.z >= v.minZ) then
            ingar = true
            lockreason = v.reason
            break
        end
    end

    Wait(5000)
    --print("ingar", ingar)

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    -- élő háttér: a város fölött (vagy a régi 0,0,500-as nézet, ha ki van kapcsolva)
    local bgMode = StartBackgroundScene(cam) and "camera" or "image"
    -- más scriptek (pl. afk_system) ebből tudják, hogy a játékos épp spawn helyet választ
    LocalPlayer.state:set('spawnSelecting', true, false)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    --local SpawnPlayer = GlobalState.SpawnPlayer[GetPlayerServerId(PlayerId())]
    --if not SpawnPlayer then
        SetTimecycleModifier('fp_vig_black')
        SetNuiFocus(true, true)
        TriggerServerEvent("FiveStar-SpawnSelector:server:SaveSpawnPlayer")
        Locations = CustomSpawn.BuildLocations()
        if ingar then
            -- zart "utolso pozicio" csik: latszik, de nem valaszthato, es
            -- kiirja az okot -- a jatekos igy erti, miert kell mast valasztania
            SendNUIMessage({ action = "openUI", bg = bgMode, settings = LoadUiSettings(), data = Locations, last = {
                Name        = Config.LastLocation.Name,
                Description = lockreason or 'Erről a helyről nem elérhető.',
                MiniTxt     = Config.LastLocation.MiniTxt,
                Locked      = true,
            }})
        else
            SendNUIMessage({ action = "openUI", bg = bgMode, settings = LoadUiSettings(), data = Locations, last = Config.LastLocation })
        end
        PlayUiSound("open")
        PlayUiEffect()
        --print("hide spawn")
        DisplayRadar(false)
        TriggerEvent('hideHud', true)
        TriggerEvent('hChat', true)
        TriggerEvent('hideChat', false)
        TriggerServerEvent("bc_spawn:started")
        SetLocalPlayerAsGhost(true)
    --end
end)

--RegisterCommand('testspawn', function()
--    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
--    SetCamCoord(cam, vector3(0.0, 0.0, 500.0))
--    SetCamActive(cam, true)
--    RenderScriptCams(true, false, 0, true, false)
--    SetTimecycleModifier('fp_vig_black')
--        SetNuiFocus(true, true)
--        TriggerServerEvent("FiveStar-SpawnSelector:server:SaveSpawnPlayer")
--        SendNUIMessage({ action = "openUI", data = Config.Location, last = Config.LastLocation })
--        
--        print("hide spawn")
--        DisplayRadar(false)
--        TriggerEvent('hideHud', true)
--        TriggerEvent('hChat', true)
--        TriggerEvent('hideChat', false)
--        TriggerServerEvent("bc_spawn:started")
--        SetLocalPlayerAsGhost(true)
--end)

local function StartDarkScreen()
    DoScreenFadeOut(500)
    while IsScreenFadingOut() do
        Citizen.Wait(1)
    end
end

local function EndDarkScreen()
    ShutdownLoadingScreen()
    DoScreenFadeIn(500)
    while IsScreenFadingIn() do
        Citizen.Wait(1)
    end
end

RegisterNUICallback("teleport", function(data)

    PlayUiSound("travel")
    StartDarkScreen()
    --print("destroy cam", cam)
    RenderScriptCams(false)
    DestroyCam(cam, true)
    SetCamActive(cam, false)
    cam = 0
    -- elsötétült: a háttér-kamera focusa, a helyi idő és időjárás visszaáll
    StopBackgroundScene()
    SendNUIMessage({ action = "openwelcome"})
    Wait(1000)

    -- Coords nélküli (zárolt) kártya nem teleportál, a játékos a helyén marad
    local selected = data and Locations[tonumber(data.index)]
    if selected and selected.Coords then
        local Location = selected.Coords
        local PlayerPed = PlayerPedId()
        SetEntityCoords(PlayerPed, Location.x, Location.y, Location.z)
        FreezeEntityPosition(PlayerPed, true)
        local start_time = GetGameTimer()
        while (not HasCollisionLoadedAroundEntity(PlayerPed) and GetGameTimer() - start_time < 5000) do
            Citizen.Wait(5)
        end
        SetEntityHeading(PlayerPed, Location.w)
        FreezeEntityPosition(PlayerPed, false)
    else
        -- utolsó helyszín: a háttér-kamera alatt a ped környéke kiürülhetett -> visszavárjuk
        WaitCollisionAndRelease(PlayerPedId())
    end

    Citizen.Wait(300)
    PlayUiSound("switch")
    StartPlayerSwitch(PlayerPedId(), PlayerPedId(), 255, 1)
    EndDarkScreen()
    Wait(6000)
    SendNUIMessage({ action = "closewelcome"})
    StopPlayerSwitch()
    LocalPlayer.state:set('spawnSelecting', false, false)
    PlayUiSound("arrive")
    PlayUiEffect()
    

    SetTimecycleModifier('default')
    SetNuiFocus(false, false)

    --print("show spawn")
     DisplayRadar(true)
    TriggerEvent('hideHud', false)
    TriggerEvent('hChat', false)
    TriggerEvent('hideChat', true)
    
    CreateThread(function()
      Wait(5000)
      SetLocalPlayerAsGhost(false)
      TriggerServerEvent("bc_spawn:finished")
    end)
end)
