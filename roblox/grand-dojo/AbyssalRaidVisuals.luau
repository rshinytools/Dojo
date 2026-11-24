-- Only the boss rig and effect pool move. Combat uses the court's fixed fit.
local Visuals = {}

local AMBER = Color3.fromRGB(255, 171, 78)
local CORAL = Color3.fromRGB(255, 129, 91)
local FOAM = Color3.fromRGB(194, 243, 239)
local PEARL_IDLE = Color3.fromRGB(76, 112, 127)
local PEARL_OPEN = Color3.fromRGB(120, 247, 216)
local PEARL_HEART = Color3.fromRGB(98, 142, 148)
local IRIS_IDLE = Color3.fromRGB(160, 91, 99)
local IRIS_RAGE = Color3.fromRGB(219, 111, 86)
local COLD = Color3.fromRGB(53, 54, 75)
local TICK = 1 / 18
local SECTION_AXIS = CFrame.Angles(0, -math.pi / 2, 0)
local RIM_COUNT = 24
local ARM_AXES = {Vector3.zAxis, Vector3.xAxis, -Vector3.zAxis, -Vector3.xAxis}
local ARM_RADII = {3.55, 5.72, 8.08, 10.37, 12.51, 14.26, 15.60}
local ARM_HEIGHTS = {1.62, 1.35, 1.02, .64, .65, 1.02, 1.73}
local UP = Vector3.yAxis

local function pool(folder, name, count)
    local parts = {}
    for index = 1, count do
        local part = Instance.new("Part")
        part.Name = name
        part.Material = Enum.Material.Neon
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

local function unit(value)
    return math.clamp(value, 0, 1)
end

local function ease(value)
    local x = unit(value)
    return x * x * (3 - 2 * x)
end

function Visuals.new(court)
    local boss = court:WaitForChild("Abyssal Kraken")
    local body = boss:WaitForChild("Animated Body")
    local folder = court:WaitForChild("Raid Tells")
    folder:ClearAllChildren()
    local state = {
        origin = boss:WaitForChild("Origin").Position,
        body = body, bodyRest = body:GetPivot(),
        plates = {}, arms = {}, lanes = {}, irises = {},
        pearl = body:WaitForChild("Mantle Pearl"), heart = body:WaitForChild("Pearl Heart"),
        outerRim = pool(folder, "Undertow outer warning", RIM_COUNT),
        innerRim = pool(folder, "Undertow inner safe boundary", RIM_COUNT),
        stipple = pool(folder, "Undertow danger band", 12),
        undertowFoam = pool(folder, "Undertow foam", 8),
        nextFrame = 0,
    }
    for index, side in {"Left", "Right"} do
        local plate = body:WaitForChild("Mantle Plate " .. side)
        state.plates[index] = {model = plate, rest = state.bodyRest:ToObjectSpace(plate:GetPivot())}
        state.irises[index] = body:WaitForChild(side .. " iris")
    end
    local tentacles = boss:WaitForChild("Tentacles")
    for arm = 1, 4 do
        local model = tentacles:WaitForChild("Tentacle " .. arm)
        local links = {}
        for index = 1, #ARM_RADII - 1 do
            local link = model:WaitForChild("Link " .. index)
            local part = link:WaitForChild("Arm")
            local joint = link:WaitForChild("Arm joint")
            local seam = link:WaitForChild("Dorsal seam")
            local tip = if index == #ARM_RADII - 1 then link:WaitForChild("Hooked tip") else nil
            links[index] = {model = link, core = part, width = part.Size.Y, rest = link:GetPivot(), restSize = part.Size,
                joint = joint, jointRest = joint.CFrame, seam = seam, seamRest = seam.CFrame, seamSize = seam.Size,
                tip = tip, tipRest = tip and tip.CFrame}
        end
        state.arms[arm] = links
        state.lanes[arm] = {
            region = pool(folder, "Tentacle warning lane", 5),
            foam = pool(folder, "Tentacle splash", 4),
        }
    end
    return state
end

local function clearTell(state)
    if state.activeTell == "undertow" then
        hide(state.outerRim)
        hide(state.innerRim)
        hide(state.stipple)
        hide(state.undertowFoam)
    elseif state.activeTell == "cataclysm" then
        for _, lane in state.lanes do
            hide(lane.region)
            hide(lane.foam)
        end
    end
    state.activeTell = nil
end

function Visuals.reset(state)
    clearTell(state)
    state.body:PivotTo(state.bodyRest)
    for index, plate in state.plates do
        plate.model:PivotTo(state.bodyRest * plate.rest)
        state.irises[index].Color = IRIS_IDLE
    end
    state.pearl.Color, state.heart.Color = PEARL_IDLE, PEARL_HEART
    for _, links in state.arms do
        for _, link in links do
            link.model:PivotTo(link.rest)
            link.core.Size = link.restSize
            link.joint.CFrame, link.seam.CFrame, link.seam.Size = link.jointRest, link.seamRest, link.seamSize
            if link.tip then
                link.tip.CFrame = link.tipRest
            end
        end
    end
    state.nextFrame, state.shutdownAt, state.settled = 0, nil, false
