Locales = {}

function Translate(str, ...)  -- Translate string
	if Locales[Config.Locale] then
		if Locales[Config.Locale][str] then
			return string.format(Locales[Config.Locale][str], ...)
		elseif Config.Locale ~= 'en' and Locales['en'] and Locales['en'][str] then
			return string.format(Locales['en'][str], ...)
		else
			return 'Wrong locale config ' .. str .. ' translation does not exist in '..Config.Locale..' locales'
		end
	elseif Config.Locale ~= 'en' and Locales['en'] and Locales['en'][str] then
			return string.format(Locales['en'][str], ...)
	else
		return 'Wrong locale config ' .. Config.Locale .. ' locale does not exist'
	end
end