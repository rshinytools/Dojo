-- The Storm Dragon coils for short counterattacks. Tempest Roar is a steady
-- hover with its beam originating at the modeled opening in the muzzle.
local Choreography = require(script.Parent.FighterChoreography)
local v = Vector3.new
local rootHeight = 2.132

local function sole(side)
    local x = side * .52
    return {v(x - .34, .012, -.88), v(x + .34, .012, -.88),
        v(x - .34, .012, .16), v(x + .34, .012, .16)}
end

local rig = Choreography.new(rootHeight, {
    Neck = v(0, 3.27, -.04),
    ["Right Shoulder"] = v(1.11, 3.13, .07), ["Left Shoulder"] = v(-1.11, 3.13, .07),
    ["Right Hip"] = v(.52, 1.51, .075), ["Left Hip"] = v(-.52, 1.51, .075),
    TailJoint = v(0, 1.82, .66),
}, sole(1), sole(-1))
local pose = rig.pose

local rear = {7, -19, 0, .151, 0, .19, .018}
local lead = {10, 15, 0, -.104, 0, -.185, .018}
local rightGuard = {45, 17, -36, -.071, .057, -.042}
local leftGuard = {52, -20, 38, .089, .065, -.056}
local ready = pose({.027, -.181, .058, -11, -9, -3}, rightGuard, leftGuard, rear, lead,
    {10, 9, 2}, {-10, -14, 4})
local breathe = pose({.011, -.127, .047, -7, -6, -2}, {48, 15, -37, -.069, .066, -.041},
    {55, -20, 33, .083, .073, -.051}, rear, lead, {7, 6, 2}, {-8, 15, -3})
local stepLead = pose({-.135, -.245, -.138, -15, 12, 7}, {54, 21, -33}, {41, -13, 29},
    rear, {24, 16, -4, -.146, 0, -.278, .151}, {15, -11, -6}, {-13, -26, -7})
local stepRear = pose({.137, -.24, -.143, -16, -11, -9}, {43, 12, -28}, {62, -19, 35},
    {22, -19, 4, .168, 0, -.258, .152}, lead, {16, 10, 7}, {-15, 24, 8})
local backRear = pose({.135, -.183, .171, -1, 8, -7}, {47, 15, -37}, {63, -19, 33},
    {-14, -22, 4, .174, 0, .285, .123}, lead, {4, -6, 7}, {-9, 29, 8})
local backLead = pose({-.137, -.17, .144, -4, -8, 9}, {57, 18, -37}, {45, -15, 28},
    rear, {-13, 19, -3, -.144, 0, .272, .122}, {5, 6, -7}, {-11, -28, -8})
local slip = pose({.292, -.304, .041, -17, 14, -23}, {36, 14, -52}, {60, -21, 27},
    {8, -24, 6, .285, 0, .129, .138}, lead, {17, -12, 16}, {-16, 27, 12})
local catch = pose({.175, -.257, -.068, -12, 17, -10}, rightGuard, leftGuard,
    {7, -24, 3, .28, 0, .081, .018}, lead, {13, -15, 8}, {-13, -29, 7})

local jabLoad = pose({.092, -.208, .102, -11, -21, -5}, {32, 8, -36, .065, .018, .177},
    leftGuard, rear, lead, {10, 19, 4}, {-12, 23, 6})
local jabHit = pose({.026, -.141, -.235, -8, 31, -3}, {69, 22, -12, -.163, .10, -.231},
    leftGuard, rear, lead, {9, -29, 2}, {-10, -36, 6})
local crossLoad = pose({-.11, -.25, .137, -14, 28, 8}, rightGuard, {28, 4, 44, -.075, .045, .248},
    rear, lead, {15, -26, -7}, {-13, -34, -7})
local crossHit = pose({-.057, -.171, -.268, -11, -35, 6}, {56, 17, -31},
    {70, -23, 11, .179, .11, -.248}, rear, lead, {11, 32, -5}, {-12, 41, 7})
local bodyLoad = pose({.119, -.349, .096, -20, -24, -8}, {26, 5, -44, .118, -.031, .197},
    leftGuard, rear, lead, {21, 21, 6}, {-15, 30, -8})
local bodyHit = pose({.064, -.34, -.257, -22, 32, -2}, {59, 26, -11, -.18, -.052, -.243},
    {61, -20, 33}, rear, lead, {22, -29, 1}, {-15, -40, 8})
local heavyLoad = pose({-.121, -.327, .184, -22, 38, 10}, {61, 21, -24, -.07, .085, -.037},
    {22, 2, 55, -.147, .038, .30}, rear, lead, {20, -34, -9}, {-15, -47, -9})
local heavyHit = pose({-.086, -.231, -.285, -17, -37, 8}, {43, 16, -36},
    {71, -27, 10, .215, .11, -.278}, rear, lead, {17, 34, -6}, {-13, 47, 8})
local heavyCarry = pose({-.116, -.29, -.155, -22, -42, 13}, rightGuard,
    {56, -37, 15, .173, .04, -.139}, rear, lead, {21, 39, -10}, {-14, 51, 9})

