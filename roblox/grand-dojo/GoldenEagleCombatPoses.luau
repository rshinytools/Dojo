-- Golden Eagle opens his wings before stepping out of guard and uses both
-- talons to catch and carry. All contact coordinates come from the native rig.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    local x = side * .49
    return {v(x - .29, .012, -.81), v(x + .29, .012, -.81),
        v(x - .29, .012, .19), v(x + .29, .012, .19)}
end

local rig = Choreography.new(rootHeight, {
    Neck = v(0, 3.21, -.045),
    ["Right Shoulder"] = v(.94, 3.09, .03), ["Left Shoulder"] = v(-.94, 3.09, .03),
    ["Right Hip"] = v(.49, 1.51, .045), ["Left Hip"] = v(-.49, 1.51, .045),
    TailJoint = v(0, 1.76, .57),
}, sole(1), sole(-1))
local pose = rig.pose

local rear = {7, -20, 0, .13, 0, .18, .018}
local lead = {10, 12, 0, -.07, 0, -.22, .018}
local rightGuard = {57, 13, 19, -.065, .065, -.035}
local leftGuard = {63, -15, -22, .085, .071, -.067}
local ready = pose({.015, -.131, .022, -7, 9, -3}, rightGuard, leftGuard, rear, lead,
    {7, -8, 2}, {-8, 5, 4})
local breathe = pose({.015, -.087, .023, -2, 7, -2}, {53, 11, 22, -.072, .086, -.037},
    {66, -17, -25, .082, .061, -.053}, rear, lead, {2, -7, 3}, {-6, -6, 3})
local stepLead = pose({-.11, -.189, -.174, -13, 11, 6}, {62, 17, 18}, {44, -10, -22},
    rear, {23, 12, -2, -.115, 0, -.284, .176}, {13, -10, -4}, {-13, 17, -5})
local stepRear = pose({.121, -.183, -.172, -13, -9, -6}, {47, 13, 19}, {63, -13, -24},
    {25, -17, 3, .125, 0, -.277, .176}, lead, {13, 8, 5}, {-13, -18, 6})
local backRear = pose({.12, -.112, .16, 4, 13, -9}, {53, 9, 25}, {68, -18, -17},
    {-14, -23, 3, .16, 0, .28, .15}, lead, {-4, -12, 6}, {-8, 24, 8})
local backLead = pose({-.11, -.12, .15, 3, -5, 7}, {63, 13, 23}, {47, -18, -26},
    rear, {-12, 14, -3, -.10, 0, .28, .145}, {-3, 4, -5}, {-9, -21, -6})
local slip = pose({.29, -.25, .012, -10, 16, -23}, {44, 11, 50}, {65, -26, -20},
    {11, -26, 5, .30, 0, .11, .16}, lead, {9, -15, 16}, {-13, 29, 13})
local catch = pose({.176, -.212, -.04, -11, 19, -10}, {47, 17, 31}, leftGuard,
    {7, -21, 1, .27, 0, .088, .018}, lead, {11, -18, 8}, {-14, -23, 7})

local jabLoad = pose({.085, -.165, .093, -6, -17, -5}, {33, 6, 20, .068, .025, .145},
    leftGuard, rear, lead, {7, 15, 4}, {-8, 17, 5})
local jabHit = pose({.03, -.113, -.249, -6, 25, -3}, {71, 15, -12, -.16, .075, -.235},
    leftGuard, rear, lead, {6, -25, 3}, {-8, -32, 6})
local crossLoad = pose({-.115, -.208, .126, -10, 26, 8}, rightGuard, {33, 7, -24, -.075, .052, .22},
    rear, lead, {12, -25, -7}, {-10, -27, -9})
local crossHit = pose({-.065, -.15, -.258, -9, -30, 5}, {62, 16, 21},
    {70, -23, 10, .167, .091, -.256}, rear, lead, {9, 28, -4}, {-9, 33, 6})
local bodyLoad = pose({.069, -.333, .063, -17, -25, -8}, {24, -13, 36, .09, -.034, .16},
    leftGuard, rear, lead, {17, 23, 6}, {-10, 30, -9})
local bodyHit = pose({.087, -.33, -.255, -17, 28, -1}, {57, 23, -10, -.21, -.061, -.228},
    {60, -21, -26}, rear, lead, {17, -26, 1}, {-12, -35, 7})
