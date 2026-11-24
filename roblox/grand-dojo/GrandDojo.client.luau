local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
player:SetAttribute("MusicArea", "city")
local city = workspace:WaitForChild("Grand Dojo City")
local districts = city:WaitForChild("District Markers")
local relay = city:WaitForChild("Lantern Relay")
local gates = relay:WaitForChild("Checkpoints")
local remote = ReplicatedStorage:WaitForChild("GrandDojoAction")
local sparRemote = ReplicatedStorage:WaitForChild("GrandDojoSparring")
local duelRemote = ReplicatedStorage:WaitForChild("GrandDojoDuel")
local fighterCatalog = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog"))
local trophyTemplate = ReplicatedStorage:WaitForChild("LanternKeeperTrophy")
local sceneLights = {}
local ambientEmitters = {}
local waterBeams = {}
local horizontalWaterSpeed = {
    ["Reedfall outflow foam"] = .38,
    ["Canal surface ripple"] = .18,
}

local function trackLocalEffects(instance)
    if (instance:IsA("PointLight") and instance.Name == "Amber lantern light")
        or ((instance:IsA("SpotLight") or instance:IsA("SurfaceLight"))
            and instance.Name == "Amber threshold light") then
        sceneLights[instance] = true
        instance.Enabled = false
        instance.Shadows = false
    elseif instance:IsA("ParticleEmitter") and instance.Name == "Ambient city particles" then
        ambientEmitters[instance] = true
        instance.Enabled = false
    elseif instance:IsA("Beam") then
        local speed = if instance.Name == "Reedfall flowing water" then .52 + instance.Width0 * .075
            else horizontalWaterSpeed[instance.Name]
        if speed then
            waterBeams[instance] = speed
            instance.TextureSpeed = 0
        end
    end
end

city.DescendantAdded:Connect(trackLocalEffects)
city.DescendantRemoving:Connect(function(instance)
    sceneLights[instance] = nil
    ambientEmitters[instance] = nil
    waterBeams[instance] = nil
end)
for _, descendant in city:GetDescendants() do
    trackLocalEffects(descendant)
end

local function enableNearbyParticles(root)
    local reduced = GuiService.ReducedMotionEnabled or UserInputService.VREnabled
    local candidates = {}
    for emitter in ambientEmitters do
        local anchor = emitter.Parent
        local distance = root and anchor and (anchor.Position - root.Position).Magnitude or math.huge
        if not reduced and distance <= 72 then
            table.insert(candidates, {emitter = emitter, distance = distance})
        elseif emitter.Enabled then
            emitter.Enabled = false
            emitter:Clear()
        end
    end
    table.sort(candidates, function(a, b)
        return a.distance < b.distance
    end)
    local limit = UserInputService.TouchEnabled and 2 or 4
    for index, candidate in candidates do
        local emitter = candidate.emitter
        local enable = index <= limit
        if emitter.Enabled ~= enable then
            emitter.Enabled = enable
            if not enable then
                emitter:Clear()
            end
        end
    end
end

local function updateWaterBeams(root)
    local reduced = GuiService.ReducedMotionEnabled or UserInputService.VREnabled
    local range = UserInputService.TouchEnabled and 82 or 118
    for beam, scrollSpeed in waterBeams do
        local anchor = beam.Attachment0
        local close = root and anchor and (root.Position - anchor.WorldPosition).Magnitude <= range
        local speed = if not reduced and close then scrollSpeed else 0
        if beam.TextureSpeed ~= speed then
            beam.TextureSpeed = speed
        end
    end
end

local lightClock = 0
RunService.Heartbeat:Connect(function(dt)
    lightClock += dt
    if lightClock < .4 then
        return
    end
    lightClock = 0
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local candidates = {}
    for light in sceneLights do
        local origin = light.Parent
        local distance = root and origin and (origin.Position - root.Position).Magnitude or math.huge
        if distance <= 34 then
            table.insert(candidates, {light = light, distance = distance})
        else
            light.Enabled = false
            light.Shadows = false
        end
    end
    table.sort(candidates, function(a, b)
        return a.distance < b.distance
    end)
    local lightCount = UserInputService.TouchEnabled and 5 or 8
    local shadowCount = UserInputService.TouchEnabled and 1 or 2
    local shadowsUsed = 0
    for i, candidate in candidates do
        local enabled = i <= lightCount
        local castsShadow = enabled and shadowsUsed < shadowCount and candidate.distance <= 21
            and candidate.light:IsA("PointLight")
        candidate.light.Enabled = enabled
        candidate.light.Shadows = castsShadow
        if castsShadow then
            shadowsUsed += 1
        end
    end
    enableNearbyParticles(root)
    updateWaterBeams(root)
end)

local palette = {
    ink = Color3.fromRGB(19, 37, 40),
    raised = Color3.fromRGB(28, 53, 52),
    parchment = Color3.fromRGB(255, 242, 209),
    muted = Color3.fromRGB(190, 212, 199),
    gold = Color3.fromRGB(244, 189, 79),
    wood = Color3.fromRGB(139, 73, 50),
    edge = Color3.fromRGB(145, 113, 65),
}
local bodyFont = Enum.Font.GothamMedium
local titleFont = Enum.Font.GothamBold

