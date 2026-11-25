"""Original evolution ornaments for Komodo, Electric Owl, and Bighorn Ram."""

from reedguard_forms_art import _copy_art_tree
from roster_fighter_art import BLOCK, FABRIC, _FighterArt


def _komodo(art, groups, grandmaster):
    if grandmaster:
        dark, panel, trim, jewel = "30434B", "617B78", "E3C795", "ECDCC0"
    else:
        dark, panel, trim, jewel = "51313C", "925353", "B78256", "DDB58E"

    head = groups["Head"]
    art.detail(head, "Obsidian-colored kiln headband", (0, 4.211, -.462), (.475, .123, .175), dark,
               pitch=14, material=FABRIC)
    art.detail(head, "Small inlaid stone at forehead", (0, 4.212, -.562), (.152, .118, .067), trim,
               roll=45, shape=BLOCK)
    art.detail(head, "Pale glint on kiln brow stone", (0, 4.214, -.603), (.078, .072, .022), jewel)

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Glazed kiln coat lapel backing", (sign * .475, 2.639, -.593), (.337, .907, .207), dark,
                   roll=sign * -23, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Kiln coat's stitched lapel facing", (sign * .491, 2.665, -.692), (.212, .734, .098), panel,
                   roll=sign * -23, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Polished edge thread on kiln collar", (sign * .534, 2.701, -.747), (.062, .576, .048), trim,
                   roll=sign * -23, yaw=sign * -15, shape=BLOCK)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Obsidian shoulder-wrap backing", (sign * 1.076, 2.804, -.303), (.569, .354, .300), dark,
                   roll=sign * 19, material=FABRIC)
        art.detail(arm, "Curved stone face on shoulder wrap", (sign * 1.113, 2.822, -.439), (.405, .229, .154), panel,
                   roll=sign * 20)
        if grandmaster:
            art.detail(arm, "Pale kiln glaze streak on shoulder", (sign * 1.136, 2.845, -.516), (.237, .068, .033), jewel,
                       roll=sign * 16)
    art.detail(torso, "Brass fastening off the center of kiln sash", (.241, 1.755, -.763), (.347, .223, .128), trim)
    art.detail(torso, "Inlaid glazed sash clasp", (.241, 1.759, -.836), (.174, .113, .043), panel)
    if grandmaster:
        art.detail(torso, "Pressed porcelain tab below kiln sash", (.473, 1.515, -.647), (.261, .365, .116), jewel,
                   roll=16, material=FABRIC)


def _owl(art, groups, grandmaster):
    if grandmaster:
        shadow, cloth, metal, pale = "263955", "5276A0", "A4BBC2", "E7EEE4"
    else:
        shadow, cloth, metal, pale = "473048", "81545A", "AB7553", "DFB180"

    head = groups["Head"]
    art.detail(head, "Narrow flight-crest binding", (0, 4.402, -.625), (.401, .159, .150), shadow,
               pitch=-8, material=FABRIC)
    art.detail(head, "Polished flight crest setting", (0, 4.405, -.701), (.241, .167, .060), metal,
               roll=45, shape=BLOCK)
    art.detail(head, "Central stone on flight crest", (0, 4.408, -.742), (.112, .094, .038), pale)

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Padded facing of the storm-flight jacket", (sign * .515, 2.664, -.598), (.393, .833, .240), shadow,
                   roll=sign * -22, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Contrasting silk on storm-flight jacket", (sign * .512, 2.680, -.711), (.284, .660, .106), cloth,
                   roll=sign * -22, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Narrow lightning embroidery on jacket", (sign * .546, 2.715, -.769), (.061, .506, .043), pale,
                   roll=sign * -23, yaw=sign * -14, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Beaded lower flight coat tab", (sign * .457, 1.614, -.716), (.271, .424, .096), cloth,
                       roll=sign * 12, material=FABRIC)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Folded flight shoulder label", (sign * 1.121, 2.773, -.280), (.544, .350, .302), shadow,
                   roll=sign * 16, material=FABRIC)
        art.detail(arm, "Storm-colored shoulder scale", (sign * 1.150, 2.789, -.414), (.415, .258, .162), cloth,
                   roll=sign * 16)
        art.detail(arm, "Light narrow seam of shoulder scale", (sign * 1.175, 2.817, -.493), (.240, .087, .044),
                   pale if grandmaster else metal, roll=sign * 17)
    art.detail(torso, "Rhombus clasp over flight sash", (.212, 1.841, -.755), (.237, .184, .083), metal)
    art.detail(torso, "Tinted inset in flight sash clasp", (.212, 1.843, -.800), (.106, .092, .031), cloth,
               roll=45, shape=BLOCK)


def _ram(art, groups, grandmaster):
    if grandmaster:
        dark, armor, metal, light = "344B59", "698788", "D0A371", "E4DFC8"
    else:
        dark, armor, metal, light = "3D384F", "595977", "B28766", "D7BB8D"

    head = groups["Head"]
    art.detail(head, "Forge-colored band between the horns", (0, 4.210, -.540), (.597, .174, .205), dark,
               pitch=8, material=FABRIC)
    art.detail(head, "Horn-safe summit crest plate", (0, 4.214, -.652), (.241, .155, .066), armor)
    art.detail(head, "Setting at the summit crest", (0, 4.216, -.692), (.111, .091, .031), metal,
               roll=45, shape=BLOCK)

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Crossed leather arms of chest harness", (sign * .551, 2.657, -.729), (.327, .901, .230), dark,
                   roll=sign * -20, yaw=sign * -16, material=FABRIC)
        art.detail(torso, "Dyed armor stripe on chest harness", (sign * .559, 2.691, -.842), (.218, .710, .103), armor,
                   roll=sign * -20, yaw=sign * -16, material=FABRIC)
        art.detail(torso, "Thin bronze border stitching", (sign * .590, 2.715, -.897), (.051, .589, .050), metal,
                   roll=sign * -20, yaw=sign * -16, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Ivory knot on upper harness", (sign * .595, 2.906, -.906), (.137, .157, .058), light,
                       roll=sign * -18)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Dyed leather cap on copper shoulder", (sign * 1.260, 2.853, -.398), (.552, .349, .252), dark,
                   roll=sign * 20, material=FABRIC)
        art.detail(arm, "Rounded shoulder armor inset", (sign * 1.262, 2.865, -.521), (.412, .228, .131), armor,
                   roll=sign * 20)
        art.detail(arm, "Short raised shoulder border", (sign * 1.272, 2.909, -.581), (.241, .069, .043),
                   light if grandmaster else metal, roll=sign * 20)
    art.detail(torso, "Small off-center mountain belt plate", (.364, 1.744, -.810), (.288, .189, .112), metal)
    art.detail(torso, "Enamel set into mountain belt plate", (.365, 1.748, -.872), (.158, .103, .037), armor)
    if grandmaster:
        art.detail(torso, "Ivory-edged summit sash tab", (-.361, 1.593, -.749), (.249, .384, .115), light,
                   roll=-16, material=FABRIC)


def build_ridge_evolutions(form_visuals, fighter_visuals, *, item, part, prop, vector):
    """Create the Warrior and Grandmaster outfits in the supplied library."""
    appearances = (("komodo-dragon", _komodo), ("electric-owl", _owl), ("bighorn-ram", _ram))
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
