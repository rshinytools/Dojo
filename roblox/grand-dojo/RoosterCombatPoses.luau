-- Original Rooster Kickboxer choreography, built around fast footwork and
-- a clearly chambered kick. See FighterChoreography for key coordinates.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {
        v(side * .48, 0, -.52), v(side * .48, .03, -.83),
        v(side * .25, .04, -.68), v(side * .71, .04, -.68), v(side * .48, .04, -.13),
    }
end

local pivots = {
    Neck = v(0, 3.16, -.03),
    ["Right Shoulder"] = v(.83, 3.02, .03), ["Left Shoulder"] = v(-.83, 3.02, .03),
    ["Right Hip"] = v(.45, 1.54, .02), ["Left Hip"] = v(-.45, 1.54, .02),
    TailJoint = v(0, 1.87, .44),
}
local rig = Choreography.new(2.60, pivots, sole(1), sole(-1))
local pose = rig.pose

local rightGuard, leftGuard = {62, 23, -13, -.04, .13, .04}, {55, -19, 15, .03, .15, .03}
local rearFoot, leadFoot = {1, -14, 0, .09, 0, .21, 0}, {2, 8, 0, -.09, 0, -.22, 0}
local watch, tailReady = {3, 10, -4}, {-3, 8, -2}
local ready = pose({.03, -.08, 0, -5, -11, 2}, rightGuard, leftGuard, rearFoot, leadFoot, watch, tailReady)
local bounce = pose({.025, -.03, -.025, -4, -9, 1}, {65, 22, -12, -.045, .14, .038}, leftGuard,
    rearFoot, leadFoot, {2, 9, -3}, {3, 6, -1})

local stepRight = pose({.105, -.07, -.08, -8, -3, -6}, {56, 18, -13, -.035, .13, .09}, leftGuard,
    {13, -10, 0, .11, 0, -.29, .15}, leadFoot, {5, 3, 4}, {6, -12, 6})
local stepLeft = pose({-.06, -.075, -.09, -7, -15, 5}, rightGuard, {59, -14, 14, .04, .16, .07},
    rearFoot, {12, 10, 0, -.09, 0, -.35, .14}, {5, 12, -4}, {5, 14, -5})
local retreatRight = pose({.09, -.105, .105, 5, -13, -6}, rightGuard, leftGuard,
    {-9, -19, 0, .10, 0, .36, .14}, leadFoot, {-4, 12, 4}, {-11, 17, 5})
local retreatLeft = pose({-.06, -.115, .09, 4, -8, 6}, rightGuard, leftGuard,
    rearFoot, {-8, 6, 0, -.13, 0, .32, .14}, {-3, 8, -5}, {-9, -10, -6})
local evade = pose({.19, -.28, .06, -12, -19, -17}, {45, 15, -21, .05, .15, .16}, leftGuard,
    {6, -23, 0, .16, 0, .20, .04}, leadFoot, {10, 16, 11}, {-2, 25, -10})
local brake = pose({.12, -.19, .02, -11, -7, -10}, {63, 21, -14, -.04, .15, .05}, leftGuard,
    {5, -24, 0, .15, 0, .16, 0}, {3, 2, 0, -.07, 0, -.18, .035}, {8, 6, 7}, {1, 14, -6})

local jabChamber = pose({.045, -.13, .06, -7, -27, -4}, {43, 4, -12, .02, .10, .19}, leftGuard,
    rearFoot, leadFoot, {5, 21, 3}, {-7, 28, 2})
local jabHit = pose({.07, -.075, -.21, -9, 24, -3}, {73, 18, -8, -.08, .075, -.26}, leftGuard,
    rearFoot, leadFoot, {6, -22, 3}, {6, -23, 3})
local crossChamber = pose({-.075, -.15, .055, -6, 22, 7}, rightGuard, {32, -8, 16, -.01, .10, .25},
    rearFoot, leadFoot, {6, -16, -4}, {-7, -25, -6})
