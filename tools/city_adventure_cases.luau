local Catalog, Progress = CityAdventureCatalog, CityAdventureProgress
local now, count = 18000000, 0
local durable = PlayerProfiles.memoryStore()
local loseReply = false
local store = {}
function store:UpdateAsync(key, callback)
    local saved = durable:UpdateAsync(key, callback)
    if loseReply then loseReply = false; error("Commits even though one response was lost") end
    return saved
end
local profiles = PlayerProfiles.new(store, function() return now end, function() end)
local playerId, lease = 9744, "city-adventure"
assert(profiles:open(playerId, lease))
local profile = assert(profiles:commitStarterChoice(playerId, lease, "reedguard-kangaroo"))
assert(profile.cityAdventure == nil, "Use the existing profile schema before the first city activity")
local startingWallet = PlayerProfiles.wallet(profile)
assert(startingWallet.coins == 0 and not startingWallet.marketSashOwned and not startingWallet.marketSashEquipped)
local rejected, reason = profiles:commitDojoWallet(playerId, lease, {kind = "buy"})
assert(not rejected and reason == "insufficient coins")
rejected, reason = profiles:commitDojoWallet(playerId, lease, {kind = "equip", equipped = false})
assert(not rejected and reason == "sash not owned")
rejected, reason = profiles:commitDojoWallet(playerId, lease, {kind = "equip", equipped = "true"})
assert(not rejected and reason == "invalid wallet command")

local function result(kind, fields)
    count += 1
    local action = table.clone(fields or {})
    action.kind, action.at, action.id = kind, now, "city-proof-" .. count
    action.fighterId = "reedguard-kangaroo"
    local updated, why, xp = profiles:commitCityAdventure(playerId, lease, action)
    assert(updated, why)
    assert(Progress.valid(updated.cityAdventure))
    profile = updated
    return xp, action
end

assert(result("trial", {district = "valley"}) == 0)
assert(result("cache", {district = "valley"}) == 0)
assert(result("grand-cache") == 0)
assert(result("graduate") == 0)
assert(result("sash", {equipped = true}) == 0 and not profile.cityAdventure.cloudbreak)
assert(not profiles:commitCityAdventure(playerId, "stale-lease", {id = "invalid", fighterId = "reedguard-kangaroo"}))

local firstThree = {"reed-path", "lantern-timing", "tide-path"}
for i, id in firstThree do
    local definition = Catalog.activities[id]
    assert(result("activity", {district = definition.district, activity = id, tenths = 209}) == (if i == 3 then 95 else 30))
    assert(result("activity", {district = definition.district, activity = id, tenths = 310}) == 0)
    assert(PlayerProfiles.wallet(profile).coins == i * 20)
end
assert(profile.trophies["world-05"])
assert(Progress.count(profile.cityAdventure.festival.stamps) == 3 and profile.cityAdventure.festival.earned)
assert(profile.cityAdventure.activities["reed-path"] == 209)

for _, chapter in Catalog.chapters do
    local district = chapter.id
    assert(result("mentor", {district = district}) == 0)
    for index = 1, 3 do
        assert(result("survey", {district = district, index = index}) == 0)
        assert(result("seal", {district = district, index = index}) == 8)
        assert(result("seal", {district = district, index = index}) == 0)
    end
    assert(profile.trophies["discovery-" .. district])
    assert(result("cache", {district = district}) == 40)
    assert(result("cache", {district = district}) == 0)
    for _, activity in chapter.activities do
        result("activity", {district = district, activity = activity[1], tenths = 180})
    end
    assert(profile.cityAdventure.districts[district].step == 2)
    assert(result("mentor", {district = district}) == 0)
    assert(profile.cityAdventure.districts[district].step == 2)
    assert(result("trial", {district = district}) == 0)
    assert(result("mentor", {district = district}) == 50)
    assert(result("mentor", {district = district}) == 0)
    if district ~= "sky" then
        assert(result("activity", {district = district, activity = chapter.activities[chapter.mastery][1],
            tenths = 175, expert = true}) == 45)
        assert(profile.trophies["mastery-" .. district])
    end
