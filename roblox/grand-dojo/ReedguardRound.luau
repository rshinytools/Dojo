-- All combat times use the server clock. Input schedules a clip, and each
-- contact is consumed once when its authored frame is reached.
local Reedguard = require(script.Parent.ReedguardCombatPoses)
local Penguin = require(script.Parent.PenguinCombatPoses)
local Silverback = require(script.Parent.SilverbackCombatPoses)
local Salamander = require(script.Parent.FireSalamanderCombatPoses)
local Frog = require(script.Parent.FrogCombatPoses)
local Otter = require(script.Parent.OtterCombatPoses)
local Sky = require(script.Parent.SkyFighterCombat)
local EmberAqua = require(script.Parent.EmberAquaCombat)
local Heavy = require(script.Parent.HeavyFighterCombat)
local Magma = require(script.Parent.MagmaFighterCombat)
local Thunder = require(script.Parent.ThunderFighterCombat)
local Apex = require(script.Parent.ApexFighterCombat)
local Abyss = require(script.Parent.AbyssFighterCombat)
local Inferno = require(script.Parent.InfernoFighterCombat)
local Storm = require(script.Parent.StormFighterCombat)
local FighterTactics = require(game:GetService("ReplicatedStorage"):WaitForChild("FighterTactics"))
local apexTimeline = Apex.zoneMoves()
local Round = {}
local reactions = {hitHead = true, hitBody = true, block = true, parry = true, stagger = true}

