local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local RushView = {}
RushView.__index = RushView

local laneNames = {"Left", "Middle", "Right"}
local laneHints = {
    [Enum.PreferredInput.KeyboardAndMouse] = {"A", "S", "D"},
    [Enum.PreferredInput.Gamepad] = {"L1", "Y", "R1"},
}
local laneKeys = {
    [Enum.KeyCode.A] = 1, [Enum.KeyCode.S] = 2, [Enum.KeyCode.D] = 3,
    [Enum.KeyCode.ButtonL1] = 1, [Enum.KeyCode.ButtonY] = 2, [Enum.KeyCode.ButtonR1] = 3,
}
local cream = Color3.fromRGB(255, 235, 198)
local lit = Color3.fromRGB(156, 81, 36)
local teal = Color3.fromRGB(34, 111, 94)
local barred = Color3.fromRGB(74, 56, 75)
local muted = Color3.fromRGB(233, 211, 193)
local gold = Color3.fromRGB(250, 180, 78)
local aqua = Color3.fromRGB(107, 239, 196)

local function make(parent, className, properties)
    local object = Instance.new(className)
    for property, value in properties do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function corner(object, radius)
    make(object, "UICorner", {CornerRadius = UDim.new(0, radius)})
end

local function lettering(parent, position, size, minimum, maximum, color)
    local object = make(parent, "TextLabel", {
        Position = position, Size = size, BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextColor3 = color, TextScaled = true, Text = "",
    })
    make(object, "UITextSizeConstraint", {MinTextSize = minimum, MaxTextSize = maximum})
    return object
end

local function part(world, name, position, size, color, material)
    return make(world, "Part", {
        Name = name, Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false,
        Size = size, Position = position, Color = color, Material = material or Enum.Material.SmoothPlastic,
    })
end

local function buildTrack(parent)
    local scene = make(parent, "ViewportFrame", {
        Name = "LanternGatePreview", Size = UDim2.fromScale(1, .58),
        BackgroundColor3 = Color3.fromRGB(62, 35, 58),
        Ambient = Color3.fromRGB(168, 127, 138),
        LightColor = Color3.fromRGB(252, 183, 145),
        LightDirection = Vector3.new(-.35, -.85, -.5),
    })
    corner(scene, 9)
    make(scene, "UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(Color3.fromRGB(95, 47, 76), Color3.fromRGB(42, 28, 45)),
    })
    local world = make(scene, "WorldModel", {})
    local camera = make(scene, "Camera", {FieldOfView = 46})
    scene.CurrentCamera = camera
    local cedar = Color3.fromRGB(124, 41, 28)
    local slate = Color3.fromRGB(79, 73, 101)
    local path = Color3.fromRGB(145, 106, 113)
    local roof = Color3.fromRGB(42, 39, 78)
    local gates = {}
    part(world, "Long paving", Vector3.new(0, -.36, -9), Vector3.new(26, .65, 62), path)
    for index, x in ipairs({-7.4, 0, 7.4}) do
        local gate = {}
        for _, side in ipairs({-1, 1}) do
            local postX = x + side * 2.65
            part(world, "Cedar post", Vector3.new(postX, 2.6, -9), Vector3.new(.55, 5.2, .56), cedar)
            part(world, "Slate post foot", Vector3.new(postX, .35, -9), Vector3.new(.83, .7, .84), slate)
            part(world, "Lantern bracket", Vector3.new(postX, 4.02, -8.47), Vector3.new(.23, .18, .9), slate)
            local lamp = part(world, "Lane lantern", Vector3.new(postX, 3.48, -8.10), Vector3.new(.46, .74, .46), gold,
                Enum.Material.Neon)
            lamp.Shape = Enum.PartType.Ball
            table.insert(gate, lamp)
        end
        part(world, "Cedar transom", Vector3.new(x, 4.42, -9), Vector3.new(6.15, .29, .45), cedar)
        part(world, "Indigo crest", Vector3.new(x, 5.15, -9), Vector3.new(6.8, .51, .89), roof)
        part(world, "Vermilion lintel", Vector3.new(x, 4.80, -8.94), Vector3.new(6.4, .30, .68), cedar)
        local strip = part(world, "Lane threshold", Vector3.new(x, .02, -8.46), Vector3.new(4.55, .09, .48), gold,
            Enum.Material.Neon)
        table.insert(gate, strip)
        for _, z in ipairs({-2, 1.5, 5, 8.5}) do
            part(world, "Paving seam", Vector3.new(x, .003, z), Vector3.new(5.6, .025, .08), slate)
        end
        gates[index] = gate
    end
    for _, x in ipairs({-11.75, -3.7, 3.7, 11.75}) do
        part(world, "Slate lane border", Vector3.new(x, .1, -6), Vector3.new(.30, .25, 35), slate)
    end
    return camera, gates
end

