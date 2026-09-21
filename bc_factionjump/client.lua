RegisterNetEvent("bc:showjump", function(jump)
    local alert = lib.alertDialog({
        header = 'Frakciójump',
        content = 'Frakciójumpod lejár: '..jump..'\nEddig nem csatlakozhatsz új frakcióba, ha csak nem vásárolod ki magad a frakciójumpból (PP shop)!\nHa lejárat után nem kerül le discordon a rang, csak nyisd meg ezt a panelt!',
        centered = true,
        cancel = false
    })
end)