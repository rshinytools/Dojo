"""Lantern Circuit's western skyline loop from the upper market to Overlook Lane."""

from math import atan2, ceil, degrees, dist, hypot


NAME = "Lantern Skyline Walk"
WIDTH = 6.0
CROWN = (-261.80, 19.37, 37.20)
TERRACE = (-268.45, -255.15, 30.30, 44.10)
CLIMB = (
    (-255.299, 13.57, -6.645), (-258.10, 13.74, .42),
    (-260.80, 15.27, 8.70), (-261.80, 17.57, 18.0),
    (-261.80, 19.37, 27.0), (-261.80, 19.37, 31.60),
)
DESCENT = (
    (-261.80, 19.37, 42.85), (-261.80, 19.37, 44.10),
    (-261.40, 17.49, 50.30), (-257.00, 14.82, 56.90),
    (-249.00, 12.14, 60.40), (-240.80, 9.38, 60.10),
    (-233.90, 6.72, 57.10), (-231.85, 6.045, 54.90),
)
MARKET_APPROACH = (
    (-248.98, 13.27, -4), (-249.18, 13.27, -5.65),
    (-252.8, 13.27, -5.65), CLIMB[0],
)
RETURN_JOIN = (-228.20, 6.045, 54.62)
POINTS = (*CLIMB, CROWN, *DESCENT)
WALK_POINTS = (*MARKET_APPROACH[:-1], *POINTS, RETURN_JOIN)
# These were the endpoints of the continuous south guard of the first
# angled Meltwater segment. Its adjoining rails remain outside the fork.
MELTWATER_GUARD_A = (-253.350092, 13.27, -2.78)
MELTWATER_GUARD_B = (-259.975061, 14.01, -5.416467)


