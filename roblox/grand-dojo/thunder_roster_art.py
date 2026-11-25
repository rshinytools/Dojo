"""Original floor-aligned fighter shells for the Sky element roster."""

from math import atan2, degrees, hypot

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _stroke(art, group, name, start, end, width, depth, tint):
    """Lay a flat piece of embroidery between two points on the costume."""
    dx, dy = (end[axis] - start[axis] for axis in (0, 1))
    center = ((start[0] + end[0]) / 2, (start[1] + end[1]) / 2, start[2])
    art.detail(group, name, center, (width, hypot(dx, dy) + width * .55, depth), tint,
               shape=BLOCK, roll=degrees(atan2(-dx, dy)))


def _owl(art):
    midnight, indigo, violet = "24304E", "38496D", "54547C"
    dusk, teal, seafoam = "2D4C62", "337975", "66B8AB"
    parchment, ivory, feather = "D3C5A3", "F1E1BB", "B4A5A0"
    ochre, gold, silk = "94613E", "DDA85D", "FFD780"
    ink, iris = "151D32", "8CD3B9"

    torso = art.group("Torso", (0, 2.306, -.031), (2.012, 2.105, 1.681))
    art.detail(torso, "Rounded owl chest", (0, 2.415, .036), (1.83, 1.731, 1.39), indigo)
    art.detail(torso, "Heavy indigo flight jacket", (0, 2.218, -.037), (1.88, 1.46, 1.39),
               midnight, material=FABRIC)
    art.detail(torso, "Pale feathers under the collar", (0, 2.991, -.24), (1.19, .69, .98),
               parchment, pitch=12)
    art.detail(torso, "Feathered breast panel", (0, 2.656, -.626), (.90, .98, .44),
               feather, pitch=-9)
    art.detail(torso, "Folded dark tailcoat hem", (0, 1.639, .22), (1.67, .67, 1.17),
               midnight, material=FABRIC)
    art.detail(torso, "Wide woven teal sash", (0, 1.815, -.009), (1.85, .304, 1.414),
               teal, material=FABRIC)
    art.detail(torso, "Brass sash braid", (0, 1.851, -.711), (1.35, .074, .074), gold)
    for sign in (-1, 1):
        art.detail(torso, "Angled teal lapel", (sign * .326, 2.687, -.665), (.257, .88, .162),
                   teal, roll=sign * -32, yaw=sign * -15, shape=BLOCK, material=FABRIC)
        art.detail(torso, "Fine brass lapel seam", (sign * .437, 2.724, -.703), (.054, .72, .072),
                   gold, roll=sign * -32, yaw=sign * -15, shape=BLOCK)
        art.detail(torso, "Short beaded tabard", (sign * .32, 1.575, -.46), (.58, .61, .51),
                   dusk, roll=sign * -12, material=FABRIC)
        art.detail(torso, "Pale tabard seam", (sign * .49, 1.542, -.67), (.068, .44, .061),
                   seafoam, roll=sign * -8, shape=BLOCK)
    art.detail(torso, "Diamond thunder badge", (0, 2.482, -.799), (.297, .297, .084), ochre,
               roll=45, shape=BLOCK)
    trace = ((.042, 2.607, -.854), (-.071, 2.470, -.854), (.048, 2.470, -.854), (-.026, 2.365, -.854))
    for index, (start, end) in enumerate(zip(trace, trace[1:]), 1):
        _stroke(art, torso, f"Lightning embroidery {index}", start, end, .038, .023, silk)

    head = art.group("Head", (0, 4.027, -.172), (1.953, 1.828, 1.762), (0, 3.16, -.045))
    art.detail(head, "Indigo head feathers", (0, 3.849, .048), (1.82, 1.45, 1.30), indigo)
    art.detail(head, "Scalloped lower face ruff", (0, 3.548, -.192), (1.61, .69, 1.02), dusk)
    art.detail(head, "Forehead indigo plume", (0, 4.324, .071), (1.52, .682, 1.13), violet)
    art.detail(head, "Clipped ceremonial forehead point", (0, 4.249, -.58), (.331, .487, .227),
               midnight, pitch=-11)
    art.detail(head, "Gold diadem inset", (0, 4.372, -.682), (.146, .146, .060), gold,
               roll=45, shape=BLOCK)
    art.detail(head, "Upper hooked beak", (0, 3.88, -.855), (.403, .33, .338), gold, pitch=16)
    art.detail(head, "Rounded beak hook", (0, 3.735, -.959), (.236, .234, .15), ochre, pitch=-23)
    art.detail(head, "Beak ridge sheen", (-.029, 3.932, -.995), (.119, .064, .038), silk)
    for sign in (-1, 1):
        art.detail(head, "Raked owl ear plume", (sign * .617, 4.447, .12), (.439, .61, .416),
                   indigo, roll=sign * -29, pitch=-16)
        art.detail(head, "Pointed crown plume", (sign * .671, 4.518, .103), (.275, .739, .291),
                   indigo, roll=sign * -28, pitch=-12, class_name="WedgePart")
        art.detail(head, "Pale inner ear feather", (sign * .646, 4.498, -.054), (.175, .412, .106),
                   parchment, roll=sign * -28, pitch=-12)
        art.detail(head, "Teal disc feather border", (sign * .437, 3.876, -.47), (.95, 1.067, .493),
                   teal, yaw=sign * -17, roll=sign * 8)
        art.detail(head, "Ivory owl face disc", (sign * .416, 3.861, -.602), (.814, .904, .343),
                   ivory, yaw=sign * -14, roll=sign * 8)
        art.detail(head, "Dark eye ring", (sign * .423, 3.974, -.749), (.565, .577, .162),
                   midnight, yaw=sign * -12, roll=sign * 6)
        art.detail(head, "Mint ringed owl eye", (sign * .412, 3.974, -.815), (.441, .455, .132),
                   iris, yaw=sign * -12)
        art.detail(head, "Deep indigo round pupil", (sign * .393, 3.973, -.882), (.247, .290, .075),
                   ink, yaw=sign * -12)
        art.detail(head, "Large eye catchlight", (sign * .393 - .046, 4.038, -.92),
                   (.098, .103, .027), "FFF8DE")
        art.detail(head, "Slanted indigo brow", (sign * .439, 4.198, -.765), (.591, .132, .184),
                   midnight, yaw=sign * -14, roll=sign * 19)
        art.detail(head, "Lower ruff feather", (sign * .646, 3.586, -.594), (.403, .316, .151),
                   parchment, yaw=sign * -27, roll=sign * 37)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.134, 2.410, -.018), (1.046, 1.604, 1.452),
                        (sign * .935, 3.03, .055))
        art.detail(arm, "Layered indigo shoulder mantle", (sign * 1.034, 2.769, .115),
                   (.823, .868, .891), indigo, roll=sign * 12)
        art.detail(arm, "Colored shoulder feather ridge", (sign * 1.217, 2.873, .12),
                   (.596, .513, .788), violet, roll=sign * 18)
        art.detail(arm, "Folded teal wing", (sign * 1.203, 2.374, .169), (.749, 1.20, 1.01),
                   dusk, pitch=-12, roll=sign * 14)
        for index, (x, y, z, length, tilt) in enumerate(((1.20, 2.21, .383, 1.28, -14),
                                                        (1.31, 2.18, .45, 1.24, -22),
                                                        (1.36, 2.25, .32, 1.05, -26)), 1):
            art.detail(arm, f"Layered flight feather {index}", (sign * x, y, z),
                       (.382, length, .338), teal if index == 2 else indigo,
                       pitch=-19, roll=sign * tilt)
        art.detail(arm, "Leather wing guard", (sign * 1.185, 2.142, -.315),
                   (.622, .718, .626), midnight, roll=sign * 13)
        art.detail(arm, "Wide brass wing cuff", (sign * 1.175, 2.166, -.381), (.174, .642, .637),
                   gold, shape=CYLINDER, roll=90 + sign * 13)
        art.detail(arm, "Rounded leading strike pad", (sign * 1.185, 1.96, -.500),
                   (.615, .452, .418), teal, roll=sign * 10)
        art.detail(arm, "Pale leading pad piping", (sign * 1.185, 1.96, -.705),
                   (.360, .105, .057), seafoam, roll=sign * 10)

        leg = art.group(f"{side} Leg", (sign * .472, .776, -.184), (.783, 1.552, 1.276),
                        (sign * .472, 1.50, .02))
        art.detail(leg, "Dark flight trousers", (sign * .472, 1.092, .052), (.756, .905, .781),
                   midnight, roll=sign * -11, material=FABRIC)
        art.detail(leg, "Rounded owl hock", (sign * .468, .565, -.074), (.502, .834, .554),
                   ochre, pitch=14, roll=sign * 7)
        art.detail(leg, "Teal flight boot cuff", (sign * .48, .486, -.135), (.158, .587, .631),
                   teal, shape=CYLINDER, roll=90 + sign * 8, material=FABRIC)
        art.detail(leg, "Thin ankle braid", (sign * .48, .445, -.151), (.066, .572, .613),
                   gold, shape=CYLINDER, roll=90 + sign * 8)
        art.detail(leg, "Flat padded owl sole", (sign * .48, .061, -.28), (.60, .102, .90),
                   midnight, shape=BLOCK)
        art.detail(leg, "Curved ochre forefoot", (sign * .48, .235, -.345), (.665, .332, .843),
                   ochre)
        for toe, x in enumerate((-.192, 0, .192), 1):
            art.detail(leg, f"Blunt owl toe cap {toe}", (sign * .48 + x, .176, -.722),
                       (.153, .186, .179), gold, yaw=x * -40)

    tail = art.group("Tail", (0, 1.602, .964), (1.016, .677, 1.135), (0, 1.76, .59))
    art.detail(tail, "Layered tail base", (0, 1.689, .733), (.894, .468, .662), indigo, pitch=14)
    for index, x in enumerate((-.289, 0, .289), 1):
        art.detail(tail, f"Swept fan feather {index}", (x, 1.481, 1.054),
                   (.369, .33, .967), teal if index == 2 else dusk, yaw=x * 46, pitch=16)
        art.detail(tail, f"Muted gold tail bar {index}", (x * 1.2, 1.414, 1.348),
                   (.293, .277, .164), gold, yaw=x * 46, pitch=16)


