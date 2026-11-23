"""Stair-free route from Cedarbank Rise to Tideharbor's Saltwind Lookout."""

from math import atan2, ceil, degrees, hypot


NAME = "Saltwind High Walk"
WIDTH = 5.30
CEDARBANK_OPENING = (71.99, 77.01)
SALTWIND_OPENING = (44.07, 49.13)
POINTS = (
    (100.20, 5.79, 74.50),
    (104.45, 6.99, 74.50),
    (110.40, 10.03, 65.70),
    (117.20, 11.25, 59.90),
    (125.00, 12.60, 55.10),
    (135.00, 13.15, 51.40),
    (144.00, 11.53, 46.60),
    (151.30, 9.56, 46.60),
    (153.05, 9.56, 46.60),
)
PAVING = "Saltwind walking stone"


def build_saltwind_high_walk(parent, *, item, prop, part, beam, triangle, path_edge,
                             sign, festival_lantern, garden_shelf, garden_prop,
                             stone, slate, cedar, brass, grass, stone_variant, variant_field):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)
    edges = [path_edge(POINTS, offset) for offset in (-WIDTH / 2, WIDTH / 2)]
    stone_colors = ("BAA498", "AF998F", "B4A39C")
    rail_edge = [path_edge(POINTS, offset) for offset in (-2.51, 2.51)]
    posts = item(walk, "Folder", "Rail posts")

    def slab(group, label, point, extent, tint, material, *, yaw=0):
        piece = part(group, label, point, extent, tint, material=material,
                     yaw=yaw, collide=False)
        prop(piece, "bool", "CastShadow", False)
        return piece

    for index, (a, b) in enumerate(zip(POINTS, POINTS[1:])):
        left, right = edges
        u, v, w, q = ((x, y - .18, z) for x, y, z in
                      (left[index], right[index], right[index + 1], left[index + 1]))
        first = len(walk)
        triangle(walk, u, v, w, stone_colors[index % 3], name=PAVING,
                 thickness=.36, material=stone, collide=True)
        triangle(walk, u, w, q, stone_colors[(index + 1) % 3], name=PAVING,
                 thickness=.36, material=stone, collide=True)
        for piece in list(walk)[first:]:
            prop(piece, "string", variant_field, stone_variant)
        for edge in rail_edge:
            if index in (0, len(POINTS) - 2):
                continue  # Each endpoint overlaps an already railed terrace.
            rail_a, rail_b = edge[index:index + 2]
            for rise, thickness in ((.57, .19), (1.43, .24)):
                beam(walk, "Teal cedar handrail",
                     (rail_a[0], rail_a[1] + rise, rail_a[2]),
                     (rail_b[0], rail_b[1] + rise, rail_b[2]), thickness,
                     "456B68", collide=True)
            beam(walk, "Weathered bridge fascia",
                 (rail_a[0], rail_a[1] - .44, rail_a[2]),
                 (rail_b[0], rail_b[1] - .44, rail_b[2]), .51, "766F79")
            length = hypot(rail_b[0] - rail_a[0], rail_b[2] - rail_a[2])
            count = max(1, ceil(length / 3.05))
            for bay in range(count):
                t = (bay + .5) / count
                x, y, z = (p + (q - p) * t for p, q in zip(rail_a, rail_b))
                slab(posts, "Lacquered cedar newel", (x, y + .70, z),
                     (.28, 1.48, .28), "416462", cedar)
                slab(posts, "Brass newel cap", (x, y + 1.47, z),
                     (.41, .13, .41), "BC9161", brass)
        if index not in (2, 3, 4, 5, 6):
            continue
        # Individual masonry piers leave the foothill silhouette visible between spans.
        x, y, z = (p + (q - p) * .49 for p, q in zip(a, b))
        yaw = degrees(atan2(b[0] - a[0], b[2] - a[2]))
        foot = (-1, -1.70, 1.40, 1.90, -1.80)[index - 2]
        top = y - .68
        support = item(walk, "Model", "Stepped slate pier")
        slab(support, "Slate pier base", (x, foot + .45, z),
             (4.18, 1.50, 3.44), "7B7279", slate, yaw=yaw)
        slab(support, "Dressed stone shaft", (x, (foot + top) / 2, z),
             (2.76, top - foot, 2.45), "8C7E84", slate, yaw=yaw)
        for course in range(1, max(2, int((top - foot) / 1.58))):
            slab(support, "Pier masonry course", (x, foot + 1.58 * course, z),
                 (2.81, .090, 2.50), "998A89", slate, yaw=yaw)
        slab(support, "Broad sandstone cap", (x, top - .14, z),
             (4.56, .66, 2.66), "A7928F", stone, yaw=yaw)

    for index, (point_index, side) in enumerate(((1, 0), (3, 0), (4, 1), (5, 0), (6, 1), (7, 1))):
        x, y, z = rail_edge[side][point_index]
        slab(walk, "Lantern stone foot", (x, y + .31, z),
             (.65, .63, .63), "9D8B8D", slate)
        slab(walk, "Lantern cedar riser", (x, y + 1.00, z),
             (.22, 1.40, .22), "653F35", cedar)
        festival_lantern(walk, x, y + 1.84, z, .49, light=False,
                         tint=("FFCB83", "FFD995")[index % 2])
    for label, x, y, z, yaw in (
        ("SALTWIND HIGH WALK", 102.36, 5.78, 77.90, 180),
        ("TIDEHARBOR  →", 134.72, 13.15, 54.82, 0),
        ("GRAND DOJO  →", 153.80, 9.55, 43.22, 0),
    ):
        slab(walk, "Wayfinding cedar post", (x, y + 1.34, z),
             (.26, 2.7, .28), "674938", cedar)
        sign(walk, label, x, y + 2.44, z, 4.90, .94, yaw=yaw, tint="3B6866")
    slab(walk, "Wayfinding cedar bracket", (134.72, 12.98, 54.28),
         (.40, .29, 1.5), "674938", cedar)
    for index, (x, y, z, w, depth) in enumerate((
        (116.6, 3.1, 54.5, 5.5, 3.8),
        (122.6, 2.0, 53.2, 6.2, 4.15),
        (129.0, 2.3, 54.8, 6.7, 4.4),
        (138.2, 2.0, 50.5, 6.6, 4.5),
        (143.8, .7, 44.9, 7.4, 5.0),
    )):
        garden_shelf(walk, x, y, z, w, depth, 2.65, "85777B", slate, collide=False)
        garden_shelf(walk, x, y + .16, z, w * .78, depth * .79, .28,
                     "838255", grass, collide=False)
        garden_prop(walk, "bankRock", (x - .81, y + .05, z + .20), .24, 44 + 38 * index, "9D8F8D")
        garden_prop(walk, "meadowCover", (x + 1.17, y + .13, z + .26), .22, 18 + 69 * index, "A5AF74")
        garden_prop(walk, "mossFlowers", (x + .63, y + .14, z - .81), .16, 55 + 46 * index, "DEA9B4")
