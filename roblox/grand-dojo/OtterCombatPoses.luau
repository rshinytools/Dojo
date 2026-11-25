-- River Otter's original R6 choreography. Surface points are calculated from
-- the authored keys so the palm and pebble cues follow the visible hands.
local Choreography = require(script.Parent.FighterChoreography)
local Poses = {}

local floorY = -2.60
local neck = Vector3.new(0, .54, -.08)
local rightShoulder = Vector3.new(.82, .43, .02)
local leftShoulder = Vector3.new(-.82, .43, .02)
local rightHip = Vector3.new(.47, -1.06, .03)
local leftHip = Vector3.new(-.47, -1.06, .03)
local tail = Vector3.new(0, -1.14, .48)
local rightPalm = Vector3.new(1.15, -.75, -.34)
local leftPalm = Vector3.new(-1.15, -.75, -.34)

local function sole(side)
    return {
        Vector3.new(side * .50, floorY, -.35),
        Vector3.new(side * .50, floorY + .048, -.65),
        Vector3.new(side * .30, floorY + .026, -.37),
        Vector3.new(side * .70, floorY + .026, -.37),
        Vector3.new(side * .51, floorY + .061, -.01),
    }
end

local rightSole, leftSole = sole(1), sole(-1)

local function rotation(pitch, yaw, roll)
    return CFrame.Angles(math.rad(pitch), math.rad(yaw or 0), math.rad(roll or 0))
end

-- A limb key sets pitch, yaw, roll, X, Y and Z translation at its pivot.
local function around(pivot, key)
    local shift = Vector3.new(key[4] or 0, key[5] or 0, key[6] or 0)
    return CFrame.new(pivot + shift) * rotation(key[1], key[2], key[3]) * CFrame.new(-pivot)
end

local function lowest(frame, points)
    local height = math.huge
    for _, point in points do
        height = math.min(height, frame:PointToWorldSpace(point).Y)
    end
    return height
end

local function foot(root, pivot, points, key)
    local offset = around(pivot, key)
    local shift = floorY + key[7] - lowest(root * offset, points)
    return CFrame.new(root:VectorToObjectSpace(Vector3.new(0, shift, 0))) * offset
end

local function pose(core, right, left, rightLeg, leftLeg, head, rudder)
    local root = CFrame.new(core[1], core[2], core[3]) * rotation(core[4], core[5], core[6])
    return {
        RootJoint = root,
        Neck = around(neck, head),
        ["Right Shoulder"] = around(rightShoulder, right),
        ["Left Shoulder"] = around(leftShoulder, left),
        ["Right Hip"] = foot(root, rightHip, rightSole, rightLeg),
        ["Left Hip"] = foot(root, leftHip, leftSole, leftLeg),
        TailJoint = around(tail, rudder),
    }
end

local function mirror(frame)
    local x, y, z, xx, xy, xz, yx, yy, yz, zx, zy, zz = frame:GetComponents()
    return CFrame.new(-x, y, z, xx, -xy, -xz, -yx, yy, yz, -zx, zy, zz)
end

local mirroredJoints = {
    ["Right Shoulder"] = "Left Shoulder", ["Left Shoulder"] = "Right Shoulder",
    ["Right Hip"] = "Left Hip", ["Left Hip"] = "Right Hip",
}

local rightGuard, leftGuard = {56, 17, -6, -.045, .18, .04}, {41, -14, 11, .015, .19, -.015}
local rightFoot, leftFoot = {5, -5, 0, .07, 0, -.11, 0}, {2, 11, 0, -.055, 0, .19, 0}
local watch, tailReady = {4, -11, -1}, {-5, -10, 2}
local ready = pose({.025, -.105, -.02, -6, 10, -3}, rightGuard, leftGuard, rightFoot, leftFoot, watch, tailReady)
local breathe = pose({.02, -.075, -.035, -4, 8, -2}, {59, 14, -7, -.045, .19, .04}, leftGuard,
    rightFoot, leftFoot, {2, -7, -2}, {-3, -5, 1})
