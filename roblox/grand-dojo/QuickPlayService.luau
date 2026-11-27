local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Bell = require(ReplicatedStorage.QuickPlayBell)
local Rush = require(ReplicatedStorage.QuickPlayRushRules)
local Rescue = require(ReplicatedStorage.QuickPlayRescue)
local Catalog = require(ReplicatedStorage.QuickPlayCatalog)
local rules = {bell = Bell, rush = Rush, rescue = Rescue}
local remote = ReplicatedStorage.QuickPlay
local QuickPlay = {}

local function characterNear(player, anchor, radius)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and root
        and (root.Position - anchor.Position).Magnitude <= radius and humanoid
end

local function snapshot(id, round)
    if id == "rush" then return Rush.snapshot(round) end
    if id == "bell" then
        return {
            startedAt = round.startedAt, score = round.score, bonus = round.bonus,
            lastBeat = round.lastBeat, feedback = round.feedback,
        }
    end
    return {
        startedAt = round.startedAt, score = round.score, position = round.position,
        holding = round.holding, message = round.message,
    }
end

function QuickPlay.mount(folder, callbacks)
    local sessions = {}
    local serial = 0

    local function record(player, id)
        local profile = callbacks.profile(player)
        local world = profile and profile.cityAdventure
        return world and world.quickPlay and world.quickPlay[id]
    end

    local function send(player, kind, session, payload)
        remote:FireClient(player, kind, session.id, session.nonce, payload)
    end

    local function clearRound(player, session)
        if not session.round then return end
        session.round = nil
        local humanoid = session.humanoid
        if humanoid.Parent and humanoid.WalkSpeed == 0 then humanoid.WalkSpeed = session.walkSpeed end
        session.humanoid = nil
        player:SetAttribute("CityAdventureActive", nil)
    end

    local function close(player, session, notify)
        clearRound(player, session)
        sessions[player] = nil
        if notify then send(player, "closed", session) end
    end

    local function start(player, session)
        local humanoid = characterNear(player, session.anchor, 10)
        if session.round or session.pending or callbacks.blocked(player) or not humanoid then
            send(player, "blocked", session)
            return
        end
        serial += 1
        session.nonce = serial
        session.startedAt = workspace:GetServerTimeNow() + 0.65
        session.round = rules[session.id].new(session.startedAt)
        session.lastInput = 0
        session.humanoid, session.walkSpeed = humanoid, humanoid.WalkSpeed
        humanoid.WalkSpeed = 0
        player:SetAttribute("CityAdventureActive", true)
        send(player, "round", session, snapshot(session.id, session.round))
    end

    local function finish(player, session, now)
        local id, round = session.id, session.round
        local score, bonus = round.score, round.bonus or 0
        local elapsed = if id == "rush" then round.result.elapsed else now - session.startedAt
        local result = {
            score = score,
            bonus = bonus,
            tenths = math.clamp(math.round(elapsed * 10), 1, Catalog[id].duration * 10),
        }
        local def = Catalog[id]
        result.medal = if score >= def.goldScore and bonus >= def.goldBonus then "Gold"
            elseif score >= def.silverScore then "Silver" else "Try again"
        clearRound(player, session)
        session.pending = nil
        if score > 0 then
            local previous = record(player, id)
            local command = {
                kind = "quick-play", activity = id, score = score, bonus = bonus,
                tenths = result.tenths, at = math.floor(now),
            }
            if callbacks.queue(player, command) then
                session.pending = command.id
                session.firstGold = result.medal == "Gold" and not (previous and previous.gold)
                result.saving = true
            else
                result.saveUnavailable = true
            end
        end
        result.best = record(player, id)
        send(player, "result", session, result)
    end

    for id in Catalog do
        local anchor = folder:WaitForChild(id):WaitForChild("Start")
        anchor:WaitForChild("QuickPlayPrompt").Triggered:Connect(function(player)
            local previous = sessions[player]
            if (previous and (previous.round or previous.pending)) or callbacks.blocked(player)
                or not characterNear(player, anchor, 9) then return end
            serial += 1
            local session = {id = id, nonce = serial, anchor = anchor}
            sessions[player] = session
            send(player, "intro", session, record(player, id))
        end)
    end

    remote.OnServerEvent:Connect(function(player, verb, nonce, choice, index)
        local session = sessions[player]
        if not session or nonce ~= session.nonce then return end
        if verb == "close" then
            close(player, session, true)
        elseif verb == "start" then
            start(player, session)
        elseif verb == "input" and session.round then
            local now = workspace:GetServerTimeNow()
            if now < session.startedAt or now - session.lastInput < 0.06
                or not characterNear(player, session.anchor, 12) then return end
            session.lastInput = now
            local id, round = session.id, session.round
            local accepted
            if id == "bell" then
                local delay = math.clamp(player:GetNetworkPing(), 0, .12)
                accepted = type(choice) == "number" and Bell.strike(round, now - delay, choice)
            elseif id == "rush" then
                accepted = Rush.act(round, choice, index, now)
            else
                accepted = Rescue.move(round, choice, now)
                round.message = accepted
            end
            if accepted then send(player, "update", session, snapshot(id, round)) end
        end
    end)

    RunService.Heartbeat:Connect(function()
        local now = workspace:GetServerTimeNow()
        for player, session in sessions do
            local round = session.round
            if round then
                local id = session.id
                if not characterNear(player, session.anchor, 12) then
                    close(player, session, true)
                elseif id == "rush" then
                    if Rush.step(round, now) then
                        if round.result then finish(player, session, now)
                        else send(player, "update", session, Rush.snapshot(round)) end
                    end
                elseif (id == "bell" and now >= session.startedAt + Bell.Duration)
                    or (id == "rescue" and Rescue.finished(round, now)) then
                    finish(player, session, now)
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        local session = sessions[player]
        if session then close(player, session, false) end
    end)

    return {
        saved = function(player, command, xp)
            local session = sessions[player]
            if session and session.pending == command.id then
                session.pending = nil
                send(player, "saved", session, {
                    best = record(player, session.id), xp = xp, firstGold = session.firstGold,
                })
            end
        end,
    }
end

return QuickPlay
