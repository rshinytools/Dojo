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
local MINIMUM_SECONDS = 1.35
local NIGHT = Color3.fromRGB(13, 16, 30)
local INDIGO = Color3.fromRGB(26, 30, 53)
local GOLD = Color3.fromRGB(249, 199, 116)
local BRASS = Color3.fromRGB(166, 119, 69)
local IVORY = Color3.fromRGB(255, 241, 214)
local CENTER = Vector2.new(.5, .5)
local FULL = UDim2.fromScale(1, 1)

local function create(class, parent, properties)
    local instance = Instance.new(class)
    for key, value in properties do
        instance[key] = value
    end
    instance.Parent = parent
    return instance
end

local function label(parent, name, text, position, size, font, maximum, tint)
    local line = create("TextLabel", parent, {
        Name = name, BackgroundTransparency = 1, Position = position, Size = size,
        Text = text, Font = font, TextColor3 = tint, TextScaled = true,
    })
    create("UITextSizeConstraint", line, {MinTextSize = 10, MaxTextSize = maximum})
    return line
end

local function motionAllowed()
    return not (GuiService.ReducedMotionEnabled or UserInputService.VREnabled)
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local splash = create("ScreenGui", nil, {
    Name = "BeastDojoSplash", ScreenInsets = Enum.ScreenInsets.None,
    SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
    DisplayOrder = 1500, ResetOnSpawn = false,
})
local screen = create("Frame", splash, {
    Name = "Backdrop", Size = FULL, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Active = true,
})
create("UIGradient", screen, {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, INDIGO),
        ColorSequenceKeypoint.new(.42, Color3.fromRGB(92, 50, 72)),
        ColorSequenceKeypoint.new(1, NIGHT),
    }),
})
local nativeHero = create("Frame", screen, {
    Name = "NativeGateArtwork", Size = FULL, BackgroundTransparency = 1, ZIndex = 2,
})
create("ImageLabel", nativeHero, {
    Name = "Sunset", Size = FULL, Image = "rbxassetid://113721219098484",
    ImageColor3 = Color3.fromRGB(206, 179, 210), ImageTransparency = .37,
    ScaleType = Enum.ScaleType.Crop, BackgroundTransparency = 1, ZIndex = 2,
})
local seal = create("Frame", nativeHero, {
    Name = "FestivalSeal", AnchorPoint = CENTER, Position = UDim2.fromScale(.5, .335),
    Size = UDim2.fromScale(.64, .63), BackgroundTransparency = .09, BorderSizePixel = 0,
    BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 3,
})
create("UIAspectRatioConstraint", seal, {AspectRatio = 1, AspectType = Enum.AspectType.FitWithinMaxSize})
create("UISizeConstraint", seal, {MaxSize = Vector2.new(406, 406)})
create("UICorner", seal, {CornerRadius = UDim.new(.5, 0)})
create("UIStroke", seal, {Color = GOLD, Thickness = 1, Transparency = .23})
create("UIGradient", seal, {
    Color = ColorSequence.new(Color3.fromRGB(251, 181, 106), Color3.fromRGB(145, 69, 95)), Rotation = 90,
})
local insetSeal = create("Frame", seal, {
    AnchorPoint = CENTER, Position = UDim2.fromScale(.5, .5), Size = UDim2.fromScale(.93, .93),
    BackgroundTransparency = 1, ZIndex = 3,
})
create("UICorner", insetSeal, {CornerRadius = UDim.new(.5, 0)})
create("UIStroke", insetSeal, {Color = IVORY, Thickness = 1, Transparency = .68})

local gateArt = ReplicatedFirst:FindFirstChild("Splash Gate")
if gateArt and not UserInputService.VREnabled then
    local view = create("ViewportFrame", nativeHero, {
        Name = "GrandDojoGate", AnchorPoint = CENTER, Position = UDim2.fromScale(.5, .345),
        Size = UDim2.fromScale(.91, .64), BackgroundTransparency = 1, ZIndex = 4,
        Ambient = Color3.fromRGB(171, 158, 195), LightColor = Color3.fromRGB(255, 205, 151),
        LightDirection = Vector3.new(-.35, -1, -.55),
    })
    create("UISizeConstraint", view, {MaxSize = Vector2.new(840, 420)})
    create("UIAspectRatioConstraint", view, {AspectRatio = 1.85, AspectType = Enum.AspectType.FitWithinMaxSize})
    local world = create("WorldModel", view, {})
    gateArt:Clone().Parent = world
    view.CurrentCamera = create("Camera", view, {
        CFrame = CFrame.lookAt(Vector3.new(10.8, 8.8, 30.7), Vector3.new(0, 5.35, 0)),
        FieldOfView = 31,
    })
