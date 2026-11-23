"""A covered cedar walk on the south shoulder of the Lantern Circuit road."""

from math import ceil, cos, dist, radians, sin


NAME = "Plum Lantern Walk"
DECK_HEIGHT = 6.68
PATH = (
    (-92.00, .16, 27.38), (-92.00, .19, 32.62), (-96.00, .70, 37.40),
    (-103.00, 2.72, 41.60), (-112.00, 5.28, 44.40), (-117.00, DECK_HEIGHT, 45.20),
    (-126.00, DECK_HEIGHT, 44.70), (-132.00, 5.42, 41.50),
    (-137.10, 3.88, 37.55), (-138.80, 2.29, 32.20), (-138.80, 1.90, 28.00),
)
WIDTH = 5.85


def between(a, b, t):
    return tuple(u + (v - u) * t for u, v in zip(a, b))


def build_plum_lantern_walk(parent, *, item, prop, part, triangle, beam, path_edge, sign,
                            swept_roof, festival_lantern, garden_shelf, garden_prop,
                            showcase_tree, cedar, slate, stone, brass, grass,
                            variant_field, cedar_variant, stone_variant):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)
    grade = item(walk, "Folder", "Cedar ramps and deck")
    timber = item(walk, "Folder", "Plum Walk millwork")
    plantings = item(walk, "Folder", "Planted slate terraces")

    def finish(node, variant=None):
        prop(node, "bool", "CastShadow", False)
        if variant:
            prop(node, "string", variant_field, variant)

    def piece(scope, label, position, size, tint, material, *, collide=False):
        node = part(scope, label, position, size, tint, material=material, collide=collide)
        finish(node, cedar_variant if material == cedar else stone_variant if material == stone else None)

    def lay_quad(scope, label, a, b, c, d, tint, *, thickness, sunk=0, visible=True):
        start = len(scope)
        for face in ((a, b, c), (b, d, c)):
            points = [(x, y - sunk, z) for x, y, z in face]
            triangle(scope, *points, tint, name=label, thickness=thickness, material=cedar,
                     collide=not visible, transparency=0 if visible else 1, shadow=False)
        if visible:
            for face in list(scope)[start:]:
                prop(face, "string", variant_field, cedar_variant)

    rail_posts = set()

    def rail(a, b):
        for lift, gauge, tint in ((.48, .15, "80463D"), (1.55, .23, "B16848")):
            finish(beam(timber, "Plum Walk cedar guardrail", (a[0], a[1] + lift, a[2]),
                        (b[0], b[1] + lift, b[2]), gauge, tint, collide=True))
        count = ceil(dist(a, b) / 3.75)
        for i in range(count + 1):
            x, y, z = between(a, b, i / count)
            key = round(x, 3), round(z, 3)
            if key in rail_posts:
                continue
            rail_posts.add(key)
            piece(timber, "Lacquered rail post", (x, y + .79, z), (.25, 1.65, .25),
                  "924930", cedar, collide=True)
            piece(timber, "Rail post brass cap", (x, y + 1.63, z), (.34, .10, .34), "CE9B56", brass)

    left, right = (path_edge(PATH, side * WIDTH / 2) for side in (-1, 1))
    # Match the old road grade across the entire width of the western join.
    for edge in (left, right):
        x, _, z = edge[-1]
        fraction = ((x + 117) * -37 - (z - 27)) / 1370
        edge[-1] = x, .182 + 2.95 * fraction, z

    for index, (a, b, c, d) in enumerate(zip(left, right, left[1:], right[1:])):
        lay_quad(grade, "Plum Walk ramp support", a, b, c, d, "956756",
                 thickness=.32, sunk=.16, visible=False)
        planks = max(1, ceil(dist(PATH[index], PATH[index + 1]) / 1.06))
        for plank in range(planks):
            t0 = (plank + .016) / planks
            t1 = (plank + .984) / planks
            lay_quad(grade, "Caramel cedar decking", between(a, c, t0), between(b, d, t0),
                     between(a, c, t1), between(b, d, t1),
                     ("A87452", "BC875E", "B28056", "A67558")[(index + plank) % 4], thickness=.038, sunk=.016)
        for edge, p, q in ((left, a, c), (right, b, d)):
            fascia = beam(timber, "Cedar deck edge", (p[0], p[1] - .27, p[2]),
                          (q[0], q[1] - .27, q[2]), .43, "794433")
            finish(fascia)
            # The south rail opens on the pavilion's viewing porch.
            if 1 <= index <= 8 and not (index == 5 and edge is right):
                start = between(p, q, .29) if index == 1 else p
                end = between(p, q, .75) if index == 8 else q
                rail(start, end)

    cx, cz = -121.5, 46.65
    porch = item(walk, "Model", "Plum Lantern Pavilion")
    # Overlap the walk so the porch has a level entrance along its north edge.
    piece(porch, "Plum Lantern viewing porch", (cx, DECK_HEIGHT - .17, 47.4),
          (9.04, .34, 7.0), "B58060", cedar, collide=True)
    for x in (-125.98, -117.02):
        rail((x, DECK_HEIGHT, 47.9), (x, DECK_HEIGHT, 50.83))
        for z in (42.28, 50.54):
            piece(porch, "Pavilion column stone shoe", (x, DECK_HEIGHT + .28, z),
                  (1.0, .56, 1.0), "8C7580", stone)
            piece(porch, "Pavilion lacquer column", (x, DECK_HEIGHT + 2.87, z),
                  (.64, 5.46, .64), "A44631", cedar)
            piece(porch, "Pavilion brass column collar", (x, DECK_HEIGHT + 4.88, z),
                  (.76, .19, .76), "CB9351", brass)
            finish(beam(porch, "Cedar pavilion bracket", (x, DECK_HEIGHT + 4.09, z),
                        (x + (.95 if x < cx else -.95), DECK_HEIGHT + 5.30, z), .26, "8B4B34"))
    rail((-125.98, DECK_HEIGHT, 50.83), (-117.02, DECK_HEIGHT, 50.83))
    for z in (42.28, 50.54):
        piece(porch, "Painted pavilion crossbeam", (cx, DECK_HEIGHT + 5.38, z),
              (10.18, .42, .52), "8C4736", cedar)
    swept_roof(porch, cx, DECK_HEIGHT + 5.64, cz, 12.15, 10.91, 2.55,
               fine_tiles=False, signature=True, corner_sweep=1.03)
    for x, z in ((-124.34, 42.38), (-118.70, 42.38), (-123.95, 50.49), (-119.12, 50.49)):
        festival_lantern(porch, x, DECK_HEIGHT + 4.70, z, .57, light=False, tint="FFC77D")
    piece(porch, "View porch cedar seat", (cx, DECK_HEIGHT + .65, 50.25),
          (3.28, .22, .68), "89644D", cedar)

    for index, (x, y, z) in enumerate(PATH[3:-2]):
        footing_top = y - .66
        piece(timber, "Dressed slate trestle pier", (x, (footing_top - 5.38) / 2, z),
              (1.71, footing_top + 5.38, 1.58), "837280", slate)
        piece(timber, "Wide plum slate capital", (x, footing_top - .20, z),
              (3.08, .41, 2.70), "A18B87", stone)
        step_z = z + (3.72 if index % 2 else 4.37)
        for level, width, length, height, tint in ((-.85, 5.8, 4.4, 4.51, "847786"),
                                                   (.30, 4.8, 3.7, 1.32, "A38C88")):
            garden_shelf(plantings, x, level, step_z, width, length, height, tint, slate, collide=False)
        garden_shelf(plantings, x, 1.13, step_z, 4.0, 3.04, .39, "7D914E", grass, collide=False)
        for species, dx, dz, scale, tint in (
            ("bankRock", -.89, .32, .22, "A19291"), ("rockVine", -.48, .92, .17, "889D54"),
            ("meadowCover", .62, -.43, .21, "B8BE69"), ("mossFlowers", .68, .45, .15, "E5ADA9"),
            ("meadowFlowers", -.78, -.65, .26, "EEBD86"),
        ):
            garden_prop(plantings, species, (x + dx, 1.28, step_z + dz), scale, index * 47, tint)
    for x, z, top, scale, yaw in ((-112.8, 53.35, .18, .84, 45), (-129.6, 52.77, -.94, .79, 149)):
        garden_shelf(plantings, x, top - .13, z, 5.7, 4.9, top + 5.2, "8D7C83", slate, collide=False)
        garden_shelf(plantings, x, top, z, 4.8, 4.2, .23, "83934D", grass, collide=False)
        showcase_tree(plantings, x, z, True, scale, yaw, top, compact=True, relief_crown=True)

    for x, y, z, yaw in ((-96.23, .20, 32.14, 149), (-144.68, 2.43, 32.55, -141)):
        piece(timber, "Plum Walk sign footing", (x, y + .26, z), (1.35, .52, 1.15), "887684", stone)
        piece(timber, "Plum Walk sign post", (x, y + 1.78, z), (.37, 2.96, .36), "7A453D", cedar)
        sign(timber, "PLUM LANTERN WALK", x, y + 2.93, z, 5.76, 1.14, yaw, "633951", finished_back=True)
        # Both sides name the branch for players arriving from either town.
        angle = radians(yaw)
        sign(timber, "PLUM LANTERN WALK", x - .12 * sin(angle), y + 2.93,
             z - .12 * cos(angle), 5.72, 1.10, yaw + 180, "633951", face_only=True)
        festival_lantern(timber, x, y + 3.73, z, .49, light=False)

    for node in plantings:
        if node.get("class") in ("Part", "WedgePart") and node.find("Properties/bool[@name='CastShadow']") is None:
            finish(node)
