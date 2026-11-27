local Rush = require("../roblox/grand-dojo/QuickPlayRushRules")

local start = 1760000000
local gold = Rush.new(start)
local function near(a, b)
    return math.abs(a - b) < 1e-4
end

local first = Rush.snapshot(gold)
assert(near(first.endsAt - first.startsAt, 25) and Rush.forkCount == 8)
assert(first.safeLane == 2 and first.shortcutLane == 1)
assert(not Rush.act(gold, first.safeLane, 1, start - .01))
assert(not Rush.act(gold, 4, 1, start))
assert(not Rush.act(gold, "2", 1, start))
assert(not Rush.act(gold, false, 1, start))
assert(not Rush.act(gold, first.safeLane, 2, start))

local shortcuts = {1, 2, 3, 2, 3, 2, 1, 1}
for fork, lane in ipairs(shortcuts) do
    local current = Rush.snapshot(gold)
    assert(current.fork == fork and current.shortcutLane == lane)
    assert(Rush.act(gold, lane, fork, current.closesAt - .01))
    assert(not Rush.act(gold, current.safeLane, fork, current.closesAt))
    assert(not Rush.step(gold, current.openedAt + 2.19))
    assert(Rush.step(gold, gold.advancesAt))
end
assert(gold.result and gold.result.rank == "gold" and gold.result.clean)
assert(gold.result.score == 8 and gold.result.bonus == 8)
assert(near(gold.result.elapsed, 17.6))
assert(not Rush.act(gold, 1, 8, start + 18))
assert(not Rush.step(gold, start + 30))

local silver = Rush.new(start)
local safeLanes = {2, 3, 1, 3, 2, 1, 2, 3}
for fork, lane in ipairs(safeLanes) do
    local current = Rush.snapshot(silver)
    assert(current.safeLane == lane)
    assert(Rush.act(silver, lane, fork, current.closesAt + .01))
    assert(Rush.step(silver, silver.advancesAt))
end
assert(silver.result.rank == "silver" and silver.result.clean)
assert(silver.result.score == 8 and silver.result.bonus == 0)
assert(near(silver.result.elapsed, 22.4))

local misses = Rush.new(start)
assert(Rush.act(misses, 1, 1, misses.openedAt + Rush.shortcutWindow))
assert(misses.score == 0 and misses.bonus == 0)
assert(string.find(misses.feedback, "^Shortcut closed"))
Rush.step(misses, misses.advancesAt)
assert(not Rush.act(misses, 2, 1, misses.openedAt + .1))
assert(Rush.act(misses, 1, 2, misses.openedAt + .1))
assert(string.find(misses.feedback, "^Barred lane"))
Rush.step(misses, start + 11.21)
assert(misses.fork == 5 and string.find(misses.feedback, "^Fork missed"))
assert(not Rush.act(misses, 2, 5, misses.advancesAt))
Rush.step(misses, start + 30)
assert(misses.result.rank == "retry" and not misses.result.clean)
assert(near(misses.result.elapsed, 22.4))

print("Quick Play Lantern Rush rules passed")
