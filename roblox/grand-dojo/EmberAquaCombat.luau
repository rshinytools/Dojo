local Scorpion = require(script.Parent.ScorpionCombatPoses)
local Shrimp = require(script.Parent.ShrimpCombatPoses)
local Combat = {}

local function lightAndHeavy(poses, jab, cross, body, heavy)
    return {
        jab = {{at = poses.Contact.jab, damage = jab, zone = "head"}},
        cross = {{at = poses.Contact.cross, damage = cross, zone = "body"}},
        body = {{at = poses.Contact.body, damage = body, zone = "body"}},
        heavy = {{at = poses.Contact.heavy, damage = heavy, zone = "body"}},
    }
end

local feint, snare = Scorpion.Skill.tailFeint, Scorpion.Skill.cinderSnare
local dash, cannon = Shrimp.Skill.clawDash, Shrimp.Skill.cavitationCannon
local scorpion = lightAndHeavy(Scorpion, 14, 14, 15, 22)
scorpion.tailFeint = {{at = Scorpion.Contact.tailFeint, damage = feint.damage, radius = feint.radius, zone = "body"}}
scorpion.cinderSnare = {{at = Scorpion.Contact.cinderSnare, damage = 0, shape = "snare",
    zone = "body", controlOnly = true, rootDuration = snare.rootDuration}}

local shrimp = lightAndHeavy(Shrimp, 15, 14, 15, 23)
shrimp.clawDash = {{at = Shrimp.Contact.clawDash, damage = dash.damage, radius = dash.radius, zone = "body"}}
local release = Shrimp.Contact.cavitationCannon
local samples = 7
shrimp.cavitationCannon = {{at = release, shape = "wave", launch = true}}
for index = 1, samples do
    table.insert(shrimp.cavitationCannon, {
        at = release + cannon.flight * index / samples, shape = "wave", zone = "body",
        from = (index - 1) / samples, to = index / samples, damage = cannon.damage, singleHit = true,
    })
end

Combat.kits = table.freeze({
    scorpion = {
        poses = Scorpion, clips = scorpion, mixedSpacing = 2.53,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .82,
        signature = "cinderSnare", signatureCooldown = 7.3, signatureCooling = "snareCooling",
        secondary = "tailFeint", secondaryCooldown = 3.2, secondaryCooling = "tailCooling",
    },
    shrimp = {
        poses = Shrimp, clips = shrimp, mixedSpacing = 2.55,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .83,
        signature = "cavitationCannon", signatureCooldown = 8.1, signatureCooling = "cannonCooling",
        secondary = "clawDash", secondaryCooldown = 3.2, secondaryCooling = "clawCooling",
    },
})

Combat.snare, Combat.snareAt = snare, Scorpion.Contact.cinderSnare
Combat.cannon, Combat.waveAt = cannon, release
Combat.shove = table.freeze({tailFeint = feint.shove, clawDash = dash.shove, cavitationCannon = cannon.shove})
return table.freeze(Combat)
