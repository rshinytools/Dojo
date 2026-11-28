"""Build the Personal Trophy Room and its original display fixtures."""

import json
from math import cos, pi, radians, sin
from pathlib import Path


def build_trophy_room(storage, *, item, part, prop, sign, asset, color, wood, slate, fabric, neon, smooth):
    room = item(storage, "Model", "Personal Trophy Room")
    prop(room, "token", "ModelStreamingMode", 1)
    mural_manifest = Path(__file__).with_name("art") / "trophy-murals" / "assets.json"
    murals = json.loads(mural_manifest.read_text()) if mural_manifest.is_file() else {}
    walnut, cedar, gold = "2C1E24", "6B3928", "CF973F"
    red, cream = "A53223", "FFDDA0"

    def piece(name, size, at, tint, material=wood, collide=False, **options):
        return part(room, name, at, size, tint, material=material, collide=collide, **options)

    def cylinder(name, diameter, height, at, tint, material=smooth, **options):
        return piece(name, (height, diameter, diameter), at, tint, material, shape=2, roll=90, **options)

    def light(source, brightness, distance, tint):
        lamp = item(source, "PointLight", "Gallery light")
        prop(lamp, "float", "Range", distance)
        prop(lamp, "float", "Brightness", brightness)
        color(lamp, "Color", tint)

    def lantern(name, x, y, z, scale=1, *, lit=False, hanging=False, shade_tint=cream):
        shade = cylinder(name, 1.46*scale, 1.65*scale, (x,y,z), shade_tint, neon)
        for component, h, width in (("Crown",-0.86,1.36), ("Cap",.86,1.36), ("Rib",-.44,1.49),
                                    ("Rib",0,1.49), ("Rib",.44,1.49)):
            cylinder(name+" "+component,width*scale,.067*scale,(x,y+h*scale,z),cedar)
        for i in range(8):
            turn = i*pi/4
            piece(name+" bamboo spine",(.039*scale,1.68*scale,.043*scale),
                  (x+.733*scale*cos(turn),y,z+.733*scale*sin(turn)),cedar)
        if hanging:
            piece("Lantern suspension",(.07,1.4,.07),(x,y+1.52*scale,z),gold)
        if lit:
            light(shade,.9,17,"FFB668")

    piece("Polished cedar gallery floor",(42,.75,41),(0,-.375,0),"81513A",collide=True)
    for i in range(24):
        x = 1.75*(i-11.5)
        piece("Floorboard joint",(.024,.014,40.7),(x,.009,0),"4E3029")
        for z in (-16.8+i%4*1.2,-7.6+i%4*1.2,1.6+i%4*1.2,10.8+i%4*1.2):
            piece("Staggered board joint",(1.7,.014,.024),(x+.84,.009,z),"4E3029")
    for x in (-21,21):
        piece("Cedar gallery wall",(.64,23,41),(x,11.5,0),walnut,collide=True)
        for z in (-19.5,-12.2,-4.8,2.7,10.1,19.5):
            piece("Carved upright",(.85,22.8,.83),(x*.972,11.4,z),cedar)
    for z in (-20.5,20.5):
        piece("Gallery end wall",(42,23,.65),(0,11.5,z),walnut,collide=True)
        for x in (-19,-13,-6.5,0,6.5,13,19):
            piece("Gallery end upright",(.71,23,.82),(x,11.5,z*.971),cedar)
    piece("High roof decking",(43,.72,42),(0,23.3,0),walnut,collide=True)

    def ceiling_detail(name, size, at, tint, material=wood, **options):
        trim = piece(name,size,at,tint,material,**options)
        prop(trim,"bool","CastShadow",False)
        return trim

    for z in (-18,-10,-2,6,14):
        piece("Exposed transverse tie beam",(42,.72,.88),(0,19.3,z),"693D30")
        ceiling_detail("Tie beam lower molding",(40.8,.19,1.02),(0,18.94,z),"8E4931")
        for side in (-1,1):
            piece("Angled roof truss",(20.8,.65,.66),(10.2*side,21.20,z),cedar,roll=-side*7)
            piece("Decorative knee brace",(.66,3.70,.61),(18.8*side,18.22,z),cedar,roll=side*38)
            ceiling_detail("Carved bracket cap",(1.49,.24,1.13),(19.55*side,18.72,z),"86462D")
            ceiling_detail("Brass truss joint",(.18,.41,.90),(17.5*side,19.29,z),gold,smooth)
        piece("Roof king post",(.58,2.9,.64),(0,20.96,z),cedar)
        ceiling_detail("Carved king post collar",(.98,.28,.90),(0,20.02,z),"925537")

    # Raised center coffers sit above a separate layer of sloping side panels.
    for z in (-14,-6,2,10,17):
        span = 5.65 if z==17 else 7.65
        ceiling_detail("Raised cedar ceiling coffer",(10.38,.16,span),(0,22.77,z),"734733")
        for dx in (-2.61,2.61):
            ceiling_detail("Coffer recessed field",(4.85,.12,span-.42),(dx,22.67,z),"53302D")
        ceiling_detail("Coffer cross rail",(10.4,.22,.23),(0,22.56,z),"9A5431")
        for side in (-1,1):
            ceiling_detail("Sloped cedar ceiling panel",(14.4,.17,span),(12.43*side,21.84,z),
                           "694333",roll=-side*7)
            ceiling_detail("Sloped coffer cross rail",(14.42,.18,.23),(12.43*side,21.66,z),
                           "925335",roll=-side*7)
    for x,y,width in ((-5.22,22.48,.36),(0,22.52,.29),(5.22,22.48,.36),
                      (-11.9,21.62,.25),(11.9,21.62,.25),(-19.55,20.70,.35),(19.55,20.70,.35)):
        ceiling_detail("Longitudinal cedar rafter",(width,.39,40.2),(x,y,0),"8C4E33")
    for side in (-1,1):
        ceiling_detail("Clerestory cornice",(.86,.31,40.5),(20.19*side,19.34,0),"844332")
        ceiling_detail("Clerestory cornice brass fillet",(.44,.067,40.4),(19.95*side,19.18,0),
                       "A36C3E",smooth)

    def lattice(x,y,z,width,height,yaw,tint):
        direction = radians(yaw)
        def window_piece(name, size, dx, dy, depth, paint, material=smooth):
            return piece(name,size,(x+dx*cos(direction)+depth*sin(direction),
                                     y+dy,z-dx*sin(direction)+depth*cos(direction)),
                         paint,material,yaw=yaw)
        window_piece("Lattice frame",(width+.33,height+.33,.24),0,0,0,cedar,wood)
        window_piece("Luminous lattice backing",(width,height,.08),0,0,.15,tint,neon)
        for i in range(1,9):
            window_piece("Lattice mullion",(.085,height,.10),(i/9-.5)*width,0,.22,walnut)
        for i in range(1,3):
            window_piece("Lattice transom",(width,.085,.10),0,(i/3-.5)*height,.22,walnut)

    for side in (-1,1):
        for z in (-15.8,-8.5,-1.0,6.5,14.8):
            lattice(side*20.4,17.9,z,6.7,2.18,-side*90,"A878A2")
        for z in (-16.7,-9.2,-1.8,5.8,13.3):
            lattice(side*20.4,2.5,z,6.8,2.48,-side*90,"E4A65D")
    for x in (-14,-7,0,7,14):
        lattice(x,18.2,-19.96,6.65,2.45,0,"A878A2")

    def mural(title, center, size, key, yaw=0):
        x,y,z = center
        w,h = size
        direction = radians(yaw)
        piece(title+" gold surround",(w+.42,h+.42,.34),center,gold,smooth,yaw=yaw)
        face = piece(title,(w,h,.09),(x+.22*sin(direction),y,z+.22*cos(direction)),
                     "DFCBAB",smooth,yaw=yaw)
        if key in murals:
            picture = item(face,"Decal",title)
            asset(picture,"TextureContent",f"rbxassetid://{murals[key]}")
            prop(picture,"token","Face",2)

    mural("Lantern Relay at sunset",(-20.08,10.9,2.5),(17.9,11.0),"relay",90)
    mural("Cloudbreak mountain shrines",(3.8,11.7,-19.20),(24.0,11.2),"cloudbreak")
    mural("Grand Dojo sparring scroll",(-13.8,10.7,-19.20),(10.0,8.7),"sparring")
    mural("Illustrated valley map",(20.08,11,0),(17.9,11.0),"valley",-90)

    piece("Woven gallery runner",(7.2,.055,23),(0,.036,6),"BD8D4E",fabric)
    for x in (-3.48,3.48):
        piece("Embroidered red runner border",(.25,.020,23),(x,.070,6),"772F2C",fabric)
        piece("Stitched gold line",(.04,.013,23),(x*.94,.082,6),"E7B564",fabric)
    for z in (-5.39,17.39):
        piece("Runner end embroidery",(7.22,.022,.18),(0,.073,z),"772F2C",fabric)

    for x,y,z,scale in ((0,15.45,6,1.48),(-12,14.55,-2,1.06),(12,14.55,-2,1.06),
                         (-7,13.35,-10,.84),(7,13.35,-10,.84)):
        lantern("Hanging festival lantern",x,y,z,scale,lit=z>=-2,hanging=True,shade_tint="E6A66B")
        hanger_top = 18.87
        stem_top = y+1.52*scale+.7
        ceiling_detail("High lantern chain",(.07,hanger_top-stem_top,.07),
                       (x,(hanger_top+stem_top)/2,z),gold,smooth)
        ceiling_detail("Lantern beam mount",(.36,.13,.36),(x,hanger_top,z),gold,smooth)
    for name, at, brightness, radius, tint in (
        ("Entrance fill",(0,7,13),1.65,21,"FFDBAF"),
        ("Shrine and cabinet fill",(0,7,-12),2.05,24,"FFE0B8"),
        ("Rafter bounce",(0,18.3,-2),1.8,24,"FFC488"),
    ):
        emitter = piece(name,(.12,.12,.12),at,tint,transparency=1)
        light(emitter,brightness,radius,tint)
    for x in (-6.5,6.5):
        piece("Crimson gallery banner",(2.25,4.23,.11),(x,16.9,5.56),"8D312B",fabric)
        for y in (14.9,18.91):
            piece("Banner brocade border",(2.28,.11,.13),(x,y,5.56),gold,fabric)
        for dx,dy in ((-.37,0),(0,.19),(.37,0)):
            piece("Banner cloud embroidery",(.61,.42,.025),(x+dx,17.3+dy,5.64),gold,fabric,shape=0)

    def plinth(name, x,z,diameter,height):
        cylinder(name+" stone foot",diameter,.22,(x,.11,z),"362A30",slate)
        cylinder(name+" underglow",diameter*.92,.083,(x,.25,z),"FFBF52",neon)
        cylinder(name+" lacquer base",diameter*.85,height-.42,(x,height/2+.07,z),"622F25",wood,collide=True)
        cylinder(name+" brass crown",diameter*.94,.16,(x,height-.07,z),gold)
        piece(name+" face plaque",(diameter*.36,.42,.07),(x,height*.52,z+diameter*.43),"A46529",smooth)
        piece(name+" crest",(.26,.26,.06),(x,height*.52,z+diameter*.43+.05),cream,smooth,roll=45)

    plinth("Central shrine",0,-8.1,6.9,1.9)
    for x in (-2.65,2.65):
        piece("Shrine red timber post",(.64,6.4,.73),(x,4.61,-8.33),red)
        for y in (1.54,2.03,6.9,7.51):
            piece("Shrine gold join",(.77,.17,.85),(x,y,-8.33),gold,smooth)
    piece("Shrine vermilion crossbeam",(6.65,.38,.77),(0,6.68,-8.33),red)
    piece("Shrine painted fascia",(7.10,.55,.935),(0,7.73,-8.33),red)
    piece("Shrine charcoal cap",(7.43,.30,1.16),(0,8.11,-8.33),"352838",slate)
    for side in (-1,1):
        piece("Upturned shrine eave",(1.82,.30,1.15),(side*3.83,8.31,-8.33),
              "352838",slate,roll=side*18)
    for x,y in ((-.42,8.0),(.42,8.0),(0,8.23)):
        piece("Gilded shrine cloud crest",(.62,.49,.18),(x,y,-7.67),gold,smooth,shape=0)
    lantern("Ceremonial hall lantern",0,4.28,-8.11,1.56,lit=True,hanging=True)
    piece("Ceremonial lantern pendant",(.32,.86,.32),(0,2.63,-8.11),gold,smooth)

    for index,x in enumerate((-15.1,-10.4,-5.9,5.9,10.4,15.1),1):
        z = -8.1 if index in (3,4) else -10.0
        plinth("Featured trophy stand",x,z,3.55,1.43)
        piece(f"Featured{index}",(.2,.2,.2),(x,1.62,z),gold,transparency=1)
        piece("Cabinet dark backing",(4.23,4.75,.25),(x,3.17,-19.39),"3B2526")
        for y in (.89,2.85,5.39):
            piece("Cabinet brass rail",(4.30,.11,.19),(x,y,-19.04),gold,smooth)
        for dx in (-2.1,2.1):
            piece("Cabinet carved frame",(.16,4.5,.24),(x+dx,3.13,-19.08),cedar)
        piece("Wall display shelf",(4.20,.20,2.18),(x,2.66,-18.40),cedar)
        piece("Wall display gilded edge",(4.23,.07,.1),(x,2.72,-17.29),gold,smooth)
        piece(f"Wall{index}",(.2,.2,.2),(x,2.77,-18.22),gold,transparency=1)

    for side in (-1,1):
        for z in (7.8,14.2):
            x=16.6*side
            piece("Gallery reading bench",(2.16,.25,5.06),(x,.96,z),cedar)
            piece("Embroidered crimson cushion",(1.93,.21,4.66),(x,1.15,z),"873430",fabric)
            for dz in (-1.79,1.79):
                piece("Bench carved leg",(1.7,.92,.47),(x,.45,z+dz),walnut)
        lantern("Floor lantern",18.75*side,.95,16.9,.53)
        x,z=17.8*side,-3.75
        cylinder("Bonsai ceramic vessel",2.5,.74,(x,.43,z),"6D6861",slate)
        cylinder("Bonsai soil",2.30,.11,(x,.85,z),"493E2D")
        piece("Bonsai leaning trunk",(.41,2.25,.38),(x,1.76,z),cedar,roll=-side*15)
        for dx,y,dz,d,w in ((0,2.86,0,1.86,1.1),(.9,2.62,.17,1.78,1.1),(-.72,2.35,-.24,1.56,1.05),
                             (-1.24,2.20,.1,1.19,.84),(.40,3.18,-.14,1.28,.88)):
            piece("Bonsai foliage",(d,.54,w),(x+dx*side,y,z+dz),
                  "58653A" if side>0 else "CD777F",smooth,shape=0)

    piece("Arrival",(.2,.2,.2),(0,3.1,14.2),gold,transparency=1)
    piece("Exit",(.3,.3,.3),(0,2,18.65),gold,transparency=1)
    sign(room,"RETURN TO TROPHY HALL",0,4.3,20.03,7.14,.72,yaw=180,tint=walnut,wayfinding=True)
    piece("RoomControls",(.3,.3,.3),(0,2,-3.4),gold,transparency=1)
