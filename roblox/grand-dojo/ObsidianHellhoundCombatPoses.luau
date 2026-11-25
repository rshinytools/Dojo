-- Obsidian Hellhound keeps a low, narrow guard. Stampede is a planted howl
-- followed by a claw cue while the two summoned echoes run independently.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    local x = side * .435
    return {v(x - .28, .012, -.775), v(x + .28, .012, -.775),
        v(x - .28, .012, .205), v(x + .28, .012, .205)}
end

local rig = Choreography.new(rootHeight, {
    Neck = v(0, 3.13, -.045),
    ["Right Shoulder"] = v(.85, 2.99, .02), ["Left Shoulder"] = v(-.85, 2.99, .02),
    ["Right Hip"] = v(.435, 1.53, .04), ["Left Hip"] = v(-.435, 1.53, .04),
    TailJoint = v(0, 1.80, .59),
}, sole(1), sole(-1))
local pose = rig.pose

local rear = {9, -16, 0, .117, 0, .18, .018}
local lead = {13, 10, 0, -.079, 0, -.20, .018}
local rightGuard = {55, 12, -27, -.045, .079, -.032}
local leftGuard = {59, -15, 31, .064, .073, -.045}
local ready = pose({-.014, -.243, .016, -15, 5, 2}, rightGuard, leftGuard, rear, lead,
    {13, -4, -2}, {-17, 11, 6})
local breathe = pose({-.024, -.192, .025, -12, 3, 3}, {52, 9, -28, -.042, .072, -.027},
    {58, -18, 32, .064, .07, -.039}, rear, lead, {11, -2, -2}, {-17, -12, -5})
local stalkLead = pose({-.117, -.307, -.107, -22, 14, 7}, {62, 18, -25}, {41, -17, 25},
    rear, {26, 12, -3, -.115, 0, -.323, .132}, {20, -13, -6}, {-21, -32, -11})
local stalkRear = pose({.13, -.305, -.13, -22, -13, -8}, {44, 12, -21}, {63, -19, 27},
    {25, -19, 3, .123, 0, -.272, .138}, lead, {19, 12, 7}, {-22, 30, 9})
local springRear = pose({.11, -.219, .147, -10, 12, -7}, {52, 13, -25}, {66, -18, 27},
    {-15, -19, 3, .124, 0, .282, .134}, lead, {10, -10, 6}, {-18, 27, 9})
local springLead = pose({-.124, -.20, .128, -8, -10, 8}, {61, 16, -27}, {47, -16, 23},
    rear, {-10, 15, -2, -.13, 0, .255, .125}, {8, 8, -8}, {-17, -27, -9})
local dart = pose({.284, -.324, .012, -23, 11, -20}, {45, 13, -40}, {60, -16, 24, .065, .093, -.052},
    {7, -23, 6, .26, 0, .117, .146}, lead, {22, -9, 17}, {-25, 30, 10})
local brake = pose({.13, -.282, -.063, -17, 15, -9}, rightGuard, leftGuard,
    {9, -23, 2, .25, 0, .08, .018}, lead, {15, -12, 8}, {-19, -28, 8})

local jabLoad = pose({.062, -.276, .084, -18, -17, -5}, {34, 5, -36, .066, .023, .145},
    leftGuard, rear, lead, {17, 16, 4}, {-17, 15, 7})
local jabHit = pose({.037, -.212, -.238, -13, 28, -5}, {72, 18, -12, -.13, .096, -.248},
    leftGuard, rear, lead, {13, -26, 3}, {-18, -28, 9})
local crossLoad = pose({-.122, -.28, .12, -17, 25, 8}, rightGuard, {33, 7, 40, -.087, .027, .199},
    rear, lead, {17, -22, -7}, {-18, -30, -9})
local crossHit = pose({-.063, -.215, -.287, -15, -32, 5}, {59, 13, -29},
    {71, -22, 12, .153, .100, -.275}, rear, lead, {15, 29, -4}, {-18, 35, 8})
local bodyLoad = pose({.079, -.378, .095, -25, -24, -7}, {27, 7, -37, .11, -.03, .181},
    leftGuard, rear, lead, {24, 22, 6}, {-19, 22, -8})
local bodyHit = pose({.055, -.347, -.248, -23, 33, -2}, {59, 23, -8, -.145, -.049, -.243},
    {59, -19, 30}, rear, lead, {22, -29, 1}, {-20, -40, 9})
