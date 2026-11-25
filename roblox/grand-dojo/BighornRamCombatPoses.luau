-- Bighorn Ram sets a wide stance and lowers the horns before committing to a charge.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    return {v(side * .175, .010, -.835), v(side * .925, .010, -.835),
        v(side * .175, .010, .225), v(side * .925, .010, .225)}
end

local rig = Choreography.new(rootHeight, {
    Neck = v(0, 3.23, -.05),
    ["Right Shoulder"] = v(1.035, 3.01, .09), ["Left Shoulder"] = v(-1.035, 3.01, .09),
    ["Right Hip"] = v(.56, 1.53, .04), ["Left Hip"] = v(-.56, 1.53, .04),
    TailJoint = v(0, 1.72, .74),
}, sole(1), sole(-1))
local pose = rig.pose

local rightGuard, leftGuard = {43, 13, -18, .05, .08, .045}, {60, -21, 16, .075, .08, -.035}
local rear = {8, -22, 0, .13, 0, .17, .018}
local lead = {7, 16, 0, -.11, 0, -.24, .018}
local ready = pose({.01, -.215, .038, -10, -12, 3}, rightGuard, leftGuard,
    rear, lead, {10, 12, -1}, {-6, 8, 1})
local breathe = pose({.025, -.165, .018, -8, -9, 2}, {46, 13, -17, .065, .09, .04},
    leftGuard, rear, lead, {9, 9, -1}, {-5, 13, 1})
local stepLead = pose({-.16, -.245, -.137, -14, -14, 9}, rightGuard, leftGuard,
    rear, {17, 13, -3, -.165, 0, -.34, .18}, {14, 13, -7}, {-11, 22, -4})
local stepRear = pose({.15, -.23, -.131, -14, -6, -7}, rightGuard, leftGuard,
    {16, -18, 3, .18, 0, -.31, .14}, lead, {14, 5, 5}, {-11, -20, 5})
local backLead = pose({-.14, -.22, .13, 0, -16, 7}, rightGuard, leftGuard,
    rear, {-16, 14, -2, -.17, 0, .28, .115}, {1, 16, -5}, {-14, 22, -3})
local backRear = pose({.147, -.26, .14, 3, -5, -7}, rightGuard, leftGuard,
    {-13, -18, 2, .18, 0, .33, .125}, lead, {-3, 5, 5}, {-12, -22, 6})
local slip = pose({.26, -.32, .065, -10, -15, -18}, {34, 11, -23, .07, .08, .20}, leftGuard,
    {12, -21, 0, .29, 0, .145, .12}, lead, {10, 16, 13}, {-11, 35, -13})
local brake = pose({.175, -.28, -.025, -11, -4, -9}, rightGuard, leftGuard,
    {6, -19, 0, .23, 0, .105, .018}, lead, {11, 4, 8}, {-13, 22, -6})

local jabLoad = pose({.08, -.24, .11, -12, -25, -5}, {28, 10, -18, .045, .04, .19}, leftGuard,
    rear, lead, {13, 25, 4}, {-8, 25, -5})
local jabHit = pose({.02, -.14, -.22, -8, 21, -2}, {66, 18, -14, -.155, .115, -.205}, leftGuard,
    rear, lead, {9, -21, 2}, {-8, -26, 4})
local crossLoad = pose({-.12, -.30, .115, -14, 24, 6}, rightGuard, {26, -8, 21, -.045, .06, .22},
    rear, lead, {13, -23, -5}, {-10, -27, -5})
local crossHit = pose({-.07, -.17, -.28, -10, -28, 4}, rightGuard, {68, -18, 13, .17, .07, -.23},
    rear, lead, {11, 28, -3}, {-9, 35, 6})
local bodyLoad = pose({.04, -.39, .13, -19, -27, -6}, {28, 9, -26, .04, -.045, .24}, leftGuard,
    rear, lead, {18, 24, 5}, {-13, 22, -5})
local bodyHit = pose({.03, -.36, -.275, -19, 22, -2}, {54, 18, -12, -.145, -.085, -.235},
    leftGuard, rear, lead, {20, -20, 2}, {-13, -28, 5})
local heavyLoad = pose({-.14, -.39, .19, -16, 39, 12}, {64, 28, -20, .035, .09, .095},
    {21, -9, 24, -.095, .035, .29}, rear, lead, {16, -36, -9}, {-11, -42, -6})
