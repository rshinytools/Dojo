"""Frostglass's upper lookout link between Meltwater View and Mistline Vista."""

from math import atan2, ceil, degrees, dist, hypot


NAME = "Glacier Lantern Walk"
WIDTH = 5.72
CROWN = (-142.40, 28.90, -198.10)
PAVILION_BOUNDS = (-149.00, -135.80, -204.20, -192.65)
BALCONY_JOIN = (-164.02, 21.546, -174.61)
VISTA_JOIN = (-128.42, 19.657, -155.08)
# Adjacent original guardrails stay in place. These are their exposed ends.
BALCONY_GUARDS = ((-162.43, 21.53, -176.87), (-162.43, 21.53, -172.34))
VISTA_GUARDS = ((-125.31, 19.657, -157.81), (-125.31, 19.657, -152.35))
ASCENT = (
    (-162.65, 21.546, -174.61), (-161.40, 21.546, -174.61), (-159.80, 22.04, -171.90),
    (-158.90, 22.62, -169.45), (-155.70, 23.64, -165.70), (-150.95, 24.72, -166.28),
    (-145.90, 26.18, -172.30), (-143.30, 27.88, -181.75), (-142.40, 28.90, -190.93),
    (-142.40, 28.90, -193.90),
)
DESCENT = (
    (-137.15, 28.90, -198.10), (-135.80, 28.90, -198.10), (-130.00, 28.90, -198.10),
    (-122.40, 28.90, -195.97), (-116.75, 28.30, -189.25), (-112.70, 26.15, -180.35),
    (-112.57, 22.50, -167.10), (-115.95, 20.50, -157.60), (-121.68, 19.657, -155.08),
    (-125.48, 19.657, -155.08),
)
PATH = (*ASCENT, CROWN, *DESCENT)
WALK_POINTS = (BALCONY_JOIN, *PATH, VISTA_JOIN)


