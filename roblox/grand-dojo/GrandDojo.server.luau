-- Grand Dojo City. Cloud profiles are isolated from local Studio playtests.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local PlayerProfiles = require(script.Parent:WaitForChild("PlayerProfiles"))
local StarterFighters = require(script.Parent:WaitForChild("StarterFighters"))
local RingProgression = require(ReplicatedStorage:WaitForChild("RingProgression"))
local starterChoice = ReplicatedStorage:WaitForChild("StarterFighterChoice")
local sparringWon = script.Parent:WaitForChild("SparringWon")
local trainingCompleted = script.Parent:WaitForChild("RingTrainingCompleted")

local studio = RunService:IsStudio()
local store = if studio then PlayerProfiles.memoryStore() else DataStoreService:GetDataStore("BeastDojoPlayerProfiles")
local profiles = PlayerProfiles.new(store, os.time, task.wait)
local shuttingDown = false
local profileWorkers = 0

local city = workspace:WaitForChild("Grand Dojo City")
local switchStation = city:FindFirstChild("Fighter Select Station")
local switchPrompt = switchStation and switchStation:FindFirstChild("SwitchFighterPrompt")
local relay = city:WaitForChild("Lantern Relay")
local board = relay:WaitForChild("EventBoard")
local hall = city:WaitForChild("Trophy Hall"):WaitForChild("HallPrompt")
local remote = ReplicatedStorage:WaitForChild("GrandDojoAction")
local sparRemote = ReplicatedStorage:WaitForChild("GrandDojoSparring")
local terrain = workspace.Terrain
terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(123, 133, 84))
terrain:SetMaterialColor(Enum.Material.Rock, Color3.fromRGB(112, 103, 118))
terrain:FillBlock(CFrame.new(0, -18, -107), Vector3.new(647, 26, 625), Enum.Material.Grass)
local valley = city["Valley skyline"]

local function sculptFoothill(profile)
    local resolution = 4
    local center = profile.Position
    local radius = profile.Size / 2
    local region = Region3.new(
        Vector3.new(center.X - radius.X, -12, center.Z - radius.Z),
        Vector3.new(center.X + radius.X, center.Y + radius.Y + 4, center.Z + radius.Z)
    ):ExpandToGrid(resolution)
    local lower = region.CFrame.Position - region.Size / 2
    local xCount, yCount, zCount = region.Size.X / resolution, region.Size.Y / resolution, region.Size.Z / resolution
    local materials, occupancy = {}, {}
    for x = 1, xCount do
        materials[x], occupancy[x] = {}, {}
        local u = (lower.X + (x - .5) * resolution - center.X) / radius.X
        for y = 1, yCount do
            materials[x][y], occupancy[x][y] = {}, {}
            local bottom = lower.Y + (y - 1) * resolution
            for z = 1, zCount do
                local v = (lower.Z + (z - .5) * resolution - center.Z) / radius.Z
                local slope = math.max(0, 1 - math.sqrt(u*u + v*v))
                local irregularity = 1 + .11 * math.cos(v*7 + 2*u) - .09 * math.sin(u*9)
                local relief = profile.Size.Y * slope^1.12 * irregularity
                local height = -5 + relief
                local filled = math.clamp((height - bottom) / resolution, 0, 1)
                local surface = if relief < .6 then Enum.Material.Grass else profile.Material
                materials[x][y][z] = if filled == 0 then Enum.Material.Air
                    elseif height - bottom > resolution * 2 then Enum.Material.Rock
                    else surface
                occupancy[x][y][z] = filled
            end
        end
    end
    terrain:WriteVoxels(region, resolution, materials, occupancy)
end

for _, profile in valley["Foothill profiles"]:GetChildren() do
    sculptFoothill(profile)
end
local canal = city["Plaza & streets"]["Festival canal"]
for _, name in {"Canal", "Arrival cove", "Promenade inlet"} do
    local bounds = canal[name .. " water bounds"]
    terrain:FillBlock(bounds.CFrame, bounds.Size, Enum.Material.Water)
    canal[name .. " edit preview"].Transparency = 1
