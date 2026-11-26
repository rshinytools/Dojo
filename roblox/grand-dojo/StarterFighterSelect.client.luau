local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local roster = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog"))
local portraits = require(ReplicatedStorage:WaitForChild("ChampionshipPortraits"))
local fighterTactics = require(ReplicatedStorage:WaitForChild("FighterTactics"))
local fighterLoadouts = require(ReplicatedStorage:WaitForChild("FighterLoadouts"))
local visuals = ReplicatedStorage:WaitForChild("StarterFighterVisuals")
local forms = require(ReplicatedStorage:WaitForChild("FighterForms"))
local formVisuals = ReplicatedStorage:WaitForChild("FighterFormVisuals")
local choice = ReplicatedStorage:WaitForChild("StarterFighterChoice")
local actionName = "BeastDojoStarterSelection"
local cancelActionName = "BeastDojoCloseFighterSelect"
local focusActionName = "BeastDojoFighterPickerFocus"
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
local starterOrder = roster.StarterOrder or roster.Order

local function displayName(info)
    return info.shortName or shortNames[info.id] or info.name
end

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
    SelectionGroup = true, SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
    SelectionBehaviorDown = Enum.SelectionBehavior.Stop, SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
    SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
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
local close = button(panel, "CloseFighterSelect", "Close", colors.raised, colors.edge)
close.Visible = false
local rosterTitle = label(panel, "RosterTitle", "", 16, colors.gold, Enum.Font.GothamBold)
local previousPage = button(panel, "PreviousRosterPage", "‹", colors.raised, colors.edge)
local nextPage = button(panel, "NextRosterPage", "›", colors.raised, colors.edge)
local rosterBar = create("Frame", panel, {
    Name = "FighterSelector", BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
})

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
local tacticalBar = create("Frame", details, {
    Name = "TacticalChoice", LayoutOrder = 3, Visible = false, BackgroundTransparency = 1, BorderSizePixel = 0,
})
local tacticalHeading = label(tacticalBar, "Heading", "Technique", 13, colors.gold, Enum.Font.GothamBold)
tacticalHeading.Size = UDim2.new(1, 0, 0, 16)
local slotOrder = {"basic", "technique", "ultimate"}
local slotNames = {basic = "Basic", technique = "Technique", ultimate = "Ultimate"}
local slotHints = {basic = "B", technique = "T", ultimate = "U"}
local slotStrip = create("Frame", tacticalBar, {
    Name = "MoveSlots", Visible = false, BackgroundTransparency = 1, BorderSizePixel = 0,
})
local slotButtons = {}
for _, slot in slotOrder do
    local control, stroke = button(slotStrip, slotNames[slot], slotNames[slot], colors.panel, colors.edge)
    slotButtons[slot] = {control = control, stroke = stroke}