end
local totals = Progress.totals(profile.cityAdventure)
assert(totals.chapters == 6 and totals.seals == 18 and totals.caches == 6 and totals.visited == 6)
assert(Progress.count(profile.cityAdventure.activities) == 12)
assert(PlayerProfiles.wallet(profile).coins == 510)
assert(result("graduate") == 85 and result("grand-cache") == 100)
assert(result("graduate") == 0 and result("grand-cache") == 0)
local rare = 0
for roll = 1, 100 do
    local reward = Progress.rollCacheXp({NextInteger = function(_, low, high)
        if low == 1 then
            assert(high == 100)
            return roll
        end
        assert(low == 20 and high == 40)
        return if roll % 2 == 0 then low else high
    end})
    if roll <= 5 then
        assert(reward == 1000)
        rare += 1
    else
        assert(reward == (if roll % 2 == 0 then 20 else 40))
    end
end
assert(rare == 5)
local cacheStart = now
local walletBeforeRepeat = PlayerProfiles.wallet(profile).coins
assert(Progress.cacheReadyAt(profile.cityAdventure, "valley") == 0, "Legacy cache progress has no cooldown")
assert(Progress.cacheReadyAt(profile.cityAdventure, "grand") == 0)
loseReply = true
local cacheXp, cacheReceipt = result("cache", {district = "valley", rewardXp = 20})
assert(cacheXp == 20)
assert(result("grand-cache", {rewardXp = 1000}) == 1000)
local xpAfterCaches = profile.fighters["reedguard-kangaroo"].xp
local sameClaim, _, replayXp = profiles:commitCityAdventure(playerId, lease, cacheReceipt)
assert(replayXp == 0 and sameClaim.fighters["reedguard-kangaroo"].xp == xpAfterCaches)
assert(profiles:release(playerId, lease))
lease = "cache-rejoin"
profile = assert(profiles:open(playerId, lease))
assert(Progress.cacheReadyAt(profile.cityAdventure, "valley") == cacheStart + 172800)
assert(Progress.cacheReadyAt(profile.cityAdventure, "grand") == cacheStart + 172800)
assert(profile.fighters["reedguard-kangaroo"].xp == xpAfterCaches)
assert(profiles:release(playerId, lease))
now = cacheStart + 172799
lease = "cache-reset"
assert(profiles:open(playerId, lease))
assert(result("cache", {district = "valley", rewardXp = 1000}) == 0)
assert(result("grand-cache", {rewardXp = 40}) == 0)
now += 1
assert(result("cache", {district = "valley", rewardXp = 40}) == 40)
assert(result("grand-cache", {rewardXp = 20}) == 20)
assert(PlayerProfiles.wallet(profile).coins == walletBeforeRepeat)
print("Treasure caches passed 95/5 rolls, XP bounds, retries, server rejoin, and the exact 48-hour reset.")
for _, id in {"journey-01", "journey-02", "journey-03", "journey-05", "journey-06"} do
    assert(profile.trophies[id], id)
end
assert(result("track", {district = "frost"}) == 0 and profile.cityAdventure.tracked == "frost")

