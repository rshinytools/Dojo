-- Server-only orchestration. The caller serializes work for each queued Player.
local Driver = {}
Driver.__index = Driver

local function seatFor(record, userId)
    for _, seat in record.seats do
        if seat.userId == userId then return seat end
    end
    return nil
end

local function markerMatches(profile, state, seat, privateId)
    local marker = profile and profile.lease and profile.lease.handoff
    return marker and marker.state == state and marker.id == seat.transferId and marker.destination == privateId
end

function Driver.new(tickets, assignments, io)
    return setmetatable({tickets = tickets, assignments = assignments, io = io, dispatches = {}, preparations = {}}, Driver)
end

-- The caller selects two candidates from a bounded scan. It retries a lost acknowledgement with the same GUID.
function Driver:pair(matchId, first, second, deadline)
    if first.userId > second.userId then first, second = second, first end
    if first.userId == second.userId or first.sourceJobId == second.sourceJobId
        or (first.sourceJobId ~= self.io.jobId and second.sourceJobId ~= self.io.jobId) then
        return nil, "invalid pair"
    end
    local existing, reason = self.assignments:read(matchId)
    if reason then return nil, reason end
    if existing then
        for n, ticket in {first, second} do
            local seat = existing.seats[n]
            if seat.userId ~= ticket.userId or seat.generation ~= ticket.generation or seat.sourceJobId ~= ticket.sourceJobId
                or seat.claimVersion ~= ticket.version + 1 then return nil, "assignment conflict" end
        end
        if existing.deadline ~= deadline or existing.placeId ~= self.io.placeId or existing.universeId ~= self.io.universeId
            or existing.protocol ~= self.io.protocol then return nil, "assignment conflict" end
        return self:assignTickets(existing)
    end
    local claimedFirst
    claimedFirst, reason = self.tickets:claim(first.userId, first.generation, first.version, matchId)
    if not claimedFirst then return nil, reason end
    local claimedSecond
    claimedSecond, reason = self.tickets:claim(second.userId, second.generation, second.version, matchId)
    if not claimedSecond then
        if reason ~= "unavailable" then
            self.tickets:releaseClaim(first.userId, first.generation, claimedFirst.version, matchId)
        end
        return nil, reason
    end
    local record
    record, reason = self.assignments:create(matchId, self.io.universeId, self.io.placeId, self.io.protocol,
        claimedFirst, claimedSecond, deadline)
    if not record then
        if reason ~= "unavailable" then
            self.tickets:releaseClaim(first.userId, first.generation, claimedFirst.version, matchId)
            self.tickets:releaseClaim(second.userId, second.generation, claimedSecond.version, matchId)
        end
        return nil, reason
    end
    return self:assignTickets(record)
end

function Driver:assignTickets(record)
    if record.phase ~= "pairing" then return record end
    for _, seat in record.seats do
        local ticket, reason = self.tickets:assign(seat.userId, seat.generation, seat.claimVersion, record.id, record.deadline)
        if not ticket then
            if reason ~= "unavailable" then
                for _, localSeat in record.seats do
                    if localSeat.sourceJobId == self.io.jobId then
                        local aborted = self.assignments:abortSource(record.id, self.io.jobId, localSeat.userId,
                            localSeat.generation, nil, "assignment")
                        if aborted then self:cleanupTickets(aborted) end
                    end
                end
            end
            return nil, reason
        end
    end
    return record
end

function Driver:_sourceSeat(player, matchId, generation)
    local record, reason = self.assignments:read(matchId)
    if not record then return nil, nil, reason end
    local seat = seatFor(record, player.UserId)
    if not seat or seat.generation ~= generation or seat.sourceJobId ~= self.io.jobId
        or record.placeId ~= self.io.placeId or record.universeId ~= self.io.universeId or record.protocol ~= self.io.protocol then
        return nil, nil, "wrong source"
    end
    return record, seat
end

function Driver:confirmSource(player, matchId, generation)
    local record, seat, reason = self:_sourceSeat(player, matchId, generation)
    if not record then return nil, reason end
    local ticket
    ticket, reason = self.tickets:read(seat.userId)
    if not ticket then return nil, reason end
    if not self.io.sourceEligible(player, seat, "queued") then return nil, "player unavailable" end
    return self.assignments:confirmTicket(record.id, self.io.jobId, ticket)
end

