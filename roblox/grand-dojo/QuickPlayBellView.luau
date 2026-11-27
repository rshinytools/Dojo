local Bell = require(script.Parent:WaitForChild("QuickPlayBell"))

local BellView = {}
BellView.__index = BellView

local PAPER = Color3.fromRGB(255, 244, 213)
local GOLD = Color3.fromRGB(255, 197, 102)
local PERFECT = Color3.fromRGB(154, 227, 187)
local COPPER = Color3.fromRGB(159, 101, 61)
local INK = Color3.fromRGB(30, 22, 29)

local FEEDBACK = {
    perfect = "Perfect",
    good = "Good strike",
    early = "Too early",
    late = "Too late",
    missed = "Missed beat",
}

local function make(className, parent, properties)
    local node = Instance.new(className)
    for property, value in properties do
        node[property] = value
    end
    node.Parent = parent
    return node
end

local function roundCorner(node, px)
    make("UICorner", node, {CornerRadius = UDim.new(0, px)})
end

local function text(parent, name, position, size)
    return make("TextLabel", parent, {
        Name = name,
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextColor3 = PAPER,
        TextSize = 15,
        Text = "",
    })
end

function BellView.mount(parent, onStrike)
    local root = make("Frame", parent, {
        Name = "BellTiming",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
    local score = text(root, "BellScore", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 19))
    local track = make("Frame", root, {
        Name = "BellTrack",
        Position = UDim2.fromOffset(0, 26),
        Size = UDim2.new(1, 0, 0, 21),
        BackgroundColor3 = INK,
        BorderSizePixel = 0,
    })
    roundCorner(track, 5)
    make("UIStroke", track, {Color = COPPER, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})

    local zone = make("Frame", track, {
        Name = "GoldWindow",
        BackgroundColor3 = GOLD,
        BorderSizePixel = 0,
        Visible = false,
    })
    roundCorner(zone, 3)
    make("Frame", zone, {
        Name = "PerfectCenterLine",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = INK,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    })
    local needle = make("Frame", track, {
        Name = "TimingNeedle",
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 4, 1, 6),
        BackgroundColor3 = PAPER,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 2,
    })
    roundCorner(needle, 2)
    make("UIStroke", needle, {Color = INK, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})

    local message = text(root, "BellFeedback", UDim2.fromOffset(0, 54), UDim2.new(1, 0, 0, 23))
    local button = make("TextButton", root, {
        Name = "Strike",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.new(0.62, 0, 0, 48),
        BackgroundColor3 = GOLD,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 19,
        TextColor3 = INK,
        Text = "Strike",
        Selectable = true,
    })
    roundCorner(button, 8)
    local view = setmetatable({
        root = root, score = score, zone = zone, needle = needle, message = message,
        button = button, onStrike = onStrike,
    }, BellView)
    button.Activated:Connect(function() view:strike() end)
    return view
end

function BellView:strike()
    if self.activeBeat and self.button.Active then
        self.button.Active = false
        self.sentBeat = self.activeBeat
        self.onStrike(self.activeBeat)
    end
end

function BellView:render(snapshot, now)
    local beat, progress, center, width = Bell.windowAt(snapshot.startedAt, now)
    self.activeBeat = beat
    self.needle.Visible = beat ~= nil
    self.zone.Visible = beat ~= nil
    if beat then
        self.zone.Position = UDim2.fromScale(center - width * 0.5, 0)
        self.zone.Size = UDim2.fromScale(width, 1)
        self.needle.Position = UDim2.new(progress, 0, 0, -3)
    end

    self.score.Text = string.format("%d / %d beats   ·   %d perfect", snapshot.score, Bell.BeatCount, snapshot.bonus)
    local feedback = if beat == snapshot.lastBeat then snapshot.feedback else nil
    self.message.TextColor3 = if feedback == "perfect" then PERFECT else PAPER
    if beat then
        self.message.Text = FEEDBACK[feedback] or "Strike when the marker reaches gold"
    elseif now - snapshot.startedAt >= Bell.Duration then
        self.message.Text = "Round complete"
    else
        self.message.Text = "Get ready"
    end

    self.button.Active = beat ~= nil and beat > math.max(self.sentBeat or 0, snapshot.lastBeat or 0)
    self.button.BackgroundColor3 = if self.button.Active then GOLD else COPPER
end

function BellView:destroy()
    self.root:Destroy()
end

return BellView
