-- Honey Badger coils under the guard, then drives back through it with alternating paws.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {v(side * .165, .014, -.81), v(side * .795, .014, -.81),
        v(side * .165, .014, .21), v(side * .795, .014, .21)}
end

local rig = Choreography.new(2.132, {
    Neck = v(0, 3.02, -.07),
    ["Right Shoulder"] = v(.96, 2.92, .055), ["Left Shoulder"] = v(-.96, 2.92, .055),
    ["Right Hip"] = v(.48, 1.46, .025), ["Left Hip"] = v(-.48, 1.46, .025),
    TailJoint = v(0, 1.66, .59),
}, sole(1), sole(-1))
local pose = rig.pose

local rear, lead = {7, -15, 0, .105, 0, .18, .018}, {10, 12, 0, -.09, 0, -.20, .018}
local rightGuard = {48, 17, -27, -.045, .08, -.025}
local leftGuard = {57, -18, 24, .065, .09, -.035}
local ready = pose({.025, -.27, .025, -17, 11, -5}, rightGuard, leftGuard, rear, lead,
    {17, -11, 4}, {-11, -12, 4})
local breathe = pose({.045, -.215, .022, -13, 9, -3}, {48, 14, -25, -.04, .095, -.025},
    leftGuard, rear, lead, {14, -9, 2}, {-10, -8, 3})
local advanceLead = pose({-.10, -.29, -.11, -19, 12, 7}, rightGuard, {53, -18, 25, .055, .085, .035},
    rear, {18, 12, -3, -.13, 0, -.31, .15}, {19, -11, -6}, {-13, 22, -6})
local advanceRear = pose({.115, -.275, -.12, -18, -5, -8}, {46, 12, -24, -.025, .045, .02},
    leftGuard, {17, -15, 3, .14, 0, -.26, .14}, lead, {18, 5, 7}, {-13, -24, 7})
local retreatLead = pose({-.115, -.21, .115, -7, 16, 5}, rightGuard, leftGuard,
    rear, {-13, 12, -2, -.11, 0, .30, .13}, {8, -15, -4}, {-13, 22, -5})
local retreatRear = pose({.115, -.245, .128, -5, -2, -6}, rightGuard, leftGuard,
    {-11, -14, 3, .13, 0, .30, .135}, lead, {6, 2, 5}, {-12, -20, 6})
local skid = pose({.30, -.33, .052, -16, 8, -21}, {35, 12, -46}, {64, -23, 20, .07, .09, -.055},
    {13, -17, 5, .27, 0, .14, .155}, lead, {17, -8, 15}, {-12, 22, -10})
local catch = pose({.17, -.31, -.055, -14, 15, -8}, rightGuard, leftGuard,
    {8, -20, 2, .22, 0, .10, .018}, lead, {15, -15, 8}, {-10, -17, 5})

local jabWind = pose({.050, -.29, .105, -19, -11, -6}, {25, -8, -27, .07, .04, .17},
    leftGuard, rear, lead, {20, 11, 5}, {-12, 15, -4})
local jabHit = pose({.016, -.20, -.235, -12, 23, -3}, {67, 19, -13, -.14, .12, -.205},
    leftGuard, rear, lead, {13, -22, 3}, {-10, -24, 4})
local crossWind = pose({-.11, -.325, .12, -21, 23, 9}, rightGuard, {23, 8, 28, -.065, .025, .245},
    rear, lead, {21, -23, -7}, {-13, -24, -7})
local crossHit = pose({-.055, -.23, -.25, -14, -26, 5}, rightGuard,
    {69, -19, 14, .145, .073, -.23}, rear, lead, {15, 25, -4}, {-13, 27, 5})
local bodyWind = pose({.065, -.42, .086, -24, -23, -8}, {27, 5, -35, .07, -.045, .18},
    leftGuard, rear, lead, {24, 21, 6}, {-14, 20, -5})
local bodyHit = pose({.055, -.38, -.25, -24, 25, -2}, {56, 22, -10, -.125, -.07, -.235},
    leftGuard, rear, lead, {24, -22, 2}, {-14, -26, 6})
local heavyWind = pose({-.12, -.40, .11, -21, 36, 11}, {62, 24, -19, -.08, .09, -.035},
    {16, 12, 48, -.12, .04, .28}, rear, lead, {22, -32, -8}, {-14, -38, -9})
