local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Match = require(script.Parent:WaitForChild("DojoMatchSupport"))
local Round = require(script.Parent:WaitForChild("SparringRound"))
local FeaturedRound = require(script.Parent:WaitForChild("ReedguardRound"))
local Motion = require(script.Parent:WaitForChild("ReedguardFightMotion"))
local progression = require(ReplicatedStorage:WaitForChild("RingProgression"))
local bots = require(ReplicatedStorage:WaitForChild("SparringBots"))
local fighters = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog")).ById
local sparringWon = script.Parent:WaitForChild("SparringWon")
local remote = ReplicatedStorage:WaitForChild("GrandDojoSparring")
local templates = ServerStorage:WaitForChild("Resident Dojo Bots")

local city = workspace:WaitForChild("Grand Dojo City")
local districts = city:WaitForChild("Connected districts")
local rings = {
    ["grand-dojo"] = city:WaitForChild("Fighting Ring"),
    cinder = districts:WaitForChild("Cinder Terraces"):WaitForChild("Cinder Terraces Ring"),
    ["cloud-top"] = districts:WaitForChild("Skywalk Peaks"):WaitForChild("Cloud-Top Temple"),
    galleon = districts:WaitForChild("Tideharbor Coast"):WaitForChild("Sunken Pirate Galleon"):WaitForChild("Tideharbor practice ring"),
}
local activeByPlayer, offers, rematches, lastAction = {}, {}, {}, {}

local function notice(player, message)
    remote:FireClient(player, "notice", message)
end

local function publish(bout, kind, now)
    local round = bout.round
    local tell = if round.botPhase == "setup" then round.attack.setup
        elseif round.botPhase == "windup" then round.attack.name else nil
    remote:FireClient(bout.player, kind, round.playerHealth, round.botHealth, round.startsAt, round.endsAt,
        if bout.outroAt then "outro" else round.botPhase, if now < bout.messageUntil then bout.message else nil, round.botAt,
        (if bout.featured then FeaturedRound else Round).parryOpensAt(round), bout.arena.config.botId,
        round.playerMaxHealth, bout.arena.id, tell, round.introAt)
end

local function finish(bout, result, now, disconnected)
    local arena, player = bout.arena, bout.player
    arena.active, activeByPlayer[player] = nil, nil
    bout.bot:Destroy()
    bout.telegraph:Destroy()
    if bout.motion then
        Motion.close(bout)
    else
        Match.clearPose(bout.arms)
    end
    player:SetAttribute("SparringActive", nil)
    player:SetAttribute("ActiveDojoRing", nil)
    if disconnected then
        return
    end
    local root = Match.root(player)
    if root == bout.root and result ~= "outside" then
        Match.move(root, arena.safeReturn.CFrame)
    end
    local wins = player:GetAttribute("SparringWins") or 0
    if result == "win" then
        wins += 1
        player:SetAttribute("SparringWins", wins)
    end
    rematches[player] = {arena = arena, untilAt = now + 35}
    remote:FireClient(player, "result", result, wins, result == "win", arena.config.botId, arena.id)
    if result == "win" then
        sparringWon:Fire(player, bout.fighterId)
    end
end

local function entry(player, arena, retrying)
    local root = Match.root(player)
    if not (Match.near(root, arena.gate, arena.prompt.MaxActivationDistance + .8)
        or (retrying and Match.near(root, arena.safeReturn, 8))) then
        return nil, "Walk to the Bot Spar sign to enter this ring."
    elseif arena.active then
        return nil, "A spar is underway. This ring opens again when it ends."
    elseif player:GetAttribute("DuelQueued") then
        return nil, "Leave the Grand Dojo duel queue before starting Bot Spar."
    elseif not Match.available(player) then
        return nil, "Finish your current activity and let your progress save before sparring."
    end
    local open, message = progression.access(player:GetAttribute("HighestFighterLevel"), player:GetAttribute("FighterLevel"), arena.id)
    return if open then root else nil, message
end

local function jointMap(bot)
    local origin = bot:GetPivot()
    local joints = {}
    for _, part in bot:GetChildren() do
        local pivot = part:FindFirstChild("ArtPivot")
        if part:IsA("MeshPart") and pivot then
            joints[part.Name] = {part = part, joint = origin:ToObjectSpace(pivot.WorldCFrame),
                shell = pivot.WorldCFrame:ToObjectSpace(part.CFrame)}
        end
    end
    return joints
end

