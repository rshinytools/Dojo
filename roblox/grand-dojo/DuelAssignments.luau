-- The authoritative two-seat Casual assignment. Use a server-only MemoryStoreHashMap.
local Assignments = {}
Assignments.__index = Assignments

local ARRIVAL_SECONDS = 60
local RUN_SECONDS = 120
local RECORD_TTL = 240
local MAX_TIME = 1e11
local MAX_ID = 9e15

local function integer(value, minimum, maximum)
    return type(value) == "number" and value % 1 == 0 and value >= minimum and value <= maximum
end

local function id(value, limit)
    return type(value) == "string" and #value <= (limit or 80) and value:match("^[%w_%-]+$") ~= nil
end

local function phaseActive(phase)
    return phase == "pairing" or phase == "preparing" or phase == "traveling"
end

local function valid(record, key)
    return type(record) == "table" and record.schema == 1 and record.id == key
        and integer(record.deadline, 1, MAX_TIME) and type(record.seats) == "table"
        and type(record.seats[1]) == "table" and type(record.seats[2]) == "table"
        and (phaseActive(record.phase) or record.phase == "running" or record.phase == "finished" or record.phase == "aborted")
end

local function seatFor(record, userId)
    for n, seat in record.seats do
        if seat.userId == userId then return seat, n end
    end
    return nil
end

local function changeSeat(record, index)
    local copy = table.clone(record)
    copy.seats = table.clone(record.seats)
    local seat = table.clone(copy.seats[index])
    copy.seats[index] = seat
    return copy, seat
end

local function terminal(record, phase, reason)
    local copy = table.clone(record)
    copy.phase, copy.reason = phase, reason
    return copy
end

local function ticketClaim(ticket, matchId)
    return type(ticket) == "table" and ticket.state == "claimed" and ticket.matchId == matchId
        and integer(ticket.userId, 1, MAX_ID) and id(ticket.sourceJobId) and id(ticket.generation)
        and integer(ticket.version, 2, 2147483645) and integer(ticket.claimUntil, 1, MAX_TIME)
        and integer(ticket.expiresAt, ticket.claimUntil, MAX_TIME)
end

local function matchesClaim(seat, ticket)
    return seat.userId == ticket.userId and seat.sourceJobId == ticket.sourceJobId
        and seat.generation == ticket.generation and seat.claimVersion == ticket.version
end

local function sourceSeat(record, source, uid, generation)
    local seat, index = seatFor(record, uid)
    if seat and seat.sourceJobId == source and seat.generation == generation then return seat, index end
    return nil
end

function Assignments.new(map, now)
    return setmetatable({map = map, now = now}, Assignments)
end

function Assignments:read(matchId)
    if not id(matchId, 40) then return nil, "invalid assignment" end
    local ok, result = pcall(self.map.GetAsync, self.map, matchId)
    if not ok then return nil, "unavailable" end
    if result and not valid(result, matchId) then return nil, "invalid record" end
    return result
end

function Assignments:_update(matchId, canCreate, transform)
    if not id(matchId, 40) then return nil, "invalid assignment" end
    local reason
    local ok, result = pcall(self.map.UpdateAsync, self.map, matchId, function(record)
        if record == nil and not canCreate then
            reason = "missing assignment"
            return nil
        elseif record ~= nil and not valid(record, matchId) then
            reason = "invalid record"
            return nil
        end
        local updated, why = transform(record, self.now())
        reason = why
        return updated
    end, RECORD_TTL)
    if not ok then return nil, "unavailable" end
    if reason then return nil, reason end
    return result
end

function Assignments:create(matchId, universeId, placeId, protocol, first, second, deadline)
    if not integer(universeId, 1, MAX_ID) or not integer(placeId, 1, MAX_ID) or not id(protocol)
        or not integer(deadline, 1, MAX_TIME - RUN_SECONDS) or not ticketClaim(first, matchId)
        or not ticketClaim(second, matchId) or first.userId >= second.userId or first.sourceJobId == second.sourceJobId then
        return nil, "invalid pairing"
    end
    return self:_update(matchId, true, function(record, now)
        if record then
            if record.universeId == universeId and record.placeId == placeId and record.protocol == protocol
                and record.deadline == deadline and matchesClaim(record.seats[1], first) and matchesClaim(record.seats[2], second) then
                return record
            end
            return nil, "assignment conflict"
        end
        if now >= first.claimUntil or now >= second.claimUntil or deadline <= now or deadline > now + ARRIVAL_SECONDS then
            return nil, "pairing expired"
        end
        local seats = {}
        for n, ticket in {first, second} do
            seats[n] = {userId = ticket.userId, sourceJobId = ticket.sourceJobId, generation = ticket.generation,
                claimVersion = ticket.version, transferId = matchId .. "-" .. n}
        end
        return {schema = 1, id = matchId, universeId = universeId, placeId = placeId, protocol = protocol,
            phase = "pairing", seats = seats, deadline = deadline}
    end)
