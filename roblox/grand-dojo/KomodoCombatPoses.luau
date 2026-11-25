-- Komodo counters with a low sweeping tail and turns the snout through a broad arc.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    local x = side * .50
    return {v(x - .3525, .012, -.855), v(x + .3525, .012, -.855),
        v(x - .3525, .012, .135), v(x + .3525, .012, .135)}
end

local rig = Choreography.new(rootHeight, {
    Neck = v(0, 3.14, -.14),
    ["Right Shoulder"] = v(.91, 2.99, .04), ["Left Shoulder"] = v(-.91, 2.99, .04),
    ["Right Hip"] = v(.50, 1.55, .04), ["Left Hip"] = v(-.50, 1.55, .04),
    TailJoint = v(0, 1.71, .52),
}, sole(1), sole(-1))
local pose = rig.pose

local rightGuard, leftGuard = {45, 17, -17, -.025, .115, .065}, {54, -19, 18, .085, .09, -.04}
local rear, lead = {5, -24, 1, .14, 0, .145, .018}, {7, 16, -1, -.12, 0, -.20, .018}
local ready = pose({.018, -.22, .055, -12, -12, 4}, rightGuard, leftGuard, rear, lead, {12, 13, -2}, {-4, 14, 5})
local breathe = pose({.035, -.17, .026, -10, -9, 2}, {48, 15, -20, -.03, .10, .06}, leftGuard,
    rear, lead, {10, 10, -1}, {-3, 19, 2})
local stepLead = pose({-.145, -.25, -.14, -12, -15, 7}, rightGuard, leftGuard, rear,
    {13, 17, -2, -.16, 0, -.36, .16}, {12, 15, -5}, {-16, 28, -7})
local stepRear = pose({.153, -.22, -.12, -12, -3, -7}, rightGuard, leftGuard,
    {13, -22, 2, .20, 0, -.33, .14}, lead, {12, 4, 4}, {-14, -19, 9})
local backLead = pose({-.15, -.25, .145, 0, -17, 6}, rightGuard, leftGuard, rear,
    {-11, 15, -2, -.175, 0, .32, .12}, {0, 16, -4}, {-18, 26, -5})
local backRear = pose({.143, -.27, .15, 1, -5, -6}, rightGuard, leftGuard,
    {-9, -23, 2, .18, 0, .35, .12}, lead, {0, 5, 4}, {-18, -20, 8})
local slip = pose({.25, -.34, .08, -15, -22, -20}, {31, 12, -27, .08, .05, .18}, leftGuard,
    {11, -26, -2, .24, 0, .16, .10}, lead, {16, 22, 10}, {-14, 38, -18})
local brake = pose({.14, -.30, .03, -12, -5, -10}, rightGuard, leftGuard,
    {8, -23, 0, .17, 0, .13, .018}, lead, {12, 5, 8}, {-13, 24, -4})

local jabLoad = pose({.08, -.26, .12, -12, -26, -6}, {29, 7, -16, .035, .09, .20}, leftGuard,
    rear, lead, {13, 25, 4}, {-8, 29, -7})
local jabHit = pose({.025, -.105, -.235, -7, 23, -1}, {66, 18, -11, -.14, .145, -.22}, leftGuard,
    rear, lead, {9, -24, 1}, {-9, -29, 4})
local crossLoad = pose({-.11, -.32, .13, -12, 26, 8}, rightGuard, {25, -6, 22, -.05, .075, .25},
    rear, lead, {13, -27, -4}, {-11, -30, -7})
local crossHit = pose({-.06, -.16, -.26, -9, -28, 4}, rightGuard, {67, -19, 11, .13, .095, -.215},
    rear, lead, {12, 27, -3}, {-15, 32, 7})
local bodyLoad = pose({.05, -.40, .13, -19, -25, -7}, {24, 9, -19, .035, -.055, .23}, leftGuard,
    rear, lead, {19, 23, 4}, {-13, 28, 4})
local bodyHit = pose({.028, -.33, -.25, -19, 19, 1}, {50, 16, -15, -.13, -.07, -.23}, leftGuard,
    rear, lead, {20, -20, 2}, {-11, -24, 3})
