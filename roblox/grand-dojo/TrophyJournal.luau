-- Owner-only Trophy Hall view. The stable IDs mirror the world design catalog.
-- This module reads server-projected attributes and never requests an award.
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local TrophyJournal = {}
TrophyJournal.__index = TrophyJournal

local categories = {
    {"Journey", {
        {"journey-01", "First Footing", "Complete the introductory mentor quest."},
        {"journey-02", "A Chapter Begins", "Complete the three-step Dojo Valley mentor chapter."},
        {"journey-03", "Six Horizons", "Discover the arrival checkpoint in all six districts."},
        {"journey-04", "A New Form", "Complete the first server-confirmed fighter evolution."},
        {"journey-05", "Mentors Remember", "Complete all six mentor chapters."},
        {"journey-06", "Dojo Graduate", "Complete the graduation quest after the six mentor chapters."},
    }},
    {"Discovery", {
        {"discovery-valley", "Dojo Valley Explorer", "Find all three permanent seals in Dojo Valley."},
        {"discovery-coast", "Tideharbor Coast Explorer", "Find all three permanent seals in Tideharbor Coast."},
        {"discovery-cinder", "Cinder Terraces Explorer", "Find all three permanent seals in Cinder Terraces."},
        {"discovery-sky", "Skywalk Peaks Explorer", "Find all three permanent seals in Skywalk Peaks."},
        {"discovery-frost", "Frostglass Gardens Explorer", "Find all three permanent seals in Frostglass Gardens."},
        {"discovery-circuit", "Lantern Circuit Explorer", "Find all three permanent seals in Lantern Circuit."},
    }},
    {"Mastery", {
        {"mastery-valley", "Dojo Valley Master", "Complete the validated Reed-path expert course."},
        {"mastery-coast", "Tideharbor Coast Master", "Complete the validated Tide-path expert course."},
        {"mastery-cinder", "Cinder Terraces Master", "Complete the validated Steam-lift expert course."},
        {"mastery-sky", "Skywalk Peaks Master", "Finish Cloudbreak Wind Trial in Expert mode and ring the summit bell."},
        {"mastery-frost", "Frostglass Gardens Master", "Complete the validated Ice-slide expert course."},
        {"mastery-circuit", "Lantern Circuit Master", "Complete the validated Rooftop expert course."},
    }},
    {"Arena", {
        {"arena-01", "First Duel", "Win one eligible completed duel."},
        {"arena-02", "Ring Reader", "Finish in the top three of an eligible eight-player brawl."},
        {"arena-03", "Tag Partners", "Win one eligible tag-team match."},
        {"arena-04", "Ten Duels", "Win ten eligible duels. Each result counts once."},
        {"arena-05", "Steady Guard", "Perform ten validated parries across eligible completed encounters."},
        {"arena-06", "Ring Veteran", "Complete twenty eligible arena matches with participation credit."},
    }},
    {"World challenges", {
        {"world-01", "Kiln Keeper", "Earn participation credit for clearing the Kilnback Custodian encounter."},
        {"world-02", "Deepwater Team", "Earn participation credit for clearing the Abyssal Kraken encounter."},
        {"world-03", "Dawn Return", "Earn participation credit for clearing the Solar Phoenix encounter."},
        {"world-04", "Lantern Keeper", "Finish one official Lantern Relay with all seven gates validated."},
        {"world-05", "Festival Regular", "Complete three validated Training Festival activities. Each result counts once."},
        {"world-06", "World Champion", "Earn all three boss-clear trophies and both world-event trophies."},
    }},
}

local raidAwards = {
    ["world-01"] = {attribute = "KilnKeeper", boss = "Kilnback Custodian"},
    ["world-02"] = {attribute = "DeepwaterTeam", boss = "Abyssal Kraken"},
    ["world-03"] = {attribute = "DawnReturn", boss = "Solar Phoenix"},
}

