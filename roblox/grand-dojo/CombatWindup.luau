-- Preview the authored Heavy or combo opener while the server decides the action.
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HitStop = require(ReplicatedStorage:WaitForChild("CombatHitStop"))
local Jump = require(ReplicatedStorage:WaitForChild("ArenaJumpMotion"))
local remote = ReplicatedStorage:WaitForChild("CombatWindupRemote")

local Windup = {}
local player = Players.LocalPlayer
local studio = RunService:IsStudio()
local shoulderMeshes = {["Left Shoulder"] = "Left Arm", ["Right Shoulder"] = "Right Arm"}
local ray = RaycastParams.new()
ray.RespectCanCollide = true
local seamSample = Vector3.new(.23, 0, .17)
local previewTime = .30
local handoffTime = .055
local contactLead = .012
local lightChainTime = .55
local lightBufferTime = .19
local generationAttribute = "CombatWindupGeneration"
local profileWaitTime = 1
local profileRetryTime = .05
local token = 0
local latestGeneration = 0
local closedThrough = -math.huge
local profile
local pending
local active

local function finite(value)
    return type(value) == "number" and math.abs(value) < math.huge
end

local function hasShoulderPose(pose)
    return type(pose) == "table" and typeof(pose["Left Shoulder"]) == "CFrame"
        and typeof(pose["Right Shoulder"]) == "CFrame"
end

local function reducedMotion()
    return GuiService.ReducedMotionEnabled or UserInputService.VREnabled
end

local function ease(t)
    local bounded = math.clamp(t, 0, 1)
    return bounded * bounded * (3 - 2 * bounded)
end

function Windup.clear()
    local preview = active
    if not preview then return end
    active = nil
    preview.simulation:Disconnect()
    for _, binding in preview.bindings do
        local weld = binding.weld
        if binding.written and weld.Parent and weld.C0 == binding.written then
            weld.C0 = binding.rest
        end
    end
    if studio then
        player:SetAttribute("CombatWindupToken", nil)
        player:SetAttribute("CombatWindupPhase", nil)
    end
end

local function hasFloor(point, floor)
    local surface = workspace:Raycast(point, -Vector3.yAxis * 2.62, ray)
    return surface ~= nil and math.abs(surface.Position.Y - floor) <= .17 and surface.Normal.Y >= .8
end

local function supported(character, root)
    local floor = character:GetAttribute("ArenaJumpFloor")
    if not finite(floor) or math.abs(root.Position.Y - floor - Jump.standingHeight) >= .26
        or math.abs(root.AssemblyLinearVelocity.Y) >= 2.5 then
        return false
    end
    local position = root.Position
    return hasFloor(position, floor) or hasFloor(position + seamSample, floor) or hasFloor(position - seamSample, floor)
end

local function ownsBindings(preview)
    for _, binding in preview.bindings do
        local weld, motor = binding.weld, binding.motor
        if not weld.Parent or not motor.Parent or motor.Part1 ~= weld.Part0
            or weld.C0 ~= (binding.written or binding.rest) then
            return false
        end
    end
    return true
end

local function startHandoff(preview, now, serverNow)
    local span = math.min(handoffTime, preview.expiresAt - now, preview.cutoff - serverNow)
    if span <= 0 then
        Windup.clear()
        return
    end
    preview.releaseAt = now
    preview.releaseSpan = span
    preview.releaseWeight = preview.weight
    if studio then player:SetAttribute("CombatWindupPhase", "handoff") end
end

local function step()
    local preview = active
    if not preview then return end
    local now, serverNow = os.clock(), workspace:GetServerTimeNow()
    if now >= preview.expiresAt or serverNow >= preview.cutoff or profile ~= preview.profile
        or player.Character ~= preview.character or preview.shell.Parent ~= preview.character
        or preview.root.Parent ~= preview.character or preview.humanoid.Health <= 0
        or not preview.animate.Parent or not preview.animate.Disabled or not player:GetAttribute("SparringActive")
        or reducedMotion() or HitStop.isActive() or not ownsBindings(preview)
        or not supported(preview.character, preview.root) then
        Windup.clear()
        return
    end
    if not preview.releaseAt and now >= preview.expiresAt - handoffTime then
        startHandoff(preview, now, serverNow)
    end
    if preview.releaseAt then
        local release = (now - preview.releaseAt) / preview.releaseSpan
        if release >= 1 then
            Windup.clear()
            return
        end
        preview.weight = preview.releaseWeight * (1 - ease(release))
    else
        preview.weight = ease((now - preview.started + .016) / preview.easeTime)
    end
    for _, binding in preview.bindings do
        local motor, weld = binding.motor, binding.weld
        local carrier = motor.C0 * motor.Transform * motor.C1:Inverse()
        weld.C0 = binding.rest:Lerp(carrier:ToObjectSpace(binding.target) * weld.C1, preview.weight)
        binding.written = weld.C0
    end
