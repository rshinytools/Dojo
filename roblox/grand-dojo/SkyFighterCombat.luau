local Rooster = require(script.Parent.RoosterCombatPoses)
local Glider = require(script.Parent.GliderCombatPoses)
local Sky = {}

local function basicClips(poses, jab, cross, body, heavy)
    return {
        jab = {{at = poses.Contact.jab, damage = jab, zone = "head"}},
        cross = {{at = poses.Contact.cross, damage = cross, zone = "body"}},
        body = {{at = poses.Contact.body, damage = body, zone = "body"}},
        heavy = {{at = poses.Contact.heavy, damage = heavy, zone = "body"}},
    }
end

local spur, flurry = Rooster.Skill.spurLift, Rooster.Skill.featherFlurry
local canopy, gust = Glider.Skill.canopySlip, Glider.Skill.gustVortex
local roosterClips = basicClips(Rooster, 14, 14, 15, 21)
roosterClips.spurLift = {{at = Rooster.Contact.spurLift, damage = spur.damage, radius = spur.radius, zone = "body", foot = true}}
roosterClips.featherFlurry = {}
for index, time in Rooster.Contact.featherFlurry do
    roosterClips.featherFlurry[index] = {
        at = time, damage = flurry.damage[index], radius = flurry.radius, zone = "body", foot = true,
    }
end

local gliderClips = basicClips(Glider, 12, 13, 14, 20)
gliderClips.canopySlip = {{at = Glider.Contact.canopySlip, damage = canopy.damage, radius = canopy.radius, zone = "body"}}
gliderClips.gustVortex = {}
for index, time in Glider.Contact.gustVortex do
    gliderClips.gustVortex[index] = {
        at = time, damage = gust.damage[index], radius = gust.radius, shape = "radial", zone = "body",
        center = gust.center, lockedCenter = true, controlOnly = index == 1,
    }
end

Sky.kits = table.freeze({
    rooster = {
        poses = Rooster, clips = roosterClips, mixedSpacing = 2.52,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .78,
        signature = "featherFlurry", signatureCooldown = 7.2, signatureCooling = "flurryCooling",
        secondary = "spurLift", secondaryCooldown = 3.1, secondaryCooling = "spurCooling",
    },
    glider = {
        poses = Glider, clips = gliderClips, mixedSpacing = 2.52,
        dodge = "sidestep", dodgeCue = "dodge", dodgeCooldown = .74,
        signature = "gustVortex", signatureCooldown = 7.5, signatureCooling = "gustCooling",
        secondary = "canopySlip", secondaryCooldown = 3, secondaryCooling = "canopyCooling",
    },
})

Sky.gust = gust
Sky.pullAt, Sky.burstAt = table.unpack(Glider.Contact.gustVortex)

function Sky.impulse(event)
    if event.attack == "gustVortex" then
        return gust.shove[event.index], 0, false
    elseif event.attack == "featherFlurry" then
        return flurry.shove[event.index], flurry.popHeight[event.index], event.index == #roosterClips.featherFlurry
    elseif event.attack == "spurLift" then
        return spur.shove, spur.popHeight, false
    elseif event.attack == "canopySlip" then
        return canopy.shove, 0, false
    end
    return nil
end

return table.freeze(Sky)
