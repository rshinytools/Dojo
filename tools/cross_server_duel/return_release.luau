local utc = 1000000
local data = {}
local adapter = {}
function adapter:UpdateAsync(key, transform)
    if self.stopped then error("transient timeout") end
    local changed = transform(data[key])
    if changed ~= nil then data[key] = changed end
    if changed and self.failAfter and changed.duelReturn and not changed.lease then
        self.failAfter, self.stopped = false, true
        error("release committed but reply lost")
    end
    return changed
end
local clock = function() return utc end
local arena = PlayerProfiles.new(adapter, clock, function() end)
local city = PlayerProfiles.new(adapter, clock, function() end)
assert(arena:open(777, "origin"))
assert(arena:commitStarterChoice(777, "origin", "reedguard-kangaroo"))
assert(arena:commitRelay(777, "origin", 440, "relay-award", "reedguard-kangaroo"))
local stored = data.player_777
assert(stored.trophies["world-04"] and stored.fighters["reedguard-kangaroo"].xp == 80)
assert(arena:prepareMatchHandoff(777, "origin", "outbound", "arena", 1, utc + 20))
local prevented, reason = arena:releaseMatchReturn(777, "origin", "city-return")
assert(not prevented and reason == "transferring")
assert(arena:acceptMatchHandoff(777, "destination", "outbound", "arena"))
adapter.failAfter = true
local released, unavailable = arena:releaseMatchReturn(777, "destination", "city-return")
assert(not released and unavailable == "unavailable" and data.player_777.lease == nil)
adapter.stopped = false
assert(city:open(777, "city"))
assert(arena:releaseMatchReturn(777, "destination", "city-return"))
assert(data.player_777.lease.token == "city" and data.player_777.trophies["world-04"] and data.player_777.fighters["reedguard-kangaroo"].xp == 80)
local duplicate, ownership = arena:releaseMatchReturn(777, "destination", "unknown-attempt")
assert(not duplicate and ownership == "ownership")
assert(data.player_777.lease.token == "city")
assert(city:release(777, "city"))
assert(arena:open(777, "destination"))
local stale, staleReason = arena:releaseMatchReturn(777, "destination", "city-return")
assert(not stale and staleReason == "stale return" and data.player_777.lease.token == "destination")
print("City release receipt passed protected outbound, missing reply, new city owner, progress preservation and stale release fencing.")
