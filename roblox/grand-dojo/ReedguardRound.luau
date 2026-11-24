-- All combat times use the server clock. Input schedules a clip, and each
-- contact is consumed once when its authored frame is reached.
local Reedguard = require(script.Parent.ReedguardCombatPoses)
local Penguin = require(script.Parent.PenguinCombatPoses)
local Silverback = require(script.Parent.SilverbackCombatPoses)
local Salamander = require(script.Parent.FireSalamanderCombatPoses)
local Round = {}

Round.INTRO = 10
Round.OUTRO = 2.55
Round.DURATION = 60
Round.PARRY_WINDOW = .28
Round.GUARD_RAISE = .055
Round.GUARD_DURATION = .64
Round.CLIPS = {
    jab = {{at = Reedguard.Contact.jab, damage = 13, zone = "head"}},
    cross = {{at = Reedguard.Contact.cross, damage = 14, zone = "body"}},
    body = {{at = Reedguard.Contact.body, damage = 15, zone = "body"}},
    uppercut = {{at = Reedguard.Contact.uppercut, damage = 16, zone = "head"}},
    heavy = {{at = Reedguard.Contact.heavy, damage = 22, zone = "body"}},
    reedstep = {
        {at = Reedguard.Contact.reedstep[1], damage = 9, zone = "body"},
        {at = Reedguard.Contact.reedstep[2], damage = 9, zone = "body"},
        {at = Reedguard.Contact.reedstep[3], damage = 14, zone = "head"},
    },
}

local penguinClips = {
    jab = {{at = Penguin.Contact.jab, damage = 12, zone = "body"}},
    cross = {{at = Penguin.Contact.cross, damage = 13, zone = "head"}},
    body = {{at = Penguin.Contact.body, damage = 14, zone = "body"}},
    heavy = {{at = Penguin.Contact.heavy, damage = 20, zone = "body"}},
    bellySlide = {},
}
for _, time in Penguin.Contact.bellySlide do
    table.insert(penguinClips.bellySlide, {at = time, damage = 30, zone = "body", singleHit = true})
end

local seismic = Silverback.Skill.seismicChestPound
local silverbackClips = {
    jab = {{at = Silverback.Contact.jab, damage = 14, zone = "head"}},
    cross = {{at = Silverback.Contact.cross, damage = 15, zone = "body"}},
    body = {{at = Silverback.Contact.body, damage = 16, zone = "body"}},
    heavy = {{at = Silverback.Contact.heavy, damage = 23, zone = "body"}},
    ridgePalm = {{at = Silverback.Contact.ridgePalm, damage = 20, zone = "body"}},
    seismicChestPound = {{
        at = Silverback.Contact.seismicChestPound, damage = 34, zone = "body",
        shape = "radial", center = seismic.center, radius = seismic.radius,
    }},
}

local ember = Salamander.Skill.emberSweep
local magma = Salamander.Skill.magmaTrail
local salamanderClips = {
    jab = {{at = Salamander.Contact.jab, damage = 14, zone = "head"}},
    cross = {{at = Salamander.Contact.cross, damage = 14, zone = "head"}},
    body = {{at = Salamander.Contact.body, damage = 15, zone = "body"}},
    heavy = {{at = Salamander.Contact.heavy, damage = 21, zone = "body"}},
    emberSweep = {{
        at = Salamander.Contact.emberSweep, damage = ember.damage, zone = "body",
        shape = "fan", center = ember.center, radius = ember.radius, halfAngle = ember.halfAngle,
    }},
}

-- The mat owns these events once the cast begins. A later clip can stop
-- planting but cannot cancel a timer on a tile that already reached the mat.
local magmaTimeline = {}
for index, tile in magma.tiles do
    table.insert(magmaTimeline, {
        at = tile.markAt, index = index, marker = true,
        shape = "tile", center = tile.offset, radius = magma.radius, markAt = tile.markAt,
    })
    table.insert(magmaTimeline, {
        at = Salamander.Contact.magmaTrail[index], index = index, damage = magma.tileDamage, zone = "body",
        shape = "tile", center = tile.offset, radius = magma.radius, markAt = tile.markAt,
    })
end
table.sort(magmaTimeline, function(a, b)
    return a.at < b.at
end)

