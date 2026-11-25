"""Native evolution apparel for Penguin, Silverback, and Fire Salamander."""

from reedguard_forms_art import _copy_art_tree
from roster_fighter_art import BLOCK, CYLINDER, FABRIC, _FighterArt


def _penguin(art, groups, grandmaster):
    if grandmaster:
        dark, cloth, panel, metal, pale = "21495C", "317482", "A9D9DC", "6EA7B8", "E1F1EA"
    else:
        dark, cloth, panel, metal, pale = "253346", "455D7E", "6F8B9E", "AA7250", "E3B581"

    head = groups["Head"]
    art.detail(head, "Seafarer forehead band", (.014, 4.590, -.401), (.843, .152, .270), cloth,
               pitch=16, material=FABRIC)
    art.detail(head, "Seafarer crest setting", (.015, 4.625, -.526), (.235, .192, .077), metal)
    art.detail(head, "Seafarer crest gem", (.015, 4.626, -.569), (.128, .115, .037), panel, roll=45, shape=BLOCK)
    if grandmaster:
        for sign in (-1, 1):
            art.detail(head, "Glacier glass crown facet", (.015+sign*.163, 4.596, -.533), (.135, .123, .070), pale,
                       yaw=sign*-14, roll=sign*28)

    torso = groups["Torso"]
    art.detail(torso, "Layered seafarer scarf clasp", (-.27, 3.329, -.508), (.397, .258, .165), dark,
               roll=-18, material=FABRIC)
    art.detail(torso, "Cast harbor clasp rim", (-.279, 3.332, -.593), (.268, .202, .071), metal, roll=-18)
    art.detail(torso, "Mapped harbor clasp center", (-.279, 3.332, -.633), (.148, .102, .044), pale, roll=-18)
    art.detail(torso, "Tide chart belt plate", (.129, 1.861, -.676), (.453, .188, .131), metal, roll=-5)
    art.detail(torso, "Indigo tide chart inset", (.129, 1.867, -.749), (.262, .092, .041), dark, roll=-5)
    for sign in (-1, 1):
        x=sign*.493
        art.detail(torso, "Curved tide vest panel", (x, 2.593, -.587), (.385, .872, .220), dark,
                   yaw=sign*-18, roll=sign*15, material=FABRIC)
        art.detail(torso, "Seafarer shoulder sash edge", (x+sign*.030, 2.650, -.691), (.229, .660, .103), cloth,
                   yaw=sign*-18, roll=sign*15, material=FABRIC)
        for index in range(2 if grandmaster else 1):
            art.detail(torso, "Foam-line sash embroidery", (x+sign*.027, 2.574+index*.182, -.744),
                       (.184, .041, .031), pale, yaw=sign*-18, roll=sign*-18)
        if grandmaster:
            art.detail(torso, "Frostglass coat lapel", (sign*.363, 3.030, -.582), (.274, .523, .132), panel,
                       yaw=sign*-15, roll=sign*-25, material=FABRIC)
            art.detail(torso, "Pearl line on Frostglass lapel", (sign*.406, 3.059, -.637), (.073, .397, .058), pale,
                       yaw=sign*-15, roll=sign*-25)

    # The original flippers are sculpted in an asymmetric stance. Keep the
    # pads near those fixed elbow planes, clear of both leading wing tips.
    for side, center, yaw, roll in (("Left", (-1.159, 2.707, -.628), -16, -13),
                                    ("Right", (1.251, 2.746, .130), 20, 16)):
        arm=groups[f"{side} Arm"]
        x,y,z=center
        art.detail(arm, "Floating harbor cuff backing", center, (.443, .462, .222), dark,
                   yaw=yaw, roll=roll, material=FABRIC)
        art.detail(arm, "Shaped floating harbor cuff plate", (x, y+.014, z-.104), (.362, .374, .164), panel,
                   yaw=yaw, roll=roll)
        art.detail(arm, "Rim of harbor cuff", (x, y+.079, z-.175), (.242, .072, .057), metal,
                   yaw=yaw, roll=roll)
        if grandmaster:
            art.detail(arm, "White wave on harbor cuff", (x, y-.027, z-.185), (.191, .066, .042), pale,
                       yaw=yaw, roll=roll-12)


