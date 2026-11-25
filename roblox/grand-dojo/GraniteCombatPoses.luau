-- Original movement for Granite's Blender shell. Body offsets are relative
-- to its exported ArtPivots. The match controller owns the arena floor frame.
local Footwork = require(script.Parent.ResidentFootwork)
local Poses = {}
local identity = CFrame.identity
local groupNames = {
    torso = "Torso",
    head = "Head",
    rightArm = "Right Arm",
    leftArm = "Left Arm",
    rightLeg = "Right Leg",
    leftLeg = "Left Leg",
    tail = "Tail",
}

local function offset(x, y, z, pitch, yaw, roll)
    return CFrame.new(x, y, z) * CFrame.Angles(math.rad(pitch), math.rad(yaw), math.rad(roll))
end

local function pose(root, offsets)
    local groups = {}
    for channel, name in groupNames do
        groups[name] = offsets and offsets[channel] or identity
    end
    return {root = root or identity, groups = groups}
end

local ready = pose()
local breathe = pose(nil, {
    torso = offset(0, .045, .035, -3, 0, 0),
    head = offset(0, .045, .015, 2, 0, 0),
    rightArm = offset(.04, .035, .04, 3, -2, 0),
    leftArm = offset(-.02, .035, .06, 3, 3, 0),
    tail = offset(0, .04, .025, 3, -8, 0),
})

local function step(side, lift)
    return pose(offset(.03 * side, 0, 0, 0, 4 * side, 0), {
        torso = offset(.035 * side, .025, -.025, 4, -3 * side, -2 * side),
        head = offset(.035 * side, .01, -.045, -2, 0, -side),
        rightArm = offset(.02, -.035, .10 * side, 4, 0, 1),
        leftArm = offset(-.02, -.02, -.10 * side, 5, 0, -1),
        rightLeg = offset(.035, if side > 0 then lift else 0, -.24 * side, 0, 4, 0),
        leftLeg = offset(-.035, if side < 0 then lift else 0, .24 * side, 0, -4, 0),
        tail = offset(0, .01, .035, 4, -11 * side, 0),
    })
end

local bow = pose(nil, {
    torso = offset(0, -.18, -.08, 14, 0, 0),
    head = offset(0, -.30, -.26, 19, 0, 0),
    rightArm = offset(.04, -.14, .10, 7, -4, 0),
    leftArm = offset(-.025, -.14, .10, 7, 4, 0),
    tail = offset(0, -.075, .075, 8, 0, 0),
})
local shoulderCheck = pose(offset(0, 0, .045, 0, 12, 0), {
    torso = offset(.025, .025, .035, -3, 10, -3),
    head = offset(.035, .025, -.07, 8, -19, -3),
    rightArm = offset(.11, .06, .24, 9, -14, -5),
    leftArm = offset(.21, .27, -.06, 19, -27, -2),
    tail = offset(.04, -.04, .03, 6, -8, 0),
})
local guard = pose(offset(.02, 0, .04, 0, 6, 0), {
    torso = offset(0, -.12, .05, 9, -3, 0),
    head = offset(0, -.14, -.04, 8, -5, 0),
    rightArm = offset(-.13, .005, -.02, 8, 14, -1),
    leftArm = offset(.13, .005, -.07, 9, -16, 1),
    rightLeg = offset(.08, 0, -.12, 0, 5, 0),
    leftLeg = offset(-.07, 0, .10, 0, -5, 0),
    tail = offset(0, -.055, .065, 11, -5, 0),
})