local function make(className, parent, properties)
    local object = Instance.new(className)
    for property, value in properties do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function style(object, radius, outline)
    make("UICorner", object, {CornerRadius = UDim.new(0, radius)})
    if outline then
        return make("UIStroke", object, {Color = outline, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    end
    return nil
end

local function label(parent, name, size, tint, font)
    return make("TextLabel", parent, {
        Name = name,
        Size = UDim2.new(1, 0, 0, size + 8),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = tint,
        TextSize = size,
        Font = font or bodyFont,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
end

local function padding(parent, amount)
    make("UIPadding", parent, {
        PaddingTop = UDim.new(0, amount), PaddingRight = UDim.new(0, amount),
        PaddingBottom = UDim.new(0, amount), PaddingLeft = UDim.new(0, amount),
    })
end

local function shade(parent, top, bottom, rotation)
    make("UIGradient", parent, {Color = ColorSequence.new(top, bottom), Rotation = rotation or 90})
end

local function button(parent, text, primary)
    local control = make("TextButton", parent, {
        Name = text, Text = text, Font = titleFont, TextSize = 17,
        TextColor3 = primary and palette.ink or palette.parchment,
        BackgroundColor3 = primary and palette.gold or palette.raised,
        BorderSizePixel = 0, Size = UDim2.new(.5, -4, 1, 0), AutoButtonColor = false,
    })
    local stroke = style(control, 9, primary and palette.parchment or palette.edge)
    if primary then
        shade(control, Color3.fromRGB(255, 248, 217), Color3.fromRGB(224, 135, 43))
    end
    local normal = stroke.Color
    control.SelectionGained:Connect(function()
        stroke.Color = Color3.new(1, 1, 1)
        stroke.Thickness = 3
    end)
    control.SelectionLost:Connect(function()
        stroke.Color = normal
        stroke.Thickness = 1.5
    end)
    control.MouseEnter:Connect(function()
        control.BackgroundTransparency = .14
    end)
    control.MouseLeave:Connect(function()
        control.BackgroundTransparency = 0
    end)
    return control
end

local gui = make("ScreenGui", player:WaitForChild("PlayerGui"), {
    Name = "GrandDojo", ResetOnSpawn = false, ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
})
local badge = make("Frame", gui, {
    Name = "Location", Position = UDim2.fromOffset(12, 54), Size = UDim2.fromOffset(218, 107),
    BackgroundColor3 = palette.ink, BorderSizePixel = 0,
})
style(badge, 10, palette.edge)
local placeName = label(badge, "City", 14, palette.gold, titleFont)
placeName.Position = UDim2.fromOffset(11, 4)
placeName.Text = "GRAND DOJO CITY"
local placeSubtitle = label(badge, "District", 12, palette.parchment)
placeSubtitle.Position = UDim2.fromOffset(11, 24)
placeSubtitle.Text = "Festival plaza"
local parcelObjective = label(badge, "ParcelObjective", 12, palette.parchment, titleFont)
parcelObjective.Position = UDim2.fromOffset(11, 46)
local parcelObjectives = {"1/2  Stamp at Weavers’ Walk", "2/2  Deliver in Tideharbor"}
local fighterStrip = make("Frame", badge, {
    Name = "Fighter progress", Size = UDim2.new(1, -22, 0, 53),
    BackgroundTransparency = 1, BorderSizePixel = 0,
})
make("Frame", fighterStrip, {
    Name = "Progress divider", Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = palette.edge, BackgroundTransparency = .3, BorderSizePixel = 0,
})
local fighterName = label(fighterStrip, "Fighter", 13, palette.parchment, titleFont)
fighterName.Position = UDim2.fromOffset(0, 4)
fighterName.Size = UDim2.new(.61, 0, 0, 20)
fighterName.Text = "Reedguard"
local fighterLevel = label(fighterStrip, "Level", 12, palette.gold, titleFont)
fighterLevel.Position = UDim2.new(.61, 0, 0, 4)
fighterLevel.Size = UDim2.new(.39, 0, 0, 20)
fighterLevel.TextXAlignment = Enum.TextXAlignment.Right
local fighterXp = label(fighterStrip, "Experience", 12, palette.muted)
fighterXp.Position = UDim2.fromOffset(0, 22)
fighterXp.Size = UDim2.new(1, 0, 0, 19)
local xpTrack = make("Frame", fighterStrip, {
    Name = "XP track", Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = palette.raised, BorderSizePixel = 0,
})
style(xpTrack, 2)
local xpFill = make("Frame", xpTrack, {
    Name = "XP fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = palette.gold, BorderSizePixel = 0,
})
style(xpFill, 2)

local compactProgress = make("Frame", gui, {
    Name = "CompactProgress", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 6),
    Size = UDim2.fromOffset(124, 32), BackgroundColor3 = palette.ink, BackgroundTransparency = .12,
    BorderSizePixel = 0, Visible = false,
})
style(compactProgress, 8, palette.edge)
local compactText = label(compactProgress, "Progress", 12, palette.parchment, titleFont)
compactText.Position = UDim2.fromOffset(8, 2)
compactText.Size = UDim2.new(1, -16, 0, 21)
compactText.TextXAlignment = Enum.TextXAlignment.Center
local compactTrack = make("Frame", compactProgress, {
    Name = "XP track", Position = UDim2.fromOffset(9, 24), Size = UDim2.new(1, -18, 0, 3),
    BackgroundColor3 = palette.raised, BorderSizePixel = 0,
})
style(compactTrack, 2)
local compactFill = make("Frame", compactTrack, {
    Name = "XP fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = palette.gold, BorderSizePixel = 0,
})
style(compactFill, 2)
local compactParcel = label(gui, "CompactParcel", 12, palette.parchment, titleFont)
compactParcel.Position = UDim2.fromOffset(8, 6)
compactParcel.Size = UDim2.new(1, -148, 0, 32)
make("UISizeConstraint", compactParcel, {MaxSize = Vector2.new(210, 32)})
compactParcel.BackgroundColor3 = palette.ink
compactParcel.BackgroundTransparency = .12
compactParcel.BorderSizePixel = 0
compactParcel.TextWrapped = true
compactParcel.TextXAlignment = Enum.TextXAlignment.Center
compactParcel.Visible = false
style(compactParcel, 8)

local activeStarterNames = {
    ["penguin-brawler"] = "Penguin",
    ["silverback-gorilla"] = "Silverback",
    ["fire-salamander"] = "Salamander",
}
local function updateFighterProgress()
    local id = player:GetAttribute("SelectedStarterFighter") or ""
    local fighter = fighterCatalog.ById[id]
    local name = activeStarterNames[id] or (fighter and (fighter.shortName or fighter.name))
    fighterName.Text = name or "Reedguard"
    local status = player:GetAttribute("ProgressStatus")
    local snapshot = player:GetAttribute("FighterHudProgress")
    local level, earned, goal
    if type(snapshot) == "string" then
        local levelText, earnedText, goalText = string.match(snapshot, "^(%d+):(%d+):(%d+)$")
        level, earned, goal = tonumber(levelText), tonumber(earnedText), tonumber(goalText)
    end
    local ready = status == "ready" or status == "saved" or status == "saving"
    fighterLevel.Text = if ready and level then string.format("LEVEL %d", level) else ""
    if not ready or not level or not earned or not goal then
        fighterXp.Text = if status == "unavailable" then "Progress unavailable" else "Loading progress…"
        compactText.Text = if status == "unavailable" then "XP unavailable" else "Loading XP…"
        xpTrack.Visible, compactTrack.Visible = false, false
        return
    end
    xpTrack.Visible, compactTrack.Visible = true, true
    if goal > 0 then
        fighterXp.Text = string.format("%d / %d XP", earned, goal)
        compactText.Text = string.format("LV %d  ·  %d/%d XP", level, earned, goal)
        xpFill.Size = UDim2.fromScale(math.clamp(earned / goal, 0, 1), 1)
    else
        fighterXp.Text = "Max level"
        compactText.Text = string.format("LV %d  ·  Max", level)
        xpFill.Size = UDim2.fromScale(1, 1)
    end
    compactFill.Size = xpFill.Size
end
for _, attribute in {"ProgressStatus", "FighterHudProgress", "SelectedStarterFighter"} do
    player:GetAttributeChangedSignal(attribute):Connect(updateFighterProgress)
end
updateFighterProgress()

local function positionLocationHud()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local spawn = workspace:FindFirstChild("Grand Dojo Spawn")
    local camera = workspace.CurrentCamera
    local size = camera and camera.ViewportSize
    -- Keep the landmark signs clear while players orient at the start of the plaza.
    local showBelow = root and spawn and size and size.X >= 780 and size.Y >= 360
        and size.X >= 1.55 * size.Y and (root.Position - spawn.Position).Magnitude <= 10
        and not UserInputService.TouchEnabled and not UserInputService.VREnabled
    local height = badge.Size.Y.Offset
    local badgePosition = if showBelow then UDim2.new(0, 12, 1, -height - 63) else UDim2.fromOffset(12, 54)
    if badge.Position ~= badgePosition then
        badge.Position = badgePosition
    end
end

local function updateParcelObjective()
    local objective = parcelObjectives[player:GetAttribute("ParcelStage")]
    parcelObjective.Text = objective or ""
    compactParcel.Text = parcelObjective.Text
    parcelObjective.Visible = objective ~= nil
    local fighterTop = if objective then 70 else 49
    fighterStrip.Position = UDim2.fromOffset(11, fighterTop)
    local badgeHeight = fighterTop + 58
    badge.Size = UDim2.fromOffset(218, badgeHeight)
    positionLocationHud()
end
player:GetAttributeChangedSignal("ParcelStage"):Connect(updateParcelObjective)
updateParcelObjective()
local districtDescriptions = {
    ["Grand Dojo City"] = "Festival plaza",
    ["Tideharbor Coast"] = "Harbor quarter",
    ["Harbor Sky Pier"] = "Tideharbor Coast",
    ["Tidewatch Walk"] = "Tideharbor Coast",
    ["Cinder Terraces"] = "Kiln district",
    ["Potters' Yard"] = "Cinder Terraces",
    ["Copper Kiln Walk"] = "Cinder Terraces",
    ["Glaze Terrace"] = "Cinder Terraces",
    ["Skywalk Peaks"] = "Wind Court",
    ["Cloudbreak Wind Trial"] = "Skywalk Peaks",
    ["Pinecrest Trail"] = "Skywalk Peaks",
    ["Pinecrest Crossing"] = "Skywalk Peaks",
    ["Pinecrest Overlook"] = "Skywalk Peaks",
    ["Frostglass Gardens"] = "Ice gardens",
    ["Pond Terrace"] = "Frostglass Gardens",
    ["Frostglass High Walk"] = "Frostglass Gardens",
    ["Glacier Lantern Walk"] = "Frostglass Gardens",
    ["Snowbell Ridge"] = "High route to Skywalk Peaks",
    ["Mistline Vista"] = "Frostglass Gardens",
    ["Lantern Circuit"] = "Night market",
    ["Lantern Skyline Walk"] = "Lantern Circuit",
    ["Cascade Lookout"] = "Grand Dojo City",
    ["Reedfall Crown"] = "Above Cascade Lookout",
    ["Cedarbank Rise"] = "Grand Dojo City",
    ["Lantern Garden Walk"] = "Grand Dojo City",
    ["South Ridge Trail"] = "Beyond the South Gate",
    ["South Ridge Lookout"] = "Grand Dojo City",
    ["Sunken Pirate Galleon"] = "Tideharbor practice ring",
}
local currentDistrict = "Grand Dojo City"
local districtRadii = { ["Grand Dojo City"] = 109, ["Tideharbor Coast"] = 62 }
local districtMusic = {
    ["Grand Dojo City"] = "city",
    ["Tideharbor Coast"] = "tideharbor",
    ["Harbor Sky Pier"] = "tideharbor",
    ["Tidewatch Walk"] = "tideharbor",
    ["Cinder Terraces"] = "cinder",
    ["Potters' Yard"] = "cinder",
    ["Copper Kiln Walk"] = "cinder",
    ["Glaze Terrace"] = "cinder",
    ["Skywalk Peaks"] = "skywalk",
    ["Cloudbreak Wind Trial"] = "skywalk",
    ["Pinecrest Trail"] = "skywalk",
    ["Pinecrest Crossing"] = "skywalk",
    ["Pinecrest Overlook"] = "skywalk",
    ["Frostglass Gardens"] = "frostglass",
    ["Pond Terrace"] = "frostglass",
    ["Frostglass High Walk"] = "frostglass",
    ["Glacier Lantern Walk"] = "frostglass",
    ["Snowbell Ridge"] = "frostglass",
    ["Mistline Vista"] = "frostglass",
    ["Lantern Circuit"] = "lantern",
    ["Lantern Skyline Walk"] = "lantern",
    ["Cascade Lookout"] = "city",
    ["Reedfall Crown"] = "city",
    ["Cedarbank Rise"] = "city",
    ["Lantern Garden Walk"] = "city",
    ["South Ridge Trail"] = "city",
    ["South Ridge Lookout"] = "city",
    ["Sunken Pirate Galleon"] = "tideharbor",
}

local function aboveDeck(position, deck)
    if not deck then
        return false
    end
    local offset = deck.CFrame:PointToObjectSpace(position)
    return math.abs(offset.X) <= deck.Size.X / 2 and math.abs(offset.Z) <= deck.Size.Z / 2
        and offset.Y >= 0 and offset.Y <= 8
end

local function withinVolume(position, bounds)
    local offset = bounds.CFrame:PointToObjectSpace(position)
    local half = bounds.Size / 2
    return math.abs(offset.X) <= half.X and math.abs(offset.Y) <= half.Y and math.abs(offset.Z) <= half.Z
end

local function alongMarkedWalk(position, walk, boundsName)
    local bounds = walk and walk:FindFirstChild(boundsName)
    if bounds then
        for _, volume in bounds:GetChildren() do
            if withinVolume(position, volume) then
                return true
            end
        end
    end
    return false
end

local function landmarkAt(position)
    if player:GetAttribute("SkywalkTrialMode") then
        return "Cloudbreak Wind Trial"
    end
    local plaza = city:FindFirstChild("Plaza & streets")
    local garden = plaza and plaza:FindFirstChild("Lantern Garden Walk")
    local gardenCourt = garden and garden:FindFirstChild("Lantern garden court")
    if aboveDeck(position, gardenCourt and gardenCourt:FindFirstChild("Lantern garden court floor")) then
        return "Lantern Garden Walk"
    end
    local south = plaza and plaza:FindFirstChild("South Ridge Trail")
    local southLookout = south and south:FindFirstChild("South Ridge Lookout")
    if aboveDeck(position, southLookout and southLookout:FindFirstChild("Lookout stone floor")) then
        return "South Ridge Lookout"
    end
    local bounds = south and south:FindFirstChild("South Ridge location bounds")
    if bounds and withinVolume(position, bounds) then
        return "South Ridge Trail"
    end
    local skyline = city:FindFirstChild("Valley skyline")
    local cedarbank = skyline and skyline:FindFirstChild("Cedarbank Rise")
    local cedarWalk = cedarbank and cedarbank:FindFirstChild("Cedarbank garden walk")
    if aboveDeck(position, cedarWalk and cedarWalk:FindFirstChild("Cedarbank overlook deck")) then
        return "Cedarbank Rise"
    end
    local cliffs = skyline and skyline:FindFirstChild("Reedfall terraced cliffs")
    local lookout = cliffs and cliffs:FindFirstChild("Cascade Lookout")
    local crown = lookout and lookout:FindFirstChild("Reedfall Crown")
    if aboveDeck(position, crown and crown:FindFirstChild("Crown pavilion deck")) then
        return "Reedfall Crown"
    end
    if aboveDeck(position, lookout and lookout:FindFirstChild("Cascade lookout deck")) then
        return "Cascade Lookout"
    end
    local towns = city:FindFirstChild("Connected districts")
    local cinder = towns and towns:FindFirstChild("Cinder Terraces")
    if cinder then
        local copperWalk = cinder:FindFirstChild("Copper Kiln Walk")
        local copperPavilion = copperWalk and copperWalk:FindFirstChild("Copper Kiln Pavilion")
        if aboveDeck(position, copperPavilion and copperPavilion:FindFirstChild("Copper Kiln Pavilion floor"))
            or alongMarkedWalk(position, copperWalk, "Copper Kiln Walk location bounds") then
            return "Copper Kiln Walk"
        end
        local pottersYard = cinder:FindFirstChild("Potters' Yard")
        if aboveDeck(position, pottersYard and pottersYard:FindFirstChild("Potters' terrace paving")) then
            return "Potters' Yard"
        end
    end
    local roads = city:FindFirstChild("Connecting roads")
    if alongMarkedWalk(position, roads and roads:FindFirstChild("Snowbell Ridge"), "Snowbell Ridge location bounds") then
        return "Snowbell Ridge"
    end
    local glazeTerrace = roads and roads:FindFirstChild("Glaze Terrace")
    if aboveDeck(position, glazeTerrace and glazeTerrace:FindFirstChild("Glaze Terrace deck")) then
        return "Glaze Terrace"
    end
    local frostglass = towns and towns:FindFirstChild("Frostglass Gardens")
    if frostglass then
        local glacierWalk = frostglass:FindFirstChild("Glacier Lantern Walk")
        local glacierPavilion = glacierWalk and glacierWalk:FindFirstChild("Glacier Lantern Pavilion")
        if aboveDeck(position, glacierPavilion and glacierPavilion:FindFirstChild("Glacier Lantern floor"))
            or alongMarkedWalk(position, glacierWalk, "Glacier Lantern Walk location bounds") then
            return "Glacier Lantern Walk"
        end
        local mistlineVista = frostglass:FindFirstChild("Mistline Vista")
        if aboveDeck(position, mistlineVista and mistlineVista:FindFirstChild("Pale stone vista floor")) then
            return "Mistline Vista"
        end
        local highWalk = frostglass:FindFirstChild("Frostglass High Walk")
        if highWalk and (aboveDeck(position, highWalk:FindFirstChild("High walk stone deck"))
            or aboveDeck(position, highWalk:FindFirstChild("Meltwater balcony"))) then
            return "Frostglass High Walk"
        end
        local pondWalk = frostglass:FindFirstChild("Frostglass Walk")
        if aboveDeck(position, pondWalk and pondWalk:FindFirstChild("Frostglass terrace paving")) then
            return "Pond Terrace"
        end
    end
    local lanternDistrict = towns and towns:FindFirstChild("Lantern Circuit")
    local skylineWalk = lanternDistrict and lanternDistrict:FindFirstChild("Lantern Skyline Walk")
    if skylineWalk then
        local pavilion = skylineWalk:FindFirstChild("Lantern Skyline Pavilion")
        if aboveDeck(position, pavilion and pavilion:FindFirstChild("Pavilion limestone deck")) then
            return "Lantern Skyline Walk"
        end
        local walkBounds = skylineWalk:FindFirstChild("Lantern Skyline location bounds")
        if walkBounds then
            for _, volume in walkBounds:GetChildren() do
                if withinVolume(position, volume) then
                    return "Lantern Skyline Walk"
                end
            end
        end
    end
    local skywalk = towns and towns:FindFirstChild("Skywalk Peaks")
    local ridgeCrossing = skywalk and skywalk:FindFirstChild("Pinecrest Crossing")
    if alongMarkedWalk(position, ridgeCrossing, "Pinecrest Crossing location bounds") then
        return "Pinecrest Crossing"
    end
    local pinecrest = skywalk and skywalk:FindFirstChild("Pinecrest Trail")
    if pinecrest then
        if aboveDeck(position, pinecrest:FindFirstChild("Pinecrest overlook deck")) then
            return "Pinecrest Overlook"
        end
        local trailBounds = pinecrest:FindFirstChild("Pinecrest trail bounds")
        if trailBounds then
            for _, volume in trailBounds:GetChildren() do
                if withinVolume(position, volume) then
                    return "Pinecrest Trail"
                end
            end
        end
    end
    local harbor = towns and towns:FindFirstChild("Tideharbor Coast")
    local skyPier = harbor and harbor:FindFirstChild("Harbor Sky Pier")
    local seaLantern = skyPier and skyPier:FindFirstChild("Sea Lantern Pavilion")
    if aboveDeck(position, seaLantern and seaLantern:FindFirstChild("Sea Lantern deck"))
        or alongMarkedWalk(position, skyPier, "Harbor Sky Pier location bounds") then
        return "Harbor Sky Pier"
    end
    local tidewatch = harbor and harbor:FindFirstChild("Tidewatch Walk")
    if aboveDeck(position, tidewatch and tidewatch:FindFirstChild("Tidewatch lookout deck"))
        or alongMarkedWalk(position, tidewatch, "Tidewatch location bounds") then
        return "Tidewatch Walk"
    end
    local galleon = harbor and harbor:FindFirstChild("Sunken Pirate Galleon")
    local practice = galleon and galleon:FindFirstChild("Tideharbor practice ring")
    if aboveDeck(position, practice and practice:FindFirstChild("Galleon ring platform")) then
        return "Sunken Pirate Galleon"
    end
    return nil
end

local function insideTrophyHall(position)
    local hall = city:FindFirstChild("Trophy Hall")
    local foundation = hall and hall:FindFirstChild("Pavilion foundation")
    local wall = hall and hall:FindFirstChild("Rear plaster wall")
    if not foundation or not wall then
        return false
    end
    local offset = foundation.CFrame:PointToObjectSpace(position)
    local half = foundation.Size / 2
    -- The inner face of the plaster walls and the front posts enclose both occupied floors.
    return math.abs(offset.X) < half.X - 1 and offset.Z > -half.Z + 1 and offset.Z < half.Z - .65
        and offset.Y > half.Y and offset.Y < half.Y + wall.Size.Y
end

local function musicAreaAt(name, position)
    if name == "Grand Dojo City" then
        if insideTrophyHall(position) then
            return "trophy"
        end
        local ring = city:FindFirstChild("Fighting Ring")
        if aboveDeck(position, ring and ring:FindFirstChild("Warm ring canvas")) then
            return "ring"
        end
        local lane = relay:FindFirstChild("Relay music volume")
        if lane then
            local offset = lane.CFrame:PointToObjectSpace(position)
            local half = lane.Size / 2
            if math.abs(offset.X) <= half.X and math.abs(offset.Y) <= half.Y and math.abs(offset.Z) <= half.Z then
                return "relay"
            end
        end
    end
    return districtMusic[name]
end

local function updateLocation()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    local name, nearest = "Connecting road", math.huge
    for _, marker in districts:GetChildren() do
        local offset = root.Position - marker.Position
        local limit = districtRadii[marker.Name] or 41
        local distance = Vector2.new(offset.X, offset.Z).Magnitude
        if distance < nearest and distance < limit and math.abs(offset.Y) < 18 then
            name, nearest = marker.Name, distance
        end
    end
    name = landmarkAt(root.Position) or name
    local musicArea = musicAreaAt(name, root.Position)
    if musicArea and player:GetAttribute("MusicArea") ~= musicArea then
        player:SetAttribute("MusicArea", musicArea)
    end
    if name ~= currentDistrict then
        currentDistrict = name
        placeName.Text = string.upper(name)
        placeSubtitle.Text = districtDescriptions[name] or "Between districts"
    end
end

local panel = make("Frame", gui, {
    Name = "EventPanel", AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -24, .5, 0),
    Size = UDim2.fromOffset(435, 421), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0, Visible = false,
})
shade(panel, Color3.fromRGB(37, 61, 56), palette.ink, 102)
local frameEdge = style(panel, 17, palette.wood)
frameEdge.Thickness = 5
local scale = make("UIScale", panel, {Scale = 1})
padding(panel, 19)
local inset = make("Frame", panel, {
    Name = "Brass trim", Position = UDim2.fromOffset(-14, -14),
    Size = UDim2.new(1, 28, 1, 28), BackgroundTransparency = 1,
})
style(inset, 12, palette.edge)
local close = button(panel, "×", false)
close.Position = UDim2.new(1, -42, 0, 0)
close.Size = UDim2.fromOffset(42, 40)
close.ZIndex = 2
local eyebrow = label(panel, "Eyebrow", 13, palette.gold, titleFont)
eyebrow.Text = "GRAND DOJO"
local heading = label(panel, "Heading", 38, palette.parchment, Enum.Font.Garamond)
heading.Position = UDim2.fromOffset(0, 22)
local detail = label(panel, "Detail", 15, palette.muted)
detail.Position = UDim2.fromOffset(0, 72)
detail.Size = UDim2.new(1, 0, 0, 41)
detail.TextWrapped = true
detail.TextYAlignment = Enum.TextYAlignment.Top

local reward = make("Frame", panel, {
    Name = "Reward", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 124), Size = UDim2.new(1, 0, 0, 142),
})
style(reward, 12, palette.gold)
shade(reward, palette.raised, Color3.fromRGB(18, 31, 31), 14)
local viewport = make("ViewportFrame", reward, {
    Name = "LanternPreview", BackgroundTransparency = 1, Size = UDim2.fromOffset(125, 142),
    Ambient = Color3.fromRGB(185, 174, 150), LightColor = Color3.fromRGB(255, 224, 169),
    LightDirection = Vector3.new(-1, -1, -1),
})
local prizeCamera = make("Camera", viewport, {
    CFrame = CFrame.lookAt(Vector3.new(5, 3.4, 6.5), Vector3.new(0, 1.33, 0)), FieldOfView = 30,
})
viewport.CurrentCamera = prizeCamera
local model = trophyTemplate:Clone()
model.Parent = viewport
local prizeTitle = label(reward, "Prize", 22, palette.gold, Enum.Font.Garamond)
prizeTitle.Position = UDim2.fromOffset(127, 22)
prizeTitle.Size = UDim2.new(1, -138, 0, 32)
local prizeDetail = label(reward, "PrizeDetail", 14, palette.muted)
prizeDetail.Position = UDim2.fromOffset(127, 58)
prizeDetail.Size = UDim2.new(1, -146, 0, 59)
prizeDetail.TextWrapped = true
prizeDetail.TextYAlignment = Enum.TextYAlignment.Top

local mapCanvas = ReplicatedStorage:WaitForChild("CityMapCanvas"):Clone()
mapCanvas.Position = UDim2.fromOffset(0, 74)
mapCanvas.Size = UDim2.fromOffset(512, 371)
mapCanvas.Visible = false
mapCanvas.Parent = panel
style(mapCanvas, 9, palette.edge)

local mapDistricts = {
    {"Grand Dojo City", "Grand Dojo"},
    {"Tideharbor Coast", "Tideharbor"},
    {"Cinder Terraces", "Cinder"},
    {"Skywalk Peaks", "Skywalk"},
    {"Frostglass Gardens", "Frostglass"},
    {"Lantern Circuit", "Lantern Circuit"},
}
local roadGraph = {}
local roadSegments = {}
local cityRoutes = require(ReplicatedStorage:WaitForChild("CityRoutes"))
for _, district in mapDistricts do
    roadGraph[district[1]] = {}
end
for _, road in cityRoutes do
    table.insert(roadGraph[road.origin], {district = road.destination, length = road.length, road = road.name})
    table.insert(roadGraph[road.destination], {district = road.origin, length = road.length, road = road.name})
    roadSegments[road.name] = {}
end
for _, line in mapCanvas:GetChildren() do
    local segments = roadSegments[line.Name]
    if segments and line:IsA("Frame") then
        table.insert(segments, {line = line, color = line.BackgroundColor3})
    end
end

local function shortestWalkingRoute(origin, destination)
    local lengths = {[origin] = 0}
    local previous, visited = {}, {}
    while true do
        local district, distance = nil, math.huge
        for _, entry in mapDistricts do
            local name = entry[1]
            if not visited[name] and (lengths[name] or math.huge) < distance then
                district, distance = name, lengths[name]
            end
        end
        if not district or district == destination then
            break
        end
        visited[district] = true
        for _, neighbor in roadGraph[district] do
            local total = distance + neighbor.length
            if total < (lengths[neighbor.district] or math.huge) then
                lengths[neighbor.district] = total
                previous[neighbor.district] = {district = district, road = neighbor.road}
            end
        end
    end
    if not lengths[destination] then
        return nil, nil
    end
    local roads = {}
    local cursor = destination
    while cursor ~= origin do
        local step = previous[cursor]
        table.insert(roads, 1, step.road)
        cursor = step.district
    end
    return roads, lengths[destination]
end

local routeControls = make("Frame", panel, {Name = "RouteControls", BackgroundTransparency = 1, Visible = false})
local routeInfo = label(routeControls, "Walking route", 17, palette.parchment, titleFont)
routeInfo.Size = UDim2.new(1, 0, 0, 47)
routeInfo.TextWrapped = true
local routeButtons = {}
local routeOrigin = "Grand Dojo City"

local function previewWalkingRoute(destination)
    local roads, distance = shortestWalkingRoute(routeOrigin, destination)
    local highlighted = {}
    for _, road in roads or {} do
        highlighted[road] = true
    end
    local hasRoute = roads ~= nil and #roads > 0
    for road, segments in roadSegments do
        local onRoute = highlighted[road]
        for _, entry in segments do
            entry.line.BackgroundColor3 = onRoute and palette.gold or entry.color
            entry.line.BackgroundTransparency = hasRoute and not onRoute and .68 or 0
        end
    end
    for index, entry in mapDistricts do
        local control = routeButtons[index]
        local selected = hasRoute and entry[1] == destination
        control.TextColor3 = selected and palette.ink or palette.parchment
        control.BackgroundColor3 = selected and palette.gold or palette.raised
        control.Text = entry[2] .. (entry[1] == routeOrigin and "\nHere" or "")
    end
    if hasRoute then
        routeInfo.Text = string.format("≈ %d studs · %s%s", math.round(distance), roads[1], #roads > 1 and " first" or "")
    else
        routeInfo.Text = roads and "Choose a destination" or "Route unavailable"
    end
end

for index, entry in mapDistricts do
    local control = button(routeControls, entry[2], false)
    control.TextSize = 19
    control.TextWrapped = true
    control.Activated:Connect(function()
        previewWalkingRoute(entry[1])
    end)
    routeButtons[index] = control
end

local status = label(panel, "Status", 14, palette.gold)
status.Position = UDim2.fromOffset(0, 279)
status.Size = UDim2.new(1, 0, 0, 37)
status.TextWrapped = true
local actions = make("Frame", panel, {
    BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -55), Size = UDim2.new(1, 0, 0, 55),
})
local start = button(actions, "Start relay", true)
local practice = button(actions, "Practice route", false)
local eagleButton = button(actions, "Eagle Eye", true)
eagleButton.Name = "OpenEagleEye"
eagleButton.Position = UDim2.new(.5, 4, 0, 0)
eagleButton.Size = UDim2.new(.5, -4, 1, 0)
eagleButton.Visible = false
eagleButton.Selectable = true
practice.Position = UDim2.new(.5, 4, 0, 0)
start.NextSelectionRight = practice
practice.NextSelectionLeft = start
start.NextSelectionUp = close
practice.NextSelectionUp = close
close.NextSelectionDown = start

local race = make("Frame", gui, {
    Name = "RelayStatus", AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, 10),
    Size = UDim2.fromOffset(260, 76), BackgroundColor3 = palette.ink, BorderSizePixel = 0, Visible = false,
})
style(race, 11, palette.edge)
local progress = label(race, "Progress", 15, palette.parchment, titleFont)
progress.Size = UDim2.new(1, 0, 0, 34)
progress.TextXAlignment = Enum.TextXAlignment.Center
local cancel = button(race, "Leave relay", false)
cancel.AnchorPoint = Vector2.new(.5, 0)
cancel.Position = UDim2.new(.5, 0, 0, 35)
cancel.Size = UDim2.fromOffset(140, 34)
cancel.TextSize = 13

