-- World-space fields use a fixed cast origin. The surface used to draw them
-- is also used for contact, even if the fighter is moved during the animation.
local Fields = {}
local ember = Color3.fromRGB(255, 153, 86)
local water = Color3.fromRGB(126, 226, 255)
local waveSegments = 18

local function floorPoint(point, floor)
    return Vector3.new(point.X, floor, point.Z)
end

function Fields.triangle(bounds, floor, origin, vertices)
    local localPoints = {}
    local loX, loZ, hiX, hiZ = math.huge, math.huge, -math.huge, -math.huge
    for index, offset in vertices do
        local point = bounds.CFrame:PointToObjectSpace(origin:PointToWorldSpace(offset))
        localPoints[index] = point
        loX, loZ, hiX, hiZ = math.min(loX, point.X), math.min(loZ, point.Z), math.max(hiX, point.X), math.max(hiZ, point.Z)
    end
    local halfX, halfZ = bounds.Size.X / 2 - .15, bounds.Size.Z / 2 - .15
    local scale = math.min(1, 2 * halfX / (hiX - loX), 2 * halfZ / (hiZ - loZ))
    local shiftX = math.clamp(0, -halfX - loX * scale, math.max(-halfX - loX * scale, halfX - hiX * scale))
    local shiftZ = math.clamp(0, -halfZ - loZ * scale, math.max(-halfZ - loZ * scale, halfZ - hiZ * scale))
    local sum = Vector3.zero
    for index, point in localPoints do
        localPoints[index] = floorPoint(bounds.CFrame:PointToWorldSpace(point * scale + Vector3.new(shiftX, 0, shiftZ)), floor)
        sum += localPoints[index]
    end
    return {vertices = localPoints, center = sum / #localPoints}
end

function Fields.wave(bounds, floor, origin)
    local center = floorPoint(origin.Position, floor)
    local localCenter = bounds.CFrame:PointToObjectSpace(center)
    local x, z = bounds.Size.X / 2 + math.abs(localCenter.X), bounds.Size.Z / 2 + math.abs(localCenter.Z)
    return {center = center, radius = math.sqrt(x * x + z * z) + .2, bounds = bounds}
end

local function cross(a, b, point)
    return (b.X - a.X) * (point.Z - a.Z) - (b.Z - a.Z) * (point.X - a.X)
end

function Fields.contains(field, move, point)
    if move.shape == "snare" then
        local a, b, c = table.unpack(field.vertices)
        local first, second, third = cross(a, b, point), cross(b, c, point), cross(c, a, point)
        return (first >= -.01 and second >= -.01 and third >= -.01)
            or (first <= .01 and second <= .01 and third <= .01)
    end
    local dx, dz = point.X - field.center.X, point.Z - field.center.Z
    local distance = math.sqrt(dx * dx + dz * dz)
    return distance >= move.from * field.radius - .25 and distance <= move.to * field.radius + .25
end

function Fields.footContact(field, move, volumes, obstructed)
    for _, volume in volumes do
        if not volume.grounded then
            continue
        end
        local frame, size = volume.frame, volume.size
        local extent = (math.abs(frame.RightVector.Y) * size.X + math.abs(frame.UpVector.Y) * size.Y
            + math.abs(frame.LookVector.Y) * size.Z) * .5
        local foot = frame.Position
        if foot.Y - extent <= field.center.Y + .70 and Fields.contains(field, move, foot)
            and not obstructed(field.center, floorPoint(foot, field.center.Y + .22)) then
            return floorPoint(foot, field.center.Y)
        end
    end
    return nil
end

local function mark(parent, name, tint)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = true, false, false, false, false
    part.Material, part.Color, part.Transparency = Enum.Material.Neon, tint, 1
    part.Size = Vector3.new(.15, .040, .15)
    part.Parent = parent
    return part
end

local function line(part, a, b, alpha)
    local delta = b - a
    if delta.Magnitude < .022 then
        part.Transparency = 1
        return
    end
    part.CFrame = CFrame.lookAlong((a + b) / 2 + Vector3.new(0, .08, 0), delta.Unit)
    part.Size, part.Transparency = Vector3.new(.115, .038, delta.Magnitude + .025), alpha
end

function Fields.showTriangle(parent, field)
    local model = Instance.new("Folder")
    model.Name = "Cinder Snare warning"
    for index, point in field.vertices do
        local core = mark(model, "Ember node", ember)
        core.Shape = Enum.PartType.Ball
        core.Size = Vector3.new(.49, .27, .49)
        core.Position, core.Transparency = point + Vector3.new(0, .16, 0), .1
        local edge = mark(model, "Snare boundary", ember)
        line(edge, point, field.vertices[index % 3 + 1], .26)
    end
    model.Parent = parent
    return model
end

local function clipDimension(a, b, halfExtent, low, high)
    local delta = b - a
    if math.abs(delta) <= .0001 then
        return low, high, math.abs(a) <= halfExtent
    end
    local first, last = (-halfExtent - a) / delta, (halfExtent - a) / delta
    local bottom, top = math.max(low, math.min(first, last)), math.min(high, math.max(first, last))
    return bottom, top, bottom <= top
end

local function clippedLine(part, bounds, a, b, alpha)
    local p, q = bounds.CFrame:PointToObjectSpace(a), bounds.CFrame:PointToObjectSpace(b)
    local first, last, inside = clipDimension(p.X, q.X, bounds.Size.X / 2 - .07, 0, 1)
    if inside then
        first, last, inside = clipDimension(p.Z, q.Z, bounds.Size.Z / 2 - .07, first, last)
    end
    if inside then
        line(part, a:Lerp(b, first), a:Lerp(b, last), alpha)
    else
        part.Transparency = 1
    end
end

local points = {}
for index = 0, waveSegments do
    local angle = index * math.pi * 2 / waveSegments
    points[index + 1] = Vector3.new(math.cos(angle), 0, math.sin(angle))
end

local function showWave(parent, name)
    local model = Instance.new("Folder")
    model.Name = name
    local parts = {}
    for index = 1, waveSegments do
        parts[index] = mark(model, "Water crest", water)
    end
    model.Parent = parent
    return model, parts
end

local function updateWave(field, parts, radius, alpha)
    for index, part in parts do
        clippedLine(part, field.bounds, field.center + points[index] * radius,
            field.center + points[index + 1] * radius, alpha)
    end
end

function Fields.clearVisuals(cast)
    if cast.warning then
        cast.warning:Destroy()
        cast.warning = nil
    end
    if cast.waveVisual then
        cast.waveVisual:Destroy()
        cast.waveVisual, cast.waveParts = nil, nil
    end
end

function Fields.updateCast(parent, cast, age, now, combat, supported)
    local field = cast.field
    if cast.clip.action == "cinderSnare" then
        local showing = supported and age >= combat.snare.warningAt and age < combat.snareAt + .10
        if showing and not cast.warning then
            cast.warning = Fields.showTriangle(parent, field)
        elseif not showing then
            Fields.clearVisuals(cast)
        end
        return
    end
    local ratio = (age - combat.waveAt) / combat.cannon.flight
    if age < combat.cannon.warningAt or ratio > 1 then
        Fields.clearVisuals(cast)
        return
    end
    local name = if ratio < 0 then "Cavitation Cannon charge" else "Cavitation Cannon wave"
    if cast.waveVisual and cast.waveVisual.Name ~= name then
        Fields.clearVisuals(cast)
    end
    if not cast.waveVisual then
        cast.waveVisual, cast.waveParts = showWave(parent, name)
        cast.waveUpdate = now
    end
    if now >= cast.waveUpdate then
        cast.waveUpdate = now + 1 / 24
        local radius = if ratio < 0 then 1.34 + .16 * math.sin(age * 26) else math.max(.4, ratio * field.radius)
        updateWave(field, cast.waveParts, radius, if ratio < 0 then .38 else .18 + ratio * .30)
    end
end

return table.freeze(Fields)
