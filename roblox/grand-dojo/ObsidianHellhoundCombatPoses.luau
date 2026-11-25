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

local emberDraw = pose({.044, -.29, .073, -15, -18, -4}, {32, 12, -33, .09, .043, .151},
    leftGuard, rear, lead, {16, 17, 3}, {-18, 21, 6})
local emberHit = pose({-.029, -.235, -.25, -19, 27, 1}, {64, 14, -14, -.158, .071, -.251},
    {62, -17, 27, .081, .082, -.011}, rear, lead, {17, -26, -1}, {-18, -28, 7})
local emberRecover = pose({-.017, -.269, -.051, -16, 15, 1}, {55, 10, -26, -.076, .08, -.073},
    leftGuard, rear, lead, {16, -13, -1}, {-18, -13, 5})

-- Load the outer glove close, then carry it across a low, grounded turn.
local glassDraw = pose({-.14, -.335, .13, -16, 35, 10}, {62, 14, -27, -.044, .124, .041},
    {30, 4, 49, -.09, .065, .21}, rear, lead, {18, -21, -8}, {-20, -37, 8})
local glassHold = pose({-.105, -.427, .075, -23, 39, 10}, {55, 15, -28, -.043, .100, .051},
    {25, 18, 50, -.06, .02, .18}, rear, lead, {24, -27, -8}, {-22, -43, 8})
local glassHit = pose({.017, -.358, -.265, -18, -35, -2}, {51, 17, -29, -.023, .043, .222},
    {64, -20, 8, .157, .059, -.219}, rear, lead, {18, 29, 2}, {-23, 35, -7})
local glassFollow = pose({-.024, -.33, -.174, -21, -44, -6}, {54, 18, -24, -.03, .055, .11},
    {55, -29, 8, .203, .075, -.09}, rear, lead, {20, 40, 4}, {-21, 40, -8})
local glassEase = pose({-.064, -.268, -.049, -15, -19, 5}, rightGuard,
    {55, -21, 23, .126, .072, -.03}, rear, lead, {15, 18, -4}, {-17, 18, -4})

local loadoutRight, loadoutLeft = {55, 12, -25, .016, .079, -.032}, {59, -15, 29, .004, .073, -.045}
local loadoutReady = pose({-.014, -.243, .016, -15, 5, 2}, loadoutRight,
    loadoutLeft, rear, lead, {13, -4, -2}, {-17, 11, 6})
local coalDraw = pose({-.014, -.282, .016, -14, 14, 5}, {59, 14, -29, -.04, .083, .035},
    {39, -8, 20, .025, .071, .145}, rear, lead, {13, -13, -4}, {-17, -14, -5})
local coalHit = pose({-.014, -.214, .016, -13, -21, 5}, {57, 15, -29, -.04, .083, .06},
    {65, -24, 17, .085, .082, -.075}, rear, lead, {12, 18, -4, 0, 0, .059}, {-18, 23, 4})
local coalFold = pose({-.014, -.247, .016, -15, -12, 3}, rightGuard,
    {58, -17, 25, .065, .075, .045}, rear, lead, {14, 11, -2}, {-17, 15, 4})

local toePivot = v(.435, 1.53 - rootHeight, .04)
local toeRight = ready.RootJoint * ready["Right Hip"]
local toeLeft = ready.RootJoint * ready["Left Hip"]
local function toePose(core, right, left, boot, head, tail)
    local offsets = pose(core, right, left, rear, lead, head, tail)
    local swing = CFrame.new(toePivot + v(boot[4], boot[5], boot[6]))
        * CFrame.Angles(math.rad(boot[1]), math.rad(boot[2]), math.rad(boot[3])) * CFrame.new(-toePivot)
    offsets["Right Hip"] = offsets.RootJoint:ToObjectSpace(swing * toeRight)
    return offsets
end
local toeLoad = toePose({-.014, -.285, .016, -10, 2, 10}, {58, 14, -23, .03, .089, .06},
    {62, -16, 23, -.027, .095, .055}, {4, 3, -1, -.018, .070, .065}, {9, -2, -7}, {-19, 14, 6})
