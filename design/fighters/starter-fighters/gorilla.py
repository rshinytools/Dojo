"""Original Silverback Gorilla geometry for the starter fighter art lineup."""

from math import cos, pi, sin


def build(p):
    charcoal = p.material("Gorilla charcoal fur", "37353B", .91, 94)
    warm_fur = p.material("Warm charcoal fur planes", "454047", .91, 94)
    shadow_fur = p.material("Deep charcoal fur", "28262E", .94, 104)
    silver = p.material("Silver saddle fur", "8D8D94", .87, 96)
    silver_shade = p.material("Silver saddle transition", "696970", .90, 99)
    silver_tip = p.material("Silver ruff tip", "AAA3A0", .88, 88)
    face = p.material("Gorilla bare facial skin", "5B4F51", .76)
    bare_hand = p.material("Palm and knuckle skin", "5F5354", .78)
    nose = p.material("Dark broad nose", "494043", .67)
    deep = p.material("Nostril and mouth shadows", "252029", .91)
    ear_inner = p.material("Warm muted ear skin", "7E605A", .84)
    cream = p.material("Warm eye ivory", "E2D3B7", .57)
    iris = p.material("Chestnut iris", "94612C", .44)
    pupil = p.material("Dark focused eyes", "1E1A22", .46)
    tea = p.material("Deep tea training canvas", "47362C", .89, 102)
    mahogany = p.material("Mahogany split jacket cloth", "734438", .88, 108)
    dyed = p.material("Ochre protective canvas", "A67548", .86, 109)
    binding = p.material("Ochre woven binding", "CA9F62", .89, 106)
    old_gold = p.material("Old-gold fittings", "B38A55", .57, metallic=.36)
    dark_wrap = p.material("Dark tea wrist wrap", "5E4135", .91, 116)

    torso, head = "Torso", "Head"
    p.loft(torso, "Low, massive gorilla trunk", (
        (1.65, 0, .16, .76, .53), (1.94, 0, .16, .90, .60),
        (2.39, 0, .14, 1.03, .68), (2.87, 0, .14, 1.13, .75),
        (3.42, 0, .145, 1.32, .79), (3.89, 0, .179, 1.39, .74),
        (4.20, 0, .198, 1.23, .666), (4.42, 0, .155, .86, .537),
        (4.54, 0, .07, .53, .40),
    ), charcoal, bevel=.049)
    p.loft(torso, "Upper chest under the open jacket", (
        (2.82, 0, -.37, .49, .255), (3.19, 0, -.397, .75, .293),
        (3.66, 0, -.405, .94, .300), (3.96, 0, -.345, .87, .257),
        (4.23, 0, -.23, .66, .221), (4.38, 0, -.19, .52, .198),
    ), dark_wrap, bevel=.035)
    p.loft(torso, "Charcoal chest fur panel", (
        (2.97, 0, -.532, .34, .164), (3.26, 0, -.542, .54, .183),
        (3.65, 0, -.541, .74, .193), (3.94, 0, -.454, .74, .167),
        (4.23, 0, -.291, .53, .195),
    ), warm_fur, bevel=.047)

    # A silver saddle follows the back and broad shoulder crown, with wider
    # silver shoulders at the upper edge and a tight, stepped waist taper.
    vertices = []
    saddle = (
        (2.53, .159, 1.066, .752, 1.08), (2.68, .150, 1.117, .774, .83),
        (3.01, .150, 1.230, .839, .58), (3.39, .150, 1.373, .870, .40),
        (3.76, .178, 1.440, .831, .26), (4.095, .196, 1.373, .769, .15),
        (4.35, .155, 1.081, .616, -.05), (4.47, .123, .771, .554, -.14),
    )
    strips = 14
    for row, (z, center_y, radius_x, radius_y, span) in enumerate(saddle):
        for column in range(strips + 1):
            angle = span + (pi - 2 * span) * column / strips
            flow = 0.055 * sin(column * 2.56 + .62 * row)
            px = (radius_x + flow * .45) * cos(angle)
            py = center_y + (radius_y + .038 + flow * .19) * sin(angle)
            vertices.append((px, py, z + flow))
    rings = strips + 1
    shell = []
    for row in range(len(saddle) - 1):
        for column in range(strips):
            at = row * rings + column
            shell.append((at, at + 1, at + rings + 1, at + rings))
    p.mesh(torso, "Silver back saddle surface", vertices, shell, silver)

    for side in (-1, 1):
        # The silver fur flows from the saddle toward the bare side of the
        # neck. Broad compact locks catch the eye in the front silhouette.
        for index, (x, y, z, tip_x, tip_y, tip_z, width, tint) in enumerate((
            (.565, -.040, 4.38, .80, -.198, 4.06, .165, silver_shade),
            (.735, .00, 4.29, .934, -.269, 3.959, .177, silver),
            (.928, .079, 4.235, 1.156, -.212, 3.913, .176, silver_tip),
            (1.088, .155, 4.12, 1.24, -.120, 3.824, .163, silver),
            (1.238, .214, 3.985, 1.391, -.010, 3.714, .151, silver_shade),
        )):
            middle = (side * (.44 * x + .56 * tip_x), .49 * y + .51 * tip_y - .037,
                      .63 * z + .37 * tip_z)
            p.tube(torso, f"Silver shoulder ruff lock {side}/{index}", (
                (side * x, y, z), middle, (side * tip_x, tip_y, tip_z),
            ), (width, width * .98, width * .19), tint, sides=6, aspect=.78)

    p.plate(torso, "Left fold of mahogany wrap jacket", (
        (-1.035, -.464, 2.289), (-.603, -.661, 2.271), (.137, -.730, 2.662),
        (-.049, -.737, 3.042), (-.304, -.743, 3.32), (-.599, -.624, 3.796),
        (-.733, -.478, 4.022), (-.973, -.375, 4.003), (-1.302, -.260, 3.537),
        (-1.203, -.299, 2.907),
    ), mahogany, thickness=.085, bevel=.043)
    p.plate(torso, "Right shadow-colored wrap panel", (
        (.146, -.730, 2.297), (.881, -.449, 2.285), (1.164, -.326, 2.75),
        (1.312, -.237, 3.423), (1.062, -.369, 3.854), (.788, -.548, 3.951),
        (.624, -.659, 3.577), (.366, -.714, 3.155), (.13, -.782, 2.729),
    ), tea, thickness=.076, bevel=.038)
    p.tube(torso, "Continuous ochre edging around open jacket", (
        (-.766, -.495, 3.98), (-.568, -.667, 3.675), (-.28, -.794, 3.23),
        (.01, -.802, 2.859), (.12, -.777, 2.638),
    ), (.052, .056, .055, .051, .040), binding, sides=8, aspect=.78)
    p.tube(torso, "Secondary vest edge with dark fold", (
        (.780, -.569, 3.929), (.58, -.711, 3.58), (.334, -.762, 3.155),
        (.292, -.774, 2.929),
    ), (.032, .047, .046, .036), dyed, sides=7, aspect=.78)
    p.tube(torso, "Plain ochre shoulders tie across the saddle", (
        (-.64, .778, 3.99), (-.486, .908, 3.72), (-.12, .955, 3.427),
        (.26, .915, 3.15), (.68, .751, 2.871),
    ), (.076, .079, .086, .073, .061), mahogany, sides=8, aspect=1.13)

    p.loft(torso, "Wide ochre training sash", (
        (1.98, 0, .14, .934, .636), (2.036, 0, .114, 1.02, .702),
        (2.204, 0, .116, 1.065, .731), (2.273, 0, .125, 1.014, .695),
    ), dyed, bevel=.017)
    for height, start, end in ((2.066, -.443, .21), (2.133, -.878, .85), (2.198, -.84, .82)):
        p.tube(torso, "Raised folds in the ochre sash", (
            (start, -.429, height), (-.34, -.617, height + .024),
            (.02, -.644, height + .028), (.39, -.615, height + .009), (end, -.433, height - .012),
        ), (.017, .023, .026, .021, .015), binding, sides=6)
    p.rounded_box(torso, "Off-center quilted sash knot", (-.404, -.671, 2.145),
                  (.337, .191, .257), mahogany, bevel=.054, rotation=(0, .26, -.14))
    for side in (-1, 1):
        x = side * .485
        p.plate(torso, "Separate split cloth sparring flap", (
            (x - .31, -.507, 1.995), (x - .27, -.593, 1.613),
            (x - .02, -.656, 1.337 + .13 * (side < 0)), (x + .233, -.556, 1.489),
            (x + .332, -.428, 1.786), (x + .28, -.439, 2.049),
        ), mahogany if side > 0 else tea, thickness=.060, bevel=.027)
        p.tube(torso, "Subtle gilt cloth edging", (
            (x - .248, -.632, 1.630), (x - .016, -.690, 1.371 + .13 * (side < 0)),
            (x + .196, -.595, 1.521),
        ), (.021, .031, .022), dyed, sides=6)

    # A wide, flattened gorilla head nests low in the shoulders. The muzzle
    # and rounded ears carry the species silhouette without helmet pieces.
    p.loft(head, "Flat-topped broad gorilla skull", (
        (4.065, 0, -.188, .481, .405), (4.28, 0, -.256, .655, .512),
        (4.609, 0, -.303, .738, .572), (4.939, 0, -.277, .712, .584),
        (5.189, 0, -.217, .667, .526), (5.427, 0, -.199, .543, .441),
        (5.578, 0, -.156, .377, .312), (5.621, 0, -.145, .212, .199),
    ), charcoal, bevel=.019)
    p.loft(head, "Dark flattened face and chin", (
        (4.155, 0, -.504, .318, .275), (4.258, 0, -.588, .464, .349),
        (4.513, 0, -.611, .552, .390), (4.759, 0, -.579, .572, .334),
        (4.953, 0, -.473, .55, .407), (5.146, 0, -.444, .440, .398),
        (5.246, 0, -.395, .321, .349),
    ), face, bevel=.019)
    p.loft(head, "Broad snub gorilla nose", (
        (4.505, 0, -.843, .268, .170), (4.584, 0, -.883, .323, .222),
        (4.686, 0, -.863, .304, .224), (4.797, 0, -.783, .214, .164),
    ), nose, bevel=.019)
    p.tube(head, "Closed, quietly confident mouth", (
        (-.405, -.893, 4.419), (-.29, -.984, 4.358), (-.15, -1.004, 4.342),
        (0, -1.006, 4.336), (.142, -1.003, 4.343), (.30, -.979, 4.363),
        (.416, -.885, 4.412),
    ), (.014, .023, .027, .028, .027, .022, .013), deep, sides=7)

    def eye_plate(side, name, outline, pigment, depth, bevel=.007):
        vertices = [(side * (.354 + .936 * u + .350 * depth), -.938 + .35 * u - depth * .936, 4.894 + v)
                    for u, v in outline]
        p.plate(head, name, vertices if side > 0 else vertices[::-1], pigment, thickness=.023, bevel=bevel)

    for side in (-1, 1):
        p.ellipse(head, "Compact round gorilla ear", (side * .692, -.290, 4.838), (.188, .139, .241), shadow_fur)
        p.ellipse(head, "Muted inner ear", (side * .788, -.392, 4.844), (.079, .060, .139), ear_inner)
        p.ellipse(head, "Wide-set dark gorilla nostril", (side * .170, -1.086, 4.603), (.103, .032, .055), deep)
        p.tube(head, "Heavy upper brow sweep", (
            (side * .157, -.859, 4.975), (side * .278, -.932, 5.036),
            (side * .408, -.909, 5.053), (side * .557, -.831, 4.997),
            (side * .626, -.733, 4.965),
        ), (.058, .086, .095, .086, .052), shadow_fur, sides=8)
        eye_plate(side, "Sculpted dark eye rim", (
            (-.152, -.038), (-.088, -.098), (.035, -.101), (.145, -.048),
            (.166, .016), (.057, .073), (-.083, .061),
        ), shadow_fur, .00)
        eye_plate(side, "Warm, alert gorilla eye", (
            (-.122, -.034), (-.067, -.073), (.031, -.075), (.121, -.043),
            (.137, .012), (.044, .041), (-.063, .036),
        ), cream, .018)
        for name, u, v, radius, material, depth in (
            ("Chestnut iris", -.019, -.019, .056, iris, .033),
            ("Focused pupil", -.023, -.019, .031, pupil, .047),
            ("Restrained catchlight", -.039, .006, .013, cream, .061),
        ):
            eye_plate(side, name, [(u + radius * cos(i * pi / 4), v + 1.08 * radius * sin(i * pi / 4))
                                    for i in range(8)], material, depth, bevel=0)
        for t, (x, y, z, outside, finish, color) in enumerate((
            (.566, -.330, 4.881, .723, 4.534, charcoal), (.611, -.220, 4.693, .732, 4.358, warm_fur),
            (.563, -.278, 4.537, .647, 4.245, shadow_fur),
        )):
            p.tube(head, f"Viewed sideburn lock {side}/{t}", (
                (side * x, y, z), (side * (x + .11), y - .017, z - .087),
                (side * outside, y - .045, finish),
            ), (.124, .131, .025), color, sides=7, aspect=.73)

    pivots = {torso: (0, .10, 2.50), head: (0, -.26, 4.25)}
    for side, label, fist_x, fist_y, fist_z, foot_y in (
        (1, "Right", 1.535, -1.078, 2.713, -.23),
        (-1, "Left", -1.714, -.785, 2.225, .125),
    ):
        arm, leg = f"{label} Arm", f"{label} Leg"
        pivots[arm] = (side * 1.211, .116, 3.818)
        pivots[leg] = (side * .567, .168, 1.807)
        p.loft(arm, "Long, stocky upper arm", (
            (2.363, side * 1.711, .04, .299, .329), (2.620, side * 1.652, .135, .453, .389),
            (3.106, side * 1.553, .153, .520, .466), (3.617, side * 1.458, .164, .551, .502),
            (3.969, side * 1.283, .184, .505, .472), (4.14, side * 1.204, .189, .341, .308),
        ), charcoal, bevel=.044)
        p.tube(arm, "Massive long bent gorilla forearm", (
            (side * 1.711, .102, 2.696), (side * 1.748, -.234, (2.573 + fist_z) / 2),
            (fist_x + .106 * side, fist_y + .337, fist_z - .104),
            (fist_x + .020 * side, fist_y + .078, fist_z - .041),
        ), (.398, .447, .402, .323), warm_fur, sides=10, aspect=.97)
        p.tube(arm, "Broad cloth hand guard", (
            (fist_x + .095 * side, fist_y + .38, fist_z - .11),
            (fist_x + .052 * side, fist_y + .247, fist_z - .077),
            (fist_x + .019 * side, fist_y + .139, fist_z - .046),
        ), (.406, .421, .358), dark_wrap if side > 0 else dyed, sides=10, aspect=1.08)
        for index, (offset, radius) in enumerate(((.15, .370), (.28, .418), (.365, .423))):
            x = fist_x + .10 * side * (offset / .365)
            path = ((x, fist_y + offset - .025, fist_z - .057 * (offset / .30)),
                    (x + .013 * side, fist_y + offset + .025, fist_z - .073 * (offset / .30)))
            dye = mahogany if side > 0 and index != 1 else binding if side < 0 else dyed
            p.tube(arm, "Raised wrist wrap seam", path, (radius, radius - .006), dye, sides=10, aspect=1.07)
        if side > 0:
            p.rounded_box(arm, "Dull brass locking patch on right wrist", (fist_x - .063, fist_y + .268, fist_z + .334),
                          (.282, .212, .116), old_gold, bevel=.022, rotation=(.23, -.18, .12))
        p.ellipse(arm, "Large gorilla palm", (fist_x, fist_y, fist_z), (.430, .306, .333), bare_hand)
        for digit in (-1, 0, 1):
            p.rounded_box(arm, "Large blunt gorilla knuckle", (fist_x + digit * .195, fist_y - .219,
                          fist_z + .035 + .042 * (digit == 0)), (.211, .179, .271), bare_hand, bevel=.041)
        p.ellipse(arm, "Inward closed thumb", (fist_x - side * .306, fist_y - .084, fist_z - .125), (.175, .207, .188), face)
        for offset, tint in ((-.04, charcoal), (.25, silver_shade if side < 0 else charcoal)):
            p.tube(arm, "Overlapping shoulder fur edge", (
                (side * 1.40, .224 + offset, 3.95), (side * 1.708, .219 + offset, 3.814),
                (side * 1.858, .172 + offset, 3.55),
            ), (.152, .163, .042), tint, sides=7, aspect=.78)

        p.loft(leg, "Short, planted heavy leg", (
            (.27, side * .745, foot_y + .036, .429, .402), (.508, side * .729, foot_y + .062, .463, .423),
            (.916, side * .696, foot_y + .11, .470, .454), (1.344, side * .631, foot_y + .132, .531, .492),
            (1.791, side * .565, .132, .521, .471), (1.994, side * .524, .17, .405, .36),
        ), tea, bevel=.053)
        p.loft(leg, "Bare weight-bearing gorilla foot", (
            (0, side * .745, foot_y - .11, .470, .478), (.112, side * .746, foot_y - .145, .511, .548),
            (.264, side * .745, foot_y - .130, .486, .524), (.408, side * .737, foot_y - .039, .407, .427),
        ), bare_hand, bevel=.048)
        for digit in (-1, 0, 1):
            toe_x = side * .744 + digit * .262
            toe_y = foot_y - .644 + abs(digit) * .05
            p.rounded_box(leg, "Blunt toe pad", (toe_x, toe_y, .131), (.233, .202, .191), face, bevel=.037)
    return pivots