local crossHit = pose({-.065, -.075, -.26, -11, -28, 5}, rightGuard, {75, -17, 8, .075, .075, -.30},
    rearFoot, {5, 19, 0, -.09, 0, -.15, 0}, {6, 26, -4}, {6, 25, -5})
local bodyChamber = pose({.135, -.27, .10, 6, -19, -10}, {49, 22, -20, .015, .12, .12}, leftGuard,
    {25, 8, -5, .015, .12, .12, .54}, leadFoot, {-3, 16, 6}, {8, 24, 7})
local bodyKick = pose({.035, -.03, -.15, 3, 14, -4}, rightGuard, {56, -13, 15, -.035, .10, .14},
    {58, 5, -3, -.04, -.04, -.20, 1.34}, leadFoot, {-2, -13, 3}, {10, -15, 3})
local heavyChamber = pose({-.12, -.27, .18, -10, 40, 12}, {51, 17, -16, .04, .14, .13},
    {43, -4, 17, -.09, .14, .27}, rearFoot, {27, -16, 5, -.14, .17, .13, .55},
    {7, -28, -7}, {-9, -42, -11})
local heavyKick = pose({-.04, .02, -.32, 10, -24, 7}, {46, 22, -12, .09, .15, .12}, leftGuard,
    rearFoot, {63, -1, 4, .06, .10, -.13, 1.60}, {-7, 23, -5}, {13, 24, -9})
local heavyRecoil = pose({-.13, -.15, -.14, -8, -36, 9}, rightGuard, leftGuard,
    rearFoot, {25, -16, 6, -.18, .05, -.05, .39}, {9, 30, -6}, {7, 35, -13})

local spurCrouch = pose({.10, -.32, .08, -10, -20, -8}, {47, 22, -16, .035, .10, .18}, leftGuard,
    {11, -11, -8, .07, 0, .26, .10}, leadFoot, {8, 15, 6}, {-7, 24, 10})
local spurRise = pose({.03, .10, -.20, 9, 12, -4}, {46, 17, -17, .025, .13, .23},
    {63, -23, 14, .02, .16, .04}, {73, 4, -1, -.025, .10, -.25, 1.91}, leadFoot,
    {-5, -12, 2}, {17, -17, 5})
local spurRetract = pose({.065, -.04, -.075, 4, 13, -6}, rightGuard, leftGuard,
    {30, -2, -6, .07, .09, .02, .87}, leadFoot, {2, -12, 4}, {8, -12, 5})

local vaultWindup = pose({.045, -.40, .12, -20, -18, -6}, {33, 18, -16, .14, .01, .22},
    {39, -12, 18, -.12, .07, .16}, {15, -15, -4, .09, 0, .22, 0}, leadFoot,
    {16, 12, 4}, {-14, 22, 10})
local vaultStart = pose({.07, .29, -.04, 15, 8, -11}, {60, 10, -19, .08, .20, .18},
    {47, -13, 14, .015, .13, .12}, {39, 4, -7, .10, .19, .08, 1.40},
    {-12, 9, 5, -.09, .07, .21, .50}, {-8, -7, 7}, {17, -17, 9})
local kickOne = pose({.025, .42, -.14, 11, 12, -6}, {38, 17, -34, .10, .19, .20},
    {61, -19, 11, .03, .16, .03}, {63, 3, -4, -.04, .11, -.26, 1.72},
    {-22, 12, 6, -.095, .09, .26, .61}, {-7, -11, 5}, {18, -23, 8})
local switchKick = pose({-.025, .43, -.065, 7, -2, 5}, {53, 19, -19, .04, .17, .12},
    {49, -15, 31, -.085, .17, .13}, {-10, -12, -6, .095, .16, .20, .82},
    {42, -7, 7, -.07, .14, .04, 1.36}, {-4, 1, -4}, {17, 1, -9})
local kickTwo = pose({-.055, .38, -.14, 8, -15, 7}, {59, 20, -12, -.02, .15, .03},
    {40, -14, 35, -.12, .18, .22}, {-21, -13, -6, .12, .09, .23, .55},
    {64, -3, 4, .01, .11, -.26, 1.80}, {-6, 12, -5}, {19, 19, -9})
