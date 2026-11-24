-- Scoring and timing shared by the Grand Dojo duel formats.
local Series = {}

local opening = {
    casual = table.freeze({intro = 10, duration = 60}),
    series = table.freeze({intro = 10, duration = 45}),
}
local nextTiming = table.freeze({intro = 3, duration = 45})
opening.ranked = opening.series

function Series.supports(format)
    return type(format) == "string" and opening[format] ~= nil
end

function Series.new(format)
    assert(Series.supports(format), "Unknown duel format")
    return {format = format, roundIndex = 1, maxRounds = if format == "casual" then 1 else 3, wins = {0, 0}}
end

function Series.timing(series)
    return if series.roundIndex == 1 then opening[series.format] else nextTiming
end

function Series.record(series, roundResult)
    if series.roundResult then
        return series.result
    end
    series.roundResult = roundResult
    for side, result in roundResult do
        if result == "win" then
            series.wins[side] += 1
        end
    end
    local first, second = series.wins[1], series.wins[2]
    if series.roundIndex == series.maxRounds or first == 2 or second == 2 then
        series.result = if first == second then {"draw", "draw"}
            elseif first > second then {"win", "loss"} else {"loss", "win"}
    end
    return series.result
end

function Series.nextRound(series)
    if not series.roundResult or series.result then
        return nil
    end
    series.roundIndex += 1
    series.roundResult = nil
    return series.roundIndex
end

return Series
