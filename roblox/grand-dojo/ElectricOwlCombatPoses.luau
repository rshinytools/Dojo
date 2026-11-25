-- Electric Owl fights out of a narrow guard and opens its wings for committed attacks.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    return {v(side * .18, .010, -.73), v(side * .78, .010, -.73),
        v(side * .18, .010, .17), v(side * .78, .010, .17)}
end

local rig = Choreography.new(rootHeight, {
    Neck = v(0, 3.16, -.045),
    ["Right Shoulder"] = v(.935, 3.03, .055), ["Left Shoulder"] = v(-.935, 3.03, .055),
    ["Right Hip"] = v(.472, 1.50, .02), ["Left Hip"] = v(-.472, 1.50, .02),
    TailJoint = v(0, 1.76, .59),
}, sole(1), sole(-1))
local pose = rig.pose

local rightGuard, leftGuard = {51, 18, 13, -.060, .07, -.05}, {62, -14, -15, .07, .055, -.06}
local rear, lead = {7, -16, 0, .09, 0, .17, .018}, {8, 10, 0, -.055, 0, -.18, .018}
local ready = pose({.016, -.115, .045, -5, 10, -3}, rightGuard, leftGuard,
    rear, lead, {6, -10, 1}, {-5, -7, 2})
local breathe = pose({.028, -.075, .025, -2, 8, -2}, {55, 16, 15, -.055, .087, -.055}, leftGuard,
    rear, lead, {3, -8, 2}, {-3, -6, 2})
local stepLead = pose({-.092, -.17, -.125, -9, 11, 5}, {51, 20, 20}, leftGuard,
    rear, {12, 9, -3, -.09, 0, -.29, .18}, {10, -10, -4}, {-9, 10, -4})
local stepRear = pose({.13, -.145, -.148, -8, -3, -6}, rightGuard, {59, -18, -18},
    {11, -14, 3, .135, 0, -.25, .16}, lead, {8, 4, 4}, {-8, -13, 4})
local backLead = pose({-.11, -.14, .135, 2, 10, 4}, rightGuard, leftGuard,
    rear, {-12, 11, -2, -.105, 0, .23, .14}, {-2, -10, -3}, {-8, 13, -3})
local backRear = pose({.10, -.13, .155, 4, 0, -5}, rightGuard, leftGuard,
    {-12, -11, 3, .13, 0, .30, .158}, lead, {-4, 0, 4}, {-9, -13, 5})
local slip = pose({.24, -.235, .035, -10, 14, -25}, {34, 12, 49}, {69, -25, -18},
    {10, -17, 4, .27, 0, .19, .17}, lead, {12, -15, 19}, {-13, 22, -14})
local catch = pose({.18, -.20, -.035, -6, 19, -9}, {41, 14, 28}, leftGuard,
    {5, -17, 1, .23, 0, .08, .018}, lead, {7, -18, 7}, {-12, -11, -6})

local jabLoad = pose({.028, -.15, .082, -6, 4, -3}, {29, -14, 19, .04, .035, .13},
    leftGuard, rear, lead, {6, -4, 2}, {-8, 11, 2})
local jabHit = pose({.03, -.09, -.20, -6, 22, -2}, {67, 21, -12, -.10, .075, -.18},
    leftGuard, rear, lead, {6, -22, 1}, {-7, -19, 3})
local crossLoad = pose({-.04, -.18, .10, -9, 23, 5}, rightGuard, {31, -6, -22, -.06, .035, .21},
    rear, lead, {9, -22, -3}, {-9, -21, -4})
local crossHit = pose({-.04, -.12, -.22, -8, -25, 2}, rightGuard, {69, -21, 11, .15, .07, -.20},
    rear, lead, {8, 25, -2}, {-8, 23, 3})
local bodyLoad = pose({.025, -.32, .087, -15, -16, -6}, {25, -18, 28, .09, .04, .13},
    leftGuard, rear, lead, {14, 16, 4}, {-8, 15, 5})
local bodyHit = pose({.04, -.31, -.24, -14, 19, -2}, {55, 23, -10, -.125, -.065, -.18},
    leftGuard, rear, lead, {13, -18, 2}, {-9, -18, -3})
local heavyLoad = pose({-.12, -.28, .14, -14, 39, 9}, {46, 15, 17},
    {14, -42, -57, -.10, .055, .12}, rear, lead, {13, -36, -7}, {-9, -33, -8})
