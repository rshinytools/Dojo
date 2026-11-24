-- Original poses for the rigid Juniper Blender shell. Offsets use the authored
-- floor frame (Y up, -Z forward) and each mesh group's ArtPivot.
local Poses = {}
local IDENTITY = CFrame.identity
local groupNames = {
    torso = "Torso",
    head = "Head",
    rightArm = "Right Arm",
    leftArm = "Left Arm",
    rightLeg = "Right Leg",
    leftLeg = "Left Leg",
}

local function offset(x, y, z, pitch, yaw, roll)
    return CFrame.new(x, y, z) * CFrame.Angles(math.rad(pitch), math.rad(yaw), math.rad(roll))
end

local function pose(root, offsets)
    local groups = {}
    for channel, groupName in groupNames do
        groups[groupName] = offsets and offsets[channel] or IDENTITY
    end
    return {root = root or IDENTITY, groups = groups}
end

local ready = pose()
local breathe = pose(nil, {
    torso = offset(0, .035, .02, 1.5, 0, 0),
    head = offset(.025, .045, .017, 0, -1.5, -1.5),
    rightArm = offset(0, .035, .015, 2.5, 0, 0),
    leftArm = offset(0, .035, .015, 2.5, 0, 0),
})

local function step(lead, lift)
    local direction = if lead then 1 else -1
    return pose(offset(.04 * direction, 0, 0, 0, 3 * direction, 0), {
        torso = offset(0, .02, 0, 3, 0, 0),
        head = offset(0, .025, 0, -3, 0, 0),
        rightArm = offset(0, 0, -.065 * direction, 1, 0, 0),
        leftArm = offset(0, 0, .065 * direction, 1, 0, 0),
        rightLeg = offset(0, if lead then lift else 0, -.28 * direction, 0, 0, 0),
        leftLeg = offset(0, if lead then 0 else lift, .28 * direction, 0, 0, 0),
    })
end

-- One guarded, step-together cycle covers 1.152 studs at 2.4 studs/second.
-- The fitted boot translations offset each hip swing to keep the planted sole in place.
local footworkDuration = .48
-- A lateral shuffle follows an arc at Juniper's 3.13-stud guard distance.
local sideReach = {{.063, .010, -.065, 7}, {.123, -.008, -.153, 14}}
local retreatReach = {
    {.100, .077, -.107, -.002, 7},
    {.195, .124, -.223, -.033, 14},
}

local function shuffleStep(side, width, leadLift, followLift, balance)
    local x, y, z, roll = table.unpack(sideReach[width])
    local weight = side * balance
    local rightLift = if side > 0 then leadLift else followLift
    local leftLift = if side < 0 then leadLift else followLift
    return pose(nil, {
        torso = offset(.095 * weight, -.065, .024, 3, 3 * weight, -4 * weight),
        head = offset(.062 * weight, -.047, .025, -2, -3 * weight, 2 * weight),
        rightArm = offset(-.048 + .035 * weight, -.052, .032, 4, 7, -3 * weight),
        leftArm = offset(.048 + .035 * weight, -.052, .032, 4, -7, -3 * weight),
        rightLeg = offset(x, y + rightLift, z, 0, 0, roll),
        leftLeg = offset(-x, y + leftLift, z, 0, 0, -roll),
    })
end

local function shuffleClip(side)
    return {{0, ready}, {.12, shuffleStep(side, 1, .13, 0, -1)},
        {.24, shuffleStep(side, 2, 0, 0, .4)}, {.36, shuffleStep(side, 1, 0, .12, 1)},
        {footworkDuration, ready}}
end

local function retreatStep(width, backLift, frontLift, weight)
    local backZ, backY, frontZ, frontY, pitch = table.unpack(retreatReach[width])
    return pose(nil, {
        torso = offset(.038 * weight, -.078, .025 + .065 * weight, 5, -3, -3 * weight),
        head = offset(.02 * weight, -.060, .040 + .044 * weight, -4, 3, 2 * weight),
        rightArm = offset(-.049, -.055, .031, 7, 7, -1),
        leftArm = offset(.06, -.048, .052, 5, -7, 1),
        rightLeg = offset(0, backY + backLift, backZ, -pitch, 0, 0),
        leftLeg = offset(0, frontY + frontLift, frontZ, pitch, 0, 0),
    })
end

