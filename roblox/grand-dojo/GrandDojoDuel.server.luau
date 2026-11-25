local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Match = require(script.Parent:WaitForChild("DojoMatchSupport"))
local Round = require(script.Parent:WaitForChild("DuelCombatRound"))
local Series = require(script.Parent:WaitForChild("DuelSeries"))
local Motion = require(script.Parent:WaitForChild("DuelFightMotion"))
local Windup = require(script.Parent:WaitForChild("CombatWindupSupport"))
local RankRules = require(script.Parent:WaitForChild("DuelRankRules"))
local RankLedger = require(script.Parent:WaitForChild("DuelRankLedger"))
local Presentation = require(ReplicatedStorage:WaitForChild("CombatPresentation"))
local FighterTactics = require(ReplicatedStorage:WaitForChild("FighterTactics"))
local FighterLoadouts = require(ReplicatedStorage:WaitForChild("FighterLoadouts"))
local studio = RunService:IsStudio()
local transport = require(script.Parent:WaitForChild("DuelTransportRuntime")).get(studio)
local arenaDriver, sourceQueue, cityReturn
local rankStore = if studio then RankLedger.memoryStore()
    else DataStoreService:GetDataStore("BeastDojoDuelRatingsV1")
local ledger = RankLedger.new(rankStore, os.time, task.wait)
local fighters = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog")).ById
local remote = ReplicatedStorage:WaitForChild("GrandDojoDuel")
local effects = ReplicatedStorage:WaitForChild("GrandDojoSparring")
local court = workspace:WaitForChild("Grand Dojo City"):WaitForChild("Fighting Ring"):WaitForChild("Duel Court")
local bounds = court:WaitForChild("Duel Bounds")
local entry = court:WaitForChild("Duel Queue")
local prompt = entry:WaitForChild("JoinDuelPrompt")
local spawns = {court:WaitForChild("First Spawn"), court:WaitForChild("Second Spawn")}
local returns = {court:WaitForChild("First Return"), court:WaitForChild("Second Return")}
local floor = bounds.Position.Y - bounds.Size.Y * .5

local OFFER_SECONDS, QUEUE_SECONDS, PREPARE_SECONDS = 12, 55, 16
local OUTSIDE_GRACE = 1.65
local formatLabels = {casual = "Casual", series = "Best of 3", ranked = "Ranked"}

local actions = {strike = true, guard = true, heavy = true, uppercut = true, secondary = true, stormSteer = true,
    dodge = true, signature = true}
local tells = {
    jab = "Jab", cross = "Cross", body = "Body strike", heavy = "Heavy strike",
    reedstep = "Reedstep Rising", bellySlide = "Belly-Slide Blitz",
    seismicChestPound = "Seismic Chest-Pound", magmaTrail = "Magma Trail",
}
for _, group in FighterTactics.ByKit do
    for _, option in group.options do
        tells[option.id] = option.name
    end
end
for _, loadout in FighterLoadouts.ByKit do
    for _, slot in {loadout.basic, loadout.ultimate} do
        for _, option in slot.options do
            if option.id ~= slot.default then
                tells[option.id] = option.name
            end
        end
    end
end
local resultMessages = {
    win = "You won the duel.",
    loss = "Your opponent won the duel.",
    draw = "The duel ended in a draw.",
    left = "You left the duel.",
    outside = "You left the mat.",
}

local offers, queues, joins = {}, {}, {}
local rankOperations = {}
local studioRankIds, nextStudioRankId = {}, 0
local pendingSettlements, shuttingDown = 0, false
local active, preparing
local nextMatchId, nextSearchAt = 0, 0

local function notice(player, text)
    remote:FireClient(player, "notice", text)
end

local function notifyQueue(entry, queued, message)
    local player = entry.player
    if player.Parent == Players then
        player:SetAttribute("DuelQueued", if queued then true else nil)
        remote:FireClient(player, "queue", {queued = queued, expiresAt = entry.expiresAt,
            format = entry.format, message = message})
    end
end

local function clearQueue(player, message)
    local waiting = queues[player]
    if waiting then
        queues[player] = nil
        notifyQueue(waiting, false, message)
    end
end