local function describe(player, id)
    local adventureAwards = player:GetAttribute("CityAdventureAwards")
    if type(adventureAwards) == "string" and string.find("," .. adventureAwards .. ",", "," .. id .. ",", 1, true) then
        if id == "mastery-sky" then
            local best = player:GetAttribute("CityAdventureCloudbreakBest")
            local clean = player:GetAttribute("CityAdventureCleanBest")
            local note = if type(best) == "number" then string.format("Best: %.1fs.", best) else "Expert clear saved."
            if type(clean) == "number" then note ..= string.format(" Clean best: %.1fs.", clean) end
            return if player:GetAttribute("ProgressMode") == "studio" then "Studio award" else "Earned", note
        end
        local isAdventure = string.match(id, "^discovery%-") ~= nil or string.match(id, "^mastery%-") ~= nil
            or id == "journey-01" or id == "journey-02" or id == "journey-03" or id == "journey-05"
            or id == "journey-06" or id == "world-05" or id == "world-06"
        if isAdventure then
            return if player:GetAttribute("ProgressMode") == "studio" then "Studio award" else "Earned",
                "Recorded in your collection."
        end
    end
    local award = raidAwards[id]
    if award then
        if player:GetAttribute(award.attribute) == true then
            return if player:GetAttribute("ProgressMode") == "studio" then "Studio award" else "Earned",
                "Awarded for an eligible " .. award.boss .. " clear."
        end
        local progress = player:GetAttribute("ProgressStatus")
        if progress == "ready" or progress == "saved" then
            return "Locked", "Defeat " .. award.boss .. " with damage or revive credit."
        elseif progress == "saving" then
            return "Updating", "Waiting for the raid reward to save."
        end
        return "Waiting", "The journal will update when progression is available."
    elseif id == "journey-04" then
        if player:GetAttribute("FighterNewForm") == true then
            if player:GetAttribute("ProgressMode") == "studio" then
                return "Studio award", "Earned by equipping an evolved form in this playtest."
            end
            return "Earned", "Your first evolved form earned this permanent trophy."
        end
        local progress = player:GetAttribute("ProgressStatus")
        if progress == "saving" then
            return "Updating", "Waiting for your form choice to save."
        elseif progress == "ready" or progress == "saved" then
            return "Locked", "Reach Level 5 with Reedguard, then equip Warrior in Fighter Select."
        end
        return "Waiting", "The journal will update when progression is available."
    elseif id == "world-04" then
        if player:GetAttribute("LanternKeeper") == true then
            if player:GetAttribute("ProgressMode") == "studio" then
                return "Studio award", "Displayed on the center pedestal for this playtest."
            end
            return "Earned", "Displayed on the center pedestal in Trophy Hall."
        end
        local status = player:GetAttribute("ProgressStatus")
        if status == "ready" or status == "saved" then
            return "Locked", "Open an official run at the Relay event board."
        elseif status == "saving" then
            return "Updating", "Waiting for the progression update."
        elseif status == "unavailable" then
            return "Unavailable", "The journal will update when progression is available."
        end
        return "Loading", "Waiting for your progression to load."
    elseif id == "mastery-sky" then
        if player:GetAttribute("SkywalkExpertEarned") == true and player:GetAttribute("SkywalkExpertRewardId") == id then
            local best = player:GetAttribute("SkywalkExpertBest")
            local note = if type(best) == "number" and best > 0
                then string.format("Expert clear in %.1fs. Waiting for the reward save.", best)
                else "Waiting for the reward save."
            return "Updating", note
        elseif player:GetAttribute("SkywalkTrialMode") == "expert" then
            local stage = player:GetAttribute("SkywalkTrialNext")
            if type(stage) == "number" then
                return "In progress", string.format("Expert checkpoints: %d / 6.",
                    math.clamp(math.floor(stage), 0, 6))
            end
        end
        return "Locked", "Finish the Expert route and ring the summit bell."
    elseif string.match(id, "^discovery%-") or string.match(id, "^mastery%-") or string.match(id, "^journey%-")
        or id == "world-05" or id == "world-06" then
        return "Locked", "Open the Adventure Journal to see city progress."
    end
    return "Planned", "This achievement’s earning path is planned."
end

