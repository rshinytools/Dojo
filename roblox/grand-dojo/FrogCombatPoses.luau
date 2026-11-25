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

-- The native boot ellipsoids extend just below the old sampled sole points.
-- Lift each planted stance foot to clear the deck for these grounded clips.
local groundedReady = table.clone(ready)
local plantedRight = CFrame.new(0, .012, 0) * ready.RootJoint * ready["Right Hip"]
local plantedLeft = CFrame.new(0, .022, 0) * ready.RootJoint * ready["Left Hip"]
groundedReady["Right Hip"] = ready.RootJoint:ToObjectSpace(plantedRight)
groundedReady["Left Hip"] = ready.RootJoint:ToObjectSpace(plantedLeft)

-- The palm turns over two planted feet. The heel keeps weight on the right
-- foot while the left foot rises, rolls heel-first, and returns to its mark.
local mudLoad = pose({.095, -.31, .08, -12, -30, -6}, {30, 6, -12, .025, .10, .20},
    {62, -19, 18, .02, .12, .075}, rearFoot, frontFoot, {8, 25, 4})
local mudHit = pose({.045, -.29, -.29, -14, 24, -5}, {61, 16, -14, .015, .035, -.11},
    {64, -21, 21, .015, .18, .10}, rearFoot, frontFoot, {10, -21, 4})
local mudFold = pose({.055, -.26, -.065, -11, 9, -4}, {56, 17, -11, 0, .09, -.035},
    leftGuard, rearFoot, frontFoot, {8, -8, 3})

local mountedLeftHip = leftHip + Vector3.yAxis * (2.60 - 2.132)
local function heelPose(core, right, left, swing, head)
    local offsets = pose(core, right, left, rearFoot, frontFoot, head)
    offsets["Left Hip"] = around(mountedLeftHip, swing)
    return offsets
end

local heelLoad = heelPose({.11, -.29, .06, -11, -9, -9}, {56, 18, -13, -.03, .15, .08},
    {58, -19, 16, .10, .08, .10}, {17, 11, -7, -.04, .162, .055}, {9, 7, 5})
local heelLift = heelPose({.16, -.25, .095, -6, -7, -13}, {63, 21, -13, -.02, .13, .12},
    {48, -17, 23, .025, .10, .14}, {53, 13, -11, -.13, .13, .10}, {6, 7, 9})
local heelCoil = heelPose({.17, -.19, .215, -1, 7, -12}, {65, 19, -14, -.045, .12, .08},
    {36, -12, 25, -.035, .11, .09}, {84, 14, -13, -.11, .12, .035}, {1, -9, 8})
local heelHit = heelPose({.14, -.12, -.49, -10, -10, -11}, {64, 20, -16, -.06, .15, .08},
    {27, -13, 29, -.075, .08, -.03}, {126, 7, 9, .025, .035, -.34}, {8, 12, 7})
local heelFollow = heelPose({.145, -.17, -.235, -9, -6, -10}, {58, 20, -14, -.04, .15, .065},
    {32, -15, 26, -.055, .08, .02}, {120, 6, 7, .035, .025, -.15}, {7, 7, 7})
local heelFold = heelPose({.14, -.26, .015, -9, -7, -11}, {53, 19, -12, -.035, .15, .08},
    {50, -13, 20, -.03, .10, .10}, {60, 12, -10, -.10, .14, .035}, {8, 7, 7})
local heelSettle = heelPose({.055, -.23, -.02, -9, -13, -3}, rightGuard,
    leftGuard, {13, 8, -2, -.09, .218, -.12}, {7, 10, 2})

-- The front toe ellipsoids set the lowest point of the right boot.
local loadoutRight = CFrame.new(0, .027, 0) * plantedRight
local loadoutReady = table.clone(groundedReady)
loadoutReady["Right Hip"] = ready.RootJoint:ToObjectSpace(loadoutRight)