local toeRaise = toePose({-.014, -.237, .016, -3, -1, 13}, {60, 16, -26, .045, .093, .065},
    {60, -17, 24, -.04, .099, .03}, {11, 10, -4, -.025, .224, .065}, {5, 1, -9}, {-20, 16, 8})
local toeHit = toePose({-.014, -.19, .016, -1, -8, 10}, {58, 16, -25, .04, .091, .075},
    {61, -21, 24, -.031, .104, -.01}, {18, 27, -4, -.20, .061, -.55}, {4, 7, -7}, {-19, 22, 7})
local toeTuck = toePose({-.014, -.24, .016, -6, -5, 8}, {57, 15, -24, .034, .09, .035},
    {62, -19, 25, -.024, .092, .025}, {11, 10, -3, -.035, .158, -.04}, {8, 5, -5}, {-18, 16, 6})
local toeRecover = toePose({-.014, -.264, .016, -12, 2, 4}, loadoutRight,
    loadoutLeft, {4, 3, -1, -.012, .075, .025}, {11, -2, -3}, {-17, 13, 6})

local crownBrace = pose({-.014, -.37, .016, -12, 5, 4}, {46, 12, -23, .016, .09, .155},
    {50, -15, 24, -.014, .095, .15}, rear, lead, {15, -4, -3}, {-19, -7, -4})
local crownShow = pose({-.014, -.17, .016, 10, 3, 1}, {45, 10, -20, .025, .11, .22},
    {47, -10, 22, -.025, .105, .22}, rear, lead, {26, -3, -1}, {-27, -12, -3})
local crownFold = pose({-.014, -.32, .016, -11, 2, 1}, {39, 12, -23, .02, .07, .245},
    {42, -13, 24, -.02, .072, .225}, rear, lead, {-1, -2, -1, 0, .02, -.035}, {-20, -7, 3})
local crownHit = pose({-.014, -.395, .016, -24, 0, 0}, {38, 14, -24, .017, .062, .275},
    {40, -16, 26, -.011, .060, .265}, rear, lead, {-18, 0, 0, 0, .018, -.15}, {-12, -3, 5})
local crownEase = pose({-.014, -.34, .016, -18, 2, 1}, {46, 12, -23, .02, .072, .17},
    {48, -15, 24, -.018, .071, .175}, rear, lead, {2, -2, -1, 0, .01, -.02}, {-15, -4, 5})
local crownRecover = pose({-.014, -.263, .016, -15, 4, 2}, loadoutRight,
    {56, -16, 29, .004, .076, -.012}, rear, lead, {12, -4, -2}, {-17, 9, 5})

local violetDraw = pose({-.014, -.37, .016, -19, 19, 8}, {58, 15, -31, -.045, .112, .09},
    {36, -1, 25, .035, .064, .19}, rear, lead, {18, -17, -6}, {-18, -24, -6})
local violetLow = pose({-.014, -.41, .016, -19, -28, 7}, {53, 13, -31, -.04, .094, .17},
    {53, -25, 13, .085, -.045, -.26}, rear, lead, {17, 24, -5, 0, 0, .07}, {-17, 27, 6})
local violetPeel = pose({-.014, -.324, .016, -16, -20, -3}, {41, 9, -29, -.043, .073, .17},
    {57, -19, 22, .067, .057, .09}, rear, lead, {15, 17, 3}, {-17, 21, 5})
local violetCoil = pose({-.014, -.308, .016, -15, -32, -9}, {32, 6, -28, -.037, .071, .225},
    {61, -19, 30, .069, .091, .10}, rear, lead, {14, 25, 7}, {-18, 29, 7})
local violetDrive = pose({-.014, -.244, .016, -13, 15, -6}, {62, 18, -18, -.075, .083, -.075},
    {60, -19, 30, .066, .089, .12}, rear, lead, {13, -13, 5}, {-19, -14, 5})
local violetHigh = pose({-.014, -.17, .016, -12, 31, -5}, {79, 27, -11, -.13, .082, -.255},
    {58, -18, 28, .065, .092, .18}, rear, lead, {12, -27, 4}, {-19, -31, 7})
local violetUnwind = pose({-.014, -.24, .016, -15, 25, -4}, {68, 23, -15, -.088, .104, -.105},
    {58, -17, 27, .065, .088, .13}, rear, lead, {14, -21, 3}, {-18, -24, 6})
