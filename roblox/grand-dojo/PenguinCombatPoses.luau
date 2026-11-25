-- Original animation on Penguin Brawler's floor-aligned Blender shell.
-- Joint offsets are applied as offset * restC0. Forward is local -Z.
local Choreography = require(script.Parent.FighterChoreography)
local Poses = {}

local neck = Vector3.new(.003, .790, -.118)
local rightShoulder = Vector3.new(.706, .448, .011)
local leftShoulder = Vector3.new(-.701, .449, -.037)
local rightHip = Vector3.new(.434, -1.375, -.040)
local leftHip = Vector3.new(-.431, -1.375, .120)
local tail = Vector3.new(0, -1.041, .441)

-- The toe, heel and side corners of each webbed sole in root coordinates.
local rightSole = {
	Vector3.new(.274, -2.600, .111),
	Vector3.new(.565, -2.575, -.757),
	Vector3.new(.690, -2.574, .142),
	Vector3.new(.141, -2.574, -.291),
	Vector3.new(.967, -2.574, -.524),
}
local leftSole = {
	Vector3.new(-.712, -2.600, .409),
	Vector3.new(-.638, -2.575, -.459),
	Vector3.new(-.294, -2.574, .440),
	Vector3.new(-.989, -2.574, -.253),
	Vector3.new(-.155, -2.574, -.224),
}

local function rotation(pitch, yaw, roll)
	return CFrame.Angles(math.rad(pitch), math.rad(yaw or 0), math.rad(roll or 0))
end

local function around(pivot, pitch, yaw, roll, lift, depth)
	return CFrame.new(pivot + Vector3.new(0, lift or 0, depth or 0))
		* rotation(pitch, yaw, roll) * CFrame.new(-pivot)
end

local function foot(root, hip, sole, pitch, yaw, lift)
	local offset = around(hip, pitch, yaw)
	if not lift then
		return offset
	end
	local frame = root * offset
	local low = math.huge
	for _, point in sole do
		low = math.min(low, frame:PointToWorldSpace(point).Y)
	end
	local correction = root:VectorToObjectSpace(Vector3.new(0, -2.575 + lift - low, 0))
	return CFrame.new(correction) * offset
end

-- Feet specify right pitch, left pitch, right lift, left lift, right yaw and
-- left yaw. False lift values leave the hips unplanted during a slide or fall.
local function pose(core, right, left, feet, head, feather)
	local root = CFrame.new(core[1], core[2], core[3]) * rotation(core[4], core[5], core[6])
	return {
		RootJoint = root,
		Neck = around(neck, table.unpack(head)),
		["Right Shoulder"] = around(rightShoulder, table.unpack(right)),
		["Left Shoulder"] = around(leftShoulder, table.unpack(left)),
		["Right Hip"] = foot(root, rightHip, rightSole, feet[1], feet[5], feet[3]),
		["Left Hip"] = foot(root, leftHip, leftSole, feet[2], feet[6], feet[4]),
		TailJoint = around(tail, table.unpack(feather)),
	}
end

local rightGuard = {10, 40, 24, .06, -.035}
local leftGuard = {-4, 12, -19, .04, .095}
local ready = pose({0, -.025, 0, -4, -5, 0}, rightGuard, leftGuard, {2, -3, 0, 0, 7, -5}, {3, 5}, {-3, -4})
local breathe = pose({.01, .007, .012, -2, -7, 2}, {12, 36, 22, .05}, {-2, 13, -20, .03, .09},
	{2, -3, 0, 0, 7, -5}, {1, 7, -1}, {1, -6})
local cover = pose({-.025, -.17, .09, -12, 4, 0}, {21, 58, 30, .11, -.10}, {9, 22, -28, .10, .08},
	{3, -3, 0, 0, 8, -7}, {9, -4, -2}, {-6, 4})
