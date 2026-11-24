local PlayerProfiles = {}
PlayerProfiles.__index = PlayerProfiles

local SCHEMA_VERSION = 1
local LEASE_SECONDS = 120
local FIRST_RELAY_XP = 80
local REPEAT_RELAY_XP = 25
local FIRST_DOJO_PRACTICE_XP = 20
local FIRST_SPAR_WIN_XP = 60
local REPEAT_SPAR_WIN_XP = 30
local REEDGUARD = "reedguard-kangaroo"
local STARTERS = {
    [REEDGUARD] = true,
    ["penguin-brawler"] = true,
    ["silverback-gorilla"] = true,
    ["fire-salamander"] = true,
}
local LANTERN_KEEPER = "world-04"
local LEVEL_THRESHOLDS = {0, 80, 180, 300, 460, 650, 830, 1030, 1260, 1500}
PlayerProfiles.FirstRelayXp = FIRST_RELAY_XP
PlayerProfiles.FirstDojoPracticeXp = FIRST_DOJO_PRACTICE_XP
PlayerProfiles.FirstSparWinXp = FIRST_SPAR_WIN_XP

local function whole(value, minimum, maximum)
    return type(value) == "number" and value >= minimum and value <= maximum and value % 1 == 0
end

local function validCompletionId(id)
    return type(id) == "string" and #id > 0 and #id <= 80
end

local function isStarter(id)
    return type(id) == "string" and STARTERS[id] == true
end

local function addFighterXp(profile, id, amount)
    profile.fighters = table.clone(profile.fighters)
    local fighter = table.clone(profile.fighters[id] or {xp = 0})
    fighter.xp = math.min(1e12, fighter.xp + amount)
    profile.fighters[id] = fighter
end

local function validRewardReceipt(receipt, firstXp, repeatXp)
    return receipt == nil or (type(receipt) == "table" and validCompletionId(receipt.id)
        and isStarter(receipt.fighterId) and (receipt.xp == firstXp or receipt.xp == repeatXp))
end

local function newProfile()
    return {
        schemaVersion = SCHEMA_VERSION,
        fighters = {[REEDGUARD] = {xp = 0}},
        trophies = {},
        relayBestTenths = 0,
    }
end

local function valid(profile)
    if type(profile) ~= "table" or profile.schemaVersion ~= SCHEMA_VERSION
        or type(profile.fighters) ~= "table" or type(profile.trophies) ~= "table"
        or not whole(profile.relayBestTenths, 0, 1200) then
        return false
    end
    for id in STARTERS do
        local fighter = profile.fighters[id]
        if (fighter ~= nil or id == REEDGUARD)
            and (type(fighter) ~= "table" or not whole(fighter.xp, 0, 1e12)) then
            return false
        end
    end
    local training = profile.ringTraining
    if training ~= nil then
        if type(training) ~= "table" then
            return false
        end
        for fighterId, records in training do
            if not isStarter(fighterId) or type(records) ~= "table" then
                return false
            end
            for drillId, receipt in records do
                if not validCompletionId(drillId) or not validCompletionId(receipt) then
                    return false
                end
            end
        end
    end
    local trophy = profile.trophies[LANTERN_KEEPER]
    local lease = profile.lease
    return (profile.dojoPracticeId == nil or validCompletionId(profile.dojoPracticeId))
        and (profile.firstSparWinId == nil or validCompletionId(profile.firstSparWinId))
        and validRewardReceipt(profile.lastRelayReward, FIRST_RELAY_XP, REPEAT_RELAY_XP)
        and validRewardReceipt(profile.lastSparReward, FIRST_SPAR_WIN_XP, REPEAT_SPAR_WIN_XP)
        and (profile.selectedStarterFighter == nil or isStarter(profile.selectedStarterFighter))
        and (profile.activeStarterFighter == nil
            or (isStarter(profile.activeStarterFighter) and profile.selectedStarterFighter ~= nil))
        and (trophy == nil or type(trophy) == "table" and whole(trophy.earnedAt, 1, 1e12)
            and whole(trophy.criterionVersion, 1, 1e6))
        and (lease == nil or type(lease) == "table" and type(lease.token) == "string"
            and whole(lease.expiresAt, 1, 1e12))
end

function PlayerProfiles.new(store, unixTime, wait)
    return setmetatable({store = store, now = unixTime, wait = wait}, PlayerProfiles)
end