local heavyLoad = pose({-.12, -.42, .19, -18, 40, 11}, {29, 15, -27, .15, .05, .22},
    {22, -7, 30, -.12, .045, .29}, rear, lead, {19, -34, -6}, {-22, -49, -9})
local heavyHit = pose({.03, -.15, -.28, -9, -32, 4}, {49, 11, -27, .025, .075, .06},
    {68, -15, 6, .14, .055, -.22}, rear, lead, {12, 30, -2}, {-15, 41, 9})
local heavyEase = pose({.08, -.30, -.14, -16, -43, -6}, rightGuard, {55, -10, 15, .08, .055, -.09},
    rear, lead, {17, 40, 3}, {-9, 60, 12})

local tailDraw = pose({-.11, -.31, .12, -6, -32, 12}, {61, 11, -29, .11, .13, .11},
    {33, -4, 39, -.12, .07, .06}, rear, lead, {8, 31, -7}, {-17, 36, -20})
local tailPass = pose({.075, -.26, -.12, -7, 10, -9}, {61, 11, -26, .06, .13, .025},
    {45, -12, 36, -.10, .09, .08}, rear, lead, {10, -10, 6}, {-13, 99, -18})
local tailHit = pose({.02, -.13, -.20, -6, 26, -3}, {65, 14, -24, .05, .14, .09},
    {38, -11, 34, -.06, .075, .09}, rear, lead, {7, -26, 3}, {10, 154, 7})
local tailFollow = pose({-.105, -.27, -.16, -13, 39, 8}, {57, 17, -32, .12, .1, .13},
    {44, -16, 33, -.06, .065, .11}, rear, lead, {15, -38, -6}, {9, 202, 11})
local tailReset = pose({-.04, -.32, -.055, -13, 22, 7}, rightGuard, leftGuard,
    rear, lead, {14, -24, -3}, {-14, 293, 10})

local snapLoad = pose({.052, -.25, .11, -4, -13, 5}, {52, 14, -20, -.06, .12, .11},
    {57, -15, 17, .09, .11, .085}, rear, lead, {21, 10, -3, 0, .035, .10}, {-9, 19, 5})
local snapHit = pose({.038, -.13, -.27, -12, 1, 1}, {53, 15, -18, -.045, .07, .11},
    {56, -17, 19, .075, .085, .095}, rear, lead, {0, -1, -3, 0, .10, -.27}, {4, 2, -2})
local snapFold = pose({.025, -.28, -.06, -8, -7, 3}, rightGuard, leftGuard,
    rear, lead, {-3, 7, -2, 0, -.03, -.065}, {-4, 12, 2})

local heelLoad = pose({-.12, -.30, .085, -9, -22, 10}, {40, 21, -20, -.07, .10, .15},
    {60, -17, 20, .055, .16, .025}, rear, lead, {11, 20, -6}, {-3, 31, 11})
local heelLift = pose({-.19, -.19, .045, 4, -15, 12}, {32, 17, -27, .08, .08, .20},
    {59, -17, 20, .08, .14, .045}, {56, -14, 3, .15, .13, .12}, lead, {-3, 14, -8}, {11, 30, 10})
local heelChamber = pose({-.205, -.12, -.005, 9, 0, 11}, {37, 12, -30, .11, .065, .19},
    {57, -20, 19, .075, .14, .055}, {79, -3, 4, .17, .23, .02}, lead, {-7, 1, -8}, {12, 18, 8})
local heelHit = pose({-.18, -.055, -.30, 9, 21, 8}, {32, 17, -28, .11, .09, .16},
    {64, -19, 22, .08, .14, .09}, {111, 4, 1, .12, .39, -.23}, lead, {-9, -18, -6}, {8, -13, 4})
local heelFollow = pose({-.208, -.12, -.175, 7, 25, 10}, {36, 15, -23, .10, .055, .15},
    {61, -17, 20, .075, .12, .08}, {102, 1, 0, .155, .22, -.12}, lead, {-6, -20, -7}, {7, -18, 6})
local heelWithdraw = pose({-.15, -.23, .025, -4, -1, 8}, rightGuard, leftGuard,
    {54, -11, 2, .17, .13, .055}, lead, {5, 1, -6}, {1, 12, 7})

