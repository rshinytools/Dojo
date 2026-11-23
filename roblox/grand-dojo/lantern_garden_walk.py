"""A terraced approach from the festival plaza to Garden Lookout."""

from math import hypot


PATH = (
    (-33.75,.19,53.60), (-37.70,.23,57.60), (-43.30,1.28,61.10),
    (-49.25,2.63,63.60), (-55.00,3.37,61.90), (-59.65,3.34,57.10),
    (-61.20,2.42,51.30), (-62.00,2.39,45.90),
)
WIDTH = 5.05
COURT = (-55.43,-46.27,65.62,74.62,2.70)
GARDENER = (-52.75,COURT[-1],71.84)


def build_lantern_garden_walk(parent, *, item, prop, part, triangle, beam, route, path_edge, sign,
                              festival_lantern, garden_shelf, garden_prop, showcase_tree,
                              stone, cedar, grass, slate, metal, flagstone_variant, variant_field):
    garden = item(parent,"Model","Lantern Garden Walk")
    prop(garden,"token","ModelStreamingMode",1)
    prop(garden,"token","LevelOfDetail",4)
    street = item(garden,"Model","Lantern garden paths")
    left,right=(path_edge(PATH,side*WIDTH/2) for side in (-1,1))

    def between(a,b,t,lift=0):
        return (a[0]+(b[0]-a[0])*t, a[1]+(b[1]-a[1])*t+lift, a[2]+(b[2]-a[2])*t)

    for i,(start,end) in enumerate(zip(PATH,PATH[1:])):
        a,b,c,d=left[i],right[i],left[i+1],right[i+1]
        faces=((a,b,c),(c,d,b))
        for face in faces:
            triangle(street,*face,"938186",name="Lantern garden paved foundation",
                     thickness=.18,material=stone,shadow=False,collide=True)
        courses=max(2,round(hypot(end[0]-start[0],end[2]-start[2])/1.48))
        for section,(p,q,r) in enumerate(faces):
            # Match each decorative course to its own foundation plane at bends.
            for course in range(courses):
                t,u=(course+.018)/courses,(course+.982)/courses
                near_a,near_b=between(p,r,t,.116),between(q,r,t,.116)
                far_a,far_b=between(p,r,u,.116),between(q,r,u,.116)
                tint=("AE9188","B79A8E","A99189","BEA397")[(i+course+section)%4]
                for face in ((near_a,near_b,far_a),(far_a,near_b,far_b)):
                    triangle(street,*face,tint,name="Fitted lantern garden flagstone",
                             thickness=.026,material=stone,shadow=False)
    route(street,"Gardener court approach",((-48.92,2.45,64.20),(-48.92,2.66,66.34)),
          3.84,"B0978D",surface=stone,stone_footings=False,join_overlap=.22,railings=False)
    for slab in street.findall("Item"):
        prop(slab,"string",variant_field,flagstone_variant)

    west,east,north,south,top = COURT
    court = item(garden,"Model","Lantern garden court")
    part(court,"Lantern garden court floor",((west+east)/2,top-.31,(north+south)/2),
         (east-west,.62,south-north),"A88F8B",material=stone)
    # The dressed stair-side faces are shallow, leaving the existing stair intact.
    for row in range(3):
        y=.39+row*.70
        for col in range(5):
            start=west+col*(east-west)/5
            part(court,"Garden court retaining course",(start+(east-west)/10,y,south-.13),
                 ((east-west)/5-.07,.66,.59), ("796C79","8E7982","9E8889")[(row+col)%3],
                 material=slate,collide=False)
    part(court,"Garden court slate footing",((west+east)/2,.98,(north+south)/2),
         (east-west-.22,2.32,south-north-.24),"837582",material=slate,collide=False)
    for x,z,top_y in ((-42.5,61.6,1.26),(-55.2,62.15,3.14),(-59.55,57.3,3.10),
                      (-61.1,51.9,2.35)):
        part(street,"Lantern garden stone bearing",(x,top_y/2-.18,z),
             (2.96,top_y-.20,2.17),"887681",material=slate,collide=False)

    def rail(a,b):
        for lift in (.52,1.34):
            beam(garden,"Lantern garden cedar rail",(a[0],a[1]+lift,a[2]),(b[0],b[1]+lift,b[2]),
                 .21,"8B5042",collide=True)
        bays=max(1,round(hypot(b[0]-a[0],b[2]-a[2])/3.0))
        for index in range(bays):
            t=(index+.5)/bays
            x,y,z=(u+(v-u)*t for u,v in zip(a,b))
            part(garden,"Lantern garden rail post",(x,y+.66,z),(.29,1.36,.29),
                 "7A493D",material=cedar,collide=False)
            part(garden,"Lantern garden brass cap",(x,y+1.36,z),(.40,.13,.40),
                 "BB9059",material=metal,collide=False)

    for side in (-1,1):
        edge=path_edge(PATH,side*2.37)
        for index,(a,b) in enumerate(zip(edge,edge[1:])):
            # Warm paths curve through open garden at the east end. Leave the
            # south side of the bend open to the raised gardener court.
            if index<2 or index==len(edge)-2 or side==1 and index in (2,3):
                continue
            rail(a,b)
    for (ax,az),(bx,bz) in (
        ((west+.20,north+.25),(west+.20,south-.22)),
        ((west+.20,south-.22),(east-.20,south-.22)),
        ((east-.20,south-.22),(east-.20,north+.25)),
        ((west+.20,north+.25),(-51.46,north+.25)),
    ):
        rail((ax,top,az),(bx,top,bz))

    trellis=item(court,"Model","Gardener’s cedar trellis")
    for x in (-54.05,-47.62):
        for z in (70.04,73.56):
            part(trellis,"Trellis slate shoe",(x,top+.35,z),(.84,.70,.83),
                 "99858B",material=slate)
            part(trellis,"Trellis cedar upright",(x,top+2.88,z),(.54,5.07,.55),
                 "96543E",material=cedar)
            part(trellis,"Trellis brass band",(x,top+4.97,z),(.64,.17,.64),
                 "BC874F",material=metal,collide=False)
        part(trellis,"Trellis lengthwise beam",(x,top+5.62,71.80),(.54,.47,4.78),
             "785044",material=cedar,collide=False)
        beam(trellis,"Trellis angled brace",(x,top+4.37,70.18),(x,top+5.54,71.67),.31,"955E46")
        festival_lantern(trellis,x,top+4.62,71.66,.52,light=False)
    for z in (69.82,71.8,73.78):
        part(trellis,"Trellis cedar girder",(-50.84,top+5.79,z),(7.66,.37,.48),
             "966346",material=cedar,collide=False)
    for i in range(7):
        x=-54.31+i*1.15
        part(trellis,"Trellis indigo-ended rafter",(x,top+6.01,71.8),(.23,.24,5.04),
             "564C63",material=cedar,collide=False)
    # The court sign is above the approach and carries no blocking geometry.
    sign(trellis,"LANTERN GARDEN",-50.84,top+5.85,69.64,5.32,1.0,yaw=180,tint="65443D")

    terraces=item(garden,"Folder","Lantern garden planted terraces")
    tiers=(
        (-36.9,65.0,7.9,8.1,.68,23),(-43.8,71.4,11.0,12.3,1.40,41),
        (-44.8,71.9,8.6,9.7,2.02,51),(-58.7,68.20,7.8,10.2,2.05,80),
        (-59.7,68.65,6.1,7.1,3.34,63),(-65.4,62.4,7.2,8.7,1.53,123),
        (-58.1,76.6,10.4,5.7,.82,96),(-38.6,77.6,9.2,5.5,.55,53),
    )
    for index,(x,z,width,depth,height,yaw) in enumerate(tiers):
        shelf=height-(.53 if index in (2,4) else 0)
        garden_shelf(terraces,x,shelf,z,width,depth,shelf+.24,"746674",slate,collide=False)
        garden_shelf(terraces,x-.15,height,z+.09,width-.29,depth-.41,.68,
                     ("98838A","9C8589","897986")[index%3],slate,collide=False)
        garden_shelf(terraces,x-.29,height+.16,z-.04,width-.85,depth-.88,.24,
                     ("748251","718050","818659")[index%3],grass,collide=False)
        for key,dx,dz,scale,tint in (
            ("bankRock",-.24,.29,.22,"98828B"), ("mossFlowers",-.15,-.13,.17,"D9A3AC"),
            ("meadowCover",.18,-.22,.20,"91A063"), ("meadowGrass",.10,.18,.20,"ADB16F"),
        ):
            garden_prop(terraces,key,(x+width*dx,height+.11,z+depth*dz),scale,yaw,tint)
    for x,z,pink,scale,yaw,y in ((-58.95,68.82,False,.81,61,3.50),
                                (-44.98,72.38,True,.65,121,2.18),
                                (-65.3,62.40,False,.55,21,1.69)):
        showcase_tree(terraces,x,z,pink,scale,yaw,y,height_scale=1.07,compact=True)

    for x,y,z,label,yaw in ((-39.15,.2,54.10,"LANTERN GARDEN",35),
                           (-56.0,.15,49.60,"GARDEN LOOKOUT",-13)):
        post=part(garden,"Lantern garden wayfinding post",(x,y+1.03,z),(.29,2.06,.29),
                  "8B5545",material=cedar,collide=False)
        plaque=sign(garden,label,x,y+2.11,z+.15,4.7,.86,yaw=yaw,tint="576846")
        for detail in (post,plaque):
            prop(detail,"bool","CastShadow",False)
    for x,y,z in ((-39.55,.65,62.55),(-54.81,top,73.75),(-58.25,2.42,46.25)):
        part(garden,"Garden lantern stone plinth",(x,y+.33,z),(.79,.66,.79),
             "887786",material=slate,collide=False)
        festival_lantern(garden,x,y+1.04,z,.47,light=False)
