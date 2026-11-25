-- Walrus keeps a wide planted base and uses the weight of both shoulders.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {
        v(side * .61, 0, -.355), v(side * .61, .046, -.76),
        v(side * .28, .048, -.355), v(side * .94, .048, -.355), v(side * .61, .057, .05),
    }
end

local pivots = {
    Neck = v(0, 3.16, -.06),
    ["Right Shoulder"] = v(1.02, 2.98, .03), ["Left Shoulder"] = v(-1.02, 2.98, .03),
    ["Right Hip"] = v(.58, 1.48, .03), ["Left Hip"] = v(-.58, 1.48, .03),
    TailJoint = v(0, 1.55, .57),
}
local rightSole, leftSole = sole(1), sole(-1)
local rig = Choreography.new(2.60, pivots, rightSole, leftSole)
local pose = rig.pose
local mountedHeight = 2.132
local mountedRig = Choreography.new(mountedHeight, pivots, rightSole, leftSole)
local attackPose = mountedRig.pose

local rightGuard, leftGuard = {48, 15, -18, -.06, .045, .02}, {46, -17, 17, .075, .055, -.06}
local rearFoot, leadFoot = {3, -23, 0, .17, 0, .15, 0}, {5, 25, 0, -.16, 0, -.16, 0}
local gaze, flippers = {10, 8, -1}, {6, 8, 1}
local ready = pose({.025, -.22, .005, -8, -9, 1}, rightGuard, leftGuard, rearFoot, leadFoot, gaze, flippers)
local breath = pose({.015, -.16, -.007, -7, -7, 2}, {50, 14, -19, -.05, .075, .035},
    {48, -16, 19, .065, .07, -.055}, rearFoot, leadFoot, {9, 8, -1}, {8, 5, 1})
local stepLeft = pose({-.14, -.245, -.11, -12, -12, 7}, rightGuard, leftGuard, rearFoot,
    {13, 24, -1, -.24, 0, -.34, .14}, {12, 14, -5}, {11, 10, -6})
local stepRight = pose({.16, -.215, -.095, -11, 0, -7}, rightGuard, leftGuard,
    {12, -20, 1, .25, 0, -.29, .13}, leadFoot, {11, 0, 5}, {8, -10, 7})
local retreatLeft = pose({-.14, -.275, .14, 4, -13, 7}, rightGuard, leftGuard, rearFoot,
    {-11, 20, 0, -.24, 0, .33, .10}, {-3, 14, -4}, {-15, 13, -6})
local retreatRight = pose({.16, -.27, .16, 3, -1, -6}, rightGuard, leftGuard,
    {-10, -21, 0, .24, 0, .36, .10}, leadFoot, {-2, 2, 4}, {-14, -8, 7})
local evade = pose({.25, -.31, .08, -9, -17, -16}, {39, 9, -30, .14, .09, .16}, leftGuard,
    {6, -27, 0, .31, 0, .13, .08}, leadFoot, {11, 17, 8}, {3, 22, -7})
local brake = pose({.16, -.28, .02, -12, -6, -9}, rightGuard, leftGuard,
    {8, -24, 0, .24, 0, .13, 0}, leadFoot, {13, 6, 4}, {9, 12, -3})

local jabDraw = pose({.09, -.28, .105, -9, -25, -5}, {28, 5, -15, -.03, .07, .18},
    leftGuard, rearFoot, leadFoot, {12, 25, 3}, {3, 24, 5})
local jabPress = pose({.035, -.14, -.23, -6, 22, -2}, {65, 22, -13, -.13, .09, -.15},
    leftGuard, rearFoot, leadFoot, {8, -21, 2}, {12, -26, 3})
local crossDraw = pose({-.12, -.31, .12, -10, 29, 8}, rightGuard,
    {24, -8, 22, .02, .095, .24}, rearFoot, leadFoot, {12, -27, -6}, {1, -25, -7})
local crossPress = pose({-.075, -.155, -.25, -9, -25, 4}, rightGuard,
    {67, -22, 11, .16, .07, -.18}, rearFoot, leadFoot, {10, 24, -2}, {12, 25, -5})
