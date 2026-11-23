"""Layered scenery seen from the South Gate and the trail lookout."""

from art.valley_ridge_layout import ridge_facets


# The near shoulders stay outside the play space. The two hinterland profiles
# dip between their summits to keep a band of sky beyond the lookout roof.
RIDGES = (
    ("South Valley west shoulder", -76, 178, 101, 28,
     (0, 8, 18, 27, 38, 33, 42, 34, 22, 11, 3, 0),
     "555866", "8C8791", "A2959B"),
    ("South Valley east shoulder", 88, 197, 113, 34,
     (0, 5, 13, 27, 38, 46, 39, 33, 44, 30, 18, 9, 0),
     "615767", "9B8790", "AB969F"),
    ("South Valley middle ridge", -16, 249, 268, 40,
     (0, 12, 24, 35, 49, 61, 53, 38, 31, 26, 32, 45, 56, 63, 48, 42, 29, 17, 0),
     "746780", "A88DA5", "C3A3B7"),
    ("South Valley sunset range", 19, 337, 484, 55,
     (2, 16, 32, 48, 70, 86, 104, 113, 97, 78, 72, 66,
      64, 77, 91, 86, 103, 118, 96, 80, 67, 49, 35, 21, 3),
     "A17992", "C697AC", "DBAAB9"),
)
TOE_DROP = (8, 10, 26, 34)
# The sunset catches these southern faces directly in Studio.
SUNSET_GRADE = ((.68, .76, .86), (.68, .76, .86), (.63, .72, .84), (.64, .71, .81))

GROVES = (
    ((-43, 169, .69), (-49, 165, .92), (-57, 172, .73), (-61, 163, 1.04),
     (-66, 171, .96), (-74, 174, 1.10), (-93, 172, .86), (-102, 164, .68)),
    ((49, 183, .76), (51, 187, .91), (57, 183, 1.07), (61, 188, .83),
     (66, 189, 1.13), (95, 191, .89), (101, 183, .97), (108, 187, .71)),
    ((-52, 239, .82), (-47, 239, .75), (-30, 241, .96), (-25, 240, .69),
     (49, 242, .72), (55, 240, .87), (58, 244, .80), (69, 241, .81)),
    (),
)


def ridge_surface_height(faces, x, z):
    """Intersect the vertical line at (x, z) with the authored facet surfaces."""
    heights = []
    for (ax, ay, az), (bx, by, bz), (cx, cy, cz) in faces:
        determinant = (bx - ax) * (cz - az) - (bz - az) * (cx - ax)
        if abs(determinant) < .00001:
            continue
        u = ((x - ax) * (cz - az) - (z - az) * (cx - ax)) / determinant
        v = ((bx - ax) * (z - az) - (bz - az) * (x - ax)) / determinant
        if min(u, v, 1 - u - v) >= -.00001:
            heights.append(ay + u * (by - ay) + v * (cy - ay))
    if not heights:
        raise ValueError(f"No ridge surface at ({x}, {z})")
    return max(heights)


def hillside_cedar(block, grove, x, y, z, scale, index):
    # Low, staggered foliage pads make each silhouette read at ridge distance.
    evergreen = ("394D45", "486550", "58745B", "6A815D")
    amber = ("735347", "93674F", "A77954", "BA8860")
    colors = amber if index in (3, 6) else evergreen
    block(grove, "Hillside cedar trunk", (x, y + 2.91 * scale, z),
          (.57 * scale, 6.56 * scale, .56 * scale), "61443D")
    handedness = 1 if index % 2 else -1
    for layer, (dx, dy, dz, width, rise, depth) in enumerate((
        (-.60, 3.45, .21, 4.68, 1.30, 3.61), (.73, 4.37, -.41, 4.08, 1.42, 3.38),
        (-.51, 5.45, -.12, 3.60, 1.60, 3.16), (.35, 6.63, .34, 2.80, 1.54, 2.46),
        (-.02, 7.57, .13, 1.92, 1.48, 1.85),
    )):
        block(grove, "Hillside cedar foliage", (x + handedness * dx * scale, y + dy * scale,
              z + dz * scale), (width * scale, rise * scale, depth * scale),
              colors[min(layer, 3)], shape=0, yaw=index * 21, roll=handedness * (layer - 2) * 3)


