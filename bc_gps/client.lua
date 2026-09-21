local activeBlips = {}
local trackerOn = {}
local state = false 
local myblip = 0
local meincar = false 
local customcolor = nil 

local partnerships = {}
ESX = nil

AddEventHandler("bc_gps:setmycolor", function(d)
    customcolor = d
    --print("ccevent", d, customcolor)
end)

Citizen.CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


RegisterNetEvent('bc_gps:updatepartners')
AddEventHandler('bc_gps:updatepartners', function(data)
	partnerships = data
end)

function GetVehType(model)
    model = type(model) == 'string' and joaat(model) or model

	if model == `submersible` or model == `submersible2` then
        return 'default'
	end

	local vehicleType = GetVehicleClassFromName(model)
	local types = {
		[8] = "bike",
		--[11] = "trailer",
		[13] = "cycles",
		[14] = "boat",
		[15] = "heli",
		[16] = "heli", --plane
		--[21] = "train",
	}

    return types[vehicleType] or "default"
end

function WrapVehicleBlip(veh, job)
    if not job or not Config.Jobs[job] then 
        return 0,0,0 
    end 

    if type(veh) == "boolean" then 
        return Config.Jobs[job].vehBlip.default.sprite, (Config.Jobs[job].vehBlip.default.scale or 1.0), Config.Jobs[job].vehBlip.default.color
    end 

    local vt = GetVehType(veh)
    if Config.Jobs[job].vehBlip[vt] then 
        return Config.Jobs[job].vehBlip[vt].sprite, (Config.Jobs[job].vehBlip[vt].scale or 1.0), Config.Jobs[job].vehBlip[vt].color
    end 
    return Config.Jobs[job].vehBlip.default.sprite, (Config.Jobs[job].vehBlip.default.scale or 1.0), Config.Jobs[job].vehBlip.default.color
end 

RegisterNetEvent('bc_gps:state')
AddEventHandler('bc_gps:state', function(data)
    state = data
    if state then 
        TriggerEvent("esx:showNotification", "A gps jeled szinet a /gpsszin paranccsal valtoztathatod meg!")
        local mycid = PlayerId()

        if ESX.PlayerData and ESX.PlayerData.job and Config.Jobs[ESX.PlayerData.job.name] then 
            local myped = PlayerPedId()
            local veh = GetVehiclePedIsIn(myped)
            local name = GetPlayerName(mycid)
            myblip = AddBlipForEntity(myped)
            if veh and veh ~= 0 then 
                meincar = true 
                local vsprite, vscale, vcolor = WrapVehicleBlip(GetEntityModel(veh), ESX.PlayerData.job.name)
                SetUpBlip(myblip, vsprite, vscale, (customcolor and customcolor or vcolor), name, false)
            else 
                SetUpBlip(myblip, Config.Jobs[ESX.PlayerData.job.name].blip.sprite, (Config.Jobs[ESX.PlayerData.job.name].blip.scale or 1.0), (customcolor and customcolor or Config.Jobs[ESX.PlayerData.job.name].blip.color), name, ESX.PlayerData.dead)
            end 
        end 
    else 
        for k, v in pairs(activeBlips) do 
            RemoveBlip(activeBlips[k].blip)
            activeBlips[k] = nil
        end 

        meincar = false 
        RemoveBlip(myblip)
        myblip = 0
    end 
end)

function isMyPartner(job)
    if not partnerships then 
        return false 
    end 
    if not partnerships[ESX.PlayerData.job.name] then 
        return false 
    end 
    if partnerships[ESX.PlayerData.job.name] and partnerships[ESX.PlayerData.job.name].partner and partnerships[ESX.PlayerData.job.name].partner == job then 
        return true 

    end 
    return false 
end 

