-- Native fighter motion, fitted contact volumes, and authored floor effects.
local Match = require(script.Parent.DojoMatchSupport)
local Geometry = require(script.Parent.ReedguardFightMotion).geometry
local Penguin = require(script.Parent.PenguinCombatPoses)
local Silverback = require(script.Parent.SilverbackCombatPoses)
local Salamander = require(script.Parent.FireSalamanderCombatPoses)
local Frog = require(script.Parent.FrogCombatPoses)
local Otter = require(script.Parent.OtterCombatPoses)

local Motion = {}
local defeatSeconds = Geometry.defeatSeconds
local joints = {"RootJoint", "Neck", "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip", "TailJoint"}
local travelActions = {sidestep = true, floeTurn = true, bellySlide = true, magmaTrail = true, lilyVault = true, eddyPalm = true}
local plantedActions = {seismicChestPound = true, ridgePalm = true, emberSweep = true, tadpoleTornado = true,
    pebbleBarrage = true}
local sideStep = {
    reedguard = {distance = 2.45, time = .23, start = 0},
    silverback = {distance = 2.23, time = .29, start = .045},
    salamander = {distance = 2.40, time = .235, start = .035},
    frog = {distance = 2.48, time = .23, start = .025},
    otter = {distance = 2.39, time = .24, start = .025},
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
    actor.wasAnimateDisabled = animate and animate.Disabled
    actor.wasAnchored = root.Anchored
    actor.held, actor.network, actor.knock, actor.lift, actor.cast = nil, nil, nil, nil, nil
    actor.aim, actor.facing, actor.defeat = nil, nil, nil
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
    end
    humanoid.AutoRotate, humanoid.AutoJumpEnabled = false, false
    setHeld(actor, true)
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
    end
    Geometry.restoreDefeat(actor)
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

local function activeActor(duel, index)
    local actor = duel.actors[index]
    return actor and actor.motionActive and actor.root.Parent == actor.character
        and not duel.round.sides[index].eliminated
end

local function floorActive(duel, point, at)
    return not duel.floorActive or duel.floorActive(point, at)
end

function Motion.canAct(duel, side, action, now)
    local actor = duel.actors[side]
    if not activeActor(duel, side) or not Match.inside(duel.bounds, actor.root.Position) then
        return false
    end
    local root = actor.root
    if duel.motion.brawl and not floorActive(duel, root.Position, now or duel.motion.at) then
        return false
    end
    if action == "dodge" or action == "signature" or action == "secondary" then
        return root.Position.Y <= duel.floor + 3.19 and math.abs(root.AssemblyLinearVelocity.Y) <= 4
    end
    return true
end

local function floorPoint(duel, point)
    return Vector3.new(point.X, duel.floor, point.Z)
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
    if cast and cast.warning then
        cast.warning:Destroy()
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
        local center = floorPoint(duel, origin:PointToWorldSpace(skill.center))
        local fan = action == "emberSweep"
        local tornado = action == "tadpoleTornado"
        local name = if fan then "Ember Sweep warning" elseif tornado then "Tadpole Tornado warning" else "Seismic Chest Pound warning"
        local tint = if fan then amber elseif tornado then Color3.fromRGB(143, 241, 124) else gold
        cast.warning = floorContour(duel, actor, name,
            center, skill.radius, if fan then origin.LookVector else nil, skill.halfAngle, tint)
    end
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
            local maxStep = (if action == "lilyVault" then 22 else 18) * (at - cast.movedAt)
            local bounded = current + delta.Unit * math.min(delta.Magnitude, maxStep)
            local low = action == "bellySlide"
            local position = intendedPosition(duel, actor, other, origin, bounded,
                if low then 1.23 elseif action == "magmaTrail" then .38 else 0, if low then 1.55 else 1.79)
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
    end
    actor.lift = 4 * progress * (1 - progress) * knock.height
    knock.moved = eased
    if progress >= 1 then
        actor.knock = nil
    end
end

local function updateActor(duel, index, now)
    local actor = duel.actors[index]
    local brawl = duel.motion.brawl
    local other = if brawl then nil else duel.actors[3 - index]
    local state = duel.round.sides[index]
    local root, clip = actor.root, state.clip
    local traveling = clip and travelActions[clip.action]
    local planting = clip and plantedActions[clip.action]
    local live = now >= duel.round.startsAt and not duel.round.resolvedAt
    if brawl then
        actor.humanoid.AutoRotate = live and not clip and not actor.knock and actor.wasAutoRotate
        if live and not floorActive(duel, root.Position, now) then
            -- Finish an active shove across the edge, then let gravity take over.
            clearCast(actor)
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
            setHeld(actor, true)
            Match.move(root, origin)
        end
        if traveling then
            moveCast(duel, actor, other, actor.cast, now)
        end
        updateWarning(duel, actor, actor.cast, now - clip.startedAt)
    else
        clearCast(actor)
        setHeld(actor, not live or actor.knock ~= nil)
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

function Motion.move(duel, now)
    duel.motion.at = now
    for index in duel.actors do
        if activeActor(duel, index) then
            updateActor(duel, index, now)
        end
    end
end

local function poseAt(duel, index, now)
    local actor, state = duel.actors[index], duel.round.sides[index]
    local round = duel.round
    local action, age, direction
    if round.resolvedAt then
        local result = if duel.motion.brawl then round.result.outcomes[index] else round.result[index]
        action, age = if result == "win" then "win" else "stance", now - round.resolvedAt
    elseif now < round.startsAt then
        action, age = "intro", now - round.introAt
    elseif state.clip then
        action, age, direction = state.clip.action, now - state.clip.startedAt, state.clip.direction
    else
        local speed = actor.root.AssemblyLinearVelocity
        local moving = Match.flat(speed)
        action, age = "stance", now
        if moving.Magnitude > 1.3 and math.abs(speed.Y) < 6 then
            action = if moving:Dot(actor.root.CFrame.LookVector) >= 0 then "advance" else "retreat"
        end
    end
    local offsets = state.kit.poses.sample(action, age, direction)
    if (actor.lift or 0) > 0 then
        offsets = table.clone(offsets)
        offsets.RootJoint = CFrame.new(0, actor.lift, 0) * offsets.RootJoint
    end
    return offsets
end

function Motion.render(duel, now)
    for index, actor in duel.actors do
        local state = duel.round.sides[index]
        local defeatAt
        if duel.motion.brawl then
            if state.eliminationReason == "knockout" and now < state.eliminatedAt + defeatSeconds
                and floorActive(duel, actor.root.Position, now) then
                defeatAt = state.eliminatedAt
            end
        elseif state.playerHealth <= 0 then
            defeatAt = duel.round.resolvedAt
        end
        if defeatAt and actor.motionActive and actor.root.Parent == actor.character then
            if not actor.defeat then
                clearCast(actor)
                clearMarks(actor)
                actor.knock, actor.lift = nil, nil
                setHeld(actor, true)
            end
            Geometry.renderPlayerDefeat(actor, actor.root, duel.floor, now - defeatAt)
            continue
        elseif not activeActor(duel, index) then
            continue
        elseif duel.round.resolvedAt then
            clearCast(actor)
            clearMarks(actor)
            setHeld(actor, true)
        else
            if actor.cast and actor.cast.clip ~= state.clip then
                clearCast(actor)
            end
            if duel.motion.brawl and duel.floorActive then
                clearDroppedMarks(duel, actor, now)
            end
        end
        local offsets = poseAt(duel, index, now)
        for name, joint in actor.motors do
            joint.motor.C0 = (offsets[name] or CFrame.identity) * joint.rest
        end
    end
end

local function defenderFacing(root, origin)
    local toward = Match.flat(origin - root.Position)
    return toward.Magnitude <= .05 or toward.Unit:Dot(root.LookVector) >= .38
end

local function defenderVolumes(duel, index, at, root, facing)
    local state, actor = duel.round.sides[index], duel.actors[index]
    local guard = facing and state.guardUntil >= at and at >= state.guardFrom + .055
    return Geometry.fittedVolumes(actor.character, root, actor.motors, poseAt(duel, index, at), guard)
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
            if not volume.grounded and (volume.zone ~= "head" or move.zone == "head") then
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

function Motion.strike(duel, side, action, move, at, index, castStartedAt)
    local other = 3 - side
    local actor = duel.actors[side]
    local root = clockFrame(actor, at)
    local target = clockFrame(duel.actors[other], at)
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
    local fan = move.shape == "fan"
    if fan or move.shape == "radial" then
        local center = floorPoint(duel, root:PointToWorldSpace(move.center))
        local hit, guardFacing = floorContact(duel, other, at, target, center, move.radius, if fan then root.LookVector else nil,
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
    local fan, tile = move.shape == "fan", move.shape == "tile"
    if tile and move.marker then
        return plantMagma(brawl, actor, move, at, index, castStartedAt)
    end
    local center, point, previous
    if tile then
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
        center = floorPoint(brawl, root:PointToWorldSpace(move.center))
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
        if center then
            if Match.flat(target.Position - center).Magnitude <= move.radius + 3 then
                hit, facing = floorContact(brawl, other, at, target, center, move.radius,
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
    local tile, fan = move.shape == "tile", move.shape == "fan"
    if tile and move.marker then
        return plantMagma(raid, actor, move, at, index, castStartedAt)
    end
    local center, point, previous, effect
    if tile then
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
        center = floorPoint(raid, root:PointToWorldSpace(move.center))
    else
        point = clipPoint(raid, side, root, action, index)
        previous = if action == "bellySlide" then slideSegment(actor, point) else nil
    end
    local targets = if raid.round.coreExposed then raid.exposedBossVolumes else raid.bossVolumes
    for _, volume in targets do
        local frame, size = volume.part.CFrame, volume.part.Size
        local hit
        if center then
            local near = Geometry.nearestPoint(frame, size, center + Vector3.new(0, .45, 0))
            local delta = Match.flat(near - center)
            if delta.Magnitude <= move.radius and (not fan or delta.Magnitude <= .03
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
            return true, if center and not fan then center else hit, volume.zone
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
    if (event.damage or 0) <= 0 then
        return
    end
    local action = event.attack
    local attacker, target = duel.actors[event.attacker], duel.actors[event.defender]
    local root = clockFrame(attacker, event.at)
    local direction = root.LookVector
    local offset, duration, height
    if action == "bellySlide" then
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
    target.knock = {at = event.at, offset = offset * scale, duration = duration, height = height * scale, moved = 0}
end

Motion.defeatSeconds = defeatSeconds
return Motion
