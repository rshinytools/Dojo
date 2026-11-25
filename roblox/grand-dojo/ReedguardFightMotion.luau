-- Featured sparring uses the same authored frame for posing and contact.
local Match = require(script.Parent.DojoMatchSupport)
local Reedguard = require(script.Parent.ReedguardCombatPoses)
local reedguardSupport = require(script.Parent.ReedguardDefeatSupport)
local Juniper = require(script.Parent.JuniperCombatPoses)
local Penguin = require(script.Parent.PenguinCombatPoses)
local Bracken = require(script.Parent.BrackenCombatPoses)
local Silverback = require(script.Parent.SilverbackCombatPoses)
local Sablecrest = require(script.Parent.SablecrestCombatPoses)
local Salamander = require(script.Parent.FireSalamanderCombatPoses)
local Granite = require(script.Parent.GraniteCombatPoses)
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
local rolls = {fortressRicochet = Heavy.roll, meteorRoll = Magma.roll}
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Motion = {}
Motion.lockedWalkSpeed = 5

local fallSeconds = .57
local playerFall = Vector3.new(math.rad(4), math.rad(62), math.rad(88))
local residentFall = Vector3.new(math.rad(86), 0, math.rad(10))
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
    frog = {poses = Frog, mixedSpacing = 2.55},
    otter = {poses = Otter, mixedSpacing = 2.55},
}
for id, kit in Sky.kits do
    playerKits[id] = kit
end
for id, kit in EmberAqua.kits do
    playerKits[id] = kit
end
for id, kit in Heavy.kits do
    playerKits[id] = kit
end
for id, kit in Magma.kits do
    playerKits[id] = kit
end
for id, kit in Thunder.kits do
    playerKits[id] = kit
end
for id, kit in Apex.kits do
    playerKits[id] = kit
end

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

local function verticalHalfExtent(frame, size)
    return (math.abs(frame.RightVector.Y) * size.X + math.abs(frame.UpVector.Y) * size.Y
        + math.abs(frame.LookVector.Y) * size.Z) * .5
end

local function defeatSnapshot(base, parts, floor, rotation)
    local bottom, top = math.huge, -math.huge
    local pieces = {}
    for _, part in parts do
        local frame = part.CFrame
        local extent = verticalHalfExtent(frame, part.Size)
        bottom, top = math.min(bottom, frame.Y - extent), math.max(top, frame.Y + extent)
        pieces[part] = base:ToObjectSpace(frame)
    end
    local empty = bottom == math.huge
    local pivot = if empty then Vector3.zero else base:PointToObjectSpace(Vector3.new(base.X, (bottom + top) * .5, base.Z))
    return {base = base, pieces = pieces, pivot = pivot, floor = floor, rotation = rotation,
        bottom = if empty then base.Y - 2.5 else bottom}
end

local function mountedBounds(shell)
    local parts = {}
    if shell then
        for _, part in shell:GetDescendants() do
            if part:IsA("BasePart") and part.Transparency < 1 then
                table.insert(parts, part)
            end
        end
    end
    return parts
end

local function partBottom(frame, part, points)
    if not points then
        return frame.Y - verticalHalfExtent(frame, part.Size)
    end
    local direction = frame:VectorToObjectSpace(Vector3.yAxis)
    local bottom = math.huge
    for _, point in points do
        bottom = math.min(bottom, direction:Dot(point))
    end
    return frame.Y + bottom
end

