"""Original native fighter shells for Desert Scorpion and Pistol Shrimp."""

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _scorpion(art):
    charcoal, plum, wine = "302333", "503041", "753634"
    terracotta, copper, orange = "A85137", "C4713C", "E6954F"
    gold, honey, bone = "EAB66C", "FFCE85", "FFEDD0"
    ink, teal = "271D2C", "41685F"

    torso = art.group("Torso", (0, 2.285, .028), (1.77, 2.07, 1.57))
    art.detail(torso, "Mulberry sparring jacket", (0, 2.43, .015), (1.68, 1.72, 1.25), plum, material=FABRIC)
    art.detail(torso, "Rear shell plate", (0, 2.54, .486), (1.75, 1.54, .63), terracotta)
    art.detail(torso, "Quilted clay sparring shorts", (0, 1.595, .016), (1.59, .67, 1.22), charcoal, material=FABRIC)
    art.detail(torso, "Terracotta collar", (0, 3.06, -.21), (1.27, .46, 1.03), copper)
    for i, (width, y, z) in enumerate(((1.47, 2.835, -.499), (1.37, 2.548, -.563), (1.22, 2.285, -.564)), 1):
        art.detail(torso, f"Overlapping amber chest plate {i}", (0, y, z), (width, .361, .334),
                   orange if i == 1 else copper, pitch=-12)
        art.detail(torso, "Gold shell binding", (0, y + .077, z - .111), (width * .82, .075, .106), gold)
    art.detail(torso, "Woven oasis sash", (0, 1.857, -.011), (1.66, .323, 1.29), teal, material=FABRIC)
    art.detail(torso, "Sash piping", (0, 1.931, -.621), (1.29, .068, .11), gold, shape=BLOCK)
    art.detail(torso, "Amber sash medallion", (-.25, 1.862, -.691), (.106, .243, .271), honey,
               shape=CYLINDER, yaw=90)
    art.detail(torso, "Trailing woven sash", (-.36, 1.622, -.648), (.233, .441, .139), teal,
               shape=BLOCK, roll=-25, material=FABRIC)

    head = art.group("Head", (0, 3.84, -.199), (1.67, 1.26, 1.52), (0, 3.10, -.04))
    art.detail(head, "Scorpion carapace", (0, 3.83, -.035), (1.54, 1.22, 1.17), terracotta)
    art.detail(head, "Amber crown panel", (0, 4.145, -.146), (1.39, .57, 1.18), orange, pitch=-14)
    art.detail(head, "Crown ridge", (0, 4.174, -.382), (.337, .63, .39), copper, pitch=-32)
    art.detail(head, "Rounded facial shield", (0, 3.771, -.509), (1.43, .82, .69), wine)
    art.detail(head, "Lower face trim", (0, 3.475, -.673), (.91, .44, .521), gold)
    art.detail(head, "Mouth line", (0, 3.453, -.891), (.446, .051, .081), plum)
    for sign in (-1, 1):
        art.detail(head, "Faceted cheek guard", (sign * .601, 3.646, -.346), (.404, .61, .557), copper,
                   yaw=-sign * 15, roll=sign * 20)
        art.detail(head, "Warm scorpion eye", (sign * .327, 3.914, -.789), (.404, .288, .168), honey,
                   yaw=-sign * 16, roll=sign * 9)
        art.detail(head, "Eye pupil", (sign * .311, 3.906, -.859), (.162, .199, .078), ink)
        art.detail(head, "Eye catchlight", (sign * .311 + .041, 3.952, -.890), (.047, .052, .03), bone)
        art.detail(head, "Focused brow guard", (sign * .343, 4.066, -.798), (.445, .14, .151), gold,
                   yaw=-sign * 15, roll=sign * 17)
        art.detail(head, "Temple sensor dot", (sign * .662, 3.994, -.500), (.139, .101, .093), honey,
                   yaw=-sign * 22)
        art.detail(head, "Rounded jaw pair", (sign * .320, 3.406, -.756), (.353, .245, .385), orange,
                   roll=sign * 15)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = art.group(f"{side} Arm", (sign * 1.057, 2.427, -.306), (.967, 1.423, 1.42),
                        (sign * .81, 2.97, .01))
        art.detail(arm, "Clay shoulder cover", (sign * .958, 2.766, .022), (.752, .722, .745), copper, roll=16 * sign)
        art.detail(arm, "Dark elbow underlayer", (sign * 1.075, 2.388, -.086), (.571, .735, .620), wine, roll=13 * sign)
        art.detail(arm, "Amber forearm armor", (sign * 1.110, 2.237, -.312), (.688, .563, .738), terracotta,
                   pitch=14, roll=9 * sign)
        art.detail(arm, "Oasis grip binding", (sign * 1.135, 2.185, -.432), (.086, .646, .695), teal,
                   shape=CYLINDER, roll=94)
        art.detail(arm, "Padded pincer heel", (sign * 1.141, 2.028, -.493), (.732, .606, .631), copper)
        art.detail(arm, "Broad outer claw finger", (sign * 1.303, 1.984, -.694), (.426, .434, .643), orange,
                   yaw=sign * -19, roll=sign * 13)
        art.detail(arm, "Padded outer claw tip", (sign * 1.211, 1.959, -.862), (.290, .269, .235), honey,
                   yaw=sign * -12)
        art.detail(arm, "Rounded inner claw finger", (sign * .966, 1.968, -.693), (.318, .301, .433), terracotta,
                   yaw=sign * 22)
        art.detail(arm, "Claw plate ridge", (sign * 1.310, 2.166, -.637), (.312, .101, .376), gold,
                   yaw=sign * -18)

        leg = art.group(f"{side} Leg", (sign * .48, .776, -.172), (.797, 1.552, 1.284),
                        (sign * .46, 1.53, .03))
        art.detail(leg, "Dark sparring thigh", (sign * .48, 1.085, .043), (.767, .943, .834), plum,
                   roll=sign * -13, material=FABRIC)
        art.detail(leg, "Terracotta shin carapace", (sign * .494, .605, -.151), (.57, .867, .624), copper,
                   pitch=16, roll=8 * sign)
        art.detail(leg, "Knee shell pad", (sign * .494, .802, -.389), (.504, .455, .302), orange, pitch=-15)
        art.detail(leg, "Oasis ankle binding", (sign * .489, .349, -.190), (.104, .560, .658), teal,
                   shape=CYLINDER, roll=91)
        art.detail(leg, "Flat padded scorpion foot", (sign * .49, .148, -.364), (.728, .296, .881), wine)
        art.detail(leg, "Copper split toe cap", (sign * .49, .139, -.621), (.577, .237, .263), copper)
        art.detail(leg, "Toe seam", (sign * .49, .106, -.747), (.048, .104, .066), plum)

    tail = art.group("Tail", (.184, 2.936, 1.145), (1.10, 2.87, 1.42), (0, 1.80, .52))
    for xyz, pitch in (((.20, 2.29, 1.329), -50), ((.415, 2.716, 1.551), -11),
                       ((.451, 3.198, 1.496), 25), ((.330, 3.644, 1.214), 48)):
        art.detail(tail, "Flexible dark tail joint", xyz, (.331, .376, .345), wine, pitch=pitch)
    for index, (xyz, size, pitch, roll) in enumerate((
        ((0, 1.832, .807), (.71, .61, .651), -49, 0),
        ((.12, 2.07, 1.174), (.626, .717, .665), -52, -12),
        ((.33, 2.478, 1.491), (.551, .742, .594), -32, -16),
        ((.472, 2.955, 1.576), (.494, .703, .533), 4, -10),
        ((.415, 3.445, 1.388), (.443, .687, .501), 28, 12),
        ((.24, 3.858, 1.041), (.393, .630, .420), 52, 17),
    ), 1):
        art.detail(tail, f"Arched tail shell {index}", xyz, size,
                   terracotta if index % 2 else copper, pitch=pitch, roll=roll)
    art.detail(tail, "Soft padded stinger cap", (.035, 4.145, .695), (.415, .334, .462), orange,
               pitch=54, roll=22)
    art.detail(tail, "Honey cap tip", (0, 4.15, .547), (.25, .226, .19), honey, pitch=28)


