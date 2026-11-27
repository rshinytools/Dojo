local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Catalog = require(ReplicatedStorage:WaitForChild("QuickPlayCatalog"))
local views = {
    bell = require(ReplicatedStorage:WaitForChild("QuickPlayBellView")),
    rush = require(ReplicatedStorage:WaitForChild("QuickPlayRushView")),
    rescue = require(ReplicatedStorage:WaitForChild("QuickPlayRescueView")),
}
local remote = ReplicatedStorage:WaitForChild("QuickPlay")
local palette = {
    panel = Color3.fromRGB(39, 28, 44),
    action = Color3.fromRGB(247, 191, 110),
    text = Color3.fromRGB(255, 235, 209),
    muted = Color3.fromRGB(218, 195, 179),
}

local function make(class, parent, properties)
    local object = Instance.new(class)
    for name, value in properties do object[name] = value end
    object.Parent = parent
    return object
end

local gui = make("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"), {
    Name = "FestivalQuickPlay", ResetOnSpawn = false, DisplayOrder = 31, Enabled = false,
})
local shade = make("Frame", gui, {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(), BackgroundTransparency = .42,
})
local panel = make("Frame", shade, {
    AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.new(.93, 0, .97, 0), BackgroundColor3 = palette.panel,
})
make("UISizeConstraint", panel, {MaxSize = Vector2.new(640, 450)})
make("UICorner", panel, {CornerRadius = UDim.new(0, 12)})
make("UIStroke", panel, {Color = Color3.fromRGB(160, 109, 71), Thickness = 1.5})

local function label(parent, name, size, color)
    return make("TextLabel", parent, {
        Name = name, BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        TextSize = size, TextColor3 = color, TextWrapped = true,
    })
end

local title = label(panel, "Title", 22, palette.text)
title.Position = UDim2.fromOffset(12, 2)
title.Size = UDim2.new(1, -116, 0, 40)
title.TextXAlignment = Enum.TextXAlignment.Left

local clock = label(panel, "Clock", 15, palette.action)
clock.Position = UDim2.new(1, -102, 0, 2)
clock.Size = UDim2.fromOffset(52, 40)

local function button(parent, name, color, textColor)
    local object = make("TextButton", parent, {
        Name = name, BackgroundColor3 = color, TextColor3 = textColor,
        Font = Enum.Font.GothamBold, TextSize = 16, Text = name,
    })
    make("UICorner", object, {CornerRadius = UDim.new(0, 8)})
    return object
end

local closeButton = button(panel, "×", Color3.fromRGB(99, 57, 59), palette.text)
closeButton.Position = UDim2.new(1, -47, 0, 4)
closeButton.Size = UDim2.fromOffset(44, 44)

local content = make("Frame", panel, {
    Name = "ActivityBoard", BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 44), Size = UDim2.new(1, -24, 1, -52),
})
local description = label(content, "Description", 19, palette.text)
description.Size = UDim2.new(1, 0, .55, -4)
description.TextYAlignment = Enum.TextYAlignment.Center

local best = label(content, "Best", 14, palette.muted)
best.Position = UDim2.fromScale(0, .55)
best.Size = UDim2.new(1, 0, .45, -48)

local go = button(content, "Start", palette.action, palette.panel)
go.AnchorPoint = Vector2.new(.5, 1)
go.Position = UDim2.new(.5, 0, 1, -2)
go.Size = UDim2.new(.78, 0, 0, 44)

local view, snapshot, id, nonce, phase, result
local savedSelection
local ACTION_CLOSE = "BeastDojoQuickPlayClose"
local ACTION_STRIKE = "BeastDojoQuickPlayStrike"

local function close()
    if nonce then remote:FireServer("close", nonce) end
    gui.Enabled = false
    if view then view:destroy() end
    view, snapshot, id, nonce, phase, result = nil, nil, nil, nil, nil, nil
    ContextActionService:UnbindAction(ACTION_CLOSE)
    ContextActionService:UnbindAction(ACTION_STRIKE)
    if savedSelection and savedSelection.Parent then GuiService.SelectedObject = savedSelection end
    savedSelection = nil
