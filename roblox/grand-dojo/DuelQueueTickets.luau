-- One server-owned Casual Duel ticket per Roblox user in an environment-specific sorted map.
local Tickets = {}
Tickets.__index = Tickets

local QUEUE_SECONDS = 55
local CLAIM_SECONDS = 8
local ASSIGNMENT_SECONDS = 60
local KEY_TTL_SECONDS = 150
local JOIN_RETRY_SECONDS = 8
local MAX_TIMESTAMP = 1e11
local MAX_VERSION = 2147483647
local TERMINAL_SORT = 1e12

local function whole(value, low, high)
    return type(value) == "number" and value >= low and value <= high and value % 1 == 0
end

local function validId(value)
    return type(value) == "string" and #value <= 80 and value:match("^[%w_%-]+$") ~= nil
end

local function validUser(userId)
    return whole(userId, 1, 9e15)
end

local function userKey(userId)
    return string.format("%.0f", userId)
end

local function validTicket(ticket, userId)
    if type(ticket) ~= "table" or ticket.schema ~= 1 or ticket.userId ~= userId
        or not validId(ticket.sourceJobId) or not validId(ticket.generation)
        or not whole(ticket.version, 1, MAX_VERSION) or not whole(ticket.joinedAt, 1, MAX_TIMESTAMP)
        or not whole(ticket.expiresAt, ticket.joinedAt + 1, MAX_TIMESTAMP) then
        return false
    end
    local state, match, claimUntil = ticket.state, ticket.matchId, ticket.claimUntil
    if state == "waiting" then
        return match == nil and claimUntil == nil
    elseif state == "claimed" then
        return validId(match) and whole(claimUntil, ticket.joinedAt + 1, ticket.expiresAt)
    elseif state == "assigned" then
        return validId(match) and claimUntil == nil
    elseif state == "closed" then
        return (match == nil or validId(match)) and claimUntil == nil
    end
    return false
end

local function changed(ticket, state, matchId, claimUntil)
    local result = table.clone(ticket)
    result.state, result.matchId, result.claimUntil = state, matchId, claimUntil
    result.version += 1
    return result
end

function Tickets.new(map, clock, ascending)
    return setmetatable({map = map, clock = clock, ascending = ascending}, Tickets)
end

function Tickets:_update(userId, transform)
    local reason
    local ok, saved = pcall(self.map.UpdateAsync, self.map, userKey(userId), function(current)
        local now = self.clock()
        if current ~= nil and not validTicket(current, userId) then
            reason = "invalid record"
            return nil
        end
        local result, why = transform(current, now)
        reason = why
        if result == nil then return nil end
        local sortKey = if result.state == "closed" or result.state == "assigned" then TERMINAL_SORT else result.joinedAt
        return result, sortKey
    end, KEY_TTL_SECONDS)
    if not ok then return nil, "unavailable" end
    if reason then return nil, reason end
    return saved
end

function Tickets:read(userId)
    if not validUser(userId) then return nil, "invalid user" end
    local ok, ticket = pcall(self.map.GetAsync, self.map, userKey(userId))
    if not ok then return nil, "unavailable" end
    if ticket ~= nil and not validTicket(ticket, userId) then return nil, "invalid record" end
    return ticket
end

-- Replace only the generation the source observed with read(). A tombstone keeps cancelled requests from reappearing.
function Tickets:join(userId, sourceJobId, generation, replaces, issuedAt)
    if not validUser(userId) or not validId(sourceJobId) or not validId(generation) or replaces == generation
        or (replaces ~= nil and not validId(replaces)) or not whole(issuedAt, 1, MAX_TIMESTAMP - QUEUE_SECONDS) then
        return nil, "invalid request"
    end
    return self:_update(userId, function(current, now)
        if current and current.generation == generation then
            if current.sourceJobId == sourceJobId and current.joinedAt == issuedAt
                and current.state ~= "closed" and now < current.expiresAt then
                return current
            end
            return nil, "stale generation"
        end
        if issuedAt > now or now - issuedAt > JOIN_RETRY_SECONDS then return nil, "expired request" end
        if (current and current.generation or nil) ~= replaces then return nil, "stale generation" end
        if current and current.state ~= "closed" and now < current.expiresAt then return nil, "already queued" end
        return {schema = 1, userId = userId, sourceJobId = sourceJobId, generation = generation,
            version = 1, joinedAt = issuedAt, expiresAt = issuedAt + QUEUE_SECONDS, state = "waiting"}
    end)
