local Bell = {}

local BEAT_LENGTHS = {1.89, 1.80, 1.72, 1.69, 1.57, 1.50, 1.43, 1.36, 1.29, 1.24}
local LEAD_IN = 2.51
local CENTER = 0.68
local PERFECT_MARGIN = 0.044
local BEATS_FOR_SILVER = 4
local BEATS_FOR_GOLD = 8
local PERFECT_FOR_GOLD = 4
local BEAT_OFFSETS = {LEAD_IN}

for index, length in ipairs(BEAT_LENGTHS) do
    BEAT_OFFSETS[index + 1] = BEAT_OFFSETS[index] + length
end

Bell.Duration = 18
Bell.BeatCount = #BEAT_LENGTHS
Bell.Keepsake = "Juniper Bell Pin"

function Bell.new(startedAt)
    return {startedAt = startedAt, score = 0, bonus = 0, lastBeat = 0}
end

-- The client draws this window from Roblox's synchronized server clock.
-- The server calculates the same window using its own clock when it receives a strike.
function Bell.windowAt(startedAt, now)
    local elapsed = now - startedAt
    if elapsed >= Bell.Duration then
        return nil
    end

    for index, length in ipairs(BEAT_LENGTHS) do
        if elapsed >= BEAT_OFFSETS[index] and elapsed < BEAT_OFFSETS[index + 1] then
            local progress = (elapsed - BEAT_OFFSETS[index]) / length
            local width = 0.25 - (index - 1) * 0.012
            return index, progress, CENTER, width
        end
    end

    return nil
end

function Bell.strike(round, now, expectedBeat)
    local beat, progress, center, width = Bell.windowAt(round.startedAt, now)
    if not beat or beat <= round.lastBeat or (expectedBeat ~= nil and beat ~= expectedBeat) then
        return nil
    end

    round.lastBeat = beat
    local offset = progress - center
    if math.abs(offset) > width * 0.5 then
        round.feedback = if offset < 0 then "early" else "late"
    else
        round.score += 1
        local perfect = math.abs(offset) < PERFECT_MARGIN
        if perfect then
            round.bonus += 1
        end
        round.feedback = if perfect then "perfect" else "good"
    end
    return round.feedback
end

function Bell.rank(score, perfect)
    if score >= BEATS_FOR_GOLD and perfect >= PERFECT_FOR_GOLD then
        return "Gold"
    end
    return if score >= BEATS_FOR_SILVER then "Silver" else "Try again"
end

return table.freeze(Bell)
