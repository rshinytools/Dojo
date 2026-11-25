local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("GrandDojoBrawl")
local fighterCatalog = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog"))
local ChampionshipHud = require(ReplicatedStorage:WaitForChild("ChampionshipHud"))
local ChampionshipPortraits = require(ReplicatedStorage:WaitForChild("ChampionshipPortraits"))
local CombatAudio = require(ReplicatedStorage:WaitForChild("CombatAudio"))

local ink = Color3.fromRGB(19, 37, 40)
local jade = Color3.fromRGB(28, 53, 52)
local lacquer = Color3.fromRGB(66, 38, 39)
local gold = Color3.fromRGB(244, 189, 79)
local parchment = Color3.fromRGB(255, 242, 209)
local muted = Color3.fromRGB(190, 212, 199)
local bronze = Color3.fromRGB(145, 113, 65)
local white = Color3.fromRGB(255, 255, 255)
local titleFont = Enum.Font.GothamBold
local bodyFont = Enum.Font.GothamMedium

local function make(class, parent, properties)
    local object = Instance.new(class)
    for property, value in properties do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function style(frame, color)
    make("UICorner", frame, {CornerRadius = UDim.new(0, 11)})
    return make("UIStroke", frame, {Color = color or bronze, Thickness = 1.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function frame(parent, name, position, size, anchor)
    local object = make("Frame", parent, {
        Name = name, Position = position, Size = size, AnchorPoint = anchor, Visible = false,
        BackgroundColor3 = ink, BorderSizePixel = 0,
    })
    style(object)
    return object
end

local function label(parent, name, position, size, textSize, color, bold)
    return make("TextLabel", parent, {
        Name = name, Position = position, Size = size, Font = if bold then titleFont else bodyFont,
        BackgroundTransparency = 1, TextColor3 = color or parchment, TextSize = textSize, Text = "",
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local function button(parent, name, primary)
    local object = make("TextButton", parent, {
        Name = name, Text = name, Font = titleFont, TextSize = 13,
        TextColor3 = if primary then ink else parchment, BackgroundColor3 = if primary then gold else jade,
        AutoButtonColor = true, BorderSizePixel = 0, TextWrapped = true,
    })
    local outline = style(object, if primary then parchment else bronze)
    local normal = outline.Color
    object.SelectionGained:Connect(function()
        outline.Color, outline.Thickness = white, 3
    end)
    object.SelectionLost:Connect(function()
        outline.Color, outline.Thickness = normal, 1.4
    end)
    return object
end

local gui = make("ScreenGui", playerGui, {
    Name = "GrandDojoBrawl", DisplayOrder = 25, ResetOnSpawn = false, ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
    SafeAreaCompatibility = Enum.SafeAreaCompatibility.None, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local queue = frame(gui, "Queue", UDim2.new(.5, 0, 1, -24), UDim2.new(.94, 0, 0, 57), Vector2.new(.5, 1))
make("UISizeConstraint", queue, {MaxSize = Vector2.new(368, 57)})
local queueTitle = label(queue, "Heading", UDim2.fromOffset(12, 7), UDim2.new(1, -113, 0, 20), 15, gold, true)
local queueDetail = label(queue, "Detail", UDim2.fromOffset(12, 28), UDim2.new(1, -113, 0, 19), 12, muted)
local cancel = button(queue, "Cancel", false)
cancel.Position, cancel.Size = UDim2.new(1, -93, 0, 6), UDim2.fromOffset(86, 45)

local championship = ChampionshipHud.new(gui, titleFont, true)
local hud, health = championship.root, championship.left
hud.Name, hud.Visible = "Match", false
local fighterPortrait = ChampionshipPortraits.new(championship.leftPortrait, false, 12)
local heading, clock, alive, cue = championship.title, championship.clock, championship.score, championship.hint

local leave = button(gui, "Leave", false)
leave.AnchorPoint, leave.Size = Vector2.new(1, 0), UDim2.fromOffset(92, 44)
leave.Visible, leave.Selectable = false, false
leave.BackgroundColor3 = lacquer

local controls = make("Frame", gui, {
    Name = "Controls", BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, 1), Visible = false,
})
local controlLimit = make("UISizeConstraint", controls, {})
local actions = {
    strike = button(controls, "Strike", true), technique = button(controls, "Technique", false),
    heavy = button(controls, "Heavy", false), guard = button(controls, "Guard", false),
    dodge = button(controls, "Dodge", false), signature = button(controls, "Signature", false),
}
for action, control in actions do
    -- Gamepad actions have direct bindings during combat.
    control.Selectable = false
    if action ~= "strike" then
        control.BackgroundColor3 = lacquer
    end
end

local recap = frame(gui, "Result", UDim2.fromScale(.5, .5), UDim2.new(.9, 0, 0, 166), Vector2.new(.5, .5))
make("UISizeConstraint", recap, {MaxSize = Vector2.new(400, 166)})
local resultTitle = label(recap, "Heading", UDim2.fromOffset(15, 13), UDim2.new(1, -30, 0, 30), 22, gold, true)
local placement = label(recap, "Placement", UDim2.fromOffset(15, 46), UDim2.new(1, -30, 0, 24), 15, parchment, true)
local winner = label(recap, "Winner", UDim2.fromOffset(15, 73), UDim2.new(1, -30, 0, 22), 13, muted)
local close = button(recap, "Close", true)
close.Position, close.Size = UDim2.new(1, -118, 1, -56), UDim2.fromOffset(105, 44)

local notice = label(gui, "Notice", UDim2.new(.5, 0, 1, -88), UDim2.new(.9, 0, 0, 42), 13)
notice.AnchorPoint, notice.Visible = Vector2.new(.5, 1), false
notice.BackgroundTransparency, notice.BackgroundColor3 = .08, ink
notice.TextWrapped, notice.TextXAlignment = true, Enum.TextXAlignment.Center
make("UISizeConstraint", notice, {MaxSize = Vector2.new(410, 42)})
make("UIPadding", notice, {PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9)})
style(notice)

local earnedCues = {}
local kits = {
    reedguard = {fighter = "Reedguard", technique = "Uppercut", techniqueAction = "uppercut", signature = "Rising"},
    penguin = {fighter = "Penguin", dodge = "Floe Turn", signature = "Belly Slide"},
    silverback = {fighter = "Silverback", technique = "Ridge Palm", techniqueAction = "secondary", signature = "Seismic"},
    salamander = {fighter = "Salamander", technique = "Ember Sweep", techniqueAction = "secondary", signature = "Magma Trail"},
}
for _, fighter in fighterCatalog.ById do
    local combat = fighter.combat
    if combat then
        kits[combat.kit] = {
            fighter = fighter.shortName or fighter.name,
            technique = combat.technique, techniqueAction = combat.techniqueAction, signature = combat.signature,
            compactTechnique = combat.compactTechnique, compactSignature = combat.compactSignature,
        }
        if combat.techniqueCue then
            earnedCues[combat.techniqueCue] = combat.technique
        end
        earnedCues[combat.signatureCue] = combat.signature
    end
end
local keyMap = {
    [Enum.KeyCode.E] = "strike", [Enum.KeyCode.ButtonR2] = "strike", [Enum.KeyCode.ButtonX] = "strike",
    [Enum.KeyCode.Q] = "guard", [Enum.KeyCode.ButtonL2] = "guard",
    [Enum.KeyCode.R] = "heavy", [Enum.KeyCode.ButtonR1] = "heavy",
    [Enum.KeyCode.X] = "dodge", [Enum.KeyCode.ButtonL1] = "dodge",
    [Enum.KeyCode.V] = "technique", [Enum.KeyCode.DPadUp] = "technique",
    [Enum.KeyCode.F] = "signature", [Enum.KeyCode.ButtonY] = "signature",
    [Enum.KeyCode.C] = "leave", [Enum.KeyCode.ButtonB] = "leave",
}
local tips = {
    blocked = "Blocked", parried = "Parried! Counter now", attackBlocked = "Your strike was blocked",
    attackParried = "Your strike was parried", hit = "You took a hit", strike = "Strike landed",
    counter = "Counter landed", guard = "Guard up", needParry = "Parry to unlock Rising",
    projectileDeflected = "Projectile deflected!",
    gustPull = "Vortex pulls inward",
    snared = "Snared briefly", snareCaught = "Cinder Snare landed",
    ricochetBounce = "Shell rebounds",
    guardBroken = "Guard broken", burn = "Heat lingers",
    shockLanded = "Thunder shock landed", shocked = "Shocked briefly",
}

local waiting, match, lastResultId
local noticeUntil, stageCueUntil = 0, 0
local sendingLeave = false

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
    local input = UserInputService.PreferredInput
    local touch = UserInputService.TouchEnabled and input ~= Enum.PreferredInput.Gamepad
    local stacked = width < 480
    local compact = touch and height <= 430
    championship:Layout(compact or stacked, true)
    local preferredBottom = if compact and not stacked then 20
        elseif touch then math.min(112, math.floor(height * .24)) else 26
    local kit = match and (kits[match.kitId] or kits.reedguard) or kits.reedguard
    local order = if kit.technique then {"strike", "technique", "heavy", "guard", "dodge", "signature"}
        else {"strike", "heavy", "guard", "dodge", "signature"}
    local columns = if stacked then 3 else #order
    local controlHeight = if stacked then 102 else 48
    local narrow = width < 650
    local bottom = math.clamp(height - controlHeight - (if narrow then 151 else 86), 5, math.max(5, preferredBottom))
    controls.Position, controls.Size = UDim2.new(.5, 0, 1, -bottom), UDim2.new(.94, 0, 0, controlHeight)
    controlLimit.MaxSize = Vector2.new(if stacked then 345 elseif compact then 365 else 522, controlHeight)
    actions.technique.Visible = kit.technique ~= nil
    for index, action in order do
        local buttonIndex = index - 1
        local object = actions[action]
        object.Position = UDim2.new((buttonIndex % columns) / columns, 2, 0, math.floor(buttonIndex / columns) * 54)
        object.Size = UDim2.new(1 / columns, -4, 0, 48)
        object.TextSize = if compact then 12 else 13
    end
    local leaveTop = if width >= 1240 then 8 else hud.Position.Y.Offset + hud.Size.Y.Offset + 4
    leave.Position = UDim2.new(1, -8, 0, leaveTop)
    queue.Position = UDim2.new(.5, 0, 1, if touch then -math.min(122, math.floor(height * .29)) else -28)
end

local function updateActionLabels(now, kit)
    local keyboard = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
    local gamepad = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
    local function hint(text, key, pad)
        return text .. (if keyboard then " · " .. key elseif gamepad then " · " .. pad else "")
    end
    local function cooldown(object, text, key, pad, fireAt)
        local remaining = if type(fireAt) == "number" then math.max(0, math.ceil(fireAt - now)) else 0
        object.Text = if remaining > 0 then text .. "\n" .. tostring(remaining) .. "s" else hint(text, key, pad)
        object.TextColor3 = if remaining > 0 then muted else parchment
    end
    actions.strike.Text = hint("Strike", "E", "RT")
    actions.heavy.Text = hint("Heavy", "R", "RB")
    actions.guard.Text = hint("Guard", "Q", "LT")
    actions.dodge.Text = hint(kit.dodge or "Dodge", "X", "LB")
    if kit.technique then
        local width = actions.technique.AbsoluteSize.X
        local technique = if kit.compactTechnique and width > 0 and width < 70 then kit.compactTechnique else kit.technique
        cooldown(actions.technique, technique, "V", "↑", match.nextSecondary)
    end
    local width = actions.signature.AbsoluteSize.X
    local signature = if kit.compactSignature and width > 0 and width < 70 then kit.compactSignature else kit.signature
    cooldown(actions.signature, signature, "F", "Y", match.nextSignature)
    leave.Text = hint(if sendingLeave then "Leaving…" else "Leave", "C", "B")
end

local function refresh()
    local now = workspace:GetServerTimeNow()
    local current = match ~= nil and not match.detached
    local playerBusy = player:GetAttribute("SparringActive") or player:GetAttribute("BrawlActive")
        or player:GetAttribute("SkywalkTrialMode") or player:GetAttribute("StarterSelectionRequired")
    local worldOverlay = not current and not recap.Visible and not playerBusy and not menuOpen()
    queue.Visible = worldOverlay and waiting ~= nil
    notice.Visible = worldOverlay and not waiting and now < noticeUntil
    if queue.Visible then
        queueTitle.Text = string.format("Brawl queue · %d/%d", waiting.count, waiting.required)
        if type(waiting.expiresAt) == "number" then
            queueDetail.Text = string.format("Queue closes in %ds", math.max(0, math.ceil(waiting.expiresAt - now)))
        else
            queueDetail.Text = waiting.message or ""
        end
    end
    hud.Visible, leave.Visible = current, current
    controls.Visible = current and not match.eliminated and not match.resolvedAt and not sendingLeave
        and now >= match.startsAt and now < match.endsAt
    if not current then
        return
    end
    local kit = kits[match.kitId] or kits.reedguard
    local seconds = match.startsAt - now
    if not match.eliminated and not match.resolvedAt and not sendingLeave and now < match.endsAt then
        CombatAudio.countdown(seconds)
    end
    local nextShrinkAt, warningAt = match.nextShrinkAt, match.warningAt
    heading.Text = if match.eliminated then "WATCHING BRAWL" else "GRAND DOJO BRAWL"
    alive.Text = string.format("%d / %d left", match.alive, match.total)
    clock.Text = tostring(math.max(0, math.ceil(match.endsAt - math.max(match.resolvedAt or now, match.startsAt))))
    cue.TextColor3 = muted
    if match.eliminated then
        cue.Text = if match.placement then string.format("Placed %d · Watch or leave", match.placement) else "Watch or leave"
    elseif seconds > 0 then
        cue.Text, cue.TextColor3 = string.format("Starts in %d", math.ceil(seconds)), gold
    elseif match.feedback == "snared" or match.feedback == "shocked" then
        cue.Text, cue.TextColor3 = tips[match.feedback], gold
    elseif type(nextShrinkAt) == "number" and type(warningAt) == "number" and now >= warningAt and now < nextShrinkAt then
        cue.Text, cue.TextColor3 = string.format("Floor drops in %ds · Move inward", math.ceil(nextShrinkAt - now)), gold
    elseif now < stageCueUntil then
        cue.Text, cue.TextColor3 = "The safe floor shrank", gold
    else
        local text = tips[match.feedback] or earnedCues[match.feedback]
        cue.Text = text or ""
        if match.feedback == "parried" then
            cue.TextColor3 = Color3.fromRGB(141, 231, 231)
        end
    end
    updateActionLabels(now, kit)
end

local function closeRecap()
    recap.Visible = false
    if GuiService.SelectedObject == close then
        GuiService.SelectedObject = nil
    end
    player:SetAttribute("BrawlRecapOpen", nil)
    refresh()
end

local function send(action)
    if not match or match.detached or sendingLeave then
        return
    end
    if action == "leave" then
        sendingLeave = true
        remote:FireServer(action, nil, match.matchId)
        refresh()
        return
    end
    if not controls.Visible then
        return
    end
    local kit = kits[match.kitId] or kits.reedguard
    if action == "technique" then
        action = kit.techniqueAction
    end
    if not action then
        return
    end
    local direction
    if action == "dodge" or action == "secondary" then
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        direction = if root and humanoid and humanoid.MoveDirection:Dot(root.CFrame.RightVector) < -.2 then -1 else 1
    end
    remote:FireServer(action, direction, match.matchId)
end

for action, object in actions do
    object.Activated:Connect(function() send(action) end)
end
leave.Activated:Connect(function() send("leave") end)
close.Activated:Connect(closeRecap)
cancel.Activated:Connect(function()
    if queue.Visible then
        remote:FireServer("cancel")
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() then
        return
    end
    local back = input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Backspace
    if recap.Visible then
        if back then
            closeRecap()
        end
    elseif match then
        local action = keyMap[input.KeyCode]
        if action then
            send(action)
        end
    elseif back and queue.Visible then
        remote:FireServer("cancel")
    end
end)

local function noticeText(message)
    if type(message) == "string" and message ~= "" then
        notice.Text = message
        noticeUntil = workspace:GetServerTimeNow() + 3
    end
end

remote.OnClientEvent:Connect(function(kind, data)
    if kind == "notice" then
        noticeText(if type(data) == "table" then data.message else data)
    elseif type(data) ~= "table" then
        return
    elseif kind == "queue" then
        waiting = if data.queued then data else nil
        if not data.queued then
            noticeText(data.message)
        end
    elseif kind == "begin" or kind == "update" then
        if kind == "begin" then
            if data.matchId == nil or data.matchId == lastResultId then
                return
            end
            waiting = nil
            if recap.Visible then
                closeRecap()
            end
            sendingLeave, stageCueUntil = false, 0
            if not match or match.matchId ~= data.matchId then
                CombatAudio.prepare()
                CombatAudio.resetCountdown()
            end
        elseif not match or match.matchId ~= data.matchId then
            return
        elseif data.stage and match.stage and data.stage > match.stage then
            stageCueUntil = workspace:GetServerTimeNow() + 1.2
        end
        local detached = kind == "update" and match and match.detached
        match = data
        match.detached = detached
        local kit = kits[match.kitId] or kits.reedguard
        health:Set(match.playerHealth, match.maxHealth or match.playerMaxHealth, kit.fighter, kind == "begin")
        if kind == "begin" then
            ChampionshipPortraits.set(fighterPortrait, match.kitId)
            layout()
        end
    elseif kind == "result" then
        if not match or match.matchId ~= data.matchId or lastResultId == data.matchId then
            return
        end
        lastResultId = data.matchId
        match, waiting = nil, nil
        sendingLeave = false
        health:Snap()
        ChampionshipPortraits.set(fighterPortrait, nil)
        resultTitle.Text = if data.result == "win" then "Brawl champion" elseif data.result == "draw" then "Brawl draw"
            elseif data.result == "left" then "You left the brawl" else "Brawl finished"
        placement.Text = if data.placement and data.total then string.format("Place %d of %d", data.placement, data.total) else ""
        winner.Text = if data.winnerName and data.result ~= "win" then "Winner · " .. data.winnerName else ""
        recap.Visible = true
        player:SetAttribute("BrawlRecapOpen", true)
        if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
            GuiService.SelectedObject = close
        end
    end
    refresh()
end)

player.CharacterRemoving:Connect(function()
    if match then
        match.detached = true
    end
    waiting = nil
    refresh()
end)

player:GetAttributeChangedSignal("BrawlActive"):Connect(function()
    if not player:GetAttribute("BrawlActive") and match then
        -- Attribute replication may precede the result packet. Hide controls and retain that match for the recap.
        match.detached = true
    end
    refresh()
end)

local function resize()
    layout()
    refresh()
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(resize)
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function() health:Snap() end)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(function() health:Snap() end)

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed >= .12 then
        elapsed = 0
        refresh()
    end
end)
resize()