def build_lantern_market_crossing(parent, *, item, prop, part, beam, triangle, path_edge,
                                  sign, swept_roof, festival_lantern, garden_shelf,
                                  garden_prop, slate, limestone, cedar, brass, grass,
                                  stone_variant, variant_field):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)

    def between(a, b, t):
        return tuple(u + (v - u) * t for u, v in zip(a, b))

    def lift(point, dy):
        return point[0], point[1] + dy, point[2]

    def guard(model, a, b, *, posts=True):
        if dist(a, b) < .08:
            return
        for height, width, tint in ((.58, .21, "745364"), (1.39, .24, "93637B")):
            beam(model, "Skyline plum guardrail", lift(a, height), lift(b, height),
                 width, tint, collide=True)
        if posts:
            count = max(1, ceil(dist(a, b) / 3.8))
            for index in range(count):
                p = between(a, b, (index + .38) / count)
                part(model, "Skyline rail newel", lift(p, .68), (.33, 1.47, .34),
                     "80586A", material=cedar, collide=False)
                part(model, "Skyline gilt rail cap", lift(p, 1.44), (.43, .15, .44),
                     "CA9A6D", material=brass, collide=False)

    for chain, label in ((CLIMB, "Market climb"), (DESCENT, "Overlook descent")):
        run = item(walk, "Model", label)
        left, right = (path_edge(chain, side * WIDTH * .5) for side in (-1, 1))
        for index, (a, b, c, d) in enumerate(zip(left, left[1:], right[1:], right)):
            ring = tuple(lift(p, -.19) for p in (a, b, c, d))
            start = len(run)
            for face, tint in (((0, 1, 2), "AA969F"), ((0, 2, 3), "B19EA7")):
                triangle(run, *(ring[i] for i in face), tint, name="Skyline limestone walk",
                         thickness=.38, material=limestone, collide=True, shadow=False)
            for stone in run[start:]:
                prop(stone, "string", variant_field, stone_variant)
        for side in (-1, 1):
            inner = path_edge(chain, side * (WIDTH * .5 - .16))
            for index, (a, b) in enumerate(zip(inner, inner[1:])):
                if chain is CLIMB and index == 0:
                    a = between(a, b, .43)
                    boundary = MELTWATER_GUARD_A if side == 1 else MELTWATER_GUARD_B
                    guard(run, boundary, a, posts=False)
                elif chain is CLIMB and index == len(inner) - 2:
                    b = between(a, b, (TERRACE[2] - a[2]) / (b[2] - a[2]))
                elif chain is DESCENT and index == 0:
                    continue
                elif chain is DESCENT and index == len(inner) - 2:
                    b = between(a, b, .29)
                guard(run, a, b)
                beam(run, "Skyline cut-stone fascia", lift(a, -.36), lift(b, -.36),
                     .47, "796A7A")

    cx, top, cz = CROWN
    west, east, north, south = TERRACE
    balcony = item(walk, "Model", "Lantern Skyline Pavilion")
    prop(balcony, "token", "LevelOfDetail", 4)
    slab = part(balcony, "Pavilion limestone deck", ((west + east) * .5, top - .25, (north + south) * .5),
                (east - west, .50, south - north), "B29FA5", material=limestone)
    prop(slab, "string", variant_field, stone_variant)

    for a, b in (
        ((west + .18, top, north), (cx - 2.84, top, north)),
        ((cx + 2.84, top, north), (east - .18, top, north)),
        ((west + .18, top, south), (cx - 2.84, top, south)),
        ((cx + 2.84, top, south), (east - .18, top, south)),
        ((west + .18, top, north), (west + .18, top, south)),
        ((east - .18, top, north), (east - .18, top, south)),
    ):
        guard(balcony, a, b)
        beam(balcony, "Pavilion carved apron", lift(a, -.37), lift(b, -.37), .53, "827082")

    # The short stone pylons and longer cedar braces leave open views below.
    supports = (
        (-260.2, 15.09, 7.8), (-261.8, 17.55, 17.9), (-261.8, 19.31, 26.7),
        (-266.0, top, 33.2), (-257.7, top, 33.2),
        (-266.0, top, 41.2), (-257.7, top, 41.2),
        (-261.5, 18.16, 48.1), (-255.2, 14.36, 56.6),
        (-245.5, 10.96, 60.4), (-238.6, 8.54, 58.5),
    )
    for i, (x, deck, z) in enumerate(supports):
        cap = deck - (.79 if 3 <= i <= 6 else .97)
        foot = -4.65 if x < -253 or z > 58.7 else 4.65
        height = cap - foot
        part(walk, "Skyline slate trestle", (x, foot + height * .5, z),
             (2.05, height, 2.25), "78677D", material=slate, collide=False)
        part(walk, "Skyline trestle plinth", (x, foot + .37, z),
             (2.88, .74, 2.97), "8B7885", material=slate, collide=False)
        part(walk, "Skyline dressed bracket stone", (x, cap + .09, z),
             (2.72, .42, 2.91), "A18A91", material=slate, collide=False)
        for fraction in (.32, .64, .87):
            part(walk, "Skyline stone stringcourse", (x, foot + height * fraction, z),
                 (2.27, .18, 2.45), "968092", material=slate, collide=False)
        across_x, across_z = (0, 1) if i >= 9 else (1, 0)
        for hand in (-1, 1):
            beam(walk, "Skyline cedar support brace",
                 (x + hand * .39 * across_x, cap - 2.1, z + hand * .39 * across_z),
                 (x + hand * 2.67 * across_x, cap + .19, z + hand * 2.67 * across_z),
                 .51, "795569")
        if i in (1, 3, 7, 8):
            garden_shelf(walk, x - .70, foot + 1.04, z, 5.25, 4.73, 1.34,
                         "817985", slate, collide=False)
            garden_shelf(walk, x - .96, foot + 1.17, z, 4.70, 4.10, .20,
                         "7C8D65", grass, collide=False)
            garden_prop(walk, "bankRock", (x - 2.14, foot + 1.18, z - .21),
                        .24, 33 + i * 29, "958694")
            garden_prop(walk, "meadowCover", (x - 1.90, foot + 1.25, z + .51),
                        .20, 29 + i * 31, "A4AB68")

    for x in (cx - 5.30, cx + 5.30):
        for z in (cz - 3.88, cz + 3.88):
            part(balcony, "Pavilion slate column shoe", (x, top + .31, z),
                 (1.12, .62, 1.10), "938393", material=slate, collide=False)
            part(balcony, "Pavilion lacquered plum post", (x, top + 3.72, z),
                 (.78, 6.83, .74), "814A61", material=cedar, collide=False)
            for y in (top + .87, top + 6.74):
                part(balcony, "Pavilion brass collar", (x, y, z),
                     (.93, .19, .93), "D0A071", material=brass, collide=False)
            festival_lantern(balcony, x, top + 5.73, z + .83, .78,
                             light=False, tint="FFD19C", entrance_paper=True)
        beam(balcony, "Pavilion cedar side tie", (x, top + 7.05, cz - 4.34),
             (x, top + 7.05, cz + 4.34), .62, "93586B")
    for z in (cz - 3.88, cz + 3.88):
        beam(balcony, "Pavilion plum lintel", (cx - 5.86, top + 7.05, z),
             (cx + 5.86, top + 7.05, z), .63, "925465")
        for hand in (-1, 1):
            beam(balcony, "Pavilion cedar knee bracket", (cx + hand * 5.29, top + 5.95, z),
                 (cx + hand * 3.81, top + 7.22, z), .44, "A46A71")
    swept_roof(balcony, cx, top + 7.16, cz, 14.45, 11.08, 3.19,
               fine_tiles=False, signature=True, corner_sweep=1.36)
    sign(balcony, "LANTERN SKYLINE WALK", cx, top + 6.76, cz - 4.29, 7.86, 1.06,
         yaw=180, tint="694361")

    # The terrace's east edge frames the night market. Furniture stays
    # outside the continuous lane and uses the native Seat interaction.
    seat_x = east - 1.08
    seat = part(balcony, "Skyline cedar seat", (seat_x, top + .57, cz + .40),
                (.95, .26, 4.39), "A7746F", material=cedar, class_name="Seat")
    seat.find("Properties/bool[@name='CanTouch']").text = "true"
    part(balcony, "Skyline seat back", (seat_x + .40, top + 1.04, cz + .40),
         (.18, .66, 4.62), "875963", material=cedar, collide=False)
    for z in (cz - 1.24, cz + 2.03):
        part(balcony, "Skyline seat slate base", (seat_x, top + .28, z),
             (.76, .56, .60), "8B7890", material=slate, collide=False)
    for x,z in ((west + 1.33, north + 1.40), (east - 1.28, south - 1.45)):
        garden_shelf(balcony, x, top + .44, z, 2.11, 2.46, .44,
                     "928195", slate, collide=False)
        garden_prop(balcony, "mossFlowers", (x, top + .47, z + .29), .22, 51,
                    "EFACC8")
        garden_prop(balcony, "meadowGrass", (x - .25, top + .49, z - .31), .18, 82,
                    "A6B275")

    for x, y, z, yaw, width, label in (
        (-253.83, 13.79, 1.29, 180, 4.75, "LANTERN SKYLINE  ↑"),
        (-236.03, 6.06, 52.93, 90, 4.75, "LANTERN SKYLINE  ↑"),
        (-266.13, top, 42.65, 180, 3.75, "OVERLOOK LANE  ↑"),
    ):
        part(walk, "Skyline wayfinding stone foot", (x, y + .23, z),
             (.87, .46, .82), "8B7890", material=slate, collide=False)
        part(walk, "Skyline wayfinding cedar post", (x, y + 1.30, z),
             (.27, 2.48, .28), "936479", material=cedar, collide=False)
        sign(walk, label, x, y + 2.53, z, width, .91, yaw=yaw, tint="684561")

    bounds = item(walk, "Folder", "Lantern Skyline location bounds")
    # Keep the lower street outside the HUD region. The existing Frostglass
    # and Overlook destinations keep their own labels at the two junctions.
    up = (between(CLIMB[0], CLIMB[1], .53), *CLIMB[1:])
    down = (*DESCENT[:-2], between(DESCENT[-3], DESCENT[-2], .62))
    for chain in (up, down):
        for a, b in zip(chain, chain[1:]):
            dx, dy, dz = (q - p for p, q in zip(a, b))
            part(bounds, "Lantern Skyline Walk bounds", lift(between(a, b, .5), 3.85),
                 (WIDTH + .28, 6.60, dist(a, b) + .44), "FFFFFF",
                 yaw=degrees(atan2(dx, dz)), pitch=-degrees(atan2(dy, hypot(dx, dz))),
                 collide=False, transparency=1)
