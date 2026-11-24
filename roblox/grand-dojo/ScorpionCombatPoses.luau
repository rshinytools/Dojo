-- Desert Scorpion stays low, leads with the pincers and uses the curled tail as a counterweight.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {
        v(side * .49, 0, -.44), v(side * .49, .04, -.72),
        v(side * .25, .06, -.50), v(side * .73, .05, -.50), v(side * .49, .07, -.13),
    }
end

local rig = Choreography.new(2.60, {
    Neck = v(0, 3.10, -.04),
    ["Right Shoulder"] = v(.81, 2.97, .01), ["Left Shoulder"] = v(-.81, 2.97, .01),
    ["Right Hip"] = v(.46, 1.53, .03), ["Left Hip"] = v(-.46, 1.53, .03),
    TailJoint = v(0, 1.80, .52),
}, sole(1), sole(-1))
local pose = rig.pose

local rightGuard, leftGuard = {44, 13, -20, .02, .13, .09}, {51, -19, 19, -.02, .11, .04}
local rearFoot, leadFoot = {3, -23, 1, .13, 0, .19, 0}, {5, 14, -1, -.14, 0, -.19, 0}
local gaze, tailUp = {13, 10, 0}, {12, 10, -6}
local ready = pose({.02, -.23, .04, -10, -11, 4}, rightGuard, leftGuard, rearFoot, leadFoot, gaze, tailUp)
local sift = pose({.035, -.18, .015, -12, -8, 2}, {46, 16, -23, .01, .12, .08},
    {54, -19, 18, -.02, .11, .02}, rearFoot, leadFoot, {15, 8, -1}, {17, 9, -4})
local reachLead = pose({-.105, -.245, -.11, -13, -16, 7}, rightGuard, {53, -16, 21, -.015, .12, .03},
    rearFoot, {9, 14, -1, -.15, 0, -.33, .13}, {14, 16, -4}, {10, 24, -9})
local reachRear = pose({.105, -.23, -.075, -11, -4, -4}, {48, 13, -19, .02, .13, .04},
    leftGuard, {10, -19, 0, .16, 0, -.27, .13}, leadFoot, {12, 4, 4}, {10, -12, 7})
local backLead = pose({-.09, -.26, .13, -4, -15, 7}, rightGuard, leftGuard,
    rearFoot, {-5, 12, -2, -.15, 0, .28, .10}, {7, 16, -4}, {5, 23, -9})
local backRear = pose({.115, -.27, .12, -5, -6, -5}, rightGuard, leftGuard,
    {-5, -22, 1, .18, 0, .37, .11}, leadFoot, {7, 5, 4}, {4, -14, 7})
local dodgeOut = pose({.24, -.34, .07, -16, -23, -17}, {32, 12, -31, .07, .045, .17}, leftGuard,
    {4, -28, 0, .25, 0, .16, .11}, leadFoot, {18, 22, 8}, {-2, 36, -21})
local dodgeLand = pose({.13, -.32, .01, -15, -7, -9}, rightGuard, leftGuard,
    {8, -20, -2, .16, 0, .14, 0}, leadFoot, {16, 7, 7}, {7, 17, -10})

local jabLoad = pose({.075, -.27, .105, -12, -25, -8}, {32, 4, -14, .05, .075, .23}, leftGuard,
    rearFoot, leadFoot, {15, 21, 5}, {9, 27, -3})
local jabPinch = pose({.005, -.11, -.22, -6, 26, 2}, {64, 17, -12, -.13, .16, -.19}, leftGuard,
    rearFoot, leadFoot, {9, -26, 0}, {19, -32, 4})
local crossLoad = pose({-.13, -.33, .11, -11, 23, 9}, rightGuard, {23, -10, 24, -.075, .06, .25},
    rearFoot, leadFoot, {13, -25, -6}, {9, -27, -8})
local crossCut = pose({-.025, -.21, -.22, -9, -25, 7}, rightGuard, {62, -15, 9, .09, .075, -.21},
    rearFoot, leadFoot, {10, 26, -5}, {13, 30, -8})
local scoopLoad = pose({.04, -.43, .135, -21, -23, -7}, {23, 7, -14, .06, .03, .23}, leftGuard,
    rearFoot, {11, 17, -2, -.15, 0, -.24, 0}, {25, 21, 3}, {13, 28, 12})
