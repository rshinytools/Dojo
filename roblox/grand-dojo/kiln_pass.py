"""Raised trail from the west bend on Kiln Ridge to Wind Rest."""

from math import atan2, ceil, cos, degrees, hypot, radians, sin


NAME = "Kiln Pass"
WIDTH = 5.20
KILN_OPENING = (-120.80, -115.43)
WIND_OPENING = (-145.10, -139.90)
POINTS = (
    (96.35, 5.38, -118.10),
    (93.32, 5.48, -118.10),
    (89.00, 6.85, -116.80),
    (83.00, 8.60, -118.00),
    (73.00, 10.60, -122.00),
    (67.00, 12.10, -127.20),
    (64.30, 11.10, -131.10),
    (65.00, 9.55, -136.40),
    (62.80, 8.12, -141.92),
    (59.30, 7.46, -142.50),
    (54.50, 7.46, -142.50),
)


def rail_outside_opening(a, b, opening):
    """Clip a longitudinal rail to the portions outside a walkway mouth."""
    low, high = opening
    if max(a[2], b[2]) <= low or min(a[2], b[2]) >= high:
        return ((a, b),)
    if a[2] > b[2]:
        a, b = b, a

    def at(z):
        t = (z - a[2]) / (b[2] - a[2])
        return tuple(x + (y - x) * t for x, y in zip(a, b))

    segments = []
    if a[2] < low:
        segments.append((a, at(low)))
    if b[2] > high:
        segments.append((at(high), b))
    return segments