local function begin(player, arena, now, retrying)
    local root, message = entry(player, arena, retrying)
    if not root then
        notice(player, message)
        return
    end
    local fighterId = player:GetAttribute("SelectedStarterFighter")
    local fighter = fighters[fighterId]
    if not fighter then
        return
    end
    offers[player], rematches[player] = nil, nil
    local profile = arena.profile
    local bot = templates[profile.name]:Clone()
    bot:PivotTo(arena.botSpawn.CFrame)
    local cue = Instance.new("Highlight")
    cue.Name = "Guard cue"
    cue.DepthMode = Enum.HighlightDepthMode.Occluded
    cue.FillTransparency = .94
    cue.OutlineTransparency = .20
    cue.Enabled = false
    cue.Parent = bot
    local telegraph = Instance.new("Folder")
    telegraph.Name = "Attack tell"
    telegraph.Parent = arena.corner
    local featured = arena.id == "grand-dojo" and fighterId == "reedguard-kangaroo" and arena.config.botId == "juniper"
    local bout = {featured = featured, arena = arena, player = player, root = root, fighterId = fighterId,
        bot = bot, profile = profile, cue = cue, joints = jointMap(bot), telegraph = telegraph,
        position = arena.botSpawn.Position, direction = arena.botSpawn.CFrame.LookVector,
        round = (if featured then FeaturedRound else Round).new(now, profile, fighter), messageUntil = 0, lastPublish = now,
        arms = Match.armMotors(player.Character)}
    arena.active, activeByPlayer[player] = bout, bout
    player:SetAttribute("SparringActive", true)
    player:SetAttribute("ActiveDojoRing", arena.id)
    bot.Parent = arena.corner
    Match.move(root, arena.playerSpawn.CFrame)
    if featured then
        Motion.open(bout)
        Motion.render(bout, now)
    end
    publish(bout, "begin", now)
end

local function distanceFacing(bout, usePose)
    local position = if usePose then bout.posePosition or bout.position else bout.position
    local delta = Match.flat(position - bout.root.Position)
    local distance = delta.Magnitude
    local facing = distance < .01 or Match.flat(bout.root.CFrame.LookVector):Dot(delta.Unit) >= .12
    return if Match.inside(bout.arena.bounds, bout.root.Position) then distance else math.huge, facing
end

local function inAttack(bout)
    local attack, frame = bout.round.attack, bout.attackFrame
    if not frame or not Match.inside(bout.arena.bounds, bout.root.Position) then
        return false
    end
    local localPosition = frame:PointToObjectSpace(bout.root.Position)
    local depth, width = -localPosition.Z, math.abs(localPosition.X)
    local radius = math.sqrt(depth * depth + width * width)
    if attack.shape == "circle" then
        return radius <= attack.reach
    elseif attack.shape == "lane" then
        return depth >= -.35 and depth <= attack.reach and width <= attack.width
    end
    return radius <= attack.reach and depth >= radius * .58
end

local function floorMark(bout, size, frame, shape)
    local mark = Instance.new("Part")
    mark.Name = "Committed attack area"
    mark.Anchored, mark.CanCollide, mark.CanQuery, mark.CanTouch = true, false, false, false
    mark.CastShadow, mark.Material, mark.Color = false, Enum.Material.Neon, bout.profile.tint
    mark.Transparency = .70
    mark.Shape = shape or Enum.PartType.Block
    mark.Size, mark.CFrame = size, frame
    mark.Parent = bout.telegraph
end

local function markAttack(bout)
    local attack, frame = bout.round.attack, bout.attackFrame + Vector3.new(0, .08, 0)
    if attack.shape == "circle" then
        floorMark(bout, Vector3.new(.035, attack.reach * 2, attack.reach * 2),
            frame * CFrame.Angles(0, 0, math.pi / 2), Enum.PartType.Cylinder)
    elseif attack.shape == "lane" then
        floorMark(bout, Vector3.new(attack.width * 2, .035, attack.reach), frame * CFrame.new(0, 0, -attack.reach / 2))
    else
        for angle = -48, 48, 16 do
            floorMark(bout, Vector3.new(1.12, .035, attack.reach),
                frame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, 0, -attack.reach / 2))
        end
    end
end