end
local slotDescription = label(tacticalBar, "SlotDescription", "", 13, colors.text)
slotDescription.TextWrapped, slotDescription.Visible = true, false
local tacticalButtons = {}
local maxTacticalOptions = 0
for _, group in fighterTactics.ByFighter do
    maxTacticalOptions = math.max(maxTacticalOptions, #group.options)
end
for index = 1, maxTacticalOptions do
    local control, stroke = button(tacticalBar, "Option" .. index, "", colors.panel, colors.edge)
    control.TextWrapped, control.TextTruncate = true, Enum.TextTruncate.None
    tacticalButtons[index] = {control = control, stroke = stroke}
end
local formBar = create("Frame", details, {
    Name = "FighterForms", LayoutOrder = 3, Visible = false, BackgroundTransparency = 1, BorderSizePixel = 0,
})
local formButtons = {}
for index = 1, 3 do
    local control, stroke = button(formBar, "Form" .. index, "", colors.panel, colors.edge)
    control.TextWrapped = true
    control.TextTruncate = Enum.TextTruncate.None
    formButtons[index] = {control = control, stroke = stroke}
end
local home = detail("Home", 13, colors.muted)
local style = detail("ElementAndStyle", 13, colors.text, Enum.Font.GothamBold)
local stats = detail("Stats", 14, colors.text)
local level = detail("FighterLevel", 14, colors.gold, Enum.Font.GothamBold)
level.Visible = false
local quote = detail("Quote", 15, colors.gold, Enum.Font.GothamBold)
local story = detail("Story", 14, colors.text)
local techniques = detail("TechniquesHeading", 14, colors.gold, Enum.Font.GothamBold)
techniques.Text = "Technique preview"
local moves = {}
local tacticalPowerIndexes = {}
local maxTechniques = 0
for _, id in roster.Order do
    local powers = roster.ById[id].powers
    local group = fighterTactics.ByFighter[id]
    local default = group and fighterTactics.get(id, group.default)
    if default then
        for index, move in powers do
            if move.name == default.name then
                tacticalPowerIndexes[id] = index
                break
            end
        end
    end
    maxTechniques = math.max(maxTechniques, #powers + (if group and not tacticalPowerIndexes[id] then 1 else 0))
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
local cardById = {}
local selectedId
local requestedForm
local requestedMoves = {}
local activeSlot = "technique"
local switching = false
local availableOrder = starterOrder
local fighterLevels = {}
local fighterForms = {}
local animation
local previewModel
local previewSize
local previewParts = {}
local beganAt = 0
local previewState
local buttons
local layout
local inFlight = false
local requestNumber = 0
local lastError = ""
local visibleControls = false
local inputLocked = false
local promptsWereEnabled
local pageCapacity, rosterPage = 8, 1

local function selectionOrder()
    return if switching then availableOrder else starterOrder
end

local function requiredLevel(id)
    local required = roster.ById[id].unlockLevel or 1
    return if required > (player:GetAttribute("HighestFighterLevel") or 1) then required else nil
end

local function savedForm(id)
    local stored = fighterForms[id]
    if id == player:GetAttribute("SelectedStarterFighter") then
        stored = player:GetAttribute("SelectedFighterForm") or stored
    end
    local record = forms.get(id, stored or forms.BaseId)
    return if record then record.id else forms.BaseId
end

local function previewForm(id)
    return if switching then requestedForm or savedForm(id) else forms.BaseId
end

local function formRequirement(id, formId)
    local form = forms.get(id, formId)
    local requirement = if form then form.level else 1
    return if requirement > (tonumber(fighterLevels[id]) or 1) then requirement else nil
end

local function moveGroup(slot)
    if slot == "technique" then
        return fighterTactics.ByFighter[selectedId]
    end
    local loadout = fighterLoadouts.ByFighter[selectedId]
    return loadout and loadout[slot]
end

local function getMove(slot, id)
    if not id then return nil end
    if slot == "technique" then
        return fighterTactics.get(selectedId, id)
    end
    return fighterLoadouts.get(selectedId, slot, id)
end

local function savedMove(slot)
    local group = moveGroup(slot)
    if not group then return nil end
    local saved = player:GetAttribute(group.attribute)
    return getMove(slot, saved) or getMove(slot, group.default)
end

local function moveRequirement(option)
    return if option and (tonumber(fighterLevels[selectedId]) or 1) < option.level then option.level else nil
end

local function requestedMoveRequirement()
    for _, slot in slotOrder do
        local requirement = moveRequirement(getMove(slot, requestedMoves[slot]))
        if requirement then return requirement end
    end
    return nil
end

local function pendingMoves()
    local count, first = 0, nil
    for _, slot in slotOrder do
        local option = getMove(slot, requestedMoves[slot])
        if option and option ~= savedMove(slot) then
            count += 1
            first = first or option
        end
    end
    return count, first
end

local function usesLoadoutSlots()
    return switching and fighterLoadouts.ByFighter[selectedId] ~= nil
end

local function alreadyEquipped(id)
    return switching and id == player:GetAttribute("SelectedStarterFighter") and previewForm(id) == savedForm(id)
        and pendingMoves() == 0
end

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
    local combat = roster.ById[selectedId].combat
    local move = (combat and combat.previewPose) or previewMoves[selectedId] or previewMoves["reedguard-kangaroo"]
    local allowed = motionAllowed()
    local entry = if allowed then math.clamp(t / .90, 0, 1) else 1
    local intro = 1 - entry
    local beat = if allowed then math.sin(math.pi * math.clamp((t - .14) / .52, 0, 1)) ^ 2 else 0
    local idle = if allowed then math.sin(t * 2.75) else 0
    local lift = math.max(0, .034 + idle * .034 + beat * move.lift)
    local root = CFrame.new(0, allowed and lift or 0, -beat * move.step)
        * CFrame.Angles(math.rad(beat * move.lean), math.rad(-13 - intro ^ 2 * 40 + idle * 5), math.rad(beat * move.roll))
    for _, group in previewParts do
        local angle = (if group.arm == 1 then move.right elseif group.arm == -1 then move.left else 0)
            + group.leg * (move.legs or 0)
        local frame = root * group.rest * CFrame.Angles(math.rad(angle * beat), 0, 0)
        for _, piece in group.pieces do
            piece.part.CFrame = frame * piece.offset
        end
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
    local formId = previewForm(id)
    screen:SetAttribute("PreviewFighterForm", formId)
    viewport:SetAttribute("FighterId", id)
    viewport:SetAttribute("FighterFormId", formId)
    local sample, outfit = forms.appearance(visuals, formVisuals, id, formId)
    stageLight.Color = ColorSequence.new(tint:Lerp(colors.raised, .57), colors.veil)
    if not (sample and sample:IsA("Model")) then
        setPreviewState("failed")
        return
    end

    setPreviewState("loading")
    local model = sample:Clone()
    previewModel = model
    model.Name = if outfit then outfit.Name else id
    for _, group in model:GetChildren() do
        if group:IsA("BasePart") then
            forms.decorate(group, outfit)
        end
    end
    model.Parent = world
    -- The import manifest already defines a floor-aligned frame facing -Z.
    -- Moving the auto-selected pivot to identity would turn the model around.
    local bounds, size = model:GetBoundingBox()
    local reference = CFrame.new(0, bounds.Position.Y - size.Y / 2, 0)
    local load, needed = {}, {}
    for _, joint in model:GetChildren() do
        if joint:IsA("BasePart") then
            local limb = joint.Name:lower():gsub("[^a-z]", "")
            local attachment = joint:FindFirstChild("ArtPivot")
            local pivot = if attachment and attachment:IsA("Attachment") then attachment.WorldCFrame else joint:GetPivot()
            local pieces = {}
            local parts = joint:GetDescendants()
            table.insert(parts, joint)
            for _, part in parts do
                if part:IsA("BasePart") then
                    part.Anchored = true
                    table.insert(pieces, {part = part, offset = pivot:ToObjectSpace(part.CFrame)})
                    if part:IsA("MeshPart") then
                        table.insert(load, part)
                        needed[part.MeshId] = true
                        needed[part.TextureID] = true
                    end
                end
            end
            table.insert(previewParts, {
                rest = reference:ToObjectSpace(pivot), pieces = pieces,
                arm = if limb == "rightarm" then 1 elseif limb == "leftarm" then -1 else 0,
                leg = if limb == "rightleg" then 1 elseif limb == "leftleg" then -1 else 0,
            })
        end
    end
    if #previewParts == 0 then
        setPreviewState("failed")
        return
    end
    previewSize = size
    local width = math.max(size.X * 1.18, size.Z * 1.26, 3.8)
    ground.Size, brass.Size = Vector3.new(.24, width, width), Vector3.new(.14, width * .955, width * .955)
    ground.Color = tint:Lerp(colors.veil, .70)
    fitCamera()
    if #load == 0 then
        beganAt = os.clock()
        pose(0)
        setPreviewState("ready")
        return
    end
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
        if processed and not next(needed) then
            beganAt = os.clock()
            pose(0)
            setPreviewState("ready")
        else
            setPreviewState("failed")
        end
    end)
end

local function updateFormButtons(saving)
    local options = forms.list(selectedId)
    formBar.Visible = switching and #options > 1
    local preview = previewForm(selectedId)
    local equipped = if selectedId == player:GetAttribute("SelectedStarterFighter") then savedForm(selectedId) else nil
    for index, tile in formButtons do
        local form = if formBar.Visible then options[index] else nil
        tile.form = form
        local control = tile.control
        control.Visible, control.Selectable, control.Active = form ~= nil, form ~= nil and not saving, form ~= nil and not saving
        if form then
            local selected = form.id == preview
            local requirement = formRequirement(selectedId, form.id)
            control.Name = form.name
            control.Text = form.name .. "\n" .. (if form.id == equipped then "Equipped"
                elseif requirement then "Level " .. requirement else "Unlocked")
            control.TextColor3 = if selected then colors.gold elseif requirement then colors.muted else colors.text
            control.BackgroundColor3 = if selected then colors.gold:Lerp(colors.panel, .82) else colors.panel
            tile.stroke.Color = if selected then colors.gold else colors.edge
        end
    end
end

local function updateTacticalButtons(saving)
    local group = moveGroup(activeSlot)
    tacticalBar.Visible = switching and group ~= nil and #group.options > 1
    slotStrip.Visible = tacticalBar.Visible and usesLoadoutSlots()
    local keyboard = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
    for _, slot in slotOrder do
        local tile = slotButtons[slot]
        local selected = slot == activeSlot
        local control = tile.control
        control.Selectable, control.Active = slotStrip.Visible and not saving, slotStrip.Visible and not saving
        control.Text = slotNames[slot] .. (if keyboard then " · " .. slotHints[slot] else "")
        control.TextColor3 = if selected then colors.gold else colors.text
        control.BackgroundColor3 = if selected then colors.gold:Lerp(colors.panel, .82) else colors.panel
        tile.stroke.Color = if selected then colors.gold else colors.edge
    end
    local stored = savedMove(activeSlot)
    local selected = getMove(activeSlot, requestedMoves[activeSlot]) or stored
    slotDescription.Visible = slotStrip.Visible and selected ~= nil and type(selected.description) == "string"
    slotDescription.Text = if slotDescription.Visible then selected.description else ""
    local activeFighter = selectedId == player:GetAttribute("SelectedStarterFighter")
    local canCycle = false
    for index, tile in tacticalButtons do
        local option = if tacticalBar.Visible then group.options[index] else nil
        tile.id = option and option.id
        local control = tile.control
        control.Name = tile.id or ("Option" .. index)
        control.Visible, control.Selectable = option ~= nil, option ~= nil and not saving
        if option then
            local locked = moveRequirement(option)
            local chosen = option == selected
            local subline = if locked then "Level " .. locked elseif option == stored and activeFighter then "Equipped"
                elseif chosen then "Selected" else ""
            canCycle = canCycle or (not chosen and locked == nil)
            control.Text = option.name .. (if subline == "" then "" else "\n" .. subline)
            control.Active, control.AutoButtonColor = not saving and not locked, not locked
            control.TextColor3 = if chosen then colors.gold elseif locked then colors.muted else colors.text
            control.BackgroundColor3 = if chosen then colors.gold:Lerp(colors.panel, .82) else colors.panel
            tile.stroke.Color = if chosen then colors.gold else colors.edge
        else
            control.Active = false
        end
    end
    tacticalHeading.Text = if canCycle and keyboard then "Technique · T" else "Technique"
end

local function updateMoveDescriptions(info)
    local loadout = usesLoadoutSlots()
    local powers = info.powers
    local catalogIndex = tacticalPowerIndexes[selectedId]
    local current = if loadout then nil else getMove("technique", requestedMoves.technique) or savedMove("technique")
    if loadout then
        -- The slot picker owns the descriptions of selectable attacks.
        local ultimate = moveGroup("ultimate")
        local default = ultimate and getMove("ultimate", ultimate.default)
        powers = {}
        for index, move in info.powers do
            if index ~= catalogIndex and (not default or move.name ~= default.name) then
                table.insert(powers, move)
            end
        end
    end
    techniques.Text = if loadout then "Other moves" else "Technique preview"
    local hasDescription = current and type(current.description) == "string" and current.description ~= ""
    techniques.Visible = #powers > 0 or hasDescription == true
    local extraRow = hasDescription and not catalogIndex
    for index, row in moves do
        local selectedTechnique = hasDescription and index == (catalogIndex or 1)
        local move = powers[if extraRow then index - 1 else index]
        local visible = selectedTechnique or move ~= nil
        row.name.Visible, row.effect.Visible = visible, visible
        if selectedTechnique then
            row.name.Text, row.effect.Text = current.name, current.description
        elseif move then
            row.name.Text, row.effect.Text = move.name, move.effect
        end
    end
end

buttons = function()
    local saving = inFlight or player:GetAttribute("StarterSelectionPending") == true
    local waiting = previewState == "loading"
    local busy = saving or waiting
    local info = roster.ById[selectedId]
    local name = displayName(info)
    updateMoveDescriptions(info)
    local formId = previewForm(selectedId)
    local equipped = alreadyEquipped(selectedId)
    local locked = switching and (requiredLevel(selectedId) or formRequirement(selectedId, formId)
        or requestedMoveRequirement())
    local option = forms.get(selectedId, formId)
    local pending, move = pendingMoves()
    local editingLoadout = usesLoadoutSlots() and pending > 0
    local activeFighter = selectedId == player:GetAttribute("SelectedStarterFighter")
    local formCopy = switching and #forms.list(selectedId) > 1 and option
    local enabled = not busy and (previewState == "failed" or (not equipped and not locked))
    confirm.Active = enabled
    close.Active = not saving
    close.Selectable = not saving
    confirm.Text = if saving then "Saving fighter…"
        elseif waiting then "Loading fighter…"
        elseif previewState == "failed" then "Retry 3D preview"
        elseif locked then string.format("Unlock at Level %d", locked)
        elseif equipped then "Currently equipped"
        elseif editingLoadout and not activeFighter then "Switch & equip loadout"
        elseif editingLoadout and (pending > 1 or formId ~= savedForm(selectedId)) then "Equip loadout"
        elseif move and activeFighter and formId == savedForm(selectedId) then "Equip " .. move.name
        elseif formCopy then "Equip " .. option.name
        else (if switching then "Switch to " else "Start as ") .. name
    confirm.BackgroundColor3 = if enabled then colors.gold else colors.gold:Lerp(colors.panel, .28)
    confirmStroke.Color = if enabled then colors.gold else colors.edge
    status.Text = if lastError ~= "" then lastError elseif saving then "Saving your choice" else ""
    status.TextColor3 = if lastError ~= "" then colors.error else colors.text
    updateFormButtons(saving)
    updateTacticalButtons(saving)
end

local function updateLevel()
    level.Visible = switching and selectedId ~= nil
    if level.Visible then
        local equipped = alreadyEquipped(selectedId)
        local required = requiredLevel(selectedId)
        level.Text = if required then string.format("Reach Level %d with any fighter to unlock", required)
            else string.format("Level %d%s", tonumber(fighterLevels[selectedId]) or 1, if equipped then " · Equipped" else "")
    end
end

local function updateCards(order, first, last, cardHeight)
    local equippedId = player:GetAttribute("SelectedStarterFighter")
    local showPortraits = panel.Visible and cardHeight >= 68
    for _, card in cards do
        local index = table.find(order, card.id)
        local visible = index and index >= first and index <= last
        local selected = card.id == selectedId
        local equipped = switching and card.id == equippedId
        local tint = card.tint
        local required = requiredLevel(card.id)
        card.control.Visible, card.control.Selectable = visible == true, visible == true
        card.control.BackgroundColor3 = if selected then colors.gold:Lerp(colors.raised, .79) else colors.raised
        card.stroke.Color = if selected then colors.gold else tint:Lerp(colors.edge, .72)
        card.stroke.Thickness = if GuiService.SelectedObject == card.control then 3 elseif selected then 2 else 1.25
        card.requirement.Text = if required then string.format("Unlock Lv %d", required)
            elseif equipped then "Equipped" elseif (roster.ById[card.id].unlockLevel or 1) > 1 then "Unlocked" else "Starter"
        card.requirement.TextColor3 = if equipped then elements.Land elseif required then colors.gold else colors.muted
        card.art.Visible = visible == true and showPortraits
        if card.art.Visible and not card.portrait then
            card.portrait = portraits.new(card.art, false, 2)
        end
        if card.portrait then
            portraits.set(card.portrait, if card.art.Visible then card.id else nil)
        end
    end
end

local function showFighter(id)
    if id == selectedId then
        return
    end
    if selectedId and (inFlight or player:GetAttribute("StarterSelectionPending") == true) then
        return
    end
    local info = roster.ById[id]
    if not info or not table.find(selectionOrder(), id) then
        return
    end
    selectedId = id
    requestedForm, activeSlot = nil, "technique"
    table.clear(requestedMoves)
    local tint = elements[info.element] or colors.gold
    screen:SetAttribute("PreviewFighterId", id)
    fighterName.Text, title.Text, home.Text = info.name, info.title, info.home
    style.Text = string.format("%s  ·  %s  ·  %s  ·  %s", info.element, info.rarity, info.role, info.style)
    style.TextColor3 = tint
    stats.Text = string.format("%s HP   ·   %s normal hit damage", tostring(info.health), tostring(info.normalHit))
    quote.Text = "“" .. info.quote .. "”"
    story.Text = info.story
    updateLevel()
    details.CanvasPosition = Vector2.zero
    if screen.Enabled then
        drawPreview(id, tint)
    end
    buttons()
    layout()
end

local function changePage(delta)
    if not panel.Visible or inFlight or player:GetAttribute("StarterSelectionPending") == true then
        return
    end
    local order = selectionOrder()
    local targetPage = math.clamp(rosterPage + delta, 1, math.ceil(#order / pageCapacity))
    if targetPage == rosterPage then
        return
    end
    local index = table.find(order, selectedId) or 1
    local nextIndex = math.min((targetPage - 1) * pageCapacity + (index - 1) % pageCapacity + 1, #order)
    local nextId = order[nextIndex]
    showFighter(nextId)
    if focusNavigation() and nextId == selectedId and not GuiService.MenuIsOpen then
        GuiService.SelectedObject = cardById[nextId].control
    end
end
previousPage.Activated:Connect(function() changePage(-1) end)
nextPage.Activated:Connect(function() changePage(1) end)

for index, id in roster.Order do
    local info = roster.ById[id]
    local name = displayName(info)
    local tint = elements[info.element] or colors.gold
    local control, stroke = button(rosterBar, id, name, colors.raised, colors.edge)
    control.TextTransparency = 1
    local art = create("Frame", control, {
        Name = "PortraitArt", BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
        ClipsDescendants = true, Active = false,
    })
    edge(art, 6, tint:Lerp(colors.raised, .55))
    create("UIGradient", art, {
        Rotation = 82, Color = ColorSequence.new(tint:Lerp(colors.raised, .43), colors.panel),
    })
    local nameLabel = label(control, "FighterName", name, 15, colors.text, Enum.Font.GothamBold)
    nameLabel.TextXAlignment, nameLabel.TextWrapped = Enum.TextXAlignment.Center, true
    local requirement = label(control, "UnlockLevel", "", 11, colors.gold, Enum.Font.GothamBold)
    requirement.TextXAlignment = Enum.TextXAlignment.Center
    local record = {id = id, control = control, stroke = stroke, art = art, tint = tint,
        name = nameLabel, requirement = requirement}
    cards[index], cardById[id] = record, record
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
    return (cardById[selectedId] or cardById[selectionOrder()[1]]).control
end

local function revealDetail(control)
    local before = details.CanvasPosition.Y
    local top = control.AbsolutePosition.Y - details.AbsolutePosition.Y + before
    local bottom = top + control.AbsoluteSize.Y
    local range = math.max(0, details.AbsoluteCanvasSize.Y - details.AbsoluteWindowSize.Y)
    local nextPosition = math.clamp(before, math.min(top, bottom - details.AbsoluteWindowSize.Y), top)
    details.CanvasPosition = Vector2.new(0, math.clamp(nextPosition, 0, range))
end

local function selectForm(form)
    if not (panel.Visible and formBar.Visible and form) or inFlight or player:GetAttribute("StarterSelectionPending") == true
        or form.id == previewForm(selectedId) then
        return
    end
    requestedForm, lastError = form.id, ""
    drawPreview(selectedId, elements[roster.ById[selectedId].element] or colors.gold)
    updateLevel()
end

for _, tile in formButtons do
    tile.control.Activated:Connect(function()
        selectForm(tile.form)
    end)
    tile.control.SelectionGained:Connect(function()
        if panel.Visible and focusNavigation() then
            revealDetail(tile.control)
            selectForm(tile.form)
        end
    end)
end

local function selectTactical(id)
    local option = getMove(activeSlot, id)
    if not (option and panel.Visible and tacticalBar.Visible) or moveRequirement(option) or inFlight
        or player:GetAttribute("StarterSelectionPending") == true then
        return
    end
    requestedMoves[activeSlot] = if option == savedMove(activeSlot) then nil else id
    lastError = ""
    updateLevel()
    buttons()
end

for _, tile in tacticalButtons do
    tile.control.Activated:Connect(function()
        selectTactical(tile.id)
    end)
    tile.control.SelectionGained:Connect(function()
        if panel.Visible and focusNavigation() then
            revealDetail(tile.control)
        end
    end)
end

local function selectSlot(slot)
    if slot == activeSlot or not (panel.Visible and slotStrip.Visible) or inFlight
        or player:GetAttribute("StarterSelectionPending") == true then
        return
    end
    activeSlot = slot
    buttons()
    layout()
    revealDetail(slotButtons[slot].control)
end

for _, slot in slotOrder do
    local control = slotButtons[slot].control
    control.Activated:Connect(function()
        selectSlot(slot)
    end)
    control.SelectionGained:Connect(function()
        if panel.Visible and focusNavigation() then
            revealDetail(control)
        end
    end)
end

local function layoutRoster(order, columns, rows, left, top, width, room, gap, maximumCardHeight)
    pageCapacity = columns * rows
    local selectedIndex = table.find(order, selectedId) or 1
    rosterPage = math.ceil(selectedIndex / pageCapacity)
    local pageCount = math.ceil(#order / pageCapacity)
    local first = (rosterPage - 1) * pageCapacity + 1
    local last = math.min(first + pageCapacity - 1, #order)
    local displayedRows = math.ceil((last - first + 1) / columns)
    local paged = pageCount > 1
    local band = if paged then 44 else 23
    local cardGap = math.min(gap, 7)
    local slot = (width - (columns - 1) * cardGap) / columns
    local cardHeight = math.clamp(math.floor((room - band - cardGap * displayedRows) / displayedRows), 44, maximumCardHeight)
    local gridY = top + band + cardGap
    local gridHeight = displayedRows * (cardHeight + cardGap) - cardGap

    rosterTitle.Text = if not switching then "Starters"
        elseif not paged and #order == 8 then "Launch roster  ·  8 fighters"
        elseif not paged then string.format("Available fighters  ·  %d", #order)
        elseif rosterPage == 1 and pageCapacity == 8 then string.format("Launch roster  ·  1 / %d", pageCount)
        else string.format("Fighters %d–%d  ·  %d / %d", first, last, rosterPage, pageCount)
    rosterTitle.TextSize = if width < 300 then 13 else 16
    rosterTitle.Position, rosterTitle.Size = UDim2.fromOffset(left + 1, top),
        UDim2.fromOffset(width - (if paged then 100 else 2), band)
    rosterTitle.TextWrapped = paged and width < 300
    previousPage.Visible, nextPage.Visible = paged, paged
    previousPage.Active, nextPage.Active = rosterPage > 1, rosterPage < pageCount
    previousPage.Selectable, nextPage.Selectable = previousPage.Active, nextPage.Active
    previousPage.TextColor3 = if previousPage.Active then colors.text else colors.edge
    nextPage.TextColor3 = if nextPage.Active then colors.text else colors.edge
    previousPage.Position = UDim2.fromOffset(left + width - 94, top)
    nextPage.Position = UDim2.fromOffset(left + width - 44, top)
    previousPage.Size, nextPage.Size = UDim2.fromOffset(44, 44), UDim2.fromOffset(44, 44)
    previousPage.TextSize, nextPage.TextSize = 25, 25
    previousPage.NextSelectionRight = if nextPage.Active then nextPage else previousPage
    nextPage.NextSelectionLeft = if previousPage.Active then previousPage else nextPage
    previousPage.NextSelectionUp, nextPage.NextSelectionUp = close, close
    previousPage.NextSelectionDown, nextPage.NextSelectionDown = selectedCard(), selectedCard()
    local firstControl = if nextPage.Active then nextPage elseif previousPage.Active then previousPage else close

    rosterBar.Position, rosterBar.Size = UDim2.fromOffset(left, gridY), UDim2.fromOffset(width, gridHeight)
    updateCards(order, first, last, cardHeight)
    for index = first, last do
        local id = order[index]
        local card = cardById[id]
        local relative = index - first
        local column, row = relative % columns, math.floor(relative / columns)
        local control = card.control
        control.Position = UDim2.fromOffset(column * (slot + cardGap), row * (cardHeight + cardGap))
        control.Size = UDim2.fromOffset(slot, cardHeight)
        local caption = if slot < 82 then 42 else 37
        local artHeight = if card.art.Visible then cardHeight - caption - 3 else 0
        card.art.Position, card.art.Size = UDim2.fromOffset(3, 3), UDim2.new(1, -6, 0, artHeight)
        card.name.Position = UDim2.fromOffset(3, artHeight + (if card.art.Visible then 3 else 2))
        card.name.Size = UDim2.new(1, -6, 0, cardHeight - card.name.Position.Y.Offset - 15)
        card.name.TextSize = if slot < 68 then 11 elseif slot < 82 then 12 elseif slot < 103 then 14 else 16
        card.requirement.Position, card.requirement.Size = UDim2.new(0, 2, 1, -14), UDim2.new(1, -4, 0, 12)
        control.NextSelectionLeft = if column > 0 then cardById[order[index - 1]].control else control
        control.NextSelectionRight = if column < columns - 1 and index < last
            then cardById[order[index + 1]].control else control
        control.NextSelectionUp = if row > 0 then cardById[order[index - columns]].control
            elseif switching then firstControl else control
        local nextRow = first + (row + 1) * columns
        control.NextSelectionDown = if nextRow <= last then cardById[order[math.min(index + columns, last)]].control
            elseif id == selectedId and slotStrip.Visible then slotButtons[activeSlot].control
            elseif id == selectedId and tacticalBar.Visible then tacticalButtons[1].control
            elseif id == selectedId and formBar.Visible then formButtons[1].control
            else confirm
    end
    return gridY + gridHeight
end

layout = function()
    local safe = backdrop.AbsoluteSize
    if safe.X < 2 or safe.Y < 2 then
        return
    end
    local tall = safe.X < 560 and safe.Y >= math.max(360, safe.X * .92)
    local compact = safe.Y < 405
    local width = math.min(safe.X - (if compact then 12 else 22), 1000)
    local height = math.min(safe.Y - (if compact then 10 else 20), 670)
    panel.Size = UDim2.fromOffset(width, height)
    local pad = if compact then 9 else 14
    local gap = if compact then 7 else 10
    local contentWidth = width - pad * 2
    local headingHeight = if compact then 37 else 44
    local closeWidth = if compact then 71 else 89
    local headingWidth = contentWidth - 2 - (if switching then closeWidth + gap else 0)
    heading.Position, heading.Size = UDim2.fromOffset(pad + 2, pad), UDim2.fromOffset(headingWidth, headingHeight)
    heading.TextSize = if compact or contentWidth < 320 then 23 else 31
    close.Position, close.Size = UDim2.fromOffset(width - pad - closeWidth, pad), UDim2.fromOffset(closeWidth, 44)
    close.TextSize = if compact then 14 else 16

    local order = selectionOrder()
    local rosterY = pad + math.max(44, headingHeight) + gap
    local footer = if compact then 44 else 48
    local footerY = height - pad - footer
    local reserve = if tall and status.Text ~= "" then 43 else 0
    local bodyBottom = footerY - reserve - gap
    local sideBySide = not tall and contentWidth >= (if compact then 250 else 540)
    local rosterWidth = if sideBySide then math.floor((contentWidth - gap) * .56) else contentWidth
    local columns = if rosterWidth >= 230 then 4 else 2
    local previewReserve = if sideBySide then 0 elseif tall then 150 elseif compact then 84 else 120
    local rosterRoom = bodyBottom - rosterY - previewReserve - (if sideBySide then 0 else gap)
    local maximumBand = if #order > columns * 2 then 44 else 23
    local rows = if rosterRoom >= maximumBand + 2 * (44 + gap) then 2 else 1
    local maximumCardHeight = if sideBySide then (if compact then 112 else 146) elseif tall then 100 else 88
    local rosterBottom = layoutRoster(order, columns, rows, pad, rosterY, rosterWidth, rosterRoom, gap, maximumCardHeight)

    local bodyY = if sideBySide then rosterY else rosterBottom + gap
    local bodyHeight = math.max(62, bodyBottom - bodyY)
    local stageX = if sideBySide then pad + rosterWidth + gap else pad
    local stageWidth = if sideBySide then contentWidth - rosterWidth - gap
        elseif tall then contentWidth else math.floor((contentWidth - gap) * .46)
    local stackedPreview = sideBySide or tall
    local stageHeight = if stackedPreview then math.clamp(math.floor(bodyHeight * .47), 62, 272) else bodyHeight
    stage.Position, stage.Size = UDim2.fromOffset(stageX, bodyY), UDim2.fromOffset(stageWidth, stageHeight)
    local detailX = if stackedPreview then stageX else pad + stageWidth + gap
    local detailY = if stackedPreview then bodyY + stageHeight + gap else bodyY
    local detailWidth = if stackedPreview then stageWidth else contentWidth - stageWidth - gap
    local detailHeight = if stackedPreview then math.max(36, bodyHeight - stageHeight - gap) else bodyHeight
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
    local tacticOffset = if tacticalBar.Visible then 1 else 0
    local tacticCount = if tacticalBar.Visible then #moveGroup(activeSlot).options else 0
    local lastTacticRow = 1
    formBar.LayoutOrder = 3 + tacticOffset
    if tacticalBar.Visible then
        local gapBetween = 4
        local widthForTactics = detailWidth - textPad - controlsWidth - 9
        local minimumWidth = if tacticCount > 2 then 78 else 70
        local columnsForTactics = math.clamp(math.floor((widthForTactics + gapBetween) / (minimumWidth + gapBetween)),
            1, tacticCount)
        local rowsForTactics = math.ceil(tacticCount / columnsForTactics)
        lastTacticRow = (rowsForTactics - 1) * columnsForTactics + 1
        local buttonHeight = if tacticCount > 2 then 48 else 44
        local buttonWidth = (widthForTactics - gapBetween * (columnsForTactics - 1)) / columnsForTactics
        local headerHeight = if compact then 0 else 20
        if slotStrip.Visible then
            local tabColumns = math.clamp(math.floor((widthForTactics + gapBetween) / 76), 1, #slotOrder)
            local tabRows = math.ceil(#slotOrder / tabColumns)
            local tabHeight = 44
            headerHeight = tabRows * (tabHeight + gapBetween)
            slotStrip.Size = UDim2.new(1, 0, 0, headerHeight - gapBetween)
            for index, slot in slotOrder do
                local control = slotButtons[slot].control
                local column, row = (index - 1) % tabColumns, math.floor((index - 1) / tabColumns)
                control.Position = UDim2.new(column / tabColumns, column * gapBetween / tabColumns,
                    0, row * (tabHeight + gapBetween))
                control.Size = UDim2.new(1 / tabColumns, -gapBetween * (tabColumns - 1) / tabColumns, 0, tabHeight)
                control.TextSize = if compact or widthForTactics < 320 then 12 else 14
                control.NextSelectionLeft = if column > 0 then slotButtons[slotOrder[index - 1]].control else control
                control.NextSelectionRight = if column < tabColumns - 1 and slotOrder[index + 1]
                    then slotButtons[slotOrder[index + 1]].control else control
                control.NextSelectionUp = if row > 0 then slotButtons[slotOrder[index - tabColumns]].control else selectedCard()
                control.NextSelectionDown = if row < tabRows - 1
                    then slotButtons[slotOrder[math.min(index + tabColumns, #slotOrder)]].control
                    else tacticalButtons[1].control
            end
        end
        tacticalBar.LayoutOrder = 3
        local optionsBottom = headerHeight + rowsForTactics * (buttonHeight + gapBetween) - gapBetween
        local descriptionHeight = if slotStrip.Visible then (if compact then 44 else 38) else 0
        tacticalBar.Size = UDim2.new(1, -9, 0, optionsBottom + descriptionHeight)
        tacticalHeading.Visible = not compact and not slotStrip.Visible
        slotDescription.Position = UDim2.fromOffset(0, optionsBottom + 3)
        slotDescription.Size = UDim2.new(1, 0, 0, math.max(0, descriptionHeight - 3))
        slotDescription.TextSize = if compact then 12 else 13
        for index = 1, tacticCount do
            local control = tacticalButtons[index].control
            local column = (index - 1) % columnsForTactics
            local row = math.floor((index - 1) / columnsForTactics)
            control.Position = UDim2.new(column / columnsForTactics, column * gapBetween / columnsForTactics,
                0, headerHeight + row * (buttonHeight + gapBetween))
            control.Size = UDim2.new(1 / columnsForTactics, -gapBetween * (columnsForTactics - 1) / columnsForTactics,
                0, buttonHeight)
            control.TextSize = if compact or detailWidth < 310 or (tacticCount > 2 and buttonWidth < 124) then 12 else 14
            control.NextSelectionLeft = if column > 0 then tacticalButtons[index - 1].control else control
            control.NextSelectionRight = if column < columnsForTactics - 1 and index < tacticCount
                then tacticalButtons[index + 1].control else control
            control.NextSelectionUp = if row > 0 then tacticalButtons[index - columnsForTactics].control
                elseif slotStrip.Visible then slotButtons[activeSlot].control else selectedCard()
            control.NextSelectionDown = if row < rowsForTactics - 1
                then tacticalButtons[math.min(index + columnsForTactics, tacticCount)].control
                elseif formBar.Visible then formButtons[1].control else confirm
        end
    end
    if formBar.Visible then
        local formGap = 4
        local widthForForms = detailWidth - textPad - controlsWidth - 9
        local formColumns = if widthForForms >= 218 then 3 elseif widthForForms >= 130 then 2 else 1
        local formRows = math.ceil(#formButtons / formColumns)
        local formHeight = 44
        formBar.Size = UDim2.new(1, -9, 0, formRows * (formHeight + formGap) - formGap)
        for index, tile in formButtons do
            local control = tile.control
            local column, row = (index - 1) % formColumns, math.floor((index - 1) / formColumns)
            control.Position = UDim2.new(column / formColumns, column * formGap / formColumns, 0, row * (formHeight + formGap))
            control.Size = UDim2.new(1 / formColumns, -formGap * (formColumns - 1) / formColumns, 0, formHeight)
            control.TextSize = if compact or widthForForms < 260 then 11 else 13
            control.NextSelectionLeft = if column > 0 then formButtons[index - 1].control else control
            control.NextSelectionRight = if column < formColumns - 1 and formButtons[index + 1]
                then formButtons[index + 1].control else control
            control.NextSelectionUp = if row > 0 then formButtons[index - formColumns].control
                elseif tacticalBar.Visible then tacticalButtons[math.min(lastTacticRow + column, tacticCount)].control
                else selectedCard()
            control.NextSelectionDown = if row < formRows - 1 then formButtons[math.min(index + formColumns, #formButtons)].control
                else confirm
        end
        stats.LayoutOrder, style.LayoutOrder, home.LayoutOrder, level.LayoutOrder = 5 + tacticOffset, 7 + tacticOffset,
            8 + tacticOffset, 4 + tacticOffset
        quote.LayoutOrder, story.LayoutOrder, techniques.LayoutOrder = 9 + tacticOffset, 10 + tacticOffset, 11 + tacticOffset
        for index, move in moves do
            move.name.LayoutOrder, move.effect.LayoutOrder = 10 + index * 2 + tacticOffset, 11 + index * 2 + tacticOffset
        end
    else
        stats.LayoutOrder, style.LayoutOrder, home.LayoutOrder =
            if compact then 3 else 5, 4, if compact then 5 else 3
        level.LayoutOrder, quote.LayoutOrder, story.LayoutOrder, techniques.LayoutOrder = 6, 7, 8, 9
        for index, move in moves do
            move.name.LayoutOrder, move.effect.LayoutOrder = 8 + index * 2, 9 + index * 2
        end
    end
    close.NextSelectionDown = selectedCard()
    confirm.Size = UDim2.fromOffset(if stackedPreview then stageWidth else math.min(contentWidth * .53, 338), footer)
    confirm.AnchorPoint = Vector2.new(1, 0)
    confirm.Position = UDim2.new(1, -pad, 0, footerY)
    confirm.TextSize = if compact then 15 else 17
    status.Position = UDim2.fromOffset(pad + 2, if tall then footerY - 42 else footerY)
    status.Size = UDim2.fromOffset(if tall then contentWidth - 4 else contentWidth - confirm.Size.X.Offset - 12,
        if tall then 39 else footer)
    confirm.NextSelectionUp = if formBar.Visible then formButtons[#formButtons].control
        elseif tacticalBar.Visible then tacticalButtons[tacticCount].control else selectedCard()
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
    if not panel.Visible or GuiService.MenuIsOpen or not selectedId or inFlight
        or player:GetAttribute("StarterSelectionPending") == true
        or (switching and not player:GetAttribute("FighterSelectOpen"))
        or (not switching and player:GetAttribute("StarterSelectionRequired") ~= true) then
        return
    end
    if previewState == "failed" then
        drawPreview(selectedId, elements[roster.ById[selectedId].element] or colors.gold)
        return
    elseif previewState ~= "ready" then
        return
    end
    if switching and (requiredLevel(selectedId) or formRequirement(selectedId, previewForm(selectedId))
        or requestedMoveRequirement() or alreadyEquipped(selectedId)) then
        return
    end
    inFlight = true
    lastError = ""
    requestNumber += 1
    local thisRequest = requestNumber
    buttons()
    if switching then
        if requestedMoves.basic or requestedMoves.ultimate then
            choice:FireServer("switch", selectedId, requestedForm, requestedMoves.technique, requestedMoves.basic,
                requestedMoves.ultimate)
        elseif requestedMoves.technique then
            choice:FireServer("switch", selectedId, requestedForm, requestedMoves.technique)
        elseif requestedForm then
            choice:FireServer("switch", selectedId, requestedForm)
        else
            choice:FireServer("switch", selectedId)
        end
    else
        choice:FireServer(selectedId)
    end
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

local function closePicker()
    if switching and panel.Visible and not inFlight and not player:GetAttribute("StarterSelectionPending") then
        choice:FireServer("close")
    end
end
close.Activated:Connect(closePicker)

local slotKeys = {[Enum.KeyCode.B] = "basic", [Enum.KeyCode.T] = "technique", [Enum.KeyCode.U] = "ultimate"}

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not panel.Visible or UserInputService:GetFocusedTextBox() or focusNavigation() then
        return
    end
    if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
        confirmChoice()
    elseif input.KeyCode == Enum.KeyCode.Backspace then
        closePicker()
    elseif tacticalBar.Visible and (input.KeyCode == Enum.KeyCode.T or (slotStrip.Visible and slotKeys[input.KeyCode])) then
        local slot = slotKeys[input.KeyCode]
        if slot ~= activeSlot then
            selectSlot(slot)
            return
        end
        local current = getMove(slot, requestedMoves[slot]) or savedMove(slot)
        local options = moveGroup(slot).options
        local index = table.find(options, current) or 1
        for step = 1, #options - 1 do
            local nextIndex = (index - 1 + step) % #options + 1
            local option = options[nextIndex]
            if not moveRequirement(option) then
                selectTactical(option.id)
                revealDetail(tacticalButtons[nextIndex].control)
                break
            end
        end
    elseif formBar.Visible and (input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down) then
        local options = forms.list(selectedId)
        local current = table.find(options, forms.get(selectedId, previewForm(selectedId))) or 1
        local direction = if input.KeyCode == Enum.KeyCode.Up then -1 else 1
        selectForm(options[(current - 1 + direction) % #options + 1])
    elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.Right then
        local order = selectionOrder()
        local index = table.find(order, selectedId) or 1
        local direction = if input.KeyCode == Enum.KeyCode.Left then -1 else 1
        showFighter(order[(index - 1 + direction) % #order + 1])
    end
end)

local function focus()
    local selected = GuiService.SelectedObject
    if panel.Visible and focusNavigation() and not GuiService.MenuIsOpen
        and (not selected or not selected.Visible or not selected:IsDescendantOf(panel)) then
        GuiService.SelectedObject = selectedCard()
    end
end
GuiService.MenuClosed:Connect(function() task.defer(focus) end)

local rosterDirections = {
    [Enum.KeyCode.DPadUp] = "NextSelectionUp", [Enum.KeyCode.DPadDown] = "NextSelectionDown",
    [Enum.KeyCode.DPadLeft] = "NextSelectionLeft", [Enum.KeyCode.DPadRight] = "NextSelectionRight",
}
local function navigatePicker(_, state, input)
    if not panel.Visible or GuiService.MenuIsOpen then
        return Enum.ContextActionResult.Pass
    end
    if input.KeyCode == Enum.KeyCode.ButtonL1 or input.KeyCode == Enum.KeyCode.ButtonR1 then
        if state == Enum.UserInputState.Begin then
            changePage(if input.KeyCode == Enum.KeyCode.ButtonL1 then -1 else 1)
        end
        return Enum.ContextActionResult.Sink
    end
    local current = GuiService.SelectedObject
    if not current or not current:IsDescendantOf(panel) then
        if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end
        current = selectedCard()
        GuiService.SelectedObject = current
    end
    if input.KeyCode == Enum.KeyCode.ButtonA and (current == confirm or current.Parent == rosterBar) then
        if state == Enum.UserInputState.Begin then
            if current == confirm then confirmChoice() else showFighter(current.Name) end
        end
        return Enum.ContextActionResult.Sink
    end
    local direction = rosterDirections[input.KeyCode]
    if direction then
        local target = current[direction]
        if target and target.Visible and target.Selectable and target:IsDescendantOf(panel) then
            if state == Enum.UserInputState.Begin and not inFlight
                and player:GetAttribute("StarterSelectionPending") ~= true then
                if target.Parent == rosterBar then showFighter(target.Name) end
                GuiService.SelectedObject = target
                task.defer(function()
                    if panel.Visible and target.Visible and not GuiService.MenuIsOpen
                        and not GuiService.SelectedObject then
                        GuiService.SelectedObject = target
                    end
                end)
            end
            return Enum.ContextActionResult.Sink
        end
    end
    return Enum.ContextActionResult.Pass
end
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
    focus()
    if panel.Visible and selectedId then buttons() end
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

local function show(asSwitch)
    switching = asSwitch
    heading.Text = if switching then "Switch fighter" else "Choose your fighter"
    close.Visible = switching
    lastError = player:GetAttribute("StarterSelectionError") or ""
    panel.Visible, loading.Visible, screen.Enabled = true, false, true
    lockInput(true)
    ContextActionService:BindActionAtPriority(focusActionName, navigatePicker, false,
        Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonA,
        Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight,
        Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
    if switching then
        ContextActionService:BindActionAtPriority(cancelActionName, function(_, inputState)
            if inputState == Enum.UserInputState.Begin then
                closePicker()
            end
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)
    end
    local active = player:GetAttribute("SelectedStarterFighter")
    selectedId = nil
    showFighter(if switching and table.find(availableOrder, active) then active else starterOrder[1])
    animation = RunService.RenderStepped:Connect(function()
        if previewState == "ready" and motionAllowed() then
            pose(os.clock() - beganAt)
        end
    end)
    layout()
    if not switching and focusNavigation() and not GuiService.MenuIsOpen then
        GuiService.SelectedObject = selectedCard()
    end
    focus()
end

local function hide()
    lockInput(false)
    ContextActionService:UnbindAction(focusActionName)
    ContextActionService:UnbindAction(cancelActionName)
    if animation then
        animation:Disconnect()
        animation = nil
    end
    if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(panel) then
        GuiService.SelectedObject = nil
    end
    panel.Visible, loading.Visible, screen.Enabled = false, false, false
    for _, card in cards do
        if card.portrait then portraits.set(card.portrait, nil) end
    end
    inFlight = false
    requestNumber += 1
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
    local open = not loadingSplash and required == false and player:GetAttribute("FighterSelectOpen") == true
    if loadingSplash or (required == false and not open) then
        if screen.Enabled then
            hide()
        end
    elseif required or open then
        if not panel.Visible then
            show(open)
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
player:GetAttributeChangedSignal("FighterSelectOpen"):Connect(synchronize)
player:GetAttributeChangedSignal("SelectedStarterFighter"):Connect(function()
    synchronize()
    if panel.Visible then
        updateLevel()
        buttons()
        layout()
    end
end)
local function readAvailableRoster()
    local encoded = player:GetAttribute("FighterRosterAvailable")
    local order = {}
    if type(encoded) == "string" then
        for _, id in string.split(encoded, ",") do
            if roster.ById[id] then table.insert(order, id) end
        end
    end
    availableOrder = if #order > 0 then order else starterOrder
    if panel.Visible and switching then
        if table.find(availableOrder, selectedId) then
            layout()
        else
            showFighter(availableOrder[1])
        end
        focus()
    end
end
player:GetAttributeChangedSignal("FighterRosterAvailable"):Connect(readAvailableRoster)
readAvailableRoster()
local function readFighterLevels()
    local encoded = player:GetAttribute("FighterRosterLevels")
    if type(encoded) == "string" then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, encoded)
        if ok and type(decoded) == "table" then
            fighterLevels = decoded
        end
    end
    updateLevel()
    if panel.Visible and selectedId then
        buttons()
    end
end
player:GetAttributeChangedSignal("FighterRosterLevels"):Connect(readFighterLevels)
readFighterLevels()
local function readFighterForms()
    local encoded = player:GetAttribute("FighterRosterForms")
    if type(encoded) == "string" then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, encoded)
        if ok and type(decoded) == "table" then
            fighterForms = decoded
        end
    else
        fighterForms = {}
    end
    if panel.Visible and selectedId then
        if screen:GetAttribute("PreviewFighterForm") ~= previewForm(selectedId) then
            drawPreview(selectedId, elements[roster.ById[selectedId].element] or colors.gold)
        end
        updateLevel()
        buttons()
    end
end
player:GetAttributeChangedSignal("FighterRosterForms"):Connect(readFighterForms)
player:GetAttributeChangedSignal("SelectedFighterForm"):Connect(readFighterForms)
local function watchMove(fighterId, attribute)
    player:GetAttributeChangedSignal(attribute):Connect(function()
        if panel.Visible and selectedId == fighterId then
            updateLevel()
            buttons()
        end
    end)
end
for fighterId, group in fighterTactics.ByFighter do
    watchMove(fighterId, group.attribute)
end
for fighterId, loadout in fighterLoadouts.ByFighter do
    watchMove(fighterId, loadout.basic.attribute)
    watchMove(fighterId, loadout.ultimate.attribute)
end
readFighterForms()
player:GetAttributeChangedSignal("HighestFighterLevel"):Connect(function()
    if panel.Visible then
        updateLevel()
        buttons()
        layout()
    end
end)
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
