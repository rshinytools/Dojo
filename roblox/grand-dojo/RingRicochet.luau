-- A cast has one bounded path in ring-local space. The renderer and hit
-- sweeps sample the same timed legs, including the split at a reflection.
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Ricochet = {}
local clearance = 1.31
local epsilon = .0001
local gold = Color3.fromRGB(245, 193, 118)

local function flat(vector)
    return Vector3.new(vector.X, 0, vector.Z)
end

local function wallTime(value, velocity, edge)
    if math.abs(velocity) < epsilon then
        return math.huge
    end
    return math.max(0, ((if velocity > 0 then edge else -edge) - value) / velocity)
end

function Ricochet.plan(bounds, start, heading, skill, obstacle)
    local basis = bounds.CFrame
    local xLimit = math.max(.1, bounds.Size.X * .5 - clearance)
    local zLimit = math.max(.1, bounds.Size.Z * .5 - clearance)
    local localStart = basis:PointToObjectSpace(start)
    local position = Vector3.new(math.clamp(localStart.X, -xLimit, xLimit), localStart.Y,
        math.clamp(localStart.Z, -zLimit, zLimit))
    local origin = basis:PointToWorldSpace(position)
    local localHeading = flat(basis:VectorToObjectSpace(heading))
    local direction = if localHeading.Magnitude < epsilon then Vector3.new(0, 0, -1) else localHeading.Unit
    local legs, bounces = {}, {}
    local time, stopAt = 0, nil
    for _ = 1, 22 do
        if time >= skill.rollSeconds - epsilon then
            break
        end
        local velocity = direction * skill.speed
        local xTime, zTime = wallTime(position.X, velocity.X, xLimit), wallTime(position.Z, velocity.Z, zLimit)
        local duration = math.min(skill.rollSeconds - time, xTime, zTime)
        local horizontal = basis:VectorToWorldSpace(direction)
        local worldStart = basis:PointToWorldSpace(position)
        local normal
        if obstacle and duration > epsilon then
            local travel = horizontal * (duration * skill.speed)
            local hit = obstacle(worldStart, travel)
            if hit and flat(hit.Normal).Magnitude > .55 then
                normal = flat(basis:VectorToObjectSpace(hit.Normal)).Unit
                duration = math.min(duration, math.max(0, hit.Distance - .045) / skill.speed)
            end
        end
        local nextPosition = position + velocity * duration
        local worldEnd = basis:PointToWorldSpace(nextPosition)
        if duration > epsilon then
            table.insert(legs, {first = time, last = time + duration, a = worldStart, b = worldEnd, heading = horizontal})
        end
        time += duration
        position = nextPosition
        if time >= skill.rollSeconds - epsilon then
            break
        end
        if skill.reflect == false then
            stopAt = time
            break
        end
        if normal then
            direction -= normal * (2 * direction:Dot(normal))
            position += normal * .018
        else
            direction = Vector3.new(if math.abs(xTime - duration) < epsilon then -direction.X else direction.X, 0,
                if math.abs(zTime - duration) < epsilon then -direction.Z else direction.Z)
        end
        table.insert(bounces, {time = time, point = worldEnd, heading = basis:VectorToWorldSpace(direction)})
    end
    local tail = legs[#legs]
    if not tail or time < skill.rollSeconds - epsilon then
        local ending = basis:PointToWorldSpace(position)
        table.insert(legs, {first = time, last = skill.rollSeconds, a = ending, b = ending,
            heading = if tail then tail.heading else basis:VectorToWorldSpace(direction)})
    end
    return {legs = legs, bounces = bounces, origin = origin, skill = skill, stopAt = stopAt}
end

local function positionAt(leg, time)
    return leg.a:Lerp(leg.b, math.clamp((time - leg.first) / (leg.last - leg.first), 0, 1))
end

function Ricochet.frameAt(path, time)
    local last = path.legs[#path.legs]
    for _, leg in path.legs do
        if time < leg.last then
            return CFrame.lookAlong(positionAt(leg, time), leg.heading)
        end
    end
    return CFrame.lookAlong(last.b, last.heading)
end

local function pitchAt(time, skill)
    return -math.clamp(time, 0, skill.rollSeconds) * skill.speed / (skill.wheelRadius or 1.31)
end

local function wheelHeight(pitch, skill)
    local supports = skill.supportHeights
    local phase = pitch / (2 * math.pi) * #supports
    local index = math.floor(phase)
    local a, b = supports[index % #supports + 1], supports[(index + 1) % #supports + 1]
    return a + (b - a) * (phase - index) + .025
end

local function wheelAt(leg, time, skill)
    return positionAt(leg, time) + Vector3.new(0, wheelHeight(pitchAt(time, skill), skill) - (skill.rootHeight or 2.60), 0)
end

function Ricochet.sweeps(path, first, last)
    local segments = {}
    if path.stopAt then
        last = math.min(last, path.stopAt)
        if first >= last then
            return segments
        end
    end
    for _, leg in path.legs do
        if leg.last >= first and leg.first <= last then
            table.insert(segments, {a = wheelAt(leg, math.max(first, leg.first), path.skill),
                b = wheelAt(leg, math.min(last, leg.last), path.skill)})
        end
    end
    return segments
end

function Ricochet.sampleAge(path, age, skill)
    if path and path.stopAt and age >= skill.windup + path.stopAt then
        return age + skill.rollSeconds - path.stopAt
    end
    return age
end

function Ricochet.pose(offsets, age, skill, shellPivot, path)
    if age < skill.windup then
        return offsets
    end
    local elapsed = age - skill.windup
    local active = if path and path.stopAt then path.stopAt else skill.rollSeconds
    local pitch = pitchAt(math.min(elapsed, active), skill)
    local center = offsets.RootJoint:PointToWorldSpace(shellPivot)
    local roll = CFrame.new(0, wheelHeight(pitch, skill) - (skill.rootHeight or 2.60), 0) * CFrame.Angles(pitch, 0, 0)
        * CFrame.new(-center) * offsets.RootJoint
    local fade = math.clamp((elapsed - active) / .30, 0, 1)
    if fade >= 1 then
        return offsets
    end
    local result = table.clone(offsets)
    local frame = roll:Lerp(offsets.RootJoint, fade)
    if skill.groundRecovery and fade > 0 then
        local bank = frame.UpVector
        local height = wheelHeight(math.atan2(bank.Z, bank.Y), skill) - (skill.rootHeight or 2.60)
        frame += Vector3.new(0, height - frame:PointToWorldSpace(shellPivot).Y, 0)
    end
    result.RootJoint = frame
    return result
end

local function mark(parent, label, frame, size)
    local part = Instance.new("Part")
    part.Name = label
    part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch, part.CastShadow = true, false, false, false, false
    part.Material, part.Color, part.Transparency = Enum.Material.Neon, gold, .24
    part.CFrame, part.Size = frame, size
    part.Parent = parent
    return part
end

function Ricochet.present(cast, parent, floor, age, skill)
    local path = cast.rollPath
    if age >= .14 and age < skill.windup then
        if not cast.warning then
            local start = path.origin
            local distance = math.min(4.3, (path.stopAt or path.legs[1].last) * skill.speed)
            local heading = path.legs[1].heading
            local point = Vector3.new(start.X, floor + .1, start.Z) + heading * (distance / 2)
            cast.warning = mark(parent, skill.guideName or "Fortress Ricochet guide", CFrame.lookAlong(point, heading),
                Vector3.new(.23, .045, math.max(.13, distance)))
        end
        return
    end
    if cast.warning then
        cast.warning:Destroy()
        cast.warning = nil
    end
    local active = path.stopAt or skill.rollSeconds
    if skill.reflect == false and age >= skill.windup and age < skill.windup + active
        and age >= (cast.emberAt or 0) then
        cast.emberAt = age + .11
        local frame = Ricochet.frameAt(path, age - skill.windup)
        local point = Vector3.new(frame.X, floor + .09, frame.Z)
        local spark = mark(parent, "Meteor Roll ember", CFrame.lookAlong(point, frame.LookVector), Vector3.new(.46, .08, .90))
        spark.Color = Color3.fromRGB(255, 141, 69)
        TweenService:Create(spark, TweenInfo.new(.24, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        Debris:AddItem(spark, .26)
    end
    local index = cast.nextBounce or 1
    local bounced = false
    local bounce = path.bounces[index]
    while bounce and age >= skill.windup + bounce.time do
        bounced = true
        local point = Vector3.new(bounce.point.X, floor + .14, bounce.point.Z)
        for side = -1, 1, 2 do
            local frame = CFrame.lookAlong(point, bounce.heading) * CFrame.Angles(0, side * .53, 0) * CFrame.new(0, 0, -.44)
            local spark = mark(parent, "Ricochet bounce", frame, Vector3.new(.14, .065, .82))
            TweenService:Create(spark, TweenInfo.new(.23, Enum.EasingStyle.Quad), {
                Transparency = 1, Size = Vector3.new(.05, .07, 1.29),
            }):Play()
            Debris:AddItem(spark, .27)
        end
        index += 1
        bounce = path.bounces[index]
    end
    cast.nextBounce = index
    return bounced
end

return table.freeze(Ricochet)