local bow = pose(nil, {
    torso = offset(0, -.17, -.06, -11, 0, 0),
    head = offset(0, -.22, -.12, -20, 0, 0),
    rightArm = offset(-.06, -.12, .03, -16, 8, 0),
    leftArm = offset(.06, -.12, .03, -16, -8, 0),
})
local salute = pose(offset(0, 0, .03, 0, -16, 0), {
    torso = offset(0, .02, 0, 1, -6, 0),
    head = offset(0, .035, 0, 0, 15, -5),
    rightArm = offset(-.08, -.11, .13, -11, 5, 2),
    leftArm = offset(.02, .12, -.18, 44, 5, 10),
})
local nod = pose(salute.root, {
    torso = salute.groups.Torso,
    head = offset(.03, -.035, -.05, -12, 15, -5),
    rightArm = salute.groups["Right Arm"],
    leftArm = offset(.05, .16, -.23, 53, 8, 13),
})

local shellSet = pose(offset(0, 0, .14, 0, 0, 0), {
    torso = offset(0, -.28, .02, -10, 0, 0),
    head = offset(0, -.51, .22, -25, 0, 0),
    rightArm = offset(-.13, -.26, .24, 10, 18, -3),
    leftArm = offset(.13, -.26, .24, 10, -18, 3),
    rightLeg = offset(.06, 0, .02, 0, -8, 0),
    leftLeg = offset(-.06, 0, -.12, 0, 8, 0),
})

local palmLoad = pose(offset(0, 0, .12, 0, -13, 0), {
    torso = offset(0, -.15, .06, 8, -8, 0),
    head = offset(0, -.13, -.01, -8, 12, 0),
    rightArm = offset(.07, -.14, .46, 7, -18, 4),
    leftArm = offset(.04, -.10, -.07, 12, -9, 0),
    rightLeg = offset(.04, 0, .20, 0, -9, 0),
    leftLeg = offset(-.05, 0, -.18, 0, 0, 0),
})
local palmDrive = pose(offset(0, 0, -.33, 0, 10, 0), {
    torso = offset(0, -.10, -.08, -9, 5, 0),
    head = offset(0, -.12, -.07, -7, -4, 0),
    rightArm = offset(-.11, -.03, -.34, -4, 13, 0),
    leftArm = offset(-.02, -.08, .13, 7, -5, 0),
    rightLeg = offset(.02, 0, .31, 0, -5, 0),
    leftLeg = offset(-.04, .13, -.33, 0, 2, 0),
})
local palmContact = pose(offset(-.04, 0, -1.18, 0, 13, 0), {
    torso = offset(0, -.17, -.10, -13, 8, 0),
    head = offset(0, -.15, -.13, -8, -9, 1),
    rightArm = offset(-.15, -.11, -.86, -3, 17, 0),
    leftArm = offset(-.03, -.18, .22, 4, -5, 4),
    rightLeg = offset(.02, 0, .61, 0, -7, 0),
    leftLeg = offset(-.04, 0, -.41, 0, 2, 0),
})
local palmTuck = pose(offset(0, 0, -.33, 0, 4, 0), {
    torso = offset(0, -.15, -.03, -5, 5, 0),
    head = offset(0, -.09, -.05, 0, -7, 0),
    rightArm = offset(-.09, -.16, .06, 6, 10, 3),
    leftArm = offset(0, -.14, .16, 6, -6, 0),
    leftLeg = offset(-.01, .08, -.13, 0, 0, 0),
    rightLeg = offset(.01, 0, .23, 0, -1, 0),
})
local parried = pose(offset(.15, 0, -.42, 0, -6, 0), {
    torso = offset(.13, -.20, .10, 12, -13, 9),
    head = offset(.13, -.10, .15, 16, -14, 10),
    rightArm = offset(.18, .15, -.18, 37, -26, 12),
    leftArm = offset(.03, -.16, .17, -13, -14, -5),
    rightLeg = offset(.08, 0, .32, 0, -12, 0),
    leftLeg = offset(-.08, 0, -.26, 0, 12, 0),
})

