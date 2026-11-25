"""Original floor-aligned rigid shells for two Land fighters."""

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _badger(art):
    charcoal, slate, ash = "292E36", "47505A", "5E6871"
    silver, cream, ivory = "ADACA5", "D8D1BB", "F2E6C9"
    belt, leather, rush, amber = "473838", "6D4B35", "B57939", "EAB45D"
    eye, ink = "C8914D", "282029"

    torso = art.group("Torso", (0, 2.20, -.065), (2.17, 2.12, 1.82))
    art.detail(torso, "Wide charcoal fighting jacket", (0, 2.27, .035),
               (1.96, 1.78, 1.46), charcoal, material=FABRIC)
    art.detail(torso, "Silver mantle across back", (0, 2.734, .461),
               (1.822, 1.046, .761), silver, pitch=8)
    art.detail(torso, "Ivory fur at top of mantle", (0, 3.007, .101),
               (1.37, .451, 1.115), cream)
    art.detail(torso, "Ribbed slate inner jacket", (0, 2.54, -.53),
               (1.38, .974, .52), slate, material=FABRIC)
    art.detail(torso, "Wide rough leather sash", (0, 1.712, -.026),
               (1.895, .331, 1.45), belt, material=FABRIC)
    art.detail(torso, "Bronze honeycomb clasp", (.015, 1.714, -.771),
               (.12, .349, .349), rush, yaw=90, shape=CYLINDER)
    art.detail(torso, "Raised clasp center", (.015, 1.714, -.838),
               (.116, .116, .037), amber, roll=45, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(torso, "Padded folded charcoal lapel", (sign * .259, 2.572, -.672),
                   (.28, .983, .183), ash, roll=sign * -32, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Fine honey-thread lapel binding", (sign * .389, 2.629, -.742),
                   (.057, .741, .076), amber, roll=sign * -32, yaw=sign * -14, shape=BLOCK)
        art.detail(torso, "Split charcoal waist panel", (sign * .467, 1.541, -.529),
                   (.692, .618, .646), slate, roll=sign * 13, material=FABRIC)
        art.detail(torso, "Amber bound coat seam", (sign * .703, 1.541, -.774),
                   (.054, .463, .078), rush, roll=sign * 13, shape=BLOCK)
        art.detail(torso, "Brass sash eyelet", (sign * .50, 1.716, -.747),
                   (.125, .109, .062), rush)

    head = art.group("Head", (0, 3.729, -.273), (1.947, 1.398, 1.905), (0, 3.02, -.07))
    art.detail(head, "Broad badger skull", (0, 3.69, .014), (1.747, 1.292, 1.298), charcoal)
    art.detail(head, "Fine silver badger crown", (0, 4.024, -.032),
               (1.667, .665, 1.341), silver, pitch=5)
    art.detail(head, "Pale crown swept to the muzzle", (0, 3.962, -.495),
               (1.457, .452, .857), cream, pitch=15)
    art.detail(head, "Cream central forehead break", (0, 3.844, -.752),
               (.528, .332, .503), ivory, pitch=14)
    art.detail(head, "Low dark badger jaw", (0, 3.437, -.338),
               (1.482, .632, 1.10), slate, pitch=7)
    art.detail(head, "Tapered slate snout bridge", (0, 3.61, -.691),
               (.949, .521, .898), charcoal, pitch=11)
    art.detail(head, "Dark flattened badger nose", (0, 3.644, -1.064),
               (.467, .245, .274), ink, pitch=7)
    art.detail(head, "Small nose shine", (-.044, 3.715, -1.190),
               (.173, .055, .038), ash)
    art.detail(head, "Short closed mouth", (0, 3.472, -.994),
               (.48, .047, .045), ink)
    for sign in (-1, 1):
        art.detail(head, "Low rounded outer ear", (sign * .662, 4.068, .261),
                   (.465, .392, .357), charcoal, roll=sign * 27)
        art.detail(head, "Quiet warm inner ear", (sign * .687, 4.071, .097),
                   (.285, .222, .151), leather, roll=sign * 27)
        art.detail(head, "Dark slash under the crown", (sign * .475, 3.79, -.518),
                   (.736, .504, .49), charcoal, yaw=sign * -25, roll=sign * 12)
        art.detail(head, "Tawny honey-brown eye", (sign * .404, 3.795, -.760),
                   (.308, .221, .139), eye, yaw=sign * -17, roll=sign * 12)
        art.detail(head, "Rounded focused pupil", (sign * .388, 3.789, -.822),
                   (.147, .136, .051), ink, yaw=sign * -15)
        art.detail(head, "Tiny badger eye catchlight", (sign * .388 - .025, 3.82, -.850),
                   (.048, .052, .028), ivory)
        art.detail(head, "Slate angled eyebrow", (sign * .407, 3.911, -.746),
                   (.415, .122, .174), slate, yaw=sign * -16, roll=sign * 19)
        art.detail(head, "Short sideburn tuft", (sign * .65, 3.564, -.321),
                   (.543, .462, .543), ash, yaw=sign * -21, roll=sign * 26)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.124, 2.373, -.148),
                        (1.075, 1.625, 1.467), (sign * .96, 2.92, .055))
        art.detail(arm, "Rounded strong charcoal shoulder", (sign * 1.072, 2.737, .087),
                   (.94, .861, .956), charcoal, roll=sign * 14)
        art.detail(arm, "Pale badger shoulder ridge", (sign * 1.198, 2.863, .118),
                   (.731, .464, .799), silver, roll=sign * 18)
        art.detail(arm, "Slate forearm", (sign * 1.252, 2.191, -.203),
                   (.774, .965, .768), slate, roll=sign * 12, pitch=-14)
        art.detail(arm, "Amber wrestling handwrap", (sign * 1.237, 2.047, -.369),
                   (.78, .72, .757), leather, roll=sign * 11, pitch=-17, material=FABRIC)
        for y, z in ((2.236, -.322), (2.104, -.371), (1.972, -.418)):
            art.detail(arm, "Honey-colored wrap fold", (sign * 1.221, y, z),
                       (.076, .752, .752), rush, roll=90 + sign * 11, shape=CYLINDER)
        art.detail(arm, "Soft amber enclosed paw", (sign * 1.193, 1.844, -.558),
                   (.8, .535, .54), amber)
        art.detail(arm, "Badger glove striking pad", (sign * 1.17, 1.86, -.805),
                   (.525, .266, .11), rush)
        for segment in (-1, 1):
            art.detail(arm, "Blunt stitched knuckle patch", (sign * 1.17 + segment * .16, 1.88, -.835),
                       (.133, .143, .044), ivory)

        leg = art.group(f"{side} Leg", (sign * .48, .771, -.185),
                        (.917, 1.544, 1.435), (sign * .48, 1.46, .025))
        art.detail(leg, "Short powerful charcoal trouser leg", (sign * .48, 1.052, .031),
                   (.841, .892, .859), charcoal, roll=sign * -11, material=FABRIC)
        art.detail(leg, "Slate shin support", (sign * .486, .608, -.109),
                   (.647, .834, .638), slate, roll=sign * 9, pitch=10)
        art.detail(leg, "Warm striped wrestling boot cuff", (sign * .484, .458, -.231),
                   (.189, .624, .65), leather, shape=CYLINDER, roll=90 + sign * 7)
        art.detail(leg, "Bright ankle braid", (sign * .485, .414, -.241),
                   (.057, .617, .638), amber, shape=CYLINDER, roll=90 + sign * 7)
        art.detail(leg, "Flat badger boot sole", (sign * .48, .067, -.30),
                   (.630, .106, 1.020), charcoal, shape=BLOCK)
        art.detail(leg, "Low charcoal wrestling boot", (sign * .48, .234, -.395),
                   (.737, .403, .909), belt)
        art.detail(leg, "Badger boot toe pad", (sign * .48, .17, -.798),
                   (.541, .194, .124), rush)

    tail = art.group("Tail", (0, 1.613, .933), (.644, .542, .744), (0, 1.66, .59))
    art.detail(tail, "Short rough badger tail", (0, 1.604, .899),
               (.612, .471, .654), charcoal, pitch=16)
    art.detail(tail, "Silver badger tail back", (0, 1.721, .945),
               (.42, .249, .627), ash, pitch=15)
    art.detail(tail, "Small cream tail tip", (0, 1.557, 1.125),
               (.344, .322, .326), silver, pitch=18)


