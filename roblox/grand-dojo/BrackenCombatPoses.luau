-- Original movement for Bracken's rigid Blender shell. The root is a visual
-- offset from the server-owned floor frame. Body groups use their ArtPivots.
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
    torso = offset(0, .04, .025, 2, 0, 0),
    head = offset(0, .03, -.025, -2, 2, 0),
    rightArm = offset(.03, .03, .055, 3, 1, 1),
    leftArm = offset(-.03, .025, .055, 3, -1, -1),
    tail = offset(0, .035, 0, -4, 8, 0),
})

local function step(right, lift)
    local side = if right then 1 else -1
    return pose(offset(.045 * side, 0, 0, 0, 4 * side, 0), {
        torso = offset(.025 * side, .015, -.025, 3, 0, -2 * side),
        head = offset(0, .02, -.01, -2, -3 * side, side),
        rightArm = offset(.015, -.02, .08 * side, 3, 0, 0),
        leftArm = offset(-.015, -.02, -.08 * side, 3, 0, 0),
        rightLeg = offset(.015, if right then lift else 0, -.27 * side, 0, 1, 0),
        leftLeg = offset(-.015, if right then 0 else lift, .27 * side, 0, -1, 0),
        tail = offset(0, -.01, .015, 4, -10 * side, 0),
    })
end

local bow = pose(nil, {
    torso = offset(0, -.15, -.045, 11, 0, 0),
    head = offset(0, -.29, -.22, 19, 0, 0),
    rightArm = offset(.05, -.08, .075, 4, 0, 0),
    leftArm = offset(-.05, -.09, .075, 4, 0, 0),
    tail = offset(0, -.06, .025, 7, 0, 0),
})
local salute = pose(offset(.04, 0, .02, 0, 10, 0), {
    torso = offset(0, .045, 0, -3, 2, 0),
    head = offset(0, .055, -.025, -6, -8, -2),
    rightArm = offset(-.07, .07, .02, -9, 46, 8),
    leftArm = offset(-.065, -.06, .09, 3, -7, -4),
    tail = offset(0, .04, 0, -9, -8, 0),
})
local brace = pose(offset(.03, 0, .06, 0, 3, 0), {
    torso = offset(0, -.13, .055, 8, 0, 0),
    head = offset(0, -.20, -.06, 8, 0, 0),
    rightArm = offset(-.10, -.04, .07, -7, 17, 3),
    leftArm = offset(.10, -.04, .07, -7, -17, -3),
    rightLeg = offset(.02, 0, .09, 0, 2, 0),
    leftLeg = offset(-.02, 0, -.12, 0, -2, 0),
    tail = offset(0, -.07, .04, 7, -6, 0),
})