local tapDraw = pose({0, -.20, 0, -6, -5, 2}, {52, 20, -11, -.03, .14, .10},
    {43, -6, 12, .035, .08, .14}, rearFoot, frontFoot, {5, 4, -2})
local tapHit = pose({0, -.22, 0, -8, -24, 3}, {55, 21, -14, -.02, .16, .09},
    {73, -22, 13, .035, .09, -.175}, rearFoot, frontFoot, {7, 19, -2})
local tapFold = pose({0, -.18, 0, -7, -14, 2}, rightGuard,
    {68, -17, 14, .035, .085, -.04}, rearFoot, frontFoot, {6, 12, -2})

local mountedRightHip = rightHip + Vector3.yAxis * (2.60 - 2.132)
local function bankPose(core, right, left, swing, head)
    local offsets = pose(core, right, left, rearFoot, frontFoot, head)
    offsets["Right Hip"] = offsets.RootJoint:ToObjectSpace(around(mountedRightHip, swing) * loadoutRight)
    return offsets
end

local bankLoad = bankPose({0, -.245, 0, -4, -23, 6}, {49, 22, -15, -.03, .14, .15},
    {64, -14, 16, .045, .11, .06}, {3, 4, 0, -.025, .075, .05}, {6, 19, -4})
local bankChamber = bankPose({0, -.20, 0, 1, -19, 9}, {52, 24, -18, -.03, .13, .13},
    {62, -14, 17, .05, .13, .025}, {11, 10, -4, -.01, .26, .065}, {3, 16, -5})
local bankHit = bankPose({0, -.15, 0, 4, -9, 7}, {55, 24, -15, -.035, .16, .15},
    {60, -18, 19, .05, .13, -.025}, {22, 17, -7, -.08, .13, -.49}, {0, 7, -4})
local bankTuck = bankPose({0, -.19, 0, 0, -12, 5}, {52, 22, -13, -.03, .15, .12},
    {64, -15, 16, .045, .12, .015}, {12, 9, -4, -.04, .20, -.125}, {3, 10, -3})
local bankPlant = bankPose({0, -.20, 0, -6, -15, 3}, rightGuard,
    leftGuard, {3, 3, 0, -.01, .09, .005}, {5, 13, -2})

local crashCrouch = pose({0, -.35, 0, -13, -10, 2}, {65, 24, -20, -.05, .19, .09},
    {71, -19, 21, .045, .18, .06}, rearFoot, frontFoot, {10, 9, -2})
local crashRaise = pose({0, -.035, 0, 4, -5, 1}, rightGuard, leftGuard, rearFoot, frontFoot, {-4, 4, -2})
local mountedShoulderLift = Vector3.yAxis * (2.60 - 2.132)
crashRaise["Right Shoulder"] = around(rightShoulder + mountedShoulderLift, {147, 13, -22, .05, .085, .18})
crashRaise["Left Shoulder"] = around(leftShoulder + mountedShoulderLift, {145, -14, 22, -.05, .085, .17})
local crashDrop = pose({0, -.29, 0, -10, -3, 1}, {110, 24, -18, -.09, .09, -.05},
    {109, -24, 18, .09, .09, -.05}, rearFoot, frontFoot, {8, 3, -1})
local crashHit = pose({0, -.39, 0, -19, 0, 0}, {79, 51, -13, -.14, .08, -.40},
    {79, -51, 13, .14, .08, -.40}, rearFoot, frontFoot, {13})
local crashFold = pose({0, -.33, 0, -15, -3, 1}, {72, 24, -20, -.06, .06, -.12},
    {73, -22, 21, .06, .06, -.12}, rearFoot, frontFoot, {10, 3, -1})
local crashRecover = pose({0, -.21, 0, -8, -11, 2}, {58, 22, -13, -.03, .12, .065},
    {65, -16, 18, .045, .12, .035}, rearFoot, frontFoot, {7, 9, -2})

