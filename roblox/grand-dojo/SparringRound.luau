-- Spar timing, health and receipts are server authoritative. Geometry is measured by the venue.
local Round = {}

Round.DURATION = 60
Round.AGGRO_RANGE = 7.7
Round.STRIKE_RANGE = 6.4
Round.PARRY_WINDOW = .32
Round.PARRY_RECOVERY_BONUS = .40

function Round.new(now, bot, fighter)
    local startsAt = now + 3
    return {
        startsAt = startsAt, endsAt = startsAt + Round.DURATION,
        playerHealth = fighter.health, playerMaxHealth = fighter.health, strikeDamage = fighter.normalHit,
        botHealth = bot.health, botMaxHealth = bot.health, botPhase = "ready", botAt = startsAt + .5,
        attacks = bot.attacks, attackIndex = 0, nextStrike = startsAt, nextGuard = startsAt, guardUntil = 0,
    }
end

function Round.parryOpensAt(round)
    return if round.botPhase == "windup" then round.botAt - Round.PARRY_WINDOW else nil
end

local function windup(round, now)
    round.botPhase = "windup"
    round.botAt = now + round.attack.windup
end

function Round.step(round, now, distance, canGuard, attackHits)
    if round.result or now < round.startsAt then
        return
    end
    if now >= round.endsAt then
        local lead = round.playerHealth * round.botMaxHealth - round.botHealth * round.playerMaxHealth
        round.result = if lead > 0 then "win" elseif lead < 0 then "loss" else "draw"
        return
    end
    if now < round.botAt then
        return
    end
    if round.botPhase == "setup" then
        windup(round, now)
    elseif round.botPhase == "windup" then
        local parry = round.parryFor == round.botAt
        round.parryFor = nil
        round.botPhase = "recovery"
        round.recoveryStartedAt = now
        round.botAt = now + round.attack.recovery
        if not attackHits then
            return "dodged"
        end
        if canGuard and now <= round.guardUntil then
            if parry then
                round.botAt += Round.PARRY_RECOVERY_BONUS
                return "parried"
            end
            return "blocked"
        end
        round.playerHealth = math.max(0, round.playerHealth - round.attack.damage)
        if round.playerHealth == 0 then
            round.result = "loss"
        end
        return "hit"
    elseif round.botPhase == "recovery" then
        round.botPhase = "ready"
        round.botAt = now + .55
    elseif distance <= Round.AGGRO_RANGE then
        round.attackIndex = round.attackIndex % #round.attacks + 1
        round.attack = round.attacks[round.attackIndex]
        if round.attack.setup then
            round.botPhase = "setup"
            round.botAt = now + round.attack.setupTime
        else
            windup(round, now)
        end
    end
end

function Round.act(round, action, now, distance, facing)
    if round.result or now < round.startsAt or now >= round.endsAt then
        return
    end
    if action == "guard" and now >= round.nextGuard then
        round.nextGuard = now + 1.1
        round.guardUntil = now + .65
        local opensAt = Round.parryOpensAt(round)
        round.parryFor = if opensAt and now >= opensAt and now <= round.botAt
            and distance <= round.attack.reach and facing then round.botAt else nil
        return "guard"
    elseif action == "strike" and now >= round.nextStrike then
        round.nextStrike = now + .63
        if distance > Round.STRIKE_RANGE or not facing then
            return "miss"
        end
        local counter = round.botPhase == "recovery"
        local braced = round.botPhase == "setup" and round.attack.brace
        local damage = if counter then round.strikeDamage + 10
            elseif braced then math.ceil(round.strikeDamage / 2) else round.strikeDamage
        round.botHealth = math.max(0, round.botHealth - damage)
        if round.botHealth == 0 then
            round.result = "win"
        end
        return if counter then "counter" elseif braced then "braced" else "strike"
    end
end

return Round
