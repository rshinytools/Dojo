local ContextActionService = game:GetService("ContextActionService")
local Rescue = require(script.Parent:WaitForChild("QuickPlayRescue"))

local RescueView = {}
RescueView.__index = RescueView

local DIRECTION_ACTION = "BeastDojoQuickPlayRescueDirection"
local DIRECTION_KEYS = {
    [Enum.KeyCode.Up] = -3, [Enum.KeyCode.W] = -3, [Enum.KeyCode.DPadUp] = -3,
    [Enum.KeyCode.Down] = 3, [Enum.KeyCode.S] = 3, [Enum.KeyCode.DPadDown] = 3,
    [Enum.KeyCode.Left] = -1, [Enum.KeyCode.A] = -1, [Enum.KeyCode.DPadLeft] = -1,
    [Enum.KeyCode.Right] = 1, [Enum.KeyCode.D] = 1, [Enum.KeyCode.DPadRight] = 1,
}

local COLORS = {
    stone = Color3.fromRGB(30, 67, 67),
    current = Color3.fromRGB(21, 35, 60),
    dock = Color3.fromRGB(103, 56, 42),
    lantern = Color3.fromRGB(111, 77, 35),
    line = Color3.fromRGB(98, 138, 142),
    currentLine = Color3.fromRGB(78, 123, 179),
    cream = Color3.fromRGB(253, 240, 209),
    paleBlue = Color3.fromRGB(172, 213, 243),
    gold = Color3.fromRGB(255, 200, 112),
}

local function create(class, parent, properties)
    local instance = Instance.new(class)
    for name, value in pairs(properties) do
        instance[name] = value
    end
    instance.Parent = parent
    return instance
end

function RescueView.mount(parent, onMove)
    local board = create("Frame", parent, {
        Name = "ReedfallBoard",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })
    create("UIGridLayout", board, {
        CellSize = UDim2.new(1 / 3, -5, 1 / 3, -5),
        CellPadding = UDim2.fromOffset(7, 7),
        FillDirectionMaxCells = 3,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local self = setmetatable({board = board, tiles = {}, onMove = onMove}, RescueView)
    for index = 1, Rescue.TileCount do
        local tile = create("TextButton", board, {
            Name = "Tile" .. index,
            LayoutOrder = index,
            BackgroundColor3 = COLORS.stone,
            TextColor3 = COLORS.cream,
            Font = Enum.Font.GothamBold,
            TextScaled = true,
            TextWrapped = true,
            AutoButtonColor = false,
            Selectable = false,
            Text = "",
        })
        create("UICorner", tile, {CornerRadius = UDim.new(0, 8)})
        create("UIPadding", tile, {
            PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        })
        create("UITextSizeConstraint", tile, {MinTextSize = 11, MaxTextSize = 19})
        local stroke = create("UIStroke", tile, {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1})
        self.tiles[index] = {button = tile, stroke = stroke}
        tile.Activated:Connect(function()
            if self.round then
                self.onMove(index)
            end
        end)
    end

    local keys = {}
    for key in pairs(DIRECTION_KEYS) do
        table.insert(keys, key)
    end
    ContextActionService:BindActionAtPriority(DIRECTION_ACTION, function(_, inputState, input)
        if not self.round then
            return Enum.ContextActionResult.Pass
        end
        if inputState == Enum.UserInputState.Begin then
            local destination = self.round.position + DIRECTION_KEYS[input.KeyCode]
            if Rescue.neighbors(self.round.position, destination) then
                self.onMove(destination)
            end
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.ContextActionPriority.High.Value, table.unpack(keys))
    return self
end

function RescueView:render(round)
    self.round = round
    local currents = Rescue.currents(round.score)
    local target = Rescue.target(round)
    for index, tile in ipairs(self.tiles) do
        local selected = index == round.position
        local paint = "stone"
        local name = "Stone"
        if index == Rescue.Dock then
            paint, name = "dock", "Dock"
        elseif index == target then
            paint, name = "lantern", "Lantern"
        elseif currents[index] then
            paint, name = "current", "≈ Current"
        end

        local label = name
        if selected then
            label = if round.holding then "You · Carrying" else "You · " .. name
        end
        tile.button.Text = label
        tile.button.BackgroundColor3 = COLORS[paint]
        tile.button.TextColor3 = if paint == "current" then COLORS.paleBlue else COLORS.cream
        tile.stroke.Color = if selected or index == target then COLORS.gold
            elseif paint == "current" then COLORS.currentLine else COLORS.line
        tile.stroke.Thickness = if selected then 3 elseif index == target then 2 else 1
    end
end

function RescueView:destroy()
    ContextActionService:UnbindAction(DIRECTION_ACTION)
    self.round = nil
    self.board:Destroy()
end

return table.freeze(RescueView)
