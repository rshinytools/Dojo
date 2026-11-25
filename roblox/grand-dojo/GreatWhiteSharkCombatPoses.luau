-- Shark leads with a lean and draws the rear fin in tight before the hook.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new

local function sole(side)
    return {v(side * .167, .012, -.850), v(side * .793, .012, -.850),
        v(side * .167, .012, .180), v(side * .793, .012, .180)}
end

local rig = Choreography.new(2.132, {
    Neck = v(0, 3.11, -.08),
    ["Right Shoulder"] = v(.965, 2.97, .02), ["Left Shoulder"] = v(-.965, 2.97, .02),
    ["Right Hip"] = v(.48, 1.44, .025), ["Left Hip"] = v(-.48, 1.44, .025),
    TailJoint = v(0, 1.71, .61),
}, sole(1), sole(-1))
local pose = rig.pose

local rear = {4, -17, 0, .15, 0, .20, .018}
local lead = {13, 8, 0, -.045, 0, -.22, .018}
local rightGuard = {48, 12, -22, -.035, .065, -.045}
local leftGuard = {58, -19, 20, .08, .08, -.04}
local ready = pose({-.038, -.19, .045, -13, 9, 6}, rightGuard, leftGuard, rear, lead,
    {14, -9, -5}, {-6, -24, -4})
local breathe = pose({-.015, -.132, .028, -10, 13, 3}, {51, 9, -26, -.044, .06, -.042},
    leftGuard, rear, lead, {10, -14, -2}, {-10, -12, 5})
local advanceLead = pose({-.125, -.238, -.101, -19, 20, 8}, {54, 14, -23}, {48, -20, 19},
    rear, {24, 6, -2, -.12, 0, -.34, .17}, {18, -19, -6}, {-7, -34, -6})
local advanceRear = pose({.14, -.200, -.112, -14, -8, -8}, {40, 9, -19}, {64, -13, 22},
    {19, -19, 3, .16, 0, -.30, .14}, lead, {16, 7, 8}, {-8, 29, 8})
local retreatRear = pose({.12, -.16, .142, 3, 15, -6}, {48, 10, -22}, leftGuard,
    {-17, -19, 3, .14, 0, .31, .14}, lead, {-1, -15, 5}, {-4, 26, 6})
local retreatLead = pose({-.12, -.19, .108, 1, 22, 8}, rightGuard, {62, -20, 25},
    rear, {-13, 9, -3, -.12, 0, .29, .13}, {0, -20, -7}, {-4, -31, -7})
local slip = pose({.31, -.36, .074, -19, 8, -21}, {34, 18, -32}, {64, -20, 22, .14, .08, -.026},
    {7, -21, 5, .28, 0, .16, .17}, lead, {20, -6, 19}, {-8, 38, 11})
local catch = pose({.18, -.24, -.082, -13, 18, -10}, rightGuard, leftGuard,
    {6, -19, 1, .24, 0, .09, .018}, lead, {13, -16, 9}, {-11, 20, 4})

local jabLoad = pose({-.08, -.205, .096, -13, -12, 4}, {27, -9, -26, .06, .02, .155},
    leftGuard, rear, lead, {13, 11, -3}, {-6, 18, -4})
local jabHit = pose({.012, -.16, -.238, -15, 29, -2}, {63, 14, -8, -.12, .10, -.24},
    leftGuard, rear, lead, {16, -28, 2}, {-8, -34, 5})
local crossLoad = pose({-.125, -.265, .108, -19, 29, 8}, rightGuard, {26, 10, 30, -.08, .025, .255},
    rear, lead, {18, -27, -7}, {-12, -34, -7})
local crossHit = pose({-.055, -.188, -.267, -13, -32, 7}, {57, 18, -24},
    {68, -17, 11, .154, .075, -.265}, rear, lead, {14, 31, -6}, {-8, 33, 7})
local bodyLoad = pose({.078, -.365, .102, -24, -25, -6}, {27, 6, -30, .08, .018, .185},
    leftGuard, rear, lead, {24, 24, 5}, {-8, 26, -6})
local bodyHit = pose({.055, -.346, -.231, -25, 32, 0}, {55, 21, -9, -.152, -.06, -.25},
    {58, -14, 27}, rear, lead, {26, -31, 0}, {-10, -22, 7})
