-- Original Sugar Glider choreography. The sleeve membranes follow the arms,
-- so each swoop has a folded setup, a broad silhouette, and a soft landing.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {
        v(side * .48, 0, -.43), v(side * .48, .038, -.72),
        v(side * .27, .03, -.48), v(side * .69, .03, -.48), v(side * .48, .045, -.10),
    }
end

local pivots = {
    Neck = v(0, 3.13, -.045),
    ["Right Shoulder"] = v(.77, 2.99, .025), ["Left Shoulder"] = v(-.77, 2.99, .025),
    ["Right Hip"] = v(.43, 1.51, .02), ["Left Hip"] = v(-.43, 1.51, .02),
    TailJoint = v(0, 1.64, .49),
}
local rightSole, leftSole = sole(1), sole(-1)
local rig = Choreography.new(2.60, pivots, rightSole, leftSole)
local pose = rig.pose
local mountedHeight = 2.132
local attackPose = Choreography.new(mountedHeight, pivots, rightSole, leftSole).pose

local rightGuard, leftGuard = {44, 14, -15, -.035, .114, .04}, {55, -16, 16, .035, .135, .065}
local rightFoot, leftFoot = {2, -9, 0, .07, 0, -.16, 0}, {4, 14, 0, -.055, 0, .14, 0}
local watch, rudder = {8, -11, 3}, {2, 14, -7}
local ready = pose({-.025, -.17, -.035, -9, 11, -3}, rightGuard, leftGuard, rightFoot, leftFoot, watch, rudder)
local settle = pose({-.035, -.125, -.04, -7, 9, -2}, {49, 13, -13, -.03, .135, .05}, leftGuard,
    rightFoot, leftFoot, {7, -9, 2}, {7, 9, -5})

local glideStepRight = pose({.085, -.14, -.085, -10, 14, -11}, {33, 11, 16, .03, .15, .10},
    leftGuard, {13, -10, 0, .13, 0, -.34, .16}, leftFoot, {9, -11, 9}, {9, -26, 9})
local glideStepLeft = pose({-.095, -.13, -.08, -10, 7, 11}, rightGuard, {36, -11, -17, -.01, .12, .11},
    rightFoot, {11, 9, 0, -.13, 0, -.34, .16}, {8, -6, -8}, {8, 27, -13})
local retreatRight = pose({.045, -.22, .105, 3, 18, -8}, {38, 22, 13, .04, .14, .105},
    leftGuard, {-8, -10, -3, .10, .06, .33, .16}, leftFoot, {-2, -14, 6}, {-9, -16, 5})
local retreatLeft = pose({-.085, -.22, .09, 4, 7, 8}, rightGuard, {40, -19, -14, -.04, .14, .09},
    rightFoot, {-9, 8, 3, -.12, .055, .32, .16}, {-1, -5, -6}, {-12, 25, -11})
local sway = pose({.18, -.29, .045, -13, -16, -19}, {23, 15, 23, .075, .13, .14},
    {52, -22, 12, .035, .14, .10}, {8, -23, 0, .16, 0, .18, .045}, leftFoot,
    {12, 15, 13}, {5, 34, -17})
local checkStep = pose({.135, -.21, .025, -11, 13, -12}, {36, 16, 25, .055, .14, .12}, leftGuard,
    {4, -21, -1, .17, 0, .14, 0}, {9, 15, 1, -.09, 0, -.09, .055}, {9, -10, 8}, {7, -8, -10})

local jabGather = pose({.065, -.23, .08, -12, -24, -6}, {34, 7, -11, .038, .105, .20}, leftGuard,
    rightFoot, leftFoot, {9, 19, 4}, {-5, 27, 6})
local jabHit = pose({.035, -.13, -.20, -14, 25, -3}, {75, 19, -7, -.07, .12, -.28}, leftGuard,
    rightFoot, leftFoot, {10, -22, 3}, {10, -28, 6})
local crossGather = pose({-.10, -.23, .06, -8, 28, 6}, rightGuard, {37, -7, 13, -.03, .11, .24},
    rightFoot, leftFoot, {8, -21, -4}, {-6, -26, -8})
local crossHit = pose({-.075, -.12, -.27, -11, -29, 6}, rightGuard, {79, -15, 8, .06, .115, -.28},
    rightFoot, {4, 20, 0, -.095, 0, .19, 0}, {10, 25, -4}, {9, 30, -10})
local bodyGather = pose({.085, -.32, .04, -16, -14, -8}, {25, 3, -10, .03, -.07, .16}, leftGuard,
    rightFoot, leftFoot, {15, 12, 5}, {-9, 30, 8})