local function updateWaiting(entry)
    local label = formatLabels[entry.format]
    notifyQueue(entry, true, if active or preparing then label .. " queue · Court in use."
        else "Waiting for a " .. label .. " opponent.")
end

local function updateQueues()
    for _, waiting in queues do
        updateWaiting(waiting)
    end
end

local function rankStatus(player, status, points)
    if player.Parent == Players then
        if points ~= nil then
            player:SetAttribute("DuelRankPoints", points)
            player:SetAttribute("DuelRankDivision", RankRules.divisionName(points))
        end
        player:SetAttribute("DuelRankStatus", status)
    end
end

local function rankUserId(player)
    local userId = player.UserId
    if not studio then return userId end

    -- Local Studio users include negative IDs. Keep stable, unique keys in this server's memory ledger.
    if not studioRankIds[userId] then
        nextStudioRankId += 1
        studioRankIds[userId] = nextStudioRankId
    end
    return studioRankIds[userId]
end

local function readRank(player)
    if rankOperations[player.UserId] then
        return nil
    end
    rankOperations[player.UserId] = true
    rankStatus(player, "loading")
    local profile, reason = ledger:read(rankUserId(player))
    rankOperations[player.UserId] = nil
    rankStatus(player, if profile then "ready" elseif reason == "pending" then "pending" else "unavailable",
        profile and profile.points)
    return profile
end

local function closeOffer(player, announce)
    local offer = offers[player]
    if offer then
        offers[player] = nil
        if announce then
            remote:FireClient(player, "offerClosed", {expiresAt = offer.expiresAt})
        end
    end
end

local function eligible(player, extraRange)
    local root = Match.root(player)
    local id = player:GetAttribute("SelectedStarterFighter")
    return player.Parent == Players and prompt.Enabled and Match.available(player)
        and not player:GetAttribute("BrawlQueued") and not player:GetAttribute("TagTeamQueued")
        and not player:GetAttribute("KilnbackRaidQueued")
        and Match.FighterKits[id] ~= nil and fighters[id] ~= nil
        and Match.near(root, entry, prompt.MaxActivationDistance + extraRange) and root
end

local function actor(player, root)
    local id = player:GetAttribute("SelectedStarterFighter")
    local kit = Match.FighterKits[id]
    return {player = player, root = root, kit = kit, fighter = fighters[id], loadout = Match.loadout(player, kit),
        nextInput = 0, feedbackUntil = 0}
end

local function score(duel, side, payload)
    local series = duel.series
    payload.format, payload.matchId = series.format, duel.matchId
    payload.roundIndex, payload.maxRounds = series.roundIndex, series.maxRounds
    payload.playerRounds, payload.opponentRounds = series.wins[side], series.wins[3 - side]
    payload.roundResult = if series.roundResult then series.roundResult[side] else nil
    return payload
end

local function publish(duel, kind, now, departing)
    local round = duel.round
    local snapshot = Presentation.snapshot(duel)
    local recipients = {}
    for i, side in round.sides do
        local challenger, opponent = duel.actors[i], duel.actors[3 - i]
        if challenger.player == departing or challenger.player.Parent ~= Players then
            continue
        end
        table.insert(recipients, challenger.player.UserId)
        Match.syncStormAim(challenger.player, if not round.result then side else nil)
        local rival = round.sides[3 - i]
        local opensAt, attackAt, attack = Round.parryOpensAt(round, i)
        remote:FireClient(challenger.player, kind, score(duel, i, {
            presentationSequence = snapshot.sequence, impacts = snapshot.impacts,
            hitStop = Match.takeHitStop(challenger),
            playerHealth = side.playerHealth, playerMaxHealth = side.playerMaxHealth,
            opponentHealth = rival.playerHealth, opponentMaxHealth = rival.playerMaxHealth,
            opponentName = opponent.player.DisplayName, opponentUserId = opponent.player.UserId, sideIndex = i,
            kitId = challenger.kit, opponentKitId = opponent.kit, tactical = side.tactical,
            basic = side.basic, ultimate = side.ultimate,
            introAt = round.introAt, startsAt = round.startsAt, endsAt = round.endsAt,
            phase = if round.result then "outro" elseif attackAt then "windup" else "ready",
            attackAt = attackAt, parryOpensAt = opensAt, tell = tells[attack],
            nextSignature = side.nextSignature, nextSecondary = side.nextSecondary,
            feedback = if now < challenger.feedbackUntil then challenger.feedback else nil,
            elementEffect = if now < challenger.feedbackUntil then challenger.elementEffect else nil,
        }))
        if not round.result then
            Windup.profile(challenger, side, challenger.motors, round.startsAt, round.endsAt)
        end
    end
    Presentation.broadcast(effects, snapshot, recipients)
