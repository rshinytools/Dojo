-- Original poses for Silverback's rigid Blender shell. Forward is local -Z.
-- Apply each offset as offset * restC0 to preserve the fitted joint axes.
local Choreography = require(script.Parent.FighterChoreography)
local Poses = {}

local neck = Vector3.new(0, 1.650, -.260)
local rightShoulder = Vector3.new(1.211, 1.218, .116)
local leftShoulder = Vector3.new(-1.211, 1.218, .116)
local rightHip = Vector3.new(.567, -.793, .168)
local leftHip = Vector3.new(-.567, -.793, .168)
local floorHeight = -2.575

-- Toe, heel and side vertices of the staggered boots from the GLB. Keep
-- their floor frame independent of the torso's crouch, pitch and lunge.
local rightSole = {
	Vector3.new(.664, -2.528, -.975), Vector3.new(.454, -2.534, .159),
	Vector3.new(.323, -2.600, -.637), Vector3.new(1.048, -2.600, -.770),
	Vector3.new(.442, -2.600, .090), Vector3.new(1.167, -2.600, -.637),
}
local leftSole = {
	Vector3.new(-.824, -2.528, -.620), Vector3.new(-.454, -2.534, .514),
	Vector3.new(-.323, -2.600, -.282), Vector3.new(-.442, -2.600, -.415),
	Vector3.new(-1.048, -2.600, .445), Vector3.new(-1.167, -2.600, .312),
}
local rightBoot = Vector3.new(.745, -2.600, -.340)
local leftBoot = Vector3.new(-.745, -2.600, .015)

local function rotation(pitch, yaw, roll)
	return CFrame.Angles(math.rad(pitch), math.rad(yaw or 0), math.rad(roll or 0))
end

local function around(pivot, pitch, yaw, roll, lift, depth)
	return CFrame.new(pivot + Vector3.new(0, lift or 0, depth or 0))
		* rotation(pitch, yaw, roll) * CFrame.new(-pivot)
end

local function floorCorrection(frame, sole, lift)
	local low = math.huge
	for _, point in sole do
		low = math.min(low, frame:PointToWorldSpace(point).Y)
	end
	return floorHeight + lift - low
end

local function foot(root, hip, boot, sole, pitch, yaw, lift, depth)
	if lift == false then
		local world = root * around(hip, pitch, yaw)
		local correction = math.max(0, floorCorrection(world, sole, 0))
		return root:Inverse() * CFrame.new(0, correction, 0) * world
	end
	local frame = around(boot, pitch, yaw, 0, 0, depth)
	return root:Inverse() * CFrame.new(0, floorCorrection(frame, sole, lift), 0) * frame
end

-- Feet specify right pitch, left pitch, right lift, left lift, right yaw,
-- left yaw and optional depths. False lets a foot follow the hips on a fall.
local function pose(core, right, left, feet, head)
	local root = CFrame.new(core[1], core[2], core[3]) * rotation(core[4], core[5], core[6])
	return {
		RootJoint = root,
		Neck = around(neck, table.unpack(head)),
		["Right Shoulder"] = around(rightShoulder, table.unpack(right)),
		["Left Shoulder"] = around(leftShoulder, table.unpack(left)),
		["Right Hip"] = foot(root, rightHip, rightBoot, rightSole, feet[1], feet[5], feet[3], feet[7]),
		["Left Hip"] = foot(root, leftHip, leftBoot, leftSole, feet[2], feet[6], feet[4], feet[8]),
	}
end

local rightGuard = {30, 18, -16, 0, .12}
local leftGuard = {44, -18, 15, .06, .26}
local planted = {0, 0, 0, 0, -4, 6}
local ready = pose({.025, -.17, -.015, -8, 9, -3}, rightGuard, leftGuard, planted, {7, -8, 2})
local breathe = pose({.035, -.125, -.01, -6, 8, -2}, {33, 20, -16, 0, .13}, {47, -19, 16, .07, .26},
	planted, {5, -7, 1})
local cover = pose({.015, -.31, .08, -15, 4, 0}, {51, 27, -19, .10, .08}, {69, -24, 19, .17, .12},
	planted, {12, -4})
local blockImpact = pose({.045, -.35, .21, -10, 8, -5}, {52, 32, -19, .09, .14}, {72, -26, 19, .14, .19},
	{0, 0, 0, 0, -5, 9}, {5, -7, 4})
local parryCatch = pose({.04, -.26, .055, -10, 12, -5}, {41, 22, -18, .06, .035}, {53, -22, 16, .08, .19},
	planted, {8, -11, 4})
local parrySweep = pose({.11, -.22, .075, -8, -10, -8}, {36, -13, -5, .04, -.035}, {58, -21, 18, .09, .22},
	{0, 0, 0, 0, -8, 8}, {7, 8, 6})