local marshDraw = pose({0, -.305, 0, -10, 14, 7}, {59, 24, -19, -.045, .18, .10},
    {26, -3, 14, .01, .045, .17}, rearFoot, frontFoot, {8, -10, -4})
local marshLow = pose({0, -.39, 0, -14, -29, 5}, {58, 22, -17, -.03, .17, .12},
    {54, -23, 14, .025, .025, -.26}, rearFoot, frontFoot, {11, 24, -4})
local marshSwitch = pose({0, -.28, 0, -11, -22, -2}, {31, 4, -13, -.025, .055, .155},
    {61, -19, 18, .035, .10, .025}, rearFoot, frontFoot, {9, 19, 1})
local marshCoil = pose({0, -.25, 0, -8, -32, -8}, {38, 8, -13, -.03, .075, .18},
    {67, -19, 20, .04, .11, .10}, rearFoot, frontFoot, {8, 26, 5})
local marshHigh = pose({0, -.135, 0, -9, 31, -6}, {81, 21, -11, -.015, .13, -.33},
    {61, -18, 18, .035, .12, .13}, rearFoot, frontFoot, {6, -25, 4})
local marshFold = pose({0, -.20, 0, -12, 33, -5}, {71, 23, -14, -.045, .15, -.16},
    {64, -16, 17, .035, .13, .085}, rearFoot, frontFoot, {9, -26, 3})
local marshRecover = pose({0, -.18, 0, -7, 2, 0}, {57, 20, -14, -.03, .15, .025},
    leftGuard, rearFoot, frontFoot, {6, -2, -1})

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
    lilyVault = .34, mudPalm = .23, pondboundHeel = .48, tadpoleTornado = .53,
    pondTap = .16, bankKick = .24, lilyCrash = .62, marshBarrage = table.freeze({.30, .64})})
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
    mudPalm = {{0, groundedReady}, {.10, mudLoad}, {contact.mudPalm, mudHit}, {.35, mudFold}, {.58, groundedReady}},
    pondboundHeel = {{0, groundedReady}, {.13, heelLoad}, {.255, heelLift}, {.354, heelCoil},
        {contact.pondboundHeel, heelHit}, {.55, heelFollow}, {.67, heelFold}, {.79, heelSettle}, {.91, groundedReady}},
    pondTap = {{0, loadoutReady}, {.061, tapDraw}, {contact.pondTap, tapHit}, {.25, tapFold}, {.40, loadoutReady}},
    bankKick = {{0, loadoutReady}, {.08, bankLoad}, {.15, bankChamber}, {contact.bankKick, bankHit},
        {.32, bankTuck}, {.42, bankPlant}, {.51, loadoutReady}},
    lilyCrash = {{0, loadoutReady}, {.151, crashCrouch}, {.33, crashRaise}, {.415, crashRaise},
        {.52, crashDrop}, {contact.lilyCrash, crashHit}, {.69, crashHit}, {.80, crashFold},
        {1.01, crashRecover}, {1.24, loadoutReady}},
    marshBarrage = {{0, loadoutReady}, {.14, marshDraw}, {contact.marshBarrage[1], marshLow}, {.411, marshSwitch},
        {.503, marshCoil}, {contact.marshBarrage[2], marshHigh}, {.754, marshFold}, {.925, marshRecover},
        {1.15, loadoutReady}},
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
-- The pads are on the existing native shell: the right hand's knuckle
-- ellipsoid and the rear of the left webbed foot, relative to the mounted root.
local mudPalmPad = Vector3.new(1.112025884, -.389241579, -.603075659)
local pondboundHeelPad = Vector3.new(-.434351223, -2.080000000, -.085192073)
local tapPad = Vector3.new(-1.361480214, -.349928068, -.507478986)
local bankToe = Vector3.new(.240231107, -2.039362318, -.794673049)
local crashRightPad = Vector3.new(1.240491354, -.382440214, -.580941602)
local crashLeftPad = Vector3.new(-1.240491354, -.382440214, -.580941602)
local marshLowPad = Vector3.new(-1.375324058, -.309931507, -.536141217)
local marshHighPad = Vector3.new(1.366682581, -.348366705, -.493731118)
local tornadoCenter = Vector3.new(0, floorY, 0)
Poses.Impact = table.freeze({
    jab = table.freeze({point(jabHit, "Left Shoulder", leftFist)}),
    cross = table.freeze({point(crossHit, "Right Shoulder", rightFist)}),
    body = table.freeze({point(bodyHit, "Left Shoulder", leftFist)}),
    heavy = table.freeze({point(heavyHit, "Right Shoulder", rightFist)}),
    lilyVault = table.freeze({vaultToes}),
    mudPalm = table.freeze({point(mudHit, "Right Shoulder", mudPalmPad)}),
    pondboundHeel = table.freeze({point(heelHit, "Left Hip", pondboundHeelPad)}),
    tadpoleTornado = table.freeze({tornadoCenter}),
    pondTap = table.freeze({point(tapHit, "Left Shoulder", tapPad)}),
    bankKick = table.freeze({point(bankHit, "Right Hip", bankToe)}),
    lilyCrash = table.freeze({point(crashHit, "Right Shoulder", crashRightPad)
        :Lerp(point(crashHit, "Left Shoulder", crashLeftPad), .5)}),
    marshBarrage = table.freeze({
        point(marshLow, "Left Shoulder", marshLowPad), point(marshHigh, "Right Shoulder", marshHighPad),
    }),
})