end

local function startRound(duel, now)
    if duel.round then
        Motion.close(duel)
    end
    local a, b = table.clone(duel.lineup[1]), table.clone(duel.lineup[2])
    duel.actors = {a, b}
    duel.round = Round.new(now, a.fighter, a.kit, b.fighter, b.kit, Series.timing(duel.series),
        duel.series.format == "ranked", a.loadout or a.tactical, b.loadout or b.tactical)
    duel.lastUpdate = now
    for i, side in duel.actors do
        Match.move(side.root, spawns[i].CFrame)
    end
    Motion.open(duel)
    Motion.render(duel, now)
    publish(duel, if duel.series.roundIndex == 1 then "begin" else "round", now)
end

local function begin(format, first, firstRoot, second, secondRoot, now, ticket, assignmentId)
    clearQueue(first)
    clearQueue(second)
    local telegraph = Instance.new("Folder")
    telegraph.Name = "Duel attack tells"
    telegraph.Parent = court
    nextMatchId += 1
    local lineup = {actor(first, firstRoot), actor(second, secondRoot)}
    local duel = {series = Series.new(format), matchId = nextMatchId, lineup = lineup, rankTicket = ticket,
        bounds = bounds, floor = floor, telegraph = telegraph, assignmentId = assignmentId}
    active = duel
    for _, side in lineup do
        side.player:SetAttribute("DuelActive", true)
        side.player:SetAttribute("SparringActive", true)
        side.player:SetAttribute("ActiveDojoRing", "grand-dojo")
    end
    startRound(duel, now)
    updateQueues()
end

local function settleRank(duel, result, counts)
    if not duel.rankTicket then
        return
    end
    local ticket, matchId = duel.rankTicket, duel.matchId
    pendingSettlements += 1
    for _, side in duel.actors do
        rankOperations[side.player.UserId] = ticket
        rankStatus(side.player, "pending")
    end
    task.spawn(function()
        local reports, reason
        if counts then
            local firstScore = if result[1] == "win" then 1 elseif result[2] == "win" then 0 else .5
            for _, delay in {0, 1, 3, 8, 16} do
                if delay > 0 then
                    task.wait(delay)
                end
                reports, reason = ledger:commit(ticket, firstScore)
                if reports or (reason ~= "pending" and reason ~= "unavailable") then
                    break
                end
            end
        else
            ledger:cancel(ticket)
        end
        for index, side in duel.actors do
            local player = side.player
            rankOperations[player.UserId] = nil
            if counts and player.Parent == Players then
                local report = reports and reports[index]
                local status = if report then "saved" elseif reason == "pending" then "pending" else "unavailable"
                rankStatus(player, if report then "ready" else status, report and report.after)
                remote:FireClient(player, "rating", {matchId = matchId, status = status,
                    before = report and report.before, after = report and report.after,
                    delta = report and report.delta, division = report and RankRules.divisionName(report.after)})
            elseif player.Parent == Players then
                task.spawn(readRank, player)
            end
        end
        pendingSettlements -= 1
    end)
end

