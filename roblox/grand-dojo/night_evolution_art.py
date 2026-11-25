"""Original evolution outfits for Abyssal Kraken, Magma Grizzly Bear and Obsidian Hellhound."""

from reedguard_forms_art import _copy_art_tree
from roster_fighter_art import BLOCK, FABRIC, _FighterArt


def _kraken(art, groups, grandmaster):
    if grandmaster:
        dark, panel, edge, pearl = "263B5E", "5A6DA8", "99C8C8", "E8EAD2"
    else:
        dark, panel, edge, pearl = "543850", "974F67", "DE967B", "F3D3AA"

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Reef guardian's quilted wrap", (sign * .541, 2.634, -.703),
                   (.419, .950, .251), dark, roll=sign * -28, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Curved shell facing at the chest", (sign * .542, 2.655, -.838),
                   (.294, .732, .118), panel, roll=sign * -28, yaw=sign * -14)
        art.detail(torso, "Bright inner edge on the shell facing", (sign * .557, 2.678, -.901),
                   (.055, .562, .039), edge, roll=sign * -27, yaw=sign * -14, shape=BLOCK)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Folded shell guard over the upper tentacle", (sign * 1.167, 2.930, -.334),
                   (.548, .339, .345), dark, roll=sign * 23, material=FABRIC)
        art.detail(arm, "Soft reef-shell shoulder plate", (sign * 1.188, 2.952, -.489),
                   (.471, .237, .159), panel, roll=sign * 22)
        art.detail(arm, "Pearled edge wrapped around the shell", (sign * 1.213, 2.975, -.568),
                   (.265, .092, .046), edge, roll=sign * 22)
        if grandmaster:
            art.detail(arm, "Small pearl rivet on the shoulder edge", (sign * 1.166, 2.964, -.596),
                       (.105, .084, .021), pearl)
    art.detail(torso, "Gold mount on the reef sash", (.303, 1.810, -.804), (.335, .206, .102), edge)
    art.detail(torso, "Pearl shell clasp on the reef sash", (.303, 1.815, -.866), (.178, .124, .050), pearl)
    art.detail(torso, "Diagonal shell engraving", (.303, 1.816, -.894), (.050, .101, .023), panel,
               roll=-21, shape=BLOCK)

    head = groups["Head"]
    art.detail(head, "Small reef circlet below the mantle markings", (0, 4.338, -.742),
               (.666, .170, .168), dark, pitch=-11, material=FABRIC)
    art.detail(head, "Upturned reef crest setting", (0, 4.344, -.831),
               (.241, .153, .070), edge, roll=-15)
    art.detail(head, "White shell on the reef crest", (0, 4.347, -.875),
               (.116, .096, .035), pearl, roll=-15)


def _grizzly(art, groups, grandmaster):
    if grandmaster:
        base, plate, rim, satin = "34303B", "585665", "DDA95A", "F4D9A1"
    else:
        base, plate, rim, satin = "502B33", "994236", "CB8450", "EABE87"

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Main facing on the kiln apron", (sign * .717, 2.676, -.667),
                   (.514, 1.173, .313), base, roll=sign * -23, yaw=sign * -13, material=FABRIC)
        art.detail(torso, "Reinforced felt on the apron", (sign * .710, 2.681, -.844),
                   (.361, .917, .149), plate, roll=sign * -23, yaw=sign * -13, material=FABRIC)
        art.detail(torso, "Sealed copper edge on the apron", (sign * .780, 2.715, -.924),
                   (.065, .727, .047), rim, roll=sign * -23, yaw=sign * -13, shape=BLOCK)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "High padded forge shoulder plate", (sign * 1.477, 3.041, -.435),
                   (.665, .389, .315), base, roll=sign * 20, material=FABRIC)
        art.detail(arm, "Rounded kiln shoulder cover", (sign * 1.510, 3.063, -.574),
                   (.513, .256, .146), plate, roll=sign * 20)
        art.detail(arm, "Burnished top edge of the shoulder cover", (sign * 1.540, 3.085, -.647),
                   (.331, .083, .046), rim, roll=sign * 20)
        if grandmaster:
            art.detail(arm, "High forge shoulder rivet", (sign * 1.579, 3.095, -.680),
                       (.105, .088, .033), satin)
    art.detail(torso, "Kiln guild stamp beside the belt crest", (.410, 1.865, -.899),
               (.245, .220, .113), rim, roll=28, shape=BLOCK)
    art.detail(torso, "Small furnace tile in the belt stamp", (.410, 1.865, -.966),
               (.116, .105, .041), plate, roll=28, shape=BLOCK)

    head = groups["Head"]
    art.detail(head, "Short kiln band between the bear ears", (0, 4.562, -.589),
               (.571, .164, .203), base, pitch=-9, material=FABRIC)
    art.detail(head, "Enamel kiln guild pin above the eyes", (0, 4.569, -.696),
               (.217, .154, .069), rim)
    art.detail(head, "Inlaid small furnace crest", (0, 4.572, -.737),
               (.112, .081, .030), satin, roll=32, shape=BLOCK)


def _hellhound(art, groups, grandmaster):
    if grandmaster:
        dark, cloth, braid, knot = "253248", "4D5979", "B98EA5", "F3CD91"
    else:
        dark, cloth, braid, knot = "422D3E", "823F53", "CB7957", "F3BA85"

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Swept cinder messenger's neck wrap", (sign * .491, 2.817, -.570),
                   (.341, .858, .280), dark, roll=sign * -32, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Channeled color on the messenger's scarf", (sign * .497, 2.822, -.714),
                   (.251, .689, .126), cloth, roll=sign * -32, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Fine warm edging on the scarf", (sign * .570, 2.851, -.767),
                   (.058, .539, .038), braid, roll=sign * -31, yaw=sign * -14, shape=BLOCK)
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Thin cinder shoulder patch", (sign * 1.045, 2.864, -.366),
                   (.523, .315, .291), dark, roll=sign * 22, material=FABRIC)
        art.detail(arm, "Dyed pad on the shoulder patch", (sign * 1.060, 2.890, -.511),
                   (.345, .204, .128), cloth, roll=sign * 22)
        art.detail(arm, "Gold edge on the shoulder patch", (sign * 1.090, 2.924, -.579),
                   (.183, .069, .032), braid, roll=sign * 22)
    art.detail(torso, "Messenger's offset clasp", (-.232, 1.855, -.687),
               (.303, .202, .126), braid, roll=-11)
    art.detail(torso, "Tinted silk under the clasp", (-.232, 1.856, -.754),
               (.169, .112, .037), cloth, roll=-11)
    if grandmaster:
        art.detail(torso, "Folded short ribbon below the messenger's sash", (-.347, 1.650, -.653),
                   (.173, .403, .115), cloth, roll=-23, material=FABRIC)

    head = groups["Head"]
    art.detail(head, "Small forward cinder headband", (0, 4.350, -.539),
               (.486, .162, .205), dark, pitch=-14, material=FABRIC)
    art.detail(head, "Gilt edge on the messenger crest", (0, 4.354, -.651),
               (.200, .137, .067), braid, roll=-19)
    art.detail(head, "Light centered flame on the crest", (0, 4.357, -.687),
               (.084, .101, .034), knot, roll=-16, shape=BLOCK)


def build_night_evolutions(form_visuals, fighter_visuals, *, item, part, prop, vector):
    """Create the two earned outfits for each fighter in the supplied library."""
    appearances = (("abyssal-kraken", _kraken), ("magma-grizzly-bear", _grizzly), ("obsidian-hellhound", _hellhound))
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