local cover = pose({-.04, -.19, .055, -12, -3, 2}, {66, 19, -14, -.07, .23, -.04},
    {67, -20, 14, .075, .22, -.015}, rightFoot, leftFoot, {12, 2, -2}, {-9, 8, -2})
local recoil = pose({-.04, -.21, .15, 7, -8, 6}, {59, 20, -13, -.045, .22, .10},
    {64, -16, 11, .065, .21, .075}, rightFoot, leftFoot, {-11, 7, -3}, {7, 12, -3})
local brush = pose({-.085, -.21, -.035, -12, -28, 11}, {66, 19, -12, -.05, .16, .09},
    {65, 32, -9, .12, .24, -.14}, rightFoot, {-2, 15, 0, -.12, 0, .13, 0}, {9, 20, -7}, {1, 31, -10})

local jabLoad = pose({.055, -.16, .06, -8, -12, -5}, {42, 5, -8, .015, .15, .19},
    leftGuard, rightFoot, leftFoot, {5, 10, 4}, {-5, 12, -3})
local jabHit = pose({.08, -.11, -.23, -10, 23, -3}, {68, 13, -6, -.075, .12, -.27}, leftGuard,
    rightFoot, leftFoot, {8, -22, 3}, {6, -18, 3})
local crossLoad = pose({-.085, -.165, .075, -7, 27, 4}, rightGuard, {43, -4, 10, -.065, .10, .20},
    rightFoot, leftFoot, {5, -23, -4}, {-7, -29, 3})
local crossHit = pose({-.07, -.105, -.26, -11, -28, 4}, rightGuard, {78, -18, 6, .05, .095, -.30},
    rightFoot, {-1, 19, 0, -.06, 0, .12, 0}, {9, 23, -4}, {4, 23, -3})
local bodyLoad = pose({.13, -.27, .06, -15, -22, -8}, {23, 4, -18, .08, -.015, .16},
    leftGuard, rightFoot, leftFoot, {14, 18, 6}, {-12, 32, 8})
local bodyHit = pose({.13, -.26, -.33, -20, 29, -7}, {55, 23, 2, -.07, -.05, -.34},
    leftGuard, rightFoot, {3, 4, 0, -.07, 0, .29, 0}, {16, -24, 6}, {10, -23, -6})
local heavyLoad = pose({-.17, -.27, .13, -7, 48, 11}, {59, 10, -8, -.04, .17, .11},
    {32, 11, 15, -.14, .03, .27}, rightFoot, {6, 18, 0, -.13, 0, .25, 0},
    {5, -32, -7}, {-12, -45, 12})
local heavyHit = pose({-.09, -.15, -.40, -12, -39, 8}, {51, 21, -10, -.045, .14, .12},
    {76, -26, 2, .10, .055, -.42}, rightFoot, {5, 23, 0, -.12, 0, .27, 0},
    {9, 28, -7}, {9, 34, -12})
local heavyFollow = pose({-.13, -.22, -.26, -17, -51, 11}, rightGuard,
    {60, -34, 5, .14, .045, -.23}, rightFoot, leftFoot, {14, 38, -8}, {4, 45, -15})

local stepRight = pose({.085, -.09, -.07, -9, 13, -4}, {52, 19, -8, -.02, .17, .02}, leftGuard,
    {11, -9, 0, .10, 0, -.31, .13}, {4, 7, 0, -.06, 0, .03, 0}, {8, -11, 3}, {-7, -19, 4})
local stepLeft = pose({-.055, -.104, -.08, -8, 7, 4}, rightGuard, {49, -15, 13, .02, .19, -.01},
    {5, -7, 0, .055, 0, .085, 0}, {14, 11, 0, -.07, 0, -.27, .12}, {7, -8, -3}, {-4, 13, -4})
local retreatRight = pose({.065, -.145, .055, 1, 14, -4}, {58, 16, -9, -.045, .18, .09}, leftGuard,
    {-10, -8, 0, .07, 0, .34, .13}, leftFoot, {-3, -11, 3}, {-10, -21, 6})
local retreatLeft = pose({-.035, -.155, .065, 2, 6, 3}, rightGuard, {52, -15, 13, .02, .18, .09},
    rightFoot, {-12, 12, 0, -.065, 0, .35, .12}, {-4, -8, -2}, {-10, 12, -6})