RegisterNetEvent('bc_gps:update')
AddEventHandler('bc_gps:update', function(data)
    trackerOn = data
    if ESX and ESX.PlayerData and ESX.PlayerData.job and Config.Jobs[ESX.PlayerData.job.name] and state then 
        local mycid = PlayerId()
        local myped = PlayerPedId()
        local veh = GetVehiclePedIsIn(myped)
        local name = GetPlayerName(mycid)
        --print("customcolor", customcolor)
        if veh and veh ~= 0 and not meincar then 
            meincar = true 
            local vsprite, vscale, vcolor = WrapVehicleBlip(GetEntityModel(veh), ESX.PlayerData.job.name)
            SetUpBlip(myblip, vsprite, vscale, (customcolor and customcolor or vcolor), name, false)
        elseif not veh or veh == 0 and meincar then
            meincar = false 
            SetUpBlip(myblip, Config.Jobs[ESX.PlayerData.job.name].blip.sprite, (Config.Jobs[ESX.PlayerData.job.name].blip.scale or 1.0), (customcolor and customcolor or Config.Jobs[ESX.PlayerData.job.name].blip.color), name, false)
        end 

        for k, v in pairs(activeBlips) do 
            if not trackerOn[k] then 
                RemoveBlip(activeBlips[k].blip)
                activeBlips[k] = nil
            elseif not Config.Jobs[ESX.PlayerData.job.name].canSee[trackerOn[k].job] and not isMyPartner(trackerOn[k].job) then
                RemoveBlip(activeBlips[k].blip)
                activeBlips[k] = nil
            end 
        end 


        local mysid = GetPlayerServerId(mycid)
        for k, v in pairs(trackerOn) do 
            Citizen.Wait(10)
            --print(k, v.customcolor)
            if k ~= mysid and (Config.Jobs[ESX.PlayerData.job.name].canSee[v.job] or isMyPartner(v.job)) then 
                local cid = GetPlayerFromServerId(k)
                if cid ~= -1 then 
                    if activeBlips[k] and activeBlips[k].long then 
                        local ped = GetPlayerPed(cid)
                        RemoveBlip(activeBlips[k].blip)
                        activeBlips[k].blip = AddBlipForEntity(ped)
                        activeBlips[k].long = false 
                        activeBlips[k].dead = v.dead 
                        if v.veh then 
                            activeBlips[k].car = v.veh 
                            local vsprite, vscale, vcolor = WrapVehicleBlip(v.veh, v.job)
                            SetUpBlip(activeBlips[k].blip, vsprite, vscale, (v.customcolor and v.customcolor or vcolor), v.name, v.dead)
                        else 
                            activeBlips[k].car = v.veh 
                            SetUpBlip(activeBlips[k].blip, Config.Jobs[v.job].blip.sprite, (Config.Jobs[v.job].blip.scale or 1.0), (v.customcolor and v.customcolor or Config.Jobs[v.job].blip.color), v.name, v.dead)
                        end 
                    else 
                        if not activeBlips[k] then 
                            local ped = GetPlayerPed(cid)
                            activeBlips[k] = {
                                blip = AddBlipForEntity(ped),
                                car = false,
                                dead = v.dead,
                                long = false 
                            }
                            if v.veh then 
                                activeBlips[k].car = v.veh 
                                local vsprite, vscale, vcolor = WrapVehicleBlip(v.veh, v.job)
                                SetUpBlip(activeBlips[k].blip, vsprite, vscale, (v.customcolor and v.customcolor or vcolor), v.name, v.dead)
                            else 
                                SetUpBlip(activeBlips[k].blip, Config.Jobs[v.job].blip.sprite, (Config.Jobs[v.job].blip.scale or 1.0), (v.customcolor and v.customcolor or Config.Jobs[v.job].blip.color), v.name, v.dead)
                            end 
                        elseif v.veh ~= activeBlips[k].car or v.dead ~= activeBlips[k].dead then 
                            activeBlips[k].dead = v.dead
                            if v.veh then 
                                activeBlips[k].car = v.veh 
                                local vsprite, vscale, vcolor = WrapVehicleBlip(v.veh, v.job)
                                SetUpBlip(activeBlips[k].blip, vsprite, vscale, (v.customcolor and v.customcolor or vcolor), v.name, v.dead)
                            else 
                                activeBlips[k].car = v.veh 
                                SetUpBlip(activeBlips[k].blip, Config.Jobs[v.job].blip.sprite, (Config.Jobs[v.job].blip.scale or 1.0), (v.customcolor and v.customcolor or Config.Jobs[v.job].blip.color), v.name, v.dead)
                            end 
                        end 
                    end 
                else 
                    if activeBlips[k] then 
                        RemoveBlip(activeBlips[k].blip)
                    end 
                    activeBlips[k] = {
                        blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z),
                        car = v.veh,
                        dead = v.dead,
                        long = true  
                    }
                    if v.veh then 
                        activeBlips[k].car = v.veh 
                        local vsprite, vscale, vcolor = WrapVehicleBlip(v.veh, v.job)
                        SetUpBlip(activeBlips[k].blip, vsprite, vscale, (v.customcolor and v.customcolor or vcolor), v.name, v.dead)
                    else 
                        activeBlips[k].car = v.veh 
                        SetUpBlip(activeBlips[k].blip, Config.Jobs[v.job].blip.sprite, (Config.Jobs[v.job].blip.scale or 1.0), (v.customcolor and v.customcolor or Config.Jobs[v.job].blip.color), v.name, v.dead)
                    end 
                end 
            end
        end 

        --[[for i = 0, 256 do
            if NetworkIsPlayerActive(i) and i ~= mycid then
                local k = GetPlayerServerId(i)
                local v = trackerOn[k]
                if v and Config.Jobs[ESX.PlayerData.job.name].canSee[v] then 
                    local name = GetPlayerName(i)
                    local ped = GetPlayerPed(i)
                    local veh = GetVehiclePedIsIn(ped)
                    activeBlips[k] = {
                        blip = AddBlipForEntity(ped),
                        car = false 
                    }
                    if veh and veh ~= 0 then 
                        activeBlips[k].car = true 
                        SetUpBlip(activeBlips[k].blip, Config.Jobs[v].vehBlip.default.sprite, (Config.Jobs[v].vehBlip.default.scale or 1.0), Config.Jobs[v].vehBlip.default.color, name)
                    else 
                        SetUpBlip(activeBlips[k].blip, Config.Jobs[v].blip.sprite, (Config.Jobs[v].blip.scale or 1.0), Config.Jobs[v].blip.color, name)
                    end 
                end 
            end
        end]]
    end 
