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