local jabLoad = pose({.060, -.24, .035, -10, -3, -5}, {24, 20, -15, 0, .24}, leftGuard,
	planted, {9, 3, 4})
local jabContact = pose({.030, -.14, -.23, -13, 24, -3}, {48, 11, -12, .04, -.14}, {47, -22, 16, .07, .32},
	planted, {10, -20, 2})
local jabReturn = pose({.035, -.19, -.07, -9, 14, -3}, {37, 17, -14, .02, -.025}, leftGuard,
	planted, {8, -13, 2})

local crossLoad = pose({-.06, -.24, .045, -8, 25, 5}, rightGuard, {28, -4, 7, -.025, .28},
	planted, {7, -22, -4})
local crossContact = pose({-.065, -.18, -.29, -15, -21, 3}, {38, 25, -21, .04, .22}, {56, -18, 14, .025, -.24},
	{0, 0, 0, 0, -5, 12}, {12, 18, -2})
local crossReturn = pose({-.035, -.24, -.09, -11, -11, 2}, rightGuard, {48, -20, 16, .025, -.09},
	{0, 0, 0, 0, -4, 8}, {10, 9, -1})

local bodyLoad = pose({.13, -.36, .09, -12, -9, -9}, {10, 13, -8, -.035, .24}, {55, -19, 14, .085, .19},
	planted, {9, 7, 7})
local bodyContact = pose({.10, -.36, -.25, -19, 24, -8}, {23, 12, -13, -.04, -.27}, {52, -22, 16, .08, .22},
	{0, 0, 0, 0, -8, 9}, {15, -21, 6})
local bodyReturn = pose({.075, -.30, -.12, -13, 14, -4}, {28, 15, -14, -.025, -.09}, leftGuard,
	planted, {11, -13, 3})

local heavyLoad = pose({-.105, -.36, .16, -7, 31, 8}, {34, 22, -16, .025, .12}, {16, 12, -5, -.08, .25},
	{0, 0, 0, 0, -4, 13}, {6, -27, -5})
local heavyDrive = pose({-.08, -.30, .01, -13, 12, 6}, {41, 25, -19, .075, .19}, {31, -3, 4, -.035, .085},
	{0, 0, 0, 0, -4, 13}, {10, -10, -4})
local heavyContact = pose({-.115, -.20, -.38, -19, -28, 7}, {44, 35, -19, .065, .21}, {52, -27, 15, .075, -.28},
	{0, 0, 0, 0, -5, 13}, {15, 24, -5})
local heavyFollow = pose({-.085, -.26, -.28, -17, -38, 8}, {39, 34, -20, .045, .24}, {40, -38, 17, .04, -.21},
	{0, 0, 0, 0, -6, 13}, {12, 32, -5})

local palmSet = pose({.12, -.35, .15, -11, -13, -7}, {18, 2, -5, -.02, .15}, {50, -20, 18, .08, .205},
	planted, {8, 11, 5})
local palmDrive = pose({.075, -.24, -.06, -13, 4, -5}, {35, 10, -10, 0, -.08}, {48, -23, 17, .065, .28},
	planted, {10, -4, 4})
local palmContact = pose({.045, -.16, -.37, -16, 22, -4}, {48, 15, -14, .035, -.30}, {51, -26, 18, .055, .34},
	planted, {12, -18, 3})
local palmRelease = pose({.02, -.23, -.21, -14, 19, -3}, {39, 16, -15, .01, -.13}, leftGuard,
	planted, {11, -16, 2})

local tapRight = pose({.025, -.17, .035, -4, 5, 2}, {54, 52, -24, .005, .48}, {31, -6, 5, .015, .10},
	planted, {4, -5, -1})
local tapCenter = pose({0, -.16, .035, -6, 2, 0}, {37, 14, -8, .035, .18}, {36, -13, 9, .045, .18},
	planted, {6, -2})
local tapLeft = pose({-.025, -.17, .035, -4, -5, -2}, {24, 9, -6, 0, .13}, {63, -55, 24, .12, .80},
	planted, {4, 5, 1})
local slamDraw = pose({0, -.40, .095, -13, 0, 0}, {25, -18, 9, 0, -.02}, {30, 19, -7, .08, .015},
	planted, {12, 0})
local slamContact = pose({.015, -1.13, -.29, -32, 0, 0}, {-15, 0, -20, -.415, -.39}, {-3, 0, 20, -.174, -.33},
	planted, {17, 0})
local slamLift = pose({.015, -.82, -.22, -29, 2, -1}, {5, 1, -3, -.22, -.20}, {5, -2, 3, .04, -.19},
	planted, {16, -2})
local slamGather = pose({.025, -.44, -.115, -17, 6, -2}, {22, 13, -10, -.03, -.08}, {36, -13, 12, .055, .16},
	planted, {13, -6, 2})

