-- One resident per venue. Damage and tells are read by the round authority.
return {
    juniper = {
        name = "Juniper Tortoise", health = 90, pace = 5.8, style = "Patient defense", tint = Color3.fromRGB(111, 207, 158),
        attacks = {
            {name = "Stillwater Palm", damage = 22, windup = .95, reach = 6.4, recovery = 1.10, shape = "arc"},
            {name = "Stillwater Palm", damage = 22, windup = .95, reach = 6.4, recovery = 1.10, shape = "arc",
                setup = "Shell Set", setupTime = .8, brace = true},
        },
    },
    bracken = {
        name = "Bracken Boar", health = 110, pace = 8, style = "Forward pressure", tint = Color3.fromRGB(255, 160, 104),
        attacks = {
            {name = "Kiln Rush", damage = 28, windup = .90, reach = 9, width = 1.9, recovery = 1.25, shape = "lane",
                setup = "Bellows Step", setupTime = .39, advance = 1.15},
            {name = "Kiln Jab", damage = 22, windup = .73, reach = 6.4, recovery = .9, shape = "arc"},
        },
    },
    sablecrest = {
        name = "Sablecrest Lynx", health = 78, pace = 9.1, style = "Feints and timing", tint = Color3.fromRGB(177, 166, 250),
        attacks = {
            {name = "Wind Court Return", damage = 24, windup = .72, reach = 8.5, width = 1.35, recovery = 1.06, shape = "lane",
                setup = "Chime Crossstep", setupTime = .39, strafe = 1.35},
            {name = "Wind Jab", damage = 16, windup = .65, reach = 5.9, recovery = .82, shape = "arc"},
        },
    },
    granite = {
        name = "Granite Rhino", health = 145, pace = 5.2, style = "Space control", tint = Color3.fromRGB(142, 196, 242),
        attacks = {
            {name = "Harbor Sweep", damage = 29, windup = 1, reach = 7.35, recovery = 1.15, shape = "arc"},
            {name = "Breakwater Stamp", damage = 34, windup = 1.2, reach = 7.8, recovery = 1.42, shape = "circle"},
        },
    },
}
