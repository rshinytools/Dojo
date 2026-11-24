local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Portraits = {}

local entries = {
    {modelName = "reedguard-kangaroo", shortName = "Reedguard", initials = "RK", tint = Color3.fromHex("FAC177")},
    {modelName = "penguin-brawler", shortName = "Penguin", initials = "PB", tint = Color3.fromHex("9EE8F8")},
    {modelName = "silverback-gorilla", shortName = "Silverback", initials = "SG", tint = Color3.fromHex("E0AE92")},
    {modelName = "fire-salamander", shortName = "Salamander", initials = "FS", tint = Color3.fromHex("FF9970")},
    {modelName = "karate-frog", shortName = "Karate Frog", kit = "frog", initials = "KF", tint = Color3.fromHex("C4EB92")},
    {modelName = "river-otter", shortName = "River Otter", kit = "otter", initials = "RO", tint = Color3.fromHex("94E4FF")},
    {modelName = "Juniper Tortoise", shortName = "Juniper", initials = "JT", tint = Color3.fromHex("AAF0C1"), resident = true},
    {modelName = "Bracken Boar", shortName = "Bracken", initials = "BB", tint = Color3.fromHex("FFC391"), resident = true},
    {modelName = "Sablecrest Lynx", shortName = "Sablecrest", initials = "SL", tint = Color3.fromHex("CFC0FF"), resident = true},
    {modelName = "Granite Rhino", shortName = "Granite", initials = "GR", tint = Color3.fromHex("A9D4FC"), resident = true},
}

local function normalize(name)
    return (string.lower(name):gsub("[^%a%d]", ""))
end

local byName = {}
for _, entry in entries do
    byName[normalize(entry.modelName)] = entry
    byName[normalize(entry.shortName)] = entry
    if entry.kit then
        byName[entry.kit] = entry
    end
end

local function create(className, parent, properties)
    local object = Instance.new(className)
    for key, value in properties do
        object[key] = value
    end
    object.Parent = parent
    return object
end

function Portraits.new(parent, mirrored, zIndex)
    local fullSize = UDim2.fromScale(1, 1)
    local viewport = create("ViewportFrame", parent, {
        Name = "FighterPortrait", Size = fullSize, Visible = false,
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = zIndex,
        Ambient = Color3.fromRGB(201, 186, 171), LightColor = Color3.fromRGB(255, 238, 214),
        LightDirection = Vector3.new(if mirrored then -.35 else .35, .58, -1),
    })
    local camera = create("Camera", viewport, {Name = "PortraitCamera", FieldOfView = 32})
    viewport.CurrentCamera = camera
    local fallback = create("TextLabel", parent, {
        Name = "PortraitInitials", Size = fullSize, Visible = false,
        BackgroundTransparency = 1, Text = "", ZIndex = zIndex,
        Font = Enum.Font.GothamBold, TextScaled = true,
        TextStrokeColor3 = Color3.fromRGB(48, 22, 27), TextStrokeTransparency = .2,
    })
    create("UITextSizeConstraint", fallback, {MinTextSize = 10, MaxTextSize = 25})
    return {viewport = viewport, camera = camera, fallback = fallback, mirrored = mirrored}
end

local function frameHead(camera, frame, size, mirrored, crop)
    -- The authored model faces -Z. Place each camera on the side that turns its fighter toward the timer.
    local aim = frame.Position - Vector3.new(0, size.Y * .12, 0)
    local direction = Vector3.new(if mirrored then -.54 else .54, .09, -1).Unit
    local basis = CFrame.lookAt(Vector3.zero, -direction)
    local halfView = math.tan(math.rad(camera.FieldOfView / 2))
    local halfSize = size * .5
    local distance = 0
    -- Estimate the head's projected bounds before cropping close to the face.
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local corner = frame:PointToWorldSpace(Vector3.new(x * halfSize.X, y * halfSize.Y, z * halfSize.Z)) - aim
                local width = math.abs(corner:Dot(basis.RightVector)) / .94
                local height = math.abs(corner:Dot(basis.UpVector)) / .91
                distance = math.max(distance, corner:Dot(direction) + math.max(width, height) / halfView)
            end
        end
    end
    -- The tighter crop fills the small badge while centering the muzzle below longer ears.
    aim -= Vector3.new(0, size.Y * .053, 0)
    camera.CFrame = CFrame.lookAt(aim + direction * distance * crop, aim)
