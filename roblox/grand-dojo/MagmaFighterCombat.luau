local Armadillo = require(script.Parent.ArmadilloStrikerCombatPoses)
local Komodo = require(script.Parent.KomodoCombatPoses)
local Debris = game:GetService("Debris")
local Magma = {}

local function strikes(poses, jab, cross, body, heavy)
    return {
        jab = {{at = poses.Contact.jab, damage = jab, zone = "head"}},
        cross = {{at = poses.Contact.cross, damage = cross, zone = "body"}},
        body = {{at = poses.Contact.body, damage = body, zone = "body"}},
        heavy = {{at = poses.Contact.heavy, damage = heavy, zone = "body"}},
    }
end

local plate, roll = Armadillo.Skill.plateCheck, Armadillo.Skill.meteorRoll
local rake, breath = Komodo.Skill.tailRake, Komodo.Skill.volcanicBreath
local armadillo = strikes(Armadillo, 14, 15, 16, 24)
armadillo.plateCheck = {{at = Armadillo.Contact.plateCheck, damage = plate.damage, radius = plate.radius, zone = "body"}}
for _, id in {"rivetPalm", "kilnShoulder"} do
    local skill = Armadillo.Skill[id]
    armadillo[id] = {{at = Armadillo.Contact[id], damage = skill.damage, radius = skill.radius, zone = "body"}}
end
armadillo.meteorRoll = {}
for index = 1, 24 do
    local first, last = roll.rollSeconds * (index - 1) / 24, roll.rollSeconds * index / 24
    armadillo.meteorRoll[index] = {at = roll.windup + last, shape = "ricochet", from = first, to = last,
        damage = roll.damage, radius = roll.radius, guardBreak = true, zone = "body", singleHit = true}
end

local komodo = strikes(Komodo, 14, 15, 15, 23)
komodo.tailRake = {{at = Komodo.Contact.tailRake, damage = rake.damage, radius = rake.radius, foot = true, zone = "body"}}
local snap, heel = Komodo.Skill.ashenSnap, Komodo.Skill.cinderHeel
komodo.ashenSnap = {{at = Komodo.Contact.ashenSnap, damage = snap.damage, radius = snap.radius, zone = "head"}}
komodo.cinderHeel = {{at = Komodo.Contact.cinderHeel, damage = heel.damage, radius = heel.radius, foot = true, zone = "body"}}
komodo.volcanicBreath = {}
for index, sample in breath.samples do
    komodo.volcanicBreath[index] = {at = sample.age, shape = "breath", direction = sample.direction,
        mouth = Komodo.Impact.volcanicBreath[index], radius = breath.radius, halfAngle = breath.halfAngle,
        damage = breath.damage, burnDamage = breath.burnDamage, singleHit = true, zone = "body"}
end

Magma.kits = table.freeze({
    armadillo = {poses = Armadillo, clips = armadillo, mixedSpacing = 2.55,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = 1.02,
        signature = "meteorRoll", signatureCooldown = 8.8, signatureCooling = "meteorCooling",
        secondaryCooldown = 3.5, secondaryCooling = "plateCooling"},
    komodo = {poses = Komodo, clips = komodo, mixedSpacing = 2.59,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .86,
        signature = "volcanicBreath", signatureCooldown = 8.5, signatureCooling = "breathCooling",
        secondaryCooldown = 3.5, secondaryCooling = "rakeCooling"},
})
Magma.roll = roll
Magma.shove = table.freeze({plateCheck = plate.shove, meteorRoll = roll.shove, tailRake = rake.shove, volcanicBreath = breath.shove})

local tickGap = .32

function Magma.ignite(round, attacker, defender, target, at, damage)
    local burns = round.magmaBurns
    if not burns then
        burns = {}
        round.magmaBurns = burns
    end
    if not burns[defender] or burns[defender].target ~= target then
        burns[defender] = {attacker = attacker, target = target, nextAt = at + tickGap, ticks = 2, damage = damage}
    end
