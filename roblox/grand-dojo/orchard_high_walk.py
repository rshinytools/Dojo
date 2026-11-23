"""The walkable orchard ridge above the Lantern Circuit road."""
from math import ceil, dist


NAME = "Orchard High Walk"
SUMMIT = 14.35
ASCENT = (
    (-109, .205, 25.7), (-109, .205, 20.3), (-109, .205, 17.2),
    (-114, 1.85, 13.8), (-121, 4.45, 9.4), (-128, 7.65, 4.9), (-135, 11.58, -1.5),
    (-139.15, SUMMIT-.03, -5.7), (-141.45, SUMMIT-.03, -5.7),
)
DESCENT = (
    (-156.70, SUMMIT-.02, -5.6), (-158.32, SUMMIT-.02, -5.6),
    (-162, 13.4, -3), (-170, 11.0, 2.3),
    (-176, 8.4, 8.2), (-181, 6.2, 14), (-181, 5.14, 20), (-181, 5.145, 20.48),
    (-181, 5.15, 23.0),
)
# The deck spans east to west between the two ramps.
DECK = (-157, -141, -13.75, 3.15)
ROAD_OPENING = (-185.1, -176.9)
KEEPER = (-146.2, SUMMIT, -8.9)


def pier_top(faces, center, width, depth):
    """Keep the full horizontal masonry footprint below the steepest adjacent slab."""
    x, z = center
    half_width, half_depth = width/2, depth/2
    limits = []
    for a, b, c in faces:
        xs, _, zs = zip(a, b, c)
        if (max(xs)<x-half_width or min(xs)>x+half_width
                or max(zs)<z-half_depth or min(zs)>z+half_depth):
            continue
        bx, by, bz = (end-start for start, end in zip(a, b))
        cx, cy, cz = (end-start for start, end in zip(a, c))
        area = bx*cz-cx*bz
        grade_x = (by*cz-cy*bz)/area
        grade_z = (bx*cy-cx*by)/area
        limits.append(a[1]+grade_x*(x-a[0])+grade_z*(z-a[2])
                      - abs(grade_x)*half_width-abs(grade_z)*half_depth)
    return min(limits)-.12


