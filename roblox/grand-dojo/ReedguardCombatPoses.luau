-- Reedguard's original R6 sparring poses. Offsets are in Part0 space.
-- Apply each value as offset * restC0 to preserve the rig's bind orientation.
local Choreography = require(script.Parent.FighterChoreography)
local Poses = {}

local joints = {
	root = "RootJoint",
	neck = "Neck",
	rightArm = "Right Shoulder",
	leftArm = "Left Shoulder",
	rightLeg = "Right Hip",
	leftLeg = "Left Hip",
	tail = "TailJoint",
}

-- ArtPivot offsets used by the original animation keys, relative to their 2.6-stud origin.
local neckPivot = Vector3.new(0, 0.475, 0)
local rightShoulderPivot = Vector3.new(0.82, 0.106, 0)
local leftShoulderPivot = Vector3.new(-0.82, 0.106, 0)
local rightHipPivot = Vector3.new(0.4674, -1.206, 0)
local leftHipPivot = Vector3.new(-0.4674, -1.206, 0)
local tailPivot = Vector3.new(0, -1.001, 0.369)
local artOrigin = Vector3.new(0, 2.6, 0)
local mountedOrigin = Vector3.new(0, 2.132, 0)

-- These eight points follow each boot's flat sole in the original fitted mesh.
local function sole(side)
	local points = {}
	for _, edge in {{.118, -.59139, .13339}, {.21332, -.767, .309}, {.64868, -.767, .309}, {.744, -.59139, .13339}} do
		table.insert(points, Vector3.new(side * edge[1], 0, edge[2]))
		table.insert(points, Vector3.new(side * edge[1], 0, edge[3]))
	end
	return points
end

-- New grounded clips resolve their sole targets from the mounted character's actual root height.
local groundedRig = Choreography.new(mountedOrigin.Y, {
	[joints.neck] = artOrigin + neckPivot,
	[joints.rightArm] = artOrigin + rightShoulderPivot,
	[joints.leftArm] = artOrigin + leftShoulderPivot,
	[joints.rightLeg] = artOrigin + rightHipPivot,
	[joints.leftLeg] = artOrigin + leftHipPivot,
	[joints.tail] = artOrigin + tailPivot,
}, sole(1), sole(-1))
local groundedPose = groundedRig.pose

local function rotation(pitch, yaw, roll)
	return CFrame.Angles(math.rad(pitch), math.rad(yaw), math.rad(roll))
end

Poses.Defeat = {
	angle = Vector3.new(math.rad(88), 0, math.rad(5)),
	joints = {
		Head = {joints.neck, rotation(5, 0, -5)},
		["Right Arm"] = {joints.rightArm, rotation(6, -15, -6)},
		["Left Arm"] = {joints.leftArm, rotation(0, 8, -18)},
		["Right Leg"] = {joints.rightLeg, rotation(-9, -5, -8)},
		["Left Leg"] = {joints.leftLeg, rotation(-9, 5, 8)},
		Tail = {joints.tail, rotation(19, 75, 15)},
	},
}

local function around(pivot, pitch, yaw, roll, y, z)
	return CFrame.new(pivot + Vector3.new(0, y or 0, z or 0))
		* rotation(pitch, yaw, roll)
		* CFrame.new(-pivot)
end

-- Each pose reads from torso down: root translation and rotation, two gloves,
-- sagittal leg motion, then head and tail follow-through. Angles are degrees.
local function pose(root, right, left, legs, head, tail)
	return {
		[joints.root] = CFrame.new(root[1], root[2], root[3]) * rotation(root[4], root[5], root[6]),
		[joints.neck] = around(neckPivot, head[1], head[2], head[3]),
		[joints.rightArm] = around(rightShoulderPivot, right[1], right[2], right[3], right[4], right[5]),
		[joints.leftArm] = around(leftShoulderPivot, left[1], left[2], left[3], left[4], left[5]),
		[joints.rightLeg] = around(rightHipPivot, legs[1], 0, 0, legs[3]),
		[joints.leftLeg] = around(leftHipPivot, legs[2], 0, 0, legs[4]),
		[joints.tail] = around(tailPivot, tail[1], tail[2], 0),
	}
end

local ready = pose({0.02, -0.02, 0, 3, 9, -2}, {44, 10, -16}, {58, -15, 15}, {8, -7}, {-3, -8, 2}, {-4, -6})
local breathing = pose({0.02, 0.035, 0, 1, 7, -1}, {47, 9, -16}, {61, -14, 14}, {7, -6}, {0, -7, 1}, {0, -4})
local guard = pose({0, -0.12, 0.09, 7, 4, 0}, {72, 21, -24}, {78, -23, 24}, {10, -8}, {3, -4, 0}, {-9, -5})
local covering = pose({0, -0.20, 0.10, 11, -5, -2}, {75, 28, -25}, {82, -18, 19}, {12, -11}, {6, 4, 0}, {-12, 8})

