"""Shallow water and low planting at the near corner of Festival Canal."""


def build_arrival_lotus_cove(parent, *, item, prop, part, triangle, garden_prop,
                             flowering_lotus, smooth, neon):
    cove = item(parent, "Model", "Arrival lotus cove")
    prop(cove, "token", "ModelStreamingMode", 1)

    # Widen the bright shallows as the inlet opens toward the approach.
    rows = (
        (59.82, -8.31, .75),
        (60.99, -7.98, 2.51),
        (62.43, -7.74, 2.96),
        (63.66, -7.43, 2.67),
    )
    for index, ((start_z, start_x, start_width), (end_z, end_x, end_width)) in enumerate(zip(rows, rows[1:])):
        edge_fade = (.08, .04, .15)[index]
        for lo, hi, tint, transparency in (
            (-1.0, -.48, "367D94", .64),
            (-.48, .51, "3FA7B1", .48),
            (.51, 1.0, "68BBAC", .61),
        ):
            a = (start_x + lo * start_width, .061, start_z)
            b = (start_x + hi * start_width, .061, start_z)
            c = (end_x + hi * end_width, .061, end_z)
            d = (end_x + lo * end_width, .061, end_z)
            for face in ((a, b, c), (a, c, d)):
                triangle(cove, *face, tint, name="Lotus cove turquoise shallows",
                         thickness=.014, material=smooth, transparency=transparency + edge_fade,
                         shadow=False)

    for x, z, width, depth, yaw, tint, transparency in (
        (-10.12, 60.54, .95, .11, -11, "77C8C6", .69),
        (-8.85, 60.68, .71, .11, 9, "94D6CD", .67),
        (-7.47, 61.09, .83, .09, -6, "80C8C2", .64),
        (-6.06, 60.85, .94, .11, -9, "B1DED4", .67),
        (-5.18, 61.51, .62, .10, -4, "A4D7CF", .59),
        (-8.90, 62.07, 1.10, .12, 8, "8BCBC4", .62),
        (-10.52, 63.02, .80, .13, 13, "71BCC4", .64),
        (-7.08, 62.79, 1.22, .12, -10, "9AD5CD", .60),
        (-6.04, 63.22, .77, .09, -5, "A9DAD0", .62),
    ):
        surface = part(cove, "Broken turquoise surface ripple", (x, .083, z),
                       (width, .018, depth), tint, yaw=yaw, shape=0, material=smooth,
                       transparency=transparency, collide=False)
        prop(surface, "bool", "CastShadow", False)

    for x, z, width, angle in (
        (-10.37, 60.27, .53, -8), (-9.71, 60.87, .67, 7),
        (-9.65, 61.44, .52, -7), (-9.23, 62.22, .65, 11),
        (-8.96, 62.63, .77, -5), (-8.47, 63.22, .59, -2),
    ):
        fleck = part(cove, "Cove sunset fleck", (x, .098, z),
                     (width, .014, .079), "FFDB9F", yaw=angle, shape=0, material=neon,
                     transparency=.38, collide=False)
        prop(fleck, "bool", "CastShadow", False)

    flowering_lotus(cove, -6.88, 61.78, .81, 43)
    for key, position, scale, yaw, tint in (
        ("bankRock", (-4.58, -.21, 63.28), .14, 43, "8C8494"),
        ("bankRock", (-4.53, -.23, 61.91), .095, 111, "A18E93"),
        ("bankRock", (-10.60, -.22, 63.84), .104, 61, "907D88"),
        ("meadowCover", (-4.19, .18, 63.13), .087, 72, "B0B56B"),
        ("meadowGrass", (-4.29, .17, 63.55), .073, 17, "B5BB62"),
        ("grassBlade", (-4.19, .18, 63.77), .31, 58, "D7BE82"),
        ("cattails", (-4.71, -.10, 63.20), .135, 131, "ABB570"),
        ("mossFlowers", (-4.19, .17, 63.43), .081, 45, "E9ACBA"),
        ("lilyPads", (-11.19, .082, 62.45), .29, 96, None),
    ):
        garden_prop(cove, key, position, scale, yaw, tint)

    for detail in cove.iter("Item"):
        shadow = detail.find("Properties/bool[@name='CastShadow']")
        if shadow is not None:
            shadow.text = "false"
        elif detail.get("class") in ("Part", "WedgePart", "MeshPart"):
            prop(detail, "bool", "CastShadow", False)
