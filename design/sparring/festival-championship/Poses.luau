-- Disposable Studio staging. Local visual copies drive poses while the real match can keep running.
-- playerCF is the Reedguard root frame, and botCF is the Juniper frame at canvas height.
local function stageFestivalPoses(options)
    options = options or {}
    local RunService = game:GetService("RunService")
    local localPlayer = game:GetService("Players").LocalPlayer
    local character = assert(localPlayer.Character)
    local rootPart = assert(character:FindFirstChild("HumanoidRootPart"))
    local ring = workspace["Grand Dojo City"]["Fighting Ring"]
    local corner = ring["Bot Spar Corner"]
    local originalBot = assert(options.botSource or corner:FindFirstChild("Juniper Tortoise"), "Start Bot Spar to stage Juniper.")
    local floor = ring["Warm ring canvas"].Position.Y + ring["Warm ring canvas"].Size.Y / 2
    local center = Vector3.new(34.9, floor, 3.8)
    local half = Vector3.new(0, 0, 2.16)
    local playerPoint = center + half + Vector3.new(0, 2.1326, 0)
    local botPoint = center - half
    local playerBase = options.playerCF or CFrame.lookAt(playerPoint, playerPoint - Vector3.zAxis)
    local botBase = options.botCF or CFrame.lookAt(botPoint, botPoint + Vector3.zAxis)
    local stage = Instance.new("Folder")
    stage.Name = "Festival Championship Pose Demo"
    stage.Parent = workspace

    local function makeVisual(source, primaryName)
        local model = Instance.new("Model")
        model.Name = source.Name .. " – staged pose"
        local parts, joints, welds = {}, {}, {}
        local sourceParts, visualParts, frames, savedVisibility = {}, {}, {}, {}
        for _, original in source:GetDescendants() do
            if original:IsA("BasePart") then
                local copy = assert(original:Clone(), "Could not copy " .. original.Name)
                for _, child in copy:GetChildren() do
                    if not (child:IsA("DataModelMesh") or child:IsA("SurfaceAppearance") or child:IsA("Decal")) then
                        child:Destroy()
                    end
                end
                copy.Anchored, copy.CanCollide, copy.CanQuery, copy.CanTouch = true, false, false, false
                copy.LocalTransparencyModifier = 0
                copy.Parent = model
                parts[original] = #visualParts + 1
                table.insert(sourceParts, original)
                table.insert(visualParts, copy)
                table.insert(frames, copy.CFrame)
                savedVisibility[original] = original.LocalTransparencyModifier
                original.LocalTransparencyModifier = 1
                if original.Name == primaryName then model.PrimaryPart = copy end
            elseif original:IsA("Motor6D") and original.Part1 then
                joints[original.Part1] = original
            elseif original:IsA("WeldConstraint") and original.Part1 then
                welds[original.Part1] = original
            end
        end
        model.Parent = stage
        return {model=model, source=sourceParts, copies=visualParts, frames=frames, joints=joints,
            welds=welds, hidden=savedVisibility}
    end

    local reed = makeVisual(character, "HumanoidRootPart")
    local juniper = makeVisual(originalBot, "PoseOrigin")
    local botRest = {}
    local sourceBotBase = originalBot:GetPivot()
    for i, part in juniper.source do botRest[i] = sourceBotBase:ToObjectSpace(part.CFrame) end
    local attachments = {}
    for _, part in reed.source do
        local weld = reed.welds[part]
        if weld and weld.Part0 and not reed.joints[part] then
            attachments[part] = weld.Part0.CFrame:ToObjectSpace(part.CFrame)
        end
    end

    local function cf(x, y, z, pitch, yaw, roll)
        return CFrame.new(x, y, z) * CFrame.Angles(math.rad(pitch), math.rad(yaw), math.rad(roll))
    end

    local function sample(sequence, t)
        if not sequence then return {} end
        local last = sequence[#sequence]
        if t >= last[1] then return last[2] end
        for i = 2, #sequence do
            local first, nextPose = sequence[i - 1], sequence[i]
            if t <= nextPose[1] then
                local alpha = math.clamp((t - first[1]) / (nextPose[1] - first[1]), 0, 1)
                alpha = alpha * alpha * (3 - 2 * alpha)
                local samplePose = {}
                for joint, transform in first[2] do samplePose[joint] = transform:Lerp(nextPose[2][joint] or CFrame.identity, alpha) end
                for joint, transform in nextPose[2] do
                    if not samplePose[joint] then samplePose[joint] = CFrame.identity:Lerp(transform, alpha) end
                end
                return samplePose
            end
        end
        return last[2]
    end

    local function sleeve(parent, name, color, width)
        local piece = Instance.new("Part")
        piece.Name = name
        piece.Shape = Enum.PartType.Cylinder
        piece.Color = color
        piece.Material = Enum.Material.SmoothPlastic
        piece.Anchored = true
        piece.CanCollide, piece.CanQuery, piece.CanTouch = false, false, false
        piece.CastShadow = false
        piece.Size = Vector3.new(1, width, width)
        piece.Parent = parent
        return piece, width
    end

    local function bridge(links, startPoint, endPoint)
        local piece, width = links[1], links[2]
        local offset = endPoint - startPoint
        if offset.Magnitude < .03 then
            piece.Transparency = 1
            return
        end
        piece.Transparency = 0
        local middle = (startPoint + endPoint) / 2
        piece.Size = Vector3.new(offset.Magnitude + .14, width, width)
        piece.CFrame = CFrame.lookAt(middle, endPoint) * CFrame.Angles(0, math.pi / 2, 0)
    end

    local reedLinks, botLinks = {}, {}
    for side, sign in {Left=-1, Right=1} do
        local function bind(sideName, group, width, color, a, b, offsetA, offsetB)
            local piece, diameter = sleeve(group.model, sideName, color, width)
            return {piece, diameter, a=a,b=b,offsetA=offsetA,offsetB=offsetB}
        end
        table.insert(reedLinks, bind(side .. " thigh", reed, .53, Color3.fromRGB(166,100,55),
            "Torso",side.." Leg", Vector3.new(sign*.56,-.47,.14),Vector3.new(0,.15,0)))
        table.insert(reedLinks, bind(side .. " ankle", reed, .42, Color3.fromRGB(204,132,69),
            side.." Leg",side.." foot", Vector3.new(0,-.28,0),Vector3.new(0,.08,.25)))
        table.insert(botLinks, bind(side .. " martial trouser", juniper, .42, Color3.fromRGB(28,95,80),
            "Hip wrap", side.." Shin",Vector3.new(sign*.35,-.12,0),Vector3.new(.03,0,0)))
        table.insert(botLinks, bind(side .. " bracer sleeve", juniper, .35, Color3.fromRGB(32,100,89),
            side.." Sleeve", side.." Paw",Vector3.zero,Vector3.zero))
    end

    local function connect(links, frames)
        for _, link in links do
            if frames[link.a] and frames[link.b] then
                bridge(link, frames[link.a]:PointToWorldSpace(link.offsetA),
                    frames[link.b]:PointToWorldSpace(link.offsetB))
            end
        end
    end

    local function animateReed(base, pose)
        local worlds = {[rootPart] = base}
        local function resolve(part)
            local previous = worlds[part]
            if previous then return previous end
            local joint = reed.joints[part]
            local weld = reed.welds[part]
            local world
            if joint and joint.Part0 then
                world = resolve(joint.Part0) * (pose[joint.Name] or CFrame.identity) * joint.C0 * joint.C1:Inverse()
            elseif weld and attachments[part] then
                world = resolve(weld.Part0) * attachments[part]
            else
                world = base * rootPart.CFrame:ToObjectSpace(part.CFrame)
            end
            worlds[part] = world
            return world
        end
        local namedFrames = {}
        for i, part in reed.source do
            reed.frames[i] = resolve(part)
            namedFrames[part.Name] = reed.frames[i]
        end
        workspace:BulkMoveTo(reed.copies, reed.frames, Enum.BulkMoveMode.FireCFrameChanged)
        connect(reedLinks, namedFrames)
    end

    local function animateJuniper(base, pose)
        local body = pose.body or CFrame.identity
        local namedFrames = {}
        for i, part in juniper.source do
            local detail = pose[part.Name]
            local rest = botRest[i]
            if detail then rest = CFrame.new(detail.Position) * rest * detail.Rotation end
            if part.Name == "PoseOrigin" then
                juniper.frames[i] = base
            elseif part.Name == "Left Foot" or part.Name == "Left Shin" or part.Name == "Right Foot" or part.Name == "Right Shin" then
                juniper.frames[i] = base * (pose.legs or CFrame.identity) * rest
            else
                juniper.frames[i] = base * body * rest
            end
            namedFrames[part.Name] = juniper.frames[i]
        end
        workspace:BulkMoveTo(juniper.copies, juniper.frames, Enum.BulkMoveMode.FireCFrameChanged)
        connect(botLinks, namedFrames)
    end

    local leadHand = "Right Shoulder"
    local rearHand = "Left Shoulder"
    local frontFoot = "Right Hip"
    local backFoot = "Left Hip"
    local torso = "RootJoint"
    local look = "Neck"
    local neutralReed = {
        [torso] = cf(0, -.035, 0, -2, -10, 0),
        [leadHand] = cf(-.12, .06, -.11, -13, -9, -12),
        [rearHand] = cf(.11, .05, -.05, -9, 7, 12),
        [frontFoot] = cf(0, 0, -.06, 5, 0, 0),
    }
    local reedCoil = {
        [torso] = cf(.15, -.23, .30, 7, -33, -9),
        [leadHand] = cf(.23, -.10, .44, 21, 30, -25),
        [rearHand] = cf(.22, .19, -.08, -28, -8, 22),
        [frontFoot] = cf(0, .14, -.30, 16, 0, 0),
        [backFoot] = cf(0, .16, -.02, -10, 0, -6),
        [look] = cf(0, 0, -.04, -9, 21, 9),
    }
    local reedPunch = {
        [torso] = cf(-.38, -.05, -1.65, -5, 16, 7),
        [leadHand] = cf(.04, -.12, -.92, -17, -22, -8),
        [rearHand] = cf(.06, -.04, .23, 17, 20, 19),
        [frontFoot] = cf(-.08, .14, -.09, 8, 0, 4),
        [backFoot] = cf(0, .09, 1.36, -21, 0, -4),
        [look] = cf(0, 0, -.08, 7, -13, -6),
        TailJoint = cf(0, .04, .12, 14, -13, 4),
    }
    local reedGuard = {
        [torso] = cf(0, -.22, .14, -7, -3, 0),
        [leadHand] = cf(-.32, .27, -.24, -22, -18, -29),
        [rearHand] = cf(.32, .20, -.18, -19, 16, 26),
        [frontFoot] = cf(.09, .12, -.19, 0, 0, 0),
        [backFoot] = cf(-.07, .13, .25, 0, 0, 0),
        [look] = cf(0, -.09, -.12, -9, 3, 0),
    }
    local reedBlock = table.clone(reedGuard)
    reedBlock[torso] = cf(.08, -.22, .51, 7, -3, -8)
    reedBlock[leadHand] = cf(-.27, .32, .03, -27, -16, -35)
    local reedParry = table.clone(reedGuard)
    reedParry[torso] = cf(.26, -.22, -.12, -6, 25, 10)
    reedParry[leadHand] = cf(-.31, .26, -.53, -37, -39, -10)
    reedParry[rearHand] = cf(.10, .06, .30, -19, 16, 26)
    local reedHurt = {
        [torso] = cf(-.15, -.21, .64, 18, -20, -12),
        [leadHand] = cf(.17, -.12, .38, 20, 25, -24),
        [rearHand] = cf(-.15, .04, .12, -9, 1, 32),
        [look] = cf(0, .04, .04, 12, -8, -12),
        [backFoot] = cf(-.10, .15, -.14, 10, 0, 0),
    }
    local reedWin = {
        [torso] = cf(0, .02, .07, -1, 10, -3),
        [leadHand] = cf(-.09, .43, -.12, 66, 5, -28),
        [rearHand] = cf(.06, .09, -.10, -21, 2, 15),
        [look] = cf(0, .08, 0, 7, -9, 2),
        [frontFoot] = cf(.05, 0, -.10, 3, 0, 0),
    }
    -- Juniper leads with the paw nearest the stage camera.
    local function botPose(x, y, z, pitch, yaw, roll)
        return cf(-x, y, z, pitch, -yaw, -roll)
    end
    local botCoil = {
        body = botPose(-.18, -.12, .37, 0, -33, -9),
        ["Left Paw"] = botPose(.22, .34, .73, -10, 21, 22),
        ["Left Sleeve"] = botPose(.14, .20, .32, -14, 24, 19),
        ["Right Paw"] = botPose(.12, .16, -.30, 4, -12, 8),
        ["Right Foot"] = botPose(-.10, .05, -.29, -8, -11, 0),
        ["Right Shin"] = botPose(-.10, .12, -.19, -6, -11, 0),
    }
    local botPunch = {
        body = botPose(.08, -.09, -.98, -7, -12, -4),
        ["Left Paw"] = botPose(.02, -.45, -1.65, -41, -8, 4),
        ["Left Sleeve"] = botPose(.02, -.11, -.83, -55, -10, 3),
        ["Right Paw"] = botPose(-.04, -.06, .22, -9, -12, 8),
        ["Right Foot"] = botPose(-.10, .05, -.57, -4, -11, 0),
        ["Right Shin"] = botPose(-.10, .02, -.43, -8, -11, 0),
    }
    local botRecoil = {
        body = botPose(-.31, -.54, .97, 24, -22, -14),
        ["Left Paw"] = botPose(.19, -.32, .35, 27, -18, 20),
        ["Left Sleeve"] = botPose(.12, -.09, .23, 28, -13, 12),
        ["Right Paw"] = botPose(-.22, -.27, .34, -3, -12, -27),
        ["Right Sleeve"] = botPose(-.14, -.12, .04, 3, 6, 12),
        ["Left Foot"] = botPose(.12, .03, .67, 2, -5, 0),
        ["Left Shin"] = botPose(.12, .09, .44, 12, 5, 0),
    }
    local botParried = {
        body = botPose(-.27, -.32, .65, 15, -32, -12),
        ["Left Paw"] = botPose(.42, .50, .36, 35, -10, -19),
        ["Left Sleeve"] = botPose(.34, .21, .12, 35, 0, -27),
        ["Right Paw"] = botPose(-.21, -.08, -.13, -5, -7, -1),
        ["Left Foot"] = botPose(.10, .03, .48, 2, -8, 0),
    }
    local botOffBalance = {
        body = botPose(-.26, .19, .84, 37, -20, -17),
        legs = botPose(-.24, .42, .78, 37, -20, -17),
        ["Left Paw"] = botPose(.28, .28, .26, 13, -7, 22),
        ["Right Paw"] = botPose(-.33, .26, .18, 4, -7, -28),
    }
    local botDown = {
        body = botPose(-.41, .80, 1.34, 83, -3, 0),
        legs = botPose(-.41, .80, 1.34, 83, -3, 0),
        ["Left Paw"] = botPose(.25, -.10, .10, 10, 14, 14),
        ["Right Paw"] = botPose(-.24, -.10, .10, 10, -14, -12),
    }
    local actions = {
        intro = {{0, neutralReed}, {.46, reedGuard}, {.68, neutralReed}},
        playerWindup = {{0, neutralReed}, {.16, reedCoil}},
        strike = {{0, neutralReed}, {.10, reedCoil}, {.23, reedPunch}, {.34, reedPunch}, {.59, neutralReed}},
        guard = {{0, neutralReed}, {.16, reedGuard}, {.67, reedGuard}, {.83, neutralReed}},
        blocked = {{0, reedGuard}, {.07, reedBlock}, {.23, reedGuard}, {.43, neutralReed}},
        parried = {{0, reedGuard}, {.12, reedParry}, {.24, reedParry}, {.45, neutralReed}},
        counter = {{0, reedParry}, {.09, reedCoil}, {.20, reedPunch}, {.38, reedPunch}, {.64, neutralReed}},
        hurt = {{0, neutralReed}, {.08, reedHurt}, {.20, reedHurt}, {.55, neutralReed}},
        victory = {{0, neutralReed}, {.34, reedWin}},
        ko = {{0, neutralReed}, {.12, reedCoil}, {.26, reedPunch}, {.40, reedPunch}, {.72, neutralReed}},
    }
    local opponent = {
        intro = {{0, {}}, {.45, botCoil}, {.72, {}}},
        strike = {{0, {}}, {.23, {}}, {.32, botRecoil}, {.44, botRecoil}, {.68, {}}},
        botWindup = {{0, {}}, {.60, botCoil}, {.79, botCoil}, {.90, botPunch}, {1.05, botPunch}, {1.31, {}}},
        blocked = {{0, botPunch}, {.13, botCoil}, {.47, {}}},
        parried = {{0, botPunch}, {.10, botParried}, {.39, botParried}, {.72, {}}},
        counter = {{0, botParried}, {.20, {}}, {.29, botRecoil}, {.44, botRecoil}, {.75, {}}},
        hurt = {{0, botPunch}, {.18, botPunch}, {.48, {}}},
        ko = {{0, {}}, {.26, {}}, {.34, botRecoil}, {.50, botOffBalance}, {.76, botDown}},
    }
    local playerSequence, playerAt = actions.intro, os.clock()
    local botSequence, botAt = opponent.intro, playerAt
    local function play(label, visualDelay)
        local start = os.clock() + (visualDelay or 0)
        if actions[label] then playerSequence, playerAt = actions[label], start end
        if opponent[label] then botSequence, botAt = opponent[label], start end
    end
    local function update()
        local now = os.clock()
        local viewPlayer, viewBot = playerBase, botBase
        if options.live and originalBot.Parent and rootPart.Parent then
            local delta = originalBot:GetPivot().Position - rootPart.Position
            local direction = Vector3.new(delta.X, 0, delta.Z)
            if direction.Magnitude > .04 then
                local toward = direction.Unit
                local midpoint = (rootPart.Position + originalBot:GetPivot().Position) / 2
                local separation = math.clamp(direction.Magnitude, 3.3, 4.32) / 2
                local pl = Vector3.new(midpoint.X, floor + 2.1326, midpoint.Z) - toward * separation
                local bo = Vector3.new(midpoint.X, floor, midpoint.Z) + toward * separation
                viewPlayer = CFrame.lookAt(pl, pl + toward)
                viewBot = CFrame.lookAt(bo, bo - toward)
            end
        end
        animateReed(viewPlayer, sample(playerSequence, now - playerAt))
        animateJuniper(viewBot, sample(botSequence, now - botAt))
    end
    update()
    local connection = RunService.PreRender:Connect(update)
    local function destroy()
        connection:Disconnect()
        for _, model in {reed, juniper} do
            for part, visibility in model.hidden do
                if part.Parent then part.LocalTransparencyModifier = visibility end
            end
        end
        stage:Destroy()
    end
    return {play=play, start=function() play("intro") end, destroy=destroy, player=reed.model, bot=juniper.model}
end
