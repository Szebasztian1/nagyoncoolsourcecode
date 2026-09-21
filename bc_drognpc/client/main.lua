--░█████╗░░██████╗██████╗░░░░░█████╗░░██████╗██████╗░
--██╔══██╗██╔════╝██╔══██╗░░░██╔══██╗██╔════╝██╔══██╗
--███████║╚█████╗░██║░░██║░░░███████║╚█████╗░██║░░██║
--██╔══██║░╚═══██╗██║░░██║░░░██╔══██║░╚═══██╗██║░░██║
--██║░░██║██████╔╝██████╔╝██╗██║░░██║██████╔╝██████╔╝
--╚═╝░░╚═╝╚═════╝░╚═════╝░╚═╝╚═╝░░╚═╝╚═════╝░╚═════╝░
local isinmenu = false
local spawnedPed = nil
PedModel = `a_f_m_beach_01` --<---------------- ITT TUDOD BEÁLLÍTANI A PED MODELT!

local function SpawnDrogNPC()
    if spawnedPed and DoesEntityExist(spawnedPed) then return end

    RequestModel(PedModel)
    while not HasModelLoaded(PedModel) do
        Wait(500)
    end

    spawnedPed = CreatePed(4, PedModel, Config.NPCPosition, false, false, false)
    FreezeEntityPosition(spawnedPed, true)
    SetEntityInvincible(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetModelAsNoLongerNeeded(PedModel)

    exports.ox_target:addLocalEntity(spawnedPed, {
        {
            name = 'drognpc',
            icon = 'fa-solid fa-circle',
            label = 'Beszélgetés a drogkereskedővel',
            onSelect = function()
                OpenMenu()
            end,
            CanInteract = function(entity, distance, coords, name, bone)
                return IsAuthorized()
            end 
        }
    })
end

local function DeleteDrogNPC()
    if spawnedPed and DoesEntityExist(spawnedPed) then
        exports.ox_target:removeLocalEntity(spawnedPed, 'drognpc')
        DeleteEntity(spawnedPed)
        spawnedPed = nil
    end
end

local npcPos = Config.NPCPosition
CreateThread(function()
    Wait(10000)
lib.zones.sphere({
    coords = vec3(npcPos.x, npcPos.y, npcPos.z),
    radius = 50.0,
    debug = false,
    onEnter = function()
        SpawnDrogNPC()
    end,
    onExit = function()
        DeleteDrogNPC()
    end
})
end)

function IsAuthorized()
    local jobname = ESX.PlayerData.job.name 
    for _, jj in ipairs(Config.AllowedJobs) do 
        if jobname == jj then 
            return true 
        end 
    end 
    return false 
end 

--[[function InteractLoop()
    while true do
        sleep = 1000
        --if IsAuthorized() then 
            local myped = PlayerPedId()
            local mycoords = GetEntityCoords(myped)
            local x,y,z,h = table.unpack(Config.NPCPosition)

            local distance = #(mycoords - vector3(x,y,z))

            if distance < 2.0 then
                sleep = 5
                local authorized = IsAuthorized()
                if authorized then 
                    Draw3DText(vector3(x,y,z+2.0), "[~g~E~s~] Beszélés a ~r~Drogkereskedövel")  --<---- ITT TUDOD BEÁLLÍTANI MIT ÍRJON KI MIKOR A PED KÖZELÉBE VAGY!
                else 
                    Draw3DText(vector3(x,y,z+2.0), "Csak maffiáknak érhető el")
                end 

                if IsControlJustPressed(0, 38) and authorized then
                    OpenMenu()
                end
            elseif isinmenu then 
                ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'drugseller')
            end
        --end 

        Wait(sleep)
    end
end]]

function OpenMenu()
    ESX.TriggerServerCallback("drognpc:cansell", function(data)
    if not data then 
        ESX.ShowNotification("Köszi van elég cuccom, most tőled nem veszek semmit, esetleg nézz vissza 1 óra múlva!")
        return 
    end 

    isinmenu = true 
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drugseller',
    {
        title = ('Drogkereskedő'), --<------- MENÜ FEJLÉC SZÖVEG!
        align = 'bottom-right',
        elements = GlobalState.DrogPrices
    },
        
    function(data, menu)
        local v = data.current

        if HasItem(v.item, 1) then
            exports["gs_eventprotect"]:GS_TriggerServerEvent("asdasd_drugnpc_sell", v.item, v.value, v.price)
        else
            exports['okokNotify']:Alert("Drogkereskedő", "Nincs nálad elég drog!", 2000, 'error') --<------- MIT ÍRJON KI MIKOR NINCS NÁLAD ELÉG DROG!
        end
    end,
    function(data, menu)
        isinmenu = false 
        menu.close()
    end
    )
    end)
    
end

function HasItem(name, count)
    --[[for i,v in ipairs(ESX.GetPlayerData().inventory) do
        if name == v.name and v.count >= count then 
            return true
        end
    end
    return false]]
    local hascount = exports.ox_inventory:Search('count', name)
    if hascount >= count then 
        return true 
    end 
    return false 
end

function Draw3DText(coords, text)
    AddTextEntry(GetCurrentResourceName(), text)
    BeginTextCommandDisplayHelp(GetCurrentResourceName())
    EndTextCommandDisplayHelp(2, false, false, -1)

    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
end