-- Snapping Tortoise fights from behind a low guard and braces with the shell.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {
        v(side * .58, 0, -.34), v(side * .58, .047, -.73),
        v(side * .26, .045, -.34), v(side * .90, .045, -.34), v(side * .58, .063, .055),
    }
end

local pivots = {
    Neck = v(0, 3.14, -.07),
    ["Right Shoulder"] = v(.97, 2.93, .13), ["Left Shoulder"] = v(-.97, 2.93, .13),
    ["Right Hip"] = v(.56, 1.46, .06), ["Left Hip"] = v(-.56, 1.46, .06),
    TailJoint = v(0, 1.65, 1.0),
}
local rig = Choreography.new(2.60, pivots, sole(1), sole(-1))
local pose = rig.pose

local rightGuard, leftGuard = {53, 18, -14, -.10, .045, .01}, {51, -16, 16, .09, .05, .005}
local rearFoot, leadFoot = {4, -24, 0, .17, 0, .18, 0}, {5, 19, 0, -.13, 0, -.15, 0}
local gaze, tailRest = {11, 10, 0}, {5, 8, 2}
local ready = pose({.025, -.26, .045, -9, -12, 3}, rightGuard, leftGuard, rearFoot, leadFoot, gaze, tailRest)
local brace = pose({.025, -.20, .025, -7, -10, 2}, {54, 17, -15, -.105, .065, .01},
    {53, -16, 16, .095, .07, .005}, rearFoot, leadFoot, {9, 10, 0}, {8, 8, 2})
local stepLead = pose({-.13, -.28, -.085, -10, -18, 6}, rightGuard,
    {51, -14, 17, .09, .055, .03}, rearFoot, {12, 20, 0, -.18, 0, -.32, .11}, {10, 18, -3}, {7, 19, -5})
local stepRear = pose({.145, -.265, -.067, -10, -5, -6}, {56, 16, -14, -.10, .055, .035},
    leftGuard, {11, -20, 0, .19, 0, -.27, .103}, leadFoot, {10, 5, 4}, {7, -16, 6})
local backLead = pose({-.13, -.28, .14, 3, -17, 6}, rightGuard, leftGuard, rearFoot,
    {-7, 17, 0, -.175, 0, .31, .11}, {-5, 16, -4}, {-8, 20, -5})
local backRear = pose({.15, -.28, .13, 4, -6, -6}, rightGuard, leftGuard,
    {-8, -23, 0, .19, 0, .34, .11}, leadFoot, {-6, 6, 3}, {-9, -17, 6})
local evade = pose({.22, -.34, .075, -13, -26, -17}, {40, 11, -22, .045, .075, .15}, leftGuard,
    {8, -27, 0, .27, 0, .14, .07}, leadFoot, {15, 23, 12}, {-2, 24, -9})
local brake = pose({.13, -.31, .07, -10, -9, -8}, rightGuard, leftGuard,
    {7, -25, 0, .20, 0, .15, 0}, leadFoot, {11, 9, 5}, {5, 16, -4})

local jabCoil = pose({.076, -.31, .107, -12, -25, -5}, {27, 3, -14, -.075, .075, .19},
    leftGuard, rearFoot, leadFoot, {14, 23, 4}, {-1, 24, 9})
local jabClap = pose({.055, -.13, -.22, -7, 24, -2}, {66, 24, -8, -.14, .075, -.19},
    leftGuard, rearFoot, leadFoot, {9, -22, 2}, {17, -27, 4})
local crossCoil = pose({-.105, -.34, .13, -14, 28, 8}, rightGuard,
    {24, -7, 19, .07, .06, .25}, rearFoot, leadFoot, {16, -25, -5}, {4, -27, -6})
local crossClap = pose({-.045, -.17, -.254, -9, -28, 4}, rightGuard,
    {69, -22, 9, .14, .07, -.215}, rearFoot, leadFoot, {9, 26, -5}, {13, 27, -5})
local scoopCoil = pose({.085, -.42, .11, -18, -24, -7}, {24, 7, -14, -.06, -.11, .20}, leftGuard,
    rearFoot, {9, 22, 0, -.18, 0, -.21, 0}, {18, 21, 5}, {11, 28, 6})
local scoopClap = pose({.028, -.36, -.235, -15, 20, 1}, {45, 16, -14, -.14, -.055, -.20},
    leftGuard, rearFoot, {9, 23, 0, -.18, 0, -.22, 0}, {17, -20, 0}, {18, -25, 2})
local heavyCoil = pose({-.14, -.41, .18, -17, 44, 11}, {30, 10, -29, .11, .065, .18},
    {23, -4, 29, -.115, .06, .28}, rearFoot, leadFoot, {19, -37, -6}, {-5, -43, -12})