local notice = label(gui, "Notice", 16, palette.parchment, titleFont)
notice.AnchorPoint = Vector2.new(.5, 1)
notice.Position = UDim2.new(.5, 0, 1, -105)
notice.Size = UDim2.new(.85, 0, 0, 49)
notice.TextXAlignment = Enum.TextXAlignment.Center
notice.TextWrapped = true
notice.BackgroundTransparency = .12
notice.BackgroundColor3 = palette.ink
notice.Visible = false
style(notice, 9, palette.edge)

local guide = make("BillboardGui", gui, {
    Name = "RouteGuide", Size = UDim2.fromOffset(116, 43), StudsOffset = Vector3.new(0, 6.5, 0),
    AlwaysOnTop = true, Enabled = false, MaxDistance = 180, LightInfluence = 0,
})
local guideLabel = label(guide, "NextGate", 16, palette.ink, titleFont)
guideLabel.Size = UDim2.fromScale(1, 1)
guideLabel.TextXAlignment = Enum.TextXAlignment.Center
guideLabel.BackgroundTransparency = 0
guideLabel.BackgroundColor3 = palette.gold
style(guideLabel, 9, palette.parchment)

local displayedTrophy
local mountName = "LanternTrophyMount"
local function updateDisplay()
    local hall = city:FindFirstChild("Trophy Hall")
    local mount = hall and hall:FindFirstChild(mountName)
    if not displayedTrophy and mount and player:GetAttribute("LanternKeeper") then
        displayedTrophy = trophyTemplate:Clone()
        displayedTrophy:PivotTo(mount.CFrame)
        displayedTrophy.Parent = workspace
    end
end
city.DescendantAdded:Connect(function(instance)
    if instance.Name == mountName then
        task.defer(updateDisplay)
    end
end)
city.DescendantRemoving:Connect(function(instance)
    if instance.Name == mountName and displayedTrophy then
        displayedTrophy:Destroy()
        displayedTrophy = nil
    end
end)

local boardHint = make("TextButton", gui, {
    Name = "EventBoardHint", AnchorPoint = Vector2.new(.5, 1),
    Position = UDim2.new(.5, 0, 1, -20), Size = UDim2.new(1, -32, 0, 50),
    BackgroundColor3 = Color3.fromRGB(72, 47, 47), BackgroundTransparency = .14,
    BorderSizePixel = 0, Text = "", AutoButtonColor = false, Selectable = false, Active = true, Visible = false,
})
make("UISizeConstraint", boardHint, {MaxSize = Vector2.new(332, 50)})
local hintStroke = style(boardHint, 11, Color3.fromRGB(232, 185, 148))
hintStroke.Transparency = .33
local boardKey = label(boardHint, "Input", 15, Color3.fromRGB(64, 39, 40), titleFont)
boardKey.Position = UDim2.fromOffset(12, 8)
boardKey.Size = UDim2.fromOffset(38, 34)
boardKey.TextXAlignment = Enum.TextXAlignment.Center
boardKey.BackgroundColor3 = Color3.fromRGB(255, 221, 182)
boardKey.BackgroundTransparency = 0
boardKey.AutoLocalize = false
style(boardKey, 7)
local boardIcon = make("ImageLabel", boardKey, {
    Name = "ControllerGlyph", Position = UDim2.fromOffset(7, 5), Size = UDim2.fromOffset(24, 24),
    BackgroundTransparency = 1, ImageColor3 = boardKey.TextColor3, Visible = false,
})
local boardAction = label(boardHint, "Action", 18, Color3.fromRGB(255, 244, 229), titleFont)
boardAction.Position = UDim2.fromOffset(62, 0)
boardAction.Size = UDim2.new(1, -75, 1, 0)
boardAction.TextTruncate = Enum.TextTruncate.AtEnd

local boardPrompt, heldPrompt, heldInput
local boardPrompts = {}
local shownBoardPrompts = {}
local sparringActive = false
local sparResult
local sparPicker
local duelUi = {pendingRatings = {}}