local clawWind = pose({-.096, -.262, .145, -14, 41, 10}, {61, 15, -35},
    {38, 9, 63, -.12, .083, .20}, rear, lead, {13, -36, -9}, {-16, -47, -9})
local clawArmed = pose({-.062, -.21, .022, -12, 19, 6}, {58, 13, -32},
    {54, -8, 49, -.076, .118, -.029}, rear, lead, {11, -17, -5}, {-15, -24, 5})
local clawHit = pose({-.043, -.198, -.278, -13, -36, 7}, {61, 17, -32},
    {70, -28, 11, .219, .084, -.229}, rear, lead, {12, 32, -6}, {-14, 45, 8})
local clawFollow = pose({-.092, -.271, -.143, -20, -47, 10}, rightGuard,
    {51, -41, 8, .21, .038, -.104}, rear, lead, {18, 43, -9}, {-17, 48, 11})

local anchorRight = {6, -22, 0, .19, 0, .145, .018}
local anchorLeft = {7, 23, 0, -.195, 0, -.145, .018}
local gather = pose({0, -.38, .10, -19, 0, 0}, {35, -8, -47, .071, .079, .094},
    {36, 8, 48, -.071, .079, .094}, anchorRight, anchorLeft, {16, 0, 0}, {-18, 3, 0})
local haloRise = pose({.0, .33, -.012, -10, 0, 0}, {59, -8, -52, .079, .099, .065},
    {60, 9, 51, -.079, .098, .062}, {14, -20, 0, .14, 0, .05, .43},
    {16, 22, 0, -.13, 0, -.151, .42}, {4, 0, 0}, {-21, 8, 0})

local hoverRight = {21, -17, 0, .14, 0, .092, .91}
local hoverLeft = {23, 17, 0, -.14, 0, -.142, .93}
local beamPush = pose({.005, .89, -.128, -15, 0, 0}, {47, -11, -55, .084, .1, .045},
    {48, 10, 55, -.085, .099, .045}, hoverRight, hoverLeft, {-19, 0, 0}, {-24, 9, 2})
local beamEase = pose({-.013, .84, -.100, -12, 0, 2}, {52, -7, -49, .061, .087, .071},
    {43, 13, 52, -.063, .090, .074}, hoverRight, hoverLeft, {-22, 0, -2}, {-19, -9, -3})
local discharge = pose({.009, .73, -.089, -13, 0, -2}, {54, -8, -53, .06, .097, .047},
    {54, 8, 54, -.06, .098, .048}, hoverRight, hoverLeft, {-14, 0, 2}, {-22, 5, 3})
local lower = pose({0, .27, -.06, -10, 0, 0}, {49, -6, -50, .05, .063, .045},
    {50, 5, 49, -.05, .06, .044}, {15, -17, 0, .145, 0, .09, .31},
    {16, 17, 0, -.14, 0, -.12, .30}, {4, 0, 0}, {-17, -6, 0})
local settle = pose({0, -.30, -.038, -16, 0, 0}, {42, 11, -38, -.057, .07, -.042},
    {44, -12, 39, .056, .069, -.043}, anchorRight, anchorLeft, {14, 0, 0}, {-12, 4, 0})

local cover = pose({.013, -.319, .083, -14, -2, -1}, {67, 18, -22, -.14, .101, -.079},
    {68, -19, 23, .129, .100, -.079}, rear, lead, {14, 2, 1}, {-12, 6, 3})
local recoil = pose({-.07, -.291, .176, 7, -10, 7}, {62, 15, -21, -.10, .068, .059},
    {60, -15, 22, .11, .065, .064}, rear, lead, {-9, 9, -5}, {-13, 14, -8})
local deflect = pose({.055, -.268, -.131, -17, 28, -5}, {70, -2, -15, -.148, .144, -.129},
    {60, -17, 27, .10, .082, .031}, rear, lead, {17, -25, 4}, {-15, -27, 7})
local headHit = pose({-.11, -.273, .187, 14, -23, 11}, {37, 11, -28}, {42, -12, 27},
    rear, lead, {-19, 20, -10}, {-14, 26, -11})
local hurt = pose({.095, -.429, .166, -24, 19, -10}, {31, 13, -23}, {38, -13, 25},
    rear, lead, {23, -17, 8}, {-16, -25, 9})
local salute = pose({.033, -.10, -.033, 2, -13, 5}, {76, 6, -22, -.065, .136, -.066},
    leftGuard, rear, lead, {-3, 13, -4}, {-9, 17, -6})
local bow = pose({0, -.31, -.151, -27, 0, 0}, {36, 13, -23}, {36, -15, 25},
    rear, lead, {23, 0, 0}, {-14, 4, 0})
local dragonCrown = pose({0, -.056, .041, 8, 0, 0}, {71, -13, -56, .078, .095, .086},
    {70, 14, 56, -.081, .095, .088}, anchorRight, anchorLeft, {15, 0, 0}, {-10, -7, 1})

