-- Server-posed Phoenix rig and reusable floor tells. Damage stays in the raid round.
local Visuals = {}

local AMBER = Color3.fromRGB(255, 189, 93)
local HONEY = Color3.fromRGB(255, 218, 142)
local SCARLET = Color3.fromRGB(255, 121, 102)
local CREAM = Color3.fromRGB(255, 240, 178)
local JADE = Color3.fromRGB(163, 241, 205)
local WARM = Color3.fromRGB(205, 124, 86)
local RIM_DARK = Color3.fromRGB(184, 123, 85)
local IRIS_REST = Color3.fromRGB(169, 87, 100)
local ASH = Color3.fromRGB(99, 79, 95)
local UP = Vector3.yAxis
local TICK = 1 / 18
local HOVER = 6.52
local CIRCLE = 18

local function unit(value)
    return math.clamp(value, 0, 1)
end

local function ease(value)
    local x = unit(value)
    return x * x * (3 - 2 * x)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function blendAngle(a, b, t)
    local difference = math.atan2(math.sin(b - a), math.cos(b - a))
    return a + difference * t
end

local function pool(folder, label, count)
    local parts = {}
    for index = 1, count do
        local part = Instance.new("Part")
        part.Name, part.Material = label, Enum.Material.Neon
        part.Size, part.Transparency = Vector3.new(.2, .04, .2), 1
        part.Anchored, part.CastShadow = true, false
        part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
        part.Parent = folder
        parts[index] = part
    end
    return parts
end

local function hide(parts)
    for _, part in parts do
        part.Transparency = 1
    end
end

local function paint(part, frame, size, color, transparency)
    part.CFrame, part.Size, part.Color, part.Transparency = frame, size, color, transparency
end

local function poseNode(parent, name)
    local model = parent:WaitForChild(name)
    return {model = model, rest = parent:GetPivot():ToObjectSpace(model:GetPivot())}
end

function Visuals.new(court)
    local boss = court:WaitForChild("Solar Phoenix")
    local body = boss:WaitForChild("Animated Body")
    local folder = court:WaitForChild("Raid Tells")
    folder:ClearAllChildren()
    local state = {
        origin = boss:WaitForChild("Origin").Position,
        body = body, bodyRest = body:GetPivot(),
        crest = poseNode(body, "Crown Fan"), tail = poseNode(body, "Tail Fan"),
        heart = body:WaitForChild("Sunheart"), heartRim = body:WaitForChild("Sunheart Rim"),
        spark = body:WaitForChild("Sunheart Spark"),
        wings = {}, talons = {}, plates = {}, irises = {}, spots = {},
        lane = pool(folder, "Sun Dive warning bars", 7),
        wake = pool(folder, "Sun Dive ember wake", 5),
        landing = pool(folder, "Landing feathers", 8),
        nextFrame = 0,
    }
    for index, side in {"Left", "Right"} do
        local wing = poseNode(body, side .. " Wing")
        wing.tip = poseNode(wing.model, "Outer Wing")
        state.wings[index] = wing
        state.talons[index] = poseNode(body, side .. " Talon")
        state.plates[index] = poseNode(body, side .. " Heart Plate")
        state.irises[index] = body:WaitForChild(side .. " iris")
    end
    for index = 1, 3 do
        local fills = pool(folder, "Solar Flare circle", 1)
        fills[1].Shape = Enum.PartType.Cylinder
        state.spots[index] = {fill = fills, rim = pool(folder, "Solar Flare warning rim", CIRCLE),
            rays = pool(folder, "Solar Flare impact sparks", 4)}
    end
    return state
end

local function clearTell(state)
    if state.activeTell == "solarFlare" then
        for _, spot in state.spots do
            hide(spot.fill)
            hide(spot.rim)
            hide(spot.rays)
        end
    elseif state.activeTell == "sunDive" then
        hide(state.lane)
        hide(state.wake)
    elseif state.activeTell == "dawnLanding" then
        hide(state.landing)
    end
    state.activeTell = nil
end

local function rigPose(state, frame, flap, flex, fold, flight, tilt, tail, open, dim, heat)
    state.body:PivotTo(frame)
    state.crest.model:PivotTo(frame * state.crest.rest * CFrame.Angles(-.11 * tilt, 0, 0))
    state.tail.model:PivotTo(frame * state.tail.rest * CFrame.Angles(.16 * flap + .30 * fold, tail, 0))
    for index, wing in state.wings do
        local side = if index == 1 then -1 else 1
        local wingFrame = frame * wing.rest * CFrame.Angles(.06 * tilt, side * .81 * fold,
            side * (flap + .09 * fold))
        wing.model:PivotTo(wingFrame)
        wing.tip.model:PivotTo(wingFrame * wing.tip.rest
            * CFrame.Angles(0, side * .67 * fold, side * (flex + .11 * fold)))
        local talon = state.talons[index]
        talon.model:PivotTo(frame * talon.rest * CFrame.Angles(-.47 * flight, 0, 0))
        local plate = state.plates[index]
        plate.model:PivotTo(frame * plate.rest * CFrame.new(side * .86 * open, .17 * open, 0)
            * CFrame.Angles(0, side * .73 * open, side * .15 * open))
        state.irises[index].Color = IRIS_REST:Lerp(SCARLET, heat):Lerp(ASH, dim)
    end
    state.heart.Color = WARM:Lerp(HONEY, open):Lerp(ASH, dim)
    state.heartRim.Color = RIM_DARK:Lerp(AMBER, open):Lerp(ASH, dim)
    state.spark.Color = WARM:Lerp(CREAM, open):Lerp(ASH, dim)