local breathFeet = {8, -21, 0, .19, 0, .19, .017}
local breathLead = {12, 16, 0, -.16, 0, -.26, .017}
local inhale = pose({-.07, -.25, .13, 3, 11, 5}, {45, 14, -25, .06, .085, .12},
    {44, -10, 27, -.07, .10, .14}, breathFeet, breathLead, {-8, 27, -4}, {-19, -18, 7})
local flameLeft = pose({-.10, -.34, -.16, -14, 10, 4}, {49, 10, -31, .04, .075, .08},
    {48, -15, 27, -.04, .11, .10}, breathFeet, breathLead, {18, 20, -1}, {-22, -20, -6})
local flameCenter = pose({0, -.30, -.185, -14, 0, 0}, {50, 12, -27, .05, .10, .10},
    {51, -13, 28, -.05, .115, .085}, breathFeet, breathLead, {18, 0, 0}, {-21, 0, 0})
local flameRight = pose({.11, -.32, -.15, -14, -10, -4}, {47, 15, -27, .04, .08, .10},
    {49, -9, 30, -.05, .095, .08}, breathFeet, breathLead, {18, -20, 1}, {-22, 22, 6})
local breathEase = pose({.10, -.25, -.08, -8, -19, -5}, rightGuard, leftGuard, breathFeet,
    breathLead, {11, -16, 3}, {-18, 30, 6})

local cover = pose({0, -.30, .085, -13, 0, 0}, {69, 12, -17, -.18, .13, -.035},
    {67, -11, 17, .18, .12, -.02}, rear, lead, {15, 0, 0}, {-10, 0, 0})
local recoil = pose({-.055, -.36, .16, 6, -7, 6}, {61, 13, -15, -.14, .085, .105},
    {61, -13, 15, .16, .095, .10}, rear, lead, {-10, 7, -5}, {-15, 11, -6})
local deflect = pose({.045, -.24, -.11, -10, 28, -6}, {57, -15, -13, -.09, .16, -.125},
    {55, -14, 23, .074, .11, .05}, rear, lead, {9, -25, 5}, {-14, -28, 9})
local headHit = pose({-.105, -.24, .21, 15, -20, 9}, {40, 12, -25, .10, .065, .14},
    {43, -16, 23, -.08, .065, .14}, rear, lead, {-25, 18, -8}, {-12, 27, -11})
local gutHit = pose({.10, -.45, .15, -21, 18, -9}, {42, 13, -18, .02, -.06, .03},
    {43, -14, 18, -.02, -.06, .03}, rear, lead, {20, -17, 6}, {-13, -30, 9})
local salute = pose({.035, -.10, -.04, -2, -18, 3}, {82, 3, -30, .04, .13, -.09},
    leftGuard, rear, lead, {3, 17, -2}, {-16, 29, -7})
local bow = pose({0, -.35, -.12, -29, 0, 0}, {35, 14, -17, -.045, .05, .10},
    {35, -14, 18, .045, .05, .10}, rear, lead, {26, 0, 0}, {-18, 0, 0})
local raised = pose({-.008, -.10, -.055, -2, 8, 0}, {78, 8, -37, .10, .14, -.12},
    {76, -10, 36, -.10, .14, -.12}, rear, lead, {3, -8, 0}, {-19, -16, 8})

-- Kiln Knuckle snaps the shorter left wrap forward without shifting either boot.
local kilnDraw = pose({-.04, -.24, .065, -9, 16, 7}, {51, 16, -20, -.04, .13, .09},
    {31, -4, 22, -.065, .06, .17}, rear, lead, {11, -16, -3}, {-7, -13, 5})
local kilnHit = pose({-.065, -.18, -.16, -12, -23, 6}, {55, 18, -21, -.05, .14, .08},
    {52, -22, 15, .11, .065, -.16}, rear, lead, {13, 22, -3}, {-5, 26, -8})
local kilnFold = pose({-.025, -.205, -.04, -12, -15, 5}, rightGuard,
    {48, -18, 19, .075, .08, -.04}, rear, lead, {13, 15, -3}, {-5, 18, 3})

-- Sootstep balances on the left boot. The right toe stays below the waist.
local sootLoad = pose({-.19, -.25, .042, -6, -15, 12}, {47, 19, -24, -.035, .105, .07}, leftGuard,
    {26, -8, 2, .09, .015, -.09, .27}, lead, {7, 12, -7}, {-9, 25, 9})
