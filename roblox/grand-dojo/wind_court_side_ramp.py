"""The stair-free side approach from Skywalk's square to Wind Court."""

from math import atan2, degrees, hypot


WIDTH = 3.86


def build_wind_court_ramp(court, x, z, square, deck, *, item, prop, part, route, beam,
                          sign, festival_lantern, slate, limestone, wood, metal,
                          stone_variant, variant_field):
    ramp = item(court, "Model", "Wind Court side ramp")
    prop(ramp, "token", "ModelStreamingMode", 1)
    prop(ramp, "token", "LevelOfDetail", 4)
    center = x - 7.55
    approach_z, landing_z = z + 7.25, z - 12.60
    lower, upper = square + .011, deck + .004
    run, rise = approach_z - landing_z, upper - lower
    pitch = degrees(atan2(rise, run))

    def level(at_z):
        return lower + rise * ((approach_z - at_z) / run)

    route(ramp, "Stair-free Wind Court ramp",
          [(center, lower, approach_z), (center, upper, landing_z)],
          WIDTH, "A4969C", surface=slate, stone_footings=False, join_overlap=.12, railings=False)

    def detail(name, at, size, tint, material, **kwargs):
        obj = part(ramp, name, at, size, tint, material=material, collide=False, **kwargs)
        prop(obj, "bool", "CastShadow", False)
        return obj

    rows = 12
    for index in range(rows):
        mid_z = approach_z - (index + .50) * run / rows
        # A narrow seam on each course reads as paving while the deck remains continuous.
        for offset, width, tint in ((-.98, 1.82, "BFAAAA"), (.92, 1.92, "AD9BA6")):
            flagstone = detail("Pale side-ramp stone", (center + offset, level(mid_z) + .018, mid_z),
                               (width, .026, (hypot(run, rise) / rows) - .056),
                               tint, limestone, pitch=pitch)
            prop(flagstone, "string", variant_field, stone_variant)

    for side in (-1, 1):
        px = center + side * 1.82
        rear = landing_z + .87
        front = approach_z - 1.36
        for lift, width, tint in ((.51, .16, "705466"), (1.35, .22, "8E5E61")):
            rail = beam(ramp, "Wind Court ramp cedar rail",
                        (px, level(front) + lift, front), (px, level(rear) + lift, rear),
                        width, tint, collide=True)
            prop(rail, "bool", "CastShadow", False)
        for index in range(6):
            pz = front + (rear - front) * index / 5
            py = level(pz)
            detail("Ramp square cedar post", (px, py + .69, pz), (.36, 1.44, .38), "805365", wood)
            detail("Ramp bronze newel cap", (px, py + 1.44, pz), (.46, .13, .49), "BC9869", metal)

        for pz in (z + 1.68, z - 2.52, z - 6.81, z - 10.31):
            height = max(.26, level(pz) - square - .42)
            detail("Slate ramp underpinning", (px, square + height / 2, pz),
                   (.74, height, 1.36), "918391", slate)
            detail("Honed ramp underpinning cap", (px, square + height, pz),
                   (.90, .19, 1.50), "A88D99", slate)

    sx, sz = x - 11.92, z + 4.63
    detail("Wind Court ramp sign shoe", (sx, square + .19, sz), (.71, .39, .73), "8E8191", slate)
    detail("Wind Court ramp sign post", (sx, square + 1.57, sz), (.32, 3.17, .35), "754D61", wood)
    sign(ramp, "WIND COURT", sx, square + 2.79, sz + .21, 3.79, .71, 0, "65516B", face_only=True)
    sign(ramp, "RAMP  →", sx, square + 2.13, sz + .21, 2.99, .57, 0, "65516B", face_only=True)
    festival_lantern(ramp, sx, square + 3.56, sz, .39, light=False)
