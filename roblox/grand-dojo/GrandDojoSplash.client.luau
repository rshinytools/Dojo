local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local PLAYER_ACTION = "BeastDojoLoading"
local LIMIT_SECONDS = 16
local MINIMUM_SECONDS = 1.6
local NIGHT = Color3.fromRGB(18, 20, 36)
local GOLD = Color3.fromRGB(255, 215, 146)
local IVORY = Color3.fromRGB(255, 242, 214)

local function create(class, parent, properties)
    local instance = Instance.new(class)
    for key, value in properties do
        instance[key] = value
    end
    instance.Parent = parent
    return instance
end

local function label(parent, text, position, size, font, maximum, tint)
    local line = create("TextLabel", parent, {
        BackgroundTransparency = 1, Position = position, Size = size,
        Text = text, Font = font, TextColor3 = tint, TextScaled = true,
    })
    create("UITextSizeConstraint", line, {MinTextSize = 12, MaxTextSize = maximum})
    return line
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local splash = create("ScreenGui", nil, {
    Name = "BeastDojoSplash", IgnoreGuiInset = true, ScreenInsets = Enum.ScreenInsets.None,
    DisplayOrder = 1500, ResetOnSpawn = false,
})
local screen = create("Frame", splash, {Size = UDim2.fromScale(1, 1), BackgroundColor3 = NIGHT, BorderSizePixel = 0, Active = true})
local skyArt = create("ImageLabel", screen, {
    Size = UDim2.fromScale(1, 1), Image = "rbxassetid://113721219098484",
    ScaleType = Enum.ScaleType.Crop, BackgroundTransparency = 1,
})
local shade = create("Frame", screen, {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
})
create("UIGradient", shade, {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 33, 61)),
        ColorSequenceKeypoint.new(.49, Color3.fromRGB(63, 29, 46)),
        ColorSequenceKeypoint.new(1, NIGHT),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, .49), NumberSequenceKeypoint.new(.50, .57),
        NumberSequenceKeypoint.new(.79, .06), NumberSequenceKeypoint.new(1, 0),
    }),
})
local gateArt = ReplicatedFirst:FindFirstChild("Splash Gate")
if gateArt and not UserInputService.VREnabled then
    local view = create("ViewportFrame", screen, {
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .34), Size = UDim2.fromScale(.90, .56),
        BackgroundTransparency = 1, Ambient = Color3.fromRGB(177, 165, 192),
        LightColor = Color3.fromRGB(255, 221, 166), LightDirection = Vector3.new(-.8, -1, -.6),
    })
    create("UISizeConstraint", view, {MaxSize = Vector2.new(880, 430)})
    create("UIAspectRatioConstraint", view, {AspectRatio = 2, DominantAxis = Enum.DominantAxis.Width})
    local world = create("WorldModel", view, {})
    gateArt:Clone().Parent = world
    local camera = create("Camera", view, {
        CFrame = CFrame.lookAt(Vector3.new(13, 10.6, 33), Vector3.new(0, 5.7, 0)),
        FieldOfView = 28,
    })
    view.CurrentCamera = camera
end

local panel = create("Frame", screen, {
    AnchorPoint = Vector2.new(.5, 1), Position = UDim2.fromScale(.5, .90), Size = UDim2.fromScale(.84, .34),
    BackgroundTransparency = 1,
})
create("UISizeConstraint", panel, {MaxSize = Vector2.new(700, 260)})
label(panel, "GRAND DOJO CITY", UDim2.fromScale(0, 0), UDim2.fromScale(1, .12), Enum.Font.GothamBold, 16, GOLD)
label(panel, "BEAST DOJO", UDim2.fromScale(0, .10), UDim2.fromScale(1, .47), Enum.Font.Garamond, 92, IVORY)
local track = create("Frame", panel, {
    Position = UDim2.fromScale(0, .71), Size = UDim2.new(1, 0, 0, 7),
    BackgroundColor3 = Color3.fromRGB(82, 63, 82), BorderSizePixel = 0, ClipsDescendants = true,
})
create("UICorner", track, {CornerRadius = UDim.new(1, 0)})
local fill = create("Frame", track, {
    Size = UDim2.fromScale(.04, 1), BackgroundColor3 = GOLD, BorderSizePixel = 0,
})
create("UICorner", fill, {CornerRadius = UDim.new(1, 0)})
create("UIGradient", fill, {
    Color = ColorSequence.new(Color3.fromRGB(221, 122, 81), GOLD),
})
local status = label(panel, "Preparing the plaza…", UDim2.fromScale(0, .82), UDim2.fromScale(.82, .18),
    Enum.Font.GothamMedium, 17, IVORY)
status.TextXAlignment = Enum.TextXAlignment.Left
local progress = label(panel, "4%", UDim2.fromScale(.83, .82), UDim2.fromScale(.17, .18),
    Enum.Font.GothamBold, 17, GOLD)
progress.TextXAlignment = Enum.TextXAlignment.Right

splash.Parent = playerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()
ContextActionService:BindActionAtPriority(PLAYER_ACTION, function()
    return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, table.unpack(Enum.PlayerActions:GetEnumItems()))

local started = os.clock()
local deadline = started + LIMIT_SECONDS
local settled, failed, requested = 0, 0, 0
local finished = false