local function stageReedguardDefeat(defeat, shell, motors)
    defeat.rotation = Reedguard.Defeat.angle
    defeat.neutralRoot = motors.RootJoint.rest
    defeat.inverseRoot = defeat.firstJoint:Inverse()
    defeat.limbs, defeat.partLimbs, defeat.support = {}, {}, {}
    defeat.bottom = math.huge
    for part in defeat.pieces do
        local samples = part.Parent == shell and reedguardSupport[part.Name]
        if samples then
            local scaled = table.create(#samples)
            for index, point in samples do
                scaled[index] = point * part.Size
            end
            defeat.support[part] = scaled
        end
        defeat.bottom = math.min(defeat.bottom, partBottom(part.CFrame, part, defeat.support[part]))
    end
    for group, pose in Reedguard.Defeat.joints do
        local binding, piece = motors[pose[1]], shell:FindFirstChild(group)
        if binding and piece then
            local motor, rest = binding.motor, binding.rest
            local parent = defeat.base:ToObjectSpace(motor.Part0.CFrame)
            -- The joint change is applied in the captured root's coordinates.
            local limb = {motor = motor, start = motor.C0, parent = parent,
                undo = motor.C0:Inverse() * parent:Inverse(),
                target = CFrame.new(rest.Position) * pose[2] * rest.Rotation}
            table.insert(defeat.limbs, limb)
            defeat.partLimbs[piece] = limb
            for _, detail in piece:GetDescendants() do
                if defeat.pieces[detail] then
                    defeat.partLimbs[detail] = limb
                end
            end
        end
    end
end

local function fallenFrame(defeat, age)
    if defeat.settledFrame then
        return defeat.settledFrame
    end
    local phase = math.clamp(age / fallSeconds, 0, 1)
    local progress = phase * phase * (3 - 2 * phase)
    local rotation = defeat.rotation * progress
    local frame = defeat.base * CFrame.new(0, 0, .64 * progress) * CFrame.new(defeat.pivot)
        * CFrame.Angles(0, rotation.Y, 0) * CFrame.Angles(rotation.X, 0, rotation.Z) * CFrame.new(-defeat.pivot)
    if defeat.neutralRoot then
        frame *= defeat.firstJoint:Lerp(defeat.neutralRoot, progress) * defeat.inverseRoot
        for _, limb in defeat.limbs do
            local pose = limb.start:Lerp(limb.target, progress)
            limb.delta = limb.parent * pose * limb.undo
            limb.motor.C0 = pose
        end
    end
    local bottom = math.huge
    for part, relative in defeat.pieces do
        local limb = defeat.partLimbs and defeat.partLimbs[part]
        local piece = if limb then frame * limb.delta * relative else frame * relative
        local points = defeat.support and defeat.support[part]
        bottom = math.min(bottom, partBottom(piece, part, points))
    end
    if bottom == math.huge then
        bottom = frame.Y - 2.5 + 1.65 * progress
    end
    -- Land the shell on the canvas, including when the last hit caught a fighter in the air.
    local target = defeat.bottom + (defeat.floor + .045 - defeat.bottom) * progress
    local result = frame + Vector3.new(0, target - bottom, 0)
    if phase == 1 then
        defeat.settledFrame = result
    end
    return result
end

local function renderPlayerDefeat(state, root, floor, age)
    local joint = state.motors.RootJoint
    if not joint then
        return
    end
    local defeat = state.defeat
    if not defeat then
        local character = root.Parent
        local shell = character:FindFirstChild("Starter Fighter Shell")
        -- A side fall keeps the tail beside the fighter instead of under their back.
        defeat = defeatSnapshot(root.CFrame, mountedBounds(shell), floor, playerFall)
        defeat.firstJoint = joint.motor.C0
        if shell and shell:GetAttribute("FighterId") == "reedguard-kangaroo" and next(defeat.pieces) then
            stageReedguardDefeat(defeat, shell, state.motors)
        end
        defeat.collisions = {}
        for _, part in character:GetDescendants() do
            if part:IsA("BasePart") and part.CanCollide then
                table.insert(defeat.collisions, part)
                part.CanCollide = false
            end
        end
        state.defeat = defeat
    end
    joint.motor.C0 = root.CFrame:ToObjectSpace(fallenFrame(defeat, age)) * defeat.firstJoint
end

local function restoreDefeat(state)
    if state.defeat then
        for _, part in state.defeat.collisions do
            if part.Parent then
                part.CanCollide = true
            end
        end
        state.defeat = nil
    end
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
        autoJump = humanoid.AutoJumpEnabled, walkSpeed = humanoid.WalkSpeed,
        animate = animate, animateDisabled = animate and animate.Disabled,
        humanoid = humanoid, playerPoses = playerKit.poses, botPoses = resident.poses,
        spacing = spacing, diameter = diameter, originalPair = originalPair}
    if bout.kit == "frog" or bout.kit == "otter" or Sky.kits[bout.kit] or EmberAqua.kits[bout.kit]
        or Heavy.kits[bout.kit] or Magma.kits[bout.kit] or Thunder.kits[bout.kit] or Apex.kits[bout.kit] then
        state.rosterHistory = {{at = bout.round.introAt, position = bout.root.CFrame}}
    end
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
    if bout.kit == "otter" then
        state.pebbleEffects = Instance.new("Folder")
        state.pebbleEffects.Name, state.pebbleEffects.Parent = "Otter effects", bout.telegraph
    end
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
    humanoid.WalkSpeed = math.min(humanoid.WalkSpeed, Motion.lockedWalkSpeed)

    bout.root.Anchored = true
    state.holding = true
    bout.motion = state
end

function Motion.close(bout)
    local state = bout.motion
    restoreDefeat(state)
    clearLane(state, "tornadoWarning")
    clearLane(state, "gustWarning")
    if state.arenaFieldCast then
        Fields.clearVisuals(state.arenaFieldCast)
    end
    if state.heavyCast then
        Fields.clearVisuals(state.heavyCast)
    end
    if state.pebbleEffects then
        state.pebbleEffects:Destroy()
    end
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
        state.humanoid.WalkSpeed = state.walkSpeed
    end
    if bout.root.Parent then
        bout.root.Anchored = state.anchored
    end
    if RunService:IsStudio() and bout.lastPlayerAction then
        bout.player:SetAttribute("SparFootworkAction", nil)
    end
end

function Motion.canAct(bout, action)
    local groundedOnly = (bout.motion.rosterHistory and (action == "dodge" or action == "secondary" or action == "signature"))
        or (penguin(bout) or silverback(bout) or salamander(bout))
        and (action == "dodge" or action == "signature") or ((silverback(bout) or salamander(bout)) and action == "secondary")
    if not groundedOnly then
        return true
    end
    local root = bout.root
    return root.Position.Y <= bout.arena.playerSpawn.Position.Y + .65
        and math.abs(root.AssemblyLinearVelocity.Y) <= 4
end