local heavyLoad = pose({-.134, -.35, .16, -25, 38, 11}, {58, 17, -24},
    {26, 15, 51, -.14, .049, .279}, rear, lead, {24, -35, -10}, {-21, -42, -9})
local heavyHit = pose({-.075, -.292, -.282, -22, -42, 7}, {46, 16, -33},
    {72, -30, 13, .192, .07, -.29}, rear, lead, {22, 38, -6}, {-22, 48, 11})
local heavyCarry = pose({-.103, -.315, -.151, -24, -47, 10}, rightGuard,
    {51, -41, 16, .169, .038, -.145}, rear, lead, {24, 42, -9}, {-23, 48, 10})

local lungeRear = {10, -14, 0, .12, 0, .26, .018}
local lungeLead = {17, 9, -1, -.09, 0, -.285, .018}
local lungeLoad = pose({-.03, -.45, .123, -28, 16, 5}, {51, 14, -31, -.06, .065, -.04},
    {26, 8, 38, -.09, .03, .23}, lungeRear, lead, {26, -13, -5}, {-25, -18, -7})
local lungeReach = pose({-.07, -.309, -.225, -25, -23, 6}, {43, 14, -20, .04, .06, .06},
    {70, -18, 9, .13, .061, -.235}, lungeRear,
    {28, 9, -1, -.09, 0, -.31, .10}, {21, 21, -6}, {-27, 21, 10})
local lungeHit = pose({-.092, -.265, -.334, -21, -30, 6}, {44, 14, -23, .05, .058, .083},
    {74, -25, 10, .177, .09, -.318}, lungeRear, lungeLead, {19, 27, -5}, {-25, 33, 10})
local lungeFollow = pose({-.104, -.335, -.229, -27, -38, 9}, {52, 16, -26},
    {57, -34, 18, .15, .064, -.194}, lungeRear, lungeLead, {24, 32, -8}, {-24, 39, 8})

local anchorRight = {6, -24, 0, .19, 0, .15, .018}
local anchorLeft = {9, 22, 0, -.18, 0, -.18, .018}
local inhale = pose({0, -.425, .119, -20, -7, 0}, {36, 8, -42, .09, .05, .117},
    {39, -7, 39, -.09, .05, .09}, anchorRight, anchorLeft, {16, 5, 2}, {-32, -6, -4})
local howl = pose({0, -.11, .048, 11, -9, -2}, {37, -9, -52, .076, .1, .093},
    {44, 11, 53, -.098, .1, .092}, anchorRight, anchorLeft, {32, 9, 2}, {-31, 12, -6})
local release = pose({.093, -.214, -.20, -16, 29, -5}, {69, 23, -19, -.17, .081, -.239},
    {37, -9, 46, -.065, .071, .09}, anchorRight, anchorLeft, {16, -25, 5}, {-23, -35, 9})
local callHold = pose({.06, -.239, -.127, -16, 19, -4}, {56, 15, -33, -.09, .074, -.085},
    {47, -14, 39, .024, .063, .015}, anchorRight, anchorLeft, {17, -17, 4}, {-24, -23, 6})
local watch = pose({0, -.291, -.055, -17, 1, 0}, {48, 10, -33, -.038, .07, -.033},
    {51, -12, 35, .053, .073, -.041}, anchorRight, anchorLeft, {17, -1, 0}, {-19, -5, 1})

local cover = pose({.003, -.34, .068, -18, 0, 0}, {66, 17, -19, -.109, .101, -.072},
    {67, -17, 19, .112, .10, -.074}, rear, lead, {17, 0, 0}, {-19, 7, 2})
local recoil = pose({-.07, -.326, .157, 4, -8, 8}, {60, 15, -21, -.093, .076, .058},
    {61, -15, 21, .11, .074, .057}, rear, lead, {-6, 7, -7}, {-19, 14, -8})
local deflect = pose({.068, -.31, -.137, -19, 26, -5}, {69, -1, -14, -.132, .145, -.133},
    {61, -17, 20, .07, .086, .028}, rear, lead, {18, -23, 4}, {-23, -28, 9})
local headHit = pose({-.106, -.30, .195, 14, -23, 12}, {38, 11, -26}, {43, -13, 24},
    rear, lead, {-21, 18, -11}, {-19, 23, -12})
