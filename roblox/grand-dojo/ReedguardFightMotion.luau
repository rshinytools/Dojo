-- The Grand Dojo showcase uses the same authored frame for posing and contact.
local Match = require(script.Parent.DojoMatchSupport)
local Reedguard = require(script.Parent.ReedguardCombatPoses)
local Juniper = require(script.Parent.JuniperCombatPoses)
local Motion = {}

local tracked = {"RootJoint", "Neck", "Right Shoulder", "Left Shoulder", "Right Hip", "Left Hip", "TailJoint"}
local function directionTo(position, target, fallback)
    local offset = Match.flat(target - position)
    return if offset.Magnitude > .04 then offset.Unit else fallback
end

function Motion.open(bout)
    local character = bout.player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animate = character:FindFirstChild("Animate")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    local state = {motors = {}, anchored = bout.root.Anchored, autoRotate = humanoid.AutoRotate,
        autoJump = humanoid.AutoJumpEnabled, animate = animate, animateDisabled = animate and animate.Disabled, humanoid = humanoid}
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
    contactSpace.Name = "Juniper sparring clearance"
    contactSpace.Shape = Enum.PartType.Cylinder
    contactSpace.Size = Vector3.new(2.85, 4.15, 4.15)
    contactSpace.CFrame = CFrame.new(bout.position + Vector3.new(0, 1.43, 0))
        * CFrame.Angles(0, 0, math.pi / 2)
    contactSpace.Transparency = 1
    contactSpace.Anchored, contactSpace.CanCollide, contactSpace.CanTouch = true, true, false
    contactSpace.Parent = bout.bot
    state.contactSpace = contactSpace

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

local function playerAction(bout, now)
    local round = bout.round
    if bout.outroAt then
        local age = now - bout.outroAt
        return if round.result == "win" then "win" else "stagger", age
    elseif now < round.startsAt then
        return "intro", now - round.introAt
    elseif round.clip then
        return round.clip.action, now - round.clip.startedAt
    end
    local speed = Match.flat(bout.root.AssemblyLinearVelocity)
    if speed.Magnitude > 1.3 and math.abs(bout.root.AssemblyLinearVelocity.Y) < 6 then
        local forward = directionTo(bout.root.Position, bout.position, bout.root.CFrame.LookVector)
        return if speed:Dot(forward) >= 0 then "advance" else "retreat", now
    end
    return "stance", now
end

local function playerDodge(bout, now)
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

local function botAction(bout, now)
    local round = bout.round
    if bout.outroAt then
        local action = if round.result == "win" then "knockout" elseif round.result == "loss" then "win" else "idle"
        return action, now - bout.outroAt
    elseif now < round.startsAt then
        return "intro", now - round.introAt
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

local function botBase(bout)
    local round, state = bout.round, bout.motion
    if round.botPhase == "windup" or round.botPhase == "recovery" then
        if state.attackStartedAt ~= round.botStartedAt then
            state.attackStartedAt = round.botStartedAt
            local toward = directionTo(bout.position, bout.root.Position, bout.direction)
            state.attackFrame = CFrame.lookAt(bout.position, bout.position + toward)
        end
        return state.attackFrame
    end
    return CFrame.lookAt(bout.position, bout.position + bout.direction)
end

local function botPose(bout, now)
    local action, age, duration = botAction(bout, now)
    local pose = Juniper.sample(action, age, duration)
    return botBase(bout) * pose.root, pose.groups
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

function Motion.strike(bout, action, move, time, index)
    local point = bout.root.CFrame:PointToWorldSpace(Reedguard.Impact[action][index])
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

function Motion.palm(bout, time)
    local pose = Juniper.sample("palm", bout.round.attack.windup, bout.round.attack.windup)
    local joint = bout.joints["Right Arm"]
    local frame = botBase(bout) * pose.root
    local point = jointFrame(frame, pose.groups, "Right Arm", joint):PointToWorldSpace(Juniper.PalmContact)
    local root = bout.root
    local facing = directionTo(root.Position, bout.position, root.CFrame.LookVector):Dot(root.CFrame.LookVector) >= .38
    local torso = root.CFrame * CFrame.new(0, .01, 0)
    local head = root.CFrame * CFrame.new(0, .82, -.05)
    local guard = bout.round.guardUntil >= time and time >= bout.round.guardFrom + .055
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
    local offset = Match.flat(bout.root.Position - bout.position)
    local distance = offset.Magnitude
    if not bout.outroAt and (round.botPhase == "ready" or round.botPhase == "setup") and distance > .04 then
        bout.direction = offset.Unit
    end
    bout.moving = not bout.outroAt and now >= round.startsAt and round.botPhase == "ready" and distance > 3.13
    if bout.moving then
        local position = bout.position + bout.direction * math.min(distance - 3.13, dt * bout.profile.pace)
        bout.position = Match.clampFloor(bout.arena.bounds, position, bout.arena.floor)
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
    local action, age = playerAction(bout, now)
    local offsets = Reedguard.sample(action, age)
    for name, joint in bout.motion.motors do
        joint.motor.C0 = (offsets[name] or CFrame.identity) * joint.rest
    end
    local frame, groups = botPose(bout, now)
    bout.bot.PrimaryPart.CFrame = botBase(bout)
    local clearance = bout.motion.contactSpace
    if (clearance.Position - Vector3.new(0, 1.43, 0) - bout.position).Magnitude > .005 then
        clearance.CFrame = CFrame.new(bout.position + Vector3.new(0, 1.43, 0)) * CFrame.Angles(0, 0, math.pi / 2)
    end
    for name, joint in bout.joints do
        joint.part.CFrame = jointFrame(frame, groups, name, joint) * joint.shell
    end
end

function Motion.impact(bout, event)
    if event.attack ~= "palm" and (event.damage or 0) > 0 then
        bout.reactionAt = event.at
        bout.reactionAction = if event.zone == "head" then "headHit" else "bodyHit"
    end
end

return Motion