end

-- Called by the owning city job after verifying the current connected player and rereading its assigned ticket.
function Assignments:confirmTicket(matchId, source, ticket)
    if type(ticket) ~= "table" or ticket.state ~= "assigned" or ticket.matchId ~= matchId or not id(source) then
        return nil, "invalid ticket"
    end
    return self:_update(matchId, false, function(record, now)
        local seat, index = sourceSeat(record, source, ticket.userId, ticket.generation)
        if not seat or ticket.sourceJobId ~= source or ticket.version ~= seat.claimVersion + 1
            or ticket.expiresAt ~= record.deadline then
            return nil, "ticket mismatch"
        end
        if now >= record.deadline or not phaseActive(record.phase) then return nil, "assignment unavailable" end
        if seat.confirmed then return record end
        if record.phase ~= "pairing" then return nil, "assignment unavailable" end
        local copy, nextSeat = changeSeat(record, index)
        nextSeat.confirmed = true
        return copy
    end)
end

local function guid(value)
    if type(value) ~= "string" or #value ~= 36 then return false end
    local a, b, c, d, e = value:match("^(%x+)%-(%x+)%-(%x+)%-(%x+)%-(%x+)$")
    return a ~= nil and #a == 8 and #b == 4 and #c == 4 and #d == 4 and #e == 12
end

-- Modern Roblox reservations are selected by a GUID. Publish one ID before either origin moves.
function Assignments:reserve(matchId, source, reservedId)
    if not id(source) or not guid(reservedId) then return nil, "invalid reservation" end
    return self:_update(matchId, false, function(record, now)
        if record.seats[1].sourceJobId ~= source and record.seats[2].sourceJobId ~= source then
            return nil, "reservation unavailable"
        end
        if now >= record.deadline or not phaseActive(record.phase) then return nil, "reservation unavailable" end
        if record.reservedId then
            if record.reservedId == reservedId then return record end
            return nil, "reservation already chosen"
        end
        if record.phase ~= "pairing" or not record.seats[1].confirmed or not record.seats[2].confirmed then
            return nil, "reservation unavailable"
        end
        local copy = table.clone(record)
        copy.phase, copy.reservedId = "preparing", reservedId
        return copy
    end)
end

-- The progress worker has verified this marker by persisting or rereading it under its existing lease.
function Assignments:confirmPrepared(matchId, source, uid, generation, transferId, privateId)
    if not id(source) or not id(generation) then return nil, "invalid source" end
    return self:_update(matchId, false, function(record, now)
        local seat, index = sourceSeat(record, source, uid, generation)
        if not seat or not seat.confirmed or transferId ~= seat.transferId
            or privateId ~= record.reservedId then
            return nil, "handoff mismatch"
        end
        if now >= record.deadline or (record.phase ~= "preparing" and record.phase ~= "traveling") then
            return nil, "assignment unavailable"
        end
        if seat.prepared then return record end
        local copy, nextSeat = changeSeat(record, index)
        nextSeat.prepared = true
        if copy.seats[1].prepared and copy.seats[2].prepared then copy.phase = "traveling" end
        return copy
    end)
end

function Assignments:authorizeDeparture(matchId, source, uid, generation, dispatch)
    if not id(dispatch) then return nil, "invalid dispatch" end
    return self:_update(matchId, false, function(record, now)
        local seat, index = sourceSeat(record, source, uid, generation)
        if not seat or record.phase ~= "traveling" or now >= record.deadline then return nil, "dispatch unavailable" end
        if seat.dispatch == dispatch then return record end
        if seat.dispatch then return nil, "already dispatched" end
        local copy, nextSeat = changeSeat(record, index)
        nextSeat.dispatch = dispatch
        return copy
    end)
end

