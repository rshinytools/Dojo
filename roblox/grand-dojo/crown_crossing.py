"""The raised crossing between Reedfall Crown and Cinder's Kiln Ridge."""

from math import atan2, ceil, degrees, dist


NAME = "Crown Crossing"
WIDTH = 5.5
CROWN_OPENING = (-87.72, -81.98)
KILN_OPENING = (-142.54, -137.75)
POINTS = (
    (93.95, 34.40, -84.85),
    (97.05, 34.40, -84.85),
    (106.20, 31.80, -90.70),
    (118.80, 27.70, -100.80),
    (130.50, 24.00, -112.80),
    (137.00, 20.70, -123.40),
    (137.11, 18.30, -132.00),
    (135.60, 17.22, -135.20),
    (132.00, 15.53, -139.90),
    (126.60, 13.90, -140.40),
    (123.50, 13.08, -140.10),
    (120.60, 13.08, -140.10),
)
KILN_JOIN = ((120.60, 13.08, -136.90), (120.60, 13.08, -134.85))


def build_crown_crossing(parent, *, item, prop, part, beam, triangle, path_edge,
                         sign, festival_lantern, garden_shelf, garden_prop,
                         sandstone, slate, cedar, grass, metal, paving_variant,
                         variant_field):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)
    edges = [path_edge(POINTS, side * WIDTH / 2) for side in (-1, 1)]
    palette = ("AA928F", "B8A298", "AE9690", "BAA096")
    for index, (a, b, c, d) in enumerate(zip(edges[0], edges[1], edges[1][1:], edges[0][1:])):
        before = len(walk)
        a, b, c, d = ((x, y - .17, z) for x, y, z in (a, b, c, d))
        for face, tint in (((a, b, c), palette[index % 4]), ((a, c, d), palette[(index + 1) % 4])):
            triangle(walk, *face, tint, name="Crown Crossing sandstone deck",
                     thickness=.34, material=sandstone, collide=True, shadow=False)
        for step in walk[before:]:
            prop(step, "string", variant_field, paving_variant)

    for side in (-1, 1):
        edge = path_edge(POINTS, side * (WIDTH / 2 - .11))
        for index, (a, b) in enumerate(zip(edge, edge[1:])):
            # Meet the Crown rail at its opening and leave the summit
            # overlap open so travelers can turn inside the bay.
            if index == len(edge) - 2:
                continue
            if index == 0:
                a = (94.66, a[1], a[2])
            for lift, gauge, color in ((.58, .20, "8D493C"), (1.53, .24, "A35B46")):
                beam(walk, "Crown Crossing lacquered rail", (a[0], a[1] + lift, a[2]),
                     (b[0], b[1] + lift, b[2]), gauge, color, collide=True)
            beam(walk, "Crown Crossing stone rim", (a[0], a[1] - .31, a[2]),
                 (b[0], b[1] - .31, b[2]), .45, "897382")
            count = max(1, ceil(dist(a, b) / 3.3))
            for bay in range(count):
                t = (bay + .5) / count
                x, y, z = (u + (v - u) * t for u, v in zip(a, b))
                part(walk, "Crown Crossing cedar newel", (x, y + .77, z), (.33, 1.56, .33),
                     "78493D", material=cedar, collide=False)
                part(walk, "Crown Crossing bronze cap", (x, y + 1.58, z), (.42, .13, .42),
                     "BC9159", material=metal, collide=False)

    # The stone trestles stand away from the market and workshop road lanes.
    for index, pier_x, pier_z in ((2, 110.50, -86.10), (3, 123.10, -96.20),
                                  (5, 143.10, -121.90), (8, 129.60, -141.30)):
        x, y, z = POINTS[index]
        next_x, _, next_z = POINTS[index + 1]
        yaw = degrees(atan2(next_x - x, next_z - z))
        foot, capital = -4.8, y - 4.93
        part(walk, "Tall split slate pier", (pier_x, (capital + foot) / 2, pier_z),
             (2.36, capital - foot, 2.72), "807180", yaw=yaw, material=slate, collide=False)
        part(walk, "Pier dressed sandstone head", (pier_x, capital + .2, pier_z), (4.08, .50, 3.42),
             "A18A91", yaw=yaw, material=sandstone, collide=False)
        beam(walk, "Deep cedar bridge brace", (pier_x, capital + .22, pier_z), (x, y - .53, z),
             .74, "795445")
        for fraction in (.24, .54, .79):
            course_y = foot + (capital - foot) * fraction
            part(walk, "Pier slate stringcourse", (pier_x, course_y, pier_z), (2.53, .19, 2.88),
                 "94808B", yaw=yaw, material=slate, collide=False)

    for x, y, z, width, depth in ((108.9, 2.04, -85.1, 8.5, 6.46), (126.2, 3.23, -92.6, 8.65, 7.15),
                                  (146.5, 4.12, -125.5, 7.15, 6.37)):
        garden_shelf(walk, x, y, z, width, depth, y + 4.65, "827683", slate, collide=False)
        garden_shelf(walk, x, y + .10, z, width * .84, depth * .77, .23, "788D51", grass, collide=False)
        garden_prop(walk, "bankRock", (x - .84, y - .10, z + .71), .29, 24, "A3949C")
        garden_prop(walk, "rockVine", (x + .97, y - .61, z + depth * .42), .55, 39, "92A367")
        garden_prop(walk, "meadowCover", (x + .63, y + .08, z + 1.11), .31, 72, "A6B479")

    for x, y, z, heading, width, label in (
        (94.63, 34.40, -90.68, -90, 5.14, "CINDER VIA CROWN CROSSING"),
        (118.30, 13.08, -142.62, 0, 4.87, "REEDFALL CROWN  ↑"),
    ):
        part(walk, "Crown Crossing wayfinding post", (x, y + 1.66, z), (.40, 3.29, .40),
             "81503E", material=cedar, collide=False)
        sign(walk, label, x, y + 2.86, z, width, .98, heading, "51535F")
        festival_lantern(walk, x, y + 3.96, z, .46, light=False)
