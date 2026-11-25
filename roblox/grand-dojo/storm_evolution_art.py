"""Original evolution outfits for Golden Eagle and Celestial Storm Dragon."""

from reedguard_forms_art import _copy_art_tree
from roster_fighter_art import BLOCK, FABRIC, _FighterArt


def _eagle(art, groups, grandmaster):
    if grandmaster:
        dark, cloth, trim, inset = "28414F", "387B85", "E4B660", "F4E3BA"
    else:
        dark, cloth, trim, inset = "512E43", "805368", "C89559", "E5C99C"

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Wrapped upper flight harness", (sign * .542, 2.663, -.648),
                   (.357, 1.134, .251), dark, roll=sign * -23, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Satin in the flight harness", (sign * .552, 2.668, -.779),
                   (.235, .897, .107), cloth, roll=sign * -23, yaw=sign * -15, material=FABRIC)
        art.detail(torso, "Gilt braid woven through the harness", (sign * .606, 2.693, -.832),
                   (.052, .713, .045), trim, roll=sign * -23, yaw=sign * -15, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Small ivory loop on the flight harness", (sign * .583, 2.915, -.786),
                       (.127, .148, .068), inset, roll=sign * -20)

        arm = groups[f"{side} Arm"]
        art.detail(arm, "Narrow cover on the upper wing root", (sign * 1.200, 2.970, -.359),
                   (.527, .335, .299), dark, roll=sign * 26, material=FABRIC)
        art.detail(arm, "Swept cloth on the upper wing root", (sign * 1.233, 2.991, -.503),
                   (.395, .212, .120), cloth, roll=sign * 26)
        art.detail(arm, "Short curved seam along the flight patch", (sign * 1.272, 3.016, -.570),
                   (.222, .067, .039), trim, roll=sign * 26)
    art.detail(torso, "Atlas cartouche beside the belt clasp", (-.310, 1.863, -.787),
               (.277, .202, .099), trim, roll=-21)
    art.detail(torso, "Enameled route line in the atlas cartouche", (-.310, 1.865, -.843),
               (.139, .105, .025), cloth, roll=-21)

    head = groups["Head"]
    art.detail(head, "Narrow sky-guide forehead band", (0, 4.352, -.558),
               (.540, .161, .179), dark, pitch=-10, material=FABRIC)
    art.detail(head, "Swept crest of the sky-guide band", (0, 4.363, -.656),
               (.233, .135, .060), trim, roll=-17)
    art.detail(head, "Inset polished trail marker", (0, 4.366, -.695),
               (.109, .083, .034), inset, roll=-17)


def _dragon(art, groups, grandmaster):
    if grandmaster:
        dark, enamel, lining, glint = "41416A", "6D6B9E", "D2C9E4", "F2E7C7"
    else:
        dark, enamel, lining, glint = "2F5151", "498276", "ACAD74", "E3D99D"

    torso = groups["Torso"]
    for sign, side in ((-1, "Left"), (1, "Right")):
        art.detail(torso, "Swept wrap along the edge of the storm scales", (sign * .734, 2.669, -.620),
                   (.358, 1.150, .291), dark, roll=sign * -16, yaw=sign * -17, material=FABRIC)
        art.detail(torso, "Dyed cloth beside the dragon's chest scales", (sign * .731, 2.685, -.775),
                   (.243, .883, .121), enamel, roll=sign * -16, yaw=sign * -17, material=FABRIC)
        art.detail(torso, "Soft metallic border along the storm wrap", (sign * .782, 2.708, -.839),
                   (.059, .697, .045), lining, roll=sign * -16, yaw=sign * -17, shape=BLOCK)
        if grandmaster:
            art.detail(torso, "Small gilt collar stud above the mantle seam", (sign * .622, 2.940, -.814),
                       (.121, .120, .037), glint)

        arm = groups[f"{side} Arm"]
        art.detail(arm, "Close-fitting cloth behind the glazed wing-root scale", (sign * 1.344, 2.934, -.404),
                   (.537, .384, .262), dark, roll=sign * 21, material=FABRIC)
        art.detail(arm, "Enamel wing-root scale over the cloth", (sign * 1.359, 2.954, -.532),
                   (.410, .255, .129), enamel, roll=sign * 21)
        art.detail(arm, "Thin polished cloud-scale seam", (sign * 1.384, 2.984, -.598),
                   (.235, .088, .041), lining, roll=sign * 20)
    art.detail(torso, "Folded pennant at the side of the storm sash", (-.386, 1.775, -.773),
               (.235, .342, .140), dark, roll=-17, material=FABRIC)
    art.detail(torso, "Tinted enamel on the side of the storm sash", (-.391, 1.786, -.848),
               (.151, .222, .054), enamel, roll=-17)

    head = groups["Head"]
    art.detail(head, "Low cloud circlet between the dragon's horns", (0, 4.385, -.730),
               (.550, .180, .169), dark, pitch=-14, material=FABRIC)
    art.detail(head, "Ceremonial cloud jewel's thin bezel", (0, 4.384, -.816),
               (.197, .179, .053), lining, roll=45, shape=BLOCK)
    art.detail(head, "Polished cloud jewel inset", (0, 4.385, -.851),
               (.106, .105, .027), glint, roll=45, shape=BLOCK)


def build_storm_evolutions(form_visuals, fighter_visuals, *, item, part, prop, vector):
    """Create both earned outfits for each Skywalk Peaks fighter."""
    appearances = (("golden-eagle", _eagle), ("celestial-storm-dragon", _dragon))
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
