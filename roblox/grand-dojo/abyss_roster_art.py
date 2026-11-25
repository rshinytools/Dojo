"""Original native-part shells for the two deep-water contenders."""

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _shark(art):
    steel, blue, edge, deep = "5C778D", "45637B", "3899A8", "30445E"
    ivory, pearl, shadow = "F0E2C5", "FCEDCB", "A9B7AE"
    navy, cloth, brass, ink = "23384D", "28546A", "CC9A59", "232B36"

    torso = art.group("Torso", (0, 2.526, .188), (1.99, 2.38, 2.13))
    art.detail(torso, "Long slate shark chest", (0, 2.49, .06), (1.84, 1.90, 1.46), steel)
    art.detail(torso, "Cropped storm-blue deck jacket", (0, 2.24, .074),
               (1.90, 1.45, 1.53), navy, material=FABRIC)
    art.detail(torso, "Ivory throat and belly", (0, 2.65, -.506),
               (1.105, 1.31, .686), ivory, pitch=-7)
    art.detail(torso, "Dorsal fin at shoulder line", (0, 3.18, .768),
               (.350, .899, .771), deep, pitch=-11, class_name="WedgePart")
    art.detail(torso, "Dorsal fin rake highlight", (0, 3.205, .788),
               (.280, .706, .624), steel, pitch=-11, class_name="WedgePart")
    art.detail(torso, "Coral-red utility belt", (0, 1.785, .008),
               (1.87, .282, 1.43), "99594E", material=FABRIC)
    art.detail(torso, "Brass tide knot plaque", (0, 1.796, -.735),
               (.258, .304, .083), brass, shape=BLOCK, roll=45)
    art.detail(torso, "Pearl clasp inset", (0, 1.796, -.792), (.117, .117, .037), pearl, roll=45, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(torso, "Raised seafarer lapel", (sign * .38, 2.64, -.588),
                   (.362, .874, .270), cloth, roll=sign * -22, yaw=sign * -10, material=FABRIC)
        art.detail(torso, "Ivory stitched lapel edging", (sign * .50, 2.64, -.704),
                   (.071, .746, .078), shadow, roll=sign * -22, shape=BLOCK)
        art.detail(torso, "Split deep-blue deck cloth", (sign * .453, 1.633, -.492),
                   (.639, .548, .661), deep, roll=sign * 10, material=FABRIC)
        art.detail(torso, "Blue running seam", (sign * .67, 1.626, -.715),
                   (.062, .403, .072), edge, roll=sign * 10, shape=BLOCK)
    art.detail(torso, "Back tide crest", (0, 2.566, .818), (.49, .379, .075), cloth)
    art.detail(torso, "Brass tide crest engraving", (0, 2.566, .863),
               (.242, .059, .026), brass, roll=-22, shape=BLOCK)

    head = art.group("Head", (0, 3.818, -.305), (2.08, 1.546, 2.44), (0, 3.11, -.08))
    art.detail(head, "Wide blue-gray shark crown", (0, 3.879, -.073),
               (1.890, 1.378, 1.491), steel, pitch=8)
    art.detail(head, "Sloping slate-blue rostrum", (0, 3.802, -.583),
               (1.765, .781, 1.689), steel, pitch=10)
    art.detail(head, "Smooth pale nose cap", (0, 3.719, -1.033),
               (1.236, .455, .821), shadow, pitch=10)
    art.detail(head, "Lower ivory jaw", (0, 3.457, -.63),
               (1.605, .511, 1.489), ivory, pitch=7)
    art.detail(head, "Upper facing ivory muzzle", (0, 3.572, -.99),
               (1.312, .324, .783), ivory, pitch=11)
    art.detail(head, "Curved charcoal mouth seam", (0, 3.473, -1.105),
               (1.227, .133, .504), ink, pitch=8)
    art.detail(head, "Soft chin highlight", (0, 3.356, -.96),
               (1.005, .174, .775), pearl, pitch=3)
    for sign in (-1, 1):
        art.detail(head, "Smooth ivory jaw transition", (.661 * sign, 3.525, -.48),
                   (.496, .429, .769), ivory, yaw=sign * -16, roll=sign * 12)
        art.detail(head, "Shark brow blue rim", (.609 * sign, 4.049, -.632),
                   (.526, .381, .368), blue, yaw=sign * -29, roll=sign * 15)
        art.detail(head, "Ivory shark eye", (.626 * sign, 4.026, -.785),
                   (.401, .294, .164), pearl, yaw=sign * -30, roll=sign * 12)
        art.detail(head, "Round midnight blue pupil", (.607 * sign, 4.022, -.862),
                   (.176, .194, .075), ink, yaw=sign * -29)
        art.detail(head, "Bright eye highlight", (.595 * sign - .025, 4.078, -.899),
                   (.052, .055, .028), pearl, yaw=sign * -29)
        art.detail(head, "Angled slate eyebrow", (.609 * sign, 4.177, -.745),
                   (.523, .108, .159), deep, yaw=sign * -20, roll=sign * 19)
        art.detail(head, "Small nostril", (.341 * sign, 3.779, -1.382),
                   (.090, .040, .043), deep, roll=sign * 22)
        for tooth, depth in ((.174, -1.338), (.341, -1.317), (.490, -1.253)):
            art.detail(head, "Small rounded ivory tooth", (sign * tooth, 3.472, depth),
                       (.118, .084, .045), pearl, roll=sign * tooth * 31, yaw=sign * tooth * -42)
        for index in range(3):
            art.detail(head, "Curved shark gill seam", (.867 * sign, 3.595 - index * .025, -.106 + index * .130),
                       (.055, .244 - index * .021, .045), deep, pitch=-16, roll=sign * -10)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.213, 2.438, -.097),
                        (1.220, 1.730, 1.611), (sign * .965, 2.97, .02))
        art.detail(arm, "Wide shark fin shoulder", (sign * 1.101, 2.809, .081),
                   (.904, .842, .950), blue, roll=sign * 15)
        art.detail(arm, "Soft pectoral fin edge", (sign * 1.482, 2.638, .239),
                   (.467, .965, .701), steel, roll=sign * 30, pitch=9)
        art.detail(arm, "Ivory inner forearm", (sign * 1.144, 2.255, -.217),
                   (.662, .780, .722), shadow, roll=sign * 14, pitch=-12)
        art.detail(arm, "Rope-bound wrist deck wrap", (sign * 1.226, 2.115, -.308),
                   (.784, .703, .769), cloth, roll=sign * 11, pitch=-13, material=FABRIC)
        for height, depth in ((2.256, -.285), (2.134, -.320), (2.013, -.354)):
            art.detail(arm, "Ivory flat wrap weave", (sign * 1.226, height, depth),
                       (.064, .743, .749), ivory, roll=90 + sign * 11, shape=CYLINDER)
        art.detail(arm, "Slate enclosed glove", (sign * 1.227, 1.904, -.532),
                   (.747, .523, .628), blue)
        art.detail(arm, "Shark glove striking pad", (sign * 1.215, 1.89, -.826),
                   (.577, .288, .124), edge)
        art.detail(arm, "Open dorsal stitching", (sign * 1.255, 1.973, -.867),
                   (.362, .035, .029), shadow, roll=sign * -11)

        leg = art.group(f"{side} Leg", (sign * .49, .78, -.222),
                        (.950, 1.552, 1.432), (sign * .48, 1.44, .025))
        art.detail(leg, "Deep sea cropped trousers", (sign * .49, 1.048, .009),
                   (.893, .940, .926), navy, roll=sign * -10, material=FABRIC)
        art.detail(leg, "Pale shin and deck socks", (sign * .481, .609, -.125),
                   (.653, .883, .683), steel, roll=sign * 9, pitch=10)
        art.detail(leg, "Ivory ankle wrap", (sign * .482, .422, -.254),
                   (.130, .643, .677), ivory, roll=90 + sign * 8, shape=CYLINDER)
        art.detail(leg, "Flat shark boot sole", (sign * .48, .064, -.335),
                   (.626, .104, 1.030), ink, shape=BLOCK)
        art.detail(leg, "Steel-blue deck boot", (sign * .48, .253, -.410),
                   (.724, .427, .901), cloth)
        art.detail(leg, "Shark boot toe pad", (sign * .48, .183, -.856),
                   (.555, .177, .132), edge)

    tail = art.group("Tail", (0, 1.85, 1.166), (.618, 1.247, 1.33), (0, 1.71, .61))
    art.detail(tail, "Short shark tail root", (0, 1.691, .967),
               (.500, .516, .856), steel, pitch=20)
    art.detail(tail, "Rising top leaf of tail fluke", (0, 2.084, 1.429),
               (.309, .749, .600), deep, pitch=22)
    art.detail(tail, "Lower leaf of tail fluke", (0, 1.541, 1.41),
               (.259, .605, .493), blue, pitch=-27)
    art.detail(tail, "Slate tail center highlight", (.021, 1.832, 1.499),
               (.223, .459, .285), steel, pitch=10)


