"""Native apparel for Reedguard's Warrior and Grandmaster forms."""

from copy import deepcopy

from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


FIGHTER = "reedguard-kangaroo"


def _copy_art_tree(source, parent, item):
    properties = source.find("Properties")
    # The body library carries asset URLs and local attachments only. Allocate
    # every Item through the builder to keep its referent unique in the place.
    if properties.find("Ref") is not None:
        raise ValueError("Reedguard form source has an instance reference")
    name = properties.findtext("*[@name='Name']")
    clone = item(parent, source.get("class"), name)
    clone.remove(clone.find("Properties"))
    clone.append(deepcopy(properties))
    for child in source.findall("Item"):
        _copy_art_tree(child, clone, item)
    return clone


def _badge(art, group, x, y, z, color, scale):
    """Repeat the original Reedguard motif with three short raised leaves."""
    for index, (spread, rise, angle) in enumerate(((-.058, .028, 31), (0, .065, 2), (.058, .031, -31)), 1):
        art.detail(group, f"Embroidered reed blade {index}", (x + spread * scale, y + rise * scale, z),
                   (.048 * scale, .166 * scale, .024), color, roll=angle)


def _warrior(art, groups):
    burgundy, quilt, dark = "63242A", "A13638", "39232A"
    leather, bronze, gold = "745044", "B17844", "E0AA65"

    head = groups["Head"]
    art.detail(head, "Scarlet brow tie", (0, 3.659, -.214), (.714, .127, .225), burgundy, material=FABRIC)
    art.detail(head, "Antique brass brow bead", (0, 3.678, -.328), (.139, .116, .041), gold, roll=45, shape=BLOCK)
    art.detail(head, "Warp stitch below brow bead", (0, 3.621, -.322), (.279, .034, .049), bronze)

    torso = groups["Torso"]
    art.detail(torso, "Crimson chest guard lining", (-.360, 2.545, -.334), (.551, .710, .237), dark,
               yaw=12, roll=-14, material=FABRIC)
    art.detail(torso, "Raised lacquer chest guard", (-.357, 2.567, -.425), (.467, .603, .117), quilt,
               yaw=12, roll=-14)
    art.detail(torso, "Bronze chest guard lip", (-.420, 2.696, -.471), (.319, .061, .070), bronze,
               roll=-14, yaw=12)
    _badge(art, torso, -.356, 2.507, -.494, gold, .82)
    art.detail(torso, "Dark belt clasp mount", (-.121, 1.731, -.482), (.363, .247, .105), dark)
    art.detail(torso, "Antique brass belt clasp", (-.121, 1.731, -.539), (.268, .176, .067), bronze)
    art.detail(torso, "Scarlet belt buckle rivet", (-.121, 1.730, -.577), (.094, .081, .026), quilt)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Warrior curved shoulder backing", (sign * 1.014, 2.693, .025), (.668, .338, .639),
                   dark, roll=sign * -12, material=FABRIC)
        art.detail(arm, "Warrior brass shoulder cap", (sign * 1.028, 2.742, -.015), (.602, .282, .590),
                   bronze, roll=sign * -13)
        art.detail(arm, "Polished shoulder rib", (sign * 1.062, 2.781, -.221), (.389, .130, .158),
                   gold, roll=sign * -15)
        art.detail(arm, "Scarlet edge on shoulder cap", (sign * 1.006, 2.633, -.292), (.429, .123, .104),
                   quilt, roll=sign * -12)
        art.detail(arm, "Oxblood wrist cuff", (sign * 1.062, 1.971, -.284), (.139, .579, .563), burgundy,
                   shape=CYLINDER, roll=90 + sign * 8, pitch=-15, material=FABRIC)
        art.detail(arm, "Buckled copper wrist strap", (sign * 1.067, 1.955, -.535), (.276, .119, .075),
                   leather, roll=sign * 9)
        art.detail(arm, "Square wrist rivet", (sign * 1.076, 1.959, -.572), (.098, .073, .034),
                   bronze, roll=sign * 9, shape=BLOCK)

        leg = groups[f"{side} Leg"]
        art.detail(leg, "Warrior leather shin backing", (sign * .432, .636, -.119), (.434, .570, .222),
                   leather, roll=sign * 8, pitch=12, material=FABRIC)
        art.detail(leg, "Scarlet woven shin panel", (sign * .430, .628, -.231), (.355, .467, .147),
                   burgundy, roll=sign * 8, pitch=12, material=FABRIC)
        art.detail(leg, "Antique brass shin clasp", (sign * .435, .634, -.311), (.172, .098, .052), bronze,
                   roll=sign * 8)


