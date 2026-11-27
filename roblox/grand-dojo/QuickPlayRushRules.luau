-- The server advances each fork using its own clock and accepts one choice per fork.
local Rush = {
    id = "lantern-rush",
    title = "Lantern Rush",
    duration = 25,
    laneDuration = 2.8,
    shortcutDuration = 2.2,
    shortcutWindow = 1.4,
    description = "Choose a lit lane at each fork. The teal shortcut closes early but saves time.",
    target = "Gold · 7 gates and 2 shortcuts",
    keepsake = "Lantern Pennant",
}

local forks = {
    {2, 1}, {3, 2}, {1, 3}, {3, 2},
    {2, 3}, {1, 2}, {2, 1}, {3, 1},
}
Rush.forkCount = #forks

local function finish(round, at)
    round.result = {
        score = round.score,
        bonus = round.bonus,
        elapsed = at - round.startsAt,
        clean = round.score == #forks,
        rank = if round.score >= 7 and round.bonus >= 2 then "gold"
            elseif round.score >= 4 then "silver" else "retry",
    }
end

function Rush.new(startsAt)
    return {
        startsAt = startsAt,
        endsAt = startsAt + Rush.duration,
        openedAt = startsAt,
        advancesAt = startsAt + Rush.laneDuration,
        fork = 1,
        score = 0,
        bonus = 0,
    }
end

function Rush.step(round, now)
    local changed = false
    while not round.result and now >= round.advancesAt do
        local at = round.advancesAt
        if round.fork == #forks or at >= round.endsAt then
            finish(round, math.min(at, round.endsAt))
            return true
        end
        round.feedback = if round.chosenLane then round.feedback else "Fork missed. Choose the next lane."
        round.fork += 1
        round.chosenLane = nil
        round.openedAt = at
        round.advancesAt = math.min(at + Rush.laneDuration, round.endsAt)
        changed = true
    end
    return changed
end

function Rush.act(round, lane, fork, now)
    if round.result or now < round.openedAt or now >= round.advancesAt
        or fork ~= round.fork or round.chosenLane then
        return false
    end
    if lane ~= 1 and lane ~= 2 and lane ~= 3 then
        return false
    end

    round.chosenLane = lane
    local safe, shortcut = table.unpack(forks[round.fork])
    if lane == safe then
        round.score += 1
        round.feedback = "Gate lit!"
    elseif lane == shortcut and now < round.openedAt + Rush.shortcutWindow then
        round.score += 1
        round.bonus += 1
        round.advancesAt = round.openedAt + Rush.shortcutDuration
        round.feedback = "Shortcut! 0.6s saved."
    else
        round.feedback = if lane == shortcut then "Shortcut closed. Take the next fork."
            else "Barred lane. Take the next fork."
    end
    return true
end

function Rush.snapshot(round)
    return {
        startsAt = round.startsAt,
        endsAt = round.endsAt,
        openedAt = round.openedAt,
        closesAt = round.openedAt + Rush.shortcutWindow,
        advancesAt = round.advancesAt,
        fork = round.fork,
        safeLane = forks[round.fork][1],
        shortcutLane = forks[round.fork][2],
        chosenLane = round.chosenLane,
        feedback = round.feedback,
        score = round.score,
        bonus = round.bonus,
    }
end

return table.freeze(Rush)
