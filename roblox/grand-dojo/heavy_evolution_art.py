"""Original heavyweight evolution apparel for Walrus, Tortoise, and Armadillo."""

from reedguard_forms_art import _copy_art_tree
from roster_fighter_art import BLOCK, FABRIC, _FighterArt


def _walrus(art, groups, grandmaster):
    if grandmaster:
        cloth, silk, metal, pale = "2E5367", "729BAF", "D2AA65", "DEE7DA"
    else:
        cloth, silk, metal, pale = "513247", "825262", "AF764B", "DAA779"

    head = groups["Head"]
    art.detail(head, "Knotted harbor forehead band", (0, 4.391, -.641), (.772, .176, .228), cloth,
               pitch=12, material=FABRIC)
    art.detail(head, "Sumo forehead band clasp", (0, 4.403, -.762), (.213, .164, .067), metal)
    art.detail(head, "Pale carved clasp inset", (0, 4.403, -.801), (.110, .095, .034), pale, roll=45, shape=BLOCK)
    if grandmaster:
        for sign in (-1, 1):
            art.detail(head, "Small side knot on harbor brow band", (sign * .237, 4.387, -.756),
                       (.122, .081, .034), silk, roll=sign * 14)

    torso = groups["Torso"]
    art.detail(torso, "Ceremonial sumo waist sash", (0, 1.825, -.744), (1.718, .174, .230), cloth,
               material=FABRIC)
    art.detail(torso, "Pale stitching along sumo sash", (-.369, 1.872, -.866), (.801, .066, .062), pale)
    art.detail(torso, "Carved metal sumo clasp", (-.343, 1.776, -.902), (.324, .235, .119), metal)
    art.detail(torso, "Cloth inset within sumo clasp", (-.343, 1.783, -.969), (.164, .120, .034), silk)
    for sign in (-1, 1):
        art.detail(torso, "Short folded harbor belt tab", (sign * .588, 1.557, -.736), (.326, .456, .142), silk,
                   roll=sign * 18, material=FABRIC)
        if grandmaster:
            art.detail(torso, "Pearl facing on tied belt tab", (sign * .608, 1.575, -.804), (.237, .326, .074), pale,
                       roll=sign * 18, material=FABRIC)
        arm = groups[f"{'Left' if sign < 0 else 'Right'} Arm"]
        art.detail(arm, "Padded upper harbor shoulder sleeve", (sign * 1.240, 2.703, -.281), (.637, .453, .388), cloth,
                   roll=sign * 19, material=FABRIC)
        art.detail(arm, "Narrow raised sleeve facing", (sign * 1.263, 2.708, -.460), (.461, .305, .145), silk,
                   roll=sign * 19)
        art.detail(arm, "Rounded cuff bead of harbor shoulder sleeve", (sign * 1.292, 2.745, -.527),
                   (.220, .105, .062), metal, roll=sign * 18)