local spikeChamber = pose({.035, .45, -.10, 10, 12, -7}, {48, 18, -23, .05, .18, .15},
    {53, -15, 24, -.045, .17, .14}, {83, 0, -6, .055, .18, .06, 2.39},
    {-12, 7, 6, -.12, .11, .22, .68}, {-6, -10, 6}, {19, -23, 9})
local spikeKick = pose({.01, .23, -.32, -11, 13, -4}, {44, 16, -30, .09, .15, .21},
    {45, -17, 26, -.08, .15, .19}, {56, 1, -3, -.035, .02, -.23, 1.36},
    {-4, 10, 3, -.11, .02, .18, .22}, {10, -12, 3}, {14, -16, 8})
local landing = pose({.025, -.30, -.06, -18, 3, -3}, rightGuard, leftGuard,
    {9, -9, 0, .085, 0, .08, 0}, leadFoot, {12, -3, 2}, {-8, 8, 4})

local cover = pose({0, -.19, .065, -8, 2, 1}, {75, 23, -19, -.12, .17, .02},
    {73, -24, 18, .12, .18, .015}, rearFoot, leadFoot, {10, -2, -1}, {-7, -2, -1})
local recoil = pose({-.055, -.22, .14, 11, -6, 6}, {70, 24, -22, -.07, .13, .09},
    {67, -22, 23, .07, .15, .09}, rearFoot, leadFoot, {-10, 4, -4}, {7, 10, -5})
local deflect = pose({.045, -.20, -.115, -9, 33, -9}, {58, -21, -13, -.045, .22, -.14},
    {58, -17, 12, .065, .14, .06}, rearFoot, {8, 11, 0, -.11, 0, -.235, 0},
    {8, -26, 5}, {-2, -31, 6})
local headHit = pose({-.10, -.11, .22, 18, -19, 7}, {42, 17, -21, .045, .12, .16},
    {46, -14, 22, -.045, .10, .105}, rearFoot, leadFoot, {-30, 16, -8}, {11, 27, -6})
local bodyHit = pose({.115, -.29, .125, -23, 18, -10}, {49, 25, -15, .01, 0, -.05},
    {50, -16, 16, .025, .025, -.06}, rearFoot, leadFoot, {19, -15, 7}, {-18, -27, 7})
local stumble = pose({-.17, -.25, .23, 14, -26, 12}, {34, 12, -24, .06, .06, .19},
    {39, -14, 25, -.06, .095, .16}, rearFoot, {-4, 17, 0, -.12, 0, .30, 0},
    {-22, 19, -9}, {12, 32, -8})

local salute = pose({.04, -.07, -.055, -7, 20, -6}, {100, 16, -13, -.025, .15, -.055},
    leftGuard, rearFoot, leadFoot, {8, -16, 3}, {6, -24, 7})
local stretch = pose({.025, .04, -.045, 4, 9, -7}, {42, 3, -27, .12, .12, .10},
    {58, -11, 22, -.01, .15, .04}, {54, -5, -7, .05, .12, -.035, 1.20}, leadFoot,
    {-5, -8, 6}, {12, -16, 9})
local bow = pose({0, -.19, -.055, -23, 2, 0}, {36, 16, -13, -.03, .075, .04},
    {38, -16, 13, .03, .075, .04}, rearFoot, leadFoot, {2, -1, 0}, {-10, 0, 0})
local wingSalute = pose({.015, -.035, -.04, -6, -8, 3}, {92, 18, -46, .06, .15, -.12},
    {64, -16, 25, -.025, .15, -.035}, rearFoot, leadFoot, {7, 8, -2}, {9, 13, -5})

