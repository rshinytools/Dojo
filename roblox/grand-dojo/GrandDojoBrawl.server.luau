local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Match = require(script.Parent:WaitForChild("DojoMatchSupport"))
local Motion = require(script.Parent:WaitForChild("BrawlFightMotion"))
local Windup = require(script.Parent:WaitForChild("CombatWindupSupport"))
local Round = require(script.Parent:WaitForChild("BrawlCombatRound"))
local fighters = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog")).ById
local CombatPresentation = require(ReplicatedStorage:WaitForChild("CombatPresentation"))
local remote = ReplicatedStorage:WaitForChild("GrandDojoBrawl")
local effects = ReplicatedStorage:WaitForChild("GrandDojoSparring")
local ring = workspace:WaitForChild("Grand Dojo City"):WaitForChild("Fighting Ring")
local entry = ring:WaitForChild("Brawl Entry")
local gate = entry:WaitForChild("Brawl Queue")
local prompt = gate:WaitForChild("JoinBrawlPrompt")
local cityReturn = entry:WaitForChild("Brawl Return")
local court = ring:WaitForChild("Brawl Court")
local bounds = court:WaitForChild("Bounds")
local floor = court:WaitForChild("Floor Origin").Position.Y
local viewing = court:WaitForChild("Spectator Return")
local tiles = court:WaitForChild("Tiles")
local shrinkBands = {tiles:WaitForChild("Outer"), tiles:WaitForChild("Middle"), tiles:WaitForChild("Inner")}
local marks = court:WaitForChild("Spawn Marks")

local SIZE, QUEUE_SECONDS = 8, 70
local SHRINK_STEP, WARNING_SECONDS = 15, 3
local PLAYABLE_HALVES = {22.5, 17.5, 12.5, 7.5}
local KNOCKOUT_EDGE_CLEARANCE = .08
local RESULT_EDGE_CLEARANCE = 2
local actionSet = {strike = true, guard = true, heavy = true, uppercut = true, secondary = true, stormSteer = true,
    dodge = true, signature = true}
local breaking = Color3.fromRGB(235, 155, 81)
local deckState, queue = {}, {}
local knockoutDecks = {}
local active
local matchId, nextCourtCheck = 0, 0

for index, half in PLAYABLE_HALVES do
    local center = bounds.Position
    local extent = half - KNOCKOUT_EDGE_CLEARANCE
    knockoutDecks[index] = {minX = center.X - extent, maxX = center.X + extent,
        minZ = center.Z - extent, maxZ = center.Z + extent}
end

for index, band in shrinkBands do
    deckState[index] = {}
    for _, part in band:GetChildren() do
        table.insert(deckState[index], {part = part, frame = part.CFrame, color = part.Color,
            material = part.Material, canQuery = part.CanQuery})
    end
end

local function floorStageAt(round, at)
    for stage = #deckState, 1, -1 do
        if at >= round.startsAt + stage * SHRINK_STEP then
            return stage
        end
    end
    return 0
end

local function nextDropAt(round, stage)
    return if stage < #deckState then round.startsAt + (stage + 1) * SHRINK_STEP else nil
end

