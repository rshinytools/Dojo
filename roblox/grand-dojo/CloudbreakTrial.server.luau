local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local city = workspace:WaitForChild("Grand Dojo City")
local skywalk = city:WaitForChild("Connected districts"):WaitForChild("Skywalk Peaks")
local course = skywalk:WaitForChild("Cloudbreak Wind Trial")
local startMarker = course:WaitForChild("Start")
local startDeck = course:WaitForChild("Cloudbreak start deck")
local platformFolder = course:WaitForChild("Platforms")
local noticeRemote = ReplicatedStorage:WaitForChild("GrandDojoAction")

local LANDING_COUNT = 24
local STAGE_ENDS = {[3] = 1, [6] = 2, [12] = 3, [17] = 4, [22] = 5, [24] = 6}
local RECOVERY_AT = {[6] = 1, [17] = 2}
local SAMPLE_INTERVAL = 1 / 30
local ACTION_COOLDOWN = .65
local MAX_INACTIVITY = 150
local MIN_EXPERT_TIME = 8
local HORIZONTAL_RATE = 28
local REPLICATION_ALLOWANCE = 4.8
local MASTERY_ID = "mastery-sky"
local MOVE_AMPLITUDE = 1.05
local MOVE_FREQUENCY = 2 * math.pi / 5.2

local function arcDistance(a, b)
    return Vector2.new(a.X - b.X, a.Z - b.Z).Magnitude
end

local function platformTop(platform)
    return platform.Position + Vector3.new(0, platform.Size.Y / 2, 0)
end

local platforms = table.create(LANDING_COUNT)
local standingRays = table.create(LANDING_COUNT)
local firstPoint = startMarker.Position
local minX, maxX, minZ, maxZ = firstPoint.X, firstPoint.X, firstPoint.Z, firstPoint.Z
for index = 1, LANDING_COUNT do
    local platform = platformFolder:WaitForChild(string.format("%02d", index))
    assert(platform:IsA("BasePart") and platform.Anchored and platform.CanCollide and platform.CanQuery,
        string.format("Cloudbreak landing %02d needs a walkable, queryable platform", index))
    platforms[index] = platform
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Include
    ray.FilterDescendantsInstances = {platform}
    standingRays[index] = ray
    local p = platform.Position
    minX, maxX = math.min(minX, p.X), math.max(maxX, p.X)
    minZ, maxZ = math.min(minZ, p.Z), math.max(maxZ, p.Z)
end

local function getPrompt(name)
    return course:WaitForChild(name .. " Anchor"):WaitForChild(name)
end

local practicePrompt = getPrompt("PracticePrompt")
local expertPrompt = getPrompt("ExpertPrompt")
local bellPrompt = getPrompt("BellPrompt")
local bellSound = bellPrompt.Parent:FindFirstChildOfClass("Sound")
local returnPrompt = getPrompt("ReturnPrompt")
local runs = {}
local lastAction = {}

local function notice(player, message)
    noticeRemote:FireClient(player, "notice", message)
end