function Motion.locomotion(poses, state, root, forward, now, readOnly)
    local velocity = root.AssemblyLinearVelocity
    local speed = Match.flat(velocity)
    if speed.Magnitude <= 1.3 or math.abs(velocity.Y) >= 6 then
        if not readOnly then state.shuffle = nil end
        return "stance", now
    end
    local along = speed:Dot(forward)
    local across = speed:Dot(forward:Cross(Vector3.yAxis))
    if poses.StrafeStepDistance and math.abs(across) > math.max(1.3, math.abs(along)) then
        local action = if across > 0 then "strafeRight" else "strafeLeft"
        local shuffle = state.shuffle
        if readOnly then
            return action, if shuffle and shuffle.action == action then shuffle.age else 0
        end
        if not shuffle or shuffle.action ~= action or now - shuffle.at > .10 then
            shuffle = {action = action, at = now, age = 0}
            state.shuffle = shuffle
        end
        local duration = poses.Duration[action]
        local rate = math.clamp(math.abs(across) * duration / poses.StrafeStepDistance, .44, 1.8)
        shuffle.age = (shuffle.age + math.clamp(now - shuffle.at, 0, .05) * rate) % duration
        shuffle.at = now
        return action, shuffle.age
    end
    if not readOnly then state.shuffle = nil end
    return if along >= 0 then "advance" else "retreat", now
end

function Motion.canPlantKick(kit, clip, root, floor)
    return kit == "reedguard" and clip and clip.action == "body"
        and math.abs(root.Position.Y - (floor + 2.13)) < .38 and math.abs(root.AssemblyLinearVelocity.Y) < 4
end

local function playerAction(bout, now, readOnly)
    local round = bout.round
    if bout.outroAt then
        local age = now - bout.outroAt
        return if round.result == "win" then "win" else "stance", age
    elseif now < round.startsAt then
        return "intro", now - round.introAt
    elseif round.clip then
        if not readOnly then bout.motion.shuffle = nil end
        return round.clip.action, now - round.clip.startedAt, round.clip.direction
    end
    local forward = directionTo(bout.root.Position, bout.position, bout.root.CFrame.LookVector)
    return Motion.locomotion(bout.motion.playerPoses, bout.motion, bout.root, forward, now, readOnly)
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

local function rosterTravel(poses, action, age, direction)
    local travel = poses.Travel and poses.Travel[action]
    if not travel or not travel.axis then
        return nil
    end
    local ratio = math.clamp((age - travel.startsAt) / (travel.endsAt - travel.startsAt), 0, 1)
    local amount = travel.distance * ratio * ratio * (3 - 2 * ratio)
    return if travel.axis == "lateral" then Vector3.new(amount * (direction or 1), 0, 0)
        else Vector3.new(0, 0, -amount)
end

local function attackPoint(poses, action, index, direction)
    return if poses.impact then poses.impact(action, index, direction) else poses.Impact[action][index]
end

local function pebbleSweep(fx, params, origin, move, index)
    local skill = Otter.Skill.pebbleBarrage
    local start = origin:PointToWorldSpace(Otter.Impact.pebbleBarrage[index])
    local travel = origin:VectorToWorldSpace(skill.directions[index].Unit) * skill.range
    local cast = workspace:Raycast(start, travel, params)
    local fraction = if cast then cast.Distance / travel.Magnitude else 1
    local label = "Pebble " .. index
    if move.launch then
        local pebble = Instance.new("Part")
        pebble.Name, pebble.Shape, pebble.Size = label, Enum.PartType.Ball, Vector3.new(.28, .26, .28)
        pebble.Color, pebble.Material = Color3.fromRGB(159, 234, 224), Enum.Material.Neon
        pebble.Anchored, pebble.CanCollide, pebble.CanTouch, pebble.CanQuery, pebble.CastShadow = true, false, false, false, false
        pebble.Position, pebble.Parent = start, fx
        local duration = math.max(.025, move.flight * fraction)
        TweenService:Create(pebble, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Position = start + travel * fraction}):Play()
        Debris:AddItem(pebble, duration + .035)
        return nil, start
    end
    if move.from >= fraction then
        return nil, start + travel * fraction
    end
    return start + travel * move.from, start + travel * math.min(move.to, fraction), fx:FindFirstChild(label)
end

local function pebbleHit(start, finish, volumes, radius)
    local nearest, zone, best = nil, nil, math.huge
    for _, volume in volumes do
        local point = Motion.geometry.sweptContact(start, finish, volume.frame, volume.size, radius)
        if point then
            local distance = (point - start).Magnitude
            if distance < best then
                nearest, zone, best = point, volume.zone, distance
            end
        end
    end
    return nearest, zone, best
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

