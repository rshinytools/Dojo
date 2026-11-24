local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Match = require(script.Parent:WaitForChild("DojoMatchSupport"))
local Round = require(script.Parent:WaitForChild("DuelCombatRound"))
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

local QUEUE_SECONDS = 55
local OUTSIDE_GRACE = 1.65

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

local queued, active

local function notice(player, text)
    remote:FireClient(player, "notice", text)
end

local function clearQueue(text, leaving)
    local waiting = queued
    queued = nil
    if waiting and waiting.player ~= leaving then
        waiting.player:SetAttribute("DuelQueued", nil)
        remote:FireClient(waiting.player, "queue", {queued = false, message = text})
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

local function publish(duel, kind, now)
    local round = duel.round
    for i, side in round.sides do
        local challenger, opponent = duel.actors[i], duel.actors[3 - i]
        if challenger.player.Parent ~= Players then
            continue
        end
        local rival = round.sides[3 - i]
        local opensAt, attackAt, attack = Round.parryOpensAt(round, i)
        remote:FireClient(challenger.player, kind, {
            playerHealth = side.playerHealth, playerMaxHealth = side.playerMaxHealth,
            opponentHealth = rival.playerHealth, opponentMaxHealth = rival.playerMaxHealth,
            opponentName = opponent.player.DisplayName, opponentUserId = opponent.player.UserId, sideIndex = i,
            kitId = challenger.kit, opponentKitId = opponent.kit,
            introAt = round.introAt, startsAt = round.startsAt, endsAt = round.endsAt,
            phase = if round.result then "outro" elseif attackAt then "windup" else "ready",
            attackAt = attackAt, parryOpensAt = opensAt, tell = tells[attack],
            nextSignature = side.nextSignature, nextSecondary = side.nextSecondary,
            feedback = if now < challenger.feedbackUntil then challenger.feedback else nil,
        })
    end
end

local function begin(first, firstRoot, second, secondRoot, now)
    clearQueue()
    local a, b = actor(first, firstRoot), actor(second, secondRoot)
    local round = Round.new(now, a.fighter, a.kit, b.fighter, b.kit)
    local telegraph = Instance.new("Folder")
    telegraph.Name = "Duel attack tells"
    telegraph.Parent = court
    local duel = {round = round, actors = {a, b}, bounds = bounds, floor = floor, telegraph = telegraph, lastUpdate = now}
    active = duel
    for i, side in duel.actors do
        side.player:SetAttribute("DuelActive", true)
        side.player:SetAttribute("SparringActive", true)
        side.player:SetAttribute("ActiveDojoRing", "grand-dojo")
        Match.move(side.root, spawns[i].CFrame)
    end
    Motion.open(duel)
    Motion.render(duel, now)
    publish(duel, "begin", now)
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
            remote:FireClient(player, "result", {result = result[i], message = message,
                opponentName = duel.actors[3 - i].player.DisplayName})
        end
    end
end

local function forfeit(duel, index, reason, departing)
    if duel.round.result then
        stop(duel, duel.round.result, departing)
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
    duel.outroAt = round.resolvedAt
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
        if event.point and (kind == "parried" or kind == "blocked" or (event.damage or 0) > 0) then
            effects:FireAllClients("impact", kind, event.point, event.attack)
        elseif event.point and event.attack == "magmaTrail" then
            effects:FireAllClients("impact", "burst", event.point, event.attack)
        end
    end
    local changed = #round.notices > 0
    table.clear(round.notices)
    return changed
end

local function advance(duel, now)
    Motion.move(duel, now)
    return resolve(duel, now)
end

prompt.Triggered:Connect(function(player)
    if queued and queued.player == player then
        clearQueue("You left the duel queue.")
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
    if queued then
        local waitingRoot = eligible(queued.player, 3.25)
        if waitingRoot and now < queued.expiresAt then
            begin(queued.player, waitingRoot, player, root, now)
            return
        end
        clearQueue("Duel queue expired. Join again at the sign.")
    end
    queued = {player = player, expiresAt = now + QUEUE_SECONDS}
    player:SetAttribute("DuelQueued", true)
    remote:FireClient(player, "queue", {queued = true, expiresAt = queued.expiresAt,
        message = "Waiting for another player at the Grand Dojo."})
end)

remote.OnServerEvent:Connect(function(player, action, direction)
    if type(action) ~= "string" then
        return
    end
    if action == "cancel" and queued and queued.player == player then
        clearQueue("You left the duel queue.")
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
    elseif action == "leave" then
        forfeit(duel, index, "left")
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
    if queued then
        if now >= queued.expiresAt then
            clearQueue("Duel queue expired. Join again at the sign.")
        elseif not eligible(queued.player, 3.25) then
            clearQueue("Duel queue closed. Stay near the sign while waiting.")
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
        stop(duel, duel.round.result)
        return
    end
    Motion.render(duel, now)
    if changed or now - duel.lastUpdate >= .10 then
        duel.lastUpdate = now
        publish(duel, "update", now)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if queued and queued.player == player then
        clearQueue(nil, player)
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