local heavyLoad = pose({-.118, -.29, .181, -16, 38, 12}, {63, 16, 19},
    {21, -35, -60, -.10, .051, .285}, rear, lead, {17, -34, -9}, {-14, -41, -9})
local heavyHit = pose({-.071, -.197, -.284, -13, -38, 7}, {54, 24, 19},
    {68, -26, 12, .198, .111, -.257}, rear, lead, {13, 35, -6}, {-13, 43, 9})
local heavyCarry = pose({-.085, -.245, -.156, -16, -46, 10}, rightGuard,
    {51, -36, 16, .172, .033, -.12}, rear, lead, {16, 42, -8}, {-14, 46, 8})

local rakeWind = pose({.09, -.24, .135, -10, -37, -6}, {24, -32, 74, .086, .107, .147},
    {65, -18, -21}, rear, lead, {10, 35, 5}, {-13, 40, -10})
local rakeDrive = pose({.045, -.189, -.092, -12, 8, -4}, {54, 10, 45, -.066, .113, -.092},
    {64, -15, -24}, rear, lead, {11, -7, 3}, {-10, -8, 5})
local rakeHit = pose({-.014, -.162, -.271, -11, 32, 5}, {68, 26, -9, -.20, .106, -.266},
    {63, -18, -22}, rear, lead, {11, -29, -3}, {-12, -37, 8})
local rakeFollow = pose({-.117, -.252, -.141, -17, 42, 12}, {52, 34, -18, -.247, .033, -.11},
    leftGuard, rear, lead, {17, -39, -10}, {-12, -48, 9})

local flickDraw = pose({-.034, -.144, .081, -7, 14, 4}, rightGuard,
    {47, 4, -39, -.028, .052, .118}, rear, lead, {7, -13, -4}, {-9, -9, 0})
local flickUnfold = pose({-.049, -.184, -.032, -9, -16, 4}, {57, 13, 18, -.069, .068, -.031},
    {67, -11, -22, .025, .065, .023}, rear, lead, {9, 16, -4}, {-11, 19, -4})
local flickHit = pose({-.029, -.211, .105, -9, -42, 3}, {58, 14, 18, -.062, .069, -.042},
    {108, -18, 5, .055, .051, .1}, rear, lead, {10, 32, -1}, {-11, 32, -6})
local flickRecover = pose({-.03, -.190, .048, -8, -17, 2}, rightGuard,
    {79, -14, -21, .067, .069, .014}, rear, lead, {9, 16, -2}, {-10, 15, -4})

local crosswindDraw = pose({.085, -.249, .138, -12, -35, -7}, {31, -27, 77, -.085, .042, .115},
    {56, -19, -38, .082, .077, .03}, rear, lead, {12, 33, 6}, {-13, 36, -6})
local crosswindCoil = pose({.085, -.318, .079, -17, -29, -7}, {39, -25, 68, -.102, .040, .088},
    {59, -18, -33, .096, .076, .028}, rear, lead, {18, 26, 5}, {-13, 31, -5})
local crosswindSwing = pose({.051, -.255, -.045, -13, -4, -4}, {54, 4, 42, -.077, .075, -.075},
    {60, -13, -35, .085, .082, -.012}, rear, lead, {13, 4, 3}, {-11, 7, -3})
local crosswindHit = pose({.055, -.205, -.278, -10, 31, -2}, {77, 25, -10, -.157, .104, -.225},
    {64, -18, -25, .093, .082, -.047}, rear, lead, {10, -33, 2}, {-10, -37, 6})
local crosswindCarry = pose({.075, -.272, -.14, -16, 45, -6}, {64, 33, -16, -.134, .083, -.135},
    {59, -18, -30, .084, .078, -.02}, rear, lead, {17, -41, 5}, {-17, -44, 8})
local crosswindSettle = pose({.03, -.215, -.047, -10, 21, -4}, {59, 18, 15, -.078, .08, -.057},
    leftGuard, rear, lead, {10, -18, 4}, {-11, -17, 5})

local takeoffRight = {6, -16, 0, .12, 0, .22, .018}
local takeoffLeft = {10, 18, 0, -.12, 0, -.15, .018}
local preload = pose({0, -.43, .143, -21, 0, 0}, {27, -13, 53, .06, .045, .07},
    {30, 14, -53, -.055, .043, .07}, takeoffRight, takeoffLeft, {20, 0, 0}, {-17, 5, 1})
