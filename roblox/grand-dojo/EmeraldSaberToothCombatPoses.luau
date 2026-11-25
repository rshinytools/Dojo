-- Emerald Saber-Tooth loads from a long stance and drops its leading paw through the landing.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    return {v(side * .18, .014, -.86), v(side * .88, .014, -.86),
        v(side * .18, .014, .22), v(side * .88, .014, .22)}
end

local rig = Choreography.new(rootHeight, {
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

local mossLoad = pose({-.078, -.255, .075, -9, 13, 6}, {49, 17, -23, .025, .10, .08},
    {39, -11, 28, -.055, .065, .14}, rear, lead, {10, -11, -5}, {-9, -12, -8})
local mossHit = pose({-.025, -.235, -.165, -12, -17, 4}, {49, 13, -25, .022, .105, .065},
    {56, -23, 7, .15, .05, -.14}, rear, lead, {13, 16, -4}, {-8, 24, -3})
local mossFold = pose({-.045, -.275, -.045, -11, -10, 6}, rightGuard,
    {49, -29, 21, .095, .095, .10}, rear, lead, {12, 8, -5}, {-7, 16, -2})

local prowlLower = pose({.075, -.355, .10, -16, -22, -8}, {31, 8, -39, .095, .015, .15},
    {59, -22, 19, .095, .09, .035}, rear, lead, {16, 22, 5}, {-13, 32, 5})
local prowlLoad = pose({.128, -.48, .16, -17, -39, -10}, {25, -9, -39, .16, .045, .21},
    {58, -16, 26, .025, .145, .035}, rear, lead, {18, 34, 9}, {-17, 51, 11})
local prowlDrive = pose({.09, -.39, -.045, -19, 1, -7}, {48, 14, -29, .11, -.015, -.018},
    {57, -21, 20, .065, .12, .075}, rear, lead, {17, 0, 3}, {-9, 14, 4})
local prowlHit = pose({.03, -.29, -.33, -16, 27, -4}, {60, 31, -9, -.15, .025, -.20},
    {55, -20, 15, .07, .13, .13}, rear, lead, {15, -22, 3}, {4, -23, -8})
local prowlFollow = pose({-.10, -.36, -.16, -18, 45, 6}, {46, 40, 8, -.24, .045, -.055},
    leftGuard, rear, lead, {18, -37, -4}, {-4, -42, -11})
local prowlFold = pose({-.025, -.24, .005, -9, 6, 3}, {47, 16, -23, -.035, .085, .065},
    leftGuard, rear, lead, {9, -7, -2}, {-7, -3, -5})

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

-- Vine Flick checks from the outside edge of the left glove with the right guard raised.
local vineDraw = pose({-.065, -.235, .055, -8, 14, 7}, {47, 16, -22, .015, .095, .045},
    {37, -3, 29, -.06, .105, .14}, rear, lead, {8, -13, -4}, {-8, -12, -4})
local vineHit = pose({-.07, -.16, -.13, -9, -22, 5}, {47, 16, -23, .015, .095, .045},
    {55, -25, 12, .135, .085, -.075}, rear, lead, {9, 21, -4}, {-6, 29, 5})
local vineFold = pose({-.02, -.21, -.032, -9, -17, 4}, rightGuard,
    {49, -22, 22, .09, .085, .04}, rear, lead, {9, 17, -3}, {-8, 20, 2})

-- Briar Step leaves the right sole in place and flicks the lead boot forward below the guard.
local briarLoad = pose({.155, -.21, .065, -5, -9, -11}, {45, 18, -25, .035, .09, .06},
    {60, -24, 24, .125, .12, .025}, rear, {23, 12, -3, -.025, .02, -.29, .29},
    {5, 9, 7}, {-9, 15, 9})
local briarHit = pose({.15, -.175, -.23, -2, 3, -9}, {46, 18, -23, .035, .09, .075},
    {58, -23, 26, .126, .12, .035}, rear, {42, -12, -4, .060, .025, -.47, .48},
    {4, -3, 6}, {-6, -11, 10})
local briarFold = pose({.13, -.21, -.075, -4, -4, -9}, {44, 16, -23, .04, .095, .065},
    {57, -22, 25, .124, .12, .005}, rear, {27, 3, -3, .005, .015, -.29, .315},
    {6, 4, 6}, {-8, 7, 8})
local briarSettle = pose({.075, -.209, .014, -8, -11, -2}, rightGuard,
    leftGuard, rear, {14, 13, 0, -.07, 0, -.24, .068}, {9, 10, 2}, {-9, 17, 3})

-- Grove Break turns the broad shoulder plate into the contact while both soles stay fixed.
local groveBrace = pose({.095, -.28, .085, -11, -27, -6}, {36, 18, -26, .065, .065, .14},
    {66, -28, 20, .14, .145, .045}, rear, lead, {10, 23, 5}, {-10, 26, 8})
local groveShow = pose({.12, -.22, .115, -7, -38, -6}, {60, 0, -15, .105, .145, .12},
    {74, -25, 22, .12, .155, -.025}, rear, lead, {7, 33, 4}, {-7, 39, 10})
local groveTurn = pose({.05, -.355, -.04, -18, 9, -3}, {47, 17, -28, -.015, .045, -.045},
    {70, -27, 28, .135, .15, .06}, rear, lead, {16, -7, 5}, {-13, -12, 7})
local groveHit = pose({-.09, -.40, -.475, -21, 49, -8}, {34, 16, -44, -.10, -.075, -.16},
    {66, -28, 26, .12, .12, .035}, rear, lead, {14, -40, 8}, {-14, -46, 12})
local groveEase = pose({-.08, -.405, -.28, -19, 58, -7}, {34, 14, -43, -.095, -.06, -.115},
    {60, -27, 29, .122, .115, .075}, rear, lead, {14, -46, 7}, {-12, -54, 12})
local groveRecover = pose({.035, -.28, -.04, -13, 9, -3}, {40, 15, -26, .015, .08, .045},
    leftGuard, rear, lead, {11, -8, 1}, {-10, -9, 4})

-- Verdant Cross places a low left paw before the opposite glove climbs through the torso line.
local verdantDraw = pose({-.095, -.32, .07, -16, 27, 8}, {52, 20, -24, .015, .105, .07},
    {26, -3, 31, -.06, .025, .175}, rear, lead, {15, -23, -5}, {-12, -29, -8})
local verdantLow = pose({-.095, -.355, -.205, -17, -25, 6}, {51, 21, -23, .015, .13, .09},
    {46, -23, 14, .105, -.025, -.23}, rear, lead, {16, 23, -5}, {-8, 29, 4})
local verdantShift = pose({.045, -.28, -.085, -10, -13, -5}, {29, 6, -29, .04, .08, .045},
    {57, -22, 23, .135, .115, .015}, rear, lead, {10, 12, 4}, {-12, 15, -8})
local verdantLoad = pose({.095, -.32, .035, -13, -29, -8}, {25, 8, -31, .055, .08, .145},
    {59, -23, 25, .135, .13, .06}, rear, lead, {12, 25, 6}, {-13, 34, 6})
local verdantHigh = pose({.08, -.11, -.285, -4, 26, -5}, {83, 19, -17, -.145, .125, -.225},
    {61, -24, 29, .115, .135, .025}, rear, lead, {4, -23, 3}, {-8, -32, 6})
local verdantCarry = pose({.055, -.145, -.17, -6, 35, -6}, {74, 20, -24, -.115, .13, -.125},
    {58, -22, 27, .10, .125, .06}, rear, lead, {6, -30, 4}, {-8, -40, 8})
local verdantRecover = pose({.05, -.225, -.033, -10, 3, -1}, {47, 16, -26, .015, .09, .015},
    leftGuard, rear, lead, {9, -3, 1}, {-10, -6, 4})

local contact = {jab = .155, cross = .218, body = .268, heavy = .413, jadeRake = .31,
    vineFlick = .155, briarStep = .24, groveBreak = .64, verdantCross = table.freeze({.30, .65}),
    mossPalm = .24, emeraldProwl = .48, apexPounce = .54}
local teleportAt = .41
local clips = {
    stance = {{0, ready}, {.55, breathe}, {1.10, ready}},
    advance = {{0, ready}, {.139, springLead}, {.277, ready}, {.414, springRear}, {.555, ready}},
    retreat = {{0, ready}, {.154, backRear}, {.31, ready}, {.461, backLead}, {.617, ready}},
    sidestep = {{0, ready}, {.102, slip}, {.219, set}, {.44, ready}},
    jab = {{0, ready}, {.067, jabWind}, {contact.jab, jabHit}, {.211, jabHit}, {.411, ready}},
    vineFlick = {{0, ready}, {.067, vineDraw}, {contact.vineFlick, vineHit}, {.257, vineFold}, {.39, ready}},
    briarStep = {{0, ready}, {.104, briarLoad}, {contact.briarStep, briarHit}, {.345, briarFold}, {.438, briarSettle}, {.52, ready}},
    groveBreak = {{0, ready}, {.165, groveBrace}, {.34, groveShow}, {.425, groveShow}, {.536, groveTurn},
        {contact.groveBreak, groveHit}, {.694, groveHit}, {.81, groveEase}, {1.042, groveRecover}, {1.25, ready}},
    verdantCross = {{0, ready}, {.142, verdantDraw}, {contact.verdantCross[1], verdantLow}, {.434, verdantShift},
        {.52, verdantLoad}, {contact.verdantCross[2], verdantHigh}, {.76, verdantCarry}, {.945, verdantRecover}, {1.14, ready}},
    cross = {{0, ready}, {.09, crossWind}, {contact.cross, crossHit}, {.302, crossHit}, {.498, ready}},
    body = {{0, ready}, {.118, bodyWind}, {contact.body, bodyHit}, {.377, breathe}, {.550, ready}},
    heavy = {{0, ready}, {.18, heavyWind}, {.266, heavyWind}, {contact.heavy, heavyHit},
        {.524, heavyFollow}, {.795, ready}},
    jadeRake = {{0, ready}, {.15, rakeWind}, {.229, rakeStart}, {contact.jadeRake, rakeHit},
        {.416, rakeFollow}, {.567, breathe}, {.676, ready}},
    mossPalm = {{0, ready}, {.088, mossLoad}, {contact.mossPalm, mossHit}, {.334, mossFold}, {.60, ready}},
    emeraldProwl = {{0, ready}, {.135, prowlLower}, {.226, prowlLoad}, {.298, prowlLoad}, {.391, prowlDrive},
        {contact.emeraldProwl, prowlHit}, {.59, prowlFollow}, {.735, prowlFold}, {.94, ready}},
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
-- The visible jade pad leads the contact cue as the glove rotates around the shoulder.
local function gauntletContact(authored, joint, side)
    local frame = authored.RootJoint * authored[joint]
    local radii = v(.251, .1355, .057)
    local front = frame:VectorToObjectSpace(-Vector3.zAxis) * radii
    return frame:PointToWorldSpace(v(side * 1.255, 1.865 - rootHeight, -.858) + front * radii / front.Magnitude)
end

-- Contact points are defined on the fitted pads, armor and lead boot.
local function mountedSurface(key, joint, rest)
    return (key.RootJoint * key[joint]):PointToWorldSpace(rest)
end

local vinePad = v(-1.488144442, -.313754413, -.865680121)
local briarPad = v(-.555178188, -2.037314512, -.900615586)
local grovePlate = v(1.593382877, .930644420, -.473482031)
local verdantLowPad = v(-1.610769435, -.307554646, -.746906292)
local verdantHighPad = v(1.612287009, -.410812590, -.602435819)
local hits = {
    vineFlick = {mountedSurface(vineHit, "Left Shoulder", vinePad)},
    briarStep = {mountedSurface(briarHit, "Left Hip", briarPad)},
    groveBreak = {mountedSurface(groveHit, "Right Shoulder", grovePlate)},
    verdantCross = {
        mountedSurface(verdantLow, "Left Shoulder", verdantLowPad),
        mountedSurface(verdantHigh, "Right Shoulder", verdantHighPad),
    },
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    jadeRake = {{rakeHit, "Left Shoulder", leftPad}}, apexPounce = {{land, "Right Shoulder", rightPad}},
    mossPalm = {gauntletContact(mossHit, "Left Shoulder", -1)},
    emeraldProwl = {gauntletContact(prowlHit, "Right Shoulder", 1)},
}
local skills = {
    vineFlick = table.freeze({damage = 12, radius = .43}),
    briarStep = table.freeze({damage = 14, radius = .47, foot = true}),
    jadeRake = table.freeze({damage = 21, radius = .61, shove = .96}),
    mossPalm = table.freeze({damage = 15, radius = .40}),
    emeraldProwl = table.freeze({damage = 23, radius = .49}),
    apexPounce = table.freeze({damage = 26, teleportAt = teleportAt}),
}
local travel = {
    jadeRake = table.freeze({axis = "forward", distance = .33, startsAt = .18, endsAt = .30}),
}

local standard = rig.finish(clips, contact, hits, skills, travel, {"sidestep"}, {
    mossPalm = true, emeraldProwl = true, vineFlick = true, groveBreak = true, verdantCross = true,
})
local poses = table.clone(standard)
local fixedRear = ready.RootJoint * ready["Right Hip"]

function poses.sample(action, age, direction)
    local offsets = standard.sample(action, age, direction)
    if action == "briarStep" then
        offsets["Right Hip"] = offsets.RootJoint:ToObjectSpace(fixedRear)
    end
    return offsets
end

poses.UltimateSkill = table.freeze({
    groveBreak = table.freeze({damage = 32, radius = .56}),
    verdantCross = table.freeze({damage = table.freeze({12, 22}), radius = table.freeze({.45, .49})}),
})
return table.freeze(poses)