end

local function bindPending(candidate)
    if pending ~= candidate then return end
    if os.clock() >= candidate.expiresAt or workspace:GetServerTimeNow() >= candidate.endsAt
        or player.Character ~= candidate.character then
        pending = nil
        return
    end
    local shell = candidate.character:FindFirstChild("Starter Fighter Shell")
    if player:GetAttribute("SparringActive") and shell and (not candidate.shell or shell == candidate.shell)
        and shell:GetAttribute(generationAttribute) == candidate.generation then
        candidate.shell = shell
        profile, pending = candidate, nil
    end
end

local function awaitProfile(candidate)
    bindPending(candidate)
    if pending == candidate then
        task.delay(profileRetryTime, awaitProfile, candidate)
    end
end

function Windup.begin(action)
    if (action ~= "heavy" and action ~= "strike") or not player:GetAttribute("SparringActive") then
        return nil
    end
    if pending then bindPending(pending) end
    local current = profile or pending
    if not current then return nil end
    local serverNow = workspace:GetServerTimeNow()
    if serverNow < current.startsAt or serverNow >= current.endsAt then
        return nil
    end
    local jab = if action == "strike" then current.jab else nil
    if action == "strike" then
        if not jab then return nil end
        local ready = serverNow >= math.max(jab.readyAt, jab.localReadyAt)
        -- Even an unpreviewed strike can start or buffer the next light on the server.
        jab.localReadyAt = serverNow + jab.duration + lightChainTime + lightBufferTime + previewTime
        if not ready then return nil end
    end
    if not profile or active or reducedMotion() or HitStop.isActive() or serverNow < profile.busyUntil then
        return nil
    end
    local character = player.Character
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    local torso = character and character:FindFirstChild("Torso")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    local animate = character and character:FindFirstChild("Animate")
    if not (shell and shell == profile.shell and torso and root and humanoid.Health > 0
        and animate and animate.Disabled) then
        return nil
    end
    local pose = if jab then jab.pose else profile.pose
    local bindings = {}
    for joint, meshName in shoulderMeshes do
        local mesh = shell:FindFirstChild(meshName)
        local weld = mesh and mesh:FindFirstChildOfClass("Weld")
        local motor = torso:FindFirstChild(joint)
        if not (weld and motor and motor:IsA("Motor6D") and motor.Part0 == torso and motor.Part1 == weld.Part0) then
            return nil
        end
        local rest = weld.C0
        table.insert(bindings, {motor = motor, weld = weld, rest = rest,
            target = pose[joint] * motor.C1:Inverse() * rest * weld.C1:Inverse()})
    end
    ray.FilterDescendantsInstances = {character}
    local now = os.clock()
    token = token % 2147483647 + 1
    active = {token = token, action = if jab then jab.action else "heavy", character = character,
        shell = shell, root = root, humanoid = humanoid,
        animate = animate, profile = profile, bindings = bindings, started = now, requestedAt = serverNow,
        expiresAt = now + previewTime,
        cutoff = if jab then profile.endsAt else math.min(serverNow + profile.contact - contactLead, profile.endsAt),
        easeTime = if jab then .070 else .115, contact = if jab then jab.contact else profile.contact,
        localReadyAt = if jab then jab.localReadyAt else nil,
        simulation = RunService.PreSimulation:Connect(step)}
    step()
    if not active then return nil end
    if studio then
        player:SetAttribute("CombatWindupToken", token)
        player:SetAttribute("CombatWindupPhase", "preview")
    end
    return token
end

