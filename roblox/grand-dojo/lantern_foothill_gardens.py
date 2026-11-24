"""Layer a planted valley between the lantern guild and the old western range."""

from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Each cross-section joins the western slope to the low ground behind the guild.
# Two broad benches and a recessed irrigation channel step toward Skyline Walk.
SECTIONS = (
    ((-325, 2.10, 40), (-317, -.74, 40), (-308, -2.28, 41), (-303, -3.45, 41),
     (-296, -4.41, 43), (-290, -4.88, 43), (-286, -5.14, 43), (-280, -5.33, 44), (-275, -5.65, 44)),
    ((-325, 7.10, 49), (-317, 5.13, 49), (-308, 4.17, 51), (-303, 2.00, 51),
     (-296, 1.20, 52), (-290, -.65, 52), (-286, -1.23, 53), (-280, -2.95, 53), (-275, -5.50, 55)),
    ((-325, 11.30, 59), (-316, 10.42, 59), (-308, 9.80, 60), (-303, 5.03, 61),
     (-295, 4.84, 61), (-289, .70, 61), (-285, .52, 62), (-280, 1.31, 64), (-273.70, -5.35, 63)),
    ((-325, 12.05, 69), (-316, 11.74, 69), (-308, 10.82, 70), (-303, 5.66, 70),
     (-296, 5.30, 71), (-290, .44, 72), (-284, .10, 73), (-279, 1.11, 73), (-271.35, -5.42, 74)),
    ((-325, 10.15, 80), (-314, 9.92, 80), (-306, 8.79, 82), (-301, 5.40, 83),
     (-294, 5.66, 82), (-289, .42, 83), (-283, .12, 84), (-277, 1.65, 84), (-269.80, -5.36, 85)),
    ((-325, 11.80, 91), (-315, 11.35, 92), (-307, 10.43, 93), (-302, 6.40, 93),
     (-295, 5.85, 94), (-291, .52, 94), (-285, .20, 95), (-277, 1.35, 95), (-269.80, -5.45, 97)),
    ((-325, 8.25, 103), (-315, 7.32, 104), (-306, 6.51, 106), (-301, 3.14, 105),
     (-296, 2.99, 105), (-292, .26, 106), (-286, .05, 107), (-279, -.21, 107), (-273.05, -5.53, 108)),
    ((-324, -1.13, 113), (-317, -2.04, 116), (-308, -2.45, 118), (-301, -3.06, 117),
     (-296, -3.61, 117), (-293, -3.73, 116), (-288, -4.04, 116), (-282, -4.76, 114), (-275, -5.57, 113)),
    ((-323, -5.33, 123), (-317, -5.40, 124), (-308, -5.49, 125), (-301, -5.53, 123),
     (-296, -5.53, 123), (-293, -5.64, 123), (-288, -5.59, 122), (-282, -5.55, 120), (-275, -5.62, 119)),
)

_SLATE = ("746C7C", "877883", "96848C", "81717B", "918086")
_SAGE = ("829957", "869B58", "94A361", "8E9C5C", "8B9F62")
_HERBS = ("95A45F", "A2A267", "A7AA68", "99A65E", "9AA762")
_DAMP = ("627C57", "657D58", "708660", "718960", "687F53")
_CEDAR = {
    "394D45": "55704C", "486550": "69834B", "58745B": "778951", "6A815D": "889D57",
    "735347": "826045", "93674F": "A57B4D", "A77954": "B38B56", "BA8860": "C29B61",
}

TREES = (
    (-311.4, 61.4, .79, 0), (-312.7, 70.8, .84, 1), (-308.8, 75.4, .78, 3),
    (-310.2, 86.7, .93, 2), (-308.3, 96.2, .78, 4), (-314.1, 103.2, .71, 5),
    (-299.0, 64.4, .61, 5), (-298.8, 87.7, .73, 1), (-298.7, 100.5, .69, 6),
    (-278.4, 87.5, .68, 2), (-280.6, 101.3, .63, 0),
    (-297.8, 69.7, .61, 1), (-296.0, 83.7, .69, 0), (-299.6, 95.2, .73, 2),
)

# Measured in Studio from KoBoIce's free Low Poly Rock model (130260542676735).
_ROCK_MESH = "124320461153364"
_ROCK_SIZE = (8.235, 4.732, 8.036)


