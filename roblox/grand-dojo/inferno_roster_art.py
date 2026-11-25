"""Original rigid art for the two Cinder Terraces contenders."""

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _grizzly(art):
    walnut, cinnamon, honey, umber = "7C4935", "A66848", "C78F64", "553729"
    soot, obsidian, slate = "29232A", "38313D", "5B5159"
    brass, ochre, ember, flame = "BB8952", "98623E", "BD5033", "E59147"
    leather, binding, ink, ivory = "704130", "AC744E", "211B20", "F2D7A8"

    torso = art.group("Torso", (0, 2.38, .09), (2.70, 2.36, 2.18))
    art.detail(torso, "Broad walnut bear body", (0, 2.46, .07), (2.53, 2.12, 1.81), walnut)
    art.detail(torso, "Cinnamon bib fur", (0, 2.72, -.535), (1.65, 1.32, .612), cinnamon, pitch=-8)
    art.detail(torso, "Honey throat crescent", (0, 3.146, -.447), (1.007, .52, .667), honey, pitch=-12)
    art.detail(torso, "Heavy dark wrestling trunks", (0, 1.837, .074), (2.32, .806, 1.65), soot, material=FABRIC)
    art.detail(torso, "Broad forge-leather belt", (0, 1.866, .044), (2.426, .304, 1.775), leather, material=FABRIC)
    art.detail(torso, "Gilt kiln plate on belt", (0, 1.865, -.845), (.587, .378, .171), brass)
    art.detail(torso, "Dark inset under kiln crest", (0, 1.861, -.934), (.397, .260, .069), soot)
    art.detail(torso, "Copper fire taper on kiln crest", (0, 1.865, -.974), (.102, .166, .030), flame, roll=24)
    art.detail(torso, "Leather back pad", (0, 2.68, .895), (.886, 1.025, .216), leather, material=FABRIC)
    art.detail(torso, "Copper backplate chevron", (0, 2.77, 1.024), (.518, .072, .027), ochre, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(torso, "Crossed forge vest edge", (sign * .77, 2.629, -.551),
                   (.343, 1.438, .368), leather, roll=sign * -17, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Brocade facing on forge leather", (sign * .785, 2.665, -.746),
                   (.075, 1.221, .111), binding, roll=sign * -17, yaw=sign * -15, shape=BLOCK)
        art.detail(torso, "Laced leather hip shield", (sign * .78, 1.651, -.589),
                   (.698, .589, .468), leather, roll=sign * 17, yaw=sign * -12, material=FABRIC)
        art.detail(torso, "Copper rivet on hip shield", (sign * .88, 1.711, -.817),
                   (.13, .126, .066), brass, yaw=sign * -17)

    head = art.group("Head", (0, 4.133, -.216), (2.27, 1.88, 2.00), (0, 3.29, -.04))
    art.detail(head, "Blocky round grizzly crown", (0, 4.111, -.02), (1.806, 1.51, 1.274), walnut)
    art.detail(head, "Short broad bear muzzle", (0, 3.883, -.653), (1.181, .722, .996), cinnamon, pitch=8)
    art.detail(head, "Rounded cheek-side muzzle pad", (0, 3.859, -.885), (.969, .540, .499), honey)
    art.detail(head, "Broad convex bear nose", (0, 4.001, -1.077), (.527, .251, .235), ink, pitch=9)
    art.detail(head, "Warm bridge highlight", (-.078, 4.062, -1.177), (.240, .077, .057), umber, pitch=7)
    art.detail(head, "Closed pursed mouth", (0, 3.717, -1.096), (.581, .064, .094), umber)
    art.detail(head, "Lower cheek fur", (0, 3.680, -.639), (.976, .456, .796), cinnamon)
    for sign in (-1, 1):
        art.detail(head, "Round grizzly ear", (sign * .761, 4.755, .12), (.714, .612, .558), umber, roll=sign * 13)
        art.detail(head, "Warm rounded ear rim", (sign * .767, 4.765, -.048), (.570, .490, .360), walnut, roll=sign * 13)
        art.detail(head, "Warm grizzly ear cup", (sign * .776, 4.761, -.207), (.350, .295, .124), cinnamon, roll=sign * 13)
        art.detail(head, "Plump grizzly cheek", (sign * .633, 3.932, -.345), (.740, .770, .801), walnut, roll=sign * 12)
        art.detail(head, "Warm grizzly brow ridge", (sign * .465, 4.257, -.555), (.556, .431, .391), umber, roll=sign * 13)
        art.detail(head, "Soft cream bear eye", (sign * .490, 4.250, -.726), (.361, .269, .157), ivory, yaw=sign * -18, roll=sign * 12)
        art.detail(head, "Round dark bear pupil", (sign * .482, 4.231, -.796), (.172, .188, .068), ink, yaw=sign * -18)
        art.detail(head, "Catchlight on bear pupil", (sign * .482 - .033, 4.274, -.828), (.049, .046, .027), ivory)
        art.detail(head, "Steady straight grizzly brow", (sign * .447, 4.387, -.723), (.478, .119, .168), umber, yaw=sign * -17, roll=sign * 16)
        art.detail(head, "Small upturned mouth corner", (sign * .285, 3.743, -1.076), (.199, .058, .077), umber, yaw=sign * -8, roll=sign * 18)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.409, 2.45, -.239),
                        (1.27, 1.93, 1.70), (sign * 1.23, 3.13, .025))
        art.detail(arm, "Hulking upper bear arm", (sign * 1.410, 2.857, .076), (1.09, 1.08, 1.053), walnut, roll=sign * 12)
        art.detail(arm, "Hammered brass shoulder pad", (sign * 1.502, 3.000, .078),
                   (1.013, .686, 1.04), ochre, roll=sign * 19)
        art.detail(arm, "Warm leading rim on shoulder pad", (sign * 1.510, 2.987, -.371),
                   (.748, .334, .270), brass, roll=sign * 19)
        art.detail(arm, "Dark rounded forearm guard", (sign * 1.435, 2.207, -.325),
                   (1.05, 1.092, 1.012), soot, pitch=-15, roll=sign * 8)
        art.detail(arm, "Obsidian armor forearm slab", (sign * 1.48, 2.306, -.608),
                   (.904, .731, .493), obsidian, pitch=-11, roll=sign * 10)
        art.detail(arm, "Muted slate plane on forearm slab", (sign * 1.484, 2.464, -.811),
                   (.460, .276, .075), slate, pitch=-11, roll=sign * 10)
        art.detail(arm, "Upper copper boundary on wrist", (sign * 1.421, 2.192, -.384),
                   (.078, .974, .946), ochre, roll=90 + sign * 9, shape=CYLINDER)
        art.detail(arm, "Slanting magma seam", (sign * 1.486, 2.247, -.865),
                   (.071, .366, .052), ember, shape=BLOCK, roll=sign * 28)
        art.detail(arm, "Bright center of magma seam", (sign * 1.521, 2.175, -.892),
                   (.040, .161, .031), flame, shape=BLOCK, roll=sign * 28)
        art.detail(arm, "Rounded obsidian boxing glove", (sign * 1.414, 1.915, -.642),
                   (.965, .672, .552), obsidian)
        art.detail(arm, "Grizzly striking pad", (sign * 1.40, 1.89, -.894), (.66, .36, .13), brass)
        art.detail(arm, "Round leather thumb pad", (sign * 1.075, 1.934, -.741),
                   (.327, .355, .369), leather, roll=sign * 15)

        leg = art.group(f"{side} Leg", (sign * .55, .789, -.177),
                        (1.153, 1.562, 1.446), (sign * .55, 1.48, .06))
        art.detail(leg, "Bear haunch in padded trunks", (sign * .576, 1.069, .064),
                   (1.052, .969, .940), soot, roll=sign * -10, material=FABRIC)
        art.detail(leg, "Heavy lower bear leg", (sign * .577, .629, -.082),
                   (.842, .922, .787), walnut, roll=sign * 10, pitch=9)
        art.detail(leg, "Calf boot gaiter", (sign * .583, .463, -.128),
                   (.842, .653, .787), leather, pitch=9, roll=sign * 6, material=FABRIC)
        art.detail(leg, "Brass boot clasp", (sign * .635, .508, -.516), (.277, .122, .108), brass, roll=sign * 5)
        art.detail(leg, "Flat grizzly boot sole", (sign * .55, .070, -.350), (.750, .116, 1.04), ink, shape=BLOCK)
        art.detail(leg, "Raised toes of bear boot", (sign * .55, .258, -.390), (.840, .445, .875), obsidian)
        art.detail(leg, "Bulbous copper toe cap", (sign * .55, .221, -.816), (.674, .237, .162), ochre)
        art.detail(leg, "Copper edge stitch", (sign * .55, .101, -.793), (.686, .048, .087), binding)

    tail = art.group("Tail", (0, 1.87, .961), (.70, .685, .674), (0, 1.84, .79))
    art.detail(tail, "Small grizzly tail", (0, 1.866, .918), (.662, .594, .583), umber, pitch=17)
    art.detail(tail, "Walnut tail cap", (0, 1.923, 1.049), (.480, .453, .441), walnut, pitch=14)


