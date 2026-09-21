Framework = Config.Framework == "esx" and exports['es_extended']:getSharedObject() or exports["qb-core"]:GetCoreObject()
local firstLoad = false

function triggerServerCallback(...)
    if Config.Framework == "esx" then
        Framework.TriggerServerCallback(...)
    else
        Framework.Functions.TriggerCallback(...)
    end
end

--[[ Minimap shape ------------------------------------------------------------------------------

Two silhouettes ship with the HUD: the original squared frame (stream/mapshape.ytd) and the round
one ported from joemap (stream/circlemap.ytd). Both dictionaries expose a texture called
"radarmasksm"; whichever one is bound over the game's radar mask decides the outline, and the clip
type has to agree with it (0 = rectangular, 1 = circular) or the corners bleed past the mask.

The component offsets belong to the shape as well - the circle wants a taller, narrower frame and
its mask sits somewhere else entirely - so each shape carries its own set. Every x is nudged by
the widescreen offset computed in getMinimapOffset().

The ring
--------
The round map has no frame of its own: what draws its outline is a plain CSS circle in the NUI,
and that one has to sit exactly on top of the radar. The catch is that the two are placed in two
different coordinate systems - the radar inside the game's 16:9 HUD box (see getHudBox), the ring
in the real viewport - and the stylesheet had the 16:9 numbers hard-coded. On a 16:9 screen the
two systems are the same thing and everything lines up; on anything else the radar sits somewhere
the stylesheet cannot express, which is the "map slid out of its frame" people see there.

So the ring is no longer positioned by the stylesheet. `ring` below is its box at 16:9, in the
same units the CSS used (vh, measured from the bottom-left corner), and ApplyMapLayout() puts it
through the same conversion the radar goes through before handing it to the NUI. At 16:9 that
gives back the exact numbers the stylesheet used to hard-code, so nothing moves on the screens
where it already looked right.
]]

-- Correction applied on top of the geometry below, for every player. `disc` moves and resizes the
-- radar itself, `ring` the outline the UI draws around it; x is a fraction of the screen width,
-- y and size fractions of its height. Both are meant to stay at zero - they are here because a
-- resolution can still disagree by a few pixels, and /terkepbeallitas prints the numbers that fix
-- it (see the alignment helper at the end of this block).
local MAP_ALIGN = {
    disc = { x = 0.0000, y = 0.0000, size = 0.0000 },
    ring = { x = 0.0000, y = 0.0000, size = 0.0000 },
    -- The ellipse radius blips are clipped to (see applyBlipMask). Not in screen fractions like the
    -- two above but in the gfx mask's own units: x/y move its centre, w/h add to its two radii.
    clip = { x = 0.0, y = 0.0, w = 0.0, h = 0.0 },
}

local MapShapes = {
    square = {
        txd = "mapshape",
        clipType = 0,
        -- radarmask1g is the expanded (bigmap) mask; the square shape overrides that one too so
        -- the zoomed-out map keeps the same frame.
        masks = { "radarmasksm", "radarmask1g" },
        components = {
            minimap      = { x =  0.000, y = -0.007, w = 0.1638, h = 0.183 },
            minimap_mask = { x =  0.000, y =  0.000, w = 0.128,  h = 0.200 },
            minimap_blur = { x = -0.010, y =  0.060, w = 0.262,  h = 0.300 },
        },
        -- The squared frame is laid out by the stylesheet itself, there is no ring to place.
    },

    bordered = {
        txd = "bordermap",
        clipType = 0,
        -- radarmask1g is the expanded (bigmap) mask; the square shape overrides that one too so
        -- the zoomed-out map keeps the same frame.
        masks = { "radarmasksm", "radarmask1g" },
        components = {
            minimap      = { x =  0.000, y = -0.007, w = 0.1638, h = 0.183 },
            minimap_mask = { x =  0.000, y =  0.000, w = 0.128,  h = 0.200 },
            minimap_blur = { x = -0.010, y =  0.060, w = 0.262,  h = 0.300 },
        },
        -- The squared frame is laid out by the stylesheet itself, there is no ring to place.
    },

    circle = {
        txd = "circlemap",
        clipType = 1,
        -- Only the small mask is swapped here: the circular clip type already rounds the frame,
        -- and pushing the round mask onto radarmask1g as well would clip the expanded map to a
        -- circle too, which cuts off most of it.
        masks = { "radarmasksm" },
        components = {
            minimap      = { x = -0.022, y = -0.026, w = 0.160, h = 0.245 },
            minimap_mask = { x =  0.185, y =  0.075, w = 0.071, h = 0.164 },
            minimap_blur = { x = -0.032, y = -0.040, w = 0.180, h = 0.220 },
        },
        -- The ring at 16:9, in vh from the bottom-left corner of the screen - the box the
        -- stylesheet used to hard-code. Its width is in vh as well (not vw) because the radar
        -- keeps its aspect off the screen height, so a vw width would drift on ultrawide.
        ring = { left = 0.49, bottom = 5.25, width = 25.15, height = 22.40 },
        -- The ellipse radius and area blips are cut to, in the units of the gfx mask (centre and
        -- the two radii; the stock rectangle spans x 6..185, y 8..123.1 there). A shape without
        -- this keeps the rectangle. Starting values read off a screenshot - /terkepbeallitas
        -- (BLIPMASZK) prints the measured ones.
        blipMask = { cx = 93.2, cy = 79.2, rx = 110.1, ry = 93.2 },
    },
}