local jabLoad = pose({0.02, -0.04, 0.05, 3, 0, -2}, {39, 8, -14}, {60, -17, 20}, {8, -7}, {-4, 0, 1}, {-3, 1})
local jabContact = pose({0.02, 0.025, -0.25, 5, 21, -3}, {91, 13, -22, 0.035, -0.18}, {64, -23, 24}, {12, -3}, {-5, -18, 3}, {4, -16})
local jabRetract = pose({0.02, -0.045, -0.09, 4, 12, -3}, {57, 13, -18}, {61, -19, 20}, {10, -6}, {-4, -10, 2}, {-3, -10})

local crossLoad = pose({-0.055, -0.085, 0.06, 4, 24, 3}, {62, 16, -20}, {37, -10, 10}, {10, -8}, {-4, -20, -1}, {-7, -17})
local crossContact = pose({-0.09, -0.015, -0.29, 7, -24, 3}, {64, 24, -27}, {75, -13, 22, 0.045, -0.18}, {15, -2}, {-7, 21, -3}, {7, 19})
local crossRetract = pose({-0.06, -0.055, -0.12, 5, -9, 2}, {58, 20, -23}, {61, -17, 19}, {10, -5}, {-5, 8, -2}, {1, 11})

local rearBoot = {8, -4, 0, 0, 0, 0, .025}
local leadBoot = {-7, 6, 0, 0, 0, 0, .025}
local rightGuard, leftGuard = {44, 10, -16}, {58, -15, 15}
local guardedFeet = groundedPose({.02, -.02, 0, 3, 9, -2}, rightGuard, leftGuard,
	rearBoot, leadBoot, {-3, -8, 2}, {-4, -6})
local kickLoad = groundedPose({-.10, -.14, .07, 8, -8, 7}, {48, 13, -16}, {63, -19, 18},
	{26, -7, 1, .02, .04, .10, .38}, leadBoot, {-4, 5, -4}, {-7, 15})
local kickChamber = groundedPose({-.16, -.15, .02, 5, -5, 8}, {51, 15, -18}, {64, -18, 19},
	{48, -6, -3, .01, .09, .06, .77}, leadBoot, {-5, 2, -5}, {-4, 14})
local kickContact = groundedPose({-.11, -.045, -.44, -9, 6, 4}, {56, 15, -17}, {61, -16, 18},
	{92, -2, -3, -.035, .045, -.29, 1.23}, leadBoot, {3, -4, -2}, {10, -15})
local kickRetract = groundedPose({-.135, -.09, -.13, 2, 2, 5}, {52, 12, -17}, {62, -17, 17},
	{53, -5, -3, .01, .08, -.065, .84}, leadBoot, {-3, -1, -3}, {2, -4})
local kickPlant = groundedPose({-.035, -.10, -.015, 6, 7, 1}, {48, 11, -16}, {60, -16, 16},
	{13, -5, 1, .01, 0, -.02, .025}, leadBoot, {-4, -5, 0}, {-4, -6})

-- Reed Sweep carries the weight over the right boot. The left boot circles
-- out low before crossing the centerline and returning to the stance.
local sweepLoad = groundedPose({.12, -.18, .055, 11, 14, -8}, {57, 14, -16}, {52, -18, 18},
	rearBoot, {12, 19, -2, -.035, .005, .10, .068}, {-8, -12, 5}, {-22, -18})
local sweepChamber = groundedPose({.16, -.20, .03, 6, 18, -9}, {62, 19, -22}, {48, -16, 18},
	rearBoot, {31, 25, -13, -.15, .02, -.045, .27}, {-5, -14, 7}, {-25, -21})
local sweepContact = groundedPose({.075, -.21, -.24, 3, -18, 3}, {51, 10, -13}, {57, -14, 18},
	rearBoot, {65, -7, -7, .07, .035, -.50, .34}, {-2, 17, -3}, {-26, 24})
local sweepWithdraw = groundedPose({.10, -.20, -.095, 6, 7, -5}, {57, 14, -17}, {55, -16, 19},
	rearBoot, {37, 7, 2, -.15, .045, -.24, .22}, {-4, 7, 2}, {-23, 9})
local sweepSettle = groundedPose({.068, -.12, -.025, 6, 6, -4}, {50, 14, -17}, {57, -16, 17},
	rearBoot, {3, 5, 0, -.012, 0, -.025, .025}, {-4, -5, 1}, {-13, -8})

-- Reedstone Heel loads on the left boot. The right boot rises with the toe
-- above its heel, then drives through the torso line before folding back.
local heelLoad = groundedPose({-.115, -.18, .075, 6, 6, 9}, {50, 18, -21}, {67, -19, 23},
	{19, -5, 7, .065, .035, .09, .16}, leadBoot, {-6, -5, -4}, {-13, 14})
local heelLift = groundedPose({-.18, -.13, .055, 0, -8, 13}, {42, 12, -28}, {68, -22, 22},
	{51, -16, 13, .13, .06, .08, .54}, leadBoot, {-3, 7, -7}, {-14, 25})
local heelChamber = groundedPose({-.19, -.10, .085, -5, -11, 15}, {30, 8, -28}, {71, -20, 21},
	{81, -19, 6, .10, .065, .09, .94}, leadBoot, {0, 9, -8}, {-15, 27})
