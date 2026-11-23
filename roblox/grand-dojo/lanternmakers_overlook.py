"""A raised rest stop on Lantern Circuit's southern terrace."""

from math import hypot


DECK = (-204.52, -192.15, 49.62, 59.62, 12.10)
WALK = (
    (-232.30, 6.045, 54.62), (-228.20, 6.045, 54.62),
    (-225.20, 6.48, 54.62), (-207.15, 11.62, 54.62), (-204.30, DECK[-1], 54.62),
)
WIDTH = 5.30
CALLIGRAPHER = (-194.00, DECK[-1], 56.94)


def build_lanternmakers_overlook(parent, *, item, prop, part, beam, route, sign, swept_roof,
                                 festival_lantern, garden_shelf, garden_prop, slate,
                                 limestone, cedar, grass, metal):
    overlook = item(parent, "Model", "Lanternmakers’ Overlook")
    prop(overlook, "token", "ModelStreamingMode", 1)
    prop(overlook, "token", "LevelOfDetail", 4)
    for i, (a, b) in enumerate(zip(WALK, WALK[1:])):
        route(overlook, "Overlook rose-slate ramp", (a, b), WIDTH,
              ("A599A5", "A4909B", "A6939F", "B19DA8")[i], surface=limestone,
              stone_footings=False, join_overlap=.32, railings=False)

    west, east, north, south, top = DECK
    cx, cz = (west + east) / 2, (north + south) / 2
    part(overlook, "Overlook stone floor", (cx, top - .30, cz),
         (east - west, .60, south - north), "BCABA9", material=limestone)
    for i, (x, z, surface, width, depth, thickness) in enumerate((
        (-220.8, 55.57, 6.28, 9.80, 5.90, 2.60),
        (-215.90, 55.45, 7.70, 8.96, 6.38, 3.64),
        (-208.60, 55.70, 9.77, 8.82, 7.03, 4.35),
        (-199.20, 55.54, 10.40, 13.44, 10.82, 6.12),
        (-197.99, 55.00, 11.82, 12.15, 10.28, 2.62),
    )):
        garden_shelf(overlook, x, surface, z, width, depth, thickness,
                     ("746577", "8A7685", "92808B")[i % 3], slate, collide=False)

    def rail(a, b):
        for lift in (.53, 1.32):
            beam(overlook, "Overlook lacquered rail", (a[0], a[1] + lift, a[2]),
                 (b[0], b[1] + lift, b[2]), .21, "765065", collide=True)
        bays = max(1, round(hypot(b[0] - a[0], b[2] - a[2]) / 3))
        for i in range(bays):
            t = (i + .5) / bays
            x, y, z = (u + (v - u) * t for u, v in zip(a, b))
            part(overlook, "Overlook cedar baluster", (x, y + .66, z), (.26, 1.38, .28),
                 "765065", material=cedar, collide=False)
            part(overlook, "Overlook brass rail cap", (x, y + 1.36, z), (.37, .11, .37),
                 "C29166", material=metal, collide=False)

    for direction in (-1, 1):
        dz = direction * 2.49
        guard = [(x, y, z + dz) for x, y, z in WALK[1:]]
        guard[-1] = (west + .10, top, cz + dz)
        for a, b in zip(guard, guard[1:]):
            rail(a, b)
    for a, b in (
        ((west + .10, top, north + .17), (east - .17, top, north + .17)),
        ((east - .17, top, north + .17), (east - .17, top, south - .17)),
        ((west + .10, top, south - .17), (east - .17, top, south - .17)),
        ((west + .10, top, north + .17), (west + .10, top, cz - 2.49)),
        ((west + .10, top, cz + 2.49), (west + .10, top, south - .17)),
    ):
        rail(a, b)

    shelter = item(overlook, "Model", "Lanternmakers’ plum pavilion")
    for x in (cx - 4.53, cx + 4.53):
        for z in (cz - 3.39, cz + 3.39):
            part(shelter, "Pavilion slate shoe", (x, top + .39, z), (.84, .78, .86),
                 "9B8995", material=slate, collide=False)
            part(shelter, "Pavilion plum cedar column", (x, top + 3.09, z), (.60, 5.80, .62),
                 "894758", material=cedar, collide=False)
            for height in (.89, 5.48):
                part(shelter, "Pavilion brass collar", (x, top + height, z), (.71, .17, .73),
                     "C18E60", material=metal, collide=False)
        beam(shelter, "Cedar side tie", (x, top + 5.72, cz - 3.74),
             (x, top + 5.72, cz + 3.74), .45, "804C60")
        festival_lantern(shelter, x, top + 4.70, cz - 2.61, .60,
                         light=False, tint="E3A879", entrance_paper=True)
    for z in (cz - 3.39, cz + 3.39):
        part(shelter, "Carved pavilion header", (cx, top + 5.75, z), (10.34, .53, .57),
             "804B60", material=cedar, collide=False)
        for direction in (-1, 1):
            beam(shelter, "Upturned cedar corbel", (cx + 4.54 * direction, top + 4.85, z),
                 (cx + 3.18 * direction, top + 5.80, z), .38, "995D6C")
    swept_roof(shelter, cx, top + 5.93, cz, 12.52, 9.80, 2.95, fine_tiles=False,
               signature=True, corner_sweep=1.25)
    sign(shelter, "LANTERNMAKERS’ OVERLOOK", west + .45, top + 5.81, cz, 8.78, 1.14,
         yaw=-90, tint="673E5C")

    seat = part(overlook, "Festival view cedar seat", (cx, top + .58, south - .91),
                (4.15, .23, .86), "A87366", material=cedar, class_name="Seat")
    seat.find("Properties/bool[@name='CanTouch']").text = "true"
    part(overlook, "Festival view bench back", (cx, top + 1.06, south - .53),
         (4.75, .63, .14), "8D5A61", material=cedar, collide=False)
    for direction in (-1, 1):
        part(overlook, "Festival view slate bench foot", (cx + 1.65 * direction, top + .25, south - .91),
             (.40, .50, .67), "98838F", material=slate, collide=False)

    for i, (x, y, z) in enumerate((
        (-229.23, 6.03, 58.06), (-219.46, 7.50, 58.12), (-213.0, 8.28, 58.28),
        (-206.72, 9.51, 59.0), (-199.38, 10.49, 60.24),
    )):
        garden_shelf(overlook, x, y + .11, z, 3.56, 2.34, .41, "7D885B", grass, collide=False)
        garden_prop(overlook, "bankRock", (x - .53, y + .10, z - .12), .20, 36 + 21 * i, "9C8996")
        garden_prop(overlook, "meadowGrass", (x + .39, y + .10, z + .11), .18, 23 + 25 * i, "B2AE6C")
        garden_prop(overlook, "mossFlowers", (x - .18, y + .09, z + .36), .18, 61 + 13 * i, "ECA6BE")
    for x, y, z, yaw, width, label in (
        (-227.16, 6.03, 32.72, 90, 5.59, "LANTERN OVERLOOK  ←"),
        (-235.65, 6.03, 50.38, 180, 4.90, "LANTERN OVERLOOK  →"),
        (-206.81, 9.72, 58.69, 90, 3.85, "MARKET STREET  →"),
    ):
        part(overlook, "Overlook wayfinding cedar post", (x, y + 1.26, z),
             (.30, 2.53, .30), "765065", material=cedar, collide=False)
        sign(overlook, label, x, y + 2.40, z, width, .90, yaw=yaw, tint="633E60")
