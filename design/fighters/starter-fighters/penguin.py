"""Original Tideharbor guard model for the Aquatic Penguin Brawler."""

from math import cos, sin


def build(p):
    navy = p.material("Penguin | blue-black plumage", "253544", .83, grain=74)
    dark = p.material("Penguin | shadow feather", "1D2938", .86)
    feather = p.material("Penguin | slate flight feather", "42596A", .81)
    ivory = p.material("Penguin | warm ivory bib", "E7E2CF", .81, grain=81)
    cheek = p.material("Penguin | pearl cheek", "EBE6D7", .78)
    bill = p.material("Penguin | sunset orange bill", "E79441", .66)
    bill_light = p.material("Penguin | warm bill bevel", "F3B659", .64)
    mandible = p.material("Penguin | ochre lower bill", "AE582B", .75)
    toe = p.material("Penguin | amber webbed feet", "D28642", .78)
    toe_high = p.material("Penguin | toe highlights", "E69B53", .77)
    pupil = p.material("Penguin | dark eye", "182433", .51)
    iris = p.material("Penguin | blue-green iris", "32958F", .46)
    white = p.material("Penguin | warm eye catchlight", "FFF5DB", .42)

    teal = p.material("Penguin | Tideharbor teal sailcloth", "2A7377", .86, grain=118)
    stitched = p.material("Penguin | frosted teal padding", "3D8A8D", .84, grain=106)
    ice = p.material("Penguin | powdered ice boot and scarf piping", "86C7CD", .82, grain=111)
    white_thread = p.material("Penguin | fog white stitch", "BDE9DC", .84)
    bindings = p.material("Penguin | indigo binding", "28485E", .88, grain=97)
    steel = p.material("Penguin | blue steel buckle", "7AABB0", .49, metallic=.23)

    p.loft("Torso", "Leaning navy feather body", [
        (.91, 0, .21, .264, .27),
        (1.18, 0, .158, .59, .457),
        (1.59, .009, .107, .775, .544),
        (2.00, 0, .032, .847, .588),
        (2.45, -.019, -.024, .884, .61),
        (2.81, -.015, -.055, .864, .533),
        (3.12, -.017, -.08, .705, .468),
        (3.38, -.012, -.123, .505, .381),
        (3.49, -.01, -.141, .356, .291),
    ], navy, .027)
    p.loft("Torso", "Tapering ivory chest and keel feathers", [
        (1.38, -.005, -.387, .35, .058),
        (1.64, -.003, -.431, .52, .104),
        (2.06, -.012, -.501, .61, .124),
        (2.43, -.019, -.518, .665, .153),
        (2.79, -.019, -.512, .586, .133),
        (3.09, -.012, -.497, .448, .123),
        (3.37, -.004, -.445, .288, .101),
    ], ivory, .019)
    p.loft("Torso", "Teal padded sliding jersey hem", [
        (1.22, .006, .091, .56, .482),
        (1.37, .006, .091, .713, .557),
        (1.58, .006, .067, .801, .591),
        (1.77, 0, .047, .834, .613),
        (1.91, 0, .041, .838, .604),
    ], teal, .024)
    p.loft("Torso", "Hem's pale ripstop binding", [
        (1.298, 0, .087, .657, .524),
        (1.332, 0, .083, .695, .548),
        (1.385, 0, .086, .722, .563),
    ], ice, .008)
    p.loft("Torso", "Deep indigo waistband", [
        (1.76, 0, .044, .830, .621),
        (1.814, 0, .044, .846, .632),
        (1.898, 0, .041, .850, .626),
        (1.946, 0, .039, .849, .614),
    ], bindings, .015)
    p.rounded_box("Torso", "Low profile ice buckle", (.134, -.610, 1.855), (.373, .129, .205), steel,
                  .045, rotation=(.02, -.111, -.074))
    p.rounded_box("Torso", "Teal buckle centre", (.135, -.678, 1.854), (.226, .037, .093), teal, .014)
    for side in (-1, 1):
        p.tube("Torso", "Curving side seam", [
            (side * .658, -.551, 1.97), (side * .666, -.598, 2.19),
            (side * .661, -.633, 2.48), (side * .626, -.608, 2.743),
            (side * .543, -.573, 2.942),
        ], [.030, .038, .039, .036, .021], teal, sides=7)
        p.tube("Torso", "Topstitch alongside side seam", [
            (side * .672, -.607, 2.14), (side * .680, -.654, 2.35),
            (side * .654, -.651, 2.62), (side * .602, -.617, 2.825),
        ], [.010, .014, .014, .009], ice, sides=5)

    p.loft("Torso", "Wrap around the collar", [
        (3.19, -.024, -.115, .640, .447),
        (3.277, -.024, -.11, .667, .467),
        (3.418, -.020, -.107, .597, .439),
        (3.474, -.015, -.107, .487, .389),
    ], stitched, .021)
    p.tube("Torso", "Rolled top edge of the harbor scarf", [
        (-.569, -.299, 3.408), (-.421, -.509, 3.455), (-.124, -.565, 3.442),
        (.239, -.523, 3.428), (.543, -.296, 3.399),
    ], [.033, .043, .045, .043, .032], ice, sides=8)
    p.rounded_box("Torso", "Wrapped scarf knot", (-.424, .182, 3.345), (.36, .297, .201), ice,
                  .051, rotation=(.13, -.20, -.27))

    # Shape the back of the scarf as sections of a single solid cloth strip.
    rows = [
        ((-.41, .308, 3.346), (.156, 0, .037)),
        ((-.525, .593, 3.314), (.173, .024, .057)),
        ((-.748, .885, 3.214), (.171, .053, .062)),
        ((-1.003, 1.106, 3.205), (.142, .073, .039)),
        ((-1.244, 1.267, 3.343), (.113, .082, .016)),
    ]
    streamers = []
    for (x, y, z), (dx, dy, dz) in rows:
        streamers.extend(((x - dx, y - dy, z - dz), (x, y, z + .036), (x + dx, y + dy, z + dz)))
    reverse = [(x, y, z - .062) for x, y, z in streamers]
    faces = []
    length = len(streamers)
    for row in range(len(rows) - 1):
        left = row * 3
        for index in (left, left + 1):
            faces.extend(((index, index + 1, index + 4, index + 3),
                          (index + 3 + length, index + 4 + length, index + 1 + length, index + length)))
        for index in (left, left + 2):
            faces.append((index, index + 3, index + 3 + length, index + length))
    for edge in (0, length - 3):
        faces.extend(((edge, edge + 1, edge + 1 + length, edge + length),
                      (edge + 1, edge + 2, edge + 2 + length, edge + 1 + length)))
    p.mesh("Torso", "Long swept glacier scarf end", streamers + reverse, faces, ice, bevel=.009)
    p.tube("Torso", "Scarf end dark seam", [
        (x - dx, y - dy, z - dz + .01) for (x, y, z), (dx, dy, dz) in rows
    ], [.017, .020, .020, .016, .011], teal, sides=5)

    p.loft("Head", "Streamlined penguin head", [
        (3.37, -.003, -.141, .355, .315),
        (3.54, 0, -.166, .530, .409),
        (3.79, .01, -.171, .667, .501),
        (4.05, .014, -.156, .704, .535),
        (4.31, .015, -.133, .696, .52),
        (4.57, .012, -.089, .600, .468),
        (4.744, .01, -.039, .422, .334),
        (4.787, .007, -.014, .227, .235),
    ], navy, .019)
    p.loft("Head", "Ivory lower cheek and throat", [
        (3.47, -.001, -.404, .221, .115),
        (3.63, .009, -.501, .426, .146),
        (3.83, .013, -.517, .553, .21),
        (4.00, .02, -.526, .560, .205),
        (4.12, .017, -.516, .45, .177),
    ], cheek, .019)
    for side in (-1, 1):
        x = side * .362
        p.ellipse("Head", "Ivory sweep through the brow", (x, -.588, 4.165), (.276, .174, .265), cheek)
        p.ellipse("Head", "Soft eye shadow", (side * .308, -.716, 4.223), (.184, .075, .149), feather)
        p.ellipse("Head", "Wide bright eye", (side * .307, -.765, 4.223), (.151, .058, .124), white)
        p.ellipse("Head", "Teal fighting eye", (side * .271, -.812, 4.22), (.070, .023, .075), iris)
        p.ellipse("Head", "Eye pupil", (side * .260, -.827, 4.219), (.037, .013, .052), pupil)
        p.rounded_box("Head", "Tiny white eye glint", (side * .248, -.843, 4.245), (.034, .014, .036), white, .006)
        rise = .032 if side == 1 else -.011
        p.tube("Head", "Confident sweeping brow", [
            (side * .155, -.735, 4.352 + rise), (side * .349, -.743, 4.403 + rise),
            (side * .552, -.591, 4.458 + rise),
        ], [.044, .072, .036], dark, sides=7)

    # The broad beak has a flattened tip and a separate shaded lower half.
    p.loft("Head", "Low angular orange upper bill", [
        (3.893, .006, -.834, .229, .225),
        (3.941, .005, -.853, .297, .264),
        (4.021, .004, -.797, .312, .251),
        (4.096, .003, -.741, .233, .157),
        (4.137, .002, -.713, .117, .086),
    ], bill, .015)
    p.loft("Head", "Short lower mandible", [
        (3.797, .005, -.795, .094, .09),
        (3.83, .005, -.817, .178, .143),
        (3.884, .006, -.828, .242, .188),
        (3.909, .006, -.835, .251, .210),
    ], mandible, .012)
    p.tube("Head", "Bill's curved pale rim", [
        (-.207, -1.004, 3.965), (-.108, -1.086, 3.962), (.025, -1.117, 3.959),
        (.146, -1.078, 3.961), (.218, -1.007, 3.966),
    ], [.017, .021, .021, .020, .013], bill_light, sides=7)
    p.tube("Head", "Wind brushed crown feather", [
        (-.118, .006, 4.65), (-.077, .072, 4.752), (.127, .148, 4.82), (.235, .219, 4.823),
    ], [.116, .108, .066, .009], dark, sides=8, aspect=.73)

    for group, flipper, sizes, cuff, adjustment in (
        ("Left Arm",
         [(-.690, -.037, 3.078), (-.952, -.175, 2.938), (-1.139, -.382, 2.68),
          (-1.100, -.657, 2.614), (-.909, -.934, 2.728), (-.774, -1.141, 2.808)],
         [.228, .295, .285, .231, .163, .036],
         [(-1.071, -.276, 2.807), (-1.141, -.398, 2.668), (-1.121, -.554, 2.627)],
         ((-1.167, -.618, 2.658), (.429, .152, .448), (-.45, -.23, -.252))),
        ("Right Arm",
         [(.680, .023, 3.075), (.967, .113, 2.931), (1.226, .345, 2.657),
          (1.471, .384, 2.629), (1.704, .251, 2.714), (1.808, .099, 2.823)],
         [.232, .301, .277, .224, .151, .036],
         [(1.079, .230, 2.81), (1.225, .345, 2.665), (1.352, .370, 2.633)],
         ((1.261, .158, 2.68), (.438, .158, .434), (-.25, .39, .346))),
    ):
        p.tube(group, "Tapered feather flipper", flipper, sizes, dark, sides=11, aspect=.80)
        p.tube(group, "Floating cuff around the bent flipper", cuff, [.277, .318, .281], teal,
               sides=10, aspect=.83)
        p.tube(group, "Pale elbow cuff binding", cuff[-2:], [.312, .292], ice, sides=10, aspect=.84)
        pad, size, rotation = adjustment
        p.rounded_box(group, "Rounded sliding elbow pad", pad, size, stitched, .072, rotation)
        sin_x, sin_y, sin_z = (sin(angle) for angle in rotation)
        cos_x, cos_y, cos_z = (cos(angle) for angle in rotation)

        def pad_front(dx, dz):
            dy = -size[1] / 2 - .006
            y1, z1 = dy * cos_x - dz * sin_x, dy * sin_x + dz * cos_x
            x2, z2 = dx * cos_y + z1 * sin_y, -dx * sin_y + z1 * cos_y
            return (pad[0] + x2 * cos_z - y1 * sin_z, pad[1] + x2 * sin_z + y1 * cos_z, pad[2] + z2)

        p.tube(group, "Three-crest elbow stitching", [
            pad_front(x, z) for x, z in ((-.126, .014), (-.055, .071), (.002, .019), (.061, .075), (.129, .028))
        ], [.012, .020, .019, .021, .012], white_thread, sides=5)

    for side, group in ((1, "Right Leg"), (-1, "Left Leg")):
        x = side * .492
        y = -.13 if side == 1 else .168
        p.loft(group, "Short bent feathered leg", [
            (.220, x, y + .025, .248, .25),
            (.441, x + side * .02, y + .071, .267, .308),
            (.746, x + side * .03, y + .081, .319, .355),
            (1.045, x, y + .048, .328, .360),
            (1.431, x - side * .074, .109, .264, .270),
        ], navy, .020)
        p.loft(group, "Teal ankle protector", [
            (.238, x, y + .034, .258, .275),
            (.317, x + side * .008, y + .047, .281, .298),
            (.474, x + side * .012, y + .062, .289, .317),
            (.523, x + side * .016, y + .069, .283, .317),
        ], teal, .024)
        p.loft(group, "Low blue ankle binding", [
            (.289, x, y + .045, .280, .3),
            (.335, x + side * .008, y + .046, .287, .31),
            (.361, x + side * .009, y + .051, .285, .309),
        ], ice, .009)
        contour = [
            (-.238, .267), (-.384, -.163), (-.433, -.451), (-.282, -.515), (-.172, -.479),
            (-.063, -.634), (.091, -.632), (.178, -.486), (.344, -.517), (.418, -.423),
            (.348, -.157), (.227, .275),
        ]
        rear = [(x + dx + side * max(0, -dy) * .173, y + dy, 0) for dx, dy in contour]
        upper = [(x + dx * .935 + side * max(0, -dy) * .173, y + dy * .947, .133) for dx, dy in contour]
        vertices = rear + upper + [(x, y + .052, .295)]
        count = len(contour)
        faces = [tuple(reversed(range(count)))]
        for edge in range(count):
            nxt = (edge + 1) % count
            faces.extend(((edge, nxt, nxt + count, edge + count), (edge + count, nxt + count, 2 * count)))
        p.mesh(group, "Three-toed orange webbed foot", vertices, faces, toe, bevel=.026)
        for dx, reach in ((-.214, -.46), (.126, -.49)):
            p.tube(group, "Orange raised toe web fold", [
                (x + dx * .49, y - .235, .222),
                (x + dx * .82 + side * .040, y - .342, .190),
                (x + dx + side * .070, y + reach, .159),
            ], [.016, .021, .011], toe_high, sides=6)

    p.tube("Tail", "Short stunted feather tail", [
        (0, .441, 1.559), (.008, .715, 1.402), (.043, .927, 1.242), (.068, 1.049, 1.163),
    ], [.247, .216, .128, .030], dark, sides=9, aspect=.80)

    return {
        "Torso": (0, .009, 2.22),
        "Head": (.003, -.118, 3.39),
        "Right Arm": (.706, .011, 3.048),
        "Left Arm": (-.701, -.037, 3.049),
        "Right Leg": (.434, -.04, 1.225),
        "Left Leg": (-.431, .12, 1.225),
        "Tail": (0, .441, 1.559),
    }
