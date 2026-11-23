"""Decorative masonry and timber joinery on the Frostglass road crossing."""

from math import atan2, degrees, hypot


def build_meltwater_bridge_art(
    parent, entry, exit, *, item, part, prop, slate, wood, metal, wood_variant, variant_field
):
    bridge = item(parent, "Model", "Meltwater bridge masonry and bracing")
    prop(bridge, "token", "ModelStreamingMode", 1)
    prop(bridge, "token", "LevelOfDetail", 4)
    dx, dy, dz = (end - start for start, end in zip(entry, exit))
    length = hypot(dx, dz)
    yaw = degrees(atan2(dx, dz))

    def point(t, side, height):
        return (
            entry[0] + t * dx - side * dz / length,
            height,
            entry[2] + t * dz + side * dx / length,
        )

    def grade(t):
        return entry[1] + t * dy

    def detail(name, position, size, tint, *, material=slate, facing=yaw, pitch=0, roll=0):
        piece = part(
            bridge, name, position, size, tint, yaw=facing, pitch=pitch, roll=roll,
            material=material, collide=False,
        )
        prop(piece, "bool", "CastShadow", False)
        if material == wood:
            prop(piece, "string", variant_field, wood_variant)

    def timber(name, start, end, width, height, tint):
        bx, by, bz = (b - a for a, b in zip(start, end))
        run = hypot(bx, bz)
        center = tuple((a + b) / 2 for a, b in zip(start, end))
        detail(
            name, center, (width, height, hypot(run, by)), tint, material=wood,
            facing=degrees(atan2(bx, bz)), pitch=-degrees(atan2(by, run)),
        )

    for side in (-1, 1):
        # Run the tie below and outside the existing slate apron so the two materials read separately.
        timber(
            "Long cedar deck tie", point(.035, side * 6.06, grade(.035) - 1.00),
            point(.965, side * 6.06, grade(.965) - 1.00), .43, .63, "74515B",
        )
        timber(
            "Amber cedar nosing", point(.035, side * 6.27, grade(.035) - .80),
            point(.965, side * 6.27, grade(.965) - .80), .13, .14, "B78D75",
        )

        for t, direction in ((.15, 1), (.85, -1)):
            heel = grade(t)
            bottom, shoulder = -4.81, heel - .80
            span = shoulder - bottom
            # The old pier core shows in the recessed joints between the dressed courses.
            courses = (
                (0, .15, 3.42, 3.73, "787786"),
                (.15, .34, 3.08, 3.39, "93909C"),
                (.34, .55, 2.94, 3.25, "A49CA7"),
                (.55, .76, 2.83, 3.16, "92909F"),
                (.76, .94, 2.76, 3.10, "A79DAB"),
                (.94, 1, 3.22, 3.44, "C3B8C2"),
            )
            for a, b, width, depth, tint in courses:
                detail(
                    "Dressed slate pier course", point(t, side * 5.66, bottom + span * (a + b) / 2),
                    (width, span * (b - a) - .075, depth), tint,
                )

            # A short knee projects from each pier toward midspan and ties the facing back to the deck.
            reach = t + direction * 4.5 / length
            timber(
                "Cedar bridge knee", point(t, side * 6.95, heel - 4.27),
                point(reach, side * 6.10, grade(reach) - 1.22), .48, .71, "926C67",
            )
            detail("Forged bridge strap", point(t, side * 7.07, heel - 2.51),
                   (.17, .72, 1.73), "6B6874", material=metal)
            detail("Bridge strap pin", point(t, side * 7.18, heel - 2.50),
                   (.12, .20, .20), "BE9570", material=metal)

        for t in (.055, .945):
            heel = grade(t)
            # Only dress the outer shoulders of the existing gateway posts.
            detail("Frostglass gate slate shoe", point(t, side * 6.24, heel + .29),
                   (.86, .58, .95), "93909D")
            detail("Frostglass gate shoulder collar", point(t, side * 6.23, heel + .65),
                   (.74, .14, .80), "C3A07C", material=metal)
            detail("Frostglass gate shoulder inlay", point(t, side * 6.405, heel + 3.07),
                   (.12, 3.60, .19), "B48372", material=wood)
            detail("Frostglass gate upper collar", point(t, side * 6.23, heel + 4.88),
                   (.75, .18, .82), "B98D6E", material=metal)

    crown = (
        (-7.02, -5.69, .63, .20, "405078"),
        (-5.69, -4.23, .20, 0, "35466C"),
        (-4.23, 4.23, 0, 0, "304165"),
        (4.23, 5.69, 0, .20, "35466C"),
        (5.69, 7.02, .20, .63, "405078"),
    )
    eave_run, eave_rise = 1.08, .63
    for t in (.055, .945):
        heel = grade(t)
        detail("Frostglass roof ridge bearer", point(t, 0, heel + 6.87),
               (9.35, .85, .38), "655561", material=wood)
        for start, end, low, high, tint in crown:
            side = (start + end) / 2
            rise = (low + high) / 2
            width = hypot(end - start, high - low)
            roll = -degrees(atan2(high - low, end - start))
            for face in (-1, 1):
                pitch = face * degrees(atan2(eave_rise, eave_run))
                detail(
                    "Frostglass indigo gate eave",
                    point(t + face * eave_run / (2 * length), side, heel + 7.08 + rise),
                    (width + .07, .25, hypot(eave_run, eave_rise) + .05), tint,
                    pitch=pitch, roll=roll,
                )
            outer_tip = abs(side) > 6
            detail(
                "Frostglass swept ridge coping", point(t, side, heel + 7.44 + rise),
                (width + .05, .17, .24), "CEA475" if outer_tip else "536087",
                material=metal if outer_tip else slate, roll=roll,
            )
        for face in (-1, 1):
            detail("Frostglass eave front edge", point(t + face * eave_run / length, 0, heel + 6.80),
                   (8.50, .18, .20), "263656")

    # Dress the lookout's two outer footings and link their knees to the cantilever above.
    for t in (.39, .61):
        heel = grade(t)
        for low, high, width, tint in (
            (-4.82, -2.50, 2.45, "777584"),
            (-2.50, .67, 2.16, "918C9C"),
            (.67, heel - .94, 1.90, "A69CAA"),
            (heel - .94, heel - .56, 2.38, "BDB1BC"),
        ):
            detail("Lookout slate footing course", point(t, 13.18, (low + high) / 2),
                   (width, high - low - .08, width), tint)
        timber("Lookout cedar cantilever brace", point(t, 13.17, heel - 3.35),
               point(t, 9.21, heel - .63), .52, .73, "986F67")
    timber("Lookout cedar sill", point(.365, 13.99, grade(.365) - .68),
           point(.635, 13.99, grade(.635) - .68), .43, .47, "805C62")

    return bridge
