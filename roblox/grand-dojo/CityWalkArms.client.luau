-- Keep the equipped fighter's visible arm swing in the torso's forward plane.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local presentationRadius = 120
local fits = {}

local function release(fit)
    for _, arm in fit.arms do
        if arm.weld.Parent and arm.weld.C0 == arm.applied then
            arm.weld.C0 = arm.rest
        end
    end
    table.clear(fit.arms)
    fit.weight = 0
end

local function walkingTrack(humanoid)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    local best
    if animator then
        for _, track in animator:GetPlayingAnimationTracks() do
            local name = track.Animation and track.Animation.Name
            if (name == "WalkAnim" or name == "RunAnim")
                and (not best or track.WeightCurrent > best.WeightCurrent) then
                best = track
            end
        end
    end
    return best
end

local function updateFit(fit, torso, weight, dt)
    fit.weight += math.clamp(weight - fit.weight, -dt / .14, dt / .14)
    if fit.weight <= .001 then
        release(fit)
        return
    end

    local stride = math.cos((fit.phase - .36) * 2 * math.pi)
    for _, side in {"Left", "Right"} do
        local arm = fit.arms[side]
        if not arm then
            local mesh = fit.shell:FindFirstChild(side .. " Arm")
            local weld = mesh and mesh:FindFirstChildOfClass("Weld")
            local shoulder = torso:FindFirstChild(side .. " Shoulder")
            if not (weld and shoulder and shoulder.Part1 and weld.Part0 == shoulder.Part1) then
                continue
            end
            arm = {weld = weld, shoulder = shoulder, rest = weld.C0, sign = if side == "Right" then 1 else -1}
            fit.arms[side] = arm
        end
        local shoulder = arm.shoulder
        local stock = shoulder.Transform
        local foreAft = CFrame.Angles(math.rad(3 + arm.sign * 15 * stride), 0, math.rad(arm.sign * 3))
        local axes = shoulder.C0.Rotation
        local fitted = stock:Lerp(axes:ToObjectSpace(foreAft * axes), fit.weight)
        -- Convert the torso-local swing through each fighter's fitted pivot.
        local attachment = shoulder.C1
        arm.applied = attachment * stock:Inverse() * fitted * attachment:Inverse() * arm.rest
        arm.weld.C0 = arm.applied
    end
end

local function updatePlayer(owner, eye, dt)
    local fit = fits[owner]
    local character = owner.Character
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local near = owner == localPlayer or (root and eye and (root.Position - eye).Magnitude <= presentationRadius)
    local animate = near and character and character:FindFirstChild("Animate")
    local humanoid = animate and character:FindFirstChildOfClass("Humanoid")
    local torso = humanoid and character:FindFirstChild("Torso")
    if not (root and shell and torso and not root.Anchored and not animate.Disabled)
        or humanoid.FloorMaterial == Enum.Material.Air
        or humanoid:GetState() ~= Enum.HumanoidStateType.Running or humanoid.Sit
        or owner:GetAttribute("SparringActive") or owner:GetAttribute("SkywalkTrialMode")
        or character:GetAttribute("ArenaJumpEnabled") then
        if fit then
            release(fit)
            fits[owner] = nil
        end
        return
    end

    if not fit or fit.shell ~= shell then
        if fit then release(fit) end
        fit = {shell = shell, arms = {}, weight = 0, phase = 0}
        fits[owner] = fit
    end
    local weight = 0
    if humanoid.MoveDirection.Magnitude > .01 or root.AssemblyLinearVelocity.Magnitude > .5 then
        local track = fit.track
        if not track or not track.IsPlaying then
            track = walkingTrack(humanoid)
            fit.track = track
        end
        if track and track.Length > 0 then
            fit.phase = track.TimePosition / track.Length
            weight = track.WeightCurrent
        end
    end
    updateFit(fit, torso, weight, dt)
end

Players.PlayerRemoving:Connect(function(owner)
    if fits[owner] then
        release(fits[owner])
        fits[owner] = nil
    end
end)

RunService.PreSimulation:Connect(function(dt)
    local camera = workspace.CurrentCamera
    local eye = camera and camera.CFrame.Position
    for _, owner in Players:GetPlayers() do
        updatePlayer(owner, eye, dt)
    end
end)