local DEFAULT_MAP_SHAPE = "square"

local currentMapShape = DEFAULT_MAP_SHAPE
-- Which mask names the last loadMap() bound, so they can be released before the next shape goes
-- in. nil until the map has come up once, which also doubles as "nothing to re-apply yet".
local appliedMasks = nil

--[[ The screen the radar lives on -----------------------------------------------------------

The game lays the HUD out in a 16:9 box centred on the screen. On a window wider than that the
box is inset on both sides and every minimap coordinate is measured against the box, not against
the screen; on a narrower one it stays against the left edge and runs past the right one (see
getHudBox). A `position: fixed` ring in the NUI sits in the real viewport and knows nothing about
any of it, which is the whole reason the two drifted apart.

"The screen" here is the one the game thinks it has, which is not always the window. The graphics
settings take an aspect ratio of their own, and "stretched 4:3" on a 16:9 monitor is a popular
pick: the game lays everything out for 4:3 and the monitor pulls the picture a third wider, radar
included. Reported 2026-09-12 by a player whose ring was fine at every resolution and slid off
the map only with that setting. getScreenAspect has the two numbers apart.

Measured in game on a 2446x1347 window (aspect 1.8159): the radar sat 26.9 px from the left edge
of the screen while the ring sat at 6.6, and half the letterbox is (2446 - 16/9 * 1347) / 2 =
25.7 px. Within a pixel of the difference, so the box is what moves it - not the safe zone slider
(0.97 there), which the same formula would have put 10 px further out.

The widescreen offset the HUD has always applied is that compensation: -(AR / (16/9) - 1) / 2 is
the exact number and ((16/9 - AR) / 3.6) - 0.008 is what is in here, so it overshoots by a fixed
0.008 of the box - 19 px on that window, which is precisely how much of the disc hung off the left
edge of the screen.
]]
local DEFAULT_ASPECT_RATIO = 1920 / 1080

-- The aspect ratio the game lays the HUD out for, and the one the window really has (which is
-- what the NUI paints in). The same number unless the aspect ratio setting disagrees with the
-- window. A triple-monitor span is the exception that is not a stretch: the setting reports the
-- middle screen there, the HUD sits undistorted in the middle of the window, and the window's own
-- ratio already describes that - so it keeps going by the window, as before.
local function getScreenAspect()
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local physical = resolutionX / resolutionY
    local layout = GetAspectRatio(false)

    if not layout or layout <= 0.0 or math.abs(layout - physical) < 0.01
        or math.abs(physical / layout - 3.0) < 0.1 then
        layout = physical
    end

    return resolutionX, resolutionY, layout, physical
end

