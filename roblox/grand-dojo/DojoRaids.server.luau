local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Match = require(script.Parent.DojoMatchSupport)
local Motion = require(script.Parent.DuelFightMotion)
local Round = require(script.Parent.KilnbackRaidRound)
local fighters = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog")).ById
local effects = ReplicatedStorage:WaitForChild("GrandDojoSparring")
local completed = script.Parent:WaitForChild("DojoRaidCompleted")
local districts = workspace:WaitForChild("Grand Dojo City"):WaitForChild("Connected districts")

local PERIOD, ENROLLMENT, SEATS = 1200, 120, Round.SIZE
local REVIVE_DISTANCE = 5.65
local studio = RunService:IsStudio()
local actionSet = {strike = true, guard = true, heavy = true, uppercut = true, secondary = true, dodge = true,
    signature = true, stormSteer = true}
local ROTATION_LENGTH = 3
local studioWindow = 0

local function mount(encounter)
    local raidId, prefix, Visuals = encounter.id, encounter.prefix, encounter.visuals
    local remote = ReplicatedStorage:WaitForChild(prefix .. "Raid")
    local district = districts:WaitForChild(encounter.district)
    local entry = district:WaitForChild(prefix .. " Raid Entry")
    local gate = entry:WaitForChild(prefix .. " Raid Queue")
    local prompt = gate:WaitForChild("Join" .. prefix .. "RaidPrompt")
    local cityReturn = entry:WaitForChild("Raid Return")
    local court = district:WaitForChild(prefix .. " Raid Court")
    local bounds = court:WaitForChild("Bounds")
    local floor = court:WaitForChild("Floor Origin").Position.Y
    local marks = court:WaitForChild("Spawn Marks")
    local boss = court:WaitForChild(encounter.bossName)
    local origin = boss:WaitForChild("Origin").Position
    local collider = boss:WaitForChild("Shell Collider")
    local shell = {part = boss:WaitForChild("Shell Hit"), zone = "body"}
    local core = {part = boss:WaitForChild("Core Hit"), zone = "core"}
    local visuals = Visuals.new(court)
    local queue, statusAt = {}, {}
    local active, lastWindow
    local matchId, nextCheck = 0, 0

    local function schedule(now)
        local window = math.floor(now / PERIOD)
        local opens = window * PERIOD
        if studio then
            return window, opens, opens + PERIOD, true
        end
        local offset = (encounter.rotationSlot - window) % ROTATION_LENGTH
        if offset == 0 and now < opens + ENROLLMENT and lastWindow ~= window then
            return window, opens, opens + ENROLLMENT, true
        end
        local nextWindow = window + (if offset == 0 then ROTATION_LENGTH else offset)
        local nextOpen = nextWindow * PERIOD
        return nextWindow, nextOpen, nextOpen + ENROLLMENT, false
    end

    local function send(player, event, fields)
        fields.raidId = raidId
        remote:FireClient(player, event, fields)
    end

    local function eligible(player, buffer)
        local root = Match.root(player)
        local id = player:GetAttribute("SelectedStarterFighter")
        return player.Parent == Players and prompt.Enabled and Match.available(player)
            and not player:GetAttribute("DuelQueued") and not player:GetAttribute("BrawlQueued")
            and not player:GetAttribute("TagTeamQueued") and fighters[id] and Match.FighterKits[id]
            and (not player:GetAttribute("KilnbackRaidQueued") or queue[player] ~= nil)
            and Match.near(root, gate, prompt.MaxActivationDistance + buffer) and root
    end

    local function queueCount()
        local count = 0
        for _ in queue do
            count += 1
        end
        return count
    end

    local function queuePacket(player, event, now, message)
        if player.Parent ~= Players then
            return
        end
        local _, opens, closes, open = schedule(now)
        local queued = queue[player] ~= nil
        if event == "queue" then
            player:SetAttribute("KilnbackRaidQueued", if queued then true else nil)
        end
        send(player, event, {queued = queued, count = queueCount(), required = SEATS,
            opensAt = opens, closesAt = closes, canJoin = open and not active and not queued and not not eligible(player, .5),
            message = message})
    end

    local function updateQueue(now)
        for player in queue do
            queuePacket(player, "queue", now)
        end
    end

    local function cancel(player, now, message)
        if queue[player] then
            queue[player] = nil
            queuePacket(player, "queue", now, message)
            updateQueue(now)
        end
    end

    local function prune(now)
        local window, _, _, open = schedule(now)
        local changed = false
        for player, member in queue do
            if not open or member.window ~= window or eligible(player, 3) ~= member.root
                or player:GetAttribute("SelectedStarterFighter") ~= member.fighterId then
                queue[player] = nil
                queuePacket(player, "queue", now, if not open then "The raid window closed." else "Stay near the raid entrance.")
                changed = true
            end
        end
        if changed then
            updateQueue(now)
        end
    end

    local function liveSide(match, index)
        local actor, side = match.actors[index], match.round.sides[index]
        return actor and not actor.returned and not side.left and not side.eliminated and Match.root(actor.player) == actor.root
    end

    local function canReachForRevive(match, index, target, at)
        local actor, targetActor = match.actors[index], match.actors[target]
        local side = match.round.sides[target]
        if not (liveSide(match, index) and targetActor and not targetActor.returned and side.downed and not side.left
            and not side.reviveUsed and Match.root(targetActor.player) == targetActor.root) then
            return false
        end
        -- The downed root stays anchored. Use the reviver's sampled motion for scheduled checks.
        local frame = at and Motion.raidPosition(match, index, at)
        local position = if frame then frame.Position else actor.root.Position
        return (position - targetActor.root.Position).Magnitude <= REVIVE_DISTANCE
            and Match.inside(bounds, position), position
    end

    local function nearestRevive(match, index, now)
        local actor = match.actors[index]
        local nearest, distance = nil, math.huge
        for target, teammate in match.actors do
            if Round.canBeginRevive(match.round, index, target, now) and canReachForRevive(match, index, target) then
                local gap = (actor.root.Position - teammate.root.Position).Magnitude
                if gap < distance then
                    nearest, distance = target, gap
                end
            end
        end
        return nearest
    end

    local function publish(match, kind, now)
        local round = match.round
        local slots = {}
        for index, actor in match.actors do
            local side = round.sides[index]
            slots[index] = {kitId = side.kitId, health = side.playerHealth, maxHealth = side.playerMaxHealth,
                userName = actor.player.DisplayName, down = side.downed or false, left = side.left or false,
                reviveUsed = side.reviveUsed or false}
        end
        local attack = round.attack
        local packetAttack = attack and {id = attack.id, name = attack.name, windupAt = attack.warningAt or attack.startedAt,
            impactAt = attack.impactAt, lastImpactAt = if #attack.steps > 0 then attack.steps[#attack.steps].at else nil,
            landAt = attack.landAt, endAt = attack.endsAt, hint = attack.hint}
        for index, actor in match.actors do
            local player, side = actor.player, round.sides[index]
            if not actor.returned and player.Parent == Players then
                Match.syncStormAim(player, if not round.result and not side.eliminated then side else nil)
                local revive = round.revives[index]
                send(player, kind, {matchId = match.id, introAt = round.introAt, startsAt = round.startsAt,
                    endsAt = round.endsAt, resolvedAt = round.resolvedAt, bossHealth = round.bossHealth,
                    bossMaxHealth = round.bossMaxHealth, phase = round.bossPhase, attack = packetAttack,
                    bossAirborne = round.bossAirborne == true,
                    vulnerableUntil = round.cooldownUntil, selfIndex = index, slots = slots,
                    nextSignature = side.nextSignature, nextSecondary = side.nextSecondary,
                    feedback = if now < actor.feedbackUntil then actor.feedback else nil,
                    revive = revive and {targetIndex = revive.target, startedAt = revive.startedAt, endsAt = revive.endsAt},
                    reviveTarget = if not round.result and now >= round.startsAt then nearestRevive(match, index, now) else nil})
            end
        end
    end

    local function reviveMarker(root, container)
        local marker = Instance.new("BillboardGui")
        marker.Name, marker.Adornee, marker.Enabled = "Revival sign", root, false
        marker.Size, marker.StudsOffsetWorldSpace = UDim2.fromOffset(70, 24), Vector3.new(0, 1.1, 0)
        marker.MaxDistance, marker.LightInfluence = 18, 0
        local label = Instance.new("TextLabel")
        label.Size, label.Text = UDim2.fromScale(1, 1), "REVIVE"
        label.Font, label.TextSize = Enum.Font.GothamBold, 14
        label.TextColor3, label.BackgroundColor3 = Color3.fromRGB(170, 249, 224), Color3.fromRGB(25, 57, 56)
        label.BackgroundTransparency, label.BorderSizePixel = .12, 0
        local corner = Instance.new("UICorner")
        corner.CornerRadius, corner.Parent = UDim.new(0, 6), label
        label.Parent, marker.Parent = marker, container
        return marker
    end

    local function start(now, window)
        local lineup = {}
        for player, member in queue do
            member.player = player
            table.insert(lineup, member)
        end
        if #lineup ~= SEATS then
            return
        end
        table.sort(lineup, function(a, b)
            return a.joinedAt < b.joinedAt or (a.joinedAt == b.joinedAt and a.player.UserId < b.player.UserId)
        end)
        local actors, entrants, byPlayer = {}, {}, {}
        local telegraph = Instance.new("Folder")
        telegraph.Name, telegraph.Parent = prefix .. " combat effects", court
        for index, member in lineup do
            local kit = Match.FighterKits[member.fighterId]
            entrants[index] = {fighter = fighters[member.fighterId], kitId = kit}
            actors[index] = {player = member.player, root = member.root, nextInput = now, feedbackUntil = 0,
                reviveMarker = reviveMarker(member.root, telegraph)}
            byPlayer[member.player] = index
        end
        matchId += 1
        lastWindow = window
        if studio then
            -- Studio data is isolated. Assign each run its own receipt window so
            -- testers can earn both trophies in either order during one session.
            studioWindow = math.max(math.floor(now), studioWindow + 1)
            window = studioWindow
        end
        local round = Round.new(now, entrants, raidId)
        local match = {id = matchId, window = window, clearId = HttpService:GenerateGUID(false), actors = actors, round = round,
            telegraph = telegraph, byPlayer = byPlayer, bounds = bounds, floor = floor, lastPublish = now,
            bossVolumes = {shell}, exposedBossVolumes = {core, shell}, bossCollider = collider,
            reviveStarts = {}, direction = Vector3.zAxis}
        active = match
        table.clear(queue)
        Visuals.reset(visuals)
        for index, actor in actors do
            local player = actor.player
            player:SetAttribute("KilnbackRaidQueued", nil)
            player:SetAttribute("KilnbackRaidActive", true)
            player:SetAttribute("SparringActive", true)
            Match.move(actor.root, marks["Seat " .. index].CFrame)
            task.spawn(function()
                pcall(function() player:RequestStreamAroundAsync(bounds.Position, 6) end)
            end)
        end
        Motion.open(match, true)
        Motion.render(match, now)
        Visuals.update(visuals, round, now, match.direction)
        publish(match, "begin", now)
    end

    local function finishPlayer(match, index, result, departing)
        local actor = match.actors[index]
        if actor.returned then
            return
        end
        actor.returned = true
        actor.reviveMarker.Enabled = false
        Motion.remove(match, index)
        local player = actor.player
        if departing or player.Parent ~= Players then
            return
        end
        player:SetAttribute("KilnbackRaidActive", nil)
        player:SetAttribute("SparringActive", nil)
        local root = Match.root(player)
        if root then
            Match.move(root, cityReturn.CFrame + Vector3.new(((index - 1) % 2) * 2.25, 0, math.floor((index - 1) / 2) * 2.3))
        end
        local outcome = match.round.result
        send(player, "result", {matchId = match.id, result = result,
            reason = outcome and outcome.reason or "leave", rewardPending = actor.reward == true})
    end

    local function stop(match)
        for index in match.actors do
            finishPlayer(match, index, match.round.result.outcomes[index])
        end
        Motion.close(match)
        match.telegraph:Destroy()
        Visuals.reset(visuals)
        active = nil
    end

    local function leave(player, now, departing)
        cancel(player, now, "You left the raid queue.")
        local match = active
        local index = match and match.byPlayer[player]
        if index and not match.actors[index].returned then
            local finished = match.round.result
            Round.leave(match.round, index, now)
            finishPlayer(match, index, if finished then finished.outcomes[index] else "left", departing)
        end
    end

    local function cue(actor, content, now)
        if actor then
            actor.feedback, actor.feedbackUntil = content, now + 1.15
        end
    end

    local function chooseTarget(match, at)
        local from = match.lastTarget or 0
        for offset = 1, SEATS do
            local index = (from + offset - 1) % SEATS + 1
            if liveSide(match, index) then
                local frame = Motion.raidPosition(match, index, at)
                local direction = frame and Match.flat(frame.Position - origin)
                if direction and direction.Magnitude > .08 then
                    match.direction = direction.Unit
                end
                match.lastTarget = index
                return index
            end
        end
        return nil
    end

    local function hazardSoundPoint(strike, direction)
        if strike.centerX then
            return origin + Vector3.new(strike.centerX, 0, strike.centerZ)
        elseif strike.axisX then
            local axis = Vector3.new(strike.axisX, 0, strike.axisZ)
            return origin + axis * ((strike.innerReach + strike.outerReach) / 2)
        end
        return origin + direction * (strike.offset or 0)
    end

    local function advance(match, now)
        local round = match.round
        Motion.move(match, now)
        Round.step(round, now,
            function(index, action, move, at, contactIndex, castAt)
                return Motion.strikeRaid(match, index, action, move, at, contactIndex, castAt)
            end,
            function(attack, strike, at)
                local sound = if attack.id == "sunDive" then "hit" else "burst"
                effects:FireAllClients("combatAudio", sound, hazardSoundPoint(strike, match.direction), attack.id)
                return Motion.raidThreatHits(match, attack, strike, at, origin, match.direction)
            end,
            function(_, at) return chooseTarget(match, at) end,
            function(index, target, at)
                local home = match.reviveStarts[index]
                local reachable, position = canReachForRevive(match, index, target, at)
                return home and reachable and (position - home).Magnitude <= 1.15
            end)
        local changed = #round.notices > 0
        for _, event in round.notices do
            local code = Match.contactCue(event)
            if event.source == "arena" and event.kind == "landing" then
                effects:FireAllClients("combatAudio", "burst", origin, event.attack)
            elseif event.source == "boss" then
                cue(match.actors[event.defender], if event.frenzyResist then "frenzyResist" else event.kind, now)
                if (event.damage or 0) > 0 and not event.frenzyResist then
                    Motion.raidImpact(match, event.defender, origin, event.at, 1.15)
                end
            elseif event.source == "player" then
                cue(match.actors[event.attacker], Match.stormFeedback(event)
                    or (if event.shockDuration then "shockLanded" elseif event.core then "core" else event.kind), now)
            elseif event.source == "team" then
                cue(match.actors[event.attacker], event.kind, now)
                cue(match.actors[event.defender], event.kind, now)
                if event.kind == "revived" and liveSide(match, event.defender) then
                    Motion.revive(match, event.defender, event.at, Round.REVIVE_RECOVERY, now)
                end
            end
            if code then
                local playedAtHazard = event.source == "boss" and event.kind == "hit"
                effects:FireAllClients("impact", code, event.point, Match.effectAttack(event), playedAtHazard)
            end
        end
        table.clear(round.notices)
        for index, actor in match.actors do
            local side = round.sides[index]
            if not actor.returned then
                actor.reviveMarker.Enabled = side.downed == true and not side.reviveUsed and not round.result
            end
            if not round.revives[index] then
                match.reviveStarts[index] = nil
            end
        end
        if round.result and not match.granted then
            match.granted = true
            for index, qualified in round.result.eligible or {} do
                local actor = match.actors[index]
                if qualified and not actor.returned and actor.player.Parent == Players then
                    actor.reward = true
                    completed:Fire(actor.player, match.window, match.clearId, match.id, raidId)
                end
            end
        end
        return changed
    end

    local function join(player, now)
        local window, _, _, open = schedule(now)
        local root = eligible(player, .5)
        if not open or active or not root then
            queuePacket(player, "schedule", now, if active then "A party is in this raid." elseif not open
                then "Come back at the next raid bell." else "Stand by the raid entrance between activities.")
            return
        end
        prune(now)
        if queue[player] then
            return
        end
        queue[player] = {root = root, fighterId = player:GetAttribute("SelectedStarterFighter"), window = window, joinedAt = now}
        updateQueue(now)
        if queueCount() == SEATS then
            start(now, window)
        end
    end

    prompt.Triggered:Connect(function(player)
        local now = workspace:GetServerTimeNow()
        if queue[player] then
            cancel(player, now, "You left the raid queue.")
        else
            join(player, now)
        end
    end)

    remote.OnServerEvent:Connect(function(player, action, value, id)
        local now = workspace:GetServerTimeNow()
        if action == "status" then
            if now >= (statusAt[player] or 0) and (queue[player] or Match.near(Match.root(player), gate, 13)) then
                statusAt[player] = now + .8
                queuePacket(player, "schedule", now)
            end
            return
        elseif action == "join" then
            join(player, now)
            return
        elseif action == "cancel" then
            cancel(player, now, "You left the raid queue.")
            return
        end
        local match = active
        local index = match and match.byPlayer[player]
        if not index or id ~= match.id or match.actors[index].returned then
            return
        elseif action == "leave" then
            leave(player, now)
            return
        end
        if action ~= "revive" and (type(action) ~= "string" or not actionSet[action]) then
            return
        end
        local actor, round = match.actors[index], match.round
        if round.result or now < round.startsAt or not liveSide(match, index)
            or not Motion.canAct(match, index, action, now) or not Match.takeCombatInput(actor, action, value, now, .075) then
            return
        end
        local changed = advance(match, now)
        if action == "revive" then
            if type(value) == "number" and value % 1 == 0 and value >= 1 and value <= SEATS and canReachForRevive(match, index, value)
                and Round.beginRevive(round, index, value, now) then
                match.reviveStarts[index] = actor.root.Position
                changed = true
            end
        else
            local result = Round.act(round, index, action, now, Match.combatDirection(action, value))
            if result then
                cue(actor, result, now)
                changed = true
            end
        end
        if changed then
            publish(match, "update", now)
        end
    end)

    RunService.Heartbeat:Connect(function()
        local now = workspace:GetServerTimeNow()
        if now >= nextCheck then
            nextCheck = now + .5
            if not active then
                prune(now)
            end
            for _, player in Players:GetPlayers() do
                if not player:GetAttribute("KilnbackRaidActive") then
                    local root = Match.root(player)
                    local offset = root and (root.Position - bounds.Position)
                    if offset and math.abs(offset.Y) < 14 and math.abs(offset.X) < 30 and math.abs(offset.Z) < 33 then
                        Match.move(root, cityReturn.CFrame)
                    end
                end
            end
        end
        local match = active
        if not match then
            return
        end
        for index, actor in match.actors do
            if not actor.returned and Match.root(actor.player) ~= actor.root then
                leave(actor.player, now)
            elseif liveSide(match, index) and not match.round.result and not Match.inside(bounds, actor.root.Position) then
                local position = Match.clampFloor(bounds, actor.root.Position, floor + 2.3)
                Match.move(actor.root, CFrame.new(position) * actor.root.CFrame.Rotation)
            end
        end
        local changed = advance(match, now)
        local round = match.round
        if round.result and now >= round.outroAt then
            stop(match)
            return
        end
        Motion.render(match, now)
        Visuals.update(visuals, round, now, match.direction)
        if changed or now - match.lastPublish >= .12 then
            match.lastPublish = now
            publish(match, "update", now)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        statusAt[player] = nil
        leave(player, workspace:GetServerTimeNow(), true)
    end)

    Visuals.reset(visuals)
end

mount({
    id = "kilnback", prefix = "Kilnback", district = "Cinder Terraces",
    bossName = "Kilnback Custodian", rotationSlot = 0, visuals = require(script.Parent.KilnbackRaidVisuals),
})
mount({
    id = "kraken", prefix = "Abyssal", district = "Tideharbor Coast",
    bossName = "Abyssal Kraken", rotationSlot = 1, visuals = require(script.Parent.AbyssalRaidVisuals),
})
mount({
    id = "phoenix", prefix = "Solar", district = "Lantern Circuit",
    bossName = "Solar Phoenix", rotationSlot = 2, visuals = require(script.Parent.SolarRaidVisuals),
})
