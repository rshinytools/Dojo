-- Native fighter motion, fitted contact volumes, and authored floor effects.
local Match = require(script.Parent.DojoMatchSupport)
local Jump = require(game:GetService("ReplicatedStorage").ArenaJumpMotion)
local Tactics = require(game:GetService("ReplicatedStorage").FighterTactics)
local Debris = game:GetService("Debris")
local FighterMotion = require(script.Parent.ReedguardFightMotion)
local Geometry = FighterMotion.geometry
local Penguin = require(script.Parent.PenguinCombatPoses)
local Silverback = require(script.Parent.SilverbackCombatPoses)
local Salamander = require(script.Parent.FireSalamanderCombatPoses)
local Frog = require(script.Parent.FrogCombatPoses)
local Otter = require(script.Parent.OtterCombatPoses)
local Sky = require(script.Parent.SkyFighterCombat)
local EmberAqua = require(script.Parent.EmberAquaCombat)
local Fields = require(script.Parent.ArenaFields)
local Heavy = require(script.Parent.HeavyFighterCombat)
local Ricochet = require(script.Parent.RingRicochet)
local Magma = require(script.Parent.MagmaFighterCombat)
local Thunder = require(script.Parent.ThunderFighterCombat)
local Apex = require(script.Parent.ApexFighterCombat)
local Abyss = require(script.Parent.AbyssFighterCombat)
local Inferno = require(script.Parent.InfernoFighterCombat)
local Storm = require(script.Parent.StormFighterCombat)
local rolls = {fortressRicochet = Heavy.roll, meteorRoll = Magma.roll}
local targetedSkills = {apexPounce = Apex.pounce, jawsOfTheDeep = Abyss.jaws}

local Motion = {}
local defeatSeconds = Geometry.defeatSeconds
local joints = {"RootJoint", "Neck", "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip", "TailJoint"}
local travelActions = {sidestep = true, floeTurn = true, bellySlide = true, magmaTrail = true, lilyVault = true, eddyPalm = true,
    fortressRicochet = true, meteorRoll = true, apexPounce = true, jawsOfTheDeep = true}
local plantedActions = {seismicChestPound = true, ridgePalm = true, emberSweep = true, tadpoleTornado = true,
    pebbleBarrage = true, cinderSnare = true, cavitationCannon = true, volcanicBreath = true, unstoppableFrenzy = true,
    tentacleCataclysm = true, eruptionSlam = true, hellfireStampede = true, talonDropMiss = true}
local sideStep = {
    reedguard = {distance = 2.45, time = .23, start = 0},
    silverback = {distance = 2.23, time = .29, start = .045},
    salamander = {distance = 2.40, time = .235, start = .035},
    frog = {distance = 2.48, time = .23, start = .025},
    otter = {distance = 2.39, time = .24, start = .025},
    rooster = {distance = 2.45, time = .24, start = .025},
    glider = {distance = 2.58, time = .23, start = .025},
    scorpion = {distance = 2.30, time = .245, start = .025},
    shrimp = {distance = 2.40, time = .23, start = .025},
    walrus = {distance = 1.85, time = .27, start = .03},
    tortoise = {distance = 1.91, time = .27, start = .03},
    armadillo = {distance = 1.95, time = .27, start = .03},
    komodo = {distance = 2.36, time = .24, start = .03},
    owl = {distance = 2.58, time = .23, start = .02},
    ram = {distance = 2.17, time = .27, start = .035},
    badger = {distance = 2.36, time = .245, start = .025},
    sabertooth = {distance = 2.57, time = .225, start = .025},
    shark = {distance = 2.56, time = .23, start = .025},
    kraken = {distance = 2.03, time = .285, start = .035},
    grizzly = {distance = 1.97, time = .28, start = .036},
    hellhound = {distance = 2.56, time = .225, start = .025},
    eagle = {distance = 2.61, time = .22, start = .023},
    dragon = {distance = 2.23, time = .26, start = .03},
}
local blue = Color3.fromRGB(105, 213, 249)
local gold = Color3.fromRGB(255, 206, 115)
local amber = Color3.fromRGB(255, 163, 82)

local function heading(origin, target, fallback)
    local offset = Match.flat(target - origin)
    return if offset.Magnitude > .04 then offset.Unit else fallback
end

local function clockFrame(actor, at)
    return Geometry.positionAt(actor.history, at)
end

local function restoreOwnership(actor)
    local root = actor.root
    if actor.network and root.Parent and not root.Anchored and root:CanSetNetworkOwnership() then
        local owner = actor.network.owner
        if actor.network.automatic or (owner and not owner.Parent) then
            root:SetNetworkOwnershipAuto()
        else
            root:SetNetworkOwner(owner)
        end
    end
end

local function setHeld(actor, hold)
    if actor.held == hold then
        return
    end
    actor.held = hold
    local root = actor.root
    root.Anchored = hold or actor.wasAnchored
    if not hold then
        restoreOwnership(actor)
    end
end

local function remember(actor, at)
    Geometry.rememberPosition(actor.history, at, actor.root.CFrame)
    while #actor.history > 2 and actor.history[2].at < at - .8 do
        table.remove(actor.history, 1)
    end
end

local function beginActor(duel, actor, index, brawl)
    local root = actor.root
    local character = root.Parent
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animate = character:FindFirstChild("Animate")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    actor.character, actor.humanoid, actor.animate = character, humanoid, animate
    actor.wasAutoRotate, actor.wasAutoJump = humanoid.AutoRotate, humanoid.AutoJumpEnabled
    actor.wasWalkSpeed = humanoid.WalkSpeed
    actor.wasAnimateDisabled = animate and animate.Disabled
    actor.wasAnchored = root.Anchored
    actor.held, actor.network, actor.knock, actor.lift, actor.cast = nil, nil, nil, nil, nil
    actor.aim, actor.facing, actor.defeat, actor.shuffle, actor.rise = nil, nil, nil, nil, nil
    actor.lastReaction, actor.reactionAt = nil, nil
    actor.history = {{at = duel.round.introAt, position = root.CFrame}}
    actor.motors, actor.marks = {}, {}
    actor.fx = Instance.new("Folder")
    actor.fx.Name = (if brawl then "Brawl Fighter " else "Duel Fighter ") .. index
    actor.fx.Parent = duel.telegraph
    actor.motionActive = true
    if not root.Anchored and root:CanSetNetworkOwnership() then
        actor.network = {automatic = root:GetNetworkOwnershipAuto(), owner = root:GetNetworkOwner()}
    end
    for _, name in joints do
        local joint = character:FindFirstChild(name, true)
        if joint and joint:IsA("Motor6D") then
            actor.motors[name] = {motor = joint, rest = joint.C0}
        end
    end
    if animate then
        animate.Disabled = true
    end
    if animator then
        for _, track in animator:GetPlayingAnimationTracks() do
            track:Stop(0)
        end
    end
    if not brawl then
        local aim = Instance.new("Attachment")
        aim.Name = "Duel facing attachment"
        aim.Parent = root
        local facing = Instance.new("AlignOrientation")
        facing.Name = "Duel opponent facing"
        facing.Mode, facing.Attachment0 = Enum.OrientationAlignmentMode.OneAttachment, aim
        facing.Responsiveness, facing.MaxTorque = 24, 45000
        facing.CFrame = root.CFrame.Rotation
        facing.Parent = root
        actor.aim, actor.facing = aim, facing
        humanoid.WalkSpeed = math.min(humanoid.WalkSpeed, FighterMotion.lockedWalkSpeed)
    end
    humanoid.AutoRotate, humanoid.AutoJumpEnabled = false, false
    setHeld(actor, true)
    Jump.open(character, duel.floor)
end

function Motion.open(duel, brawl)
    local excluded = {duel.bounds}
    for index, actor in duel.actors do
        beginActor(duel, actor, index, brawl)
        table.insert(excluded, actor.character)
    end
    duel.motion = {arena = duel, arenaCast = Geometry.castParameters(excluded), brawl = brawl, at = duel.round.introAt}
    if duel.bossCollider then
        local contactExclusions = table.clone(excluded)
        table.insert(contactExclusions, duel.bossCollider)
        duel.motion.contactCast = Geometry.castParameters(contactExclusions)
    end
end

function Motion.remove(duel, index)
    local actor = duel.actors[index]
    if not actor or not actor.motionActive then
        return
    end
    actor.motionActive = false
    Jump.close(actor.character)
    for _, joint in actor.motors do
        if joint.motor.Parent then
            joint.motor.C0 = joint.rest
        end
    end
    if actor.animate and actor.animate.Parent then
        actor.animate.Disabled = actor.wasAnimateDisabled
    end
    if actor.humanoid.Parent then
        actor.humanoid.AutoRotate = actor.wasAutoRotate
        actor.humanoid.AutoJumpEnabled = actor.wasAutoJump
        if not duel.motion.brawl then
            actor.humanoid.WalkSpeed = actor.wasWalkSpeed
        end
    end
    Geometry.restoreDefeat(actor)
    actor.rise = nil
    if actor.facing then
        actor.facing:Destroy()
        actor.aim:Destroy()
    end
    actor.fx:Destroy()
    if actor.root.Parent then
        actor.root.Anchored = actor.wasAnchored
        restoreOwnership(actor)
    end
end

function Motion.close(duel)
    if not duel.motion then
        return
    end
    for index in duel.actors do
        Motion.remove(duel, index)
    end
    duel.motion = nil
end

function Motion.reopenActor(duel, index, now)
    local actor = duel.actors[index]
    beginActor(duel, actor, index, duel.motion.brawl)
    actor.history[1].at = now
end

function Motion.revive(raid, index, at, duration, now)
    local actor = raid.actors[index]
    local shape = if now < at + duration then Geometry.capturePlayerRise(actor, actor.root) else nil
    if not shape then
        Motion.remove(raid, index)
        Motion.reopenActor(raid, index, now)
        return
    end
    actor.rise = {shape = shape, startedAt = at, endsAt = at + duration}
end

local function activeActor(duel, index)
    local actor = duel.actors[index]
    return actor and actor.motionActive and actor.root.Parent == actor.character
        and not duel.round.sides[index].eliminated
end

local function floorActive(duel, point, at)
    return not duel.floorActive or duel.floorActive(point, at)
