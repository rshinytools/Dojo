-- The playable Kraken plants a wide base and calls each tentacle with a distinct beat.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {v(side * .15, .012, -.822), v(side * .85, .012, -.822),
        v(side * .15, .012, .174), v(side * .85, .012, .174)}
end

local rig = Choreography.new(2.132, {
    Neck = v(0, 3.15, -.045),
    ["Right Shoulder"] = v(1.04, 3.035, .015), ["Left Shoulder"] = v(-1.04, 3.035, .015),
    ["Right Hip"] = v(.50, 1.44, .035), ["Left Hip"] = v(-.50, 1.44, .035),
    TailJoint = v(0, 1.81, .69),
}, sole(1), sole(-1))
local pose = rig.pose

local rear = {4, -19, 0, .185, 0, .13, .018}
local lead = {10, 13, 0, -.151, 0, -.16, .018}
local rightGuard = {53, 11, -35, -.045, .056, -.038}
local leftGuard = {56, -16, 34, .06, .056, -.050}
local ready = pose({.017, -.178, .027, -10, 4, -3}, rightGuard, leftGuard, rear, lead,
    {11, -5, 3}, {-12, 9, 3})
local breathe = pose({.01, -.118, .02, -6, 2, -2}, {49, 10, -36, -.034, .07, -.031},
    {59, -21, 35, .065, .066, -.041}, rear, lead, {7, -2, 2}, {-16, -13, -4})
local advanceLead = pose({-.132, -.217, -.083, -16, 14, 8}, {56, 18, -32}, {44, -19, 29},
    rear, {24, 13, -3, -.17, 0, -.295, .125}, {18, -12, -7}, {-15, -24, -7})
local advanceRear = pose({.135, -.223, -.104, -16, -13, -9}, {48, 13, -26}, {63, -19, 36},
    {20, -17, 3, .20, 0, -.253, .13}, lead, {17, 11, 8}, {-13, 24, 8})
local retreatRear = pose({.142, -.195, .156, -1, 15, -8}, {49, 13, -28}, {64, -19, 32},
    {-14, -21, 3, .20, 0, .278, .119}, lead, {1, -12, 7}, {-18, 26, 6})
local retreatLead = pose({-.14, -.177, .135, -4, -3, 8}, {55, 18, -29}, leftGuard,
    rear, {-12, 17, -2, -.195, 0, .27, .106}, {5, 3, -7}, {-18, -24, -7})
local glide = pose({.32, -.33, .082, -18, 9, -22}, {39, 14, -52}, {66, -18, 25, .06, .09, -.051},
    {11, -22, 5, .31, 0, .11, .14}, lead, {17, -8, 16}, {-17, 31, -8})
local catch = pose({.18, -.282, -.071, -13, 17, -10}, rightGuard, leftGuard,
    {9, -23, 2, .31, 0, .07, .018}, lead, {13, -15, 8}, {-16, -26, 8})

local jabLoad = pose({.081, -.23, .09, -15, -14, -6}, {30, -5, -33, .063, .018, .17},
    leftGuard, rear, lead, {16, 13, 5}, {-16, 15, -5})
local jabHit = pose({.028, -.164, -.24, -11, 28, -3}, {66, 17, -12, -.125, .108, -.246},
    leftGuard, rear, lead, {12, -26, 2}, {-14, -31, 6})
local crossLoad = pose({-.125, -.27, .128, -17, 27, 7}, rightGuard, {29, 9, 39, -.065, .021, .22},
    rear, lead, {18, -25, -6}, {-15, -29, -6})
local crossHit = pose({-.067, -.195, -.284, -13, -32, 5}, {56, 16, -31},
    {67, -22, 10, .165, .103, -.255}, rear, lead, {13, 28, -4}, {-15, 34, 5})
local bodyLoad = pose({.095, -.36, .123, -24, -23, -7}, {28, 5, -40, .09, -.031, .19},
    leftGuard, rear, lead, {23, 21, 6}, {-18, 24, -7})
local bodyHit = pose({.056, -.34, -.264, -22, 31, 0}, {56, 22, -9, -.17, -.045, -.237},
    {58, -12, 31}, rear, lead, {23, -28, 0}, {-17, -37, 8})
