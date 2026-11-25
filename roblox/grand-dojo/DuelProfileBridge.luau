-- An in-server mailbox. Only serveProgress may use the DataStore lease token.
local Bridge = {}
Bridge.__index = Bridge

function Bridge.new(now, hold)
    return setmetatable({now = now, hold = hold, sessions = {}}, Bridge)
end

function Bridge:register(player, role)
    if not self.sessions[player] then
        self.sessions[player] = {phase = if role == "city" then "city" else "arrival", sequence = 0}
        if role ~= "city" then self.hold(player, true) end
    end
end

function Bridge:classifyCity(player)
    local session = self.sessions[player]
    if not session or session.phase ~= "arrival" or session.acceptAttempted or session.request then return false end
    session.phase = "city"
    self.hold(player, false)
    return true
end

function Bridge:request(player, action, transferId, route, deadline)
    local session = self.sessions[player]
    if not session then return nil, "worker unavailable" end
    local current = session.request
    if current and current.action == action and current.id == transferId and current.route == route
        and (action ~= "prepare" or current.deadline == deadline) then
        return current.profile, current.reason or (if current.profile then nil else "pending")
    end
    if (action == "prepare" or action == "accept") and (type(deadline) ~= "number" or deadline <= self.now()) then
        return nil, "expired"
    end
    if action == "prepare" and session.phase == "city" then
        session.sequence += 1
        session.phase = "draining"
        self.hold(player, true)
    elseif action == "return" and (session.phase == "arena" or session.phase == "arrival") then
        session.phase = "drainingReturn"
        self.hold(player, true)
    elseif action == "resume" and (session.phase == "draining" or session.phase == "outbound"
        or (session.phase == "city" and current and current.action == "prepare")) then
        local prepared = session.prepared or current
        if not prepared or prepared.id ~= transferId or prepared.route ~= route then return nil, "stale handoff" end
        deadline = prepared.deadline
    elseif action ~= "accept" or session.phase ~= "arrival" or session.request then
        return nil, "worker busy"
    end
    session.request = {action = action, id = transferId, route = route, deadline = deadline}
    return nil, "pending"
end

function Bridge:ownsOutbound(player)
    local session = self.sessions[player]
    return session ~= nil and (session.phase == "outbound" or session.phase == "returning" or session.phase == "released")
end

function Bridge:sourcePaused(player)
    local session = self.sessions[player]
    return session ~= nil and (session.phase == "draining" or session.phase == "outbound")
end

function Bridge:sourcePreparing(player, transferId)
    local session = self.sessions[player]
    local operation = session and session.request
    return self:sourcePaused(player) and operation ~= nil and operation.action == "prepare" and operation.id == transferId
end

function Bridge:sourceBlocked(player)
    local session = self.sessions[player]
    return session ~= nil and session.lateReceipt == true
end

function Bridge:receiptQueued(player)
    local session = self.sessions[player]
    if session and session.phase == "outbound" then session.lateReceipt = true end
end

function Bridge:sourceReady(player)
    local session = self.sessions[player]
    return session ~= nil and session.phase == "outbound" and session.prepared and session.prepared.profile ~= nil
        and not session.lateReceipt and self.now() < session.prepared.deadline and session.request == session.prepared
end

function Bridge:arenaReady(player)
    local session = self.sessions[player]
    return session ~= nil and session.phase == "arena"
end

function Bridge:acceptAttempted(player)
    local session = self.sessions[player]
    return session ~= nil and session.acceptAttempted == true
end

function Bridge:forget(player)
    self.sessions[player] = nil
end

-- Returns whether to skip ordinary loading/saving, then a newly confirmed profile when one is available.
function Bridge:step(player, profiles, token, profile, pending)
    local session = self.sessions[player]
    if not session then return false end
    local current = session.request
    if not current or current.profile then
        return session.phase == "arrival" or session.phase == "outbound" or session.phase == "released"
    end
    local phase, now = session.phase, self.now()
    if current.action == "return" then
        if phase == "drainingReturn" and pending then return false end
        session.phase = "returning"
        local released, reason = profiles:releaseMatchReturn(player.UserId, token, current.id)
        if released or reason == "ownership" then
            current.profile, current.reason = true, nil
            session.phase = "released"
        else
            current.reason = reason
        end
        return true
    elseif current.action == "prepare" then
        if phase == "draining" and now >= current.deadline then
            current.reason = "expired"
            session.phase = "city"
            self.hold(player, false)
            return false
        end
        if phase == "draining" and (pending or not profile) then return false end
        session.phase, session.prepared = "outbound", current
        if now >= current.deadline then
            current.reason = "expired"
            return true
        end
        local confirmed, reason = profiles:prepareMatchHandoff(player.UserId, token, current.id, current.route,
            session.sequence, current.deadline)
        if session.request == current then current.profile, current.reason = confirmed, reason end
        return true
    elseif current.action == "resume" then
        local restored, reason
        if phase == "draining" or phase == "city" then
            restored = profile
            if not restored then restored, reason = profiles:open(player.UserId, token) end
        else
            if now < current.deadline then
                restored, reason = profiles:cancelMatchHandoff(player.UserId, token, current.id, current.route)
            end
            if now >= current.deadline or reason == "stale handoff" then
                restored, reason = profiles:open(player.UserId, token)
            end
        end
        current.profile, current.reason = restored, reason
        if restored then
            session.phase, session.prepared, session.lateReceipt = "city", nil, nil
            self.hold(player, false)
        end
        return true, restored
    elseif current.action == "accept" then
        if now >= current.deadline then
            current.reason = "expired"
            return true
        end
        session.acceptAttempted = true
        local accepted, reason = profiles:acceptMatchHandoff(player.UserId, token, current.id, current.route)
        current.profile, current.reason = accepted, reason
        if accepted then session.phase = "arena" end
        return true, accepted
    end
    return false
end

return Bridge
