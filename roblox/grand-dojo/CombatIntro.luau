local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local movementAction = "GrandDojoRoundIntro"
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

function Intro:_release()
    self:_restoreCamera()
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

function Intro:Stop()
    if self.liveRender then
        self.liveRender:Disconnect()
        self.liveRender = nil
    end
    self:_release()
    self:_hideCount()
end

local function lens(camera, focus, eye, width, narrow)
    camera.CFrame = CFrame.lookAt(eye, focus)
    camera.Focus = CFrame.new(focus)
    camera.FieldOfView = width + (if narrow then 10 else 0)
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
    local playerSpawn = court and court:FindFirstChild("Player Spawn")
    local botSpawn = court and court:FindFirstChild("Bot Spawn")
    if not (playerSpawn and botSpawn) then
        self:_restoreCamera()
        return
    end
    local camera = saved.camera
    local forward, right = playerSpawn.CFrame.LookVector, playerSpawn.CFrame.RightVector
    local up = Vector3.yAxis
    local wideFighters = presentation.wideFighters
    local deckLift = if presentation.deckView then .85 else 0
    local headroom = if wideFighters then .34 else 0
    local closeDistance = if wideFighters then 6.9 else 6.2
    local challenger = playerSpawn.Position + up * (.28 + headroom)
    local resident = botSpawn.Position + up * (2.26 + headroom)
    local middle = challenger:Lerp(resident, .54)
    local narrow = camera.ViewportSize.X < camera.ViewportSize.Y
    if stage == 1 then
        lens(camera, middle, middle + right * (13.5 - math.clamp(age, 0, 2.3) * .65)
            - forward * 5.0 + up * (4.3 + deckLift), if wideFighters then 61 else 58, narrow)
    elseif stage == 2 then
        lens(camera, challenger, challenger + right * (4.5 - (age - 2.3) * .33)
            + forward * closeDistance + up * 1.5, 46, narrow)
    elseif stage == 3 then
        lens(camera, resident, resident + right * (4.8 - (age - 4.8) * .35)
            - forward * closeDistance + up * 1.6, 46, narrow)
    else
        local mix = math.clamp((age - 7) / 3, 0, 1)
        lens(camera, middle:Lerp(challenger, mix * .67),
            middle + right * (10.7 - mix * 7.7) - forward * (6.6 + mix * 9.3) + up * (3.7 + deckLift), 62, narrow)
    end
end

function Intro:_startLive(court, presentation)
    local spawn = court and court:FindFirstChild("Player Spawn")
    local bot = court and court:FindFirstChild(presentation.resident)
    if not spawn or not bot then
        return
    end
    local saved = takeCamera(self.player)
    if not saved then
        return
    end
    self.camera = saved
    local right, forward = spawn.CFrame.RightVector, spawn.CFrame.LookVector
    local headroom = if presentation.wideFighters then .31 else 0
    local depthBias = if presentation.wideFighters then .95 else 0
    local height = if presentation.deckView then 4.05 else 2.7
    local fieldOfView = if presentation.deckView then 57 else 54
    local currentFocus, currentEye
    self.liveRender = RunService.RenderStepped:Connect(function(dt)
        local root, camera = rootOf(self.player), saved.camera
        if not root or not bot.Parent or workspace.CurrentCamera ~= camera
            or camera.CameraType ~= Enum.CameraType.Scriptable
            or UserInputService.VREnabled or GuiService.ReducedMotionEnabled then
            self.liveRender:Disconnect()
            self.liveRender = nil
            self:_restoreCamera()
            return
        end
        local botFloor = bot:GetPivot().Position
        local center = root.Position:Lerp(botFloor + Vector3.new(0, 2.1, 0), .5) + Vector3.yAxis * headroom
        local separation = math.min((root.Position - botFloor).Magnitude, 13)
        local depth = 8.3 + .34 * separation + depthBias
        local eye = center + right * depth - forward * 1.8 + Vector3.yAxis * height
        local alpha = 1 - math.exp(-dt * 10)
        currentFocus = if currentFocus then currentFocus:Lerp(center, alpha) else center
        currentEye = if currentEye then currentEye:Lerp(eye, alpha) else eye
        lens(camera, currentFocus, currentEye, fieldOfView, camera.ViewportSize.X < camera.ViewportSize.Y)
    end)
end

function Intro:Start(introAt, startsAt, court, presentation, onBell)
    self:Stop()
    local now = workspace:GetServerTimeNow()
    if now >= startsAt then
        self:_startLive(court, presentation)
        onBell()
        return
    end
    self.camera = takeCamera(self.player)
    self.card.Visible = true
    self.locked = true
    ContextActionService:BindActionAtPriority(movementAction, function()
        return Enum.ContextActionResult.Sink
    end, false, Enum.ContextActionPriority.High.Value, table.unpack(Enum.PlayerActions:GetEnumItems()))
    local previousStage, finished = nil, false
    local function render()
        local remaining = startsAt - workspace:GetServerTimeNow()
        if remaining <= 0 then
            if not finished then
                finished = true
                self:_release()
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
        local age = math.max(0, startsAt - introAt - remaining)
        local stage = if age < 2.3 then 1 elseif age < 4.8 then 2 elseif remaining > 3 then 3 else 4
        if stage ~= previousStage then
            previousStage = stage
            self.small.Text = if stage == 2 then "CHALLENGER" elseif stage == 3 then "RESIDENT" else "BOT SPAR"
            self.title.Text = if stage == 1 then presentation.ring elseif stage == 2 then presentation.challenger
                elseif stage == 3 then presentation.resident
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
        self:_shot(court, stage, age, presentation)
    end
    render()
    self.render = RunService.RenderStepped:Connect(render)
end

return Intro
