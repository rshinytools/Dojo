"""A planted marker at the plaza junction below Reedfall Gallery."""

from math import cos, radians, sin


def build_reedfall_crown_wayfinding(parent, *, item, prop, part, sign, garden_shelf,
                                    garden_prop, slate, limestone, cedar, brass, grass):
    junction = item(parent, "Model", "Reedfall Crown trailhead")
    prop(junction, "token", "ModelStreamingMode", 1)
    prop(junction, "token", "LevelOfDetail", 4)

    # Face the plaza and the eastbound turn from the west side of the lower stair.
    x, z, yaw = 36.10, -19.00, 52
    angle = radians(yaw)
    c, s = cos(angle), sin(angle)

    def marker_point(across, height, depth):
        return x + across * c + depth * s, height, z - across * s + depth * c

    def piece(name, across, height, depth, size, tint, material):
        return part(junction, name, marker_point(across, height, depth), size,
                    tint, material=material, yaw=yaw, collide=False)

    piece("Dressed slate trailhead base", 0, .34, 0, (4.85, .40, 1.82), "817382", slate)
    piece("Honed sandstone trailhead cap", 0, .59, 0, (4.62, .17, 1.62), "B49A92", limestone)
    for side in (-1, 1):
        offset = side * 2.01
        piece("Slate post shoe", offset, .81, 0, (.57, .32, .57), "9A8283", slate)
        piece("Cedar trailhead post", offset, 2.13, 0, (.34, 2.45, .37), "88503D", cedar)
        piece("Brass post collar", offset, 3.24, 0, (.48, .15, .51), "C8985E", brass)

    piece("Cedar sign back", 0, 2.41, .05, (4.42, 1.82, .31), "694739", cedar)
    piece("Copper trailhead header", 0, 3.405, .15, (4.74, .16, .57), "B47A4C", brass)
    piece("Sandstone sign sill", 0, 1.47, .15, (4.70, .13, .52), "AD9387", limestone)
    for label, height, width, line_height, tint in (
        ("REEDFALL CROWN", 2.99, 4.25, .61, "884C3C"),
        ("CINDER TERRACES  →", 2.36, 4.25, .56, "435A4E"),
        ("GALLERY +9  |  CROWN +34", 1.82, 4.25, .45, "504E60"),
    ):
        sign(junction, label, *marker_point(0, height, .21), width, line_height, yaw, tint)

    for bed_x, bed_z, top, width, depth in (
        (49.75, -11.70, .62, 1.72, 2.24),
        (46.93, -20.60, 1.24, 2.02, 1.98),
    ):
        garden_shelf(junction, bed_x, top, bed_z, width, depth, top-.13,
                     "918089", slate, collide=False)
        garden_shelf(junction, bed_x, top+.13, bed_z-.03, width*.78, depth*.78, .23,
                     "71854F", grass, collide=False)
        garden_prop(junction, "bankRock", (bed_x-.21, top-.09, bed_z-.23), .066, 37, "9B8589")
        garden_prop(junction, "meadowGrass", (bed_x+.38, top+.10, bed_z+.17), .083, 57, "A9B461")
        garden_prop(junction, "meadowCover", (bed_x+.23, top+.06, bed_z-.25), .078, 29, "8EA360")
        garden_prop(junction, "mossFlowers", (bed_x-.43, top+.13, bed_z+.37), .074, 108, "EAAE97")

    for detail in junction.findall("Item"):
        shadow = detail.find("Properties/bool[@name='CastShadow']")
        if shadow is None:
            prop(detail, "bool", "CastShadow", False)
        else:
            shadow.text = "false"
