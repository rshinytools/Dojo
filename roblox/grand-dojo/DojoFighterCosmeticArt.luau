local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("DojoCosmeticCatalog"))
local visuals = ReplicatedStorage:WaitForChild("StarterFighterVisuals")
local Art = {}

local vector, frame = Vector3.new, CFrame.new
local color = Color3.fromRGB
local block, ball = Enum.PartType.Block, Enum.PartType.Ball
local fabric, wood, metal = Enum.Material.Fabric, Enum.Material.Wood, Enum.Material.Metal
local enamel = Enum.Material.SmoothPlastic

local function hand(x, y, z, tipX, tipY, tipZ)
    return CFrame.lookAt(vector(x, y, z), vector(tipX, tipY, tipZ))
end

local fits = {
    -- The woven shell encloses the baked crimson mitt geometry. The centers and
    -- minimum size came from both original arm meshes and their baked atlas.
    ["reedguard-bamboo-mitts"] = {
        left = frame(-1.006, 1.720, -.377), right = frame(1.006, 1.720, -.377),
        size = vector(.804, .602, .808),
    },
    -- Penguin's left flipper is forward. The right flipper points out and back.
    ["penguin-glacier-mitts"] = {
        left = hand(-1.026, 2.712, -.867, -.774, 2.808, -1.141),
        right = hand(1.570, 2.707, .273, 1.808, 2.823, .099),
        size = vector(.60, .55, .77),
    },
    -- Match the original wrapped forearm, leaving the bare knuckles clear.
    ["silverback-cedar-bracers"] = {
        left = hand(-1.774, 2.159, -.516, -1.714, 2.225, -.785),
        right = hand(1.595, 2.647, -.809, 1.535, 2.713, -1.078),
        size = vector(.93, .90, .40),
    },
    -- Replace the cloth cuff without covering Salamander's raised webbed fingers.
    ["salamander-kiln-mitts"] = {
        left = hand(-.953, 3.019, -.343, -.917, 3.14, -.636),
        right = hand(.953, 2.729, -.533, .917, 2.85, -.826),
        size = vector(.514, .526, .478),
    },
}

local function bamboo(add, side)
    local shadow, reed, moss = color(27, 70, 45), color(124, 170, 83), color(61, 108, 47)
    local gold, thread = color(201, 153, 70), color(233, 199, 126)
    add("Enclosed hand padding", frame(), vector(1, 1, 1), shadow, block, fabric)
    add("Woven knuckle panel", frame(0, .012, -.409), vector(.97, .91, .055), moss, block, wood)
    for row = -1, 1 do
        add("Bamboo weft", frame(0, row * .141, -.432), vector(.965, .194, .031),
            if row % 2 == 0 then reed else moss, block, wood)
        for column = -1, 1 do
            if (row + column) % 2 == 0 then
                add("Raised bamboo warp", frame(column * .187, row * .141, -.448), vector(.171, .196, .025), reed, block, wood)
            end
        end
    end
    add("Laced thumb cap", frame(-side * .394, -.032, -.272), vector(.25, .62, .59), moss, ball, fabric)
    for _, x in {-.387, .387} do
        add("Bound side seam", frame(x, .008, -.436), vector(.047, .98, .045), gold, block, fabric)
    end
    add("Gold-edged cuff", frame(0, .280, .038), vector(.96, .137, .87), gold, block, fabric)
    add("Clasp", frame(-side * .229, .276, -.328) * CFrame.Angles(0, 0, math.rad(45)),
        vector(.16, .22, .085), thread, block, metal)
end

local function glacier(add)
    local shadow, cobalt = color(28, 57, 115), color(33, 107, 180)
    local ice, silver = color(97, 218, 235), color(204, 232, 239)
    add("Tapered flipper pad", frame(), vector(1, 1, 1), cobalt, ball, fabric)
    add("Deep blue palm", frame(0, -.088, .025), vector(.92, .81, .88), shadow, ball, fabric)
    add("Silver edge", frame(0, .149, -.08), vector(.92, .62, .79), silver, ball, enamel)
    add("Glacier crest", frame(0, .187, -.095), vector(.74, .51, .77), ice, ball, enamel)
    for i = -1, 1 do
        add("Blue ice seam", frame(i * .118, .318, -.102) * CFrame.Angles(0, math.rad(i * 16), 0),
            vector(.046, .047, .48), cobalt, block, enamel)
    end
    add("Soft cuff", frame(0, -.005, .217), vector(.98, .94, .22), shadow, ball, fabric)
