-- Fit the local Reedguard's city walk and shade the boots' contact with the pavement.
-- All contact presentation stays local and needs no shadow lights.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local opacity = {.12, .17, .27, .41}
local soleClearance = .003
local fighterId = "reedguard-kangaroo"
local source = ReplicatedStorage:WaitForChild("StarterFighterVisuals"):WaitForChild(fighterId)
-- The eight corners of the flat sole in the fighter's fitted art space.
local outline = {{.118, -.59139, .13339}, {.21332, -.767, .309},
    {.64868, -.767, .309}, {.744, -.59139, .13339}}
local soles = {}
for _, side in {"Left", "Right"} do
    local name = side .. " Leg"
    local rest = source:WaitForChild(name).CFrame
    local sign = if side == "Left" then -1 else 1
    local footprint = {}
    for _, edge in outline do
        table.insert(footprint, rest:PointToObjectSpace(Vector3.new(sign * edge[1], 0, edge[2])))
        table.insert(footprint, rest:PointToObjectSpace(Vector3.new(sign * edge[1], 0, edge[3])))
    end
    soles[name] = {
        hip = side .. " Hip",
        point = rest:PointToObjectSpace(Vector3.new(sign * .43, 0, -.23)),
        forward = rest:VectorToObjectSpace(-Vector3.zAxis),
        footprint = footprint,
    }
end

local folder = Instance.new("Folder")
folder.Name = "Local Reedguard Foot Shadows"
folder.Parent = workspace

local function makeShadow(name)
    local plate = Instance.new("Part")
    plate.Name = name
    plate.Size = Vector3.new(1.08, .01, 1.48)
    plate.Anchored = true
    plate.CanCollide = false
    plate.CanTouch = false
    plate.CanQuery = false
    plate.CastShadow = false
    plate.Transparency = 1
    plate.Parent = folder

    local surface = Instance.new("SurfaceGui")
    surface.Face = Enum.NormalId.Top
    surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
    surface.CanvasSize = Vector2.new(100, 100)
    surface.LightInfluence = 0
    surface.Enabled = false
    surface.Parent = plate

    local layers = {}
    for index, diameter in {.98, .82, .65, .46} do
        local oval = Instance.new("Frame")
        oval.AnchorPoint = Vector2.new(.5, .5)
        oval.Position = UDim2.fromScale(.5, .5)
        oval.Size = UDim2.fromScale(diameter, diameter)
        oval.BorderSizePixel = 0
        oval.BackgroundColor3 = Color3.fromRGB(42, 27, 33)
        oval.Parent = surface
        local round = Instance.new("UICorner")
        round.CornerRadius = UDim.new(.5, 0)
        round.Parent = oval
        layers[index] = oval
    end
    return {plate = plate, surface = surface, layers = layers}
end

local shadows = {}
for name in soles do
    shadows[name] = makeShadow(name)
end

local ray = RaycastParams.new()
ray.RespectCanCollide = true
ray.IgnoreWater = true
local visibleRay = RaycastParams.new()
visibleRay.FilterType = Enum.RaycastFilterType.Include
local visibleScope, visibleFilter = nil, {}
local trackedCharacter
local idleWeight = 0
local plantedFeet = {}
local elapsed = 0
local lastPlantAt = -math.huge
local lastPlantFrame
local walkTrack
local supportByFoot = {}
local soleStepLift = .18
-- The stock R6 cycle carries each foot forward during these phase intervals.
local swingPhases = { ["Left Leg"] = .16, ["Right Leg"] = .57 }
local armWelds = {}
local armShell
local armWeight, armPhase = 0, 0

local function cityJoint(character, humanoid, root)
    local animate = character and character:FindFirstChild("Animate")
    if not root or root.Anchored
        or not animate or animate.Disabled or player:GetAttribute("SparringActive")
        or humanoid.FloorMaterial == Enum.Material.Air
        or humanoid:GetState() ~= Enum.HumanoidStateType.Running or humanoid.Sit then
        return nil
    end
    return root:FindFirstChild("RootJoint")
end

local function moving(humanoid, root)
    return humanoid.MoveDirection.Magnitude > .01 or root.AssemblyLinearVelocity.Magnitude > .5
end

local function visibleFloor(floor, probe)
    local name = floor.Instance.Name
    local art
    if name == "Promenade mortar bed" then
        art = floor.Instance.Parent
    elseif name == "Grand Dojo Spawn" then
        local city = workspace:FindFirstChild("Grand Dojo City")
        local plaza = city and city:FindFirstChild("Plaza & streets")
        art = plaza and plaza:FindFirstChild("Hewn promenade paving")
    elseif name == "Warm ring canvas" then
        art = floor.Instance.Parent:FindFirstChild("Woven arena canvas")
    end
    if art then
        if art ~= visibleScope then
            visibleScope = art
            visibleFilter[1] = art
            visibleRay.FilterDescendantsInstances = visibleFilter
        end
        local point = Vector3.new(probe.X, floor.Position.Y, probe.Z)
        local surface = workspace:Raycast(point + Vector3.yAxis * .12, -Vector3.yAxis * .17, visibleRay)
        if surface and surface.Normal.Y >= .90 then
            return surface
        end
    end
    return floor