local heavyLoad = pose({-.19, -.33, .16, -18, 45, 14}, {64, 22, -21, -.06, .07},
    {20, 14, 48, -.155, .04, .39}, rear, lead, {17, -39, -13}, {-7, -47, -10})
local heavyHit = pose({-.07, -.26, -.32, -20, -39, 11}, {43, 12, -24},
    {68, -24, 5, .16, .115, -.275}, rear, lead, {19, 37, -10}, {-7, 46, 10})
local heavyCarry = pose({-.12, -.29, -.18, -24, -48, 14}, rightGuard,
    {53, -36, 16, .18, .045, -.13}, rear, lead, {23, 43, -12}, {-6, 46, 8})

local reefWind = pose({.17, -.31, .17, -14, -39, -14}, {34, -28, -58, .11, .06, .14},
    {68, -23, 21, .087, .09, -.015}, rear, lead, {15, 35, 11}, {-8, 43, -8})
local reefHit = pose({.058, -.21, -.275, -17, 27, 3}, {67, 18, -20, -.20, .065, -.235},
    {48, -17, 32, .053, .075, .055}, rear, lead, {18, -25, -3}, {-9, -37, 9})
local reefCarry = pose({-.108, -.236, -.14, -12, 43, 9}, {74, 36, -15, -.20, .145, -.11},
    leftGuard, rear, lead, {13, -39, -8}, {-9, -45, 8})

-- World locomotion stays on the ring plane. These local offsets dip the art
-- below it while the rule set controls concealment and the server relocation.
local diveWind = pose({0, -.48, .14, -26, -13, 0}, {35, -6, -33, .025, -.045, .145},
    {44, 14, 32, -.03, -.055, .17}, rear, lead, {25, 12, 0}, {-7, 25, -2})
local submerged = pose({0, -4.86, .035, -26, 0, 0}, {45, 15, -22, -.035, -.04, -.08},
    {54, -20, 27, .055, -.055, -.068},
    {15, -14, 1, .12, 0, .18, -4.68}, {17, 11, -1, -.09, 0, -.14, -4.68},
    {24, 0, 0}, {-8, -24, -3})
local emerge = pose({.025, -1.25, -.085, -4, -15, -2}, {44, 13, -16, .035, .02, .048},
    {59, -18, 29, .10, .046, -.12},
    {9, -17, 0, .142, 0, .15, -1.01}, {12, 8, 0, -.06, 0, -.28, -.96},
    {6, 15, 2}, {-9, 20, -6})
local eruption = pose({.038, .035, -.29, -11, 28, -4}, {77, 24, -9, -.155, .125, -.29},
    {54, -18, 27, .107, .083, -.02}, {6, -16, 1, .15, 0, .18, .064},
    {15, 10, 0, -.07, 0, -.25, .018}, {13, -24, 4}, {-11, -35, 9})
local eruptionCarry = pose({.05, -.088, -.15, -17, 33, -3}, {68, 25, -15, -.12, .085, -.16},
    leftGuard, rear, lead, {17, -31, 3}, {-10, -38, 7})

local cover = pose({-.018, -.28, .052, -15, 4, 3}, {65, 22, -26, -.115, .078, -.075},
    {69, -26, 24, .139, .092, -.085}, rear, lead, {16, -4, -2}, {-8, -10, -4})
local recoil = pose({-.06, -.218, .158, 9, 8, 3}, {58, 13, -34, -.10, .088, .065},
    {60, -22, 25, .092, .108, .071}, rear, lead, {-7, -7, -3}, {-13, 21, 5})
local deflect = pose({.025, -.21, -.122, -13, 33, -3}, {64, 9, -48, -.11, .094, -.073},
    {58, -15, 22}, rear, lead, {14, -29, 3}, {-9, -32, 5})
local headHit = pose({.081, -.12, .18, 17, -31, -12}, {30, 9, -35}, {33, -10, 41},
    rear, lead, {-17, 27, 10}, {-8, 36, -6})
local gutHit = pose({-.105, -.437, .136, -30, 17, 11}, {39, 15, -22}, {42, -18, 27},
    rear, lead, {29, -15, -10}, {-6, -27, 7})
local bow = pose({0, -.252, -.105, -27, 0, 0}, {36, 11, -20}, {37, -12, 21},
    rear, lead, {21, 0, 0}, {-11, -8, 2})