local function syncDeck(match, now)
    local stage = floorStageAt(match.round, now)
    local nextDrop = nextDropAt(match.round, stage)
    local warning = if nextDrop and now >= nextDrop - WARNING_SECONDS then stage + 1 else nil
    if stage == match.stage and warning == match.warning then
        return false
    end
    for index = match.stage + 1, stage do
        for _, tile in deckState[index] do
            local part = tile.part
            part.CanCollide, part.CanQuery = false, false
            tile.tween = TweenService:Create(part, TweenInfo.new(.42, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {CFrame = tile.frame - Vector3.yAxis * 4.5, Transparency = 1})
            tile.tween:Play()
        end
    end
    if warning then
        for _, tile in deckState[warning] do
            tile.part.Color, tile.part.Material = breaking, Enum.Material.SmoothPlastic
        end
    end
    match.stage, match.warning = stage, warning
    return true
end

local function restoreDeck()
    for _, band in deckState do
        for _, tile in band do
            if tile.tween then
                tile.tween:Cancel()
                tile.tween = nil
            end
            local part = tile.part
            part.CFrame, part.Color, part.Material = tile.frame, tile.color, tile.material
            part.Transparency, part.CanCollide, part.CanQuery = 0, true, tile.canQuery
        end
    end
end

local function eligible(player, extraRange)
    local root = Match.root(player)
    local id = player:GetAttribute("SelectedStarterFighter")
    return player.Parent == Players and prompt.Enabled and Match.available(player)
        and not player:GetAttribute("DuelQueued") and not player:GetAttribute("TagTeamQueued")
        and not player:GetAttribute("KilnbackRaidQueued")
        and fighters[id] and Match.FighterKits[id]
        and Match.near(root, gate, prompt.MaxActivationDistance + extraRange) and root
end

local function publishQueue(entry, queued, count, message)
    local player = entry.player
    if player.Parent == Players then
        player:SetAttribute("BrawlQueued", if queued then true else nil)
        remote:FireClient(player, "queue", {queued = queued, count = count, required = SIZE,
            expiresAt = entry.expiresAt, message = message})
    end
end

local function queueCount()
    local count = 0
    for _ in queue do
        count += 1
    end
    return count
end

local function updateQueue()
    local count = queueCount()
    for _, waiting in queue do
        publishQueue(waiting, true, count)
    end
end

local function unqueue(player, message)
    local waiting = queue[player]
    if waiting then
        queue[player] = nil
        publishQueue(waiting, false, queueCount(), message)
        updateQueue()
    end
end

local function pruneQueue(now)
    for player, waiting in queue do
        if now >= waiting.expiresAt then
            unqueue(player, "Brawl queue expired. Join again at the sign.")
        elseif eligible(player, 3.5) ~= waiting.root then
            unqueue(player, "Stay near the Brawl sign while waiting.")
        end
    end
end

local function publish(match, kind, now, departing)
    local round = match.round
    local nextShrink = nextDropAt(round, match.stage)
    local snapshot = CombatPresentation.snapshot(match)
    local recipients = {}
    for index, actor in match.actors do
        if actor.returned or actor.player == departing or actor.player.Parent ~= Players then
            continue
        end
        local side = round.sides[index]
        Match.syncStormAim(actor.player, if not round.result and not side.eliminated then side else nil)
        remote:FireClient(actor.player, kind, {matchId = match.id, startsAt = round.startsAt, endsAt = round.endsAt,
            resolvedAt = round.resolvedAt,
            playerHealth = side.playerHealth, maxHealth = side.playerMaxHealth,
            kitId = actor.kit, tactical = side.tactical, basic = side.basic, ultimate = side.ultimate,
            alive = round.remaining,
            total = SIZE, stage = match.stage, nextShrinkAt = nextShrink,
            warningAt = nextShrink and nextShrink - WARNING_SECONDS, eliminated = side.eliminated,
            spectatorRoot = actor.spectatorRoot,
            placement = side.placement, feedback = if now < actor.feedbackUntil then actor.feedback else nil,
            nextSignature = side.nextSignature, nextSecondary = side.nextSecondary,
            presentationSequence = snapshot.sequence, impacts = snapshot.impacts, hitStop = Match.takeHitStop(actor)})
        if not round.result and not side.eliminated then
            Windup.profile(actor, side, actor.motors, round.startsAt, round.endsAt)
        end
        table.insert(recipients, actor.player.UserId)
    end
    CombatPresentation.broadcast(effects, snapshot, recipients)
end

local function onFloor(point, reference, stage)
    local half = PLAYABLE_HALVES[stage + 1]
    return math.abs(point.X - reference.X) <= half and math.abs(point.Z - reference.Z) <= half
end

local function start(now)
    local lineup = {}
    for _, waiting in queue do
        table.insert(lineup, waiting)
    end
    if #lineup ~= SIZE then
        return
    end
    table.sort(lineup, function(a, b)
        return a.joinedAt < b.joinedAt or (a.joinedAt == b.joinedAt and a.player.UserId < b.player.UserId)
    end)
    local actors, entrants, sideFor = {}, {}, {}
    for index, waiting in lineup do
        local player = waiting.player
        local id = player:GetAttribute("SelectedStarterFighter")
        local kit = Match.FighterKits[id]
        actors[index] = {player = player, root = waiting.root, kit = kit, nextInput = now, feedbackUntil = 0}
        entrants[index] = {fighter = fighters[id], kitId = kit, level = player:GetAttribute("FighterLevel"),
            loadout = Match.loadout(player, kit)}
        sideFor[player] = index
    end
    matchId += 1
    local telegraph = Instance.new("Folder")
    telegraph.Name = "Brawl attack tells"
    telegraph.Parent = court
    local round = Round.new(now, entrants)
    local match = {id = matchId, round = round, actors = actors, sideFor = sideFor, bounds = bounds, floor = floor,
        telegraph = telegraph, stage = 0, lastPublish = now}
    function match.floorActive(point, at)
        local stage = if at and at ~= match.outgoingFloorAt then floorStageAt(round, at) else match.stage
        return onFloor(point, bounds.Position, stage)
    end
    function match.knockoutDeck()
        return knockoutDecks[match.stage + 1]
    end
    function match.resultStand(frame)
        local center, position = bounds.Position, frame.Position
        local standingY = marks["Seat 1"].Position.Y
        if onFloor(position, center, match.stage) and math.abs(position.Y - standingY) <= .02 then
            return nil
        end
        local half = PLAYABLE_HALVES[match.stage + 1] - RESULT_EDGE_CLEARANCE
        local planted = Vector3.new(math.clamp(position.X, center.X - half, center.X + half),
            standingY, math.clamp(position.Z, center.Z - half, center.Z + half))
        local forward = Match.flat(frame.LookVector)
        return if forward.Magnitude > .01 then CFrame.lookAlong(planted, forward) else CFrame.new(planted)
    end
    active = match
    table.clear(queue)
    for index, actor in actors do
        local player = actor.player
        player:SetAttribute("BrawlQueued", nil)
        player:SetAttribute("BrawlActive", true)
        player:SetAttribute("SparringActive", true)
        player:SetAttribute("ActiveDojoRing", "grand-dojo")
        Match.move(actor.root, marks["Seat " .. index].CFrame)
        task.spawn(function()
            pcall(function() player:RequestStreamAroundAsync(bounds.Position, 6) end)
        end)
    end
    Motion.open(match)
    Motion.render(match, now)
    publish(match, "begin", now)
end

local function placeSpectator(match, index)
    local actor = match.actors[index]
    if actor.returned then
        return
    end
    Motion.remove(match, index)
    local root = Match.root(actor.player)
    if not root or actor.spectatorRoot == root then
        return
    end
    actor.spectatorRoot = root
    local position = viewing.Position + Vector3.new((index - 4.5) * 2.5, 0, 0)
    Match.move(root, CFrame.lookAt(position, Vector3.new(bounds.Position.X, position.Y, bounds.Position.Z)))
end

local function sendResult(match, index, result, departing)
    local actor, round = match.actors[index], match.round
    if actor.returned then
        return
    end
    actor.returned = true
    Motion.remove(match, index)
    local player = actor.player
    if departing or player.Parent ~= Players then
        return
    end
    player:SetAttribute("BrawlActive", nil)
    player:SetAttribute("SparringActive", nil)
    player:SetAttribute("ActiveDojoRing", nil)
    local root = Match.root(player)
    if root then
        local column, row = (index - 1) % 4, math.floor((index - 1) / 4)
        local position = cityReturn.Position + Vector3.new((column - 1.5) * 2.4, 0, row * 2.75)
        Match.move(root, CFrame.lookAt(position, Vector3.new(gate.Position.X, position.Y, gate.Position.Z)))
    end
    local winner = round.result and round.result.winners[1]
    remote:FireClient(player, "result", {matchId = match.id, result = result, placement = round.sides[index].placement,
        winnerName = winner and match.actors[winner].player.DisplayName, alive = round.remaining, total = SIZE,
        presentationSequence = CombatPresentation.resultSequence(match)})
end

local function stop(match)
    for index in match.actors do
        sendResult(match, index, match.round.result.outcomes[index])
    end
    Motion.close(match)
    match.telegraph:Destroy()
    restoreDeck()
    active = nil
end

local function setFeedback(actor, notice, now)
    actor.feedback, actor.feedbackUntil = notice, now + .75
end

local function resolveContacts(match, now, beforeBoundary)
    Round.step(match.round, now, function(attacker, action, move, at, index, castAt)
        return Motion.strike(match, attacker, action, move, at, index, castAt)
    end, nil, nil, beforeBoundary)
    local changed = #match.round.notices > 0
    local playedFloor = {}
    for _, event in match.round.notices do
        Motion.impact(match, event)
        local attacker = match.actors[event.attacker]
        local side = match.round.sides[event.attacker]
        if attacker and side.playerHealth > 0 and not side.eliminated then
            Match.queueHitStop(attacker, attacker.kit, side.kit, event, attacker.motors, side.reaction)
        end
        local stormCue = Match.stormFeedback(event)
        if stormCue then
            setFeedback(attacker, stormCue, now)
            if stormCue ~= "talonDropMiss" then
                setFeedback(match.actors[event.defender], if stormCue == "talonCarry" then "talonCaught" else "hit", now)
            end
        elseif event.kind == "parried" or event.kind == "blocked" then
            setFeedback(attacker, if event.kind == "parried" then "attackParried" else "attackBlocked", now)
            setFeedback(match.actors[event.defender], if event.deflected then "projectileDeflected" else event.kind, now)
        elseif event.kind == "pull" then
            setFeedback(attacker, "gustPull", now)
            setFeedback(match.actors[event.defender], if event.frenzyResist then "frenzyResist" else "gustPull", now)
        elseif event.kind == "snare" then
            setFeedback(attacker, if event.attack == "apexPounce" then "apexRootCaught" else "snareCaught", now)
            setFeedback(match.actors[event.defender], if event.attack == "apexPounce" then "apexRooted" else "snared", now)
        elseif event.frenzyResist then
            setFeedback(attacker, event.kind, now)
            setFeedback(match.actors[event.defender], "frenzyResist", now)
        elseif event.shockDuration then
            setFeedback(attacker, "shockLanded", now)
            setFeedback(match.actors[event.defender], "shocked", now)
        elseif event.kind == "guardBroken" or event.kind == "burn" then
            setFeedback(attacker, event.kind, now)
            setFeedback(match.actors[event.defender], event.kind, now)
        elseif (event.damage or 0) > 0 then
            setFeedback(attacker, event.elementEffect or "strike", now)
            setFeedback(match.actors[event.defender], "hit", now)
        end
        local cue = Match.contactCue(event)
        local floorStrike = Match.floorAttack(event.attack)
        if cue and floorStrike and cue ~= "parried" and cue ~= "blocked" then
            -- One pressure ring per resolved ground pulse, even when several bodies are hit.
            local byAttacker = playedFloor[attacker]
            if not byAttacker then
                byAttacker = {}
                playedFloor[attacker] = byAttacker
            end
            if byAttacker[event.at] then
                cue = nil
            end
            byAttacker[event.at] = true
        end
        if cue then
            CombatPresentation.collect(match, cue, event.point, Match.effectAttack(event), event.at)
        end
    end
    table.clear(match.round.notices)
    return changed
end

local function collectExits(match, now, previousStage, leaving)
    local round = match.round
    local exits = if leaving and not round.result then {{index = leaving, reason = "left"}} else {}
    for index, actor in match.actors do
        if actor.returned then
            continue
        end
        local side = round.sides[index]
        if side.eliminated then
            if previousStage == nil and (Match.root(actor.player) ~= actor.root
                or not Motion.holdsKnockout(match, index, now)) then
                placeSpectator(match, index)
            end
        elseif not round.result then
            local root = Match.root(actor.player)
            if root ~= actor.root and previousStage == nil then
                table.insert(exits, {index = index, reason = "left"})
            elseif root == actor.root and now >= round.startsAt then
                local position = root.Position
                local unsupported = position.Y < floor + 1.12 and not match.floorActive(position)
                local ringout = if previousStage ~= nil then unsupported and onFloor(position, bounds.Position, previousStage)
                    else unsupported or position.Y < floor - 1.8 or not onFloor(position, bounds.Position, 0)
                if ringout then
                    table.insert(exits, {index = index, reason = "ringout"})
                end
            end
        end
    end
    return exits
end

local function advanceTimeline(match, now, leaving, departing)
    local round = match.round
    local deckChanged = false
    local dropAt = nextDropAt(round, match.stage)
    while not round.result and dropAt and dropAt <= now do
        -- Resolve committed contacts on the outgoing deck. The new floor owns the exact boundary.
        match.outgoingFloorAt = dropAt
        Motion.move(match, dropAt)
        match.outgoingFloorAt = nil
        if resolveContacts(match, dropAt, true) then
            Motion.render(match, dropAt, true)
            publish(match, "update", dropAt, departing)
        end
        if round.result then
            break
        end
        local previousStage = match.stage
        syncDeck(match, dropAt)
        if leaving and dropAt == now then
            -- An explicit exit and a deck loss observed at this instant share placements.
            Round.eliminateMany(round, collectExits(match, now, nil, leaving), now)
            leaving = nil
        else
            Round.eliminateMany(round, collectExits(match, dropAt, previousStage), dropAt)
        end
        deckChanged = true
        dropAt = nextDropAt(round, match.stage)
    end
    if not round.result and syncDeck(match, now) then
        deckChanged = true
    end
    local exits = collectExits(match, now, nil, leaving)
    local deferredCasts = {}
    Motion.move(match, now, deferredCasts)
    local earlierHit = false
    local eliminated = false
    if #exits > 0 or next(deferredCasts) then
        -- Preserve contacts strictly before the first observed exit. At the tie, the exit wins.
        earlierHit = resolveContacts(match, now, true)
        if earlierHit and #exits > 0 and not round.result then
            publish(match, "update", now, departing)
        end
        Motion.clearCasts(deferredCasts)
        eliminated = Round.eliminateMany(round, exits, now)
    end
    local hits = resolveContacts(match, now) or earlierHit
    return deckChanged or eliminated or hits, hits
end

local function leave(player, departing)
    unqueue(player, "You left the Brawl queue.")
    local match = active
    local index = match and match.sideFor[player]
    if index and not match.actors[index].returned then
        local now = workspace:GetServerTimeNow()
        local before = match.round.result
        local disconnected = if departing then player else nil
        if advanceTimeline(match, now, index, disconnected) then
            Motion.render(match, now)
            publish(match, "update", now, disconnected)
        end
        local round = match.round
        local result = before or (round.resolvedAt and round.resolvedAt < now and round.result)
        sendResult(match, index, if result then result.outcomes[index] else "left", departing)
    end
end

prompt.Triggered:Connect(function(player)
    if queue[player] then
        unqueue(player, "You left the Brawl queue.")
        return
    end
    local root = eligible(player, .4)
    if not root or active then
        remote:FireClient(player, "notice", if active then "A Brawl is underway. Join after it ends."
            else "Stand by the Brawl sign between activities to join.")
        return
    end
    local now = workspace:GetServerTimeNow()
    pruneQueue(now)
    queue[player] = {player = player, root = root, joinedAt = now, expiresAt = now + QUEUE_SECONDS}
    updateQueue()
    if queueCount() == SIZE then
        start(now)
    end
end)

remote.OnServerEvent:Connect(function(player, action, direction, id, windupToken)
    if action == "cancel" then
        unqueue(player, "You left the Brawl queue.")
        return
    end
    local match = active
    local index = match and match.sideFor[player]
    if not index or id ~= match.id or match.actors[index].returned then
        return
    elseif action == "leave" then
        leave(player)
        return
    elseif type(action) ~= "string" or not actionSet[action] then
        return
    end
    local now = workspace:GetServerTimeNow()
    local round, actor = match.round, match.actors[index]
    if round.result or round.sides[index].eliminated or now < round.startsAt
        or Match.root(player) ~= actor.root
        or not Match.takeCombatInput(actor, action, direction, now, .08) then
        return
    end
    local changed = advanceTimeline(match, now)
    if changed then
        Motion.render(match, now)
    end
    local side = round.sides[index]
    local previousClip = side.clip
    local feedback = if not round.result and Motion.canAct(match, index, action, now)
        then Round.act(round, index, action, now, Match.combatDirection(action, direction)) else nil
    Windup.decide(actor, side, round.startsAt, windupToken, previousClip, now, action)
    if feedback then
        setFeedback(actor, feedback, now)
    end
    if changed or feedback then
        publish(match, "update", now)
    end
end)

RunService.Heartbeat:Connect(function()
    local now = workspace:GetServerTimeNow()
    if now >= nextCourtCheck then
        nextCourtCheck = now + .5
        for _, player in Players:GetPlayers() do
            if not player:GetAttribute("BrawlActive") then
                local root = Match.root(player)
                local position = root and root.Position
                if position and math.abs(position.Y - floor) < 12
                    and math.abs(position.X - bounds.Position.X) < 42 and math.abs(position.Z - bounds.Position.Z) < 45 then
                    Match.move(root, cityReturn.CFrame)
                end
            end
        end
    end
    local match = active
    if not match then
        if next(queue) then
            pruneQueue(now)
        end
        return
    end
    local round = match.round
    local changed, hits = advanceTimeline(match, now)
    if round.result and now >= round.outroAt then
        if hits then
            Motion.render(match, now)
        end
        publish(match, "update", now)
        stop(match)
        return
    end
    Motion.render(match, now)
    if changed or now - match.lastPublish >= .13 then
        match.lastPublish = now
        publish(match, "update", now)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    leave(player, true)
end)
