-- Shared technique choices. Profiles enforce the unlock level and matches snapshot the equipped choice.
local byFighter = {
    ["reedguard-kangaroo"] = {
        kit = "reedguard", attribute = "ReedguardTactical", default = "uppercut",
        options = {
            {id = "uppercut", name = "Uppercut", compact = "Uppercut", level = 1, action = "uppercut",
                description = "A quick rising punch that targets the head."},
            {id = "reedSweep", name = "Reed Sweep", compact = "Sweep", level = 5, action = "secondary", planted = true,
                description = "A low sweeping kick with extra reach."},
            {id = "reedstoneHeel", name = "Reedstone Heel", compact = "Heel", level = 10, action = "secondary", planted = true,
                description = "A slower, close-range heel strike with a high windup."},
        },
    },
    ["penguin-brawler"] = {
        kit = "penguin", attribute = "PenguinTactical", default = "icecrestPalm",
        options = {
            {id = "icecrestPalm", name = "Icecrest Palm", compact = "Palm", level = 1, action = "secondary", planted = true,
                description = "A mid-range palm strike from a steady stance."},
            {id = "floeHook", name = "Floe Hook", compact = "Hook", level = 5, action = "secondary", planted = true,
                description = "A quick flipper hook for close openings."},
            {id = "glacierPress", name = "Glacier Press", compact = "Press", level = 10, action = "secondary", planted = true,
                description = "A slower two-flipper strike with a deep windup."},
        },
    },
    ["silverback-gorilla"] = {
        kit = "silverback", attribute = "SilverbackTactical", default = "ridgePalm",
        options = {
            {id = "ridgePalm", name = "Ridge Palm", compact = "Palm", level = 1, action = "secondary"},
            {id = "canopyKnuckle", name = "Canopy Knuckle", compact = "Knuckle", level = 5, action = "secondary", planted = true,
                description = "A quick glove strike for close openings. 15 base damage."},
            {id = "ironbarkHammer", name = "Ironbark Hammer", compact = "Hammer", level = 10, action = "secondary", planted = true,
                description = "Both gloves wind up for a slower downward strike. 23 base damage."},
        },
    },
    ["fire-salamander"] = {
        kit = "salamander", attribute = "SalamanderTactical", default = "emberSweep",
        options = {
            {id = "emberSweep", name = "Ember Sweep", compact = "Sweep", level = 1, action = "secondary"},
            {id = "coalstepKick", name = "Coalstep Kick", compact = "Kick", level = 5, action = "secondary", planted = true,
                description = "A quick close-range boot strike that can catch a low stance. 14 base damage."},
            {id = "furnaceBacklash", name = "Furnace Backlash", compact = "Lash", level = 10, action = "secondary", planted = true,
                description = "A longer-reaching tail lash with a slower windup. 22 base damage."},
        },
    },
    ["karate-frog"] = {
        kit = "frog", attribute = "FrogTactical", default = "lilyVault",
        options = {
            {id = "lilyVault", name = "Lily Vault", compact = "Vault", level = 1, action = "secondary"},
            {id = "mudPalm", name = "Mud Palm", compact = "Palm", level = 5, action = "secondary", planted = true,
                description = "A quick, grounded palm strike for close openings."},
            {id = "pondboundHeel", name = "Pondbound Heel", compact = "Heel", level = 10, action = "secondary", planted = true,
                description = "A slower high heel strike with a planted support foot."},
        },
    },
    ["river-otter"] = {
        kit = "otter", attribute = "OtterTactical", default = "eddyPalm",
        options = {
            {id = "eddyPalm", name = "Eddy Palm", compact = "Palm", level = 1, action = "secondary"},
            {id = "brookHook", name = "Brook Hook", compact = "Hook", level = 5, action = "secondary", planted = true,
                description = "A short, quick hook that keeps both feet on the mat."},
            {id = "breakwaterPalm", name = "Breakwater Palm", compact = "Thrust", level = 10, action = "secondary", planted = true,
                description = "A slower two-hand thrust with a deeper windup."},
        },
    },
    ["rooster-kickboxer"] = {
        kit = "rooster", attribute = "RoosterTactical", default = "spurLift",
        options = {
            {id = "spurLift", name = "Spur Lift", compact = "Spur", level = 1, action = "secondary"},
            {id = "perchPeck", name = "Perch Peck", compact = "Peck", level = 5, action = "secondary", planted = true,
                description = "A quick beak dip for a close opening."},
            {id = "crestWheel", name = "Crest Wheel", compact = "Wheel", level = 10, action = "secondary", planted = true,
                description = "A slow turning kick with one foot planted."},
        },
    },
    ["sugar-glider"] = {
        kit = "glider", attribute = "GliderTactical", default = "canopySlip",
        options = {
            {id = "canopySlip", name = "Canopy Slip", compact = "Slip", level = 1, action = "secondary"},
            {id = "boughSnap", name = "Bough Snap", compact = "Snap", level = 5, action = "secondary", planted = true,
                description = "A short, quick palm from a folded guard."},
            {id = "sailSwipe", name = "Sail Swipe", compact = "Swipe", level = 10, action = "secondary", planted = true,
                description = "A wide wing windup into a sweeping palm strike."},
        },
    },
    ["desert-scorpion"] = {
        kit = "scorpion", attribute = "ScorpionTactical", default = "tailFeint",
        options = {
            {id = "tailFeint", name = "Tail Feint", compact = "Feint", level = 1, action = "secondary"},
            {id = "sandPincer", name = "Sand Pincer", compact = "Pincer", level = 5, action = "secondary", planted = true,
                description = "A quick claw strike for an opening at close range."},
            {id = "duneLash", name = "Dune Lash", compact = "Lash", level = 10, action = "secondary", planted = true,
                description = "A slower tail sweep that reaches across the body line."},
        },
    },
    ["pistol-shrimp"] = {
        kit = "shrimp", attribute = "ShrimpTactical", default = "clawDash",
        options = {
            {id = "clawDash", name = "Claw Dash", compact = "Dash", level = 1, action = "secondary"},
            {id = "jetSnap", name = "Jet Snap", compact = "Snap", level = 5, action = "secondary", planted = true,
                description = "A fast strike with the smaller claw and a short recoil."},
            {id = "tidebreakerClaw", name = "Tidebreaker Claw", compact = "Claw", level = 10, action = "secondary", planted = true,
                description = "Both claws wind up before the larger claw strikes."},
        },
    },
    ["walrus-sumo"] = {
        kit = "walrus", attribute = "WalrusTactical", default = "harborPalm",
        options = {
            {id = "harborPalm", name = "Harbor Palm", compact = "Palm", level = 1, action = "secondary"},
            {id = "whiskerCheck", name = "Whisker Check", compact = "Check", level = 5, action = "secondary", planted = true,
                description = "A short head dip that catches a nearby opening."},
            {id = "basinPress", name = "Basin Press", compact = "Press", level = 10, action = "secondary", planted = true,
                description = "A slow, wide windup into a two-flipper press."},
        },
    },
    ["snapping-tortoise"] = {
        kit = "tortoise", attribute = "TortoiseTactical", default = "shellCheck",
        options = {
            {id = "shellCheck", name = "Shell Check", compact = "Shell", level = 1, action = "secondary"},
            {id = "quickSnap", name = "Quick Snap", compact = "Snap", level = 5, action = "secondary", planted = true,
                description = "A short beak strike from a steady guard."},
            {id = "rampartBash", name = "Rampart Bash", compact = "Bash", level = 10, action = "secondary", planted = true,
                description = "A planted turn that brings the rounded shell around."},
        },
    },
    ["armadillo-striker"] = {
        kit = "armadillo", attribute = "ArmadilloTactical", default = "plateCheck",
        options = {
            {id = "plateCheck", name = "Plate Check", compact = "Plate", level = 1, action = "secondary"},
            {id = "rivetPalm", name = "Rivet Palm", compact = "Rivet", level = 5, action = "secondary", planted = true,
                description = "A quick strike with a reinforced glove."},
            {id = "kilnShoulder", name = "Kiln Shoulder", compact = "Shoulder", level = 10, action = "secondary", planted = true,
                description = "A slower body turn with the rounded shoulder plate leading."},
        },
    },
    ["komodo-dragon"] = {
        kit = "komodo", attribute = "KomodoTactical", default = "tailRake",
        options = {
            {id = "tailRake", name = "Tail Rake", compact = "Rake", level = 1, action = "secondary"},
            {id = "ashenSnap", name = "Ashen Snap", compact = "Snap", level = 5, action = "secondary", planted = true,
                description = "A quick muzzle strike for close openings."},
            {id = "cinderHeel", name = "Cinder Heel", compact = "Heel", level = 10, action = "secondary", planted = true,
                description = "A turning heel strike with one foot planted."},
        },
    },
    ["electric-owl"] = {
        kit = "owl", attribute = "OwlTactical", default = "wingSweep",
        options = {
            {id = "wingSweep", name = "Wing Sweep", compact = "Sweep", level = 1, action = "secondary"},
            {id = "quillFlick", name = "Quill Flick", compact = "Quill", level = 5, action = "secondary", planted = true,
                description = "A quick close-range strike with the leading feather."},
            {id = "thunderclapWing", name = "Thunderclap Wing", compact = "Clap", level = 10, action = "secondary", planted = true,
                description = "Both wings spread before the leading wing strikes."},
        },
    },
    ["bighorn-ram"] = {
        kit = "ram", attribute = "RamTactical", default = "hornCheck",
        options = {
            {id = "hornCheck", name = "Horn Check", compact = "Horn", level = 1, action = "secondary"},
            {id = "stoneTap", name = "Stone Tap", compact = "Tap", level = 5, action = "secondary", planted = true,
                description = "A quick glove strike from a braced stance."},
            {id = "ridgelineDrive", name = "Ridgeline Drive", compact = "Drive", level = 10, action = "secondary", planted = true,
                description = "A slow, braced horn strike that pushes the opponent back."},
        },
    },
    ["honey-badger"] = {
        kit = "badger", attribute = "BadgerTactical", default = "burrowHook",
        options = {
            {id = "burrowHook", name = "Burrow Hook", compact = "Hook", level = 1, action = "secondary"},
            {id = "copperKnuckle", name = "Copper Knuckle", compact = "Knuckle", level = 5, action = "secondary", planted = true,
                description = "A short strike with the padded foreknuckle."},
            {id = "quarryBackhand", name = "Quarry Backhand", compact = "Backhand", level = 10, action = "secondary", planted = true,
                description = "A planted turn into a wide backhand."},
        },
    },
    ["emerald-saber-tooth"] = {
        kit = "sabertooth", attribute = "SaberTactical", default = "jadeRake",
        options = {
            {id = "jadeRake", name = "Jade Rake", compact = "Rake", level = 1, action = "secondary"},
            {id = "mossPalm", name = "Moss Palm", compact = "Palm", level = 5, action = "secondary", planted = true,
                description = "A quick palm strike out of guard."},
            {id = "emeraldProwl", name = "Emerald Prowl", compact = "Prowl", level = 10, action = "secondary", planted = true,
                description = "A low crouch into a sweeping gauntlet strike."},
        },
    },
    ["great-white-shark"] = {
        kit = "shark", attribute = "SharkTactical", default = "reefHook",
        options = {
            {id = "reefHook", name = "Reef Hook", compact = "Hook", level = 1, action = "secondary"},
            {id = "shoalPalm", name = "Shoal Palm", compact = "Palm", level = 5, action = "secondary", planted = true,
                description = "A compact strike with the leading glove."},
            {id = "undertowHeel", name = "Undertow Heel", compact = "Heel", level = 10, action = "secondary", planted = true,
                description = "A turning heel strike with one boot planted."},
        },
    },
    ["abyssal-kraken"] = {
        kit = "kraken", attribute = "KrakenTactical", default = "tideGrip",
        options = {
            {id = "tideGrip", name = "Tide Grip", compact = "Grip", level = 1, action = "secondary"},
            {id = "currentTap", name = "Current Tap", compact = "Tap", level = 5, action = "secondary", planted = true,
                description = "A quick close strike with the folded tentacle."},
            {id = "maelstromPalm", name = "Maelstrom Palm", compact = "Maelstrom", level = 10, action = "secondary", planted = true,
                description = "A deliberate body turn into a broad tentacle press."},
        },
    },
}

local byKit, byId = {}, {}
for _, definition in byFighter do
    byKit[definition.kit] = definition
    for _, option in definition.options do
        byId[option.id] = table.freeze(option)
    end
    table.freeze(definition.options)
    table.freeze(definition)
end

local Tactics = {ByFighter = table.freeze(byFighter), ByKit = table.freeze(byKit)}

local function get(definition, id)
    if definition then
        for _, option in definition.options do
            if option.id == id then return option end
        end
    end
    return nil
end

function Tactics.get(fighterId, id)
    return get(byFighter[fighterId], id)
end

function Tactics.forKit(kitId, id)
    local definition = byKit[kitId]
    return if definition then get(definition, id) or byId[definition.default] else nil
end

function Tactics.isPlanted(id)
    return byId[id] ~= nil and byId[id].planted == true
end

return table.freeze(Tactics)
