-- Magma Grizzly bears his weight on the rear boot, then drives both bracers
-- into the mat. The follow-up beats leave the bear planted over the impact.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    local x = side * .55
    return {v(x - .375, .012, -.87), v(x + .375, .012, -.87),
        v(x - .375, .012, .17), v(x + .375, .012, .17)}
end

local rig = Choreography.new(rootHeight, {
    Neck = v(0, 3.29, -.04),
    ["Right Shoulder"] = v(1.23, 3.13, .025), ["Left Shoulder"] = v(-1.23, 3.13, .025),
    ["Right Hip"] = v(.55, 1.48, .06), ["Left Hip"] = v(-.55, 1.48, .06),
    TailJoint = v(0, 1.84, .79),
}, sole(1), sole(-1))
local pose = rig.pose

local rear = {5, -20, 0, .17, 0, .23, .018}
local lead = {10, 14, 0, -.10, 0, -.18, .018}
local rightGuard = {47, 14, -31, -.065, .061, -.028}
local leftGuard = {54, -16, 31, .059, .08, -.06}
local ready = pose({.05, -.20, .042, -10, -7, -5}, rightGuard, leftGuard, rear, lead,
    {9, 7, 4}, {-9, -8, 6})
local breathe = pose({.023, -.147, .018, -7, -3, -2}, {49, 11, -34, -.072, .073, -.032},
    {56, -20, 33, .061, .073, -.061}, rear, lead, {7, 3, 2}, {-7, 9, -5})
local forwardLead = pose({-.137, -.30, -.091, -17, 10, 7}, {51, 16, -30}, {43, -11, 25},
    rear, {21, 15, -2, -.15, 0, -.295, .143}, {17, -9, -6}, {-10, -20, -7})
local forwardRear = pose({.16, -.30, -.13, -18, -13, -9}, {42, 9, -25}, {62, -19, 25},
    {23, -18, 4, .22, 0, -.274, .15}, lead, {17, 11, 7}, {-12, 19, 9})
local backRear = pose({.16, -.19, .17, -4, 11, -7}, {50, 12, -32}, {59, -14, 31},
    {-17, -22, 3, .18, 0, .31, .115}, lead, {6, -8, 6}, {-8, 22, 7})
local backLead = pose({-.147, -.195, .162, -3, -7, 9}, {54, 12, -31}, {46, -15, 26},
    rear, {-11, 19, -1, -.16, 0, .28, .121}, {4, 5, -8}, {-8, -22, -7})
local slip = pose({.30, -.32, .016, -15, -14, -21}, {34, 15, -48}, {59, -19, 29},
    {8, -25, 3, .27, 0, .14, .137}, lead, {12, 13, 16}, {-12, 22, 10})
local catch = pose({.20, -.28, -.035, -11, 12, -10}, rightGuard, leftGuard,
    {9, -24, 2, .30, 0, .107, .018}, lead, {12, -10, 8}, {-9, -19, 6})

local jabLoad = pose({.101, -.26, .10, -15, -22, -5}, {33, 8, -32, .056, .010, .17},
    leftGuard, rear, lead, {15, 20, 4}, {-10, 18, 5})
local jabHit = pose({.026, -.185, -.223, -12, 29, -4}, {68, 19, -13, -.16, .099, -.24},
    leftGuard, rear, lead, {12, -27, 3}, {-9, -34, 6})
local crossLoad = pose({-.129, -.277, .138, -18, 25, 8}, rightGuard, {28, 6, 44, -.08, .033, .23},
    rear, lead, {18, -23, -7}, {-13, -26, -7})
local crossHit = pose({-.059, -.206, -.267, -13, -32, 6}, {58, 13, -30},
    {69, -21, 10, .16, .099, -.27}, rear, lead, {15, 29, -5}, {-11, 34, 6})
local bodyLoad = pose({.123, -.37, .12, -22, -20, -8}, {26, 13, -44, .14, -.043, .215},
    leftGuard, rear, lead, {21, 18, 7}, {-13, 25, -5})
