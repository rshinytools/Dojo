local Shark = require(script.Parent.GreatWhiteSharkCombatPoses)
local Kraken = require(script.Parent.AbyssalKrakenCombatPoses)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Abyss = {}

local function strikes(poses, damage, secondary)
    local contacts, move = poses.Contact, poses.Skill[secondary]
    return {
        jab = {{at = contacts.jab, damage = damage[1], zone = "head"}},
        cross = {{at = contacts.cross, damage = damage[2], zone = "body"}},
        body = {{at = contacts.body, damage = damage[3], zone = "body"}},
        heavy = {{at = contacts.heavy, damage = damage[4], zone = "body"}},
        [secondary] = {{at = contacts[secondary], damage = move.damage, radius = move.radius, zone = "body"}},
    }
end

local jaws = Shark.Skill.jawsOfTheDeep
local cataclysm = Kraken.Skill.tentacleCataclysm
Abyss.jaws = table.freeze({
    teleportAt = jaws.teleportAt, submergeAt = jaws.submergeAt, resurfaceAt = jaws.resurfaceAt,
    at = Shark.Contact.jawsOfTheDeep, radius = 2.45, gap = 2.05, tint = Color3.fromRGB(126, 233, 255),
    center = Vector3.new(0, 0, -.85),
})
local shark = strikes(Shark, {15, 15, 16, 24}, "reefHook")
shark.jawsOfTheDeep = {{at = Abyss.jaws.at, damage = jaws.damage, shape = "radial", center = Abyss.jaws.center,
    abyss = true, radius = Abyss.jaws.radius, zone = "body"}}

local kraken = strikes(Kraken, {14, 16, 17, 25}, "tideGrip")
local laneRadius = .83
kraken.tentacleCataclysm = {}
for index, at in Kraken.Contact.tentacleCataclysm do
    kraken.tentacleCataclysm[index] = {at = at, damage = cataclysm.damage[index], shape = "tentacle",
        radius = laneRadius, zone = "body"}
end

Abyss.kits = table.freeze({
    shark = {poses = Shark, clips = shark, mixedSpacing = 2.62,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .79,
        secondary = "reefHook", secondaryCooldown = 3.35, secondaryCooling = "reefCooling",
        signature = "jawsOfTheDeep", signatureCooldown = 9.8, signatureCooling = "jawsCooling"},
    kraken = {poses = Kraken, clips = kraken, mixedSpacing = 2.72,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = 1.03,
        secondary = "tideGrip", secondaryCooldown = 3.55, secondaryCooling = "tideCooling",
        signature = "tentacleCataclysm", signatureCooldown = 11.4, signatureCooling = "cataclysmCooling"},
})
Abyss.shove = table.freeze({reefHook = Shark.Skill.reefHook.shove, tideGrip = Kraken.Skill.tideGrip.shove,
    jawsOfTheDeep = .96})

function Abyss.submerged(side, at)
    local clip = side.clip
    if not clip or clip.action ~= "jawsOfTheDeep" then return false end
    return at >= clip.startedAt + Abyss.jaws.submergeAt and at < clip.startedAt + Abyss.jaws.resurfaceAt
end

local directions = {Vector3.new(-1, 0, 0), Vector3.new(1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1)}

function Abyss.lanes(origin, floor, clamp, obstruct)
    local focal = origin:PointToWorldSpace(Vector3.new(0, 0, -4.35))
    local center = clamp(Vector3.new(focal.X, floor, focal.Z))
    local lanes = {}
    for index, direction in directions do
        local edge = clamp(center + origin:VectorToWorldSpace(direction) * 6.20)
        lanes[index] = {start = obstruct(center, edge), finish = center}
    end
    return lanes
end

local function closestAlong(lane, point)
    local axis = lane.finish - lane.start
    local extent = axis:Dot(axis)
    if extent < .016 then return nil end
    return lane.start + axis * math.clamp((point - lane.start):Dot(axis) / extent, 0, 1)
end

function Abyss.laneContact(lane, frame, size, nearest, maxHeight, radius)
    local line = closestAlong(lane, frame.Position)
    if not line then return nil end
    local point = nearest(frame, size, line + Vector3.yAxis * .18)
    local projected = closestAlong(lane, point)
    local delta = point - projected
    if delta.Y < -.22 or delta.Y > maxHeight or Vector3.new(delta.X, 0, delta.Z).Magnitude > radius then
        return nil
    end
    return point, projected
