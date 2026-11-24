-- Native character motion, fitted contact volumes, and bounded floor effects for two players.
local Match = require(script.Parent.DojoMatchSupport)
local Geometry = require(script.Parent.ReedguardFightMotion).geometry
local Penguin = require(script.Parent.PenguinCombatPoses)
local Silverback = require(script.Parent.SilverbackCombatPoses)
local Salamander = require(script.Parent.FireSalamanderCombatPoses)

local Motion = {}
local joints = {"RootJoint", "Neck", "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip", "TailJoint"}
local travelActions = {sidestep = true, floeTurn = true, bellySlide = true, magmaTrail = true}
local plantedActions = {seismicChestPound = true, ridgePalm = true, emberSweep = true}
local sideStep = {
    reedguard = {distance = 2.45, time = .23, start = 0},
    silverback = {distance = 2.23, time = .29, start = .045},
    salamander = {distance = 2.40, time = .235, start = .035},
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

local function beginActor(duel, actor, index)
    local root = actor.root
    local character = root.Parent
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animate = character:FindFirstChild("Animate")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    actor.character, actor.humanoid, actor.animate = character, humanoid, animate
    actor.wasAutoRotate, actor.wasAutoJump = humanoid.AutoRotate, humanoid.AutoJumpEnabled
    actor.wasAnimateDisabled = animate and animate.Disabled
    actor.wasAnchored = root.Anchored
    actor.history = {{at = duel.round.introAt, position = root.CFrame}}
    actor.motors, actor.marks = {}, {}
    actor.fx = Instance.new("Folder")
    actor.fx.Name = "Duel Fighter " .. index
    actor.fx.Parent = duel.telegraph
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
    humanoid.AutoRotate, humanoid.AutoJumpEnabled = false, false
    setHeld(actor, true)
end

function Motion.open(duel)
    for index, actor in duel.actors do
        beginActor(duel, actor, index)
    end
    duel.motion = {arena = duel, arenaCast = Geometry.castParameters({
        duel.actors[1].character, duel.actors[2].character, duel.bounds,
    })}
end

function Motion.close(duel)
    if not duel.motion then
        return
    end
    for _, actor in duel.actors do
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
        actor.facing:Destroy()
        actor.aim:Destroy()
        actor.fx:Destroy()
        if actor.root.Parent then
            actor.root.Anchored = actor.wasAnchored
            restoreOwnership(actor)
        end
    end
    duel.motion = nil
end

function Motion.canAct(duel, side, action)
    local actor = duel.actors[side]
    local root = actor.root
    if root.Parent ~= actor.character or not Match.inside(duel.bounds, root.Position) then
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
    return vector.Magnitude > .005 and workspace:Raycast(from, vector, duel.motion.arenaCast) ~= nil
end

local function floorContour(duel, actor, name, center, radius, direction, halfAngle, tint)
    return Geometry.groundContour({arena = duel, telegraph = actor.fx}, name, center, radius, direction, halfAngle, tint)
end

local function intendedPosition(duel, actor, opponent, origin, target, lowered, gap)
    local current = actor.root.Position
    local desired = Geometry.stopAtActor(current, target - current, opponent.root.Position, gap)
    local frame = CFrame.new(current - Vector3.new(0, lowered, 0)) * origin.Rotation
    local box = if lowered >= 1 then Vector3.new(1.12, 1.10, 1.12) else Vector3.new(1.52, 2.18, 1.38)
    return Geometry.safeTravel(duel.motion, current, current + desired, frame, box, duel.motion.arenaCast)
end

local function slideGuide(duel, actor, origin, distance)
    local start = floorPoint(duel, origin.Position)
    local feet = CFrame.new(start + Vector3.new(0, .76, 0)) * origin.Rotation
    local finish = Geometry.safeTravel(duel.motion, start, start + origin.LookVector * distance, feet,
        Vector3.new(1.12, 1.08, .92), duel.motion.arenaCast)
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
        cast.warning = floorContour(duel, actor, if fan then "Ember Sweep warning" else "Seismic Chest Pound warning",
            center, skill.radius, if fan then origin.LookVector else nil, skill.halfAngle, if fan then amber else gold)
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
    local path = (if action == "magmaTrail" then Salamander else Penguin).Travel[action]
    local offset = Geometry.pathOffset(path, age)
    if action == "magmaTrail" then
        local other = cast.origin:PointToObjectSpace(opponent.root.Position)
        local dx = offset.X - other.X
        local skirt = 1.90
        if other.Z < 0 and math.abs(dx) < skirt then
            return Vector3.new(offset.X, 0, math.max(offset.Z, other.Z + math.sqrt(skirt * skirt - dx * dx)))
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
            local maxStep = 18 * (at - cast.movedAt)
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
    local actor, other = duel.actors[index], duel.actors[3 - index]
    local state = duel.round.sides[index]
    local root, clip = actor.root, state.clip
    local traveling = clip and travelActions[clip.action]
    local planting = clip and plantedActions[clip.action]
    local live = now >= duel.round.startsAt and not duel.round.resolvedAt
    if live and (traveling or planting) then
        if not actor.cast or actor.cast.clip ~= clip then
            clearCast(actor)
            local orientation = heading(root.Position, other.root.Position, root.CFrame.LookVector)
            local origin = CFrame.lookAlong(root.Position, orientation)
            actor.cast = {clip = clip, origin = origin, movedAt = clip.startedAt, kit = state.kitId}
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
    local aim = heading(root.Position, other.root.Position, root.CFrame.LookVector)
    if actor.facing.CFrame.LookVector:Dot(aim) < .999 then
        actor.facing.CFrame = CFrame.lookAlong(Vector3.zero, aim)
    end
    remember(actor, now)
end

function Motion.move(duel, now)
    for index in duel.actors do
        updateActor(duel, index, now)
    end
end

local function poseAt(duel, index, now)
    local actor, state = duel.actors[index], duel.round.sides[index]
    local round = duel.round
    local action, age, direction
    if round.resolvedAt then
        local result = round.result[index]
        if result == "win" then
            action = "win"
        elseif result == "loss" then
            action = if state.kitId == "reedguard" then "stagger" else "knockout"
        else
            action = "stance"
        end
        age = now - round.resolvedAt
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
        if actor.cast and actor.cast.clip ~= state.clip then
            clearCast(actor)
        end
        if duel.round.resolvedAt then
            clearCast(actor)
            for _, marks in actor.marks do
                for _, mark in marks do
                    mark.warning:Destroy()
                end
            end
            table.clear(actor.marks)
            setHeld(actor, true)
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

local function magma(duel, attacker, defender, move, at, index, startedAt, target)
    local actor = duel.actors[attacker]
    local marks = actor.marks[startedAt]
    if move.marker then
        local cast = actor.cast
        if not cast or cast.clip.startedAt ~= startedAt or cast.movedAt < at - .001 then
            return false
        end
        local center = floorPoint(duel, clockFrame(actor, at).Position)
        if not Match.inside(duel.bounds, center + Vector3.yAxis)
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
    local mark = marks and marks[index]
    if not mark then
        return false
    end
    mark.warning:Destroy()
    marks[index] = nil
    if not next(marks) then
        actor.marks[startedAt] = nil
    end
    local hit, facing = floorContact(duel, defender, at, target, mark.center, move.radius)
    return hit ~= nil, mark.center, "body", facing
end

function Motion.strike(duel, side, action, move, at, index, castStartedAt)
    local other = 3 - side
    local actor = duel.actors[side]
    local root = clockFrame(actor, at)
    local target = clockFrame(duel.actors[other], at)
    if move.shape == "tile" then
        return magma(duel, side, other, move, at, index, castStartedAt, target)
    end
    local facing = defenderFacing(target, root.Position)
    if not Match.inside(duel.bounds, root.Position) or not Match.inside(duel.bounds, target.Position) then
        return false, nil, nil, facing
    end
    local fan = move.shape == "fan"
    if fan or move.shape == "radial" then
        local center = floorPoint(duel, root:PointToWorldSpace(move.center))
        local hit, guardFacing = floorContact(duel, other, at, target, center, move.radius, if fan then root.LookVector else nil,
            move.halfAngle)
        return hit ~= nil, if fan then hit or center else center, "body", guardFacing
    end
    local poses = duel.round.sides[side].kit.poses
    local offset = poses.Impact[action][index]
    local point = root:PointToWorldSpace(offset)
    local delta = Match.flat(target.Position - root.Position)
    if delta.Magnitude < .04 or delta.Unit:Dot(root.LookVector) < .41 then
        return false, point, nil, facing
    end
    local volumes = defenderVolumes(duel, other, at, target, facing)
    if action == "bellySlide" then
        local cast = actor.cast
        local previous = cast and cast.lastContact or point
        if cast then
            cast.lastContact = point
        end
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
                return true, hit, "body", facing
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
                local radius = if action == "uppercut" then .43 else .47
                if (near - point).Magnitude <= radius then
                    local contact = point:Lerp(near, .5)
                    if not obstructed(duel, root.Position, contact) then
                        return true, contact, volume.zone, facing
                    end
                end
            end
        end
    end
    return false, point, nil, facing
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
    else
        return
    end
    target.knock = {at = event.at, offset = offset, duration = duration, height = height, moved = 0}
end

return Motion
