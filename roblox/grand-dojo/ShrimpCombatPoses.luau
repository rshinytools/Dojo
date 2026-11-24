-- Pistol Shrimp leads with a small testing claw and braces the large snap claw for the release.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {
        v(side * .45, 0, -.37), v(side * .45, .04, -.66),
        v(side * .22, .05, -.45), v(side * .68, .05, -.45), v(side * .45, .07, -.12),
    }
end

local rig = Choreography.new(2.60, {
    Neck = v(0, 3.11, -.04),
    ["Right Shoulder"] = v(.76, 2.91, .01), ["Left Shoulder"] = v(-.76, 2.91, .01),
    ["Right Hip"] = v(.42, 1.48, .035), ["Left Hip"] = v(-.42, 1.48, .035),
    TailJoint = v(0, 1.62, .48),
}, sole(1), sole(-1))
local pose = rig.pose

local snapGuard, leadGuard = {41, 13, -13, -.03, .10, .10}, {63, -18, 17, .065, .14, .025}
local rearFoot, leadFoot = {2, -16, -2, .10, 0, .23, 0}, {5, 10, 2, -.10, 0, -.22, 0}
local eyes, tail = {8, -16, -5}, {7, -17, -7}
local ready = pose({-.045, -.12, .045, -6, 17, 3}, snapGuard, leadGuard, rearFoot, leadFoot, eyes, tail)
local bob = pose({-.045, -.06, .018, -8, 12, 0}, {42, 13, -10, -.025, .11, .085},
    {61, -16, 17, .06, .12, .025}, rearFoot, leadFoot, {9, -13, -1}, {13, -13, 0})
local leadShuffle = pose({-.115, -.16, -.105, -10, 16, 8}, snapGuard, leadGuard,
    rearFoot, {10, 10, 0, -.13, 0, -.39, .12}, {15, -16, -6}, {12, -24, -10})
local rearShuffle = pose({.095, -.16, -.085, -11, 9, -7}, {43, 15, -19, -.01, .11, .10}, leadGuard,
    {12, -16, -4, .125, 0, -.28, .12}, leadFoot, {14, -8, 5}, {12, 12, 9})
local leadBack = pose({-.13, -.186, .16, 3, 20, 9}, snapGuard, leadGuard,
    rearFoot, {-7, 14, 0, -.14, 0, .33, .11}, {2, -19, -7}, {-2, -26, -11})
local rearBack = pose({.11, -.18, .15, 4, 9, -9}, snapGuard, leadGuard,
    {-7, -17, -2, .14, 0, .35, .105}, leadFoot, {1, -8, 7}, {-4, 18, 12})
local skip = pose({.16, -.29, .065, -13, 0, -13}, {32, 10, -21, .095, .09, .23},
    {64, -21, 22, .06, .11, .04}, {9, -23, -2, .20, 0, .18, .075}, leadFoot,
    {12, 1, 9}, {-5, 30, -15})
local skipPlant = pose({.113, -.20, .015, -9, 12, -7}, snapGuard, leadGuard,
    {4, -22, -3, .14, 0, .17, 0}, leadFoot, {10, -13, 4}, {7, 14, -9})

local jabLoad = pose({-.12, -.20, .061, -8, 24, 7}, snapGuard, {44, -7, 24, -.02, .085, .15},
    rearFoot, leadFoot, {10, -23, -6}, {8, -31, -12})
local jabHit = pose({-.045, -.089, -.26, -8, -24, 5}, snapGuard, {76, -19, 7, .1, .11, -.27},
    rearFoot, leadFoot, {9, 23, -3}, {17, 31, -3})
local crossLoad = pose({.115, -.21, .127, -2, -28, -9}, {31, 16, -20, .045, .075, .24}, leadGuard,
    rearFoot, leadFoot, {3, 23, 8}, {3, 33, 11})
local crossHit = pose({-.02, -.11, -.26, -9, 26, 0}, {55, 17, -8, -.12, .10, -.20}, leadGuard,
    rearFoot, leadFoot, {11, -24, -2}, {15, -35, 1})
local bodyLoad = pose({-.157, -.34, .11, -21, 24, 8}, snapGuard, {28, -16, 23, -.06, .04, .18},
    rearFoot, {9, 17, 1, -.125, 0, -.22, 0}, {22, -23, -4}, {12, -30, -4})
local bodyHit = pose({-.035, -.30, -.23, -18, -25, 4}, {38, 15, -18, .05, .08, .20},
    {58, -16, 10, .09, .03, -.23}, rearFoot, leadFoot, {17, 25, -2}, {21, 31, -5})