local sweepLoad = pose(offset(.08, 0, .085, 0, -21, 0), {
    torso = offset(.02, -.17, .035, 8, -13, -5),
    head = offset(.04, -.20, -.08, 7, 31, -4),
    rightArm = offset(.08, -.15, .36, 11, -35, -6),
    leftArm = offset(.095, -.08, -.035, 6, -15, -1),
    rightLeg = offset(.09, 0, .28, 0, 5, 0),
    leftLeg = offset(-.11, 0, -.17, 0, -7, 0),
    tail = offset(.03, -.10, .06, 10, 17, 3),
})
local sweepOpen = pose(offset(.05, 0, -.075, 0, -9, 0), {
    torso = offset(.015, -.18, -.045, 11, -5, -3),
    head = offset(.035, -.21, -.16, 9, 13, -3),
    rightArm = offset(.04, -.28, -.24, -14, 4, -4),
    leftArm = offset(.105, -.15, .02, 8, -16, -1),
    rightLeg = offset(.09, 0, .23, 0, 5, 0),
    leftLeg = offset(-.09, 0, -.17, 0, -7, 0),
    tail = offset(.02, -.12, .065, 12, 9, 0),
})
local sweepAcross = pose(offset(-.06, 0, -.21, 0, 11, 0), {
    torso = offset(-.035, -.19, -.10, 14, 12, 7),
    head = offset(-.045, -.23, -.22, 9, -14, 5),
    rightArm = offset(-.15, -.42, -.57, -12, 27, -3),
    leftArm = offset(.095, -.20, .24, 8, -6, -6),
    rightLeg = offset(.08, 0, .35, 0, 10, 0),
    leftLeg = offset(-.11, 0, -.12, 0, -7, 0),
    tail = offset(-.03, -.13, .11, 14, -15, 1),
})
local sweepFinish = pose(offset(-.07, 0, -.24, 0, 23, 0), {
    torso = offset(-.09, -.20, -.115, 14, 18, 11),
    head = offset(-.095, -.25, -.23, 8, -23, 7),
    rightArm = offset(-.28, -.42, -.59, -13, 58, 2),
    leftArm = offset(.045, -.18, .235, 10, 2, -7),
    rightLeg = offset(.05, 0, .34, 0, 11, 0),
    leftLeg = offset(-.10, 0, -.12, 0, -9, 0),
    tail = offset(-.065, -.16, .12, 15, -21, 3),
})
local sweepCatch = pose(offset(-.035, 0, -.09, 0, 9, 0), {
    torso = offset(-.04, -.105, -.045, 8, 5, 6),
    head = offset(-.05, -.12, -.075, 5, -12, 3),
    rightArm = offset(-.085, -.13, .11, 9, 20, -1),
    leftArm = offset(.13, -.10, .07, 7, -12, -2),
    rightLeg = offset(.06, .10, .15, 0, 5, 0),
    leftLeg = offset(-.09, 0, -.11, 0, -6, 0),
    tail = offset(-.03, -.05, .08, 10, -12, 1),
})
local sweepDeflected = pose(offset(.16, 0, -.075, 0, -14, 0), {
    torso = offset(.17, -.08, .15, -8, -15, -8),
    head = offset(.22, -.08, .13, -8, -1, -9),
    rightArm = offset(.20, -.11, .02, -9, -29, -8),
    leftArm = offset(.13, -.16, .20, 4, -10, 1),
    rightLeg = offset(.24, 0, .18, 0, 10, 0),
    leftLeg = offset(-.14, 0, -.18, 0, -8, 0),
    tail = offset(.085, -.055, .055, 9, 19, -5),
})

local stampShift = pose(offset(-.12, 0, .015, 0, -3, 0), {
    torso = offset(-.14, -.10, .02, 4, 0, 7),
    head = offset(-.19, -.13, -.02, 10, 5, 6),
    rightArm = offset(-.035, -.025, .085, 4, -7, 5),
    leftArm = offset(-.065, -.105, .07, 9, -12, 2),
    rightLeg = offset(.045, .10, -.025, 0, 5, 0),
    leftLeg = offset(.045, 0, -.025, 0, -5, 0),
    tail = offset(-.07, -.065, .065, 10, 17, 0),
})
local stampRaise = pose(offset(-.12, 0, 0, 0, -4, 0), {
    torso = offset(-.19, -.10, .055, -3, 1, 9),
    head = offset(-.24, -.135, -.035, 15, 6, 7),
    rightArm = offset(-.095, .03, .17, 4, -13, 8),
    leftArm = offset(-.09, -.08, .09, 8, -9, 4),
    rightLeg = offset(.12, .66, -.28, 0, 5, 0),
    leftLeg = offset(.045, 0, -.025, 0, -5, 0),
    tail = offset(-.075, -.05, .07, 9, 23, -5),
})
local stampContact = pose(offset(.03, 0, -.08, 0, -3, 0), {
    torso = offset(.055, -.28, -.095, 17, 2, -5),
    head = offset(.075, -.34, -.25, 15, 1, -4),
    rightArm = offset(.065, -.29, -.08, 20, 4, -4),
    leftArm = offset(-.08, -.29, .035, 17, -4, 3),
    rightLeg = offset(.12, 0, -.28, 0, 5, 0),
    leftLeg = offset(-.065, 0, .04, 0, -3, 0),
    tail = offset(.06, -.18, .14, 18, -14, 5),
})
local stampSettle = pose(offset(.03, 0, -.03, 0, 1, 0), {
    torso = offset(.025, -.13, -.035, 8, 2, -2),
    head = offset(.035, -.16, -.085, 9, -5, -1),
    rightArm = offset(.07, -.13, .085, 12, 4, -3),
    leftArm = offset(-.09, -.085, .095, 9, -2, 3),
    rightLeg = offset(.095, .07, -.14, 0, 4, 0),
    leftLeg = offset(-.06, 0, .035, 0, -3, 0),
    tail = offset(.03, -.09, .085, 12, -8, 3),
})
local stampDeflected = pose(offset(-.16, 0, .06, 0, 8, 0), {
    torso = offset(-.16, -.12, .08, 4, 9, 13),
    head = offset(-.23, -.18, .045, 7, -6, 15),
    rightArm = offset(.08, -.18, .18, 11, -13, 11),
    leftArm = offset(-.15, -.12, -.06, 14, -7, 6),
    rightLeg = offset(.11, 0, -.23, 0, 7, 0),
    leftLeg = offset(-.15, 0, .12, 0, -7, 0),
    tail = offset(-.04, -.10, .10, 14, 20, -5),
})

