"""Original native fighter shells for the Skywalk Peaks contenders."""

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _eagle(art):
    bark, umber, bronze, amber = "633D2F", "483134", "9D5D39", "CA8C50"
    gold, ochre, cream, ink = "ECC175", "B07639", "FFDEAC", "33272B"
    pine, jade, spruce, peridot = "204846", "35675D", "284F4D", "81A182"

    torso = art.group("Torso", (0, 2.36, .015), (2.24, 2.23, 1.90))
    art.detail(torso, "Tawny eagle chest", (0, 2.42, .036), (1.97, 1.96, 1.48), bark)
    art.detail(torso, "Golden nape breast plume", (0, 2.929, -.366), (1.195, .777, .931), bronze, pitch=-7)
    art.detail(torso, "Amber shield of breast feathers", (0, 2.622, -.569), (1.232, .898, .558), amber, pitch=-9)
    art.detail(torso, "Deep green flight trousers", (0, 1.712, .025), (1.90, .642, 1.39), pine, material=FABRIC)
    art.detail(torso, "Jade harness sash", (0, 1.851, -.012), (2.012, .271, 1.523), jade, material=FABRIC)
    art.detail(torso, "Gilt atlas pin", (.095, 1.908, -.775), (.380, .341, .13), gold, shape=BLOCK, roll=45)
    art.detail(torso, "Weathered jade atlas inset", (.095, 1.91, -.849), (.207, .203, .047), spruce, shape=BLOCK, roll=45)
    art.detail(torso, "Folded green back harness", (0, 2.577, .670), (1.035, 1.163, .367), pine, material=FABRIC)
    art.detail(torso, "Gold brow of rear harness", (0, 3.027, .817), (.613, .108, .084), ochre)
    for sign in (-1, 1):
        art.detail(torso, "Diagonal spruce harness shoulder strap", (sign * .564, 2.655, -.530),
                   (.292, 1.297, .374), spruce, roll=sign * -19, yaw=sign * -10, material=FABRIC)
        art.detail(torso, "Trail-gold strap braid", (sign * .561, 2.658, -.715),
                   (.059, 1.063, .085), gold, roll=sign * -19, yaw=sign * -10, shape=BLOCK)
        art.detail(torso, "Low jade flight harness tab", (sign * .592, 1.601, -.498),
                   (.458, .591, .485), jade, roll=sign * 16, material=FABRIC)
        art.detail(torso, "Inlaid bronze harness stud", (sign * .716, 1.579, -.733), (.135, .136, .060), ochre)

    head = art.group("Head", (0, 4.064, -.190), (1.97, 1.73, 2.24), (0, 3.21, -.045))
    art.detail(head, "Swept umber eagle crown", (0, 3.996, .037), (1.552, 1.432, 1.351), bark, pitch=-7)
    art.detail(head, "Golden nape shield", (0, 4.191, .472), (1.321, 1.070, .620), amber, pitch=-23)
    art.detail(head, "Longer bronze nape plume", (0, 4.102, .624), (1.100, .927, .478), bronze, pitch=-25)
    art.detail(head, "Tawny cheek collar", (0, 3.563, -.131), (1.611, .665, 1.163), bronze, pitch=-13)
    art.detail(head, "Gold eagle cere", (0, 3.877, -.677), (.592, .435, .557), ochre, pitch=8)
    art.detail(head, "Gold wedge of eagle beak", (0, 3.808, -.897), (.511, .327, .488), gold, pitch=13)
    art.detail(head, "Downturned curved beak tip", (0, 3.690, -1.073), (.278, .318, .259), gold, pitch=19)
    art.detail(head, "Eagle mouth seam", (0, 3.672, -.941), (.341, .067, .272), umber, pitch=8)
    art.detail(head, "Gold highlight at beak bridge", (-.037, 3.906, -.968), (.226, .104, .113), cream, pitch=13)
    for sign in (-1, 1):
        art.detail(head, "Swept side nape quill", (sign * .627, 4.155, .353), (.411, .699, .614), amber,
                   pitch=-25, roll=sign * 26)
        art.detail(head, "Raked cheek feather", (sign * .593, 3.718, -.401), (.489, .492, .435), bronze,
                   pitch=-14, yaw=sign * -33, roll=sign * 31)
        art.detail(head, "Dark eagle ocular mask", (sign * .426, 4.037, -.560), (.604, .390, .432), umber,
                   yaw=sign * -29, roll=sign * 14)
        art.detail(head, "Gold raptor iris", (sign * .447, 4.014, -.750), (.362, .268, .147), cream,
                   yaw=sign * -30, roll=sign * 13)
        art.detail(head, "Warm amber iris center", (sign * .438, 4.007, -.818), (.210, .204, .069), gold, yaw=sign * -25)
        art.detail(head, "Focused eagle pupil", (sign * .425, 4.001, -.848), (.121, .150, .058), ink, yaw=sign * -24)
        art.detail(head, "Eagle eye sparkle", (sign * .423 - .027, 4.054, -.875), (.046, .043, .028), cream)
        art.detail(head, "Angled bronze brow feather", (sign * .436, 4.172, -.726), (.543, .140, .168), bark,
                   yaw=sign * -30, roll=sign * 19)
        art.detail(head, "Eagle nostril", (sign * .189, 3.87, -.929), (.093, .047, .045), umber, yaw=sign * -28)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.314, 2.466, .020),
                        (1.37, 1.88, 1.84), (sign * .94, 3.09, .03))
        art.detail(arm, "Tawny hooked shoulder plume", (sign * 1.141, 2.916, .111), (.912, .757, .92), bronze,
                   roll=sign * 16)
        art.detail(arm, "Gold shoulder covert", (sign * 1.257, 2.969, -.028), (.738, .439, .749), amber,
                   pitch=-11, roll=sign * 25)
        art.detail(arm, "Folded dark eagle wing", (sign * 1.303, 2.412, .238), (.886, 1.285, 1.053), bark,
                   pitch=-14, roll=sign * 15)
        for index, (x, y, z, length, angle) in enumerate((
                (1.20, 2.14, .296, 1.20, 18), (1.39, 2.179, .392, 1.244, 22),
                (1.56, 2.222, .453, 1.172, 26), (1.682, 2.300, .491, 1.045, 33)), 1):
            art.detail(arm, f"Fanned eagle primary feather {index}", (sign * x, y, z), (.293, length, .365),
                       umber if index % 2 == 0 else bark, pitch=-17, roll=sign * angle)
        art.detail(arm, "Spruce wrist gauntlet", (sign * 1.297, 2.174, -.341), (.682, .742, .692), pine,
                   material=FABRIC, pitch=-17, roll=sign * 10)
        art.detail(arm, "Worn gold wing cuff", (sign * 1.294, 2.163, -.411), (.097, .683, .691), ochre,
                   roll=90 + sign * 10, shape=CYLINDER)
        art.detail(arm, "Jade knuckle glove", (sign * 1.301, 1.983, -.56), (.660, .518, .438), jade)
        art.detail(arm, "Eagle wing strike pad", (sign * 1.30, 1.92, -.730), (.53, .35, .17), peridot)

        leg = art.group(f"{side} Leg", (sign * .49, .802, -.198),
                        (.884, 1.582, 1.39), (sign * .49, 1.51, .045))
        art.detail(leg, "Tapered dark eagle flight breeches", (sign * .49, 1.109, .032), (.786, .944, .828),
                   pine, roll=sign * -10, material=FABRIC)
        art.detail(leg, "Ochre low eagle hock", (sign * .493, .548, -.089), (.533, .826, .614),
                   ochre, pitch=13, roll=sign * 8)
        art.detail(leg, "Jade ankle brace", (sign * .487, .436, -.151), (.139, .609, .617),
                   jade, roll=90 + sign * 8, shape=CYLINDER, material=FABRIC)
        art.detail(leg, "Flat eagle boot sole", (sign * .49, .060, -.31), (.58, .096, 1.00), ink, shape=BLOCK)
        art.detail(leg, "Rounded forefoot in gold suede", (sign * .49, .216, -.376), (.632, .355, .779), ochre)
        for index, offset in enumerate((-.173, 0, .173), 1):
            art.detail(leg, "Eagle fitted talon" if index == 2 else f"Eagle side toe {index}",
                       (sign * .49 + offset, .173, -.775 + abs(offset) * .195), (.153, .186, .175), gold,
                       yaw=-offset * 57)

    tail = art.group("Tail", (0, 1.620, .971), (1.31, .879, 1.42), (0, 1.76, .57))
    art.detail(tail, "Compact fanned eagle tail root", (0, 1.745, .743), (.89, .504, .703), bark, pitch=7)
    for index, x in enumerate((-.33, 0, .33), 1):
        art.detail(tail, f"Broad tapered eagle tail feather {index}", (x, 1.545, 1.043),
                   (.431, .273, 1.057), bronze if index == 2 else bark, yaw=x * 55, pitch=16)
        art.detail(tail, f"Short tail feather gold band {index}", (x * 1.32, 1.443, 1.343),
                   (.379, .228, .220), amber, yaw=x * 55, pitch=16)


