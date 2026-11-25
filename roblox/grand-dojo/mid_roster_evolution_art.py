"""Original evolution apparel for Sugar Glider, Desert Scorpion, and Pistol Shrimp."""

from reedguard_forms_art import _copy_art_tree
from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _glider(art, groups, grandmaster):
    if grandmaster:
        lining, cloth, bronze, light = "283F5A", "6293A4", "D3AC67", "EEE2C0"
    else:
        lining, cloth, bronze, light = "512638", "924A50", "A16848", "E2A578"

    head = groups["Head"]
    art.detail(head, "Cloudflier's forehead wrap", (0, 4.353, -.533), (.480, .151, .210), cloth,
               pitch=-10, material=FABRIC)
    art.detail(head, "Rounded navigator badge", (0, 4.397, -.727), (.176, .149, .058), bronze)
    art.detail(head, "Pin of the navigator badge", (0, 4.399, -.761), (.095, .091, .024), light,
               roll=45, shape=BLOCK)

    torso = groups["Torso"]
    for sign in (-1, 1):
        art.detail(torso, "Layered navigator coat lapel", (sign * .466, 2.644, -.548), (.349, .944, .206), lining,
                   roll=sign * -20, yaw=sign * -11, material=FABRIC)
        art.detail(torso, "Raised facing on navigator coat", (sign * .482, 2.659, -.660), (.241, .779, .100), cloth,
                   roll=sign * -20, yaw=sign * -11, material=FABRIC)
        art.detail(torso, "Slender flight-coat topstitch", (sign * .490, 2.707, -.708), (.048, .607, .035), light,
                   roll=sign * -20, yaw=sign * -11, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Ivory loop by the navigator collar", (sign * .378, 2.879, -.724), (.152, .173, .056), light,
                       roll=sign * -21)
    art.detail(torso, "Pilot's crossed waist cord", (.134, 1.893, -.608), (.796, .181, .167), lining,
               material=FABRIC, roll=-6)
    art.detail(torso, "Cast brass pilot buckle", (.136, 1.910, -.700), (.283, .193, .112), bronze, roll=-8)
    art.detail(torso, "Ivory point of pilot buckle", (.136, 1.909, -.754), (.142, .095, .032), light, roll=-8)
    if grandmaster:
        art.detail(torso, "Double-folded ivory flight tab", (.386, 1.606, -.573), (.288, .459, .129), light,
                   roll=19, material=FABRIC)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Wingroot coat binding", (sign * .959, 2.758, -.194), (.558, .397, .297), lining,
                   roll=sign * 18, material=FABRIC)
        art.detail(arm, "Oval navigator shoulder patch", (sign * .987, 2.777, -.334), (.409, .258, .143), cloth,
                   roll=sign * 18)
        art.detail(arm, "Gilt fold on navigator shoulder patch", (sign * .989, 2.784, -.410), (.226, .073, .043),
                   bronze if not grandmaster else light, roll=sign * -15)


def _scorpion(art, groups, grandmaster):
    if grandmaster:
        fabric, plate, metal, inlay = "264F4A", "4C8270", "D1A567", "B9C69E"
    else:
        fabric, plate, metal, inlay = "593341", "855168", "BA8054", "DEA877"

    head = groups["Head"]
    art.detail(head, "Oasis guard forehead setting", (0, 4.239, -.667), (.390, .190, .145), fabric,
               pitch=-15)
    art.detail(head, "Geometric sand-polished brow medallion", (0, 4.253, -.747), (.191, .159, .065), metal,
               roll=45, shape=BLOCK)
    if grandmaster:
        art.detail(head, "Green center of the oasis crest", (0, 4.254, -.787), (.092, .084, .031), inlay,
                   roll=45, shape=BLOCK)

    torso = groups["Torso"]
    art.detail(torso, "Woven stoneworker's diagonal harness", (-.157, 2.582, -.704), (.255, 1.011, .162), fabric,
               roll=32, material=FABRIC)
    art.detail(torso, "Carved harness plate", (-.167, 2.618, -.783), (.208, .615, .098), plate,
               roll=32)
    art.detail(torso, "Brass closure on stoneworker's harness", (-.065, 2.377, -.828), (.215, .154, .061), metal,
               roll=-10)
    art.detail(torso, "Pressed brass panel on oasis belt", (.231, 1.873, -.648), (.357, .208, .142), metal)
    art.detail(torso, "Small three-sided oasis inset", (.231, 1.876, -.724), (.157, .128, .049), plate,
               roll=45, shape=BLOCK)
    if grandmaster:
        art.detail(torso, "Raised gold leaf on oasis plate", (-.218, 2.673, -.833), (.087, .266, .035), inlay,
                   roll=28)
        art.detail(torso, "Green fold hanging from oasis belt", (.314, 1.591, -.615), (.268, .378, .131), plate,
                   roll=20, material=FABRIC)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Oasis guard shoulder backing", (sign * .996, 2.746, -.246), (.613, .434, .352), fabric,
                   roll=sign * 18, material=FABRIC)
        art.detail(arm, "Carved oasis shoulder scale", (sign * 1.014, 2.765, -.415), (.469, .303, .125), plate,
                   roll=sign * 19)
        art.detail(arm, "Metal shoulder-scale rim", (sign * 1.050, 2.803, -.473), (.246, .096, .046), metal,
                   roll=sign * 19)
        if grandmaster:
            art.detail(arm, "Pale jade shoulder setting", (sign * 1.024, 2.712, -.485), (.166, .109, .042), inlay,
                       roll=sign * -12)
        leg = groups[f"{side} Leg"]
        art.detail(leg, "Color stripe across the scorpion's upper greave", (sign * .484, .906, -.501),
                   (.286, .185, .100), plate, roll=sign * 8)


