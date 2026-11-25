"""The Grand Dojo Tag Team gate and the teal-and-vermilion terrace court."""

from math import cos, pi, sin

from district_dojo_rings import PLAYER_STAND_HEIGHT


def build_dojo_tag_team(ring, *, item, part, prop, sign, showcase_tree, wood, slate, metal, neon, fabric,
                        triangle, limestone=None):
    brass, gilt, ink = "B9905E", "E2BD78", "453642"
    vermilion, jade = "A85749", "3C7771"
    entry = item(ring, "Model", "Tag Team Entry")
    board_x, board_z, board_ground = 33.5, 39.1, .15
    for dx, tint in ((-2.56, jade), (2.56, vermilion)):
        part(entry, "Tag Team sign footing", (board_x + dx, board_ground + .27, board_z),
             (.60, .54, .72), "887581", material=slate, collide=False)
        part(entry, "Tag Team colored cedar post", (board_x + dx, board_ground + 1.41, board_z),
             (.33, 2.44, .36), tint, material=wood, collide=False)
        part(entry, "Tag Team sign clasp", (board_x + dx, board_ground + 2.43, board_z + .16),
             (.46, .24, .12), brass, material=metal, collide=False)
    sign(entry, "2V2 TAG TEAM", board_x, board_ground + 2.44, board_z + .16, 5.14, .83,
         tint="72433C", single_line=True)
    sign(entry, "CHOOSE A BACKUP", board_x, board_ground + 1.71, board_z + .16, 4.89, .48,
         tint="394F57", single_line=True)
    gate = part(entry, "Tag Team Queue", (board_x, board_ground + 2.10, board_z + .74),
                (.2, .2, .2), "FFF0C5", transparency=1, collide=False)
    prompt = item(gate, "ProximityPrompt", "JoinTagTeamPrompt")
    prop(prompt, "string", "ActionText", "Choose backup fighter")
    prop(prompt, "string", "ObjectText", "Grand Dojo Tag Team")
    prop(prompt, "float", "MaxActivationDistance", 7.25)
    prop(prompt, "bool", "RequiresLineOfSight", False)
    prop(prompt, "float", "HoldDuration", .20)
    part(entry, "Tag Team Return", (board_x + 1.5, 2.55, board_z + 4.6), (.2, .2, .2),
         "FFF0C5", transparency=1, collide=False, yaw=180)

    court = item(ring, "Model", "Tag Team Court")
    prop(court, "token", "ModelStreamingMode", 1)
    cx, floor, cz = -875, 78, 702

    def detail(parent, name, x, y, z, size, color, *, material=slate, collide=False, yaw=0, pitch=0,
               transparency=0):
        surface = {"material": material} if material is not None else {}
        node = part(parent, name, (cx + x, floor + y, cz + z), size, color, collide=collide, yaw=yaw,
                    pitch=pitch, transparency=transparency, **surface)
        prop(node, "bool", "CastShadow", False)
        return node

    def marker(parent, name, x, y, z, *, size=(.2, .2, .2), yaw=0):
        return detail(parent, name, x, y, z, size, brass, transparency=1, yaw=yaw)

    marker(court, "Bounds", 0, 3.10, 0, size=(40, 13, 40))
    marker(court, "Floor Origin", 0, 0, 0)
    marks = item(court, "Folder", "Spawn Marks")
    for index, (x, z, yaw) in enumerate(((12, 6, 90), (12, -6, 90), (-12, 6, -90), (-12, -6, -90)), 1):
        marker(marks, f"Seat {index}", x, PLAYER_STAND_HEIGHT, z, yaw=yaw)

    # A single collision plane keeps all foot, dash and ground-effect heights consistent.
    detail(court, "Stable Tag canvas", 0, -.32, 0, (40.4, .64, 40.4), "C8A98A", material=limestone, collide=True)
    pavers = ("E7C6A2", "EACAA5", "EBCFAA", "E4C6A8")
    for row in range(4):
        for column in range(4):
            detail(court, "Warm honed court sandstone", (column - 1.5) * 9.99, .011, (row - 1.5) * 9.99,
                   (9.94, .021, 9.94), pavers[(row * 3 + column) % len(pavers)], material=limestone)
    detail(court, "Shadow line below the court", 0, -.86, 0, (43.7, .38, 43.7), ink)
    detail(court, "Cedar platform fascia", 0, -1.36, 0, (46.3, .78, 46.3), "855B50", material=wood)
    detail(court, "Stone platform plinth", 0, -3.00, 0, (46.7, 2.54, 46.7), "746575")
    detail(court, "Sandstone foundation foot", 0, -4.43, 0, (48.5, .38, 48.5), "977C87")
    for side, tint, seam in ((1, "438D80", "8DC5AE"), (-1, "C65D47", "E09571")):
        detail(court, "Dyed team inlay", side * 17.32, .026, 0, (4.5, .023, 39.83), tint, material=limestone)
        detail(court, "Team inlay seam", side * 14.99, .043, 0, (.15, .018, 39.75), seam, material=limestone)
        for z in (-6, 6):
            detail(court, "Paired starting inlay", side * 12, .029, z, (1.28, .024, 3.9), tint, material=limestone)
            detail(court, "Pair mark gilt", side * 11.37, .045, z, (.11, .021, 3.43), gilt, material=metal)
        detail(court, "Court end trim", side * 19.78, .047, 0, (.18, .04, 39.72), gilt, material=metal)
        detail(court, "Court side trim", 0, .047, side * 19.78, (39.72, .04, .18), gilt, material=metal)

    # Interlocking diamonds mark center without covering the neutral floor with a pattern.
    for side, tint in ((1, jade), (-1, vermilion)):
        detail(court, "Double reed brass device", side * .94, .025, 0, (2.72, .034, 2.72), brass, yaw=45)
        detail(court, "Double reed inner field", side * .94, .045, 0, (2.28, .025, 2.28), tint, yaw=45)
    detail(court, "Double reed knot", 0, .064, 0, (.86, .025, .86), gilt, yaw=45)

    def rail(parent, x, z, span, yaw, *, ground=0):
        detail(parent, "Solid safety boundary", x, ground + 5.0, z, (span, 10.5, .39), ink,
               collide=True, transparency=1, yaw=yaw)
        for height, thickness, depth, tint in ((.26, .25, .39, "785759"), (1.20, .13, .21, brass),
                                                 (2.12, .24, .32, "814C42")):
            detail(parent, "Cedar court rail", x, ground + height, z, (span, thickness, depth), tint,
                   material=wood, yaw=yaw)

    for side in (-1, 1):
        rail(court, side * 20.30, 0, 40.68, 90)
        rail(court, 0, side * 20.30, 40.68, 0)
        for position in (-20.36, -10.18, 0, 10.18, 20.36):
            detail(court, "Banded cedar guard post", position, 1.17, side * 20.32,
                   (.40, 2.36, .43), "643F42", material=wood)
            detail(court, "Brass guard post crown", position, 2.36, side * 20.32,
                   (.49, .14, .53), brass, material=metal)
        for position in (-10.18, 0, 10.18):
            detail(court, "Banded cedar guard post", side * 20.32, 1.17, position,
                   (.43, 2.36, .40), "643F42", material=wood)
            detail(court, "Brass guard post crown", side * 20.32, 2.36, position,
                   (.53, .14, .49), brass, material=metal)

    def lantern(x, z, y, tint):
        detail(court, "Lantern bronze foot", x, y - .84, z, (1.18, .17, 1.18), brass, material=metal)
        detail(court, "Lantern warm paper", x, y - .35, z, (.93, .83, .93), tint, material=neon)
        detail(court, "Lantern crown", x, y + .12, z, (1.31, .23, 1.31), "74463D", material=wood)
        for dx in (-.50, .50):
            for dz in (-.50, .50):
                detail(court, "Lantern cedar rib", x + dx, y - .34, z + dz,
                       (.09, .92, .09), "694448", material=wood)

    for side, tint in ((1, jade), (-1, vermilion)):
        x = side * 24.2
        for z in (-9.2, 9.2):
            detail(court, "Team gate slate foot", x, -.52, z, (2.28, 1.43, 2.24), "847482")
            detail(court, "Team gate cedar upright", x, 3.01, z, (1.31, 6.13, 1.29), tint, material=wood)
            detail(court, "Team gate collar", x, 5.64, z, (1.54, .23, 1.51), brass, material=metal)
            detail(court, "Team gate bracket", x, 5.92, z, (1.84, .32, 2.04), "6A4344", material=wood)
            for dz in (-.4, .4):
                detail(court, "Bannertop hanging rod", x - side * .73, 4.98, z + dz,
                       (.14, .12, .92), brass, material=metal)
            detail(court, "Team gate banner", x - side * .75, 3.79, z, (.13, 2.14, 1.44), tint, material=fabric)
            detail(court, "Banner straight hem", x - side * .82, 2.76, z, (.10, .14, 1.40), gilt, material=metal)
            lantern(x, z - 2.30, 5.38, "FFCA81")
        detail(court, "Team gate header", x, 6.31, 0, (1.84, .49, 20.66), "824B3E", material=wood)
        detail(court, "Team gate crown", x, 6.67, 0, (2.43, .39, 21.4), "3A445B")
        detail(court, "Team gate crown brass", x, 6.90, 0, (2.48, .13, 21.68), brass, material=metal)
        for z_side in (-1, 1):
            detail(court, "Upturned team coping", x, 7.00, z_side * 10.92, (2.49, .24, 2.20),
                   "3A445B", pitch=-z_side * 14)
            detail(court, "Gate ridge tip", x, 7.19, z_side * 11.77, (2.56, .20, .58),
                   gilt, material=metal, pitch=-z_side * 14)

    # Lower native facets join the platform to a local valley and a broken distant ridgeline.
    detail(court, "Broad terrace base", 0, -8.79, 0, (83, 1.20, 88), "746475")
    landscape = item(court, "Model", "Lantern foothill valley")
    detail(landscape, "Slate blue valley basin", 0, -51.5, 0, (492, 2.5, 425), "737D83", material=None)
    terrain = (
        (40, 40, (-7, -8, -8, -7, -7, -9, -8, -7, -8, -8, -7, -9)),
        (58, 56, (-8, -5, -7, -4, -7, -8, -6, -7, -4, -7, -6, -8)),
        (93, 86, (-25, -14, -22, -10, -16, -23, -25, -19, -12, -20, -13, -22)),
        (157, 142, (5, 27, 8, 31, 20, 33, -1, 20, 29, 8, 23, 1)),
        (241, 209, (-50, -48, -50, -48, -49, -50, -49, -48, -50, -49, -50, -48)),
    )
    belts = (
        ("807D67", "747E69", "8B826D", "7D826D", "89907A"),
        ("707969", "798371", "828978", "778174", "8B8B76"),
        ("8B7887", "766C83", "829087", "947F8D", "787683"),
        ("928697", "817E94", "8D8798", "798495", "87928C"),
    )
    rings = []
    for band, (width, depth, heights) in enumerate(terrain):
        points = []
        for index, y in enumerate(heights):
            angle = (index + .20 * (band % 2)) * pi / 6
            radius = (1, .93, 1.03, .98)[(index + band) % 4]
            points.append((cx + width * radius * cos(angle), floor + y, cz + depth * radius * sin(angle)))
        rings.append(points)
    for band, (near, far) in enumerate(zip(rings, rings[1:])):
        palette = belts[band]
        for index, point in enumerate(near):
            next_index = (index + 1) % len(near)
            triangle(landscape, point, far[index], far[next_index], palette[(index + band) % len(palette)],
                     name="Foothill slope face", thickness=.28, shadow=False)
            triangle(landscape, point, far[next_index], near[next_index], palette[(index + band + 1) % len(palette)],
                     name="Foothill slope face", thickness=.28, shadow=False)
    for index, scale in ((1, 1.44), (2, 1.16), (4, 1.53), (5, 1.22), (7, 1.36), (9, 1.47), (11, 1.28)):
        x, y, z = rings[1][index]
        showcase_tree(landscape, x, z, False, scale, 24 + index * 30, y - .18, compact=True)

    apron = item(court, "Model", "Tag Team viewing terrace")
    detail(apron, "Raised viewing deck", 0, 1.63, 30.5, (27.5, 1.25, 11), "976D57", material=wood, collide=True)
    detail(apron, "Deck foundation", 0, -.61, 30.5, (28.1, 3.26, 11.6), "766171")
    for x, z, span, yaw in ((0, 25.10, 27.5, 0), (0, 35.90, 27.5, 0),
                               (-13.64, 30.5, 11.05, 90), (13.64, 30.5, 11.05, 90)):
        rail(apron, x, z, span, yaw, ground=2.255)
    for x in (-13.59, -6.76, 0, 6.76, 13.59):
        for z in (25.16, 35.84):
            detail(apron, "Viewing rail cedar post", x, 3.52, z, (.43, 2.42, .43), "70464A", material=wood)
    marker(court, "Spectator Return", 0, 4.58, 30.5)
    sign(apron, "TAG TEAM", cx, floor + 4.01, cz + 35.88, 8.1, .78,
         tint="6B4443", single_line=True, finished_back=True, reverse_label="TAG TEAM")
    sign(court, "GRAND DOJO TAG TEAM", cx, floor + 2.79, cz - 21.10, 10.9, .92,
         tint="704540", single_line=True)
    return court