local sootHit = pose({-.16, -.18, -.23, 2, 8, 10}, {55, 17, -23, -.045, .125, .03},
    {57, -19, 22, .08, .115, .015}, {43, 15, 2, -.06, .05, -.32, .49}, lead,
    {1, -7, -6}, {4, -18, 5})
local sootFold = pose({-.18, -.235, -.11, -5, -2, 11}, {49, 18, -23, -.035, .11, .07}, leftGuard,
    {29, -6, 2, .045, .03, -.09, .32}, lead, {6, 0, -6}, {-3, 7, 7})
local sootSettle = pose({-.065, -.22, .02, -10, -10, 7}, rightGuard, leftGuard,
    {9, -21, 1, .125, .015, .11, .072}, lead, {12, 10, -4}, {-5, 14, 6})

-- The high right glove reads before Obsidian Drop lands one close downward hit.
local obsidianBrace = pose({.046, -.29, .10, -10, -8, -3}, {37, 8, -12, .025, .12, .11},
    {55, -19, 20, .085, .11, .045}, rear, lead, {10, 8, 2}, {-10, 12, 7})
local obsidianRaise = pose({.07, -.12, .09, -4, -18, -5}, {133, 10, 10, .10, .10, .09},
    {58, -19, 23, .085, .12, .06}, rear, lead, {3, 16, 3}, {-7, 21, 8})
local obsidianDrive = pose({.055, -.30, -.035, -15, 2, -6}, {78, 17, -13, -.075, .04, -.125},
    {64, -20, 27, .08, .135, .075}, rear, lead, {15, -2, 2}, {-12, -6, 3})
local obsidianHit = pose({.04, -.355, -.275, -24, 22, -3}, {49, 20, -21, -.145, -.035, -.255},
    {58, -25, 31, .08, .135, .075}, rear, lead, {18, -19, 2}, {-12, -29, 8})
local obsidianCarry = pose({.03, -.395, -.195, -23, 22, -1}, {37, 22, -21, -.125, -.055, -.16},
    {56, -19, 25, .08, .11, .08}, rear, lead, {20, -21, 0}, {-9, -27, 4})
local obsidianRecover = pose({.031, -.28, -.07, -14, -2, -1}, {40, 15, -18, -.035, .06, .04},
    leftGuard, rear, lead, {14, 2, 0}, {-8, 4, 4})

-- Ashline Turn opens with the left wrap, then brings the rounded tail around from behind.
local ashlineGather = pose({-.075, -.30, .08, -10, 23, 8}, {54, 19, -21, -.045, .125, .10},
    {36, -6, 25, -.07, .08, .16}, rear, lead, {11, -20, -5}, {-8, -32, -9})
local ashlinePalm = pose({-.055, -.20, -.205, -10, -25, 5}, {56, 21, -24, -.04, .14, .08},
    {60, -22, 9, .115, .09, -.20}, rear, lead, {12, 22, -4}, {-8, 32, -5})
local ashlineCoil = pose({-.045, -.245, -.105, -6, -11, 7}, {63, 14, -24, -.065, .13, .07},
    {49, -19, 22, .083, .12, .03}, rear, lead, {7, 10, -5}, {-9, 64, -19})
local ashlinePass = pose({.035, -.235, -.14, -5, 11, -3}, {59, 13, -27, -.015, .14, .105},
    {48, -17, 24, .06, .10, .065}, rear, lead, {7, -10, 2}, {1, 114, -11})
local ashlineTail = pose({.03, -.135, -.245, -4, 24, -3}, {63, 15, -23, -.045, .125, .085},
    {47, -18, 24, .055, .09, .08}, rear, lead, {7, -21, 2}, {18, 149, 4})
local ashlineCarry = pose({-.052, -.23, -.14, -9, 32, 5}, {58, 14, -26, -.015, .11, .12},
    {52, -17, 24, .05, .09, .08}, rear, lead, {10, -29, -3}, {12, 199, 10})
local ashlineRecover = pose({-.035, -.27, -.015, -11, 14, 5}, rightGuard, leftGuard,
    rear, lead, {12, -13, -3}, {-11, 290, 8})

