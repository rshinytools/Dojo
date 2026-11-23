"""A raised waterfront loop between Beacon Terrace and Lantern Quay."""

from math import atan2, ceil, degrees, dist, hypot


NAME = "Harbor Sky Pier"
WIDTH = 5.72
CROWN = (323.70, 18.35, 34.35)
PAVILION_BOUNDS = (317.50, 329.90, 27.50, 41.20)
QUAY_FORK = (283.655, 8.175, 31.85)
QUAY_LENGTH = hypot(4.69, 3.60)
QUAY_ALONG = (4.69 / QUAY_LENGTH, -3.60 / QUAY_LENGTH)
QUAY_OUT = (3.60 / QUAY_LENGTH, 4.69 / QUAY_LENGTH)
QUAY_GRADE = 1.85 / QUAY_LENGTH
QUAY_GUARDS = (
    (282.940485, 7.25, 35.827376),
    (287.663474, 9.10, 32.202054),
)
BEACON_GUARDS = ((298.73, 11.0, 13.96), (298.73, 11.0, 19.70))


def quay_offset(outward, height):
    x, y, z = QUAY_FORK
    return x + QUAY_OUT[0] * outward, y + height, z + QUAY_OUT[1] * outward


ASCENT = (
    (297.95, 11.00, 16.83), (300.75, 11.00, 16.83), (309.90, 13.42, 16.83),
    (318.80, 16.10, 18.85), (323.70, 18.35, 26.00), (323.70, 18.35, 28.60),
)
DESCENT = (
    (323.70, 18.35, 39.70), (323.70, 18.35, 41.20),
    (320.65, 16.50, 47.47), (311.25, 14.31, 48.62), (300.85, 11.79, 45.68),
    (292.65, 9.60, 41.55), quay_offset(5.80, .36), quay_offset(1.58, 0),
)
UPPER_JOIN = (295.20, 11.00, 16.83)
PATH = (*ASCENT, CROWN, *DESCENT)
WALK_POINTS = (UPPER_JOIN, *PATH, QUAY_FORK)


def quay_bank(index, point):
    """Blend the last boards into the existing Quay's longitudinal grade."""
    blend = {len(DESCENT) - 2: .40, len(DESCENT) - 1: 1}.get(index, 0)
    x, y, z = point
    shift = (x - QUAY_FORK[0]) * QUAY_ALONG[0] + (z - QUAY_FORK[2]) * QUAY_ALONG[1]
    return x, y + shift * QUAY_GRADE * blend, z