local scrape = pose(offset(.09, 0, .085, 0, 12, 0), {
    torso = offset(.02, -.18, .075, 12, 6, -4),
    head = offset(.01, -.27, -.10, 10, -16, 1),
    rightArm = offset(-.04, -.19, .17, 6, 11, 6),
    leftArm = offset(.04, -.15, -.05, 4, -8, 0),
    rightLeg = offset(.06, .16, .35, 1, 2, 0),
    leftLeg = offset(-.01, 0, -.14, 0, -4, 0),
    tail = offset(0, -.10, .035, 9, -13, 0),
})
local stomp = pose(offset(.035, 0, 0, 0, 7, 0), {
    torso = offset(0, -.13, -.055, 10, 3, -2),
    head = offset(0, -.25, -.16, 8, -9, 0),
    rightArm = offset(-.02, -.17, -.10, 4, 8, 3),
    leftArm = offset(.045, -.15, .08, 3, -9, -1),
    rightLeg = offset(.035, 0, -.27, 0, 3, 0),
    leftLeg = offset(-.03, 0, .16, 0, -5, 0),
    tail = offset(0, -.10, -.03, 11, -8, 0),
})
local rushCoil = pose(offset(-.06, 0, .13, 0, 13, 0), {
    torso = offset(-.025, -.22, .06, 16, 6, 4),
    head = offset(-.05, -.32, -.10, 16, -18, 3),
    rightArm = offset(.06, -.19, .24, 8, 11, 1),
    leftArm = offset(.045, -.27, .28, 2, -6, -4),
    rightLeg = offset(.055, 0, .26, 0, 5, 0),
    leftLeg = offset(-.07, 0, -.23, 0, -5, 0),
    tail = offset(0, -.18, .11, 16, -12, 0),
})
local rushDrive = pose(offset(.04, 0, -.11, 0, -11, 0), {
    torso = offset(-.04, -.21, -.13, 16, -8, 6),
    head = offset(-.045, -.35, -.08, 11, 3, 6),
    rightArm = offset(.04, -.20, .39, 1, 7, 3),
    leftArm = offset(.07, -.28, -.1, 2, -14, -3),
    rightLeg = offset(.02, .13, .20, 0, 5, 0),
    leftLeg = offset(-.05, 0, -.32, 0, -5, 0),
    tail = offset(0, -.15, .13, 12, 13, 0),
})
local rushContact = pose(offset(.10, 0, -.32, 0, -24, 0), {
    torso = offset(-.08, -.23, -.17, 20, -9, 7),
    head = offset(-.07, -.37, -.09, 17, 9, 9),
    rightArm = offset(.04, -.22, .45, 4, 6, 7),
    leftArm = offset(.09, -.32, -.23, 4, -20, -5),
    rightLeg = offset(.07, 0, .42, 0, 6, 0),
    leftLeg = offset(-.09, 0, -.27, 0, -8, 0),
    tail = offset(.04, -.20, .16, 15, 16, 0),
})
local rushCatch = pose(offset(.11, 0, -.19, 0, -14, 0), {
    torso = offset(-.04, -.21, -.12, 14, -4, -3),
    head = offset(-.03, -.30, -.04, 8, 10, 4),
    rightArm = offset(.04, -.16, .19, 1, 7, 5),
    leftArm = offset(.035, -.14, .12, -2, -9, -3),
    rightLeg = offset(.035, .12, .16, 0, 4, 0),
    leftLeg = offset(-.09, 0, -.19, 0, -8, 0),
    tail = offset(.015, -.11, .11, 9, 10, 0),
})
local rushRebound = pose(offset(-.10, 0, .18, 0, -8, 0), {
    torso = offset(-.13, -.20, .16, -9, -9, -10),
    head = offset(-.18, -.20, .16, -6, -4, -10),
    rightArm = offset(.085, -.21, .13, 8, 14, -1),
    leftArm = offset(-.10, -.22, .26, 5, -20, -11),
    rightLeg = offset(.13, 0, .21, 0, 8, 0),
    leftLeg = offset(-.09, 0, -.25, 0, -8, 0),
    tail = offset(-.04, -.10, -.02, 10, 14, 0),
})

local jabLoad = pose(offset(.08, 0, .10, 0, -13, 0), {
    torso = offset(.025, -.09, .04, 3, -8, -4),
    head = offset(.045, -.14, -.04, 5, 14, 3),
    rightArm = offset(.05, -.16, .37, 11, 4, -2),
    leftArm = offset(.015, -.035, .055, -1, -14, 0),
    rightLeg = offset(.04, 0, .13, 0, 4, 0),
    leftLeg = offset(-.03, 0, -.15, 0, -4, 0),
    tail = offset(0, -.07, .01, 5, 13, 0),
})
local jabContact = pose(offset(-.13, 0, -.72, 0, 16, 0), {
    torso = offset(.015, -.11, -.075, 11, 5, -5),
    head = offset(0, -.20, -.09, 6, -13, 1),
    rightArm = offset(-.19, -.31, -.58, 5, 14, -1),
    leftArm = offset(-.06, -.08, .14, -2, -10, -5),
    rightLeg = offset(.06, 0, .46, 0, -5, 0),
    leftLeg = offset(-.04, 0, -.12, 0, 3, 0),
    tail = offset(-.025, -.09, .12, 12, -14, 0),
})
local jabRetract = pose(offset(-.045, 0, -.19, 0, 6, 0), {
    torso = offset(0, -.12, -.015, 5, 2, -3),
    head = offset(0, -.16, -.04, 4, -7, 2),
    rightArm = offset(-.07, -.14, .04, 2, 13, 3),
    leftArm = offset(-.02, -.06, .105, 2, -10, -1),
    rightLeg = offset(.025, .09, .19, 0, 0, 0),
    leftLeg = offset(-.025, 0, -.10, 0, -4, 0),
    tail = offset(-.04, -.12, .06, 8, -7, 0),
})
local jabDeflected = pose(offset(.11, 0, -.29, 0, -8, 0), {
    torso = offset(.14, -.14, .13, -11, -10, 9),
    head = offset(.18, -.12, .17, -7, -9, 9),
    rightArm = offset(.22, -.12, -.09, -10, -32, 0),
    leftArm = offset(.01, -.10, .15, 5, -8, -3),
    rightLeg = offset(.07, 0, .33, 0, 4, 0),
    leftLeg = offset(-.11, 0, -.19, 0, -9, 0),
    tail = offset(.06, -.11, .035, 5, 18, 0),
})

