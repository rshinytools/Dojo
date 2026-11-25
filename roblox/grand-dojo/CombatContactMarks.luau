-- Camera-facing marks give each outcome a recognizable silhouette.
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Marks = {}
local families = {
    strike = {name = "Strike contact", priority = 1, life = .25, size = 38, paths = {
        {.50, .18, .54, .40}, {.81, .43, .60, .48}, {.54, .79, .52, .58}, {.20, .62, .42, .54},
    }},
    guard = {name = "Guard contact", priority = 2, life = .32, size = 43, paths = {
        {.26, .24, .50, .19}, {.50, .19, .74, .24}, {.74, .24, .70, .57},
        {.70, .57, .50, .77}, {.50, .77, .30, .57}, {.30, .57, .26, .24},
    }},
    parry = {name = "Parry contact", priority = 3, life = .34, size = 46, paths = {
        {.33, .27, .17, .48}, {.17, .48, .33, .69}, {.67, .27, .83, .48}, {.83, .48, .67, .69},
        {.50, .30, .50, .66}, {.41, .48, .59, .48},
    }},
    breakGuard = {name = "Guard break contact", priority = 3, life = .36, size = 47, paths = {
        {.20, .24, .37, .18}, {.20, .24, .27, .59}, {.27, .59, .40, .71},
        {.63, .18, .80, .24}, {.80, .24, .73, .59}, {.73, .59, .60, .71},
        {.51, .22, .43, .46}, {.43, .46, .57, .46}, {.57, .46, .49, .76},
    }},
    deflect = {name = "Deflection contact", priority = 2, life = .30, size = 44, paths = {
        {.29, .27, .53, .48}, {.53, .48, .29, .69}, {.54, .27, .78, .48}, {.78, .48, .54, .69},
    }},
}
local defense = {blocked = "guard", braced = "guard", parried = "parry", deflected = "deflect", guardBroken = "breakGuard"}
local active = {}
local outline = Color3.fromRGB(38, 25, 33)

function Marks.defenseFamily(kind)
    return defense[kind]
end

local function samePoint(entry, point)
    return (entry.part.Position - point).Magnitude < .34
end

local function reserve(point, priority, limit, now)
    for index = #active, 1, -1 do
        if not active[index].part.Parent then table.remove(active, index) end
    end
    for _, entry in active do
        if entry.priority >= priority and now - entry.at < .075 and samePoint(entry, point) then
            return false
        end
    end
    -- A later contact refreshes the mark. Within one burst, defense takes priority.
    for index = #active, 1, -1 do
        if samePoint(active[index], point) then table.remove(active, index).part:Destroy() end
    end
    while #active >= limit do
        local replace, weakest = nil, priority
        for index, entry in active do
            if entry.priority <= weakest and (not replace or entry.priority < weakest) then
                replace, weakest = index, entry.priority
            end
        end
        if not replace then return false end
        table.remove(active, replace).part:Destroy()
    end
    return true
end

local function stroke(parent, points, color, thickness)
    local x, y, toX, toY = table.unpack(points)
    local dx, dy = toX - x, toY - y
    local bar = Instance.new("Frame")
    bar.Name = "Stroke"
    bar.AnchorPoint = Vector2.new(.5, .5)
    bar.Position = UDim2.fromScale((x + toX) / 2, (y + toY) / 2)
    bar.Size = UDim2.new(math.sqrt(dx * dx + dy * dy), 2, 0, thickness)
    bar.Rotation = math.deg(math.atan2(dy, dx))
    bar.BorderSizePixel, bar.BackgroundColor3 = 0, color
    local edge = Instance.new("UIStroke")
    edge.ApplyStrokeMode, edge.LineJoinMode = Enum.ApplyStrokeMode.Border, Enum.LineJoinMode.Round
    edge.Color, edge.Thickness, edge.Transparency = outline, 1.4, .04
    edge.Parent = bar
    bar.Parent = parent
    return bar, edge
end

function Marks.show(parent, point, family, color, compact, limited)
    local style, now = families[family], os.clock()
    if not reserve(point, style.priority, if limited then 5 else 8, now) then return nil end

    local anchor = Instance.new("Part")
    anchor.Name = style.name
    anchor.Anchored, anchor.CanCollide, anchor.CanTouch, anchor.CanQuery = true, false, false, false
    anchor.CastShadow, anchor.Transparency, anchor.Size = false, 1, Vector3.one * .05
    anchor.CFrame = CFrame.new(point)
    local visual = Instance.new("BillboardGui")
    visual.Name = "Contact mark"
    visual:SetAttribute("Family", family)
    visual.AlwaysOnTop, visual.LightInfluence, visual.MaxDistance = false, 0, 64
    visual.StudsOffset = Vector3.new(0, .15, .48)
    local size = style.size - (if compact then 6 else 0)
    visual.Size = UDim2.fromOffset(size, size)
    visual.Parent = anchor
    local bars = {}
    for _, points in style.paths do
        local bar, edge = stroke(visual, points, color, if compact then 2 else 3)
        table.insert(bars, {bar, edge})
    end
    anchor.Parent = parent
    table.insert(active, {part = anchor, priority = style.priority, at = now})
    local fade = TweenInfo.new(.095, Enum.EasingStyle.Quad)
    task.delay(style.life - fade.Time, function()
        if not anchor.Parent then return end
        for _, pair in bars do
            TweenService:Create(pair[1], fade, {BackgroundTransparency = 1}):Play()
            TweenService:Create(pair[2], fade, {Transparency = 1}):Play()
        end
    end)
    Debris:AddItem(anchor, style.life + .05)
    return anchor
end

return table.freeze(Marks)
