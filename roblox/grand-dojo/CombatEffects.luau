-- Uses the circular hit and parry ring textures from Artinex2's licensed
-- RPG & Combat Effects Pack. Timing, size, and color are authored for Beast Dojo.
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Marks = require(script.Parent.CombatContactMarks)

local CombatEffects = {}
local hitTexture = "rbxassetid://18140248952"
local parryTexture = "rbxassetid://126034245450101"
local tint = {
    strike = Color3.fromRGB(255, 211, 124),
    counter = Color3.fromRGB(255, 229, 146),
    hit = Color3.fromRGB(255, 170, 117),
    parried = Color3.fromRGB(139, 235, 255),
    blocked = Color3.fromRGB(183, 215, 210),
    deflected = Color3.fromRGB(173, 247, 122),
    gustPull = Color3.fromRGB(198, 211, 255),
    diveKick = Color3.fromRGB(255, 152, 105),
    snared = Color3.fromRGB(255, 166, 103),
    braced = Color3.fromRGB(174, 211, 180),
    guardBroken = Color3.fromRGB(255, 161, 120),
    burst = Color3.fromRGB(255, 143, 75),
}
local groundPulses = {
    seismicChestPound = {name = "Seismic contact pulse", color = Color3.fromRGB(255, 183, 104), initial = 1.4,
        width = 8.5, compact = 5.9, life = .26},
    magmaTrail = {name = "Magma tile burst", color = tint.burst, initial = .65, width = 2.36, compact = 2.15, life = .30},
    tadpoleTornado = {name = "Tadpole Tornado pulse", color = Color3.fromRGB(143, 241, 124),
        initial = 1.05, width = 6.4, compact = 5.3, life = .29},
    gustVortex = {name = "Gust Vortex outward pulse", color = Color3.fromRGB(203, 175, 255),
        initial = 1.06, width = 6, compact = 5.2, life = .27},
    tidalBellyFlop = {name = "Tidal landing pulse", color = Color3.fromRGB(135, 226, 255),
        initial = .95, width = 7.3, compact = 6.40, life = .33},
    ["Breakwater Stamp"] = {name = "Breakwater contact pulse", color = Color3.fromRGB(135, 202, 236),
        initial = 1.2, width = 8.5, compact = 5.9, life = .28},
}
local moveContactTint = {
    reedSweep = Color3.fromRGB(187, 230, 143),
    icecrestPalm = Color3.fromRGB(166, 221, 253),
    floeHook = Color3.fromRGB(140, 239, 230),
    thunderDive = Color3.fromRGB(168, 222, 255),
    staticCharge = Color3.fromRGB(255, 212, 122),
    burrowHook = Color3.fromRGB(245, 186, 106),
    unstoppableFrenzy = Color3.fromRGB(255, 196, 117),
    jadeRake = Color3.fromRGB(162, 231, 184),
    apexPounce = Color3.fromRGB(137, 231, 174),
    reefHook = Color3.fromRGB(155, 231, 243),
    jawsOfTheDeep = Color3.fromRGB(121, 226, 255),
    tideGrip = Color3.fromRGB(209, 174, 251),
    tentacleCataclysm = Color3.fromRGB(210, 149, 244),
    basaltBackhand = Color3.fromRGB(255, 173, 111),
    eruptionSlam = Color3.fromRGB(255, 193, 102),
    cinderLunge = Color3.fromRGB(255, 124, 103),
    hellfireStampede = Color3.fromRGB(244, 144, 198),
    galeRake = Color3.fromRGB(255, 225, 138),
    talonDrop = Color3.fromRGB(255, 193, 92),
    stormClaw = Color3.fromRGB(197, 171, 255),
    tempestRoar = Color3.fromRGB(147, 198, 250),
    stormThunder = Color3.fromRGB(217, 181, 255),
}

local folder
local prepared = false
function CombatEffects.prepare()
    if prepared or UserInputService.TouchEnabled or UserInputService.VREnabled or GuiService.ReducedMotionEnabled then
        return
    end
    prepared = true
    task.spawn(function()
        local allLoaded = true
        local ok = pcall(function()
            ContentProvider:PreloadAsync({hitTexture, parryTexture}, function(_, status)
                allLoaded = allLoaded and status == Enum.AssetFetchStatus.Success
            end)
        end)
        prepared = ok and allLoaded
    end)
end

local function worldFolder()
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Local Dojo contact effects"
        folder.Parent = workspace
    end
    return folder
end

local function groundPulse(point, style, compact, reduced)
    local pulse = Instance.new("Part")
    pulse.Name = style.name
    pulse.Shape = Enum.PartType.Cylinder
    pulse.Anchored, pulse.CanCollide, pulse.CanQuery, pulse.CanTouch = true, false, false, false
    pulse.CastShadow, pulse.Material = false, Enum.Material.Neon
    pulse.Color = style.color
    pulse.Transparency = if reduced then .86 elseif compact then .78 else .70
    pulse.Size = Vector3.new(.035, style.initial, style.initial)
    pulse.CFrame = CFrame.new(point + Vector3.new(0, .065, 0)) * CFrame.Angles(0, 0, math.pi / 2)
    pulse.Parent = worldFolder()
    local width = if reduced then style.initial elseif compact then style.compact else style.width
    TweenService:Create(pulse, TweenInfo.new(style.life, Enum.EasingStyle.Quad), {
        Size = Vector3.new(.035, width, width), Transparency = 1,
    }):Play()
    Debris:AddItem(pulse, style.life + .06)
end

local inwardGust = {name = "Gust Vortex inward pulse", color = tint.gustPull,
    initial = 6, width = .85, compact = 1, life = .30}
