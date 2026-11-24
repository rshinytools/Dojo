local Rules = require(script.Parent:WaitForChild("DuelRankRules"))

local Ledger = {}
Ledger.__index = Ledger

local VERSION = 1
local MATCH_SECONDS = 240
local MAX_POINTS = Rules.MaximumRating
local MAX_GAMES = 9e15

local function whole(value, low, high)
    return type(value) == "number" and value >= low and value <= high and value % 1 == 0
end

local function userId(value)
    return whole(value, 1, 9e15)
end

local function matchId(value)
    return type(value) == "string" and #value <= 40 and value:match("^[%w_%-]+$") ~= nil
end

local function validUsers(users)
    return type(users) == "table" and userId(users[1]) and userId(users[2]) and users[1] ~= users[2]
end

local function validRatings(points)
    return type(points) == "table" and whole(points[1], 0, MAX_POINTS) and whole(points[2], 0, MAX_POINTS)
end

local function samePair(a, b)
    return a[1] == b[1] and a[2] == b[2]
end

local function validScore(score)
    return score == 0 or score == .5 or score == 1
end

local function playerKey(id)
    return string.format("p_%.0f", id)
end

local function matchKey(id)
    return "m_" .. id
end

local function playerRecord(profile)
    return type(profile) == "table" and profile.version == VERSION
        and whole(profile.points, 0, MAX_POINTS) and whole(profile.games, 0, MAX_GAMES)
        and (profile.pending == nil or matchId(profile.pending))
end

local function newPlayer()
    return {version = VERSION, points = Rules.StartingRating, games = 0}
end

local function journalRecord(journal)
    if type(journal) ~= "table" or journal.version ~= VERSION or not validUsers(journal.users)
        or not whole(journal.expiresAt, 1, 1e12) or (journal.before ~= nil and not validRatings(journal.before)) then
        return false
    end
    if journal.state == "open" or journal.state == "cancelled" then
        return journal.after == nil and journal.score == nil
    end
    return journal.state == "committed" and validRatings(journal.before) and validRatings(journal.after)
        and validScore(journal.score)
end

function Ledger.new(store, unixClock, wait)
    return setmetatable({store = store, clock = unixClock, wait = wait}, Ledger)
end

-- Studio uses an isolated in-memory store with the same UpdateAsync interface.
function Ledger.memoryStore()
    local records = {}
    return {
        UpdateAsync = function(_, key, transform)
            local replacement = transform(records[key])
            if replacement ~= nil then
                records[key] = replacement
            end
            return replacement
        end,
    }
end

function Ledger:_transact(key, attachedUsers, transition)
    for attempt = 1, 3 do
        local reply, reason
        local ok = pcall(self.store.UpdateAsync, self.store, key, function(current, info)
            local replacement
            replacement, reply, reason = transition(current)
            if replacement == nil then
                return nil
            end
            return replacement, attachedUsers, if info then info:GetMetadata() else nil
        end)
        if ok then
            return reply, reason
        end
        if attempt < 3 then
            self.wait(.22 * 2 ^ (attempt - 1) + math.random() * .13)
        end
    end
    return nil, "unavailable"
end

function Ledger:_journal(id)
    return self:_transact(matchKey(id), nil, function(current)
        if not journalRecord(current) then
            return nil, nil, "invalid"
        end
        return nil, current
    end)
end

function Ledger:_close(id, users, force)
    return self:_transact(matchKey(id), users, function(current)
        if not journalRecord(current) or not samePair(current.users, users) then
            return nil, nil, "invalid"
        end
        if current.state ~= "open" then
            return nil, current
        end
        if not force and self.clock() < current.expiresAt then
            return nil, nil, "pending"
        end
        local changed = table.clone(current)
        changed.state = "cancelled"
        return changed, changed
    end)
end

function Ledger:_materialize(id, journal, side)
    local user = journal.users[side]
    return self:_transact(playerKey(user), {user}, function(current)
        if current == nil and journal.state == "cancelled" then
            return nil, newPlayer()
        end
        if not playerRecord(current) then
            return nil, nil, "invalid"
        end
        if current.pending ~= id then
            return nil, current
        end
        local changed = table.clone(current)
        if journal.state == "committed" then
            if current.points ~= journal.before[side] then
                return nil, nil, "invalid"
            end
            changed.points = journal.after[side]
            changed.games = math.min(MAX_GAMES, current.games + 1)
        end
        -- Clearing this claim atomically with the rating change is the receipt.
        -- A later match can claim the player without making an older commit replayable.
        changed.pending = nil
        return changed, changed
    end)
end

function Ledger:_recover(user, id)
    local journal, reason = self:_journal(id)
    if not journal then
        return nil, reason
    end
    local side = if journal.users[1] == user then 1 elseif journal.users[2] == user then 2 else nil
    if not side then
        return nil, "invalid"
    end
    if journal.state == "open" then
        if self.clock() < journal.expiresAt then
            return nil, "pending"
        end
        journal, reason = self:_close(id, journal.users, false)
        if not journal then
            return nil, reason
        end
    end
    return self:_materialize(id, journal, side)
end

