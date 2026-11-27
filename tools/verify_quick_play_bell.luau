local Bell = require("../roblox/grand-dojo/QuickPlayBell")

local START = 1000
local beatLengths = {1.89, 1.80, 1.72, 1.69, 1.57, 1.50, 1.43, 1.36, 1.29, 1.24}

local function timeAtBeat(beat, progress)
    local elapsed = 2.51
    for index = 1, beat - 1 do
        elapsed += beatLengths[index]
    end
    return START + elapsed + beatLengths[beat] * progress
end

assert(Bell.Duration == 18 and Bell.BeatCount == 10)
assert(Bell.windowAt(START, START - 1) == nil)
assert(Bell.windowAt(START, START + 2.50) == nil)
assert(Bell.windowAt(START, START + 18) == nil)

local gold = Bell.new(START)
for beat = 1, Bell.BeatCount do
    local time = timeAtBeat(beat, .68)
    local index, _, _, width = Bell.windowAt(START, time)
    assert(index == beat)
    assert(math.abs(width - (0.25 - (beat - 1) * 0.012)) < 1e-6)
    assert(Bell.strike(gold, time) == "perfect")
    assert(Bell.strike(gold, time + .01) == nil)
end
assert(gold.score == 10 and gold.bonus == 10)
assert(Bell.rank(gold.score, gold.bonus) == "Gold")
assert(Bell.strike(gold, timeAtBeat(1, .68)) == nil)

local silver = Bell.new(START)
assert(Bell.strike(silver, START) == nil)
assert(Bell.strike(silver, timeAtBeat(1, 0.68), 2) == nil)
assert(silver.lastBeat == 0 and silver.score == 0)
assert(Bell.strike(silver, timeAtBeat(1, .2)) == "early")
assert(Bell.strike(silver, timeAtBeat(1, .68)) == nil)
assert(Bell.strike(silver, timeAtBeat(2, .98)) == "late")
assert(silver.feedback == "late")
for beat = 3, Bell.BeatCount do
    assert(Bell.strike(silver, timeAtBeat(beat, .73)) == "good")
end
assert(silver.score == 8 and silver.bonus == 0)
assert(Bell.rank(silver.score, silver.bonus) == "Silver")
assert(Bell.rank(8, 3) == "Silver")
assert(Bell.rank(8, 4) == "Gold")
assert(Bell.rank(3, 3) == "Try again")
assert(Bell.strike(silver, START + 18) == nil)

print("Quick Play Bell timing tests passed")