local bodyDraw = pose({.04, -.43, .125, -16, -24, -7}, {26, 4, -20, -.04, -.12, .20},
    leftGuard, rearFoot, {8, 22, 0, -.17, 0, -.20, 0}, {17, 18, 4}, {8, 25, 6})
local bodyDrive = pose({.035, -.35, -.25, -13, 23, -3}, {43, 19, -12, -.13, -.095, -.24},
    leftGuard, rearFoot, {9, 22, 0, -.17, 0, -.20, 0}, {16, -20, 2}, {13, -21, 3})
local heavyDraw = pose({-.10, -.39, .155, -14, 39, 10}, {30, 13, -31, .16, .05, .23},
    {23, -7, 28, -.13, .065, .28}, rearFoot, leadFoot, {15, -34, -6}, {3, -36, -9})
local heavyPress = pose({-.055, -.165, -.28, -12, -31, 4}, {47, 12, -28, .04, .05, .07},
    {64, -20, 12, .16, .02, -.22}, rearFoot, leadFoot, {13, 29, -2}, {15, 33, -5})
local follow = pose({-.135, -.29, -.155, -18, -37, 7}, rightGuard,
    {49, -16, 18, .10, -.025, -.04}, rearFoot, leadFoot, {17, 32, -4}, {19, 36, -8})

local palmDraw = pose({.12, -.36, .13, -10, -29, -8}, {29, 10, -16, -.06, .11, .25},
    {57, -18, 24, .095, .14, -.04}, {8, -26, 0, .23, 0, .15, 0}, leadFoot,
    {12, 27, 6}, {6, 30, 7})
local palmDrive = pose({.015, -.085, -.27, -7, 29, -3}, {70, 20, -10, -.16, .13, -.27},
    {52, -16, 19, .075, .105, .11}, {8, -22, 0, .19, 0, .18, 0},
    {10, 23, 0, -.18, 0, -.30, 0}, {9, -27, 2}, {15, -32, 4})
local palmSettle = pose({.045, -.255, -.13, -15, 15, -4}, {56, 19, -14, -.12, .08, -.095},
    leftGuard, rearFoot, {8, 23, 0, -.17, 0, -.24, 0}, {16, -14, 4}, {14, -20, 5})

local whiskerLoad = attackPose({.045, -.24, .105, -8, -8, -1}, {53, 19, -25, -.08, .10, .08},
    {52, -20, 25, .08, .10, .07}, rearFoot, leadFoot, {2, 8, 0, .02, .06, .13}, {2, 12, -3})
local whiskerHit = attackPose({.035, -.27, -.33, -20, -6, 0}, {55, 15, -27, .04, .12, -.035},
    {55, -15, 28, -.04, .12, -.03}, rearFoot, leadFoot, {-3, 9, 0, .045, .02, -.16}, {15, 8, 0})
local whiskerReturn = attackPose({.035, -.29, -.095, -11, -5, 1}, rightGuard, leftGuard,
    rearFoot, leadFoot, {10, 7, 1, .025, .025, -.085}, {9, 9, 1})
local basinLoad = attackPose({-.065, -.38, .17, -10, -12, 5}, {14, 1, -36, .16, .10, .26},
    {16, 3, 35, -.17, .095, .25}, rearFoot, leadFoot, {12, 14, -3}, {-5, 14, -4})
local basinBrace = attackPose({-.055, -.43, .20, -12, -10, 5}, {38, 5, -55, .23, .15, .28},
    {35, -3, 52, -.23, .15, .31}, rearFoot, leadFoot, {18, 12, -2}, {-9, 15, -6})
local basinHit = attackPose({.025, -.26, -.30, -13, 4, -3}, {70, 6, -31, -.31, .11, -.46},
    {73, -6, 36, .32, .115, -.43}, rearFoot, leadFoot, {9, -3, 1}, {17, -6, 3})
local basinFollow = attackPose({.035, -.34, -.19, -17, 8, -5}, {59, 10, -34, -.195, .085, -.31},
    {60, -8, 39, .215, .09, -.28}, rearFoot, leadFoot, {13, -6, 3}, {19, -9, 4})

