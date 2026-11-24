-- Original combat poses for the floor-aligned Fire Salamander shell.
-- Offsets multiply restC0 from the left. Forward in the pose frame is -Z.
local Poses = {}

local neck = Vector3.new(0, .830, -.090)
local rightShoulder = Vector3.new(.680, .620, .025)
local leftShoulder = Vector3.new(-.680, .620, .025)
local tail = Vector3.new(0, -.900, .340)
local floorY = -2.575

local rightBoot = Vector3.new(.548, -2.600, -.431)
local leftBoot = Vector3.new(-.548, -2.600, -.151)
local rightSole = {
	Vector3.new(.547, -2.543, -.848), Vector3.new(.375, -2.600, -.774),
	Vector3.new(.786, -2.600, -.731), Vector3.new(.312, -2.600, -.169),
	Vector3.new(.723, -2.600, -.126),
}
local leftSole = {
	Vector3.new(-.547, -2.543, -.568), Vector3.new(-.375, -2.600, -.494),
	Vector3.new(-.786, -2.600, -.451), Vector3.new(-.312, -2.600, .111),
	Vector3.new(-.723, -2.600, .154),
}

local function rotation(pitch, yaw, roll)
	return CFrame.Angles(math.rad(pitch), math.rad(yaw or 0), math.rad(roll or 0))
end

local function around(pivot, pitch, yaw, roll, lift, depth)
	return CFrame.new(pivot + Vector3.new(0, lift or 0, depth or 0))
		* rotation(pitch, yaw, roll) * CFrame.new(-pivot)
end

local function foot(boot, sole, pitch, yaw, lift, depth, stride)
	local orientation = around(boot, pitch, yaw, 0, 0, depth)
	local low = math.huge
	for _, point in sole do
		low = math.min(low, orientation:PointToWorldSpace(point).Y)
	end
	return CFrame.new(stride or 0, floorY + lift - low, 0) * orientation
end

-- Author feet in the floor frame so the short steps stay under the body
-- while the tail and torso turn. The sampler fits them to the moving hips.
-- Feet specify each boot's pitch, lift, yaw, fore-aft step and side step.
local function pose(core, right, left, feet, head, tailMotion)
	return {
		RootJoint = CFrame.new(core[1], core[2], core[3]) * rotation(core[4], core[5], core[6]),
		Neck = around(neck, table.unpack(head)),
		["Right Shoulder"] = around(rightShoulder, table.unpack(right)),
		["Left Shoulder"] = around(leftShoulder, table.unpack(left)),
		["Right Hip"] = foot(rightBoot, rightSole, feet[1], feet[5], feet[3], feet[7], feet[9]),
		["Left Hip"] = foot(leftBoot, leftSole, feet[2], feet[6], feet[4], feet[8], feet[10]),
		TailJoint = around(tail, table.unpack(tailMotion)),
	}
end

local rightGuard = {39, 14, -15, .025, .07}
local leftGuard = {27, -13, 17, .03, .13}
local planted = {0, 0, 0, 0, 2, -7}
local ready = pose({.015, -.08, -.035, -5, -12, -3}, rightGuard, leftGuard, planted, {6, 11, 2}, {-8, 13, 1})
local breathe = pose({.01, -.045, -.01, -3, -11, -2}, {42, 14, -16, .03, .085}, {28, -15, 17, .025, .13},
	planted, {4, 10, 1}, {-9, 10, 1})
local cover = pose({-.035, -.21, .09, -10, -7, 1}, {54, 25, -24, .075, .13}, {48, -27, 23, .055, .16},
	planted, {9, 7, -1}, {-7, 16, -2})
local guardRecoil = pose({-.075, -.22, .16, -5, -12, 6}, {52, 29, -27, .07, .17}, {51, -23, 25, .065, .14},
	planted, {3, 12, -3}, {-11, 13, -1})
local parryReady = pose({-.025, -.15, .015, -6, -11, 2}, {47, 22, -22, .045, .095}, {39, -23, 23, .04, .145},
	planted, {6, 11, -2}, {-8, 13, 2})
local parryWhisk = pose({-.092, -.12, -.02, -5, 16, 9}, {41, 15, -19, .055, .13}, {36, 8, 31, .035, .025},
	{0, 0, 0, 0, 5, -12}, {5, -15, -4}, {-8, -24, 2})

local jabLoad = pose({.04, -.11, .05, -6, -21, -4}, {28, 9, -11, .005, .12}, leftGuard,
	planted, {6, 19, 3}, {-8, 18, 1})