local function receiveProfile(packet, serverNow)
    local character = player.Character
    if not character or not (finite(packet.generation) and packet.generation % 1 == 0 and packet.generation > latestGeneration)
        or not (finite(packet.startsAt) and finite(packet.endsAt) and finite(packet.contact))
        or packet.startsAt <= closedThrough
        or packet.endsAt <= serverNow or packet.contact <= contactLead or packet.contact >= packet.endsAt - packet.startsAt
        or not hasShoulderPose(packet.pose) then
        return
    end
    latestGeneration = packet.generation
    Windup.clear()
    profile = nil
    local jabPacket, jab = packet.jab, nil
    if type(jabPacket) == "table" and finite(jabPacket.contact) and finite(jabPacket.duration)
        and finite(jabPacket.readyAt) and jabPacket.contact > contactLead and jabPacket.duration >= jabPacket.contact
        and hasShoulderPose(jabPacket.pose) then
        jab = {pose = jabPacket.pose, contact = jabPacket.contact, duration = jabPacket.duration,
            readyAt = jabPacket.readyAt, localReadyAt = -math.huge,
            action = if type(jabPacket.action) == "string" then jabPacket.action else "jab"}
    end
    pending = {character = character, shell = packet.shell, generation = packet.generation,
        startsAt = packet.startsAt, endsAt = packet.endsAt, expiresAt = os.clock() + profileWaitTime,
        contact = packet.contact, pose = packet.pose, busyUntil = -math.huge, jab = jab}
    awaitProfile(pending)
end

local function receiveReadiness(packet)
    local candidate = pending or profile
    if candidate and candidate.jab and packet.generation == candidate.generation and packet.startsAt == candidate.startsAt
        and (not packet.shell or not candidate.shell or packet.shell == candidate.shell)
        and finite(packet.jabReadyAt) then
        candidate.jab.readyAt = packet.jabReadyAt
    end
end

local function receiveDecision(packet, serverNow)
    local preview = active
    local now = os.clock()
    if not preview or preview.decided or packet.token ~= preview.token or packet.shell ~= preview.shell
        or packet.generation ~= preview.profile.generation or packet.action ~= preview.action
        or packet.startsAt ~= preview.profile.startsAt or now >= preview.expiresAt
        or serverNow >= preview.cutoff then
        return
    end
    local acceptedAt = packet.acceptedAt
    local busyUntil = if finite(packet.busyUntil) then packet.busyUntil else -math.huge
    if acceptedAt ~= nil then
        if not finite(acceptedAt) or acceptedAt < preview.profile.startsAt or acceptedAt < preview.requestedAt - .10
            or acceptedAt > serverNow + .10 or acceptedAt >= preview.profile.endsAt then
            return
        end
        local contactAt = acceptedAt + preview.contact
        preview.cutoff = math.min(preview.cutoff, contactAt - contactLead)
        busyUntil = math.max(contactAt, busyUntil)
        local jab = preview.profile.jab
        if jab and preview.action == jab.action and jab.localReadyAt == preview.localReadyAt then
            jab.localReadyAt = acceptedAt + jab.duration + lightChainTime
        end
        if studio then
            player:SetAttribute("CombatWindupAcceptedAt", acceptedAt)
            player:SetAttribute("CombatWindupAcceptedToken", preview.token)
        end
    end
    preview.decided = true
    preview.profile.busyUntil = math.max(preview.profile.busyUntil, busyUntil)
    if serverNow >= preview.cutoff then
        Windup.clear()
    elseif preview.releaseAt then
        preview.releaseSpan = math.min(preview.releaseSpan, now - preview.releaseAt + preview.cutoff - serverNow)
    else
        startHandoff(preview, now, serverNow)
    end
end

remote.OnClientEvent:Connect(function(kind, packet)
    if type(packet) ~= "table" then return end
    if kind == "profile" then
        receiveProfile(packet, workspace:GetServerTimeNow())
    elseif kind == "readiness" then
        receiveReadiness(packet)
    elseif kind == "decision" then
        receiveDecision(packet, workspace:GetServerTimeNow())
    end
end)

local function clearRound()
    Windup.clear()
    closedThrough = math.max(closedThrough, workspace:GetServerTimeNow())
    profile, pending = nil, nil
end

player.CharacterRemoving:Connect(clearRound)
player:GetAttributeChangedSignal("SparringActive"):Connect(function()
    if not player:GetAttribute("SparringActive") then clearRound() end
end)
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(Windup.clear)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(Windup.clear)

return table.freeze(Windup)