local kits = {
    reedguard = {
        poses = Reedguard, clips = Round.CLIPS, botStartRange = 3.65, botAttackLabel = "palm",
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .85, signature = "reedstep",
    },
    penguin = {
        poses = Penguin, clips = penguinClips, botStartRange = 3.35,
        dodge = "floeTurn", dodgeCue = "floeTurn", dodgeCooldown = 1.05,
        signature = "bellySlide", signatureCooldown = 7, signatureCooling = "slideCooling",
    },
    silverback = {
        poses = Silverback, clips = silverbackClips, botStartRange = 4.05,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .98,
        signature = "seismicChestPound", signatureCooldown = 7.8, signatureCooling = "seismicCooling",
        secondary = "ridgePalm", secondaryCooldown = 3.4, secondaryCooling = "ridgeCooling",
    },
    salamander = {
        poses = Salamander, clips = salamanderClips, botStartRange = 3.80,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .78,
        signature = "magmaTrail", signatureCooldown = 7.4, signatureCooling = "magmaCooling",
        secondary = "emberSweep", secondaryCooldown = 3.2, secondaryCooling = "emberCooling",
    },
}
local combo = {jab = "cross", cross = "body"}
local PARRY_COUNTER_TIME = 2.4

function Round.new(now, bot, fighter, kitId)
    local kit = kits[kitId or "reedguard"]
    assert(kit, "Unknown combat kit")
    local startsAt = now + Round.INTRO
    return {
        kit = kit,
        introAt = now, startsAt = startsAt, endsAt = startsAt + Round.DURATION,
        playerHealth = fighter.health, playerMaxHealth = fighter.health,
        botHealth = bot.health, botMaxHealth = bot.health,
        botPhase = "ready", botAt = startsAt + .58, attackIndex = 0, attacks = bot.attacks,
        playerStunUntil = 0, nextGuard = startsAt, nextDodge = startsAt,
        guardFrom = 0, guardUntil = 0, signatureUntil = 0, notices = {},
        nextSignature = if kit.signatureCooldown then startsAt else nil,
        nextSecondary = if kit.secondaryCooldown then startsAt else nil,
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
    local trail = round.trail
    if trail and round.clip == trail.clip and at < trail.clip.endsAt then
        trail.interruptedAt = at
    end
    local duration = if action == "guard" then Round.GUARD_DURATION else round.kit.poses.Duration[action]
    round.clip = {action = action, startedAt = at, endsAt = at + duration, nextContact = 1}
end

local function nextLight(round, at)
    local last = round.lastLight
    local action = if last and at <= round.comboUntil then combo[last] or "jab" else "jab"
    round.lastLight, round.comboUntil = action, at + round.kit.poses.Duration[action] + .55
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
    local kit = round.kit
    if action == "strike" then
        round.guardUntil = 0
        return nextLight(round, now)
    elseif action == "guard" and now >= round.nextGuard then
        round.nextGuard = now + .74
        round.guardFrom, round.guardUntil = now, now + Round.GUARD_DURATION
        play(round, "guard", now)
        return "guard"
    elseif action == "heavy" or (action == "uppercut" and kit.clips.uppercut) then
        round.guardUntil = 0
        play(round, action, now)
        return action
    elseif action == "dodge" and now >= round.nextDodge then
        round.nextDodge, round.guardUntil = now + kit.dodgeCooldown, 0
        play(round, kit.dodge, now)
        round.clip.direction = if direction == -1 then -1 else 1
        return kit.dodgeCue
    elseif action == "secondary" and kit.secondary then
        if now < round.nextSecondary then
            return kit.secondaryCooling
        end
        round.nextSecondary, round.guardUntil = now + kit.secondaryCooldown, 0
        play(round, kit.secondary, now)
        return kit.secondary
    elseif action == "signature" then
        if kit.signatureCooldown then
            if now < round.nextSignature then
                return kit.signatureCooling
            end
            round.nextSignature = now + kit.signatureCooldown
        elseif now > round.signatureUntil then
            return "needParry"
        end
        round.signatureUntil, round.guardUntil = 0, 0
        play(round, kit.signature, now)
        if kit == kits.salamander then
            round.trail = {
                startedAt = now, clip = round.clip, nextEvent = 1, planted = {}, remainingDamage = magma.damageBudget,
            }
        end
        return kit.signature
    end
end

local function landContact(round, at, fields)
    local brace = round.botPhase == "setup" and round.attack.brace
    local counter = round.botPhase == "recovery" and round.recoveryKind == "parried"
    local damage = if brace then math.ceil(fields.damage / 2) else fields.damage
    round.botHealth = math.max(0, round.botHealth - damage)
    fields.damage = damage
    report(round, if brace then "braced" elseif counter then "counter" else "strike", at, fields)
    if round.botHealth == 0 then
        round.result = "win"
    end
    return damage
end

local function contact(round, clip, at, check)
    local attacks = round.kit.clips[clip.action]
    local move = attacks[clip.nextContact]
    local index = clip.nextContact
    clip.nextContact += 1
    if move.singleHit and clip.connected then
        return
    end
    local hit, point, resolvedZone
    if round.kit == kits.salamander then
        hit, point, resolvedZone = check(clip.action, move, at, index, clip.startedAt)
    else
        hit, point, resolvedZone = check(clip.action, move, at, index)
    end
    if not hit then
        if not move.singleHit or index == #attacks then
            report(round, "miss", at, {attack = clip.action, index = index, point = point})
        end
        return
    end
    if move.singleHit then
        clip.connected = true
    end
    landContact(round, at,
        {attack = clip.action, index = index, point = point, zone = resolvedZone or move.zone, damage = move.damage})
end

local function advanceTrail(round, trail, move, at, check)
    trail.nextEvent += 1
    if trail.nextEvent > #magmaTimeline then
        round.trail = nil
    end
    local index = move.index
    if move.marker then
        if not trail.interruptedAt or at <= trail.interruptedAt then
            trail.planted[index] = check("magmaTrail", move, at, index, trail.startedAt)
        end
        return
    end
    if not trail.planted[index] or trail.remainingDamage <= 0 then
        return
    end
    local hit, point, resolvedZone = check("magmaTrail", move, at, index, trail.startedAt)
    if not point then
        return
    end
    local fields = {attack = "magmaTrail", index = index, point = point, castStartedAt = trail.startedAt}
    if hit then
        fields.zone, fields.damage = resolvedZone or move.zone, math.min(move.damage, trail.remainingDamage)
        trail.remainingDamage -= landContact(round, at, fields)
    else
        report(round, "miss", at, fields)
    end
end

local function advanceBot(round, at, distance, check)
    if round.botPhase == "ready" then
        if distance > round.kit.botStartRange then
            round.botAt = at + .12
            return
        end
        round.attackIndex = round.attackIndex % #round.attacks + 1
        round.attack = round.attacks[round.attackIndex]
        round.botPhase = if round.attack.setup then "setup" else "windup"
        round.botStartedAt = at
        round.botAt = at + (if round.botPhase == "setup" then round.attack.setupTime else round.attack.windup)
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
            if not round.kit.signatureCooldown then
                round.signatureUntil = at + PARRY_COUNTER_TIME
            end
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
        report(round, result, at, {source = "bot", attack = round.kit.botAttackLabel or round.attack.name, zone = zone, point = point,
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
    if round.botPhase == "ready" and round.botAt < now - .2 and distance > round.kit.botStartRange then
        round.botAt = now + .1
    end
    while not round.result do
        local clip = round.clip
        local attacks = clip and round.kit.clips[clip.action]
        local hit = attacks and attacks[clip.nextContact]
        local contactAt = if hit then clip.startedAt + hit.at else math.huge
        local trail = round.trail
        local markOrBurst = trail and magmaTimeline[trail.nextEvent]
        local trailAt = if markOrBurst then trail.startedAt + markOrBurst.at else math.huge
        local completeAt = clip and clip.endsAt or math.huge
        local eventAt = math.min(contactAt, trailAt, completeAt, round.botAt)
        if eventAt > limit then
            break
        elseif eventAt == contactAt then
            contact(round, clip, eventAt, checkPlayer)
        elseif eventAt == trailAt then
            advanceTrail(round, trail, markOrBurst, eventAt, checkPlayer)
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
