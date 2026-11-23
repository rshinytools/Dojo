"""Tapered reed heads and groundcover for the playable plaza arrival."""

from math import cos, radians, sin


def build_arrival_bank_planting(plaza, *, item, prop, beam, triangle, garden_prop, grass):
    planting = item(plaza, "Model", "Arrival reed and meadow detail")
    prop(planting, "token", "ModelStreamingMode", 1)
    prop(planting, "token", "LevelOfDetail", 4)

    def stalk(name, start, end, width, tint):
        stem = beam(planting, name, start, end, width, tint)
        prop(stem, "bool", "CastShadow", False)

    def folded_leaf(origin, bearing, reach, rise, width, tints):
        x, y, z = origin
        direction = radians(bearing)
        dx, dz = sin(direction), cos(direction)

        def point(length, height, transverse=0):
            return x + dx * length + dz * transverse, y + height, z + dz * length - dx * transverse

        outer = point(reach * .56, rise * .75, width * .56)
        inner = point(reach * .56, rise * .75, -width * .44)
        spine = point(reach * .58, rise * .89)
        tip = point(reach, rise)
        for face, tint in zip(((origin, outer, spine), (origin, spine, inner),
                               (outer, tip, spine), (spine, tip, inner)), tints):
            triangle(planting, *face, tint, name="Folded arrival sedge", thickness=.021,
                     material=grass, shadow=False)

    # Forward-facing leaves anchor the cream heads in the existing raised bank.
    for origin, bearing, reach, rise, width, tints in (
        ((11.20, 1.00, 64.10), -105, .95, .58, .23, ("8D9F46", "617737", "BEBD62", "879E43")),
        ((10.82, 1.01, 64.08), -132, .76, .79, .20, ("A7AD50", "6E8441", "C6BD70", "929D4D")),
        ((10.85, 1.00, 64.16), -78, .71, .54, .25, ("8CA544", "657D39", "B5B957", "859A43")),
        ((11.19, 1.02, 64.21), -165, .72, .91, .19, ("8CA449", "748842", "BDBD69", "9CAB4D")),
        ((11.29, 1.01, 64.08), 91, .74, .62, .21, ("A7A949", "727E37", "C6B85C", "919746")),
        ((11.48, 1.02, 64.20), 142, .86, .61, .19, ("8CA342", "66813C", "A6B54E", "8D9C40")),
    ):
        folded_leaf(origin, bearing, reach, rise, width, tints)

    # Four plumes turn into the open frame. Keeping the roots north of the
    # east approach leaves the walking space around the map unplanted.
    for x, y, z, tall, arc in (
        (10.86, 1.01, 63.98, 1.01, .86),
        (11.10, 1.02, 64.37, .95, .91),
        (11.37, 1.02, 64.13, 1.16, .94),
        (11.61, 1.02, 64.24, 1.10, .87),
    ):
        root = x, y, z
        elbow = x - .10, y + tall * .57, z - .14
        neck = x - .28, y + tall * .94, z - .18
        stalk("Olive arrival reed stalk", root, elbow, .042, "8B954D")
        stalk("Sunlit arrival reed stalk", elbow, neck, .031, "B5AB63")

        def head(t):
            return x - .28 - arc * t, y + tall * .94 + .58 * t - .46 * t * t, z - .18 - .17 * t

        for start, end, width, tint in (
            (0, .37, .062, "D6BD84"), (.37, .71, .083, "EAD19C"), (.71, 1, .050, "F6E2B6"),
        ):
            stalk("Bent ivory plume stem", head(start), head(end), width, tint)

        for t, fan, tint in ((.17, .11, "D8BD84"), (.32, .17, "E6C993"), (.47, .21, "F3DCA8"),
                             (.61, .20, "FAE2AD"), (.74, .15, "F0D6A3"), (.86, .10, "F7DFAD")):
            center = head(t)
            for side, shade in ((-1, tint), (1, "EBD3A4")):
                feather = center[0] - .22 + t * .03, center[1] + side * fan, center[2] + .026 * side
                stalk("Sunlit plume feather", center, feather, .043 - .017 * t, shade)

    for key, origin, scale, bearing, tint in (
        ("meadowGrass", (10.96, 1.03, 64.04), .071, 81, "B4C36A"),
        ("meadowCover", (11.83, 1.03, 64.25), .083, 29, "A5B457"),
        ("meadowGrass", (12.23, 1.02, 64.48), .066, 41, "9BAC59"),
        ("meadowGrass", (12.15, .91, 55.14), .075, 78, "B4C16F"),
        ("meadowCover", (11.55, .93, 55.27), .065, 122, "A1B25F"),
        ("meadowGrass", (-3.53, .19, 58.01), .053, 71, "BAC96D"),
        ("meadowGrass", (-3.53, .19, 59.07), .049, 17, "B4C264"),
        ("meadowCover", (-3.56, .18, 59.57), .048, 94, "A7BE60"),
        ("meadowGrass", (-3.57, .19, 48.65), .045, 13, "B2C267"),
        ("meadowGrass", (-3.58, .18, 47.82), .040, 67, "B2C86F"),
        ("tallReeds", (-3.54, .19, 58.46), .080, 111, "A8AE55"),
        ("meadowGrass", (-10.06, .17, 62.88), .066, 19, "AFBE60"),
        ("meadowCover", (-10.72, .17, 63.39), .069, 93, "9FB356"),
        ("meadowGrass", (-8.95, .18, 60.81), .075, 148, "B8C967"),
    ):
        garden_prop(planting, key, origin, scale, bearing, tint)

    for origin, bearing, reach, rise in (
        ((-3.55, .19, 57.92), 261, .24, .50),
        ((-3.43, .19, 58.19), 166, .37, .62),
        ((-3.59, .19, 58.85), 221, .34, .54),
        ((-3.45, .19, 59.43), 279, .36, .49),
    ):
        folded_leaf(origin, bearing, reach, rise, .13,
                    ("99AD50", "738940", "BEC96C", "A1AD48"))
