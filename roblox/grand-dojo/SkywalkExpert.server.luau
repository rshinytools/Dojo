local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local city = workspace:WaitForChild("Grand Dojo City")
local skywalk = city:WaitForChild("Connected districts"):WaitForChild("Skywalk Peaks")
local course = skywalk:WaitForChild("Skywalk Expert Course", 10)
if not course then
    return
end

local noticeRemote = ReplicatedStorage:WaitForChild("GrandDojoAction")
local startMarker = course:WaitForChild("Start")
local markers = course:WaitForChild("Checkpoints")
local recoveryStations = course:WaitForChild("Recovery Stations")
local positions = { startMarker.Position }
for index = 1, #markers:GetChildren() do
    table.insert(positions, markers:WaitForChild(tostring(index)).Position)
end

local PRACTICE_SECONDS = 150
local EXPERT_SECONDS = 24
local CHECKPOINT_RADIUS = 1.94
local SAMPLE_INTERVAL = 0.10
local MIN_EXPERT_SECONDS = 4.2
local RESTART_LOCKOUT = .65
local MASTERY_ID = "mastery-sky"
local runs = {}
local lastAction = {}

local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
for _, position in positions do
    minX, maxX = math.min(minX, position.X), math.max(maxX, position.X)
    minZ, maxZ = math.min(minZ, position.Z), math.max(maxZ, position.Z)
end

