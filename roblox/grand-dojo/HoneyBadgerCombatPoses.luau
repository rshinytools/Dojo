-- Honey Badger coils under the guard, then drives back through it with alternating paws.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    return {v(side * .165, .014, -.81), v(side * .795, .014, -.81),
        v(side * .165, .014, .21), v(side * .795, .014, .21)}
end

local rig = Choreography.new(rootHeight, {
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

-- Snap the padded right knuckle forward from guard with a compact shoulder turn.
local copperLoad = pose({.07, -.33, .085, -18, -18, -6}, {33, 3, -22, .03, .055, .18},
    {63, -20, 25, .071, .12, -.04}, rear, lead, {19, 16, 4}, {-13, 17, -4})
local copperHit = pose({.035, -.32, -.135, -17, 22, -5}, {54, 18, -19, -.105, -.015, -.13},
    {64, -20, 25, .075, .12, .015}, rear, lead, {18, -20, 4}, {-12, -21, 5})
local copperFold = pose({.04, -.30, -.035, -14, 14, -4}, {49, 17, -22, -.065, .045, -.03},
    leftGuard, rear, lead, {15, -13, 3}, {-12, -13, 4})

-- Roll the left wrist across the body so the padded outside of the paw
-- leads the swing. The right glove holds its guard during the turn.
local quarryLoad = pose({-.12, -.37, .12, -19, 25, 8}, {62, 20, -21, -.045, .10, -.015},
    {28, 14, 11, -.10, .045, .18}, rear, lead, {18, -22, -5}, {-13, -24, -6})
local quarryDraw = pose({-.15, -.40, .12, -19, 40, 10}, {68, 24, -24, -.055, .10, -.025},
    {32, 30, 21, -.14, .07, .20}, rear, lead, {18, -33, -7}, {-15, -36, -8})
local quarryTurn = pose({-.10, -.34, .035, -17, 7, 7}, {65, 21, -25, -.05, .10, .01},
    {52, -20, 36, -.085, .07, .075}, rear, lead, {17, -7, -4}, {-13, -8, -5})
local quarryHit = pose({-.035, -.27, -.57, -12, -39, 3}, {58, 23, -22, -.065, .11, .07},
    {55, -50, 33, .045, .045, -.24}, rear, lead, {13, 35, -3}, {-12, 32, 6})
local quarryThrough = pose({.08, -.31, -.24, -16, -51, -4}, {55, 22, -24, -.06, .10, .045},
    {53, -68, 37, .11, .05, -.08}, rear, lead, {16, 41, 3}, {-13, 43, 6})
local quarryFold = pose({.045, -.30, -.075, -16, -14, -3}, rightGuard,
    {53, -32, 26, .105, .08, -.015}, rear, lead, {17, 12, 3}, {-12, 15, 4})

local brambleDraw = pose({.025, -.31, .025, -16, 17, 4}, {53, 19, -27, -.05, .09, .015},
    {35, -9, 21, .03, .065, .12}, rear, lead, {16, -16, -3}, {-13, -17, -5})
local brambleHit = pose({.025, -.23, .025, -14, -19, 3}, {53, 18, -27, -.045, .09, .06},
    {64, -21, 18, .075, .09, -.075}, rear, lead, {15, 16, -3}, {-11, 22, 2})
local brambleFold = pose({.025, -.26, .025, -14, -10, 2}, rightGuard,
    {56, -19, 22, .075, .09, .04}, rear, lead, {14, 9, -2}, {-11, 10, 2})

local toePivot = v(-.48, 1.46 - rootHeight, .025)
local toeRight = ready.RootJoint * ready["Right Hip"]
local toeLeft = ready.RootJoint * ready["Left Hip"]
local function toePose(core, right, left, boot, head, tail)
    local offsets = pose(core, right, left, rear, lead, head, tail)
    local swing = CFrame.new(toePivot + v(boot[4], boot[5], boot[6]))
        * CFrame.Angles(math.rad(boot[1]), math.rad(boot[2]), math.rad(boot[3])) * CFrame.new(-toePivot)
    offsets["Left Hip"] = offsets.RootJoint:ToObjectSpace(swing * toeLeft)
    return offsets
end

local toeLoad = toePose({.025, -.31, .025, -12, 13, -9}, {52, 19, -29, -.065, .095, .06},
    {55, -17, 25, .08, .095, .09}, {4, -2, 2, .01, .07, .065}, {12, -12, 7}, {-12, -14, -7})
local toeRaise = toePose({.025, -.25, .025, -4, 12, -12}, {57, 21, -30, -.065, .10, .06},
    {54, -18, 25, .085, .105, .07}, {11, -10, 4, .025, .235, .08}, {6, -12, 8}, {-13, -18, -8})
local toeHit = toePose({.025, -.20, .025, -2, 7, -10}, {56, 22, -30, -.065, .105, .02},
    {52, -21, 23, .07, .11, .065}, {17, -27, 5, .22, .06, -.37}, {7, -7, 6}, {-14, -19, -7})
local toeTuck = toePose({.025, -.25, .025, -6, 9, -8}, {54, 19, -29, -.055, .10, .005},
    {55, -20, 23, .08, .11, .045}, {11, -11, 4, .04, .16, -.045}, {9, -9, 5}, {-12, -17, -6})
local toeRecover = toePose({.025, -.29, .025, -12, 10, -5}, rightGuard,
    leftGuard, {4, -4, 1, .015, .075, .03}, {13, -10, 5}, {-11, -13, -2})

local crushBrace = pose({.025, -.38, .025, -15, 10, -4}, {60, 12, -8, .025, .12, .10},
    {60, -13, 10, -.015, .12, .09}, rear, lead, {15, -8, 2}, {-12, -8, 3})
local crushSpread = pose({.025, -.22, .025, -8, 0, 0}, {78, -15, 19, .02, .08, .07},
    {78, 15, -19, -.02, .08, .07}, rear, lead, {9}, {-9})
local crushDrive = pose({.025, -.32, .025, -15, 0, 0}, {67, 21, -11, .02, .085, -.035},
    {67, -21, 11, -.02, .085, -.035}, rear, lead, {14}, {-12})
local crushHit = pose({.025, -.35, .025, -17, 0, 0}, {61, 46, -12, -.045, .035, -.42},
    {61, -46, 12, .045, .035, -.42}, rear, lead, {17}, {-13})
local crushPeel = pose({.025, -.34, .025, -15, 1, 0}, {55, 31, -13, .015, .055, -.12},
    {56, -32, 13, -.01, .055, -.12}, rear, lead, {15, -1}, {-13, -1})
local crushSettle = pose({.025, -.285, .025, -15, 9, -4}, rightGuard,
    {52, -19, 23, .06, .10, .015}, rear, lead, {15, -8, 3}, {-12, -8, 3})

local hollowWind = pose({.025, -.42, .025, -21, -26, -9}, {30, -8, -30, .075, -.015, .17},
    {58, -18, 25, .075, .11, .09}, rear, lead, {22, 23, 7}, {-14, 20, -6})
local hollowLow = pose({.025, -.43, .025, -20, 28, -5}, {48, 24, -13, -.115, -.04, -.26},
    {54, -20, 25, .065, .11, .135}, rear, lead, {20, -24, 4}, {-14, -25, 4})
local hollowRelease = pose({.025, -.32, .025, -15, 17, 2}, {54, 16, -21, -.06, .045, .03},
    {33, -7, 19, .055, .06, .17}, rear, lead, {15, -15, -3}, {-14, -16, -1})
local hollowCoil = pose({.025, -.30, .025, -13, 30, 9}, {53, 16, -27, -.05, .085, .11},
    {35, 4, 19, .055, .075, .205}, rear, lead, {14, -25, -6}, {-15, -26, -3})
local hollowDrive = pose({.025, -.23, .025, -12, -18, 6}, {51, 17, -27, -.04, .085, .125},
    {58, -18, 15, .11, .09, -.07}, rear, lead, {13, 16, -4}, {-14, 17, 2})
local hollowHigh = pose({.025, -.165, .025, -11, -33, 5}, {49, 17, -27, -.035, .085, .155},
    {74, -29, 11, .14, .12, -.35}, rear, lead, {12, 28, -4}, {-13, 30, 4})
local hollowPeel = pose({.025, -.22, .025, -14, -27, 4}, {49, 15, -27, -.035, .085, .10},
    {66, -25, 13, .095, .11, -.11}, rear, lead, {14, 25, -3}, {-13, 24, 4})
local hollowSettle = pose({.025, -.255, .025, -16, 3, -3}, rightGuard,
    leftGuard, rear, lead, {16, -3, 2}, {-12, -3, 2})

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
    burrowHook = .29, copperKnuckle = .24, quarryBackhand = .49, unstoppableFrenzy = table.freeze({.28, .48, .69, .92}),
    brambleCheck = .16, thicketToe = .25, honeycombCrush = .62, hollowHammer = table.freeze({.31, .67})}
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
    copperKnuckle = {{0, ready}, {.095, copperLoad}, {contact.copperKnuckle, copperHit}, {.345, copperFold}, {.59, ready}},
    quarryBackhand = {{0, ready}, {.145, quarryLoad}, {.285, quarryDraw}, {.395, quarryTurn},
        {contact.quarryBackhand, quarryHit}, {.585, quarryThrough}, {.75, quarryFold}, {.94, ready}},
    brambleCheck = {{0, ready}, {.061, brambleDraw}, {contact.brambleCheck, brambleHit}, {.25, brambleFold}, {.41, ready}},
    thicketToe = {{0, ready}, {.085, toeLoad}, {.160, toeRaise}, {contact.thicketToe, toeHit},
        {.333, toeTuck}, {.433, toeRecover}, {.53, ready}},
    honeycombCrush = {{0, ready}, {.158, crushBrace}, {.33, crushSpread}, {.424, crushSpread}, {.515, crushDrive},
        {contact.honeycombCrush, crushHit}, {.683, crushHit}, {.797, crushPeel}, {1.0, crushSettle}, {1.24, ready}},
    hollowHammer = {{0, ready}, {.15, hollowWind}, {contact.hollowHammer[1], hollowLow}, {.416, hollowRelease},
        {.535, hollowCoil}, {.615, hollowDrive}, {contact.hollowHammer[2], hollowHigh}, {.777, hollowPeel},
        {.955, hollowSettle}, {1.19, ready}},
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
local function mountedContact(key, joint, artPoint)
    return (key.RootJoint * key[joint]):PointToWorldSpace(artPoint - Vector3.yAxis * rootHeight)
end
local crushPad = mountedContact(crushHit, "Right Shoulder", v(1.354373627, 1.776271986, -.823270878))
    :Lerp(mountedContact(crushHit, "Left Shoulder", v(-1.354373627, 1.776271986, -.823270878)), .5)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    burrowHook = {{hookHit, "Right Shoulder", rightPad}},
    -- The native striking pad and the outside of the opposite enclosed paw.
    copperKnuckle = {{copperHit, "Right Shoulder", v(1.421409231, 1.830635123, -.815136785)}},
    quarryBackhand = {{quarryHit, "Left Shoulder", v(-1.592291598, 1.856266583, -.547768232)}},
    brambleCheck = {{brambleHit, "Left Shoulder", v(-1.413740001, 1.813924996, -.812340608)}},
    thicketToe = {{toeHit, "Left Hip", v(-.564963554, .144031071, -.854473385)}},
    honeycombCrush = {crushPad},
    hollowHammer = {
        {hollowLow, "Right Shoulder", v(1.544278261, 1.805065909, -.681016982)},
        {hollowHigh, "Left Shoulder", v(-1.415923113, 1.813736160, -.806993429)},
    },
    unstoppableFrenzy = {
        {firstSwipe, "Right Shoulder", rightPad}, {secondSwipe, "Left Shoulder", leftPad},
        {thirdSwipe, "Right Shoulder", rightPad}, {finalSwipe, "Left Shoulder", leftPad},
    },
}
local skills = {
    brambleCheck = table.freeze({damage = 12, radius = .44}),
    thicketToe = table.freeze({damage = 15, radius = .47, foot = true}),
    burrowHook = table.freeze({damage = 20, radius = .60, shove = .85}),
    copperKnuckle = table.freeze({damage = 15, radius = .46}),
    quarryBackhand = table.freeze({damage = 23, radius = .51}),
    unstoppableFrenzy = table.freeze({damage = table.freeze({6, 6, 6, 6}), immunity = 5}),
}
local travel = {
    burrowHook = table.freeze({axis = "forward", distance = .40, startsAt = .17, endsAt = .28}),
}

local planted = {copperKnuckle = true, quarryBackhand = true, brambleCheck = true, honeycombCrush = true, hollowHammer = true}
local moves = table.clone(rig.finish(clips, contact, hits, skills, travel, {"sidestep"}, planted))
moves.UltimateSkill = table.freeze({
    honeycombCrush = table.freeze({damage = 31, radius = .49}),
    hollowHammer = table.freeze({damage = table.freeze({13, 22}), radius = table.freeze({.46, .48})}),
})
local sample = moves.sample
function moves.sample(action, age, direction)
    local offsets = sample(action, age, direction)
    if action == "thicketToe" then
        offsets["Right Hip"] = offsets.RootJoint:ToObjectSpace(toeRight)
    end
    return offsets
end

return table.freeze(moves)
