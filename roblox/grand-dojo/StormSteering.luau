local UserInputService = game:GetService("UserInputService")
local StormSteering = {}
StormSteering.__index = StormSteering
StormSteering.hint = "Aim with movement"

local function directionFor(player)
    if UserInputService:GetFocusedTextBox() then
        return 0
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then
        return 0
    end
    local camera = workspace.CurrentCamera
    local right = if camera then camera.CFrame.RightVector else root.CFrame.RightVector
    local lateral = humanoid.MoveDirection:Dot(right)
    return if lateral < -.25 then -1 elseif lateral > .25 then 1 else 0
end

function StormSteering.new(player)
    return setmetatable({player = player, direction = 0, nextSendAt = 0}, StormSteering)
end

function StormSteering:active(now)
    local endsAt = self.player:GetAttribute("TempestAimUntil")
    return type(endsAt) == "number" and now < endsAt
end

function StormSteering:step(enabled, send)
    local now = if enabled then workspace:GetServerTimeNow() else 0
    if not enabled or not self:active(now) then
        self.castEndsAt, self.direction, self.nextSendAt, self.refreshAt = nil, 0, 0, nil
        return
    end
    local endsAt = self.player:GetAttribute("TempestAimUntil")
    if endsAt ~= self.castEndsAt then
        self.castEndsAt, self.direction, self.nextSendAt, self.refreshAt = endsAt, 0, 0, nil
    end
    if now < self.nextSendAt then
        return
    end
    local direction = directionFor(self.player)
    if direction ~= self.direction or (self.refreshAt and now >= self.refreshAt) then
        self.direction, self.nextSendAt, self.refreshAt = direction, now + .07, now + .22
        send("stormSteer", direction)
    end
end

return StormSteering