local function moveCommittedSkill(bout, now, clip, age)
    local state, root = bout.motion, bout.root
    local action = clip and not bout.outroAt and clip.action
    local roll = rolls[action]
    local thunder = Thunder.skills[action]
    local pounce = action == "apexPounce"
    local active = action == "tidalBellyFlop" or action == "volcanicBreath" or roll ~= nil or thunder ~= nil or pounce
    local cast = state.heavyCast
    if cast and (not active or cast.clip ~= clip) then
        Fields.clearVisuals(cast)
        state.heavyCast, cast = nil, nil
    end
    if not active then
        return false
    end
    local arena = bout.arena
    if not cast then
        local origin = if thunder then CFrame.lookAlong(root.Position,
            directionTo(root.Position, bout.position, root.CFrame.LookVector)) else root.CFrame
        cast = {clip = clip, origin = origin}
        state.heavyCast = cast
        if pounce then
            local target = bout.position
            local aim = Apex.face(origin.Position, target, origin)
            local wanted = Apex.destination(origin.Position, target)
            local landing = safeTravel(bout, origin.Position, wanted, aim, Vector3.new(1.52, 2.18, 1.38), state.arenaCast)
            cast.apexLanding = Apex.face(landing, target, aim)
        elseif action == "tidalBellyFlop" then
            local target = origin.Position + origin.LookVector * Heavy.flopTravel.distance
            cast.landing = safeTravel(bout, origin.Position, target, origin, Vector3.new(1.84, 2.2, 1.5), state.arenaCast)
        elseif roll then
            cast.rollPath = Ricochet.plan(arena.bounds, origin.Position, origin.LookVector, roll, function(from, delta)
                local center = Vector3.new(from.X, arena.floor + 1.22, from.Z)
                return workspace:Blockcast(CFrame.new(center), Vector3.new(2.44, 2.22, 2.44), delta, state.arenaCast)
            end)
        end
    end
    if pounce then
        local skill = Apex.pounce
        if age < skill.impactAt then
            if not cast.warning then
                cast.warning = galleonContour(bout, "Apex Pounce warning",
                    groundPoint(bout, cast.apexLanding.Position), skill.radius, nil, nil, skill.tint)
            end
        else
            Fields.clearVisuals(cast)
        end
        if age >= skill.teleportAt and not cast.apexArrived then
            Match.move(root, cast.apexLanding)
            cast.apexArrived = true
        end
    elseif thunder then
        local origin, position = cast.origin, root.Position
        local function step(target)
            local delta = stopAtActor(position, Match.flat(target - position), bout.position, 1.91)
            return safeTravel(bout, position, position + delta, CFrame.new(position) * origin.Rotation,
                Vector3.new(1.52, 2.18, 1.38), state.arenaCast)
        end
        local offset = rosterTravel(state.playerPoses, action, age, clip.direction)
        local nextPosition = step(origin:PointToWorldSpace(offset))
        local landing = step(origin.Position + origin.LookVector * thunder.travel.distance)
        Match.move(root, CFrame.new(nextPosition) * origin.Rotation)
        Thunder.present(cast, bout.telegraph, arena.floor, age, landing, true)
    elseif cast.rollPath then
        if age >= roll.windup then
            Match.move(root, Ricochet.frameAt(cast.rollPath, age - roll.windup))
        end
        if Ricochet.present(cast, bout.telegraph, arena.floor, age, roll) then
            bout.message, bout.messageUntil = "ricochetBounce", now + .38
        end
    elseif action == "volcanicBreath" then
        Magma.presentBreath(cast, bout.telegraph, arena.floor, age, function(mouth, direction, range)
            local ray = workspace:Raycast(mouth, direction * range, state.arenaCast)
            return if ray then ray.Distance else range
        end)
    else
        local travel = Heavy.flopTravel
        local alpha = math.clamp((age - travel.startsAt) / (travel.endsAt - travel.startsAt), 0, 1)
        local point = cast.origin.Position:Lerp(cast.landing, alpha * alpha * (3 - 2 * alpha))
        Match.move(root, CFrame.new(point) * cast.origin.Rotation)
        if age >= Heavy.flop.warningAt and age < Heavy.flopAt then
            if not cast.warning then
                local center = Vector3.new(cast.landing.X, arena.floor, cast.landing.Z)
                cast.warning = galleonContour(bout, "Tidal Belly-Flop warning", center, Heavy.flop.radius,
                    nil, nil, Color3.fromRGB(126, 226, 255))
            end
        else
            Fields.clearVisuals(cast)
        end
    end
    return true
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
    local age = clip and now - clip.startedAt
    local tornado = Frog.Skill.tadpoleTornado
    if clip and clip.action == "tadpoleTornado" and not bout.outroAt and age >= tornado.warningAt
        and age < Frog.Contact.tadpoleTornado then
        if not state.tornadoWarning then
            local center = Vector3.new(root.Position.X, bout.arena.floor, root.Position.Z)
            state.tornadoWarning = galleonContour(bout, "Tadpole Tornado warning", center, tornado.radius,
                nil, nil, Color3.fromRGB(143, 241, 124))
        end
    else
        clearLane(state, "tornadoWarning")
    end
    local heavyActive = moveCommittedSkill(bout, now, clip, age)
    local offset = not heavyActive and clip and rosterTravel(state.playerPoses, clip.action, age, clip.direction)
    if offset and not bout.outroAt then
        if state.dodgeClip ~= clip then
            state.dodgeClip, state.dodgeFrom = clip, root.CFrame
        end
        local origin = state.dodgeFrom
        local wanted = origin:PointToWorldSpace(offset)
        local delta = stopAtActor(root.Position, Match.flat(wanted - root.Position), bout.position, 1.85)
        local position = safeTravel(bout, root.Position, root.Position + delta, root.CFrame,
            Vector3.new(1.16, 1.85, 1.12), state.arenaCast)
        Match.move(root, CFrame.new(position) * origin.Rotation)
    elseif clip and clip.action == "sidestep" and not bout.outroAt then
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
    if clip and clip.action == "gustVortex" and not bout.outroAt and age >= Sky.gust.warningAt and age < Sky.burstAt then
        if not state.gustWarning then
            local center = Match.clampFloor(bout.arena.bounds, state.dodgeFrom:PointToWorldSpace(Sky.gust.center), bout.arena.floor)
            state.gustWarning = galleonContour(bout, "Gust Vortex warning", center, Sky.gust.radius,
                nil, nil, Color3.fromRGB(188, 179, 255))
        end
    else
        clearLane(state, "gustWarning")
    end
    local fieldAction = clip and not bout.outroAt and (clip.action == "cinderSnare" or clip.action == "cavitationCannon")
    local fieldCast = state.arenaFieldCast
    if fieldCast and (not fieldAction or fieldCast.clip ~= clip) then
        Fields.clearVisuals(fieldCast)
        state.arenaFieldCast = nil
        fieldCast = nil
    end
    if fieldAction then
        if not fieldCast then
            local bounds, floor = bout.arena.bounds, bout.arena.floor
            local origin = root.CFrame
            local field = if clip.action == "cinderSnare"
                then Fields.triangle(bounds, floor, origin, EmberAqua.snare.vertices) else Fields.wave(bounds, floor, origin)
            fieldCast = {clip = clip, field = field}
            state.arenaFieldCast = fieldCast
        end
        Fields.updateCast(bout.telegraph, fieldCast, age, now, EmberAqua, true)
    end
    local kick = Motion.canPlantKick(bout.kit, clip, root, bout.arena.floor)
    if kick and state.kickClip ~= clip then
        state.kickClip = clip
        local forward = directionTo(root.Position, bout.position, root.CFrame.LookVector)
        Match.move(root, CFrame.lookAlong(root.Position, forward))
    elseif not kick then
        state.kickClip = nil
    end
    local hold = now < bout.round.startsAt or bout.outroAt ~= nil or state.dodgeClip ~= nil or fieldAction == true
        or heavyActive or kick == true or (clip ~= nil and clip.action == "unstoppableFrenzy")
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
    local rooted = now < (round.botRootedUntil or 0)
    local heading = action.basis.LookVector
    if bout.outroAt or phase == "recovery" then
        clearLane(state, "rushLane")
        rememberPosition(action.samples, now, bout.position)
        return
    elseif phase == "setup" then
        local alpha = math.clamp((age - .12) / math.max(.01, attack.setupTime - .12), 0, 1)
        local stepLength = math.max(action.stepProgress, (attack.advance or 0) * alpha * alpha)
        if not rooted then
            brackenStep(bout, heading * (stepLength - action.stepProgress), action.basis)
        end
        action.stepProgress = stepLength
    elseif phase == "windup" and descriptor.travelProgress then
        if not action.driveLength then
            local gap = Match.flat(bout.root.Position - bout.position).Magnitude
            action.driveLength = math.clamp(gap - 1.94, .35, 3.1)
        end
        local progress = math.max(action.driveProgress, descriptor.travelProgress(age, attack.windup))
        if not rooted then
            brackenStep(bout, heading * (action.driveLength * (progress - action.driveProgress)), action.basis)
        end
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
    local rooted = now < (round.botRootedUntil or 0)
    if bout.outroAt or phase == "recovery" then
        clearLane(state, "returnLane")
    elseif phase == "setup" then
        local progress = math.max(action.setupProgress, descriptor.setupProgress(age, attack.setupTime))
        local step = action.basis.RightVector * attack.strafe * (progress - action.setupProgress)
        if not rooted then
            sablecrestStep(bout, step, action.basis)
        end
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
        if not rooted then
            sablecrestStep(bout, drive, action.strikeBasis)
        end
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

