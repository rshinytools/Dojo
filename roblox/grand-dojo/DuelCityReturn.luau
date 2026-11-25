-- Only server-authorized terminal arena states can create a City return entry.
local Return = {}
Return.__index = Return

local RELEASE_SECONDS = 12
local ARRIVAL_SECONDS = 18

function Return.new(io)
    return setmetatable({io = io, entries = {}}, Return)
end

function Return:_status(entry, phase, message)
    entry.phase = phase
    self.io.status(entry.player, phase, message)
end

function Return:offer(player, recapSeconds)
    if self.entries[player] or not self.io.present(player) then return false end
    local when = self.io.now() + recapSeconds
    local entry = {player = player, id = self.io.guid(), at = when, releaseUntil = when + RELEASE_SECONDS}
    self.entries[player] = entry
    self:_status(entry, "waiting", "Return to Grand Dojo City.")
    return true
end

function Return:retry(player)
    local entry = self.entries[player]
    if not entry then return false end
    if entry.phase == "failed" or entry.phase == "waiting" then
        entry.at = self.io.now()
        entry.releaseUntil = entry.at + RELEASE_SECONDS
        self:_status(entry, "waiting", "Returning to Grand Dojo City.")
    end
    return true
end

function Return:failure(player, dispatch)
    local entry = self.entries[player]
    if not entry or not dispatch or entry.dispatch ~= dispatch
        or (entry.phase ~= "launching" and entry.phase ~= "sent") then return false end
    self:_status(entry, "failed", "Could not return. Try again.")
    return true
end

function Return:remove(player)
    self.entries[player] = nil
end

function Return:tick()
    local now = self.io.now()
    for player, entry in self.entries do
        if not self.io.present(player) then
            self:remove(player)
        elseif entry.phase == "sent" and now >= entry.confirmUntil then
            self:_status(entry, "failed", "Still in the arena. Try returning again.")
        elseif entry.phase == "waiting" and now >= entry.at then
            local released = self.io.release(player, entry.id)
            if not released then
                if now >= entry.releaseUntil then self:_status(entry, "failed", "Progress is still saving. Try again.") end
                continue
            end
            if not self.io.present(player) or self.entries[player] ~= entry then continue end
            entry.dispatch = self.io.guid()
            self:_status(entry, "launching", "Returning to Grand Dojo City.")
            local ok, result = pcall(self.io.teleport, player, entry.dispatch)
            if entry.phase == "launching" then
                if ok and result ~= false then
                    entry.confirmUntil = self.io.now() + ARRIVAL_SECONDS
                    self:_status(entry, "sent", "Connecting to Grand Dojo City.")
                else
                    self:failure(player, entry.dispatch)
                end
            end
        end
    end
end

return Return