local function stop(duel, result, departing, walkover)
    active = nil
    local counts = duel.rankTicket ~= nil and (duel.series.roundIndex > 1
        or workspace:GetServerTimeNow() >= duel.round.startsAt)
    Motion.close(duel)
    duel.telegraph:Destroy()
    local sequence = Presentation.resultSequence(duel)
    for i, side in duel.actors do
        local player = side.player
        if player ~= departing and player.Parent == Players then
            player:SetAttribute("DuelActive", nil)
            player:SetAttribute("SparringActive", nil)
            player:SetAttribute("ActiveDojoRing", nil)
            if Match.root(player) == side.root then
                Match.move(side.root, returns[i].CFrame)
            end
            local message = if walkover and result[i] == "win" then "Your opponent left the duel." else resultMessages[result[i]]
            remote:FireClient(player, "result", score(duel, i, {result = result[i], message = message,
                opponentName = duel.actors[3 - i].player.DisplayName, ratingPending = counts,
                presentationSequence = sequence, crossServer = if duel.assignmentId then true else nil}))
        end
    end
    settleRank(duel, result, counts)
    updateQueues()
    if duel.assignmentId and arenaDriver then
        for _, side in duel.actors do
            if side.player ~= departing and side.player.Parent == Players then cityReturn:offer(side.player, 4) end
        end
        task.spawn(function()
            for _ = 1, 3 do
                local record, reason = arenaDriver:finish(duel.assignmentId)
                if record then arenaDriver:cleanupTickets(record) return end
                if reason ~= "unavailable" then return end
                task.wait(.4)
            end
        end)
    end
end

local function setFeedback(side, feedback, now, elementEffect)
    side.feedback, side.feedbackUntil = feedback, now + .82
    side.elementEffect = elementEffect
end

local function onMat(side)
    return Match.root(side.player) == side.root and Match.inside(bounds, side.root.Position)
end

local function resolve(duel, now, beforeExit)
    local round = duel.round
    Round.step(round, now, function(attacker, _, action, move, at, index, castStartedAt)
        return Motion.strike(duel, attacker, action, move, at, index, castStartedAt)
    end, beforeExit)
    local ended = round.result and not duel.series.roundResult
    if ended then
        Series.record(duel.series, round.result)
        -- Give every series round its recap even if the server ran a late frame.
        if duel.series.format ~= "casual" then
            round.outroAt = now + Round.OUTRO
        end
    end
    for _, event in round.notices do
        Motion.impact(duel, event)
        local a, b = duel.actors[event.attacker], duel.actors[event.defender]
        local side = round.sides[event.attacker]
        if a and side.playerHealth > 0 then
            Match.queueHitStop(a, a.kit, side.kit, event, a.motors, side.reaction)
        end
        local kind = event.kind
        local stormCue = Match.stormFeedback(event)
        if stormCue then
            setFeedback(a, stormCue, now, event.elementEffect)
            if stormCue ~= "talonDropMiss" then
                setFeedback(b, if stormCue == "talonCarry" then "talonCaught" else "hit", now)
            end
        elseif kind == "parried" or kind == "blocked" then
            setFeedback(a, if kind == "parried" then "attackParried" else "attackBlocked", now)
            setFeedback(b, if event.deflected then "projectileDeflected" else kind, now)
        elseif kind == "pull" then
            setFeedback(a, "gustPull", now)
            setFeedback(b, if event.frenzyResist then "frenzyResist" else "gustPull", now)
        elseif kind == "snare" then
            setFeedback(a, if event.attack == "apexPounce" then "apexRootCaught" else "snareCaught", now)
            setFeedback(b, if event.attack == "apexPounce" then "apexRooted" else "snared", now)
        elseif event.frenzyResist then
            setFeedback(a, kind, now, event.elementEffect)
            setFeedback(b, "frenzyResist", now)
        elseif event.shockDuration then
            setFeedback(a, "shockLanded", now, event.elementEffect)
            setFeedback(b, "shocked", now)
        elseif kind == "guardBroken" or kind == "burn" then
            setFeedback(a, kind, now, event.elementEffect)
            setFeedback(b, kind, now)
        elseif event.damage and event.damage > 0 then
            setFeedback(a, kind, now, event.elementEffect)
            setFeedback(b, "hit", now)
        elseif event.attack ~= "magmaTrail" then
            setFeedback(a, kind, now)
        end
        local cue = Match.contactCue(event)
        if cue then
            Presentation.collect(duel, cue, event.point, Match.effectAttack(event), event.at)
        end
    end
    local changed = #round.notices > 0
    table.clear(round.notices)
    return ended or changed
end

local function advance(duel, now)
    Motion.move(duel, now)
    return resolve(duel, now)
end