Round.INTRO = 10
Round.OUTRO = 2.55
Round.DURATION = 60
Round.PARRY_WINDOW = .28
Round.GUARD_RAISE = .055
Round.GUARD_DURATION = .64
Round.CLIPS = {
    jab = {{at = Reedguard.Contact.jab, damage = 13, zone = "head"}},
    cross = {{at = Reedguard.Contact.cross, damage = 14, zone = "body"}},
    body = {{at = Reedguard.Contact.body, damage = 15, zone = "body", foot = true, radius = .52}},
    uppercut = {{at = Reedguard.Contact.uppercut, damage = 16, zone = "head"}},
    reedSweep = {{at = Reedguard.Contact.reedSweep, damage = 13, zone = "body", foot = true, radius = .50}},
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
    icecrestPalm = {{at = Penguin.Contact.icecrestPalm, damage = 17, zone = "body", radius = .47}},
    floeHook = {{at = Penguin.Contact.floeHook, damage = 13, zone = "body", radius = .47}},
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
    canopyKnuckle = {{at = Silverback.Contact.canopyKnuckle, damage = 15, zone = "body", radius = .46}},
    ironbarkHammer = {{at = Silverback.Contact.ironbarkHammer, damage = 23, zone = "body", radius = .48}},
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
    coalstepKick = {{at = Salamander.Contact.coalstepKick, damage = 14, zone = "body", radius = .46, foot = true}},
    furnaceBacklash = {{at = Salamander.Contact.furnaceBacklash, damage = 22, zone = "body", radius = .48, foot = true}},
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

local lily, tornado = Frog.Skill.lilyVault, Frog.Skill.tadpoleTornado
local eddy, barrage = Otter.Skill.eddyPalm, Otter.Skill.pebbleBarrage
local frogClips = {
    jab = {{at = Frog.Contact.jab, damage = 12, zone = "head"}},
    cross = {{at = Frog.Contact.cross, damage = 13, zone = "body"}},
    body = {{at = Frog.Contact.body, damage = 14, zone = "body"}},
    heavy = {{at = Frog.Contact.heavy, damage = 20, zone = "body"}},
    lilyVault = {{at = Frog.Contact.lilyVault, damage = lily.damage, radius = lily.radius, zone = "body"}},
    tadpoleTornado = {{at = Frog.Contact.tadpoleTornado, damage = tornado.damage, shape = "radial",
        center = tornado.center, radius = tornado.radius, zone = "body"}},
}
local otterClips = {
    jab = {{at = Otter.Contact.jab, damage = 13, zone = "head"}},
    cross = {{at = Otter.Contact.cross, damage = 13, zone = "body"}},
    body = {{at = Otter.Contact.body, damage = 14, zone = "body"}},
    heavy = {{at = Otter.Contact.heavy, damage = 21, zone = "body"}},
    eddyPalm = {{at = Otter.Contact.eddyPalm, damage = eddy.damage, radius = eddy.radius, zone = "body"}},
    pebbleBarrage = {},
}
local SAMPLES_PER_PEBBLE, PEBBLE_FLIGHT = 5, .20
for index, release in Otter.Contact.pebbleBarrage do
    table.insert(otterClips.pebbleBarrage, {at = release, projectile = index, release = release, launch = true,
        radius = barrage.radius, flight = PEBBLE_FLIGHT})
    for step = 1, SAMPLES_PER_PEBBLE do
        table.insert(otterClips.pebbleBarrage, {
            at = release + PEBBLE_FLIGHT * step / SAMPLES_PER_PEBBLE,
            release = release, flight = PEBBLE_FLIGHT, projectile = index, damage = barrage.damage,
            radius = barrage.radius, zone = "body", from = (step - 1) / SAMPLES_PER_PEBBLE,
            to = step / SAMPLES_PER_PEBBLE, lastSample = step == SAMPLES_PER_PEBBLE,
        })
    end
end
table.sort(otterClips.pebbleBarrage, function(a, b)
    return a.at < b.at or (a.at == b.at and a.projectile < b.projectile)
end)

local kits = {
    reedguard = {
        poses = Reedguard, clips = Round.CLIPS,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .85, signature = "reedstep",
    },
    penguin = {
        poses = Penguin, clips = penguinClips,
        dodge = "floeTurn", dodgeCue = "floeTurn", dodgeCooldown = 1.05,
        signature = "bellySlide", signatureCooldown = 7, signatureCooling = "slideCooling",
        secondaryCooldown = 5, secondaryCooling = "penguinTacticalCooling",
    },
    silverback = {
        poses = Silverback, clips = silverbackClips,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .98,
        signature = "seismicChestPound", signatureCooldown = 7.8, signatureCooling = "seismicCooling",
        secondaryCooldown = 3.4, secondaryCooling = "ridgeCooling",
    },
    salamander = {
        poses = Salamander, clips = salamanderClips,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .78,
        signature = "magmaTrail", signatureCooldown = 7.4, signatureCooling = "magmaCooling",
        secondaryCooldown = 3.2, secondaryCooling = "emberCooling",
    },
    frog = {
        poses = Frog, clips = frogClips,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .76,
        signature = "tadpoleTornado", signatureCooldown = 7, signatureCooling = "tornadoCooling",
        secondary = "lilyVault", secondaryCooldown = 3.1, secondaryCooling = "lilyCooling",
    },
    otter = {
        poses = Otter, clips = otterClips,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .8,
        signature = "pebbleBarrage", signatureCooldown = 7.2, signatureCooling = "pebbleCooling",
        secondary = "eddyPalm", secondaryCooldown = 3, secondaryCooling = "eddyCooling",
    },
}
for id, kit in Sky.kits do
    kits[id] = kit
end
for id, kit in EmberAqua.kits do
    kits[id] = kit
end
for id, kit in Heavy.kits do
    kits[id] = kit
end
for id, kit in Magma.kits do
    kits[id] = kit
end
for id, kit in Thunder.kits do
    kits[id] = kit
end
for id, kit in Apex.kits do
    kits[id] = kit
end
for id, kit in Abyss.kits do
    kits[id] = kit
end
for id, kit in Inferno.kits do
    kits[id] = kit
end
for id, kit in Storm.kits do
    kits[id] = kit
end

local residents = {
    juniper = {startRange = 3.65, attackLabel = "palm"},
    bracken = {startRange = 3.35},
    sablecrest = {startRange = 4.05},
    granite = {startRange = 3.80},
}
local residentByOpener = {
    ["Stillwater Palm"] = "juniper",
    ["Kiln Rush"] = "bracken",
    ["Wind Court Return"] = "sablecrest",
    ["Harbor Sweep"] = "granite",
}
local combo = {jab = "cross", cross = "body"}
local PARRY_COUNTER_TIME = 2.4

local function newCombatant(now, fighter, kitId, timing, tactical)
    kitId = kitId or "reedguard"
    local kit = kits[kitId]
    assert(kit, "Unknown combat kit")
    local option = FighterTactics.forKit(kitId, tactical)
    local startsAt = now + (timing and timing.intro or Round.INTRO)
    return {
        kit = kit,
        tactical = option and option.id,
        introAt = now, startsAt = startsAt, endsAt = startsAt + (timing and timing.duration or Round.DURATION),
        playerHealth = fighter.health, playerMaxHealth = fighter.health,
        playerStunUntil = 0, nextGuard = startsAt, nextDodge = startsAt,
        guardFrom = 0, guardUntil = 0, signatureUntil = 0,
        nextSignature = if kit.signatureCooldown then startsAt else nil,
        nextSecondary = if kit.secondaryCooldown then startsAt else nil,
    }
end

function Round.new(now, bot, fighter, kitId, botId, tactical)
    local round = newCombatant(now, fighter, kitId, nil, tactical)
    if not botId then
        -- Earlier callers supplied the resident's attack profile without its ID.
        local opener = bot.attacks and bot.attacks[1]
        botId = (opener and residentByOpener[opener.name]) or "juniper"
    end
    local resident = residents[botId]
    assert(resident, "Unknown sparring resident")
    round.resident = resident
    round.botHealth, round.botMaxHealth = bot.health, bot.health
    round.botPhase, round.botAt, round.attackIndex = "ready", round.startsAt + .58, 0
    round.attacks, round.notices = bot.attacks, {}
    return round
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
    round.reaction = if reactions[action] then round.clip else nil
    if action == "tempestRoar" then
        round.clip.steerEndsAt = at + Storm.tempest.channelEnd
    end
end

local function missTalon(side, at)
    play(side, Storm.talon.missAction, at - Storm.talon.grabAt)
end

local function resolveTalon(sides, event, at)
    if not event.talonGrab then return end
    local attacker, defender = sides[event.attacker], sides[event.defender]
    local clip = attacker.clip
    if not clip or clip.action ~= "talonDrop" or clip.startedAt ~= event.castStartedAt then
        if event.kind == "talonCarry" then event.kind = "miss" end
        return
    end
    if event.kind == "talonCarry" then
        if defender and Storm.latch(attacker, defender, event.defender, at) then return end
        event.kind = "miss"
    end
    missTalon(attacker, at)
end

local function nextLight(round, at)
    local last = round.lastLight
    local action = if last and at <= round.comboUntil then combo[last] or "jab" else "jab"
    round.lastLight, round.comboUntil = action, at + round.kit.poses.Duration[action] + .55
    play(round, action, at)
    return action
end

local function jabReadyAt(round)
    local clipEnd = if round.clip then round.clip.endsAt else 0
    -- The continuation remains eligible on the exact expiry tick.
    local comboEnd = if combo[round.lastLight] then round.comboUntil + .001 else 0
    local ready = math.max(round.playerStunUntil, clipEnd, comboEnd)
    local hold = Storm.held(round, ready)
    return if hold then hold.endsAt + .001 else ready
end

local function inMotion(side, action)
    local travel = side.kit.poses.Travel
    return action == side.kit.dodge or action == "fortressRicochet" or action == "meteorRoll"
        or action == "apexPounce" or action == "jawsOfTheDeep" or action == "talonDrop" or (travel and travel[action] ~= nil)
end

local function applyRoot(side, at, duration)
    side.rootedUntil = math.max(side.rootedUntil or 0, at + duration)
    if side.clip and inMotion(side, side.clip.action) then
        side.clip, side.bufferedLight = nil, false
    end
end

local function interruptFixedTravel(side)
    local action = side.clip and side.clip.action
    if action == "fortressRicochet" or action == "meteorRoll" or action == "tidalBellyFlop"
        or action == "apexPounce" or action == "jawsOfTheDeep" or action == "talonDrop" then
        side.clip, side.bufferedLight = nil, false
    end
end

function Round.act(round, action, now, direction)
    if round.result or now < round.startsAt or now >= round.endsAt or now < round.playerStunUntil or Storm.held(round, now) then
        return
    end
    if action == "stormSteer" then
        Storm.steer(round.clip, direction, now)
        return
    end
    local kit = round.kit
    local secondary = kit.secondaryCooldown and (round.tactical or kit.secondary)
    local reedSweep = action == "secondary" and round.tactical == "reedSweep"
    if now < (round.rootedUntil or 0) then
        local attempted = if action == "secondary" then secondary
            elseif action == "signature" then kit.signature elseif action == "dodge" then kit.dodge else nil
        if attempted and inMotion(round, attempted) then
            return "snared"
        end
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
    elseif action == "heavy" or reedSweep or (action == "uppercut" and round.tactical == "uppercut") then
        local move = if reedSweep then "reedSweep" else action
        round.guardUntil = 0
        play(round, move, now)
        return move
    elseif action == "dodge" and now >= round.nextDodge then
        round.nextDodge, round.guardUntil = now + kit.dodgeCooldown, 0
        play(round, kit.dodge, now)
        round.clip.direction = if direction == -1 then -1 else 1
        return kit.dodgeCue
    elseif action == "secondary" and secondary then
        if now < round.nextSecondary then
            return kit.secondaryCooling
        end
        round.nextSecondary, round.guardUntil = now + kit.secondaryCooldown, 0
        play(round, secondary, now)
        round.clip.direction = if direction == -1 then -1 else 1
        return secondary
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
        if kit.frenzyTime then
            round.frenzyFrom, round.frenzyUntil = now, now + kit.frenzyTime
        elseif kit.signature == "apexPounce" then
            round.trail = {startedAt = now, clip = round.clip, nextEvent = 1, apex = true, remainingDamage = 0}
        elseif kit == kits.salamander then
            round.trail = {
                startedAt = now, clip = round.clip, nextEvent = 1, planted = {}, remainingDamage = magma.damageBudget,
            }
        end
        return kit.signature
    end
end

local function resolveBotContact(round, at, fields, hit, _, move)
    if move and move.shape == "talonGrab" then
        local brace = hit and round.botPhase == "setup" and round.attack.brace
        if hit and not brace then
            round.clip.talonTarget = 0
            round.botPhase, round.recoveryStartedAt, round.recoveryKind = "recovery", at, "talon"
            round.botAt = round.clip.startedAt + Storm.talon.impactAt + .38
            fields.damage = 0
            report(round, "talonCarry", at, fields)
        else
            missTalon(round, at)
            fields.damage = 0
            report(round, if brace then "braced" else "miss", at, fields)
        end
        return 0
    end
    if not hit then
        report(round, "miss", at, fields)
        return 0
    end
    local brace = round.botPhase == "setup" and round.attack.brace
    if fields.controlOnly then
        if fields.rootDuration and not brace then
            round.botRootedAt, round.botRootedUntil = at, math.max(round.botRootedUntil or 0, at + fields.rootDuration)
        end
        report(round, if brace then "braced" elseif fields.rootDuration then "snare" else "pull", at, fields)
        return 0
    end
    local counter = round.botPhase == "recovery" and round.recoveryKind == "parried"
    local guardBroken = brace and move and move.guardBreak
    local damage = if guardBroken then math.ceil(fields.damage * .55)
        elseif brace then math.ceil(fields.damage / 2) else fields.damage
    if guardBroken then
        round.botPhase, round.recoveryStartedAt = "recovery", at
        round.recoveryKind, round.botAt = "hit", at + .52
    elseif not brace and move and move.shockDuration then
        round.botPhase, round.recoveryStartedAt = "recovery", at
        round.recoveryKind, round.botAt = "shocked", at + move.shockDuration
        fields.shockDuration = move.shockDuration
    elseif not brace and move and move.burnDamage then
        Magma.ignite(round, nil, 0, round, at, move.burnDamage)
    end
    round.botHealth = math.max(0, round.botHealth - damage)
    fields.damage = damage
    report(round, if guardBroken then "guardBroken" elseif brace then "braced" elseif counter then "counter" else "strike", at, fields)
    if round.botHealth == 0 then
        round.result = "win"
    end
    return damage
end

local signatureBeat = {reedstep = 3, featherFlurry = 3, gustVortex = 2, unstoppableFrenzy = 4}
local groundedSignature = {
    reedstep = true, seismicChestPound = true, tadpoleTornado = true, gustVortex = true,
    tidalBellyFlop = true, staticCharge = true, apexPounce = true, jawsOfTheDeep = true,
    unstoppableFrenzy = true,
}

local function contactPresentation(kit, clip, move, index, fields)
    local attack = clip.action
    if attack == "body" and not clip.tagEntry then
        fields.poseHold = .04
        fields.holdKick = move.foot or kit == kits.rooster
    elseif attack == kit.signature and not move.controlOnly
        and (not signatureBeat[attack] or signatureBeat[attack] == index)
        and (attack ~= "tempestRoar" or move.shape == "stormThunder") then
        fields.signatureCast = clip.startedAt
        if groundedSignature[attack] then fields.poseHold = .08 end
    end
    if fields.poseHold then
        fields.poseAt, fields.poseDirection = move.at, clip.direction
    end
end

local function contact(round, at, check, resolve, publishCast, multipleDefenders)
    local clip = round.clip
    local attacks = round.kit.clips[clip.action]
    local move = attacks[clip.nextContact]
    local index = clip.nextContact
    clip.nextContact += 1
    if move.shape == "talonThrow" and clip.talonTarget == nil then return end
    if move.projectile then
        index = move.projectile
        clip.projectiles = clip.projectiles or {}
        if clip.projectiles[index] then
            return
        end
    end
    if move.singleHit and clip.connected then
        return
    end
    local hit, point, resolvedZone, facing
    if publishCast or round.kit == kits.salamander or move.projectile or move.lockedCenter
        or move.shape == "snare" or move.shape == "wave" or move.shape == "ricochet" or move.shape == "breath"
        or move.thunder or move.apex or move.abyss or move.shape == "tentacle" or move.detached or Storm.isCast(clip.action) then
        hit, point, resolvedZone, facing = check(clip.action, move, at, index, clip.startedAt)
    else
        hit, point, resolvedZone = check(clip.action, move, at, index)
    end
    if move.launch or (move.projectile and not hit and not move.lastSample) then
        return
    end
    if hit and move.maxContacts and not multipleDefenders then
        local group = move.contactGroup or 0
        clip.contactCounts = clip.contactCounts or {}
        local contacts = clip.contactCounts[group] or 0
        if contacts >= move.maxContacts then return end
        clip.contactCounts[group] = contacts + 1
    elseif not hit and move.silentMiss then
        return
    end
    if move.projectile and hit then
        clip.projectiles[index] = true
    end
    if not hit and move.singleHit and index ~= #attacks then
        return
    end
    if hit and move.singleHit then
        clip.connected = true
    end
    local fields = {attack = clip.action, index = index, point = point, projectile = move.projectile, controlOnly = move.controlOnly,
        rootDuration = move.rootDuration, stormThunder = if move.shape == "stormThunder" then true else nil,
        talonGrab = if move.shape == "talonGrab" then true else nil,
        castStartedAt = if publishCast or move.shape == "breath" or move.guardBreak or move.thunder
            or move.apex or move.abyss or move.shape == "tentacle" or move.detached or Storm.isCast(clip.action)
            then clip.startedAt else nil}
    if hit then
        fields.zone, fields.damage = resolvedZone or move.zone, move.damage
        contactPresentation(round.kit, clip, move, index, fields)
    end
    resolve(round, at, fields, hit, facing, move)
end

local function advanceTrail(round, at, check, resolve)
    local trail = round.trail
    local timeline = if trail.apex then apexTimeline else magmaTimeline
    local move = timeline[trail.nextEvent]
    trail.nextEvent += 1
    if trail.nextEvent > #timeline then
        round.trail = nil
    end
    if trail.apex then
        if move.marker then
            trail.planted = (not trail.interruptedAt or at <= trail.interruptedAt)
                and check("apexPounce", move, at, 1, trail.startedAt)
        elseif trail.planted then
            local hit, point, zone, facing = check("apexPounce", move, at, trail.nextEvent - 1, trail.startedAt)
            if hit then
                resolve(round, at, {attack = "apexPounce", point = point, zone = zone, damage = 0,
                    controlOnly = true, rootDuration = move.rootDuration, castStartedAt = trail.startedAt}, true, facing, move)
            end
        end
        return
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
    local hit, point, resolvedZone, facing = check("magmaTrail", move, at, index, trail.startedAt)
    if not point then
        return
    end
    local fields = {attack = "magmaTrail", index = index, point = point, castStartedAt = trail.startedAt}
    if hit then
        fields.zone, fields.damage = resolvedZone or move.zone, math.min(move.damage, trail.remainingDamage)
        fields.signatureCast = trail.startedAt
    end
    trail.remainingDamage -= resolve(round, at, fields, hit, facing, move)
end

local function nextContacts(round)
    local clip = round.clip
    local attacks = clip and round.kit.clips[clip.action]
    local hit = attacks and attacks[clip.nextContact]
    local trail = round.trail
    local markOrBurst = trail and (if trail.apex then apexTimeline else magmaTimeline)[trail.nextEvent]
    return if hit then clip.startedAt + hit.at else math.huge,
        if markOrBurst then trail.startedAt + markOrBurst.at else math.huge,
        if clip then clip.endsAt else math.huge
end

local function completeClip(round, at)
    if round.reaction and round.clip == round.reaction then
        round.reaction.expired = true
    end
    round.clip = nil
    if round.bufferedLight then
        round.bufferedLight = false
        nextLight(round, at)
    end
end

local function deflects(round, time, move)
    local clip = round.clip
    if not move.projectile or not clip or clip.action ~= "tadpoleTornado" then
        return false
    end
    local age = time - clip.startedAt
    return age >= tornado.deflectFrom and age <= tornado.deflectUntil
end

local function nextThreat(round)
    local earliest, action = math.huge, nil
    local clip = round.clip
    local attacks = clip and round.kit.clips[clip.action]
    if attacks then
        for index = clip.nextContact, #attacks do
            local strike = attacks[index]
            if not strike.launch and strike.shape ~= "talonThrow" and not (strike.singleHit and clip.connected)
                and not (strike.projectile and clip.projectiles and clip.projectiles[strike.projectile]) then
                earliest, action = clip.startedAt + strike.at, clip.action
                break
            end
        end
    end
    local trail = round.trail
    if trail and trail.remainingDamage > 0 then
        for index = trail.nextEvent, #magmaTimeline do
            local move = magmaTimeline[index]
            local at = trail.startedAt + move.at
            if not move.marker and trail.planted[move.index] and at < earliest then
                earliest, action = at, "magmaTrail"
                break
            end
        end
    end
    return earliest, action
end

local function advanceBot(round, at, distance, check)
    if round.botPhase == "ready" then
        if distance > round.resident.startRange then
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
        local submerged = Abyss.submerged(round, at)
        hit = hit and not submerged
        round.botPhase, round.recoveryStartedAt = "recovery", at
        local guarded = hit and facing and at >= round.guardFrom + Round.GUARD_RAISE and at <= round.guardUntil
        local parried = guarded and round.guardFrom >= at - Round.PARRY_WINDOW
        local result = if submerged then "submerged" elseif not hit then "dodged"
            elseif parried then "parried" elseif guarded then "blocked" else "hit"
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
            round.playerHealth = math.max(0, round.playerHealth - round.attack.damage)
            if not Apex.unstoppable(round, at) then
                round.bufferedLight = false
                play(round, if zone == "head" then "hitHead" else "hitBody", at)
                round.playerStunUntil = at + .28
            end
            if round.playerHealth == 0 then
                round.result = "loss"
            end
        end
        report(round, result, at, {source = "bot", attack = round.resident.attackLabel or round.attack.name, zone = zone, point = point,
            frenzyResist = result == "hit" and Apex.unstoppable(round, at),
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
    if round.botPhase == "ready" and round.botAt < now - .2 and distance > round.resident.startRange then
        round.botAt = now + .1
    end
    while not round.result do
        local contactAt, trailAt, completeAt = nextContacts(round)
        local burnAt = Magma.nextBurn(round)
        local eventAt = math.min(contactAt, trailAt, completeAt, round.botAt, burnAt)
        if eventAt > limit then
            break
        elseif eventAt == burnAt then
            for _, event in Magma.burnsAt(round, burnAt) do
                event.damage = math.min(event.damage, round.botHealth)
                round.botHealth -= event.damage
                table.insert(round.notices, event)
            end
            if round.botHealth == 0 then round.result = "win" end
        elseif eventAt == contactAt then
            contact(round, eventAt, checkPlayer, resolveBotContact)
        elseif eventAt == trailAt then
            advanceTrail(round, eventAt, checkPlayer, resolveBotContact)
        elseif eventAt == completeAt then
            completeClip(round, eventAt)
        else
            advanceBot(round, eventAt, distance, checkBot)
        end
    end
    if not round.result and now >= round.endsAt then
        local lead = round.playerHealth * round.botMaxHealth - round.botHealth * round.playerMaxHealth
        round.result = if lead > 0 then "win" elseif lead < 0 then "loss" else "draw"
    end
end

Round.Combatant = table.freeze({
    new = newCombatant,
    play = play,
    jabReadyAt = jabReadyAt,
    complete = completeClip,
    nextContacts = nextContacts,
    nextThreat = nextThreat,
    contact = contact,
    deflects = deflects,
    applyRoot = applyRoot,
    interruptFixedTravel = interruptFixedTravel,
    advanceTrail = advanceTrail,
    missTalon = missTalon,
    resolveTalon = resolveTalon,
    held = Storm.held,
    unstoppable = Apex.unstoppable,
    submerged = Abyss.submerged,
    PARRY_COUNTER_TIME = PARRY_COUNTER_TIME,
})

return Round
