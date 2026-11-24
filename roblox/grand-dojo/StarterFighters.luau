-- Fit the selected art to the existing character, keeping its Humanoid,
-- colliders, controller and animation tracks.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local catalog = require(ReplicatedStorage:WaitForChild("StarterFighterCatalog"))
local visuals = ReplicatedStorage:WaitForChild("StarterFighterVisuals")
local restRig = StarterPlayer:WaitForChild("StarterCharacter")

local StarterFighters = {}
local REQUIRED_GROUPS = {"Torso", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local SHELL_NAME = "Starter Fighter Shell"
local HELD_ATTRIBUTE = "HeldForStarterChoice"

local restJoints = {}
for _, joint in restRig:GetDescendants() do
    if joint:IsA("Motor6D") and joint.Name ~= "RootJoint" and joint.Part0 and joint.Part1 then
        restJoints[joint.Part1.Name] = joint
    end
end

local function visualModel(id)
    local model = visuals:FindFirstChild(id)
    return if model and model:IsA("Model") then model else nil
end

function StarterFighters.isChoice(id)
    return typeof(id) == "string" and #id <= 80 and catalog.ById[id] ~= nil
end

function StarterFighters.hasVisuals(id)
    local model = visualModel(id)
    if not model then
        return false
    end
    for _, group in REQUIRED_GROUPS do
        local part = model:FindFirstChild(group)
        if not part or not part:IsA("MeshPart") then
            return false
        end
    end
    return true
end

function StarterFighters.hold(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root and not root.Anchored then
        root:SetAttribute(HELD_ATTRIBUTE, true)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored = true
    end
end

function StarterFighters.release(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root and root:GetAttribute(HELD_ATTRIBUTE) then
        root:SetAttribute(HELD_ATTRIBUTE, nil)
        root.Anchored = false
    end
end

local function mountedPieces(character, model)
    local pieces = {}
    local groups = table.clone(REQUIRED_GROUPS)
    if model:FindFirstChild("Tail") then
        table.insert(groups, "Tail")
    end
    for _, group in groups do
        local source = model:FindFirstChild(group)
        local carrier = character:FindFirstChild(group)
        local restPart = restRig:FindFirstChild(group)
        if not (source and source:IsA("MeshPart") and carrier and carrier:IsA("BasePart") and restPart) then
            return nil
        end
        local restJoint = restJoints[group]
        local artPivot = source:FindFirstChild("ArtPivot")
        local joint, c0, c1
        if restJoint and artPivot and artPivot:IsA("Attachment") then
            local parent = character:FindFirstChild(restJoint.Part0.Name)
            joint = parent and parent:FindFirstChild(restJoint.Name)
            if not joint or not joint:IsA("Motor6D") or joint.Part0 ~= parent or joint.Part1 ~= carrier then
                return nil
            end
            -- Move both ends of the joint together. The animation axes and the
            -- rest pose stay the same while movement pivots about this fighter's
            -- authored shoulder, hip, neck or tail attachment.
            local original = restPart.CFrame * restJoint.C1
            local pivot = CFrame.new(source.CFrame:PointToWorldSpace(artPivot.Position)) * original.Rotation
            c0 = restJoint.Part0.CFrame:ToObjectSpace(pivot)
            c1 = restPart.CFrame:ToObjectSpace(pivot)
        end
        table.insert(pieces, {
            source = source,
            carrier = carrier,
            offset = restPart.CFrame:ToObjectSpace(source.CFrame),
            joint = joint,
            c0 = c0,
            c1 = c1,
        })
    end
    return pieces
end

function StarterFighters.equip(character, id)
    local current = character:FindFirstChild(SHELL_NAME)
    if current then
        return current:GetAttribute("FighterId") == id
    end
    local model = visualModel(id)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local pieces = model and humanoid and mountedPieces(character, model)
    if not pieces then
        return false
    end
    local shell = Instance.new("Folder")
    shell.Name = SHELL_NAME
    shell:SetAttribute("FighterId", id)
    for _, piece in pieces do
        local mesh = piece.source:Clone()
        mesh.Anchored = false
        mesh.Massless = true
        mesh.CanCollide = false
        mesh.CanTouch = false
        mesh.CanQuery = false
        mesh.CFrame = piece.carrier.CFrame * piece.offset
        mesh.Parent = shell

        local weld = Instance.new("Weld")
        weld.Part0 = piece.carrier
        weld.Part1 = mesh
        weld.C0 = piece.offset
        weld.Parent = mesh
        if piece.joint then
            piece.joint.C0 = piece.c0
            piece.joint.C1 = piece.c1
        end
    end
    for _, old in character:GetDescendants() do
        if old:IsA("BasePart") then
            old.Transparency = 1
            old.CastShadow = false
        elseif old:IsA("Decal") then
            old.Transparency = 1
        end
    end
    shell.Parent = character
    local entry = catalog.ById[id]
    local name = entry and (entry.Name or entry.name)
    if typeof(name) == "string" then
        humanoid.DisplayName = name
    end
    return true
end

return StarterFighters