local ink = Color3.fromRGB(19, 37, 40)
local raised = Color3.fromRGB(31, 56, 54)
local gold = Color3.fromRGB(244, 189, 79)
local parchment = Color3.fromRGB(255, 242, 209)
local muted = Color3.fromRGB(190, 212, 199)
local edge = Color3.fromRGB(145, 113, 65)

local function make(className, parent, properties)
    local instance = Instance.new(className)
    for key, value in properties do
        instance[key] = value
    end
    instance.Parent = parent
    return instance
end

local function outline(instance, radius)
    make("UICorner", instance, {CornerRadius = UDim.new(0, radius)})
    return make("UIStroke", instance, {Color = edge, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function text(parent, name, size, color, bold)
    return make("TextLabel", parent, {
        Name = name, Text = "", TextSize = size, TextColor3 = color, BackgroundTransparency = 1,
        Font = if bold then Enum.Font.GothamBold else Enum.Font.GothamMedium,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
    })
end

local function button(parent, name, label, position, size)
    local control = make("TextButton", parent, {
        Name = name, Text = label, TextSize = 15, Font = Enum.Font.GothamBold,
        TextColor3 = parchment, BackgroundColor3 = raised, BorderSizePixel = 0,
        Position = position, Size = size, Selectable = true,
    })
    local stroke = outline(control, 8)
    control.SelectionGained:Connect(function()
        stroke.Color = parchment
        stroke.Thickness = 2.5
    end)
    control.SelectionLost:Connect(function()
        stroke.Color = edge
        stroke.Thickness = 1
    end)
    return control
end

local function stack(parent)
    return make("UIListLayout", parent, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7)})
end

local function cardLine(parent, name, size, tint, bold, order)
    local line = text(parent, name, size, tint, bold)
    line.LayoutOrder = order
    line.Size = UDim2.new(1, 0, 0, 0)
    line.AutomaticSize = Enum.AutomaticSize.Y
    return line
end

local permanentAwards = {"LanternKeeper", "KilnKeeper", "DeepwaterTeam", "DawnReturn", "FighterNewForm"}
local observedAttributes = {
    "ProgressMode", "ProgressStatus", "SkywalkExpertEarned", "SkywalkExpertRewardId",
    "SkywalkExpertBest", "SkywalkTrialMode", "SkywalkTrialNext",
    "CityAdventureAwards", "CityAdventureCloudbreakBest", "CityAdventureCleanBest",
}
for _, attribute in permanentAwards do
    table.insert(observedAttributes, attribute)
end