local heelStrike = groundedPose({-.155, -.02, -.43, -10, 6, 10}, {34, 9, -36}, {62, -21, 24},
	{134, -6, -9, -.025, .06, -.34, 1.93}, leadBoot, {5, -5, -6}, {-12, -14})
local heelFollow = groundedPose({-.145, -.07, -.14, -8, 9, 10}, {39, 10, -33}, {63, -20, 25},
	{125, -5, -6, -.035, .04, -.12, 1.66}, leadBoot, {2, -7, -6}, {-14, -12})
local heelRetract = groundedPose({-.16, -.17, .02, 3, -1, 11}, {48, 12, -22}, {62, -18, 21},
	{58, -11, 6, .095, .07, .08, .58}, leadBoot, {-4, 1, -6}, {-13, 14})
local heelSettle = groundedPose({-.065, -.10, .012, 5, 5, 5}, {47, 12, -18}, {61, -16, 18},
	{9, -5, 0, 0, 0, 0, .025}, leadBoot, {-5, -4, -2}, {-8, -9})

-- Basic openers with a shorter recovery than the Technique kicks.
local checkLoad = groundedPose({-.052, -.075, .072, 4, 11, 3}, {50, 12, -17},
	{44, -9, 24, -.028, .028, .105}, rearBoot, leadBoot, {-4, -10, -3}, {-8, -12})
local checkHit = groundedPose({-.025, -.073, -.13, 3, -17, 1}, {55, 12, -17},
	{62, -12, 13, .085, .035, -.180}, rearBoot, leadBoot, {-4, 15, -2}, {-4, 13})
local checkFold = groundedPose({-.038, -.099, -.027, 6, -8, 3}, {49, 11, -16},
	{54, -14, 21, .035, .052, .038}, rearBoot, leadBoot, {-5, 6, -2}, {-8, 7})

local toeLoad = groundedPose({.099, -.13, .048, 6, 7, -5}, {51, 12, -19}, {62, -16, 17},
	rearBoot, {16, 12, -3, -.048, .015, .01, .092}, {-5, -7, 3}, {-14, -12})
local toeHit = groundedPose({.08, -.11, -.15, 4, -12, -2}, {53, 14, -16}, {64, -18, 19},
	rearBoot, {46, -1, -3, -.070, .045, -.07, .34}, {-4, 11, 2}, {-16, 11})
local toeTuck = groundedPose({.09, -.12, -.04, 5, -3, -4}, {52, 12, -17}, {62, -16, 17},
	rearBoot, {26, 7, -3, -.013, .033, -.038, .21}, {-4, 3, 3}, {-13, 7})
local toeReturn = groundedPose({.055, -.075, .015, 4, 4, -3}, rightGuard, leftGuard,
	rearBoot, {4, 8, 0, -.02, 0, -.01, .025}, {-4, -3, 2}, {-7, -4})

local uppercutLoad = pose({0.06, -0.18, 0.055, 9, -13, -4}, {27, 7, -11, 0, 0.07}, {65, -20, 22}, {10, -7}, {-7, 12, 3}, {-7, 12})
local uppercutDrive = pose({0.07, -0.10, -0.10, 7, 8, -3}, {68, 13, -17, 0.015, -0.14}, {64, -20, 22}, {10, -7}, {-5, -7, 2}, {-3, -9})
local uppercutContact = pose({0.035, 0.01, -0.34, -4, 20, -3}, {119, 14, -21, 0.12, -0.29}, {65, -22, 22}, {11, -5}, {1, -17, 3}, {3, -17})
local uppercutRetract = pose({0.04, -0.063, -0.14, 6, 15, -3}, {69, 13, -17, 0.015, -0.04}, {62, -20, 21}, {9, -7}, {-5, -13, 2}, {-3, -11})

local heavyLoad = pose({-0.10, -0.15, 0.11, 7, 31, 7}, {64, 19, -21}, {21, -2, 9, 0, 0.04}, {13, -12}, {-5, -24, -5}, {-11, -23})
local heavyDrive = pose({-0.08, -0.13, -0.04, 11, 1, 6}, {65, 21, -26}, {52, -11, 17}, {16, -7}, {-7, -3, -5}, {-4, -6})
local heavyContact = pose({-0.14, -0.055, -0.44, 10, -28, 5}, {65, 23, -27}, {74, -13, 25, 0.03, -0.22}, {20, 0}, {-9, 23, -5}, {9, 23})
local heavyFollow = pose({-0.12, -0.10, -0.32, 14, -33, 7}, {61, 22, -24}, {71, -33, 31, 0, -0.10}, {17, -6}, {-8, 26, -4}, {4, 26})

