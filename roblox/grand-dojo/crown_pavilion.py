"""A stair-free skyline pavilion above Cascade Lookout."""

from math import hypot

from crown_crossing import CROWN_OPENING


CROWN_ENTRY_Z = -49.62
CROWN_ROUTE_WIDTH = 5.60


def build_crown_pavilion(parent, entry_x, entry_y, *, item, prop, part, beam, route,
                         swept_roof, sign, lamp, garden_prop, slate, cedar, stone,
                         cloth, brass):
    crown = item(parent, "Model", "Reedfall Crown")
    prop(crown, "token", "ModelStreamingMode", 1)
    prop(crown, "token", "LevelOfDetail", 4)

    ramp_x, elbow_y, top = 83.60, 26.0, 34.40
    west, east, north, south = 72.30, 94.90, -91.35, -77.62
    half_width = CROWN_ROUTE_WIDTH / 2
    z = CROWN_ENTRY_Z
    lower_end = ramp_x - 1.55
    upper_start = z - 2.65
    guard_color, stone_tone = "784D43", "A49194"

    def floor(label, x0, x1, z0, z1, height):
        part(crown, label, ((x0+x1)/2, height-.38, (z0+z1)/2),
             (x1-x0, .76, z1-z0), stone_tone, material=stone)

    def rail(a, b):
        for lift in (.54, 1.49):
            beam(crown, "Crown cedar guard", (a[0],a[1]+lift,a[2]),
                 (b[0],b[1]+lift,b[2]), .24, guard_color, collide=True)
        bays = max(1, round(hypot(b[0]-a[0], b[2]-a[2])/3.25))
        for index in range(bays):
            t = (index+.5)/bays
            x,y,z = (u+(v-u)*t for u,v in zip(a,b))
            part(crown, "Crown square baluster", (x,y+.75,z), (.33,1.5,.33),
                 guard_color, material=cedar, collide=False)
            part(crown, "Crown brass rail cap", (x,y+1.52,z), (.41,.15,.41),
                 "B68958", material=brass, collide=False)

    apron_x = entry_x + 1.30
    w = half_width-.15
    floor("Crown approach landing", entry_x-.35, apron_x+.24, z-half_width,
          z+half_width, entry_y)
    route(crown, "Crown lower ramp", [(apron_x,entry_y,z),(lower_end,elbow_y,z)],
          CROWN_ROUTE_WIDTH, stone_tone, surface=stone, stone_footings=False,
          join_overlap=.12, railings=False)
    floor("Crown turning landing", lower_end-.12, ramp_x+half_width+.20,
          upper_start-.16, z+half_width, elbow_y)
    # The elbow overlaps the inside of the first ramp by the width of its uphill landing.
    floor("Crown inner landing", ramp_x-half_width, lower_end+.10,
          upper_start-.16, z-w+.12, elbow_y)
    route(crown, "Crown upper ramp", [(ramp_x,elbow_y,upper_start),(ramp_x,top,south+.17)],
          CROWN_ROUTE_WIDTH, stone_tone, surface=stone, stone_footings=False,
          join_overlap=.16, railings=False)
    floor("Crown pavilion deck", west, east, north, south+.27, top)

    for side in (-1,1):
        rail((entry_x-.24,entry_y,z+side*w),(apron_x,entry_y,z+side*w))
        inner_end = ramp_x-w if side == -1 else lower_end
        edge_y = entry_y+(elbow_y-entry_y)*(inner_end-apron_x)/(lower_end-apron_x)
        rail((apron_x,entry_y,z+side*w),(inner_end,edge_y,z+side*w))
        rail((ramp_x+side*w,elbow_y,upper_start),(ramp_x+side*w,top,south+.17))
    for a,b in (
        ((lower_end,elbow_y,z+w),(ramp_x+w,elbow_y,z+w)),
        ((ramp_x+w,elbow_y,z+w),(ramp_x+w,elbow_y,upper_start)),
        ((west+.23,top,south),(ramp_x-w,top,south)),
        ((ramp_x+w,top,south),(east-.23,top,south)),
        ((west+.23,top,north+.22),(west+.23,top,south)),
        ((east-.23,top,north+.22),(east-.23,top,CROWN_OPENING[0])),
        ((east-.23,top,CROWN_OPENING[1]),(east-.23,top,south)),
        ((west+.23,top,north+.22),(east-.23,top,north+.22)),
    ):
        rail(a,b)

    # Structural dressing stays clear of the lower Cinder approaches.
    for x,y,pier_z in ((74.9,23.44,-49.62),(83.70,elbow_y,-52.30),
                       (89.20,25.70,-61.0),(73.90,top,-79.70),(79.20,top,-79.80),
                       (75.60,top,-82.0),(87.50,top,-89.50)):
        part(crown, "Raised slate pier", (x,(y-1.0)/2,pier_z), (1.52,y-1.0,1.57),
             "817585", material=slate, collide=False)
        part(crown, "Terraced stone capital", (x,y-1.05,pier_z), (2.3,.64,2.31),
             "A18B88", material=slate, collide=False)
    beam(crown, "Raised cedar brace", (89.20,24.1,-61.0),(83.60,28.02,-61.0),
         .68,"80594D")
    for z in (north+.30, south-.07):
        part(crown, "Crown cedar deck fascia", ((west+east)/2,top-.46,z),
             (east-west,.45,.28), "714E4B", material=cedar, collide=False)

    cx, cz, eave = 84.25, -85.65, 45.45
    for x in (cx-6.82,cx+6.82):
        for z in (cz-3.78,cz+3.55):
            part(crown, "Pavilion slate column shoe", (x,top+.38,z), (1.39,.76,1.39),
                 "988391", material=slate)
            part(crown, "Pavilion cedar column", (x,(top+eave)/2,z), (1.02,eave-top,1.02),
                 "8A5147", material=cedar)
            for y, width in ((top+.82,1.16),(eave-.76,1.32),(eave-.46,1.65)):
                part(crown, "Pavilion column collar", (x,y,z), (width,.25,width),
                     "B18956", material=brass, collide=False)
        part(crown, "Pavilion dark side beam", (x,eave-.36,cz), (1.10,.80,8.0),
             "654049", material=cedar, collide=False)
        lamp(crown,x,eave-3.0,cz+3.27,scale=.89)
        part(crown, "Pavilion banner", (x,38.35,cz+3.66), (1.27,3.15,.12),
             "833F47", material=cloth, collide=False)
        part(crown, "Pavilion banner hem", (x,36.81,cz+3.74), (1.27,.13,.13),
             "B68A56", material=cloth, collide=False)
    part(crown, "Pavilion front beam", (cx,eave-.59,cz+3.55), (15.5,.92,.86),
         "71464B", material=cedar, collide=False)
    part(crown, "Pavilion coffered ceiling", (cx,eave-.32,cz), (15.24,.36,8.18),
         "795950", material=cedar)
    swept_roof(crown,cx,eave,cz,19.0,10.55,4.30,fine_tiles=False,corner_sweep=1.24)

    upper_eave = 61.35
    part(crown, "Upper pavilion sealed timber frame", (cx,54.80,cz), (13.9,13.1,6.08),
         "764A4D", material=cedar, collide=False)
    for z in (cz-3.10,cz+3.10):
        facing = 1 if z > cz else -1
        for y in (51.1,54.9,59.9):
            part(crown, "Upper timber frieze", (cx,y,z), (14.05,.45,.25),
                 "805052", material=cedar, collide=False)
        for x in (cx-6.78,cx-2.08,cx+2.08,cx+6.78):
            part(crown, "Upper frame pilaster", (x,57.71,z), (.36,4.40,.36),
                 "956459", material=cedar, collide=False)
        for x in (cx-3.97,cx,cx+3.97):
            part(crown, "Upper shutter sill", (x,56.03,z), (3.16,.24,.28),
                 "AF7E62", material=cedar, collide=False)
            part(crown, "Upper pavilion paper shutter", (x,57.34,z), (2.87,2.46,.14),
                 "D5B391", material=cloth, collide=False)
            for offset in (-.88,-.44,0,.44,.88):
                part(crown, "Upper shutter mullion", (x+offset,57.34,z+facing*.09),
                     (.09,2.49,.14), "825B50", material=cedar, collide=False)
    swept_roof(crown,cx,upper_eave,cz,17.3,9.23,4.75,fine_tiles=False,corner_sweep=1.29)
    sign(crown,"REEDFALL CROWN",cx,eave-1.10,cz+4.07,10.45,1.16,tint="603E44")
    part(crown, "Crown route sign post", (entry_x-.52,entry_y+1.06,CROWN_ENTRY_Z+3.31),
         (.28,2.12,.29), guard_color, material=cedar, collide=False)
    sign(crown,"REEDFALL CROWN  ↑",entry_x-.75,entry_y+2.36,CROWN_ENTRY_Z+3.31,
         4.42,.87,yaw=-90,tint="684C4B")
    return_sign_x = 89.25
    part(crown, "Crown return sign bracket", (return_sign_x,top+1.49,south+.29),
         (.44,.22,.72), guard_color, material=cedar, collide=False)
    sign(crown,"CASCADE LOOKOUT  ↓",return_sign_x,top+1.49,south+.55,5.0,.87,
         yaw=180,tint="385D55")

    for x in (78.05,90.47):
        seat = part(crown, "Crown viewing seat", (x,top+.50,south-1.51), (2.71,.21,.74),
                    "A97859", material=cedar, class_name="Seat", yaw=180)
        seat.find("Properties/bool[@name='CanTouch']").text = "true"
        part(crown, "Crown bench back", (x,top+.91,south-1.94), (2.71,.59,.18),
             "855A4B", material=cedar, collide=False)
        for offset in (-.94,.94):
            part(crown, "Crown bench leg", (x+offset,top+.21,south-1.51), (.26,.42,.5),
                 "76574D", material=cedar, collide=False)
    for x,z in ((west+1.22,north+2.0),(east-1.22,north+2.0),
                (west+1.28,south-1.42),(east-1.22,south-1.42)):
        part(crown, "Crown planted slate bowl", (x,top+.31,z), (1.63,.62,1.55),
             "877585", material=slate, collide=False)
        garden_prop(crown,"meadowGrass",(x,top+.57,z),.15,42,"98A16B")
        garden_prop(crown,"mossFlowers",(x+.16,top+.63,z+.12),.115,-24,"D5A6B2")