local bodyHit = pose({.039, -.365, -.267, -23, 30, -1}, {57, 24, -8, -.145, -.075, -.242},
    {61, -20, 31}, rear, lead, {24, -28, 0}, {-11, -39, 7})
local heavyLoad = pose({-.13, -.342, .20, -20, 36, 11}, {62, 18, -25, -.07, .095, -.04},
    {25, -5, 48, -.13, .025, .30}, rear, lead, {19, -35, -9}, {-14, -39, -7})
local heavyHit = pose({-.09, -.234, -.292, -17, -38, 8}, {49, 16, -34},
    {69, -27, 10, .196, .106, -.277}, rear, lead, {17, 35, -7}, {-12, 40, 8})
local heavyCarry = pose({-.138, -.30, -.16, -20, -48, 12}, rightGuard,
    {53, -37, 13, .175, .054, -.10}, rear, lead, {17, 44, -10}, {-14, 49, 8})

local backhandWind = pose({.154, -.255, .145, -10, -44, -8}, {48, -12, -54, .061, .06, .14},
    {64, -19, 27, .11, .06, -.08}, rear, lead, {11, 39, 6}, {-13, 41, -7})
local backhandHit = pose({-.039, -.185, -.244, -10, 35, 6}, {66, 28, -6, -.26, .08, -.225},
    {69, -13, 28, .08, .12, -.066}, rear, lead, {10, -31, -3}, {-13, -40, 6})
local backhandCarry = pose({-.128, -.24, -.14, -19, 44, 13}, {53, 36, -4, -.308, .03, -.106},
    leftGuard, rear, lead, {17, -39, -10}, {-13, -49, 9})

-- A short forepaw strike turns out of the elbow line while the off paw holds guard.
local pumiceLoad = pose({.082, -.285, .072, -16, -27, -4}, {35, 6, -32, .055, .004, .15},
    {61, -20, 28, .070, .114, -.030}, rear, lead, {15, 24, 2}, {-11, 24, -4})
local pumiceHit = pose({.072, -.343, -.032, -16, 19, -5}, {51, 19, -26, -.115, -.007, -.09},
    {63, -20, 31, .065, .094, -.034}, rear, lead, {16, -17, 4}, {-12, -20, 5})
local pumiceFold = pose({.056, -.27, -.055, -14, 9, -5}, {50, 15, -29, -.089, .061, -.059},
    leftGuard, rear, lead, {15, -8, 4}, {-11, -12, 4})

-- Lower into the rear boot, then roll the left brass plate across the body line.
-- The tucked glove and muzzle trail the rounded shoulder through contact.
local forgeSit = pose({.075, -.39, .087, -15, 21, -9}, {58, 18, -27, -.042, .10, -.025},
    {27, -6, 21, .033, .084, .115}, rear, lead, {15, -17, 7}, {-11, -21, 9})
local forgeDraw = pose({.168, -.51, .123, -18, 37, -13}, {62, 23, -27, -.055, .111, -.026},
    {16, -2, 25, .073, .084, .143}, rear, lead, {18, -32, 8}, {-12, -34, 10})
local forgeTurn = pose({.035, -.36, -.038, -13, -18, -8}, {47, 15, -30, -.033, .117, .071},
    {-17, -11, 29, .045, .113, .025}, rear, lead, {13, 12, 6}, {-9, 16, 7})
local forgeHit = pose({-.045, -.245, -.36, -12, -70, 7}, {29, 20, -21, -.085, .084, .23},
    {-34, -13, 25, .034, .083, -.035}, rear, lead, {10, 12, -8, -.045, -.10, .125}, {-10, 31, -5})
local forgeThrough = pose({-.09, -.29, -.24, -13, -75, 7}, {35, 20, -23, -.071, .083, .171},
    {-29, -15, 23, .041, .071, -.011}, rear, lead, {12, 14, -7, -.025, -.061, .09}, {-11, 33, -5})
