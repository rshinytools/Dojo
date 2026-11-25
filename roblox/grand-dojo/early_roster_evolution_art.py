"""Original Warrior and Grandmaster apparel for Frog, Otter, and Rooster."""

from reedguard_forms_art import _copy_art_tree
from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _frog(art, groups, grandmaster):
    if grandmaster:
        dark, cloth, trim, pale, jewel = "51354D", "AB6483", "D7AC69", "F2DEB6", "E7969D"
    else:
        dark, cloth, trim, pale, jewel = "392842", "745176", "BA7754", "DAA375", "BC6F70"

    head = groups["Head"]
    art.detail(head, "Lotus forehead tie", (0, 4.257, -.496), (.643, .151, .143), cloth,
               pitch=-9, material=FABRIC)
    art.detail(head, "Brass setting on lotus tie", (0, 4.281, -.570), (.190, .166, .051), trim)
    art.detail(head, "Lotus center bead", (0, 4.286, -.604), (.093, .090, .028), jewel, roll=45, shape=BLOCK)
    if grandmaster:
        for sign in (-1, 1):
            art.detail(head, "Small petal on lotus tie", (sign * .137, 4.254, -.570), (.068, .129, .037), pale,
                       roll=sign * 35)

    torso = groups["Torso"]
    for sign in (-1, 1):
        art.detail(torso, "Folded lotus gi facing", (sign * .441, 2.636, -.516), (.336, .900, .212), dark,
                   roll=sign * -19, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Colored silk on lotus facing", (sign * .467, 2.667, -.608), (.231, .730, .096), cloth,
                   roll=sign * -19, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Metallic thread on lotus facing", (sign * .504, 2.676, -.653), (.047, .627, .048), trim,
                   roll=sign * -19, yaw=sign * -14, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Silk petal at the gi hem", (sign * .496, 1.563, -.529), (.369, .454, .129), cloth,
                       roll=sign * 11, material=FABRIC)
            art.detail(torso, "Fine gold hem embroidery", (sign * .509, 1.562, -.591), (.208, .073, .065), pale,
                       roll=sign * 11)
    art.detail(torso, "Tri-fold plum lotus belt", (-.144, 1.841, -.548), (.901, .211, .217), dark,
               material=FABRIC)
    art.detail(torso, "Banded lotus sash clasp", (-.168, 1.853, -.661), (.344, .234, .123), trim)
    art.detail(torso, "Soft inset beneath lotus sash clasp", (-.168, 1.853, -.724), (.254, .157, .057), cloth)
    for spread, y, angle in ((-.068, 1.862, 38), (0, 1.888, 0), (.068, 1.862, -38)):
        art.detail(torso, "Raised lotus sash petal", (-.168 + spread, y, -.757), (.048, .096, .025), pale,
                   roll=angle)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Cushioned lotus shoulder binding", (sign * .984, 2.726, -.160), (.542, .420, .409), dark,
                   roll=sign * 14, material=FABRIC)
        art.detail(arm, "Layered shoulder petal", (sign * 1.013, 2.745, -.315), (.417, .292, .162), cloth,
                   roll=sign * 17)
        art.detail(arm, "Threaded lotus shoulder clasp", (sign * 1.051, 2.780, -.392), (.202, .111, .055), trim,
                   roll=sign * 18)
        art.detail(arm, "Thin lotus cuff tie", (sign * 1.049, 2.405, -.121), (.115, .617, .647), cloth,
                   shape=CYLINDER, roll=90 + sign * 13, material=FABRIC)
        if grandmaster:
            art.detail(arm, "Small cream crest on shoulder petal", (sign * 1.030, 2.698, -.398), (.167, .089, .044), pale,
                       roll=sign * -15)

        leg = groups[f"{side} Leg"]
        art.detail(leg, "Upper lotus kneepad binding", (sign * .517, .870, -.279), (.363, .303, .172), dark,
                   roll=sign * 9, material=FABRIC)
        art.detail(leg, "Rounded lotus knee insert", (sign * .518, .886, -.357), (.275, .219, .080), cloth,
                   roll=sign * 9)


