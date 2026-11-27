local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("CityAdventure")
local adventureNavigation = ReplicatedStorage:WaitForChild("AdventureNavigation")
local backAction = "CloseCityAdventureJournal"
local function bindActivityPrompts(tag, playerAttribute, promptAttribute)
    local function refresh(prompt)
        local active = player:GetAttribute(playerAttribute)
        prompt.Enabled = active ~= nil and prompt:GetAttribute(promptAttribute) == active
    end
    local function refreshAll()
        for _, prompt in CollectionService:GetTagged(tag) do refresh(prompt) end
    end
    CollectionService:GetInstanceAddedSignal(tag):Connect(refresh)
    player:GetAttributeChangedSignal(playerAttribute):Connect(refreshAll)
    refreshAll()
end

bindActivityPrompts("CityAdventureCheckpointPrompt", "CityAdventureCheckpoint", "CityCheckpointId")
bindActivityPrompts("RingTrainingCuePrompt", "RingTrainingActive", "RingTrainingCueId")

local ink = Color3.fromRGB(23, 38, 40)
local raised = Color3.fromRGB(35, 57, 55)
local accent = Color3.fromRGB(86, 148, 125)
local paper = Color3.fromRGB(255, 242, 212)
local muted = Color3.fromRGB(194, 214, 201)
local gold = Color3.fromRGB(246, 194, 104)
local edge = Color3.fromRGB(139, 113, 69)
local dark = Color3.fromRGB(44, 34, 29)

local function create(class, parent, properties)
    local node = Instance.new(class)
    for property, value in properties do
        node[property] = value
    end
    node.Parent = parent
    return node
end