local heavyLoad = pose({-.15, -.355, .15, -23, 41, 11}, {60, 23, -25, -.06, .088, -.011},
    {18, 12, 53, -.156, .041, .327}, rear, lead, {22, -37, -10}, {-15, -45, -9})
local heavyHit = pose({-.086, -.266, -.29, -17, -39, 7}, {43, 17, -33},
    {67, -27, 9, .195, .120, -.283}, rear, lead, {17, 36, -6}, {-15, 42, 9})
local heavyCarry = pose({-.105, -.299, -.16, -23, -43, 11}, rightGuard,
    {55, -37, 16, .184, .064, -.14}, rear, lead, {23, 36, -9}, {-16, 43, 8})

local gripOpen = pose({0, -.28, .092, -13, 20, 0}, {39, 1, -58, .07, .044, .07},
    {35, -5, 62, -.085, .063, .12}, rear, lead, {13, -19, 0}, {-15, -29, 0})
local gripHit = pose({-.044, -.271, -.252, -16, -27, 4}, {61, 21, -18, -.23, .123, -.045},
    {64, -21, 10, .20, .106, -.28}, rear, lead, {17, 25, -3}, {-10, 31, 7})
local gripHold = pose({-.035, -.329, -.186, -22, -18, 2}, {56, 28, -22, -.185, .082, -.07},
    {62, -30, 26, .18, .073, -.12}, rear, lead, {22, 16, -2}, {-16, 24, 5})

local anchorRight = {8, -24, 1, .22, 0, .134, .018}
local anchorLeft = {9, 23, -1, -.22, 0, -.19, .018}
local summon = pose({0, -.30, .10, -16, -2, 0}, {64, -21, -62, .15, .11, .023},
    {65, 21, 61, -.15, .115, .024}, anchorRight, anchorLeft, {17, 1, 0}, {-26, 7, 0})
local firstCall = pose({.10, -.252, -.20, -18, 31, -7}, {65, 28, -20, -.19, .068, -.225},
    {37, 10, 49, -.066, .052, .135}, anchorRight, anchorLeft, {17, -27, 6}, {-23, -41, 9})
local secondCall = pose({-.115, -.225, -.185, -13, -34, 9}, {34, -6, -47, .10, .039, .152},
    {72, -27, 15, .17, .123, -.22}, anchorRight, anchorLeft, {14, 30, -8}, {-22, 43, -9})
local thirdCall = pose({.076, -.376, -.22, -28, 26, -5}, {56, 21, -9, -.16, -.02, -.25},
    {50, -18, 39, .07, .085, -.072}, anchorRight, anchorLeft, {25, -24, 4}, {-31, -35, 10})
local finalCall = pose({-.052, -.31, -.29, -24, -15, 3}, {67, 29, -18, -.20, .06, -.242},
    {69, -22, 15, .174, .09, -.274}, anchorRight, anchorLeft, {24, 15, -3}, {-32, 20, -6})
local settle = pose({-.045, -.392, -.114, -30, -17, 5}, {49, 20, -41, -.055, .053, -.095},
    {51, -24, 37, .045, .059, -.089}, anchorRight, anchorLeft, {30, 16, -4}, {-24, 26, -7})

local cover = pose({0, -.257, .053, -14, 0, 0}, {64, 23, -34, -.117, .092, -.083},
    {67, -25, 32, .114, .097, -.084}, rear, lead, {15, 0, 0}, {-16, 3, 0})
local recoil = pose({-.073, -.231, .17, 10, -9, 8}, {61, 13, -34, -.085, .091, .08},
    {61, -17, 29, .085, .095, .071}, rear, lead, {-9, 8, -7}, {-18, 17, -6})
local deflect = pose({.068, -.233, -.101, -14, 31, -8}, {67, 7, -56, -.11, .102, -.087},
    {58, -12, 28, .075, .079, -.041}, rear, lead, {14, -28, 7}, {-14, -34, 8})
local headHit = pose({-.105, -.168, .168, 14, -24, 12}, {34, 11, -39}, {32, -9, 41},
    rear, lead, {-16, 22, -10}, {-13, 27, -9})
local gutHit = pose({.102, -.448, .171, -29, 16, -11}, {38, 17, -32}, {40, -17, 34},
    rear, lead, {28, -15, 10}, {-21, -22, 9})
