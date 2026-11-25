"""Original floor-aligned playable art for the two Magma fighters."""

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _armadillo(art):
    obsidian, basalt, coal = "323037", "48434A", "26232B"
    bronze, copper, amber = "9D583C", "C28052", "ECB272"
    ochre, umber, sand = "AD7557", "775247", "D6A981"
    wine, wine_shadow, cloth = "743844", "4D2834", "9A4A50"
    ivory, ink = "FFE7C3", "201B24"

    torso = art.group("Torso", (0, 2.295, .169), (2.583, 2.159, 2.461))
    art.detail(torso, "Broad obsidian carapace", (0, 2.32, .275), (2.34, 2.08, 2.06), obsidian)
    art.detail(torso, "Armored belly", (0, 2.26, -.474), (1.87, 1.75, .962), umber)
    art.detail(torso, "Tapered breastplate", (0, 2.56, -.713), (1.62, 1.21, .55), basalt)
    art.detail(torso, "Protective collar", (0, 3.054, -.225), (1.67, .447, 1.29), bronze)
    for level, (y, z, width, tilt) in enumerate(((2.939, .575, 1.88, -15),
                                                  (2.624, .772, 2.05, -7),
                                                  (2.298, .847, 2.13, 0),
                                                  (1.984, .742, 1.96, 8),
                                                  (1.716, .572, 1.76, 17)), 1):
        art.detail(torso, f"Copper shell rib {level}", (0, y, z),
                   (width, .238, 1.02), copper, pitch=tilt)
        art.detail(torso, f"Obsidian shell inset {level}", (0, y + .044, z + .328),
                   (.81 * width, .120, .391), basalt, pitch=tilt)
        art.detail(torso, f"Warm shell edge {level}", (0, y - .064, z + .401),
                   (.69 * width, .053, .274), amber, pitch=tilt)
    for sign in (-1, 1):
        art.detail(torso, "Side carapace cheek", (sign * .909, 2.38, .103), (.53, 1.53, 1.27), obsidian,
                   yaw=sign * -21, roll=sign * -13)
        art.detail(torso, "Copper shoulder collar binding", (sign * .53, 2.735, -.91), (.17, .83, .12), copper,
                   shape=BLOCK, yaw=sign * -17, roll=sign * -29)
        for y in (2.819, 2.525):
            art.detail(torso, "Small bronze collar stud", (sign * .558, y, -.96), (.113, .122, .067), amber)
    art.detail(torso, "Lacquer-red training split skirt", (0, 1.52, -.034), (1.77, .58, 1.45), wine_shadow,
               material=FABRIC)
    art.detail(torso, "Layered mulberry belt", (0, 1.726, -.067), (2.04, .285, 1.57), wine, material=FABRIC)
    art.detail(torso, "Belt seam", (0, 1.772, -.843), (1.66, .06, .075), cloth, material=FABRIC)
    art.detail(torso, "Sunburst belt medallion", (0, 1.73, -.89), (.078, .35, .35), copper, shape=CYLINDER, yaw=90)
    art.detail(torso, "Sunburst medallion inset", (0, 1.73, -.933), (.12, .137, .045), amber)

    head = art.group("Head", (0, 3.877, -.411), (1.508, 1.492, 1.924), (0, 3.10, -.11))
    art.detail(head, "Armadillo cranium", (0, 3.715, -.088), (1.48, 1.14, 1.25), ochre)
    art.detail(head, "Streamlined muzzle bridge", (0, 3.635, -.632), (.912, .66, 1.03), ochre, pitch=13)
    art.detail(head, "Golden tapered muzzle", (0, 3.529, -.935), (.674, .409, .63), sand, pitch=13)
    art.detail(head, "Armadillo coal nose", (0, 3.576, -1.242), (.374, .211, .233), ink)
    art.detail(head, "Nose reflection", (.049, 3.615, -1.337), (.134, .043, .042), sand)
    art.detail(head, "Soft lower jaw", (0, 3.402, -.816), (.69, .268, .699), umber, pitch=7)
    art.detail(head, "Curved forehead armor", (0, 4.024, -.29), (1.308, .609, 1.043), obsidian, pitch=8)
    art.detail(head, "Copper forehead edging", (0, 4.122, -.449), (1.03, .316, .824), bronze, pitch=8)
    art.detail(head, "Forehead sun crest", (0, 4.135, -.842), (.192, .184, .071), amber, roll=45, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(head, "Armadillo upright ear", (sign * .492, 4.223, .226), (.333, .822, .34), umber,
                   roll=sign * -19, pitch=12)
        art.detail(head, "Short soft ear inset", (sign * .522, 4.299, .099), (.227, .550, .115), sand,
                   roll=sign * -19, pitch=12)
        art.detail(head, "Copper orbital guard", (sign * .474, 3.86, -.511), (.54, .433, .358), bronze,
                   yaw=sign * -16, roll=sign * 18)
        art.detail(head, "Warm eye white", (sign * .49, 3.806, -.642), (.329, .257, .13), ivory,
                   yaw=sign * -16, roll=sign * 14)
        art.detail(head, "Amber iris", (sign * .473, 3.804, -.704), (.144, .174, .082), amber,
                   yaw=sign * -12)
        art.detail(head, "Small dark pupil", (sign * .463, 3.805, -.742), (.071, .127, .04), ink)
        art.detail(head, "Glove-side catchlight", (sign * .464 + .024, 3.854, -.763), (.044, .053, .03), ivory)
        art.detail(head, "Copper brow plate", (sign * .489, 3.968, -.649), (.355, .105, .132), coal,
                   yaw=sign * -12, roll=sign * 21)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.144, 2.376, -.129), (.979, 1.565, 1.330),
                        (sign * .96, 2.83, .06))
        art.detail(arm, "Rounded plated shoulder", (sign * 1.116, 2.728, .042), (.9, .827, .96), basalt,
                   roll=sign * 15)
        art.detail(arm, "Hammered bronze shoulder lip", (sign * 1.249, 2.86, -.051), (.677, .452, .746), bronze,
                   roll=sign * 20)
        art.detail(arm, "Armored forearm", (sign * 1.25, 2.21, -.164), (.731, .895, .714), obsidian,
                   pitch=-17, roll=sign * 12)
        art.detail(arm, "Crimson striking wrap", (sign * 1.24, 1.947, -.381), (.692, .572, .663), wine,
                   roll=sign * 10, material=FABRIC)
        art.detail(arm, "Gold wrap seam", (sign * 1.24, 2.004, -.418), (.117, .671, .652), amber,
                   shape=CYLINDER, roll=90 + sign * 9)
        art.detail(arm, "Heavy copper knuckle pad", (sign * 1.24, 1.80, -.6), (.688, .384, .36), copper)
        art.detail(arm, "Rounded outer guard ridge", (sign * 1.252, 1.832, -.73), (.437, .115, .068), amber)

        leg = art.group(f"{side} Leg", (sign * .53, .754, -.22), (.885, 1.513, 1.287),
                         (sign * .53, 1.43, .03))
        art.detail(leg, "Multilayer leg wrap", (sign * .53, 1.042, -.032), (.855, .91, .883), wine_shadow,
                   roll=sign * -10, material=FABRIC)
        art.detail(leg, "Short obsidian shin plate", (sign * .552, .551, -.208), (.632, .724, .691), basalt,
                   pitch=-15, roll=sign * 6)
        art.detail(leg, "Burnished copper shin edge", (sign * .55, .542, -.467), (.568, .421, .158), copper,
                   pitch=-13)
        art.detail(leg, "Flat training boot sole", (sign * .53, .137, -.31), (.82, .25, .93), coal, shape=BLOCK)
        art.detail(leg, "Sand-colored armored boot", (sign * .53, .281, -.298), (.792, .371, .986), umber)
        art.detail(leg, "Copper toe cap", (sign * .535, .242, -.616), (.749, .263, .455), bronze)
        for x in (-.205, 0, .205):
            art.detail(leg, "Rounded hard toe stitch", (sign * .53 + x, .212, -.811), (.117, .135, .076), amber)

    tail = art.group("Tail", (0, 1.493, 1.33), (.681, .700, 1.295), (0, 1.61, .78))
    for index, (y, z, width, length) in enumerate(((1.57, 1.00, .653, .62), (1.452, 1.354, .507, .671),
                                                   (1.327, 1.661, .358, .635))):
        art.detail(tail, f"Articulated tail armor {index + 1}", (0, y, z), (width, width * .77, length),
                   basalt if index % 2 else obsidian, pitch=20)
        art.detail(tail, f"Tail armor edge {index + 1}", (0, y + .083, z + .072),
                   (width * .86, width * .31, .14), copper, pitch=20)