def _grandmaster(art, groups):
    jade, emerald, dark = "2D7869", "409181", "264842"
    ivory, cream, shadow = "E7D7B3", "F7E9CD", "B2A485"
    bronze, gilt = "B28850", "DEB67A"

    head = groups["Head"]
    art.detail(head, "Jade ceremonial brow band", (0, 3.682, -.197), (.716, .151, .218), jade, material=FABRIC)
    art.detail(head, "Grandmaster gilded brow trim", (0, 3.695, -.303), (.476, .065, .078), bronze)
    art.detail(head, "Ivory brow diadem", (0, 3.722, -.336), (.234, .181, .055), ivory, roll=45, shape=BLOCK)
    art.detail(head, "Polished jade diadem stone", (0, 3.722, -.368), (.127, .118, .044), emerald)
    for sign in (-1, 1):
        art.detail(head, "Gilt brow tie pin", (sign * .237, 3.69, -.323), (.095, .069, .049), gilt,
                   roll=sign * 12)

    torso = groups["Torso"]
    art.detail(torso, "Grandmaster white chest lining", (-.339, 2.584, -.373), (.486, .705, .247), ivory,
               yaw=12, roll=-19, material=FABRIC)
    art.detail(torso, "Deep jade chest flourish", (-.374, 2.582, -.500), (.295, .593, .103), jade,
               roll=-19, yaw=12, material=FABRIC)
    _badge(art, torso, -.360, 2.525, -.562, gilt, .9)
    art.detail(torso, "Jade waist sash", (0, 1.729, .016), (1.345, .220, .918), dark, material=FABRIC)
    art.detail(torso, "Ivory face of grandmaster belt", (0, 1.742, -.472), (1.222, .127, .084), ivory,
               material=FABRIC)
    art.detail(torso, "Wide gilt master belt plaque", (0, 1.745, -.538), (.416, .260, .114), gilt)
    art.detail(torso, "Jade master belt medallion", (0, 1.745, -.602), (.240, .174, .044), emerald)
    _badge(art, torso, 0, 1.708, -.632, cream, .57)
    for sign in (-1, 1):
        x = sign * .310
        art.detail(torso, "Grandmaster split jade tabard", (x, 1.286, -.510), (.470, .654, .148), jade,
                   roll=sign * 7, pitch=-6, material=FABRIC)
        art.detail(torso, "Ivory tabard top binding", (x, 1.531, -.580), (.384, .070, .060), ivory,
                   roll=sign * 7)
        art.detail(torso, "Grandmaster tabard leaf", (x, 1.235, -.593), (.095, .297, .040), gilt,
                   roll=sign * -21)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Rounded jade shoulder backing", (sign * 1.027, 2.686, .049), (.679, .368, .664), jade,
                   roll=sign * -13, material=FABRIC)
        art.detail(arm, "Grandmaster ivory shoulder scale", (sign * 1.025, 2.745, -.006), (.599, .283, .591),
                   ivory, roll=sign * -14)
        art.detail(arm, "Capped gilt shoulder seam", (sign * 1.078, 2.754, -.249), (.395, .094, .119), gilt,
                   roll=sign * -18)
        art.detail(arm, "Curved carved jade shoulder inset", (sign * 1.048, 2.635, -.271), (.371, .184, .139),
                   emerald, roll=sign * -13)
        art.detail(arm, "Thick jade wrist guard", (sign * 1.064, 1.943, -.312), (.170, .595, .609), jade,
                   shape=CYLINDER, roll=90 + sign * 8, pitch=-14, material=FABRIC)
        art.detail(arm, "Ivory wrist guard braid", (sign * 1.065, 1.991, -.347), (.064, .578, .571), ivory,
                   shape=CYLINDER, roll=90 + sign * 8, pitch=-14)
        art.detail(arm, "Gilt wrist clasp", (sign * 1.072, 1.949, -.611), (.182, .093, .050), gilt,
                   roll=sign * 9)

        leg = groups[f"{side} Leg"]
        art.detail(leg, "Grandmaster jade shin cloth", (sign * .433, .628, -.125), (.440, .601, .240), jade,
                   roll=sign * 9, pitch=12, material=FABRIC)
        art.detail(leg, "Grandmaster ivory shin facing", (sign * .430, .608, -.243), (.354, .456, .131), ivory,
                   roll=sign * 9, pitch=12)
        art.detail(leg, "Grandmaster shin band", (sign * .430, .633, -.312), (.278, .069, .034), shadow,
                   roll=sign * 9)
        art.detail(leg, "Shin guard gilt accent", (sign * .437, .699, -.315), (.075, .143, .038), gilt,
                   roll=sign * -18)


def build_reedguard_forms(storage, fighter_visuals, *, item, part, prop, vector):
    """Clone the established Reedguard shell and attach distinct apparel to each form."""
    model = next(node for node in fighter_visuals.findall("Item")
                 if node.findtext("Properties/*[@name='Name']") == FIGHTER)
    library = item(storage, "Folder", "FighterFormVisuals")
    for name, decorate in (("warrior", _warrior), ("grandmaster", _grandmaster)):
        art = _FighterArt(library, f"{FIGHTER}-{name}", item=item, part=part, prop=prop, vector=vector)
        groups = {node.findtext("Properties/*[@name='Name']"): _copy_art_tree(node, art.model, item)
                  for node in model.findall("Item")}
        decorate(art, groups)
    return library
