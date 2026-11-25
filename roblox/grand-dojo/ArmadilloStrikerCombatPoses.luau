-- Armadillo shows his shoulder plate before a short, committed wheel rush.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    local x = side * .53
    return {v(x - .41, .012, -.775), v(x + .41, .012, -.775),
        v(x - .41, .012, .155), v(x + .41, .012, .155)}
end

local rig = Choreography.new(rootHeight, {
    Neck = v(0, 3.10, -.11),
    ["Right Shoulder"] = v(.96, 2.83, .06), ["Left Shoulder"] = v(-.96, 2.83, .06),
    ["Right Hip"] = v(.53, 1.43, .03), ["Left Hip"] = v(-.53, 1.43, .03),
    TailJoint = v(0, 1.61, .78),
}, sole(1), sole(-1))
local pose = rig.pose

local rightGuard, leftGuard = {50, 13, -15, -.03, .11, .07}, {44, -19, 16, .075, .08, -.04}
local rear, lead = {5, -22, 0, .15, 0, .11, .015}, {7, 19, 0, -.12, 0, -.16, .015}
local ready = pose({.02, -.19, .04, -10, -13, 3}, rightGuard, leftGuard, rear, lead, {11, 13, -1}, {8, 14, 3})
local breathe = pose({.018, -.12, .02, -8, -11, 2}, {49, 14, -17, -.035, .08, .07}, leftGuard,
    rear, lead, {10, 11, -1}, {10, 12, 2})
local stepLead = pose({-.15, -.23, -.135, -12, -18, 7}, rightGuard, leftGuard, rear,
    {16, 19, 0, -.20, 0, -.38, .17}, {12, 18, -5}, {13, 23, -5})
local stepRear = pose({.16, -.205, -.115, -13, -4, -7}, rightGuard, leftGuard,
    {13, -18, 0, .21, 0, -.32, .14}, lead, {13, 4, 4}, {12, -17, 6})
local backLead = pose({-.14, -.24, .15, 2, -17, 7}, rightGuard, leftGuard, rear,
    {-12, 18, 0, -.19, 0, .28, .13}, {-2, 16, -4}, {-10, 22, -4})
local backRear = pose({.15, -.24, .16, 3, -6, -6}, rightGuard, leftGuard,
    {-10, -21, 0, .20, 0, .37, .13}, lead, {-3, 6, 4}, {-11, -18, 5})
local dodge = pose({.25, -.36, .07, -15, -24, -19}, {29, 10, -27, .075, .07, .15}, leftGuard,
    {12, -24, 0, .28, 0, .16, .12}, lead, {16, 24, 10}, {12, 35, -9})
local brake = pose({.13, -.29, .005, -14, -4, -10}, rightGuard, leftGuard,
    {8, -21, 0, .22, 0, .13, .018}, lead, {15, 4, 9}, {17, 15, -4})

local jabLoad = pose({.09, -.26, .115, -9, -29, -6}, {31, 7, -16, -.065, .07, .19}, leftGuard,
    rear, lead, {10, 25, 4}, {8, 24, -5})
local jabHit = pose({.04, -.11, -.22, -7, 23, -2}, {63, 20, -11, -.15, .07, -.21}, leftGuard,
    rear, lead, {9, -22, 2}, {16, -22, 2})
local crossLoad = pose({-.10, -.31, .13, -13, 30, 8}, rightGuard, {26, -7, 21, .07, .06, .25},
    rear, lead, {13, -26, -4}, {8, -23, 5})
local crossHit = pose({-.05, -.16, -.28, -8, -26, 4}, rightGuard, {66, -19, 10, .15, .10, -.22},
    rear, lead, {9, 25, -3}, {14, 26, -4})
local bodyLoad = pose({.05, -.42, .16, -20, -31, -7}, {26, 9, -18, -.08, -.09, .22}, leftGuard,
    rear, lead, {20, 28, 5}, {10, 27, 7})
local bodyHit = pose({.035, -.35, -.25, -18, 22, -2}, {51, 21, -12, -.13, -.12, -.22}, leftGuard,
    rear, lead, {17, -20, 2}, {22, -26, 4})
