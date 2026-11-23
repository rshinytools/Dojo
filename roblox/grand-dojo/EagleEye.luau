local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local EagleEye = {}

-- A Roblox Studio capture of the six districts. Request the image only when opened.
local AERIAL_IMAGE = "rbxassetid://78633320292833"
local LOAD_SECONDS = 8

local function getMovementControls(player)
    local scripts = player:FindFirstChild("PlayerScripts")
    local module = scripts and scripts:FindFirstChild("PlayerModule")
    if not module then
        return nil
    end
    local ok, controls = pcall(function()
        return require(module):GetControls()
    end)
    return if ok then controls else nil
end

function EagleEye.new(options)
    local player = options.player
    local make, button, label, style = options.make, options.button, options.label, options.style
    local palette = options.palette
    local active
    local controller = {}

    local view = make("Frame", options.gui, {
        Name = "EagleEyeView", Size = UDim2.fromScale(1, 1), BackgroundColor3 = palette.ink,
        BorderSizePixel = 0, Visible = false,
    })
    local titleCard = make("Frame", view, {
        Name = "ViewTitle", Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -154, 0, 47),
        BackgroundColor3 = palette.raised,
    })
    make("UISizeConstraint", titleCard, {MaxSize = Vector2.new(263, 47)})
    style(titleCard, 10, palette.edge)
    local title = label(titleCard, "CurrentView", 14, palette.gold, options.titleFont)
    title.Position = UDim2.fromOffset(11, 3)
    title.Size = UDim2.new(1, -22, 0, 19)
    title.Text = "EAGLE EYE"
    local subtitle = label(titleCard, "Location", 13, palette.parchment)
    subtitle.Position = UDim2.fromOffset(11, 21)
    subtitle.Size = UDim2.new(1, -22, 0, 20)
    subtitle.Text = "All six districts"
    subtitle.TextTruncate = Enum.TextTruncate.AtEnd
    local back = button(view, "Back to map", false)
    back.Name = "ReturnToMap"
    back.Position = UDim2.new(1, -132, 0, 6)
    back.Size = UDim2.fromOffset(120, 47)
    back.TextSize = 15
    back.Selectable = true

    local status = label(view, "IllustrationStatus", 15, palette.parchment)
    status.AnchorPoint = Vector2.new(.5, .5)
    status.Position = UDim2.fromScale(.5, .52)
    status.Size = UDim2.new(1, -36, 0, 32)
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Text = "Loading the valley…"

    local function updateGamepadFocus()
        if view.Visible and UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
            GuiService.SelectedObject = back
        end
    end
    UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateGamepadFocus)

    function controller:IsActive()
        return view.Visible
    end

    function controller:Close(restoreMap)
        local session = active
        if not session then
            return
        end
        active = nil
        if session.image then
            session.image:Destroy()
            session.controls:Enable()
        end
        if GuiService.SelectedObject == back then
            GuiService.SelectedObject = nil
        end
        view.Visible = false
        if session.image then
            options.onClosed(restoreMap)
        end
    end

    function controller:Open()
        if active or not player.Character then
            return
        end
        local session = {character = player.Character}
        active = session
        local controls = getMovementControls(player)
        if active ~= session then
            return
        end
        if not controls or session.character ~= player.Character then
            self:Close(true)
            options.message("Eagle Eye is unavailable here. The city map is ready.")
            return
        end
        session.controls = controls
        controls:Disable()
        status.Visible = true
        local picture = make("ImageLabel", view, {
            Name = "ValleyIllustration", Position = UDim2.fromOffset(8, 58),
            Size = UDim2.new(1, -16, 1, -66), BackgroundTransparency = 1,
            Image = AERIAL_IMAGE, ScaleType = Enum.ScaleType.Fit,
        })
        session.image = picture
        view.Visible = true
        options.onOpened()
        updateGamepadFocus()

        local deadline = os.clock() + LOAD_SECONDS
        while active == session and not picture.IsLoaded and os.clock() < deadline do
            task.wait(.12)
        end
        if active ~= session then
            return
        end
        if picture.IsLoaded then
            status.Visible = false
        else
            self:Close(true)
            options.message("The aerial picture is unavailable. You can keep using the city map.")
        end
    end

    back.Activated:Connect(function()
        controller:Close(true)
    end)
    player.CharacterRemoving:Connect(function()
        controller:Close(false)
    end)
    return controller
end

return EagleEye
