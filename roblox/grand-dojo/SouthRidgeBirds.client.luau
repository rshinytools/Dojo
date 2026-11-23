-- Local wildlife. Only the flock nearest the camera is animated.
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local VR_RANGE = 155
local EXIT_MARGIN = 15
local SWITCH_MARGIN = 12
local ORBIT_RATE = math.pi * 2
local PROBE_INTERVAL = .25

local ridgePalette = {
    {
        name = "Jade Ridge Bird", size = 1.02, phase = .38, radius = 18, height = -1.6, period = 16.4,
        body = Color3.fromRGB(62, 155, 142), belly = Color3.fromRGB(175, 212, 161),
        head = Color3.fromRGB(81, 175, 152), tip = Color3.fromRGB(41, 86, 121),
        beak = Color3.fromRGB(232, 174, 93),
    },
    {
        name = "Coral Ridge Bird", size = .94, phase = 1.66, radius = 15.5, height = .4, period = 18.8,
        body = Color3.fromRGB(187, 87, 103), belly = Color3.fromRGB(242, 177, 152),
        head = Color3.fromRGB(211, 111, 116), tip = Color3.fromRGB(132, 66, 109),
        beak = Color3.fromRGB(230, 188, 126),
    },
    {
        name = "Gold Ridge Bird", size = .98, phase = 2.8, radius = 19.2, height = 1.4, period = 17.2,
        body = Color3.fromRGB(206, 154, 63), belly = Color3.fromRGB(239, 211, 147),
        head = Color3.fromRGB(228, 178, 84), tip = Color3.fromRGB(144, 82, 55),
        beak = Color3.fromRGB(173, 100, 75),
    },
}

local canalPalette = {
    {
        name = "Turquoise Canal Bird", size = .86, phase = .62, radius = 1, height = .35, period = 8.4,
        body = Color3.fromRGB(34, 170, 178), belly = Color3.fromRGB(248, 154, 89),
        head = Color3.fromRGB(49, 191, 179), tip = Color3.fromRGB(51, 82, 149),
        beak = Color3.fromRGB(94, 60, 64),
    },
    {
        name = "Tangerine Canal Bird", size = .79, phase = 3.69, radius = .85, height = -.42, period = 9.6,
        body = Color3.fromRGB(217, 101, 73), belly = Color3.fromRGB(248, 206, 144),
        head = Color3.fromRGB(243, 131, 82), tip = Color3.fromRGB(161, 58, 89),
        beak = Color3.fromRGB(104, 67, 81),
    },
}

local cloudPalette = {
    {
        name = "Indigo Cliff Bird", size = 1.17, phase = .53, radius = 1, height = .56, period = 13.8,
        body = Color3.fromRGB(92, 99, 184), belly = Color3.fromRGB(208, 201, 239),
        head = Color3.fromRGB(118, 105, 189), tip = Color3.fromRGB(55, 68, 131),
        beak = Color3.fromRGB(239, 179, 108),
    },
    {
        name = "Rose Cliff Bird", size = 1.10, phase = 2.85, radius = .87, height = -.1, period = 14.6,
        body = Color3.fromRGB(197, 89, 137), belly = Color3.fromRGB(244, 191, 185),
        head = Color3.fromRGB(214, 115, 148), tip = Color3.fromRGB(113, 66, 143),
        beak = Color3.fromRGB(237, 185, 103),
    },
    {
        name = "Saffron Cliff Bird", size = 1.05, phase = 5.02, radius = .93, height = -.56, period = 13.2,
        body = Color3.fromRGB(221, 164, 63), belly = Color3.fromRGB(249, 223, 158),
        head = Color3.fromRGB(239, 185, 80), tip = Color3.fromRGB(157, 95, 84),
        beak = Color3.fromRGB(172, 100, 74),
    },
}

local flocks = {
    {name = "South Ridge Birds", center = Vector3.new(1, 29, 171), axes = Vector3.new(1, .98, .88),
        range = 178, palette = ridgePalette},
    {name = "Festival Canal Birds", center = Vector3.new(-18, 9.1, 22.5), axes = Vector3.new(3.3, .58, 5.8),
        range = 95, palette = canalPalette},
    {name = "Cloudbreak Cliff Birds", center = Vector3.new(88, 40, -244), axes = Vector3.new(10, 1.0, 5),
        range = 114, palette = cloudPalette},
}

local function addPart(bird, name, className, size, tint, offset, angle, side)
    local part = Instance.new(className)
    part.Name = name
    part.Size = size * bird.settings.size
    part.Color = tint
    part.Material = Enum.Material.SmoothPlastic
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    if className == "Part" then
        part.Shape = Enum.PartType.Ball
    end
    part.Parent = bird.model
    table.insert(bird.parts, part)
    table.insert(bird.layout, {
        frame = CFrame.new(offset * bird.settings.size) * CFrame.Angles(0, angle, 0),
        side = side,
    })
end