def _hellhound(art):
    charcoal, cinder, muzzle, shadow = "322B3E", "514459", "8E7483", "272330"
    plum, violet, trim, smoke = "493252", "674668", "82617F", "A183A0"
    ember, gold, ember_dark, ink, cream = "CC6246", "E9A55E", "8D4850", "221E29", "FFE1AA"

    torso = art.group("Torso", (0, 2.497, .024), (1.83, 2.36, 1.94))
    art.detail(torso, "Long charcoal canine body", (0, 2.464, .037), (1.648, 1.970, 1.34), charcoal, pitch=-5)
    art.detail(torso, "Tapered purple fight jacket", (0, 2.367, .018), (1.703, 1.746, 1.401), plum, material=FABRIC)
    art.detail(torso, "Smoke-gray bib fur", (0, 2.886, -.403), (1.128, 1.123, .605), cinder, pitch=-10)
    art.detail(torso, "Warm slash of throat fur", (0, 3.147, -.435), (.729, .541, .592), muzzle, pitch=-14)
    art.detail(torso, "Obsidian rope sash", (0, 1.831, .027), (1.715, .299, 1.359), shadow, material=FABRIC)
    art.detail(torso, "Knotted plum sash wrap", (.314, 1.817, -.628), (.466, .324, .333), violet, roll=19, material=FABRIC)
    art.detail(torso, "Ember ribbon end", (.359, 1.568, -.619), (.124, .479, .097), ember_dark, roll=18, shape=BLOCK, material=FABRIC)
    art.detail(torso, "Copper sash knot tip", (.399, 1.772, -.782), (.191, .099, .051), gold, roll=19)
    art.detail(torso, "Smoke mantle wedge", (0, 2.923, .493), (.963, 1.089, .662), charcoal, pitch=19, class_name="WedgePart")
    art.detail(torso, "Copper fold across upper back", (0, 2.942, .763), (.567, .068, .065), ember_dark, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(torso, "Purple pointed jacket lapel", (sign * .445, 2.716, -.496),
                   (.391, 1.159, .293), violet, roll=sign * -23, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Copper line on pointed lapel", (sign * .535, 2.673, -.654),
                   (.066, .983, .079), ember, roll=sign * -23, yaw=sign * -15, shape=BLOCK)
        art.detail(torso, "Side hip flap", (sign * .511, 1.65, -.343),
                   (.475, .665, .542), plum, roll=sign * 12, material=FABRIC)
        art.detail(torso, "Pale plum hip stitch", (sign * .581, 1.556, -.580),
                   (.153, .082, .073), trim, roll=sign * -14)

    head = art.group("Head", (0, 4.043, -.302), (1.87, 2.38, 2.31), (0, 3.13, -.045))
    art.detail(head, "Lean canine skull", (0, 3.982, -.044), (1.412, 1.416, 1.067), charcoal, pitch=-12)
    art.detail(head, "Strong charcoal cheek planes", (0, 3.691, -.244), (1.478, .868, 1.05), cinder, pitch=2)
    art.detail(head, "Long tapered canine muzzle bridge", (0, 3.816, -.750),
               (.831, .549, 1.143), cinder, pitch=10)
    art.detail(head, "Narrow smoke muzzle tip", (0, 3.730, -1.089), (.583, .351, .609), muzzle, pitch=8)
    art.detail(head, "Canine lower jaw", (0, 3.514, -.768), (.668, .288, 1.014), muzzle, pitch=6)
    art.detail(head, "Obsidian canine nose", (0, 3.797, -1.339), (.425, .247, .214), ink, pitch=11)
    art.detail(head, "Warm nose highlight", (-.061, 3.835, -1.430), (.158, .059, .031), trim, pitch=9)
    art.detail(head, "Narrow smile under the snout", (0, 3.605, -1.188), (.497, .056, .199), shadow, pitch=8)
    art.detail(head, "Copper brow center", (0, 4.216, -.567), (.160, .335, .102), ember_dark, roll=-10)
    for sign in (-1, 1):
        art.detail(head, "Triangular outer canine ear", (sign * .565, 4.597, .039),
                   (.440, 1.171, .664), charcoal, roll=sign * 22, yaw=sign * -90, class_name="WedgePart")
        art.detail(head, "Inside of pointed vulcan ear", (sign * .556, 4.608, -.187),
                   (.154, .840, .407), trim, roll=sign * 22, yaw=sign * -90, class_name="WedgePart")
        art.detail(head, "Round ear root", (sign * .523, 4.282, .040), (.599, .644, .504), cinder, roll=sign * 13)
        art.detail(head, "Taper on canine cheek", (sign * .598, 3.651, -.161),
                   (.380, .603, .725), charcoal, pitch=-18, roll=sign * 22)
        art.detail(head, "Raised smoke brow ridge", (sign * .385, 4.076, -.553),
                   (.537, .393, .339), shadow, yaw=sign * -21, roll=sign * 13)
        art.detail(head, "Warm yellow canine eye", (sign * .397, 4.057, -.705),
                   (.360, .251, .120), gold, yaw=sign * -25, roll=sign * 12)
        art.detail(head, "Dark oval canine pupil", (sign * .382, 4.044, -.763),
                   (.142, .156, .061), ink, yaw=sign * -22, roll=sign * 5)
        art.detail(head, "Warm canine catchlight", (sign * .374 - .022, 4.087, -.795), (.043, .040, .024), cream)
        art.detail(head, "Angled shade above canine eye", (sign * .382, 4.179, -.676),
                   (.453, .102, .122), charcoal, yaw=sign * -23, roll=sign * 19)
        art.detail(head, "Ember line on outer cheek", (sign * .564, 3.852, -.658),
                   (.205, .058, .071), ember_dark, roll=sign * -25, yaw=sign * -31)
        art.detail(head, "Soft wide smile corner", (sign * .284, 3.626, -1.088),
                   (.173, .045, .123), shadow, yaw=sign * -30, roll=sign * 11)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.033, 2.431, -.160),
                        (.974, 1.673, 1.434), (sign * .85, 2.99, .02))
        art.detail(arm, "Lean shoulder of the hellhound", (sign * .988, 2.786, .078),
                   (.813, .808, .784), charcoal, roll=sign * 14)
        art.detail(arm, "Fitted smoky purple shoulder pauldron", (sign * 1.035, 2.831, -.037),
                   (.759, .553, .796), violet, roll=sign * 23)
        art.detail(arm, "Copper shoulder stud", (sign * 1.113, 2.843, -.425),
                   (.204, .192, .076), gold, roll=sign * 21)
        art.detail(arm, "Slim forearm over charcoal fur", (sign * 1.047, 2.361, -.165),
                   (.737, 1.015, .685), cinder, pitch=-13, roll=sign * 9)
        art.detail(arm, "Long black volcanic wrist wrap", (sign * 1.062, 2.180, -.351),
                   (.765, .722, .673), shadow, pitch=-14, roll=sign * 8, material=FABRIC)
        art.detail(arm, "Burnished copper wrist band", (sign * 1.061, 2.272, -.339),
                   (.074, .764, .722), ember_dark, roll=90 + sign * 9, shape=CYLINDER)
        art.detail(arm, "Ember wrist slash", (sign * 1.107, 2.177, -.681),
                   (.067, .368, .073), ember, roll=sign * 20, shape=BLOCK)
        art.detail(arm, "Compact purple canine glove", (sign * 1.028, 1.963, -.566), (.730, .514, .445), plum)
        art.detail(arm, "Hellhound striking pad", (sign * 1.01, 1.931, -.76), (.49, .27, .120), ember)
        art.detail(arm, "Rounded plum glove thumb", (sign * .794, 1.970, -.619),
                   (.263, .254, .296), violet, roll=sign * 13)

        leg = art.group(f"{side} Leg", (sign * .435, .814, -.172),
                        (.846, 1.621, 1.36), (sign * .435, 1.53, .04))
        art.detail(leg, "Slim tapered purple fight trousers", (sign * .439, 1.110, .05),
                   (.781, .982, .819), plum, roll=sign * -8, material=FABRIC)
        art.detail(leg, "Tailored purple kneepad", (sign * .441, .834, -.168),
                   (.617, .596, .525), violet, pitch=15, roll=sign * 8)
        art.detail(leg, "Lean charcoal shin", (sign * .449, .541, -.110),
                   (.519, .824, .600), charcoal, pitch=13, roll=sign * 8)
        art.detail(leg, "Copper ring above heel", (sign * .453, .438, -.144),
                   (.093, .532, .603), ember_dark, roll=90 + sign * 9, shape=CYLINDER)
        art.detail(leg, "Flat hellhound boot sole", (sign * .435, .058, -.285), (.56, .092, .98), ink, shape=BLOCK)
        art.detail(leg, "Tapered ash-purple boot", (sign * .435, .228, -.359), (.669, .388, .875), cinder)
        art.detail(leg, "Hellhound fitted toe", (sign * .435, .16, -.779), (.466, .153, .122), violet)
        art.detail(leg, "Copper seam on the upper boot", (sign * .435, .321, -.596), (.390, .069, .080), ember_dark, pitch=-12)

    tail = art.group("Tail", (0, 1.954, 1.238), (.66, 1.30, 1.60), (0, 1.80, .59))
    art.detail(tail, "Short rising black tail root", (0, 1.728, .898), (.524, .495, .942), charcoal, pitch=-17)
    art.detail(tail, "Lifted canine tail plume", (0, 1.933, 1.338), (.481, .579, .918), cinder, pitch=-34)
    art.detail(tail, "Plum tail silhouette", (0, 2.179, 1.589), (.414, .507, .634), plum, pitch=-53)
    art.detail(tail, "Ember highlight at tail tip", (0, 2.369, 1.745), (.299, .353, .484), ember_dark, pitch=-54)


def build_inferno_roster_visuals(library, *, item, part, prop, vector):
    """Build the grizzly and hellhound with native parts and fitted joints."""
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    _grizzly(_FighterArt(library, "magma-grizzly-bear", **helpers))
    _hellhound(_FighterArt(library, "obsidian-hellhound", **helpers))
