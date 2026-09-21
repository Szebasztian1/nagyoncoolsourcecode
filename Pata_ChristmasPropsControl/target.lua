
if string.lower(Targetting) == "ox_target" then
	-- affError("Targetting set on QB-Target")
	function targetAddModel(model,option)
		local targetID = 0
		targetID = exports.ox_target:addModel(model,option)
		return targetID
	end

elseif string.lower(Targetting) == "qb_target" then
	-- affError("Targetting set on QB-Target")
	function targetAddModel(model,option)
		-- aff("option : "..tostring(option))
		local targetID = 0
		local options = {}
		for k,v in pairs(option) do
			-- aff("k : "..tostring(k).." v: "..tostring(v.event))
			options[k] = v
			if v.serverEvent then
				options[k].type = "server"
				options[k].event = v.serverEvent 
			else
				options[k].type = "client"
				options[k].event = v.event 
			end
		end
		-- aff("target model : "..tostring(model))
		targetID = exports['qb-target']:AddTargetModel({model},{ -- The specified entity number
			options = options,
			distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
		  })
		return targetID
	end
else
	-- aff("^2 Error no targetting system defined !!!! you have to put : ox_target or qb_target in the Targetting field of the config file !^7")
end