end

local function talonHold(duel, index, at)
    local hold = Storm.held(duel.round.sides[index], at)
    if hold then
        for attacker, state in duel.round.sides do
            if state == hold.attacker and activeActor(duel, attacker) then
                return hold, attacker
            end
        end
    end
    return nil
end

function Motion.holdsKnockout(match, index, now)
    local actor, round = match.actors[index], match.round
    local state = round.sides[index]
    return state.eliminationReason == "knockout" and actor.motionActive and actor.root.Parent == actor.character
        and (round.result ~= nil or state.downed or now < state.eliminatedAt + defeatSeconds)
        and (not match.floorActive or (actor.root.Position.Y >= match.floor + 1.12
            and floorActive(match, actor.root.Position)))
        and (not match.knockoutDeck or Geometry.defeatFits(actor, match.knockoutDeck()))
end

function Motion.canAct(duel, side, action, now)
    local actor = duel.actors[side]
    if not activeActor(duel, side) or not Match.inside(duel.bounds, actor.root.Position)
        or talonHold(duel, side, now or duel.motion.at) then
        return false
    end
    local root = actor.root
    if duel.motion.brawl and not floorActive(duel, root.Position, now or duel.motion.at) then
        return false
    end
    if action == "secondary" and Tactics.isPlanted(duel.round.sides[side].tactical) then
        return FighterMotion.reactionGrounded(root, duel.floor)
    end
    if action == "dodge" or action == "signature" or action == "secondary" then
        return root.Position.Y <= duel.floor + 3.19 and math.abs(root.AssemblyLinearVelocity.Y) <= 4
    end
    return true
end

local function floorPoint(duel, point)
    return Vector3.new(point.X, duel.floor, point.Z)
end

local function clipInfernoLane(duel, from, to, width, at)
    local supported = if duel.floorActive then function(point) return floorActive(duel, point, at) end else nil
    return Geometry.clipGroundLane(from, to, duel.motion.contactCast or duel.motion.arenaCast, supported, width)
end

local function obstructed(duel, source, target)
    local from = Vector3.new(source.X, target.Y, source.Z)
    local vector = target - from
    return vector.Magnitude > .005 and workspace:Raycast(from, vector, duel.motion.contactCast or duel.motion.arenaCast) ~= nil
end

local function floorContour(duel, actor, name, center, radius, direction, halfAngle, tint)
    return Geometry.groundContour({arena = duel, telegraph = actor.fx}, name, center, radius, direction, halfAngle, tint)
end

local function arenaTravel(duel, position, target, frame, box)
    local motion = duel.motion
    if motion.brawl then
        local delta = target - position
        if delta.Magnitude <= .005 then
            return position
        end
        local hit = workspace:Blockcast(frame, box, delta, motion.arenaCast)
        return if hit then position + delta.Unit * math.max(0, hit.Distance - .065) else target
    end
    return Geometry.safeTravel(motion, position, target, frame, box, motion.arenaCast)
end

local function intendedPosition(duel, actor, opponent, origin, target, lowered, gap)
    local current = actor.root.Position
    local desired = target - current
    if duel.motion.brawl then
        for index, other in duel.actors do
            if other ~= actor and activeActor(duel, index)
                and math.abs(current.Y - other.root.Position.Y) < 2.5 then
                desired = Geometry.stopAtActor(current, desired, other.root.Position, gap)
            end
        end
    else
        desired = Geometry.stopAtActor(current, desired, opponent.root.Position, gap)
    end
    local frame = CFrame.new(current - Vector3.new(0, lowered, 0)) * origin.Rotation
    local box = if lowered >= 1 then Vector3.new(1.12, 1.10, 1.12) else Vector3.new(1.52, 2.18, 1.38)
    return arenaTravel(duel, current, current + desired, frame, box)
end

local function thunderTravel(duel, actor, other, origin, target, at)
    -- Unlike ordinary knockback, the charged landing stays on supported arena floor.
    local point = Match.clampFloor(duel.bounds, target, origin.Y)
    local landing = intendedPosition(duel, actor, other, origin, point, 0, 1.91)
    if duel.floorActive then
        return Thunder.floorEnd(actor.root.Position, landing, function(sample)
            return floorActive(duel, sample, at)
        end)
    end
    return landing
end

local function nearestGroundTarget(duel, side, origin, at)
    local target, best = nil, math.huge
    for index, opponent in duel.actors do
        if index ~= side and (not duel.enemies or duel.enemies(side, index)) and activeActor(duel, index) then
            local point = opponent.root.Position
            local distance = Match.flat(point - origin.Position).Magnitude
            if distance < best and Match.inside(duel.bounds, point) and floorActive(duel, point, at)
                and not Abyss.submerged(duel.round.sides[index], at) then
                target, best = point, distance
            end
        end
    end
    if not target and duel.bossVolumes then
        target = duel.bossVolumes[1].part.Position
    end
    return target or origin.Position
end

local function slideGuide(duel, actor, origin, distance)
    local start = floorPoint(duel, origin.Position)
    local feet = CFrame.new(start + Vector3.new(0, .76, 0)) * origin.Rotation
    local finish = arenaTravel(duel, start, start + origin.LookVector * distance, feet, Vector3.new(1.12, 1.08, .92))
    local vector = finish - start
    if vector.Magnitude < .12 then
        return nil
    end
    local stripe = Instance.new("Part")
    stripe.Name = "Belly Slide lane"
    stripe.Size = Vector3.new(1.14, .028, vector.Magnitude)
    stripe.CFrame = CFrame.lookAlong(start + vector / 2 + Vector3.new(0, .065, 0), vector.Unit)
    stripe.Anchored, stripe.CanCollide, stripe.CanTouch, stripe.CanQuery = true, false, false, false
    stripe.CastShadow, stripe.Material, stripe.Color, stripe.Transparency = false, Enum.Material.Neon, blue, .54
    stripe.Parent = actor.fx
    return stripe
end

local function clearCast(actor)
    local cast = actor.cast
    if cast then
        Fields.clearVisuals(cast)
    end
    actor.cast = nil
end

local function clearMarks(actor)
    for _, marks in actor.marks do
        for _, mark in marks do
            mark.warning:Destroy()
        end
    end
    table.clear(actor.marks)
    if actor.apexZone then
        actor.apexZone.visual:Destroy()
        actor.apexZone = nil
    end
end

local function clearDroppedMarks(duel, actor, now)
    for castStart, marks in actor.marks do
        for number, mark in marks do
            if not floorActive(duel, mark.center, now) then
                mark.warning:Destroy()
                marks[number] = nil
            end
        end
        if not next(marks) then
            actor.marks[castStart] = nil
        end
    end
end