local startingXP = profile.fighters["reedguard-kangaroo"].xp
assert(Progress.cloudbreakTenths(math.huge) == nil and Progress.cloudbreakTenths(0/0) == nil)
local longFinish = assert(Progress.cloudbreakTenths(228.1))
loseReply = true
local xp, clear = result("cloudbreak", {tenths = longFinish, clean = false})
assert(xp == 85 and profile.fighters["reedguard-kangaroo"].xp == startingXP + 85)
assert(profile.cityAdventure.cloudbreak.best == 2281 and not profile.cityAdventure.cloudbreak.cleanBest)
assert(profile.cityAdventure.cloudbreak.equipped and profile.trophies["mastery-sky"])
local replay, _, creditedXP = profiles:commitCityAdventure(playerId, lease, clear)
assert(creditedXP == 85 and replay.fighters["reedguard-kangaroo"].xp == startingXP + 85)
assert(profiles:release(playerId, lease))
lease = "after-long-clear"
local afterLongClear = assert(profiles:open(playerId, lease))
assert(afterLongClear.cityAdventure.cloudbreak.best == 2281)
assert(afterLongClear.cityAdventure.cloudbreak.equipped and afterLongClear.trophies["mastery-sky"])
assert(result("cloudbreak", {tenths = 265, clean = false}) == 0)
assert(result("cloudbreak", {tenths = 281, clean = true}) == 0)
assert(result("sash", {equipped = false}) == 0)
assert(result("cloudbreak", {tenths = 309, clean = true}) == 0 and not profile.cityAdventure.cloudbreak.equipped)
assert(profile.cityAdventure.cloudbreak.best == 265 and profile.cityAdventure.cloudbreak.cleanBest == 281)
assert(PlayerProfiles.wallet(profile).coins == 570)

assert(profiles:release(playerId, lease))
now += Catalog.festivalDuration
assert(profiles:open(playerId, lease))
assert(result("festival", {activity = "relay"}) == 0)
local closedWindow = profile.cityAdventure.festival.window
assert(profiles:release(playerId, lease))
now += Catalog.festivalPeriod - Catalog.festivalDuration
assert(profiles:open(playerId, lease))
assert(result("festival", {activity = "relay"}) == 0 and profile.cityAdventure.festival.window == closedWindow + 1)
assert(Progress.count(profile.cityAdventure.festival.stamps) == 1 and not profile.cityAdventure.festival.earned)
assert(result("festival", {activity = "relay"}) == 0)
assert(result("festival", {activity = "cloudbreak"}) == 0)
assert(result("festival", {activity = "bellows"}) == 65)

assert(profiles:release(playerId, lease))
lease = "new-server-city"
local restored = assert(profiles:open(playerId, lease))
assert(restored.cityAdventure.graduated and restored.cityAdventure.grandCache)
assert(Progress.totals(restored.cityAdventure).seals == 18 and restored.cityAdventure.cloudbreak.cleanBest == 281)
assert(restored.cityAdventure.cloudbreak.equipped == false)
local other = assert(profiles:open(playerId + 1, "other-server"))
assert(other.cityAdventure == nil and next(other.trophies) == nil)
local damaged = table.clone(restored.cityAdventure)
damaged.districts = {valley = {step = 4}}
assert(not Progress.valid(damaged))
print("City adventure passed six chapters, 12 activities, 18 seals, seven caches, repeat festival windows, and an idempotent Cloudbreak reward across profile rejoin.")

-- Existing achievements create a wallet on read. The purchase record owns the debit and the cosmetic.
assert(restored.dojoWallet == nil and PlayerProfiles.wallet(restored).coins == 570)
local firstRelay = assert(profiles:commitRelay(playerId, lease, 95, "wallet-relay"))
assert(PlayerProfiles.wallet(firstRelay).coins == 630)
local firstSpar = assert(profiles:commitSparWin(playerId, lease, "wallet-spar", "reedguard-kangaroo"))
assert(PlayerProfiles.wallet(firstSpar).coins == 660)
assert(profiles:commitRelay(playerId, lease, 92, "wallet-relay-repeat"))
local beforeBuy = assert(profiles:commitSparWin(playerId, lease, "wallet-spar-repeat", "reedguard-kangaroo"))
assert(PlayerProfiles.wallet(beforeBuy).coins == 660)
local beforeBuyXp = beforeBuy.fighters["reedguard-kangaroo"].xp
rejected, reason = profiles:commitDojoWallet(playerId, "stale-lease", {kind = "buy"})
assert(not rejected and reason == "ownership")

