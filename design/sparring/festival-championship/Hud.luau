local festivalHud = (function()
    local Players = game:GetService("Players")
    local GuiService = game:GetService("GuiService")
    local TweenService = game:GetService("TweenService")
    local InputService = game:GetService("UserInputService")
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local rgb = Color3.fromRGB
    local ink = rgb(17, 20, 32)
    local parchment = rgb(255, 243, 214)
    local gilt = rgb(222, 168, 80)
    local darkGold = rgb(111, 65, 38)
    local ember = rgb(248, 172, 67)
    local first, second, clockLabel, banner, bannerTitle, bannerBody, bannerOutline
    local screen
    local hidden = {}
    local cueTween

    local function make(class, parent, values)
        local item = Instance.new(class)
        for name, value in values do
            item[name] = value
        end
        item.Parent = parent
        return item
    end

    local function frame(parent, name, position, size, color, layer)
        return make("Frame", parent, {
            Name = name, Position = position, Size = size, BackgroundColor3 = color,
            BorderSizePixel = 0, ZIndex = layer or 1,
        })
    end

    local function corners(item, radius)
        make("UICorner", item, { CornerRadius = UDim.new(0, radius) })
    end

    local function outline(item, color, width, transparency)
        return make("UIStroke", item, {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = color, Thickness = width, Transparency = transparency or 0,
        })
    end

    local function gradient(item, rotation, top, bottom)
        make("UIGradient", item, {
            Rotation = rotation,
            Color = ColorSequence.new(top, bottom),
        })
    end

    local function text(parent, name, value, position, size, fontSize, color, alignment)
        return make("TextLabel", parent, {
            Name = name, Text = value, Position = position, Size = size, Font = Enum.Font.GothamBold,
            TextColor3 = color, TextSize = fontSize, TextXAlignment = alignment or Enum.TextXAlignment.Center,
            BackgroundTransparency = 1, TextTruncate = Enum.TextTruncate.AtEnd,
        })
    end

    local function motionEnabled()
        return not GuiService.ReducedMotionEnabled and not InputService.VREnabled
    end

    local function tween(object, duration, properties, delaySeconds)
        local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delaySeconds or 0)
        local taskTween = TweenService:Create(object, info, properties)
        taskTween:Play()
        return taskTween
    end

    local function side(parent, title, isRight, maxHealth, healthTop, healthBottom)
        local x = if isRight then 1 else 0
        local align = if isRight then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left
        local shell = frame(parent, title, UDim2.new(x, 0, 0, 9), UDim2.new(.5, -39, 0, 68), darkGold)
        shell.AnchorPoint = Vector2.new(x, 0)
        corners(shell, 10)
        outline(shell, gilt, 1.5)
        gradient(shell, 90, rgb(198, 130, 61), rgb(77, 44, 44))
        local inset = frame(shell, "Inner enamel", UDim2.fromOffset(3, 3), UDim2.new(1, -6, 1, -6), ink)
        corners(inset, 8)
        gradient(inset, 90, rgb(33, 29, 48), rgb(18, 21, 33))

        text(inset, "Fighter name", title, UDim2.fromOffset(9, 4), UDim2.new(1, -18, 0, 18), 15, parchment, align)
        local track = frame(inset, "Health well", UDim2.fromOffset(9, 27), UDim2.new(1, -18, 0, 24), rgb(14, 16, 26))
        corners(track, 5)
        outline(track, darkGold, 1)

        local function layer(name, color, order)
            local item = frame(track, name, UDim2.fromScale(x, 0), UDim2.fromScale(1, 1), color, order)
            item.AnchorPoint = Vector2.new(x, 0)
            corners(item, 5)
            return item
        end

        local trail = layer("Delayed amber damage", ember, 2)
        gradient(trail, 90, rgb(255, 217, 121), rgb(223, 97, 36))
        local fill = layer("Current health", parchment, 3)
        gradient(fill, 90, healthTop, healthBottom)
        local sheen = layer("Damage glint", parchment, 4)
        sheen.BackgroundTransparency = 1
        for division = 1, 3 do
            local mark = frame(track, "Etched division", UDim2.fromScale(division / 4, .12),
                UDim2.new(0, 1, .76, 0), rgb(24, 18, 28), 5)
            mark.BackgroundTransparency = .77
        end
        local numbers = text(track, "Health value", string.format("%d / %d", maxHealth, maxHealth),
            UDim2.fromOffset(6, 0), UDim2.new(1, -12, 1, 0), 13, parchment, align)
        numbers.ZIndex = 6
        numbers.TextStrokeColor3 = rgb(20, 18, 28)
        numbers.TextStrokeTransparency = .15

        local damage = text(inset, "Damage amount", "", UDim2.fromOffset(9, 43),
            UDim2.new(1, -18, 0, 18), 19, rgb(255, 203, 132),
            if isRight then Enum.TextXAlignment.Left else Enum.TextXAlignment.Right)
        damage.TextStrokeColor3 = ink
        damage.TextStrokeTransparency = 1
        damage.ZIndex = 7
        damage.TextTransparency = 1
        local previous = maxHealth
        local fillTween, trailTween, glintTween, damageTween

        return function(health)
            local bounded = math.clamp(math.floor(health), 0, maxHealth)
            if bounded == previous then
                return
            end
            for _, active in {fillTween, trailTween, glintTween, damageTween} do
                active:Cancel()
            end
            local amount = previous - bounded
            local target = UDim2.fromScale(bounded / maxHealth, 1)
            numbers.Text = string.format("%d / %d", bounded, maxHealth)
            if amount <= 0 or not motionEnabled() then
                fill.Size, trail.Size = target, target
                sheen.BackgroundTransparency = 1
                damage.TextTransparency, damage.TextStrokeTransparency = 1, 1
            else
                trail.Size = UDim2.fromScale(math.max(trail.Size.X.Scale, previous / maxHealth), 1)
                fillTween = tween(fill, .12, {Size = target})
                trailTween = tween(trail, .38, {Size = target}, .31)
                sheen.Size = UDim2.fromScale(previous / maxHealth, 1)
                sheen.BackgroundTransparency = .58
                glintTween = tween(sheen, .23, {BackgroundTransparency = 1})
                damage.Text = "−" .. amount
                damage.Position = UDim2.fromOffset(9, 45)
                damage.TextTransparency, damage.TextStrokeTransparency = 0, .25
                damageTween = tween(damage, .37, {
                    Position = UDim2.fromOffset(9, 34),
                    TextTransparency = 1, TextStrokeTransparency = 1,
                }, .26)
            end
            previous = bounded
        end
    end

    local cues = {
        ready = { "GET READY", gilt },
        fight = { "FIGHT", rgb(255, 215, 124) },
        strike = { "STRIKE", rgb(255, 184, 113) },
        block = { "BLOCK", rgb(156, 205, 242) },
        parry = { "PARRY", rgb(150, 237, 217) },
        counter = { "COUNTER", rgb(255, 194, 107) },
        ko = { "KNOCKOUT", rgb(255, 215, 124) },
        guard = { "GUARD", rgb(156, 205, 242) },
        windup = { "WINDUP", rgb(255, 186, 109) },
        victory = { "VICTORY", rgb(255, 215, 124) },
    }
    cues.blocked, cues.parried, cues.win = cues.block, cues.parry, cues.victory

    local function hide()
        if screen then
            screen:Destroy()
            screen = nil
        end
        for original, priorVisibility in hidden do
            if original.Parent then
                original.Visible = priorVisibility
            end
        end
        table.clear(hidden)
    end

    local function show()
        hide()
        local previous = playerGui:FindFirstChild("FestivalChampionshipHUD")
        if previous then
            previous:Destroy()
        end
        local originalGui = playerGui:FindFirstChild("GrandDojo")
        if originalGui then
            for _, name in {"Location", "SparringHUD"} do
                local original = originalGui:FindFirstChild(name)
                if original and original:IsA("GuiObject") then
                    hidden[original] = original.Visible
                    original.Visible = false
                end
            end
        end
        screen = make("ScreenGui", playerGui, {
            Name = "FestivalChampionshipHUD", ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
            DisplayOrder = 35, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        local holder = frame(screen, "Festival Championship", UDim2.new(.5, 0, 0, 12),
            UDim2.new(.94, 0, 0, 76), ink)
        holder.AnchorPoint = Vector2.new(.5, 0)
        holder.BackgroundTransparency = 1
        make("UISizeConstraint", holder, {MaxSize = Vector2.new(945, 76)})

        first = side(holder, "Reedguard", false, 100, rgb(227, 116, 67), rgb(121, 41, 57))
        second = side(holder, "Juniper Tortoise", true, 90, rgb(84, 163, 139), rgb(34, 82, 94))

        local crest = frame(holder, "Timer crest", UDim2.new(.5, 0, 0, 39),
            UDim2.fromOffset(58, 58), rgb(106, 69, 44))
        crest.AnchorPoint = Vector2.new(.5, .5)
        crest.Rotation = 45
        corners(crest, 8)
        outline(crest, gilt, 1.5)
        gradient(crest, 90, rgb(208, 144, 75), rgb(91, 47, 50))
        local inset = frame(crest, "Inlaid timer crest", UDim2.fromOffset(4, 4), UDim2.new(1, -8, 1, -8), ink)
        corners(inset, 7)
        outline(inset, darkGold, 1.2)
        gradient(inset, 90, rgb(51, 39, 64), rgb(23, 23, 37))
        local timerLabel = text(holder, "Round type", "BOT SPAR", UDim2.new(.5, -29, 0, 22),
            UDim2.fromOffset(58, 14), 9, gilt)
        timerLabel.ZIndex = 3
        clockLabel = text(holder, "Round clock", "0:45", UDim2.new(.5, -34, 0, 35),
            UDim2.fromOffset(68, 24), 21, parchment)
        clockLabel.ZIndex = 3

        banner = frame(screen, "Exchange caption", UDim2.new(.5, 0, 0, 102),
            UDim2.new(.88, 0, 0, 38), rgb(26, 24, 37))
        banner.BackgroundTransparency = .09
        banner.AnchorPoint = Vector2.new(.5, 0)
        corners(banner, 8)
        bannerOutline = outline(banner, gilt, 1.25, .2)
        gradient(banner, 90, rgb(35, 30, 46), rgb(20, 21, 34))
        make("UISizeConstraint", banner, {MaxSize = Vector2.new(300, 62)})
        bannerTitle = text(banner, "Action", "", UDim2.fromOffset(8, 4),
            UDim2.new(1, -16, 0, 30), 21, gilt)
        bannerBody = text(banner, "Instruction", "", UDim2.fromOffset(8, 31),
            UDim2.new(1, -16, 0, 19), 13, parchment)
        banner.Visible = false
    end

    local function cue(key, subtitle)
        if not screen then
            return
        end
        local definition = cues[key]
        if not definition then
            banner.Visible = false
            return
        end
        if cueTween then
            cueTween:Cancel()
        end
        local hasSubtitle = type(subtitle) == "string" and subtitle ~= ""
        banner.Size = UDim2.new(.88, 0, 0, if hasSubtitle then 54 else 38)
        bannerTitle.Text, bannerTitle.TextColor3 = definition[1], definition[2]
        bannerBody.Visible = hasSubtitle
        bannerBody.Text = if hasSubtitle then subtitle else ""
        bannerOutline.Color = definition[2]
        bannerOutline.Transparency = .2
        if motionEnabled() then
            bannerOutline.Transparency = .06
            cueTween = tween(bannerOutline, .19, {Transparency = .32})
        end
        banner.Visible = true
    end

    return {
        show = show,
        health = function(reedHealth, juniperHealth)
            if screen then
                first(reedHealth)
                second(juniperHealth)
            end
        end,
        clock = function(seconds)
            if screen then
                local whole = math.max(0, math.ceil(seconds))
                clockLabel.Text = string.format("%d:%02d", math.floor(whole / 60), whole % 60)
            end
        end,
        cue = cue,
        hide = hide,
    }
end)()
