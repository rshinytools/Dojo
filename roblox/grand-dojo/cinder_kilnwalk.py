"""The elevated Cinder Terraces link between Potters' Yard and Glaze Terrace."""

from math import atan2, ceil, degrees, dist, hypot


NAME = "Copper Kiln Walk"
FLOOR = "Copper Kiln Walk sandstone deck"
PAVILION = "Copper Kiln Pavilion"
PAVILION_FLOOR = "Copper Kiln Pavilion floor"
BOUNDS = "Copper Kiln Walk location bounds"
WIDTH = 5.72
POTTERS_NORTH_RAIL_END = 4.02
GLAZE_RAIL_OPENING = (.12, .88)

YARD_JOIN = (108.48, 18.30, -217.62)
YARD_RAILS = ((109.80, 18.30, -219.95), (105.82, 18.30, -219.95))
GLAZE_JOIN = (194.85, 15.823, -189.05)
CROWN = (155.60, 27.05, -239.42)
PAVILION_BOUNDS = (148.82, 162.38, -244.96, -233.88)
ASCENT = (
    (108.48, 18.281, -219.60), (108.65, 18.36, -222.47), (112.50, 19.18, -226.12),
    (119.80, 21.00, -232.22), (128.00, 22.82, -235.42), (139.85, 24.75, -238.48),
    (146.25, 26.58, -239.42), (148.72, 27.048, -239.42), (149.76, 27.05, -239.42),
)
DESCENT = (
    (161.65, 27.05, -239.42), (164.15, 27.05, -239.42), (172.10, 26.37, -237.75),
    (180.25, 24.84, -233.80), (187.29, 22.64, -227.22), (192.36, 20.48, -217.79),
    (196.16, 18.23, -208.66), (198.26, 16.22, -200.95), (197.13, 15.823, -196.45),
    (195.05, 15.803, -194.51),
)
PATH = (*ASCENT, CROWN, *DESCENT)
WALK_POINTS = (YARD_JOIN, *PATH, (193.52, 15.823, -193.11), (194.85, 15.823, -190.82), GLAZE_JOIN)