local jabContact = pose({.04, -.05, -.22, -10, 22, -3}, {42, 25, -17, .05, -.16}, {27, -17, 17, .035, .18},
	{0, 0, 0, 0, 6, -8}, {9, -20, 2}, {-9, -16, -1})
local jabReturn = pose({.025, -.08, -.08, -7, 3, -2}, {40, 19, -17, .035, -.035}, leftGuard,
	planted, {7, -2, 1}, {-8, -1, 1})
local crossLoad = pose({-.05, -.12, .035, -6, 14, 6}, rightGuard, {14, -2, 9, 0, .15},
	planted, {7, -13, -4}, {-8, -15, 3})
local crossContact = pose({-.045, -.07, -.275, -13, -32, 4}, {39, 17, -18, .045, .14}, {38, -22, 19, .055, -.19},
	{0, 0, 0, 0, 7, -18}, {12, 24, -3}, {-10, 17, -3})
local crossReturn = pose({-.035, -.105, -.09, -8, -19, 2}, rightGuard, {32, -18, 18, .035, -.015},
	planted, {7, 17, -1}, {-8, 12, 1})
local bodyLoad = pose({.075, -.23, .055, -12, -19, -8}, {6, 6, -8, -.055, .10}, {36, -14, 19, .04, .11},
	planted, {11, 18, 5}, {-9, 19, 1})
local bodyContact = pose({.065, -.25, -.27, -16, 27, -4}, {19, 24, -13, -.035, -.22}, {37, -15, 19, .05, .15},
	{0, 0, 0, 0, 10, -10}, {13, -22, 2}, {-12, -19, -3})
local bodyReturn = pose({.04, -.19, -.12, -10, 11, -2}, {24, 15, -15, .01, -.09}, leftGuard,
	planted, {9, -10, 2}, {-9, -7, 1})
local heavyLoad = pose({-.095, -.23, .10, -6, 34, 9}, {44, 18, -20, .045, .10}, {3, 12, 12, -.05, .20},
	{0, 0, 0, 0, 7, -14}, {6, -27, -5}, {-9, -24, 4})
local heavyDrive = pose({-.055, -.15, -.03, -11, 6, 6}, {48, 22, -24, .05, .10}, {18, -6, 14, -.015, .025},
	{0, 0, 0, 0, 9, -16}, {10, -5, -4}, {-10, -8})
local heavyContact = pose({-.07, -.06, -.38, -14, -36, 6}, {41, 24, -20, .05, .19}, {39, -24, 21, .025, -.31},
	{0, 0, 0, 0, 9, -17}, {12, 26, -4}, {-10, 27, -1})
local heavyFollow = pose({-.095, -.125, -.265, -13, -47, 8}, {36, 25, -22, .065, .18}, {40, -32, 23, .03, -.18},
	{0, 0, 0, 0, 8, -13}, {10, 32, -5}, {-10, 30, -2})

local sweepLoad = pose({-.055, -.24, .04, -5, 23, 6}, {29, 22, -14, .045, .12}, {37, -15, 21, .04, .16},
	{0, 4, 0, .045, 13, 16, 0, .08, -.08, .04}, {5, -24, -3}, {-7, -18, -3})
local sweepPivot = pose({.035, -.24, -.075, -3, 86, -3}, {25, 16, -31, .02, .14}, {37, -11, 33, .03, .16},
	{0, 12, 0, .13, 72, 70, -.04, .53, -.55, .33}, {4, -35, 2}, {-2, 38, 1})
local sweepContact = pose({.045, -.24, -.12, -1, 119, -3}, {28, 23, -28, .01, .145}, {30, -15, 30, .025, .13},
	{0, 13, 0, .145, 99, 106, -.04, .53, -.55, .67}, {3, -42, 3}, {-2, 61, 1})
local sweepFollow = pose({.035, -.235, -.085, -1, 150, 3}, {36, 20, -25, .025, .12}, {29, -15, 31, .025, .13},
	{0, 7, 0, .07, 133, 134, -.04, .39, -.55, .95}, {0, -44, -2}, {-1, 52, -1})
local sweepCatch = pose({-.035, -.17, -.018, -4, 211, 6}, {35, 14, -23, .025, .09}, {31, -13, 24, .03, .11},
	{11, 0, .15, 0, 203, 193, .50, -.03, -.92, .97}, {4, 38, -3}, {-4, 13, -3})
local sweepSettle = pose({-.02, -.105, .01, -5, 288, 4}, rightGuard, leftGuard,
	{0, 2, 0, .11, 286, 283, .68, -.19, -.42, .34}, {6, 25, -3}, {-6, 4, -1})