local bank = pose({.16, -.29, .018, -11, -17, -13}, {38, 4, -4, .05, .19, .15},
    {55, -16, 16, .03, .18, .085}, {12, -22, 0, .16, 0, -.12, .12}, leftFoot,
    {9, 13, 7}, {-2, 26, 10})
local brake = pose({.14, -.23, -.035, -7, 11, -7}, {53, 16, -8, 0, .18, .07},
    leftGuard, {5, -13, 0, .155, 0, -.08, 0}, {8, 8, 0, -.045, 0, .15, .07},
    {5, -10, 4}, {1, -16, 5})

local eddySlip = pose({.17, -.28, .075, -17, -23, -13}, {21, 1, -7, .035, .12, .20},
    {66, -17, 13, .045, .21, .09}, {8, -24, -2, .155, 0, -.09, .10}, leftFoot,
    {13, 19, 9}, {-5, 35, 12})
local eddyHit = pose({.17, -.18, -.275, -12, 37, -6}, {72, 27, 2, -.085, .14, -.33},
    {50, -15, 12, .045, .20, .14}, {6, -21, 1, .16, 0, -.065, 0}, {4, 6, 0, -.10, 0, .16, 0},
    {11, -31, 3}, {8, -36, 5})
local eddyFollow = pose({.11, -.24, -.15, -15, 49, -10}, {63, 30, 0, -.125, .12, -.16},
    leftGuard, {7, -20, 0, .155, 0, -.04, 0}, leftFoot, {11, -37, 6}, {2, -42, 9})

local scoop = pose({0, -.34, .06, -19, 6, 2}, {19, 23, -5, -.06, -.07, -.03},
    {25, -22, 5, .07, -.085, -.035}, {7, -8, 0, .07, 0, -.09, 0}, leftFoot,
    {15, -7, -2}, {-12, -5, 4})
local gather = pose({-.03, -.17, .02, -9, 16, 2}, {49, 21, -10, -.07, .06, .09},
    {60, -9, -8, -.14, .12, .09}, rightFoot, leftFoot, {9, -14, -2}, {-3, -19, -4})
local skipLeft = pose({-.04, -.11, -.19, -12, -17, 8}, {58, 25, -9, -.035, .18, .13},
    {68, -5, -2, -.12, .11, -.27}, rightFoot, leftFoot, {10, 12, -5}, {6, 18, -10})
local bankLeft = pose({-.06, -.15, -.035, -6, -28, 5}, {43, 13, -12, .035, .12, .19},
    {46, -11, 3, .025, .12, -.04}, rightFoot, leftFoot, {5, 27, -4}, {-2, 26, -7})
local skipCenter = pose({.01, -.13, -.20, -10, 28, -6}, {74, 24, -13, -.095, .12, -.30},
    {52, -17, 8, .055, .13, .16}, rightFoot, leftFoot, {8, -27, 4}, {8, -33, 10})
local bankRight = pose({.045, -.17, -.01, -8, 15, -7}, {54, 18, -9, -.025, .14, -.025},
    {41, -6, 9, .035, .14, .185}, rightFoot, leftFoot, {8, -13, 5}, {-3, -24, 10})
local skipRight = pose({.06, -.11, -.18, -12, -33, -5}, {58, 18, -10, -.055, .18, .13},
    {71, -23, 6, .13, .10, -.29}, rightFoot, leftFoot, {9, 26, 5}, {8, 31, 7})
local rockFollow = pose({.05, -.17, -.14, -8, -44, 2}, rightGuard, {57, -30, 3, .13, .10, -.17},
    rightFoot, leftFoot, {6, 32, -3}, {7, 40, -4})

local headHit = pose({-.10, -.13, .20, 15, -16, 10}, {42, 15, -13, .025, .17, .16},
    {41, -8, 10, -.015, .13, .19}, rightFoot, leftFoot, {-29, 10, -6}, {9, 30, -7})
