"""Coastal shape and offshore framing for the Tideharbor sea."""

from math import cos, radians, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Native water extends the swimmable shallows. Grid-aligned edges overlap
# the adjoining fill by one cell so the shoreline has no dry seams.
WATER_APRONS = (
    (244, 464, -188, -152),
    (268, 464, -220, -184),
    (296, 464, -256, -216),
    (324, 464, -296, -252),
    (244, 464, 96, 172),
    (456, 644, -296, 172),
)
ISLAND_OUTLINE = ((-.52, -.12), (-.37, -.43), (.04, -.52), (.40, -.35),
                  (.53, -.04), (.37, .43), (-.02, .52), (-.46, .38))


def build_offshore_island(parent, x, z, width, depth, crest, yaw, *, triangle, slate,
                          distant=False):
    """Join a broad submerged toe to offset shoulders and an uneven summit."""
    rows = ((1.02, 0, 0), (.73, .43, .07), (.43, .76, .13))
    if distant:
        rows = (rows[0], rows[1])
    turn = radians(yaw)
    rings = []
    for span, lift, offset in rows:
        ring = []
        for index, (u, v) in enumerate(ISLAND_OUTLINE):
            cross = (u * span + offset) * width
            reach = (v * span - offset * .42) * depth
            fold = (1.04, .89, .96, .88, 1.02, .82, .96, .86)[index]
            ring.append((x + cross * cos(turn) + reach * sin(turn),
                         -5.8 + (crest + 5.8) * lift * fold,
                         z + reach * cos(turn) - cross * sin(turn)))
        rings.append(ring)
    surfaces = []
    tones = (("847586", "948697", "7F7287"), ("908098", "A290A1", "8B7990"))
    for layer, (lower, upper) in enumerate(zip(rings, rings[1:])):
        for index, a in enumerate(lower):
            next_index = (index + 1) % len(lower)
            b, c, d = lower[next_index], upper[index], upper[next_index]
            for face in ((a, b, c), (b, d, c)):
                triangle(parent, *face, tones[layer][index % 3], name="Tideharbor slate slope",
                         thickness=.18, material=slate, shadow=False)
                surfaces.append(face)
    summit = (x + width * .11, crest, z - depth * .14)
    cap = rings[-1]
    for index, a in enumerate(cap):
        face = (summit, a, cap[(index + 1) % len(cap)])
        triangle(parent, *face, ("8F8693", "A68FA0", "9F899B")[index % 3],
                 name="Coastal island crown", thickness=.16, material=slate, shadow=False)
        surfaces.append(face)
    return surfaces


def build_tideharbor_offshore(parent, *, item, prop, part, triangle, garden_shelf,
                              garden_prop, sign, beam, slate, grass, wood):
    coast = item(parent, "Model", "Tideharbor offshore coast")
    prop(coast, "token", "ModelStreamingMode", 2)
    prop(coast, "token", "LevelOfDetail", 4)
    fills = item(coast, "Folder", "Native sea aprons")
    for index, (west, east, north, south) in enumerate(WATER_APRONS, 1):
        volume = part(fills, f"Offshore water volume {index}", ((west + east) / 2, -2, (north + south) / 2),
                      (east - west, 4.8, south - north), "28859C", transparency=1, collide=False)
        prop(volume, "bool", "CastShadow", False)
    boundary = part(coast, "Harbor swim boundary", (366.50, 0, -29.50), (243, .25, 317),
                    "44636B", transparency=1, collide=False)
    prop(boundary, "bool", "CastShadow", False)

    def cedar_piece(group, name, position, size, tint, **orientation):
        material = wood if name.endswith("trunk") else grass
        piece = part(group, name, position, size, tint, material=material, collide=False, **orientation)
        prop(piece, "bool", "CastShadow", False)

    cape = item(coast, "Model", "Tideharbor northern cape")
    for index, (x, z, width, depth, crest, yaw) in enumerate((
        (249, -160, 31, 39, 11.4, 31),
        (268, -185, 45, 52, 20.2, 24),
        (290, -210, 55, 52, 24.6, 38),
        (320, -238, 65, 64, 33.2, 56),
        (353, -262, 70, 59, 22.6, 39),
    )):
        faces = build_offshore_island(cape, x, z, width, depth, crest, yaw,
                                      triangle=triangle, slate=slate)
        y = ridge_surface_height(faces, x, z)
        garden_shelf(cape, x, y + .18, z, width * .19, depth * .21, .52,
                     "718760", grass, collide=False)
        for dx, dz, scale in ((-1.5, 1.0, .81), (1.75, -.86, .72)):
            root_y = ridge_surface_height(faces, x + dx, z + dz)
            hillside_cedar(cedar_piece, cape, x + dx, root_y - .15, z + dz, scale, index)
        garden_prop(cape, "meadowCover", (x + 1.78, y + .19, z + 1.37), .43, yaw, "9AAD76")
        garden_prop(cape, "rockVine", (x + .38, y - 2.32, z + depth * .10), .88, yaw - 12)

    islands = item(coast, "Model", "Outer Tideharbor islands")
    for x, z, width, depth, crest, yaw in (
        (420, -232, 72, 48, 20.6, 38),
        (476, -264, 118, 68, 48.5, 57),
        (576, -283, 156, 83, 53.7, 38),
        (700, -324, 195, 96, 41.6, 27),
        (842, -370, 168, 92, 27.3, 47),
    ):
        build_offshore_island(islands, x, z, width, depth, crest, yaw,
                              triangle=triangle, slate=slate, distant=True)

    markers = item(coast, "Folder", "Harbor boundary buoys")
    for index, (x, z, yaw) in enumerate(((480, -119, -90), (480, -35, -90), (480, 50, -90),
                                         (309, -179, 0), (405, -179, 0), (339, 123, 180),
                                         (421, 123, 180))):
        part(markers, "Harbor mooring buoy", (x, .20, z), (2.2, 1.0, 1.86), "A46448",
             material=wood, shape=0, collide=False)
        beam(markers, "Harbor marker mast", (x, .53, z), (x, 3.22, z), .24, "84624F")
        part(markers, "Harbor buoy brass collar", (x, 2.94, z), (.51, .24, .51),
             "C3965C", collide=False)
        if index in (1, 3, 5):
            sign(markers, "HARBOR LIMIT", x, 2.41, z, 4.03, .95, yaw, "416772")
    return coast
