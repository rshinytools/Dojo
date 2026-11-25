local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("CombatWindupRemote")

local Windup = {}
local shoulders = {"Left Shoulder", "Right Shoulder"}
local maximumToken = 2147483647

local function fighterShell(actor)
    local character = actor.root.Parent
    if character and character == actor.player.Character then
        return character:FindFirstChild("Starter Fighter Shell")
    end
    return nil
end

function Windup.profile(actor, side, motors, startsAt, endsAt)
    if side.playerHealth <= 0 or not motors then return end
    local shell = fighterShell(actor)
    local previous = actor.windupProfile
    if not shell or (previous and previous.shell == shell and previous.startsAt == startsAt) then
        return
    end

    local heavy = side.kit.clips.heavy
    local contact = heavy and heavy[1] and heavy[1].at
    if not contact or contact <= .14 then return end
    local offsets = side.kit.poses.sample("heavy", .14)
    local pose = {}
    for _, name in shoulders do
        local binding = motors[name]
        if not binding or not offsets[name] then return end
        pose[name] = offsets[name] * binding.rest
    end

    actor.windupProfile = {shell = shell, startsAt = startsAt}
    remote:FireClient(actor.player, "profile", {shell = shell, startsAt = startsAt,
        endsAt = endsAt, contact = contact, pose = pose})
end

function Windup.decide(actor, side, startsAt, token, previousClip, now)
    if type(token) ~= "number" or not (token >= 1 and token <= maximumToken and token % 1 == 0) then return end
    local shell = fighterShell(actor)
    local profile = actor.windupProfile
    if not shell or not profile or profile.shell ~= shell or profile.startsAt ~= startsAt then return end

    local clip = side.clip
    local accepted = clip and clip ~= previousClip and clip.action == "heavy" and clip.startedAt == now
    local busyUntil = math.max(side.playerStunUntil or 0, if clip then clip.endsAt else 0)
    remote:FireClient(actor.player, "decision", {shell = shell, startsAt = startsAt, token = token,
        acceptedAt = if accepted then clip.startedAt else nil, busyUntil = if busyUntil > now then busyUntil else nil})
end

return table.freeze(Windup)