local heavyClap = pose({-.03, -.145, -.285, -10, -33, 3}, {48, 10, -27, .04, .05, .075},
    {68, -19, 11, .145, .064, -.215}, rearFoot, leadFoot, {12, 31, -1}, {19, 37, -7})
local heavyFollow = pose({-.12, -.31, -.16, -17, -41, 8}, rightGuard,
    {50, -16, 16, .075, -.025, -.075}, rearFoot, leadFoot, {17, 36, -4}, {20, 48, -13})

local checkChamber = pose({.105, -.39, .12, -16, -36, -10}, {23, 8, -20, -.095, .075, .21},
    {57, -16, 15, .09, .12, -.075}, {8, -26, 0, .23, 0, .16, 0}, leadFoot,
    {20, 32, 4}, {10, 36, 8})
local checkHit = pose({.005, -.235, -.31, -14, 31, -6}, {53, 19, -13, -.17, .08, -.25},
    {49, -13, 22, .075, .10, .11}, {7, -24, 0, .18, 0, .14, 0},
    {9, 21, 0, -.16, 0, -.27, 0}, {17, -28, 5}, {15, -29, 8})
local checkEase = pose({.05, -.28, -.15, -16, 21, -5}, {55, 17, -16, -.13, .06, -.10},
    leftGuard, rearFoot, {9, 21, 0, -.15, 0, -.23, 0}, {17, -18, 4}, {12, -23, 7})

local lowRight, lowLeft = {11, -24, 0, .145, 0, .145, 0}, {11, 24, 0, -.145, 0, -.10, 0}
local prepareTuck = pose({0, -.43, .10, -13, 0, 0},
    {43, 11, -16, -.14, .115, .16}, {43, -11, 16, .14, .115, .16},
    lowRight, lowLeft, {17, 0, 0, 0, -.13, .23}, {18, 0, 0, 0, .15, -.125})
-- The server applies wheel rotation about the shell centre. The tucked keys
-- stay neutral and fixed so the moving shell never wobbles or opens early.
local tucked = pose({0, -.24, 0, 0, 0, 0},
    {52, 18, -10, -.26, -.33, 1.07}, {52, -18, 10, .26, -.33, 1.07},
    {71, -11, 0, -.11, .42, 1.35}, {71, 11, 0, .11, .42, 1.35},
    {24, 0, 0, 0, -.74, .83}, {30, 0, 0, 0, .52, -.54})
local openShell = pose({0, -.47, .018, -12, 0, 0},
    {48, 10, -14, -.15, .10, .16}, {48, -10, 14, .15, .10, .16},
    lowRight, lowLeft, {17, 0, 0, 0, -.07, .14}, {11, 0, 0, 0, .09, -.09})

local cover = pose({0, -.36, .075, -12, 0, 0},
    {70, 10, -13, -.19, .11, -.035}, {68, -10, 12, .19, .11, -.035},
    rearFoot, leadFoot, {16, 0, 0}, {10, 0, 0})
local recoil = pose({-.035, -.41, .16, 4, -7, 5}, {62, 11, -12, -.16, .105, .11},
    {64, -12, 12, .17, .105, .09}, rearFoot, leadFoot, {-8, 6, -3}, {-6, 9, -4})
local deflect = pose({.06, -.28, -.07, -11, 28, -8}, {59, -18, -13, -.115, .155, -.115},
    {57, -14, 22, .075, .095, .07}, rearFoot, leadFoot, {12, -22, 5}, {6, -28, 7})
local hitHead = pose({-.12, -.26, .22, 15, -18, 9}, {40, 12, -24, .09, .075, .13},
    {41, -15, 21, -.075, .085, .13}, rearFoot, leadFoot, {-24, 16, -7}, {-9, 21, -8})
local hitBody = pose({.105, -.48, .14, -25, 16, -8}, {44, 17, -19, .015, -.04, .035},
    {45, -15, 20, -.02, -.035, .025}, rearFoot, leadFoot, {23, -16, 5}, {22, -23, 7})
local salute = pose({.03, -.11, -.05, -4, -17, 2}, {81, 2, -28, -.02, .12, -.09},
    leftGuard, rearFoot, leadFoot, {5, 16, 0}, {12, 16, -2})
local bow = pose({0, -.40, -.12, -27, 0, 0}, {31, 15, -16, -.035, .045, .08},
    {32, -15, 16, .035, .045, .08}, rearFoot, leadFoot, {23, 0, 0}, {8, 0, 0})
local victory = pose({-.01, -.10, -.055, -4, 1, 0}, {76, 6, -32, .11, .075, -.11},
    {75, -6, 32, -.11, .075, -.11}, rearFoot, leadFoot, {4, -1, 0}, {14, 1, 0})

