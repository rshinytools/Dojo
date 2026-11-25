-- The city's lighting can leave no readable shadow under small feet.
-- Only the local Reedguard draws these soft accents, with no shadow lights.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local opacity = {.07, .11, .16, .23}
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
    plate.Size = Vector3.new(1.02, .01, 1.42)
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
local elapsed = 0

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
    for name, shadow in shadows do
        local foot = active and shell:FindFirstChild(name)
        local sole = soles[name]
        local position = foot and foot.CFrame:PointToWorldSpace(sole.point)
        local floor = position and workspace:Raycast(position + Vector3.yAxis * .18, -Vector3.yAxis * .54, ray)
        local fade = if floor and floor.Normal.Y >= .65
            then math.clamp(1 - (position.Y - floor.Position.Y) / .32, 0, 1)
            else 0
        shadow.surface.Enabled = fade > .03
        if shadow.surface.Enabled then
            local normal = floor.Normal
            local forward = foot.CFrame:VectorToWorldSpace(sole.forward)
            forward -= normal * forward:Dot(normal)
            -- The promenade's visual sandstone sits above the walkable mortar.
            local lift = if floor.Instance.Name == "Promenade mortar bed" then .068 else 0
            local center = floor.Position + normal * (.009 + lift)
            local tangent = if forward.Magnitude > .01 then forward.Unit else normal:Cross(Vector3.xAxis).Unit
            shadow.plate.CFrame = CFrame.lookAt(center, center + tangent, normal)
            for index, layer in shadow.layers do
                layer.BackgroundTransparency = 1 - fade * opacity[index]
            end
        end
    end
end)