local bodyHit = pose({.10, -.38, -.28, -17, 24, -5}, {62, 17, -4, -.11, -.055, -.30}, leftGuard,
    rightFoot, {2, 8, 0, -.11, 0, .24, 0}, {13, -18, 4}, {11, -22, 8})
local heavyGather = pose({-.15, -.30, .12, -9, 44, 12}, {40, 15, 13, .03, .14, .07},
    {27, 10, -43, -.13, .11, .22}, rightFoot, {7, 25, 0, -.13, 0, .18, 0},
    {10, -32, -9}, {-4, -44, -12})
local heavyHit = pose({-.055, -.17, -.39, -16, -40, 9}, {44, 12, -12, .03, .14, .05},
    {71, -23, 13, .15, .10, -.35}, rightFoot, leftFoot, {12, 33, -7}, {13, 41, -16})
local heavyFollow = pose({-.10, -.24, -.23, -17, -49, 10}, rightGuard,
    {57, -29, 24, .16, .11, -.17}, rightFoot, leftFoot, {13, 41, -7}, {15, 44, -14})

local slip = pose({.14, -.28, .065, -16, -18, -16}, {18, 21, 53, .14, .16, .11},
    {55, -21, 15, .045, .13, .06}, {10, -18, 0, .15, 0, -.10, .09}, leftFoot,
    {12, 18, 12}, {4, 32, -14})
local sweepGather = pose({.105, -.29, -.045, -14, -9, -13}, {48, 28, 49, .17, .20, .06}, leftGuard,
    {9, -22, 0, .16, 0, .075, 0}, {7, 8, 0, -.08, 0, -.17, .04}, {12, 9, 9}, {9, 26, -15})
local sweepHit = pose({-.12, -.25, -.29, -14, 43, -7}, {75, 27, -7, -.145, .135, -.32},
    {59, -19, 17, .035, .15, .10}, {6, -18, 0, .13, 0, .15, 0}, leftFoot,
    {10, -31, 5}, {12, -35, -8})
local sweepFollow = pose({-.03, -.285, -.18, -15, 54, -5}, {64, 32, -20, -.09, .13, -.17},
    leftGuard, rightFoot, leftFoot, {10, -42, 2}, {8, -41, -9})

local boughGather = attackPose({-.09, -.24, .07, -4, 19, 8}, rightGuard,
    {36, -7, 21, -.05, .15, .12}, rightFoot, leftFoot, {9, -19, -3}, {-3, -25, 8})
local boughHit = attackPose({-.045, -.25, -.21, -13, -21, 5}, {47, 16, -19, -.04, .13, .10},
    {66, -9, 12, .08, .10, -.19}, rightFoot, leftFoot, {10, 19, -4}, {12, 21, -7})
local boughRetract = attackPose({-.085, -.25, -.065, -9, -5, 5}, rightGuard,
    {45, -9, 18, .045, .12, -.09}, rightFoot, leftFoot, {8, 3, -2}, {8, 6, -6})
local sailGather = attackPose({.15, -.26, .10, -5, -32, -8}, {11, 17, 69, .12, .18, .14},
    {56, -21, 26, .05, .125, .10}, rightFoot, leftFoot, {9, 27, 7}, {-7, 37, -14})
local sailOpen = attackPose({.12, -.23, .025, -8, -22, -12}, {34, 12, 82, .11, .19, .11},
    {53, -13, -21, .035, .125, .06}, rightFoot, leftFoot, {6, 19, 8}, {5, 28, -17})
local sailHit = attackPose({-.075, -.26, -.27, -15, 35, -8}, {75, 18, -19, -.03, .08, -.49},
    {53, -13, 24, .03, .12, .085}, rightFoot, leftFoot, {10, -30, 6}, {12, -39, -10})
local sailFollow = attackPose({-.115, -.25, -.19, -17, 48, -7}, {64, 23, -35, -.11, .10, -.21},
    leftGuard, rightFoot, leftFoot, {10, -39, 5}, {14, -47, -9})

local folded = pose({-.035, -.38, .11, -17, 7, -3}, {28, 15, -17, -.035, .035, .18},
    {30, -17, 15, .03, .06, .16}, {9, -12, 0, .075, 0, .18, 0}, leftFoot,
    {13, -5, 3}, {-13, -11, -3})