local scoopHit = pose({.035, -.36, -.24, -18, 17, 0}, {46, 14, -14, -.10, -.03, -.17}, leftGuard,
    rearFoot, {10, 16, -2, -.14, 0, -.24, 0}, {21, -17, 0}, {24, -20, 0})
local heavyLoad = pose({-.12, -.43, .195, -17, 39, 13}, {26, 14, -30, .18, -.025, .20},
    {24, -2, 34, -.15, .045, .28}, rearFoot, leadFoot, {19, -34, -8}, {-7, -47, -19})
local heavySweep = pose({.055, -.15, -.28, -11, -31, 3}, {52, 8, -29, .025, .075, .055},
    {68, -14, 6, .135, .02, -.20}, rearFoot, leadFoot, {16, 29, -3}, {25, 34, 11})
local heavyFollow = pose({.12, -.34, -.15, -21, -39, -5}, {38, 13, -25, .10, .10, .18},
    {53, -7, 4, .08, -.03, -.08}, rearFoot, leadFoot, {21, 34, 1}, {32, 49, 16})

local tailSlip = pose({.19, -.33, .07, -14, -25, -19}, {32, 17, -26, .08, .08, .20},
    {58, -22, 18, -.03, .10, .025}, {7, -23, -3, .27, 0, .15, .07}, leadFoot,
    {14, 22, 11}, {-13, 38, -23})
local tailSweep = pose({-.105, -.16, -.245, -10, 41, -3}, {66, 17, -6, -.11, .09, -.21},
    {41, -9, 33, -.09, .055, .145}, {3, -29, -1, .20, 0, .15, 0}, leadFoot,
    {9, -40, 5}, {18, -48, 13})
local tailReturn = pose({.05, -.32, -.105, -16, 23, -7}, {50, 17, -16, -.08, .03, -.045},
    leftGuard, rearFoot, leadFoot, {14, -22, 5}, {11, -28, 3})

local snareGather = pose({0, -.38, .13, -5, 2, 0}, {47, -13, -6, -.11, .14, .10},
    {47, 13, 6, .11, .14, .10}, {7, -25, 0, .17, 0, .16, 0}, {7, 25, 0, -.17, 0, -.105, 0},
    {7, -2, 0}, {-13, 0, 0})
local snareMarks = pose({.01, -.45, -.04, -12, -2, -2}, {24, 21, -33, .13, .015, -.06},
    {25, -20, 32, -.13, .02, -.065}, {7, -25, 0, .17, 0, .16, 0}, {7, 25, 0, -.17, 0, -.105, 0},
    {15, 2, 0}, {5, -5, -1})
local snareSnap = pose({0, -.37, -.18, -20, 0, 0}, {36, -2, -12, -.075, -.07, -.14},
    {36, 2, 12, .075, -.07, -.14}, {7, -25, 0, .17, 0, .16, 0}, {7, 25, 0, -.17, 0, -.105, 0},
    {24, 0, 0}, {34, 0, 0})

local cover = pose({0, -.31, .075, -13, 0, 0}, {69, 6, -16, -.15, .125, .045},
    {68, -8, 17, .15, .125, .045}, rearFoot, leadFoot, {17, 0, 0}, {11, -2, 1})
local deflect = pose({.04, -.255, -.12, -10, 28, -6}, {57, -4, -18, -.095, .17, -.11},
    {46, -15, 27, -.055, .14, .06}, rearFoot, leadFoot, {12, -28, 6}, {18, -32, 9})
local blockRecoil = pose({-.055, -.35, .165, 6, -9, 8}, {63, 10, -16, -.08, .14, .10},
    {58, -7, 15, .09, .14, .10}, rearFoot, leadFoot, {-9, 7, -7}, {-4, 9, -7})
local hitHigh = pose({-.12, -.24, .24, 13, -23, 8}, {39, 15, -24, .13, .055, .18},
    {44, -15, 23, -.11, .07, .19}, rearFoot, leadFoot, {-23, 21, -7}, {-10, 28, -13})
local hitLow = pose({.10, -.43, .17, -23, 18, -8}, {36, 12, -25, .07, -.03, .025},
    {36, -16, 24, -.065, -.03, .035}, rearFoot, leadFoot, {20, -14, 5}, {26, -27, 13})