local forgeFold = pose({.015, -.325, -.058, -14, -27, 4}, rightGuard,
    {22, -16, 28, .052, .074, .058}, rear, lead, {13, 22, -2}, {-10, 22, -2})

local anchorRight = {4, -17, 0, .25, 0, .19, .018}
local anchorLeft = {5, 18, 0, -.23, 0, -.19, .018}
local pull = pose({.005, -.30, .10, -11, -4, 0}, {43, 8, -48, .125, .06, .034},
    {45, -7, 48, -.10, .06, .035}, anchorRight, anchorLeft, {12, 4, 0}, {-12, 9, 0})
local lift = pose({.0, -.07, .082, 10, 0, 0}, {128, -7, -29, .04, .21, -.09},
    {127, 8, 27, -.04, .21, -.08}, anchorRight, anchorLeft, {-13, 0, 0}, {-14, 4, 0})
local descend = pose({-.004, -.49, -.21, -25, 0, 0}, {37, 5, 1, -.055, .037, -.11},
    {41, -6, -1, .05, .029, -.10}, anchorRight, anchorLeft, {20, 0, 0}, {-18, -2, 0})
local slam = pose({-.004, -.99, -.44, -32, 0, 0}, {7, 0, 4, -.30, -.044, -.471},
    {8, 0, -4, .30, -.045, -.472}, anchorRight, anchorLeft, {24, -3, 0}, {-18, 3, 0})
local secondBeat = pose({-.10, -.89, -.27, -28, -9, 6}, {23, 8, -7, -.125, .08, -.13},
    {12, -10, 1, .16, -.076, -.256}, anchorRight, anchorLeft, {21, 12, -4}, {-15, 14, -4})
local thirdBeat = pose({.09, -.89, -.245, -27, 10, -7}, {18, 10, -2, -.16, -.068, -.275},
    {27, -8, 6, .13, .14, -.13}, anchorRight, anchorLeft, {23, -13, 5}, {-15, -15, 4})
local fourthBeat = pose({0, -.60, -.20, -25, 0, 0}, {28, 8, -12, -.14, .047, -.16},
    {29, -9, 12, .13, .052, -.15}, anchorRight, anchorLeft, {25, 1, 0}, {-14, -3, 1})
local recover = pose({0, -.36, -.078, -18, 0, 0}, {43, 10, -29, -.07, .06, -.06},
    {46, -11, 29, .065, .07, -.06}, anchorRight, anchorLeft, {17, 0, 0}, {-11, 6, 0})

local cover = pose({.01, -.33, .062, -14, -3, -1}, {64, 18, -24, -.13, .103, -.063},
    {67, -19, 23, .13, .105, -.063}, rear, lead, {14, 3, 1}, {-10, 4, 3})
local recoil = pose({-.07, -.307, .15, 6, -5, 7}, {62, 15, -22, -.10, .06, .065},
    {63, -15, 22, .12, .07, .07}, rear, lead, {-8, 5, -5}, {-10, 6, -8})
local deflect = pose({.058, -.27, -.101, -16, 23, -4}, {66, 1, -16, -.15, .151, -.15},
    {60, -17, 22, .085, .093, .033}, rear, lead, {16, -19, 3}, {-11, -22, 5})
local headHit = pose({-.115, -.283, .197, 14, -19, 12}, {38, 10, -29}, {42, -16, 24},
    rear, lead, {-18, 16, -11}, {-12, 18, -10})
local gutHit = pose({.098, -.437, .16, -25, 16, -9}, {33, 14, -23}, {39, -13, 23},
    rear, lead, {23, -14, 8}, {-12, -22, 7})
local salute = pose({.036, -.12, -.03, 3, -10, 5}, {83, 6, -26, -.068, .13, -.08},
    leftGuard, rear, lead, {-4, 10, -4}, {-7, 13, -6})
local bow = pose({0, -.32, -.15, -29, 0, 0}, {39, 12, -25, -.035, .04, .04},
    {41, -12, 25, .035, .046, .04}, rear, lead, {24, 0, 0}, {-9, 4, 1})
