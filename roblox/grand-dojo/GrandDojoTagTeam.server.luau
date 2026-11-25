local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Match = require(script.Parent:WaitForChild("DojoMatchSupport"))
local Motion = require(script.Parent:WaitForChild("DuelFightMotion"))
local Round = require(script.Parent:WaitForChild("TagCombatRound"))
local Equip = require(script.Parent:WaitForChild("StarterFighters"))
local fighterCatalog = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog"))
local FighterForms = require(ReplicatedStorage:WaitForChild("FighterForms"))
local CombatPresentation = require(ReplicatedStorage:WaitForChild("CombatPresentation"))
local catalog = fighterCatalog.ById
local remote = ReplicatedStorage:WaitForChild("GrandDojoTagTeam")
local effects = ReplicatedStorage:WaitForChild("GrandDojoSparring")

local ring = workspace:WaitForChild("Grand Dojo City"):WaitForChild("Fighting Ring")
local entry = ring:WaitForChild("Tag Team Entry")
local gate = entry:WaitForChild("Tag Team Queue")
local prompt = gate:WaitForChild("JoinTagTeamPrompt")
local cityReturn = entry:WaitForChild("Tag Team Return")
local court = ring:WaitForChild("Tag Team Court")
local bounds = court:WaitForChild("Bounds")
local floor = court:WaitForChild("Floor Origin").Position.Y
local viewing = court:WaitForChild("Spectator Return")
local marks = court:WaitForChild("Spawn Marks")

local SEATS, OFFER_SECONDS, QUEUE_SECONDS = 4, 20, 75
local matchId, nextCourtCheck = 0, 0
local offers, queue = {}, {}
local active
local actionSet = {strike = true, guard = true, heavy = true, uppercut = true, stormSteer = true,
    secondary = true, dodge = true, signature = true}
local colors = {Color3.fromRGB(134, 249, 206), Color3.fromRGB(255, 178, 117)}

local function notice(player, message)
    remote:FireClient(player, "notice", {message = message})
end

local function eligible(player, extraRange)
    local root = Match.root(player)
    local id = player:GetAttribute("SelectedStarterFighter")
    return player.Parent == Players and prompt.Enabled and Match.available(player) and not player:GetAttribute("DuelQueued")
        and not player:GetAttribute("BrawlQueued") and not player:GetAttribute("KilnbackRaidQueued")
        and catalog[id] and Match.FighterKits[id]
        and Match.near(root, gate, prompt.MaxActivationDistance + extraRange) and root
end

local function eligibleBackup(player, primaryId, id)
    local fighter = catalog[id]
    return id ~= primaryId and fighter and Match.FighterKits[id]
        and (player:GetAttribute("HighestFighterLevel") or 1) >= (fighter.unlockLevel or 1)
end

local function savedForm(player, fighterId)
    local encoded = player:GetAttribute("FighterRosterForms")
    if typeof(encoded) == "string" then
        local ok, equipped = pcall(HttpService.JSONDecode, HttpService, encoded)
        if ok and type(equipped) == "table" and FighterForms.get(fighterId, equipped[fighterId]) then
            return equipped[fighterId]
        end
    end
    return FighterForms.BaseId
end

local function queueCount()
    local count = 0
    for _ in queue do
        count += 1
    end
    return count
end

local function publishQueue(player, waiting, count, message)
    if player.Parent == Players then
        player:SetAttribute("TagTeamQueued", if waiting then true else nil)
        remote:FireClient(player, "queue", {queued = waiting ~= nil, count = count, required = SEATS,
            expiresAt = waiting and waiting.expiresAt, message = message})
    end
end

local function updateQueue()
    local count = queueCount()
    for player, waiting in queue do
        publishQueue(player, waiting, count)
    end
end

local function clearQueue(player, message)
    offers[player] = nil
    if queue[player] then
        queue[player] = nil
        publishQueue(player, nil, queueCount(), message)
        updateQueue()
    end
end

local function pruneQueue(now)
    local changed = false
    for player, waiting in queue do
        local reason
        if now >= waiting.expiresAt then
            reason = "Tag Team queue expired. Join again at the sign."
        elseif eligible(player, 4) ~= waiting.root
            or player:GetAttribute("SelectedStarterFighter") ~= waiting.primaryId then
            reason = "Stay near the Tag Team sign between activities."
        end
        if reason then
            queue[player] = nil
            publishQueue(player, nil, queueCount(), reason)
            changed = true
        end
    end
    if changed then
        updateQueue()
    end
    for player, offer in offers do
        if now >= offer.expiresAt then
            offers[player] = nil
        end
    end