def _horn(art, head, sign, bone, sand, shade):
    # Tapered links wrap forward beside the muzzle, then curl back toward the cheek.
    path = ((.527, 4.208, .189, .317), (.758, 4.364, .032, .309),
            (.986, 4.308, -.209, .279), (1.096, 4.123, -.473, .244),
            (1.103, 3.942, -.696, .199), (1.018, 3.741, -.697, .154),
            (.879, 3.669, -.610, .107), (.821, 3.761, -.476, .057))
    for index, (start, end) in enumerate(zip(path, path[1:]), 1):
        sx, sy, sz, r1 = start
        ex, ey, ez, r2 = end
        dx, dy, dz = sign * (ex - sx), ey - sy, ez - sz
        center = (sign * (sx + ex) / 2, (sy + ey) / 2, (sz + ez) / 2)
        pitch = degrees(atan2(-dy, hypot(dx, dz)))
        yaw = degrees(atan2(dx, dz))
        diameter = r1 + r2
        art.detail(head, f"Curved horn section {index}", center,
                   (diameter, diameter * .93, hypot(dx, dy, dz) + diameter * .76),
                   bone if index in (3, 5, 7) else sand, pitch=pitch, yaw=yaw)
        if index in (1, 2, 4):
            # Low, darker keratin ridges wrap the horn without interrupting its outer silhouette.
            art.detail(head, f"Horn growth seam {index}", center,
                       (diameter * 1.012, diameter * .942, .085), shade, pitch=pitch, yaw=yaw)


