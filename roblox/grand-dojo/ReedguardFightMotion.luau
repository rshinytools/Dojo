-- Featured sparring uses the same authored frame for posing and contact.
local Match = require(script.Parent.DojoMatchSupport)
local Reedguard = require(script.Parent.ReedguardCombatPoses)
local Juniper = require(script.Parent.JuniperCombatPoses)
local Penguin = require(script.Parent.PenguinCombatPoses)
local Bracken = require(script.Parent.BrackenCombatPoses)
local Silverback = require(script.Parent.SilverbackCombatPoses)
local Sablecrest = require(script.Parent.SablecrestCombatPoses)
local Salamander = require(script.Parent.FireSalamanderCombatPoses)
local Granite = require(script.Parent.GraniteCombatPoses)
local Motion = {}

local tracked = {"RootJoint", "Neck", "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip", "TailJoint"}
local slideClearance = 2.65
local brackenDriveClearance = 2.05
local slideTint = Color3.fromRGB(105, 213, 249)
local sablecrestDriveClearance = 2.48
local seismicTint = Color3.fromRGB(255, 206, 115)
local trailClearance = 2.44
local emberTint = Color3.fromRGB(255, 163, 82)

local playerKits = {
    reedguard = {poses = Reedguard, mixedSpacing = 2.85},
    penguin = {poses = Penguin, mixedSpacing = 2.68},
    silverback = {poses = Silverback, mixedSpacing = 3.13},
    salamander = {poses = Salamander, mixedSpacing = 2.49},
}

local residents = {
    juniper = {poses = Juniper, spacing = 3.13, diameter = 4.15, originalKit = "reedguard"},
    bracken = {poses = Bracken, spacing = 3.02, diameter = 3.15, originalKit = "penguin"},
    sablecrest = {poses = Sablecrest, spacing = 3.22, diameter = 2.90, originalKit = "silverback"},
    granite = {poses = Granite, spacing = 2.70, diameter = 3.18, originalKit = "salamander"},
}

local function penguin(bout)
    return bout.kit == "penguin"
end

local function silverback(bout)
    return bout.kit == "silverback"
end

local function salamander(bout)
    return bout.kit == "salamander"
end

local function directionTo(position, target, fallback)
    local offset = Match.flat(target - position)
    return if offset.Magnitude > .04 then offset.Unit else fallback
end

local function castParameters(instances)
    local parameters = RaycastParams.new()
    parameters.FilterDescendantsInstances = instances
    parameters.RespectCanCollide = true
    return parameters
end

local function keepClearance(bout)
    local clearance = bout.motion.contactSpace
    local offset = Vector3.new(0, 1.43, 0)
    if (clearance.Position - offset - bout.position).Magnitude > .005 then
        clearance.CFrame = CFrame.new(bout.position + offset) * CFrame.Angles(0, 0, math.pi / 2)
    end
end

local function drawLane(bout, field, position, finish, width, tint)
    local state = bout.motion
    local lane = state[field]
    local delta = Match.flat(finish - position)
    local length = delta.Magnitude
    if length < .15 then
        if lane then
            lane.Transparency = 1
        end
        return
    end
    if not lane then
        lane = Instance.new("Part")
        lane.Name = if field == "slideLane" then "Belly Slide lane"
            elseif field == "returnLane" then "Wind Court Return lane" else "Kiln Rush lane"
        lane.Anchored, lane.CanCollide, lane.CanTouch, lane.CanQuery = true, false, false, false
        lane.CastShadow, lane.Material, lane.Color = false, Enum.Material.Neon, tint
        lane.Parent = bout.telegraph
        state[field] = lane
    end
    local center = Vector3.new(position.X, bout.arena.floor + .045, position.Z) + delta / 2
    lane.Size = Vector3.new(width, .03, length)
    lane.CFrame = CFrame.lookAlong(center, delta.Unit)
    lane.Transparency = .62
end

local function clearLane(state, field)
    local lane = state[field]
    if lane and lane.Parent then
        lane:Destroy()
    end
    state[field] = nil
end

local function clearMagmaMarks(state)
    for _, marks in state.magmaMarks do
        for _, mark in marks do
            if mark.warning.Parent then
                mark.warning:Destroy()
            end
        end
    end
    table.clear(state.magmaMarks)
end

function Motion.open(bout)
    local character = bout.player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animate = character:FindFirstChild("Animate")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    local playerKit, resident = playerKits[bout.kit], residents[bout.botId]
    local originalPair = resident.originalKit == bout.kit
    local spacing = if originalPair then resident.spacing else math.min(resident.spacing, playerKit.mixedSpacing)
    -- The invisible bot collider leaves room for the player's half-width at melee distance.
    local diameter = if originalPair then resident.diameter else math.min(resident.diameter, 2 * (spacing - .76))
    local state = {motors = {}, anchored = bout.root.Anchored, autoRotate = humanoid.AutoRotate,
        autoJump = humanoid.AutoJumpEnabled, animate = animate, animateDisabled = animate and animate.Disabled,
        humanoid = humanoid, playerPoses = playerKit.poses, botPoses = resident.poses,
        spacing = spacing, diameter = diameter, originalPair = originalPair}
    for _, name in tracked do
        local motor = character:FindFirstChild(name, true)
        if motor and motor:IsA("Motor6D") then
            state.motors[name] = {motor = motor, rest = motor.C0}
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
    local contactSpace = Instance.new("Part")
    contactSpace.Name = bout.bot.Name .. " sparring clearance"
    contactSpace.Shape = Enum.PartType.Cylinder
    contactSpace.Size = Vector3.new(2.85, diameter, diameter)
    contactSpace.CFrame = CFrame.new(bout.position + Vector3.new(0, 1.43, 0))
        * CFrame.Angles(0, 0, math.pi / 2)
    contactSpace.Transparency = 1
    contactSpace.Anchored, contactSpace.CanCollide, contactSpace.CanTouch = true, true, false
    contactSpace.Parent = bout.bot
    state.contactSpace = contactSpace
    state.arenaCast = castParameters({character, bout.bot, bout.arena.bounds})
    state.avatarCast = castParameters({character, bout.arena.bounds})
    if salamander(bout) then
        state.magmaMarks = {}
    end

    local aim = Instance.new("Attachment")
    aim.Name = "Dojo opponent facing"
    aim.Parent = bout.root
    local facing = Instance.new("AlignOrientation")
    facing.Mode = Enum.OrientationAlignmentMode.OneAttachment
    facing.Attachment0 = aim
    facing.Responsiveness = 24
    facing.MaxTorque = 45000
    facing.CFrame = bout.root.CFrame.Rotation
    facing.Parent = bout.root
    state.aim, state.facing = aim, facing
    humanoid.AutoRotate = false
    humanoid.AutoJumpEnabled = false

    bout.root.Anchored = true
    state.holding = true
    bout.motion = state
end

function Motion.close(bout)
    local state = bout.motion
    clearLane(state, "slideLane")
    clearLane(state, "rushLane")
    clearLane(state, "returnLane")
    clearLane(state, "seismicWarning")
    if salamander(bout) then
        clearLane(state, "emberWarning")
        clearLane(state, "graniteWarning")
        clearMagmaMarks(state)
    end
    for _, joint in state.motors do
        if joint.motor.Parent then
            joint.motor.C0 = joint.rest
        end
    end
    if state.animate and state.animate.Parent then
        state.animate.Disabled = state.animateDisabled
    end
    state.facing:Destroy()
    state.aim:Destroy()
    if state.humanoid.Parent then
        state.humanoid.AutoRotate = state.autoRotate
        state.humanoid.AutoJumpEnabled = state.autoJump
    end
    if bout.root.Parent then
        bout.root.Anchored = state.anchored
    end