local function animate(bout, now, dt)
    local round, arena = bout.round, bout.arena
    local toward = Match.flat(bout.root.Position - bout.position)
    local distance = toward.Magnitude
    local direction = if distance > .03 then toward.Unit else bout.direction
    local isReady = now >= round.startsAt and round.botPhase == "ready" and distance > 4.5 and distance < 50
    local stride, lean, arm = 0, 0, 0
    if isReady then
        local move = math.min(dt * bout.profile.pace, distance - 4.5)
        bout.position = Match.clampFloor(arena.bounds, bout.position + direction * move, arena.floor)
        stride = math.sin(now * 12) * 10
    end
    local position = bout.position
    if round.botPhase == "setup" then
        local setup = round.attack
        local beat = math.sin(math.pi * math.clamp(1 - (round.botAt - now) / setup.setupTime, 0, 1))
        position = Match.clampFloor(arena.bounds, position + (direction * (setup.advance or 0)
            + direction:Cross(Vector3.yAxis) * (setup.strafe or 0)) * beat, arena.floor)
        lean, arm = beat * 12, -beat * 15
    elseif round.botPhase == "windup" then
        direction = bout.attackFrame.LookVector
        local beat = math.clamp(1 - (round.botAt - now) / round.attack.windup, 0, 1)
        lean, arm = -beat * 12, beat * 30
    elseif round.botPhase == "recovery" then
        local beat = math.max(0, 1 - (now - round.recoveryStartedAt) / .32)
        local lunging = round.attack.shape == "lane"
        direction = bout.releaseDirection or direction
        position = Match.clampFloor(arena.bounds, position + direction * beat * (if lunging then 3.15 else .70), arena.floor)
        lean, arm = beat * 17, -beat * 73
    end
    bout.direction = direction
    bout.posePosition = position
    local frame = CFrame.lookAt(position, position + direction)
    bout.bot:PivotTo(frame)
    local trunk = frame * CFrame.Angles(math.rad(lean), 0, 0)
    for name, joint in bout.joints do
        local rotation, base = 0, trunk
        if name == "Right Arm" then
            rotation = arm + stride
        elseif name == "Left Arm" then
            rotation = arm * .35 - stride
        elseif name == "Right Leg" then
            rotation, base = -stride, frame
        elseif name == "Left Leg" then
            rotation, base = stride, frame
        end
        joint.part.CFrame = base * joint.joint * CFrame.Angles(math.rad(rotation), 0, 0) * joint.shell
    end
end

local arenas = {}
for _, id in progression.Order do
    local corner = rings[id]:WaitForChild("Bot Spar Corner")
    local config = progression.ById[id]
    local gate = corner:WaitForChild("Sparring Gate")
    local botSpawn = corner:WaitForChild("Bot Spawn")
    local arena = {id = id, config = config, profile = bots[config.botId], corner = corner, gate = gate,
        prompt = gate:WaitForChild("SparPrompt"), bounds = corner:WaitForChild("Sparring Bounds"),
        playerSpawn = corner:WaitForChild("Player Spawn"), safeReturn = corner:WaitForChild("Safe Return"),
        botSpawn = botSpawn, floor = botSpawn.Position.Y}
    table.insert(arenas, arena)
    arena.prompt.Triggered:Connect(function(player)
        if not Match.near(Match.root(player), arena.gate, arena.prompt.MaxActivationDistance + .8) then
            return
        end
        local root, message = entry(player, arena, false)
        local untilAt = workspace:GetServerTimeNow() + 30
        offers[player] = if root then {arena = arena, untilAt = untilAt} else nil
        remote:FireClient(player, "offer", arena.id, untilAt, root ~= nil, message)
    end)
end

remote.OnServerEvent:Connect(function(player, action, direction)
    if type(action) ~= "string" then
        return
    end
    local now = workspace:GetServerTimeNow()
    if now - (lastAction[player] or -math.huge) < .095 then
        return
    end
    lastAction[player] = now
    if action == "accept" then
        local offer = offers[player]
        if offer and now < offer.untilAt then
            begin(player, offer.arena, now, false)
        else
            notice(player, "Use the local Bot Spar sign to enter the ring.")
        end
        return
    elseif action == "cancelChoice" then
        offers[player] = nil
        return
    elseif action == "retry" then
        local rematch = rematches[player]
        if rematch and now < rematch.untilAt then
            begin(player, rematch.arena, now, true)
        else
            notice(player, "Use the local Bot Spar sign to start another round.")
        end
        return
    end
    local bout = activeByPlayer[player]
    if not bout then
        return
    end
    if action == "leave" then
        finish(bout, if bout.outroAt then bout.round.result else "left", now)
    elseif bout.featured then
        if Match.root(player) ~= bout.root or not Match.inside(bout.arena.bounds, bout.root.Position) then
            return
        end
        local feedback = FeaturedRound.act(bout.round, action, now, direction)
        if feedback then
            bout.message, bout.messageUntil = feedback, now + .74
            publish(bout, "state", now)
        end
    elseif (action == "strike" or action == "guard") and Match.root(player) == bout.root
        and Match.inside(bout.arena.bounds, bout.root.Position) then
        local distance, facing = distanceFacing(bout, action == "strike")
        local feedback = Round.act(bout.round, action, now, distance, facing)
        if feedback then
            Match.pose(bout.arms, action)
            bout.message, bout.messageUntil = feedback, now + .73
        end
        if bout.round.result then
            finish(bout, bout.round.result, now)
        end
    end
end)

