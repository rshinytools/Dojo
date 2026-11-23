"""The rising walking trail and covered lookout outside Grand Dojo's South Gate."""


TRAIL = (
    (2.6, .55, 106.9),
    (2.6, .60, 115.4),
    (6.5, 1.55, 124.4),
    (9.8, 3.55, 133.7),
    (8.5, 5.65, 141.2),
    (3.8, 7.8, 150.7),
    (-.2, 10.4, 158.7),
    (-.2, 12.0, 166.4),
)

LOOKOUT_X = -.2
LOOKOUT_Y = 12.0
LOOKOUT_Z = 176.4


def build_south_ridge_trail(parent, *, item, prop, part, beam, path_edge,
                            triangle, sign, swept_roof, festival_lantern, garden_shelf,
                            garden_prop, tree, slate, limestone, cedar, grass, brass, rock):
    trail = item(parent, "Model", "South Ridge Trail")
    prop(trail, "token", "ModelStreamingMode", 1)
    part(trail, "South Ridge location bounds", (2.0, 7.5, 138.0), (34, 17, 61.6),
         "FFFFFF", collide=False, transparency=1)
    # Both pavement edges share the same mitered joints as the adjoining banks.
    # This keeps the walkable surface continuous through the changes of heading.
    left = path_edge(TRAIL, -5.12)
    right = path_edge(TRAIL, 5.12)
    for a, b, c, d in zip(left, left[1:], right, right[1:]):
        for face in ((a, c, b), (b, c, d)):
            underside = [(x, y - .255, z) for x, y, z in face]
            triangle(trail, *underside, "AE9080", name="South Ridge trail paving",
                     material=limestone, thickness=.50, collide=True)

    def block(parent, name, position, size, tint, material, *, collision=False):
        return part(parent, name, position, size, tint, material=material, collide=collision)

    def railing(parent, points):
        for (x, y, z) in points:
            block(parent, "Cedar railing post", (x, y + 1.30, z), (.37, 2.67, .37),
                  "765043", cedar, collision=True)
            block(parent, "Brass railing cap", (x, y + 2.66, z), (.49, .15, .49), "B2895F", brass)
        for start, end in zip(points, points[1:]):
            for lift in (1.06, 2.14):
                a = (start[0], start[1] + lift, start[2])
                b = (end[0], end[1] + lift, end[2])
                beam(parent, "Cedar guard rail", a, b, .27, "865549", collide=True)

    for side in (-1, 1):
        inner = path_edge(TRAIL, 5.00 * side)
        shoulder = path_edge(TRAIL, 8.4 * side)
        footing = path_edge(TRAIL, 14.4 * side)
        # Follow the grade beside the road so the banks read as cut rock from below.
        ribbons = [inner, [(x, y - .47, z) for x, y, z in shoulder],
                   [(x, -4.5 + (i % 3) * .40, z) for i, (x, _, z) in enumerate(footing)]]
        for band, (high, low) in enumerate(zip(ribbons, ribbons[1:])):
            for i, (a, b, c, d) in enumerate(zip(high, high[1:], low, low[1:])):
                tones = (("7E8455", "879259", "71825D"), ("7C6F77", "98807B", "8F7B83"))[band]
                material = grass if band == 0 else rock
                for face, tint in (((a, c, b), tones[i % 3]), ((b, c, d), tones[(i + 1) % 3])):
                    triangle(trail, *face, tint, name="South Ridge planted bank" if band == 0 else
                             "South Ridge exposed rock", material=material, thickness=.22)
        guard = [*inner[1:-1], (LOOKOUT_X + side * 5, LOOKOUT_Y, 166.35)]
        railing(trail, guard)

    # These near banks break up the square grass edge seen through the city gate.
    gardens = item(trail, "Folder", "Roadside planting")
    for index, (x, y, z, width, depth) in enumerate((
        (-11.5, .42, 115.2, 13.8, 11.4), (17.2, .68, 117.4, 13.4, 11.9),
        (-7.0, 1.14, 125.0, 10.2, 10.1), (24.0, 2.35, 131.8, 12.1, 12.9),
        (-4.4, 4.7, 140.5, 9.8, 8.7), (21.2, 4.85, 143.4, 10.5, 9.7),
        (-9.4, 7.5, 150.5, 9.4, 9.6), (13.3, 8.4, 155.1, 8.4, 9.1),
    )):
        garden_shelf(gardens, x, y, z, width, depth, max(1.1, y + .6), "8F7D81", slate, collide=False)
        garden_shelf(gardens, x, y + .07, z, width * .92, depth * .91, .34,
                     "798854", grass, collide=False)
        for offset, (key, fx, fz, scale, tint) in enumerate((
            ("bankRock", -.23, .08, .64, "9C8785"), ("bankRock", .17, .25, .40, "A38C8A"),
            ("rockVine", -.15, -.22, .45, "7E9658"), ("meadowCover", .26, -.22, .32, "849D59"),
            ("meadowFlowers", .06, -.18, .55, "E8B783"), ("mossFlowers", -.30, .22, .38, "D998AA"),
        )):
            garden_prop(gardens, key, (x + width * fx, y + .04, z + depth * fz), scale,
                        index * 43 + offset * 29, tint)

    # Ground-level trees frame the first bend without covering either sign face.
    tree(gardens, -17, 111.8, True, scale=.92)
    tree(gardens, 22, 112.4, False, scale=1.05)
    tree(gardens, -24, 124.0, False, scale=1.12)
    for x, sign_y, z, label, yaw, width in (
        (-4.8, .28, 110.8, "SOUTH RIDGE LOOKOUT", 180, 6.35),
        (7.6, 12, 168.3, "SOUTH GATE", 0, 4.8),
    ):
        block(trail, "Trail sign post", (x, sign_y + 1.78, z), (.30, 3.56, .30), "815044", cedar)
        sign(trail, label, x, sign_y + 3.27, z, width, 1.13, yaw, "69483F")
        festival_lantern(trail, x, sign_y + 2.35, z + .22, .38, light=False)

    lookout = item(trail, "Model", "South Ridge Lookout")
    x, y, z = LOOKOUT_X, LOOKOUT_Y, LOOKOUT_Z
    block(lookout, "Lookout slate foundation", (x, y - 5.7, 174.2), (18.2, 10.7, 17.3),
          "80717A", slate)
    block(lookout, "Lookout stone floor", (x, y - .28, 174.975), (21, .56, 17.25),
          "AC958C", limestone, collision=True)
    for side in (-1, 1):
        railing(lookout, [(x + side * sx, y, zz) for sx, zz in
                          ((5, 166.35), (10.25, 166.35), (10.25, 172.0), (10.25, 183.35))])
    railing(lookout, [(x - 10.25, y, 183.35), (x, y, 183.35), (x + 10.25, y, 183.35)])
    for side in (-1, 1):
        for far in (-1, 1):
            px, pz = x + side * 5.75, z + far * 3.35
            block(lookout, "Lookout pillar plinth", (px, y + .47, pz), (1.42, .94, 1.42), "97818D", slate)
            block(lookout, "Vermilion lookout pillar", (px, y + 3.5, pz), (.93, 6.3, .95),
                  "9E4B37", cedar, collision=True)
            block(lookout, "Gilt pillar collar", (px, y + 5.9, pz), (1.13, .20, 1.13), "C69759", brass)
            festival_lantern(lookout, px, y + 5.55, pz + far * 1.08, .43, light=False)
    for face in (-1, 1):
        block(lookout, "Lookout pavilion crossbeam", (x, y + 6.35, z + face * 3.35),
              (12.5, .58, .85), "884432", cedar)
    swept_roof(lookout, x, y + 6.65, z, 16.6, 10.7, 2.6, fine_tiles=False, corner_sweep=.84)
    sign(lookout, "SOUTH RIDGE LOOKOUT", x, y + 5.92, z - 3.8, 8.2, 1.18, 180, "754139")
    for side in (-1, 1):
        sx = x + side * 7.85
        block(lookout, "Lookout bench", (sx, y + .83, z + .7), (1.54, .24, 3.28),
              "9E6748", cedar, collision=True)
        for offset in (-1.04, 1.04):
            block(lookout, "Bench slate base", (sx, y + .38, z + .7 + offset),
                  (1.18, .75, .37), "8F7984", slate)
