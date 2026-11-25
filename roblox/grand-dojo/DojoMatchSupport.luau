local TweenService = game:GetService("TweenService")
local Match = {}

Match.FighterKits = table.freeze({
    ["reedguard-kangaroo"] = "reedguard",
    ["penguin-brawler"] = "penguin",
    ["silverback-gorilla"] = "silverback",
    ["fire-salamander"] = "salamander",
    ["karate-frog"] = "frog",
    ["river-otter"] = "otter",
    ["rooster-kickboxer"] = "rooster",
    ["sugar-glider"] = "glider",
    ["desert-scorpion"] = "scorpion",
    ["pistol-shrimp"] = "shrimp",
    ["walrus-sumo"] = "walrus",
    ["snapping-tortoise"] = "tortoise",
    ["armadillo-striker"] = "armadillo",
    ["komodo-dragon"] = "komodo",
    ["electric-owl"] = "owl",
    ["bighorn-ram"] = "ram",
    ["honey-badger"] = "badger",
    ["emerald-saber-tooth"] = "sabertooth",
})

local floorAttacks = {seismicChestPound = true, magmaTrail = true, tadpoleTornado = true, gustVortex = true,
    tidalBellyFlop = true, thunderDive = true, staticCharge = true, apexPounce = true, ["Breakwater Stamp"] = true}

function Match.floorAttack(action)
    return floorAttacks[action] == true
end

function Match.contactCue(event)
    if not event.point then
        return nil
    end
    local kind = event.kind
    if event.deflected then
        return "deflected"
    end
    if event.controlOnly then
        if event.rootDuration then
            return if kind == "snare" then "snared" elseif kind == "blocked" or kind == "braced" then kind else nil
        end
        return if kind == "pull" or kind == "miss" then "gustPull" else kind
    end
    if event.attack == "featherFlurry" and event.index == 3 and (event.damage or 0) > 0 then
        return "diveKick"
    end
    if kind == "parried" or kind == "blocked" or (event.damage or 0) > 0 then
        return kind
    end
    if Match.floorAttack(event.attack) then
        return "burst"
    end
    return nil
end

function Match.flat(vector)
    return Vector3.new(vector.X, 0, vector.Z)
end

function Match.root(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart") or nil
end

function Match.available(player)
    local status = player:GetAttribute("ProgressStatus")
    return player:GetAttribute("StarterSelectionRequired") == false
        and (status == "ready" or status == "saved")
        and not player:GetAttribute("StarterSelectionPending")
        and not player:GetAttribute("FighterSelectOpen")
        and not player:GetAttribute("SparringActive")
        and not player:GetAttribute("RingTrainingActive")
        and not player:GetAttribute("RingTrainingPending")
        and not player:GetAttribute("SkywalkTrialMode")
        and (player:GetAttribute("ParcelStage") or 0) == 0
        and (player:GetAttribute("RelayNextGate") or 0) == 0
end

function Match.inside(bounds, position)
    local offset = bounds.CFrame:PointToObjectSpace(position)
    return math.abs(offset.X) <= bounds.Size.X / 2 and math.abs(offset.Z) <= bounds.Size.Z / 2
        and offset.Y >= -2.6 and offset.Y <= 6.5
end

function Match.clampFloor(bounds, position, floor)
    local point = bounds.CFrame:PointToObjectSpace(position)
    local x = math.clamp(point.X, -bounds.Size.X / 2 + 1.05, bounds.Size.X / 2 - 1.05)
    local z = math.clamp(point.Z, -bounds.Size.Z / 2 + 1.05, bounds.Size.Z / 2 - 1.05)
    local clamped = bounds.CFrame:PointToWorldSpace(Vector3.new(x, 0, z))
    return Vector3.new(clamped.X, floor, clamped.Z)
end

function Match.near(root, part, radius)
    return root and (root.Position - part.Position).Magnitude <= radius
end

function Match.move(root, frame)
    root.CFrame = frame
    root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
end

function Match.armMotors(character)
    local arms = {}
    local torso = character:FindFirstChild("Torso")
    for _, side in {"Right", "Left"} do
        local motor = torso and torso:FindFirstChild(side .. " Shoulder")
        if motor and motor:IsA("Motor6D") then
            table.insert(arms, {motor = motor, rest = motor.C0, right = side == "Right"})
        end
    end
    return arms
end

function Match.pose(arms, action)
    local guard = action == "guard"
    for _, arm in arms do
        if guard or arm.right then
            if arm.tween then
                arm.tween:Cancel()
            end
            local angle, travel = if guard then -30 else -61, if guard then -.12 else -.45
            local attack = TweenService:Create(arm.motor, TweenInfo.new(.10), {
                C0 = CFrame.new(0, 0, travel) * arm.rest * CFrame.Angles(math.rad(angle), 0, 0),
            })
            arm.tween = attack
            attack:Play()
            task.delay(if guard then .52 else .17, function()
                if arm.tween == attack and arm.motor.Parent then
                    arm.tween = TweenService:Create(arm.motor, TweenInfo.new(.18), {C0 = arm.rest})
                    arm.tween:Play()
                end
            end)
        end
    end
end

function Match.clearPose(arms)
    for _, arm in arms do
        if arm.tween then
            arm.tween:Cancel()
            arm.tween = nil
        end
        if arm.motor.Parent then
            arm.motor.C0 = arm.rest
        end
    end
end

return Match