local function tickShowcase(bout, now, dt)
    local round = bout.round
    local distance = Motion.move(bout, now, dt)
    local before = round.botPhase
    FeaturedRound.step(round, now, distance, function(action, move, time, index)
        return Motion.strike(bout, action, move, time, index)
    end, function(time)
        return Motion.palm(bout, time)
    end)
    local hadImpact = #round.notices > 0
    for _, event in round.notices do
        Motion.impact(bout, event)
        bout.message, bout.messageUntil = event.kind, now + .86
        if RunService:IsStudio() then
            bout.bot:SetAttribute("LastContactAt", event.at)
            bout.bot:SetAttribute("LastContactKind", event.kind)
            bout.bot:SetAttribute("LastContactAttack", event.attack)
            bout.bot:SetAttribute("LastContactIndex", event.index)
        end
    end
    table.clear(round.notices)
    if round.result then
        bout.outroAt = bout.outroAt or now
        if now >= bout.outroAt + FeaturedRound.OUTRO then
            finish(bout, round.result, now)
            return
        end
    end
    Motion.render(bout, now)
    local opensAt = FeaturedRound.parryOpensAt(round)
    local parryCue = not bout.outroAt and opensAt ~= nil and now >= opensAt and now <= round.botAt
    local cueChanged = parryCue ~= bout.parryCue
    bout.parryCue = parryCue
    bout.cue.Enabled = parryCue
    bout.cue.OutlineColor = Color3.fromRGB(151, 235, 248)
    if cueChanged or hadImpact or before ~= round.botPhase or now - bout.lastPublish >= .14 then
        publish(bout, "state", now)
        bout.lastPublish = now
    end
end

local function tickBout(bout, now, dt)
    local round, arena = bout.round, bout.arena
    if Match.root(bout.player) ~= bout.root then
        finish(bout, "left", now)
        return
    end
    if Match.inside(arena.bounds, bout.root.Position) then
        bout.outsideSince = nil
    elseif now >= round.startsAt then
        bout.outsideSince = bout.outsideSince or now
        if now - bout.outsideSince > 1.6 then
            finish(bout, "outside", now)
            return
        end
    end
    if bout.featured then
        tickShowcase(bout, now, dt)
        return
    end
    local before = round.botPhase
    local distance, facing = distanceFacing(bout)
    local feedback = Round.step(round, now, distance, facing, inAttack(bout))
    if round.result then
        finish(bout, round.result, now)
        return
    end
    if feedback then
        bout.message, bout.messageUntil = feedback, now + .86
    end
    if before ~= round.botPhase then
        bout.telegraph:ClearAllChildren()
        if round.botPhase == "windup" then
            local delta = Match.flat(bout.root.Position - bout.position)
            local direction = if delta.Magnitude > .03 then delta.Unit else bout.direction
            bout.attackFrame = CFrame.lookAt(bout.position, bout.position + direction)
            markAttack(bout)
        elseif round.botPhase == "recovery" then
            bout.releaseDirection = bout.attackFrame.LookVector
            bout.attackFrame = nil
        end
    end
    animate(bout, now, dt)
    local opensAt = Round.parryOpensAt(round)
    local parryCue = opensAt ~= nil and now >= opensAt and now <= round.botAt
    local cueStarted = parryCue and not bout.parryCue
    bout.parryCue = parryCue
    bout.cue.Enabled = round.botPhase ~= "ready"
    local tint = if parryCue then Color3.fromRGB(151, 235, 248) else bout.profile.tint
    bout.cue.FillColor, bout.cue.OutlineColor = tint, tint
    if cueStarted or feedback or before ~= round.botPhase or now - bout.lastPublish >= .14 then
        publish(bout, "state", now)
        bout.lastPublish = now
    end
end

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    local tickStandard = elapsed >= .05
    local step = math.min(elapsed, .15)
    if tickStandard then
        elapsed = 0
    end
    local now = workspace:GetServerTimeNow()
    for _, arena in arenas do
        local bout = arena.active
        if bout and (bout.featured or tickStandard) then
            tickBout(bout, now, if bout.featured then math.min(dt, .15) else step)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local bout = activeByPlayer[player]
    if bout then
        finish(bout, "left", 0, true)
    end
    rematches[player], offers[player], lastAction[player] = nil, nil, nil
end)
