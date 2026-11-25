-- Origin queue for the opt-in cross-server Casual format. One pump per city job.
local Source = {}
Source.__index = Source

local ENROLL_SECONDS = 8
local QUEUE_SECONDS = 55
local TRAVEL_SECONDS = 45
local LOCAL_LIMIT = 12
local PAGE_SIZE = 16

function Source.new(tickets, assignments, driver, profiles, io)
    return setmetatable({tickets = tickets, assignments = assignments, driver = driver, profiles = profiles,
        io = io, entries = {}, nextSearch = 0, count = 0}, Source)
end

function Source:owns(player)
    return self.entries[player] ~= nil
end

function Source:_status(entry, stage, message, canCancel)
    if stage == entry.stage then return end
    entry.stage = stage
    if not entry.gone and self.entries[entry.player] == entry then
        self.io.status(entry.player, true, entry.expiresAt, stage, message, canCancel)
    end
end

function Source:_clear(entry, notice)
    if self.entries[entry.player] ~= entry then return end
    self.entries[entry.player] = nil
    self.count -= 1
    if not entry.gone then self.io.status(entry.player, false, entry.expiresAt, nil, notice, false) end
end

function Source:enroll(player, root)
    if self.entries[player] or not root or root ~= self.io.root(player, false) then return false, "Stand by the duel sign." end
    if self.count >= LOCAL_LIMIT then return false, "This server's matchmaking queue is full." end
    local now = self.io.now()
    local entry = {player = player, root = root, userId = player.UserId, generation = self.io.guid(),
        issuedAt = now, expiresAt = now + QUEUE_SECONDS}
    self.entries[player] = entry
    self.count += 1
    self:_status(entry, "enrolling", "Joining across-server Casual.", true)
    return true
end

function Source:eligible(player, seat, phase)
    local entry = self.entries[player]
    if not entry or entry.gone or entry.cancelled or entry.generation ~= seat.generation then return false end
    local paused = self.profiles:sourcePreparing(player, seat.transferId)
    if self.io.root(player, paused) ~= entry.root then return false end
    if phase == "transferring" then return self.profiles:sourceReady(player) == true end
    return phase ~= "queued" or not paused
end

function Source:cancel(player)
    local entry = self.entries[player]
    if not entry then return false end
    if entry.initiated then return true end
    entry.cancelled = true
    return true
end

function Source:removed(player)
    local entry = self.entries[player]
    if not entry then return end
    entry.gone = true
    local wasDispatched = self.driver:sourceRemoved(player)
    if wasDispatched then self:_clear(entry) else entry.cancelled = true end
end

function Source:failed(player, matchId, dispatch)
    local entry = self.entries[player]
    if not entry or entry.matchId ~= matchId or entry.dispatch ~= dispatch then return false end
    entry.failed = true
    return true
end

function Source:_enroll(entry, now)
    if not entry.observed then
        local last, reason = self.tickets:read(entry.userId)
        if reason then
            if now - entry.issuedAt >= ENROLL_SECONDS then self:_clear(entry, "Matchmaking is temporarily unavailable.") end
            return
        end
        entry.replaces = last and last.generation or nil
        entry.observed = true
    end
    if entry.cancelled and not entry.joinAttempted then
        self:_clear(entry, "You left the duel queue.")
        return
    end
    entry.joinAttempted = true
    local ticket, reason = self.tickets:join(entry.userId, self.io.jobId, entry.generation, entry.replaces, entry.issuedAt)
    if ticket then
        entry.enrolled = true
        self:_status(entry, "waiting", "Finding a Casual opponent across servers.", true)
    elseif reason ~= "unavailable" or now - entry.issuedAt >= ENROLL_SECONDS then
        local stored, readIssue = self.tickets:read(entry.userId)
        if stored and stored.generation == entry.generation then
            entry.enrolled = true
        elseif not readIssue or now >= entry.expiresAt then
            self:_clear(entry, "Could not join matchmaking. Try again or choose a local duel.")
        else
            entry.cancelled = true
            self:_status(entry, "recovering", "Checking whether matchmaking accepted your request.", false)
        end
    end
end

function Source:_abort(entry, reason)
    local assignment, issue = self.assignments:read(entry.matchId)
    if not assignment then return issue == nil end
    if assignment.phase == "aborted" then return true end
    if assignment.phase == "running" or assignment.phase == "finished" then return false end
    local dispatch
    for _, seat in assignment.seats do
        if seat.userId == entry.userId and seat.sourceJobId == self.io.jobId and seat.generation == entry.generation then
            dispatch = seat.dispatch
            break
        end
    end
    if entry.failed and dispatch then
        self.driver:failDeparture(entry.player, entry.matchId, dispatch)
        return false
    end
    local result = self.assignments:abortSource(entry.matchId, self.io.jobId, entry.userId, entry.generation, dispatch, reason)
    return result ~= nil
end

function Source:_recoverExpired(entry)
    if entry.gone or self.driver:recoverExpiredSource(entry.player, entry.matchId, entry.generation) then
        self:_clear(entry, "Match connection ended. You can queue again.")
    else
        self:_status(entry, "recovering", "Restoring your progress before you rejoin the queue.", false)
    end
end