local wingLaunch = pose({-.02, .18, .01, -5, -9, 11}, {23, 2, 65, .05, .13, .045},
    {26, -4, -57, -.04, .08, .09}, {-10, -8, -2, .07, .035, .20, .37},
    {22, 12, 6, -.08, .12, -.08, .70}, {1, 7, -7}, {12, 19, -11})
local swoop = pose({.065, .42, -.22, -22, -12, 9}, {30, 2, 83, .09, .15, .055},
    {24, -4, -74, -.07, .13, .10}, {-14, -12, -3, .08, .04, .29, .36},
    {-9, 8, 3, -.075, .085, .14, .45}, {9, 11, -7}, {26, 21, -13})
local funnelPull = pose({.005, .13, -.235, -25, 12, -8}, {45, 10, 70, .10, .09, -.12},
    {52, -8, -66, -.09, .15, -.13}, {-9, -3, 0, .07, .04, .15, .20},
    {18, 12, 0, -.065, .025, .015, .28}, {12, -10, 6}, {21, -26, 11})
local catchLanding = pose({0, -.36, .045, -17, -4, 2}, {63, 15, -15, -.04, .075, -.055},
    {58, -18, 15, .045, .10, -.055}, {5, -12, -2, .135, 0, -.045, 0},
    {9, 14, 2, -.12, 0, -.035, 0}, {10, 3, -1}, {-7, 10, -2})
local funnelBurst = pose({.015, -.06, -.205, -12, 4, 2}, {50, 17, 79, .08, .20, -.10},
    {49, -17, -79, -.10, .20, -.10}, {7, -15, -2, .14, 0, -.05, 0},
    {8, 14, 3, -.12, 0, -.035, 0}, {1, -3, -1}, {16, -8, -2})
local gustFalloff = pose({.025, -.17, -.06, -8, 3, 1}, {46, 18, 34, .04, .14, .06},
    {46, -18, -30, -.04, .15, .04}, rightFoot, leftFoot, {5, -2, -1}, {9, 6, 0})

local cover = pose({-.025, -.24, .075, -12, 1, 1}, {70, 19, -17, -.09, .16, .015},
    {72, -20, 17, .09, .16, .015}, rightFoot, leftFoot, {11, 0, 0}, {-9, 0, -1})
local recoil = pose({-.055, -.27, .16, 9, -6, 6}, {66, 23, -21, -.07, .13, .09},
    {67, -22, 21, .07, .14, .09}, rightFoot, leftFoot, {-8, 5, -4}, {11, 8, -6})
local parryBrush = pose({.09, -.23, -.10, -9, 36, -10}, {57, -20, -18, -.035, .23, -.14},
    {54, -17, 11, .035, .11, .08}, rightFoot, leftFoot, {10, -29, 6}, {3, -30, 9})
local headHit = pose({-.11, -.16, .22, 18, -18, 9}, {39, 17, -21, .035, .12, .15},
    {43, -12, 22, -.04, .11, .13}, rightFoot, leftFoot, {-30, 13, -8}, {14, 25, -9})
local bodyHitRecoil = pose({.11, -.31, .13, -22, 18, -10}, {51, 21, -16, .015, .025, -.06},
    {52, -15, 16, .02, .020, -.065}, rightFoot, leftFoot, {18, -13, 7}, {-16, -23, 7})
local stumble = pose({-.18, -.29, .24, 15, -27, 13}, {28, 14, 6, .075, .09, .17},
    {37, -14, 16, -.06, .095, .16}, rightFoot, {-5, 16, 0, -.13, 0, .32, 0},
    {-22, 21, -9}, {12, 36, -12})

local greeting = pose({-.04, -.10, -.045, -8, -8, 5}, {83, 6, 32, .045, .145, -.04},
    leftGuard, rightFoot, leftFoot, {6, 8, -3}, {10, 17, -3})
local saluteBow = pose({0, -.20, -.08, -26, 0, 0}, {34, 13, 18, .04, .08, .04},
    {34, -13, -18, -.04, .08, .04}, rightFoot, leftFoot, {3, 0, 0}, {-10, 0, 0})
local wingShow = pose({.015, -.10, -.01, -3, 5, 2}, {13, 13, 72, .07, .13, .07},
    {13, -16, -72, -.06, .13, .07}, rightFoot, leftFoot, {8, -4, -2}, {13, 6, -5})

local gustHits = table.freeze({.51, .83})
local contact = {jab = .162, cross = .219, body = .257, heavy = .428, canopySlip = .28, gustVortex = gustHits,
    boughSnap = .24, sailSwipe = .50}