local function forfeit(duel, index, reason, departing)
    local first, second = duel.actors[1], duel.actors[2]
    if not duel.round.result and Match.root(first.player) == first.root and Match.root(second.player) == second.root then
        -- Resolve earlier contacts from recorded positions before settling the exit.
        local now = workspace:GetServerTimeNow()
        if resolve(duel, now, true) then
            publish(duel, "update", now, departing)
        end
    end
    if duel.series.result then
        stop(duel, duel.series.result, departing)
        return
    end
    local result = {"win", "win"}
    result[index] = reason
    stop(duel, result, departing, true)
end

local function endPreparation(attempt, message)
    if preparing ~= attempt then
        return
    end
    preparing = nil
    for _, entry in attempt.entries do
        notifyQueue(entry, false, message)
    end
    updateQueues()
end

local function prepareRanked(first, second, now)
    local attempt = {entries = {first, second}, expiresAt = now + PREPARE_SECONDS}
    preparing = attempt
    for _, entry in attempt.entries do
        queues[entry.player] = nil
        rankOperations[entry.player.UserId] = attempt
        rankStatus(entry.player, "loading")
        notifyQueue(entry, true, "Preparing Ranked Duel.")
    end
    updateQueues()
    task.spawn(function()
        local firstId, secondId = rankUserId(first.player), rankUserId(second.player)
        local ticket = ledger:reserve(HttpService:GenerateGUID(false), firstId, secondId)
        local currentTime = workspace:GetServerTimeNow()
        local allowed = preparing == attempt and not shuttingDown and currentTime < attempt.expiresAt
            and eligible(first.player, 3.25) == first.root and eligible(second.player, 3.25) == second.root
        local eligiblePair = ticket and math.abs(ticket.before[1] - ticket.before[2])
            <= RankRules.matchRange(currentTime - first.joinedAt)
        if allowed and eligiblePair then
            endPreparation(attempt)
            for index, entry in attempt.entries do
                rankOperations[entry.player.UserId] = nil
                rankStatus(entry.player, "ready", ticket.before[index])
            end
            begin("ranked", first.player, first.root, second.player, second.root, currentTime, ticket)
            return
        end
        endPreparation(attempt, if ticket then "Ranked pairing expired. Join again at the sign."
            else "Ranked ratings are unavailable. You can still choose Casual or Best of 3.")
        if ticket then
            ledger:cancel(ticket)
        end
        for _, entry in attempt.entries do
            rankOperations[entry.player.UserId] = nil
            if not shuttingDown and entry.player.Parent == Players then
                task.spawn(readRank, entry.player)
            end
        end
    end)
end

local function tryMatch(now)
    if active or preparing or shuttingDown then
        return
    end
    local candidates = {}
    for _, entry in queues do
        if entry.expiresAt > now and eligible(entry.player, 3.25) == entry.root then
            table.insert(candidates, entry)
        end
    end
    table.sort(candidates, function(a, b)
        return a.joinedAt < b.joinedAt or (a.joinedAt == b.joinedAt and a.player.UserId < b.player.UserId)
    end)
    for i, first in candidates do
        for j = i + 1, #candidates do
            local second = candidates[j]
            if first.format ~= second.format then
                continue
            end
            if first.format ~= "ranked" then
                begin(first.format, first.player, first.root, second.player, second.root, now)
                return
            elseif math.abs(first.points - second.points) <= RankRules.matchRange(now - first.joinedAt) then
                prepareRanked(first, second, now)
                return
            end
        end
    end
end

local function cancelEntry(player)
    if sourceQueue and sourceQueue:cancel(player) then closeOffer(player, true) return end
    joins[player] = nil
    clearQueue(player, "You left the duel queue.")
    closeOffer(player, true)
    if preparing then
        for _, entry in preparing.entries do
            if entry.player == player then
                endPreparation(preparing, "Ranked pairing cancelled. You can rejoin at the sign.")
                break
            end
        end
    end
end

