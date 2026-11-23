"""Native paper and timber lantern finishes for the plaza arrival."""

from math import cos, radians, sin, tan


def _turn(origin, offset, yaw, scale):
    x, y, z = (coordinate * scale for coordinate in offset)
    c, s = cos(radians(yaw)), sin(radians(yaw))
    return origin[0] + x * c + z * s, origin[1] + y, origin[2] - x * s + z * c


def _lantern_parts(parent, origin, yaw, scale, name, *, item, prop, part, wood, metal,
                   variant_field, cedar_variant, brass_variant):
    model = item(parent, "Model", name)
    prop(model, "token", "ModelStreamingMode", 1)

    def detail(label, offset, size, tone, material, *, twist=0, roll=0, shape=1):
        geometry = part(model, label, _turn(origin, offset, yaw, scale),
                        tuple(axis * scale for axis in size), tone,
                        yaw=yaw + twist, roll=roll, shape=shape, material=material, collide=False)
        prop(geometry, "bool", "CastShadow", False)
        if material == wood:
            prop(geometry, "string", variant_field, cedar_variant)
        if material == metal:
            prop(geometry, "string", variant_field, brass_variant)
        return geometry

    return model, detail


def amber_paper(tint):
    factors = (.92, .77, .59)
    channels = (int(tint[index:index + 2], 16) for index in (0, 2, 4))
    return "".join(f"{round(channel * factor):02X}" for channel, factor in zip(channels, factors))


def craft_hanging_lantern(parent, x, y, z, scale, *, item, prop, part, neon, wood, metal,
                          variant_field, cedar_variant, brass_variant,
                          entrance_paper=False, tint=None):
    """Return the original light mount after placing a new paper shell."""
    stretch = 1.12 if entrance_paper else 1
    old_width = 1.38 if entrance_paper else 1.56
    old_paper = tint or ("C48F60" if entrance_paper else "FFDEA5")
    mount = part(parent, "Round amber paper lantern", (x, y, z),
                 (old_width * scale, 1.98 * stretch * scale, old_width * scale),
                 old_paper, material=neon, shape=0, collide=False, transparency=1)
    prop(mount, "bool", "CastShadow", False)
    _, place = _lantern_parts(parent, (x, y, z), 0, scale, "Hand-ribbed festival lantern",
                              item=item, prop=prop, part=part, wood=wood, metal=metal,
                              variant_field=variant_field, cedar_variant=cedar_variant,
                              brass_variant=brass_variant)

    # Stacked paper bands suggest the slightly squared profile of a stretched
    # lantern. The two middling bands carry the brightest warm paper.
    stops = (-.90, -.70, -.47, -.23, 0, .23, .47, .70, .90)
    paper = (
        (1.12, "FFC367"), (1.37, "FFD178"), (1.54, "FFDF90"), (1.60, "FFE7A0"),
        (1.60, "FFE6A4"), (1.54, "FFDC91"), (1.37, "FFD07A"), (1.12, "FFC471"),
    )
    for index, (width, tone) in enumerate(paper):
        bottom, top = stops[index:index + 2]
        place("Luminous folded paper", (0, (bottom + top) * stretch / 2, 0),
              ((top - bottom) * stretch + .006, width, width), amber_paper(tone), neon, roll=90, shape=2)
    for index, elevation in enumerate(stops[1:-1], start=1):
        width = max(paper[index - 1][0], paper[index][0]) + .026
        place("Hand-set bamboo rib", (0, (elevation + .006 * (-1) ** index) * stretch, 0),
              (.042, width, width), "C5904F", wood, roll=90, shape=2)

    for direction in (-1, 1):
        place("Bronze lantern ferrule", (0, direction * .895 * stretch, 0),
              (.110, .99, .99), "AB6F40", metal, roll=90, shape=2)
        place("Gilded lantern edge", (0, direction * .850 * stretch, 0),
              (.028, 1.10, 1.10), "DAA35A", metal, roll=90, shape=2)
    place("Cedar suspension button", (0, .986 * stretch, 0), (.13, .18, .18),
          "6F3E2F", wood, roll=90, shape=2)
    place("Woven tassel binding", (0, -.976 * stretch, 0), (.16, .11, .17),
          "B75832", wood)
    place("Carmine festival tassel", (0, -1.10 * stretch, 0), (.12, .23, .12),
          "913D30", wood, roll=-4)
    place("Tassel gilded neck", (0, -1.01 * stretch, 0), (.155, .045, .15),
          "DDAC5F", metal)
    return mount


def craft_board_lantern(parent, x, y, z, scale, *, item, prop, part, neon, wood, metal,
                        variant_field, cedar_variant, brass_variant, yaw=32):
    """Dress the existing board's stone rest with a low octagonal lantern."""
    housing, place = _lantern_parts(parent, (x, y, z), yaw, scale, "Arrival paper lantern",
                                    item=item, prop=prop, part=part, wood=wood, metal=metal,
                                    variant_field=variant_field, cedar_variant=cedar_variant,
                                    brass_variant=brass_variant)

    for y, width, height, tint in (
        (.08, .65, .16, "6D4232"), (.232, .58, .15, "86604A"),
        (.343, .72, .09, "673A2A"), (.425, .84, .095, "9B5936"),
        (1.64, .86, .105, "855036"), (1.753, .97, .114, "6B412E"),
        (1.864, .79, .108, "85573D"), (1.951, .57, .067, "9F6B45"),
    ):
        place("Stacked cedar housing", (0, y, 0), (width, height, width), tint, wood)
    for y, width in ((.385, .77), (1.698, .905)):
        place("Aged brass housing edge", (0, y, 0), (width, .035, width), "BE8D52", metal)

    # Paper faces meet at eight timber seams. Slight variations in the warm
    # faces hold their depth on low graphics settings as well as in bloom.
    apothem = .376
    half_side = apothem * tan(radians(22.5))
    for index in range(8):
        twist = index * 45
        angle = radians(twist)
        s, c = sin(angle), cos(angle)
        for height, depth, tint in (
            (.662, .402, "FFD47D"), (1.035, .345, "FFE5A1"), (1.409, .401, "FFD78B"),
        ):
            place("Octagonal amber paper pane", (apothem * s, height, apothem * c),
                  (2 * half_side + .015, depth, .028), amber_paper(tint), neon, twist=twist)
        for height in (.782, 1.034, 1.286):
            place("Thin brass pane rib", ((apothem + .021) * s, height, (apothem + .021) * c),
                  (2 * half_side + .021, .025, .025), "BE8B51", metal, twist=twist)
        edge = apothem / cos(radians(22.5))
        angle = radians(twist + 22.5)
        place("Vertical cedar paper seam", (edge * sin(angle), 1.046, edge * cos(angle)),
              (.060, 1.19, .065), "71432E", wood, twist=twist + 22.5)
    return housing