function TrophyJournal.new(panel, player, onBack)
    local gui = make("Frame", panel, {
        Name = "TrophyJournal", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false,
    })
    local title = text(gui, "JournalTitle", 20, parchment, true)
    title.Size = UDim2.new(1, -73, 0, 25)
    title.Text = "Trophy journal"
    local summary = text(gui, "Summary", 13, muted, false)
    summary.Position = UDim2.fromOffset(0, 25)
    summary.Size = UDim2.new(1, -73, 0, 19)
    local back = button(gui, "JournalBack", "Back", UDim2.new(1, -62, 0, 0), UDim2.fromOffset(62, 44))
    local scroll = make("ScrollingFrame", gui, {
        Name = "JournalScroll", Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -52),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 5,
        ScrollBarImageColor3 = edge, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Selectable = false,
    })
    make("UIPadding", scroll, {PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 9), PaddingBottom = UDim.new(0, 3)})
    stack(scroll)

    local function navigation(name, order)
        local row = make("Frame", scroll, {
            Name = name, LayoutOrder = order, Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1,
        })
        local previous = button(row, name .. "Previous", "<", UDim2.fromOffset(0, 0), UDim2.fromOffset(45, 44))
        local next = button(row, name .. "Next", ">", UDim2.new(1, -45, 0, 0), UDim2.fromOffset(45, 44))
        previous.NextSelectionRight = next
        next.NextSelectionLeft = previous
        local caption = text(row, name .. "Caption", 14, parchment, true)
        caption.Size = UDim2.new(1, -100, 1, 0)
        caption.Position = UDim2.fromOffset(50, 0)
        caption.TextXAlignment = Enum.TextXAlignment.Center
        return previous, next, caption
    end

    local categoryPrevious, categoryNext, categoryName = navigation("Category", 1)
    local entryPrevious, entryNext, entryNumber = navigation("Trophy", 2)
    local card = make("Frame", scroll, {Name = "TrophyDetails", LayoutOrder = 3,
        BackgroundColor3 = ink, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0)})
    outline(card, 8)
    make("UIPadding", card, {PaddingTop = UDim.new(0, 11), PaddingBottom = UDim.new(0, 11),
        PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11)})
    stack(card)
    local name = cardLine(card, "TrophyName", 18, parchment, true, 1)
    local state = cardLine(card, "TrophyState", 14, gold, true, 2)
    local criterion = cardLine(card, "Criterion", 15, parchment, false, 3)
    local note = cardLine(card, "TrophyNote", 13, muted, false, 4)

    back.NextSelectionDown = categoryNext
    categoryPrevious.NextSelectionUp, categoryNext.NextSelectionUp = back, back
    categoryPrevious.NextSelectionDown, categoryNext.NextSelectionDown = entryPrevious, entryNext
    entryPrevious.NextSelectionUp, entryNext.NextSelectionUp = categoryPrevious, categoryNext

    local journal = setmetatable({
        player = player, container = gui, scroll = scroll, back = back, connections = {},
        category = 5, entry = 4, summary = summary, categoryName = categoryName, entryNumber = entryNumber,
        name = name, state = state, criterion = criterion, note = note,
    }, TrophyJournal)

    back.Activated:Connect(onBack)
    categoryPrevious.Activated:Connect(function() journal:_switchCategory(-1) end)
    categoryNext.Activated:Connect(function() journal:_switchCategory(1) end)
    entryPrevious.Activated:Connect(function() journal:_switchEntry(-1) end)
    entryNext.Activated:Connect(function() journal:_switchEntry(1) end)
    gui.Destroying:Connect(function() journal:Hide() end)
    return journal
end

function TrophyJournal:_update()
    local group = categories[self.category]
    local entry = group[2][self.entry]
    self.categoryName.Text = group[1]
    self.entryNumber.Text = string.format("Trophy %d / %d", self.entry, #group[2])
    self.name.Text = entry[2]
    self.criterion.Text = entry[3]
    self.state.Text, self.note.Text = describe(self.player, entry[1])
    local mode = self.player:GetAttribute("ProgressMode")
    local state = self.player:GetAttribute("ProgressStatus")
    local earned = 0
    for _, category in categories do
        for _, trophy in category[2] do
            local awardState = if trophy == entry then self.state.Text else describe(self.player, trophy[1])
            if awardState == "Earned" or awardState == "Studio award" then
                earned += 1
            end
        end
    end
    if mode == "studio" then
        self.summary.Text = string.format("%d of 30 earned · Studio", earned)
    elseif earned > 0 or state == "ready" or state == "saved" then
        self.summary.Text = string.format("%d of 30 earned", earned)
    else
        self.summary.Text = "30 catalog entries"
    end
end

function TrophyJournal:_switchCategory(offset)
    self.category = (self.category - 1 + offset) % #categories + 1
    self.entry = 1
    self:_update()
end

function TrophyJournal:_switchEntry(offset)
    self.entry = (self.entry - 1 + offset) % #categories[self.category][2] + 1
    self:_update()
end

function TrophyJournal:Show()
    if self.container.Visible then
        return
    end
    self.category, self.entry = 5, 4
    self:_update()
    self.scroll.CanvasPosition = Vector2.new(0, 0)
    self.container.Visible = true
    for _, attribute in observedAttributes do
        table.insert(self.connections, self.player:GetAttributeChangedSignal(attribute):Connect(function()
            self:_update()
        end))
    end
    if UserInputService.GamepadEnabled then
        GuiService.SelectedObject = self.back
    end
end

function TrophyJournal:Hide()
    self.container.Visible = false
    for _, connection in self.connections do
        connection:Disconnect()
    end
    table.clear(self.connections)
    local selected = GuiService.SelectedObject
    if selected and selected:IsDescendantOf(self.container) then
        GuiService.SelectedObject = nil
    end
end

return TrophyJournal