local heavyHit = pose({-.05, -.25, -.28, -15, -31, 7}, {42, 14, -26},
    {67, -28, 12, .175, .11, -.245}, rear, lead, {16, 29, -5}, {-16, 35, 8})
local heavyCarry = pose({-.08, -.31, -.15, -21, -43, 9}, rightGuard, {50, -37, 15, .13, .055, -.10},
    rear, lead, {20, 38, -7}, {-15, 48, 10})

local hookDuck = pose({.09, -.47, .11, -24, -32, -10}, {22, -15, -39, .095, -.025, .20},
    {60, -17, 20, .075, .075, -.03}, rear, lead, {23, 28, 8}, {-17, 24, -8})
local hookRise = pose({.038, -.37, -.09, -21, -9, -4}, {43, -2, -36, .055, .04, -.11},
    leftGuard, rear, lead, {20, 9, 3}, {-12, 12, -4})
local hookHit = pose({.023, -.27, -.25, -12, 28, 3}, {64, 32, -15, -.155, .10, -.245},
    {56, -26, 22, .085, .083, .035}, rear, lead, {13, -26, -2}, {-14, -28, 6})
local hookFollow = pose({-.03, -.225, -.11, -6, 42, 5}, {76, 44, -11, -.18, .16, -.135},
    leftGuard, rear, lead, {8, -37, -4}, {-14, -35, 8})

local frenzyRear = {8, -22, -1, .14, 0, .18, .018}
local frenzyLead = {10, 22, 1, -.14, 0, -.23, .018}
local frenzyWind = pose({.055, -.40, .105, -25, -29, -6}, {30, -31, -54, .09, .045, .17},
    {59, -19, 25, .075, .08, -.02}, frenzyRear, frenzyLead, {23, 24, 4}, {-15, 23, -7})
local firstSwipe = pose({.05, -.29, -.21, -18, 27, -4}, {58, 21, -27, -.145, .068, -.22},
    {31, 7, 41, -.01, .05, .17}, frenzyRear, frenzyLead, {17, -24, 3}, {-15, -28, 7})
local secondSwipe = pose({-.04, -.26, -.28, -14, -29, 4}, {29, -5, -43, .04, .05, .18},
    {74, -27, 14, .14, .135, -.18}, frenzyRear, frenzyLead, {14, 26, -2}, {-15, 30, -7})
local thirdSwipe = pose({.06, -.41, -.26, -26, 27, -7}, {53, 26, -11, -.16, -.06, -.23},
    {32, 6, 35, -.025, .05, .17}, frenzyRear, frenzyLead, {26, -24, 6}, {-16, -31, 8})
local finalSwipe = pose({-.08, -.17, -.225, -11, -35, 5}, {56, 21, -19, -.10, .10, -.03},
    {83, -21, 12, .19, .16, -.29}, frenzyRear, frenzyLead, {11, 32, -3}, {-14, 36, -7})
local frenzySettle = pose({-.08, -.33, -.17, -22, -42, 8}, {44, 11, -24}, {67, -38, 13, .17, .06, -.095},
    frenzyRear, frenzyLead, {21, 36, -7}, {-13, 43, -8})

local cover = pose({0, -.35, .06, -18, 0, 0}, {67, 24, -30, -.13, .08, -.09},
    {69, -23, 29, .125, .085, -.08}, rear, lead, {18, 0, 0}, {-13, 0, 0})
local recoil = pose({-.055, -.29, .17, 7, -12, 8}, {62, 13, -29, -.095, .085, .085},
    {62, -15, 27, .09, .075, .08}, rear, lead, {-8, 11, -6}, {-12, 17, -8})
local deflect = pose({.055, -.32, -.095, -16, 30, -7}, {67, 9, -48, -.105, .10, -.075},
    {58, -14, 23, .06, .05, -.01}, rear, lead, {15, -26, 6}, {-14, -28, 8})
local headHit = pose({-.09, -.24, .155, 14, -23, 12}, {32, 5, -31}, {30, -8, 33},
    rear, lead, {-18, 20, -10}, {-16, 22, -10})
local gutHit = pose({.095, -.45, .17, -29, 17, -12}, {39, 14, -26}, {38, -12, 29},
    rear, lead, {27, -15, 9}, {-16, -19, 10})
local bow = pose({0, -.33, -.10, -30, 0, 0}, {40, 12, -20}, {40, -12, 21},
    rear, lead, {18, 0, 0}, {-13, 0, 0})
