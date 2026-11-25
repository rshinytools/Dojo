local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("CombatWindupRemote")
local Combatant = require(script.Parent.ReedguardRound).Combatant

local Windup = {}
local shoulders = {"Left Shoulder", "Right Shoulder"}
local maximumToken = 2147483647
local shellSwapGrace = .06

local function fighterShell(actor)
    local character = actor.root.Parent
    if character and character == actor.player.Character then
        return character:FindFirstChild("Starter Fighter Shell")
    end
    return nil
end

local function poseSample(kit, motors, action, age)
    local clips = kit.clips[action]
    local contact = clips and clips[1] and clips[1].at
    if not contact or contact <= age then return nil end
    local offsets = kit.poses.sample(action, age)
    local pose = {}
    for _, name in shoulders do
        local binding = motors[name]
        if not binding or not offsets[name] then return nil end
        pose[name] = offsets[name] * binding.rest
    end
    return {contact = contact, pose = pose}
end

function Windup.profile(actor, side, motors, startsAt, endsAt, now)
    if side.playerHealth <= 0 or not motors then return end
    local shell = fighterShell(actor)
    if not shell then return end
    local previous = actor.windupProfile
    if previous and previous.startsAt == startsAt then
        if previous.shell ~= shell then
            -- Let the newly mounted Tag Team shell replicate before sending its profile.
            actor.windupProfile = {shell = shell, startsAt = startsAt, sendAfter = now + shellSwapGrace}
            return
        elseif not previous.sendAfter then
            if previous.jabReadyAt ~= nil then
                local readyAt = math.max(startsAt, Combatant.jabReadyAt(side))
                if readyAt ~= previous.jabReadyAt then
                    previous.jabReadyAt = readyAt
                    remote:FireClient(actor.player, "readiness", {shell = shell, startsAt = startsAt, jabReadyAt = readyAt})
                end
            end
            return
        elseif now < previous.sendAfter then
            return
        end
    end

    local heavy = poseSample(side.kit, motors, "heavy", .14)
    if not heavy then return end
    local jab = poseSample(side.kit, motors, "jab", .065)
    if jab then
        jab.readyAt = math.max(startsAt, Combatant.jabReadyAt(side))
        jab.duration = side.kit.poses.Duration.jab
    end

    actor.windupProfile = {shell = shell, startsAt = startsAt, jabReadyAt = jab and jab.readyAt}
    remote:FireClient(actor.player, "profile", {shell = shell, startsAt = startsAt,
        endsAt = endsAt, contact = heavy.contact, pose = heavy.pose, jab = jab})
end

function Windup.decide(actor, side, startsAt, token, previousClip, now, action)
    if type(token) ~= "number" or not (token >= 1 and token <= maximumToken and token % 1 == 0) then return end
    local expected = if action == "strike" then "jab" elseif action == "heavy" then "heavy" else nil
    if not expected then return end
    local shell = fighterShell(actor)
    local profile = actor.windupProfile
    if not shell or not profile or profile.shell ~= shell or profile.startsAt ~= startsAt or profile.sendAfter then return end

    local clip = side.clip
    local accepted = clip and clip ~= previousClip and clip.action == expected and clip.startedAt == now
    local busyUntil = math.max(side.playerStunUntil or 0, if clip then clip.endsAt else 0)
    remote:FireClient(actor.player, "decision", {shell = shell, startsAt = startsAt, token = token, action = expected,
        acceptedAt = if accepted then clip.startedAt else nil, busyUntil = if busyUntil > now then busyUntil else nil})
end

return table.freeze(Windup)