end)

function SetUpBlip(blip, sprite, scale, color, name, dead)
    SetBlipAsShortRange(blip, false)
    SetBlipSprite(blip, (dead and 274 or sprite))
	SetBlipDisplay(blip, 2)
	SetBlipScale(blip, scale)
	SetBlipColour(blip, color)
    SetBlipFlashes(blip, false)
    SetBlipShowCone(blip, true)
    SetBlipCategory(blip, 7)
	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
	EndTextCommandSetBlipName(blip)
end 

if GetResourceState('ox_inventory') ~= "missing" then 
    AddEventHandler("esx:removeInventoryItem", function(name, count)
        if name == Config.Item then 
            if count < 1 then 
                TriggerServerEvent("bc_gps:removedOxInv")
            end 
        end 
    end)
end 

BlipToRgb = {
	["0"] = {254, 254, 254}, -- white
	["1"] = {224, 50, 50}, -- red
	["2"] = {113, 203, 113}, -- green
	["3"] = {93, 182, 229}, -- blue
	["4"] = {254, 254, 254}, -- white
	["5"] = {238, 198, 78}, -- yellow
	["6"] = {194, 80, 80}, -- light red
	["7"] = {156, 110, 175}, -- violet
	["8"] = {254, 122, 195}, -- pink
	["9"] = {245, 157, 121}, -- light orange
	["10"] = {177, 143, 131}, -- light brown
	["11"] = {141, 206, 167}, -- light green
	["12"] = {112, 168, 174}, -- light blue
	["13"] = {211, 209, 231}, -- light purple
	["14"] = {143, 126, 152}, -- dark purple
	["15"] = {106, 196, 191}, -- cyan
	["16"] = {213, 195, 152}, -- light yellow
	["17"] = {234, 142, 80}, -- orange
	["18"] = {151, 202, 233}, -- light blue
	["19"] = {178, 98, 135}, -- dark pink
	["20"] = {143, 141, 121}, -- dark yellow
	["21"] = {166, 117, 94}, -- dark orange
	["22"] = {175, 168, 168}, -- light gray
	["23"] = {231, 141, 154}, -- light pink
	["24"] = {187, 214, 91}, -- lemon green
	["25"] = {12, 123, 86}, -- forest green
	["26"] = {122, 195, 254}, -- electric blue
	["27"] = {171, 60, 230}, -- bright purple
	["28"] = {205, 168, 12}, -- dark yellow
	["29"] = {69, 97, 171}, -- dark blue
	["30"] = {41, 165, 184}, -- dark cyan
	["31"] = {184, 155, 123}, -- light brown
	["32"] = {200, 224, 254}, -- light blue
	["33"] = {240, 240, 150}, -- light yellow
	["34"] = {237, 140, 161}, -- light pink
	["35"] = {249, 138, 138}, -- beige -- from here it's wrong 36 is actually: beige
	["36"] = {251, 238, 165}, -- white
	["37"] = {254, 254, 254}, -- blue
	["38"] = {44, 109, 184}, -- light gray
	["39"] = {154, 154, 154}, -- dark gray
	["40"] = {76, 76, 76}, -- pink red
	["41"] = {242, 157, 157}, -- blue
	["42"] = {108, 183, 214}, -- light green
	["43"] = {175, 237, 174}, -- light orange
	["44"] = {255, 167, 95}, -- white
	["45"] = {241, 241, 241}, -- gold
	["46"] = {236, 240, 41}, -- orange
	["47"] = {255, 154, 24}, -- brilliant rose
	["48"] = {246, 68, 165}, -- red
	["49"] = {224, 58, 58}, -- blue
	["50"] = {138, 109, 227}, -- medium purple
	["51"] = {255, 139, 92}, -- salmon
	["52"] = {65, 108, 65}, -- dark green
	["53"] = {179, 221, 243}, -- blizzard blue
	["54"] = {58, 100, 121}, -- oracle blue
	["55"] = {160, 160, 160}, -- silver
	["56"] = {132, 114, 50}, -- brown
	["57"] = {101, 185, 231}, -- blue
	["58"] = {75, 65, 117}, -- east bay
	["59"] = {225, 59, 59}, -- red
	["60"] = {240, 203, 88}, -- yellow orange
	["61"] = {205, 63, 152}, -- mulberry pink
	["62"] = {207, 207, 207}, -- alto gray
	["63"] = {39, 106, 159}, -- jerry bean blue
	["64"] = {216, 123, 27}, -- dark orange
	["65"] = {142, 131, 147}, -- mamba
	["66"] = {240, 203, 87}, -- yellow orange
	["67"] = {101, 185, 231}, -- blue
	["68"] = {101, 185, 231}, -- blue
	["69"] = {121, 205, 121}, -- green
	["70"] = {239, 202, 87}, -- yellow orange
	["71"] = {239, 202, 87}, -- yellow orange
	["72"] = {61, 61, 61}, -- transparent black
	["73"] = {239, 202, 87}, -- yellow orange
	["74"] = {101, 185, 231}, -- blue
	["75"] = {224, 50, 50}, -- red
	["76"] = {120, 35, 35}, -- deep red
	["77"] = {101, 185, 231}, -- blue
	["78"] = {58, 100, 121}, -- oracle blue
	["79"] = {224, 50, 50}, -- red
	["80"] = {101, 185, 231}, -- transparent blue
	["81"] = {242, 164, 12}, -- orange
	["82"] = {164, 204, 170}, -- light green
	["83"] = {168, 84, 242}, -- purple
	["84"] = {101, 185, 231}, -- blue
	["85"] = {61, 61, 61}, -- transparent black
}

