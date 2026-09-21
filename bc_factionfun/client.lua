CreateThread(function()
    AddTextEntry('bc_faction_place_msg',
        '~INPUT_SKIP_CUTSCENE~ lehelyezés ~n~ ~INPUT_CELLPHONE_CANCEL~ mégse fel/le nyilak magasság állítása jobb/bal nyilak forgatás') --18 177
end)

RegisterCommand("frakciofejlesztes", function(s, a, r)
    local perm = lib.callback.await('bc_factionfun:getPerm', false)
    if #perm == 0 then
        TriggerEvent("esx:showNotifiaction", "A te frakciód számára nincs elérhető fejlesztés.")
        return
    end
    local elements = {}
    for k, v in pairs(perm) do
        elements[#elements + 1] = {
            title = Config.Objs[v].label .. " - $" .. Config.Objs[v].price,
            description = Config.Objs[v].description,
            onSelect = function()
                PlaceObj(v)
                lib.hideContext(false)
            end
        }
    end
    lib.registerContext({
        id = 'fractionfun',
        title = 'Frakció fejlesztések (készpénzes fizetés)',
        options = elements
    })

    lib.showContext('fractionfun')
end, false)

function PlaceObj(ot)
    CreateThread(function()
        local hash = Config.Objs[ot].prop
        if not IsModelInCdimage(hash) then
            print('érvénytelen model: '..hash)
            return
        end
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
        local obj = CreateObject(hash, GetEntityCoords(PlayerPedId()), false)
        while not DoesEntityExist(obj) do
            Wait(10)
        end
        SetEntityAlpha(obj, 70, false)
        SetEntityCollision(obj, false, true)
        local offset = Config.Objs[ot].offset
        local hoffset = (Config.Objs[ot].hoffset or 0.0)
        while true do
            Wait(1)
            DisplayHelpTextThisFrame('bc_faction_place_msg')
            local ped = PlayerPedId()
            SetEntityCoords(obj, GetOffsetFromEntityInWorldCoords(ped, offset))
            SetEntityHeading(obj, GetEntityHeading(ped) + hoffset)
            --print(GetOffsetFromEntityInWorldCoords(ped, offset), GetEntityHeading(ped)+hoffset)
            if IsControlJustReleased(0, 18) then
                --PlaceObjectOnGroundProperly(obj)
                TriggerServerEvent('bc_factionfun:place', ot, GetEntityCoords(obj), GetEntityHeading(ped) + hoffset)
                --print(GetEntityCoords(obj), GetEntityHeading(ped)+hoffset)
                break
            elseif IsControlJustReleased(0, 177) then
                break
            end

            -- arrow left
            if IsControlPressed(0, 174) then
                hoffset = hoffset - 0.1
                if hoffset < 0 then
                    hoffset = 360
                end
                -- arrow right
            elseif IsControlPressed(0, 175) then
                hoffset = hoffset + 0.1
                if hoffset > 360 then
                    hoffset = 0
                end
            end
            -- arrow up
            if IsControlPressed(0, 172) then
                offset = vector3(offset.x, offset.y, offset.z + 0.004)
                -- arrow down
            elseif IsControlPressed(0, 173) then
                offset = vector3(offset.x, offset.y, offset.z - 0.004)
            end
        end
        DeleteEntity(obj)
        SetModelAsNoLongerNeeded(hash)
    end)
end

-- id -> entity. Korabban ez sima tomb volt (`objs[#objs+1]`), ezert egyetlen
-- targyat nem lehetett belole kivenni: minden valtozasnal az OSSZESET le kellett
-- bontani es ujraepiteni. Az id-kulcsos tarolas teszi lehetove a delta kezelest.
local objs = {}

---Egy targy lebontasa (target + entitas).
---@param id any
local function RemoveObj(id)
    local obj = objs[id]
    if not obj then return end
    exports.ox_target:removeLocalEntity(obj, "bc_factionfun")
    exports.ox_target:removeLocalEntity(obj, "bc_factionfun:huto")
    if DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
    objs[id] = nil
end

---Egy targy letrehozasa. Ha az id-n mar all valami, azt elobb lebontja.
---@param id any
---@param v table
local function SpawnObj(id, v)
    if not v then return end
    RemoveObj(id)

    local hash = v.prop

    CreateThread(function()
        local to = 2000
        RequestModel(hash)
        while not HasModelLoaded(hash) and to > 0 do
            to = to - 10
            Wait(10)
        end
        if HasModelLoaded(hash) then
            local obj = CreateObject(hash, vector3(v.coords.x, v.coords.y, v.coords.z), false)
            local to = 2000
            while not DoesEntityExist(obj) and to > 0 do
                to = to - 10
                Wait(10)
            end
            FreezeEntityPosition(obj, true)
            objs[id] = obj
            SetModelAsNoLongerNeeded(hash)
            SetEntityHeading(obj, v.heading)
            if hash == GetHashKey("prop_fridge_03") then
                exports.ox_target:addLocalEntity(obj, { {
                    name = 'bc_factionfun:huto',
                    icon = 'fa-solid fa-circle',
                    label = 'Hűtő',
                    onSelect = function()
                        exports.ox_inventory:openInventory('stash', "factionfun-" .. (v.stashid or id))
                    end
                } })
            end
            exports.ox_target:addLocalEntity(obj, { {
                name = 'bc_factionfun',
                icon = 'fa-solid fa-circle',
                label = 'Eltávolítás',
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Eltávolítás',
                        content = 'Biztosan eltávolítod az adott tárgyat? Az árát nem kapod vissza!',
                        centered = true,
                        cancel = true
                    })
                    if alert == true or alert == "confirm" then
                        TriggerServerEvent("bc_factionfun:delete", id)
                    end
                end
            } })
        end
    end)
end

-- Teljes ujraepites. Csak belepeskor (lib.callback) es a /factionfunrefresh
-- konzolparancsnal fut le -- NEM minden lehelyezesnel, mint korabban.
RegisterNetEvent('bc_factionfun:refresh', function(spawn)
    for id in pairs(objs) do
        RemoveObj(id)
    end
    objs = {}
    for k, v in pairs(spawn) do
        if v then
            SpawnObj(k, v)
        end
    end
end)

-- Delta: egyetlen targy jott letre / valtozott.
RegisterNetEvent('bc_factionfun:added', function(id, data)
    if not id or not data then return end
    SpawnObj(id, data)
end)

-- Delta: egyetlen targyat tavolitottak el.
RegisterNetEvent('bc_factionfun:removed', function(id)
    if not id then return end
    RemoveObj(id)
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(1000)
    end
    Wait(5000)
    local spawn = lib.callback.await('bc_factionfun:refresh', false)
    TriggerEvent('bc_factionfun:refresh', spawn)

    exports.ox_inventory:displayMetadata('edate', 'Lejárati dátum')
end)

RegisterCommand("autogov", function(s, a, r)
    if not Config.AutoGovs[ESX.PlayerData.job.name] then
        return
    end
    local elements = {}
    for k, v in pairs(Config.AutoGovs[ESX.PlayerData.job.name]) do
        elements[#elements + 1] = {
            title = "->",
            description = v,
            onSelect = function()
                TriggerServerEvent("bc_factionfun:sendgov", k)
            end
        }
    end
    lib.registerContext({
        id = 'autogov',
        title = 'Auto govolás',
        options = elements
    })

    lib.showContext('autogov')
end, false)
