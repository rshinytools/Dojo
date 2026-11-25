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

local flickLoad = pose({.030, -.13, .102, -6, 5, -3}, {38, -17, 25, .018, .067, .12},
    leftGuard, rear, lead, {6, -5, 2}, {-9, 6, 2})
local flickDrive = pose({.045, -.155, -.06, -9, 18, -3}, {59, 4, 29, .02, .083, .01},
    leftGuard, rear, lead, {9, -18, 1}, {-10, -15, 4})
local flickHit = pose({.022, -.18, -.035, -10, 36, -4}, {108, 15, -10, .025, .045, -.035},
    {58, -13, -19, .075, .065, -.045}, rear, lead, {10, -31, 2}, {-12, -26, 6})
local flickCatch = pose({.014, -.16, -.08, -8, 22, -4}, {72, 15, 12, -.03, .085, -.067},
    leftGuard, rear, lead, {8, -20, 2}, {-9, -15, 4})

local clapOpen = pose({-.085, -.13, .13, -4, 18, 4}, {53, -18, 96, -.115, .027, -.05},
    {51, 24, -99, .082, .037, .021}, rear, lead, {4, -16, -3}, {-7, -12, -3})
local clapSink = pose({-.07, -.28, .084, -13, 11, 2}, {51, -16, 83, -.086, .040, .023},
    {48, 22, -89, .089, .042, .037}, rear, lead, {12, -11, -2}, {-17, -9, -2})
local clapClose = pose({-.04, -.27, -.035, -12, -8, 3}, {59, 11, 54, -.092, .047, -.06},
    {61, -10, -55, .120, .032, -.082}, rear, lead, {12, 9, -2}, {-16, 5, -4})
local clapHit = pose({-.045, -.20, -.28, -10, -32, 1}, {76, 16, 19, -.065, .037, -.085},
    {77, -23, 16, .10, .09, -.21}, rear, lead, {10, 29, 0}, {-12, 19, -3})
local clapThrough = pose({-.075, -.25, -.16, -13, -42, 5}, {68, 24, 12, -.058, .037, -.029},
    {70, -27, 11, .088, .05, -.13}, rear, lead, {13, 38, -4}, {-14, 33, -6})
local clapSettle = pose({-.038, -.185, -.055, -9, -14, 1}, {59, 18, 20}, {63, -18, -10},
    rear, lead, {9, 13, -2}, {-8, 11, -3})

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

local contact = {jab = .159, cross = .219, body = .268, heavy = .411, wingSweep = .28, quillFlick = .23,
    thunderclapWing = .50, thunderDive = .66}
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
    quillFlick = {{0, ready}, {.074, flickLoad}, {.147, flickDrive}, {contact.quillFlick, flickHit},
        {.331, flickCatch}, {.59, ready}},
    thunderclapWing = {{0, ready}, {.188, clapOpen}, {.287, clapOpen}, {.369, clapSink}, {.429, clapClose},
        {contact.thunderclapWing, clapHit}, {.605, clapThrough}, {.77, clapSettle}, {.93, ready}},
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
    quillFlick = {{flickHit, "Right Shoulder", v(1.209000446, 1.683555397, .615635893)}},
    thunderclapWing = {{clapHit, "Left Shoulder", v(-1.450220854, 1.870888828, -.521817631)}},
}
local skills = {
    wingSweep = table.freeze({damage = 18, radius = .57, shove = .67}),
    quillFlick = table.freeze({damage = 14, radius = .47}),
    thunderclapWing = table.freeze({damage = 22, radius = .54}),
    thunderDive = table.freeze({damage = 24, shove = .66, stun = 1.20}),
}
local travel = {
    wingSweep = table.freeze({axis = "forward", distance = .30, startsAt = .15, endsAt = .26}),
    thunderDive = table.freeze({axis = "forward", distance = 5.60, startsAt = .24, endsAt = .66}),
}

local standard = rig.finish(clips, contact, hits, skills, travel, {"sidestep"},
    {quillFlick = true, thunderclapWing = true})

local leftHip, rightHip = "Left Hip", "Right Hip"
local leftPlant = CFrame.new(0, -.009, 0) * ready.RootJoint * ready[leftHip]
local rightPlant = CFrame.new(0, -.009, 0) * ready.RootJoint * ready[rightHip]