local flurryHits = table.freeze({.38, .55, .76})
local contact = {jab = .158, cross = .224, body = .263, heavy = .421, spurLift = .29, featherFlurry = flurryHits}
local clips = {
    stance = {{0, ready}, {.38, bounce}, {.82, ready}},
    advance = {{0, ready}, {.135, stepRight}, {.27, ready}, {.415, stepLeft}, {.55, ready}},
    retreat = {{0, ready}, {.156, retreatRight}, {.312, ready}, {.468, retreatLeft}, {.624, ready}},
    sidestep = {{0, ready}, {.103, evade}, {.238, brake}, {.46, ready}},
    jab = {{0, ready}, {.071, jabChamber}, {contact.jab, jabHit}, {.25, bounce}, {.40, ready}},
    cross = {{0, ready}, {.112, crossChamber}, {contact.cross, crossHit}, {.34, bounce}, {.49, ready}},
    body = {{0, ready}, {.118, bodyChamber}, {contact.body, bodyKick}, {.377, bodyChamber}, {.54, ready}},
    heavy = {{0, ready}, {.18, heavyChamber}, {.29, heavyChamber}, {contact.heavy, heavyKick},
        {.54, heavyRecoil}, {.81, ready}},
    spurLift = {{0, ready}, {.12, spurCrouch}, {.19, spurCrouch}, {contact.spurLift, spurRise},
        {.41, spurRetract}, {.54, landing}, {.66, ready}},
    featherFlurry = {{0, ready}, {.14, vaultWindup}, {.22, vaultWindup}, {.307, vaultStart},
        {flurryHits[1], kickOne}, {.462, switchKick}, {flurryHits[2], kickTwo}, {.666, spikeChamber},
        {flurryHits[3], spikeKick}, {.885, landing}, {1.14, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.073, recoil}, {.145, recoil}, {.28, cover}},
    parry = {{0, cover}, {.086, deflect}, {.166, deflect}, {.244, cover}, {.34, ready}},
    hitHead = {{0, ready}, {.077, headHit}, {.187, headHit}, {.34, ready}},
    hitBody = {{0, ready}, {.088, bodyHit}, {.199, bodyHit}, {.36, ready}},
    stagger = {{0, headHit}, {.14, stumble}, {.35, cover}, {.56, ready}},
    intro = {{0, ready}, {.85, bounce}, {1.93, ready}, {2.57, salute}, {3.02, salute}, {3.66, bow},
        {4.24, ready}, {5.42, bounce}, {6.13, stretch}, {6.51, stretch}, {7.06, landing},
        {7.53, ready}, {8.50, bounce}, {10, ready}},
    win = {{0, ready}, {.28, wingSalute}, {.66, wingSalute}, {1.09, bow}, {1.33, bow}, {1.82, ready}},
}

local rightFist, leftFist = v(1.10, 1.92, -.66), v(-1.10, 1.92, -.66)
local rightToe, leftToe = v(.48, .115, -.92), v(-.48, .115, -.92)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightFist}},
    cross = {{crossHit, "Left Shoulder", leftFist}},
    body = {{bodyKick, "Right Hip", rightToe}},
    heavy = {{heavyKick, "Left Hip", leftToe}},
    spurLift = {{spurRise, "Right Hip", rightToe}},
    featherFlurry = {{kickOne, "Right Hip", rightToe}, {kickTwo, "Left Hip", leftToe},
        {spikeKick, "Right Hip", rightToe}},
}
local skills = {
    spurLift = table.freeze({damage = 18, radius = .52, shove = .48, popHeight = .30}),
    featherFlurry = table.freeze({damage = table.freeze({8, 9, 16}), radius = .54,
        shove = table.freeze({.13, .17, .58}), popHeight = table.freeze({.17, .12, 0})}),
}
local travel = {
    spurLift = table.freeze({distance = .44, startsAt = .11, endsAt = .25, axis = "forward"}),
    featherFlurry = table.freeze({distance = 1.46, startsAt = .18, endsAt = .62, axis = "forward"}),
}

local standard = rig.finish(clips, contact, hits, skills, travel, {"sidestep"})