local contact = {jab = .18, cross = .241, body = .29, heavy = .453, shellCheck = .345, fortressRicochet = .44}
local rollSeconds = 4
local rollEnds = contact.fortressRicochet + rollSeconds
local clips = {
    stance = {{0, ready}, {.50, brace}, {1.03, ready}},
    advance = {{0, ready}, {.18, stepLead}, {.36, brace}, {.54, stepRear}, {.72, ready}},
    retreat = {{0, ready}, {.18, backRear}, {.36, ready}, {.54, backLead}, {.72, ready}},
    sidestep = {{0, ready}, {.116, evade}, {.247, brake}, {.50, ready}},
    jab = {{0, ready}, {.086, jabCoil}, {contact.jab, jabClap}, {.258, jabClap}, {.46, ready}},
    cross = {{0, ready}, {.114, crossCoil}, {contact.cross, crossClap}, {.336, crossClap}, {.545, ready}},
    body = {{0, ready}, {.14, scoopCoil}, {contact.body, scoopClap}, {.41, brace}, {.61, ready}},
    heavy = {{0, ready}, {.20, heavyCoil}, {.32, heavyCoil}, {contact.heavy, heavyClap}, {.57, heavyFollow}, {.85, ready}},
    shellCheck = {{0, ready}, {.14, checkChamber}, {.228, checkChamber}, {contact.shellCheck, checkHit},
        {.46, checkEase}, {.72, ready}},
    fortressRicochet = {{0, ready}, {.20, prepareTuck}, {contact.fortressRicochet, tucked}, {rollEnds, tucked},
        {rollEnds + .17, openShell}, {4.83, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.082, recoil}, {.168, recoil}, {.29, cover}},
    parry = {{0, cover}, {.096, deflect}, {.188, deflect}, {.36, ready}},
    hitHead = {{0, ready}, {.078, hitHead}, {.186, hitHead}, {.36, ready}},
    hitBody = {{0, ready}, {.093, hitBody}, {.20, hitBody}, {.38, ready}},
    stagger = {{0, hitHead}, {.17, brake}, {.365, recoil}, {.58, ready}},
    intro = {{0, ready}, {.91, brace}, {1.70, salute}, {2.32, salute}, {2.94, bow}, {3.51, ready},
        {4.4, prepareTuck}, {4.84, openShell}, {5.34, ready}, {6.24, checkChamber}, {6.63, checkHit},
        {7.24, brake}, {8.20, ready}, {9, brace}, {10, ready}},
    win = {{0, ready}, {.32, victory}, {.93, victory}, {1.22, bow}, {1.57, bow}, {2.04, ready}},
}

local rightPalm, leftPalm = v(1.30, 1.92, -.724), v(-1.30, 1.92, -.724)
local shellCenter = v(0, -.14, .37)
-- Floor-to-hub height for each 15 degrees of positive pitch, starting at zero.
-- These contact heights come from the visible hull and tucked art at the roll key.
local shellSupportHeights = table.freeze({
    1.31000, 1.33204, 1.38828, 1.42303, 1.39128, 1.36986,
    1.46750, 1.48115, 1.54451, 1.55440, 1.50164, 1.39044,
    1.31000, 1.23110, 1.34225, 1.45293, 1.46459, 1.38874,
    1.37700, 1.56108, 1.63877, 1.60478, 1.46143, 1.23110,
})
local hits = {
    jab = {{jabClap, "Right Shoulder", rightPalm}},
    cross = {{crossClap, "Left Shoulder", leftPalm}},
    body = {{scoopClap, "Right Shoulder", rightPalm}},
    heavy = {{heavyClap, "Left Shoulder", leftPalm}},
    shellCheck = {{checkHit, "Right Shoulder", rightPalm}},
    fortressRicochet = {tucked.RootJoint:PointToWorldSpace(shellCenter)},
}
local skills = {
    shellCheck = table.freeze({damage = 22, radius = .54, shove = .96}),
    fortressRicochet = table.freeze({windup = contact.fortressRicochet, rollSeconds = rollSeconds,
        radius = 1.10, damage = 25, shove = 1.25, speed = 9.2, shellCenter = shellCenter,
        supportHeights = shellSupportHeights}),
}
local travel = {
    shellCheck = table.freeze({axis = "forward", distance = .48, startsAt = .16, endsAt = .31}),
}

local standard = rig.finish(clips, contact, hits, skills, travel, {"sidestep"})

-- Fit the additional strikes to the mounted combat root. Keep both rounded soles
-- grounded at contact and let the trunk move independently.
local mountedRig = Choreography.new(2.132, pivots, sole(1), sole(-1))
local leftHip, rightHip = "Left Hip", "Right Hip"
local leftPlant = CFrame.new(0, .019, 0) * ready.RootJoint * ready[leftHip]
local rightPlant = CFrame.new(0, .019, 0) * ready.RootJoint * ready[rightHip]

