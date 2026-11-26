local Art = {}

Art.Name = "Midnight Lantern Set"
Art.Description = "Indigo shoulder mantle and a bronze lantern charm. Cosmetic apparel."

local midnight = Color3.fromRGB(39, 43, 86)
local thread = Color3.fromRGB(104, 123, 190)
local bronze = Color3.fromRGB(213, 151, 81)
local enamel = Color3.fromRGB(255, 211, 122)
local fabric = Enum.Material.Fabric
local metal = Enum.Material.SmoothPlastic

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
