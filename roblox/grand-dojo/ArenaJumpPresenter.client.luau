-- Align the fitted shell's jump to the root this client actually sees. The
-- arena's motors and hit volumes continue to use the original authored clips.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Jump = require(ReplicatedStorage:WaitForChild("ArenaJumpMotion"))

local tracked = {}
local studio = RunService:IsStudio()
local groups = {"Left Leg", "Right Leg", "Left Arm", "Right Arm", "Tail"}

local function clearPose(character, state)
    if state.phase then
        for _, part in state.bindings do
            if part.weld.Parent then part.weld.C0 = part.rest end
        end
        if studio then character:SetAttribute("ArenaJumpPhase", nil) end
        state.phase = nil
    end
end

local function reset(character, state)
    clearPose(character, state)
    table.clear(state.sample)
    table.clear(state.ready)
    state.supportAt = nil
end

local function add(character)
    if not tracked[character] then
        tracked[character] = {bindings = {}, sample = {}, ready = {}}
    end
end

CollectionService:GetInstanceAddedSignal(Jump.tag):Connect(add)
CollectionService:GetInstanceRemovedSignal(Jump.tag):Connect(function(character)
    local state = tracked[character]
    if state then
        reset(character, state)
        tracked[character] = nil
    end
end)
for _, character in CollectionService:GetTagged(Jump.tag) do
    add(character)
end

local function fit(shell, bindings)
    table.clear(bindings)
    for _, name in groups do
        local mesh = shell:FindFirstChild(name)
        local weld = mesh and mesh:FindFirstChildOfClass("Weld")
        local pivot = mesh and mesh:FindFirstChild("ArtPivot")
        if weld and weld.Part0 and pivot and pivot:IsA("Attachment") then
            bindings[name] = {weld = weld, pivot = pivot.CFrame, rest = weld.C0, back = weld.C1:Inverse()}
        elseif name ~= "Tail" or mesh then
            return nil
        end
    end
    local left, right = shell:FindFirstChild("Left Leg"), shell:FindFirstChild("Right Leg")
    local leftPivot = left and left:FindFirstChild("ArtPivot")
    local rightPivot = right and right:FindFirstChild("ArtPivot")
    local width = if leftPivot and rightPivot then (rightPivot.WorldPosition - leftPivot.WorldPosition).Magnitude else .94
    return math.clamp(1.05 - (width - .94) * .35, .58, 1.12)
end

local function naturalFrame(part)
    return part.weld.Part0.CFrame * part.rest * part.back
end

local function deckAt(point, ray, floor)
    local hit = workspace:Raycast(point, -Vector3.yAxis * 2.56, ray)
    return hit ~= nil and math.abs(hit.Position.Y - floor) < .17 and hit.Normal.Y > .80
end

local function supportAt(character, state, root, floor, height, now)
    if height < -.64 or height > .21 then return false end
    if not state.ray then
        state.ray = RaycastParams.new()
        state.ray.FilterDescendantsInstances = {character}
        state.ray.RespectCanCollide = true
    end
    if state.sample.launchedAt or not state.supportAt or now - state.supportAt > .07
        or (root.Position - state.supportPosition).Magnitude > .20 then
        local position = root.Position
        -- Check within the fighter's footprint when a tile seam splits the center ray.
        state.support = deckAt(position, state.ray, floor)
            or deckAt(position + Vector3.new(.23, 0, .17), state.ray, floor)
            or deckAt(position - Vector3.new(.23, 0, .17), state.ray, floor)
        state.supportAt, state.supportPosition = now, root.Position
    end
    return state.support
end

local function present(character, state, now)
    local root = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("Torso")
    local shell = character:FindFirstChild("Starter Fighter Shell")
    local floor = character:GetAttribute("ArenaJumpFloor")
    if not root or not torso or not shell or not floor or root.Anchored
        or not character:GetAttribute("ArenaJumpEnabled") then
        reset(character, state)
        return
    end
    local tail = shell:FindFirstChild("Tail")
    if shell ~= state.shell or tail ~= state.tail or not state.legScale then
        reset(character, state)
        state.shell, state.tail, state.legScale = shell, tail, fit(shell, state.bindings)
        if not state.legScale then return end
    end
    for _, part in state.bindings do
        if not part.weld.Part0 or not part.weld.Parent then
            state.legScale = nil
            reset(character, state)
            return
        end
    end

    local height = root.Position.Y - floor - Jump.standingHeight
    local support = supportAt(character, state, root, floor, height, now)
    local phase = Jump.track(state.sample, now, height, root.AssemblyLinearVelocity.Y, support)
    if not phase then
        clearPose(character, state)
        if support then
            for name, part in state.bindings do
                state.ready[name] = torso.CFrame:ToObjectSpace(naturalFrame(part))
            end
        end
        return
    end

    local turns, flightWeight = Jump.pose(state.sample, phase, now, state.legScale)
    for name, part in state.bindings do
        local rotation = turns[name]
        if rotation then
            local carrier = part.weld.Part0.CFrame
            local current = naturalFrame(part)
            -- Reuse the takeoff silhouette through the apex, then blend back to
            -- the current footwork. The two boots are free as soon as they land.
            local ready = state.ready[name]
            local basis = if ready and flightWeight > 0 then current:Lerp(torso.CFrame * ready, flightWeight) else current
            local visible = basis * part.pivot * rotation * part.pivot:Inverse()
            part.weld.C0 = carrier:ToObjectSpace(visible) * part.weld.C1
        elseif state.phase ~= phase then
            part.weld.C0 = part.rest
        end
    end
    if studio and state.phase ~= phase then character:SetAttribute("ArenaJumpPhase", phase) end
    state.phase = phase
end

RunService.PreSimulation:Connect(function()
    local now = workspace:GetServerTimeNow()
    for character, state in tracked do
        present(character, state, now)
    end
end)
