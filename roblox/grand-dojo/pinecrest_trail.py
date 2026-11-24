"""The continuous Skywalk courtyard spur and the Pinecrest overlook."""

from math import atan2, ceil, degrees, hypot


PINECREST_PATH = (
    (-4.70, 25.052, -254.00), (-8.50, 25.052, -254.00),
    (-19.50, 27.45, -257.50), (-25.50, 29.55, -268.00),
    (-25.50, 31.95, -279.50), (-24.00, 34.00, -288.00),
)
PINECREST_WIDTH = 5.20
PINECREST_DECK = (-24.00, 34.00, -292.10)
WIND_LOOKOUT_DECK = (-6.20, 30.50, -290.00)
RIDGE_WIDTH = 5.20
RIDGE_PATH = (
    (-6.20, 30.50, -294.55), (-6.20, 30.50, -295.10),
    (-6.20, 31.40, -303.80), (-14.25, 32.19, -303.80),
    (-14.25, 33.45, -291.10), (-17.70, 34.00, -291.10),
    (-18.10, 34.00, -291.10),
)


def build_pinecrest_trail(town, *, item, prop, part, triangle, path_edge, beam, sign,
                          swept_roof, festival_lantern, garden_shelf, garden_prop, showcase_tree,
                          slate, limestone, wood, rock, grass, stone_variant, rock_variant,
                          material_variant_field):
    trail = item(town, "Model", "Pinecrest Trail")
    prop(trail, "token", "ModelStreamingMode", 1)
    prop(trail, "token", "LevelOfDetail", 4)
    ramps = item(trail, "Folder", "Pinecrest ramps")
    locations = item(trail, "Folder", "Pinecrest trail bounds")
    cliff = item(trail, "Model", "Pinecrest carved cliff")
    half = PINECREST_WIDTH / 2
    tones = ("A697A5", "ADA0AB", "A394A2")
    west, east = (path_edge(PINECREST_PATH, side * half) for side in (-1, 1))
    for index, (a, b, c, d) in enumerate(zip(west, west[1:], east[1:], east)):
        points = [(x, y - .24, z) for x, y, z in (a, b, c, d)]
        for ia, ib, ic in ((0, 1, 2), (0, 2, 3)):
            triangle(ramps, points[ia], points[ib], points[ic], tones[index % 3],
                     name="Pinecrest slate tread", material=slate, thickness=.48, collide=True)
        start, finish = PINECREST_PATH[index:index+2]
        dx, dy, dz = (v - u for u, v in zip(start, finish))
        yaw = degrees(atan2(dx, dz))
        pitch = -degrees(atan2(dy, hypot(dx, dz)))
        x, y, z = ((u + v) / 2 for u, v in zip(start, finish))
        bounds = part(locations, "Pinecrest path volume", (x, y + 2.82, z),
                      (PINECREST_WIDTH, 5.62, hypot(dx, dy, dz) + .55), "FFF0D2",
                      yaw=yaw, pitch=pitch, transparency=1, collide=False)
        prop(bounds, "bool", "CastShadow", False)

    def railing(points):
        for a, b in zip(points, points[1:]):
            for lift, tone, size in ((.56, "745267", .18), (1.42, "8A5E6C", .24)):
                beam(trail, "Pinecrest cedar guardrail", (a[0], a[1] + lift, a[2]),
                     (b[0], b[1] + lift, b[2]), size, tone, collide=True)
            steps = max(1, ceil(hypot(b[0]-a[0], b[2]-a[2]) / 3.80))
            for i in range(steps):
                x, y, z = (u + (v - u) * i / steps for u, v in zip(a, b))
                part(trail, "Pinecrest rail post", (x, y + .72, z), (.31, 1.50, .31), "765465", material=wood)
                part(trail, "Pinecrest brass newel cap", (x, y + 1.49, z), (.45, .15, .45),
                     "C09761", collide=False)

    dx, dy, dz = PINECREST_DECK
    floor = part(trail, "Pinecrest overlook deck", (dx, dy-.29, dz), (12.60, .58, 10.20),
                 "B4A1AA", material=limestone)
    prop(floor, "string", material_variant_field, stone_variant)
    front, back = dz+4.99, dz-4.94
    for side in (-1, 1):
        handrail = path_edge(PINECREST_PATH, side*(half-.13))
        # The entry rail starts at the existing courtyard edge.
        x, y, z = handrail[0]
        handrail[0] = (x-2.58, y, z)
        boundary = dx-side*6.14
        entry_rail = [*handrail, (dx-side*2.50, dy, front), (boundary, dy, front)]
        if side == -1:
            crossing_z = RIDGE_PATH[-1][2]
            opening = RIDGE_WIDTH / 2
            railing([*entry_rail, (boundary, dy, crossing_z + opening)])
            railing([(boundary, dy, crossing_z - opening), (boundary, dy, back), (dx, dy, back)])
        else:
            railing([*entry_rail, (boundary, dy, back), (dx, dy, back)])

        inner = path_edge(PINECREST_PATH, side*(half+.10))
        middle = path_edge(PINECREST_PATH, side*4.85)
        outer = path_edge(PINECREST_PATH, side*8.10)
        for i in range(1, len(inner)-1):
            a, b = [(x,y-.48,z) for x,y,z in inner[i:i+2]]
            c, d = [(x,y-6.65+(j%2)*.60,z) for j,(x,y,z) in enumerate(middle[i:i+2],i)]
            e, f = [(x,-5.85,z) for x,_,z in outer[i:i+2]]
            for face, tint in (((a,c,b),"9A8693"), ((b,c,d),"8F7E8B"),
                               ((c,e,d),"746977"), ((d,e,f),"7F7080")):
                triangle(cliff,*face,tint,name="Pinecrest cliff face",material=rock,shadow=False,thickness=.34)
    for facet in cliff.findall("Item"):
        prop(facet, "string", material_variant_field, rock_variant)
    for width, depth, drop, height, shade in ((12.85,10.4,.59,4.15,"998793"),
                                             (14.45,12.25,4.10,6.1,"857787"),
                                             (17.20,15.5,9.62,30.55,"756979")):
        garden_shelf(cliff,dx,dy-drop,dz,width,depth,height,shade,rock,collide=False)
    for x,y,z,yaw,scale in ((-22.6,24.1,-260.54,-28,.34),(-30.26,27.8,-277.16,43,.39),
                           (-31.83,30.8,-293.06,31,.42)):
        garden_shelf(cliff,x,y,z,4.90,4.53,3.25,"958393",rock,collide=False)
        garden_shelf(cliff,x,y+.11,z,3.88,3.46,.31,"748451",grass,collide=False)
        showcase_tree(cliff,x+.31,z-.43,False,scale,yaw,y+.11,compact=True)
        garden_prop(cliff,"bankRock",(x-.79,y-.09,z+.29),.18,yaw,"A19296")
        garden_prop(cliff,"mossFlowers",(x+.57,y+.11,z+.70),.17,yaw+39,"DCA3BE")
        garden_prop(cliff,"meadowGrass",(x-.13,y+.10,z+.67),.20,yaw+83,"A8B473")

    for z in (-257.03,-250.97):
        part(trail,"Trail gate slate foot",(-7.50,25.26,z),(.82,.49,.82),"8D7E90",material=slate,collide=False)
        part(trail,"Trail lacquer post",(-7.50,28.34,z),(.53,6.15,.53),"925F69",material=wood,collide=False)
        festival_lantern(trail,-7.16,29.60,z,.45,light=False)
    part(trail,"Trail gate lintel",(-7.50,31.54,-254),(.68,.62,7.26),"784958",material=wood,collide=False)
    swept_roof(trail,-7.50,31.87,-254,2.8,8.22,.67,fine_tiles=False)
    sign(trail,"PINECREST OVERLOOK",-7.10,31.54,-254,7.37,.91,90,"624A67",face_only=True)

    shelter_x,shelter_z=dx-.66,dz-1.72
    for x in (shelter_x-4.15,shelter_x+4.15):
        for z in (shelter_z-2.34,shelter_z+2.34):
            part(trail,"Pinecrest pillar footing",(x,dy+.25,z),(.82,.50,.84),"99879A",material=slate)
            part(trail,"Pinecrest pavilion pillar",(x,dy+3.10,z),(.51,5.70,.51),"9D6A6E",material=wood)
        festival_lantern(trail,x+(.72 if x<shelter_x else -.72),dy+4.86,shelter_z+2.28,.59,light=False)
    swept_roof(trail,shelter_x,dy+6.02,shelter_z,10.36,7.65,2.24,fine_tiles=False,signature=True)
    part(trail,"Pinecrest lintel",(shelter_x,dy+5.68,shelter_z+2.43),(8.86,.43,.78),
         "825165",material=wood,collide=False)
    sign(trail,"PINECREST OVERLOOK",shelter_x,dy+5.66,shelter_z+2.84,7.36,.96,0,"624A67")
    part(trail,"Valley-facing pine bench",(shelter_x,dy+.81,shelter_z-2.15),(5.26,.27,1.20),
         "AF7972",material=wood)
    for x in (shelter_x-1.95,shelter_x+1.95):
        part(trail,"Pinecrest bench foot",(x,dy+.34,shelter_z-2.15),(.42,.68,.85),"8F7C8E",material=slate)
    sign(trail, "WIND LOOKOUT", dx + 6.02, dy + 1.84, dz - 3.13, 3.06, .59, -90, "624A67")


