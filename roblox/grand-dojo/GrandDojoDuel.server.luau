local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Match = require(script.Parent:WaitForChild("DojoMatchSupport"))
local Round = require(script.Parent:WaitForChild("DuelCombatRound"))
local Series = require(script.Parent:WaitForChild("DuelSeries"))
local Motion = require(script.Parent:WaitForChild("DuelFightMotion"))
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

local OFFER_SECONDS, QUEUE_SECONDS = 12, 55
local OUTSIDE_GRACE = 1.65
local formats = {"casual", "series"}
local formatLabels = {casual = "Casual", series = "Best of 3"}

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

local offers, queues = {}, {}
local active
local nextMatchId = 0

local function notice(player, text)
    remote:FireClient(player, "notice", text)
end

local function queueFormat(player)
    for _, format in formats do
        local waiting = queues[format]
        if waiting and waiting.player == player then
            return format
        end
    end
    return nil
end

local function clearQueue(format, message, departing)
    local waiting = queues[format]
    queues[format] = nil
    if waiting and waiting.player ~= departing then
        waiting.player:SetAttribute("DuelQueued", nil)
        remote:FireClient(waiting.player, "queue", {queued = false, message = message, format = format})
    end
end

local function updateWaiting(format)
    local waiting = queues[format]
    if waiting then
        local label = formatLabels[format]
        remote:FireClient(waiting.player, "queue", {queued = true, expiresAt = waiting.expiresAt, format = format,
            message = if active then label .. " queue · Court in use." else "Waiting for a " .. label .. " opponent."})
    end
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
        }))
    end
end

local function startRound(duel, now)
    if duel.round then
        Motion.close(duel)
    end
    local a, b = table.clone(duel.lineup[1]), table.clone(duel.lineup[2])
    duel.actors = {a, b}
    duel.round = Round.new(now, a.fighter, a.kit, b.fighter, b.kit, Series.timing(duel.series))
    duel.lastUpdate = now
    for i, side in duel.actors do
        Match.move(side.root, spawns[i].CFrame)
    end
    Motion.open(duel)
    Motion.render(duel, now)
    publish(duel, if duel.series.roundIndex == 1 then "begin" else "round", now)
end

local function begin(format, first, firstRoot, second, secondRoot, now)
    clearQueue(format)
    local telegraph = Instance.new("Folder")
    telegraph.Name = "Duel attack tells"
    telegraph.Parent = court
    nextMatchId += 1
    local lineup = {actor(first, firstRoot), actor(second, secondRoot)}
    local duel = {series = Series.new(format), matchId = nextMatchId, lineup = lineup,
        bounds = bounds, floor = floor, telegraph = telegraph}
    active = duel
    for _, side in lineup do
        side.player:SetAttribute("DuelActive", true)
        side.player:SetAttribute("SparringActive", true)
        side.player:SetAttribute("ActiveDojoRing", "grand-dojo")
    end
    startRound(duel, now)
    for _, queuedFormat in formats do
        updateWaiting(queuedFormat)
    end
end

local function stop(duel, result, departing, walkover)
    active = nil
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
                opponentName = duel.actors[3 - i].player.DisplayName}))
        end
    end
    for _, format in formats do
        updateWaiting(format)
    end
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

local function setFeedback(side, feedback, now)
    side.feedback, side.feedbackUntil = feedback, now + .82
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
        if duel.series.format == "series" then
            round.outroAt = now + Round.OUTRO
        end
    end
    for _, event in round.notices do
        Motion.impact(duel, event)
        local a, b = duel.actors[event.attacker], duel.actors[event.defender]
        local kind = event.kind
        if kind == "parried" or kind == "blocked" then
            setFeedback(a, if kind == "parried" then "attackParried" else "attackBlocked", now)
            setFeedback(b, kind, now)
        elseif event.damage and event.damage > 0 then
            setFeedback(a, kind, now)
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

prompt.Triggered:Connect(function(player)
    local queuedFormat = queueFormat(player)
    if queuedFormat then
        clearQueue(queuedFormat, "You left the duel queue.")
        return
    end
    local root = eligible(player, .4)
    if not root then
        notice(player, "Stand by the queue sign between activities to join a duel.")
        return
    elseif active then
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

local function joinQueue(player, format)
    local offer = offers[player]
    if not offer or not Series.supports(format) or queueFormat(player) then
        return
    end
    closeOffer(player, true)
    local now = workspace:GetServerTimeNow()
    local root = eligible(player, .4)
    if root ~= offer.root or now >= offer.expiresAt then
        notice(player, "Stand by the sign and choose a duel again.")
        return
    elseif active then
        notice(player, "A duel is underway. This court opens when it ends.")
        return
    end
    local waiting = queues[format]
    if waiting then
        if now < waiting.expiresAt and eligible(waiting.player, 3.25) == waiting.root then
            begin(format, waiting.player, waiting.root, player, root, now)
            return
        end
        clearQueue(format, "Duel queue closed. Join again at the sign.")
    end
    queues[format] = {player = player, root = root, expiresAt = now + QUEUE_SECONDS}
    player:SetAttribute("DuelQueued", true)
    updateWaiting(format)
end

remote.OnServerEvent:Connect(function(player, action, direction, matchId, roundIndex)
    if type(action) ~= "string" then
        return
    end
    if action == "join" then
        joinQueue(player, direction)
        return
    elseif action == "cancel" then
        local format = queueFormat(player)
        if format then
            clearQueue(format, "You left the duel queue.")
        end
        closeOffer(player, true)
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
    if (duel.series.format == "series" or matchId ~= nil) and matchId ~= duel.matchId then
        return
    end
    if action == "leave" then
        forfeit(duel, index, "left")
        return
    elseif (duel.series.format == "series" or roundIndex ~= nil) and roundIndex ~= duel.series.roundIndex then
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
    for _, format in formats do
        local waiting = queues[format]
        if waiting then
            if now >= waiting.expiresAt then
                clearQueue(format, "Duel queue expired. Join again at the sign.")
            elseif eligible(waiting.player, 3.25) ~= waiting.root then
                clearQueue(format, "Duel queue closed. Stay near the sign while waiting.")
            end
        end
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
    local format = queueFormat(player)
    if format then
        clearQueue(format, nil, player)
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