local wingUp = pose({.015, .39, -.049, -4, 0, 0}, {45, -17, 89, .065, .085, .04},
    {45, 17, -89, -.06, .085, .04}, {24, -14, 0, .10, 0, .08, .50},
    {22, 12, 0, -.092, 0, -.12, .58}, {2, 0, 0}, {-20, -7, 0})
local grabRight = {45, -7, 4, -.02, 0, -.23, 1.10}
local grabLeft = {47, 6, -4, .019, 0, -.24, 1.12}
local grab = pose({.0, .94, -.26, -15, 0, 0}, {37, -23, 66, .045, .096, .08},
    {38, 22, -69, -.045, .096, .08}, grabRight, grabLeft, {11, 0, 0}, {-21, 4, 0})

local carryRight = {49, -9, 4, -.03, 0, -.13, 1.23}
local carryLeft = {50, 8, -4, .026, 0, -.15, 1.22}
local carryLift = pose({-.028, 1.22, -.211, -10, 0, 4}, {42, -14, 88, .07, .102, .07},
    {40, 15, -88, -.071, .10, .07}, carryRight, carryLeft, {6, 0, -4}, {-18, 10, -7})
local carryPressed = pose({.026, 1.10, -.195, -12, 0, -3}, {42, -24, 46, .04, .053, .07},
    {43, 23, -46, -.04, .053, .07}, carryRight, carryLeft, {10, 0, 3}, {-23, -10, 6})
local aimThrow = pose({.026, 1.16, -.235, -24, 1, -4}, {38, -22, 77, .071, .105, .07},
    {39, 22, -75, -.079, .10, .07}, {42, -10, 5, .025, 0, -.19, 1.35},
    {47, 10, -5, -.015, 0, -.18, 1.34}, {18, -1, 3}, {-24, -9, 5})
local castDown = pose({-.007, .92, -.26, -31, 0, 0}, {34, -16, 71, .05, .08, .03},
    {36, 15, -71, -.049, .083, .03}, {56, -13, 1, .06, 0, -.60, .54},
    {57, 11, -1, -.06, 0, -.60, .56}, {26, 0, 0}, {-27, 4, 0})
local descend = pose({0, .31, -.13, -18, 0, 0}, {34, -14, 68}, {35, 14, -67},
    {25, -11, 0, .07, 0, -.18, .26}, {24, 11, 0, -.07, 0, -.21, .25}, {15, 0, 0}, {-19, -3, 0})
local land = pose({0, -.36, -.15, -19, 0, 0}, {38, -14, 61}, {39, 15, -61},
    {14, -15, 0, .13, 0, .044, .018}, {15, 16, 0, -.12, 0, -.218, .018}, {15, 0, 0}, {-14, 3, 0})
local recover = pose({.013, -.24, -.044, -11, -2, 1}, rightGuard,
    {56, -14, -30}, rear, lead, {11, 2, -1}, {-11, -5, 0})

local cover = pose({.001, -.298, .06, -15, 0, 0}, {67, 19, -11, -.12, .101, -.072},
    {69, -18, 11, .121, .104, -.062}, rear, lead, {14, 0, 0}, {-10, 7, 0})
local recoil = pose({-.073, -.301, .158, 7, -6, 8}, {61, 17, -12, -.094, .065, .07},
    {63, -16, 14, .118, .073, .07}, rear, lead, {-8, 6, -6}, {-11, 13, -8})
local deflect = pose({.046, -.27, -.128, -17, 24, -5}, {68, 5, -14, -.14, .159, -.134},
    {61, -15, -18, .08, .091, .035}, rear, lead, {17, -23, 4}, {-12, -28, 6})
local headHit = pose({-.117, -.267, .185, 14, -22, 11}, {39, 12, 32}, {42, -14, -29},
    rear, lead, {-19, 17, -10}, {-12, 22, -11})
local bodyHurt = pose({.111, -.42, .157, -26, 18, -10}, {33, 12, 26}, {40, -12, -25},
    rear, lead, {24, -17, 9}, {-14, -23, 8})
local salute = pose({.028, -.075, -.043, 2, -14, 5}, {80, 4, 7, -.064, .133, -.058},
    leftGuard, rear, lead, {-2, 14, -5}, {-6, 17, -6})
local bow = pose({0, -.30, -.134, -27, 0, 0}, {37, 10, 22}, {37, -12, -22},
    rear, lead, {21, 0, 0}, {-12, -4, 0})