function duelUi.hasRounds(format)
    return format == "series" or format == "ranked"
end

local function groupCombatUiOpen()
    return player:GetAttribute("BrawlActive") or player:GetAttribute("BrawlRecapOpen")
        or player:GetAttribute("TagTeamActive") or player:GetAttribute("TagTeamOfferOpen")
        or player:GetAttribute("TagTeamRecapOpen")
        or player:GetAttribute("KilnbackRaidActive") or player:GetAttribute("KilnbackRaidRecapOpen")
end

local function restoreWorldPrompts()
    ProximityPromptService.Enabled = not sparringActive and not groupCombatUiOpen() and not panel.Visible
        and not (sparResult and sparResult.Visible) and not (sparPicker and sparPicker.Visible)
        and not (duelUi.picker and duelUi.picker.Visible)
end

local function releaseBoardInput()
    local prompt = heldPrompt
    heldPrompt, heldInput = nil, nil
    if prompt then
        prompt:InputHoldEnd()
    end
end

local function updateBoardHint()
    local prompt = boardPrompt
    local visible = prompt ~= nil and prompt.Enabled
        and prompt.Style == Enum.ProximityPromptStyle.Custom and ProximityPromptService.Enabled
        and not panel.Visible and not race.Visible and not UserInputService.VREnabled
        and not sparringActive and not (sparResult and sparResult.Visible) and not (sparPicker and sparPicker.Visible)
    boardHint.Visible = visible
    if not visible then
        releaseBoardInput()
        return
    end

    local preferred = UserInputService.PreferredInput
    local image = ""
    local key = "Tap"
    if preferred == Enum.PreferredInput.Gamepad then
        image = UserInputService:GetImageForKeyCode(prompt.GamepadKeyCode)
        key = string.gsub(prompt.GamepadKeyCode.Name, "^Button", "")
    elseif preferred == Enum.PreferredInput.KeyboardAndMouse then
        key = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
        if key == "" then
            key = prompt.KeyboardKeyCode.Name
        end
    end
    boardIcon.Image = image
    boardIcon.Visible = image ~= ""
    boardKey.Text = if boardIcon.Visible then "" else key
    boardAction.Text = prompt.ActionText
end

local openPanel, offered = "", false
local restorePlayerList
local function updatePlayerList(hidden)
    if hidden and restorePlayerList == nil then
        restorePlayerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
        if restorePlayerList then
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        end
    elseif not hidden and restorePlayerList ~= nil then
        if restorePlayerList then
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        end
        restorePlayerList = nil
    end
