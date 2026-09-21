-----------------------------------------------------------------------------------------------------------------------------------------
-- Egyseges "Munka" terkep-blip -- a blipek resource kezeli (client/work.lua).
--
-- Hasznalat: a blip letrehozasa UTAN egy sor:
--     MunkaBlip('<id a blipek Config.WorkBlips tablajabol>', blip)
--
-- Onnantol a blipek adja ra a kozos nevet/ikont/szint, es az ESC menu Blip
-- fulen ki-be kapcsolhato. Ha a blipek resource nem fut, az esemenyt senki nem
-- kapja el -- a blip pontosan ugy nez ki, mint eddig. Ezert nem toroltuk ki a
-- resource sajat blip-nevezeset: az a tartalek.
--
-- Ezt a fajlt NE szerkeszd resource-onkent kulon: minden munka-resource-ban
-- ugyanez a tartalom van, hogy egy helyen lehessen javitani.
-----------------------------------------------------------------------------------------------------------------------------------------

local ismert = {}

--- @param id string   a blipek Config.WorkBlips-beli azonosito
--- @param blip number a mar letrehozott blip handle
--- @param styleless boolean|nil true: ne kapjon nevet/ikont, csak a ki-be
---        kapcsolast kovesse (terulet-blipekhez, AddBlipForRadius)
--- @return number blip (tovabbadva, hogy `local b = MunkaBlip('x', AddBlipForCoord(...))` is menjen)
function MunkaBlip(id, blip, styleless)
    if type(blip) ~= 'number' or blip == 0 then return blip end

    -- a mar nem letezo handle-ok kitakaritasa (ujraepitett blipek miatt)
    for i = #ismert, 1, -1 do
        if not DoesBlipExist(ismert[i][2]) then
            table.remove(ismert, i)
        end
    end

    ismert[#ismert + 1] = { id, blip, styleless }
    TriggerEvent('blipek:registerWorkBlip', id, blip, styleless)

    return blip
end

-- Ha a blipek resource ezutan a resource utan indul (vagy ujraindul), ujra
-- bejelentkezunk, kulonben a kapcsolok ures listat latnanak.
AddEventHandler('blipek:workReady', function()
    for i = 1, #ismert do
        TriggerEvent('blipek:registerWorkBlip', ismert[i][1], ismert[i][2], ismert[i][3])
    end
end)
