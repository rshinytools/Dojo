local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Catalog = require(script.Parent.TrophyCatalog)
local Art = require(script.Parent.TrophyArt)

local districts = {["world-04"] = "Dojo Valley", ["mastery-sky"] = "Skywalk Peaks", ["arena-01"] = "Grand Dojo Ring"}
local ink = Color3.fromRGB(39,27,41)
local gold = Color3.fromRGB(219,163,102)
local paper = Color3.fromRGB(255,241,216)
local mint = Color3.fromRGB(163,228,211)

local function make(class, parent, properties)
    local object = Instance.new(class)
    for key, value in properties do object[key] = value end
    object.Parent = parent
    return object
end

local function label(parent, name, copy, size, tint, font, position, dimensions)
    return make("TextLabel", parent, {
        Name = name, Text = copy, TextSize = size, TextColor3 = tint, Font = font,
        Position = position, Size = dimensions, TextWrapped = true,
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
    })
end

local Exhibit = {}

function Exhibit.new(parent, onClose)
    local panel = make("Frame", parent, {
        Name = "TrophyExhibit", BackgroundColor3 = ink, BorderSizePixel = 0, Visible = false, Active = true,
    })
    panel.ClipsDescendants = true
    make("UICorner", panel, {CornerRadius = UDim.new(0, 12)})
    make("UIStroke", panel, {Color = gold, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    local header = make("Frame", panel, {
        Name = "LacquerHeader", Size = UDim2.new(1,0,0,44),
        BackgroundColor3 = Color3.fromRGB(91,45,48), BorderSizePixel = 0,
    })
    label(header, "Section", "Trophy exhibit", 16, paper, Enum.Font.GothamBold,
        UDim2.fromOffset(13,0), UDim2.new(1,-64,1,0))
    local close = make("TextButton", header, {
        Name = "CloseExhibit", Text = "×", TextSize = 23, Font = Enum.Font.GothamBold,
        TextColor3 = paper, BackgroundColor3 = Color3.fromRGB(110,61,60), BorderSizePixel = 0,
        Position = UDim2.new(1,-44,0,0), Size = UDim2.fromOffset(44,44), Selectable = true,
    })
    local art = make("ViewportFrame", panel, {
        Name = "Sculpture", BackgroundColor3 = Color3.fromRGB(58,37,48), BorderSizePixel = 0,
    })
    local district = label(panel, "District", "", 13, mint, Enum.Font.GothamBold,
        UDim2.fromOffset(0,0), UDim2.fromOffset(0,19))
    local title = label(panel, "ExhibitTitle", "", 25, paper, Enum.Font.Fondamento,
        UDim2.fromOffset(0,0), UDim2.fromOffset(0,57))
    local earn = label(panel, "HowToEarn", "How to earn", 13, gold, Enum.Font.GothamBold,
        UDim2.fromOffset(0,0), UDim2.fromOffset(0,19))
    local criterion = label(panel, "Criterion", "", 14, paper, Enum.Font.GothamMedium,
        UDim2.fromOffset(0,0), UDim2.fromOffset(0,56))
    for _, text in {district,title,earn,criterion} do text.TextYAlignment = Enum.TextYAlignment.Top end

    local function resize()
        local view = parent.AbsoluteSize
        local compact = view.X < 820 or view.Y < 430 or UserInputService.TouchEnabled
        local width = math.clamp(view.X - 24, 1, if compact then 382 else 420)
        panel.Size = UDim2.fromOffset(width, 210)
        panel.AnchorPoint = if compact then Vector2.new(.5,1) else Vector2.new(1,1)
        panel.Position = if compact then UDim2.new(.5,0,1,-12) else UDim2.new(1,-16,1,-20)
        local artWidth = math.floor(width * .38)
        art.Size, art.Position = UDim2.fromOffset(artWidth,144), UDim2.fromOffset(11,55)
        local x, copyWidth = artWidth + 22, width - artWidth - 33
        district.Size, district.Position = UDim2.fromOffset(copyWidth,19), UDim2.fromOffset(x,55)
        title.Size, title.Position = UDim2.fromOffset(copyWidth,54), UDim2.fromOffset(x,76)
        title.TextSize = if width < 340 then 21 else 25
        earn.Size, earn.Position = UDim2.fromOffset(copyWidth,18), UDim2.fromOffset(x,132)
        criterion.Size, criterion.Position = UDim2.fromOffset(copyWidth,52), UDim2.fromOffset(x,151)
        criterion.TextSize = if width < 340 then 13 else 14
    end
    parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
    resize()
    close.Activated:Connect(onClose)

    return {
        Show = function(_, id)
            local trophy = Catalog.byId[id]
            if not trophy or not districts[id] then return end
            district.Text, title.Text, criterion.Text = districts[id], trophy.title, trophy.criterion
            Art.preview(art,id)
            make("UICorner", art, {CornerRadius = UDim.new(0,8)})
            panel.Visible = true
            if UserInputService.GamepadEnabled then GuiService.SelectedObject = close end
        end,
        Hide = function()
            if GuiService.SelectedObject == close then GuiService.SelectedObject = nil end
            panel.Visible = false
            art.CurrentCamera = nil
            art:ClearAllChildren()
        end,
    }
end

return Exhibit
