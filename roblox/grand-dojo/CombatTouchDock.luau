-- Position every combat action outside the stock movement and jump regions when space permits.
local Dock = {}
local spacing = 4
local minimum = 44
local stockNames = {DynamicThumbstickFrame = true, ThumbstickFrame = true, JumpButton = true}

local function bounds(native, inset, name)
    local widget = native and native:FindFirstChild(name, true)
    if not widget or not widget:IsA("GuiObject") or not widget.Visible or widget.AbsoluteSize.X <= 0
        or widget.AbsoluteSize.Y <= 0 then return nil end
    local parent = widget.Parent
    while parent and parent ~= native do
        if parent:IsA("GuiObject") and not parent.Visible then return nil end
        parent = parent.Parent
    end
    local position, size = widget.AbsolutePosition, widget.AbsoluteSize
    return {left = position.X - inset.X, top = position.Y - inset.Y,
        right = position.X + size.X - inset.X, bottom = position.Y + size.Y - inset.Y}
end

local function obstacles(playerGui, inset, width, height)
    local native = playerGui:FindFirstChild("TouchGui")
    native = if native and native.Enabled then native else nil
    local landscape = width >= height
    local large = math.min(width, height) > 500
    local jumpInset = if large then 172 else 96
    local jumpTop = height - (if large then 210 else 90)
    local stick = bounds(native, inset, "DynamicThumbstickFrame") or bounds(native, inset, "ThumbstickFrame")
        or {left = 0, top = if landscape then height / 3 else height * .6,
            right = if landscape then width * .4 else width, bottom = height}
    local jump = bounds(native, inset, "JumpButton")
        or {left = width - jumpInset, right = width, top = jumpTop, bottom = height}
    return stick, jump
end

local function intersects(a, b)
    return a.left < b.right and b.left < a.right and a.top < b.bottom and b.top < a.bottom
end

local function grid(spec, left, top, right, bottom, minimumTarget, columns)
    local width, height = right - left, bottom - top
    if width <= 0 or height <= 0 then return nil end
    local rows = math.ceil(spec.count / columns)
    local gap = math.min(spacing, width / columns * .2, height / rows * .2)
    local w = math.min(width, columns * spec.cellWidth)
    local rowHeight = math.min(spec.rowHeight, (height - (rows - 1) * gap) / rows)
    if w / columns - gap < minimumTarget or rowHeight < minimumTarget then return nil end
    local h = rows * (rowHeight + gap) - gap
    local x = left + (width - w) / 2
    local y = math.clamp(spec.bottom - h, top, math.max(top, bottom - h))
    return {x = x, y = y, w = w, h = h, columns = columns, rowHeight = rowHeight, gap = gap}
end

local function preferredGrid(spec, left, top, right, bottom, target)
    local columns = math.min(spec.columns, spec.count)
    return grid(spec, left, top, right, bottom, target, columns)
        or (columns > 1 and grid(spec, left, top, right, bottom, target, columns - 1) or nil)
end

local function inRegion(spec, left, top, right, bottom, minimumTarget)
    local board = preferredGrid(spec, left, top, right, bottom, minimumTarget)
    local exit = spec.extra
    if not board or not exit or not intersects(
        {left = board.x, top = board.y, right = board.x + board.w, bottom = board.y + board.h}, exit) then
        return board
    end
    -- One protected control can cut into a direct dock region on compact screens.
    return preferredGrid(spec, left, top, math.min(right, exit.left), bottom, minimumTarget)
        or preferredGrid(spec, math.max(left, exit.right), top, right, bottom, minimumTarget)
        or preferredGrid(spec, left, top, right, math.min(bottom, exit.top), minimumTarget)
        or preferredGrid(spec, left, math.max(top, exit.bottom), right, bottom, minimumTarget)
end

function Dock.layout(playerGui, inset, width, height, spec)
    if width <= 0 or height <= 0 or spec.count == 0 then return nil end
    local stick, jump = obstacles(playerGui, inset, width, height)
    local stickRight = math.clamp(math.ceil(stick.right), 0, width)
    local jumpLeft = math.clamp(math.floor(jump.left) - 1, 0, width)
    local above = math.clamp(math.min(stick.top, jump.top) - spacing, 0, height)
    local aboveJump = math.clamp(jump.top - spacing, 0, height)
    local belowJump = math.clamp(jump.bottom + spacing, 0, height)
    local below = math.clamp(math.max(stick.bottom, jump.bottom) + spacing, 0, height)
    local function place(top, target)
        if width >= height then
            local side = inRegion(spec, stickRight, top, jumpLeft, height, target)
                or inRegion(spec, stickRight, top, width, aboveJump, target)
                or inRegion(spec, stickRight, math.max(top, belowJump), width, height, target)
            if side then return side end
        end
        return inRegion(spec, 0, top, width, above, target)
            or inRegion(spec, 0, math.max(top, below), width, height, target)
    end
    local top = math.clamp(spec.top, 0, height)
    -- Prefer leaving the upper HUD clear, then relax it if only the area above Roblox's controls is available.
    local fitted = place(top, minimum) or place(0, minimum)
    if fitted then return fitted end
    -- Favor the largest minimum touch dimension across only the direct regions.
    local best
    for _, candidate in {
        inRegion(spec, stickRight, 0, jumpLeft, height, 0),
        inRegion(spec, stickRight, 0, width, aboveJump, 0),
        inRegion(spec, stickRight, belowJump, width, height, 0),
        inRegion(spec, 0, 0, width, above, 0),
        inRegion(spec, 0, below, width, height, 0),
    } do
        local size = math.min(candidate.w / candidate.columns - candidate.gap, candidate.rowHeight)
        if not best or size > math.min(best.w / best.columns - best.gap, best.rowHeight) then best = candidate end
    end
    return best or preferredGrid(spec, 0, 0, width, height, 0)
end

function Dock.observe(playerGui, changed)
    local native, pending, needsBind
    local connections = {}
    local function request(rebind)
        needsBind = needsBind or rebind
        if pending then return end
        pending = true
        task.defer(function()
            pending = false
            if needsBind then
                needsBind = false
                for _, connection in connections do connection:Disconnect() end
                table.clear(connections)
                native = playerGui:FindFirstChild("TouchGui")
                if native then
                    table.insert(connections, native:GetPropertyChangedSignal("Enabled"):Connect(function() request(false) end))
                    local watched = {}
                    for name in stockNames do
                        local widget = native:FindFirstChild(name, true)
                        if widget and widget:IsA("GuiObject") then
                            for _, property in {"Visible", "AbsolutePosition", "AbsoluteSize"} do
                                table.insert(connections, widget:GetPropertyChangedSignal(property):Connect(function() request(false) end))
                            end
                            local parent = widget.Parent
                            while parent and parent ~= native do
                                if parent:IsA("GuiObject") and not watched[parent] then
                                    watched[parent] = true
                                    table.insert(connections, parent:GetPropertyChangedSignal("Visible"):Connect(function() request(false) end))
                                end
                                parent = parent.Parent
                            end
                        end
                    end
                    local function rebindWidget(widget)
                        if stockNames[widget.Name] then request(true) end
                    end
                    table.insert(connections, native.DescendantAdded:Connect(rebindWidget))
                    table.insert(connections, native.DescendantRemoving:Connect(rebindWidget))
                end
            end
            changed()
        end)
    end
    playerGui.ChildAdded:Connect(function(child) if child.Name == "TouchGui" then request(true) end end)
    playerGui.ChildRemoved:Connect(function(child) if child == native then request(true) end end)
    request(true)
end

return table.freeze(Dock)
