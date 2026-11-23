"""A planted southeast foothill and a walkable overlook beside the city wall."""

from math import cos, hypot, radians, sin

from saltwind_high_walk import CEDARBANK_OPENING
from south_valley_backdrop import hillside_cedar, ridge_surface_height


# x positions for the west toe, crest and east toe, then the crest elevation.
# The west toe bends clear of the signed path and the city-wall pavilion.
ROWS = (
    (42.0, 98.0, 107.0, 122.0, -.28),
    (48.0, 98.0, 106.0, 123.0, 2.45),
    (55.2, 97.5, 101.9, 123.0, 7.90),
    (62.0, 99.5, 105.7, 126.0, 8.80),
    (69.4, 102.45, 108.5, 128.1, 7.15),
    (77.0, 103.50, 111.2, 129.9, 10.30),
    (85.7, 103.00, 111.0, 130.7, 10.95),
    (93.7, 98.30, 107.3, 131.6, 13.55),
    (101.3, 95.40, 104.2, 131.0, 11.90),
    (109.0, 96.50, 107.2, 132.2, 6.95),
    (118.0, 101.0, 117.0, 134.0, -.28),
)

PATH = (
    (87.50,.20,43.00), (92.60,.20,47.50), (93.00,.235,49.33), (93.80,1.20,53.00),
    (96.00,3.68,62.90), (98.90,5.74,71.80), (99.05,5.74,72.60),
)
PATH_WIDTH = 4.90
DECK = (96.33,104.05,71.73,78.65,5.78)


def hillside_faces():
    """Alternate the slate faces and the softer green shoulders across the two ribs."""
    sections = []
    for z, west, crest, east, height in ROWS:
        sections.append(tuple((crest+(crest-west if fraction < 0 else east-crest)*fraction,
                               -.28+(height+.28)*lift,z)
                              for fraction,lift in ((-1,0),(-.68,.23),(-.38,.59),(-.12,.92),
                                                    (0,1),(.26,.86),(.52,.48),(.77,.20),(1,0))))
    slate = ("8F7F85","A48C8A","796F7B","99878A")
    earth = ("798052","81875C","899063","747C52")
    for row,(near,far) in enumerate(zip(sections, sections[1:])):
        for lane,(a,b,c,d) in enumerate(zip(near,near[1:],far,far[1:])):
            exposed = lane in (1,2) and row in (1,2,5,6,7,8)
            color = slate if exposed else earth
            faces = ((a,b,c),(b,d,c)) if (row+lane)%2 else ((a,b,d),(a,d,c))
            for index,face in enumerate(faces):
                yield face,color[(row+lane+index*2)%len(color)],exposed


