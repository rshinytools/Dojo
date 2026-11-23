"""Decorative Fighting Ring details in final, world-space ring coordinates."""


def build_ring_arrival_details(parent, *, center, deck_lift, item, part, prop, beam, banner,
                               slate, limestone, wood, metal, stone_variant, variant_field):
    """Give the existing stair threshold and covered bay more visual depth."""
    details = item(parent, "Model", "Ring threshold dressings")

    def trim(group, name, location, size, tint, material):
        piece = part(group, name, location, size, tint, material=material, collide=False)
        prop(piece, "bool", "CastShadow", False)

    # Keep each apron wing outside the stair cheeks. Its face sits behind the
    # existing apron pennants, leaving them the strongest color at this height.
    stone_colors = ("9F8386", "947C83", "A88988", "8F767D", "967B80")
    foundation_top = 2.4 + deck_lift
    for side in (-1, 1):
        x = center + side * 18.54
        for row, (bottom, top) in enumerate((
            (.14, 1.31), (1.36, 2.62), (2.67, 3.78), (3.83, foundation_top-.20),
        )):
            edges = (-10.35, -6.75, -2.72, 1.90, 7.42, 12.63, 16.16, 20.36) if row % 2 else (
                -10.35, -4.94, -.82, 4.42, 9.69, 14.66, 20.36,
            )
            for index, (start, finish) in enumerate(zip(edges, edges[1:])):
                stone = part(details, "Hewn basalt side course", (x, (bottom+top)/2, (start+finish)/2),
                             (.13, top-bottom, finish-start-.045),
                             stone_colors[(row*2+index) % len(stone_colors)],
                             material=slate, collide=False)
                prop(stone, "string", variant_field, stone_variant)
                prop(stone, "bool", "CastShadow", False)
        trim(details, "Slate sidewall coping", (x, foundation_top-.11, 5),
             (.29, .19, 30.86), "A38B8A", slate)
    stone_courses = (
        (1.59, .40, (-4.86, -2.65, -.42, 2.26, 4.86)),
        (2.03, .40, (-4.86, -3.63, -1.45, 1.22, 3.55, 4.86)),
        (2.48, .43, (-4.86, -2.81, -.72, 1.70, 3.86, 4.86)),
        (2.48 + deck_lift*.54, .52, (-4.86, -3.51, -1.46, .88, 3.11, 4.86)),
    )
    for side in (-1, 1):
        x = center + side * 13.02
        for name, y, z, width, height, depth, tint, material in (
            ("Rose slate apron backing", 1.79+deck_lift/2, 20.48, 9.76, .94+deck_lift, .20, "725F6A", slate),
            ("Slate apron course sill", 1.335, 20.54, 9.82, .14, .30, "81707B", slate),
            ("Shadow under apron coping", 2.265+deck_lift, 20.54, 9.82, .09, .29, "82676D", slate),
            ("Honed sandstone apron coping", 2.435+deck_lift, 20.57, 9.96, .25, .31, "C5A88F", limestone),
            ("Beveled sandstone coping crown", 2.585+deck_lift, 20.53, 9.86, .05, .26, "D9B99C", limestone),
            ("Cedar sill above coping", 2.64+deck_lift, 20.52, 9.76, .06, .23, "754C3C", wood),
            ("Cedar apron fascia", 3.005+deck_lift, 20.48, 9.74, .67, .22, "965C46", wood),
            ("Apron fascia bronze fillet", 3.25+deck_lift, 20.61, 9.74, .065, .07, "BF8E58", metal),
        ):
            trim(details, name, (x, y, z), (width, height, depth), tint, material)
        for row, (y, height, edges) in enumerate(stone_courses):
            for column, (left, right) in enumerate(zip(edges, edges[1:])):
                stone_x = x + side * (left + right) / 2
                tint = stone_colors[(column + row * 2) % len(stone_colors)]
                trim(details, "Hewn rose slate apron stone", (stone_x, y, 20.54),
                     (right - left - .045, height, .26), tint, slate)
        for edge in (-1, 1):
            end_x = x + edge * 4.62
            trim(details, "Cedar apron end join", (end_x, 2.96+deck_lift, 20.606),
                 (.27, .56, .083), "754C3C", wood)
            trim(details, "Cedar fascia fastener", (end_x, 2.97+deck_lift, 20.666),
                 (.13, .13, .037), "D49D5E", metal)

    # Suspend the new standards from the existing cross tie by the fighting
    # floor. They sit behind the trainees and above Reedguard's head.
    for side in (-1, 1):
        x, y, z, scale = center + side * 8.05, 12.06, 7.83, 1.06
        standard = item(details, "Model", "Suspended reed standard")
        banner(standard, x, y, z, scale=scale, vermilion=True)
        for offset in (-.94, .94):
            hanger_x = x + offset * scale
            beam(standard, "Cedar roof standard hanger", (hanger_x, 19.06, 7.42),
                 (hanger_x, y + 2.08 * scale, z), .095, "7D513E")
        for piece in standard.iter("Item"):
            if (piece.attrib["class"] in ("Part", "WedgePart")
                    and piece.find("Properties/bool[@name='CastShadow']") is None):
                prop(piece, "bool", "CastShadow", False)