local guardRecoil = pose({.01, -.16, .17, 5, 8, -5}, {24, 53, 35, .09, -.07}, {9, 25, -26, .10, .13},
	{1, -6, 0, 0, 8, -7}, {-3, -6, 3}, {7, 7})

local jabLoad = pose({-.06, -.11, .08, -5, 11, 3}, rightGuard, {-6, 29, -15, .04, .19},
	{2, -4, 0, 0, 7, -5}, {2, -9, -2}, {-4, 9})
local jabContact = pose({-.035, -.03, -.36, -12, -23, 1}, {11, 39, 24, .055}, {13, -14, -7, .025, -.155},
	{3, -5, 0, 0, 11, -7}, {9, 19}, {7, -13})
local jabReturn = pose({-.025, -.07, -.12, -7, -10, 1}, rightGuard, {5, 3, -15, .03, .015},
	{3, -4, 0, 0, 9, -6}, {4, 8}, {2, -8})

local crossLoad = pose({.075, -.13, .035, -4, -25, -4}, {3, 14, 20, .03, .105}, leftGuard,
	{3, -2, 0, 0, 11, -4}, {2, 22, 3}, {-5, -15})
local crossContact = pose({.055, -.07, -.35, -10, 33, -2}, {14, 70, 26, .03, -.19}, {-4, 14, -21, .04, .12},
	{1, -6, 0, 0, 14, -10}, {7, -24, 2}, {8, 16})
local crossReturn = pose({.035, -.10, -.14, -7, 15, -2}, {12, 55, 26, .06, -.08}, leftGuard,
	{2, -4, 0, 0, 11, -7}, {4, -12}, {3, 8})

local bodyLoad = pose({-.08, -.23, .075, -12, 12, 5}, {14, 46, 25, .08}, {-20, 21, -6, -.11, .17},
	{6, -5, 0, 0, 13, -7}, {9, -11, -3}, {-8, 11})
local bodyContact = pose({-.075, -.21, -.51, -15, -24, 4}, {14, 46, 29, .06}, {1, -15, -9, -.06, -.29},
	{7, -6, 0, 0, 13, -7}, {15, 20, -3}, {5, -17})
local bodyReturn = pose({-.04, -.16, -.16, -13, -14, 2}, rightGuard, {-7, 5, -11, .015, -.01},
	{5, -5, 0, 0, 11, -5}, {10, 12}, {2, -8})

local heavyLoad = pose({.11, -.21, .13, -7, -37, -7}, {-10, 4, 19, .035, .17}, {1, 14, -26, .05, .10},
	{4, -8, 0, 0, 10, -5}, {4, 27, 5}, {-9, -19})
local heavyDrive = pose({.09, -.17, -.035, -15, -2, -5}, {2, 43, 20, .04, -.03}, leftGuard,
	{4, -6, 0, 0, 12, -9}, {11, 2, 2}, {-5, -4})
local heavyContact = pose({.065, -.105, -.41, -14, 35, -3}, {10, 66, 22, .015, -.24}, {-3, 21, -20, .05, .13},
	{3, -8, 0, 0, 17, -10}, {11, -25, 2}, {9, 20})
local heavyFollow = pose({.045, -.14, -.29, -12, 40, 1}, {11, 52, 25, .035, -.13}, leftGuard,
	{5, -7, 0, 0, 16, -8}, {8, -27}, {5, 21})

-- The torso and flippers carry the strikes while both webbed feet stay planted.
local tacticalFeet = {2, -3, 0, 0, 7, -5}
local plantedRight = ready.RootJoint * ready["Right Hip"]
local plantedLeft = ready.RootJoint * ready["Left Hip"]

local palmGather = pose({.065, -.18, .055, -12, -20, -4}, {8, 24, 39, .09, .09}, {8, 18, -36, .13, .07},
	tacticalFeet, {8, 16}, {-6, -11})
local palmFrame = pose({.08, -.16, -.045, -12, -10, -3}, {24, 43, 38, .13, -.025}, {16, 24, -40, .15, .055},
	tacticalFeet, {8, 8}, {-4, -5})
