local ContextActionService = game:GetService("ContextActionService")
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CameraImpact = require(script.Parent.CombatCameraImpact)

local movementAction = "GrandDojoRoundIntro"
local liveCameraStep = "GrandDojoLiveFightCamera"
local up = Vector3.yAxis
local gold = Color3.fromRGB(247, 197, 100)
local jade = Color3.fromRGB(148, 234, 195)
local parchment = Color3.fromRGB(255, 244, 217)

local Intro = {}
Intro.__index = Intro

local function label(parent, name, bounds, tint, font, min, max)
    local text = Instance.new("TextLabel")
    text.Name = name
    text.Size = bounds
    text.BackgroundTransparency = 1
    text.Font = font
    text.TextColor3 = tint
    text.TextScaled = true
    text.Text = ""
    text.ZIndex = 6
    local limits = Instance.new("UITextSizeConstraint")
    limits.MinTextSize, limits.MaxTextSize = min, max
    limits.Parent = text
    text.Parent = parent
    return text
end

local function trim(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end

function Intro.new(gui, player)
    local card = Instance.new("Frame")
    card.Name = "FightIntro"
    card.AnchorPoint = Vector2.new(.5, 1)
    card.Position = UDim2.new(.5, 0, 1, -26)
    card.Size = UDim2.new(.93, 0, 0, 86)
    card.BackgroundColor3 = Color3.fromRGB(21, 28, 33)
    card.BackgroundTransparency = .12
    card.BorderSizePixel = 0
    card.Visible = false
    card.ZIndex = 5
    trim(card, 9)
    local size = Instance.new("UISizeConstraint")
    size.MaxSize = Vector2.new(600, 86)
    size.Parent = card
    local rim = Instance.new("UIStroke")
    rim.Color = gold
    rim.Thickness = 1.3
    rim.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rim.Parent = card
    card.Parent = gui

    local small = label(card, "Role", UDim2.new(1, -24, 0, 20), gold, Enum.Font.GothamBold, 12, 15)
    small.Position = UDim2.fromOffset(12, 12)
    local title = label(card, "Fighter", UDim2.new(1, -24, 0, 38), parchment, Enum.Font.GothamBlack, 16, 29)
    title.Position = UDim2.fromOffset(12, 34)
    local line = Instance.new("Frame")
    line.Name = "CountdownTrack"
    line.AnchorPoint = Vector2.new(.5, 1)
    line.Position = UDim2.new(.5, 0, 1, -6)
    line.Size = UDim2.new(.58, 0, 0, 2)
    line.BackgroundColor3 = Color3.fromRGB(72, 89, 83)
    line.BorderSizePixel = 0
    line.ZIndex = 6
    line.Parent = card
    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BorderSizePixel = 0
    fill.BackgroundColor3 = gold
    fill.ZIndex = 7
    fill.Parent = line
    local count = label(gui, "FightCountdown", UDim2.fromOffset(154, 63), parchment, Enum.Font.GothamBlack, 30, 48)
    count.AnchorPoint = Vector2.new(.5, .5)
    count.Position = UDim2.fromScale(.5, .34)
    count.Visible = false
    local countStroke = Instance.new("UIStroke")
    countStroke.Color = Color3.fromRGB(12, 24, 22)
    countStroke.Thickness = 2
    countStroke.Parent = count

    return setmetatable({player = player, card = card, small = small, title = title, count = count,
        fill = fill, rim = rim}, Intro)
end

local function rootOf(player)
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function startingMarkers(court, presentation)
    if not court then
        return nil, nil
    end
    if presentation.duel then
        local first, second = court:FindFirstChild("First Spawn"), court:FindFirstChild("Second Spawn")
        if presentation.sideIndex == 2 then
            return second, first
        end
        return first, second
    end
    return court:FindFirstChild("Player Spawn"), court:FindFirstChild("Bot Spawn")
end

local function opponentModel(court, presentation)
    if presentation.duel then
        local userId = presentation.opponentUserId
        local opponent = if type(userId) == "number" then Players:GetPlayerByUserId(userId) else nil
        return opponent and opponent.Character
    end
    return court and court:FindFirstChild(presentation.resident)
end

local function warmActor(model, art)
    if not model or art.queued then
        return
    end
    local meshes = {}
    for _, part in model:GetChildren() do
        if part:IsA("MeshPart") then
            table.insert(meshes, part)
        end
    end
    -- Each equipped shell has six main groups. Wait for replication only
    -- within the intro's existing server-clock window.
    if #meshes < 6 then
        return
    end
    art.queued = true
    task.spawn(function()
        local assetsReady = true
        local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, meshes, function(_, status)
            if status ~= Enum.AssetFetchStatus.Success then
                assetsReady = false
            end
        end)
        art.ready = ok and assetsReady
    end)
