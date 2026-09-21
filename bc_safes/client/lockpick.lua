local lockpickamount = 0
local locks = {}
local activelock = 1
local activepick = 0
local activerotation = 0
AddTextEntry('lockpicking_help', '~INPUT_MOVE_DOWN_ONLY~ a befejezéshez ~INPUT_MOVE_UP_ONLY~ a zár töréséhez ~INPUT_MOVE_LEFT_ONLY~/~INPUT_MOVE_RIGHT_ONLY~ a jobbra/balra forgatáshoz')
function LockPick(num)
    UpdateLockPicks() 
    lockpicking = true
    locks = {}
    for i = 1, num, 1 do 
        locks[i] = true
    end 
    activelock = 1
    activepick = math.random(1, 100)
    activerotation = 0
    local aspectRatio = GetAspectRatio(true)
    RequestStreamedTextureDict("MPSafeCracking",false)
	RequestAmbientAudioBank("SAFE_CRACK",false)

    RequestAnimDict("mini@safe_cracking")
	while not HasAnimDictLoaded("mini@safe_cracking") do
		Wait(10)
	end
	TaskPlayAnim(PlayerPedId(),"mini@safe_cracking","idle_base",3.0,3.0,-1,1,0,0,0,0)

    while lockpicking do 
        Wait(0)

        DisplayHelpTextThisFrame('lockpicking_help')

        DrawSprite("MPSafeCracking","Dial_BG",0.48,0.3,0.3,aspectRatio*0.3,0,255,255,255,255)
	    DrawSprite("MPSafeCracking","Dial",0.48,0.3,0.3*0.5,aspectRatio*0.3*0.5,activerotation,255,255,255,255)

	    local yPos = 0.5 - ((#locks * 0.075) / 2)
        for _, status in pairs(locks) do 
            local lockString
            if status then
                lockString = "lock_closed"
            else
                lockString = "lock_open"
            end

            DrawSprite("MPSafeCracking",lockString,0.6,yPos,0.025,aspectRatio*0.015,0,231,194,81,255)
            yPos = yPos + 0.05
        end 

        if IsEntityDead(PlayerPedId()) then
            lockpicking = false 
            ClearPedTasksImmediately(PlayerPedId())
			return false
        end 

        if IsControlJustPressed(0,33) then
            lockpicking = false 
            ClearPedTasksImmediately(PlayerPedId())
			return false
		end

		if IsControlJustPressed(0,32) then
			if (not Config.LockPickItem) or lockpickamount > 0 then 
                if GetCurrentSafeDialNumber(activerotation) == activepick then 
                    locks[activelock] = false
                    activelock = activelock + 1
                    activepick = math.random(1, 100)
                    activerotation = 0
                    TriggerServerEvent("bc_safes:removeLockPick")
                    UpdateLockPicks() 
                    PlaySoundFrontend(0,"tumbler_reset","SAFE_CRACK_SOUNDSET",true)
                    if activelock > num then 
                        lockpicking = false 
                        ClearPedTasksImmediately(PlayerPedId())
                        PlaySoundFrontend(0,"safe_door_open","SAFE_CRACK_SOUNDSET",true)
                        return true
                    end 
                else 
                    TriggerServerEvent("bc_safes:removeLockPick")
                    PlaySoundFrontend(0,"tumbler_pin_fall_final","SAFE_CRACK_SOUNDSET",true)
                    UpdateLockPicks() 
                end 
            else 
                lockpicking = false 
                ClearPedTasksImmediately(PlayerPedId())
                return false 
            end 
 		end

        if IsControlJustPressed(0,34) then
            RotateSafeDial(true)
        elseif IsControlJustPressed(0,35) then
            RotateSafeDial(false)
        end 
    end 

    ClearPedTasksImmediately(PlayerPedId())
    return false 
end 

function RotateSafeDial(rotate)
    local multiplier
    if rotate then 
        multiplier = 1
    else 
        multiplier = -1
    end 

    local change = 3.6*multiplier
    activerotation = activerotation + change
    if activerotation > 359 then 
        activerotation = 0
    elseif activerotation < 0 then 
        activerotation = 359
    end 
	PlaySoundFrontend(0,"TUMBLER_TURN","SAFE_CRACK_SOUNDSET",true)

    if GetCurrentSafeDialNumber(activerotation) == activepick then 
        PlaySoundFrontend(0,"TUMBLER_PIN_FALL","SAFE_CRACK_SOUNDSET",true)
    end 
end

function UpdateLockPicks() 
    if Config.LockPickItem then 
        ESX.TriggerServerCallback("bc_safes:getLockPicks", function(count) 
            lockpickamount = count
            if lockpickamount < 1 then 
                lockpicking = false 
                ESX.ShowNotification("Elfogyott a zártörőd!")
            end 
        end)
    end 
end 

function GetCurrentSafeDialNumber(angle)
	local number = math.floor(angle/3.6)

	return math.abs(number)
end