local crouchFeet = {17, -27, 0, .18, 0, .14, 0}
local crouchOther = {17, 27, 0, -.18, 0, -.13, 0}
local leapGather = pose({0, -.52, .095, -15, 0, 0}, {11, 10, -33, .12, .055, .15},
    {11, -10, 33, -.12, .055, .15}, crouchFeet, crouchOther, {15, 0, 0}, {-17, 0, 0})
local leapPush = pose({0, .15, -.05, -3, 0, 0}, {66, 3, -36, .09, .14, -.09},
    {66, -3, 36, -.09, .14, -.09}, {31, -20, 0, .16, .035, .15, .46},
    {37, 20, 0, -.16, .045, .08, .66}, {7, 0, 0}, {9, 0, 0})
local leapApex = pose({.005, 1.36, -.08, -16, 2, 2}, {77, 4, -45, .16, .09, -.02},
    {74, -4, 44, -.16, .09, -.01}, {41, -17, 0, .16, .08, .15, 1.76},
    {46, 17, 0, -.16, .08, .095, 1.90}, {19, -2, -2}, {16, -3, 3})
local plunge = pose({.008, .69, -.16, -51, 1, 1}, {41, 16, -40, .18, .055, .12},
    {43, -16, 40, -.18, .055, .12}, {14, -24, 0, .16, .08, .23, .92},
    {17, 24, 0, -.16, .08, .25, 1.01}, {26, -1, -1}, {19, -1, 3})
local splash = pose({0, -1.16, -.065, -64, 0, 0}, {19, 13, -39, .15, .015, .055},
    {19, -13, 39, -.15, .015, .055}, {-21, -22, 0, .17, 0, .27, .20},
    {-21, 22, 0, -.17, 0, .24, .20}, {31, 0, 0}, {23, 0, 0})
local seatPlant = pose({0, -.56, -.115, -27, 0, 0}, {34, 13, -28, .085, .055, -.03},
    {34, -13, 28, -.085, .055, -.03}, {17, -27, 0, .18, 0, .14, .024},
    {17, 27, 0, -.18, 0, -.13, .024}, {20, 0, 0}, {15, 0, 0})

local cover = pose({0, -.32, .075, -10, 0, 0}, {67, 13, -12, -.20, .12, -.03},
    {66, -14, 12, .20, .12, -.03}, rearFoot, leadFoot, {14, 0, 0}, {11, 0, 0})
local recoil = pose({-.04, -.36, .155, 5, -5, 4}, {60, 13, -10, -.15, .11, .08},
    {62, -14, 13, .17, .11, .08}, rearFoot, leadFoot, {-8, 7, -3}, {-6, 9, -3})
local deflect = pose({.05, -.22, -.08, -8, 24, -5}, {58, -18, -15, -.08, .17, -.115},
    {54, -16, 26, .06, .08, .06}, rearFoot, leadFoot, {10, -21, 5}, {8, -27, 6})
local hitHigh = pose({-.095, -.26, .22, 16, -14, 7}, {36, 15, -24, .085, .05, .14},
    {41, -14, 21, -.07, .07, .14}, rearFoot, leadFoot, {-27, 13, -4}, {-8, 19, -6})
local hitBody = pose({.10, -.42, .15, -21, 16, -6}, {40, 13, -20, .015, -.045, .035},
    {39, -14, 22, -.015, -.04, .02}, rearFoot, leadFoot, {22, -14, 4}, {19, -21, 5})
local bow = pose({0, -.39, -.105, -28, 0, 0}, {32, 16, -19, -.035, .03, .08},
    {32, -16, 19, .035, .03, .08}, rearFoot, leadFoot, {23, 0, 0}, {8, 0, 0})
local salute = pose({.02, -.08, -.04, -3, -12, 1}, {73, 8, -31, .14, .135, -.04},
    {64, -11, 29, -.13, .12, -.04}, rearFoot, leadFoot, {4, 12, -1}, {14, 9, 3})

local contact = {jab = .175, cross = .239, body = .284, heavy = .448, harborPalm = .32, tidalBellyFlop = .84,
    whiskerCheck = .27, basinPress = .53}
