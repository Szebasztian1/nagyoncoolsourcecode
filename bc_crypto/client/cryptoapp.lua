-- RoadPhone "Crypto" app (client): bridges the phone iframe (NUI) to the server via ox_lib callbacks.
-- The iframe is served from cfx-nui-bc_crypto, so its fetch('https://bc_crypto/...') hits these callbacks.

RegisterNUICallback('cryptoGetData', function(_, cb)
    local data = lib.callback.await('bc_crypto:app:getData', false)
    cb(data or { ok = false })
end)

RegisterNUICallback('cryptoBuyAccess', function(_, cb)
    local data = lib.callback.await('bc_crypto:app:buyAccess', false)
    cb(data or { ok = false, reason = 'error' })
end)
