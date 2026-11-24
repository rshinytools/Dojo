-- The encounter clock shares the fighters' authored contact frames. The
-- caller provides historical hit geometry and live revive eligibility.
local Spar = require(script.Parent.ReedguardRound)
local Fighter = Spar.Combatant

local Raid = {
    SIZE = 4, INTRO = Spar.INTRO, DURATION = 105, OUTRO = Spar.OUTRO,
    BOSS_HEALTH = 1260, REVIVE_TIME = 2, REVIVE_FRACTION = .35,
}

local bosses = {
    kilnback = {
        health = Raid.BOSS_HEALTH, duration = Raid.DURATION,
        attacks = {
            {id = "pulse", name = "Kiln Pulse", hint = "Clear the ring"},
            {id = "sweep", name = "Tile Sweep", hint = "Leave the marked lane"},
            {id = "cooldown", name = "Cool-down Window", hint = "Strike the exposed core"},
        },
    },
    kraken = {
        health = 1500, duration = 118,
        attacks = {
            {id = "undertow", name = "Undertow", hint = "Step inside or outside the ring"},
            {id = "cataclysm", name = "Tentacle Cataclysm", hint = "Move into a diagonal gap"},
            {id = "airPocket", name = "Air Pocket", hint = "Strike the exposed mantle"},
        },
    },
    phoenix = {
        health = 1650, duration = 125,
        attacks = {
            {id = "solarFlare", name = "Sunspots", hint = "Leave the marked circles"},
            {id = "sunDive", name = "Sundive", hint = "Move out of the marked lane"},
            {id = "dawnLanding", name = "Dawn Landing", hint = "Strike the exposed chest"},
        },
    },
}
local cardinal = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
local sunspots = {{-11, 7}, {11, 7}, {0, -11}}
local inputs = {strike = true, guard = true, heavy = true, uppercut = true, dodge = true, secondary = true, signature = true}
local evades = {sidestep = true, floeTurn = true}

