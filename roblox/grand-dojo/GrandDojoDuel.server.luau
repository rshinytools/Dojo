local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Match = require(script.Parent:WaitForChild("DojoMatchSupport"))
local fighters = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog")).ById
local remote = ReplicatedStorage:WaitForChild("GrandDojoDuel")
local court = workspace:WaitForChild("Grand Dojo City"):WaitForChild("Fighting Ring"):WaitForChild("Duel Court")
local bounds = court:WaitForChild("Duel Bounds")
local entry = court:WaitForChild("Duel Queue")
local prompt = entry:WaitForChild("JoinDuelPrompt")
local spawns = {court:WaitForChild("First Spawn"), court:WaitForChild("Second Spawn")}
local returns = {court:WaitForChild("First Return"), court:WaitForChild("Second Return")}

local QUEUE_SECONDS = 55
local ROUND_SECONDS = 60
local STRIKE_WINDUP = .27
local STRIKE_RANGE = 6.25
local GUARD_TIME = .64
local PARRY_TIME = .24

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
        and fighters[id] ~= nil and Match.near(root, entry, prompt.MaxActivationDistance + extraRange) and root
end

local function combatant(player, root)
    local data = fighters[player:GetAttribute("SelectedStarterFighter")]
    return {player = player, root = root, arms = Match.armMotors(player.Character),
        health = data.health, maxHealth = data.health, damage = data.normalHit,
        nextStrike = 0, nextGuard = 0, guardFrom = 0, guardUntil = 0,
        nextInput = 0, feedbackUntil = 0}
end

local function publish(duel, kind, now)
    for i, side in duel.sides do
        local other = duel.sides[3 - i]
        remote:FireClient(side.player, kind, {
            playerHealth = side.health, playerMaxHealth = side.maxHealth,
            opponentHealth = other.health, opponentMaxHealth = other.maxHealth,
            opponentName = other.player.DisplayName, startsAt = duel.startsAt, endsAt = duel.endsAt,
            phase = if other.attackAt then "windup" else "ready", attackAt = other.attackAt,
            feedback = if now < side.feedbackUntil then side.feedback else nil,
        })
    end
end

local function begin(first, firstRoot, second, secondRoot, now)
    clearQueue()
    local duel = {startsAt = now + 3, endsAt = now + 3 + ROUND_SECONDS,
        sides = {combatant(first, firstRoot), combatant(second, secondRoot)}, lastUpdate = now}
    active = duel
    for i, side in duel.sides do
        side.player:SetAttribute("DuelActive", true)
        side.player:SetAttribute("SparringActive", true)
        side.player:SetAttribute("ActiveDojoRing", "grand-dojo")
        Match.move(side.root, spawns[i].CFrame)
    end
    publish(duel, "begin", now)
end

local function stop(duel, results, text, leaving)
    active = nil
    for i, side in duel.sides do
        Match.clearPose(side.arms)
        local player = side.player
        if player ~= leaving and player.Parent == Players then
            player:SetAttribute("DuelActive", nil)
            player:SetAttribute("SparringActive", nil)
            player:SetAttribute("ActiveDojoRing", nil)
            if Match.root(player) == side.root then
                Match.move(side.root, returns[i].CFrame)
            end
            remote:FireClient(player, "result", {result = results[i], message = text[i],
                opponentName = duel.sides[3 - i].player.DisplayName})
        end
    end
end

local function forfeit(duel, index, reason, leaving)
    local outcomes = {"win", "win"}
    outcomes[index] = if reason == "outside" then "outside" else "left"
    local messages = {"Your opponent left the duel.", "Your opponent left the duel."}
    messages[index] = if reason == "outside" then "You left the mat." else "You left the duel."
    stop(duel, outcomes, messages, leaving)
end

local function byHealth(duel, first, second)
    if first.health * second.maxHealth == second.health * first.maxHealth then
        stop(duel, {"draw", "draw"}, {"The duel ended in a draw.", "The duel ended in a draw."})
    elseif first.health * second.maxHealth > second.health * first.maxHealth then
        stop(duel, {"win", "loss"}, {"You won the duel.", "Your opponent won the duel."})
    else
        stop(duel, {"loss", "win"}, {"Your opponent won the duel.", "You won the duel."})
    end