local sweepForward = pose({.005, -.095, -.015, -6, 332, -1}, rightGuard, leftGuard,
	{5, 0, .05, 0, 340, 336, .325, .015, -.10, 0}, {6, 18}, {-8, 11, 1})

local advanceRight = pose({.085, -.075, -.08, -9, -14, -5}, {33, 13, -13, .02, .08}, leftGuard,
	{-7, 3, .14, 0, 4, -9, -.26, .13}, {8, 13, 3}, {-9, 17, 2})
local advanceLeft = pose({-.065, -.08, -.075, -9, -9, 3}, rightGuard, {25, -14, 15, .025, .12},
	{3, -7, 0, .14, 4, -8, .13, -.26}, {8, 8, -2}, {-9, 3, -1})
local backRight = pose({.07, -.11, .04, 2, -14, -4}, {40, 16, -15, .03, .11}, leftGuard,
	{9, -4, .115, 0, 5, -9, .23, -.105}, {-1, 13, 3}, {-13, 16, 3})
local backLeft = pose({-.055, -.115, .045, 1, -9, 3}, rightGuard, {27, -16, 17, .04, .13},
	{-4, 9, 0, .115, 5, -8, -.105, .23}, {-1, 8, -2}, {-13, 6, -1})
local dodgeRight = pose({.15, -.235, .02, -11, -29, -13}, {28, 2, -9, .015, .12}, {35, -17, 25, .04, .165},
	{3, 1, .11, 0, 24, -1, .05, .015}, {10, 21, 7}, {-10, 28, 3})
local dodgeRightCatch = pose({.13, -.17, -.015, -12, 3, -5}, rightGuard, {32, -18, 22, .04, .16},
	{0, 2, 0, .06, 10, -5}, {10, -4, 4}, {-9, -14, -1})
local dodgeLeft = pose({-.15, -.235, .025, -11, 10, 12}, {42, 18, -23, .045, .09}, {17, -2, 14, 0, .17},
	{1, 3, 0, .12, 3, -34, .02, .055}, {10, -9, -7}, {-10, -19, -3})
local dodgeLeftCatch = pose({-.125, -.17, -.02, -12, -22, 6}, {41, 19, -20, .04, .11}, leftGuard,
	{2, 0, .06, 0, 4, -15}, {10, 18, -4}, {-9, 12, 2})

local trailCrouch = pose({.01, -.19, -.035, -12, -19, 4}, {22, 14, -14, .02, .08}, {34, -20, 19, .045, .14},
	planted, {11, 13, -2}, {-10, 13, 3})
local trailCutLeft = pose({-.11, -.16, -.025, -13, 52, 12}, {31, 11, -19, .045, .085}, {12, -2, 12, .02, .12},
	{4, -9, 0, .16, 43, 52, .42, -.28, -.23, .21}, {8, -8, -6}, {-10, -24, -3})
local trailMarkLeft = pose({-.115, -.235, -.04, -12, 39, 11}, {32, 16, -23, .045, .10}, {17, -6, 16, -.03, .04},
	{1, 0, .08, 0, 53, 36, .31, -.225, -.24, .10}, {9, -9, -6}, {-5, -35, -2})
local trailBend = pose({.025, -.09, -.03, -16, -58, -7}, {15, 3, -13, .015, .10}, {40, -17, 17, .05, .08},
	{-7, 4, .13, 0, -46, -54, .48, -.26, -.16, .14}, {12, 7, 5}, {-8, 25, 3})
local trailMarkRight = pose({.115, -.23, -.035, -12, -107, -9}, {18, 6, -17, -.025, .05}, {39, -16, 22, .045, .16},
	{0, 4, 0, .13, -92, -99, .81, -.30, -.40, .52}, {9, 17, 5}, {-8, 29, 2})
local trailBank = pose({.11, -.16, .015, -10, -175, -10}, {26, 13, -18, .015, .075}, {32, -16, 20, .035, .13},
	{-7, 3, .13, 0, -160, -162, .62, -.21, -.91, 1.03}, {7, 22, 5}, {-12, 24, 1})
local trailBrake = pose({.03, -.165, .025, -5, -236, -4}, {38, 18, -19, .03, .10}, {35, -19, 22, .04, .13},
	{3, -1, 0, .10, -220, -226, .27, .52, -.82, .88}, {4, -13, 3}, {-12, 17, 1})
local trailFace = pose({.015, -.105, -.025, -7, -315, -3}, rightGuard, leftGuard,
	{0, 0, .075, 0, -302, -310, -.13, .37, -.11, .17}, {7, -28, 2}, {-7, -12, 1})

