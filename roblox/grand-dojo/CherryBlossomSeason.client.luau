local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VRService = game:GetService("VRService")

local QUALITY = UserSettings():GetService("UserGameSettings")
local PREVIEW_ATTRIBUTE = "PreviewCherryBlossomSeason"
local WALK_CENTER = Vector3.new(-94, 6, 49)
local random = Random.new()
local shownSeason
local shownClusters
local bench

RunService.PreSimulation:Connect(function()
    local weld = bench and bench:FindFirstChild("SeatWeld")
    local weldedPart = weld and weld.Part1
    local character = weldedPart and weldedPart.Parent
    if not character or not character:FindFirstChild("Starter Fighter Shell") then
        return
    end
    local torso = character:FindFirstChild("Torso")
    if not torso then return end
    -- The standard R6 sit clip flares the fitted fighter's shoulders.
    for _, side in {"Left", "Right"} do
        local shoulder = torso:FindFirstChild(side .. " Shoulder")
        if shoulder then
            local axes = shoulder.C0.Rotation
            shoulder.Transform = axes:ToObjectSpace(CFrame.Angles(math.rad(-16), 0, 0) * axes)
        end
    end
end)

local function seasonActive(now)
    if RunService:IsStudio() and workspace:GetAttribute(PREVIEW_ATTRIBUTE) == true then
        return true
    end
    local date = os.date("!*t", now)
    local monthDay = date.month * 100 + date.day
    return monthDay >= 320 and monthDay <= 415
end

local function driftingPetal()
    local start = Vector3.new(random:NextNumber(-101, -84), random:NextNumber(9, 12), random:NextNumber(44, 54))
    local petal = Instance.new("Part")
    petal.Name = "Drifting blossom petal"
    petal.Size = Vector3.new(.17, .033, .12)
    petal.Color = Color3.fromRGB(239, 152, 180)
    petal.Anchored = true
    petal.CanCollide = false
    petal.CanTouch = false
    petal.CanQuery = false
    petal.CastShadow = false
    petal.CFrame = CFrame.new(start) * CFrame.Angles(.25, random:NextNumber(0, math.pi), .8)
    petal.Parent = workspace
    local motion = TweenService:Create(petal, TweenInfo.new(3, Enum.EasingStyle.Linear), {
        CFrame = petal.CFrame * CFrame.Angles(1.6, 1.1, .9) + Vector3.new(2.4, -4.1, 1),
        Transparency = 1,
    })
    motion.Completed:Once(function() petal:Destroy() end)
    motion:Play()
end

while true do
    local season = seasonActive(math.floor(workspace:GetServerTimeNow()))
    local city = workspace:FindFirstChild("Grand Dojo City")
    local streets = city and city:FindFirstChild("City streets")
    local walk = streets and streets:FindFirstChild("Cherry Blossom Walk")
    local clusters = walk and walk:FindFirstChild("Seasonal blossom clusters")
    bench = walk and walk:FindFirstChild("Sunset Bench")
    if clusters and (clusters ~= shownClusters or season ~= shownSeason) then
        for _, cluster in clusters:GetChildren() do
            cluster.Transparency = if season then 0 else 1
        end
    end
    shownClusters = clusters
    shownSeason = season
    local camera = workspace.CurrentCamera
    local quality = QUALITY.SavedQualityLevel.Value
    if season and clusters and camera and (camera.CFrame.Position - WALK_CENTER).Magnitude < 44
        and not GuiService.ReducedMotionEnabled and not VRService.VREnabled and (quality == 0 or quality > 4) then
        driftingPetal()
        task.wait(.28)
    else
        task.wait(1)
    end
end