-- Studio playtests are isolated from cloud keys. This also gives the profile
-- rules the same UpdateAsync interface in deterministic local tests.
function PlayerProfiles.memoryStore()
    local records = {}
    return {
        UpdateAsync = function(_, key, transform)
            local value = transform(records[key])
            if value ~= nil then
                records[key] = value
            end
            return value
        end,
    }
end

function PlayerProfiles.activeFighter(profile)
    return profile.activeStarterFighter or profile.selectedStarterFighter
end

function PlayerProfiles.levelForXp(xp)
    local level = 1
    for index, minimum in LEVEL_THRESHOLDS do
        if xp >= minimum then
            level = index
        end
    end
    return level
end

function PlayerProfiles.summary(profile, fighterId)
    fighterId = fighterId or REEDGUARD
    local fighter = profile.fighters[fighterId]
    local xp = if fighter then fighter.xp else 0
    local level = PlayerProfiles.levelForXp(xp)
    local highestXp = 0
    local fighterLevels = {}
    for id in STARTERS do
        local owned = profile.fighters[id]
        local ownedXp = if owned then owned.xp else 0
        highestXp = math.max(highestXp, ownedXp)
        fighterLevels[id] = PlayerProfiles.levelForXp(ownedXp)
    end
    return {
        lanternKeeper = profile.trophies[LANTERN_KEEPER] ~= nil,
        dojoPracticeComplete = profile.dojoPracticeId ~= nil,
        firstSparWinComplete = profile.firstSparWinId ~= nil,
        relayBest = profile.relayBestTenths / 10,
        xp = xp,
        level = level,
        levelFloor = LEVEL_THRESHOLDS[level],
        nextLevelXp = LEVEL_THRESHOLDS[level + 1],
        highestFighterLevel = PlayerProfiles.levelForXp(highestXp),
        fighterLevels = fighterLevels,
        ringTraining = (profile.ringTraining and profile.ringTraining[fighterId]) or {},
    }
end

function PlayerProfiles:_update(userId, mutate)
    local key = "player_" .. userId
    for attempt = 1, 3 do
        local rejection
        local ok, result = pcall(self.store.UpdateAsync, self.store, key, function(current, info)
            local updated, reason = mutate(current, self.now())
            rejection = reason
            if updated == nil then
                return nil
            end
            return updated, {userId}, if info then info:GetMetadata() else nil
        end)
        if ok then
            return result, rejection
        end
        if attempt < 3 then
            self.wait(.35 * 2 ^ (attempt - 1) + math.random() * .2)
        end
    end
    return nil, "unavailable"
end

function PlayerProfiles:open(userId, token)
    return self:_update(userId, function(current, now)
        local profile = if current == nil then newProfile() else current
        if not valid(profile) then
            return nil, "invalid"
        end
        local lease = profile.lease
        if lease and lease.expiresAt > now and lease.token ~= token then
            return nil, "busy"
        end
        local updated = table.clone(profile)
        updated.lease = {token = token, expiresAt = now + LEASE_SECONDS}
        return updated
    end)
end

function PlayerProfiles:_owned(userId, token, change, releasing)
    return self:_update(userId, function(current, now)
        if not valid(current) or not current.lease or current.lease.token ~= token
            or current.lease.expiresAt <= now then
            return nil, "ownership"
        end
        local updated = table.clone(current)
        if change then
            change(updated, now)
        end
        updated.lease = if releasing then nil else {token = token, expiresAt = now + LEASE_SECONDS}
        return updated
    end)
end

function PlayerProfiles:renew(userId, token)
    return self:_owned(userId, token)
end

function PlayerProfiles:release(userId, token)
    return self:_owned(userId, token, nil, true)
end

function PlayerProfiles:commitStarterChoice(userId, token, fighterId)
    if not isStarter(fighterId) then
        return nil, "invalid starter"
    end
    return self:_owned(userId, token, function(profile)
        -- Retrying a timed-out write returns the saved selection. The first
        -- confirmed choice also wins if a later request selects another fighter.
        if profile.selectedStarterFighter == nil then
            profile.selectedStarterFighter = fighterId
        end
    end)
end

function PlayerProfiles:commitFighterSwitch(userId, token, fighterId)
    if not isStarter(fighterId) then
        return nil, "invalid fighter"
    end
    return self:_owned(userId, token, function(profile)
        if profile.selectedStarterFighter ~= nil then
            profile.activeStarterFighter = fighterId
        end
    end)
end