def _gorilla(art, groups, grandmaster):
    if grandmaster:
        backing, cloth, panel, rim, light = "2D473A", "4F6350", "ABC0AA", "AE955C", "E9D8A0"
    else:
        backing, cloth, panel, rim, light = "332E38", "4D4D58", "776568", "A9754F", "CA985D"

    head = groups["Head"]
    art.detail(head, "Stoneworks headband", (0, 5.366, -.459), (.981, .168, .452), cloth,
               pitch=15, material=FABRIC)
    art.detail(head, "Mason's brass crest base", (0, 5.378, -.713), (.272, .183, .066), rim)
    art.detail(head, "Mountain crest setting", (0, 5.389, -.755), (.139, .131, .046), panel, roll=45, shape=BLOCK)
    if grandmaster:
        art.detail(head, "Carved ivory mountain peak", (0, 5.419, -.783), (.081, .142, .029), light, roll=45, shape=BLOCK)

    torso = groups["Torso"]
    art.detail(torso, "Mason's wide sash weave", (0, 2.184, .114), (2.151, .235, 1.492), backing, material=FABRIC)
    art.detail(torso, "Metal stoneworks belt clasp", (-.125, 2.16, -.746), (.493, .278, .147), rim)
    art.detail(torso, "Carved center of stoneworks clasp", (-.125, 2.166, -.830), (.302, .162, .058), panel)
    art.detail(torso, "Raised mason's crest", (-.125, 2.186, -.858), (.109, .098, .025), light, roll=45, shape=BLOCK)
    for sign in (-1, 1):
        x=sign*.710
        art.detail(torso, "Stoneworks vest facing", (sign*.509, 3.339, -.707), (.468, 1.033, .203), cloth,
                   roll=sign*-23, yaw=sign*-13, material=FABRIC)
        art.detail(torso, "Metal-lined stoneworks vest lapel", (sign*.566, 3.419, -.815), (.123, .815, .086), rim,
                   roll=sign*-23, yaw=sign*-13)
        art.detail(torso, "Cloth vest pin", (x, 3.694, -.835), (.121, .106, .057), light, roll=sign*24)
        if grandmaster:
            art.detail(torso, "Light jade embroidery at the collar", (sign*.585, 3.660, -.826), (.131, .358, .039),
                       panel, roll=sign*-23)
            art.detail(torso, "Glazed ivory belt tab", (sign*.497, 1.836, -.615), (.380, .538, .165), panel,
                       roll=sign*14, material=FABRIC)
            art.detail(torso, "Thin gilding on stoneworks belt tab", (sign*.548, 1.854, -.706), (.059, .376, .033), rim,
                       roll=sign*14)

    for sign,side,y,z,x in ((-1,"Left",2.218,-.455,-1.779),(1,"Right",2.700,-.729,1.572)):
        arm=groups[f"{side} Arm"]
        art.detail(arm, "Stoneworks shoulder backing", (sign*1.462, 3.727, .171), (.995, .645, .958), backing,
                   roll=sign*-16, material=FABRIC)
        art.detail(arm, "Stoneworks curved shoulder plate", (sign*1.508, 3.803, -.003), (.857, .488, .774), panel,
                   roll=sign*-19)
        art.detail(arm, "Copper shoulder arc", (sign*1.541, 3.849, -.368), (.447, .157, .118), rim,
                   roll=sign*-16)
        if grandmaster:
            art.detail(arm, "Carved shoulder plate pin", (sign*1.55, 3.706, -.390), (.181, .168, .063), light)
        art.detail(arm, "Mason's forearm wrap", (x, y, z), (.806, .670, .158), cloth,
                   pitch=-17, roll=sign*-8, material=FABRIC)
        art.detail(arm, "Thin braiding on the forearm wrap", (x, y+.229, z-.063), (.482, .124, .066), rim,
                   pitch=-17, roll=sign*-8)
        art.detail(arm, "Flat mason's forearm rivet", (x, y+.112, z-.085), (.116, .092, .036), light,
                   pitch=-17, roll=sign*-8, shape=BLOCK)


