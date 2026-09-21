local safes = {}
local safesbyobjects = {}
local targetentitiescache = {}

local options = {
    {
        name = 'bc_safes:opensafe',
        event = 'bc_safes:openSafe',
        icon = 'fa-solid fa-road',
        label = 'Széf megtekintése',
    }
}

-- Egyetlen szef valtozasa. Korabban ilyenkor a szerver az OSSZES szefet
-- ujrakuldte mindenkinek; a lenti 4 mp-es ciklus ugyis csak a `safes` tablabol
-- epiti ujra a targeteket, ezert eleg egy elemet modositani benne.
RegisterNetEvent('bc_safes:safeUpdated', function(id, data)
    if not id or not data then return end
    safes[id] = data
end)

RegisterNetEvent('bc_safes:safeRemoved', function(id)
    if not id then return end
    safes[id] = nil
end)

RegisterNetEvent('bc_safes:updateSafes', function(data)
    safes = data

    --[[local targetentities = {}
    local options = {
        {
            name = 'bc_safes:opensafe',
            event = 'bc_safes:openSafe',
            icon = 'fa-solid fa-road',
            label = 'Széf megtekintése',
        },
    }

    exports.ox_target:removeEntity(targetentitiescache, 'bc_safes:opensafe')

    
    safesbyobjects = {}
    for k, v in pairs(safes) do 
        --local entity = NetworkGetEntityFromNetworkId(v.object)
        --if entity and entity ~= 0 then 
            targetentities[#targetentities+1] = v.object
            --safesbyobjects[entity] = k
        --end 
    end 
    targetentitiescache = targetentities
    exports.ox_target:addEntity(targetentities, options)]]
end)

CreateThread(function()
    while not ESX.PlayerLoaded do 
        Wait(10)
    end 
    ESX.TriggerServerCallback("bc_safes:loaded", function(data) 
        safes = data
    end)
    while true do 
        Wait(4000)
        local targetentities = {}     

        safesbyobjects = {}
        -- ket szef-rekord mutathat ugyanarra az objektumra; dupla netid dupla
        -- ox_target opciot (Replacing existing target option warning) okozna
        local seen = {}
        for k, v in pairs(safes) do
            if not seen[v.object] and NetworkDoesNetworkIdExist(v.object) then
                local entity = NetworkGetEntityFromNetworkId(v.object)
                if entity and entity ~= 0 then
                    seen[v.object] = true
                    targetentities[#targetentities+1] = v.object
                    safesbyobjects[entity] = k
                end 
            end 
        end 
        
        -- pairs() sorrendje nem determinisztikus, szeparator nelkul pedig kulonbozo
        -- listak is adhatnak azonos stringet -> rendezes + vesszos osszefuzes
        table.sort(targetentities)
        if table.concat(targetentitiescache, ',') ~= table.concat(targetentities, ',') then
            exports.ox_target:removeEntity(targetentitiescache, 'bc_safes:opensafe')
            targetentitiescache = targetentities
            exports.ox_target:addEntity(targetentities, options)
        end 
    end
end)

AddEventHandler('bc_safes:openSafe', function(response)
    local entity = response.entity 
    if not entity or not safesbyobjects[entity] then return end 
    local safeid = safesbyobjects[entity]
    if not safes[safeid] then return end 
    lib.registerContext({
        id = 'bc_safes:openedSafe',
        title = 'Széf menü',
        options = {
            {
                title = 'A Széf kiniytása',
                description = 'A széf kinyitása a biztonsági kóddal',
                onSelect = function(args)
                    EnterPasscode(args)
                end,
                args = {safeid = safeid}
            },
            {
                title = 'Elfelejtett biztonsági kód',
                description = 'Ha te vagy a széf tulajdonosa, itt állíthatsz be új biztonsági kódot',
                onSelect = function(args)
                    NewPasscode(args)
                end,
                args = {safeid = safeid}
            },
            {
                title = 'A széf feltörése',
                description = 'A széfet feltörheted zártörők segítségével',
                onSelect = function(args)
                    RobSafe(args)
                end,
                args = {safeid = safeid}
            },
            {
                title = 'A széf törlése',
                description = 'Ha te vagy a széf tulajdonosa, felveheted a széfet, de előtte pakolj ki belőle',
                onSelect = function(args)
                    DeleteSafe(args)
                end,
                args = {safeid = safeid}
            }
        }
    })

    lib.showContext('bc_safes:openedSafe')
end)

function RobSafe(args)
    local safeid = args.safeid
    if not safes[safeid] then return end
    ESX.TriggerServerCallback("bc_safes:canStartRob", function(success, msg) 
        if not success then 
            ESX.ShowNotification(msg)
            return 
        end 
        local picked = LockPick(Config.Safes[safes[safeid].size].locks)
        if picked then 
            exports.ox_inventory:openInventory('stash', {id="bc_safe_"..safeid})
        end 
    end, safeid)
end 

function EnterPasscode(args)
    local safeid = args.safeid
    if not safes[safeid] then return end
    
        local input = lib.inputDialog(safes[safeid].label, {
            { type = "input", label = "Széf kód", password = true, icon = 'lock' }
        })
        if not input then 
            ESX.ShowNotification("Helytelen biztonsági kulcs!")
            return 
        end 
        local passcodetry = input[1]

        ESX.TriggerServerCallback("bc_safes:tryPasscode", function(success, owner) 
            if not success then 
                ESX.ShowNotification("Helytelen biztonsági kulcs!")
                return
            end 
            if not owner then 
                exports.ox_inventory:openInventory('stash', {id="bc_safe_"..safeid})
            else 
                OpenOwnerMenu(safeid)
            end 
        end, safeid, passcodetry)
end 

function OpenOwnerMenu(safeid)
    lib.registerContext({
        id = 'bc_safes:ownerMenu',
        title = 'Széf menü',
        options = {
            {
                title = 'Tároló megnyitása',
                description = 'Tároló megnyitása',
                onSelect = function(args)
                    exports.ox_inventory:openInventory('stash', {id="bc_safe_"..args.safeid})
                end,
                args = {safeid = safeid}
            },
            {
                title = 'Új biztonsági kód',
                description = 'Ha te vagy a széf tulajdonosa, itt állíthatsz be új biztonsági kódot',
                onSelect = function(args)
                    NewPasscode(args)
                end,
                args = {safeid = safeid}
            },
            {
                title = 'A széf átnevezése',
                description = 'Ha te vagy a széf tulajdonosa, itt állíthatsz be új nevet',
                onSelect = function(args)
                    NewLabel(args)
                end,
                args = {safeid = safeid}
            },
            {
                title = 'A széf törlése',
                description = 'Ha te vagy a széf tulajdonosa, felveheted a széfet, de előtte pakolj ki beleőle',
                onSelect = function(args)
                    DeleteSafe(args)
                end,
                args = {safeid = safeid}
            },
        }
    })

    lib.showContext('bc_safes:ownerMenu')
end 

function NewPasscode(args)
    local safeid = args.safeid
    if not safes[safeid] then return end

    ESX.TriggerServerCallback("bc_safes:isOwner", function(success) 
        if not success then 
            ESX.ShowNotification("Nem te vagy a széf tulaja!")
            return
        end 

        local input = lib.inputDialog("Új biztonsági kód állítása ide: "..safes[safeid].label, {
            { type = "input", label = "Széf kód", password = false, icon = 'lock' }
        })
        if not input then 
            ESX.ShowNotification("Helytelen biztonsági kulcs!")
            return
        end 
        local newpasscode = input[1]
        if not newpasscode or newpasscode == "" then 
            ESX.ShowNotification("Helytelen biztonsági kulcs!")
            return
        end 

        TriggerServerEvent('bc_safes:newPasscode', safeid, newpasscode)
    end, safeid)
end 

function NewLabel(args)
    local safeid = args.safeid
    if not safes[safeid] then return end

    local input = lib.inputDialog("Új név állítása ide: "..safes[safeid].label, {
        { type = "input", label = "Széf neve" }
    })
    if not input then 
        ESX.ShowNotification("Helytelen név!")
        return
    end 
    local newlabel = input[1]
    if not newlabel or newlabel == "" then 
        ESX.ShowNotification("Helytelen név!")
        return
    end 

    TriggerServerEvent('bc_safes:newLabel', safeid, newlabel)
end 

function DeleteSafe(args)
    local safeid = args.safeid
    if not safes[safeid] then return end

    ESX.TriggerServerCallback("bc_safes:canDelete", function(success)
        if not success then
            ESX.ShowNotification("Nem te vagy a széf tulaja!")
            return
        end
        if not safes[safeid] then return end

        local confirm = lib.alertDialog({
            header = 'Széf törlése',
            content = 'Biztosan törlöd a(z) **'..safes[safeid].label..'** nevű széfet?  \nA benne maradt tárgyak elvesznek!',
            centered = true,
            cancel = true,
            labels = {
                confirm = 'Igen, törlöm',
                cancel = 'Mégse'
            }
        })
        if confirm ~= 'confirm' then return end

        TriggerServerEvent('bc_safes:deleteSafe', safeid)
    end, safeid)
end

RegisterNetEvent('bc_safes:alertRob', function(position, msg)
    ESX.ShowNotification(msg)
    local blip = AddBlipForCoord(position.x, position.y, position.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 2.0)
    SetBlipColour(blip, 3)
    PulseBlip(blip)
    SetTimeout(Config.BlipTime, function()
        RemoveBlip(blip)
    end)
end)