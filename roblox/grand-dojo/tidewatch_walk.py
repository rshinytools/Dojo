"""An upper waterfront connection from Beacon Terrace to the Cinder road."""
from math import atan2, ceil, degrees, dist, hypot


NAME = "Tidewatch Walk"
WIDTH = 5.20
DECK_HEIGHT = 15.60
BEACON_OPENING = (291.88, 297.32)
CINDER_OPENING = (-28.64, -23.36)
KEEPER = (272.18, DECK_HEIGHT, -13.80)
PATH = (
    (294.60, 11.028, 8.30), (294.60, 11.028, 6.46),
    (295.20, 12.60, -.70), (287.80, 14.80, -11.60),
    (278.50, DECK_HEIGHT, -18.0), (268, DECK_HEIGHT, -21.0),
    (254, 13.40, -23), (240, 10.50, -25), (226, 7.0, -26),
    (214, 3.114, -26), (210.90, 3.115, -26),
)


def build_tidewatch_walk(parent, *, item, prop, part, beam, triangle, path_edge, sign,
                         swept_roof, festival_lantern, shoreline_slate, garden_shelf,
                         garden_prop, showcase_tree, slate, limestone, cedar, grass,
                         brass, paving_variant, cedar_variant, variant_field):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)

    def trail_piece(name, position, size, tint, material, **pose):
        return part(walk, name, position, size, tint, material=material, **pose)

    first = len(walk)
    left, right = (path_edge(PATH, offset) for offset in (-WIDTH/2, WIDTH/2))
    for i, ((left_a,left_b),(right_a,right_b)) in enumerate(zip(zip(left,left[1:]),zip(right,right[1:]))):
        a,b,c,d = ((x,y-.149,z) for x,y,z in (left_a,right_a,right_b,left_b))
        timber = i<6
        material = cedar if timber else limestone
        for points in ((a,b,c),(a,c,d)):
            triangle(walk, *points, "9E785B" if timber else "AA9994",
                     name="Tidewatch graded deck", material=material, thickness=.30, collide=True)
    for slab in list(walk)[first:]:
        material=slab.findtext("Properties/token[@name='Material']")
        prop(slab, "string", variant_field, cedar_variant if material==str(cedar) else paving_variant)

    def along(a, b, fraction):
        return tuple(start+(finish-start)*fraction for start,finish in zip(a,b))

    # The two walkways meet at the level high span. Keep access open along its south rail.
    sheltera, shelterb = PATH[4:6]
    dx, dz = shelterb[0]-sheltera[0], shelterb[2]-sheltera[2]
    length = hypot(dx,dz)
    yaw = degrees(atan2(dx,dz))

    def bay_point(fraction, offset, lift=0):
        x,y,z=along(sheltera,shelterb,fraction)
        return x+offset*dz/length,y+lift,z-offset*dx/length

    bay=trail_piece("Tidewatch lookout deck",bay_point(.5,5.27,-.202),
                    (5.82,.42,length*.77),"A77C5D",cedar,yaw=yaw)
    prop(bay,"string",variant_field,cedar_variant)
    # Slender transverse joints suggest deck planking without adding raised contact edges.
    for index in range(8):
        cut=trail_piece("Tidewatch lookout board joint",bay_point(.197+index*.088,5.32,.013),
                        (5.66,.009,.030),"795A4F",cedar,yaw=yaw,collide=False)
        prop(cut,"bool","CastShadow",False)

    posts=set()
    def rail(a,b):
        for lift,width in ((.57,.18),(1.42,.24)):
            beam(walk,"Tidewatch teal guardrail",(a[0],a[1]+lift,a[2]),(b[0],b[1]+lift,b[2]),
                 width,"426F71",collide=True)
        count=ceil(dist(a,b)/4.4)
        for j in range(count+1):
            position=tuple(round(v,4) for v in along(a,b,j/count))
            if position in posts:
                continue
            posts.add(position)
            x,y,z=position
            trail_piece("Tidewatch rail newel",(x,y+.74,z),(.33,1.49,.35),"477371",cedar)
            trail_piece("Tidewatch brass railing cap",(x,y+1.49,z),(.46,.13,.43),"C59C61",brass,collide=False)

    for side in (-1,1):
        shoulder=path_edge(PATH,side*2.44)
        for i,(a,b) in enumerate(zip(shoulder,shoulder[1:])):
            beam(walk,"Tidewatch cedar fascia",(a[0],a[1]-.32,a[2]),(b[0],b[1]-.32,b[2]),
                 .35,"6B524B")
            if i==4 and side>0:
                rail(a,bay_point(.12,2.44))
                rail(bay_point(.88,2.44),b)
            elif i < len(PATH)-2:
                rail(a,b)
            else:
                # The road edge crosses the end of the deck diagonally.
                road_edge=212.86+(b[2]+26)*(15/62)
                rail(a,(road_edge,b[1],b[2]))
    for fraction in (.12,.88):
        rail(bay_point(fraction,2.44),bay_point(fraction,7.96))
    rail(bay_point(.12,7.96),bay_point(.88,7.96))

    for i in range(1,len(PATH)-2):
        a,b=PATH[i:i+2]
        x,y,z=along(a,b,.5)
        foot=-4.5
        height=y-foot-.88
        for offset in (-1.71,1.71):
            span=hypot(b[0]-a[0],b[2]-a[2])
            px=x+(b[2]-a[2])*offset/span
            pz=z-(b[0]-a[0])*offset/span
            trail_piece("Tidewatch slate pier",(px,foot+height/2,pz),
                        (1.40,height,1.43),"827982",slate,collide=False)
            trail_piece("Tidewatch slate pier capital",(px,y-.93,pz),
                        (1.86,.46,1.79),"A39191",slate,collide=False)
        tilt=degrees(atan2(b[0]-a[0],b[2]-a[2]))
        trail_piece("Tidewatch cedar crosshead",(x,y-.57,z),(4.80,.47,1.23),
                    "735C52",cedar,yaw=tilt,collide=False)

    for fraction in (.23,.77):
        x,y,z=bay_point(fraction,7.24)
        height=y+3.65
        trail_piece("Lookout bay footing",(x,(y-4.5)/2-.36,z),(1.62,height,1.72),
                    "827983",slate,collide=False)
    for fraction in (.21,.79):
        for offset in (4.68,7.39):
            x,y,z=bay_point(fraction,offset)
            trail_piece("Tidewatch pavilion stone shoe",(x,y+.22,z),(.76,.44,.74),"A49187",slate)
            trail_piece("Tidewatch pavilion cedar post",(x,y+3.08,z),(.49,5.82,.51),"477475",cedar)
        festival_lantern(walk,*bay_point(fraction,4.49,5.15),.56,light=False)
    cx,_,cz=bay_point(.5,6.0)
    swept_roof(walk,cx,DECK_HEIGHT+6.11,cz,7.56,5.26,2.31,fine_tiles=False)
    sign(walk,"TIDEWATCH WALK",cx,DECK_HEIGHT+5.53,cz+2.55,5.94,.91,0,"376D70")
    for fraction in (.34,.62):
        x,y,z=bay_point(fraction,7.25)
        trail_piece("Tidewatch bench foot",(x,y+.32,z),(.58,.64,.61),"91838B",slate)
    x,y,z=bay_point(.48,7.25)
    trail_piece("Tidewatch cedar bench",(x,y+.63,z),(.84,.22,3.39),"AD795A",cedar,
                yaw=yaw,collide=False)

    for i, (x,z,top,width,depth,yaw) in enumerate((
        (284.1,-4.95,4.45,7.3,7.7,39), (275.65,-11.65,7.37,8.3,6.3,65),
        (256.40,-16.90,8.93,8.9,7.25,78), (241.80,-18.1,6.10,7.45,6.2,31),
    )):
        shoreline_slate(walk,x,z,-4.85,width,depth,top+4.85,yaw,shadow=False)
        garden_shelf(walk,x,top-.18,z,width*.53,depth*.49,.34,
                     "718958",grass,collide=False)
        for key,ox,oz,scale,tint in (
            ("bankRock",-.66,.55,.18,"9A898C"),("meadowCover",.45,.83,.17,"A6BA74"),
            ("mossFlowers",.59,-.54,.16,"D7A8BB"),("meadowFlowers",-.80,-.59,.28,"ECD0A3"),
        ):
            garden_prop(walk,key,(x+ox,top-.18,z+oz),scale,yaw+i*23,tint)
    showcase_tree(walk,275.65,-11.65,False,.63,41,7.15,compact=True)
    showcase_tree(walk,256.4,-16.90,True,.57,71,8.71,compact=True)

    for x,y,z,yaw,label in (
        (298.13,11,12.80,-79,"TIDEWATCH WALK"),
        (218.35,3.38,-31.85,-91,"TIDEWATCH WALK"),
        (268.80,15.58,-23.83,0,"CINDER ROAD  →"),
    ):
        trail_piece("Tidewatch wayfinding post",(x,y+1.47,z),(.36,2.94,.37),"6F5345",cedar,collide=False)
        sign(walk,label,x,y+2.78,z,5.63,1.02,yaw,"376D70")
    trail_piece("Road wayfinding slate support",(218.35,-.71,-31.85),(.60,8.18,.72),
                "827780",slate,collide=False)
    beam(walk,"High wayfinding cedar brace",(268.80,15.56,-23.83),(268.80,15.12,-22.10),
         .26,"6F5345")
    for i in (2,4,6,8):
        x,y,z=path_edge(PATH,-2.44)[i]
        festival_lantern(walk,x,y+1.99,z,.55,light=False)

    bounds = item(walk, "Folder", "Tidewatch location bounds")
    for a, b in zip(PATH[:-2], PATH[1:-1]):
        dx, dy, dz = (end-start for start, end in zip(a, b))
        x, y, z = along(a, b, .5)
        part(bounds, "Tidewatch location volume", (x, y+3.65, z),
             (WIDTH, 6.2, dist(a,b)+.40), "FFFFFF", material=limestone,
             yaw=degrees(atan2(dx,dz)), pitch=-degrees(atan2(dy,hypot(dx,dz))),
             collide=False, transparency=1)
