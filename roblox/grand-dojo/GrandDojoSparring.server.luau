local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Round = require(script.Parent:WaitForChild("SparringRound"))
local sparringWon = script.Parent:WaitForChild("SparringWon")

local ring = workspace:WaitForChild("Grand Dojo City"):WaitForChild("Fighting Ring")
local corner = ring:WaitForChild("Bot Spar Corner")
local bounds = corner:WaitForChild("Sparring Bounds")
local gate = corner:WaitForChild("Sparring Gate")
local template = ServerStorage:WaitForChild("Juniper Tortoise")
local remote = ReplicatedStorage:WaitForChild("GrandDojoSparring")
local floor = bounds.Position.Y - bounds.Size.Y / 2
local active
local retryUntil = {}
local lastAction = {}

local function flat(vector)
    return Vector3.new(vector.X, 0, vector.Z)
end

local function inCorner(position)
    local offset = position - bounds.Position
    return math.abs(offset.X) <= bounds.Size.X / 2 and math.abs(offset.Z) <= bounds.Size.Z / 2
        and offset.Y >= -2 and offset.Y <= 7
end

local function livingRoot(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart") or nil
end

local function publish(bout, kind, now)
    local round = bout.round
    remote:FireClient(bout.player, kind, round.playerHealth, round.botHealth, round.startsAt, round.endsAt,
        round.botPhase, if now < bout.messageUntil then bout.message else nil, round.botAt, Round.parryOpensAt(round))
end

local function shoulderPose(bout, action)
    local guard = action == "guard"
    for _, arm in bout.arms do
        if guard or arm.right then
            if arm.tween then
                arm.tween:Cancel()
            end
            local angle = if guard then -22 else -57
            local forward = if guard then -.10 else -.46
            arm.tween = TweenService:Create(arm.motor, TweenInfo.new(.09), {
                C0 = CFrame.new(0, 0, forward) * arm.rest * CFrame.Angles(math.rad(angle), 0, 0),
            })
            local pose = arm.tween
            pose:Play()
            task.delay(if guard then .52 else .15, function()
                if arm.tween == pose and arm.motor.Parent then
                    arm.tween = TweenService:Create(arm.motor, TweenInfo.new(.17), {C0 = arm.rest})
                    arm.tween:Play()
                end
            end)
        end
    end
end

local function finish(bout, result, now, disconnected)
    active = nil
    bout.bot:Destroy()
    for _, arm in bout.arms do
        if arm.tween then
            arm.tween:Cancel()
            arm.tween = nil
            if arm.motor.Parent then
                arm.motor.C0 = arm.rest
            end
        end
    end
    local player = bout.player
    player:SetAttribute("SparringActive", nil)
    if disconnected then
        return
    end
    local wins = player:GetAttribute("SparringWins") or 0
    local eligibleWin = result == "win" and player:GetAttribute("FirstSparWinComplete") ~= true
        and player:GetAttribute("FirstSparWinPending") ~= true
    if result == "win" then
        wins += 1
        player:SetAttribute("SparringWins", wins)
    end
    retryUntil[player] = now + 25
    remote:FireClient(player, "result", result, wins, eligibleWin)
    if eligibleWin then
        sparringWon:Fire(player)
    end
end

local function begin(player, now, retrying)
    local root = livingRoot(player)
    local nearGate = root and (root.Position - gate.Position).Magnitude <= gate.SparPrompt.MaxActivationDistance + .5
    if not root or not (nearGate or (retrying and inCorner(root.Position))) then
        if retrying then
            remote:FireClient(player, "notice", "Return to the Bot Spar sign to try again.")
        end
        return
    end
    if active then
        if active.player ~= player then
            remote:FireClient(player, "notice", "A spar is underway. This corner opens when the round ends.")
        end
        return
    end
    if (player:GetAttribute("RelayNextGate") or 0) > 0 then
        remote:FireClient(player, "notice", "Finish or leave the Lantern Relay before sparring.")
        return
    end
    retryUntil[player] = nil
    local bot = template:Clone()
    local cue = Instance.new("Highlight")
    cue.Name = "Guard cue"
    cue.DepthMode = Enum.HighlightDepthMode.Occluded
    cue.FillTransparency = .88
    cue.Enabled = false
    cue.Parent = bot
    bot.Parent = corner
    active = {
        player = player, root = root, bot = bot, cue = cue, round = Round.new(now),
        paw = bot["Right Paw"], shoulder = bot["Right Sleeve"],
        messageUntil = 0, lastPublish = now, arms = {},
    }
    local torso = player.Character:FindFirstChild("Torso")
    if torso then
        for _, name in {"Right Shoulder", "Left Shoulder"} do
            local motor = torso:FindFirstChild(name)
            if motor and motor:IsA("Motor6D") then
                table.insert(active.arms, {motor = motor, rest = motor.C0, right = name == "Right Shoulder"})
            end
        end
    end
    active.pawRest = bot:GetPivot():ToObjectSpace(active.paw.CFrame)
    active.shoulderRest = bot:GetPivot():ToObjectSpace(active.shoulder.CFrame)
    player:SetAttribute("SparringActive", true)
    publish(active, "begin", now)
end

local function measure(bout)
    local delta = flat(bout.bot:GetPivot().Position - bout.root.Position)
    local distance = delta.Magnitude
    local facing = distance < .01 or bout.root.CFrame.LookVector:Dot(delta.Unit) >= .12
    local onMat = inCorner(bout.root.Position) and math.abs(bout.root.Position.Y - floor - 3) <= 2.7
    return if onMat then distance else math.huge, facing
end

local function moveBot(bout, now, dt)
    local round = bout.round
    local position = bout.bot:GetPivot().Position
    local toward = flat(bout.root.Position - position)
    local distance = toward.Magnitude
    if distance < .01 then
        return
    end
    local direction = toward.Unit
    if now >= round.startsAt and round.botPhase == "ready" and inCorner(bout.root.Position) and distance > 4.4 then
        position += direction * math.min(dt * 7.2, distance - 4.4)
        local center, half = bounds.Position, bounds.Size / 2
        position = Vector3.new(math.clamp(position.X, center.X - half.X + 1, center.X + half.X - 1),
            floor, math.clamp(position.Z, center.Z - half.Z + 1, center.Z + half.Z - 1))
    end
    local pivot = CFrame.lookAt(position, position + direction)
    local reach = 0
    if round.botPhase == "windup" then
        reach = -.30 * (1 - math.clamp((round.botAt - now) / Round.WINDUP, 0, 1))
    elseif round.botPhase == "recovery" then
        reach = 1.28 * math.clamp(1 - (now - round.recoveryStartedAt) / .30, 0, 1)
    end
    bout.bot:PivotTo(pivot)
    bout.paw.CFrame = pivot * CFrame.new(0, 0, -reach) * bout.pawRest
    bout.shoulder.CFrame = pivot * CFrame.new(0, 0, -.45 * reach) * bout.shoulderRest
end

gate.SparPrompt.Triggered:Connect(function(player)
    begin(player, workspace:GetServerTimeNow(), false)
end)

remote.OnServerEvent:Connect(function(player, action)
    if type(action) ~= "string" then
        return
    end
    local now = workspace:GetServerTimeNow()
    if now - (lastAction[player] or -math.huge) < .09 then
        return
    end
    lastAction[player] = now
    if action == "retry" then
        if now < (retryUntil[player] or 0) then
            begin(player, now, true)
        else
            remote:FireClient(player, "notice", "Use the Bot Spar sign to start a new round.")
        end
        return
    end
    local bout = active
    if not bout or bout.player ~= player then
        return
    end
    if action == "leave" then
        finish(bout, "left", now)
    elseif (action == "strike" or action == "guard") and livingRoot(player) == bout.root and inCorner(bout.root.Position) then
        local distance, facing = measure(bout)
        local feedback = Round.act(bout.round, action, now, distance, facing)
        if feedback then
            shoulderPose(bout, action)
            bout.message, bout.messageUntil = feedback, now + .7
        end
        if bout.round.result then
            finish(bout, bout.round.result, now)
        end
    end
end)

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    local bout = active
    if not bout then
        elapsed = 0
        return
    end
    elapsed += dt
    if elapsed < .05 then
        return
    end
    local step = math.min(elapsed, .15)
    elapsed = 0
    local now = workspace:GetServerTimeNow()
    if livingRoot(bout.player) ~= bout.root then
        finish(bout, "left", now)
        return
    end
    if inCorner(bout.root.Position) then
        bout.outsideSince = nil
    elseif now >= bout.round.startsAt then
        bout.outsideSince = bout.outsideSince or now
        if now - bout.outsideSince > 1.6 then
            finish(bout, "outside", now)
            return
        end
    end
    local distance, facing = measure(bout)
    local feedback = Round.step(bout.round, now, distance, facing)
    if bout.round.result then
        finish(bout, bout.round.result, now)
        return
    end
    if feedback then
        bout.message, bout.messageUntil = feedback, now + .85
    end
    moveBot(bout, now, step)
    local round = bout.round
    local phase = round.botPhase
    local opensAt = Round.parryOpensAt(round)
    local parryCue = opensAt ~= nil and now >= opensAt and now <= round.botAt
    local cueStarted = parryCue and not bout.parryCue
    bout.parryCue = parryCue
    bout.cue.Enabled = phase ~= "ready"
    local tint = if parryCue then Color3.fromRGB(148, 223, 233)
        elseif phase == "windup" then Color3.fromRGB(255, 192, 94) else Color3.fromRGB(129, 226, 188)
    bout.cue.FillColor, bout.cue.OutlineColor = tint, tint
    if cueStarted or feedback == "parried" or now - bout.lastPublish >= .13 then
        publish(bout, "state", now)
        bout.lastPublish = now
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if active and active.player == player then
        finish(active, "left", 0, true)
    end
    retryUntil[player], lastAction[player] = nil, nil
end)
