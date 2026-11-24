local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local roster = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog"))
local visuals = ReplicatedStorage:WaitForChild("StarterFighterVisuals")
local choice = ReplicatedStorage:WaitForChild("StarterFighterChoice")
local actionName = "BeastDojoStarterSelection"
local colors = {
    veil = Color3.fromRGB(19, 15, 30),
    panel = Color3.fromRGB(35, 28, 45),
    raised = Color3.fromRGB(57, 43, 66),
    ink = Color3.fromRGB(49, 31, 35),
    text = Color3.fromRGB(255, 242, 220),
    muted = Color3.fromRGB(222, 208, 221),
    gold = Color3.fromRGB(253, 207, 133),
    edge = Color3.fromRGB(137, 104, 125),
    error = Color3.fromRGB(255, 171, 156),
}
local elements = {
    Land = Color3.fromRGB(160, 219, 175),
    Aquatic = Color3.fromRGB(151, 225, 245),
    Magma = Color3.fromRGB(255, 176, 151),
    Sky = Color3.fromRGB(238, 211, 151),
}
local shortNames = {
    ["reedguard-kangaroo"] = "Reedguard",
    ["penguin-brawler"] = "Penguin",
    ["silverback-gorilla"] = "Silverback",
    ["fire-salamander"] = "Salamander",
}
local previewMoves = {
    ["reedguard-kangaroo"] = {right = -33, left = 13, lean = -7, roll = -6, lift = .18, step = .18},
    ["penguin-brawler"] = {right = 13, left = -25, lean = -14, roll = 8, lift = .07, step = .30},
    ["silverback-gorilla"] = {right = -22, left = -18, lean = -5, roll = 2, lift = .09, step = .10},
    ["fire-salamander"] = {right = -28, left = 15, lean = -11, roll = -9, lift = .17, step = .20},
}

local function create(class, parent, properties)
    local instance = Instance.new(class)
    for key, value in properties do
        instance[key] = value
    end
    instance.Parent = parent
    return instance
end