def build_pinecrest_crossing(town, *, item, prop, part, triangle, path_edge, beam, sign,
                            swept_roof, festival_lantern, garden_shelf, garden_prop,
                            slate, cedar, rock, grass, fabric, cedar_variant, variant_field):
    crossing = item(town, "Model", "Pinecrest Crossing")
    prop(crossing, "token", "ModelStreamingMode", 1)
    prop(crossing, "token", "LevelOfDetail", 4)
    bounds = item(crossing, "Folder", "Pinecrest Crossing location bounds")
    west, east = (path_edge(RIDGE_PATH, side * RIDGE_WIDTH / 2) for side in (-1, 1))
    deck_tints = ("A87863", "B38369", "B88A70")
    for index, (a, b, c, d) in enumerate(zip(west, west[1:], east[1:], east)):
        a, b, c, d = [(x, y - .22, z) for x, y, z in (a, b, c, d)]
        for p, q, r in ((a, b, c), (a, c, d)):
            triangle(crossing, p, q, r, deck_tints[index % 3], name="Cedar crossing deck",
                     thickness=.44, material=cedar, collide=True)
        start, end = RIDGE_PATH[index:index+2]
        dx, dy, dz = (v - u for u, v in zip(start, end))
        board_rows = max(1, ceil(hypot(dx, dz) / 2.05))
        for row in range(1, board_rows):
            fraction = row / board_rows
            edges = [tuple(u + (v - u) * fraction for u, v in zip(p, q))
                     for p, q in ((a, b), (a, c), (d, c))]
            edges = [(x, y + .231, z) for x, y, z in edges]
            for p, q in zip(edges, edges[1:]):
                groove = beam(crossing, "Cedar board seam", p, q, .034, "946F61")
                prop(groove, "bool", "CastShadow", False)
        x, y, z = ((u + v) / 2 for u, v in zip(start, end))
        volume = part(bounds, "Ridge path volume", (x, y + 2.8, z),
                      (RIDGE_WIDTH, 5.6, hypot(dx, dy, dz) + 1.20), "FFF0D2",
                      yaw=degrees(atan2(dx, dz)), pitch=-degrees(atan2(dy, hypot(dx, dz))),
                      transparency=1, collide=False)
        prop(volume, "bool", "CastShadow", False)
    for surface in crossing.findall("Item[@class='WedgePart']"):
        prop(surface, "string", variant_field, cedar_variant)

    def raised(point, amount):
        x, y, z = point
        return x, y + amount, z

    for side in (-1, 1):
        shoulder = path_edge(RIDGE_PATH, side * (RIDGE_WIDTH / 2 - .12))
        for index, (a, b) in enumerate(zip(shoulder, shoulder[1:])):
            for height, size, tint, label in ((-.39, .34, "614C59", "Cedar deck rim"),
                                              (.64, .18, "80576A", "Lower handrail"),
                                              (1.48, .24, "9E646F", "Cedar handrail")):
                beam(crossing, label, raised(a, height), raised(b, height), size, tint, collide=height > 0)
            if index == 0 or index == len(shoulder) - 2:
                continue
            count = max(1, ceil(hypot(b[0] - a[0], b[2] - a[2]) / 3.5))
            for step in range(count):
                point = tuple(u + (v - u) * step / count for u, v in zip(a, b))
                part(crossing, "Crossing railing post", raised(point, .62), (.34, 1.83, .34),
                     "775061", material=cedar)
                part(crossing, "Crossing brass cap", raised(point, 1.57), (.46, .12, .46),
                     "D8AD66", collide=False)
        festival_lantern(crossing, *raised(shoulder[2 if side < 0 else 3], 1.89), .44, light=False)

    # Terraced rock feet hold up the span and leave the ravine visible between them.
    for index, (x, top, z) in enumerate(((-6.32, 31.16, -301.30), (-13.78, 32.16, -303.78),
                                         (-14.55, 33.12, -294.52))):
        for drop, height, width, depth, tint in ((.44, 2.4, 3.25, 3.12, "9F8D9B"),
                                                  (2.55, 5.9, 4.45, 4.22, "8F7E91"),
                                                  (7.92, 8.75, 5.84, 5.51, "807287"),
                                                  (16.22, 17.8, 7.10, 7.40, "71647B")):
            support = part(crossing, "Hewn crossing pier", (x, top - drop - height / 2, z),
                           (width, height, depth), tint, yaw=3 - 4 * index, material=rock, collide=False)
            prop(support, "bool", "CastShadow", False)
        shelf_x = x + (2.40 if index % 2 == 0 else -2.40)
        garden_shelf(crossing, shelf_x, top - 4.50, z + .70, 3.30, 3.06, 1.35, "8A7A8C", slate, collide=False)
        garden_shelf(crossing, shelf_x, top - 4.34, z + .70, 3.01, 2.67, .29, "73894E", grass, collide=False)
        garden_prop(crossing, "bankRock", (shelf_x + .45, top - 4.36, z + .62), .27, 22 + index * 30, "9C8A9D")
        garden_prop(crossing, "meadowGrass", (shelf_x - .37, top - 4.32, z + .95), .21, 45 + index * 55)
        garden_prop(crossing, "rockVine", (x, top - 4.74, z + 2.42), .49, index * 30)

    x, y, z = WIND_LOOKOUT_DECK
    portal_z = z - 4.05
    for side in (-1, 1):
        post_x = x + side * 3.09
        part(crossing, "Crossing portal footing", (post_x, y + .29, portal_z),
             (.75, .58, .78), "9B8A9B", material=slate)
        part(crossing, "Crossing portal post", (post_x, y + 3.18, portal_z),
             (.44, 5.82, .48), "925C68", material=cedar)
        festival_lantern(crossing, post_x, y + 4.04, portal_z + .54, .47, light=False)
    part(crossing, "Crossing portal lintel", (x, y + 5.78, portal_z),
         (7.04, .47, .69), "815061", material=cedar, collide=False)
    swept_roof(crossing, x, y + 6.00, portal_z, 8.42, 3.42, .98, fine_tiles=False)
    for side in (-1, 1):
        strut_x = x + side * 2.65
        beam(crossing, "Crossing sign brace", (strut_x, y + 5.68, portal_z),
             (strut_x, y + 5.48, portal_z + 1.31), .22, "815061")
    sign(crossing, "PINECREST CROSSING", x, y + 5.42, portal_z + 1.32, 6.22, .87, 0, "604862")

    for index, (x, y, z) in enumerate((west[2], east[3])):
        direction = 1 if index == 0 else -1
        x += direction * .26
        part(crossing, "Ridge pennant pole", (x, y + 2.15, z), (.13, 2.70, .13),
             "9C6767", material=cedar, collide=False)
        part(crossing, "Ridge pennant", (x + direction * .45, y + 2.82, z),
             (.88, .66, .07), "C6778B" if index == 0 else "E2AE69", material=fabric, collide=False)