local risingLoad = pose({0.05, -0.19, 0.04, 8, -13, -5}, {28, 6, -10}, {65, -18, 21}, {13, -11}, {-6, 11, 4}, {-7, 10})
local risingBody = pose({0.07, -0.16, -0.30, 12, 23, -3}, {50, 13, -21, 0, -0.19}, {66, -22, 25}, {17, -5}, {-8, -18, 3}, {-2, -18})
local risingSwitch = pose({-0.01, -0.12, -0.17, 8, 5, 3}, {60, 19, -24}, {36, -7, 12}, {13, -8}, {-6, -5, -2}, {-5, -7})
local risingCross = pose({-0.08, -0.028, -0.39, 8, -23, 4}, {66, 24, -27}, {74, -15, 23, 0.03, -0.17}, {16, -3}, {-8, 20, -3}, {5, 21})
local risingCoil = pose({0.07, -0.24, -0.18, 13, -16, -7}, {26, 11, -13, 0, 0.03}, {67, -22, 23}, {16, -11}, {-8, 15, 4}, {-9, 13})
local risingFinish = pose({0.09, 0.145, -0.41, -5, 25, -3}, {110, 15, -22, 0.085, -0.22}, {63, -24, 23}, {13, 2}, {-3, -21, 2}, {11, -20})
local risingSettle = pose({0.05, -0.17, -0.19, 10, 13, -4}, {65, 15, -19}, {62, -19, 21}, {14, -8}, {-6, -12, 3}, {-4, -10})

local parryCatch = pose({-0.07, -0.095, 0.06, 5, 11, 3}, {77, 22, -25, 0.035}, {74, -22, 19}, {12, -8}, {0, -10, -3}, {-4, -10})
local parrySweep = pose({-0.13, -0.065, 0.05, 5, -13, 7}, {76, 36, -28, 0.04, -0.14}, {68, -21, 22}, {12, -6}, {-1, 12, -4}, {2, 10})
local parryReturn = pose({-0.045, -0.055, 0.025, 4, -3, 0}, {67, 24, -24}, {65, -18, 23}, {10, -7}, {-2, 4, 0}, {-4, 5})

local headFlinch = pose({0.02, -0.025, 0.14, -10, -11, -5}, {34, 8, 1}, {46, -16, 11}, {4, -13}, {-12, -6, -8}, {-10, 12})
local headRecoil = pose({0.11, -0.065, 0.26, -13, -18, -7}, {29, 5, 4}, {51, -21, 12}, {2, -17}, {-14, -9, -12}, {-12, 18})
local bodyFlinch = pose({-0.06, -0.18, 0.13, 16, 10, 7}, {43, 25, -26}, {40, -25, 25}, {14, -12}, {8, -7, -5}, {-12, -5})
local bodyRecoil = pose({-0.08, -0.23, 0.25, 21, 12, 7}, {42, 27, -26}, {39, -23, 26}, {16, -14}, {11, -9, -6}, {-14, -9})
local stumble = pose({0.07, -0.24, 0.31, -8, -19, -7}, {25, 3, 5}, {38, -12, 7}, {4, -22}, {-7, 10, -6}, {-13, 20})
local brace = pose({-0.03, -0.21, 0.12, 13, -4, 3}, {59, 23, -23}, {66, -22, 23}, {16, -15}, {4, 5, -2}, {-9, 3})

local stepForwardRight = pose({0.04, 0.015, -0.07, 6, 11, -2}, {43, 10, -16}, {60, -15, 15}, {20, -9, 0.09, 0}, {-4, -10, 2}, {-2, -8})
local stepForwardLeft = pose({-0.04, 0.01, -0.085, 6, 6, 1}, {46, 11, -16}, {56, -15, 15}, {-5, 18, 0, 0.09}, {-4, -5, -1}, {2, -4})
local stepBackRight = pose({0.04, 0, 0.05, -2, 10, -1}, {46, 11, -17}, {60, -15, 15}, {-17, 9, 0.08, 0}, {-1, -9, 1}, {-7, -7})
local stepBackLeft = pose({-0.04, 0.01, 0.065, -2, 6, 1}, {46, 11, -16}, {58, -15, 15}, {10, -18, 0, 0.08}, {-1, -5, -1}, {-6, -5})
local sideLoad = pose({-0.13, -0.10, 0.015, 4, 9, 6}, {49, 13, -16}, {64, -16, 18}, {9, -8}, {-1, -8, -3}, {-5, -11})
local sideCatch = pose({0.14, -0.065, -0.035, 6, 13, -5}, {52, 14, -18}, {65, -16, 19}, {10, -7}, {-3, -11, 3}, {1, 6})

local shuffleLead = groundedPose({.075, -.12, .025, 5, 9, -5}, {49, 11, -13}, {62, -15, 13},
	{7, -7, 15, 0, 0, 0, .16}, {4, 6, -9, 0, 0, 0, .025}, {-3, -8, 4}, {1, -12})
local shuffleTransfer = groundedPose({.04, -.15, .025, 6, 8, -2}, {50, 13, -16}, {61, -16, 17},
	{6, -5, 17, 0, 0, 0, .025}, {-3, 6, -17, 0, 0, 0, .025}, {-3, -7, 2}, {2, -10})
local shuffleTrail = groundedPose({-.065, -.09, .015, 4, 8, 5}, {47, 10, -13}, {63, -17, 15},
	{5, -5, -4, 0, 0, 0, .025}, {9, 8, -14, 0, 0, 0, .13}, {-2, -7, -4}, {-2, 6})

