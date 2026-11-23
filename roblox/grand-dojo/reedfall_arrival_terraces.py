"""A planted rock stair on the west bank of the existing Reedfall curtains."""

from math import cos, radians, sin


# The water moves forward as it descends. Set each lower slab farther toward
# the plaza and keep the forward corners on the dry side of the water.
TERRACES = (
    # name, x, z, crown, height, across, depth, turn, vegetation
    ("Spring shoulder", 22.10, -46.22, 46.66, 8.18, 5.71, 5.82, -11, "pine"),
    ("Overhanging moss shelf", 21.32, -43.53, 37.46, 9.92, 6.48, 5.75, 12, "pine"),
    ("Blossom saddle", 20.23, -40.50, 28.40, 9.55, 6.39, 5.50, -8, "blossom"),
    ("Overflow garden foot", 22.79, -33.05, 20.45, 5.75, 3.78, 4.69, 12, None),
)

# A convex cap keeps the moss and its planting inside the bed. The asymmetric
# front lip exposes sunlit stone on the left and a recessed seam on the right.
OUTLINE = (
    (-.49, -.19), (-.38, -.48), (.23, -.51), (.50, -.21),
    (.45, .30), (.20, .49), (-.19, .53), (-.46, .19),
)
PROFILE = (
    # height fraction, span, x drift, depth drift
    (0, .83, -.04, -.37),
    (.58, .91, .06, -.12),
    (.80, .84, .01, -.02),
    (.92, 1, -.02, .04),
    (1, .91, -.03, 0),
)
RISERS = (
    ("786B7C", "766879", "7D6C7C", "877481", "8E7A85", "96808B", "9B828D", "8C7683"),
    ("736578", "716476", "75677A", "7D6F7F", "806D7F", "887282", "8E7687", "816F80"),
    ("8E7886", "897582", "897581", "917C86", "9F8590", "A88E97", "AB9296", "9C828C"),
    ("97808B", "907A87", "95808B", "9C8690", "AD9297", "B49B9E", "B89EA0", "A28A92"),
)
NOTCHES = (.11, -.15, .06, -.06, .12, -.13, .07, -.04)


