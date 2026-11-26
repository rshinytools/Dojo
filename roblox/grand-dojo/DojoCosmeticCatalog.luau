local Catalog = {}

Catalog.PassConfig = "dojo_outfitters_fighter_passes"
Catalog.Items = {
    {
        id = "reedguard-bamboo-mitts", fighterId = "reedguard-kangaroo", fighter = "Reedguard Kangaroo",
        name = "Bamboo Weave Mitts", slot = "hands",
        description = "Emerald bamboo weave over compact gold-trimmed sparring mitts.",
    },
    {
        id = "penguin-glacier-mitts", fighterId = "penguin-brawler", fighter = "Penguin Brawler",
        name = "Glacier Breaker Mitts", slot = "hands",
        description = "Cobalt sparring pads with frost-blue panels and silver edging.",
    },
    {
        id = "silverback-cedar-bracers", fighterId = "silverback-gorilla", fighter = "Silverback Gorilla",
        name = "Cedarcrest Bracers", slot = "hands",
        description = "Cedar plates and warm brass over moss-green hand wraps.",
    },
    {
        id = "salamander-kiln-mitts", fighterId = "fire-salamander", fighter = "Fire Salamander",
        name = "Kilnflare Wraps", slot = "hands",
        description = "Vermilion wraps and amber lacquer inspired by Cinder Terraces.",
    },
}

local byId = {}
for _, item in Catalog.Items do
    byId[item.id] = item
    table.freeze(item)
end
table.freeze(Catalog.Items)

function Catalog.get(itemId)
    return byId[itemId]
end

function Catalog.canWear(itemId, fighterId)
    local item = byId[itemId]
    return item ~= nil and item.fighterId == fighterId
end

function Catalog.attribute(prefix, itemId)
    return prefix .. "_" .. itemId:gsub("-", "_")
end

return table.freeze(Catalog)
