local Eagle = require(script.Parent.GoldenEagleCombatPoses)
local Dragon = require(script.Parent.CelestialStormDragonCombatPoses)
local Match = require(script.Parent.DojoMatchSupport)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Storm = {}
local talon = table.clone(Eagle.Skill.talonDrop)
talon.bossDamage = 22
Storm.talon = table.freeze(talon)
local tempest = Dragon.Skill.tempestRoar
Storm.tempest = tempest
local carryAction, aimAction = "talonDrop", "tempestRoar"
local gold = Color3.fromRGB(255, 210, 102)
local violet = Color3.fromRGB(165, 131, 255)
local blue = Color3.fromRGB(143, 224, 255)
local white = Color3.fromRGB(232, 250, 255)

local function strikes(poses, damage, secondary)
    local at, move = poses.Contact, poses.Skill[secondary]
    return {
        jab = {{at = at.jab, damage = damage[1], zone = "head"}},
        cross = {{at = at.cross, damage = damage[2], zone = "body"}},
        body = {{at = at.body, damage = damage[3], zone = "body"}},
        heavy = {{at = at.heavy, damage = damage[4], zone = "body"}},
        [secondary] = {{at = at[secondary], damage = move.damage, radius = move.radius, zone = "body"}},
    }
end

local eagle = strikes(Eagle, {14, 16, 17, 24}, "galeRake")
eagle[carryAction] = {
    {at = talon.grabAt, shape = "talonGrab", radius = talon.grabRadius, damage = 0, zone = "body"},
    {at = talon.impactAt, shape = "talonThrow", damage = talon.damage, zone = "body", silentMiss = true},
}
local dragon = strikes(Dragon, {14, 16, 18, 25}, "stormClaw")
dragon[aimAction] = {}
for _, at in tempest.beamBeats do
    table.insert(dragon[aimAction], {at = at, shape = "stormBeam", radius = tempest.beamRadius,
        damage = tempest.beamDamage, zone = "body", detached = true, silentMiss = true})
end
table.insert(dragon[aimAction], {at = tempest.thunderAt, shape = "stormThunder", radius = tempest.thunderRadius,
    damage = tempest.thunderDamage, zone = "body", detached = true, silentMiss = true})
table.sort(dragon[aimAction], function(a, b) return a.at < b.at end)

Storm.kits = table.freeze({
    eagle = {poses = Eagle, clips = eagle, mixedSpacing = 2.57, dodge = "sidestep", dodgeCue = "dodge",
        dodgeCooldown = .79, secondary = "galeRake", secondaryCooldown = 3.32, secondaryCooling = "galeCooling",
        signature = carryAction, signatureCooldown = 10.7, signatureCooling = "talonCooling"},
    dragon = {poses = Dragon, clips = dragon, mixedSpacing = 2.72, dodge = "sidestep", dodgeCue = "dodge",
        dodgeCooldown = .96, secondary = "stormClaw", secondaryCooldown = 3.65, secondaryCooling = "clawCooling",
        signature = aimAction, signatureCooldown = 12, signatureCooling = "tempestCooling"},
})
Storm.shove = table.freeze({galeRake = Eagle.Skill.galeRake.shove, stormClaw = Dragon.Skill.stormClaw.shove})

function Storm.isCast(action)
    return action == carryAction or action == aimAction
end

function Storm.held(side, at)
    local hold = side.talonHold
    if hold and at <= hold.endsAt and hold.attacker.clip == hold.clip and not hold.attacker.eliminated
        and hold.attacker.playerHealth > 0 and side.playerHealth > 0 and not side.eliminated then
        return hold
    end
    return nil
end

function Storm.latch(attacker, defender, target, at)
    local clip = attacker.clip
    if not clip or clip.action ~= carryAction or clip.talonTarget or attacker.playerHealth <= 0
        or attacker.eliminated or defender.eliminated or defender.playerHealth <= 0
        or Storm.held(attacker, at) or Storm.held(defender, at) then
        return false
    end
    clip.talonTarget = target
    defender.talonHold = {attacker = attacker, clip = clip, endsAt = clip.startedAt + talon.impactAt}
    defender.clip, defender.guardUntil, defender.bufferedLight = nil, 0, false
    return true
end

local function yawAt(clip, at)
    for index = #(clip.steering or {}), 1, -1 do
        local input = clip.steering[index]
        if input.at <= at then
            local elapsed = math.min(at, clip.startedAt + tempest.channelEnd) - input.at
            return math.clamp(input.yaw + input.direction * tempest.steerRate * math.max(0, elapsed),
                -tempest.maxYaw, tempest.maxYaw)
        end
    end
    return 0
end