local snareMark = {name = "Cinder Snare hold", color = tint.snared,
    initial = 1.88, width = .78, compact = .88, life = .72}
local waveHit = {name = "Cavitation Cannon impact", color = Color3.fromRGB(126, 226, 255),
    initial = .7, width = 2.7, compact = 2.0, life = .23}
local floorBurst = {name = "Ground contact pulse", color = tint.burst, initial = .7, width = 3.2, compact = 2.2, life = .25}

local function funnel(point, compact)
    local count = if compact then 6 else 10
    for index = 1, count do
        local progress = index / count
        local angle = progress * math.pi * 3
        local radius = 2.42 - progress * 1.9
        local edge = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local mark = Instance.new("Part")
        mark.Name = "Vortex wind ribbon"
        mark.Anchored, mark.CanCollide, mark.CanQuery, mark.CanTouch, mark.CastShadow = true, false, false, false, false
        mark.Material, mark.Color, mark.Transparency = Enum.Material.Neon, tint.gustPull, .23
        mark.Size = Vector3.new(.07, .065, if compact then .72 else 1.08)
        local position = point + edge * radius + Vector3.yAxis * (progress * 1.68 + .14)
        mark.CFrame = CFrame.lookAt(position, position + edge:Cross(Vector3.yAxis))
        mark.Parent = worldFolder()
        local inward = mark.CFrame - edge * radius * .56 + Vector3.yAxis * .28
        TweenService:Create(mark, TweenInfo.new(.24, Enum.EasingStyle.Quad), {CFrame = inward, Transparency = 1}):Play()
        Debris:AddItem(mark, .28)
    end
end

local function tidalCrests(point, compact)
    local count = if compact then 6 else 10
    for index = 1, count do
        local angle = (index - .5) * math.pi * 2 / count
        local outward = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local crest = Instance.new("WedgePart")
        crest.Name = "Tidal splash crest"
        crest.Anchored, crest.CanCollide, crest.CanQuery, crest.CanTouch, crest.CastShadow = true, false, false, false, false
        crest.Color, crest.Material, crest.Transparency = Color3.fromRGB(178, 239, 255), Enum.Material.Neon, .23
        crest.Size = Vector3.new(.32, .45, .24)
        crest.CFrame = CFrame.lookAlong(point + outward * .58 + Vector3.yAxis * .29, outward) * CFrame.Angles(-.25, 0, 0)
        crest.Parent = worldFolder()
        TweenService:Create(crest, TweenInfo.new(.27, Enum.EasingStyle.Quad), {
            CFrame = crest.CFrame + outward * (if compact then 1.65 else 2.38) + Vector3.yAxis * .49,
            Size = Vector3.new(.21, .21, .18), Transparency = 1,
        }):Play()
        Debris:AddItem(crest, .31)
    end
end

function CombatEffects.play(kind, point, attack)
    local camera = workspace.CurrentCamera
    local color = tint[kind]
    if not color or typeof(point) ~= "Vector3" or not camera then
        return
    end
    local distance = (point - camera.CFrame.Position).Magnitude
    local _, visible = camera:WorldToViewportPoint(point)
    if distance > 64 or not visible then
        return
    end
    local defense = Marks.defenseFamily(kind)
    local reduced = GuiService.ReducedMotionEnabled or UserInputService.VREnabled
    local mobile = UserInputService.TouchEnabled
    local compact = reduced or mobile or distance > 32
    if kind == "gustPull" then
        groundPulse(point, inwardGust, compact, reduced)
        if not reduced then
            funnel(point, compact)
        end
        return
    end
    if kind == "snared" and attack ~= "apexPounce" then
        groundPulse(point, snareMark, compact, reduced)
        return
    end
    local pulse = if attack == "cavitationCannon" then waveHit else groundPulses[attack]
    if not defense and (pulse or kind == "burst") then
        groundPulse(point, pulse or floorBurst, compact, reduced)
        if attack == "tidalBellyFlop" and not reduced then
            tidalCrests(point, compact)
        end
        if kind == "burst" then return end
    end
    if not defense then
        if attack == "emberSweep" or attack == "volcanicBreath" or attack == "meteorRoll" then
            color = tint.burst
        elseif attack == "canopySlip" then
            color = tint.gustPull
        else
            color = moveContactTint[attack] or color
        end
    end
    local anchor = Marks.show(worldFolder(), point, defense or "strike", color, compact, reduced or mobile)
    local parry = defense == "parry"
    if not anchor or compact or (defense and not parry) then return end

    local diameter = if parry then 1.16 elseif kind == "diveKick" then 1.20 else 1.02
    local life = if parry then .23 else .18
    local attachment = Instance.new("Attachment")
    attachment.Parent = anchor
    local ring = Instance.new("ParticleEmitter")
    ring.Name = "Contact ring"
    ring.Enabled, ring.Rate, ring.Speed = false, 0, NumberRange.new(0)
    ring.Texture = if parry then parryTexture else hitTexture
    ring.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
    ring.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    ring.LightEmission, ring.LightInfluence, ring.ZOffset = .55, 0, .02
    ring.Color, ring.Lifetime = ColorSequence.new(color), NumberRange.new(life)
    ring.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, .30),
        NumberSequenceKeypoint.new(.63, .55),
        NumberSequenceKeypoint.new(1, 1),
    })
    ring.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, diameter * .66),
        NumberSequenceKeypoint.new(.45, diameter),
        NumberSequenceKeypoint.new(1, diameter * 1.15),
    })
    ring.Parent = attachment
    ring:Emit(1)
end

return CombatEffects
