"""Original Granite Rhino geometry for the standalone sparring lineup."""

from math import cos, pi, sin


def build(p):
    granite = p.material("Granite hide", "535B68", .85)
    hide_plane = p.material("Weathered slate hide", "697581", .85)
    dark_hide = p.material("Slate folds", "3D4551", .90)
    clay = p.material("Russet hide folds", "74554F", .86)
    crease = p.material("Deep facial creases", "2B2932", .95)
    ivory = p.material("Warm ivory horn", "C9B592", .62, grain=76)
    horn_root = p.material("Weathered horn root", "887B6D", .75, grain=68)
    eye_white = p.material("Warm eye white", "EDE1C6", .58)
    amber = p.material("Amber iris", "CB913A", .34)
    pupil = p.material("Dark eye and nostril", "1A1D24", .65)
    canvas = p.material("Ink-blue vest canvas", "303D56", .85, grain=96)
    blue = p.material("Indigo armor enamel", "415B83", .54, grain=81, metallic=.12)
    cobalt = p.material("Worn blue armor edges", "5A7293", .66, metallic=.10)
    steel = p.material("Forged steel trim", "89989B", .55, metallic=.44)
    brass = p.material("Aged brass hardware", "B48A56", .58, metallic=.42)
    leather = p.material("Oxide-red leather binding", "754743", .79, grain=100)
    wrap = p.material("Russet wrist and waist wraps", "975D50", .88, grain=108)
    linen = p.material("Indigo underwrap", "27354A", .90, grain=104)

    torso, head = "Torso", "Head"
    p.loft(torso, "Low, wide jacket silhouette", (
        (1.71, .00, .10, .72, .49), (1.94, .00, .10, .89, .56),
        (2.28, .00, .10, 1.00, .60), (2.81, .00, .10, 1.10, .68),
        (3.39, .00, .13, 1.24, .70), (3.82, .00, .15, 1.12, .62),
        (4.03, .00, .13, .81, .48),
    ), canvas, bevel=.055)
    p.loft(torso, "Neck and shoulder mantle", (
        (3.64, .00, .14, 1.09, .58), (3.89, .00, .11, 1.13, .57),
        (4.10, .00, .10, .92, .52), (4.25, .00, .06, .57, .44),
        (4.39, .00, .02, .47, .38),
    ), granite, bevel=.065)

    p.plate(torso, "Crossed indigo chest facing", (
        (-.83, -.55, 2.91), (.79, -.55, 2.91), (1.03, -.54, 3.38),
        (.79, -.48, 3.76), (.43, -.55, 3.80), (-.15, -.61, 3.33),
        (-.57, -.53, 3.77), (-.91, -.48, 3.69), (-1.07, -.51, 3.43),
    ), blue, thickness=.084, bevel=.026)
    p.plate(torso, "Overlapping rust-color lapel binding", (
        (-.74, -.55, 3.70), (-.55, -.59, 3.77), (-.17, -.67, 3.34),
        (.42, -.66, 3.05), (.34, -.65, 2.91), (-.19, -.66, 3.17),
    )[::-1], leather, thickness=.050, bevel=.016)
    p.tube(torso, "Blue quilted edge beside chest binding", (
        (-.48, -.60, 3.65), (-.14, -.68, 3.29), (.35, -.69, 3.03),
    ), (.043, .049, .035), cobalt, sides=7)
    p.plate(torso, "Hammered chest panel on right side", (
        (.24, -.67, 3.14), (.70, -.60, 3.13), (.88, -.59, 3.38),
        (.73, -.57, 3.59), (.43, -.61, 3.55),
    ), steel, thickness=.062, bevel=.026)
    p.plate(torso, "Inset enamel chest panel", (
        (.34, -.735, 3.23), (.66, -.667, 3.22), (.79, -.665, 3.39),
        (.69, -.645, 3.51), (.49, -.685, 3.47),
    ), blue, thickness=.024)
    for band, height in enumerate((2.36, 2.55, 2.74)):
        half_width = .72 + .045 * band
        p.plate(torso, f"Quilted lower vest tier {band + 1}", (
            (-half_width, -.43, height - .105), (0, -.587, height - .128),
            (half_width, -.43, height - .105), (half_width + .055, -.48, height + .045),
            (half_width - .08, -.52, height + .090), (0, -.623, height + .074),
            (-half_width + .08, -.52, height + .090), (-half_width - .055, -.48, height + .045),
        ), blue if band % 2 == 0 else linen, thickness=.066, bevel=.019)
    p.loft(torso, "Wide oxide-red waist wrap", (
        (1.94, .00, .10, .88, .58), (2.00, .00, .10, .98, .61),
        (2.19, .00, .10, 1.035, .64), (2.27, .00, .10, 1.005, .61),
    ), leather, bevel=0)
    for band, height in enumerate((2.025, 2.118, 2.207)):
        p.tube(torso, f"Waist wrap raised stitching {band + 1}", (
            (-.80, -.36, height), (-.40, -.535, height + .012),
            (.03, -.564, height + .021), (.44, -.534, height), (.83, -.36, height - .017),
        ), (.027, .032, .035, .032, .025), wrap, sides=6)
    p.rounded_box(torso, "Hammered bronze belt clasp", (.24, -.568, 2.12), (.35, .15, .24), brass, bevel=.041)
    p.rounded_box(torso, "Slate clasp inset", (.24, -.651, 2.12), (.21, .037, .13), dark_hide, bevel=.024)
    p.plate(torso, "Short split waist flap", (
        (-.32, -.505, 1.45), (.06, -.548, 1.50), (.26, -.557, 1.94),
        (-.37, -.53, 2.01), (-.54, -.475, 1.66),
    ), blue, thickness=.094, bevel=.026)
    p.tube(torso, "Blue waist flap edge", (
        (-.49, -.542, 1.72), (-.31, -.595, 1.48), (.04, -.64, 1.53),
    ), (.030, .035, .029), cobalt, sides=6)

    p.loft(head, "Broad rhino skull", (
        (4.03, .00, -.10, .46, .38), (4.17, .00, -.15, .60, .51),
        (4.43, .00, -.17, .71, .60), (4.72, .00, -.15, .741, .61),
        (4.98, .00, -.115, .68, .57), (5.18, .00, -.07, .52, .45),
        (5.29, .00, -.02, .36, .31),
    ), granite, bevel=.019)
    p.loft(head, "Broad lower jaw", (
        (3.97, .00, -.52, .40, .31), (4.07, .00, -.59, .58, .44),
        (4.23, .00, -.65, .67, .465), (4.34, .00, -.67, .61, .42),
    ), dark_hide, bevel=.019)
    p.loft(head, "Squared forward muzzle", (
        (4.22, .00, -.66, .59, .45), (4.32, .00, -.72, .715, .49),
        (4.47, .00, -.77, .72, .49), (4.62, .00, -.73, .59, .43),
        (4.75, .00, -.65, .38, .34),
    ), hide_plane, bevel=.019)
    p.tube(head, "Short recessed mouth", (
        (-.55, -1.031, 4.24), (-.41, -1.125, 4.27), (-.19, -1.168, 4.25),
        (0, -1.174, 4.254), (.21, -1.16, 4.253), (.44, -1.117, 4.27),
        (.55, -1.02, 4.23),
    ), (.022, .030, .027, .025, .028, .031, .019), crease, sides=7)
    p.tube(head, "Blunt slate base of main horn", (
        (0, -.924, 4.58), (0, -.981, 4.707), (0, -.986, 4.76),
    ), (.285, .262, .221), horn_root, sides=10, aspect=1.10)
    p.tube(head, "Single broad ivory horn", (
        (0, -.989, 4.71), (0, -1.04, 4.81), (.00, -1.068, 4.94),
        (-.009, -1.052, 5.07), (-.025, -1.014, 5.205), (-.032, -.998, 5.247),
    ), (.234, .212, .174, .124, .060, .026), ivory, sides=11, aspect=1.08)
    p.tube(head, "Small rear horn stub", (
        (.00, -.464, 5.02), (.00, -.47, 5.104), (.00, -.455, 5.24), (.01, -.428, 5.294),
    ), (.140, .133, .077, .036), horn_root, sides=9)

    def eye_shape(side, name, outline, material, outset, thickness, bevel=.008):
        vertices = [(side * (.525 + .894 * u + .448 * outset),
                     -.678 + .448 * u - .894 * outset, 4.852 + v) for u, v in outline]
        p.plate(head, name, vertices if side > 0 else vertices[::-1], material,
                thickness=thickness, bevel=bevel)

    for side in (-1, 1):
        p.loft(head, "Tapered rhino ear", (
            (5.028, side * .432, .080, .12, .10), (5.195, side * .518, .114, .185, .131),
            (5.39, side * .610, .152, .159, .103), (5.51, side * .646, .172, .090, .061),
            (5.555, side * .627, .176, .028, .025),
        ), granite, bevel=.019)
        ear = [(side * x, y, z) for x, y, z in (
            (.439, -.026, 5.151), (.620, -.007, 5.194), (.692, .048, 5.376),
            (.634, .098, 5.469), (.538, .041, 5.375),
        )]
        p.plate(head, "Russet ear inset", ear if side > 0 else ear[::-1], clay, thickness=.040, bevel=.013)
        p.ellipse(head, "Cheek armor of natural slate hide", (side * .61, -.433, 4.376), (.183, .413, .275), granite)
        p.tube(head, "Warm folded cheek undercut", (
            (side * .692, -.754, 4.52), (side * .748, -.599, 4.45),
            (side * .747, -.451, 4.345), (side * .70, -.392, 4.31),
        ), (.017, .032, .032, .016), clay, sides=7)
        p.ellipse(head, "Rhino nostril shadow", (side * .294, -1.243, 4.491), (.126, .028, .074), crease)
        p.ellipse(head, "Rhino nostril opening", (side * .297, -1.265, 4.493), (.100, .019, .050), pupil)
        eye_shape(side, "Recessed almond eye socket", (
            (-.176, -.053), (-.059, -.118), (.083, -.101), (.177, -.047),
            (.206, .075), (.086, .123), (-.063, .068),
        ), crease, .0, .05)
        eye_shape(side, "Cream eye", (
            (-.144, -.041), (-.045, -.083), (.066, -.066), (.153, -.020),
            (.165, .047), (.068, .082), (-.042, .035),
        ), eye_white, .032, .024)
        for name, u, v, radius, material, outset in (
            ("Amber iris", -.023, -.010, .065, amber, .051),
            ("Focused pupil", -.030, -.011, .037, pupil, .065),
            ("Small eye catchlight", -.048, .014, .016, eye_white, .078),
        ):
            eye_shape(side, name, [(u + radius * cos(i * pi / 4), v + radius * sin(i * pi / 4) * 1.07)
                                    for i in range(8)], material, outset, .013, bevel=0)
        p.tube(head, "Heavy raised rhino brow", (
            (side * .310, -.658, 4.90), (side * .460, -.711, 4.966),
            (side * .607, -.635, 5.034), (side * .743, -.504, 5.014),
        ), (.067, .101, .116, .067), granite, sides=9)
        p.tube(head, "Brow ridge glancing edge", (
            (side * .392, -.704, 4.995), (side * .539, -.677, 5.083), (side * .679, -.565, 5.092),
        ), (.022, .047, .024), hide_plane, sides=7)

    pivots = {torso: (0, 0, 2.57), head: (0, -.06, 4.21)}
    for side, label, hand_y, hand_z, foot_y in (
        (1, "Right", -.934, 3.25, -.15), (-1, "Left", -.744, 3.08, .17),
    ):
        arm, leg = f"{label} Arm", f"{label} Leg"
        pivots[arm] = (side * 1.10, .10, 3.59)
        pivots[leg] = (side * .55, .063, 1.86)
        hand_x = side * 1.575
        p.loft(arm, "Thick shoulder and lowered elbow", (
            (2.37, side * 1.53, -.205, .33, .30), (2.61, side * 1.55, -.077, .43, .39),
            (3.10, side * 1.48, .089, .465, .448), (3.54, side * 1.36, .105, .514, .477),
            (3.82, side * 1.26, .093, .447, .398), (3.96, side * 1.22, .090, .308, .302),
        ), granite, bevel=.061)
        p.tube(arm, "Thick bent forearm behind raised fist", (
            (side * 1.58, -.28, 2.59), (side * 1.64, hand_y + .39, hand_z - .31),
            (hand_x, hand_y + .12, hand_z - .12),
        ), (.362, .357, .300), hide_plane, sides=10)
        p.tube(arm, "Protective indigo wrist and forearm binding", (
            (side * 1.64, hand_y + .45, hand_z - .36), (side * 1.61, hand_y + .32, hand_z - .27),
            (hand_x, hand_y + .18, hand_z - .15),
        ), (.367, .389, .320), blue if side > 0 else leather, sides=10)
        p.tube(arm, "Wrist binding ridge", (
            (side * 1.60, hand_y + .255, hand_z - .21), (side * 1.585, hand_y + .195, hand_z - .16),
        ), (.367, .354), steel if side > 0 else wrap, sides=10)
        p.ellipse(arm, "Blunt rhino fist", (hand_x, hand_y, hand_z), (.387, .329, .342), granite)
        for finger in (-1, 0, 1):
            p.rounded_box(arm, "Wrapped blunt knuckle", (hand_x + finger * .184, hand_y - .241,
                          hand_z + .078 + (1 - abs(finger)) * .051), (.184, .162, .230),
                          hide_plane, bevel=.052)
        p.ellipse(arm, "Tucked thumb", (hand_x - side * .240, hand_y - .096, hand_z - .133), (.183, .189, .189), dark_hide)
        if side > 0:
            p.loft(arm, "Heavy single forged pauldron", (
                (3.32, 1.52, .13, .426, .487), (3.53, 1.50, .105, .579, .578),
                (3.81, 1.46, .097, .583, .589), (4.095, 1.393, .109, .467, .486),
                (4.225, 1.274, .102, .27, .32),
            ), blue, bevel=.064)
            p.plate(arm, "Pauldron face steel border", (
                (1.059, -.420, 3.53), (1.760, -.381, 3.49), (1.968, -.292, 3.64),
                (1.898, -.306, 3.846), (1.603, -.390, 4.091), (1.297, -.412, 4.136),
                (.985, -.350, 3.884),
            ), steel, thickness=.096, bevel=.035)
            p.plate(arm, "Pauldron blue enamel inset", (
                (1.172, -.519, 3.63), (1.702, -.483, 3.59), (1.849, -.384, 3.704),
                (1.790, -.418, 3.82), (1.560, -.484, 4.00), (1.320, -.515, 4.037),
                (1.103, -.462, 3.854),
            ), blue, thickness=.059, bevel=.030)
            p.tube(arm, "Bronze riveted pauldron strike", (
                (1.278, -.566, 3.758), (1.428, -.569, 3.920), (1.576, -.523, 3.853),
            ), (.023, .039, .030), brass, sides=7)
            for x, y, z in ((1.204, -.458, 3.59), (1.724, -.424, 3.54), (1.756, -.412, 3.908)):
                p.rounded_box(arm, "Small flat brass shoulder rivet", (x, y, z), (.086, .044, .085), brass, bevel=.023)
        else:
            p.tube(arm, "Single soft cloth shoulder tie", (
                (-1.635, -.284, 3.597), (-1.516, -.374, 3.766), (-1.283, -.355, 3.965),
                (-1.128, -.236, 4.053),
            ), (.084, .101, .114, .064), leather, sides=8)

        p.loft(leg, "Sturdy wide-set leg", (
            (.27, side * .69, foot_y + .05, .445, .391), (.59, side * .685, foot_y + .054, .450, .400),
            (1.01, side * .666, foot_y + .087, .434, .433), (1.44, side * .615, foot_y + .090, .505, .449),
            (1.87, side * .543, .101, .467, .428), (2.016, side * .50, .117, .340, .323),
        ), canvas, bevel=.059)
        p.ellipse(leg, "Rounded reinforced kneecap", (side * .679, foot_y - .315, .966), (.354, .108, .285), blue)
        p.plate(leg, "Rounded knee panel light edge", (
            (side * .677 - .225, foot_y - .408, .941), (side * .677, foot_y - .446, .819),
            (side * .677 + .225, foot_y - .408, .941), (side * .677 + .192, foot_y - .408, 1.126),
            (side * .677, foot_y - .445, 1.170), (side * .677 - .192, foot_y - .408, 1.126),
        ), cobalt, thickness=.035, bevel=.012)
        p.loft(leg, "Oxide red ankle binding", (
            (.392, side * .692, foot_y + .009, .479, .418),
            (.489, side * .688, foot_y + .021, .477, .418),
            (.546, side * .687, foot_y + .033, .447, .399),
        ), leather, bevel=0)
        p.loft(leg, "Weight-bearing three-toed foot", (
            (0, side * .690, foot_y - .115, .465, .509),
            (.102, side * .693, foot_y - .137, .498, .538),
            (.26, side * .692, foot_y - .127, .493, .531),
            (.423, side * .692, foot_y - .057, .422, .432),
        ), granite, bevel=.059)
        for toe in (-1, 0, 1):
            p.rounded_box(leg, "Rounded slate toenail", (side * .690 + toe * .261,
                          foot_y - .600 + abs(toe) * .06, .130), (.208, .143, .174),
                          horn_root, bevel=.038)

    tail = "Tail"
    pivots[tail] = (0, .552, 1.82)
    p.tube(tail, "Small curved rhino tail", (
        (0, .532, 1.825), (.022, .722, 1.651), (.050, .83, 1.396), (.030, .942, 1.205),
    ), (.106, .092, .069, .043), dark_hide, sides=8)
    p.loft(tail, "Small dark tail tuft", (
        (1.103, .028, .935, .037, .029), (1.185, .035, .927, .094, .059),
        (1.269, .033, .907, .077, .049),
    ), crease, bevel=0)
    return pivots
