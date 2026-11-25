-- The match RemoteEvent delivers health and the effects for that snapshot together.
-- Players outside the match hear and see the same fresh effects through the world relay.
local Presentation = {}
local maximumEffectAge = .6

local function nextSequence(match)
    local sequence = (match.presentationSequence or 0) + 1
    match.presentationSequence = sequence
    return sequence
end

function Presentation.collect(match, cue, point, attack, at)
    if not match.pendingImpacts then
        match.pendingImpacts = {}
    end
    table.insert(match.pendingImpacts, {cue = cue, point = point, attack = attack, at = at})
end

function Presentation.snapshot(match)
    local impacts = match.pendingImpacts
    match.pendingImpacts = nil
    return {sequence = nextSequence(match), impacts = impacts}
end

function Presentation.resultSequence(match)
    return nextSequence(match)
end

function Presentation.broadcast(remote, snapshot, recipientUserIds)
    if snapshot.impacts then
        remote:FireAllClients("spectatorImpacts", snapshot.impacts, recipientUserIds)
    end
end

function Presentation.accept(state, kind, data)
    if type(data) ~= "table" then
        return false
    end
    local matchId, round, sequence = data.matchId, data.roundIndex or 1, data.presentationSequence
    if type(matchId) ~= "number" or type(round) ~= "number" or type(sequence) ~= "number" then
        return false
    end
    if kind == "begin" then
        if state.matchId and matchId <= state.matchId then
            return false
        end
    elseif state.closed or matchId ~= state.matchId or sequence <= state.sequence then
        return false
    elseif kind == "round" then
        if round <= state.round then
            return false
        end
    elseif round ~= state.round then
        return false
    end

    state.matchId, state.round, state.sequence = matchId, round, sequence
    state.closed = kind == "result"
    return true
end

function Presentation.playLocalContact(packet, now)
    if not packet then return end
    local storage = game:GetService("ReplicatedStorage")
    if packet.pose then
        require(storage:WaitForChild("CombatHitStop")).play(packet, now)
    end
    if packet.pulse then
        require(storage:WaitForChild("CombatCameraImpact")).play(packet, now)
    end
end

function Presentation.play(data, now, play)
    Presentation.playLocalContact(data.hitStop, now)
    if type(data.impacts) ~= "table" then
        return
    end
    for _, impact in data.impacts do
        if type(impact) == "table" and type(impact.at) == "number" and now - impact.at <= maximumEffectAge
            and impact.at - now <= .1 and type(impact.cue) == "string" and typeof(impact.point) == "Vector3" then
            play(impact.cue, impact.point, impact.attack)
        end
    end
end

return table.freeze(Presentation)