function PlayerProfiles:commitRelay(userId, token, elapsedTenths, completionId, fighterId)
    fighterId = fighterId or REEDGUARD
    if not whole(elapsedTenths, 1, 1200) or not validCompletionId(completionId) or not isStarter(fighterId) then
        return nil, "invalid result"
    end
    local saved, reason = self:_owned(userId, token, function(profile, now)
        local trophy = profile.trophies[LANTERN_KEEPER]
        if (trophy and trophy.completionId == completionId)
            or (profile.lastRelayReward and profile.lastRelayReward.id == completionId) then
            return
        end
        if profile.relayBestTenths == 0 or elapsedTenths < profile.relayBestTenths then
            profile.relayBestTenths = elapsedTenths
        end
        -- The account-bound trophy also acts as the first-clear grant receipt.
        -- A repeated callback, ambiguous network reply or later clear can't add XP twice.
        local xp = if trophy then REPEAT_RELAY_XP else FIRST_RELAY_XP
        if not trophy then
            profile.trophies = table.clone(profile.trophies)
            profile.trophies[LANTERN_KEEPER] = {earnedAt = now, criterionVersion = 1, completionId = completionId}
        end
        profile.lastRelayReward = {id = completionId, fighterId = fighterId, xp = xp}
        addFighterXp(profile, fighterId, xp)
    end)
    local first = saved ~= nil and saved.trophies[LANTERN_KEEPER].completionId == completionId
    local receipt = saved and saved.lastRelayReward
    return saved, reason, first, if first then FIRST_RELAY_XP
        elseif receipt and receipt.id == completionId then receipt.xp else 0
end

function PlayerProfiles:commitDojoPractice(userId, token, completionId)
    if not validCompletionId(completionId) then
        return nil, "invalid result"
    end
    local saved, reason = self:_owned(userId, token, function(profile)
        -- Keep the originating receipt so a committed write with a lost reply
        -- can confirm this clear without increasing XP again.
        if profile.dojoPracticeId == nil then
            profile.dojoPracticeId = completionId
            addFighterXp(profile, REEDGUARD, FIRST_DOJO_PRACTICE_XP)
        end
    end)
    return saved, reason, saved ~= nil and saved.dojoPracticeId == completionId
end

function PlayerProfiles:commitFirstSparWin(userId, token, completionId, fighterId)
    fighterId = fighterId or REEDGUARD
    if not validCompletionId(completionId) or not isStarter(fighterId) then
        return nil, "invalid result"
    end
    local saved, reason = self:_owned(userId, token, function(profile)
        if profile.firstSparWinId == nil then
            profile.firstSparWinId = completionId
            addFighterXp(profile, fighterId, FIRST_SPAR_WIN_XP)
        end
    end)
    return saved, reason, saved ~= nil and saved.firstSparWinId == completionId
end

function PlayerProfiles:commitSparWin(userId, token, completionId, fighterId)
    if not isStarter(fighterId) or not validCompletionId(completionId) then
        return nil, "invalid result"
    end
    local saved, reason = self:_owned(userId, token, function(profile)
        if profile.firstSparWinId == completionId
            or (profile.lastSparReward and profile.lastSparReward.id == completionId) then
            return
        end
        local first = profile.firstSparWinId == nil
        local xp = if first then FIRST_SPAR_WIN_XP else REPEAT_SPAR_WIN_XP
        if first then
            profile.firstSparWinId = completionId
        end
        profile.lastSparReward = {id = completionId, fighterId = fighterId, xp = xp}
        addFighterXp(profile, fighterId, xp)
    end)
    local first = saved ~= nil and saved.firstSparWinId == completionId
    local receipt = saved and saved.lastSparReward
    return saved, reason, first, if first then FIRST_SPAR_WIN_XP
        elseif receipt and receipt.id == completionId then receipt.xp else 0
end

function PlayerProfiles:commitRingTraining(userId, token, drillId, completionId, fighterId, xp)
    if not isStarter(fighterId) or not validCompletionId(drillId) or not validCompletionId(completionId)
        or not whole(xp, 1, LEVEL_THRESHOLDS[#LEVEL_THRESHOLDS]) then
        return nil, "invalid training result"
    end
    local saved, reason = self:_owned(userId, token, function(profile)
        local training = profile.ringTraining or {}
        local recorded = training[fighterId] or {}
        if recorded[drillId] == completionId then
            return
        end
        profile.ringTraining = table.clone(training)
        local updated = table.clone(recorded)
        updated[drillId] = completionId
        profile.ringTraining[fighterId] = updated
        addFighterXp(profile, fighterId, xp)
    end)
    return saved, reason, saved ~= nil and saved.ringTraining[fighterId][drillId] == completionId
end

return PlayerProfiles