local roar = pose({0, -.075, .042, 7, 0, 0}, {80, -9, -47, .11, .11, -.043},
    {81, 11, 46, -.117, .115, -.045}, anchorRight, anchorLeft, {-16, 0, 0}, {-9, 8, 1})

local cinderFold = pose({-.085, -.245, .074, -9, 21, 5}, rightGuard,
    {33, -12, 29, .066, .073, .153}, rear, lead, {9, -19, -4}, {-13, -24, 6})
local cinderHit = pose({-.045, -.244, -.024, -13, -26, 4}, rightGuard,
    {62, -18, 13, .124, .067, -.041}, rear, lead, {12, 25, -3}, {-12, 22, -6})
local cinderReset = pose({-.068, -.23, -.051, -10, -13, 4}, rightGuard,
    {48, -18, 22, .081, .084, -.051}, rear, lead, {10, 12, -3}, {-10, 18, -4})

local toeDraw = pose({.14, -.275, .090, -8, -8, -12}, rightGuard,
    {56, -14, 33, .061, .088, .021}, rear, {26, 13, -1, -.084, .064, .055, .12},
    {8, 8, 8}, {-10, 11, 7})
local toeHit = pose({.13, -.268, -.150, -11, -12, -11}, rightGuard,
    {58, -17, 37, .074, .089, .015}, rear, {49, 7, 4, -.02, .063, -.45, .24},
    {9, 11, 8}, {-11, 20, 8})
local toePull = pose({.10, -.29, -.07, -12, -10, -7}, rightGuard,
    {53, -17, 34, .064, .087, .033}, rear, {27, 11, 2, -.075, .051, -.157, .16},
    {10, 9, 5}, {-12, 14, 7})

local furnaceSet = pose({0, -.34, .08, -13, -2, 0}, {37, 12, 42, .07, .072, .14},
    {46, -14, -28, -.059, .084, .08}, rear, lead, {12, -1, 1}, {-20, 4, -6})
local furnaceRaise = pose({.028, -.184, .045, -9, -17, -3}, {103, 19, 31, .073, .15, .102},
    {66, -16, 30, .067, .10, -.13}, rear, lead, {8, 15, 2}, {-12, 20, -7})
local furnaceHit = pose({.032, -.414, -.27, -21, 28, -3}, {61, 21, -15, -.17, -.035, -.245},
    {62, -16, 33, .065, .10, -.041}, rear, lead, {18, -26, 3}, {-17, -36, 8})
local furnaceEase = pose({.026, -.31, -.15, -14, 19, -3}, {54, 17, -22, -.115, .034, -.10},
    leftGuard, rear, lead, {12, -17, 2}, {-15, -23, 6})

local foundryLoad = pose({-.13, -.29, .091, -12, 32, 7}, rightGuard,
    {39, -5, -43, -.094, .083, .21}, rear, lead, {11, -28, -6}, {-13, -35, 7})
local foundryHigh = pose({-.035, -.19, -.32, -12, -31, 4}, rightGuard,
    {75, -20, 11, .178, .123, -.267}, rear, lead, {9, 27, -3}, {-17, 34, -5})
local foundryTurn = pose({.128, -.34, .026, -16, -37, -8}, {27, 13, 39, .10, .054, .19},
    leftGuard, rear, lead, {16, 33, 7}, {-14, 43, -8})
local foundryLow = pose({.048, -.423, -.28, -21, 26, -6}, {54, 20, -16, -.17, -.032, -.246},
    leftGuard, rear, lead, {18, -25, 4}, {-19, -33, 7})
local foundryOut = pose({.036, -.34, -.118, -15, 15, -4}, {48, 18, -22, -.112, .027, -.096},
    leftGuard, rear, lead, {12, -14, 3}, {-13, -26, 7})

local function forwardSurface(at, joint, center, radii)
    local plate = at.RootJoint * at[joint] * CFrame.new(center - v(0, rootHeight, 0))
    local view = plate:VectorToObjectSpace(v(0, 0, -1))
    local offset = (view * radii * radii) / (view * radii).Magnitude
    return plate:PointToWorldSpace(offset)
