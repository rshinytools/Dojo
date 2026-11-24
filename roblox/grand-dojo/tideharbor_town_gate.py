"""A painted timber and brass entry on Tideharbor's west causeway."""


def build_tideharbor_town_gate(town, x, y, z, *, item, prop, part, beam, gate, sign,
                               swept_roof, curved_plaque, marquee_title, festival_lantern,
                               slate, wood, metal, neon, cedar_variant, variant_field):
    # Retain the gate's original jambs and the causeway's clear opening.
    gate(town, x, z, -90, span=15, trim="326F79", y=y,
         lanterns=False, straight_lintel=False)
    portal = item(town, "Model", "Tideharbor tidal arch")
    prop(portal, "token", "ModelStreamingMode", 1)
    prop(portal, "token", "LevelOfDetail", 4)

    def trim(name, center, dimensions, color, material=wood, **pose):
        piece = part(portal, name, center, dimensions, color, material=material, collide=False, **pose)
        prop(piece, "bool", "CastShadow", False)
        if material == wood:
            prop(piece, "string", variant_field, cedar_variant)

    for side in (-1, 1):
        column = side * 7.5
        for height, size, color, material in (
            (.39, (2.46, .71, 3.17), "7F777D", slate),
            (.88, (2.39, .13, 3.06), "A7A39C", slate),
            (4.83, (1.52, 7.61, 2.65), "396669", wood),
            (2.16, (1.70, .23, 2.74), "AB885B", metal),
            (8.38, (1.75, .21, 2.81), "B48C55", metal),
            (8.84, (2.43, .33, 2.91), "34585A", wood),
            (9.25, (2.98, .42, 3.34), "64898A", wood),
        ):
            trim("Tideharbor layered pier course", (column, height, 0), size, color, material)
        for front in (-1, 1):
            trim("Pier inset tide panel", (column, 5.25, front * 1.36),
                 (1.09, 5.94, .11), "578280")
            trim("Teal pier raised stile", (column + side * .39, 5.22, front * 1.43),
                 (.17, 6.12, .11), "759F95")
            trim("Teal pier brass pinstripe", (column + side * .39, 5.22, front * 1.505),
                 (.06, 5.70, .047), "C3925D", metal)
            trim("Pier recessed end panel", (column - side * .78, 5.6, front * .63),
                 (.12, 4.95, .69), "305557")
        brace = beam(portal, "Harbor crossbeam raked knee", (column - side * .16, 7.79, .19),
                     (column - side * 2.03, 9.43, .19), .49, "517C7B")
        prop(brace, "bool", "CastShadow", False)
        festival_lantern(portal, column - side * 1.93, 7.91, 1.29, 1.02,
                         light=True, tint="FFD28A", warm_pool=True, light_profile=(1.08, 15))
        for fore in (-1, 1):
            bracket = beam(portal, "Harbor eave support knee", (column, 8.18, fore * 1.20),
                           (column + side * 1.46, 10.48, fore * 3.13), .49, "3A6263")
            prop(bracket, "bool", "CastShadow", False)
            trim("Stepped eave corbel", (column + side * 1.36, 10.21, fore * 1.96),
                 (1.66, .32, 1.80), "4A7374")
            trim("Stepped eave cap", (column + side * 1.36, 10.53, fore * 2.43),
                 (1.92, .29, 2.27), "71928A")

    # Wide ribs are visible when the player steps through the opening. Keep
    # the lowest timber above the original lintel and the road below it clear.
    trim("Recessed harbor soffit", (0, 10.77, 0), (16.63, .30, 6.56), "2E4E53")
    for depth in (-2.82, -.98, 1.02, 2.81):
        trim("Harbor soffit timber", (0, 10.52, depth), (15.49, .31, .33), "487171")
        trim("Copper soffit binding", (0, 10.34, depth), (15.25, .06, .18), "A48157", metal)

    profile = tuple((offset, 10.45 - .99 * (offset / 9.03) ** 2)
                    for offset in (-9.03, -7.03, -5.17, -3.31, -1.57, 0, 1.57, 3.31, 5.17, 7.03, 9.03))
    trim("Shadowed teal header", (0, 8.96, .20), (16.63, .65, 1.47), "35575A")
    trim("Tideharbor sign mounting timber", (0, 10.09, .94), (15.42, .41, 1.34), "375C60")
    curved_plaque(portal, 0, 1.61, profile, 2.21, "2C5B61", "D5A363", rim_height=.19)
    marquee_title(portal, "TIDEHARBOR COAST", 0, 1.61, profile, 1.46)
    for side in (-1, 1):
        points = [(side * (7.28 + x), y, 2.16)
                  for x, y in ((-.42, 9.37), (-.29, 9.59), (-.12, 9.67), (.10, 9.62),
                               (.26, 9.47), (.45, 9.44), (.61, 9.52))]
        for a, b in zip(points, points[1:]):
            line = beam(portal, "Inlaid bronze tide crest", a, b, .072, "DBA762")
            prop(line, "bool", "CastShadow", False)
    trim("Harbor return lintel", (0, 8.89, -.69), (16.7, .74, .48), "355E64")
    sign(portal, "GRAND DOJO CITY", 0, 8.94, -1.12, 11.2, 1.15, 180, "3D6262", face_only=True)
    swept_roof(portal, 0, 11.58, .05, 21.32, 8.02, 2.70, fine_tiles=False,
               signature=True, corner_sweep=1.28, ridge_finial_scale=.89)

    # Dress the actual west storehouse walls visible through and next to the
    # gate. Local depth is the negative world-X distance behind the entrance.
    for across, depth, width, height, inset in (
        (-10.0, -2.50, 12.03, 9.0, 2.70),
        (12.0, -6.50, 10.12, 8.0, 2.32),
    ):
        trim("Harbor storehouse muted plaster", (across, .42 + height * .5, depth + .08),
             (width, height, .15), "A78A6C", slate)
        for level, depth_offset, section, tint in (
            (.66, .25, .28, "7C7E78"), (2.38, .21, .19, "60766D"),
            (height - .79, .24, .30, "668883"), (height + .14, .29, .35, "42676C"),
        ):
            trim("Harbor storehouse belt course", (across, level, depth + depth_offset),
                 (width + .11, section, .22), tint)
        for offset in (-width * .49, 0, width * .49):
            trim("Harbor storehouse raised upright", (across + offset, .43 + height * .49, depth + .29),
                 (.30, height - .12, .31), "3A686C")
        for side in (-1, 1):
            bay = across + side * inset
            sill = height - 4.03
            trim("Harbor paper window deep reveal", (bay, sill + 1.51, depth + .22),
                 (3.09, 3.17, .19), "284B51")
            trim("Harbor amber paper inset", (bay, sill + 1.50, depth + .34),
                 (2.38, 2.69, .045), "D39B69", neon)
            for offset in (-.81, 0, .81):
                trim("Harbor window lattice stile", (bay + offset, sill + 1.50, depth + .40),
                     (.095, 2.77, .095), "4B6864")
            for level in (.49, 1.49, 2.49):
                trim("Harbor window lattice tie", (bay, sill + level, depth + .42),
                     (2.44, .087, .077), "33585A")
            trim("Harbor slate window sill", (bay, sill - .059, depth + .28),
                 (3.27, .19, .40), "B59C82", slate)
            trim("Harbor window awning", (bay, sill + 3.13, depth + .48),
                 (3.34, .21, .67), "334E62", pitch=9)
            trim("Copper window awning edge", (bay, sill + 3.09, depth + .81),
                 (3.31, .077, .093), "BD9569", metal)

    # World -X faces the causeway. All parts and attached labels share
    # the same quarter turn, leaving the original colliding posts in place.
    for transform in portal.iter("CoordinateFrame"):
        row = {field.tag: float(field.text) for field in transform}
        row.update(X=x - row["Z"], Y=y + row["Y"], Z=z + row["X"])
        for index in range(3):
            first, third = f"R0{index}", f"R2{index}"
            row[first], row[third] = -row[third], row[first]
        for field in transform:
            field.text = f"{row[field.tag]:.9g}"
