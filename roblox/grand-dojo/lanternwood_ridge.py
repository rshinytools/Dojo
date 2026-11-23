"""The layered, wooded skyline south of Lantern Circuit Road."""

from math import cos, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Crest controls from the roadward toe to the southern shoulder. Short,
# offset shoulders break up the three summits from the market's western view.
CREST = (
    (-174.0,-1.0,39.4,18.0,18.0),(-171.4,8.0,46.8,22.0,19.0),
    (-167.6,18.9,54.6,27.0,26.0),(-165.0,23.9,57.7,28.0,27.8),
    (-164.0,26.4,61.0,28.0,30.0),(-165.7,25.1,63.7,29.5,28.6),
    (-169.2,20.2,68.7,34.5,25.0),(-162.4,24.5,73.3,32.0,29.1),
    (-158.0,28.3,77.0,31.1,31.8),(-156.9,29.0,80.4,31.2,33.1),
    (-157.3,25.4,84.6,32.9,34.2),(-158.4,21.2,88.2,34.1,34.5),
    (-162.2,21.9,93.1,37.0,35.9),(-166.8,25.0,96.8,40.1,36.7),
    (-169.1,24.9,100.1,41.3,36.1),(-173.5,21.4,103.6,38.0,34.6),
    (-176.7,14.8,107.7,35.0,31.5),(-185.0,-1.0,117.1,24.0,20.0),
)
BANDS=((0,1),(.19,.86),(.39,.69),(.60,.48),(.79,.25),(1,0))
SLATE_TONES=("726979","847783","8D7C85","776E80","978589")
MOSS_TONES=("65735D","768066","7D8467","68785F","82876D")
WEST_SLATE=("7C717F","847785","91828A","877A86","947F8B")
WEST_SAGE=("6E776B","758071","788170","737D6F","818779")