local saluteLoad = pose({0, -0.11, 0, 8, 11, -1}, {42, 12, -15}, {60, -15, 16}, {9, -8}, {5, -10, 0}, {-4, -7})
local salute = pose({0.02, 0.025, 0, 1, 7, -2}, {88, 24, -22, 0.02}, {51, -15, 12}, {7, -6}, {-4, -6, 2}, {0, -4})
local saluteNod = pose({0.02, -0.04, 0, 5, 7, -2}, {88, 24, -22, 0.02}, {51, -15, 12}, {9, -7}, {11, -6, 2}, {-4, -4})
local winRaise = pose({0.05, 0.07, 0.025, -7, 13, -4}, {119, 7, -16, 0.04}, {67, -15, 14}, {7, -8}, {-5, -11, 4}, {6, -9})
local winHold = pose({0.035, 0.045, 0.025, -4, 9, -2}, {108, 10, -15, 0.025}, {55, -14, 12}, {7, -6}, {-2, -8, 2}, {2, -5})

-- Lantern Break shows both raised gauntlets before the single paired strike.
local lanternBrace = groundedPose({0, -.23, .055, 12, 3, 0}, {55, 10, -17}, {61, -12, 16},
	rearBoot, leadBoot, {-5, -3, 0}, {-19, -4})
local lanternRaise = groundedPose({0, -.13, .08, 3, 0, 0}, {151, 5, 17, .06, -.04, .015}, {153, -5, -17, -.06, -.04, .015},
	rearBoot, leadBoot, {4, 0, 0}, {-14, 0})
local lanternFold = groundedPose({0, -.56, -.13, 28, 0, 0}, {72, 8, 10, .055, -.115, -.09}, {72, -8, -10, -.055, -.115, -.09},
	rearBoot, leadBoot, {-2, 0, 0}, {-71, 0})
local lanternHit = groundedPose({0, -1.25, -.50, 69, 0, 0}, {-30, 1, 9, .037, 0, .198}, {-30, -1, -9, -.037, 0, .198},
	rearBoot, leadBoot, {-36, 0, 0}, {-130, 0})
local lanternRebound = groundedPose({0, -.66, -.20, 41, 0, 0}, {8, 7, 8, .045, -.055, -.14}, {8, -7, -8, -.045, -.055, -.14},
	rearBoot, leadBoot, {-21, 0, 0}, {-79, 0})
local lanternRecover = groundedPose({0, -.24, -.11, 14, 4, -1}, {50, 11, -16}, {60, -15, 15},
	rearBoot, leadBoot, {-6, -4, 1}, {-13, -5})

-- A low left mitt and a delayed straight right each have their own contact.
local festivalDraw = groundedPose({-.055, -.23, .04, 10, 25, 7}, {59, 15, -19}, {32, -5, 13, 0, -.025, .025},
	rearBoot, leadBoot, {-7, -22, -4}, {-17, -18})
local festivalLeft = groundedPose({-.065, -.25, -.33, 12, -20, 5}, {60, 19, -20}, {57, -13, 22, -.008, -.035, -.20},
	rearBoot, leadBoot, {-8, 18, -4}, {-14, 20})
local festivalSwitch = groundedPose({.045, -.17, -.11, 8, -14, -5}, {30, 5, -20, .005, -.035, .06}, {58, -19, 24, 0, .005, -.03},
	rearBoot, leadBoot, {-6, 13, 4}, {-14, 15})
local festivalCoil = groundedPose({.095, -.18, -.035, 5, -27, -8}, {28, 7, -16, .015, 0, .08}, {64, -19, 20},
	rearBoot, leadBoot, {-4, 24, 5}, {-13, 23})
local festivalRight = groundedPose({.075, -.16, -.36, 8, 24, -4}, {81, 13, -22, 0, .04, -.22}, {63, -19, 22},
	rearBoot, leadBoot, {-7, -22, 3}, {-12, -19})
local festivalFollow = groundedPose({.08, -.21, -.25, 13, 27, -6}, {67, 14, -21, 0, .018, -.12}, {63, -20, 22},
	rearBoot, leadBoot, {-9, -24, 4}, {-17, -24})
local festivalRecover = groundedPose({.035, -.12, -.09, 7, 13, -3}, {50, 11, -17}, {60, -15, 18},
	rearBoot, leadBoot, {-6, -11, 2}, {-11, -11})

local uppercutContactAt = 0.285
local kickContactAt = .30
local sweepContactAt = .35
local heelContactAt = .48
local checkContactAt = .17
local toeContactAt = .25
local lanternContactAt = .62
local festivalContacts = table.freeze({.31, .64})
local shuffleDuration = .50
local shuffleStride = 1.40
local groundedClips = {
	shuffle = {{0, guardedFeet}, {.125, shuffleLead}, {.25, shuffleTransfer}, {.375, shuffleTrail},
		{shuffleDuration, guardedFeet}},
}
local soleCenter = {
	[joints.rightLeg] = Vector3.new(.43, -mountedOrigin.Y, -.23),
	[joints.leftLeg] = Vector3.new(-.43, -mountedOrigin.Y, -.23),
}

