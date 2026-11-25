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

local tapGather = pose({.043, -.234, .055, -14, -8, -6}, {38, -11, -34, .015, .064, .105},
    leftGuard, rear, lead, {14, 8, 3}, {-12, 15, 0})
local tapDrive = pose({.041, -.279, -.047, -17, 15, -4}, {54, 4, -29, -.032, .041, -.028},
    {54, -13, 32, .063, .072, -.021}, rear, lead, {17, -13, 2}, {-16, -17, 5})
local tapHit = pose({.028, -.25, -.032, -15, 27, -3}, {66, 17, -10, -.137, .067, -.028},
    {54, -16, 34, .062, .06, -.045}, rear, lead, {16, -24, 1}, {-13, -24, 7})
local tapReset = pose({.026, -.228, -.049, -14, 16, -3}, {60, 15, -22, -.104, .068, -.077},
    leftGuard, rear, lead, {15, -15, 2}, {-13, -14, 6})

local palmDraw = pose({-.077, -.299, .13, -16, 33, 8}, {54, 6, -42, -.064, .085, -.015},
    {31, 12, 54, .017, .065, .161}, rear, lead, {15, -31, -6}, {-18, -25, -7})
local palmBrace = pose({-.069, -.333, .083, -19, 30, 7}, {55, 13, -39, -.100, .076, -.031},
    {36, 8, 50, .035, .092, .129}, rear, lead, {19, -27, -5}, {-19, -24, -6})
local palmSwing = pose({-.051, -.279, -.047, -15, 3, 4}, {58, 19, -34, -.123, .067, -.055},
    {55, -13, 37, .068, .112, -.059}, rear, lead, {15, -3, -4}, {-19, 7, -4})
local palmHit = pose({-.043, -.222, -.258, -13, -37, 3}, {57, 19, -36, -.106, .076, -.065},
    {73, -17, 11, .172, .117, -.229}, rear, lead, {13, 35, -1}, {-13, 38, -5})
local palmThrough = pose({-.063, -.273, -.162, -17, -46, 6}, {54, 19, -32, -.072, .075, -.041},
    {63, -26, 18, .154, .092, -.156}, rear, lead, {17, 41, -4}, {-17, 43, -7})
local palmReset = pose({-.027, -.221, -.050, -12, -15, 2}, rightGuard,
    {56, -19, 29, .091, .073, -.077}, rear, lead, {12, 14, -1}, {-14, 17, -3})

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

-- The short left hook coils inward while the opposite guard stays visible.
local reefDraw = pose({-.058, -.225, .062, -10, 23, 7}, {54, 16, -28, -.055, .07, .06},
    {36, 6, 41, -.07, .055, .145}, rear, lead, {9, -21, -5}, {-12, -23, -6})
local reefHit = pose({-.056, -.197, -.14, -13, -21, 5}, {58, 19, -29, -.065, .09, .055},
    {55, -26, 13, .135, .068, -.12}, rear, lead, {12, 20, -4}, {-15, 25, 5})
local reefFold = pose({-.031, -.218, -.037, -11, -9, 3}, rightGuard,
    {50, -20, 27, .10, .065, -.025}, rear, lead, {11, 8, -3}, {-14, 10, 3})

-- Low toe check. The left support frame stays fixed as the right tentacle boot lifts.
local poolLoad = pose({-.16, -.232, .048, -8, -9, 11}, {55, 16, -34, -.05, .077, .042},
    {62, -20, 35, .06, .082, .01}, {27, -8, 1, .10, .013, -.10, .265}, lead,
    {8, 8, -7}, {-14, 14, 9})
local poolHit = pose({-.14, -.169, -.22, -2, 9, 10}, {57, 13, -33, -.05, .075, .038},
    {65, -21, 33, .065, .09, .035}, {44, 13, 1, -.05, .025, -.32, .49}, lead,
    {2, -8, -7}, {-10, -15, 8})
local poolFold = pose({-.147, -.216, -.085, -7, -4, 10}, {53, 15, -34, -.045, .065, .039},
    leftGuard, {29, -3, 0, .06, .015, -.125, .315}, lead, {8, 4, -6}, {-14, 7, 7})
local poolSettle = pose({-.05, -.199, .012, -9, 0, 3}, rightGuard,
    leftGuard, {10, -16, 0, .15, 0, .105, .070}, lead, {10, -2, -2}, {-13, 10, 3})

-- Trench Ring raises both wrapped tentacles. The right plants on the mat
-- while the left opens for balance and the mantle turns through the crouch.
local trenchBrace = pose({.04, -.246, .075, -9, 1, -3}, {69, 17, -10, -.03, .12, .075},
    {57, -12, 10, -.022, .10, .095}, rear, lead, {9, -1, 2}, {-14, 9, 3})
