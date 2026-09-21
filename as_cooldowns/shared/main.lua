-- Credit: https://stackoverflow.com/a/45376848
function CooldownToTable(cooldown)
	local isNegative = cooldown < 0 and true or false
	cooldown = isNegative and math.abs(cooldown) or cooldown
	local days = math.floor(cooldown/86400)
	local hours = math.floor((cooldown%86400)/3600)
	local minutes = math.floor((cooldown%3600)/60)
	local seconds = math.floor(cooldown%60)
	return { isNegative = isNegative, days = days, hours = hours, minutes = minutes, seconds = seconds }
end

function CooldownToString(cooldown)
	local tab = CooldownToTable(cooldown)
	return string.format("%s%d:%02d:%02d:%02d", tab.isNegative and '-' or '', tab.days, tab.hours, tab.minutes, tab.seconds)
end


local jobgroups = {
	["banda"] = {
		"balen",
		"bloods",
		"conte",
		"crips",
		"doa",
		"groove",
		"loscuba",
		"lostmc",
		"kingsman",
		"mechanic",
		"pollos",
		"vagos",
		"vagoos",
		"lostmc",
		"farm",
		"teszt",
		"sonsofanarchy",
		"peakybb",
		"gokart"
	},
	["maffia"] = {
		"bahamas",
		"szeged",
		"army",
		"asian",
		"bratva",
		"dd",
		"gomorra",
		"gorilla",
		"khc",
		"kingston",
		"mob",
		"ms",
		"ms13",
		"offluxduty",
		"remmo",
		"sonsofanarchy",
		"ssouls",
		"russian",
		"soa",
		"ujfrakcio",
		"ujfrakciodawe3",
		"blackmamba",
		"gentle",
		"gym",
		"farm",
		"pearlsillegal",
		"diavoltelepoff",
		"conte",
		"rh"
	}
}

exports("AuthJob", function(job1, job2)
	if job1 == job2 then 
		return true 
	end 
	if not jobgroups[job2] then 
		return false 
	end 
	for _, jj in ipairs(jobgroups[job2]) do 
		if job1 == jj then 
			return true 
		end 
	end 
	return false 
end)