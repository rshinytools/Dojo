local seat = script.Parent
local prompt = seat:WaitForChild("SitAtSunset")

local function updatePrompt()
    prompt.Enabled = seat.Occupant == nil
end

seat:GetPropertyChangedSignal("Occupant"):Connect(updatePrompt)
updatePrompt()

prompt.Triggered:Connect(function(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not seat.Occupant and humanoid and root and humanoid.Health > 0
        and not humanoid.SeatPart and (root.Position - seat.Position).Magnitude <= prompt.MaxActivationDistance then
        seat:Sit(humanoid)
    end
end)
