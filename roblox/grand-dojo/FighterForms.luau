-- Form eligibility uses each fighter's own level. The form visuals share its rig and combat kit.
local Forms = {BaseId = "rookie"}
local rookie = table.freeze({id = Forms.BaseId, name = "Rookie", level = 1})
local base = table.freeze({rookie})
local roster = {}
for _, id in {"reedguard-kangaroo", "penguin-brawler", "silverback-gorilla", "fire-salamander",
    "karate-frog", "river-otter", "rooster-kickboxer"} do
    roster[id] = table.freeze({
        rookie,
        table.freeze({id = "warrior", name = "Warrior", level = 5, visual = id .. "-warrior"}),
        table.freeze({id = "grandmaster", name = "Grandmaster", level = 10, visual = id .. "-grandmaster"}),
    })
end

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
    local model = visuals:FindFirstChild(fighterId)
    if not model or not model:IsA("Model") then return nil end
    local outfit = form.visual and formVisuals:FindFirstChild(form.visual)
    if form.visual and not (outfit and outfit:IsA("Model")) then return nil end
    return model, outfit
end

-- Outfits store only new parts in the same authored world frame as the base art.
function Forms.decorate(group, outfit)
    local ornaments = outfit and outfit:FindFirstChild(group.Name)
    if not ornaments then return end
    for _, part in ornaments:GetChildren() do
        if part:IsA("BasePart") then
            part:Clone().Parent = group
        end
    end
end

return table.freeze(Forms)