end
local roads = city["Connecting roads"]
local meltwaterApproaches = roads:FindFirstChild("Meltwater bridge approaches")
for _, road in roads:GetDescendants() do
    if road:IsA("BasePart") and road.Material == Enum.Material.Sandstone and road.Size.X >= 11
        and road.Parent ~= meltwaterApproaches then
        terrain:FillBlock(road.CFrame * CFrame.new(0, -13, 0),
            Vector3.new(road.Size.X + 23, 16, road.Size.Z + 4), Enum.Material.Rock)
    end
end
for _, district in city["Connected districts"]:GetChildren() do
    local shelf = district["District retaining shelf"]
    terrain:FillBlock(shelf.CFrame * CFrame.new(0, -6, 0),
        Vector3.new(shelf.Size.X + 15, shelf.Size.Y + 2, shelf.Size.Z + 15), Enum.Material.Rock)
end
for _, name in {"Skywalk creek", "Frostglass meltwater"} do
    local creek = valley[name]
    local creekBounds = creek["Creek water bounds"]
    terrain:FillBlock(creekBounds.CFrame, creekBounds.Size, Enum.Material.Water)
    creek["Creek edit preview"].Transparency = 1
end
local harbor = city["Connected districts"]["Tideharbor Coast"]
local shore = harbor["District retaining shelf"]
local seaCenter = shore.Position + Vector3.new(133, shore.Size.Y/2 - 3.9, -45)
terrain:FillBlock(CFrame.new(seaCenter - Vector3.new(0, 6, 0)), Vector3.new(216, 7, 256), Enum.Material.Sand)
terrain:FillBlock(CFrame.new(seaCenter), Vector3.new(216, 4.8, 256), Enum.Material.Water)
local offshore = harbor:FindFirstChild("Tideharbor offshore coast")
local swimBoundary = offshore and offshore:FindFirstChild("Harbor swim boundary")
if offshore then
    for _, volume in offshore["Native sea aprons"]:GetChildren() do
        terrain:FillBlock(volume.CFrame * CFrame.new(0, -6, 0), volume.Size + Vector3.new(0, 2.2, 0),
            Enum.Material.Sand)
        terrain:FillBlock(volume.CFrame, volume.Size, Enum.Material.Water)
    end
    local horizon = offshore:FindFirstChild("Horizon sea fills")
    if horizon then
        for _, volume in horizon:GetChildren() do
            terrain:FillBlock(volume.CFrame, volume.Size, Enum.Material.Water)
        end
    end
end

