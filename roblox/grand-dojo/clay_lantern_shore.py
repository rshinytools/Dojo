"""The rock shelves and planted banks below Clay Lantern Lookout."""

import json

from south_valley_backdrop import hillside_cedar


# Each station gives z, the point where the beach meets the sea, and the
# landward rise above sea level. The end stations blend into the old coast.
STATIONS = (
    (-160, 245, 1.9), (-148, 242, 2.5), (-134, 241, 4.1),
    (-120, 223, 2.1), (-108, 222, 1.7), (-95, 239, 2.9),
    (-81, 251, 4.2), (-67, 244, 3.3), (-53, 226, 2.0),
    (-40, 236, 2.6), (-24, 245, 1.7),
)


def build_clay_lantern_shore(parent, *, item, prop, part, vector, asset, garden_prop, shoreline_slate,
                             rock, cedar, grass, bank_variant, variant_field):
    shore = item(parent, "Model", "Clay Lantern tide shore")
    prop(shore, "token", "LevelOfDetail", 4)
    profile = item(shore, "StringValue", "Coastline stations")
    prop(profile, "string", "Value", json.dumps(STATIONS, separators=(",", ":")))

    # Broad stone ribs define three points and frame two smaller coves.
    for index, (x, z, base, width, depth, height, yaw) in enumerate((
        (238.4, -137.8, -.8, 9.9, 14.1, 5.25, 19),
        (239.5, -98.1, -.45, 11.6, 10.6, 3.85, -32),
        (250.0, -79.0, -1.4, 13.2, 15.7, 5.82, 22),
        (242.3, -35.5, -1.1, 8.0, 11.8, 3.48, -19),
    )):
        alcove = item(shore, "Model", "Weathered tide shelf")
        prop(alcove, "token", "ModelStreamingMode", 1)
        prop(alcove, "token", "LevelOfDetail", 4)
        crown = shoreline_slate(alcove, x, z, base, width, depth, height, yaw, shadow=False)
        for key, a, b, weight, scale, tint in (
            ("meadowCover", 1, 2, .61, .48, "97A75E"),
            ("meadowGrass", 2, 3, .27, .38, "B4AD6E"),
            ("mossFlowers", 6, 2, .43, .28, "C7909E"),
        ):
            px, py, pz = (u + (v - u) * weight for u, v in zip(crown[a], crown[b]))
            garden_prop(alcove, key, (px, py - .12, pz), scale, yaw + 41 * index, tint)

    banks = item(shore, "Model", "Tidepool reeds and rounded stones")
    prop(banks, "token", "LevelOfDetail", 4)
    for index, (x, y, z) in enumerate((
        (233.1, 2.35, -126.1), (223.1, 1.68, -116.7),
        (221.6, 1.41, -109.9), (222.6, 1.57, -105.0),
        (232.4, 1.88, -99.1), (242.9, 2.75, -87.4),
        (244.3, 2.02, -72.6), (231.9, 1.95, -62.6),
        (225.5, 1.53, -55.4), (224.8, 1.58, -51.0),
        (229.4, 1.77, -45.9), (232.8, 2.2, -39.3),
    )):
        phase = index * 61
        garden_prop(banks, "bankRock", (x + .82, y - .69, z + 1.3),
                    (.23, .31, .19)[index % 3], phase + 29, "948280")
        garden_prop(banks, "reeds" if index % 3 else "cattails",
                    (x, y - .52, z), (.56, .43, .51)[index % 3], phase, "ABAC69")
        garden_prop(banks, "meadowGrass", (x - 1.55, y - .18, z + 1.22),
                    .32, phase + 62, "BBC57B")

    def cedar_piece(group, name, position, size, tint, **pose):
        material = cedar if name.endswith("trunk") else grass
        node = part(group, name, position, size, tint, collide=False, material=material, **pose)
        prop(node, "bool", "CastShadow", False)

    for index, (x, y, z, scale) in enumerate((
        (229.6, 3.60, -132.8, .59), (237.6, 4.33, -85.6, .76), (221.8, 2.70, -65.2, .57),
    )):
        hillside_cedar(cedar_piece, banks, x, y, z, scale, index + 2)
        garden_prop(banks, "meadowCover", (x + .71, y + .57, z + .96), .45, 49 * index, "ADBD66")
        garden_prop(banks, "meadowFlowers", (x + 1.72, y + .54, z - 1.38), .32, 48 * index, "DEAD86")

    # KoBoIce's free Low Poly Rock, Creator Store model 130260542676735.
    for center, size, heading, tint in (
        ((225.6, 1.31, -112.3), (4.38, 1.91, 3.77), -28, "847986"),
        ((247.8, 2.55, -83.2), (5.32, 2.59, 4.23), 63, "9A8382"),
        ((231.6, 1.12, -49.0), (3.82, 1.64, 4.40), 15, "907E81"),
    ):
        outcrop = part(banks, "Rounded tidepool outcrop", center, size, tint, yaw=heading,
                       material=rock, collide=False, class_name="MeshPart")
        vector(outcrop, "Vector3", "InitialSize", ("X", "Y", "Z"), (50, 28.732067, 48.794754))
        asset(outcrop, "MeshContent", "rbxassetid://124320461153364")
        prop(outcrop, "string", variant_field, bank_variant)
        prop(outcrop, "bool", "CastShadow", False)
    for node in shore.iter("Item"):
        flag = node.find("Properties/bool[@name='CastShadow']")
        if flag is not None:
            flag.text = "false"
