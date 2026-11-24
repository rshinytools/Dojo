local Spar = require(script.Parent.ReedguardRound)
local Elements = require(script.Parent.DuelRankRules)
local Combatant = Spar.Combatant
local Brawl = {INTRO = Spar.INTRO, DURATION = Spar.DURATION, OUTRO = Spar.OUTRO}

local NEUTRAL_SCALE = Elements.matchup(nil, nil).damageScale
local HIT_STUN, PARRY_STUN = .28, .56

function Brawl.new(now, entrants)
    assert(#entrants >= 2 and #entrants <= 8, "Brawl requires two to eight entrants")
    local sides = {}
    for index, entrant in entrants do
        local kitId = entrant.kitId or "reedguard"
        local side = Combatant.new(now, entrant.fighter, kitId)
        local level = entrant.level or 1
        assert(type(level) == "number" and level >= 1 and level < math.huge and level % 1 == 0,
            "Brawl requires a valid fighter level")
        assert(side.playerHealth > 0 and side.playerHealth < math.huge, "Brawl requires positive fighter health")
        local scale = 1 + (level - 1) * .04
        side.kitId, side.eliminated = kitId, false
        side.playerHealth = math.round(side.playerHealth * scale)
        side.playerMaxHealth = side.playerHealth
        side.matchups = {}
        for defenderIndex, defender in entrants do
            if defenderIndex ~= index then
                local element = Elements.matchup(entrant.fighter.element, defender.fighter.element)
                element.damageScale = element.damageScale / NEUTRAL_SCALE * scale
                side.matchups[defenderIndex] = element
            end
        end
        sides[index] = side
    end
    return {introAt = now, startsAt = sides[1].startsAt, endsAt = sides[1].endsAt,
        sides = sides, remaining = #sides, notices = {}}
end

function Brawl.act(round, index, action, now, direction)
    local side = round.sides[index]
    if round.result or not side or side.eliminated then
        return nil
    end
    return Spar.act(side, action, now, direction)
end

function Brawl.threat(round, attackerIndex)
    local side = round.sides[attackerIndex]
    if round.result or not side or side.eliminated then
        return nil
    end
    local contactAt, action = Combatant.nextThreat(side)
    if contactAt <= round.endsAt then
        return contactAt - Spar.PARRY_WINDOW, contactAt, action
    end
    return nil
end

local function finish(round, at, reason, leaders)
    local winners, outcomes, placements = {}, {}, {}
    for index, side in round.sides do
        outcomes[index] = "loss"
        side.placement = side.placement or 1
        placements[index] = side.placement
    end
    if #leaders == 1 then
        local winner = leaders[1]
        winners[1], outcomes[winner] = winner, "win"
    else
        for _, index in leaders do
            outcomes[index] = "draw"
        end
    end
    for index, side in round.sides do
        side.result = outcomes[index]
    end
    round.result = {winners = winners, outcomes = outcomes, placements = placements, reason = reason}
    round.resolvedAt, round.outroAt = at, at + Brawl.OUTRO
end

function Brawl.eliminateMany(round, exits, now)
    if round.result then
        return false
    end
    local removed = {}
    for _, exit in exits do
        local side = round.sides[exit.index]
        if side and not side.eliminated then
            side.eliminated, side.eliminatedAt, side.eliminationReason = true, now, exit.reason
            side.playerHealth, side.clip, side.trail = 0, nil, nil
            round.remaining -= 1
            table.insert(removed, exit.index)
        end
    end
    if #removed == 0 then
        return false
    end
    for _, index in removed do
        round.sides[index].placement = round.remaining + 1
    end
    if round.remaining == 0 then
        finish(round, now, "simultaneous", removed)
    elseif round.remaining == 1 then
        for index, side in round.sides do
            if not side.eliminated then
                finish(round, now, "last-standing", {index})
                break
            end
        end
    end
    return true
end

function Brawl.eliminate(round, index, reason, now)
    return Brawl.eliminateMany(round, {{index = index, reason = reason}}, now)
end

local function defense(side, at, facing)
    if not facing or at < side.guardFrom + Spar.GUARD_RAISE or at > side.guardUntil then
        return nil
    end
    return if side.guardFrom >= at - Spar.PARRY_WINDOW then "parried" else "blocked"
end

local function collect(round, index, at, clipAt, trailAt, check, batch)
    if clipAt ~= at and trailAt ~= at then
        return
    end
    local attacker = round.sides[index]
    local targets
    local function sample(action, move, contactAt, sampleIndex, castStartedAt)
        local contacts, missPoint = check(index, action, move, contactAt, sampleIndex, castStartedAt)
        if move.marker or move.launch then
            return contacts == true, missPoint
        end
        local clip = attacker.clip
        local used = move.singleHit and clip and clip.brawlHits or {}
        if move.singleHit then
            clip.brawlHits = used
        end
        targets = {}
        for _, hit in contacts or {} do
            local defender = round.sides[hit.defender]
            if defender and attacker.matchups[hit.defender] and not defender.eliminated and not used[hit.defender] then
                used[hit.defender] = true
                table.insert(targets, hit)
                if not move.shape and not move.singleHit then
                    break
                end
            end
        end
        local first = targets[1]
        return first ~= nil, if first then first.point or missPoint else missPoint, first and first.zone,
            first and first.facing
    end
    local function resolve(_, contactAt, fields, hit, _, move)
        fields.attacker, fields.at = index, contactAt
        if not hit then
            if move.singleHit and attacker.clip.brawlHits and next(attacker.clip.brawlHits) then
                return 0
            end
            fields.kind, fields.damage = "miss", 0
            table.insert(batch, fields)
            return 0
        end
        local spent = 0
        for _, target in targets do
            local defender = round.sides[target.defender]
            local notice = table.clone(fields)
            notice.defender = target.defender
            notice.zone = target.zone or move.zone
            notice.point = target.point or fields.point
            if clipAt == contactAt and attacker.clip.tagEntry then
                notice.tagEntry = true
            end
            local deflected = Combatant.deflects(defender, contactAt, move)
            notice.kind = if deflected then "blocked" else defense(defender, contactAt, target.facing)
            notice.deflected = if deflected then true else nil
            if move.controlOnly then
                notice.kind = if notice.kind then "blocked" else "pull"
                notice.damage = 0
            elseif notice.kind then
                notice.damage = 0
            else
                notice.kind = if defender.counterUntil and contactAt < defender.counterUntil then "counter" else "strike"
                local matchup = attacker.matchups[target.defender]
                notice.damage = math.round(fields.damage * matchup.damageScale)
                notice.elementEffect, notice.knockbackScale = matchup.elementEffect, matchup.knockbackScale
                spent = fields.damage
            end
            notice.detached = move.shape == "tile" or move.projectile ~= nil
            table.insert(batch, notice)
        end
        -- Each tile spends the authored cast budget once, regardless of how many fighters it catches.
        return spent
    end
    if clipAt == at then
        Combatant.contact(attacker, at, sample, resolve, true)
        -- Belly Slide consumes each victim once for the whole cast, while later sweeps can reach new victims.
        attacker.clip.connected = nil
    end
    if trailAt == at then
        Combatant.advanceTrail(attacker, at, sample, resolve)
    end
end

local function reaction(plan, action, priority, stun)
    if priority > plan.priority then
        plan.action, plan.priority = action, priority
    end
    plan.stun = math.max(plan.stun, stun)
end

local function resolveBatch(round, at, notices, eliminateMany)
    local plans = {}
    for index in round.sides do
        plans[index] = {damage = 0, priority = 0, stun = 0}
    end
    for _, event in notices do
        local attacker, defender = plans[event.attacker], plans[event.defender]
        if event.damage > 0 then
            defender.damage += event.damage
            local head = event.zone == "head"
            reaction(defender, if head then "hitHead" else "hitBody", if head then 5 else 4, HIT_STUN)
        elseif event.kind == "parried" then
            reaction(defender, "parry", 3, 0)
            defender.parried = true
            if not event.detached then
                reaction(attacker, "stagger", 2, PARRY_STUN)
                attacker.counterUntil = at + PARRY_STUN
            end
        elseif event.kind == "blocked" and not event.deflected and not event.controlOnly then
            reaction(defender, "block", 1, 0)
        end
        table.insert(round.notices, event)
    end
    local knockedOut = {}
    for index, side in round.sides do
        if not side.eliminated then
            local plan = plans[index]
            side.playerHealth = math.max(0, side.playerHealth - plan.damage)
            if side.playerHealth == 0 then
                table.insert(knockedOut, {index = index, reason = "knockout"})
            elseif plan.action then
                side.guardUntil, side.bufferedLight = 0, false
                side.playerStunUntil = math.max(side.playerStunUntil, at + plan.stun)
                Combatant.play(side, plan.action, at)
            end
            if plan.parried and not side.kit.signatureCooldown then
                side.signatureUntil = at + Combatant.PARRY_COUNTER_TIME
            end
            if plan.counterUntil then
                side.counterUntil = plan.counterUntil
            end
        end
    end
    eliminateMany(round, knockedOut, at)
end

local function fractionDifference(a, b)
    return a.playerHealth * b.playerMaxHealth - b.playerHealth * a.playerMaxHealth
end

local function timeout(round)
    local survivors, leaders = {}, {}
    for index, side in round.sides do
        if not side.eliminated then
            table.insert(survivors, index)
        end
    end
    table.sort(survivors, function(a, b)
        local lead = fractionDifference(round.sides[a], round.sides[b])
        return lead > 0 or (lead == 0 and a < b)
    end)
    local previous, placement = nil, 1
    for position, index in survivors do
        local side = round.sides[index]
        if previous and fractionDifference(previous, side) > 0 then
            placement = position
        end
        side.placement = placement
        if placement == 1 then
            table.insert(leaders, index)
        end
        previous = side
    end
    finish(round, round.endsAt, "timeout", leaders)
end

function Brawl.step(round, now, check, eliminateMany, resolveTimeout)
    if round.result or now < round.startsAt then
        return
    end
    local limit = math.min(now, round.endsAt)
    while not round.result do
        local at = math.huge
        for _, side in round.sides do
            if not side.eliminated then
                at = math.min(at, Combatant.nextContacts(side))
            end
        end
        if at > limit then
            break
        end
        local notices, finishedClips = {}, {}
        for index, side in round.sides do
            if not side.eliminated then
                local clipAt, trailAt, finishAt = Combatant.nextContacts(side)
                collect(round, index, at, clipAt, trailAt, check, notices)
                if finishAt == at then
                    table.insert(finishedClips, side)
                end
            end
        end
        for _, side in finishedClips do
            Combatant.complete(side, at)
        end
        if #notices > 0 then
            resolveBatch(round, at, notices, eliminateMany or Brawl.eliminateMany)
        end
    end
    if not round.result and now >= round.endsAt then
        local finishOnTime = resolveTimeout or timeout
        finishOnTime(round)
    end
end

return Brawl