end

local function cedar(add)
    local moss, plate = color(50, 75, 51), color(126, 73, 45)
    local grain, bronze = color(169, 100, 57), color(224, 162, 70)
    add("Moss-green forearm wrap", frame(), vector(1, 1, 1), moss, block, fabric)
    for i = -1, 1 do
        add("Curved cedar plate", frame(i * .239, .436, -.015) * CFrame.Angles(0, 0, math.rad(i * -18)),
            vector(.42, .18, .95), plate, block, wood)
        add("Raised wood grain", frame(i * .239, .515, -.011) * CFrame.Angles(0, 0, math.rad(i * -18)),
            vector(.12, .058, .78), grain, block, wood)
    end
    for _, z in {-.179, .157} do
        add("Bronze bracer rim", frame(0, -.002, z), vector(1.015, .995, .14), bronze, block, metal)
    end
    for _, x in {-.256, .256} do
        add("Rivet", frame(x, .541, -.075), vector(.15, .078, .31), bronze, ball, metal)
    end
end

local function kiln(add)
    local oxblood, red, vermilion = color(116, 36, 36), color(194, 53, 36), color(238, 78, 38)
    local amber, yellow = color(224, 127, 36), color(252, 183, 68)
    add("Close-fitted cloth sleeve", frame(), vector(1, 1, 1), oxblood, block, fabric)
    for i = -1, 1 do
        add("Layered vermilion wrap", frame(0, 0, i * .144) * CFrame.Angles(math.rad(13), 0, 0),
            vector(1.033, 1.034, .28), if i == 0 then vermilion else red, block, fabric)
        add("Stitched wrap edge", frame(0, .271, i * .144 - .038) * CFrame.Angles(math.rad(13), 0, 0),
            vector(.97, .045, .084), amber, block, fabric)
    end
    add("Kiln clasp backing", frame(0, .307, .018) * CFrame.Angles(0, math.rad(45), 0),
        vector(.43, .15, .45), amber, block, metal)
    add("Glazed ember inset", frame(0, .356, .018) * CFrame.Angles(0, math.rad(45), 0),
        vector(.29, .078, .31), yellow, block, enamel)
end

local styles = {
    ["reedguard-bamboo-mitts"] = bamboo,
    ["penguin-glacier-mitts"] = glacier,
    ["silverback-cedar-bracers"] = cedar,
    ["salamander-kiln-mitts"] = kiln,
}

local arms = {["Left Arm"] = "left", ["Right Arm"] = "right"}

local function piece(parent, arm, name, pose, size, tint, shape, material, moving)
    local part = Instance.new("Part")
    part.Name, part.CFrame, part.Size, part.Color = name, pose, size, tint
    part.Shape, part.Material = shape, material
    part.Anchored, part.Massless, part.CanCollide, part.CanQuery, part.CanTouch = not moving, true, false, false, false
    part.CastShadow = false
    if moving then
        local weld = Instance.new("WeldConstraint")
        weld.Part0, weld.Part1 = arm, part
        weld.Parent = part
    end
    part.Parent = parent
end

function Art.mount(parent, shell, itemId, fighterId, moving)
    if not Catalog.canWear(itemId, fighterId) then return nil end
    local fit, style = fits[itemId], styles[itemId]
    local source = visuals:FindFirstChild(fighterId)
    if not fit or not style or not source then return nil end
    local mounts = {}
    for name, side in arms do
        local arm, reference = shell:FindFirstChild(name), source:FindFirstChild(name)
        if not (arm and reference and arm:IsA("BasePart") and reference:IsA("BasePart")) then return nil end
        mounts[name] = arm.CFrame * reference.CFrame:ToObjectSpace(fit[side])
    end

    local model = Instance.new("Model")
    model.Name = Catalog.get(itemId).name
    for name, pose in mounts do
        local armFolder = Instance.new("Folder")
        armFolder.Name, armFolder.Parent = name, model
        local arm = shell[name]
        style(function(label, offset, scale, tint, shape, material)
            piece(armFolder, arm, label, pose * offset, fit.size * scale, tint, shape, material, moving)
        end, if arms[name] == "left" then -1 else 1)
    end
    model.Parent = parent
    return model
end

return Art