end

local function ring(origin, parts, radius, tint, transparency)
    local spacing = math.pi * 2 / #parts
    local length = radius * 2 * math.sin(spacing / 2)
    local midpoint = radius * math.cos(spacing / 2)
    for index, part in parts do
        local angle = spacing * (index - .5)
        local point = origin + Vector3.new(math.sin(angle) * midpoint, 0, math.cos(angle) * midpoint)
        paint(part, CFrame.new(point) * CFrame.Angles(0, angle, 0),
            Vector3.new(length + .03, .039, .15), tint, transparency)
    end
end

local function undertow(state, attack, now, tint)
    local step = attack.steps[1]
    local age = now - step.at
    local tail = .45
    if age > tail then
        hide(state.outerRim)
        hide(state.innerRim)
        hide(state.stipple)
        hide(state.undertowFoam)
        return
    end
    local lit = age >= 0
    local progress = unit(age / tail)
    local warning = ease((now - attack.warningAt) / (step.at - attack.warningAt))
    local origin = state.origin + UP * .071
    local ringColor = if lit then FOAM else tint
    local opacity = if lit then .19 + progress * .77 else .40 - warning * .26
    ring(origin, state.outerRim, step.radius, ringColor, opacity)
    ring(origin, state.innerRim, step.innerRadius, ringColor, opacity)
    local mid = (step.radius + step.innerRadius) / 2
    for index, mark in state.stipple do
        local angle = index * math.pi * 2 / #state.stipple
        local point = origin + Vector3.new(math.sin(angle) * mid, 0, math.cos(angle) * mid)
        local stripe = Vector3.new(.22, .035, (step.radius - step.innerRadius) * .48)
        paint(mark, CFrame.new(point) * CFrame.Angles(0, angle, 0), stripe, ringColor, math.min(.99, opacity+.22))
    end
    if lit then
        local radius = step.radius + (step.innerRadius - step.radius) * progress
        for index, foam in state.undertowFoam do
            local angle = 2 * math.pi * index / #state.undertowFoam
            local point = state.origin + Vector3.new(math.sin(angle)*radius, .24 + .38*math.sin(math.pi*progress),
                math.cos(angle)*radius)
            paint(foam, CFrame.new(point) * CFrame.Angles(0, angle, 0),
                Vector3.new(1.12 + progress*1.05, .18, .34), FOAM, .26 + progress*.72)
        end
    else
        hide(state.undertowFoam)
    end
end

local function cataclysm(state, attack, now, tint)
    for index, step in attack.steps do
        local lane = state.lanes[index]
        local age = now - step.at
        local tail = .41
        if age > tail then
            hide(lane.region)
            hide(lane.foam)
            continue
        end
        local axis = Vector3.new(step.axisX, 0, step.axisZ)
        local reach = step.outerReach - step.innerReach
        local middle = (step.outerReach + step.innerReach)/2
        local origin = state.origin + UP * .064
        local frame = CFrame.lookAlong(origin + axis * middle, axis)
        local lit = age >= 0
        local progress = unit(age/tail)
        local warning = ease((now - attack.warningAt)/(step.at - attack.warningAt))
        local edge = if lit then .16 + progress*.81 else .44 - warning*.29
        local color = if lit then FOAM else tint
        paint(lane.region[1], frame, Vector3.new(step.halfWidth*2, .025, reach), color,
            if lit then .69 + progress*.30 else .94 - warning*.14)
        for side = 1, 2 do
            local sign = if side == 1 then -1 else 1
            paint(lane.region[1 + side], frame * CFrame.new(sign*step.halfWidth, .028, 0),
                Vector3.new(.15, .036, reach + .12), color, edge)
            paint(lane.region[3 + side], frame * CFrame.new(0, .028, sign*reach/2),
                Vector3.new(step.halfWidth*2, .036, .15), color, edge)
        end
        if lit then
            local water = CFrame.lookAlong(origin + axis * (step.outerReach - reach*progress), axis)
            for spray, foam in lane.foam do
                local spread = (spray - 2.5) * step.halfWidth * .49
                local frame = water * CFrame.new(spread, .2+.54*math.sin(math.pi*progress), (spray%2)*.32)
                paint(foam, frame, Vector3.new(.61, .16, .71 + 1.2*progress), FOAM, .20 + progress*.73)
            end
        else
            hide(lane.foam)
        end
    end
end

