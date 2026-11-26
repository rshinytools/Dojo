local Players = game:GetService("Players")

local spawn = workspace:WaitForChild("Grand Dojo Spawn")
local SAMPLE_PERIOD = .25
local VOID_Y = -18
local states = {}
local activityAttributes = {
    "SparringActive", "DuelActive", "BrawlActive", "TagTeamActive", "KilnbackRaidActive",
    "SkywalkTrialMode", "CityAdventureActive", "RingTrainingActive", "DuelTransferHold",
    "StarterSelectionPending", "StarterSelectionRequired",
}

local function inActivity(player)
    for _, attribute in activityAttributes do
        if player:GetAttribute(attribute) then return true end
    end
    return (player:GetAttribute("RelayDeadline") or 0) > 0
        or (player:GetAttribute("ParcelStage") or 0) > 0
end

local function findGround(position, params, drop)
    local hit = workspace:Raycast(position, Vector3.new(0, -drop, 0), params)
    return if hit and hit.Normal.Y >= .64 and hit.Instance.Anchored then hit else nil
end

local function placeOnGround(character, root, target)
    character:PivotTo(target * root.CFrame:ToObjectSpace(character:GetPivot()))
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function climbOut(player, anchor, prompt)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not (humanoid and root and humanoid.Health > 0 and not root.Anchored) or inActivity(player) then return end
    local position = root.Position
    if position.Y > 1.1 or (position - anchor.Position).Magnitude > prompt.MaxActivationDistance + .3 then return end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.IgnoreWater = true
    params.RespectCanCollide = true
    local ground = findGround(anchor.Position + Vector3.new(6, 4, 0), params, 4.1)
    if not ground then return end
    local height = math.max(2.8, humanoid.HipHeight + root.Size.Y / 2)
    local target = ground.Position + Vector3.new(0, height, 0)
    placeOnGround(character, root, CFrame.lookAt(target, target + Vector3.xAxis))
end

local city = workspace:WaitForChild("Grand Dojo City")
local canal = city:WaitForChild("Plaza & streets"):WaitForChild("Festival canal")
for _, anchor in canal:WaitForChild("Canal climb exits"):GetChildren() do
    local prompt = anchor:FindFirstChildOfClass("ProximityPrompt")
    prompt.Triggered:Connect(function(player) climbOut(player, anchor, prompt) end)
end

local function sample(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not (humanoid and root and humanoid.Health > 0 and not root.Anchored) then return end
    if inActivity(player) then
        states[player] = nil
        return
    end

    local state = states[player]
    if not state or state.character ~= character then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {character}
        params.IgnoreWater = true
        params.RespectCanCollide = true
        state = {character = character, params = params, grounded = 0, voidSamples = 0}
        states[player] = state
    end

    local position = root.Position
    local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
    if position.Y > VOID_Y and grounded and math.abs(root.AssemblyLinearVelocity.Y) < 7 then
        local hit = findGround(position, state.params, 5)
        if hit and position.Y - hit.Position.Y >= .8 then
            state.voidSamples = 0
            state.grounded += 1
            if state.grounded >= 2 then
                state.safe = root.CFrame
            end
            return
        end
    end
    state.grounded = 0

    if position.Y >= VOID_Y or grounded or humanoid:GetState() == Enum.HumanoidStateType.Swimming then
        state.voidSamples = 0
        return
    end
    state.voidSamples += 1
    if state.voidSamples < 2 then return end
    state.voidSamples = 0

    local safe = state.safe
    -- A saved footing can disappear if arena, environment, or stream state moved on.
    if not safe or not findGround(safe.Position, state.params, 5) then
        safe = spawn.CFrame + Vector3.new(0, spawn.Size.Y / 2 + 3, 0)
    end
    placeOnGround(character, root, safe)
end

Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
end)

while true do
    task.wait(SAMPLE_PERIOD)
    for _, player in Players:GetPlayers() do
        sample(player)
    end
end