def build_kiln_pass(parent, *, item, prop, part, beam, triangle, path_edge, sign,
                    festival_lantern, garden_shelf, garden_prop, sandstone, slate,
                    cedar, metal, grass, stone_variant, variant_field):
    walk = item(parent,"Model",NAME)
    prop(walk,"token","ModelStreamingMode",1)
    prop(walk,"token","LevelOfDetail",4)

    def cross_grade(chain):
        # Match the original Kiln Ridge slope at the first two cross sections.
        return [(x,y+(z-POINTS[0][2])*grade,z)
                for (x,y,z),grade in zip(chain,(-.26,-.18)+(0,)*(len(POINTS)-2))]

    colored = ("AF8D7B","AA9287","B59E90","A79B92")
    left,right = (cross_grade(path_edge(POINTS,d)) for d in (-WIDTH/2,WIDTH/2))
    for index,((a,d),(b,c)) in enumerate(zip(zip(left,left[1:]),zip(right,right[1:]))):
        before = len(walk)
        a,b,c,d = ((x,y-.16,z) for x,y,z in (a,b,c,d))
        triangle(walk,a,b,c,colored[index%4],name="Kiln Pass paving",material=sandstone,
                 thickness=.34,collide=True,shadow=False)
        triangle(walk,a,c,d,colored[(index+1)%4],name="Kiln Pass paving",material=sandstone,
                 thickness=.34,collide=True,shadow=False)
        for piece in list(walk)[before:]:
            prop(piece,"string",variant_field,stone_variant)

    def guard(a,b):
        for lift,size in ((.53,.18),(1.40,.23)):
            beam(walk,"Kiln Pass cedar guard",(a[0],a[1]+lift,a[2]),(b[0],b[1]+lift,b[2]),
                 size,"835950",collide=True)
        beam(walk,"Kiln Pass stone rim",(a[0],a[1]-.38,a[2]),(b[0],b[1]-.38,b[2]),
             .36,"8E7B79")
        count=max(1,ceil(hypot(b[0]-a[0],b[2]-a[2])/3.0))
        for index in range(count):
            t=(index+.50)/count
            x,y,z=(u+(v-u)*t for u,v in zip(a,b))
            part(walk,"Kiln Pass newel",(x,y+.70,z),(.30,1.47,.32),"795044",
                 material=cedar,collide=False)
            part(walk,"Brass ridge cap",(x,y+1.45,z),(.40,.12,.43),"BC9361",
                 material=metal,collide=False)

    edges = [cross_grade(path_edge(POINTS,d)) for d in (-2.44,2.44)]
    for edge in edges:
        for a,b in zip(edge[1:-2],edge[2:-1]):
            guard(a,b)
    for index in (1,3,4,6,8):
        a,b=POINTS[index:index+2]
        x,y,z=((u+v)*.5 for u,v in zip(a,b))
        base=-5.1
        capital_y=y-(1.08 if index==1 else .91)
        bearing_top=capital_y-.12
        half=(bearing_top+base)/2
        yaw=degrees(atan2(b[0]-a[0],b[2]-a[2]))
        part(walk,"Ridge stone bearing",(x,half,z),(2.80,bearing_top-base,2.26),"826D75",
             yaw=yaw,material=slate,collide=False)
        part(walk,"Cut stone bridge capital",(x,capital_y,z),(4.09,.50,2.70),"A18C8C",
             yaw=yaw,material=sandstone,collide=False)
        for row in range(3):
            layer=base+(row+1)*(bearing_top-.22-base)/4
            part(walk,"Stone bearing joint",(x,layer,z),(2.85,.075,2.31),"AA928C",
                 yaw=yaw,material=slate,collide=False)
    for index,(x,y,z,w,d) in enumerate(((89.1,1.45,-121.4,7.3,5.7),(77.9,1.65,-123.7,9.6,6.1),
                                        (70.8,3.25,-130.4,8.9,5.9),(62.7,2.50,-134.4,6.4,4.5))):
        garden_shelf(walk,x,y,z,w,d,y+4.90,"81707A",slate,collide=False)
        garden_shelf(walk,x,y+.08,z,w*.78,d*.76,.31,"7F8D56",grass,collide=False)
        for key,dx,dz,size,tint in (("bankRock",-.65,.42,.25,"9A8390"),
                ("meadowCover",.66,-.38,.22,"9EB573"),("meadowFlowers",.91,.51,.24,"E6B68F")):
            garden_prop(walk,key,(x+dx,y+.06,z+dz),size,17+index*43,tint)

    # A compact cedar gateway marks the crest without taking floor space.
    ax,ay,az=POINTS[5]
    yaw=50
    c,s=cos(radians(yaw)),sin(radians(yaw))

    def gate_point(dx,dy,dz=0):
        return ax+dx*c+dz*s,ay+dy,az-dx*s+dz*c

    for offset in (-2.93,2.93):
        part(walk,"Ridge gate slate shoe",gate_point(offset,.26),(.63,.52,.67),
             "887580",yaw=yaw,material=slate,collide=False)
        part(walk,"Ridge gate vermilion cedar",gate_point(offset,3.14),(.55,5.38,.55),
             "8C4F3F",yaw=yaw,material=cedar,collide=False)
        festival_lantern(walk,*gate_point(offset,5.44,.18),.50,light=False)
    for lift,width,height,tint in ((6.04,6.61,.48,"8B4839"),(6.43,7.11,.39,"354B78"),
                                   (6.65,7.54,.095,"C2955D")):
        part(walk,"Layered ridge gate lintel",gate_point(0,lift),(width,height,1.12),
             tint,yaw=yaw,material=cedar,collide=False)
    sign(walk,"KILN PASS",*gate_point(0,6.03,.62),4.4,.79,yaw,"743F3B")
    sign(walk,"KILN PASS",*gate_point(0,6.03,-.62),4.4,.79,yaw+180,"743F3B")

    for label,x,y,z,heading in (
        ("WIND REST",92.55,5.70,-121.22,0),
        ("KILN RIDGE",58.19,7.45,-139.38,180),
    ):
        part(walk,"Pass wayfinding post",(x,y+1.20,z),(.26,2.44,.27),"735247",
             material=cedar,collide=False)
        sign(walk,label,x,y+2.16,z,4.2,.84,heading,"5E515E")
