"""Street-height timber detail and masonry for the east harbor façades."""


def build_tideharbor_waterfront(parent, *, item, prop, part, beam, slate,
                               limestone, wood, clay, metal, neon, cedar_variant,
                               stone_variant, roof_variant, variant_field):
    addition=item(parent,"Model","Tideharbor waterfront facades")
    prop(addition,"token","ModelStreamingMode",1)
    prop(addition,"token","LevelOfDetail",4)
    variants={wood:cedar_variant,slate:stone_variant,clay:roof_variant}

    def facade(name, wall_x, width, center_z, top, window_rows, brace_offsets):
        facade_model=item(addition,"Model",name)
        prop(facade_model,"token","LevelOfDetail",4)

        def point(offset,y,depth):
            return wall_x+depth,y,center_z-offset

        def trim(name,offset,y,depth,size,tint,material=wood,**pose):
            detail=part(facade_model,name,point(offset,y,depth),size,tint,yaw=90,
                        material=material,collide=False,**pose)
            prop(detail,"bool","CastShadow",False)
            if material in variants:
                prop(detail,"string",variant_field,variants[material])
            return detail

        for offset in brace_offsets:
            trim("Waterfront post slate shoe",offset,3.91,.13,(.60,.98,.25),"8F818A",slate)
            trim("Waterfront lacquered post",offset,(top+4.20)/2,.188,(.29,top-4.20,.36),"367273")
            for y in (5.15,top-.87):
                trim("Waterfront post brass tie",offset,y,.37,(.34,.12,.047),"A88152",metal)
        for y,depth,height,tint in ((4.54,.14,.23,"896352"),(6.04,.16,.19,"65908A"),
                                    (top-1.38,.17,.31,"386A6B"),(top-.48,.21,.45,"568582")):
            trim("Waterfront continuous cedar rail",0,y,depth,(width,height,.34),tint)

        block_width=width/5
        for col in range(5):
            offset=(col-2)*block_width
            trim("Waterfront courtyard slate skirt",offset,3.91,.105,
                 (block_width-.065,.87,.195),("9D8B8B","8B818A","A1918E")[col%3],slate)

        for offset,y in window_rows:
            trim("Window dark reveal",offset,y,.079,(3.17,3.55,.143),"4A504E",slate)
            trim("Window warm paper",offset,y,.171,(2.02,2.81,.04),"E5B37B",neon)
            for dx in (-.99,-.32,.32,.99):
                trim("Harbor window mullion",offset+dx,y,.234,(.13,3.01,.135),"4F4F46")
            for oy in (-1.42,-.48,.45,1.42):
                trim("Harbor window cross lattice",offset,y+oy,.24,(2.10,.117,.128),"5D5649")
            for side in (-1,1):
                x=offset+side*1.32
                trim("Teal plank shutter",x,y,.218,(.47,3.02,.20),"497C7B")
                for dy in (-.98,0,.98):
                    trim("Shutter cedar louvre",x,y+dy,.331,(.50,.17,.108),"588985")
                trim("Shutter bronze pull",x-side*.11,y,.399,(.09,.29,.073),"C2A16B",metal)
            trim("Harbor window sandstone sill",offset,y-1.63,.19,(3.35,.25,.35),"B19A8D",limestone)
            trim("Harbor window eyebrow",offset,y+1.64,.305,(3.36,.24,.58),"444964",clay,pitch=14)
            trim("Window eyebrow ochre lip",offset,y+1.57,.596,(3.30,.085,.094),"B78559")

        return facade_model,point,trim

    wall,point,trim=facade("East harbor storehouse dress",243.5,12.58,6.00,14.42,
                          ((3.49,8.60),(-1.46,8.60)),(-5.92,-.07,5.91))
    # A coarse, loosely draped drying net anchors the lower waterfront wall.
    net=item(wall,"Model","Harbor drying net")
    def cord(name,a,b,gauge,tint):
        strand=beam(net,name,point(*a),point(*b),gauge,tint)
        prop(strand,"bool","CastShadow",False)
    net_points=[
        [(-4.66+col*.51,5.88-row*.29
          +.13*(abs(col-3)/3)**2*row/4,.27+.06*row/4)
         for col in range(7)] for row in range(5)
    ]
    cord("Net softened upper rope",(-4.80,5.90,.27),(-1.42,5.90,.27),.062,"A8805A")
    for i,row in enumerate(net_points):
        for j,p in enumerate(row[:-1]):
            cord("Net cross weave",p,row[j+1],.026,"9A7A5D")
            if i<4:
                cord("Net hanging weave",p,net_points[i+1][j+1],.024,"A48465")
        if i<4:
            cord("Net edge rope",row[-1],net_points[i+1][-1],.043,"95785C")
    for index,offset in enumerate((-4.61,-3.89,-3.03,-2.21,-1.57)):
        trim("Net wooden float",offset,5.91,.308,(.193,.20,.177),
             ("AD7458","CF9E69","8A6255")[index%3],shape=0)
    facade("Harbor House east dress",230.5,13.78,-2.00,16.42,
           ((4.39,9.12),(-1.83,9.12)),(-5.95,.60,6.35))

    # Fit shallow stone faces to the seawall on either side of the marked ramp.
    bank=item(addition,"Model","Shore exit dressed seawall")
    prop(bank,"token","LevelOfDetail",4)
    for left,right in ((-13.64,-5.47),(1.07,14.69)):
        for row, (height,y) in enumerate(((1.32,-.66),(1.11,.59),(1.02,1.68),(.59,2.52))):
            columns=round((right-left)/2.33)
            span=(right-left)/columns
            for column in range(columns):
                z=left+(column+.5)*span
                tile=part(bank,"Waterfront seawall slate block",(250.064+(row%2)*.026,y,z),
                          (.218,height-.034,span-.072),
                          ("858D85","92998B","A49792","83888C")[(row+column*3)%4],
                          material=slate,collide=False)
                prop(tile,"string",variant_field,stone_variant)
                prop(tile,"bool","CastShadow",False)
        coping=part(bank,"Beveled seawall coping",(250.091,2.904,(left+right)/2),
                    (.28,.142,right-left),"B7A89C",material=limestone,collide=False)
        prop(coping,"bool","CastShadow",False)
