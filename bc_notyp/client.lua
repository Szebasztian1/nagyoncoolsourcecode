local isNotifyActive = false

function SendNotification(title, msg, time, nType)
    -- Spam védelem: amíg egy kint van, a többit eldobja
    if isNotifyActive then return end 
    isNotifyActive = true
    
    -- Alap GTA pittyenés
    PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", 1)
    
    SendNUIMessage({
        action = 'showNotification',
        title = title,
        message = msg,
        time = time or 5000,
        type = nType or 'police' -- Ha nincs megadva, alapból rendőr
    })

    -- Csak az animáció és a display idő után engedünk újat
    Citizen.SetTimeout((time or 5000) + 600, function()
        isNotifyActive = false
    end)
end

-- Ezt hívja meg az okokChat (Szerver oldalról a TriggerClientEvent)
RegisterNetEvent("bc_renvedelem:notify", function(p1, p2, time, p4)
    -- p1: Cím, p2: Üzenet, time: Idő, p4: Típus (fbi, ambulance, police)
    SendNotification(p1, p2, time, p4)
end)

-- A felhívás alapból a képernyő legtetején áll. A VIP EXP sáv (aty_hud)
-- ugyanezt a helyet használja, de csak XP-szerzéskor, ~6 másodpercig: amíg
-- kint van, az aty_hud kliense elküldi ezt az eseményt, és a felhívás addig
-- lecsúszik a második sávba (html/style.css: #notification-container.shifted).
AddEventHandler('bc_vipxp:visible', function(ms)
    SendNUIMessage({
        action = 'shiftDown',
        time = tonumber(ms) or 6300
    })
end)

-- Export, ha más scriptből akarnád hívni: exports['scriptneve']:ShowNotify(...)
exports('ShowNotify', SendNotification)