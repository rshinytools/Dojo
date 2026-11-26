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