local function makeBird(flock, settings)
    local model = Instance.new("Model")
    model.Name = settings.name
    model.Parent = flock.model
    local bird = {model = model, layout = {}, parts = flock.parts, settings = settings}
    addPart(bird, "Body", "Part", Vector3.new(.59, .54, 1.20), settings.body,
        Vector3.zero, 0)
    addPart(bird, "Breast", "Part", Vector3.new(.48, .30, .79), settings.belly,
        Vector3.new(0, -.16, -.16), 0)
    addPart(bird, "Head", "Part", Vector3.new(.43, .45, .48), settings.head,
        Vector3.new(0, .22, -.45), 0)
    addPart(bird, "Beak", "WedgePart", Vector3.new(.20, .15, .37), settings.beak,
        Vector3.new(0, .17, -.76), 0)

    for _, side in {-1, 1} do
        local wingName = if side < 0 then "Left" else "Right"
        addPart(bird, wingName .. " wing", "WedgePart", Vector3.new(1.18, .25, .58), settings.body,
            Vector3.new(side * .62, .045, -.06), side * -.19, side)
        addPart(bird, wingName .. " flight feathers", "WedgePart", Vector3.new(.43, .16, .85), settings.tip,
            Vector3.new(side * 1.10, .045, .08), side * 1.81, side)
        addPart(bird, wingName .. " tail feather", "WedgePart", Vector3.new(.24, .10, .70), settings.tip,
            Vector3.new(side * .13, -.04, .73), math.pi + side * -.23)
    end
    table.insert(flock.birds, bird)
end

local function buildFlock(flock)
    flock.model = Instance.new("Model")
    flock.model.Name = flock.name
    flock.birds = {}
    flock.parts = {}
    flock.poses = {}
    for _, settings in flock.palette do
        makeBird(flock, settings)
    end
end

local function flightPoint(flock, settings, angle)
    return flock.center + Vector3.new(
        settings.radius * flock.axes.X * math.cos(angle),
        settings.height + flock.axes.Y * math.sin(angle * 2 + settings.phase),
        settings.radius * flock.axes.Z * math.sin(angle)
    )
end

local function poseFlock(flock, time, reduceMotion)
    table.clear(flock.poses)
    for _, bird in flock.birds do
        local settings = bird.settings
        local angle = time * ORBIT_RATE / settings.period + settings.phase
        local point = flightPoint(flock, settings, angle)
        local facing = CFrame.lookAt(point, flightPoint(flock, settings, angle + .045))
        local bank = if reduceMotion then -.11 else -.20 - .09 * math.sin(angle * 2)
        local wingbeat = math.sin(time * ORBIT_RATE * 2.65 + settings.phase * 3)
        local effort = .23 + .64 * (.5 + .5 * math.sin(angle * 2 - 1.2)) ^ 2
        local flap = if reduceMotion then .09 else .08 + wingbeat * effort
        local root = facing * CFrame.Angles(0, 0, bank)
        local leftWing = root * CFrame.Angles(0, 0, -flap)
        local rightWing = root * CFrame.Angles(0, 0, flap)
        for _, part in bird.layout do
            local frame = if part.side == -1 then leftWing elseif part.side == 1 then rightWing else root
            table.insert(flock.poses, frame * part.frame)
        end
    end
end

local active
local poseElapsed = 0
local probe = PROBE_INTERVAL
local started = os.clock()

local function nearestFlock(camera, vr)
    if not camera then
        return nil
    end

    local position = camera.CFrame.Position
    local nearest
    local nearestDistance = math.huge
    for _, flock in flocks do
        local distance = (position - flock.center).Magnitude
        local range = if vr then math.min(VR_RANGE, flock.range) else flock.range
        local priority = distance
        if flock == active then
            range += EXIT_MARGIN
            priority -= SWITCH_MARGIN
        end
        if distance <= range and priority < nearestDistance then
            nearest = flock
            nearestDistance = priority
        end
    end
    return nearest
end

RunService.Heartbeat:Connect(function(deltaTime)
    probe += deltaTime
    if probe >= PROBE_INTERVAL then
        probe = 0
        local nearest = nearestFlock(workspace.CurrentCamera, UserInputService.VREnabled)
        if active ~= nearest then
            if active then
                active.model.Parent = nil
            end
            active = nearest
            if active and not active.model then
                buildFlock(active)
            end
        end
    end
    if not active then
        return
    end

    poseElapsed += deltaTime
    local interval = if UserInputService.TouchEnabled or UserInputService.VREnabled then 1 / 15 else 1 / 20
    if poseElapsed < interval then
        return
    end
    poseElapsed %= interval
    poseFlock(active, os.clock() - started, GuiService.ReducedMotionEnabled or UserInputService.VREnabled)
    if not active.model.Parent then
        active.model.Parent = workspace
    end
    workspace:BulkMoveTo(active.parts, active.poses, Enum.BulkMoveMode.FireCFrameChanged)
end)