local bow = pose({0, -.308, -.093, -28, 0, 0}, {34, 13, -26}, {37, -13, 25},
    rear, lead, {23, 0, 0}, {-16, 0, 0})
local palmSalute = pose({.069, -.118, -.033, -7, 16, -5}, {79, 18, -18, -.127, .16, -.066},
    {55, -24, 32, .057, .08, -.02}, rear, lead, {7, -15, 4}, {-14, -21, 4})
local currentCall = pose({0, -.057, -.04, 1, 0, 0}, {81, -23, -54, .083, .15, -.088},
    {80, 24, 54, -.075, .15, -.091}, rear, lead, {0, 0, 0}, {-19, 0, 0})

local contact = {jab = .171, cross = .237, body = .285, heavy = .438, tideGrip = .31,
    tentacleCataclysm = table.freeze({.47, .62, .77, .92})}
local beat = contact.tentacleCataclysm
local clips = {
    stance = {{0, ready}, {.63, breathe}, {1.26, ready}},
    advance = {{0, ready}, {.168, advanceLead}, {.334, ready}, {.50, advanceRear}, {.668, ready}},
    retreat = {{0, ready}, {.178, retreatRear}, {.355, ready}, {.534, retreatLead}, {.71, ready}},
    sidestep = {{0, ready}, {.131, glide}, {.251, catch}, {.481, ready}},
    jab = {{0, ready}, {.079, jabLoad}, {contact.jab, jabHit}, {.227, jabHit}, {.439, ready}},
    cross = {{0, ready}, {.101, crossLoad}, {contact.cross, crossHit}, {.306, crossHit}, {.525, ready}},
    body = {{0, ready}, {.12, bodyLoad}, {contact.body, bodyHit}, {.391, breathe}, {.583, ready}},
    heavy = {{0, ready}, {.175, heavyLoad}, {.283, heavyLoad}, {contact.heavy, heavyHit},
        {.559, heavyCarry}, {.83, ready}},
    tideGrip = {{0, ready}, {.139, gripOpen}, {.213, gripOpen}, {contact.tideGrip, gripHit},
        {.394, gripHold}, {.544, breathe}, {.683, ready}},
    tentacleCataclysm = {{0, ready}, {.16, gripOpen}, {.31, summon}, {.39, summon},
        {beat[1], firstCall}, {.494, firstCall}, {beat[2], secondCall}, {.645, secondCall},
        {beat[3], thirdCall}, {.792, thirdCall}, {beat[4], finalCall}, {1.04, settle}, {1.34, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.086, recoil}, {.169, recoil}, {.294, cover}},
    parry = {{0, cover}, {.089, deflect}, {.179, deflect}, {.352, ready}},
    hitHead = {{0, ready}, {.076, headHit}, {.165, headHit}, {.359, ready}},
    hitBody = {{0, ready}, {.089, gutHit}, {.193, gutHit}, {.392, ready}},
    stagger = {{0, headHit}, {.175, catch}, {.34, recoil}, {.587, ready}},
    intro = {{0, ready}, {.8, breathe}, {1.3, palmSalute}, {2.12, palmSalute}, {2.57, bow}, {3.07, ready},
        {3.89, gripOpen}, {4.43, gripHit}, {4.95, ready}, {5.94, summon}, {6.39, firstCall},
        {6.9, secondCall}, {7.41, settle}, {7.92, ready}, {8.76, breathe}, {10, ready}},
    win = {{0, ready}, {.37, currentCall}, {1.02, currentCall}, {1.38, bow}, {1.68, bow}, {2.09, ready}},
}

local rightPad, leftPad = v(1.265, 1.923, -.918), v(-1.265, 1.923, -.918)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    tideGrip = {{gripHit, "Left Shoulder", leftPad}},
    tentacleCataclysm = {{firstCall, "Right Shoulder", rightPad}, {secondCall, "Left Shoulder", leftPad},
        {thirdCall, "Right Shoulder", rightPad}, {finalCall, "Left Shoulder", leftPad}},
}
local skills = {
    tideGrip = table.freeze({damage = 20, radius = .63, shove = .99}),
    tentacleCataclysm = table.freeze({damage = table.freeze({9, 9, 9, 9})}),
}
local travel = {tideGrip = table.freeze({axis = "forward", distance = .29, startsAt = .18, endsAt = .29})}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
