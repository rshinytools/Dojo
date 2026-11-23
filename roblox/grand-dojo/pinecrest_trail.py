"""The continuous Skywalk courtyard spur and the Pinecrest overlook."""

from math import atan2, ceil, degrees, hypot


PINECREST_PATH = (
    (-4.70, 25.052, -254.00), (-8.50, 25.052, -254.00),
    (-19.50, 27.45, -257.50), (-25.50, 29.55, -268.00),
    (-25.50, 31.95, -279.50), (-24.00, 34.00, -288.00),
)
PINECREST_WIDTH = 5.20
PINECREST_DECK = (-24.00, 34.00, -292.10)


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
        railing([*handrail, (dx-side*2.50, dy, front), (boundary, dy, front),
                 (boundary, dy, back), (dx, dy, back)])

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