def _shrimp(art, groups, grandmaster):
    if grandmaster:
        cloth, belt, glass, accent = "384760", "314E66", "D2DFD5", "CE9B84"
    else:
        cloth, belt, glass, accent = "7E3C49", "512E40", "B37573", "D4AA73"

    head = groups["Head"]
    art.detail(head, "Diver's low headband", (0, 4.343, -.509), (.585, .146, .181), cloth,
               pitch=10, material=FABRIC)
    art.detail(head, "Rounded enamel diver pin", (0, 4.356, -.605), (.176, .151, .074), glass)
    art.detail(head, "Diver pin inset", (0, 4.360, -.648), (.098, .087, .030), accent, roll=45, shape=BLOCK)

    torso = groups["Torso"]
    for sign in (-1, 1):
        art.detail(torso, "Padded deepwater jacket edge", (sign * .517, 2.598, -.582), (.313, .935, .189), belt,
                   roll=sign * -20, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Curved facing on deepwater jacket", (sign * .524, 2.620, -.674), (.199, .736, .094), cloth,
                   roll=sign * -20, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Thread lift on deepwater jacket", (sign * .551, 2.643, -.716), (.047, .545, .039), accent,
                   roll=sign * -20, yaw=sign * -14, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Pearl collar edge", (sign * .426, 2.907, -.687), (.119, .286, .062), glass,
                       roll=sign * -25)
    art.detail(torso, "Pearl-cut diver's chest emblem", (0, 2.741, -.644), (.273, .279, .116), glass)
    art.detail(torso, "Embossed water mark on pearl", (-.006, 2.742, -.709), (.107, .164, .036), belt, roll=-23)
    art.detail(torso, "Nautical belt clasp", (-.243, 1.821, -.699), (.309, .192, .123), accent)
    art.detail(torso, "Salt-colored inset on belt clasp", (-.243, 1.821, -.763), (.164, .110, .046), glass, roll=-8)
    if grandmaster:
        art.detail(torso, "Soft ivory diver jacket tab", (-.374, 1.582, -.608), (.290, .438, .124), glass,
                   roll=-16, material=FABRIC)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Rounded deepwater shoulder scale", (sign * .980, 2.743, -.279), (.499, .372, .282), cloth,
                   roll=sign * 16)
        art.detail(arm, "Color across deepwater shoulder scale", (sign * 1.014, 2.754, -.411), (.364, .230, .130), glass,
                   roll=sign * 17)
        art.detail(arm, "Metal seam on pearl shoulder facing", (sign * 1.020, 2.803, -.472), (.183, .065, .047), accent,
                   roll=sign * 17)
        if grandmaster:
            art.detail(arm, "Coral lap of upper arm braid", (sign * 1.024, 2.542, -.162), (.067, .560, .650), accent,
                       shape=CYLINDER, roll=90 + sign * 12)


def build_mid_roster_evolutions(form_visuals, fighter_visuals, *, item, part, prop, vector):
    """Add two cosmetic forms per fighter to the supplied form library."""
    appearances = (("sugar-glider", _glider), ("desert-scorpion", _scorpion), ("pistol-shrimp", _shrimp))
    stages = (("warrior", False), ("grandmaster", True))
    models = {model.findtext("Properties/*[@name='Name']"): model for model in fighter_visuals.findall("Item")}
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    for fighter_id, decorate in appearances:
        for stage, grandmaster in stages:
            art = _FighterArt(form_visuals, f"{fighter_id}-{stage}", **helpers)
            groups = {node.findtext("Properties/*[@name='Name']"): _copy_art_tree(node, art.model, item)
                      for node in models[fighter_id].findall("Item")}
            decorate(art, groups, grandmaster)
    return form_visuals