local bodyRecoil = pose(offset(0, 0, .15, 0, 3, 0), {
    torso = offset(0, -.23, .10, 14, 3, -2),
    head = offset(0, -.30, -.10, 16, -3, 0),
    rightArm = offset(-.14, -.25, .045, 6, 16, 3),
    leftArm = offset(.14, -.25, .045, 6, -16, -3),
    rightLeg = offset(.04, 0, .12, 0, 4, 0),
    leftLeg = offset(-.04, 0, -.16, 0, -5, 0),
    tail = offset(0, -.14, .035, 13, -9, 0),
})
local headRecoil = pose(offset(.05, 0, .13, 0, -5, 0), {
    torso = offset(.035, -.07, .12, -7, -3, 4),
    head = offset(.14, -.03, .25, -16, -13, 11),
    rightArm = offset(.02, -.12, .11, 5, 11, 5),
    leftArm = offset(-.03, -.095, .06, 4, -6, -4),
    rightLeg = offset(.04, 0, .095, 0, 4, 0),
    leftLeg = offset(-.06, 0, .025, 0, -5, 0),
    tail = offset(0, -.05, .07, 6, 15, 0),
})
local kneel = pose(offset(-.14, 0, .27, 0, -11, 0), {
    torso = offset(-.10, -.62, -.12, 15, -6, -9),
    head = offset(-.145, -.80, -.33, 19, -3, -12),
    rightArm = offset(.14, -.52, -.14, 17, 8, 10),
    leftArm = offset(-.10, -.62, -.32, 16, -7, -12),
    rightLeg = offset(.22, 0, .29, 0, 17, 0),
    leftLeg = offset(-.20, .055, -.35, 0, -17, 0),
    tail = offset(-.09, -.40, -.02, 22, 7, 0),
})

local rushDriveStart = .63
local clips = {
    idle = {{0, ready}, {1.04, breathe}, {2.08, ready}},
    step = {{0, ready}, {.14, step(true, .16)}, {.28, step(true, 0)}, {.36, ready},
        {.50, step(false, .16)}, {.64, step(false, 0)}, {.72, ready}},
    intro = {{0, ready}, {1.12, breathe}, {1.63, bow}, {2.08, ready}, {4.82, ready},
        {5.18, salute}, {5.52, salute}, {5.93, brace}, {6.40, stomp}, {7.05, ready},
        {8.34, breathe}, {9.12, ready}, {10, ready}},
    bellowsStep = {{0, ready}, {.13, scrape}, {.29, stomp}, {.39, stomp}},
    rush = {{0, stomp}, {.22, rushCoil}, {rushDriveStart, rushCoil}, {.77, rushDrive}, {.90, rushContact}},
    rushRecover = {{0, rushContact}, {.095, rushContact}, {.25, rushCatch}, {.66, brace}, {1.25, ready}},
    rushDeflect = {{0, rushContact}, {.10, rushRebound}, {.27, rushRebound}, {.62, bodyRecoil}, {1.65, ready}},
    rushBlocked = {{0, rushContact}, {.14, rushRebound}, {.34, rushCatch}, {.74, brace}, {1.25, ready}},
    jab = {{0, ready}, {.24, jabLoad}, {.56, jabLoad}, {.73, jabContact}},
    jabRecover = {{0, jabContact}, {.068, jabContact}, {.235, jabRetract}, {.58, brace}, {.90, ready}},
    jabDeflect = {{0, jabContact}, {.09, jabDeflected}, {.23, jabDeflected}, {.51, bodyRecoil}, {1.30, ready}},
    jabBlocked = {{0, jabContact}, {.092, jabDeflected}, {.22, jabRetract}, {.48, brace}, {.90, ready}},
    bodyHit = {{0, ready}, {.091, bodyRecoil}, {.15, bodyRecoil}, {.36, ready}},
    headHit = {{0, ready}, {.073, headRecoil}, {.14, headRecoil}, {.34, ready}},
    knockout = {{0, ready}, {.12, headRecoil}, {.29, bodyRecoil}, {.62, kneel}, {1.30, kneel}},
    win = {{0, ready}, {.29, salute}, {.57, salute}, {.81, brace}, {1.12, breathe}, {1.64, ready}},
}