def build_reedfall_arrival_terraces(parent, *, item, prop, part, triangle, beam, garden_prop,
                                   rock, grass, cedar, rock_variant, variant_field):
    terraces = item(parent, "Model", "Reedfall west bank terraces")
    prop(terraces, "token", "LevelOfDetail", 4)

    def face(model, points, color, label, material):
        first = len(model)
        triangle(model, *points, color, name=label, material=material, thickness=.12,
                 collide=False, shadow=False)
        if material == rock:
            for wedge in model[first:]:
                prop(wedge, "string", variant_field, rock_variant)

    def planter(model, key, position, scale, turn, color):
        first = len(model)
        garden_prop(model, key, position, scale, turn, color)
        for asset in model[first:]:
            shadow = asset.find("Properties/bool[@name='CastShadow']")
            if shadow is not None:
                shadow.text = "false"

    def crown(model, position, scale, species):
        x, y, z = position

        def point(a, b, c):
            return x + a * scale, y + b * scale, z + c * scale

        for a, b, width in (
            ((0, -.18, 0), (-.18, 1.44, .06), .22),
            ((-.18, 1.10, .06), (-.82, 1.82, .20), .125),
            ((-.18, 1.16, .06), (.69, 1.79, -.06), .14),
            ((-.18, 1.44, .06), (.19, 2.17, -.15), .13),
        ):
            branch = beam(model, "Reedfall sapling branch", point(*a), point(*b), width * scale, "75574C")
            branch.find("Properties/token[@name='Material']").text = str(cedar)
            prop(branch, "bool", "CastShadow", False)

        palette = (("587448", "789755", "91A760", "A2AD63") if species == "pine"
                   else ("A56284", "C782A2", "DC98AF", "E5AAA9"))
        for i, (a, b, c, width, rise, depth) in enumerate((
            (-.83, 1.87, .18, 1.68, .54, 1.11), (-1.23, 1.94, .30, .80, .34, .73),
            (-.61, 2.04, .41, 1.08, .35, .71), (.67, 1.82, -.06, 1.55, .52, 1.06),
            (1.08, 1.83, .13, .83, .37, .65), (.61, 1.98, .22, 1.04, .42, .79),
            (.13, 2.29, -.16, 1.60, .60, 1.09), (-.22, 2.40, -.06, 1.09, .40, .83),
            (.33, 2.48, -.31, .94, .36, .81),
        )):
            blob = part(model, "Reedfall sapling foliage", point(a, b, c),
                        (width * scale, rise * scale, depth * scale),
                        palette[i % 4], shape=0, collide=False, yaw=(i * 19) % 60)
            prop(blob, "bool", "CastShadow", False)

    for index, (name, x, z, y, height, width, depth, yaw, species) in enumerate(TERRACES):
        model = item(terraces, "Model", name)
        sine, cosine = sin(radians(yaw)), cos(radians(yaw))

        def locate(across, rise, reach):
            return (x + across * width * cosine + reach * depth * sine, y + rise,
                    z + reach * depth * cosine - across * width * sine)

        rings = []
        for fraction, span, drift_x, drift_z in PROFILE:
            rings.append([
                locate(u * span + drift_x, height * (fraction - 1) + NOTCHES[(i + index) % len(OUTLINE)],
                       v * span + drift_z)
                for i, (u, v) in enumerate(OUTLINE)
            ])

        for corner in range(len(OUTLINE)):
            next_corner = (corner + 1) % len(OUTLINE)
            if corner in (0, 1, 2):
                courses = ((rings[0], rings[-1], RISERS[0][corner]),)
            else:
                courses = [(lower, upper, colors[corner])
                           for lower, upper, colors in zip(rings, rings[1:], RISERS)]
            for lower, upper, color in courses:
                a, b, c, d = lower[corner], lower[next_corner], upper[next_corner], upper[corner]
                face(model, (a, b, d), color, "Weathered Reedfall stratum", rock)
                face(model, (b, c, d), color, "Weathered Reedfall stratum", rock)

        top = rings[-1]
        center = locate(-.03, .07, 0)
        visible_lip = index in (1, 2)
        cap_width, cap_depth = (.91, .87) if visible_lip else (.81, .78)
        cap = [
            (center[0] + (a - center[0]) * cap_width, b + .08, center[2] + (c - center[2]) * cap_depth)
            for a, b, c in top
        ]
        for i in range(len(top)):
            j = (i + 1) % len(top)
            face(model, (center, top[i], top[j]), "AD959A", "Exposed Reedfall capstone", rock)
            palette = ("9AB65F", "93AB5C", "A4B66A", "8CA85C") if visible_lip else (
                "859754", "8EA258", "84974D", "829355")
            face(model, ((center[0], center[1] + .09, center[2]), cap[i], cap[j]),
                 palette[i % len(palette)], "Reedfall moss cap", grass)

        # From the plaza the player sees the edge of the green turf and the
        # cut underneath, so let the moss curl over the exposed cap in places.
        for across, rise, reach, spread, tint in (
            (-.32, -.12, .30, .23, "7F914D"),
            (-.23, -.06, .40, .23, "92A15C"),
            (-.10, -.24, .44, .21, "83954D"),
            (.055, -.14, .43, .20, "93A35B"),
            (.18, -.13, .39, .17, "83934F"),
        ):
            color = ("A0AB61", "A8B969", "8EA85A", "93A958")[index % 4] if visible_lip else tint
            moss = part(model, "Moss rolling over the rock edge", locate(across, rise, reach),
                        (width * spread, (.79 if visible_lip else .56) + .18 * spread, depth * .15),
                        color, shape=0, collide=False, yaw=yaw)
            prop(moss, "bool", "CastShadow", False)

        for key, across, rise, reach, scale, color in (
            ("meadowCover", -.17, .12, .15, .113, "B4BD73"),
            ("meadowGrass", .13, .10, .22, .126, "B1B568"),
            ("rockVine", -.14, -.98, .45, .41, "9BA965"),
            ("mossFlowers", -.23, .15, .19, .091, "E39BB2"),
        ):
            planter(model, key, locate(across, rise, reach), scale, yaw + 31 + 18 * index, color)
        if species:
            crown(model, locate(-.12, .13, .08), (1.28, 1.0, 1.02)[index], species)
        if visible_lip:
            planter(model, "meadowCover", locate(.09, .18, .35), .19, yaw + 68, "AABC6A")
            planter(model, "mossFlowers", locate(-.27, .13, .30), .16, yaw + 104,
                    "F1ADBB" if species == "blossom" else "EAD1A0")