def _otter(art, groups, grandmaster):
    if grandmaster:
        leather, cloth, metal, pale, jewel = "3E3C64", "756FA8", "9FADCF", "E0E9DB", "8798CF"
    else:
        leather, cloth, metal, pale, jewel = "572C33", "8D4945", "B77A52", "E5B27B", "BE7668"

    head = groups["Head"]
    art.detail(head, "River scout forehead wrap", (0, 4.382, -.477), (.681, .173, .243), cloth,
               pitch=13, material=FABRIC)
    art.detail(head, "Scalloped river scout tie clasp", (0, 4.390, -.607), (.237, .172, .067), metal, roll=11)
    art.detail(head, "Waterworn pebble on scout tie", (.013, 4.397, -.644), (.120, .110, .045), jewel, roll=11)
    if grandmaster:
        for sign in (-1, 1):
            art.detail(head, "Pale pearl setting bead", (sign * .159, 4.392, -.602), (.077, .070, .049), pale)

    torso = groups["Torso"]
    for sign in (-1, 1):
        art.detail(torso, "Explorer's folded vest edging", (sign * .436, 2.646, -.554), (.368, .930, .243), leather,
                   roll=sign * -24, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Woven facing on explorer's vest", (sign * .457, 2.670, -.662), (.247, .739, .111), cloth,
                   roll=sign * -24, yaw=sign * -14, material=FABRIC)
        art.detail(torso, "Metallic binding on explorer's vest", (sign * .502, 2.691, -.715), (.050, .594, .059), metal,
                   roll=sign * -24, yaw=sign * -15, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Pale waterproof collar stitch", (sign * .367, 2.892, -.704), (.131, .232, .051), pale,
                       roll=sign * -27)
    art.detail(torso, "River scout's new buckle backing", (-.208, 1.856, -.647), (.425, .218, .158), leather)
    art.detail(torso, "Metal clasp on river scout belt", (-.216, 1.863, -.734), (.351, .185, .087), metal)
    for step, (x, y) in enumerate(((-.303, 1.870), (-.219, 1.892), (-.139, 1.871)), 1):
        art.detail(torso, f"Pebble in river scout clasp {step}", (x, y, -.783), (.072, .074, .031), pale,
                   roll=16 if step == 2 else -12)
    art.detail(torso, "Carved back clasp for scout harness", (0, 2.680, .678), (.378, .377, .062), cloth,
               roll=18)
    if grandmaster:
        art.detail(torso, "White arch on explorer's rear crest", (0, 2.714, .717), (.293, .116, .038), pale,
                   roll=-12)
        art.detail(torso, "Trailing split streamer above tail", (-.26, 1.859, .589), (.264, .433, .172), cloth,
                   roll=20, material=FABRIC)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Explorer's rolled sleeve binding", (sign * 1.012, 2.721, -.055), (.679, .451, .648), leather,
                   pitch=-9, roll=sign * 14, material=FABRIC)
        art.detail(arm, "Polished canvas sleeve facing", (sign * 1.041, 2.751, -.326), (.448, .313, .166), cloth,
                   roll=sign * 17)
        art.detail(arm, "Two-tone explorer cuff braid", (sign * 1.100, 2.389, -.161), (.099, .603, .638), metal,
                   shape=CYLINDER, roll=90 + sign * 12)
        if grandmaster:
            art.detail(arm, "White wave pin on explorer sleeve", (sign * 1.042, 2.759, -.414), (.248, .091, .052), pale,
                       roll=sign * -17)
        leg = groups[f"{side} Leg"]
        art.detail(leg, "Dry guard over explorer's shin", (sign * .517, .832, -.270), (.358, .344, .169), leather,
                   roll=sign * 9, material=FABRIC)
        art.detail(leg, "Waterproof shin panel", (sign * .517, .849, -.351), (.258, .225, .086), cloth,
                   roll=sign * 9)


