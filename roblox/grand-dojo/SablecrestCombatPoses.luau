-- Original poses for the Wind Court courier. The body groups pivot at the
-- shipped GLB's ArtPivots. The motion controller owns all floor travel.
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
    torso = offset(0, .035, -.02, 2, -2, 0),
    head = offset(0, .04, -.035, -2, 3, -2),
    rightArm = offset(-.035, .055, .075, -3, 3, 0),
    leftArm = offset(.03, .02, .01, 2, -3, 0),
    tail = offset(.015, .02, 0, -3, 14, 2),
})

local function step(side, lift)
    return pose(offset(.045 * side, 0, 0, 0, 0, 0), {
        torso = offset(.03 * side, .045, -.035, 4, -3 * side, -3 * side),
        head = offset(.045 * side, .05, -.10, -2, 3 * side, -2 * side),
        rightArm = offset(-.045, .045, .12 * side, -1, 5, 2),
        leftArm = offset(.045, .03, -.13 * side, 2, -8, -2),
        rightLeg = offset(.025, if side > 0 then lift else 0, -.27 * side, 0, 1, 0),
        leftLeg = offset(-.025, if side < 0 then lift else 0, .27 * side, 0, -1, 0),
        tail = offset(0, .025, .04, 1, -19 * side, 5 * side),
    })
end

local listen = pose(nil, {
    torso = offset(.035, 0, .02, -2, 7, -2),
    head = offset(.065, .03, .025, -4, 25, 11),
    rightArm = offset(-.08, .025, .08, -3, 6, 0),
    leftArm = offset(.11, .065, .055, -5, -13, -4),
    tail = offset(.025, .035, 0, -2, -18, -5),
})
local bow = pose(nil, {
    torso = offset(0, -.12, -.095, 13, 0, 0),
    head = offset(.025, -.24, -.29, 20, -3, -2),
    rightArm = offset(-.022, -.14, .09, 4, 13, 3),
    leftArm = offset(.045, -.12, .13, 5, -7, -3),
    tail = offset(0, -.07, .03, 9, 3, 2),
})
local salute = pose(offset(0, 0, 0, 0, -7, 0), {
    torso = offset(.045, .015, .03, -1, -6, -3),
    head = offset(.055, .045, -.04, -5, 9, -5),
    rightArm = offset(-.095, .095, .24, -2, 11, -1),
    leftArm = offset(.12, .28, .085, 12, -22, -2),
    tail = offset(.02, .05, .015, -7, 12, -2),
})
local guard = pose(offset(.025, 0, .035, 0, -5, 0), {
    torso = offset(.035, -.075, -.015, 5, -3, -3),
    head = offset(.035, -.10, -.085, 5, 6, -3),
    rightArm = offset(-.10, -.025, -.02, 4, 13, 1),
    leftArm = offset(.12, .035, -.015, 6, -14, -1),
    rightLeg = offset(.035, 0, -.08, 0, 0, 0),
    leftLeg = offset(-.025, 0, .055, 0, -4, 0),
    tail = offset(.025, -.05, .06, 8, -13, 0),
})