local headHit = pose({.08, -.115, .155, 10, 6, -9}, {25, 9, -11, 0, .10}, {18, -6, 12, .03, .14},
	planted, {6, 14, -5}, {-19, -5, 1})
local bodyHit = pose({-.065, -.285, .13, -22, -12, 8}, {47, 21, -23, .04, .15}, {42, -19, 21, .045, .155},
	planted, {13, 10, -6}, {-12, 14, 2})
local stagger = pose({.12, -.225, .255, 13, 19, -13}, {18, 7, -5, .015, .14}, {18, -9, 16, .02, .18},
	{2, 7, 0, .105, 11, -13, .015, .19}, {8, -8, -6}, {-25, 0, 1})
local drop = pose({.145, -.54, .25, 18, 20, -14}, {12, 2, -4, 0, .06}, {15, -6, 13, .015, .15},
	{3, 7, 0, 0, 12, -18, -.10, .22}, {4, -9, -4}, {-27, -7, 4})
local sit = pose({.15, -.925, .295, 28, 16, -18}, {7, 2, 3, -.08, -.08}, {16, -9, 14, -.04, .08},
	{7, 13, 0, 0, 16, -23, -.19, .27}, {4, -5, -6}, {-44, -3, 4})

local traceLeft = pose({-.035, -.13, -.055, -11, -3, 5}, {28, 23, -23, .045, -.01}, {43, -24, 26, .035, .10},
	planted, {-1, 1, -4}, {-9, -13, 2})
local traceRight = pose({.05, -.115, -.045, -8, 13, -6}, {56, 6, -11, .07, -.08}, {27, -14, 19, .06, .115},
	planted, {1, -9, 4}, {-9, 7, -1})
local nod = pose({.01, -.135, -.025, -15, -9, -2}, {24, 14, -12, 0, .08}, {26, -16, 17, 0, .10},
	planted, {-5, 8, 1}, {-10, 11, 1})

local firstTile = table.freeze({markAt = .36, burstAt = .90, offset = Vector3.new(-1.80, floorY, -1.55)})
local secondTile = table.freeze({markAt = .74, burstAt = 1.28, offset = Vector3.new(1.72, floorY, -1.55)})
local fanWarningAt = .13
local contact = table.freeze({
	jab = .17,
	cross = .225,
	body = .26,
	heavy = .42,
	emberSweep = .49,
	magmaTrail = table.freeze({firstTile.burstAt, secondTile.burstAt}),
})
local clips = {
	stance = {{0, ready}, {.48, breathe}, {1.08, ready}},
	advance = {{0, ready}, {.135, advanceRight}, {.27, ready}, {.40, advanceLeft}, {.54, ready}},
	retreat = {{0, ready}, {.15, backRight}, {.29, ready}, {.43, backLeft}, {.58, ready}},
	dodge = {{0, ready}, {.105, dodgeRight}, {.24, dodgeRightCatch}, {.49, ready}},
	jab = {{0, ready}, {.075, jabLoad}, {contact.jab, jabContact}, {.25, jabReturn}, {.41, ready}},
	cross = {{0, ready}, {.105, crossLoad}, {contact.cross, crossContact}, {.34, crossReturn}, {.52, ready}},
	body = {{0, ready}, {.12, bodyLoad}, {contact.body, bodyContact}, {.37, bodyReturn}, {.57, ready}},
	heavy = {{0, ready}, {.19, heavyLoad}, {.31, heavyDrive}, {contact.heavy, heavyContact}, {.52, heavyFollow}, {.79, ready}},
	guard = {{0, cover}},
	block = {{0, cover}, {.075, guardRecoil}, {.16, guardRecoil}, {.29, cover}},
	parry = {{0, ready}, {.07, parryReady}, {.135, parryWhisk}, {.22, parryReady}, {.36, ready}},
	hitHead = {{0, ready}, {.08, headHit}, {.18, headHit}, {.35, ready}},
	hitBody = {{0, ready}, {.09, bodyHit}, {.21, bodyHit}, {.39, ready}},
	stagger = {{0, headHit}, {.12, stagger}, {.32, cover}, {.55, ready}},
	knockout = {{0, headHit}, {.14, stagger}, {.34, drop}, {.59, sit}, {1.19, sit}},
	emberSweep = {{0, ready}, {fanWarningAt, sweepLoad}, {.32, sweepLoad}, {.42, sweepPivot},
		{contact.emberSweep, sweepContact}, {.57, sweepFollow}, {.68, sweepCatch}, {.83, sweepSettle},
		{.94, sweepForward}, {1.02, ready}},
	magmaTrail = {{0, ready}, {.12, trailCrouch}, {.24, trailCutLeft}, {firstTile.markAt, trailMarkLeft},
		{.52, trailBend}, {secondTile.markAt, trailMarkRight}, {.88, trailBank}, {1.00, trailBrake},
		{1.08, trailFace}, {1.15, ready}},
	intro = {{0, ready}, {1.06, breathe}, {2.20, ready}, {2.74, traceLeft}, {3.10, traceLeft},
		{3.46, traceRight}, {3.93, traceRight}, {4.52, ready}, {5.26, breathe}, {6.35, nod},
		{6.85, nod}, {7.54, ready}, {8.46, breathe}, {9.22, ready}, {10, ready}},
	win = {{0, ready}, {.24, traceLeft}, {.55, traceRight}, {.89, traceRight}, {1.18, nod}, {1.37, nod}, {1.88, ready}},
}
clips.sidestep = clips.dodge
local leftDodge = {{0, ready}, {.105, dodgeLeft}, {.24, dodgeLeftCatch}, {.49, ready}}

