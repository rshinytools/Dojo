-- Form eligibility uses each fighter's own level. The form visuals share its rig and combat kit.
local Forms = {BaseId = "rookie"}
local rookie = table.freeze({id = Forms.BaseId, name = "Rookie", level = 1})
local base = table.freeze({rookie})
local roster = {
    ["reedguard-kangaroo"] = table.freeze({
        rookie,
        table.freeze({id = "warrior", name = "Warrior", level = 5, visual = "reedguard-kangaroo-warrior"}),
        table.freeze({id = "grandmaster", name = "Grandmaster", level = 10, visual = "reedguard-kangaroo-grandmaster"}),
    }),
}

function Forms.list(fighterId)
    return roster[fighterId] or base
end

function Forms.get(fighterId, formId)
    for _, form in Forms.list(fighterId) do
        if form.id == formId then return form end
    end
    return nil
end

function Forms.appearance(visuals, formVisuals, fighterId, formId)
    local form = Forms.get(fighterId, formId or Forms.BaseId)
    if not form then return nil end
    local model = if form.visual then formVisuals:FindFirstChild(form.visual) else visuals:FindFirstChild(fighterId)
    return if model and model:IsA("Model") then model else nil
end

return table.freeze(Forms)
