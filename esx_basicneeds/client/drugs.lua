local Drugs = { -- Create you own drugs
    
    ['weed_lemonhaze'] = {

    	Label = 'Lemon Haze',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 15, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'pajzs',
            'drunkWalk'
    	}
        
    },
    ['ecstasy'] = {

    	Label = 'Ecstasy',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 15, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk',
            'runningSpeedIncrease',
            'pajzs'
    	}
        
    },
    ['varazsfagyi'] = {

    	Label = 'Varázs Fagyi',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 15, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'pajzs'
    	}
        
    },
    ['varazsgomba'] = {

    	Label = 'Varázs Gomba',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 15, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'healthRegen'
    	}
        
    },
    ['gatya'] = {

    	Label = 'Gatya',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 15, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'runningSpeedIncrease',
            'healthRegen',
            'pajzs',
            'drunkWalk'
    	}
        
    },
    ['lilacsoda'] = {

    	Label = 'LilaCsoda',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 15, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'pajzs',
            'drunkWalk'
    	}
        
    },
    ['gomba'] = {

    	Label = 'Gomba',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 15, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'pajzs',
            'drunkWalk'
    	}
        
    },
    ['weed_cookie'] = {

    	Label = 'Füves brownie',
    	Animation = 'eat', -- Animations: blunt, sniff, pill
        Time = 15, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
    	}
        
    },
    ['cocaine'] = {

        Label = 'Cocaine',
        Animation = 'sniff', -- Animations: blunt, sniff, pill
        Time = 25, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'runningSpeedIncrease',
            'healthRegen',
            'fogEffect',
            'psycoWalk',
            'pajzs'
        }
        
    },
    ['meth'] = {

        Label = 'Meth',
        Animation = 'sniff', -- Animations: blunt, sniff, pill
        Time = 25, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'runningSpeedIncrease',
            'healthRegen',
            'fogEffect',
            'psycoWalk',
            'kicsipajzs'
        }
        
    },
    ['opium'] = {

        Label = 'Opium',
        Animation = 'sniff', -- Animations: blunt, sniff, pill
        Time = 25, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'healthRegen',
            'fogEffect',
            'psycoWalk',
        }
        
    },
    ['adr'] = {

        Label = 'Adrenalin injekció',
        Animation = 'sniff', -- Animations: blunt, sniff, pill
        Time = 25, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'runningSpeedIncrease',
            'fogEffect',
            'psycoWalk',
            'healthRegen',
            'kicsipajzs'
        }
        
    },
    ['speed'] = {

        Label = 'Speed',
        Animation = 'sniff', -- Animations: blunt, sniff, pill
        Time = 25, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'runningSpeedIncrease',
            'fogEffect',
            'psycoWalk',
        }
        
    },
    ['lsd'] = {

        Label = 'lsd',
        Animation = 'sniff', -- Animations: blunt, sniff, pill
        Time = 25, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'runningSpeedIncrease',
            'healthRegen',
            'whiteoutEffect',
			'focusEffect',
            'psycoWalk',
            'pajzs'
        }
        
    },
    ['regal'] = {

        Label = 'Chivas Regal',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 80, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['henessy'] = {

        Label = 'Henessy',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 120, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['mojito'] = {

        Label = 'Mojito',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 120, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['mouldybread'] = {

        Label = 'mouldybread',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 120, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
        }
        
    },
    ['champagne'] = {

        Label = 'Pezsgő',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 40, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['beer'] = {

        Label = 'Sör',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 30, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['palinka'] = {

        Label = 'Palinka',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 30, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['jager'] = {

        Label = 'Sör',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 30, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['torleypezsgo'] = {

        Label = 'Törley',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 30, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['bor'] = {

        Label = 'Sör',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 30, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['soproni'] = {

        Label = 'Sör',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 30, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },
    ['aranyaszok'] = {

        Label = 'Sör',
        Animation = 'drink', -- Animations: blunt, sniff, pill
        Time = 30, -- Time is added on top of 30 seconds
        Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
            'intenseEffect',
            'drunkWalk'
        }
        
    },

    ['felejto_injekcio'] = {

    	Label = 'Felejtő injekció',
    	Animation = 'blunt', -- Animations: blunt, sniff, pill
        Time = 60, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
    	}
        
    },


    ['fajdalomcsillapito'] = {

    	Label = 'Fájdalom csillapító',
    	Animation = 'pill', -- Animations: blunt, sniff, pill
        Time = 60, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
        "healthRegen",
        "infinateStamina",
        "confusionEffect",
        "psycoWalk"
    	}
        
    },
    ['lazcsillapito'] = {

    	Label = 'Láz csillapító',
    	Animation = 'pill', -- Animations: blunt, sniff, pill
        Time = 60, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
        "healthRegen",
        "confusionEffect",
        "fogEffect"
    	}
        
    },
    ['gyulladascsokkento'] = {

    	Label = 'Gyulladás csökkentő',
    	Animation = 'pill', -- Animations: blunt, sniff, pill
        Time = 60, -- Time is added on top of 30 seconds
    	Effects = { -- Effects: runningSpeedIncrease, infinateStamina, moreStrength, healthRegen, foodRegen, drunkWalk, psycoWalk, outOfBody, cameraShake, fogEffect, confusionEffect, whiteoutEffect, intenseEffect, focusEffect
        "healthRegen",
        "moreStrength",
        "confusionEffect"
    	}
        
    },
}

local shown = false
local interactive = false
local action = false
local processing = false

local infinateStamina = false
local healthRegen = false
local foodRegen = false
local cameraShake = false
local strength = false
local outOfBody = false
local pajzs = false
local kicsipajzs = false

Citizen.CreateThread(
    function()
        while true do
            if outOfBody then
                local pid = PlayerId()
                ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 3.2)
                Citizen.Wait(10000)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if cameraShake then
                local pid = PlayerId()
                ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 0.2)
                Citizen.Wait(1100)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if infinateStamina then
                local pid = PlayerId()
                RestorePlayerStamina(pid, 1.0)
                Citizen.Wait(0)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            if strength then
                local pid = PlayerId()
                local ped = PlayerPedId()
                if GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_UNARMED") then
                    SetPlayerMeleeWeaponDamageModifier(pid, 2.0)
                end
                Citizen.Wait(5)
            else
                Citizen.Wait(1000)
            end
        end
    end
)

local usingmed = false 
local plyState = LocalPlayer.state
plyState:set('usingMed', false, false)
AddStateBagChangeHandler('usingMed', stateId, function(_, _, value)
	usingmed = value
end)

local lastused = 0
RegisterNetEvent("core_drugs:drug")
AddEventHandler(
    "core_drugs:drug",
    function(type)
        if usingmed then 
            TriggerEvent('esx:showNotification', "Ezt jelenleg nem használhatod!")
            return 
        end 
        if lastused + 1000*10 > GetGameTimer() then 
            TriggerEvent('esx:showNotification', "Várj egy kicsit ne spammeld!")
            return 
        end 
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            TriggerEvent('esx:showNotification', "Ezt autóba nem tudod használni!")
        else 
            lastused = GetGameTimer()
            TriggerServerEvent("core_drugs:removeItem", type, 1)
            drug(type)
        end
    end
)

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(500)
    end
end

function drug(type)
    local info = Drugs[type]
    local ped = PlayerPedId()

    if not info then return end 

    Citizen.CreateThread(
        function()
            if info.Animation == "pill" then
                loadAnimDict("mp_suicide")
                TaskPlayAnim(ped, "mp_suicide", "pill", 3.0, 3.0, 2000, 48, 0, false, false, false)
            elseif info.Animation == "sniff" then
                loadAnimDict("anim@mp_player_intcelebrationmale@face_palm")
                TaskPlayAnim(
                    ped,
                    "anim@mp_player_intcelebrationmale@face_palm",
                    "face_palm",
                    3.0,
                    3.0,
                    3000,
                    48,
                    0,
                    false,
                    false,
                    false
                )
            elseif info.Animation == "blunt" then
                TaskStartScenarioInPlace(ped, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(4500)
                ClearPedTasks(ped)
            elseif info.Animation == "drink" then
                TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRINKING", 0, 1)
                Citizen.Wait(4500)
                ClearPedTasks(ped)
            elseif info.Animation == "eat" then
                Citizen.Wait(4500)
                ClearPedTasks(ped)
            end


            for _, effect in ipairs(info.Effects) do
                addEffect(effect, true)
            end

            LocalPlayer.state.usingDrugs = true

            Citizen.Wait(31000 + (info.Time * 1000))

            LocalPlayer.state.usingDrugs = false

            for _, effect in ipairs(info.Effects) do
                addEffect(effect, false)
            end
        end
    )
end

function addEffect(effect, status)
    local ped = PlayerPedId()

    if effect == "runningSpeedIncrease" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    SetPedMoveRateOverride(PlayerId(), 10.0)
                    SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
                    Wait(90000)
                    SetPedMoveRateOverride(PlayerId(), 0.0)
                    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                end
            )
        else
            --SetPedMoveRateOverride(PlayerId(), 0.0)
            --SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end
    elseif effect == "infinateStamina" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    infinateStamina = true
                end
            )
        else
            infinateStamina = false
        end
    elseif effect == "moreStrength" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    strength = true
                end
            )
        else
            strength = false
        end
    elseif effect == "healthRegen" then
        if status then
            --[[Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    healthRegen = true
                end
            )]]
                SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId())+30)
            SetPlayerHealthRechargeMultiplier(PlayerId(), 1.3)
        else
            --healthRegen = false
            SetPlayerHealthRechargeMultiplier(PlayerId(), 1.0)
        end
    elseif effect == "foodRegen" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    foodRegen = true
                end
            )
        else
            foodRegen = false
        end
    elseif effect == "pajzs" then
        if status then
            SetPedArmour(PlayerPedId(),100)
        end
    elseif effect == "kicsipajzs" then
        if status then
            SetPedArmour(PlayerPedId(),50)
        end
    elseif effect == "drunkWalk" then
        if status then
            Citizen.CreateThread(
                function()
                    RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                    while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do
                        Citizen.Wait(0)
                    end

                    Citizen.Wait(30000)
                    SetPedMovementClipset(ped, "MOVE_M@DRUNK@VERYDRUNK", true)
                end
            )
        else
            ResetPedMovementClipset(ped, 0)
        end
    elseif effect == "psycoWalk" then
        if status then
            Citizen.CreateThread(
                function()
                    RequestAnimSet("MOVE_M@QUICK")
                    while not HasAnimSetLoaded("MOVE_M@QUICK") do
                        Citizen.Wait(0)
                    end

                    Citizen.Wait(30000)
                    SetPedMovementClipset(ped, "MOVE_M@QUICK", true)
                end
            )
        else
            ResetPedMovementClipset(ped, 0)
        end
    elseif effect == "outOfBody" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    outOfBody = true
                end
            )
        else
            ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
            outOfBody = false
        end
    elseif effect == "cameraShake" then
        if status then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(30000)
                    cameraShake = true
                end
            )
        else
            ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 0.0)
            cameraShake = false
        end
    elseif effect == "fogEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingIn", 30000, true)
                    Citizen.Wait(30000)

                    AnimpostfxPlay("DrugsMichaelAliensFightIn", 100000, true)
                end
            )
        else
            Citizen.CreateThread(
                function()
                    AnimpostfxStop("DrugsDrivingIn")
                    AnimpostfxPlay("DrugsDrivingOut", 20000, true)
                    AnimpostfxStop("DrugsMichaelAliensFightIn")
                    Citizen.Wait(20000)
                    AnimpostfxStop("DrugsDrivingOut")
                end
            )
        end
    elseif effect == "confusionEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("Rampage", 30000, true)
                    Citizen.Wait(30000)
                    AnimpostfxPlay("Dont_tazeme_bro", 30000, true)
                end
            )
        else
            Citizen.CreateThread(
                function()
                    AnimpostfxStop("Rampage")
                    AnimpostfxStop("Dont_tazeme_bro")
                    AnimpostfxPlay("RampageOut", 20000, true)
                    Citizen.Wait(20000)
                    AnimpostfxStop("RampageOut")
                end
            )
        end
    elseif effect == "whiteoutEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingIn", 30000, true)
                    Citizen.Wait(30000)
                    AnimpostfxPlay("PeyoteIn", 100000, true)
                end
            )
        else
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingOut", 20000, true)
                    AnimpostfxPlay("PeyoteOut", 20000, true)
                    AnimpostfxStop("PeyoteIn")
                    AnimpostfxStop("DrugsDrivingIn")
                    Citizen.Wait(20000)
                    AnimpostfxStop("DrugsDrivingOut")
                    AnimpostfxStop("PeyoteOut")
                end
            )
        end
    elseif effect == "intenseEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingIn", 30000, true)
                    Citizen.Wait(30000)
                    AnimpostfxPlay("DMT_flight_intro", 100000, true)
                end
            )
        else
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("DrugsDrivingOut", 20000, true)
                    AnimpostfxStop("DMT_flight_intro")
                    AnimpostfxStop("DrugsDrivingIn")
                    Citizen.Wait(20000)
                    AnimpostfxStop("DrugsDrivingOut")
                end
            )
        end
    elseif effect == "focusEffect" then
        if status then
            Citizen.CreateThread(
                function()
                    AnimpostfxPlay("FocusIn", 100000, true)
                end
            )
        else
            AnimpostfxStop("FocusIn")
            AnimpostfxPlay("FocusOut", 10000, false)
        end
    end
end