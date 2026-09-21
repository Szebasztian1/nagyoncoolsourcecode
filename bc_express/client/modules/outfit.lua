-- BC Express – munkaruha: a kocsi felvételekor kerül fel, a munka végén
-- (leadás / időtúllépés / resource stop) az eredeti ruha áll vissza.

local Outfit = {}

local saved = nil   -- [component] = { drawable, texture } – az eredeti ruha darabjai

local function getList()
    if GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` then
        return Config.Uniform.female
    end
    return Config.Uniform.male
end

function Outfit.apply()
    if not Config.Uniform.enabled or saved then return end
    local ped  = PlayerPedId()
    local list = getList()
    saved = {}
    for i = 1, #list do
        local c = list[i]
        saved[c.component] = {
            drawable = GetPedDrawableVariation(ped, c.component),
            texture  = GetPedTextureVariation(ped, c.component),
        }
        SetPedComponentVariation(ped, c.component, c.drawable, c.texture, 0)
    end
end

function Outfit.restore()
    if not saved then return end
    local ped = PlayerPedId()
    for component, v in pairs(saved) do
        SetPedComponentVariation(ped, component, v.drawable, v.texture, 0)
    end
    saved = nil
end

return Outfit