-- The additional strikes use the fitted character's 2.132-stud root as
-- their reference. Keep the original pose basis for the existing repertoire.
local mountedRig = Choreography.new(2.132, pivots, sole(1), sole(-1))
local leftHip, rightHip = "Left Hip", "Right Hip"
-- Lift the guard stance just enough for the visible rounded soles to clear the mat.
local leftPlant = CFrame.new(0, .018, 0) * ready.RootJoint * ready[leftHip]
local rightPlant = CFrame.new(0, .023, 0) * ready.RootJoint * ready[rightHip]

local function plantTalons(offsets, both)
    local root = offsets.RootJoint
    offsets[leftHip] = root:ToObjectSpace(leftPlant)
    if both then
        offsets[rightHip] = root:ToObjectSpace(rightPlant)
    end
    return offsets
end

local function fitted(core, right, left, kick, head, tail)
    return plantTalons(mountedRig.pose(core, right, left, kick or rearFoot, leadFoot, head, tail), kick == nil)
end

local tacticalReady = plantTalons(table.clone(ready), true)
local peckGather = fitted({.035, -.18, .052, -4, -12, 4}, {51, 15, -16, -.03, .16, .10},
    leftGuard, nil, {8, 10, -5}, {-5, 16, -3})
local peckDip = fitted({.019, -.245, -.054, -11, -6, 2}, {48, 16, -20, -.015, .12, .13},
    {56, -16, 18, .03, .13, .08}, nil, {-10, 7, -3, 0, -.02, -.03}, {-11, 12, -4})
local peckHit = fitted({0, -.28, -.17, -16, -2, 0}, {41, 18, -22, -.05, .09, .16},
    {47, -15, 19, .04, .105, .14}, nil, {-17, 3, -1, 0, -.03, -.06}, {-16, 9, -3})
local peckRecoil = fitted({.025, -.14, -.095, -8, -6, 3}, rightGuard, leftGuard,
    nil, {4, 7, -1}, {-5, 12, -5})

local wheelCoil = fitted({-.095, -.23, .105, -8, -31, 8}, {42, 16, -21, .025, .12, .17},
    {51, -19, 20, .02, .12, .11}, nil, {3, 23, -6}, {-10, 33, -12})
local wheelChamber = fitted({-.14, -.19, .06, -3, -38, 11}, {35, 25, -27, .05, .13, .14},
    {49, -12, 26, -.015, .14, .12}, {35, -10, 25, .16, .03, .14, .62},
    {0, 27, -7}, {-4, 38, -14})
local wheelSwing = fitted({-.06, -.115, -.055, 0, -19, 9}, {38, 27, -33, .07, .14, .02},
    {48, -17, 21, -.02, .125, .13}, {55, -17, 17, .10, .03, -.12, .96},
    {-2, 14, -6}, {8, 21, -11})
local wheelHit = fitted({.055, -.06, -.24, 2, 12, 6}, {46, 25, -29, .075, .13, .07},
    {59, -15, 13, -.025, .13, .10}, {63, -5, 12, -.045, .06, -.24, 1.26},
    {-3, -9, -4}, {13, -12, -9})
local wheelThrough = fitted({.12, -.10, -.17, 5, 35, 5}, {49, 23, -24, .065, .15, .13},
    {57, -19, 14, .01, .12, .13}, {54, 6, 4, -.10, .08, -.16, 1.04},
    {-4, -28, -3}, {11, -37, -9})
local wheelWithdraw = fitted({-.07, -.16, -.05, -1, 10, 4}, rightGuard, leftGuard,
    {27, -7, 9, -.015, .06, -.04, .49}, {0, -8, -2}, {5, -13, -6})

local wheelSettle = fitted({-.025, -.125, -.02, -4, -6, 3}, rightGuard, leftGuard,
    nil, {2, 8, -3}, {-3, 9, -4})

local tapDraw = fitted({.037, -.137, .065, -7, -21, -3}, {35, 9, -21, .018, .11, .137},
    leftGuard, nil, {6, 20, 3}, {-6, 24, -4})
local tapHit = fitted({.024, -.12, -.090, -9, 31, -2}, {87, 21, 1, -.081, .073, -.118},
    {59, -15, 17, .035, .139, .032}, nil, {9, -24, 2}, {8, -28, 3})
