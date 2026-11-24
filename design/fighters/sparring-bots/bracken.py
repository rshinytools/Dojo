"""Bracken Boar, an original orchard bruiser in patched festival armor."""


def build(p):
    skin = p.material("Bracken | burnt umber hide", "8F5240", .84, grain=82)
    light_hide = p.material("Bracken | warm cheek hide", "AA6550", .82, grain=78)
    shadow_hide = p.material("Bracken | shaded hide", "623A34", .87)
    muzzle = p.material("Bracken | dusty rose muzzle", "CB8167", .78)
    nose = p.material("Bracken | plum snout cap", "A9574E", .65)
    inner_ear = p.material("Bracken | flushed inner ear", "9D574D", .87)
    nostril = p.material("Bracken | nostril and lip shadow", "42232B", .85)
    mane = p.material("Bracken | charcoal-umber bristles", "362629", .89)
    bristle_rim = p.material("Bracken | toasted bristle ridges", "61392F", .88)
    ivory = p.material("Bracken | worn tusk ivory", "F0DAB2", .55)
    iris = p.material("Bracken | honey iris", "E6AD57", .45)
    sclera = p.material("Bracken | eye ivory", "F6DEB7", .49)
    pupil = p.material("Bracken | dark eye", "2C2027", .52)

    lining = p.material("Bracken | charcoal quilted canvas", "4B3031", .9, grain=117)
    leather = p.material("Bracken | weathered russet hide armor", "764738", .84, grain=86)
    dark_red = p.material("Bracken | oxblood armoring", "702D32", .8, grain=95)
    red = p.material("Bracken | paprika-red fabric", "AD4438", .84, grain=109)
    red_fold = p.material("Bracken | shaded red wrap", "86322F", .88, grain=109)
    brass = p.material("Bracken | antique hammered brass", "A97640", .52, grain=92, metallic=.46)
    warm_brass = p.material("Bracken | burnished brass edge", "D0A35D", .45, metallic=.53)
    thread = p.material("Bracken | flax cord", "C99468", .86)
    hoof = p.material("Bracken | smoke horn", "453032", .7)

    def front_plate(group, name, side, outline, material, thickness=.045, bevel=.014):
        points = [(side * x, y, z) for x, y, z in outline]
        p.plate(group, name, points if side == 1 else list(reversed(points)), material, thickness, bevel)

    p.loft("Torso", "Barrel chest and heavy neck", [
        (1.53, 0, .06, .50, .36),
        (1.74, 0, .06, .71, .47),
        (2.04, 0, .04, .84, .53),
        (2.48, 0, .05, .94, .59),
        (2.90, 0, .08, 1.03, .56),
        (3.20, 0, .09, 1.06, .52),
        (3.36, 0, .10, .81, .46),
        (3.57, 0, .03, .55, .39),
        (3.66, 0, -.01, .40, .29),
    ], skin, .026)
    p.loft("Torso", "Fitted quilted body armor", [
        (1.65, 0, .06, .66, .47),
        (1.98, 0, .055, .86, .58),
        (2.42, 0, .06, .965, .61),
        (2.88, 0, .08, 1.045, .58),
        (3.19, 0, .09, 1.045, .54),
        (3.34, 0, .105, .75, .46),
    ], lining, .034)
    p.loft("Torso", "Crossed cloth waist sash", [
        (1.71, 0, .055, .72, .49),
        (1.79, 0, .055, .79, .53),
        (1.99, 0, .06, .88, .58),
        (2.11, 0, .06, .88, .57),
    ], red, .024)
    p.loft("Torso", "Lower red sash fold", [
        (1.76, 0, .055, .75, .52),
        (1.81, 0, .06, .80, .55),
        (1.90, 0, .065, .84, .575),
    ], red_fold, .016)
    p.loft("Torso", "Waist binding band", [
        (1.92, 0, .06, .84, .579),
        (1.97, 0, .06, .87, .601),
        (2.035, 0, .06, .89, .591),
    ], dark_red, .016)

    # Each breast plate has a closed, contoured face and a tucked back.
    # The lower lip of each higher plate covers the plate beneath it.
    for index, (half, bottom, top, depth, tint) in enumerate((
        (.77, 2.10, 2.44, -.649, dark_red),
        (.84, 2.36, 2.75, -.685, leather),
        (.88, 2.65, 3.13, -.720, red_fold),
    ), 1):
        across = (-1, -.66, 0, .66, 1)
        front = [(half * u, depth - .030 + .104 * u * u, bottom + .076 * u * u) for u in across]
        front += [(half * .976 * u, depth + .016 + .092 * u * u, top - .037 * u * u) for u in across]
        rear = [(x, y + .23, z) for x, y, z in front]
        faces = []
        for left in range(4):
            right = left + 1
            faces.extend((
                (left, right, right + 5, left + 5),
                (left + 15, right + 15, right + 10, left + 10),
                (left + 10, right + 10, right, left),
                (left + 5, right + 5, right + 15, left + 15),
            ))
        faces.extend(((0, 5, 15, 10), (14, 19, 9, 4)))
        p.mesh("Torso", f"Overlapping chest plate {index}", front + rear, faces, tint, bevel=.012)
        for side in (-1, 1):
            p.rounded_box("Torso", f"Chest plate {index} brass rivet {side}",
                          (side * half * .81, depth + .044, bottom + .139), (.070, .056, .075), warm_brass, .014)

    p.tube("Torso", "Bound collar seam", [
        (-.68, -.33, 3.27), (-.41, -.49, 3.31), (0, -.51, 3.24),
        (.40, -.49, 3.31), (.68, -.33, 3.27),
    ], [.044, .051, .055, .051, .044], leather, sides=7)
    p.plate("Torso", "Brass chest reed clasp", [
        (-.17, -.769, 2.875), (0, -.784, 2.815), (.17, -.769, 2.875),
        (.15, -.761, 3.02), (0, -.775, 3.087), (-.15, -.761, 3.02),
    ], brass, .055, .017)
    p.tube("Torso", "Cut inlay in chest clasp", [
        (-.064, -.781, 2.885), (0, -.794, 2.942), (.074, -.775, 3.017),
    ], [.014, .016, .010], warm_brass, sides=5)

    for side in (-1, 1):
        front_plate("Torso", "Flared hip guard", side, [
            (.16, -.544, 1.26), (.54, -.50, 1.19), (.91, -.15, 1.40),
            (.87, -.24, 1.94), (.28, -.55, 1.92), (.14, -.57, 1.54),
        ], dark_red, .086, .028)
        front_plate("Torso", "Scored hip guard inset", side, [
            (.235, -.591, 1.36), (.52, -.552, 1.30), (.81, -.27, 1.45),
            (.77, -.32, 1.83), (.287, -.605, 1.85),
        ], leather, .042, .015)
        p.tube("Torso", "Hip guard worn binding", [
            (side * .24, -.606, 1.40), (side * .52, -.564, 1.34), (side * .81, -.283, 1.49),
        ], [.022, .027, .018], brass, sides=6)
    p.plate("Torso", "Short split festival sash tab", [
        (-.15, -.615, 1.80), (-.12, -.614, 1.31), (.03, -.653, 1.18),
        (.19, -.635, 1.35), (.20, -.609, 1.82),
    ], red, .055, .016)
    p.rounded_box("Torso", "Forged sash clasp", (.01, -.595, 1.92), (.43, .16, .227), brass, .044)
    p.rounded_box("Torso", "Russet inset of sash clasp", (.01, -.689, 1.92), (.26, .036, .096), dark_red, .018)

    p.loft("Head", "Weighty boar head and jawline", [
        (3.44, 0, -.07, .36, .33),
        (3.58, 0, -.12, .59, .44),
        (3.79, 0, -.11, .76, .53),
        (4.06, 0, -.075, .83, .61),
        (4.29, 0, -.048, .79, .63),
        (4.53, 0, -.01, .70, .59),
        (4.70, 0, .03, .56, .46),
        (4.80, 0, .07, .33, .29),
    ], skin, .019)
    p.loft("Head", "Muscular neck ruff", [
        (3.57, 0, .23, .43, .36),
        (3.74, 0, .25, .59, .44),
        (4.02, 0, .29, .69, .43),
        (4.42, 0, .24, .59, .43),
        (4.73, 0, .19, .47, .33),
        (4.82, 0, .18, .28, .23),
    ], mane, .018)
    p.loft("Head", "Forward snout volume", [
        (3.59, 0, -.66, .235, .18),
        (3.70, 0, -.734, .43, .292),
        (3.85, 0, -.792, .46, .322),
        (4.01, 0, -.811, .432, .342),
        (4.16, 0, -.69, .366, .281),
        (4.22, 0, -.59, .27, .228),
    ], light_hide, .018)
    p.ellipse("Head", "Broad rose snout", (0, -1.024, 3.96), (.415, .227, .237), muzzle)
    p.rounded_box("Head", "Soft squared snout face", (0, -1.187, 3.991), (.669, .139, .323), nose, .062,
                  rotation=(.12, 0, 0))
    p.tube("Head", "Short level scowl", [
        (-.37, -.966, 3.723), (-.20, -1.076, 3.688), (0, -1.091, 3.674),
        (.24, -1.055, 3.683), (.39, -.932, 3.723),
    ], [.016, .025, .027, .021, .015], nostril, sides=7)

    for side in (-1, 1):
        p.loft("Head", "Chiseled lower cheek", [
            (3.56, side * .47, -.41, .15, .17),
            (3.67, side * .56, -.39, .23, .24),
            (3.83, side * .61, -.36, .26, .27),
            (4.03, side * .56, -.37, .21, .25),
            (4.14, side * .46, -.37, .14, .15),
        ], light_hide, .019)
        p.rounded_box("Head", "Oval nostril", (side * .151, -1.254, 4.012), (.115, .045, .087), nostril,
                      .031, rotation=(.13, 0, side * -.13))
        p.tube("Head", "Short ascending tusk", [
            (side * .355, -.953, 3.716), (side * .492, -1.031, 3.72),
            (side * .586, -1.072, 3.807), (side * .637, -1.043, 3.91),
            (side * .644, -1.004, 4.048), (side * .62, -.994, 4.115),
        ], [.116, .119, .108, .081, .040, .006], ivory, sides=9)
        p.ellipse("Head", "Deep-set eye socket", (side * .375, -.608, 4.265), (.269, .146, .172), shadow_hide)
        p.ellipse("Head", "Narrow amber eye white", (side * .371, -.705, 4.257), (.173, .079, .104), sclera)
        p.ellipse("Head", "Amber eye iris", (side * .331, -.771, 4.251), (.075, .032, .078), iris)
        p.ellipse("Head", "Reed black pupil", (side * .327, -.791, 4.244), (.034, .014, .052), pupil)
        p.tube("Head", "Furrowed overhanging eyebrow", [
            (side * .139, -.721, 4.328), (side * .284, -.756, 4.349),
            (side * .467, -.694, 4.41), (side * .633, -.585, 4.479),
        ], [.061, .090, .087, .055], mane, sides=8)
        p.tube("Head", "Angular brow plane", [
            (side * .162, -.701, 4.393), (side * .338, -.724, 4.467),
            (side * .502, -.64, 4.525),
        ], [.057, .074, .045], skin, sides=7)
        ear_tip = 5.04 if side == 1 else 5.005
        p.loft("Head", "Crooked pointed ear", [
            (4.32, side * .583, -.012, .17, .14),
            (4.48, side * .709, .007, .210, .19),
            (4.668, side * .821, .02, .191, .165),
            (4.84, side * .896, .061, .126, .111),
            (4.994, side * .962, .105, .044, .052),
            (ear_tip, side * .97, .139, .015, .019),
        ], shadow_hide, .019)
        front_plate("Head", "Warm inset of pointed ear", side, [
            (.674, -.134, 4.52), (.816, -.153, 4.549), (.930, -.058, 4.765),
            (.949, .035, 4.958), (.796, -.087, 4.768), (.705, -.125, 4.655),
        ], inner_ear, .041, .017)
        for index, (dx, y, z) in enumerate(((.64, .31, 4.37), (.69, .23, 4.13), (.66, .22, 3.94))):
            p.tube("Head", f"Temple ruff tip {index}", [
                (side * dx, y - .10, z + .10), (side * (dx + .09), y + .04, z),
                (side * (dx + .112), y + .20, z - .16),
            ], [.113, .071, .008], mane if index != 1 else bristle_rim, sides=6)

    for index, (x, y, base, tip, sweep, width) in enumerate((
        (-.26, .16, 4.64, 4.98, .39, .118),
        (.22, .145, 4.64, 5.045, .38, .125),
        (-.12, .01, 4.70, 5.085, .36, .132),
        (.095, .012, 4.70, 5.157, .42, .150),
        (-.035, .217, 4.68, 5.191, .56, .175),
        (.174, .28, 4.66, 5.09, .68, .135),
        (-.19, .31, 4.58, 4.994, .73, .121),
        (.016, .42, 4.55, 4.963, .79, .139),
    ), 1):
        p.tube("Head", f"Swept mane blade {index}", [
            (x, y - .08, base),
            (x * 1.10, y + .025, base + .15),
            (x * 1.19, (y + sweep) / 2, tip - .095),
            (x * 1.29, sweep, tip),
        ], [width, width * .98, width * .54, .006], bristle_rim if index in (3, 6) else mane, sides=7, aspect=.75)

    for side, group in ((1, "Right Arm"), (-1, "Left Arm")):
        high = .15 if side == 1 else 0
        fist_x, fist_y, fist_z = side * 1.23, -.94 - high * .60, 2.92 + high
        p.loft(group, "Heavy upper arm", [
            (2.35 + high * .4, side * 1.34, -.035, .245, .235),
            (2.52 + high * .4, side * 1.38, -.04, .348, .305),
            (2.78 + high * .3, side * 1.36, .015, .409, .346),
            (3.06, side * 1.23, .055, .434, .365),
            (3.31, side * 1.07, .07, .371, .31),
            (3.44, side * .98, .095, .216, .215),
        ], skin, .029)
        p.tube(group, "Bent thick forearm", [
            (side * 1.394, -.045, 2.56 + high * .43), (side * 1.398, -.347, 2.59 + high * .48),
            (side * 1.329, -.639, 2.74 + high * .80), (fist_x, fist_y + .134, fist_z),
        ], [.269, .348, .334, .247], light_hide, sides=11, aspect=.89)
        p.loft(group, "Tapered padded shoulder guard", [
            (2.96, side * 1.26, .069, .408, .391),
            (3.19, side * 1.24, .043, .462, .420),
            (3.40, side * 1.12, .069, .411, .371),
            (3.52, side * 1.01, .089, .25, .261),
        ], dark_red if side == 1 else lining, .027)
        front_plate(group, "Shaped shoulder stud plate", side, [
            (.877, -.274, 3.30), (.955, -.34, 3.079), (1.32, -.37, 2.972),
            (1.59, -.244, 3.075), (1.616, -.214, 3.293), (1.412, -.282, 3.451),
            (1.12, -.306, 3.457),
        ], leather if side == -1 else red, .078, .026)
        p.tube(group, "Worn lower shoulder piping", [
            (side * .941, -.379, 3.103), (side * 1.306, -.414, 2.985), (side * 1.604, -.273, 3.114),
        ], [.031, .040, .027], brass, sides=6)
        for x, y, z in ((1.083, -.375, 3.265), (1.432, -.368, 3.198)):
            p.rounded_box(group, "Shoulder bronze eyelet", (side * x, y, z), (.078, .054, .083), warm_brass, .015)

        p.tube(group, "Tapered oxblood wrist binding", [
            (side * 1.376, fist_y + .51, 2.57 + high * .66),
            (side * 1.337, fist_y + .383, 2.69 + high * .83),
            (side * 1.294, fist_y + .254, 2.786 + high),
            (side * 1.265, fist_y + .158, 2.843 + high),
        ], [.338, .373, .374, .356], dark_red, sides=11, aspect=.94)
        for index, (x, depth, z) in enumerate(((1.359, .388, 2.70), (1.288, .240, 2.80))):
            p.tube(group, f"Raised wrist binding seam {index}", [
                (side * (x - .005), fist_y + depth - .04, z + high + .022),
                (side * x, fist_y + depth, z + high),
                (side * (x + .005), fist_y + depth + .04, z + high - .021),
            ], [.356, .395, .356], red if index == 1 else red_fold, sides=11, aspect=.93)
        p.rounded_box(group, "Padded closed guard fist", (fist_x, fist_y, fist_z), (.715, .668, .618), leather,
                      .127, rotation=(-.21, side * .11, side * -.13))
        p.rounded_box(group, "Ox hide knuckle cover", (fist_x + side * .018, fist_y - .254, fist_z + .062),
                      (.656, .305, .48), red_fold, .098, rotation=(-.22, side * .11, side * -.13))
        p.rounded_box(group, "Folded thumb padding", (fist_x - side * .289, fist_y - .032, fist_z - .084),
                      (.282, .432, .338), dark_red, .086, rotation=(-.04, side * -.272, side * -.161))
        for index, dx in enumerate((-.17, .0, .17)):
            p.tube(group, f"Short flax knots {index}", [
                (fist_x + dx - .035, fist_y - .390, fist_z + .095),
                (fist_x + dx, fist_y - .414, fist_z + .134),
                (fist_x + dx + .036, fist_y - .390, fist_z + .17),
            ], [.011, .015, .010], thread, sides=5)

    for side, group in ((1, "Right Leg"), (-1, "Left Leg")):
        x = side * .587
        forward = -.15 if side == 1 else .14
        p.loft(group, "Massive close-set thigh", [
            (.65, x, forward + .1, .31, .32),
            (.91, x, forward + .06, .35, .359),
            (1.23, x + side * .019, .055 + forward * .7, .366, .367),
            (1.53, x - side * .018, .10 + forward * .4, .385, .414),
            (1.83, x - side * .075, .115, .386, .391),
            (1.98, x - side * .094, .102, .29, .32),
        ], lining, .019)
        p.loft(group, "Russet wrestling greave", [
            (.24, x, forward + .07, .313, .313),
            (.45, x, forward + .07, .331, .332),
            (.74, x, forward + .07, .361, .349),
            (.94, x, forward + .07, .330, .339),
            (1.06, x, forward + .064, .297, .303),
        ], leather, .023)
        outline = [
            (.299, -.336, .561), (.443, -.418, .436), (.588, -.451, .409),
            (.747, -.408, .454), (.873, -.337, .589), (.843, -.362, .888),
            (.588, -.428, 1.035), (.333, -.365, .887),
        ]
        shield = [(side * px, forward + y, z) for px, y, z in outline]
        if side == -1:
            shield.reverse()
        back = [(px, y + .18, z) for px, y, z in shield]
        vertices = shield + back + [(x, forward - .485, .724)]
        count = len(shield)
        faces = [tuple(range(2 * count - 1, count - 1, -1))]
        for edge in range(count):
            next_edge = (edge + 1) % count
            faces.extend(((edge, next_edge, 2 * count), (next_edge, edge, count + edge, count + next_edge)))
        p.mesh(group, "Solid oxblood shin shield", vertices, faces, dark_red, bevel=.015)
        p.tube(group, "Shin shield brass hem", [
            (side * px, forward + y - .022, z + .026) for px, y, z in outline[1:4]
        ], [.021, .026, .020], warm_brass, sides=6)
        p.rounded_box(group, "Upper shin shield rivet", (x, forward - .467, .932),
                      (.086, .057, .075), brass, .015)
        p.rounded_box(group, "Squat boot's leather instep", (x, forward - .044, .264), (.735, .789, .455), shadow_hide,
                      .103, rotation=(0, 0, side * -.075))
        p.rounded_box(group, "Broad flat outsole", (x, forward - .087, .084), (.794, .916, .168), hoof,
                      .054, rotation=(0, 0, side * -.075))
        for toe in (-1, 1):
            p.rounded_box(group, "Two-part polished hoof toe", (x + toe * .182, forward - .399, .155),
                          (.347, .496, .29), hoof, .071, rotation=(0, 0, side * -.074 + toe * -.059))

    p.tube("Tail", "Short carved bristle tail", [
        (0, .451, 1.83), (.107, .68, 1.874), (.245, .856, 1.986),
        (.275, 1.029, 2.097), (.179, 1.125, 2.179), (.078, 1.094, 2.154),
    ], [.112, .118, .096, .073, .045, .013], skin, sides=8)
    p.tube("Tail", "Charcoal tail tassel", [
        (.155, 1.121, 2.175), (.088, 1.101, 2.155), (.036, 1.061, 2.14),
    ], [.062, .069, .009], mane, sides=7)

    return {
        "Torso": (0, .055, 2.36),
        "Head": (0, .021, 3.52),
        "Right Arm": (1.05, .075, 3.21),
        "Left Arm": (-1.05, .075, 3.21),
        "Right Leg": (.51, .07, 1.83),
        "Left Leg": (-.51, .12, 1.83),
        "Tail": (0, .451, 1.83),
    }
