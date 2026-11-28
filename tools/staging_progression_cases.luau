-- Disposable compatibility fixture, shared by the native staging probe and Luau tests.
local Cases = {}

local reedguard = "reedguard-kangaroo"
local penguin = "penguin-brawler"

function Cases.seed(store, userId, now)
    assert(store:UpdateAsync("player_" .. userId, function(prior)
        if prior ~= nil then return nil end
        return {
            schemaVersion = 1,
            selectedStarterFighter = reedguard,
            relayBestTenths = 222,
            trophies = {["world-04"] = {earnedAt = now, criterionVersion = 1}},
            fighters = {[reedguard] = {xp = 830}, [penguin] = {xp = 0}},
            dojoWallet = {spent = 50, marketSashEquipped = true},
        }
    end), "Disposable legacy record already exists")
end

function Cases.migrate(profiles, userId, token)
    local profile = assert(profiles:open(userId, token))
    assert(profile.levelCurveUpdated and profile.fighters[reedguard].levelCurveCredit == 2020)
    assert(profiles:commitFighterSwitch(userId, token, penguin))
    assert(profiles:commitDojoWallet(userId, token, {
        kind = "fighterCosmetic", fighterId = penguin, slot = "hands",
        itemId = "penguin-glacier-mitts", equipped = true,
    }))
    assert(profiles:release(userId, token))
end

function Cases.rejoin(profiles, PlayerProfiles, RingProgression, userId, token)
    local profile = assert(profiles:open(userId, token))
    assert(PlayerProfiles.activeFighter(profile) == penguin)
    local progress = PlayerProfiles.summary(profile, penguin)
    assert(progress.highestFighterLevel == 7 and progress.level == 1 and progress.xp == 0)
    assert(PlayerProfiles.summary(profile, reedguard).xp == 2850)
    assert(progress.relayBest == 22.2 and progress.lanternKeeper)
    for _, ring in {"cloud-top", "galleon"} do
        assert(RingProgression.access(progress.highestFighterLevel, progress.level, ring))
    end
    local wallet = PlayerProfiles.wallet(profile)
    assert(wallet.marketSashOwned and wallet.marketSashEquipped and wallet.coins == 10)
    assert(profile.fighterCosmetics[penguin].hands == "penguin-glacier-mitts")
    assert(profiles:release(userId, token))
end

return Cases
