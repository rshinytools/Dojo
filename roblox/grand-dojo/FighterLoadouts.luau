-- Technique choices stay in FighterTactics and keep their existing save keys.
local reedguard = {
    kit = "reedguard",
    basic = {
        attribute = "ReedguardBasic", default = "jab",
        options = {
            {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                description = "Open with a straight right jab, then follow with a cross and kick."},
            {id = "reedCheck", name = "Reed Check", compact = "Check", action = "strike", level = 5, planted = true,
                description = "A quick left-glove check opens the combo from a planted stance."},
            {id = "courtyardToe", name = "Courtyard Toe", compact = "Toe", action = "strike", level = 10, planted = true,
                description = "A low toe strike opens the combo while the other foot stays planted."},
        },
    },
    ultimate = {
        attribute = "ReedguardUltimate", default = "reedstep",
        options = {
            {id = "reedstep", name = "Reedstep Rising", compact = "Rising", action = "signature", level = 1,
                description = "A timed parry opens a short window for this three-hit rising combo."},
            {id = "lanternBreak", name = "Lantern Break", compact = "Lantern", action = "signature", level = 5,
                planted = true, cooldown = 20, floorPulse = true, description = "Both gloves strike the mat and send a short pulse along the floor."},
            {id = "festivalCross", name = "Festival Cross", compact = "Cross", action = "signature", level = 10,
                planted = true, cooldown = 20, description = "Two deliberate mitt strikes land in sequence from a planted stance."},
        },
    },
}

local byFighter = {
    ["reedguard-kangaroo"] = reedguard,
    ["penguin-brawler"] = {
        kit = "penguin",
        basic = {
            attribute = "PenguinBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start the combo with a straight flipper strike."},
                {id = "rimeTap", name = "Rime Tap", compact = "Rime", action = "strike", level = 5,
                    planted = true, description = "Snap out a short flipper strike to start the combo."},
                {id = "skateToe", name = "Skate Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true, description = "Balance on one boot and flick the other toe forward."},
            },
        },
        ultimate = {
            attribute = "PenguinUltimate", default = "bellySlide",
            options = {
                {id = "bellySlide", name = "Belly-Slide Blitz", compact = "Slide", action = "signature", level = 1,
                    description = "Slide forward along the mat to catch a fighter in your path."},
                {id = "glacierRing", name = "Glacier Ring", compact = "Glacier", action = "signature", level = 5,
                    planted = true, cooldown = 20, floorPulse = true, description = "Raise both flippers, then send an icy pulse along the mat."},
                {id = "frostwake", name = "Frostwake", compact = "Frost", action = "signature", level = 10,
                    planted = true, cooldown = 20, description = "Sweep one flipper across, then drive the other into a second hit."},
            },
        },
    },
    ["silverback-gorilla"] = {
        kit = "silverback",
        basic = {
            attribute = "SilverbackBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start a three-strike combo with a straight glove."},
                {id = "fernCheck", name = "Fern Check", compact = "Fern", action = "strike", level = 5,
                    planted = true, description = "Use a quick left glove check to start the combo."},
                {id = "timberToe", name = "Timber Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true, description = "Open with a short right toe strike while the left boot stays planted."},
            },
        },
        ultimate = {
            attribute = "SilverbackUltimate", default = "seismicChestPound",
            options = {
                {id = "seismicChestPound", name = "Seismic Chest-Pound", compact = "Seismic", action = "signature", level = 1,
                    description = "Wind up a chest pound and send a shock through the mat."},
                {id = "cedarCrash", name = "Cedar Crash", compact = "Cedar", action = "signature", level = 5,
                    planted = true, cooldown = 20, description = "Lead with a high glove, then follow with a low glove on the other side."},
                {id = "forestClamp", name = "Forest Clamp", compact = "Clamp", action = "signature", level = 10,
                    planted = true, cooldown = 20, description = "Spread both gauntlets, then close them for one heavy hit."},
            },
        },
    },
    ["fire-salamander"] = {
        kit = "salamander",
        basic = {
            attribute = "SalamanderBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Use a quick jab to start the close-range combo."},
                {id = "sootPalm", name = "Soot Palm", compact = "Soot", action = "strike", level = 5,
                    planted = true, description = "Start the combo with a short left palm strike."},
                {id = "kilnToe", name = "Kiln Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true, description = "Start the combo with a low toe strike and a planted support boot."},
            },
        },
        ultimate = {
            attribute = "SalamanderUltimate", default = "magmaTrail",
            options = {
                {id = "magmaTrail", name = "Magma Trail", compact = "Trail", action = "signature", level = 1,
                    description = "Rush forward and leave a trail of marked tiles that burst in sequence."},
                {id = "hearthCircle", name = "Hearth Circle", compact = "Hearth", action = "signature", level = 5,
                    planted = true, cooldown = 20, floorPulse = true, description = "Strike the mat with both mitts and send a short wave across the floor."},
                {id = "crucibleArc", name = "Crucible Arc", compact = "Arc", action = "signature", level = 10,
                    planted = true, cooldown = 20, description = "Swing one gauntlet across, then turn into a second hit with the other."},
            },
        },
    },
}

local byMove, byKit = {}, {}
for _, fighter in byFighter do
    byKit[fighter.kit] = fighter
    for _, slot in {fighter.basic, fighter.ultimate} do
        for _, option in slot.options do
            table.freeze(option)
            if option.planted then byMove[option.id] = option end
        end
        table.freeze(slot.options)
        table.freeze(slot)
    end
    table.freeze(fighter)
end

local Loadouts = {
    ByFighter = table.freeze(byFighter),
    ByKit = table.freeze(byKit),
}

local function find(slot, id)
    if type(slot) == "table" and type(id) == "string" then
        for _, option in slot.options do
            if option.id == id then return option end
        end
    end
    return nil
end

function Loadouts.get(fighterId, slot, id)
    local loadout = Loadouts.ByFighter[fighterId]
    return find(loadout and loadout[slot], id)
end

function Loadouts.forFighter(fighterId, slot, id)
    local loadout = Loadouts.ByFighter[fighterId]
    local group = loadout and loadout[slot]
    return if type(group) == "table" then find(group, id) or group.options[1] else nil
end

function Loadouts.forKit(kit, slot, id)
    local loadout = Loadouts.ByKit[kit]
    local group = loadout and loadout[slot]
    return if type(group) == "table" then find(group, id) or group.options[1] else nil
end

function Loadouts.isPlanted(id)
    return byMove[id] ~= nil
end

function Loadouts.isFloorPulse(id)
    local option = byMove[id]
    return option ~= nil and option.floorPulse == true
end

return table.freeze(Loadouts)
