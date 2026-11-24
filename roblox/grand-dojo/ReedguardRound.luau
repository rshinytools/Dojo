-- All combat times use the server clock. Input schedules a clip, and each
-- contact is consumed once when its authored frame is reached.
local Poses = require(script.Parent.ReedguardCombatPoses)
local Round = {}

Round.INTRO = 10
Round.OUTRO = 2.55
Round.DURATION = 60
Round.PARRY_WINDOW = .28
Round.GUARD_RAISE = .055
Round.GUARD_DURATION = .64
Round.CLIPS = {
    jab = {{at = Poses.Contact.jab, damage = 13, zone = "head"}},
    cross = {{at = Poses.Contact.cross, damage = 14, zone = "body"}},
    body = {{at = Poses.Contact.body, damage = 15, zone = "body"}},
    heavy = {{at = Poses.Contact.heavy, damage = 22, zone = "body"}},
    reedstep = {
        {at = Poses.Contact.reedstep[1], damage = 9, zone = "body"},
        {at = Poses.Contact.reedstep[2], damage = 9, zone = "body"},
        {at = Poses.Contact.reedstep[3], damage = 14, zone = "head"},
    },
}
local combo = {jab = "cross", cross = "body"}
local PARRY_COUNTER_TIME = 2.4
local PALM_START_RANGE = 3.65

function Round.new(now, bot, fighter)
    local startsAt = now + Round.INTRO
    return {
        introAt = now, startsAt = startsAt, endsAt = startsAt + Round.DURATION,
        playerHealth = fighter.health, playerMaxHealth = fighter.health,
        botHealth = bot.health, botMaxHealth = bot.health,
        botPhase = "ready", botAt = startsAt + .58, attackIndex = 0, attacks = bot.attacks,
        playerStunUntil = 0, nextGuard = startsAt, nextDodge = startsAt,
        guardFrom = 0, guardUntil = 0, signatureUntil = 0, notices = {},
    }
end

function Round.parryOpensAt(round)
    return if round.botPhase == "windup" then round.botAt - Round.PARRY_WINDOW else nil
end

local function report(round, kind, at, fields)
    fields = fields or {}
    fields.kind, fields.at = kind, at
    table.insert(round.notices, fields)
end

local function play(round, action, at)
    local duration = if action == "guard" then Round.GUARD_DURATION else Poses.Duration[action]
    round.clip = {action = action, startedAt = at, endsAt = at + duration, nextContact = 1}
end

local function nextLight(round, at)
    local last = round.lastLight
    local action = if last and at <= round.comboUntil then combo[last] or "jab" else "jab"
    round.lastLight, round.comboUntil = action, at + Poses.Duration[action] + .55
    play(round, action, at)
    return action
end

function Round.act(round, action, now, direction)
    if round.result or now < round.startsAt or now >= round.endsAt or now < round.playerStunUntil then
        return
    end
    local current = round.clip
    if current and now < current.endsAt then
        if action == "strike" and combo[current.action] and now >= current.endsAt - .19 then
            round.bufferedLight = true
        end
        -- The deflection can cancel into the earned rising combo after its pose reads.
        if action ~= "signature" or current.action ~= "parry" or now < current.startedAt + .20 then
            return
        end
    end
    if action == "strike" then
        round.guardUntil = 0
        return nextLight(round, now)
    elseif action == "guard" and now >= round.nextGuard then
        round.nextGuard = now + .74
        round.guardFrom, round.guardUntil = now, now + Round.GUARD_DURATION
        play(round, "guard", now)
        return "guard"
    elseif action == "heavy" then
        round.guardUntil = 0
        play(round, "heavy", now)
        return "heavy"
    elseif action == "dodge" and now >= round.nextDodge then
        round.nextDodge, round.guardUntil = now + .85, 0
        play(round, "sidestep", now)
        round.clip.direction = if direction == -1 then -1 else 1
        return "dodge"
    elseif action == "signature" then
        if now > round.signatureUntil then
            return "needParry"
        end
        round.signatureUntil, round.guardUntil = 0, 0
        play(round, "reedstep", now)
        return "reedstep"
    end
end

