local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local INTERVAL = 30 * 60
local LAUNCH_TIME = .83
local VIEW_RADIUS = 430
local COMPACT_RADIUS = 255
local STAR_TEXTURE = "rbxassetid://5860841663"
local PREVIEW_CLOCK = "FestivalFireworksPreviewStart"
local ribbonGold = Color3.fromRGB(255, 205, 121)
local softGold = Color3.fromRGB(255, 239, 186)
local palettes = {
    gold = {Color3.fromRGB(255, 196, 78), Color3.fromRGB(255, 127, 51)},
    rose = {Color3.fromRGB(255, 118, 191), Color3.fromRGB(177, 111, 255)},
    jade = {Color3.fromRGB(106, 244, 180), Color3.fromRGB(77, 184, 255)},
    blue = {Color3.fromRGB(133, 209, 255), Color3.fromRGB(121, 112, 255)},
    ember = {Color3.fromRGB(255, 134, 86), Color3.fromRGB(239, 64, 118)},
    pearl = {Color3.fromRGB(255, 243, 205), Color3.fromRGB(245, 177, 98)},
}

local cues = {}
local function cue(at, x, y, pattern, palette, scale)
    table.insert(cues, {
        at = at, position = Vector3.new(x, y + 21, -112 - math.abs(x) * .16),
        pattern = pattern, colors = palettes[palette], scale = scale * 1.24,
    })
end

-- Opening fans over the roofs and three high bursts over the hall.
for index = 0, 4 do
    local x = 29 + index * 13
    local height = 68 + index * 3
    cue(1.35 + index * .26, -x, height, "palm", "gold", .74)
    cue(1.35 + index * .26, x, height, "palm", "pearl", .74)
end
cue(3.7, 0, 113, "crown", "gold", 1.30)
cue(4.55, -52, 107, "ring", "rose", 1.08)
cue(4.55, 52, 107, "ring", "jade", 1.08)

-- Color sweeps alternate across the skyline before the willow interlude.
local colors = {"rose", "blue", "jade", "ember", "gold"}
for index, palette in colors do
    local x = (index - 3) * 34
    cue(7.2 + (index - 1) * .66, x, 111 + 3 * index, "crown", palette, 1.08)
    cue(7.75 + (index - 1) * .66, -x, 86 + 3 * index, "ring", palette, .80)
    cue(12.1 + (index - 1) * .62, -x, 104 + 2 * index, "peony", palette, 1.12)
    cue(15.7 + (index - 1) * .62, x, 116 + index, "palm", palette, 1.05)
end
cue(19.5, -72, 112, "willow", "pearl", 1.25)
cue(20.2, 72, 116, "willow", "gold", 1.25)
cue(21.1, 0, 129, "willow", "gold", 1.45)
cue(24.1, -44, 103, "ring", "blue", 1.14)
cue(24.5, 44, 108, "ring", "rose", 1.14)
cue(25.4, 0, 128, "peony", "jade", 1.34)