local forwardRight = pose({.105, -.21, -.045, -12, 6, -4}, {25, 15, -13, 0, .13}, leftGuard,
	{-6, 3, .135, 0, -5, 7, -.27, .15}, {10, -6, 3})
local forwardLeft = pose({-.10, -.22, -.055, -12, 12, 4}, rightGuard, {38, -16, 13, .055, .23},
	{3, -6, 0, .13, -5, 7, .15, -.27}, {10, -11, -2})
local backRight = pose({.055, -.17, .07, -4, 4, -4}, rightGuard, {42, -16, 14, .055, .25},
	{10, -4, .115, 0, -5, 8, .22, -.13}, {4, -4, 3})
local backLeft = pose({-.045, -.19, .06, -5, 11, 4}, {30, 17, -14, 0, .11}, leftGuard,
	{-4, 10, 0, .115, -5, 7, -.13, .22}, {5, -10, -2})

local stepRight = pose({.14, -.34, .035, -12, -3, -12}, {20, 3, -7, .035, .10}, {43, -25, 19, .08, .16},
	{2, 0, .115, 0, -13, 3}, {10, 3, 8})
local catchRight = pose({.12, -.31, -.025, -13, 14, -6}, {31, 14, -15, .01, .11}, leftGuard,
	{0, 2, 0, .055, -8, 9}, {11, -13, 4})
local stepLeft = pose({-.16, -.35, .03, -12, 19, 11}, {35, 24, -19, .045, .08}, {35, -6, 9, .035, .19},
	{0, 2, 0, .115, -3, 15}, {10, -17, -8})
local catchLeft = pose({-.10, -.30, -.025, -13, -1, 6}, rightGuard, {44, -18, 13, .065, .24},
	{2, 0, .055, 0, -8, 10}, {12, 2, -4})

local headHit = pose({.085, -.23, .16, 2, 15, -9}, {19, 11, -9, -.015, .14}, {34, -11, 8, .055, .26},
	planted, {10, 8, -6})
local bodyHit = pose({-.055, -.39, .11, -23, 2, 7}, {55, 31, -21, .04, .22}, {53, -30, 22, .065, .29},
	planted, {16, -3, -5})
local stumble = pose({.16, -.28, .28, 8, 19, -15}, {10, 0, -2, -.025, .145}, {25, -10, 5, .025, .19},
	{2, 11, 0, .095, -8, 13, 0, .16}, {5, 1, -7})
local drop = pose({.12, -.59, .23, -6, 16, -13}, {10, 1, -1, -.05, -.11}, {27, -8, 10, .065, .23},
	{-6, 58, 0, false, -5, 11}, {12, -9, 7})
local kneel = pose({.11, -.87, .19, -14, 11, -10}, {0, 0, 2, -.15, -.2}, {21, -11, 10, .01, .20},
	{-4, 74, 0, false, -8, 12}, {-2, -8, 6})

local wrapPress = pose({.045, -.22, .035, -9, 0, 3}, {45, 41, -22, -.01, .28}, {63, -51, 24, .11, .40},
	planted, {-4, 0, -3})
local bow = pose({.025, -.25, -.015, -19, 5, -1}, {21, 12, -7, -.015, .16}, {36, -14, 11, .025, .22},
	planted, {-6, -4, 1})
local winTouch = pose({0, -.08, .015, -3, 5, 0}, {55, 54, -23, .045, .46}, {25, -10, 10, 0, .24},
	planted, {4, -5})

