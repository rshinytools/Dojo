"""Decorative Fighting Ring details in final, world-space ring coordinates."""

from math import atan2, degrees, hypot


def build_ring_paper_lantern(parent, x, y, z, scale, *, item, part, prop, neon, wood, metal,
                             lantern_light, light_profile, standing=False):
    """A square amber shade with a lacquer frame and brass corner fittings."""
    housing = item(parent, "Model", "Arena stair lantern" if standing else "Arena eave lantern")

    def piece(name, offset, dimensions, tint, material):
        dx, dy, dz = offset
        node = part(housing, name, (x + dx * scale, y + dy * scale, z + dz * scale),
                    tuple(axis * scale for axis in dimensions), tint, material=material, collide=False)
        prop(node, "bool", "CastShadow", False)
        return node

    paper = piece("Amber paper core", (0, 0, 0), (1.40, 1.64, 1.40), "FFC970", neon)
    for tier, direction in enumerate((-1, 1)):
        piece("Recessed cedar lantern plate", (0, direction * .886, 0), (1.74, .19, 1.74),
              ("754B37", "814930")[tier], wood)
        piece("Bronze lantern collar", (0, direction * .755, 0), (1.55, .080, 1.55), "C69351", metal)
        piece("Cedar lantern mounting block", (0, direction * 1.025, 0), (1.14, .115, 1.14),
              ("62382D", "985C3A")[tier], wood)
        piece("Thin horizontal paper seam", (0, direction * .30, 0), (1.42, .052, 1.42),
              "BD8150", wood)
        for side in (-1, 1):
            piece("Lacquer frame post", (side * .706, 0, direction * .706), (.147, 1.63, .147),
                  "663B2D", wood)
    if standing:
        piece("Cedar lantern socket", (0, -1.13, 0), (1.88, .13, 1.88), "967A6B", wood)
    else:
        piece("Brass suspension button", (0, 1.11, 0), (.37, .19, .37), "C69453", metal)
    if light_profile is not None:
        lantern_light(paper, scale, warm_pool=True, light_profile=light_profile)


def build_ring_stair_lantern_plinth(parent, x, z, *, item, part, prop, slate, limestone, stone_variant,
                                    variant_field, floor_lift):
    """Dress the lantern pedestal with broad stone courses and a recessed face."""
    footing = item(parent, "Model", "Split slate stair lantern base")
    for name, y, size, tint, material in (
        ("Broad slate footing", .43, (2.40, .23, 2.29), "73606D", slate),
        ("Canted stair lantern lower course", .63, (2.17, .21, 2.10), "9B8281", slate),
        ("Rose slate lantern upright", 1.18, (1.87, .90, 1.88), "9D8584", slate),
        ("Shadow below lantern ledge", 1.64, (1.94, .09, 1.96), "716169", slate),
        ("Sandstone lantern ledge", 1.78, (2.11, .18, 2.12), "BE9B83", limestone),
        ("Honed square lantern cap", 1.94, (2.22, .14, 2.18), "D5B495", limestone),
    ):
        piece = part(footing, name, (x, y + floor_lift, z), size, tint, material=material, collide=False)
        prop(piece, "bool", "CastShadow", False)
        prop(piece, "string", variant_field, stone_variant)
    face = part(footing, "Recessed lantern stone face", (x, 1.18 + floor_lift, z + .948),
                (1.06, .64, .047), "836D72", material=slate, collide=False)
    prop(face, "bool", "CastShadow", False)
    prop(face, "string", variant_field, stone_variant)