end

local function floorAt(probe, above, reach)
    local floor = workspace:Raycast(probe + Vector3.yAxis * above, -Vector3.yAxis * reach, ray)
    return floor and visibleFloor(floor, probe)
end

local function footFloor(probe, center)
    local floor = floorAt(probe, .40, .80)
    if not floor or floor.Normal.Y < .90 then
        return nil
    end
    local distance = (center - floor.Position):Dot(floor.Normal) / floor.Normal.Y
    if math.abs(distance) > .32 then
        return nil
    end
    return floor, center - Vector3.yAxis * distance
end

local function supportPlane(foot, sole, point)
    local centerFloor, center = footFloor(point, point)
    local highestFloor, highest, highestProbe = centerFloor, center, point
    -- A boot can overlap a raised stone while its center is over the lower bed.
    -- An adjacent high stair should still remain a stair until the player steps onto it.
    local ceiling = if center then center.Y + .17 else math.huge
    local supports = if centerFloor then {centerFloor.Position} else {}
    for _, localPoint in sole.footprint do
        local probe = foot:PointToWorldSpace(localPoint)
        local cornerFloor, cornerCenter = footFloor(probe, point)
        if cornerCenter and cornerCenter.Y <= ceiling then
            table.insert(supports, cornerFloor.Position)
            if not highest or cornerCenter.Y > highest.Y + .001 then
                highestFloor, highest, highestProbe = cornerFloor, cornerCenter, probe
            end
        end
    end
    if not highest then
        return nil
    end
    if not center or highest.Y - center.Y <= .025 then
        return highestFloor.Normal, highest
    end

    -- Tilt toward a shallow lip so the sole can share support with the lower paving.
    local rise = highest.Y - center.Y
    local run = (highestProbe - point) * Vector3.new(1, 0, 1)
    local normal = (centerFloor.Normal - run.Unit * math.min(.30, rise / run.Magnitude)).Unit
    local height = -math.huge
    for _, support in supports do
        local offset = support - point
        height = math.max(height, point.Y + offset:Dot(normal) / normal.Y)
    end
    return normal, Vector3.new(point.X, height, point.Z)
end

local function footTarget(hip, foot, sole, torsoRest)
    local weld = foot and foot:FindFirstChildOfClass("Weld")
    if not (hip and weld and weld.Part0 == hip.Part1) then
        return nil
    end
    -- Use the unanimated boot to keep the next ray independent of the planted pose.
    local hipRest = torsoRest * hip.C0
    local footRest = hipRest * hip.C1:Inverse() * weld.C0 * weld.C1:Inverse()
    local point = footRest:PointToWorldSpace(sole.point)
    local forward = footRest:VectorToWorldSpace(sole.forward)
    local normal, center = supportPlane(footRest, sole, point)
    if not normal then
        return nil
    end
    local tangent = forward - normal * forward:Dot(normal)
    local restSole = CFrame.lookAt(point, point + forward)
    local contact = center + normal * soleClearance
    local planted = CFrame.lookAt(contact, contact + tangent, normal)
    return planted * restSole:ToObjectSpace(hipRest)
end

local function walkPhase(humanoid)
    if not walkTrack or not walkTrack.IsPlaying then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in animator:GetPlayingAnimationTracks() do
                if track.Animation and track.Animation.Name == "WalkAnim" then
                    walkTrack = track
                    break
                end
            end
        end
    end
    if walkTrack and walkTrack.IsPlaying and walkTrack.Length > 0 then
        return walkTrack.TimePosition / walkTrack.Length, walkTrack.WeightCurrent
    end
    return 0, 0
end

local function releaseArmFit()
    for _, arm in armWelds do
        if arm.weld.Parent and arm.weld.C0 == arm.applied then
            arm.weld.C0 = arm.rest
        end
    end
    table.clear(armWelds)
    armShell, armWeight = nil, 0
end