local palmPush = pose({.04, -.12, -.37, -11, 43, -2}, {12, 82, 24, .055, -.26}, {18, 22, -41, .15, .09},
	tacticalFeet, {9, -23}, {8, 13})
local palmRelease = pose({.045, -.10, -.16, -8, 23, 1}, {20, 57, 32, .08, -.095}, {11, 18, -35, .11, .08},
	tacticalFeet, {6, -18}, {6, 11})

local hookLoad = pose({-.095, -.24, .09, -13, 24, 7}, {16, 44, 30, .09, .035}, {-14, 34, -7, -.075, .20},
	tacticalFeet, {11, -18, -3}, {-5, 11})
local hookCut = pose({-.065, -.235, -.20, -13, -40, 4}, {17, 43, 31, .09, .045}, {2, -33, -17, -.095, -.055},
	tacticalFeet, {11, 24, -3}, {6, -13})
local hookFold = pose({-.04, -.19, -.11, -10, -30, 3}, {14, 44, 27, .07, .025}, {3, -41, -25, -.015, .035},
	tacticalFeet, {9, 24, -2}, {5, -14})

local pressCrouch = pose({0, -.19, .045, -12, -5, 0}, {-3, 22, 40, .06, .14}, {8, 24, -37, .07, .14},
	tacticalFeet, {9, 5}, {-9, -5})
local pressLoad = pose({0, -.36, .09, -18, -4, 0}, {-8, 18, 54, .03, .16}, {2, 27, -51, .05, .21},
	tacticalFeet, {15, 4}, {-12, -5})
local pressDrive = pose({0, -.27, -.055, -15, -2, 0}, {12, 67, 26, .09, -.03}, {16, -22, -29, .11, .045},
	tacticalFeet, {12, 2}, {-7, -3})
local pressContact = pose({0, -.18, -.52, -15, 2, 0}, {14, 129, 5, .03, -.44}, {11, -67, -11, .11, -.54},
	tacticalFeet, {10, -2}, {7, 2})
local pressRelease = pose({0, -.19, -.19, -11, 1, 0}, {18, 105, 12, .04, -.19}, {11, -47, -17, .045, -.135},
	tacticalFeet, {6, -1}, {4, -1})
local pressFold = pose({0, -.11, -.055, -7, -3, 0}, {15, 65, 22, .07, -.035}, {4, -16, -24, .055, .065},
	tacticalFeet, {5, 4}, {1, -3})

local parryCatch = pose({-.055, -.11, .04, -7, -5, 3}, {18, 47, 27, .07}, {3, 23, -28, .08, .06},
	{3, -4, 0, 0, 10, -6}, {4, 4, -3}, {1, -8})
local parrySweep = pose({-.115, -.095, .09, -5, 17, 8}, {10, 43, 30, .055}, {9, -34, -33, .045, -.055},
	{3, -5, 0, 0, 13, -12}, {2, -14, -6}, {6, 13})

local headHit = pose({.07, -.13, .15, 11, 8, -7}, {3, 23, 18}, {-2, 16, -11, .015, .11},
	{1, -12, 0, 0, 12, -10}, {9, 5, -4}, {-7, 11})
local bodyHit = pose({-.045, -.25, .19, -20, -5, 4}, {18, 49, 26, .04}, {3, 24, -22, .02, .08},
	{9, -10, 0, 0, 13, -8}, {16, 3, -2}, {-10, -6})
local stumble = pose({.11, -.18, .25, 13, 15, -12}, {-7, 16, 24}, {3, 29, -21, .02, .13},
	{-6, -14, 0, .11, 14, -12}, {8, -8, -2}, {-11, 14})
local sitDrop = pose({.18, -.47, .28, 23, 17, -19}, {-8, 17, 15}, {4, 27, -18, 0, .05},
	{25, 27, 0, .015, -1, 7}, {6, -8, 4}, {-10, 10})