end

-- Feed back the opaque cursor for another bounded scan. The claimant still verifies each row via CAS.
function Tickets:list(limit, cursor)
    if not whole(limit, 1, 50) then return nil, nil, "invalid limit" end
    local ok, rows = pcall(self.map.GetRangeAsync, self.map, self.ascending, limit, cursor)
    if not ok then return nil, nil, "unavailable" end
    local now, waiting = self.clock(), {}
    for _, row in rows do
        local ticket, userId = row.value, tonumber(row.key)
        if validUser(userId) and validTicket(ticket, userId) and ticket.expiresAt > now
            and (ticket.state == "waiting" or ticket.state == "claimed" and ticket.claimUntil <= now) then
            table.insert(waiting, ticket)
        elseif row.sortKey == TERMINAL_SORT then
            return waiting
        end
    end
    local last = if #rows == limit then rows[#rows] else nil
    return waiting, if last then {key = last.key, sortKey = last.sortKey} else nil
end

function Tickets:claim(userId, generation, version, matchId)
    if not validUser(userId) or not validId(generation) or not whole(version, 1, MAX_VERSION - 2)
        or not validId(matchId) then
        return nil, "invalid claim"
    end
    return self:_update(userId, function(current, now)
        if not current or current.generation ~= generation or current.expiresAt <= now then
            return nil, "stale ticket"
        end
        if current.state == "claimed" and current.matchId == matchId and current.version == version + 1
            and current.claimUntil > now then
            return current
        end
        if current.version ~= version then return nil, "stale version" end
        if current.state ~= "waiting" and (current.state ~= "claimed" or current.claimUntil > now) then
            return nil, "ticket unavailable"
        end
        return changed(current, "claimed", matchId, math.min(current.expiresAt, now + CLAIM_SECONDS))
    end)
end

function Tickets:releaseClaim(userId, generation, version, matchId)
    if not validUser(userId) or not validId(generation) or not whole(version, 1, MAX_VERSION - 1)
        or not validId(matchId) then
        return nil, "invalid claim"
    end
    return self:_update(userId, function(current, now)
        if not current or current.generation ~= generation or current.expiresAt <= now
            or current.version ~= version or current.state ~= "claimed" or current.matchId ~= matchId then
            return nil, "stale claim"
        end
        return changed(current, "waiting")
    end)
end

-- The caller has created a canonical two-seat assignment for the same match ID before assigning either ticket.
function Tickets:assign(userId, generation, version, matchId, deadline)
    if not validUser(userId) or not validId(generation) or not whole(version, 1, MAX_VERSION - 2)
        or not validId(matchId) or not whole(deadline, 1, MAX_TIMESTAMP) then
        return nil, "invalid assignment"
    end
    return self:_update(userId, function(current, now)
        if not current or current.generation ~= generation or current.expiresAt <= now then
            return nil, "stale ticket"
        end
        if current.state == "assigned" and current.matchId == matchId and current.version == version + 1
            and current.expiresAt == deadline then
            return current
        end
        if current.version ~= version or current.state ~= "claimed" or current.matchId ~= matchId
            or current.claimUntil <= now then
            return nil, "stale claim"
        end
        if deadline <= now or deadline > now + ASSIGNMENT_SECONDS then return nil, "invalid deadline" end
        local result = changed(current, "assigned", matchId)
        result.expiresAt = deadline
        return result
    end)
end

-- An assigned ticket can close only as a consequence of the canonical match reaching a terminal phase.
function Tickets:close(userId, sourceJobId, generation, matchId)
    if not validUser(userId) or not validId(sourceJobId) or not validId(generation)
        or (matchId ~= nil and not validId(matchId)) then
        return nil, "invalid request"
    end
    return self:_update(userId, function(current)
        if not current or current.generation ~= generation or current.sourceJobId ~= sourceJobId then
            return nil, "stale ticket"
        end
        if current.state == "closed" and current.matchId == matchId then return current end
        if current.state == "assigned" and current.matchId ~= matchId then return nil, "assignment active" end
        if current.state ~= "assigned" and (current.state == "closed" or matchId ~= nil) then
            return nil, "stale assignment"
        end
        return changed(current, "closed", matchId)
    end)
end

return Tickets
