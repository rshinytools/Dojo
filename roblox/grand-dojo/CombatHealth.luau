local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Health = {}
Health.__index = Health

local warm = Color3.fromRGB(255, 184, 92)
local cool = Color3.fromRGB(127, 226, 211)
local parchment = Color3.fromRGB(255, 242, 209)
local trackColor = Color3.fromRGB(22, 37, 41)
local critical = Color3.fromRGB(255, 163, 133)
local damageColor = Color3.fromRGB(255, 231, 168)
local white = Color3.fromRGB(255, 255, 255)
local black = Color3.fromRGB(0, 0, 0)
local normalDrain = TweenInfo.new(.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local chipDrain = TweenInfo.new(.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, .18)
local impactFade = TweenInfo.new(.23, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function make(class, parent, properties)
    local object = Instance.new(class)
    for property, value in properties do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function round(frame)
    make("UICorner", frame, {CornerRadius = UDim.new(0, 3)})
end

local function text(parent, name, initial, font, alignment, color)
    return make("TextLabel", parent, {
        Name = name, Text = initial, Font = font, TextSize = 14,
        TextXAlignment = alignment, TextColor3 = color, BackgroundTransparency = 1,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

function Health.new(parent, label, mirrored, font)
    local group = make("Frame", parent, {
        Name = label .. "Health", Size = UDim2.new(.5, -20, 1, 0), BackgroundTransparency = 1,
        Position = UDim2.new(if mirrored then .5 else 0, if mirrored then 6 else 14, 0, 0),
    })
    local tone = if mirrored then cool else warm
    local left, right = Enum.TextXAlignment.Left, Enum.TextXAlignment.Right
    local caption = text(group, "Fighter", label, font, if mirrored then right else left, parchment)
    local amount = text(group, "HP", "", font, if mirrored then left else right, tone)
    local track = make("Frame", group, {
        Name = "Track", BackgroundColor3 = trackColor, BorderSizePixel = 0, ClipsDescendants = true,
    })
    round(track)
    make("UIStroke", track, {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = tone:Lerp(black, .6), Thickness = 1,
    })

    local anchor = Vector2.new(if mirrored then 1 else 0, 0)
    local origin = UDim2.fromScale(anchor.X, 0)
    local chip = make("Frame", track, {
        Name = "RecentDamage", AnchorPoint = anchor, Position = origin, Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = damageColor, BorderSizePixel = 0, Visible = false, ZIndex = 2,
    })
    round(chip)
    local fill = make("Frame", track, {
        Name = "CurrentHealth", AnchorPoint = anchor, Position = origin, Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = white, BorderSizePixel = 0, ZIndex = 3, ClipsDescendants = true,
    })
    round(fill)
    make("UIGradient", fill, {Color = ColorSequence.new(tone:Lerp(white, .40), tone:Lerp(black, .23)), Rotation = 90})
    local edgeAnchor = Vector2.new(if mirrored then 0 else 1, 0)
    local edge = make("Frame", fill, {
        Name = "ImpactEdge", AnchorPoint = edgeAnchor, Position = UDim2.fromScale(edgeAnchor.X, 0),
        Size = UDim2.new(0, 5, 1, 0), BackgroundColor3 = parchment,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4,
    })

    return setmetatable({caption = caption, amount = amount, track = track, chip = chip, fill = fill,
        edge = edge, tone = tone, label = label, mirrored = mirrored, ratio = 1}, Health)
end

function Health:Layout(compact)
    local top, height = if compact then 22 else 31, if compact then 16 else 20
    local countWidth = if compact then 38 else 49
    self.caption.Position = UDim2.fromOffset(if self.mirrored then countWidth + 4 else 0, top)
    self.caption.Size = UDim2.new(1, -countWidth - 4, 0, height)
    self.caption.TextSize = if compact then 12 else 14
    self.amount.Position = if self.mirrored then UDim2.fromOffset(0, top) else UDim2.new(1, -countWidth, 0, top)
    self.amount.Size = UDim2.fromOffset(countWidth, height)
    self.amount.TextSize = if compact then 13 else 16
    self.track.Position = UDim2.fromOffset(0, if compact then 40 else 54)
    self.track.Size = UDim2.new(1, 0, 0, if compact then 9 else 13)
end

function Health:_cancelTweens()
    if self.fillTween then
        self.fillTween:Cancel()
        self.fillTween = nil
    end
    if self.chipTween then
        self.chipTween:Cancel()
        self.chipTween = nil
    end
    if self.edgeTween then
        self.edgeTween:Cancel()
        self.edgeTween = nil
    end
end

function Health:Snap()
    self:_cancelTweens()
    local target = UDim2.fromScale(self.ratio, 1)
    self.fill.Size, self.chip.Size = target, target
    self.chip.Visible = false
    self.edge.BackgroundTransparency = 1
end

function Health:Set(health, maxHealth, displayName, reset)
    if type(health) ~= "number" or type(maxHealth) ~= "number" or not (maxHealth > 0) or health ~= health then
        return
    end
    local confirmed = math.clamp(health, 0, maxHealth)
    local ratio = confirmed / maxHealth
    local name = displayName or self.label
    if name ~= self.displayedName then
        self.displayedName = name
        self.caption.Text = name
    end
    if confirmed ~= self.displayedHealth then
        self.displayedHealth = confirmed
        self.amount.Text = tostring(math.round(confirmed))
    end
    if not reset and self.ratio == ratio then
        return
    end

    local previous = self.ratio
    self.ratio = ratio
    self.amount.TextColor3 = if ratio <= .25 then critical else self.tone
    if reset or ratio > previous or GuiService.ReducedMotionEnabled or UserInputService.VREnabled then
        self:Snap()
        return
    end

    self:_cancelTweens()
    local target = UDim2.fromScale(ratio, 1)
    -- Preserve the visible end of the chip when another strike lands before it settles.
    self.chip.Size = UDim2.fromScale(math.max(previous, self.chip.Size.X.Scale, self.fill.Size.X.Scale), 1)
    self.chip.Visible = true
    self.edge.BackgroundTransparency = .12
    self.fillTween = TweenService:Create(self.fill, normalDrain, {Size = target})
    self.chipTween = TweenService:Create(self.chip, chipDrain, {Size = target})
    self.edgeTween = TweenService:Create(self.edge, impactFade, {BackgroundTransparency = 1})
    self.fillTween:Play()
    self.chipTween:Play()
    self.edgeTween:Play()
end

return Health