local function poseArm(state, index, now, attack, turn, fold)
    local links, axis = state.arms[index], ARM_AXES[index]
    local across = Vector3.new(axis.Z, 0, -axis.X)
    local reach, lift, recoil, uncoil = 0, 0, 0, 0
    if attack and attack.id == "cataclysm" then
        local step = attack.steps[index]
        local age = now - step.at
        if age < 0 then
            local windup = ease((now - attack.warningAt)/(step.at - attack.warningAt - .26))
            reach = (step.outerReach - ARM_RADII[#ARM_RADII]) * windup
            local slam = ease((age + .27)/.27)
            lift = windup * (1 - slam) * 6.20
            recoil, uncoil = slam * .22, windup
        else
            local landing = ease(age/.72)
            reach = (step.outerReach - ARM_RADII[#ARM_RADII]) * (1 - landing)
            lift = -.74 * (1 - landing) + math.sin(math.pi*landing) * .42
            recoil, uncoil = 1 - landing, 1 - landing
        end
    elseif attack and attack.id == "undertow" then
        local swell = ease((now - attack.warningAt)/(attack.impactAt - attack.warningAt))
            * ease((attack.endsAt - now)/.6)
        lift, reach = swell*1.25, swell*.62
    end
    local function node(sample)
        local along = (sample - 1)/(#ARM_RADII - 1)
        local tide = math.sin(now*1.62 + along*3.2 + index*.71)
        local bow = math.sin(along * math.pi)
        local bend = (.49 + .22*turn)*bow + tide*along*.27
            + along^4*(1.73 + .38*tide)*(1 - uncoil*.82)
        local radius = ARM_RADII[sample] + reach*along^1.45 - along*(fold*1.68 + recoil*.38)
        local y = ARM_HEIGHTS[sample] + along^1.35*lift + tide*along*.12 - fold*(.22 + along*.38)
        return state.origin + axis*radius + across*bend*(1 - fold*.4) + UP*y
    end
    local first = node(1)
    for sample, link in links do
        local target = node(sample + 1)
        local mid = (first + target)/2
        local length, width = (target - first).Magnitude, link.width
        -- Native cylinder parts measure their length on local X. Their end
        -- caps overlap the shared joint at every bent or extended pose.
        local frame = CFrame.lookAt(mid, first) * SECTION_AXIS
        link.model:PivotTo(frame)
        link.core.Size = Vector3.new(length + width*.47, width, width)
        link.joint.CFrame = CFrame.new(first)
        link.seam.CFrame = frame * CFrame.new(0, width*.43, 0)
        link.seam.Size = Vector3.new(length*.87, width*.18, width*.18)
        if link.tip then
            link.tip.CFrame = CFrame.lookAt(target, mid) * SECTION_AXIS * CFrame.Angles(0, 0, -.54)
        end
        first = target
    end
end

function Visuals.update(state, round, now, _direction)
    if now < state.nextFrame or state.settled then
        return
    end
    state.nextFrame = now + TICK
    local alive = round.bossHealth > 0
    local attack = if alive then round.attack else nil
    local tell = attack and attack.id
    if tell ~= state.activeTell then
        clearTell(state)
        state.activeTell = tell
    end
    local faster = round.bossPhase == 2
    local tint = if faster then CORAL else AMBER
    if tell == "undertow" then
        undertow(state, attack, now, tint)
    elseif tell == "cataclysm" then
        cataclysm(state, attack, now, tint)
    end
    local opening = if tell == "airPocket" and round.coreExposed then
        ease((now - attack.startedAt)/.33) * ease((attack.endsAt - now)/.30) else 0
    local surge = if attack and attack.impactAt then
        ease((now - attack.warningAt)/(attack.impactAt - attack.warningAt))
            * ease((attack.endsAt - now)/.38) else 0
    if not alive and not state.shutdownAt then
        state.shutdownAt = round.resolvedAt or now
    end
    local fold = if state.shutdownAt then ease((now - state.shutdownAt)/.88) else 0
    local breath = math.sin((now - round.introAt) * (if faster then 2.78 else 1.93)) * .10 * (1 - fold)
    local bodyFrame = state.bodyRest * CFrame.new(0, breath + surge*.38 - fold*.79, 0)
        * CFrame.Angles(.08*surge - .20*fold, 0, .11*fold)
    state.body:PivotTo(bodyFrame)
    for side, plate in state.plates do
        local sign = if side == 1 then -1 else 1
        plate.model:PivotTo(bodyFrame * plate.rest * CFrame.new(sign*opening*1.24, opening*.25, -.20*opening)
            * CFrame.Angles(0, sign*opening*.67, sign*opening*.23))
        state.irises[side].Color = (if faster then IRIS_RAGE else IRIS_IDLE):Lerp(COLD, fold)
    end
    state.pearl.Color = PEARL_IDLE:Lerp(PEARL_OPEN, opening):Lerp(COLD, fold)
    state.heart.Color = PEARL_HEART:Lerp(PEARL_OPEN, opening):Lerp(COLD, fold)
    for index = 1, #state.arms do
        poseArm(state, index, now, attack, surge, fold)
    end
    state.settled = fold == 1
end

return table.freeze(Visuals)
