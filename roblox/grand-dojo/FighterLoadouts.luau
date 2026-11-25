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
    ["armadillo-striker"] = {
        kit = "armadillo",
        basic = {
            attribute = "ArmadilloBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Open with a padded jab, then cross and finish low."},
                {id = "tileJab", name = "Tile Jab", compact = "Tile", action = "strike", level = 5,
                    planted = true,
                    description = "Start the combo with a short left glove strike."},
                {id = "cobbleToe", name = "Cobble Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Kick low with the right toe while the left boot stays planted."},
            },
        },
        ultimate = {
            attribute = "ArmadilloUltimate", default = "meteorRoll",
            options = {
                {id = "meteorRoll", name = "Meteor Roll", compact = "Roll", action = "signature", level = 1,
                    description = "Curl into a quick roll to hit along a straight path."},
                {id = "bastionPress", name = "Bastion Press", compact = "Press", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Show the shoulder plate, then turn it into one heavy body hit."},
                {id = "forgeCadence", name = "Forge Cadence", compact = "Cadence", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Lead with a low left glove and follow with a higher right."},
            },
        },
    },
    ["komodo-dragon"] = {
        kit = "komodo",
        basic = {
            attribute = "KomodoBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start with a quick glove before two follow-up strikes."},
                {id = "kilnKnuckle", name = "Kiln Knuckle", compact = "Kiln", action = "strike", level = 5,
                    planted = true,
                    description = "Snap a short left glove forward from guard."},
                {id = "sootstep", name = "Sootstep", compact = "Soot", action = "strike", level = 10,
                    planted = true,
                    description = "Kick with the right toe while the left boot stays planted."},
            },
        },
        ultimate = {
            attribute = "KomodoUltimate", default = "volcanicBreath",
            options = {
                {id = "volcanicBreath", name = "Volcanic Breath", compact = "Breath", action = "signature", level = 1,
                    description = "Turn into a short cone of heat directly ahead."},
                {id = "obsidianDrop", name = "Obsidian Drop", compact = "Drop", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Bring a raised right mitt down for one close body hit."},
                {id = "ashlineTurn", name = "Ashline Turn", compact = "Turn", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Lead with a left glove and finish with a low tail sweep."},
            },
        },
    },
    ["electric-owl"] = {
        kit = "owl",
        basic = {
            attribute = "OwlBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Open with a wing strike, then cross and follow up low."},
                {id = "skyFletch", name = "Sky Fletch", compact = "Fletch", action = "strike", level = 5,
                    planted = true,
                    description = "Snap a short padded left wing out of guard."},
                {id = "perchHook", name = "Perch Hook", compact = "Hook", action = "strike", level = 10,
                    planted = true,
                    description = "Open with a low right talon while the left foot stays planted."},
            },
        },
        ultimate = {
            attribute = "OwlUltimate", default = "thunderDive",
            options = {
                {id = "thunderDive", name = "Thunder Dive", compact = "Dive", action = "signature", level = 1,
                    description = "Rise, then land on the marked mat to send out a pulse."},
                {id = "staticPerch", name = "Static Perch", compact = "Perch", action = "signature", level = 5,
                    planted = true, cooldown = 20, floorPulse = true,
                    description = "Warn nearby fighters, then bring both wings down to send out a pulse."},
                {id = "splitGale", name = "Split Gale", compact = "Gale", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Strike with the left wing, then follow with a low right talon."},
            },
        },
    },
    ["bighorn-ram"] = {
        kit = "ram",
        basic = {
            attribute = "RamBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Lead with a padded glove, then cross and finish low."},
                {id = "slateJab", name = "Slate Jab", compact = "Slate", action = "strike", level = 5,
                    planted = true,
                    description = "Start a combo with a quick left glove from a braced stance."},
                {id = "cragToe", name = "Crag Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Kick low with the left hoof while the right foot stays planted."},
            },
        },
        ultimate = {
            attribute = "RamUltimate", default = "staticCharge",
            options = {
                {id = "staticCharge", name = "Static Charge", compact = "Charge", action = "signature", level = 1,
                    description = "Lower the horns and run along the marked path."},
                {id = "summitPress", name = "Summit Press", compact = "Press", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Raise both gloves and bring them down for one direct hit."},
                {id = "switchback", name = "Switchback", compact = "Switch", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Start with a low right glove, then turn into a high left strike."},
            },
        },
    },
    ["honey-badger"] = {
        kit = "badger",
        basic = {
            attribute = "BadgerBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Open with a straight paw, then cross and follow up low."},
                {id = "brambleCheck", name = "Bramble Check", compact = "Bramble", action = "strike", level = 5,
                    planted = true,
                    description = "Start the combo with a short left glove."},
                {id = "thicketToe", name = "Thicket Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Kick low with the left toe while the right boot stays planted."},
            },
        },
        ultimate = {
            attribute = "BadgerUltimate", default = "unstoppableFrenzy",
            options = {
                {id = "unstoppableFrenzy", name = "Unstoppable Frenzy", compact = "Frenzy", action = "signature", level = 1,
                    description = "Sweep four times and briefly resist stagger and knockback."},
                {id = "honeycombCrush", name = "Honeycomb Crush", compact = "Crush", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Spread both paws, then bring them together for one heavy hit."},
                {id = "hollowHammer", name = "Hollow Hammer", compact = "Hammer", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Strike low with the right paw, then turn into a high left hit."},
            },
        },
    },
    ["emerald-saber-tooth"] = {
        kit = "sabertooth",
        basic = {
            attribute = "SaberBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start the combo with a straight strike from the jade gauntlet."},
                {id = "vineFlick", name = "Vine Flick", compact = "Vine", action = "strike", level = 5,
                    planted = true,
                    description = "Flick the left gauntlet forward to start the combo."},
                {id = "briarStep", name = "Briar Step", compact = "Briar", action = "strike", level = 10,
                    planted = true,
                    description = "Open with a low left toe strike while the right boot stays planted."},
            },
        },
        ultimate = {
            attribute = "SaberUltimate", default = "apexPounce",
            options = {
                {id = "apexPounce", name = "Apex Pounce", compact = "Pounce", action = "signature", level = 1,
                    description = "Leap to the marked area and hit nearby fighters on landing."},
                {id = "groveBreak", name = "Grove Break", compact = "Grove", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Load the right shoulder plate, then drive it into one hit."},
                {id = "verdantCross", name = "Verdant Cross", compact = "Verdant", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Hit low with the left gauntlet, then follow with a higher right."},
            },
        },
    },
    ["great-white-shark"] = {
        kit = "shark",
        basic = {
            attribute = "SharkBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Start with a straight glove, then cross and finish low."},
                {id = "saltTap", name = "Salt Tap", compact = "Salt", action = "strike", level = 5,
                    planted = true,
                    description = "Snap the left glove forward from a compact guard."},
                {id = "sandbarToe", name = "Sandbar Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Lift the left toe for a short kick while the right boot stays planted."},
            },
        },
        ultimate = {
            attribute = "SharkUltimate", default = "jawsOfTheDeep",
            options = {
                {id = "jawsOfTheDeep", name = "Jaws of the Deep", compact = "Jaws", action = "signature", level = 1,
                    description = "Dive below the mat, then resurface near the marked fighter."},
                {id = "whitecapBreak", name = "Whitecap Break", compact = "Whitecap", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Turn the rounded right fin into one close body hit."},
                {id = "surgeCross", name = "Surge Cross", compact = "Surge", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Strike high with the right glove and follow low with the left."},
            },
        },
    },
    ["abyssal-kraken"] = {
        kit = "kraken",
        basic = {
            attribute = "KrakenBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Open with a padded strike, then cross and follow up low."},
                {id = "reefCurl", name = "Reef Curl", compact = "Curl", action = "strike", level = 5,
                    planted = true,
                    description = "Snap the folded left tentacle forward to start the combo."},
                {id = "tidepoolToe", name = "Tidepool Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Kick low with the right toe while the left boot stays planted."},
            },
        },
        ultimate = {
            attribute = "KrakenUltimate", default = "tentacleCataclysm",
            options = {
                {id = "tentacleCataclysm", name = "Tentacle Cataclysm", compact = "Cataclysm", action = "signature", level = 1,
                    description = "Warn the ring as four tentacles sweep in from marked lanes."},
                {id = "trenchRing", name = "Trench Ring", compact = "Trench", action = "signature", level = 5,
                    planted = true, cooldown = 20, floorPulse = true,
                    description = "Raise the tentacles, then strike the mat to send out a short pulse."},
                {id = "reefbreakerCross", name = "Reefbreaker Cross", compact = "Breaker", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Strike high with the left tentacle, then follow low with the right."},
            },
        },
    },
    ["magma-grizzly-bear"] = {
        kit = "grizzly",
        basic = {
            attribute = "GrizzlyBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Open with a padded jab, then follow with a cross and a low strike."},
                {id = "cinderTap", name = "Cinder Tap", compact = "Tap", action = "strike", level = 5,
                    planted = true,
                    description = "Snap a short left glove out of guard."},
                {id = "smelterToe", name = "Smelter Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Kick low with the left toe while the right boot stays planted."},
            },
        },
        ultimate = {
            attribute = "GrizzlyUltimate", default = "eruptionSlam",
            options = {
                {id = "eruptionSlam", name = "Eruption Slam", compact = "Eruption", action = "signature", level = 1,
                    description = "Send four molten pillars forward. A fighter can take up to two hits."},
                {id = "furnaceGate", name = "Furnace Gate", compact = "Gate", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Raise both gloves, then bring the right glove down for one heavy hit."},
                {id = "foundryTurn", name = "Foundry Turn", compact = "Turn", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Strike high with the left glove, then turn into a low right strike."},
            },
        },
    },
    ["obsidian-hellhound"] = {
        kit = "hellhound",
        basic = {
            attribute = "HellhoundBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Open with a quick paw, then follow with a cross and a low strike."},
                {id = "coalFlick", name = "Coal Flick", compact = "Flick", action = "strike", level = 5,
                    planted = true,
                    description = "Snap a short left glove forward from a narrow guard."},
                {id = "slateToe", name = "Slate Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Check with the right toe while the left boot stays planted."},
            },
        },
        ultimate = {
            attribute = "HellhoundUltimate", default = "hellfireStampede",
            options = {
                {id = "hellfireStampede", name = "Hellfire Stampede", compact = "Stampede", action = "signature", level = 1,
                    description = "Send two spectral hounds across the ring on marked routes."},
                {id = "cinderCrown", name = "Cinder Crown", compact = "Crown", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Lift the muzzle, then dip into one heavy body strike."},
                {id = "violetCross", name = "Violet Cross", compact = "Cross", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Lead with a low left glove and finish high with the right."},
            },
        },
    },
    ["golden-eagle"] = {
        kit = "eagle",
        basic = {
            attribute = "EagleBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Lead with a padded wing jab, then follow with a cross and a low strike."},
                {id = "aerieTap", name = "Aerie Tap", compact = "Tap", action = "strike", level = 5,
                    planted = true,
                    description = "Flick the left padded wing forward for a quick opening hit."},
                {id = "ridgeTalon", name = "Ridge Talon", compact = "Talon", action = "strike", level = 10,
                    planted = true,
                    description = "Kick low with the right talon while the left foot stays planted."},
            },
        },
        ultimate = {
            attribute = "EagleUltimate", default = "talonDrop",
            options = {
                {id = "talonDrop", name = "Talon Drop", compact = "Drop", action = "signature", level = 1,
                    description = "Catch an opponent, carry them briefly, then land for one hit."},
                {id = "sunfanCrash", name = "Sunfan Crash", compact = "Crash", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Spread both wings, then bring them down for one close strike."},
                {id = "crownArc", name = "Crown Arc", compact = "Arc", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Bring the left wing down from high guard, then follow with a low right wing strike."},
            },
        },
    },
    ["celestial-storm-dragon"] = {
        kit = "dragon",
        basic = {
            attribute = "DragonBasic", default = "jab",
            options = {
                {id = "jab", name = "Jab Combo", compact = "Jab", action = "strike", level = 1,
                    description = "Open with a short forepaw jab, then follow with a cross and a low strike."},
                {id = "zephyrKnuckle", name = "Zephyr Knuckle", compact = "Zephyr", action = "strike", level = 5,
                    planted = true,
                    description = "Fold the near wing inward and tap with the left forepaw."},
                {id = "cloudbankToe", name = "Cloudbank Toe", compact = "Toe", action = "strike", level = 10,
                    planted = true,
                    description = "Tap low with the right toe while the left boot stays planted."},
            },
        },
        ultimate = {
            attribute = "DragonUltimate", default = "tempestRoar",
            options = {
                {id = "tempestRoar", name = "Tempest Roar", compact = "Roar", action = "signature", level = 1,
                    description = "Hover and steer a storm beam while a marked thunder strike builds."},
                {id = "thunderheadDrop", name = "Thunderhead Drop", compact = "Drop", action = "signature", level = 5,
                    planted = true, cooldown = 20,
                    description = "Raise both wings and bring the right forepaw down for one direct hit."},
                {id = "cirrusBreaker", name = "Cirrus Breaker", compact = "Cirrus", action = "signature", level = 10,
                    planted = true, cooldown = 20,
                    description = "Sweep low with the rounded tail, then strike high with the left forepaw."},
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
