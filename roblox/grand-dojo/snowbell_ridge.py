"""A high, stair-free branch between Glacier Lantern Pavilion and Mistline."""

from math import atan2, ceil, cos, degrees, hypot, radians, sin

from frostglass_store_planting import frostglass_winter_foliage
from south_valley_backdrop import ridge_surface_height


NAME = "Snowbell Ridge"
WIDTH = 6.26
MISTLINE_SEGMENT = 4
MISTLINE_STATION = .27
MISTLINE_OPENING = 3.03
APPROACH = (
    (-142.40, 28.90, -204.06), (-142.40, 28.90, -208.00),
    (-138.80, 29.88, -213.80), (-132.10, 30.85, -219.90),
    (-123.60, 29.74, -223.90), (-114.90, 27.72, -223.00),
    (-108.70, 25.83, -220.40), (-105.36, 24.42, -217.08),
    (-101.94, 23.1396, -213.856),
)


def between(a, b, t):
    return tuple(u + (v - u) * t for u, v in zip(a, b))


def lift(point, height):
    x, y, z = point
    return x, y + height, z


def mistline_junction(path, ridge_offset, path_edge, along=0):
    rim = path_edge(path, ridge_offset)
    a, b = rim[MISTLINE_SEGMENT:MISTLINE_SEGMENT + 2]
    distance = hypot(b[0] - a[0], b[2] - a[2])
    return between(a, b, MISTLINE_STATION + along / distance)