end

local function takeCamera(player)
    local camera, root = workspace.CurrentCamera, rootOf(player)
    if not (camera and root) or camera.CameraType ~= Enum.CameraType.Custom
        or UserInputService.VREnabled or GuiService.ReducedMotionEnabled then
        return nil
    end
    local saved = {camera = camera, subject = camera.CameraSubject, kind = camera.CameraType,
        fov = camera.FieldOfView, offset = camera.CFrame.Position - root.Position}
    camera.CameraType = Enum.CameraType.Scriptable
    return saved
end

function Intro:_restoreCamera()
    local saved = self.camera
    self.camera = nil
    if not saved or saved.camera.CameraType ~= Enum.CameraType.Scriptable then
        return
    end
    local camera, root = saved.camera, rootOf(self.player)
    if root then
        local offset = saved.offset
        local distance = offset.Magnitude
        if distance < 3 or distance > 22 or offset:Dot(root.CFrame.LookVector) > -1 then
            offset = -root.CFrame.LookVector * 11 + Vector3.new(0, 3.7, 0)
        end
        local focus = root.Position + Vector3.new(0, .8, 0)
        camera.CFrame = CFrame.lookAt(focus + offset, focus)
        camera.Focus = CFrame.new(focus)
    end
    camera.FieldOfView = saved.fov
    if saved.subject and saved.subject.Parent then
        camera.CameraSubject = saved.subject
    end
    camera.CameraType = saved.kind
end

function Intro:_dismissCard()
    if self.locked then
        self.locked = false
        ContextActionService:UnbindAction(movementAction)
    end
    self.card.Visible = false
end

function Intro:_hideCount()
    if self.render then
        self.render:Disconnect()
        self.render = nil
    end
    self.count.Visible = false
end

function Intro:_stopLive()
    if self.liveRender then
        self.liveRender = nil
        RunService:UnbindFromRenderStep(liveCameraStep)
    end
end

function Intro:Stop(preserveCamera)
    self:_stopLive()
    if not preserveCamera then
        self:_restoreCamera()
    end
    self:_dismissCard()
    self:_hideCount()
end

local function lens(camera, focus, eye, fieldOfView)
    camera.CFrame = CFrame.lookAt(eye, focus)
    camera.Focus = CFrame.new(focus)
    camera.FieldOfView = fieldOfView
end

local function viewportFit(camera, fieldOfView)
    local viewport = camera.ViewportSize
    local aspect = if viewport.Y > 1 and viewport.X > 1 then math.max(.25, viewport.X / viewport.Y) else 1.6
    local narrow = math.clamp((1.2 - aspect) / .65, 0, 1)
    local fov = fieldOfView + 14 * narrow
    local vertical = math.tan(math.rad(fov) * .5)
    -- Leave the health and action rows outside the fighter silhouettes.
    return fov, vertical * aspect * .84, vertical * .70, narrow
end

local function pairDistance(focus, direction, first, second, horizontal, vertical, wide)
    local frame = CFrame.lookAt(direction, Vector3.zero)
    -- Include the ears, gloves, tails, and the near face of each fitted shell.
    local shoulder, halfHeight = if wide then 2.32 else 1.95, if wide then 2.74 else 2.55
    local a, b = first - focus, second - focus
    local aDistance = a:Dot(direction) + math.max(
        (math.abs(a:Dot(frame.RightVector)) + shoulder) / horizontal,
        (math.abs(a:Dot(frame.UpVector)) + halfHeight) / vertical)
    local bDistance = b:Dot(direction) + math.max(
        (math.abs(b:Dot(frame.RightVector)) + shoulder) / horizontal,
        (math.abs(b:Dot(frame.UpVector)) + halfHeight) / vertical)
    return math.max(aDistance, bDistance) + 1.2
end

local function fittedPair(camera, first, second, offset, fieldOfView, wide)
    local fov, horizontal, vertical = viewportFit(camera, fieldOfView)
    local focus = first:Lerp(second, .5) + up * .14
    local direction = offset.Unit
    local distance = math.max(offset.Magnitude, pairDistance(focus, direction, first, second, horizontal, vertical, wide))
    lens(camera, focus, focus + direction * distance, fov)
