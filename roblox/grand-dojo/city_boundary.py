"""Open southern entrance and stepped perimeter for Grand Dojo City."""
from math import atan2, degrees, hypot


GATE_X = 2.6
GATE_Z = 92.4
SOUTH_GATE_APPROACH = (
    (GATE_X, .15, 81.7),
    (GATE_X, .15, 90),
    (GATE_X, .15, 96),
    (GATE_X, .55, 103.7),
)

# The side returns frame the path and follow the outer garden edge.
WALL_SEGMENTS = (
    ((-85, 80.5), (-77, 86.4), (-67, 90.0), (-54, 91.0),
     (-41, 91.4), (-28, 92.2), (-17, 92.4), (-6.24, 92.4)),
    ((11.44, 92.4), (22, 92.4), (34, 92.2), (46, 91.4),
     (59, 91.0), (71, 89.6), (81, 85.9), (89, 80.5)),
)


def build_south_boundary(parent, *, item, prop, part, beam, route, swept_roof,
                         festival_lantern, sign, garden_shelf, garden_prop,
                         slate, wood, limestone, grass, tree=None):
    """Add the city edge, open gate and an exterior loop off the spawn paving."""
    boundary = item(parent, "Model", "South City Boundary")
    gate = item(boundary, "Model", "Grand Dojo South Gate")
    prop(gate, "token", "ModelStreamingMode", 1)
    prop(gate, "token", "LevelOfDetail", 4)
    apron = item(boundary, "Model", "South Gate Garden Court")
    prop(apron, "token", "ModelStreamingMode", 1)

    def slab(parent, name, x, y, z, width, height, length, tint, material, *, yaw=0, collide=False):
        return part(parent, name, (x,y,z), (width,height,length), tint,
                    yaw=yaw, material=material, collide=collide)

    def wall_pier(parent, x, z, height, width):
        slab(parent,"Wall post footing",x,.33,z,width+.52,1.36,3.1,"837586",slate)
        slab(parent,"Wall post slate block",x,1.75,z,width+.23,1.98,2.77,"978899",slate,collide=True)
        slab(parent,"Wall post brass separator",x,2.78,z,width+.18,.18,2.69,"B78548",wood)
        slab(parent,"Wall post lacquer",x,(height+2.74)/2,z,width,height-2.74,2.38,"AA523A",wood,collide=True)
        slab(parent,"Wall post indigo cap",x,height,z,width+.50,.38,3.16,"34416A",wood)
        slab(parent,"Wall post stone coping",x,height-.28,z,width+.37,.19,2.97,"B3A1A5",slate)

    for side in (-1,1):
        x = GATE_X + side*8.84
        slab(gate,"South gate slate footing",x,.32,GATE_Z,3.44,1.22,4.15,"807184",slate,collide=True)
        slab(gate,"South gate plinth",x,1.32,GATE_Z,2.95,1.17,3.48,"9D8B93",slate,collide=True)
        slab(gate,"South gate plinth cap",x,2.00,GATE_Z,3.16,.28,3.64,"AB959D",slate)
        slab(gate,"South gate pillar",x,6.24,GATE_Z,2.38,8.24,3.02,"A74532",wood,collide=True)
        for face in (-1,1):
            slab(gate,"Vermilion pillar inset",x,6.23,GATE_Z+face*1.54,1.62,7.32,.11,"BD5A3F",wood)
            for edge in (-1,1):
                slab(gate,"Pillar brass inlay",x+edge*.83,6.19,GATE_Z+face*1.61,.062,7.29,.06,"E1A45D",wood)
            for y in (2.66,9.66):
                slab(gate,"Cedar collar",x,y,GATE_Z+face*1.48,2.49,.28,.44,"7C352D",wood)
        for y,w in ((9.85,3.06),(10.23,3.46),(10.58,3.88)):
            slab(gate,"Stacked gate bracket",x,y,GATE_Z,w,.35,w*.82,"984834",wood)
        beam(gate,"South gate brace",(x,8.28,GATE_Z),(x-side*2.64,10.37,GATE_Z),.48,"A6543E")

        # The reclaimed cedar doors sit visibly open along the side walls.
        leaf_x = GATE_X + side*8.84
        leaf_z = GATE_Z + 2.20
        slab(gate,"Open cedar gate leaf",leaf_x,4.45,leaf_z,.55,7.92,3.26,"74392F",wood)
        for y in (1.03,4.42,7.78):
            slab(gate,"Door cross strap",leaf_x-side*.29,y,leaf_z,.12,.20,3.20,"D0A25E",wood)
        for z in (leaf_z-.98,leaf_z-.33,leaf_z+.33,leaf_z+.98):
            slab(gate,"Door cedar stave",leaf_x-side*.29,4.43,z,.11,7.57,.07,"A86751",wood)

        for face in (-1,1):
            lamp_z = GATE_Z + face*3.23
            beam(gate,"Lantern hanger",(x,9.18,GATE_Z+face*1.37),(x,9.18,lamp_z),.20,"A36F49")
            beam(gate,"Lantern cradle",(x,9.18,lamp_z),(x,8.86,lamp_z),.10,"BB8E5C")
            festival_lantern(gate,x,8.13,lamp_z,.67,light=False)

    slab(gate,"South gate lintel",GATE_X,10.06,GATE_Z,23.8,.81,2.90,"A34C36",wood)
    slab(gate,"Lacquer fascia",GATE_X,10.57,GATE_Z,25.2,.50,3.92,"764033",wood)
    slab(gate,"South gate gold drip line",GATE_X,10.84,GATE_Z,25.9,.18,4.25,"D4A468",wood)
    swept_roof(gate,GATE_X,10.94,GATE_Z,26.6,11.34,3.84,fine_tiles=False,
               signature=True,corner_sweep=1.1)
    for face in (-1,1):
        sign(gate,"SOUTH GATE",GATE_X,9.78,GATE_Z+face*2.55,10.25,1.58,
             180 if face < 0 else 0,"863833")

    for chain_number, points in enumerate(WALL_SEGMENTS):
        wall = item(boundary,"Model",("West city wall" if chain_number==0 else "East city wall"))
        prop(wall,"token","ModelStreamingMode",1)
        for index,((ax,az),(bx,bz)) in enumerate(zip(points,points[1:])):
            x,z = (ax+bx)/2,(az+bz)/2
            dx,dz = bx-ax,bz-az
            length = hypot(dx,dz)
            yaw = degrees(atan2(-dz,dx))
            top = 7.42 + (.28 if index%3 == 1 else 0)
            slab(wall,"Slate perimeter footing",x,.48,z,length+.46,1.52,3.4,"847580",slate,yaw=yaw,collide=True)
            slab(wall,"Dressed slate perimeter base",x,1.85,z,length+.29,1.75,2.90,"9A8790",slate,yaw=yaw,collide=True)
            slab(wall,"Perimeter stone belt",x,2.77,z,length+.33,.28,3.07,"ADA0A4",slate,yaw=yaw)
            slab(wall,"Warm plaster perimeter",x,(top+2.90)/2,z,length+.25,top-2.90,2.28,
                 ("E4B88F","DDAF85","EBC09C")[index%3],limestone,yaw=yaw,collide=True)
            for y,at,depth,tint,material in (
                (top-.04,.25,2.75,"9B503A",wood),
                (top+.09,.20,3.13,"3C4E7A",wood),
                (top+.26,.19,2.67,"41578C",wood),
                (top+.43,.19,2.14,"4E6090",wood),
            ):
                slab(wall,"Indigo perimeter coping",x,y,z,length+.34,at,depth,tint,material,yaw=yaw)
            for course,y in enumerate((.64,1.29,1.96,2.43)):
                for pi in (-1,0,1):
                    along = (pi+(.18 if course%2 else -.15))*length*.28
                    for face in (-1,1):
                        across=face*(1.50 if course==0 else 1.46)
                        slab(wall,"Staggered dressed slate",x+along*dx/length+across*dz/length,
                             y,z+along*dz/length-across*dx/length,length*.25,.47,.18,
                             ("93818B","A49199","A2939F")[(pi+course+index)%3],slate,yaw=yaw)
            for t in (.35,.66):
                px,pz=ax+t*dx,az+t*dz
                for face in (-1,1):
                    nx,nz = face*1.19*dz/length,-face*1.19*dx/length
                    slab(wall,"Cedar wall brace",px+nx,5.08,pz+nz,.24,4.15,.16,"97573F",wood,yaw=yaw)
        for index,(x,z) in enumerate(points):
            if abs(x-GATE_X)<11:
                continue
            wall_pier(wall,x,z,7.98,1.30 if index%2 else 1.56)

        far_x,far_z = points[0 if chain_number==0 else -1]
        and_x,and_z = points[2 if chain_number==0 else -3]
        for x,z,w in ((far_x,far_z,10.8),(and_x,and_z,9.9)):
            tower = item(wall,"Model","Roofed boundary pavilion")
            prop(tower,"token","ModelStreamingMode",1)
            slab(tower,"Pavilion stone base",x,1.38,z,w*.64,3.40,4.72,"90828D",slate,collide=True)
            slab(tower,"Pavilion wall core",x,5.85,z,w*.60,5.78,4.52,"C79975",limestone,collide=True)
            for joint in (-1,1):
                slab(tower,"Pavilion corner cedar",x+joint*w*.277,6.20,z, .57,6.45,4.76,"9E4C37",wood)
            for face in (-1,1):
                pz=z+face*2.33
                slab(tower,"Pavilion amber inset",x,7.44,pz,2.91,1.61,.16,"DE9B61",limestone)
                for gap in (-1,0,1):
                    slab(tower,"Pavilion window lattice",x+gap*.74,7.44,pz+face*.10,
                         .09,1.65,.14,"744333",wood)
                festival_lantern(tower,x,7.07,z+face*3.10,.46,light=False)
            swept_roof(tower,x,8.97,z,w,7.87,2.55,fine_tiles=False)

    path = item(boundary, "Model", "South Gate walking loop")
    prop(path, "token", "ModelStreamingMode", 1)
    route(path,"South Gate promenade",SOUTH_GATE_APPROACH,13,"AD9690",surface=limestone,
          stone_footings=False,join_overlap=.34,railings=False)
    slab(path,"South Gate garden terrace",GATE_X,.28,104.0,25.2,.54,9.4,"AF9994",limestone,collide=True)
    for side in (-1,1):
        junction=(GATE_X+side*9.2,.55,104.5)
        route(path,"Garden alcove access",(junction,(GATE_X+side*14.9,.52,103.12)),
              5.30,"A99491",surface=limestone,stone_footings=False,join_overlap=.32,railings=False)
        slab(path,"Garden alcove floor",GATE_X+side*16.78,.25,103.05,5.82,.54,6.45,"AC9791",
             limestone,collide=True)

        seat_x,seat_z=GATE_X+side*17.28,105.10
        slab(apron,"Boundary garden bench",seat_x,1.53,seat_z,3.62,.23,1.51,"A97457",wood,collide=True)
        for support in (-1,1):
            slab(apron,"Boundary garden bench foot",seat_x+support*1.20,.98,seat_z,.47,.89,1.11,
                 "98899A",slate)
        slab(apron,"Boundary garden bench back",seat_x,1.95,seat_z+.64,3.61,.65,.15,"A16B50",wood)
        for x,z in ((GATE_X+side*7.56,87.25),(GATE_X+side*10.76,98.7)):
            slab(apron,"Garden lantern stone foot",x,.49,z,1.08,1.13,1.04,"958396",slate)
            slab(apron,"Garden lantern post",x,1.22,z,.29,1.30,.28,"884D3C",wood)
            festival_lantern(apron,x,2.25,z,.48,light=False)

    # Plant the city and country sides of the wall, keeping the walking loop clear.
    for idx,(x,z,width,length) in enumerate((
        (-25,86.4,8.7,5.2),(-45,86.8,11.6,4.2),(-62,85.5,10.8,5.2),(-78,82.8,8.5,3.8),
        (28,86.1,9.4,5.4),(46,86.0,10.9,4.4),(63,85.2,11.2,4.8),(80,81.9,8.8,4.1),
        (-24,101.9,8.8,5.9),(29,101.9,9.8,6.1),(-13.9,109.7,10.8,3.5),(19.1,109.7,10.8,3.5),
    )):
        bed=item(apron,"Model","Planted slate shoulder")
        prop(bed,"token","ModelStreamingMode",1)
        garden_shelf(bed,x,.63,z,width,length,.90,"887A88",slate,collide=False)
        garden_shelf(bed,x,.89,z,width*.84,length*.77,.28,"788A52",grass,collide=False)
        for j,(key,delta_x,delta_z,scale,tint) in enumerate((
            ("bankRock",-.31,-.19,.35,"9B899B"),("bankRock",.34,.14,.27,"A39199"),
            ("meadowCover",-.18,.19,.21,"91A95F"),("tallReeds",.23,-.14,.42,"D7B971"),
            ("mossFlowers",-.17,-.21,.20,"DD9CB4"),("meadowFlowers",.12,.23,.37,"F5C58A"),
        )):
            garden_prop(bed,key,(x+width*delta_x,.88,z+length*delta_z),scale,31*idx+57*j,tint)
    if tree is not None:
        for x,z,pink,scale in ((-31,84.4,True,.86),(32,84.6,True,.91),
                               (-72,81.8,False,1.05),(78,80.1,False,.97),
                               (-29,104.0,False,.85),(34,104.0,True,.85)):
            tree(apron,x,z,pink,scale=scale)