local heavyLoad = pose({-.14, -.43, .19, -18, 40, 12}, {29, 12, -30, .16, .04, .21},
    {21, -6, 29, -.15, .075, .29}, rear, lead, {20, -38, -7}, {3, -40, -9})
local heavyHit = pose({-.025, -.16, -.28, -10, -33, 5}, {47, 10, -29, .10, .075, .06},
    {67, -18, 11, .16, .08, -.215}, rear, lead, {12, 31, -3}, {20, 40, -4})
local heavyEase = pose({-.14, -.30, -.17, -18, -43, 6}, rightGuard, {46, -13, 16, .09, .045, -.09},
    rear, lead, {17, 38, -2}, {19, 45, -7})

local plateLoad = pose({.15, -.43, .12, -18, -37, -14}, {30, -4, -22, -.11, .07, .23},
    {67, -11, 20, .10, .11, -.04}, rear, lead, {20, 35, 7}, {12, 33, 9})
local plateHit = pose({.02, -.24, -.29, -14, 27, -7}, {53, 9, -24, -.11, .07, -.34},
    {50, -14, 21, .07, .11, .09}, rear, lead, {16, -25, 5}, {18, -27, 5})
local plateEase = pose({.05, -.31, -.17, -21, 21, -8}, {46, 14, -26, -.095, .03, -.16}, leftGuard,
    rear, lead, {19, -19, 7}, {16, -24, 4})

-- Keep the left palm compact as the chest turns through the target.
local rivetLoad = pose({-.07, -.29, .09, -11, 13, 6}, {53, 16, -20, -.025, .12, .11},
    {29, -3, 9, .06, .065, .17}, rear, lead, {12, -11, -4}, {8, -12, 5})
local rivetHit = pose({-.015, -.245, -.09, -10, -25, 4}, {56, 17, -23, -.045, .13, .13},
    {55, -16, 14, .09, .10, -.10}, rear, lead, {11, 23, -3}, {12, 18, -3})
local rivetFold = pose({-.045, -.27, -.035, -10, -14, 4}, {54, 17, -20, -.035, .12, .09},
    {50, -17, 15, .08, .11, -.02}, rear, lead, {11, 13, -2}, {10, 11, -2})

-- Turn the plated shoulder through the strike while the glove folds behind
-- the lip and the muzzle turns away, leaving the armor to lead the silhouette.
local kilnLoad = pose({-.115, -.30, .10, -12, -25, 8}, {36, 7, -20, -.045, .11, .16},
    {59, -15, 20, .10, .10, .01}, rear, lead, {13, 22, -4}, {9, 23, -6})
local kilnCoil = pose({-.155, -.40, .125, -15, -40, 12}, {21, 11, -21, -.075, .09, .11},
    {59, -11, 23, .095, .10, .045}, rear, lead, {16, 32, -6}, {9, 33, -8})
local kilnTuck = pose({-.08, -.35, .025, -14, 15, 9}, {-14, 10, -25, -.035, .12, .01},
    {45, -22, 18, .075, .12, .135}, rear, lead, {12, -13, -7}, {10, -12, -4})
local kilnHit = pose({.13, -.18, -.45, -16, 73, -8}, {-36, 11, -25, -.025, .11, -.025},
    {27, -26, 17, .09, .095, .21}, rear, lead, {15, -16, 8, .065, -.10, .13}, {14, -30, 8})
local kilnFollow = pose({.095, -.29, -.355, -14, 77, -6}, {-28, 14, -21, -.04, .095, .015},
    {31, -20, 17, .08, .08, .17}, rear, lead, {11, -17, 5, .04, -.065, .09}, {15, -30, 7})
local kilnEase = pose({.045, -.31, -.065, -13, 24, -2}, {27, 13, -18, -.04, .08, .055},
    leftGuard, rear, lead, {12, -16, 2}, {13, -20, 4})

local fold = pose({0, -.43, .07, 4, 0, 0}, {47, 15, -24, -.17, -.05, .24},
    {47, -15, 24, .17, -.05, .24}, {27, -17, 0, .07, .045, .22, .023},
    {27, 17, 0, -.07, .045, .22, .023}, {-27, 0, 0, 0, -.20, .26}, {-24, 0, 0, 0, .21, -.14})