local violetRecover = pose({-.014, -.255, .016, -15, 9, 1}, loadoutRight,
    loadoutLeft, rear, lead, {14, -8, -1}, {-17, 8, 5})

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
    emberKnuckle = .235, blackglassSweep = .50, hellfireStampede = table.freeze({.38, .57}),
    coalFlick = .16, slateToe = .25, cinderCrown = .62, violetCross = table.freeze({.32, .69})}
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
    emberKnuckle = {{0, ready}, {.098, emberDraw}, {contact.emberKnuckle, emberHit}, {.344, emberRecover}, {.60, ready}},
    blackglassSweep = {{0, ready}, {.178, glassDraw}, {.341, glassHold}, {contact.blackglassSweep, glassHit},
        {.63, glassFollow}, {.786, glassEase}, {.96, ready}},
    coalFlick = {{0, loadoutReady}, {.064, coalDraw}, {contact.coalFlick, coalHit}, {.253, coalFold}, {.41, loadoutReady}},
    slateToe = {{0, loadoutReady}, {.086, toeLoad}, {.158, toeRaise}, {contact.slateToe, toeHit},
        {.340, toeTuck}, {.442, toeRecover}, {.53, loadoutReady}},
    cinderCrown = {{0, loadoutReady}, {.154, crownBrace}, {.326, crownShow}, {.425, crownShow}, {.524, crownFold},
        {contact.cinderCrown, crownHit}, {.68, crownHit}, {.798, crownEase}, {1.015, crownRecover}, {1.25, loadoutReady}},
    violetCross = {{0, loadoutReady}, {.154, violetDraw}, {contact.violetCross[1], violetLow}, {.431, violetPeel},
        {.548, violetCoil}, {.622, violetDrive}, {contact.violetCross[2], violetHigh}, {.798, violetUnwind},
        {.958, violetRecover}, {1.20, loadoutReady}},
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
    emberKnuckle = {{emberHit, "Right Shoulder", rightPad}},
    blackglassSweep = {{glassHit, "Left Shoulder", leftPad}},
    hellfireStampede = {{howl, "Neck", mouth}, {release, "Right Shoulder", rightPad}},
    coalFlick = {{coalHit, "Left Shoulder", v(-1.338901321, 1.853055438, -.633285762)}},
    slateToe = {{toeHit, "Right Hip", v(.606801305, .146702356, -.818818919)}},
    cinderCrown = {{crownHit, "Neck", v(0, 3.882864105, -1.411880157)}},
    violetCross = {
        {violetLow, "Left Shoulder", v(-1.354742481, 1.907144376, -.652577559)},
        {violetHigh, "Right Shoulder", v(1.339137994, 1.831034300, -.587903711)},
    },
}
local skills = {
    coalFlick = table.freeze({damage = 13, radius = .44}),
    slateToe = table.freeze({damage = 16, radius = .47, foot = true}),
    cinderLunge = table.freeze({damage = 22, radius = .58, shove = .96}),
    emberKnuckle = table.freeze({damage = 15, radius = .46}),
    blackglassSweep = table.freeze({damage = 23, radius = .53}),
    hellfireStampede = table.freeze({damage = table.freeze({17, 17})}),
}
local travel = {cinderLunge = table.freeze({axis = "forward", distance = .40, startsAt = .14, endsAt = .27})}

local planted = {emberKnuckle = true, blackglassSweep = true, coalFlick = true, cinderCrown = true, violetCross = true}
local moves = table.clone(rig.finish(clips, contact, hits, skills, travel, {"sidestep"}, planted))
moves.UltimateSkill = table.freeze({
    cinderCrown = table.freeze({damage = 33, radius = .50}),
    violetCross = table.freeze({damage = table.freeze({14, 23}), radius = table.freeze({.46, .49})}),
})
local sample = moves.sample
function moves.sample(action, age, direction)
    local offsets = sample(action, age, direction)
    if action == "slateToe" then
        offsets["Left Hip"] = offsets.RootJoint:ToObjectSpace(toeLeft)
    end
    return offsets
end

return table.freeze(moves)
