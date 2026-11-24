local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatHealth = require(ReplicatedStorage:WaitForChild("CombatHealth"))

local Championship = {}
Championship.__index = Championship

local rgb = Color3.fromRGB
local paper = rgb(255, 240, 205)
local dark = rgb(24, 19, 26)
local bronze = rgb(100, 48, 17)
local gold = rgb(244, 168, 60)
local lightGold = rgb(255, 225, 140)
local white = rgb(255, 255, 255)
local black = rgb(0, 0, 0)
local teal = rgb(23, 198, 160)
local red = rgb(232, 56, 68)

local gilded = ColorSequence.new({
    ColorSequenceKeypoint.new(0, lightGold),
    ColorSequenceKeypoint.new(.20, rgb(251, 190, 77)),
    ColorSequenceKeypoint.new(.44, rgb(161, 82, 27)),
    ColorSequenceKeypoint.new(.69, gold),
    ColorSequenceKeypoint.new(1, rgb(144, 72, 27)),
})
local carved = ColorSequence.new(rgb(124, 63, 32), rgb(54, 27, 26))
local lacquer = ColorSequence.new(rgb(106, 37, 33), rgb(49, 23, 27))
local slate = ColorSequence.new(rgb(57, 49, 56), rgb(24, 23, 31))
local damage = ColorSequence.new(rgb(255, 232, 132), rgb(238, 151, 48))

local function make(class, parent, attributes)
    local object = Instance.new(class)
    for key, value in attributes do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function frame(parent, name, color, zIndex)
    return make("Frame", parent, {
        Name = name, BackgroundColor3 = color or white, BackgroundTransparency = if color then 0 else 1,
        BorderSizePixel = 0, ZIndex = zIndex,
    })
end

local function corner(parent, radius)
    make("UICorner", parent, {CornerRadius = radius})
end

local function gradient(parent, colors)
    local effect = parent:FindFirstChildOfClass("UIGradient")
    if not effect then
        effect = make("UIGradient", parent, {})
    end
    effect.Color = colors
    effect.Rotation = 90
end

local function keyline(parent, color, thickness)
    make("UIStroke", parent, {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = color, Thickness = thickness})
end

local function label(parent, name, font, color, zIndex)
    return make("TextLabel", parent, {
        Name = name, Font = font, Text = "", TextColor3 = color, TextStrokeColor3 = dark,
        TextStrokeTransparency = .45, BackgroundTransparency = 1, TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = zIndex,
    })
end

local function inset(object, amount)
    object.Position = UDim2.fromOffset(amount, amount)
    object.Size = UDim2.new(1, -amount * 2, 1, -amount * 2)
end

local function blade(parent, name, color, zIndex, colors)
    local span = frame(parent, name, color, zIndex)
    local point = frame(parent, name .. "Point", color, zIndex)
    point.Rotation = 45
    point.AnchorPoint = Vector2.new(.5, .5)
    if colors then
        gradient(span, colors)
        gradient(point, colors)
    end
    return {span = span, point = point}
end

local function layoutBlade(layer, mirrored, barHeight, padding)
    local height = barHeight - padding * 2
    local half = math.floor(barHeight / 2)
    local tipWidth = math.round(height / math.sqrt(2))
    layer.span.Position = if mirrored then UDim2.fromOffset(half, padding) else UDim2.fromOffset(padding, padding)
    layer.span.Size = UDim2.new(1, -half - padding + 1, 0, height)
    layer.point.Size = UDim2.fromOffset(tipWidth, tipWidth)
    layer.point.Position = UDim2.new(if mirrored then 0 else 1, if mirrored then half else -half, .5, 0)
end

local function studs(parent, zIndex)
    local items = {}
    for index, anchor in {Vector2.new(0, 0), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(1, 1)} do
        local peg = frame(parent, "Brass rivet", lightGold, zIndex)
        peg.AnchorPoint = Vector2.new(.5, .5)
        peg.Position = UDim2.fromScale(anchor.X, anchor.Y)
        peg.Rotation = 45
        keyline(peg, bronze, 1)
        items[index] = peg
    end
    return items