loseReply = true
local purchase, purchaseError, status = profiles:commitDojoWallet(playerId, lease, {kind = "buy", coins = 0})
assert(purchase and purchaseError == nil and status == "You already own the Jade Festival Sash.")
local bought = PlayerProfiles.wallet(purchase)
assert(bought.coins == 610 and bought.marketSashOwned and bought.marketSashEquipped)
assert(purchase.fighters["reedguard-kangaroo"].xp == beforeBuyXp)
local removed = assert(profiles:commitDojoWallet(playerId, lease, {kind = "equip", equipped = false}))
assert(not PlayerProfiles.wallet(removed).marketSashEquipped and purchase.dojoWallet.marketSashEquipped)
local retry = assert(profiles:commitDojoWallet(playerId, lease, {kind = "buy"}))
local afterRetry = PlayerProfiles.wallet(retry)
assert(afterRetry.coins == 610 and afterRetry.marketSashOwned and not afterRetry.marketSashEquipped)

assert(profiles:release(playerId, lease))
local walletLease = "new-server-wallet"
local afterReconnect = assert(profiles:open(playerId, walletLease))
local rejoined = PlayerProfiles.wallet(afterReconnect)
assert(rejoined.coins == 610 and rejoined.marketSashOwned and not rejoined.marketSashEquipped)
local equipped = assert(profiles:commitDojoWallet(playerId, walletLease, {kind = "equip", equipped = true}))
assert(PlayerProfiles.wallet(equipped).marketSashEquipped and PlayerProfiles.wallet(equipped).coins == 610)
assert(PlayerProfiles.wallet(other).coins == 0 and not PlayerProfiles.wallet(other).marketSashOwned)
print("Dojo wallet passed legacy credits, repeat rewards, stale ownership, insufficient funds, lost purchase reply, duplicate purchase, equip and rejoin.")

assert(equipped.midnightLanternEquipped == nil)
local bundle, bundleError = profiles:commitDojoWallet(playerId, walletLease, {kind = "bundleEquip", equipped = "true"})
assert(not bundle and bundleError == "invalid wallet command")
bundle, bundleError = profiles:commitDojoWallet(playerId, lease, {kind = "bundleEquip", equipped = false})
assert(not bundle and bundleError == "ownership")
local chosen = assert(profiles:commitDojoWallet(playerId, walletLease, {kind = "bundleEquip", equipped = false}))
assert(chosen.midnightLanternEquipped == false)
assert(PlayerProfiles.wallet(chosen).coins == 610 and PlayerProfiles.wallet(chosen).marketSashEquipped)
assert(profiles:release(playerId, walletLease))
local rejoinLease = "new-server-appearance"
local rejoinedBundle = assert(profiles:open(playerId, rejoinLease))
assert(rejoinedBundle.midnightLanternEquipped == false and PlayerProfiles.wallet(rejoinedBundle).coins == 610)
local restoredBundle = assert(profiles:commitDojoWallet(playerId, rejoinLease,
    {kind = "bundleEquip", equipped = true}))
assert(restoredBundle.midnightLanternEquipped == true and PlayerProfiles.wallet(restoredBundle).coins == 610)
print("Bundle equip preference survived rejoin and left earned Coins and the Jade Sash intact.")

local progressionStore = PlayerProfiles.memoryStore()
local progression = PlayerProfiles.new(progressionStore, function() return now end, function() end)
local reedguard = "reedguard-kangaroo"
local guideUser, firstJob, secondJob, thirdJob = 14, "guide-first", "guide-second", "guide-third"
assert(progression:open(guideUser, firstJob))
assert(progression:commitStarterChoice(guideUser, firstJob, reedguard))
local tracked = assert(progression:commitCityAdventure(guideUser, firstJob,
    {kind = "guided-goal", goal = "relay", at = now, id = "track-relay", fighterId = reedguard}))
