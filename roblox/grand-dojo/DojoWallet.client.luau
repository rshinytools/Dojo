local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("DojoWallet")
local closeAction = "CloseDojoWallet"
local openAction = "OpenDojoWalletOnGamepad"
local defaultSashPrice = 50

local colors = {
    ink = Color3.fromRGB(24, 39, 41),
    card = Color3.fromRGB(34, 55, 54),
    seam = Color3.fromRGB(129, 107, 70),
    gold = Color3.fromRGB(246, 194, 104),
    paper = Color3.fromRGB(255, 242, 212),
    muted = Color3.fromRGB(190, 210, 200),
    jade = Color3.fromRGB(32, 115, 106),
    mint = Color3.fromRGB(174, 235, 206),
}

local function create(class, parent, properties)
    local instance = Instance.new(class)
    for property, value in properties do
        instance[property] = value
    end
    instance.Parent = parent
    return instance
end

local function edge(node, radius)
    create("UICorner", node, {CornerRadius = UDim.new(0, radius)})
    return create("UIStroke", node, {
        Color = colors.seam, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function label(parent, name, copy, size, tint, bold, position, bounds)
    return create("TextLabel", parent, {
        Name = name, Text = copy, TextSize = size, TextColor3 = tint, BackgroundTransparency = 1,
        Position = position, Size = bounds, TextXAlignment = Enum.TextXAlignment.Left,
        Font = if bold then Enum.Font.GothamBold else Enum.Font.GothamMedium, TextWrapped = true,
    })
end

local function button(parent, name, copy, position, bounds)
    local control = create("TextButton", parent, {
        Name = name, Text = copy, TextSize = 14, TextColor3 = colors.paper, Font = Enum.Font.GothamBold,
        Position = position, Size = bounds, BackgroundColor3 = colors.card, BorderSizePixel = 0,
        Selectable = true, TextWrapped = true,
    })
    local rim = edge(control, 8)
    control.SelectionGained:Connect(function() rim.Color, rim.Thickness = colors.paper, 2 end)
    control.SelectionLost:Connect(function() rim.Color, rim.Thickness = colors.seam, 1 end)
    return control
end

local screen = create("ScreenGui", playerGui, {
    Name = "DojoWallet", DisplayOrder = 24, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets, SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
})
local toggle = button(screen, "OpenWallet", "Wallet", UDim2.new(1, -120, 0, 44), UDim2.fromOffset(116, 44))
toggle.AnchorPoint = Vector2.new(1, 0)
toggle.TextSize, toggle.Visible = 13, false

local shade = create("Frame", screen, {
    Name = "WalletOverlay", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = .40, BorderSizePixel = 0, Active = true, Visible = false,
})
local panel = create("Frame", shade, {
    Name = "Wallet", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    BackgroundColor3 = colors.ink, BorderSizePixel = 0, Active = true, SelectionGroup = true,
    SelectionBehaviorUp = Enum.SelectionBehavior.Stop, SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
    SelectionBehaviorLeft = Enum.SelectionBehavior.Stop, SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
})
edge(panel, 14)
create("UISizeConstraint", panel, {MaxSize = Vector2.new(540, 428)})
label(panel, "Title", "Wallet", 24, colors.gold, true, UDim2.fromOffset(16, 9), UDim2.new(1, -115, 0, 44))
local close = button(panel, "CloseWallet", "Close", UDim2.new(1, -86, 0, 10), UDim2.fromOffset(74, 44))

local scroll = create("ScrollingFrame", panel, {
    Name = "WalletEntries", Position = UDim2.fromOffset(14, 62), Size = UDim2.new(1, -28, 1, -72),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollingDirection = Enum.ScrollingDirection.Y,
    AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.fromOffset(0, 0),
    ScrollBarThickness = 5, ScrollBarImageColor3 = colors.gold,
    VerticalScrollBarInset = Enum.ScrollBarInset.Always, ClipsDescendants = true, Selectable = false,
})
create("UIPadding", scroll, {PaddingBottom = UDim.new(0, 6), PaddingRight = UDim.new(0, 2)})
create("UIListLayout", scroll, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

local balances = create("Frame", scroll, {
    Name = "Balances", Size = UDim2.new(1, 0, 0, 62), LayoutOrder = 1, BackgroundTransparency = 1,
})
local values, captions = {}, {}
for index, entry in ipairs({
    {"DojoCoins", "Coins"}, {"RaidTokens", "Raid Tokens"}, {"MythicShards", "Mythic Shards"},
}) do
    local attribute, title = entry[1], entry[2]
    local x = (index - 1) / 3
    local tile = create("Frame", balances, {
        Name = attribute, Position = UDim2.new(x, if index > 1 then 3 else 0, 0, 0),
        Size = UDim2.new(1 / 3, if index == 3 then -3 else -5, 1, 0),
        BackgroundColor3 = colors.card, BorderSizePixel = 0,
    })
    edge(tile, 8)
    local caption = label(tile, "Caption", title, 11, colors.muted, true,
        UDim2.fromOffset(4, 6), UDim2.new(1, -8, 0, 24))
    caption.TextXAlignment = Enum.TextXAlignment.Center
    captions[attribute] = caption
    local number = label(tile, "Value", "—", 22, if index == 1 then colors.gold else colors.paper, true,
        UDim2.fromOffset(5, 25), UDim2.new(1, -10, 0, 28))
    number.TextXAlignment, number.TextScaled = Enum.TextXAlignment.Center, true
    create("UITextSizeConstraint", number, {MinTextSize = 10, MaxTextSize = 22})
    values[attribute] = number
end

local fighter = create("Frame", scroll, {
    Name = "FighterProgress", Size = UDim2.new(1, 0, 0, 54), LayoutOrder = 2,
    BackgroundColor3 = colors.card, BorderSizePixel = 0,
})
edge(fighter, 8)
local fighterCaption = label(fighter, "Caption", "Fighter progression", 12, colors.muted, true,
    UDim2.fromOffset(10, 3), UDim2.new(1, -20, 0, 19))
local xp = label(fighter, "Progress", "Loading XP…", 14, colors.paper, true,
    UDim2.fromOffset(10, 21), UDim2.new(1, -20, 0, 20))
local track = create("Frame", fighter, {
    Name = "XPTrack", Position = UDim2.fromOffset(10, 45), Size = UDim2.new(1, -20, 0, 3),
    BackgroundColor3 = colors.ink, BorderSizePixel = 0, ClipsDescendants = true,
})
local xpFill = create("Frame", track, {
    Name = "XPFill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = colors.gold, BorderSizePixel = 0,
})

local wardrobe = create("Frame", scroll, {
    Name = "Wardrobe", Size = UDim2.new(1, 0, 0, 142), LayoutOrder = 3,
    BackgroundColor3 = colors.card, BorderSizePixel = 0,
})
edge(wardrobe, 9)
local swatch = create("Frame", wardrobe, {
    Name = "SashPreview", Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(67, 66),
    BackgroundColor3 = colors.ink, BorderSizePixel = 0,
})
edge(swatch, 8)
local binding = create("Frame", swatch, {
    Position = UDim2.fromOffset(9, 18), Size = UDim2.fromOffset(49, 18), Rotation = -18,
    BackgroundColor3 = colors.gold, BorderSizePixel = 0,
})
create("Frame", binding, {
    Position = UDim2.fromOffset(0, 3), Size = UDim2.new(1, 0, 1, -6),
    BackgroundColor3 = colors.jade, BorderSizePixel = 0,
})
create("Frame", swatch, {
    Position = UDim2.fromOffset(41, 32), Size = UDim2.fromOffset(11, 22), Rotation = 17,
    BackgroundColor3 = colors.jade, BorderSizePixel = 0,
})
local clasp = create("Frame", swatch, {
    Position = UDim2.fromOffset(30, 21), Size = UDim2.fromOffset(13, 13), Rotation = 45,
    BackgroundColor3 = colors.mint, BorderSizePixel = 0,
})
create("UICorner", clasp, {CornerRadius = UDim.new(0, 2)})
local sashTitle = label(wardrobe, "Title", "Jade Festival Sash", 17, colors.paper, true,
    UDim2.fromOffset(90, 10), UDim2.new(1, -101, 0, 32))
local ownership = label(wardrobe, "Ownership", "Cosmetic sash", 13, colors.muted, false,
    UDim2.fromOffset(90, 39), UDim2.new(1, -101, 0, 35))
local action = button(wardrobe, "CosmeticAction", "Buy · 50 Coins",
    UDim2.new(0, 10, 1, -54), UDim2.new(1, -20, 0, 44))
close.NextSelectionDown, action.NextSelectionUp = action, close

local earnHint = "Earn Coins from first clears, your first sparring win, and district treasures."
local feedback = label(scroll, "WalletNotice", earnHint, 13, colors.muted, false,
    UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 42))
feedback.LayoutOrder = 4

local blockedAttributes = {
    "StarterSelectionRequired", "StarterSelectionPending", "FighterSelectOpen", "CityAdventureJournalOpen",
    "CityAdventureActive", "SkywalkTrialMode", "SparringActive", "DuelActive", "DuelQueued", "DuelTransferHold",
    "RingTrainingActive", "RingTrainingPending", "BrawlActive", "BrawlQueued", "BrawlRecapOpen",
    "TagTeamActive", "TagTeamQueued", "TagTeamOfferOpen", "TagTeamRecapOpen",
    "KilnbackRaidActive", "KilnbackRaidQueued", "KilnbackRaidRecapOpen", "RelayDeadline", "ParcelStage",
}
local conflictingPanels = {
    EventPanel = true, EagleEyeView = true, RelayStatus = true, SparringPicker = true,
    SparringResult = true, DuelFormatPicker = true, CloudbreakStatus = true,
}
local pending = false
local requestNumber = 0
local previousSelection

local function gamepad()
    return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad or UserInputService.VREnabled
end

local function available()
    if not player:GetAttribute("SelectedStarterFighter") then return false end
    for _, attribute in ipairs(blockedAttributes) do
        local value = player:GetAttribute(attribute)
        if value == true or type(value) == "number" and value > 0 or attribute == "SkywalkTrialMode" and value then
            return false
        end
    end
    local splash = playerGui:FindFirstChild("BeastDojoSplash")
    if splash and splash.Enabled then return false end
    local cityGui = playerGui:FindFirstChild("GrandDojo")
    if cityGui and cityGui.Enabled then
        for name in conflictingPanels do
            local node = cityGui:FindFirstChild(name)
            if node and node.Visible then return false end
        end
    end
    return true
end

local function whole(value)
    return if type(value) == "number" and value >= 0 and value < math.huge then math.floor(value) else nil
end

local function formatted(value)
    local text = string.format("%.0f", value):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (text:gsub("^,", ""))
end

local function coinChip(value)
    local amount = if value < 10000 then formatted(value)
        elseif value < 1000000 then string.format("%.1fK", value / 1000)
        elseif value < 1000000000 then string.format("%.1fM", value / 1000000)
        else string.format("%.1fB", value / 1000000000)
    return "Wallet · " .. amount .. " Coins"
end

local function readyToSpend()
    local status = player:GetAttribute("ProgressStatus")
    return status == "ready" or status == "saved"
end

local function sashPrice()
    local value = whole(player:GetAttribute("DojoMarketSashCost"))
    return if value and value > 0 then value else defaultSashPrice
end

local function render()
    local status = player:GetAttribute("ProgressStatus")
    local ready = status == "ready" or status == "saved" or status == "saving"
    local coins = whole(player:GetAttribute("DojoCoins"))
    toggle.Text = if ready and coins ~= nil then coinChip(coins) else "Wallet"
    for attribute, number in values do
        local value = whole(player:GetAttribute(attribute))
        number.Text = if ready and value ~= nil then formatted(value) else "—"
    end
    local snapshot = player:GetAttribute("FighterHudProgress")
    local levelText, xpText, goalText
    if type(snapshot) == "string" then
        levelText, xpText, goalText = snapshot:match("^(%d+):(%d+):(%d+)$")
    end
    local level, earned, goal = tonumber(levelText), tonumber(xpText), tonumber(goalText)
    if ready and level and earned and goal then
        xp.Text = if goal > 0 then ("Level %d  ·  %d / %d XP"):format(level, earned, goal)
            else ("Level %d  ·  Max level"):format(level)
        xpFill.Size = UDim2.fromScale(if goal > 0 then math.clamp(earned / goal, 0, 1) else 1, 1)
    else
        xp.Text = if status == "unavailable" then "XP unavailable" else "Loading XP…"
        xpFill.Size = UDim2.fromScale(0, 1)
    end

    local owned = player:GetAttribute("DojoMarketSashOwned") == true
    local equipped = player:GetAttribute("DojoMarketSashEquipped") == true
    ownership.Text = if equipped then "Cosmetic · Equipped" elseif owned then "Cosmetic · Owned" else "Cosmetic sash"
    local price = sashPrice()
    local canAfford = coins ~= nil and coins >= price
    local usable = readyToSpend() and not pending and (owned or canAfford)
    action.Text = if pending then "Saving…"
        elseif status == "unavailable" then "Wallet unavailable"
        elseif not readyToSpend() then (if ready then "Saving progress…" else "Loading wallet…")
        elseif equipped then "Remove sash"
        elseif owned then "Equip sash"
        elseif canAfford then ("Buy · %d Coins"):format(price)
        elseif coins ~= nil then ("%d Coins · %d more needed"):format(price, price - coins)
        else ("Buy · %d Coins"):format(price)
    action.Active, action.AutoButtonColor = usable, usable
    action.BackgroundColor3 = if usable then colors.jade else colors.ink
    action.TextColor3 = if usable then colors.paper else colors.muted
end

local function hide()
    if not shade.Visible then return end
    local picked = GuiService.SelectedObject
    shade.Visible, toggle.Visible = false, available()
    ContextActionService:UnbindAction(closeAction)
    if picked and picked:IsDescendantOf(shade) then
        GuiService.SelectedObject = if previousSelection and previousSelection.Parent and previousSelection.Visible
            then previousSelection else (if gamepad() and toggle.Visible then toggle else nil)
    end
    previousSelection = nil
end

local function show()
    if shade.Visible or not available() then return end
    previousSelection = GuiService.SelectedObject
    shade.Visible, toggle.Visible = true, false
    scroll.CanvasPosition = Vector2.zero
    if gamepad() then GuiService.SelectedObject = close end
    ContextActionService:BindActionAtPriority(closeAction, function(_, state)
        if state == Enum.UserInputState.Begin then hide() end
        return Enum.ContextActionResult.Sink
    end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)
    render()
end

local function reveal(node)
    local bottom = scroll.AbsolutePosition.Y + scroll.AbsoluteWindowSize.Y
    local excess = node.AbsolutePosition.Y + node.AbsoluteSize.Y + 4 - bottom
    if excess > 0 then
        local maxY = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
        scroll.CanvasPosition = Vector2.new(0, math.min(maxY, scroll.CanvasPosition.Y + excess))
    end
end

local function notice(message)
    feedback.Text = if message == "" then earnHint else message
    feedback.TextColor3 = if message == "" then colors.muted else colors.gold
    if message ~= "" and shade.Visible then
        task.defer(function()
            if shade.Visible then reveal(feedback) end
        end)
    end
end

action.Activated:Connect(function()
    if not shade.Visible or not available() or not readyToSpend() or pending then return end
    local owned = player:GetAttribute("DojoMarketSashOwned") == true
    local coins = whole(player:GetAttribute("DojoCoins"))
    if not owned and (coins == nil or coins < sashPrice()) then return end
    pending = true
    requestNumber += 1
    local request = requestNumber
    notice("")
    render()
    if owned then
        remote:FireServer("equip", player:GetAttribute("DojoMarketSashEquipped") ~= true)
    else
        remote:FireServer("buy")
    end
    task.delay(12, function()
        if not pending or request ~= requestNumber then return end
        pending = false
        notice("Saving is taking longer than usual. Check your wallet before trying again.")
        render()
    end)
end)
remote.OnClientEvent:Connect(function(message)
    if type(message) ~= "string" then return end
    pending = false
    notice(message)
    render()
end)

local function updateAvailability()
    if shade.Visible and not available() then hide() end
    toggle.Visible = available() and not shade.Visible
end
for _, attribute in ipairs(blockedAttributes) do
    player:GetAttributeChangedSignal(attribute):Connect(updateAvailability)
end
player:GetAttributeChangedSignal("SelectedStarterFighter"):Connect(updateAvailability)
for _, attribute in {"ProgressStatus", "FighterHudProgress", "DojoCoins", "RaidTokens", "MythicShards",
    "DojoMarketSashOwned", "DojoMarketSashEquipped", "DojoMarketSashCost"} do
    player:GetAttributeChangedSignal(attribute):Connect(render)
end

local function watchPanel(node)
    if node:IsA("ScreenGui") and node.Parent == playerGui and (node.Name == "GrandDojo" or node.Name == "BeastDojoSplash") then
        node:GetPropertyChangedSignal("Enabled"):Connect(updateAvailability)
    elseif node:IsA("GuiObject") and node.Parent and node.Parent.Name == "GrandDojo" and conflictingPanels[node.Name] then
        node:GetPropertyChangedSignal("Visible"):Connect(updateAvailability)
    else
        return
    end
    updateAvailability()
end
for _, node in ipairs(playerGui:GetDescendants()) do watchPanel(node) end
playerGui.DescendantAdded:Connect(watchPanel)
playerGui.ChildRemoved:Connect(function(node)
    if node.Name == "BeastDojoSplash" or node.Name == "GrandDojo" then updateAvailability() end
end)

local function layout()
    local size = screen.AbsoluteSize
    panel.Size = UDim2.fromOffset(math.max(1, size.X - 14), math.max(1, size.Y - 14))
    toggle.Size = UDim2.fromOffset(math.clamp(size.X - 148, 76, 116), 44)
    local narrowDesktop = size.X < 470 and not UserInputService.TouchEnabled
    toggle.Position = if narrowDesktop then UDim2.new(1, -8, 0, 165) else UDim2.new(1, -120, 0, 44)

    -- Landscape phones have room for a purchase button alongside the item, but little height to scroll.
    local compact = size.Y < 350 and size.X >= 470
    balances.Size = UDim2.new(1, 0, 0, if compact then 44 else 62)
    for attribute, number in values do
        captions[attribute].Position = UDim2.fromOffset(4, if compact then 2 else 6)
        captions[attribute].Size = UDim2.new(1, -8, 0, if compact then 16 else 24)
        number.Position = UDim2.fromOffset(5, if compact then 18 else 25)
        number.Size = UDim2.new(1, -10, 0, if compact then 22 else 28)
    end
    fighter.Size = UDim2.new(1, 0, 0, if compact then 33 else 54)
    fighterCaption.Visible = not compact
    xp.Position = UDim2.fromOffset(10, if compact then 4 else 21)
    track.Position = UDim2.fromOffset(10, if compact then 26 else 45)
    wardrobe.Size = UDim2.new(1, 0, 0, if compact then 86 else 142)
    sashTitle.Size = UDim2.new(1, if compact then -265 else -101, 0, 32)
    ownership.Size = UDim2.new(1, if compact then -265 else -101, 0, 35)
    action.Position = if compact then UDim2.new(1, -168, .5, -22) else UDim2.new(0, 10, 1, -54)
    action.Size = if compact then UDim2.fromOffset(156, 44) else UDim2.new(1, -20, 0, 44)
end
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
toggle.Activated:Connect(show)
close.Activated:Connect(hide)
player.CharacterRemoving:Connect(hide)
action.SelectionGained:Connect(function() reveal(action) end)
local function focusForDevice()
    if shade.Visible and gamepad() then
        local selected = GuiService.SelectedObject
        if not selected or not selected:IsDescendantOf(shade) then GuiService.SelectedObject = close end
    end
end
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(focusForDevice)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(focusForDevice)
UserInputService.InputBegan:Connect(function(input, consumed)
    if consumed or UserInputService:GetFocusedTextBox() then return end
    if shade.Visible and (input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.Backspace) then
        hide()
    elseif not shade.Visible and input.KeyCode == Enum.KeyCode.K then
        show()
    end
end)
ContextActionService:BindAction(openAction, function(_, state)
    if shade.Visible or GuiService.SelectedObject or not toggle.Visible then return Enum.ContextActionResult.Pass end
    if state == Enum.UserInputState.Begin then show() end
    return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.DPadDown)
screen.Destroying:Connect(function()
    ContextActionService:UnbindAction(openAction)
    ContextActionService:UnbindAction(closeAction)
end)

layout()
render()
updateAvailability()
