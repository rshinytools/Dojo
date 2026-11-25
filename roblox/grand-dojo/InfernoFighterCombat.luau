local Grizzly = require(script.Parent.MagmaGrizzlyBearCombatPoses)
local Hellhound = require(script.Parent.ObsidianHellhoundCombatPoses)
local Match = require(script.Parent.DojoMatchSupport)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Inferno = {}
local eruption = "eruptionSlam"
local stampede = "hellfireStampede"
local pillarDistances = {1.45, 3.10, 4.75, 6.40}
local pillarRadius, echoRadius = 1.42, .96
local travelSeconds, travelSteps = .56, 12
local breaks = Hellhound.Contact.hellfireStampede
local ember = Color3.fromRGB(255, 153, 66)
local coal = Color3.fromRGB(111, 49, 66)
local flame = Color3.fromRGB(255, 188, 103)

local function strikes(poses, damage, techniques)
    local at = poses.Contact
    local moves = {
        jab = {{at = at.jab, damage = damage[1], zone = "head"}},
        cross = {{at = at.cross, damage = damage[2], zone = "body"}},
        body = {{at = at.body, damage = damage[3], zone = "body"}},
        heavy = {{at = at.heavy, damage = damage[4], zone = "body"}},
    }
    for _, id in techniques do
        local move = poses.Skill[id]
        moves[id] = {{at = at[id], damage = move.damage, radius = move.radius, zone = "body"}}
    end
    return moves
end

local grizzly = strikes(Grizzly, {14, 16, 18, 26}, {"basaltBackhand", "pumiceKnuckle", "forgeShoulder"})
grizzly[eruption] = {}
for index, at in Grizzly.Contact.eruptionSlam do
    grizzly[eruption][index] = {at = at, damage = Grizzly.Skill[eruption].damage[index], shape = "eruption",
        radius = pillarRadius, zone = "body", maxContacts = 2, silentMiss = true, detached = true}
end

local hellhound = strikes(Hellhound, {15, 15, 17, 24}, {"cinderLunge", "emberKnuckle", "blackglassSweep"})
local echoes = {}
for echo, release in breaks do
    for step = 1, travelSteps do
        table.insert(echoes, {at = release + travelSeconds * step / travelSteps,
            shape = "echo", radius = echoRadius, zone = "body", damage = Hellhound.Skill[stampede].damage[echo],
            contactGroup = echo, maxContacts = 1, silentMiss = true, detached = true,
            from = (step - 1) / travelSteps, to = step / travelSteps})
    end
end
table.sort(echoes, function(a, b)
    return if a.at == b.at then a.contactGroup < b.contactGroup else a.at < b.at
end)
hellhound[stampede] = echoes

Inferno.kits = table.freeze({
    grizzly = {poses = Grizzly, clips = grizzly, mixedSpacing = 2.71,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = 1.01,
        secondaryCooldown = 3.65, secondaryCooling = "basaltCooling",
        signature = eruption, signatureCooldown = 10.2, signatureCooling = "eruptionCooling"},
    hellhound = {poses = Hellhound, clips = hellhound, mixedSpacing = 2.57,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .78,
        secondaryCooldown = 3.35, secondaryCooling = "lungeCooling",
        signature = stampede, signatureCooldown = 10.9, signatureCooling = "stampedeCooling"},
})
Inferno.shove = table.freeze({
    basaltBackhand = Grizzly.Skill.basaltBackhand.shove,
    cinderLunge = Hellhound.Skill.cinderLunge.shove,
})

function Inferno.isCast(action)
    return action == eruption or action == stampede
end

