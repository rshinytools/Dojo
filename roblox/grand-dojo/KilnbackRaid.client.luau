local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local fighterCatalog = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog"))
local fighterTactics = require(ReplicatedStorage:WaitForChild("FighterTactics"))
local fighterLoadouts = require(ReplicatedStorage:WaitForChild("FighterLoadouts"))
local Health = require(ReplicatedStorage:WaitForChild("CombatHealth"))
local Portraits = require(ReplicatedStorage:WaitForChild("ChampionshipPortraits"))
local CombatAudio = require(ReplicatedStorage:WaitForChild("CombatAudio"))
local CombatPresentation = require(ReplicatedStorage:WaitForChild("CombatPresentation"))
local CombatTouchDock = require(ReplicatedStorage:WaitForChild("CombatTouchDock"))
local CombatWindup = require(ReplicatedStorage:WaitForChild("CombatWindup"))
local steering = require(ReplicatedStorage:WaitForChild("StormSteering")).new(player)

local ink = Color3.fromRGB(33, 23, 27)
local wood = Color3.fromRGB(69, 41, 39)
local bronze = Color3.fromRGB(158, 102, 63)
local gold = Color3.fromRGB(244, 187, 97)
local paper = Color3.fromRGB(255, 241, 214)
local muted = Color3.fromRGB(216, 192, 176)
local mint = Color3.fromRGB(141, 237, 199)
local jade = Color3.fromRGB(37, 81, 68)
local coral = Color3.fromRGB(255, 155, 137)
local amber = Color3.fromRGB(255, 201, 117)
local track = Color3.fromRGB(40, 31, 36)
local bold, regular = Enum.Font.GothamBold, Enum.Font.GothamMedium

local raids = {
    {id = "kilnback", remote = ReplicatedStorage:WaitForChild("KilnbackRaid"), district = "Cinder Terraces",
        entry = "Kilnback Raid Entry", gate = "Kilnback Raid Queue", label = "Kilnback Raid",
        name = "Kilnback Custodian", short = "Kilnback", target = "Core", defeated = "Kilnback shut down",
        clear = "The party shut down Kilnback Custodian.", panel = ink, rim = bronze, accent = gold,
        lastMatchId = 0, nextStatusAt = 0},
    {id = "kraken", remote = ReplicatedStorage:WaitForChild("AbyssalRaid"), district = "Tideharbor Coast",
        entry = "Abyssal Raid Entry", gate = "Abyssal Raid Queue", label = "Abyssal Raid",
        name = "Abyssal Kraken", short = "Abyssal Kraken", target = "Mantle", defeated = "Abyssal Kraken defeated",
        clear = "The party defeated the Abyssal Kraken.", panel = Color3.fromRGB(18, 38, 52),
        rim = Color3.fromRGB(76, 139, 148), accent = Color3.fromRGB(155, 237, 235),
        health = Color3.fromRGB(109, 216, 209), lastMatchId = 0, nextStatusAt = 0},
    {id = "phoenix", remote = ReplicatedStorage:WaitForChild("SolarRaid"), district = "Lantern Circuit",
        entry = "Solar Raid Entry", gate = "Solar Raid Queue", label = "Solar Raid",
        name = "Solar Phoenix", short = "Solar Phoenix", target = "Chest", defeated = "Solar Phoenix defeated",
        clear = "The party defeated the Solar Phoenix.", panel = Color3.fromRGB(53, 28, 34),
        rim = Color3.fromRGB(180, 103, 74), accent = Color3.fromRGB(255, 210, 137),
        health = Color3.fromRGB(246, 132, 79), lastMatchId = 0, nextStatusAt = 0},
}

local earnedCues = {ultimateCooling = "Ultimate cooling down", penguinTacticalCooling = "Technique cooling down", ridgeCooling = "Technique cooling down",
    emberCooling = "Technique cooling down"}
for _, group in fighterTactics.ByKit do
    for _, option in group.options do
        earnedCues[option.id] = option.name
    end
end
for _, loadout in fighterLoadouts.ByKit do
    for _, slot in {loadout.basic, loadout.ultimate} do
        for _, option in slot.options do
            if option.id ~= slot.default then
                earnedCues[option.id] = option.name
            end
        end
    end
end
local kits = {
    reedguard = {name = "Reedguard", technique = "Uppercut", techniqueAction = "uppercut", signature = "Rising"},
    penguin = {name = "Penguin", dodge = "Floe Turn", signature = "Belly Slide"},
    silverback = {name = "Silverback", signature = "Seismic"},
    salamander = {name = "Salamander", signature = "Magma Trail"},
}
for _, fighter in fighterCatalog.ById do
    local combat = fighter.combat
    if combat then
        kits[combat.kit] = {
            name = fighter.shortName or fighter.name,
            technique = combat.technique, techniqueAction = combat.techniqueAction, signature = combat.signature,
            compactTechnique = combat.compactTechnique, compactSignature = combat.compactSignature,
        }
        if combat.techniqueCue then
            earnedCues[combat.techniqueCue] = combat.technique
        end
        earnedCues[combat.signatureCue] = combat.signature
    end
end
local function make(class, parent, properties)
    local node = Instance.new(class)
    for key, value in properties do
        node[key] = value
    end
    node.Parent = parent
    return node
end