local clips = {
    stance = {{0, ready}, {.49, breath}, {1.0, ready}},
    advance = {{0, ready}, {.17, stepLeft}, {.34, breath}, {.51, stepRight}, {.69, ready}},
    retreat = {{0, ready}, {.17, retreatRight}, {.34, ready}, {.51, retreatLeft}, {.69, ready}},
    sidestep = {{0, ready}, {.11, evade}, {.245, brake}, {.49, ready}},
    jab = {{0, ready}, {.083, jabDraw}, {contact.jab, jabPress}, {.25, jabPress}, {.45, ready}},
    cross = {{0, ready}, {.113, crossDraw}, {contact.cross, crossPress}, {.33, crossPress}, {.53, ready}},
    body = {{0, ready}, {.136, bodyDraw}, {contact.body, bodyDrive}, {.40, breath}, {.60, ready}},
    heavy = {{0, ready}, {.196, heavyDraw}, {.307, heavyDraw}, {contact.heavy, heavyPress}, {.56, follow}, {.84, ready}},
    harborPalm = {{0, ready}, {.13, palmDraw}, {.205, palmDraw}, {contact.harborPalm, palmDrive},
        {.43, palmSettle}, {.68, ready}},
    whiskerCheck = {{0, ready}, {.11, whiskerLoad}, {contact.whiskerCheck, whiskerHit}, {.41, whiskerReturn}, {.65, ready}},
    basinPress = {{0, ready}, {.19, basinLoad}, {.33, basinBrace}, {.39, basinBrace}, {contact.basinPress, basinHit},
        {.64, basinFollow}, {.79, breath}, {1.0, ready}},
    tidalBellyFlop = {{0, ready}, {.18, leapGather}, {.30, leapGather}, {.40, leapPush}, {.58, leapApex},
        {.735, plunge}, {contact.tidalBellyFlop, splash}, {.93, splash}, {1.045, seatPlant}, {1.22, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.084, recoil}, {.164, recoil}, {.29, cover}},
    parry = {{0, cover}, {.095, deflect}, {.18, deflect}, {.36, ready}},
    hitHead = {{0, ready}, {.079, hitHigh}, {.174, hitHigh}, {.36, ready}},
    hitBody = {{0, ready}, {.091, hitBody}, {.192, hitBody}, {.38, ready}},
    stagger = {{0, hitHigh}, {.17, brake}, {.36, recoil}, {.58, ready}},
    intro = {{0, ready}, {.9, breath}, {1.7, salute}, {2.25, salute}, {2.94, bow}, {3.47, ready},
        {4.34, leapGather}, {4.85, leapGather}, {5.3, ready}, {6.21, palmDraw}, {6.56, palmDrive},
        {7.27, brake}, {8.2, ready}, {9, breath}, {10, ready}},
    win = {{0, ready}, {.32, salute}, {.94, salute}, {1.31, bow}, {1.59, bow}, {2.05, ready}},
}

local rightPalm, leftPalm = v(1.37, 1.80, -.814), v(-1.37, 1.80, -.814)
local splashCenter = v(0, -2.60, 0)
local function mountedContact(key, joint, surface)
    return (key.RootJoint * key[joint]):PointToWorldSpace(surface - v(0, mountedHeight, 0))
end
local hits = {
    jab = {{jabPress, "Right Shoulder", rightPalm}},
    cross = {{crossPress, "Left Shoulder", leftPalm}},
    body = {{bodyDrive, "Right Shoulder", rightPalm}},
    heavy = {{heavyPress, "Left Shoulder", leftPalm}},
    harborPalm = {{palmDrive, "Right Shoulder", rightPalm}},
    whiskerCheck = {mountedContact(whiskerHit, "Neck", v(.020257, 3.973706, -1.016074))},
    basinPress = {mountedContact(basinHit, "Right Shoulder", v(1.536502, 1.679633, -.727501))},
    tidalBellyFlop = {splashCenter},
}
local skills = {
    harborPalm = table.freeze({damage = 21, radius = .50, shove = .88}),
    tidalBellyFlop = table.freeze({warningAt = .18, groundAt = contact.tidalBellyFlop, radius = 3.65,
        damage = 33, shove = 1.55, center = splashCenter}),
}
local travel = {
    tidalBellyFlop = table.freeze({axis = "forward", distance = 1.36, startsAt = .34, endsAt = .79}),
}