local gutHit = pose({.094, -.45, .132, -27, 15, -9}, {31, 13, -24}, {39, -12, 24},
    rear, lead, {24, -14, 8}, {-20, -24, 9})
local salute = pose({.011, -.117, -.042, -2, -10, 4}, {76, 6, -21, -.065, .121, -.060},
    leftGuard, rear, lead, {3, 9, -4}, {-11, 17, -6})
local bow = pose({0, -.318, -.136, -26, 0, 0}, {36, 10, -27}, {37, -11, 26},
    rear, lead, {18, 0, 0}, {-15, 5, 0})
local victory = pose({0, -.08, .048, 8, 1, 0}, {67, -7, -45, .084, .092, .089},
    {67, 11, 47, -.083, .096, .086}, anchorRight, anchorLeft, {27, -1, 0}, {-30, 3, 0})

local contact = {jab = .161, cross = .224, body = .27, heavy = .411, cinderLunge = .28,
    hellfireStampede = table.freeze({.38, .57})}
local beat = contact.hellfireStampede
local clips = {
    stance = {{0, ready}, {.56, breathe}, {1.12, ready}},
    advance = {{0, ready}, {.145, stalkLead}, {.289, breathe}, {.443, stalkRear}, {.595, ready}},
    retreat = {{0, ready}, {.151, springRear}, {.304, breathe}, {.45, springLead}, {.62, ready}},
    sidestep = {{0, ready}, {.105, dart}, {.236, brake}, {.433, ready}},
    jab = {{0, ready}, {.071, jabLoad}, {contact.jab, jabHit}, {.209, jabHit}, {.407, ready}},
    cross = {{0, ready}, {.094, crossLoad}, {contact.cross, crossHit}, {.284, crossHit}, {.491, ready}},
    body = {{0, ready}, {.106, bodyLoad}, {contact.body, bodyHit}, {.371, breathe}, {.55, ready}},
    heavy = {{0, ready}, {.164, heavyLoad}, {.254, heavyLoad}, {contact.heavy, heavyHit},
        {.522, heavyCarry}, {.781, ready}},
    cinderLunge = {{0, ready}, {.116, lungeLoad}, {.208, lungeReach}, {contact.cinderLunge, lungeHit},
        {.363, lungeFollow}, {.48, breathe}, {.625, ready}},
    hellfireStampede = {{0, ready}, {.135, inhale}, {.216, inhale}, {.307, howl}, {beat[1], howl},
        {.432, howl}, {beat[2], release}, {.645, release}, {.775, callHold}, {1.13, watch}, {1.27, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.07, recoil}, {.149, recoil}, {.282, cover}},
    parry = {{0, cover}, {.079, deflect}, {.163, deflect}, {.333, ready}},
    hitHead = {{0, ready}, {.07, headHit}, {.148, headHit}, {.339, ready}},
    hitBody = {{0, ready}, {.081, gutHit}, {.168, gutHit}, {.363, ready}},
    stagger = {{0, headHit}, {.148, brake}, {.314, recoil}, {.528, ready}},
    intro = {{0, ready}, {.81, breathe}, {1.28, salute}, {2.01, salute}, {2.55, bow}, {3.02, ready},
        {3.81, lungeLoad}, {4.21, lungeHit}, {4.6, lungeFollow}, {5.08, ready},
        {5.84, inhale}, {6.38, howl}, {6.92, howl}, {7.35, release}, {7.92, watch}, {8.63, breathe}, {10, ready}},
    win = {{0, ready}, {.34, inhale}, {.62, victory}, {1.18, victory}, {1.55, bow}, {1.77, bow}, {2.12, ready}},
}

local rightPad, leftPad = v(1.01, 1.931, -.820), v(-1.01, 1.931, -.820)
local mouth = v(0, 3.618848, -1.286532)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    cinderLunge = {{lungeHit, "Left Shoulder", leftPad}},
    hellfireStampede = {{howl, "Neck", mouth}, {release, "Right Shoulder", rightPad}},
}
local skills = {
    cinderLunge = table.freeze({damage = 22, radius = .58, shove = .96}),
    hellfireStampede = table.freeze({damage = table.freeze({17, 17})}),
}
local travel = {cinderLunge = table.freeze({axis = "forward", distance = .40, startsAt = .14, endsAt = .27})}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
