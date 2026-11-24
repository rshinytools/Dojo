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

local rig = Choreography.new(2.60, {
    Neck = v(0, 3.16, -.03),
    ["Right Shoulder"] = v(.83, 3.02, .03), ["Left Shoulder"] = v(-.83, 3.02, .03),
    ["Right Hip"] = v(.45, 1.54, .02), ["Left Hip"] = v(-.45, 1.54, .02),
    TailJoint = v(0, 1.87, .44),
}, sole(1), sole(-1))
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

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
