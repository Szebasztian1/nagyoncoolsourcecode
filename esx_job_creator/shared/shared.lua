locales = locales or {}

-- Returns random element from a table of objects that have "chances" property
function getRandomElementFromTable(fullTable)
    local count = 0

    local keyIntervals = {}

    for k, data in pairs(fullTable) do
        local startingCount = count
        count = count + data.chances

        table.insert(keyIntervals, {
            min = startingCount,
            max = count,
            key = k
        })
    end

    local randomNumber = math.random(0, count)

    for k, interval in pairs(keyIntervals) do
        if (randomNumber >= interval.min and randomNumber <= interval.max) then
            return fullTable[interval.key]
        end
    end
end

function getLocalizedText(text, ...)
    local message = nil

    if (locales[config.locale][text]) then
        message = locales[config.locale][text]
    else
        message = locales["en"][text]
    end

    if (message) then
        local _, argumentsCount = string.gsub(message, "%%.", "")

        -- If arguments to format in the string are the correct number
        if (argumentsCount == #{ ... }) then
            return string.format(message, ...)
        else
            print("^1Argument missing for ^3'" .. text .. "'^1 translation, you should retranslate that string^7")
            return text
        end
    else
        print("^1Translation missing: ^3" .. text .. "^7")
        return text
    end
end
