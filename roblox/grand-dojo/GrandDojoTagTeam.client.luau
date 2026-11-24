local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("GrandDojoTagTeam")
local ChampionshipHud = require(ReplicatedStorage:WaitForChild("ChampionshipHud"))
local Portraits = require(ReplicatedStorage:WaitForChild("ChampionshipPortraits"))
local CombatAudio = require(ReplicatedStorage:WaitForChild("CombatAudio"))

local ink = Color3.fromRGB(32, 23, 27)
local lacquer = Color3.fromRGB(67, 40, 40)
local chestnut = Color3.fromRGB(48, 28, 31)
local gold = Color3.fromRGB(244, 189, 97)
local bronze = Color3.fromRGB(153, 100, 62)
local paper = Color3.fromRGB(255, 240, 205)
local muted = Color3.fromRGB(211, 185, 171)
local jade = Color3.fromRGB(27, 77, 66)
local mint = Color3.fromRGB(130, 234, 198)
local coral = Color3.fromRGB(250, 147, 142)
local darkTrack = Color3.fromRGB(37, 26, 30)
local bold = Enum.Font.GothamBold
local regular = Enum.Font.GothamMedium

local roster = {
    {id = "reedguard-kangaroo", kit = "reedguard", name = "Reedguard", style = "Parry and counter",
        technique = "Uppercut", techniqueAction = "uppercut", signature = "Rising"},
    {id = "penguin-brawler", kit = "penguin", name = "Penguin", style = "Dodge and slide",
        dodge = "Floe Turn", signature = "Belly Slide"},
    {id = "silverback-gorilla", kit = "silverback", name = "Silverback", style = "Power and wide hits",
        technique = "Ridge Palm", techniqueAction = "secondary", signature = "Seismic"},
    {id = "fire-salamander", kit = "salamander", name = "Salamander", style = "Sweep and floor control",
        technique = "Ember Sweep", techniqueAction = "secondary", signature = "Magma Trail"},
    {id = "karate-frog", kit = "frog", name = "Karate Frog", style = "Leaping kicks and spins",
        technique = "Lily Vault", techniqueAction = "secondary", signature = "Tadpole Tornado", earned = true},
    {id = "river-otter", kit = "otter", name = "River Otter", style = "Palm strikes and pebbles",
        technique = "Eddy Palm", techniqueAction = "secondary", signature = "Pebble Barrage", earned = true},
}
local byKit = {}
for _, fighter in roster do
    byKit[fighter.id], byKit[fighter.kit] = fighter, fighter
end

local function object(class, parent, properties)
    local node = Instance.new(class)
    for key, value in properties do
        node[key] = value
    end
    node.Parent = parent
    return node
end

local function trim(node, radius, tint)
    object("UICorner", node, {CornerRadius = UDim.new(0, radius)})
    return object("UIStroke", node, {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = tint or bronze, Thickness = 1})
end

local function frame(parent, name, color)
    return object("Frame", parent, {
        Name = name, BorderSizePixel = 0, BackgroundColor3 = color or ink,
        BackgroundTransparency = if color then 0 else 1,
    })
end

local function label(parent, name, x, y, size, height, font, tint)
    return object("TextLabel", parent, {
        Name = name, Position = UDim2.fromOffset(x, y), Size = size, Font = font or regular,
        BackgroundTransparency = 1, TextSize = height, TextColor3 = tint or paper, Text = "",
        TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
    })
end

local function button(parent, name, text, primary)
    local node = object("TextButton", parent, {
        Name = name, Text = text, TextWrapped = true, TextSize = 13, Font = bold, BorderSizePixel = 0,
        TextColor3 = if primary then ink else paper, BackgroundColor3 = if primary then gold else lacquer,
    })
    local outline = trim(node, 8, if primary then paper else bronze)
    local resting = outline.Color
    node.SelectionGained:Connect(function()
        outline.Color, outline.Thickness = paper, 2.5
    end)
    node.SelectionLost:Connect(function()
        outline.Color, outline.Thickness = resting, 1
    end)
    return node