end

function Intro:_shot(court, stage, age, presentation)
    local saved = self.camera
    if not saved then
        return
    end
    if workspace.CurrentCamera ~= saved.camera or saved.camera.CameraType ~= Enum.CameraType.Scriptable
        or UserInputService.VREnabled or GuiService.ReducedMotionEnabled then
        self:_restoreCamera()
        return
    end
    local playerSpawn, opponentSpawn = startingMarkers(court, presentation)
    if not (playerSpawn and opponentSpawn) then
        self:_restoreCamera()
        return
    end
    local camera = saved.camera
    local forward, right = playerSpawn.CFrame.LookVector, playerSpawn.CFrame.RightVector
    local wideFighters = presentation.wideFighters
    local deckLift = if presentation.deckView then .85 else 0
    local headroom = if wideFighters then .34 else 0
    local closeDistance = if wideFighters then 6.9 else 6.2
    local challenger = playerSpawn.Position + up * (.28 + headroom)
    local opponentHeight = if presentation.duel then .28 else 2.26
    local resident = opponentSpawn.Position + up * (opponentHeight + headroom)
    local _, _, _, narrow = viewportFit(camera, 58)
    if stage == 1 then
        fittedPair(camera, challenger, resident, right * (13.5 - math.clamp(age, 0, 2.3) * .65)
            - forward * (4.2 + 3.6 * narrow) + up * (4.3 + deckLift), if wideFighters then 61 else 58, wideFighters)
    elseif stage == 2 then
        local offset = right * (4.5 - (age - 2.3) * .33) + forward * closeDistance + up * 1.5
        if narrow > 0 then
            fittedPair(camera, challenger, challenger, offset, 46, wideFighters)
        else
            lens(camera, challenger, challenger + offset, 46)
        end
    elseif stage == 3 then
        local offset = right * (4.8 - (age - 4.8) * .35) - forward * closeDistance + up * 1.6
        if narrow > 0 then
            fittedPair(camera, resident, resident, offset, 46, wideFighters)
        else
            lens(camera, resident, resident + offset, 46)
        end
    else
        local mix = math.clamp((age - (if presentation.quickRound then 0 else 7)) / 3, 0, 1)
        fittedPair(camera, challenger, resident, right * (12.2 - mix * 2.2)
            - forward * (3.4 + 4 * narrow) + up * (3.5 + deckLift), 60 - mix * 3, wideFighters)
    end
end

function Intro:_startLive(court, presentation)
    local spawn = startingMarkers(court, presentation)
    local opponent = opponentModel(court, presentation)
    local follow = if opponent and presentation.duel then opponent:FindFirstChild("HumanoidRootPart") else opponent
    if not spawn or not follow then
        self:_restoreCamera()
        return
    end
    local introCamera = self.camera
    local saved = introCamera or takeCamera(self.player)
    local challenger = rootOf(self.player)
    if not saved or not challenger then
        self:_restoreCamera()
        return
    end
    self.camera = saved
    local right, forward = spawn.CFrame.RightVector, spawn.CFrame.LookVector
    local wide = presentation.wideFighters
    local pitch = if presentation.deckView then .35 else .29
    local fieldOfView = if presentation.deckView then 57 else 54
    local currentFocus, currentDirection, currentDistance
    if introCamera then
        currentFocus = saved.camera.Focus.Position
        local offset = saved.camera.CFrame.Position - currentFocus
        currentDirection, currentDistance = offset.Unit, offset.Magnitude
    end
    self.liveRender = true
    RunService:BindToRenderStep(liveCameraStep, Enum.RenderPriority.Camera.Value + 10, function(dt)
        local root, camera = rootOf(self.player), saved.camera
        if root ~= challenger or not follow.Parent or not opponent.Parent or workspace.CurrentCamera ~= camera
            or camera.CameraType ~= Enum.CameraType.Scriptable
            or UserInputService.VREnabled or GuiService.ReducedMotionEnabled then
            self:_stopLive()
            self:_restoreCamera()
            return
        end
        local first = root.Position + up * .43
        local second = if presentation.duel then follow.Position + up * .43 else follow:GetPivot().Position + up * 2.48
        local center = first:Lerp(second, .5) + up * .14
        local fov, horizontal, vertical, narrow = viewportFit(camera, fieldOfView)
        local side = (right - forward * (.24 + narrow * .16)).Unit
        local gap = first - second
        -- Raise the sightline a little when one fighter crosses behind the other.
        -- Keeping the same side prevents the movement controls from reversing.
        local lift = math.clamp((math.abs(gap:Dot(side)) - gap.Magnitude * .55) * .075, 0, .28)
        local direction = (side + up * (pitch + lift + narrow * .14)).Unit
        local alpha = 1 - math.exp(-dt * 10)
        currentFocus = if currentFocus then currentFocus:Lerp(center, alpha) else center
        currentDirection = if currentDirection then currentDirection:Lerp(direction, alpha).Unit else direction
        local required = math.max(if wide then 9.4 else 8.6,
            pairDistance(currentFocus, currentDirection, first, second, horizontal, vertical, wide))
        local easedDistance = if currentDistance then currentDistance + (required - currentDistance) * alpha else required
        currentDistance = math.max(required, easedDistance)
        local framing = CFrame.lookAt(currentFocus + currentDirection * currentDistance, currentFocus)
        camera.CFrame = CameraImpact.frame(camera, framing)
        camera.Focus = CFrame.new(currentFocus)
        camera.FieldOfView = fov
    end)