local sit = pose({.24, -.86, .30, 32, 15, -22}, {-10, 16, 13}, {4, 26, -16},
	{46, 46, false, false, -2, 10}, {2, -8, 8}, {-10, 8})

local forwardRight = pose({.075, -.045, -.04, -7, -8, -4}, {7, 30, 20}, leftGuard,
	{14, -4, .12, 0, 10, -7}, {4, 7, 2}, {-3, -10})
local forwardLeft = pose({-.065, -.045, -.055, -7, -3, 4}, rightGuard, {-7, 16, -15, .025, .08},
	{-5, 14, 0, .12, 10, -7}, {4, 3, -2}, {-4, 9})
local backRight = pose({.065, -.045, .045, 3, -3, -3}, {9, 35, 21}, leftGuard,
	{-14, 5, .105, 0, 10, -9}, {-2, 3, 2}, {4, -6})
local backLeft = pose({-.06, -.045, .055, 3, -7, 3}, rightGuard, {-2, 10, -18, .035, .08},
	{4, -14, 0, .105, 11, -7}, {-3, 7, -2}, {5, 7})

local bankRight = pose({.07, -.13, -.02, -9, -18, -12}, {-4, 15, 33}, {1, -8, -34, .02, .11},
	{3, -6, 0, .09, -8, -11}, {7, 13, 5}, {-6, -15})
local catchRight = pose({.025, -.12, -.055, -12, 11, 8}, {12, 42, 26, .05}, {-2, 16, -19, .035, .08},
	{6, -4, 0, 0, 19, -3}, {9, -9, -5}, {3, 12})
local bankLeft = pose({-.07, -.13, -.025, -9, 16, 12}, {1, 24, 38}, {-8, 1, -30, .03, .10},
	{4, -6, .09, 0, 13, 9}, {7, -12, -5}, {-6, 15})
local catchLeft = pose({-.025, -.12, -.055, -12, -18, -8}, {12, 42, 24, .05}, {-2, 13, -23, .035, .08},
	{5, -4, 0, 0, 7, -20}, {9, 15, 5}, {3, -12})

local slideCoil = pose({0, -.24, .07, -18, -1, 0}, {-7, 16, 13}, {-8, 22, -14, .035, .14},
	{6, -8, 0, 0, 8, -7}, {14, 2}, {-10})
local slidePush = pose({.025, -.35, -.19, -33, 1, -2}, {-9, -9, 22}, {-14, 43, -19, 0, .12},
	{-14, -13, 0, .085, 8, -5}, {24, -1}, {6, -4})
local slideDive = pose({.012, -.88, -.155, -51, 1, -1}, {-9, -15, 24}, {-12, 47, -21, 0, .08},
	{-27, -20, .045, .065, 3, -5}, {26, -1}, {12, -2})
local slideFront = pose({0, -1.56, -.14, -70, 0, 0}, {-10, -21, 26}, {-8, 52, -24, -.01, .045},
	{-30, -18, false, false, -2, -6}, {27}, {17})
local slideBrake = pose({0, -1.31, -.19, -59, 0, 0}, {-8, -8, 30}, {-5, 38, -34, .02, .05},
	{-38, -26, false, false, -14, 10}, {25}, {13})
local slideCatch = pose({.01, -.85, -.23, -43, -5, 3}, {-2, 18, 34, .02}, {-4, 29, -34, .02, .06},
	{-31, -24, .03, .025, -8, 7}, {22, 3, -1}, {11, -5})
local slideSkid = pose({.015, -.47, -.24, -30, -8, 4}, {4, 28, 34, .02}, {-6, 24, -29, .02, .06},
	{-13, -11, 0, 0, 13, -9}, {18, 5, -2}, {9, -8})
local slideCollect = pose({0, -.23, -.05, -18, -5, 1}, rightGuard, leftGuard,
	{7, -5, 0, 0, 9, -5}, {13, 4}, {2, -4})