function Driver:reserve(matchId, reservedId)
    return self.assignments:reserve(matchId, self.io.jobId, reservedId)
end

function Driver:prepareSource(player, matchId, generation)
    local record, seat, reason = self:_sourceSeat(player, matchId, generation)
    if not record then return nil, reason end
    if (record.phase ~= "preparing" and record.phase ~= "traveling") or self.io.now() >= record.deadline
        or not self.io.sourceEligible(player, seat, "preparing") then return nil, "preparation unavailable" end
    local privateId = record.reservedId
    local preparation = self.preparations[player]
    if preparation and (preparation.matchId ~= matchId or preparation.generation ~= generation) then
        return nil, "profile transfer in progress"
    end
    self.preparations[player] = preparation or {matchId = matchId, generation = generation,
        transferId = seat.transferId, privateId = privateId, deadline = record.deadline}
    local profile
    profile, reason = self.io.prepare(player, seat.transferId, privateId, record.deadline)
    if not markerMatches(profile, "pending", seat, privateId) then return nil, reason or "invalid profile receipt" end
    if not self.io.sourceEligible(player, seat, "transferring") then return nil, "player unavailable" end
    return self.assignments:confirmPrepared(matchId, self.io.jobId, seat.userId, generation, seat.transferId, privateId)
end

function Driver:dispatch(player, matchId, generation, dispatch)
    local record, seat, reason = self:_sourceSeat(player, matchId, generation)
    if not record then return nil, reason end
    if not self.io.sourceEligible(player, seat, "transferring") then return nil, "player unavailable" end
    record, reason = self.assignments:authorizeDeparture(matchId, self.io.jobId, seat.userId, generation, dispatch)
    if not record then return nil, reason end
    if not self.io.sourceEligible(player, seat, "transferring") then
        self.assignments:abortSource(matchId, self.io.jobId, seat.userId, generation, dispatch, "cancelled")
        return nil, "player unavailable"
    end
    local departure = self.dispatches[player]
    if departure then
        if departure.matchId == matchId and departure.dispatch == dispatch then
            if departure.status == "failed" then return nil, "transport failed" end
            return departure.status
        end
        return nil, "departure in progress"
    end
    departure = {matchId = matchId, generation = generation, dispatch = dispatch, status = "starting"}
    self.dispatches[player] = departure
    local ok, initiated = pcall(self.io.teleport, player, record.placeId, record.reservedId,
        {purpose = "casualDuel", matchId = matchId, dispatch = dispatch})
    if departure.status == "failed" then return nil, "transport failed" end
    if not ok or initiated == false then
        self:failDeparture(player, matchId, dispatch)
        return nil, "transport failed"
    end
    departure.status = "initiated"
    return departure.status
end

function Driver:failDeparture(player, matchId, dispatch)
    local departure = self.dispatches[player]
    if not departure or departure.matchId ~= matchId or departure.dispatch ~= dispatch then return nil, "stale dispatch" end
    departure.status = "failed"
    return self.assignments:abortSource(matchId, self.io.jobId, player.UserId, departure.generation, dispatch, "transport")
end

function Driver:sourceRemoved(player)
    -- PlayerRemoving after a dispatch is a normal part of a successful teleport.
    local dispatched = self.dispatches[player] ~= nil
    self.dispatches[player] = nil
    self.preparations[player] = nil
    return dispatched
end

function Driver:cleanupTickets(record)
    if record.phase ~= "aborted" and record.phase ~= "finished" then return nil, "assignment active" end
    local complete = true
    for _, seat in record.seats do
        local ticket, reason = self.tickets:read(seat.userId)
        if reason then
            complete = false
        elseif ticket and ticket.generation == seat.generation and ticket.matchId == record.id then
            if ticket.state == "claimed" and self.io.now() < ticket.expiresAt then
                local released = self.tickets:releaseClaim(seat.userId, seat.generation, ticket.version, record.id)
                complete = complete and released ~= nil
            elseif ticket.state == "assigned" then
                local closed = self.tickets:close(seat.userId, seat.sourceJobId, seat.generation, record.id)
                complete = complete and closed ~= nil
            end
        end
    end
    return complete
end

