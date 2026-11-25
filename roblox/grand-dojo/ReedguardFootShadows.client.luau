-- Keep the local Reedguard's boots level at rest and shade their floor contact.
-- All contact presentation stays local and needs no shadow lights.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local opacity = {.08, .12, .20, .34}
local visualFloorLift = { ["Grand Dojo Spawn"] = .020, ["Promenade mortar bed"] = .079 }
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
    plate.Size = Vector3.new(.94, .01, 1.34)
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
local trackedCharacter
local idleWeight = 0
local plantedFeet = {}
local elapsed = 0

local function idleJoint(character, humanoid, root)
    local animate = character and character:FindFirstChild("Animate")
    -- The ring owns its own poses. Defer to locomotion as soon as the player moves.
    if not root or root.Anchored
        or not animate or animate.Disabled or player:GetAttribute("SparringActive")
        or player:GetAttribute("RingTrainingActive") or humanoid.FloorMaterial == Enum.Material.Air
        or humanoid:GetState() ~= Enum.HumanoidStateType.Running or humanoid.Sit
        or humanoid.MoveDirection.Magnitude > .01 or root.AssemblyLinearVelocity.Magnitude > .5 then
        return nil
    end
    return root:FindFirstChild("RootJoint")
end

local function findFootTargets(root, joint, shell)
    local torsoRest = root.CFrame * joint.C0 * joint.C1:Inverse()
    for leg, sole in soles do
        local side = if leg == "Left Leg" then "Left" else "Right"
        local hip = joint.Part1:FindFirstChild(side .. " Hip")
        local foot = shell:FindFirstChild(leg)
        local weld = foot and foot:FindFirstChildOfClass("Weld")
        if not (hip and weld and weld.Part0 == hip.Part1) then
            return false
        end
        -- Sample from the unanimated bind pose so planting never feeds back into the next ray.
        local hipRest = torsoRest * hip.C0
        local footRest = hipRest * hip.C1:Inverse() * weld.C0 * weld.C1:Inverse()
        local point = footRest:PointToWorldSpace(sole.point)
        local floor = workspace:Raycast(point + Vector3.yAxis * .40, -Vector3.yAxis * .80, ray)
        if not floor or floor.Normal.Y < .90 or math.abs(point.Y - floor.Position.Y) > .32 then
            return false
        end
        local forward = footRest:VectorToWorldSpace(sole.forward)
        local tangent = forward - floor.Normal * forward:Dot(floor.Normal)
        local restSole = CFrame.lookAt(point, point + forward)
        local planted = CFrame.lookAt(floor.Position, floor.Position + tangent, floor.Normal)
        plantedFeet[hip] = planted * restSole:ToObjectSpace(hipRest)
    end
    return true
end

RunService.PreSimulation:Connect(function(dt)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
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
    if joint and joint.Part1 and not findFootTargets(root, joint, shell) then
        table.clear(plantedFeet)
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
        local floor = position and workspace:Raycast(position + Vector3.yAxis * .18, -Vector3.yAxis * .54, ray)
        -- The smooth walking surfaces sit below the visible sandstone faces.
        local lift = floor and visualFloorLift[floor.Instance.Name] or 0
        local floorGap = if floor then position.Y - floor.Position.Y else math.huge
        local fade = if floor and floor.Normal.Y >= .65
            then math.clamp(1 - (floorGap - lift) / .26, 0, 1)
            else 0
        shadow.surface.Enabled = fade > .03
        if shadow.surface.Enabled then
            local normal = floor.Normal
            local forward = foot.CFrame:VectorToWorldSpace(sole.forward)
            forward -= normal * forward:Dot(normal)
            local center = floor.Position + normal * (.009 + lift)
            local tangent = if forward.Magnitude > .01 then forward.Unit else normal:Cross(Vector3.xAxis).Unit
            shadow.plate.CFrame = CFrame.lookAt(center, center + tangent, normal)
            for index, layer in shadow.layers do
                layer.BackgroundTransparency = 1 - fade * opacity[index]
            end
        end
    end
end)