def build_harbor_roof_walk(town, *, item, prop, part, beam, triangle, path_edge, sign,
                           swept_roof, festival_lantern, garden_shelf, garden_prop,
                           slate, limestone, cedar, grass, brass, paving_variant,
                           cedar_variant, variant_field):
    walk = item(town, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)

    def lift(point, height):
        return point[0], point[1] + height, point[2]

    def between(a, b, t):
        return tuple(u + (v - u) * t for u, v in zip(a, b))

    def detail(model, name, point, size, tint, material, **options):
        node = part(model, name, point, size, tint, material=material, collide=False, **options)
        prop(node, "bool", "CastShadow", False)
        return node

    def guard(model, a, b, *, posts=True):
        if dist(a, b) < .08:
            return
        for height, width, tint in ((.59, .21, "365F61"), (1.41, .24, "4C7776")):
            beam(model, "Sky Pier teal railing", lift(a, height), lift(b, height),
                 width, tint, collide=True)
        if posts:
            amount = max(1, ceil(dist(a, b) / 3.8))
            for index in range(amount):
                p = between(a, b, (index + .38) / amount)
                detail(model, "Sky Pier cedar newel", lift(p, .70), (.34, 1.48, .36),
                       "3F706C", cedar)
                detail(model, "Sky Pier brass newel cap", lift(p, 1.47), (.46, .15, .45),
                       "C69260", brass)

    for chain, label in ((ASCENT, "Beacon climb"), (DESCENT, "Lantern Quay descent")):
        route = item(walk, "Model", label)
        left, right = (path_edge(chain, side * WIDTH / 2) for side in (-1, 1))
        if chain is DESCENT:
            left = [quay_bank(i, point) for i, point in enumerate(left)]
            right = [quay_bank(i, point) for i, point in enumerate(right)]
        for i, (a, b, c, d) in enumerate(zip(left, left[1:], right[1:], right)):
            corners = tuple(lift(point, -.20) for point in (a, b, c, d))
            start = len(route)
            for face, tint in (((0, 1, 2), "97775F"), ((0, 2, 3), "A58065")):
                triangle(route, *(corners[j] for j in face), tint, name="Sky Pier cedar deck",
                         material=cedar, collide=True, shadow=False, thickness=.40)
            for piece in route[start:]:
                prop(piece, "string", variant_field, cedar_variant)
            length = dist(a, b)
            joints = max(1, round(length / 1.18))
            for j in range(joints):
                t = (j + .64) / joints
                u, v = between(a, b, t), between(d, c, t)
                line = beam(route, "Cedar deck plank joint", lift(u, -.025), lift(v, -.025),
                            .026, ("7C6556", "8E715D")[(i + j) % 2])
                prop(line, "bool", "CastShadow", False)

        for side in (-1, 1):
            rails = path_edge(chain, side * (WIDTH / 2 - .14))
            if chain is DESCENT:
                rails = [quay_bank(i, point) for i, point in enumerate(rails)]
            for i, (a, b) in enumerate(zip(rails, rails[1:])):
                if chain is ASCENT and i == 0:
                    a = BEACON_GUARDS[0 if side == 1 else 1]
                if chain is ASCENT and i == len(rails) - 2:
                    b = between(a, b, (PAVILION_BOUNDS[2] - a[2]) / (b[2] - a[2]))
                if chain is DESCENT and i == 0:
                    continue
                if chain is DESCENT and i == len(rails) - 2:
                    b = QUAY_GUARDS[0 if side == 1 else 1]
                guard(route, a, b)
                fascia = beam(route, "Sky Pier cedar fascia", lift(a, -.29), lift(b, -.29),
                              .37, "7A5E50")
                prop(fascia, "bool", "CastShadow", False)

    x, top, z = CROWN
    west, east, north, south = PAVILION_BOUNDS
    pavilion = item(walk, "Model", "Sea Lantern Pavilion")
    prop(pavilion, "token", "LevelOfDetail", 4)
    deck = part(pavilion, "Sea Lantern deck", (x, top - .28, (north + south) * .50),
                (east - west, .56, south - north), "B3A19D", material=limestone)
    prop(deck, "string", variant_field, paving_variant)
    for u, v in (
        ((west + .16, top, north), (x - 2.72, top, north)),
        ((x + 2.72, top, north), (east - .16, top, north)),
        ((west + .16, top, south), (x - 2.72, top, south)),
        ((x + 2.72, top, south), (east - .16, top, south)),
        ((west + .16, top, north), (west + .16, top, south)),
        ((east - .16, top, north), (east - .16, top, south)),
    ):
        guard(pavilion, u, v)
        beam(pavilion, "Sea Lantern stone apron", lift(u, -.35), lift(v, -.35),
             .49, "8C8187")

    # Underwater piers and bracket knees frame the route without adding swim obstacles.
    supports = (
        (306.70, 12.55, 16.83), (315.20, 15.10, 18.22), (321.15, 17.15, 22.35),
        (319.05, top - .51, 29.36), (328.10, top - .51, 29.36),
        (319.05, top - .51, 39.52), (328.10, top - .51, 39.52),
        (322.10, 17.38, 44.57), (315.76, 15.39, 48.12), (305.49, 12.89, 47.06),
        (296.23, 10.55, 43.44), (289.03, 8.81, 38.84),
    )
    for i, (px, y, pz) in enumerate(supports):
        # Keep broad, horizontal bearings beneath both sides of the ramp.
        y -= .87 if i not in (3, 4, 5, 6) else .24
        foot = -6.6
        span = y - foot
        detail(walk, "Sea pier slate pile", (px, foot + span / 2, pz), (2.18, span, 2.14),
               "827D83", slate)
        detail(walk, "Sea pier dressed bearing", (px, y + .10, pz), (2.92, .48, 2.85),
               "A79A98", slate)
        for h in (1.27, (y + 1.27) * .50, y - 1.15):
            detail(walk, "Sea pier chamfered stone course", (px, h, pz), (2.45, .29, 2.42),
                   "978A8A", slate)
        for side in (-1, 1):
            brace = beam(walk, "Sea pier angled cedar knee",
                         (px + side * .58, y - 2.00, pz),
                         (px + side * 2.13, y - .23, pz),
                         .49, "786458")
            prop(brace, "bool", "CastShadow", False)
        if i in (3, 4, 6, 8):
            garden_shelf(walk, px, 1.06, pz, 4.30, 4.44, 1.50, "929392", slate, collide=False)
            garden_prop(walk, "bankRock", (px - 1.82, 1.09, pz - .89), .24,
                        41 + i * 20, "8C9496")
            garden_prop(walk, "cattails", (px + 1.34, 1.07, pz + .68), .18, 29 + i * 26)

    for px in (x - 4.71, x + 4.71):
        for pz in (z - 3.63, z + 3.63):
            detail(pavilion, "Sea Lantern slate column shoe", (px, top + .30, pz), (1.18, .60, 1.18),
                   "93878C", slate)
            detail(pavilion, "Sea Lantern teal column", (px, top + 3.47, pz), (.69, 6.42, .69),
                   "426F6C", cedar)
            for y in (top + .85, top + 6.26):
                detail(pavilion, "Sea Lantern column brass collar", (px, y, pz), (.83, .17, .83),
                       "CD9A5D", brass)
            festival_lantern(pavilion, px, top + 5.54, pz + .76, .78, light=False,
                             tint="FFD195", entrance_paper=True)
        beam(pavilion, "Sea Lantern cedar side beam", (px, top + 6.74, z - 4.08),
             (px, top + 6.74, z + 4.08), .57, "536D63")
    for pz in (z - 3.63, z + 3.63):
        beam(pavilion, "Sea Lantern cedar lintel", (x - 5.28, top + 6.77, pz),
             (x + 5.28, top + 6.77, pz), .58, "536D63")
        for side in (-1, 1):
            beam(pavilion, "Sea Lantern carved knee bracket", (x + side * 4.71, top + 5.60, pz),
                 (x + side * 3.25, top + 6.76, pz), .42, "648578")
    swept_roof(pavilion, x, top + 6.91, z, 13.42, 10.30, 2.88,
               fine_tiles=False, signature=True, corner_sweep=1.15)
    sign(pavilion, "SEA LANTERN PAVILION", x, top + 6.44, z - 4.00, 8.20, 1.02,
         yaw=180, tint="3B6767")

    seat_x = east - 1.21
    seat = part(pavilion, "Sea Lantern bench", (seat_x, top + .60, z),
                (1.02, .30, 4.08), "AC825F", material=cedar, class_name="Seat")
    seat.find("Properties/bool[@name='CanTouch']").text = "true"
    detail(pavilion, "Sea Lantern bench back", (seat_x + .45, top + 1.18, z), (.19, .66, 4.18),
           "986D54", cedar)
    for pz in (z - 1.52, z + 1.52):
        detail(pavilion, "Sea Lantern bench slate shoe", (seat_x, top + .24, pz), (.85, .48, .68),
               "8E7D80", slate)
    for px, pz in ((west + 1.37, north + 1.28), (east - 1.31, south - 1.26)):
        garden_shelf(pavilion, px, top + .41, pz, 1.98, 1.85, .44, "948886", slate, collide=False)
        garden_shelf(pavilion, px, top + .45, pz, 1.79, 1.68, .12, "7B8D6D", grass, collide=False)
        garden_prop(pavilion, "meadowCover", (px - .17, top + .47, pz + .19), .14, 47, "A5B37A")
        garden_prop(pavilion, "mossFlowers", (px + .18, top + .47, pz - .12), .22, 71, "EFB5BB")

    for px, y, pz, yaw, title in (
        (302.18, 11.38, 13.28, -24, "HARBOR SKY PIER  ↑"),
        (290.49, 8.87, 32.58, -25, "HARBOR SKY PIER  ↑"),
        (328.66, top, 39.76, 158, "LANTERN QUAY  ↓"),
    ):
        detail(walk, "Sky Pier wayfinding slate shoe", (px, y + .24, pz), (.89, .48, .84), "928686", slate)
        detail(walk, "Sky Pier wayfinding cedar post", (px, y + 1.37, pz), (.29, 2.72, .28), "4D7770", cedar)
        sign(walk, title, px, y + 2.67, pz, 5.49, .98, yaw=yaw, tint="3B6767")

    bounds = item(walk, "Folder", "Harbor Sky Pier location bounds")
    upper = (between(ASCENT[0], ASCENT[1], .72), *ASCENT[1:])
    lower = (*DESCENT[:-2], between(DESCENT[-3], DESCENT[-2], .76))
    for chain in (upper, lower):
        for a, b in zip(chain, chain[1:]):
            dx, dy, dz = (q - p for p, q in zip(a, b))
            part(bounds, "Harbor Sky Pier route bounds", lift(between(a, b, .5), 3.85),
                 (WIDTH + .28, 6.60, dist(a, b) + .44), "FFFFFF",
                 yaw=degrees(atan2(dx, dz)), pitch=-degrees(atan2(dy, hypot(dx, dz))),
                 collide=False, transparency=1)
