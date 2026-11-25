-- Emerald Saber-Tooth loads from a long stance and drops its leading paw through the landing.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {v(side * .18, .014, -.86), v(side * .88, .014, -.86),
        v(side * .18, .014, .22), v(side * .88, .014, .22)}
end

local rig = Choreography.new(2.132, {
    Neck = v(0, 3.12, -.09),
    ["Right Shoulder"] = v(1.015, 3.04, .055), ["Left Shoulder"] = v(-1.015, 3.04, .055),
    ["Right Hip"] = v(.52, 1.54, .035), ["Left Hip"] = v(-.52, 1.54, .035),
    TailJoint = v(0, 1.72, .63),
}, sole(1), sole(-1))
local pose = rig.pose

local rear, lead = {7, -20, 0, .11, 0, .25, .018}, {12, 15, 0, -.09, 0, -.25, .018}
local rightGuard = {39, 12, -26, .035, .07, .055}
local leftGuard = {60, -25, 18, .12, .105, -.075}
local ready = pose({.045, -.19, .035, -9, -14, 4}, rightGuard, leftGuard, rear, lead,
    {9, 14, -3}, {-8, 23, 3})
local breathe = pose({.04, -.145, .020, -6, -11, 3}, {42, 12, -24, .04, .085, .04},
    leftGuard, rear, lead, {7, 11, -2}, {-7, 15, 2})
local springLead = pose({-.14, -.235, -.175, -13, -15, 9}, {32, 11, -28, .025, .08, .105},
    leftGuard, rear, {22, 17, -3, -.115, 0, -.40, .195}, {13, 14, -6}, {-9, -18, -5})
local springRear = pose({.138, -.215, -.151, -12, -5, -8}, rightGuard,
    {51, -22, 18, .09, .10, .005}, {19, -16, 3, .15, 0, -.37, .17}, lead, {12, 5, 7}, {-14, 29, 7})
local backLead = pose({-.115, -.195, .125, 4, -15, 7}, rightGuard, leftGuard,
    rear, {-14, 13, -3, -.13, 0, .30, .13}, {-5, 15, -5}, {-15, -23, -4})
local backRear = pose({.14, -.23, .146, 6, -2, -7}, rightGuard, leftGuard,
    {-13, -17, 2, .13, 0, .36, .15}, lead, {-6, 2, 6}, {-14, 29, 6})
local slip = pose({.31, -.245, .040, -12, -17, -24}, {30, 13, -53, .051, .08, .10},
    {64, -24, 20, .12, .12, -.045}, {13, -21, 4, .30, 0, .15, .16}, lead,
    {12, 17, 18}, {-12, -33, -14})
local set = pose({.20, -.26, -.085, -12, -5, -8}, rightGuard, leftGuard,
    {7, -19, 1, .24, 0, .11, .018}, lead, {12, 5, 7}, {-13, 36, 7})

local jabWind = pose({.046, -.205, .095, -12, -22, -4}, {26, 6, -29, .07, .05, .17},
    leftGuard, rear, lead, {12, 22, 4}, {-11, 24, -5})
local jabHit = pose({.018, -.125, -.232, -7, 22, -2}, {69, 18, -12, -.15, .105, -.22},
    leftGuard, rear, lead, {8, -22, 2}, {-10, -28, 6})
local crossWind = pose({-.083, -.245, .10, -14, 24, 7}, rightGuard, {24, 7, 28, -.08, .075, .25},
    rear, lead, {14, -24, -6}, {-10, -29, -7})
local crossHit = pose({-.045, -.145, -.265, -9, -29, 5}, rightGuard,
    {71, -20, 12, .17, .085, -.23}, rear, lead, {9, 28, -4}, {-12, 32, 6})
local bodyWind = pose({.062, -.385, .095, -22, -22, -7}, {16, 4, -38, .066, -.055, .20},
    leftGuard, rear, lead, {21, 21, 6}, {-13, 24, -7})
local bodyHit = pose({.016, -.33, -.29, -21, 24, -2}, {55, 23, -13, -.137, -.075, -.24},
    leftGuard, rear, lead, {21, -23, 2}, {-14, -27, 6})