function Storm.steer(clip, direction, at)
    if not clip or clip.action ~= aimAction or at < clip.startedAt or at > clip.startedAt + tempest.channelEnd
        or (direction ~= -1 and direction ~= 0 and direction ~= 1) then
        return
    end
    clip.steering = clip.steering or {}
    local prior = clip.steering[#clip.steering]
    if prior and (at - prior.receivedAt < .045 or prior.direction == direction) then return end
    local atStart = math.max(at, clip.startedAt + tempest.aimAt)
    table.insert(clip.steering, {at = atStart, receivedAt = at, yaw = yawAt(clip, atStart), direction = direction})
end

function Storm.begin(action, arena, origin, clip)
    local sector = if action == aimAction then math.random() * math.pi * 2 else nil
    return {action = action, arena = arena, origin = origin, clip = clip, thunderSector = sector}
end

function Storm.aim(cast, at)
    local yaw = yawAt(cast.clip, at)
    return cast.origin * CFrame.Angles(0, -yaw, 0), yaw
end

local function insideBeamEnd(bounds, from, to)
    local start = bounds.CFrame:PointToObjectSpace(from)
    local delta = bounds.CFrame:VectorToObjectSpace(to - from)
    local function boundAxis(position, travel, half)
        if math.abs(travel) < .005 then return 1 end
        return ((if travel < 0 then -half else half) - position) / travel
    end
    local fraction = math.clamp(math.min(boundAxis(start.X, delta.X, bounds.Size.X * .5),
        boundAxis(start.Z, delta.Z, bounds.Size.Z * .5)), 0, 1)
    return from:Lerp(to, fraction)
end

function Storm.beam(cast, at, clipEndpoint)
    local age = at - cast.clip.startedAt
    local aim = Storm.aim(cast, at)
    local localStart, localDirection = Dragon.muzzleAt(math.max(age, tempest.channelAt))
    local from = aim:PointToWorldSpace(localStart)
    local dir = aim:VectorToWorldSpace(localDirection)
    local travel = tempest.range
    if dir.Y < -.01 then
        travel = math.min(travel, math.max(0, (from.Y - cast.arena.floor - .07) / -dir.Y))
    end
    local finish = clipEndpoint(from, insideBeamEnd(cast.arena.bounds, from, from + dir * travel))
    return {start = from, finish = finish}
end

function Storm.beamContact(beam, frame, size, nearest, radius)
    local axis = beam.finish - beam.start
    local extent = axis:Dot(axis)
    if extent < .0064 then return nil end
    local function closest(point)
        return beam.start + axis * math.clamp((point - beam.start):Dot(axis) / extent, 0, 1)
    end
    local point = nearest(frame, size, closest(frame.Position))
    local onBeam = closest(point)
    if (point - onBeam).Magnitude <= radius then return point, onBeam end
    return nil
end

function Storm.thunder(cast, at, hasFloor)
    local markAt = cast.clip.startedAt + tempest.thunderWarnAt
    if at + .00001 < markAt then return nil end
    if not cast.thunderPlanned then
        local aim = Storm.aim(cast, markAt)
        local offset = Vector3.new(math.cos(cast.thunderSector) * .88, 0, -3.85 + math.sin(cast.thunderSector) * .88)
        local point = Match.clampFloor(cast.arena.bounds, aim:PointToWorldSpace(offset), cast.arena.floor)
        cast.thunderPlanned = true
        if not hasFloor or hasFloor(point) then
            cast.thunderPoint = point
        end
    end
    return cast.thunderPoint
end

function Storm.planTalon(cast, grabber, victim, clipTravel, victimGroundY)
    if cast.path then return end
    local arena = cast.arena
    local heading = cast.origin.LookVector
    local function limit(from, width)
        local wanted = Match.clampFloor(arena.bounds, from + heading * 5.2, from.Y)
        local straight = from + heading * math.max(0, (wanted - from):Dot(heading))
        local allowed = Match.clampFloor(arena.bounds, straight, from.Y)
        return math.max(0, (clipTravel(from, allowed, width) - from):Dot(heading))
    end
    local distance = math.min(limit(grabber.Position, 1.44), limit(victim.Position, 1.28))
    cast.path = {from = grabber.Position, victimFrom = victim.Position, direction = heading, distance = distance,
        victimLandY = victimGroundY or victim.Position.Y,
        victimFinish = victim.Position + heading * distance}
end

function Storm.carry(cast, at)
    local path = cast.path
    if not path then return nil end
    local age = at - cast.clip.startedAt
    local progress = math.clamp((age - talon.grabAt) / talon.carryDuration, 0, 1)
    local ease = progress * progress * (3 - 2 * progress)
    local touchdown = math.clamp((age - talon.throwAt) / (talon.impactAt - talon.throwAt), 0, 1)
    local lift = math.min(1, progress * 7) * (1 - touchdown ^ 1.4)
    local shift = path.direction * path.distance * ease
    local owner = path.from + shift + Vector3.yAxis * (.53 * lift)
    local targetFloor = (path.victimLandY - path.victimFrom.Y) * touchdown
    local victim = path.victimFrom + shift + Vector3.yAxis * (1.08 * lift + targetFloor)
    return CFrame.lookAlong(owner, path.direction), CFrame.lookAlong(victim, -path.direction)
end

local function part(parent, name, size, frame, tint, transparency, shape)
    local piece = Instance.new("Part")
    piece.Name, piece.Size, piece.CFrame, piece.Color, piece.Transparency = name, size, frame, tint, transparency
    piece.Material = Enum.Material.Neon
    piece.Shape = shape or Enum.PartType.Block
    piece.Anchored, piece.CanCollide, piece.CanTouch, piece.CanQuery, piece.CastShadow = true, false, false, false, false
    piece.Parent = parent
    return piece
end

local function disk(parent, name, point, radius, tint, alpha)
    return part(parent, name, Vector3.new(.034, radius * 2, radius * 2),
        CFrame.new(point + Vector3.yAxis * .06) * CFrame.Angles(0, 0, math.pi * .5), tint, alpha, Enum.PartType.Cylinder)
end

local function strip(parent, name, from, to, width, tint, transparency, piece)
    local length = (to - from).Magnitude
    local frame = if length > .008 then CFrame.lookAt(from:Lerp(to, .5), to) else CFrame.new(from)
    local size = Vector3.new(width, width, math.max(length, .02))
    if piece then
        piece.Size, piece.CFrame, piece.Transparency = size, frame, transparency
        return piece
    end
    return part(parent, name, size, frame, tint, transparency)
end

function Storm.show(cast, parent)
    local group = Instance.new("Folder")
    group.Name = if cast.action == carryAction then "Talon Drop warning" else "Tempest Roar warning"
    group.Parent = parent
    cast.warning = group
    if cast.action == carryAction then
        local lead = cast.origin:PointToWorldSpace(Vector3.new(0, 0, -1.7))
        local point = Match.clampFloor(cast.arena.bounds, lead, cast.arena.floor)
        cast.reachMark = disk(group, "Talon reach", point, .92, gold, .66)
    end
    return group
end

function Storm.present(cast, at, beam, hasFloor)
    local age, group = at - cast.clip.startedAt, cast.warning
    if not group then return end
    if cast.action == carryAction then
        if cast.path and not cast.carryMark then
            if cast.reachMark then cast.reachMark:Destroy() end
            local point = Match.clampFloor(cast.arena.bounds, cast.path.victimFinish, cast.arena.floor)
            cast.carryMark = disk(group, "Talon Drop carry", point, 1.15, gold, .48)
        end
        return
    end
    if beam and age >= tempest.aimAt and age < tempest.channelEnd then
        local active = age >= tempest.channelAt
        if active and not cast.beamGroup then
            cast.beamGroup = Instance.new("Folder")
            cast.beamGroup.Name, cast.beamGroup.Parent = "Tempest Roar beam", group
        end
        local parent = cast.beamGroup or group
        cast.core = strip(parent, "Lightning core", beam.start, beam.finish,
            if active then .18 else .045, white, if active then .05 else .52, cast.core)
        if active then
            cast.core.Parent = parent
            cast.halo = strip(parent, "Lightning halo", beam.start, beam.finish,
                .46 + .05 * math.sin(age * 40), blue, .58, cast.halo)
        end
    elseif cast.core and age >= tempest.channelEnd then
        if cast.beamGroup then cast.beamGroup:Destroy() else cast.core:Destroy() end
        cast.beamGroup, cast.core, cast.halo = nil, nil, nil
    end
    local mark = Storm.thunder(cast, at, hasFloor)
    if mark and age < tempest.thunderAt and not cast.thunderMark then
        cast.thunderMark = disk(group, "Tempest thunder warning", mark, tempest.thunderRadius, violet, .42)
    end
end

function Storm.flash(cast, shape, parent, point)
    local name = if shape == "talonThrow" then "Talon Drop landing" else "Tempest thunder strike"
    if shape == "stormThunder" then
        if cast.thunderMark then cast.thunderMark:Destroy() end
    elseif cast.carryMark then
        cast.carryMark:Destroy()
    end
    local fx = Instance.new("Folder")
    fx.Name, fx.Parent = name, parent
    local ground = Vector3.new(point.X, cast.arena.floor, point.Z)
    local ring = disk(fx, "Impact ring", ground, if shape == "talonThrow" then 1.39 else 1.36,
        if shape == "talonThrow" then gold else violet, .23)
    TweenService:Create(ring, TweenInfo.new(.22), {Transparency = 1}):Play()
    if shape == "stormThunder" then
        for index = 0, 3 do
            local from = ground + Vector3.new((index % 2) * .42, index * 1.45, 0)
            local to = ground + Vector3.new(((index + 1) % 2) * .42, (index + 1) * 1.45, 0)
            local bolt = strip(fx, "Thunder branch", from, to, .22, violet, .12)
            TweenService:Create(bolt, TweenInfo.new(.23), {Transparency = 1}):Play()
        end
    end
    Debris:AddItem(fx, .24)
end

return table.freeze(Storm)
