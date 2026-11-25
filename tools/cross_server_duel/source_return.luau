local Source = require("../../roblox/grand-dojo/DuelSourceQueue")
local Return = require("../../roblox/grand-dojo/DuelCityReturn")
local Driver = require("../../roblox/grand-dojo/DuelAssignmentDriver")
local Assignments = require("../../roblox/grand-dojo/DuelAssignments")
local Tickets = require("../../roblox/grand-dojo/DuelQueueTickets")
local Bridge = require("../../roblox/grand-dojo/DuelProfileBridge")

local function clone(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in value do result[key] = clone(child) end
    return result
end

local function memoryStore()
    local data = {}
    local store = {}
    function store:GetAsync(key) return clone(data[key] and data[key].value) end
    function store:UpdateAsync(key, update)
        local old = data[key]
        local value, sort = update(clone(old and old.value), old and old.sortKey)
        if not value then return nil end
        data[key] = {value = clone(value), key = key, sortKey = sort}
        if self.lose and self.lose(value) then self.lose = nil error("write committed and response lost") end
        return clone(value)
    end
    function store:GetRangeAsync(_, count, cursor)
        local rows = {}
        local function before(a, b) return a.sortKey < b.sortKey or a.sortKey == b.sortKey and a.key < b.key end
        for _, row in data do if not cursor or before(cursor, row) then table.insert(rows, row) end end
        table.sort(rows, before)
        while #rows > count do table.remove(rows) end
        return rows
    end
    return store
end

local function fixture()
    local test = {now = 1000000, nextId = 0, sends = {}, reached = {}, profile = {}, held = {}, status = {}, workers = {}}
    function test.guid()
        test.nextId += 1
        return string.format("ee272394-7ef5-4ba4-afbc-%012d", test.nextId)
    end
    local function now() return test.now end
    test.ticketMap, test.assignmentMap = memoryStore(), memoryStore()
    test.assignments = Assignments.new(test.assignmentMap, now)
    test.tickets = Tickets.new(test.ticketMap, now, "ascending")
    test.alpha = {UserId = 101, job = "alpha", root = {}}
    test.beta = {UserId = 202, job = "beta", root = {}}
    local function origin(player)
        local queue
        local bridge = Bridge.new(now, function(which, held) test.held[which] = held end)
        bridge:register(player, "city")
        local profile = {lease = {token = player.job}}
        local driver = Driver.new(test.tickets, test.assignments, {
            jobId = player.job, universeId = 77, placeId = 55, protocol = "test", now = now, guid = test.guid,
            sourceEligible = function(who, seat, phase) return queue:eligible(who, seat, phase) end,
            isPresent = function(who) return not who.gone and who.job == player.job end,
            prepare = function(who, id, route, deadline) return bridge:request(who, "prepare", id, route, deadline) end,
            resume = function(who, id, route) return bridge:request(who, "resume", id, route) end,
            teleport = function(who, place, route, packet)
                assert(place == 55 and route == packet.matchId and test.held[who])
                test.sends[who] = (test.sends[who] or 0) + 1
                test.reached[who] = packet
                if test.failSend == who then return false end
            end,
        })
        queue = Source.new(test.tickets, test.assignments, driver, bridge, {
            jobId = player.job, now = now, guid = test.guid,
            root = function(who, paused)
                if who.gone or (test.held[who] and not paused) then return nil end
                return who.root
            end,
            player = function(uid) return if uid == player.UserId then player else nil end,
            status = function(who, queued, expiresAt, stage, message, canCancel)
                assert(type(message) == "string")
                test.status[who] = {queued = queued, stage = stage, canCancel = canCancel}
            end,
        })
        local datastore = {}
        function datastore:prepareMatchHandoff(uid, token, id, route, seq, deadline)
            assert(uid == player.UserId and token == player.job and seq > 0 and deadline > test.now)
            local pending = {lease = {token = token, handoff = {id = id, destination = route, state = "pending"}}}
            test.profile[player] = pending
            return pending
        end
        function datastore:cancelMatchHandoff(uid, token, id, _)
            assert(uid == player.UserId and token == player.job)
            assert(test.profile[player].lease.handoff.id == id)
            test.profile[player] = nil
            return profile
        end
        function datastore:open(uid, token)
            assert(uid == player.UserId and token == player.job)
            return profile
        end
        test.workers[player] = function()
            if not player.gone then bridge:step(player, datastore, player.job, profile, false) end
        end
        return queue, bridge
    end
    test.a, test.bridgeA = origin(test.alpha)
    test.b, test.bridgeB = origin(test.beta)
    function test.tick()
        test.now += 1
        test.a:tick()
        test.b:tick()
        test.workers[test.alpha]()
        test.workers[test.beta]()
    end
    function test.untilCondition(condition, maximum)
        for _ = 1, maximum do
            if condition() then return end
            test.tick()
        end
        assert(condition(), "expected source transition did not arrive: A " .. tostring(test.status[test.alpha] and test.status[test.alpha].stage)
            .. " B " .. tostring(test.status[test.beta] and test.status[test.beta].stage))
    end
    function test.enroll()
        assert(test.a:enroll(test.alpha, test.alpha.root))
        assert(test.b:enroll(test.beta, test.beta.root))
    end
    return test
end

local normal = fixture()
assert(not normal.a:enroll(normal.alpha, {}))
normal.enroll()
assert(not normal.a:enroll(normal.alpha, normal.alpha.root))
normal.ticketMap.lose = function(ticket) return ticket.state == "assigned" end
normal.untilCondition(function() return normal.sends[normal.alpha] and normal.sends[normal.beta] end, 40)
assert(normal.sends[normal.alpha] == 1 and normal.sends[normal.beta] == 1)
local packet = normal.reached[normal.alpha]
assert(packet.matchId == normal.reached[normal.beta].matchId)
assert(normal.status[normal.alpha].canCancel == false)
assert(not normal.a:failed(normal.alpha, packet.matchId, "obsolete-dispatch"))
normal.alpha.gone = true
normal.a:removed(normal.alpha)
assert(not normal.a:owns(normal.alpha) and normal.assignments:read(packet.matchId).phase == "traveling")
for _ = 1, 4 do normal.tick() end
assert(normal.sends[normal.beta] == 1)

local failed = fixture()
failed.failSend = failed.alpha
failed.enroll()
failed.untilCondition(function() return not failed.a:owns(failed.alpha) and not failed.b:owns(failed.beta) end, 35)
assert(failed.sends[failed.alpha] == 1 and (failed.sends[failed.beta] or 0) <= 1)
assert(failed.held[failed.alpha] == false and failed.held[failed.beta] == false)
assert(failed.assignments:read(failed.reached[failed.alpha].matchId).phase == "aborted")
assert(failed.a:enroll(failed.alpha, failed.alpha.root))

local cancelled = fixture()
cancelled.enroll()
assert(cancelled.a:cancel(cancelled.alpha))
cancelled.untilCondition(function() return not cancelled.a:owns(cancelled.alpha) end, 5)
assert(next(cancelled.sends) == nil)

local awarded = fixture()
awarded.enroll()
awarded.untilCondition(function() return awarded.profile[awarded.alpha] and awarded.profile[awarded.beta] end, 30)
awarded.bridgeA:receiptQueued(awarded.alpha)
awarded.untilCondition(function() return not awarded.a:owns(awarded.alpha) and not awarded.b:owns(awarded.beta) end, 30)
assert(next(awarded.sends) == nil)

local sameJob = fixture()
assert(sameJob.a:enroll(sameJob.alpha, sameJob.alpha.root))
assert(sameJob.tickets:join(sameJob.beta.UserId, "alpha", "second-local-player", nil, sameJob.now))
for _ = 1, 8 do sameJob.tick() end
assert(sameJob.tickets:read(sameJob.alpha.UserId).state == "waiting" and next(sameJob.sends) == nil)

local expiry = fixture()
assert(expiry.a:enroll(expiry.alpha, expiry.alpha.root))
expiry.untilCondition(function() return not expiry.a:owns(expiry.alpha) end, 62)
assert(expiry.status[expiry.alpha].queued == false and next(expiry.sends) == nil)

local outage = fixture()
outage.enroll()
outage.untilCondition(function() return outage.profile[outage.alpha] and outage.held[outage.alpha] end, 30)
function outage.ticketMap:GetAsync() error("Ticket store unavailable") end
function outage.assignmentMap:GetAsync() return nil end
outage.tick()
assert(outage.a:owns(outage.alpha) and outage.held[outage.alpha])
outage.now += 90
outage.untilCondition(function() return not outage.a:owns(outage.alpha) end, 4)
assert(outage.held[outage.alpha] == false and next(outage.sends) == nil)

local terminal = {phase = "aborted", reason = "split job", seats = {{userId = 101}, {userId = 202}}}
local abandoned = Driver.new({}, {read = function() return terminal end}, {})
abandoned.destination = {matchId = "split-match", seats = {[101] = outage.alpha}}
local failedStart, terminalReason = abandoned:tryStart()
assert(failedStart == nil and terminalReason == "split job")
print("Expired profile holds recover without MemoryStore, and a split-job abort surfaces immediately.")

local city = {clock = 1000000, sent = 0, releaseCount = 0, released = false, phase = nil, guid = 0}
local visitor = {UserId = 303}
local cityReturn
cityReturn = Return.new({
    now = function() return city.clock end,
    guid = function() city.guid += 1 return "return-" .. city.guid end,
    present = function(player) return player == visitor end,
    release = function(player, id)
        assert(player == visitor and id == "return-1")
        city.releaseCount += 1
        return city.released
    end,
    teleport = function(player, dispatch)
        assert(player == visitor and city.released)
        city.sent += 1
        city.dispatch = dispatch
        if city.sent == 1 then assert(cityReturn:failure(player, dispatch)) end
    end,
    status = function(_, phase) city.phase = phase end,
})
assert(not cityReturn:retry(visitor))
assert(cityReturn:offer(visitor, 4))
cityReturn:tick()
assert(city.releaseCount == 0 and city.phase == "waiting")
city.clock += 5
cityReturn:tick()
assert(city.releaseCount == 1 and city.sent == 0)
city.clock += 13
cityReturn:tick()
assert(city.phase == "failed")
assert(cityReturn:retry(visitor))
city.released = true
cityReturn:tick()
assert(city.sent == 1 and city.phase == "failed")
local old = city.dispatch
assert(cityReturn:retry(visitor))
cityReturn:tick()
assert(city.sent == 2 and city.phase == "sent" and city.dispatch ~= old)
assert(not cityReturn:failure(visitor, old))
assert(cityReturn:retry(visitor))
cityReturn:tick()
assert(city.sent == 2)
city.clock += 19
cityReturn:tick()
assert(city.sent == 2 and city.phase == "failed")
assert(cityReturn:retry(visitor))
cityReturn:tick()
assert(city.sent == 3 and city.phase == "sent")
cityReturn:remove(visitor)
assert(not cityReturn:failure(visitor, city.dispatch) and not cityReturn:retry(visitor))
print("Origin and City return passed real ticket/assignment/driver flow, lost replies, cancellation, expired queue, late rewards, dispatch failure and retry fencing.")
