"""The layered western range and hillside rooftops beyond Lantern Circuit."""

from math import atan2, degrees, hypot

from art.valley_ridge_layout import ridge_facets
from south_valley_backdrop import hillside_cedar, ridge_surface_height


# The ridges run along world Z and face the playable valley to the east.
# Their feet overlap the grass behind the High Walk's smaller immediate ridge.
RANGES = (
    ("West Valley wooded shoulder", -54, -368, 542, 59,
     (1,24,40,47,38,48,38,46,40,27,35,48,40,53,61,52,63,47,46,34,1),
     ("74687A","928086","A68A94"), 16),
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
    (-334.4,19,1.26),(-333.4,25,1.12),(-331.9,32,1.30),
    (-339.1,43,1.08),(-334.0,50,1.20),(-332.0,64,1.07),
    (-330.0,74,1.09),(-325.5,86,1.26),(-327.4,92,1.14),
    (-326.2,103,1.22),(-329.1,111,1.02),(-331.4,119,1.16),
    (-342,150,1.14),
    (-333,163,1.06),(-344,179,1.11),
)
HOUSES = (
    (-341,-208,1.05),(-332,-197,.82),
    (-339,48,1.18),(-333,56,.78),(-342,69,.94),
)

# Each strip lists the break in the cliff, the eastward run of its ledge and
# its longitudinal knots. Small end lengths bury the shelf inside the rock.
_BENCHES = (
    ((-337.6, 12, 1.1), (-337.9, 19, 7.5), (-336.8, 25, 8.6),
     (-335.2, 31, 8.1), (-337.0, 38, 4.2), (-338.6, 43, 1.0)),
    ((-343.7, 35, 1.2), (-341.9, 43, 7.7), (-339.4, 49, 10.1),
     (-338.9, 57, 8.8), (-337.8, 65, 10.1), (-335.5, 74, 8.9), (-338.1, 83, 1.2)),
    ((-332.2, 69, 1.0), (-330.9, 79, 6.4), (-329.6, 86, 9.0),
     (-332.2, 94, 9.4), (-330.0, 101, 8.0), (-333.6, 112, 9.8),
     (-335.3, 120, 7.5), (-334.6, 131, 1.4)),
)
_MOSS = ("6F7B55", "808A5D", "7B895D", "899366")
_SLATE = ("837580", "93838D", "8B7C8C", "9F8C94")
_CEDAR = {
    "394D45": "56654E", "486550": "647756", "58745B": "758765", "6A815D": "7B8962",
    "735347": "795E4A", "93674F": "886D50", "A77954": "9D8059", "BA8860": "AD8E66",
}


def _bench_faces(source, guides):
    """Generate a top bench and weathered face with both ends buried into the slope."""
    rows = []
    for index, (x, z, reach) in enumerate(guides):
        lift = -.34 if index in (0, len(guides) - 1) else .13
        grade = ridge_surface_height(source, x, z) + lift
        edge = x + reach * .53
        toe = x + reach * 1.17
        rows.append(((x - .18, grade - .20, z),
                     (x + reach * .24, grade - .21, z + .12),
                     (edge, grade - .89, z - .10),
                     (toe, ridge_surface_height(source, toe, z) - .32, z)))
    for row, (front, back) in enumerate(zip(rows, rows[1:])):
        for band, (a, b, c, d) in enumerate(zip(front, front[1:], back, back[1:])):
            planted = band < 2
            palette = _MOSS if planted else _SLATE
            for half, face in enumerate(((a, b, c), (c, b, d))):
                yield face, palette[(row + band + half) % len(palette)], planted


