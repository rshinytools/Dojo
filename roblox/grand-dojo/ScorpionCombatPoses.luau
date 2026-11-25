-- Desert Scorpion stays low, leads with the pincers and uses the curled tail as a counterweight.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {
        v(side * .49, 0, -.44), v(side * .49, .04, -.72),
        v(side * .25, .06, -.50), v(side * .73, .05, -.50), v(side * .49, .07, -.13),
    }
end

local pivots = {
    Neck = v(0, 3.10, -.04),
    ["Right Shoulder"] = v(.81, 2.97, .01), ["Left Shoulder"] = v(-.81, 2.97, .01),
    ["Right Hip"] = v(.46, 1.53, .03), ["Left Hip"] = v(-.46, 1.53, .03),
    TailJoint = v(0, 1.80, .52),
}
local rightSole, leftSole = sole(1), sole(-1)
local rig = Choreography.new(2.60, pivots, rightSole, leftSole)
local mountedHeight = 2.132
local tacticPose = Choreography.new(mountedHeight, pivots, rightSole, leftSole).pose
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

-- Open both claws beside the jacket, then close them across the body line.
-- The lower right claw gives the single strike a clear contact surface.
local pincerLoad = tacticPose({.06, -.36, .075, -14, -11, -5}, {27, 9, -9, .20, .07, .16},
    {39, -7, 9, -.20, .10, .14}, rearFoot, leadFoot, {17, 9, 3}, {9, 18, -11})
local pincerClose = tacticPose({.035, -.28, -.235, -12, 13, -3}, {56, 20, -20, -.11, .04, -.17},
    {61, -26, 31, .10, .09, -.095}, rearFoot, leadFoot, {13, -12, 2}, {20, -14, 4})
local pincerFold = tacticPose({.04, -.30, -.08, -13, 3, -4}, {50, 18, -28, .03, .08, -.045},
    {58, -21, 27, -.035, .10, .065}, rearFoot, leadFoot, {13, -1, 2}, {16, -5, -3})

-- Let the tail travel around the right flank. Its rounded upper armor
-- presents a broad sideways surface while the claws stay behind the strike.
local lashLoad = tacticPose({-.08, -.34, .14, -11, -21, 6}, {44, 16, -29, .04, .11, .11},
    {49, -16, 28, -.07, .12, .10}, rearFoot, leadFoot, {14, 18, -4}, {9, 29, -25})
local lashCoil = tacticPose({-.13, -.37, .13, -11, -31, 8}, {28, 5, -36, .06, .09, .15},
    {47, -14, 24, -.075, .13, .13}, rearFoot, leadFoot, {14, 26, -5}, {-4, 39, -59})
local lashDrive = tacticPose({-.14, -.32, -.07, -12, -16, 9}, {30, 9, -35, .025, .09, .14},
    {52, -19, 20, -.09, .11, .11}, rearFoot, leadFoot, {14, 15, -4}, {-48, 13, -46, .125, 0, 0})
local lashContact = tacticPose({-.60, -.25, -.52, -11, 3, 8}, {34, 12, -32, .015, .09, .12},
    {53, -20, 20, -.065, .12, .10}, rearFoot, leadFoot, {12, -2, -4}, {-108, -20, -53, .30, .015, -.08})
local lashThrough = tacticPose({-.28, -.31, -.15, -10, 8, 7}, {37, 14, -31, .025, .10, .12},
    {54, -20, 22, -.045, .12, .10}, rearFoot, leadFoot, {11, -10, -4}, {-103, -25, -52, .36, 0, 0})
local lashFold = tacticPose({-.044, -.30, .04, -9, -2, 4}, {42, 14, -26, .02, .12, .10},
    leftGuard, rearFoot, leadFoot, {11, 4, -1}, {-40, 23, -49, .10, 0, 0})

local flintDraw = tacticPose({.02, -.25, .04, -8, 1, 4}, {47, 16, -19, .03, .135, .09},
    {35, -3, 14, -.025, .10, .17}, rearFoot, leadFoot, {11, -1, -2}, {10, -4, -5})
local flintHit = tacticPose({.02, -.22, .04, -8, -19, 5}, {50, 16, -20, .015, .13, .10},
    {62, -25, 18, .10, .08, -.07}, rearFoot, leadFoot, {11, 17, -4}, {18, 24, -8})
local flintFold = tacticPose({.02, -.24, .04, -9, -14, 4}, rightGuard,
    {56, -21, 18, .04, .095, .045}, rearFoot, leadFoot, {12, 12, -2}, {14, 14, -7})

local siltDraw = tacticPose({.02, -.40, .04, -14, -27, -7}, {25, 4, -21, .075, .045, .21},
    {59, -23, 26, -.055, .11, .125}, rearFoot, leadFoot, {16, 23, 5}, {17, 25, 10})