local heavyLoad = pose({.095, -.35, .20, -14, -37, -9}, {18, 9, -31, .14, .07, .17},
    {59, -18, 26, .02, .11, .08}, {11, -19, 1, .14, 0, .21, 0}, leadFoot, {19, 34, 7}, {-3, 45, 13})
local heavyHit = pose({.015, -.18, -.32, -13, 36, -6}, {54, 14, -4, -.055, .075, -.28},
    {43, -14, 29, .03, .05, .12}, rearFoot, leadFoot, {16, -34, 4}, {29, -42, 12})
local heavyRecoil = pose({-.09, -.28, -.08, -20, 31, 6}, {49, 6, -17, -.095, .03, -.10},
    leadGuard, rearFoot, leadFoot, {22, -29, -5}, {20, -36, -9})

local dashCollect = pose({.13, -.28, .11, -12, -27, -12}, {36, 12, -24, .065, .07, .18},
    {61, -18, 23, .045, .135, .085}, {9, -23, 0, .15, 0, .16, 0}, leadFoot, {14, 24, 9}, {4, 38, 13})
local dashSnap = pose({-.005, -.14, -.24, -15, 38, -2}, {61, 14, -2, -.045, .07, -.225},
    {38, -18, 36, .075, .10, .16}, rearFoot, {8, 14, 0, -.10, 0, -.29, 0}, {17, -34, 4}, {20, -46, 8})
local dashBrake = pose({-.05, -.31, -.085, -19, 25, 4}, {48, 13, -17, -.035, .07, -.13},
    leadGuard, rearFoot, leadFoot, {21, -25, -3}, {14, -30, -8})

local cannonPlant = pose({.085, -.36, .15, -14, -30, -6}, {25, 10, -33, .13, .02, .25},
    {51, -9, 25, .06, .085, .12}, {9, -28, 0, .16, 0, .20, 0}, {8, 24, 0, -.16, 0, -.23, 0},
    {17, 26, 8}, {-8, 43, 15})
local cannonCharge = pose({.04, -.47, .19, -15, -35, -3}, {28, 9, -25, .04, .07, .29},
    {50, -5, 31, .15, .11, .115}, {10, -29, 0, .19, 0, .22, 0}, {8, 25, 0, -.17, 0, -.25, 0},
    {18, 34, 5}, {-17, 46, 5})
local cannonFire = pose({.005, -.19, -.175, -12, 28, -5}, {62, 15, -3, -.065, .07, -.28},
    {49, -14, 30, .135, .13, .06}, {7, -26, 0, .18, 0, .23, 0}, {7, 23, 0, -.17, 0, -.22, 0},
    {16, -24, 5}, {30, -41, 12})
local cannonRecoil = pose({-.10, -.22, .22, 16, 32, 8}, {49, -3, -17, -.085, .15, .13},
    {54, -15, 31, .08, .15, .115}, {6, -25, 0, .18, 0, .26, 0}, {6, 23, 0, -.18, 0, -.21, 0},
    {-18, -30, -5}, {-22, -43, -10})
local cannonSettle = pose({-.025, -.31, .08, -16, 13, 3}, {40, 14, -19, -.04, .08, .13},
    {60, -15, 26, .09, .115, .09}, {7, -25, 0, .15, 0, .21, 0}, leadFoot,
    {19, -13, -1}, {18, -16, -1})

local cover = pose({-.028, -.25, .08, -7, 3, 0}, {68, 2, -18, -.18, .15, .02},
    {76, -13, 20, .13, .12, .02}, rearFoot, leadFoot, {12, -3, 1}, {8, -2, 0})
local ricochet = pose({-.06, -.30, .16, 9, -7, 9}, {63, 4, -18, -.13, .16, .055},
    {71, -13, 20, .11, .135, .085}, rearFoot, leadFoot, {-4, 5, -8}, {-3, 8, -11})
local openGuard = pose({.055, -.20, -.070, -11, 39, -8}, {61, -12, -31, -.075, .17, -.065},
    {66, -15, 21, .085, .115, .045}, rearFoot, leadFoot, {17, -35, 6}, {17, -45, 13})
local headHit = pose({.10, -.16, .20, 13, -18, -7}, {32, 12, -24, .11, .03, .195},
    {49, -17, 28, -.01, .04, .17}, rearFoot, leadFoot, {-25, 16, 6}, {-10, 27, 12})