end

local function fighter(parent, mirrored, font)
    local group = frame(parent, if mirrored then "RightFighter" else "LeftFighter", nil, 2)
    local frameAnchor = if mirrored then Vector2.new(1, 0) else Vector2.new(0, 0)
    local portraitFrame = frame(group, "PortraitFrame", white, 9)
    portraitFrame.AnchorPoint = frameAnchor
    portraitFrame.Position = UDim2.fromScale(frameAnchor.X, 0)
    corner(portraitFrame, UDim.new(0, 7))
    gradient(portraitFrame, gilded)
    keyline(portraitFrame, dark, 2)
    local recess = frame(portraitFrame, "Carved lip", bronze, 10)
    corner(recess, UDim.new(0, 5))
    keyline(recess, lightGold, 1)
    local backing = frame(recess, "Lacquer panel", white, 11)
    corner(backing, UDim.new(0, 4))
    gradient(backing, lacquer)
    local portrait = frame(backing, "Portrait", nil, 12)
    inset(portrait, 0)
    local pegs = studs(recess, 13)

    local bar = frame(group, "BarHousing", nil, 3)
    bar.AnchorPoint = frameAnchor
    local outlines = {
        blade(bar, "Outline", dark, 3),
        blade(bar, "Gold trim", white, 4, gilded),
        blade(bar, "Recessed edge", white, 5, carved),
        blade(bar, "Dark track", dark, 6),
    }
    local lip = frame(bar, "Top highlight", lightGold, 7)
    lip.BackgroundTransparency = .28
    local plaque = frame(group, "Lacquer title", white, 4)
    plaque.AnchorPoint = frameAnchor
    gradient(plaque, lacquer)
    corner(plaque, UDim.new(0, 5))
    keyline(plaque, bronze, 1)
    local plaqueLine = frame(plaque, "Lacquer highlight", lightGold, 5)
    plaqueLine.BackgroundTransparency = .73
    plaqueLine.Position = UDim2.fromOffset(7, 1)
    plaqueLine.Size = UDim2.new(1, -14, 0, 1)
    local clasp = frame(group, "Brass bar clasp", white, 10)
    clasp.AnchorPoint = frameAnchor
    corner(clasp, UDim.new(0, 4))
    gradient(clasp, gilded)
    keyline(clasp, dark, 1.5)
    local claspChannel = frame(clasp, "Inset", white, 11)
    inset(claspChannel, 3)
    corner(claspChannel, UDim.new(0, 2))
    gradient(claspChannel, carved)
    keyline(claspChannel, lightGold, 1)
    local claspPeg = frame(claspChannel, "Inlaid brass", gold, 12)
    claspPeg.AnchorPoint = Vector2.new(.5, .5)
    claspPeg.Position = UDim2.fromScale(.5, .5)
    claspPeg.Size = UDim2.fromOffset(7, 7)
    claspPeg.Rotation = 45
    keyline(claspPeg, bronze, 1)

    local health = CombatHealth.new(group, if mirrored then "OPPONENT" else "FIGHTER", mirrored, font)
    local unused = health.track.Parent
    health.track.Parent = bar
    health.caption.Parent = plaque
    health.amount.Parent = health.track
    unused:Destroy()
    local tint = if mirrored then red else teal
    health.tone = paper
    health.track.ZIndex = 7
    health.track.BackgroundColor3 = white
    gradient(health.track, slate)
    health.track:FindFirstChildOfClass("UIStroke"):Destroy()
    health.chip.BackgroundColor3 = white
    health.chip.ZIndex = 8
    gradient(health.chip, damage)
    health.fill.ZIndex = 9
    gradient(health.fill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, tint:Lerp(white, .58)),
        ColorSequenceKeypoint.new(.22, tint:Lerp(white, .25)),
        ColorSequenceKeypoint.new(.29, tint),
        ColorSequenceKeypoint.new(1, tint:Lerp(black, .23)),
    }))
    health.edge.ZIndex = 10
    local ratioShine = frame(health.fill, "Glass highlight", white, 10)
    ratioShine.Size = UDim2.new(1, 0, 0, 1)
    ratioShine.Position = UDim2.fromOffset(0, 1)
    ratioShine.BackgroundTransparency = .38
    health.caption.ZIndex = 7
    health.caption.TextScaled = true
    health.caption.TextXAlignment = Enum.TextXAlignment.Center
    health.caption.TextStrokeColor3 = dark
    health.caption.TextStrokeTransparency = .30
    health.caption.Font = Enum.Font.GothamBlack
    local titleLimit = make("UITextSizeConstraint", health.caption, {MinTextSize = 9})
    health.amount.ZIndex = 11
    health.amount.TextColor3 = paper
    health.amount.TextStrokeColor3 = dark
    health.amount.TextStrokeTransparency = .10
    health.amount.Font = Enum.Font.GothamBold
    health.amount.TextXAlignment = if mirrored then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left
    local setHealth = health.Set
    function health:Set(current, maximum, name, reset)
        setHealth(self, current, maximum, if type(name) == "string" then string.upper(name) else nil, reset)
    end

    return {group = group, portraitFrame = portraitFrame, recess = recess, backing = backing, portrait = portrait,
        pegs = pegs, plaque = plaque, clasp = clasp, outlines = outlines, lip = lip, bar = bar, health = health,
        titleLimit = titleLimit, mirrored = mirrored}