local standard = rig.finish(clips, contact, hits, skills, travel, {"sidestep"},
    {whiskerCheck = true, basinPress = true})

-- The new strikes use the equipped shell's root height. Plant the visible
-- flipper soles just above the mat and preserve the original pose repertoire.
local leftHip, rightHip = "Left Hip", "Right Hip"
local leftPlant = CFrame.new(0, .011, 0) * ready.RootJoint * ready[leftHip]
local rightPlant = CFrame.new(0, .018, 0) * ready.RootJoint * ready[rightHip]

local function plantFlippers(offsets, both)
    local root = offsets.RootJoint
    offsets[leftHip] = root:ToObjectSpace(leftPlant)
    if both then
        offsets[rightHip] = root:ToObjectSpace(rightPlant)
    end
    return offsets
end

local function fitted(core, right, left, head, tail, kick)
    return plantFlippers(mountedRig.pose(core, right, left, kick or rearFoot, leadFoot, head, tail), kick == nil)
end

local variantReady = plantFlippers(table.clone(ready), true)
local tapGather = fitted({.055, -.24, .062, -8, -20, -4}, {37, 12, -32, .078, .083, .13},
    leftGuard, {11, 18, 3}, {5, 20, 3})
local tapHit = fitted({.042, -.24, .105, -12, 32, -4}, {68, 29, -4, -.187, .11, -.126},
    {48, -13, 22, .08, .065, .045}, {12, -29, 2}, {10, -32, 4})
local tapEase = fitted({.054, -.25, -.075, -8, 16, -4}, {56, 17, -18, -.089, .082, -.095},
    leftGuard, {10, -13, 1}, {9, -15, 4})

local toeGather = fitted({-.078, -.273, .021, -10, -14, 7}, {47, 18, -24, .015, .087, .058},
    {56, -20, 21, .065, .104, .023}, {13, 14, -4}, {-5, 17, -5})
local toeTuck = fitted({-.12, -.288, -.005, -7, -11, 9}, {47, 13, -29, .045, .074, .095},
    {61, -20, 16, .098, .124, .033}, {8, 11, -5}, {-3, 15, -7},
    {31, -16, 5, .138, .035, .059, .25})
local toeHit = fitted({-.115, -.24, -.20, -12, 16, 8}, {48, 22, -29, .02, .072, -.058},
    {60, -20, 18, .108, .123, .056}, {11, -14, -4}, {8, -16, -6},
    {64, -5, 5, -.035, .05, -.24, .63})
local toeEase = fitted({-.10, -.275, -.07, -10, 5, 6}, {48, 18, -26, .023, .085, -.025},
    {54, -19, 22, .087, .096, .04}, {10, -5, -3}, {5, -6, -5},
    {28, -14, 4, .055, .055, -.097, .20})

local dropRaise = fitted({.018, -.025, .128, 0, -4, 1}, {101, 8, -61, .04, .23, .035},
    {99, -7, 56, -.031, .20, .059}, {5, 3, -1}, {-2, 6, -1})
local dropHold = fitted({.013, -.066, .111, -7, -1, 0}, {94, 9, -53, -.025, .18, .053},
    {91, -8, 51, .024, .17, .065}, {11, 2, -1}, {-4, 4, -1})
local dropDrive = fitted({.028, -.259, -.092, -17, 2, -3}, {68, 20, -32, -.115, .071, -.12},
    {67, -17, 33, .104, .073, -.115}, {15, -2, 2}, {10, -4, 4})
local dropHit = fitted({.047, -.41, -.34, -25, 5, -3}, {50, 26, -14, -.279, -.103, -.37},
    {51, -21, 20, .231, -.090, -.315}, {18, -4, 2}, {15, -7, 4})
local dropReceive = fitted({.034, -.39, -.183, -22, 7, -3}, {55, 23, -19, -.185, -.052, -.223},
    {54, -19, 22, .161, -.051, -.21}, {17, -6, 2}, {14, -9, 4})
local dropEase = fitted({.029, -.27, -.052, -12, 2, -1}, rightGuard, leftGuard,
    {13, 0, 1}, {9, -4, 1})