end

function Intro:Start(introAt, startsAt, court, presentation, onBell)
    self:Stop(presentation.quickRound)
    local now = workspace:GetServerTimeNow()
    if now >= startsAt then
        self:_startLive(court, presentation)
        onBell()
        return
    end
    self.camera = self.camera or takeCamera(self.player)
    self.card.Visible = true
    self.locked = true
    ContextActionService:BindActionAtPriority(movementAction, function()
        return Enum.ContextActionResult.Sink
    end, false, Enum.ContextActionPriority.High.Value, table.unpack(Enum.PlayerActions:GetEnumItems()))
    local challengerArt, residentArt = {}, {}
    local nextWarmAt = now
    local previousStage, finished = nil, false
    local function render()
        local serverNow = workspace:GetServerTimeNow()
        local remaining = startsAt - serverNow
        if remaining <= 0 then
            if not finished then
                finished = true
                self:_dismissCard()
                self:_startLive(court, presentation)
                self.count.Text = "FIGHT"
                self.count.Visible = true
                onBell()
            end
            if remaining < -.52 then
                self:_hideCount()
            end
            return
        end
        if not presentation.quickRound and self.camera and serverNow >= nextWarmAt
            and (not challengerArt.queued or not residentArt.queued) then
            nextWarmAt = serverNow + .25
            local character = self.player.Character
            local opponent = opponentModel(court, presentation)
            local shell = if opponent and presentation.duel then opponent:FindFirstChild("Starter Fighter Shell") else opponent
            warmActor(character and character:FindFirstChild("Starter Fighter Shell"), challengerArt)
            warmActor(shell, residentArt)
        end
        local age = math.max(0, startsAt - introAt - remaining)
        local stage = if presentation.quickRound then 4 elseif age < 2.3 then 1 elseif age < 4.8 then 2
            elseif remaining > 3 then 3 else 4
        if stage ~= previousStage then
            previousStage = stage
            self.small.Text = if stage == 2 then "CHALLENGER"
                elseif stage == 3 then presentation.opponentFighter or (if presentation.duel then "OPPONENT" else "RESIDENT")
                elseif presentation.roundIndex then "BEST OF 3"
                elseif presentation.duel then "1V1 DUEL" else "BOT SPAR"
            self.title.Text = if stage == 1 then presentation.ring elseif stage == 2 then presentation.challenger
                elseif stage == 3 then presentation.resident
                elseif presentation.quickRound then string.format("Round %d", presentation.roundIndex)
                else presentation.challengerShort .. "  vs  " .. presentation.residentShort
            self.small.TextColor3 = if stage == 3 then presentation.residentTint or jade
                else presentation.challengerTint or gold
            self.rim.Color = self.small.TextColor3
            self.fill.BackgroundColor3 = self.small.TextColor3
        end
        self.fill.Size = UDim2.fromScale(math.clamp(remaining / (startsAt - introAt), 0, 1), 1)
        self.count.Visible = remaining <= 3
        if self.count.Visible then
            self.count.Text = tostring(math.ceil(remaining))
        end
        local closeupPending = (stage == 2 and not challengerArt.ready) or (stage == 3 and not residentArt.ready)
        self:_shot(court, if closeupPending then 1 else stage, age, presentation)
    end
    render()
    self.render = RunService.RenderStepped:Connect(render)
end

return Intro