-- The path renderer spins this fixed pose about the shell hub during travel.
local tucked = pose({0, -1.205, -.15, 0, 0, 0}, {51, 14, -23, -.34, -.51, 1.00},
    {51, -14, 23, .34, -.51, 1.00}, {64, -8, 2, -.14, .61, 1.26},
    {64, 8, -2, .14, .61, 1.26}, {-37, 0, 0, 0, -.85, .77}, {-56, 0, 0, 0, .37, -.58})
local unroll = pose({0, -.43, .04, -17, 0, 0}, {49, 15, -20, -.12, .05, .14},
    {49, -15, 20, .12, .05, .14}, {15, -25, 0, .22, 0, .17, .015},
    {15, 25, 0, -.22, 0, -.17, .015}, {15, 0, 0, 0, -.06, .04}, {9, 0, 0, 0, .06, -.07})

local cover = pose({0, -.31, .075, -15, 0, 0}, {67, 12, -17, -.19, .12, -.03},
    {67, -11, 17, .18, .12, -.03}, rear, lead, {15, 0, 0}, {10, 0, 0})
local recoil = pose({-.06, -.38, .14, 4, -7, 5}, {60, 12, -16, -.14, .10, .10},
    {61, -13, 15, .17, .11, .09}, rear, lead, {-7, 7, -4}, {-5, 10, -4})
local deflect = pose({.06, -.26, -.08, -11, 27, -7}, {57, -18, -13, -.10, .15, -.13},
    {55, -14, 22, .08, .10, .05}, rear, lead, {11, -24, 4}, {12, -24, 6})
local hitHigh = pose({-.11, -.22, .23, 14, -17, 8}, {36, 12, -27, .10, .07, .13},
    {40, -15, 22, -.08, .07, .15}, rear, lead, {-23, 15, -6}, {-9, 21, -8})
local hitLow = pose({.12, -.43, .15, -24, 16, -8}, {41, 18, -19, .03, -.06, .035},
    {44, -15, 20, -.035, -.05, .035}, rear, lead, {24, -15, 7}, {18, -24, 7})
local salute = pose({.03, -.09, -.055, -4, -17, 2}, {81, 5, -28, .03, .12, -.09},
    leftGuard, rear, lead, {4, 16, 0}, {12, 16, -2})
local bow = pose({0, -.33, -.11, -27, 0, 0}, {34, 16, -16, -.035, .04, .08},
    {34, -16, 16, .035, .04, .08}, rear, lead, {22, 0, 0}, {4, 0, 0})
local raised = pose({0, -.08, -.065, -5, 1, 0}, {74, 7, -31, .11, .11, -.10},
    {73, -7, 31, -.11, .11, -.10}, rear, lead, {4, -1, 0}, {12, 1, 0})

