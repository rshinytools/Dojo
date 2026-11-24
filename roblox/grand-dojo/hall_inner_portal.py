"""A shallow cedar portal that frames the Trophy Hall's recessed doorway."""

from hall_arrival_mass import hall_portico_box, hall_portico_y


def build_hall_inner_portal(hall, *, item, prop, part, beam, triangle, slate, wood, metal,
                            neon, variant_field, wood_variant, brass_variant):
    portal = item(hall, "Model", "Trophy Hall front amber portal")
    prop(portal, "token", "LevelOfDetail", 4)

    def raised(position):
        x, y, z = position
        return x, hall_portico_y(y), z

    def trim(name, position, size, tint, material=wood):
        position, size = hall_portico_box(position, size)
        piece = part(portal, name, position, size, tint, material=material, collide=False)
        prop(piece, "bool", "CastShadow", False)
        if material in (wood, metal):
            prop(piece, "string", variant_field, wood_variant if material == wood else brass_variant)

    def carving(name, start, end, width, tint):
        piece = beam(portal, name, raised(start), raised(end), width, tint, collide=False)
        prop(piece, "bool", "CastShadow", False)

    for side in (-1, 1):
        x = side * 7.68
        # The shoes sit on the stair shoulders, beyond the active treads.
        for name, y, z, size, tint, material in (
            ("Hewn slate portal shoe", 2.85, -28.19, (1.64, .68, 1.63), "87737D", slate),
            ("Sandstone portal shoe edge", 3.21, -28.17, (1.52, .14, 1.56), "AD8E84", slate),
            ("Lacquered inner portal jamb", 6.72, -28.17, (1.08, 6.92, 1.08), "8E442F", wood),
            ("Raised cedar jamb panel", 6.70, -27.588, (.86, 5.84, .097), "A65B3D", wood),
            ("Honey brass lower jamb collar", 3.52, -28.15, (1.22, .16, 1.16), "BC8955", metal),
            ("Honey brass upper jamb collar", 9.54, -28.15, (1.24, .15, 1.19), "CA9456", metal),
            ("Stacked inner portal capital", 9.82, -28.04, (1.43, .31, 1.29), "9E5439", wood),
            ("Carved end of portal beam", 10.58, -26.93, (.70, .28, .13), "AB6746", wood),
        ):
            trim(name, (x, y, z), size, tint, material)
        for offset, tint in ((-.34, "713B2D"), (.34, "C18960")):
            trim("Beveled border of jamb panel", (x + offset, 6.70, -27.516),
                 (.092, 5.58, .072), tint)

        carving("Portico returning cedar bracket", (x, 9.56, -28.53),
                 (x - side * 1.05, 10.43, -28.57), .26, "794731")
        trim("Raised lintel over lantern bay", (side * 6.86, 10.55, -27.69),
             (2.71, .32, 1.20), "884530")
        trim("Honey cedar lantern bay fascia", (side * 6.86, 10.51, -27.055),
             (2.72, .17, .099), "BA7952")

        u = side * 5.86
        trim("Recessed reed tablet", (u, 10.60, -27.06), (1.26, .59, .15), "704031")
        stem = (u - side * .30, 10.40, -26.946)
        carving("Incised reed stem", stem, (u + side * .22, 10.84, -26.946),
                .055, "D9A566")
        for offset in (.13, .29):
            carving("Incised reed leaf", (stem[0] + side * offset, stem[1] + offset * .84, stem[2]),
                    (stem[0] + side * (offset - .09), stem[1] + .16 + offset * .81, stem[2]),
                    .039, "D9A566")

    # The lintel clears the highest tread it overlaps and the front lanterns.
    for name, y, z, size, tint, material in (
        ("Cedar portal lintel core", 10.18, -27.69, (11.22, .54, 1.25), "884530", wood),
        ("Shadowed inner lintel underside", 9.94, -27.74, (11.10, .12, 1.14), "663D31", wood),
        ("Warm bounce on the lintel edge", 10.02, -27.02, (11.25, .11, .15), "CA8B5A", wood),
        ("Saffron transom sill", 10.18, -26.88, (9.64, .16, .18), "BB8650", metal),
        ("Lacquer transom top rail", 10.92, -27.28, (13.89, .14, .42), "874A36", wood),
    ):
        trim(name, (0, y, z), size, tint, material)

    # Warm paper and inset cedar ribs form the second open threshold. The
    # original rear doorway still reads through the space below this fan.
    face_z = -26.91
    sill = 10.24
    profile = ((-4.62, sill), (-3.68, 10.60), (-2.06, 10.88), (0, 11.00),
               (2.06, 10.88), (3.68, 10.60), (4.62, sill))
    tones = ("F6BC76", "FFD493", "FFE1AC", "FFE4B5", "FFD898", "FAC481")
    for index, ((x0, y0), (x1, y1)) in enumerate(zip(profile, profile[1:])):
        triangle(portal, raised((0, sill - .025, face_z)), raised((x0, y0, face_z)), raised((x1, y1, face_z)),
                 tones[index], name="Cream paper front transom pane", thickness=.086,
                 material=neon, shadow=False, collide=False)
        carving("Curved cedar transom casing", (x0, y0, face_z + .062),
                (x1, y1, face_z + .062), .135, "AD6A40")
    for x, y in profile[1:-1]:
        carving("Radial transom cedar muntin", (x * .58, sill, face_z + .065),
                (x, y, face_z + .065), .072, "A16842")