Poses.Skill = table.freeze({
    pondTap = table.freeze({damage = 11, radius = .43}),
    bankKick = table.freeze({damage = 14, radius = .47, foot = true}),
    lilyVault = table.freeze({damage = 20, radius = .48, shove = .56}),
    tadpoleTornado = table.freeze({center = tornadoCenter, radius = 3.2, warningAt = .18,
        deflectFrom = .36, deflectUntil = .69, damage = 28, shove = .94}),
})
Poses.UltimateSkill = table.freeze({
    lilyCrash = table.freeze({damage = 31, radius = .48}),
    marshBarrage = table.freeze({damage = table.freeze({12, 21}), radius = table.freeze({.45, .47})}),
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
    local isPalm, isHeel = action == "mudPalm", action == "pondboundHeel"
    local isBank = action == "bankKick"
    local bothPlanted = action == "pondTap" or action == "lilyCrash" or action == "marshBarrage"
    local result = {RootJoint = root}
    for name, previous in before[2] do
        if name ~= "RootJoint" then
            local following = after[2][name]
            local offset = previous:Lerp(following, weight)
            local solePoints = feet[name]
            if isBank and name == "Right Hip" then
                local beforeBoot, afterBoot = before[2].RootJoint * previous, after[2].RootJoint * following
                offset = root:ToObjectSpace(beforeBoot:Lerp(afterBoot, weight))
            elseif solePoints and not (bothPlanted or isPalm or isHeel or isBank) then
                local oldY, newY = soleHeights[before[2]][name], soleHeights[after[2]][name]
                local shift = oldY + (newY - oldY) * weight - lowest(root * offset, solePoints)
                offset = CFrame.new(root:VectorToObjectSpace(Vector3.new(0, shift, 0))) * offset
            end
            result[name] = offset
        end
    end
    if bothPlanted then
        result["Right Hip"] = root:ToObjectSpace(loadoutRight)
    elseif isPalm or isHeel then
        result["Right Hip"] = root:ToObjectSpace(plantedRight)
    end
    if bothPlanted or isPalm or isBank then
        result["Left Hip"] = root:ToObjectSpace(plantedLeft)
    end
    return result
end

Choreography.addShuffle(Poses, rightSole, leftSole, 2.60)
return table.freeze(Poses)
