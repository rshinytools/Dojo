-- Uses the circular hit and parry ring textures from Artinex2's licensed
-- RPG & Combat Effects Pack. Timing, size, and color are authored for Beast Dojo.
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local CombatEffects = {}
local hitTexture = "rbxassetid://18140248952"
local parryTexture = "rbxassetid://126034245450101"
local tint = {
    strike = Color3.fromRGB(255, 211, 124),
    counter = Color3.fromRGB(255, 229, 146),
    hit = Color3.fromRGB(255, 170, 117),
    parried = Color3.fromRGB(139, 235, 255),
    blocked = Color3.fromRGB(183, 215, 210),
    braced = Color3.fromRGB(174, 211, 180),
}

local folder
local prepared = false
function CombatEffects.prepare()
    if prepared then
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

local function slamPulse(point, compact, reduced)
    local pulse = Instance.new("Part")
    pulse.Name = "Seismic contact pulse"
    pulse.Shape = Enum.PartType.Cylinder
    pulse.Anchored, pulse.CanCollide, pulse.CanQuery, pulse.CanTouch = true, false, false, false
    pulse.CastShadow, pulse.Material = false, Enum.Material.Neon
    pulse.Color = Color3.fromRGB(255, 183, 104)
    pulse.Transparency = if reduced then .86 elseif compact then .78 else .70
    pulse.Size = Vector3.new(.035, 1.4, 1.4)
    pulse.CFrame = CFrame.new(point + Vector3.new(0, .065, 0)) * CFrame.Angles(0, 0, math.pi / 2)
    pulse.Parent = worldFolder()
    local width = if reduced then 1.4 elseif compact then 5.9 else 8.5
    TweenService:Create(pulse, TweenInfo.new(.26, Enum.EasingStyle.Quad), {
        Size = Vector3.new(.035, width, width), Transparency = 1,
    }):Play()
    Debris:AddItem(pulse, .32)
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
    local parry = kind == "parried"
    local reduced = GuiService.ReducedMotionEnabled or UserInputService.VREnabled
    local mobile = UserInputService.TouchEnabled
    local compact = reduced or mobile or distance > 32
    if attack == "seismicChestPound" then
        slamPulse(point, compact, reduced)
        return
    end
    local diameter = if parry then (if compact then 1.28 else 1.72) else (if compact then .93 else 1.2)
    local life = if parry then .27 else .21

    local anchor = Instance.new("Part")
    anchor.Name = if parry then "Parry contact" else "Strike contact"
    anchor.Anchored, anchor.CanCollide, anchor.CanTouch, anchor.CanQuery = true, false, false, false
    anchor.CastShadow, anchor.Massless, anchor.Transparency = false, true, 1
    anchor.CFrame, anchor.Size = CFrame.new(point), Vector3.one * .05
    local attachment = Instance.new("Attachment")
    attachment.Parent = anchor
    local ring = Instance.new("ParticleEmitter")
    ring.Name = "Contact ring"
    ring.Enabled, ring.Rate, ring.Speed = false, 0, NumberRange.new(0)
    ring.Texture = if parry then parryTexture else hitTexture
    ring.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
    ring.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    ring.LightEmission, ring.LightInfluence, ring.ZOffset = .65, 0, .05
    ring.Color, ring.Lifetime = ColorSequence.new(color), NumberRange.new(life)
    ring.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, if reduced then .32 else .12),
        NumberSequenceKeypoint.new(.63, .44),
        NumberSequenceKeypoint.new(1, 1),
    })
    ring.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, diameter * .66),
        NumberSequenceKeypoint.new(.45, diameter),
        NumberSequenceKeypoint.new(1, diameter * 1.15),
    })
    ring.Parent = attachment
    anchor.Parent = worldFolder()
    ring:Emit(1)
    Debris:AddItem(anchor, life + .11)

    -- Keep a small visible contact cue if a published place cannot load the
    -- texture or the device disables the animated particle.
    local spark = Instance.new("Part")
    spark.Name = "Contact glint"
    spark.Anchored, spark.CanCollide, spark.CanTouch, spark.CanQuery = true, false, false, false
    spark.CastShadow, spark.Material, spark.Color = false, Enum.Material.Neon, color
    spark.Transparency = if reduced then .42 else .14
    spark.CFrame = CFrame.new(point) * CFrame.Angles(0, math.rad(32), math.rad(45))
    spark.Size = Vector3.new(.085, if parry then .38 else .24, .085)
    spark.Parent = anchor
    TweenService:Create(spark, TweenInfo.new(.12, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
end

return CombatEffects
