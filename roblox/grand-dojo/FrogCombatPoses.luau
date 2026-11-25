-- Karate Frog's original R6 choreography. Transforms are relative to the
-- floor-aligned shell at rest. The ring handles travel and confirms contacts.
local Choreography = require(script.Parent.FighterChoreography)
local Poses = {}

local floorY = -2.60
local neck = Vector3.new(0, .47, -.03)
local rightShoulder = Vector3.new(.79, .34, .02)
local leftShoulder = Vector3.new(-.79, .34, .02)
local rightHip = Vector3.new(.46, -1.10, .04)
local leftHip = Vector3.new(-.46, -1.10, .04)
local rightFist = Vector3.new(1.10, -.85, -.35)
local leftFist = Vector3.new(-1.10, -.85, -.35)
local rightToe = Vector3.new(.48, -2.48, -.82)
local leftToe = Vector3.new(-.48, -2.48, -.82)

local function sole(side)
    return {
        Vector3.new(side * .48, floorY, -.42),
        Vector3.new(side * .48, floorY + .045, -.73),
        Vector3.new(side * .27, floorY + .024, -.46),
        Vector3.new(side * .69, floorY + .024, -.46),
        Vector3.new(side * .49, floorY + .057, -.08),
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
    if key[7] == nil then
        return offset
    end
    local shift = floorY + key[7] - lowest(root * offset, points)
    return CFrame.new(root:VectorToObjectSpace(Vector3.new(0, shift, 0))) * offset
end

local function pose(core, right, left, rightLeg, leftLeg, head)
    local root = CFrame.new(core[1], core[2], core[3]) * rotation(core[4], core[5], core[6])
    return {
        RootJoint = root,
        Neck = around(neck, head),
        ["Right Shoulder"] = around(rightShoulder, right),
        ["Left Shoulder"] = around(leftShoulder, left),
        ["Right Hip"] = foot(root, rightHip, rightSole, rightLeg),
        ["Left Hip"] = foot(root, leftHip, leftSole, leftLeg),
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

local rightGuard, leftGuard = {47, 19, -9, -.03, .14, .09}, {65, -9, 13, .03, .10, .04}
local rearFoot, frontFoot = {3, -12, 0, .10, 0, .17, 0}, {7, 7, 0, -.13, 0, -.23, 0}
local watch = {6, 14, -2}
local ready = pose({0, -.16, 0, -7, -15, 2}, rightGuard, leftGuard, rearFoot, frontFoot, watch)
local breathe = pose({.015, -.125, .015, -5, -13, 1}, {50, 18, -10, -.04, .16, .09},
    leftGuard, rearFoot, frontFoot, {4, 12, -1})
local cover = pose({-.03, -.25, .08, -12, 3, 2}, {69, 16, -17, -.04, .21, -.01},
    {72, -17, 17, .04, .21, -.015}, rearFoot, frontFoot, {10, -2, -1})
local recoil = pose({.06, -.24, .16, 9, 8, -7}, {60, 14, -21, -.03, .18, .10},
    {60, -15, 17, .03, .19, .09}, rearFoot, frontFoot, {-7, -3, 4})
local redirect = pose({.08, -.24, -.08, -8, 32, -8}, {64, -17, 3, -.06, .20, -.02},
    {54, -16, 12, .03, .12, .09}, {7, -19, 0, .20, 0, .13, 0}, frontFoot, {7, -28, 4})

local jabLoad = pose({-.045, -.24, .05, -11, 1, 5}, rightGuard,
    {38, 1, 15, .015, .09, .18}, rearFoot, frontFoot, {9, -3, -4})
local jabHit = pose({-.055, -.13, -.27, -10, -29, 3}, rightGuard,
    {74, -10, 7, -.015, .14, -.27}, rearFoot, frontFoot, {8, 25, -2})
local crossLoad = pose({.12, -.23, .045, -13, -32, -7}, {34, 3, -11, .045, .07, .26},
    leftGuard, rearFoot, frontFoot, {10, 25, 3})
local crossHit = pose({.06, -.11, -.31, -10, 31, -3}, {76, 15, -8, .035, .13, -.31},
    leftGuard, {4, -22, 0, .11, 0, .19, 0}, frontFoot, {6, -25, 3})
local bodyLoad = pose({-.13, -.28, .015, -17, 1, 8}, rightGuard,
    {17, -1, 9, -.055, -.042, .06}, rearFoot, frontFoot, {14, -2, -5})
local bodyHit = pose({-.11, -.30, -.29, -19, -23, 5}, rightGuard,
    {54, -10, 10, -.015, -.055, -.34}, rearFoot, frontFoot, {14, 20, -4})
local heavyGather = pose({.19, -.30, .16, -12, -49, -9}, {20, -7, -21, .10, .02, .30},
    {58, -3, 15, .045, .13, .09}, {9, 7, 0, .17, 0, .21, 0}, frontFoot, {8, 37, 5})
local heavyHit = pose({-.01, -.06, -.43, -13, 37, -5}, {77, 22, -9, .025, .12, -.38},
    {49, -10, 15, .02, .12, .15}, {8, -23, 0, .09, 0, .26, 0}, frontFoot, {9, -29, 4})
local heavyFollow = pose({-.08, -.19, -.29, -18, 52, -8}, {68, 19, -13, -.045, .11, -.19},
    leftGuard, rearFoot, frontFoot, {14, -36, 5})

local stepRight = pose({.12, -.12, -.10, -10, -18, -4}, {50, 17, -9, 0, .15, .04},
    leftGuard, {13, -13, -4, .07, 0, -.23, .15}, {3, 4, 2, -.12, 0, .12, 0}, {9, 16, 3})
local stepLeft = pose({-.10, -.13, -.08, -10, -9, 5}, rightGuard,
    {57, -11, 15, .02, .09, .03}, {3, -11, -3, .10, 0, .15, 0}, {15, 7, 4, -.14, 0, -.28, .14},
    {9, 8, -3})
local retreatRight = pose({.055, -.17, .10, -3, -11, -4}, {54, 17, -11, -.01, .15, .09},
    leftGuard, {-14, -12, 0, .11, 0, .39, .13}, frontFoot, {4, 9, 3})
local retreatLeft = pose({-.07, -.19, .09, -3, -17, 5}, rightGuard, {66, -9, 15, .025, .12, .09},
    rearFoot, {-11, 8, 0, -.13, 0, .31, .15}, {4, 14, -3})
local duck = pose({.17, -.38, .02, -15, -18, -12}, {51, 18, -11, -.04, .15, .07},
    {51, -15, 24, .05, .13, .17}, {10, -23, -4, .18, 0, -.17, .13}, frontFoot, {13, 15, 9})
local catch = pose({.14, -.24, -.035, -7, 1, -6}, {54, 17, -10, -.04, .15, .07},
    leftGuard, {6, -17, 0, .18, 0, -.08, 0}, {6, 5, 0, -.09, 0, .13, .09}, {5, -3, 4})

local vaultCrouch = pose({0, -.42, .10, -24, -9, 0}, {15, 9, -14, .02, .02, .25},
    {19, -8, 15, -.015, .02, .14}, {15, -12, 0, .11, 0, .14, 0}, {17, 7, 0, -.12, 0, -.10, 0}, {19, 5})
local vaultTuck = pose({0, .42, -.025, 11, -4, 3}, {63, 10, -18, .045, .13, .07},
    {67, -11, 21, -.03, .12, .08}, {62, -12, 0, .055, .16, .12}, {65, 10, 0, -.08, .11, .10}, {-8, 3, -1})
local vaultExtend = pose({0, .40, .025, 17, -3, 0}, {28, 3, 21, .12, .08, .24},
    {26, -5, -22, -.12, .08, .19}, {71, -4, -3, .025, .14, -.22}, {73, 4, 5, -.03, .18, -.21},
    {-14, 2})
local vaultFold = pose({0, .31, .045, 14, -2, -3}, {44, 7, -1, .06, .11, .17},
    {49, -11, 7, -.06, .11, .09}, {56, -9, 0, .06, .08, .06}, {61, 5, 0, -.065, .09, .07},
    {-11, 2, 2})
local vaultLand = pose({-.035, -.32, -.02, -18, -9, 2}, {53, 11, -8, -.02, .11, .04},
    {64, -10, 14, .035, .14, .08}, {8, -12, 0, .12, 0, .10, 0}, {12, 10, 0, -.14, 0, -.22, 0},
    {16, 6, -2})

local coil = pose({0, -.34, .035, -15, -49, 4}, {41, 42, -21, -.06, .22, -.06},
    {55, -20, 26, .08, .19, .04}, rearFoot, frontFoot, {10, 31, -3})
local firstTurn = pose({0, -.115, .03, -7, 39, 2}, {40, 1, 37, .08, .09, -.02},
    {55, -31, -18, -.04, .15, -.06}, {11, -7, 0, .10, 0, .08, 0}, {17, 15, 0, -.13, 0, -.12, .23},
    {6, 28, -4})
local fanTurn = pose({0, .055, -.01, -6, 132, -2}, {60, -29, 74, .095, 0, -.10},
    {56, 23, -73, -.08, .05, -.13}, {8, -28, 3, .13, 0, .09, 0}, {28, 6, 0, -.14, 0, -.16, .35},
    {6, 27, 5})
local spinHit = pose({0, .095, -.015, -4, 219, -4}, {83, -42, 65, .15, .03, -.14},
    {75, 39, -68, -.14, .03, -.12}, {9, -28, 4, .115, 0, .04, .04}, {30, 20, 0, -.15, 0, -.13, .36},
    {4, 30, 6})
local spinFollow = pose({0, -.025, .02, -5, 296, 1}, {61, -24, 74, .11, .05, -.06},
    {63, 25, -66, -.1, .09, -.12}, {11, -12, 0, .12, 0, .17, 0}, {19, 8, 0, -.14, 0, -.16, .19},
    {5, 21, -1})
local spinBrake = pose({.04, -.23, .045, -13, 365, -4}, {42, 10, -5, -.035, .13, .06},
    leftGuard, rearFoot, frontFoot, {12, -4, 3})

local headHit = pose({.105, -.16, .21, 14, 17, -10}, {34, 11, -15, 0, .13, .13},
    {48, -12, 13, .02, .11, .18}, rearFoot, frontFoot, {-27, -9, 6})
local bodyRecoil = pose({-.09, -.35, .16, -26, -21, 10}, {63, 24, -23, -.035, -.03, -.05},
    {59, -21, 25, .04, -.025, -.05}, rearFoot, frontFoot, {20, 17, -7})
local wobble = pose({.16, -.23, .23, 15, 29, -14}, {29, 3, 22, .07, .09, .14},
    {38, -6, -16, -.04, .09, .22}, {2, -8, 0, .18, 0, .32, 0}, frontFoot, {-24, -19, 8})
local bow = pose({0, -.19, -.08, -29, -4, 0}, {33, 3, -19, -.04, .10, .08},
    {33, -3, 19, .04, .10, .08}, rearFoot, frontFoot, {-3, 3})
local salute = pose({0, -.105, -.035, -9, 2, 1}, {66, 18, -22, -.10, .24, -.035},
    {69, -20, 19, .11, .22, -.03}, rearFoot, frontFoot, {4, -5, -1})
local victory = pose({.04, -.09, -.06, -8, -8, -6}, {98, -4, -20, .11, .08, -.08},
    {43, -4, 7, .035, .04, .11}, rearFoot, frontFoot, {5, 7, 4})

local contact = table.freeze({jab = .158, cross = .218, body = .252, heavy = .418,
    lilyVault = .34, tadpoleTornado = .53})
local clips = {
    stance = {{0, ready}, {.48, breathe}, {1.04, ready}},
    advance = {{0, ready}, {.135, stepRight}, {.27, ready}, {.405, stepLeft}, {.54, ready}},
    retreat = {{0, ready}, {.15, retreatRight}, {.30, ready}, {.45, retreatLeft}, {.60, ready}},
    sidestep = {{0, ready}, {.100, duck}, {.23, catch}, {.45, ready}},
    jab = {{0, ready}, {.063, jabLoad}, {contact.jab, jabHit}, {.25, jabLoad}, {.39, ready}},
    cross = {{0, ready}, {.092, crossLoad}, {contact.cross, crossHit}, {.31, breathe}, {.47, ready}},
    body = {{0, ready}, {.108, bodyLoad}, {contact.body, bodyHit}, {.36, bodyLoad}, {.53, ready}},
    heavy = {{0, ready}, {.20, heavyGather}, {.32, jabLoad}, {contact.heavy, heavyHit}, {.52, heavyFollow}, {.78, ready}},
    lilyVault = {{0, ready}, {.15, vaultCrouch}, {.252, vaultTuck}, {contact.lilyVault, vaultExtend},
        {.426, vaultFold}, {.54, vaultLand}, {.72, ready}},
    tadpoleTornado = {{0, ready}, {.18, coil}, {.267, coil}, {.36, firstTurn}, {.438, fanTurn},
        {contact.tadpoleTornado, spinHit}, {.63, spinFollow}, {.75, spinBrake}, {.892, breathe}, {1.03, ready}},
    guard = {{0, cover}},
    block = {{0, cover}, {.067, recoil}, {.175, recoil}, {.29, cover}},
    parry = {{0, cover}, {.085, redirect}, {.159, redirect}, {.246, cover}, {.35, ready}},
    hitHead = {{0, ready}, {.077, headHit}, {.188, headHit}, {.33, ready}},
    hitBody = {{0, ready}, {.085, bodyRecoil}, {.201, bodyRecoil}, {.37, ready}},
    stagger = {{0, headHit}, {.12, wobble}, {.32, cover}, {.52, ready}},
    intro = {{0, ready}, {1.12, breathe}, {2.38, ready}, {2.85, salute}, {3.30, bow},
        {3.66, bow}, {4.15, ready}, {5.36, breathe}, {6.22, vaultCrouch}, {6.43, ready},
        {7.54, breathe}, {8.53, ready}, {10, ready}},
    win = {{0, ready}, {.22, victory}, {.61, victory}, {.91, salute}, {1.21, bow}, {1.44, bow}, {1.86, ready}},
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

local vaultToes = point(vaultExtend, "Right Hip", rightToe):Lerp(point(vaultExtend, "Left Hip", leftToe), .5)
local tornadoCenter = Vector3.new(0, floorY, 0)
Poses.Impact = table.freeze({
    jab = table.freeze({point(jabHit, "Left Shoulder", leftFist)}),
    cross = table.freeze({point(crossHit, "Right Shoulder", rightFist)}),
    body = table.freeze({point(bodyHit, "Left Shoulder", leftFist)}),
    heavy = table.freeze({point(heavyHit, "Right Shoulder", rightFist)}),
    lilyVault = table.freeze({vaultToes}),
    tadpoleTornado = table.freeze({tornadoCenter}),
})

Poses.Skill = table.freeze({
    lilyVault = table.freeze({damage = 20, radius = .48, shove = .56}),
    tadpoleTornado = table.freeze({center = tornadoCenter, radius = 3.2, warningAt = .18,
        deflectFrom = .36, deflectUntil = .69, damage = 28, shove = .94}),
})
Poses.Travel = table.freeze({
    lilyVault = table.freeze({distance = 1.65, startsAt = .18, endsAt = contact.lilyVault, axis = "forward"}),
})

local loops = {stance = true, advance = true, retreat = true}
local feet = {["Right Hip"] = rightSole, ["Left Hip"] = leftSole}
local leftDodge = {clips.sidestep[1]}
for index = 2, #clips.sidestep - 1 do
    local time, authored = table.unpack(clips.sidestep[index])
    local reflected = {}
    for name, offset in authored do
        reflected[mirroredJoints[name] or name] = mirror(offset)
    end
    leftDodge[index] = {time, reflected}
end
leftDodge[#clips.sidestep] = clips.sidestep[#clips.sidestep]

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
rememberSoles(leftDodge)

function Poses.sample(action, age, direction)
    action = clips[action] and action or "stance"
    local frames = if direction == -1 and action == "sidestep" then leftDodge else clips[action]
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