local shift = pose(offset(-.06, 0, .015, 0, 6, 0), {
    torso = offset(-.09, -.09, -.115, 5, -13, 7),
    head = offset(-.14, -.12, -.12, 5, 9, 8),
    leftArm = offset(-.035, -.08, -.11, 5, -12, 7),
    rightArm = offset(-.04, -.15, .18, 7, 10, -3),
    leftLeg = offset(-.06, 0, -.03, 0, -7, 0),
    rightLeg = offset(.08, .11, .06, 0, 5, 0),
    tail = offset(-.04, -.04, .05, 9, 18, 5),
})
local cross = pose(offset(.025, 0, -.005, 0, 14, 0), {
    torso = offset(.14, -.12, .01, 6, 13, -11),
    head = offset(.25, -.13, -.075, 3, -19, -8),
    leftArm = offset(.12, -.13, .08, 6, -5, -4),
    rightArm = offset(.075, -.13, -.10, 7, 5, -5),
    leftLeg = offset(-.48, 0, -.04, 0, -6, 0),
    rightLeg = offset(.29, .19, -.055, 0, 9, 0),
    tail = offset(.005, -.045, .05, 9, -26, -8),
})
local plant = pose(offset(0, 0, 0, 0, 9, 0), {
    torso = offset(.07, -.13, -.01, 4, 13, -6),
    head = offset(.13, -.17, -.075, 1, -18, -4),
    leftArm = offset(.07, -.14, .17, 4, -5, -2),
    rightArm = offset(.035, -.14, -.08, 7, 11, -3),
    leftLeg = offset(-.29, 0, .13, 0, -3, 0),
    rightLeg = offset(.18, 0, -.23, 0, 7, 0),
    tail = offset(.045, -.07, .065, 7, -21, -3),
})
local returnCoil = pose(offset(.02, 0, .08, 0, 16, 0), {
    torso = offset(.045, -.16, .07, 1, 15, -6),
    head = offset(.07, -.17, .035, 2, -26, -4),
    leftArm = offset(.02, -.20, .34, 0, -6, -2),
    rightArm = offset(-.11, -.075, -.055, 4, 12, -2),
    leftLeg = offset(-.21, 0, .18, 0, -3, 0),
    rightLeg = offset(.13, 0, -.22, 0, 6, 0),
    tail = offset(.025, -.09, .08, 6, -23, -2),
})
local returnDrive = pose(offset(-.025, 0, -.105, 0, 2, 0), {
    torso = offset(-.04, -.16, -.10, 10, -5, 4),
    head = offset(-.08, -.225, -.18, 6, 0, 5),
    leftArm = offset(.055, -.275, -.19, -1, -16, 3),
    rightArm = offset(-.10, -.15, .16, 7, 6, -2),
    leftLeg = offset(-.095, .16, -.10, 0, -5, 0),
    rightLeg = offset(.13, 0, .24, 0, 3, 0),
    tail = offset(-.025, -.12, .12, 11, 15, 3),
})
local returnContact = pose(offset(.015, 0, -.18, 0, -8, 0), {
    torso = offset(-.07, -.18, -.13, 14, -14, 5),
    head = offset(-.12, -.235, -.25, 6, 10, 3),
    leftArm = offset(.135, -.37, -.44, -6, -26, 1),
    rightArm = offset(-.055, -.17, .215, 6, 8, 0),
    leftLeg = offset(-.11, 0, -.35, 0, -5, 0),
    rightLeg = offset(.12, 0, .31, 0, 5, 0),
    tail = offset(-.07, -.13, .16, 11, 21, 4),
})
local returnCatch = pose(offset(.025, 0, -.11, 0, -6, 0), {
    torso = offset(-.045, -.12, -.075, 7, -6, 2),
    head = offset(-.085, -.16, -.16, 4, 7, 2),
    leftArm = offset(.095, -.16, -.07, 3, -12, 2),
    rightArm = offset(-.075, -.095, .08, 7, 9, -1),
    leftLeg = offset(-.065, 0, -.16, 0, -4, 0),
    rightLeg = offset(.075, .09, .095, 0, 3, 0),
    tail = offset(-.06, -.07, .10, 8, 16, 4),
})
local returnDeflected = pose(offset(-.14, 0, -.055, 0, 14, 0), {
    torso = offset(-.14, -.08, .13, -10, 8, 7),
    head = offset(-.21, -.09, .16, -7, -15, 12),
    leftArm = offset(-.09, -.235, -.13, -6, 22, 8),
    rightArm = offset(-.12, -.12, .19, 10, 2, -5),
    leftLeg = offset(-.19, 0, -.22, 0, -10, 0),
    rightLeg = offset(.11, 0, .18, 0, 6, 0),
    tail = offset(-.065, -.075, .025, 4, 26, 8),
})

