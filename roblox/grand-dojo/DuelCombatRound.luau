-- Authoritative Duel round clock. The arena supplies contact geometry.
local Spar = require(script.Parent.ReedguardRound)
local Combatant = Spar.Combatant
local Duel = {INTRO = Spar.INTRO, DURATION = Spar.DURATION, OUTRO = Spar.OUTRO}

local PARRY_STUN = .56
local HIT_STUN = .28

function Duel.new(now, firstFighter, firstKitId, secondFighter, secondKitId, timing)
    local first = Combatant.new(now, firstFighter, firstKitId, timing)
    local second = Combatant.new(now, secondFighter, secondKitId, timing)
    first.kitId, second.kitId = firstKitId or "reedguard", secondKitId or "reedguard"
    return {
        introAt = now, startsAt = first.startsAt, endsAt = first.endsAt,
        sides = {first, second}, notices = {},
    }
end

function Duel.act(duel, index, action, now, direction)
    local side = duel.sides[index]
    if duel.result or not side then
        return nil
    end
    return Spar.act(side, action, now, direction)
end

function Duel.parryOpensAt(duel, defenderIndex)
    if duel.result or (defenderIndex ~= 1 and defenderIndex ~= 2) then
        return nil
    end
    local attacker = duel.sides[3 - defenderIndex]
    local contactAt, action = Combatant.nextThreat(attacker)
    if contactAt <= duel.endsAt then
        return contactAt - Spar.PARRY_WINDOW, contactAt, action
    end
    return nil
end

local function defense(side, time, facing)
    if not facing or time < side.guardFrom + Spar.GUARD_RAISE or time > side.guardUntil then
        return nil
    end
    return if side.guardFrom >= time - Spar.PARRY_WINDOW then "parried" else "blocked"
end

local function collect(duel, attackerIndex, time, clipAt, trailAt, check, batch)
    if clipAt ~= time and trailAt ~= time then
        return
    end
    local defenderIndex = 3 - attackerIndex
    local attacker, defender = duel.sides[attackerIndex], duel.sides[defenderIndex]
    local function sample(action, move, at, index, castStartedAt)
        return check(attackerIndex, defenderIndex, action, move, at, index, castStartedAt)
    end
    local function resolve(_, at, fields, hit, facing, move)
        local kind = if not hit then "miss" else defense(defender, at, facing)
        if not kind then
            kind = if defender.counterUntil and at < defender.counterUntil then "counter" else "strike"
        end
        local landed = kind == "strike" or kind == "counter"
        fields.attacker, fields.defender, fields.kind, fields.at = attackerIndex, defenderIndex, kind, at
        fields.damage = if landed then fields.damage else 0
        table.insert(batch, {notice = fields, direct = move.shape ~= "tile"})
        return fields.damage
    end
    if clipAt == time then
        Combatant.contact(attacker, time, sample, resolve, true)
    end
    if trailAt == time then
        Combatant.advanceTrail(attacker, time, sample, resolve)
    end
end

local function reaction(plan, action, priority, stun)
    if priority > plan.priority then
        plan.action, plan.priority = action, priority
    end
    plan.stun = math.max(plan.stun, stun)
end

local function resolveBatch(duel, time, batch)
    local first = {damage = 0, priority = 0, stun = 0}
    local second = {damage = 0, priority = 0, stun = 0}
    local plans = {first, second}
    for _, impact in batch do
        local event = impact.notice
        local attacker, defender = plans[event.attacker], plans[event.defender]
        if event.damage > 0 then
            defender.damage += event.damage
            local head = event.zone == "head"
            reaction(defender, if head then "hitHead" else "hitBody", if head then 5 else 4, HIT_STUN)
        elseif event.kind == "parried" then
            reaction(defender, "parry", 3, 0)
            defender.parried = true
            if impact.direct then
                reaction(attacker, "stagger", 2, PARRY_STUN)
                attacker.counterUntil = time + PARRY_STUN
            end
        elseif event.kind == "blocked" then
            reaction(defender, "block", 1, 0)
        end
        table.insert(duel.notices, event)
    end
    for index, side in duel.sides do
        local plan = plans[index]
        side.playerHealth = math.max(0, side.playerHealth - plan.damage)
        if plan.action then
            side.guardUntil, side.bufferedLight = 0, false
            side.playerStunUntil = math.max(side.playerStunUntil, time + plan.stun)
            Combatant.play(side, plan.action, time)
        end
        if plan.parried and not side.kit.signatureCooldown then
            side.signatureUntil = time + Combatant.PARRY_COUNTER_TIME
        end
        if plan.counterUntil then
            side.counterUntil = plan.counterUntil
        end
    end
end

local function finish(duel, at)
    local first, second = duel.sides[1], duel.sides[2]
    local lead = first.playerHealth * second.playerMaxHealth - second.playerHealth * first.playerMaxHealth
    first.result = if lead > 0 then "win" elseif lead < 0 then "loss" else "draw"
    second.result = if lead > 0 then "loss" elseif lead < 0 then "win" else "draw"
    duel.result = {first.result, second.result}
    duel.resolvedAt, duel.outroAt = at, at + Duel.OUTRO
end

function Duel.step(duel, now, check)
    if duel.result or now < duel.startsAt then
        return
    end
    local first, second = duel.sides[1], duel.sides[2]
    local limit = math.min(now, duel.endsAt)
    while not duel.result do
        local firstClip, firstTrail, firstEnd = Combatant.nextContacts(first)
        local secondClip, secondTrail, secondEnd = Combatant.nextContacts(second)
        local time = math.min(firstClip, firstTrail, firstEnd, secondClip, secondTrail, secondEnd)
        if time > limit then
            break
        end

        -- Both contacts see the pre-impact state. Reactions and health only
        -- change after the batch, so a simultaneous knockout is a draw.
        local batch = {}
        collect(duel, 1, time, firstClip, firstTrail, check, batch)
        collect(duel, 2, time, secondClip, secondTrail, check, batch)
        if firstEnd == time then
            Combatant.complete(first, time)
        end
        if secondEnd == time then
            Combatant.complete(second, time)
        end
        if #batch > 0 then
            resolveBatch(duel, time, batch)
        end
        if first.playerHealth == 0 or second.playerHealth == 0 then
            finish(duel, time)
        end
    end
    if not duel.result and now >= duel.endsAt then
        finish(duel, duel.endsAt)
    end
end

return Duel