local trenchRaise = pose({.065, -.16, .09, 2, 3, -5}, {145, 8, 20, .12, .085, .035},
    {106, -9, -28, -.145, .115, .085}, rear, lead, {-3, -2, 4}, {-15, -7, 6})
local trenchFold = pose({.088, -.62, -.115, 29, 4, -8}, {65, 14, 5, .04, -.01, -.055},
    {89, -12, -23, -.105, .095, .065}, rear, lead, {-17, -4, 7}, {-66, -6, 7})
local trenchHit = pose({.09, -1.19, -.49, 68, 7, -8}, {-54, 14, -11, -.08, .005, .065},
    {85, -12, -27, -.11, .095, .075}, rear, lead, {-37, -7, 7}, {-110, -8, 3, 0, .04, -.125})
local trenchRise = pose({.071, -.69, -.24, 36, 6, -7}, {10, 18, -14, -.055, .019, -.11},
    {74, -19, -18, -.095, .07, .09}, rear, lead, {-20, -5, 6}, {-71, -2, 5, 0, .015, -.06})
local trenchRecover = pose({.027, -.27, -.055, 4, 6, -3}, {48, 15, -29, -.045, .075, .025},
    {58, -17, 31, .065, .075, -.022}, rear, lead, {-2, -5, 3}, {-26, 6, 3})

-- Reefbreaker Cross drops the left wrap from above and then turns the
-- opposite forearm low through the torso line from the same stance.
local breakerRaise = pose({-.11, -.195, .085, -6, 27, 8}, {57, 16, -29, -.055, .093, .041},
    {111, -7, 17, -.025, .12, .11}, rear, lead, {5, -23, -5}, {-10, -30, -8})
local breakerHigh = pose({-.075, -.167, -.215, -13, -28, 5}, {59, 21, -32, -.065, .10, .055},
    {66, -24, 13, .155, .123, -.215}, rear, lead, {12, 25, -4}, {-14, 34, 8})
local breakerShift = pose({.048, -.287, -.08, -17, -13, -6}, {37, 3, -38, .025, .028, .115},
    {53, -21, 29, .095, .092, -.015}, rear, lead, {16, 12, 5}, {-17, 18, 8})
local breakerLoad = pose({.13, -.344, .052, -19, -31, -9}, {29, -5, -43, .085, -.015, .18},
    {56, -23, 33, .073, .096, .045}, rear, lead, {17, 27, 6}, {-17, 36, 11})
local breakerLow = pose({.091, -.337, -.315, -23, 35, -6}, {48, 28, -13, -.16, -.065, -.23},
    {59, -21, 35, .065, .094, .025}, rear, lead, {22, -30, 5}, {-15, -38, 7})
local breakerCarry = pose({.047, -.382, -.205, -24, 43, -4}, {37, 30, -16, -.147, -.041, -.165},
    leftGuard, rear, lead, {23, -36, 3}, {-14, -46, 8})
local breakerRecover = pose({.035, -.259, -.048, -14, 12, -3}, {49, 15, -31, -.05, .057, -.013},
    leftGuard, rear, lead, {14, -12, 2}, {-19, -17, 5})

local contact = {jab = .171, cross = .237, body = .285, heavy = .438, tideGrip = .31,
    reefCurl = .17, tidepoolToe = .26, trenchRing = .65, reefbreakerCross = table.freeze({.33, .70}),
    currentTap = .25, maelstromPalm = .51,
    tentacleCataclysm = table.freeze({.47, .62, .77, .92})}
