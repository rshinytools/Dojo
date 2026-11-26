local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("DojoWallet")
local OutfitArt = require(ReplicatedStorage:WaitForChild("DojoOutfitArt"))
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

local shortcut = button(screen, "OutfittersShortcut", "Shop", UDim2.fromOffset(15, 146), UDim2.fromOffset(86, 44))
shortcut.BackgroundColor3, shortcut.Visible = colors.jade, false
shortcut.Text, shortcut.TextXAlignment = "    Shop", Enum.TextXAlignment.Center
local bag = create("Frame", shortcut, {
    Position = UDim2.fromOffset(11, 17), Size = UDim2.fromOffset(13, 11), BorderSizePixel = 0,
    BackgroundColor3 = colors.paper, Active = false,
})
edge(bag, 2).Color = colors.paper
local handle = create("Frame", bag, {
    Position = UDim2.fromOffset(3, -4), Size = UDim2.fromOffset(7, 5), BackgroundTransparency = 1,
})
edge(handle, 3).Color = colors.paper

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

local openShop = button(scroll, "OpenShop", "Shop apparel", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 44))
openShop.LayoutOrder, openShop.BackgroundColor3 = 3, colors.jade
close.NextSelectionDown, openShop.NextSelectionUp = openShop, close

local earnHint = "Earn Coins from first clears, your first sparring win, and district treasures."
local hint = label(scroll, "EarnCoins", earnHint, 13, colors.muted, false,
    UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 44))
hint.LayoutOrder = 4

local cedar = Color3.fromRGB(40, 24, 31)
local lacquer = Color3.fromRGB(56, 32, 39)
local brass = Color3.fromRGB(181, 127, 66)
local cream = Color3.fromRGB(255, 232, 191)
local parchment = Color3.fromRGB(221, 192, 168)
local fern = Color3.fromRGB(36, 108, 77)