local clips = {
    stance = {{0, ready}, {.48, settle}, {1.03, ready}},
    advance = {{0, ready}, {.14, glideStepRight}, {.28, ready}, {.423, glideStepLeft}, {.56, ready}},
    retreat = {{0, ready}, {.158, retreatRight}, {.316, ready}, {.474, retreatLeft}, {.632, ready}},
    sidestep = {{0, ready}, {.094, sway}, {.235, checkStep}, {.45, ready}},
    jab = {{0, ready}, {.074, jabGather}, {contact.jab, jabHit}, {.27, settle}, {.416, ready}},
    cross = {{0, ready}, {.095, crossGather}, {contact.cross, crossHit}, {.339, settle}, {.50, ready}},
    body = {{0, ready}, {.124, bodyGather}, {contact.body, bodyHit}, {.373, bodyGather}, {.54, ready}},
    heavy = {{0, ready}, {.191, heavyGather}, {.30, heavyGather}, {contact.heavy, heavyHit},
        {.531, heavyFollow}, {.80, ready}},
    canopySlip = {{0, ready}, {.11, slip}, {.21, sweepGather}, {contact.canopySlip, sweepHit},
        {.39, sweepFollow}, {.52, gustFalloff}, {.65, ready}},
    boughSnap = {{0, ready}, {.10, boughGather}, {contact.boughSnap, boughHit}, {.36, boughRetract}, {.60, ready}},
    sailSwipe = {{0, ready}, {.17, sailGather}, {.31, sailOpen}, {.37, sailOpen}, {contact.sailSwipe, sailHit},
        {.63, sailFollow}, {.78, gustFalloff}, {.94, ready}},
    gustVortex = {{0, ready}, {.15, folded}, {.242, wingLaunch}, {.382, swoop}, {gustHits[1], funnelPull},
        {.666, catchLanding}, {.751, catchLanding}, {gustHits[2], funnelBurst},
        {.988, gustFalloff}, {1.21, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.07, recoil}, {.151, recoil}, {.28, cover}},
    parry = {{0, cover}, {.083, parryBrush}, {.168, parryBrush}, {.234, cover}, {.34, ready}},
    hitHead = {{0, ready}, {.078, headHit}, {.18, headHit}, {.34, ready}},
    hitBody = {{0, ready}, {.09, bodyHitRecoil}, {.203, bodyHitRecoil}, {.36, ready}},
    stagger = {{0, headHit}, {.13, stumble}, {.357, cover}, {.56, ready}},
    intro = {{0, ready}, {.81, settle}, {1.92, ready}, {2.58, greeting}, {2.96, greeting}, {3.60, saluteBow},
        {4.21, ready}, {5.32, settle}, {5.95, folded}, {6.54, wingShow}, {6.98, wingShow},
        {7.57, ready}, {8.47, settle}, {10, ready}},
    win = {{0, ready}, {.23, catchLanding}, {.55, wingShow}, {.86, wingShow}, {1.24, saluteBow},
        {1.48, saluteBow}, {1.92, ready}},
}

local rightPalm, leftPalm = v(1.04, 1.93, -.57), v(-1.04, 1.93, -.57)
local gustCenter = v(0, -2.60, -1.45)
local function mountedContact(key, joint, surface)
    return (key.RootJoint * key[joint]):PointToWorldSpace(surface - v(0, mountedHeight, 0))
end
local hits = {
    jab = {{jabHit, "Right Shoulder", rightPalm}},
    cross = {{crossHit, "Left Shoulder", leftPalm}},
    body = {{bodyHit, "Right Shoulder", rightPalm}},
    heavy = {{heavyHit, "Left Shoulder", leftPalm}},
    canopySlip = {{sweepHit, "Right Shoulder", rightPalm}},
    boughSnap = {mountedContact(boughHit, "Left Shoulder", v(-1.198955, 1.859494, -.503159))},
    sailSwipe = {mountedContact(sailHit, "Right Shoulder", v(1.235829, 1.889947, -.483435))},
    gustVortex = {gustCenter, gustCenter},
}
local skills = {
    canopySlip = table.freeze({damage = 18, radius = .49, shove = .48}),
    gustVortex = table.freeze({damage = table.freeze({0, 25}), radius = 3.0,
        shove = table.freeze({-1.28, 1.62}), center = gustCenter, warningAt = .24}),
}
local travel = {
    canopySlip = table.freeze({distance = .78, startsAt = .10, endsAt = .24, axis = "lateral"}),
    gustVortex = table.freeze({distance = .90, startsAt = .15, endsAt = .42, axis = "forward"}),
}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep", "canopySlip"}, {boughSnap = true, sailSwipe = true})