local heavyWind = pose({-.14, -.34, .19, -16, 40, 12}, {57, 25, -19, -.075, .095, -.025},
    {13, -2, 45, -.13, .027, .30}, rear, lead, {16, -36, -8}, {-13, -43, -8})
local heavyHit = pose({-.085, -.21, -.32, -10, -31, 6}, {43, 17, -29},
    {70, -22, 11, .17, .085, -.25}, rear, lead, {10, 29, -5}, {-13, 42, 8})
local heavyFollow = pose({-.10, -.29, -.17, -12, -43, 9}, rightGuard, {56, -35, 16, .12, .044, -.10},
    rear, lead, {13, 39, -8}, {-13, 50, 9})

local rakeWind = pose({.025, -.22, .095, -7, 35, 7}, {39, 15, -29, .045, .08, .11},
    {45, 30, 58, -.13, .095, .135}, rear, lead, {7, -30, -6}, {-12, -31, -7})
local rakeStart = pose({.005, -.32, -.06, -14, 8, 2}, rightGuard,
    {78, -10, 23, .040, .195, -.08}, rear, lead, {13, -7, -2}, {-10, -6, 2})
local rakeHit = pose({-.075, -.225, -.275, -12, -32, 6}, {42, 12, -25},
    {68, -29, 8, .175, .045, -.235}, rear, lead, {12, 29, -5}, {-14, 42, 8})
local rakeFollow = pose({-.13, -.315, -.15, -20, -47, 11}, rightGuard,
    {47, -39, 15, .14, -.015, -.13}, rear, lead, {21, 41, -8}, {-14, 54, 12})

local squatRear, squatLead = {13, -15, 0, .14, 0, .23, .018}, {15, 13, 0, -.15, 0, -.19, .018}
local coil = pose({0, -.43, .23, -26, 0, 0}, {27, 15, -35, .065, .04, .16},
    {28, -15, 35, -.075, .035, .15}, squatRear, squatLead, {23, 0, 0}, {-21, -13, 0})
local spring = pose({.028, .36, -.11, -17, 8, -4}, {53, 17, -49, -.08, .09, -.035},
    {48, -12, 43, .08, .115, .055}, {25, -13, 1, .105, 0, .27, .52},
    {27, 12, -1, -.10, 0, -.09, .56}, {16, -8, 3}, {-17, 22, -4})
local blink = pose({.015, .67, -.16, -26, 4, -2}, {77, 13, -38, -.075, .10, -.09},
    {58, -14, 41, .075, .12, .04}, {28, -12, 1, .105, .11, .21, .74},
    {32, 9, -1, -.105, .11, .05, .74}, {24, -4, 2}, {-27, 15, -5})
local reach = pose({.038, .245, -.24, -28, 13, -3}, {60, 17, -22, -.09, -.10, -.20},
    {46, -19, 40, .05, .085, -.03}, {19, -13, 3, .115, 0, .11, .25},
    {32, 7, -2, -.11, 0, -.13, .25}, {25, -12, 2}, {-23, -11, -4})
local land = pose({.035, -.42, -.25, -30, 18, 3}, {50, 20, -18, -.125, -.41, -.21},
    {37, -23, 43, .055, .055, -.04}, {15, -13, 0, .17, 0, .095, .018},
    {19, 10, 0, -.17, 0, -.30, .018}, {27, -17, -2}, {-25, -23, 6})
local landRecover = pose({.035, -.31, -.145, -21, 13, 3}, {44, 16, -25, -.06, -.18, -.115},
    leftGuard, rear, lead, {20, -12, -2}, {-16, -15, 5})

local cover = pose({0, -.275, .066, -12, -6, 0}, {66, 24, -23, -.13, .12, -.080},
    {74, -21, 19, .12, .10, -.085}, rear, lead, {12, 6, 0}, {-15, 11, 3})
local recoil = pose({-.065, -.255, .15, 9, -13, 4}, {62, 17, -26, -.06, .082, .10},
    {67, -18, 22, .115, .09, .055}, rear, lead, {-11, 12, -4}, {-15, 24, 7})
local deflect = pose({.058, -.24, -.12, -12, 25, -6}, {63, 10, -44, -.08, .145, -.12},
    {62, -19, 18, .11, .10, -.015}, rear, lead, {11, -24, 5}, {-14, -24, 10})
