--[[
    FactionHQ - marker/blip/text drawing helpers (client)

    Floating house icon (runtime texture billboard), 3D/2D text, blips
    and an optional ground ring.
]]

local HQMarker = {}

local blips = {}
local entryProp = nil

-- One-frame marker draw (call from a Wait(0) loop while near).
-- cfg.zOffset defaults to -0.9 (flat ground ring sitting on the floor);
-- a floating marker like the type-20 arrow sets it positive to hover.
-- cfg.bob toggles the native up/down bob (nice for the arrow).
function HQMarker.DrawEntry(pos, cfg)
    DrawMarker(cfg.type, pos.x, pos.y, pos.z + (cfg.zOffset or -0.9), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        cfg.size + 0.0, cfg.size + 0.0, cfg.height + 0.0,
        cfg.color.r, cfg.color.g, cfg.color.b, cfg.color.a,
        cfg.bob == true, false, 2, false, nil, nil, false)
end

--======================================================================
-- Floating house icon: runtime texture from the shipped house.png,
-- drawn as a world-anchored billboard (SetDrawOrigin + DrawSprite) with
-- a slow up-and-down bob. DrawMarker has no house shape, this does.
--======================================================================
local houseTxd = false

local function ensureHouseTexture()
    if houseTxd then return true end
    local ok = pcall(function()
        local txd = CreateRuntimeTxd('bc_factionhq_txd')
        CreateRuntimeTextureFromImage(txd, 'house', 'html/img/house.png')
    end)
    houseTxd = ok
    return ok
end

-- Text line at a screen offset relative to the active draw origin
local function originText(dx, dy, text, scale)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 235)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(dx, dy)
end

-- One frame: bobbing house icon + text lines stacked ABOVE it. Both use
-- the SAME draw origin and screen-space offsets, so the camera angle can
-- never push the text into the icon. lines = compact array (cached by
-- the caller, max 3). dist scales everything together.
function HQMarker.DrawEntryComposite(pos, color, dist, lines)
    if not ensureHouseTexture() then
        -- Texture unavailable -> visible fallback ring
        return HQMarker.DrawEntry(pos, Config.Marker)
    end

    local ic = Config.HouseIcon
    local et = Config.EntryText
    local f = math.min(math.max(8.0 / math.max(dist, 1.0), 0.35), 1.2)
    local iconW = ic.size * f
    local iconH = iconW * GetAspectRatio(false)
    local bob = math.sin(GetGameTimer() / (ic.bobSpeed + 0.0)) * ic.bobAmount

    SetDrawOrigin(pos.x, pos.y, pos.z + ic.height + bob, 0)
    DrawSprite('bc_factionhq_txd', 'house', 0.0, 0.0, iconW, iconH, 0.0,
        color.r, color.g, color.b, color.a)

    if lines then
        local n = #lines
        local ts = et.scale * f
        local lh = et.lineHeight * f
        local y = -(iconH / 2.0) - (et.gap * f) - n * lh
        for i = 1, n do
            originText(0.0, y, lines[i], ts)
            y = y + lh
        end
    end
    ClearDrawOrigin()
end


-- Native DrawText does not render Hungarian o/u accents -> keep texts accent-free
function HQMarker.DrawText3D(coords, text, scale)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    SetTextScale(scale or 0.32, scale or 0.32)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 215)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

function HQMarker.DrawText2D(x, y, text, scale, center)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow()
    SetTextOutline()
    if center then SetTextCentre(true) end
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

--======================================================================
-- Blips: house icon for the own faction HQ + guest-access HQs only
--======================================================================
function HQMarker.RefreshBlips(entries)
    for _, blip in ipairs(blips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    blips = {}

    if not Config.Blip.enabled then return end
    for _, e in ipairs(entries) do
        local blip = AddBlipForCoord(e.coords.x, e.coords.y, e.coords.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipColour(blip, Config.Blip.color)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(e.label)
        EndTextCommandSetBlipName(blip)
        blips[#blips + 1] = blip
    end
end

--======================================================================
-- Optional local entry prop (Config.EntryProp), only for the HQ the
-- player is currently near - spawned/removed with the draw loop.
--======================================================================
function HQMarker.EnsureEntryProp(pos)
    if not Config.EntryProp or entryProp then return end
    local model = joaat(Config.EntryProp)
    if not IsModelValid(model) then return end
    RequestModel(model)
    local deadline = GetGameTimer() + 3000
    while not HasModelLoaded(model) and GetGameTimer() < deadline do Wait(25) end
    if not HasModelLoaded(model) then return end
    entryProp = CreateObject(model, pos.x, pos.y, pos.z - 1.0, false, false, false)
    PlaceObjectOnGroundProperly(entryProp)
    FreezeEntityPosition(entryProp, true)
    SetModelAsNoLongerNeeded(model)
end

function HQMarker.ClearEntryProp()
    if entryProp and DoesEntityExist(entryProp) then
        DeleteEntity(entryProp)
    end
    entryProp = nil
end

return HQMarker