local contact = {jab = .174, cross = .237, body = .29, heavy = .46, plateCheck = .33, rivetPalm = .25, kilnShoulder = .52, meteorRoll = .39}
local rollSeconds = .95
local rollEnds = contact.meteorRoll + rollSeconds
local clips = {
    stance = {{0, ready}, {.46, breathe}, {.94, ready}},
    advance = {{0, ready}, {.17, stepLead}, {.34, breathe}, {.51, stepRear}, {.69, ready}},
    retreat = {{0, ready}, {.18, backRear}, {.36, ready}, {.54, backLead}, {.71, ready}},
    sidestep = {{0, ready}, {.104, dodge}, {.25, brake}, {.50, ready}},
    jab = {{0, ready}, {.078, jabLoad}, {contact.jab, jabHit}, {.248, jabHit}, {.45, ready}},
    cross = {{0, ready}, {.115, crossLoad}, {contact.cross, crossHit}, {.328, crossHit}, {.54, ready}},
    body = {{0, ready}, {.136, bodyLoad}, {contact.body, bodyHit}, {.41, breathe}, {.60, ready}},
    heavy = {{0, ready}, {.20, heavyLoad}, {.32, heavyLoad}, {contact.heavy, heavyHit}, {.57, heavyEase}, {.85, ready}},
    plateCheck = {{0, ready}, {.14, plateLoad}, {.205, plateLoad}, {contact.plateCheck, plateHit},
        {.445, plateEase}, {.71, ready}},
    rivetPalm = {{0, ready}, {.10, rivetLoad}, {contact.rivetPalm, rivetHit}, {.37, rivetFold}, {.62, ready}},
    kilnShoulder = {{0, ready}, {.15, kilnLoad}, {.29, kilnCoil}, {.40, kilnTuck}, {contact.kilnShoulder, kilnHit},
        {.64, kilnFollow}, {.81, kilnEase}, {.98, ready}},
    meteorRoll = {{0, ready}, {.20, fold}, {contact.meteorRoll, tucked}, {rollEnds, tucked},
        {rollEnds + .30, tucked}, {rollEnds + .44, unroll}, {rollEnds + .61, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.082, recoil}, {.166, recoil}, {.29, cover}},
    parry = {{0, cover}, {.096, deflect}, {.186, deflect}, {.35, ready}},
    hitHead = {{0, ready}, {.079, hitHigh}, {.181, hitHigh}, {.36, ready}},
    hitBody = {{0, ready}, {.094, hitLow}, {.194, hitLow}, {.38, ready}},
    stagger = {{0, hitHigh}, {.17, brake}, {.36, recoil}, {.58, ready}},
    intro = {{0, ready}, {.93, breathe}, {1.70, salute}, {2.26, salute}, {2.96, bow}, {3.52, ready},
        {4.39, fold}, {4.82, unroll}, {5.36, ready}, {6.27, plateLoad}, {6.62, plateHit},
        {7.24, brake}, {8.21, ready}, {9.0, breathe}, {10, ready}},
    win = {{0, ready}, {.33, raised}, {.92, raised}, {1.22, bow}, {1.57, bow}, {2.04, ready}},
}

local rightFist, leftFist = v(1.24, 1.80, -.78), v(-1.24, 1.80, -.78)
local forearm = v(1.508, 2.087, -.392)
local shellCenter = v(0, 2.46 - rootHeight, .15)
-- Floor-to-hub heights for each 15 degrees of the exact tucked art envelope.
local supportHeights = table.freeze({
    1.23000, 1.20692, 1.28870, 1.36356, 1.37701, 1.32751,
    1.23500, 1.16524, 1.10820, 1.08489, 1.08587, 1.20513,
    1.25187, 1.21979, 1.12833, 1.24413, 1.27515, 1.21926,
    1.19794, 1.27647, 1.38694, 1.40290, 1.34706, 1.29275,
})
local hits = {
    jab = {{jabHit, "Right Shoulder", rightFist}}, cross = {{crossHit, "Left Shoulder", leftFist}},
    body = {{bodyHit, "Right Shoulder", rightFist}}, heavy = {{heavyHit, "Left Shoulder", leftFist}},
    plateCheck = {{plateHit, "Right Shoulder", forearm}},
    -- Rounded parts in the shipped shell, in the rest floor frame.
    rivetPalm = {{rivetHit, "Left Shoulder", v(-1.542710051, 1.738834120, -.663426084)}},
    kilnShoulder = {{kilnHit, "Right Shoulder", v(1.499209984, 3.050060771, .027655620)}},
    meteorRoll = {tucked.RootJoint:PointToWorldSpace(shellCenter)},
}
local skills = {
    rivetPalm = table.freeze({damage = 15, radius = .46}),
    kilnShoulder = table.freeze({damage = 24, radius = .51}),
    plateCheck = table.freeze({damage = 21, radius = .52, shove = .95}),
    meteorRoll = table.freeze({windup = contact.meteorRoll, rollSeconds = rollSeconds, rootHeight = rootHeight,
        speed = 10.55, wheelRadius = 1.12, radius = 1.05, damage = 30, shove = 1.65,
        shellCenter = shellCenter, supportHeights = supportHeights, groundRecovery = true,
        reflect = false, guideName = "Meteor Roll guide"}),
}
local travel = {plateCheck = table.freeze({axis = "forward", distance = .47, startsAt = .16, endsAt = .31})}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"}, {rivetPalm = true, kilnShoulder = true})
