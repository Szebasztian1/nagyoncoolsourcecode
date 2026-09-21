--[[
    FactionHQ - animated NUI menu (replaces the ESX default menus)

    HQMenu.Open(def, cb)
      def = { title, subtitle, items = { { id, label, desc?, right?,
              icon?, disabled?, danger? }, ... } }
      cb(itemId) on select, cb(nil) on back/close.
    Every select/back closes the menu first; submenus simply call Open
    again (the panel entrance animation replays). NUI focus is always
    released here, so the menu cannot leak focus or callbacks.
]]

local HQMenu = { open = false }

local currentCb = nil

local function closeInternal()
    HQMenu.open = false
    currentCb = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

function HQMenu.Open(def, cb)
    currentCb = cb
    HQMenu.open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', menu = def })
end

function HQMenu.Close()
    if HQMenu.open then closeInternal() end
end

RegisterNUICallback('select', function(d, cb)
    cb('ok')
    local fn = currentCb
    closeInternal()
    if fn then fn(tostring(d.id)) end
end)

RegisterNUICallback('back', function(_, cb)
    cb('ok')
    local fn = currentCb
    closeInternal()
    if fn then fn(nil) end
end)

-- Never leave the game with stuck NUI focus
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and HQMenu.open then
        SetNuiFocus(false, false)
    end
end)

return HQMenu
