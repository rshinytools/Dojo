local Walrus = require(script.Parent.WalrusCombatPoses)
local Tortoise = require(script.Parent.TortoiseCombatPoses)
local Heavy = {}

local function strikes(poses, jab, cross, body, heavy)
    return {
        jab = {{at = poses.Contact.jab, damage = jab, zone = "head"}},
        cross = {{at = poses.Contact.cross, damage = cross, zone = "body"}},
        body = {{at = poses.Contact.body, damage = body, zone = "body"}},
        heavy = {{at = poses.Contact.heavy, damage = heavy, zone = "body"}},
    }
end

local palm, flop = Walrus.Skill.harborPalm, Walrus.Skill.tidalBellyFlop
local check, ricochet = Tortoise.Skill.shellCheck, Tortoise.Skill.fortressRicochet
local walrus = strikes(Walrus, 14, 15, 16, 23)
walrus.harborPalm = {{at = Walrus.Contact.harborPalm, damage = palm.damage, radius = palm.radius, zone = "body"}}
walrus.tidalBellyFlop = {{at = Walrus.Contact.tidalBellyFlop, damage = flop.damage, radius = flop.radius,
    center = flop.center, shape = "radial", zone = "body"}}
local tortoise = strikes(Tortoise, 14, 14, 16, 23)
tortoise.shellCheck = {{at = Tortoise.Contact.shellCheck, damage = check.damage, radius = check.radius, zone = "body"}}
tortoise.fortressRicochet = {}
local sweepCount = 64
for index = 1, sweepCount do
    local first, last = ricochet.rollSeconds * (index - 1) / sweepCount, ricochet.rollSeconds * index / sweepCount
    tortoise.fortressRicochet[index] = {at = ricochet.windup + last, from = first, to = last, shape = "ricochet",
        radius = ricochet.radius, damage = ricochet.damage, zone = "body", singleHit = true}
end

Heavy.kits = table.freeze({
    walrus = {
        poses = Walrus, clips = walrus, mixedSpacing = 2.56,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = 1.02,
        signature = "tidalBellyFlop", signatureCooldown = 8.5, signatureCooling = "flopCooling",
        secondary = "harborPalm", secondaryCooldown = 3.5, secondaryCooling = "harborCooling",
    },
    tortoise = {
        poses = Tortoise, clips = tortoise, mixedSpacing = 2.58,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = 1.02,
        signature = "fortressRicochet", signatureCooldown = 12.2, signatureCooling = "ricochetCooling",
        secondary = "shellCheck", secondaryCooldown = 3.5, secondaryCooling = "shellCooling",
    },
})

Heavy.flop, Heavy.flopAt = flop, Walrus.Contact.tidalBellyFlop
Heavy.flopTravel = Walrus.Travel.tidalBellyFlop
Heavy.roll = ricochet
Heavy.shove = table.freeze({harborPalm = palm.shove, tidalBellyFlop = flop.shove,
    shellCheck = check.shove, fortressRicochet = ricochet.shove})

return table.freeze(Heavy)