def ridge_facets():
    for side in (-1,1):
        contours=[]
        for travel,lift in BANDS:
            contours.append(tuple(
                (x+side*(east if side>0 else west)*travel+1.8*sin(index*.83+travel*5)*travel,
                 (y+1.8*cos(index*.89+travel*6)*travel)*lift-4.08*travel,
                 z+1.7*sin(index*.82+travel*3.9)*travel if 0<index<len(CREST)-1 else z)
                for index,(x,y,z,east,west) in enumerate(CREST)
            ))
        for band,(higher,lower) in enumerate(zip(contours,contours[1:])):
            for row,(a,b,c,d) in enumerate(zip(higher,higher[1:],lower,lower[1:])):
                # Rock leads at the rim and returns in strips through the moss.
                faces=((a,b,c),(c,b,d)) if (row+band)%2 else ((a,b,d),(a,d,c))
                if side<0:
                    # Adjacent triangles share a color on the west-facing shelves.
                    # Long slate ribs and broad sage strips read as contour layers.
                    stone=band in (0,2) or (row//3+band)%5==1
                    tints=WEST_SLATE if stone else WEST_SAGE
                    tint=tints[(row//2+band)%len(tints)]
                    for face in faces:
                        yield face,tint,stone
                else:
                    stone=band<2 or (row+band*2)%5 in (0,2)
                    tints=SLATE_TONES if stone else MOSS_TONES
                    for side_index,face in enumerate(faces):
                        yield face,tints[(row*2+band+side_index+side)%len(tints)],stone


def build_lanternwood_ridge(parent, *, item, prop, part, triangle, slate, rock,
                            grass, cedar, neon, rock_variant, variant_field):
    ridge=item(parent,"Model","Lanternwood Ridge")
    prop(ridge,"token","ModelStreamingMode",1)
    prop(ridge,"token","LevelOfDetail",4)
    terrain=item(ridge,"Folder","Folded slate and moss faces")
    surfaces=[]
    for face,tint,stone in ridge_facets():
        surfaces.append(face)
        triangle(terrain,*face,tint,name="Lanternwood slate face" if stone else "Lanternwood sage bench",
                 thickness=.17,material=rock if stone else grass,shadow=False)
    for slab in terrain.findall("Item"):
        if slab.findtext("Properties/string[@name='Name']")=="Lanternwood slate face":
            prop(slab,"string",variant_field,rock_variant)

    def model_piece(group,name,p,size,tint,*, material=None,**rotation):
        surface=material if material is not None else cedar if name.endswith("trunk") else grass
        piece=part(group,name,p,size,tint,material=surface,collide=False,**rotation)
        prop(piece,"bool","CastShadow",False)

    trees=item(ridge,"Folder","Lanternwood cedar groups")
    placements=((-153.4,53.2,.51),(-150.0,55.9,.55),(-146.3,58.4,.72),
                (-147.0,63.1,.66),(-142.6,65.5,.60),(-145.0,74.9,.57),
                (-140.8,81.4,.68),(-135.4,83.0,.55),(-137.7,92.2,.55),
                (-143.4,96.7,.63),(-149.6,101.3,.64),(-150.4,106.0,.49),
                (-174.7,61.3,.49),(-177.3,86.1,.51))
    for index,(x,z,scale) in enumerate(placements):
        y=ridge_surface_height(surfaces,x,z)
        hillside_cedar(model_piece,trees,x,y-.50,z,scale,index)

    west_groves=item(ridge,"Folder","Western cedar and amber groves")
    for i,(x,z,scale) in enumerate((
        (-181.8,53.9,.69),(-184.0,56.2,.88),(-177.9,57.7,.67),
        (-181.0,62.4,.84),(-187.7,65.2,.73),(-185.1,66.4,.76),
        (-190.8,72.2,.61),(-186.9,74.3,.79),(-180.4,77.2,1.02),(-177.7,79.8,.86),
        (-185.9,82.9,.78),(-183.2,86.5,.67),(-190.4,90.3,.93),(-193.3,92.6,.81),
        (-187.4,95.0,1.04),(-189.6,98.2,.89),(-198.1,101.2,.69),(-197.4,104.5,.67),
    )):
        y=ridge_surface_height(surfaces,x,z)
        hillside_cedar(model_piece,west_groves,x,y-.47,z,scale,i%12)

    lips=item(ridge,"Folder","Exposed slate ledges")
    for i,(x,z,width,depth) in enumerate(((-152.8,58.8,6.4,2.9),(-144.6,69.45,5.1,3.6),
                                          (-139.1,82.6,6.8,2.9),(-146.1,96.6,5.3,3.3))):
        y=ridge_surface_height(surfaces,x,z)
        model_piece(lips,"Broken pale slate shelf",(x,y+.12,z),(depth,.67,width),
                    ("92808B","9C8A90","8A7986")[i%3],material=slate,yaw=12+i*17,roll=-9)
        model_piece(lips,"Slate shelf base",(x-.72,y-.27,z+.19),(depth*.95,.54,width*.96),
                    "786D7E",material=slate,yaw=12+i*17,roll=-9)
    for i,(x,z,width,depth) in enumerate(((-180.8,58.70,5.82,2.47),(-183.85,67.15,7.20,2.78),
                                          (-183.7,78.6,6.95,3.13),(-190.65,94.75,8.65,3.20),
                                          (-193.65,101.10,7.05,2.79))):
        y=ridge_surface_height(surfaces,x,z)
        model_piece(lips,"Western split slate shelf",(x,y-.17,z),(depth,.67,width),
                    ("9E9096","96858F","8E8190")[i%3],material=slate,yaw=8+i*18,roll=11)
        model_piece(lips,"Western slate shelf root",(x+.52,y-.50,z+.20),(depth*.88,.52,width*.87),
                    "776C7D",material=slate,yaw=8+i*18,roll=11)

    # A small roofed lamp gives the middle distance a scale cue.
    x,z=-146.0,72.0
    pad_y=max(ridge_surface_height(surfaces,x+dx,z+dz)
              for dx,dz in ((-2,-1.35),(-2,1.35),(2,-1.35),(2,1.35)))+.15
    pad_bottom=min(ridge_surface_height(surfaces,x+dx,z+dz)
                   for dx,dz in ((-2,-1.35),(-2,1.35),(2,-1.35),(2,1.35)))-.22
    shelter=item(ridge,"Model","Lanternwood ridge shelter")
    model_piece(shelter,"Shelter fitted slate base",(x,(pad_y+pad_bottom)/2,z),
                (4.24,pad_y-pad_bottom,2.98),"857584",material=slate)
    for dx in (-1.36,1.36):
        for dz in (-.93,.93):
            model_piece(shelter,"Shelter cedar post",(x+dx,pad_y+1.36,z+dz),
                        (.27,2.72,.29),"925742",material=cedar)
        model_piece(shelter,"Shelter cedar header",(x+dx,pad_y+2.69,z),
                    (.25,.32,2.27),"764740",material=cedar)
    for dz,side in ((-.78,-1),(.78,1)):
        model_piece(shelter,"Shelter indigo eave",(x,pad_y+3.23,z+dz),(4.27,.28,1.91),
                    "444966",material=slate,pitch=side*19)
        model_piece(shelter,"Shelter copper eave lip",(x,pad_y+2.97,z+side*1.68),(4.32,.11,.15),
                    "B28A59",material=cedar)
    model_piece(shelter,"Shelter amber lantern",(x,pad_y+2.10,z+.38),(.53,.68,.53),"E8AA65",material=neon)
