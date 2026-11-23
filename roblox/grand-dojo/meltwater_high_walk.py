"""The raised walk from Upper Lantern Market to Frostglass Gardens."""

from math import ceil, dist


NAME = "Meltwater High Walk"
WIDTH = 6.00
MARKET_OPENING = (-8.75, -2.55)
POINTS = (
    (-250.00,13.27,-5.65), (-252.80,13.27,-5.65), (-257.70,14.01,-7.60),
    (-260.00,15.38,-14.15), (-260.00,17.30,-26.40), (-259.80,19.50,-42.65),
    (-254.30,20.10,-59.40), (-249.60,20.10,-71.40), (-248.00,20.10,-88.60),
    (-247.40,20.10,-103.00), (-245.50,19.75,-115.20), (-243.00,18.05,-130.00),
    (-232.50,16.05,-144.70), (-224.00,14.027,-150.50),
    (-218.70,14.027,-150.50), (-212.00,14.027,-150.50),
)


def build_meltwater_high_walk(parent, *, item, prop, part, beam, triangle, path_edge,
                              sign, swept_roof, festival_lantern, garden_shelf, garden_prop,
                              showcase_tree, limestone, slate, cedar, brass, grass,
                              stone_variant, variant_field):
    walk = item(parent, "Model", NAME)
    prop(walk, "token", "ModelStreamingMode", 1)
    prop(walk, "token", "LevelOfDetail", 4)
    left,right = (path_edge(POINTS, side * WIDTH * .5) for side in (-1, 1))

    for index,(a,b,c,d) in enumerate(zip(left,left[1:],right[1:],right)):
        ring = tuple((x,y-.19,z) for x,y,z in (a,b,c,d))
        start = len(walk)
        for corners,tint in (((0,1,2),"AEA1A7"),((0,2,3),"B6A5A7")):
            triangle(walk, *(ring[i] for i in corners), tint, name="High Walk limestone deck",
                     thickness=.38, material=limestone, collide=True, shadow=False)
        for stone in walk[start:]:
            prop(stone,"string",variant_field,stone_variant)

    def lift(point,height):
        return point[0],point[1]+height,point[2]

    def along(a,b,t):
        return tuple(u+(v-u)*t for u,v in zip(a,b))

    def at_z(a,b,z):
        return along(a,b,(z-a[2])/(b[2]-a[2]))

    def guard(a,b,*,posts=True):
        for height,width,tint in ((.57,.20,"695164"),(1.47,.24,"926475")):
            beam(walk,"High Walk lacquered guard",lift(a,height),lift(b,height),width,tint,collide=True)
        if posts:
            count=max(1,ceil(dist(a,b)/4.1))
            for i in range(count):
                point=along(a,b,(i+.5)/count)
                part(walk,"High Walk square newel",lift(point,.75),(.32,1.55,.33),
                     "784F64",material=cedar,collide=False)
                part(walk,"High Walk newel brass cap",lift(point,1.54),(.42,.14,.43),
                     "C8996D",material=brass,collide=False)

    near,far,top = -77.60,-87.35,20.10
    bay_west,bay_east = -246.28,-239.56
    east_edge=path_edge(POINTS,-WIDTH*.5+.13)
    near_join=at_z(*east_edge[7:9],near)
    far_join=at_z(*east_edge[7:9],far)
    for side in (-1,1):
        path=path_edge(POINTS,side*(WIDTH*.5-.13))
        for index,(a,b) in enumerate(zip(path,path[1:])):
            if index==len(path)-2:
                continue
            if index==0:
                a=(-251.95,a[1],a[2])
            beam(walk,"High Walk dressed fascia",lift(a,-.34),lift(b,-.34),
                 .43,"877883")
            if side==1 and index==1:
                continue  # Lantern Skyline Walk closes this opening with its own fork rails.
            if side==-1 and index==7:
                guard(a,near_join)
                guard(far_join,b)
            else:
                guard(a,b)

    # The creek span crosses above the original water and lower routes.
    # Trestles stand on either bank, with the braced center left open.
    for index,foot_x,foot_z in (
        (3,-263.9,-13.2),(4,-260.5,-27.8),(5,-260.3,-42.7),
        (6,-254.8,-59.4),(7,-250.95,-70.45),(8,-249.4,-91.20),
        (10,-245.6,-115.4),(11,-243.7,-130.9),(12,-234.2,-144.3),
    ):
        deck=POINTS[index]
        foot=-4.92
        head=deck[1]-4.05
        part(walk,"Meltwater slate trestle", (foot_x,(foot+head)*.5,foot_z),
             (2.62,head-foot,2.84),"756A7C",material=slate,collide=False)
        part(walk,"Meltwater dressed capital",(foot_x,head+.10,foot_z),
             (3.66,.52,3.56),"A394A2",material=slate,collide=False)
        for course in (.23,.52,.81):
            part(walk,"Meltwater trestle course",(foot_x,foot+(head-foot)*course,foot_z),
                 (2.82,.20,3.03),"90828E",material=slate,collide=False)
        for dx in (-1.80,1.80):
            beam(walk,"Meltwater timber knee",(foot_x+dx*.36,head+.26,foot_z),
                 (deck[0]+dx,deck[1]-.45,deck[2]),.69,"775160")

    ridge=item(walk,"Model","Meltwater west bank shelves")
    prop(ridge,"token","LevelOfDetail",4)
    for i,(x,z,y,w,d) in enumerate((
        (-274.6,-23.0,12.3,20.1,18.4),(-276.0,-43.3,15.4,23.0,22.8),
        (-271.1,-61.4,12.6,21.6,18.1),(-267.1,-82.3,16.15,24.2,22.3),
        (-265.4,-101.5,12.85,21.1,20.1),(-256.3,-126.0,9.55,19.2,16.8),
    )):
        for rise,spread,tint in ((.49,1,"756B78"),(.81,.86,"877B88"),(1,.71,"9D8A93")):
            upper=y*rise
            garden_shelf(ridge,x-(1-rise)*2.6,upper,z,w*spread,d*spread,
                         upper+4.9,tint,slate,collide=False)
        garden_shelf(ridge,x-.83,y+.09,z-.23,w*.62,d*.64,.28,"73815E",grass,collide=False)
        showcase_tree(ridge,x-2.45,z-.6,i in (1,4),.65+i%2*.12,19+i*47,y+.08,
                      compact=i!=3)
        for dx,dz in ((-.1,1.3),(3.10,-2.2)):
            garden_prop(ridge,"meadowCover",(x+dx,y+.15,z+dz),.24,19+i*41,"A4AE71")
            garden_prop(ridge,"mossFlowers",(x+dx+.44,y+.15,z+dz+.58),.19,33+i*41,"DCAAC9")

    skyline=item(walk,"Model","Meltwater western ridge")
    prop(skyline,"token","LevelOfDetail",4)
    crest=((-308,-1,15),(-308,17,-7),(-311,27,-28),(-318,34,-43),
           (-313,29,-58),(-320,42,-77),(-314,36,-91),(-317,39,-110),
           (-308,27,-126),(-309,30,-145),(-305,17,-167),(-306,-1,-187))
    for direction in (-1,1):
        bands=[]
        for shift,relief in ((0,1),(.32,.77),(.68,.39),(1,0)):
            bands.append(tuple(
                (x+direction*shift*(34+(index%3)*2),-4.85+(y+4.85)*relief,z+(index%3-1)*2.8*shift)
                for index,(x,y,z) in enumerate(crest)
            ))
        for layer,(upper,lower) in enumerate(zip(bands,bands[1:])):
            palette=(("80728C","887B95","8C7E97"),("84798D","8B8090","877D88"),
                     ("768071","808876","859077"))[layer]
            for index,(a,b,c,d) in enumerate(zip(upper,upper[1:],lower,lower[1:])):
                for face in ((a,b,c),(b,d,c)):
                    triangle(skyline,*face,palette[index%3],name="Meltwater hillside facet",
                             material=slate,thickness=.16,shadow=False)

    terrace=item(walk,"Model","Meltwater shelter balcony")
    cx,cz=(bay_west+bay_east)*.5,(near+far)*.5
    part(terrace,"Meltwater balcony limestone floor",(cx,top-.24,cz),
         (bay_east-bay_west,.48,near-far),"B9A7A7",material=limestone)
    for a,b in (
        (near_join,(bay_east-.12,top,near)),
        ((bay_east-.12,top,near),(bay_east-.12,top,far)),
        ((bay_east-.12,top,far),far_join),
    ):
        guard(a,b)
    for z in (near+.18,far-.18):
        beam(terrace,"Balcony slate bearer",(bay_west,top-.63,z),(bay_east,top-.63,z),
             .65,"8B7788")
        beam(terrace,"Balcony cedar cantilever",(bay_west-.9,top-3.5,z),(bay_east-.8,top-.65,z),
             .66,"775161")
    for z in (near-.51,far+.51):
        for x in (bay_west+1.38,bay_east-.64):
            part(terrace,"Cedar shelter footing",(x,top+.22,z),(.87,.44,.87),
                 "988591",material=slate,collide=False)
            part(terrace,"Shelter plum column",(x,top+3.41,z),(.56,6.66,.56),
                 "8B4F66",material=cedar,collide=False)
            part(terrace,"Shelter capital collar",(x,top+6.45,z),(.77,.25,.76),
                 "C89468",material=brass,collide=False)
        beam(terrace,"Meltwater shelter lintel",(bay_west+.38,top+6.67,z),
             (bay_east-.32,top+6.67,z),.47,"945E71")
        festival_lantern(terrace,bay_east-1.48,top+5.84,z,.61,light=False,tint="FFCD96")
    swept_roof(terrace,cx,top+6.85,cz,7.75,11.78,2.62,fine_tiles=False,signature=True)
    part(terrace,"Meltwater balcony cedar bench",(bay_east-.82,top+.70,cz),
         (.83,.22,4.20),"9C746B",material=cedar,collide=False)
    for z in (cz-1.52,cz+1.52):
        part(terrace,"Meltwater slate bench shoe",(bay_east-.82,top+.29,z),
             (.61,.58,.48),"9F8C99",material=slate,collide=False)
    sign(terrace,"MELTWATER OVERLOOK",cx,top+6.36,near-.23,5.70,.94,tint="6E4A60")

    for x,y,z,yaw,caption in (
        (-252.20,13.27,-5.65,90,"FROSTGLASS HIGH WALK"),
        (-219.05,14.027,-150.50,90,"LANTERN CIRCUIT HIGH WALK"),
    ):
        part(walk,"High Walk route lintel",(x,y+5.88,z),(.54,.41,6.48),
             "8F5971",material=cedar,collide=False)
        for offset in (-3.18,3.18):
            part(walk,"High Walk gateway plinth",(x,y+.25,z+offset),(.80,.50,.78),
                 "A18D97",material=slate,collide=False)
            part(walk,"High Walk gateway post",(x,y+2.99,z+offset),(.40,5.74,.43),
                 "88526B",material=cedar,collide=False)
        sign(walk,caption,x+.34,y+5.59,z,5.97,1.02,yaw,tint="65495F")