prompt.Triggered:Connect(function(player)
    if queues[player] or (sourceQueue and sourceQueue:owns(player)) then
        cancelEntry(player)
        return
    end
    local root = eligible(player, .4)
    if not root then
        notice(player, "Stand by the queue sign between activities to join a duel.")
        return
    elseif shuttingDown or ((active or preparing) and not sourceQueue) then
        notice(player, "A duel is underway. This court opens when it ends.")
        return
    end
    local now = workspace:GetServerTimeNow()
    local current = offers[player]
    local expiresAt = if current and current.root == root and now < current.expiresAt
        then current.expiresAt else now + OFFER_SECONDS
    offers[player] = {root = root, expiresAt = expiresAt, across = sourceQueue ~= nil}
    remote:FireClient(player, "offer", {expiresAt = expiresAt, across = if sourceQueue then true else nil})
end)

local function enqueue(player, root, format, now, points)
    queues[player] = {player = player, root = root, format = format, joinedAt = now,
        expiresAt = now + QUEUE_SECONDS, points = points}
    updateWaiting(queues[player])
    tryMatch(now)
end

local function joinQueue(player, format)
    local offer = offers[player]
    local across = format == "crossCasual" and sourceQueue and offer and offer.across
    if not offer or (not across and not Series.supports(format)) or queues[player] or joins[player]
        or (sourceQueue and sourceQueue:owns(player)) then
        return
    end
    closeOffer(player, true)
    local now = workspace:GetServerTimeNow()
    local root = eligible(player, .4)
    if root ~= offer.root or now >= offer.expiresAt then
        notice(player, "Stand by the sign and choose a duel again.")
        return
    elseif across and not shuttingDown then
        local accepted, message = sourceQueue:enroll(player, root)
        if not accepted then notice(player, message) end
        return
    elseif active or preparing or shuttingDown then
        notice(player, "A duel is underway. This court opens when it ends.")
        return
    elseif format ~= "ranked" then
        enqueue(player, root, format, now)
        return
    elseif rankOperations[player.UserId] then
        notice(player, "Your last Ranked result is still being checked.")
        return
    end
    joins[player] = offer
    notice(player, "Loading your Rank Points.")
    task.spawn(function()
        local profile = readRank(player)
        if joins[player] ~= offer then
            return
        end
        joins[player] = nil
        local joinedAt = workspace:GetServerTimeNow()
        if player.Parent ~= Players then
            return
        elseif not profile then
            notice(player, "Ranked ratings are unavailable. You can still choose Casual or Best of 3.")
        elseif joinedAt > now + PREPARE_SECONDS or eligible(player, .4) ~= root or shuttingDown then
            notice(player, "Stand by the sign and choose Ranked again.")
        else
            enqueue(player, root, format, joinedAt, profile.points)
        end
    end)
end

remote.OnServerEvent:Connect(function(player, action, direction, matchId, roundIndex, windupToken)
    if type(action) ~= "string" then
        return
    end
    if action == "join" then
        joinQueue(player, direction)
        return
    elseif action == "cancel" then
        cancelEntry(player)
        return
    elseif action == "returnCity" then
        if cityReturn then cityReturn:retry(player) end
        return
    elseif action ~= "leave" and not actions[action] then
        return
    end
    local duel = active
    if not duel then
        return
    end
    local index = if duel.actors[1].player == player then 1 elseif duel.actors[2].player == player then 2 else nil
    if not index then
        return
    end
    if (duel.series.format ~= "casual" or matchId ~= nil) and matchId ~= duel.matchId then
        return
    end
    if action == "leave" then
        forfeit(duel, index, "left")
        return
    elseif (duel.series.format ~= "casual" or roundIndex ~= nil) and roundIndex ~= duel.series.roundIndex then
        return
    end
    local now = workspace:GetServerTimeNow()
    local side = duel.actors[index]
    if now < duel.round.startsAt or duel.round.result or not onMat(side)
        or not Motion.canAct(duel, index, action) or not Match.takeCombatInput(side, action, direction, now, .08) then
        return
    end
    for participant, actor in duel.actors do
        if Match.root(actor.player) ~= actor.root then
            forfeit(duel, participant, "left")
            return
        end
    end
    -- A new input must not replace an earlier contact still due after a long frame.
    local changed = advance(duel, now)
    if changed then
        Motion.render(duel, now)
    end
    local round = duel.round
    local combatant = round.sides[index]
    local previousClip = combatant.clip
    local feedback = if not round.result
        then Round.act(round, index, action, now, Match.combatDirection(action, direction)) else nil
    Windup.decide(side, combatant, round.startsAt, windupToken, previousClip, now, action)
    if feedback then
        setFeedback(side, feedback, now)
    end
    if changed or feedback then
        duel.lastUpdate = now
        publish(duel, "update", now)
    end
end)