function Source:_follow(entry, ticket, now)
    if not entry.matchId then
        if entry.cancelled or now >= entry.expiresAt then
            local closed = self.tickets:close(entry.userId, self.io.jobId, entry.generation)
            if closed or now >= entry.expiresAt then self:_clear(entry, "You left the duel queue.") end
        end
        return
    end
    local record = self.assignments:read(entry.matchId)
    if not record then
        if now >= entry.recoverAt then self:_recoverExpired(entry) end
        return
    end
    entry.recoverAt = record.deadline
    if record.phase == "aborted" then
        self.driver:cleanupTickets(record)
        if entry.gone or self.driver:resumeSource(entry.player, record.id, entry.generation) then
            self:_clear(entry, "Match connection ended. You can queue again.")
        else
            self:_status(entry, "recovering", "Restoring your progress before you rejoin the queue.", false)
        end
        return
    end
    if now >= record.deadline then
        local expired = self.assignments:expire(record.id)
        if expired and expired.phase == "aborted" then self.driver:cleanupTickets(expired) end
        self:_recoverExpired(entry)
        return
    end
    if record.phase == "running" or record.phase == "finished" then return end
    if entry.cancelled or entry.failed or not ticket or ticket.generation ~= entry.generation
        or ticket.state ~= "assigned" or ticket.matchId ~= record.id then
        self:_abort(entry, if entry.failed then "transport" else "cancelled")
        return
    end
    if record.phase == "pairing" then
        local confirmed = self.driver:confirmSource(entry.player, record.id, entry.generation)
        if confirmed and confirmed.seats[1].confirmed and confirmed.seats[2].confirmed then
            self.driver:reserve(record.id, record.id)
        end
        self:_status(entry, "preparing", "Opponent found. Preparing the Grand Dojo Ring.", true)
    elseif record.phase == "preparing" then
        local _, reason = self.driver:prepareSource(entry.player, record.id, entry.generation)
        if reason == "player unavailable" or reason == "invalid profile receipt" then self:_abort(entry, "profile") end
        if self.profiles:sourceBlocked(entry.player) then self:_abort(entry, "profile") end
    elseif record.phase == "traveling" and not entry.initiated then
        if self.profiles:sourceBlocked(entry.player) then
            self:_abort(entry, "profile")
            return
        end
        entry.dispatch = entry.dispatch or self.io.guid()
        local state, issue = self.driver:dispatch(entry.player, record.id, entry.generation, entry.dispatch)
        if issue == "transport failed" then entry.failed = true end
        if state == "initiated" then
            entry.initiated = true
            self:_status(entry, "traveling", "Traveling to the Grand Dojo Ring.", false)
        end
    end
end

function Source:_advance(entry, now)
    if not entry.initiated and not entry.gone and self.io.root(entry.player, self.profiles:sourcePaused(entry.player)) ~= entry.root then
        entry.cancelled = true
    end
    if not entry.enrolled then
        self:_enroll(entry, now)
        return
    end
    if entry.pair and not entry.cancelled then
        local result, reason = self.driver:pair(entry.pair.id, entry.pair.first, entry.pair.second, entry.pair.deadline)
        if result or reason ~= "unavailable" then entry.pair = nil end
    end
    local ticket, reason = self.tickets:read(entry.userId)
    if reason then
        if entry.matchId and now >= entry.recoverAt then
            self:_recoverExpired(entry)
        elseif not entry.matchId and now >= entry.expiresAt then
            self:_clear(entry, "The duel queue expired.")
        end
        return
    end
    if ticket and ticket.generation == entry.generation then
        if ticket.state == "assigned" and entry.matchId ~= ticket.matchId then
            entry.matchId, entry.recoverAt = ticket.matchId, entry.expiresAt + TRAVEL_SECONDS
        end
    elseif not entry.matchId then
        self:_clear(entry, "The duel queue expired.")
        return
    end
    if ticket and ticket.state == "closed" and not entry.matchId then
        self:_clear(entry, "You left the duel queue.")
        return
    end
    self:_follow(entry, ticket, now)
end

function Source:_search(now)
    -- Only scan when this job owns at least one live candidate.
    local waiting = false
    for _, entry in self.entries do
        if entry.enrolled and not entry.matchId and not entry.cancelled and not entry.pair then waiting = true break end
    end
    if not waiting then return end
    local page, cursor = self.tickets:list(PAGE_SIZE, self.searchCursor)
    if not page then return end
    self.searchCursor = cursor
    for _, first in page do
        if first.sourceJobId ~= self.io.jobId then continue end
        local player = self.io.player(first.userId)
        local entry = player and self.entries[player]
        if not entry or first.generation ~= entry.generation or entry.matchId or entry.cancelled or entry.pair then continue end
        for _, second in page do
            if second.sourceJobId ~= self.io.jobId and second.userId ~= first.userId then
                entry.pair = {id = self.io.guid(), first = first, second = second, deadline = now + TRAVEL_SECONDS}
                return
            end
        end
    end
end

function Source:tick()
    local now = self.io.now()
    for _, entry in self.entries do self:_advance(entry, now) end
    if now >= self.nextSearch then
        self.nextSearch = now + 2
        self:_search(now)
    end
end

return Source
