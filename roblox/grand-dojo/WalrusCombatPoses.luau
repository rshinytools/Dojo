-- Walrus keeps a wide planted base and uses the weight of both shoulders.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {
        v(side * .61, 0, -.355), v(side * .61, .046, -.76),
        v(side * .28, .048, -.355), v(side * .94, .048, -.355), v(side * .61, .057, .05),
    }
end

local rig = Choreography.new(2.60, {
    Neck = v(0, 3.16, -.06),
    ["Right Shoulder"] = v(1.02, 2.98, .03), ["Left Shoulder"] = v(-1.02, 2.98, .03),
    ["Right Hip"] = v(.58, 1.48, .03), ["Left Hip"] = v(-.58, 1.48, .03),
    TailJoint = v(0, 1.55, .57),
}, sole(1), sole(-1))
local pose = rig.pose

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

local contact = {jab = .175, cross = .239, body = .284, heavy = .448, harborPalm = .32, tidalBellyFlop = .84}
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
local hits = {
    jab = {{jabPress, "Right Shoulder", rightPalm}},
    cross = {{crossPress, "Left Shoulder", leftPalm}},
    body = {{bodyDrive, "Right Shoulder", rightPalm}},
    heavy = {{heavyPress, "Left Shoulder", leftPalm}},
    harborPalm = {{palmDrive, "Right Shoulder", rightPalm}},
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

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
