local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Catalog = require(script.Parent.CityAdventureCatalog)
local Progress = require(script.Parent.CityAdventureProgress)
local Match = require(script.Parent.DojoMatchSupport)

local Service = {}
local STUDS = 8
local SAMPLE_INTERVAL = .10
local TIMING_CYCLE, TIMING_WINDOW = 2.4, 1.04
local LIT, WAIT = Color3.fromRGB(130, 237, 201), Color3.fromRGB(209, 151, 95)

local function inReach(root, part, radius)
    return root and (root.Position - part.Position).Magnitude <= radius
end

local function at(spot)
    return if spot:IsA("BasePart") then spot else spot:WaitForChild("Interaction")
end

local function clue(spot, fallback)
    local value = spot:FindFirstChild("Clue")
    return if value and value:IsA("StringValue") and value.Value ~= "" then value.Value else fallback
end

local function lit(now, index)
    return (now + index * .41) % TIMING_CYCLE < TIMING_WINDOW
end

local function prompt(anchor, action, label, callback, key, gamepad)
    local trigger = Instance.new("ProximityPrompt")
    trigger.Name, trigger.ActionText, trigger.ObjectText = "CityAdventurePrompt", action, label
    trigger.MaxActivationDistance, trigger.RequiresLineOfSight = STUDS, false
    if key then
        trigger.KeyboardKeyCode, trigger.GamepadKeyCode = key, gamepad
    end
    trigger.Parent = anchor
    trigger.Triggered:Connect(function(player)
        local root = Match.root(player)
        if inReach(root, anchor, STUDS + 1) then callback(player, root) end
    end)
    return trigger
end

local function asGoal(position)
    return {x = position.X, y = position.Y, z = position.Z}
end

local function carryParcel(character)
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not torso then return nil end
    local parcel = Instance.new("Part")
    parcel.Name, parcel.Size = "City delivery parcel", Vector3.new(.84, .62, .43)
    parcel.Color, parcel.Material = Color3.fromRGB(232, 171, 94), Enum.Material.Wood
    parcel.CanCollide, parcel.CanTouch, parcel.CanQuery, parcel.CastShadow = false, false, false, false
    parcel.Massless, parcel.RootPriority = true, -127
    parcel.CFrame = torso.CFrame * CFrame.new(0, -.2, -1.02)
    parcel.Parent = character
    local weld = Instance.new("WeldConstraint")
    weld.Part0, weld.Part1, weld.Parent = torso, parcel, parcel
    return parcel
end