end

function Visuals.reset(state)
    clearTell(state)
    -- Restore the authored ground transform so another mount reads the same rest rig.
    rigPose(state, state.bodyRest, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    state.nextFrame, state.defeatedAt, state.takeoffAt, state.wasAirborne = 0, nil, nil, true
    state.settled = false
end

local function floorRing(parts, center, radius, color, alpha)
    local step = 2 * math.pi / #parts
    local halfStep = step * .5
    local edge = radius * math.cos(halfStep)
    local width = 2 * radius * math.sin(halfStep)
    for index, rim in parts do
        local theta = (index - .50) * step
        local point = center + Vector3.new(math.sin(theta) * edge, 0, math.cos(theta) * edge)
        paint(rim, CFrame.new(point) * CFrame.Angles(0, theta, 0),
            Vector3.new(width + .025, .031, .15), color, alpha)
    end
end

local function flareTells(state, attack, now, tint)
    for index, impact in attack.steps do
        local spot, age = state.spots[index], now - impact.at
        local fadeAt = .43
        if age > fadeAt then
            hide(spot.fill)
            hide(spot.rim)
            hide(spot.rays)
            continue
        end
        local warning = ease((now - attack.warningAt) / (impact.at - attack.warningAt))
        local burst = unit(age / fadeAt)
        local center = state.origin + Vector3.new(impact.centerX, .148, impact.centerZ)
        local lit = age >= 0
        local color = if lit then HONEY else tint
        floorRing(spot.rim, center, impact.radius, color, if lit then .12 + .86 * burst else .48 - .32 * warning)
        paint(spot.fill[1], CFrame.new(center - UP * .009) * CFrame.Angles(0, 0, math.pi / 2),
            Vector3.new(.022, impact.radius * 2, impact.radius * 2), color,
            if lit then .47 + .51 * burst else .92 - .15 * warning)
        if lit then
            for ray, shard in spot.rays do
                local theta = ray * math.pi / 2 + index * .29
                local spread = impact.radius * (.22 + .45 * burst)
                local pos = center + Vector3.new(math.sin(theta) * spread, .3 + burst * .93, math.cos(theta) * spread)
                paint(shard, CFrame.new(pos) * CFrame.Angles(.29, theta, -.15),
                    Vector3.new(.12, .15, .91 * (1 - .42 * burst)), CREAM, .12 + burst * .87)
            end
        else
            hide(spot.rays)
        end
    end
end

local function diveTell(state, attack, now, tint, direction)
    local hit = attack.steps[1]
    local age = now - hit.at
    if age > .53 then
        hide(state.lane)
        hide(state.wake)
        return
    end
    local fade = unit(age / .53)
    local warning = ease((now - attack.warningAt) / (hit.at - attack.warningAt))
    local center = state.origin + direction * hit.offset + UP * .147
    local corridor = CFrame.lookAlong(center, direction)
    local halfLength, halfWidth = hit.halfWidth, hit.halfSpan
    local lit = age >= 0
    local color = if lit then CREAM else tint
    local edge = if lit then .10 + fade * .88 else .42 - warning * .30
    paint(state.lane[1], corridor, Vector3.new(halfWidth * 2, .024, halfLength * 2), color,
        if lit then .58 + fade * .40 else .92 - warning * .13)
    for index = 1, 2 do
        local side = if index == 1 then -1 else 1
        paint(state.lane[1 + index], corridor * CFrame.new(side * halfWidth, .018, 0),
            Vector3.new(.14, .03, halfLength * 2), color, edge)
        paint(state.lane[3 + index], corridor * CFrame.new(0, .018, side * halfLength),
            Vector3.new(halfWidth * 2, .03, .14), color, edge)
        paint(state.lane[5 + index], corridor * CFrame.new(side * halfWidth * .19, .023, -halfLength * .60)
            * CFrame.Angles(0, side * .45, 0), Vector3.new(.14, .041, halfWidth * 1.18), color, edge)
    end
    if lit then
        local tip = state.origin + direction * halfLength * fade + UP * (.35 + .35 * math.sin(fade * math.pi))
        local pulse = CFrame.lookAlong(tip, direction)
        for index, shard in state.wake do
            paint(shard, pulse * CFrame.new((index - 3) * halfWidth * .37, (index % 2) * .24, (index % 3) * 1.1),
                Vector3.new(.15, .13, 1.7 + fade * 1.21), color, .08 + fade * .89)
        end
    else
        hide(state.wake)
    end
end

local function landingTell(state, age)
    if age < 0 or age > .53 then
        hide(state.landing)
        return
    end
    local fade = unit(age / .53)
    for index, shard in state.landing do
        local theta = index * math.pi / 4
        local distance = 2.5 + .9 * fade
        local pos = state.origin + Vector3.new(math.sin(theta) * distance, .18 + fade * .74, math.cos(theta) * distance)
        paint(shard, CFrame.new(pos) * CFrame.Angles(-.37, theta, 0),
            Vector3.new(.17, .11, .57), JADE, .26 + fade * .72)
    end
end

local function flightPass(attack, now, direction)
    local hit = attack.steps[1]
    local range = hit.halfWidth - 1.15
    local yaw = math.atan2(direction.X, direction.Z)
    local preparation = .66
    if now < hit.at then
        local warning = unit((now - attack.startedAt) / (hit.at - attack.startedAt))
        if warning < preparation then
            local retreat = ease(warning / preparation)
            return -range * retreat, HOVER + 2.4 * math.sin(retreat * math.pi * .5),
                blendAngle(0, yaw, retreat), -.48 * retreat, .51 * retreat
        end
        local sweep = ease((warning - preparation) / (1 - preparation))
        return -range * (1 - sweep), lerp(HOVER + 2.4, 1.05, sweep), yaw, -.48 * (1 - sweep), .51 * (1 - sweep)
    end
    local recovery = unit((now - hit.at) / (attack.endsAt - hit.at))
    if recovery < .46 then
        local crossing = ease(recovery / .46)
        return range * crossing, lerp(1.05, 4.6, crossing), yaw, .21 * crossing, .62 * (1 - crossing)
    end
    local returnToCenter = ease((recovery - .46) / .54)
    return range * (1 - returnToCenter), lerp(4.6, HOVER, returnToCenter), blendAngle(yaw, 0, returnToCenter),
        .21 * (1 - returnToCenter), 0
end

function Visuals.update(state, round, now, direction)
    if now < state.nextFrame or state.settled then
        return
    end
    state.nextFrame = now + TICK
    local alive = round.bossHealth > 0
    local faster = round.bossPhase == 2
    local attack = if alive and not round.result then round.attack else nil
    local tell = attack and attack.id
    if tell ~= state.activeTell then
        clearTell(state)
        state.activeTell = tell
    end
    local tint = if faster then SCARLET else AMBER
    if tell == "solarFlare" then
        flareTells(state, attack, now, tint)
    elseif tell == "sunDive" then
        diveTell(state, attack, now, tint, direction)
    elseif tell == "dawnLanding" then
        landingTell(state, now - attack.landAt)
    end

    local flapRate = if faster then 6.9 else 5.8
    local pulse = (now - round.introAt) * flapRate
    local travel = Vector3.zero
    local altitude, yaw, bank = HOVER + .34 * math.sin(pulse * .55), .09 * math.sin(pulse * .26), 0
    local flight, fold, open, dim = 1, 0, 0, 0
    if tell == "sunDive" then
        local along
        along, altitude, yaw, bank, fold = flightPass(attack, now, direction)
        travel = direction * along
        flight = .51
    elseif tell == "dawnLanding" then
        local down = ease((now - attack.startedAt) / (attack.landAt - attack.startedAt))
        altitude, yaw, flight, fold = altitude * (1 - down), yaw * (1 - down), 1 - down, down
        if round.coreExposed then
            open = ease((now - attack.landAt) / .29) * ease((attack.endsAt - now) / .25)
        end
    elseif round.bossAirborne and alive then
        if not state.wasAirborne then
            state.takeoffAt = now
        end
        if state.takeoffAt then
            local launch = ease((now - state.takeoffAt) / .62)
            altitude, flight, fold = altitude * launch, launch, 1 - launch
            if launch == 1 then
                state.takeoffAt = nil
            end
        end
        if tell == "solarFlare" then
            local lead = ease((now - attack.warningAt) / (attack.impactAt - attack.warningAt))
            local release = ease((attack.endsAt - now) / .60)
            altitude += lead * release * .85 * flight
        end
    end
    state.wasAirborne = round.bossAirborne
    if not alive then
        state.defeatedAt = state.defeatedAt or round.resolvedAt or now
        dim = ease((now - state.defeatedAt) / .90)
        altitude, yaw, flight, fold, open = -.48 * dim, 0, 0, 1 - .23 * dim, 1 - dim
    end
    local frame = (state.bodyRest + travel + UP * altitude)
        * CFrame.Angles(bank - .19 * dim, yaw, .14 * dim)
    rigPose(state, frame, math.sin(pulse) * .51 * flight, math.sin(pulse - 1.28) * .29 * flight,
        fold, flight, bank, math.sin(pulse * .57) * .19 * flight, open, dim, if faster then 1 else 0)
    state.settled = dim == 1
end

return table.freeze(Visuals)