local salute = pose({-.067, -.102, -.057, -4, -21, 5}, {58, 13, -26},
    {75, -19, 17, .145, .16, -.11}, rear, lead, {4, 20, -4}, {-7, 26, -6})
local rollFins = pose({.022, -.053, -.033, 3, 17, -2}, {75, -21, -51, .07, .115, -.116},
    {71, 14, 39, -.07, .135, -.04}, rear, lead, {0, -15, 2}, {-9, -31, 8})

local contact = {jab = .157, cross = .216, body = .266, heavy = .421,
    reefHook = .30, jawsOfTheDeep = .84}
local submergeAt, teleportAt, resurfaceAt = .27, .58, .76
local clips = {
    stance = {{0, ready}, {.53, breathe}, {1.06, ready}},
    advance = {{0, ready}, {.143, advanceLead}, {.286, ready}, {.425, advanceRear}, {.564, ready}},
    retreat = {{0, ready}, {.162, retreatRear}, {.323, ready}, {.484, retreatLead}, {.646, ready}},
    sidestep = {{0, ready}, {.095, slip}, {.217, catch}, {.394, ready}},
    jab = {{0, ready}, {.07, jabLoad}, {contact.jab, jabHit}, {.211, jabHit}, {.401, ready}},
    cross = {{0, ready}, {.095, crossLoad}, {contact.cross, crossHit}, {.278, crossHit}, {.486, ready}},
    body = {{0, ready}, {.11, bodyLoad}, {contact.body, bodyHit}, {.36, breathe}, {.542, ready}},
    heavy = {{0, ready}, {.164, heavyLoad}, {.269, heavyLoad}, {contact.heavy, heavyHit},
        {.515, heavyCarry}, {.788, ready}},
    reefHook = {{0, ready}, {.122, reefWind}, {.203, reefWind}, {contact.reefHook, reefHit},
        {.39, reefCarry}, {.622, ready}},
    jawsOfTheDeep = {{0, ready}, {.173, diveWind}, {.22, diveWind}, {submergeAt, submerged},
        {resurfaceAt, submerged}, {.798, emerge}, {contact.jawsOfTheDeep, eruption}, {.93, eruptionCarry},
        {1.18, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.075, recoil}, {.147, recoil}, {.27, cover}},
    parry = {{0, cover}, {.079, deflect}, {.151, deflect}, {.314, ready}},
    hitHead = {{0, ready}, {.07, headHit}, {.147, headHit}, {.324, ready}},
    hitBody = {{0, ready}, {.087, gutHit}, {.169, gutHit}, {.351, ready}},
    stagger = {{0, headHit}, {.148, catch}, {.281, recoil}, {.527, ready}},
    intro = {{0, ready}, {.69, breathe}, {1.22, salute}, {1.97, salute}, {2.42, bow}, {2.94, ready},
        {3.66, reefWind}, {4.11, reefHit}, {4.64, reefCarry}, {5.21, ready}, {6.10, advanceLead},
        {6.72, ready}, {7.40, rollFins}, {8.03, ready}, {8.82, breathe}, {10, ready}},
    win = {{0, ready}, {.31, rollFins}, {.85, rollFins}, {1.20, salute}, {1.51, bow}, {1.91, ready}},
}

local rightPad, leftPad = v(1.215, 1.89, -.888), v(-1.215, 1.89, -.888)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightPad}}, cross = {{crossHit, "Left Shoulder", leftPad}},
    body = {{bodyHit, "Right Shoulder", rightPad}}, heavy = {{heavyHit, "Left Shoulder", leftPad}},
    reefHook = {{reefHit, "Right Shoulder", rightPad}},
    jawsOfTheDeep = {{eruption, "Right Shoulder", rightPad}},
}
local skills = {
    reefHook = table.freeze({damage = 21, radius = .61, shove = .94}),
    jawsOfTheDeep = table.freeze({damage = 28, submergeAt = submergeAt, resurfaceAt = resurfaceAt,
        teleportAt = teleportAt, shove = 1.28}),
}
local travel = {reefHook = table.freeze({axis = "forward", distance = .33, startsAt = .16, endsAt = .28})}

return rig.finish(clips, contact, hits, skills, travel, {"sidestep"})