local crown = pose({0, -.064, .028, 7, 0, 0}, {62, -20, 82, .058, .12, .042},
    {61, 21, -82, -.058, .116, .042}, takeoffRight, takeoffLeft, {-7, 0, 0}, {-9, 4, 0})

local grabAt, carryDuration = .36, 1.50
local throwAt, impactAt = grabAt + carryDuration, 2.02
local contacts = {jab = .159, cross = .224, body = .269, heavy = .415, galeRake = .29,
    gildedFlick = .25, crosswindWing = .49,
    talonDrop = table.freeze({grabAt, throwAt, impactAt})}
local clips = {
    stance = {{0, ready}, {.63, breathe}, {1.26, ready}},
    advance = {{0, ready}, {.153, stepLead}, {.305, breathe}, {.456, stepRear}, {.621, ready}},
    retreat = {{0, ready}, {.163, backRear}, {.324, breathe}, {.487, backLead}, {.661, ready}},
    sidestep = {{0, ready}, {.117, slip}, {.247, catch}, {.445, ready}},
    jab = {{0, ready}, {.073, jabLoad}, {contacts.jab, jabHit}, {.217, jabHit}, {.41, ready}},
    cross = {{0, ready}, {.093, crossLoad}, {contacts.cross, crossHit}, {.284, crossHit}, {.487, ready}},
    body = {{0, ready}, {.111, bodyLoad}, {contacts.body, bodyHit}, {.369, breathe}, {.562, ready}},
    heavy = {{0, ready}, {.175, heavyLoad}, {.263, heavyLoad}, {contacts.heavy, heavyHit},
        {.521, heavyCarry}, {.776, ready}},
    galeRake = {{0, ready}, {.121, rakeWind}, {.204, rakeDrive}, {contacts.galeRake, rakeHit},
        {.39, rakeFollow}, {.50, breathe}, {.629, ready}},
    gildedFlick = {{0, ready}, {.087, flickDraw}, {.171, flickUnfold}, {contacts.gildedFlick, flickHit},
        {.341, flickRecover}, {.62, ready}},
    crosswindWing = {{0, ready}, {.183, crosswindDraw}, {.267, crosswindDraw}, {.341, crosswindCoil},
        {.410, crosswindSwing}, {contacts.crosswindWing, crosswindHit}, {.602, crosswindCarry},
        {.767, crosswindSettle}, {.94, ready}},
    talonDrop = {{0, ready}, {.16, preload}, {.258, wingUp}, {grabAt, grab}, {.52, carryLift},
        {.72, carryPressed}, {.93, carryLift}, {1.14, carryPressed}, {1.35, carryLift},
        {1.57, carryPressed}, {1.74, aimThrow}, {throwAt, castDown}, {1.959, descend}, {impactAt, land},
        {2.16, recover}, {2.39, ready}},
    talonDropMiss = {{0, ready}, {.16, preload}, {.258, wingUp}, {grabAt, grab}, {.49, descend},
        {.555, land}, {.684, recover}, {.78, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.075, recoil}, {.151, recoil}, {.279, cover}},
    parry = {{0, cover}, {.077, deflect}, {.16, deflect}, {.335, ready}},
    hitHead = {{0, ready}, {.072, headHit}, {.154, headHit}, {.35, ready}},
    hitBody = {{0, ready}, {.084, bodyHurt}, {.169, bodyHurt}, {.372, ready}},
    stagger = {{0, headHit}, {.151, catch}, {.319, recoil}, {.533, ready}},
    intro = {{0, ready}, {.83, breathe}, {1.32, salute}, {2.03, salute}, {2.51, bow}, {3.03, ready},
        {3.74, rakeWind}, {4.13, rakeHit}, {4.57, rakeFollow}, {5.04, ready},
        {5.92, preload}, {6.26, wingUp}, {6.61, grab}, {6.90, descend}, {7.23, land},
        {7.75, ready}, {8.59, crown}, {9.09, crown}, {10, ready}},
    win = {{0, ready}, {.37, crown}, {1.19, crown}, {1.51, bow}, {1.8, bow}, {2.18, ready}},
}

local rightWing, leftWing = v(1.30, 1.92, -.815), v(-1.30, 1.92, -.815)
local rightTalon, leftTalon = v(.49, .173, -.8625), v(-.49, .173, -.8625)
local origin = v(0, rootHeight, 0)
local function talons(poseAt)
    return (poseAt.RootJoint * poseAt["Right Hip"]):PointToWorldSpace(rightTalon - origin),
        (poseAt.RootJoint * poseAt["Left Hip"]):PointToWorldSpace(leftTalon - origin)