def build_snowbell_ridge(
        roads, mistline_path, *, item, prop, part, beam, triangle, path_edge,
        sign, festival_lantern, vector, asset, cedar, slate, rock,
        snow, brass, cedar_variant, rock_variant, variant_field):
    ridge = item(roads, "Model", NAME)
    prop(ridge, "token", "ModelStreamingMode", 1)
    prop(ridge, "token", "LevelOfDetail", 4)

    def detail(parent, name, position, size, tint, material, **options):
        node = part(parent, name, position, size, tint, material=material, collide=False, **options)
        prop(node, "bool", "CastShadow", False)
        return node

    # End inside the outer edge of the stone deck, with a slight vertical
    # offset so the two walkable surfaces overlap without texture flicker.
    def deck_join(along):
        return lift(mistline_junction(mistline_path, 4.27, path_edge, along), .022)

    return_join = mistline_junction(mistline_path, 0, path_edge)
    path = (*APPROACH, deck_join(0))
    deck = item(ridge, "Model", "Snowbell cedar deck")
    edges = tuple(path_edge(path, side * WIDTH / 2) for side in (-1, 1))
    for edge, side in zip(edges, (-1, 1)):
        edge[-1] = deck_join(side * WIDTH / 2)

    cedar_colors = ("9C745F", "B38469", "AA7B63", "987461", "BA8970")
    for index, (a, b, c, d) in enumerate(zip(edges[0], edges[0][1:], edges[1][1:], edges[1])):
        corners = tuple(lift(p, -.22) for p in (a, b, c, d))
        for face in ((0, 1, 2), (0, 2, 3)):
            triangle(deck, *(corners[i] for i in face), "866659", name="Snowbell walkable surface",
                     material=cedar, collide=True, shadow=False, thickness=.44)
        start, finish = path[index:index + 2]
        dx, dy, dz = (v - u for u, v in zip(start, finish))
        length = hypot(dx, dz)
        boards = ceil(length / .91)
        for board in range(boards):
            tint = cedar_colors[(index * 3 + board) % len(cedar_colors)]
            if board in (0, boards - 1) or index == len(path) - 2:
                # Fit end boards to the miter so adjacent runs do not cross at bends.
                lo, hi = (board + .04) / boards, (board + .96) / boards
                ends = (between(a, b, lo), between(a, b, hi), between(d, c, hi), between(d, c, lo))
                plank = tuple(lift(between(p, q, .03), .043) for p, q in zip(ends, reversed(ends)))
                first = len(deck)
                for face in ((0, 1, 2), (0, 2, 3)):
                    triangle(deck, *(plank[i] for i in face), tint, name="Snowbell fitted cedar board",
                             material=cedar, thickness=.055, shadow=False)
                for piece in deck[first:]:
                    prop(piece, "string", variant_field, cedar_variant)
                continue
            t = (board + .5) / boards
            plank = detail(deck, "Snowbell cedar board", lift(between(start, finish, t), .022),
                           (WIDTH - .38, .075, length / boards - .045),
                           tint, cedar,
                           yaw=degrees(atan2(dx, dz)), pitch=-degrees(atan2(dy, length)))
            prop(plank, "string", variant_field, cedar_variant)

    rails = item(ridge, "Model", "Indigo railings and lanterns")
    for side in (-1, 1):
        rail = path_edge(path, side * (WIDTH / 2 - .10))
        rail[-1] = mistline_junction(mistline_path, 4.15, path_edge, side * MISTLINE_OPENING)
        for i, (a, b) in enumerate(zip(rail, rail[1:])):
            for y, width, tint in ((.53, .20, "596D83"), (1.40, .24, "4E5E7B")):
                bar = beam(rails, "Snowbell cedar rail", lift(a, y), lift(b, y), width, tint, collide=True)
                prop(bar, "bool", "CastShadow", False)
            fascia = beam(rails, "Snowbell bearer beam", lift(a, -.33), lift(b, -.33), .47, "69565E")
            prop(fascia, "bool", "CastShadow", False)
            posts = max(1, ceil(hypot(b[0] - a[0], b[2] - a[2]) / 3.85))
            for post in range(posts):
                mount = between(a, b, post / posts)
                detail(rails, "Snowbell carved newel", lift(mount, .73), (.34, 1.52, .36), "60748B", cedar)
                detail(rails, "Snowbell brass cap", lift(mount, 1.50), (.46, .15, .47), "C59869", brass)
            if (side, i) in ((-1, 0), (1, 2), (-1, 4), (1, 6), (-1, 8)):
                mount = between(a, b, .32)
                detail(rails, "Snowbell lantern mast", lift(mount, 1.25), (.31, 2.18, .31), "617185", cedar)
                festival_lantern(rails, *lift(mount, 2.48), .49, light=False,
                                 tint="FFD6A5", entrance_paper=True)

    # Three rock shoulders pin the elevated deck over the snow basin. Piers
    # are decorative so they do not interrupt foot travel below the branch.
    buttresses = item(ridge, "Model", "Snowbell snow-covered buttresses")
    formations = (
        (-138.95, -214.68, -4, 28.90, 6.9, 7.8, 14),
        (-125.95, -226.20, -4, 29.24, 9.5, 8.3, 36),
        (-115.95, -225.20, -2, 26.98, 7.9, 7.1, 5),
        (-109.05, -223.65, 2, 24.70, 7.0, 5.8, 42),
    )
    terrain_faces = []
    for index, (x, z, foot, crown, width, depth, yaw) in enumerate(formations):
        height = crown - foot
        rock_color = ("777486", "848194", "918DA1", "9F9DB1")
        rings = []
        for level, scale, drift in ((0, 1, 0), (.43, .83, -.6), (.74, .67, .6), (.95, .46, 1.1), (1, .35, .85)):
            ring = []
            for radial, stretch in enumerate((1, .87, 1.08, .90, 1.03, .81, 1.01)):
                angle = radians(yaw + radial * 360 / 7)
                ring.append((x + width * scale * stretch * cos(angle) + drift,
                             foot + height * level + (.36 if radial % 3 == 1 else 0),
                             z + depth * scale * stretch * sin(angle) - .25 * drift))
            rings.append(ring)
        for band, (lower, upper) in enumerate(zip(rings, rings[1:])):
            for edge, a in enumerate(lower):
                end = (edge + 1) % len(lower)
                powder = band == 3 or (band == 2 and edge in (1, 2))
                before = len(buttresses)
                tint = ("C6CADD", "D9DDEA")[edge % 2] if powder else rock_color[(edge + band + index) % 4]
                for points in ((a, lower[end], upper[edge]), (lower[end], upper[end], upper[edge])):
                    terrain_faces.append(points)
                    triangle(buttresses, *points, tint, name="Snowbell snow shelf" if powder else "Snowbell slate face",
                             material=snow if powder else rock, shadow=False)
                if not powder:
                    for piece in buttresses[before:]:
                        prop(piece, "string", variant_field, rock_variant)
        cap = rings[-1]
        for edge, a in enumerate(cap):
            face = ((x + .85, crown + .13, z - .21), a, cap[(edge + 1) % len(cap)])
            terrain_faces.append(face)
            triangle(buttresses, *face, "D5DAE9", name="Snowbell drift cap", material=snow, shadow=False)

    for index, (x, y, z, offset) in enumerate(((*path[1], -1), (*path[3], -1), (*path[5], 1), (*path[7], 1))):
        foot = (-5, -5, 0, 8)[index]
        cap = y - .46
        detail(buttresses, "Snowbell dressed slate pier", (x, (cap + foot) / 2, z),
               (1.90, cap - foot, 2.02), "818595", slate)
        detail(buttresses, "Snowbell square bearing", (x, cap, z), (3.12, .57, 2.64), "A0A4B0", slate)
        beam(buttresses, "Snowbell diagonal cedar brace", (x, cap - 1.92, z),
             (x + offset * 2.58, cap, z), .34, "665763")

    pine, shrub = frostglass_winter_foliage(ridge, "Snowbell winter planting", item=item, prop=prop,
                                             part=part, vector=vector, asset=asset)
    for plant, label, locations in (
            (pine, "Snowbell snowy pine", ((-139.0, -219.4, 26, .30), (-125.3, -228.4, 48, .38),
                                         (-116.1, -228.1, 71, .33), (-109.9, -226.0, 89, .29))),
            (shrub, "Snowbell frosted shrub", ((-127.1, -226.6, 54, .27),
                                              (-114.0, -226.5, 68, .24), (-108.5, -223.78, 24, .20)))):
        for x, z, yaw, scale in locations:
            plant(label, x, z, yaw, scale, ridge_surface_height(terrain_faces, x, z))

    for text, back, (x, y, z), yaw in (
            ("SNOWBELL RIDGE", "GLACIER LANTERN", (-142.40, 28.90, -204.42), 0),
            ("GLACIER LANTERN", "SKYWALK PEAKS", mistline_junction(mistline_path, 4.15, path_edge), 43)):
        # Suspend each sign above its actual opening and keep the lane open.
        for side in (-1, 1):
            r = radians(yaw)
            base = (x + side * 3.33 * cos(r), y, z - side * 3.33 * sin(r))
            detail(ridge, "Snowbell granite entry foot", lift(base, .29), (.83, .57, .81), "A6ACBA", slate)
            detail(ridge, "Snowbell entry post", lift(base, 3.17), (.42, 6.04, .43), "58728A", cedar)
        sign(ridge, text, x, y + 5.95, z, 6.38, .91, yaw, "4C647D", reverse_label=back)

    bounds = item(ridge, "Folder", NAME + " location bounds")
    for a, b in zip(path, path[1:]):
        dx, dy, dz = (v - u for u, v in zip(a, b))
        part(bounds, "Snowbell route bounds", lift(between(a, b, .5), 3.15),
             (WIDTH + .25, 5.35, hypot(dx, dy, dz) + .36), "FFFFFF",
             yaw=degrees(atan2(dx, dz)), pitch=-degrees(atan2(dy, hypot(dx, dz))),
             collide=False, transparency=1)
    return (*path, return_join)
