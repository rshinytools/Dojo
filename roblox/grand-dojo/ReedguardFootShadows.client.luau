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
local onLevelFloor = false
local elapsed = 0

RunService.PreSimulation:Connect(function(dt)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    local animate = character and character:FindFirstChild("Animate")
    -- The ring owns its own poses. Defer to locomotion as soon as the player moves.
    if character ~= trackedCharacter or not root or root.Anchored or not onLevelFloor
        or not shell or shell:GetAttribute("FighterId") ~= fighterId
        or not animate or animate.Disabled or player:GetAttribute("SparringActive")
        or player:GetAttribute("RingTrainingActive") or humanoid.FloorMaterial == Enum.Material.Air
        or humanoid:GetState() ~= Enum.HumanoidStateType.Running or humanoid.Sit
        or humanoid.MoveDirection.Magnitude > .01 or root.AssemblyLinearVelocity.Magnitude > .5 then
        idleWeight = 0
        return
    end

    local rootJoint = root:FindFirstChild("RootJoint")
    local torso = rootJoint and rootJoint.Part1
    if not torso then
        return
    end
    idleWeight = math.min(1, idleWeight + dt / .12)
    -- Cancel the torso's idle motion at the hips so the torso can keep breathing.
    local counterMotion = rootJoint.C1 * rootJoint.Transform:Inverse() * rootJoint.C1:Inverse()
    for _, name in {"Left Hip", "Right Hip"} do
        local hip = torso:FindFirstChild(name)
        if hip then
            local planted = hip.C0:ToObjectSpace(counterMotion * hip.C0)
            hip.Transform = hip.Transform:Lerp(planted, idleWeight)
        end
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
    -- Intro holds anchor the root, so a nearby floor ray can supply contact
    -- while the Humanoid temporarily reports Air.
    local active = isReedguard and humanoid and (humanoid.FloorMaterial ~= Enum.Material.Air
        or (root and root.Anchored))
        and humanoid:GetState() ~= Enum.HumanoidStateType.Swimming
    local levelContacts = 0
    for name, shadow in shadows do
        local foot = active and shell:FindFirstChild(name)
        local sole = soles[name]
        local position = foot and foot.CFrame:PointToWorldSpace(sole.point)
        local floor = position and workspace:Raycast(position + Vector3.yAxis * .18, -Vector3.yAxis * .54, ray)
        -- The smooth walking surfaces sit below the visible sandstone faces.
        local lift = floor and visualFloorLift[floor.Instance.Name] or 0
        local floorGap = if floor then position.Y - floor.Position.Y else math.huge
        if floor and floor.Normal.Y >= .995 and math.abs(floorGap) < .11 then
            levelContacts += 1
        end
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
    onLevelFloor = levelContacts == 2
end)