local function setProgress(fraction, message)
    fill.Size = UDim2.fromScale(fraction, 1)
    progress.Text = string.format("%d%%", math.floor(fraction * 100 + .5))
    status.Text = message
end

local function queue(asset)
    if not asset then
        return
    end
    requested += 1
    task.spawn(function()
        local hadFailure = false
        local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, {asset}, function(_, result)
            if result ~= Enum.AssetFetchStatus.Success then
                hadFailure = true
            end
        end)
        if not finished then
            settled += 1
            if not ok or hadFailure then
                failed += 1
            end
        end
    end)
end

local function playable()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local city = workspace:FindFirstChild("Grand Dojo City")
    local plaza = city and city:FindFirstChild("Plaza & streets")
    if not (game:IsLoaded() and root and plaza and workspace.CurrentCamera) then
        return false
    end
    local filter = RaycastParams.new()
    filter.FilterType = Enum.RaycastFilterType.Exclude
    filter.FilterDescendantsInstances = {character}
    filter.RespectCanCollide = true
    return workspace:Raycast(root.Position, Vector3.new(0, -6, 0), filter) ~= nil
end

local function loadEntry()
    queue(skyArt)
    task.spawn(function()
        local spawn = workspace:WaitForChild("Grand Dojo Spawn", 5)
        if spawn and workspace.StreamingEnabled and not finished then
            pcall(player.RequestStreamAroundAsync, player, spawn.Position, 5)
        end
    end)

    local city = workspace:WaitForChild("Grand Dojo City", 6)
    local plaza = city and city:WaitForChild("Plaza & streets", math.max(.1, started + 7 - os.clock()))
    queue(Lighting:FindFirstChildOfClass("Sky"))
    if plaza then
        for _, name in {
            "TS03_ENV_Rock_02_MossPatch", "TS02_ENV_Grass_02", "TS02_ENV_Grass_04",
            "TS02_ENV_GroundFlowers_01", "TS03_Waterlilies_03",
        } do
            queue(plaza:FindFirstChild(name, true))
        end
        local petals = plaza:FindFirstChild("Creator Store blossom petals", true)
        queue(petals and petals:FindFirstChildOfClass("ParticleEmitter"))
        local sakura = plaza:FindFirstChild("Relay garden Sakura tree", true)
        if sakura then
            queue(sakura:FindFirstChildOfClass("MeshPart"))
            queue(sakura:FindFirstChildWhichIsA("SpecialMesh", true))
        end
    end

    while os.clock() < deadline do
        local ready = playable()
        if ready and settled == requested and os.clock() - started >= MINIMUM_SECONDS then
            return "ready"
        end
        local fraction = math.min(.94, .13 + .77 * settled / math.max(requested, 1) + (ready and .04 or 0))
        local message = if settled < requested then "Loading plaza assets…" else "Preparing the plaza…"
        setProgress(fraction, message)
        task.wait(.08)
    end
    return "timeout"
end

local function framePlazaArrival()
    if GuiService.ReducedMotionEnabled or UserInputService.VREnabled then
        return
    end
    local camera = workspace.CurrentCamera
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local spawn = workspace:FindFirstChild("Grand Dojo Spawn")
    if not (camera and root and humanoid and spawn) then
        return
    end

    local step = "BeastDojoFramePlaza"
    RunService:BindToRenderStep(step, Enum.RenderPriority.Camera.Value - 1, function()
        RunService:UnbindFromRenderStep(step)
        if workspace.CurrentCamera ~= camera or camera.CameraType ~= Enum.CameraType.Custom
            or camera.CameraSubject ~= humanoid or player.Character ~= character
            or camera.ViewportSize.X < camera.ViewportSize.Y
            or (root.Position - spawn.Position).Magnitude > 8
            or GuiService.ReducedMotionEnabled or UserInputService.VREnabled then
            return
        end
        local look = camera.CFrame.LookVector
        -- The default reset aims 15 degrees down. Preserve a view the
        -- player has already tilted or turned while waiting for the splash.
        if math.abs(look.Y + math.sin(math.rad(15))) > .025 or look:Dot(spawn.CFrame.LookVector) < .94 then
            return
        end
        local facing = Vector3.new(look.X, 0, look.Z).Unit
        local aim = facing - Vector3.yAxis * math.tan(math.rad(8))
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + aim)
    end)
end

local ok, outcome = pcall(loadEntry)
finished = true
local reason = if ok then outcome else "error"
if not ok then
    warn("[Beast Dojo] Loading screen continued after an error: " .. tostring(outcome))
end
if reason == "ready" and failed == 0 then
    setProgress(1, "Entering the city…")
    framePlazaArrival()
else
    status.Text = "Entering the city…"
    progress.Visible = false
end

if not (GuiService.ReducedMotionEnabled or UserInputService.VREnabled) then
    -- A small final fade uses a solid frame, avoiding a full-screen GUI render target.
    local veil = create("Frame", splash, {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = NIGHT, BorderSizePixel = 0, ZIndex = 20,
    })
    screen.Visible = false
    local fade = TweenService:Create(veil, TweenInfo.new(.24, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    fade:Play()
    task.wait(.25)
end
ContextActionService:UnbindAction(PLAYER_ACTION)
splash:Destroy()
print(string.format("[Beast Dojo] Splash finished (%s). %d/%d entry assets settled, %d failed, %.2fs.",
    reason, settled, requested, failed, os.clock() - started))
