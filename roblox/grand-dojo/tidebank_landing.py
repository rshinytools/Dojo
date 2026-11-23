"""A graded swim-out and terraced breakwater beneath Tidewatch Walk."""
from math import atan2, degrees, hypot

from south_valley_backdrop import hillside_cedar, ridge_surface_height


NAME = "Tidebank Landing"
WIDTH = 4.40
PATH = ((263.00, .42, -2.40), (258.96, 1.06, -2.40),
        (250.20, 3.058, -2.40), (247.88, 3.058, -2.40))


def build_tidebank_landing(parent, *, item, prop, part, beam, route, sign, shoreline_slate,
                           garden_shelf, garden_prop, showcase_tree, festival_lantern,
                           slate, limestone, wood, grass, paving_variant, variant_field):
    landing = item(parent, "Model", NAME)
    prop(landing, "token", "ModelStreamingMode", 1)
    prop(landing, "token", "LevelOfDetail", 4)
    route(landing, "Tidebank shore ramp", PATH, WIDTH, "A69790", surface=limestone,
          stone_footings=False, join_overlap=.15, railings=False)

    for index, (start, finish) in enumerate(zip(PATH,PATH[1:])):
        length = hypot(finish[0]-start[0],finish[2]-start[2])
        rise = finish[1]-start[1]
        pitch = -degrees(atan2(rise, length))
        count = round(length/.86)
        for course in range(count):
            at = (course+.5)/count
            x,y,z = (a+(b-a)*at for a,b in zip(start,finish))
            seam = .25*(hypot(1,rise/length)-1)
            paver = part(landing, "Tidebank fitted stone course", (x,y+seam+.013,z),
                         (WIDTH-.079,.021,hypot(length,rise)/count-.055),
                         ("B6A299","A89A96","BCAC9F")[(index+course)%3],
                         yaw=-90, pitch=pitch, material=limestone, collide=False)
            prop(paver, "string", variant_field, paving_variant)
            prop(paver, "bool", "CastShadow", False)
        if index < 2:
            x,y,z = ((a+b)/2 for a,b in zip(start,finish))
            base, top = -3.7,y-.47
            part(landing, "Tidebank seated slate pier", (x,(top+base)/2,z),
                 (1.3,top-base,3.60),"827981",material=slate,collide=False)

    # The underwater mouth remains open from the front and both sides.
    for side in (-1,1):
        z = PATH[1][2]+side*2.055
        a,b = PATH[1:3]
        for lift,width in ((.54,.17),(1.28,.22)):
            beam(landing,"Tidebank upper handrail",(a[0]-.41,a[1]+.10+lift,z),
                 (b[0]-.05,b[1]+lift,z),width,"47716E",collide=True)
        for t in (.10,.52,.94):
            x,y = (a[k]+(b[k]-a[k])*t for k in (0,1))
            part(landing,"Tidebank teal newel",(x,y+.63,z),(.30,1.34,.32),"477471",material=wood)
            part(landing,"Tidebank brass cap",(x,y+1.33,z),(.40,.12,.42),"B9905B",collide=False)
        fixture_x,fixture_z = 251.62,PATH[1][2]+side*2.63
        part(landing,"Tidebank ramp lantern base",(fixture_x,2.69,fixture_z),(1.06,.69,.95),
             "887D83",material=slate,collide=False)
        festival_lantern(landing,fixture_x,3.61,fixture_z,.43,light=False)

    # Turn a shore sign toward returning swimmers from the east.
    post_x,post_z = 252.76,-6.98
    part(landing,"Shore sign slate footing",(post_x,-.49,post_z),(.91,5.61,.88),
         "817981",material=slate,collide=False)
    part(landing,"Shore sign cedar post",(post_x,3.46,post_z),(.33,2.48,.35),
         "70564B",material=wood,collide=False)
    sign(landing,"SHORE EXIT",post_x,4.47,post_z,4.05,1.07,69,"3A6B6B")

    breakwater = item(parent, "Model", "Tidebank planted breakwater")
    prop(breakwater, "token", "ModelStreamingMode", 1)
    prop(breakwater, "token", "LevelOfDetail", 4)
    for i,(x,z,crest,width,depth,yaw) in enumerate((
        (253.12,-8.62,2.71,5.46,6.1,21),
        (258.72,-11.53,3.04,6.23,5.6,54),
        (262.76,-16.7,5.34,9.2,7.2,49),
        (268.1,-22.95,6.36,11.24,9.2,69),
        (276.35,-26.1,8.01,11.65,9.65,36),
        (281.85,-32.2,5.49,10.27,8.52,83),
    )):
        shoreline_slate(breakwater,x,z,-3.7,width,depth,crest+3.7,yaw,shadow=False)
        terrace_y=-3.7+.82*(crest+3.7)
        garden_shelf(breakwater,x+.22,terrace_y+.18,z-.05,width*.57,depth*.53,
                     .36,"758759",grass,collide=False)
        for key,dx,dz,scale,tint in (
            ("bankRock",-.47,.58,.22,"9D8E95"),
            ("meadowCover",.58,.16,.19,"9AB66D"),
            ("meadowFlowers",-.59,-.47,.32,"E8BF91"),
            ("mossFlowers",.70,-.54,.16,"D4A2B7"),
            ("rockVine",.35,.97,.42,"99A875"),
        ):
            garden_prop(breakwater,key,(x+dx,terrace_y+.16,z+dz),scale,yaw+i*23,tint)
    for x,z,base,pink,scale,yaw in (
        (262.51,-17.38,3.87,False,.53,24),
        (276.12,-28.24,6.10,True,.61,52),
        (281.58,-32.35,4.06,False,.74,11),
    ):
        showcase_tree(breakwater,x,z,pink,scale,yaw,base,compact=True)

    # Distant sea stacks step down toward the harbor and stay beyond the return channel.
    stacks = item(parent, "Model", "Tideharbor distant sea stacks")
    prop(stacks, "token", "ModelStreamingMode", 1)
    prop(stacks, "token", "LevelOfDetail", 4)

    def cedar_piece(group, name, position, size, tint, **pose):
        piece=part(group, name, position, size, tint, material=wood if name.endswith("trunk") else grass,
                   collide=False, **pose)
        prop(piece,"bool","CastShadow",False)

    for index, (x,z,width,depth,height,yaw) in enumerate((
        (299.8,-53,15.0,13.6,14.2,18), (312.3,-63,21.8,20,25.1,47),
        (324.8,-68,18.1,16.4,19.9,71), (335.0,-74.8,13.1,14.4,10.2,40),
    )):
        cap=shoreline_slate(stacks,x,z,-3.65,width,depth,height+3.65,yaw,shadow=False)
        faces=[(cap[0],a,b) for a,b in zip(cap[1:-1],cap[2:])]
        top=ridge_surface_height(faces,x,z)
        garden_shelf(stacks,x,top+.18,z,width*.40,depth*.38,1.01,
                     "778362",grass,collide=False)
        for dx,dz,scale in ((-.95,.42,.55),(.86,-.38,.62)):
            root=ridge_surface_height(faces,x+dx,z+dz)
            hillside_cedar(cedar_piece,stacks,x+dx,max(root,top)-.18,z+dz,scale,index)
