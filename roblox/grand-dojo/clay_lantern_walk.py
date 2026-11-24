"""A raised, stair-free turnout along the Harbor to Cinder road."""

from math import atan2, ceil, degrees, dist, hypot

from clay_lantern_shelter import build_clay_lantern_shelter


NAME = "Clay Lantern Lookout"
LEVEL = 10.80
WIDTH = 5.40
HARBOR_JOIN = 8.20
CINDER_JOIN = 47.00
ROAD_OPENINGS = ((4.90, 11.50), (43.70, 50.30))


def road_coordinates(start, end):
    dx, dz = end[0] - start[0], end[2] - start[2]
    length = hypot(dx, dz)
    heading = degrees(atan2(dx, dz))

    def road_level(distance):
        return start[1] + (end[1] - start[1]) * distance / length

    def point(distance, east, elevation):
        return (
            start[0] + (dx * distance - dz * east) / length,
            elevation,
            start[2] + (dz * distance + dx * east) / length,
        )

    return length, heading, road_level, point


def walk_points(start, end):
    _, _, road_level, point = road_coordinates(start, end)
    harbor_y, cinder_y = road_level(HARBOR_JOIN), road_level(CINDER_JOIN)
    return tuple(point(*coordinates) for coordinates in (
        (HARBOR_JOIN, 2.75, harbor_y), (HARBOR_JOIN, 7.20, harbor_y),
        (9.10, 10.60, 4.50), (13.40, 13.95, 6.16), (18.75, 16.80, 8.03),
        (25.35, 18.40, 10.25), (27.55, 18.40, LEVEL), (33.20, 18.40, LEVEL),
        (39.10, 16.20, 9.05), (43.40, 13.25, 7.41), (46.60, 9.20, 5.80),
        (CINDER_JOIN, 7.20, cinder_y), (CINDER_JOIN, 2.75, cinder_y),
    ))