def _rooster(art, groups, grandmaster):
    if grandmaster:
        silk, cloth, trim, pale, jewel = "652B44", "A04852", "E5A761", "FADEAA", "D57363"
    else:
        silk, cloth, trim, pale, jewel = "2C344F", "536491", "BC8050", "EBC78B", "C5966C"

    head = groups["Head"]
    art.detail(head, "Kickboxer's padded brow band", (0, 4.463, -.501), (.689, .156, .258), silk,
               pitch=12, material=FABRIC)
    art.detail(head, "Sunrise brow pin", (0, 4.489, -.633), (.217, .148, .056), trim,
               roll=45, shape=BLOCK)
    art.detail(head, "Top light on sunrise brow pin", (0, 4.512, -.666), (.101, .091, .025), pale)
    if grandmaster:
        for sign in (-1, 1):
            art.detail(head, "Colored inlay beside sunrise pin", (sign * .145, 4.471, -.638), (.129, .063, .047), jewel,
                       roll=sign * 17)

    torso = groups["Torso"]
    for sign in (-1, 1):
        art.detail(torso, "Stitched kickboxing chest harness", (sign * .434, 2.610, -.609), (.299, .987, .250), silk,
                   roll=sign * -19, yaw=sign * -13, material=FABRIC)
        art.detail(torso, "Raised kickboxing harness facing", (sign * .452, 2.649, -.730), (.198, .792, .106), cloth,
                   roll=sign * -19, yaw=sign * -13, material=FABRIC)
        art.detail(torso, "Gilt cord on kickboxing harness", (sign * .485, 2.657, -.782), (.050, .651, .039), trim,
                   roll=sign * -19, yaw=sign * -13, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Split crimson belt skirt", (sign * .420, 1.630, -.516), (.368, .533, .182), cloth,
                       roll=sign * 13, material=FABRIC)
            art.detail(torso, "Light thread embroidered on belt skirt", (sign * .470, 1.631, -.605), (.077, .317, .049), pale,
                       roll=sign * 13)
    art.detail(torso, "Champion's rounded chest pin", (0, 2.768, -.807), (.366, .316, .113), trim)
    art.detail(torso, "Sunrise enamel on chest pin", (0, 2.768, -.866), (.249, .210, .051), silk)
    for x, peak, roll in ((-.074, 2.768, 35), (0, 2.813, 0), (.074, 2.768, -35)):
        art.detail(torso, "Thread of sunlight on enamel pin", (x, peak, -.897), (.046, .103, .023), pale,
                   roll=roll)
    art.detail(torso, "Kickboxer's split belt buckle", (-.236, 1.892, -.669), (.332, .207, .107), trim)
    art.detail(torso, "Enamel inset on split belt buckle", (-.236, 1.898, -.730), (.168, .112, .039), jewel)

    for sign, side in ((-1, "Left"), (1, "Right")):
        arm = groups[f"{side} Arm"]
        art.detail(arm, "Scalloped guard on upper wing", (sign * 1.054, 2.674, -.208), (.608, .402, .431), silk,
                   roll=sign * 16, material=FABRIC)
        art.detail(arm, "Kickboxer's armored wing ridge", (sign * 1.086, 2.694, -.395), (.433, .298, .181), cloth,
                   roll=sign * 15)
        art.detail(arm, "Brass seam across wing ridge", (sign * 1.105, 2.724, -.481), (.265, .078, .044), trim,
                   roll=sign * 15)
        if grandmaster:
            art.detail(arm, "Sunrise enamel wing badge", (sign * 1.076, 2.649, -.484), (.170, .117, .051), jewel,
                       roll=sign * 15)
        leg = groups[f"{side} Leg"]
        art.detail(leg, "Kickboxer's raised upper shin shield", (sign * .481, .770, -.310), (.381, .346, .294), silk,
                   pitch=14, roll=sign * 8)
        art.detail(leg, "Lacquered facing on shin shield", (sign * .480, .784, -.453), (.292, .255, .101), cloth,
                   pitch=14, roll=sign * 8)
        art.detail(leg, "Small metal knee rivet", (sign * .480, .797, -.503), (.109, .084, .054), trim,
                   roll=sign * 8)


def build_early_roster_evolutions(form_visuals, fighter_visuals, *, item, part, prop, vector):
    """Write two cosmetic forms for each fighter into the existing form library."""
    appearances = (("karate-frog", _frog), ("river-otter", _otter), ("rooster-kickboxer", _rooster))
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
