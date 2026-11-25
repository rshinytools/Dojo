local Badger = require(script.Parent.HoneyBadgerCombatPoses)
local Saber = require(script.Parent.EmeraldSaberToothCombatPoses)
local Debris = game:GetService("Debris")
local Apex = {}

local function standard(poses, damage, techniques)
    local contacts = poses.Contact
    local moves = {
        jab = {{at = contacts.jab, damage = damage[1], zone = "head"}},
        cross = {{at = contacts.cross, damage = damage[2], zone = "body"}},
        body = {{at = contacts.body, damage = damage[3], zone = "body"}},
        heavy = {{at = contacts.heavy, damage = damage[4], zone = "body"}},
    }
    for _, id in techniques do
        local move = poses.Skill[id]
        moves[id] = {{at = contacts[id], damage = move.damage, radius = move.radius, zone = "body"}}
    end
    return moves
end

local frenzy = Badger.Skill.unstoppableFrenzy
local pounce = Saber.Skill.apexPounce
local badgerMoves = standard(Badger, {14, 15, 15, 23}, {"burrowHook", "copperKnuckle", "quarryBackhand"})
badgerMoves.unstoppableFrenzy = {}
for index, time in Badger.Contact.unstoppableFrenzy do
    badgerMoves.unstoppableFrenzy[index] = {
        at = time, damage = frenzy.damage[index], zone = "body", shape = "apexCone",
        radius = 3.32, halfAngle = math.rad(42), side = if index % 2 == 0 then -1 else 1,
    }
end

Apex.pounce = table.freeze({
    teleportAt = pounce.teleportAt, impactAt = Saber.Contact.apexPounce,
    radius = 2.82, gap = 2.35, duration = 1.20, rootDuration = .88, tint = Color3.fromRGB(143, 239, 158),
})
local saberMoves = standard(Saber, {15, 15, 17, 24}, {"jadeRake", "mossPalm", "emeraldProwl"})
saberMoves.apexPounce = {{at = Apex.pounce.impactAt, damage = pounce.damage, shape = "radial", apex = true,
    radius = Apex.pounce.radius, center = Vector3.zero, zone = "body"}}

Apex.kits = table.freeze({
    badger = {poses = Badger, clips = badgerMoves, mixedSpacing = 2.52,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .85,
        secondaryCooldown = 3.3, secondaryCooling = "burrowCooling",
        signature = "unstoppableFrenzy", signatureCooldown = 12, signatureCooling = "frenzyCooling",
        frenzyTime = frenzy.immunity},
    sabertooth = {poses = Saber, clips = saberMoves, mixedSpacing = 2.63,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .79,
        secondaryCooldown = 3.45, secondaryCooling = "jadeCooling",
        signature = "apexPounce", signatureCooldown = 9.3, signatureCooling = "apexCooling"},
})

Apex.shove = table.freeze({burrowHook = Badger.Skill.burrowHook.shove,
    jadeRake = Saber.Skill.jadeRake.shove, apexPounce = .51})

function Apex.unstoppable(side, at)
    return (side.frenzyFrom or math.huge) <= at and at < (side.frenzyUntil or 0)
end

function Apex.frenzyVisual(stored, side, model, parent, now)
    if stored or not Apex.unstoppable(side, now) then
        return stored
    end
    local outline = Instance.new("Highlight")
    outline.Name = "Frenzy armor"
    outline.Adornee, outline.DepthMode = model, Enum.HighlightDepthMode.Occluded
    outline.FillColor, outline.OutlineColor = Color3.fromRGB(220, 119, 44), Color3.fromRGB(255, 210, 124)
    outline.FillTransparency, outline.OutlineTransparency = .93, .34
    outline.Parent = parent
    Debris:AddItem(outline, side.frenzyUntil - now)
    return outline
end

function Apex.swipeFrame(root, move)
    local from = root:PointToWorldSpace(Vector3.new(0, .30, -.04))
    return from, (root * CFrame.Angles(0, move.side * .17, 0)).LookVector
end

function Apex.destination(origin, target, gap)
    gap = gap or Apex.pounce.gap
    local delta = Vector3.new(target.X - origin.X, 0, target.Z - origin.Z)
    if delta.Magnitude <= gap then
        return origin
    end
    return origin + delta.Unit * (delta.Magnitude - gap)
end

function Apex.face(origin, target, fallback)
    local delta = Vector3.new(target.X - origin.X, 0, target.Z - origin.Z)
    return CFrame.lookAlong(origin, if delta.Magnitude > .025 then delta.Unit else fallback.LookVector)
end

function Apex.zoneMoves()
    local skill = Apex.pounce
    local moves = {{at = skill.impactAt, marker = true, shape = "apexZone"}}
    for index = 1, 12 do
        moves[index + 1] = {at = skill.impactAt + (index - 1) * skill.duration / 12,
            shape = "apexZone", controlOnly = true, rootDuration = skill.rootDuration, radius = skill.radius, zone = "body"}
    end
    return moves
end

return table.freeze(Apex)
