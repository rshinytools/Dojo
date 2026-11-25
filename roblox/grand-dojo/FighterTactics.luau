-- Shared technique choices. Profiles enforce the unlock level and matches snapshot the equipped choice.
local byFighter = {
    ["reedguard-kangaroo"] = {
        kit = "reedguard", attribute = "ReedguardTactical", default = "uppercut",
        options = {
            {id = "uppercut", name = "Uppercut", compact = "Uppercut", level = 1, action = "uppercut"},
            {id = "reedSweep", name = "Reed Sweep", compact = "Sweep", level = 5, action = "secondary", planted = true},
        },
    },
    ["penguin-brawler"] = {
        kit = "penguin", attribute = "PenguinTactical", default = "icecrestPalm",
        options = {
            {id = "icecrestPalm", name = "Icecrest Palm", compact = "Palm", level = 1, action = "secondary", planted = true},
            {id = "floeHook", name = "Floe Hook", compact = "Hook", level = 5, action = "secondary", planted = true},
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