def build_orchard_high_walk(parent, road_start, road_end, *, item, prop, part, beam, path_edge, triangle,
                            sign, swept_roof, festival_lantern, shoreline_slate,
                            garden_shelf, garden_prop, showcase_tree, slate, limestone, cedar,
                            grass, brass, paving_variant, variant_field):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)
    west, east, north, south = DECK
    posts = set()
    road_x, road_y, road_z = (end-start for start, end in zip(road_start, road_end))

    def shoulder(path, offset):
        edge = path_edge(path, offset)
        if path is DESCENT:
            for index in (-3, -2, -1):
                x, y, z = edge[index]
                center_x, _, center_z = path[index]
                fraction = ((x-center_x)*road_x+(z-center_z)*road_z)/(road_x**2+road_z**2)
                edge[index] = (x, y+road_y*fraction, z)
        return edge

    def rail(a, b):
        for height, width in ((.52, .18), (1.39, .25)):
            a_top = (a[0], a[1]+height, a[2])
            b_top = (b[0], b[1]+height, b[2])
            beam(walk, "Orchard cedar guardrail", a_top, b_top, width, "69434F", collide=True)
        count = ceil(dist(a, b) / 4.4)
        for index in range(count + 1):
            point = tuple(round(start+(end-start)*index/count, 4) for start, end in zip(a, b))
            if point in posts:
                continue
            posts.add(point)
            x, y, z = point
            part(walk, "Orchard guardrail post", (x, y+.72, z), (.32, 1.51, .32),
                 "754752", material=cedar)
            part(walk, "Orchard brass rail cap", (x, y+1.51, z), (.44, .13, .44),
                 "C69757", material=brass, collide=False)

    for path in (ASCENT, DESCENT):
        first = len(walk)
        left, right = (shoulder(path, offset) for offset in (-3.20, 3.20))
        surfaces = []
        for (left_a, left_b), (right_a, right_b) in zip(zip(left, left[1:]), zip(right, right[1:])):
            for surface in ((left_a, right_a, right_b), (left_a, right_b, left_b)):
                surfaces.append(surface)
                collider = ((x, y-.18, z) for x, y, z in surface)
                triangle(walk, *collider, "AC958C", name="Orchard sloped flagstones",
                         thickness=.36, material=limestone, collide=True, transparency=1, shadow=False)
                facing = ((x, y-.028, z) for x, y, z in surface)
                triangle(walk, *facing, "AC958C", name="Orchard ramp stone facing",
                         thickness=.064, material=limestone, shadow=False)
        for face in list(walk)[first:]:
            if face.findtext("Properties/string[@name='Name']") == "Orchard ramp stone facing":
                prop(face, "string", variant_field, paving_variant)

        edges = [shoulder(path, offset) for offset in (-2.96, 2.96)]
        for edge in edges:
            segments = list(zip(edge, edge[1:]))
            for a, b in segments[2:-1] if path is ASCENT else segments[:-1]:
                rail(a, b)
            for a, b in segments:
                beam(walk, "Orchard stone fascia",
                     (a[0], a[1]-.38, a[2]), (b[0], b[1]-.38, b[2]), .57, "806775")
        for x, _, z in path[2:-2]:
            cap_top = pier_top(surfaces, (x,z), 4.08, 3.55)
            pier_base, pier_top_y = -4.63, cap_top-.39
            part(walk, "Orchard flared pier", (x, (pier_top_y+pier_base)/2, z),
                 (2.84, pier_top_y-pier_base, 2.65),
                 "80707B", material=slate, collide=False)
            part(walk, "Orchard pier cap", (x, cap_top-.215, z), (4.08, .43, 3.55),
                 "9D8288", material=slate, collide=False)
            spring = pier_top(surfaces, (x,z), 1.55, 1.44)
            part(walk, "Orchard pier saddle", (x, (spring+cap_top)/2-.02, z),
                 (1.55, spring-cap_top+.04, 1.44), "8D7882", material=slate, collide=False)
    part(walk, "Orchard summit paving", ((west+east)/2, SUMMIT-.29, (north+south)/2),
         (east-west, .58, south-north), "A58C83", material=limestone)
    for i in range(4):
        for j in range(4):
            cell_x, cell_z = (east-west)/4, (south-north)/4
            stone = part(walk, "Orchard inset paving",
                         (west+(i+.5)*cell_x, SUMMIT+.015, north+(j+.5)*cell_z),
                         (cell_x-.055, .024, cell_z-.06),
                         ("B59A8F", "B0A097", "C0AAA1")[(i+2*j)%3], material=limestone, collide=False)
            prop(stone, "string", variant_field, paving_variant)
            prop(stone, "bool", "CastShadow", False)
    for x in (-154.9, -149.0, -143.2):
        for z in (-10.9, .9):
            part(walk, "Summit slate buttress", (x, 6.30, z), (2.25, 15.15, 2.55),
                 "7C6B79", material=slate, collide=False)
            part(walk, "Summit buttress cap", (x, SUMMIT-.65, z), (3.21, .61, 3.5),
                 "A68A87", material=slate, collide=False)

    for (ax, az), (bx, bz) in (
        ((west+.3, north+.3), (east-.3, north+.3)),
        ((west+.3, south-.3), (east-.3, south-.3)),
        ((west+.3, north+.3), (west+.3, -9.24)),
        ((west+.3, -1.99), (west+.3, south-.3)),
        ((east-.3, north+.3), (east-.3, -9.35)),
        ((east-.3, -2.02), (east-.3, south-.3)),
    ):
        rail((ax, SUMMIT, az), (bx, SUMMIT, bz))

    for x in (-152.95, -144.98):
        for z in (-12.65, -9.95):
            part(walk, "Orchard lantern pavilion plinth", (x, SUMMIT+.22, z),
                 (.80, .44, .78), "AA8D88", material=slate)
            part(walk, "Orchard lantern pavilion column", (x, SUMMIT+3.01, z),
                 (.56, 5.78, .56), "97545E", material=cedar)
            part(walk, "Orchard column gilt collar", (x, SUMMIT+5.67, z),
                 (.74, .17, .71), "BF8C53", material=brass, collide=False)
        festival_lantern(walk, x, SUMMIT+5.10, -9.16, .73, light=False)
    swept_roof(walk, -148.97, SUMMIT+6.10, -11.22, 11.05, 5.72, 2.64, fine_tiles=False)
    sign(walk, NAME.upper(), -149, SUMMIT+5.53, -8.17, 7.61, 1.16, 0, "714650")
    for x in (-151.57, -146.31):
        part(walk, "Orchard resting bench support", (x, SUMMIT+.34, -12.36),
             (.68, .68, .70), "9C847F", material=slate)
    part(walk, "Orchard resting bench", (-149, SUMMIT+.72, -12.43),
         (6.19, .25, 1.07), "965D53", material=cedar)
    part(walk, "Orchard bench back", (-149, SUMMIT+1.09, -12.83),
         (6.19, .44, .18), "865049", material=cedar)

    for index, (x, z, top, width, depth, yaw) in enumerate((
        (-120, 5, 2.1, 10.4, 8.7, 37), (-129, 13.4, 5.3, 11.2, 7.5, 62),
        (-138, 5.8, 8.2, 11.1, 6.7, 83), (-150, 7.3, 9.3, 12.3, 8.5, 93),
        (-162, 5.9, 9.8, 10.8, 7.3, 46), (-172, -6.2, 7.4, 10.2, 8.5, 25),
    )):
        shoreline_slate(walk, x, z, -4.9, width, depth, top+4.9, yaw, shadow=False)
        garden_shelf(walk, x, top-.18, z, width*.56, depth*.58, .46, "707D59", grass, collide=False)
        for dx, dz, mesh, scale, tint in (
            (-.85, -.71, "meadowCover", .28, "98A775"),
            (.89, .82, "meadowFlowers", .42, "E4B5C0"),
            (1.13, -.61, "bankRock", .21, "B09395"),
            (-1.16, .71, "cattails", .33, "A8B77B"),
        ):
            garden_prop(walk, mesh, (x+dx, top-.04, z+dz), scale, yaw+39*index, tint)
    for x, z, y, pink, scale, yaw in (
        (-129.0, 13.4, 5.08, True, .90, 44),
        (-150.0, 7.3, 9.08, True, .88, 125),
        (-162.0, 5.9, 9.58, False, .82, 78),
        (-172.0, -6.2, 7.18, True, .94, 19),
    ):
        showcase_tree(walk, x, z, pink, scale, yaw, y, compact=True)
    for x, y, z, yaw, label in (
        (-103.8, .19, 16.5, 45, "ORCHARD HIGH WALK"),
        (-186.8, 5.38, 18.0, -28, "ORCHARD HIGH WALK"),
        (-154.5, SUMMIT, 1.9, 180, "←  LANTERN CIRCUIT"),
    ):
        part(walk, "Orchard wayfinding post", (x, y+1.50, z), (.35, 3.0, .35),
             "744753", material=cedar, collide=False)
        sign(walk, label, x, y+2.82, z, 6.4, 1.02, yaw, "704A67")
    for path, offset in ((ASCENT, -2.96), (DESCENT, 2.96)):
        for x, y, z in shoulder(path, offset)[2:-2:2]:
            festival_lantern(walk, x, y+1.95, z, .52, light=False)
