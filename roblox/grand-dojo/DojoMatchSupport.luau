local TweenService = game:GetService("TweenService")
local FighterTactics = require(game:GetService("ReplicatedStorage"):WaitForChild("FighterTactics"))
local FighterLoadouts = require(game:GetService("ReplicatedStorage"):WaitForChild("FighterLoadouts"))
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
    ["great-white-shark"] = "shark",
    ["abyssal-kraken"] = "kraken",
    ["magma-grizzly-bear"] = "grizzly",
    ["obsidian-hellhound"] = "hellhound",
    ["golden-eagle"] = "eagle",
    ["celestial-storm-dragon"] = "dragon",
})

function Match.tactical(player, kitId)
    local profile = FighterTactics.ByKit[kitId]
    if not profile then return nil end
    local option = FighterTactics.forKit(kitId, player:GetAttribute(profile.attribute))
    return option.id
end

function Match.loadout(player, kitId)
    local group = FighterLoadouts.ByKit[kitId]
    return table.freeze({
        tactical = Match.tactical(player, kitId),
        basic = group and FighterLoadouts.forKit(kitId, "basic", player:GetAttribute(group.basic.attribute)).id,
        ultimate = group and FighterLoadouts.forKit(kitId, "ultimate", player:GetAttribute(group.ultimate.attribute)).id,
    })
end

local floorAttacks = {seismicChestPound = true, magmaTrail = true, tadpoleTornado = true, gustVortex = true,
    tidalBellyFlop = true, thunderDive = true, staticCharge = true, apexPounce = true,
    jawsOfTheDeep = true, tentacleCataclysm = true, ["Breakwater Stamp"] = true}

function Match.floorAttack(action)
    return floorAttacks[action] == true or FighterLoadouts.isFloorPulse(action)
end

function Match.loadoutFloorPulse(poses, action)
    return if FighterLoadouts.isFloorPulse(action) then poses.UltimateSkill[action] else nil
end

function Match.plantedAction(action)
    return FighterTactics.isPlanted(action) or FighterLoadouts.isPlanted(action)
end

function Match.plantedInput(side, action)
    local move = if action == "strike" then side.basic
        elseif action == "secondary" then side.tactical
        elseif action == "signature" then side.ultimate else nil
    return Match.plantedAction(move)
end

function Match.syncStormAim(player, side)
    local clip = side and side.clip
    local endsAt = if clip and clip.action == "tempestRoar" then clip.steerEndsAt else nil
    if endsAt ~= player:GetAttribute("TempestAimUntil") then
        player:SetAttribute("TempestAimUntil", endsAt)
    end
end

function Match.takeCombatInput(actor, action, direction, now, cooldown)
    if action == "stormSteer" then
        if (direction ~= -1 and direction ~= 0 and direction ~= 1) or now < (actor.nextSteer or 0) then
            return false
        end
        actor.nextSteer = now + .055
    else
        if now < actor.nextInput then
            return false
        end
        actor.nextInput = now + cooldown
    end
    return true
end

function Match.combatDirection(action, value)
    return if action == "stormSteer" then value elseif value == -1 then -1 else 1
end

function Match.stormFeedback(event)
    if event.kind == "talonCarry" then
        return "talonCarry"
    elseif event.attack == "talonDrop" and event.kind == "miss" then
        return "talonDropMiss"
    elseif event.stormThunder and (event.damage or 0) > 0 then
        return "stormThunder"
    end
    return nil
end

function Match.effectAttack(event)
    return if event.stormThunder then "stormThunder" else event.attack
end

function Match.contactCue(event)
    if not event.point then
        return nil
    end
    local kind = event.kind
    if event.deflected then
        return "deflected"
    end
    -- A blocked strike can still deal chip damage. Report the defense before
    -- choosing any move-specific effect based on positive damage.
    if kind == "parried" or kind == "blocked" or kind == "braced" or kind == "guardBroken" then
        return kind
    end
    if event.attack == "talonDrop" and (event.damage or 0) == 0 then
        return nil
    end
    if event.controlOnly then
        if event.rootDuration then
            return if kind == "snare" then "snared" else nil
        end
        return if kind == "pull" or kind == "miss" then "gustPull" else kind
    end
    if event.attack == "featherFlurry" and event.index == 3 and (event.damage or 0) > 0 then
        return "diveKick"
    end
    if (event.damage or 0) > 0 then
        return kind
    end
    if Match.floorAttack(event.attack) then
        return "burst"
    end
    return nil
end

local shoulders = {"Left Shoulder", "Right Shoulder"}
local kickingLimbs = {"Left Shoulder", "Right Shoulder", "Right Hip"}

local function contactPose(kit, event, motors)
    local pose = {}
    local offsets = kit.poses.sample(event.attack, event.poseAt, event.poseDirection)
    for _, name in if event.holdKick then kickingLimbs else shoulders do
        local joint = motors[name]
        if not joint or not offsets[name] then return nil end
        pose[name] = offsets[name] * joint.rest
    end
    return pose
end

function Match.queueHitStop(actor, kitId, kit, event, motors, reaction)
    if not actor or (event.kind ~= "strike" and event.kind ~= "counter")
        or (event.damage or 0) <= 0 or not event.point then
        return
    end
    local pulse = event.signatureCast ~= nil and event.signatureCast > (actor.lastSignatureImpactCast or -math.huge)
    -- A reaction from the same server step owns the fighter's pose during a trade.
    local hold = (not reaction or reaction.endsAt <= event.at)
        and (event.poseHold == .04 or (event.poseHold == .08 and pulse))
    if not (pulse or hold) then return end
    local last = actor.pendingHitStop
    if last and (last.at >= event.at or (last.pulse and not pulse)) then
        return
    end
    local character = actor.root.Parent
    local shell = character and character:FindFirstChild("Starter Fighter Shell")
    if not shell or not kitId or Match.FighterKits[shell:GetAttribute("FighterId")] ~= kitId then return end

    local pose = if hold and motors then contactPose(kit, event, motors) else nil
    if pulse then
        actor.lastSignatureImpactCast = event.signatureCast
    elseif not pose then
        return
    end
    actor.pendingHitStop = {shell = shell, at = event.at, duration = if pose then event.poseHold else nil,
        pose = pose, pulse = if pulse then true else nil}
end

function Match.takeHitStop(actor)
    local packet = actor.pendingHitStop
    actor.pendingHitStop = nil
    return packet
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
        and not player:GetAttribute("DuelTransferHold") and not player:GetAttribute("DojoPartyTravel")
        and not player:GetAttribute("FighterSelectOpen")
        and not player:GetAttribute("SparringActive")
        and not player:GetAttribute("RingTrainingActive")
        and not player:GetAttribute("RingTrainingPending")
        and not player:GetAttribute("SkywalkTrialMode")
        and not player:GetAttribute("CityAdventureActive")
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
