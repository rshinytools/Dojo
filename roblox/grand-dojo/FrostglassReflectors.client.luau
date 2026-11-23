local Players = game:GetService("Players")
local player = Players.LocalPlayer

local PROGRESS_ATTRIBUTE = "FrostglassReflectorProgress"
local headingNames = {"East", "Southeast", "Northeast"}
local idlePigment = Color3.fromRGB(143, 188, 204)
local restoredPigment = Color3.fromRGB(213, 238, 219)

local function findPuzzle()
    local city = workspace:FindFirstChild("Grand Dojo City")
    local districts = city and city:FindFirstChild("Connected districts")
    local garden = districts and districts:FindFirstChild("Frostglass Gardens")
    return garden and garden:FindFirstChild("Frostglass Reflectors")
end

local function status(station, text)
    local hub = station:FindFirstChild("Hub")
    local caption = hub and hub:FindFirstChild("Caption")
    local label = caption and caption:FindFirstChild("Status")
    if label then
        label.Text = text
    end
    return hub
end

local function update()
    local puzzle = findPuzzle()
    if not puzzle then
        return
    end

    local state = player:GetAttribute(PROGRESS_ATTRIBUTE) or "113:1:0"
    local first, second, third, lit, count = string.match(state, "^([1-3])([1-3])([1-3]):([1-4]):(%d+)$")
    if not first then
        return
    end
    local headings = {tonumber(first), tonumber(second), tonumber(third)}
    local reached, clears = tonumber(lit), tonumber(count)
    local solved = reached == 4

    local source = puzzle:FindFirstChild("Source")
    if source then
        local input = source:FindFirstChild("InputRay")
        if input then
            input.Enabled = true
        end
        status(source, string.format("Source • Session clears %d", clears))
    end

    for index, heading in headings do
        local station = puzzle:FindFirstChild("Lens" .. index)
        if not station then
            continue
        end
        local hub = status(station, string.format("Lens %d • %s", index, headingNames[heading]))
        local interact = hub and hub:FindFirstChild("Interact")
        if interact then
            interact.Enabled = not solved
        end

        for choice = 1, #headingNames do
            local direction = station:FindFirstChild("Direction" .. choice)
            if not direction then
                continue
            end
            local selected = choice == heading
            for _, detail in direction:GetChildren() do
                if detail:IsA("Beam") then
                    detail.Enabled = selected and index <= reached
                elseif detail.Name == "Pointer" then
                    detail.Transparency = if selected then 0 else 1
                end
            end
        end
    end

    local receiver = puzzle:FindFirstChild("Receiver")
    if receiver then
        local text = if solved then "Light restored! Reset at source to replay" else "Receiver • Awaiting light"
        local hub = status(receiver, text)
        if hub then
            hub.Color = if solved then restoredPigment else idlePigment
        end
    end
end

player:GetAttributeChangedSignal(PROGRESS_ATTRIBUTE):Connect(update)
workspace.DescendantAdded:Connect(function(child)
    -- Atomic streaming brings the props and their beams back as a group.
    if child.Name == "Frostglass Reflectors" then
        task.defer(update)
    end
end)
update()