local bow = pose({0, -.14, -.055, -16, -5, 1}, {2, 22, 18}, {0, 23, -13, .02, .045},
	{5, -4, 0, 0, 9, -5}, {-5, 4}, {5, -5})
local flourish = pose({0, -.045, -.035, -4, -14, 6}, {-11, 27, 52, .015}, leftGuard,
	{3, -7, 0, 0, 13, -5}, {4, 11, -6}, {5, -14})

local contact = table.freeze({
	jab = .17,
	cross = .24,
	body = .27,
	heavy = .43,
	icecrestPalm = .34,
	floeHook = .23,
	glacierPress = .50,
	bellySlide = table.freeze({.38, .49, .60, .68}),
})
local slideContacts = contact.bellySlide
local clips = {
	stance = {{0, ready}, {.58, breathe}, {1.24, ready}},
	advance = {{0, ready}, {.155, forwardRight}, {.30, ready}, {.455, forwardLeft}, {.60, ready}},
	retreat = {{0, ready}, {.17, backRight}, {.33, ready}, {.50, backLeft}, {.66, ready}},
	sidestep = {{0, ready}, {.12, bankRight}, {.27, catchRight}, {.46, ready}},
	jab = {{0, ready}, {.08, jabLoad}, {contact.jab, jabContact}, {.25, jabReturn}, {.43, ready}},
	cross = {{0, ready}, {.12, crossLoad}, {contact.cross, crossContact}, {.34, crossReturn}, {.57, ready}},
	body = {{0, ready}, {.14, bodyLoad}, {contact.body, bodyContact}, {.40, bodyReturn}, {.62, ready}},
	heavy = {{0, ready}, {.22, heavyLoad}, {.33, heavyDrive}, {contact.heavy, heavyContact}, {.56, heavyFollow}, {.86, ready}},
	icecrestPalm = {{0, ready}, {.13, palmGather}, {.23, palmFrame}, {contact.icecrestPalm, palmPush},
		{.47, palmRelease}, {.72, ready}},
	floeHook = {{0, ready}, {.10, hookLoad}, {contact.floeHook, hookCut}, {.34, hookFold}, {.58, ready}},
	glacierPress = {{0, ready}, {.155, pressCrouch}, {.255, pressLoad}, {.32, pressLoad}, {.405, pressDrive},
		{contact.glacierPress, pressContact}, {.63, pressRelease}, {.78, pressFold}, {.94, ready}},
	guard = {{0, cover}},
	block = {{0, guardRecoil}, {.09, guardRecoil}, {.29, cover}},
	parry = {{0, parryCatch}, {.09, parrySweep}, {.20, parryCatch}, {.36, ready}},
	hitHead = {{0, cover}, {.09, headHit}, {.24, headHit}, {.38, ready}},
	hitBody = {{0, cover}, {.10, bodyHit}, {.26, bodyHit}, {.42, ready}},
	stagger = {{0, headHit}, {.13, stumble}, {.37, cover}, {.67, ready}},
	knockout = {{0, headHit}, {.14, stumble}, {.31, sitDrop}, {.53, sit}, {1.20, sit}},
	floeTurn = {{0, ready}, {.17, bankRight}, {.35, catchRight}, {.66, ready}},
	bellySlide = {{0, ready}, {.22, slideCoil}, {.31, slidePush}, {.345, slideDive},
		{slideContacts[1], slideFront}, {slideContacts[3], slideFront}, {slideContacts[4], slideBrake},
		{.74, slideCatch}, {.80, slideSkid}, {1.00, slideCollect}, {1.27, ready}},
	intro = {{0, ready}, {1.08, breathe}, {2.35, ready}, {2.82, bow}, {3.31, bow},
		{3.94, ready}, {5.30, breathe}, {6.48, flourish}, {7.07, flourish}, {7.72, ready}, {10, ready}},
	win = {{0, ready}, {.20, bow}, {.49, flourish}, {.95, flourish}, {1.22, bow}, {1.86, ready}},
}
local leftTurns = {
	sidestep = {{0, ready}, {.12, bankLeft}, {.27, catchLeft}, {.46, ready}},
	floeTurn = {{0, ready}, {.17, bankLeft}, {.35, catchLeft}, {.66, ready}},
}