end
local journal
local eagleEye
local isPractice = false
local function layoutRoutePlanner(viewportSize)
    local wide = viewportSize.X >= viewportSize.Y * 1.30
    local width, height = if wide then 804 else 550, if wide then 522 else 755
    mapCanvas.Size = if wide then UDim2.fromOffset(478, 346) else UDim2.fromOffset(512, 371)
    local areaWidth = if wide then 275 else 512
    routeControls.Position = if wide then UDim2.fromOffset(491, 74) else UDim2.fromOffset(0, 455)
    routeControls.Size = UDim2.fromOffset(areaWidth, if wide then 346 else 202)
    local columns = if wide then 2 else 3
    local buttonWidth = (areaWidth - (columns - 1) * 7) / columns
    for index, control in routeButtons do
        local column, row = (index - 1) % columns, math.floor((index - 1) / columns)
        control.Position = UDim2.fromOffset(column * (buttonWidth + 7), row * 75)
        control.Size = UDim2.fromOffset(buttonWidth, 68)
        control.NextSelectionLeft = if column > 0 then routeButtons[index - 1] else nil
        control.NextSelectionRight = if column < columns - 1 then routeButtons[index + 1] else nil
        control.NextSelectionUp = routeButtons[index - columns] or close
        control.NextSelectionDown = routeButtons[index + columns] or (eagleButton.Visible and eagleButton or start)
    end
    routeInfo.Position = UDim2.fromOffset(0, #routeButtons / columns * 75 + 2)
    start.NextSelectionUp = routeButtons[#routeButtons]
    eagleButton.NextSelectionUp = routeButtons[#routeButtons]
    close.NextSelectionDown = routeButtons[1]
    return width, height
end

local cloudbreakStatus = make("Frame", gui, {
    Name = "CloudbreakStatus", AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, 4),
    Size = UDim2.new(.90, 0, 0, 45), BackgroundColor3 = palette.ink, BorderSizePixel = 0, Visible = false,
})
make("UISizeConstraint", cloudbreakStatus, {MaxSize = Vector2.new(330, 45)})
style(cloudbreakStatus, 10, Color3.fromRGB(100, 174, 148))
local cloudbreakTitle = label(cloudbreakStatus, "Course and mode", 13, Color3.fromRGB(169, 233, 198), titleFont)
cloudbreakTitle.Position = UDim2.fromOffset(8, 3)
cloudbreakTitle.Size = UDim2.new(1, -16, 0, 18)
cloudbreakTitle.TextXAlignment = Enum.TextXAlignment.Center
local cloudbreakProgress = label(cloudbreakStatus, "Stages, shrines and time", 13, palette.parchment)
cloudbreakProgress.Position = UDim2.fromOffset(8, 21)
cloudbreakProgress.Size = UDim2.new(1, -16, 0, 19)
cloudbreakProgress.TextXAlignment = Enum.TextXAlignment.Center
cloudbreakProgress.TextScaled = true
make("UITextSizeConstraint", cloudbreakProgress, {MinTextSize = 9, MaxTextSize = 13})

local function updateCloudbreakText()
    local mode = player:GetAttribute("SkywalkTrialMode")
    local stages = player:GetAttribute("SkywalkTrialNext")
    local shrines = player:GetAttribute("SkywalkTrialRecoveries")
    local startedAt = player:GetAttribute("SkywalkTrialStartedAt")
    if (mode ~= "expert" and mode ~= "practice") or type(stages) ~= "number" or type(shrines) ~= "number"
        or (mode == "expert" and type(startedAt) ~= "number") then
        cloudbreakTitle.Text = ""
        cloudbreakProgress.Text = ""
        return
    end
    cloudbreakTitle.Text = if mode == "expert" then "CLOUDBREAK · EXPERT" else "CLOUDBREAK · PRACTICE"
    local progress = string.format("%d/6 stages  ·  %d/2 shrines", math.floor(math.clamp(stages, 0, 6)),
        math.floor(math.clamp(shrines, 0, 2)))
    if mode == "expert" then
        local timer = "Jump to start"
        if startedAt > 0 then
            local tenths = math.floor(math.max(0, workspace:GetServerTimeNow() - startedAt) * 10)
            timer = string.format("%d:%02d.%d", math.floor(tenths / 600), math.floor(tenths / 10) % 60, tenths % 10)
        end
        progress ..= "  ·  " .. timer
    end
    cloudbreakProgress.Text = progress
end

local function layout()
    updateBoardHint()
    positionLocationHud()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    local size = camera.ViewportSize
    local compact = UserInputService.TouchEnabled and not UserInputService.VREnabled
        and (size.X < 780 or size.Y < 520)
    updatePlayerList(compact or panel.Visible)
    local map = openPanel == "map"
    local journalView = openPanel == "journal"
    local aerial = eagleEye and eagleEye:IsActive()
    local width, height = 435, 421
    if map then
        width, height = layoutRoutePlanner(size)
    elseif journalView then
        width = math.clamp(size.X - 26, 240, 435)
        height = math.clamp(size.Y - 54, 240, 421)
    end
    local narrow = map or journalView or size.X < 720
    panel.AnchorPoint = Vector2.new(narrow and .5 or 1, .5)
    panel.Position = narrow and UDim2.fromScale(.5, .5) or UDim2.new(1, -26, .5, 0)
    panel.Size = UDim2.fromOffset(width, height)
    scale.Scale = math.max(.1, math.min(1, (size.X - 26)/width, (size.Y - 54)/height))
    local showingResult = sparResult and sparResult.Visible
    local choosingFight = (sparPicker and sparPicker.Visible) or (duelUi.picker and duelUi.picker.Visible)
    local inGroupCombat = groupCombatUiOpen()
    cloudbreakStatus.Visible = cloudbreakTitle.Text ~= "" and not sparringActive and not inGroupCombat and not showingResult and not choosingFight
        and not race.Visible and not panel.Visible and not aerial
    if aerial then
        boardHint.Visible = false
    end
    local showingWorldHud = not sparringActive and not inGroupCombat and not showingResult and not choosingFight
        and not race.Visible and not aerial
    badge.Visible = not compact and showingWorldHud and not (panel.Visible and narrow)
        and (not boardHint.Visible or parcelObjective.Visible)
    compactProgress.Visible = compact and showingWorldHud and not panel.Visible and not cloudbreakStatus.Visible
    compactParcel.Visible = compactProgress.Visible and parcelObjective.Visible
    if duelUi.queue then
        duelUi.queue.Visible = duelUi.queued == true and showingWorldHud and not panel.Visible
    end
end

for _, attribute in {"SkywalkTrialMode", "SkywalkTrialNext", "SkywalkTrialStartedAt", "SkywalkTrialRecoveries"} do
    player:GetAttributeChangedSignal(attribute):Connect(function()
        updateCloudbreakText()
        layout()
    end)
end
updateCloudbreakText()

local cameraViewport
local layoutMatchControls
local function refreshViewport()
    local camera = workspace.CurrentCamera
    if camera and not UserInputService.VREnabled then
        local size = camera.ViewportSize
        if size.X > 1 and size.Y > 1 then
            local aspect = size.X / size.Y
            -- Keep the outer plaza titles readable with the closer landscape arrival.
            local fit = math.deg(2 * math.atan(1.46 / aspect))
            camera.FieldOfView = if aspect < 1 then 70 else math.clamp(fit, 68, 90)
        end
    end
    layout()
    if layoutMatchControls then
        layoutMatchControls()
    end
end

local function watchCamera()
    if cameraViewport then
        cameraViewport:Disconnect()
        cameraViewport = nil
    end
    local camera = workspace.CurrentCamera
    if camera then
        cameraViewport = camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshViewport)
    end
    refreshViewport()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera()

local function hide()
    if eagleEye then
        eagleEye:Close(false)
    end
    openPanel = ""
    panel.Visible = false
    if journal then
        journal:Hide()
    end
    restoreWorldPrompts()
    if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(panel) then
        GuiService.SelectedObject = nil
    end
    layout()
end

local function formatRewardXp(amount)
    return string.format("+%d XP", amount)
end

local function updateTrophyPanel()
    local state = player:GetAttribute("ProgressStatus")
    local earned = player:GetAttribute("LanternKeeper")
    if state == nil or state == "loading" then
        detail.Text = "Loading your progression…"
    elseif state == "unavailable" then
        detail.Text = "Progress is temporarily unavailable."
    elseif state == "saving" then
        detail.Text = "Saving your progress…"
    else
        local fighter = fighterCatalog.ById[player:GetAttribute("SelectedStarterFighter") or ""]
        local prefix = if fighter then fighter.name else "Fighter progress"
        detail.Text = string.format("%s · Level %d · %d XP", prefix,
            player:GetAttribute("FighterLevel") or 1, player:GetAttribute("FighterXp") or 0)
    end
    if earned then
        prizeDetail.Text = "Earned. Your trophy is on the center pedestal."
        status.Text = "On display"
    elseif state == "ready" or state == "saved" then
        prizeDetail.Text = "Locked. Finish the Lantern Relay to earn it."
        status.Text = "Find the event board by the lantern gate."
    else
        prizeDetail.Text = "Your collection will update when progression is available."
        status.Text = "Lantern Relay practice is available."
    end
end

local function show(kind, elapsed, first, practiceRun, xpReward)
    if sparringActive or groupCombatUiOpen() or (sparPicker and sparPicker.Visible) or (duelUi.picker and duelUi.picker.Visible) then
        return
    end
    if eagleEye then
        eagleEye:Close(false)
    end
    if journal then
        journal:Hide()
    end
    openPanel = kind
    offered = kind == "relay"
    local map = kind == "map"
    local journalView = kind == "journal"
    panel.Visible = true
    ProximityPromptService.Enabled = false
    mapCanvas.Visible = map
    routeControls.Visible = map
    heading.Visible = not journalView
    eyebrow.Visible = not journalView
    close.Visible = not journalView
    actions.Visible = not journalView
    detail.Visible = not map and not journalView
    reward.Visible = not map and not journalView
    status.Visible = not map and not journalView
    if journalView then
        layout()
        journal:Show()
        return
    end
    eyebrow.Text = "GRAND DOJO"
    local earned = first or player:GetAttribute("LanternKeeper")
    local best = player:GetAttribute("RelayBest") or 0
    practice.Visible = offered
    eagleButton.Visible = map
    start.Text = if offered then "Start relay" elseif kind == "trophy" then "Open journal" else "Back to city"
    start.Size = (offered or eagleButton.Visible) and UDim2.new(.5, -4, 1, 0) or UDim2.fromScale(1, 1)
    start.NextSelectionRight = if offered then practice elseif eagleButton.Visible then eagleButton else nil
    eagleButton.NextSelectionLeft = start
    start.NextSelectionUp = close
    close.NextSelectionDown = start
    prizeTitle.Text = "Lantern Keeper"
    if map then
        heading.Text = "City map"
        routeOrigin = if roadGraph[elapsed] then elapsed else "Grand Dojo City"
        eyebrow.Text = "FROM " .. string.upper(routeOrigin)
        previewWalkingRoute(routeOrigin)
    elseif kind == "relay" or kind == "relayInfo" then
        heading.Text = "Lantern Relay"
        detail.Text = if offered then "Follow seven lantern gates in order. 2 min limit."
            else "Cross the red bridge. Start timed or practice runs at the Lantern Relay arch."
        status.Text = best > 0 and string.format("Best time  %.1fs", best) or "First clear unlocks a trophy for your hall."
        prizeDetail.Text = earned and "Already displayed in your Trophy Hall." or "Finish an official relay to earn this golden lantern."
    elseif kind == "trophy" then
        heading.Text = "Trophy Hall"
        updateTrophyPanel()
    else
        heading.Text = practiceRun and "Practice complete" or "Relay complete!"
        detail.Text = string.format("Seven gates cleared in %.1fs.", elapsed)
        prizeDetail.Text = first and "Trophy earned. Follow the jade markers to the Trophy Hall." or
            (practiceRun and "Enter an official relay to earn the trophy." or "Your first-clear trophy is already in the hall.")
        status.Text = if first then "Lantern Keeper unlocked · " .. formatRewardXp(xpReward or 0)
            elseif practiceRun then "Practice route"
            elseif xpReward and xpReward > 0 then "Official clear · " .. formatRewardXp(xpReward)
            else string.format("Best time  %.1fs", math.min(best > 0 and best or elapsed, elapsed))
    end
    layout()
    if UserInputService.GamepadEnabled then
        local firstDestination = if routeOrigin == mapDistricts[1][1] then 2 else 1
        GuiService.SelectedObject = map and routeButtons[firstDestination] or start
    end
end

journal = require(ReplicatedStorage:WaitForChild("TrophyJournal")).new(panel, player, function()
    show("trophy")
end)

local noticeId = 0
local function flash(message)
    noticeId += 1
    local id = noticeId
    notice.Text = message
    notice.Visible = true
    task.delay(3.5, function()
        if id == noticeId then
            notice.Visible = false
        end
    end)
end

eagleEye = require(ReplicatedStorage:WaitForChild("EagleEye")).new({
    player = player, gui = gui,
    make = make, button = button, label = label, style = style, palette = palette, titleFont = titleFont,
    message = flash,
    onOpened = function()
        panel.Visible = false
        layout()
    end,
    onClosed = function(restoreMap)
        if restoreMap and openPanel == "map" and not sparringActive and not race.Visible then
            panel.Visible = true
            if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
                GuiService.SelectedObject = if eagleButton.Visible then eagleButton else start
            end
        end
        layout()
    end,
})
eagleButton.Activated:Connect(function()
    if openPanel == "map" and panel.Visible then
        eagleEye:Open()
    end
end)
local function updateRace()
    local nextGate = player:GetAttribute("RelayNextGate") or 0
    local nextPart = gates:FindFirstChild(tostring(nextGate))
    guide.Adornee = nextPart
    guide.Enabled = nextPart ~= nil
    if nextPart then
        guideLabel.Text = nextGate == #gates:GetChildren() and "FINISH" or string.format("GATE  %d", nextGate)
    end
    race.Visible = nextPart ~= nil
    layout()
end

close.Activated:Connect(hide)
start.Activated:Connect(function()
    if offered and openPanel == "relay" then
        remote:FireServer("start")
    elseif openPanel == "trophy" then
        show("journal")
    else
        hide()
    end
end)
practice.Activated:Connect(function()
    if offered and openPanel == "relay" then
        remote:FireServer("practice")
    end
end)
cancel.Activated:Connect(function()
    remote:FireServer("cancel")
end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and eagleEye:IsActive()
        and (input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Backspace) then
        eagleEye:Close(true)
    elseif not processed and input.KeyCode == Enum.KeyCode.ButtonB and panel.Visible then
        if openPanel == "journal" then
            show("trophy")
        else
            hide()
        end
    elseif not processed and (input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Backspace) and race.Visible then
        remote:FireServer("cancel")
    end
end)

player:GetAttributeChangedSignal("LanternKeeper"):Connect(updateDisplay)
for _, attribute in {"LanternKeeper", "ProgressStatus", "FighterLevel", "FighterXp", "SelectedStarterFighter"} do
    player:GetAttributeChangedSignal(attribute):Connect(function()
        if openPanel == "trophy" then
            updateTrophyPanel()
        end
    end)
end
player:GetAttributeChangedSignal("RelayNextGate"):Connect(updateRace)
player:GetAttributeChangedSignal("ParcelStage"):Connect(layout)
player.CharacterAdded:Connect(hide)

local function selectBoardPrompt(preferred)
    local prompt = preferred or boardPrompt
    if not prompt or not shownBoardPrompts[prompt] or prompt.Style ~= Enum.ProximityPromptStyle.Custom then
        prompt = nil
        for candidate in shownBoardPrompts do
            if candidate.Style == Enum.ProximityPromptStyle.Custom then
                prompt = candidate
                break
            end
        end
    end
    if prompt ~= boardPrompt then
        releaseBoardInput()
        boardPrompt = prompt
    end
    layout()
end

local function registerBoardPrompts()
    local registered = {}
    local function register(owner)
        local board = owner and owner:FindFirstChild("EventBoard")
        local prompt = board and board:FindFirstChild("BoardPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then
            registered[prompt] = true
            prompt.Style = if UserInputService.VREnabled or prompt.HoldDuration > 0
                then Enum.ProximityPromptStyle.Default else Enum.ProximityPromptStyle.Custom
        end
    end
    register(city:FindFirstChild("Lantern Relay"))
    local plaza = city:FindFirstChild("Plaza & streets")
    register(plaza and plaza:FindFirstChild("Arrival Festival Board"))
    for prompt in shownBoardPrompts do
        if not registered[prompt] then
            shownBoardPrompts[prompt] = nil
        end
    end
    boardPrompts = registered
    selectBoardPrompt()
end

ProximityPromptService.PromptShown:Connect(function(prompt)
    if boardPrompts[prompt] then
        shownBoardPrompts[prompt] = true
        selectBoardPrompt(prompt)
    end
end)
ProximityPromptService.PromptHidden:Connect(function(prompt)
    if shownBoardPrompts[prompt] then
        shownBoardPrompts[prompt] = nil
        selectBoardPrompt()
    end
end)

local boardNodeNames = {
    ["Plaza & streets"] = true, ["Arrival Festival Board"] = true, ["Lantern Relay"] = true,
    EventBoard = true, BoardPrompt = true,
}
city.DescendantAdded:Connect(function(instance)
    if boardNodeNames[instance.Name] then
        registerBoardPrompts()
    end
end)
city.DescendantRemoving:Connect(function(instance)
    if not boardNodeNames[instance.Name] then
        return
    end
    for prompt in boardPrompts do
        if prompt == instance or prompt:IsDescendantOf(instance) then
            boardPrompts[prompt] = nil
            shownBoardPrompts[prompt] = nil
        end
    end
    selectBoardPrompt()
end)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(layout)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(registerBoardPrompts)
boardHint.InputBegan:Connect(function(input)
    if heldInput or not boardHint.Visible or not boardPrompt then
        return
    end
    local kind = input.UserInputType
    if kind == Enum.UserInputType.Touch or (kind == Enum.UserInputType.MouseButton1 and boardPrompt.ClickablePrompt) then
        heldInput, heldPrompt = input, boardPrompt
        boardPrompt:InputHoldBegin()
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if heldInput == input then
        releaseBoardInput()
    end
end)
UserInputService.WindowFocusReleased:Connect(releaseBoardInput)
registerBoardPrompts()

ProximityPromptService.PromptTriggered:Connect(function(prompt, who)
    if who == player and not panel.Visible and not race.Visible and not eagleEye:IsActive() and prompt.Name == "CityMapPrompt"
        and prompt:IsDescendantOf(city) then
        show("map", prompt.ObjectText)
    end
end)
remote.OnClientEvent:Connect(function(kind, a, b, c, d)
    if kind == "panel" then
        show(a)
    elseif kind == "started" then
        isPractice = a
        hide()
        flash("Follow the gold marker through each gate.")
    elseif kind == "finished" then
        if sparringActive or (sparResult and sparResult.Visible) then
            local title = if c then "Relay practice complete" else "Lantern Relay complete"
            local message = string.format("%s · %.1fs", title, a)
            if b then
                message ..= " · Lantern Keeper"
            end
            if d and d > 0 then
                message ..= " · " .. formatRewardXp(d)
            end
            flash(message)
        else
            show("finished", a, b, c, d)
        end
    elseif kind == "notice" then
        flash(a)
    elseif kind == "strike" then
        flash(a)
        local pad = typeof(b) == "Instance" and b:IsDescendantOf(city) and b:FindFirstChild("Target pad")
        if pad then
            local original = pad.Color
            pad.Color = palette.gold
            TweenService:Create(pad, TweenInfo.new(.32), {Color = original}):Play()
        end
    end
end)

local lastTick = 0
RunService.RenderStepped:Connect(function(dt)
    lastTick += dt
    if lastTick < .12 then
        return
    end
    lastTick = 0
    updateLocation()
    positionLocationHud()
    if cloudbreakStatus.Visible then
        updateCloudbreakText()
    end
    if not race.Visible then
        return
    end
    local deadline = player:GetAttribute("RelayDeadline") or 0
    local nextGate = player:GetAttribute("RelayNextGate") or 1
    local seconds = math.max(0, math.ceil(deadline - workspace:GetServerTimeNow()))
    progress.Text = string.format("%s  %d / %d     %d:%02d", isPractice and "Practice" or "Relay",
        nextGate, #gates:GetChildren(), math.floor(seconds/60), seconds%60)
end)

layout()
updateDisplay()
updateRace()
print("[Grand Dojo] Event board and personal trophy display ready.")

local sparBots = require(ReplicatedStorage:WaitForChild("SparringBots"))
local ringProgression = require(ReplicatedStorage:WaitForChild("RingProgression"))
local combatEffects = require(ReplicatedStorage:WaitForChild("CombatEffects"))
local combatAudio = require(ReplicatedStorage:WaitForChild("CombatAudio"))
local championshipHud = require(ReplicatedStorage:WaitForChild("ChampionshipHud")).new(gui, titleFont)
local championshipPortraits = require(ReplicatedStorage:WaitForChild("ChampionshipPortraits"))
local playerPortrait = championshipPortraits.new(championshipHud.leftPortrait, false, 12)
local opponentPortrait = championshipPortraits.new(championshipHud.rightPortrait, true, 12)
local duelRound = false
local fightIntro = require(ReplicatedStorage:WaitForChild("CombatIntro")).new(gui, player)
local matchPresentation = {showcase = false}
local showcaseKits = {
    reedguard = {challenger = "Reedguard Kangaroo", challengerShort = "Reedguard",
        techniqueAction = "uppercut", techniqueName = "Uppercut", techniqueLabel = "Uppercut",
        dodgeName = "Dodge", dodgeLabel = "Dodge", signatureName = "ReedstepRising", signatureLabel = "Rising"},
    penguin = {challenger = "Penguin Brawler", challengerShort = "Penguin",
        dodgeName = "FloeTurn", dodgeLabel = "Floe Turn", signatureName = "BellySlide", signatureLabel = "Belly Slide",
        signatureCooldown = "Slide %ds", tint = Color3.fromRGB(163, 216, 251)},
    silverback = {challenger = "Silverback Gorilla", challengerShort = "Silverback",
        techniqueAction = "secondary", techniqueName = "RidgePalm", techniqueLabel = "Ridge Palm",
        techniqueCooldown = "Ridge Palm\n%ds",
        dodgeName = "Dodge", dodgeLabel = "Dodge", signatureName = "SeismicChestPound", signatureLabel = "Seismic",
        signatureCooldown = "Seismic\n%ds", wideFighters = true, tint = Color3.fromRGB(230, 194, 138)},
    salamander = {challenger = "Fire Salamander", challengerShort = "Salamander",
        techniqueAction = "secondary", techniqueName = "EmberSweep", techniqueLabel = "Ember Sweep",
        techniqueCooldown = "Ember Sweep\n%ds",
        dodgeName = "Dodge", dodgeLabel = "Dodge", signatureName = "MagmaTrail", signatureLabel = "Magma Trail",
        signatureCooldown = "Magma Trail\n%ds", wideFighters = true, tint = Color3.fromRGB(255, 174, 109)},
}

local showcaseCourts = {
    ["grand-dojo"] = {"Fighting Ring"},
    cinder = {"Connected districts", "Cinder Terraces", "Cinder Terraces Ring"},
    ["cloud-top"] = {"Connected districts", "Skywalk Peaks", "Cloud-Top Temple"},
    galleon = {"Connected districts", "Tideharbor Coast", "Sunken Pirate Galleon", "Tideharbor practice ring"},
}
local function showcaseCourt(ringId)
    local path = showcaseCourts[ringId]
    if not path then
        return nil
    end
    local ring = city
    for _, name in path do
        ring = ring:FindFirstChild(name)
        if not ring then
            return nil
        end
    end
    return ring:FindFirstChild("Bot Spar Corner")
end

local function residentLabel(opponent)
    return opponent.name:match("^%S+") or opponent.name
end

sparPicker = make("Frame", gui, {
    Name = "SparringPicker", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.fromScale(.94, .91), BackgroundColor3 = palette.ink, BorderSizePixel = 0,
    Active = true, Visible = false,
})
make("UISizeConstraint", sparPicker, {MaxSize = Vector2.new(435, 238)})
style(sparPicker, 14, palette.edge)
local pickerHeading = label(sparPicker, "Heading", 20, palette.gold, titleFont)
pickerHeading.Position = UDim2.fromOffset(16, 9)
pickerHeading.Size = UDim2.new(1, -32, 0, 30)
pickerHeading.TextScaled = true
make("UITextSizeConstraint", pickerHeading, {MinTextSize = 15, MaxTextSize = 23})
local pickerName = label(sparPicker, "Resident", 19, palette.parchment, titleFont)
pickerName.Position = UDim2.fromOffset(16, 46)
pickerName.Size = UDim2.new(1, -32, 0, 28)
local pickerStats = label(sparPicker, "BotStats", 14, palette.muted, bodyFont)
pickerStats.Position = UDim2.fromOffset(16, 75)
pickerStats.Size = UDim2.new(1, -32, 0, 29)
pickerStats.TextWrapped = true
local pickerStatus = label(sparPicker, "Status", 14, palette.parchment, bodyFont)
pickerStatus.Position = UDim2.fromOffset(16, 110)
pickerStatus.Size = UDim2.new(1, -32, 1, -175)
pickerStatus.TextWrapped = true
local botStart = button(sparPicker, "Start Bot Spar", true)
botStart.Name = "StartBotSpar"
botStart.Position = UDim2.new(0, 16, 1, -54)
botStart.Size = UDim2.new(1, -128, 0, 42)
botStart.Selectable = true
local pickerClose = button(sparPicker, "Close", false)
pickerClose.Position = UDim2.new(1, -102, 1, -54)
pickerClose.Size = UDim2.fromOffset(86, 42)
pickerClose.Selectable = true
botStart.NextSelectionRight, pickerClose.NextSelectionLeft = pickerClose, botStart

local offerEndsAt
local function closePicker(cancel)
    if not sparPicker.Visible then
        return
    end
    sparPicker.Visible = false
    offerEndsAt = nil
    if cancel then
        sparRemote:FireServer("cancelChoice")
    end
    if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(sparPicker) then
        GuiService.SelectedObject = nil
    end
    restoreWorldPrompts()
    layout()
end
pickerClose.Activated:Connect(function() closePicker(true) end)
player.CharacterRemoving:Connect(function() closePicker(true) end)
botStart.Activated:Connect(function()
    if offerEndsAt and workspace:GetServerTimeNow() < offerEndsAt then
        sparRemote:FireServer("accept")
    end
end)

local sparHud, sparTitle, sparClock = championshipHud.root, championshipHud.title, championshipHud.clock
local playerHealth, botHealth, sparHint = championshipHud.left, championshipHud.right, championshipHud.hint
sparHud.Name, sparHud.Visible = "SparringHUD", false
duelUi.score = championshipHud.score
local function settleCombatHealth()
    playerHealth:Snap()
    botHealth:Snap()
end
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(settleCombatHealth)
UserInputService:GetPropertyChangedSignal("VREnabled"):Connect(settleCombatHealth)

local sparControls = make("Frame", gui, {
    Name = "SparringControls", AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, -64),
    Size = UDim2.new(.82, 0, 0, 48), BackgroundTransparency = 1, Visible = false,
})
local controlSize = make("UISizeConstraint", sparControls, {MaxSize = Vector2.new(394, 48)})
local strikeButton = button(sparControls, "Strike", true)
local function combatControl(parent, text)
    local control = button(parent, text, false)
    control.BackgroundColor3 = Color3.fromRGB(66, 38, 39)
    return control
end
local guardButton = combatControl(sparControls, "Guard")
local leaveButton = combatControl(sparControls, "Leave")
local combatButtons = {
    technique = combatControl(sparControls, "Uppercut"),
    heavy = combatControl(sparControls, "Heavy"),
    dodge = combatControl(sparControls, "Dodge"),
    signature = combatControl(sparControls, "Reedstep Rising"),
    exit = combatControl(gui, "Leave spar"),
}
combatButtons.signature.Name = "ReedstepRising"
combatButtons.exit.Name = "LeaveShowcaseSpar"
combatButtons.exit.AnchorPoint = Vector2.new(1, 0)
combatButtons.exit.Position = UDim2.new(1, -10, 0, 12)
combatButtons.exit.Size = UDim2.fromOffset(82, 44)
combatButtons.exit.TextSize = 13
combatButtons.exit.Visible = false

sparResult = make("Frame", gui, {
    Name = "SparringResult", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.new(.90, 0, 0, 161), BackgroundColor3 = palette.ink, BorderSizePixel = 0, Visible = false,
})
duelUi.resultLimit = make("UISizeConstraint", sparResult, {MaxSize = Vector2.new(416, 161)})
style(sparResult, 14, palette.edge)
local outcome = label(sparResult, "Result", 23, palette.gold, titleFont)
outcome.Position = UDim2.fromOffset(16, 14)
outcome.Size = UDim2.new(1, -32, 0, 28)
local winsDetail = label(sparResult, "Session wins", 14, palette.parchment, bodyFont)
winsDetail.Position = UDim2.fromOffset(16, 49)
winsDetail.Size = UDim2.new(1, -32, 0, 42)
winsDetail.TextWrapped = true
duelUi.rating = label(sparResult, "RatingStatus", 14, palette.gold, titleFont)
duelUi.rating.Position = UDim2.fromOffset(16, 93)
duelUi.rating.Size = UDim2.new(1, -32, 0, 44)
duelUi.rating.TextWrapped = true
duelUi.rating.Visible = false
local resultActions = make("Frame", sparResult, {
    Position = UDim2.new(0, 16, 1, -61), Size = UDim2.new(1, -32, 0, 46), BackgroundTransparency = 1,
})
local retryButton = button(resultActions, "Retry", true)
local exitButton = button(resultActions, "Close", false)
exitButton.Position = UDim2.new(.5, 4, 0, 0)

local outcomes = {
    win = "You won", draw = "Draw", left = "Spar ended", outside = "You stepped off the mat",
}
local cues = {
    blocked = "Blocked. Counter now!", parried = "Parried! Counter now!", hit = "You took a hit.",
    guard = "Guard up",
    counter = "Counter landed!", strike = "Strike landed.", miss = "Face your opponent and step closer.",
    dodged = "You evaded the strike.",
    stunned = "Your opponent parried. Reset your guard.",
    attackBlocked = "Your opponent blocked the strike.",
    attackParried = "Your opponent parried the strike.",
    jab = "Jab", cross = "Cross", body = "Body strike", heavy = "Heavy strike", uppercut = "Uppercut",
    reedstep = "Reedstep Rising", dodge = "Sidestep", brace = "Shell Set",
    floeTurn = "Floe Turn", bellySlide = "Belly-Slide Blitz",
    ridgePalm = "Ridge Palm", seismicChestPound = "Seismic Chest-Pound",
    emberSweep = "Ember Sweep", magmaTrail = "Magma Trail",
    projectileDeflected = "Projectile deflected!",
    gustPull = "Vortex pulls inward",
    needParry = "Parry a strike to unlock Rising.",
    ["Shell Set"] = "Shell Set · Wait out the brace",
    ["Kiln Rush"] = "Kiln Rush · Leave the lane",
    ["Wind Court Return"] = "Wind Court Return · Leave the line",
    ["Chime Crossstep"] = "Chime Crossstep · Track the fighter",
    ["Harbor Sweep"] = "Harbor Sweep · Leave the arc",
    ["Breakwater Stamp"] = "Breakwater Stamp · Leave the circle",
}
local cooldownCues = {
    slideCooling = {label = "Belly Slide", field = "nextSignature"},
    ridgeCooling = {label = "Ridge Palm", field = "nextSecondary"},
    seismicCooling = {label = "Seismic", field = "nextSignature"},
    emberCooling = {label = "Ember Sweep", field = "nextSecondary"},
    magmaCooling = {label = "Magma Trail", field = "nextSignature"},
}
local priorityCues = {
    uppercut = true, floeTurn = true, bellySlide = true, ridgePalm = true, seismicChestPound = true,
    emberSweep = true, magmaTrail = true, attackBlocked = true, attackParried = true, projectileDeflected = true,
    gustPull = true,
}
for _, fighter in fighterCatalog.ById do
    local combat = fighter.combat
    if combat then
        showcaseKits[combat.kit] = {
            challenger = fighter.name, challengerShort = fighter.shortName or fighter.name,
            techniqueAction = combat.techniqueAction, techniqueName = combat.techniqueName, techniqueLabel = combat.techniqueLabel,
            techniqueCooldown = combat.techniqueCooldown,
            dodgeName = "Dodge", dodgeLabel = "Dodge", signatureName = combat.signatureName,
            signatureLabel = combat.signatureLabel, signatureCooldown = combat.signatureCooldown, tint = Color3.fromHex(combat.tint),
        }
        if combat.techniqueCue then
            cues[combat.techniqueCue] = combat.technique
            priorityCues[combat.techniqueCue] = true
        end
        cues[combat.signatureCue], priorityCues[combat.signatureCue] = combat.signature, true
        if combat.techniqueCoolingCue then
            cooldownCues[combat.techniqueCoolingCue] = {label = combat.technique, field = "nextSecondary"}
        end
        if combat.signatureCoolingCue then
            cooldownCues[combat.signatureCoolingCue] = {label = combat.signature, field = "nextSignature"}
        end
    end
end

local resultAwaitingReward = false

local function closeResult()
    resultAwaitingReward = false
    duelUi.ratingMatchId = nil
    sparResult.Visible = false
    if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(sparResult) then
        GuiService.SelectedObject = nil
    end
    restoreWorldPrompts()
    layout()
end

local function cooldownSeconds(untilAt, now)
    return math.max(0, math.ceil((untilAt or 0) - now))
end

local function refreshSparControls(now)
    local keyboard = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
    local gamepad = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
    local kit = matchPresentation.kit or showcaseKits.reedguard
    strikeButton.Text = if keyboard then "Strike · E" elseif gamepad then "Strike · RT" else "Strike"
    guardButton.Text = if keyboard then "Guard · Q" elseif gamepad then "Guard · LT" else "Guard"
    leaveButton.Text = if keyboard then "Leave · C" elseif gamepad then "Leave · Y" else "Leave"
    local clock = now or workspace:GetServerTimeNow()
    local techniqueCooling = if kit.techniqueCooldown then cooldownSeconds(matchPresentation.nextSecondary, clock) else 0
    combatButtons.technique.TextWrapped = kit.techniqueCooldown ~= nil
    combatButtons.technique.Text = if techniqueCooling > 0 then string.format(kit.techniqueCooldown, techniqueCooling)
        else (kit.techniqueLabel or "Uppercut") .. (if keyboard then " · V" elseif gamepad then "\nD-pad ↑" else "")
    combatButtons.technique.TextColor3 = if techniqueCooling > 0 then palette.muted else palette.parchment
    combatButtons.heavy.Text = if keyboard then "Heavy · R" elseif gamepad then "Heavy · RB" else "Heavy"
    local separator = if kit.signatureCooldown then "\n" else " · "
    combatButtons.dodge.Text = kit.dodgeLabel .. (if keyboard then separator .. "X" elseif gamepad then separator .. "LB" else "")
    combatButtons.signature.TextWrapped = kit.signatureCooldown ~= nil
    local cooling = if kit.signatureCooldown then cooldownSeconds(matchPresentation.nextSignature, clock) else 0
    combatButtons.signature.Text = if cooling > 0 then string.format(kit.signatureCooldown, cooling)
        else kit.signatureLabel .. (if keyboard then separator .. "F" elseif gamepad then separator .. "Y" else "")
    combatButtons.signature.TextColor3 = if cooling > 0 then palette.muted else palette.parchment
    combatButtons.exit.Text = if keyboard then "Leave · C" elseif gamepad then "Leave · B" else "Leave"
end
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(refreshSparControls)
refreshSparControls()

layoutMatchControls = function()
    local showcase = matchPresentation.showcase
    local hasTechnique = showcase and matchPresentation.kit.techniqueAction ~= nil
    local ready = sparringActive and not matchPresentation.inIntro and matchPresentation.phase ~= "outro"
    sparControls.Visible = ready
    local touch = UserInputService.TouchEnabled
    local safe = gui.AbsoluteSize
    local compact = showcase and touch and safe.Y <= 430
    local stacked = showcase and safe.X < 504
    local rows = if stacked then 2 else 1
    local height = rows * 48 + (rows - 1) * 6
    championshipHud:Layout(safe.Y <= 430 or safe.X <= 570, duelUi.hasRounds(matchPresentation.format))
    local exitTop = if safe.X < 1240 and not matchPresentation.inIntro
        then sparHud.Position.Y.Offset + sparHud.Size.Y.Offset + 4 else 12
    controlSize.MaxSize = Vector2.new(if stacked then 328 elseif compact then 360 elseif showcase then 540 else 394, height)
    sparControls.Size = UDim2.new(if showcase then .94 else .82, 0, 0, height)
    -- On landscape phones the short bottom strip sits between the native thumb controls.
    local bottom = if compact and not stacked then 20 else 64
    if showcase and touch and (stacked or not compact) then
        bottom = math.clamp(math.round(safe.Y * .30), 90, 130)
    end
    if showcase then
        local reservedTop = math.max(122, exitTop + combatButtons.exit.Size.Y.Offset + 4)
        bottom = math.min(bottom, math.max(0, safe.Y - height - reservedTop))
    end
    sparControls.Position = UDim2.new(.5, 0, 1, -bottom)
    local controls = if showcase then {strikeButton, combatButtons.heavy, guardButton, combatButtons.dodge,
        combatButtons.signature} else {strikeButton, guardButton, leaveButton}
    if hasTechnique then
        table.insert(controls, 2, combatButtons.technique)
    end
    local columns = if stacked then 3 else #controls
    for index, control in controls do
        control.Position = UDim2.new(((index - 1) % columns) / columns, 0, 0, math.floor((index - 1) / columns) * 54)
        control.Size = UDim2.new(1 / columns, -4, 0, 48)
        control.TextSize = if compact then 12 elseif showcase then 13 else 14
    end
    leaveButton.Visible = not showcase
    combatButtons.technique.Visible = hasTechnique
    combatButtons.heavy.Visible = showcase
    combatButtons.dodge.Visible = showcase
    combatButtons.signature.Visible = showcase
    combatButtons.exit.Position = UDim2.new(1, -10, 0, exitTop)
    combatButtons.exit.Visible = showcase and sparringActive and matchPresentation.phase ~= "outro"
    sparHud.Visible = sparringActive and not matchPresentation.inIntro
end
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(layoutMatchControls)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutMatchControls)

local function sendSparAction(action)
    if not sparringActive or matchPresentation.phase == "outro" then
        return
    elseif action ~= "leave" and workspace:GetServerTimeNow() < (matchPresentation.startsAt or 0) then
        return
    elseif not matchPresentation.showcase and (action == "technique" or action == "heavy" or action == "dodge"
        or action == "signature") then
        return
    end
    if action == "technique" then
        action = matchPresentation.kit.techniqueAction
    end
    if not action then
        return
    end
    local direction
    if action == "dodge" or action == "secondary" then
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local left = root and humanoid and humanoid.MoveDirection:Dot(root.CFrame.RightVector) < -.2
        direction = if left then -1 else 1
    end
    local actionRemote = if duelRound then duelRemote else sparRemote
    if duelRound and duelUi.hasRounds(matchPresentation.format) then
        duelRemote:FireServer(action, direction, matchPresentation.matchId, matchPresentation.roundIndex)
    elseif direction then
        actionRemote:FireServer(action, direction)
    else
        actionRemote:FireServer(action)
    end
end
strikeButton.Activated:Connect(function() sendSparAction("strike") end)
guardButton.Activated:Connect(function() sendSparAction("guard") end)
leaveButton.Activated:Connect(function() sendSparAction("leave") end)
combatButtons.exit.Activated:Connect(function() sendSparAction("leave") end)
for _, action in {"technique", "heavy", "dodge", "signature"} do
    combatButtons[action].Activated:Connect(function() sendSparAction(action) end)
end
retryButton.Activated:Connect(function() sparRemote:FireServer("retry") end)
exitButton.Activated:Connect(closeResult)
local sparKeys = {
    [Enum.KeyCode.E] = "strike", [Enum.KeyCode.ButtonX] = "strike", [Enum.KeyCode.ButtonR2] = "strike",
    [Enum.KeyCode.Q] = "guard", [Enum.KeyCode.ButtonL2] = "guard",
    [Enum.KeyCode.C] = "leave", [Enum.KeyCode.ButtonY] = "leave",
}
local showcaseKeys = {
    [Enum.KeyCode.V] = "technique", [Enum.KeyCode.DPadUp] = "technique",
    [Enum.KeyCode.R] = "heavy", [Enum.KeyCode.ButtonR1] = "heavy",
    [Enum.KeyCode.X] = "dodge", [Enum.KeyCode.ButtonL1] = "dodge",
    [Enum.KeyCode.F] = "signature", [Enum.KeyCode.ButtonY] = "signature",
    [Enum.KeyCode.ButtonB] = "leave",
}
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() then
        return
    end
    local back = input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Backspace
    if duelUi.picker and duelUi.picker.Visible then
        if back then
            duelUi.close(true)
        elseif input.KeyCode == Enum.KeyCode.One then
            duelUi.join("casual")
        elseif input.KeyCode == Enum.KeyCode.Two then
            duelUi.join("series")
        elseif input.KeyCode == Enum.KeyCode.Three then
            duelUi.join("ranked")
        end
    elseif sparPicker.Visible and input.KeyCode == Enum.KeyCode.ButtonB then
        closePicker(true)
    elseif sparringActive then
        local action = if matchPresentation.showcase then showcaseKeys[input.KeyCode] or sparKeys[input.KeyCode]
            else sparKeys[input.KeyCode]
        if action then
            sendSparAction(action)
        end
    elseif sparResult.Visible and input.KeyCode == Enum.KeyCode.ButtonB then
        closeResult()
    elseif back and duelUi.queue and duelUi.queue.Visible then
        duelRemote:FireServer("cancel")
    end
end)

