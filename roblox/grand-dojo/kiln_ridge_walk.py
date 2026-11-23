"""A two-ended overlook trail above the lower Cinder workshop road."""

from math import atan2, ceil, cos, degrees, dist, hypot, radians, sin

from crown_crossing import KILN_OPENING as CROWN_KILN_OPENING
from kiln_pass import KILN_OPENING, rail_outside_opening


NAME = "Kiln Ridge Walk"
WIDTH = 4.60
PATH = (
    (110.40, 1.960, -98.70), (105.60, 1.960, -104.55),
    (99.30, 3.30, -110.10), (96.80, 5.38, -118.10),
    (100.20, 8.16, -127.50), (108.90, 10.78, -133.40),
    (117.20, 13.08, -134.40), (124.00, 13.08, -135.30),
    (122.70, 10.429, -126.50), (116.10, 8.703, -118.90),
    (112.55, 6.469, -126.30), (107.95, 5.770, -119.25),
    (113.30, 2.89, -112.55), (120.40, 2.858, -106.825),
)


def interpolate(a, b, fraction):
    return tuple(start + (finish - start) * fraction for start, finish in zip(a, b))


def build_kiln_ridge_walk(parent, road_span, *, item, prop, part, beam, triangle,
                         path_edge, sign, swept_roof, festival_lantern, garden_shelf,
                         garden_prop, showcase_tree, sandstone, cedar, grass, brass,
                         stone_variant, wood_variant, variant_field):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)
    approach, departure = road_span
    dx, dy, dz = (b - a for a, b in zip(approach, departure))
    length = hypot(dx, dz)
    tangent = (dx / length, dz / length)
    road_normal = (tangent[1], -tangent[0])
    road_y_offset = .25 * (hypot(1, dy / length) - 1)

    def road_location(point):
        x, _, z = point
        offset_x, offset_z = x - approach[0], z - approach[2]
        shoulder = offset_x * road_normal[0] + offset_z * road_normal[1]
        station = offset_x * tangent[0] + offset_z * tangent[1]
        return shoulder, approach[1] + dy * station / length + road_y_offset

    def merge_grade(point):
        x, y, z = point
        shoulder, grade = road_location(point)
        blend = max(0, min(1, (shoulder - 6.50) / 1.65))
        return x, grade - .020 + (y - grade + .020) * blend, z

    def clip_shoulder(polygon, edge, *, outside):
        clipped = []
        for a, b in zip(polygon, polygon[1:] + polygon[:1]):
            distance_a, _ = road_location(a)
            distance_b, _ = road_location(b)
            inside_a = (distance_a >= edge) == outside
            inside_b = (distance_b >= edge) == outside
            if inside_a:
                clipped.append(a)
            if inside_a != inside_b:
                clipped.append(interpolate(a, b, (edge - distance_a) / (distance_b - distance_a)))
        return clipped

    def stone_piece(name, position, size, tint, **options):
        piece = part(walk, name, position, size, tint, material=sandstone, **options)
        prop(piece, "string", variant_field, stone_variant)
        return piece

    def deck_facet(points, tint):
        before = len(walk)
        triangle(walk, *points, tint, name="Kiln Ridge sandstone deck", material=sandstone,
                 thickness=.36, collide=True, shadow=False)
        for slab in list(walk)[before:]:
            prop(slab, "string", variant_field, stone_variant)

    def graded_edge(distance):
        return tuple(merge_grade(point) for point in path_edge(PATH, distance))

    left, right = (path_edge(PATH, distance) for distance in (-WIDTH / 2, WIDTH / 2))
    for i in range(len(PATH) - 1):
        strip = [left[i], right[i], right[i + 1], left[i + 1]]
        # Bring the two joins to the old road without placing extra paving in its center lanes.
        for low, high, tint in ((6.20, 6.50, "986F62"), (6.50, 8.15, "A9826E"),
                                (8.15, float("inf"), "B18D77")):
            face = clip_shoulder(clip_shoulder(strip, low, outside=True), high, outside=False)
            vertices = [(x, y - .18, z) for x, y, z in map(merge_grade, face)]
            for b, c in zip(vertices[1:-1], vertices[2:]):
                deck_facet((vertices[0], b, c), tint)
    left = graded_edge(-WIDTH / 2)

    summit_a, summit_b = PATH[6:8]
    summit_dx, _, summit_dz = (b - a for a, b in zip(summit_a, summit_b))
    summit_length = hypot(summit_dx, summit_dz)
    summit_y = PATH[6][1]
    yaw = degrees(atan2(summit_dx, summit_dz))

    def bay_point(fraction, offset, lift=0):
        x, y, z = interpolate(summit_a, summit_b, fraction)
        return x + offset * summit_dz / summit_length, y + lift, z - offset * summit_dx / summit_length

    stone_piece("Kiln Ridge lookout floor", bay_point(.5, 4.78, -.27),
                (5.72, .55, summit_length * .91), "B5937E", yaw=yaw)

    posts = set()

    def guard(a, b):
        for lift, width, tint in ((.51, .17, "8A5141"), (1.39, .23, "A2654E")):
            beam(walk, "Kiln Ridge cedar guard", (a[0], a[1] + lift, a[2]),
                 (b[0], b[1] + lift, b[2]), width, tint, collide=True)
        count = max(1, ceil(dist(a, b) / 3.35))
        for index in range(count + 1):
            position = tuple(round(value, 4) for value in interpolate(a, b, index / count))
            if position in posts:
                continue
            posts.add(position)
            x, y, z = position
            newel = part(walk, "Kiln Ridge clay-red newel", (x, y + .73, z),
                         (.34, 1.46, .34), "865543", material=cedar)
            prop(newel, "string", variant_field, wood_variant)
            part(walk, "Kiln Ridge brass rail cap", (x, y + 1.51, z),
                 (.44, .12, .44), "C29458", material=brass, collide=False)

    for side in (-1, 1):
        shoulder = graded_edge(side * (WIDTH / 2 + .12))
        for i, (a, b) in enumerate(zip(shoulder, shoulder[1:])):
            distance_a, _ = road_location(a)
            distance_b, _ = road_location(b)
            if min(distance_a, distance_b) < 6.72:
                # Open both junctions to the through-road and keep rail caps out of its shoulders.
                if max(distance_a, distance_b) < 6.72:
                    continue
                clipped = interpolate(a, b, (6.72 - distance_a) / (distance_b - distance_a))
                a, b = (clipped, b) if distance_a < 6.72 else (a, clipped)
            if i == 6 and side == 1:
                guard(a, bay_point(.14, 2.42))
                guard(bay_point(.86, 2.42), b)
            elif side == 1 and i in (2, 3):
                for start, finish in rail_outside_opening(a,b,KILN_OPENING):
                    guard(start,finish)
            else:
                guard(a, b)
            beam(walk, "Kiln Ridge sandstone rim", (a[0], a[1] - .27, a[2]),
                 (b[0], b[1] - .27, b[2]), .29, "977661")
    guard(bay_point(.055, 2.40), bay_point(.055, 7.58))
    for start, finish in rail_outside_opening(bay_point(.945, 2.40), bay_point(.945, 7.58), CROWN_KILN_OPENING):
        guard(start, finish)
    guard(bay_point(.055, 7.58), bay_point(.945, 7.58))

    # Tall stone ribs follow the contours. Their crowns tuck under the deck and leave the grade open.
    outline = ((-1, -.38), (-.49, -1), (.39, -.97), (1, -.33), (.68, .83), (-.66, .92))
    strata = ((0, 1.14, -.12), (.40, 1.0, .03), (.72, .85, -.075), (1, .66, .01))
    tints = (("84645B", "8E6C60", "997465"), ("947160", "A7806B", "987262"),
             ("B18A75", "AE846E", "A67D6B"))

    def grade_limit(x, z, top):
        for a, b in zip(PATH, PATH[1:]):
            dx, dz = b[0] - a[0], b[2] - a[2]
            fraction = max(0, min(1, ((x - a[0]) * dx + (z - a[2]) * dz) / (dx * dx + dz * dz)))
            px, py, pz = interpolate(a, b, fraction)
            if hypot(x - px, z - pz) < 3.25:
                top = min(top, merge_grade((x, py, z))[1] - .62)
        return top

    def clay_rib(x, z, foot, top, width, depth, bearing):
        c, s = cos(radians(bearing)), sin(radians(bearing))
        bands = []
        for height, spread, shear in strata:
            ring = []
            for u, v in outline:
                sx, sz = (u * spread + shear) * width * .5, v * depth * spread * .5
                px, pz = x + sx * c + sz * s, z - sx * s + sz * c
                crown = grade_limit(px, pz, top + .46 * u + .31 * v)
                ring.append((px, foot + (crown - foot) * height, pz))
            bands.append(ring)
        first = len(walk)
        for course, (bottom, crown) in enumerate(zip(bands, bands[1:])):
            for index in range(len(outline)):
                nxt = (index + 1) % len(outline)
                for vertices in ((bottom[index], bottom[nxt], crown[nxt]),
                                 (bottom[index], crown[nxt], crown[index])):
                    triangle(walk, *vertices, tints[course][index % 3], name="Kiln Ridge clay strata",
                             material=sandstone, thickness=.16, shadow=False)
        for a, b in zip(bands[-1][1:-1], bands[-1][2:]):
            triangle(walk, bands[-1][0], a, b, "AA826F", name="Kiln Ridge rock crest",
                     material=sandstone, thickness=.16, shadow=False)
        for face in list(walk)[first:]:
            prop(face, "string", variant_field, stone_variant)

    for index in (1, 2, 3, 4, 5, 7, 8, 9, 10, 11):
        a, b = PATH[index:index + 2]
        x, y, z = interpolate(a, b, .51)
        bearing = degrees(atan2(b[0] - a[0], b[2] - a[2]))
        clay_rib(x, z, -5.45, y - .36, 5.05 + .5 * (index % 3), 5.88, bearing)
    x, _, z = bay_point(.48, 5.15)
    clay_rib(x, z, -5.45, summit_y - .47, 7.6, 8.6, yaw)

    for i, (x, z, top, width, depth, bearing) in enumerate((
        (94.10, -114.75, 3.22, 7.25, 9.2, 41),
        (92.55, -125.85, 7.07, 9.6, 8.7, 63),
        (100.70, -135.80, 9.02, 12.35, 9.0, 73),
        (109.18, -140.15, 9.52, 8.60, 9.75, 39),
        (114.58, -144.10, 8.14, 7.25, 6.72, 17),
    )):
        clay_rib(x, z, -5.26, top, width, depth, bearing)
        garden_shelf(walk, x, top + .05, z, width * .57, depth * .54, .30,
                     "7D8854", grass, collide=False)
        for key, ox, oz, scale, tint in (
            ("bankRock", -.80, -.40, .24, "A98B7F"), ("meadowCover", .55, -.62, .22, "9FA96A"),
            ("mossFlowers", .34, .71, .17, "D3A28A"), ("grassBlade", -.55, .75, .22, "D5B786"),
        ):
            garden_prop(walk, key, (x + ox, top + .05, z + oz), scale, bearing + i * 23, tint)
    showcase_tree(walk, 92.18, -126.58, False, .61, 49, 7.12, compact=True)
    showcase_tree(walk, 100.25, -136.30, True, .60, 72, 9.07, compact=True)

    # Shade and seat sit behind the viewing edge. The post spacing leaves the promenade open.
    for fraction in (.16, .84):
        px, _, pz = bay_point(fraction, 6.13)
        stone_piece("Kiln Ridge canopy stone shoe", (px, summit_y + .17, pz),
                    (.68, .34, .67), "8E6C5D", yaw=yaw)
        column = part(walk, "Kiln Ridge canopy post", (px, summit_y + 3.04, pz),
                      (.38, 5.76, .39), "805243", material=cedar)
        prop(column, "string", variant_field, wood_variant)
        festival_lantern(walk, *bay_point(fraction, 6.29, 5.69), .55, light=False)
    cx, _, cz = bay_point(.5, 6.12)
    swept_roof(walk, cx, summit_y + 5.86, cz, 6.34, 2.93, 1.39, fine_tiles=False)
    sign(walk, "KILN RIDGE WALK", cx, summit_y + 5.55, cz + 1.31, 4.95, .74, 0, "794C3E")
    bench = part(walk, "Kiln Ridge resting bench", bay_point(.13, 4.25, .47),
                 (.50, .17, 1.94), "9B6A4E", material=cedar, yaw=yaw+90, collide=False)
    prop(bench, "string", variant_field, wood_variant)
    for offset in (3.63, 4.87):
        stone_piece("Kiln Ridge bench foot", bay_point(.13, offset, .19),
                    (.32, .38, .35), "8E6C5D", yaw=yaw+90, collide=False)

    for index in (2, 4, 8, 10):
        x, y, z = left[index]
        festival_lantern(walk, x, y + 1.81, z, .53, light=False)

    for x, y, z, bearing in ((99.53, 1.95, -102.73, 69), (116.28, 2.82, -116.54, 117)):
        foundation = y + 5.27
        stone_piece("Kiln Ridge sign support", (x, y - foundation / 2, z),
                    (.80, foundation, .82), "997968", collide=False)
        part(walk, "Kiln Ridge wayfinding post", (x, y + 1.30, z), (.33, 2.61, .34),
             "795144", material=cedar, collide=False)
        sign(walk, "KILN RIDGE WALK", x, y + 2.45, z, 4.84, .91, bearing, "794C3E")