end

local function visiblePieces(group, load)
    local pieces = {}
    local descendants = group:GetDescendants()
    table.insert(descendants, group)
    for _, piece in descendants do
        if piece:IsA("BasePart") and piece.Transparency < 1 then
            table.insert(pieces, piece)
            if piece:IsA("MeshPart") then
                table.insert(load, piece)
            end
        end
    end
    return pieces
end

local function copyPieces(pieces, parent)
    for _, source in pieces do
        local part = source:Clone()
        part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
        part.CastShadow = false
        for _, child in part:GetChildren() do
            if not child:IsA("SurfaceAppearance") then
                child:Destroy()
            end
        end
        part.Parent = parent
    end
end

local function stagePortrait(portrait, entry, request)
    local libraryName = if entry.resident then "ChampionshipBotPortraits" else "StarterFighterVisuals"
    local library = ReplicatedStorage:WaitForChild(libraryName, 3)
    local fighter = library and library:WaitForChild(entry.modelName, 3)
    local head = fighter and fighter:WaitForChild("Head", 3)
    local torso = fighter and fighter:WaitForChild("Torso", 3)
    if portrait.request ~= request then
        return
    end
    if not (head and torso and head:IsA("BasePart") and torso:IsA("BasePart")) then
        portrait.viewport:SetAttribute("PortraitState", "fallback")
        return
    end

    local load = {}
    local face = visiblePieces(head, load)
    local chest = visiblePieces(torso, load)
    local ok, loaded = true, true
    if #load > 0 then
        ok = pcall(ContentProvider.PreloadAsync, ContentProvider, load, function(_, status)
            loaded = loaded and status == Enum.AssetFetchStatus.Success
        end)
    end
    if portrait.request ~= request then
        return
    end
    if not (ok and loaded and #face > 0) then
        portrait.viewport:SetAttribute("PortraitState", "fallback")
        return
    end

    local bust = create("Model", portrait.viewport, {Name = "PortraitBust"})
    portrait.bust = bust
    local faceFrame, faceSize = face[1].CFrame, face[1].Size
    if #face == 1 then
        copyPieces(face, bust)
    else
        local faceGroup = create("Model", bust, {Name = "HeadGroup"})
        copyPieces(face, faceGroup)
        faceFrame, faceSize = faceGroup:GetBoundingBox()
    end
    copyPieces(chest, bust)
    frameHead(portrait.camera, faceFrame, faceSize, portrait.mirrored, if #face == 1 then .83 else .92)
    portrait.viewport:SetAttribute("PortraitState", "ready")
    portrait.viewport.Visible = true
    portrait.fallback.Visible = false
end

function Portraits.set(portrait, name)
    local normalized = if type(name) == "string" then normalize(name) else ""
    local entry = byName[normalized]
    local key = if entry then entry.modelName else normalized
    if portrait.key == key then
        return
    end
    portrait.key = key
    -- The request token prevents a slow download from painting onto a later fight.
    local request = {}
    portrait.request = request
    if portrait.bust then
        portrait.bust:Destroy()
        portrait.bust = nil
    end
    portrait.viewport.Visible = false
    portrait.viewport:SetAttribute("FighterId", if key ~= "" then key else nil)
    portrait.viewport:SetAttribute("PortraitState", if entry then "loading" elseif key ~= "" then "fallback" else nil)
    portrait.fallback.Text = if entry then entry.initials else "?"
    portrait.fallback.TextColor3 = if entry then entry.tint else Color3.fromRGB(255, 221, 162)
    portrait.fallback.Visible = key ~= ""
    if entry then
        task.spawn(stagePortrait, portrait, entry, request)
    end
end

return Portraits
