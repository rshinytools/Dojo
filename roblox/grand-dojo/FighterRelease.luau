local FighterRelease = {}

local launchCount, fightersPerMonth = 8, 2
local maxTimestamp = 253402300799

function FighterRelease.releasedCount(launch, now, total)
    if type(launch) ~= "number" or launch % 1 ~= 0 or launch < 1 or launch > maxTimestamp or now < launch then
        return math.min(launchCount, total)
    end
    local first, today = os.date("!*t", launch), os.date("!*t", now)
    local months = (today.year - first.year) * 12 + today.month - first.month
    local nextMonth = if today.month == 12 then 1 else today.month + 1
    local nextYear = if today.month == 12 then today.year + 1 else today.year
    local monthStart = os.time({year = today.year, month = today.month, day = 1, hour = 0})
    local monthEnd = os.time({year = nextYear, month = nextMonth, day = 1, hour = 0})
    local anniversary = math.min(first.day, (monthEnd - monthStart) / 86400)
    local check = os.time({year = today.year, month = today.month, day = anniversary,
        hour = first.hour, min = first.min, sec = first.sec})
    if now < check then months -= 1 end
    return math.min(launchCount + math.max(0, months) * fightersPerMonth, total)
end

function FighterRelease.roster(order, count, fighters, active)
    local available = {}
    for index, fighterId in order do
        if index <= count or fighters[fighterId] or fighterId == active then
            table.insert(available, fighterId)
        end
    end
    return table.concat(available, ",")
end

function FighterRelease.contains(lineup, fighterId)
    return type(lineup) == "string"
        and string.find("," .. lineup .. ",", "," .. fighterId .. ",", 1, true) ~= nil
end

return FighterRelease