local shop = create("Frame", shade, {
    Name = "Shop", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    BackgroundColor3 = cedar, BorderSizePixel = 0, Active = true, Visible = false, SelectionGroup = true,
    SelectionBehaviorUp = Enum.SelectionBehavior.Stop, SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
    SelectionBehaviorLeft = Enum.SelectionBehavior.Stop, SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
})
local shopRim = edge(shop, 15)
shopRim.Color, shopRim.Thickness = brass, 2
create("UISizeConstraint", shop, {MaxSize = Vector2.new(890, 490)})
local shopHeader = create("Frame", shop, {
    Name = "ShopHeader", Position = UDim2.fromOffset(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
})
create("UICorner", shopHeader, {CornerRadius = UDim.new(0, 14)})
create("UIGradient", shopHeader, {
    Color = ColorSequence.new(Color3.fromRGB(103, 49, 37), Color3.fromRGB(52, 25, 39)), Rotation = 12,
})
local district = label(shopHeader, "District", "REED MARKET", 11, colors.gold, true,
    UDim2.fromOffset(20, 9), UDim2.fromOffset(110, 15))
local shopTitle = label(shopHeader, "Title", "Dojo Outfitters", 38, cream, true, UDim2.new(), UDim2.new())
shopTitle.Font = Enum.Font.Garamond
local walletBack = button(shop, "OpenWalletFromShop", "Wallet", UDim2.new(), UDim2.new())
local shopClose = button(shop, "CloseShop", "Close", UDim2.new(), UDim2.new())

local tabs = create("Frame", shop, {Name = "Categories", BackgroundTransparency = 1})
local categoryNames = {"Robux cosmetics", "Earned with Coins", "My closet"}
local categoryKeys = {"robux", "coins", "closet"}
local tabButtons = {}
for index, key in ipairs(categoryKeys) do
    local tab = button(tabs, key, categoryNames[index], UDim2.new((index - 1) / 3, 0, 0, 0),
        UDim2.new(1 / 3, if index == 3 then 0 else -5, 1, 0))
    tabButtons[key] = tab
    if index > 1 then
        tab.NextSelectionLeft = tabButtons[categoryKeys[index - 1]]
        tab.NextSelectionLeft.NextSelectionRight = tab
    end
    tab.NextSelectionUp = walletBack
end
walletBack.NextSelectionRight, shopClose.NextSelectionLeft = shopClose, walletBack
walletBack.NextSelectionDown, shopClose.NextSelectionDown = tabButtons.robux, tabButtons.closet

local shopScroll = create("ScrollingFrame", shop, {
    Name = "ShopEntries", BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollingDirection = Enum.ScrollingDirection.Y, AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(), ScrollBarThickness = 4, ScrollBarImageColor3 = colors.gold,
    VerticalScrollBarInset = Enum.ScrollBarInset.Always, ClipsDescendants = true, Selectable = false,
})
local product = create("Frame", shopScroll, {Name = "Product", BackgroundTransparency = 1})
local previewTile = create("Frame", product, {
    Name = "Preview", BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ClipsDescendants = true,
})
edge(previewTile, 11).Color = brass
create("UIGradient", previewTile, {
    Rotation = 104, Color = ColorSequence.new(Color3.fromRGB(118, 65, 48), Color3.fromRGB(35, 27, 46)),
})
local portrait = create("ViewportFrame", previewTile, {
    Name = "Reedguard", Position = UDim2.new(.24, 0, 0, 0), Size = UDim2.new(.76, 0, 1, 0),
    BackgroundTransparency = 1, Ambient = Color3.fromRGB(168, 148, 154),
    LightColor = Color3.fromRGB(255, 230, 182), LightDirection = Vector3.new(-.8, -1, -.9),
})
local portraitCamera = create("Camera", portrait, {FieldOfView = 34})
portrait.CurrentCamera = portraitCamera
local portraitModel
local wornPreview
local previewing = true
local function refreshPortrait(bundle, visible)
    if not portraitModel or not portraitModel:FindFirstChild("Torso") then return end
    if wornPreview then
        wornPreview:Destroy()
        wornPreview = nil
    end
    if not visible then return end
    local torso = portraitModel.Torso
    local center, width, height, front = OutfitArt.fit(torso, torso.CFrame)
    wornPreview = create("Model", portrait, {Name = "PreviewOutfit"})
    local function piece(name, frame, size, color, material)
        create("Part", wornPreview, {
            Name = name, CFrame = frame, Size = size, Color = color, Material = material,
            Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
        })
    end
    local buildOutfit = if bundle then OutfitArt.build else OutfitArt.buildJade
    buildOutfit(piece, center, width, height, front)
end

local function mountPortrait()
    if portraitModel then return end
    local library = ReplicatedStorage:FindFirstChild("StarterFighterVisuals")
    local sample = library and library:FindFirstChild("reedguard-kangaroo")
    if not (sample and sample:IsA("Model")) then return end
    portraitModel = sample:Clone()
    portraitModel.Parent = portrait
    local box, size = portraitModel:GetBoundingBox()
    local aim = box.Position + Vector3.new(0, size.Y * .02, 0)
    portraitCamera.CFrame = CFrame.lookAt(aim + Vector3.new(-.42, .14, -1.92) * size.Y, aim)
end

local previewMode = button(previewTile, "PreviewMode", "Without outfit", UDim2.fromOffset(8, 8), UDim2.fromOffset(123, 44))
previewMode.BackgroundColor3, previewMode.TextSize = lacquer, 12
local portraitBundle, portraitVisible
local function syncPortrait(bundle, empty)
    previewMode.Text = if previewing then "Without outfit" else "With outfit"
    local showOutfit = previewing and not empty and portraitModel ~= nil
    if bundle ~= portraitBundle or showOutfit ~= portraitVisible then
        portraitBundle, portraitVisible = bundle, showOutfit
        refreshPortrait(bundle, showOutfit)
    end
end

local productStand = create("Frame", previewTile, {
    Name = "ItemStand", BackgroundColor3 = cedar, BackgroundTransparency = .15, BorderSizePixel = 0,
    Position = UDim2.new(0, 8, .50, 0), Size = UDim2.new(.39, 0, .45, 0),
})
edge(productStand, 8).Color = brass
local preview = create("ViewportFrame", productStand, {
    Name = "SashPreview", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
    Ambient = Color3.fromRGB(180, 187, 173), LightColor = Color3.fromRGB(255, 235, 196),
    LightDirection = Vector3.new(-.8, -1, -.9),
})
local bundlePreview = preview:Clone()
bundlePreview.Name, bundlePreview.Visible, bundlePreview.Parent = "MidnightPreview", false, productStand
local closetChoices = create("Frame", product, {Name = "OwnedOutfits", BackgroundTransparency = 1, Visible = false})
local jadeChoice = button(closetChoices, "JadeSashTab", "Jade Sash", UDim2.fromOffset(0, 0), UDim2.new(.50, -3, 1, 0))
local bundleChoice = button(closetChoices, "MidnightSetTab", "Midnight Set", UDim2.new(.50, 3, 0, 0),
    UDim2.new(.50, -3, 1, 0))
jadeChoice.NextSelectionRight, bundleChoice.NextSelectionLeft = bundleChoice, jadeChoice
local previewCamera = create("Camera", preview, {
    CFrame = CFrame.lookAt(Vector3.new(-.63, .49, -2.56), Vector3.new(0, -.22, 0)),
    FieldOfView = 35,
})
preview.CurrentCamera = previewCamera
local bundleCamera = create("Camera", bundlePreview, {
    CFrame = CFrame.lookAt(Vector3.new(-.31, .50, -3.56), Vector3.new(0, -.06, 0)),
    FieldOfView = 27,
})
bundlePreview.CurrentCamera = bundleCamera

-- A display-only replica of the server-authored Jade Festival Sash on a wooden stand.
local cloth, trim, clasp = Color3.fromRGB(41, 113, 91), Color3.fromRGB(224, 177, 95), Color3.fromRGB(145, 228, 184)
local fabric = Enum.Material.Fabric
local function displayPart(name, size, frame, color, material, shape, parent)
    create("Part", parent or preview, {
        Name = name, Size = size, CFrame = frame, Color = color, Material = material,
        Shape = shape or Enum.PartType.Block, Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false,
    })
end
local upright = CFrame.Angles(0, 0, math.pi / 2)
displayPart("Display base", Vector3.new(.14, 1.30, 1.30), CFrame.new(0, -.66, .12) * upright,
    Color3.fromRGB(75, 50, 30), Enum.Material.Wood, Enum.PartType.Cylinder)
displayPart("Display rim", Vector3.new(.035, 1.24, 1.24), CFrame.new(0, -.572, .12) * upright,
    trim, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
displayPart("Display top", Vector3.new(.03, 1.18, 1.18), CFrame.new(0, -.54, .12) * upright,
    Color3.fromRGB(106, 75, 46), Enum.Material.Wood, Enum.PartType.Cylinder)
displayPart("Display support", Vector3.new(.12, .54, .16), CFrame.new(0, -.25, .07),
    Color3.fromRGB(106, 75, 46), Enum.Material.Wood)
local sashWidth = 1.04
local wrap = CFrame.Angles(0, 0, .10)
displayPart("Woven gold edge", Vector3.new(sashWidth + .07, .24, .09), wrap, trim, fabric)
displayPart("Jade waist wrap", Vector3.new(sashWidth, .17, .07), wrap * CFrame.new(0, 0, -.042), cloth, fabric)
local fold = wrap * CFrame.new(sashWidth * .27, -.19, -.047) * CFrame.Angles(0, 0, .18)
displayPart("Silk fold", Vector3.new(.24, .46, .08), fold, cloth, fabric)
displayPart("Mint embroidery", Vector3.new(.20, .066, .03), fold * CFrame.new(0, -.145, -.044), clasp, fabric)
displayPart("Jade clasp", Vector3.new(.17, .17, .08),
    wrap * CFrame.new(sashWidth * .27, 0, -.08) * CFrame.Angles(0, 0, math.pi / 4), clasp, Enum.Material.SmoothPlastic)

displayPart("Bundle pedestal", Vector3.new(.12, 1.58, 1.58), CFrame.new(0, -.69, .13) * upright,
    Color3.fromRGB(31, 28, 44), Enum.Material.Wood, Enum.PartType.Cylinder, bundlePreview)
displayPart("Pedestal gold rim", Vector3.new(.035, 1.53, 1.53), CFrame.new(0, -.62, .13) * upright,
    trim, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder, bundlePreview)
displayPart("Tailor's display", Vector3.new(.83, 1.16, .37), CFrame.new(.32, -.04, .13),
    Color3.fromRGB(105, 100, 108), Enum.Material.SmoothPlastic, nil, bundlePreview)
OutfitArt.build(function(name, frame, size, color, material)
    displayPart(name, size, frame, color, material, nil, bundlePreview)
end, Vector3.new(.32, .02, 0), .55, .73, -.14)

local details = create("Frame", product, {
    Name = "Details", BackgroundColor3 = lacquer, BorderSizePixel = 0,
})
edge(details, 11).Color = brass
local title = label(details, "Title", "", 38, cream, true, UDim2.new(), UDim2.new())
title.Font = Enum.Font.Garamond
local ownership = label(details, "Ownership", "", 12, colors.gold, true, UDim2.new(), UDim2.new())
local description = label(details, "Description", "", 14, parchment, false, UDim2.new(), UDim2.new())
local priceDisplay = label(details, "Price", "", 17, cream, true, UDim2.new(), UDim2.new())
local action = button(details, "CosmeticAction", "", UDim2.new(), UDim2.new())
local feedback = label(details, "ShopNotice", "", 12, colors.gold, false, UDim2.new(), UDim2.new())
for _, control in {walletBack, shopClose, jadeChoice, bundleChoice} do
    control.BackgroundColor3 = lacquer
end
jadeChoice.NextSelectionDown, bundleChoice.NextSelectionDown = action, action
jadeChoice.NextSelectionUp, bundleChoice.NextSelectionUp = tabButtons.closet, tabButtons.closet

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
local category = "robux"
local closetOffer = "midnight"
local bundleSelected = true
local bundleSaving = false
local bundleRequest = 0
local bundlePrice, priceState = nil, "unlisted"
local priceRequest = 0
local jadeNotice, bundleNotice = "", ""
local requestNumber = 0
local previousSelection
local shopFromWallet = false

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

    walletBack.Text = if ready and coins ~= nil then coinChip(coins) else "Wallet"
    local jadeOwned = player:GetAttribute("DojoMarketSashOwned") == true
    local entitlement = player:GetAttribute("DojoBundleOwnership")
    local bundleOwned = entitlement == "owned"
    local inCloset = category == "closet"
    local closetLoaded = ready and (entitlement == "owned" or entitlement == "locked")
    local empty = inCloset and not (jadeOwned or bundleOwned)
    if inCloset and jadeOwned ~= bundleOwned then closetOffer = if jadeOwned then "jade" else "midnight" end
    bundleSelected = category == "robux" or (inCloset and closetOffer == "midnight")
    for key, tab in tabButtons do
        tab.BackgroundColor3 = if category == key then fern else lacquer
        tab.TextColor3 = if category == key then colors.paper else parchment
    end
    closetChoices.Visible, jadeChoice.Visible, bundleChoice.Visible = inCloset and jadeOwned and bundleOwned, jadeOwned, bundleOwned
    jadeChoice.BackgroundColor3 = if closetOffer == "jade" then fern else lacquer
    bundleChoice.BackgroundColor3 = if closetOffer == "midnight" then fern else lacquer
    previewTile.Visible = not empty
    syncPortrait(bundleSelected, empty)
    preview.Visible, bundlePreview.Visible = not bundleSelected, bundleSelected
    details:SetAttribute("ClosetEmpty", empty)
    product:SetAttribute("HasClosetChoices", closetChoices.Visible)
    action.Visible, priceDisplay.Visible = not empty, not empty
    local nextProduct = if closetChoices.Visible then (if bundleSelected then bundleChoice else jadeChoice) else previewMode
    for _, tab in tabButtons do tab.NextSelectionDown = nextProduct end
    jadeChoice.NextSelectionDown, bundleChoice.NextSelectionDown = previewMode, previewMode
    action.NextSelectionUp = previewMode
    action.NextSelectionLeft = if not empty then previewMode else nil
    previewMode.NextSelectionRight = action
    previewMode.NextSelectionUp = if closetChoices.Visible then nextProduct else tabButtons[category]

    local usable = false
    if empty then
        title.Text = if closetLoaded then "Your closet is empty" else "My closet"
        ownership.Text = "OWNED OUTFITS"
        description.Text = if closetLoaded then "Collect apparel in either shop tab to see it here."
            elseif status == "unavailable" or entitlement == "unknown" and ready
                then "Outfit ownership could not be verified. Reopen Outfitters to retry."
            else "Checking your outfits…"
        feedback.Text = ""
    elseif bundleSelected then
        local worn = bundleOwned and player:GetAttribute("DojoBundleSelected") == true
        local listed = priceState == "ready"
        title.Text = "Midnight Lantern Set"
        description.Text = "Indigo shoulder mantle and bronze lantern charm."
        ownership.Text = if worn then "EQUIPPED" elseif bundleOwned then "OWNED" else "PERMANENT COSMETIC"
        priceDisplay.Text = if bundleOwned then "Yours to wear" elseif listed then ("%s Robux"):format(formatted(bundlePrice))
            elseif priceState == "loading" then "Checking Roblox…" elseif priceState == "error" then "Price unavailable"
            else "Off sale"
        usable = not bundleSaving and (bundleOwned and readyToSpend() or listed and entitlement == "locked")
        action.Text = if bundleSaving then "Saving…" elseif bundleOwned and not readyToSpend() then "Waiting for save…"
            elseif worn then "Remove set" elseif bundleOwned then "Equip set"
            elseif listed and entitlement ~= "locked" then "Checking ownership…" elseif listed then "Open Roblox Shop"
            elseif priceState == "loading" then "Checking availability…" else "Unavailable for purchase"
        feedback.Text = bundleNotice
    else
        local equipped = player:GetAttribute("DojoMarketSashEquipped") == true
        local price = sashPrice()
        local canAfford = coins ~= nil and coins >= price
        title.Text = "Jade Festival Sash"
        description.Text = "Jade fabric with woven gold trim and a mint clasp."
        ownership.Text = if equipped then "EQUIPPED" elseif jadeOwned then "OWNED" else "PERMANENT COSMETIC"
        priceDisplay.Text = if jadeOwned then "Yours to wear" else ("%d Coins"):format(price)
        usable = readyToSpend() and not pending and (jadeOwned or canAfford)
        action.Text = if pending then "Saving…" elseif status == "unavailable" then "Wallet unavailable"
            elseif not readyToSpend() then (if ready then "Saving progress…" else "Loading wallet…")
            elseif equipped then "Remove sash" elseif jadeOwned then "Equip sash"
            elseif canAfford then ("Buy · %d Coins"):format(price)
            elseif coins ~= nil then ("%d more Coins needed"):format(price - coins) else "Loading Coins…"
        feedback.Text = jadeNotice
    end
    action.Active, action.Selectable, action.AutoButtonColor = usable, usable, usable
    action.BackgroundColor3 = if usable then fern else cedar
    action.TextColor3 = if usable then colors.paper else parchment
end

local function refreshPrice()
    priceRequest += 1
    bundlePrice = nil
    local passId = whole(remote:GetAttribute("BundlePassId"))
    if not passId or passId == 0 then
        priceState = "unlisted"
        render()
        return
    end
    priceState = "loading"
    render()
    local request = priceRequest
    task.spawn(function()
        local ok, info = pcall(MarketplaceService.GetProductInfoAsync, MarketplaceService, passId, Enum.InfoType.GamePass)
        if request ~= priceRequest then return end
        local hasInfo = ok and type(info) == "table"
        if hasInfo and info.IsForSale == true then
            local price = whole(info.PriceInRobux)
            if price and price > 0 then bundlePrice = price end
        end
        priceState = if bundlePrice then "ready" elseif not hasInfo or info.IsForSale then "error" else "unlisted"
        render()
    end)
end

local function hide()
    if not shade.Visible then return end
    local picked = GuiService.SelectedObject
    shade.Visible = false
    toggle.Visible, shortcut.Visible = available(), available()
    ContextActionService:UnbindAction(closeAction)
    if picked and picked:IsDescendantOf(shade) then
        GuiService.SelectedObject = if previousSelection and previousSelection.Parent and previousSelection.Visible
            then previousSelection else (if gamepad() and toggle.Visible then toggle else nil)
    end
    previousSelection = nil
end

local function setView(shopVisible)
    category, previewing = "robux", true
    shade.BackgroundTransparency = if shopVisible then .73 else .40
    panel.Visible, shop.Visible = not shopVisible, shopVisible
    scroll.CanvasPosition, shopScroll.CanvasPosition = Vector2.zero, Vector2.zero
    if gamepad() then GuiService.SelectedObject = if shopVisible then shopClose else openShop end
    if shopVisible then
        mountPortrait()
        remote:FireServer("bundleRefresh")
        refreshPrice()
    else
        render()
    end
end

local function goBack()
    if shop.Visible and shopFromWallet then
        setView(false)
    else
        hide()
    end
end

local function show(shopVisible, fromWallet)
    if not available() then return end
    if not shade.Visible then
        previousSelection = GuiService.SelectedObject
        shade.Visible, toggle.Visible, shortcut.Visible = true, false, false
        ContextActionService:BindActionAtPriority(closeAction, function(_, state)
            if state == Enum.UserInputState.Begin then goBack() end
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)
    end
    shopFromWallet = shopVisible and fromWallet == true
    setView(shopVisible)
end

local function revealShop(node)
    local bottom = shopScroll.AbsolutePosition.Y + shopScroll.AbsoluteWindowSize.Y
    local excess = node.AbsolutePosition.Y + node.AbsoluteSize.Y + 4 - bottom
    if excess > 0 then
        local maxY = math.max(0, shopScroll.AbsoluteCanvasSize.Y - shopScroll.AbsoluteWindowSize.Y)
        shopScroll.CanvasPosition = Vector2.new(0, math.min(maxY, shopScroll.CanvasPosition.Y + excess))
    end
end

local function notice(message)
    jadeNotice = message
    if not bundleSelected then feedback.Text = message end
    if message ~= "" and shade.Visible and shop.Visible then
        task.defer(function()
            if shade.Visible and shop.Visible then revealShop(feedback) end
        end)
    end
end

action.Activated:Connect(function()
    if not shade.Visible or not shop.Visible or not available() or not action.Active then return end
    if bundleSelected then
        if not action.Active or bundleSaving then return end
        bundleNotice = ""
        if player:GetAttribute("DojoBundleOwnership") == "owned" then
            bundleSaving = true
            bundleRequest += 1
            local request = bundleRequest
            remote:FireServer("bundleEquip", player:GetAttribute("DojoBundleSelected") ~= true)
            task.delay(12, function()
                if request ~= bundleRequest or not bundleSaving then return end
                bundleSaving = false
                bundleNotice = "Saving is taking longer than usual. Check your outfit before retrying."
                render()
            end)
        else
            local ok = pcall(MarketplaceService.OpenShop, MarketplaceService, player)
            if ok then
                hide()
            else
                bundleNotice = "Roblox Shop is unavailable. Try again in a moment."
            end
        end
        render()
        return
    end
    if pending then return end
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
remote.OnClientEvent:Connect(function(message, open)
    if message == "openShop" then
        if open == true then show(true, false) end
        return
    end
    if message == "bundleNotice" then
        bundleSaving = false
        bundleNotice = if type(open) == "string" then open else ""
        render()
        return
    end
    if type(message) ~= "string" then return end
    pending = false
    notice(message)
    render()
end)

local function updateAvailability()
    if shade.Visible and not available() then hide() end
    local visible = available() and not shade.Visible
    toggle.Visible, shortcut.Visible = visible, visible
end
for _, attribute in ipairs(blockedAttributes) do
    player:GetAttributeChangedSignal(attribute):Connect(updateAvailability)
end
player:GetAttributeChangedSignal("SelectedStarterFighter"):Connect(updateAvailability)
for _, attribute in {"ProgressStatus", "FighterHudProgress", "DojoCoins", "RaidTokens", "MythicShards",
    "DojoMarketSashOwned", "DojoMarketSashEquipped", "DojoMarketSashCost",
    "DojoBundleOwnership", "DojoBundleSelected"} do
    player:GetAttributeChangedSignal(attribute):Connect(render)
end
remote:GetAttributeChangedSignal("BundlePassId"):Connect(function()
    if shop.Visible and shade.Visible and category == "robux" then refreshPrice() end
end)

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

    local compact = size.Y < 355
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
    local wide = size.X >= 980
    local width = math.max(1, if wide then math.min(890, math.floor(size.X * .72)) else size.X - 16)
    local height = math.max(1, math.min(490, size.Y - 16))
    shop.AnchorPoint = Vector2.new(if wide then 1 else .5, .5)
    shop.Position = if wide then UDim2.new(1, -28, .5, 0) else UDim2.fromScale(.5, .5)
    shop.Size = UDim2.fromOffset(width, height)
    local touch = UserInputService.TouchEnabled
    shortcut.Size = UDim2.fromOffset(if touch then 75 else 86, 44)
    shortcut.Position = if touch then UDim2.fromOffset(8, if compact then 54 else 82)
        else UDim2.fromOffset(16, if compact then 65 else 178)

    local stacked = width < 460
    local small = compact or stacked
    local headerHeight = if compact then 49 elseif stacked then 64 else 72
    local inset = if small then 10 else 18
    shopHeader.Size = UDim2.new(1, -2, 0, headerHeight)
    district.Position = UDim2.fromOffset(inset, if compact then 4 else 8)
    shopTitle.Position = UDim2.fromOffset(inset, if compact then 15 else 22)
    shopTitle.Size = UDim2.new(1, if stacked then -165 else -225, 0, if compact then 29 else 44)
    shopTitle.TextSize = if stacked then 23 elseif compact then 28 else 38
    local walletWidth, closeWidth = if stacked then 88 else 125, if stacked then 47 else 62
    shopClose.Position = UDim2.new(1, -closeWidth - inset, 0, (headerHeight - 44) / 2)
    shopClose.Size = UDim2.fromOffset(closeWidth, 44)
    walletBack.Position = UDim2.new(1, -walletWidth - closeWidth - inset - 6, 0, (headerHeight - 44) / 2)
    walletBack.Size = UDim2.fromOffset(walletWidth, 44)
    walletBack.TextSize = if stacked then 11 else 13
    tabs.Position, tabs.Size = UDim2.fromOffset(inset, headerHeight + 6), UDim2.new(1, -inset * 2, 0, 44)
    for _, tab in tabButtons do tab.TextSize = if stacked then 12 else 14 end
    local top = headerHeight + (if compact then 54 else 58)
    local hasChoices = product:GetAttribute("HasClosetChoices") == true
    local empty = details:GetAttribute("ClosetEmpty") == true
    local footer = not empty and (stacked or compact and (height - top < 154 or hasChoices))
    local inlineCompact = compact and not footer
    shopScroll.Position = UDim2.fromOffset(inset, top)
    shopScroll.Size = UDim2.new(1, -inset * 2, 1, -top - (if footer then 61 else 9))
    local offset = if hasChoices then 50 else 0
    local detailHeight = if inlineCompact then (if feedback.Text == "" then 145 else 176)
        elseif small then 193 else math.max(255, height - top - 14 - offset)
    local previewHeight = if empty then 0 elseif stacked then 139 else detailHeight
    local detailY = offset + (if stacked and not empty then previewHeight + 8 else 0)
    product.Size = UDim2.new(1, -4, 0, detailY + detailHeight)
    closetChoices.Size = UDim2.new(1, 0, 0, 44)
    previewTile.Position = UDim2.fromOffset(0, offset)
    previewTile.Size = if stacked then UDim2.new(1, 0, 0, previewHeight) else UDim2.new(.49, -5, 0, previewHeight)
    details.Position = if stacked or empty then UDim2.fromOffset(0, detailY) else UDim2.new(.49, 5, 0, detailY)
    details.Size = if stacked or empty then UDim2.new(1, 0, 0, detailHeight) else UDim2.new(.51, -5, 0, detailHeight)
    previewCamera.FieldOfView = if stacked or compact then 43 else 37
    bundleCamera.FieldOfView = if stacked or compact then 39 else 34

    title.TextSize = if small then 25 else 37
    title.Position, title.Size = UDim2.fromOffset(inset, if inlineCompact then 17 elseif small then 21 else 36),
        UDim2.new(1, -inset * 2, 0, if inlineCompact then 30 elseif small then 38 else 55)
    ownership.Position, ownership.Size = UDim2.fromOffset(inset, if small then 4 else 15), UDim2.new(1, -inset * 2, 0, 18)
    description.Position, description.Size = UDim2.fromOffset(inset, if inlineCompact then 45 elseif small then 59 else 92),
        UDim2.new(1, -inset * 2, 0, if small then 31 else 44)
    priceDisplay.Position, priceDisplay.Size = UDim2.fromOffset(inset, if inlineCompact then 71 elseif small then 89 else 144),
        UDim2.new(1, -inset * 2, 0, 26)
    local actionParent = if footer then shop else details
    if action.Parent ~= actionParent then action.Parent = actionParent end
    action.Position = if footer then UDim2.new(0, inset, 1, -53)
        else UDim2.fromOffset(inset, if inlineCompact then 97 else 177)
    action.Size = UDim2.new(1, -inset * 2, 0, 44)
    feedback.Position, feedback.Size = UDim2.fromOffset(inset, if footer then 116 elseif inlineCompact then 143 else 222),
        UDim2.new(1, -inset * 2, 0, 30)
end
details:GetAttributeChangedSignal("ClosetEmpty"):Connect(layout)
product:GetAttributeChangedSignal("HasClosetChoices"):Connect(layout)
feedback:GetPropertyChangedSignal("Text"):Connect(layout)
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
toggle.Activated:Connect(function() show(false) end)
close.Activated:Connect(hide)
openShop.Activated:Connect(function() show(true, true) end)
walletBack.Activated:Connect(function() show(false) end)
shopClose.Activated:Connect(hide)
shortcut.Activated:Connect(function() show(true, false) end)
for key, tab in tabButtons do
    tab.Activated:Connect(function()
        category, previewing = key, true
        shopScroll.CanvasPosition = Vector2.zero
        if key == "robux" then refreshPrice() else render() end
    end)
end
jadeChoice.Activated:Connect(function()
    closetOffer, previewing = "jade", true
    render()
end)
bundleChoice.Activated:Connect(function()
    closetOffer, previewing = "midnight", true
    render()
end)
previewMode.Activated:Connect(function()
    previewing = not previewing
    syncPortrait(bundleSelected, details:GetAttribute("ClosetEmpty") == true)
end)
player.CharacterRemoving:Connect(hide)
action.SelectionGained:Connect(function()
    if action.Parent == details then revealShop(action) end
end)
local function focusForDevice()
    if shade.Visible and gamepad() then
        local selected = GuiService.SelectedObject
        if not selected or not selected:IsDescendantOf(shade) then
            GuiService.SelectedObject = if shop.Visible then shopClose else openShop
        end
    end
end
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(focusForDevice)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(focusForDevice)
UserInputService.InputBegan:Connect(function(input, consumed)
    if consumed or UserInputService:GetFocusedTextBox() then return end
    if shade.Visible and input.KeyCode == Enum.KeyCode.Backspace then
        goBack()
    elseif input.KeyCode == Enum.KeyCode.O then
        if shade.Visible and shop.Visible then hide() else show(true, false) end
    elseif input.KeyCode == Enum.KeyCode.K then
        if shade.Visible then hide() else show(false) end
    end
end)
ContextActionService:BindAction(openAction, function(_, state)
    if shade.Visible or GuiService.SelectedObject or not toggle.Visible then return Enum.ContextActionResult.Pass end
    if state == Enum.UserInputState.Begin then show(false) end
    return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.DPadDown)
screen.Destroying:Connect(function()
    ContextActionService:UnbindAction(openAction)
    ContextActionService:UnbindAction(closeAction)
end)

layout()
render()
updateAvailability()
