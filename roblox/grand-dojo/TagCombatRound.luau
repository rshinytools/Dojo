local Spar = require(script.Parent.ReedguardRound)
local Rules = require(script.Parent.DuelRankRules)
local Group = require(script.Parent.BrawlCombatRound)
local Combatant = Spar.Combatant

local Tag = {INTRO = Spar.INTRO, DURATION = 90, OUTRO = Spar.OUTRO, TAG_COOLDOWN = 12, ENTRY_DELAY = .95}
local timing = {intro = Tag.INTRO, duration = Tag.DURATION}

local function newFighter(now, slot)
    local side = Combatant.new(now, slot.fighter, slot.kitId, timing, slot.loadout or slot.tactical)
    local maximum = Rules.health(slot.fighter.health)
    assert(maximum > 0 and maximum < math.huge, "Tag Team requires positive fighter health")
    side.kitId, side.element = slot.kitId, slot.fighter.element
    side.playerHealth, side.playerMaxHealth = maximum, maximum
    side.eliminated, side.matchups = false, {}
    return side
end

local function refreshMatchups(round)
    for index, side in round.sides do
        local team = round.lineup[index].team
        for rivalIndex, rival in round.sides do
            if round.lineup[rivalIndex].team ~= team then
                side.matchups[rivalIndex] = Rules.matchup(side.element, rival.element)
            end
        end
    end
end

function Tag.new(now, entrants)
    assert(#entrants == 4, "Tag Team requires exactly four entrants")
    local startsAt = now + Tag.INTRO
    local round = {introAt = now, startsAt = startsAt, endsAt = startsAt + Tag.DURATION,
        remaining = 4, sides = {}, lineup = {}, notices = {}}
    for index, entrant in entrants do
        assert(entrant.primary.kitId and entrant.backup.kitId
            and entrant.primary.kitId ~= entrant.backup.kitId, "Choose two distinct Tag Team fighters")
        local primary, backup = newFighter(now, entrant.primary), newFighter(now, entrant.backup)
        round.lineup[index] = {team = if index <= 2 then 1 else 2,
            active = 1, slots = {primary, backup}, nextTagAt = startsAt}
        round.sides[index] = primary
    end
    refreshMatchups(round)
    return round
end

function Tag.planTag(round, index, now)
    local line, side = round.lineup[index], round.sides[index]
    if not line or line.out or round.result or now < round.startsAt or now >= round.endsAt then
        return nil
    end
    local incomingIndex = 3 - line.active
    local incoming = line.slots[incomingIndex]
    if incoming.playerHealth <= 0 then
        return nil, nil, "noBackup"
    end
    if side.eliminated then
        if not line.entryAt or now < line.entryAt then
            return nil, nil, "waitingForEntry"
        end
    elseif now < line.nextTagAt then
        return nil, nil, "tagCooling"
    elseif now < side.playerStunUntil or Combatant.held(side, now) or (side.clip and now < side.clip.endsAt)
        or (side.trail and side.trail.remainingDamage > 0) then
        -- Let every committed contact and planted burst finish before a voluntary swap.
        return nil, nil, "tagBusy"
    end
    return incomingIndex, incoming
end

local function clearAttack(side)
    side.clip, side.trail, side.lastLight, side.bufferedLight = nil, nil, nil, false
    side.reaction = nil
    side.guardUntil, side.counterUntil = 0, nil
    side.talonHold = nil
end

function Tag.swap(round, index, now, expectedSlot)
    local incomingIndex, incoming = Tag.planTag(round, index, now)
    if not incomingIndex or incomingIndex ~= expectedSlot then
        return nil
    end
    local line = round.lineup[index]
    clearAttack(round.sides[index])
    line.active, line.nextTagAt, line.entryAt = incomingIndex, now + Tag.TAG_COOLDOWN, nil
    round.sides[index] = incoming
    refreshMatchups(round)
    -- Keep the incoming fighter's guard, dodge, and ability cooldowns. The
    -- entry assist uses their own fitted light attack and can be defended.
    Combatant.play(incoming, "jab", now)
    incoming.clip.tagEntry = true
    return incoming, "tagIn"
end

local function finish(round, now, winningTeam, reason)
    local outcomes = {}
    for index, side in round.sides do
        local line = round.lineup[index]
        local result = if reason == "cancelled" then "cancelled" elseif line.forfeited then "loss"
            elseif not winningTeam then "draw" elseif line.team == winningTeam then "win" else "loss"
        side.result, outcomes[index] = result, result
    end
    round.result = {winningTeam = winningTeam, reason = reason, outcomes = outcomes}
    round.resolvedAt, round.outroAt = now, now + Tag.OUTRO
end

function Tag.eliminateMany(round, exits, now)
    if round.result then
        return false
    end
    local changed, forfeited, seen = false, false, {}
    for _, exit in exits do
        local line, side = round.lineup[exit.index], round.sides[exit.index]
        if not line or line.out or seen[exit.index] then
            continue
        end
        seen[exit.index] = true
        local knockout = exit.reason == "knockout"
        if knockout and side.eliminated then
            continue
        end
        if not side.eliminated then
            side.eliminatedAt, side.eliminationReason = now, exit.reason
        end
        side.eliminated, side.playerHealth = true, 0
        clearAttack(side)
        local reserve = line.slots[3 - line.active]
        if knockout and reserve.playerHealth > 0 then
            line.entryAt = now + Tag.ENTRY_DELAY
        else
            line.out, line.entryAt = true, nil
            line.forfeited = not knockout
            if line.forfeited then
                reserve.playerHealth = 0
                forfeited = true
            end
            round.remaining -= 1
        end
        changed = true
    end
    if not changed then
        return false
    end
    if forfeited and now < round.startsAt then
        finish(round, now, nil, "cancelled")
        return true
    end
    local alive = {false, false}
    for _, line in round.lineup do
        alive[line.team] = alive[line.team] or not line.out
    end
    if not alive[1] or not alive[2] then
        local winner = if alive[1] then 1 elseif alive[2] then 2 else nil
        finish(round, now, winner, if forfeited then "forfeit" elseif winner then "knockout" else "simultaneous")
    end
    return true
end

local function timeout(round)
    local totals = {0, 0}
    for _, line in round.lineup do
        for _, side in line.slots do
            totals[line.team] += side.playerHealth / side.playerMaxHealth
        end
    end
    local difference = totals[1] - totals[2]
    local winner = if difference > 1e-9 then 1 elseif difference < -1e-9 then 2 else nil
    finish(round, round.endsAt, winner, "timeout")
end

function Tag.step(round, now, check, beforeExit)
    Group.step(round, now, check, Tag.eliminateMany, timeout, beforeExit)
end

Tag.act, Tag.threat = Group.act, Group.threat

return table.freeze(Tag)
