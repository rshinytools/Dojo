"""Dress the lower Skywalk ascent between the plaza and the creek bridge."""

from cinder_ravine_terraces import STORE_STONES
from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Cross-sections run from the road edge to the eastern valley floor. The dip
# near z=-105 keeps the existing pavilion visible between the two shoulders.
SECTIONS = (
    ((32.9, -.45, -81.5), (35.0, -.28, -82.9), (37.6, .14, -82.0),
     (39.4, -.15, -82.5), (40.9, -.51, -82.3)),
    ((30.8, -.34, -91.0), (33.4, 2.68, -90.2), (37.4, 5.30, -91.8),
     (40.5, 2.70, -90.0), (42.0, -.51, -91.7)),
    ((30.1, -.36, -98.6), (32.3, 3.13, -98.2), (36.8, 6.65, -99.9),
     (39.4, 3.80, -97.7), (42.2, -.50, -100.0)),
    ((30.7, -.39, -108.6), (33.1, 1.56, -107.2), (37.1, 3.16, -107.7),
     (39.6, 2.33, -108.1), (42.1, -.50, -108.6)),
    ((30.4, -.38, -117.1), (33.0, 3.25, -116.0), (37.5, 6.36, -115.8),
     (41.0, 4.14, -117.0), (43.1, -.50, -116.9)),
    ((29.9, -.39, -125.8), (32.7, 5.08, -124.5), (37.4, 9.85, -124.0),
     (43.0, 6.10, -124.9), (47.8, -.53, -125.5)),
    ((30.9, -.40, -133.6), (34.1, 5.33, -133.0), (39.1, 7.71, -132.6),
     (44.8, 4.90, -133.1), (49.4, -.59, -133.2)),
    ((34.1, -.54, -137.1), (38.0, .34, -137.6), (41.8, 1.15, -137.7),
     (44.9, .02, -136.9), (47.8, -.61, -137.0)),
)

STONE = ("857481", "94808A", "9B8690", "8C7A86")
SHADOW = ("77707C", "817380", "897888")
MOSS = ("677C57", "748660", "809168", "778968")
CEDAR_FOLIAGE = {
    "394D45": "526347", "486550": "65794D", "58745B": "78874F", "6A815D": "839057",
    "735347": "745442", "93674F": "926747", "A77954": "AC7B4D", "BA8860": "BD9257",
}


def build_skywalk_road_bank(parent, *, item, prop, part, vector, asset, triangle,
                           garden_prop, rock, grass, cedar, rock_variant, variant_field):
    model = item(parent, "Model", "Skywalk road cedar banks")
    prop(model, "token", "ModelStreamingMode", 1)
    prop(model, "token", "LevelOfDetail", 4)
    strata = item(model, "Folder", "Contoured slate and cedar soil")
    surfaces = []

    for row, (front, back) in enumerate(zip(SECTIONS, SECTIONS[1:])):
        for band, (a, b, c, d) in enumerate(zip(front, front[1:], back, back[1:])):
            for split, corners in enumerate(((a, b, c), (c, b, d))):
                surfaces.append(corners)
                palette = MOSS if band == 2 else SHADOW if band == 3 else STONE
                cover = band == 2 or (band == 0 and row == 3)
                first = len(strata)
                triangle(strata, *corners, palette[(row + band + split) % len(palette)],
                         name="Moss cap" if cover else "Broken slate terrace",
                         material=grass if cover else rock, thickness=.20,
                         shadow=False, collide=False)
                if not cover:
                    for wedge in strata[first:]:
                        prop(wedge, "string", variant_field, rock_variant)

    def ground(x, z):
        return ridge_surface_height(surfaces, x, z)

    trees = item(model, "Folder", "Cedar silhouettes and low planting")

    def cedar_piece(group, label, position, size, tint, **rotation):
        trunk = label.endswith("trunk")
        if not trunk:
            # Flatten and overlap the foliage pads into broad cedar boughs.
            size = (size[0] * 1.36, size[1] * .86, size[2] * 1.22)
            tint = CEDAR_FOLIAGE[tint]
        piece = part(group, label, position, size, tint, material=cedar if trunk else grass,
                     collide=False, **rotation)
        prop(piece, "bool", "CastShadow", False)

    for index, (x, z, scale) in enumerate((
        (36.4, -90.6, .74), (38.7, -94.8, .80), (36.6, -99.6, 1.03),
        (40.4, -116.8, .60), (38.0, -121.3, .98), (39.6, -125.6, 1.10),
        (43.1, -129.9, .80), (37.2, -133.6, .69),
    )):
        hillside_cedar(cedar_piece, trees, x, ground(x, z) - .15, z, scale, index)

    for index, (x, z, kind, scale, tint) in enumerate((
        (33.9, -88.5, "meadowGrass", .31, "8B9A67"),
        (34.3, -93.8, "mossFlowers", .36, "CAA786"),
        (31.8, -97.1, "meadowCover", .32, "97A974"),
        (38.1, -98.8, "meadowGrass", .51, "8FA36B"),
        (32.1, -104.3, "mossFlowers", .23, "CCAE91"),
        (34.7, -106.2, "rockVine", .40, "8F9B6D"),
        (39.6, -106.2, "meadowCover", .40, "A0A777"),
        (32.9, -114.4, "meadowGrass", .36, "98A875"),
        (36.7, -118.3, "mossFlowers", .34, "C39D8B"),
        (35.2, -123.5, "rockVine", .47, "809767"),
        (32.6, -128.1, "meadowGrass", .27, "94A66F"),
        (42.5, -131.2, "meadowCover", .41, "9EA575"),
        (36.2, -134.4, "mossFlowers", .30, "C7AA8A"),
        (35.1, -97.6, "meadowCover", .49, "9DAB76"),
        (33.8, -103.1, "meadowGrass", .31, "A0A66A"),
        (35.6, -112.8, "meadowFlowers", .45, "C9A385"),
        (34.0, -118.6, "meadowCover", .44, "9DA670"),
        (34.8, -121.6, "meadowGrass", .38, "A3A36C"),
        (38.2, -128.5, "meadowGrass", .45, "98A875"),
        (41.4, -127.7, "rockVine", .49, "8A9D72"),
    )):
        garden_prop(trees, kind, (x, ground(x, z) - .13, z), scale, 23 + index * 39, tint)

    outcrops = item(model, "Folder", "Weathered slate outcrops")
    for key, x, z, size, yaw, tint in (
        ("Cube.005", 35.0, -96.5, (5.75, 2.62, 4.40), 14, "9D8890"),
        ("Cube.010", 34.9, -114.2, (6.52, 3.34, 4.83), -29, "897B8A"),
        ("Cube.008", 39.8, -124.1, (7.30, 5.85, 5.12), 26, "8D7F8D"),
        ("Cube.005", 37.0, -132.0, (6.10, 2.67, 4.32), -44, "8F7E89"),
    ):
        identifier, mesh_size = STORE_STONES[key]
        piece = part(outcrops, "Screened Creator Store slate", (x, ground(x, z) - .48, z),
                     size, tint, yaw=yaw, material=rock, collide=False, class_name="MeshPart")
        prop(piece, "bool", "CastShadow", False)
        prop(piece, "token", "RenderFidelity", 0)
        prop(piece, "string", variant_field, rock_variant)
        vector(piece, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        asset(piece, "MeshContent", f"rbxassetid://{identifier}")