local tideShore = harbor:FindFirstChild("Clay Lantern tide shore")
if tideShore then
    local stations = HttpService:JSONDecode(tideShore["Coastline stations"].Value)
    local resolution = 4
    local west, east = 208, 272
    local north, south = stations[1][1], stations[#stations][1]
    local bottom = -12
    local bounds = Region3.new(Vector3.new(west, bottom, north), Vector3.new(east, 8, south))
    local data = terrain:ReadVoxelChannels(bounds, resolution,
        {"SolidMaterial", "SolidOccupancy", "LiquidOccupancy"})
    local seaLevel = seaCenter.Y + 2.4
    local segment = 1

    for zi = 1, data.Size.Z do
        local z = north + (zi - .5) * resolution
        while z > stations[segment + 1][1] do
            segment += 1
        end
        local a, b = stations[segment], stations[segment + 1]
        local t = (z - a[1]) / (b[1] - a[1])
        local shoreX = a[2] + (b[2] - a[2]) * t
        local bluff = a[3] + (b[3] - a[3]) * t
        local lengthBlend = math.min(1, (z - north) / 14, (south - z) / 14)

        for xi = 1, data.Size.X do
            local x = west + (xi - .5) * resolution
            local blend = lengthBlend * math.min(1, (x - west) / 16, (east - x) / 12)
            local inland = shoreX - x
            local seaward = math.clamp((x - 212) / 24, 0, 1)
            local undulation = math.cos((x - west) * .23 + (z - north) * .18) * .24
            local crest = math.max(.38, bluff * (.33 + .43 * seaward) + undulation)
            local height = seaLevel + math.clamp(inland * .32, -5.35, crest)
            local surface = if inland <= 4 then Enum.Material.Sand
                elseif bluff > 2.9 and inland < 13 then Enum.Material.Rock
                else Enum.Material.Grass

            for yi = 1, data.Size.Y do
                local floor = bottom + (yi - 1) * resolution
                local oldSolid = data.SolidOccupancy[xi][yi][zi]
                local oldLiquid = data.LiquidOccupancy[xi][yi][zi]
                local solid = math.clamp((height - floor) / resolution, 0, 1)
                local liquid = math.clamp((seaLevel - floor) / resolution - solid, 0, 1 - solid)
                local mergedSolid = oldSolid + (solid - oldSolid) * blend
                data.SolidOccupancy[xi][yi][zi] = mergedSolid
                data.LiquidOccupancy[xi][yi][zi] = math.min(1 - mergedSolid, oldLiquid + (liquid - oldLiquid) * blend)
                if mergedSolid < .004 then
                    data.SolidMaterial[xi][yi][zi] = Enum.Material.Air
                elseif blend >= .5 or oldSolid < .004 then
                    data.SolidMaterial[xi][yi][zi] = if height - floor > 7 then Enum.Material.Rock else surface
                end
            end
        end
    end
    terrain:WriteVoxelChannels(bounds, resolution, {
        SolidMaterial = data.SolidMaterial,
        SolidOccupancy = data.SolidOccupancy,
        LiquidOccupancy = data.LiquidOccupancy,
    })
end

local gates = relay:WaitForChild("Checkpoints"):GetChildren()
table.sort(gates, function(a, b)
    return tonumber(a.Name) < tonumber(b.Name)
end)

local RUN_LIMIT = 120
local state = {}

local function liveRoot(player)
    if player:GetAttribute("StarterSelectionRequired") ~= false or player:GetAttribute("StarterSelectionPending") then
        return nil
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function near(player, part, radius)
    local root = liveRoot(player)
    return root and (root.Position - part.Position).Magnitude <= radius
end

local pier = harbor["Harbor pier"]
local waterReturn = pier.WaterReturn
waterReturn.ReturnPrompt.Triggered:Connect(function(player)
    local root = liveRoot(player)
    if root and root.Position.Y < waterReturn.Position.Y + 1.5 and near(player, waterReturn, 13) then
        player.Character:PivotTo(pier.PierLanding.CFrame)
    end
end)

local function returnFromOuterHarbor(player, root)
    if not swimBoundary or not root or root.Position.Y > 3.2 then
        return
    end
    local offset = root.Position - swimBoundary.Position
    local half = swimBoundary.Size / 2
    if offset.X < -half.X or (offset.X <= half.X and math.abs(offset.Z) <= half.Z) then
        return
    end
    player.Character:PivotTo(pier.PierLanding.CFrame)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    remote:FireClient(player, "notice", "The harbor current brought you back to Tideharbor pier.")
end

for _, resident in city["City residents"]:GetChildren() do
    local anchor = resident.GreetingAnchor
    anchor.Talk.Triggered:Connect(function(player)
        if near(player, anchor, 10) then
            remote:FireClient(player, "notice", resident.Greeting.Value)
        end
    end)
end

local function resetRun(player, data)
    data.run = nil
    player:SetAttribute("RelayDeadline", 0)
    player:SetAttribute("RelayNextGate", 0)
end

local function projectProgress(player, data, profile)
    local progress = PlayerProfiles.summary(profile, PlayerProfiles.activeFighter(profile))
    player:SetAttribute("FirstSparWinComplete", progress.firstSparWinComplete)
    player:SetAttribute("LanternKeeper", progress.lanternKeeper)
    player:SetAttribute("RelayBest", progress.relayBest)
    player:SetAttribute("FighterXp", progress.xp)
    player:SetAttribute("FighterLevel", progress.level)
    player:SetAttribute("HighestFighterLevel", progress.highestFighterLevel)
    player:SetAttribute("FighterRosterLevels", HttpService:JSONEncode(progress.fighterLevels))
    local goal = (progress.nextLevelXp or progress.levelFloor) - progress.levelFloor
    local earned = math.clamp(progress.xp - progress.levelFloor, 0, goal)
    player:SetAttribute("FighterHudProgress", string.format("%d:%d:%d", progress.level, earned, goal))
end

local function pendingProgress(data)
    return data.pendingStarterChoice or data.pendingRelay or data.pendingSparWin or data.pendingTraining
end

local function syncStarterAvatar(player, data, character)
    if data.departed or character ~= player.Character then
        return
    end
    if not data.selectedStarter or data.pendingStarterChoice then
        StarterFighters.hold(character)
    end
    if not data.selectedStarter then
        return
    end
    if not StarterFighters.equip(character, data.selectedStarter) then
        player:SetAttribute("StarterSelectionError", "Your starter choice was saved, but its appearance could not load.")
        warn("[Grand Dojo] Starter shell could not mount for", data.selectedStarter)
    end
    if not data.pendingStarterChoice then
        StarterFighters.release(character)
    end
end

local function projectStarterChoice(player, data, profile)
    local selected = PlayerProfiles.activeFighter(profile)
    local pending = data.pendingStarterChoice
    local alreadySaved = pending and (selected == pending.id or (pending.first and selected ~= nil))
    data.selectedStarter = selected
    if not pending or alreadySaved then
        data.pendingStarterChoice = nil
        player:SetAttribute("StarterSelectionError", nil)
        player:SetAttribute("StarterSelectionPending", false)
        if alreadySaved then
            player:SetAttribute("FighterSelectOpen", false)
        end
    end
    if player.Character then
        syncStarterAvatar(player, data, player.Character)
    end
    player:SetAttribute("InitialStarterFighter", profile.selectedStarterFighter)
    player:SetAttribute("SelectedStarterFighter", selected)
    player:SetAttribute("StarterSelectionRequired", selected == nil)
end

local function saveStarterChoice(player, data, token)
    local pending = data.pendingStarterChoice
    local profile = if pending.first then profiles:commitStarterChoice(player.UserId, token, pending.id)
        else profiles:commitFighterSwitch(player.UserId, token, pending.id)
    if not profile then
        return nil
    end
    if not (data.departed or shuttingDown) then
        projectStarterChoice(player, data, profile)
        projectProgress(player, data, profile)
        player:SetAttribute("ProgressStatus", if pendingProgress(data) then "saving" else "saved")
    end
    return profile
end

local function saveRelay(player, data, token)
    local pending = data.pendingRelay
    local profile, _, first, xp = profiles:commitRelay(player.UserId, token, pending.tenths, pending.id, pending.fighterId)
    if not profile then
        return nil
    end
    data.pendingRelay = nil
    if not (data.departed or shuttingDown) then
        projectProgress(player, data, profile)
        player:SetAttribute("ProgressStatus", if pendingProgress(data) then "saving" else "saved")
        if data.run then
            local message = if first then string.format("Lantern Keeper saved · +%d XP", xp)
                else string.format("Official Relay saved · +%d XP", xp)
            remote:FireClient(player, "notice", message)
        else
            remote:FireClient(player, "finished", pending.tenths / 10, first, false, xp)
        end
        print(string.format("[Grand Dojo] %s saved an official Relay in %.1fs. First trophy: %s",
            player.Name, pending.tenths / 10, tostring(first)))
    end
    return profile
end

local function saveSparWin(player, data, token)
    local pending = data.pendingSparWin
    local profile, _, first, xp = profiles:commitSparWin(player.UserId, token, pending.id, pending.fighterId)
    if not profile then
        return nil
    end
    data.pendingSparWin = nil
    if not (data.departed or shuttingDown) then
        projectProgress(player, data, profile)
        player:SetAttribute("FirstSparWinPending", nil)
        player:SetAttribute("ProgressStatus", if pendingProgress(data) then "saving" else "saved")
        sparRemote:FireClient(player, "reward", xp, first)
    end
    return profile
end

local function saveTraining(player, data, token)
    local pending = data.pendingTraining
    local drill = RingProgression.Drills[pending.drillId]
    local profile = profiles:commitRingTraining(player.UserId, token, pending.drillId, pending.id, pending.fighterId, drill.xp)
    if not profile then
        return nil
    end
    data.pendingTraining = nil
    if not (data.departed or shuttingDown) then
        projectProgress(player, data, profile)
        player:SetAttribute("RingTrainingPending", nil)
        player:SetAttribute("ProgressStatus", if pendingProgress(data) then "saving" else "saved")
        remote:FireClient(player, "notice", string.format("%s complete · +%d XP", drill.name, drill.xp))
    end
    return profile
end

local function serveProgress(player, data)
    local token = HttpService:GenerateGUID(false)
    local attempted = false
    local nextRefresh, nextLoad = 0, 0
    while not (data.departed or shuttingDown) do
        local now = os.clock()
        if data.profile == nil and now >= nextLoad then
            attempted = true
            data.profile = profiles:open(player.UserId, token)
            if data.departed or shuttingDown then
                break
            elseif data.profile then
                projectProgress(player, data, data.profile)
                projectStarterChoice(player, data, data.profile)
                player:SetAttribute("ProgressStatus", if pendingProgress(data) then "saving" else "ready")
                nextRefresh = os.clock() + math.random(38, 54)
            else
                player:SetAttribute("ProgressStatus", "unavailable")
                if not (data.selectedStarter or data.pendingStarterChoice) then
                    player:SetAttribute("StarterSelectionError", "Your profile is still loading. We'll retry while you're here.")
                end
                nextLoad = os.clock() + math.random(8, 12)
            end
        end
        if data.profile and (pendingProgress(data) or now >= nextRefresh) then
            if data.pendingStarterChoice then
                data.profile = saveStarterChoice(player, data, token)
            elseif data.pendingRelay then
                data.profile = saveRelay(player, data, token)
            elseif data.pendingSparWin then
                data.profile = saveSparWin(player, data, token)
            elseif data.pendingTraining then
                data.profile = saveTraining(player, data, token)
            else
                data.profile = profiles:renew(player.UserId, token)
            end
            nextRefresh = os.clock() + math.random(38, 54)
            if not data.profile and not (data.departed or shuttingDown) then
                player:SetAttribute("ProgressStatus", "unavailable")
                nextLoad = os.clock() + math.random(8, 12)
                if data.pendingStarterChoice then
                    player:SetAttribute("StarterSelectionError", "Your starter choice is still saving. We'll retry while you're here.")
                elseif data.pendingRelay then
                    remote:FireClient(player, "notice", "Your Relay result is pending. We'll retry while you're here.")
                elseif data.pendingSparWin then
                    sparRemote:FireClient(player, "rewardPending", "Your spar XP is pending. We'll retry while you're here.")
                elseif data.pendingTraining then
                    remote:FireClient(player, "notice", "Your training XP is pending. We'll retry while you're here.")
                end
            end
        end
        task.wait(.4)
    end
    if pendingProgress(data) and not data.profile then
        attempted = true
        data.profile = profiles:open(player.UserId, token)
    end
    if data.profile then
        if data.pendingStarterChoice then
            saveStarterChoice(player, data, token)
        end
        if data.pendingRelay then
            saveRelay(player, data, token)
        end
        if data.pendingSparWin then
            saveSparWin(player, data, token)
        end
        if data.pendingTraining then
            saveTraining(player, data, token)
        end
    end
    if attempted then
        profiles:release(player.UserId, token)
    end
    profileWorkers -= 1
end

sparringWon.Event:Connect(function(player, fighterId)
    local data = state[player]
    if data and fighterId and fighterId == data.selectedStarter
        and not (data.departed or shuttingDown or data.pendingSparWin) then
        data.pendingSparWin = {id = HttpService:GenerateGUID(false), fighterId = fighterId}
        player:SetAttribute("FirstSparWinPending", true)
        player:SetAttribute("ProgressStatus", "saving")
    end
end)

trainingCompleted.Event:Connect(function(player, drillId, fighterId)
    local data = state[player]
    if not data or data.departed or shuttingDown or not RingProgression.Drills[drillId]
        or not fighterId or fighterId ~= data.selectedStarter then
        player:SetAttribute("RingTrainingPending", nil)
        return
    end
    if not data.pendingTraining then
        data.pendingTraining = {id = HttpService:GenerateGUID(false), drillId = drillId, fighterId = fighterId}
        player:SetAttribute("ProgressStatus", "saving")
    end
end)

local function activeActivity(player, data)
    return data.run or player:GetAttribute("SparringActive") or player:GetAttribute("SkywalkTrialMode")
        or player:GetAttribute("RingTrainingActive") or player:GetAttribute("RingTrainingPending")
        or player:GetAttribute("DuelQueued")
        or (player:GetAttribute("ParcelStage") or 0) > 0
end

local function atFighterSelect(player)
    return switchPrompt and switchPrompt.Enabled and near(player, switchStation, switchPrompt.MaxActivationDistance)
end

if switchPrompt then
    switchPrompt.Triggered:Connect(function(player)
        local data = state[player]
        if not data or shuttingDown or not data.selectedStarter or data.pendingStarterChoice
            or not atFighterSelect(player) then
            return
        end
        if activeActivity(player, data) then
            remote:FireClient(player, "notice", "Finish your current activity before switching fighters.")
        elseif not data.profile or pendingProgress(data) then
            remote:FireClient(player, "notice", "Fighter Select opens after your progress finishes saving.")
        else
            player:SetAttribute("StarterSelectionError", nil)
            player:SetAttribute("FighterSelectOpen", true)
        end
    end)
end

starterChoice.OnServerEvent:Connect(function(player, request, requestedFighter)
    local data = state[player]
    if not data or data.departed or shuttingDown or data.pendingStarterChoice then
        return
    end
    if request == "close" then
        player:SetAttribute("FighterSelectOpen", false)
        return
    end
    local switching = request == "switch"
    local fighterId = if switching then requestedFighter else request
    if not StarterFighters.isChoice(fighterId) or switching ~= (data.selectedStarter ~= nil) then
        return
    end
    if switching and (not player:GetAttribute("FighterSelectOpen") or not atFighterSelect(player)
        or activeActivity(player, data)) then
        remote:FireClient(player, "notice", "Stand beside Fighter Select between activities.")
        player:SetAttribute("FighterSelectOpen", false)
        return
    end
    if fighterId == data.selectedStarter then
        player:SetAttribute("FighterSelectOpen", false)
        return
    end
    if not data.profile or pendingProgress(data) then
        player:SetAttribute("StarterSelectionError", "Your fighter profile is still loading or saving. Try again shortly.")
        return
    end
    if not StarterFighters.canEquip(player.Character, fighterId) then
        player:SetAttribute("StarterSelectionError", "This fighter's appearance could not load. Choose another fighter.")
        return
    end
    data.pendingStarterChoice = {id = fighterId, first = not switching}
    player:SetAttribute("StarterSelectionError", nil)
    player:SetAttribute("StarterSelectionPending", true)
    player:SetAttribute("ProgressStatus", "saving")
    StarterFighters.hold(player.Character)
end)

local function addPlayer(player)
    if state[player] then
        return
    end
    local data = {openUntil = 0, lastAction = 0, lastStrike = 0, targetStrikes = {}, nextChime = 1, lastChime = -math.huge}
    state[player] = data
    player:SetAttribute("LanternKeeper", false)
    player:SetAttribute("RelayBest", 0)
    player:SetAttribute("FighterXp", 0)
    player:SetAttribute("FighterLevel", 1)
    player:SetAttribute("ProgressMode", if studio then "studio" else "cloud")
    player:SetAttribute("ProgressStatus", "loading")
    player:SetAttribute("StarterSelectionPending", false)
    player:SetAttribute("FighterSelectOpen", false)
    player:SetAttribute("ParcelStage", 0)
    player:SetAttribute("HarborDeliveries", 0)
    player:SetAttribute("WindChimeCompletions", 0)
    resetRun(player, data)
    player.CharacterAdded:Connect(function(character)
        player:SetAttribute("FighterSelectOpen", false)
        syncStarterAvatar(player, data, character)
        table.clear(data.targetStrikes)
        data.openUntil = 0
        data.nextChime = 1
        if data.run then
            resetRun(player, data)
            remote:FireClient(player, "notice", "Relay ended. Return to the event board to try again.")
        end
    end)
    if player.Character then
        syncStarterAvatar(player, data, player.Character)
    end
    profileWorkers += 1
    task.spawn(serveProgress, player, data)
end

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(function(player)
    local data = state[player]
    if data then
        data.departed = true
    end
    state[player] = nil
end)
for _, player in Players:GetPlayers() do
    addPlayer(player)
end
game:BindToClose(function()
    shuttingDown = true
    local limit = os.clock() + 25
    while profileWorkers > 0 and os.clock() < limit do
        task.wait(.1)
    end
end)

local streets = city["City streets"]
local parcelStops = {
    streets["Parcel Dispatch"].Interaction,
    streets["Weavers’ Walk"]["Parcel Stamp Desk"].Interaction,
    harbor["Parcel Receiving"].Interaction,
}
local parcelDirections = {
    "Pick up a parcel at the dispatch desk in Reed Market.",
    "Take the parcel up Weavers’ Walk and stamp it at the workshop.",
    "Take the east ramp to the Tideharbor road. Deliver the parcel in the harbor square.",
}

for index, anchor in parcelStops do
    anchor.ParcelPrompt.Triggered:Connect(function(player)
        if not state[player] or not near(player, anchor, 9) then
            return
        end
        local stage = player:GetAttribute("ParcelStage")
        if stage ~= index - 1 then
            remote:FireClient(player, "notice", parcelDirections[stage + 1])
            return
        end

        local nextStage = index % #parcelStops
        player:SetAttribute("ParcelStage", nextStage)
        if nextStage == 0 then
            local deliveries = player:GetAttribute("HarborDeliveries") + 1
            player:SetAttribute("HarborDeliveries", deliveries)
            remote:FireClient(player, "notice", string.format("Parcel delivered. Deliveries this session: %d.", deliveries))
        else
            remote:FireClient(player, "notice", parcelDirections[nextStage + 1])
        end
    end)
end

local chimes = city["Connected districts"]["Skywalk Peaks"]["Wind Court"]["Wind chimes"]
local chimeOrder = {"Reed", "Cloud", "Summit"}
for index, name in chimeOrder do
    local anchor = chimes[name]
    anchor.ChimePrompt.Triggered:Connect(function(player)
        local data = state[player]
        local now = workspace:GetServerTimeNow()
        if not data or now - data.lastChime < .25 or not near(player, anchor, 6.5) then
            return
        end
        data.lastChime = now
        if not anchor.Note.IsPlaying then
            anchor.Note:Play()
        end

        if index ~= data.nextChime then
            data.nextChime = if index == 1 then 2 else 1
            remote:FireClient(player, "notice", "Sequence restarted. Ring " .. chimeOrder[data.nextChime] .. " next.")
        elseif index == #chimeOrder then
            data.nextChime = 1
            local count = player:GetAttribute("WindChimeCompletions") + 1
            player:SetAttribute("WindChimeCompletions", count)
            remote:FireClient(player, "notice", string.format("Wind Court melody complete. Melodies this session: %d.", count))
        else
            data.nextChime += 1
            remote:FireClient(player, "notice", "Ring " .. chimeOrder[data.nextChime] .. " next.")
        end
    end)
end

local function bindEventBoard(anchor, startsRelay)
    local prompt = anchor:FindFirstChild("BoardPrompt")
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return
    end
    local radius = if startsRelay then 14 else prompt.MaxActivationDistance + 1
    prompt.Triggered:Connect(function(player)
        local data = state[player]
        if data and not (shuttingDown or activeActivity(player, data) or player:GetAttribute("FighterSelectOpen"))
            and prompt.Enabled and near(player, anchor, radius) then
            data.openUntil = if startsRelay then workspace:GetServerTimeNow() + 40 else 0
            remote:FireClient(player, "panel", if startsRelay then "relay" else "relayInfo")
        end
    end)
end

bindEventBoard(board, true)
local plaza = city:FindFirstChild("Plaza & streets")
local festival = plaza and plaza:FindFirstChild("Arrival Festival Board")
local arrivalBoard = festival and festival:FindFirstChild("EventBoard")
if arrivalBoard then
    bindEventBoard(arrivalBoard, false)
end

hall.TrophyPrompt.Triggered:Connect(function(player)
    if state[player] and near(player, hall, 11) then
        remote:FireClient(player, "panel", "trophy")
    end
end)

local function bindPracticeTarget(target)
    target.PracticePrompt.Triggered:Connect(function(player)
        local data = state[player]
        local now = workspace:GetServerTimeNow()
        if shuttingDown or not data or data.run or player:GetAttribute("SparringActive")
            or now - data.lastStrike < .45 or not near(player, target, 8) then
            return
        end
        data.lastStrike = now
        local hits = (data.targetStrikes[target] or 0) + 1
        if hits == 3 then
            data.targetStrikes[target] = nil
            remote:FireClient(player, "strike", "Practice set complete!", target.Parent)
        else
            data.targetStrikes[target] = hits
            remote:FireClient(player, "strike", string.format("Target hit  %d / 3", hits), target.Parent)
        end
    end)
end

local tideharbor = city["Connected districts"]:FindFirstChild("Tideharbor Coast")
local galleon = tideharbor and tideharbor:FindFirstChild("Sunken Pirate Galleon")
local galleonPractice = galleon and galleon:FindFirstChild("Practice Target")
local galleonTarget = galleonPractice and galleonPractice:FindFirstChild("TargetPrompt")
if galleonTarget then
    bindPracticeTarget(galleonTarget)
end

remote.OnServerEvent:Connect(function(player, action)
    local data = state[player]
    local now = workspace:GetServerTimeNow()
    if shuttingDown or not data or typeof(action) ~= "string" or now - data.lastAction < .3 then
        return
    end
    data.lastAction = now

    if action == "cancel" and data.run then
        resetRun(player, data)
        remote:FireClient(player, "notice", "Relay cancelled. You can try again at the event board.")
        return
    end

    if (action ~= "start" and action ~= "practice") or activeActivity(player, data)
        or player:GetAttribute("FighterSelectOpen") or player:GetAttribute("StarterSelectionPending") then
        return
    end
    if now > data.openUntil or not near(player, board, 14) then
        remote:FireClient(player, "notice", "Stand beside the event board and open it again.")
        return
    end
    if action == "start" and (not data.profile or data.pendingRelay) then
        local message = if data.pendingRelay then "Your previous Relay result is still saving."
            else "Progress is unavailable. You can still run the practice route."
        remote:FireClient(player, "notice", message)
        return
    end
    data.openUntil = 0
    data.run = {started = now, nextGate = 1, practice = action == "practice", fighterId = data.selectedStarter}
    player:SetAttribute("RelayNextGate", 1)
    player:SetAttribute("RelayDeadline", now + RUN_LIMIT)
    remote:FireClient(player, "started", data.run.practice)
end)

local function finish(player, data, now)
    local run = data.run
    local tenths = math.max(1, math.round((now - run.started) * 10))
    resetRun(player, data)
    if run.practice then
        remote:FireClient(player, "finished", tenths / 10, false, true)
    else
        data.pendingRelay = {tenths = tenths, id = HttpService:GenerateGUID(false), fighterId = run.fighterId}
        player:SetAttribute("ProgressStatus", "saving")
        remote:FireClient(player, "notice", "Saving your Relay result…")
    end
end

local accumulated = 0
RunService.Heartbeat:Connect(function(dt)
    if shuttingDown then
        return
    end
    accumulated += dt
    if accumulated < .075 then
        return
    end
    accumulated = 0
    local now = workspace:GetServerTimeNow()
    for player, data in state do
        if not data.pendingStarterChoice and player:GetAttribute("FighterSelectOpen")
            and (not atFighterSelect(player) or activeActivity(player, data)) then
            player:SetAttribute("FighterSelectOpen", false)
        end
        local root = liveRoot(player)
        returnFromOuterHarbor(player, root)
        local run = data.run
        if not run then
            continue
        end
        if not root or now - run.started >= RUN_LIMIT then
            resetRun(player, data)
            remote:FireClient(player, "notice", "Relay ended. Try again at the event board.")
            continue
        end
        local zone = gates[run.nextGate]
        local offset = zone.CFrame:PointToObjectSpace(root.Position)
        local half = zone.Size / 2
        if math.abs(offset.X) <= half.X and math.abs(offset.Y) <= half.Y and math.abs(offset.Z) <= half.Z then
            if run.nextGate == #gates then
                finish(player, data, now)
            else
                run.nextGate += 1
                player:SetAttribute("RelayNextGate", run.nextGate)
            end
        end
    end
end)

print("[Grand Dojo] City, Lantern Relay, harbor parcels and Wind Court chimes ready.")
