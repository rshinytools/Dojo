"""A walkable cedar gallery with six featured stands and six paged wall displays."""

from math import cos, radians, sin


def build_trophy_room(storage, *, item, part, prop, sign, wood, slate, fabric, neon, smooth):
    room = item(storage, "Model", "Personal Trophy Room")
    prop(room, "token", "ModelStreamingMode", 1)
    walnut, cedar, gold = "51333B", "774535", "BC864F"
    def piece(name, size, at, tint, material=wood, collide=False, **options):
        return part(room, name, at, size, tint, material=material, collide=collide, **options)

    piece("Gallery floor", (34, .65, 35), (0, -.325, 0), "925A42", collide=True)
    for x in range(-16, 17, 2):
        piece("Wood join", (.028, .015, 34), (x, .008, 0), "694039")
    for x in (-17, 17):
        piece("Cedar side wall", (.75, 11, 35), (x, 5.5, 0), walnut, collide=True)
        for y, tint in ((1.15, cedar), (3.12, gold), (9.41, gold)):
            piece("Carved side trim", (.86, .16, 34), (x, y, 0), tint)
    for z in (-17.5, 17.5):
        piece("Cedar end wall", (34, 11, .58), (0, 5.5, z), walnut, collide=True)
        piece("Gallery crown", (34,.28,.7), (0,10.48,z), gold)
    piece("Ceiling", (35,.55,36), (0,11.1,0), "462B37", collide=True)
    for z in (-13,-6,2,10,15):
        piece("Exposed beam", (34,.38,.51), (0,10.66,z), cedar)
    for x in (-16.5,16.5):
        for z in (-15,-8,0,8,15):
            piece("Cedar post", (.62,11,.55), (x,5.5,z), cedar)
    piece("Reed runner", (6.9,.045,28), (0,.032,3), "956347", fabric)
    for x in (-3.35, 3.35):
        piece("Runner stitched edge", (.12,.016,28), (x,.064,3), "F0BD7B", fabric)
    for x in (-8.1,0,8.1):
        shade = piece("Festival paper lantern", (1.38,1.45,1.38), (x,9.05,-.2), "F4B570", smooth, shape=0)
        for y in (8.63, 9.03, 9.45):
            width = 1.40 if y==9.03 else 1.23
            piece("Lantern silk rib", (width,.055,width),(x,y,-.2),"D28D5E",neon,shape=2,roll=90)
        piece("Bronze hanger", (.11,1.40,.11),(x,10.17,-.2), gold)
        light = item(shade, "PointLight", "Soft gallery light")
        prop(light, "float", "Range", 18)
        prop(light, "float", "Brightness", .85)

    def art(title, center, sky, mountains, kind, yaw=0):
        x, y, z = center
        sine, cosine = sin(radians(yaw)), cos(radians(yaw))
        def paint(name, size, position, tint, material=smooth, **kwargs):
            px, py, pz = position
            dx, dz = px-x, pz-z
            return piece(name,size,(x+dx*cosine+dz*sine,py,z-dx*sine+dz*cosine),
                         tint,material,yaw=yaw,**kwargs)
        lamp=paint("Mural wash",(.3,.3,.3),(x,y+.0,z+3.8),"FFD7AC",transparency=1)
        light=item(lamp,"PointLight","Framed art light")
        prop(light,"float","Range",8)
        prop(light,"float","Brightness",1.30)
        paint(title + " frame", (8.32,4.65,.25), (x,y,z), gold)
        paint(title + " paper", (8.04,4.34,.04), (x,y,z+.15), sky, smooth)
        paint(title + " sun", (1.22,1.22,.044), (x+2.27,y+.89,z+.18), "FFC684", smooth, shape=0)
        for i, tint in enumerate(mountains):
            for j in range(4):
                h = .62 + .55 * abs(sin((i+1)*(j+1)*1.35))
                p = .9 + (i+1)*.16
                paint(title + " painted ridge", (p,h,.022), (x-2.68+j*1.79,y-.14-i*.30,z+.22+i*.02),
                    tint, smooth, roll=(-1)**j*17)
        paint(title + " foreground", (8.02,.80,.026), (x,y-1.72,z+.29), mountains[-1], smooth)
        if kind == "bridge":
            for step in range(-8,9):
                u = step/8
                height = -.55-.69*u*u
                paint("Painted red bridge", (.28,.21,.028), (x+u*2.02,y+height,z+.34), "9F4B52", smooth,
                    roll=-step*3)
                if step % 2 == 0:
                    paint("Bridge rail painted post", (.10,.35,.029), (x+u*2.02,y+height+.16,z+.355), "F2B17B", smooth)
        elif kind == "summit":
            for gx,gy in ((-1.7,-.53),(.23,.36),(2.18,1.02)):
                for side in (-1,1):
                    paint("Painted summit gate post", (.13,.56,.05),(x+gx+side*.25,y+gy,z+.33),"A95152",smooth)
                paint("Painted summit gate roof",(.72,.12,.047),(x+gx,y+gy+.29,z+.35),"E9A376",smooth)
        elif kind == "arena":
            for side,tint in ((-1,"D07150"),(1,"4B8E83")):
                paint("Painted fighter head",(.80,.84,.04),(x+side*1.04,y+.36,z+.33),tint,shape=0)
                paint("Painted fighter robes",(.82,.96,.045),(x+side*1.12,y-.38,z+.335),tint,roll=side*12)
                paint("Painted sparring glove",(.66,.50,.045),(x+side*.36,y-.06,z+.36),"F6BB7E",shape=0)
                paint("Painted sash",(.74,.13,.045),(x+side*1.16,y-.53,z+.38),"F2CF94",roll=side*12)
        else:
            for i in range(7):
                paint("Painted district marker", (.16,.16,.036),(x-2.82+i*.88,y+.46*sin(i*1.82),z+.36),
                    "F6CD89",smooth,shape=0)

    art("Lantern Relay mural",(-10.03,7.55,-16.98),"AD6467",("985D74","7A526B","66445C"),"bridge")
    art("Cloudbreak mural",(0,7.55,-16.98),"7989A8",("818DAC","686E92","555780"),"summit")
    art("Valley route map",(10.03,7.55,-16.98),"AD8568",("8A8A75","75846D","637969"),"map")
    art("Grand Dojo sparring mural",(-16.10,6.55,0),"986C81",("A27583","80596D","674F6B"),"arena",90)
    art("Festival canal mural",(16.10,6.55,0),"7BA2A2",("8E9A9B","687C94","537985"),"bridge",-90)
    for x in (-13.5,13.5):
        for z in (7,12):
            piece("Cedar bench", (2.5,.22,3.9), (x,.76,z), cedar)
            piece("Brocade cushion", (2.35,.16,3.65), (x,.94,z), "8D485C", fabric)
    for index, x in enumerate((-12.5,-7.5,-2.5,2.5,7.5,12.5),1):
        featured_z = -6.0 if index in (3,4) else -8.0
        piece("Featured slate foot", (3.40,.22,3.39), (x,.11,featured_z), "625866", slate)
        piece("Featured lacquer pedestal", (3.02,1.48,2.98), (x,.93,featured_z), cedar, collide=True)
        piece("Featured brass trim", (3.25,.16,3.12), (x,1.71,featured_z), gold)
        piece(f"Featured{index}", (.2,.2,.2), (x,1.91,featured_z), gold, transparency=1)
        piece("Wall display shelf", (3.42,.18,2.84), (x,2.76,-14.43), "9F624A")
        piece(f"Wall{index}", (.2,.2,.2), (x,2.98,-14.43), gold, transparency=1)
    piece("Arrival",(.2,.2,.2), (0,3.1,11.5), gold, transparency=1)
    piece("Exit",(.3,.3,.3), (0,2,15), gold, transparency=1)
    sign(room,"RETURN TO TROPHY HALL",0,4.08,17.15,7.14,.72,yaw=180,tint=walnut,wayfinding=True)
    piece("RoomControls",(.3,.3,.3),(0,2,8.7),gold,transparency=1)