local function smooth(alpha)
    local weight = math.clamp(alpha, 0, 1)
    return weight * weight * (3 - 2 * weight)
end

local function plantFeet(offsets, action, age)
    local root = offsets.RootJoint
    offsets[leftHip] = root:ToObjectSpace(leftPlant)
    local rear = rightPlant
    if action == "rampartBash" then
        -- Set the right foot in front before the shell comes through, then reset it.
        local enter, leave = (age - .15) / .25, (age - .64) / .28
        local planted = smooth(enter) - smooth(leave)
        local lift = .18 * (math.sin(math.pi * math.clamp(enter, 0, 1)) ^ 2
            + math.sin(math.pi * math.clamp(leave, 0, 1)) ^ 2)
        rear = CFrame.new(-.40 * planted, lift, -.82 * planted) * rightPlant
    end
    offsets[rightHip] = root:ToObjectSpace(rear)
    return offsets
end

local function fitted(core, right, left, head, tail)
    return mountedRig.pose(core, right, left, rearFoot, leadFoot, head, tail)
end

local snapGather = fitted({.025, -.25, .074, -4, -12, 2}, rightGuard, leftGuard,
    {21, 9, -2, 0, .01, .08}, {2, 10, 2})
local snapHit = fitted({.035, -.34, -.22, -17, -2, 0}, {50, 18, -15, -.105, .05, .09},
    {48, -17, 16, .105, .05, .09}, {-24, 3, 0, 0, -.04, -.26}, {9, 9, 0})
local snapRecoil = fitted({.018, -.32, -.125, -10, -7, 2}, rightGuard, leftGuard,
    {-4, 6, -3, 0, .016, -.07}, {5, 12, 2})

local bashLoad = fitted({-.068, -.34, .14, -10, -38, 7}, {46, 20, -18, -.10, .09, .13},
    {62, -13, 19, .075, .12, .07}, {17, 27, -3, 0, -.105, .10}, {11, 24, -5})
local bashStart = fitted({-.13, -.36, .05, -8, 8, 3}, {43, 19, -20, -.13, .08, .14},
    {60, -15, 19, .086, .10, .10}, {18, -8, -5, 0, -.16, .15}, {18, 11, -8})
local bashHit = fitted({-.27, -.26, -.60, -8, 83, -2}, {46, 16, -23, -.21, .13, .19},
    {55, -17, 17, .08, .08, .13}, {15, -42, -6, 0, -.14, .14}, {14, -30, 10})
local bashThrough = fitted({-.31, -.28, -.42, -6, 91, -4}, {48, 15, -22, -.17, .10, .14},
    {58, -17, 15, .09, .11, .12}, {16, -40, -6, 0, -.135, .14}, {14, -36, 5})
local bashWithdraw = fitted({-.14, -.30, -.055, -7, 25, 0}, rightGuard, leftGuard,
    {12, -21, -3, 0, -.035, .055}, {11, -19, 3})

local tacticalContact = {quickSnap = .23, rampartBash = .51}
local tacticalClips = {
    quickSnap = {{0, ready}, {.095, snapGather}, {tacticalContact.quickSnap, snapHit},
        {.315, snapRecoil}, {.60, ready}},
    rampartBash = {{0, ready}, {.17, bashLoad}, {.295, bashLoad}, {.38, bashStart},
        {tacticalContact.rampartBash, bashHit}, {.59, bashThrough}, {.77, bashWithdraw}, {.97, ready}},
}
-- Surface samples come from the blunt beak and broad shell rim at full contact.
local tacticalHits = {
    quickSnap = {{snapHit, "Neck", v(.004858011, 3.751437919, -1.071198672)}},
    rampartBash = {bashHit.RootJoint:PointToWorldSpace(v(1.271194983, .558756863, .507326925))},
}
local tacticalSkills = {
    quickSnap = table.freeze({damage = 14, radius = .50}),
    rampartBash = table.freeze({damage = 22, radius = .56, shove = 1.12}),
}
local tactical = mountedRig.finish(tacticalClips, tacticalContact, tacticalHits, tacticalSkills, {}, {})
local poses = table.clone(standard)
for _, field in {"Duration", "Contact", "Impact", "Skill"} do
    local values = table.clone(standard[field])
    for move, value in tactical[field] do
        values[move] = value
    end
    poses[field] = table.freeze(values)
end

function poses.sample(action, age, direction)
    if tacticalContact[action] then
        return plantFeet(tactical.sample(action, age, direction), action, age or 0)
    end
    return standard.sample(action, age, direction)
end

function poses.impact(action, index, direction)
    local source = if tacticalContact[action] then tactical else standard
    return source.impact(action, index, direction)
end

return table.freeze(poses)
