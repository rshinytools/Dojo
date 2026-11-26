local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rules = require(ReplicatedStorage:WaitForChild("RingProgression"))
local starterCatalog = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog"))
local actionRemote = ReplicatedStorage:WaitForChild("GrandDojoAction")
local completed = script.Parent:WaitForChild("RingTrainingCompleted")
local stations = workspace:WaitForChild("Grand Dojo City"):WaitForChild("Ring Training")

local active = {}
local cooldowns = {}
local lastNotice = {}

local function notice(player, message)
    local now = os.clock()
    if now - (lastNotice[player] or -math.huge) >= .28 then
        lastNotice[player] = now
        actionRemote:FireClient(player, "notice", message)
    end
end

local function playerRoot(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart")
end

local function isNear(root, anchor, prompt)
    return root and prompt.Enabled and (root.Position - anchor.Position).Magnitude <= prompt.MaxActivationDistance + .4
end

local function clear(player)
    active[player] = nil
    player:SetAttribute("RingTrainingActive", nil)
end

local function incompatible(player)
    return player:GetAttribute("StarterSelectionRequired") ~= false
        or player:GetAttribute("FighterSelectOpen")
        or player:GetAttribute("StarterSelectionPending")
        or player:GetAttribute("SparringActive")
        or player:GetAttribute("DuelQueued")
        or player:GetAttribute("DuelTransferHold")
        or player:GetAttribute("SkywalkTrialMode")
        or player:GetAttribute("CityAdventureActive")
        or (player:GetAttribute("RelayNextGate") or 0) > 0
end

local function cue(player, trial)
    notice(player, "Next: " .. rules.Drills[trial.id].cues[trial.index])
end

local function begin(player, drillId, anchor, prompt)
    local root = playerRoot(player)
    if not isNear(root, anchor, prompt) then
        return
    end
    if incompatible(player) then
        notice(player, "Finish your current activity before starting a training drill.")
        return
    end
    local status = player:GetAttribute("ProgressStatus")
    if (status ~= "ready" and status ~= "saved") or player:GetAttribute("RingTrainingPending") then
        notice(player, "Your progress is still saving. Try the drill again when it is ready.")
        return
    end
    local fighterId = player:GetAttribute("SelectedStarterFighter")
    if type(fighterId) ~= "string" or not starterCatalog.ById[fighterId] then
        return
    end
    local now = os.clock()
    local activeDrill = active[player]
    if activeDrill and activeDrill.root == root and activeDrill.expiresAt > now
        and (root.Position - activeDrill.start.Position).Magnitude <= 29 then
        cue(player, activeDrill)
        return
    end
    local key = fighterId .. "/" .. drillId
    local readyAt = cooldowns[player] and cooldowns[player][key] or 0
    if now < readyAt then
        notice(player, string.format("Drill ready again in %ds. Try another activity in the meantime.", math.ceil(readyAt - now)))
        return
    end
    local trial = rules.beginDrill(drillId, now)
    trial.root, trial.start, trial.fighterId, trial.key = root, anchor, fighterId, key
    active[player] = trial
    player:SetAttribute("RingTrainingActive", drillId)
    cue(player, trial)
end

local function hit(player, drillId, index, anchor, prompt)
    local root = playerRoot(player)
    if not isNear(root, anchor, prompt) then
        return
    end
    local drill = active[player]
    if not drill or drill.id ~= drillId or drill.root ~= root then
        notice(player, "Start the drill at the training sign.")
        return
    end
    if incompatible(player) or player:GetAttribute("SelectedStarterFighter") ~= drill.fighterId then
        clear(player)
        return
    end
    local now = os.clock()
    local result = rules.drillCue(drill, index, now)
    if result == "finished" then
        cooldowns[player] = cooldowns[player] or {}
        cooldowns[player][drill.key] = now + rules.DrillCooldown
        player:SetAttribute("RingTrainingPending", true)
        clear(player)
        completed:Fire(player, drillId, drill.fighterId)
    elseif result == "expired" then
        clear(player)
        notice(player, "Time expired. Start another attempt at the training sign.")
    elseif result == "early" then
        notice(player, "Wait a moment, then try this cue again.")
    else
        cue(player, drill)
    end
end

for _, id in rules.DrillOrder do
    local station = stations:WaitForChild(id)
    local start = station:WaitForChild("Start")
    local startPrompt = start:WaitForChild("TrainingPrompt")
    startPrompt.Triggered:Connect(function(player)
        begin(player, id, start, startPrompt)
    end)
    for index, cueName in rules.Drills[id].cues do
        local anchor = station:WaitForChild(tostring(index))
        local prompt = anchor:WaitForChild("TrainingPrompt")
        prompt.ObjectText = string.format("%d  %s", index, cueName)
        prompt:SetAttribute("RingTrainingCueId", id)
        CollectionService:AddTag(prompt, "RingTrainingCuePrompt")
        prompt.Triggered:Connect(function(player)
            hit(player, id, index, anchor, prompt)
        end)
    end
end

task.spawn(function()
    while true do
        task.wait(.65)
        local now = os.clock()
        for player, drill in active do
            local root = playerRoot(player)
            if not root or root ~= drill.root then
                clear(player)
            elseif incompatible(player) or (root.Position - drill.start.Position).Magnitude > 29 then
                clear(player)
                notice(player, "Training drill ended. Return to the sign to try again.")
            elseif now >= drill.expiresAt then
                clear(player)
                notice(player, "Time expired. Start another attempt at the training sign.")
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    active[player], cooldowns[player], lastNotice[player] = nil, nil, nil
end)
