local Art = {}

Art.JadeName = "Jade Festival Sash"
Art.Name = "Midnight Lantern Set"
Art.Description = "Indigo shoulder mantle and a bronze lantern charm. Cosmetic apparel."

local midnight = Color3.fromRGB(39, 43, 86)
local thread = Color3.fromRGB(104, 123, 190)
local bronze = Color3.fromRGB(213, 151, 81)
local enamel = Color3.fromRGB(255, 211, 122)
local brass = Color3.fromRGB(224, 177, 95)
local jade = Color3.fromRGB(41, 113, 91)
local mint = Color3.fromRGB(145, 228, 184)
local fabric = Enum.Material.Fabric
local metal = Enum.Material.SmoothPlastic

local function frontEdge(frame, size)
    local halfDepth = .5 * (math.abs(frame.RightVector.Z) * size.X + math.abs(frame.UpVector.Z) * size.Y
        + math.abs(frame.LookVector.Z) * size.Z)
    return frame.Z - halfDepth
end

function Art.fit(art, artFrame)
    local half = art.Size * .5
    local right, up, forward = artFrame.RightVector, artFrame.UpVector, artFrame.LookVector
    local halfWidth = math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(forward.X) * half.Z
    local halfHeight = math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(forward.Y) * half.Z
    local center = artFrame.Position
    local width = math.clamp(halfWidth, .36, 1.44)
    local height = math.clamp(halfHeight, .40, 1.56)
    local front = frontEdge(artFrame, art.Size)
    for _, ornament in art:GetDescendants() do
        if ornament:IsA("BasePart") and ornament.Transparency < 1 then
            local link = ornament:FindFirstChildOfClass("Weld")
            if link and link.Part0 == art and link.Part1 == ornament then
                front = math.min(front, frontEdge(artFrame * link.C0 * link.C1:Inverse(), ornament.Size))
            end
        end
    end
    front -= .07

    return center, width, height, front
end

function Art.buildJade(piece, center, width, height, front)
    local sashWidth = math.clamp(width * .96, .42, 1.10)
    local belt = CFrame.new(center.X + width * .36, center.Y - height * .56, front)
        * CFrame.Angles(0, 0, .10)
    piece("Woven gold edge", belt, Vector3.new(sashWidth + .07, .24, .09), brass, fabric)
    piece("Jade waist wrap", belt * CFrame.new(0, 0, -.042), Vector3.new(sashWidth, .17, .07), jade, fabric)
    local fold = belt * CFrame.new(sashWidth * .27, -.19, -.047) * CFrame.Angles(0, 0, .18)
    piece("Silk fold", fold, Vector3.new(.24, .46, .08), jade, fabric)
    piece("Mint embroidery", fold * CFrame.new(0, -.145, -.044), Vector3.new(.20, .066, .03), mint, fabric)
    piece("Jade clasp", belt * CFrame.new(sashWidth * .27, 0, -.08) * CFrame.Angles(0, 0, math.pi / 4),
        Vector3.new(.17, .17, .08), mint, Enum.Material.SmoothPlastic)
end

function Art.build(piece, center, width, height, front)
    local shoulder = CFrame.new(center.X - .68 * width, center.Y + .34 * height, front)
        * CFrame.Angles(0, 0, -.25)
    local panel = shoulder * CFrame.new(0, -.12, 0)
    piece("Mantle binding", panel, Vector3.new(.53, .79, .09), bronze, fabric)
    piece("Indigo shoulder mantle", panel * CFrame.new(0, .037, -.043), Vector3.new(.46, .68, .08), midnight, fabric)
    for index = 1, 3 do
        piece("Woven chevron", panel * CFrame.new((index - 2) * .12, -.18, -.089) * CFrame.Angles(0, 0, .48),
            Vector3.new(.043, .145, .030), thread, fabric)
    end
    piece("Mantle clasp", shoulder * CFrame.new(0, .20, -.091) * CFrame.Angles(0, 0, math.pi / 4),
        Vector3.new(.15, .15, .067), bronze, metal)

    local charm = CFrame.new(center.X - .58 * width, center.Y - .65 * height, front - .06)
        * CFrame.Angles(0, 0, .12)
    piece("Charm loop", charm * CFrame.new(0, .17, 0), Vector3.new(.057, .16, .04), bronze, metal)
    piece("Lantern charm frame", charm, Vector3.new(.23, .28, .10), bronze, metal)
    piece("Amber enamel", charm * CFrame.new(0, 0, -.057), Vector3.new(.146, .174, .037), enamel, metal)
    piece("Lantern center rib", charm * CFrame.new(0, 0, -.079), Vector3.new(.026, .185, .017), bronze, metal)
end

return Art