function Service.mount(folder, callbacks)
    local remote = ReplicatedStorage:WaitForChild("CityAdventure")
    local sessions, places, timingNodes = {}, {}, {}
    local cacheRandom = Random.new()
    local function session(player)
        if not sessions[player] then sessions[player] = {} end
        return sessions[player]
    end
    local function read(player)
        local world = Progress.world(callbacks.profile(player))
        for _, command in callbacks.pending(player) do
            world = Progress.apply(world, command)
        end
        return world
    end
    local function sendNotice(player, content)
        if player.Parent == Players then remote:FireClient(player, "notice", {message = content}) end
    end
    local function enqueue(player, command)
        command.at = math.floor(workspace:GetServerTimeNow())
        if not callbacks.queue(player, command) then
            sendNotice(player, "Your journal is waiting for progression. Try again in a moment.")
            return false
        end
        return true
    end
    local function objectives(world, chapter, district)
        if district.step == 3 then return "Chapter complete" end
        if not district.met then return "Meet the " .. chapter.mentor .. "." end
        if district.step == 0 then
            return chapter.survey .. string.format(" (%d/3)", Progress.count(district.surveys))
        end
        if district.step == 1 then
            local parts = {}
            for _, activity in chapter.activities do
                if not world.activities[activity[1]] then table.insert(parts, activity[2]) end
            end
            return "Complete " .. table.concat(parts, " and ") .. "."
        end
        return if district.trial then "Report back to the " .. chapter.mentor .. "." else chapter.trial
    end
    local function packet(player, now)
        local world, s = read(player), session(player)
        local chapters, totals = {}, Progress.totals(world)
        for index, chapter in Catalog.chapters do
            local place, district = places[chapter.id], world.districts[chapter.id] or {step = 0}
            local activities, clues = {}, {}
            for slot, named in chapter.activities do
                local best = world.activities[named[1]]
                activities[slot] = {id = named[1], name = named[2], completed = best ~= nil,
                    bestSeconds = best and best / 10}
            end
            for i, part in place.seals do
                local found = district.seals and district.seals[tostring(i)]
                clues[i] = if found then "Found" else clue(part, "Search near the district paths.")
            end
            chapters[index] = {id = chapter.id, name = chapter.name, mentor = chapter.mentor, chapter = chapter.chapter,
                step = district.step, story = chapter.story, objective = objectives(world, chapter, district),
                activities = activities, seals = {count = Progress.count(district.seals), total = 3, clues = clues},
                treasure = {found = district.cache == true, readyAt = Progress.cacheReadyAt(world, chapter.id),
                    clue = if Progress.count(district.seals) == 3
                    then clue(place.treasure, "The three seals point toward the district cache.") else "Find the three seals to reveal the cache clue."},
                canTravel = chapter.id == "valley" or district.step == 3}
        end
        local run, trail = s.run, nil
        if run then
            local nextIndex = run.order[run.next]
            local point = run.route.checkpoints[nextIndex]
            trail = {name = run.name, next = run.next, goal = asGoal(point.Position), deadline = run.deadline,
                total = #run.order, hint = if run.route.definition.kind == "timing" then "Use the marked lamp when it turns mint."
                    elseif run.route.definition.kind == "sequence" then "Activate signal " .. nextIndex .. "." else "Reach the next marker."}
        elseif world.tracked then
            local destination = places[world.tracked]
            local chapter = Catalog.byId[world.tracked]
            local district = world.districts[world.tracked] or {step = 0}
            local point = destination.mentor
            if district.met and district.step == 0 then
                for index, survey in destination.surveys do
                    if not (district.surveys and district.surveys[tostring(index)]) then point = survey break end
                end
            elseif district.step == 1 then
                point = destination.routes[if world.activities[chapter.activities[1][1]] then 2 else 1].start
            elseif district.step == 2 and not district.trial and world.tracked ~= "valley" then
                point = destination.routes[2].start
            end
            trail = {name = chapter.chapter, goal = asGoal(point.Position), hint = objectives(world, chapter, district)}
        end
        local window, endsAt, nextAt = Progress.festivalAt(now)
        local festival = if world.festival and world.festival.window == window then world.festival else nil
        local stampIds = {}
        if festival then
            for id in festival.stamps do
                table.insert(stampIds, if Catalog.activities[id] then Catalog.activities[id].name
                    elseif id == "relay" then "Lantern Relay" else "Cloudbreak Expert")
            end
            table.sort(stampIds)
        end
        return {districts = chapters, tracked = world.tracked, totals = totals, trail = trail,
            saving = #callbacks.pending(player) > 0, grandCache = world.grandCache == true,
            grandCacheReadyAt = Progress.cacheReadyAt(world, "grand"), graduated = world.graduated == true,
            cloudbreak = world.cloudbreak, festival = {active = now < endsAt, endsAt = endsAt, nextAt = nextAt,
                count = #stampIds, earned = festival ~= nil and festival.earned == true, stampIds = stampIds}}
    end
    local function publish(player, kind, tab, cache)
        if player.Parent == Players then
            local run = session(player).run
            local checkpoint = run and run.order[run.next]
            local interactive = run and (run.route.definition.kind == "timing" or run.route.definition.kind == "sequence")
            player:SetAttribute("CityAdventureCheckpoint", if interactive and checkpoint
                then run.route.definition.id .. "/" .. checkpoint else nil)
            local payload = packet(player, workspace:GetServerTimeNow())
            payload.openTab = tab
            payload.openCache = cache
            remote:FireClient(player, kind or "state", payload)
        end
    end
    local function cachePrompt(anchor, cacheId, label, missing)
        local trigger = prompt(anchor, "Open cache", label, function(player)
            if callbacks.blocked(player) then
                sendNotice(player, "Finish your current activity or wait for your progress to load, then try the cache again.")
                return
            end
            local world = read(player)
            local requirement = missing(world)
            if requirement then
                sendNotice(player, requirement)
                publish(player, "open", "treasures", cacheId)
                return
            end
            if workspace:GetServerTimeNow() < Progress.cacheReadyAt(world, cacheId) then
                sendNotice(player, label .. " is still open. Check Treasures for its reset time.")
                publish(player, "open", "treasures", cacheId)
                return
            end
            if enqueue(player, {kind = if cacheId == "grand" then "grand-cache" else "cache",
                district = if cacheId == "grand" then nil else cacheId, rewardXp = Progress.rollCacheXp(cacheRandom)}) then
                sendNotice(player, "Opening cache. Saving your treasure…")
                publish(player)
            end
        end)
        trigger:SetAttribute("CityCacheId", cacheId)
        CollectionService:AddTag(trigger, "CityAdventureCachePrompt")
    end
    local function stop(player, reason)
        local s = sessions[player]
        if not s or not s.run then return end
        local run = s.run
        s.run = nil
        if run.speed and run.humanoid.Parent and run.humanoid.WalkSpeed == run.speed then
            run.humanoid.WalkSpeed = run.normalSpeed
        end
        if run.parcel then run.parcel:Destroy() end
        player:SetAttribute("CityAdventureActive", nil)
        player:SetAttribute("CityAdventureCheckpoint", nil)
        if reason then
            sendNotice(player, reason)
            publish(player)
        end
    end
    local function complete(player, run, now)
        stop(player)
        local route = run.route
        local tenths = math.clamp(math.floor((now - run.startedAt) * 10 + .5), 1, 1200)
        local command = if run.mode == "trial" then {kind = "trial", district = route.definition.district}
            else {kind = "activity", district = route.definition.district, activity = route.definition.id,
                tenths = tenths, expert = run.mode == "expert"}
        if enqueue(player, command) then
            sendNotice(player, if run.mode == "trial" then "Trial complete. Report to the mentor."
                elseif route.definition.kind == "delivery" then string.format("Parcel delivered · %.1fs", tenths / 10)
                else string.format("%s complete · %.1fs", run.name, tenths / 10))
        end
        publish(player)
    end
    local function advance(player, run, index, now)
        if run.order[run.next] ~= index or now - run.lastAt < .16 then return false end
        run.next, run.lastAt = run.next + 1, now
        if run.next > #run.order then complete(player, run, now) else publish(player) end
        return true
    end
    local function start(player, root, route, mode)
        local s, profile = session(player), callbacks.profile(player)
        if s.run or not profile or callbacks.blocked(player) then
            sendNotice(player, "Finish your current activity and wait for progression before starting.")
            return
        end
        local district = read(player).districts[route.definition.district]
        if mode == "trial" and (not district or district.step ~= 2 or district.trial)
            or mode == "expert" and (not district or district.step ~= 3) then
            sendNotice(player, if mode == "expert" then "Finish the mentor chapter to unlock this route."
                else "Complete the two district activities before taking the mentor trial.")
            return
        end
        local kind, order = route.definition.kind, {}
        for i = 1, #route.checkpoints do order[i] = i end
        if kind == "sequence" then
            -- Every panel is reachable on the ground. The order changes for each attempt.
            for i = #order, 2, -1 do
                local slot = math.random(i)
                order[i], order[slot] = order[slot], order[i]
            end
        end
        local length, previous = 0, route.start.Position
        for _, index in order do
            local position = route.checkpoints[index].Position
            length, previous = length + (position - previous).Magnitude, position
        end
        local now = workspace:GetServerTimeNow()
        local isAdvanced = mode ~= "normal"
        local budget = math.clamp(length / (if isAdvanced then 9 else 5)
            + (if kind == "timing" or kind == "sequence" then #order * 3.3 else 4), if isAdvanced then 12 else 22, 110)
        local humanoid = root.Parent:FindFirstChildOfClass("Humanoid")
        local name = if mode == "trial" then "Mentor practice trial" elseif mode == "expert" then route.definition.name .. " · Expert"
            else route.definition.name
        local run = {route = route, order = order, next = 1, startedAt = now, deadline = now + budget,
            lastAt = now, name = name, mode = mode, root = root, humanoid = humanoid, lastPosition = root.Position,
            moveAt = now}
        if kind == "slide" then
            run.normalSpeed = humanoid.WalkSpeed
            run.speed = math.max(run.normalSpeed, 20)
            humanoid.WalkSpeed = run.speed
        elseif kind == "delivery" then
            run.parcel = carryParcel(root.Parent)
        end
        s.run = run
        player:SetAttribute("CityAdventureActive", true)
        sendNotice(player, name .. " started.")
        publish(player)
    end
    for _, chapter in Catalog.chapters do
        local district = folder:WaitForChild(chapter.id)
        local place = {mentor = at(district:WaitForChild("Mentor")), treasure = at(district:WaitForChild("Treasure")),
            surveys = {}, seals = {}, routes = {}}
        places[chapter.id] = place
        for index = 1, 3 do
            place.surveys[index], place.seals[index] = at(district:WaitForChild("Survey-" .. index)), at(district:WaitForChild("Seal-" .. index))
            prompt(place.surveys[index], "Inspect marker", chapter.name, function(player)
                if callbacks.blocked(player) then return end
                local d = read(player).districts[chapter.id]
                if not (d and d.met) then sendNotice(player, "Meet the " .. chapter.mentor .. " first."); return end
                if d.surveys and d.surveys[tostring(index)] then sendNotice(player, "Marker already recorded."); return end
                if enqueue(player, {kind = "survey", district = chapter.id, index = index}) then publish(player) end
            end)
            prompt(place.seals[index], "Record seal", chapter.name, function(player)
                if callbacks.blocked(player) then return end
                local d = read(player).districts[chapter.id]
                if d and d.seals and d.seals[tostring(index)] then sendNotice(player, "Seal already in your journal."); return end
                if enqueue(player, {kind = "seal", district = chapter.id, index = index}) then publish(player) end
            end)
        end
        prompt(place.mentor, "Talk", chapter.mentor, function(player)
            if callbacks.blocked(player) then return end
            local d = read(player).districts[chapter.id]
            if not d or not d.met or (d.step == 2 and d.trial) then
                enqueue(player, {kind = "mentor", district = chapter.id})
            end
            if chapter.id == "valley" then
                local world = read(player)
                if not world.graduated and Progress.totals(world).chapters == #Catalog.chapters then
                    enqueue(player, {kind = "graduate"})
                end
            end
            publish(player, "open", "chapters")
        end)
        cachePrompt(place.treasure, chapter.id, chapter.name .. " Treasure", function(world)
            local d = world.districts[chapter.id]
            local seals = Progress.count(d and d.seals)
            return if seals < 3 then string.format("Cache locked · %d/3 district seals.", seals) else nil
        end)
        for slot, named in chapter.activities do
            local nodes = district:WaitForChild("Activity-" .. slot)
            local startPart = nodes:FindFirstChild("Start") or nodes:WaitForChild("Activity Start")
            local route = {definition = Catalog.activities[named[1]], start = at(startPart), checkpoints = {}}
            local index = 1
            while nodes:FindFirstChild(tostring(index)) do
                route.checkpoints[index] = at(nodes[tostring(index)])
                index += 1
            end
            assert(#route.checkpoints >= 3, named[1] .. " needs three checkpoints")
            place.routes[slot] = route
            local interactive = named[3] == "timing" or named[3] == "sequence"
            if interactive then
                for i, checkpoint in route.checkpoints do
                    if named[3] == "timing" then table.insert(timingNodes, {part = checkpoint, index = i}) end
                    local trigger = prompt(checkpoint, if named[3] == "timing" then "Tap lamp" else "Activate signal",
                        named[2] .. " · " .. i, function(player)
                            local run, now = session(player).run, workspace:GetServerTimeNow()
                            if not run or run.route ~= route then
                                sendNotice(player, "Start " .. named[2] .. " at its sign first."); return
                            end
                            if now > run.deadline then stop(player, "Time expired. Try the start marker again."); return end
                            if run.order[run.next] ~= i then sendNotice(player, "Look for the next marked signal."); return end
                            if named[3] == "timing" and not lit(now, i) then
                                sendNotice(player, "Wait for the mint light."); return
                            end
                            advance(player, run, i, now)
                        end)
                    trigger:SetAttribute("CityCheckpointId", named[1] .. "/" .. i)
                    CollectionService:AddTag(trigger, "CityAdventureCheckpointPrompt")
                end
            end
            prompt(route.start, "Start activity", named[2], function(player, root) start(player, root, route, "normal") end)
            if slot == 2 and chapter.id ~= "valley" then
                prompt(route.start, "Practice trial", chapter.mentor, function(player, root) start(player, root, route, "trial") end,
                    Enum.KeyCode.R, Enum.KeyCode.ButtonY)
            end
            if slot == chapter.mastery and chapter.id ~= "sky" then
                prompt(route.start, "Expert route", named[2], function(player, root) start(player, root, route, "expert") end,
                    Enum.KeyCode.X, Enum.KeyCode.ButtonL1)
            end
        end
    end
    prompt(at(folder:WaitForChild("Festival")), "Open festival", "Training Festival", function(player)
        if not callbacks.blocked(player) then publish(player, "open", "festival") end
    end)
    cachePrompt(at(folder:WaitForChild("Grand Treasure")), "grand", "Grand Treasure", function(world)
        local caches = Progress.totals(world).caches
        return if caches < #Catalog.chapters
            then string.format("Grand Treasure locked · %d/%d district caches.", caches, #Catalog.chapters) else nil
    end)

    remote.OnServerEvent:Connect(function(player, action, id)
        local s, now = session(player), workspace:GetServerTimeNow()
        if action == "view" then
            if now >= (s.viewAt or 0) then
                s.viewAt = now + .55
                publish(player)
            end
            return
        end
        if now < (s.remoteAt or 0) then return end
        s.remoteAt = now + .28
        if action == "track" and type(id) == "string" and Catalog.byId[id] and read(player).tracked ~= id then
            if enqueue(player, {kind = "track", district = id}) then publish(player) end
        elseif action == "cancel" then
            stop(player, "Activity cancelled.")
        elseif action == "sash" and type(id) == "boolean" and not callbacks.blocked(player) then
            local cloud = read(player).cloudbreak
            if cloud and (cloud.equipped ~= false) ~= id then
                if enqueue(player, {kind = "sash", equipped = id}) then publish(player) end
            end
        elseif action == "travel" and type(id) == "string" and places[id] and not callbacks.blocked(player) then
            local root, world = Match.root(player), read(player)
            local d = world.districts[id]
            if root and (id == "valley" or d and d.step == 3) then
                local anchor = if id == "valley" then workspace:FindFirstChild("Grand Dojo Spawn") or places[id].mentor
                    else places[id].mentor
                local destination = anchor.CFrame * CFrame.new(0, 1.3, 4.5)
                local ray = RaycastParams.new()
                ray.FilterDescendantsInstances = {player.Character}
                ray.RespectCanCollide = true
                local ground = workspace:Raycast(destination.Position + Vector3.yAxis * 4, -Vector3.yAxis * 12, ray)
                if ground and ground.Normal.Y > .72 then
                    Match.move(root, CFrame.new(ground.Position + Vector3.yAxis * 2.3) * destination.Rotation)
                    publish(player)
                else
                    sendNotice(player, "The arrival path is busy. Follow the marked road.")
                end
            end
        end
    end)

    local lastCheck, visitAt, lastFestivalPhase = 0, 0, nil
    RunService.Heartbeat:Connect(function()
        local now = workspace:GetServerTimeNow()
        if now - lastCheck < SAMPLE_INTERVAL then return end
        lastCheck = now
        for _, marker in timingNodes do
            local active = lit(now, marker.index)
            if marker.lit ~= active then marker.lit, marker.part.Color = active, if active then LIT else WAIT end
        end
        for player, s in sessions do
            local run = s.run
            if not run then continue end
            local root = Match.root(player)
            if root ~= run.root or now > run.deadline then
                stop(player, if root ~= run.root then "Your activity ended." else "Time expired. Try the start marker again.")
                continue
            end
            local speed = (root.Position - run.lastPosition).Magnitude / math.max(.1, now - run.moveAt)
            run.lastPosition, run.moveAt = root.Position, now
            if speed > 90 then
                stop(player, "You left the activity route. Try the start marker again.")
                continue
            end
            local kind = run.route.definition.kind
            if kind ~= "timing" and kind ~= "sequence" then
                local index = run.order[run.next]
                if inReach(root, run.route.checkpoints[index], 5.2) then advance(player, run, index, now) end
            end
        end
        if now < visitAt then return end
        visitAt = now + 1.5
        local window, endsAt = Progress.festivalAt(now)
        local phase = window * 2 + (if now < endsAt then 0 else 1)
        if phase ~= lastFestivalPhase then
            lastFestivalPhase = phase
            for player in sessions do publish(player) end
        end
        for _, player in Players:GetPlayers() do
            if not callbacks.profile(player) or callbacks.blocked(player) then continue end
            local root, world = Match.root(player), read(player)
            for _, chapter in Catalog.chapters do
                local d = world.districts[chapter.id]
                if not (d and d.visited) and inReach(root, places[chapter.id].surveys[1], 20) then
                    if enqueue(player, {kind = "visit", district = chapter.id}) then publish(player) end
                    break
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        stop(player)
        sessions[player] = nil
    end)

    return {
        project = function(player, profile)
            local awards = {}
            for id in profile.trophies do table.insert(awards, id) end
            table.sort(awards)
            player:SetAttribute("CityAdventureAwards", table.concat(awards, ","))
            local cloud = Progress.world(profile).cloudbreak
            if cloud then
                player:SetAttribute("CityAdventureCloudbreakBest", cloud.best / 10)
                player:SetAttribute("CityAdventureCleanBest", cloud.cleanBest and cloud.cleanBest / 10)
                player:SetAttribute("CloudbreakCosmetic", Catalog.cloudbreakCosmetic)
                player:SetAttribute("CloudbreakSashEquipped", cloud.equipped ~= false)
            end
            publish(player)
        end,
        saved = function(player, command, xp)
            if xp > 0 then
                local label = if command.kind == "cloudbreak" then "Cloudbreak reward saved"
                    elseif command.kind == "cache" or command.kind == "grand-cache" then
                        (if xp == 1000 then "Rare treasure saved" else "Treasure saved")
                    else "Adventure progress saved"
                sendNotice(player, string.format("%s · +%d XP", label, xp))
            end
        end,
        trusted = function(player, command)
            local world = read(player)
            if command.kind == "festival" then
                local now = workspace:GetServerTimeNow()
                local window, endsAt = Progress.festivalAt(now)
                if now >= endsAt or (world.festival and world.festival.window == window
                    and (world.festival.earned or world.festival.stamps[command.activity])) then return end
            elseif command.kind == "trial" then
                local district = world.districts[command.district]
                if not district or district.step ~= 2 or district.trial then return end
            end
            if enqueue(player, command) and player.Parent == Players then publish(player) end
        end,
    }
end

return Service
