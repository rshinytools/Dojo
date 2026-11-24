"""The lantern guild's hillside workshop on Lantern Circuit's western skyline."""

from south_valley_backdrop import hillside_cedar, ridge_surface_height


CENTER = (-283.0, 54.0)
APRON = 12.0

_OUTLINE = (
    (-.92, -.48), (-.45, -.90), (.20, -1.0), (.76, -.73),
    (1.0, -.19), (.83, .53), (.36, .95), (-.42, .98), (-.99, .38),
)
# Broad shelves separate the darker lower cliff from the warm, built upper apron.
_BANDS = (
    (15.6, 13.3, -6.1, -.47, .14),
    (14.0, 11.8, -1.05, .14, -.11),
    (11.9, 10.6, -.60, -.18, -.31),
    (10.9, 9.25, 5.10, -.71, -.42),
    (9.2, 7.70, 5.63, -.49, -.79),
    (7.9, 6.8, 11.63, -.23, -.21),
)
_STONE = ("766677", "807182", "877889", "8F7C89", "9B8590", "968591")
_GRASS = ("737B54", "7B8058", "84885F", "778258")


def build_lantern_guild_beacon(parent, *, item, prop, part, beam, triangle,
                               swept_roof, festival_lantern, garden_prop, showcase_tree,
                               slate, grass, cedar, metal, neon, stone_variant, variant_field):
    """Add a distant point of reference outside the walking loop's guardrail."""
    landmark = item(parent, "Model", "Lantern Guild Beacon")
    prop(landmark, "token", "ModelStreamingMode", 1)
    prop(landmark, "token", "LevelOfDetail", 4)
    x, z = CENTER
    cliff = item(landmark, "Folder", "Terraced guild bluff")
    rings = []
    for band, (width, depth, grade, dx, dz) in enumerate(_BANDS):
        rings.append(tuple(
            (x + u * width + dx, grade + (.25, -.17, .12, -.09, .30, -.23, .11, -.26, .13)[
                (index + (band // 2) * 2) % len(_OUTLINE)], z + v * depth + dz)
            for index, (u, v) in enumerate(_OUTLINE)
        ))

    surface = []

    def facet(points, color, planted):
        surface.append(points)
        first = len(cliff)
        triangle(cliff, *points, color, name="Planted terrace" if planted else "Split slate bluff",
                 thickness=.20, material=grass if planted else slate, shadow=False)
        if not planted:
            for piece in list(cliff)[first:]:
                prop(piece, "string", variant_field, stone_variant)

    for band, (lower, upper) in enumerate(zip(rings, rings[1:])):
        planted = band in (1, 3)
        palette = _GRASS if planted else _STONE
        for index in range(len(lower)):
            following = (index + 1) % len(lower)
            facet((lower[index], lower[following], upper[index]),
                  palette[(index + band) % len(palette)], planted)
            facet((upper[index], lower[following], upper[following]),
                  palette[(index + band + 1) % len(palette)], planted)
    crown = rings[-1]
    for index, first in enumerate(crown):
        facet(((x, 11.75, z), first, crown[(index + 1) % len(crown)]),
              _GRASS[index % len(_GRASS)], True)

    planting = item(landmark, "Folder", "Guild gardens")
    for index, (dx, dz) in enumerate((
        (12.2, -1.4), (10.4, 3.1), (9.5, -4.8), (7.7, 5.3), (7.3, -1.5),
        (4.5, 5.6), (-2.0, 6.2), (-6.4, 3.0), (-4.5, -4.0), (4.7, -6.3),
    )):
        bx, bz = x + dx, z + dz
        grade = ridge_surface_height(surface, bx, bz)
        garden_prop(planting, "bankRock", (bx, grade - .13, bz), .21 + index % 3 * .035,
                    21 + index * 33, "A497A7")
        gx, gz = bx - .37, bz + .44
        kind, scale, tint = (
            ("meadowCover", .24, "9AA66C"), ("mossFlowers", .23, "D8ACC4"),
            ("grassBlade", .48, "E3BC77"), ("meadowFlowers", .34, "D39E9F"),
        )[index % 4]
        garden_prop(planting, kind, (gx, ridge_surface_height(surface, gx, gz) - .05, gz),
                    scale, 14 + index * 27, tint)
    def cedar_piece(group, name, position, size, tint, **rotation):
        part(group, name, position, size, tint,
             material=cedar if name.endswith("trunk") else grass, collide=False, **rotation)

    for dx, dz, scale, shade in ((8.45, 4.21, .66, 2), (-4.58, 5.20, .57, 3)):
        bx, bz = x + dx, z + dz
        hillside_cedar(cedar_piece, planting, bx, ridge_surface_height(surface, bx, bz) - .15,
                       bz, scale, shade)
    bx, bz = x + 5.35, z - 4.95
    showcase_tree(planting, bx, bz, True, .59, 36,
                  ridge_surface_height(surface, bx, bz) - .15, compact=True)

    house = item(landmark, "Model", "Lantern guild workshop")

    def detail(name, dx, y, dz, size, color, material=cedar):
        return part(house, name, (x + dx, y, z + dz), size, color,
                    material=material, collide=False)

    detail("Recessed stone plinth", 0, APRON - .34, 0, (12.82, .82, 10.86), "837383", slate)
    detail("Dressed slate cap", 0, APRON + .15, 0, (12.44, .32, 10.48), "AA919C", slate)
    for width, depth, floor, height, roof_width, roof_depth, rise in (
        (10.50, 8.60, 12.29, 5.87, 13.25, 11.15, 2.26),
        (7.23, 5.65, 19.60, 4.57, 9.62, 7.84, 2.68),
    ):
        u, v = width / 2, depth / 2
        for side in (-1, 1):
            for f in (-1, 1):
                detail("Lacquered cedar corner post", side * u, floor + height / 2, f * v,
                       (.63, height, .63), "783A40")
                detail("Gilded column collar", side * u, floor + height - .48, f * v,
                       (.77, .18, .77), "C48B56", metal)
                beam(house, "Rounded stepped corbel", (x + side * (u - .71), floor + height - .90, z + f * v),
                     (x + side * (u + .38), floor + height - .17, z + f * v), .37, "A15149")
            detail("East-west red cedar tie", side * u, floor + height - .24, 0,
                   (.55, .47, depth + .82), "763B42")
            detail("North-south red cedar tie", 0, floor + height - .24, side * v,
                   (width + .82, .47, .55), "763B42")
            detail("Shadowed timber screen", side * (u - .13), floor + height / 2, 0,
                   (.24, height - .70, depth - .46), "58333C")
            detail("Plum plaster panel", 0, floor + height / 2, side * (v - .15),
                   (width - .49, height - .66, .25), "A76857")
            for offset in (-.28, 0, .28):
                window_width = depth * .19
                panel_height = height * .51
                wy = floor + height * .56
                wz = offset * depth
                detail("Amber paper screen", side * u, wy, wz,
                       (.20, panel_height, window_width), "F8B569", neon)
                for mullion in (-.32, .32):
                    detail("Paper screen lattice", side * (u + .14), wy, wz + mullion * window_width,
                           (.12, panel_height, .10), "793F40")
                detail("Lattice crossbar", side * (u + .16), wy, wz,
                       (.13, .10, window_width), "793F40")
        swept_roof(house, x, floor + height, z, roof_width, roof_depth, rise,
                   fine_tiles=False, signature=True, corner_sweep=1.1, ridge_finial_scale=.70)

    for dz in (-3.6, 3.6):
        festival_lantern(house, x + 5.56, 16.67, z + dz, .62,
                         light=False, tint="F9B765", entrance_paper=True)
    for piece in landmark.iter("Item"):
        if piece.find("Properties/bool[@name='Anchored']") is None:
            continue
        for field in ("CanCollide", "CanQuery", "CanTouch", "CastShadow"):
            flag = piece.find(f"Properties/bool[@name='{field}']")
            if flag is None:
                prop(piece, "bool", field, False)
            else:
                flag.text = "false"