local function plantTalons(offsets, both)
    local root = offsets.RootJoint
    offsets[leftHip] = root:ToObjectSpace(leftPlant)
    if both then
        offsets[rightHip] = root:ToObjectSpace(rightPlant)
    end
    return offsets
end

local function fitted(core, right, left, head, tail, kick)
    return plantTalons(pose(core, right, left, kick or rear, lead, head, tail), kick == nil)
end

local variantReady = plantTalons(table.clone(ready), true)
local fletchTuck = fitted({-.031, -.16, .075, -7, 20, 3}, rightGuard,
    {47, -9, -10, .043, .061, .10}, {9, -18, -2}, {-8, -18, -3})
local fletchHit = fitted({-.031, -.23, -.075, -13, -29, 5}, {48, 18, 18, -.06, .073, .02},
    {63, -18, 15, .143, .001, -.106}, {13, 23, -3}, {-8, 30, -4})
local fletchEase = fitted({-.035, -.16, -.022, -8, -13, 3}, rightGuard,
    {60, -17, 2, .111, .043, -.040}, {10, 11, -2}, {-8, 13, -3})

local hookGather = fitted({-.095, -.195, .04, -7, -3, 7}, {44, 18, 25, -.015, .086, .05},
    {61, -17, -22, .108, .082, .01}, {9, 5, -5}, {-6, 7, -6})
local hookTuck = fitted({-.13, -.194, .003, -8, 6, 9}, {42, 21, 27, -.03, .072, .06},
    {62, -21, -20, .124, .095, .04}, {10, -6, -5}, {-9, -7, -6},
    {34, -16, 5, .091, .05, .012, .24})
local hookHit = fitted({-.102, -.20, -.172, -10, 19, 8}, {43, 18, 26, -.033, .071, -.02},
    {62, -20, -16, .109, .095, .015}, {12, -16, -4}, {-8, -20, -6},
    {62, -5, 0, -.037, .06, -.264, .53})
local hookEase = fitted({-.062, -.19, -.064, -7, 12, 6}, {46, 18, 24, -.027, .077, -.012},
    {62, -19, -17, .086, .077, -.005}, {8, -11, -3}, {-8, -14, -4},
    {29, -14, 4, .06, .052, -.10, .19})

local perchBrace = fitted({0, -.28, .082, -12, 0, 0}, {28, -9, 34, -.055, .05, .105},
    {30, 10, -36, .055, .058, .115}, {11, 0, 0}, {-13, 0, 0})
local perchFan = fitted({.004, -.11, .082, -2, 1, 0}, {62, -16, 87, -.247, .102, .027},
    {64, 15, -89, .247, .104, .031}, {2, 0, 0}, {-9, 0, 0})
local perchFall = fitted({.005, -.50, -.048, -16, 1, 0}, {21, -8, 43, -.09, -.06, -.043},
    {22, 7, -42, .09, -.065, -.049}, {15, 1, -1}, {1, -1, 0})
local perchMat = fitted({.009, -.88, -.17, -28, 1, 0}, {8, -8, 12, -.138, -.585, -.205},
    {7, 8, -11, .145, -.585, -.205}, {20, -1, -1}, {8, 0, 0})
local perchRebound = fitted({.006, -.55, -.089, -15, 1, 0}, {13, -2, 38, -.079, -.055, -.108},
    {14, 1, -39, .078, -.057, -.11}, {17, -1, 0}, {0, 0, 0})
local perchEase = fitted({.01, -.255, -.037, -10, 5, -1}, {38, 14, 35, -.055, .059, -.038},
    {48, -16, -35, .069, .061, -.038}, {11, -4, 1}, {-6, -4, 1})

local galeWide = fitted({-.072, -.21, .123, -9, 32, 7}, {49, 20, 13, -.024, .088, .04},
    {23, 16, -67, .129, .074, .08}, {8, -29, -5}, {-10, -28, -5})
local galeWing = fitted({-.044, -.29, -.243, -16, -35, 4}, {50, 16, 27, -.054, .084, .056},
    {68, -24, 16, .164, .062, -.204}, {16, 30, -3}, {1, 35, -4})
