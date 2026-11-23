local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local INTERVAL = 30 * 60
local LAUNCH_TIME = .83
local SHOW_LENGTH = 30
local VIEW_RADIUS = 300
local STAR_TEXTURE = "rbxassetid://5860841663"
local PREVIEW_CLOCK = "FestivalFireworksPreviewStart"
local ribbonGold = Color3.fromRGB(255, 205, 121)
local softGold = Color3.fromRGB(255, 239, 186)
local palettes = {
    gold = {Color3.fromRGB(255, 196, 78), Color3.fromRGB(255, 127, 51)},
    rose = {Color3.fromRGB(255, 118, 191), Color3.fromRGB(177, 111, 255)},
    jade = {Color3.fromRGB(106, 244, 180), Color3.fromRGB(77, 184, 255)},
}

local function cue(at, x, y, z, pattern, palette)
    return {at = at, position = Vector3.new(x, y, z), pattern = pattern, colors = palettes[palette]}
end

local cues = {
    cue(1.1, -32, 83, -91, "crown", "gold"),
    cue(3.7, 18, 95, -108, "ring", "rose"),
    cue(6.3, -59, 87, -117, "willow", "jade"),
    cue(8.9, 49, 87, -110, "ring", "jade"),
    cue(10.0, 4, 104, -113, "crown", "gold"),
    cue(12.6, -49, 104, -125, "ring", "rose"),
    cue(13.5, 47, 97, -130, "crown", "gold"),
    cue(16.3, -15, 94, -100, "willow", "rose"),
    cue(18.4, 38, 106, -113, "ring", "jade"),
    cue(20.6, -67, 89, -115, "crown", "gold"),
    cue(21.3, 61, 90, -119, "crown", "rose"),
    cue(22.4, -27, 107, -123, "ring", "jade"),
    cue(23.1, 28, 108, -126, "ring", "rose"),
    cue(24.8, 0, 113, -128, "willow", "gold"),
}

local effects = Instance.new("Folder")
effects.Name = "Local Festival Fireworks"
effects.Parent = workspace

local sparkSize = NumberSequence.new({
    NumberSequenceKeypoint.new(0, .79), NumberSequenceKeypoint.new(.20, .68),
    NumberSequenceKeypoint.new(.74, .39), NumberSequenceKeypoint.new(1, .09),
})
local sparkFade = NumberSequence.new({
    NumberSequenceKeypoint.new(0, .13), NumberSequenceKeypoint.new(.42, .23),
    NumberSequenceKeypoint.new(.78, .55), NumberSequenceKeypoint.new(1, 1),
})
local function lightAnchor(name, position)
    local part = Instance.new("Part")
    part.Name = name
    part.Position = position
    part.Size = Vector3.new(.27, .27, .27)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Transparency = 1
    part.Parent = effects
    return part
end

local function sparkEmitter(colors, speed, life, spread, falloff)
    local spark = Instance.new("ParticleEmitter")
    spark.Texture = STAR_TEXTURE
    spark.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors[1]:Lerp(softGold, .32)),
        ColorSequenceKeypoint.new(.24, colors[1]),
        ColorSequenceKeypoint.new(1, colors[2]),
    })
    spark.Size = sparkSize
    spark.Transparency = sparkFade
    spark.Enabled = false
    spark.SpreadAngle = Vector2.new(spread, spread)
    spark.EmissionDirection = Enum.NormalId.Front
    spark.Speed = speed
    spark.Lifetime = life
    spark.Drag = .54
    spark.Acceleration = Vector3.new(0, -falloff, 0)
    spark.LightEmission = .82
    spark.LightInfluence = 0
    return spark
end

local function emitAfterMount(emitter, count)
    task.delay(.06, function()
        if emitter.Parent then
            emitter:Emit(count)
        end
    end)
end

local function softBurst(anchor, colors)
    anchor.Shape = Enum.PartType.Ball
    anchor.Material = Enum.Material.Neon
    anchor.Color = colors[1]
    anchor.Size = Vector3.one * 1.75
    TweenService:Create(anchor, TweenInfo.new(.5), {Transparency = .58, Size = Vector3.one * 3}):Play()
    task.delay(.55, function()
        TweenService:Create(anchor, TweenInfo.new(1.1), {Transparency = 1, Size = Vector3.one * 4.5}):Play()
    end)
end

local function trailFor(part, width, lifetime, color, tailColor)
    local left = Instance.new("Attachment", part)
    local right = Instance.new("Attachment", part)
    left.Position = Vector3.new(-width / 2, 0, 0)
    right.Position = Vector3.new(width / 2, 0, 0)
    local trail = Instance.new("Trail")
    trail.Attachment0 = left
    trail.Attachment1 = right
    trail.FaceCamera = true
    trail.Lifetime = lifetime
    trail.Color = ColorSequence.new(color, tailColor)
    trail.LightEmission = .32
    trail.LightInfluence = 0
    trail.Transparency = NumberSequence.new(.12, 1)
    trail.WidthScale = NumberSequence.new(1, .07)
    trail.Parent = part
    return trail
end