end

local function layoutFighter(side, compact, size, timerRadius)
    local mirrored = side.mirrored
    local portraitSize = if compact then 39 else 84
    local portraitInset = if compact then 3 else 6
    local overhang = if compact then 5 else 10
    local throat = if compact then 3 else 5
    side.group.Size = UDim2.new(.5, -timerRadius + throat, 0, size)
    side.group.AnchorPoint = if mirrored then Vector2.new(1, 0) else Vector2.new(0, 0)
    side.group.Position = UDim2.new(if mirrored then 1 else 0, 0, 0, 0)

    side.portraitFrame.Size = UDim2.fromOffset(portraitSize, portraitSize)
    inset(side.recess, portraitInset)
    inset(side.backing, 2)
    for _, peg in side.pegs do
        peg.Size = UDim2.fromOffset(if compact then 3 else 6, if compact then 3 else 6)
    end

    local stem = portraitSize - overhang
    local barTop = if compact then 19 else 33
    local barHeight = if compact then 19 else 39
    side.bar.Position = UDim2.new(if mirrored then 1 else 0, if mirrored then -stem else stem, 0, barTop)
    side.bar.Size = UDim2.new(1, -stem, 0, barHeight)
    side.clasp.Visible = not compact
    side.clasp.Position = UDim2.new(if mirrored then 1 else 0, if mirrored then -stem - 7 else stem + 7, 0, barTop - 4)
    side.clasp.Size = UDim2.fromOffset(21, barHeight + 8)
    local bevels = if compact then {0, 1, 3, 4} else {0, 2, 5, 7}
    for index, layer in side.outlines do
        layoutBlade(layer, mirrored, barHeight, bevels[index])
    end
    local throatWidth = math.floor(barHeight / 2) - (if compact then 1 else 2)
    local gap = if compact then 5 else 8
    side.lip.Position = UDim2.fromOffset(if mirrored then throatWidth else gap, bevels[2])
    side.lip.Size = UDim2.new(1, -throatWidth - gap, 0, 1)
    side.health.track.Position = UDim2.fromOffset(if mirrored then throatWidth else gap, gap)
    side.health.track.Size = UDim2.new(1, -throatWidth - gap, 1, -gap * 2)
    side.health.amount.Position = if mirrored then UDim2.new(1, -55, 0, 0) else UDim2.fromOffset(22, 0)
    side.health.amount.Size = UDim2.new(0, 33, 1, 0)
    side.health.amount.TextSize = if compact then 9 else 13
    side.health.amount.Visible = not compact

    side.plaque.Position = UDim2.new(if mirrored then 1 else 0, if mirrored then -stem else stem, 0, if compact then 1 else 4)
    side.plaque.Size = UDim2.new(1, -stem - (if compact then 7 else 12), 0, barTop + 2 - side.plaque.Position.Y.Offset)
    side.health.caption.Position = UDim2.fromOffset(5, 0)
    side.health.caption.Size = UDim2.new(1, -10, 1, -1)
    side.titleLimit.MaxTextSize = if compact then 14 else 26