-- The finale rises from the outside in, then ends in a gold canopy.
for index = 0, 6 do
    local x = 96 - index * 12
    local at = 27.5 + index * .53
    local palette = colors[index % #colors + 1]
    cue(at, -x, 86 + index * 6, "crown", palette, .95)
    cue(at, x, 86 + index * 6, "peony", palette, .95)
    cue(at + .23, (index - 3) * 25, 75 + index * 4, "palm", "gold", .74)
end
cue(31.85, 0, 143, "ring", "pearl", 1.60)
cue(32.55, -57, 130, "willow", "gold", 1.34)
cue(32.98, 57, 130, "willow", "gold", 1.34)
cue(33.65, 0, 147, "willow", "pearl", 1.66)
table.sort(cues, function(left, right) return left.at < right.at end)
local SHOW_LENGTH = cues[#cues].at + 4

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

local activeSparks = 0
local patterns = {
    ring = {duration = 1.85, gravity = 6, speed = 36, trail = .39},
    crown = {duration = 1.95, gravity = 8, speed = 34, trail = .43},
    peony = {duration = 2.12, gravity = 7, speed = 28, trail = .32},
    palm = {duration = 2.32, gravity = 15, speed = 31, trail = .62},
    willow = {duration = 3.10, gravity = 14, speed = 27, trail = .83},
}
local function sparkDirection(pattern, index, count)
    local petal = index % 2
    local angle = index * 2 * math.pi / count
    if pattern == "ring" then
        local x, y = math.cos(angle), math.sin(angle)
        return Vector3.new(x, y, .29 * x - .15 * y), if petal == 0 then 1 else .79
    end
    if pattern == "palm" then
        return Vector3.new(.66 * math.cos(angle), .62 + .32 * (index % 3), .51 * math.sin(angle)), 1
    end
    local spiral = index * 2.399963
    local height = 1 - 2 * (index + .5) / count
    local radius = math.sqrt(1 - height * height)
    local speed = if pattern == "peony" and petal == 1 then .62 else 1 + (index % 5) * .075
    return Vector3.new(radius * math.cos(spiral), height, radius * math.sin(spiral)), speed
end

local function trailBurst(anchor, shot, compact)
    local budget = if compact then 72 else 160
    local count = math.min(if compact then 12 else 25, budget - activeSparks)
    if count < 6 then return end
    activeSparks += count
    local pattern = patterns[shot.pattern]
    local sparks = table.create(count)
    for index = 0, count - 1 do
        local direction, speed = sparkDirection(shot.pattern, index, count)
        local color = shot.colors[1 + index % 2]
        local spark = lightAnchor("Firework spark", anchor.Position)
        spark.Parent = anchor
        spark.Size = Vector3.one * (if compact then .75 else .94)
        spark.Shape = Enum.PartType.Ball
        spark.Material = Enum.Material.Neon
        spark.Color = color
        spark.Transparency = 0
        local trail = trailFor(spark, if compact then .96 else 1.20, pattern.trail, color:Lerp(softGold, .24), shot.colors[2])
        sparks[index + 1] = {part = spark, trail = trail, velocity = direction * pattern.speed * shot.scale * speed}
    end

    local elapsed = 0
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed >= pattern.duration or not anchor.Parent then
            connection:Disconnect()
            activeSparks -= count
            for _, spark in sparks do
                spark.trail.Enabled = false
                spark.part.Transparency = 1
            end
            return
        end
        local distance = elapsed / (1 + .34 * elapsed)
        local drop = Vector3.new(0, -.5 * pattern.gravity * elapsed * elapsed, 0)
        for _, spark in sparks do
            spark.part.Position = anchor.Position + spark.velocity * distance + drop
            spark.part.Transparency = math.clamp((elapsed / pattern.duration - .40) / .60, 0, 1)
        end
    end)
end

local function openBurst(shot, quiet, compact)
    local anchor = lightAnchor("Festival " .. shot.pattern, shot.position)
    Debris:AddItem(anchor, 4.1)
    if quiet then
        softBurst(anchor, shot.colors)
        return
    end
    trailBurst(anchor, shot, compact)
    local seeds = sparkEmitter({shot.colors[1], shot.colors[2]}, NumberRange.new(9, 24 * shot.scale),
        NumberRange.new(.95, 1.9), 360, 9)
    seeds.Parent = anchor
    emitAfterMount(seeds, if compact then 16 else 36)
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

local function isQuiet()
    return GuiService.ReducedMotionEnabled or VRService.VREnabled
end

local function playCue(shot, elapsed, start)
    local camera = workspace.CurrentCamera
    local distance = if camera then (camera.CFrame.Position - shot.position).Magnitude else math.huge
    if distance > VIEW_RADIUS then
        return
    end

    local quiet = isQuiet()
    local quality = UserSettings():GetService("UserGameSettings").SavedQualityLevel.Value
    local compact = UserInputService.TouchEnabled or distance > COMPACT_RADIUS or (quality > 0 and quality <= 4)
    local remaining = shot.at - elapsed
    if remaining > .095 and not quiet then
        launchTrail(shot, remaining)
    end
    task.delay(math.max(0, remaining), function()
        local now = workspace:GetServerTimeNow()
        local view = workspace.CurrentCamera
        if now - start <= shot.at + .32 and view
            and (view.CFrame.Position - shot.position).Magnitude <= VIEW_RADIUS then
            openBurst(shot, quiet or isQuiet(), compact)
        end
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
                playCue(shot, elapsed, start)
            end
            nextCue += 1
        end
        task.wait(.06)
    else
        task.wait(.35)
    end
end
