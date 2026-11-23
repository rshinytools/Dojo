-- Arena rules are evaluated with the server clock and measured contact.
local Round = {}

Round.PLAYER_HEALTH = 100
Round.BOT_HEALTH = 90
Round.DURATION = 55
Round.AGGRO_RANGE = 7.8
Round.STRIKE_RANGE = 6.4
Round.WINDUP = .9
Round.RECOVERY = .95
Round.PARRY_WINDOW = .32
Round.PARRY_RECOVERY_BONUS = .4

function Round.new(now)
    local startsAt = now + 3
    return {
        startsAt = startsAt, endsAt = startsAt + Round.DURATION,
        playerHealth = Round.PLAYER_HEALTH, botHealth = Round.BOT_HEALTH,
        botPhase = "ready", botAt = startsAt + .50,
        nextStrike = startsAt, nextGuard = startsAt, guardUntil = 0,
    }
end

function Round.parryOpensAt(round)
    return if round.botPhase == "windup" then round.botAt - Round.PARRY_WINDOW else nil
end

function Round.step(round, now, distance, canGuard)
    if round.result or now < round.startsAt then
        return
    end
    if now >= round.endsAt then
        -- Compare the percentage left in each corner using integer arithmetic.
        local lead = round.playerHealth * Round.BOT_HEALTH - round.botHealth * Round.PLAYER_HEALTH
        round.result = if lead > 0 then "win" elseif lead < 0 then "loss" else "draw"
        return
    end
    if now < round.botAt then
        return
    end
    if round.botPhase == "windup" then
        local parry = round.parryFor == round.botAt
        round.parryFor = nil
        round.botPhase = "recovery"
        round.recoveryStartedAt = now
        round.botAt = now + Round.RECOVERY
        if distance > Round.STRIKE_RANGE then
            return "dodged"
        end
        if canGuard and now <= round.guardUntil then
            if parry then
                round.botAt += Round.PARRY_RECOVERY_BONUS
                return "parried"
            end
            return "blocked"
        end
        round.playerHealth = math.max(0, round.playerHealth - 18)
        if round.playerHealth == 0 then
            round.result = "loss"
        end
        return "hit"
    elseif round.botPhase == "recovery" then
        round.botPhase = "ready"
        round.botAt = now + .70
    elseif distance <= Round.AGGRO_RANGE then
        round.botPhase = "windup"
        round.botAt = now + Round.WINDUP
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
            and distance <= Round.STRIKE_RANGE and facing then round.botAt else nil
        return "guard"
    elseif action == "strike" and now >= round.nextStrike then
        round.nextStrike = now + .63
        if distance > Round.STRIKE_RANGE or not facing then
            return "miss"
        end
        local counter = round.botPhase == "recovery"
        round.botHealth = math.max(0, round.botHealth - (if counter then 23 else 13))
        if round.botHealth == 0 then
            round.result = "win"
        end
        return if counter then "counter" else "strike"
    end
end

return Round