def build_clay_lantern_walk(parent, start, end, *, item, prop, part, beam, triangle, path_edge,
                            sign, swept_roof, festival_lantern, garden_prop, vector, asset,
                            cedar, slate, limestone, brass, cedar_variant, stone_variant, variant_field):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)
    length, yaw, road_level, point = road_coordinates(start, end)
    path = walk_points(start, end)
    west, east = (path_edge(path, side * WIDTH / 2) for side in (1, -1))

    def finish(node, variant=None):
        prop(node, "bool", "CastShadow", False)
        if variant:
            prop(node, "string", variant_field, variant)

    def box(name, center, size, tint, material, *, collide=False, heading=yaw):
        piece = part(walk, name, center, size, tint, material=material, collide=collide, yaw=heading)
        finish(piece, cedar_variant if material == cedar else stone_variant if material == limestone else None)
        return piece

    def mix(a, b, amount):
        return tuple(x + (y - x) * amount for x, y in zip(a, b))

    posts = set()

    def rail(a, b):
        for lift, width, tint in ((.46, .17, "72463D"), (1.44, .23, "A46C53")):
            aa, bb = ((x, y + lift, z) for x, y, z in (a, b))
            finish(beam(walk, "Clay Lantern cedar guard", aa, bb, width, tint, collide=True))
        intervals = max(1, ceil(dist(a, b) / 4.2))
        for i in range(intervals + 1):
            x, y, z = mix(a, b, i / intervals)
            key = round(x, 3), round(z, 3)
            if key in posts:
                continue
            posts.add(key)
            box("Clay Lantern rail post", (x, y + .73, z), (.29, 1.53, .29), "805045", cedar, collide=True)
            box("Clay Lantern rail cap", (x, y + 1.51, z), (.36, .10, .36), "C39061", brass)

    for i, (a, b) in enumerate(zip(path, path[1:])):
        deck_start = len(walk)
        w0, e0, e1, w1 = ((x, y - .16, z) for x, y, z in (west[i], east[i], east[i+1], west[i+1]))
        for face, tint in (((w0, e0, e1), "AC8D7F"), ((w0, e1, w1), "BA9A86")):
            triangle(walk, *face, tint, name="Clay Lantern graded paving", thickness=.32,
                     material=limestone, collide=True, shadow=False)
        for slab in list(walk)[deck_start:]:
            prop(slab, "string", variant_field, stone_variant)

        if i in (0, len(path) - 2):
            continue
        for side, edge in ((-1, west), (1, east)):
            p, q = edge[i], edge[i+1]
            pp, qq = ((x, y - .31, z) for x, y, z in (p, q))
            finish(beam(walk, "Copper-brown ramp fascia", pp, qq, .38, "77574D"))
            if i != 6 or side < 0:
                rail(p, q)
        if i in (2, 3, 5, 6, 8, 9):
            x, y, z = mix(a, b, .52)
            height = y + 3.95
            box("Ocher stone ramp pier", (x, y - .46 - height/2, z),
                (1.44, height, 1.48), "887070", slate)
            box("Slate pier capital", (x, y - .55, z), (2.03, .31, 1.82), "9E8480", slate)
            box("Caramel timber bearing", (x, y - .37, z), (4.86, .27, .96), "7E5042", cedar)

    box("Clay Lantern lookout porch", point(29.50, 24.58, LEVEL - .23),
        (6.90, .46, 9.72), "B39886", limestone, collide=True)
    box("Lookout joining threshold", point(30.33, 20.94, LEVEL - .184),
        (1.46, .40, 5.58), "BF9E87", limestone, collide=True)
    for a, b in (
        ((24.70, 21.16), (24.70, 27.88)), ((34.30, 21.16), (34.30, 27.88)),
        ((24.70, 27.88), (34.30, 27.88)), ((24.70, 21.16), (27.54, 21.16)),
        ((33.13, 21.16), (34.30, 21.16)),
    ):
        rail(point(*a, LEVEL), point(*b, LEVEL))
    for distance in (25.55, 33.42):
        height = LEVEL + 4.16
        box("Lookout slate tower footing", point(distance, 26.54, LEVEL - .55 - height / 2),
            (1.72, height, 1.65), "796771", slate)
        box("Lookout sandstone bearing", point(distance, 26.54, LEVEL - .54),
            (2.05, .34, 1.98), "A18681", limestone)

    for begin, finish_at in ((0, ROAD_OPENINGS[0][0]), (ROAD_OPENINGS[0][1], ROAD_OPENINGS[1][0]),
                             (ROAD_OPENINGS[1][1], length)):
        a = point(begin, 6, road_level(begin) + 1.05)
        b = point(finish_at, 6, road_level(finish_at) + 1.05)
        finish(beam(walk, "Cinder road seaward rail", a, b, .20, "4B3535", collide=True))

    for distance, direction in ((HARBOR_JOIN, -1), (CINDER_JOIN, 1)):
        marker = distance + direction * 4.0
        base = road_level(marker)
        x, y, z = point(marker, 6.65, base)
        box("Clay Lantern trail marker post", (x, y + 1.54, z), (.34, 3.09, .34), "744D3C", cedar)
        box("Trail marker slate shoe", (x, y + .22, z), (.71, .44, .73), "937B78", slate)
        marker_yaw = yaw + (142 if direction < 0 else 42)
        sign(walk, "CLAY LANTERN  →" if direction < 0 else "←  CLAY LANTERN",
             x, y + 2.70, z, 5.37, .90, marker_yaw, "814C3D",
             reverse_label="CLAY LANTERN")

    build_clay_lantern_shelter(walk, point=point, level=LEVEL, yaw=yaw,
                               item=item, prop=prop, part=part, beam=beam, swept_roof=swept_roof,
                               festival_lantern=festival_lantern, sign=sign, garden_prop=garden_prop,
                               vector=vector, asset=asset,
                               cedar=cedar, slate=slate, limestone=limestone, brass=brass,
                               cedar_variant=cedar_variant, stone_variant=stone_variant, variant_field=variant_field)