local function destinationSeat(record, arrival)
    if type(arrival) ~= "table" or not id(arrival.jobId) or arrival.universeId ~= record.universeId
        or arrival.placeId ~= record.placeId or arrival.sourcePlaceId ~= record.placeId
        or arrival.sourceUniverseId ~= record.universeId or arrival.protocol ~= record.protocol
        or not record.reservedId or arrival.privateId ~= record.reservedId then
        return nil
    end
    local seat, index = seatFor(record, arrival.userId)
    if seat and seat.dispatch and seat.dispatch == arrival.dispatch then return seat, index end
    return nil
end

-- Build arrival from actual server properties, authenticated Roblox user and trusted join provenance.
-- The teleport payload provides a match ID and dispatch correlation only.
function Assignments:admit(matchId, arrival)
    return self:_update(matchId, false, function(record, now)
        local seat, index = destinationSeat(record, arrival)
        if not seat then return nil, "admission denied" end
        if record.phase ~= "traveling" or now >= record.deadline then return nil, "admission closed" end
        if record.destinationJob and record.destinationJob ~= arrival.jobId then
            return terminal(record, "aborted", "split job")
        end
        if seat.arrived then return record end
        local copy, nextSeat = changeSeat(record, index)
        copy.destinationJob = arrival.jobId
        nextSeat.arrived = true
        return copy
    end)
end

function Assignments:confirmProfile(matchId, arrival, transferId)
    return self:_update(matchId, false, function(record, now)
        local seat, index = destinationSeat(record, arrival)
        if not seat or not seat.arrived or record.destinationJob ~= arrival.jobId or seat.transferId ~= transferId then
            return nil, "admission denied"
        end
        if record.phase ~= "traveling" or now >= record.deadline then return nil, "admission closed" end
        if seat.loaded then return record end
        local copy, nextSeat = changeSeat(record, index)
        nextSeat.loaded = true
        return copy
    end)
end

-- Check both local actors immediately before and after the yielding call, then begin the local Casual duel once.
function Assignments:start(matchId, job, startId)
    if not id(job) or not id(startId) then return nil, "invalid start" end
    return self:_update(matchId, false, function(record, now)
        if job ~= record.destinationJob then return nil, "wrong destination" end
        if record.phase == "running" and record.startId == startId and now < record.deadline + RUN_SECONDS then return record end
        if record.phase ~= "traveling" or now >= record.deadline or not record.seats[1].loaded or not record.seats[2].loaded then
            return nil, "start unavailable"
        end
        local copy = terminal(record, "running")
        copy.startId = startId
        return copy
    end)
end

function Assignments:finish(matchId, job, startId)
    if not id(job) or not id(startId) then return nil, "invalid finish" end
    return self:_update(matchId, false, function(record)
        if job ~= record.destinationJob or startId ~= record.startId then return nil, "wrong destination" end
        if record.phase == "finished" then return record end
        if record.phase ~= "running" then return nil, "assignment not running" end
        return terminal(record, "finished")
    end)
end

local failures = {cancelled = true, profile = true, assignment = true, transport = true, shutdown = true}

function Assignments:abortSource(matchId, source, uid, generation, dispatch, reason)
    if not failures[reason] then return nil, "invalid failure" end
    return self:_update(matchId, false, function(record)
        local seat = sourceSeat(record, source, uid, generation)
        if not seat or seat.dispatch ~= dispatch or seat.arrived then return nil, "stale source" end
        if record.phase == "aborted" then return record end
        if not phaseActive(record.phase) then return nil, "assignment committed" end
        return terminal(record, "aborted", reason)
    end)
end

-- For a local departure/profile failure after first arrival or a lost local actor during the start CAS.
function Assignments:abortDestination(matchId, job, startId, reason)
    if not id(job) or not failures[reason] then return nil, "invalid failure" end
    return self:_update(matchId, false, function(record)
        if record.destinationJob ~= job or record.startId ~= startId then return nil, "wrong destination" end
        if record.phase == "aborted" then return record end
        if record.phase ~= "traveling" and record.phase ~= "running" then return nil, "assignment committed" end
        return terminal(record, "aborted", reason)
    end)
end

function Assignments:expire(matchId)
    return self:_update(matchId, false, function(record, now)
        if (phaseActive(record.phase) and now >= record.deadline)
            or (record.phase == "running" and now >= record.deadline + RUN_SECONDS) then
            return terminal(record, "aborted", "expired")
        end
        return nil, "not expired"
    end)
end

return Assignments
