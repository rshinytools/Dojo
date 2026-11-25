local Owl = require(script.Parent.ElectricOwlCombatPoses)
local Ram = require(script.Parent.BighornRamCombatPoses)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Thunder = {}

local function kitMoves(poses, damage, secondary, signature)
    local light = poses.Contact
    local technique, charged = poses.Skill[secondary], poses.Skill[signature]
    return {
        jab = {{at = light.jab, damage = damage[1], zone = "head"}},
        cross = {{at = light.cross, damage = damage[2], zone = "body"}},
        body = {{at = light.body, damage = damage[3], zone = "body"}},
        heavy = {{at = light.heavy, damage = damage[4], zone = "body"}},
        [secondary] = {{at = light[secondary], damage = technique.damage, radius = technique.radius, zone = "body"}},
        [signature] = {{at = light[signature], damage = charged.damage, shape = "radial",
            center = Vector3.zero, thunder = true, shockDuration = charged.stun, zone = "body"}},
    }
end

local owlMoves = kitMoves(Owl, {13, 14, 15, 21}, "wingSweep", "thunderDive")
local ramMoves = kitMoves(Ram, {14, 15, 16, 24}, "hornCheck", "staticCharge")
Thunder.kits = table.freeze({
    owl = {poses = Owl, clips = owlMoves, mixedSpacing = 2.48,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .76,
        secondary = "wingSweep", secondaryCooldown = 3.1, secondaryCooling = "wingCooling",
        signature = "thunderDive", signatureCooldown = 8.4, signatureCooling = "thunderCooling"},
    ram = {poses = Ram, clips = ramMoves, mixedSpacing = 2.58,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .98,
        secondary = "hornCheck", secondaryCooldown = 3.5, secondaryCooling = "hornCooling",
        signature = "staticCharge", signatureCooldown = 8.8, signatureCooling = "staticCooling"},
})

Thunder.skills = table.freeze({
    thunderDive = {name = "Thunder Dive", move = owlMoves.thunderDive[1], travel = Owl.Travel.thunderDive,
        radius = 2.6, maxRadius = 2.6, tint = Color3.fromRGB(137, 215, 255)},
    staticCharge = {name = "Static Charge", move = ramMoves.staticCharge[1], travel = Ram.Travel.staticCharge,
        radius = 1.85, maxRadius = 3.55, tint = Color3.fromRGB(255, 214, 129)},
})
Thunder.shove = table.freeze({
    wingSweep = Owl.Skill.wingSweep.shove, thunderDive = Owl.Skill.thunderDive.shove,
    hornCheck = Ram.Skill.hornCheck.shove, staticCharge = Ram.Skill.staticCharge.shove,
})

function Thunder.radius(skill, origin, landing)
    local delta = landing - origin
    local distance = Vector3.new(delta.X, 0, delta.Z).Magnitude
    return skill.radius + (skill.maxRadius - skill.radius) * math.clamp(distance / skill.travel.distance, 0, 1)
end

function Thunder.floorEnd(from, target, hasFloor)
    -- Check the path as well as its destination so a dash cannot cross a collapsed tile.
    local distance = (target - from).Magnitude
    local steps = math.ceil(distance / .24)
    local finish = from
    for index = 1, steps do
        local point = from:Lerp(target, index / steps)
        if not hasFloor(point) then
            break
        end
        finish = point
    end
    return finish
end

local function segments(parent, name, tint, opacity)
    local group = Instance.new("Folder")
    group.Name = name
    for index = 1, 12 do
        local edge = Instance.new("Part")
        edge.Name = "Charge outline"
        edge.Anchored, edge.CanCollide, edge.CanQuery, edge.CanTouch, edge.CastShadow = true, false, false, false, false
        edge.Material, edge.Color, edge.Transparency = Enum.Material.Neon, tint, opacity
        edge.Parent = group
    end
    group.Parent = parent
    return group
end

local function draw(group, center, radius, height, width)
    local outline = group:GetChildren()
    for index, edge in outline do
        local angle = (index - 1) * 2 * math.pi / #outline
        local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
        edge.Size = Vector3.new(width, .025, 1.76 * radius * math.sin(math.pi / #outline))
        edge.CFrame = CFrame.lookAlong(center + direction * radius + Vector3.yAxis * height,
            Vector3.new(-direction.Z, 0, direction.X))
    end
end

function Thunder.present(cast, parent, floor, age, point, canLand)
    local skill = Thunder.skills[cast.clip.action]
    if age < skill.move.at and canLand then
        local landing = Vector3.new(point.X, floor, point.Z)
        if not cast.warning then
            cast.warning = segments(parent, skill.name .. " warning", skill.tint, .36)
        end
        if not cast.thunderPreview or (cast.thunderPreview - landing).Magnitude > .045 then
            cast.thunderPreview = landing
            draw(cast.warning, landing, Thunder.radius(skill, cast.origin.Position, landing), .062, .095)
        end
    elseif cast.warning then
        cast.warning:Destroy()
        cast.warning, cast.thunderPreview = nil, nil
    end
end

function Thunder.burst(cast, parent, center, radius)
    if cast.thunderBurst then
        return
    end
    cast.thunderBurst = true
    local skill = Thunder.skills[cast.clip.action]
    local spark = segments(parent, skill.name .. " impact", skill.tint, .10)
    draw(spark, center, radius, .075, .17)
    local inner = segments(spark, "Inner shock", Color3.fromRGB(255, 243, 192), .22)
    draw(inner, center, radius * .64, .095, .085)
    Debris:AddItem(spark, .25)
end

function Thunder.shock(target, parent, duration)
    local glow = Instance.new("Highlight")
    glow.Name = "Thunder shock"
    glow.Adornee, glow.DepthMode = target, Enum.HighlightDepthMode.Occluded
    glow.FillColor, glow.OutlineColor = Color3.fromRGB(104, 190, 255), Color3.fromRGB(214, 243, 255)
    glow.FillTransparency, glow.OutlineTransparency = .89, .30
    glow.Parent = parent
    TweenService:Create(glow, TweenInfo.new(duration), {FillTransparency = 1, OutlineTransparency = 1}):Play()
    Debris:AddItem(glow, duration)
end

return table.freeze(Thunder)