-- Where the game's 16:9 HUD box sits inside the screen: the inset in front of it and its size,
-- both as fractions of the screen.
--
-- Narrower than 16:9 the box is not letterboxed: HUD sizes keep going by the screen height and
-- every x is scaled up by the same factor, so it stays against the left edge, full height, and
-- runs past the right one. For a window that really is that narrow this changes nothing - the
-- ring's width is in vh and its left edge comes out where it always did - it only matters once
-- the aspect ratio setting stretches the picture. That is read off the stretched 4:3 screenshot
-- (the radar kept its height and only grew wider than the ring), not measured to the pixel - the
-- /terkepbeallitas readout prints both ratios for whoever does.
local function getHudBox(aspectRatio)
    if aspectRatio > DEFAULT_ASPECT_RATIO then
        local width = DEFAULT_ASPECT_RATIO / aspectRatio
        return (1.0 - width) / 2, width, 0.0, 1.0
    end

    return 0.0, DEFAULT_ASPECT_RATIO / aspectRatio, 0.0, 1.0
end

-- Pulls the radar back out of the letterbox towards the edge of the screen. Clamped at the point
-- where the map has the same margin it has on 16:9: past that the 0.008 tail takes a slice of the
-- disc off the screen, and a ring cannot be aligned to something that is not there.
local function getMinimapOffset()
    local _, _, aspectRatio = getScreenAspect()

    if aspectRatio <= DEFAULT_ASPECT_RATIO then
        return 0.0, aspectRatio, 0.0
    end

    local insetX, hudWidth = getHudBox(aspectRatio)
    local raw = ((DEFAULT_ASPECT_RATIO - aspectRatio) / 3.6) - 0.008

    return math.max(raw, -insetX / hudWidth), aspectRatio, raw
end

-- Places every minimap component and hands the UI the matching ring box. Cheap enough to run on a
-- keypress: only the mask *texture* swap in loadMap() needs the bigmap refresh around it.
function ApplyMapLayout()
    local shape = MapShapes[currentMapShape] or MapShapes[DEFAULT_MAP_SHAPE]
    local minimapOffset, aspectRatio = getMinimapOffset()

    -- disc.size grows or shrinks the visible disc, and it does that on the mask alone: the mask is
    -- only the crop, so the map keeps its zoom and the player stays in the middle of it.
    local maskScale = 1.0
    if shape.ring and MAP_ALIGN.disc.size ~= 0.0 then
        maskScale = (shape.ring.height + MAP_ALIGN.disc.size * 100) / shape.ring.height
    end

    for component, pos in pairs(shape.components) do
        local scale = component == "minimap_mask" and maskScale or 1.0

        SetMinimapComponentPosition(component, "L", "B",
            pos.x + minimapOffset + MAP_ALIGN.disc.x, pos.y + MAP_ALIGN.disc.y,
            pos.w * scale, pos.h * scale)
    end

    if not shape.ring then
        SendNUIMessage({ action = "mapGeometry", shape = currentMapShape })
        return
    end

    local ring = shape.ring
    local _, _, _, physicalAspect = getScreenAspect()
    local insetX, hudWidth, insetY, hudHeight = getHudBox(aspectRatio)
    -- How much wider the monitor draws the picture than the game laid it out: 1 unless the aspect
    -- ratio setting disagrees with the window (4/3 for stretched 4:3 on 16:9). Heights and anything
    -- given as a screen fraction are untouched by it, widths in vh are not.
    local stretch = physicalAspect / aspectRatio
    -- Every correction is a screen fraction, the ring's own box is in vh - hence the * 100.
    local size = ring.width + MAP_ALIGN.ring.size * 100

    -- The ring's own box is where the radar sits inside the HUD box; the conversion out to the
    -- real viewport is the inset plus the box's own size, exactly what the radar goes through.
    -- On 16:9 the inset is zero and the box is the screen, so this is the identity. The left edge
    -- goes into box units at 16:9 (that is what the vh number was taken at), so with the offset
    -- clamped it keeps the same margin as on 16:9 - the same thing the clamp does for the radar.
    local left   = insetX + ((ring.left / 100 / DEFAULT_ASPECT_RATIO) + minimapOffset + MAP_ALIGN.disc.x) * hudWidth
    local bottom = insetY + ((ring.bottom / 100) + MAP_ALIGN.disc.y) * hudHeight

    SendNUIMessage({
        action = "mapGeometry",
        shape  = currentMapShape,
        -- One vw number for the left keeps the NUI free of any geometry of its own; the rest is
        -- vh, so the disc stays a disc whatever the screen is - or turns into the same oval the
        -- stretched radar does.
        left   = (left + MAP_ALIGN.ring.x) * 100,
        bottom = (bottom + MAP_ALIGN.ring.y) * 100,
        width  = size * stretch * hudHeight,
        height = size * (ring.height / ring.width) * hudHeight,
    })