assert(tracked.cityAdventure.guidedGoal == "relay")
assert(progression:release(guideUser, firstJob))
assert(progression:open(guideUser, secondJob).cityAdventure.guidedGoal == "relay")
local goalReward, _, firstClear, xpReward = progression:commitRelay(guideUser, secondJob, 183, "guided-relay", reedguard)
assert(goalReward.cityAdventure.guidedGoal == "trophy" and firstClear and xpReward == 80)
assert(PlayerProfiles.wallet(goalReward).coins == 60 and goalReward.trophies["world-04"])
assert(progression:release(guideUser, secondJob))
local guideRestored = assert(progression:open(guideUser, thirdJob))
assert(guideRestored.cityAdventure.guidedGoal == "trophy" and guideRestored.relayBestTenths == 183)
assert(guideRestored.trophies["world-04"] and PlayerProfiles.summary(guideRestored).xp == 80)
local nextGoal = assert(progression:commitCityAdventure(guideUser, thirdJob,
    {kind = "track", district = "valley", at = now, id = "track-valley", fighterId = reedguard}))
assert(nextGoal.cityAdventure.guidedGoal == nil and nextGoal.cityAdventure.tracked == "valley")
local replayedGuide = assert(progression:commitRelay(guideUser, thirdJob, 183, "guided-relay", reedguard))
assert(replayedGuide.cityAdventure.tracked == "valley" and PlayerProfiles.summary(replayedGuide).xp == 80)
print("Adventure goal survived separate leases, advanced with the first Relay grant, and yielded to the next tracked activity.")
local fresh = assert(progression:open(11, "fresh-curve"))
assert(PlayerProfiles.summary(fresh).nextLevelXp == 250)
assert(PlayerProfiles.levelForXp(249) == 1 and PlayerProfiles.levelForXp(250) == 2)
assert(PlayerProfiles.levelForXp(2849) == 6 and PlayerProfiles.levelForXp(2850) == 7)
assert(PlayerProfiles.levelForXp(5799) == 9 and PlayerProfiles.levelForXp(5800) == 10)
progressionStore:UpdateAsync("player_12", function()
    return {
        schemaVersion = 1, relayBestTenths = 0, trophies = {},
        selectedStarterFighter = reedguard, activeRosterFighter = "karate-frog",
        fighters = {[reedguard] = {xp = 480}, ["karate-frog"] = {xp = 81}, ["fire-salamander"] = {xp = 79}},
    }
end)
local migrated = assert(progression:open(12, "legacy-curve"))
local summary = PlayerProfiles.summary(migrated)
assert(summary.level == 5 and summary.xp == 1470 and summary.nextLevelXp == 2100)
assert(migrated.fighters[reedguard].xp == 480 and PlayerProfiles.canSwitch(migrated, "karate-frog"))
assert(PlayerProfiles.summary(migrated, "karate-frog").xp == 251)
assert(PlayerProfiles.summary(migrated, "fire-salamander").xp == 79)
local rewarded = assert(progression:commitSparWin(12, "legacy-curve", "post-migration-win", reedguard))
assert(PlayerProfiles.summary(rewarded).xp == 1530 and rewarded.fighters[reedguard].xp == 540)
assert(progression:release(12, "legacy-curve"))
local curveRejoin = assert(progression:open(12, "rejoin-curve"))
assert(PlayerProfiles.summary(curveRejoin).xp == 1530 and PlayerProfiles.activeFighter(curveRejoin) == "karate-frog")
print("Fighter XP passed the new thresholds, legacy levels, subsequent rewards and idempotent reconnect migration.")

local handwear = {
    {fighterId = reedguard, itemId = "reedguard-bamboo-mitts"},
    {fighterId = "penguin-brawler", itemId = "penguin-glacier-mitts"},
    {fighterId = "silverback-gorilla", itemId = "silverback-cedar-bracers"},
    {fighterId = "fire-salamander", itemId = "salamander-kiln-mitts"},
}
for _, item in handwear do
    item.kind, item.slot, item.equipped = "fighterCosmetic", "hands", true
    local wrongFighter, wearError = progression:commitDojoWallet(12, "rejoin-curve", item)
    assert(wrongFighter == nil and wearError == "fighter changed", item.itemId)
    assert(progression:commitFighterSwitch(12, "rejoin-curve", item.fighterId))
    local fitted = assert(progression:commitDojoWallet(12, "rejoin-curve", item))
    assert(fitted.fighterCosmetics[item.fighterId].hands == item.itemId)