local beat = contact.tentacleCataclysm
local clips = {
    stance = {{0, ready}, {.63, breathe}, {1.26, ready}},
    advance = {{0, ready}, {.168, advanceLead}, {.334, ready}, {.50, advanceRear}, {.668, ready}},
    retreat = {{0, ready}, {.178, retreatRear}, {.355, ready}, {.534, retreatLead}, {.71, ready}},
    sidestep = {{0, ready}, {.131, glide}, {.251, catch}, {.481, ready}},
    jab = {{0, ready}, {.079, jabLoad}, {contact.jab, jabHit}, {.227, jabHit}, {.439, ready}},
    reefCurl = {{0, ready}, {.075, reefDraw}, {contact.reefCurl, reefHit}, {.28, reefFold}, {.42, ready}},
    tidepoolToe = {{0, ready}, {.115, poolLoad}, {contact.tidepoolToe, poolHit}, {.361, poolFold}, {.448, poolSettle}, {.54, ready}},
    trenchRing = {{0, ready}, {.151, trenchBrace}, {.335, trenchRaise}, {.434, trenchRaise}, {.544, trenchFold},
        {contact.trenchRing, trenchHit}, {.693, trenchHit}, {.794, trenchRise}, {1.052, trenchRecover}, {1.29, ready}},
    reefbreakerCross = {{0, ready}, {.162, breakerRaise}, {.211, breakerRaise}, {contact.reefbreakerCross[1], breakerHigh},
        {.464, breakerShift}, {.566, breakerLoad}, {contact.reefbreakerCross[2], breakerLow},
        {.804, breakerCarry}, {.982, breakerRecover}, {1.20, ready}},
    cross = {{0, ready}, {.101, crossLoad}, {contact.cross, crossHit}, {.306, crossHit}, {.525, ready}},
    body = {{0, ready}, {.12, bodyLoad}, {contact.body, bodyHit}, {.391, breathe}, {.583, ready}},
    heavy = {{0, ready}, {.175, heavyLoad}, {.283, heavyLoad}, {contact.heavy, heavyHit},
        {.559, heavyCarry}, {.83, ready}},
    tideGrip = {{0, ready}, {.139, gripOpen}, {.213, gripOpen}, {contact.tideGrip, gripHit},
        {.394, gripHold}, {.544, breathe}, {.683, ready}},
    currentTap = {{0, ready}, {.091, tapGather}, {.168, tapDrive}, {contact.currentTap, tapHit},
        {.349, tapReset}, {.63, ready}},
    maelstromPalm = {{0, ready}, {.188, palmDraw}, {.280, palmDraw}, {.352, palmBrace},
        {.419, palmSwing}, {contact.maelstromPalm, palmHit}, {.622, palmThrough},
        {.801, palmReset}, {.98, ready}},
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
-- The fitted native shell points follow each padding surface to its contact frame.
local function mountedSurface(key, joint, rest)
    return (key.RootJoint * key[joint]):PointToWorldSpace(rest)
end

local reefPad = v(-1.532502106, -.256102961, -.867787665)
local poolPad = v(.729337205, -2.011924674, -.850178846)
local trenchPad = v(1.301971266, -.484110899, -.550531824)
local breakerHighPad = v(-1.593844219, -.327266151, -.699737339)
local breakerLowPad = v(1.658205565, .068239606, -.464707525)
local trenchHand = mountedSurface(trenchHit, "Right Shoulder", trenchPad)
local trenchCenter = v(trenchHand.X, -2.132, trenchHand.Z)
local hits = {
    reefCurl = {mountedSurface(reefHit, "Left Shoulder", reefPad)},
    tidepoolToe = {mountedSurface(poolHit, "Right Hip", poolPad)},
    trenchRing = {trenchCenter},
    reefbreakerCross = {
        mountedSurface(breakerHigh, "Left Shoulder", breakerHighPad),
        mountedSurface(breakerLow, "Right Shoulder", breakerLowPad),
    },
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    tideGrip = {{gripHit, "Left Shoulder", leftPad}},
    currentTap = {{tapHit, "Right Shoulder", v(1.568347134, 1.790349227, -.726339229)}},
    maelstromPalm = {{palmHit, "Left Shoulder", v(-1.532139772, 1.872116985, -.863937001)}},
    tentacleCataclysm = {{firstCall, "Right Shoulder", rightPad}, {secondCall, "Left Shoulder", leftPad},
        {thirdCall, "Right Shoulder", rightPad}, {finalCall, "Left Shoulder", leftPad}},
}
local skills = {
    reefCurl = table.freeze({damage = 12, radius = .44}),
    tidepoolToe = table.freeze({damage = 15, radius = .47, foot = true}),
    tideGrip = table.freeze({damage = 20, radius = .63, shove = .99}),
    currentTap = table.freeze({damage = 15, radius = .48}),
    maelstromPalm = table.freeze({damage = 24, radius = .56}),
    tentacleCataclysm = table.freeze({damage = table.freeze({9, 9, 9, 9})}),
}
local travel = {tideGrip = table.freeze({axis = "forward", distance = .29, startsAt = .18, endsAt = .29})}

local standard = rig.finish(clips, contact, hits, skills, travel, {"sidestep"}, {
    currentTap = true, maelstromPalm = true, reefCurl = true, trenchRing = true, reefbreakerCross = true,
})
local poses = table.clone(standard)
local leftSupport = ready.RootJoint * ready["Left Hip"]

function poses.sample(action, age, direction)
    local offsets = standard.sample(action, age, direction)
    if action == "tidepoolToe" then
        offsets["Left Hip"] = offsets.RootJoint:ToObjectSpace(leftSupport)
    end
    return offsets
end

poses.TrenchRingHand = trenchHand
poses.UltimateSkill = table.freeze({
    trenchRing = table.freeze({damage = 31, radius = 2.48, center = trenchCenter, warningAt = .24}),
    reefbreakerCross = table.freeze({damage = table.freeze({13, 22}), radius = table.freeze({.46, .50})}),
})
return table.freeze(poses)