local heavyHit = pose({-.06, -.165, -.25, -9, -31, 6}, {54, 30, 18},
    {69, -25, 14, .13, .09, -.22}, rear, lead, {9, 27, -5}, {-8, 34, 6})
local heavyEase = pose({-.06, -.22, -.17, -14, -42, 8}, rightGuard, {54, -29, 17, .115, .01, -.13},
    rear, lead, {14, 37, -6}, {-13, 43, 7})

local wingOpen = pose({-.01, -.15, .105, -4, -27, -7}, {20, -39, 69, .10, .09, .06},
    {63, -25, -16, .12, .07, -.08}, rear, lead, {5, 27, 7}, {-11, 22, -7})
local wingDrive = pose({.025, -.135, -.105, -7, 5, 2}, {53, 0, 40, .02, .095, -.12},
    leftGuard, rear, lead, {7, -5, -1}, {-8, -7, 3})
local wingHit = pose({.015, -.155, -.245, -8, 32, 4}, {69, 17, -5, -.12, .13, -.23},
    {56, -19, -22, .05, .03, .01}, rear, lead, {10, -30, -2}, {-10, -35, 7})
local wingFollow = pose({-.07, -.255, -.12, -11, 43, 7}, {56, 37, -17, -.17, .06, -.11},
    leftGuard, rear, lead, {11, -36, -5}, {-14, -41, 12})

local blinkCrouch = pose({0, -.39, .115, -18, 0, 0}, {30, -16, 47}, {29, 19, -45},
    {11, -19, 0, .10, 0, .20, .018}, {11, 17, 0, -.075, 0, -.14, .018}, {18, 0, 0}, {-20, 0, 0})
local wingLaunch = pose({.02, .47, -.055, -8, 0, 3}, {46, -14, 61}, {45, 15, -59},
    {14, -13, 0, .05, 0, .17, .58}, {16, 10, 0, -.06, 0, -.18, .66}, {9, 0, -2}, {-17, 0, 0})
local diveTuck = pose({0, .88, -.08, -30, 0, 0}, {31, -10, 25, -.07, .06, .19},
    {31, 10, -25, .07, .06, .19}, {32, -10, 0, .06, .14, .20, .81},
    {34, 10, 0, -.06, .14, .11, .81}, {27, 0, 0}, {-22, 0, 0})
local diveExtend = pose({0, .38, -.15, -33, 0, 0}, {29, -9, 49}, {29, 9, -50},
    {43, -9, 0, .07, 0, -.23, .26}, {46, 9, 0, -.07, 0, -.26, .26}, {29, 0, 0}, {-25, 0, 0})
local diveLand = pose({0, -.40, -.19, -25, 0, 0}, {35, -22, 66}, {35, 22, -66},
    {13, -4, 0, .12, 0, -.08, .018}, {13, 4, 0, -.12, 0, -.08, .018},
    {26, 0, 0}, {-22, 0, 0})
local diveEase = pose({0, -.265, -.07, -10, 0, 0}, {47, -9, 34}, {46, 9, -34},
    rear, lead, {11, 0, 0}, {-13, 0, 0})

local cover = pose({0, -.22, .052, -10, 0, 0}, {73, 23, -11, -.135, .11, -.09},
    {76, -19, 11, .10, .09, -.07}, rear, lead, {8, 0, 0}, {-13, 0, 0})
local recoil = pose({-.055, -.20, .14, 9, -9, 6}, {65, 13, -2, -.1, .08, .035},
    {65, -9, 2, .10, .09, .035}, rear, lead, {-10, 9, -6}, {-10, 4, -5})
local deflect = pose({.068, -.15, -.11, -9, 25, -6}, {67, 10, 25, -.08, .135, -.09},
    {61, -18, -12}, rear, lead, {9, -24, 5}, {-12, -23, 8})
local headHit = pose({-.095, -.18, .13, 16, -15, 12}, {41, 3, 38}, {34, -9, -39},
    rear, lead, {-15, 12, -10}, {-10, 13, -12})
local gutHit = pose({.093, -.34, .16, -22, 16, -11}, {39, 20, 24}, {42, -20, -24},
    rear, lead, {13, -15, 8}, {-11, -15, 11})
local bow = pose({0, -.225, -.10, -24, 0, 0}, {40, 15, 12}, {39, -15, -12},
    rear, lead, {14, 0, 0}, {-15, 0, 0})