local siltLow = tacticPose({.02, -.51, .04, -20, -20, -6}, {24, 12, -22, .06, -.095, .07},
    {61, -23, 24, -.02, .15, .10}, rearFoot, leadFoot, {22, 18, 4}, {21, 21, 8})
local siltHit = tacticPose({.02, -.52, .04, -19, 21, -3}, {37, 24, -18, -.05, -.095, -.23},
    {59, -22, 26, -.035, .13, .13}, rearFoot, leadFoot, {21, -18, 2}, {25, -20, 2})
local siltFold = tacticPose({.02, -.37, .04, -13, 10, -3}, {44, 20, -21, .01, .02, .01},
    leftGuard, rearFoot, leadFoot, {16, -9, 2}, {20, -13, -2})

local claspCoil = tacticPose({.02, -.35, .04, -8, -8, 3}, {60, -7, 10, .105, .15, .16},
    {61, 7, -10, -.105, .14, .17}, rearFoot, leadFoot, {11, 7, -2}, {16, 7, -7})
local claspShow = tacticPose({.02, -.17, .04, -4, 0, 0}, {88, -15, 28, .13, .14, .21},
    {88, 15, -28, -.13, .14, .21}, rearFoot, leadFoot, {4}, {12})
local claspDrive = tacticPose({.02, -.29, .04, -12, -2, 0}, {70, 25, -25, .02, .08, -.015},
    {70, -25, 25, -.02, .08, -.015}, rearFoot, leadFoot, {11, 2}, {18, 2})
local claspHit = tacticPose({.02, -.33, .04, -15, 0, 0}, {62, 51, -13, .05, .055, -.40},
    {62, -51, 13, -.05, .055, -.40}, rearFoot, leadFoot, {14}, {20})
local claspPeel = tacticPose({.02, -.30, .04, -13, -2, 0}, {57, 34, -21, -.035, .09, -.14},
    {59, -34, 21, .035, .09, -.14}, rearFoot, leadFoot, {12, 2}, {17, 2})
local claspRecover = tacticPose({.02, -.24, .04, -10, -9, 3}, {48, 20, -22, .015, .13, .04},
    {54, -23, 22, -.025, .12, .015}, rearFoot, leadFoot, {12, 8, -2}, {13, 9, -5})

local stingLift = tacticPose({.02, -.245, .04, -8, -12, 4}, rightGuard, leftGuard,
    rearFoot, leadFoot, {12, 11, -3}, {-4, 10, -35})
local stingWind = tacticPose({.02, -.29, .04, -7, -13, 6}, {39, 13, -32, .06, .075, .16},
    {54, -21, 23, -.045, .13, .14}, rearFoot, leadFoot, {11, 12, -5}, {-20, 16, -42})
local stingDrive = tacticPose({.02, -.24, .04, -6, -7, 5}, {39, 13, -28, .045, .085, .145},
    {56, -22, 22, -.045, .12, .14}, rearFoot, leadFoot, {10, 7, -4}, {-55, 0, -29})
local stingHit = tacticPose({.02, -.25, .04, -7, 0, 2}, {42, 14, -28, .04, .10, .15},
    {56, -19, 21, -.055, .12, .13}, rearFoot, leadFoot, {10, 0, -1}, {-79, 0, -14, .025, .045, -.08})
local stingWithhold = tacticPose({.02, -.29, .04, -11, 12, 4}, {46, 17, -29, .025, .12, .10},
    {42, -9, 19, -.09, .10, .18}, rearFoot, leadFoot, {13, -9, -3}, {-62, 9, -34})
local stingCoil = tacticPose({.02, -.31, .04, -12, 25, 9}, {51, 19, -27, .01, .14, .12},
    {26, 4, 21, -.085, .055, .22}, rearFoot, leadFoot, {14, -20, -6}, {-22, -17, -39})
local stingClaw = tacticPose({.02, -.20, .04, -13, -27, 6}, {40, 7, -27, .17, .10, .23},
    {68, -23, 12, .045, .075, -.29}, rearFoot, leadFoot, {15, 23, -4}, {6, 23, -26})
local stingBrake = tacticPose({.02, -.255, .04, -14, -21, 4}, {47, 17, -22, .02, .13, .11},
    {59, -24, 16, .035, .081, -.13}, rearFoot, leadFoot, {15, 17, -3}, {14, 18, -17})
local stingReturn = tacticPose({.02, -.235, .04, -10, -12, 3}, rightGuard,
    leftGuard, rearFoot, leadFoot, {13, 10, -1}, {14, 10, -7})

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

