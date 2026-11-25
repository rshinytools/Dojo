-- Authoritative Duel round clock. The arena supplies contact geometry.
local Spar = require(script.Parent.ReedguardRound)
local Magma = require(script.Parent.MagmaFighterCombat)
local RankRules = require(script.Parent.DuelRankRules)
local Storm = require(script.Parent.StormFighterCombat)
local Combatant = Spar.Combatant
local Duel = {INTRO = Spar.INTRO, DURATION = Spar.DURATION, OUTRO = Spar.OUTRO}

local PARRY_STUN = .56
local HIT_STUN = .28

function Duel.new(now, firstFighter, firstKitId, secondFighter, secondKitId, timing, ranked, firstTactical, secondTactical)
    local first = Combatant.new(now, firstFighter, firstKitId, timing, firstTactical)
    local second = Combatant.new(now, secondFighter, secondKitId, timing, secondTactical)
    first.kitId, second.kitId = firstKitId or "reedguard", secondKitId or "reedguard"
    if ranked then
        first.playerHealth = RankRules.health(firstFighter.health)
        second.playerHealth = RankRules.health(secondFighter.health)
        first.playerMaxHealth, second.playerMaxHealth = first.playerHealth, second.playerHealth
        first.rankedMatchup = RankRules.matchup(firstFighter.element, secondFighter.element)
        second.rankedMatchup = RankRules.matchup(secondFighter.element, firstFighter.element)
    end
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
    local submerged
    local function sample(action, move, at, index, castStartedAt)
        submerged = Combatant.submerged(defender, at) and not move.marker and not move.launch
        if submerged and move.projectile then return false end
        if move.shape == "talonThrow" then
            local hold = Storm.held(defender, at)
            if not hold or hold.attacker ~= attacker then return false end
        end
        local hit, point, zone, facing = check(attackerIndex, defenderIndex, action, move, at, index, castStartedAt)
        return hit and not submerged, point, zone, facing
    end
    local function resolve(_, at, fields, hit, facing, move)
        local deflected = hit and Combatant.deflects(defender, at, move)
        local kind = if not hit then (if submerged then "submerged" else "miss")
            elseif deflected then "blocked" else defense(defender, at, facing)
        if hit and move.controlOnly then
            kind = if kind then "blocked" elseif move.rootDuration then "snare" else "pull"
        elseif not kind then
            kind = if defender.counterUntil and at < defender.counterUntil then "counter" else "strike"
        end
        local guardBroken = kind == "blocked" and not deflected and move.guardBreak
        if guardBroken then kind = "guardBroken" end
        local landed = kind == "strike" or kind == "counter" or guardBroken
        if landed and move.shape == "talonGrab" then kind = "talonCarry" end
        fields.attacker, fields.defender, fields.kind, fields.at = attackerIndex, defenderIndex, kind, at
        fields.deflected = if deflected then true else nil
        local baseDamage = if guardBroken then math.ceil(fields.damage * .55) elseif landed then fields.damage else 0
        local matchup = attacker.rankedMatchup
        fields.damage = baseDamage
        if matchup and baseDamage > 0 then
            fields.damage = math.round(baseDamage * matchup.damageScale)
            fields.elementEffect = matchup.elementEffect
            fields.knockbackScale = matchup.knockbackScale
        end
        if landed and move.burnDamage then
            fields.burnDamage = math.max(1, math.round(move.burnDamage * (if matchup then matchup.damageScale else 1)))
        end
        if landed then
            fields.shockDuration = move.shockDuration
        end
        table.insert(batch, {notice = fields, direct = move.shape ~= "tile" and move.shape ~= "wave"
            and move.shape ~= "tentacle" and not move.projectile and not move.detached})
        -- The authored Magma Trail budget spends unscaled move damage.
        return baseDamage
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
        if event.kind == "burn" and Combatant.submerged(duel.sides[event.defender], time) then
            continue
        end
        if event.damage > 0 then
            defender.damage += event.damage
            local head = event.zone == "head"
            if event.kind ~= "burn" then
                event.frenzyResist = Combatant.unstoppable(duel.sides[event.defender], time)
                if not event.frenzyResist then
                    reaction(defender, if head then "hitHead" else "hitBody", if head then 5 else 4,
                        event.shockDuration or HIT_STUN)
                    if event.shockDuration then
                        defender.shock = math.max(defender.shock or 0, event.shockDuration)
                    end
                else
                    event.shockDuration = nil
                end
                if event.burnDamage then
                    Magma.ignite(duel, event.attacker, event.defender, duel.sides[event.defender], time, event.burnDamage)
                end
            end
        elseif event.kind == "parried" then
            reaction(defender, "parry", 3, 0)
            defender.parried = true
            if impact.direct and not Combatant.unstoppable(duel.sides[event.attacker], time) then
                reaction(attacker, "stagger", 2, PARRY_STUN)
                attacker.counterUntil = time + PARRY_STUN
            end
        elseif event.kind == "snare" then
            defender.rootTime = math.max(defender.rootTime or 0, event.rootDuration)
        elseif event.kind == "pull" then
            event.frenzyResist = Combatant.unstoppable(duel.sides[event.defender], time)
            defender.interruptedTravel = not event.frenzyResist or defender.interruptedTravel
        elseif event.kind == "blocked" and not event.deflected and not event.controlOnly then
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
        if plan.parried and not side.ultimateCooldown then
            side.signatureUntil = time + Combatant.PARRY_COUNTER_TIME
        end
        if plan.counterUntil then
            side.counterUntil = plan.counterUntil
        end
        if plan.shock and side.playerHealth > 0 then
            side.shockedUntil = math.max(side.shockedUntil or 0, time + plan.shock)
        end
        if plan.rootTime and side.playerHealth > 0 then
            Combatant.applyRoot(side, time, plan.rootTime)
        elseif plan.interruptedTravel then
            Combatant.interruptFixedTravel(side)
        end
    end
    for _, impact in batch do
        Combatant.resolveTalon(duel.sides, impact.notice, time)
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

function Duel.step(duel, now, check, beforeExit)
    if duel.result or now < duel.startsAt then
        return
    end
    local first, second = duel.sides[1], duel.sides[2]
    local limit = math.min(now, duel.endsAt)
    while not duel.result do
        local firstClip, firstTrail, firstEnd = Combatant.nextContacts(first)
        local secondClip, secondTrail, secondEnd = Combatant.nextContacts(second)
        local burnAt = Magma.nextBurn(duel)
        local time = math.min(firstClip, firstTrail, firstEnd, secondClip, secondTrail, secondEnd, burnAt)
        if time > limit or (beforeExit and time == now) then
            break
        end

        -- Both contacts see the pre-impact state. Reactions and health only
        -- change after the batch, so a simultaneous knockout is a draw.
        local batch = {}
        if burnAt == time then
            for _, event in Magma.burnsAt(duel, time) do
                table.insert(batch, {notice = event})
            end
        end
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
    if not duel.result and (now > duel.endsAt or (not beforeExit and now == duel.endsAt)) then
        finish(duel, duel.endsAt)
    end
end

return Duel