def build_ring_stone_cheeks(parent, *, center, front, back, widths, start_y, end_y, steps, item,
                           part, prop, triangle, slate, limestone, stone_variant, cap_variant, variant_field):
    """Bind the stair flight between sloping, beveled sandstone coping courses."""
    cheeks = item(parent, "Model", "Swept sandstone stair shoulders")
    for side in (-1, 1):
        shoulder = item(cheeks, "Model", "Stone stair cheek")

        def face(corners, tint, name, material):
            mark = len(shoulder)
            a, b, c, d = corners
            triangle(shoulder, a, b, c, tint, name=name, material=material,
                     thickness=.052, shadow=False)
            triangle(shoulder, a, c, d, tint, name=name, material=material,
                     thickness=.052, shadow=False)
            for stone in list(shoulder)[mark:]:
                prop(stone, "string", variant_field, cap_variant if material == limestone else stone_variant)

        def position(along, width, height):
            half_stair = (widths[0] + (widths[1]-widths[0]) * along) / 2
            return center + side * (half_stair + .085 + width), height, front + (back-front)*along

        def coping_y(along):
            return start_y + (end_y-start_y) * along

        foot, inside, outside, rim = .18, .23, 1.66, 1.92
        # Fit solid masonry below the bevels while keeping the treads clear.
        for step in range(steps):
            a, b = step / steps, (step + 1) / steps
            cap = coping_y(a) - .15
            low = position(a, rim / 2, 0)
            high = position(b, rim / 2, 0)
            dx, dz = high[0] - low[0], high[2] - low[2]
            base = part(shoulder, "Stair shoulder collision",
                        ((low[0] + high[0]) / 2, (foot + cap) / 2, (low[2] + high[2]) / 2),
                        (rim - .05, cap - foot, hypot(dx, dz) + .025), "937B7E",
                        yaw=degrees(atan2(dx, dz)), material=slate, transparency=1)
            prop(base, "bool", "CastShadow", False)
        # The slate below the coping follows the original tapered stair edges.
        colors = ("8B777B", "A38B84", "937B7E", "9D8482", "8D757A")
        for band, (low, high) in enumerate(((0, .34), (.34, .66), (.66, 1))):
            cuts = (0, .22, .47, .74, 1) if band % 2 else (0, .35, .62, 1)
            for column, (start, end) in enumerate(zip(cuts, cuts[1:])):
                a, b = start + .003, end - .003
                for edge, shift in ((0, 2), (rim, 0)):
                    ha, hb = coping_y(a)-foot-.13, coping_y(b)-foot-.13
                    face((position(a, edge, foot+ha*low), position(b, edge, foot+hb*low),
                          position(b, edge, foot+hb*high), position(a, edge, foot+ha*high)),
                         colors[(band+column+shift) % len(colors)], "Fitted slate cheek course", slate)

        # Top courses align across the bevels and visibly run the full rise.
        profile = ((0, -.13), (inside, .11), (outside, .11), (rim, -.13))
        for course, (a, b) in enumerate(zip((0, .29, .56, .79), (.29, .56, .79, 1))):
            for (left, yl), (right, yr), tint in zip(profile, profile[1:],
                    ("BC9A84", ("D4B193", "DABA9F")[course % 2], "9F806F")):
                face((position(a, left, coping_y(a)+yl), position(b, left, coping_y(b)+yl),
                      position(b, right, coping_y(b)+yr), position(a, right, coping_y(a)+yr)),
                     tint, "Continuous sandstone coping", limestone)
        face((position(0, 0, foot), position(0, rim, foot),
              position(0, rim, start_y-.14), position(0, 0, start_y-.14)),
             "A08A83", "Stair cheek plinth face", slate)
        face((position(0, 0, start_y-.13), position(0, rim, start_y-.13),
              position(0, outside, start_y+.11), position(0, inside, start_y+.11)),
             "C5A48D", "Beveled cheek plinth cap", limestone)


def build_ring_ceiling_panels(parent, *, purlins, cross_ties, height, item, part, prop, wood,
                              variant_field, cedar_variant):
    """Fit recessed cedar panels between the ring's existing main roof timbers."""
    ceiling = item(parent, "Model", "Recessed cedar ceiling panels")
    prop(ceiling, "token", "LevelOfDetail", 4)

    def panel(name, center, dimensions, tint):
        board = part(ceiling, name, center, dimensions, tint, material=wood, collide=False)
        prop(board, "string", variant_field, cedar_variant)
        prop(board, "bool", "CastShadow", False)

    grain = ("87503A", "794835", "84513D")
    for row, (far, near) in enumerate(zip(cross_ties, cross_ties[1:])):
        for column, (left, right) in enumerate(zip(purlins, purlins[1:])):
            x, z = (left + right) / 2, (far + near) / 2
            width, depth = right - left - .52, near - far - .76
            panel("Cedar ceiling shadow bed", (x, height + .33, z), (width, .225, depth), "513934")
            for wide in (-1, 0, 1):
                center_x = x + wide * width / 3
                tone = grain[(row + 2 * column + wide) % len(grain)]
                panel("Fitted cedar ceiling plank", (center_x, height + .18, z),
                      (width / 3 - .078, .095, depth - .155), tone)
            for lip in (far + .36, near - .36):
                panel("Honed cedar ceiling rim", (x, height + .12, lip), (width+.08, .17, .20), "9E6549")