function Raid.new(now, entrants, bossId)
    bossId = bossId or "kilnback"
    local boss = assert(bosses[bossId], "Unknown raid boss")
    assert(#entrants == Raid.SIZE, "Raid requires four fighters")
    local sides = {}
    local timing = {intro = Raid.INTRO, duration = boss.duration}
    for index, entrant in entrants do
        assert(type(entrant.fighter.health) == "number" and entrant.fighter.health > 0
            and entrant.fighter.health < math.huge and entrant.kitId, "Invalid raid fighter")
        local side = Fighter.new(now, entrant.fighter, entrant.kitId, timing)
        side.kitId = entrant.kitId
        side.contribution = {damage = 0, revives = 0, parries = 0}
        sides[index] = side
    end
    local startsAt = now + Raid.INTRO
    return {
        introAt = now, startsAt = startsAt, endsAt = startsAt + boss.duration, sides = sides,
        bossId = bossId, bossHealth = boss.health, bossMaxHealth = boss.health, bossPhase = 1, coreExposed = false,
        bossAirborne = if bossId == "phoenix" then true else nil,
        nextAttackAt = startsAt + 1.35, attackIndex = 0, lastTarget = 0,
        revives = {}, notices = {}, steppedAt = now,
    }
end

local function standing(side)
    return side and not side.left and not side.eliminated and side.playerHealth > 0
end

local function report(round, event)
    table.insert(round.notices, event)
end

function Raid.cancelRevive(round, reviver, now, reason)
    local channel = round.revives[reviver]
    if not channel then
        return false
    end
    round.revives[reviver] = nil
    report(round, {source = "team", kind = "reviveCancelled", attacker = reviver, defender = channel.target,
        at = now, reason = reason})
    return true
end

local function clearRevives(round, index, now, reason)
    Raid.cancelRevive(round, index, now, reason)
    for reviver, channel in round.revives do
        if channel.target == index then
            Raid.cancelRevive(round, reviver, now, reason)
        end
    end
end

function Raid.canBeginRevive(round, reviver, target, now)
    local source, downed = round.sides[reviver], round.sides[target]
    if round.result or now < round.startsAt or now < round.steppedAt
        or now + Raid.REVIVE_TIME > round.endsAt or reviver == target
        or not standing(source) or not downed or downed.left or not downed.downed or downed.reviveUsed
        or now < source.playerStunUntil or (source.clip and now < source.clip.endsAt)
        or now < downed.eliminatedAt + .60 or round.revives[reviver] then
        return nil
    end
    for _, channel in round.revives do
        if channel.target == target then
            return nil
        end
    end
    return true
end

function Raid.beginRevive(round, reviver, target, now)
    if not Raid.canBeginRevive(round, reviver, target, now) then
        return nil
    end
    local channel = {target = target, startedAt = now, endsAt = now + Raid.REVIVE_TIME}
    round.revives[reviver] = channel
    report(round, {source = "team", kind = "reviveStarted", attacker = reviver, defender = target, at = now})
    return channel
end

function Raid.act(round, index, action, now, direction)
    local side = round.sides[index]
    if round.result or now < round.steppedAt or not standing(side) or not inputs[action] then
        return nil
    end
    local before = side.clip
    local accepted = Spar.act(side, action, now, direction)
    if side.clip ~= before then
        Raid.cancelRevive(round, index, now, "action")
    end
    return accepted
end

local function finish(round, now, outcome, reason)
    local outcomes, eligible = {}, {}
    for index, side in round.sides do
        outcomes[index] = if side.left then "left" else outcome
        local contribution = side.contribution
        if outcome == "win" and not side.left and (contribution.damage >= 48 or contribution.revives > 0) then
            eligible[index] = true
        end
    end
    table.clear(round.revives)
    round.result = {outcome = outcome, reason = reason, outcomes = outcomes, eligible = eligible}
    round.resolvedAt, round.outroAt = now, now + Raid.OUTRO
    round.coreExposed, round.cooldownUntil = false, nil
end

local function settled(round, now)
    for _, side in round.sides do
        if standing(side) then
            if round.bossHealth == 0 then
                finish(round, now, "win", "cleared")
            end
            return
        end
    end
    finish(round, now, "loss", "wipe")
end

function Raid.leave(round, index, now)
    local side = round.sides[index]
    if round.result or now < round.steppedAt or not side or side.left then
        return false
    end
    clearRevives(round, index, now, "departure")
    side.left, side.eliminated, side.eliminatedAt, side.eliminationReason = true, true, now, "left"
    side.downed, side.playerHealth, side.clip, side.trail = false, 0, nil, nil
    side.guardUntil, side.bufferedLight = 0, false
    if now < round.startsAt then
        finish(round, now, "cancelled", "earlyDeparture")
    else
        settled(round, now)
    end
    return true
end

local function nextTarget(round, at, chooseTarget)
    local requested = chooseTarget and chooseTarget(round, at)
    if standing(round.sides[requested]) then
        round.lastTarget = requested
        return requested
    end
    for offset = 1, Raid.SIZE do
        local candidate = (round.lastTarget + offset - 1) % Raid.SIZE + 1
        if standing(round.sides[candidate]) then
            round.lastTarget = candidate
            return candidate
        end
    end
    return nil
end

local function beginAttack(round, at, chooseTarget)
    local order = bosses[round.bossId].attacks
    round.attackIndex = round.attackIndex % #order + 1
    local move, phase = order[round.attackIndex], round.bossPhase
    local id = move.id
    local faster = phase == 2
    local attack = {id = id, name = move.name, hint = move.hint, phase = phase, startedAt = at, warningAt = at,
        steps = {}, nextStep = 1, caught = {}}
    if id == "pulse" then
        attack.impactAt = at + (if faster then 1.15 else 1.40)
        attack.steps[1] = {index = 1, at = attack.impactAt, radius = if faster then 13.5 else 11.5,
            damage = if faster then 38 else 29}
        attack.endsAt = attack.impactAt + (if faster then .65 else .80)
    elseif id == "sweep" then
        attack.target = nextTarget(round, at, chooseTarget)
        attack.impactAt = at + (if faster then 1.28 else 1.55)
        for index = 1, 3 do
            attack.steps[index] = {index = index, at = attack.impactAt + (index - 1) * (if faster then .40 else .47),
                offset = 4.5 + (index - 1) * 6, halfWidth = 3.25, halfSpan = 8,
                damage = if faster then 29 else 22}
        end
        attack.endsAt = attack.steps[3].at + (if faster then .65 else .90)
    elseif id == "undertow" then
        attack.impactAt = at + (if faster then 1.19 else 1.45)
        attack.steps[1] = {index = 1, at = attack.impactAt, radius = if faster then 21 else 19,
            innerRadius = if faster then 8.5 else 9, damage = if faster then 36 else 30}
        attack.endsAt = attack.impactAt + (if faster then .66 else .82)
    elseif id == "cataclysm" then
        attack.impactAt = at + (if faster then 1.42 else 1.70)
        for index, axis in cardinal do
            attack.steps[index] = {index = index, at = attack.impactAt + (index - 1) * (if faster then .14 else .18),
                axisX = axis[1], axisZ = axis[2], innerReach = 3.5, outerReach = if faster then 22 else 20.5,
                halfWidth = if faster then 3.8 else 3.25, damage = if faster then 40 else 34}
        end
        attack.endsAt = attack.steps[4].at + (if faster then .66 else .90)
    elseif id == "solarFlare" then
        attack.impactAt = at + (if faster then 1.31 else 1.62)
        for index, center in sunspots do
            attack.steps[index] = {index = index, at = attack.impactAt + (index - 1) * (if faster then .18 else .25),
                centerX = center[1], centerZ = center[2], radius = if faster then 5.6 else 4.75,
                damage = if faster then 32 else 25}
        end
        attack.endsAt = attack.steps[#sunspots].at + (if faster then .54 else .70)
    elseif id == "sunDive" then
        attack.target = nextTarget(round, at, chooseTarget)
        attack.impactAt = at + (if faster then 1.56 else 1.90)
        attack.steps[1] = {index = 1, at = attack.impactAt, offset = 0, halfWidth = if faster then 23 else 22,
            halfSpan = if faster then 4.3 else 3.3, damage = if faster then 43 else 36}
        attack.endsAt = attack.impactAt + (if faster then .65 else .85)
    elseif id == "dawnLanding" then
        attack.landAt = at + (if faster then .74 else .88)
        attack.steps[1] = {index = 1, at = attack.landAt, kind = "land"}
        attack.endsAt = attack.landAt + (if faster then 5.40 else 6.20)
    else
        local duration = if faster then 4.5 elseif id == "airPocket" then 5.15 else 5.2
        attack.endsAt = at + duration
        round.coreExposed, round.cooldownUntil = true, attack.endsAt
    end
    round.attack = attack
end

local function attackEventAt(round)
    local attack = round.attack
    local strike = attack and attack.steps[attack.nextStep]
    return if strike then strike.at elseif attack then attack.endsAt else round.nextAttackAt
end

local function defense(side, at, facing)
    local clip = side.clip
    if clip and evades[clip.action] and at >= clip.startedAt + .045
        and at < math.min(clip.endsAt, clip.startedAt + .27) then
        return "dodged"
    end
    local guarded = facing and at >= side.guardFrom + Spar.GUARD_RAISE and at <= side.guardUntil
    return if not guarded then "hit" elseif side.guardFrom >= at - Spar.PARRY_WINDOW then "parried" else "blocked"
end

local function advanceBoss(round, at, chooseTarget, checkBoss, hits)
    local attack = round.attack
    if not attack then
        beginAttack(round, at, chooseTarget)
        return
    end
    local strike = attack.steps[attack.nextStep]
    if not strike then
        round.attack = nil
        round.coreExposed, round.cooldownUntil = false, nil
        if attack.id == "dawnLanding" then
            round.bossAirborne = true
        end
        round.nextAttackAt = at + (if round.bossPhase == 2 then .46 else .68)
        return
    end
    attack.nextStep += 1
    if strike.kind == "land" then
        round.bossAirborne, round.coreExposed, round.cooldownUntil = false, true, attack.endsAt
        report(round, {source = "arena", kind = "landing", attack = attack.id, at = at})
        return
    end
    local seen = {}
    for _, contact in checkBoss(attack, strike, at) or {} do
        local index = contact.index
        local side = round.sides[index]
        if standing(side) and not attack.caught[index] and not seen[index] then
            seen[index] = true
            local kind = defense(side, at, contact.facing)
            if kind ~= "dodged" then
                -- Adjacent lanes belong to one cast. A broad hurtbox can
                -- overlap multiple steps, but only one may deal damage.
                attack.caught[index] = true
            end
            local damage = if kind == "hit" then strike.damage elseif kind == "blocked" then math.ceil(strike.damage * .28) else 0
            table.insert(hits, {source = "boss", kind = kind, attack = attack.id, index = strike.index,
                at = at, defender = index, point = contact.point, damage = damage})
        end
    end
end

local function collectFighter(round, index, at, hitAt, tileAt, checkPlayer, hits)
    if hitAt ~= at and tileAt ~= at then
        return
    end
    local function sample(action, move, contactAt, contactIndex, castAt)
        return checkPlayer(index, action, move, contactAt, contactIndex, castAt)
    end
    local function resolve(_, contactAt, fields, hit, _facing, _move)
        fields.source, fields.attacker, fields.at = "player", index, contactAt
        if hit and not round.bossAirborne then
            local baseDamage = fields.damage
            local core = round.coreExposed and fields.zone == "core"
            local scale = if core then 1.64 elseif round.coreExposed then 1.18 else .72
            fields.kind, fields.damage = if core then "counter" else "strike", math.max(1, math.round(baseDamage * scale))
            fields.core = core
            table.insert(hits, fields)
            return baseDamage
        end
        fields.kind, fields.damage = if hit then "airborne" else "miss", 0
        table.insert(hits, fields)
        return 0
    end
    local side = round.sides[index]
    if hitAt == at then
        Fighter.contact(side, at, sample, resolve, true)
    end
    if tileAt == at then
        Fighter.advanceTrail(side, at, sample, resolve)
    end
end

local function applyBossHit(round, event)
    local side = round.sides[event.defender]
    if event.kind == "dodged" then
        return
    end
    side.guardUntil, side.bufferedLight = 0, false
    if event.kind == "parried" then
        side.contribution.parries += 1
        if not side.kit.signatureCooldown then
            side.signatureUntil = event.at + Fighter.PARRY_COUNTER_TIME
        end
        Fighter.play(side, "parry", event.at)
        return
    end

    event.damage = math.min(side.playerHealth, event.damage)
    side.playerHealth -= event.damage
    Raid.cancelRevive(round, event.defender, event.at, "hit")
    if side.playerHealth == 0 then
        side.downed, side.eliminated, side.eliminatedAt, side.eliminationReason = true, true, event.at, "knockout"
        side.clip, side.trail = nil, nil
        report(round, {source = "team", kind = "down", defender = event.defender, at = event.at})
    elseif event.kind == "blocked" then
        Fighter.play(side, "block", event.at)
    else
        side.playerStunUntil = math.max(side.playerStunUntil, event.at + .28)
        Fighter.play(side, "hitBody", event.at)
    end
end

local function applyHits(round, hits)
    for _, event in hits do
        if event.source == "player" then
            event.damage = math.min(round.bossHealth, event.damage)
            round.bossHealth -= event.damage
            round.sides[event.attacker].contribution.damage += event.damage
        else
            applyBossHit(round, event)
        end
        report(round, event)
    end
    if round.bossHealth * 2 <= round.bossMaxHealth then
        round.bossPhase = 2
    end
end

local function validateRevives(round, at, checkRevive)
    for reviver, channel in round.revives do
        local target = round.sides[channel.target]
        if at >= channel.startedAt and (not standing(round.sides[reviver]) or target.left or not target.downed
            or not checkRevive or not checkRevive(reviver, channel.target, at)) then
            Raid.cancelRevive(round, reviver, at, "position")
        end
    end
end

local function completeRevives(round, at)
    for reviver, channel in round.revives do
        if channel.endsAt == at then
            local target = round.sides[channel.target]
            round.revives[reviver] = nil
            target.playerHealth = math.max(1, math.round(target.playerMaxHealth * Raid.REVIVE_FRACTION))
            target.downed, target.eliminated, target.eliminationReason, target.eliminatedAt = false, false, nil, nil
            target.reviveUsed, target.playerStunUntil = true, at + .30
            round.sides[reviver].contribution.revives += 1
            report(round, {source = "team", kind = "revived", attacker = reviver, defender = channel.target,
                at = at, health = target.playerHealth})
        end
    end
end

function Raid.step(round, now, checkPlayer, checkBoss, chooseTarget, checkRevive)
    if round.result or now < round.startsAt or now < round.steppedAt then
        return
    end
    local limit = math.min(now, round.endsAt)
    -- Continuity is checked on every live tick, including ticks without impacts.
    validateRevives(round, limit, checkRevive)
    while not round.result do
        local bossAt = attackEventAt(round)
        local at = bossAt
        for _, side in round.sides do
            if standing(side) then
                at = math.min(at, Fighter.nextContacts(side))
            end
        end
        for _, channel in round.revives do
            at = math.min(at, channel.endsAt)
        end
        if at > limit then
            break
        end

        local hits, clipsEnding = {}, {}
        if bossAt == at then
            advanceBoss(round, at, chooseTarget, checkBoss, hits)
        end
        for index, side in round.sides do
            if standing(side) then
                local hitAt, tileAt, finishAt = Fighter.nextContacts(side)
                collectFighter(round, index, at, hitAt, tileAt, checkPlayer, hits)
                if finishAt == at then
                    table.insert(clipsEnding, side)
                end
            end
        end
        for _, side in clipsEnding do
            Fighter.complete(side, at)
        end
        applyHits(round, hits)
        settled(round, at)
        if not round.result then
            -- A damaging strike at the exact end of a channel interrupts it.
            validateRevives(round, at, checkRevive)
            completeRevives(round, at)
        end
    end
    round.steppedAt = limit
    if not round.result and now >= round.endsAt then
        finish(round, round.endsAt, "loss", "timeout")
    end
end

return table.freeze(Raid)