end

local artwork = ReplicatedFirst:FindFirstChild("SplashArtwork")
local splashArt
if artwork and artwork:IsA("StringValue") and artwork.Value:match("^rbxassetid://%d+$") then
    splashArt = create("ImageLabel", screen, {
        Name = "FestivalKeyArt", Size = FULL, BackgroundTransparency = 1,
        Image = artwork.Value, ScaleType = Enum.ScaleType.Crop, ZIndex = 5,
    })
end

local shade = create("Frame", screen, {
    Name = "WordmarkShade", Size = FULL, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 6,
})
create("UIGradient", shade, {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, NIGHT),
        ColorSequenceKeypoint.new(.48, Color3.fromRGB(49, 28, 53)),
        ColorSequenceKeypoint.new(1, NIGHT),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, .69),
        NumberSequenceKeypoint.new(.30, .99),
        NumberSequenceKeypoint.new(.51, .95),
        NumberSequenceKeypoint.new(.73, .10),
        NumberSequenceKeypoint.new(1, 0),
    }),
})

-- Keep the wordmark and loading information inside the safe area while the artwork extends to the edges.
local foreground = create("ScreenGui", nil, {
    Name = "BeastDojoSplashContent", ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
    SafeAreaCompatibility = Enum.SafeAreaCompatibility.None, DisplayOrder = 1501, ResetOnSpawn = false,
})
local panel = create("Frame", foreground, {
    Name = "TitleAndProgress",
    AnchorPoint = Vector2.new(.5, 1), Position = UDim2.fromScale(.5, .95), Size = UDim2.fromScale(.82, .40),
    BackgroundTransparency = 1,
})
create("UISizeConstraint", panel, {MaxSize = Vector2.new(690, 260)})

local title = label(panel, "Wordmark", "BEAST DOJO", UDim2.fromScale(0, 0), UDim2.fromScale(1, .49),
    Enum.Font.Garamond, 108, Color3.new(1, 1, 1))
create("UIGradient", title, {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 250, 234)),
        ColorSequenceKeypoint.new(.6, IVORY),
        ColorSequenceKeypoint.new(1, GOLD),
    }),
    Rotation = 90,
})
create("UIStroke", title, {
    ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
    Color = Color3.fromRGB(49, 30, 50), Thickness = 1.3, Transparency = .25,
})

label(panel, "Location", "GRAND DOJO CITY", UDim2.fromScale(.24, .50), UDim2.fromScale(.52, .13),
    Enum.Font.GothamBold, 16, GOLD)
for _, point in {.22, .78} do
    create("Frame", panel, {
        AnchorPoint = Vector2.new(if point < .5 then 1 else 0, .5),
        Position = UDim2.fromScale(point, .565), Size = UDim2.new(.15, 0, 0, 1),
        BackgroundColor3 = BRASS, BackgroundTransparency = .23, BorderSizePixel = 0,
    })
    create("Frame", panel, {
        AnchorPoint = CENTER, Position = UDim2.fromScale(point, .565), Size = UDim2.fromOffset(4, 4),
        Rotation = 45, BackgroundColor3 = GOLD, BorderSizePixel = 0,
    })
end

local loader = create("Frame", panel, {
    Name = "Loader", AnchorPoint = Vector2.new(.5, 1), Position = UDim2.fromScale(.5, 1),
    Size = UDim2.fromScale(1, .27), BackgroundTransparency = 1,
})
create("UISizeConstraint", loader, {MaxSize = Vector2.new(420, 60)})