def build_west_valley_backdrop(parent, *, item, prop, part, triangle, beam,
                               slate, rock, smooth, cedar, neon, grass,
                               garden_prop, rock_variant, variant_field):
    backdrop = item(parent, "Folder", "West Valley backdrop")
    near_faces = []
    for index, (title, along, distance, width, depth, profile, palette, skirt) in enumerate(RANGES):
        model = item(backdrop, "Model", title)
        prop(model, "token", "ModelStreamingMode", 2)
        prop(model, "token", "LevelOfDetail", 4)
        for face,uv,tint in ridge_facets(along,distance,width,depth,profile,*palette,lower_detail=index > 0):
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

    def face_piece(group, face, tint, name, planted):
        first = len(group)
        triangle(group, *face, tint, name=name, material=grass if planted else rock,
                 thickness=.22, shadow=False)
        if not planted:
            for piece in list(group)[first:]:
                prop(piece, "string", variant_field, rock_variant)

    # Cut back into the mountain to create continuous bands of planted ground.
    slope = tuple(near_faces)
    for guides in _BENCHES:
        shelf = item(backdrop, "Model", "West Valley planted ridge bench")
        prop(shelf, "token", "ModelStreamingMode", 1)
        prop(shelf, "token", "LevelOfDetail", 4)
        for face, tint, planted in _bench_faces(slope, guides):
            face_piece(shelf, face, tint, "Sage shelf" if planted else "Ridge bench slate face", planted)
            near_faces.append(face)

    def tree_piece(group, name, position, size, tint, **rotation):
        if name.endswith("trunk"):
            block(group, name, position, size, tint, material=cedar, **rotation)
        else:
            broad = (size[0] * 1.79, size[1] * .89, size[2] * 1.66)
            block(group, name, position, broad, _CEDAR[tint], material=grass, **rotation)

    def fitted_shelf(group, name, top, ground, tint, *, cover):
        for i, (front, foot) in enumerate(zip(top, ground)):
            following = (i + 1) % len(top)
            for face in ((front, foot, ground[following]), (front, ground[following], top[following])):
                face_piece(group, face, tint, name, False)
        for i in range(1, len(top) - 1):
            face_piece(group, (top[0], top[i], top[i + 1]), cover, f"{name} cap", True)

    # Keep groves in independent streaming groups. The six-piece background
    # trees are buried in each occupied cliff shelf instead of sitting in front.
    for start in range(0,len(GROVES),3):
        group=item(backdrop,"Model","West Valley cedar grove")
        prop(group,"token","ModelStreamingMode",1)
        prop(group,"token","LevelOfDetail",4)
        for index,(x,z,scale) in enumerate(GROVES[start:start+3],start):
            y=ridge_surface_height(near_faces,x,z)
            hillside_cedar(tree_piece,group,x,y-.35,z,scale,index%8)
            if 12 <= z <= 130:
                offsets = ((-.94,-1.27),(.75,-1.64),(2.22,-.83),(2.54,.65),(1.06,1.63),(-1.32,1.06))
                top = tuple((x+dx*scale,y-.06,z+dz*scale) for dx,dz in offsets)
                feet = tuple((px,min(top_y-.39,ridge_surface_height(near_faces,px,pz)-.26),pz)
                             for px,top_y,pz in top)
                fitted_shelf(group, "Rooted cedar ledge", top, feet, _SLATE[index % len(_SLATE)], cover="788561")
                if index % 2 == 0:
                    kind = "meadowCover" if index % 4 == 0 else "grassBlade"
                    garden_prop(group, kind, (x+scale,y-.12,z+.57),.62,index*37,"A7A875")
            else:
                block(group,"Cedar root turf",(x,y-.35,z),(2.33*scale,.48,1.89*scale),
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
        if z > 0:
            apron = ((-3.55,-4.76),(2.21,-5.36),(4.72,-3.55),(5.45,.94),
                     (3.09,4.54),(-1.42,5.15),(-3.55,3.47))
            top = tuple((x+dx*scale,floor-.24-(.13 if dx>3 else 0),z+dz*scale) for dx,dz in apron)
            feet = tuple((px,min(top_y-.48,ridge_surface_height(near_faces,px,pz)-.34),pz)
                         for px,top_y,pz in top)
            fitted_shelf(roofline, "Lodge stone apron", top, feet, "8A7D89", cover="7E8460")
            for dz, kind, tint in ((-4.45,"mossFlowers","C6A0AB"),(4.05,"grassBlade","C8AF7B")):
                garden_prop(roofline, kind, (x+2.49*scale,floor-.30,z+dz*scale),.56,index*47,tint)

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