end

local function setFeedback(side, text, now)
    side.feedback, side.feedbackUntil = text, now + .8
end

local function onMat(side)
    return Match.root(side.player) == side.root and Match.inside(bounds, side.root.Position)
end

local function land(attacker, defender, now)
    if not attacker.attackAt or now < attacker.attackAt then
        return 0
    end
    attacker.attackAt = nil
    local delta = Match.flat(defender.root.Position - attacker.root.Position)
    local distance = delta.Magnitude
    if not onMat(attacker) or not onMat(defender) or distance > STRIKE_RANGE
        or (distance >= .01 and attacker.root.CFrame.LookVector:Dot(delta.Unit) < .15) then
        setFeedback(attacker, "Miss", now)
        return 0
    end
    local facing = distance < .01 or defender.root.CFrame.LookVector:Dot(-delta.Unit) >= .15
    if facing and now <= defender.guardUntil then
        local parry = now <= defender.guardFrom + PARRY_TIME
        if parry then
            attacker.nextStrike = math.max(attacker.nextStrike, now + .78)
        end
        setFeedback(attacker, if parry then "Strike parried" else "Strike blocked", now)
        setFeedback(defender, if parry then "Parry" else "Block", now)
        return 0
    end
    setFeedback(attacker, "Strike landed", now)
    setFeedback(defender, "Hit", now)
    return attacker.damage
end

local function resolve(duel, now)
    local first, second = duel.sides[1], duel.sides[2]
    if now >= duel.endsAt then
        byHealth(duel, first, second)
        return
    end
    local dealtByFirst, dealtBySecond = land(first, second, now), land(second, first, now)
    first.health, second.health = math.max(0, first.health - dealtBySecond), math.max(0, second.health - dealtByFirst)
    if first.health == 0 or second.health == 0 then
        byHealth(duel, first, second)
    end
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

remote.OnServerEvent:Connect(function(player, action)
    if action == "cancel" and queued and queued.player == player then
        clearQueue("You left the duel queue.")
        return
    elseif action ~= "leave" and action ~= "strike" and action ~= "guard" then
        return
    end
    local duel = active
    if not duel then
        return
    end
    local index = if duel.sides[1].player == player then 1 elseif duel.sides[2].player == player then 2 else nil
    if not index then
        return
    elseif action == "leave" then
        forfeit(duel, index, "left")
        return
    end
    local now = workspace:GetServerTimeNow()
    local side = duel.sides[index]
    if now < duel.startsAt or now < side.nextInput or not onMat(side) then
        return
    end
    side.nextInput = now + .08
    resolve(duel, now)
    if active ~= duel or side.attackAt then
        return
    end
    if action == "strike" and now >= side.nextStrike and now > side.guardUntil then
        side.nextStrike, side.attackAt = now + .66, now + STRIKE_WINDUP
        Match.pose(side.arms, "strike")
    elseif action == "guard" and now >= side.nextGuard then
        side.nextGuard, side.guardFrom, side.guardUntil = now + 1.12, now, now + GUARD_TIME
        Match.pose(side.arms, "guard")
    end
end)

local accumulated = 0
RunService.Heartbeat:Connect(function(elapsed)
    accumulated += elapsed
    if accumulated < .045 then
        return
    end
    accumulated = 0
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
    for i, side in duel.sides do
        if Match.root(side.player) ~= side.root then
            forfeit(duel, i, "left")
            return
        end
        if not onMat(side) then
            side.outsideAt = side.outsideAt or now
            if now - side.outsideAt > 1.65 then
                forfeit(duel, i, "outside")
                return
            end
        else
            side.outsideAt = nil
        end
    end
    resolve(duel, now)
    if active == duel and now - duel.lastUpdate >= .10 then
        duel.lastUpdate = now
        publish(duel, "update", now)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if queued and queued.player == player then
        clearQueue(nil, player)
    end
    if active then
        for i, side in active.sides do
            if side.player == player then
                forfeit(active, i, "left", player)
                return
            end
        end
    end
end)