local breathTimes = table.freeze({.58, .78, .98})
local contact = {jab = .164, cross = .232, body = .276, heavy = .437, tailRake = .36,
    kilnKnuckle = .17, sootstep = .25, obsidianDrop = .62, ashlineTurn = table.freeze({.32, .66}),
    volcanicBreath = breathTimes, ashenSnap = .25, cinderHeel = .49}
local clips = {
    stance = {{0, ready}, {.47, breathe}, {.94, ready}},
    advance = {{0, ready}, {.16, stepLead}, {.32, breathe}, {.49, stepRear}, {.65, ready}},
    retreat = {{0, ready}, {.18, backRear}, {.35, ready}, {.52, backLead}, {.69, ready}},
    sidestep = {{0, ready}, {.108, slip}, {.24, brake}, {.47, ready}},
    jab = {{0, ready}, {.074, jabLoad}, {contact.jab, jabHit}, {.235, jabHit}, {.43, ready}},
    kilnKnuckle = {{0, ready}, {.072, kilnDraw}, {contact.kilnKnuckle, kilnHit}, {.278, kilnFold}, {.42, ready}},
    sootstep = {{0, ready}, {.111, sootLoad}, {contact.sootstep, sootHit}, {.356, sootFold}, {.447, sootSettle}, {.54, ready}},
    obsidianDrop = {{0, ready}, {.158, obsidianBrace}, {.32, obsidianRaise}, {.417, obsidianRaise}, {.525, obsidianDrive},
        {contact.obsidianDrop, obsidianHit}, {.682, obsidianHit}, {.790, obsidianCarry}, {1.014, obsidianRecover}, {1.22, ready}},
    ashlineTurn = {{0, ready}, {.15, ashlineGather}, {contact.ashlineTurn[1], ashlinePalm}, {.452, ashlineCoil}, {.553, ashlinePass},
        {contact.ashlineTurn[2], ashlineTail}, {.758, ashlineCarry}, {.965, ashlineRecover}, {1.18, ready}},
    cross = {{0, ready}, {.105, crossLoad}, {contact.cross, crossHit}, {.318, crossHit}, {.52, ready}},
    body = {{0, ready}, {.135, bodyLoad}, {contact.body, bodyHit}, {.392, breathe}, {.58, ready}},
    heavy = {{0, ready}, {.185, heavyLoad}, {.29, heavyLoad}, {contact.heavy, heavyHit}, {.55, heavyEase}, {.82, ready}},
    tailRake = {{0, ready}, {.15, tailDraw}, {.238, tailPass}, {contact.tailRake, tailHit},
        {.45, tailFollow}, {.59, tailReset}, {.75, ready}},
    ashenSnap = {{0, ready}, {.10, snapLoad}, {contact.ashenSnap, snapHit}, {.355, snapFold}, {.59, ready}},
    cinderHeel = {{0, ready}, {.13, heelLoad}, {.24, heelLift}, {.362, heelChamber}, {contact.cinderHeel, heelHit},
        {.555, heelFollow}, {.68, heelWithdraw}, {.94, ready}},
    volcanicBreath = {{0, ready}, {.21, inhale}, {.39, inhale}, {breathTimes[1], flameLeft},
        {breathTimes[2], flameCenter}, {breathTimes[3], flameRight}, {1.12, breathEase}, {1.34, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.081, recoil}, {.165, recoil}, {.286, cover}},
    parry = {{0, cover}, {.089, deflect}, {.180, deflect}, {.34, ready}},
    hitHead = {{0, ready}, {.077, headHit}, {.18, headHit}, {.35, ready}},
    hitBody = {{0, ready}, {.091, gutHit}, {.192, gutHit}, {.37, ready}},
    stagger = {{0, headHit}, {.18, brake}, {.36, recoil}, {.57, ready}},
    intro = {{0, ready}, {.88, breathe}, {1.58, salute}, {2.20, salute}, {2.90, bow}, {3.45, ready},
        {4.17, inhale}, {4.54, flameLeft}, {4.84, flameCenter}, {5.11, flameRight}, {5.68, ready},
        {6.17, slip}, {6.59, brake}, {7.52, ready}, {8.74, breathe}, {10, ready}},
    win = {{0, ready}, {.29, raised}, {.91, raised}, {1.24, bow}, {1.54, bow}, {1.99, ready}},
}

