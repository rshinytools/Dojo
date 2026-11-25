local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Impact = {}
local player = Players.LocalPlayer
local duration = 0.18
local restoreStep = "GrandDojoCombatImpactRestore"
local applyStep = "GrandDojoCombatImpactApply"
local latestAt = -math.huge
local active
local lastCamera, lastBase, lastWritten

local function motionDisabled()
    return GuiService.ReducedMotionEnabled or UserInputService.VREnabled
end

local function finite(value)
    return type(value) == "number" and math.abs(value) < math.huge
end

local function restoreOwned()
    local camera, base, written = lastCamera, lastBase, lastWritten
    lastCamera, lastBase, lastWritten = nil, nil, nil
    if camera and camera.CFrame == written then
        camera.CFrame = base
    end
end

local function clear()
    local pulse = active
    if pulse then
        active = nil
        pulse.modeChanged:Disconnect()
        if pulse.mode == Enum.CameraType.Custom then
            RunService:UnbindFromRenderStep(restoreStep)
            RunService:UnbindFromRenderStep(applyStep)
        end
    end
    restoreOwned()
end

local function ownsStockView(camera, humanoid, root)
    local subject = camera.CameraSubject
    return (subject == humanoid or subject == root)
        and player.CameraMode ~= Enum.CameraMode.LockFirstPerson
        and (camera.CFrame.Position - camera.Focus.Position).Magnitude > 2
end

local function pulseAge(pulse, camera)
    if pulse.camera ~= camera or camera ~= workspace.CurrentCamera or camera.CameraType ~= pulse.mode
        or player.Character ~= pulse.character or not player:GetAttribute("SparringActive")
        or pulse.shell.Parent ~= pulse.character or pulse.root.Parent ~= pulse.character
        or pulse.humanoid.Health <= 0 or motionDisabled() then
        clear()
        return nil
    end
    local age = os.clock() - pulse.started
    if age >= duration then
        clear()
        return nil
    end
    return age
end

local function offsetFrame(camera, base, age)
    local phase = age / duration
    local remaining = 1 - phase
    local envelope = remaining * remaining
    local gain = UserInputService.TouchEnabled and 0.48 or 1
    local horizontal = math.sin(2 * math.pi * phase) * envelope * gain * 0.26
    local vertical = math.sin(math.pi * phase) * envelope * gain * 0.075
    local written = base + base.RightVector * horizontal + base.UpVector * vertical
    lastCamera, lastBase, lastWritten = camera, base, written
    return written
end

local function applyStockView()
    local pulse = active
    if not pulse then return end
    local camera = pulse.camera
    local age = pulseAge(pulse, camera)
    if age and ownsStockView(camera, pulse.humanoid, pulse.root) then
        camera.CFrame = offsetFrame(camera, camera.CFrame, age)
    end
end

-- Only the live combat lens calls this. Its incoming transform is freshly authored each frame.
function Impact.frame(camera, baseCFrame)
    local pulse = active
    if pulse and pulse.mode == Enum.CameraType.Scriptable and pulse.camera == camera then
        local age = pulseAge(pulse, camera)
        if age then
            return offsetFrame(camera, baseCFrame, age)
        end
    end
    return baseCFrame
end

function Impact.play(packet, serverNow)
    if type(packet) ~= "table" or packet.pulse ~= true or not finite(packet.at) or not finite(serverNow)
        or packet.at <= latestAt or serverNow - packet.at > 0.25 or packet.at - serverNow > 0.10
        or motionDisabled() or not player:GetAttribute("SparringActive") then
        return
    end
    local camera = workspace.CurrentCamera
    local character = player.Character
    if not camera or not character then return end
    local shell = character:FindFirstChild("Starter Fighter Shell")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    if not shell or packet.shell ~= shell or not root or humanoid.Health <= 0 then return end
    local mode = camera.CameraType
    if mode ~= Enum.CameraType.Scriptable
        and (mode ~= Enum.CameraType.Custom or not ownsStockView(camera, humanoid, root)) then
        return
    end

    clear()
    latestAt = packet.at
    local pulse = {
        started = os.clock(),
        camera = camera,
        mode = mode,
        character = character,
        shell = shell,
        humanoid = humanoid,
        root = root,
        modeChanged = camera:GetPropertyChangedSignal("CameraType"):Connect(clear),
    }
    active = pulse
    if mode == Enum.CameraType.Custom then
        RunService:BindToRenderStep(restoreStep, Enum.RenderPriority.Camera.Value - 1, restoreOwned)
        RunService:BindToRenderStep(applyStep, Enum.RenderPriority.Camera.Value + 10, applyStockView)
    end
    task.delay(duration, function()
        if active == pulse then clear() end
    end)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(clear)
player:GetAttributeChangedSignal("SparringActive"):Connect(clear)
player.CharacterRemoving:Connect(clear)
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(clear)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(clear)

return Impact
