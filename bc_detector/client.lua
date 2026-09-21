local boneoffsets = {
    model = `w_am_digiscanner`,
    bone = 18905,
    offset = vector3(0.15, 0.1, 0.0),
    rotation = vector3(270.0, 90.0, 80.0),
}
local isInZone = false
local using = false
local thread = false
local lastpos = vector3(0.0, 0.0, 0.0)



CreateThread(function()
    Wait(10000)
    local MetalZone = PolyZone:Create(Config.DetectorZones, {
        name = "Fém kereső zóna",
    })
    
    MetalZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            isInZone = true 
        else
            isInZone = false 
        end
    end)

    AddTextEntry('detector_usage', '~INPUT_VEH_HEADLIGHT~ a fémek kereséséhez ~n~~INPUT_VEH_DUCK~ a detektor elrakásához')
end)

RegisterNetEvent("bc_detector:setState", function(data)
    if not data then 
        using = false
        return 
    end 
    if not isInZone then 
        return TriggerEvent("esx:showNotification", "Itt nem használhatod a detektort!")
    end 
    using = true
    if thread then return end 
    CreateThread(MainThread)
end)

function MainThread()
    thread = true 
    while not HasModelLoaded(boneoffsets.model) do
        RequestModel(boneoffsets.model)
        Wait(10)
    end
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local ent = CreateObjectNoOffset(boneoffsets.model, pos, 1, 1, 0)
    -- bc_kocsitorles: legalis spawn jelolese
    if ent and ent ~= 0 and NetworkGetEntityIsNetworked(ent) then Entity(ent).state:set('bc_spawned', true, true) end
    AttachEntityToEntity(ent, ped, GetPedBoneIndex(ped, boneoffsets.bone), boneoffsets.offset, boneoffsets.rotation, 1, 1, 0, 0, 2, 1)
    while using do 
        Wait(1)
        if not isInZone then 
            TriggerEvent("bc_detector:setState", false)
        end 
        DisplayHelpTextThisFrame('detector_usage')
        if IsControlJustReleased(0, 73) then
            TriggerEvent("bc_detector:setState", false)
        end 
        if IsControlJustReleased(0, 74) then
            if #(GetEntityCoords(PlayerPedId()) - lastpos) > 10 then 
                lastpos = GetEntityCoords(PlayerPedId())
                local success = lib.skillCheck({'easy', 'easy'}, {'w', 'a', 's', 'd'})
                if success then 
                    local gymmult = 1.0
                        if GetResourceState("vilmos_gym") == "started" then 
                            local bst = exports["vilmos_gym"]:getSkill("strenght")
                            gymmult = gymmult + (bst/100)
                            if gymmult > 2.0 then 
                                gymmult = 2.0 
                            end 
                        end 
                    if lib.progressBar({
                        duration = (17000-(2000*gymmult)),
                        label = 'Fémkeresés...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true 
                        },
                        anim = {
                            dict = 'mini@golfai',
                            clip = 'wood_idle_a'
                        }
                    }) then 
                        exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_detector:detected")
                    end
                end 
            else 
                TriggerEvent("esx:showNotification", "Itt most kerestél, menj odébb!")
                Wait(3000)
            end 
        end 
    end 
    DeleteEntity(ent)
    thread = false
end 

AddEventHandler("esx:removeInventoryItem", function(name, count)
    if name == Config.DetectorItem then 
        if count < 1 then 
            TriggerEvent("bc_detector:setState", false)
        end 
    end 
end)

local pedmarker = vector3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
local baseprices = {}

-- 2026-09-16: a Mark NPC blipjet mostantol a `blipek` resource rajzolja
-- (config.lua "Antik kereskedö", 780.13/570.06), hogy a terkep jelmagyarazataban
-- egy sorba kerulhessen a paleto-ival. true-ra allitva visszajon ez a blip, de
-- akkor ket kulon sor lesz (a nev es a meret is elter).
local SHOW_BLIP <const> = false

CreateThread(function()
    while ESX == nil do
		Wait(10)
	end

    -- "kereskedovel": a GTA font a hosszu o-t (ő) ures negyzetnek rajzolja.
    AddTextEntry('antik_open_msg', '~INPUT_PICKUP~ hogy beszélj az antik kereskedövel')

    if SHOW_BLIP then
        local blip = AddBlipForCoord(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
        SetBlipSprite (blip, 480)
        SetBlipScale  (blip, 1.0)
        SetBlipColour (blip, 28)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("Antik kereskedo")
        EndTextCommandSetBlipName(blip)
        MunkaBlip('antik_kereskedo', blip)
    end

    if IsModelInCdimage(Config.NPC.model) then 
        RequestModel(Config.NPC.model)
        while not HasModelLoaded(Config.NPC.model) do
            Wait(1)
        end
        local ped = CreatePed(1, Config.NPC.model, Config.NPC.coords, false, false)
        PlaceObjectOnGroundProperly(ped)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
        SetModelAsNoLongerNeeded(Config.NPC.model)

        pedmarker = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.8, -1.0)
            
        Wait(10)
    else 
        print("FIGYELEM! Érvénytelen ped model hash: "..Config.NPC.model)
    end 


    while true do 
        local coords = GetEntityCoords(PlayerPedId())
        local sleep = 1000

        if #(coords - pedmarker) < 20 then 
            sleep = 2
            DrawText3D(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z+2.1, Config.NPC.label)
            DrawMarker(6, pedmarker, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 155, 20, 100, true, true, 2, false, false, false, false)
            DrawMarker(20, pedmarker.x, pedmarker.y, pedmarker.z+0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 0, 155, 20, 100, true, true, 2, false, false, false, false)
            if #(coords - pedmarker) < 1.5 then 
                DisplayHelpTextThisFrame('antik_open_msg')
                if IsControlJustReleased(0, 38) then
                    OpenMenu()
                end 
            end 
        end 

        Wait(sleep)
    end 
end)