end

--[[ Radius blips on the round map --------------------------------------------------------------

Swapping radarmasksm only rounds what the game cuts with that texture, which is the map itself.
Radius and area blips (AddBlipForRadius / AddBlipForArea) are movie clips in the minimap
scaleform, and the layer they sit in is clipped by a vector shape from stream/minimap.gfx:
"mapMaskSquare", a plain rectangle (x 6..185, y 8..123.1 in its own units). SetMinimapClipType
does not reach it either - the FiveM source shows it only flips the bool the game uses to pin blip
icons to the edge. So on the round map a zone covering the radar shows up as a box inside the disc.

The gfx shipped with the HUD is patched for this, with the stock rectangle left as it was:
  * mapMaskSquare has a second, empty frame and a frame script handing the clip to _global;
  * MINIMAP.SET_BLIP_MASK_SHAPE(round, cx, cy, rx, ry) keeps the rectangle (round = false) or
    replaces it with an ellipse drawn in the mask's own units;
  * MINIMAP.GET_BLIP_MASK_INFO() reports what it found, for /terkepbeallitas.

Where the game puts that mask relative to the disc is not something the script can read, so the
ellipse is a number carried by the shape (blipMask) and measured in game.

The state lives inside the movie. The game rebuilds the mask clip when the radar changes mode
(bigmap, pause map) and the frame script re-applies it there, but a reloaded movie starts over
with the rectangle - hence the resend while the round map is up. A client still running the old
gfx (it only loads on connect, a resource restart is not enough) ignores the call.
]]
local minimapMovie = nil
local BLIP_MASK_RESEND_MS = 2000

local function applyBlipMask()
    if not minimapMovie then return end

    local shape = MapShapes[currentMapShape] or MapShapes[DEFAULT_MAP_SHAPE]
    local mask = shape.blipMask

    BeginScaleformMovieMethod(minimapMovie, "SET_BLIP_MASK_SHAPE")
    ScaleformMovieMethodAddParamBool(mask ~= nil)
    ScaleformMovieMethodAddParamFloat(mask and mask.cx + MAP_ALIGN.clip.x or 0.0)
    ScaleformMovieMethodAddParamFloat(mask and mask.cy + MAP_ALIGN.clip.y or 0.0)
    ScaleformMovieMethodAddParamFloat(mask and mask.rx + MAP_ALIGN.clip.w or 0.0)
    ScaleformMovieMethodAddParamFloat(mask and mask.ry + MAP_ALIGN.clip.h or 0.0)
    EndScaleformMovieMethod()
end

-- What the patched gfx says about its mask clip. Yields until the movie answers.
local function getBlipMaskInfo()
    if not minimapMovie then return "a minimap scaleform nincs betoltve" end

    BeginScaleformMovieMethod(minimapMovie, "GET_BLIP_MASK_INFO")
    local handle = EndScaleformMovieMethodReturnValue()
    local deadline = GetGameTimer() + 1000

    while not IsScaleformMovieMethodReturnValueReady(handle) do
        if GetGameTimer() > deadline then return "nincs valasz a scaleformtol" end
        Wait(0)
    end

    local info = GetScaleformMovieMethodReturnValueString(handle)

    if not info or info == "" then
        return "ures valasz: a regi minimap.gfx fut (ujracsatlakozas kell, a restart nem eleg)"
    end

    return info
end