function Ledger:read(user)
    if not userId(user) then
        return nil, "invalid"
    end
    local profile, reason = self:_transact(playerKey(user), nil, function(current)
        if current == nil then
            return nil, newPlayer()
        end
        if not playerRecord(current) then
            return nil, nil, "invalid"
        end
        return nil, current
    end)
    if profile and profile.pending then
        profile, reason = self:_recover(user, profile.pending)
    end
    if not profile then
        return nil, reason
    end
    if profile.pending then
        return nil, "pending"
    end
    return {points = profile.points, games = profile.games}
end

function Ledger:_claim(user, id, expiresAt)
    local attached = {user}
    local key = playerKey(user)
    local function claim(current)
        if self.clock() >= expiresAt then
            return nil, nil, "expired"
        end
        local profile = if current == nil then newPlayer() else current
        if not playerRecord(profile) then
            return nil, nil, "invalid"
        end
        if profile.pending then
            if profile.pending == id then
                return nil, profile
            end
            return nil, profile, "pending"
        end
        local changed = table.clone(profile)
        changed.pending = id
        return changed, changed
    end
    local profile, reason = self:_transact(key, attached, claim)
    if reason == "pending" and profile then
        local recovered
        recovered, reason = self:_recover(user, profile.pending)
        if not recovered then
            return nil, reason
        end
        profile, reason = self:_transact(key, attached, claim)
    end
    if not profile or reason then
        return nil, reason
    end
    return profile.points
end

local function ticketFor(id, journal)
    return {
        id = id, users = table.clone(journal.users), before = table.clone(journal.before), expiresAt = journal.expiresAt,
    }
end

function Ledger:reserve(id, first, second)
    local users = {first, second}
    if not matchId(id) or not validUsers(users) then
        return nil, "invalid"
    end
    local journal, reason = self:_transact(matchKey(id), users, function(current)
        if current == nil then
            local made = {version = VERSION, state = "open", users = users, expiresAt = self.clock() + MATCH_SECONDS}
            return made, made
        end
        if not journalRecord(current) or not samePair(current.users, users) then
            return nil, nil, "invalid"
        end
        if current.state ~= "open" then
            return nil, nil, current.state
        end
        if self.clock() >= current.expiresAt then
            return nil, nil, "expired"
        end
        return nil, current
    end)
    if not journal then
        return nil, reason
    elseif journal.before then
        return ticketFor(id, journal)
    end

    local points = {}
    local lower = if first < second then 1 else 2
    for _, side in {lower, 3 - lower} do
        points[side], reason = self:_claim(users[side], id, journal.expiresAt)
        if points[side] == nil then
            self:cancel({id = id, users = users})
            return nil, reason
        end
    end

    journal, reason = self:_transact(matchKey(id), users, function(current)
        if not journalRecord(current) or not samePair(current.users, users) then
            return nil, nil, "invalid"
        end
        if current.state ~= "open" then
            return nil, nil, current.state
        end
        if self.clock() >= current.expiresAt then
            return nil, nil, "expired"
        end
        if current.before then
            return nil, current
        end
        local ready = table.clone(current)
        ready.before = points
        return ready, ready
    end)
    if not journal then
        self:cancel({id = id, users = users})
        return nil, reason
    end
    return ticketFor(id, journal)
end

function Ledger:commit(ticket, score)
    if type(ticket) ~= "table" or not matchId(ticket.id) or not validUsers(ticket.users)
        or not validRatings(ticket.before) or not validScore(score) then
        return nil, "invalid"
    end
    local id, users = ticket.id, ticket.users
    local journal, reason = self:_transact(matchKey(id), users, function(current)
        if not journalRecord(current) or not samePair(current.users, users) or not current.before
            or not samePair(current.before, ticket.before) then
            return nil, nil, "invalid"
        end
        if current.state == "committed" then
            if current.score ~= score then
                return nil, nil, "conflict"
            end
            return nil, current
        elseif current.state == "cancelled" then
            return nil, nil, "cancelled"
        elseif self.clock() >= current.expiresAt then
            return nil, nil, "expired"
        end
        local changed = table.clone(current)
        changed.after = {Rules.elo(current.before[1], current.before[2], score)}
        if not validRatings(changed.after) then
            return nil, nil, "invalid"
        end
        changed.state, changed.score = "committed", score
        return changed, changed
    end)
    if not journal then
        return nil, reason
    end

    local saved
    saved, reason = self:_materializeBoth(id, journal)
    if not saved then
        return nil, reason
    end
    local reports = {}
    for side, before in journal.before do
        local after = journal.after[side]
        reports[side] = {before = before, after = after, delta = after - before}
    end
    return reports
end

function Ledger:_materializeBoth(id, journal)
    local first, firstError = self:_materialize(id, journal, 1)
    local second, secondError = self:_materialize(id, journal, 2)
    if not first or not second then
        return nil, if firstError == "invalid" or secondError == "invalid" then "invalid" else "pending"
    end
    return true
end

function Ledger:cancel(ticket)
    if type(ticket) ~= "table" or not matchId(ticket.id) or not validUsers(ticket.users) then
        return nil, "invalid"
    end
    local journal, reason = self:_close(ticket.id, ticket.users, true)
    if not journal then
        return nil, reason
    end
    local saved
    saved, reason = self:_materializeBoth(ticket.id, journal)
    if not saved then
        return nil, reason
    end
    if journal.state == "committed" then
        return nil, "committed"
    end
    return true
end

return Ledger