end
local function boxingGlove(at, side)
    return forwardSurface(at, if side > 0 then "Right Shoulder" else "Left Shoulder",
        v(side * 1.414, 1.915, -.642), v(.4825, .336, .276))
end
local toeSurface = forwardSurface(toeHit, "Left Hip", v(-.55, .221, -.816), v(.337, .1185, .081))

local contact = {jab = .183, cross = .248, body = .294, heavy = .45, basaltBackhand = .32,
    pumiceKnuckle = .25, forgeShoulder = .53,
    eruptionSlam = table.freeze({.52, .68, .84, 1.00}),
    cinderTap = .166, smelterToe = .26, furnaceGate = .66, foundryTurn = table.freeze({.35, .71})}
local beat = contact.eruptionSlam
local clips = {
    cinderTap = {{0, ready}, {.078, cinderFold}, {contact.cinderTap, cinderHit}, {.263, cinderReset}, {.43, ready}},
    smelterToe = {{0, ready}, {.108, toeDraw}, {contact.smelterToe, toeHit}, {.369, toePull}, {.57, ready}},
    furnaceGate = {{0, ready}, {.17, furnaceSet}, {.325, furnaceRaise}, {.455, furnaceRaise},
        {contact.furnaceGate, furnaceHit}, {.743, furnaceHit}, {.91, furnaceEase}, {1.30, ready}},
    foundryTurn = {{0, ready}, {.164, foundryLoad}, {contact.foundryTurn[1], foundryHigh}, {.483, foundryTurn},
        {.571, foundryTurn}, {contact.foundryTurn[2], foundryLow}, {.85, foundryOut}, {1.24, ready}},
    stance = {{0, ready}, {.71, breathe}, {1.42, ready}},
    advance = {{0, ready}, {.192, forwardLead}, {.381, breathe}, {.574, forwardRear}, {.765, ready}},
    retreat = {{0, ready}, {.201, backRear}, {.399, breathe}, {.60, backLead}, {.802, ready}},
    sidestep = {{0, ready}, {.135, slip}, {.294, catch}, {.51, ready}},
    jab = {{0, ready}, {.092, jabLoad}, {contact.jab, jabHit}, {.245, jabHit}, {.464, ready}},
    cross = {{0, ready}, {.12, crossLoad}, {contact.cross, crossHit}, {.333, crossHit}, {.554, ready}},
    body = {{0, ready}, {.138, bodyLoad}, {contact.body, bodyHit}, {.414, breathe}, {.626, ready}},
    heavy = {{0, ready}, {.192, heavyLoad}, {.30, heavyLoad}, {contact.heavy, heavyHit},
        {.596, heavyCarry}, {.875, ready}},
    basaltBackhand = {{0, ready}, {.122, backhandWind}, {.209, backhandWind}, {contact.basaltBackhand, backhandHit},
        {.425, backhandCarry}, {.556, breathe}, {.715, ready}},
    pumiceKnuckle = {{0, ready}, {.105, pumiceLoad}, {contact.pumiceKnuckle, pumiceHit}, {.365, pumiceFold}, {.62, ready}},
    forgeShoulder = {{0, ready}, {.156, forgeSit}, {.31, forgeDraw}, {.414, forgeTurn}, {contact.forgeShoulder, forgeHit},
        {.657, forgeThrough}, {.814, forgeFold}, {.99, ready}},
    eruptionSlam = {{0, ready}, {.135, pull}, {.295, lift}, {.354, lift}, {.447, descend},
        {beat[1], slam}, {.56, slam}, {beat[2], secondBeat}, {beat[3], thirdBeat}, {beat[4], fourthBeat},
        {1.145, recover}, {1.39, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.102, recoil}, {.194, recoil}, {.332, cover}},
    parry = {{0, cover}, {.096, deflect}, {.193, deflect}, {.377, ready}},
    hitHead = {{0, ready}, {.089, headHit}, {.18, headHit}, {.40, ready}},
    hitBody = {{0, ready}, {.097, gutHit}, {.21, gutHit}, {.405, ready}},
    stagger = {{0, headHit}, {.184, catch}, {.36, recoil}, {.62, ready}},
    intro = {{0, ready}, {.85, breathe}, {1.34, salute}, {2.12, salute}, {2.63, bow},
        {3.28, ready}, {4.01, backhandWind}, {4.41, backhandHit}, {4.88, ready},
        {5.76, pull}, {6.38, lift}, {6.77, descend}, {7.06, slam}, {7.64, recover},
        {8.3, ready}, {9.11, breathe}, {10, ready}},
    win = {{0, ready}, {.41, roar}, {1.15, roar}, {1.54, bow}, {1.84, bow}, {2.22, ready}},
}

