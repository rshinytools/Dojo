-- Beast Dojo UI design tokens. Design proposal; verify rendering in Roblox Studio.
-- Source: design/ui-system.json. Generated without third-party runtime dependencies.
local Theme = {}

Theme.Colors = {
    ink = Color3.fromRGB(24, 43, 53), -- #182B35
    surface = Color3.fromRGB(34, 59, 69), -- #223B45
    elevated = Color3.fromRGB(46, 74, 82), -- #2E4A52
    parchment = Color3.fromRGB(247, 240, 220), -- #F7F0DC
    paper = Color3.fromRGB(255, 249, 233), -- #FFF9E9
    mutedDark = Color3.fromRGB(180, 196, 195), -- #B4C4C3
    mutedLight = Color3.fromRGB(77, 99, 104), -- #4D6368
    borderDark = Color3.fromRGB(112, 141, 151), -- #708D97
    borderLight = Color3.fromRGB(185, 199, 190), -- #B9C7BE
    gold = Color3.fromRGB(244, 189, 79), -- #F4BD4F
    goldPressed = Color3.fromRGB(217, 156, 45), -- #D99C2D
    jade = Color3.fromRGB(84, 213, 175), -- #54D5AF
    jadePressed = Color3.fromRGB(42, 184, 143), -- #2AB88F
    land = Color3.fromRGB(141, 216, 120), -- #8DD878
    aquatic = Color3.fromRGB(107, 203, 242), -- #6BCBF2
    magma = Color3.fromRGB(255, 146, 116), -- #FF9274
    sky = Color3.fromRGB(245, 212, 107), -- #F5D46B
    health = Color3.fromRGB(104, 211, 145), -- #68D391
    danger = Color3.fromRGB(255, 141, 147), -- #FF8D93
    warning = Color3.fromRGB(245, 212, 107), -- #F5D46B
    success = Color3.fromRGB(84, 213, 175), -- #54D5AF
    focus = Color3.fromRGB(255, 255, 255), -- #FFFFFF
    common = Color3.fromRGB(202, 213, 219), -- #CAD5DB
    rare = Color3.fromRGB(124, 185, 255), -- #7CB9FF
    epic = Color3.fromRGB(202, 173, 255), -- #CAADFF
    legendary = Color3.fromRGB(244, 189, 79), -- #F4BD4F
    mythic = Color3.fromRGB(247, 151, 199), -- #F797C7
}

Theme.Fonts = {
    Display = Font.new("rbxasset://fonts/families/FredokaOne.json"),
    Body = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular),
    Label = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
    Heading = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
}

Theme.Spacing = {4, 8, 12, 16, 24, 32, 48}
Theme.Radius = {Chip = 8, Button = 12, Panel = 20, Dialog = 24}
Theme.Targets = {MenuMinimum = 48, CombatPreferred = 60, GapMinimum = 8}
Theme.Motion = {Press = 0.08, Panel = 0.18, Reward = 0.30}
Theme.TextSize = {Meta = 12, Body = 16, Label = 14, Subheading = 22, Heading = 28, Display = 36}

Theme.Modes = {
    light = {
        canvas = Theme.Colors.parchment,
        panel = Theme.Colors.paper,
        raised = Color3.fromRGB(239, 230, 208),
        text = Theme.Colors.ink,
        muted = Theme.Colors.mutedLight,
        controlBoundary = Theme.Colors.mutedLight,
    },
    dark = {
        canvas = Theme.Colors.ink,
        panel = Theme.Colors.surface,
        raised = Theme.Colors.elevated,
        text = Theme.Colors.parchment,
        muted = Theme.Colors.mutedDark,
        controlBoundary = Theme.Colors.borderDark,
    },
}

-- Element and rarity meaning must also be carried by labels and icons.
-- Core UI safe areas, player preferences and input hints require implementation.
return Theme