local channelAt, channelEnd = .52, 1.54
local beamBeats = table.freeze({channelAt, .76, 1.00, 1.24, 1.48})
local thunderAt = 1.37
local contacts = {jab = .175, cross = .239, body = .281, heavy = .433, stormClaw = .31,
    tempestRoar = table.freeze({beamBeats[1], beamBeats[2], beamBeats[3], beamBeats[4], thunderAt, beamBeats[5]})}
local clips = {
    stance = {{0, ready}, {.675, breathe}, {1.35, ready}},
    advance = {{0, ready}, {.176, stepLead}, {.355, breathe}, {.533, stepRear}, {.711, ready}},
    retreat = {{0, ready}, {.185, backRear}, {.37, breathe}, {.553, backLead}, {.748, ready}},
    sidestep = {{0, ready}, {.124, slip}, {.266, catch}, {.481, ready}},
    jab = {{0, ready}, {.077, jabLoad}, {contacts.jab, jabHit}, {.233, jabHit}, {.434, ready}},
    cross = {{0, ready}, {.102, crossLoad}, {contacts.cross, crossHit}, {.309, crossHit}, {.515, ready}},
    body = {{0, ready}, {.131, bodyLoad}, {contacts.body, bodyHit}, {.396, breathe}, {.59, ready}},
    heavy = {{0, ready}, {.19, heavyLoad}, {.278, heavyLoad}, {contacts.heavy, heavyHit},
        {.551, heavyCarry}, {.829, ready}},
    stormClaw = {{0, ready}, {.135, clawWind}, {.224, clawArmed}, {contacts.stormClaw, clawHit},
        {.403, clawFollow}, {.53, breathe}, {.679, ready}},
    tempestRoar = {{0, ready}, {.17, gather}, {.27, gather}, {.41, haloRise},
        {beamBeats[1], beamPush}, {beamBeats[2], beamEase}, {beamBeats[3], beamPush},
        {beamBeats[4], beamEase}, {thunderAt, beamPush}, {beamBeats[5], beamEase},
        {channelEnd, discharge}, {1.66, lower}, {1.78, settle}, {1.92, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.086, recoil}, {.169, recoil}, {.295, cover}},
    parry = {{0, cover}, {.088, deflect}, {.177, deflect}, {.359, ready}},
    hitHead = {{0, ready}, {.081, headHit}, {.165, headHit}, {.373, ready}},
    hitBody = {{0, ready}, {.091, hurt}, {.188, hurt}, {.394, ready}},
    stagger = {{0, headHit}, {.168, catch}, {.331, recoil}, {.579, ready}},
    intro = {{0, ready}, {.86, breathe}, {1.42, salute}, {2.10, salute}, {2.68, bow}, {3.20, ready},
        {3.97, clawWind}, {4.39, clawHit}, {4.84, clawFollow}, {5.22, ready},
        {5.81, gather}, {6.26, haloRise}, {6.61, beamPush}, {7.17, beamEase}, {7.49, lower},
        {7.79, settle}, {8.32, ready}, {9.09, breathe}, {10, ready}},
    win = {{0, ready}, {.38, dragonCrown}, {1.17, dragonCrown}, {1.52, bow}, {1.8, bow}, {2.24, ready}},
}

local rightClaw, leftClaw = v(1.37, 1.94, -.830), v(-1.37, 1.94, -.830)
local muzzle = v(0, 3.69, -1.305)
local hits = {
    jab = {{jabHit, "Right Shoulder", rightClaw}}, cross = {{crossHit, "Left Shoulder", leftClaw}},
    body = {{bodyHit, "Right Shoulder", rightClaw}}, heavy = {{heavyHit, "Left Shoulder", leftClaw}},
    stormClaw = {{clawHit, "Left Shoulder", leftClaw}},
    tempestRoar = {{beamPush, "Neck", muzzle}, {beamEase, "Neck", muzzle}, {beamPush, "Neck", muzzle},
        {beamEase, "Neck", muzzle}, v(0, -rootHeight, 0), {beamEase, "Neck", muzzle}},
}
local skills = {
    stormClaw = table.freeze({damage = 21, radius = .60, shove = .88}),
    tempestRoar = table.freeze({
        aimAt = .24, channelAt = channelAt, channelEnd = channelEnd, beamBeats = beamBeats,
        maxYaw = math.rad(40), steerRate = math.rad(86), range = 8.2, beamRadius = .83, beamDamage = 6,
        thunderWarnAt = .70, thunderAt = thunderAt, thunderRadius = 1.35, thunderDamage = 10,
    }),
}
local travel = {stormClaw = table.freeze({axis = "forward", distance = .29, startsAt = .163, endsAt = .30})}

local poses = table.clone(rig.finish(clips, contacts, hits, skills, travel, {"sidestep"}))
function poses.muzzleAt(age)
    local offsets = poses.sample("tempestRoar", age)
    local head = offsets.RootJoint * offsets.Neck
    return head:PointToWorldSpace(muzzle - v(0, rootHeight, 0)), head.LookVector
end

return table.freeze(poses)