function DrawText3D(x, y, z, text) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    if onScreen then
        SetTextScale(0.0, 0.4*scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
	    AddTextComponentString(text)
	    EndTextCommandDisplayText(_x, _y)
    end
end

function OpenMenu()
    ESX.TriggerServerCallback("bc_detector:canDeal", function(data) 
        if not data then 
            return TriggerEvent("esx:showNotification", "Próbálkozz később!")
        end 
        baseprices = data
        local menuoptions = {}
        for k, v in pairs(Config.SellItems) do 
            menuoptions[#menuoptions+1] = {
                title = "Eladás: "..v.label,
                arrow = true,
                onSelect = function()
                    OpenOfferMenu(k) 
                end
            }
        end 
        lib.registerContext({
            id = 'antik_base',
            title = 'Válassz mit szeretnél eladni',
            options = menuoptions
        })
        lib.showContext('antik_base')
    end)
end

function OpenOfferMenu(item)
    if not Config.SellItems[item] then return end 
    if not baseprices[item] then return end 
    local input = lib.inputDialog('Dialog title', {
        {type = 'number', label = 'Mennyit '..Config.SellItems[item].label.."-t szeretnél eladni?", required = true},
    })
    --print(json.encode(input), input[1])
    if not input then return end
    if not input[1] or input[1] < 1 then return end
    local count = input[1] 
    local options = {
        {
            title = 'Ennyit adok darabjáért: '..baseprices[item],
        },
        {
            title = 'Elfogadom!',
            onSelect = function()
                TriggerServerEvent("bc_detector:makeDeal", item, count, 1)
                lib.hideContext(false)
            end
        },
    }
    for k, v in pairs(Config.SellItems[item].offers) do 
        options[#options+1] = {
            title = 'Legyen '..math.floor(k*baseprices[item]).."!",
            onSelect = function()
                TriggerServerEvent("bc_detector:makeDeal", item, count, k)
                lib.hideContext(false)
            end
        }
    end 
    lib.registerContext({
        id = 'antik_offer',
        title = 'Eladás: '..count.."db "..Config.SellItems[item].label,
        options = options
    })
    lib.showContext('antik_offer')
end 

local buymarker = vector3(Config.Buy.coords.x, Config.Buy.coords.y, Config.Buy.coords.z)

-- A blipet csak a jatekos spawnja utan (+1-2 mp) hozzuk letre: a betolteskori
-- torlodasban a blip neve elveszhet a terkep jelmagyarazatabol. A firstName-et az
-- ESX a karakter betoltesekor allitja be; a spawn es a SpawnSelector alatt a kep el
-- van sotetitve, vagy player switch / spawnSelecting fut. Az 1-2 mp resource-onkent mas.
local function WaitForSpawnBeforeBlips()
    while LocalPlayer.state.firstName == nil
        or not IsScreenFadedIn()
        or IsPlayerSwitchInProgress()
        or LocalPlayer.state.spawnSelecting == true do
        Wait(500)
    end
    Wait(1000 + GetHashKey(GetCurrentResourceName()) % 1000)
end

CreateThread(function()
    while ESX == nil do
		Wait(10)
	end

    AddTextEntry('detector_buy_msg', '~INPUT_PICKUP~ hogy vegyél egy fémdetekrtort '..Config.Buy.price.."$-ért")

    CreateThread(function()
        WaitForSpawnBeforeBlips()
        local blip = AddBlipForCoord(Config.Buy.coords.x, Config.Buy.coords.y, Config.Buy.coords.z)
        SetBlipSprite (blip, 317)
        SetBlipScale  (blip, 1.0)
        SetBlipColour (blip, 26)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("Fémdetektorozás")
        EndTextCommandSetBlipName(blip)
        MunkaBlip('femdetektorozas', blip)
    end)

    if IsModelInCdimage(Config.Buy.model) then 
        RequestModel(Config.Buy.model)
        while not HasModelLoaded(Config.Buy.model) do
            Wait(1)
        end
        local ped = CreatePed(1, Config.Buy.model, Config.Buy.coords, false, false)
        PlaceObjectOnGroundProperly(ped)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
        SetModelAsNoLongerNeeded(Config.Buy.model)

        buymarker = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.8, -1.0)
            
        Wait(10)
    else 
        print("FIGYELEM! Érvénytelen ped model hash: "..Config.Buy.model)
    end 


    while true do 
        local coords = GetEntityCoords(PlayerPedId())
        local sleep = 1000

        if #(coords - buymarker) < 20 then 
            sleep = 2
            DrawMarker(6, buymarker, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 155, 20, 100, true, true, 2, false, false, false, false)
            DrawMarker(20, buymarker.x, buymarker.y, buymarker.z+0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 0, 155, 20, 100, true, true, 2, false, false, false, false)
            if #(coords - buymarker) < 1.5 then 
                DisplayHelpTextThisFrame('detector_buy_msg')
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("bc_detector:buy")
                    Wait(7000)
                end 
            end 
        end 

        Wait(sleep)
    end 
end)