local tideLeftLoad = fitted({-.066, -.28, .093, -8, 31, 6}, {53, 15, -18, -.041, .076, .054},
    {44, 21, -56, .15, .05, .063}, {9, -27, -5}, {4, -34, -6})
local tideLeft = fitted({-.049, -.207, -.237, -12, -36, 4}, {52, 14, -29, -.098, .069, .074},
    {74, -23, 14, .199, .083, -.203}, {12, 29, -3}, {15, 38, -6})
local tideRightLoad = fitted({.076, -.296, -.057, -11, -39, -6}, {41, -20, 58, -.159, .051, .054},
    {48, -19, 25, .123, .088, .002}, {11, 30, 5}, {-5, 43, 7})
local tideRight = fitted({.051, -.214, -.301, -13, 39, -5}, {76, 26, -14, -.228, .078, -.274},
    {49, -17, 24, .116, .084, .052}, {15, -34, 4}, {16, -44, 7})
local tideEase = fitted({.063, -.235, -.145, -14, 25, -6}, {59, 20, -20, -.136, .072, -.106},
    {50, -17, 20, .084, .071, .058}, {13, -24, 4}, {11, -29, 6})

local toeLiftAt, toePlantAt = .067, .51
local variantContact = {dockTap = .153, brineToe = .26, mooringDrop = .62, tidelineClap = table.freeze({.34, .69})}
local variantClips = {
    dockTap = {{0, variantReady}, {.067, tapGather}, {variantContact.dockTap, tapHit},
        {.253, tapEase}, {.41, variantReady}},
    brineToe = {{0, variantReady}, {toeLiftAt, toeGather}, {.148, toeTuck}, {variantContact.brineToe, toeHit},
        {.365, toeEase}, {toePlantAt, variantReady}, {.55, variantReady}},
    mooringDrop = {{0, variantReady}, {.237, dropRaise}, {.332, dropRaise}, {.431, dropHold}, {.527, dropDrive},
        {variantContact.mooringDrop, dropHit}, {.756, dropReceive}, {.99, dropEase}, {1.23, variantReady}},
    tidelineClap = {{0, variantReady}, {.14, tideLeftLoad}, {variantContact.tidelineClap[1], tideLeft},
        {.505, tideRightLoad}, {variantContact.tidelineClap[2], tideRight}, {.815, tideEase}, {1.20, variantReady}},
}
-- Contact points sampled from the forward-facing surfaces on the shipped shell.
local variantHits = {
    dockTap = {{tapHit, "Right Shoulder", v(1.577509024, 1.698820213, -.693145547)}},
    brineToe = {{toeHit, rightHip, v(.796677020, .078773836, -.866673597)}},
    mooringDrop = {{dropHit, "Right Shoulder", v(1.551914907, 1.741691451, -.758949033)}},
    tidelineClap = {{tideLeft, "Left Shoulder", v(-1.594760753, 1.721822605, -.690281874)},
        {tideRight, "Right Shoulder", v(1.599291775, 1.728037077, -.685471205)}},
}
local basicSkills = {
    dockTap = table.freeze({damage = 12, radius = .44}),
    brineToe = table.freeze({damage = 15, radius = .48, foot = true}),
}
local variants = mountedRig.finish(variantClips, variantContact, variantHits, basicSkills, {}, {})
local poses = table.clone(standard)
poses.UltimateSkill = table.freeze({
    mooringDrop = table.freeze({damage = 32, radius = .57}),
    tidelineClap = table.freeze({damage = table.freeze({14, 21}), radius = table.freeze({.48, .54})}),
})
for _, field in {"Duration", "Contact", "Impact", "Skill"} do
    local values = table.clone(standard[field])
    for move, value in variants[field] do
        values[move] = value
    end
    poses[field] = table.freeze(values)
end

function poses.sample(action, age, direction)
    if variantContact[action] then
        local time = age or 0
        local keepBothPlanted = action ~= "brineToe" or time <= toeLiftAt or time >= toePlantAt
        return plantFlippers(variants.sample(action, time, direction), keepBothPlanted)
    end
    return standard.sample(action, age, direction)
end

function poses.impact(action, index, direction)
    local source = if variantContact[action] then variants else standard
    return source.impact(action, index, direction)
end

return table.freeze(poses)
