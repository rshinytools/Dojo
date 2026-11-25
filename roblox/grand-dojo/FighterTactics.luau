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