-- Solve the local bottom of the rounded right glove in the slam pose.
-- This is the support point of its ellipsoid along the arm's rotated down axis.
local down = (slam.RootJoint * slam["Right Shoulder"]):VectorToObjectSpace(v(0, -1, 0))
local shell = v(.4825, .336, .276)
local weightedDown = v(down.X * shell.X, down.Y * shell.Y, down.Z * shell.Z)
local gloveContact = v(1.414, 1.915, -.642)
    + v(weightedDown.X * shell.X, weightedDown.Y * shell.Y, weightedDown.Z * shell.Z) / weightedDown.Magnitude
local rightPad, leftPad = v(1.40, 1.89, -.959), v(-1.40, 1.89, -.959)
-- The first impact is the glove touching the mat. The other positions describe
-- the consecutive rifts ahead of that strike, in coordinates relative to the root.
local hits = {
    cinderTap = {boxingGlove(cinderHit, -1)}, smelterToe = {toeSurface},
    furnaceGate = {boxingGlove(furnaceHit, 1)}, foundryTurn = {boxingGlove(foundryHigh, -1), boxingGlove(foundryLow, 1)},
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    basaltBackhand = {{backhandHit, "Right Shoulder", rightPad}},
    -- The glove pad and the rounded outside of the brass shoulder armor.
    pumiceKnuckle = {{pumiceHit, "Right Shoulder", v(1.719596455, 1.859098872, -.905733591)}},
    forgeShoulder = {{forgeHit, "Left Shoulder", v(-1.888723431, 3.281662140, .010069325)}},
    eruptionSlam = {{slam, "Right Shoulder", gloveContact},
        v(0, -rootHeight, -3.10), v(0, -rootHeight, -4.75), v(0, -rootHeight, -6.40)},
}

local skills = {
    cinderTap = table.freeze({damage = 13, radius = .44}),
    smelterToe = table.freeze({damage = 16, radius = .49, foot = true}),
    basaltBackhand = table.freeze({damage = 22, radius = .65, shove = .86}),
    pumiceKnuckle = table.freeze({damage = 16, radius = .47}),
    forgeShoulder = table.freeze({damage = 25, radius = .53}),
    eruptionSlam = table.freeze({damage = table.freeze({12, 12, 12, 12})}),
}

local poses = table.clone(rig.finish(clips, contact, hits, skills, {}, {"sidestep"},
    {pumiceKnuckle = true, forgeShoulder = true, cinderTap = true, furnaceGate = true, foundryTurn = true}))
local sample = poses.sample
local rightPlant = ready.RootJoint * ready["Right Hip"]
function poses.sample(action, age, direction)
    local offsets = sample(action, age, direction)
    if action == "smelterToe" then
        offsets["Right Hip"] = offsets.RootJoint:ToObjectSpace(rightPlant)
    end
    return offsets
end
poses.UltimateSkill = table.freeze({
    furnaceGate = table.freeze({damage = 35, radius = .55}),
    foundryTurn = table.freeze({damage = table.freeze({15, 22}), radius = table.freeze({.48, .53})}),
})
return table.freeze(poses)