def build_cinder_kiln_walk(
        town, *, item, prop, part, beam, triangle, path_edge, sign, swept_roof,
        festival_lantern, garden_shelf, garden_prop, slate, sandstone, cedar,
        grass, brass, sandstone_variant, variant_field):
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

    def guard(parent, start, finish):
        length = dist(start, finish)
        if length < .10:
            return
        for height, gauge, tint in ((.56, .20, "874D3C"), (1.36, .24, "985438")):
            beam(parent, "Kiln Walk copperwood guard", lift(start, height), lift(finish, height),
                 gauge, tint, collide=True)
        count = max(1, ceil(length / 3.8))
        for index in range(count):
            post = between(start, finish, (index + .40) / count)
            detail(parent, "Kiln Walk cedar newel", lift(post, .72), (.32, 1.47, .34),
                   "A76449", cedar)
            detail(parent, "Kiln Walk copper newel cap", lift(post, 1.45), (.44, .15, .46),
                   "C88955", brass)
        fascia = beam(parent, "Kiln Walk slate fascia", lift(start, -.37), lift(finish, -.37),
                      .40, "7F5958")
        prop(fascia, "bool", "CastShadow", False)

    # Exact endpoint of each rail is shared with the open side of Glaze Terrace.
    glaze_exit = ((194.85, 15.823, -188.10), (194.85, 15.823, -190.80),
                  (191.60, 15.823, -194.70), (187.60, 14.46, -194.50))
    glaze_rail = path_edge(glaze_exit, -2.73)
    glaze_mouth = tuple(between(glaze_rail[1], glaze_rail[2], t) for t in GLAZE_RAIL_OPENING)
    west, east, north, south = PAVILION_BOUNDS
    for chain, label in ((ASCENT, "Potters' climb"), (DESCENT, "Glaze Terrace return")):
        run = item(walk, "Model", label)
        edges = [path_edge(chain, side * WIDTH / 2) for side in (-1, 1)]
        if chain is ASCENT:
            for edge, end in zip(edges, YARD_RAILS):
                edge[0] = (end[0], chain[0][1], chain[0][2])
        else:
            for edge, end in zip(edges, reversed(glaze_mouth)):
                edge[-1] = (end[0] - .30, chain[-1][1], end[2] + .247)
        for section, (a, b, c, d) in enumerate(zip(edges[0], edges[0][1:], edges[1][1:], edges[1])):
            corners = tuple(lift(point, -.21) for point in (a, b, c, d))
            first = len(run)
            for face, tint in (((0, 1, 2), "BE9B7D"), ((0, 2, 3), "B79378")):
                triangle(run, *(corners[i] for i in face), tint, name=FLOOR, material=sandstone,
                         collide=True, shadow=False, thickness=.42)
            for piece in run[first:]:
                prop(piece, "string", variant_field, sandstone_variant)
            count = max(1, round(dist(a, b) / 2.2))
            for index in range(1, count):
                fraction = index / count
                joint = beam(run, "Kiln Walk recessed paving joint",
                             lift(between(a, b, fraction), .014), lift(between(d, c, fraction), .014),
                             .035, ("956F66", "A68270")[(section + index) % 2])
                prop(joint, "bool", "CastShadow", False)

        for index, side in enumerate((-1, 1)):
            guides = path_edge(chain, side * (WIDTH / 2 - .14))
            if chain is ASCENT:
                guides[0] = YARD_RAILS[index]
            else:
                guides[-1] = glaze_mouth[1 - index]
            for step, (a, b) in enumerate(zip(guides, guides[1:])):
                if chain is ASCENT and step == len(guides) - 2:
                    b = between(a, b, (west - a[0]) / (b[0] - a[0]))
                if chain is DESCENT and step == 0:
                    a = between(a, b, (east - a[0]) / (b[0] - a[0]))
                guard(run, a, b)

    cx, top, cz = CROWN
    pavilion = item(walk, "Model", PAVILION)
    prop(pavilion, "token", "LevelOfDetail", 4)
    deck = part(pavilion, PAVILION_FLOOR, ((west + east) / 2, top - .265, (north + south) / 2),
                (east - west, .53, south - north), "BC9A83", material=sandstone)
    prop(deck, "string", variant_field, sandstone_variant)
    for x in (west, east):
        for a, b in ((north+.13, cz-2.71), (cz+2.71, south-.13)):
            guard(pavilion, (x, top, a), (x, top, b))
    for z in (north+.13, south-.13):
        guard(pavilion, (west+.12, top, z), (east-.12, top, z))
        for x in (cx-4.85, cx+4.85):
            beam(pavilion, "Copper Kiln roof diagonal corbel", (x, top+5.31, z),
                 (x+(1 if x<cx else -1)*1.42, top+6.42, z), .31, "8E5540")

    for x, high, z, ground in (
        (108.66, 18.31, -222.45, 6.48), (115.23, 19.52, -228.67, 1.8),
        (123.66, 21.39, -234.05, -4.2), (135.58, 23.63, -237.10, -4.2),
        (144.64, 25.33, -239.52, -4.2), (150.60, 26.52, -242.42, -4.2),
        (150.60, 26.52, -236.30, -4.2), (160.60, 26.52, -242.42, -4.2),
        (160.60, 26.52, -236.30, -4.2), (169.84, 26.11, -238.31, -4.2),
        (181.17, 24.13, -233.03, -4.2), (188.94, 21.53, -224.52, -4.2),
        (193.14, 19.56, -215.98, -4.2), (197.04, 16.66, -205.16, -4.2),
        (197.28, 15.40, -198.44, -4.2),
    ):
        height = high - ground
        detail(walk, "Kiln Walk dressed basalt pier", (x, ground + height*.5, z),
               (2.22, height, 2.31), "765859", slate)
        detail(walk, "Kiln Walk flared basalt footing", (x, ground + 1.63, z),
               (3.25, 3.26, 3.32), "836165", slate)
        detail(walk, "Kiln Walk pier capital", (x, high - .24, z),
               (2.91, .49, 2.87), "A67B6D", slate)
        for fraction in (.23, .51, .75, .90):
            detail(walk, "Kiln Walk sandstone inset course", (x, ground + height*fraction, z),
                   (2.35, .22, 2.45), "AD7861", sandstone)

    # Irregular rock shoulders behind the viaduct break up the straight piers.
    for index, (x, y, z, width, depths) in enumerate((
        (124.65, 8.90, -239.50, 16.2, 12.9), (139.10, 11.20, -244.20, 20.5, 14.2),
        (157.25, 14.60, -247.50, 23.4, 15.2), (175.00, 10.80, -245.20, 19.9, 14.8),
        (189.62, 7.90, -236.70, 15.8, 11.4),
    )):
        bed = item(walk, "Model", "Kiln Walk planted sandstone shoulder")
        for step, (scale, drop, h, tint) in enumerate((
            (1.20, 4.20, y + .30, "80616A"), (1.00, 2.12, 4.2, "9D6F64"),
            (.79, .05, 2.34, "AA7963"), (.61, -.11, .23, "898950"),
        )):
            stone = grass if step == 3 else sandstone
            garden_shelf(bed, x + step*.37, y - drop, z + step*.31,
                         width*scale, depths*scale, h, tint, stone, collide=False)
        for stone_x, stone_z, turn in ((x-width*.22,z+.74,36), (x+width*.26,z+.38,105)):
            garden_prop(bed, "bankRock", (stone_x, y+.07, stone_z), .36, turn+index*26, "A48672")
            garden_prop(bed, "meadowCover", (stone_x + .50, y+.12, stone_z + .61),
                        .21, turn+index*38, "9A9A61")
            garden_prop(bed, "mossFlowers", (stone_x - .40, y+.11, stone_z + .35),
                        .19, turn+index*22, "F3B78B")

    for x in (cx-4.85, cx+4.85):
        for z in (cz-3.65, cz+3.65):
            detail(pavilion, "Kiln Pavilion sandstone column shoe", (x, top+.30, z),
                   (1.05, .60, 1.10), "A7806C", sandstone)
            detail(pavilion, "Kiln Pavilion copperwood post", (x, top+3.47, z),
                   (.70, 6.34, .70), "965A44", cedar)
            for height in (.93, 5.73, 6.33):
                detail(pavilion, "Pavilion copper joint collar", (x, top+height, z),
                       (.81, .14, .82), "C08757", brass)
            festival_lantern(pavilion, x, top+5.52, z + (.74 if z > cz else -.74),
                             .70, tint="FFD0A2", light=False, entrance_paper=True)
        beam(pavilion, "Kiln Pavilion cedar side lintel", (x, top+6.44, cz-4.01),
             (x, top+6.44, cz+4.01), .47, "79493E")
    for z in (cz-3.65, cz+3.65):
        beam(pavilion, "Kiln Pavilion copperwood lintel", (cx-5.43, top+6.45, z),
             (cx+5.43, top+6.45, z), .51, "9B5B48")
    swept_roof(pavilion, cx, top+6.72, cz, 14.52, 10.47, 3.12,
               fine_tiles=False, signature=True, corner_sweep=1.17)
    sign(pavilion, "COPPER KILN WALK", cx, top+5.87, cz+3.90, 8.22, 1.06, 0, "784934")

    display = item(pavilion, "Model", "Potters' copper glaze display")
    detail(display, "Copper glaze sandstone counter", (cx, top+.56, north+1.10),
           (4.82, 1.12, 1.37), "96665C", slate)
    detail(display, "Copper glaze dressed top", (cx, top+1.18, north+1.10),
           (5.03, .19, 1.56), "C39976", sandstone)
    for offset, height, width, colors in (
        (-1.49, .99, .74, ("5F7D69", "75927B", "9CAD7D")),
        (.03, 1.34, .93, ("A6684F", "C28359", "D4A174")),
        (1.48, .90, .68, ("687861", "94A474", "BAAA75")),
    ):
        for depth, diameter, middle, tone in (
            (.26, .62, .13, colors[0]), (.42, 1.0, .47, colors[1]), (.22, .78, .79, colors[1]),
            (.13, .49, .955, colors[2]),
        ):
            detail(display, "Glazed stoneware vessel", (cx+offset, top+1.28+middle*height, north+1.10),
                   (depth*height, diameter*width, diameter*width), tone, sandstone, roll=90, shape=2)
    seat = part(pavilion, "Copper Kiln bench", (cx, top+.64, south-1.04),
                (4.02, .27, .95), "AD7452", material=cedar, class_name="Seat")
    seat.find("Properties/bool[@name='CanTouch']").text = "true"
    detail(pavilion, "Copper Kiln bench back", (cx, top+1.19, south-.68),
           (4.06, .65, .19), "995B44", cedar)
    for x in (cx-1.53, cx+1.53):
        detail(pavilion, "Copper Kiln sandstone bench foot", (x, top+.26, south-1.04),
               (.60, .51, .80), "8D665F", slate)
    for index, (x, z) in enumerate(((west+1.59, south-1.54), (east-1.64, north+1.64))):
        garden_shelf(pavilion, x, top+.41, z, 1.93, 1.85, .41, "A17B66", sandstone, collide=False)
        garden_shelf(pavilion, x, top+.47, z, 1.66, 1.56, .14, "818751", grass, collide=False)
        garden_prop(pavilion, "meadowCover", (x-.19, top+.50, z+.23), .15, 63+index*31, "ADB270")
        garden_prop(pavilion, "mossFlowers", (x+.20, top+.50, z-.17), .18, 76+index*29, "EDAE77")

    for x, y, z, yaw, board, width, title in (
        (111.85, 18.10, -221.27, 18, 5.92, 5.8, "COPPER KILN WALK  ↑"),
        (198.73, 15.80, -192.88, -41, 5.92, 5.8, "COPPER KILN WALK  ↑"),
        (160.80, top, -244.18, -90, 2.60, 4.50, "GLAZE TERRACE  ↓"),
        (150.43, top, -234.76, 90, 2.60, 4.50, "POTTERS' YARD  ↓"),
    ):
        detail(walk, "Kiln Walk wayfinding foot", (x, y+.24, z), (.73, .48, .78), "A57F69", slate)
        detail(walk, "Kiln Walk wayfinding post", (x, y+board*.5, z), (.28, board+.10, .28),
               "8B533F", cedar)
        sign(walk, title, x, y+board, z, width, 1.00, yaw, "854A36")
    for foot, bearing in (
        ((111.85, 18.11, -221.27), (109.97, 17.92, -221.27)),
        ((198.73, 15.81, -192.88), (197.12, 15.42, -192.66)),
    ):
        beam(walk, "Kiln Walk wayfinding side bracket", foot, bearing, .41, "81584F")

    bounds = item(walk, "Folder", BOUNDS)
    for chain in (ASCENT, DESCENT):
        for a, b in zip(chain, chain[1:]):
            dx, dy, dz = (v-u for u, v in zip(a, b))
            part(bounds, "Copper Kiln Walk route bounds", lift(between(a, b, .5), 3.65),
                 (WIDTH+.27, 6.34, dist(a,b)+.42), "FFFFFF",
                 yaw=degrees(atan2(dx,dz)), pitch=-degrees(atan2(dy,hypot(dx,dz))),
                 collide=False, transparency=1)
