"""Original floor-aligned native shells for Rooster Kickboxer and Sugar Glider."""

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _rooster(art):
    plum, aubergine, turquoise, teal = "47263D", "30263D", "54C9C1", "215E66"
    rust, copper, ochre, cream = "A44B35", "CD6D43", "E49A59", "FFDB94"
    comb, comb_tip, beak, ink = "C83D51", "ED6670", "F9AC49", "221A2A"
    brass = "F2BE78"
    torso = art.group("Torso", (0, 2.40, -.084), (1.76, 2.28, 1.58))
    art.detail(torso, "Copper feathered chest", (0, 2.54, .02), (1.73, 1.76, 1.35), rust)
    art.detail(torso, "Honey hackle ruff", (0, 3.02, -.18), (1.28, 1.01, 1.17), ochre)
    art.detail(torso, "Layered breast feathers", (0, 2.71, -.52), (1.28, 1.22, .57), copper)
    art.detail(torso, "Dark kickboxing shorts", (0, 1.64, -.01), (1.51, .74, 1.15), aubergine, material=FABRIC)
    art.detail(torso, "Turquoise champion sash", (0, 1.89, -.01), (1.64, .31, 1.23), teal, material=FABRIC)
    art.detail(torso, "Woven sash edging", (0, 1.99, -.585), (1.40, .084, .11), turquoise, shape=BLOCK)
    art.detail(torso, "Brass buckle", (.27, 1.91, -.652), (.10, .25, .35), brass, shape=CYLINDER, yaw=90)
    art.detail(torso, "Overlapping festival ribbon", (.30, 1.66, -.574), (.24, .57, .14), turquoise,
               shape=BLOCK, roll=19, material=FABRIC)
    art.detail(torso, "Tailored red ribbon", (.08, 1.64, -.585), (.17, .52, .12), comb,
               shape=BLOCK, roll=-17, material=FABRIC)
    for sign in (-1, 1):
        art.detail(torso, "Teal sparring harness", (sign * .35, 2.57, -.615), (.18, 1.24, .17), teal,
                   shape=BLOCK, roll=sign * -23, material=FABRIC)
        art.detail(torso, "Harness binding", (sign * .42, 2.63, -.692), (.053, .92, .07), turquoise,
                   shape=BLOCK, roll=sign * -23)
    art.detail(torso, "Gilded sunrise crest", (0, 2.77, -.804), (.11, .22, .24), brass, shape=CYLINDER, yaw=90)

    head = art.group("Head", (0, 4.224, -.258), (1.53, 1.98, 1.68), (0, 3.16, -.03))
    art.detail(head, "Chicken head", (0, 4.03, -.08), (1.34, 1.39, 1.29), copper)
    art.detail(head, "Tapered neck collar", (0, 3.60, -.12), (.97, .70, .95), ochre)
    art.detail(head, "Ochre upper beak", (0, 3.95, -.744), (.56, .39, .68), beak, pitch=10)
    art.detail(head, "Beak seam", (0, 3.854, -.856), (.45, .066, .45), rust, pitch=5)
    art.detail(head, "Lower beak", (0, 3.804, -.777), (.44, .19, .49), ochre, pitch=-7)
    art.detail(head, "Rooster wattles", (.01, 3.55, -.59), (.40, .60, .42), comb, pitch=-20)
    for index, (y, z, h, tilt) in enumerate(((4.66, -.35, .66, 19), (4.80, -.08, .84, 21), (4.69, .20, .77, 30))):
        art.detail(head, f"Comb lobe {index + 1}", (0, y, z), (.32, h, .44), comb if index != 1 else comb_tip, pitch=tilt)
    for sign in (-1, 1):
        art.detail(head, "Pale cheek feather", (sign * .53, 3.87, -.34), (.42, .59, .54), ochre, roll=sign * 19)
        art.detail(head, "Eye socket", (sign * .39, 4.137, -.544), (.45, .43, .31), rust, yaw=sign * -20)
        art.detail(head, "Warm eye white", (sign * .39, 4.127, -.661), (.35, .33, .16), cream, yaw=sign * -20)
        art.detail(head, "Pupil", (sign * .35, 4.124, -.728), (.145, .206, .081), ink, yaw=sign * -18)
        art.detail(head, "Eye catchlight", (sign * .35 + .027, 4.185, -.764), (.050, .055, .021), "FFF7E5")
        art.detail(head, "Confident tapered brow", (sign * .41, 4.30, -.617), (.43, .14, .18), plum,
                   yaw=sign * -17, roll=sign * 17)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.055, 2.422, -.109), (.934, 1.59, 1.16), (sign * .83, 3.02, .03))
        art.detail(arm, "Copper wing shoulder", (sign * .982, 2.792, .028), (.67, .72, .72), copper, roll=sign * 16)
        art.detail(arm, "Broad plum wing guard", (sign * 1.049, 2.47, .008), (.738, .88, .77), plum, roll=sign * 16)
        art.detail(arm, "Scalloped feather edge", (sign * 1.102, 2.47, .286), (.59, .73, .34), rust,
                   roll=sign * 18)
        art.detail(arm, "Turquoise wing wrap", (sign * 1.087, 2.20, -.15), (.58, .60, .71), turquoise, roll=sign * 12)
        art.detail(arm, "Wrist brass binding", (sign * 1.10, 2.069, -.18), (.091, .59, .722), brass,
                   shape=CYLINDER, roll=90 + sign * 14)
        art.detail(arm, "Plum kickboxer glove", (sign * 1.10, 1.995, -.338), (.62, .48, .64), plum)
        art.detail(arm, "Glove impact panel", (sign * 1.10, 1.975, -.528), (.53, .34, .25), teal)

        leg = art.group(f"{side} Leg", (sign * .49, .792, -.211), (.85, 1.59, 1.55), (sign * .45, 1.54, .02))
        art.detail(leg, "Plum kicking thigh", (sign * .48, 1.129, .049), (.744, .84, .84), plum,
                   roll=sign * -12, material=FABRIC)
        art.detail(leg, "Bird shin", (sign * .50, .623, -.076), (.46, .92, .56), copper, pitch=14, roll=sign * 7)
        art.detail(leg, "Teal kick pad", (sign * .49, .594, -.253), (.47, .75, .39), teal, pitch=-15)
        art.detail(leg, "Padded lower trim", (sign * .50, .35, -.222), (.09, .49, .55), turquoise,
                   shape=CYLINDER, roll=90 + sign * 8)
        art.detail(leg, "Padded forefoot", (sign * .48, .145, -.451), (.72, .29, .84), copper)
        for spread, length, zpos in ((-.23, .30, -.675), (0, .392, -.724), (.23, .30, -.675)):
            art.detail(leg, "Rounded toe pad", (sign * (.48 + spread), .113, zpos), (.207, .214, length), ochre,
                       yaw=sign * spread * 56)

    tail = art.group("Tail", (0, 2.25, 1.20), (1.47, 1.68, 2.14), (0, 1.87, .44))
    art.detail(tail, "Tail base", (0, 1.92, .725), (.68, .69, .78), plum, pitch=-32)
    art.detail(tail, "Peacock-blue center sickle", (0, 2.31, 1.231), (.48, 1.41, .56), teal, pitch=-45)
    art.detail(tail, "Center sickle tip", (0, 2.61, 1.709), (.37, .75, .40), turquoise, pitch=-69)
    for sign in (-1, 1):
        art.detail(tail, "Outer maroon tail cover", (sign * .33, 2.24, 1.21), (.43, 1.17, .64), plum,
                   pitch=-48, roll=sign * -22)
        art.detail(tail, "Copper tail tip", (sign * .49, 2.43, 1.63), (.36, .70, .42), rust,
                   pitch=-68, roll=sign * -24)