end

local function visualPart(parent, name, size, frame, color, transparency, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Size, part.CFrame, part.Color, part.Transparency = size, frame, color, transparency
    part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch, part.CastShadow = true, false, false, false, false
    part.Material = if shape then Enum.Material.SmoothPlastic else Enum.Material.Neon
    if shape then part.Shape = shape end
    part.Parent = parent
    return part
end

function Abyss.laneWarnings(lanes, parent)
    local group = Instance.new("Folder")
    group.Name, group.Parent = "Tentacle Cataclysm warning", parent
    for index, lane in lanes do
        local direction = lane.finish - lane.start
        if direction.Magnitude > .12 then
            local aim = CFrame.lookAlong(lane.start:Lerp(lane.finish, .5) + Vector3.yAxis * .07, direction.Unit)
            visualPart(group, tostring(index), Vector3.new(laneRadius * 2, .035, direction.Magnitude), aim,
                Color3.fromRGB(149, 114, 241), .61)
        end
    end
    return group
end

local function tentacle(cast, parent, index, windup)
    local lane = cast.lanes[index]
    local direction = lane.finish - lane.start
    if direction.Magnitude < .13 then return nil end
    local group = Instance.new("Folder")
    group.Name, group.Parent = "Tentacle slam " .. index, parent
    local ball = Enum.PartType.Ball
    for step = 0, 6 do
        local ratio = step / 6
        local position = lane.start:Lerp(lane.finish, ratio)
        local height = 1.18 * (1 - ratio) ^ 2 + .17
        local width = .98 - .57 * ratio
        local orientation = CFrame.lookAlong(position + Vector3.yAxis * height, direction.Unit)
        local raised = Vector3.yAxis * (1.0 + 1.6 * ratio)
        local length = direction.Magnitude / 6 + .44
        local limb = visualPart(group, "Coiled arm", Vector3.new(width, width, length),
            if windup > 0 then orientation + raised else orientation,
            Color3.fromRGB(82 + step * 4, 43 + step * 4, 134 + step * 8), 0, ball)
        local sucker = orientation * CFrame.new(.23 * (1 - ratio), width * .33, 0)
        local cup = visualPart(group, "Coral cup", Vector3.new(width * .42, .19, width * .41),
            if windup > 0 then sucker + raised else sucker,
            Color3.fromRGB(242, 141, 154), 0, ball)
        if windup > 0 then
            local easing = TweenInfo.new(windup, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            TweenService:Create(limb, easing, {CFrame = orientation}):Play()
            TweenService:Create(cup, easing, {CFrame = sucker}):Play()
        end
    end
    return group
end

function Abyss.windupLanes(cast, age)
    cast.arms = cast.arms or {}
    for index, move in kraken.tentacleCataclysm do
        local remaining = move.at - age
        if remaining > 0 and remaining <= .16 and not cast.arms[index] then
            cast.arms[index] = tentacle(cast, cast.warning, index, remaining) or false
        end
    end
end

function Abyss.resolveLane(cast, parent, index)
    local strip = cast.warning and cast.warning:FindFirstChild(tostring(index))
    if strip then strip:Destroy() end
    local group = cast.arms and cast.arms[index] or tentacle(cast, parent, index, 0)
    if not group then return nil end
    group.Parent = parent
    for _, piece in group:GetChildren() do
        TweenService:Create(piece, TweenInfo.new(.20), {Transparency = 1, CFrame = piece.CFrame - Vector3.yAxis * .38}):Play()
    end
    Debris:AddItem(group, .21)
    return cast.lanes[index]
end

function Abyss.splash(cast, parent, center)
    if cast.splashed then return end
    cast.splashed = true
    local group = Instance.new("Folder")
    group.Name, group.Parent = "Jaws of the Deep splash", parent
    for index = 1, 8 do
        local angle = index * math.pi / 4
        local outward = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local position = center + outward * (1.26 + index % 2 * .30) + Vector3.yAxis * .43
        visualPart(group, "Foam jet", Vector3.new(.14, .93, .20),
            CFrame.lookAlong(position, (outward + Vector3.yAxis * .70).Unit), Abyss.jaws.tint, .28)
    end
    Debris:AddItem(group, .22)
end

return table.freeze(Abyss)