local function restoreSource(driver, player, matchId, generation)
    if not driver.io.isPresent(player) then return nil, "player unavailable" end
    local preparation = driver.preparations[player]
    if preparation then
        if preparation.matchId ~= matchId or preparation.generation ~= generation then return nil, "stale recovery" end
        local resumed, reason = driver.io.resume(player, preparation.transferId, preparation.privateId)
        if not resumed then return nil, reason end
        driver.preparations[player] = nil
    end
    local departure = driver.dispatches[player]
    if departure and departure.matchId == matchId and departure.generation == generation then
        driver.dispatches[player] = nil
    end
    return true
end

function Driver:resumeSource(player, matchId, generation)
    local record, _, reason = self:_sourceSeat(player, matchId, generation)
    if not record then return nil, reason end
    if record.phase ~= "aborted" then return nil, "source still traveling" end
    return restoreSource(self, player, matchId, generation)
end

function Driver:recoverExpiredSource(player, matchId, generation)
    local preparation = self.preparations[player]
    if preparation and self.io.now() < preparation.deadline then return nil, "source still traveling" end
    return restoreSource(self, player, matchId, generation)
end

function Driver:acceptArrival(player, joinData)
    local payload = joinData and joinData.TeleportData
    if type(payload) ~= "table" or payload.purpose ~= "casualDuel" or not self.io.privateId
        or not self.io.isPresent(player) then return nil, "invalid arrival" end
    if self.destination and self.destination.matchId ~= payload.matchId then return nil, "wrong reservation" end
    local arrival = {userId = player.UserId, jobId = self.io.jobId, privateId = self.io.privateId,
        universeId = self.io.universeId, placeId = self.io.placeId, protocol = self.io.protocol,
        sourceUniverseId = joinData.SourceGameId, sourcePlaceId = joinData.SourcePlaceId, dispatch = payload.dispatch}
    local record, reason = self.assignments:admit(payload.matchId, arrival)
    if not record then return nil, reason end
    if record.phase ~= "traveling" then return nil, record.reason end
    if not self.destination then self.destination = {matchId = record.id, startId = self.io.guid(), seats = {}} end
    if self.destination.matchId ~= record.id then return nil, "wrong reservation" end
    if not self.io.isPresent(player) then
        self.assignments:abortDestination(record.id, self.io.jobId, nil, "cancelled")
        return nil, "player unavailable"
    end
    local seat = seatFor(record, player.UserId)
    local profile
    profile, reason = self.io.accept(player, seat.transferId, self.io.privateId, record.deadline)
    if not markerMatches(profile, "accepted", seat, self.io.privateId) then return nil, reason or "invalid profile receipt" end
    record, reason = self.assignments:confirmProfile(record.id, arrival, seat.transferId)
    if not record then return nil, reason end
    if not self.io.isPresent(player) then
        self.assignments:abortDestination(record.id, self.io.jobId, nil, "cancelled")
        return nil, "player unavailable"
    end
    self.destination.seats[player.UserId] = player
    return record
end

function Driver:_roots(record)
    local first = self.destination.seats[record.seats[1].userId]
    local second = self.destination.seats[record.seats[2].userId]
    if not first or not second then return nil end
    local firstRoot, secondRoot = self.io.readyRoot(first), self.io.readyRoot(second)
    if firstRoot and secondRoot then return first, firstRoot, second, secondRoot end
    return nil
end

function Driver:tryStart()
    local localMatch = self.destination
    if not localMatch or localMatch.started then return nil, "start unavailable" end
    local record, reason = self.assignments:read(localMatch.matchId)
    if not record then return nil, reason end
    if record.phase ~= "traveling" and not (record.phase == "running" and record.startId == localMatch.startId) then
        return nil, record.reason or "start unavailable"
    end
    if not self:_roots(record) then return nil, "players not ready" end
    record, reason = self.assignments:start(record.id, self.io.jobId, localMatch.startId)
    if not record then return nil, reason end
    local first, firstRoot, second, secondRoot = self:_roots(record)
    if localMatch.started then return nil, "already started" end
    if not first then
        self.assignments:abortDestination(record.id, self.io.jobId, localMatch.startId, "cancelled")
        return nil, "player departed"
    end
    localMatch.started = true
    self.io.begin(first, firstRoot, second, secondRoot, record.id)
    return record
end

function Driver:finish(matchId)
    local localMatch = self.destination
    if not localMatch or localMatch.matchId ~= matchId or not localMatch.started then return nil, "not running" end
    return self.assignments:finish(matchId, self.io.jobId, localMatch.startId)
end

return Driver