def _saber(art):
    tawny, ochre, honey, cream = "C69B66", "A47856", "DBB584", "EFE0B3"
    sage, fern, emerald, deep = "9DAB84", "4C7655", "307555", "254D43"
    jade, mint, bronze = "61A778", "A5D395", "C48F52"
    leather, dark, ink = "5C4539", "574035", "2C3230"

    torso = art.group("Torso", (0, 2.308, -.007), (2.145, 2.246, 1.78))
    art.detail(torso, "Strong tawny saber chest", (0, 2.468, .032),
               (2.091, 1.876, 1.456), tawny)
    art.detail(torso, "Dark green watchkeeper jacket", (0, 2.314, .015),
               (2.018, 1.748, 1.481), deep, material=FABRIC)
    art.detail(torso, "Soft sage collar lining", (0, 2.966, -.252),
               (1.529, .837, 1.244), sage, pitch=8)
    art.detail(torso, "Pale chest bib", (0, 2.631, -.604),
               (.818, 1.113, .449), cream, pitch=-9)
    art.detail(torso, "Broad warm brown belt", (0, 1.817, -.026),
               (1.996, .334, 1.465), leather, material=FABRIC)
    art.detail(torso, "Shield-shaped belt medallion", (0, 1.820, -.782),
               (.295, .295, .105), bronze, roll=45, shape=BLOCK)
    art.detail(torso, "Emerald diamond belt inset", (0, 1.820, -.844),
               (.16, .16, .052), jade, roll=45, shape=BLOCK)
    art.detail(torso, "Back peak medallion", (0, 2.491, .763),
               (.521, .521, .115), emerald, roll=45, shape=BLOCK)
    art.detail(torso, "Back medallion center", (0, 2.491, .827),
               (.263, .263, .061), mint, roll=45, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(torso, "Emerald folded lapel", (sign * .407, 2.65, -.674),
                   (.312, .908, .199), emerald, yaw=sign * -17, roll=sign * -31, material=FABRIC)
        art.detail(torso, "Pale braid along lapel", (sign * .532, 2.696, -.758),
                   (.068, .788, .054), mint, yaw=sign * -17, roll=sign * -31, shape=BLOCK)
        art.detail(torso, "Watchkeeper split-tail panel", (sign * .471, 1.587, -.439),
                   (.768, .753, .625), fern, roll=sign * 12, material=FABRIC)
        art.detail(torso, "Low edged coat seam", (sign * .703, 1.565, -.695),
                   (.063, .517, .079), bronze, roll=sign * 12, shape=BLOCK)

    head = art.group("Head", (0, 3.9, -.22), (2.065, 1.514, 1.91), (0, 3.12, -.09))
    art.detail(head, "Broad tawny saber head", (0, 3.947, -.011),
               (1.882, 1.381, 1.456), tawny)
    art.detail(head, "Pale sage cheek ruff", (0, 3.528, -.072),
               (1.683, .713, 1.291), sage, pitch=9)
    art.detail(head, "Tawny upper snout bridge", (0, 3.773, -.548),
               (1.039, .684, .914), honey, pitch=12)
    art.detail(head, "Small lower feline chin", (0, 3.399, -.588),
               (.973, .291, .635), ochre, pitch=8)
    art.detail(head, "Dark horizontal mouth line", (0, 3.478, -.857),
               (.968, .065, .163), dark)
    art.detail(head, "Rounded charcoal feline nose", (0, 3.721, -1.034),
               (.461, .239, .229), ink, pitch=12)
    art.detail(head, "Fine nose ridge highlight", (-.039, 3.787, -1.134),
               (.198, .05, .045), dark)
    art.detail(head, "Pale forehead leaf accent", (0, 4.241, -.674),
               (.29, .353, .121), sage, pitch=-14, roll=28)
    art.detail(head, "Small watchkeeper brow stone", (0, 4.289, -.724),
               (.128, .128, .056), emerald, roll=45, shape=BLOCK)
    for sign in (-1, 1):
        art.detail(head, "Rounded watchful cat ear", (sign * .668, 4.379, .016),
                   (.453, .498, .498), ochre, roll=sign * 28, yaw=sign * -13)
        art.detail(head, "Sage inner ear oval", (sign * .696, 4.392, -.177),
                   (.295, .325, .161), sage, roll=sign * 29, yaw=sign * -11)
        art.detail(head, "Thick sage cheek tuft", (sign * .676, 3.634, -.235),
                   (.643, .697, .839), sage, roll=sign * 32, yaw=sign * -21)
        art.detail(head, "Wide light feline muzzle pad", (sign * .303, 3.618, -.836),
                   (.587, .426, .551), cream, yaw=sign * -14, roll=sign * 9)
        art.detail(head, "Ivory cartoon saber fang shoulder", (sign * .367, 3.449, -1.017),
                   (.194, .319, .185), cream, roll=sign * 11, pitch=-9)
        art.detail(head, "Rounded inward saber fang tip", (sign * .341, 3.307, -1.008),
                   (.115, .232, .13), "F5E6BE", roll=sign * 14, pitch=-13)
        art.detail(head, "Broad amber brow rim", (sign * .435, 3.979, -.557),
                   (.585, .472, .387), ochre, yaw=sign * -18, roll=sign * 14)
        art.detail(head, "Pale eye with emerald edge", (sign * .425, 3.978, -.695),
                   (.468, .300, .234), cream, yaw=sign * -19, roll=sign * 12)
        art.detail(head, "Emerald saber iris", (sign * .412, 3.971, -.792),
                   (.237, .244, .105), jade, yaw=sign * -15)
        art.detail(head, "Vertical saber pupil", (sign * .405, 3.970, -.838),
                   (.099, .174, .061), ink, yaw=sign * -15, roll=sign * 6)
        art.detail(head, "Saber eye catchlight", (sign * .405 - .024, 4.016, -.871),
                   (.046, .052, .028), cream)
        art.detail(head, "Sage angled upper eyelid", (sign * .435, 4.112, -.709),
                   (.545, .132, .211), sage, yaw=sign * -19, roll=sign * 16)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.169, 2.46, -.18),
                        (1.223, 1.761, 1.511), (sign * 1.015, 3.04, .055))
        art.detail(arm, "Padded sage shoulder quilt", (sign * 1.102, 2.843, .045),
                   (1.059, .942, 1.021), fern, roll=sign * 17, material=FABRIC)
        art.detail(arm, "Broad curved emerald shoulder plate", (sign * 1.295, 2.985, -.037),
                   (.952, .617, .929), emerald, roll=sign * 16)
        art.detail(arm, "Raked jade shoulder blade ridge", (sign * 1.367, 3.055, -.142),
                   (.672, .366, .724), jade, roll=sign * 25)
        art.detail(arm, "Mint edge of the shoulder plate", (sign * 1.407, 2.968, -.432),
                   (.453, .194, .223), mint, roll=sign * 24)
        art.detail(arm, "Tawny padded forearm", (sign * 1.304, 2.267, -.214),
                   (.74, .926, .804), tawny, pitch=-13, roll=sign * 11)
        art.detail(arm, "Rough green forearm wrap", (sign * 1.321, 2.097, -.404),
                   (.768, .755, .729), deep, pitch=-15, roll=sign * 11, material=FABRIC)
        for y, z, tint in ((2.229, -.360, jade), (2.095, -.417, bronze)):
            art.detail(arm, "Watchkeeper wrap piping", (sign * 1.318, y, z),
                       (.088, .766, .754), tint, shape=CYLINDER, roll=90 + sign * 11)
        art.detail(arm, "Broad cushioned claw glove", (sign * 1.283, 1.868, -.585),
                   (.791, .533, .605), fern)
        art.detail(arm, "Saber glove striking pad", (sign * 1.255, 1.865, -.858),
                   (.502, .271, .114), jade)
        for ridge in (-1, 1):
            art.detail(arm, "Rounded pale glove knuckle ridge", (sign * 1.255 + ridge * .157, 1.891, -.883),
                       (.13, .144, .048), mint)

        leg = art.group(f"{side} Leg", (sign * .53, .780, -.20), (.947, 1.56, 1.49),
                        (sign * .52, 1.54, .035))
        art.detail(leg, "Green arena trousers", (sign * .532, 1.074, .034),
                   (.887, .931, .858), deep, roll=sign * -11, material=FABRIC)
        art.detail(leg, "Tawny cat shin", (sign * .54, .595, -.144),
                   (.645, .887, .692), ochre, pitch=12, roll=sign * 8)
        art.detail(leg, "Curved emerald shin guard", (sign * .539, .586, -.413),
                   (.582, .625, .388), emerald, pitch=12, roll=sign * 7)
        art.detail(leg, "Shin guard leaf ridge", (sign * .542, .623, -.589),
                   (.302, .367, .127), jade, pitch=13, roll=sign * 7)
        art.detail(leg, "Low leather ankle band", (sign * .53, .391, -.299),
                   (.112, .647, .709), leather, shape=CYLINDER, roll=90 + sign * 7)
        art.detail(leg, "Flat saber boot sole", (sign * .53, .069, -.32),
                   (.70, .11, 1.08), deep, shape=BLOCK)
        art.detail(leg, "Soft saber boot toe", (sign * .53, .233, -.464),
                   (.793, .407, .889), fern)
        art.detail(leg, "Saber boot toe pad", (sign * .53, .195, -.866),
                   (.577, .232, .14), ochre)

    tail = art.group("Tail", (.06, 1.643, 1.196), (.592, .588, 1.33), (0, 1.72, .63))
    art.detail(tail, "Tawny muscular tail base", (0, 1.684, .869),
               (.43, .443, .65), tawny, pitch=17)
    art.detail(tail, "Tail sweep toward the outside", (.078, 1.562, 1.192),
               (.359, .382, .66), ochre, pitch=5, yaw=23)
    art.detail(tail, "Rising curve of the short tail", (.174, 1.601, 1.483),
               (.302, .317, .484), tawny, pitch=-21, yaw=19)
    art.detail(tail, "Deep green dipped tail tip", (.195, 1.691, 1.704),
               (.206, .229, .283), deep, pitch=-25, yaw=10)


def build_apex_roster_visuals(library, *, item, part, prop, vector):
    """Build both native shells without external asset dependencies."""
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    _badger(_FighterArt(library, "honey-badger", **helpers))
    _saber(_FighterArt(library, "emerald-saber-tooth", **helpers))