local contact = {jab = .16, cross = .23, body = .275, heavy = .43, tailFeint = .31, sandPincer = .23, duneLash = .49,
    cinderSnare = .86, flintCheck = .17, siltScoop = .25, sunforgeClasp = .63, stingerRelay = table.freeze({.34, .68})}
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
    sandPincer = {{0, ready}, {.10, pincerLoad}, {contact.sandPincer, pincerClose}, {.34, pincerFold}, {.58, ready}},
    duneLash = {{0, ready}, {.15, lashLoad}, {.29, lashCoil}, {.405, lashDrive}, {contact.duneLash, lashContact},
        {.585, lashThrough}, {.735, lashFold}, {.94, ready}},
    cinderSnare = {{0, ready}, {.22, snareGather}, {.362, snareMarks}, {.69, snareMarks},
        {contact.cinderSnare, snareSnap}, {.97, snareSnap}, {1.16, ready}},
    flintCheck = {{0, ready}, {.068, flintDraw}, {contact.flintCheck, flintHit}, {.26, flintFold}, {.42, ready}},
    siltScoop = {{0, ready}, {.089, siltDraw}, {.16, siltLow}, {contact.siltScoop, siltHit}, {.36, siltFold}, {.54, ready}},
    sunforgeClasp = {{0, ready}, {.155, claspCoil}, {.324, claspShow}, {.422, claspShow}, {.525, claspDrive},
        {contact.sunforgeClasp, claspHit}, {.686, claspHit}, {.815, claspPeel}, {1.02, claspRecover}, {1.23, ready}},
    stingerRelay = {{0, ready}, {.064, stingLift}, {.126, stingWind}, {.242, stingDrive}, {contact.stingerRelay[1], stingHit},
        {.416, stingWithhold}, {.546, stingCoil}, {contact.stingerRelay[2], stingClaw}, {.807, stingBrake},
        {.98, stingReturn}, {1.20, ready}},
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
-- Keep the contact pads on the original native ellipsoids in mounted space.
local function mountedContact(key, joint, artPoint)
    return (key.RootJoint * key[joint]):PointToWorldSpace(artPoint - Vector3.yAxis * mountedHeight)
end
local claspPad = mountedContact(claspHit, "Right Shoulder", v(1.263776202, 1.872415832, -.937770648))
    :Lerp(mountedContact(claspHit, "Left Shoulder", v(-1.263776202, 1.872415832, -.937770648)), .5)
local hits = {
    jab = {{jabPinch, "Right Shoulder", rightTip}},
    cross = {{crossCut, "Left Shoulder", leftTip}},
    body = {{scoopHit, "Right Shoulder", rightTip}},
    heavy = {{heavySweep, "Left Shoulder", leftTip}},
    tailFeint = {{tailSweep, "Right Shoulder", rightTip}},
    sandPincer = {mountedContact(pincerClose, "Right Shoulder", v(1.199490452, 1.885044817, -.961241258))},
    duneLash = {mountedContact(lashContact, "TailJoint", v(.075320563, 3.949417832, 1.255634070))},
    cinderSnare = {v(0, -2.6, -3.1)},
    flintCheck = {mountedContact(flintHit, "Left Shoulder", v(-1.319859867, 1.885021442, -.896195940))},
    siltScoop = {mountedContact(siltHit, "Right Shoulder", v(1.319340007, 1.953341144, -.932089373))},
    sunforgeClasp = {claspPad},
    stingerRelay = {
        mountedContact(stingHit, "TailJoint", v(-.033931718, 4.254960016, .554470018)),
        mountedContact(stingClaw, "Left Shoulder", v(-1.320818843, 1.883634057, -.892350106)),
    },
}
local skills = {
    flintCheck = table.freeze({damage = 12, radius = .44}),
    siltScoop = table.freeze({damage = 15, radius = .47}),
    tailFeint = table.freeze({damage = 19, radius = .49, shove = .52}),
    cinderSnare = table.freeze({warningAt = .22, rootDuration = .72, vertices = vertices}),
}
local travel = {tailFeint = table.freeze({axis = "lateral", distance = .81, startsAt = .105, endsAt = .26})}

local planted = {sandPincer = true, duneLash = true, flintCheck = true, siltScoop = true, sunforgeClasp = true, stingerRelay = true}
local poses = table.clone(rig.finish(clips, contact, hits, skills, travel, {"sidestep", "tailFeint"}, planted))
poses.UltimateSkill = table.freeze({
    sunforgeClasp = table.freeze({damage = 32, radius = .49}),
    stingerRelay = table.freeze({damage = table.freeze({13, 22}), radius = table.freeze({.44, .47})}),
})
local sample = poses.sample
function poses.sample(action, age, direction)
    local offsets = sample(action, age, direction)
    if planted[action] then
        -- Match the native padded feet, which extend past the legacy sole samples.
        local up = offsets.RootJoint:VectorToObjectSpace(Vector3.yAxis)
        offsets["Right Hip"] = CFrame.new(up * .021) * offsets["Right Hip"]
        offsets["Left Hip"] = CFrame.new(up * .010) * offsets["Left Hip"]
    end
    return offsets
end

return table.freeze(poses)