local function bootPosition(offsets, joint)
	return (offsets.RootJoint * offsets[joint]):PointToWorldSpace(soleCenter[joint])
end

local function plantStandingBoots(offsets)
	local root = offsets.RootJoint
	for joint, center in soleCenter do
		local boot = root * offsets[joint]
		local position = boot:PointToWorldSpace(center)
		local forward = boot.LookVector
		local level = CFrame.lookAt(position, position + Vector3.new(forward.X, 0, forward.Z))
		offsets[joint] = root:ToObjectSpace(level * CFrame.new(-center))
	end
	return groundedRig.plantFeet(offsets, .003)
end

local sweepReady = plantStandingBoots(table.clone(ready))
groundedClips.body = {{0, sweepReady}, {.11, kickLoad}, {.22, kickChamber}, {kickContactAt, kickContact},
	{.382, kickRetract}, {.49, kickPlant}, {.56, sweepReady}}
groundedClips.reedSweep = {{0, sweepReady}, {.120, sweepLoad}, {.225, sweepChamber}, {sweepContactAt, sweepContact},
	{.455, sweepWithdraw}, {.600, sweepSettle}, {.740, sweepReady}}
groundedClips.reedstoneHeel = {{0, sweepReady}, {.125, heelLoad}, {.265, heelLift}, {.365, heelChamber},
	{heelContactAt, heelStrike}, {.55, heelFollow}, {.675, heelRetract}, {.825, heelSettle}, {.96, sweepReady}}
groundedClips.reedCheck = {{0, sweepReady}, {.059, checkLoad}, {checkContactAt, checkHit},
	{.248, checkFold}, {.40, sweepReady}}
groundedClips.courtyardToe = {{0, sweepReady}, {.105, toeLoad}, {toeContactAt, toeHit},
	{.334, toeTuck}, {.414, toeReturn}, {.51, sweepReady}}
groundedClips.lanternBreak = {{0, sweepReady}, {.15, lanternBrace}, {.32, lanternRaise}, {.425, lanternRaise},
	{.525, lanternFold}, {lanternContactAt, lanternHit}, {.665, lanternHit}, {.765, lanternRebound},
	{1.04, lanternRecover}, {1.26, sweepReady}}
groundedClips.festivalCross = {{0, sweepReady}, {.14, festivalDraw}, {festivalContacts[1], festivalLeft},
	{.414, festivalSwitch}, {.50, festivalCoil}, {festivalContacts[2], festivalRight}, {.745, festivalFollow},
	{.91, festivalRecover}, {1.12, sweepReady}}
local floorClips = groundedRig.finish(groundedClips, {}, {}, {}, {}, {"shuffle"})

local function placeBoot(offsets, joint, position)
	local delta = position - bootPosition(offsets, joint)
	local localDelta = offsets.RootJoint:VectorToObjectSpace(Vector3.new(delta.X, 0, delta.Z))
	offsets[joint] = CFrame.new(localDelta) * offsets[joint]
end

local bootHome = {
	[joints.rightLeg] = bootPosition(guardedFeet, joints.rightLeg),
	[joints.leftLeg] = bootPosition(guardedFeet, joints.leftLeg),
}

local function sampleShuffle(ageSeconds, direction)
	local age = math.max(ageSeconds or 0, 0) % shuffleDuration
	local offsets = floorClips.sample("shuffle", age, direction)
	local phase = age / shuffleDuration
	local firstStep = phase < .5
	local swing = (phase * 2) % 1
	local weight = swing * swing * (3 - 2 * swing)
	local distance = direction * shuffleStride
	local lead, trail = joints.rightLeg, joints.leftLeg
	if direction < 0 then
		lead, trail = trail, lead
	end
	-- The lead boot opens the stance, then holds while the other boot catches up.
	-- Subtract the root's nominal travel to keep the support boot over its mark.
	local leadStep = (if firstStep then weight else 1) - phase
	local trailStep = (if firstStep then 0 else weight) - phase
	placeBoot(offsets, lead, bootHome[lead] + Vector3.new(leadStep * distance, 0, 0))
	placeBoot(offsets, trail, bootHome[trail] + Vector3.new(trailStep * distance, 0, 0))
	return offsets
end