local knuckleSalute = pose({.055, -.12, -.05, -3, 17, -4}, {77, 18, -15, -.10, .13, -.06},
    {59, -20, 18, .07, .09, -.045}, rear, lead, {5, -16, 3}, {-10, -16, 4})
local broadRaise = pose({0, -.075, -.035, 4, 0, 0}, {74, -18, -44, .055, .15, -.08},
    {74, 18, 44, -.06, .14, -.07}, rear, lead, {-2, 0, 0}, {-12, 0, 0})

local contact = {jab = .159, cross = .228, body = .275, heavy = .421,
    burrowHook = .29, unstoppableFrenzy = table.freeze({.28, .48, .69, .92})}
local swipe = contact.unstoppableFrenzy
local clips = {
    stance = {{0, ready}, {.59, breathe}, {1.18, ready}},
    advance = {{0, ready}, {.151, advanceLead}, {.30, ready}, {.449, advanceRear}, {.60, ready}},
    retreat = {{0, ready}, {.166, retreatRear}, {.33, ready}, {.494, retreatLead}, {.658, ready}},
    sidestep = {{0, ready}, {.108, skid}, {.235, catch}, {.462, ready}},
    jab = {{0, ready}, {.073, jabWind}, {contact.jab, jabHit}, {.227, jabHit}, {.423, ready}},
    cross = {{0, ready}, {.10, crossWind}, {contact.cross, crossHit}, {.308, crossHit}, {.510, ready}},
    body = {{0, ready}, {.123, bodyWind}, {contact.body, bodyHit}, {.391, breathe}, {.563, ready}},
    heavy = {{0, ready}, {.171, heavyWind}, {.276, heavyWind}, {contact.heavy, heavyHit},
        {.53, heavyCarry}, {.817, ready}},
    burrowHook = {{0, ready}, {.14, hookDuck}, {.213, hookRise}, {contact.burrowHook, hookHit},
        {.394, hookFollow}, {.518, breathe}, {.654, ready}},
    unstoppableFrenzy = {{0, ready}, {.14, frenzyWind}, {.21, frenzyWind}, {swipe[1], firstSwipe},
        {.327, firstSwipe}, {swipe[2], secondSwipe}, {.527, secondSwipe}, {swipe[3], thirdSwipe},
        {.741, thirdSwipe}, {swipe[4], finalSwipe}, {1.07, frenzySettle}, {1.31, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.082, recoil}, {.16, recoil}, {.28, cover}},
    parry = {{0, cover}, {.088, deflect}, {.165, deflect}, {.332, ready}},
    hitHead = {{0, ready}, {.074, headHit}, {.169, headHit}, {.351, ready}},
    hitBody = {{0, ready}, {.084, gutHit}, {.183, gutHit}, {.376, ready}},
    stagger = {{0, headHit}, {.17, catch}, {.326, recoil}, {.566, ready}},
    intro = {{0, ready}, {.85, breathe}, {1.46, knuckleSalute}, {2.04, knuckleSalute}, {2.50, bow},
        {3.08, ready}, {4.02, hookDuck}, {4.37, hookRise}, {4.63, hookFollow}, {5.19, ready},
        {6.16, frenzyWind}, {6.61, firstSwipe}, {7.0, secondSwipe}, {7.42, frenzySettle},
        {7.98, ready}, {8.76, breathe}, {10, ready}},
    win = {{0, ready}, {.31, broadRaise}, {.95, broadRaise}, {1.23, bow}, {1.56, bow}, {2, ready}},
}

local rightPad, leftPad = v(1.17, 1.86, -.86), v(-1.17, 1.86, -.86)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    burrowHook = {{hookHit, "Right Shoulder", rightPad}},
    unstoppableFrenzy = {
        {firstSwipe, "Right Shoulder", rightPad}, {secondSwipe, "Left Shoulder", leftPad},
        {thirdSwipe, "Right Shoulder", rightPad}, {finalSwipe, "Left Shoulder", leftPad},
    },
}
local skills = {
    burrowHook = table.freeze({damage = 20, radius = .60, shove = .85}),
    unstoppableFrenzy = table.freeze({damage = table.freeze({6, 6, 6, 6}), immunity = 5}),
}
local travel = {
    burrowHook = table.freeze({axis = "forward", distance = .40, startsAt = .17, endsAt = .28}),
}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