local contact = table.freeze({
	jab = .21,
	cross = .28,
	body = .32,
	heavy = .49,
	ridgePalm = .46,
	seismicChestPound = .99,
})
local warningAt, firstTap, secondTap = .15, .25, .51
local clips = {
	stance = {{0, ready}, {.72, breathe}, {1.48, ready}},
	advance = {{0, ready}, {.19, forwardRight}, {.37, ready}, {.55, forwardLeft}, {.74, ready}},
	retreat = {{0, ready}, {.21, backRight}, {.40, ready}, {.62, backLeft}, {.80, ready}},
	dodge = {{0, ready}, {.13, stepRight}, {.32, catchRight}, {.58, ready}},
	jab = {{0, ready}, {.095, jabLoad}, {contact.jab, jabContact}, {.31, jabReturn}, {.49, ready}},
	cross = {{0, ready}, {.14, crossLoad}, {contact.cross, crossContact}, {.43, crossReturn}, {.65, ready}},
	body = {{0, ready}, {.18, bodyLoad}, {contact.body, bodyContact}, {.46, bodyReturn}, {.70, ready}},
	heavy = {{0, ready}, {.26, heavyLoad}, {.38, heavyDrive}, {contact.heavy, heavyContact}, {.65, heavyFollow}, {.96, ready}},
	guard = {{0, cover}},
	block = {{0, cover}, {.09, blockImpact}, {.19, blockImpact}, {.35, cover}},
	parry = {{0, ready}, {.07, parryCatch}, {.145, parrySweep}, {.24, parryCatch}, {.42, ready}},
	hitHead = {{0, ready}, {.09, headHit}, {.21, headHit}, {.43, ready}},
	hitBody = {{0, ready}, {.125, bodyHit}, {.26, bodyHit}, {.49, ready}},
	stagger = {{0, headHit}, {.15, stumble}, {.37, cover}, {.72, ready}},
	knockout = {{0, headHit}, {.16, stumble}, {.39, drop}, {.64, kneel}, {1.24, kneel}},
	ridgePalm = {{0, ready}, {.25, palmSet}, {.36, palmDrive}, {contact.ridgePalm, palmContact},
		{.57, palmContact}, {.69, palmRelease}, {1.09, ready}},
	seismicChestPound = {{0, ready}, {warningAt, tapCenter}, {firstTap, tapRight}, {.35, tapRight}, {.40, tapCenter},
		{secondTap, tapLeft}, {.60, tapLeft}, {.80, slamDraw}, {contact.seismicChestPound, slamContact},
		{1.13, slamContact}, {1.26, slamLift}, {1.49, slamGather}, {1.92, ready}},
	intro = {{0, ready}, {.95, breathe}, {2.10, ready}, {2.65, wrapPress}, {3.18, wrapPress}, {3.87, ready},
		{4.62, breathe}, {5.42, bow}, {5.98, bow}, {6.72, ready}, {7.81, breathe}, {8.76, ready}, {10, ready}},
	win = {{0, ready}, {.37, winTouch}, {.75, winTouch}, {1.19, bow}, {1.43, bow}, {1.99, ready}},
}
clips.sidestep = clips.dodge
local leftDodge = {{0, ready}, {.13, stepLeft}, {.32, catchLeft}, {.58, ready}}

local duration = {}
for name, frames in clips do
	duration[name] = frames[#frames][1]
end
Poses.Duration = table.freeze(duration)
Poses.Contact = contact

-- Forward glove surfaces for ordinary contacts. Seismic uses the floor point
-- between the two gloves for its dust burst and a separate radial hit volume.
Poses.Impact = table.freeze({
	jab = table.freeze({Vector3.new(.490, .634, -2.767)}),
	cross = table.freeze({Vector3.new(-.488, .066, -3.037)}),
	body = table.freeze({Vector3.new(.467, -.594, -2.600)}),
	heavy = table.freeze({Vector3.new(-.146, -.265, -3.060)}),
	ridgePalm = table.freeze({Vector3.new(.432, .481, -3.030)}),
	seismicChestPound = table.freeze({Vector3.new(0, floorHeight, -.800)}),
})

-- The floor circle stays centered under Silverback's starting root. The
-- two chest taps cue the warning. Only the slam has a contact marker.
Poses.Skill = table.freeze({
	ridgePalm = table.freeze({shove = 1.15}),
	seismicChestPound = table.freeze({
		warningAt = warningAt,
		chestTaps = table.freeze({firstTap, secondTap}),
		radius = 4.25,
		popHeight = .55,
		center = Vector3.new(0, floorHeight, 0),
	}),
})

local loops = {stance = true, advance = true, retreat = true}

function Poses.sample(action, age, direction)
	action = clips[action] and action or "stance"
	local frames = if direction == -1 and (action == "sidestep" or action == "dodge") then leftDodge else clips[action]
	age = math.max(age or 0, 0)
	if loops[action] then
		age %= duration[action]
	end
	for index = 2, #frames do
		local before, after = frames[index - 1], frames[index]
		if age <= after[1] then
			local progress = (age - before[1]) / (after[1] - before[1])
			local weight = progress * progress * (3 - 2 * progress)
			local root = before[2].RootJoint:Lerp(after[2].RootJoint, weight)
			local inverse = root:Inverse()
			local result = {RootJoint = root}
			for name, previous in before[2] do
				local following = after[2][name]
				if name == "Right Hip" or name == "Left Hip" then
					-- Blend in the floor frame so the plant stays still
					-- while the body twists independently above it.
					local fromFoot, toFoot = before[2].RootJoint * previous, after[2].RootJoint * following
					local footFrame = fromFoot:Lerp(toFoot, weight)
					if action == "knockout" and name == "Left Hip" then
						local correction = math.max(0, floorCorrection(footFrame, leftSole, 0))
						footFrame = CFrame.new(0, correction, 0) * footFrame
					end
					result[name] = inverse * footFrame
				elseif name ~= "RootJoint" then
					result[name] = previous:Lerp(following, weight)
				end
			end
			return result
		end
	end
	return frames[#frames][2]
end

Choreography.addShuffle(Poses, rightSole, leftSole, 2.60)
return table.freeze(Poses)
