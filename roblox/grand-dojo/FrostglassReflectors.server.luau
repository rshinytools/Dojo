local Players = game:GetService("Players")
local puzzle = workspace:WaitForChild("Grand Dojo City")
    :WaitForChild("Connected districts")
    :WaitForChild("Frostglass Gardens")
    :WaitForChild("Frostglass Reflectors")

local PROGRESS_ATTRIBUTE = "FrostglassReflectorProgress"
-- These headings match the routes to each next RayAnchor in the native layout.
local TARGETS = {2, 3, 1}
local INITIAL_HEADINGS = {1, 1, 3}
local INPUT_INTERVAL = .24
local sessions = {}

local function update(player, session)
    local reached = 1
    for index, target in TARGETS do
        if session.headings[index] ~= target then
            break
        end
        reached += 1
    end

    if reached == 4 and not session.solved then
        session.solved = true
        session.clears += 1
    end
    player:SetAttribute(PROGRESS_ATTRIBUTE, string.format(
        "%d%d%d:%d:%d", session.headings[1], session.headings[2], session.headings[3], reached, session.clears
    ))
end

local function connect(hub, lens)
    local prompt = hub:WaitForChild("Interact")
    prompt.Triggered:Connect(function(player)
        if player.Parent ~= Players or not prompt.Enabled then
            return
        end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0
            or (root.Position - hub.Position).Magnitude > prompt.MaxActivationDistance + .65 then
            return
        end

        local now = os.clock()
        local session = sessions[player]
        if not session then
            session = {headings = table.clone(INITIAL_HEADINGS), clears = 0, solved = false, lastInput = -math.huge}
            sessions[player] = session
        end
        if now - session.lastInput < INPUT_INTERVAL or (lens and session.solved) then
            return
        end
        session.lastInput = now

        if lens then
            session.headings[lens] = session.headings[lens] % 3 + 1
        else
            session.headings = table.clone(INITIAL_HEADINGS)
            session.solved = false
        end
        update(player, session)
    end)
end

connect(puzzle:WaitForChild("Source"):WaitForChild("Hub"), nil)
for index = 1, #TARGETS do
    connect(puzzle:WaitForChild("Lens" .. index):WaitForChild("Hub"), index)
end
Players.PlayerRemoving:Connect(function(player)
    sessions[player] = nil
end)