def _shrine(parent, faces, *, item, block, triangle, rock):
    shrine = item(parent, "Model", "Distant South Valley shrine")
    x, z = -38.6, 243.0
    footprint = ((-3.9, -2.8), (3.9, -2.8), (3.9, 2.8), (-3.9, 2.8))
    foundations = [(x + dx, ridge_surface_height(faces, x + dx, z + dz) - .30, z + dz)
                   for dx, dz in footprint]
    y = max(point[1] for point in foundations) + .68
    platform = [(px, y, pz) for px, _, pz in foundations]
    for a, b, c, d in zip(platform, platform[1:] + platform[:1], foundations,
                           foundations[1:] + foundations[:1]):
        for face in ((a, c, b), (b, c, d)):
            triangle(shrine, *face, "6D6370", name="Shrine seated slate footing",
                     material=rock, collide=False, shadow=False)
    block(shrine, "Shrine slate plinth", (x, y + .08, z), (8.22, .52, 6.0), "91808A", material=rock)
    block(shrine, "Shrine plaster walls", (x, y + 2.35, z), (5.9, 4.10, 3.4), "AE8776")
    block(shrine, "Shrine cedar doorway", (x, y + 1.99, z - 1.73), (2.18, 3.41, .12), "624450")
    for side in (-1, 1):
        block(shrine, "Shrine vermilion pillars", (x + side * 2.35, y + 2.48, z - 1.95),
              (.59, 4.37, .56), "9F554A")
        block(shrine, "Shrine amber inset", (x + side * 1.65, y + 2.56, z - 1.76),
              (.51, 1.58, .10), "CE9C61")
        block(shrine, "Shrine indigo roof", (x, y + 5.22, z + side * 1.63),
              (8.91, .30, 3.55), "414968", pitch=side * 21)
        block(shrine, "Shrine warm eave trim", (x, y + 4.67, z + side * 3.35),
              (9.28, .19, .23), "9C7864")
        block(shrine, "Shrine gilt roof finial", (x + side * 4.31, y + 5.93, z),
              (1.02, .21, .36), "BD9365", roll=side * 25)
    block(shrine, "Shrine indigo crown", (x, y + 5.87, z), (8.94, .31, .36), "4C526C")


def build_south_valley_backdrop(parent, *, item, prop, part, triangle, rock, smooth,
                                rock_variant, variant_field):
    """Build visual-only ridges facing the city from the south."""
    valley = item(parent, "Folder", "South Valley backdrop")

    def block(parent, name, position, size, tint, *, material=smooth, **rotation):
        piece = part(parent, name, position, size, tint, collide=False, material=material, **rotation)
        prop(piece, "bool", "CastShadow", False)

    for index, (name, x, z, width, depth, profile, shadow, sunlight, haze) in enumerate(RIDGES):
        shoulder = index < 2
        ridge = item(valley, "Model", name)
        prop(ridge, "token", "ModelStreamingMode", 1 if shoulder else 2)
        prop(ridge, "token", "LevelOfDetail", 4)
        faces = []
        for face, uv, tint in ridge_facets(x, -z, width, depth, profile, shadow,
                                          sunlight, haze, lower_detail=True):
            # Extend the feet into the valley so the cliff base does not show
            # a strip of sky between the footpath and distant mountains.
            points = tuple((px, py - TOE_DROP[index] * progress, -pz)
                           for (px, py, pz), (_, progress) in zip(face, uv))
            faces.append(points)
            color = "".join(f"{round(channel * factor):02X}"
                            for channel, factor in zip(tint, SUNSET_GRADE[index]))
            triangle(ridge, *points, color, material=rock if shoulder else smooth,
                     thickness=.28, collide=False, shadow=False)
        if shoulder:
            for wedge in ridge.findall("Item[@class='WedgePart']"):
                prop(wedge, "string", variant_field, rock_variant)
        if GROVES[index]:
            grove = item(ridge, "Folder", "Hillside grove")
            for tree_index, (px, pz, scale) in enumerate(GROVES[index]):
                hillside_cedar(block, grove, px, ridge_surface_height(faces, px, pz), pz, scale, tree_index)
        if index == 2:
            _shrine(ridge, faces, item=item, block=block, triangle=triangle, rock=rock)