def build_frostglass_glacier_walk(
        town, *, item, prop, part, beam, triangle, path_edge, sign, swept_roof,
        festival_lantern, garden_shelf, garden_prop, slate, limestone, cedar,
        grass, brass, paving_variant, variant_field):
    walk = item(town, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)

    def lift(point, height):
        return point[0], point[1] + height, point[2]

    def between(a, b, fraction):
        return tuple(u + (v - u) * fraction for u, v in zip(a, b))

    def detail(parent, name, point, size, tint, material, **options):
        node = part(parent, name, point, size, tint, material=material, collide=False, **options)
        prop(node, "bool", "CastShadow", False)
        return node

    def guard(parent, start, finish, posts=True):
        length = dist(start, finish)
        if length < .08:
            return
        for height, gauge, tint in ((.56, .21, "506776"), (1.37, .23, "536F84")):
            beam(parent, "Glacier Walk blue cedar rail", lift(start, height), lift(finish, height),
                 gauge, tint, collide=True)
        if posts:
            count = max(1, ceil(length / 3.6))
            for index in range(count):
                post = between(start, finish, (index + .38) / count)
                detail(parent, "Glacier Walk frost-blue newel", lift(post, .72), (.33, 1.48, .35),
                       "647F8F", cedar)
                detail(parent, "Glacier Walk copper newel cap", lift(post, 1.44), (.43, .15, .45),
                       "BD9371", brass)

    for chain, label in ((ASCENT, "Meltwater climb"), (DESCENT, "Mistline Vista return")):
        run = item(walk, "Model", label)
        edges = [path_edge(chain, side * WIDTH / 2) for side in (-1, 1)]
        if chain is ASCENT:
            for edge, (_, _, z) in zip(edges, reversed(BALCONY_GUARDS)):
                edge[0] = (chain[0][0], chain[0][1], z + (.08 if z > chain[0][2] else -.08))
        for index, (a, b, c, d) in enumerate(zip(edges[0], edges[0][1:], edges[1][1:], edges[1])):
            corners = tuple(lift(point, -.21) for point in (a, b, c, d))
            first = len(run)
            for face, tint in (((0, 1, 2), "ABB8C2"), ((0, 2, 3), "B4BEC9")):
                triangle(run, *(corners[i] for i in face), tint, name="Glacier Walk slate deck",
                         material=limestone, collide=True, shadow=False, thickness=.42)
            for piece in run[first:]:
                prop(piece, "string", variant_field, paving_variant)
            for row in range(1, max(1, round(dist(a, b) / 2.3))):
                t = row / round(dist(a, b) / 2.3)
                joint = beam(run, "Glacier Walk recessed stone joint",
                             lift(between(a,b,t), .012), lift(between(d,c,t), .012),
                             .028, ("8095A7", "91A2AE")[(index + row) % 2])
                prop(joint, "bool", "CastShadow", False)

        for side in (-1, 1):
            guides = path_edge(chain, side * (WIDTH / 2 - .14))
            if chain is ASCENT:
                guides[0] = BALCONY_GUARDS[0 if side == 1 else 1]
            else:
                # The Vista approach runs west. Its positive edge faces south.
                guides[-1] = VISTA_GUARDS[1 if side == 1 else 0]
            for index, (start, finish) in enumerate(zip(guides, guides[1:])):
                if chain is ASCENT and index == len(guides) - 2:
                    finish = between(start, finish, (PAVILION_BOUNDS[3] - start[2]) /
                                     (finish[2] - start[2]))
                if chain is DESCENT and index == 0:
                    continue
                guard(run, start, finish)
                fascia = beam(run, "Glacier Walk blue slate fascia", lift(start, -.30),
                              lift(finish, -.30), .36, "758999")
                prop(fascia, "bool", "CastShadow", False)

    cx, top, cz = CROWN
    west, east, north, south = PAVILION_BOUNDS
    pavilion = item(walk, "Model", "Glacier Lantern Pavilion")
    prop(pavilion, "token", "LevelOfDetail", 4)
    deck = part(pavilion, "Glacier Lantern floor", ((west + east) / 2, top - .25, (north + south) / 2),
                (east - west, .50, south - north), "BDC9D2", material=limestone)
    prop(deck, "string", variant_field, paving_variant)
    for u, v in (
        ((west+.14, north+.14), (east-.14, north+.14)),
        ((west+.14, north+.14), (west+.14, south-.14)),
        ((west+.14, south), (cx-2.72, south)), ((cx+2.72, south), (east-.14, south)),
        ((east, north+.14), (east, cz-2.72)), ((east, cz+2.72), (east, south-.14)),
    ):
        start, finish = (u[0], top, u[1]), (v[0], top, v[1])
        guard(pavilion, start, finish)
        beam(pavilion, "Glacier pavilion dressed sill", lift(start, -.32), lift(finish, -.32),
             .47, "8297A6")

    # Place slender piers clear of the lower Mistline roadway and its gate.
    supports = (
        (-159.1, 21.12, -171.10, 12.5), (-155.87, 23.04, -165.26, 11.34),
        (-149.27, 24.66, -169.08, 0.15), (-144.40, 26.07, -175.20, -4.4),
        (-141.91, 28.20, -188.30, -4.4), (-145.84, top-.58, -194.93, -4.4),
        (-139.03, top-.58, -194.93, -4.4), (-145.84, top-.58, -201.10, -4.4),
        (-139.03, top-.58, -201.10, -4.4), (-130.96, top-.54, -198.54, -4.4),
        (-121.28, 28.04, -194.19, -4.4), (-113.14, 26.55, -185.10, -4.4),
        (-111.85, 23.51, -172.81, -4.4), (-115.85, 19.91, -159.20, -4.4),
    )
    for index, (x, cap, z, foot) in enumerate(supports):
        height = cap - foot
        detail(walk, "Glacier Walk quarried slate pier", (x, foot + height * .5, z),
               (2.05, height, 2.19), "788499", slate)
        detail(walk, "Glacier Walk dressed bearing", (x, cap + .04, z),
               (2.64, .40, 2.71), "99ACBA", slate)
        for fraction in (.19, .47, .75, .93):
            detail(walk, "Glacier Walk slate string course", (x, foot + height * fraction, z),
                   (2.21, .18, 2.36), "8B9EAB", slate)
        if index in (2, 5, 8, 10, 12):
            garden_shelf(walk, x - .45, foot + 1.14, z, 5.12, 4.2, 1.48,
                         "838C9D", slate, collide=False)
            garden_shelf(walk, x - .62, foot + 1.22, z, 4.45, 3.78, .22,
                         "879688", grass, collide=False)
            garden_prop(walk, "bankRock", (x-1.7, foot+1.19, z-.24),
                        .26, 37 + index * 23, "9BA6B2")
            garden_prop(walk, "meadowCover", (x-1.54, foot+1.25, z+.56),
                        .18, 49 + index * 27, "B5BEA6")

    for px in (cx - 4.93, cx + 4.93):
        for z in (cz - 3.89, cz + 3.89):
            detail(pavilion, "Glacier granite column shoe", (px, top + .32, z),
                   (1.17, .64, 1.15), "97A9B6", slate)
            detail(pavilion, "Glacier Lantern blue cedar column", (px, top + 3.56, z),
                   (.72, 6.47, .73), "476C7F", cedar)
            for y in (top + .98, top + 6.42):
                detail(pavilion, "Glacier Lantern copper column band", (px, y, z),
                       (.83, .18, .84), "C49772", brass)
            festival_lantern(pavilion, px, top + 5.57, z + .72, .71, light=False,
                             tint="FFD4A4", entrance_paper=True)
        beam(pavilion, "Glacier pavilion cedar side lintel", (px, top + 6.74, cz-4.14),
             (px, top + 6.74, cz+4.14), .54, "5E7691")
    for z in (cz-3.89, cz+3.89):
        beam(pavilion, "Glacier pavilion cedar lintel", (cx-5.32, top+6.75, z),
             (cx+5.32, top+6.75, z), .62, "536E86")
        for side in (-1, 1):
            beam(pavilion, "Glacier pavilion diagonal corbel", (cx+side*4.91, top+5.64,z),
                 (cx+side*3.46, top+6.71,z), .42, "6B8399")
    swept_roof(pavilion, cx, top+6.96, cz, 13.56, 10.39, 3.10,
               fine_tiles=False, signature=True, corner_sweep=1.22)
    sign(pavilion, "GLACIER LANTERN", cx, top+6.22, cz+4.18, 7.52, .97, 0, "486D80")

    seat = part(pavilion, "Glacier Lantern bench", (cx, top+.63, north+1.18),
                (3.84, .27, 1.01), "AA826F", material=cedar, class_name="Seat")
    seat.find("Properties/bool[@name='CanTouch']").text = "true"
    detail(pavilion, "Glacier Lantern cedar bench back", (cx, top+1.13, north+.70),
           (3.94, .65, .18), "876F70", cedar)
    for x in (cx-1.43,cx+1.43):
        detail(pavilion, "Glacier Lantern granite bench foot", (x, top+.27, north+1.18),
               (.55, .51, .77), "91A4B0", slate)
    for k, (x, z) in enumerate(((west+1.32,south-1.25), (east-1.39,north+1.45))):
        garden_shelf(pavilion, x, top+.39, z, 1.92, 1.80, .42, "9AAEB7", slate, collide=False)
        garden_shelf(pavilion, x, top+.45, z, 1.69, 1.55, .14, "91A591", grass, collide=False)
        garden_prop(pavilion, "meadowCover", (x-.20, top+.47, z+.22), .14, 45 + k * 36, "B9C9B8")
        garden_prop(pavilion, "mossFlowers", (x+.17, top+.48, z-.17), .19, 71 + k * 38, "D5CDEA")

    beam(walk, "Glacier Walk wayfinding support", (-161.03, 21.21, -176.67),
         (-160.40, 21.44, -178.18), .44, "74889C")
    for x, y, z, yaw, title in (
        (-160.40, 21.65, -178.18, -90, "GLACIER LANTERN  ↑"),
        (-128.24, 19.657, -150.54, -90, "GLACIER LANTERN  ↑"),
        (-136.10, top, -202.70, 90, "MISTLINE VISTA  ↓"),
    ):
        detail(walk, "Glacier Walk wayfinding stone foot", (x, y+.24, z), (.86, .48, .80),
               "9AAAB5", slate)
        detail(walk, "Glacier Walk wayfinding cedar post", (x, y+1.39, z), (.28, 2.76, .28),
               "658092", cedar)
        sign(walk, title, x, y+2.70, z, 5.52, .96, yaw, "486D80")

    bounds = item(walk, "Folder", "Glacier Lantern Walk location bounds")
    main_approach = (between(ASCENT[0], ASCENT[1], .65), *ASCENT[1:])
    main_return = (*DESCENT[:-1], between(DESCENT[-2], DESCENT[-1], .75))
    for chain in (main_approach, main_return):
        for start, finish in zip(chain, chain[1:]):
            dx, dy, dz = (v-u for u,v in zip(start, finish))
            part(bounds, "Glacier Lantern Walk route bounds", lift(between(start, finish, .5), 3.74),
                 (WIDTH+.26, 6.62, dist(start,finish)+.42), "FFFFFF",
                 yaw=degrees(atan2(dx,dz)), pitch=-degrees(atan2(dy,hypot(dx,dz))),
                 collide=False, transparency=1)