local tapBack = fitted({.026, -.13, -.035, -6, 9, -1}, {67, 20, -12, -.037, .12, -.043},
    leftGuard, nil, {7, -8, 0}, {1, -10, 3})

local toeTuck = fitted({-.069, -.155, .027, -7, -11, 6}, {52, 17, -24, -.025, .108, .064},
    {59, -13, 20, .048, .145, .055}, {32, -7, 5, .088, .03, .111, .24},
    {7, 13, -4}, {-7, 13, -5})
local toeHit = fitted({-.052, -.123, -.133, -7, 13, 5}, {58, 24, -21, -.016, .11, -.022},
    {56, -17, 21, .036, .129, .058}, {61, -6, 4, .04, .03, -.29, .61},
    {7, -12, -3}, {7, -15, -6})
local toeCollect = fitted({-.043, -.143, -.05, -7, 1, 4}, rightGuard,
    {57, -16, 19, .046, .145, .045}, {28, -8, 3, .079, .04, -.113, .22},
    {6, 2, -3}, {5, 5, -4})

local hammerRaise = fitted({.014, .045, .155, 2, -3, 1}, {105, -1, -60, -.015, .19, .105},
    {101, 1, 56, .03, .175, .123}, nil, {-4, 2, -2}, {9, 6, 1})
local hammerLoad = fitted({.006, -.082, .127, -6, -2, 0}, {100, 5, -53, -.055, .185, .075},
    {99, -4, 52, .051, .182, .075}, nil, {8, 1, 0}, {-2, 3, -1})
local hammerDrive = fitted({.01, -.313, -.058, -18, -1, 1}, {73, 18, -24, -.143, .071, -.12},
    {74, -17, 22, .136, .07, -.135}, nil, {16, 1, -1}, {-11, 0, -2})
local hammerHit = fitted({.012, -.435, -.37, -25, 1, 2}, {45, 28, -9, -.277, -.105, -.247},
    {46, -24, 9, .269, -.092, -.247}, nil, {18, 0, -3}, {-14, -4, -3})
local hammerReceive = fitted({.009, -.383, -.155, -19, 2, 1}, {49, 21, -13, -.13, -.07, -.117},
    {50, -21, 16, .147, -.057, -.115}, nil, {16, 0, -2}, {-9, -7, -2})
local hammerEase = fitted({.017, -.22, -.075, -12, -7, 1}, rightGuard, leftGuard,
    nil, {11, 7, -2}, {-7, 5, -2})

local arcLoad = fitted({-.054, -.188, .10, -8, 30, 7}, {52, 17, -18, -.02, .151, .037},
    {34, 18, -59, .286, -.075, .035}, nil, {7, -26, -5}, {-8, -29, -8})
local arcLeft = fitted({-.036, -.173, -.238, -11, -28, 4}, {49, 10, -36, -.195, .022, .039},
    {70, -19, 18, .095, .092, -.193}, nil, {11, 24, -4}, {7, 31, -6})
local arcExchange = fitted({.094, -.197, -.03, -9, -34, -5}, {36, -19, 62, -.260, -.020, .025},
    {47, -24, 23, .071, .137, -.051}, nil, {10, 30, 4}, {-6, 35, 7})
local arcRight = fitted({.036, -.212, -.292, -12, 38, -4}, {74, 21, -17, -.144, .081, -.252},
    {49, -19, 32, .031, .129, .078}, nil, {11, -34, 3}, {8, -39, 5})
local arcEase = fitted({.048, -.212, -.139, -13, 37, -4}, {60, 24, -22, -.092, .111, -.086},
    {55, -17, 26, .034, .145, .06}, nil, {13, -33, 3}, {7, -40, 6})

local wheelLoadEnd, wheelReplantAt = .13, .885
local toeLoadEnd, toeReplantAt = .057, .476
local tacticalContact = {perchPeck = .23, crestWheel = .48, roostTap = .16, sunspur = .25,
    roostHammer = .64, sunriseArc = table.freeze({.31, .66})}