local salute = pose({.04, -.16, -.04, -1, -18, 2}, {82, 1, -32, .03, .135, -.10},
    {49, -18, 24, -.03, .10, .04}, rearFoot, leadFoot, {2, 17, -1}, {22, 26, -4})
local bow = pose({.005, -.36, -.095, -29, 0, 0}, {31, 17, -14, -.045, .015, .06},
    {31, -17, 14, .045, .015, .06}, rearFoot, leadFoot, {26, 0, 0}, {-10, 0, 0})
local victory = pose({-.005, -.11, -.06, 0, 8, 0}, {78, 10, -41, .085, .16, -.14},
    {79, -12, 42, -.085, .16, -.14}, rearFoot, leadFoot, {5, -8, 0}, {21, 7, 0})

local contact = {jab = .16, cross = .23, body = .275, heavy = .43, tailFeint = .31, cinderSnare = .86}
local clips = {
    stance = {{0, ready}, {.46, sift}, {.92, ready}},
    advance = {{0, ready}, {.15, reachLead}, {.31, sift}, {.46, reachRear}, {.62, ready}},
    retreat = {{0, ready}, {.16, backRear}, {.32, ready}, {.48, backLead}, {.65, ready}},
    sidestep = {{0, ready}, {.105, dodgeOut}, {.24, dodgeLand}, {.47, ready}},
    jab = {{0, ready}, {.072, jabLoad}, {contact.jab, jabPinch}, {.22, jabPinch}, {.42, ready}},
    cross = {{0, ready}, {.105, crossLoad}, {contact.cross, crossCut}, {.30, crossCut}, {.51, ready}},
    body = {{0, ready}, {.136, scoopLoad}, {contact.body, scoopHit}, {.39, sift}, {.57, ready}},
    heavy = {{0, ready}, {.18, heavyLoad}, {.29, heavyLoad}, {contact.heavy, heavySweep}, {.54, heavyFollow}, {.81, ready}},
    tailFeint = {{0, ready}, {.11, tailSlip}, {.212, tailSlip}, {contact.tailFeint, tailSweep}, {.405, tailReturn}, {.67, ready}},
    cinderSnare = {{0, ready}, {.22, snareGather}, {.362, snareMarks}, {.69, snareMarks},
        {contact.cinderSnare, snareSnap}, {.97, snareSnap}, {1.16, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.079, blockRecoil}, {.153, blockRecoil}, {.28, cover}},
    parry = {{0, cover}, {.095, deflect}, {.183, deflect}, {.34, ready}},
    hitHead = {{0, ready}, {.076, hitHigh}, {.175, hitHigh}, {.34, ready}},
    hitBody = {{0, ready}, {.096, hitLow}, {.199, hitLow}, {.36, ready}},
    stagger = {{0, hitHigh}, {.17, dodgeLand}, {.34, blockRecoil}, {.56, ready}},
    intro = {{0, ready}, {.71, sift}, {1.52, salute}, {2.11, salute}, {2.77, bow}, {3.19, ready},
        {4.16, snareGather}, {4.78, snareMarks}, {5.22, ready}, {6.17, dodgeOut}, {6.58, dodgeLand},
        {7.5, ready}, {8.63, sift}, {10, ready}},
    win = {{0, ready}, {.31, victory}, {.92, victory}, {1.26, bow}, {1.53, bow}, {1.96, ready}},
}

local rightTip, leftTip = v(1.14, 1.96, -.97), v(-1.14, 1.96, -.97)
local vertices = table.freeze({v(-2.6, -2.6, -1.55), v(2.6, -2.6, -1.55), v(0, -2.6, -6.2)})
local hits = {
    jab = {{jabPinch, "Right Shoulder", rightTip}},
    cross = {{crossCut, "Left Shoulder", leftTip}},
    body = {{scoopHit, "Right Shoulder", rightTip}},
    heavy = {{heavySweep, "Left Shoulder", leftTip}},
    tailFeint = {{tailSweep, "Right Shoulder", rightTip}},
    cinderSnare = {v(0, -2.6, -3.1)},
}
local skills = {
    tailFeint = table.freeze({damage = 19, radius = .49, shove = .52}),
    cinderSnare = table.freeze({warningAt = .22, rootDuration = .72, vertices = vertices}),
}
local travel = {tailFeint = table.freeze({axis = "lateral", distance = .81, startsAt = .105, endsAt = .26})}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep", "tailFeint"})