end

function Motion.canAct(bout, action)
    local groundedOnly = (penguin(bout) or silverback(bout) or salamander(bout))
        and (action == "dodge" or action == "signature") or ((silverback(bout) or salamander(bout)) and action == "secondary")
    if not groundedOnly then
        return true
    end
    local root = bout.root
    return root.Position.Y <= bout.arena.playerSpawn.Position.Y + .65
        and math.abs(root.AssemblyLinearVelocity.Y) <= 4
end

local function playerAction(bout, now)
    local round = bout.round
    if bout.outroAt then
        local age = now - bout.outroAt
        return if round.result == "win" then "win"
            elseif (penguin(bout) or silverback(bout) or salamander(bout)) and round.result == "loss"
            then "knockout" else "stagger", age
    elseif now < round.startsAt then
        return "intro", now - round.introAt
    elseif round.clip then
        return round.clip.action, now - round.clip.startedAt, round.clip.direction
    end
    local speed = Match.flat(bout.root.AssemblyLinearVelocity)
    if speed.Magnitude > 1.3 and math.abs(bout.root.AssemblyLinearVelocity.Y) < 6 then
        local forward = directionTo(bout.root.Position, bout.position, bout.root.CFrame.LookVector)
        return if speed:Dot(forward) >= 0 then "advance" else "retreat", now
    end
    return "stance", now
end