local function showMatchHud(isDuel, title, startsAt, introAt, ringId, opponent, kitId, nextSignature, nextSecondary)
    duelRound = isDuel
    sparringActive = true
    matchPresentation.startsAt = startsAt
    matchPresentation.phase = nil
    matchPresentation.finishedAt = nil
    matchPresentation.showcase = type(introAt) == "number"
    matchPresentation.format = if isDuel and opponent then opponent.format else nil
    matchPresentation.matchId = if isDuel and opponent then opponent.matchId else nil
    matchPresentation.roundIndex = if isDuel and opponent then opponent.roundIndex else nil
    matchPresentation.roundResult = nil
    local kit = if matchPresentation.showcase then showcaseKits[kitId] or showcaseKits.reedguard else nil
    matchPresentation.kit = kit
    matchPresentation.nextSignature = if type(nextSignature) == "number" then nextSignature else nil
    matchPresentation.nextSecondary = if type(nextSecondary) == "number" then nextSecondary else nil
    combatButtons.technique.Name = kit and kit.techniqueName or "Uppercut"
    combatButtons.dodge.Name = kit and kit.dodgeName or "Dodge"
    combatButtons.signature.Name = kit and kit.signatureName or "ReedstepRising"
    if kit then
        combatEffects.prepare()
        combatAudio.prepare()
        combatAudio.resetCountdown()
    end
    matchPresentation.inIntro = matchPresentation.showcase and workspace:GetServerTimeNow() < startsAt
    closePicker(false)
    closeResult()
    hide()
    sparTitle.Text = title
    championshipPortraits.set(playerPortrait, kitId)
    championshipPortraits.set(opponentPortrait, opponent and (if isDuel then opponent.opponentKitId else opponent.name))
    refreshSparControls()
    layoutMatchControls()
    if kit then
        local deckView = ringId == "galleon"
        local opponentKit = if isDuel then showcaseKits[opponent.opponentKitId] else nil
        local opponentName = if isDuel then opponent.opponentName else opponent.name
        local opponentShort = if isDuel then (opponentKit and opponentKit.challengerShort or opponentName)
            else residentLabel(opponent)
        local intro = {
            ring = title, challenger = kit.challenger, challengerShort = kit.challengerShort,
            resident = opponentName, residentShort = opponentShort,
            challengerTint = kit.tint, residentTint = if isDuel then opponentKit and opponentKit.tint else opponent.tint,
            wideFighters = kit.wideFighters or (opponentKit and opponentKit.wideFighters)
                or deckView or ringId == "cloud-top",
            deckView = deckView, duel = isDuel,
        }
        local court
        if isDuel then
            local ring = city:FindFirstChild("Fighting Ring")
            court = ring and ring:FindFirstChild("Duel Court")
            intro.sideIndex, intro.opponentUserId = opponent.sideIndex, opponent.opponentUserId
            intro.opponentFighter = opponentKit and opponentKit.challenger
            if duelUi.hasRounds(matchPresentation.format) then
                intro.roundIndex = opponent.roundIndex
                intro.quickRound = (opponent.roundIndex or 1) > 1
            end
        else
            court = showcaseCourt(ringId)
        end
        fightIntro:Start(introAt, startsAt, court, intro, function()
            matchPresentation.inIntro = false
            refreshSparControls()
            layoutMatchControls()
        end)
    else
        fightIntro:Stop()
    end
    layout()