local jabLoad = pose(offset(-.025, 0, .06, 0, -10, 0), {
    torso = offset(-.04, -.055, .015, 2, -5, 3),
    head = offset(-.085, -.07, 0, 2, 14, 5),
    rightArm = offset(-.02, -.09, .29, 4, 6, 1),
    leftArm = offset(.13, .025, -.06, 5, -12, -1),
    leftLeg = offset(-.06, 0, .08, 0, -5, 0),
    rightLeg = offset(.045, 0, -.09, 0, 6, 0),
    tail = offset(-.02, -.02, .055, 2, 15, 1),
})
local jabContact = pose(offset(-.05, 0, -.44, 0, 8, 0), {
    torso = offset(.035, -.085, -.065, 8, 10, -3),
    head = offset(.06, -.145, -.16, 4, -14, -2),
    rightArm = offset(-.045, -.295, -.35, -5, 23, -1),
    leftArm = offset(.085, -.07, .13, 5, -7, -2),
    rightLeg = offset(.055, 0, -.10, 0, 5, 0),
    leftLeg = offset(-.065, 0, .36, 0, -4, 0),
    tail = offset(.02, -.065, .095, 6, -19, -4),
})
local jabBack = pose(offset(-.02, 0, -.12, 0, 4, 0), {
    torso = offset(.03, -.045, -.04, 5, 3, -2),
    head = offset(.035, -.09, -.085, 2, -8, -1),
    rightArm = offset(-.10, -.105, .09, 3, 6, -3),
    leftArm = offset(.10, -.065, -.02, 4, -8, 0),
    rightLeg = offset(.055, .08, -.03, 0, 5, 0),
    leftLeg = offset(-.04, 0, .10, 0, -3, 0),
    tail = offset(.025, -.05, .03, 4, -13, -3),
})
local jabDeflected = pose(offset(.10, 0, -.16, 0, -14, 0), {
    torso = offset(.085, -.065, .12, -8, -9, -8),
    head = offset(.17, -.055, .16, -6, 8, -10),
    rightArm = offset(.20, -.22, -.085, -7, -17, -5),
    leftArm = offset(.12, -.055, .13, 7, -10, 3),
    rightLeg = offset(.14, 0, -.08, 0, 8, 0),
    leftLeg = offset(-.12, 0, .26, 0, -5, 0),
    tail = offset(.085, -.06, .035, 5, -23, -8),
})

local bodyRecoil = pose(offset(.035, 0, .12, 0, 6, 0), {
    torso = offset(.015, -.21, .07, 12, 5, -3),
    head = offset(.06, -.29, -.10, 13, -5, -3),
    rightArm = offset(-.13, -.23, .065, 6, 17, -3),
    leftArm = offset(.10, -.18, .085, 7, -15, -2),
    rightLeg = offset(.06, 0, .11, 0, 6, 0),
    leftLeg = offset(-.08, 0, -.17, 0, -7, 0),
    tail = offset(.01, -.16, .06, 9, 12, -2),
})
local headRecoil = pose(offset(-.025, 0, .095, 0, -6, 0), {
    torso = offset(-.075, -.055, .07, -5, -4, 6),
    head = offset(-.16, -.01, .19, -15, -12, 12),
    rightArm = offset(-.07, -.09, .13, 3, 8, -2),
    leftArm = offset(.04, -.055, .12, 4, -11, 4),
    rightLeg = offset(.045, 0, .10, 0, 4, 0),
    leftLeg = offset(-.055, 0, -.05, 0, -6, 0),
    tail = offset(-.045, -.04, .055, 5, -14, 6),
})
local kneel = pose(offset(.045, 0, .19, 0, -12, 0), {
    torso = offset(-.06, -.49, -.075, 18, -8, -6),
    head = offset(-.12, -.70, -.32, 24, 4, -5),
    leftArm = offset(.06, -.45, -.25, 12, -11, 0),
    rightArm = offset(.015, -.44, .10, 13, 5, 2),
    rightLeg = offset(.12, 0, .19, 0, 10, 0),
    leftLeg = offset(-.16, 0, -.29, 0, -12, 0),
    tail = offset(-.055, -.28, .08, 15, 11, -3),
})

