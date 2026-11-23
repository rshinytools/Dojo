"""A painted timber and brass entry on Tideharbor's west causeway."""


def build_tideharbor_town_gate(town, x, y, z, *, item, prop, part, beam, gate, sign,
                               swept_roof, curved_plaque, marquee_title, festival_lantern,
                               slate, wood, metal, cedar_variant, variant_field):
    # Retain the gate's original jambs and the causeway's clear opening.
    gate(town, x, z, -90, span=15, trim="326F79", y=y,
         lanterns=False, straight_lintel=False)
    portal = item(town, "Model", "Tideharbor tidal arch")
    prop(portal, "token", "ModelStreamingMode", 1)
    prop(portal, "token", "LevelOfDetail", 4)

    def trim(name, center, dimensions, color, material=wood):
        piece = part(portal, name, center, dimensions, color, material=material, collide=False)
        prop(piece, "bool", "CastShadow", False)
        if material == wood:
            prop(piece, "string", variant_field, cedar_variant)

    for side in (-1, 1):
        column = side * 7.5
        for height, size, color, material in (
            (.39, (2.46, .71, 2.55), "7F777D", slate),
            (.88, (2.39, .13, 2.45), "A7A39C", slate),
            (4.83, (1.43, 7.61, 1.49), "3D7072", wood),
            (2.16, (1.62, .23, 1.64), "AB885B", metal),
            (8.38, (1.67, .21, 1.67), "B48C55", metal),
            (8.84, (2.43, .33, 2.12), "34585A", wood),
            (9.25, (2.98, .42, 2.54), "64898A", wood),
        ):
            trim("Tideharbor layered pier course", (column, height, 0), size, color, material)
        for front in (-1, 1):
            trim("Teal pier raised stile", (column + side * .39, 5.22, front * .78),
                 (.17, 6.12, .13), "6E9690")
            trim("Teal pier brass pinstripe", (column + side * .39, 5.22, front * .861),
                 (.06, 5.70, .047), "C3925D", metal)
        brace = beam(portal, "Harbor crossbeam raked knee", (column - side * .16, 7.79, .19),
                     (column - side * 2.03, 9.43, .19), .49, "517C7B")
        prop(brace, "bool", "CastShadow", False)
        festival_lantern(portal, column - side * 1.93, 7.91, 1.29, 1.02,
                         light=True, tint="FFD28A", warm_pool=True, light_profile=(1.08, 15))

    profile = tuple((offset, 10.45 - .99 * (offset / 9.03) ** 2)
                    for offset in (-9.03, -7.03, -5.17, -3.31, -1.57, 0, 1.57, 3.31, 5.17, 7.03, 9.03))
    trim("Shadowed teal header", (0, 8.96, .20), (16.63, .65, 1.47), "35575A")
    curved_plaque(portal, 0, .90, profile, 2.21, "2C5B61", "D5A363", rim_height=.19)
    marquee_title(portal, "TIDEHARBOR COAST", 0, .90, profile, 1.46)
    for side in (-1, 1):
        points = [(side * (7.28 + x), y, 1.45)
                  for x, y in ((-.42, 9.37), (-.29, 9.59), (-.12, 9.67), (.10, 9.62),
                               (.26, 9.47), (.45, 9.44), (.61, 9.52))]
        for a, b in zip(points, points[1:]):
            line = beam(portal, "Inlaid bronze tide crest", a, b, .072, "DBA762")
            prop(line, "bool", "CastShadow", False)
    trim("Harbor return lintel", (0, 8.89, -.69), (16.7, .74, .48), "355E64")
    sign(portal, "GRAND DOJO CITY", 0, 8.94, -1.12, 11.2, 1.15, 180, "3D6262", face_only=True)
    swept_roof(portal, 0, 11.58, .05, 21.32, 6.46, 2.70, fine_tiles=False,
               signature=True, corner_sweep=1.28, ridge_finial_scale=.89)

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