end

local function betweenTalons(poseAt)
    local right, left = talons(poseAt)
    return (right + left) / 2
end

local hits = {
    jab = {{jabHit, "Right Shoulder", rightWing}}, cross = {{crossHit, "Left Shoulder", leftWing}},
    body = {{bodyHit, "Right Shoulder", rightWing}}, heavy = {{heavyHit, "Left Shoulder", leftWing}},
    galeRake = {{rakeHit, "Right Shoulder", rightWing}},
    gildedFlick = {{flickHit, "Left Shoulder", v(-1.633774943, 1.634514565, .560177260)}},
    crosswindWing = {{crosswindHit, "Right Shoulder", v(1.527881190, 1.831077922, -.734102860)}},
    talonDrop = {betweenTalons(grab), betweenTalons(castDown), v(0, -rootHeight, 0)},
}
local skills = {
    galeRake = table.freeze({damage = 20, radius = .63, shove = .81}),
    gildedFlick = table.freeze({damage = 15, radius = .48}),
    crosswindWing = table.freeze({damage = 23, radius = .55}),
    talonDrop = table.freeze({
        grabAt = grabAt, carryDuration = carryDuration, throwAt = throwAt, impactAt = impactAt,
        grabRadius = .88, damage = 28, missAction = "talonDropMiss",
    }),
}
local travel = {galeRake = table.freeze({axis = "forward", distance = .26, startsAt = .16, endsAt = .28})}

local standard = rig.finish(clips, contacts, hits, skills, travel, {"sidestep"},
    {gildedFlick = true, crosswindWing = true})
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
local tapFold = fitted({-.033, -.146, .072, -7, 21, 3}, rightGuard,
    {46, -11, -22, .058, .050, .112}, {8, -17, -4}, {-8, -20, -2})
local tapHit = fitted({-.025, -.220, -.071, -11, -27, 4}, {52, 14, 25, -.071, .063, .024},
    {63, -22, 10, .136, .018, -.102}, {13, 25, -3}, {-7, 26, -4})
local tapEase = fitted({-.023, -.167, -.022, -9, -14, 3}, rightGuard,
    {61, -20, -7, .103, .044, -.039}, {10, 13, -3}, {-8, 16, -3})

local toeSet = fitted({-.079, -.180, .049, -6, -9, 7}, {47, 13, 29, -.036, .074, .083},
    {62, -20, -20, .102, .112, -.031}, {8, 9, -5}, {-8, 13, -6})
local toeTuck = fitted({-.116, -.192, .019, -8, -5, 8}, {44, 15, 32, -.055, .075, .070},
    {65, -19, -17, .108, .113, .025}, {8, 6, -5}, {-7, 9, -7},
    {32, -15, 5, .110, .036, .023, .25})
local toeHit = fitted({-.083, -.223, -.189, -11, 15, 8}, {47, 18, 31, -.067, .078, -.009},
    {65, -21, -21, .117, .113, .033}, {11, -13, -4}, {-9, -14, -7},
    {64, -6, 0, -.026, .060, -.289, .56})
local toeEase = fitted({-.064, -.184, -.072, -8, 10, 5}, {49, 16, 28, -.052, .073, -.016},
    {64, -20, -23, .093, .088, -.004}, {9, -9, -3}, {-8, -11, -5},
    {28, -15, 4, .071, .048, -.112, .205})

local fanBrace = fitted({.015, -.227, .083, -11, -4, 1}, {39, -8, 48, -.114, .071, .090},
    {41, 9, -50, .104, .069, .083}, {10, 4, 0}, {-12, 5, 1})
local fanRaise = fitted({.012, -.055, .092, 1, -2, 0}, {93, -13, 81, -.245, .109, .025},
    {94, 11, -84, .235, .107, .023}, {-2, 2, 0}, {-5, 2, 0})
local fanFold = fitted({.015, -.238, -.087, -13, 2, 1}, {70, 12, 27, -.16, .070, -.103},
    {71, -14, -28, .151, .090, -.093}, {13, -2, -1}, {-8, -3, -1})
local fanHit = fitted({.021, -.385, -.332, -24, 4, -1}, {51, 23, -10, -.320, -.084, -.273},
    {50, -21, 10, .29, -.065, -.253}, {18, -3, 0}, {-9, -5, 2})