local clips = {
	stance = {{0, ready}, {0.63, breathing}, {1.30, ready}},
	advance = {{0, ready}, {0.16, stepForwardRight}, {0.31, ready}, {0.47, stepForwardLeft}, {0.62, ready}},
	retreat = {{0, ready}, {0.17, stepBackRight}, {0.33, ready}, {0.50, stepBackLeft}, {0.66, ready}},
	sidestep = {{0, ready}, {0.10, sideLoad}, {0.22, sideCatch}, {0.42, ready}},
	jab = {{0, ready}, {0.075, jabLoad}, {0.18, jabContact}, {0.26, jabRetract}, {0.43, ready}},
	cross = {{0, ready}, {0.105, crossLoad}, {0.23, crossContact}, {0.32, crossRetract}, {0.54, ready}},
	uppercut = {{0, ready}, {0.14, uppercutLoad}, {0.22, uppercutDrive}, {uppercutContactAt, uppercutContact}, {0.38, uppercutRetract}, {0.60, ready}},
	heavy = {{0, ready}, {0.23, heavyLoad}, {0.33, heavyDrive}, {0.42, heavyContact}, {0.53, heavyFollow}, {0.82, ready}},
	reedstep = {{0, ready}, {0.125, risingLoad}, {0.23, risingBody}, {0.31, risingSwitch}, {0.42, risingCross}, {0.54, risingCoil}, {0.67, risingFinish}, {0.84, risingSettle}, {1.13, ready}},
	guard = {{0, guard}},
	block = {{0, covering}, {0.07, covering}, {0.24, guard}},
	parry = {{0, parryCatch}, {0.07, parrySweep}, {0.19, parryReturn}, {0.36, ready}},
	hitHead = {{0, headFlinch}, {0.09, headRecoil}, {0.20, headFlinch}, {0.37, ready}},
	hitBody = {{0, bodyFlinch}, {0.105, bodyRecoil}, {0.23, brace}, {0.42, ready}},
	stagger = {{0, headFlinch}, {0.13, stumble}, {0.34, brace}, {0.65, ready}},
	salute = {{0, ready}, {0.16, saluteLoad}, {0.43, salute}, {0.79, salute}, {1.12, ready}},
	intro = {{0, ready}, {1.1, breathing}, {2.3, ready}, {2.58, saluteLoad}, {2.99, salute},
		{3.44, saluteNod}, {3.77, salute}, {4.40, ready}, {5.75, breathing}, {7.0, ready},
		{7.85, guard}, {8.26, ready}, {9.10, breathing}, {10, ready}},
	win = {{0, ready}, {0.17, saluteLoad}, {0.45, winRaise}, {0.68, winHold}, {0.92, winRaise}, {1.42, winHold}, {1.88, ready}},
}

local looping = { stance = true, advance = true, retreat = true }
-- Keep the boots level with the mat through grounded punches and reactions.
local planted = {
	stance = true, guard = true, block = true, parry = true,
	hitHead = true, hitBody = true, stagger = true,
	jab = true, cross = true, uppercut = true, heavy = true, reedstep = true,
	sidestep = true,
	salute = true, intro = true, win = true,
}
local durations = {body = floorClips.Duration.body, reedSweep = floorClips.Duration.reedSweep,
	reedstoneHeel = floorClips.Duration.reedstoneHeel,
	reedCheck = floorClips.Duration.reedCheck, courtyardToe = floorClips.Duration.courtyardToe,
	lanternBreak = floorClips.Duration.lanternBreak, festivalCross = floorClips.Duration.festivalCross,
	strafeLeft = shuffleDuration, strafeRight = shuffleDuration}