def _salamander(art, groups, grandmaster):
    if grandmaster:
        black, cloth, glaze, trim, spark = "493348", "675269", "F0CAB1", "C16B52", "FFD6A0"
    else:
        black, cloth, glaze, trim, spark = "372D30", "74423A", "A24735", "BA7754", "EFAB69"

    head=groups["Head"]
    art.detail(head, "Protective kiln foreband", (0, 4.531, -.609), (.681, .134, .297), cloth,
               pitch=20, material=FABRIC)
    art.detail(head, "Fired ceramic forehead bead", (0, 4.551, -.760), (.183, .148, .064), trim,
               pitch=15, roll=45, shape=BLOCK)
    art.detail(head, "Amber inset on forehead bead", (0, 4.555, -.795), (.104, .083, .031), spark,
               pitch=15, roll=45, shape=BLOCK)
    if grandmaster:
        for sign in (-1, 1):
            art.detail(head, "Small cream arch at brow band", (sign*.144, 4.545, -.757), (.130, .061, .063), glaze,
                       yaw=sign*-14, roll=sign*17)

    torso=groups["Torso"]
    art.detail(torso, "Kiln runner chest lining", (.262, 2.851, -.398), (.528, .681, .223), black,
               pitch=-7, roll=20, material=FABRIC)
    art.detail(torso, "Kiln run glazed chest piece", (.268, 2.841, -.510), (.417, .550, .144), glaze,
               pitch=-7, roll=20)
    for index,(x,y,roll) in enumerate(((.222,2.795,37),(.279,2.840,26),(.328,2.884,19)),1):
        art.detail(torso, f"Fire kiln crest stroke {index}", (x,y,-.584), (.071, .178, .038),
                   trim if grandmaster else spark, roll=roll)
    art.detail(torso, "Kiln worker broad belt accent", (0, 1.996, -.414), (1.036, .144, .189), cloth,
               material=FABRIC)
    art.detail(torso, "Old copper belt lock", (0, 1.991, -.521), (.395, .185, .083), trim)
    art.detail(torso, "Cast glazed belt inset", (0, 1.993, -.565), (.237, .119, .048), glaze)
    if grandmaster:
        art.detail(torso, "Plum seam tying the kiln collar", (-.268, 2.786, -.474), (.299, .730, .153), cloth,
                   roll=19, pitch=-8, material=FABRIC)
        art.detail(torso, "Light ceramic trim on kiln collar", (-.300, 2.831, -.544), (.106, .569, .064), glaze,
                   roll=19, pitch=-8)
        for sign in (-1,1):
            art.detail(torso, "Split soot-plum kiln apron front", (sign*.267, 1.617, -.364), (.361, .438, .145), cloth,
                       roll=sign*8, material=FABRIC)
            art.detail(torso, "Cream kiln apron binding", (sign*.267, 1.708, -.444), (.247, .074, .040), glaze,
                       roll=sign*8)
            art.detail(torso, "Ember arch on kiln apron", (sign*.268, 1.599, -.437), (.074, .224, .038), spark,
                       roll=sign*21)

    for sign,side,y,z in ((-1,"Left",3.022,-.347),(1,"Right",2.746,-.534)):
        arm=groups[f"{side} Arm"]
        art.detail(arm, "Low raised kiln shoulder lining", (sign*.748, 3.266, -.178), (.541, .340, .467), black,
                   roll=sign*-20, material=FABRIC)
        art.detail(arm, "Rounded fired-clay shoulder plate", (sign*.766, 3.282, -.261), (.461, .237, .407), glaze,
                   roll=sign*-20)
        art.detail(arm, "Small bronze cap line", (sign*.791, 3.336, -.430), (.262, .084, .071), trim,
                   roll=sign*-19)
        art.detail(arm, "Stacked kiln wrist wrap", (sign*.945,y,z), (.124, .436, .456), cloth,
                   shape=CYLINDER, roll=90+sign*9, pitch=-18, material=FABRIC)
        art.detail(arm, "Old ceramic wrist ring", (sign*.949,y+.075,z+.027), (.056, .437, .435),
                   glaze if grandmaster else trim, shape=CYLINDER, roll=90+sign*9, pitch=-18)
        if grandmaster:
            art.detail(arm, "Warm edge-stitch on wrist wrap", (sign*.949,y+.110,z+.049), (.042, .422, .425), spark,
                       shape=CYLINDER, roll=90+sign*9, pitch=-18)

        leg=groups[f"{side} Leg"]
        depth=-.278 if sign<0 else -.538
        art.detail(leg, "Fitted kiln worker knee shield", (sign*.525, 1.009, depth), (.373, .332, .182), black,
                   pitch=11, roll=sign*7)
        art.detail(leg, "Small fired insert over knee", (sign*.525, 1.014, depth-.087), (.272, .246, .093), glaze,
                   pitch=11, roll=sign*7)
        if grandmaster:
            art.detail(leg, "Knee shield bronze line", (sign*.526, 1.048, depth-.129), (.154, .067, .046), trim,
                       pitch=11, roll=sign*7)


def build_starter_evolutions(form_visuals, fighter_visuals, *, item, part, prop, vector):
    """Copy the same equipped meshes and build two original outfits per fighter."""
    stages = (("warrior", False), ("grandmaster", True))
    appearances = (("penguin-brawler", _penguin), ("silverback-gorilla", _gorilla), ("fire-salamander", _salamander))
    source_models = {node.findtext("Properties/*[@name='Name']"): node for node in fighter_visuals.findall("Item")}
    helpers = dict(item=item, part=part, prop=prop, vector=vector)
    for fighter_id, decorate in appearances:
        body = source_models[fighter_id]
        for stage, grandmaster in stages:
            art = _FighterArt(form_visuals, f"{fighter_id}-{stage}", **helpers)
            groups = {node.findtext("Properties/*[@name='Name']"): _copy_art_tree(node, art.model, item)
                      for node in body.findall("Item")}
            decorate(art, groups, grandmaster)
    return form_visuals