local duration = {}
for name, frames in clips do
	duration[name] = frames[#frames][1]
end
Poses.Duration = table.freeze(duration)
Poses.Contact = contact

-- Forward surface samples from the Blender pads and torso, measured at each
-- authored contact relative to an unmoved HumanoidRootPart.
local slidingChest = Vector3.new(-.054, -1.717, -1.083)
-- The right flipper's GLB vertex in the mounted rest frame.
local pressPad = Vector3.new(1.789506197, 2.649204015 - 2.132, .308000468)
Poses.Impact = table.freeze({
	jab = table.freeze({Vector3.new(-.409, .028, -1.819)}),
	cross = table.freeze({Vector3.new(.546, .481, -2.058)}),
	body = table.freeze({Vector3.new(-.434, -.529, -1.967)}),
	heavy = table.freeze({Vector3.new(.510, .165, -2.224)}),
	icecrestPalm = table.freeze({Vector3.new(0.432425851, 0.427610454, -2.052795646)}),
	floeHook = table.freeze({Vector3.new(-0.183524557, -0.136406898, -1.601527903)}),
	glacierPress = table.freeze({(pressContact.RootJoint * pressContact["Right Shoulder"]):PointToWorldSpace(pressPad)}),
	bellySlide = table.freeze({slidingChest, slidingChest, slidingChest, Vector3.new(-.044, -1.296, -1.157)}),
})

-- Paths are relative to the starting root. A resolver sweeps against arena
-- limits; direction -1 mirrors Floe Turn's X only. Neither path applies damage.
local function waypoint(age, x, depth)
	return table.freeze({age = age, offset = Vector3.new(x, 0, -depth)})
end
Poses.Travel = table.freeze({
	floeTurn = table.freeze({
		waypoint(.10, 0, 0), waypoint(.20, .54, .32), waypoint(.32, 1.60, .61), waypoint(.44, 2.42, .48),
	}),
	bellySlide = table.freeze({
		waypoint(.32, 0, 0), waypoint(.38, 0, .48), waypoint(.49, 0, 1.81),
		waypoint(.60, 0, 3.31), waypoint(.68, 0, 4.30), waypoint(.76, 0, 4.80),
	}),
})

-- Sweep between belly contact samples and allow one hit per target throughout
-- the slide. The visual skid after this window is recovery.
Poses.HitWindow = table.freeze({
	bellySlide = table.freeze({opensAt = slideContacts[1], closesAt = slideContacts[#slideContacts]}),
})

local loops = {stance = true, advance = true, retreat = true}

function Poses.sample(action, age, direction)
	action = clips[action] and action or "stance"
	local frames = (direction == -1 and leftTurns[action]) or clips[action]
	age = math.max(age or 0, 0)
	if loops[action] then
		age %= duration[action]
	end
	for index = 2, #frames do
		local before, after = frames[index - 1], frames[index]
		if age <= after[1] then
			local progress = (age - before[1]) / (after[1] - before[1])
			local weight = progress * progress * (3 - 2 * progress)
			local result = {}
			for name, previous in before[2] do
				result[name] = previous:Lerp(after[2][name], weight)
			end
			if action == "icecrestPalm" or action == "floeHook" or action == "glacierPress" then
				local root = result.RootJoint
				result["Right Hip"] = root:ToObjectSpace(plantedRight)
				result["Left Hip"] = root:ToObjectSpace(plantedLeft)
			end
			return result
		end
	end
	return table.clone(frames[#frames][2])
end

Choreography.addShuffle(Poses, rightSole, leftSole, 2.60)
return table.freeze(Poses)