local duration = {}
for name, frames in clips do
	duration[name] = frames[#frames][1]
end
Poses.Duration = table.freeze(duration)
Poses.Contact = contact

-- Basic contacts are glove surfaces and the fan uses a measured tail tip.
-- Tile points are nominal floor positions relative to the skill's start.
-- Use the server's actual reached floor position when planting each mark.
Poses.Impact = table.freeze({
	jab = table.freeze({Vector3.new(.180, .641, -1.673)}),
	cross = table.freeze({Vector3.new(-.273, .711, -1.717)}),
	body = table.freeze({Vector3.new(.057, -.061, -1.827)}),
	heavy = table.freeze({Vector3.new(-.145, .627, -1.935)}),
	emberSweep = table.freeze({Vector3.new(.295, -2.501, -2.989)}),
	magmaTrail = table.freeze({firstTile.offset, secondTile.offset}),
})

Poses.Skill = table.freeze({
	emberSweep = table.freeze({
		warningAt = fanWarningAt,
		center = Vector3.new(0, floorY, 0),
		halfAngle = math.rad(54),
		radius = 3.45,
		damage = 18,
	}),
	magmaTrail = table.freeze({
		tiles = table.freeze({firstTile, secondTile}),
		radius = 1.18,
		tileDamage = 15,
		damageBudget = 30,
		popHeight = .50,
	}),
})

local function waypoint(age, x, z)
	return table.freeze({age = age, offset = Vector3.new(x, 0, z)})
end

-- Root motion follows the safe arena path. Tile clocks are independent of
-- the actor's next clip, including the final burst after she steadies.
Poses.Travel = table.freeze({
	magmaTrail = table.freeze({
		waypoint(.12, 0, 0), waypoint(.24, -1.15, -.70),
		waypoint(firstTile.markAt, firstTile.offset.X, firstTile.offset.Z),
		waypoint(.50, -1.30, -2.62), waypoint(.62, .05, -2.75),
		waypoint(secondTile.markAt, secondTile.offset.X, secondTile.offset.Z),
		waypoint(.88, 1.48, -.47), waypoint(1.02, .33, .03), waypoint(1.13, 0, 0),
	}),
})

local loops = {stance = true, advance = true, retreat = true}
local boots = {["Right Hip"] = rightBoot, ["Left Hip"] = leftBoot}

function Poses.sample(action, age, direction)
	action = clips[action] and action or "stance"
	local frames = if direction == -1 and (action == "dodge" or action == "sidestep") then leftDodge else clips[action]
	age = math.max(age or 0, 0)
	if loops[action] then
		age %= duration[action]
	end
	local before, after = frames[#frames], frames[#frames]
	local weight = 0
	for index = 2, #frames do
		if age <= frames[index][1] then
			before, after = frames[index - 1], frames[index]
			local step = (age - before[1]) / (after[1] - before[1])
			weight = step * step * (3 - 2 * step)
			break
		end
	end
	local root = before[2].RootJoint:Lerp(after[2].RootJoint, weight)
	local inverse = root:Inverse()
	local result = {RootJoint = root}
	for name, previous in before[2] do
		if name ~= "RootJoint" then
			local following = after[2][name]
			local offset = previous:Lerp(following, weight)
			local boot = boots[name]
			if boot then
				local center = previous:PointToWorldSpace(boot):Lerp(following:PointToWorldSpace(boot), weight)
				-- Interpolate about the boot center so a planted pivot does
				-- not drift sideways as the toes turn across the mat.
				offset = inverse * CFrame.new(center - offset:PointToWorldSpace(boot)) * offset
			end
			result[name] = offset
		end
	end
	return result
end

return table.freeze(Poses)
