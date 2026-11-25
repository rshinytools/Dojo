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
    ["karate-frog"] = {
        kit = "frog",
        basic = {
            attribute = "FrogBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start with a quick glove before the cross and body strike."},
                {id = "pondTap", name = "Pond Tap", compact = "Pond", action = "strike", level = 5,
                    planted = true,
                    description = "Lead with a short left-glove tap from a low guard."},
                {id = "bankKick", name = "Bank Kick", compact = "Kick", action = "strike", level = 10,
                    planted = true,
                    description = "Open with a low right kick while the left boot stays planted."},
            },
        },
        ultimate = {
            attribute = "FrogUltimate", default = "tadpoleTornado",
            options = {
                {id = "tadpoleTornado", name = "Tadpole Tornado", compact = "Tornado", action = "signature", level = 1,
                    description = "Wind up a spin that spreads a pulse across the mat."},
                {id = "lilyCrash", name = "Lily Crash", compact = "Crash", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Raise both gloves, then drive them down for one body hit."},
                {id = "marshBarrage", name = "Marsh Barrage", compact = "Marsh", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Land a low left glove and follow with a high right."},
            },
        },
    },
    ["river-otter"] = {
        kit = "otter",
        basic = {
            attribute = "OtterBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Lead with a straight palm, then follow with two quick strikes."},
                {id = "runnelTap", name = "Runnel Tap", compact = "Runnel", action = "strike", level = 5,
                    planted = true,
                    description = "Snap a short left palm forward to start the combo."},
                {id = "currentHeel", name = "Current Heel", compact = "Heel", action = "strike", level = 10,
                    planted = true,
                    description = "Turn a low left heel forward while the right foot stays down."},
            },
        },
        ultimate = {
            attribute = "OtterUltimate", default = "pebbleBarrage",
            options = {
                {id = "pebbleBarrage", name = "Pebble Barrage", compact = "Pebbles", action = "signature", level = 1,
                    description = "Send three skipping pebbles along different paths."},
                {id = "estuaryRing", name = "Estuary Ring", compact = "Estuary", action = "signature", level = 5,
                    planted = true, cooldown = 20, floorPulse = true,
                    description = "Show a warning on the mat, then send a pulse from both palms."},
                {id = "riverRush", name = "River Rush", compact = "Rush", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Strike high with the right palm, then low with the left."},
            },
        },
    },
    ["rooster-kickboxer"] = {
        kit = "rooster",
        basic = {
            attribute = "RoosterBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start with a short wing strike before two follow-ups."},
                {id = "roostTap", name = "Roost Tap", compact = "Roost", action = "strike", level = 5,
                    planted = true,
                    description = "Tap forward with the padded right wing to open the combo."},
                {id = "sunspur", name = "Sunspur", compact = "Spur", action = "strike", level = 10,
                    planted = true,
                    description = "Snap out a low toe strike while the other foot stays planted."},
            },
        },
        ultimate = {
            attribute = "RoosterUltimate", default = "featherFlurry",
            options = {
                {id = "featherFlurry", name = "Feather Flurry", compact = "Flurry", action = "signature", level = 1,
                    description = "Close the gap with three quick wing strikes."},
                {id = "roostHammer", name = "Roost Hammer", compact = "Hammer", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Raise both wings, then bring the right pad down for one heavy hit."},
                {id = "sunriseArc", name = "Sunrise Arc", compact = "Arc", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Sweep the left wing inward, then follow with the right."},
            },
        },
    },
    ["sugar-glider"] = {
        kit = "glider",
        basic = {
            attribute = "GliderBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start with a straight palm before a cross and body strike."},
                {id = "sailTap", name = "Sail Tap", compact = "Sail", action = "strike", level = 5,
                    planted = true,
                    description = "Unfold the right sleeve into a short opening palm strike."},
                {id = "branchToe", name = "Branch Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Kick low with the left toe while the right foot stays planted."},
            },
        },
        ultimate = {
            attribute = "GliderUltimate", default = "gustVortex",
            options = {
                {id = "gustVortex", name = "Gust Vortex", compact = "Vortex", action = "signature", level = 1,
                    description = "Glide in and pull nearby fighters toward a burst of wind."},
                {id = "canopyClap", name = "Canopy Clap", compact = "Clap", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Spread both sleeves, then close both palms for one hit."},
                {id = "duskWheel", name = "Dusk Wheel", compact = "Dusk", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Swing the right palm inward, then reverse into a left palm strike."},
            },
        },
    },
    ["desert-scorpion"] = {
        kit = "scorpion",
        basic = {
            attribute = "ScorpionBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start with a claw strike, then cross and follow up low."},
                {id = "flintCheck", name = "Flint Check", compact = "Flint", action = "strike", level = 5,
                    planted = true,
                    description = "Open the combo with a short left claw check."},
                {id = "siltScoop", name = "Silt Scoop", compact = "Scoop", action = "strike", level = 10,
                    planted = true,
                    description = "Turn the right claw under a low guard with both feet set."},
            },
        },
        ultimate = {
            attribute = "ScorpionUltimate", default = "cinderSnare",
            options = {
                {id = "cinderSnare", name = "Cinder Snare", compact = "Snare", action = "signature", level = 1,
                    description = "Mark a short area where the tail can trap a close opponent."},
                {id = "sunforgeClasp", name = "Sunforge Clasp", compact = "Clasp", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Spread both claws, then bring them together for one body hit."},
                {id = "stingerRelay", name = "Stinger Relay", compact = "Relay", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Sweep the tail low, then follow with the opposite claw."},
            },
        },
    },
    ["pistol-shrimp"] = {
        kit = "shrimp",
        basic = {
            attribute = "ShrimpBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Lead with a claw, then alternate sides and finish low."},
                {id = "coralCheck", name = "Coral Check", compact = "Coral", action = "strike", level = 5,
                    planted = true,
                    description = "Tap forward with the larger claw from a tight guard."},
                {id = "dockKick", name = "Dock Kick", compact = "Kick", action = "strike", level = 10,
                    planted = true,
                    description = "Open with a low left kick while the right foot stays planted."},
            },
        },
        ultimate = {
            attribute = "ShrimpUltimate", default = "cavitationCannon",
            options = {
                {id = "cavitationCannon", name = "Cavitation Cannon", compact = "Cannon", action = "signature", level = 1,
                    description = "Wind up the larger claw and release a marked pressure blast."},
                {id = "coralGate", name = "Coral Gate", compact = "Gate", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Open both pincers wide, then close them for one direct hit."},
                {id = "quaysideCross", name = "Quayside Cross", compact = "Cross", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Strike high with the right claw and follow low with the left."},
            },
        },
    },
    ["walrus-sumo"] = {
        kit = "walrus",
        basic = {
            attribute = "WalrusBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Lead with a flipper, then follow with a cross and a low strike."},
                {id = "dockTap", name = "Dock Tap", compact = "Dock", action = "strike", level = 5,
                    planted = true,
                    description = "Use a short, quick right flipper to start the combo."},
                {id = "brineToe", name = "Brine Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Open with a low right toe strike from the planted left boot."},
            },
        },
        ultimate = {
            attribute = "WalrusUltimate", default = "tidalBellyFlop",
            options = {
                {id = "tidalBellyFlop", name = "Tidal Belly-Flop", compact = "Flop", action = "signature", level = 1,
                    description = "Leap, then land on the marked mat to send out a pulse."},
                {id = "mooringDrop", name = "Mooring Drop", compact = "Drop", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Raise both flippers, then bring the lead flipper down for one hit."},
                {id = "tidelineClap", name = "Tideline Clap", compact = "Clap", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Sweep one flipper across, then turn into a second flipper strike."},
            },
        },
    },
    ["snapping-tortoise"] = {
        kit = "tortoise",
        basic = {
            attribute = "TortoiseBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start with a padded knuckle, then cross and follow up low."},
                {id = "masonTap", name = "Mason Tap", compact = "Mason", action = "strike", level = 5,
                    planted = true,
                    description = "Lead with a short left knuckle strike from behind the shell."},
                {id = "plinthToe", name = "Plinth Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Kick low with the left boot while the right boot stays planted."},
            },
        },
        ultimate = {
            attribute = "TortoiseUltimate", default = "fortressRicochet",
            options = {
                {id = "fortressRicochet", name = "Fortress Ricochet", compact = "Roll", action = "signature", level = 1,
                    description = "Tuck into the shell and roll around the ring."},
                {id = "stonegatePress", name = "Stonegate Press", compact = "Press", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Lift both wraps, then bring them through for one close body hit."},
                {id = "keystoneTurn", name = "Keystone Turn", compact = "Turn", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Land a high right knuckle, then turn into a low left strike."},
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