local heavyHit = pose({-.07, -.18, -.31, -12, -33, 5}, {46, 9, -21},
    {68, -22, 11, .155, .095, -.245}, rear, lead, {13, 33, -3}, {-15, 44, 9})
local heavyEase = pose({-.08, -.29, -.135, -14, -42, 7}, rightGuard, {52, -25, 16, .095, .055, -.10},
    rear, lead, {15, 41, -4}, {-11, 51, 12})

local hornWindup = pose({.105, -.37, .19, -19, -28, -7}, {32, 10, -23, .08, .04, .145},
    {57, -21, 19, .10, .10, .025}, rear, lead, {-7, 14, 7}, {-13, 30, -9})
local hornDrive = pose({.04, -.36, -.15, -26, -9, -3}, {36, 9, -22, .07, .04, .075},
    {51, -19, 21, .095, .075, .025}, rear, lead, {-19, 2, 5, 0, 0, -.11}, {-17, 11, -4})
local hornHit = pose({0, -.38, -.29, -23, -16, 0}, {39, 10, -23, .05, .03, .07},
    {44, -15, 22, .065, .055, .04}, rear, lead, {-22, -5, 0, 0, 0, -.14}, {-21, 18, 0})
local hornFollow = pose({-.07, -.33, -.19, -15, 21, 7}, rightGuard, {55, -20, 18},
    rear, lead, {-7, 19, -5}, {-14, -21, 8})

local crouchRear = {8, -17, 0, .15, 0, .29, .018}
local crouchLead = {13, 12, 0, -.12, 0, -.285, .018}
local tuckedRight, tuckedLeft = {32, 8, -16, .055, .08, .17}, {34, -10, 17, -.065, .065, .17}
local chargeLoad = pose({.035, -.54, .18, -31, 0, 0}, tuckedRight, tuckedLeft,
    crouchRear, crouchLead, {-13, 0, 0}, {-18, 0, 0})
local chargeRear = pose({.071, -.35, -.13, -32, -5, -5}, tuckedRight, {40, -11, 19, -.06, .06, .10},
    {26, -15, 2, .12, 0, -.31, .14}, crouchLead, {-14, 4, 3}, {-17, 19, 6})
local chargeLead = pose({-.065, -.36, -.15, -31, 5, 4}, {37, 7, -21, .04, .06, .10}, tuckedLeft,
    crouchRear, {25, 13, -2, -.13, 0, -.30, .15}, {-15, -4, -3}, {-18, -17, -7})
local chargeBrace = pose({0, -.50, -.26, -30, 0, 0}, {36, 4, -26, .09, .025, .12},
    {37, -4, 26, -.09, .025, .12}, {9, -15, 0, .18, 0, .09, .018},
    {14, 15, 0, -.155, 0, -.28, .018}, {-12, 0, 0, 0, 0, -.15}, {-21, 0, 0})
local chargeRecover = pose({0, -.19, -.04, 2, 0, 0}, {57, 17, -23}, {57, -16, 22},
    rear, lead, {-8, 0, 0}, {-13, 0, 0})

local cover = pose({0, -.34, .08, -13, 0, 0}, {68, 17, -21, -.14, .10, -.065},
    {68, -17, 21, .14, .10, -.065}, rear, lead, {14, 0, 0}, {-11, 0, 0})
local recoil = pose({-.075, -.33, .17, 7, -8, 7}, {63, 15, -17, -.10, .08, .10},
    {61, -14, 18, .12, .07, .10}, rear, lead, {-11, 8, -4}, {-13, 13, -8})
local deflect = pose({.04, -.28, -.12, -15, 28, -5}, {64, -11, -17, -.11, .145, -.12},
    {60, -19, 20, .08, .095, .065}, rear, lead, {14, -25, 5}, {-15, -25, 8})
local headHit = pose({-.11, -.29, .18, 14, -19, 10}, {39, 6, -24}, {40, -13, 24},
    rear, lead, {-19, 16, -9}, {-16, 18, -10})
local gutHit = pose({.10, -.45, .17, -22, 16, -10}, {38, 14, -19}, {41, -13, 19},
    rear, lead, {18, -15, 7}, {-15, -24, 9})
local bow = pose({0, -.31, -.12, -28, 0, 0}, {36, 13, -16}, {35, -13, 16},
    rear, lead, {17, 0, 0}, {-15, 0, 0})