RunService.Heartbeat:Connect(function()
    local now = workspace:GetServerTimeNow()
    for player, offer in offers do
        if now >= offer.expiresAt then
            closeOffer(player, true)
        end
    end
    for player, waiting in queues do
        if now >= waiting.expiresAt then
            clearQueue(player, "Duel queue expired. Join again at the sign.")
        elseif eligible(player, 3.25) ~= waiting.root then
            clearQueue(player, "Duel queue closed. Stay near the sign while waiting.")
        end
    end
    if preparing and now >= preparing.expiresAt then
        endPreparation(preparing, "Ranked pairing took too long. Join again at the sign.")
    end
    if now >= nextSearchAt then
        nextSearchAt = now + .5
        tryMatch(now)
    end
    local duel = active
    if not duel then
        return
    end
    for i, side in duel.actors do
        if Match.root(side.player) ~= side.root then
            forfeit(duel, i, "left")
            return
        end
        if not onMat(side) then
            side.outsideAt = side.outsideAt or now
            if now - side.outsideAt > OUTSIDE_GRACE then
                forfeit(duel, i, "outside")
                return
            end
        else
            side.outsideAt = nil
        end
    end
    local changed = advance(duel, now)
    if duel.round.result and now >= duel.round.outroAt then
        if changed then
            Motion.render(duel, now)
            publish(duel, "update", now)
        end
        if duel.series.result then
            stop(duel, duel.series.result)
        elseif Series.nextRound(duel.series) then
            startRound(duel, now)
        end
        return
    end
    Motion.render(duel, now)
    if changed or now - duel.lastUpdate >= .10 then
        duel.lastUpdate = now
        publish(duel, "update", now)
    end
end)