local function juniperStep(bout, movement, orientation, footwork)
    if bout.motion.originalPair and not footwork then
        bout.position = Match.clampFloor(bout.arena.bounds, bout.position + movement, bout.arena.floor)
        return
    end
    local allowed = stopAtActor(bout.position, movement, bout.root.Position, 2.23)
    local center = bout.position + Vector3.new(0, 1.32, 0)
    bout.position = safeTravel(bout, bout.position, bout.position + allowed,
        CFrame.new(center) * orientation.Rotation, Vector3.new(2.15, 2.5, 1.9), bout.motion.arenaCast)
end

local function juniperFootwork(bout, distance, now, dt)
    local state, round = bout.motion, bout.round
    if (distance <= round.resident.startRange and now >= round.botAt - .055)
        or (bout.reactionAt and now - bout.reactionAt < .20) then
        return
    end
    local cycle = round.recoveryStartedAt or round.startsAt
    if state.juniperCycle ~= cycle then
        state.juniperCycle = cycle
        state.juniperSide = if round.attackIndex == 1 then -1 else 1
        state.juniperRetreatUntil = if round.recoveryKind == "parried" or round.recoveryKind == "blocked"
            then now + .40 else now
    end
    local heading = bout.direction
    local orientation = CFrame.lookAlong(Vector3.zero, heading)
    local before, spacing = bout.position, state.spacing
    local stepTime = math.clamp(dt, 0, .045)
    local action
    if distance < math.min(spacing + .25, round.resident.startRange - .22) and now < state.juniperRetreatUntil then
        action = "retreat"
        local travel = math.min(2.4 * stepTime, round.resident.startRange - .14 - distance)
        juniperStep(bout, -heading * travel, orientation, true)
    elseif distance > spacing + .30 then
        action = "step"
        local travel = math.min(distance - spacing, bout.profile.pace * stepTime)
        juniperStep(bout, heading * travel, orientation, true)
    else
        local sideways = orientation.RightVector * (2.4 * stepTime)
        local radial = heading * (math.clamp((distance - spacing) * 3, -.9, .9) * stepTime)
        juniperStep(bout, sideways * state.juniperSide + radial, orientation, true)
        if (bout.position - before).Magnitude < .005 then
            state.juniperSide = -state.juniperSide
            juniperStep(bout, sideways * state.juniperSide + radial, orientation, true)
        end
        action = if state.juniperSide > 0 then "strafeRight" else "strafeLeft"
    end
    if (bout.position - before).Magnitude > .005 then
        return action
    end
    return nil
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
    state.crossLift = if knock.dropFrom then knock.dropFrom * (1 - alpha) ^ 3
        else 4 * alpha * (1 - alpha) * knock.height
    knock.progress = progress
    if alpha >= 1 then
        state.crossKnock = nil
    end