end
assert(progression:commitFighterSwitch(12, "rejoin-curve", "karate-frog"))
assert(progression:release(12, "rejoin-curve"))
local wardrobeLease = "wardrobe-rejoin"
local rejoinedWardrobe = assert(progression:open(12, wardrobeLease))
assert(rejoinedWardrobe.fighterCosmetics["karate-frog"] == nil)
local savedFighters = 0
for _ in rejoinedWardrobe.fighterCosmetics do savedFighters += 1 end
assert(savedFighters == #handwear)
for _, item in handwear do
    local switched = assert(progression:commitFighterSwitch(12, wardrobeLease, item.fighterId))
    assert(PlayerProfiles.activeFighter(switched) == item.fighterId)
    local slots = switched.fighterCosmetics[item.fighterId]
    assert(slots.hands == item.itemId and next(slots) == "hands" and next(slots, "hands") == nil)
end

local first = handwear[1]
assert(progression:commitFighterSwitch(12, wardrobeLease, first.fighterId))
local invalidSlot = table.clone(first)
invalidSlot.slot = "invalid"
local rejectedGear, slotError = progression:commitDojoWallet(12, wardrobeLease, invalidSlot)
assert(rejectedGear == nil and slotError == "invalid wallet command")
local remove = table.clone(first)
remove.equipped = false
local removedGear = assert(progression:commitDojoWallet(12, wardrobeLease, remove))
assert(removedGear.fighterCosmetics[first.fighterId] == nil)
for index = 2, #handwear do
    local item = handwear[index]
    assert(removedGear.fighterCosmetics[item.fighterId].hands == item.itemId)
end
print("Four fighter-exclusive cosmetics passed wrong-fighter rejection, separate slots, rejoin and isolated removal.")

-- Gold keepsakes and improved scores share the durable Adventure receipt worker.
local quickLease = "quick-play-first"
local quickPlayer = 9751
local quick = assert(profiles:open(quickPlayer, quickLease))
quick = assert(profiles:commitStarterChoice(quickPlayer, quickLease, "reedguard-kangaroo"))
local modes = {bell = {9, 6, 180}, rush = {8, 3, 206}, rescue = {5, 0, 350}}
local firstResult
for id, outcome in modes do
    local receipt = {
        kind = "quick-play", id = "quick-first-" .. id, fighterId = "reedguard-kangaroo",
        activity = id, score = outcome[1], bonus = outcome[2], tenths = outcome[3], at = now,
    }
    if id == "bell" then loseReply = true; firstResult = receipt end
    local saved, issue, xp = profiles:commitCityAdventure(quickPlayer, quickLease, receipt)
    assert(saved, issue)
    assert(xp == 35 and saved.cityAdventure.quickPlay[id].gold and Progress.valid(saved.cityAdventure))
end
assert(profiles:release(quickPlayer, quickLease))
quickLease = "quick-play-rejoin"
quick = assert(profiles:open(quickPlayer, quickLease))
assert(quick.fighters["reedguard-kangaroo"].xp == 105)
assert(quick.cityAdventure.quickPlay.bell.bonus == 6 and quick.cityAdventure.quickPlay.rush.tenths == 206)
assert(quick.cityAdventure.quickPlay.rescue.gold and quick.cityAdventure.festival == nil)
local repeatReceipt = table.clone(firstResult)
repeatReceipt.id, repeatReceipt.score, repeatReceipt.bonus = "quick-repeat-bell", 10, 8
local savedBest, _, repeatXp = profiles:commitCityAdventure(quickPlayer, quickLease, repeatReceipt)
assert(repeatXp == 0 and savedBest.cityAdventure.quickPlay.bell.score == 10)
local invalidReceipt = table.clone(repeatReceipt)
invalidReceipt.id, invalidReceipt.score = "quick-invalid-bell", 9999
local ignored = assert(profiles:commitCityAdventure(quickPlayer, quickLease, invalidReceipt))
assert(ignored.cityAdventure.quickPlay.bell.score == 10 and ignored.fighters["reedguard-kangaroo"].xp == 105)
print("Quick Play saved three Gold records and kept all rewards idempotent after a lost reply and rejoin.")

local roomId, roomLease = 9764, "trophy-room-original"
assert(profiles:open(roomId,roomLease))
assert(profiles:commitStarterChoice(roomId,roomLease,"reedguard-kangaroo"))
local function roomReceipt(id,fields)
    fields.id, fields.at, fields.fighterId = id, now, "reedguard-kangaroo"
    return profiles:commitCityAdventure(roomId,roomLease,fields)
end
assert(roomReceipt("room-unearned",{kind="trophy-display",slot=1,trophy="world-04"})==nil)
assert(roomReceipt("room-first-duel",{kind="arena-trophy",mode="duel",outcome="win",parries=2}).trophies["arena-01"])
local displayed={kind="trophy-display",slot=1,trophy="arena-01"}
loseReply=true
assert(roomReceipt("room-display",displayed).cityAdventure.trophyRoom["1"]=="arena-01")
assert(roomReceipt("room-display",displayed).cityAdventure.trophyRoom["1"]=="arena-01")
assert(profiles:release(roomId,roomLease))
roomLease="trophy-room-rejoin"
local rejoinedRoom=assert(profiles:open(roomId,roomLease))
assert(rejoinedRoom.cityAdventure.trophyRoom["1"]=="arena-01")
local moved=assert(roomReceipt("room-move",{kind="trophy-display",slot=18,trophy="arena-01"}))
assert(moved.cityAdventure.trophyRoom["1"]==nil and moved.cityAdventure.trophyRoom["18"]=="arena-01")
assert(roomReceipt("room-invalid-slot",{kind="trophy-display",slot=19,trophy="arena-01"})==nil)
local removed=assert(roomReceipt("room-clear",{kind="trophy-display",slot=18,trophy=""}))
assert(removed.cityAdventure.trophyRoom["18"]==nil and removed.trophies["arena-01"])
for n=1,19 do
    local mode=if n==1 then "brawl" elseif n==2 then "tag" else "duel"
    removed=assert(roomReceipt("arena-credit-"..n,{kind="arena-trophy",mode=mode,placement=2,outcome="win",parries=1}))
end
for n=1,6 do assert(removed.trophies[string.format("arena-%02d",n)]) end
print("Trophy displays passed earning, unearned rejection, lost response, rejoin, wall slot moves and all six arena thresholds.")

do
    local original = PlayerProfiles.memoryStore()
    local otherUniverse = PlayerProfiles.memoryStore()
    local origin = PlayerProfiles.new(original, function() return now end, function() end)
    local separate = PlayerProfiles.new(otherUniverse, function() return now end, function() end)
    local tester = 8801
    StagingProgressionCases.seed(original, tester, now)
    StagingProgressionCases.migrate(origin, tester, "legacy-origin")
    local destination = PlayerProfiles.new(original, function() return now + 1 end, function() end)
    StagingProgressionCases.rejoin(destination, PlayerProfiles, RingProgression, tester, "new-city-job")
    local profileInOtherScope = assert(separate:open(tester, "independent-scope"))
    local data = PlayerProfiles.summary(profileInOtherScope)
    assert(data.highestFighterLevel == 1 and not data.lanternKeeper and data.relayBest == 0)
    assert(not PlayerProfiles.wallet(profileInOtherScope).marketSashOwned)
    for index, ring in {"cinder", "cloud-top", "galleon"} do
        local level = ({3, 5, 7})[index]
        local expected = ({550, 1450, 2850})[index]
        local access, hint = RingProgression.access(level - 1, 1, ring)
        assert(not access and hint:find(tostring(expected) .. " XP", 1, true))
        assert(PlayerProfiles.levelForXp(expected - 1) == level - 1)
        assert(PlayerProfiles.levelForXp(expected) == level and RingProgression.access(level, 1, ring))
    end
    print("Legacy Level 7, both satellite ring gates, 10 Coins and two cosmetic preferences survived a new lease; an independent store remained fresh.")
end
