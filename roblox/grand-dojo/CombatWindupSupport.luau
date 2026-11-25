local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("CombatWindupRemote")
local Combatant = require(script.Parent.ReedguardRound).Combatant

local Windup = {}
local shoulders = {"Left Shoulder", "Right Shoulder"}
local maximumToken = 2147483647
local generationAttribute = "CombatWindupGeneration"
local generation = 0

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

function Windup.profile(actor, side, motors, startsAt, endsAt)
    if side.playerHealth <= 0 or not motors then return end
    local shell = fighterShell(actor)
    if not shell then return end
    local previous = actor.windupProfile
    if previous and previous.startsAt == startsAt and previous.shell == shell then
        if previous.jabReadyAt ~= nil then
            local readyAt = math.max(startsAt, Combatant.jabReadyAt(side))
            if readyAt ~= previous.jabReadyAt then
                previous.jabReadyAt = readyAt
                remote:FireClient(actor.player, "readiness", {shell = shell, startsAt = startsAt,
                    generation = previous.generation, jabReadyAt = readyAt})
            end
        end
        return
    end

    local heavy = poseSample(side.kit, motors, "heavy", .14)
    if not heavy then return end
    local opener = Combatant.firstLight(side)
    local jab = poseSample(side.kit, motors, opener, .065)
    if jab then
        jab.action = opener
        jab.readyAt = math.max(startsAt, Combatant.jabReadyAt(side))
        jab.duration = side.kit.poses.Duration[opener]
    end

    -- The marker identifies the intended shell even when Roblox delivers a nil Instance reference.
    generation += 1
    shell:SetAttribute(generationAttribute, generation)
    actor.windupProfile = {shell = shell, startsAt = startsAt, generation = generation, jabReadyAt = jab and jab.readyAt}
    remote:FireClient(actor.player, "profile", {shell = shell, startsAt = startsAt, generation = generation,
        endsAt = endsAt, contact = heavy.contact, pose = heavy.pose, jab = jab})
end

function Windup.decide(actor, side, startsAt, token, previousClip, now, action)
    if type(token) ~= "number" or not (token >= 1 and token <= maximumToken and token % 1 == 0) then return end
    local expected = if action == "strike" then Combatant.firstLight(side) elseif action == "heavy" then "heavy" else nil
    if not expected then return end
    local shell = fighterShell(actor)
    local profile = actor.windupProfile
    if not shell or not profile or profile.shell ~= shell or profile.startsAt ~= startsAt then return end

    local clip = side.clip
    local accepted = clip and clip ~= previousClip and clip.action == expected and clip.startedAt == now
    local busyUntil = math.max(side.playerStunUntil or 0, if clip then clip.endsAt else 0)
    remote:FireClient(actor.player, "decision", {shell = shell, startsAt = startsAt, generation = profile.generation,
        token = token, action = expected, acceptedAt = if accepted then clip.startedAt else nil,
        busyUntil = if busyUntil > now then busyUntil else nil})
end

return table.freeze(Windup)
