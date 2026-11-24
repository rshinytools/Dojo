-- Decorative walkers use synchronized local poses. Guides stay server-owned.
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local city = workspace:WaitForChild("Grand Dojo City")
local townsfolk = city:WaitForChild("Ambient townsfolk")
local walkers = {}
local restPoses = setmetatable({}, { __mode = "k" })
local movingParts = {}
local poses = {}
local candidates = {}
local PAUSE = .62
local ACTIVE_RANGE = 92
local limitedEffects = UserInputService.TouchEnabled or UserInputService.VREnabled
local activeLimit = limitedEffects and 5 or 8
local frameInterval = limitedEffects and 1 / 24 or 1 / 36

local swingWeights = {
    ["Left Foot"] = 1, ["Right Foot"] = -1,
    ["Left Shin"] = .44, ["Right Shin"] = -.44,
    ["Left Paw"] = -.52, ["Right Paw"] = .52,
    ["Left Sleeve"] = -.19, ["Right Sleeve"] = .19,
}
local function register(model)
    local origin = model:FindFirstChild("PoseOrigin")
    local route = model:FindFirstChild("Walk route")
    if not origin or not route then
        return
    end
    local existing = restPoses[model]
    if existing and existing.anchor == origin and existing.parts[1].instance.Parent == model then
        walkers[model] = existing
        return
    end
    local parts = {}
    for _, part in model:GetChildren() do
        if part:IsA("BasePart") and part ~= origin then
            table.insert(parts, {
                instance = part,
                rest = origin.CFrame:ToObjectSpace(part.CFrame),
                swing = swingWeights[part.Name] or 0,
            })
        end
    end
    if #parts == 0 then
        return
    end
    local ordered = {}
    for _, value in route:GetChildren() do
        if value:IsA("Vector3Value") then
            table.insert(ordered, value)
        end
    end
    table.sort(ordered, function(a, b)
        return a.Name < b.Name
    end)
    if #ordered < 2 then
        return
    end
    local segments = {}
    local totalTime = 0
    local center = Vector3.zero
    local passThrough = route:FindFirstChild("Pass-through pause")
    for i, point in ordered do
        local start = point.Value
        local destination = ordered[i % #ordered + 1].Value
        local delta = destination - start
        local travelTime = delta.Magnitude / route.Pace.Value
        local heading = Vector3.new(delta.X, 0, delta.Z).Unit
        local pause = PAUSE
        if passThrough then
            local following = ordered[(i + 1) % #ordered + 1].Value - destination
            local nextHeading = Vector3.new(following.X, 0, following.Z).Unit
            if heading:Dot(nextHeading) > .88 then
                pause = passThrough.Value
            end
        end
        totalTime += travelTime + pause
        center += start
        table.insert(segments, {
            start = start,
            destination = destination,
            heading = heading,
            travelTime = travelTime,
            pause = pause,
            steps = math.max(1, math.round(delta.Magnitude / 2.07)),
        })
    end
    local walker = {
        anchor = origin,
        parts = parts,
        segments = segments,
        period = totalTime,
        phase = route.Phase.Value,
        center = center / #ordered,
    }
    restPoses[model] = walker
    walkers[model] = walker
end

townsfolk.ChildAdded:Connect(register)
townsfolk.ChildRemoved:Connect(function(model)
    walkers[model] = nil
end)
for _, model in townsfolk:GetChildren() do
    register(model)
end

local function addPose(walker, now)
    local elapsed = (now + walker.phase) % walker.period
    for i, segment in walker.segments do
        local span = segment.travelTime + segment.pause
        if elapsed >= span then
            elapsed -= span
            continue
        end

        local amount = math.min(elapsed / segment.travelTime, 1)
        local position = segment.start:Lerp(segment.destination, amount)
        local heading = CFrame.lookAt(position, position + segment.heading)
        if elapsed > segment.travelTime then
            local nextSegment = walker.segments[i % #walker.segments + 1]
            local turn = (elapsed - segment.travelTime) / segment.pause
            heading = heading:Lerp(CFrame.lookAt(position, position + nextSegment.heading), turn)
        end

        local cycle = math.pi * 2 * segment.steps * amount
        local movement = math.min(amount * 9, (1 - amount) * 9, 1)
        local reduced = GuiService.ReducedMotionEnabled or UserInputService.VREnabled
        local stride = if reduced then 0 else math.sin(cycle) * movement
        local lift = if reduced then 0 else math.abs(math.cos(cycle)) * movement * .073 + math.sin(now * 2.31) * .014
        for _, detail in walker.parts do
            local swing = stride * detail.swing
            table.insert(movingParts, detail.instance)
            table.insert(poses, heading * CFrame.new(0, lift + math.max(swing, 0) * .12, swing * .26)
                * detail.rest * CFrame.Angles(swing * .24, 0, 0))
        end
        return
    end
end

local clock = 0
RunService.Heartbeat:Connect(function(dt)
    clock += dt
    local camera = workspace.CurrentCamera
    if clock < frameInterval or not camera then
        return
    end
    clock %= frameInterval
    table.clear(candidates)
    local viewpoint = camera.CFrame.Position
    for _, walker in walkers do
        local offset = walker.center - viewpoint
        local distance = offset.Magnitude
        if distance <= ACTIVE_RANGE then
            walker.distance = distance
            table.insert(candidates, walker)
        end
    end
    table.sort(candidates, function(a, b)
        return a.distance < b.distance
    end)

    table.clear(movingParts)
    table.clear(poses)
    local now = workspace:GetServerTimeNow()
    for i = 1, math.min(activeLimit, #candidates) do
        addPose(candidates[i], now)
    end
    if #movingParts > 0 then
        workspace:BulkMoveTo(movingParts, poses, Enum.BulkMoveMode.FireCFrameChanged)
    end
end)
