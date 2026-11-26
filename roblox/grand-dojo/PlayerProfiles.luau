local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FighterForms = require(ReplicatedStorage:WaitForChild("FighterForms"))
local FighterTactics = require(ReplicatedStorage:WaitForChild("FighterTactics"))
local FighterLoadouts = require(ReplicatedStorage:WaitForChild("FighterLoadouts"))
local CityAdventureProgress = require(script.Parent:WaitForChild("CityAdventureProgress"))

local PlayerProfiles = {}
PlayerProfiles.__index = PlayerProfiles

local SCHEMA_VERSION = 1
local LEASE_SECONDS = 120
local MATCH_HANDOFF_SECONDS = 60
local MAX_HANDOFF_SEQUENCE = 2147483647
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
local ROSTER_UNLOCKS = {["karate-frog"] = 2, ["river-otter"] = 3}
local EXPANDED_UNLOCKS = {
    ["rooster-kickboxer"] = 4, ["sugar-glider"] = 5, ["desert-scorpion"] = 6, ["pistol-shrimp"] = 7,
    ["walrus-sumo"] = 8, ["snapping-tortoise"] = 9,
    ["armadillo-striker"] = 10, ["komodo-dragon"] = 10,
    ["electric-owl"] = 10, ["bighorn-ram"] = 10,
    ["honey-badger"] = 10, ["emerald-saber-tooth"] = 10,
    ["great-white-shark"] = 10, ["abyssal-kraken"] = 10,
    ["magma-grizzly-bear"] = 10, ["obsidian-hellhound"] = 10,
    ["golden-eagle"] = 10, ["celestial-storm-dragon"] = 10,
}
local STARTER_PROGRESS = {relay = "lastRelayReward", spar = "lastSparReward", training = "ringTraining"}
local ROSTER_PROGRESS = {relay = "lastRosterRelayReward", spar = "lastRosterSparReward", training = "rosterTraining"}
local EXPANDED_PROGRESS = {
    relay = "lastExpandedRelayReward", spar = "lastExpandedSparReward", training = "expandedRosterTraining",
}
local LANTERN_KEEPER = "world-04"
local KILN_KEEPER = "world-01"
local DEEPWATER_TEAM = "world-02"
local DAWN_RETURN = "world-03"
local NEW_FORM = "journey-04"
local RAID_TROPHIES = {kilnback = KILN_KEEPER, kraken = DEEPWATER_TEAM, phoenix = DAWN_RETURN}
local RAID_TOKENS, RAID_SHARDS = 20, 2
local MARKET_SASH_COST = 50
local LEGACY_LEVEL_THRESHOLDS = {0, 80, 180, 300, 460, 650, 830, 1030, 1260, 1500}
local LEVEL_THRESHOLDS = {0, 250, 550, 950, 1450, 2100, 2850, 3700, 4700, 5800}
local MAX_LEVEL_CURVE_CREDIT = LEVEL_THRESHOLDS[#LEVEL_THRESHOLDS] - LEGACY_LEVEL_THRESHOLDS[#LEGACY_LEVEL_THRESHOLDS]
PlayerProfiles.FirstRelayXp = FIRST_RELAY_XP
PlayerProfiles.FirstDojoPracticeXp = FIRST_DOJO_PRACTICE_XP
PlayerProfiles.FirstSparWinXp = FIRST_SPAR_WIN_XP
PlayerProfiles.MarketSashCost = MARKET_SASH_COST

local function whole(value, minimum, maximum)
    return type(value) == "number" and value >= minimum and value <= maximum and value % 1 == 0
end

local function validCompletionId(id)
    return type(id) == "string" and #id > 0 and #id <= 80
end

local function isStarter(id)
    return type(id) == "string" and STARTERS[id] == true
end

local function isOriginalUnlock(id)
    return ROSTER_UNLOCKS[id] ~= nil
end

local function isExpandedId(id)
    return type(id) == "string" and #id <= 80 and string.match(id, "^[a-z][a-z0-9%-]*$") ~= nil
        and not isStarter(id) and not isOriginalUnlock(id)
end

local function isFighter(id)
    return isStarter(id) or isOriginalUnlock(id) or EXPANDED_UNLOCKS[id] ~= nil
end

local cosmeticSlots = {hands = true, head = true, back = true, waist = true, trail = true}

local function cosmeticId(id)
    return type(id) == "string" and #id <= 80 and id:match("^[a-z][a-z0-9%-]*$") ~= nil
end

local function validFighterCosmetics(value)
    if value == nil then return true end
    if type(value) ~= "table" then return false end
    for fighter, slots in value do
        if not cosmeticId(fighter) or type(slots) ~= "table" then return false end
        for slot, itemId in slots do
            if not cosmeticSlots[slot] or not cosmeticId(itemId) then return false end
        end
    end
    return true
end

local function fieldsFor(id)
    return if isStarter(id) then STARTER_PROGRESS elseif isOriginalUnlock(id) then ROSTER_PROGRESS else EXPANDED_PROGRESS
end

local function progressionXp(fighter)
    return if fighter then fighter.xp + (fighter.levelCurveCredit or 0) else 0
end

local function withCurrentLevelCurve(profile)
    if type(profile) ~= "table" or profile.levelCurveUpdated ~= nil or type(profile.fighters) ~= "table" then
        return profile
    end
    local updated = table.clone(profile)
    updated.levelCurveUpdated = true
    updated.fighters = table.clone(profile.fighters)
    -- Keep every earned level and the XP already earned within that level.
    -- The original reward XP stays readable by older servers during a rollout.
    for id, fighter in profile.fighters do
        if isFighter(id) and type(fighter) == "table" and whole(fighter.xp, 0, 1e12) then
            for level = #LEGACY_LEVEL_THRESHOLDS, 2, -1 do
                local previous = LEGACY_LEVEL_THRESHOLDS[level]
                if fighter.xp >= previous then
                    local migrated = table.clone(fighter)
                    migrated.levelCurveCredit = LEVEL_THRESHOLDS[level] - previous
                    updated.fighters[id] = migrated
                    break
                end
            end
        end
    end
    return updated
end

local function highestXp(profile)
    local highest = 0
    for id, fighter in profile.fighters do
        if isFighter(id) then
            highest = math.max(highest, progressionXp(fighter))
        end
    end
    return highest
end

function PlayerProfiles.unlockLevel(fighterId)
    return if isStarter(fighterId) then 1 else ROSTER_UNLOCKS[fighterId] or EXPANDED_UNLOCKS[fighterId]
end

function PlayerProfiles.canSwitch(profile, fighterId)
    local minimum = PlayerProfiles.unlockLevel(fighterId)
    return profile.selectedStarterFighter ~= nil and minimum ~= nil
        and (minimum == 1 or PlayerProfiles.levelForXp(highestXp(profile)) >= minimum)
end

local function addFighterXp(profile, id, amount)
    profile.fighters = table.clone(profile.fighters)
    local fighter = table.clone(profile.fighters[id] or {xp = 0})
    fighter.xp = math.min(1e12, fighter.xp + amount)
    profile.fighters[id] = fighter
end

local function validRewardReceipt(receipt, firstXp, repeatXp, acceptsFighter)
    return receipt == nil or (type(receipt) == "table" and validCompletionId(receipt.id)
        and acceptsFighter(receipt.fighterId)
        and (receipt.xp == firstXp or receipt.xp == repeatXp))
end

local function validRaidReceipt(receipt)
    return type(receipt) == "table" and whole(receipt.window, 0, 1e10)
        and whole(receipt.tokens, 0, 1e12) and whole(receipt.shards, 0, 1e12)
        and validCompletionId(receipt.id)
        and (receipt.raidId == nil or RAID_TROPHIES[receipt.raidId] ~= nil)
        and (receipt.encounterId == nil or RAID_TROPHIES[receipt.encounterId] ~= nil
            and (receipt.raidId == nil or receipt.raidId == receipt.encounterId))
        and (receipt.grantedTokens == nil or whole(receipt.grantedTokens, 0, RAID_TOKENS))
        and (receipt.grantedShards == nil or whole(receipt.grantedShards, 0, RAID_SHARDS))
end

local function validRaidTrophy(trophy)
    return type(trophy) == "table" and whole(trophy.earnedAt, 1, 1e12)
        and whole(trophy.criterionVersion, 1, 1e6) and validCompletionId(trophy.completionId)
end

local function newProfile()
    return {
        schemaVersion = SCHEMA_VERSION,
        levelCurveUpdated = true,
        fighters = {[REEDGUARD] = {xp = 0}},
        trophies = {},
        relayBestTenths = 0,
    }
end

local function validTraining(training, acceptsFighter)
    if training == nil then
        return true
    end
    if type(training) ~= "table" then
        return false
    end
    for fighterId, records in training do
        if not acceptsFighter(fighterId) or type(records) ~= "table" then
            return false
        end
        for drillId, receipt in records do
            if not validCompletionId(drillId) or not validCompletionId(receipt) then
                return false
            end
        end
    end
    return true
end

local function validHandoffId(value)
    return type(value) == "string" and #value <= 80 and value:match("^[%w_%-]+$") ~= nil
end

local function validLease(lease)
    if lease == nil then return true end
    if type(lease) ~= "table" or type(lease.token) ~= "string" or not whole(lease.expiresAt, 1, 1e12) then
        return false
    end
    local handoff = lease.handoff
    if handoff == nil then return true end
    if type(handoff) ~= "table" or not validHandoffId(handoff.id) or not validHandoffId(handoff.destination)
        or not whole(handoff.sequence, 1, MAX_HANDOFF_SEQUENCE) or not whole(handoff.deadline, 1, 1e12) then
        return false
    end
    return handoff.state == "accepted" or handoff.state == "cancelled"
        or handoff.state == "pending" and handoff.deadline == lease.expiresAt
end

local function valid(profile)
    if type(profile) ~= "table" or profile.schemaVersion ~= SCHEMA_VERSION
        or (profile.levelCurveUpdated ~= nil and profile.levelCurveUpdated ~= true)
        or type(profile.fighters) ~= "table" or type(profile.trophies) ~= "table"
        or not whole(profile.relayBestTenths, 0, 1200) then
        return false
    end
    for id, fighter in profile.fighters do
        if isFighter(id) and (type(fighter) ~= "table" or not whole(fighter.xp, 0, 1e12)
            or (fighter.levelCurveCredit ~= nil and not whole(fighter.levelCurveCredit, 0, MAX_LEVEL_CURVE_CREDIT))) then
            return false
        end
    end
    if profile.fighters[REEDGUARD] == nil or not validTraining(profile.ringTraining, isStarter)
        or not validTraining(profile.rosterTraining, isOriginalUnlock)
        or not validTraining(profile.expandedRosterTraining, isExpandedId) then
        return false
    end
    local trophy = profile.trophies[LANTERN_KEEPER]
    local wallet = profile.dojoWallet
    for _, id in RAID_TROPHIES do
        local award = profile.trophies[id]
        if award ~= nil and not validRaidTrophy(award) then
            return false
        end
    end
    return (profile.dojoPracticeId == nil or validCompletionId(profile.dojoPracticeId))
        and (profile.firstSparWinId == nil or validCompletionId(profile.firstSparWinId))
        and validRewardReceipt(profile.lastRelayReward, FIRST_RELAY_XP, REPEAT_RELAY_XP, isStarter)
        and validRewardReceipt(profile.lastSparReward, FIRST_SPAR_WIN_XP, REPEAT_SPAR_WIN_XP, isStarter)
        and validRewardReceipt(profile.lastRosterRelayReward, FIRST_RELAY_XP, REPEAT_RELAY_XP, isOriginalUnlock)
        and validRewardReceipt(profile.lastRosterSparReward, FIRST_SPAR_WIN_XP, REPEAT_SPAR_WIN_XP, isOriginalUnlock)
        and validRewardReceipt(profile.lastExpandedRelayReward, FIRST_RELAY_XP, REPEAT_RELAY_XP, isExpandedId)
        and validRewardReceipt(profile.lastExpandedSparReward, FIRST_SPAR_WIN_XP, REPEAT_SPAR_WIN_XP, isExpandedId)
        and (profile.selectedStarterFighter == nil or isStarter(profile.selectedStarterFighter))
        and (profile.activeStarterFighter == nil
            or (isStarter(profile.activeStarterFighter) and profile.selectedStarterFighter ~= nil))
        and (profile.activeRosterFighter == nil or ROSTER_UNLOCKS[profile.activeRosterFighter] ~= nil
            and PlayerProfiles.canSwitch(profile, profile.activeRosterFighter))
        and (profile.activeExpandedFighter == nil or (isExpandedId(profile.activeExpandedFighter)
            and (isStarter(profile.expandedFallback) or isOriginalUnlock(profile.expandedFallback))
            and (EXPANDED_UNLOCKS[profile.activeExpandedFighter] == nil
                or PlayerProfiles.canSwitch(profile, profile.activeExpandedFighter))))
        and (trophy == nil or type(trophy) == "table" and whole(trophy.earnedAt, 1, 1e12)
            and whole(trophy.criterionVersion, 1, 1e6))
        and (profile.kilnback == nil or validRaidReceipt(profile.kilnback))
        and CityAdventureProgress.valid(profile.cityAdventure)
        and (wallet == nil or type(wallet) == "table" and whole(wallet.spent, 1, 1e12)
            and type(wallet.marketSashEquipped) == "boolean")
        and (profile.midnightLanternEquipped == nil or type(profile.midnightLanternEquipped) == "boolean")
        and validFighterCosmetics(profile.fighterCosmetics)
        and (profile.cityAdventureReceipt == nil or type(profile.cityAdventureReceipt) == "table"
            and validCompletionId(profile.cityAdventureReceipt.id) and whole(profile.cityAdventureReceipt.xp, 0, 200)
            and (profile.cityAdventureReceipt.rareCache == nil
                or profile.cityAdventureReceipt.rareCache == true and profile.cityAdventureReceipt.xp == 0))
        and validLease(profile.lease)
        and (profile.duelReturn == nil or type(profile.duelReturn) == "table"
            and validHandoffId(profile.duelReturn.id) and validHandoffId(profile.duelReturn.token))
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

local function fallbackFighter(profile)
    return profile.activeRosterFighter or profile.activeStarterFighter or profile.selectedStarterFighter
end

function PlayerProfiles.activeFighter(profile)
    local fallback = fallbackFighter(profile)
    if profile.expandedFallback == fallback and EXPANDED_UNLOCKS[profile.activeExpandedFighter] then
        return profile.activeExpandedFighter
    end
    return fallback
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

function PlayerProfiles.canEquipForm(profile, fighterId, formId)
    if not isFighter(fighterId) or type(formId) ~= "string" then
        return false
    end
    local form = FighterForms.get(fighterId, formId)
    if not form then
        return false
    end
    local fighter = profile.fighters[fighterId]
    local level = PlayerProfiles.levelForXp(progressionXp(fighter))
    return level >= form.level
end

function PlayerProfiles.formFor(profile, fighterId)
    local fighter = profile.fighters[fighterId]
    local equipped = fighter and fighter.equippedForm
    -- A rollback can see a form from a newer catalog. Keep the saved choice so
    -- it can be restored when that catalog returns.
    return if PlayerProfiles.canEquipForm(profile, fighterId, equipped) then equipped else FighterForms.BaseId
end

function PlayerProfiles.tacticalUnlockLevel(fighterId, tactical)
    local option = FighterTactics.get(fighterId, tactical)
    return option and option.level
end

function PlayerProfiles.canEquipTactical(profile, fighterId, tactical)
    local required = PlayerProfiles.tacticalUnlockLevel(fighterId, tactical)
    if not required then return false end
    local fighter = profile.fighters[fighterId]
    return PlayerProfiles.levelForXp(progressionXp(fighter)) >= required
end

function PlayerProfiles.tacticalFor(profile, fighterId)
    local registered = FighterTactics.ByFighter[fighterId]
    if not registered then return nil end
    local fighter = profile.fighters[fighterId]
    local equipped = fighter and fighter.equippedTactical
    -- A newer or currently locked option stays in the saved record while the default is projected.
    return if PlayerProfiles.canEquipTactical(profile, fighterId, equipped) then equipped else registered.default
end

function PlayerProfiles.canEquipLoadout(profile, fighterId, slot, id)
    local option = FighterLoadouts.get(fighterId, slot, id)
    if not option then return false end
    local fighter = profile.fighters[fighterId]
    return PlayerProfiles.levelForXp(progressionXp(fighter)) >= option.level
end

local function loadoutFor(profile, fighterId, slot, field)
    local loadout = FighterLoadouts.ByFighter[fighterId]
    local definition = loadout and loadout[slot]
    if not definition then return nil end
    local fighter = profile.fighters[fighterId]
    local equipped = fighter and fighter[field]
    -- Project the default for unknown or locked choices without dropping the stored choice.
    return if PlayerProfiles.canEquipLoadout(profile, fighterId, slot, equipped) then equipped else definition.default
end

function PlayerProfiles.basicFor(profile, fighterId)
    return loadoutFor(profile, fighterId, "basic", "equippedBasic")
end

function PlayerProfiles.ultimateFor(profile, fighterId)
    return loadoutFor(profile, fighterId, "ultimate", "equippedUltimate")
end

function PlayerProfiles.wallet(profile)
    local world = CityAdventureProgress.world(profile)
    -- Permanent completion facts also credit players who cleared these activities before the market opened.
    local coins = (if profile.trophies[LANTERN_KEEPER] then 60 else 0)
        + (if profile.firstSparWinId then 30 else 0)
        + (if world.cloudbreak then 60 else 0)
        + CityAdventureProgress.count(world.activities) * 20
    for _, district in world.districts do
        if district.cache then coins += 45 end
    end
    local purchase = profile.dojoWallet
    return {
        coins = math.max(0, coins - (if purchase then purchase.spent else 0)),
        marketSashOwned = purchase ~= nil,
        marketSashEquipped = purchase ~= nil and purchase.marketSashEquipped,
    }
end

function PlayerProfiles.summary(profile, fighterId)
    fighterId = fighterId or REEDGUARD
    local fighter = profile.fighters[fighterId]
    local xp = progressionXp(fighter)
    local level = PlayerProfiles.levelForXp(xp)
    local fighterLevels, fighterForms = {}, {}
    for _, roster in {STARTERS, ROSTER_UNLOCKS, EXPANDED_UNLOCKS} do
        for id in roster do
            local owned = profile.fighters[id]
            fighterLevels[id] = PlayerProfiles.levelForXp(progressionXp(owned))
            if #FighterForms.list(id) > 1 then
                fighterForms[id] = PlayerProfiles.formFor(profile, id)
            end
        end
    end
    local raid = profile.kilnback
    local training = profile[fieldsFor(fighterId).training]
    return {
        lanternKeeper = profile.trophies[LANTERN_KEEPER] ~= nil,
        kilnKeeper = profile.trophies[KILN_KEEPER] ~= nil,
        deepwaterTeam = profile.trophies[DEEPWATER_TEAM] ~= nil,
        dawnReturn = profile.trophies[DAWN_RETURN] ~= nil,
        newForm = profile.trophies[NEW_FORM] ~= nil,
        raidTokens = raid and raid.tokens or 0,
        mythicShards = raid and raid.shards or 0,
        dojoPracticeComplete = profile.dojoPracticeId ~= nil,
        firstSparWinComplete = profile.firstSparWinId ~= nil,
        relayBest = profile.relayBestTenths / 10,
        xp = xp,
        level = level,
        levelFloor = LEVEL_THRESHOLDS[level],
        nextLevelXp = LEVEL_THRESHOLDS[level + 1],
        highestFighterLevel = PlayerProfiles.levelForXp(highestXp(profile)),
        fighterLevels = fighterLevels,
        fighterForms = fighterForms,
        ringTraining = (training and training[fighterId]) or {},
    }
end

function PlayerProfiles:_update(userId, mutate)
    local key = "player_" .. userId
    for attempt = 1, 3 do
        local rejection
        local ok, result = pcall(self.store.UpdateAsync, self.store, key, function(current, info)
            local updated, reason = mutate(withCurrentLevelCurve(current), self.now())
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

local function pendingHandoff(lease)
    return lease.handoff and lease.handoff.state == "pending"
end

local function refreshLease(token, now, handoff)
    return {token = token, expiresAt = now + LEASE_SECONDS, handoff = handoff}
end

function PlayerProfiles:open(userId, token)
    return self:_update(userId, function(current, now)
        local profile = if current == nil then newProfile() else current
        if not valid(profile) then
            return nil, "invalid"
        end
        local lease = profile.lease
        local live = lease and lease.expiresAt > now
        if live and (lease.token ~= token or pendingHandoff(lease)) then
            return nil, "busy"
        end
        local updated = table.clone(profile)
        updated.lease = refreshLease(token, now, if live then lease.handoff else nil)
        return updated
    end)
end

function PlayerProfiles:_owned(userId, token, change, releasing)
    return self:_update(userId, function(current, now)
        if not valid(current) or not current.lease or current.lease.token ~= token
            or current.lease.expiresAt <= now then
            return nil, "ownership"
        end
        if pendingHandoff(current.lease) then
            return nil, "transferring"
        end
        local updated = table.clone(current)
        if change then
            local rejection = change(updated, now)
            if rejection then
                return nil, rejection
            end
        end
        updated.lease = if releasing then nil else refreshLease(token, now, current.lease.handoff)
        return updated
    end)
end

function PlayerProfiles:renew(userId, token)
    return self:_owned(userId, token)
end

function PlayerProfiles:release(userId, token)
    return self:_owned(userId, token, nil, true)
end

function PlayerProfiles:commitDojoWallet(userId, token, command)
    if type(command) ~= "table" or (command.kind ~= "buy"
        and not ((command.kind == "equip" or command.kind == "bundleEquip" or command.kind == "fighterCosmetic")
            and type(command.equipped) == "boolean")) then
        return nil, "invalid wallet command"
    end
    if command.kind == "fighterCosmetic" and (not isFighter(command.fighterId)
        or not cosmeticSlots[command.slot] or not cosmeticId(command.itemId)) then
        return nil, "invalid wallet command"
    end
    local status
    local saved, reason = self:_owned(userId, token, function(profile)
        local purchase = profile.dojoWallet
        if command.kind == "fighterCosmetic" then
            local fighterId = command.fighterId
            if PlayerProfiles.activeFighter(profile) ~= fighterId then return "fighter changed" end
            local fittings = table.clone(profile.fighterCosmetics or {})
            local equipped = table.clone(fittings[fighterId] or {})
            if command.equipped then
                equipped[command.slot] = command.itemId
                status = "Cosmetic equipped."
            elseif equipped[command.slot] == command.itemId then
                equipped[command.slot] = nil
                status = "Cosmetic removed."
            end
            fittings[fighterId] = if next(equipped) then equipped else nil
            profile.fighterCosmetics = if next(fittings) then fittings else nil
        elseif command.kind == "bundleEquip" then
            -- This is an appearance preference only. Roblox verifies ownership separately.
            profile.midnightLanternEquipped = command.equipped
            status = if command.equipped then "Midnight Lantern Set equipped." else "Midnight Lantern Set removed."
        elseif command.kind == "buy" then
            if purchase then
                status = "You already own the Jade Festival Sash."
                return
            end
            if PlayerProfiles.wallet(profile).coins < MARKET_SASH_COST then
                return "insufficient coins"
            end
            profile.dojoWallet = {spent = MARKET_SASH_COST, marketSashEquipped = true}
            status = "Jade Festival Sash purchased and equipped."
        else
            if not purchase then return "sash not owned" end
            profile.dojoWallet = table.clone(purchase)
            profile.dojoWallet.marketSashEquipped = command.equipped
            status = if command.equipped then "Jade Festival Sash equipped." else "Jade Festival Sash removed."
        end
    end)
    return saved, reason, if saved then status else nil
end

local function validHandoffRequest(userId, token, id, destination)
    return whole(userId, 1, 9e15) and validHandoffId(token) and validHandoffId(id) and validHandoffId(destination)
end

-- Called by the serial profile worker after pausing new grants and confirming pending writes.
-- The destination and transfer ID are derived from an authorized match assignment on the server.
function PlayerProfiles:prepareMatchHandoff(userId, token, id, destination, sequence, deadline)
    if not validHandoffRequest(userId, token, id, destination)
        or not whole(sequence, 1, MAX_HANDOFF_SEQUENCE) or not whole(deadline, 1, 1e12) then
        return nil, "invalid handoff"
    end
    return self:_update(userId, function(current, now)
        if not valid(current) then return nil, "invalid" end
        local lease = current.lease
        if not lease or lease.token ~= token or lease.expiresAt <= now then return nil, "ownership" end
        if deadline <= now or deadline > now + MATCH_HANDOFF_SECONDS then return nil, "invalid deadline" end
        local previous = lease.handoff
        if previous and previous.id == id then
            if previous.state == "pending" and previous.destination == destination
                and previous.sequence == sequence and previous.deadline == deadline then
                return current
            end
            return nil, "stale handoff"
        end
        if pendingHandoff(lease) then return nil, "transferring" end
        if previous and previous.state == "cancelled" and sequence <= previous.sequence then
            return nil, "stale handoff"
        end
        local updated = table.clone(current)
        updated.lease = {token = token, expiresAt = deadline, handoff = {
            id = id, destination = destination, sequence = sequence, deadline = deadline, state = "pending",
        }}
        return updated
    end)
end

-- Accept only after the coordinator verifies this user's seat in the assigned physical destination job.
function PlayerProfiles:acceptMatchHandoff(userId, token, id, destination)
    if not validHandoffRequest(userId, token, id, destination) then return nil, "invalid handoff" end
    return self:_update(userId, function(current, now)
        if not valid(current) then return nil, "invalid" end
        local lease = current.lease
        local handoff = lease and lease.handoff
        if not handoff or handoff.id ~= id or handoff.destination ~= destination then return nil, "stale handoff" end
        if lease.expiresAt <= now then return nil, "expired" end
        if handoff.state == "accepted" and lease.token == token then return current end
        if handoff.state ~= "pending" or lease.token == token then return nil, "unavailable handoff" end
        local accepted = table.clone(handoff)
        accepted.state = "accepted"
        local updated = table.clone(current)
        updated.lease = refreshLease(token, now, accepted)
        return updated
    end)
end

function PlayerProfiles:cancelMatchHandoff(userId, token, id, destination)
    if not validHandoffRequest(userId, token, id, destination) then return nil, "invalid handoff" end
    return self:_update(userId, function(current, now)
        if not valid(current) then return nil, "invalid" end
        local lease = current.lease
        if not lease or lease.token ~= token or lease.expiresAt <= now then return nil, "ownership" end
        local handoff = lease.handoff
        if not handoff or handoff.id ~= id or handoff.destination ~= destination then return nil, "stale handoff" end
        if handoff.state == "cancelled" then return current end
        if handoff.state ~= "pending" then return nil, "unavailable handoff" end
        local cancelled = table.clone(handoff)
        cancelled.state = "cancelled"
        local updated = table.clone(current)
        updated.lease = refreshLease(token, now, cancelled)
        return updated
    end)
end

-- Preserve an acknowledgement across a lost reply or a new city's subsequent open.
function PlayerProfiles:releaseMatchReturn(userId, token, id)
    if not whole(userId, 1, 9e15) or not validHandoffId(token) or not validHandoffId(id) then
        return false, "invalid return"
    end
    local saved, reason = self:_update(userId, function(current, now)
        if current == nil then return nil, "ownership" end
        if not valid(current) then return nil, "invalid" end
        local lease = current.lease
        if current.duelReturn and current.duelReturn.id == id and current.duelReturn.token == token then
            if not lease or lease.token ~= token then return current end
            return nil, "stale return"
        end
        if not lease or lease.token ~= token or lease.expiresAt <= now then return nil, "ownership" end
        if pendingHandoff(lease) then return nil, "transferring" end
        local updated = table.clone(current)
        updated.lease = nil
        updated.duelReturn = {id = id, token = token}
        return updated
    end)
    return saved ~= nil, reason
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

function PlayerProfiles:commitFighterSwitch(userId, token, fighterId, formId, tactical, basic, ultimate)
    if not isFighter(fighterId) then
        return nil, "invalid fighter"
    end
    if tactical ~= nil and not PlayerProfiles.tacticalUnlockLevel(fighterId, tactical) then
        return nil, "invalid tactical"
    end
    if basic ~= nil and not FighterLoadouts.get(fighterId, "basic", basic) then
        return nil, "invalid basic"
    end
    if ultimate ~= nil and not FighterLoadouts.get(fighterId, "ultimate", ultimate) then
        return nil, "invalid ultimate"
    end
    return self:_owned(userId, token, function(profile, now)
        if not PlayerProfiles.canSwitch(profile, fighterId) then
            return "fighter locked"
        end
        local fighter = profile.fighters[fighterId]
        local storedForm = fighter and fighter.equippedForm
        local storedTactical = fighter and fighter.equippedTactical
        local storedBasic = fighter and fighter.equippedBasic
        local storedUltimate = fighter and fighter.equippedUltimate
        local equippedForm, equippedTactical = storedForm, storedTactical
        local equippedBasic, equippedUltimate = storedBasic, storedUltimate
        if formId ~= nil then
            if not PlayerProfiles.canEquipForm(profile, fighterId, formId) then
                return "form locked"
            end
            equippedForm = if formId == FighterForms.BaseId then nil else formId
        end
        if tactical ~= nil then
            if not PlayerProfiles.canEquipTactical(profile, fighterId, tactical) then
                return "tactical locked"
            end
            equippedTactical = if tactical == FighterTactics.ByFighter[fighterId].default then nil else tactical
        end
        if basic ~= nil then
            if not PlayerProfiles.canEquipLoadout(profile, fighterId, "basic", basic) then
                return "basic locked"
            end
            equippedBasic = if basic == FighterLoadouts.ByFighter[fighterId].basic.default then nil else basic
        end
        if ultimate ~= nil then
            if not PlayerProfiles.canEquipLoadout(profile, fighterId, "ultimate", ultimate) then
                return "ultimate locked"
            end
            equippedUltimate = if ultimate == FighterLoadouts.ByFighter[fighterId].ultimate.default then nil else ultimate
        end
        local outgoing = PlayerProfiles.activeFighter(profile)
        local rememberOutgoing = outgoing and not isStarter(outgoing) and profile.fighters[outgoing] == nil
        if rememberOutgoing or not fighter or equippedForm ~= storedForm or equippedTactical ~= storedTactical
            or equippedBasic ~= storedBasic or equippedUltimate ~= storedUltimate then
            profile.fighters = table.clone(profile.fighters)
            if rememberOutgoing then profile.fighters[outgoing] = {xp = 0} end
            local updated = table.clone(fighter or {xp = 0})
            updated.equippedForm, updated.equippedTactical = equippedForm, equippedTactical
            updated.equippedBasic, updated.equippedUltimate = equippedBasic, equippedUltimate
            profile.fighters[fighterId] = updated
        end
        if formId ~= nil and equippedForm and profile.trophies[NEW_FORM] == nil then
            profile.trophies = table.clone(profile.trophies)
            profile.trophies[NEW_FORM] = {earnedAt = now, criterionVersion = 1, completionId = "fighter-form"}
        end
        if EXPANDED_UNLOCKS[fighterId] then
            -- Older builds still see a fighter they can equip and retain new progress fields.
            profile.activeExpandedFighter = fighterId
            profile.expandedFallback = fallbackFighter(profile)
            return
        end
        profile.activeExpandedFighter, profile.expandedFallback = nil, nil
        if isStarter(fighterId) then
            profile.activeStarterFighter = fighterId
            profile.activeRosterFighter = nil
        else
            -- Keep the legacy starter as a playable fallback on the previous build.
            profile.activeRosterFighter = fighterId
        end
    end)
end

local function completeWorldCollection(profile, now)
    local trophies = profile.trophies
    if not trophies["world-06"] and trophies[KILN_KEEPER] and trophies[DEEPWATER_TEAM]
        and trophies[DAWN_RETURN] and trophies[LANTERN_KEEPER] and trophies["world-05"] then
        profile.trophies = table.clone(trophies)
        profile.trophies["world-06"] = {earnedAt = now, criterionVersion = 1}
    end
end

function PlayerProfiles:commitCityAdventure(userId, token, receipt)
    if type(receipt) ~= "table" or not validCompletionId(receipt.id) or not isFighter(receipt.fighterId) then
        return nil, "invalid adventure receipt"
    end
    local saved, reason = self:_owned(userId, token, function(profile, now)
        if profile.cityAdventureReceipt and profile.cityAdventureReceipt.id == receipt.id then return end
        if not PlayerProfiles.canSwitch(profile, receipt.fighterId) then return "fighter locked" end
        local updated, xp, awards = CityAdventureProgress.apply(profile.cityAdventure, receipt)
        profile.cityAdventure = updated
        if #awards > 0 then
            profile.trophies = table.clone(profile.trophies)
            for _, id in awards do
                profile.trophies[id] = profile.trophies[id] or {earnedAt = now, criterionVersion = 1}
            end
        end
        completeWorldCollection(profile, now)
        if xp > 0 then addFighterXp(profile, receipt.fighterId, xp) end
        -- Keep the receipt readable by versions that validate the original XP range.
        profile.cityAdventureReceipt = {id = receipt.id, xp = if xp == 1000 then 0 else xp,
            rareCache = if xp == 1000 then true else nil}
    end)
    local recorded = saved and saved.cityAdventureReceipt
    return saved, reason, if recorded and recorded.id == receipt.id
        then (if recorded.rareCache then 1000 else recorded.xp) else 0
end

function PlayerProfiles:commitRaid(userId, token, raidId, window, completionId)
    local trophyId = RAID_TROPHIES[raidId]
    if not trophyId or not whole(window, 0, 1e10) or not validCompletionId(completionId) then
        return nil, "invalid result"
    end
    local saved, reason = self:_owned(userId, token, function(profile, now)
        -- Keep the original storage key so a rollback still reads the shared balances.
        local previous = profile.kilnback
        local trophy = profile.trophies[trophyId]
        if previous and (window <= previous.window or completionId == previous.id) then
            return
        end
        for _, awardId in RAID_TROPHIES do
            local award = profile.trophies[awardId]
            if award and award.completionId == completionId then
                return
            end
        end
        if not trophy then
            profile.trophies = table.clone(profile.trophies)
            profile.trophies[trophyId] = {earnedAt = now, criterionVersion = 1, completionId = completionId}
        end
        completeWorldCollection(profile, now)
        local tokens, shards = previous and previous.tokens or 0, previous and previous.shards or 0
        local grantTokens, grantShards = math.min(RAID_TOKENS, 1e12 - tokens), math.min(RAID_SHARDS, 1e12 - shards)
        -- The previous checkpoint only accepts Kilnback and Kraken in raidId.
        -- Keep Phoenix's identity in the additive field for safe rollback.
        profile.kilnback = {raidId = if raidId == "phoenix" then nil else raidId,
            encounterId = raidId, window = window, id = completionId,
            tokens = tokens + grantTokens, shards = shards + grantShards, grantedTokens = grantTokens, grantedShards = grantShards}
    end)
    if not saved then
        return nil, reason
    end
    local receipt = saved.kilnback
    local applied = receipt and (receipt.encounterId or receipt.raidId or "kilnback") == raidId
        and receipt.window == window and receipt.id == completionId
    local trophy = saved.trophies[trophyId]
    return saved, nil, {status = if applied then "saved" else "already",
        tokens = if applied then receipt.grantedTokens or RAID_TOKENS else 0,
        shards = if applied then receipt.grantedShards or RAID_SHARDS else 0,
        newTrophy = applied and trophy and trophy.completionId == completionId or false}
end

function PlayerProfiles:commitRelay(userId, token, elapsedTenths, completionId, fighterId)
    fighterId = fighterId or REEDGUARD
    if not whole(elapsedTenths, 1, 1200) or not validCompletionId(completionId) or not isFighter(fighterId) then
        return nil, "invalid result"
    end
    local legacy = isStarter(fighterId)
    local receiptKey = fieldsFor(fighterId).relay
    local saved, reason = self:_owned(userId, token, function(profile, now)
        if not legacy and not PlayerProfiles.canSwitch(profile, fighterId) then
            return "fighter locked"
        end
        local trophy = profile.trophies[LANTERN_KEEPER]
        if (trophy and trophy.completionId == completionId)
            or (profile[receiptKey] and profile[receiptKey].id == completionId) then
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
        completeWorldCollection(profile, now)
        profile[receiptKey] = {id = completionId, fighterId = fighterId, xp = xp}
        addFighterXp(profile, fighterId, xp)
    end)
    local first = saved ~= nil and saved.trophies[LANTERN_KEEPER].completionId == completionId
    local receipt = saved and saved[receiptKey]
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
    if not validCompletionId(completionId) or not isFighter(fighterId) then
        return nil, "invalid result"
    end
    local saved, reason = self:_owned(userId, token, function(profile)
        if not isStarter(fighterId) and not PlayerProfiles.canSwitch(profile, fighterId) then
            return "fighter locked"
        end
        if profile.firstSparWinId == nil then
            profile.firstSparWinId = completionId
            addFighterXp(profile, fighterId, FIRST_SPAR_WIN_XP)
        end
    end)
    return saved, reason, saved ~= nil and saved.firstSparWinId == completionId
end

function PlayerProfiles:commitSparWin(userId, token, completionId, fighterId)
    if not isFighter(fighterId) or not validCompletionId(completionId) then
        return nil, "invalid result"
    end
    local legacy = isStarter(fighterId)
    local receiptKey = fieldsFor(fighterId).spar
    local saved, reason = self:_owned(userId, token, function(profile)
        if not legacy and not PlayerProfiles.canSwitch(profile, fighterId) then
            return "fighter locked"
        end
        if profile.firstSparWinId == completionId
            or (profile[receiptKey] and profile[receiptKey].id == completionId) then
            return
        end
        local first = profile.firstSparWinId == nil
        local xp = if first then FIRST_SPAR_WIN_XP else REPEAT_SPAR_WIN_XP
        if first then
            profile.firstSparWinId = completionId
        end
        profile[receiptKey] = {id = completionId, fighterId = fighterId, xp = xp}
        addFighterXp(profile, fighterId, xp)
    end)
    local first = saved ~= nil and saved.firstSparWinId == completionId
    local receipt = saved and saved[receiptKey]
    return saved, reason, first, if first then FIRST_SPAR_WIN_XP
        elseif receipt and receipt.id == completionId then receipt.xp else 0
end

function PlayerProfiles:commitRingTraining(userId, token, drillId, completionId, fighterId, xp)
    if not isFighter(fighterId) or not validCompletionId(drillId) or not validCompletionId(completionId)
        or not whole(xp, 1, LEVEL_THRESHOLDS[#LEVEL_THRESHOLDS]) then
        return nil, "invalid training result"
    end
    local legacy = isStarter(fighterId)
    local trainingKey = fieldsFor(fighterId).training
    local saved, reason = self:_owned(userId, token, function(profile)
        if not legacy and not PlayerProfiles.canSwitch(profile, fighterId) then
            return "fighter locked"
        end
        local training = profile[trainingKey] or {}
        local recorded = training[fighterId] or {}
        if recorded[drillId] == completionId then
            return
        end
        profile[trainingKey] = table.clone(training)
        local updated = table.clone(recorded)
        updated[drillId] = completionId
        profile[trainingKey][fighterId] = updated
        addFighterXp(profile, fighterId, xp)
    end)
    return saved, reason, saved ~= nil and saved[trainingKey][fighterId][drillId] == completionId
end

return PlayerProfiles