local hornSalute = pose({.038, -.095, -.015, 5, -15, 5}, {76, 4, -22, -.045, .13, -.085},
    leftGuard, rear, lead, {-2, 15, -4}, {-14, 19, -5})
local chestRaise = pose({0, -.05, -.04, 5, 0, 0}, {78, -6, -32, .14, .16, -.08},
    {77, 6, 32, -.13, .15, -.07}, rear, lead, {-6, 0, 0}, {-14, 0, 0})

local contact = {jab = .173, cross = .237, body = .283, heavy = .439, hornCheck = .31, staticCharge = .68}
local clips = {
    stance = {{0, ready}, {.61, breathe}, {1.22, ready}},
    advance = {{0, ready}, {.17, stepLead}, {.34, breathe}, {.52, stepRear}, {.69, ready}},
    retreat = {{0, ready}, {.19, backRear}, {.38, ready}, {.55, backLead}, {.73, ready}},
    sidestep = {{0, ready}, {.108, slip}, {.247, brake}, {.483, ready}},
    jab = {{0, ready}, {.078, jabLoad}, {contact.jab, jabHit}, {.233, jabHit}, {.44, ready}},
    cross = {{0, ready}, {.108, crossLoad}, {contact.cross, crossHit}, {.318, crossHit}, {.535, ready}},
    body = {{0, ready}, {.137, bodyLoad}, {contact.body, bodyHit}, {.41, breathe}, {.596, ready}},
    heavy = {{0, ready}, {.198, heavyLoad}, {.293, heavyLoad}, {contact.heavy, heavyHit}, {.557, heavyEase}, {.845, ready}},
    hornCheck = {{0, ready}, {.143, hornWindup}, {.224, hornDrive}, {contact.hornCheck, hornHit},
        {.417, hornFollow}, {.53, breathe}, {.681, ready}},
    staticCharge = {{0, ready}, {.15, chargeLoad}, {.20, chargeLoad}, {.32, chargeRear},
        {.43, chargeLead}, {.54, chargeRear}, {.62, chargeLead}, {contact.staticCharge, chargeBrace},
        {.80, chargeBrace}, {.98, chargeRecover}, {1.18, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.087, recoil}, {.172, recoil}, {.29, cover}},
    parry = {{0, cover}, {.089, deflect}, {.18, deflect}, {.36, ready}},
    hitHead = {{0, ready}, {.082, headHit}, {.176, headHit}, {.373, ready}},
    hitBody = {{0, ready}, {.094, gutHit}, {.196, gutHit}, {.39, ready}},
    stagger = {{0, headHit}, {.17, brake}, {.34, recoil}, {.565, ready}},
    intro = {{0, ready}, {.95, breathe}, {1.70, hornSalute}, {2.31, hornSalute}, {2.91, bow}, {3.47, ready},
        {4.19, chargeLoad}, {4.64, chargeLoad}, {5.10, chargeRecover}, {5.60, ready},
        {6.36, hornWindup}, {6.72, hornHit}, {7.22, hornFollow}, {7.82, ready}, {8.88, breathe}, {10, ready}},
    win = {{0, ready}, {.31, chestRaise}, {.98, chestRaise}, {1.25, bow}, {1.57, bow}, {2.02, ready}},
}

local rightGlove, leftGlove = v(1.25, 1.879, -.831), v(-1.25, 1.879, -.831)
-- The near edge of the left horn leads when the head twists into the check.
local hornFront = v(-1.173, 4.162, -.732)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightGlove}}, cross = {{crossHit, "Left Shoulder", leftGlove}},
    body = {{bodyHit, "Right Shoulder", rightGlove}}, heavy = {{heavyHit, "Left Shoulder", leftGlove}},
    hornCheck = {{hornHit, "Neck", hornFront}},
    staticCharge = {v(0, -rootHeight, 0)},
}
local skills = {
    hornCheck = table.freeze({damage = 20, radius = .60, shove = .96}),
    staticCharge = table.freeze({damage = 29, shove = 1.35}),
}
local travel = {
    hornCheck = table.freeze({axis = "forward", distance = .38, startsAt = .17, endsAt = .30}),
    staticCharge = table.freeze({axis = "forward", distance = 6.85, startsAt = .20, endsAt = .68}),
}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