local bodyRecoil = pose(offset(0, 0, .14, 0, 4, 0), {
    torso = offset(0, -.25, .06, 14, 2, -3),
    head = offset(.025, -.32, -.09, 15, -4, -2),
    rightArm = offset(-.18, -.26, .055, 11, 17, 3),
    leftArm = offset(.17, -.25, .075, 12, -17, -2),
    rightLeg = offset(.08, 0, .12, 0, 7, 0),
    leftLeg = offset(-.08, 0, -.14, 0, -7, 0),
    tail = offset(0, -.145, .07, 14, 6, 0),
})
local headRecoil = pose(offset(.06, 0, .11, 0, -8, 0), {
    torso = offset(.045, -.07, .12, -7, -8, -5),
    head = offset(.12, -.045, .22, -16, 4, -12),
    rightArm = offset(.025, -.13, .145, 6, 12, -2),
    leftArm = offset(-.02, -.07, .11, 7, -7, 4),
    rightLeg = offset(.07, 0, .13, 0, 7, 0),
    leftLeg = offset(-.08, 0, -.08, 0, -7, 0),
    tail = offset(.055, -.07, .07, 7, -14, -3),
})
local kneel = pose(offset(-.12, 0, .16, 0, 10, 0), {
    torso = offset(-.12, -.57, -.065, 17, 7, 7),
    head = offset(-.18, -.78, -.33, 21, -6, 7),
    rightArm = offset(.10, -.55, -.17, 20, 9, 4),
    leftArm = offset(-.095, -.57, -.23, 15, -11, 4),
    rightLeg = offset(.18, 0, .27, 0, 11, 0),
    leftLeg = offset(-.16, 0, -.26, 0, -11, 0),
    tail = offset(-.07, -.33, .065, 21, 9, -2),
})

local clips = {
    idle = {{0, ready}, {1.18, breathe}, {2.4, ready}},
    step = {{0, ready}, {.17, step(1, .16)}, {.32, step(1, 0)}, {.42, ready},
        {.59, step(-1, .16)}, {.74, step(-1, 0)}, {.84, ready}},
    intro = {{0, ready}, {1.13, breathe}, {1.69, bow}, {2.13, ready}, {4.80, ready},
        {5.20, shoulderCheck}, {5.66, shoulderCheck}, {6.12, stampShift}, {6.50, guard}, {7.06, ready},
        {8.39, breathe}, {9.19, ready}, {10, ready}},
    harborSweep = {{0, ready}, {.30, sweepLoad}, {.78, sweepLoad}, {.855, sweepOpen},
        {.934, sweepAcross}, {1, sweepFinish}},
    sweepRecover = {{0, sweepFinish}, {.06, sweepFinish}, {.25, sweepCatch}, {.64, guard}, {1.15, ready}},
    sweepDeflect = {{0, sweepFinish}, {.10, sweepDeflected}, {.27, sweepDeflected}, {.61, bodyRecoil},
        {1.02, sweepCatch}, {1.71, ready}},
    sweepBlocked = {{0, sweepFinish}, {.105, sweepDeflected}, {.33, sweepCatch}, {.69, guard}, {1.15, ready}},
    breakwaterStamp = {{0, ready}, {.18, stampShift}, {.39, stampRaise}, {1.035, stampRaise}, {1.20, stampContact}},
    stampRecover = {{0, stampContact}, {.11, stampContact}, {.36, stampSettle}, {.84, guard}, {1.42, ready}},
    stampDeflect = {{0, stampContact}, {.13, stampDeflected}, {.33, stampDeflected}, {.69, stampSettle},
        {1.19, guard}, {1.98, ready}},
    stampBlocked = {{0, stampContact}, {.085, stampContact}, {.28, stampDeflected}, {.58, stampSettle},
        {1.02, guard}, {1.42, ready}},
    bodyHit = {{0, ready}, {.08, bodyRecoil}, {.16, bodyRecoil}, {.37, ready}},
    headHit = {{0, ready}, {.079, headRecoil}, {.149, headRecoil}, {.34, ready}},
    knockout = {{0, ready}, {.11, headRecoil}, {.26, bodyRecoil}, {.64, kneel}, {1.30, kneel}},
    win = {{0, ready}, {.29, shoulderCheck}, {.69, shoulderCheck}, {1.04, bow}, {1.64, ready}},
}

