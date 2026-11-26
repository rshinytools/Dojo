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
    character:PivotTo(safe * root.CFrame:ToObjectSpace(character:GetPivot()))
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
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