def build_ring_arrival_details(parent, *, center, deck_lift, item, part, prop,
                               slate, limestone, wood, metal, stone_variant, variant_field):
    """Give the existing stair threshold and covered bay more visual depth."""
    details = item(parent, "Model", "Ring threshold dressings")

    def trim(group, name, location, size, tint, material):
        piece = part(group, name, location, size, tint, material=material, collide=False)
        prop(piece, "bool", "CastShadow", False)
        if material == slate:
            prop(piece, "string", variant_field, stone_variant)

    stone_colors = ("9F898A", "947F88", "A88E8C", "91818A", "99888D")
    foundation_top = 2.4 + deck_lift
    base_top = .55
    apron_top = foundation_top - .28
    course_count = 4
    course_rise = (apron_top - base_top) / course_count

    def bounds(row):
        bottom = base_top + course_rise * row
        return bottom + .029, bottom + course_rise - .029

    # The front courses wrap onto the side walls at the same heights.
    for side in (-1, 1):
        x = center + side * 18.54
        trim(details, "Basalt sidewall base", (x, .34, 5), (.25, .42, 30.86), "71616D", slate)
        for row in range(course_count):
            bottom, top = bounds(row)
            edges = (-10.35, -6.75, -2.72, 1.90, 7.42, 12.63, 16.16, 20.36) if row % 2 else (
                -10.35, -4.94, -.82, 4.42, 9.69, 14.66, 20.36,
            )
            for index, (start, finish) in enumerate(zip(edges, edges[1:])):
                trim(details, "Hewn basalt side course", (x, (bottom+top)/2, (start+finish)/2),
                     (.13, top-bottom, finish-start-.055),
                     stone_colors[(row*2+index) % len(stone_colors)], slate)
        trim(details, "Slate sidewall coping", (x, foundation_top-.11, 5),
             (.29, .19, 30.86), "A38B8A", slate)

    # The apron behind the pennants is recessed between broad stone supports.
    for side in (-1, 1):
        x = center + side * 13.02
        for name, y, z, width, height, depth, tint, material in (
            ("Basalt apron footing", .34, 20.57, 9.88, .42, .32, "71616D", slate),
            ("Rose slate apron backing", (base_top+apron_top)/2, 20.48, 9.76, apron_top-base_top,
             .20, "725F6A", slate),
            ("Shadow under apron coping", foundation_top-.21, 20.54, 9.82, .14, .29, "675763", slate),
            ("Honed sandstone apron coping", foundation_top+.035, 20.59, 9.96, .29, .34, "C6A993", limestone),
            ("Beveled sandstone coping crown", foundation_top+.20, 20.55, 9.86, .055, .26,
             "D9B99C", limestone),
            ("Cedar sill above coping", 2.64+deck_lift, 20.52, 9.76, .06, .23, "754C3C", wood),
            ("Cedar apron fascia", 3.005+deck_lift, 20.48, 9.74, .67, .22, "965C46", wood),
            ("Apron fascia bronze fillet", 3.25+deck_lift, 20.61, 9.74, .085, .07, "C99A64", metal),
        ):
            trim(details, name, (x, y, z), (width, height, depth), tint, material)
        for row in range(course_count):
            bottom, top = bounds(row)
            edges = (-4.86, -3.54, -1.34, .96, 3.43, 4.86) if row % 2 else (
                -4.86, -2.63, -.41, 1.82, 4.86,
            )
            for column, (left, right) in enumerate(zip(edges, edges[1:])):
                stone_x = x + side * (left + right) / 2
                tint = stone_colors[(column + row * 2) % len(stone_colors)]
                trim(details, "Hewn rose slate apron stone", (stone_x, (bottom+top)/2, 20.56),
                     (right-left-.055, top-bottom, .27), tint, slate)
        for edge in (-1, 1):
            end_x = x + edge * 4.62
            trim(details, "Cedar apron end join", (end_x, 2.96+deck_lift, 20.606),
                 (.27, .56, .083), "754C3C", wood)
            trim(details, "Cedar fascia fastener", (end_x, 2.97+deck_lift, 20.666),
                 (.13, .13, .037), "D49D5E", metal)
        for offset in (9.00, 17.36):
            pier_x = center + side * offset
            trim(details, "Basalt apron pier shoe", (pier_x, .37, 20.70),
                 (1.42, .67, .55), "6E606E", slate)
            for row in range(course_count):
                bottom, top = bounds(row)
                trim(details, "Raised apron pier block", (pier_x, (bottom+top)/2, 20.71),
                     (1.04, top-bottom, .39), ("9B8389", "8C7984")[row % 2], slate)
            trim(details, "Inset apron pier neck", (pier_x, foundation_top-.14, 20.71),
                 (1.12, .21, .46), "7A6772", slate)
            trim(details, "Sandstone pier cap", (pier_x, foundation_top+.045, 20.77),
                 (1.46, .221, .56), "CBAA94", limestone)