local function decorate(node, radius, color)
    create("UICorner", node, {CornerRadius = UDim.new(0, radius)})
    return create("UIStroke", node, {Color = color, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function label(parent, name, size, tint, bold)
    return create("TextLabel", parent, {
        Name = name, BackgroundTransparency = 1, Text = "", TextSize = size, TextColor3 = tint,
        Font = if bold then Enum.Font.GothamBold else Enum.Font.GothamMedium,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    })
end

local function showFocus(node, rim)
    node.SelectionGained:Connect(function()
        rim.Color, rim.Thickness = paper, 2
    end)
    node.SelectionLost:Connect(function()
        rim.Color, rim.Thickness = edge, 1
    end)
end

local function button(parent, name, copy)
    local node = create("TextButton", parent, {
        Name = name, Text = copy, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = paper,
        BackgroundColor3 = raised, BorderSizePixel = 0, Selectable = true, TextWrapped = true,
    })
    showFocus(node, decorate(node, 8, edge))
    return node
end

local screen = create("ScreenGui", playerGui, {
    Name = "CityAdventureJournal", DisplayOrder = 23, ResetOnSpawn = false,
    ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets, SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local toggle = button(screen, "OpenJournal", "Adventure")
toggle.AnchorPoint, toggle.Size = Vector2.new(1, 0), UDim2.fromOffset(104, 44)
toggle.Position = UDim2.new(1, -8, 0, 44)

local shade = create("Frame", screen, {
    Name = "JournalOverlay", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = .36, BorderSizePixel = 0, Visible = false, Active = true,
})
local panel = create("Frame", shade, {
    Name = "Journal", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    BackgroundColor3 = ink, BorderSizePixel = 0, Active = true,
    SelectionGroup = true, SelectionBehaviorUp = Enum.SelectionBehavior.Stop, SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
    SelectionBehaviorLeft = Enum.SelectionBehavior.Stop, SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
})
decorate(panel, 13, edge)
create("UISizeConstraint", panel, {MaxSize = Vector2.new(680, 590)})

local heading = label(panel, "Title", 25, gold, true)
heading.Text, heading.Position, heading.Size = "Adventure Journal", UDim2.fromOffset(14, 13), UDim2.new(1, -110, 0, 33)
local close = button(panel, "CloseJournal", "Close")
close.AnchorPoint = Vector2.new(1, 0)
close.Position, close.Size = UDim2.new(1, -12, 0, 9), UDim2.fromOffset(76, 44)

local progress = label(panel, "Progress", 13, muted, false)
progress.Position, progress.Size = UDim2.fromOffset(14, 55), UDim2.new(1, -28, 0, 20)

local tabBar = create("Frame", panel, {
    Name = "Tabs", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 80), Size = UDim2.new(1, -28, 0, 44),
})
local tabs = {}
local tabNames = {"Chapters", "Treasures", "Festival"}
for index, name in ipairs(tabNames) do
    local tab = button(tabBar, name, name)
    tab.Position, tab.Size = UDim2.new((index - 1) / 3, 2, 0, 0), UDim2.new(1 / 3, -4, 0, 44)
    tab.NextSelectionUp = close
    tabs[index] = tab
end
for index, tab in ipairs(tabs) do
    tab.NextSelectionLeft, tab.NextSelectionRight = tabs[index - 1], tabs[index + 1]
end

local scroll = create("ScrollingFrame", panel, {
    Name = "JournalEntries", Position = UDim2.fromOffset(14, 134), Size = UDim2.new(1, -28, 1, -146),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollingDirection = Enum.ScrollingDirection.Y,
    CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 5,
    ScrollBarImageColor3 = gold, VerticalScrollBarInset = Enum.ScrollBarInset.Always, ClipsDescendants = true,
    Selectable = false,
})
create("UIPadding", scroll, {PaddingBottom = UDim.new(0, 6)})
create("UIListLayout", scroll, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7)})

local toast = label(screen, "AdventureNotice", 14, paper, true)
toast.AnchorPoint = Vector2.new(.5, 1)
toast.Position, toast.Size = UDim2.new(.5, 0, 1, -124), UDim2.new(.82, 0, 0, 44)
toast.TextXAlignment, toast.TextYAlignment = Enum.TextXAlignment.Center, Enum.TextYAlignment.Center
toast.BackgroundColor3, toast.BackgroundTransparency, toast.Visible, toast.ZIndex = ink, .08, false, 3
create("UISizeConstraint", toast, {MaxSize = Vector2.new(390, 44)})
create("UIPadding", toast, {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
decorate(toast, 8, edge)

local trailChip = label(screen, "ActiveTrail", 13, paper, true)
trailChip.AnchorPoint = Vector2.new(1, 0)
trailChip.Position, trailChip.Size = UDim2.new(1, -8, 0, 95), UDim2.new(.57, 0, 0, 54)
trailChip.TextXAlignment, trailChip.TextYAlignment = Enum.TextXAlignment.Center, Enum.TextYAlignment.Center
trailChip.BackgroundColor3, trailChip.BackgroundTransparency, trailChip.Visible = ink, .08, false
create("UISizeConstraint", trailChip, {MaxSize = Vector2.new(263, 54)})
create("UIPadding", trailChip, {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
decorate(trailChip, 8, edge)

local guidedCard = create("Frame", screen, {
    Name = "AdventureCard", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 95),
    Size = UDim2.fromOffset(210, 97), BackgroundColor3 = ink, BackgroundTransparency = .04,
    BorderSizePixel = 0, Visible = false,
})
decorate(guidedCard, 10, edge)
local guidedTitle = label(guidedCard, "Objective", 15, gold, true)
guidedTitle.Position, guidedTitle.Size = UDim2.fromOffset(10, 7), UDim2.new(1, -21, 0, 20)
local guidedDetail = label(guidedCard, "Directions", 12, paper, false)
guidedDetail.Position, guidedDetail.Size = UDim2.fromOffset(10, 29), UDim2.new(1, -20, 0, 20)
local guidedAction = button(guidedCard, "PrimaryAction", "Track Relay")
guidedAction.Position, guidedAction.Size = UDim2.fromOffset(8, 47), UDim2.new(1, -66, 0, 44)
local guidedClose = button(guidedCard, "HideObjective", "×")
guidedClose.Position, guidedClose.Size = UDim2.new(1, -50, 0, 47), UDim2.fromOffset(44, 44)
guidedAction.NextSelectionRight, guidedClose.NextSelectionLeft = guidedClose, guidedAction
guidedAction.NextSelectionUp, guidedClose.NextSelectionUp = toggle, toggle
toggle.NextSelectionDown = guidedAction

local waypoint = create("Part", workspace, {
    Name = "LocalAdventureWaypoint", Size = Vector3.new(.2, .2, .2), Anchored = true, Transparency = 1,
    CanCollide = false, CanTouch = false, CanQuery = false, CastShadow = false,
})
local flag = create("BillboardGui", waypoint, {
    Name = "NextObjective", Size = UDim2.fromOffset(104, 26), MaxDistance = 100, Enabled = false,
    LightInfluence = 0, StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0),
})
local flagText = label(flag, "Label", 13, gold, true)
flagText.Size, flagText.BackgroundColor3, flagText.BackgroundTransparency = UDim2.fromScale(1, 1), ink, .08
flagText.TextXAlignment, flagText.TextYAlignment = Enum.TextXAlignment.Center, Enum.TextYAlignment.Center
flagText.Text = "Next objective"
decorate(flagText, 6, edge)
screen.Destroying:Connect(function()
    waypoint:Destroy()
    ContextActionService:UnbindAction(backAction)
    player:SetAttribute("CityAdventureJournalOpen", nil)
end)

local busyAttributes = {
    "SparringActive", "BrawlActive", "BrawlRecapOpen", "TagTeamActive", "TagTeamOfferOpen", "TagTeamRecapOpen",
    "KilnbackRaidActive", "KilnbackRaidRecapOpen", "StarterSelectionRequired", "StarterSelectionPending", "FighterSelectOpen",
    "DuelQueued", "BrawlQueued", "TagTeamQueued", "KilnbackRaidQueued", "DuelTransferHold", "RingTrainingActive", "RingTrainingPending",
}
local conflictingPanels = {
    EventPanel = true, EagleEyeView = true, RelayStatus = true, SparringPicker = true,
    SparringResult = true, DuelFormatPicker = true, CloudbreakStatus = true,
}

local snapshot
local activeTab = 1
local previousSelection
local rowNodes = {}
local navigation = {}
local focusById = {}
local noticeUntil = 0
local goalPosition
local deadlineLabel
local festivalLabel
local cacheTag = "CityAdventureCachePrompt"
local cacheReadyAt, cacheVisuals = {}, {}
local lidParts = {["Carved cedar lid"] = true, ["Raised lid rim"] = true, ["Bronze lid strap"] = true}

local function refreshCache(prompt, now)
    local anchor = prompt.Parent
    local id = prompt:GetAttribute("CityCacheId")
    local lid = anchor and anchor:FindFirstChild("Carved cedar lid")
    if not id or not lid then return false end
    local opened = (cacheReadyAt[id] or 0) > now
    local state = cacheVisuals[prompt]
    if not state then
        local hinge = lid.CFrame * CFrame.new(0, -lid.Size.Y / 2, -lid.Size.Z * .47)
        state = {parts = {}, swing = hinge * CFrame.Angles(math.rad(-66), 0, 0) * hinge:Inverse()}
        cacheVisuals[prompt] = state
    end
    local changed = state.opened ~= opened
    for _, part in anchor:GetChildren() do
        if lidParts[part.Name] and part:IsA("BasePart") and not state.parts[part] then
            state.parts[part] = part.CFrame
            if opened then part.CFrame = state.swing * part.CFrame end
        end
    end
    if not changed then return false end
    state.opened = opened
    prompt.ActionText = if opened then "View reset time" else "Open cache"
    for part, closed in state.parts do
        part.CFrame = if opened then state.swing * closed else closed
    end
    return true
end

CollectionService:GetInstanceRemovedSignal(cacheTag):Connect(function(prompt)
    local state = cacheVisuals[prompt]
    if state and state.opened then
        for part, closed in state.parts do
            if part.Parent then part.CFrame = closed end
        end
    end
    cacheVisuals[prompt] = nil
end)

local function cacheStatus(readyAt, found)
    local minutes = math.ceil(((tonumber(readyAt) or 0) - workspace:GetServerTimeNow()) / 60)
    if minutes > 0 then return string.format("Open · resets in %dh %02dm", math.floor(minutes / 60), minutes % 60) end
    return if found then "Ready to open" else nil
end

local function gamepad()
    return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad or UserInputService.VREnabled
end

local function available()
    if player:GetAttribute("TrophyRoomActive") then return false end
    for _, attribute in ipairs(busyAttributes) do
        if player:GetAttribute(attribute) then return false end
    end
    local splash = playerGui:FindFirstChild("BeastDojoSplash")
    if splash and splash.Enabled then return false end
    local existing = playerGui:FindFirstChild("GrandDojo")
    if existing and existing.Enabled then
        for name in conflictingPanels do
            local node = existing:FindFirstChild(name)
            if node and node.Visible then return false end
        end
    end
    return true
end

local function focus(node)
    if gamepad() then
        GuiService.SelectedObject = node or tabs[activeTab]
    end
end

local function integer(value)
    return if type(value) == "number" and value >= 0 and value < math.huge then math.floor(value) else 0
end

local function body(value)
    return if type(value) == "string" then value else ""
end

local function fields(value)
    return if type(value) == "table" then value else {}
end

local function counted(value, singular, plural)
    local count = integer(value)
    return string.format("%d %s", count, if count == 1 then singular else plural)
end

local function updateProgress()
    if workspace:GetServerTimeNow() < noticeUntil then
        progress.Text = toast.Text
    elseif snapshot and snapshot.saving then
        progress.Text = "Saving adventure progress…"
    elseif snapshot then
        local totals = fields(snapshot.totals)
        progress.Text = table.concat({counted(totals.chapters, "chapter", "chapters"), counted(totals.seals, "seal", "seals"),
            counted(totals.caches, "treasure", "treasures")}, "  ·  ")
    else
        progress.Text = "Loading adventure progress…"
    end
end

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function secondsLeft(at)
    if not finite(at) then return nil end
    return math.max(0, math.ceil(at - workspace:GetServerTimeNow()))
end

local function timerText(at)
    local value = secondsLeft(at)
    return if value then string.format("%d:%02d", math.floor(value / 60), value % 60) else ""
end

local function activeCourse(trail)
    return type(trail) == "table" and finite(trail.deadline)
end

local function trailText(trail)
    local name = body(trail.name)
    local remaining = timerText(trail.deadline)
    local total = integer(trail.total or trail.goal)
    if total > 0 then name ..= string.format("  ·  %d/%d", integer(trail.next), total) end
    if remaining ~= "" then name ..= "  ·  " .. remaining end
    return name
end

local function waypointFor(trail)
    local point = fields(fields(trail).goal)
    if not (finite(point.x) and finite(point.y) and finite(point.z)) then return nil end
    return Vector3.new(point.x, point.y, point.z)
end

local function updateTimers()
    local trail = snapshot and snapshot.trail
    if type(trail) == "table" then
        local title = trailText(trail)
        if deadlineLabel then deadlineLabel.Text = title end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local hint = body(trail.hint)
        if root and goalPosition then
            hint = string.format("%d studs%s", math.floor((root.Position - goalPosition).Magnitude + .5),
                if hint == "" then "" else "  ·  " .. hint)
        end
        trailChip.Text = if hint == "" then title else title .. "\n" .. hint
    end
    local festival = snapshot and snapshot.festival
    if festivalLabel and type(festival) == "table" then
        local time = timerText(if festival.active then festival.endsAt else festival.nextAt)
        festivalLabel.Text = if festival.active then (if time ~= "" then "Ends in " .. time else "Open now")
            else (if time ~= "" then "Next festival in " .. time else "Festival closed")
    end
end

local function reveal(node)
    local top = node.AbsolutePosition.Y - scroll.AbsolutePosition.Y
    local excess = top + node.AbsoluteSize.Y - scroll.AbsoluteWindowSize.Y
    if top < 0 or excess > 0 then
        local maximum = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
        scroll.CanvasPosition = Vector2.new(0, math.clamp(scroll.CanvasPosition.Y + (if top < 0 then top else excess),
            0, maximum))
    end
end

local function markNavigation(node, id)
    table.insert(navigation, node)
    focusById[id] = node
    node:SetAttribute("JournalFocusId", id)
    node.SelectionGained:Connect(function() reveal(node) end)
end

local function card(id, title, subtitle, description, actions)
    local node = create("Frame", scroll, {
        Name = id, LayoutOrder = #rowNodes + 1, Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = raised, BorderSizePixel = 0, Selectable = not actions or #actions == 0,
    })
    table.insert(rowNodes, node)
    local rim = decorate(node, 9, edge)
    create("UIPadding", node, {
        PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9),
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
    })
    create("UIListLayout", node, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
    local function line(name, copy, size, tint, bold, order)
        local text = label(node, name, size, tint, bold)
        text.Text, text.LayoutOrder = copy, order
        text.Size, text.AutomaticSize = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y
        return text
    end
    line("Heading", title, 17, gold, true, 1)
    local sub = if subtitle ~= "" then line("Status", subtitle, 13, muted, true, 2) else nil
    if description ~= "" then line("Detail", description, 14, paper, false, 3) end
    if node.Selectable then
        showFocus(node, rim)
        markNavigation(node, id)
    else
        for index, action in ipairs(actions) do
            local control = button(node, action.name, action.label)
            control.LayoutOrder, control.Size = 3 + index, UDim2.fromOffset(action.width or 128, 44)
            control.Activated:Connect(action.run)
            markNavigation(control, if index == 1 then id else id .. "-" .. action.name)
        end
    end
    return sub
end

local function districts()
    return if snapshot and type(snapshot.districts) == "table" then snapshot.districts else {}
end

local hide

local function chapterCards()
    local trail = snapshot.trail
    if type(trail) == "table" then
        local running = activeCourse(trail)
        local actions = if running then {{name = "Action", label = "Cancel trail", run = function() remote:FireServer("cancel") end}} else nil
        deadlineLabel = card("trail", if running then "Active trail" else "Tracked objective", trailText(trail), body(trail.hint), actions)
    end
    local guide = snapshot.guided
    card("relay", "Lantern Relay", if snapshot.relayEarned then "Lantern Keeper earned" else "First clear",
        "Cross the red bridge to the Relay arch. First clear earns Lantern Keeper, 80 XP and 60 Coins.",
        if guide and guide.goal == "relay" then nil else {{
            name = "TrackRelay", label = "Track Relay", run = function()
                remote:FireServer("guided-goal", "relay")
                hide()
            end,
        }})
    for _, district in ipairs(districts()) do
        local id = body(district.id)
        local completed = math.clamp(integer(district.step), 0, 3)
        local note = if completed == 3 then "Chapter complete" else string.format("%d/3 steps", completed)
        if body(district.mentor) ~= "" then note ..= "  ·  " .. district.mentor end
        if snapshot.tracked == id then note ..= "  ·  Tracked" end
        local lines = {}
        for _, value in {body(district.chapter), body(district.objective), body(district.story)} do
            if value ~= "" then table.insert(lines, value) end
        end
        for _, activity in ipairs(fields(district.activities)) do
            local name = body(activity.name)
            if name ~= "" then
                local best = activity.bestSeconds
                local status = if type(best) == "number" and best > 0 and best < math.huge then string.format("Best %.1fs", best)
                    elseif activity.completed then "Completed" else "Available"
                table.insert(lines, name .. "  ·  " .. status)
            end
        end
        local actions = {}
        if id ~= "" and snapshot.tracked ~= id then
            table.insert(actions, {name = "Action", label = "Track", run = function() remote:FireServer("track", id) end})
        end
        if id ~= "" and district.canTravel == true and not activeCourse(trail) then
            table.insert(actions, {
                name = "Travel", label = if id == "valley" then "Return to Grand Dojo" else "Travel to district", width = 176,
                run = function()
                    if player:GetAttribute("CityAdventureActive") or activeCourse(snapshot and snapshot.trail) then return end
                    remote:FireServer("travel", id)
                    hide()
                end,
            })
        end
        card("chapter-" .. id, body(district.name), note, table.concat(lines, "\n"), actions)
    end
end

local function treasureCards()
    local totals = fields(snapshot.totals)
    card("grand-treasure", "Grand Treasure", cacheStatus(snapshot.grandCacheReadyAt, snapshot.grandCache)
        or string.format("%d/6 district treasures", integer(totals.caches)),
        if integer(totals.caches) < 6 then "Recover the six district treasures, then open the grand cache in Dojo Valley."
        else "95% chance of 20–40 XP. 5% chance of 1,000 XP. Resets 48 hours after opening.")
    local cloudbreak = snapshot.cloudbreak
    if type(cloudbreak) == "table" and integer(cloudbreak.best) > 0 then
        local equipped = cloudbreak.equipped == true
        local records = string.format("Best %.1fs", integer(cloudbreak.best) / 10)
        if integer(cloudbreak.cleanBest) > 0 then records ..= string.format("  ·  Clean %.1fs", integer(cloudbreak.cleanBest) / 10) end
        local actions = if activeCourse(snapshot.trail) then nil else {{
            name = "Sash", label = if equipped then "Remove sash" else "Equip sash",
            run = function()
                if not player:GetAttribute("CityAdventureActive") then remote:FireServer("sash", not equipped) end
            end,
        }}
        card("cloudbreak", "Cloudbreak Expert", records, "Summit Sash earned", actions)
    else
        card("cloudbreak", "Cloudbreak Expert", "", "Finish an Expert run to earn the Summit Sash.")
    end
    for _, district in ipairs(districts()) do
        local seals, treasure = fields(district.seals), fields(district.treasure)
        local note = string.format("%d/%d seals", integer(seals.count), integer(seals.total))
        local lines = {}
        for _, clue in ipairs(fields(seals.clues)) do
            local copy = if type(clue) == "table" then body(clue.clue or clue.text) else body(clue)
            if copy ~= "" then
                table.insert(lines, (if type(clue) == "table" and clue.found then "Found  ·  " else "") .. copy)
            end
        end
        local status = cacheStatus(treasure.readyAt, treasure.found)
        if status then table.insert(lines, status) end
        if not status and body(treasure.clue) ~= "" then
            table.insert(lines, "Treasure clue  ·  " .. treasure.clue)
        end
        card("treasure-" .. body(district.id), body(district.name), note, table.concat(lines, "\n"))
    end
end

local function festivalCards()
    local festival = snapshot.festival
    if type(festival) ~= "table" then
        card("festival", "Training Festival", "", "Festival progress is unavailable.")
        return
    end
    local title = string.format("%d/3 festival stamps", math.clamp(integer(festival.count), 0, 3))
    local lines = {if festival.earned then "Festival Regular earned" else "Complete three different festival activities."}
    local courses = {"Lantern Relay", "Cloudbreak Expert"}
    local timing, deliveries = {}, {}
    local groups = {route = courses, slide = courses, timing = timing, sequence = timing, delivery = deliveries}
    local stamped = {}
    for _, name in ipairs(fields(festival.stampIds)) do
        if type(name) == "string" then stamped[name] = true end
    end
    for _, district in ipairs(districts()) do
        for _, activity in ipairs(fields(district.activities)) do
            local group = groups[activity.kind]
            if group then table.insert(group, body(activity.name)) end
        end
    end
    card("festival", "Training Festival", title, table.concat(lines, "\n"))
    -- Keep the timer on its own row so the stamp count remains visible when the timer updates.
    festivalLabel = card("festival-window", if festival.active then "Festival open" else "Next festival", "Checking schedule…", "")
    for _, group in ipairs({{"Courses", courses}, {"Timing & puzzles", timing}, {"Deliveries", deliveries}}) do
        local entries = {}
        for _, name in ipairs(group[2]) do
            table.insert(entries, name .. (if stamped[name] then "  ·  Stamped" else ""))
        end
        if #entries > 0 then card("festival-" .. group[1], group[1], "", table.concat(entries, "\n")) end
    end
end

local function render(resetScroll)
    local selected = GuiService.SelectedObject
    local id = selected and selected:IsDescendantOf(scroll) and selected:GetAttribute("JournalFocusId")
    local priorCanvas = scroll.CanvasPosition
    for _, node in ipairs(rowNodes) do node:Destroy() end
    table.clear(rowNodes)
    table.clear(navigation)
    table.clear(focusById)
    deadlineLabel, festivalLabel = nil, nil
    for index, tab in ipairs(tabs) do
        tab.BackgroundColor3 = if index == activeTab then gold else raised
        tab.TextColor3 = if index == activeTab then dark else paper
    end
    if not snapshot then
        card("loading", "Adventure progress", "", "Your journal will update when progression is available.")
    else
        if activeTab == 1 then chapterCards() elseif activeTab == 2 then treasureCards() else festivalCards() end
        if #rowNodes == 0 then card("empty", "Adventure progress", "", "No entries are available yet.") end
    end
    close.NextSelectionDown = tabs[activeTab]
    for _, tab in ipairs(tabs) do tab.NextSelectionDown = navigation[1] end
    for index, node in ipairs(navigation) do
        node.NextSelectionUp = navigation[index - 1] or tabs[activeTab]
        node.NextSelectionDown = navigation[index + 1] or tabs[activeTab]
    end
    scroll.CanvasPosition = if resetScroll then Vector2.zero else priorCanvas
    if id then focus(focusById[id]) end
    updateProgress()
    updateTimers()
end

local function syncVisibility()
    local ready = available()
    local guide = snapshot and snapshot.guided
    local showGuide = ready and not shade.Visible and guide ~= nil and snapshot.trail == nil
    toggle.Visible = ready and not shade.Visible
    trailChip.Visible = ready and not shade.Visible and snapshot ~= nil and type(snapshot.trail) == "table"
    guidedCard.Visible = showGuide
    flag.Enabled = (trailChip.Visible or showGuide) and goalPosition ~= nil
    if showGuide then
        local trophy = guide.goal == "trophy"
        local suggested = guide.goal == "suggested"
        guidedTitle.Text = if trophy then "Lantern Keeper earned" else "Lantern Relay"
        guidedDetail.Text = if guide.saving then "Saving your goal…"
            elseif trophy then "On display in Trophy Hall"
            elseif suggested then "80 XP · 60 Coins · Trophy" else "Cross the red bridge to the arch"
        guidedAction.Text = if trophy then "View Trophy" elseif suggested then "Track Relay" else "Adventure Journal"
        guidedAction.Active, guidedClose.Active = not guide.saving, not guide.saving
    end
    toast.Visible = ready and not shade.Visible and workspace:GetServerTimeNow() < noticeUntil
end

hide = function()
    if not shade.Visible then return end
    local picked = GuiService.SelectedObject
    shade.Visible = false
    ContextActionService:UnbindAction(backAction)
    player:SetAttribute("CityAdventureJournalOpen", nil)
    syncVisibility()
    if (not GuiService.SelectedObject or GuiService.SelectedObject == picked) and picked and picked:IsDescendantOf(shade) then
        GuiService.SelectedObject = if previousSelection and previousSelection.Parent and previousSelection.Visible
            then previousSelection else nil
    end
    previousSelection = nil
end

local function show(tab)
    if not available() then return end
    if not shade.Visible then
        previousSelection = GuiService.SelectedObject
        shade.Visible = true
        player:SetAttribute("CityAdventureJournalOpen", true)
        ContextActionService:BindActionAtPriority(backAction, function(_, state)
            if state == Enum.UserInputState.Begin then hide() end
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)
    end
    if tab then activeTab = tab end
    render(true)
    focus()
    syncVisibility()
end

local function askView()
    show()
    if shade.Visible then remote:FireServer("view") end
end

local function layout()
    local size = screen.AbsoluteSize
    local compact = UserInputService.TouchEnabled and not UserInputService.VREnabled
        and (size.X < 780 or size.Y < 520)
    guidedCard.AnchorPoint = if compact then Vector2.zero else Vector2.new(1, 0)
    guidedCard.Position = if compact then UDim2.fromOffset(8, 88) else UDim2.new(1, -8, 0, 95)
    panel.Size = UDim2.new(.96, 0, 0, math.max(160, math.min(590, size.Y - 14)))
    heading.TextSize = if size.X < 330 then 18 elseif size.X < 420 then 21 else 25
    progress.TextSize = if size.X < 370 then 12 else 13
end

for index, tab in ipairs(tabs) do
    tab.Activated:Connect(function()
        if not shade.Visible then return end
        activeTab = index
        render(true)
        focus(tab)
    end)
end
close.Activated:Connect(hide)
toggle.Activated:Connect(askView)
guidedAction.Activated:Connect(function()
    local guide = snapshot and snapshot.guided
    if not guide or guide.saving or not guidedCard.Visible then return end
    if guide.goal == "trophy" then
        adventureNavigation:Fire("view-trophy")
    elseif guide.goal == "suggested" then
        remote:FireServer("guided-goal", "relay")
    else
        askView()
    end
end)
guidedClose.Activated:Connect(function()
    if guidedCard.Visible and snapshot.guided and not snapshot.guided.saving then
        remote:FireServer("guided-goal", "hidden")
    end
end)
adventureNavigation.Event:Connect(function(action)
    if action == "next-activity" then
        show(1)
        if shade.Visible then remote:FireServer("view") end
    elseif action == "track-relay" then
        remote:FireServer("guided-goal", "relay")
    end
end)
UserInputService.InputBegan:Connect(function(input, consumed)
    if consumed or UserInputService:GetFocusedTextBox() then return end
    local key = input.KeyCode
    if shade.Visible and (key == Enum.KeyCode.Backspace or key == Enum.KeyCode.J) then
        hide()
    elseif not shade.Visible and key == Enum.KeyCode.J then
        askView()
    end
end)
local function deviceChanged()
    if shade.Visible and gamepad() then
        local selected = GuiService.SelectedObject
        if not selected or not selected:IsDescendantOf(shade) then focus() end
    end
end
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(deviceChanged)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(deviceChanged)
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
player.CharacterRemoving:Connect(hide)

local function updateAvailability()
    if shade.Visible and not available() then hide() end
    syncVisibility()
end
for _, attribute in ipairs(busyAttributes) do
    player:GetAttributeChangedSignal(attribute):Connect(updateAvailability)
end
local function watchPanel(node)
    if node.Name == "BeastDojoSplash" and node.Parent == playerGui and node:IsA("ScreenGui") then
        node:GetPropertyChangedSignal("Enabled"):Connect(updateAvailability)
        updateAvailability()
    elseif conflictingPanels[node.Name] and node.Parent and node.Parent.Name == "GrandDojo" and node:IsA("GuiObject") then
        node:GetPropertyChangedSignal("Visible"):Connect(updateAvailability)
        updateAvailability()
    end
end
for _, node in ipairs(playerGui:GetDescendants()) do watchPanel(node) end
playerGui.DescendantAdded:Connect(watchPanel)
playerGui.ChildRemoved:Connect(function(node)
    if node.Name == "BeastDojoSplash" then updateAvailability() end
end)

remote.OnClientEvent:Connect(function(kind, packet)
    if type(packet) ~= "table" then return end
    if kind == "open" or kind == "state" then
        snapshot = packet
        cacheReadyAt.grand = packet.grandCacheReadyAt
        for _, district in ipairs(fields(packet.districts)) do
            cacheReadyAt[district.id] = fields(district.treasure).readyAt
        end
        local guide = packet.guided
        local position = waypointFor(packet.trail or (guide and {goal = guide.point}))
        if position and position ~= goalPosition then waypoint.Position = position end
        goalPosition = position
        flagText.Text = if packet.trail or not guide then "Next objective"
            elseif guide.goal == "trophy" then "Trophy Hall" else "Relay start"
        if kind == "open" then
            local tab = if packet.openTab == "chapters" then 1 elseif packet.openTab == "treasures" then 2
                elseif packet.openTab == "festival" then 3 else nil
            show(tab)
            if tab == 2 and type(packet.openCache) == "string" then
                local id = if packet.openCache == "grand" then "grand-treasure" else "treasure-" .. packet.openCache
                task.defer(function()
                    local target = focusById[id]
                    if target and shade.Visible and activeTab == 2 then
                        reveal(target)
                        focus(target)
                    end
                end)
            end
        elseif shade.Visible then
            render(false)
        end
        updateTimers()
        syncVisibility()
    elseif kind == "notice" and body(packet.message) ~= "" then
        toast.Text = packet.message
        noticeUntil = workspace:GetServerTimeNow() + 4.5
        if shade.Visible then updateProgress() end
        syncVisibility()
    end
end)
remote:FireServer("view")

local elapsed = 0
RunService.Heartbeat:Connect(function(delta)
    elapsed += delta
    if elapsed < .25 then return end
    elapsed = 0
    local changed = false
    local now = workspace:GetServerTimeNow()
    for _, prompt in CollectionService:GetTagged(cacheTag) do
        if refreshCache(prompt, now) then changed = true end
    end
    if changed and shade.Visible and activeTab == 2 then render(false) end
    if shade.Visible or trailChip.Visible then updateTimers() end
    if noticeUntil > 0 and workspace:GetServerTimeNow() >= noticeUntil then
        noticeUntil = 0
        if shade.Visible then updateProgress() end
        toast.Visible = false
    end
end)
layout()
updateAvailability()