end

local function applyBest(record)
    local def = Catalog[id]
    best.Text = if record then string.format("Personal best · %d %s%s", record.score, def.unit,
        if def.maxBonus > 0 then string.format(" · %d %s", record.bonus, def.bonusUnit) else "")
        else "Personal best · —"
    if record and record.gold then best.Text ..= "\nKeepsake · " .. def.keepsake end
end

local function showSummary()
    if view then view:destroy(); view = nil end
    description.Visible, best.Visible, go.Visible = true, true, true
    if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then GuiService.SelectedObject = go end
    closeButton.NextSelectionDown = go
    go.NextSelectionUp = closeButton
end

local function requestStart()
    if (phase == "intro" or phase == "result") and go.Active then
        remote:FireServer("start", nonce)
    end
end

go.Activated:Connect(requestStart)
closeButton.Activated:Connect(close)

remote.OnClientEvent:Connect(function(kind, mode, token, data)
    if not Catalog[mode] then return end
    if kind == "intro" then
        if not gui.Enabled then savedSelection = GuiService.SelectedObject end
        id, nonce, phase = mode, token, kind
        gui.Enabled = true
        title.Text = Catalog[id].title
        clock.Text = string.format("%ds", Catalog[id].duration)
        showSummary()
        description.Text = Catalog[id].description
        applyBest(data)
        go.Text, go.Active = "Start", true
        ContextActionService:BindAction(ACTION_CLOSE, function(_, input)
            if input == Enum.UserInputState.Begin then close() end
            return Enum.ContextActionResult.Sink
        end, false, Enum.KeyCode.ButtonB)
    elseif id ~= mode or (kind ~= "round" and nonce ~= token) then
        return
    elseif kind == "round" then
        nonce, phase, snapshot = token, kind, data
        description.Visible, best.Visible, go.Visible = false, false, false
        if view then view:destroy() end
        view = views[id].mount(content, function(choice, index)
            if phase == "round" then remote:FireServer("input", nonce, choice, index) end
        end)
        if id == "bell" then
            closeButton.NextSelectionDown = view.button
            view.button.NextSelectionUp = closeButton
            if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
                GuiService.SelectedObject = view.button
            end
            ContextActionService:BindAction(ACTION_STRIKE, function(_, input)
                if view and phase == "round" and input == Enum.UserInputState.Begin then view:strike() end
                return Enum.ContextActionResult.Sink
            end, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonX)
        end
    elseif kind == "update" then
        snapshot = data
    elseif kind == "result" then
        phase, result, snapshot = kind, data, nil
        ContextActionService:UnbindAction(ACTION_STRIKE)
        showSummary()
        local def = Catalog[id]
        local bonus = if def.maxBonus > 0 then string.format(" · %d %s", result.bonus, def.bonusUnit) else ""
        description.Text = string.format("%s\n%d %s%s · %.1fs", result.medal, result.score, def.unit, bonus, result.tenths / 10)
        applyBest(result.best)
        if result.saving then best.Text ..= "\nSaving…" end
        if result.saveUnavailable then best.Text ..= "\nResult could not be saved." end
        go.Text, go.Active = if result.saving then "Saving…" else "Play again", not result.saving
    elseif kind == "saved" and phase == "result" then
        applyBest(data.best)
        if data.xp > 0 then best.Text ..= string.format(" · +%d XP saved", data.xp) end
        if data.firstGold then description.Text ..= "\nKeepsake earned!" end
        go.Text, go.Active = "Play again", true
    elseif kind == "blocked" then
        description.Text = "Stand by this activity’s station and finish any other activity first."
    elseif kind == "closed" then
        nonce = nil
        close()
    end
end)

RunService.RenderStepped:Connect(function()
    if not view or not snapshot or phase ~= "round" then return end
    local now = workspace:GetServerTimeNow()
    local startedAt = snapshot.startedAt or snapshot.startsAt
    clock.Text = if now < startedAt then "Ready" else string.format("%ds",
        math.max(0, math.ceil(startedAt + Catalog[id].duration - now)))
    view:render(snapshot, now)
end)