def _ram(art):
    walnut, fur, rust = "653C37", "9D614E", "B36E52"
    sand, bone, ivory = "CEA178", "ECC9A1", "FAE9C8"
    leather, lacquer, lining = "502D37", "753D47", "A75B50"
    bronze, copper, honey = "895630", "B77E46", "E6AE6E"
    umber, ink, iris = "503833", "2E252B", "C28952"

    torso = art.group("Torso", (0, 2.278, -.073), (2.221, 2.191, 1.784))
    art.detail(torso, "Broad russet ram chest", (0, 2.413, .048), (2.148, 1.90, 1.52), fur)
    art.detail(torso, "Thick weathered leather jacket", (0, 2.269, -.012), (2.11, 1.79, 1.52),
               leather, material=FABRIC)
    art.detail(torso, "Cream chest ruff", (0, 2.937, -.226), (1.737, .79, 1.13), bone)
    art.detail(torso, "Burnished copper chest plate", (0, 2.521, -.621), (1.451, 1.085, .554), copper,
               pitch=-8)
    art.detail(torso, "Inset amber breastplate panel", (0, 2.534, -.813), (1.01, .765, .255),
               bronze, pitch=-8)
    art.detail(torso, "Crimson undercoat hem", (0, 1.576, .03), (1.902, .713, 1.429),
               lining, material=FABRIC)
    art.detail(torso, "Wide walnut sparring belt", (0, 1.754, -.04), (2.17, .329, 1.578),
               leather, material=FABRIC)
    art.detail(torso, "Layered round copper buckle", (0, 1.751, -.823), (.153, .396, .396),
               copper, yaw=90, shape=CYLINDER)
    art.detail(torso, "Diamond clasp emblem", (0, 1.751, -.904), (.16, .16, .068),
               honey, shape=BLOCK, roll=45)
    for sign in (-1, 1):
        art.detail(torso, "Padded outer chest rim", (sign * .809, 2.535, -.497), (.492, .979, .618),
                   lining, roll=sign * 21, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Short split leather coat panel", (sign * .43, 1.547, -.47), (.782, .704, .61),
                   lacquer, roll=sign * 12, material=FABRIC)
        art.detail(torso, "Angled bound lower seam", (sign * .621, 1.529, -.736), (.057, .501, .082),
                   honey, shape=BLOCK, roll=sign * 12)
        art.detail(torso, "Ivory inner shoulder fleece", (sign * .699, 2.993, -.355), (.676, .631, .659),
                   sand, roll=sign * -19)
    trace = ((.126, 2.792, -.942), (-.119, 2.580, -.942),
             (.109, 2.580, -.942), (-.077, 2.337, -.942))
    for index, (start, end) in enumerate(zip(trace, trace[1:]), 1):
        _stroke(art, torso, f"Incised chest bolt {index}", start, end, .058, .025, honey)

    head = art.group("Head", (0, 3.924, -.313), (2.668, 1.400, 1.791), (0, 3.23, -.05))
    art.detail(head, "Compact ram skull", (0, 3.851, -.054), (1.59, 1.232, 1.252), fur)
    art.detail(head, "Cream jaw fleece", (0, 3.52, -.237), (1.395, .551, .971), bone, pitch=10)
    art.detail(head, "Ram muzzle bridge", (0, 3.708, -.537), (.985, .585, .924), rust, pitch=13)
    art.detail(head, "Squared pale muzzle cheeks", (0, 3.562, -.825), (.879, .437, .580), bone, pitch=9)
    art.detail(head, "Dark split ram nose", (0, 3.676, -1.096), (.465, .229, .203), walnut)
    art.detail(head, "Short central nose crease", (0, 3.570, -1.105), (.056, .144, .049),
               umber, shape=BLOCK)
    art.detail(head, "Gold ram forehead plate", (0, 4.124, -.465), (.738, .456, .366), bronze,
               pitch=7)
    art.detail(head, "Pale forehead star", (0, 4.121, -.667), (.216, .216, .074), honey,
               roll=45, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(head, "Pale cheek fleece", (sign * .438, 3.617, -.464), (.649, .578, .596), sand,
                   yaw=sign * -20, roll=sign * 10)
        art.detail(head, "Side ear behind the horn", (sign * .704, 3.878, .306), (.508, .272, .53), rust,
                   yaw=sign * 30, roll=sign * 23)
        art.detail(head, "Ram's pale eye white", (sign * .442, 3.901, -.591), (.395, .294, .21), ivory,
                   yaw=sign * -16, roll=sign * 14)
        art.detail(head, "Golden ram iris", (sign * .431, 3.902, -.686), (.201, .201, .129), iris,
                   yaw=sign * -16)
        art.detail(head, "Horizontal ram pupil", (sign * .42, 3.901, -.746), (.145, .084, .056),
                   ink, yaw=sign * -14)
        art.detail(head, "Eye catchlight", (sign * .420 - .025, 3.947, -.773), (.048, .059, .032), ivory)
        art.detail(head, "Low walnut brow", (sign * .458, 4.051, -.626), (.459, .141, .18), walnut,
                   yaw=sign * -15, roll=sign * 18)
        _horn(art, head, sign, bone, sand, "B58562")

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.171, 2.419, -.146), (1.031, 1.644, 1.391),
                        (sign * 1.035, 3.01, .09))
        art.detail(arm, "High heavy shoulder plate", (sign * 1.154, 2.805, .046),
                   (.985, .837, .985), leather, roll=sign * 16)
        art.detail(arm, "Overlapping copper pauldron", (sign * 1.262, 2.906, -.009),
                   (.846, .609, .865), copper, roll=sign * 17)
        art.detail(arm, "Raised gold plate bead", (sign * 1.313, 2.925, -.352),
                   (.617, .229, .257), honey, roll=sign * 20)
        art.detail(arm, "Wool forearm", (sign * 1.262, 2.289, -.212), (.740, .967, .722), rust,
                   pitch=-17, roll=sign * 11)
        art.detail(arm, "Thick crimson striking wrap", (sign * 1.265, 2.10, -.376),
                   (.773, .729, .745), lacquer, pitch=-17, roll=sign * 11, material=FABRIC)
        art.detail(arm, "Bronze-bound wrap fold", (sign * 1.257, 2.166, -.390), (.097, .762, .754),
                   lining, shape=CYLINDER, roll=90 + sign * 11)
        art.detail(arm, "Heavy copper glove", (sign * 1.25, 1.869, -.549), (.735, .522, .475), copper)
        art.detail(arm, "Cushioned thumb", (sign * 1.012, 1.944, -.579), (.365, .392, .341), bronze)
        art.detail(arm, "Glove striking face", (sign * 1.25, 1.879, -.774), (.451, .196, .114), honey)

        leg = art.group(f"{side} Leg", (sign * .56, .758, -.199), (.913, 1.516, 1.396),
                        (sign * .56, 1.53, .04))
        art.detail(leg, "Broad reinforced trouser leg", (sign * .56, 1.042, .04),
                   (.89, .929, .897), leather, roll=sign * -12, material=FABRIC)
        art.detail(leg, "Cream wool hock", (sign * .576, .620, -.092), (.631, .778, .721), sand,
                   pitch=11, roll=sign * 9)
        art.detail(leg, "Cushioned red greave", (sign * .578, .581, -.327), (.574, .602, .508), lacquer,
                   pitch=13, roll=sign * 8)
        art.detail(leg, "Warm greave head", (sign * .578, .669, -.525), (.469, .227, .215), copper,
                   pitch=13, roll=sign * 8)
        art.detail(leg, "Flat hoof boot sole", (sign * .55, .075, -.305), (.75, .13, 1.06),
                   ink, shape=BLOCK)
        art.detail(leg, "Rounded ram boot", (sign * .55, .235, -.371), (.779, .389, 1.031), umber)
        for x in (-.177, .177):
            art.detail(leg, "Two-part hoof toe steel", (sign * .55 + x, .230, -.744),
                       (.333, .229, .247), bronze, yaw=x * 24)

    tail = art.group("Tail", (.031, 1.625, 1.025), (.594, .614, .803), (0, 1.72, .74))
    art.detail(tail, "Short russet ram tail", (.031, 1.655, .96), (.572, .477, .694), fur,
               pitch=28, yaw=5)
    art.detail(tail, "Cream fleece on tail tip", (.052, 1.538, 1.202), (.509, .369, .441), bone,
               pitch=28, yaw=5)
    art.detail(tail, "Warm wool curl", (.044, 1.466, 1.274), (.337, .279, .236), sand,
               pitch=23, yaw=7)


def build_thunder_roster_visuals(library, *, item, part, prop, vector):
    """Build the two native shells without external asset dependencies."""
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    _owl(_FighterArt(library, "electric-owl", **helpers))
    _ram(_FighterArt(library, "bighorn-ram", **helpers))