if transport then
    local SourceQueue = require(script.Parent.DuelSourceQueue)
    local CityReturn = require(script.Parent.DuelCityReturn)
    local function present(player) return player.Parent == Players and not shuttingDown end
    local function guid() return HttpService:GenerateGUID(false) end
    local function stageRoot(player, paused)
        if not present(player) or not prompt.Enabled then return nil end
        if not paused then return eligible(player, 3.25) end
        local root = Match.root(player)
        return Match.near(root, entry, prompt.MaxActivationDistance + 3.25) and root or nil
    end
    local function preparedRoot(player)
        local id = player:GetAttribute("SelectedStarterFighter")
        if present(player) and not active and not preparing and transport.profiles:arenaReady(player)
            and player:GetAttribute("DuelTransferHold")
            and (player:GetAttribute("ProgressStatus") == "ready" or player:GetAttribute("ProgressStatus") == "saved")
            and fighters[id] and Match.FighterKits[id] then
            return Match.root(player)
        end
        return nil
    end
    local driver = transport:driver({
        isPresent = present,
        sourceEligible = function(player, seat, phase) return sourceQueue:eligible(player, seat, phase) end,
        readyRoot = preparedRoot,
        begin = function(first, firstRoot, second, secondRoot, assignmentId)
            begin("casual", first, firstRoot, second, secondRoot, workspace:GetServerTimeNow(), nil, assignmentId)
        end,
    })
    sourceQueue = SourceQueue.new(transport.tickets, transport.assignments, driver, transport.profiles, {
        jobId = transport.jobId, root = stageRoot, now = os.time, guid = guid,
        player = function(userId) return Players:GetPlayerByUserId(userId) end,
        status = function(player, queued, expiresAt, stage, message, canCancel)
            if player.Parent ~= Players then return end
            player:SetAttribute("DuelQueued", if queued then true else nil)
            remote:FireClient(player, "queue", {queued = queued, expiresAt = expiresAt, format = "crossCasual",
                message = message, stage = stage, canCancel = canCancel})
        end,
    })
    cityReturn = CityReturn.new({
        present = present, now = os.time, guid = guid,
        release = function(player, id) return transport.profiles:request(player, "return", id) end,
        teleport = function(player, dispatch) return transport:returnToCity(player, dispatch) end,
        status = function(player, phase, message)
            if player.Parent == Players then remote:FireClient(player, "cityReturn", {phase = phase, message = message}) end
        end,
    })
    transport:connectFailures(function(player, packet)
        if packet.purpose == "casualDuel" then
            sourceQueue:failed(player, packet.matchId, packet.dispatch)
        elseif packet.purpose == "casualDuelReturn" then
            cityReturn:failure(player, packet.dispatch)
        end
    end)
    task.spawn(function()
        while not shuttingDown do
            sourceQueue:tick()
            cityReturn:tick()
            task.wait(.6)
        end
    end)
    local function stageArenaArrival(player)
        if not transport.privateId then return end
        local bootDeadline = os.time() + 15
        local role = transport:profileRole(player)
        while role == "unknown" and present(player) and os.time() < bootDeadline do
            task.wait(1)
            role = transport:profileRole(player)
        end
        if not present(player) then return end
        local joinData = player:GetJoinData()
        if role ~= "arena" then
            local payload = joinData and joinData.TeleportData
            if role == "unknown" and type(payload) == "table" and payload.purpose == "casualDuel"
                and payload.matchId == transport.privateId and joinData.SourceGameId == transport.universeId
                and joinData.SourcePlaceId == transport.placeId then cityReturn:offer(player, 0) end
            return
        end
        arenaDriver = driver
        local assignment = transport.assignments:read(transport.privateId)
        if not assignment then cityReturn:offer(player, 0) return end
        local admitted = false
        while present(player) and os.time() < assignment.deadline do
            local record, reason = arenaDriver:acceptArrival(player, joinData)
            if record then
                admitted = true
                break
            elseif reason ~= "unavailable" and reason ~= "pending" and reason ~= "worker unavailable" then
                break
            end
            task.wait(.5)
        end
        while admitted and present(player) and os.time() < assignment.deadline do
            if arenaDriver.destination and arenaDriver.destination.started then return end
            local record, reason = arenaDriver:tryStart()
            if record or reason == "already started" then return end
            if reason ~= "players not ready" and reason ~= "unavailable" then break end
            task.wait(.3)
        end
        local terminal = transport.assignments:expire(assignment.id) or transport.assignments:read(assignment.id)
        if terminal and (terminal.phase == "aborted" or terminal.phase == "finished") then
            arenaDriver:cleanupTickets(terminal)
        end
        if present(player) and not (active and active.assignmentId == assignment.id
            and (active.actors[1].player == player or active.actors[2].player == player)) then cityReturn:offer(player, 0) end
    end
    Players.PlayerAdded:Connect(function(player) task.spawn(stageArenaArrival, player) end)
    for _, player in Players:GetPlayers() do task.spawn(stageArenaArrival, player) end
end

Players.PlayerRemoving:Connect(function(player)
    closeOffer(player, false)
    if sourceQueue and sourceQueue:owns(player) then sourceQueue:removed(player) else cancelEntry(player) end
    if cityReturn then cityReturn:remove(player) end
    local reserved = arenaDriver and arenaDriver.destination
    if not active and reserved and not reserved.started and reserved.seats[player.UserId] == player then
        task.spawn(function() transport.assignments:abortDestination(reserved.matchId, transport.jobId, nil, "cancelled") end)
    end
    if active then
        for i, side in active.actors do
            if side.player == player then
                forfeit(active, i, "left", player)
                return
            end
        end
    end
end)

game:BindToClose(function()
    shuttingDown = true
    if preparing then
        endPreparation(preparing)
    end
    if active and active.rankTicket then
        local duel = active
        if duel.series.result then
            stop(duel, duel.series.result)
        else
            active = nil
            Motion.close(duel)
            duel.telegraph:Destroy()
            settleRank(duel, {}, false)
        end
    end
    local deadline = os.clock() + 22
    while pendingSettlements > 0 and os.clock() < deadline do
        task.wait(.1)
    end
end)