local rightFist, leftFist = v(1.18, 1.88, -.77), v(-1.18, 1.88, -.77)
local mouth, tailTip = v(0, 3.58, -1.38), v(.18, .94, 2.65)
-- The rounded muzzle's leading surface and the center line of the flat heel.
local muzzle = snapHit.RootJoint * snapHit.Neck
local muzzleRadius = v(.4405, .2025, .202)
local front = muzzle:VectorToObjectSpace(-Vector3.zAxis) * muzzleRadius
local snapPoint = muzzle:PointToWorldSpace(v(0, 3.675 - rootHeight, -1.193) + front * muzzleRadius / front.Magnitude)
-- Fitted, unposed native shell surfaces in the mount frame.
local function mountStrike(key, joint, rest)
    return (key.RootJoint * key[joint]):PointToWorldSpace(rest)
end

local kilnPad = v(-1.431383207, -.257327235, -.749164418)
local sootPad = v(.519515317, -2.043461079, -.869791425)
local obsidianPad = v(1.447533980, -.275430261, -.681451062)
local ashlinePalmPad = v(-1.440241997, -.355938200, -.642941515)
local ashlineTailPad = v(.224803671, -1.230776676, 2.679186397)
local hits = {
    kilnKnuckle = {mountStrike(kilnHit, "Left Shoulder", kilnPad)},
    sootstep = {mountStrike(sootHit, "Right Hip", sootPad)},
    obsidianDrop = {mountStrike(obsidianHit, "Right Shoulder", obsidianPad)},
    ashlineTurn = {
        mountStrike(ashlinePalm, "Left Shoulder", ashlinePalmPad),
        mountStrike(ashlineTail, "TailJoint", ashlineTailPad),
    },
    jab = {{jabHit, "Right Shoulder", rightFist}}, cross = {{crossHit, "Left Shoulder", leftFist}},
    body = {{bodyHit, "Right Shoulder", rightFist}}, heavy = {{heavyHit, "Left Shoulder", leftFist}},
    tailRake = {{tailHit, "TailJoint", tailTip}}, volcanicBreath = {},
    ashenSnap = {snapPoint}, cinderHeel = {{heelHit, "Right Hip", v(.50, .012, .135)}},
}
local samples = {}
for index, key in {flameLeft, flameCenter, flameRight} do
    local muzzle = key.RootJoint * key.Neck
    local normal = muzzle.LookVector
    local direction = v(normal.X, 0, normal.Z).Unit
    samples[index] = table.freeze({age = breathTimes[index], direction = direction,
        origin = muzzle:PointToWorldSpace(mouth - v(0, rootHeight, 0))})
    hits.volcanicBreath[index] = {key, "Neck", mouth}
end
local skills = {
    kilnKnuckle = table.freeze({damage = 12, radius = .44}),
    sootstep = table.freeze({damage = 15, radius = .47, foot = true}),
    tailRake = table.freeze({damage = 21, radius = .58, shove = 1.0}),
    ashenSnap = table.freeze({damage = 14, radius = .40}),
    cinderHeel = table.freeze({damage = 22, radius = .46}),
    volcanicBreath = table.freeze({warningAt = .21, radius = 4.65, halfAngle = math.rad(17),
        damage = 22, burnDamage = 3, shove = .78, samples = table.freeze(samples)}),
}
local travel = {tailRake = table.freeze({axis = "forward", distance = .24, startsAt = .18, endsAt = .34})}

local standard = rig.finish(clips, contact, hits, skills, travel, {"sidestep"}, {
    ashenSnap = true, kilnKnuckle = true, obsidianDrop = true, ashlineTurn = true,
})
local poses = table.clone(standard)
local leftHip = "Left Hip"
local plantedLeft = ready.RootJoint * ready[leftHip]

function poses.sample(action, age, direction)
    local offsets = standard.sample(action, age, direction)
    if action == "cinderHeel" or action == "sootstep" then
        offsets[leftHip] = offsets.RootJoint:ToObjectSpace(plantedLeft)
    end
    return offsets
end

poses.UltimateSkill = table.freeze({
    obsidianDrop = table.freeze({damage = 32, radius = .52}),
    ashlineTurn = table.freeze({damage = table.freeze({12, 22}), radius = table.freeze({.45, .53})}),
})
return table.freeze(poses)