local headHit = pose({-.098, -.21, .16, 14, -24, 11}, {32, 12, -32}, {30, -10, 34},
    rear, lead, {-16, 21, -8}, {-17, 28, -11})
local gutHit = pose({.10, -.425, .158, -25, 17, -10}, {39, 17, -23}, {41, -14, 25},
    rear, lead, {23, -16, 7}, {-14, -26, 9})
local bow = pose({0, -.22, -.10, -25, -6, 0}, {32, 15, -29}, {36, -15, 27},
    rear, lead, {15, 6, 0}, {-13, 8, 2})
local clawSalute = pose({-.035, -.115, -.031, -2, -18, 5}, rightGuard,
    {78, -12, 48, .085, .17, -.095}, rear, lead, {3, 17, -3}, {-11, 24, 6})
local crestRaise = pose({.048, -.055, -.08, 3, -3, 1}, {68, 8, -51, .04, .15, -.04},
    {75, -6, 50, -.04, .15, -.07}, rear, lead, {-3, 3, -1}, {-10, 11, 3})

local contact = {jab = .155, cross = .218, body = .268, heavy = .413, jadeRake = .31, apexPounce = .54}
local teleportAt = .41
local clips = {
    stance = {{0, ready}, {.55, breathe}, {1.10, ready}},
    advance = {{0, ready}, {.139, springLead}, {.277, ready}, {.414, springRear}, {.555, ready}},
    retreat = {{0, ready}, {.154, backRear}, {.31, ready}, {.461, backLead}, {.617, ready}},
    sidestep = {{0, ready}, {.102, slip}, {.219, set}, {.44, ready}},
    jab = {{0, ready}, {.067, jabWind}, {contact.jab, jabHit}, {.211, jabHit}, {.411, ready}},
    cross = {{0, ready}, {.09, crossWind}, {contact.cross, crossHit}, {.302, crossHit}, {.498, ready}},
    body = {{0, ready}, {.118, bodyWind}, {contact.body, bodyHit}, {.377, breathe}, {.550, ready}},
    heavy = {{0, ready}, {.18, heavyWind}, {.266, heavyWind}, {contact.heavy, heavyHit},
        {.524, heavyFollow}, {.795, ready}},
    jadeRake = {{0, ready}, {.15, rakeWind}, {.229, rakeStart}, {contact.jadeRake, rakeHit},
        {.416, rakeFollow}, {.567, breathe}, {.676, ready}},
    apexPounce = {{0, ready}, {.19, coil}, {.30, coil}, {.365, spring}, {teleportAt, blink},
        {.474, reach}, {contact.apexPounce, land}, {.65, land}, {.79, landRecover}, {1.03, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.085, recoil}, {.161, recoil}, {.276, cover}},
    parry = {{0, cover}, {.087, deflect}, {.162, deflect}, {.323, ready}},
    hitHead = {{0, ready}, {.075, headHit}, {.167, headHit}, {.341, ready}},
    hitBody = {{0, ready}, {.085, gutHit}, {.185, gutHit}, {.368, ready}},
    stagger = {{0, headHit}, {.16, set}, {.308, recoil}, {.538, ready}},
    intro = {{0, ready}, {.84, breathe}, {1.48, clawSalute}, {2.12, clawSalute}, {2.65, bow}, {3.13, ready},
        {4.0, rakeWind}, {4.39, rakeStart}, {4.67, rakeFollow}, {5.25, ready}, {6.23, coil},
        {6.78, landRecover}, {7.29, crestRaise}, {7.82, ready}, {8.91, breathe}, {10, ready}},
    win = {{0, ready}, {.32, crestRaise}, {.97, crestRaise}, {1.24, bow}, {1.55, bow}, {2.06, ready}},
}

local rightPad, leftPad = v(1.255, 1.865, -.915), v(-1.255, 1.865, -.915)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    jadeRake = {{rakeHit, "Left Shoulder", leftPad}}, apexPounce = {{land, "Right Shoulder", rightPad}},
}
local skills = {
    jadeRake = table.freeze({damage = 21, radius = .61, shove = .96}),
    apexPounce = table.freeze({damage = 26, teleportAt = teleportAt}),
}
local travel = {
    jadeRake = table.freeze({axis = "forward", distance = .33, startsAt = .18, endsAt = .30}),
}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