local function livingCharacter(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
        return root, humanoid
    end
    return nil, nil
end

local function hasConflictingActivity(player)
    return (player:GetAttribute("RelayNextGate") or 0) > 0 or player:GetAttribute("SparringActive") == true
        or player:GetAttribute("FighterSelectOpen") == true or player:GetAttribute("StarterSelectionPending") == true
        or player:GetAttribute("DuelQueued") == true or player:GetAttribute("RingTrainingActive") ~= nil
        or player:GetAttribute("RingTrainingPending") == true
end

local function nearPrompt(root, prompt)
    return prompt.Enabled and (root.Position - prompt.Parent.Position).Magnitude <= prompt.MaxActivationDistance + .55
end

local function allowedAction(player, now)
    return now - (lastAction[player] or -math.huge) >= ACTION_COOLDOWN
end

local function clearRun(player)
    local run = runs[player]
    if run then
        run.deathConnection:Disconnect()
        runs[player] = nil
    end
    player:SetAttribute("SkywalkTrialMode", nil)
    player:SetAttribute("SkywalkTrialNext", nil)
    player:SetAttribute("SkywalkTrialStartedAt", nil)
    player:SetAttribute("SkywalkTrialRecoveries", nil)
end

local function placeOnLanding(root, position)
    root.CFrame = CFrame.new(position + Vector3.new(0, 3.15, 0)) * root.CFrame.Rotation
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function beginRun(player, prompt, mode)
    local root, humanoid = livingCharacter(player)
    local now = workspace:GetServerTimeNow()
    if not root or not humanoid or not nearPrompt(root, prompt) or not allowedAction(player, now) then
        return
    end
    if hasConflictingActivity(player) then
        notice(player, "Finish your current activity before starting Cloudbreak.")
        return
    end
    lastAction[player] = now
    clearRun(player)
    placeOnLanding(root, firstPoint)
    local run = {
        root = root,
        mode = mode,
        nextPad = 1,
        recovery = 0,
        started = nil,
        previousPosition = root.Position,
        sampledAt = now,
        activeAt = now,
        movementAllowance = REPLICATION_ALLOWANCE,
    }
    run.deathConnection = humanoid.Died:Connect(function()
        if runs[player] == run then
            clearRun(player)
        end
    end)
    runs[player] = run
    player:SetAttribute("SkywalkTrialNext", 0)
    player:SetAttribute("SkywalkTrialStartedAt", 0)
    player:SetAttribute("SkywalkTrialRecoveries", 0)
    player:SetAttribute("SkywalkTrialMode", mode)
    notice(player, if mode == "practice" then "Practice started. Land on every stone in order, then ring the summit bell."
        else "Expert ready. The clock starts when you leave the staging platform.")
end

practicePrompt.Triggered:Connect(function(player)
    beginRun(player, practicePrompt, "practice")
end)
expertPrompt.Triggered:Connect(function(player)
    beginRun(player, expertPrompt, "expert")
end)

local function standingOn(root, humanoid, index)
    local heightAbove = root.Position.Y - platformTop(platforms[index]).Y
    if heightAbove < .6 or heightAbove > 4.1 or humanoid.FloorMaterial == Enum.Material.Air then
        return false
    end
    local hit = workspace:Raycast(root.Position, Vector3.new(0, -4.2, 0), standingRays[index])
    return hit ~= nil and hit.Instance == platforms[index]
end

local function recover(player, run, now)
    local recovery = run.recovery
    local point = if recovery == 0 then firstPoint else platformTop(platforms[recovery])
    placeOnLanding(run.root, point)
    run.nextPad = recovery + 1
    run.previousPosition = run.root.Position
    run.sampledAt = now
    run.activeAt = now
    run.movementAllowance = REPLICATION_ALLOWANCE
    player:SetAttribute("SkywalkTrialNext", STAGE_ENDS[recovery] or 0)
    notice(player, if recovery == 0 then "Back at the staging platform." else "Back at your last recovery shrine.")
end

local function leftStagingDeck(position)
    local offset = startDeck.CFrame:PointToObjectSpace(position)
    return math.abs(offset.X) > startDeck.Size.X / 2 + .12
        or math.abs(offset.Z) > startDeck.Size.Z / 2 + .12
        or position.Y > firstPoint.Y + 4.5
end

local function advance(player, run, now)
    local root, humanoid = livingCharacter(player)
    if root ~= run.root or not humanoid then
        clearRun(player)
        return
    end
    if hasConflictingActivity(player) then
        clearRun(player)
        notice(player, "Cloudbreak ended when you started another activity.")
        return
    end

    local position = root.Position
    if not (math.abs(position.X) < math.huge and math.abs(position.Y) < math.huge and math.abs(position.Z) < math.huge) then
        clearRun(player)
        return
    end
    local hop = arcDistance(position, run.previousPosition)
    local rise = position.Y - run.previousPosition.Y
    local stepTime = math.max(now - run.sampledAt, 0)
    local allowance = run.movementAllowance + stepTime * HORIZONTAL_RATE - hop
    if allowance < 0 or rise > 3.4 + stepTime * 68 then
        clearRun(player)
        notice(player, "Cloudbreak lost track of your landing. Start again at the staging platform.")
        return
    end
    run.movementAllowance = math.min(REPLICATION_ALLOWANCE, allowance)
    if hop > .095 or math.abs(rise) > .13 then
        run.activeAt = now
    end
    run.previousPosition = position
    run.sampledAt = now

    local previousFloor = if run.nextPad == 1 then firstPoint.Y else platformTop(platforms[run.nextPad - 1]).Y
    if position.Y < previousFloor - 5 then
        recover(player, run, now)
        return
    end
    local outside = position.X < minX - 11 or position.X > maxX + 11
        or position.Z < minZ - 11 or position.Z > maxZ + 11
    if outside then
        clearRun(player)
        notice(player, "You left the Cloudbreak route.")
        return
    end
    if now - run.activeAt > MAX_INACTIVITY then
        clearRun(player)
        return
    end
    if run.mode == "expert" and not run.started and leftStagingDeck(position) then
        run.started = now
        player:SetAttribute("SkywalkTrialStartedAt", now)
    end
    if run.nextPad > LANDING_COUNT or not standingOn(root, humanoid, run.nextPad) then
        return
    end

    local index = run.nextPad
    run.nextPad += 1
    run.activeAt = now
    local stage = STAGE_ENDS[index]
    if stage then
        player:SetAttribute("SkywalkTrialNext", stage)
    end
    if RECOVERY_AT[index] then
        run.recovery = index
        player:SetAttribute("SkywalkTrialRecoveries", RECOVERY_AT[index])
        notice(player, string.format("Recovery shrine %d of 2 reached.", RECOVERY_AT[index]))
    elseif index == LANDING_COUNT then
        notice(player, "All six stages cleared. Ring the summit bell to finish.")
    end
end

bellPrompt.Triggered:Connect(function(player)
    local root, humanoid = livingCharacter(player)
    local run = runs[player]
    local now = workspace:GetServerTimeNow()
    if not root or not humanoid or not run or root ~= run.root or not nearPrompt(root, bellPrompt)
        or not allowedAction(player, now) or hasConflictingActivity(player) then
        return
    end
    lastAction[player] = now
    if run.nextPad <= LANDING_COUNT or not standingOn(root, humanoid, LANDING_COUNT) then
        notice(player, "Land on every stone in order before ringing the bell.")
        return
    end
    clearRun(player)
    if run.mode == "practice" then
        if bellSound then
            bellSound:Play()
        end
        notice(player, "Practice clear. Try Expert for the timed climb.")
        return
    end
    if not run.started or now - run.started < MIN_EXPERT_TIME then
        notice(player, "That run could not be verified. Start another attempt.")
        return
    end
    if bellSound then
        bellSound:Play()
    end
    local seconds = math.round((now - run.started) * 10) / 10
    local best = player:GetAttribute("SkywalkExpertBest")
    if not best or seconds < best then
        player:SetAttribute("SkywalkExpertBest", seconds)
    end
    if player:GetAttribute("SkywalkExpertEarned") ~= true then
        player:SetAttribute("SkywalkExpertEarned", true)
        player:SetAttribute("SkywalkExpertRewardId", MASTERY_ID)
        notice(player, string.format("Skywalk Peaks Master earned this session · %.1fs", seconds))
    else
        notice(player, string.format("Cloudbreak Expert clear · %.1fs", seconds))
    end
end)

returnPrompt.Triggered:Connect(function(player)
    local root = livingCharacter(player)
    local now = workspace:GetServerTimeNow()
    if not root or not nearPrompt(root, returnPrompt) or not allowedAction(player, now)
        or hasConflictingActivity(player) then
        return
    end
    lastAction[player] = now
    clearRun(player)
    placeOnLanding(root, firstPoint)
    notice(player, "Back at Cloudbreak staging.")
end)

local movingPlatform = platforms[4]
local movingOrigin = movingPlatform.CFrame
local motionStarted = workspace:GetServerTimeNow()
RunService.PreSimulation:Connect(function()
    local phase = (workspace:GetServerTimeNow() - motionStarted) * MOVE_FREQUENCY
    local offset = MOVE_AMPLITUDE * math.sin(phase)
    local speed = MOVE_AMPLITUDE * MOVE_FREQUENCY * math.cos(phase)
    movingPlatform.CFrame = movingOrigin + Vector3.new(0, 0, offset)
    -- The anchored deck moves on the server. Its surface velocity helps a
    -- grounded character travel with it instead of sliding off the platform.
    movingPlatform.AssemblyLinearVelocity = Vector3.new(0, 0, speed)
end)

local timeSinceSample = 0
RunService.Heartbeat:Connect(function(elapsed)
    if next(runs) == nil then
        timeSinceSample = 0
        return
    end
    timeSinceSample += elapsed
    if timeSinceSample < SAMPLE_INTERVAL then
        return
    end
    timeSinceSample = 0
    local now = workspace:GetServerTimeNow()
    for player, run in runs do
        advance(player, run, now)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    clearRun(player)
    lastAction[player] = nil
end)