local lengths = {}
for action, clip in clips do
    lengths[action] = clip[#clip][1]
end
Poses.Duration = table.freeze(lengths)

-- Sweep samples its moving forefist. Stamp uses the measured center of the
-- sole as the floor pulse origin and takes the configured reach from the bout.
Poses.Attacks = table.freeze({
    ["Harbor Sweep"] = table.freeze({windup = "harborSweep", recover = "sweepRecover",
        blocked = "sweepBlocked", deflect = "sweepDeflect", contactFrom = .78, contactAt = lengths.harborSweep,
        group = "Right Arm", point = Vector3.new(.435, -.2988, -1.3132), radius = .52}),
    ["Breakwater Stamp"] = table.freeze({windup = "breakwaterStamp", recover = "stampRecover",
        blocked = "stampBlocked", deflect = "stampDeflect", contactAt = lengths.breakwaterStamp,
        group = "Right Leg", point = Vector3.new(.14, -1.86, -.328), groundPulse = true}),
})

function Poses.sample(action, age, duration)
    local clip = clips[action]
    if not clip then
        return ready
    end
    local length = lengths[action]
    local playback = math.max(duration or length, .001)
    local elapsed = math.max(age, 0)
    if action == "idle" or action == "step" then
        elapsed %= playback
    end
    local time = length * math.clamp(elapsed / playback, 0, 1)
    for i = 2, #clip do
        local from, to = clip[i - 1], clip[i]
        if time <= to[1] then
            local progress = (time - from[1]) / (to[1] - from[1])
            local weight = progress * progress * (3 - 2 * progress)
            local groups = {}
            for _, name in groupNames do
                groups[name] = from[2].groups[name]:Lerp(to[2].groups[name], weight)
            end
            return {root = from[2].root:Lerp(to[2].root, weight), groups = groups}
        end
    end
    return clip[#clip][2]
end

local function footworkGuard(side, shift, amount)
    local sway = .20 * side * shift
    local back = if side == 0 then amount else 0
    return pose(nil, {
        torso = offset(sway, -.128 * amount, .032 * amount + .085 * back,
            3 * amount - 9 * back, 5 * side * amount, -30 * sway),
        head = offset(.72 * sway, -.102 * amount, -.023 * amount + .08 * back,
            -5 * amount + 5 * back, -5 * side * amount, 23 * sway),
        rightArm = offset(-.06 * amount + .54 * sway, .054 * amount, -.02 * amount, 8 * amount, 6 * amount, -3 * amount),
        leftArm = offset(.066 * amount + .54 * sway, .083 * amount, -.037 * amount, 11 * amount, -7 * amount, 3 * amount),
        tail = offset(-.26 * sway, -.033 * amount, .022 * amount, 5 * amount, -7 * side * amount, 0),
    })
end

Footwork.add(Poses, {
    orbitRadius = 2.70,
    side = {duration = .68, distance = 1.09, transfer = .55, leadLift = .103, trailLift = .079, toeTurn = 5},
    retreat = {duration = .72, distance = .93, transfer = .57, leadLift = .113, trailLift = .087, toeTurn = 4},
    -- Sole centers measured over the lower 0.035 studs of the original GLB boot meshes.
    boots = {
        ["Right Leg"] = {pivot = Vector3.new(.55, 1.86, .063), center = Vector3.new(.690, 0, -.265)},
        ["Left Leg"] = {pivot = Vector3.new(-.55, 1.86, .063), center = Vector3.new(-.690, 0, .055)},
    },
}, footworkGuard)

return Poses