def _komodo(art):
    charcoal, basalt, ash = "333B3B", "475553", "667570"
    jade, deep_jade, mint = "33766C", "24504E", "7FBE9C"
    russet, coral, gold = "8D4333", "CC7647", "E9AA68"
    wrap, cream, ink = "B99470", "F2D5A1", "1B292B"

    torso = art.group("Torso", (0, 2.267, -.04), (2.074, 2.290, 1.794))
    art.detail(torso, "Long monitor chest", (0, 2.42, .035), (2.0, 1.881, 1.51), charcoal)
    art.detail(torso, "Dark green training tunic", (0, 2.347, -.058), (1.89, 1.575, 1.385), deep_jade,
               material=FABRIC)
    art.detail(torso, "Crossed basalt shoulder drape", (0, 2.864, .078), (2.046, .676, 1.301), basalt,
               material=FABRIC)
    art.detail(torso, "Ash-colored throat scales", (0, 3.077, -.32), (1.19, .62, .95), ash, pitch=13)
    art.detail(torso, "Sun-dried fighting sash", (0, 1.727, -.045), (1.97, .31, 1.434), russet, material=FABRIC)
    art.detail(torso, "Ember border seam", (0, 1.798, -.747), (1.68, .06, .105), gold, material=FABRIC)
    art.detail(torso, "Off-axis cloth knot", (-.493, 1.722, -.788), (.478, .256, .27), coral,
               roll=-12, material=FABRIC)
    for sign in (-1, 1):
        art.detail(torso, "Split volcanic-cloth lower panel", (sign * .395, 1.502, -.204), (.83, .613, .928),
                   deep_jade, roll=sign * -12, material=FABRIC)
        art.detail(torso, "Angular jade lapel", (sign * .307, 2.618, -.592), (.262, 1.108, .205), jade,
                   shape=BLOCK, yaw=sign * -17, roll=sign * -32, material=FABRIC)
        art.detail(torso, "Contrasting stitch on lapel", (sign * .402, 2.649, -.701), (.069, .899, .046), mint,
                   shape=BLOCK, yaw=sign * -17, roll=sign * -32)
        art.detail(torso, "Side bronze weight clasp", (sign * .641, 1.82, -.629), (.167, .202, .174), gold,
                   roll=sign * 13)
    art.detail(torso, "Folded vermilion cloth end", (-.491, 1.478, -.837), (.21, .65, .145), russet,
               shape=BLOCK, roll=-18, material=FABRIC)
    art.detail(torso, "Warm kerchief tip", (-.685, 1.512, -.807), (.165, .49, .12), coral,
               shape=BLOCK, roll=-21, material=FABRIC)
    for index, (y, z, size) in enumerate(((2.961, .623, .625), (2.71, .708, .568), (2.48, .733, .494),
                                          (2.24, .733, .424))):
        art.detail(torso, f"Flat monitor dorsal scale {index + 1}", (0, y, z), (size, .261, .214), jade,
                   pitch=-18)

    head = art.group("Head", (0, 3.757, -.431), (1.648, 1.128, 1.976), (0, 3.14, -.14))
    art.detail(head, "Monitor skull", (0, 3.755, -.092), (1.548, 1.095, 1.27), basalt)
    art.detail(head, "Flattened lizard snout", (0, 3.742, -.718), (1.208, .567, 1.28), charcoal, pitch=-3)
    art.detail(head, "Long cool-green nasal ridge", (0, 3.871, -.756), (.804, .295, 1.19), jade, pitch=-9)
    art.detail(head, "Rounded scaled snout end", (0, 3.675, -1.193), (.881, .405, .404), basalt)
    art.detail(head, "Open inner jaw shadow", (0, 3.548, -.912), (.991, .109, .943), ink, pitch=-4)
    art.detail(head, "Visible warm mouth opening", (0, 3.568, -1.31), (.527, .112, .143), russet)
    art.detail(head, "Flat monitor jaw", (0, 3.44, -.809), (1.037, .277, 1.16), ash, pitch=-4)
    art.detail(head, "Amber chin scales", (0, 3.419, -.977), (.679, .184, .734), wrap, pitch=-6)
    art.detail(head, "Rounded crown crest", (0, 4.106, .081), (.696, .34, .736), deep_jade, pitch=-19)
    for sign in (-1, 1):
        art.detail(head, "Dark jaw hinge", (sign * .483, 3.51, -.33), (.563, .485, .62), jade,
                   yaw=sign * -23)
        art.detail(head, "Lizard eye socket", (sign * .569, 3.92, -.526), (.523, .439, .351), deep_jade,
                   yaw=sign * -31, roll=sign * -10)
        art.detail(head, "Golden lizard iris", (sign * .606, 3.911, -.647), (.299, .253, .144), gold,
                   yaw=sign * -31)
        art.detail(head, "Vertical monitor pupil", (sign * .585, 3.916, -.703), (.069, .192, .069), ink,
                   yaw=sign * -26)
        art.detail(head, "Warm eye catchlight", (sign * .581 + .025, 3.979, -.733), (.049, .051, .036), cream)
        art.detail(head, "Expressive jade upper brow", (sign * .569, 4.038, -.576), (.501, .147, .204), jade,
                   yaw=sign * -21, roll=sign * 15)
        art.detail(head, "Nasal pit", (sign * .256, 3.735, -1.365), (.135, .074, .063), ink,
                   yaw=sign * -24)
        for index, (y, z) in enumerate(((3.73, -.741), (3.699, -.849), (3.673, -.949))):
            art.detail(head, f"Speckled nose scale {index + 1}", (sign * (.551 - index * .032), y, z),
                       (.113, .062, .099), ash, yaw=sign * -29)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.072, 2.441, -.131), (.892, 1.592, 1.349),
                        (sign * .91, 2.99, .04))
        art.detail(arm, "Scaled upper arm", (sign * 1.037, 2.687, .105), (.752, 1.015, .849), basalt,
                   roll=sign * 15)
        art.detail(arm, "Layered jade shoulder wrap", (sign * 1.054, 2.85, -.047), (.839, .731, .833), jade,
                   roll=sign * 19, material=FABRIC)
        art.detail(arm, "Charcoal forearm", (sign * 1.175, 2.229, -.245), (.621, .94, .694), charcoal,
                   pitch=-17, roll=sign * 13)
        art.detail(arm, "Linen boxing wrap", (sign * 1.18, 2.035, -.404), (.65, .576, .687), wrap,
                   pitch=-15, roll=sign * 11, material=FABRIC)
        for y, z in ((2.182, -.331), (2.038, -.451)):
            art.detail(arm, "Covered wrap stitching", (sign * 1.18, y, z), (.07, .643, .681), cream,
                       shape=CYLINDER, roll=90 + sign * 10)
        art.detail(arm, "Padded lizard fist", (sign * 1.18, 1.88, -.59), (.626, .441, .36), jade)
        art.detail(arm, "Fist tip ridge", (sign * 1.182, 1.894, -.746), (.511, .198, .066), mint)

        leg = art.group(f"{side} Leg", (sign * .502, .802, -.233), (.869, 1.61, 1.391),
                         (sign * .50, 1.55, .04))
        art.detail(leg, "Jade sparring trouser leg", (sign * .502, 1.107, .038), (.833, .978, .82), deep_jade,
                   roll=sign * -13, material=FABRIC)
        art.detail(leg, "Banded monitor shin", (sign * .522, .593, -.183), (.611, .833, .778), basalt,
                   pitch=18, roll=sign * 8)
        art.detail(leg, "Heat-faded ankle tie", (sign * .513, .359, -.26), (.129, .652, .749), coral,
                   shape=CYLINDER, roll=90 + sign * 8, material=FABRIC)
        art.detail(leg, "Flat monitor boot sole", (sign * .50, .127, -.36), (.705, .23, .99), ink, shape=BLOCK)
        art.detail(leg, "Wide reptile forefoot", (sign * .502, .239, -.401), (.778, .385, 1.016), charcoal)
        for index, displacement in enumerate((-.235, 0, .235)):
            art.detail(leg, f"Blunt plated toe {index + 1}", (sign * .50 + displacement, .177, -.822),
                       (.182, .213, .186), ash, yaw=displacement * -52)

    tail = art.group("Tail", (0, 1.371, 1.537), (.784, 1.116, 2.316), (0, 1.71, .52))
    for index, (x, y, z, radius, length) in enumerate(((0, 1.52, .875, .756, .997),
                                                        (.023, 1.291, 1.474, .57, 1.051),
                                                        (.095, 1.083, 2.031, .428, .905),
                                                        (.167, .961, 2.442, .264, .512))):
        art.detail(tail, f"Continuous tapered tail {index + 1}", (x, y, z),
                   (radius, radius * .84, length), basalt if index % 2 else charcoal, pitch=19, yaw=index * 5)
        art.detail(tail, f"Jade dorsal tail bar {index + 1}", (x, y + radius * .284, z + .041),
                   (radius * .62, radius * .49, .24), jade, pitch=19, yaw=index * 5)


def build_magma_roster_visuals(library, *, item, part, prop, vector):
    """Build the two original rigid shells without uploaded asset dependencies."""
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    _armadillo(_FighterArt(library, "armadillo-striker", **helpers))
    _komodo(_FighterArt(library, "komodo-dragon", **helpers))
