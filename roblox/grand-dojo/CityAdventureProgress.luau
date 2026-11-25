local Catalog = require(script.Parent.CityAdventureCatalog)
local Progress = {}
local EMPTY = table.freeze({districts = table.freeze({}), activities = table.freeze({})})
local FESTIVAL_SOURCES = {relay = true, cloudbreak = true}
-- Expert has an inactivity limit. Any verified finish can be stored as exact tenths.
local MAX_CLOUDBREAK_TENTHS = 2 ^ 53 - 1

local function integer(value, minimum, maximum)
    return type(value) == "number" and value % 1 == 0 and value >= minimum and value <= maximum
end

function Progress.cloudbreakTenths(seconds)
    if type(seconds) ~= "number" then return nil end
    local tenths = math.round(seconds * 10)
    return if integer(tenths, 1, MAX_CLOUDBREAK_TENTHS) then tenths else nil
end

local function allThree(flags)
    return flags and flags["1"] and flags["2"] and flags["3"]
end

local function canStamp(id)
    return type(id) == "string" and (Catalog.activities[id] ~= nil or FESTIVAL_SOURCES[id] == true)
end

local function validFlags(flags)
    if flags == nil then return true end
    if type(flags) ~= "table" then return false end
    for key, value in flags do
        if (key ~= "1" and key ~= "2" and key ~= "3") or value ~= true then return false end
    end
    return true
end

function Progress.valid(world)
    if world == nil then return true end
    if type(world) ~= "table" or type(world.districts) ~= "table" or type(world.activities) ~= "table" then return false end
    for id, district in world.districts do
        if not Catalog.byId[id] or type(district) ~= "table" or not integer(district.step, 0, 3)
            or not validFlags(district.surveys) or not validFlags(district.seals) then return false end
        for _, name in {"met", "visited", "trial", "cache", "mastered"} do
            if district[name] ~= nil and district[name] ~= true then return false end
        end
    end
    for id, best in world.activities do
        if not Catalog.activities[id] or not integer(best, 1, 1200) then return false end
    end
    if world.tracked ~= nil and not Catalog.byId[world.tracked] then return false end
    for _, key in {"graduated", "grandCache"} do
        if world[key] ~= nil and world[key] ~= true then return false end
    end
    local f = world.festival
    if f ~= nil then
        if type(f) ~= "table" or not integer(f.window, 0, 1e10) or type(f.stamps) ~= "table"
            or f.earned ~= nil and f.earned ~= true then return false end
        local count = 0
        for id, flag in f.stamps do
            count += 1
            if not canStamp(id) or flag ~= true or count > Catalog.festivalTarget then return false end
        end
    end
    local c = world.cloudbreak
    return c == nil or (type(c) == "table" and integer(c.best, 1, MAX_CLOUDBREAK_TENTHS)
        and (c.cleanBest == nil or integer(c.cleanBest, c.best, MAX_CLOUDBREAK_TENTHS))
        and (c.equipped == nil or type(c.equipped) == "boolean"))
end

function Progress.world(profile)
    return profile and profile.cityAdventure or EMPTY
end

function Progress.count(map)
    local total = 0
    for _ in map or {} do total += 1 end
    return total
end

function Progress.totals(world)
    local sums = {chapters = 0, seals = 0, caches = 0, visited = 0}
    for _, district in world.districts do
        if district.step == 3 then sums.chapters += 1 end
        if district.visited then sums.visited += 1 end
        if district.cache then sums.caches += 1 end
        sums.seals += Progress.count(district.seals)
    end
    return sums
end

function Progress.festivalAt(now)
    local window = math.floor(now / Catalog.festivalPeriod)
    local startsAt = window * Catalog.festivalPeriod
    return window, startsAt + Catalog.festivalDuration, startsAt + Catalog.festivalPeriod
end

local function addStamp(world, source, now, awards)
    if not canStamp(source) then return 0 end
    local window, endsAt = Progress.festivalAt(now)
    if now >= endsAt then return 0 end
    local old = world.festival
    if old and old.window > window then return 0 end
    if old and old.window == window and (old.earned or old.stamps[source]) then return 0 end
    local stamps = if old and old.window == window then table.clone(old.stamps) else {}
    stamps[source] = true
    local earned = Progress.count(stamps) >= Catalog.festivalTarget
    world.festival = {window = window, stamps = stamps, earned = if earned then true else nil}
    if earned then
        table.insert(awards, "world-05")
        return 65
    end
    return 0
