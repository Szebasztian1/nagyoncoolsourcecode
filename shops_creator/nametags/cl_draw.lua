-- Shop name plates — rendering.
-- Native 3D text and help prompts only: no NUI, no entities, nothing created in
-- the world. Called once per visible plate per frame, and only while a plate is
-- actually in range.

NameTags = NameTags or {}
NameTags.Draw = {}

local cfg = NameTags.Config
local DEFAULT = cfg.colors[cfg.defaultColor] or { rgb = { 255, 255, 255 } }
local FADE = cfg.drawDistance * 0.25   -- the last quarter of the range fades in

function NameTags.Draw.ResolveColor(key)
    local color = cfg.colors[key] or DEFAULT
    return color.rgb[1], color.rgb[2], color.rgb[3]
end

function NameTags.Draw.Plate(plate, dist)
    local alpha = 255
    if dist > cfg.drawDistance - FADE then
        alpha = math.floor(255.0 * (cfg.drawDistance - dist) / FADE)
        if alpha <= 0 then return end
    end

    -- Grows slightly as you walk up to it, like a player nametag.
    local scale = cfg.textScale * (1.0 + (cfg.drawDistance - dist) / cfg.drawDistance * 0.35)

    SetTextFont(4)
    SetTextScale(0.0, scale)
    SetTextColour(plate.r, plate.g, plate.b, alpha)
    SetTextCentre(true)
    SetTextDropshadow(0, 0, 0, 0, alpha)
    SetTextDropShadow()
    SetTextOutline()

    SetDrawOrigin(plate.x, plate.y, plate.z, 0)
    SetTextEntry('STRING')
    AddTextComponentSubstringPlayerName(plate.t)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function NameTags.Draw.Help(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, false, -1)
end