local lengths = {}
for action, clip in clips do
    lengths[action] = clip[#clip][1]
end
Poses.Duration = table.freeze(lengths)

-- Scale by safe travel measured along the locked attack lane. The motion
-- controller keeps the final floor position on recovery.
function Poses.rushProgress(age, duration)
    local length = lengths.rush
    local time = length * math.clamp(age / math.max(duration or length, .001), 0, 1)
    local drive = math.clamp((time - rushDriveStart) / (length - rushDriveStart), 0, 1)
    return drive * drive * (3 - 2 * drive)
end

-- Points are measured from the front plates of the shipped GLB gloves, in
-- each strike group's ArtPivot coordinates. Map them through the authored pose
-- and the current floor frame before testing a player's swept contact volume.
Poses.Attacks = table.freeze({
    ["Kiln Rush"] = table.freeze({setup = "bellowsStep", windup = "rush", recover = "rushRecover",
        deflect = "rushDeflect", blocked = "rushBlocked", contactAt = lengths.rush, group = "Left Arm",
        point = Vector3.new(-.1736, -.1621, -1.4411), radius = .55, travelProgress = Poses.rushProgress}),
    ["Kiln Jab"] = table.freeze({windup = "jab", recover = "jabRecover", deflect = "jabDeflect",
        blocked = "jabBlocked", contactAt = lengths.jab, group = "Right Arm",
        point = Vector3.new(.1864, -.0121, -1.5311), radius = .38}),
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
            local stepFraction = (time - from[1]) / (to[1] - from[1])
            local weight = stepFraction * stepFraction * (3 - 2 * stepFraction)
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
    local sway = .14 * side * shift
    local back = if side == 0 then amount else 0
    return pose(nil, {
        torso = offset(sway, -.108 * amount, -.055 * amount + .11 * back,
            9 * amount - 12 * back, 5 * side * amount, -32 * sway),
        head = offset(.65 * sway, -.072 * amount, -.065 * amount + .09 * back,
            -4 * amount + 6 * back, -5 * side * amount, 21 * sway),
        rightArm = offset(-.06 * amount + .4 * sway, .012 * amount, -.028 * amount, 7 * amount, 8 * amount, -3 * amount),
        leftArm = offset(.06 * amount + .4 * sway, .032 * amount, -.064 * amount, 9 * amount, -8 * amount, 3 * amount),
        tail = offset(0, -.025 * amount, .015 * amount, 6 * amount, -10 * side * amount, 0),
    })
end

Footwork.add(Poses, {
    orbitRadius = 3.02,
    side = {duration = .52, distance = 1.14, transfer = .49, leadLift = .168, trailLift = .118, toeTurn = 9},
    retreat = {duration = .60, distance = 1.02, transfer = .51, leadLift = .132, trailLift = .106, toeTurn = 6},
    -- Sole centers measured over the lower 0.035 studs of the original GLB boot meshes.
    boots = {
        ["Right Leg"] = {pivot = Vector3.new(.51, 1.83, .07), center = Vector3.new(.587, 0, -.27323)},
        ["Left Leg"] = {pivot = Vector3.new(-.51, 1.83, .12), center = Vector3.new(-.587, 0, .01677)},
    },
}, footworkGuard)

return Poses