local function edge(object, radius, tint)
    create("UICorner", object, {CornerRadius = UDim.new(0, radius)})
    return create("UIStroke", object, {Color = tint, Thickness = 1.25, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function label(parent, name, text, size, tint, font)
    return create("TextLabel", parent, {
        Name = name, Text = text, TextSize = size, TextColor3 = tint,
        Font = font or Enum.Font.GothamMedium, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
    })
end

local function button(parent, name, text, tint, strokeColor)
    local control = create("TextButton", parent, {
        Name = name, Text = text, TextSize = 16, TextColor3 = colors.text,
        Font = Enum.Font.GothamBold, BorderSizePixel = 0, BackgroundColor3 = tint,
        Selectable = true, AutoButtonColor = true, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local stroke = edge(control, 8, strokeColor)
    control.SelectionGained:Connect(function()
        stroke.Thickness = 3
    end)
    control.SelectionLost:Connect(function()
        stroke.Thickness = 1.25
    end)
    return control, stroke
end

local screen = create("ScreenGui", playerGui, {
    Name = "StarterFighterSelect",
    DisplayOrder = 90, ResetOnSpawn = false, Enabled = false,
    ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
    SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local backdrop = create("Frame", screen, {
    Name = "Backdrop", Size = UDim2.fromScale(1, 1), BackgroundColor3 = colors.veil,
    BackgroundTransparency = .13, BorderSizePixel = 0, Active = true,
})
local panel = create("Frame", backdrop, {
    Name = "SelectionPanel", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    BackgroundColor3 = colors.panel, BorderSizePixel = 0, Active = true, Visible = false,
})
local loading = create("Frame", backdrop, {
    Name = "ProfileLoading", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.new(.84, 0, 0, 102), BackgroundColor3 = colors.panel, BorderSizePixel = 0, Visible = false,
})
create("UISizeConstraint", loading, {MaxSize = Vector2.new(440, 102)})
edge(loading, 15, colors.edge)
local loadingTitle = label(loading, "LoadingTitle", "Opening fighter profile", 21, colors.gold, Enum.Font.FredokaOne)
loadingTitle.Position, loadingTitle.Size = UDim2.fromOffset(13, 9), UDim2.new(1, -26, 0, 36)
loadingTitle.TextXAlignment = Enum.TextXAlignment.Center
local loadingStatus = label(loading, "LoadingStatus", "", 14, colors.text)
loadingStatus.Position, loadingStatus.Size = UDim2.fromOffset(13, 38), UDim2.new(1, -26, 0, 53)
loadingStatus.TextXAlignment, loadingStatus.TextWrapped = Enum.TextXAlignment.Center, true
edge(panel, 15, colors.edge)
local heading = label(panel, "Heading", "Choose your fighter", 31, colors.gold, Enum.Font.FredokaOne)
local rosterBar = create("Frame", panel, {Name = "FighterSelector", BackgroundTransparency = 1})

local stage = create("Frame", panel, {
    Name = "Stage", BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ClipsDescendants = true,
})
edge(stage, 13, colors.edge)
local stageLight = create("UIGradient", stage, {Rotation = 88})
local viewport = create("ViewportFrame", stage, {
    Name = "FighterPreview", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    Ambient = Color3.fromRGB(185, 174, 177), LightColor = Color3.fromRGB(255, 225, 196),
    LightDirection = Vector3.new(-3, -5, -4),
})
local previewCamera = create("Camera", viewport, {Name = "PreviewCamera", FieldOfView = 34})
viewport.CurrentCamera = previewCamera
local world = create("WorldModel", viewport, {Name = "PreviewWorld"})
local ground = create("Part", world, {
    Name = "Pedestal", Anchored = true, CanCollide = false, CanQuery = false,
    Shape = Enum.PartType.Cylinder, Material = Enum.Material.SmoothPlastic,
    Color = Color3.fromRGB(72, 50, 64), CFrame = CFrame.new(0, -.17, 0) * CFrame.Angles(0, 0, math.pi / 2),
})
local brass = create("Part", world, {
    Name = "Pedestal rim", Anchored = true, CanCollide = false, CanQuery = false,
    Shape = Enum.PartType.Cylinder, Material = Enum.Material.SmoothPlastic,
    Color = Color3.fromRGB(173, 120, 79), CFrame = CFrame.new(0, -.072, 0) * CFrame.Angles(0, 0, math.pi / 2),
})
local stageError = label(stage, "PreviewStatus", "", 16, colors.text)
stageError.Size = UDim2.fromScale(1, 1)
stageError.TextXAlignment = Enum.TextXAlignment.Center
stageError.TextWrapped = true
stageError.Visible = false

local detailBox = create("Frame", panel, {
    Name = "FighterDetails", BackgroundColor3 = colors.raised, BorderSizePixel = 0,
})
edge(detailBox, 13, colors.edge)
local details = create("ScrollingFrame", detailBox, {
    Name = "DetailsScroll", BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 4, ScrollBarImageColor3 = colors.gold,
    CanvasSize = UDim2.fromOffset(0, 0), ScrollingDirection = Enum.ScrollingDirection.Y,
})
local list = create("UIListLayout", details, {
    SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6),
})
local lines = {}
local function detail(name, size, tint, font)
    local line = label(details, name, "", size, tint, font)
    line.LayoutOrder = #lines + 1
    line.Size = UDim2.new(1, -9, 0, 0)
    line.AutomaticSize = Enum.AutomaticSize.Y
    line.TextWrapped = true
    table.insert(lines, line)
    return line
end
local fighterName = detail("FighterName", 26, colors.text, Enum.Font.FredokaOne)
local title = detail("FighterTitle", 15, colors.gold, Enum.Font.GothamBold)
local home = detail("Home", 13, colors.muted)
local style = detail("ElementAndStyle", 13, colors.text, Enum.Font.GothamBold)
local stats = detail("Stats", 14, colors.text)
local quote = detail("Quote", 15, colors.gold, Enum.Font.GothamBold)
local story = detail("Story", 14, colors.text)
local techniques = detail("TechniquesHeading", 14, colors.gold, Enum.Font.GothamBold)
techniques.Text = "Technique preview"
local moves = {}
local maxTechniques = 0
for _, id in roster.Order do
    maxTechniques = math.max(maxTechniques, #roster.ById[id].powers)
end
for index = 1, maxTechniques do
    moves[index] = {
        name = detail("Technique" .. index, 15, colors.text, Enum.Font.GothamBold),
        effect = detail("TechniqueEffect" .. index, 14, colors.muted),
    }
end
local up = button(detailBox, "DetailsUp", utf8.char(0x2191), colors.panel, colors.edge)
local down = button(detailBox, "DetailsDown", utf8.char(0x2193), colors.panel, colors.edge)
up.Size, down.Size = UDim2.fromOffset(42, 42), UDim2.fromOffset(42, 42)
up.Visible, down.Visible = false, false
local confirm, confirmStroke = button(panel, "ConfirmFighter", "", colors.gold, colors.gold)
confirm.TextColor3 = colors.ink
local status = label(panel, "SelectionStatus", "", 13, colors.text)
status.TextWrapped = true
local cards = {}
local selectedId
local animation
local previewModel
local previewSize
local previewParts = {}
local beganAt = 0
local previewState
local buttons
local inFlight = false
local requestNumber = 0
local lastError = ""
local visibleControls = false
local inputLocked = false
local promptsWereEnabled

local function focusNavigation()
    return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad or UserInputService.VREnabled
end

local function motionAllowed()
    return not (GuiService.ReducedMotionEnabled or UserInputService.VREnabled)
end

local function boundedScroll(amount)
    local limit = math.max(0, details.AbsoluteCanvasSize.Y - details.AbsoluteWindowSize.Y)
    details.CanvasPosition = Vector2.new(0, math.clamp(details.CanvasPosition.Y + amount, 0, limit))
end
up.Activated:Connect(function() boundedScroll(-math.max(54, details.AbsoluteWindowSize.Y * .55)) end)
down.Activated:Connect(function() boundedScroll(math.max(54, details.AbsoluteWindowSize.Y * .55)) end)
local function updateScroll()
    local height = list.AbsoluteContentSize.Y + 8
    details.CanvasSize = UDim2.fromOffset(0, height)
    local overflow = height > details.AbsoluteWindowSize.Y + 4
    up.Visible, down.Visible = overflow and visibleControls, overflow and visibleControls
    confirm.NextSelectionRight = if down.Visible then down else confirm
    confirm.NextSelectionLeft = if down.Visible then down else confirm
    if not up.Visible and (GuiService.SelectedObject == up or GuiService.SelectedObject == down) then
        GuiService.SelectedObject = confirm
    end
end
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)

local function fitCamera()
    if not previewSize then
        return
    end
    local area = viewport.AbsoluteSize
    if area.X < 2 or area.Y < 2 then
        return
    end
    local aspect = area.X / area.Y
    local span = math.max((previewSize.Y + .35) * 1.19, (previewSize.X + previewSize.Z * .25) * 1.22 / aspect)
    local distance = span / (2 * math.tan(math.rad(previewCamera.FieldOfView / 2)))
    local center = Vector3.new(0, previewSize.Y * .49, 0)
    previewCamera.CFrame = CFrame.lookAt(center + Vector3.new(.23, .112, -.967).Unit * distance, center)
end

local function pose(t)
    if not selectedId then
        return
    end
    local move = previewMoves[selectedId] or previewMoves["reedguard-kangaroo"]
    local allowed = motionAllowed()
    local entry = if allowed then math.clamp(t / .90, 0, 1) else 1
    local intro = 1 - entry
    local beat = if allowed then math.sin(math.pi * math.clamp((t - .14) / .52, 0, 1)) ^ 2 else 0
    local idle = if allowed then math.sin(t * 2.75) else 0
    local lift = math.max(0, .034 + idle * .034 + beat * move.lift)
    local root = CFrame.new(0, allowed and lift or 0, -beat * move.step)
        * CFrame.Angles(math.rad(beat * move.lean), math.rad(-13 - intro ^ 2 * 40 + idle * 5), math.rad(beat * move.roll))
    for _, entryPart in previewParts do
        local limbAngle = if entryPart.arm == 1 then beat * move.right elseif entryPart.arm == -1 then beat * move.left else 0
        entryPart.part.CFrame = root * entryPart.rest * CFrame.Angles(math.rad(limbAngle), 0, 0) * entryPart.meshOffset
    end
end

local function setPreviewState(state)
    previewState = state
    viewport:SetAttribute("PreviewState", state)
    viewport.Visible = state == "ready"
    stageError.Visible = state ~= "ready"
    stageError.Text = if state == "loading" then "Loading fighter…" else "3D preview could not load"
    buttons()
end

local function drawPreview(id, tint)
    if previewModel then
        previewModel:Destroy()
        previewModel = nil
    end
    table.clear(previewParts)
    previewSize = nil
    viewport:SetAttribute("FighterId", id)
    local sample = visuals:FindFirstChild(id)
    stageLight.Color = ColorSequence.new(tint:Lerp(colors.raised, .57), colors.veil)
    if not (sample and sample:IsA("Model")) then
        setPreviewState("failed")
        return
    end

    setPreviewState("loading")
    local model = sample:Clone()
    previewModel = model
    model.Name = id
    model.Parent = world
    -- The import manifest already defines a floor-aligned frame facing -Z.
    -- Moving the auto-selected pivot to identity would turn the model around.
    local bounds, size = model:GetBoundingBox()
    local reference = CFrame.new(0, bounds.Position.Y - size.Y / 2, 0)
    local load, needed = {}, {}
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = true
            local group = part.Name:lower():gsub("[^a-z]", "")
            local arm = if group:find("rightarm", 1, true) then 1 elseif group:find("leftarm", 1, true) then -1 else 0
            local attachment = part:FindFirstChild("ArtPivot")
            local pivot = if attachment and attachment:IsA("Attachment") then attachment.WorldCFrame else part:GetPivot()
            table.insert(previewParts, {
                part = part, rest = reference:ToObjectSpace(pivot), meshOffset = pivot:ToObjectSpace(part.CFrame), arm = arm,
            })
            if part:IsA("MeshPart") then
                table.insert(load, part)
                needed[part.MeshId] = true
                needed[part.TextureID] = true
            end
        end
    end
    previewSize = size
    local width = math.max(size.X * 1.18, size.Z * 1.26, 3.8)
    ground.Size, brass.Size = Vector3.new(.24, width, width), Vector3.new(.14, width * .955, width * .955)
    ground.Color = tint:Lerp(colors.veil, .70)
    fitCamera()
    task.delay(12, function()
        if previewModel == model and previewState == "loading" then
            setPreviewState("failed")
        end
    end)
    task.spawn(function()
        local processed = pcall(function()
            ContentProvider:PreloadAsync(load, function(uri, status)
                if status == Enum.AssetFetchStatus.Success then
                    needed[uri] = nil
                end
            end)
        end)
        if previewModel ~= model or previewState ~= "loading" then
            return
        end
        if processed and #load > 0 and not next(needed) then
            beganAt = os.clock()
            pose(0)
            setPreviewState("ready")
        else
            setPreviewState("failed")
        end
    end)
end

buttons = function()
    local saving = inFlight or player:GetAttribute("StarterSelectionPending") == true
    local waiting = previewState == "loading"
    local busy = saving or waiting
    local name = shortNames[selectedId] or roster.ById[selectedId].name
    confirm.Active = not busy
    confirm.Text = if saving then "Saving fighter…"
        elseif waiting then "Loading fighter…"
        elseif previewState == "failed" then "Retry 3D preview"
        else "Start as " .. name
    confirm.BackgroundColor3 = if busy then colors.gold:Lerp(colors.panel, .28) else colors.gold
    confirmStroke.Color = if busy then colors.edge else colors.gold
    status.Text = if lastError ~= "" then lastError elseif saving then "Saving your choice" else ""
    status.TextColor3 = if lastError ~= "" then colors.error else colors.text
end

local function showFighter(id)
    if id == selectedId or (selectedId and (inFlight or player:GetAttribute("StarterSelectionPending") == true)) then
        return
    end
    local info = roster.ById[id]
    if not info then
        return
    end
    selectedId = id
    local tint = elements[info.element] or colors.gold
    screen:SetAttribute("PreviewFighterId", id)
    fighterName.Text, title.Text, home.Text = info.name, info.title, info.home
    style.Text = string.format("%s  ·  %s  ·  %s  ·  %s", info.element, info.rarity, info.role, info.style)
    style.TextColor3 = tint
    stats.Text = string.format("%s HP   ·   %s normal hit damage", tostring(info.health), tostring(info.normalHit))
    quote.Text = "“" .. info.quote .. "”"
    story.Text = info.story
    for index, row in moves do
        local move = info.powers[index]
        row.name.Visible, row.effect.Visible = move ~= nil, move ~= nil
        if move then
            row.name.Text, row.effect.Text = move.name, move.effect
        end
    end
    for _, entry in cards do
        entry.control.BackgroundColor3 = if entry.id == id then tint:Lerp(colors.raised, .73) else colors.raised
        entry.stroke.Color = if entry.id == id then tint else colors.edge
    end
    details.CanvasPosition = Vector2.zero
    if screen.Enabled then
        drawPreview(id, tint)
    end
    buttons()
end

for index, id in roster.Order do
    local info = roster.ById[id]
    local control, stroke = button(rosterBar, id, shortNames[id] or info.name, colors.raised, colors.edge)
    cards[index] = {id = id, control = control, stroke = stroke}
    control.Activated:Connect(function()
        showFighter(id)
    end)
    control.SelectionGained:Connect(function()
        if screen.Enabled and focusNavigation() then
            showFighter(id)
        end
    end)
end

local function selectedCard()
    for _, card in cards do
        if card.id == selectedId then
            return card.control
        end
    end
    return cards[1].control
end

local function layout()
    local safe = backdrop.AbsoluteSize
    if safe.X < 2 or safe.Y < 2 then
        return
    end
    local tall = safe.X < 560 and safe.Y >= safe.X * .92
    local compact = safe.Y < 405
    local width = math.min(safe.X - (if compact then 12 else 22), 1000)
    local height = math.min(safe.Y - (if compact then 10 else 20), 670)
    panel.Size = UDim2.fromOffset(width, height)
    local pad = if compact then 9 else 14
    local gap = if compact then 7 else 10
    local contentWidth = width - pad * 2
    local headingHeight = if compact then 31 else 42
    heading.Position, heading.Size = UDim2.fromOffset(pad + 2, pad), UDim2.fromOffset(contentWidth - 2, headingHeight)
    heading.TextSize = if compact then 24 else 31
    local cardHeight = if compact then 42 else 49
    local columns = if tall then 2 else 4
    local rosterY = pad + headingHeight + gap
    local rosterHeight = math.ceil(#cards / columns) * (cardHeight + gap) - gap
    local slot = (contentWidth - (columns - 1) * gap) / columns
    rosterBar.Position, rosterBar.Size = UDim2.fromOffset(pad, rosterY), UDim2.fromOffset(contentWidth, rosterHeight)
    for index, card in cards do
        local column, row = (index - 1) % columns, math.floor((index - 1) / columns)
        local control = card.control
        control.Position = UDim2.fromOffset(column * (slot + gap), row * (cardHeight + gap))
        control.Size = UDim2.fromOffset(slot, cardHeight)
        control.TextSize = if slot < 104 then 14 else 16
        control.NextSelectionLeft = if column > 0 then cards[index - 1].control else control
        control.NextSelectionRight = if column < columns - 1 and cards[index + 1] then cards[index + 1].control else control
        control.NextSelectionUp = if row > 0 then cards[index - columns].control else control
        control.NextSelectionDown = if cards[index + columns] then cards[index + columns].control else confirm
    end

    local footer = if compact then 42 else 48
    local footerY = height - pad - footer
    local reserve = if tall and status.Text ~= "" then 43 else 0
    local bodyY = rosterY + rosterHeight + gap
    local bodyHeight = math.max(62, footerY - bodyY - gap - reserve)
    local stageWidth = if tall then contentWidth else math.floor((contentWidth - gap) * .49)
    local stageHeight = if tall then math.clamp(math.floor(bodyHeight * .46), 62, 235) else bodyHeight
    stage.Position, stage.Size = UDim2.fromOffset(pad, bodyY), UDim2.fromOffset(stageWidth, stageHeight)
    local detailX = if tall then pad else pad + stageWidth + gap
    local detailY = if tall then bodyY + stageHeight + gap else bodyY
    local detailWidth = if tall then contentWidth else contentWidth - stageWidth - gap
    local detailHeight = if tall then math.max(36, bodyHeight - stageHeight - gap) else bodyHeight
    detailBox.Position, detailBox.Size = UDim2.fromOffset(detailX, detailY), UDim2.fromOffset(detailWidth, detailHeight)
    visibleControls = detailHeight >= 94 or focusNavigation()
    local textPad = if compact then 8 else 12
    local detailButtonSize = if detailHeight >= 94 then 42 else 28
    local controlsWidth = if visibleControls then detailButtonSize + 9 else 5
    details.Position = UDim2.fromOffset(textPad, textPad)
    details.Size = UDim2.new(1, -textPad - controlsWidth, 1, -textPad * 2)
    up.Size, down.Size = UDim2.fromOffset(detailButtonSize, detailButtonSize), UDim2.fromOffset(detailButtonSize, detailButtonSize)
    up.Position = UDim2.new(1, -detailButtonSize - 6, .5, -detailButtonSize - 2)
    down.Position = UDim2.new(1, -detailButtonSize - 6, .5, 3)
    fighterName.TextSize = if compact then 19 else 25
    title.TextSize, home.TextSize = if compact then 13 else 15, if compact then 12 else 13
    stats.LayoutOrder, style.LayoutOrder, home.LayoutOrder =
        if compact then 3 else 5, 4, if compact then 5 else 3
    confirm.Size = UDim2.fromOffset(if tall then contentWidth else math.min(contentWidth * .53, 338), footer)
    confirm.AnchorPoint = Vector2.new(1, 0)
    confirm.Position = UDim2.new(1, -pad, 0, footerY)
    confirm.TextSize = if compact then 15 else 17
    status.Position = UDim2.fromOffset(pad + 2, if tall then footerY - 42 else footerY)
    status.Size = UDim2.fromOffset(if tall then contentWidth - 4 else contentWidth - confirm.Size.X.Offset - 12,
        if tall then 39 else footer)
    confirm.NextSelectionUp = selectedCard()
    confirm.NextSelectionDown = confirm
    up.NextSelectionDown, down.NextSelectionUp = down, up
    up.NextSelectionLeft, down.NextSelectionLeft = confirm, confirm
    up.NextSelectionRight, down.NextSelectionRight = confirm, confirm
    up.NextSelectionUp, down.NextSelectionDown = selectedCard(), confirm
    fitCamera()
    updateScroll()
end
backdrop:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitCamera)
status:GetPropertyChangedSignal("Text"):Connect(layout)

local function confirmChoice()
    if not panel.Visible or not selectedId or inFlight or player:GetAttribute("StarterSelectionPending") == true
        or player:GetAttribute("StarterSelectionRequired") ~= true then
        return
    end
    if previewState == "failed" then
        drawPreview(selectedId, elements[roster.ById[selectedId].element] or colors.gold)
        return
    elseif previewState ~= "ready" then
        return
    end
    inFlight = true
    lastError = ""
    requestNumber += 1
    local thisRequest = requestNumber
    buttons()
    choice:FireServer(selectedId)
    task.delay(8, function()
        if requestNumber == thisRequest and inFlight and screen.Enabled
            and player:GetAttribute("StarterSelectionPending") ~= true then
            inFlight = false
            lastError = "Still waiting for a reply. Try again."
            buttons()
        end
    end)
end
confirm.Activated:Connect(confirmChoice)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not panel.Visible or UserInputService:GetFocusedTextBox() or focusNavigation() then
        return
    end
    if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
        confirmChoice()
    elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.Right then
        local index = table.find(roster.Order, selectedId) or 1
        local direction = if input.KeyCode == Enum.KeyCode.Left then -1 else 1
        showFighter(roster.Order[(index - 1 + direction) % #roster.Order + 1])
    end
end)

local function focus()
    if panel.Visible and focusNavigation()
        and (not GuiService.SelectedObject or not GuiService.SelectedObject:IsDescendantOf(panel)) then
        GuiService.SelectedObject = selectedCard()
    end
end
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
    layout()
    focus()
end)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(function()
    focus()
    pose(os.clock() - beganAt)
end)

local function lockInput(locked)
    if locked == inputLocked then
        return
    end
    inputLocked = locked
    if locked then
        promptsWereEnabled = ProximityPromptService.Enabled
        ProximityPromptService.Enabled = false
        ContextActionService:BindActionAtPriority(actionName, function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, table.unpack(Enum.PlayerActions:GetEnumItems()))
    else
        ContextActionService:UnbindAction(actionName)
        ProximityPromptService.Enabled = promptsWereEnabled
    end
end

local function show()
    panel.Visible, loading.Visible, screen.Enabled = true, false, true
    lockInput(true)
    if not selectedId then
        showFighter(roster.Order[1])
    else
        drawPreview(selectedId, elements[roster.ById[selectedId].element] or colors.gold)
    end
    animation = RunService.RenderStepped:Connect(function()
        if previewState == "ready" and motionAllowed() then
            pose(os.clock() - beganAt)
        end
    end)
    layout()
    focus()
end

local function hide()
    lockInput(false)
    if animation then
        animation:Disconnect()
        animation = nil
    end
    if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(panel) then
        GuiService.SelectedObject = nil
    end
    panel.Visible, loading.Visible, screen.Enabled = false, false, false
    inFlight = false
    if previewModel then
        previewModel:Destroy()
        previewModel = nil
    end
    table.clear(previewParts)
end

local function waitForProfile()
    local message = player:GetAttribute("StarterSelectionError")
    local unavailable = player:GetAttribute("ProgressStatus") == "unavailable"
    loadingStatus.Text = if type(message) == "string" and message ~= "" then message
        elseif unavailable then "Your profile is temporarily unavailable. Retrying…" else ""
    if loadingStatus.Text == "" then
        loadingTitle.Position = UDim2.fromOffset(13, 33)
    else
        loadingTitle.Position = UDim2.fromOffset(13, 9)
    end
    loading.Visible, screen.Enabled = true, true
    lockInput(true)
end

local function synchronize()
    local loadingSplash = playerGui:FindFirstChild("BeastDojoSplash") or playerGui:FindFirstChild("BeastDojoSplashContent")
    local required = player:GetAttribute("StarterSelectionRequired")
    if loadingSplash or required == false then
        if screen.Enabled then
            hide()
        end
    elseif required then
        if not panel.Visible then
            show()
        end
    else
        if panel.Visible then
            hide()
        end
        waitForProfile()
    end
end
local function splashChanged(child)
    if child.Name == "BeastDojoSplash" or child.Name == "BeastDojoSplashContent" then
        task.defer(synchronize)
    end
end
playerGui.ChildAdded:Connect(splashChanged)
playerGui.ChildRemoved:Connect(splashChanged)
player:GetAttributeChangedSignal("StarterSelectionRequired"):Connect(synchronize)
player:GetAttributeChangedSignal("SelectedStarterFighter"):Connect(synchronize)
player:GetAttributeChangedSignal("ProgressStatus"):Connect(function()
    if loading.Visible then
        waitForProfile()
    end
end)
player:GetAttributeChangedSignal("StarterSelectionError"):Connect(function()
    lastError = player:GetAttribute("StarterSelectionError") or ""
    if lastError ~= "" then
        inFlight = false
    end
    if selectedId then
        buttons()
    end
    if loading.Visible then
        waitForProfile()
    end
end)
player:GetAttributeChangedSignal("StarterSelectionPending"):Connect(function()
    if selectedId then
        buttons()
    end
end)
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()
    pose(os.clock() - beganAt)
end)
script.Destroying:Connect(function()
    if screen.Enabled then
        hide()
    end
    screen:Destroy()
end)
task.delay(.15, synchronize)
