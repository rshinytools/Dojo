-- Ranked Duel uses a fixed competitive level and the standard elemental cycle.
local Rules = {StartingRating = 1200, MaximumRating = 1000000000, CompetitiveLevel = 15}

local levelScale = 1 + (Rules.CompetitiveLevel - 1) * .04
local eloK = 32
local elementBeats = {Land = "Aquatic", Aquatic = "Magma", Magma = "Sky", Sky = "Land"}
local divisions = {
    {minimum = 2100, name = "Dojo Champion"},
    {minimum = 1900, name = "Master"},
    {minimum = 1700, name = "Diamond"},
    {minimum = 1500, name = "Gold"},
    {minimum = 1300, name = "Silver"},
}

function Rules.health(baseHealth)
    return math.round(baseHealth * levelScale)
end

function Rules.matchup(attacker, defender)
    local attackerEdge, defenderEdge = elementBeats[attacker], elementBeats[defender]
    if attackerEdge and attackerEdge == defender then
        return {damageScale = levelScale * 1.25, knockbackScale = 1.20, elementEffect = "edge"}
    elseif defenderEdge and defenderEdge == attacker then
        return {damageScale = levelScale * .80, knockbackScale = .85, elementEffect = "resist"}
    end
    return {damageScale = levelScale, knockbackScale = 1}
end

local function validRating(points)
    return type(points) == "number" and points >= 0 and points <= Rules.MaximumRating and points % 1 == 0
end

function Rules.elo(firstPoints, secondPoints, score)
    assert(validRating(firstPoints) and validRating(secondPoints), "Invalid Duel rating")
    assert(score == 0 or score == .5 or score == 1, "Invalid Duel outcome")
    local expected = 1 / (1 + 10 ^ ((secondPoints - firstPoints) / 400))
    local transfer = math.round(eloK * (score - expected))
    -- Limit the transfer at both records' rating boundaries without creating points.
    transfer = math.clamp(transfer, math.max(-firstPoints, secondPoints - Rules.MaximumRating),
        math.min(secondPoints, Rules.MaximumRating - firstPoints))
    return firstPoints + transfer, secondPoints - transfer
end

function Rules.divisionName(points)
    for _, division in divisions do
        if points >= division.minimum then
            return division.name
        end
    end
    return "Bronze"
end

function Rules.matchRange(waitSeconds)
    local elapsed = math.max(0, waitSeconds)
    return math.min(300, 100 + 50 * math.floor(elapsed / 10))
end

return table.freeze(Rules)
