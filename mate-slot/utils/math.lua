MathUtils = {}

function MathUtils.WeightedRandomSymbol()
    local roll = math.random() * Config.TotalWeight

    for _, sym in ipairs(Config.Symbols) do
        roll = roll - sym.weight
        if roll <= 0 then
            return sym
        end
    end

    return Config.Symbols[#Config.Symbols]
end

function MathUtils.GetPayoutMultiplier(symbolId, matchCount)
    local sym = Config.SymbolMap[symbolId]
    if not sym then return 0 end

    local raw = sym.payouts[matchCount] or 0
    return raw * Config.Economy.payoutNormFactor * Config.Economy.globalPayoutMultiplier
end

function MathUtils.GetWinTier(winAmount, betAmount)
    if betAmount <= 0 then return "normal" end

    local ratio = winAmount / betAmount

    if ratio >= Config.WinTiers.jackpot then return "jackpot" end
    if ratio >= Config.WinTiers.megaWin then return "megaWin" end
    if ratio >= Config.WinTiers.bigWin then return "bigWin" end

    return "normal"
end

function MathUtils.Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function MathUtils.Round(value)
    return math.floor(value + 0.5)
end