function Inferno.plan(action, arena, origin, clip)
    local floor, bounds = arena.floor, arena.bounds
    local function clamp(position)
        return Match.clampFloor(bounds, position, floor)
    end
    if action == eruption then
        local start = clamp(origin.Position)
        local forward = origin.LookVector
        local pillars = {}
        for index, distance in pillarDistances do
            local center = start + forward * distance
            if (clamp(center) - center).Magnitude > .025 or (clip(start, center, 1.68) - center).Magnitude > .025 then
                break
            end
            pillars[index] = center
        end
        return {pillars = pillars}
    end

    local aim = clamp(origin.Position + origin.LookVector * 3.75)
    local field = bounds.CFrame
    local localAim = field:PointToObjectSpace(aim)
    local half = bounds.Size.X / 2 - 1.05
    local depth = bounds.Size.Z / 2 - 1.05
    local laneCenter = math.clamp(localAim.Z, -depth + .58, depth - .58)
    local lanes = {}
    for index = 1, #breaks do
        local direction = if index == 1 then 1 else -1
        local z = laneCenter + direction * .58
        local middle = clamp(field:PointToWorldSpace(Vector3.new(localAim.X, 0, z)))
        local start = clamp(field:PointToWorldSpace(Vector3.new(-direction * half, 0, z)))
        local finish = clamp(field:PointToWorldSpace(Vector3.new(direction * half, 0, z)))
        start = clip(middle, start, echoRadius * 2)
        finish = clip(middle, finish, echoRadius * 2)
        if (finish - start).Magnitude > .24 then
            lanes[index] = {start = start, finish = finish}
        end
    end
    return {lanes = lanes, models = {}}
end

local function part(parent, name, size, frame, tint, opacity, shape, neon)
    local piece = Instance.new("Part")
    piece.Name, piece.Size, piece.CFrame = name, size, frame
    piece.Color, piece.Transparency = tint, 1 - opacity
    piece.Anchored, piece.CanCollide, piece.CanTouch, piece.CanQuery, piece.CastShadow = true, false, false, false, false
    piece.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
    piece.Shape = shape or Enum.PartType.Block
    piece.Parent = parent
    return piece
end

local function disk(parent, name, center, diameter, opacity)
    local level = CFrame.new(center) * CFrame.Angles(0, 0, math.pi * .5)
    return part(parent, name, Vector3.new(.033, diameter, diameter), level, ember, opacity, Enum.PartType.Cylinder, true)
end

function Inferno.showWarnings(cast, parent)
    local group = Instance.new("Folder")
    group.Name = if cast.pillars then "Eruption Slam warning" else "Hellfire Stampede warning"
    group.Parent = parent
    cast.warning = group
    for index, center in cast.pillars or {} do
        local y = center + Vector3.yAxis * .062
        disk(group, tostring(index), y, pillarRadius * 2, .27)
        disk(group, tostring(index) .. " core", y + Vector3.yAxis * .025, .58, .62)
    end
    for index, lane in cast.lanes or {} do
        local delta = lane.finish - lane.start
        local from = lane.start:Lerp(lane.finish, .5) + Vector3.yAxis * .063
        local frame = CFrame.lookAlong(from, delta.Unit)
        part(group, tostring(index), Vector3.new(echoRadius * 2, .039, delta.Magnitude), frame, ember, .22, nil, true)
        for side = -1, 1, 2 do
            part(group, "Lane edge", Vector3.new(.064, .045, delta.Magnitude),
                frame * CFrame.new(side * echoRadius, 0, 0), ember, .56, nil, true)
        end
    end
    return group
end

local function removeWarning(cast, name)
    local piece = cast.warning and cast.warning:FindFirstChild(name)
    if piece then piece:Destroy() end
end

local function pillar(cast, parent, index, center)
    removeWarning(cast, tostring(index))
    removeWarning(cast, tostring(index) .. " core")
    local group = Instance.new("Folder")
    group.Name, group.Parent = "Eruption Pillar " .. index, parent
    local ground = CFrame.new(center)
    local function flare(name, size, offset, tint, shape, neon)
        local peak = ground * offset
        local piece = part(group, name, size, peak - Vector3.yAxis * .57, tint, 1, shape, neon)
        TweenService:Create(piece, TweenInfo.new(.09, Enum.EasingStyle.Quart), {CFrame = peak}):Play()
        TweenService:Create(piece, TweenInfo.new(.17, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, .10),
            {Transparency = 1}):Play()
    end
    flare("Molten core", Vector3.new(.76, 2.34, .78), CFrame.new(0, 1.05, 0), flame, Enum.PartType.Ball, true)
    for side = -1, 1, 2 do
        flare("Lifted basalt", Vector3.new(.55, 1.5, .62),
            CFrame.new(.64 * side, .59, .27 * side) * CFrame.Angles(.23 * side, .45 * side, -.33 * side), coal)
        flare("Fire lick", Vector3.new(.32, 1.5, .32),
            CFrame.new(.38 * side, .66, -.29 * side) * CFrame.Angles(-.31 * side, 0, -.39 * side),
            ember, Enum.PartType.Ball, true)
    end
    disk(group, "Dust ring", center + Vector3.yAxis * .052, 2.5, .28)
    Debris:AddItem(group, .28)
