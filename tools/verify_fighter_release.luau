local FighterRelease = require("../roblox/grand-dojo/FighterRelease")

local function utc(year, month, day, hour)
    return os.time({year = year, month = month, day = day, hour = hour or 0})
end

local launch = utc(2028, 1, 31, 18)
local function count(at)
    return FighterRelease.releasedCount(launch, at, 24)
end

assert(FighterRelease.releasedCount(nil, launch, 24) == 8)
assert(FighterRelease.releasedCount("not a release date", launch, 24) == 8)
assert(FighterRelease.releasedCount(math.huge, launch, 24) == 8)
assert(count(launch - 1) == 8 and count(launch) == 8)
assert(count(utc(2028, 2, 29, 18) - 1) == 8)
assert(count(utc(2028, 2, 29, 18)) == 10, "Leap-day anniversary")
assert(count(utc(2028, 3, 31, 18) - 1) == 10)
assert(count(utc(2028, 3, 31, 18)) == 12, "Return to original anniversary")
assert(count(utc(2028, 9, 30, 18)) == 24)
assert(count(utc(2031, 12, 31, 18)) == 24, "The roster caps at its catalog size")
assert(FighterRelease.releasedCount(utc(2027, 12, 5), utc(2028, 1, 5), 24) == 10, "New year anniversary")
assert(FighterRelease.releasedCount(nil, launch, 4) == 4)

local order = {"fox", "lynx", "red-fox", "tiger", "wolf", "leopard"}
local lineup = FighterRelease.roster(order, 1, {tiger = {xp = 250}}, "wolf")
assert(lineup == "fox,tiger,wolf")
assert(FighterRelease.contains(lineup, "fox") and FighterRelease.contains(lineup, "wolf"))
assert(not FighterRelease.contains(lineup, "red-fox"))
assert(not FighterRelease.contains("blue-fox,lynx", "fox"))
assert(not FighterRelease.contains(nil, "fox"))
print("Fighter release checks passed for the launch size, UTC anniversaries, and existing access.")