end

local function botAction(bout, now)
    local round = bout.round
    if bout.outroAt then
        local action = if round.result == "loss" then "win" else "idle"
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
    return bout.footworkAction or "idle", if bout.footworkAction then now - bout.footworkAt else now
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
    local state = bout.motion
    if state.rosterHistory and #state.rosterHistory > 0 then
        return positionAt(state.rosterHistory, time)
    end
    local travel = if silverback(bout) then state.skywalkCast
        elseif salamander(bout) then state.salamanderCast else state.playerTravel
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

local function botFloorContact(bout, frame, groups, center, radius)
    for _, name in {"Left Leg", "Right Leg"} do
        local joint = bout.joints[name]
        local point = nearestPoint(jointFrame(frame, groups, name, joint) * joint.shell, joint.part.Size, center)
        if Match.flat(point - center).Magnitude <= radius and point.Y <= center.Y + .78
            and not obstructed(bout, center, point) then
            return true
        end
    end
    return false
end

function Motion.strike(bout, action, move, time, index, castStartedAt)
    if salamander(bout) then
        return salamanderStrike(bout, action, move, time, index, castStartedAt)
    elseif silverback(bout) then
        return silverbackStrike(bout, action, move, time, index)
    elseif action == "bellySlide" and penguin(bout) then
        return slideContact(bout, time, index)
    end
    local state, root = bout.motion, actorRootAt(bout, time)
    local frame, groups = botPose(bout, time)
    if move.shape == "apexCone" then
        local from, direction = Apex.swipeFrame(root, move)
        for _, name in {"Torso", "Head", "Left Arm", "Right Arm"} do
            local joint = bout.joints[name]
            local target = jointFrame(frame, groups, name, joint) * joint.shell
            local point = Magma.breathHit(from, direction, move, target, joint.part.Size, nearestPoint)
            if point and not obstructed(bout, from, point) then
                return true, point, "body"
            end
        end
        return false, from
    elseif move.shape == "apexZone" then
        if move.marker then
            local cast = state.heavyCast
            if not cast or not cast.apexArrived or cast.clip.startedAt ~= castStartedAt then return false end
            local skill = Apex.pounce
            local center = groundPoint(bout, root.Position)
            local visual = galleonContour(bout, "Apex Root Zone", center, skill.radius, nil, nil, skill.tint)
            Debris:AddItem(visual, skill.duration)
            state.apexZone = {center = center, startedAt = castStartedAt}
            return true
        end
        local zone = state.apexZone
        if zone and zone.startedAt == castStartedAt and not zone.touched
            and botFloorContact(bout, frame, groups, zone.center, move.radius) then
            zone.touched = true
            return true, zone.center, "body"
        end
        return false
    elseif move.apex then
        local cast = state.heavyCast
        local center = groundPoint(bout, root.Position)
        return cast ~= nil and cast.apexArrived and cast.clip.startedAt == castStartedAt
            and botFloorContact(bout, frame, groups, center, move.radius), center, "body"
    elseif move.thunder then
        local cast = state.heavyCast
        if not cast or cast.clip.startedAt ~= castStartedAt then
            return false
        end
        local center = groundPoint(bout, root.Position)
        local radius = Thunder.radius(Thunder.skills[action], cast.origin.Position, center)
        Thunder.burst(cast, bout.telegraph, center, radius)
        return botFloorContact(bout, frame, groups, center, radius), center, "body"
    elseif move.shape == "ricochet" then
        local cast = state.heavyCast
        if not cast or not cast.rollPath or cast.clip.startedAt ~= castStartedAt then
            return false
        end
        for _, segment in Ricochet.sweeps(cast.rollPath, move.from, move.to) do
            for _, name in {"Torso", "Left Leg", "Right Leg"} do
                local joint = bout.joints[name]
                local target = jointFrame(frame, groups, name, joint) * joint.shell
                local contact = sweptContact(segment.a, segment.b, target, joint.part.Size, move.radius)
                if contact and not obstructed(bout, segment.a, contact) then
                    return true, contact, "body"
                end
            end
        end
        return false
    elseif move.shape == "breath" then
        local cast = state.heavyCast
        if not cast or cast.clip.startedAt ~= castStartedAt then return false end
        local mouth, direction = Magma.breathFrame(cast.origin, move)
        for _, name in {"Torso", "Head", "Left Arm", "Right Arm"} do
            local joint = bout.joints[name]
            local target = jointFrame(frame, groups, name, joint) * joint.shell
            local hit = Magma.breathHit(mouth, direction, move, target, joint.part.Size, nearestPoint)
            if hit and not obstructed(bout, mouth, hit) then return true, hit, "body" end
        end
        return false, mouth
    elseif action == "tidalBellyFlop" then
        local center = Vector3.new(root.X, bout.arena.floor, root.Z)
        for _, name in {"Left Leg", "Right Leg"} do
            local joint = bout.joints[name]
            local contact = nearestPoint(jointFrame(frame, groups, name, joint) * joint.shell, joint.part.Size, center)
            if Match.flat(contact - center).Magnitude <= move.radius and contact.Y <= center.Y + .78
                and not obstructed(bout, center, contact) then
                return true, center, "body"
            end
        end
        return false, center
    elseif move.shape == "snare" or move.shape == "wave" then
        local cast = state.arenaFieldCast
        if not cast or cast.clip.startedAt ~= castStartedAt or move.launch then
            return false
        end
        local volumes = {}
        for _, name in {"Left Leg", "Right Leg"} do
            local joint = bout.joints[name]
            table.insert(volumes, {frame = jointFrame(frame, groups, name, joint) * joint.shell,
                size = joint.part.Size, grounded = true})
        end
        local field = cast.field
        local foot = Fields.footContact(field, move, volumes, function(from, to)
            return obstructed(bout, from, to)
        end)
        return foot ~= nil, foot, "body"
    elseif move.projectile then
        local releaseRoot = actorRootAt(bout, castStartedAt + move.release)
        local start, finish, effect = pebbleSweep(state.pebbleEffects, state.arenaCast, releaseRoot, move, index)
        if not start then
            return false, finish
        end
        local volumes = {}
        for _, name in {"Torso", "Head", "Right Leg", "Left Leg"} do
            local joint = bout.joints[name]
            table.insert(volumes, {frame = jointFrame(frame, groups, name, joint) * joint.shell,
                size = joint.part.Size, zone = if name == "Head" then "head" else "body"})
        end
        local hit, zone = pebbleHit(start, finish, volumes, move.radius)
        if hit and effect then
            effect:Destroy()
        end
        return hit ~= nil, hit or finish, zone
    elseif action == "tadpoleTornado" then
        local center = Vector3.new(root.X, bout.arena.floor, root.Z)
        local joint = bout.joints.Torso
        local contact = nearestPoint(jointFrame(frame, groups, "Torso", joint) * joint.shell, joint.part.Size, center)
        return Match.flat(contact - center).Magnitude <= move.radius
            and contact.Y <= center.Y + 1.5 and not obstructed(bout, center, contact), center, "body"
    elseif move.lockedCenter then
        local origin = state.dodgeFrom or actorRootAt(bout, castStartedAt)
        local center = Match.clampFloor(bout.arena.bounds, origin:PointToWorldSpace(move.center), bout.arena.floor)
        for _, name in {"Left Leg", "Right Leg"} do
            local joint = bout.joints[name]
            local nearest = nearestPoint(jointFrame(frame, groups, name, joint) * joint.shell, joint.part.Size, center)
            if Match.flat(nearest - center).Magnitude <= move.radius and nearest.Y <= center.Y + .85
                and not obstructed(bout, center, nearest) then
                return true, center, "body"
            end
        end
        return false, center
    end
    local direction = bout.round.clip and bout.round.clip.direction
    local point = root:PointToWorldSpace(attackPoint(state.playerPoses, action, index, direction))
    local offset = Match.flat(bout.position - root.Position)
    if offset.Magnitude < .05 or offset.Magnitude > 3.55 or offset.Unit:Dot(root.LookVector) < .48 then
        return false, point
    end
    local zones = if move.zone == "head" then {"Head", "Torso"}
        elseif move.foot then {"Torso", "Left Leg", "Right Leg"} else {"Torso"}
    for _, name in zones do
        local joint = bout.joints[name]
        local targetFrame, size = jointFrame(frame, groups, name, joint) * joint.shell, joint.part.Size
        if action == "uppercut" and name == "Torso" then
            targetFrame *= CFrame.new(0, size.Y * .22, 0)
            size *= Vector3.new(1, .56, 1)
        end
        local nearest = nearestPoint(targetFrame, size, point)
        local radius = move.radius or (if action == "uppercut" then .43 else .52)
        if (point - nearest).Magnitude <= radius and not obstructed(bout, root.Position, nearest) then
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
    local action, age, direction = playerAction(bout, time, true)
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
        return false, false, "body"
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
    state.frenzyGlow = Apex.frenzyVisual(state.frenzyGlow and state.frenzyGlow.Parent and state.frenzyGlow,
        round, bout.root.Parent, bout.telegraph, now)
    if state.rosterHistory then
        local history = state.rosterHistory
        rememberPosition(history, now, bout.root.CFrame)
        while #history > 2 and history[2].at < now - .8 do
            table.remove(history, 1)
        end
    end
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
    local readyToMove = not bout.outroAt and not state.shove and not state.crossKnock and now >= round.startsAt
        and now >= (round.botRootedUntil or 0)
        and round.botPhase == "ready"
    if bout.botId == "juniper" then
        local action = if readyToMove and distance > .04 then juniperFootwork(bout, distance, now, dt) else nil
        if action ~= bout.footworkAction then
            bout.footworkAction, bout.footworkAt = action, now
            if RunService:IsStudio() then
                bout.bot:SetAttribute("FootworkAction", action or "idle")
            end
        end
    elseif readyToMove and distance > spacing then
        bout.moving = true
        local travel = bout.direction * math.min(distance - spacing, dt * bout.profile.pace)
        residentStep[bout.botId](bout, travel, CFrame.lookAlong(Vector3.zero, bout.direction))
        if command then
            keepClearance(bout)
        end
    else
        bout.moving = false
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
    local round, state = bout.round, bout.motion
    if bout.outroAt and round.playerHealth <= 0 then
        setTravelHold(bout, true)
        renderPlayerDefeat(state, bout.root, bout.arena.floor, now - bout.outroAt)
    else
        local action, age, direction = playerAction(bout, now)
        if RunService:IsStudio() and bout.lastPlayerAction ~= action then
            bout.lastPlayerAction = action
            bout.player:SetAttribute("SparFootworkAction", action)
        end
        local roll = rolls[action]
        local path = state.heavyCast and state.heavyCast.rollPath
        local sampleAge = if roll then Ricochet.sampleAge(path, age, roll) else age
        local offsets = state.playerPoses.sample(action, sampleAge, direction)
        if roll then
            offsets = Ricochet.pose(offsets, age, roll, roll.shellCenter, path)
        end
        for name, joint in state.motors do
            joint.motor.C0 = (offsets[name] or CFrame.identity) * joint.rest
        end
    end
    if bout.outroAt and round.botHealth <= 0 then
        if not state.botDefeat then
            local parts = {}
            for _, joint in bout.joints do
                table.insert(parts, joint.part)
            end
            state.botDefeat = defeatSnapshot(bout.bot.PrimaryPart.CFrame, parts, bout.arena.floor, residentFall)
        end
        local frame = fallenFrame(state.botDefeat, now - bout.outroAt)
        for part, relative in state.botDefeat.pieces do
            part.CFrame = frame * relative
        end
        return
    end
    local frame, groups = botPose(bout, now)
    bout.bot.PrimaryPart.CFrame = botBase(bout)
    keepClearance(bout)
    for name, joint in bout.joints do
        joint.part.CFrame = jointFrame(frame, groups, name, joint) * joint.shell
    end