def _dragon(art):
    ocean, shale, midnight, graphite = "397589", "335875", "263B5E", "25364B"
    teal, laurel, spray, pale = "4C938E", "326781", "8CBFB6", "CFDFBD"
    lavender, deep_purple, silver = "8C94B4", "555F86", "BACAC9"
    cream, ivory, ink, glint = "E1C393", "EAD9AD", "26313D", "FFF2C6"

    torso = art.group("Torso", (0, 2.372, .053), (2.37, 2.40, 2.14))
    art.detail(torso, "Slate-blue dragon torso", (0, 2.477, .08), (2.15, 2.040, 1.598), ocean)
    art.detail(torso, "Pale cloud scale belly", (0, 2.641, -.590), (1.405, 1.644, .731), spray, pitch=-8)
    art.detail(torso, "Ivory throat plating", (0, 3.176, -.535), (.982, .606, .657), pale, pitch=-15)
    for index, (y, z, length) in enumerate(((2.88, -.891, 1.03), (2.64, -.956, 1.18), (2.395, -.914, 1.006)), 1):
        art.detail(torso, f"Overlapping curved cloud scale {index}", (0, y, z), (length, .184, .096), pale, pitch=-7)
    art.detail(torso, "Indigo flight waistguard", (0, 1.764, .074), (1.98, .589, 1.544), midnight, material=FABRIC)
    art.detail(torso, "Double-wrapped violet sash", (0, 1.862, .045), (2.113, .248, 1.69), deep_purple, material=FABRIC)
    art.detail(torso, "Round blue-gray storm crest", (0, 1.887, -.858), (.399, .341, .151), lavender)
    art.detail(torso, "Silver slash in storm crest", (.034, 1.892, -.943), (.072, .191, .044), silver, roll=-25, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(torso, "Wing-root shoulder vest seam", (sign * .756, 2.702, -.502),
                   (.275, 1.275, .391), shale, roll=sign * -16, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Thin silver shoulder stitch", (sign * .755, 2.715, -.697),
                   (.059, 1.104, .080), silver, roll=sign * -16, yaw=sign * -14, shape=BLOCK)
        art.detail(torso, "Violet flight sash tab", (sign * .593, 1.584, -.511),
                   (.499, .571, .484), deep_purple, roll=sign * 13, material=FABRIC)
    art.detail(torso, "Upper dorsal storm fin", (0, 2.972, .786), (.309, .651, .345), shale,
               pitch=-8, class_name="WedgePart")
    art.detail(torso, "Middle dorsal storm fin", (0, 2.552, .876), (.268, .721, .274), teal,
               pitch=-13, class_name="WedgePart")

    head = art.group("Head", (0, 4.105, -.098), (2.47, 2.20, 2.56), (0, 3.27, -.04))
    art.detail(head, "Deep blue dragon crown", (0, 4.032, -.058), (1.662, 1.384, 1.361), ocean, pitch=-7)
    art.detail(head, "Sculpted sapphire forehead", (0, 4.268, -.331), (1.361, .790, .837), teal, pitch=-10)
    art.detail(head, "Long pale dragon muzzle bridge", (0, 3.846, -.745), (.913, .653, 1.030), spray, pitch=11)
    art.detail(head, "Broad cool-blue dragon muzzle", (0, 3.809, -1.032), (.751, .411, .522), pale, pitch=8)
    art.detail(head, "Lower pale rounded dragon jaw", (0, 3.568, -.820), (.840, .370, .909), spray, pitch=6)
    art.detail(head, "Storm breath mouth", (0, 3.69, -1.245), (.524, .087, .120), ink)
    art.detail(head, "Pale chin plate", (0, 3.520, -1.093), (.499, .198, .347), pale, pitch=7)
    art.detail(head, "Cloud sigil above the eyes", (0, 4.350, -.723), (.219, .237, .087), lavender, shape=BLOCK, roll=45)
    art.detail(head, "Dragon crown ridge", (0, 4.557, .328), (.515, .572, .675), shale,
               pitch=-18, class_name="WedgePart")
    for sign in (-1, 1):
        art.detail(head, "Teal swept cheek fin", (sign * .733, 3.795, .006), (.620, .671, .624), teal,
                   pitch=-14, roll=sign * 30)
        art.detail(head, "Deep navy outer cheek fin", (sign * .838, 3.823, .142), (.466, .608, .550), shale,
                   pitch=-18, roll=sign * 39)
        art.detail(head, "Warm cloud-horn root", (sign * .572, 4.523, .206), (.380, .571, .453), cream,
                   pitch=5, roll=sign * -21)
        art.detail(head, "Raked ivory horn center", (sign * .738, 4.76, .361), (.284, .543, .359), ivory,
                   pitch=26, roll=sign * -29)
        art.detail(head, "Tapered horn tip", (sign * .870, 4.962, .522), (.145, .463, .272), ivory,
                   pitch=34, roll=sign * -27)
        art.detail(head, "Graphite dragon eye ridge", (sign * .453, 4.091, -.630), (.574, .405, .428), shale,
                   yaw=sign * -25, roll=sign * 17)
        art.detail(head, "Agate dragon iris", (sign * .462, 4.065, -.808), (.355, .261, .161), ivory,
                   yaw=sign * -25, roll=sign * 16)
        art.detail(head, "Rounded teal pupil", (sign * .438, 4.050, -.871), (.149, .193, .084), ink, yaw=sign * -25)
        art.detail(head, "Bright dragon eye glint", (sign * .434 - .030, 4.107, -.909), (.058, .050, .031), glint)
        art.detail(head, "Lean stern dragon brow", (sign * .441, 4.207, -.778), (.529, .119, .161), ocean,
                   yaw=sign * -26, roll=sign * 19)
        art.detail(head, "Small dark dragon nostril", (sign * .202, 3.88, -1.221), (.127, .075, .066), shale, yaw=sign * -20)
        art.detail(head, "Tiny swept muzzle tendril", (sign * .403, 3.753, -.836), (.098, .531, .109), ivory,
                   yaw=sign * 12, roll=sign * -52)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.554, 2.629, .129),
                        (1.63, 1.97, 2.07), (sign * 1.11, 3.13, .07))
        art.detail(arm, "Blue shoulder wing root", (sign * 1.259, 2.914, .112), (.895, .807, .958), ocean,
                   roll=sign * 17)
        art.detail(arm, "Glazed shoulder scale", (sign * 1.374, 2.947, -.243), (.635, .507, .408), teal,
                   yaw=sign * -18, roll=sign * 19)
        art.detail(arm, "Upper wing spar", (sign * 1.646, 3.099, .565), (.183, .967, .202), midnight,
                   pitch=-9, roll=sign * -72)
        art.detail(arm, "Inner membrane joining the wing root", (sign * 1.484, 2.671, .553), (.179, .810, .680), laurel,
                   yaw=sign * -90, pitch=-10, class_name="WedgePart")
        art.detail(arm, "Wide teal wing membrane", (sign * 1.785, 2.825, .634), (.184, 1.21, .949), laurel,
                   yaw=sign * 90, pitch=10, class_name="WedgePart")
        art.detail(arm, "Inset storm-green wing web", (sign * 1.799, 2.793, .524), (.107, .962, .783), teal,
                   yaw=sign * 90, pitch=10, class_name="WedgePart")
        art.detail(arm, "Slanted wing rib", (sign * 1.832, 2.82, .492), (.103, .835, .097), shale,
                   roll=sign * -29)
        art.detail(arm, "Tapered outer wing knuckle", (sign * 2.143, 3.290, .641), (.238, .456, .210), midnight,
                   pitch=13, roll=sign * -26)
        art.detail(arm, "Dark indigo wing wrist guard", (sign * 1.356, 2.194, -.345), (.745, .758, .764), midnight,
                   pitch=-15, roll=sign * 12, material=FABRIC)
        art.detail(arm, "Pale silver wing wrist binding", (sign * 1.364, 2.172, -.402), (.088, .726, .673), silver,
                   roll=90 + sign * 11, shape=CYLINDER)
        art.detail(arm, "Blue dragon knuckle guard", (sign * 1.367, 1.963, -.532), (.717, .580, .483), ocean)
        art.detail(arm, "Dragon wing strike pad", (sign * 1.37, 1.94, -.755), (.58, .39, .15), spray)

        leg = art.group(f"{side} Leg", (sign * .52, .805, -.207),
                        (1.02, 1.59, 1.49), (sign * .52, 1.51, .075))
        art.detail(leg, "Scaled dragon thigh in violet trousers", (sign * .525, 1.117, .059), (.862, .956, .937),
                   deep_purple, roll=sign * -11, material=FABRIC)
        art.detail(leg, "Strong blue dragon shin", (sign * .524, .613, -.079), (.669, .883, .691), ocean,
                   pitch=12, roll=sign * 9)
        art.detail(leg, "Decorative silver shin scale", (sign * .528, .518, -.365), (.405, .432, .264), spray,
                   pitch=11, roll=sign * 9)
        art.detail(leg, "Indigo ankle wrap", (sign * .519, .425, -.199), (.113, .692, .682), midnight,
                   roll=90 + sign * 8, shape=CYLINDER, material=FABRIC)
        art.detail(leg, "Flat dragon boot sole", (sign * .52, .067, -.36), (.68, .110, 1.04), graphite, shape=BLOCK)
        art.detail(leg, "Rounded teal dragon boot", (sign * .52, .239, -.428), (.767, .420, .860), laurel)
        for offset in (-.194, 0, .194):
            art.detail(leg, "Blunt polished dragon boot toe", (sign * .52 + offset, .175, -.816 + abs(offset) * .12),
                       (.169, .165, .154), lavender, yaw=-offset * 48)

    tail = art.group("Tail", (0, 1.962, 1.350), (.76, 1.59, 1.80), (0, 1.82, .66))
    art.detail(tail, "Heavy base of the dragon tail", (0, 1.747, .928), (.647, .553, .949), ocean, pitch=-12)
    art.detail(tail, "Rising blue tail", (0, 1.925, 1.38), (.522, .446, .877), laurel, pitch=-31)
    art.detail(tail, "Tapered turn of dragon tail", (0, 2.183, 1.633), (.341, .391, .695), teal, pitch=-49)
    art.detail(tail, "Silver crest at dragon tail tip", (0, 2.396, 1.854), (.283, .573, .428), spray,
               pitch=-38, class_name="WedgePart")
    art.detail(tail, "Short dorsal scale on the tail", (0, 2.101, 1.280), (.252, .307, .463), midnight,
               pitch=-39, class_name="WedgePart")


def build_storm_roster_visuals(library, *, item, part, prop, vector):
    """Build the eagle and dragon using native ornaments and fitted pivots."""
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    _eagle(_FighterArt(library, "golden-eagle", **helpers))
    _dragon(_FighterArt(library, "celestial-storm-dragon", **helpers))