local bodyRecoil = pose({.10, -.31, .12, -23, 18, -10}, {56, 21, -15, -.025, -.045, -.06},
    {49, -11, 16, .045, 0, -.055}, rightFoot, leftFoot, {21, -13, 7}, {-17, -27, 6})
local stumble = pose({-.155, -.255, .22, 12, -26, 15}, {39, 8, 15, .05, .09, .17},
    {36, -7, -16, -.035, .10, .17}, rightFoot, {1, 17, 0, -.11, 0, .34, 0},
    {-23, 17, -8}, {10, 42, -9})
local greeting = pose({.055, -.105, -.04, -8, -11, -6}, {69, 2, 24, .12, .14, -.04},
    {41, -10, 7, .035, .18, .035}, rightFoot, leftFoot, {6, 10, 5}, {5, 26, 6})
local bow = pose({0, -.14, -.06, -26, 3, 1}, {35, 17, -18, -.055, .05, .05},
    {35, -17, 18, .055, .05, .05}, rightFoot, leftFoot, {3, -1, -2}, {-9, 5, 0})
local flourish = pose({.01, -.045, -.05, -5, 4, -3}, {97, 6, 20, .085, .095, -.09},
    {45, -11, -5, .015, .145, .09}, rightFoot, leftFoot, {3, -8, 5}, {9, -23, 4})

local releases = table.freeze({.38, .53, .68})
local contact = table.freeze({jab = .163, cross = .223, body = .265, heavy = .427,
    eddyPalm = .31, pebbleBarrage = releases})
local clips = {
    stance = {{0, ready}, {.53, breathe}, {1.14, ready}},
    advance = {{0, ready}, {.146, stepRight}, {.292, ready}, {.436, stepLeft}, {.584, ready}},
    retreat = {{0, ready}, {.162, retreatRight}, {.324, ready}, {.486, retreatLeft}, {.648, ready}},
    sidestep = {{0, ready}, {.10, bank}, {.24, brake}, {.47, ready}},
    jab = {{0, ready}, {.071, jabLoad}, {contact.jab, jabHit}, {.264, breathe}, {.41, ready}},
    cross = {{0, ready}, {.10, crossLoad}, {contact.cross, crossHit}, {.335, breathe}, {.50, ready}},
    body = {{0, ready}, {.127, bodyLoad}, {contact.body, bodyHit}, {.366, bodyLoad}, {.55, ready}},
    heavy = {{0, ready}, {.19, heavyLoad}, {.29, heavyLoad}, {contact.heavy, heavyHit}, {.53, heavyFollow}, {.80, ready}},
    eddyPalm = {{0, ready}, {.13, eddySlip}, {.23, brake}, {contact.eddyPalm, eddyHit}, {.398, eddyFollow}, {.62, ready}},
    pebbleBarrage = {{0, ready}, {.18, scoop}, {.29, gather}, {releases[1], skipLeft}, {.443, bankLeft},
        {releases[2], skipCenter}, {.594, bankRight}, {releases[3], skipRight}, {.775, rockFollow}, {1.08, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.07, recoil}, {.158, recoil}, {.28, cover}},
    parry = {{0, cover}, {.08, brush}, {.16, brush}, {.23, cover}, {.34, ready}},
    hitHead = {{0, ready}, {.081, headHit}, {.194, headHit}, {.33, ready}},
    hitBody = {{0, ready}, {.091, bodyRecoil}, {.208, bodyRecoil}, {.36, ready}},
    stagger = {{0, headHit}, {.13, stumble}, {.34, cover}, {.56, ready}},
    intro = {{0, ready}, {1.06, breathe}, {2.22, ready}, {2.88, greeting}, {3.24, greeting}, {3.72, bow},
        {4.28, ready}, {5.38, breathe}, {6.19, scoop}, {6.57, gather}, {7.03, ready}, {8.41, breathe}, {10, ready}},
    win = {{0, ready}, {.29, flourish}, {.66, flourish}, {1.05, bow}, {1.29, bow}, {1.81, ready}},
}