end

local function publish(match, event, now)
    local round = match.round
    local snapshot = CombatPresentation.snapshot(match)
    local recipients = {}
    match.lastPublish = now
    local slots = {}
    for index, actor in match.actors do
        local seat, side = round.lineup[index], round.sides[index]
        local backup = seat.slots[3 - seat.active]
        slots[index] = {kitId = side.kitId, health = side.playerHealth, maxHealth = side.playerMaxHealth,
            backupKitId = backup.kitId, backupHealth = backup.playerHealth, backupMaxHealth = backup.playerMaxHealth,
            userName = actor.player.DisplayName, eliminated = seat.out == true, entryAt = seat.entryAt}
    end
    for index, actor in match.actors do
        local player = actor.player
        if not actor.returned and player.Parent == Players then
            local seat, side = round.lineup[index], round.sides[index]
            Match.syncStormAim(player, if not round.result and not side.eliminated then side else nil)
            remote:FireClient(player, event, {matchId = match.id, introAt = round.introAt, startsAt = round.startsAt,
                endsAt = round.endsAt, resolvedAt = round.resolvedAt, slots = slots, selfIndex = index,
                presentationSequence = snapshot.sequence, impacts = snapshot.impacts,
                hitStop = Match.takeHitStop(actor),
                focusIndex = actor.lastTarget,
                canTag = Round.planTag(round, index, now) ~= nil and not seat.entryAt,
                tagReadyAt = seat.nextTagAt, nextSignature = side.nextSignature, nextSecondary = side.nextSecondary,
                feedback = if now < actor.feedbackUntil then actor.feedback else nil})
            table.insert(recipients, player.UserId)
        end
    end
    CombatPresentation.broadcast(effects, snapshot, recipients)
end

local function kitEntry(id)
    return {fighter = catalog[id], kitId = Match.FighterKits[id]}
end

local function teamMarker(actor, parent, team)
    local marker = Instance.new("BillboardGui")
    marker.Name, marker.Adornee = "Tag Team marker", actor.root
    marker.Size, marker.StudsOffsetWorldSpace = UDim2.fromOffset(52, 18), Vector3.new(0, 3.9, 0)
    marker.MaxDistance, marker.LightInfluence = 38, 0
    local label = Instance.new("TextLabel")
    label.Size, label.Text = UDim2.fromScale(1, 1), if team == 1 then "JADE" else "EMBER"
    label.TextColor3, label.TextSize = colors[team], 11
    label.BackgroundColor3, label.BackgroundTransparency = Color3.fromRGB(38, 24, 27), .1
    label.Font, label.BorderSizePixel = Enum.Font.GothamBold, 0
    local radius = Instance.new("UICorner")
    radius.CornerRadius, radius.Parent = UDim.new(0, 5), label
    label.Parent, marker.Parent = marker, parent
    actor.marker = marker
end

local function start(now)
    local lineup = {}
    for _, waiting in queue do
        table.insert(lineup, waiting)
    end
    if #lineup ~= SEATS then
        return
    end
    table.sort(lineup, function(a, b)
        return a.joinedAt < b.joinedAt or (a.joinedAt == b.joinedAt and a.player.UserId < b.player.UserId)
    end)

    local actors, entrants, sideFor = {}, {}, {}
    for index, waiting in lineup do
        local player = waiting.player
        local primaryForm, backupForm = player:GetAttribute("SelectedFighterForm") or FighterForms.BaseId,
            savedForm(player, waiting.backupId)
        if not eligibleBackup(player, waiting.primaryId, waiting.backupId)
            or not Equip.canEquip(player.Character, waiting.primaryId, primaryForm)
            or not Equip.canEquip(player.Character, waiting.backupId, backupForm) then
            clearQueue(player, "Your fighters could not load. Rejoin the Tag Team queue.")
            return
        end
        actors[index] = {player = player, root = waiting.root, ids = {waiting.primaryId, waiting.backupId},
            forms = {primaryForm, backupForm}, nextInput = now, feedbackUntil = 0}
        entrants[index] = {primary = kitEntry(waiting.primaryId), backup = kitEntry(waiting.backupId)}
        sideFor[player] = index
    end
    matchId += 1
    local telegraph = Instance.new("Folder")
    telegraph.Name = "Tag Team attack tells"
    telegraph.Parent = court
    local round = Round.new(now, entrants)
    local match = {id = matchId, round = round, actors = actors, sideFor = sideFor, floor = floor, bounds = bounds,
        telegraph = telegraph, lastPublish = now}
    function match.enemies(a, b)
        return round.lineup[a].team ~= round.lineup[b].team
    end
    active = match
    table.clear(queue)
    table.clear(offers)
    for index, actor in actors do
        local player = actor.player
        player:SetAttribute("TagTeamQueued", nil)
        player:SetAttribute("TagTeamActive", true)
        player:SetAttribute("SparringActive", true)
        player:SetAttribute("ActiveDojoRing", "grand-dojo")
        Match.move(actor.root, marks["Seat " .. index].CFrame)
        teamMarker(actor, telegraph, round.lineup[index].team)
        task.spawn(function()
            pcall(function() player:RequestStreamAroundAsync(bounds.Position, 6) end)
        end)
    end
    Motion.open(match, true)
    Motion.render(match, now)
    publish(match, "begin", now)