def build_cedarbank_rise(parent, *, item, prop, part, triangle, beam, route, path_edge,
                         garden_prop, sign, lamp, stone, slate, cedar, grass, rock, metal,
                         rock_variant, variant_field):
    model = item(parent,"Model","Cedarbank Rise")
    prop(model,"token","ModelStreamingMode",1)
    prop(model,"token","LevelOfDetail",4)
    hillside = item(model,"Folder","Folded slate foothill")
    faces = []
    for face,tint,exposed in hillside_faces():
        center = tuple(sum(values)/3 for values in zip(*face))
        # Extend each face slightly in its own plane to cover joins between wedges.
        fitted = tuple(tuple(origin+(value-origin)*1.014 for origin,value in zip(center,point))
                       for point in face)
        triangle(hillside,*fitted,tint,name="Cedarbank slate rib" if exposed else "Cedarbank grassy slope",
                 material=rock if exposed else grass,thickness=.14,shadow=False,collide=True)
        faces.append(face)
    for wedge in hillside.findall("Item[@class='WedgePart']"):
        if wedge.findtext("Properties/string[@name='Name']") == "Cedarbank slate rib":
            prop(wedge,"string",variant_field,rock_variant)

    def cedar_shape(group, name, p, extent, tint, **rotation):
        piece = part(group,name,p,extent,tint,material=cedar if name.endswith("trunk") else grass,
                     collide=False,**rotation)
        prop(piece,"bool","CastShadow",False)

    trees = item(model,"Folder","Cedarbank grove")
    for index,(x,z,scale) in enumerate(((102.4,55.8,.79),(106.4,59.8,.64),(110.75,53.15,.65),
              (113.8,72.9,.66),(117.2,75.0,.63),(109.4,84.4,.76),(114.7,87.2,.65),
              (103.8,94.8,.80),(108.5,96.1,.96),(111.8,98.9,.72),(100.9,103.9,.67),
              (106.4,107.5,.63),(118.4,105.6,.64),(119.0,110.2,.57))):
        hillside_cedar(cedar_shape,trees,x,ridge_surface_height(faces,x,z)-.29,z,scale,index)

    plants = item(model,"Folder","Cedarbank groundcover")
    for index,(x,z,scale) in enumerate(((99.1,50.15,.95),(104.8,49.0,1.05),(99.45,58.0,1.07),
              (102.45,63.8,1.05),(109.5,63.5,.83),(104.8,71.0,.98),(104.7,77.7,.81),
              (106.1,82.1,.96),(102.7,91.2,.88),(101.5,97.1,1.03),(104.0,105.7,1.0))):
        for key,dx,dz,ratio,tint in (("bankRock",.43,.26,.32,"A28A8B"),
                    ("meadowCover",.83,-.29,.23,"8DA06D"),("meadowGrass",.17,-.52,.25,"9C9C64"),
                    ("mossFlowers",-.20,.15,.18,"D4A4AD")):
            px,pz=x+dx,z+dz
            base=ridge_surface_height(faces,px,pz)-(.20 if key=="bankRock" else .08)
            garden_prop(plants,key,(px,base,pz),ratio*scale,index*53,tint)

    walk = item(model,"Model","Cedarbank garden walk")
    route(walk,"Cedarbank garden paving",PATH,PATH_WIDTH,"AA938C",surface=stone,
          stone_footings=False,join_overlap=.27,railings=False)
    west,east,north,south,top = DECK
    part(walk,"Cedarbank overlook deck",((west+east)/2,top-.34,(north+south)/2),
         (east-west,.68,south-north),"A39087",material=stone)
    for x,z,height in ((94.9,57.8,2.28),(97.4,66.3,4.38),
                       (97.23,72.57,top),(97.23,77.78,top),(102.8,77.78,top)):
        part(walk,"Cedarbank slate footing",(x,height/2-.26,z),(1.15,height+.16,1.3),
             "877985",material=slate,collide=False)
        part(walk,"Cedarbank timber bearing",(x,height-.49,z),(1.42,.40,1.50),
             "895B49",material=cedar,collide=False)

    def rail(a,b):
        for height in (.56,1.42):
            beam(walk,"Cedarbank cedar railing",(a[0],a[1]+height,a[2]),(b[0],b[1]+height,b[2]),
                 .22,"885140",collide=True)
        bays=max(1,round(hypot(b[0]-a[0],b[2]-a[2])/3.05))
        for index in range(bays):
            t=(index+.5)/bays
            x,y,z=(u+(v-u)*t for u,v in zip(a,b))
            part(walk,"Cedarbank square post",(x,y+.73,z),(.30,1.48,.30),
                 "815345",material=cedar,collide=False)
            part(walk,"Cedarbank rail cap",(x,y+1.49,z),(.39,.13,.39),
                 "B58A57",material=metal,collide=False)

    for side in (-1,1):
        edge=path_edge(PATH,side*2.27)
        for a,b in zip(edge[3:-1],edge[4:]):
            rail(a,b)
    low_opening, high_opening = CEDARBANK_OPENING
    for a,b in (
        ((west+.18,top,north+.24),(west+.18,top,south-.20)),
        ((west+.18,top,south-.20),(east-.20,top,south-.20)),
        ((east-.20,top,south-.20),(east-.20,top,high_opening)),
        ((east-.20,top,low_opening),(east-.20,top,north+.24)),
        ((east-.20,top,north+.24),(101.28,top,north+.24)),
    ):
        rail(a,b)
    x,z = 98.31,77.36
    yaw = 38
    seat=part(walk,"Cedarbank overlook seat",(x,top+.53,z),(3.40,.20,.86),
              "AE7D57",material=cedar,class_name="Seat",yaw=yaw)
    seat.find("Properties/bool[@name='CanTouch']").text="true"
    part(walk,"Cedarbank bench back",(x+.39*sin(radians(yaw)),top+.92,z+.39*cos(radians(yaw))),
         (3.42,.63,.16),"895642",material=cedar,collide=False,yaw=yaw)
    for y,x,z,scale in ((top,103.05,77.65,.48),(.15,92.95,44.45,.55)):
        part(walk,"Cedarbank lantern foot",(x,y+.36,z),(.69,.72,.68),
             "8B7883",material=slate,collide=False)
        lamp(walk,x,y+1.13,z,scale=scale,light=False)
    part(walk,"Cedarbank wayfinding post",(95.20,1.14,43.70),(.30,2.0,.30),
         "855444",material=cedar,collide=False)
    sign(walk,"CEDARBANK RISE",95.20,2.24,43.48,5.0,.91,yaw=180,tint="556748")
