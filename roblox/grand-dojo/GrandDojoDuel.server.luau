local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Match = require(script.Parent:WaitForChild("DojoMatchSupport"))
local Round = require(script.Parent:WaitForChild("DuelCombatRound"))
local Series = require(script.Parent:WaitForChild("DuelSeries"))
local Motion = require(script.Parent:WaitForChild("DuelFightMotion"))
local RankRules = require(script.Parent:WaitForChild("DuelRankRules"))
local RankLedger = require(script.Parent:WaitForChild("DuelRankLedger"))
local rankStore = if RunService:IsStudio() then RankLedger.memoryStore()
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

local actions = {strike = true, guard = true, heavy = true, uppercut = true, secondary = true,
    dodge = true, signature = true}
local tells = {
    jab = "Jab", cross = "Cross", body = "Body strike", heavy = "Heavy strike",
    uppercut = "Uppercut", reedstep = "Reedstep Rising", bellySlide = "Belly-Slide Blitz",
    ridgePalm = "Ridge Palm", seismicChestPound = "Seismic Chest-Pound",
    emberSweep = "Ember Sweep", magmaTrail = "Magma Trail",
}
local resultMessages = {
    win = "You won the duel.",
    loss = "Your opponent won the duel.",
    draw = "The duel ended in a draw.",
    left = "You left the duel.",
    outside = "You left the mat.",
}

local offers, queues, joins = {}, {}, {}
local rankOperations = {}
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

local function readRank(player)
    if rankOperations[player.UserId] then
        return nil
    end
    rankOperations[player.UserId] = true
    rankStatus(player, "loading")
    local profile, reason = ledger:read(player.UserId)
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
    return {player = player, root = root, kit = Match.FighterKits[id], fighter = fighters[id], nextInput = 0, feedbackUntil = 0}
end

local function score(duel, side, payload)
    local series = duel.series
    payload.format, payload.matchId = series.format, duel.matchId
    payload.roundIndex, payload.maxRounds = series.roundIndex, series.maxRounds
    payload.playerRounds, payload.opponentRounds = series.wins[side], series.wins[3 - side]
    payload.roundResult = if series.roundResult then series.roundResult[side] else nil
    return payload
end

local function publish(duel, kind, now)
    local round = duel.round
    for i, side in round.sides do
        local challenger, opponent = duel.actors[i], duel.actors[3 - i]
        if challenger.player.Parent ~= Players then
            continue
        end
        local rival = round.sides[3 - i]
        local opensAt, attackAt, attack = Round.parryOpensAt(round, i)
        remote:FireClient(challenger.player, kind, score(duel, i, {
            playerHealth = side.playerHealth, playerMaxHealth = side.playerMaxHealth,
            opponentHealth = rival.playerHealth, opponentMaxHealth = rival.playerMaxHealth,
            opponentName = opponent.player.DisplayName, opponentUserId = opponent.player.UserId, sideIndex = i,
            kitId = challenger.kit, opponentKitId = opponent.kit,
            introAt = round.introAt, startsAt = round.startsAt, endsAt = round.endsAt,
            phase = if round.result then "outro" elseif attackAt then "windup" else "ready",
            attackAt = attackAt, parryOpensAt = opensAt, tell = tells[attack],
            nextSignature = side.nextSignature, nextSecondary = side.nextSecondary,
            feedback = if now < challenger.feedbackUntil then challenger.feedback else nil,
            elementEffect = if now < challenger.feedbackUntil then challenger.elementEffect else nil,
        }))
    end
end

local function startRound(duel, now)
    if duel.round then
        Motion.close(duel)
    end
    local a, b = table.clone(duel.lineup[1]), table.clone(duel.lineup[2])
    duel.actors = {a, b}
    duel.round = Round.new(now, a.fighter, a.kit, b.fighter, b.kit, Series.timing(duel.series),
        duel.series.format == "ranked")
    duel.lastUpdate = now
    for i, side in duel.actors do
        Match.move(side.root, spawns[i].CFrame)
    end
    Motion.open(duel)
    Motion.render(duel, now)
    publish(duel, if duel.series.roundIndex == 1 then "begin" else "round", now)