def _tortoise(art, groups, grandmaster):
    if grandmaster:
        cloth, glaze, metal, light = "34574C", "728768", "BA975E", "E6D9B0"
    else:
        cloth, glaze, metal, light = "2E354A", "4C586F", "A77455", "DDA771"

    head = groups["Head"]
    art.detail(head, "Stonegate brow ribbon", (0, 4.286, -.490), (.548, .161, .168), cloth,
               pitch=13, material=FABRIC)
    art.detail(head, "Mason's rounded bronze brow clasp", (0, 4.295, -.563), (.185, .126, .060), metal)
    art.detail(head, "Small glass on mason's clasp", (0, 4.304, -.595), (.083, .072, .027), light)

    torso = groups["Torso"]
    for sign in (-1, 1):
        art.detail(torso, "Cross-laced shell harness side", (sign * .529, 2.664, -.746), (.268, .973, .177), cloth,
                   roll=sign * -21, yaw=sign * -12, material=FABRIC)
        art.detail(torso, "Ribbed facing on shell harness", (sign * .551, 2.695, -.838), (.179, .750, .093), glaze,
                   roll=sign * -21, yaw=sign * -12, material=FABRIC)
        art.detail(torso, "Gilt seam on shell harness", (sign * .585, 2.714, -.883), (.045, .592, .036), light,
                   roll=sign * -21, yaw=sign * -12, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Pale thread setting on shell harness", (sign * .582, 2.911, -.896),
                       (.119, .182, .044), light, roll=sign * -22)
        arm = groups[f"{'Left' if sign < 0 else 'Right'} Arm"]
        art.detail(arm, "Layered stonegate shoulder guard", (sign * 1.184, 2.724, -.176), (.591, .408, .386),
                   glaze, roll=sign * 17)
        art.detail(arm, "Narrow edge on shoulder guard", (sign * 1.231, 2.783, -.363), (.363, .094, .100),
                   metal, roll=sign * 17)
        if grandmaster:
            art.detail(arm, "Soft stone tile on shoulder guard", (sign * 1.197, 2.686, -.363),
                       (.222, .131, .063), light, roll=sign * -14)
    art.detail(torso, "Small stonegate belt setting", (-.270, 1.727, -.884), (.268, .170, .101), metal)
    art.detail(torso, "Colored stone in belt setting", (-.270, 1.728, -.936), (.141, .102, .034), glaze)


def _armadillo(art, groups, grandmaster):
    if grandmaster:
        cloth, panel, metal, jewel = "33495E", "739097", "C39769", "EADDC1"
    else:
        cloth, panel, metal, jewel = "4F4650", "8F5850", "B37F54", "DEAA77"

    head = groups["Head"]
    art.detail(head, "Kiln guard crown inset", (0, 4.137, -.858), (.285, .222, .073), cloth)
    art.detail(head, "Glazed center of crown inset", (0, 4.142, -.902), (.153, .136, .039), metal,
               roll=45, shape=BLOCK)
    if grandmaster:
        art.detail(head, "Porcelain point on crown inset", (0, 4.146, -.926), (.072, .064, .027), jewel,
                   roll=45, shape=BLOCK)

    torso = groups["Torso"]
    for sign in (-1, 1):
        art.detail(torso, "Hammered front collar facing", (sign * .304, 2.688, -.899), (.281, .664, .122), cloth,
                   roll=sign * -20, yaw=sign * -13, material=FABRIC)
        art.detail(torso, "Glazed edge on hammered collar", (sign * .335, 2.715, -.956), (.148, .480, .069), panel,
                   roll=sign * -20, yaw=sign * -13)
        if grandmaster:
            art.detail(torso, "Fine porcelain edge on front collar", (sign * .371, 2.732, -.992),
                       (.054, .371, .036), jewel, roll=sign * -20, yaw=sign * -13)
        arm = groups[f"{'Left' if sign < 0 else 'Right'} Arm"]
        art.detail(arm, "Shaped foundry shoulder plate", (sign * 1.222, 2.834, -.417), (.540, .285, .185), panel,
                   roll=sign * 21)
        art.detail(arm, "Rim of foundry shoulder plate", (sign * 1.274, 2.860, -.511), (.266, .094, .058), metal,
                   roll=sign * 21)
        if grandmaster:
            art.detail(arm, "Glazed cap on foundry shoulder plate", (sign * 1.216, 2.782, -.508),
                       (.143, .134, .052), jewel)
    art.detail(torso, "Low forge belt-brace setting", (-.236, 1.742, -.851), (.277, .161, .095), metal)
    art.detail(torso, "Color in low belt-brace setting", (-.236, 1.748, -.904), (.133, .095, .038), panel)


def build_heavy_evolutions(form_visuals, fighter_visuals, *, item, part, prop, vector):
    """Copy existing shells and add their original Warrior and Grandmaster apparel."""
    appearances = (("walrus-sumo", _walrus), ("snapping-tortoise", _tortoise), ("armadillo-striker", _armadillo))
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