end

local function hound(group, index)
    local model = Instance.new("Model")
    model.Name = "Spectral Hound " .. index
    local paws = {}
    local ball = Enum.PartType.Ball
    part(model, "Spine", Vector3.new(.86, .79, 1.63), CFrame.new(0, .94, .13), coal, .84, ball)
    part(model, "Flame shoulder", Vector3.new(.58, .69, .69), CFrame.new(0, 1.19, -.45), ember, .86, ball, true)
    part(model, "Head", Vector3.new(.65, .64, .78), CFrame.new(0, 1.36, -.76), coal, .94, ball)
    part(model, "Muzzle", Vector3.new(.49, .35, .66), CFrame.new(0, 1.19, -1.10), ember, .94, ball, true)
    part(model, "Tail", Vector3.new(.23, .29, .85), CFrame.new(0, 1.02, 1.06) * CFrame.Angles(.30, 0, 0),
        ember, .83, ball, true)
    for side = -1, 1, 2 do
        part(model, "Ear", Vector3.new(.23, .60, .24),
            CFrame.new(.22 * side, 1.73, -.55) * CFrame.Angles(.21, 0, -.24 * side), coal, .91, ball)
        part(model, "Eye", Vector3.new(.12, .115, .14), CFrame.new(.232 * side, 1.43, -1.01), flame, 1, ball, true)
        for front = -1, 1, 2 do
            local foot = part(model, "Running paw", Vector3.new(.21, .75, .29),
                CFrame.new(.33 * side, .47, .56 * front), ember, .82, ball, true)
            table.insert(paws, {part = foot, offset = foot.CFrame, side = side * front})
        end
    end
    model.WorldPivot = CFrame.identity
    model.Parent = group
    return {model = model, paws = paws}
end

function Inferno.presentEchoes(cast, age)
    for index, lane in cast.lanes or {} do
        local elapsed = age - breaks[index]
        if elapsed >= travelSeconds then
            local echo = cast.models[index]
            if echo then
                if echo.model.Parent then echo.model:Destroy() end
                cast.models[index] = nil
            end
        elseif elapsed >= 0 and cast.warning then
            local echo = cast.models[index]
            if not echo then
                echo = hound(cast.warning, index)
                cast.models[index] = echo
            end
            local cycle = elapsed * math.pi * 16
            local position = lane.start:Lerp(lane.finish, elapsed / travelSeconds)
            local direction = (lane.finish - lane.start).Unit
            local frame = CFrame.lookAlong(position + Vector3.yAxis * (.06 + .07 * math.abs(math.sin(cycle))), direction)
            echo.model:PivotTo(frame)
            for _, paw in echo.paws do
                paw.part.CFrame = frame * paw.offset * CFrame.Angles(paw.side * math.sin(cycle) * .62, 0, 0)
            end
        end
    end
end

function Inferno.impact(cast, move, index, parent, hasFloor)
    if move.shape == "eruption" then
        local center = cast.pillars[index]
        if center and hasFloor and not hasFloor(center) then
            removeWarning(cast, tostring(index))
            removeWarning(cast, tostring(index) .. " core")
            return nil
        end
        if center then pillar(cast, parent, index, center) end
        return center
    end
    local lane = cast.lanes[move.contactGroup]
    return lane and {start = lane.start:Lerp(lane.finish, move.from), finish = lane.start:Lerp(lane.finish, move.to)}
end

return table.freeze(Inferno)