local tacticalClips = {
    perchPeck = {{0, tacticalReady}, {.083, peckGather}, {.155, peckDip},
        {tacticalContact.perchPeck, peckHit}, {.33, peckRecoil}, {.60, tacticalReady}},
    crestWheel = {{0, tacticalReady}, {wheelLoadEnd, wheelCoil}, {.26, wheelChamber}, {.37, wheelSwing},
        {tacticalContact.crestWheel, wheelHit}, {.58, wheelThrough}, {.73, wheelWithdraw},
        {wheelReplantAt, wheelSettle}, {.94, tacticalReady}},
    roostTap = {{0, tacticalReady}, {.061, tapDraw}, {tacticalContact.roostTap, tapHit},
        {.254, tapBack}, {.41, tacticalReady}},
    sunspur = {{0, tacticalReady}, {toeLoadEnd, tacticalReady}, {.135, toeTuck}, {tacticalContact.sunspur, toeHit},
        {.356, toeCollect}, {toeReplantAt, tacticalReady}, {.52, tacticalReady}},
    roostHammer = {{0, tacticalReady}, {.222, hammerRaise}, {.315, hammerRaise}, {.415, hammerLoad},
        {.532, hammerDrive}, {tacticalContact.roostHammer, hammerHit}, {.752, hammerReceive},
        {.979, hammerEase}, {1.26, tacticalReady}},
    sunriseArc = {{0, tacticalReady}, {.141, arcLoad}, {tacticalContact.sunriseArc[1], arcLeft},
        {.485, arcExchange}, {tacticalContact.sunriseArc[2], arcRight}, {.778, arcEase},
        {1.16, tacticalReady}},
}
-- Forward-most surface samples of the upper beak and striking toe in their contact poses.
local tacticalHits = {
    perchPeck = {{peckHit, "Neck", v(.000208800, 4.052779859, -1.061329187)}},
    crestWheel = {{wheelHit, rightHip, v(.478121938, .030394700, -.848528346)}},
    roostTap = {{tapHit, "Right Shoulder", v(1.285693367, 1.853742603, -.529816818)}},
    sunspur = {{toeHit, rightHip, v(.488790424, .048486406, -.879478918)}},
    roostHammer = {{hammerHit, "Right Shoulder", v(1.305415222, 1.931539945, -.600217568)}},
    sunriseArc = {{arcLeft, "Left Shoulder", v(-1.339865944, 1.909587000, -.550582439)},
        {arcRight, "Right Shoulder", v(1.350961495, 1.923599768, -.541536094)}},
}
local tacticalSkills = {
    perchPeck = table.freeze({damage = 13, radius = .47}),
    crestWheel = table.freeze({damage = 21, radius = .49}),
    roostTap = table.freeze({damage = 11, radius = .43}),
    sunspur = table.freeze({damage = 14, radius = .47, foot = true}),
}
local tactical = mountedRig.finish(tacticalClips, tacticalContact, tacticalHits, tacticalSkills, {}, {})
local poses = table.clone(standard)
poses.UltimateSkill = table.freeze({
    roostHammer = table.freeze({damage = 31, radius = .57}),
    sunriseArc = table.freeze({damage = table.freeze({13, 20}), radius = table.freeze({.47, .53})}),
})
for _, field in {"Duration", "Contact", "Impact", "Skill"} do
    local values = table.clone(standard[field])
    for move, value in tactical[field] do
        values[move] = value
    end
    poses[field] = table.freeze(values)
end

function poses.sample(action, age, direction)
    if tacticalContact[action] then
        local time = age or 0
        local both = if action == "crestWheel" then time <= wheelLoadEnd or time >= wheelReplantAt
            elseif action == "sunspur" then time <= toeLoadEnd or time >= toeReplantAt
            else true
        return plantTalons(tactical.sample(action, time, direction), both)
    end
    return standard.sample(action, age, direction)
end

function poses.impact(action, index, direction)
    local source = if tacticalContact[action] then tactical else standard
    return source.impact(action, index, direction)
end

return table.freeze(poses)