local galeSwap = fitted({-.125, -.249, -.015, -7, -16, 9}, {46, 18, 35, -.129, .076, .052},
    {59, -24, 23, .092, .077, -.028}, {10, 15, -5}, {-7, 15, -7})
local galeCoil = fitted({-.143, -.252, -.022, -6, -12, 10}, {40, 20, 43, -.152, .079, .052},
    {54, -21, 13, .117, .079, .068}, {8, 11, -6}, {-6, 13, -7},
    {33, -10, 4, .114, .04, .097, .28})
local galeKick = fitted({-.085, -.208, -.256, -11, 19, 7}, {37, 20, 53, -.166, .082, .035},
    {48, -23, -22, .088, .086, .111}, {12, -16, -5}, {-4, -19, -7},
    {68, -9, 3, -.021, .07, -.34, .74})
local galeWithdraw = fitted({-.079, -.212, -.15, -10, 11, 6}, {48, 20, 33, -.106, .079, .034},
    {54, -19, -12, .078, .075, .039}, {10, -9, -4}, {-5, -10, -5},
    {43, -12, 4, .043, .045, -.135, .42})
local galeEase = fitted({-.043, -.175, -.049, -8, 7, 4}, rightGuard, leftGuard,
    {9, -6, -2}, {-8, -7, -3})

local hookLiftAt, hookPlantAt = .071, .478
local galeLiftAt, galePlantAt = .456, 1.02
local perchCenter = v(0, -rootHeight, -.545)
local variantContact = {skyFletch = .138, perchHook = .247, staticPerch = .67, splitGale = table.freeze({.34, .70})}
local variantClips = {
    skyFletch = {{0, variantReady}, {.051, fletchTuck}, {variantContact.skyFletch, fletchHit},
        {.233, fletchEase}, {.37, variantReady}},
    perchHook = {{0, variantReady}, {hookLiftAt, hookGather}, {.142, hookTuck}, {variantContact.perchHook, hookHit},
        {.343, hookEase}, {hookPlantAt, variantReady}, {.52, variantReady}},
    staticPerch = {{0, variantReady}, {.194, perchBrace}, {.348, perchFan}, {.434, perchFan},
        {.574, perchFall}, {variantContact.staticPerch, perchMat}, {.708, perchMat},
        {.798, perchRebound}, {1.05, perchEase}, {1.31, variantReady}},
    splitGale = {{0, variantReady}, {.149, galeWide}, {variantContact.splitGale[1], galeWing},
        {galeLiftAt, galeSwap}, {.569, galeCoil}, {variantContact.splitGale[2], galeKick},
        {.823, galeWithdraw}, {galePlantAt, galeEase}, {1.19, variantReady}},
}
-- Latch each direct hit to its visible padded wing or blunt toe cap.
local variantHits = {
    skyFletch = {{fletchHit, "Left Shoulder", v(-1.443219632, 1.890857345, -.575199370)}},
    perchHook = {{hookHit, rightHip, v(.498905074, .103169735, -.773073884)}},
    staticPerch = {perchCenter},
    splitGale = {{galeWing, "Left Shoulder", v(-1.464886828, 1.909588554, -.550228012)},
        {galeKick, rightHip, v(.493949945, .098623919, -.768893407)}},
}
local basicSkills = {
    skyFletch = table.freeze({damage = 11, radius = .43}),
    perchHook = table.freeze({damage = 14, radius = .48, foot = true}),
}
local variants = rig.finish(variantClips, variantContact, variantHits, basicSkills, {}, {})
local poses = table.clone(standard)
poses.UltimateSkill = table.freeze({
    staticPerch = table.freeze({damage = 28, center = perchCenter, radius = 2.55, warningAt = .24}),
    splitGale = table.freeze({damage = table.freeze({13, 20}), radius = table.freeze({.47, .54}), feet = table.freeze({false, true})}),
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
        local both = if action == "perchHook" then time <= hookLiftAt or time >= hookPlantAt
            elseif action == "splitGale" then time <= galeLiftAt or time >= galePlantAt
            else true
        return plantTalons(variants.sample(action, time, direction), both)
    end
    return standard.sample(action, age, direction)
end

function poses.impact(action, index, direction)
    local source = if variantContact[action] then variants else standard
    return source.impact(action, index, direction)
end

return table.freeze(poses)
