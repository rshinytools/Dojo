local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OutfitArt = require(ReplicatedStorage:WaitForChild("DojoOutfitArt"))

local COSMETIC_ID = "cloudbreak-summit-sash"
local COSMETIC_ATTRIBUTE = "CloudbreakCosmetic"
local EQUIPPED_ATTRIBUTE = "CloudbreakSashEquipped"
local MARKET_ATTRIBUTE = "DojoMarketSashEquipped"
local SHELL_NAME = "Starter Fighter Shell"
local SASH_NAME = "Cloudbreak Summit Sash"
local MARKET_SASH_NAME = "Jade Festival Sash"
local watches = {}

local indigo = Color3.fromRGB(56, 66, 109)
local brass = Color3.fromRGB(224, 177, 95)
local wind = Color3.fromRGB(183, 233, 219)

local function makeSash(torso, art, artFrame, style)
    -- Mount beside the fighter shell so the sash cannot change contact or defeat bounds.
    local sash = Instance.new("Model")
    sash.Name = style
    local center, width, height, front = OutfitArt.fit(art, artFrame)

    local function piece(name, localFrame, size, color, material)
        local part = Instance.new("Part")
        part.Name, part.Size, part.Color, part.Material = name, size, color, material
        part.CFrame = torso.CFrame * localFrame
        part.Anchored, part.RootPriority = false, -127
        part.Massless, part.CanCollide, part.CanQuery, part.CanTouch, part.CastShadow = true, false, false, false, false
        local weld = Instance.new("WeldConstraint")
        weld.Part0, weld.Part1 = torso, part
        weld.Parent, part.Parent = part, sash
    end

    if style == OutfitArt.Name then
        OutfitArt.build(piece, center, width, height, front)
        return sash
    end
    if style == MARKET_SASH_NAME then
        -- An offset waist wrap leaves the Cloudbreak shoulder strap and left pennant visible.
        OutfitArt.buildJade(piece, center, width, height, front)
        return sash
    end

    local shoulder = Vector3.new(center.X + width * .47, center.Y + height * .57, front)
    local hip = Vector3.new(center.X - width * .52, center.Y - height * .22, front)
    local across = shoulder - hip
    local stripe = CFrame.new((shoulder + hip) * .5) * CFrame.Angles(0, 0, math.atan2(-across.X, across.Y))
    local panelWidth = math.clamp(width * .47, .32, .49)
    local panelLength = math.clamp(height * .64, .49, .75)
    local panel = CFrame.new(hip + Vector3.new(-.025, -panelLength * .46, -.018)) * CFrame.Angles(0, 0, -.14)

    piece("Gold selvage", stripe, Vector3.new(.25, across.Magnitude + .10, .09), brass, Enum.Material.Fabric)
    piece("Indigo cross strap", stripe + Vector3.new(0, 0, -.033),
        Vector3.new(.17, across.Magnitude + .075, .055), indigo, Enum.Material.Fabric)
    piece("Summit pennant", panel, Vector3.new(panelWidth, panelLength, .09), indigo, Enum.Material.Fabric)
    piece("Pennant hem", panel * CFrame.new(0, -panelLength / 2 + .033, -.028),
        Vector3.new(panelWidth, .065, .045), brass, Enum.Material.Fabric)
    piece("Cloth knot", CFrame.new(hip + Vector3.new(0, 0, -.065)) * CFrame.Angles(0, 0, .33),
        Vector3.new(.25, .24, .12), brass, Enum.Material.Fabric)
    for index, length in {.62, .46, .29} do
        piece("Wind stitch", panel * CFrame.new((index - 2) * .027, .12 - index * .086, -.049),
            Vector3.new(panelWidth * length, .037, .019), wind, Enum.Material.Fabric)
    end
    return sash
end

local function watch(player)
    if watches[player] or player.Parent ~= Players then
        return
    end
    local playerConnections, characterConnections = {}, {}
    local active, queued = true, false
    local character, mountedArt
    local mounted = {}

    local function removeSashes()
        for name, sash in mounted do
            sash:Destroy()
            mounted[name] = nil
        end
        mountedArt = nil
    end

    local function refresh()
        local summit = player:GetAttribute(COSMETIC_ATTRIBUTE) == COSMETIC_ID
            and player:GetAttribute(EQUIPPED_ATTRIBUTE) ~= false
        local market = player:GetAttribute(MARKET_ATTRIBUTE) == true
        local premium = player:GetAttribute("DojoBundleOwnership") == "owned"
            and player:GetAttribute("DojoBundleSelected") == true
        if not character or character ~= player.Character or not (summit or market or premium) then
            removeSashes()
            return
        end
        local torso = character:FindFirstChild("Torso")
        local shell = character:FindFirstChild(SHELL_NAME)
        local art = shell and shell:FindFirstChild("Torso")
        local weld = art and art:IsA("BasePart") and art:FindFirstChildOfClass("Weld")
        if not (torso and torso:IsA("BasePart") and weld and weld.Part0 == torso and weld.Part1 == art) then
            removeSashes()
            return
        end
        if mountedArt ~= art then
            removeSashes()
            mountedArt = art
        end
        for name, visible in {[SASH_NAME] = summit, [MARKET_SASH_NAME] = market, [OutfitArt.Name] = premium} do
            local sash = mounted[name]
            if sash and (not visible or sash.Parent ~= character) then
                sash:Destroy()
                mounted[name] = nil
            end
            if visible and not mounted[name] then
                local newSash = makeSash(torso, art, weld.C0 * weld.C1:Inverse(), name)
                mounted[name], newSash.Parent = newSash, character
            end
        end
    end

    local function schedule()
        if not active or queued then
            return
        end
        queued = true
        task.defer(function()
            queued = false
            if active then
                refresh()
            end
        end)
    end

    local function bindCharacter(nextCharacter)
        for _, connection in characterConnections do
            connection:Disconnect()
        end
        table.clear(characterConnections)
        removeSashes()
        character = nextCharacter
        if not character then
            return
        end
        local function shellChanged(child)
            if child.Name == SHELL_NAME or child.Name == "Torso" then
                schedule()
            end
        end
        characterConnections[1] = character.ChildAdded:Connect(shellChanged)
        characterConnections[2] = character.ChildRemoved:Connect(shellChanged)
        schedule()
    end

    playerConnections[1] = player:GetAttributeChangedSignal(COSMETIC_ATTRIBUTE):Connect(schedule)
    playerConnections[2] = player:GetAttributeChangedSignal(EQUIPPED_ATTRIBUTE):Connect(schedule)
    playerConnections[5] = player:GetAttributeChangedSignal(MARKET_ATTRIBUTE):Connect(schedule)
    playerConnections[6] = player:GetAttributeChangedSignal("DojoBundleOwnership"):Connect(schedule)
    playerConnections[7] = player:GetAttributeChangedSignal("DojoBundleSelected"):Connect(schedule)
    playerConnections[3] = player.CharacterAdded:Connect(bindCharacter)
    playerConnections[4] = player.CharacterRemoving:Connect(function(oldCharacter)
        if character == oldCharacter then
            bindCharacter(nil)
        end
    end)
    watches[player] = function()
        active = false
        for _, connection in playerConnections do
            connection:Disconnect()
        end
        bindCharacter(nil)
    end
    bindCharacter(player.Character)
end

Players.PlayerAdded:Connect(watch)
Players.PlayerRemoving:Connect(function(player)
    local stop = watches[player]
    if stop then
        watches[player] = nil
        stop()
    end
end)
for _, player in Players:GetPlayers() do
    watch(player)
end