function loadMap()
    local shape = MapShapes[currentMapShape] or MapShapes[DEFAULT_MAP_SHAPE]

    DisplayRadar(false)

    if not firstLoad then
        Config.Notify(Translations[Config.Locale]["LOADING"], Translations[Config.Locale]["MAP_LOADING"], "success", 5000, "fa-solid fa-map", "green")
    end

    RequestStreamedTextureDict(shape.txd, false)

    -- Bounded: a dictionary that never turns up must not park this thread forever, the radar is
    -- still drawn (with the stock mask) if we give up.
    local waited = 0
    while not HasStreamedTextureDictLoaded(shape.txd) and waited < 2000 do
        Wait(50)
        waited = waited + 50
    end

    SetMinimapClipType(shape.clipType)

    -- Release the previous shape's overrides first - leaving them bound keeps the old mask on the
    -- radar and the new dictionary never gets a look in.
    if appliedMasks then
        for i = 1, #appliedMasks do
            RemoveReplaceTexture("platform:/textures/graphics", appliedMasks[i])
        end
    end

    for i = 1, #shape.masks do
        AddReplaceTexture("platform:/textures/graphics", shape.masks[i], shape.txd, "radarmasksm")
    end

    appliedMasks = shape.masks

    ApplyMapLayout()

    SetBlipAlpha(GetNorthRadarBlip(), 255)
    SetMinimapClipType(shape.clipType)

    DisplayRadar(true)
    SetRadarBigmapEnabled(true, true)
    Wait(50)
    SetRadarBigmapEnabled(false, false)

    -- After the flip, which is when the radar has just rebuilt its mask clip. Switching back to
    -- the square shape goes through here as well and puts the rectangle back.
    applyBlipMask()

    if not firstLoad then
        firstLoad = true
        Citizen.SetTimeout(1000, function()
            Config.Notify(Translations[Config.Locale]["LOADED"], Translations[Config.Locale]["MAP_LOADED"], "success", 5000, "fa-solid fa-map", "green")
        end)
    end
end

-- Called from the settings menu (and once on UI load, with whatever the player last picked).
---@param shape string "square" or "circle"
function SetMapShape(shape)
    if not MapShapes[shape] then
        shape = DEFAULT_MAP_SHAPE
    end

    if shape == currentMapShape then
        -- Same shape, but this is the path a UI reload takes too, and the reloaded page has lost
        -- its ring box. Re-sending it is cheap; rebuilding the mask (which flickers) is not.
        if appliedMasks then ApplyMapLayout() end
        return
    end

    currentMapShape = shape

    -- Before the first loadMap() there is nothing bound yet and the shape is simply picked up
    -- when the map comes up on login; afterwards the swap has to happen now, so the map matches
    -- the button the player just clicked.
    if appliedMasks then
        CreateThread(loadMap)
    end
end

function GetMapShape()
    return currentMapShape
end

--[[ The stock satnav readout --------------------------------------------------------------------

With a waypoint set the game prints the distance to it ("0.9 mi", with an arrow) under the radar.
The minimap scaleform draws that, not the HUD, so HideHudComponentThisFrame cannot reach it, and
its place is fixed against the map render - which the round shape moves and enlarges, so the text
lands across the lower half of the disc.

The scaleform has a HIDE_SATNAV method for exactly this. It lasts for the frame it is called in,
hence the loop - and only for the round map: with the squared frame the readout sits where it
always has, and players are used to reading it there.

The loop used to also require IsWaypointActive(), which is what let the readout back onto the
disc. That native only covers the waypoint the player places by hand; a GPS route a script draws
with SetBlipRoute (job destinations, deliveries, heists) prints the same distance while
IsWaypointActive() stays false, so the gate skipped exactly the case players hit most. Only the
shape is checked now - two native calls a frame, and only for players who picked the round map
(the default is square).
]]
CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    local waited = 0

    while not HasScaleformMovieLoaded(minimap) and waited < 5000 do
        Wait(50)
        waited = waited + 50
    end

    if not HasScaleformMovieLoaded(minimap) then return end

    -- Requesting the movie can leave the radar stuck on the interior map; the same bigmap flip
    -- loadMap() uses puts it back.
    SetBigmapActive(true, false)
    Wait(0)
    SetBigmapActive(false, false)

    -- The same movie carries the blip mask. A first loadMap() can run before this point, so the
    -- shape it wanted is sent again now that there is a handle to send it to.
    minimapMovie = minimap
    applyBlipMask()

    local nextBlipMaskSend = 0

    while true do
        if currentMapShape == "circle" then
            BeginScaleformMovieMethod(minimap, "HIDE_SATNAV")
            EndScaleformMovieMethod()

            local now = GetGameTimer()
            if now >= nextBlipMaskSend then
                nextBlipMaskSend = now + BLIP_MASK_RESEND_MS
                applyBlipMask()
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)