end

function Magma.nextBurn(round)
    if not round.magmaBurns then return math.huge end
    local at = math.huge
    for _, burn in round.magmaBurns do
        at = math.min(at, burn.nextAt)
    end
    return at
end

function Magma.burnsAt(round, at)
    local events = {}
    for defender, burn in round.magmaBurns or {} do
        if burn.nextAt == at then
            local target = if defender == 0 then round else round.sides[defender]
            if target ~= burn.target or target.eliminated then
                round.magmaBurns[defender] = nil
                continue
            end
            table.insert(events, {kind = "burn", attack = "volcanicBreath", source = "player",
                attacker = burn.attacker, defender = defender, at = at, damage = burn.damage})
            burn.ticks -= 1
            if burn.ticks == 0 then
                round.magmaBurns[defender] = nil
            else
                burn.nextAt += tickGap
            end
        end
    end
    return events
end

local function flat(vector)
    return Vector3.new(vector.X, 0, vector.Z)
end

function Magma.breathFrame(origin, move)
    return origin:PointToWorldSpace(move.mouth), flat(origin:VectorToWorldSpace(move.direction)).Unit
end

function Magma.breathHit(origin, direction, move, frame, size, nearest)
    local along = math.clamp((frame.Position - origin):Dot(direction), 0, move.radius)
    local point = nearest(frame, size, origin + direction * along)
    local delta = flat(point - origin)
    if math.abs(point.Y - origin.Y) <= 1.35 and delta.Magnitude <= move.radius
        and (delta.Magnitude < .03 or delta.Unit:Dot(direction) >= math.cos(move.halfAngle)) then
        return point
    end
    return nil
end

local function ribbon(parent, name, start, direction, length, width, tint, opacity)
    if length < .09 then
        return
    end
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch, part.CastShadow = true, false, false, false, false
    part.Material, part.Color, part.Transparency = Enum.Material.Neon, tint, opacity
    part.CFrame = CFrame.lookAlong(start + direction * (length * .5), direction)
    part.Size, part.Parent = Vector3.new(width, width * .60, length), parent
end

function Magma.presentBreath(cast, parent, floor, age, clipRay)
    local samples = komodo.volcanicBreath
    if age >= breath.warningAt and age < samples[1].at and not cast.warning then
        local guide = Instance.new("Folder")
        guide.Name, guide.Parent = "Volcanic Breath warning", parent
        cast.warning = guide
        for _, move in samples do
            local mouth, direction = Magma.breathFrame(cast.origin, move)
            local base = Vector3.new(mouth.X, floor + .055, mouth.Z)
            ribbon(guide, "Breath sweep direction", base, direction, clipRay(mouth, direction, move.radius),
                .16, Color3.fromRGB(255, 161, 87), .50)
        end
    end
    local index = cast.pulse or 1
    while samples[index] and age >= samples[index].at do
        if cast.warning then
            cast.warning:Destroy()
            cast.warning = nil
        end
        local move = samples[index]
        local mouth, direction = Magma.breathFrame(cast.origin, move)
        local burst = Instance.new("Folder")
        burst.Name, burst.Parent = "Volcanic Breath pulse", parent
        local frame = CFrame.lookAlong(Vector3.zero, direction)
        for side = -1, 1 do
            local ray = (frame * CFrame.Angles(0, side * move.halfAngle * .76, 0)).LookVector
            ribbon(burst, "Volcanic stream", mouth + Vector3.new(0, side * .13, 0), ray,
                clipRay(mouth, ray, move.radius), if side == 0 then .42 else .24,
                if index == 2 then Color3.fromRGB(255, 211, 125) else Color3.fromRGB(255, 135, 65), .22)
        end
        Debris:AddItem(burst, .19)
        index += 1
    end
    cast.pulse = index
end

return table.freeze(Magma)