local status = label(loader, "Status", "Finding Festival Plaza…", UDim2.new(0, 0, 0, 0),
    UDim2.new(1, -66, 1, -11), Enum.Font.GothamMedium, 18, IVORY)
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Bottom
local progress = label(loader, "AssetCount", "", UDim2.new(1, -60, 0, 0),
    UDim2.new(0, 60, 1, -11), Enum.Font.GothamBold, 15, GOLD)
progress.TextXAlignment = Enum.TextXAlignment.Right
progress.TextYAlignment = Enum.TextYAlignment.Bottom

local track = create("Frame", loader, {
    Name = "Track", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
    Size = UDim2.new(1, 0, 0, 5), BackgroundColor3 = Color3.fromRGB(71, 60, 84),
    BorderSizePixel = 0, ClipsDescendants = true,
})
create("UICorner", track, {CornerRadius = UDim.new(1, 0)})
local fill = create("Frame", track, {
    Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
})
create("UICorner", fill, {CornerRadius = UDim.new(1, 0)})
create("UIGradient", fill, {
    Color = ColorSequence.new(Color3.fromRGB(210, 116, 70), GOLD),
})

splash.Parent = playerGui
foreground.Parent = playerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()
ContextActionService:BindActionAtPriority(PLAYER_ACTION, function()
    return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, table.unpack(Enum.PlayerActions:GetEnumItems()))

local started = os.clock()
local deadline = started + LIMIT_SECONDS
local settled, failed, requested = 0, 0, 0
local finished = false
local fillFraction = 0
local fillTween

local function setProgress(fraction, message, count)
    status.Text = message
    progress.Text = count or ""
    if fraction == fillFraction then
        return
    end
    fillFraction = fraction
    if fillTween then
        fillTween:Cancel()
        fillTween = nil
    end
    local size = UDim2.fromScale(fraction, 1)
    if motionAllowed() then
        fillTween = TweenService:Create(fill, TweenInfo.new(.18, Enum.EasingStyle.Quad), {Size = size})
        fillTween:Play()
    else
        fill.Size = size
    end
end

if splashArt then
    task.spawn(function()
        local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, {splashArt})
        if not ok then
            return
        end
        while not finished and not splashArt.IsLoaded do
            task.wait(.05)
        end
        if not finished then
            nativeHero.Visible = false
        end
    end)
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
        local succeeded = settled - failed
        local fraction = (if plaza then .16 else 0) + .64 * succeeded / math.max(requested, 1)
            + (if ready then .12 else 0)
        local message = if not plaza then "Finding Festival Plaza…"
            elseif settled < requested then "Loading plaza details…"
            elseif ready then "Entering Festival Plaza…" else "Preparing your arrival…"
        local count = if requested > 0 and settled < requested then string.format("%d / %d", succeeded, requested) else ""
        setProgress(fraction, message, count)
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
        local facing = Vector3.new(look.X, 0, look.Z).Unit
        -- The default reset aims 15 degrees down. Preserve a view the
        -- player has already tilted or turned while waiting for the splash.
        if math.abs(look.Y + math.sin(math.rad(15))) > .025
            or facing:Dot(spawn.CFrame.LookVector) < math.cos(math.rad(1)) then
            return
        end
        local right = facing:Cross(Vector3.yAxis)
        local aim = facing + right * math.tan(math.rad(1.5)) - Vector3.yAxis * math.tan(math.rad(8))
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
    setProgress(1, "Entering Festival Plaza…")
    framePlazaArrival()
else
    status.Text = "Continuing into the city…"
    progress.Text = ""
end

if motionAllowed() then
    -- A small final fade uses a solid frame, avoiding a full-screen GUI render target.
    local veil = create("Frame", splash, {
        Size = FULL, BackgroundColor3 = NIGHT, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 20,
    })
    TweenService:Create(veil, TweenInfo.new(.10, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
    task.wait(.10)
    foreground.Enabled = false
    screen.Visible = false
    TweenService:Create(veil, TweenInfo.new(.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    task.wait(.19)
end
if fillTween then
    fillTween:Cancel()
end
ContextActionService:UnbindAction(PLAYER_ACTION)
foreground:Destroy()
splash:Destroy()
print(string.format("[Beast Dojo] Splash finished (%s). %d/%d entry assets settled, %d failed, %.2fs.",
    reason, settled, requested, failed, os.clock() - started))
