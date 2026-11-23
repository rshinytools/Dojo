"""Weathered slate terraces and planting around the Reedfall curtains."""

from math import cos, radians, sin

from south_valley_backdrop import hillside_cedar


# Each top is set into existing cliff stone. The two right shelves beside
# the side spill have narrower forward noses so the small curtain shows.
LEDGES = (
    (23.03, 37.12, -42.65, 4.55, 5.95, 4.18, -19, "83994F", "cedar"),
    (36.58, 33.44, -44.17, 5.85, 4.42, 4.17, 16, "748C4F", None),
    (37.86, 40.33, -44.88, 5.19, 4.12, 4.08, -9, "7B9553", "cedar"),
    (40.06, 26.24, -44.22, 6.24, 5.61, 5.10, 23, "768E4C", "blossom"),
    (25.30, 17.92, -35.02, 4.36, 5.16, 4.34, -20, "819A58", None),
    (38.43, 16.91, -34.04, 4.72, 4.69, 3.66, 23, "859D55", "cedar"),
    (25.23, 5.20, -27.94, 3.48, 3.24, 2.18, 14, "768D4C", None),
    (23.91, 43.65, -48.27, 5.18, 4.41, 3.24, -21, "879B55", "blossom"),
    (36.53, 46.29, -47.82, 5.19, 3.95, 3.55, 29, "7E9450", "cedar"),
    (41.24, 30.55, -50.0, 6.75, 4.67, 4.02, -14, "72894F", "cedar"),
    (23.34, 30.81, -39.58, 4.68, 7.44, 5.20, 12, "829654", None),
)
OUTLINE = ((-.48, -.08), (-.41, -.43), (.18, -.50),
           (.51, -.17), (.35, .43), (-.24, .48))


def build_reedfall_ledge_gardens(parent, *, item, prop, part, triangle, garden_prop,
                                  showcase_tree, cedar_part, slate, rock, grass, rock_variant,
                                  variant_field):
    garden = item(parent, "Model", "Planted cascade ledges")
    for index, (x, y, z, width, depth, root_height, yaw, moss, tree) in enumerate(LEDGES):
        group = item(garden, "Model", f"Reedfall garden shelf {index + 1}")
        sine, cosine = sin(radians(yaw)), cos(radians(yaw))
        contours = []
        for span, drop, setback in ((.76, root_height, .37), (1.03, .67, .13), (.91, 0, 0)):
            ring = []
            for corner, (offset_x, offset_z) in enumerate(OUTLINE):
                across = offset_x * width * span
                reach = (offset_z * span - setback) * depth
                ripple = (.08, -.12, .09, -.04, .13, -.035)[(corner + index) % 6]
                ring.append((x + across * cosine + reach * sine, y - drop + ripple,
                             z + reach * cosine - across * sine))
            contours.append(ring)

        root, shoulder, cap = contours
        for corner in range(len(root)):
            next_corner = (corner + 1) % len(root)
            # The lighter weathered layer folds around the exposed lip.
            # One continuous stone face is enough on the backs of the ledges.
            courses = ((root, cap, "80707D"),)
            if corner >= 3:
                tint = ("99848F", "AC9A9E", "957E8A")[(corner + index) % 3]
                courses = ((root, shoulder, "796B79"), (shoulder, cap, tint))
            for lower, upper, tint in courses:
                start = len(group)
                triangle(group, lower[corner], lower[next_corner], upper[corner], tint,
                         name="Fractured slate course", thickness=.16, material=rock, shadow=False)
                triangle(group, upper[corner], lower[next_corner], upper[next_corner], tint,
                         name="Fractured slate course", thickness=.16, material=rock, shadow=False)
                for wedge in group[start:]:
                    prop(wedge, "string", variant_field, rock_variant)

        # Keep a narrow uneven stone lip around each moss cap.
        inner = [(x + (a - x) * .89, b + .075, z + (c - z) * .86) for a, b, c in cap]
        for a, b, c, d in zip(cap[1:-1], cap[2:], inner[1:-1], inner[2:]):
            triangle(group, inner[0], c, d, moss, name="Mossy shelf crown",
                     thickness=.19, material=grass, shadow=False)
            triangle(group, cap[0], a, b, "A38D97", name="Weathered slate cap",
                     thickness=.11, material=slate, shadow=False)

        hand = -1 if index % 2 else 1
        for key, dx, floor, dz, scale, tint in (
            ("bankRock", .24, -.32, -.12, .28, "9C8A93"),
            ("rockVine", -.16, -1.08, .28, .53, "9BB069"),
            ("meadowCover", -.10, .07, .06, .22, "9EB676"),
            ("meadowGrass", -.25, .09, .23, .13, "B3BF75"),
            ("mossFlowers", .16, .08, .24, .21, "E4ABC3"),
        ):
            garden_prop(group, key, (x + width * dx * hand, y + floor, z + depth * dz),
                        scale, yaw + 37 + index * 13, tint)
        if index in (0, 2, 3, 5, 7, 8, 10):
            for across, reach, spread, tint in (
                (-.22, .31, .32, "789548"), (.04, .34, .30, "8EA652"), (.27, .24, .27, "6D8848"),
            ):
                cushion = part(group, "Moss cushion at the exposed lip",
                               (x + across * width, y + .11, z + reach * depth),
                               (width * spread, .38, depth * .28), tint,
                               material=grass, shape=0, collide=False, yaw=yaw)
                prop(cushion, "bool", "CastShadow", False)
        tree_x, tree_z = x + hand * width * .09, z + depth * .14
        if tree == "blossom":
            showcase_tree(group, tree_x, tree_z, True, .35 if index < 6 else .33,
                          yaw + 38, y + .04, compact=True, height_scale=.91, crown_spread=1.18)
        elif tree == "cedar":
            hillside_cedar(cedar_part, group, tree_x, y + .04, tree_z,
                           .48 if index in (0, 2, 8) else .39, index)