local crossstepStart, crossstepPlant = .08, .31
local returnDriveStart = .51
local clips = {
    idle = {{0, ready}, {.78, breathe}, {1.60, ready}},
    step = {{0, ready}, {.105, step(1, .175)}, {.21, step(1, 0)}, {.29, ready},
        {.395, step(-1, .175)}, {.50, step(-1, 0)}, {.58, ready}},
    intro = {{0, ready}, {.95, listen}, {1.30, listen}, {1.70, bow}, {2.14, ready}, {4.76, ready},
        {5.22, listen}, {5.57, salute}, {6.02, salute}, {6.39, guard}, {7.03, ready}, {8.44, breathe},
        {9.22, ready}, {10, ready}},
    crossstep = {{0, ready}, {crossstepStart, shift}, {.192, cross}, {crossstepPlant, plant}, {.39, plant}},
    windReturn = {{0, plant}, {.20, returnCoil}, {returnDriveStart, returnCoil}, {.628, returnDrive}, {.72, returnContact}},
    returnRecover = {{0, returnContact}, {.045, returnContact}, {.198, returnCatch}, {.52, guard}, {1.06, ready}},
    returnDeflect = {{0, returnContact}, {.090, returnDeflected}, {.236, returnDeflected}, {.46, bodyRecoil},
        {.87, returnCatch}, {1.62, ready}},
    returnBlocked = {{0, returnContact}, {.087, returnDeflected}, {.248, returnCatch}, {.63, guard}, {1.06, ready}},
    windJab = {{0, ready}, {.19, jabLoad}, {.46, jabLoad}, {.65, jabContact}},
    jabRecover = {{0, jabContact}, {.047, jabContact}, {.17, jabBack}, {.44, guard}, {.82, ready}},
    jabDeflect = {{0, jabContact}, {.069, jabDeflected}, {.20, jabDeflected}, {.435, bodyRecoil},
        {.73, jabBack}, {1.38, ready}},
    jabBlocked = {{0, jabContact}, {.083, jabDeflected}, {.21, jabBack}, {.46, guard}, {.82, ready}},
    bodyHit = {{0, ready}, {.077, bodyRecoil}, {.148, bodyRecoil}, {.32, ready}},
    headHit = {{0, ready}, {.066, headRecoil}, {.123, headRecoil}, {.29, ready}},
    knockout = {{0, ready}, {.09, headRecoil}, {.26, bodyRecoil}, {.54, kneel}, {1.30, kneel}},
    win = {{0, ready}, {.22, guard}, {.54, salute}, {.84, salute}, {1.20, bow}, {1.64, ready}},
}

local lengths = {}
for action, clip in clips do
    lengths[action] = clip[#clip][1]
end
Poses.Duration = table.freeze(lengths)

local function smoothstep(t)
    return t * t * (3 - 2 * t)
end

local function progress(action, age, duration, start, finish)
    local length = lengths[action]
    local time = length * math.clamp(age / math.max(duration or length, .001), 0, 1)
    return smoothstep(math.clamp((time - start) / (finish - start), 0, 1))
end

-- The crossstep travels to the right of the server's approach frame. It
-- completes as the lead foot plants, before the locked attack lane appears.
local function crossstepProgress(age, duration)
    return progress("crossstep", age, duration, crossstepStart, crossstepPlant)
end

local function returnProgress(age, duration)
    return progress("windReturn", age, duration, returnDriveStart, lengths.windReturn)
end

-- The strike points were measured at the center of the leading glove pads
-- in the GLB's arm-local frames. Apply the posed ArtPivot before hit testing.
Poses.Attacks = table.freeze({
    ["Wind Court Return"] = table.freeze({setup = "crossstep", setupProgress = crossstepProgress,
        windup = "windReturn", recover = "returnRecover", deflect = "returnDeflect", blocked = "returnBlocked",
        contactAt = lengths.windReturn, group = "Left Arm", point = Vector3.new(-.294, .06, -1.176),
        radius = .42, travelProgress = returnProgress, maxTravel = 2.45}),
    ["Wind Jab"] = table.freeze({windup = "windJab", recover = "jabRecover", deflect = "jabDeflect",
        blocked = "jabBlocked", contactAt = lengths.windJab, group = "Right Arm",
        point = Vector3.new(.294, .06, -1.336), radius = .36}),
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
            local weight = smoothstep((time - from[1]) / (to[1] - from[1]))
            local groups = {}
            for _, name in groupNames do
                groups[name] = from[2].groups[name]:Lerp(to[2].groups[name], weight)
            end
            return {root = from[2].root:Lerp(to[2].root, weight), groups = groups}
        end
    end
    return clip[#clip][2]
end

return Poses
