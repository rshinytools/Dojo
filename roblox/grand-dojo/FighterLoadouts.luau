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
                planted = true, cooldown = 20, description = "Both gloves strike the mat and send a short pulse along the floor."},
            {id = "festivalCross", name = "Festival Cross", compact = "Cross", action = "signature", level = 10,
                planted = true, cooldown = 20, description = "Two deliberate mitt strikes land in sequence from a planted stance."},
        },
    },
}

local byMove = {}
for _, slot in {reedguard.basic, reedguard.ultimate} do
    for _, option in slot.options do byMove[option.id] = table.freeze(option) end
    table.freeze(slot.options)
    table.freeze(slot)
end
table.freeze(reedguard)

local Loadouts = {
    ByFighter = table.freeze({["reedguard-kangaroo"] = reedguard}),
    ByKit = table.freeze({reedguard = reedguard}),
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
    local option = byMove[id]
    return option ~= nil and option.planted == true
end

return table.freeze(Loadouts)