--[[ Alignment helper ----------------------------------------------------------------------------

The ring now goes through the same conversion as the radar, which is what a screen that is not
16:9 was missing. This is where that was measured: the tool below is how the 2446x1347 numbers in
getHudBox's comment were taken, by aligning the ring by hand and reading off what it took.

Should another screen still need a nudge, editing this file and restarting the resource to chase a
few pixels is slow, so /terkepbeallitas moves the map and the ring live instead. Whatever it ends
up with is kept per client (KVP, survives a relog) and printed to F8 in the exact shape of
MAP_ALIGN above, ready to be pasted in as everyone's default.

Note the targets are not the same thing: TERKEP moves the radar itself (useful when the disc
hangs off the edge of the screen), KERET only moves the outline the UI draws. Moving the map takes
the ring with it, so the usual order is map first, ring second.

BLIPMASZK is the ellipse radius blips are clipped to on the round map (see applyBlipMask). While
it is picked the tool puts a large red zone on the player, visible only here, so the clip has
something to show: line its edge up with the edge of the disc. Holding Ctrl (crouch is muted
meanwhile) turns the arrows into the two radii. TERKEP's size resizes the disc but not this
ellipse, so settle that one first. Only meaningful with the round map picked.
]]

-- Versioned: a correction saved before the HUD box was modelled was paying for the letterbox by
-- hand, and applying it now would push the ring out by that much a second time.
local MAP_ALIGN_KVP = "aty_hud:mapalign:v2"
local alignTargets = { "ring", "disc", "clip" }
local alignLabels = { ring = "KERET", disc = "TERKEP", clip = "BLIPMASZK" }
local alignIndex, alignActive = 1, false

local function alignSave()
    SetResourceKvp(MAP_ALIGN_KVP, json.encode(MAP_ALIGN))
end

-- The screen this was tuned on. Two players with the same settings can still see the map in two
-- different places: the aspect ratio decides how deep the 16:9 HUD box is inset, and the safe zone
-- slider in the game's display settings moves HUD elements around as well. `offset` is what the
-- radar was actually given, `raw` what the shipped formula asked for - the two part company where
-- the clamp keeps the disc on screen.
-- `arany` is the ratio the game lays the HUD out for, `ablak` the window's own; they only differ
-- when the aspect ratio setting stretches the picture (see getScreenAspect).
local function alignScreen()
    local resolutionX, resolutionY, _, physicalAspect = getScreenAspect()
    local offset, aspectRatio, raw = getMinimapOffset()
    local insetX = getHudBox(aspectRatio)

    return resolutionX, resolutionY, aspectRatio, GetSafeZoneSize(), offset, raw, insetX, physicalAspect
end

local function alignPrint()
    local resolutionX, resolutionY, aspectRatio, safeZone, offset, raw, insetX, physicalAspect = alignScreen()

    print(("^2[aty_hud] MAP_ALIGN = { disc = { x = %.4f, y = %.4f, size = %.4f }, ring = { x = %.4f, y = %.4f, size = %.4f } }^7")
        :format(MAP_ALIGN.disc.x, MAP_ALIGN.disc.y, MAP_ALIGN.disc.size,
                MAP_ALIGN.ring.x, MAP_ALIGN.ring.y, MAP_ALIGN.ring.size))
    print(("^2[aty_hud] kepernyo: %dx%d  arany: %.4f (ablak %.4f)  safezone: %.4f  offset: %.4f (nyers %.4f)  16:9 doboz: %.4f (%d px)^7")
        :format(resolutionX, resolutionY, aspectRatio, physicalAspect, safeZone, offset, raw, insetX, math.floor(insetX * resolutionX + 0.5)))

    -- Already summed with the correction, so it goes straight into MapShapes.circle.
    local mask = MapShapes.circle.blipMask
    print(("^2[aty_hud] blipMask = { cx = %.2f, cy = %.2f, rx = %.2f, ry = %.2f }^7")
        :format(mask.cx + MAP_ALIGN.clip.x, mask.cy + MAP_ALIGN.clip.y, mask.rx + MAP_ALIGN.clip.w, mask.ry + MAP_ALIGN.clip.h))

    CreateThread(function()
        print("^2[aty_hud] blipmaszk: " .. getBlipMaskInfo() .. "^7")
    end)
