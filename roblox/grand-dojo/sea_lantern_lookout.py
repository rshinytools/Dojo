"""A stair-free overlook rising east from the Sea Lantern Pavilion."""

from math import atan2, ceil, cos, degrees, dist, radians, sin


NAME = "Sea Lantern Lookout"
EAST_OPENING = (31.60, 37.10)
WIDTH = 5.40
WALK_POINTS = (
    (328.45, 18.35, 34.35),
    (333.00, 18.35, 34.35),
    (347.50, 22.45, 34.35),
    (352.10, 22.45, 34.35),
    (355.30, 22.45, 34.35),
)
PLATFORM_BOUNDS = (347.50, 357.10, 29.40, 39.30)


def build_sea_lantern_lookout(walk, *, bounds, item, part, prop, beam, sign,
                               slate, limestone, cedar, brass, neon,
                               paving_variant, cedar_variant, variant_field):
    lookout = item(walk, "Model", NAME)
    prop(lookout, "token", "LevelOfDetail", 4)
    west, east, north, south = PLATFORM_BOUNDS
    entry_x = 329.82
    _, start, crest, _, _ = WALK_POINTS
    _, level, center_z = crest
    entry = (entry_x, start[1] - .008, center_z)

    def piece(parent, name, position, size, tint, material, *, collide=False, **pose):
        node = part(parent, name, position, size, tint, material=material,
                    collide=collide, **pose)
        prop(node, "bool", "CastShadow", False)
        if material == cedar:
            prop(node, "string", variant_field, cedar_variant)
        elif material == limestone:
            prop(node, "string", variant_field, paving_variant)
        return node

    def label(name, x, y, z, width, height, yaw):
        plaque = sign(lookout, name, x, y, z, width, height, yaw=yaw,
                      tint="356463", face_only=True)
        prop(plaque, "bool", "CastShadow", False)

    def rail(a, b, *, end_cap=False):
        for height, width, color in ((.57, .20, "315A5D"), (1.39, .24, "527E78")):
            edge = beam(lookout, "Lookout teal guardrail",
                        (a[0], a[1] + height, a[2]), (b[0], b[1] + height, b[2]),
                        width, color, collide=True)
            prop(edge, "bool", "CastShadow", False)
            edge.find("Properties/token[@name='Material']").text = str(cedar)
            prop(edge, "string", variant_field, cedar_variant)
        count = ceil(dist(a, b) / 3.5)
        for index in range(count):
            t = (index + .30) / count
            x, y, z = (start + (end - start) * t for start, end in zip(a, b))
            piece(lookout, "Lookout cedar baluster", (x, y + .71, z),
                  (.34, 1.45, .34), "416F6D", cedar)
            piece(lookout, "Lookout copper rail cap", (x, y + 1.48, z),
                  (.45, .14, .43), "BB8C56", brass)
        if end_cap:
            x, y, z = b
            piece(lookout, "Lookout coastal corner post", (x, y + .71, z),
                  (.42, 1.55, .42), "376764", cedar)
            piece(lookout, "Lookout coastal corner cap", (x, y + 1.52, z),
                  (.53, .14, .51), "C29A61", brass)

    # Offset from the actual upper face. The .06-stud overlap under the
    # pavilion and small join at the crest keep wheels and feet on a floor.
    for a, b in ((entry, start), (start, crest)):
        grade = atan2(b[1] - a[1], b[0] - a[0])
        length = dist(a, b)
        x, y = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        half_thickness = .245
        piece(lookout, "Lookout graded cedar floor",
              (x + half_thickness * sin(grade), y - half_thickness * cos(grade), center_z),
              (WIDTH, half_thickness * 2, length + .09), "A27A62", cedar,
              collide=True, yaw=90, pitch=-degrees(grade))
        plank_count = ceil(length / 1.15)
        for index in range(plank_count):
            fraction = (index + .35) / plank_count
            px, py = (a[i] + (b[i] - a[i]) * fraction for i in (0, 1))
            piece(lookout, "Lookout cedar plank seam", (px, py + .007, center_z),
                  (WIDTH - .32, .018, .055), "795B4E", cedar,
                  yaw=90, pitch=-degrees(grade))
        for side in (-1, 1):
            rail_z = center_z + side * 2.62
            rail((a[0] - .12, a[1], rail_z), (b[0] + .18, b[1], rail_z))
            piece(lookout, "Lookout split cedar fascia",
                  (x, y - .24, center_z + side * 2.69),
                  (.18, .40, length), "53645B", cedar, yaw=90, pitch=-degrees(grade))
        piece(bounds, "Harbor Sky Pier lookout route bounds", (x, y + 3.52, center_z),
              (WIDTH + .20, 6.63, length + .30), "FFFFFF", cedar,
              yaw=90, pitch=-degrees(grade), transparency=1)

    deck_x = (west + east) / 2
    piece(lookout, "Sea Lantern Lookout stone floor", (deck_x, level - .29, center_z),
          (east - west, .58, south - north), "A9A09A", limestone, collide=True)
    piece(bounds, "Harbor Sky Pier lookout deck bounds", (deck_x, level + 3.52, center_z),
          (east - west + .12, 6.63, south - north + .12), "FFFFFF", cedar, transparency=1)
    back, face, low, high = west + .12, east - .16, north + .16, south - .16
    for a, b in (
        ((back, level, low), (face, level, low)),
        ((face, level, low), (face, level, high)),
        ((face, level, high), (back, level, high)),
        ((back, level, low), (back, level, center_z - 2.62)),
        ((back, level, high), (back, level, center_z + 2.62)),
    ):
        rail(a, b, end_cap=True)
        x, z = (a[0] + b[0]) / 2, (a[2] + b[2]) / 2
        yaw = degrees(atan2(b[0] - a[0], b[2] - a[2]))
        piece(lookout, "Lookout copper clad deck edge", (x, level - .39, z),
              (.26, .40, dist(a, b) + .08), "638176", brass, yaw=yaw)

    # Two bridge bearings and four splayed platform piles tie the lookout to the coast.
    for x, height, z, scale in (
        (334.62, 18.31, 33.15, .67), (334.62, 18.31, 35.55, .67),
        (343.16, 20.81, 32.98, .78), (343.16, 20.81, 35.72, .78),
        (349.10, 21.81, 31.14, 1.00), (349.10, 21.81, 37.56, 1.00),
        (355.18, 21.81, 31.14, 1.00), (355.18, 21.81, 37.56, 1.00),
    ):
        bed = -7.30
        for bottom, top, width, tint in (
            (bed, -.42, 2.65, "727B81"), (-.42, .52, 2.39, "94938D"),
            (.52, height - 1.10, 1.81, "8B8487"), (height - 1.10, height, 2.49, "A09591"),
        ):
            piece(lookout, "Lookout split slate pile", (x, (bottom + top) / 2, z),
                  (width * scale, top - bottom, width * scale), tint, slate)
        for y, shade in ((3.14, "6D676E"), (height * .66, "B0A19B")):
            piece(lookout, "Lookout slate weather course", (x, y, z),
                  (1.96 * scale, .14, 1.96 * scale), shade, slate)
        side = -1 if z < center_z else 1
        brace = beam(lookout, "Lookout tide-braced cedar knee", (x, height - 1.91, z),
                     (x, height - .21, z + side * 1.14), .30 * scale, "5B6760")
        prop(brace, "bool", "CastShadow", False)

    # The open deck preserves the seaward view. A copper lantern lens marks
    # the north corner above the rail with a warm emissive core.
    beacon = item(lookout, "Model", "Lookout copper lantern beacon")
    bx, bz = 354.64, 30.91
    for elevation, width, height, material, tint in (
        (.23, 2.02, .46, slate, "8A7D87"), (.53, 1.72, .18, limestone, "A99486"),
        (1.39, 1.27, 1.58, slate, "918589"), (2.23, 1.38, .19, brass, "56796E"),
        (2.68, .92, .74, cedar, "3B6D68"), (3.07, 1.50, .18, cedar, "416E68"),
        (4.42, 1.54, .21, brass, "AF7C48"), (4.61, 1.20, .27, brass, "598479"),
        (4.88, .51, .28, brass, "A37B49"), (5.04, .27, .13, brass, "C3A35E"),
    ):
        piece(beacon, "Lookout lantern beacon course", (bx, level + elevation, bz),
              (height, width, width), tint, material, roll=90, shape=2)
    for sx, sz in ((-1, -1), (-1, 1), (1, -1), (1, 1)):
        piece(beacon, "Lookout bronze lantern cage", (bx + sx * .46, level + 3.75, bz + sz * .46),
              (.11, 1.28, .11), "A57D50", brass)
    piece(beacon, "Lookout amber lantern lens", (bx, level + 3.76, bz),
          (.78, .94, .78), "EFB86B", neon, shape=0)

    # A brass compass inlay gives arriving players an unobstructed place to turn.
    compass_x = 352.14
    piece(lookout, "Lookout compass frame", (compass_x, level + .026, center_z),
          (.043, 2.64, 2.64), "A78758", brass, roll=90, shape=2)
    piece(lookout, "Lookout compass face", (compass_x, level + .049, center_z),
          (.021, 2.30, 2.30), "63817C", limestone, roll=90, shape=2)
    for heading in range(0, 360, 45):
        angle = radians(heading)
        radius = .70 if heading % 90 == 0 else .86
        piece(lookout, "Lookout compass point",
              (compass_x + sin(angle) * radius, level + .068, center_z + cos(angle) * radius),
              (.083, .027, .69 if heading % 90 == 0 else .34),
              "E1B77C" if heading == 90 else "A99167", brass, yaw=heading)
    piece(lookout, "Lookout compass center", (compass_x, level + .078, center_z),
          (.035, .25, .25), "DBB17B", brass, roll=90, shape=2)

    # Keep the signage above the playable opening without blocking the skyline.
    for side in (-1, 1):
        z = center_z + side * 2.77
        piece(lookout, "Lookout directional post", (331.38, start[1] + 2.95, z),
              (.45, 5.90, .36), "406D68", cedar)
        for y in (start[1] + .65, start[1] + 5.35):
            piece(lookout, "Lookout post copper lashing", (331.38, y, z),
                  (.51, .16, .42), "B9915F", brass)
    y = start[1] + 5.91
    piece(lookout, "Lookout teal sign lintel", (331.38, y, center_z),
          (.43, .66, 5.84), "355F60", cedar)
    for elevation in (-.31, .32):
        piece(lookout, "Lookout oxidized copper lintel bead", (331.38, y + elevation, center_z),
              (.51, .085, 6.10), "9B835D", brass)
    label("SEA LANTERN LOOKOUT", 331.36, y, center_z, 5.40, .54, -90)
    label("SEA LANTERN PAVILION", 331.40, y, center_z, 5.40, .54, 90)
