"""Original evolution outfits for Honey Badger, Emerald Saber-Tooth and Great White Shark."""

from reedguard_forms_art import _copy_art_tree
from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _badger(art, groups, grandmaster):
    if grandmaster:
        backing, cloth, trim, inset = "442F50", "67425C", "F3C875", "F5E1AE"
    else:
        backing, cloth, trim, inset = "483336", "874737", "D69A4F", "EDBC75"

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Crossed honeycomb vest facing", (sign * .443, 2.613, -.667),
                   (.374, .983, .237), backing, roll=sign * -29, yaw=sign * -17, material=FABRIC)
        art.detail(torso, "Folded honeycomb vest satin", (sign * .442, 2.632, -.785),
                   (.255, .817, .090), cloth, roll=sign * -29, yaw=sign * -17, material=FABRIC)
        art.detail(torso, "Woven gold seam on the vest", (sign * .511, 2.647, -.845),
                   (.061, .669, .035), trim, roll=sign * -29, yaw=sign * -17, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Honeycomb jacket pin", (sign * .510, 2.881, -.781),
                       (.109, .144, .144), inset, yaw=90, shape=CYLINDER)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Padded honeycomb shoulder cuff", (sign * 1.103, 2.866, -.319),
                   (.504, .405, .336), backing, roll=sign * 19, material=FABRIC)
        art.detail(arm, "Colored cushion on shoulder cuff", (sign * 1.129, 2.873, -.479),
                   (.343, .273, .110), cloth, roll=sign * 19)
        art.detail(arm, "Warm piping across cuff", (sign * 1.153, 2.911, -.548),
                   (.232, .074, .049), trim, roll=sign * 19)
    art.detail(torso, "Double-faced honeycomb sash plaque", (.281, 1.732, -.793),
               (.361, .229, .115), trim)
    art.detail(torso, "Dark enamel in the sash plaque", (.281, 1.737, -.854),
               (.235, .136, .043), backing, shape=BLOCK)
    art.detail(torso, "Bright lozenge in the honeycomb plaque", (.281, 1.738, -.885),
               (.088, .088, .027), inset, roll=45, shape=BLOCK)

    head = groups["Head"]
    art.detail(head, "Crown binding above the silver forehead", (0, 4.163, -.716),
               (.585, .149, .167), backing, pitch=17, material=FABRIC)
    art.detail(head, "Small honey-colored crown badge", (0, 4.170, -.803),
               (.171, .145, .068), trim, roll=45, shape=BLOCK)
    if grandmaster:
        art.detail(head, "Center glint on the crown badge", (0, 4.171, -.844),
                   (.090, .071, .026), inset)


def _saber(art, groups, grandmaster):
    if grandmaster:
        backing, cloth, seam, stone = "2F605E", "B0CBBB", "E1BC77", "EBF2D9"
    else:
        backing, cloth, seam, stone = "433948", "8A5963", "DCA86D", "B6D289"

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Saber guard's folded lapel", (sign * .497, 2.683, -.729),
                   (.346, .950, .241), backing, roll=sign * -26, yaw=sign * -19, material=FABRIC)
        art.detail(torso, "Dyed watchkeeper lapel facing", (sign * .494, 2.686, -.847),
                   (.233, .780, .106), cloth, roll=sign * -26, yaw=sign * -19, material=FABRIC)
        art.detail(torso, "Thin border of the guard lapel", (sign * .556, 2.716, -.907),
                   (.052, .635, .040), seam, roll=sign * -26, yaw=sign * -19, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Folded silk at the side of the sash", (sign * .463, 1.606, -.722),
                       (.254, .379, .100), cloth, roll=sign * 16, material=FABRIC)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Inset sash pad over saber shoulder", (sign * 1.317, 2.989, -.441),
                   (.588, .374, .305), backing, roll=sign * 23, material=FABRIC)
        art.detail(arm, "Long leaf appliqué on the shoulder", (sign * 1.333, 3.010, -.580),
                   (.405, .213, .117), cloth, roll=sign * 23)
        art.detail(arm, "Metal vein of the saber appliqué", (sign * 1.365, 3.035, -.642),
                   (.240, .062, .034), seam, roll=sign * 26)
    art.detail(torso, "Watchkeeper sash badge frame", (.315, 1.831, -.808),
               (.306, .204, .123), seam)
    art.detail(torso, "Sash badge's carved inlay", (.315, 1.835, -.881),
               (.175, .115, .036), stone)

    head = groups["Head"]
    art.detail(head, "High leaf clasp behind the saber brow", (0, 4.303, -.716),
               (.376, .174, .158), backing, pitch=-12, material=FABRIC)
    art.detail(head, "Leaf clasp edge", (0, 4.316, -.799),
               (.155, .155, .050), seam, roll=45, shape=BLOCK)
    art.detail(head, "High watchkeeper leaf stone", (0, 4.318, -.831),
               (.086, .089, .028), stone, roll=45, shape=BLOCK)


def _shark(art, groups, grandmaster):
    if grandmaster:
        backing, cloth, piping, inset = "293F67", "517BA8", "C2DDE0", "F0E2B3"
    else:
        backing, cloth, piping, inset = "583D4A", "9A6159", "D9A776", "F1DAB8"

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Deck coat facing with a rolled seam", (sign * .479, 2.617, -.679),
                   (.385, .965, .256), backing, roll=sign * -22, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Dyed deck coat collar", (sign * .485, 2.636, -.804),
                   (.255, .811, .108), cloth, roll=sign * -22, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Fine double-stitched tide edging", (sign * .558, 2.669, -.866),
                   (.064, .652, .036), piping, roll=sign * -22, yaw=sign * -15, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Sea-glass coat stud", (sign * .446, 2.327, -.839),
                       (.112, .126, .063), inset)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Tight shoulder cord above the pectoral fin", (sign * 1.104, 2.926, -.353),
                   (.496, .320, .309), backing, roll=sign * 24, material=FABRIC)
        art.detail(arm, "Contrasting short tide cord", (sign * 1.120, 2.946, -.504),
                   (.346, .212, .122), cloth, roll=sign * 24)
        art.detail(arm, "Bright piping on the tide cord", (sign * 1.152, 2.981, -.568),
                   (.209, .070, .036), piping, roll=sign * 24)
    art.detail(torso, "Stamped tide crest belt mount", (.299, 1.792, -.754),
               (.310, .208, .112), piping)
    art.detail(torso, "Small tide crest belt accent", (.300, 1.795, -.815),
               (.171, .105, .034), inset)

    head = groups["Head"]
    art.detail(head, "Tide officer's folded temple band", (0, 4.292, -.641),
               (.509, .158, .183), backing, pitch=-13, material=FABRIC)
    art.detail(head, "Rising wave crest on the band", (0, 4.301, -.734),
               (.189, .139, .067), piping, roll=35, shape=BLOCK)
    art.detail(head, "Pearl point at the wave crest", (0, 4.308, -.774),
               (.085, .078, .031), inset)


def build_apex_evolutions(form_visuals, fighter_visuals, *, item, part, prop, vector):
    """Create the two earned outfits for each fighter in the supplied library."""
    appearances = (("honey-badger", _badger), ("emerald-saber-tooth", _saber), ("great-white-shark", _shark))
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