for action, frames in pairs(clips) do
	durations[action] = frames[#frames][1]
end

Poses.Duration = table.freeze(durations)
Poses.StrafeStepDistance = shuffleStride
Poses.Contact = table.freeze({
	jab = 0.18,
	cross = 0.23,
	body = kickContactAt,
	reedSweep = sweepContactAt,
	reedstoneHeel = heelContactAt,
	reedCheck = checkContactAt,
	courtyardToe = toeContactAt,
	lanternBreak = lanternContactAt, festivalCross = festivalContacts,
	uppercut = uppercutContactAt,
	heavy = 0.42,
	reedstep = table.freeze({0.23, 0.42, 0.67}),
})

-- Centers of the contact surfaces sampled on the original mesh at each
-- contact frame, relative to the unanimated HumanoidRootPart. These positions
-- already include the limb and RootJoint offsets from the pose.
Poses.BodyKickBootPoint = Vector3.new(.2036, -1.373, -.719)
local bootContact = rightHipPivot + artOrigin - mountedOrigin + Poses.BodyKickBootPoint
-- Outer toe vertex on the fitted left boot, relative to its hip pivot.
local sweepBootPad = Vector3.new(-.2036, -1.373, -.719)
local sweepPoint = leftHipPivot + artOrigin - mountedOrigin + sweepBootPad
-- Rear outsole vertex on the fitted right boot, relative to its hip pivot.
local heelBootPad = Vector3.new(.181279540, -1.394000053, .308999985)
local heelPoint = rightHipPivot + artOrigin - mountedOrigin + heelBootPad
local heelSupport = sweepReady.RootJoint * sweepReady[joints.leftLeg]
local sweepSupport = sweepReady.RootJoint * sweepReady[joints.rightLeg]
-- Points are fitted to the visible padding and left boot toe in the shipped shell.
local checkPad = Vector3.new(-1.285499453, 1.460358978, -.640155733) - mountedOrigin
local toePad = Vector3.new(-.641870856, .017307400, -.789945006) - mountedOrigin
Poses.Skill = table.freeze({
	reedCheck = table.freeze({damage = 11, radius = .42}),
	courtyardToe = table.freeze({damage = 14, radius = .47, foot = true}),
})
local function glovePoint(key, joint, point)
	return (key.RootJoint * key[joint]):PointToWorldSpace(point)
end

-- Exact fitted surface points in the unposed mount frame; hands share one floor hit.
local lanternRightHand = Vector3.new(.905362455, -.664518336, -.088014749)
local lanternLeftHand = Vector3.new(-.905362512, -.664518336, -.088014489)
local festivalLeftMitt = Vector3.new(-1.316013487, -.671438435, -.551284544)
local festivalRightMitt = Vector3.new(1.284692133, -.672629336, -.159515871)
local lanternHands = table.freeze({
	glovePoint(lanternHit, joints.rightArm, lanternRightHand),
	glovePoint(lanternHit, joints.leftArm, lanternLeftHand),
})
local lanternCenter = lanternHands[1]:Lerp(lanternHands[2], .5)
lanternCenter = Vector3.new(lanternCenter.X, -mountedOrigin.Y, lanternCenter.Z)
Poses.UltimateSkill = table.freeze({
	lanternBreak = table.freeze({damage = 29, center = lanternCenter, radius = 2.45, warningAt = .23}),
	festivalCross = table.freeze({damage = table.freeze({12, 21}), radius = table.freeze({.45, .47})}),
})
Poses.Impact = table.freeze({
	jab = table.freeze({Vector3.new(0.264, 0.595, -1.828)}),
	cross = table.freeze({Vector3.new(-0.196, 0.361, -1.925)}),
	body = table.freeze({(kickContact.RootJoint * kickContact[joints.rightLeg]):PointToWorldSpace(bootContact)}),
	reedstoneHeel = table.freeze({(heelStrike.RootJoint * heelStrike[joints.rightLeg]):PointToWorldSpace(heelPoint)}),
	lanternBreak = table.freeze({lanternCenter}),
	festivalCross = table.freeze({
		glovePoint(festivalLeft, joints.leftArm, festivalLeftMitt),
		glovePoint(festivalRight, joints.rightArm, festivalRightMitt),
	}),
	reedSweep = table.freeze({(sweepContact.RootJoint * sweepContact[joints.leftLeg]):PointToWorldSpace(sweepPoint)}),
	reedCheck = table.freeze({(checkHit.RootJoint * checkHit[joints.leftArm]):PointToWorldSpace(checkPad)}),
	courtyardToe = table.freeze({(toeHit.RootJoint * toeHit[joints.leftLeg]):PointToWorldSpace(toePad)}),
	uppercut = table.freeze({Vector3.new(0.432, 0.861, -1.896)}),
	heavy = table.freeze({Vector3.new(-0.081, 0.323, -2.064)}),
	reedstep = table.freeze({Vector3.new(0.139, -0.067, -2.001), Vector3.new(-0.187, 0.317, -2.000), Vector3.new(0.306, 0.764, -2.015)}),
})

function Poses.sample(action, ageSeconds)
	if action == "body" then
		local offsets = floorClips.sample(action, ageSeconds)
		offsets[joints.leftLeg] = offsets.RootJoint:ToObjectSpace(heelSupport)
		return offsets
	elseif action == "reedSweep" then
		local offsets = floorClips.sample(action, ageSeconds)
		-- Hold the full support leg frame while the torso turns over it.
		offsets[joints.rightLeg] = offsets.RootJoint:ToObjectSpace(sweepSupport)
		return offsets
	elseif action == "reedstoneHeel" then
		local offsets = floorClips.sample(action, ageSeconds)
		offsets[joints.leftLeg] = offsets.RootJoint:ToObjectSpace(heelSupport)
		return offsets
	elseif action == "reedCheck" or action == "courtyardToe" or action == "lanternBreak" or action == "festivalCross" then
		local offsets = floorClips.sample(action, ageSeconds)
		offsets[joints.rightLeg] = offsets.RootJoint:ToObjectSpace(sweepSupport)
		if action ~= "courtyardToe" then
			offsets[joints.leftLeg] = offsets.RootJoint:ToObjectSpace(heelSupport)
		end
		return offsets
	elseif action == "strafeLeft" or action == "strafeRight" then
		return sampleShuffle(ageSeconds, if action == "strafeLeft" then -1 else 1)
	end
	action = clips[action] and action or "stance"
	local frames = clips[action]
	local duration = durations[action]
	local age = math.max(ageSeconds or 0, 0)
	if looping[action] then
		age %= duration
	end

	local offsets
	for index = 2, #frames do
		local finish = frames[index]
		if age <= finish[1] then
			local start = frames[index - 1]
			local progress = (age - start[1]) / (finish[1] - start[1])
			local weight = progress * progress * (3 - 2 * progress)
			offsets = {}
			for jointName, offset in pairs(start[2]) do
				offsets[jointName] = offset:Lerp(finish[2][jointName], weight)
			end
			break
		end
	end

	offsets = offsets or table.clone(frames[#frames][2])
	return if planted[action] then plantStandingBoots(offsets) else offsets
end

return table.freeze(Poses)