local function rememberPosition(samples, now, position)
    local latest = samples[#samples]
    if latest.at == now then
        latest.position = position
    elseif latest.at < now then
        table.insert(samples, {at = now, position = position})
    end
end

local function positionAt(samples, time)
    local last = samples[#samples]
    if time >= last.at then
        return last.position
    end
    for index = #samples - 1, 1, -1 do
        local before, after = samples[index], samples[index + 1]
        if time >= before.at then
            return before.position:Lerp(after.position, (time - before.at) / (after.at - before.at))
        end
    end
    return samples[1].position
end

local function pathOffset(waypoints, age)
    local first = waypoints[1]
    if age <= first.age then
        return first.offset
    end
    for index = 2, #waypoints do
        local before, after = waypoints[index - 1], waypoints[index]
        if age <= after.age then
            local alpha = (age - before.age) / (after.age - before.age)
            return before.offset:Lerp(after.offset, alpha)
        end
    end
    return waypoints[#waypoints].offset
end

local function groundPoint(bout, position)
    return Vector3.new(position.X, bout.arena.floor, position.Z)
end

local function safeTravel(bout, position, target, castStart, castSize, parameters)
    local clamped = Match.clampFloor(bout.arena.bounds, target, position.Y)
    local delta = clamped - position
    if delta.Magnitude <= .005 then
        return position, false
    end
    local hit = workspace:Blockcast(castStart, castSize, delta, parameters)
    if hit then
        return position + delta.Unit * math.max(0, hit.Distance - .065), true
    end
    return clamped, false
end

local function stopAtActor(position, movement, target, radius)
    local length = movement.Magnitude
    if length <= .005 then
        return movement
    end
    local direction = movement.Unit
    local offset = Match.flat(target - position)
    local along = offset:Dot(direction)
    if along <= 0 then
        return movement
    end
    local lateralSquared = offset:Dot(offset) - along * along
    local radiusSquared = radius * radius
    if lateralSquared >= radiusSquared then
        return movement
    end
    local available = along - math.sqrt(radiusSquared - lateralSquared)
    return direction * math.clamp(available, 0, length)
end

local function obstructed(bout, source, hit)
    local from = Vector3.new(source.X, hit.Y, source.Z)
    local travel = hit - from
    return travel.Magnitude > .005 and workspace:Raycast(from, travel, bout.motion.arenaCast) ~= nil
end

local function setTravelHold(bout, moving)
    local state = bout.motion
    local hold = moving or bout.outroAt ~= nil
    if hold ~= state.holding then
        bout.root.Anchored = hold or state.anchored
        state.holding = hold
    end
end

local function galleonLine(bout, folder, from, to, tint)
    if (to - from).Magnitude < .02 or not Match.inside(bout.arena.bounds, from + Vector3.yAxis)
        or not Match.inside(bout.arena.bounds, to + Vector3.yAxis) then
        return
    end
    local lift = Vector3.new(0, .085, 0)
    local line = Instance.new("Part")
    line.Name = "Floor warning edge"
    line.Size = Vector3.new(.132, .027, (from - to).Magnitude + .035)
    line.CFrame = CFrame.lookAt((from + to) * .5 + lift, to + lift)
    line.Anchored, line.CanCollide, line.CanTouch, line.CanQuery = true, false, false, false
    line.Material, line.Color, line.Transparency, line.CastShadow = Enum.Material.Neon, tint, .25, false
    line.Parent = folder
end

local function galleonContour(bout, name, center, radius, heading, halfAngle, tint)
    local warning = Instance.new("Folder")
    warning.Name = name
    local segments = if halfAngle then 10 else 16
    local limit = halfAngle or math.pi
    local direction = heading or Vector3.new(0, 0, -1)
    local previous
    for index = 0, segments do
        local yaw = -limit + 2 * limit * index / segments
        local offset = CFrame.Angles(0, yaw, 0):VectorToWorldSpace(direction) * radius
        local point = center + offset
        if previous then
            galleonLine(bout, warning, previous, point, tint)
        end
        if halfAngle and (index == 0 or index == segments) then
            galleonLine(bout, warning, center, point, tint)
        end
        previous = point
    end
    warning.Parent = bout.telegraph
    return warning
end

local function restoreClearance(bout, margin)
    local state = bout.motion
    local clearance, diameter = state.contactSpace, state.diameter
    if clearance.Size.Y ~= diameter
        and Match.flat(bout.root.Position - bout.position).Magnitude >= diameter * .5 + margin then
        clearance.Size = Vector3.new(2.85, diameter, diameter)
    end
end

local function magmaPath(bout, cast, now)
    local root, state = bout.root, bout.motion
    local path = Salamander.Travel.magmaTrail
    local limit = math.min(now, cast.clip.startedAt + path[#path].age)
    while cast.movedAt + .0001 < limit do
        local stepAt = math.min(cast.movedAt + 1 / 40, limit)
        for _, tile in Salamander.Skill.magmaTrail.tiles do
            local mark = cast.clip.startedAt + tile.markAt
            if mark > cast.movedAt + .0001 then
                stepAt = math.min(stepAt, mark)
            end
        end
        local offset = pathOffset(path, stepAt - cast.clip.startedAt)
        local obstacle = cast.origin:PointToObjectSpace(bout.position)
        local dx = offset.X - obstacle.X
        -- Cut shallower around the opponent when they occupy the nominal route.
        -- The extra margin keeps the curved section outside the movement cylinder.
        local skirt = 1.94
        if obstacle.Z < 0 and math.abs(dx) < skirt then
            local depth = obstacle.Z + math.sqrt(skirt * skirt - dx * dx)
            offset = Vector3.new(offset.X, 0, math.max(offset.Z, depth))
        end
        local current = root.Position
        local delta = cast.origin:PointToWorldSpace(offset) - current
        if delta.Magnitude > .005 then
            local maxStep = 18 * (stepAt - cast.movedAt)
            local desired = delta.Unit * math.min(delta.Magnitude, maxStep)
            local bounded = stopAtActor(current, desired, bout.position, 1.79)
            local box = CFrame.new(current - Vector3.new(0, .55, 0)) * cast.origin.Rotation
            local position = safeTravel(bout, current, current + bounded, box,
                Vector3.new(1.05, 2.24, 1.05), state.arenaCast)
            if (position - current).Magnitude > .005 then
                Match.move(root, CFrame.new(position) * cast.origin.Rotation)
            end
        end
        cast.movedAt = stepAt
        rememberPosition(cast.samples, stepAt, root.Position)
    end
end

local function galleonPlayer(bout, now)
    local state, round, root = bout.motion, bout.round, bout.root
    local clip = round.clip
    local action = clip and clip.action
    if bout.outroAt or (action ~= "sidestep" and action ~= "emberSweep" and action ~= "magmaTrail") then
        state.salamanderCast = nil
        clearLane(state, "emberWarning")
        if bout.outroAt and next(state.magmaMarks) then
            clearMagmaMarks(state)
        end
        restoreClearance(bout, .69)
        setTravelHold(bout, now < round.startsAt)
        return
    end
    local cast = state.salamanderCast
    if not cast or cast.clip ~= clip then
        cast = {clip = clip, origin = root.CFrame, movedAt = clip.startedAt,
            samples = {{at = clip.startedAt, position = root.Position}}}
        state.salamanderCast = cast
    end
    setTravelHold(bout, true)
    local age = now - clip.startedAt
    if action == "magmaTrail" then
        if state.contactSpace.Size.Y ~= trailClearance then
            state.contactSpace.Size = Vector3.new(2.85, trailClearance, trailClearance)
        end
        magmaPath(bout, cast, now)
    elseif action == "emberSweep" then
        local skill = Salamander.Skill.emberSweep
        if not state.emberWarning and age >= skill.warningAt and age < Salamander.Contact.emberSweep then
            local center = groundPoint(bout, cast.origin:PointToWorldSpace(skill.center))
            state.emberWarning = galleonContour(bout, "Ember Sweep warning", center, skill.radius,
                cast.origin.LookVector, skill.halfAngle, emberTint)
        elseif age >= Salamander.Contact.emberSweep then
            clearLane(state, "emberWarning")
        end
    elseif not cast.blocked then
        local alpha = math.clamp((age - .035) / .235, 0, 1)
        local eased = alpha * alpha * (3 - 2 * alpha)
        local right = cast.origin.RightVector
        local current = root.Position
        local desired = cast.origin.Position + right * (clip.direction * 2.40 * eased) - current
        local movement = stopAtActor(current, desired, bout.position, 2.12)
        local position, blocked = safeTravel(bout, current, current + movement,
            CFrame.new(current) * cast.origin.Rotation, Vector3.new(1.3, 2.2, 1.2), state.avatarCast)
        cast.blocked = blocked
        if (position - current).Magnitude > .005 then
            Match.move(root, CFrame.new(position) * cast.origin.Rotation)
        end
        rememberPosition(cast.samples, now, root.Position)
    end
end

local function seismicWarning(bout, center)
    local radius = Silverback.Skill.seismicChestPound.radius
    local warning = Instance.new("Folder")
    warning.Name = "Seismic Chest Pound warning"
    local function mark(name, size, frame, opacity, shape)
        local part = Instance.new("Part")
        part.Name, part.Size, part.CFrame = name, size, frame
        part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
        part.Material, part.Color, part.Transparency, part.CastShadow = Enum.Material.Neon, seismicTint, opacity, false
        part.Shape = shape or Enum.PartType.Block
        part.Parent = warning
    end
    local height = Vector3.new(0, .071, 0)
    local count = 18
    local step = 2 * math.pi / count
    local inside = true
    for index = 1, count do
        local a, b = index * step, (index + 1) * step
        local from = center + Vector3.new(math.cos(a) * radius, 0, math.sin(a) * radius)
        local to = center + Vector3.new(math.cos(b) * radius, 0, math.sin(b) * radius)
        if Match.inside(bout.arena.bounds, from + Vector3.yAxis)
            and Match.inside(bout.arena.bounds, to + Vector3.yAxis) then
            mark("Warning rim", Vector3.new(.115, .023, (to - from).Magnitude + .04),
                CFrame.lookAt((from + to) * .5 + height, to + height), .25)
        else
            inside = false
        end
    end
    if inside then
        mark("Warning area", Vector3.new(.015, radius * 2, radius * 2),
            CFrame.new(center + Vector3.new(0, .053, 0)) * CFrame.Angles(0, 0, math.pi / 2),
            .91, Enum.PartType.Cylinder)
    end
    warning.Parent = bout.telegraph
    bout.motion.seismicWarning = warning
end

local function skywalkPlayer(bout, now)
    local state, round, root = bout.motion, bout.round, bout.root
    local clip = round.clip
    local action = clip and clip.action
    if bout.outroAt or (action ~= "sidestep" and action ~= "seismicChestPound" and action ~= "ridgePalm") then
        state.skywalkCast = nil
        clearLane(state, "seismicWarning")
        setTravelHold(bout, now < round.startsAt)
        return
    end

    local cast = state.skywalkCast
    if not cast or cast.clip ~= clip then
        cast = {clip = clip, origin = root.CFrame, samples = {{at = clip.startedAt, position = root.Position}}}
        state.skywalkCast = cast
    end
    setTravelHold(bout, true)
    local age = now - clip.startedAt
    if action == "sidestep" and not cast.blocked then
        local alpha = math.clamp((age - .045) / .29, 0, 1)
        local eased = alpha * alpha * (3 - 2 * alpha)
        local side = Match.flat(cast.origin.RightVector).Unit * clip.direction * 2.23
        local current = root.Position
        local desired = cast.origin.Position + side * eased - current
        local allowed = stopAtActor(current, desired, bout.position, sablecrestDriveClearance)
        local frame = CFrame.new(current) * cast.origin.Rotation
        local position, blocked = safeTravel(bout, current, current + allowed, frame,
            Vector3.new(2.05, 2.30, 1.35), state.avatarCast)
        cast.blocked = blocked
        if (position - current).Magnitude > .005 then
            Match.move(root, CFrame.new(position) * cast.origin.Rotation)
        end
        rememberPosition(cast.samples, now, root.Position)
    elseif action == "seismicChestPound" then
        local skill = Silverback.Skill.seismicChestPound
        if not state.seismicWarning and age >= skill.warningAt and age < Silverback.Contact.seismicChestPound then
            seismicWarning(bout, groundPoint(bout, cast.origin:PointToWorldSpace(skill.center)))
        elseif age >= Silverback.Contact.seismicChestPound then
            clearLane(state, "seismicWarning")
        end
    end
end

local function penguinTravel(bout, now)
    local state, root, round = bout.motion, bout.root, bout.round
    local clip = round.clip
    local path = clip and Penguin.Travel[clip.action]
    if not path or bout.outroAt then
        state.playerTravel = nil
        clearLane(state, "slideLane")
        restoreClearance(bout, .655)
        setTravelHold(bout, now < round.startsAt)
        return
    end

    local slide = clip.action == "bellySlide"
    if slide and state.contactSpace.Size.Y ~= slideClearance then
        state.contactSpace.Size = Vector3.new(2.85, slideClearance, slideClearance)
    end
    local travel = state.playerTravel
    if not travel or travel.clip ~= clip then
        local start = root.CFrame
        travel = {clip = clip, origin = start, samples = {{at = clip.startedAt, position = start.Position}}}
        state.playerTravel = travel
    end
    local age = now - clip.startedAt
    setTravelHold(bout, true)
    local offset = pathOffset(path, age)
    if clip.direction == -1 then
        offset *= Vector3.new(-1, 1, 1)
    end
    if not travel.blocked then
        local current = root.Position
        local target = travel.origin:PointToWorldSpace(offset)
        local actorGap = if slide then 1.86 else brackenDriveClearance
        local desired = target - current
        local movement = stopAtActor(current, desired, bout.position, actorGap)
        if not slide and movement.Magnitude + .005 < desired.Magnitude then
            -- Cut the forward step when Bracken closes in so the turn can still evade sideways.
            local side = travel.origin.RightVector
            movement = stopAtActor(current, side * desired:Dot(side), bout.position, actorGap)
        end
        local center = if slide then current - Vector3.new(0, 1.32, 0) else current
        local size = if slide then Vector3.new(1.10, 1.08, 1.08) else Vector3.new(1.45, 2, 1.2)
        local position, blocked = safeTravel(bout, current, current + movement, CFrame.new(center) * travel.origin.Rotation,
            size, state.avatarCast)
        travel.blocked = blocked
        if (position - current).Magnitude > .005 then
            Match.move(root, CFrame.new(position) * travel.origin.Rotation)
        end
    end
    rememberPosition(travel.samples, now, root.Position)

    if slide and age < path[1].age and not travel.laneDrawn then
        local start = groundPoint(bout, travel.origin.Position)
        local target = travel.origin:PointToWorldSpace(path[#path].offset)
        local finish = safeTravel(bout, start, target,
            CFrame.new(start + Vector3.new(0, .82, 0)) * travel.origin.Rotation,
            Vector3.new(1.10, 1.08, 1.08), state.arenaCast)
        drawLane(bout, "slideLane", start, finish, 1.14, slideTint)
        travel.laneDrawn = true
    elseif age >= path[1].age then
        clearLane(state, "slideLane")
    end
end

local function playerDodge(bout, now)
    if penguin(bout) then
        penguinTravel(bout, now)
        return
    elseif silverback(bout) then
        skywalkPlayer(bout, now)
        return
    elseif salamander(bout) then
        galleonPlayer(bout, now)
        return
    end
    local state, root, clip = bout.motion, bout.root, bout.round.clip
    if clip and clip.action == "sidestep" and not bout.outroAt then
        if state.dodgeClip ~= clip then
            state.dodgeClip, state.dodgeFrom = clip, root.CFrame
            local origin = state.dodgeFrom
            local walk = Match.flat(origin.RightVector).Unit * clip.direction * 2.45
            local ray = RaycastParams.new()
            ray.FilterDescendantsInstances = {root.Parent, bout.bot}
            ray.RespectCanCollide = true
            local hit = workspace:Blockcast(origin, Vector3.new(1.45, 2, 1.2), walk, ray)
            state.dodgeTravel = if hit then walk.Unit * math.max(0, hit.Distance - .1) else walk
        end
        local alpha = math.clamp((now - clip.startedAt) / .23, 0, 1)
        local offset = state.dodgeTravel * (alpha * alpha * (3 - 2 * alpha))
        local origin = state.dodgeFrom
        local position = Match.clampFloor(bout.arena.bounds, origin.Position + offset, origin.Y)
        Match.move(root, origin + (position - origin.Position))
    else
        state.dodgeClip = nil
    end
    local hold = now < bout.round.startsAt or bout.outroAt ~= nil or state.dodgeClip ~= nil
    if hold ~= state.holding then
        root.Anchored = hold or state.anchored
        state.holding = hold
    end
end

local function brackenStep(bout, movement, orientation)
    local allowed = stopAtActor(bout.position, movement, bout.root.Position, brackenDriveClearance)
    local center = bout.position + Vector3.new(0, 1.41, 0)
    local position = safeTravel(bout, bout.position, bout.position + allowed,
        CFrame.new(center) * orientation.Rotation, Vector3.new(1.65, 2.55, 1.4), bout.motion.arenaCast)
    bout.position = position
end

local function brackenShove(bout, now)
    local state = bout.motion
    local shove = state.shove
    if not shove then
        return
    end
    local alpha = math.clamp((now - shove.at) / .20, 0, 1)
    local progress = 1 - (1 - alpha) * (1 - alpha)
    local motion = shove.offset * (progress - shove.progress)
    if motion.Magnitude > .005 then
        brackenStep(bout, motion, CFrame.lookAlong(Vector3.zero, shove.offset.Unit))
    end
    shove.progress = progress
    if alpha >= 1 then
        state.shove = nil
    end
end

local function brackenCommand(bout, now)
    local round, state = bout.round, bout.motion
    local phase = round.botPhase
    local attack = round.attack
    local descriptor = attack and Bracken.Attacks[attack.name]
    if phase == "ready" or not descriptor then
        state.brackenAction = nil
        clearLane(state, "rushLane")
        return
    end
    local action = state.brackenAction
    if not action or action.attack ~= attack then
        local heading = directionTo(bout.position, bout.root.Position, bout.direction)
        local locked = CFrame.lookAlong(bout.position, heading)
        action = {attack = attack, descriptor = descriptor, basis = locked, stepProgress = 0, driveProgress = 0,
            samples = {{at = round.botStartedAt, position = bout.position}}}
        state.brackenAction = action
    end
    local age = now - round.botStartedAt
    local heading = action.basis.LookVector
    if bout.outroAt or phase == "recovery" then
        clearLane(state, "rushLane")
        rememberPosition(action.samples, now, bout.position)
        return
    elseif phase == "setup" then
        local alpha = math.clamp((age - .12) / math.max(.01, attack.setupTime - .12), 0, 1)
        local stepLength = math.max(action.stepProgress, (attack.advance or 0) * alpha * alpha)
        brackenStep(bout, heading * (stepLength - action.stepProgress), action.basis)
        action.stepProgress = stepLength
    elseif phase == "windup" and descriptor.travelProgress then
        if not action.driveLength then
            local gap = Match.flat(bout.root.Position - bout.position).Magnitude
            action.driveLength = math.clamp(gap - 1.94, .35, 3.1)
        end
        local progress = math.max(action.driveProgress, descriptor.travelProgress(age, attack.windup))
        brackenStep(bout, heading * (action.driveLength * (progress - action.driveProgress)), action.basis)
        action.driveProgress = progress
    end
    rememberPosition(action.samples, now, bout.position)

    if descriptor.travelProgress and not action.laneDrawn then
        local target = action.basis.Position + heading * 4.35
        local start = groundPoint(bout, action.basis.Position)
        local finish = safeTravel(bout, start, target,
            CFrame.new(start + Vector3.new(0, .51, 0)) * action.basis.Rotation,
            Vector3.new(1.55, 1, 1.0), state.arenaCast)
        drawLane(bout, "rushLane", start, finish, 1.55, bout.profile.tint)
        action.laneDrawn = true
    end
end

local function sablecrestStep(bout, movement, basis)
    local allowed = stopAtActor(bout.position, movement, bout.root.Position, sablecrestDriveClearance)
    local center = bout.position + Vector3.new(0, 1.24, 0)
    bout.position = safeTravel(bout, bout.position, bout.position + allowed, CFrame.new(center) * basis.Rotation,
        Vector3.new(1.44, 2.34, 1.36), bout.motion.arenaCast)
end

local function sablecrestShove(bout, now)
    local state, shove = bout.motion, bout.motion.shove
    if not shove then
        return
    end
    local alpha = math.clamp((now - shove.at) / shove.duration, 0, 1)
    local progress = 1 - (1 - alpha) * (1 - alpha)
    local movement = shove.offset * (progress - shove.progress)
    if movement.Magnitude > .005 then
        sablecrestStep(bout, movement, shove.basis)
    end
    state.skywalkLift = if shove.height then 4 * alpha * (1 - alpha) * shove.height else 0
    shove.progress = progress
    if alpha >= 1 then
        state.shove = nil
    end
end

local function sablecrestCommand(bout, now)
    local state, round = bout.motion, bout.round
    local phase, attack = round.botPhase, round.attack
    local descriptor = attack and Sablecrest.Attacks[attack.name]
    if phase == "ready" or not descriptor then
        state.sablecrestAction = nil
        clearLane(state, "returnLane")
        return
    end
    local action = state.sablecrestAction
    if not action or action.attack ~= attack then
        local heading = directionTo(bout.position, bout.root.Position, bout.direction)
        action = {attack = attack, descriptor = descriptor, basis = CFrame.lookAlong(bout.position, heading),
            setupProgress = 0, driveProgress = 0, samples = {{at = round.botStartedAt, position = bout.position}}}
        state.sablecrestAction = action
    end
    local age = now - round.botStartedAt
    if bout.outroAt or phase == "recovery" then
        clearLane(state, "returnLane")
    elseif phase == "setup" then
        local progress = math.max(action.setupProgress, descriptor.setupProgress(age, attack.setupTime))
        local step = action.basis.RightVector * attack.strafe * (progress - action.setupProgress)
        sablecrestStep(bout, step, action.basis)
        action.setupProgress = progress
    elseif phase == "windup" and descriptor.travelProgress then
        if not action.strikeBasis then
            local heading = directionTo(bout.position, bout.root.Position, action.basis.LookVector)
            local basis = CFrame.lookAlong(bout.position, heading)
            action.strikeBasis = basis
            local gap = Match.flat(bout.root.Position - bout.position).Magnitude
            action.driveLength = math.clamp(gap - sablecrestDriveClearance, .46, descriptor.maxTravel)
            local start = groundPoint(bout, basis.Position)
            local tip = Sablecrest.sample(descriptor.windup, attack.windup, attack.windup)
            local joint = bout.joints[descriptor.group].joint
            local contact = (tip.root * joint * tip.groups[descriptor.group]):PointToWorldSpace(descriptor.point)
            local length = action.driveLength - contact.Z
            local finish = safeTravel(bout, start, start + heading * length,
                CFrame.new(start + Vector3.new(0, .49, 0)) * basis.Rotation,
                Vector3.new(attack.width, .88, .62), state.arenaCast)
            drawLane(bout, "returnLane", start, finish, attack.width, bout.profile.tint)
        end
        local progress = math.max(action.driveProgress, descriptor.travelProgress(age, attack.windup))
        local drive = action.strikeBasis.LookVector * action.driveLength * (progress - action.driveProgress)
        sablecrestStep(bout, drive, action.strikeBasis)
        action.driveProgress = progress
    end
    rememberPosition(action.samples, now, bout.position)
end

local function graniteStep(bout, movement, orientation)
    local minimumGap = if bout.motion.contactSpace.Size.Y == trailClearance then 1.79 else 2.32
    local allowed = stopAtActor(bout.position, movement, bout.root.Position, minimumGap)
    local center = bout.position + Vector3.new(0, 1.51, 0)
    bout.position = safeTravel(bout, bout.position, bout.position + allowed,
        CFrame.new(center) * orientation.Rotation, Vector3.new(2.02, 2.85, 1.8), bout.motion.arenaCast)
end

local function graniteAttackPoint(bout, command, age, basis)
    local descriptor = command.descriptor
    local pose = Granite.sample(descriptor.windup, age, command.attack.windup)
    local joint = bout.joints[descriptor.group].joint
    return (basis * pose.root * joint * pose.groups[descriptor.group]):PointToWorldSpace(descriptor.point)
end

local function graniteCommand(bout, now)
    local state, round = bout.motion, bout.round
    local phase, attack = round.botPhase, round.attack
    local descriptor = attack and Granite.Attacks[attack.name]
    if phase == "ready" or not descriptor then
        state.graniteAction = nil
        clearLane(state, "graniteWarning")
        return
    end
    local action = state.graniteAction
    if not action or action.attack ~= attack then
        local heading = directionTo(bout.position, bout.root.Position, bout.direction)
        local basis = CFrame.lookAlong(bout.position, heading)
        action = {attack = attack, descriptor = descriptor, basis = basis,
            samples = {{at = round.botStartedAt, position = bout.position}}}
        state.graniteAction = action
    end
    if bout.outroAt or phase == "recovery" then
        clearLane(state, "graniteWarning")
    elseif phase == "windup" and not action.marked then
        if descriptor.groundPulse then
            local sole = graniteAttackPoint(bout, action, attack.windup, action.basis)
            action.stampCenter = groundPoint(bout, sole)
            action.stampRadius = math.min(4.25, attack.reach)
            state.graniteWarning = galleonContour(bout, "Breakwater Stamp warning", action.stampCenter,
                action.stampRadius, nil, nil, bout.profile.tint)
        else
            local warning = Instance.new("Folder")
            warning.Name = "Harbor Sweep warning"
            local startAge = attack.windup * descriptor.contactFrom / descriptor.contactAt
            local previous
            for index = 0, 10 do
                local age = startAge + (attack.windup - startAge) * index / 10
                local point = groundPoint(bout, graniteAttackPoint(bout, action, age, action.basis))
                if previous and not obstructed(bout, action.basis.Position, point + Vector3.new(0, .20, 0)) then
                    galleonLine(bout, warning, previous, point, bout.profile.tint)
                end
                previous = point
            end
            warning.Parent = bout.telegraph
            state.graniteWarning = warning
        end
        action.marked = true
    end
    rememberPosition(action.samples, now, bout.position)
end

local function granitePop(bout, now)
    local state, pop = bout.motion, bout.motion.galleonPop
    if pop then
        local age = math.clamp((now - pop.at) / .28, 0, 1)
        state.galleonLift = 4 * age * (1 - age) * Salamander.Skill.magmaTrail.popHeight
        if age >= 1 then
            state.galleonPop = nil
        end
    end
end

local function juniperStep(bout, movement, orientation)
    if bout.motion.originalPair then
        bout.position = Match.clampFloor(bout.arena.bounds, bout.position + movement, bout.arena.floor)
        return
    end
    local allowed = stopAtActor(bout.position, movement, bout.root.Position, 2.23)
    local center = bout.position + Vector3.new(0, 1.32, 0)
    bout.position = safeTravel(bout, bout.position, bout.position + allowed,
        CFrame.new(center) * orientation.Rotation, Vector3.new(2.15, 2.5, 1.9), bout.motion.arenaCast)
end

local residentStep = {juniper = juniperStep, bracken = brackenStep, sablecrest = sablecrestStep, granite = graniteStep}
local residentCommand = {bracken = brackenCommand, sablecrest = sablecrestCommand, granite = graniteCommand}
local residentReaction = {bracken = brackenShove, sablecrest = sablecrestShove, granite = granitePop}

local function moveCrossKnock(bout, now)
    local state, knock = bout.motion, bout.motion.crossKnock
    if not knock then
        return
    end
    local alpha = math.clamp((now - knock.at) / knock.duration, 0, 1)
    local progress = 1 - (1 - alpha) * (1 - alpha)
    local motion = knock.offset * (progress - knock.progress)
    if motion.Magnitude > .005 then
        residentStep[bout.botId](bout, motion, knock.basis)
    end
    state.crossLift = 4 * alpha * (1 - alpha) * knock.height
    knock.progress = progress
    if alpha >= 1 then
        state.crossKnock = nil
    end
end

local function botAction(bout, now)
    local round = bout.round
    if bout.outroAt then
        local action = if round.result == "win" then "knockout" elseif round.result == "loss" then "win" else "idle"
        return action, now - bout.outroAt
    elseif now < round.startsAt then
        return "intro", now - round.introAt
    elseif bout.botId ~= "juniper" then
        local attack = round.attack
        local cue = attack and bout.motion.botPoses.Attacks[attack.name]
        if cue then
            if round.botPhase == "windup" then
                return cue.windup, now - round.botStartedAt, attack.windup
            elseif round.botPhase == "setup" then
                return cue.setup or "idle", now - round.botStartedAt, attack.setupTime
            elseif round.botPhase == "recovery" then
                local elapsed = now - round.recoveryStartedAt
                local reaction = if round.recoveryKind == "parried" then cue.deflect
                    elseif round.recoveryKind == "blocked" then cue.blocked else cue.recover
                if elapsed < .28 or not bout.reactionAt or now - bout.reactionAt >= .28 then
                    return reaction, elapsed
                end
            end
        end
        if bout.reactionAt and now - bout.reactionAt < .28 then
            return bout.reactionAction, now - bout.reactionAt
        end
        return if bout.moving then "step" else "idle", now
    elseif round.botPhase == "windup" then
        return "palm", now - round.botStartedAt, round.attack.windup
    elseif round.botPhase == "setup" then
        return "brace", now - round.botStartedAt, round.attack.setupTime
    elseif round.botPhase == "recovery" and now - round.recoveryStartedAt < .52 then
        local action = if round.recoveryKind == "parried" then "deflect"
            elseif round.recoveryKind == "blocked" then "blocked" else "recover"
        return action, now - round.recoveryStartedAt
    elseif bout.reactionAt and now - bout.reactionAt < .28 then
        return bout.reactionAction, now - bout.reactionAt
    end
    return if bout.moving then "step" else "idle", now
end

local function botBase(bout, time)
    local round, state = bout.round, bout.motion
    local lift = Vector3.new(0, (state.galleonLift or 0) + (state.skywalkLift or 0) + (state.crossLift or 0), 0)
    if bout.botId ~= "juniper" then
        local command = if bout.botId == "granite" then state.graniteAction
            elseif bout.botId == "sablecrest" then state.sablecrestAction else state.brackenAction
        if command then
            local floor = if time then positionAt(command.samples, time) else bout.position
            return CFrame.new(floor + lift) * (command.strikeBasis or command.basis).Rotation
        end
        return CFrame.lookAlong(bout.position + lift, bout.direction)
    end
    if round.botPhase == "windup" or round.botPhase == "recovery" then
        if state.attackStartedAt ~= round.botStartedAt then
            state.attackStartedAt = round.botStartedAt
            local toward = directionTo(bout.position, bout.root.Position, bout.direction)
            state.attackFrame = CFrame.lookAt(bout.position, bout.position + toward)
        end
        return if state.originalPair then state.attackFrame else CFrame.new(bout.position + lift) * state.attackFrame.Rotation
    end
    local position = bout.position + lift
    return CFrame.lookAt(position, position + bout.direction)
end

local function botPose(bout, now)
    local action, age, duration = botAction(bout, now)
    local pose = bout.motion.botPoses.sample(action, age, duration)
    return botBase(bout, now) * pose.root, pose.groups
end

local function jointFrame(frame, groups, name, joint)
    return frame * joint.joint * (groups[name] or CFrame.identity)
end

local function nearestPoint(frame, size, point)
    local localPoint = frame:PointToObjectSpace(point)
    local half = size * .5
    local nearest = Vector3.new(math.clamp(localPoint.X, -half.X, half.X),
        math.clamp(localPoint.Y, -half.Y, half.Y), math.clamp(localPoint.Z, -half.Z, half.Z))
    return frame:PointToWorldSpace(nearest)
end

local function overlap(frame, size, point, radius)
    return (point - nearestPoint(frame, size, point)).Magnitude <= radius
end

local function sweptContact(from, to, frame, size, radius)
    local steps = math.max(1, math.ceil((to - from).Magnitude / .14))
    for step = 0, steps do
        local point = from:Lerp(to, step / steps)
        local closest = nearestPoint(frame, size, point)
        if (point - closest).Magnitude <= radius then
            return point:Lerp(closest, .5)
        end
    end
    return nil
end

local function actorRootAt(bout, time)
    local travel = if silverback(bout) then bout.motion.skywalkCast
        elseif salamander(bout) then bout.motion.salamanderCast else bout.motion.playerTravel
    if travel then
        return CFrame.new(positionAt(travel.samples, time)) * travel.origin.Rotation
    end
    return bout.root.CFrame
end

local function slideContact(bout, time, index)
    local travel = bout.motion.playerTravel
    local tip = Penguin.Impact.bellySlide[index]
    local root = actorRootAt(bout, time)
    local point = root:PointToWorldSpace(tip)
    if not travel then
        return false, point
    end
    local before = travel.previousContact or point
    travel.previousContact = point
    local frame, groups = botPose(bout, time)
    for _, name in {"Right Leg", "Left Leg", "Torso"} do
        local joint = bout.joints[name]
        if not joint then
            continue
        end
        local targetFrame = jointFrame(frame, groups, name, joint) * joint.shell
        local size = joint.part.Size
        if name == "Torso" then
            targetFrame *= CFrame.new(0, -size.Y * .24, 0)
            size *= Vector3.new(1, .52, 1)
        end
        local hit = sweptContact(before, point, targetFrame, size, .43)
        if hit and not obstructed(bout, root.Position, hit) then
            return true, hit, "body"
        end
    end
    return false, point
end

local function seismicContact(bout, move, time)
    local cast = bout.motion.skywalkCast
    local center = groundPoint(bout, actorRootAt(bout, time):PointToWorldSpace(move.center))
    if not cast then
        return false, center
    end
    local frame, groups = botPose(bout, time)
    for _, name in {"Right Leg", "Left Leg"} do
        local joint = bout.joints[name]
        local foot = jointFrame(frame, groups, name, joint) * joint.shell
        local edge = nearestPoint(foot, joint.part.Size, center + Vector3.new(0, .34, 0))
        if edge.Y <= center.Y + .83 and Match.flat(edge - center).Magnitude <= move.radius
            and not obstructed(bout, center, edge + Vector3.new(0, .08, 0)) then
            return true, center, "body"
        end
    end
    return false, center
end

local function silverbackStrike(bout, action, move, time, index)
    if action == "seismicChestPound" then
        return seismicContact(bout, move, time)
    end
    local root = actorRootAt(bout, time)
    local point = root:PointToWorldSpace(Silverback.Impact[action][index])
    local offset = Match.flat(bout.position - root.Position)
    if offset.Magnitude < .05 or offset.Magnitude > 4.20 or offset.Unit:Dot(root.LookVector) < .42 then
        return false, point
    end
    local frame, groups = botPose(bout, time)
    local targets = if action == "ridgePalm" then {"Torso", "Right Arm", "Left Arm"}
        elseif move.zone == "head" then {"Head", "Torso"} else {"Torso"}
    for _, name in targets do
        local joint = bout.joints[name]
        local target = jointFrame(frame, groups, name, joint) * joint.shell
        local nearest = nearestPoint(target, joint.part.Size, point)
        local radius = if action == "ridgePalm" then .46 else .42
        if (point - nearest).Magnitude <= radius then
            local contact = point:Lerp(nearest, .5)
            if not obstructed(bout, root.Position, contact) then
                return true, contact, if name == "Head" then "head" else "body"
            end
        end
    end
    return false, point
end

local function footContact(bout, time, center, radius, direction, angle)
    local frame, groups = botPose(bout, time)
    local target = center + Vector3.new(0, .23, 0)
    for _, name in {"Right Leg", "Left Leg"} do
        local joint = bout.joints[name]
        local foot = jointFrame(frame, groups, name, joint) * joint.shell
        local edge = nearestPoint(foot, joint.part.Size, target)
        local offset = Match.flat(edge - center)
        if edge.Y <= center.Y + .86 and offset.Magnitude <= radius
            and (not direction or offset.Magnitude <= .01 or offset.Unit:Dot(direction) >= math.cos(angle))
            and not obstructed(bout, center, edge + Vector3.new(0, .125, 0)) then
            return edge
        end
    end
    return nil
end

local function magmaContact(bout, move, time, index, castStartedAt)
    local state = bout.motion
    local marks = state.magmaMarks[castStartedAt]
    if move.marker then
        local cast = state.salamanderCast
        if not cast or cast.clip.startedAt ~= castStartedAt or cast.movedAt < time - .001 then
            return false
        end
        local center = groundPoint(bout, positionAt(cast.samples, time))
        if not Match.inside(bout.arena.bounds, center + Vector3.yAxis)
            or Match.flat(center - cast.origin.Position).Magnitude < .30
            or (marks and marks[1] and (center - marks[1].center).Magnitude < move.radius) then
            return false
        end
        if not marks then
            marks = {}
            state.magmaMarks[castStartedAt] = marks
        end
        local name = if index == 1 then "Magma Trail first mark" else "Magma Trail second mark"
        local warning = galleonContour(bout, name, center, move.radius, nil, nil, emberTint)
        marks[index] = {center = center, warning = warning}
        return true, center
    end
    local mark = marks and marks[index]
    if not mark then
        return false
    end
    mark.warning:Destroy()
    marks[index] = nil
    if not next(marks) then
        state.magmaMarks[castStartedAt] = nil
    end
    local hit = footContact(bout, time, mark.center, move.radius) ~= nil
    return hit, mark.center, "body"
end

local function salamanderStrike(bout, action, move, time, index, castStartedAt)
    if action == "magmaTrail" then
        return magmaContact(bout, move, time, index, castStartedAt)
    end
    local root = actorRootAt(bout, time)
    local point = root:PointToWorldSpace(Salamander.Impact[action][index])
    if action == "emberSweep" then
        local center = groundPoint(bout, root:PointToWorldSpace(move.center))
        local hit = footContact(bout, time, center, move.radius, root.LookVector, move.halfAngle)
        return hit ~= nil, hit or point, "body"
    end
    local offset = Match.flat(bout.position - root.Position)
    if offset.Magnitude < .05 or offset.Magnitude > 3.65 or offset.Unit:Dot(root.LookVector) < .43 then
        return false, point
    end
    local frame, groups = botPose(bout, time)
    for _, name in if move.zone == "head" then {"Head", "Torso"} else {"Torso"} do
        local joint = bout.joints[name]
        local target = jointFrame(frame, groups, name, joint) * joint.shell
        local nearest = nearestPoint(target, joint.part.Size, point)
        local contact = point:Lerp(nearest, .5)
        if (point - nearest).Magnitude <= .46 and not obstructed(bout, root.Position, contact) then
            return true, contact, if name == "Head" then "head" else "body"
        end
    end
    return false, point
end

function Motion.strike(bout, action, move, time, index, castStartedAt)
    if salamander(bout) then
        return salamanderStrike(bout, action, move, time, index, castStartedAt)
    elseif silverback(bout) then
        return silverbackStrike(bout, action, move, time, index)
    elseif action == "bellySlide" and penguin(bout) then
        return slideContact(bout, time, index)
    end
    local point = bout.root.CFrame:PointToWorldSpace(bout.motion.playerPoses.Impact[action][index])
    local frame, groups = botPose(bout, time)
    local offset = Match.flat(bout.position - bout.root.Position)
    if offset.Magnitude < .05 or offset.Magnitude > 3.55 or offset.Unit:Dot(bout.root.CFrame.LookVector) < .52 then
        return false, point
    end
    for _, name in if move.zone == "head" then {"Head", "Torso"} else {"Torso"} do
        local joint = bout.joints[name]
        local targetFrame, size = jointFrame(frame, groups, name, joint) * joint.shell, joint.part.Size
        if action == "uppercut" and name == "Torso" then
            targetFrame *= CFrame.new(0, size.Y * .22, 0)
            size *= Vector3.new(1, .56, 1)
        end
        local nearest = nearestPoint(targetFrame, size, point)
        local radius = if action == "uppercut" then .43 else .52
        if (point - nearest).Magnitude <= radius then
            local zone = if name == "Head" then "head" else "body"
            return true, point:Lerp(nearest, .5), zone
        end
    end
    return false, point
end

local function fittedVolumes(character, root, motors, offsets, guardFacing)
    local shell = character:FindFirstChild("Starter Fighter Shell")
    if not shell then
        return {}
    end
    local rootJoint = motors.RootJoint
    if not rootJoint then
        return {}
    end
    local torso = root * offsets.RootJoint * rootJoint.rest * rootJoint.motor.C1:Inverse()
    local volumes = {}
    local function add(name, motorName, zone, grounded)
        local mesh = shell:FindFirstChild(name)
        local weld = mesh and mesh:FindFirstChildOfClass("Weld")
        local joint = motorName and motors[motorName]
        if not (mesh and weld) or (motorName and not joint) then
            return
        end
        local carrier = if joint then torso * offsets[motorName] * joint.rest * joint.motor.C1:Inverse() else torso
        table.insert(volumes,
            {frame = carrier * weld.C0 * weld.C1:Inverse(), size = mesh.Size, zone = zone, grounded = grounded})
    end
    if guardFacing then
        add("Right Arm", "Right Shoulder", "body")
        add("Left Arm", "Left Shoulder", "body")
    end
    add("Head", "Neck", "head")
    add("Torso", nil, "body")
    add("Right Leg", "Right Hip", "body", true)
    add("Left Leg", "Left Hip", "body", true)
    return volumes
end

local function actorVolumes(bout, time, guardFacing)
    local state = bout.motion
    local action, age, direction = playerAction(bout, time)
    local offsets = state.playerPoses.sample(action, age, direction)
    return fittedVolumes(bout.root.Parent, actorRootAt(bout, time), state.motors, offsets, guardFacing)
end

local function featuredBotStrike(bout, time)
    local command
    if bout.botId == "sablecrest" then
        sablecrestCommand(bout, time)
        command = bout.motion.sablecrestAction
    else
        brackenCommand(bout, time)
        command = bout.motion.brackenAction
    end
    local round = bout.round
    local attack = round.attack
    local descriptor = command and command.descriptor
    if not descriptor then
        return false, false, "body", bout.position
    end
    local root = bout.root
    local facing = directionTo(root.Position, bout.position, root.CFrame.LookVector):Dot(root.CFrame.LookVector) >= .38
    local guard = round.guardUntil >= time and time >= round.guardFrom + .055
    local volumes = actorVolumes(bout, time, guard and facing)
    local joint = bout.joints[descriptor.group]
    local readyAt = round.botStartedAt
    local function strikePoint(age)
        local pose = bout.motion.botPoses.sample(descriptor.windup, age, attack.windup)
        local frame = botBase(bout, readyAt + age) * pose.root
        return jointFrame(frame, pose.groups, descriptor.group, joint):PointToWorldSpace(descriptor.point)
    end
    local windup = attack.windup
    local startAge = windup * (if descriptor.travelProgress then .77 else .85)
    local from = strikePoint(startAge)
    for index = 1, 4 do
        local to = strikePoint(startAge + (windup - startAge) * index / 4)
        for _, volume in volumes do
            local hit = sweptContact(from, to, volume.frame, volume.size, descriptor.radius)
            if hit and not obstructed(bout, positionAt(command.samples, readyAt + startAge), hit) then
                return true, facing, volume.zone, hit
            end
        end
        from = to
    end
    return false, facing, "body", from
end

local function graniteStrike(bout, time)
    graniteCommand(bout, time)
    local command = bout.motion.graniteAction
    if not command then
        return false, false, "body", bout.position
    end
    local root, round = bout.root, bout.round
    local facing = directionTo(root.Position, bout.position, root.CFrame.LookVector):Dot(root.CFrame.LookVector) >= .38
    local guard = round.guardUntil >= time and time >= round.guardFrom + .055
    local volumes = actorVolumes(bout, time, guard and facing)
    if command.stampCenter then
        local center = command.stampCenter
        for _, volume in volumes do
            if volume.grounded then
                local edge = nearestPoint(volume.frame, volume.size, center + Vector3.new(0, .22, 0))
                if edge.Y <= center.Y + .71 and Match.flat(edge - center).Magnitude <= command.stampRadius
                    and not obstructed(bout, center, edge + Vector3.new(0, .125, 0)) then
                    return true, facing, "body", center
                end
            end
        end
        return false, facing, "body", center
    end
    local attack, descriptor = command.attack, command.descriptor
    local firstAge = attack.windup * descriptor.contactFrom / descriptor.contactAt
    local function pointAt(age)
        return graniteAttackPoint(bout, command, age, botBase(bout, round.botStartedAt + age))
    end
    local previous = pointAt(firstAge)
    for index = 1, 10 do
        local finish = pointAt(firstAge + (attack.windup - firstAge) * index / 10)
        for _, volume in volumes do
            local hit = sweptContact(previous, finish, volume.frame, volume.size, descriptor.radius)
            if hit and not obstructed(bout, bout.position, hit) then
                return true, facing, volume.zone, hit
            end
        end
        previous = finish
    end
    return false, facing, "body", previous
end

function Motion.palm(bout, time)
    if bout.botId == "granite" then
        return graniteStrike(bout, time)
    elseif bout.botId ~= "juniper" then
        return featuredBotStrike(bout, time)
    end
    local pose = Juniper.sample("palm", bout.round.attack.windup, bout.round.attack.windup)
    local joint = bout.joints["Right Arm"]
    local frame = botBase(bout) * pose.root
    local point = jointFrame(frame, pose.groups, "Right Arm", joint):PointToWorldSpace(Juniper.PalmContact)
    local root = bout.root
    local facing = directionTo(root.Position, bout.position, root.CFrame.LookVector):Dot(root.CFrame.LookVector) >= .38
    local guard = bout.round.guardUntil >= time and time >= bout.round.guardFrom + .055
    if not bout.motion.originalPair then
        for _, volume in actorVolumes(bout, time, guard and facing) do
            local radius = if volume.zone == "head" then .42 else .52
            if overlap(volume.frame, volume.size, point, radius) and not obstructed(bout, bout.position, point) then
                return true, facing, volume.zone, point
            end
        end
        return false, facing, "body", point
    end
    local torso = root.CFrame * CFrame.new(0, .01, 0)
    local head = root.CFrame * CFrame.new(0, .82, -.05)
    local zone = if overlap(head, Vector3.new(1.11, .83, 1), point, .42) then "head" else "body"
    local hit = zone == "head" or overlap(torso, Vector3.new(1.14, 1.5, .92), point, .52)
    if not hit and guard and facing then
        hit = overlap(root.CFrame * CFrame.new(0, .37, -.54), Vector3.new(1.3, 1.1, .5), point, .42)
    end
    return hit, facing, zone, point
end

function Motion.move(bout, now, dt)
    playerDodge(bout, now)
    local round, state = bout.round, bout.motion
    moveCrossKnock(bout, now)
    local command, reaction = residentCommand[bout.botId], residentReaction[bout.botId]
    if reaction then
        reaction(bout, now)
    end
    if command then
        command(bout, now)
        keepClearance(bout)
    end
    local offset = Match.flat(bout.root.Position - bout.position)
    local distance = offset.Magnitude
    if not bout.outroAt and (round.botPhase == "ready" or round.botPhase == "setup") and distance > .04 then
        bout.direction = offset.Unit
    end
    local spacing = state.spacing
    bout.moving = not bout.outroAt and not state.shove and not state.crossKnock and now >= round.startsAt
        and round.botPhase == "ready" and distance > spacing
    if bout.moving then
        local travel = bout.direction * math.min(distance - spacing, dt * bout.profile.pace)
        residentStep[bout.botId](bout, travel, CFrame.lookAlong(Vector3.zero, bout.direction))
        if command then
            keepClearance(bout)
        end
    end
    local gap = Match.flat(bout.root.Position - bout.position)
    if not bout.outroAt and now >= round.startsAt and gap.Magnitude > .05 then
        local target = -gap.Unit
        if state.facing.CFrame.LookVector:Dot(target) < .999 then
            state.facing.CFrame = CFrame.lookAlong(Vector3.zero, target)
        end
    end
    return gap.Magnitude
end

function Motion.render(bout, now)
    if silverback(bout) then
        skywalkPlayer(bout, now)
    elseif salamander(bout) then
        galleonPlayer(bout, now)
    end
    local command = residentCommand[bout.botId]
    if command then
        command(bout, now)
    end
    local action, age, direction = playerAction(bout, now)
    local offsets = bout.motion.playerPoses.sample(action, age, direction)
    for name, joint in bout.motion.motors do
        joint.motor.C0 = (offsets[name] or CFrame.identity) * joint.rest
    end
    local frame, groups = botPose(bout, now)
    bout.bot.PrimaryPart.CFrame = botBase(bout)
    keepClearance(bout)
    for name, joint in bout.joints do
        joint.part.CFrame = jointFrame(frame, groups, name, joint) * joint.shell
    end
end

function Motion.impact(bout, event)
    if event.source ~= "bot" and event.attack ~= "palm" and (event.damage or 0) > 0 then
        bout.reactionAt = event.at
        bout.reactionAction = if event.zone == "head" then "headHit" else "bodyHit"
        if event.attack == "bellySlide" and penguin(bout) then
            local state = bout.motion
            local travel = state.playerTravel
            if travel then
                local heading = travel.origin.LookVector
                local shove = {at = event.at, offset = heading * 1.38, progress = 0}
                if state.originalPair then
                    state.shove = shove
                else
                    shove.duration, shove.height = .20, 0
                    shove.basis = CFrame.lookAlong(Vector3.zero, heading)
                    state.crossKnock = shove
                end
            end
        elseif salamander(bout) and event.attack == "magmaTrail" then
            local state = bout.motion
            if state.originalPair then
                state.galleonPop = {at = event.at}
            else
                state.crossKnock = {at = event.at, offset = Vector3.zero, progress = 0, duration = .28,
                    height = Salamander.Skill.magmaTrail.popHeight}
            end
        elseif silverback(bout) and (event.attack == "ridgePalm" or event.attack == "seismicChestPound") then
            local state = bout.motion
            local cast = state.skywalkCast
            if cast then
                local seismic = event.attack == "seismicChestPound"
                local heading = if seismic then directionTo(cast.origin.Position, bout.position, cast.origin.LookVector)
                    else cast.origin.LookVector
                local length = if seismic then .38 else Silverback.Skill.ridgePalm.shove
                local shove = {at = event.at, offset = heading * length, progress = 0,
                    duration = if seismic then .27 else .22,
                    height = if seismic then Silverback.Skill.seismicChestPound.popHeight else 0,
                    basis = CFrame.lookAlong(Vector3.zero, heading)}
                if state.originalPair then
                    state.shove = shove
                else
                    state.crossKnock = shove
                end
            end
        end
    end
end

Motion.geometry = table.freeze({
    fittedVolumes = fittedVolumes,
    nearestPoint = nearestPoint,
    sweptContact = sweptContact,
    pathOffset = pathOffset,
    stopAtActor = stopAtActor,
    safeTravel = safeTravel,
    castParameters = castParameters,
    positionAt = positionAt,
    rememberPosition = rememberPosition,
    groundContour = galleonContour,
})

return Motion