local function fitWalkingArms(shell, torso, phase, walkWeight, dt)
    if armShell ~= shell then
        releaseArmFit()
        armShell = shell
    end
    if walkWeight > .001 then
        armPhase = phase
    end
    armWeight += math.clamp(walkWeight - armWeight, -dt / .14, dt / .14)
    if armWeight <= .001 then
        if next(armWelds) then releaseArmFit() end
        return
    end

    local stride = math.cos((armPhase - .36) * 2 * math.pi)
    for _, side in {"Left", "Right"} do
        local arm = armWelds[side]
        if not arm then
            local mesh = shell:FindFirstChild(side .. " Arm")
            local weld = mesh and mesh:FindFirstChildOfClass("Weld")
            local shoulder = torso:FindFirstChild(side .. " Shoulder")
            if not (weld and shoulder and shoulder.Part1 and weld.Part0 == shoulder.Part1) then continue end
            arm = {weld = weld, shoulder = shoulder, rest = weld.C0, sign = if side == "Right" then 1 else -1}
            armWelds[side] = arm
        end
        local shoulder = arm.shoulder
        local stock = shoulder.Transform
        local foreAft = CFrame.Angles(math.rad(3 + arm.sign * 15 * stride), 0, math.rad(arm.sign * 3))
        local axes = shoulder.C0.Rotation
        local fitted = stock:Lerp(axes:ToObjectSpace(foreAft * axes), armWeight)
        -- Replace the stock angles on the visible shell around the authored
        -- pivot. The character's Motor6D and contact physics remain untouched.
        local attachment = shoulder.C1
        arm.weld.C0 = attachment * stock:Inverse() * fitted * attachment:Inverse() * arm.rest
        arm.applied = arm.weld.C0
    end
end

local function lowestSole(frame, sole, normal)
    local localNormal = frame:VectorToObjectSpace(normal)
    local nearest, depth = sole.point, math.huge
    for _, point in sole.footprint do
        local projection = point:Dot(localNormal)
        if projection < depth then nearest, depth = point, projection end
    end
    return nearest, depth
end

local function fitMovingBoot(name, sole, hip, foot, torso, root, lift, now)
    local weld = foot and foot:FindFirstChildOfClass("Weld")
    if not (hip and weld and weld.Part0 == hip.Part1) then
        return
    end
    local joint = torso * hip.C0
    local frame = joint * hip.Transform * hip.C1:Inverse() * weld.C0 * weld.C1:Inverse()
    local center = frame:PointToWorldSpace(sole.point)
    local contact = lowestSole(frame, sole, Vector3.yAxis)
    local lowest = frame:PointToWorldSpace(contact)

    local support = supportByFoot[name]
    if not support or now - support.at >= 1 / 30
        or (center - support.center).Magnitude > .65 or (lowest - support.lowest).Magnitude > .70 then
        local base = root.Position.Y - 2.1326
        local function floorBelow(point)
            local probe = Vector3.new(point.X, base, point.Z)
            local hit = floorAt(probe, .43, .86)
            return if hit and hit.Normal.Y >= .82 then hit else nil
        end
        support = {at = now, center = center, lowest = lowest, floor = floorBelow(center), edge = floorBelow(lowest)}
        supportByFoot[name] = support
    end
    local rise = -math.huge
    for _, floor in {support.floor, support.edge} do
        if floor.Instance.Parent then
            local _, depth = lowestSole(frame, sole, floor.Normal)
            local offset = ((floor.Position - frame.Position):Dot(floor.Normal) - depth) / floor.Normal.Y
            -- A ray through a grout seam sees the hidden bed. The boot is wide enough to bridge the surrounding stones.
            if floor.Instance.Name == "Promenade mortar bed" then offset += .067 end
            rise = math.max(rise, offset)
        end
    end
    if rise > -math.huge then
        local vertical = math.clamp(rise + soleClearance + lift, -.11, .60)
        hip.Transform += joint:VectorToObjectSpace(Vector3.yAxis * vertical)
    end
end

