"""Visible slate ledges and cliff gardens above Saltwind High Walk."""

from south_valley_backdrop import hillside_cedar, ridge_surface_height


SHELVES = (
    (127.3, 63.9, 5.35, 2.55, .40),
    (131.3, 65.2, 6.65, 3.40, .47),
    (135.4, 67.2, 6.45, 3.08, .44),
    (137.1, 63.0, 6.85, 3.28, .39),
    (142.0, 66.0, 7.20, 3.52, .52),
    (148.4, 64.4, 6.78, 3.39, .40),
    (154.8, 63.0, 7.20, 3.50, .47),
)
FACE_TINTS = (
    ("74697C", "796D82", "7D7084"), ("746678", "786B7D", "7A6D81"),
    ("716478", "76697D", "796C7E"), ("6D6174", "716477", "756779"),
    ("6E626E", "726571", "756873"),
)


def build_saltwind_bluff_art(parent, faces, *, item, prop, part, triangle, garden_prop,
                             slate, grass, cedar, slate_variant, variant_field):
    art = item(parent, "Model", "Saltwind slate shelves and cliff gardens")
    prop(art, "token", "ModelStreamingMode", 1)
    prop(art, "token", "LevelOfDetail", 4)
    outline = ((-.52, .26), (-.52, -.07), (-.34, -.49), (.06, -.55),
               (.44, -.40), (.53, -.15), (.45, .28))
    strata = (("6D5F73", "75677A", "7C6C80"),
              ("8E7C8C", "988492", "9E8B98"))

    def rock(a, b, c, tint, name, material=slate):
        start = len(art)
        triangle(art, a, b, c, tint, name=name, thickness=.14, material=material,
                 collide=False, shadow=False)
        if material == slate:
            for facet in list(art)[start:]:
                prop(facet, "string", variant_field, slate_variant)

    def block(group, name, position, size, tint, **orientation):
        material = cedar if name.endswith("trunk") else grass
        piece = part(group, name, position, size, tint, material=material,
                     collide=False, **orientation)
        prop(piece, "bool", "CastShadow", False)

    for index, (x, z, width, depth, tree_scale) in enumerate(SHELVES):
        y = ridge_surface_height(faces, x, z) + .30
        outline_top = [
            (x + dx * width, y + lift, z + dz * depth)
            for (dx, dz), lift in zip(outline, (-.04, .04, -.09, .04, -.07, .13, .03))
        ]
        shoulder, root = [], []
        for edge, (px, py, pz) in enumerate(outline_top):
            # The exposed nose projects a little. Its foot folds back into the hillside.
            sx = x + (px - x) * 1.04
            sz = z + (pz - z) * 1.05
            shoulder.append((sx, py - (.35 if edge % 2 else .48), sz))
            tx = x + (px - x) * .67 + .11
            tz = z + (pz - z) * .86 - .27
            root_floor = ridge_surface_height(faces, tx, tz)
            cut = .58 if edge in (2, 3, 4) else .28
            root.append((tx, min(root_floor - cut, py - 1.04), tz))
        for layer, (lower, upper) in enumerate(((root, shoulder), (shoulder, outline_top))):
            for edge in range(len(outline) - 1):
                a, b = lower[edge:edge + 2]
                c, d = upper[edge:edge + 2]
                tint = strata[layer][(edge + index) % 3]
                rock(a, b, c, tint, "Separated coastal slate strata")
                rock(b, d, c, tint, "Separated coastal slate strata")
        center = (x, y + .11, z - depth * .08)
        for edge, (a, b) in enumerate(zip(outline_top, outline_top[1:] + outline_top[:1])):
            rock(center, a, b, ("74834F", "68764C", "7F8555")[(index + edge) % 3],
                 "Cliff moss cap", grass)
        hillside_cedar(block, art, x - width * .13, y - .09, z - depth * .16,
                       tree_scale, index)
        if index in (1, 4):
            hillside_cedar(block, art, x + width * .19, y - .12, z - depth * .04,
                           tree_scale * .76, index + 1)
        for key, dx, dz, scale, tint in (
            ("bankRock", .26, -.20, .19, "A0899B"),
            ("meadowGrass", .11, -.31, .20, "A5AD70"),
            ("meadowCover", -.29, -.17, .20, "A2AF74"),
            ("mossFlowers", .19, -.29, .125, "DAA1B2"),
        ):
            garden_prop(art, key, (x + width * dx, y + .015, z + depth * dz),
                        scale, 27 + 39 * index, tint)
