-- Fit resident steps to a floor-relative travel path without moving the bot root.
local Footwork = {}

local rightLeg, leftLeg = "Right Leg", "Left Leg"
local sideOf = {strafeLeft = -1, strafeRight = 1, retreat = 0}

local function travelFrame(distance, side, radius)
    if side == 0 then
        return CFrame.new(0, 0, distance), 0
    end
    local yaw = side * distance / radius
    local position = CFrame.new(radius * math.sin(yaw), 0, radius * (math.cos(yaw) - 1))
    return position * CFrame.Angles(0, yaw, 0), yaw
end

local function footOffset(base, destination, yaw, boot, progress, lift, toeTurn)
    local weight = progress * progress * (3 - 2 * progress)
    local arc = 16 * progress ^ 2 * (1 - progress) ^ 2
    local center = boot.center:Lerp(destination:PointToWorldSpace(boot.center), weight)
    local foot = CFrame.new(center + Vector3.new(0, lift * arc, 0))
        * CFrame.Angles(0, yaw * weight + toeTurn * arc, 0)
    -- Mesh groups apply offsets after their ArtPivot. Solve the sole in that frame.
    return CFrame.new(-boot.pivot) * base:ToObjectSpace(foot) * CFrame.new(boot.pivot - boot.center)
end

function Footwork.add(poses, config, bodyPose)
    local durations = table.clone(poses.Duration)
    local distances, shapes, destinations, endYaws = {}, {}, {}, {}
    for action, side in sideOf do
        local shape = if side == 0 then config.retreat else config.side
        shapes[action] = shape
        durations[action], distances[action] = shape.duration, shape.distance
        destinations[action], endYaws[action] = travelFrame(shape.distance, side, config.orbitRadius)
    end
    poses.Duration = table.freeze(durations)
    poses.StepDistance = table.freeze(distances)

    local originalSample = poses.sample
    function poses.sample(action, age, duration)
        local shape = shapes[action]
        if not shape then
            return originalSample(action, age, duration)
        end
        local playback = math.max(duration or shape.duration, .001)
        local phase = (math.max(age, 0) % playback) / playback
        if phase == 0 then
            return originalSample("idle", 0)
        end

        local side = sideOf[action]
        local base = travelFrame(phase * shape.distance, side, config.orbitRadius)
        local lead = if side > 0 then rightLeg else leftLeg
        local leadPhase = math.min(phase / shape.transfer, 1)
        local trailPhase = math.max((phase - shape.transfer) / (1 - shape.transfer), 0)
        local guarded = math.sin(math.pi * phase) ^ 2
        local pose = bodyPose(side, -math.cos(math.pi * phase) * guarded, guarded)
        for name, boot in config.boots do
            local leads = name == lead
            local progress = if leads then leadPhase else trailPhase
            local lift = if leads then shape.leadLift else shape.trailLift
            local toeTurn = math.rad(shape.toeTurn) * (if name == rightLeg then -1 else 1)
            pose.groups[name] = footOffset(base, destinations[action], endYaws[action], boot, progress, lift, toeTurn)
        end
        return pose
    end
end

return table.freeze(Footwork)
