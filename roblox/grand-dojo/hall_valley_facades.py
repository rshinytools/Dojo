"""Timber gallery fronts visible from Reedfall Crown and Crown Crossing."""


def build_hall_valley_facades(hall, *, item, prop, part, wood, metal, neon,
                              wood_variant, brass_variant, variant_field):
    facades = item(hall, "Model", "Trophy Hall valley facades")
    prop(facades, "token", "ModelStreamingMode", 1)
    prop(facades, "token", "LevelOfDetail", 4)

    # From the elevated north approach, the two side ends and the rear need
    # their own window bays. The solid shell and its front entrance stay intact.
    for label, x, z, tangent, outward, yaw, half, bays in (
        ("North gallery", 0, -52.675, (1, 0), (0, -1), 0, 14.80, (-10.71, -5.36, 0, 5.36, 10.71)),
        ("East gallery", 14.80, -44, (0, 1), (1, 0), 90, 8.675, (-5.28, 0, 5.28)),
        ("West gallery", -14.80, -44, (0, 1), (-1, 0), 90, 8.675, (-5.28, 0, 5.28)),
    ):
        wall = item(facades, "Model", label)

        def trim(name, u, y, setback, size, tint, material=wood):
            tx, tz = tangent
            nx, nz = outward
            center = (x + u * tx + setback * nx, y, z + u * tz + setback * nz)
            piece = part(wall, name, center, size, tint, material=material, yaw=yaw, collide=False)
            prop(piece, "bool", "CastShadow", False)
            if material in (wood, metal):
                prop(piece, "string", variant_field, wood_variant if material == wood else brass_variant)

        for y, height, depth, tint in (
            (17.26, .70, .46, "6E403D"),
            (18.01, .29, .52, "A97556"),
            (28.92, .51, .51, "7F463E"),
            (29.40, .21, .59, "BD8A5F"),
            (31.33, .47, .46, "895044"),
            (38.71, .56, .55, "754541"),
            (39.16, .21, .61, "BC8C60"),
        ):
            trim("Projected gallery stringcourse", 0, y, .18, (2 * half + .14, height, depth), tint)

        posts = (-half + .50, *((a + b) / 2 for a, b in zip(bays, bays[1:])), half - .50)
        for u in posts:
            width = .62 if abs(u) < half - 1 else .91
            trim("Cedar gallery upright", u, 28.32, .21, (width, 20.30, .42), "8D463C")
            trim("Beveled gallery upright edge", u - width * .25, 28.24, .43,
                 (.08, 19.82, .09), "BD7553")
            for y in (18.28, 30.17, 38.17):
                trim("Gallery bronze collar", u, y, .43, (width + .17, .27, .25), "C49160", metal)

        for u in bays:
            for y, width, height, paper in ((23.67, 3.10, 5.55, "BF8052"),
                                           (35.11, 3.00, 3.92, "DEA064")):
                trim("Recessed gallery shutter frame", u, y, .18,
                     (width + .48, height + .48, .41), "633C3A")
                trim("Amber gallery paper", u, y, .40, (width, height, .11), paper, neon)
                for cross in (-1 / 3, 0, 1 / 3):
                    trim("Gallery lattice upright", u + width * cross, y, .48,
                         (.095, height - .08, .13), "8A594B")
                for depth in (-.31, 0, .31):
                    trim("Gallery lattice rail", u, y + height * depth, .50,
                         (width, .10, .13), "986346")
                trim("Bronze gallery sill", u, y - height / 2 - .25, .40,
                     (width + .68, .15, .52), "BD8D5F", metal)