end

local function feedback(actor, cue, now)
    actor.feedback, actor.feedbackUntil = cue, now + 1
end

local function swapFlash(match, position, team)
    local disk = Instance.new("Part")
    disk.Name, disk.Shape = "Tag entry ring", Enum.PartType.Cylinder
    disk.Anchored, disk.CanCollide, disk.CanQuery, disk.CanTouch = true, false, false, false
    disk.CastShadow, disk.Material, disk.Transparency = false, Enum.Material.Neon, .45
    disk.Color = colors[team]
    disk.CFrame = CFrame.new(position.X, floor + .05, position.Z) * CFrame.Angles(0, 0, math.pi / 2)
    disk.Size = Vector3.new(.04, 1.45, 1.45)
    disk.Parent = match.telegraph
    TweenService:Create(disk, TweenInfo.new(.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Transparency = 1, Size = Vector3.new(.04, 4.5, 4.5)}):Play()
    Debris:AddItem(disk, .36)
end

local function swap(match, index, now)
    local round, actor = match.round, match.actors[index]
    local slot = Round.planTag(round, index, now)
    if not slot or Match.root(actor.player) ~= actor.root then
        return false
    end
    local id = actor.ids[slot]
    if not Equip.canEquip(actor.root.Parent, id, actor.forms[slot]) then
        return false
    end
    local frame = actor.root.CFrame
    Motion.remove(match, index)
    local equipped = Equip.equip(actor.root.Parent, id, actor.forms[slot])
    local side, cue
    if equipped then
        side, cue = Round.swap(round, index, now, slot)
        if not side then
            local original = round.lineup[index].active
            Equip.equip(actor.root.Parent, actor.ids[original], actor.forms[original])
        end
    end
    Match.move(actor.root, frame)
    Motion.reopenActor(match, index, now)
    if not side then
        return false
    end
    Motion.render(match, now)
    swapFlash(match, frame.Position, round.lineup[index].team)
    feedback(actor, cue or "tagIn", now)
    return true
end

local function placeSpectator(match, index)
    local actor = match.actors[index]
    local root = Match.root(actor.player)
    Motion.remove(match, index)
    actor.marker.Enabled = false
    if root and actor.spectatorRoot ~= root then
        actor.spectatorRoot = root
        local position = viewing.Position + Vector3.new((index - 2.5) * 3, 0, 0)
        Match.move(root, CFrame.lookAt(position, Vector3.new(bounds.Position.X, position.Y, bounds.Position.Z)))
    end
end

local function finishPlayer(match, index, result, departing)
    local actor = match.actors[index]
    if actor.returned then
        return
    end
    actor.returned = true
    Motion.remove(match, index)
    actor.marker.Enabled = false
    local player = actor.player
    local root = Match.root(player)
    if root == actor.root then
        Equip.equip(root.Parent, actor.ids[1], actor.forms[1])
    end
    if departing or player.Parent ~= Players then
        return
    end
    player:SetAttribute("TagTeamActive", nil)
    player:SetAttribute("SparringActive", nil)
    player:SetAttribute("ActiveDojoRing", nil)
    if root then
        local column, row = (index - 1) % 2, math.floor((index - 1) / 2)
        local position = cityReturn.Position + Vector3.new((column - .5) * 2.6, 0, row * 2.7)
        Match.move(root, CFrame.lookAt(position, Vector3.new(gate.Position.X, position.Y, gate.Position.Z)))
    end
    local outcome = match.round.result
    remote:FireClient(player, "result", {matchId = match.id, result = result,
        presentationSequence = CombatPresentation.resultSequence(match),
        reason = outcome and outcome.reason, winningTeam = outcome and outcome.winningTeam})
