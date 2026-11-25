-- Hold the fitted contact pose locally while the authoritative rig keeps moving.
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Jump = require(ReplicatedStorage:WaitForChild("ArenaJumpMotion"))

local HitStop = {}
local player = Players.LocalPlayer
local studio = RunService:IsStudio()
local maximumAge = .25
local releaseTime = .035
local meshFor = {["Left Shoulder"] = "Left Arm", ["Right Shoulder"] = "Right Arm", ["Right Hip"] = "Right Leg"}
local ray = RaycastParams.new()
ray.RespectCanCollide = true
local latestAt = -math.huge
local active

local function reducedMotion()
    return GuiService.ReducedMotionEnabled or UserInputService.VREnabled
end

local function clear()
    if not active then return end
    active.simulation:Disconnect()
    active.render:Disconnect()
    for _, binding in active.bindings do
        local weld = binding.weld
        if weld.Parent and weld.C0 == binding.written then
            weld.C0 = binding.rest
        end
    end
    if studio then
        player:SetAttribute("CombatHitStopPhase", nil)
    end
    active = nil
end

local function supported(hold)
    local root, character = hold.root, hold.character
    local floor = character:GetAttribute("ArenaJumpFloor")
    if type(floor) ~= "number" or math.abs(root.Position.Y - floor - Jump.standingHeight) >= .26
        or math.abs(root.AssemblyLinearVelocity.Y) >= 2.5 then
        return false
    end
    local surface = workspace:Raycast(root.Position, -Vector3.yAxis * 2.62, ray)
    return surface ~= nil and math.abs(surface.Position.Y - floor) <= .17 and surface.Normal.Y >= .8
end

local function noteRender()
    local hold = active
    if not hold or not hold.corrected then return end
    hold.releaseAt = hold.releaseAt or os.clock() + hold.duration
    if hold.releasing then hold.renderedRelease = true end
end

local function step()
    local hold = active
    if not hold then return end
    local now = os.clock()
    if now >= hold.expiresAt or player.Character ~= hold.character or hold.shell.Parent ~= hold.character
        or not player:GetAttribute("SparringActive") or hold.root.Parent ~= hold.character
        or hold.humanoid.Health <= 0
        or reducedMotion() or not supported(hold) then
        clear()
        return
    end
    local releaseAge = if hold.releaseAt then now - hold.releaseAt else 0
    if releaseAge >= releaseTime and hold.renderedRelease then
        clear()
        return
    end
    -- Keep a partial pose for one frame if a slow render skips the whole blend interval.
    local weight = 1 - math.clamp(releaseAge / releaseTime, 0, .75)
    hold.releasing = weight < 1
    for _, binding in hold.bindings do
        local weld, motor = binding.weld, binding.motor
        if not weld.Parent or not motor.Parent or weld.C0 ~= (binding.written or binding.rest) then
            clear()
            return
        end
    end
    for _, binding in hold.bindings do
        local motor, weld = binding.motor, binding.weld
        local carrier = motor.C0 * motor.Transform * motor.C1:Inverse()
        weld.C0 = binding.rest:Lerp(carrier:ToObjectSpace(binding.target) * weld.C1, weight)
        binding.written = weld.C0
    end
    hold.corrected = true
    if studio then
        player:SetAttribute("CombatHitStopPhase", if weight == 1 then "hold" else "release")
    end
end

function HitStop.play(packet, now)
    if not player or type(packet) ~= "table" or type(packet.at) ~= "number"
        or not (packet.at > latestAt and now - packet.at <= maximumAge and packet.at - now <= .1)
        or not (packet.duration == .04 or packet.duration == .08) or reducedMotion()
        or not player:GetAttribute("SparringActive") then
        return
    end
    local character = player.Character
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    local torso = character and character:FindFirstChild("Torso")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    local animate = character and character:FindFirstChild("Animate")
    if not (shell and shell == packet.shell and torso and root and humanoid.Health > 0
        and animate and animate.Disabled and type(packet.pose) == "table") then
        return
    end
    ray.FilterDescendantsInstances = {character}
    local hold = {character = character, shell = shell, root = root, humanoid = humanoid,
        duration = packet.duration, expiresAt = os.clock() + maximumAge, bindings = {}}
    if not supported(hold) then return end

    clear()
    for joint, target in packet.pose do
        local mesh = meshFor[joint] and shell:FindFirstChild(meshFor[joint])
        local weld = mesh and mesh:FindFirstChildOfClass("Weld")
        local motor = torso:FindFirstChild(joint)
        if weld and motor and motor:IsA("Motor6D") and motor.Part1 == weld.Part0 and typeof(target) == "CFrame" then
            local rest = weld.C0
            table.insert(hold.bindings, {motor = motor, weld = weld, rest = rest,
                target = target * motor.C1:Inverse() * rest * weld.C1:Inverse()})
        end
    end
    if #hold.bindings < 2 then return end
    latestAt = packet.at
    active = hold
    active.simulation = RunService.PreSimulation:Connect(step)
    active.render = RunService.PreRender:Connect(noteRender)
    if studio then
        player:SetAttribute("CombatHitStopDuration", packet.duration)
        player:SetAttribute("CombatHitStopAt", packet.at)
    end
end

return table.freeze(HitStop)