def _kraken(art):
    skin, lilac, deep, glint = "765C99", "A183BB", "4A3865", "C7A4D1"
    coral, salmon, pearl, shell = "CE7465", "EAA184", "FAE0C4", "D79AA6"
    hood, lapel, weave, ink = "302747", "514472", "6A466D", "272338"

    torso = art.group("Torso", (0, 2.297, -.012), (2.162, 2.176, 1.778))
    art.detail(torso, "Purple swimmer chest mantle", (0, 2.447, .022),
               (2.083, 1.793, 1.627), skin)
    art.detail(torso, "Short indigo guardian vest", (0, 2.283, .033),
               (1.989, 1.786, 1.612), hood, material=FABRIC)
    art.detail(torso, "Pale lilac collar", (0, 2.896, -.207), (1.392, .744, 1.213), lilac)
    art.detail(torso, "Satin coral mid-chest panel", (0, 2.533, -.627),
               (.968, .867, .466), weave, pitch=-9, material=FABRIC)
    art.detail(torso, "Broad coral reef sash", (0, 1.800, .017),
               (2.135, .325, 1.589), coral, material=FABRIC)
    art.detail(torso, "Mother-of-pearl sash pin", (0, 1.815, -.807),
               (.308, .257, .088), pearl, roll=-12)
    art.detail(torso, "Single shell line on the pin", (0, 1.818, -.856),
               (.067, .179, .029), salmon, roll=-12)
    for sign in (-1, 1):
        art.detail(torso, "Wide indigo vest lapel", (sign * .452, 2.595, -.658),
                   (.309, .998, .193), lapel, yaw=sign * -10, roll=sign * -24, material=FABRIC)
        art.detail(torso, "Coral piping on guardian vest", (sign * .563, 2.601, -.746),
                   (.063, .885, .068), coral, roll=sign * -24, shape=BLOCK)
        art.detail(torso, "Segmented plum coattail", (sign * .511, 1.606, -.407),
                   (.716, .720, .751), lapel, roll=sign * 12, material=FABRIC)
        art.detail(torso, "Running salmon lower edging", (sign * .767, 1.645, -.669),
                   (.104, .410, .093), salmon, roll=sign * 12)

    head = art.group("Head", (0, 4.028, -.049), (2.245, 1.816, 2.064), (0, 3.15, -.045))
    art.detail(head, "Purple upturned octopus mantle", (0, 4.071, .102),
               (1.942, 1.658, 1.735), skin, pitch=-13)
    art.detail(head, "Rounded crown highlight", (0, 4.469, .008),
               (1.459, .852, 1.526), lilac, pitch=-9)
    art.detail(head, "Soft plum face panel", (0, 3.751, -.485),
               (1.832, 1.203, 1.023), skin, pitch=8)
    art.detail(head, "Wide pale jaw mantel", (0, 3.490, -.461),
               (1.661, .656, 1.03), glint, pitch=7)
    art.detail(head, "Rounded deep plum muzzle", (0, 3.603, -.783),
               (.613, .324, .564), deep)
    art.detail(head, "Small coral lip accent", (0, 3.523, -.990),
               (.269, .082, .060), coral)
    art.detail(head, "Soft focused mouth line", (0, 3.581, -1.014),
               (.393, .054, .072), ink)
    for sign in (-1, 1):
        art.detail(head, "Raised eye ridge", (.549 * sign, 3.948, -.705),
                   (.702, .620, .430), deep, roll=sign * 12, yaw=sign * -13)
        art.detail(head, "Warm pearl eye", (.585 * sign, 3.954, -.860),
                   (.487, .385, .211), pearl, yaw=sign * -17, roll=sign * 13)
        art.detail(head, "Violet outer iris", (.580 * sign, 3.945, -.946),
                   (.258, .280, .086), weave, yaw=sign * -16)
        art.detail(head, "Rounded octopus pupil", (.568 * sign, 3.936, -.986),
                   (.137, .189, .069), ink, yaw=sign * -16)
        art.detail(head, "Bright octopus eye glint", (.564 * sign - .037, 4.004, -1.021),
                   (.064, .059, .038), pearl)
        art.detail(head, "Raised calm brow", (.571 * sign, 4.120, -.862),
                   (.594, .125, .136), deep, roll=sign * 19, yaw=sign * -18)
        art.detail(head, "Mantle corner curl", (.807 * sign, 3.582, -.468),
                   (.394, .674, .670), skin, roll=sign * 26, pitch=-16)
        art.detail(head, "Compact lifted corner curl tip", (.951 * sign, 3.386, -.624),
                   (.304, .277, .554), lilac, roll=sign * 35, pitch=28)
        art.detail(head, "Coral face chromatophore", (.671 * sign, 3.67, -.853),
                   (.183, .099, .075), coral, yaw=sign * -20)
        art.detail(head, "Little curl suction cup", (.957 * sign, 3.376, -.884),
                   (.111, .110, .036), coral, yaw=sign * -18, pitch=24)
    for x, y in ((-.36, 4.53), (-.165, 4.58), (.11, 4.62), (.345, 4.50)):
        art.detail(head, "Pink mantle chromatophore", (x, y, -.622),
                   (.129, .097, .048), shell, yaw=x * -34, pitch=-17)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.232, 2.400, -.091),
                        (1.210, 1.803, 1.708), (sign * 1.04, 3.035, .015))
        art.detail(arm, "Mantle upper tentacle shoulder", (sign * 1.159, 2.817, .119),
                   (.985, .927, .993), skin, roll=sign * 13)
        art.detail(arm, "Lilac stripe on upper tentacle", (sign * 1.395, 2.784, .230),
                   (.644, .673, .772), lilac, roll=sign * 23)
        art.detail(arm, "Muscular tentacle forearm", (sign * 1.306, 2.249, -.238),
                   (.829, 1.00, .875), skin, roll=sign * 10, pitch=-17)
        art.detail(arm, "Coral cloth fighting bind", (sign * 1.283, 2.183, -.367),
                   (.854, .639, .789), coral, roll=sign * 14, material=FABRIC)
        for height, depth in ((2.320, -.343), (2.167, -.414), (2.033, -.465)):
            art.detail(arm, "Pearl tentacle wrap edging", (sign * 1.282, height, depth),
                       (.059, .814, .794), salmon, roll=90 + sign * 11, shape=CYLINDER)
        art.detail(arm, "Rounded coiled tentacle glove", (sign * 1.263, 1.924, -.612),
                   (.773, .568, .582), deep)
        art.detail(arm, "Kraken glove striking pad", (sign * 1.265, 1.923, -.860),
                   (.568, .306, .116), salmon)
        art.detail(arm, "Stitched glove sucker accent", (sign * 1.441, 1.982, -.852),
                   (.136, .134, .083), pearl, yaw=sign * -32)
        art.detail(arm, "Small outer tentacle nub", (sign * 1.608, 2.452, .248),
                   (.358, .623, .526), deep, pitch=-26, roll=sign * 15)

        leg = art.group(f"{side} Leg", (sign * .508, .79, -.195),
                        (1.036, 1.573, 1.402), (sign * .50, 1.44, .035))
        art.detail(leg, "Plum cropped fighting trousers", (sign * .504, 1.082, .014),
                   (.935, .948, .934), hood, roll=sign * -12, material=FABRIC)
        art.detail(leg, "Short padded octopus shin", (sign * .500, .607, -.107),
                   (.684, .889, .674), skin, roll=sign * 9, pitch=10)
        art.detail(leg, "Coral anklet", (sign * .500, .440, -.241),
                   (.12, .678, .653), coral, roll=90 + sign * 8, shape=CYLINDER)
        art.detail(leg, "Flat kraken boot sole", (sign * .50, .067, -.324),
                   (.700, .110, .996), ink, shape=BLOCK)
        art.detail(leg, "Rounded dark indigo foot", (sign * .50, .240, -.395),
                   (.805, .394, .894), deep, yaw=sign * -3)
        art.detail(leg, "Kraken boot toe pad", (sign * .50, .160, -.829),
                   (.596, .149, .122), salmon)

    tail = art.group("Tail", (0, 1.84, .899), (1.810, .865, .927), (0, 1.81, .69))
    art.detail(tail, "Low mantle tail nub", (0, 1.797, .882),
               (.766, .597, .724), deep, pitch=10)
    for sign in (-1, 1):
        art.detail(tail, "Small curled side tentacle", (sign * .443, 1.833, .928),
                   (.655, .376, .681), skin, yaw=sign * 27, roll=sign * 24)
        art.detail(tail, "Uplifted tentacle tip", (sign * .663, 1.992, .950),
                   (.416, .340, .547), lilac, yaw=sign * 32, roll=sign * 25)
        art.detail(tail, "Coral cup under tail curl", (sign * .586, 1.906, .728),
                   (.113, .112, .070), coral, yaw=sign * 27)


def build_abyss_roster_visuals(library, *, item, part, prop, vector):
    """Build the shark and playable kraken from native rigid ornaments."""
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    _shark(_FighterArt(library, "great-white-shark", **helpers))
    _kraken(_FighterArt(library, "abyssal-kraken", **helpers))