end

local function stop(match)
    for index in match.actors do
        finishPlayer(match, index, match.round.result.outcomes[index])
    end
    Motion.close(match)
    match.telegraph:Destroy()
    active = nil
end

local function advance(match, now)
    Motion.move(match, now)
    Round.step(match.round, now, function(attacker, action, move, at, index, castAt)
        return Motion.strikeGroup(match, attacker, action, move, at, index, castAt)
    end)
    local changed = #match.round.notices > 0
    local floorCueAt = {}
    for _, event in match.round.notices do
        Motion.impact(match, event)
        local attacker = match.actors[event.attacker]
        local side = match.round.sides[event.attacker]
        if attacker and side.playerHealth > 0 and not side.eliminated then
            Match.queueHitStop(attacker, side.kitId, event, attacker.motors)
        end
        if event.defender and event.kind ~= "miss" and event.kind ~= "burn" then
            attacker.lastTarget = event.defender
            match.actors[event.defender].lastTarget = event.attacker
        end
        local stormCue = Match.stormFeedback(event)
        if stormCue then
            feedback(attacker, stormCue, now)
            if stormCue ~= "talonDropMiss" then
                feedback(match.actors[event.defender], if stormCue == "talonCarry" then "talonCaught" else "hit", now)
            end
        elseif event.kind == "blocked" or event.kind == "parried" then
            feedback(attacker, if event.kind == "blocked" then "attackBlocked" else "attackParried", now)
            feedback(match.actors[event.defender], if event.deflected then "projectileDeflected" else event.kind, now)
        elseif event.kind == "pull" then
            feedback(attacker, "gustPull", now)
            feedback(match.actors[event.defender], if event.frenzyResist then "frenzyResist" else "gustPull", now)
        elseif event.kind == "snare" then
            feedback(attacker, if event.attack == "apexPounce" then "apexRootCaught" else "snareCaught", now)
            feedback(match.actors[event.defender], if event.attack == "apexPounce" then "apexRooted" else "snared", now)
        elseif event.frenzyResist then
            feedback(attacker, event.kind, now)
            feedback(match.actors[event.defender], "frenzyResist", now)
        elseif event.shockDuration then
            feedback(attacker, "shockLanded", now)
            feedback(match.actors[event.defender], "shocked", now)
        elseif event.kind == "guardBroken" or event.kind == "burn" then
            feedback(attacker, event.kind, now)
            feedback(match.actors[event.defender], event.kind, now)
        elseif (event.damage or 0) > 0 then
            feedback(attacker, if event.tagEntry then "tagStrike" else "strike", now)
            feedback(match.actors[event.defender], "hit", now)
        end
        local cue = Match.contactCue(event)
        if cue and Match.floorAttack(event.attack)
            and cue ~= "parried" and cue ~= "blocked" then
            if floorCueAt[event.attacker] == event.at then
                cue = nil
            else
                floorCueAt[event.attacker] = event.at
            end
        end
        if cue then
            CombatPresentation.collect(match, cue, event.point, Match.effectAttack(event), event.at)
        end
    end
    table.clear(match.round.notices)
    return changed
end

local function leave(player, departing)
    clearQueue(player, "You left the Tag Team queue.")
    local match = active
    local index = match and match.sideFor[player]
    if index and not match.actors[index].returned then
        Round.eliminateMany(match.round, {{index = index, reason = "left"}}, workspace:GetServerTimeNow())
        finishPlayer(match, index, "left", departing)
    end
end

local function settleSeats(match, now)
    local changed, exits = false, {}
    local round = match.round
    for index, actor in match.actors do
        if actor.returned then
            continue
        end
        local seat, side = round.lineup[index], round.sides[index]
        local root = Match.root(actor.player)
        if root ~= actor.root then
            table.insert(exits, {index = index, reason = "left"})
            if not round.result then
                changed = true
            end
        elseif not round.result and seat.entryAt and now >= seat.entryAt then
            if swap(match, index, now) then
                changed = true
            else
                table.insert(exits, {index = index, reason = "left"})
                changed = true
            end
        elseif seat.out then
            if not Motion.holdsKnockout(match, index, now) then
                placeSpectator(match, index)
            end
        elseif not round.result and not side.eliminated and not Match.inside(bounds, root.Position) then
            local at = Match.clampFloor(bounds, root.Position, floor + 2.3)
            Match.move(root, CFrame.new(at) * root.CFrame.Rotation)
        end
    end
    if #exits > 0 then
        Round.eliminateMany(round, exits, now)
        for _, exit in exits do
            finishPlayer(match, exit.index, "left")
        end
    end
    return changed