local spread = pose({0, -.04, -.025, 0, 0, 0}, {55, -11, 91}, {53, 11, -91},
    rear, lead, {-5, 0, 0}, {-12, 0, 0})
local salute = pose({.045, -.09, -.02, -4, 18, -4}, {54, -21, 81}, {63, -18, -10},
    rear, lead, {3, -18, 3}, {-8, -14, 3})

local contact = {jab = .159, cross = .219, body = .268, heavy = .411, wingSweep = .28, thunderDive = .66}
local clips = {
    stance = {{0, ready}, {.52, breathe}, {1.04, ready}},
    advance = {{0, ready}, {.14, stepLead}, {.28, ready}, {.43, stepRear}, {.58, ready}},
    retreat = {{0, ready}, {.16, backRear}, {.32, ready}, {.49, backLead}, {.65, ready}},
    sidestep = {{0, ready}, {.104, slip}, {.226, catch}, {.43, ready}},
    jab = {{0, ready}, {.067, jabLoad}, {contact.jab, jabHit}, {.215, jabHit}, {.405, ready}},
    cross = {{0, ready}, {.097, crossLoad}, {contact.cross, crossHit}, {.305, crossHit}, {.50, ready}},
    body = {{0, ready}, {.121, bodyLoad}, {contact.body, bodyHit}, {.379, breathe}, {.56, ready}},
    heavy = {{0, ready}, {.185, heavyLoad}, {.282, heavyLoad}, {contact.heavy, heavyHit}, {.532, heavyEase}, {.79, ready}},
    wingSweep = {{0, ready}, {.133, wingOpen}, {.219, wingDrive}, {contact.wingSweep, wingHit},
        {.377, wingFollow}, {.528, breathe}, {.63, ready}},
    thunderDive = {{0, ready}, {.16, blinkCrouch}, {.24, blinkCrouch}, {.36, wingLaunch}, {.47, diveTuck},
        {.57, diveExtend}, {contact.thunderDive, diveLand}, {.77, diveLand}, {.89, diveEase}, {1.08, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.08, recoil}, {.157, recoil}, {.268, cover}},
    parry = {{0, cover}, {.083, deflect}, {.16, deflect}, {.32, ready}},
    hitHead = {{0, ready}, {.074, headHit}, {.165, headHit}, {.33, ready}},
    hitBody = {{0, ready}, {.083, gutHit}, {.178, gutHit}, {.35, ready}},
    stagger = {{0, headHit}, {.16, catch}, {.32, recoil}, {.54, ready}},
    intro = {{0, ready}, {.85, breathe}, {1.48, salute}, {2.18, salute}, {2.72, bow}, {3.26, ready},
        {4.09, wingOpen}, {4.58, spread}, {5.10, spread}, {5.68, ready},
        {6.49, blinkCrouch}, {6.95, diveEase}, {7.34, ready}, {8.82, breathe}, {10, ready}},
    win = {{0, ready}, {.31, spread}, {.93, spread}, {1.21, bow}, {1.51, bow}, {1.98, ready}},
}

local rightWing, leftWing = v(1.185, 1.96, -.7335), v(-1.185, 1.96, -.7335)
local talons = v(.48, .010, -.73)
local landing = diveLand.RootJoint:PointToWorldSpace(
    (diveLand["Right Hip"]:PointToWorldSpace(talons - v(0, rootHeight, 0))
        + diveLand["Left Hip"]:PointToWorldSpace(v(-talons.X, talons.Y - rootHeight, talons.Z))) / 2)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightWing}}, cross = {{crossHit, "Left Shoulder", leftWing}},
    body = {{bodyHit, "Right Shoulder", rightWing}}, heavy = {{heavyHit, "Left Shoulder", leftWing}},
    wingSweep = {{wingHit, "Right Shoulder", rightWing}}, thunderDive = {landing},
}
local skills = {
    wingSweep = table.freeze({damage = 18, radius = .57, shove = .67}),
    thunderDive = table.freeze({damage = 24, shove = .66, stun = 1.20}),
}
local travel = {
    wingSweep = table.freeze({axis = "forward", distance = .30, startsAt = .15, endsAt = .26}),
    thunderDive = table.freeze({axis = "forward", distance = 5.60, startsAt = .24, endsAt = .66}),
}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
