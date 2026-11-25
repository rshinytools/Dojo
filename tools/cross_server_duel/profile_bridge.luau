local Bridge = require("../../roblox/grand-dojo/DuelProfileBridge")
local clock = 1000000
local held, calls = {}, {}
local source, dest, other = {UserId = 101}, {UserId = 101}, {UserId = 202}
local worker = Bridge.new(function() return clock end, function(player, value) held[player] = value end)
worker:register(source, "city")
worker:register(dest, "arena")
worker:register(other, "unknown")
assert(held[source] == nil and held[dest] and held[other])
assert(worker:classifyCity(other) and held[other] == false)
local profile = {fighters = {xp = 300}, lease = {token = "origin-lease"}}
local function counts(name)
    calls[name] = (calls[name] or 0) + 1
end
local function leased(state, id, route)
    return {fighters = {xp = 300}, lease = {handoff = {state = state, id = id, destination = route}}}
end
local store = {}
function store:prepareMatchHandoff(userId, token, id, route, sequence, deadline)
    counts("prepare")
    assert(userId == 101 and token == "origin-lease" and deadline > clock and sequence > 0)
    if self.onPrepare then self.onPrepare() end
    if self.unavailable then return nil, "unavailable" end
    return leased("pending", id, route)
end
function store:cancelMatchHandoff(userId, token, id, route)
    counts("cancel")
    assert(userId == 101 and token == "origin-lease")
    if self.unavailable then return nil, "unavailable" end
    return leased("cancelled", id, route)
end
function store:acceptMatchHandoff(userId, token, id, route)
    counts("accept")
    assert(userId == 101 and token == "arena-lease")
    if self.unavailable then return nil, "unavailable" end
    return leased("accepted", id, route)
end
function store:open(userId, token)
    counts("open")
    assert(userId == 101 and token == "origin-lease")
    if self.busy then return nil, "busy" end
    return profile
end
local function rejected(reason, got, why)
    assert(got == nil and why == reason, string.format("expected %s, got %s %s", reason, tostring(got), tostring(why)))
end
assert(worker:step(source, store, "origin-lease", profile, false) == false)
assert(worker:step(dest, store, "arena-lease", nil, false) == true)
assert(calls.open == nil and calls.accept == nil)
rejected("worker busy", worker:request(source, "accept", "fake", "route", clock + 30))
local deadline = clock + 45
rejected("pending", worker:request(source, "prepare", "match-1", "route", deadline))
assert(held[source] and not worker:ownsOutbound(source))
assert(worker:step(source, store, "origin-lease", profile, true) == false and calls.prepare == nil)
store.unavailable = true
assert(worker:step(source, store, "origin-lease", profile, false))
assert(worker:ownsOutbound(source) and not worker:sourceReady(source))
rejected("unavailable", worker:request(source, "prepare", "match-1", "route", deadline))
store.unavailable = false
assert(worker:step(source, store, "origin-lease", profile, false))
assert(worker:sourceReady(source))
assert(worker:request(source, "prepare", "match-1", "route", deadline).lease.handoff.state == "pending")
worker:receiptQueued(source)
assert(not worker:sourceReady(source))
rejected("stale handoff", worker:request(source, "resume", "wrong-id", "route"))
rejected("pending", worker:request(source, "resume", "match-1", "route"))
assert(not worker:sourceReady(source))
local paused, restored = worker:step(source, store, "origin-lease", profile, true)
assert(paused and restored and restored.fighters.xp == 300 and held[source] == false)
assert(worker:request(source, "resume", "match-1", "route") == restored)
assert(not worker:ownsOutbound(source))
assert(worker:step(source, store, "origin-lease", restored, true) == false)

rejected("pending", worker:request(source, "prepare", "match-2", "route", clock + 2))
assert(worker:step(source, store, "origin-lease", restored, false))
clock += 2
rejected("pending", worker:request(source, "resume", "match-2", "route"))
store.busy = true
assert(worker:step(source, store, "origin-lease", restored, false))
rejected("busy", worker:request(source, "resume", "match-2", "route"))
assert(held[source] and worker:ownsOutbound(source))
store.busy = false
local recoveryHeld, recovery = worker:step(source, store, "origin-lease", restored, false)
assert(recoveryHeld and recovery == profile and held[source] == false)

rejected("pending", worker:request(source, "prepare", "drain-expired", "route", clock + 1))
clock += 1
assert(not worker:step(source, store, "origin-lease", profile, true))
rejected("expired", worker:request(source, "prepare", "drain-expired", "route", clock))
rejected("pending", worker:request(source, "resume", "drain-expired", "route"))
local restoredDrain, elapsed = worker:step(source, store, "origin-lease", profile, true)
assert(restoredDrain and elapsed == profile and held[source] == false)

rejected("pending", worker:request(source, "prepare", "competing", "route", clock + 30))
store.onPrepare = function()
    rejected("pending", worker:request(source, "resume", "competing", "route"))
end
assert(worker:step(source, store, "origin-lease", profile, false))
assert(not worker:sourceReady(source))
store.onPrepare = nil
assert(worker:step(source, store, "origin-lease", profile, false))
assert(worker:request(source, "resume", "competing", "route"))

rejected("pending", worker:request(dest, "accept", "match-3", "route", clock + 20))
assert(not worker:classifyCity(dest))
store.unavailable = true
assert(worker:step(dest, store, "arena-lease", nil, false))
assert(worker:acceptAttempted(dest) and not worker:arenaReady(dest))
store.unavailable = false
local blockedArrival, arrived = worker:step(dest, store, "arena-lease", nil, false)
assert(blockedArrival and arrived and worker:arenaReady(dest) and held[dest])
assert(worker:step(dest, store, "arena-lease", arrived, false) == false)
assert(worker:request(dest, "accept", "match-3", "route", clock + 20) == arrived)
worker:forget(dest)
assert(not worker:acceptAttempted(dest) and not worker:arenaReady(dest))
print("Serial profile bridge passed drain, write ambiguity, late grant fence, rollback, transit expiry, arrival freeze and sole worker ownership.")