end

prompt.Triggered:Connect(function(player)
    if queue[player] then
        clearQueue(player, "You left the Tag Team queue.")
        return
    end
    local root = eligible(player, .4)
    if not root or active then
        notice(player, if active then "A Tag Team match is underway." else "Stand by the Tag Team sign between activities.")
        return
    end
    local now = workspace:GetServerTimeNow()
    local offer = {root = root, primaryId = player:GetAttribute("SelectedStarterFighter"), expiresAt = now + OFFER_SECONDS}
    offers[player] = offer
    local backupIds = {}
    for _, id in fighterCatalog.Order do
        if eligibleBackup(player, offer.primaryId, id) then
            table.insert(backupIds, id)
        end
    end
    remote:FireClient(player, "offer", {primaryId = offer.primaryId, expiresAt = offer.expiresAt, backupIds = backupIds})
end)

remote.OnServerEvent:Connect(function(player, action, value, id)
    local now = workspace:GetServerTimeNow()
    if action == "cancel" then
        clearQueue(player, "You left the Tag Team queue.")
        return
    elseif action == "join" then
        local offer, root = offers[player], eligible(player, .75)
        if active or not offer or now >= offer.expiresAt or not root or root ~= offer.root
            or player:GetAttribute("SelectedStarterFighter") ~= offer.primaryId then
            notice(player, "Use the Tag Team sign again to choose your backup.")
            return
        elseif type(value) ~= "string" or not eligibleBackup(player, offer.primaryId, value) then
            notice(player, "Choose a different fighter as your backup.")
            return
        end
        pruneQueue(now)
        offers[player] = nil
        queue[player] = {player = player, root = root, primaryId = offer.primaryId, backupId = value, joinedAt = now,
            expiresAt = now + QUEUE_SECONDS}
        updateQueue()
        if queueCount() == SEATS then
            start(now)
        end
        return
    end

    local match = active
    local index = match and match.sideFor[player]
    if not index or id ~= match.id or match.actors[index].returned then
        return
    elseif action == "leave" then
        leave(player)
        return
    end
    if action ~= "tag" and (type(action) ~= "string" or not actionSet[action]) then
        return
    end
    local round, actor = match.round, match.actors[index]
    if round.result or now < round.startsAt or Match.root(player) ~= actor.root
        or not Motion.canAct(match, index, action, now) or not Match.takeCombatInput(actor, action, value, now, .08) then
        return
    end
    if advance(match, now) then
        -- Show the outgoing fighter's reaction and HP before a manual swap replaces that slot.
        Motion.render(match, now)
        publish(match, "update", now)
    end
    local changed = false
    if action == "tag" then
        if swap(match, index, now) then
            changed = true
        elseif not round.result then
            feedback(actor, "tagUnavailable", now)
            changed = true
        end
    else
        local cue = Round.act(round, index, action, now, Match.combatDirection(action, value))
        if cue then
            feedback(actor, cue, now)
            changed = true
        end
    end
    if changed then
        publish(match, "update", now)
    end
end)

RunService.Heartbeat:Connect(function()
    local now = workspace:GetServerTimeNow()
    if now >= nextCourtCheck then
        nextCourtCheck = now + .5
        for _, player in Players:GetPlayers() do
            if not player:GetAttribute("TagTeamActive") then
                local root = Match.root(player)
                local offset = root and (root.Position - bounds.Position)
                if offset and math.abs(offset.Y) < 12 and math.abs(offset.X) < 42 and math.abs(offset.Z) < 44 then
                    Match.move(root, cityReturn.CFrame)
                end
            end
        end
        if not active then
            pruneQueue(now)
        end
    end
    local match = active
    if not match then
        return
    end
    if advance(match, now) then
        -- A late frame can resolve a hit and cross the forced entry or outro time.
        Motion.render(match, now)
        publish(match, "update", now)
    end
    local transitioned = settleSeats(match, now)
    if match.round.result and now >= match.round.outroAt then
        stop(match)
        return
    end
    Motion.render(match, now)
    if transitioned or now - match.lastPublish >= .13 then
        publish(match, "update", now)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    leave(player, true)
end)