end

local function matchClock(startsAt, endsAt, phase)
    local now = workspace:GetServerTimeNow()
    if phase == "outro" and not matchPresentation.finishedAt then
        matchPresentation.finishedAt = now
    end
    local seconds = math.max(0, math.ceil(endsAt - math.max(matchPresentation.finishedAt or now, startsAt)))
    sparClock.Text = tostring(seconds)
    return now
end

local function updateMatchTimeline(startsAt, endsAt, phase, feedback, tell, attackAt, parryOpensAt,
    nextSignature, nextSecondary, opponentTint, braceName, elementEffect)
    if phase ~= matchPresentation.phase then
        matchPresentation.phase = phase
        layoutMatchControls()
    end
    local now = matchClock(startsAt, endsAt, phase)
    local kit = matchPresentation.kit
    if kit then
        combatAudio.countdown(startsAt - now)
    end
    if kit and kit.signatureCooldown then
        matchPresentation.nextSignature = if type(nextSignature) == "number" then nextSignature else nil
        matchPresentation.nextSecondary = if type(nextSecondary) == "number" then nextSecondary else nil
        refreshSparControls(now)
    end
    local cooldownCue = cooldownCues[feedback]
    local parryCue = parryOpensAt ~= nil and attackAt ~= nil and now >= parryOpensAt and now <= attackAt
    sparHint.TextColor3 = if parryCue or feedback == "parried" then Color3.fromRGB(148, 223, 233)
        elseif phase == "windup" or phase == "setup" then opponentTint or palette.gold else palette.parchment
    if phase == "outro" then
        local roundResult = matchPresentation.roundResult
        sparHint.Text = if playerHealth.ratio == 0 or botHealth.ratio == 0 then "Knockout"
            elseif roundResult == "win" then "You won the round" elseif roundResult == "loss" then "Opponent won the round"
            elseif roundResult == "draw" then "Round drawn" else "Round ended"
    elseif now < startsAt then
        sparHint.Text = string.format("Starting in %d", math.ceil(startsAt - now))
    elseif matchPresentation.showcase and feedback == "parried" then
        sparHint.Text = if kit == showcaseKits.reedguard then "Parried! Use Rising now." else cues.parried
    elseif not parryCue and priorityCues[feedback] then
        sparHint.Text = cues[feedback]
    elseif not parryCue and cooldownCue then
        local cooling = cooldownSeconds(matchPresentation[cooldownCue.field], now)
        sparHint.Text = if cooling > 0 then string.format("%s ready in %ds", cooldownCue.label, cooling)
            else cooldownCue.label .. " ready"
    elseif phase == "windup" then
        sparHint.Text = if feedback == "guard" then "Guard up"
            elseif parryCue then "Guard now to parry!"
            else cues[tell] or ((tell or "Incoming strike") .. " · Watch the mat")
    elseif phase == "setup" and not feedback then
        sparHint.Text = cues[tell] or tell or "Watch your opponent’s stance"
    elseif feedback == "braced" and braceName then
        sparHint.Text = "You struck into " .. braceName .. "’s brace."
    elseif elementEffect == "edge" or elementEffect == "resist" then
        sparHint.Text = if elementEffect == "edge" then "Element edge!" else "Element resisted"
    elseif feedback and cues[feedback] then
        sparHint.Text = cues[feedback]
    elseif phase == "recovery" then
        sparHint.Text = "Opponent recovering. Counter now!"
    else
        sparHint.Text = "Face your opponent and move within reach."
    end
end

local function showMatchResult(result, opponent, detail, showRetry, ratingMatchId)
    fightIntro:Stop()
    settleCombatHealth()
    championshipPortraits.set(playerPortrait, nil)
    championshipPortraits.set(opponentPortrait, nil)
    matchPresentation.inIntro = false
    sparringActive = false
    layoutMatchControls()
    outcome.Text = if result == "loss" and opponent then opponent .. " won" else (outcomes[result] or "Spar ended")
    outcome.TextTruncate = Enum.TextTruncate.AtEnd
    winsDetail.Text = detail
    duelUi.ratingMatchId = ratingMatchId
    duelUi.rating.Visible = ratingMatchId ~= nil
    duelUi.rating.Text = if ratingMatchId then "Saving Rank Points…" else ""
    local resultHeight = if ratingMatchId then 207 else 161
    sparResult.Size = UDim2.new(.90, 0, 0, resultHeight)
    duelUi.resultLimit.MaxSize = Vector2.new(416, resultHeight)
    retryButton.Visible = showRetry
    retryButton.Active = showRetry and not resultAwaitingReward
    retryButton.Text = if resultAwaitingReward then "Saving XP…" else "Retry"
    sparResult.Visible = true
    ProximityPromptService.Enabled = false
    layout()
    if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
        GuiService.SelectedObject = if showRetry then retryButton else exitButton
    end
end

local function clearInterruptedMatch()
    fightIntro:Stop()
    if sparringActive then
        settleCombatHealth()
        championshipPortraits.set(playerPortrait, nil)
        championshipPortraits.set(opponentPortrait, nil)
        matchPresentation.inIntro = false
        sparringActive = false
        restoreWorldPrompts()
        layoutMatchControls()
        layout()
    end
end
player.CharacterRemoving:Connect(clearInterruptedMatch)
player:GetAttributeChangedSignal("SparringActive"):Connect(function()
    if not player:GetAttribute("SparringActive") then
        clearInterruptedMatch()
    end
end)