def _glider(art):
    fur, fleece, taupe, stripe = "79617F", "FFE2B5", "BA8C9B", "48354F"
    slate, violet, lavender, lilac = "252445", "554378", "A390D2", "7C6395"
    cloud, mint, coral, brass = "F5CBAC", "9FE4DC", "BE7D8A", "F2C17D"
    ink = "1B182A"
    torso = art.group("Torso", (0, 2.38, -.065), (1.62, 2.16, 1.46))
    art.detail(torso, "Indigo flight jacket", (0, 2.48, .023), (1.58, 1.64, 1.23), violet)
    art.detail(torso, "Soft chest bib", (0, 2.76, -.499), (.98, 1.02, .47), fleece)
    art.detail(torso, "Padded cloud collar", (0, 3.04, -.072), (1.26, .48, 1.08), lavender)
    art.detail(torso, "Layered night tunic", (0, 1.74, -.026), (1.41, .74, 1.15), slate, material=FABRIC)
    art.detail(torso, "Turquoise sky sash", (0, 1.881, -.02), (1.53, .28, 1.23), mint)
    art.detail(torso, "Dusk sash trim", (0, 1.837, -.595), (1.36, .08, .14), lilac)
    art.detail(torso, "Sash pin", (-.266, 1.892, -.665), (.101, .24, .27), brass, shape=CYLINDER, yaw=90)
    art.detail(torso, "Knotted fabric sash", (-.36, 1.68, -.592), (.25, .49, .16), lavender,
               shape=BLOCK, roll=-19, material=FABRIC)
    for sign in (-1, 1):
        art.detail(torso, "Flight jacket lapel", (sign * .34, 2.55, -.598), (.21, .94, .151), lilac,
                   shape=BLOCK, yaw=sign * -14, roll=sign * -23)
        art.detail(torso, "Raised lapel piping", (sign * .43, 2.63, -.668), (.061, .69, .058), lavender,
                   shape=BLOCK, yaw=sign * -14, roll=sign * -23)
    art.detail(torso, "Flight guild brooch", (.32, 2.65, -.71), (.19, .20, .078), mint, roll=24)

    head = art.group("Head", (0, 4.024, -.225), (1.78, 1.48, 1.56), (0, 3.13, -.045))
    art.detail(head, "Sugar glider skull", (0, 3.96, -.062), (1.51, 1.31, 1.21), fur)
    art.detail(head, "Heart-shaped face", (0, 3.81, -.524), (1.11, .84, .52), cloud)
    art.detail(head, "Light muzzle", (0, 3.654, -.663), (.81, .48, .47), fleece)
    art.detail(head, "Central glider facial stripe", (0, 4.152, -.562), (.267, .72, .253), stripe, pitch=-22)
    art.detail(head, "Pointed nose", (0, 3.818, -.873), (.292, .193, .24), stripe, pitch=5)
    art.detail(head, "Dusky nose sheen", (.022, 3.865, -.973), (.142, .073, .038), coral)
    art.detail(head, "Soft lower lip", (0, 3.589, -.814), (.31, .07, .088), taupe)
    for sign in (-1, 1):
        art.detail(head, "Rounded glider ear", (sign * .592, 4.426, .015), (.55, .646, .48), fur, roll=sign * -21)
        art.detail(head, "Pink ear cup", (sign * .621, 4.449, -.182), (.373, .462, .148), coral, roll=sign * -21)
        art.detail(head, "Peak ear rim", (sign * .674, 4.547, -.215), (.204, .239, .08), taupe, roll=sign * -21)
        art.detail(head, "Dark glider eye mask", (sign * .394, 4.055, -.548), (.591, .53, .34), stripe,
                   yaw=sign * -18, roll=sign * 13)
        art.detail(head, "Honey amber iris", (sign * .374, 4.069, -.693), (.387, .39, .18), brass,
                   yaw=sign * -18, roll=sign * 10)
        art.detail(head, "Wide night pupil", (sign * .354, 4.069, -.763), (.264, .287, .143), ink, yaw=sign * -18)
        art.detail(head, "Large eye catchlight", (sign * .354 + .049, 4.142, -.823), (.11, .09, .034), "FFF6DB")
        art.detail(head, "Small eye catchlight", (sign * .354 - .030, 4.026, -.829), (.048, .050, .028), "F7EEE8")
        art.detail(head, "Glider brow", (sign * .400, 4.258, -.653), (.405, .115, .123), fur,
                   yaw=sign * -12, roll=sign * 13)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * .887, 2.44, .01), (.93, 1.43, 1.19), (sign * .77, 2.99, .025))
        art.detail(arm, "Lilac flight sleeve", (sign * .947, 2.69, .05), (.67, .91, .656), lilac, roll=sign * 18)
        # Folded in guard, these continuous panels fan out when the shoulders open.
        art.detail(arm, "Folded flight membrane", (sign * .833, 2.445, .273), (.19, 1.10, .72), lavender,
                   class_name="WedgePart", yaw=sign * 90, roll=sign * 21)
        art.detail(arm, "Membrane inner web", (sign * .711, 2.516, .361), (.16, .84, .54), violet,
                   class_name="WedgePart", yaw=sign * 90, roll=sign * 21)
        art.detail(arm, "Dark sparring gauntlet", (sign * 1.029, 2.228, -.186), (.56, .73, .64), slate,
                   roll=sign * 13, material=FABRIC)
        art.detail(arm, "Mint wrist binding", (sign * 1.036, 2.168, -.218), (.085, .58, .657), mint,
                   shape=CYLINDER, roll=90 + sign * 13)
        art.detail(arm, "Glider palm", (sign * 1.04, 1.976, -.315), (.58, .457, .50), fur)
        art.detail(arm, "Pale palm pad", (sign * 1.04, 1.93, -.462), (.42, .265, .217), cloud)

        leg = art.group(f"{side} Leg", (sign * .47, .780, -.169), (.83, 1.56, 1.32), (sign * .43, 1.51, .02))
        art.detail(leg, "Flight suit leg", (sign * .466, 1.105, .031), (.733, .888, .84), violet,
                   roll=sign * -13, material=FABRIC)
        art.detail(leg, "Glider shin", (sign * .49, .594, -.078), (.513, .82, .68), fur, pitch=17, roll=sign * 9)
        art.detail(leg, "Wide practical ankle strap", (sign * .490, .390, -.175), (.115, .557, .671), lilac,
                   shape=CYLINDER, roll=90 + sign * 12, material=FABRIC)
        art.detail(leg, "Mint ankle button", (sign * .691, .400, -.366), (.154, .179, .151), mint)
        art.detail(leg, "Padded glider forefoot", (sign * .480, .142, -.375), (.703, .284, .85), fur)
        art.detail(leg, "Cream toe web", (sign * .480, .123, -.649), (.537, .208, .323), cloud)

    tail = art.group("Tail", (.08, 1.305, 1.615), (.92, 1.10, 2.91), (0, 1.64, .49))
    art.detail(tail, "Bushy glider tail base", (0, 1.48, .925), (.68, .53, 1.10), stripe, pitch=22)
    art.detail(tail, "Sweep of the plume", (.048, 1.209, 1.652), (.64, .53, 1.53), fur, pitch=20, yaw=6)
    art.detail(tail, "Lilac center marking", (.095, 1.076, 1.924), (.631, .493, .61), lilac, pitch=16, yaw=7)
    art.detail(tail, "Darker end plume", (.168, 1.044, 2.384), (.485, .416, 1.05), stripe, pitch=3, yaw=13)
    art.detail(tail, "Soft tail cap", (.303, 1.104, 2.741), (.326, .293, .57), fur, pitch=-9, yaw=20)


def build_sky_visuals(library, *, item, part, prop, vector):
    """Add both Sky fighters with original native ornament groups."""
    adapters = dict(item=item, part=part, prop=prop, vector=vector)
    _rooster(_FighterArt(library, "rooster-kickboxer", **adapters))
    _glider(_FighterArt(library, "sugar-glider", **adapters))