RunService.PreSimulation:Connect(function(dt)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    local animate = character and character:FindFirstChild("Animate")
    if shell and shell:GetAttribute("FighterId") == fighterId and animate and animate.Disabled then
        releaseArmFit()
        -- Arena poses are authored in C0. The local Animator can still supply
        -- a hip Transform after Animate stops, lifting the planted boots.
        local torso = character:FindFirstChild("Torso")
        if torso then
            for _, name in {"Left Hip", "Right Hip"} do
                local hip = torso:FindFirstChild(name)
                if hip and hip.Transform ~= CFrame.identity then
                    hip.Transform = CFrame.identity
                end
            end
        end
        idleWeight = 0
        table.clear(supportByFoot)
        return
    end
    local joint = character == trackedCharacter and shell and shell:GetAttribute("FighterId") == fighterId
        and cityJoint(character, humanoid, root)
    if not joint or not joint.Part1 then
        releaseArmFit()
        idleWeight = 0
        table.clear(supportByFoot)
        return
    end
    local torsoAnimated = root.CFrame * joint.C0 * joint.Transform * joint.C1:Inverse()
    local walking = moving(humanoid, root)
    local onCourse = player:GetAttribute("SkywalkTrialMode")
    local phase, weight = 0, 0
    if walking and not onCourse then
        phase, weight = walkPhase(humanoid)
    end
    if onCourse or character:GetAttribute("ArenaJumpEnabled") then
        releaseArmFit()
    else
        fitWalkingArms(shell, joint.Part1, phase, weight, dt)
    end
    if walking then
        idleWeight = 0
        if not onCourse then
            local now = os.clock()
            for name, sole in soles do
                local progress = math.min(1, ((phase - swingPhases[name]) % 1) / .40)
                local swing = weight * math.sin(math.pi * progress) ^ 2
                local hip = joint.Part1:FindFirstChild(sole.hip)
                if hip then
                    -- The stock angles expect square R6 feet. Soften the roll of Reedguard's long boots.
                    local animated = hip.Transform
                    local angle = CFrame.identity:Lerp(animated.Rotation, .57 + .18 * swing)
                    hip.Transform = CFrame.new(animated.Position) * angle
                    fitMovingBoot(name, sole, hip, shell:FindFirstChild(name), torsoAnimated, root, soleStepLift * swing, now)
                end
            end
        else
            table.clear(supportByFoot)
        end
        return
    end
    idleWeight = math.min(1, idleWeight + dt / .12)
    for hip, target in plantedFeet do
        local planted = (torsoAnimated * hip.C0):ToObjectSpace(target)
        hip.Transform = hip.Transform:Lerp(planted, idleWeight)
    end
    if idleWeight < 1 and next(supportByFoot) then
        local now = os.clock()
        for name, sole in soles do
            local hip = joint.Part1:FindFirstChild(sole.hip)
            fitMovingBoot(name, sole, hip, shell:FindFirstChild(name), torsoAnimated, root, 0, now)
        end
    else
        table.clear(supportByFoot)
    end
end)

RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 1 / 30 then
        return
    end
    elapsed %= 1 / 30

    local character = player.Character
    if character ~= trackedCharacter then
        trackedCharacter = character
        lastPlantFrame = nil
        walkTrack = nil
        table.clear(supportByFoot)
        ray.FilterDescendantsInstances = if character then {character} else {}
    end
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    local isReedguard = shell and shell:GetAttribute("FighterId") == fighterId
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    local joint = isReedguard and cityJoint(character, humanoid, root)
    if not joint or not joint.Part1 or moving(humanoid, root) then
        table.clear(plantedFeet)
        lastPlantFrame = nil
    elseif not lastPlantFrame or os.clock() - lastPlantAt >= .12
        or (root.Position - lastPlantFrame.Position).Magnitude > .02
        or root.CFrame.LookVector:Dot(lastPlantFrame.LookVector) < .9999 then
        lastPlantAt, lastPlantFrame = os.clock(), root.CFrame
        table.clear(plantedFeet)
        local torsoRest = lastPlantFrame * joint.C0 * joint.C1:Inverse()
        for name, sole in soles do
            local hip = joint.Part1:FindFirstChild(sole.hip)
            if hip then
                plantedFeet[hip] = footTarget(hip, shell:FindFirstChild(name), sole, torsoRest)
            end
        end
    end
    -- Intro holds anchor the root, so a nearby floor ray can supply contact
    -- while the Humanoid temporarily reports Air.
    local active = isReedguard and humanoid and (humanoid.FloorMaterial ~= Enum.Material.Air
        or (root and root.Anchored))
        and humanoid:GetState() ~= Enum.HumanoidStateType.Swimming
    for name, shadow in shadows do
        local foot = active and shell:FindFirstChild(name)
        local sole = soles[name]
        local position = foot and foot.CFrame:PointToWorldSpace(sole.point)
        local soleHeight = position and position.Y
        if position and supportByFoot[name] then
            local contact = lowestSole(foot.CFrame, sole, Vector3.yAxis)
            local edge = foot.CFrame:PointToWorldSpace(contact)
            position = position:Lerp(edge, .60)
            soleHeight = edge.Y
        end
        local floor = position and floorAt(position, .18, .54)
        local floorGap = if floor then soleHeight - floor.Position.Y else math.huge
        local fade = if floor and floor.Normal.Y >= .65
            then math.clamp(1 - floorGap / .26, 0, 1)
            else 0
        shadow.surface.Enabled = fade > .03
        if shadow.surface.Enabled then
            local normal = floor.Normal
            local forward = foot.CFrame:VectorToWorldSpace(sole.forward)
            forward -= normal * forward:Dot(normal)
            local center = floor.Position + normal * .009
            local tangent = if forward.Magnitude > .01 then forward.Unit else normal:Cross(Vector3.xAxis).Unit
            shadow.plate.CFrame = CFrame.lookAt(center, center + tangent, normal)
            for index, layer in shadow.layers do
                layer.BackgroundTransparency = 1 - fade * opacity[index]
            end
        end
    end
end)
