local function activity(title, duration, maxScore, maxBonus, goldScore, goldBonus, silverScore, unit, bonusUnit, keepsake, description)
    return table.freeze({
        title = title, duration = duration, maxScore = maxScore, maxBonus = maxBonus,
        goldScore = goldScore, goldBonus = goldBonus, silverScore = silverScore,
        unit = unit, bonusUnit = bonusUnit, keepsake = keepsake, description = description,
    })
end

return table.freeze({
    bell = activity("Juniper’s Bell", 18, 10, 10, 8, 4, 4, "strikes", "perfect", "Juniper Bell Pin",
        "Strike inside the gold window. The beat gets faster."),
    rush = activity("Lantern Rush", 25, 8, 8, 7, 2, 4, "gates", "shortcuts", "Lantern Pennant",
        "Choose a lit lane at every fork. Teal shortcuts close early."),
    rescue = activity("Reedfall Rescue", 35, 9, 0, 4, 0, 2, "rescues", "", "Reedfall Paper Boat",
        "Carry each drifting lantern back to the dock. The current shifts after each rescue."),
})