local fanBrake = fitted({.016, -.36, -.192, -19, 2, 0}, {53, 18, -3, -.193, -.018, -.135},
    {54, -16, 4, .181, -.010, -.127}, {15, -2, -1}, {-8, -4, 1})
local fanEase = fitted({.013, -.224, -.053, -12, 3, -1}, rightGuard, leftGuard,
    {11, -1, 0}, {-8, -4, 1})

local arcLeftLoad = fitted({-.069, -.233, .114, -9, 33, 7}, {59, 14, 20, -.061, .082, .031},
    {40, 14, -64, .138, .041, .141}, {8, -28, -6}, {-12, -34, -6})
local arcLeft = fitted({-.059, -.172, -.186, -12, -33, 4}, {54, 14, 29, -.080, .077, .053},
    {77, -23, 10, .171, .126, -.217}, {10, 29, -3}, {-5, 36, -4})
local arcRightLoad = fitted({.078, -.334, .024, -16, -42, -7}, {33, -16, 66, -.147, .047, .083},
    {53, -18, -26, .095, .079, .040}, {15, 33, 6}, {-10, 39, 6})
local arcRight = fitted({.047, -.316, -.294, -14, 37, -3}, {59, 26, -12, -.222, -.072, -.264},
    {54, -18, -34, .107, .084, .064}, {15, -32, 3}, {-8, -39, 5})
local arcFollow = fitted({.06, -.281, -.135, -15, 30, -4}, {58, 21, -8, -.147, .021, -.101},
    {59, -17, -29, .088, .089, .026}, {13, -27, 3}, {-9, -31, 5})

local toeLiftAt, toePlantAt = .075, .493
local variantContact = {aerieTap = .139, ridgeTalon = .251, sunfanCrash = .63, crownArc = table.freeze({.35, .70})}
local variantClips = {
    aerieTap = {{0, variantReady}, {.054, tapFold}, {variantContact.aerieTap, tapHit},
        {.235, tapEase}, {.375, variantReady}},
    ridgeTalon = {{0, variantReady}, {toeLiftAt, toeSet}, {.15, toeTuck}, {variantContact.ridgeTalon, toeHit},
        {.356, toeEase}, {toePlantAt, variantReady}, {.54, variantReady}},
    sunfanCrash = {{0, variantReady}, {.165, fanBrace}, {.269, fanRaise}, {.387, fanRaise}, {.52, fanFold},
        {variantContact.sunfanCrash, fanHit}, {.755, fanBrake}, {.984, fanEase}, {1.23, variantReady}},
    crownArc = {{0, variantReady}, {.16, arcLeftLoad}, {variantContact.crownArc[1], arcLeft},
        {.51, arcRightLoad}, {variantContact.crownArc[2], arcRight}, {.834, arcFollow}, {1.20, variantReady}},
}
-- Latch the new hits to the fitted feather pads and rounded talon.
local variantHits = {
    aerieTap = {{tapHit, "Left Shoulder", v(-1.533722983, 1.841856833, -.742815435)}},
    ridgeTalon = {{toeHit, rightHip, v(.504152882, .097949048, -.824072211)}},
    sunfanCrash = {{fanHit, "Right Shoulder", v(1.511594266, 1.846692098, -.766753850)}},
    crownArc = {{arcLeft, "Left Shoulder", v(-1.532635011, 1.837074652, -.735892261)},
        {arcRight, "Right Shoulder", v(1.554819913, 1.876090905, -.739465090)}},
}
local basicSkills = {
    aerieTap = table.freeze({damage = 12, radius = .43}),
    ridgeTalon = table.freeze({damage = 15, radius = .48, foot = true}),
}
local variants = rig.finish(variantClips, variantContact, variantHits, basicSkills, {}, {})
local poses = table.clone(standard)
poses.UltimateSkill = table.freeze({
    sunfanCrash = table.freeze({damage = 32, radius = .56}),
    crownArc = table.freeze({damage = table.freeze({13, 21}), radius = table.freeze({.48, .54})}),
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
        local both = action ~= "ridgeTalon" or time <= toeLiftAt or time >= toePlantAt
        return plantTalons(variants.sample(action, time, direction), both)
    end
    return standard.sample(action, age, direction)
end

function poses.impact(action, index, direction)
    local source = if variantContact[action] then variants else standard
    return source.impact(action, index, direction)
end

function poses.talonsAt(age)
    return talons(poses.sample("talonDrop", age))
end

return table.freeze(poses)