local function updateWarning(duel, actor, cast, age)
    local action, origin = cast.clip.action, cast.origin
    local start, finish, skill
    if action == "bellySlide" then
        start, finish = 0, Penguin.Travel.bellySlide[1].age
    elseif action == "emberSweep" then
        skill = Salamander.Skill.emberSweep
        start, finish = skill.warningAt, Salamander.Contact.emberSweep
    elseif action == "seismicChestPound" then
        skill = Silverback.Skill.seismicChestPound
        start, finish = skill.warningAt, Silverback.Contact.seismicChestPound
    elseif action == "tadpoleTornado" then
        skill = Frog.Skill.tadpoleTornado
        start, finish = skill.warningAt, Frog.Contact.tadpoleTornado
    elseif action == "gustVortex" then
        skill = Sky.gust
        start, finish = skill.warningAt, Sky.burstAt
        if not floorActive(duel, cast.fieldCenter, duel.motion.at) then
            finish = 0
        end
    elseif action == "tidalBellyFlop" then
        skill = Heavy.flop
        start, finish = skill.warningAt, Heavy.flopAt
    else
        return
    end
    if age >= finish then
        if cast.warning then
            cast.warning:Destroy()
            cast.warning = nil
        end
        return
    elseif age < start or cast.warned then
        return
    end
    cast.warned = true
    if action == "bellySlide" then
        local path = Penguin.Travel.bellySlide
        cast.warning = slideGuide(duel, actor, origin, -path[#path].offset.Z)
    else
        local gust = action == "gustVortex"
        local flop = action == "tidalBellyFlop"
        local center = if gust then cast.fieldCenter elseif flop then floorPoint(duel, cast.landing)
            else floorPoint(duel, origin:PointToWorldSpace(skill.center))
        local fan = action == "emberSweep"
        local tornado = action == "tadpoleTornado"
        local name = if fan then "Ember Sweep warning" elseif tornado then "Tadpole Tornado warning"
            elseif gust then "Gust Vortex warning" elseif flop then "Tidal Belly-Flop warning" else "Seismic Chest Pound warning"
        local tint = if fan then amber elseif tornado then Color3.fromRGB(143, 241, 124)
            elseif gust then Color3.fromRGB(188, 179, 255) elseif flop then blue else gold
        cast.warning = floorContour(duel, actor, name,
            center, skill.radius, if fan then origin.LookVector else nil, skill.halfAngle, tint)
    end
end

local function supportedTriangle(duel, field, at)
    for _, node in field.vertices do
        if not floorActive(duel, node, at) then
            return false
        end
    end
    return true
end

local function pathOffset(cast, age, opponent)
    local action, clip = cast.clip.action, cast.clip
    if action == "sidestep" then
        local step = sideStep[cast.kit]
        local progress = math.clamp((age - step.start) / step.time, 0, 1)
        local distance = step.distance * progress * progress * (3 - 2 * progress)
        return Vector3.new(distance * (clip.direction or 1), 0, 0)
    end
    local rosterOffset = Geometry.rosterTravel(cast.poses, action, age, clip.direction)
    if rosterOffset then
        return rosterOffset
    end
    local path = (if action == "magmaTrail" then Salamander else Penguin).Travel[action]
    local offset = Geometry.pathOffset(path, age)
    if action == "magmaTrail" then
        if opponent then
            local other = cast.origin:PointToObjectSpace(opponent.root.Position)
            local dx = offset.X - other.X
            local skirt = 1.90
            if other.Z < 0 and math.abs(dx) < skirt then
                return Vector3.new(offset.X, 0, math.max(offset.Z, other.Z + math.sqrt(skirt * skirt - dx * dx)))
            end
        end
        return offset
    elseif clip.direction == -1 then
        return offset * Vector3.new(-1, 1, 1)
    end
    return offset
end

local function moveCast(duel, actor, other, cast, now)
    local clip, origin = cast.clip, cast.origin
    local action = clip.action
    local endAt = math.min(now, clip.endsAt)
    if cast.targeted then
        local arrival = clip.startedAt + cast.targeted.teleportAt
        if endAt >= arrival and not cast.arrived then
            if arrival > cast.movedAt then
                remember(actor, arrival - .0002)
            end
            local desired = Apex.destination(origin.Position, cast.targetPoint, cast.targeted.gap)
            local target = thunderTravel(duel, actor, other, origin, desired, arrival)
            Match.move(actor.root, Apex.face(target, cast.targetPoint, origin))
            cast.arrived = true
            remember(actor, arrival)
        end
        cast.movedAt = endAt
        remember(actor, endAt)
        return
    elseif cast.rollPath then
        local windup = cast.rollPath.skill.windup
        if endAt >= clip.startedAt + windup then
            local frame = Ricochet.frameAt(cast.rollPath, endAt - clip.startedAt - windup)
            Match.move(actor.root, frame)
        end
        cast.movedAt = endAt
        remember(actor, endAt)
        return
    elseif cast.landing then
        local travel = Heavy.flopTravel
        local alpha = math.clamp((endAt - clip.startedAt - travel.startsAt) / (travel.endsAt - travel.startsAt), 0, 1)
        local position = origin.Position:Lerp(cast.landing, alpha * alpha * (3 - 2 * alpha))
        Match.move(actor.root, CFrame.new(position) * origin.Rotation)
        cast.movedAt = endAt
        remember(actor, endAt)
        return
    end
    while cast.movedAt + .0001 < endAt do
        local at = math.min(cast.movedAt + 1 / 40, endAt)
        if action == "magmaTrail" then
            for _, tile in Salamander.Skill.magmaTrail.tiles do
                local markAt = clip.startedAt + tile.markAt
                if markAt > cast.movedAt + .0001 then
                    at = math.min(at, markAt)
                end
            end
        end
        local current = actor.root.Position
        local target = origin:PointToWorldSpace(pathOffset(cast, at - clip.startedAt, other))
        local delta = target - current
        if delta.Magnitude > .005 then
            local position
            if Thunder.skills[action] then
                position = thunderTravel(duel, actor, other, origin, target, at)
            else
                local maxStep = (if action == "lilyVault" then 22 else 18) * (at - cast.movedAt)
                local bounded = current + delta.Unit * math.min(delta.Magnitude, maxStep)
                local low = action == "bellySlide"
                position = intendedPosition(duel, actor, other, origin, bounded,
                    if low then 1.23 elseif action == "magmaTrail" then .38 else 0, if low then 1.55 else 1.79)
            end
            if (position - current).Magnitude > .005 then
                Match.move(actor.root, CFrame.new(position) * origin.Rotation)
            end
        end
        cast.movedAt = at
        remember(actor, at)
    end
end

local function moveKnock(duel, actor, other, now)
    local knock = actor.knock
    if not knock then
        return
    end
    local progress = math.clamp((now - knock.at) / knock.duration, 0, 1)
    local eased = 1 - (1 - progress) * (1 - progress)
    local current = actor.root.Position
    local shift = knock.offset * (eased - knock.moved)
    if shift.Magnitude > .005 then
        local frame = actor.root.CFrame
        local position = intendedPosition(duel, actor, other, frame, current + shift, 0, 1.70)
        Match.move(actor.root, CFrame.new(position) * frame.Rotation)
        if knock.carryCast and actor.cast then
            actor.cast.origin += position - current
        end
    end
    actor.lift = if knock.dropFrom then knock.dropFrom * (1 - progress) ^ 3
        else 4 * progress * (1 - progress) * knock.height
    knock.moved = eased
    if progress >= 1 then
        actor.knock = nil
    end
end

local function stormCast(actor, castStartedAt)
    local cast = actor.cast
    return if cast and cast.clip.startedAt == castStartedAt then cast.storm else nil
end

local function beamEndpoint(duel, from, to)
    local delta = to - from
    if delta.Magnitude <= .005 then return from end
    local hit = workspace:Raycast(from, delta, duel.motion.contactCast or duel.motion.arenaCast)
    return if hit then hit.Position else to
end

local function stormBeam(duel, cast, at)
    return Storm.beam(cast, at, function(from, to) return beamEndpoint(duel, from, to) end)
end

local function clipTalonTravel(duel, grabber, victim, from, to, width, at)
    local target = Match.clampFloor(duel.bounds, to, from.Y)
    local delta = target - from
    for index, other in duel.actors do
        if other ~= grabber and other ~= victim and activeActor(duel, index)
            and math.abs(from.Y - other.root.Position.Y) < 2.45 then
            delta = Geometry.stopAtActor(from, delta, other.root.Position, (width + 1.65) * .5)
        end
    end
    local finish = arenaTravel(duel, from, from + delta, CFrame.new(from), Vector3.new(width, 2.10, width))
    if not duel.floorActive then return finish end
    return if floorActive(duel, from, at) then Thunder.floorEnd(from, finish, function(point)
        return floorActive(duel, point, at)
    end) else from
end

local function talonFrames(duel, attacker, defender, cast, at)
    local grabber, victim = duel.actors[attacker], duel.actors[defender]
    local grabAt = cast.clip.startedAt + Storm.talon.grabAt
    if not cast.path then
        Storm.planTalon(cast, clockFrame(grabber, grabAt), clockFrame(victim, grabAt), function(from, to, width)
            return clipTalonTravel(duel, grabber, victim, from, to, width, grabAt)
        end, duel.floor + 2.132)
    end
    local fighterFrame, victimFrame = Storm.carry(cast, at)
    if fighterFrame and victimFrame and floorActive(duel, fighterFrame.Position, at)
        and floorActive(duel, victimFrame.Position, at) then
        return fighterFrame, victimFrame
    end
    return nil
end

local function updateActor(duel, index, now, deferredCasts)
    local actor = duel.actors[index]
    local brawl = duel.motion.brawl
    local other = if brawl then nil else duel.actors[3 - index]
    local state = duel.round.sides[index]
    local root, clip = actor.root, state.clip
    if actor.rise and now < actor.rise.endsAt and not actor.knock and not duel.round.resolvedAt then
        setHeld(actor, true)
        remember(actor, now)
        return
    end
    actor.frenzyGlow = Apex.frenzyVisual(actor.frenzyGlow and actor.frenzyGlow.Parent and actor.frenzyGlow,
        state, actor.character, actor.fx, now)
    if actor.knock and (Apex.unstoppable(state, now) or Abyss.submerged(state, now)) then
        actor.knock, actor.lift = nil, nil
    end
    local travel = clip and state.kit.poses.Travel and state.kit.poses.Travel[clip.action]
    local traveling = clip and (travelActions[clip.action] or (travel and travel.axis))
    local special = clip and Storm.isCast(clip.action)
    local planting = (clip and (plantedActions[clip.action] or special))
        or FighterMotion.canPlantStrike(state.kitId, clip, root, duel.floor)
    local live = now >= duel.round.startsAt and not duel.round.resolvedAt
    local rooted = now < math.max(state.rootedUntil or 0, state.shockedUntil or 0)
    if live and talonHold(duel, index, now) and floorActive(duel, root.Position, now) then
        clearCast(actor)
        actor.knock, actor.lift = nil, nil
        actor.humanoid.AutoRotate = false
        setHeld(actor, true)
        remember(actor, now)
        return
    end
    if brawl then
        actor.humanoid.AutoRotate = live and not clip and not actor.knock and actor.wasAutoRotate
        if live and not floorActive(duel, root.Position, now) then
            -- Finish an active shove across the edge, then let gravity take over.
            if deferredCasts and actor.cast then
                -- Keep the old geometry for scheduled contacts, but stop moving it with the actor.
                deferredCasts[actor] = actor.cast
                actor.cast = nil
            else
                clearCast(actor)
            end
            if actor.knock then
                setHeld(actor, true)
                moveKnock(duel, actor, other, now)
            end
            if not actor.knock then
                actor.lift = nil
                setHeld(actor, false)
            end
            remember(actor, now)
            return
        end
    end
    if live and (traveling or planting) then
        if not actor.cast or actor.cast.clip ~= clip then
            clearCast(actor)
            local orientation = if other then heading(root.Position, other.root.Position, root.CFrame.LookVector)
                else root.CFrame.LookVector
            local origin = CFrame.lookAlong(root.Position, orientation)
            actor.cast = {clip = clip, origin = origin, movedAt = clip.startedAt, kit = state.kitId, poses = state.kit.poses}
            local targeted = targetedSkills[clip.action]
            if targeted then
                local target = nearestGroundTarget(duel, index, origin, now)
                local desired = Apex.destination(origin.Position, target, targeted.gap)
                local landing = thunderTravel(duel, actor, other, origin, desired, now)
                local face = Apex.face(landing, target, origin)
                local center = Match.clampFloor(duel.bounds,
                    face:PointToWorldSpace(targeted.center or Vector3.zero), duel.floor)
                actor.cast.targetPoint, actor.cast.targeted = target, targeted
                local name = if clip.action == "apexPounce" then "Apex Pounce warning" else "Jaws of the Deep warning"
                actor.cast.warning = floorContour(duel, actor, name, center, targeted.radius, nil, nil, targeted.tint)
            elseif clip.action == "tentacleCataclysm" then
                local supported = if duel.floorActive then function(point) return floorActive(duel, point, now) end else nil
                actor.cast.lanes = Geometry.groundLanes(duel, origin, duel.motion.arenaCast, supported)
                actor.cast.warning = Abyss.laneWarnings(actor.cast.lanes, actor.fx)
            elseif Inferno.isCast(clip.action) then
                actor.cast.inferno = Inferno.plan(clip.action, duel, origin, function(from, to, width)
                    return clipInfernoLane(duel, from, to, width, now)
                end)
                actor.cast.warning = Inferno.showWarnings(actor.cast.inferno, actor.fx)
            elseif special then
                actor.cast.storm = Storm.begin(clip.action, duel, origin, clip)
                actor.cast.warning = Storm.show(actor.cast.storm, actor.fx)
            elseif clip.action == "gustVortex" then
                actor.cast.fieldCenter = Match.clampFloor(duel.bounds, origin:PointToWorldSpace(Sky.gust.center), duel.floor)
            elseif clip.action == "cinderSnare" then
                actor.cast.field = Fields.triangle(duel.bounds, duel.floor, origin, EmberAqua.snare.vertices)
            elseif clip.action == "cavitationCannon" then
                actor.cast.field = Fields.wave(duel.bounds, duel.floor, origin)
            elseif clip.action == "tidalBellyFlop" then
                local target = Match.clampFloor(duel.bounds, origin.Position + orientation * Heavy.flopTravel.distance, origin.Y)
                actor.cast.landing = arenaTravel(duel, origin.Position, target, origin, Vector3.new(1.84, 2.20, 1.50))
            elseif rolls[clip.action] then
                actor.cast.rollPath = Ricochet.plan(duel.bounds, origin.Position, orientation, rolls[clip.action], function(from, delta)
                    local center = Vector3.new(from.X, duel.floor + 1.22, from.Z)
                    return workspace:Blockcast(CFrame.new(center), Vector3.new(2.44, 2.22, 2.44), delta, duel.motion.arenaCast)
                end)
            end
            setHeld(actor, true)
            Match.move(root, origin)
        end
        if traveling then
            moveCast(duel, actor, other, actor.cast, now)
        end
        if actor.cast.rollPath then
            Ricochet.present(actor.cast, actor.fx, duel.floor, now - clip.startedAt, actor.cast.rollPath.skill)
        elseif clip.action == "volcanicBreath" then
            Magma.presentBreath(actor.cast, actor.fx, duel.floor, now - clip.startedAt, function(mouth, direction, range)
                local ray = workspace:Raycast(mouth, direction * range, duel.motion.arenaCast)
                return if ray then ray.Distance else range
            end)
        elseif Thunder.skills[clip.action] then
            local origin = actor.cast.origin
            local target = origin.Position + origin.LookVector * Thunder.skills[clip.action].travel.distance
            local landing = thunderTravel(duel, actor, other, origin, target, now)
            Thunder.present(actor.cast, actor.fx, duel.floor, now - clip.startedAt, landing, floorActive(duel, landing, now))
        elseif actor.cast.targeted then
            local targeted = actor.cast.targeted
            if now >= clip.startedAt + (targeted.impactAt or targeted.at) then
                Fields.clearVisuals(actor.cast)
            end
        elseif actor.cast.lanes then
            Abyss.windupLanes(actor.cast, now - clip.startedAt)
        elseif actor.cast.inferno then
            Inferno.presentEchoes(actor.cast.inferno, now - clip.startedAt)
        elseif actor.cast.storm then
            local storm = actor.cast.storm
            local beam
            if clip.action == "tempestRoar" then
                Match.move(root, Storm.aim(storm, now))
                beam = stormBeam(duel, storm, now)
            end
            Storm.present(storm, now, beam, function(point) return floorActive(duel, point, now) end)
        elseif actor.cast.field then
            local field = actor.cast.field
            Fields.updateCast(actor.fx, actor.cast, now - clip.startedAt, now, EmberAqua,
                not field.vertices or supportedTriangle(duel, field, now))
        else
            updateWarning(duel, actor, actor.cast, now - clip.startedAt)
        end
    else
        clearCast(actor)
        setHeld(actor, not live or rooted or actor.knock ~= nil)
    end
    moveKnock(duel, actor, other, now)
    if other then
        local aim = heading(root.Position, other.root.Position, root.CFrame.LookVector)
        if actor.facing.CFrame.LookVector:Dot(aim) < .999 then
            actor.facing.CFrame = CFrame.lookAlong(Vector3.zero, aim)
        end
    end
    remember(actor, now)
end

function Motion.move(duel, now, deferredCasts)
    duel.motion.at = now
    for index in duel.actors do
        if activeActor(duel, index) then
            updateActor(duel, index, now, deferredCasts)
        end
    end
    -- Move both roots after normal updates so roster iteration cannot overwrite
    -- the held fighter's position or the grabber's committed heading.
    if duel.round.resolvedAt then return end
    for defender, victim in duel.actors do
        if activeActor(duel, defender) then
            local hold, attacker = talonHold(duel, defender, now)
            local grabber = attacker and duel.actors[attacker]
            local cast = grabber and stormCast(grabber, hold.clip.startedAt)
            if cast and floorActive(duel, victim.root.Position, now) then
                local fighterFrame, victimFrame = talonFrames(duel, attacker, defender, cast, now)
                if fighterFrame then
                    Match.move(grabber.root, fighterFrame)
                    Match.move(victim.root, victimFrame)
                    remember(grabber, now)
                    remember(victim, now)
                end
            end
        end
    end
    if deferredCasts then
        for actor, cast in deferredCasts do
            actor.cast = cast
        end
    end
end

function Motion.clearCasts(actors)
    for actor in actors do
        clearCast(actor)
    end
end

local function poseAt(duel, index, now, readOnly)
    local actor, state = duel.actors[index], duel.round.sides[index]
    local round = duel.round
    local action, age, direction
    local rise = actor.rise
    if rise and not actor.knock and not round.resolvedAt and now >= rise.startedAt and now < rise.endsAt then
        local root = if readOnly then clockFrame(actor, now) else actor.root.CFrame
        local stance = state.kit.poses.sample("stance", now)
        local phase = (now - rise.startedAt) / (rise.endsAt - rise.startedAt)
        return Geometry.playerRiseOffsets(rise.shape, root, stance, actor.motors, phase), "raidRise"
    end
    if round.resolvedAt then
        local result = if duel.motion.brawl then round.result.outcomes[index] else round.result[index]
        action, age = if result == "win" then "win" else "stance", now - round.resolvedAt
    elseif now < round.startsAt then
        action, age = "intro", now - round.introAt
    elseif talonHold(duel, index, now) then
        action, age = "hitBody", .13 + math.sin(now * 16) * .045
    elseif state.clip then
        if not readOnly then actor.shuffle = nil end
        action, age, direction = state.clip.action, now - state.clip.startedAt, state.clip.direction
    else
        action, age = FighterMotion.locomotion(state.kit.poses, actor, actor.root, actor.root.CFrame.LookVector, now, readOnly)
    end
    local roll = rolls[action]
    local path = actor.cast and actor.cast.rollPath
    local sampleAge = if roll then Ricochet.sampleAge(path, age, roll) else age
    local offsets = state.kit.poses.sample(action, sampleAge, direction)
    if roll then
        offsets = Ricochet.pose(offsets, age, roll, roll.shellCenter, path)
    end
    if (actor.lift or 0) > 0 then
        offsets = table.clone(offsets)
        offsets.RootJoint = CFrame.new(0, actor.lift, 0) * offsets.RootJoint
    end
    return offsets, action
end

function Motion.render(duel, now, historical)
    for index, actor in duel.actors do
        local state = duel.round.sides[index]
        local defeatAt
        if duel.motion.brawl then
            if Motion.holdsKnockout(duel, index, now) then
                defeatAt = state.eliminatedAt
            end
        elseif state.playerHealth <= 0 then
            defeatAt = duel.round.resolvedAt
        end
        if defeatAt and actor.motionActive and actor.root.Parent == actor.character then
            if not historical then Jump.allow(actor.character, false) end
            if actor.rise then
                actor.rise = nil
                Geometry.restoreDefeat(actor)
            end
            if not actor.defeat then
                clearCast(actor)
                clearMarks(actor)
                actor.knock, actor.lift = nil, nil
                setHeld(actor, true)
            end
            local deck = if duel.knockoutDeck then duel.knockoutDeck() else nil
            Geometry.renderPlayerDefeat(actor, actor.root, duel.floor, now - defeatAt, deck)
            continue
        elseif not activeActor(duel, index) then
            continue
        elseif duel.round.resolvedAt then
            clearCast(actor)
            clearMarks(actor)
            if duel.resultStand then
                actor.knock, actor.lift = nil, nil
                local stand = duel.resultStand(actor.root.CFrame)
                if stand then Match.move(actor.root, stand) end
            end
            setHeld(actor, true)
        else
            if actor.cast and actor.cast.clip ~= state.clip then
                clearCast(actor)
            end
            if duel.motion.brawl and duel.floorActive then
                clearDroppedMarks(duel, actor, now)
            end
        end
        local offsets, action = poseAt(duel, index, now)
        if not historical and (state.reaction or actor.lastReaction) then
            local canRecover = not duel.round.resolvedAt and action == "stance" and not actor.knock
                and not (duel.round.revives and duel.round.revives[index])
                and FighterMotion.reactionGrounded(actor.root, duel.floor) and floorActive(duel, actor.root.Position, now)
            offsets = FighterMotion.recoverReaction(state, actor, offsets, now, canRecover)
        end
        if not historical then
            local canJump = now >= duel.round.startsAt and not duel.round.resolvedAt
                and not actor.knock and (actor.lift or 0) <= 0 and not actor.rise and not actor.cast
                and not (duel.round.revives and duel.round.revives[index]) and not talonHold(duel, index, now)
                and not state.clip and not actor.reactionAt
            Jump.allow(actor.character, canJump)
        end
        for name, joint in actor.motors do
            joint.motor.C0 = (offsets[name] or CFrame.identity) * joint.rest
        end
        if actor.rise and action ~= "raidRise" then
            actor.rise = nil
            Geometry.restoreDefeat(actor)
        end
    end
end

local function defenderFacing(root, origin)
    local toward = Match.flat(origin - root.Position)
    return toward.Magnitude <= .05 or toward.Unit:Dot(root.LookVector) >= .38
end

local function defenderVolumes(duel, index, at, root, facing)
    local state, actor = duel.round.sides[index], duel.actors[index]
    if Abyss.submerged(state, at) then return {} end
    local guard = facing and not talonHold(duel, index, at) and state.guardUntil >= at and at >= state.guardFrom + .055
    return Geometry.fittedVolumes(actor.character, root, actor.motors, poseAt(duel, index, at, true), guard)
end

local function floorContact(duel, index, at, root, center, radius, direction, halfAngle)
    local facing = defenderFacing(root, center)
    for _, volume in defenderVolumes(duel, index, at, root, facing) do
        if volume.grounded then
            local closest = Geometry.nearestPoint(volume.frame, volume.size, center + Vector3.new(0, .24, 0))
            local delta = Match.flat(closest - center)
            if closest.Y <= center.Y + .78 and delta.Magnitude <= radius
                and (not direction or delta.Magnitude <= .01 or delta.Unit:Dot(direction) >= math.cos(halfAngle))
                and not obstructed(duel, center, closest + Vector3.new(0, .13, 0)) then
                return closest, facing
            end
        end
    end
    return nil, facing
end

local function plantMagma(duel, actor, move, at, index, startedAt)
    local marks = actor.marks[startedAt]
    local cast = actor.cast
    if not cast or cast.clip.startedAt ~= startedAt or cast.movedAt < at - .001 then
        return false
    end
    local center = floorPoint(duel, clockFrame(actor, at).Position)
    if not Match.inside(duel.bounds, center + Vector3.yAxis) or not floorActive(duel, center, at)
        or Match.flat(center - cast.origin.Position).Magnitude < .30
        or (marks and marks[1] and (center - marks[1].center).Magnitude < move.radius) then
        return false
    end
    if not marks then
        marks = {}
        actor.marks[startedAt] = marks
    end
    local name = if index == 1 then "Magma Trail first mark" else "Magma Trail second mark"
    marks[index] = {center = center,
        warning = floorContour(duel, actor, name, center, move.radius, nil, nil, amber)}
    return true, center
end

local function takeMagma(duel, actor, at, index, startedAt)
    local marks = actor.marks[startedAt]
    local mark = marks and marks[index]
    if not mark then
        return nil
    end
    mark.warning:Destroy()
    marks[index] = nil
    if not next(marks) then
        actor.marks[startedAt] = nil
    end
    return if floorActive(duel, mark.center, at) then mark.center else nil
end

local function directContact(duel, other, action, move, at, root, target, point, previous, facing)
    local volumes = defenderVolumes(duel, other, at, target, facing)
    if previous then
        for _, volume in volumes do
            local frame, size = volume.frame, volume.size
            if volume.zone == "head" then
                continue
            elseif not volume.grounded then
                frame *= CFrame.new(0, -size.Y * .24, 0)
                size *= Vector3.new(1, .52, 1)
            end
            local hit = Geometry.sweptContact(previous, point, frame, size, .43)
            if hit and not obstructed(duel, root.Position, hit) then
                return hit, "body"
            end
        end
    else
        for _, volume in volumes do
            if (move.foot or not volume.grounded) and (volume.zone ~= "head" or move.zone == "head") then
                local frame, size = volume.frame, volume.size
                if action == "uppercut" and volume.zone == "body" then
                    frame *= CFrame.new(0, size.Y * .22, 0)
                    size *= Vector3.new(1, .56, 1)
                end
                local near = Geometry.nearestPoint(frame, size, point)
                local radius = move.radius or (if action == "uppercut" then .43 else .47)
                if (near - point).Magnitude <= radius then
                    local contact = point:Lerp(near, .5)
                    if not obstructed(duel, root.Position, contact) then
                        return contact, volume.zone
                    end
                end
            end
        end
    end
    return nil
end

local function slideSegment(actor, point)
    local cast = actor.cast
    local previous = cast and cast.lastContact or point
    if cast then
        cast.lastContact = point
    end
    return previous
end

local function inFront(root, target)
    local delta = Match.flat(target.Position - root.Position)
    return delta.Magnitude >= .04 and delta.Unit:Dot(root.LookVector) >= .41
end

local function clipPoint(duel, side, root, action, index)
    local state = duel.round.sides[side]
    local point = Geometry.attackPoint(state.kit.poses, action, index, state.clip and state.clip.direction)
    return root:PointToWorldSpace(point)
end

local function pebbleSegment(duel, actor, move, index, castStartedAt)
    local origin = clockFrame(actor, castStartedAt + move.release)
    local params = duel.motion.contactCast or duel.motion.arenaCast
    return Geometry.pebbleSweep(actor.fx, params, origin, move, index)
end

local function radialCenter(duel, actor, root, move, at, castStartedAt)
    if move.apex or move.abyss then
        local cast = actor.cast
        local center = Match.clampFloor(duel.bounds, root:PointToWorldSpace(move.center), duel.floor)
        if cast and cast.arrived and cast.clip.startedAt == castStartedAt and floorActive(duel, center, at) then
            if move.abyss then Abyss.splash(cast, actor.fx, center) end
            return center, move.radius
        end
        return nil
    elseif move.thunder then
        local cast = actor.cast
        if not cast or cast.clip.startedAt ~= castStartedAt or cast.movedAt < at - .001 then
            return nil
        end
        local center = floorPoint(duel, root.Position)
        if not floorActive(duel, center, at) then return nil end
        local radius = Thunder.radius(Thunder.skills[cast.clip.action], cast.origin.Position, center)
        Thunder.burst(cast, actor.fx, center, radius)
        return center, radius
    end
    if not move.lockedCenter then
        return floorPoint(duel, root:PointToWorldSpace(move.center)), move.radius
    end
    local cast = actor.cast
    local center = if cast and cast.clip.startedAt == castStartedAt and cast.fieldCenter then cast.fieldCenter
        else Match.clampFloor(duel.bounds, clockFrame(actor, castStartedAt):PointToWorldSpace(move.center), duel.floor)
    return (if floorActive(duel, center, at) then center else nil), move.radius
end

local function placeApexZone(duel, actor, root, at, castStartedAt)
    local skill = Apex.pounce
    local cast = actor.cast
    local center = floorPoint(duel, root.Position)
    if not cast or not cast.arrived or cast.clip.startedAt ~= castStartedAt or not floorActive(duel, center, at) then
        return false
    end
    local visual = floorContour(duel, actor, "Apex Root Zone", center, skill.radius, nil, nil, skill.tint)
    Debris:AddItem(visual, skill.duration)
    actor.apexZone = {startedAt = castStartedAt, center = center, visual = visual, caught = {}}
    return true
end

local function tentacleLane(duel, actor, at, index, castStartedAt)
    local cast = actor.cast
    if not cast or cast.clip.startedAt ~= castStartedAt or not cast.lanes
        or not floorActive(duel, cast.lanes[index].finish, at) then
        return nil
    end
    return Abyss.resolveLane(cast, actor.fx, index)
end

local function tentacleContact(duel, index, target, lane, move, at)
    if not Match.inside(duel.bounds, target.Position) or not floorActive(duel, target.Position, at) then
        return nil, false
    end
    local facing = defenderFacing(target, lane.start)
    for _, volume in defenderVolumes(duel, index, at, target, facing) do
        if volume.grounded then
            local hit, from = Abyss.laneContact(lane, volume.frame, volume.size, Geometry.nearestPoint, .78, move.radius)
            if hit and floorActive(duel, from, at) and not obstructed(duel, from, hit + Vector3.yAxis * .12) then
                return hit, facing
            end
        end
    end
    return nil, facing
end

local function infernoGeometry(duel, actor, move, at, index, castStartedAt)
    local cast = actor.cast
    if not cast or not cast.inferno or cast.clip.startedAt ~= castStartedAt then
        return nil
    end
    local supported = if duel.floorActive then function(point) return floorActive(duel, point, at) end else nil
    local shape = Inferno.impact(cast.inferno, move, index, actor.fx, supported)
    if not shape or move.shape == "eruption" then return shape end
    if duel.floorActive then
        -- The warning and echo follow the cast's original lane. If the floor
        -- drops under this sweep, reject it instead of moving the damage.
        local finish = clipInfernoLane(duel, shape.start, shape.finish, move.radius * 2, at)
        if (finish - shape.finish).Magnitude > .015 then return nil end
    end
    return shape
end

local function infernoContact(duel, defender, target, move, shape, at)
    if not Match.inside(duel.bounds, target.Position) or not floorActive(duel, target.Position, at) then
        return nil, false
    end
    if move.shape == "eruption" then
        return floorContact(duel, defender, at, target, shape, move.radius)
    end
    local facing = defenderFacing(target, shape.start)
    for _, volume in defenderVolumes(duel, defender, at, target, facing) do
        local hit, from = Abyss.laneContact(shape, volume.frame, volume.size, Geometry.nearestPoint, 2.3, move.radius)
        if hit and floorActive(duel, from, at) and not obstructed(duel, from, hit + Vector3.yAxis * .12) then
            return hit, facing
        end
    end
    return nil, facing
end

local function talonGrabContact(duel, defender, root, target, point, radius, at)
    local facing = defenderFacing(target, root.Position)
    if not Match.inside(duel.bounds, root.Position) or not Match.inside(duel.bounds, target.Position)
        or not floorActive(duel, target.Position, at) or talonHold(duel, defender, at) or not inFront(root, target) then
        return nil, facing
    end
    local closest, distance = nil, math.huge
    for _, volume in defenderVolumes(duel, defender, at, target, facing) do
        if volume.zone ~= "head" then
            local near = Geometry.nearestPoint(volume.frame, volume.size, point)
            local gap = (near - point).Magnitude
            if gap <= radius and gap < distance and not obstructed(duel, root.Position, near) then
                closest, distance = near, gap
            end
        end
    end
    return closest, facing
end

local function talonLanding(duel, attacker, defender, at, castStartedAt)
    if not activeActor(duel, defender) then return nil end
    local grabber, victim = duel.actors[attacker], duel.actors[defender]
    local cast = stormCast(grabber, castStartedAt)
    if not cast or cast.clip.talonTarget ~= defender then return nil end
    local hold, holder = talonHold(duel, defender, at)
    if not hold or holder ~= attacker or hold.clip ~= cast.clip then return nil end
    local fighterFrame, landing = talonFrames(duel, attacker, defender, cast, at)
    if landing and Match.inside(duel.bounds, landing.Position) then
        local point = floorPoint(duel, landing.Position)
        if not cast.landed then
            cast.landed = true
            -- Late frames still show both fighters touch down. Leave the
            -- pre-reaction history available to the rest of the strike batch.
            Match.move(grabber.root, fighterFrame)
            Match.move(victim.root, landing)
            Storm.flash(cast, "talonThrow", grabber.fx, point)
        end
        return point
    end
    return nil
end

local function tempestShape(duel, actor, move, at, castStartedAt)
    local cast = stormCast(actor, castStartedAt)
    if not cast then return nil end
    if move.shape == "stormThunder" then
        local center = Storm.thunder(cast, at, function(point) return floorActive(duel, point, at) end)
        if center and floorActive(duel, center, at) then
            Storm.flash(cast, "stormThunder", actor.fx, center)
            return center
        end
        return nil
    end
    local beam = stormBeam(duel, cast, at)
    return if beam and (beam.finish - beam.start).Magnitude > .035 then beam else nil
end

local function beamHit(duel, beam, frame, size, radius)
    local hit, from = Storm.beamContact(beam, frame, size, Geometry.nearestPoint, radius)
    if hit then
        local delta = hit - from
        if delta.Magnitude <= .005
            or not workspace:Raycast(from, delta, duel.motion.contactCast or duel.motion.arenaCast) then
            return hit
        end
    end
    return nil
end

local function tempestContact(duel, defender, target, move, shape, at)
    if not Match.inside(duel.bounds, target.Position) or not floorActive(duel, target.Position, at) then
        return nil, false
    end
    if move.shape == "stormThunder" then
        return floorContact(duel, defender, at, target, shape, move.radius)
    end
    local facing = defenderFacing(target, shape.start)
    for _, volume in defenderVolumes(duel, defender, at, target, facing) do
        local hit = beamHit(duel, shape, volume.frame, volume.size, move.radius)
        if hit then return hit, facing end
    end
    return nil, facing
end

local function apexZoneContact(duel, actor, defender, target, move, at, castStartedAt)
    local zone = actor.apexZone
    if not zone or zone.startedAt ~= castStartedAt or zone.caught[defender]
        or not floorActive(duel, zone.center, at) or not floorActive(duel, target.Position, at)
        or not Match.inside(duel.bounds, target.Position) then
        return nil, false
    end
    local hit, facing = floorContact(duel, defender, at, target, zone.center, move.radius)
    if hit then
        zone.caught[defender] = true
    end
    return hit, facing
end

local function fieldFor(duel, actor, move, at, castStartedAt)
    local cast = actor.cast
    local field = cast and cast.clip.startedAt == castStartedAt and cast.field
    if not field then
        return nil
    end
    if move.shape == "snare" and not supportedTriangle(duel, field, at) then
        return nil
    end
    return field
end

local function fieldContact(duel, index, move, at, target, field)
    if not Match.inside(duel.bounds, target.Position) or not floorActive(duel, target.Position, at) then
        return nil, false
    end
    local facing = defenderFacing(target, field.center)
    local point = Fields.footContact(field, move, defenderVolumes(duel, index, at, target, facing), function(from, to)
        return obstructed(duel, from, to)
    end)
    return point, facing
end

local function rollSegments(duel, actor, move, castStartedAt, at)
    local cast = actor.cast
    if not cast or not cast.rollPath or cast.clip.startedAt ~= castStartedAt
        or not floorActive(duel, actor.root.Position, at) then
        return nil
    end
    return Ricochet.sweeps(cast.rollPath, move.from, move.to)
end

local function rollContact(duel, other, at, target, segments, radius)
    if not segments or not Match.inside(duel.bounds, target.Position) or not floorActive(duel, target.Position, at) then
        return nil, false
    end
    for _, segment in segments do
        if Match.flat(target.Position - segment.b).Magnitude <= 4.1 and floorActive(duel, segment.b, at) then
            local facing = defenderFacing(target, segment.a)
            for _, volume in defenderVolumes(duel, other, at, target, facing) do
                local hit = Geometry.sweptContact(segment.a, segment.b, volume.frame, volume.size, radius)
                if hit and not obstructed(duel, segment.a, hit) then
                    return hit, facing
                end
            end
        end
    end
    return nil, false
end

local function breathFrame(actor, move, castStartedAt, root)
    if move.shape == "apexCone" then
        return Apex.swipeFrame(root, move)
    end
    local cast = actor.cast
    if cast and cast.clip.startedAt == castStartedAt then
        return Magma.breathFrame(cast.origin, move)
    end
    return nil
end

local function breathContact(duel, other, at, target, move, mouth, direction)
    local facing = defenderFacing(target, mouth)
    for _, volume in defenderVolumes(duel, other, at, target, facing) do
        if not volume.grounded then
            local hit = Magma.breathHit(mouth, direction, move, volume.frame, volume.size, Geometry.nearestPoint)
            if hit and not obstructed(duel, mouth, hit) then return hit, facing end
        end
    end
    return nil, facing
end

function Motion.strike(duel, side, action, move, at, index, castStartedAt)
    local other = 3 - side
    local actor = duel.actors[side]
    local root = clockFrame(actor, at)
    local target = clockFrame(duel.actors[other], at)
    if move.shape == "talonGrab" then
        local point = clipPoint(duel, side, root, action, index)
        local hit, facing = talonGrabContact(duel, other, root, target, point, move.radius, at)
        return hit ~= nil, hit or point, "body", facing
    elseif move.shape == "talonThrow" then
        local point = talonLanding(duel, side, other, at, castStartedAt)
        return point ~= nil, point, "body", false
    elseif move.shape == "stormBeam" or move.shape == "stormThunder" then
        local shape = tempestShape(duel, actor, move, at, castStartedAt)
        if not shape then return false end
        local hit, facing = tempestContact(duel, other, target, move, shape, at)
        return hit ~= nil, hit or (if move.shape == "stormBeam" then shape.finish else shape), "body", facing
    end
    if move.shape == "eruption" or move.shape == "echo" then
        local shape = infernoGeometry(duel, actor, move, at, index, castStartedAt)
        if not shape then return false end
        local hit, facing = infernoContact(duel, other, target, move, shape, at)
        local effectPoint = if move.shape == "eruption" then shape else shape.finish
        return hit ~= nil, hit or effectPoint, "body", facing
    end
    if move.shape == "tentacle" then
        local lane = tentacleLane(duel, actor, at, index, castStartedAt)
        if not lane then return false end
        local hit, facing = tentacleContact(duel, other, target, lane, move, at)
        return hit ~= nil, hit or lane.finish, "body", facing
    end
    if move.shape == "apexZone" then
        if move.marker then return placeApexZone(duel, actor, root, at, castStartedAt) end
        local hit, facing = apexZoneContact(duel, actor, other, target, move, at, castStartedAt)
        return hit ~= nil, hit, "body", facing
    end
    if move.shape == "ricochet" then
        local point, facing = rollContact(duel, other, at, target, rollSegments(duel, actor, move, castStartedAt, at), move.radius)
        return point ~= nil, point, "body", facing
    elseif move.shape == "snare" or move.shape == "wave" then
        local field = fieldFor(duel, actor, move, at, castStartedAt)
        if not field or move.launch then
            return false
        end
        local point, facing = fieldContact(duel, other, move, at, target, field)
        return point ~= nil, point, "body", facing
    end
    if move.shape == "tile" then
        if move.marker then
            return plantMagma(duel, actor, move, at, index, castStartedAt)
        end
        local center = takeMagma(duel, actor, at, index, castStartedAt)
        if not center then
            return false
        end
        local hit, facing = floorContact(duel, other, at, target, center, move.radius)
        return hit ~= nil, center, "body", facing
    end
    local facing = defenderFacing(target, root.Position)
    if not Match.inside(duel.bounds, root.Position) or not Match.inside(duel.bounds, target.Position) then
        return false, nil, nil, facing
    end
    if move.projectile then
        local start, finish, effect = pebbleSegment(duel, actor, move, index, castStartedAt)
        if not start then
            return false, finish
        end
        local hit, zone = Geometry.pebbleHit(start, finish, defenderVolumes(duel, other, at, target, facing), move.radius)
        if hit and effect then
            effect:Destroy()
        end
        return hit ~= nil, hit or finish, zone, facing
    end
    if move.shape == "breath" or move.shape == "apexCone" then
        local mouth, direction = breathFrame(actor, move, castStartedAt, root)
        if mouth then
            local hit, guardFacing = breathContact(duel, other, at, target, move, mouth, direction)
            return hit ~= nil, hit or mouth, "body", guardFacing
        end
        return false
    end
    local fan = move.shape == "fan"
    if fan or move.shape == "radial" then
        local center, radius = radialCenter(duel, actor, root, move, at, castStartedAt)
        if not center then
            return false
        end
        local hit, guardFacing = floorContact(duel, other, at, target, center, radius, if fan then root.LookVector else nil,
            move.halfAngle)
        return hit ~= nil, if fan then hit or center else center, "body", guardFacing
    end
    local point = clipPoint(duel, side, root, action, index)
    if not inFront(root, target) then
        return false, point, nil, facing
    end
    local previous = if action == "bellySlide" then slideSegment(actor, point) else nil
    local hit, zone = directContact(duel, other, action, move, at, root, target, point, previous, facing)
    return hit ~= nil, hit or point, zone, facing
end

function Motion.strikeGroup(brawl, side, action, move, at, index, castStartedAt)
    if not activeActor(brawl, side) then
        return if move.marker then false else {}
    end
    local actor = brawl.actors[side]
    local root = clockFrame(actor, at)
    if move.shape == "talonGrab" then
        local point = clipPoint(brawl, side, root, action, index)
        local closest, distance = nil, math.huge
        for other, defender in brawl.actors do
            if other ~= side and (not brawl.enemies or brawl.enemies(side, other)) and activeActor(brawl, other) then
                local target = clockFrame(defender, at)
                local gap = (target.Position - root.Position).Magnitude
                if gap < distance then
                    local hit, facing = talonGrabContact(brawl, other, root, target, point, move.radius, at)
                    if hit then
                        closest, distance = {defender = other, point = hit, zone = "body", facing = facing}, gap
                    end
                end
            end
        end
        return (if closest then {closest} else {}), point
    elseif move.shape == "talonThrow" then
        local cast = stormCast(actor, castStartedAt)
        local defender = cast and cast.clip.talonTarget
        local point = defender and talonLanding(brawl, side, defender, at, castStartedAt)
        return if point then {{defender = defender, point = point, zone = "body", facing = false}} else {}
    elseif move.shape == "stormBeam" or move.shape == "stormThunder" then
        local shape = tempestShape(brawl, actor, move, at, castStartedAt)
        local contacts = {}
        if not shape then return contacts end
        for other, opponent in brawl.actors do
            if other ~= side and (not brawl.enemies or brawl.enemies(side, other)) and activeActor(brawl, other) then
                local point, facing = tempestContact(brawl, other, clockFrame(opponent, at), move, shape, at)
                if point then
                    table.insert(contacts, {defender = other, point = point, zone = "body", facing = facing})
                end
            end
        end
        return contacts, if move.shape == "stormBeam" then shape.finish else shape
    end
    if move.shape == "eruption" or move.shape == "echo" then
        local shape = infernoGeometry(brawl, actor, move, at, index, castStartedAt)
        local contacts = {}
        if not shape then return contacts end
        for other, opponent in brawl.actors do
            if other ~= side and (not brawl.enemies or brawl.enemies(side, other)) and activeActor(brawl, other) then
                local hit, facing = infernoContact(brawl, other, clockFrame(opponent, at), move, shape, at)
                if hit then
                    table.insert(contacts, {defender = other, point = hit, zone = "body", facing = facing})
                end
            end
        end
        return contacts, if move.shape == "eruption" then shape else shape.finish
    end
    if move.shape == "tentacle" then
        local lane = tentacleLane(brawl, actor, at, index, castStartedAt)
        local contacts = {}
        if lane then
            for other, opponent in brawl.actors do
                if other ~= side and (not brawl.enemies or brawl.enemies(side, other)) and activeActor(brawl, other) then
                    local hit, facing = tentacleContact(brawl, other, clockFrame(opponent, at), lane, move, at)
                    if hit then table.insert(contacts, {defender = other, point = hit, zone = "body", facing = facing}) end
                end
            end
        end
        return contacts, lane and lane.finish
    end
    if move.shape == "apexZone" then
        if move.marker then return placeApexZone(brawl, actor, root, at, castStartedAt) end
        local contacts = {}
        for other, opponent in brawl.actors do
            if other ~= side and (not brawl.enemies or brawl.enemies(side, other)) and activeActor(brawl, other) then
                local point, facing = apexZoneContact(brawl, actor, other, clockFrame(opponent, at), move, at, castStartedAt)
                if point then
                    table.insert(contacts, {defender = other, point = point, zone = "body", facing = facing})
                end
            end
        end
        return contacts
    end
    if move.shape == "ricochet" then
        local segments = rollSegments(brawl, actor, move, castStartedAt, at)
        local contacts = {}
        if segments then
            for other, defender in brawl.actors do
                if other ~= side and (not brawl.enemies or brawl.enemies(side, other)) and activeActor(brawl, other) then
                    local point, facing = rollContact(brawl, other, at, clockFrame(defender, at), segments, move.radius)
                    if point then
                        table.insert(contacts, {defender = other, point = point, zone = "body", facing = facing})
                    end
                end
            end
        end
        return contacts
    elseif move.shape == "snare" or move.shape == "wave" then
        if move.launch then
            return false
        end
        local field = fieldFor(brawl, actor, move, at, castStartedAt)
        local contacts = {}
        if field then
            for other, defender in brawl.actors do
                if other ~= side and (not brawl.enemies or brawl.enemies(side, other)) and activeActor(brawl, other) then
                    local point, facing = fieldContact(brawl, other, move, at, clockFrame(defender, at), field)
                    if point then
                        table.insert(contacts, {defender = other, point = point, zone = "body", facing = facing})
                    end
                end
            end
        end
        return contacts
    end
    local fan, tile = move.shape == "fan", move.shape == "tile"
    if tile and move.marker then
        return plantMagma(brawl, actor, move, at, index, castStartedAt)
    end
    local center, point, previous, breathDirection
    local radius = move.radius
    if move.shape == "breath" or move.shape == "apexCone" then
        center, breathDirection = breathFrame(actor, move, castStartedAt, root)
        if not center then return {} end
    elseif tile then
        center = takeMagma(brawl, actor, at, index, castStartedAt)
        if not center then
            return {}
        end
    elseif not Match.inside(brawl.bounds, root.Position) or not floorActive(brawl, root.Position, at) then
        return {}
    elseif move.projectile then
        local start, finish, effect = pebbleSegment(brawl, actor, move, index, castStartedAt)
        if not start then
            return {}, finish
        end
        local closest, best = nil, math.huge
        for other, defender in brawl.actors do
            if other == side or (brawl.enemies and not brawl.enemies(side, other)) or not activeActor(brawl, other) then
                continue
            end
            local target = clockFrame(defender, at)
            if not Match.inside(brawl.bounds, target.Position) or not floorActive(brawl, target.Position, at) then
                continue
            end
            local facing = defenderFacing(target, root.Position)
            local volumes = defenderVolumes(brawl, other, at, target, facing)
            local hit, zone, distance = Geometry.pebbleHit(start, finish, volumes, move.radius)
            if hit and distance < best then
                closest, best = {defender = other, point = hit, zone = zone, facing = facing}, distance
            end
        end
        if closest and effect then
            effect:Destroy()
        end
        return if closest then {closest} else {}, finish
    elseif fan or move.shape == "radial" then
        center, radius = radialCenter(brawl, actor, root, move, at, castStartedAt)
        if not center then
            return {}
        end
    else
        point = clipPoint(brawl, side, root, action, index)
        if action == "bellySlide" then
            previous = slideSegment(actor, point)
        end
    end

    local area = center ~= nil or previous ~= nil
    local candidates, closest = {}, math.huge
    for other, defender in brawl.actors do
        if other == side or (brawl.enemies and not brawl.enemies(side, other)) or not activeActor(brawl, other) then
            continue
        end
        local target = clockFrame(defender, at)
        if not Match.inside(brawl.bounds, target.Position) or not floorActive(brawl, target.Position, at) then
            continue
        end
        local hit, zone, facing
        if breathDirection then
            hit, facing = breathContact(brawl, other, at, target, move, center, breathDirection)
            zone = "body"
        elseif center then
            if Match.flat(target.Position - center).Magnitude <= radius + 3 then
                hit, facing = floorContact(brawl, other, at, target, center, radius,
                    if fan then root.LookVector else nil, move.halfAngle)
                if hit and not fan then
                    hit = center
                end
                zone = "body"
            end
        elseif previous or inFront(root, target) then
            -- Sample the cast's single sweep segment for all targets before advancing it.
            local reach = if previous then (point - previous).Magnitude + 3.5 else 3.5
            if (target.Position - point).Magnitude <= reach then
                facing = defenderFacing(target, root.Position)
                hit, zone = directContact(brawl, other, action, move, at, root, target, point, previous, facing)
            end
        end
        if hit then
            local contact = {defender = other, point = hit, zone = zone, facing = facing}
            if area then
                table.insert(candidates, contact)
            else
                local distance = (target.Position - root.Position).Magnitude
                if distance < closest then
                    candidates[1], closest = contact, distance
                end
            end
        end
    end
    return candidates, center
end

function Motion.raidPosition(raid, side, at)
    local actor = raid.actors[side]
    return actor and actor.history and clockFrame(actor, at)
end

function Motion.strikeRaid(raid, side, action, move, at, index, castStartedAt)
    if not activeActor(raid, side) then
        return false
    end
    local actor = raid.actors[side]
    local root = clockFrame(actor, at)
    if move.shape == "talonThrow" then return false end
    if move.shape == "talonGrab" or move.shape == "stormBeam" or move.shape == "stormThunder" then
        local grab, beam = move.shape == "talonGrab", move.shape == "stormBeam"
        local shape = if grab then clipPoint(raid, side, root, action, index)
            else tempestShape(raid, actor, move, at, castStartedAt)
        if not shape then return false end
        local targets = if raid.round.coreExposed then raid.exposedBossVolumes else raid.bossVolumes
        for _, volume in targets do
            local frame, size = volume.part.CFrame, volume.part.Size
            local hit
            if beam then
                hit = beamHit(raid, shape, frame, size, move.radius)
            elseif grab then
                local nearest = Geometry.nearestPoint(frame, size, shape)
                if (nearest - shape).Magnitude <= move.radius and not obstructed(raid, root.Position, nearest) then
                    hit = nearest
                end
            else
                local nearest = Geometry.nearestPoint(frame, size, shape + Vector3.yAxis * .24)
                if nearest.Y <= shape.Y + .78 and Match.flat(nearest - shape).Magnitude <= move.radius
                    and not obstructed(raid, shape, nearest + Vector3.yAxis * .12) then
                    hit = nearest
                end
            end
            if hit then return true, hit, volume.zone end
        end
        return false, if beam then shape.finish else shape
    end
    if move.shape == "eruption" or move.shape == "echo" then
        local shape = infernoGeometry(raid, actor, move, at, index, castStartedAt)
        if not shape then return false end
        local eruption = move.shape == "eruption"
        local targets = if raid.round.coreExposed then raid.exposedBossVolumes else raid.bossVolumes
        for _, volume in targets do
            local frame, size = volume.part.CFrame, volume.part.Size
            local hit, from
            if eruption then
                local closest = Geometry.nearestPoint(frame, size, shape + Vector3.yAxis * .24)
                if closest.Y <= shape.Y + .78 and Match.flat(closest - shape).Magnitude <= move.radius then
                    hit, from = closest, shape
                end
            else
                hit, from = Abyss.laneContact(shape, frame, size, Geometry.nearestPoint, 2.3, move.radius)
            end
            if hit and not obstructed(raid, from, hit + Vector3.yAxis * .12) then
                return true, hit, volume.zone
            end
        end
        return false, if eruption then shape else shape.finish
    end
    if move.shape == "tentacle" then
        local lane = tentacleLane(raid, actor, at, index, castStartedAt)
        if not lane then return false end
        local targets = if raid.round.coreExposed then raid.exposedBossVolumes else raid.bossVolumes
        for _, volume in targets do
            local hit, from = Abyss.laneContact(lane, volume.part.CFrame, volume.part.Size, Geometry.nearestPoint, 3.1,
                move.radius)
            if hit and not obstructed(raid, from, hit) then return true, hit, volume.zone end
        end
        return false, lane.finish
    end
    if move.shape == "ricochet" then
        local segments = rollSegments(raid, actor, move, castStartedAt, at)
        if segments then
            local targets = if raid.round.coreExposed then raid.exposedBossVolumes else raid.bossVolumes
            for _, segment in segments do
                for _, volume in targets do
                    local hit = Geometry.sweptContact(segment.a, segment.b, volume.part.CFrame, volume.part.Size, move.radius)
                    if hit and not obstructed(raid, segment.a, hit) then
                        return true, hit, volume.zone
                    end
                end
            end
        end
        return false
    elseif move.shape == "snare" then
        return false
    elseif move.shape == "wave" then
        if move.launch then
            return false
        end
        local field = fieldFor(raid, actor, move, at, castStartedAt)
        if field then
            local targets = if raid.round.coreExposed then raid.exposedBossVolumes else raid.bossVolumes
            for _, volume in targets do
                local location = Geometry.nearestPoint(volume.part.CFrame, volume.part.Size, field.center + Vector3.yAxis * .45)
                if location.Y <= field.center.Y + 3.25 and Fields.contains(field, move, location)
                    and not obstructed(raid, field.center, location) then
                    return true, location, volume.zone
                end
            end
        end
        return false
    end
    local tile, fan = move.shape == "tile", move.shape == "fan"
    if tile and move.marker then
        return plantMagma(raid, actor, move, at, index, castStartedAt)
    end
    local center, point, previous, effect, breathDirection
    local radius = move.radius
    if move.shape == "apexZone" then
        return move.marker and placeApexZone(raid, actor, root, at, castStartedAt)
    elseif move.shape == "breath" or move.shape == "apexCone" then
        center, breathDirection = breathFrame(actor, move, castStartedAt, root)
        if not center then return false end
    elseif tile then
        center = takeMagma(raid, actor, at, index, castStartedAt)
        if not center then
            return false
        end
    elseif not Match.inside(raid.bounds, root.Position) then
        return false
    elseif move.projectile then
        previous, point, effect = pebbleSegment(raid, actor, move, index, castStartedAt)
        if not previous then
            return false, point
        end
    elseif fan or move.shape == "radial" then
        center, radius = radialCenter(raid, actor, root, move, at, castStartedAt)
        if not center then
            return false
        end
    else
        point = clipPoint(raid, side, root, action, index)
        previous = if action == "bellySlide" then slideSegment(actor, point) else nil
    end
    local targets = if raid.round.coreExposed then raid.exposedBossVolumes else raid.bossVolumes
    for _, volume in targets do
        local frame, size = volume.part.CFrame, volume.part.Size
        local hit
        if breathDirection then
            hit = Magma.breathHit(center, breathDirection, move, frame, size, Geometry.nearestPoint)
        elseif center then
            local near = Geometry.nearestPoint(frame, size, center + Vector3.new(0, .45, 0))
            local delta = Match.flat(near - center)
            if delta.Magnitude <= radius and (not fan or delta.Magnitude <= .03
                or delta.Unit:Dot(root.LookVector) >= math.cos(move.halfAngle)) then
                hit = near
            end
        elseif previous then
            hit = Geometry.sweptContact(previous, point, frame, size, move.radius or .44)
        else
            local near = Geometry.nearestPoint(frame, size, point)
            local forward = Match.flat(near - root.Position)
            if (near - point).Magnitude <= (move.radius or .48) and (forward.Magnitude < .06 or forward.Unit:Dot(root.LookVector) >= .2) then
                hit = near
            end
        end
        if hit and (move.projectile or not obstructed(raid, center or root.Position, hit)) then
            if effect then
                effect:Destroy()
            end
            return true, if center and not fan and not breathDirection then center else hit, volume.zone
        end
    end
    return false, center or point
end

local function raidFootprint(raid, index, at, root, facing, origin, strike, axis)
    for _, volume in defenderVolumes(raid, index, at, root, facing) do
        if not volume.grounded then
            continue
        end
        local delta = Match.flat(volume.frame.Position - origin)
        local sample
        if axis then
            sample = axis * math.clamp(delta:Dot(axis), strike.innerReach, strike.outerReach)
        else
            local radial = if delta.Magnitude > .01 then delta.Unit else Vector3.zAxis
            sample = radial * math.clamp(delta.Magnitude, strike.innerRadius, strike.radius)
        end
        local point = Geometry.nearestPoint(volume.frame, volume.size, origin + sample + Vector3.new(0, .24, 0))
        local offset = Match.flat(point - origin)
        local inside
        if axis then
            local along = offset:Dot(axis)
            inside = along >= strike.innerReach and along <= strike.outerReach
                and math.abs(offset:Cross(axis).Y) <= strike.halfWidth
        else
            inside = offset.Magnitude >= strike.innerRadius and offset.Magnitude <= strike.radius
        end
        if inside and point.Y <= origin.Y + .78
            and not obstructed(raid, origin, point + Vector3.new(0, .13, 0)) then
            return point
        end
    end
    return nil
end

function Motion.raidThreatHits(raid, _attack, strike, at, origin, direction)
    local hits = {}
    local axis = strike.axisX and Vector3.new(strike.axisX, 0, strike.axisZ)
    local radialCenter = if strike.centerX then origin + Vector3.new(strike.centerX, 0, strike.centerZ) else origin
    local rowCenter = strike.offset and (origin + direction * strike.offset)
    local row = rowCenter and CFrame.lookAlong(rowCenter, direction)
    for index, actor in raid.actors do
        if not activeActor(raid, index) then
            continue
        end
        local root = clockFrame(actor, at)
        if not Match.inside(raid.bounds, root.Position) then
            continue
        end
        local facing = defenderFacing(root, origin)
        local hit
        if axis or strike.innerRadius then
            hit = raidFootprint(raid, index, at, root, facing, origin, strike, axis)
        elseif strike.radius then
            hit, facing = floorContact(raid, index, at, root, radialCenter, strike.radius)
        else
            for _, volume in defenderVolumes(raid, index, at, root, facing) do
                if volume.grounded then
                    local point = Geometry.nearestPoint(volume.frame, volume.size, rowCenter + Vector3.new(0, .27, 0))
                    local offset = row:PointToObjectSpace(point)
                    if offset.Y <= .83 and math.abs(offset.X) <= strike.halfSpan and math.abs(offset.Z) <= strike.halfWidth
                        and not obstructed(raid, rowCenter, point + Vector3.new(0, .12, 0)) then
                        hit = point
                        break
                    end
                end
            end
        end
        if hit then
            table.insert(hits, {index = index, facing = facing, point = hit})
        end
    end
    return hits
end

function Motion.raidImpact(raid, index, origin, at, strength)
    if activeActor(raid, index) then
        local actor = raid.actors[index]
        local away = heading(origin, actor.root.Position, -actor.root.CFrame.LookVector)
        actor.knock = {at = at, offset = away * strength, duration = .29, height = .30, moved = 0}
    end
end

function Motion.impact(duel, event)
    if event.kind == "burn" or event.frenzyResist or ((event.damage or 0) <= 0 and event.kind ~= "pull") then
        return
    end
    local action = event.attack
    local attacker, target = duel.actors[event.attacker], duel.actors[event.defender]
    local root = clockFrame(attacker, event.at)
    local direction = root.LookVector
    if event.shockDuration and not duel.round.sides[event.defender].eliminated then
        Thunder.shock(target.character, target.fx, event.shockDuration)
    end
    local offset, duration, height
    local force, popHeight, spike = Sky.impulse(event)
    if force then
        local center = if action == "gustVortex" then event.point else root.Position
        local outward = heading(center, target.root.Position, direction)
        offset, duration, height = outward * force, if spike then .16 else .20, popHeight
    elseif EmberAqua.shove[action] then
        local field = attacker.cast and attacker.cast.field
        local center = if action == "cavitationCannon" and field then field.center else root.Position
        offset, duration, height = heading(center, target.root.Position, direction) * EmberAqua.shove[action],
            (if action == "cavitationCannon" then .34 else .20), 0
    elseif Thunder.shove[action] or Apex.shove[action] or Abyss.shove[action] or Inferno.shove[action] or Storm.shove[action] then
        local force = Thunder.shove[action] or Apex.shove[action] or Abyss.shove[action] or Inferno.shove[action] or Storm.shove[action]
        offset, duration, height = heading(root.Position, target.root.Position, direction) * force, .24, 0
    elseif Magma.shove[action] then
        offset, duration, height = heading(root.Position, target.root.Position, direction) * Magma.shove[action],
            .24, if action == "meteorRoll" then .32 else 0
    elseif Heavy.shove[action] then
        local center = if action == "tidalBellyFlop" then event.point else root.Position
        local away = if action == "fortressRicochet" then direction else heading(center, target.root.Position, direction)
        offset, duration, height = away * Heavy.shove[action], .26, if action == "tidalBellyFlop" then .17 else 0
    elseif action == "bellySlide" then
        offset, duration, height = direction * 1.38, .20, 0
    elseif action == "ridgePalm" then
        offset, duration, height = direction * Silverback.Skill.ridgePalm.shove, .22, 0
    elseif action == "seismicChestPound" then
        local outward = heading(root.Position, target.root.Position, direction)
        offset, duration, height = outward * .38, .27, Silverback.Skill.seismicChestPound.popHeight
    elseif action == "magmaTrail" then
        offset, duration, height = Vector3.zero, .28, Salamander.Skill.magmaTrail.popHeight
    elseif Frog.Skill[action] or Otter.Skill[action] then
        local skill = Frog.Skill[action] or Otter.Skill[action]
        local outward = heading(root.Position, target.root.Position, direction)
        offset, duration, height = outward * skill.shove, .20, 0
    elseif duel.motion.brawl then
        local lift = action == "uppercut" or (action == "reedstep" and event.index == 3)
        local distance = if action == "heavy" then 1.25 elseif lift then .70 else .35
        offset, duration, height = direction * distance, if distance > 1 then .21 else .15, if lift then .46 else 0
    else
        return
    end
    local scale = event.knockbackScale or 1
    target.knock = {at = event.at, offset = offset * scale, duration = duration, height = height * scale, moved = 0,
        dropFrom = if spike then target.lift or 0 else nil, carryCast = event.kind == "pull"}
end

Motion.defeatSeconds = defeatSeconds
return Motion
