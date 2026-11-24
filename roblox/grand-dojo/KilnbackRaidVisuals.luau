-- The room markers remain fixed for fitted combat. Only the ceramic rig and tells move.
local Visuals = {}

local AMBER = Color3.fromRGB(255, 155, 74)
local PALE = Color3.fromRGB(255, 216, 136)
local EMBER = Color3.fromRGB(255, 115, 75)
local STEAM = Color3.fromRGB(255, 230, 189)
local VENT_IDLE = Color3.fromRGB(195, 121, 67)
local CORE_IDLE = Color3.fromRGB(68, 112, 107)
local CORE_OPEN = Color3.fromRGB(145, 255, 217)
local COLD = Color3.fromRGB(75, 75, 66)
local UP = Vector3.yAxis
local RIM_SEGMENTS = 24
local TICK = 1 / 20
local LEVEL_DISK = CFrame.Angles(0, 0, math.pi / 2)

local function glow(folder, name, tint, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Material, part.Color = Enum.Material.Neon, tint
    part.Shape = shape or Enum.PartType.Block
    part.Size, part.Transparency = Vector3.new(.2, .04, .2), 1
    part.Anchored, part.CastShadow = true, false
    part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
    part.Parent = folder
    return part
end

local function posed(parent, name)
    local model = parent:WaitForChild(name)
    return {model = model, rest = model:GetPivot()}
end

local function paint(node, cf, size, tint, transparency)
    node.CFrame, node.Size, node.Color, node.Transparency = cf, size, tint, transparency
end

local function ease(value)
    local x = math.clamp(value, 0, 1)
    return x * x * (3 - 2 * x)
end

local function percent(now, first, last)
    return math.clamp((now - first) / math.max(last - first, .05), 0, 1)
end

local function hide(group)
    for _, node in group do
        node.Transparency = 1
    end
end

local function restore(group)
    for _, pose in group do
        pose.model:PivotTo(pose.rest)
    end
end

function Visuals.new(court)
    local boss = court:WaitForChild("Kilnback Custodian")
    local origin = boss:WaitForChild("Origin")
    local rig = boss:WaitForChild("Animated Body")
    local folder = court:WaitForChild("Raid Tells")
    folder:ClearAllChildren()
    local state = {
        body = {model = rig, rest = rig:GetPivot()},
        origin = origin.Position,
        front = origin.CFrame.LookVector,
        head = posed(rig, "Head"),
        core = rig:WaitForChild("Core Glow"),
        plates = {}, legs = {}, bellows = {}, shutters = {}, vents = {}, eyes = {},
        ring = {}, steam = {}, rows = {}, activeTell = nil,
        pulseFloor = glow(folder, "Kiln pulse warning floor", AMBER, Enum.PartType.Cylinder),
        nextFrame = 0,
    }
    for index = 1, 8 do
        state.plates[index] = posed(rig, "Shell Plate " .. index)
    end
    for index = 1, 4 do
        state.legs[index] = posed(rig, "Leg " .. index)
    end
    for index, side in {"Left", "Right"} do
        state.bellows[index] = posed(rig, "Bellows " .. side)
        state.shutters[index] = posed(rig, "Core Shutter " .. side)
        state.vents[index] = state.bellows[index].model:WaitForChild("Vent Glow")
        state.eyes[index] = state.head.model:WaitForChild(if index == 1 then "Eye -1" else "Eye 1")
        state.steam[index] = {}
        for layer = 1, 3 do
            state.steam[index][layer] = glow(folder, "Steam vent", STEAM, Enum.PartType.Ball)
        end
    end
    for index = 1, RIM_SEGMENTS do
        state.ring[index] = glow(folder, "Kiln pulse boundary", AMBER)
    end
    for index = 1, 3 do
        local row = {floor = glow(folder, "Tile wave warning floor", AMBER), edges = {}, tiles = {}}
        for edge = 1, 4 do
            row.edges[edge] = glow(folder, "Tile wave boundary", AMBER)
        end
        for tile = 1, 5 do
            row.tiles[tile] = glow(folder, "Rolling ceramic tile", PALE)
        end
        state.rows[index] = row
    end
    return state
end

local function clearTell(state)
    if state.activeTell == "pulse" then
        hide(state.ring)
        state.pulseFloor.Transparency = 1
        for _, side in state.steam do
            hide(side)
        end
    elseif state.activeTell == "sweep" then
        for _, row in state.rows do
            row.floor.Transparency = 1
            hide(row.edges)
            hide(row.tiles)
        end
    end
    state.activeTell = nil
end

function Visuals.reset(state)
    clearTell(state)
    state.body.model:PivotTo(state.body.rest)
    state.head.model:PivotTo(state.head.rest)
    restore(state.plates)
    restore(state.legs)
    restore(state.bellows)
    restore(state.shutters)
    state.core.Color = CORE_IDLE
    for index, vent in state.vents do
        vent.Color = VENT_IDLE
        state.eyes[index].Color = PALE
    end
    state.nextFrame, state.shutdownAt, state.sweepPlate = 0, nil, nil
end

local function pulse(state, attack, now, tint)
    local step = attack.steps[1]
    local after = now - step.at
    local origin, radius = state.origin + UP * .053, step.radius
    local warming = percent(now, attack.warningAt, step.at)
    if after <= .35 then
        local active = after >= 0
        local traveling = if active then .48 + .52 * percent(now, step.at, step.at + .35) else 1
        local ringRadius = radius * traveling
        paint(state.pulseFloor, CFrame.new(origin) * LEVEL_DISK, Vector3.new(.027, radius * 2, radius * 2),
            tint, if active then .79 + .19 * (after / .35) else .93 - .13 * warming)
        for index, segment in state.ring do
            local angle = (index - .5) * math.pi * 2 / RIM_SEGMENTS
            local point = origin + Vector3.new(math.sin(angle) * ringRadius, .025, math.cos(angle) * ringRadius)
            local arc = 2 * ringRadius * math.sin(math.pi / RIM_SEGMENTS)
            paint(segment, CFrame.new(point) * CFrame.Angles(0, angle, 0), Vector3.new(arc + .022, .045, .18),
                if active then PALE else tint, if active then .12 + .62 * (after / .35) else .37 - .22 * warming)
        end
    else
        hide(state.ring)
        state.pulseFloor.Transparency = 1
    end
    for side, group in state.steam do
        local sign = if side == 1 then -1 else 1
        for index, puff in group do
            local age = after - (index - 1) * .057
            if age >= 0 and age < .40 then
                local scale = age / .40
                local center = state.origin + Vector3.new(sign * (5.97 + scale * 2.35), 1.98 + scale * 1.15, -.73)
                paint(puff, CFrame.new(center), Vector3.new(1, .67, .72) * (.50 + scale * .84), STEAM, .40 + scale * .59)
            else
                puff.Transparency = 1
            end
        end
    end
end

local function sweep(state, attack, now, facing, tint)
    for index, step in attack.steps do
        local row = state.rows[index]
        local after = now - step.at
        local waveLife = .38
        if after > waveLife then
            row.floor.Transparency = 1
            hide(row.edges)
            hide(row.tiles)
            continue
        end
        local center = state.origin + UP * .069 + facing * step.offset
        local frame = CFrame.lookAt(center, center + facing)
        local active = after >= 0
        local warning = percent(now, attack.warningAt, step.at)
        local width, span = step.halfWidth, step.halfSpan
        paint(row.floor, frame, Vector3.new(span * 2, .029, width * 2), tint,
            if active then .77 + .20 * (after / waveLife) else .94 - warning * .12)
        for edge, rail in row.edges do
            local across = edge < 3
            local sign = if edge % 2 == 1 then -1 else 1
            local offset = if across then Vector3.new(0, .025, sign * width) else Vector3.new(sign * span, .025, 0)
            local size = if across then Vector3.new(span * 2 + .18, .033, .18)
                else Vector3.new(.18, .033, width * 2 + .18)
            paint(rail, frame * CFrame.new(offset), size, if active then PALE else tint,
                if active then .12 + .72 * (after / waveLife) else .40 - warning * .27)
        end
        for tile, slat in row.tiles do
            if active then
                local progress = after / waveLife
                local lift = math.sin(math.pi * progress)
                local spacing = span * .40
                local pose = frame * CFrame.new((tile - 3) * spacing, .12 + .89 * lift, width - 2 * width * progress)
                    * CFrame.Angles(-.46 * lift, 0, 0)
                paint(slat, pose, Vector3.new(spacing * .89, .20, .82), PALE, .17 + .80 * progress)
            else
                slat.Transparency = 1
            end
        end
    end
end

function Visuals.update(state, round, now, direction)
    if now < state.nextFrame then
        return
    end
    state.nextFrame = now + TICK
    local attack = round.attack
    local alive = round.bossHealth > 0
    local tells = if alive and attack then attack.id else nil
    if tells ~= state.activeTell then
        clearTell(state)
        state.activeTell = tells
    end
    if not alive then
        local at = state.shutdownAt or round.resolvedAt or now
        if not state.shutdownAt then
            restore(state.plates)
            state.sweepPlate = nil
            state.shutdownAt = at
        end
        local fall = ease((now - at) / .72)
        state.body.model:PivotTo(CFrame.new(0, -.76 * fall, 0) * state.body.rest)
        state.head.model:PivotTo(CFrame.new(0, -.75 * fall, 0) * state.head.rest * CFrame.Angles(.31 * fall, 0, 0))
        state.core.Color = CORE_IDLE:Lerp(COLD, fall)
        for index, vent in state.vents do
            vent.Color = VENT_IDLE:Lerp(COLD, fall)
            state.eyes[index].Color = PALE:Lerp(COLD, fall)
        end
        return
    end
    local vector = direction or (attack and attack.direction) or state.front
    local horizontal = Vector3.new(vector.X, 0, vector.Z)
    local facing = if horizontal.Magnitude > .01 then horizontal.Unit else state.front
    local yaw = math.atan2(facing.X, facing.Z)
    local coreOpen = if round.coreExposed and attack then ease((now - attack.startedAt) / .36)
        * ease((attack.endsAt - now) / .32) else 0
    local tint = if round.bossPhase == 2 then EMBER else AMBER
    local warning = if tells == "pulse" or tells == "sweep" then percent(now, attack.warningAt, attack.impactAt)
        else 0
    local leg = 0
    if tells == "pulse" then
        pulse(state, attack, now, tint)
        leg = warning * .11
    elseif tells == "sweep" then
        sweep(state, attack, now, facing, tint)
    end
    local plate = if tells == "sweep" then (math.floor(yaw / (math.pi / 4) + .5) % 8) + 1 else nil
    if state.sweepPlate and state.sweepPlate ~= plate then
        local old = state.plates[state.sweepPlate]
        old.model:PivotTo(old.rest)
    end
    if plate then
        local pose = state.plates[plate]
        local tip = ease(warning) * ease((attack.endsAt - now) / .42)
        pose.model:PivotTo(pose.rest * CFrame.Angles(-.44 * tip, 0, 0))
    end
    state.sweepPlate = plate
    local breath = math.sin((now - round.introAt) * 2.1) * .065
    local turn = if tells == "sweep" then yaw * .43 * warning else 0
    state.head.model:PivotTo(state.head.rest * CFrame.new(0, breath - coreOpen * .34, 0)
        * CFrame.Angles(.17 * coreOpen, turn, -.04 * warning))
    state.core.Color = CORE_IDLE:Lerp(CORE_OPEN, coreOpen)
    if warning > 0 or state.wasBraced then
        for index, pose in state.legs do
            local sign = if index < 3 then -1 else 1
            pose.model:PivotTo(pose.rest * CFrame.Angles(0, 0, sign * leg))
        end
    end
    state.wasBraced = warning > 0
    for index, shutter in state.shutters do
        local sign = if index == 1 then -1 else 1
        shutter.model:PivotTo(shutter.rest * CFrame.new(sign * 1.01 * coreOpen, .09 * coreOpen, -.06 * coreOpen)
            * CFrame.Angles(0, -sign * .45 * coreOpen, 0))
        local bellows = state.bellows[index]
        bellows.model:PivotTo(bellows.rest * CFrame.new(sign * (.30 * warning + .6 * breath), 0, 0))
        state.vents[index].Color = VENT_IDLE:Lerp(tint:Lerp(PALE, .25), warning)
        state.eyes[index].Color = if round.bossPhase == 2 then PALE:Lerp(EMBER, .55) else PALE
    end
end

return table.freeze(Visuals)