sparRemote.OnClientEvent:Connect(function(kind, a, b, startsAt, endsAt, phase, feedback, botAt, parryOpensAt,
    id, playerMaxHealth, ringId, tell, introAt, kitId, nextSignature, nextSecondary)
    if kind == "impact" then
        combatEffects.play(a, b, startsAt)
        if endsAt ~= true then
            combatAudio.impact(a, b, startsAt)
        end
        return
    elseif kind == "combatAudio" then
        combatAudio.impact(a, b, startsAt)
        return
    elseif kind == "offer" then
        if duelUi.picker and duelUi.picker.Visible then
            return
        end
        local ring = ringProgression.ById[a]
        local opponent = ring and sparBots[ring.botId]
        if not opponent then
            return
        end
        closeResult()
        hide()
        offerEndsAt = if startsAt then b else nil
        pickerHeading.Text = ring.name
        pickerHeading.TextColor3 = opponent.tint
        pickerName.Text = opponent.name
        pickerStats.Text = string.format("%d HP · %s", opponent.health, opponent.style)
        pickerStatus.Text = endsAt
        botStart.Visible = startsAt
        sparPicker.Visible = true
        ProximityPromptService.Enabled = false
        layout()
        if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
            GuiService.SelectedObject = if startsAt then botStart else pickerClose
        end
        task.delay(math.max(0, b - workspace:GetServerTimeNow()), function()
            if offerEndsAt == b and sparPicker.Visible then
                offerEndsAt = nil
                botStart.Visible = false
                pickerStatus.Text = "Use the local Bot Spar sign to reopen."
            end
        end)
        return
    end
    if kind == "notice" or kind == "reward" or kind == "rewardPending" then
        local message = a
        if kind == "reward" then
            message = if a > 0 then (if b then "First spar win · " else "Spar win · ") .. formatRewardXp(a)
                else "Spar result saved."
        end
        if sparPicker.Visible and kind == "notice" then
            pickerStatus.Text = message
        elseif sparResult.Visible and (kind == "notice" or resultAwaitingReward) then
            winsDetail.Text = message
            if kind == "reward" then
                resultAwaitingReward = false
                retryButton.Active = retryButton.Visible
                retryButton.Text = "Retry"
            end
        else
            flash(message)
        end
        return
    end
    if kind == "result" then
        local opponent = sparBots[endsAt]
        resultAwaitingReward = startsAt == true
        showMatchResult(a, opponent and opponent.name, if resultAwaitingReward then "Saving your spar XP…"
            else string.format("Bot Spar wins this session  %d", b), true)
        return
    end
    local opponent = sparBots[id]
    if not opponent then
        return
    elseif kind == "begin" then
        showMatchHud(false, ringProgression.ById[ringId].name, startsAt, introAt, ringId, opponent, kitId,
            nextSignature, nextSecondary)
    elseif kind ~= "state" or not sparringActive or duelRound then
        return
    end
    local showcase = matchPresentation.showcase
    local kit = matchPresentation.kit
    local resident = residentLabel(opponent)
    local shortName = if showcase then resident else opponent.name
    playerHealth:Set(a, playerMaxHealth, kit and kit.challengerShort, kind == "begin")
    botHealth:Set(b, opponent.health, shortName, kind == "begin")
    updateMatchTimeline(startsAt, endsAt, phase, feedback, tell, botAt, parryOpensAt,
        nextSignature, nextSecondary, opponent.tint, resident)
end)

do
    local queue = button(gui, "Leave Duel Queue", false)
    queue.Name = "LeaveDuelQueue"
    queue.AnchorPoint = Vector2.new(.5, 1)
    queue.Position, queue.Size = UDim2.new(.5, 0, 1, -64), UDim2.new(.92, 0, 0, 48)
    queue.TextSize, queue.Visible = 14, false
    make("UISizeConstraint", queue, {MaxSize = Vector2.new(258, 48)})
    queue.Activated:Connect(function() duelRemote:FireServer("cancel") end)
    duelUi.queue = queue

    local picker = make("Frame", gui, {
        Name = "DuelFormatPicker", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.new(.94, 0, 0, 243), BackgroundColor3 = palette.ink, BorderSizePixel = 0,
        Active = true, Visible = false,
    })
    make("UISizeConstraint", picker, {MaxSize = Vector2.new(444, 243)})
    style(picker, 14, palette.edge)
    local heading = label(picker, "Heading", 21, palette.gold, titleFont)
    heading.Position, heading.Size = UDim2.fromOffset(16, 8), UDim2.new(1, -32, 0, 32)
    heading.Text = "Grand Dojo Duel"

    local function formatOption(name, title, description, x, tone)
        local control = button(picker, "", false)
        control.Name = name
        control.Position, control.Size = UDim2.new(x, if x == 0 then 16 else 4, 0, 46), UDim2.new(.5, -20, 0, 62)
        local caption = label(control, "Format", 17, tone, titleFont)
        caption.Position, caption.Size = UDim2.fromOffset(11, 6), UDim2.new(1, -22, 0, 23)
        caption.Text = title
        local detail = label(control, "Rules", 12, palette.muted)
        detail.Position, detail.Size = UDim2.fromOffset(11, 27), UDim2.new(1, -22, 0, 27)
        detail.Text, detail.TextWrapped = description, true
        return control, detail
    end

    local casual = formatOption("Casual", "Casual", "One 60s round", 0, palette.parchment)
    local series = formatOption("BestOfThree", "Best of 3", "45s rounds · First to 2", .5, palette.gold)
    local ranked, rankedRules = formatOption("Ranked", "Ranked", "Best of 3 · Fixed Level 15", 0, palette.gold)
    ranked.Position, ranked.Size = UDim2.fromOffset(16, 116), UDim2.new(1, -32, 0, 66)
    rankedRules.Position, rankedRules.Size = UDim2.fromOffset(11, 26), UDim2.new(1, -22, 0, 15)
    local rankStatus = label(ranked, "RankStatus", 13, palette.parchment, titleFont)
    rankStatus.Position, rankStatus.Size = UDim2.fromOffset(11, 42), UDim2.new(1, -22, 0, 18)
    rankStatus.TextTruncate = Enum.TextTruncate.AtEnd

    local function refreshRankStatus()
        local status = player:GetAttribute("DuelRankStatus")
        local points = player:GetAttribute("DuelRankPoints")
        local division = player:GetAttribute("DuelRankDivision")
        if status == "ready" and type(points) == "number" then
            local prefix = if type(division) == "string" then division .. " · " else ""
            rankStatus.Text = string.format("%s%d Rank Points", prefix, points)
        elseif status == "loading" then
            rankStatus.Text = "Loading Rank Points…"
        elseif status == "pending" then
            rankStatus.Text = "Rank save pending"
        elseif status == "unavailable" then
            rankStatus.Text = "Rank Points unavailable"
        else
            rankStatus.Text = "Rank Points load when you choose Ranked"
        end
    end
    local closeChoice = button(picker, "Close", false)
    closeChoice.Position, closeChoice.Size = UDim2.new(1, -130, 1, -57), UDim2.fromOffset(114, 48)
    closeChoice.TextSize = 15
    local keys = label(picker, "KeyboardHelp", 12, palette.muted)
    keys.Position, keys.Size = UDim2.new(0, 16, 1, -48), UDim2.new(1, -154, 0, 30)
    keys.Text = "1, 2 or 3 to choose"
    casual.NextSelectionRight, series.NextSelectionLeft = series, casual
    casual.NextSelectionDown, series.NextSelectionDown = ranked, ranked
    ranked.NextSelectionUp, ranked.NextSelectionDown = casual, closeChoice
    closeChoice.NextSelectionUp = ranked
    duelUi.picker = picker

    function duelUi.close(cancelOffer)
        if not picker.Visible then
            return
        end
        duelUi.expiresAt = nil
        picker.Visible = false
        if cancelOffer then
            duelRemote:FireServer("cancel")
        end
        if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(picker) then
            GuiService.SelectedObject = nil
        end
        restoreWorldPrompts()
        layout()
    end

    local function focusPicker()
        keys.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
        if picker.Visible and UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
            GuiService.SelectedObject = casual
        end
    end

    function duelUi.open(expiresAt)
        duelUi.expiresAt = expiresAt
        refreshRankStatus()
        picker.Visible = true
        restoreWorldPrompts()
        layout()
        focusPicker()
        task.delay(math.max(0, expiresAt - workspace:GetServerTimeNow()), function()
            if duelUi.expiresAt == expiresAt then
                duelUi.close(false)
            end
        end)
    end

    function duelUi.join(format)
        if picker.Visible and duelUi.expiresAt and workspace:GetServerTimeNow() < duelUi.expiresAt then
            duelUi.close(false)
            duelRemote:FireServer("join", format)
        end
    end

    casual.Activated:Connect(function() duelUi.join("casual") end)
    series.Activated:Connect(function() duelUi.join("series") end)
    ranked.Activated:Connect(function() duelUi.join("ranked") end)
    closeChoice.Activated:Connect(function() duelUi.close(true) end)
    focusPicker()
    for _, attribute in {"DuelRankStatus", "DuelRankPoints", "DuelRankDivision"} do
        player:GetAttributeChangedSignal(attribute):Connect(refreshRankStatus)
    end
    UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(focusPicker)
    player.CharacterRemoving:Connect(function() duelUi.close(true) end)
end

duelRemote.OnClientEvent:Connect(function(kind, info)
    if kind == "notice" then
        flash(info)
    elseif kind == "offer" then
        if not sparringActive and not groupCombatUiOpen() and not sparPicker.Visible and not panel.Visible and not race.Visible
            and not player:GetAttribute("StarterSelectionRequired") and not player:GetAttribute("FighterSelectOpen")
            and type(info.expiresAt) == "number" and info.expiresAt > workspace:GetServerTimeNow() then
            closeResult()
            duelUi.open(info.expiresAt)
        end
    elseif kind == "offerClosed" then
        if type(info) ~= "table" or info.expiresAt == nil or duelUi.expiresAt == info.expiresAt then
            duelUi.close(false)
        end
    elseif kind == "queue" then
        duelUi.close(false)
        duelUi.queued = info.queued
        duelUi.queue.Text = if info.format == "ranked" then "Waiting for Ranked · Leave"
            elseif info.format == "series" then "Waiting for Best of 3 · Leave" else "Waiting for Casual · Leave"
        layout()
        if info.message then
            flash(info.message)
        end
    elseif kind == "rating" then
        local matchId = info.matchId
        local previous = duelUi.pendingRatings[matchId]
        if not previous or previous == info.status then
            return
        end
        local detailText
        if info.status == "saved" and type(info.after) == "number" and type(info.delta) == "number" then
            local prefix = if type(info.division) == "string" then info.division .. " · " else ""
            local points = string.format("%s%d Rank Points", prefix, info.after)
            local change = if info.delta == 0 then "No change" else string.format("%+d this duel", info.delta)
            detailText = points .. "\n" .. change
        elseif info.status == "pending" then
            detailText = "Rank save pending"
        elseif info.status == "unavailable" then
            detailText = "Rank save still unconfirmed"
        else
            return
        end
        duelUi.pendingRatings[matchId] = if info.status == "pending" then "pending" else nil
        if sparResult.Visible and duelUi.ratingMatchId == matchId then
            duelUi.rating.Text = detailText
        else
            flash((detailText:gsub("\n", " · ")))
        end
    elseif kind == "result" then
        if duelUi.hasRounds(info.format) and info.matchId ~= matchPresentation.matchId then
            return
        end
        resultAwaitingReward = false
        local detailText = info.message or "Grand Dojo Duel"
        if duelUi.hasRounds(info.format) then
            detailText ..= string.format("\nRounds %d–%d", info.playerRounds, info.opponentRounds)
        end
        local ratingMatchId = if info.format == "ranked" and info.ratingPending then info.matchId else nil
        if ratingMatchId then
            duelUi.pendingRatings[ratingMatchId] = "waiting"
        end
        showMatchResult(info.result, info.opponentName, detailText, false, ratingMatchId)
        matchPresentation.matchId = nil
    elseif kind == "begin" or ((kind == "update" or kind == "round") and sparringActive and duelRound) then
        local series = duelUi.hasRounds(info.format)
        local reset = kind ~= "update"
        if kind ~= "begin" and duelUi.hasRounds(matchPresentation.format) then
            local expected = matchPresentation.roundIndex + (if kind == "round" then 1 else 0)
            if info.format ~= matchPresentation.format or info.matchId ~= matchPresentation.matchId or info.roundIndex ~= expected then
                return
            end
        end
        if reset then
            duelUi.close(false)
            duelUi.queued = false
            local title = if info.format == "ranked" then "Ranked Duel" elseif series then "Best of 3 Duel" else "Grand Dojo Duel"
            showMatchHud(true, title, info.startsAt, info.introAt,
                "grand-dojo", info, info.kitId, info.nextSignature, info.nextSecondary)
        end
        if series then
            duelUi.score.Text = string.format("Round %d/%d · %d–%d", info.roundIndex, info.maxRounds,
                info.playerRounds, info.opponentRounds)
            matchPresentation.roundResult = info.roundResult
        end
        local kit = matchPresentation.kit
        local opponent = showcaseKits[info.opponentKitId]
        playerHealth:Set(info.playerHealth, info.playerMaxHealth, kit and kit.challengerShort, reset)
        botHealth:Set(info.opponentHealth, info.opponentMaxHealth, opponent and opponent.challengerShort or info.opponentName, reset)
        if matchPresentation.showcase then
            updateMatchTimeline(info.startsAt, info.endsAt, info.phase, info.feedback, info.tell, info.attackAt,
                info.parryOpensAt, info.nextSignature, info.nextSecondary, opponent and opponent.tint, nil,
                if info.format == "ranked" then info.elementEffect else nil)
        else
            local now = matchClock(info.startsAt, info.endsAt, info.phase)
            sparHint.TextColor3 = if info.phase == "windup" then palette.gold else palette.parchment
            sparHint.Text = if now < info.startsAt then string.format("Starting in %d", math.ceil(info.startsAt - now))
                elseif info.feedback then cues[info.feedback] or info.feedback
                elseif info.phase == "windup" then "Incoming strike · Guard or step away"
                else "Face your opponent and move within reach."
        end
    end
end)

local function syncGroupCombatUi()
    if groupCombatUiOpen() then
        duelUi.close(false)
        closePicker(false)
        closeResult()
        hide()
    end
    restoreWorldPrompts()
    layout()
end
for _, attribute in {"BrawlActive", "BrawlRecapOpen", "TagTeamActive", "TagTeamOfferOpen", "TagTeamRecapOpen",
    "KilnbackRaidActive", "KilnbackRaidRecapOpen"} do
    player:GetAttributeChangedSignal(attribute):Connect(syncGroupCombatUi)
end