local durations = {}
for name, frames in clips do
    durations[name] = frames[#frames][1]
end
Poses.Duration = table.freeze(durations)
Poses.Contact = contact

local function point(poseAtContact, joint, position)
    return (poseAtContact.RootJoint * poseAtContact[joint]):PointToWorldSpace(position)
end

Poses.Impact = table.freeze({
    jab = table.freeze({point(jabHit, "Right Shoulder", rightPalm)}),
    cross = table.freeze({point(crossHit, "Left Shoulder", leftPalm)}),
    body = table.freeze({point(bodyHit, "Right Shoulder", rightPalm)}),
    heavy = table.freeze({point(heavyHit, "Left Shoulder", leftPalm)}),
    eddyPalm = table.freeze({point(eddyHit, "Right Shoulder", rightPalm)}),
    pebbleBarrage = table.freeze({point(skipLeft, "Left Shoulder", leftPalm),
        point(skipCenter, "Right Shoulder", rightPalm), point(skipRight, "Left Shoulder", leftPalm)}),
})

local function aim(degrees)
    local angle = math.rad(degrees)
    return Vector3.new(math.sin(angle), 0, -math.cos(angle))
end

Poses.Skill = table.freeze({
    eddyPalm = table.freeze({damage = 19, radius = .45, shove = .48}),
    pebbleBarrage = table.freeze({warningAt = .18, range = 7.8, radius = .30, damage = 8, shove = .40,
        directions = table.freeze({aim(-9), aim(0), aim(9)})}),
})
Poses.Travel = table.freeze({
    eddyPalm = table.freeze({distance = .68, startsAt = .12, endsAt = .29, axis = "lateral"}),
})

function Poses.impact(action, index, direction)
    local hit = Poses.Impact[action][index]
    return if direction == -1 and action == "eddyPalm" then Vector3.new(-hit.X, hit.Y, hit.Z) else hit
end

local loops = {stance = true, advance = true, retreat = true}
local feet = {["Right Hip"] = rightSole, ["Left Hip"] = leftSole}

local function reflectTravel(frames)
    local result = {frames[1]}
    for index = 2, #frames - 1 do
        local time, authored = table.unpack(frames[index])
        local reflected = {}
        for name, offset in authored do
            reflected[mirroredJoints[name] or name] = mirror(offset)
        end
        result[index] = {time, reflected}
    end
    result[#frames] = frames[#frames]
    return result
end

local leftTravel = {sidestep = reflectTravel(clips.sidestep), eddyPalm = reflectTravel(clips.eddyPalm)}
local soleHeights = {}
local function rememberSoles(frames)
    for _, key in frames do
        local authored = key[2]
        if not soleHeights[authored] then
            local heights = {}
            for name, points in feet do
                heights[name] = lowest(authored.RootJoint * authored[name], points)
            end
            soleHeights[authored] = heights
        end
    end
end
for _, frames in clips do
    rememberSoles(frames)
end
for _, frames in leftTravel do
    rememberSoles(frames)
end

function Poses.sample(action, age, direction)
    action = clips[action] and action or "stance"
    local frames = (direction == -1 and leftTravel[action]) or clips[action]
    age = math.max(age or 0, 0)
    if loops[action] then
        age %= durations[action]
    end
    local before, after = frames[#frames], frames[#frames]
    local weight = 0
    for index = 2, #frames do
        if age <= frames[index][1] then
            before, after = frames[index - 1], frames[index]
            local phase = (age - before[1]) / (after[1] - before[1])
            weight = phase * phase * (3 - 2 * phase)
            break
        end
    end
    local root = before[2].RootJoint:Lerp(after[2].RootJoint, weight)
    local result = {RootJoint = root}
    for name, previous in before[2] do
        if name ~= "RootJoint" then
            local following = after[2][name]
            local offset = previous:Lerp(following, weight)
            local solePoints = feet[name]
            if solePoints then
                local oldY, newY = soleHeights[before[2]][name], soleHeights[after[2]][name]
                local shift = oldY + (newY - oldY) * weight - lowest(root * offset, solePoints)
                offset = CFrame.new(root:VectorToObjectSpace(Vector3.new(0, shift, 0))) * offset
            end
            result[name] = offset
        end
    end
    return result
end

Choreography.addShuffle(Poses, rightSole, leftSole, 2.60)
return table.freeze(Poses)