function RushView.mount(parent, sendChoice)
    local root = make(parent, "Frame", {
        Name = "LanternRushView", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    })
    local self = setmetatable({
        root = root, sendChoice = sendChoice, buttons = {}, titles = {}, statuses = {}, outlines = {},
    }, RushView)
    self.camera, self.gates = buildTrack(root)
    local laneRow = make(root, "Frame", {
        Position = UDim2.fromScale(0, .61), Size = UDim2.fromScale(1, .31), BackgroundTransparency = 1,
    })
    make(laneRow, "UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(.02, 0),
    })
    for index, name in ipairs(laneNames) do
        local button = make(laneRow, "TextButton", {
            Name = name .. "Lane", LayoutOrder = index, Size = UDim2.fromScale(.316, 1),
            BackgroundColor3 = barred, Text = "", Selectable = true, AutoButtonColor = false,
        })
        corner(button, 8)
        self.buttons[index] = button
        self.outlines[index] = make(button, "UIStroke", {
            Color = muted, Transparency = .56, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1,
        })
        self.titles[index] = lettering(button, UDim2.fromScale(.06, .09), UDim2.fromScale(.88, .44), 12, 22, cream)
        self.statuses[index] = lettering(button, UDim2.fromScale(.04, .53), UDim2.fromScale(.92, .37), 10, 15, cream)
        button.Activated:Connect(function()
            self:choose(index)
        end)
    end
    for index, button in ipairs(self.buttons) do
        button.NextSelectionLeft = self.buttons[index - 1] or button
        button.NextSelectionRight = self.buttons[index + 1] or button
    end
    local track = make(root, "Frame", {
        Position = UDim2.fromScale(0, .951), Size = UDim2.fromScale(1, .028),
        BackgroundColor3 = Color3.fromRGB(76, 47, 66), BorderSizePixel = 0,
    })
    corner(track, 3)
    self.progress = make(track, "Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = gold, BorderSizePixel = 0})
    corner(self.progress, 3)
    self.keyboard = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and laneKeys[input.KeyCode] then
            self:choose(laneKeys[input.KeyCode])
        end
    end)
    local function updateHints()
        local hints = laneHints[UserInputService.PreferredInput]
        for index, title in ipairs(self.titles) do
            title.Text = if hints then laneNames[index] .. " · " .. hints[index] else laneNames[index]
        end
    end
    self.inputChanged = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateHints)
    updateHints()
    return self
end

function RushView:choose(lane)
    local state = self.state
    local now = workspace:GetServerTimeNow()
    if not state or now < state.openedAt or now >= state.advancesAt or state.chosenLane
        or self.sentFork == state.fork or not self.root.Visible then
        return
    end
    self.sentFork = state.fork
    self.sendChoice(lane, state.fork)
end

function RushView:render(state, now)
    if not self.state or self.state.startsAt ~= state.startsAt then
        self.sentFork = nil
        self.lastAppearance = nil
    end
    self.state = state
    local openShortcut = now < state.closesAt
    local elapsed = math.clamp((now - state.openedAt) / (state.advancesAt - state.openedAt), 0, 1)
    self.progress.Size = UDim2.fromScale(elapsed, 1)
    local motion = if UserInputService.VREnabled then 0 else elapsed
    local x = if state.chosenLane then (state.chosenLane - 2) * 4.9 * math.min(1, motion * 1.55) else 0
    self.camera.CFrame = CFrame.lookAt(Vector3.new(x, 6.4 - motion, 17 - motion * 8), Vector3.new(x * .48, 2.55, -9))
    local last = self.lastAppearance
    if last and last.fork == state.fork and last.shortcut == openShortcut and last.chosen == state.chosenLane then
        return
    end
    self.lastAppearance = {fork = state.fork, shortcut = openShortcut, chosen = state.chosenLane}
    for index, button in ipairs(self.buttons) do
        local safe = index == state.safeLane
        local shortcut = index == state.shortcutLane
        local chosen = index == state.chosenLane
        self.statuses[index].Text = if safe then "Lit path" elseif shortcut and openShortcut then "Shortcut"
            elseif shortcut then "Closed" else "Barred"
        button.BackgroundColor3 = if safe then lit elseif shortcut and openShortcut then teal else barred
        local accent = if safe then gold elseif shortcut and openShortcut then aqua
            else Color3.fromRGB(111, 83, 107)
        for _, lamp in ipairs(self.gates[index]) do
            lamp.Color = accent
            lamp.Material = if safe or (shortcut and openShortcut) then Enum.Material.Neon else Enum.Material.SmoothPlastic
        end
        self.outlines[index].Color = if chosen then cream else accent
        self.outlines[index].Thickness = if chosen then 3 else 1
        self.outlines[index].Transparency = if chosen then 0 else .26
    end
    local selected = GuiService.SelectedObject
    if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad and not selected then
        GuiService.SelectedObject = self.buttons[2]
    end
end

function RushView:destroy()
    if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.root) then
        GuiService.SelectedObject = nil
    end
    self.keyboard:Disconnect()
    self.inputChanged:Disconnect()
    self.root:Destroy()
end

return RushView