local function trailBurst(anchor, shot, compact)
    local ring = shot.pattern == "ring"
    local willow = shot.pattern == "willow"
    local count = if compact then 12 elseif ring then 22 else 26
    local duration = if willow then 2.55 else 1.7
    local gravity = if willow then 17 else 8
    local sparks = table.create(count)
    for index = 0, count - 1 do
        local angle = if ring then index * 2 * math.pi / count else index * 2.399963
        local dx, dy = math.cos(angle), math.sin(angle)
        local slope = 1 - 2 * (index + .5) / count
        local radius = math.sqrt(1 - slope * slope)
        local direction = if ring then Vector3.new(dx, dy, .29 * dx - .15 * dy)
            else Vector3.new(radius * dx, slope, radius * dy)
        local color = shot.colors[1 + index % 2]
        local spark = Instance.new("Part")
        spark.Name = "Firework spark"
        spark.CFrame = anchor.CFrame
        spark.Size = Vector3.one * (if compact then .59 else .7)
        spark.Shape = Enum.PartType.Ball
        spark.Material = Enum.Material.Neon
        spark.Color = color
        spark.Anchored = true
        spark.CanCollide = false
        spark.CanTouch = false
        spark.CanQuery = false
        spark.CastShadow = false
        spark.Parent = anchor
        local trail = trailFor(spark, if compact then .7 else .92, if willow then .64 else .35,
            color, shot.colors[2])
        local speed = if ring then 33 else 22 + (index % 5) * 2.7
        sparks[index + 1] = {part = spark, trail = trail, velocity = direction * speed}
    end

    local elapsed = 0
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed >= duration or not anchor.Parent then
            connection:Disconnect()
            for _, spark in sparks do
                spark.trail.Enabled = false
                spark.part.Transparency = 1
            end
            return
        end
        local distance = elapsed / (1 + .42 * elapsed)
        local drop = Vector3.new(0, -.5 * gravity * elapsed * elapsed, 0)
        for _, spark in sparks do
            spark.part.Position = anchor.Position + spark.velocity * distance + drop
            spark.part.Transparency = math.clamp((elapsed / duration - .42) * 1.72, 0, 1)
        end
    end)
end

local function openBurst(shot, quiet, compact)
    local anchor = lightAnchor("Festival " .. shot.pattern, shot.position)
    Debris:AddItem(anchor, 3.9)
    if quiet then
        softBurst(anchor, shot.colors)
        return
    end
    trailBurst(anchor, shot, compact)
    local seeds = sparkEmitter({softGold, shot.colors[1]}, NumberRange.new(8, 26),
        NumberRange.new(.9, 1.85), 360, 10)
    seeds.Parent = anchor
    emitAfterMount(seeds, if compact then 16 else 34)
end

local function launchTrail(shot, remaining)
    local launch = Vector3.new(shot.position.X * .82, 29, shot.position.Z + 3)
    local now = launch:Lerp(shot.position, 1 - math.clamp(remaining / LAUNCH_TIME, 0, 1))
    local rocket = lightAnchor("Festival launch", now)
    rocket.Shape = Enum.PartType.Ball
    rocket.Material = Enum.Material.Neon
    rocket.Color = ribbonGold:Lerp(shot.colors[1], .38)
    rocket.Transparency = .14
    local tail = trailFor(rocket, .82, .33, shot.colors[1], ribbonGold)
    TweenService:Create(rocket, TweenInfo.new(remaining, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = shot.position}):Play()
    task.delay(remaining, function()
        rocket.Transparency = 1
        tail.Enabled = false
    end)
    Debris:AddItem(rocket, remaining + .42)
end

local function playCue(shot, elapsed)
    local camera = workspace.CurrentCamera
    if not camera or (camera.CFrame.Position - shot.position).Magnitude > VIEW_RADIUS then
        return
    end

    local quiet = GuiService.ReducedMotionEnabled or VRService.VREnabled
    local quality = UserSettings():GetService("UserGameSettings").SavedQualityLevel.Value
    local compact = UserInputService.TouchEnabled or (quality > 0 and quality <= 4)
    local remaining = shot.at - elapsed
    if remaining > .095 and not quiet then
        launchTrail(shot, remaining)
    end
    task.delay(math.max(0, remaining), function()
        openBurst(shot, quiet or GuiService.ReducedMotionEnabled or VRService.VREnabled, compact)
    end)
end

local function showStart(now)
    if RunService:IsStudio() then
        local previewStart = workspace:GetAttribute(PREVIEW_CLOCK)
        if type(previewStart) == "number" then
            return previewStart
        end
    end
    return math.floor(now / INTERVAL) * INTERVAL
end

local currentStart
local nextCue = 1
while true do
    local now = workspace:GetServerTimeNow()
    local start = showStart(now)
    if start ~= currentStart then
        currentStart = start
        nextCue = 1
    end
    local elapsed = now - start
    if elapsed >= 0 and elapsed < SHOW_LENGTH then
        while cues[nextCue] and cues[nextCue].at - LAUNCH_TIME <= elapsed do
            local shot = cues[nextCue]
            if elapsed <= shot.at + .22 then
                playCue(shot, elapsed)
            end
            nextCue += 1
        end
        task.wait(.06)
    else
        task.wait(.35)
    end
end
