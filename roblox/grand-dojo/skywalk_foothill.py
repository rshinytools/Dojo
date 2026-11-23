"""A signed loop and planted headland on the west side of the Skywalk road."""

from math import cos, dist, pi, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Endpoints overlap the existing Skywalk ascent. The road begins grading at z=-111.
PATH = (
    (20.6, .13, -104.85), (13.9, .16, -104.85), (5.2, .54, -109.05),
    (-4.4, 1.95, -113.75), (-13.3, 3.62, -118.00), (-22.0, 5.47, -122.40),
    (-29.0, 7.15, -127.20), (-33.0, 8.52, -133.55), (-27.2, 8.52, -139.60),
    (-17.2, 8.16, -144.20), (-7.5, 7.45, -146.25), (5.3, 7.07, -146.25),
    (13.70, 6.85, -147.10), (20.5, 6.77, -147.40),
)
WIDTH = 5.12
SLATE_TONES = ("837985", "8A8187", "8C8086", "91858A")
GRASS_TONES = ("879361", "8B9765", "899466", "899764")


def between(a, b, fraction):
    return tuple(u + (v - u) * fraction for u, v in zip(a, b))


def below(point, height):
    return point[0], point[1] - height, point[2]


def ground_toe(z):
    # Bury skirt ends just below the plain at the southern edge and the
    # existing lower Terrain beyond the plaza foundation.
    return -.37 - 2.88 * max(0, min(1, (-z - 130) / 4.5))