end

local function alignLoad()
    local stored = GetResourceKvpString(MAP_ALIGN_KVP)
    if not stored then return end

    local ok, decoded = pcall(json.decode, stored)
    if not ok or type(decoded) ~= "table" then return end

    for _, target in ipairs(alignTargets) do
        local saved = decoded[target]

        if type(saved) == "table" then
            for field in pairs(MAP_ALIGN[target]) do
                if type(saved[field]) == "number" then
                    MAP_ALIGN[target][field] = saved[field]
                end
            end
        end
    end
end

local function alignDrawLine(text, y)
    SetTextFont(4)
    SetTextScale(0.32, 0.32)
    SetTextColour(255, 255, 255, 220)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.33, y)
end

CreateThread(function()
    alignLoad()

    if not Config.MapAlignTool then return end

    TriggerEvent("chat:addSuggestion", "/terkepbeallitas", "Terkep es a kore rajzolt keret egymasra igazitasa (csak nalad latszik)")

    RegisterCommand("terkepbeallitas", function()
        alignActive = not alignActive

        if not alignActive then
            alignSave()
            alignPrint()
            return
        end

        CreateThread(function()
            local helperBlip = nil

            while alignActive do
                local target = alignTargets[alignIndex]
                local tune = MAP_ALIGN[target]
                local coarse = IsControlPressed(0, 21)
                local changed = false

                -- Space cycles the target and the wheel resizes; left alone they would make the
                -- player jump and switch weapons while aligning.
                DisableControlAction(0, 22, true)
                DisableControlAction(0, 241, true)
                DisableControlAction(0, 242, true)

                if target == "clip" then
                    -- Gfx units, where the rectangle is about 180 wide: half a unit a press, five
                    -- with Shift. Up on screen is -y inside the movie.
                    local step = coarse and 5.0 or 0.5
                    DisableControlAction(0, 36, true)
                    local radii = IsDisabledControlPressed(0, 36)

                    if IsControlJustPressed(0, 174) then if radii then tune.w = tune.w - step else tune.x = tune.x - step end changed = true end
                    if IsControlJustPressed(0, 175) then if radii then tune.w = tune.w + step else tune.x = tune.x + step end changed = true end
                    if IsControlJustPressed(0, 172) then if radii then tune.h = tune.h + step else tune.y = tune.y - step end changed = true end
                    if IsControlJustPressed(0, 173) then if radii then tune.h = tune.h - step else tune.y = tune.y + step end changed = true end
                    if IsDisabledControlJustPressed(0, 241) then tune.w = tune.w + step tune.h = tune.h + step changed = true end
                    if IsDisabledControlJustPressed(0, 242) then tune.w = tune.w - step tune.h = tune.h - step changed = true end

                    local coords = GetEntityCoords(PlayerPedId())

                    if not helperBlip then
                        helperBlip = AddBlipForRadius(coords.x, coords.y, coords.z, 1500.0)
                        SetBlipColour(helperBlip, 1)
                        SetBlipAlpha(helperBlip, 110)
                    else
                        SetBlipCoords(helperBlip, coords.x, coords.y, coords.z)
                    end
                else
                    -- Shift is the coarse step: 0.5% of the screen against 0.05%, so a few presses
                    -- land in the right neighbourhood and the rest is fine-tuning.
                    local step = coarse and 0.0050 or 0.0005

                    if IsControlJustPressed(0, 174) then tune.x = tune.x - step changed = true end
                    if IsControlJustPressed(0, 175) then tune.x = tune.x + step changed = true end
                    if IsControlJustPressed(0, 172) then tune.y = tune.y + step changed = true end
                    if IsControlJustPressed(0, 173) then tune.y = tune.y - step changed = true end
                    if IsDisabledControlJustPressed(0, 241) then tune.size = tune.size + step changed = true end
                    if IsDisabledControlJustPressed(0, 242) then tune.size = tune.size - step changed = true end

                    if helperBlip then
                        RemoveBlip(helperBlip)
                        helperBlip = nil
                    end
                end

                if IsDisabledControlJustPressed(0, 22) then
                    alignIndex = (alignIndex % #alignTargets) + 1
                end

                if IsControlJustPressed(0, 176) then -- Enter
                    alignSave()
                    alignPrint()
                end

                if IsControlJustPressed(0, 177) then -- Backspace
                    alignActive = false
                    alignSave()
                    alignPrint()
                end

                if changed then
                    if target == "clip" then applyBlipMask() else ApplyMapLayout() end
                end

                local resolutionX, resolutionY, aspectRatio, safeZone, offset, raw, _, physicalAspect = alignScreen()
                local mask = MapShapes.circle.blipMask

                alignDrawLine("~y~TERKEP IGAZITAS~s~   most: ~b~" .. alignLabels[target] .. "~s~   (szokoz: valtas)", 0.730)
                alignDrawLine("nyilak: mozgatas     eger-gorgo: meret     shift: nagyobb lepes     ctrl+nyilak: blipmaszk sugarai", 0.760)
                alignDrawLine("enter: mentes es kiiras (F8)     backspace: kilepes", 0.785)
                alignDrawLine(("keret   x %.4f   y %.4f   meret %.4f"):format(MAP_ALIGN.ring.x, MAP_ALIGN.ring.y, MAP_ALIGN.ring.size), 0.815)
                alignDrawLine(("terkep  x %.4f   y %.4f   meret %.4f"):format(MAP_ALIGN.disc.x, MAP_ALIGN.disc.y, MAP_ALIGN.disc.size), 0.840)
                alignDrawLine(("blipmaszk   kozep %.1f / %.1f   sugar %.1f / %.1f")
                    :format(mask.cx + MAP_ALIGN.clip.x, mask.cy + MAP_ALIGN.clip.y, mask.rx + MAP_ALIGN.clip.w, mask.ry + MAP_ALIGN.clip.h), 0.865)
                alignDrawLine(("kepernyo %dx%d   arany %.4f (ablak %.4f)   safezone %.4f   offset %.4f (nyers %.4f)")
                    :format(resolutionX, resolutionY, aspectRatio, physicalAspect, safeZone, offset, raw), 0.895)

                Wait(0)
            end

            if helperBlip then
                RemoveBlip(helperBlip)
            end
        end)
    end, false)
end)

function ragdollP()
	if not SeatBelt then 
		playerPed = PlayerPedId()
		local position = GetEntityCoords(playerPed)
		SetEntityCoords(playerPed, position.x, position.y, position.z - 0.47, true, true, true)
		SetEntityVelocity(playerPed, prevVelocity.x, prevVelocity.y, prevVelocity.z)
		Wait(1)
		SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
	end
end

function IsWhitelistedWeaponStress(weapon)
    if weapon then
        for _, v in pairs(Config.WhitelistedWeaponStress) do
            if weapon == v then
                return true
            end
        end
    end
    return false
end

function table_size(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

--[[ HUD message de-duplication ------------------------------------------------------------------

The HUD polls on fixed timers and used to push every payload unconditionally: the gun panel every
200ms while armed, the toggle every 500ms, the street name every 3s. Between two ticks almost
nothing has changed, so most of that was a JSON encode plus a CEF IPC round trip that repainted
exactly the same pixels.

SendHudMessage keeps the last payload per action and only forwards it when a field actually moved.
Payloads are fixed-shape per action (same key set every call), which is what makes the comparison
safe.
]]

local lastHudPayload = {}

---@param action string
---@param payload table
function SendHudMessage(action, payload)
    payload.action = action

    local previous = lastHudPayload[action]
    if previous then
        local changed = false

        for k, v in pairs(payload) do
            if previous[k] ~= v then
                changed = true
                break
            end
        end

        if not changed then return end
    end

    lastHudPayload[action] = payload
    SendNUIMessage(payload)
end

-- The UI keeps no state across a reload, so the cache has to go with it or the first identical
-- payload after a reload would be swallowed and the panel would sit empty.
function ResetHudMessageCache()
    lastHudPayload = {}
end