end

local function begin(format, first, firstRoot, second, secondRoot, now, ticket)
    clearQueue(first)
    clearQueue(second)
    local telegraph = Instance.new("Folder")
    telegraph.Name = "Duel attack tells"
    telegraph.Parent = court
    nextMatchId += 1
    local lineup = {actor(first, firstRoot), actor(second, secondRoot)}
    local duel = {series = Series.new(format), matchId = nextMatchId, lineup = lineup, rankTicket = ticket,
        bounds = bounds, floor = floor, telegraph = telegraph}
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
                opponentName = duel.actors[3 - i].player.DisplayName, ratingPending = counts}))
        end
    end
    settleRank(duel, result, counts)
    updateQueues()
end

local function forfeit(duel, index, reason, departing)
    if duel.series.result then
        stop(duel, duel.series.result, departing)
        return
    end
    local result = {"win", "win"}
    result[index] = reason
    stop(duel, result, departing, true)
end

local function setFeedback(side, feedback, now, elementEffect)
    side.feedback, side.feedbackUntil = feedback, now + .82
    side.elementEffect = elementEffect
end

local function onMat(side)
    return Match.root(side.player) == side.root and Match.inside(bounds, side.root.Position)
end

local function resolve(duel, now)
    local round = duel.round
    Round.step(round, now, function(attacker, _, action, move, at, index, castStartedAt)
        return Motion.strike(duel, attacker, action, move, at, index, castStartedAt)
    end)
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
        local kind = event.kind
        if kind == "parried" or kind == "blocked" then
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
            effects:FireAllClients("impact", cue, event.point, event.attack)
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
        local firstId, secondId = first.player.UserId, second.player.UserId
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
    if queues[player] then
        cancelEntry(player)
        return
    end
    local root = eligible(player, .4)
    if not root then
        notice(player, "Stand by the queue sign between activities to join a duel.")
        return
    elseif active or preparing or shuttingDown then
        notice(player, "A duel is underway. This court opens when it ends.")
        return
    end
    local now = workspace:GetServerTimeNow()
    local current = offers[player]
    local expiresAt = if current and current.root == root and now < current.expiresAt
        then current.expiresAt else now + OFFER_SECONDS
    offers[player] = {root = root, expiresAt = expiresAt}
    remote:FireClient(player, "offer", {expiresAt = expiresAt})
end)

local function enqueue(player, root, format, now, points)
    queues[player] = {player = player, root = root, format = format, joinedAt = now,
        expiresAt = now + QUEUE_SECONDS, points = points}
    updateWaiting(queues[player])
    tryMatch(now)
end

local function joinQueue(player, format)
    local offer = offers[player]
    if not offer or not Series.supports(format) or queues[player] or joins[player] then
        return
    end
    closeOffer(player, true)
    local now = workspace:GetServerTimeNow()
    local root = eligible(player, .4)
    if root ~= offer.root or now >= offer.expiresAt then
        notice(player, "Stand by the sign and choose a duel again.")
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

remote.OnServerEvent:Connect(function(player, action, direction, matchId, roundIndex)
    if type(action) ~= "string" then
        return
    end
    if action == "join" then
        joinQueue(player, direction)
        return
    elseif action == "cancel" then
        cancelEntry(player)
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
    if now < duel.round.startsAt or now < side.nextInput or duel.round.result or not onMat(side)
        or not Motion.canAct(duel, index, action) then
        return
    end
    side.nextInput = now + .08
    -- A new input must not replace an earlier contact still due after a long frame.
    local changed = advance(duel, now)
    local feedback = if not duel.round.result
        then Round.act(duel.round, index, action, now, if direction == -1 then -1 else 1) else nil
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

Players.PlayerRemoving:Connect(function(player)
    closeOffer(player, false)
    cancelEntry(player)
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