end

local function roundBadge(parent, name, colors, zIndex)
    local face = frame(parent, name, white, zIndex)
    face.AnchorPoint = Vector2.new(.5, .5)
    face.Position = UDim2.fromScale(.5, .5)
    corner(face, UDim.new(.5, 0))
    gradient(face, colors)
    return face
end

local function bell(parent)
    local case = roundBadge(parent, "Clock bronze", gilded, 11)
    keyline(case, dark, 2)
    local border = roundBadge(case, "Clock inset", carved, 12)
    keyline(border, lightGold, 1)
    local face = roundBadge(case, "Clock face", slate, 13)
    keyline(face, bronze, 1)
    local clock = label(face, "Clock", Enum.Font.GothamBlack, paper, 14)
    clock.Size = UDim2.fromScale(1, 1)
    clock.Text = "60"
    local wings = {}
    local fins = {}
    for index = 1, 2 do
        local anchor = if index == 1 then 0 else 1
        local wing = frame(case, "Bell finial", white, 10)
        wing.AnchorPoint = Vector2.new(.5, .5)
        wing.Position = UDim2.fromScale(anchor, .51)
        wing.Rotation = 45
        gradient(wing, gilded)
        keyline(wing, bronze, 1)
        wings[index] = wing
        local fin = frame(case, "Carved bell leaf", white, 10)
        fin.AnchorPoint = Vector2.new(.5, .5)
        fin.Position = UDim2.new(anchor, if index == 1 then -4 else 4, .39, 0)
        fin.Rotation = if index == 1 then -24 else 24
        corner(fin, UDim.new(.5, 0))
        gradient(fin, gilded)
        keyline(fin, bronze, 1)
        fins[index] = fin
    end
    return {case = case, border = border, face = face, clock = clock, wings = wings, fins = fins}
end

local function ribbon(parent, name, font, color)
    local result = frame(parent, name, white, 3)
    result.AnchorPoint = Vector2.new(.5, 0)
    gradient(result, lacquer)
    corner(result, UDim.new(0, 5))
    keyline(result, bronze, 1)
    local title = label(result, name, font, color, 4)
    inset(title, 2)
    return result, title
end

function Championship.new(parent, font, solo)
    local root = frame(parent, "ChampionshipHUD", nil, 2)
    root.AnchorPoint = Vector2.new(.5, 0)
    root.Visible = false
    local limit = make("UISizeConstraint", root, {})
    local left = fighter(root, false, font)
    local right = if solo then nil else fighter(root, true, font)
    local timer = bell(root)
    local titleFrame, title = ribbon(root, "Match mode", font, paper)
    title.TextScaled = true
    local modeLimit = make("UITextSizeConstraint", title, {MinTextSize = 9})
    local scoreFrame, score = ribbon(root, "Round score", font, paper)
    local hintFrame, hint = ribbon(root, "Round cue", font, paper)
    hintFrame.BackgroundTransparency = .12
    hintFrame.Visible = false
    hint:GetPropertyChangedSignal("Text"):Connect(function()
        hintFrame.Visible = hint.Text ~= ""
    end)
    local self = setmetatable({root = root, limit = limit, leftSide = left, rightSide = right,
        left = left.health, right = if right then right.health else nil, timer = timer, clock = timer.clock,
        titleFrame = titleFrame, title = title, modeLimit = modeLimit, scoreFrame = scoreFrame, score = score,
        hintFrame = hintFrame, hint = hint, solo = solo, leftPortrait = left.portrait,
        rightPortrait = if right then right.portrait else nil}, Championship)
    self:Layout(false, solo)
    return self
