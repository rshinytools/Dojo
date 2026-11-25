-- Keep the local Reedguard's boots level at rest and shade their floor contact.
-- All contact presentation stays local and needs no shadow lights.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local opacity = {.12, .17, .27, .41}
local soleClearance = .003
local fighterId = "reedguard-kangaroo"
local source = ReplicatedStorage:WaitForChild("StarterFighterVisuals"):WaitForChild(fighterId)
local soles = {}
for _, side in {"Left", "Right"} do
    local name = side .. " Leg"
    local rest = source:WaitForChild(name).CFrame
    local x = if side == "Left" then -.43 else .43
    soles[name] = {
        point = rest:PointToObjectSpace(Vector3.new(x, 0, -.23)),
        forward = rest:VectorToObjectSpace(-Vector3.zAxis),
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

local function idleJoint(character, humanoid, root)
    local animate = character and character:FindFirstChild("Animate")
    -- The ring owns its own poses. Defer to locomotion as soon as the player moves.
    if not root or root.Anchored
        or not animate or animate.Disabled or player:GetAttribute("SparringActive")
        or humanoid.FloorMaterial == Enum.Material.Air
        or humanoid:GetState() ~= Enum.HumanoidStateType.Running or humanoid.Sit
        or humanoid.MoveDirection.Magnitude > .01 or root.AssemblyLinearVelocity.Magnitude > .5 then
        return nil
    end
    return root:FindFirstChild("RootJoint")
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
    local floor, center = footFloor(point, point)
    if not floor then
        -- The toe or heel can still carry weight when the sole center is over a gap.
        floor, center = footFloor(point + forward * .38, point)
        if not floor then
            floor, center = footFloor(point - forward * .36, point)
        end
        if not floor then
            return nil
        end
    end
    local normal = floor.Normal
    local tangent = forward - normal * forward:Dot(normal)
    local restSole = CFrame.lookAt(point, point + forward)
    local contact = center + normal * soleClearance
    local planted = CFrame.lookAt(contact, contact + tangent, normal)
    return planted * restSole:ToObjectSpace(hipRest)
end

RunService.PreSimulation:Connect(function(dt)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    local animate = character and character:FindFirstChild("Animate")
    if shell and shell:GetAttribute("FighterId") == fighterId and animate and animate.Disabled then
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
        return
    end
    local joint = character == trackedCharacter and next(plantedFeet) and idleJoint(character, humanoid, root)
    if not joint or not joint.Part1 then
        idleWeight = 0
        return
    end
    idleWeight = math.min(1, idleWeight + dt / .12)
    local torsoAnimated = root.CFrame * joint.C0 * joint.Transform * joint.C1:Inverse()
    for hip, target in plantedFeet do
        local planted = (torsoAnimated * hip.C0):ToObjectSpace(target)
        hip.Transform = hip.Transform:Lerp(planted, idleWeight)
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
        ray.FilterDescendantsInstances = if character then {character} else {}
    end
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    local isReedguard = shell and shell:GetAttribute("FighterId") == fighterId
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    table.clear(plantedFeet)
    local joint = isReedguard and idleJoint(character, humanoid, root)
    if joint and joint.Part1 then
        local torsoRest = root.CFrame * joint.C0 * joint.C1:Inverse()
        for name, sole in soles do
            local side = if name == "Left Leg" then "Left" else "Right"
            local hip = joint.Part1:FindFirstChild(side .. " Hip")
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
        local floor = position and floorAt(position, .18, .54)
        local floorGap = if floor then position.Y - floor.Position.Y else math.huge
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