local bodyHitPose = pose({-.10, -.41, .12, -24, 27, 6}, {33, 12, -15, .02, -.035, .025},
    {39, -14, 23, .065, -.025, .00}, rearFoot, leadFoot, {27, -23, -5}, {21, -37, -9})
local salute = pose({.015, -.071, -.035, -3, -8, -7}, {77, 9, -27, .07, .17, -.08},
    leadGuard, rearFoot, leadFoot, {7, 8, 4}, {19, 8, 10})
local bow = pose({-.01, -.30, -.075, -26, 5, 1}, {31, 12, -16, -.025, .07, .045},
    {33, -13, 25, .02, .055, .045}, rearFoot, leadFoot, {23, -6, -1}, {-12, -4, 1})
local victory = pose({.012, -.018, -.025, 0, 21, 5}, {84, 15, -34, .035, .17, -.17},
    {77, -20, 27, -.035, .14, -.04}, rearFoot, leadFoot, {3, -19, -2}, {25, -20, -9})

local contact = {jab = .155, cross = .215, body = .258, heavy = .403, clawDash = .285, cavitationCannon = .68}
local clips = {
    stance = {{0, ready}, {.39, bob}, {.83, ready}},
    advance = {{0, ready}, {.133, leadShuffle}, {.27, bob}, {.401, rearShuffle}, {.55, ready}},
    retreat = {{0, ready}, {.143, rearBack}, {.29, ready}, {.435, leadBack}, {.59, ready}},
    sidestep = {{0, ready}, {.09, skip}, {.232, skipPlant}, {.43, ready}},
    jab = {{0, ready}, {.066, jabLoad}, {contact.jab, jabHit}, {.245, bob}, {.39, ready}},
    cross = {{0, ready}, {.096, crossLoad}, {contact.cross, crossHit}, {.318, bob}, {.47, ready}},
    body = {{0, ready}, {.115, bodyLoad}, {contact.body, bodyHit}, {.397, bob}, {.55, ready}},
    heavy = {{0, ready}, {.175, heavyLoad}, {.29, heavyLoad}, {contact.heavy, heavyHit}, {.525, heavyRecoil}, {.79, ready}},
    clawDash = {{0, ready}, {.11, dashCollect}, {.175, dashCollect}, {contact.clawDash, dashSnap},
        {.41, dashBrake}, {.655, ready}},
    cavitationCannon = {{0, ready}, {.20, cannonPlant}, {.42, cannonCharge}, {.60, cannonCharge},
        {contact.cavitationCannon, cannonFire}, {.76, cannonRecoil}, {.94, cannonSettle}, {1.13, bob}, {1.36, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.081, ricochet}, {.156, ricochet}, {.27, cover}},
    parry = {{0, cover}, {.091, openGuard}, {.184, openGuard}, {.343, ready}},
    hitHead = {{0, ready}, {.078, headHit}, {.176, headHit}, {.33, ready}},
    hitBody = {{0, ready}, {.088, bodyHitPose}, {.185, bodyHitPose}, {.36, ready}},
    stagger = {{0, headHit}, {.154, rearBack}, {.35, ricochet}, {.56, ready}},
    intro = {{0, ready}, {.78, bob}, {1.66, salute}, {2.13, salute}, {2.64, bow}, {3.20, ready},
        {4.11, cannonPlant}, {4.63, cannonCharge}, {4.96, cannonSettle}, {5.51, ready}, {6.70, skip},
        {7.18, skipPlant}, {7.73, bob}, {8.41, ready}, {9.17, bob}, {10, ready}},
    win = {{0, ready}, {.25, salute}, {.54, victory}, {.912, victory}, {1.22, bow}, {1.56, bow}, {1.90, ready}},
}

local snapTip, leadTip = v(1.20, 1.94, -1.15), v(-1.03, 1.96, -.65)
local hits = {
    jab = {{jabHit, "Left Shoulder", leadTip}},
    cross = {{crossHit, "Right Shoulder", snapTip}},
    body = {{bodyHit, "Left Shoulder", leadTip}},
    heavy = {{heavyHit, "Right Shoulder", snapTip}},
    clawDash = {{dashSnap, "Right Shoulder", snapTip}},
    cavitationCannon = {{cannonFire, "Right Shoulder", snapTip}},
}
local skills = {
    clawDash = table.freeze({damage = 21, radius = .51, shove = .70}),
    cavitationCannon = table.freeze({warningAt = .21, flight = .53, damage = 26, shove = 3.25}),
}
local travel = {clawDash = table.freeze({axis = "forward", distance = 1.18, startsAt = .11, endsAt = .28})}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