end

function Championship:Layout(compact, series, insetX)
    local heroHeight = if compact then 42 else 94
    local medal = if compact then 39 else 76
    local infoHeight = if compact then 16 else 20
    local cueHeight = if compact then 19 else 24
    local cueTop = heroHeight + infoHeight + 3
    local height = cueTop + cueHeight
    self.root.Position = UDim2.new(.5, 0, 0, if compact then 5 else 10)
    self.root.Size = UDim2.new(.96, -2 * (insetX or 0), 0, height)
    self.limit.MaxSize = Vector2.new(if compact then 620 else 1040, height)
    layoutFighter(self.leftSide, compact, heroHeight, medal / 2)
    if self.rightSide then
        layoutFighter(self.rightSide, compact, heroHeight, medal / 2)
    end

    local timer = self.timer
    timer.case.Position = UDim2.new(.5, 0, 0, if compact then heroHeight / 2 else 53)
    timer.case.Size = UDim2.fromOffset(medal, medal)
    timer.border.Size = UDim2.new(1, if compact then -6 else -8, 1, if compact then -6 else -8)
    timer.face.Size = UDim2.new(1, if compact then -10 else -14, 1, if compact then -10 else -14)
    for _, wing in timer.wings do
        wing.Size = UDim2.fromOffset(if compact then 9 else 17, if compact then 9 else 17)
    end
    for _, fin in timer.fins do
        fin.Visible = not compact
        fin.Size = UDim2.fromOffset(8, 24)
    end
    self.clock.TextSize = if compact then 18 else 37
    self.title.TextSize = if compact then 10 else 13
    self.modeLimit.MaxTextSize = self.title.TextSize
    self.score.TextSize = self.title.TextSize
    self.hint.TextSize = if compact then 11 else 14

    local titleWidth = if compact then 112 else 148
    local scoreWidth = if compact then 98 else 128
    self.scoreFrame.Visible = series == true
    self.score.Visible = series == true
    self.titleFrame.Size = UDim2.fromOffset(titleWidth, infoHeight)
    self.scoreFrame.Size = UDim2.fromOffset(scoreWidth, infoHeight)
    self.titleFrame.Position = UDim2.new(.5, if series then -(scoreWidth + 4) / 2 else 0, 0, heroHeight)
    self.scoreFrame.Position = UDim2.new(.5, (titleWidth + 4) / 2, 0, heroHeight)
    if self.solo then
        local spacing = if compact then 8 else 18
        local rightOffset = medal / 2 + spacing
        local top = if compact then 2 else 7
        self.titleFrame.AnchorPoint = Vector2.zero
        self.scoreFrame.AnchorPoint = Vector2.zero
        self.titleFrame.Position = UDim2.new(.5, rightOffset, 0, top)
        self.scoreFrame.Position = UDim2.new(.5, rightOffset, 0, top + infoHeight + 2)
        self.titleFrame.Size = UDim2.new(.5, -rightOffset, 0, infoHeight)
        self.scoreFrame.Size = self.titleFrame.Size
        cueTop = heroHeight + 3
    end
    self.hintFrame.Position = UDim2.new(.5, 0, 0, cueTop)
    self.hintFrame.Size = UDim2.new(1, 0, 0, cueHeight)
    self.hint.TextScaled = true
    if not self.hintLimit then
        self.hintLimit = make("UITextSizeConstraint", self.hint, {MinTextSize = 9})
    end
    self.hintLimit.MaxTextSize = self.hint.TextSize
    if not self.hintWidth then
        self.hintWidth = make("UISizeConstraint", self.hintFrame, {})
    end
    self.hintWidth.MaxSize = Vector2.new(if compact then 288 else 330, cueHeight)
end

return Championship
