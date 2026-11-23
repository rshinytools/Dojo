"""A small spill running over the landscaped shelves beside the Hall ramp."""


def build_hall_garden_spill(parent, *, item, prop, part, triangle, glass):
    spill = item(parent,"Model","Trophy Hall garden spill")
    prop(spill,"token","LevelOfDetail",4)
    # Continue Reedfall's west overflow over the short lower stone lips.
    contour = (
        (24.98,7.15,-27.02,1.73),
        (25.03,6.30,-26.58,1.58),
        (25.09,5.50,-25.61,2.03),
        (25.15,4.82,-25.08,2.38),
        (25.22,3.80,-24.73,2.16),
        (25.32,2.80,-24.34,1.74),
        (25.45,2.12,-24.29,1.66),
        (25.56,1.53,-24.17,1.35),
        (25.63,.96,-24.09,1.48),
        (25.70,.67,-23.98,1.65),
    )
    palette = (("639FBB",.23),("BCE9EE",.13),("76B9CF",.18))
    offset = (-.50,-.16,.19,.50)
    contour = [[(x+width*u,y+(0.015 if col%2 else -.019),z+.31+(0.05 if col in (1,2) else 0))
                for col,u in enumerate(offset)] for x,y,z,width in contour]
    for top,bottom in zip(contour,contour[1:]):
        for col,(tint,alpha) in enumerate(palette):
            a,b=top[col:col+2]
            c,d=bottom[col:col+2]
            for face in ((a,c,b),(c,d,b)):
                triangle(spill,*face,tint,name="Reedfall garden water ribbon",
                         thickness=.044,shadow=False,collide=False,transparency=alpha)
    for x,y,z,w,d in ((25.10,5.46,-25.38,2.01,.91),
                       (25.23,3.78,-24.52,2.21,.81),
                       (25.80,.65,-23.48,2.16,1.16)):
        piece = part(spill,"Pale spill shelf",(x,y,z),(w,.064,d),
                     "9BD6E6",shape=0,material=glass,transparency=.28,collide=False)
        prop(piece,"bool","CastShadow",False)
    for x,y,z,width,depth,yaw in (
        (24.76,5.54,-25.39,.94,.29,-13), (25.56,5.53,-25.33,.49,.16,18),
        (25.00,3.85,-24.50,1.30,.33,8), (25.67,3.85,-24.58,.54,.18,-17),
        (25.51,.72,-23.26,.82,.31,-12), (26.16,.71,-23.42,.69,.26,16),
    ):
        foam = part(spill,"Garden spill surface foam",(x,y,z),(width,.032,depth),
                    "D6EFEE",yaw=yaw,shape=0,transparency=.25,collide=False)
        prop(foam,"bool","CastShadow",False)