end

local gui = object("ScreenGui", playerGui, {
    Name = "GrandDojoTagTeam", DisplayOrder = 26, ResetOnSpawn = false,
    ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets, SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local function panel(name, width, height)
    local node = frame(gui, name, ink)
    node.AnchorPoint, node.Visible = Vector2.new(.5, .5), false
    node.Position, node.Size = UDim2.fromScale(.5, .5), UDim2.new(.92, 0, 0, height)
    trim(node, 12, gold)
    object("UISizeConstraint", node, {MaxSize = Vector2.new(width, height)})
    return node
end

local offerPanel = panel("Offer", 398, 248)
local offerTitle = label(offerPanel, "Title", 14, 8, UDim2.new(1, -28, 0, 27), 19, bold, gold)
offerTitle.Text = "Choose your backup"
local offerInfo = label(offerPanel, "Primary", 15, 36, UDim2.new(1, -30, 0, 19), 12, regular, muted)
local backupList = object("ScrollingFrame", offerPanel, {
    Name = "BackupChoices", Position = UDim2.fromOffset(12, 54), Size = UDim2.new(1, -24, 0, 144),
    BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.fromOffset(0, 0),
    ScrollBarThickness = 4, ScrollBarImageColor3 = gold, ScrollingDirection = Enum.ScrollingDirection.Y,
    Selectable = false,
})
local offerChoices = {}
for _, fighter in roster do
    local node = button(backupList, fighter.id, "", false)
    node.Size = UDim2.new(1, -10, 0, 44)
    node.SelectionGained:Connect(function()
        local top = node.Position.Y.Offset
        local scroll = backupList.CanvasPosition.Y
        local window = backupList.AbsoluteWindowSize.Y
        if window >= 48 then
            backupList.CanvasPosition = Vector2.new(0, math.clamp(scroll, math.max(0, top + 46 - window), math.max(0, top - 2)))
        end
    end)
    local badge = frame(node, "Portrait", chestnut)
    badge.Position, badge.Size = UDim2.fromOffset(5, 3), UDim2.fromOffset(38, 38)
    trim(badge, 5)
    local name = label(node, "Fighter", 52, 3, UDim2.new(1, -62, 0, 19), 14, bold)
    name.Text = fighter.name
    local style = label(node, "Style", 52, 22, UDim2.new(1, -62, 0, 18), 11, regular, muted)
    style.Text = fighter.style
    offerChoices[fighter.id] = {node = node, portrait = Portraits.new(badge, false, 4)}
end
local offerCancel = button(offerPanel, "Cancel", "Cancel", false)
offerCancel.Position, offerCancel.Size = UDim2.new(1, -110, 1, -48), UDim2.fromOffset(96, 44)
local offerClock = label(offerPanel, "Time", 14, 201, UDim2.new(1, -130, 0, 44), 11, regular, muted)
offerClock.TextWrapped = true

local queue = panel("Queue", 380, 60)
queue.AnchorPoint = Vector2.new(.5, 1)
local queueTitle = label(queue, "Heading", 13, 7, UDim2.new(1, -113, 0, 21), 15, bold, gold)
local queueDetail = label(queue, "Detail", 13, 31, UDim2.new(1, -113, 0, 19), 11, regular, muted)
local queueCancel = button(queue, "Cancel", "Cancel", false)
queueCancel.Position, queueCancel.Size = UDim2.new(1, -97, 0, 7), UDim2.fromOffset(88, 46)

local championship = ChampionshipHud.new(gui, bold)
local hud = championship.root
hud.Name = "Match"
championship.title.Text = "Tag Team"
local selfPortrait = Portraits.new(championship.leftPortrait, false, 12)
local rivalPortrait = Portraits.new(championship.rightPortrait, true, 12)

local teams = frame(gui, "Teams")
teams.AnchorPoint, teams.Visible = Vector2.new(.5, 0), false
local teamLimit = object("UISizeConstraint", teams, {})
local rosters = {}
for side = 1, 2 do
    local clan = frame(teams, if side == 1 then "YourTeam" else "Opponents", chestnut)
    clan.BackgroundTransparency = .16
    clan.Position, clan.Size = UDim2.new((side - 1) / 2, if side == 1 then 0 else 3, 0, 0), UDim2.new(.5, -3, 1, 0)
    local tint = if side == 1 then mint else coral
    local outline = trim(clan, 7, tint:Lerp(chestnut, .56))
    local title = label(clan, "Team", 7, 0, UDim2.new(.62, -10, 0, 15), 9, bold, tint)
    local reserveTitle = label(clan, "Backup", 0, 0, UDim2.new(.38, -7, 0, 15), 9, bold, gold)
    reserveTitle.Position = UDim2.fromScale(.62, 0)
    reserveTitle.Text, reserveTitle.TextXAlignment = "BACKUP", Enum.TextXAlignment.Right
    rosters[side] = {title = title, outline = outline}
    for index = 1, 2 do
        local member = frame(clan, "Fighter" .. index)
        member.Position = UDim2.new(0, 7, (index - 1) / 2, if index == 1 then 15 else 7)
        member.Size = UDim2.new(1, -14, .5, -9)
        local name = label(member, "Active", 0, 0, UDim2.new(.52, -3, 1, 0), 11, bold, tint)
        local reserve = label(member, "Reserve", 0, 0, UDim2.new(.48, 0, 1, 0), 10, regular, muted)
        reserve.Position = UDim2.fromScale(.52, 0)
        reserve.TextXAlignment = Enum.TextXAlignment.Right
        local meter = frame(member, "Health", darkTrack)
        meter.Size, meter.Position = UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 1, -2)
        local fill = frame(meter, "Current", tint)
        local reserveMeter = frame(member, "ReserveHealth", darkTrack)
        reserveMeter.Size, reserveMeter.Position = UDim2.new(.48, 0, 0, 2), UDim2.new(.52, 0, 1, -2)
        meter.Size = UDim2.new(.52, -5, 0, 2)
        local reserveFill = frame(reserveMeter, "Current", gold)
        rosters[side][index] = {name = name, reserve = reserve, fill = fill, reserveFill = reserveFill}
    end
end

local controls = frame(gui, "Controls")
controls.AnchorPoint, controls.Visible = Vector2.new(.5, 1), false
local controlsLimit = object("UISizeConstraint", controls, {})
local actions = {
    strike = button(controls, "Strike", "Strike", true), technique = button(controls, "Technique", "Technique", false),
    heavy = button(controls, "Heavy", "Heavy", false), guard = button(controls, "Guard", "Guard", false),
    dodge = button(controls, "Dodge", "Dodge", false), signature = button(controls, "Signature", "Signature", false),
    tag = button(controls, "TagIn", "Tag In", false), leave = button(controls, "Leave", "Leave", false),
}
for _, control in actions do
    -- During a match gamepad inputs use the action bindings.
    control.Selectable = false
end
actions.tag.BackgroundColor3 = jade

local recap = panel("Result", 400, 153)
local resultTitle = label(recap, "Heading", 16, 12, UDim2.new(1, -32, 0, 31), 22, bold, gold)
local resultDetail = label(recap, "Detail", 16, 49, UDim2.new(1, -32, 0, 48), 13, regular, paper)
resultDetail.TextWrapped = true
resultDetail.TextYAlignment = Enum.TextYAlignment.Top
local close = button(recap, "Close", "Close", true)
close.Position, close.Size = UDim2.new(1, -118, 1, -55), UDim2.fromOffset(102, 44)

local notice = panel("Notice", 420, 45)
notice.AnchorPoint = Vector2.new(.5, 1)
local noticeBody = label(notice, "Message", 10, 2, UDim2.new(1, -20, 0, 41), 12, regular)
noticeBody.TextWrapped = true
noticeBody.TextXAlignment = Enum.TextXAlignment.Center

local keys = {
    [Enum.KeyCode.E] = "strike", [Enum.KeyCode.ButtonR2] = "strike", [Enum.KeyCode.ButtonX] = "strike",
    [Enum.KeyCode.Q] = "guard", [Enum.KeyCode.ButtonL2] = "guard",
    [Enum.KeyCode.R] = "heavy", [Enum.KeyCode.ButtonR1] = "heavy",
    [Enum.KeyCode.X] = "dodge", [Enum.KeyCode.ButtonL1] = "dodge",
    [Enum.KeyCode.V] = "technique", [Enum.KeyCode.DPadUp] = "technique",
    [Enum.KeyCode.F] = "signature", [Enum.KeyCode.ButtonY] = "signature",
    [Enum.KeyCode.T] = "tag", [Enum.KeyCode.DPadRight] = "tag",
    [Enum.KeyCode.C] = "leave", [Enum.KeyCode.ButtonB] = "leave",
}
local tips = {
    blocked = "Blocked", parried = "Parried! Counter now", attackBlocked = "Your strike was blocked",
    projectileDeflected = "Pebble deflected!",
    attackParried = "Your strike was parried", hit = "You took a hit", strike = "Strike landed", counter = "Counter landed",
    needParry = "Parry to unlock Rising", tag = "Tag in!", tagIn = "Tag in!", tagStrike = "Tag assist landed",
    tagUnavailable = "Wait until Tag In is ready", knockedOut = "Knockout", guard = "Guard up",
    projectileDeflected = "Projectile deflected!",
}

local offer, waiting, match
local detached, leaving = false, false
local lastMatchId, firstChoice, joinAt, noticeUntil = 0, nil, nil, 0
local offerFeedback
local rivalIndex

local function isGamepad()
    return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

local function focus()
    local selected = GuiService.SelectedObject
    local target = if recap.Visible then close elseif offerPanel.Visible then firstChoice or offerCancel
        elseif queue.Visible then queueCancel else nil
    if isGamepad() and target then
        GuiService.SelectedObject = target
    elseif selected and selected:IsDescendantOf(gui) then
        GuiService.SelectedObject = nil
    end
end

local function showOffer(data)
    offer, joinAt, offerFeedback = data, nil, nil
    offerPanel.Visible = offer ~= nil
    player:SetAttribute("TagTeamOfferOpen", if offer then true else nil)
    local eligible = offer and offer.backupIds
    local hasEligibilityList = type(eligible) == "table"
    local chosen = {}
    for _, fighter in roster do
        local option = offerChoices[fighter.id]
        local show = offer ~= nil and fighter.id ~= offer.primaryId
            and (if hasEligibilityList then table.find(eligible, fighter.id) ~= nil else not fighter.earned)
        option.node.Visible, option.node.Selectable = show, show
        Portraits.set(option.portrait, if show then fighter.id else nil)
        if show then
            table.insert(chosen, option.node)
        end
    end
    firstChoice = chosen[1]
    for index, node in chosen do
        node.Position = UDim2.fromOffset(2, 2 + (index - 1) * 48)
        node.NextSelectionUp = chosen[index - 1] or offerCancel
        node.NextSelectionDown = chosen[index + 1] or offerCancel
    end
    backupList.CanvasSize = UDim2.fromOffset(0, #chosen * 48)
    backupList.CanvasPosition = Vector2.zero
    offerCancel.NextSelectionUp, offerCancel.NextSelectionDown = chosen[#chosen], firstChoice
    if offer then
        local fighter = byKit[offer.primaryId]
        offerInfo.Text = if fighter then "Primary · " .. fighter.name else "Choose a different fighter for Tag In."
    end
    focus()
end

local function menuOpen()
    local main = playerGui:FindFirstChild("GrandDojo")
    if main and main.Enabled then
        for _, name in {"EventPanel", "EagleEyeView", "RelayStatus", "SparringPicker", "SparringResult", "DuelFormatPicker"} do
            local window = main:FindFirstChild(name)
            if window and window.Visible then
                return true
            end
        end
    end
    local starter = playerGui:FindFirstChild("StarterFighterSelect")
    return starter and starter.Enabled
end

local function layout()
    local width, height = gui.AbsoluteSize.X, gui.AbsoluteSize.Y
    local compact = width <= 570 or height <= 430
    local touch = UserInputService.TouchEnabled and not isGamepad()
    local stacked = width < 510 or (touch and width < 630)
    championship:Layout(compact, true)
    local headerBottom = hud.Position.Y.Offset + hud.Size.Y.Offset
    local cardHeight = if height <= 295 then 50 elseif compact then 54 else 60
    teams.Position = UDim2.new(.5, 0, 0, headerBottom + 4)
    teams.Size = UDim2.new(.94, 0, 0, cardHeight)
    teamLimit.MaxSize = Vector2.new(if compact then 448 else 720, cardHeight)

    local state = match and match.slots[match.selfIndex]
    local kit = state and byKit[state.kitId]
    local order = if kit and not kit.technique then {"strike", "heavy", "guard", "dodge", "signature", "tag", "leave"}
        else {"strike", "technique", "heavy", "guard", "dodge", "signature", "tag", "leave"}
    local columns = if stacked then 4 else #order
    local targetHeight = if height <= 260 then 44 else 46
    local controlHeight = if stacked then targetHeight * 2 + 4 else targetHeight
    local bottom = if touch then (if stacked then math.min(108, math.floor(height * .19)) else 16) else 28
    bottom = math.max(0, math.min(bottom, height - headerBottom - cardHeight - controlHeight - 8))
    controls.Position, controls.Size = UDim2.new(.5, 0, 1, -bottom), UDim2.new(if touch and not stacked then .81 else .94, 0, 0, controlHeight)
    controlsLimit.MaxSize = Vector2.new(if stacked then 390 elseif touch and compact then 398
        elseif compact then 574 else 694, controlHeight)
    actions.technique.Visible = actions.strike.Visible and (not kit or kit.technique ~= nil)
    for index, action in order do
        local i, node = index - 1, actions[action]
        node.Position = UDim2.new((i % columns) / columns, 2, 0, math.floor(i / columns) * (targetHeight + 4))
        node.Size = UDim2.new(1 / columns, -4, 0, targetHeight)
        node.TextSize = if compact then 12 else 13
    end
    local queueBottom = if touch then math.min(112, math.floor(height * .25)) else 24
    queue.Position = UDim2.new(.5, 0, 1, -queueBottom)
    notice.Position = UDim2.new(.5, 0, 1, -queueBottom)
end

local function seconds(at, now)
    return if type(at) == "number" then math.max(0, math.ceil(at - now)) else 0
end

local function ratio(health, maximum)
    return if type(health) == "number" and type(maximum) == "number" and maximum > 0
        then math.clamp(health / maximum, 0, 1) else 0
end

local function fighting(slot)
    return slot and not slot.eliminated and slot.health > 0
end

local function eligibleRival(slot)
    return fighting(slot) or (slot and not slot.eliminated and slot.entryAt ~= nil)
end

local function fighterName(kit)
    return if byKit[kit] then byKit[kit].name else "Fighter"
end

local function sameTeam(a, b)
    return (a <= 2) == (b <= 2)
end

local function pickRival(data)
    local focusIndex = data.focusIndex
    if data.slots[focusIndex] and not sameTeam(focusIndex, data.selfIndex) and eligibleRival(data.slots[focusIndex]) then
        return focusIndex
    end
    local first = if data.selfIndex <= 2 then 3 else 1
    if rivalIndex and sameTeam(rivalIndex, first) and eligibleRival(data.slots[rivalIndex]) then
        return rivalIndex
    end
    return if fighting(data.slots[first]) or not fighting(data.slots[first + 1]) then first else first + 1
end

local function setRoster(data)
    local left, right = if data.selfIndex <= 2 then 1 else 3, if data.selfIndex <= 2 then 3 else 1
    local standing = {0, 0}
    for team, start in {left, right} do
        local group = rosters[team]
        local tint, name = if start == 1 then mint else coral, if start == 1 then "JADE" else "EMBER"
        group.title.Text = name .. (if team == 1 then " · YOUR TEAM" else "")
        group.title.TextColor3, group.outline.Color = tint, tint:Lerp(chestnut, .56)
        for offset = 0, 1 do
            local index = start + offset
            local member, status = data.slots[index], group[offset + 1]
            local active = member and not member.eliminated
            if active then
                standing[team] += 1
            end
            local name = if index == data.selfIndex then "You" else fighterName(member and member.kitId)
            status.name.Text = if active then name else name .. " · Out"
            status.name.TextColor3, status.fill.BackgroundColor3 = if active then tint else muted, tint
            status.fill.Size = UDim2.fromScale(if active then ratio(member.health, member.maxHealth) else 0, 1)
            status.reserve.Text = if active and member.backupKitId then fighterName(member.backupKitId) else ""
            status.reserveFill.Size = UDim2.fromScale(if active then ratio(member.backupHealth, member.backupMaxHealth) else 0, 1)
        end
    end
    championship.score.Text = string.format("%d vs %d", standing[1], standing[2])
end

local function combatReady(now)
    return match and not detached and not leaving and not match.resolvedAt and now >= match.startsAt and now < match.endsAt
end

local function showCombatActions(now, own, kit)
    local live = combatReady(now) and not own.eliminated
    local enabled = live and fighting(own)
    local keyboard = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
    local function binding(name, key, gamepad)
        return name .. (if keyboard then " · " .. key elseif isGamepad() then " · " .. gamepad else "")
    end
    local function cool(buttonNode, name, key, gamepad, readyAt)
        local wait = seconds(readyAt, now)
        buttonNode.Text = if wait > 0 then name .. "\n" .. wait .. "s" else binding(name, key, gamepad)
        buttonNode.TextColor3 = if wait > 0 then muted else paper
    end
    actions.strike.Visible, actions.heavy.Visible, actions.guard.Visible = enabled, enabled, enabled
    actions.dodge.Visible, actions.signature.Visible = enabled, enabled
    actions.technique.Visible = enabled and kit.technique ~= nil
    actions.tag.Visible = live
    actions.leave.Visible = not match.resolvedAt
    actions.strike.Text, actions.heavy.Text = binding("Strike", "E", "RT"), binding("Heavy", "R", "RB")
    actions.guard.Text, actions.dodge.Text = binding("Guard", "Q", "LT"), binding(kit.dodge or "Dodge", "X", "LB")
    if kit.technique then
        cool(actions.technique, kit.technique, "V", "↑", match.nextSecondary)
    end
    cool(actions.signature, kit.signature, "F", "Y", match.nextSignature)
    local canTag = live and match.canTag == true
    local wait = seconds(match.tagReadyAt, now)
    actions.tag.Active, actions.tag.AutoButtonColor = canTag, canTag
    actions.tag.BackgroundColor3 = if canTag then jade else chestnut
    actions.tag.TextColor3 = if canTag then mint else muted
    actions.tag.Text = if canTag then binding("Tag In", "T", "→") elseif (own.backupHealth or 0) <= 0 then "Backup Out"
        elseif wait > 0 then "Tag In · " .. wait .. "s" else "Tag In"
    actions.leave.Text = binding(if leaving then "Leaving…" else "Leave", "C", "B")
end

local function tell(message)
    if type(message) == "string" and message ~= "" then
        noticeBody.Text, noticeUntil = message, workspace:GetServerTimeNow() + 3
    end
end

local function refresh()
    local now = workspace:GetServerTimeNow()
    if offer then
        local timeLeft = seconds(offer.expiresAt, now)
        if timeLeft == 0 then
            showOffer(nil)
            tell("Invite expired. Use the Tag Team sign to try again.")
        else
            if joinAt and now >= joinAt + 2.5 then
                joinAt = nil
            end
            offerClock.Text = if joinAt then "Joining…" else offerFeedback or string.format("Choose within %ds", timeLeft)
        end
    end
    local current = match ~= nil and not detached
    local occupied = player:GetAttribute("SparringActive") or player:GetAttribute("BrawlActive")
        or player:GetAttribute("SkywalkTrialMode") or player:GetAttribute("StarterSelectionRequired")
    local world = not current and not recap.Visible and not offerPanel.Visible and not occupied and not menuOpen()
    local wasQueued = queue.Visible
    queue.Visible, notice.Visible = world and waiting ~= nil, world and not waiting and now < noticeUntil
    if queue.Visible then
        queueTitle.Text = string.format("Tag Team queue · %d/%d", waiting.count, waiting.required)
        queueDetail.Text = string.format("Queue closes in %ds", seconds(waiting.expiresAt, now))
    end
    if queue.Visible ~= wasQueued then
        focus()
    end
    hud.Visible, teams.Visible, controls.Visible = current, current, current
    if not current then
        return
    end
    local own = match.slots[match.selfIndex]
    local kit = byKit[own.kitId] or roster[1]
    if not match.resolvedAt and not own.eliminated and own.health > 0 and not leaving and now < match.endsAt then
        CombatAudio.countdown(match.startsAt - now)
    end
    championship.clock.Text = tostring(math.max(0, math.ceil(match.endsAt - math.max(match.resolvedAt or now, match.startsAt))))
    championship.hint.TextColor3 = paper
    if match.resolvedAt then
        championship.hint.Text = "Match finished"
    elseif now < match.startsAt then
        championship.hint.Text = string.format("Starts in %d", seconds(match.startsAt, now))
    elseif own.eliminated then
        championship.hint.Text = "Watch your teammate"
    elseif own.health == 0 then
        championship.hint.Text = if own.entryAt then "Knockout · Backup is entering" else "Knockout"
        championship.hint.TextColor3 = gold
    else
        championship.hint.Text = tips[match.feedback] or ""
        if match.feedback == "tagIn" or match.feedback == "tagStrike" or match.feedback == "parried" then
            championship.hint.TextColor3 = mint
        end
    end
    showCombatActions(now, own, kit)
end

local function closeRecap()
    recap.Visible = false
    player:SetAttribute("TagTeamRecapOpen", nil)
    focus()
    refresh()
end

local function send(action)
    if not match or detached or leaving then
        return
    end
    if action == "leave" then
        if not match.resolvedAt then
            leaving = true
            remote:FireServer("leave", nil, match.matchId)
            refresh()
        end
        return
    end
    local own = match.slots[match.selfIndex]
    if not combatReady(workspace:GetServerTimeNow()) or own.eliminated then
        return
    end
    if action == "tag" then
        if match.canTag then
            remote:FireServer("tag", nil, match.matchId)
        end
        return
    end
    if not fighting(own) then
        return
    end
    local kit = byKit[own.kitId] or roster[1]
    if action == "technique" then
        action = kit.techniqueAction
    end
    if not action then
        return
    end
    local direction
    if action == "dodge" then
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        direction = if root and humanoid and humanoid.MoveDirection:Dot(root.CFrame.RightVector) < -.2 then -1 else 1
    end
    remote:FireServer(action, direction, match.matchId)
end

for action, buttonNode in actions do
    buttonNode.Activated:Connect(function()
        send(action)
    end)
end
for id, option in offerChoices do
    option.node.Activated:Connect(function()
        if offer and option.node.Visible and not joinAt then
            joinAt = workspace:GetServerTimeNow()
            offerFeedback = nil
            remote:FireServer("join", id)
            refresh()
        end
    end)
end

local function cancelWaiting()
    if offer or waiting then
        showOffer(nil)
        remote:FireServer("cancel")
    end
end
offerCancel.Activated:Connect(cancelWaiting)
queueCancel.Activated:Connect(cancelWaiting)
close.Activated:Connect(closeRecap)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() then
        return
    end
    local back = input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Backspace
    if recap.Visible then
        if back then closeRecap() end
    elseif match then
        local action = keys[input.KeyCode]
        if action then send(action) end
    elseif back and (offerPanel.Visible or queue.Visible) then
        cancelWaiting()
    end
end)

local resultCopy = {
    win = "Your team won", loss = "Opponents won", draw = "Teams tied", left = "You left Tag Team",
    cancelled = "Match cancelled",
}
local resultReasons = {
    knockout = "The match ended by knockout.", timeout = "Decided by remaining fighter health at the bell.",
    forfeit = "A team forfeited.", leave = "You returned to Grand Dojo.", cancelled = "A player left before the bell.",
    simultaneous = "Both teams went down on the same beat.",
}

remote.OnClientEvent:Connect(function(kind, data)
    if type(data) ~= "table" then
        return
    end
    if kind == "offer" and not match and not recap.Visible and data.primaryId and type(data.expiresAt) == "number" then
        showOffer(data)
    elseif kind == "notice" then
        joinAt = nil
        offerFeedback = if offer then data.message else nil
        tell(data.message)
    elseif kind == "queue" then
        if offer then showOffer(nil) end
        waiting = if data.queued then data else nil
        tell(data.message)
    elseif kind == "begin" or kind == "update" then
        if type(data.slots) ~= "table" or not data.slots[data.selfIndex] then
            return
        end
        if kind == "begin" then
            if type(data.matchId) ~= "number" or data.matchId <= lastMatchId then
                return
            end
            lastMatchId = data.matchId
            waiting, rivalIndex = nil, nil
            detached, leaving = false, false
            showOffer(nil)
            closeRecap()
            CombatAudio.prepare()
            CombatAudio.resetCountdown()
        elseif not match or match.matchId ~= data.matchId then
            return
        end
        local old = match
        local previousRival = rivalIndex
        match = data
        rivalIndex = pickRival(data)
        local own, other = data.slots[data.selfIndex], data.slots[rivalIndex]
        local ownChanged = not old or old.slots[old.selfIndex].kitId ~= own.kitId
        local rivalChanged = not old or previousRival ~= rivalIndex or old.slots[rivalIndex].kitId ~= other.kitId
        championship.left:Set(own.health, own.maxHealth, fighterName(own.kitId), ownChanged)
        championship.right:Set(other.health, other.maxHealth, fighterName(other.kitId), rivalChanged)
        Portraits.set(selfPortrait, own.kitId)
        Portraits.set(rivalPortrait, other.kitId)
        setRoster(data)
        if ownChanged then layout() end
    elseif kind == "result" and match and data.matchId == match.matchId then
        match, waiting = nil, nil
        leaving = false
        championship.left:Snap()
        championship.right:Snap()
        Portraits.set(selfPortrait, nil)
        Portraits.set(rivalPortrait, nil)
        resultTitle.Text = resultCopy[data.result] or "Tag Team finished"
        resultDetail.Text = data.message or resultReasons[data.reason] or "Return to Grand Dojo when ready."
        recap.Visible = true
        player:SetAttribute("TagTeamRecapOpen", true)
        focus()
    end
    refresh()
end)

player.CharacterRemoving:Connect(function()
    detached, waiting = true, nil
    showOffer(nil)
    refresh()
end)
player:GetAttributeChangedSignal("TagTeamActive"):Connect(function()
    if not player:GetAttribute("TagTeamActive") and match then
        -- The recap packet may follow attribute replication.
        detached = true
    end
    refresh()
end)
for _, property in {"SparringActive", "BrawlActive", "StarterSelectionRequired", "SkywalkTrialMode"} do
    player:GetAttributeChangedSignal(property):Connect(refresh)
end

local function resize()
    layout()
    refresh()
end
local function snapHealth()
    championship.left:Snap()
    championship.right:Snap()
end
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(snapHealth)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(snapHealth)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
    resize()
    focus()
end)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed >= .10 then
        elapsed = 0
        if offer or waiting or match or notice.Visible then refresh() end
    end
end)
resize()
