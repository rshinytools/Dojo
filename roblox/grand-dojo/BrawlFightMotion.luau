-- Brawl uses the same authored joints, fitted volumes, and world-space cues as Duel.
local FighterMotion = require(script.Parent.DuelFightMotion)

return table.freeze({
    open = function(brawl)
        FighterMotion.open(brawl, true)
    end,
    move = FighterMotion.move,
    clearCasts = FighterMotion.clearCasts,
    render = FighterMotion.render,
    canAct = FighterMotion.canAct,
    strike = FighterMotion.strikeGroup,
    impact = FighterMotion.impact,
    remove = FighterMotion.remove,
    close = FighterMotion.close,
    holdsKnockout = FighterMotion.holdsKnockout,
})