def build_lantern_foothill_gardens(parent, *, item, prop, part, triangle, vector, asset, garden_prop,
                                  showcase_tree, stone, cedar, grass, smooth, stone_variant, variant_field):
    valley = item(parent, "Model", "Lantern foothill gardens")
    prop(valley, "token", "ModelStreamingMode", 1)
    prop(valley, "token", "LevelOfDetail", 4)
    soil = item(valley, "Folder", "Slate and herb terraces")
    channel = item(valley, "Folder", "Foothill irrigation pools")
    faces = []
    water_colors = ("477F82", "518989", "578B89", "4F888B", "5F9191")
    for row, (near, far) in enumerate(zip(SECTIONS, SECTIONS[1:])):
        for band, (a, b, c, d) in enumerate(zip(near, near[1:], far, far[1:])):
            planted = band in (0, 1, 3, 5, 6, 7)
            tone = _HERBS if band == 3 else _DAMP if band in (5, 6) else _SAGE if planted else _SLATE
            for half, face in enumerate(((a, b, c), (c, b, d))):
                faces.append(face)
                first = len(soil)
                triangle(soil, *face, tone[(row + band + half) % len(tone)], thickness=.17,
                         name="Planted shelf" if planted else "Weathered slate face",
                         material=grass if planted else stone, shadow=False)
                if not planted:
                    for piece in list(soil)[first:]:
                        prop(piece, "string", variant_field, stone_variant)
            if band == 5 and 2 <= row <= 5:
                # The planted edges narrow the water without raising its center out of the cut.
                p, q, r, s = (
                    (left[0] + (right[0] - left[0]) * t, .78, left[2] + (right[2] - left[2]) * t)
                    for left, right in ((a, b), (c, d)) for t in (.20, .78)
                )
                for half, face in enumerate(((p, q, r), (r, q, s))):
                    triangle(channel, *face, water_colors[(row + half) % len(water_colors)],
                             name="Irrigation pool", thickness=.065, material=smooth, shadow=False)

    def floor(x, z):
        return ridge_surface_height(faces, x, z)

    planting = item(valley, "Folder", "Foothill cedar groves and orchard beds")

    def cedar_piece(group, name, position, size, tint, **rotation):
        is_trunk = name.endswith("trunk")
        if not is_trunk:
            size = (size[0] * 1.85, size[1] * .93, size[2] * 1.79)
            tint = _CEDAR[tint]
        piece = part(group, name, position, size, tint, material=cedar if is_trunk else grass,
                     collide=False, **rotation)
        prop(piece, "bool", "CastShadow", False)

    for x, z, scale, shade in TREES:
        hillside_cedar(cedar_piece, planting, x, floor(x, z) - .24, z, scale, shade)
    for x, z, scale, turn in ((-299.25, 75.40, .76, 119), (-311.15, 95.05, .64, 216),
                              (-279.80, 77.20, .58, 85)):
        showcase_tree(planting, x, z, True, scale, turn, floor(x, z) - .15, compact=True)

    for x, z, scale, yaw in ((-305.0, 72.5, .24, 21), (-296.7, 79.8, .21, 68),
                            (-305.4, 94.6, .25, 115), (-278.6, 91.2, .19, 182)):
        rock = part(planting, "Exposed foothill boulder", (x, floor(x, z) + .44 * scale, z),
                    tuple(dimension * scale for dimension in _ROCK_SIZE), "92858F",
                    material=stone, yaw=yaw, collide=False, class_name="MeshPart")
        vector(rock, "Vector3", "InitialSize", ("X", "Y", "Z"), _ROCK_SIZE)
        asset(rock, "MeshContent", f"rbxassetid://{_ROCK_MESH}")
        prop(rock, "token", "RenderFidelity", 0)
        prop(rock, "bool", "CastShadow", False)
        prop(rock, "string", variant_field, stone_variant)

    for row, (x, z) in enumerate(((-302.6, 65.0), (-301.0, 75.2), (-299.0, 83.2),
                                   (-299.4, 91.3), (-300.8, 99.6))):
        for column, dx in enumerate((0, 1.65, 3.35)):
            px, pz = x + dx, z + .42 * column
            key = ("meadowGrass", "meadowFlowers", "meadowCover")[(row + column) % 3]
            garden_prop(planting, key, (px, floor(px, pz) - .045, pz), .33 + .06 * column,
                        20 + row * 47 + column * 32, ("C7A66D", "D5AB88", "A5AA69")[column])
    for index, (x, z) in enumerate(((-291.8, 66.9), (-284.3, 70.2), (-289.4, 78.5),
                                   (-282.1, 85.0), (-289.7, 92.7), (-283.3, 97.8), (-292.5, 103.0))):
        garden_prop(planting, "bankRock", (x, floor(x, z) - .15, z), .22 + index % 3 * .045,
                    index * 41, "90828E")
        px, pz = x + .73, z + .45
        garden_prop(planting, "grassBlade", (px, floor(px, pz) - .04, pz), .51,
                    12 + index * 39, "D7B574")

    for piece in planting.iter("Item"):
        shadow = piece.find("Properties/bool[@name='CastShadow']")
        if shadow is not None:
            shadow.text = "false"