local function livingRoot(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
        return root
    end
    return nil
end

local function notice(player, message)
    noticeRemote:FireClient(player, "notice", message)
end

local function clearRun(player)
    runs[player] = nil
    player:SetAttribute("SkywalkTrialMode", nil)
    player:SetAttribute("SkywalkTrialNext", nil)
    player:SetAttribute("SkywalkTrialDeadline", nil)
end

local function placeOnLanding(root, landing)
    root.CFrame = CFrame.new(landing + Vector3.new(0, 3, 0)) * root.CFrame.Rotation
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function nearPrompt(root, prompt)
    return (root.Position - prompt.Parent.Position).Magnitude <= prompt.MaxActivationDistance + .55
end

local function start(player, prompt, practice)
    local root = livingRoot(player)
    local now = workspace:GetServerTimeNow()
    if not root or not nearPrompt(root, prompt)
        or now - (lastAction[player] or -math.huge) < RESTART_LOCKOUT then
        return
    end
    if (player:GetAttribute("RelayNextGate") or 0) > 0 or player:GetAttribute("SparringActive") then
        notice(player, "Finish your current activity before starting the Wind-bridge trial.")
        return
    end
    lastAction[player] = now
    placeOnLanding(root, positions[1])
    local deadline = now + (if practice then PRACTICE_SECONDS else EXPERT_SECONDS)
    runs[player] = {
        root = root,
        practice = practice,
        started = now,
        due = deadline,
        next = 2,
        lastPosition = root.Position,
        lastSample = now,
        lastCheckpoint = now,
    }
    player:SetAttribute("SkywalkTrialNext", 1)
    player:SetAttribute("SkywalkTrialDeadline", deadline)
    player:SetAttribute("SkywalkTrialMode", if practice then "practice" else "expert")
    notice(player, if practice then "Practice started. Falls return you to the last marker."
        else "Expert started. Reach all six markers and the far landing in 24 seconds.")
end

local function bindStart(name, practice)
    local anchor = course:WaitForChild(name .. " Anchor")
    local prompt = anchor:WaitForChild(name)
    prompt.Triggered:Connect(function(player)
        start(player, prompt, practice)
    end)
end

bindStart("PracticePrompt", true)
bindStart("ExpertPrompt", false)

for _, anchor in recoveryStations:GetChildren() do
    local prompt = anchor:WaitForChild("RecoveryPrompt")
    prompt.Triggered:Connect(function(player)
        local root = livingRoot(player)
        local now = workspace:GetServerTimeNow()
        if not root or not nearPrompt(root, prompt)
            or now - (lastAction[player] or -math.huge) < RESTART_LOCKOUT then
            return
        end
        lastAction[player] = now
        clearRun(player)
        placeOnLanding(root, positions[1])
        notice(player, "Back at the Wind-bridge start.")
    end)
end

local function finish(player, run, now)
    clearRun(player)
    if run.practice then
        notice(player, "Practice clear. Try Expert for the timed challenge.")
        return
    end
    local elapsed = now - run.started
    if elapsed < MIN_EXPERT_SECONDS then
        notice(player, "That run could not be verified. Start another attempt at the trial board.")
        return
    end

    local seconds = math.round(elapsed * 10) / 10
    local best = player:GetAttribute("SkywalkExpertBest")
    if not best or seconds < best then
        player:SetAttribute("SkywalkExpertBest", seconds)
    end
    local firstClear = player:GetAttribute("SkywalkExpertEarned") ~= true
    if firstClear then
        player:SetAttribute("SkywalkExpertEarned", true)
        player:SetAttribute("SkywalkExpertRewardId", MASTERY_ID)
        notice(player, string.format("Skywalk Peaks Master earned this session · %.1fs", seconds))
    else
        notice(player, string.format("Wind-bridge expert clear · %.1fs", seconds))
    end
end

local function floorOnLeg(position, origin, goal)
    local direction = Vector2.new(goal.X - origin.X, goal.Z - origin.Z)
    local offset = Vector2.new(position.X - origin.X, position.Z - origin.Z)
    local fraction = math.clamp(offset:Dot(direction) / direction:Dot(direction), 0, 1)
    return origin.Y + (goal.Y - origin.Y) * fraction
end

local function advance(player, run, now)
    local root = livingRoot(player)
    if root ~= run.root then
        clearRun(player)
        return
    end
    local position = root.Position
    if position.X < minX - 11 or position.X > maxX + 11
        or position.Z < minZ - 11 or position.Z > maxZ + 11 then
        clearRun(player)
        notice(player, "You left the Wind-bridge trial.")
        return
    end

    if now > run.due then
        clearRun(player)
        placeOnLanding(root, positions[1])
        notice(player, if run.practice then "Practice timed out. Start again when ready."
            else "Time ran out. Try Expert again from the start.")
        return
    end

    local previous = positions[run.next - 1]
    local expected = positions[run.next]
    if position.Y < floorOnLeg(position, previous, expected) - .46 then
        if run.practice then
            placeOnLanding(root, previous)
            run.lastPosition = root.Position
            run.lastSample = now
            run.lastCheckpoint = now
            notice(player, "Back at the last practice marker.")
        else
            clearRun(player)
            placeOnLanding(root, positions[1])
            notice(player, "The catch net is below you. Try Expert again from the start.")
        end
        return
    end

    local motion = position - run.lastPosition
    local hop = Vector2.new(motion.X, motion.Z).Magnitude
    if hop > 8 + math.max(0, now - run.lastSample) * 25 then
        clearRun(player)
        notice(player, "The trial lost track of your position. Start another attempt at the board.")
        return
    end
    run.lastPosition = position
    run.lastSample = now

    local delta = position - expected
    if Vector2.new(delta.X, delta.Z).Magnitude > CHECKPOINT_RADIUS
        or delta.Y < .68 or delta.Y > 3.96 then
        return
    end
    local legLength = Vector2.new(expected.X - previous.X, expected.Z - previous.Z).Magnitude
    if now - run.lastCheckpoint < math.max(0, legLength - 4.1) / 38 then
        clearRun(player)
        notice(player, "That checkpoint crossing could not be verified. Try another run.")
        return
    end

    if run.next == #positions then
        finish(player, run, now)
        return
    end

    run.lastCheckpoint = now
    run.next += 1
    player:SetAttribute("SkywalkTrialNext", run.next - 1)
    local checkpoint = run.next - 2
    local total = #positions - 2
    if run.practice then
        notice(player, string.format("Practice marker %d of %d", checkpoint, total))
    else
        notice(player, string.format("Marker %d of %d · %.0fs left", checkpoint, total, run.due - now))
    end
end

local sampleElapsed = 0
RunService.Heartbeat:Connect(function(elapsed)
    sampleElapsed += elapsed
    if sampleElapsed < SAMPLE_INTERVAL or next(runs) == nil then
        return
    end
    sampleElapsed = 0
    local now = workspace:GetServerTimeNow()
    for player, run in runs do
        advance(player, run, now)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    clearRun(player)
    lastAction[player] = nil
end)