local bodyRecoil = pose(offset(0, 0, .16, 0, 0, 0), {
    torso = offset(0, -.28, .10, -18, 0, 0),
    head = offset(0, -.24, -.10, -12, 0, 0),
    rightArm = offset(-.10, -.33, .12, -10, 12, 0),
    leftArm = offset(.10, -.33, .12, -10, -12, 0),
})
local headRecoil = pose(offset(.04, 0, .14, 0, 0, 0), {
    torso = offset(0, -.13, .08, 6, -4, 0),
    head = offset(.14, -.06, .24, 22, -15, 10),
    rightArm = offset(-.07, -.13, .03, 4, 7, 0),
    leftArm = offset(.05, -.13, .03, 4, -7, 0),
})
local down = pose(offset(.16, 0, .26, 0, 11, 0), {
    torso = offset(0, -.70, -.07, -21, 0, 9),
    head = offset(.04, -.81, -.13, -29, -2, 10),
    rightArm = offset(-.09, -.67, -.19, -15, 10, 2),
    leftArm = offset(.08, -.65, -.23, -14, -10, -4),
    rightLeg = offset(.14, 0, .31, 0, -13, 0),
    leftLeg = offset(-.13, 0, -.21, 0, 13, 0),
})

local clips = {
    idle = {{0, ready}, {1.35, breathe}, {2.7, ready}},
    step = {{0, ready}, {.18, step(true, .20)}, {.34, step(true, 0)},
        {.52, step(false, .20)}, {.70, step(false, 0)}, {.80, ready}},
    strafeLeft = shuffleClip(-1),
    strafeRight = shuffleClip(1),
    retreat = {{0, ready}, {.12, retreatStep(1, .14, 0, 0)},
        {.24, retreatStep(2, 0, 0, 1)}, {.36, retreatStep(1, 0, .12, .6)},
        {footworkDuration, ready}},
    intro = {{0, ready}, {1.0, breathe}, {1.55, bow}, {1.95, bow}, {2.55, ready},
        {4.75, breathe}, {5.45, salute}, {6.05, salute}, {6.33, nod}, {6.65, salute},
        {7.6, ready}, {8.15, step(true, .08)}, {8.95, ready}, {10, ready}},
    brace = {{0, ready}, {.20, shellSet}, {.56, shellSet}, {.80, ready}},
    palm = {{0, ready}, {.27, palmLoad}, {.68, palmLoad}, {.81, palmDrive}, {.95, palmContact}},
    recover = {{0, palmContact}, {.075, palmContact}, {.38, palmTuck}, {.82, ready}, {1.10, ready}},
    deflect = {{0, palmContact}, {.105, parried}, {.28, parried}, {.57, bodyRecoil}, {1.10, ready}},
    blocked = {{0, shellSet}, {.085, bodyRecoil}, {.22, shellSet}, {.29, ready}},
    bodyHit = {{0, ready}, {.085, bodyRecoil}, {.15, bodyRecoil}, {.38, ready}},
    headHit = {{0, ready}, {.078, headRecoil}, {.15, headRecoil}, {.36, ready}},
    knockout = {{0, ready}, {.12, headRecoil}, {.27, bodyRecoil}, {.66, down}, {1.3, down}},
    win = {{0, ready}, {.37, salute}, {.72, nod}, {1.15, salute}, {1.55, ready}},
}

Poses.Duration = {}
for action, clip in clips do
    Poses.Duration[action] = clip[#clip][1]
end

local looping = {idle = true, step = true, strafeLeft = true, strafeRight = true, retreat = true}

-- Forward knuckle vertex measured on the authored Right_Arm_Shell mesh
-- in its right ArtPivot frame. This is the visible contact at the end of palm.
Poses.PalmContact = Vector3.new(.0763, -.1595, -1.4299)

function Poses.sample(action, age, duration)
    local clip = clips[action]
    if not clip then
        return ready
    end
    local length = Poses.Duration[action]
    local playbackDuration = math.max(duration or length, .001)
    local elapsed = math.max(age, 0)
    if looping[action] then
        elapsed %= playbackDuration
    end
    local time = length * math.clamp(elapsed / playbackDuration, 0, 1)
    for i = 2, #clip do
        local from, to = clip[i - 1], clip[i]
        if time <= to[1] then
            local weight = (time - from[1]) / (to[1] - from[1])
            local result = {root = from[2].root:Lerp(to[2].root, weight), groups = {}}
            for _, name in groupNames do
                result.groups[name] = from[2].groups[name]:Lerp(to[2].groups[name], weight)
            end
            return result
        end
    end
    return clip[#clip][2]
end

return Poses