function GetRgbFromBlipColor(id)
	for k, v in pairs(BlipToRgb) do
		if tonumber(k) == id then
			return v
		end
	end
end


RegisterCommand("gpsszin", function()
    local opt = {}

    for i=1, 84 do 
        local rgb = GetRgbFromBlipColor(i)
        opt[#opt+1] = {
            title = "Legyen ilyen!",
            icon = "fa fa-circle",
            iconColor = "rgb("..rgb[1]..","..rgb[2]..","..rgb[3]..")",
            onSelect = function()
                --print("setcustomcolor", i)
                customcolor = i
                TriggerEvent("bc_gps:setmycolor", i)
                TriggerServerEvent("bc_gps:setmyColor", i)
            end 
        }
    end 

    lib.registerContext({
        id = 'gpscolor',
        title = 'GPS Szine',
        menu = 'gpscolorsome_menu',
        options = opt
      })
     
      lib.showContext('gpscolor')
    
end)

RegisterNetEvent("bc_gps:psuse", function()


    lib.registerContext({
        id = 'gpsszovi',
        title = 'GPS Szövi',
        menu = 'gpscolorsome_menu',
        options = {
            {
                title = "Szövetségkötés",
                icon = "fa fa-circle",
                onSelect = function()
                    local closestPlayer, playerDistance = ESX.Game.GetClosestPlayer() -- GetPlayerServerId(closestPlayer)
                    if closestPlayer == -1 or playerDistance > 3.0 then
                        return ESX.ShowNotification("Nincs senki a közeledben!")
                    end 
                    local sid = GetPlayerServerId(closestPlayer)
                    TriggerServerEvent("bc_gps:partnership", sid)
                end 
            },
            {
                title = "Szövetség felbontása",
                icon = "fa fa-circle",
                onSelect = function()
                    TriggerServerEvent("bc_gps:partnerend")
                end 
            },
        }
      })
     
      lib.showContext('gpsszovi')

    
end)


lib.callback.register('bc_gps:confpartnership', function(faction)
	local alert = lib.alertDialog({
        header = 'Szövetség',
        content = 'Szövetséget szeretnél kötni a(z) '..faction..'-val/vel 30 napra 100M$ ért?',
        centered = true,
        cancel = true
    })
    if alert == "confirm" then 
        return true 
    end 
    return false 
end)


lib.callback.register('bc_gps:breakpartnership', function(faction, endt)
	local alert = lib.alertDialog({
        header = 'Szövetség',
        content = 'Szeretnéd bontani a szövetséged a(z) '..faction..'-val/vel 100M$ ért? (ha nem bontod lejárat: '..endt..')',
        centered = true,
        cancel = true
    })
    if alert == "confirm" then 
        return true 
    end 
    return false 
end)

--[[local input = lib.inputDialog('Add meg a bliped szinet', {
        {type = 'color', label = 'Szin', default = '#eb4034'},
    })
    if not input or not input[1] then return end 
    print("color", input[1])
    local inpcolor = input[1]:sub(2)
    inpcolor = string.upper(inpcolor)
    TriggerServerEvent("bc_gps:setmyColor", inpcolor)
    customcolor = tonumber(inpcolor, 16)]]