end

function Motion.impact(bout, event)
    if event.source == "bot" or event.attack == "palm" or event.kind == "burn" then
        return
    end
    local damage = (event.damage or 0) > 0
    if damage then
        bout.reactionAt = event.at
        bout.reactionAction = if event.zone == "head" then "headHit" else "bodyHit"
    end
    if event.shockDuration and bout.round.botHealth > 0 then
        Thunder.shock(bout.bot, bout.telegraph, event.shockDuration)
    end
    local force, height, spike = Sky.impulse(event)
    if force and (damage or event.kind == "pull") then
        local state = bout.motion
        local center = if event.attack == "gustVortex" then event.point else bout.root.Position
        local heading = directionTo(center, bout.position, bout.root.CFrame.LookVector)
        state.crossKnock = {at = event.at, offset = heading * force, progress = 0,
            duration = if spike then .16 else .20, height = height, dropFrom = if spike then state.crossLift or 0 else nil,
            basis = CFrame.lookAlong(Vector3.zero, heading)}
    elseif damage and EmberAqua.shove[event.attack] then
        local cast = bout.motion.arenaFieldCast
        local center = if event.attack == "cavitationCannon" and cast then cast.field.center else bout.root.Position
        local heading = directionTo(center, bout.position, bout.root.CFrame.LookVector)
        bout.motion.crossKnock = {at = event.at, offset = heading * EmberAqua.shove[event.attack],
            progress = 0, duration = if event.attack == "cavitationCannon" then .34 else .20, height = 0,
            basis = CFrame.lookAlong(Vector3.zero, heading)}
    elseif damage and (Thunder.shove[event.attack] or Apex.shove[event.attack]) then
        local direction = directionTo(bout.root.Position, bout.position, bout.root.CFrame.LookVector)
        local force = Thunder.shove[event.attack] or Apex.shove[event.attack]
        bout.motion.crossKnock = {at = event.at, offset = direction * force, progress = 0,
            duration = .24, height = 0, basis = CFrame.lookAlong(Vector3.zero, direction)}
    elseif damage and Magma.shove[event.attack] then
        local forward = actorRootAt(bout, event.at).LookVector
        local direction = if event.attack == "meteorRoll" then forward else directionTo(bout.root.Position, bout.position, forward)
        bout.motion.crossKnock = {at = event.at, offset = direction * Magma.shove[event.attack], progress = 0,
            duration = .24, height = if event.attack == "meteorRoll" then .32 else 0,
            basis = CFrame.lookAlong(Vector3.zero, direction)}
    elseif damage and Heavy.shove[event.attack] then
        local center = if event.attack == "tidalBellyFlop" then event.point else bout.root.Position
        local forward = actorRootAt(bout, event.at).LookVector
        local direction = if event.attack == "fortressRicochet" then forward else directionTo(center, bout.position, forward)
        bout.motion.crossKnock = {at = event.at, offset = direction * Heavy.shove[event.attack], progress = 0,
            duration = .26, height = if event.attack == "tidalBellyFlop" then .17 else 0,
            basis = CFrame.lookAlong(Vector3.zero, direction)}
    elseif damage then
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
        elseif Frog.Skill[event.attack] or Otter.Skill[event.attack] then
            local skill = Frog.Skill[event.attack] or Otter.Skill[event.attack]
            local heading = directionTo(bout.root.Position, bout.position, bout.root.CFrame.LookVector)
            bout.motion.crossKnock = {at = event.at, offset = heading * skill.shove, progress = 0,
                duration = .20, height = 0, basis = CFrame.lookAlong(Vector3.zero, heading)}
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
    rosterTravel = rosterTravel,
    attackPoint = attackPoint,
    pebbleSweep = pebbleSweep,
    pebbleHit = pebbleHit,
    rememberPosition = rememberPosition,
    groundContour = galleonContour,
    renderPlayerDefeat = renderPlayerDefeat,
    restoreDefeat = restoreDefeat,
    defeatSeconds = fallSeconds + .35,
})

return Motion
