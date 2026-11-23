"""The layered western range and hillside rooftops beyond Lantern Circuit."""

from math import atan2, degrees, hypot

from art.valley_ridge_layout import ridge_facets
from south_valley_backdrop import hillside_cedar, ridge_surface_height


# The ridges run along world Z and face the playable valley to the east.
# Their feet overlap the grass behind the High Walk's smaller immediate ridge.
RANGES = (
    ("West Valley wooded shoulder", -54, -368, 542, 59,
     (1,24,40,47,38,48,38,46,40,27,35,48,40,53,61,52,63,47,46,34,1),
     ("676178","95849A","B398A6"), 16),
    ("West Valley distant peaks", -9, -484, 930, 112,
     (1,32,55,69,79,64,89,78,92,76,62,69,87,80,102,89,
      67,81,102,109,93,82,98,86,79,60,36,16,1),
     ("8E6E86","C092A5","D8A2B3"), 36),
)
GROVES = (
    (-342,-262,1.20),(-334,-251,1.04),(-341,-239,1.26),
    (-339,-177,1.09),(-331,-165,.89),(-345,-156,1.26),
    (-341,-122,1.14),(-335,-109,.97),(-343,-96,1.23),
    (-341,-47,1.22),(-339,-33,.98),(-330,-25,.82),
    (-342,19,1.36),(-332,28,1.13),(-342,37,1.25),
    (-340,61,1.32),(-332,75,1.02),(-342,94,1.26),
    (-332,112,1.08),(-341,121,1.29),(-342,150,1.14),
    (-333,163,1.06),(-344,179,1.11),
)
HOUSES = (
    (-341,-208,1.05),(-332,-197,.82),
    (-339,48,1.18),(-333,56,.78),(-342,69,.94),
)


def build_west_valley_backdrop(parent, *, item, prop, part, triangle, beam,
                               slate, rock, smooth, cedar, neon, grass,
                               rock_variant, variant_field):
    backdrop = item(parent, "Folder", "West Valley backdrop")
    near_faces = []
    for index, (title, along, distance, width, depth, profile, palette, skirt) in enumerate(RANGES):
        model = item(backdrop, "Model", title)
        prop(model, "token", "ModelStreamingMode", 2)
        prop(model, "token", "LevelOfDetail", 4)
        for face,uv,tint in ridge_facets(along,distance,width,depth,profile,*palette,lower_detail=True):
            points = tuple((x,y-skirt*progress,z) for (z,y,x),(_,progress) in zip(face,uv))
            if index == 0:
                near_faces.append(points)
            factors = (.84,.88,.95) if index == 0 else (.91,.88,.94)
            pigment = "".join(f"{round(channel*factor):02X}" for channel,factor in zip(tint,factors))
            first = len(model)
            triangle(model,*points,pigment,name="Western ridge slope",material=rock if index == 0 else smooth,
                     thickness=.23,shadow=False)
            if index == 0:
                for piece in model[first:]:
                    prop(piece,"string",variant_field,rock_variant)

    def block(group,name,position,size,tint,*,material=smooth,**rotation):
        piece=part(group,name,position,size,tint,material=material,collide=False,**rotation)
        prop(piece,"bool","CastShadow",False)

    # Put the sparse cedar groves into independent streaming groups.
    for start in range(0,len(GROVES),3):
        group=item(backdrop,"Model","West Valley cedar grove")
        prop(group,"token","ModelStreamingMode",1)
        prop(group,"token","LevelOfDetail",4)
        for index,(x,z,scale) in enumerate(GROVES[start:start+3],start):
            y=ridge_surface_height(near_faces,x,z)
            hillside_cedar(block,group,x,y+.12,z,scale,index%8)
            block(group,"Cedar root turf",(x,y-.10,z),(2.33*scale,.48,1.89*scale),
                  "77856A",material=grass,yaw=index*33,shape=0)

    for index,(x,z,scale) in enumerate(HOUSES):
        roofline=item(backdrop,"Model","West Valley hillside lodge")
        prop(roofline,"token","ModelStreamingMode",1)
        prop(roofline,"token","LevelOfDetail",4)
        corners=((-2.55,-3.70),(2.55,-3.70),(2.55,3.70),(-2.55,3.70))
        grounded=[(x+dx*scale,ridge_surface_height(near_faces,x+dx*scale,z+dz*scale)-.42,
                   z+dz*scale) for dx,dz in corners]
        floor=max(y for _,y,_ in grounded)+.32
        high=[(px,floor,pz) for px,_,pz in grounded]
        for i in range(4):
            j=(i+1)%4
            for p,q,r in ((high[i],grounded[i],grounded[j]),(high[i],grounded[j],high[j])):
                triangle(roofline,p,q,r,"8B7A87",name="Slope-fitted slate foundation",
                         thickness=.24,material=slate,shadow=False)

        def detail(name,dx,dy,dz,size,tint,material=smooth,**rotation):
            block(roofline,name,(x+dx*scale,floor+dy*scale,z+dz*scale),
                  tuple(length*scale for length in size),tint,material=material,**rotation)

        detail("Dressed slate terrace",0,.08,0,(5.40,.31,7.83),"A39091",slate)
        detail("Warm plaster lodge",0,2.23,0,(4.65,4.20,6.73),"B27960")
        for offset in (-2.86,0,2.86):
            detail("Lodge vermilion pillar",2.38,2.35,offset,(.26,4.36,.44),"915345",cedar)
        for offset in (-1.45,1.45):
            detail("Lodge amber lattice",2.37,2.48,offset,(.14,1.66,1.60),"DEA276",neon)
            detail("Lattice cedar mullion",2.46,2.48,offset,(.12,1.73,.12),"986E5E",cedar)
        detail("Lodge eave fascia",2.40,4.29,0,(.25,.32,7.20),"896152",cedar)
        roof=((3.70,4.44),(2.65,4.69),(1.67,5.24),(.79,5.98),(0,6.79))
        for side in (-1,1):
            for (outer,lower),(inner,upper) in zip(roof,roof[1:]):
                pitch=-side*degrees(atan2(upper-lower,outer-inner))
                detail("Indigo lodge roof",side*(outer+inner)*.5,(lower+upper)*.5,0,
                       (hypot(outer-inner,upper-lower)+.12,.22,8.96),
                       ("4C5376","555477","544E70")[index%3],roll=pitch)
            for end in (-1,1):
                start=(x+side*3.50*scale,floor+4.49*scale,z+end*4.00*scale)
                tip=(x+side*3.74*scale,floor+4.96*scale,z+end*4.74*scale)
                gold=beam(roofline,"Lodge upturned eave tip",start,tip,.31*scale,"BF946F")
                prop(gold,"bool","CastShadow",False)
        detail("Lodge ridge coping",0,6.83,0,(.52,.34,8.92),"5C5676")
