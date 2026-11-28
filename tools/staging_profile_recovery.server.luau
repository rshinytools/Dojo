-- Install only in a temporary, private staging test place. See IMPLEMENTATION.md.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local universeId = script:GetAttribute("StagingUniverseId")
local placeId = script:GetAttribute("RecoveryPlaceId")
local testerId = script:GetAttribute("TesterUserId")
local runId = script:GetAttribute("RecoveryRunId")
local phase = script:GetAttribute("RecoveryPhase")

if RunService:IsStudio() or game.JobId == "" or type(universeId) ~= "number" or universeId <= 0
    or type(placeId) ~= "number" or placeId <= 0 or game.GameId ~= universeId or game.PlaceId ~= placeId
    or type(testerId) ~= "number" or testerId <= 0 or testerId % 1 ~= 0
    or type(runId) ~= "string" or #runId > 28 or not runId:match("^[a-z0-9%-]+$")
    or (phase ~= "interrupt" and phase ~= "replay") then
    return
end

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local PlayerProfiles = require(script.Parent:WaitForChild("PlayerProfiles"))
local StageCases = require(script.Parent:WaitForChild("StagingProgressionCases"))
local RingProgression = require(game:GetService("ReplicatedStorage"):WaitForChild("RingProgression"))
local fighterId = "reedguard-kangaroo"

local function verify(tester)
    local store = DataStoreService:GetDataStore("BeastDojoStagingRecovery", "qa-" .. runId)
    local compatibilityStore = DataStoreService:GetDataStore("BeastDojoStagingRecovery", "legacy-" .. runId)
    local compatibility = PlayerProfiles.new(compatibilityStore, os.time, task.wait)
    local token = HttpService:GenerateGUID(false)
    local mode, faultCount = nil, 0
    local adapter = {}
    function adapter:UpdateAsync(key, transform)
        if mode == "before" then
            faultCount += 1
            error("Injected interruption before UpdateAsync")
        end
        local saved = store:UpdateAsync(key, transform)
        if mode == "reply" then
            assert(saved, "Native UpdateAsync did not return a committed write")
            faultCount += 1
            error("Injected lost reply after UpdateAsync")
        end
        return saved
    end

    -- Expire only the disposable profile's old lease for the second server.
    -- This exercises takeover without waiting for the production lease timeout.
    local function now()
        return os.time() - (if phase == "interrupt" then 180 else 0)
    end
    local profiles = PlayerProfiles.new(adapter, now, task.wait)
    local function expectProfile(profile, xp, best)
        assert(profile, "Expected a committed profile")
        assert(profile.selectedStarterFighter == fighterId, "Starter choice changed")
        local summary = PlayerProfiles.summary(profile, fighterId)
        assert(summary.xp == xp and summary.relayBest == best and summary.lanternKeeper,
            "Unexpected XP, Relay best, or Lantern Keeper state")
    end

    if phase == "interrupt" then
        local claimed = store:UpdateAsync("run", function(previous)
            if previous ~= nil then return nil end
            return {job = game.JobId, owner = tester.UserId, token = token, state = "started"}
        end)
        assert(claimed, "Recovery run ID already exists")
        assert(profiles:open(tester.UserId, token))
        assert(profiles:commitStarterChoice(tester.UserId, token, fighterId))
        expectProfile(profiles:commitRelay(tester.UserId, token, 222, "baseline", fighterId), 80, 22.2)
        mode = "before"
        local result, reason = profiles:commitRelay(tester.UserId, token, 170, "interrupted", fighterId)
        assert(result == nil and reason == "unavailable" and faultCount == 3,
            "Expected all three write attempts to be interrupted")
        StageCases.seed(compatibilityStore, tester.UserId, os.time())
        StageCases.migrate(compatibility, tester.UserId, token)
        claimed.state = "interrupted"
        store:SetAsync("run", claimed)
    else
        local claimed = store:UpdateAsync("run", function(previous)
            if not previous or previous.state ~= "interrupted" or previous.job == game.JobId
                or previous.owner ~= tester.UserId then
                return nil
            end
            previous.state = "replaying"
            return previous
        end)
        assert(claimed, "Run the interruption phase first in a different server with the same tester and run ID")
        expectProfile(profiles:open(tester.UserId, token), 80, 22.2)
        local stale, staleReason = profiles:commitRelay(tester.UserId, claimed.token, 160, "stale", fighterId)
        assert(stale == nil and staleReason == "ownership", "Previous server's lease can still grant XP")
        mode = "reply"
        local result, reason = profiles:commitRelay(tester.UserId, token, 165, "retry", fighterId)
        assert(result == nil and reason == "unavailable" and faultCount == 3,
            "Expected three lost replies after committed UpdateAsync calls")
        mode = nil
        expectProfile(profiles:commitRelay(tester.UserId, token, 165, "retry", fighterId), 105, 16.5)
        assert(profiles:release(tester.UserId, token))
        local readback = HttpService:GenerateGUID(false)
        expectProfile(profiles:open(tester.UserId, readback), 105, 16.5)
        assert(profiles:release(tester.UserId, readback))
        StageCases.rejoin(compatibility, PlayerProfiles, RingProgression, tester.UserId, readback)
        claimed.state = "passed"
        claimed.replayJob = game.JobId
        store:SetAsync("run", claimed)
    end
end

local started = false
local function run(tester)
    if started or tester.UserId ~= testerId then return end
    started = true
    local ok, detail = pcall(verify, tester)
    if ok then
        print("[Staging profile recovery] PASS", phase, runId, game.JobId)
    else
        warn("[Staging profile recovery] FAIL", phase, runId, game.JobId, detail)
    end
end

Players.PlayerAdded:Connect(run)
for _, tester in Players:GetPlayers() do
    task.spawn(run, tester)
end