local function contact(round, clip, at, check)
    local attacks = Round.CLIPS[clip.action]
    local move = attacks[clip.nextContact]
    local index = clip.nextContact
    clip.nextContact += 1
    local hit, point = check(clip.action, move, at, index)
    if not hit then
        report(round, "miss", at, {attack = clip.action, index = index, point = point})
        return
    end
    local brace = round.botPhase == "setup" and round.attack.brace
    local counter = round.botPhase == "recovery" and round.recoveryKind == "parried"
    local damage = if brace then math.ceil(move.damage / 2) else move.damage
    round.botHealth = math.max(0, round.botHealth - damage)
    report(round, if brace then "braced" elseif counter then "counter" else "strike", at,
        {attack = clip.action, index = index, point = point, zone = move.zone, damage = damage})
    if round.botHealth == 0 then
        round.result = "win"
    end
end

local function advanceBot(round, at, distance, check)
    if round.botPhase == "ready" then
        if distance > PALM_START_RANGE then
            round.botAt = at + .12
            return
        end
        round.attackIndex = round.attackIndex % #round.attacks + 1
        round.attack = round.attacks[round.attackIndex]
        round.botPhase = if round.attack.brace then "setup" else "windup"
        round.botStartedAt = at
        round.botAt = at + (round.attack.setupTime or round.attack.windup)
    elseif round.botPhase == "setup" then
        round.botPhase, round.botStartedAt, round.botAt = "windup", at, at + round.attack.windup
    elseif round.botPhase == "windup" then
        local hit, facing, zone, point = check(at)
        round.botPhase, round.recoveryStartedAt = "recovery", at
        local guarded = hit and facing and at >= round.guardFrom + Round.GUARD_RAISE and at <= round.guardUntil
        local parried = guarded and round.guardFrom >= at - Round.PARRY_WINDOW
        local result = if not hit then "dodged" elseif parried then "parried" elseif guarded then "blocked" else "hit"
        round.recoveryKind = result
        round.botAt = at + round.attack.recovery + (if parried then .56 else 0)
        if parried then
            round.signatureUntil = at + PARRY_COUNTER_TIME
            round.guardUntil = 0
            play(round, "parry", at)
        elseif guarded then
            round.guardUntil = 0
            play(round, "block", at)
        elseif hit then
            round.guardUntil = 0
            round.bufferedLight = false
            round.playerHealth = math.max(0, round.playerHealth - round.attack.damage)
            play(round, if zone == "head" then "hitHead" else "hitBody", at)
            round.playerStunUntil = at + .28
            if round.playerHealth == 0 then
                round.result = "loss"
            end
        end
        report(round, result, at, {attack = "palm", zone = zone, point = point,
            damage = if result == "hit" then round.attack.damage else 0})
    else
        round.botPhase, round.botAt = "ready", at + .48
    end
end

function Round.step(round, now, distance, checkPlayer, checkBot)
    if round.result or now < round.startsAt then
        return
    end
    local limit = math.min(now, round.endsAt)
    if round.botPhase == "ready" and round.botAt < now - .2 and distance > PALM_START_RANGE then
        round.botAt = now + .1
    end
    while not round.result do
        local clip = round.clip
        local hit = clip and Round.CLIPS[clip.action] and Round.CLIPS[clip.action][clip.nextContact]
        local contactAt = if hit then clip.startedAt + hit.at else math.huge
        local completeAt = clip and clip.endsAt or math.huge
        local eventAt = math.min(contactAt, completeAt, round.botAt)
        if eventAt > limit then
            break
        elseif eventAt == contactAt then
            contact(round, clip, eventAt, checkPlayer)
        elseif eventAt == completeAt then
            round.clip = nil
            if round.bufferedLight then
                round.bufferedLight = false
                nextLight(round, eventAt)
            end
        else
            advanceBot(round, eventAt, distance, checkBot)
        end
    end
    if not round.result and now >= round.endsAt then
        local lead = round.playerHealth * round.botMaxHealth - round.botHealth * round.playerMaxHealth
        round.result = if lead > 0 then "win" elseif lead < 0 then "loss" else "draw"
    end
end

return Round