end

local function requiredActivities(world, chapter)
    return world.activities[chapter.activities[1][1]] ~= nil and world.activities[chapter.activities[2][1]] ~= nil
end

function Progress.apply(source, action)
    local old = source or EMPTY
    if type(action) ~= "table" or not integer(action.at, 0, 1e12) then return old, 0, {} end
    local world = table.clone(old)
    local kind, id = action.kind, action.district
    local chapter = Catalog.byId[id]
    local awards, xp = {}, 0
    if kind == "festival" then
        xp += addStamp(world, action.activity, action.at, awards)
    elseif kind == "cloudbreak" and integer(action.tenths, 1, MAX_CLOUDBREAK_TENTHS) and type(action.clean) == "boolean" then
        local previous = old.cloudbreak
        local cleanBest = previous and previous.cleanBest
        if action.clean then cleanBest = math.min(cleanBest or action.tenths, action.tenths) end
        world.cloudbreak = {best = math.min(previous and previous.best or action.tenths, action.tenths), cleanBest = cleanBest,
            equipped = if previous then previous.equipped ~= false else true}
        if not previous then table.insert(awards, "mastery-sky"); xp += 85 end
        xp += addStamp(world, "cloudbreak", action.at, awards)
    elseif kind == "sash" and old.cloudbreak and type(action.equipped) == "boolean" then
        world.cloudbreak = table.clone(old.cloudbreak)
        world.cloudbreak.equipped = action.equipped
    elseif kind == "graduate" and not old.graduated and Progress.totals(old).chapters == #Catalog.chapters then
        world.graduated = true
        table.insert(awards, "journey-06")
        xp += 85
    elseif kind == "grand-cache" and not old.grandCache and Progress.totals(old).caches == #Catalog.chapters then
        world.grandCache = true
        xp += 100
    elseif chapter and kind == "track" then
        world.tracked = id
    elseif chapter then
        local district = table.clone(old.districts[id] or {step = 0})
        if kind == "visit" then
            district.visited = true
        elseif kind == "mentor" then
            district.met, district.visited = true, true
            if district.step == 2 and district.trial then
                district.step = 3
                xp += 50
                if id == "valley" then table.insert(awards, "journey-02") end
            end
        elseif kind == "survey" and district.met and integer(action.index, 1, 3) then
            local flags = table.clone(district.surveys or {})
            flags[tostring(action.index)] = true
            district.surveys = flags
        elseif kind == "seal" and integer(action.index, 1, 3) then
            local flags = table.clone(district.seals or {})
            local key = tostring(action.index)
            if not flags[key] then
                flags[key] = true
                xp += 8
                if allThree(flags) then table.insert(awards, "discovery-" .. id) end
            end
            district.seals = flags
        elseif kind == "cache" and not district.cache and allThree(district.seals) then
            district.cache = true
            xp += 40
        elseif kind == "activity" then
            local activity = Catalog.activities[action.activity]
            if not activity or activity.district ~= id or not integer(action.tenths, 1, 1200) then return old, 0, {} end
            local best = old.activities[activity.id]
            world.activities = table.clone(old.activities)
            world.activities[activity.id] = math.min(best or action.tenths, action.tenths)
            if not best then xp += 30 end
            if action.expert and district.step >= 2 and id ~= "sky"
                and not district.mastered and activity.slot == chapter.mastery then
                district.mastered = true
                table.insert(awards, "mastery-" .. id)
                xp += 45
            end
            xp += addStamp(world, activity.id, action.at, awards)
        elseif kind == "trial" and district.step == 2 then
            district.trial = true
        end
        if district.step == 0 and district.met and allThree(district.surveys) then
            district.step = 1
            if id == "valley" then table.insert(awards, "journey-01") end
        end
        if district.step == 1 and requiredActivities(world, chapter) then district.step = 2 end
        world.districts = table.clone(old.districts)
        world.districts[id] = district
        local totals = Progress.totals(world)
        if totals.visited == #Catalog.chapters then table.insert(awards, "journey-03") end
        if totals.chapters == #Catalog.chapters then table.insert(awards, "journey-05") end
    end
    return world, xp, awards
end

return table.freeze(Progress)