def _shrimp(art):
    navy, steel, cobalt = "243951", "3B6080", "577C9F"
    ice, seafoam, foam, pale = "8AC4D3", "69A9B9", "B8E7DE", "E3F7EE"
    coral, salmon, crimson = "ED826E", "E3A18A", "A95757"
    brass, ink = "EBC48C", "25293C"

    torso = art.group("Torso", (0, 2.309, -.032), (1.752, 2.02, 1.524))
    art.detail(torso, "Blue training jacket", (0, 2.445, .035), (1.62, 1.68, 1.23), steel, material=FABRIC)
    art.detail(torso, "Pale shoulder yoke", (0, 2.988, .010), (1.731, .641, 1.209), seafoam)
    art.detail(torso, "Layered shrimp abdomen", (0, 1.673, .053), (1.456, .727, 1.20), navy)
    art.detail(torso, "Shell seam down the back", (0, 2.64, .481), (.53, 1.27, .42), seafoam, pitch=11)
    for i, (width, y, z) in enumerate(((1.39, 2.743, -.464), (1.195, 2.46, -.522), (1.045, 2.198, -.53)), 1):
        art.detail(torso, f"Layered glacier-blue shell panel {i}", (0, y, z),
                   (width, .420, .348), ice if i == 2 else foam, pitch=-10)
    art.detail(torso, "Wide navy utility belt", (0, 1.803, -.047), (1.601, .294, 1.235), navy, material=FABRIC)
    art.detail(torso, "Copper diver belt clasp", (.244, 1.817, -.703), (.306, .224, .161), brass, shape=BLOCK, roll=8)
    art.detail(torso, "Ice coat flap", (.347, 1.583, -.585), (.261, .446, .172), ice,
               shape=BLOCK, roll=21, material=FABRIC)
    for sign in (-1, 1):
        art.detail(torso, "Coral coat lapel", (sign * .495, 2.642, -.515), (.165, .906, .153), coral,
                   shape=BLOCK, yaw=-sign * 14, roll=-sign * 20)
    art.detail(torso, "Pearl fight-club badge", (-.361, 2.759, -.679), (.155, .207, .085), pale, roll=-14)

    head = art.group("Head", (0, 4.119, -.219), (1.626, 1.74, 1.467), (0, 3.11, -.04))
    art.detail(head, "Shrimp head shell", (0, 3.855, -.071), (1.355, 1.19, 1.149), ice)
    art.detail(head, "Mint forehead carapace", (0, 4.096, -.208), (1.26, .638, 1.053), foam, pitch=-12)
    art.detail(head, "Snub central shell ridge", (0, 3.937, -.637), (.424, .451, .630), salmon, pitch=21)
    art.detail(head, "Pale rounded muzzle", (0, 3.529, -.551), (.948, .488, .544), pale)
    art.detail(head, "Calm mouth line", (0, 3.556, -.812), (.363, .068, .079), steel)
    for sign in (-1, 1):
        art.detail(head, "Blue lower cheek plate", (sign * .500, 3.630, -.336), (.463, .529, .548), seafoam,
                   roll=sign * 18)
        art.detail(head, "Visible eye stalk", (sign * .430, 4.026, -.485), (.234, .422, .245), seafoam,
                   yaw=-sign * 12, roll=-sign * 22)
        art.detail(head, "Dark outer eye cap", (sign * .494, 4.158, -.579), (.401, .392, .347), navy)
        art.detail(head, "Warm eye disk", (sign * .490, 4.135, -.719), (.311, .265, .135), pale, yaw=-sign * 18)
        art.detail(head, "Iris", (sign * .482, 4.130, -.777), (.166, .199, .084), ink)
        art.detail(head, "Eye catchlight", (sign * .482 + .041, 4.173, -.811), (.049, .054, .025), "FFF7E7")
        art.detail(head, "Coral antenna base", (sign * .268, 4.277, -.255), (.225, .25, .225), coral)
        art.detail(head, "Rigid lower antenna", (sign * .437, 4.476, -.303), (.151, .615, .156), coral,
                   pitch=-12, roll=-sign * 35)
        art.detail(head, "Rounded antenna tip", (sign * .665, 4.797, -.362), (.141, .436, .146), salmon,
                   pitch=-11, roll=-sign * 35)

    right = art.group("Right Arm", (1.152, 2.415, -.383), (1.169, 1.489, 1.60), (.76, 2.91, .01))
    art.detail(right, "Snap-claw shoulder cover", (.939, 2.752, .029), (.715, .80, .751), seafoam, roll=17)
    art.detail(right, "Strong snap-claw forearm", (1.125, 2.43, -.229), (.753, .860, .753), cobalt, roll=12)
    art.detail(right, "Oversized coral claw heel", (1.207, 2.117, -.517), (1.038, .862, 1.037), crimson, pitch=12)
    art.detail(right, "Saturated coral snap shell", (1.195, 2.115, -.576), (.98, .741, .974), coral, pitch=13)
    art.detail(right, "Curved outer snap finger", (1.411, 1.976, -.869), (.531, .453, .620), coral, yaw=-25, roll=15)
    art.detail(right, "Round oversize snap nose", (1.203, 1.941, -1.037), (.329, .287, .230), salmon, yaw=-15)
    art.detail(right, "Short opposing coral finger", (.933, 1.977, -.846), (.385, .366, .505), crimson, yaw=17)
    art.detail(right, "Pearl claw wedge mark", (1.336, 2.274, -.881), (.421, .12, .190), foam, yaw=-22, roll=25)
    art.detail(right, "Claw joint guard", (1.462, 2.259, -.489), (.179, .309, .309), salmon, yaw=-14)
    art.detail(right, "Marine gauntlet trim", (1.082, 2.483, -.317), (.102, .699, .745), ice, shape=CYLINDER, roll=96)

    left = art.group("Left Arm", (-.983, 2.442, -.171), (.807, 1.36, 1.072), (-.76, 2.91, .01))
    art.detail(left, "Ice shoulder cover", (-.933, 2.744, .013), (.679, .737, .682), ice, roll=-18)
    art.detail(left, "Smaller guard forearm", (-.999, 2.390, -.114), (.585, .744, .655), cobalt, roll=-13)
    art.detail(left, "Seafoam elbow pad", (-1.066, 2.294, -.338), (.463, .495, .286), seafoam, pitch=-21)
    art.detail(left, "Pale wrist binding", (-1.018, 2.109, -.197), (.102, .577, .640), foam, shape=CYLINDER, roll=86)
    art.detail(left, "Offhand claw heel", (-1.043, 2.004, -.328), (.664, .461, .57), salmon)
    art.detail(left, "Offhand outer claw", (-1.137, 1.969, -.469), (.393, .360, .459), coral, yaw=18)
    art.detail(left, "Blunt offhand claw tip", (-1.030, 1.963, -.566), (.260, .188, .173), salmon, yaw=14)
    art.detail(left, "Short inner finger", (-.877, 1.954, -.453), (.273, .227, .341), crimson, yaw=-19)

    for sign, side in ((-1, "Left"), (1, "Right")):
        leg = art.group(f"{side} Leg", (sign * .458, .767, -.165), (.753, 1.534, 1.187),
                        (sign * .42, 1.48, .035))
        art.detail(leg, "Marine jacket thigh", (sign * .459, 1.082, .021), (.716, .915, .793), steel,
                   roll=-sign * 14, material=FABRIC)
        art.detail(leg, "Padded ice-blue shin", (sign * .468, .632, -.153), (.489, .852, .562), ice,
                   pitch=15, roll=sign * 12)
        art.detail(leg, "Seafoam greave ridge", (sign * .462, .667, -.353), (.373, .564, .287), seafoam, pitch=-14)
        art.detail(leg, "Shrimp ankle band", (sign * .468, .363, -.184), (.10, .515, .620), coral,
                   shape=CYLINDER, roll=90)
        art.detail(leg, "Flat-surface boxing boot", (sign * .450, .148, -.319), (.715, .296, .858), navy)
        art.detail(leg, "Icy two-toe cap", (sign * .450, .145, -.530), (.544, .215, .291), foam)
        art.detail(leg, "Toe seam", (sign * .450, .136, -.669), (.046, .105, .065), cobalt)

    tail = art.group("Tail", (0, 1.362, 1.17), (1.756, .875, 1.61), (0, 1.62, .48))
    art.detail(tail, "Curved tail root", (0, 1.467, .719), (.772, .615, .71), cobalt, pitch=32)
    art.detail(tail, "Layered blue tail link", (0, 1.29, 1.07), (.819, .530, .701), seafoam, pitch=26)
    art.detail(tail, "Central tail fan paddle", (0, 1.150, 1.481), (.433, .367, .992), ice, pitch=14)
    for sign in (-1, 1):
        art.detail(tail, "Shell fan outer petal", (sign * .419, 1.182, 1.443), (.692, .377, .932), seafoam,
                   pitch=16, yaw=sign * 30)
        art.detail(tail, "Coral fan edge", (sign * .660, 1.110, 1.670), (.425, .24, .397), coral,
                   pitch=17, yaw=sign * 33)


def build_ember_aqua_visuals(library, *, item, part, prop, vector):
    """Emit two fighter shells using the native-part builder."""
    adapters = dict(item=item, part=part, prop=prop, vector=vector)
    _scorpion(_FighterArt(library, "desert-scorpion", **adapters))
    _shrimp(_FighterArt(library, "pistol-shrimp", **adapters))
