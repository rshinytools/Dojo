"""Shaped sea underlay and layered coastal landforms beyond the swim limit."""

from math import cos, radians, sin


# The western row stays below the native coastal apron. It continues under the
# rendered water so Terrain streaming cannot reveal sky between the two.
SEA_SHORE = (
    (578, -2140), (506, -1180), (436, -650), (376, -435), (315, -296),
    (264, -220), (242, -154), (239, 99), (244, 174), (286, 296),
    (355, 610), (470, 1180), (561, 2120), (613, 3260),
)
SEA_BANDS = ((1610, "A6B8BA"), (2630, "A3B1B7"),
             (3970, "9DAAB3"), (5500, "98A3AD"))

ROCK_OUTLINE = (
    (-.49, -.19), (-.32, -.43), (-.03, -.49), (.23, -.45),
    (.46, -.27), (.52, .03), (.34, .37), (.09, .49),
    (-.21, .43), (-.48, .24),
)
COAST_PALETTES = (
    ("6B6479", "827389", "9C8796", "827981"),
    ("77718A", "8F8199", "A18B9E", "93879A"),
    ("8C829C", "9A8AA2", "A996AE", "A093AE"),
)


def _build_sea(parent, part, prop, triangle, smooth):
    shore = [(x, -1.10, z) for x, z in SEA_SHORE]
    for x, drift, tint in ((656, 28, "BAC9C4"), (975, 0, "AABEBB")):
        # Bending the bands lets them overlap the cliff mouths and narrows the
        # clearer water toward the north, without out-of-bounds swimmable water.
        edge = [(x + drift * sin(i * .77), -1.10, z)
                for i, (_, z) in enumerate(SEA_SHORE)]
        for (a, b), (c, d) in zip(zip(shore, shore[1:]), zip(edge, edge[1:])):
            triangle(parent, a, b, c, tint, name="Coastal sea underlay",
                     thickness=.22, material=smooth, shadow=False)
            triangle(parent, b, d, c, tint, name="Coastal sea underlay",
                     thickness=.22, material=smooth, shadow=False)
        shore = edge
    left = 975
    margins = (SEA_SHORE[0][1], -650, 990, 2120, SEA_SHORE[-1][1])
    for right, tint in SEA_BANDS:
        for front, back in zip(margins, margins[1:]):
            sea = part(parent, "Distant coastal water",
                       ((left+right)/2, -1.10, (front+back)/2),
                       (right-left, .22, back-front), tint,
                       material=smooth, collide=False)
            prop(sea, "bool", "CastShadow", False)
        left = right


def _build_headland(parent, origin, dimensions, bearing, shade, triangle, slate):
    """Create a submerged toe, irregular bluff, and narrower ridge crown."""
    x, z = origin
    width, depth, height = dimensions
    c, s = cos(radians(bearing)), sin(radians(bearing))
    palette = COAST_PALETTES[shade]
    contour = (.57, .79, .91, .67, .94, .85, .63, .82, .68, .54)
    layers = ((1, 0, 0, 0), (.86, .40, .04, -.035), (.58, .78, -.035, -.075))
    if shade > 0:
        layers = (layers[0], layers[2])
    all_rings = []
    for span, lift, across, reach in layers:
        ring = []
        for index, (u, v) in enumerate(ROCK_OUTLINE):
            dx = (span * u + across) * width
            dz = (span * v + reach) * depth
            ring.append((x + dx * c + dz * s,
                         -2.8 + (height + 2.8) * lift * contour[index],
                         z - dx * s + dz * c))
        all_rings.append(ring)
    for level, (lower, upper) in enumerate(zip(all_rings, all_rings[1:])):
        for i, low in enumerate(lower):
            j = (i + 1) % len(lower)
            color = palette[(i + (1 if level else 0)) % 3]
            triangle(parent, low, lower[j], upper[i], color, name="Folded sea cliff",
                     thickness=.16, material=slate, shadow=False)
            triangle(parent, lower[j], upper[j], upper[i], color, name="Folded sea cliff",
                     thickness=.16, material=slate, shadow=False)
    for i, point in enumerate(all_rings[-1]):
        # Two unequal ridge tips create one longer landform silhouette.
        peak = (-width * .12, height, -depth * .14) if i in (0, 1, 2, 7, 8, 9) else (
            width * .20, height * .82, -depth * .02)
        dx, y, dz = peak
        crest = (x + dx * c + dz * s, y, z - dx * s + dz * c)
        other = all_rings[-1][(i + 1) % len(ROCK_OUTLINE)]
        triangle(parent, point, other, crest, palette[(i + 1) % len(palette)],
                 name="Coastal ridge crown", thickness=.16, material=slate, shadow=False)
        if i in (2, 6):
            # Join the two crown fans along the split ridge.
            dx, y, dz = (width * .20, height * .82, -depth * .02) if i == 2 else (
                -width * .12, height, -depth * .14)
            other_crest = (x + dx * c + dz * s, y, z - dx * s + dz * c)
            triangle(parent, other, crest, other_crest, palette[-1],
                     name="Coastal saddle crown", thickness=.16, material=slate, shadow=False)


def build_coastal_horizon(offshore, *, item, prop, part, triangle, slate, smooth):
    """Continue the visible sea with lower surfaces and distant landforms."""
    sea = item(offshore, "Folder", "Continuous coastal sea")
    _build_sea(sea, part, prop, triangle, smooth)

    # North faces carry the diagonal view from Crown Crossing. The lower
    # southern string keeps a different silhouette behind the Harbor piers.
    for label, formations in (
        ("Cinder-facing coastline", (
            ((569, -145), (88, 60, 25), 39, 0),
            ((717, -169), (149, 101, 42), 31, 1),
            ((924, -214), (213, 148, 62), 40, 1),
            ((1285, -314), (302, 193, 74), 48, 2),
        )),
        ("Tideharbor offshore archipelago", (
            ((636, 237), (103, 76, 20), -26, 0),
            ((873, 441), (167, 120, 37), -32, 1),
            ((1054, 683), (241, 157, 48), -30, 1),
            ((1665, 1420), (383, 202, 65), -29, 2),
        )),
    ):
        silhouettes = item(offshore, "Model", label)
        prop(silhouettes, "token", "LevelOfDetail", 4)
        for origin, dimensions, bearing, shade in formations:
            _build_headland(silhouettes, origin, dimensions, bearing, shade, triangle, slate)