def build_skywalk_foothill(parent, *, item, prop, part, triangle, beam, path_edge, sign,
                           garden_prop, lantern, rock, grass, cedar, limestone, metal,
                           rock_variant, path_variant, variant_field):
    walk = item(parent, "Model", "Cedar Foothill Walk")
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)
    paving = item(walk, "Folder", "Graded foothill path")
    banks = item(walk, "Folder", "Foothill slate and meadow slopes")
    surfaces = []

    def facet(group, corners, tint, name, material, *, thickness=.20, collide=True):
        start = len(group)
        triangle(group, *corners, tint, name=name, material=material, thickness=thickness,
                 shadow=False, collide=collide)
        variant = rock_variant if material == rock else path_variant if material == limestone else None
        if variant is not None:
            for wedge in group[start:]:
                prop(wedge, "string", variant_field, variant)

    def join(group, a, b, c, d, tint, name, material, *, thickness=.20, collide=True):
        for face in ((a, b, c), (b, d, c)):
            facet(group, face, tint, name, material, thickness=thickness, collide=collide)

    def grass_quad(a, b, c, d, tint):
        surfaces.extend(((a, b, c), (b, d, c)))
        join(banks, a, b, c, d, tint, "Foothill grass slope", grass)

    outer, inner = (path_edge(PATH, offset * WIDTH / 2) for offset in (1, -1))
    # Feather the last landing across the existing road's longitudinal grade.
    for edge in (outer, inner):
        x, _, z = edge[-1]
        edge[-1] = (x, .105 + (-z - 111) * 8.05 / 44, z)

    for index, (a, b, c, d) in enumerate(zip(outer, inner, outer[1:], inner[1:])):
        join(paving, *(below(point, .11) for point in (a, b, c, d)), "A89483",
             "Foothill sandstone path", limestone, thickness=.22)
        stones = max(2, round(dist(a, c) / 2.75))
        for step in range(stones):
            start, end = (step + .035) / stones, (step + .965) / stones
            aa, bb = between(a, c, start), between(b, d, start)
            cc, dd = between(a, c, end), between(b, d, end)
            middle = .41 if step % 2 else .62
            for left, right, tint in ((.02, middle - .012, "B39B89"),
                                      (middle + .012, .98, "BAA18E")):
                points = (between(aa, bb, left), between(aa, bb, right),
                          between(cc, dd, left), between(cc, dd, right))
                # These stone courses are a thin visual layer over the physical deck.
                join(paving, *(below(point, -.025) for point in points), tint,
                     "Foothill path stone inlay", limestone, thickness=.04, collide=False)

    # The outside slope follows the walk, dropping away in irregular grassy
    # aprons. Its east edge stays clear of the stone highway and lamps.
    trail_bank = outer[2:12]
    shoulder = path_edge(PATH, 6.6)[2:12]
    foothill = path_edge(PATH, 15.3)[2:12]
    toe = path_edge(PATH, 22.6)[2:12]
    def creek_edge(x, z):
        # Leave the east side of the creek toe behind the dry bank.
        return max(z, -160.3 - max(0, min(10, (-x - 19) * .76)))

    bands = [
        [below(point, .16) for point in trail_bank],
        [(min(9.4, x), .71 * y + .22 * sin(i * 1.66) - .47, z)
         for i, (x, y, z) in enumerate(shoulder)],
        [(min(8.1, x), ground_toe(z) + .27 * (y - ground_toe(z)), creek_edge(x, z + .55))
         for x, y, z in foothill],
        [(min(8.1, x), ground_toe(z), creek_edge(x, z)) for x, _, z in toe],
    ]
    for band, (high, low) in enumerate(zip(bands, bands[1:])):
        for index, (a, b, c, d) in enumerate(zip(high, high[1:], low, low[1:])):
            grass_quad(a, b, c, d, GRASS_TONES[(index + band) % len(GRASS_TONES)])

    # Fill the headland inside the road's bend. The polygon follows the inner
    # edge and fans into one rounded, planted crest, with a low eastern toe.
    rim = [below(point, .19) for point in inner[2:12]]
    rim += [(6.2, 3.15, -139.45), (7.1, -.28, -130.8), (6.9, -.24, -118.4)]
    crown = (-10.8, 9.65, -128.45)
    shoulders = [between(a, crown, .48) for a in rim]
    for index, (a, b) in enumerate(zip(rim, rim[1:] + rim[:1])):
        c, d = shoulders[index], shoulders[(index + 1) % len(rim)]
        grass_quad(a, b, c, d, GRASS_TONES[index % len(GRASS_TONES)])
        surfaces.append((c, d, crown))
        facet(banks, (c, d, crown), GRASS_TONES[(index + 1) % len(GRASS_TONES)], "Foothill meadow crown", grass)

    # Step back the higher cedar shoulder beyond the walk and leave a shallow
    # gully between the two rises. Its silhouette frames the Skywalk approach.
    ridge_center = (-49.5, 16.25, -157.2)
    ridge_bands = []
    for radius, y in ((1.0, -3.54), (.75, 2.10), (.49, 8.80), (.22, 13.80)):
        outline = []
        for index in range(12):
            angle = index * pi / 6
            edge = 1 + .12 * sin(index * 1.87) - .072 * cos(index * 2.63)
            x = ridge_center[0] + cos(angle) * 24.8 * radius * edge + (1 - radius) * 2.6
            z = ridge_center[2] + sin(angle) * 15.8 * radius * edge + (1 - radius) * 1.4
            outline.append((x, y + .92 * (1 - abs(radius - .50)) * sin(index * .92), z))
        ridge_bands.append(outline)
    for index, (low, high) in enumerate(zip(ridge_bands, ridge_bands[1:])):
        for i in range(12):
            j = (i + 1) % 12
            grass_quad(low[i], low[j], high[i], high[j], GRASS_TONES[(i + index) % len(GRASS_TONES)])
    for index, a in enumerate(ridge_bands[-1]):
        face = (a, ridge_bands[-1][(index + 1) % 12], ridge_center)
        surfaces.append(face)
        facet(banks, face, GRASS_TONES[index % len(GRASS_TONES)], "High shoulder grass", grass)

    # Bedrock peeks between the short grass slopes in low, irregular ledges.
    seams = item(walk, "Folder", "Planted slate outcrops")
    for index, (x, z, width, depth) in enumerate(((-11.9, -106.3, 6.9, 4.5), (-29.5, -116.0, 7.0, 4.3),
        (-43.2, -132.4, 7.7, 5.8), (-35.9, -147.1, 8.5, 5.6), (-14.5, -151.3, 6.6, 4.7),
        (-53.1, -149.1, 8.0, 4.6), (-61.0, -155.2, 7.6, 5.7), (-45.7, -157.0, 6.5, 4.5),
        (-10.7, -123.5, 5.0, 3.2), (-22.7, -130.5, 6.1, 3.2))):
        outline = ((-.51, -.08), (-.37, -.43), (.28, -.48), (.49, -.16), (.34, .38), (-.27, .46))
        rim, roots = [], []
        for vertex, (u, v) in enumerate(outline):
            px, pz = x + u * width, z + v * depth
            y = ridge_surface_height(surfaces, px, pz)
            rim.append((px, y + .43 + .34 * sin(index * 2.2 + vertex * .88), pz))
            roots.append((px, y - .24, pz))
        for j, (a, b) in enumerate(zip(rim, rim[1:] + rim[:1])):
            join(seams, a, b, roots[j], roots[(j + 1) % len(rim)],
                 SLATE_TONES[(index + j) % len(SLATE_TONES)], "Slate outcrop seam", rock, collide=False)
        center = (x, ridge_surface_height(surfaces, x, z) + .52, z)
        for j, (a, b) in enumerate(zip(rim, rim[1:] + rim[:1])):
            facet(seams, (center, a, b), SLATE_TONES[(index + j) % len(SLATE_TONES)],
                  "Slate outcrop cap", rock, collide=False)
        garden_prop(seams, "rockVine", (x + .12, center[1] - .28, z + depth * .41),
                    .33, 12 + index * 29, "849567")

    # The upper connection crosses the lower verge on seated stone supports.
    for index, (x, y, z) in enumerate(((8.6, 6.91, -146.55), (12.2, 6.84, -146.94))):
        for level in range(4):
            bottom = 1.12 + level * 1.39
            part(banks, "Slate walk abutment", (x, bottom + .71, z),
                 (2.95 - .24 * level, 1.52, 5.02 - .47 * level),
                 SLATE_TONES[(index + level) % len(SLATE_TONES)], material=rock, collide=False)
        part(banks, "Cedar crossbeam at the upper join", (x, y - .36, z), (1.05, .36, 5.22),
             "8D624E", material=cedar, collide=False)

    grove = item(walk, "Folder", "Cedar groups and owned understory")

    def wood_or_leaf(group, name, position, size, tint, **rotation):
        trunk = name.endswith("trunk")
        if not trunk:
            size = (size[0] * 1.22, size[1] * .80, size[2] * 1.14)
        piece = part(group, name, position, size, tint, material=cedar if trunk else grass,
                     collide=False, **rotation)
        prop(piece, "bool", "CastShadow", False)

    for index, (x, z, scale) in enumerate(((-18.3, -128.7, .86), (-10.44, -127.48, .98),
        (-4.4, -130.5, .68), (-26.8, -133.3, .63), (-48.0, -151.3, .81),
        (-50.9, -156.8, 1.08), (-53.9, -160.6, .89), (-48.1, -163.7, .74),
        (-57.7, -153.9, .76), (-41.5, -153.3, .66), (-34.3, -153.7, .66),
        (-38.9, -136.4, .68), (-29.7, -116.9, .76), (-18.7, -110.9, .61),
        (-9.5, -108.7, .48), (-2.1, -149.7, .58))):
        ground = ridge_surface_height(surfaces, x, z)
        hillside_cedar(wood_or_leaf, grove, x, ground - .18, z, scale, index)
        understory = [("meadowCover", .45, .65, .26, "A0A96C"),
                      ("meadowGrass", -.70, .02, .19, "9DA56A")]
        if index % 3 != 1:
            understory.append(("mossFlowers", -.58, .34, .18, "D5B79C"))
        if index in (0, 4, 7, 10, 12):
            understory.append(("bankRock", .24, -.63, .23, "887D87"))
        for key, dx, dz, size, tint in understory:
            y = ridge_surface_height(surfaces, x + dx, z + dz)
            garden_prop(grove, key, (x + dx, y - .08, z + dz), size, index * 49, tint)

    lookout = item(walk, "Folder", "Cedar Foothill lookout rail")
    # Above the west slope, a continuous rail lets players pause at the bend.
    edge = path_edge(PATH, 2.43)
    for index in (5, 6, 7, 8):
        a, b = edge[index:index + 2]
        for drop, width, tint in ((-1.03, .23, "91573F"), (-.40, .16, "75493D")):
            beam(lookout, "Foothill overlook guardrail", below(a, drop), below(b, drop), width, tint, collide=True)
        for point in (a, between(a, b, .50)):
            part(lookout, "Cedar overlook post", below(point, -.55), (.32, 1.28, .32),
                 "82533E", material=cedar, collide=False)
            part(lookout, "Overlook bronze cap", below(point, -1.22), (.41, .12, .41),
                 "BC9459", material=metal, collide=False)
    for index in (4, 7, 10):
        x, y, z = inner[index]
        lantern(walk, x, y + .88, z, .53, light=False)
    for x, y, z, yaw in ((11.8, 1.45, -101.1, 37), (12.7, 8.08, -149.9, 136)):
        part(walk, "Foothill wayfinding post", (x, y - .52, z), (.37, 1.86, .38),
             "81533F", material=cedar, collide=False)
        sign(walk, "CEDAR FOOTHILL WALK", x, y + .43, z, 4.8, .91, yaw, "4A6B52")