local function trim(node, radius, tint)
    make("UICorner", node, {CornerRadius = UDim.new(0, radius)})
    return make("UIStroke", node, {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = tint, Thickness = 1})
end

local function frame(parent, name, color)
    return make("Frame", parent, {
        Name = name, BackgroundColor3 = color or ink, BackgroundTransparency = if color then 0 else 1,
        BorderSizePixel = 0,
    })
end

local function text(parent, name, font, size, color, alignment)
    return make("TextLabel", parent, {
        Name = name, Text = "", Font = font, TextSize = size, TextColor3 = color,
        TextXAlignment = alignment or Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
    })
end

local function button(parent, name, label, primary)
    local node = make("TextButton", parent, {
        Name = name, Text = label, Font = bold, TextWrapped = true, TextSize = 13, BorderSizePixel = 0,
        BackgroundColor3 = if primary then gold else wood, TextColor3 = if primary then ink else paper,
    })
    local rim = trim(node, 7, if primary then paper else bronze)
    local normal = rim.Color
    node.SelectionGained:Connect(function()
        rim.Color, rim.Thickness = paper, 2.5
    end)
    node.SelectionLost:Connect(function()
        rim.Color, rim.Thickness = normal, 1
    end)
    return node
end

local gui = make("ScreenGui", playerGui, {
    Name = "KilnbackRaid", DisplayOrder = 27, ResetOnSpawn = false,
    ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets, SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local function panel(name, width, height, dock)
    local node = frame(gui, name, ink)
    node.Visible = false
    node.AnchorPoint = Vector2.new(.5, if dock then 1 else .5)
    node.Position = UDim2.fromScale(.5, if dock then 1 else .5)
    node.Size = UDim2.new(.94, 0, 0, height)
    local rim = trim(node, 10, bronze)
    local bounds = make("UISizeConstraint", node, {MaxSize = Vector2.new(width, height)})
    return node, bounds, rim
end

local queue, _, queueRim = panel("Queue", 384, 65, true)
local queueTitle = text(queue, "Heading", bold, 16, gold)
queueTitle.Position, queueTitle.Size = UDim2.fromOffset(13, 7), UDim2.new(1, -26, 0, 21)
local queueDetail = text(queue, "Detail", regular, 12, muted)
queueDetail.Position, queueDetail.Size = UDim2.fromOffset(13, 31), UDim2.new(1, -26, 0, 27)
queueDetail.TextWrapped = true
local cancel = button(queue, "Cancel", "Cancel", false)
cancel.Position, cancel.Size = UDim2.new(1, -102, 0, 9), UDim2.fromOffset(92, 46)
local join = button(queue, "Join", "Join Raid", true)
join.Position, join.Size = cancel.Position, cancel.Size

local notice = panel("Notice", 368, 46, true)
local noticeText = text(notice, "Message", regular, 12, paper, Enum.TextXAlignment.Center)
noticeText.Position, noticeText.Size = UDim2.fromOffset(8, 0), UDim2.new(1, -16, 1, 0)
noticeText.TextWrapped = true

local hud, hudLimit, hudRim = panel("Match", 660, 91)
hud.AnchorPoint, hud.Position = Vector2.new(.5, 0), UDim2.new(.5, 0, 0, 8)
local heading = text(hud, "Heading", bold, 20, paper)
local timer = text(hud, "Timer", bold, 19, gold, Enum.TextXAlignment.Right)
local phase = text(hud, "Phase", bold, 12, muted, Enum.TextXAlignment.Right)

local health = Health.new(hud, "Boss", false, bold)
local defaultHealthTone = health.tone
local healthRim = health.track:FindFirstChildOfClass("UIStroke")
local healthGradient = health.fill:FindFirstChildOfClass("UIGradient")
local white, black = Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)
local healthBox = health.track.Parent
healthBox.Name = "BossHealth"
healthBox.Size, healthBox.Position = UDim2.fromScale(1, 1), UDim2.fromScale(0, 0)
health.caption.Visible, health.amount.Visible = false, false
local healthValue = text(health.track, "Value", bold, 10, paper, Enum.TextXAlignment.Center)
healthValue.Size, healthValue.ZIndex = UDim2.fromScale(1, 1), 5
healthValue.TextStrokeColor3, healthValue.TextStrokeTransparency = ink, .3
local cue = text(hud, "Cue", bold, 13, paper, Enum.TextXAlignment.Center)
local reviveMeter = frame(hud, "ReviveProgress", track)
local reviveFill = frame(reviveMeter, "Progress", mint)
reviveFill.Size = UDim2.fromScale(0, 1)

local party = frame(gui, "Party")
party.AnchorPoint, party.Visible = Vector2.new(.5, 0), false
local partyLimit = make("UISizeConstraint", party, {})
local slots = {}
for i = 1, 4 do
    local tile = frame(party, "Fighter" .. i, ink)
    local rim = trim(tile, 6, bronze)
    local portraitFrame = frame(tile, "Portrait", wood)
    local portrait = Portraits.new(portraitFrame, false, 4)
    local name = text(tile, "Name", bold, 12, paper)
    local state = text(tile, "Status", regular, 11, muted, Enum.TextXAlignment.Right)
    local meter = frame(tile, "Health", track)
    local fill = frame(meter, "Current", mint)
    slots[i] = {node = tile, rim = rim, portraitFrame = portraitFrame, portrait = portrait,
        name = name, state = state, meter = meter, fill = fill}
end

local controls = frame(gui, "Controls")
controls.AnchorPoint, controls.Visible = Vector2.new(.5, 1), false
local controlsLimit = make("UISizeConstraint", controls, {})
local actions = {
    strike = button(controls, "Strike", "Strike", true),
    technique = button(controls, "Technique", "Technique", false),
    heavy = button(controls, "Heavy", "Heavy", false),
    guard = button(controls, "Guard", "Guard", false),
    dodge = button(controls, "Dodge", "Dodge", false),
    signature = button(controls, "Signature", "Signature", false),
    revive = button(controls, "Revive", "Revive", false),
    leave = button(controls, "Leave", "Leave", false),
}
for _, control in actions do
    control.Selectable = false
end

local recap, _, recapRim = panel("Result", 416, 180)
local resultTitle = text(recap, "Heading", bold, 23, gold)
resultTitle.Position, resultTitle.Size = UDim2.fromOffset(15, 10), UDim2.new(1, -30, 0, 32)
local resultDetail = text(recap, "Detail", regular, 13, paper)
resultDetail.Position, resultDetail.Size = UDim2.fromOffset(15, 45), UDim2.new(1, -30, 0, 34)
resultDetail.TextWrapped = true
local rewardLine = text(recap, "Reward", bold, 13, mint)
rewardLine.Position, rewardLine.Size = UDim2.fromOffset(15, 79), UDim2.new(1, -30, 0, 22)
local trophyLine = text(recap, "Trophy", bold, 13, gold)
trophyLine.Position, trophyLine.Size = UDim2.fromOffset(15, 103), UDim2.new(1, -30, 0, 22)
local close = button(recap, "Close", "Close", true)
close.Position, close.Size = UDim2.new(1, -117, 1, -53), UDim2.fromOffset(102, 44)

local keys = {
    [Enum.KeyCode.E] = "strike", [Enum.KeyCode.ButtonR2] = "strike", [Enum.KeyCode.ButtonX] = "strike",
    [Enum.KeyCode.Q] = "guard", [Enum.KeyCode.ButtonL2] = "guard",
    [Enum.KeyCode.R] = "heavy", [Enum.KeyCode.ButtonR1] = "heavy",
    [Enum.KeyCode.X] = "dodge", [Enum.KeyCode.ButtonL1] = "dodge",
    [Enum.KeyCode.V] = "technique", [Enum.KeyCode.DPadUp] = "technique",
    [Enum.KeyCode.F] = "signature", [Enum.KeyCode.ButtonY] = "signature",
    [Enum.KeyCode.G] = "revive", [Enum.KeyCode.DPadRight] = "revive",
    [Enum.KeyCode.C] = "leave", [Enum.KeyCode.ButtonB] = "leave",
}
local feedback = {
    strike = "Hit confirmed", blocked = "Guard held", parried = "Parry! Counter now",
    revived = "Revived", reviveCancelled = "Revive interrupted",
    needParry = "Parry to unlock Rising", down = "Knocked down",
    dodged = "Attack evaded", counter = "Counter hit confirmed", airborne = "Out of reach · Wait for landing",
    gustPull = "Vortex pulls inward",
    snared = "Snared briefly", snareCaught = "Cinder Snare landed",
    ricochetBounce = "Shell rebounds",
    guardBroken = "Guard broken", burn = "Heat lingers",
    shockLanded = "Thunder shock landed", shocked = "Shocked briefly",
    frenzyResist = "Frenzy keeps you planted",
    submerged = "Attack evaded underwater",
    talonCarry = "Talon Drop · Carrying", talonDropMiss = "Talon Drop missed",
    stormThunder = "Thunder strike landed",
}
local attackCues = {
    pulse = {name = "Kiln Pulse", hint = "Clear the ring"},
    sweep = {name = "Tile Sweep", hint = "Leave the marked lane", moving = "Tile wave moving", safe = "Stay out of the lane"},
    undertow = {name = "Undertow", hint = "Inside or beyond the ring"},
    cataclysm = {name = "Tentacle Cataclysm", hint = "Move between the arms", moving = "Tentacles striking",
        safe = "Stay between the arms", untilLastHit = true},
    solarFlare = {name = "Sunspots", hint = "Clear the circles", moving = "Sunspots bursting",
        safe = "Stay outside the circles", untilLastHit = true},
    sunDive = {name = "Sundive", hint = "Step out of the lane"},
}

local match, matchRaid, outcome, outcomeRaid, reward, earlyReward
local queuedRaid, nearbyRaid, displayedRaid, noticeRaid
local noticeUntil = 0
local leaving, detached = false, false

local function gamepad()
    return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

local function focus()
    local selected = GuiService.SelectedObject
    local target = if recap.Visible then close elseif queue.Visible and cancel.Visible then cancel
        elseif queue.Visible and join.Visible then join else nil
    if gamepad() and target then
        GuiService.SelectedObject = target
    elseif selected and selected:IsDescendantOf(gui) then
        GuiService.SelectedObject = nil
    end
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

local function nearGate()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local city = workspace:FindFirstChild("Grand Dojo City")
    local districts = city and city:FindFirstChild("Connected districts")
    if not root or not districts then
        return nil
    end
    for _, raid in raids do
        local district = districts:FindFirstChild(raid.district)
        local entry = district and district:FindFirstChild(raid.entry)
        local gate = entry and entry:FindFirstChild(raid.gate)
        if gate and (root.Position - gate.Position).Magnitude <= 13 then
            return raid
        end
    end
    return nil
end

local function clockText(seconds)
    local value = math.max(0, math.ceil(seconds))
    return string.format("%d:%02d", math.floor(value / 60), value % 60)
end

local function localSlot()
    return match and match.slots[match.selfIndex]
end

local function canFight(slot)
    return slot and not slot.down and not slot.left and slot.health > 0
end

local function kitName(slot)
    local kit = slot and kits[slot.kitId]
    return if kit then kit.name else "Fighter"
end

local function participantName(slot)
    return if slot and type(slot.userName) == "string" and slot.userName ~= "" then slot.userName else kitName(slot)
end

local function layout()
    local width, height = gui.AbsoluteSize.X, gui.AbsoluteSize.Y
    local compact = height <= 400 or width < 620
    local touch = UserInputService.TouchEnabled and not gamepad()
    local header = if compact then 63 else 84
    hud.Position, hud.Size = UDim2.new(.5, 0, 0, if compact then 5 else 9), UDim2.new(.94, 0, 0, header)
    hudLimit.MaxSize = Vector2.new(if compact then 476 else 660, header)
    heading.Position, heading.Size = UDim2.fromOffset(10, 4), UDim2.new(1, if compact then -113 else -133, 0, if compact then 21 else 27)
    heading.TextSize = if compact then 14 else 20
    timer.Position, timer.Size = UDim2.new(1, -60, 0, 4), UDim2.fromOffset(50, if compact then 21 else 27)
    timer.TextSize = if compact then 15 else 19
    phase.Position, phase.Size = UDim2.new(1, if compact then -117 else -136, 0, 4),
        UDim2.fromOffset(if compact then 53 else 68, if compact then 21 else 27)
    phase.TextSize = if compact then 9 else 12
    health.track.Position = UDim2.fromOffset(9, if compact then 26 else 34)
    health.track.Size = UDim2.new(1, -18, 0, if compact then 13 else 18)
    healthValue.TextSize = if compact then 9 else 11
    cue.Position, cue.Size = UDim2.fromOffset(8, if compact then 41 else 55),
        UDim2.new(1, -16, 0, if compact then 17 else 21)
    cue.TextSize = if compact then 11 else 13
    reviveMeter.Position, reviveMeter.Size = UDim2.new(0, 10, 1, -4), UDim2.new(1, -20, 0, 2)

    local cols = if width < 470 then 2 else 4
    local cardH = if compact then 24 else 33
    local partyH = if cols == 2 then cardH * 2 + 4 else cardH
    local partyTop = header + hud.Position.Y.Offset + 5
    party.Position, party.Size = UDim2.new(.5, 0, 0, partyTop), UDim2.new(.94, 0, 0, partyH)
    partyLimit.MaxSize = Vector2.new(if compact then 476 else 660, partyH)
    for index, tile in slots do
        local offset = index - 1
        tile.node.Position = UDim2.new((offset % cols) / cols, 2, 0, math.floor(offset / cols) * (cardH + 4))
        tile.node.Size = UDim2.new(1 / cols, -4, 0, cardH)
        local portraitSize = if compact then 18 else 26
        tile.portraitFrame.Position = UDim2.fromOffset(4, 2)
        tile.portraitFrame.Size = UDim2.fromOffset(portraitSize, portraitSize)
        local nameStart = if tile.portraitFrame.Visible then portraitSize + 8 else 6
        tile.name.Position, tile.name.Size = UDim2.fromOffset(nameStart, 1), UDim2.new(1, -(nameStart + 37), 1, -4)
        tile.name.TextSize = if compact then 10 else 12
        tile.state.Position, tile.state.Size = UDim2.new(1, -36, 0, 1), UDim2.new(0, 30, 1, -4)
        tile.state.TextSize = if compact then 9 else 11
        tile.meter.Position, tile.meter.Size = UDim2.new(0, 5, 1, -4), UDim2.new(1, -10, 0, 2)
    end

    local own = localSlot()
    local kit = own and kits[own.kitId]
    local hasTechnique = not kit or kit.technique ~= nil
        or fighterTactics.forKit(own.kitId, own.tactical) ~= nil
    local order = if not hasTechnique then {"strike", "heavy", "guard", "dodge", "signature", "revive", "leave"}
        else {"strike", "technique", "heavy", "guard", "dodge", "signature", "revive", "leave"}
    local stacked = width < 510 or (touch and width < 630)
    local columns = if stacked then 4 else #order
    local rowH = if compact then 44 else 48
    local actionH = if stacked then 2 * rowH + 4 else rowH
    local preferredBottom = if touch and stacked then math.min(92, math.floor(height * .19)) elseif touch then 16 else 25
    local bottom = math.clamp(height - partyTop - partyH - actionH - 6, 0, preferredBottom)
    local board
    if touch then
        local portrait = height > width
        local inset = GuiService:GetInsetArea(Enum.ScreenInsets.CoreUISafeInsets)
        board = CombatTouchDock.layout(playerGui, inset.Min, width, height, {
            count = #order, columns = 4, rowHeight = rowH, cellWidth = if portrait then 86 else 64,
            top = partyTop + partyH + 6, bottom = if portrait then math.floor(height * .56) - 8 else height - 16,
        })
    end
    if board then
        columns = board.columns
        controls.Position = UDim2.fromOffset(board.x + board.w * .5, board.y + board.h)
        controls.Size = UDim2.fromOffset(board.w, board.h)
        controlsLimit.MaxSize = Vector2.new(board.w, board.h)
    else
        controls.Position = UDim2.new(.5, 0, 1, -bottom)
        controls.Size = UDim2.new(if touch and not stacked then .81 else .94, 0, 0, actionH)
        controlsLimit.MaxSize = Vector2.new(if stacked then 390 elseif touch then 398 elseif compact then 560 else 688, actionH)
    end
    for index, action in order do
        local offset = index - 1
        local node = actions[action]
        local rowHeight, gap = if board then board.rowHeight else rowH, if board then board.gap else 4
        node.Position = UDim2.new((offset % columns) / columns, gap * .5, 0, math.floor(offset / columns) * (rowHeight + gap))
        node.Size = UDim2.new(1 / columns, -gap, 0, rowHeight)
        node.TextSize = if touch and not stacked then 10 elseif compact then 12 else 13
    end
    local dock = if touch then math.min(95, math.floor(height * .24)) else 22
    queue.Position, notice.Position = UDim2.new(.5, 0, 1, -dock), UDim2.new(.5, 0, 1, -dock)
    resultTitle.TextSize = if width < 370 then 20 else 23
end

local function refreshParty()
    for index, tile in slots do
        local slot = match.slots[index]
        local own = index == match.selfIndex
        tile.node.Visible = slot ~= nil
        tile.portraitFrame.Visible = own
        if slot then
            local name = if own then "You" else participantName(slot)
            local down = slot.down or slot.health <= 0
            tile.name.Text = name
            tile.state.Text = if slot.left then "Left" elseif down then (if slot.reviveUsed then "Out" else "Down")
                else tostring(math.round(slot.health))
            tile.state.TextColor3 = if down then coral else muted
            local revival = match.revive and match.revive.targetIndex or match.reviveTarget
            tile.rim.Color = if not slot.left and down and revival == index then mint elseif down then coral else matchRaid.rim
            tile.fill.Size = UDim2.fromScale(if slot.left or slot.maxHealth <= 0 then 0
                else math.clamp(slot.health / slot.maxHealth, 0, 1), 1)
            Portraits.set(tile.portrait, if own then kitName(slot) else nil)
        end
    end
end

local function active(now)
    return match and not detached and not leaving and not match.resolvedAt and now >= match.startsAt and now < match.endsAt
end

local function binding(name, key, pad)
    return name .. (if UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then " · " .. key
        elseif gamepad() then " · " .. pad else "")
end

local function refreshActions(own, now)
    local kit = kits[own.kitId] or kits.reedguard
    local option = fighterTactics.forKit(own.kitId, own.tactical)
    local techniqueName = if option then option.name else kit.technique
    local fighting = active(now) and canFight(own)
    for action, control in actions do
        control.Visible = if action == "leave" then not match.resolvedAt
            elseif action == "technique" then fighting and techniqueName ~= nil else fighting
    end
    local choices = fighterLoadouts.ByKit[own.kitId]
    local basic = fighterLoadouts.forKit(own.kitId, "basic", own.basic)
    local strike = "Strike"
    if basic and basic.id ~= choices.basic.default then
        local width = actions.strike.AbsoluteSize.X
        strike = if width > 0 and width < 100 then basic.compact or basic.name else basic.name
    end
    actions.strike.Text = binding(strike, "E", "RT")
    actions.heavy.Text = binding("Heavy", "R", "RB")
    actions.guard.Text, actions.dodge.Text = binding("Guard", "Q", "LT"), binding(kit.dodge or "Dodge", "X", "LB")
    actions.leave.Text = binding(if leaving then "Leaving…" else "Leave", "C", "B")
    local function cooldown(control, name, key, pad, readyAt)
        local seconds = if readyAt then math.max(0, math.ceil(readyAt - now)) else 0
        control.Text = if seconds > 0 then name .. "\n" .. seconds .. "s" else binding(name, key, pad)
        control.TextColor3 = if seconds > 0 then muted else paper
    end
    if techniqueName then
        local width = actions.technique.AbsoluteSize.X
        local compactWidth = if option then 100 else 70
        local compactName = if option then option.compact else kit.compactTechnique
        local technique = if compactName and width > 0 and width < compactWidth then compactName else techniqueName
        cooldown(actions.technique, technique, "V", "↑", match.nextSecondary)
    end
    local width = actions.signature.AbsoluteSize.X
    local ultimate = fighterLoadouts.forKit(own.kitId, "ultimate", own.ultimate)
    local customUltimate = ultimate and ultimate.id ~= choices.ultimate.default
    local compactName = if customUltimate then ultimate.compact else kit.compactSignature
    local name = if customUltimate then ultimate.name else kit.signature
    local signature = if compactName and width > 0 and width < (if customUltimate then 100 else 70) then compactName else name
    cooldown(actions.signature, signature, "F", "Y", match.nextSignature)

    local ready = fighting and match.reviveTarget ~= nil and match.revive == nil
    actions.revive.Active, actions.revive.AutoButtonColor = ready, ready
    actions.revive.BackgroundColor3, actions.revive.TextColor3 = if ready then jade else wood, if ready then mint else muted
    actions.revive.Text = if match.revive then "Reviving" else binding("Revive", "G", "→")
end

local function refreshCue(own, now)
    local color = paper
    local message = if match.feedback == "hit" then "Hit by " .. matchRaid.short
        elseif match.feedback == "core" then matchRaid.target .. " hit"
        else feedback[match.feedback] or earnedCues[match.feedback] or ""
    local attack, revival = match.attack, match.revive
    local copy = attack and attackCues[attack.id]
    local attackName = attack and (attack.name or (copy and copy.name) or "Attack")
    local warning = attack and attack.impactAt and now >= (attack.windupAt or 0) and now < attack.impactAt
    local movementEnd = attack and (if copy and copy.untilLastHit then attack.lastImpactAt or attack.endAt else attack.endAt)
    local moving = copy and copy.moving and attack.impactAt and movementEnd
        and now >= attack.impactAt and now < movementEnd
    local descending = attack and attack.id == "dawnLanding" and type(attack.landAt) == "number" and now < attack.landAt
    reviveMeter.Visible = false
    if match.resolvedAt then
        message = if match.bossHealth <= 0 then matchRaid.defeated else "Encounter over"
    elseif now < match.startsAt then
        message = "Raid starts in " .. math.ceil(match.startsAt - now)
    elseif own.left or own.down or own.health <= 0 then
        message = if own.reviveUsed or own.left then "Out · Watch your party" else "Down · An ally can revive you"
        color = coral
    elseif revival and revival.endsAt and revival.startedAt and revival.endsAt > revival.startedAt then
        local remaining = math.max(0, revival.endsAt - now)
        message = if warning then string.format("%s in %.1fs · Reviving", attackName, attack.impactAt - now)
            elseif moving then copy.moving .. " · Reviving"
            else string.format("Reviving %s · %.1fs", participantName(match.slots[revival.targetIndex]), remaining)
        local progress = math.clamp((now - revival.startedAt) / (revival.endsAt - revival.startedAt), 0, 1)
        reviveMeter.Visible = true
        reviveFill.Size = UDim2.fromScale(progress, 1)
        color = if warning or moving then amber else mint
    elseif warning then
        local hint = (copy and copy.hint) or attack.hint or "Move to safety"
        message = string.format("%s · %.1fs · %s", attackName, attack.impactAt - now, hint)
        color = amber
    elseif moving then
        message, color = copy.moving .. " · " .. copy.safe, amber
    elseif descending then
        message, color = string.format("Dawn Landing · %.1fs", attack.landAt - now), amber
    elseif steering:active(now) and match.feedback ~= "stormThunder" then
        message = steering.hint
    elseif not match.bossAirborne and match.vulnerableUntil and now < match.vulnerableUntil then
        message = string.format("%s exposed · %.1fs", matchRaid.target, match.vulnerableUntil - now)
        color = mint
    elseif match.reviveTarget then
        message = "Revive " .. participantName(match.slots[match.reviveTarget])
        color = mint
    elseif match.bossAirborne and message == "" then
        message = "Airborne · Watch the floor"
    end
    cue.Text, cue.TextColor3 = message, color
end

local function tell(raid, message, now)
    if type(message) == "string" and message ~= "" then
        noticeText.Text, noticeUntil, noticeRaid = message, now + 5, raid
    end
end

local function refresh()
    local now = workspace:GetServerTimeNow()
    local current = match ~= nil and not detached
    local occupied = player:GetAttribute("SparringActive") or player:GetAttribute("BrawlActive")
        or player:GetAttribute("TagTeamActive") or player:GetAttribute("SkywalkTrialMode")
        or player:GetAttribute("StarterSelectionRequired")
    local world = not current and not recap.Visible and not occupied and not menuOpen()
    local near = world and nearGate() or nil
    local gateSchedule = near and near.schedule
    if near and now >= near.nextStatusAt and (near ~= nearbyRaid or not gateSchedule or not gateSchedule.opensAt
        or now >= gateSchedule.opensAt) then
        near.nextStatusAt = now + 5
        near.remote:FireServer("status")
    end
    nearbyRaid = near

    displayedRaid = world and (queuedRaid or near) or nil
    local schedule = displayedRaid and displayedRaid.schedule
    local queued = queuedRaid ~= nil and displayedRaid == queuedRaid
    local canJoin = displayedRaid == near and schedule ~= nil and schedule.canJoin == true
        and not queued and now < (schedule.closesAt or math.huge)
    local wasVisible, hadCancel, hadJoin = queue.Visible, cancel.Visible, join.Visible
    local showNotice = world and now < noticeUntil and (not near or near == noticeRaid)
    queue.Visible = world and schedule ~= nil and (queued or (near and not showNotice))
    notice.Visible = showNotice and not queue.Visible
    cancel.Visible, join.Visible = queued, canJoin
    if queue.Visible then
        queue.BackgroundColor3, queueRim.Color, queueTitle.TextColor3 = displayedRaid.panel, displayedRaid.rim, displayedRaid.accent
        local open = schedule.opensAt or now
        local closes = schedule.closesAt or math.huge
        local count, required = schedule.count or 0, schedule.required or 4
        queueTitle.Text = if queued or (open <= now and now < closes) then string.format("%s · %d/%d", displayedRaid.label, count, required)
            else displayedRaid.label
        queueDetail.Text = if schedule.message then schedule.message
            elseif now < open then "Opens in " .. clockText(open - now)
            elseif now >= closes then "Checking the next opening…"
            elseif queued then (if closes < math.huge then "Closes in " .. clockText(closes - now) else "Waiting for the party")
            else "Use the gate to enter"
        queueTitle.Size = UDim2.new(1, if queued or canJoin then -123 else -26, 0, 21)
        queueDetail.Size = UDim2.new(1, if queued or canJoin then -123 else -26, 0, 27)
    end
    if wasVisible ~= queue.Visible or hadCancel ~= cancel.Visible or hadJoin ~= join.Visible then focus() end

    hud.Visible, party.Visible, controls.Visible = current, current, current
    if not current then
        return
    end
    local own = localSlot()
    if not match.resolvedAt and not own.left and not own.down and own.health > 0 and not leaving and now < match.endsAt then
        CombatAudio.countdown(match.startsAt - now)
    end
    timer.Text = clockText(match.endsAt - math.max(match.resolvedAt or now, match.startsAt))
    phase.Text = if match.phase == 2 then "PHASE 2" else "PHASE 1"
    phase.TextColor3 = if match.phase == 2 then amber else muted
    refreshCue(own, now)
    refreshActions(own, now)
end

local function closeRecap()
    recap.Visible = false
    player:SetAttribute("KilnbackRaidRecapOpen", nil)
    focus()
    refresh()
end

local function send(action, direction)
    if not match or not matchRaid or detached or leaving then
        return
    end
    local remote = matchRaid.remote
    local now = workspace:GetServerTimeNow()
    if action == "leave" and not match.resolvedAt then
        CombatWindup.clear()
        leaving = true
        remote:FireServer("leave", nil, match.matchId)
        refresh()
        return
    end
    local own = localSlot()
    if not active(now) or not canFight(own) then return end
    if action == "revive" then
        if match.reviveTarget and not match.revive then
            CombatWindup.clear()
            remote:FireServer("revive", match.reviveTarget, match.matchId)
        end
        return
    end
    if action == "technique" then
        local kit = kits[own.kitId] or kits.reedguard
        local option = fighterTactics.forKit(own.kitId, own.tactical)
        action = if option then option.action else kit.techniqueAction
    end
    if not action then return end
    if action == "dodge" or action == "secondary" then
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        direction = if root and humanoid and humanoid.MoveDirection:Dot(root.CFrame.RightVector) < -.2 then -1 else 1
    end
    remote:FireServer(action, direction, match.matchId, CombatWindup.begin(action))
end

join.Activated:Connect(function()
    if queue.Visible and join.Visible and displayedRaid then displayedRaid.remote:FireServer("join") end
end)
cancel.Activated:Connect(function()
    if queue.Visible and cancel.Visible and queuedRaid then queuedRaid.remote:FireServer("cancel") end
end)
close.Activated:Connect(closeRecap)
for action, control in actions do
    control.Activated:Connect(function() send(action) end)
end
UserInputService.InputBegan:Connect(function(input, consumed)
    if consumed or UserInputService:GetFocusedTextBox() then return end
    local back = input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Backspace
    if recap.Visible then
        if back then closeRecap() end
    elseif match then
        local action = keys[input.KeyCode]
        if action then send(action) end
    elseif back and queue.Visible and cancel.Visible and queuedRaid then
        queuedRaid.remote:FireServer("cancel")
    end
end)

local resultTitles = {
    loss = "The party was defeated", timeout = "Time expired",
    left = "You left the raid", cancelled = "Raid cancelled",
}
local resultReasons = {
    wipe = "Every remaining fighter went down.", earlyDeparture = "The raid ended before the first attack.",
}

local function themeMatch(raid)
    hud.BackgroundColor3, hudRim.Color, heading.Text = raid.panel, raid.rim, raid.name
    timer.TextColor3 = raid.accent
    for _, tile in slots do
        tile.node.BackgroundColor3 = raid.panel
    end
    local tone = raid.health or defaultHealthTone
    health.tone = tone
    healthRim.Color = tone:Lerp(black, .6)
    healthGradient.Color = ColorSequence.new(tone:Lerp(white, .40), tone:Lerp(black, .23))
end

local function showReward()
    trophyLine.Text = ""
    if reward and reward.status == "saved" then
        local grants = {}
        if type(reward.tokens) == "number" and reward.tokens > 0 then
            table.insert(grants, string.format("+%d Raid Tokens", reward.tokens))
        end
        if type(reward.shards) == "number" and reward.shards > 0 then
            table.insert(grants, string.format("+%d Mythic %s", reward.shards, if reward.shards == 1 then "Shard" else "Shards"))
        end
        rewardLine.Text = if #grants > 0 then table.concat(grants, "  ·  ") else "Raid reward recorded"
        if reward.newTrophy == true and type(reward.trophy) == "string" then
            trophyLine.Text = reward.trophy .. " earned"
        end
    elseif reward and reward.status == "already" then
        rewardLine.Text = "Reward already recorded"
    elseif reward and reward.status == "unavailable" then
        rewardLine.Text = "Reward save unavailable"
    elseif (reward and reward.status == "pending") or (outcome and outcome.rewardPending == true) then
        rewardLine.Text = "Saving raid rewards…"
    else
        rewardLine.Text = ""
    end
    rewardLine.TextColor3 = if reward and reward.status == "unavailable" then coral else mint
end

local function receive(raid, kind, data)
    if type(data) ~= "table" or (data.raidId or "kilnback") ~= raid.id then return end
    local now = workspace:GetServerTimeNow()
    if kind == "schedule" or kind == "queue" then
        raid.schedule = data
        local wasQueued = queuedRaid == raid
        if not match and data.queued then
            queuedRaid = raid
        elseif wasQueued then
            queuedRaid = nil
        end
        if kind == "queue" and not data.queued and (wasQueued or nearbyRaid == raid) then tell(raid, data.message, now) end
    elseif kind == "notice" then
        if raid == queuedRaid or raid == nearbyRaid then tell(raid, data.message, now) end
    elseif kind == "begin" or kind == "update" then
        if type(data.slots) ~= "table" or not data.selfIndex or not data.slots[data.selfIndex]
            or type(data.startsAt) ~= "number" or type(data.endsAt) ~= "number"
            or type(data.bossHealth) ~= "number" or type(data.bossMaxHealth) ~= "number" then return end
        local beginning = kind == "begin"
        if beginning then
            if type(data.matchId) ~= "number" or data.matchId <= raid.lastMatchId
                or (match and data.startsAt <= match.startsAt) then return end
            raid.lastMatchId = data.matchId
            if queuedRaid then queuedRaid.schedule = nil end
            raid.schedule, queuedRaid, noticeUntil = nil, nil, 0
            outcome, outcomeRaid, reward, earlyReward = nil, nil, nil, nil
            leaving, detached = false, false
            themeMatch(raid)
            CombatAudio.prepare()
            CombatAudio.resetCountdown()
        elseif not match or matchRaid ~= raid or match.matchId ~= data.matchId then
            return
        end
        local previousSlot = localSlot()
        local currentSlot = data.slots[data.selfIndex]
        match, matchRaid = data, raid
        if beginning or data.resolvedAt or not canFight(currentSlot)
            or (previousSlot and currentSlot.health < previousSlot.health) then
            CombatWindup.clear()
        end
        health:Set(data.bossHealth, data.bossMaxHealth, raid.name, beginning)
        CombatPresentation.playLocalContact(data.hitStop, now)
        healthValue.Text = string.format("%d / %d HP", math.round(data.bossHealth), math.round(data.bossMaxHealth))
        refreshParty()
        if beginning then
            layout()
            closeRecap()
        end
    elseif kind == "result" and match and matchRaid == raid and data.matchId == match.matchId then
        CombatWindup.clear()
        match, matchRaid, raid.schedule, leaving, detached = nil, nil, nil, false, false
        outcome, outcomeRaid, reward, earlyReward = data, raid, earlyReward, nil
        health:Snap()
        for _, tile in slots do Portraits.set(tile.portrait, nil) end
        recap.BackgroundColor3, recapRim.Color, resultTitle.TextColor3 = raid.panel, raid.rim, raid.accent
        resultTitle.Text = if data.reason == "timeout" then resultTitles.timeout elseif data.result == "win"
            then raid.short .. " defeated" else resultTitles[data.result] or "Raid finished"
        resultDetail.Text = data.message or resultReasons[data.reason] or (if data.result == "win" then raid.clear
            elseif data.reason == "timeout" then raid.short .. " was still standing when time ran out."
            else "You returned to " .. raid.district .. ".")
        showReward()
        recap.Visible = true
        player:SetAttribute("KilnbackRaidRecapOpen", true)
        focus()
    elseif kind == "reward" then
        if outcome and outcomeRaid == raid and data.matchId == outcome.matchId then
            reward = data
            showReward()
            if not recap.Visible and data.status == "saved" then
                tell(raid, if data.newTrophy and type(data.trophy) == "string" then data.trophy .. " earned" else "Raid reward saved", now)
            end
        elseif match and matchRaid == raid and data.matchId == match.matchId then
            earlyReward = data
        end
    end
    refresh()
end

for _, raid in raids do
    raid.remote.OnClientEvent:Connect(function(kind, data) receive(raid, kind, data) end)
end

player.CharacterRemoving:Connect(function()
    detached, queuedRaid = true, nil
    for _, raid in raids do raid.schedule = nil end
    refresh()
end)
player:GetAttributeChangedSignal("KilnbackRaidActive"):Connect(function()
    if not player:GetAttribute("KilnbackRaidActive") and match then detached = true end
    refresh()
end)
for _, attr in {"SparringActive", "BrawlActive", "TagTeamActive", "SkywalkTrialMode", "StarterSelectionRequired"} do
    player:GetAttributeChangedSignal(attr):Connect(refresh)
end

local function resize()
    layout()
    focus()
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(resize)
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()
    if match then health:Snap() end
end)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(function()
    if match then health:Snap() end
end)
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    local own = localSlot()
    steering:step(actions.signature.Visible and own and own.kitId == "dragon", send)
    elapsed += dt
    if elapsed >= .10 then
        elapsed = 0
        refresh()
    end
end)
CombatTouchDock.observe(playerGui, function()
    if controls.Visible and UserInputService.TouchEnabled and UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad then
        layout()
    end
end)
resize()
