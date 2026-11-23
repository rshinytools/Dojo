"""The Trophy Hall's split roof silhouette and dressed arrival threshold."""

from math import atan2, degrees, hypot


def build_hall_crown_roof(parent, eave_y, *, item, prop, part, triangle, clay, brass,
                          variant_field, tile_variant, brass_variant):
    """Build a tapered ridge above broad, upswept eaves."""
    crown = item(parent, "Model", "Trophy Hall raised crown roof")
    prop(crown, "token", "LevelOfDetail", 4)
    center_z = -41.15
    half_depth = 15.44
    rows = (
        (1, 0, 20.30, 3.60),
        (.79, .81, 19.90, 2.35),
        (.56, 2.86, 19.03, 1.46),
        (.33, 5.63, 17.68, .96),
        (.14, 8.94, 15.84, 1.08),
        (0, 11.90, 14.31, 1.39),
    )
    lanes = ((-1, 1), (-.75, .34), (-.44, .04), (.44, .04), (.75, .34), (1, 1))
    courses = ("334A88", "394F8F", "425B9B", "4964A3", "506CA9")
    shade_courses = ("303F73", "37487D", "3B4F88", "435991", "49629A")

    def surface(row, across, sweep, side, lift=0):
        depth, height, half_width, end_rise = row
        return (across * half_width, eave_y + height + sweep * end_rise + lift,
                center_z + side * depth * half_depth)

    def tile(name, a, b, diameter, tint, *, metal=False):
        dx, dy, dz = (end - start for start, end in zip(a, b))
        center = tuple((start + end) / 2 for start, end in zip(a, b))
        node = part(crown, name, center, (hypot(dx, dy, dz) + .055, diameter, diameter), tint,
                    yaw=degrees(atan2(dx,dz))-90, roll=degrees(atan2(dy,hypot(dx,dz))),
                    shape=2, material=brass if metal else clay, collide=False)
        prop(node, "bool", "CastShadow", False)
        prop(node, "string", variant_field, brass_variant if metal else tile_variant)

    def ceramic_panel(a, b, c, tint):
        start = len(crown)
        triangle(crown, a,b,c,tint,name="Hipped indigo roof panel",
                 thickness=.31,material=clay,shadow=False)
        for piece in list(crown)[start:]:
            prop(piece, "string", variant_field, tile_variant)

    for direction in (-1, 1):
        palette = courses if direction == 1 else shade_courses
        for band, (lower, upper) in enumerate(zip(rows, rows[1:])):
            for (left, left_lift), (right, right_lift) in zip(lanes, lanes[1:]):
                a = surface(lower, left, left_lift, direction)
                b = surface(lower, right, right_lift, direction)
                c = surface(upper, right, right_lift, direction)
                d = surface(upper, left, left_lift, direction)
                ceramic_panel(a,b,c,palette[band])
                ceramic_panel(a,c,d,palette[band])
                if band == 0:
                    tile("Sculpted indigo eave lip", a, b, .64, "3B548E")
                    tile("Gilded lower eave line", tuple(v-.33 if axis==1 else v for axis,v in enumerate(a)),
                         tuple(v-.33 if axis==1 else v for axis,v in enumerate(b)), .17, "C48952", metal=True)
            if direction == 1 or band == 0:
                for run in range(17):
                    across = (run-8)*.116
                    sweep = next(
                        lo_lift+(hi_lift-lo_lift)*(across-lo)/(hi-lo)
                        for (lo,lo_lift),(hi,hi_lift) in zip(lanes,lanes[1:])
                        if lo <= across <= hi
                    )
                    a=surface(lower, across, sweep, direction, .20)
                    b=surface(upper, across, sweep, direction, .20)
                    tile("Raised ceramic barrel tile", a, b, .26, ("637CB1","536BA2","586EAB")[run%3])
            for end in (-1, 1):
                tile("Rounded indigo hip", surface(lower, end, 1, direction, .21),
                     surface(upper, end, 1, direction, .21), .55, "48649D")
                return_eave=(end*20.32,eave_y+1.70,center_z)
                ceramic_panel(return_eave,surface(lower,end,1,direction),
                              surface(upper,end,1,direction),shade_courses[band])

        for end in (-1,1):
            x,y,z=surface(rows[0],end,1,direction)
            tip=(x+end*1.08,y+.83,z+direction*.20)
            tile("Round side eave", (x,y,z),(end*20.32,eave_y+1.70,center_z),.53,"414F84")
            tile("Oxidized bronze eave tip", (x-end*.47,y-.19,z), tip, .42, "C68F4D", metal=True)
            tile("Lit eave tip facet", tip, (tip[0]+end*.15,tip[1]+.25,tip[2]), .28, "F1C178", metal=True)

    ridge = tuple(surface(rows[-1], x, lift, 1, .21) for x,lift in lanes)
    for a,b in zip(ridge,ridge[1:]):
        tile("Arcing blue ridge coping", a, b, .73, "354878")
    for end in (-1,1):
        x,y,z=surface(rows[-1],end,1,1,.20)
        swept_tip=((x-end*1.04,y-.37,z),(x+end*.32,y+.16,z),
                   (x+end*.86,y+.79,z),(x+end*.94,y+1.66,z))
        for a,b,diameter,tint in zip(swept_tip,swept_tip[1:],(.72,.56,.35),("C48642","E5A653","F3CB82")):
            tile("Signature gilded crown hook", a, b, diameter, tint, metal=True)


def build_hall_wing_eave(parent, x, eave_y, *, item, prop, part, swept_roof, cedar):
    """Pull the lower gallery gables forward without covering the central title."""
    wing = item(parent, "Model", "Trophy Hall forward gallery eave")
    prop(wing, "token", "LevelOfDetail", 4)
    swept_roof(wing, x, eave_y+.08, -32.71, 21.02, 13.78, 6.47, fine_tiles=False,
               signature=True, corner_sweep=1.52, ridge_finial_scale=1.26)
    for across in (-7.01,-3.52,0,3.52,7.01):
        arm = part(wing, "Under eave rafter tail", (x+across, eave_y-.43, -27.97),
                   (.49,.37,4.82), "945438", material=cedar, collide=False, pitch=-5)
        prop(arm, "bool", "CastShadow", False)


def build_hall_arrival_mass(hall, *, item, prop, part, beam, triangle, slate, sandstone,
                            cedar, brass, neon, variant_field, stone_variant, brass_variant):
    """Layer the stone flanks and add a deep amber reveal around the open doorway."""
    mass = item(hall, "Model", "Trophy Hall raised forecourt and amber portal")
    prop(mass, "token", "LevelOfDetail", 4)

    def layer(name, center, size, tint, material, *, roll=0):
        node = part(mass, name, center, size, tint, material=material, collide=False, roll=roll)
        prop(node, "bool", "CastShadow", False)
        if material in (slate, sandstone, brass):
            prop(node, "string", variant_field, brass_variant if material == brass else stone_variant)

    for side in (-1, 1):
        # The west landing crosses the stair shoulder between its two cheeks.
        # Both cheeks sit outside the unchanged 13-stud stair and east ramp.
        ranges = ((-22.81,-20.91,1.26),(-29.47,-25.76,3.42))
        for z0,z1,top in ranges:
            x=side*8.69
            rows=max(2, round(top/.65))
            depth=z1-z0
            for row in range(rows):
                low=.14+row*(top-.20)/rows
                high=.14+(row+1)*(top-.20)/rows
                size_x=3.16-(row%2)*.16
                center_y=(low+high)/2
                front=z1-.05*row
                layer("Stair flank ashlar sill", (x,center_y,(z0+front)/2),
                      (size_x,high-low-.044,front-z0), ("877785","9E888E","917D87")[row%3], slate)
                layer("Projected slate face bevel", (x,high-.055,front+.037),
                      (size_x+.07,.095,.11), ("A18A8F","AA9396")[row%2], slate)
                layer("Recessed stair flank seam", (x+side*.17,center_y,front+.087),
                      (.063,high-low-.145,.07), "766573", slate)
            layer("Honed stair flank coping", (x,top+.018,(z0+z1)/2-.095),
                  (3.30,.154,depth+.13), "BFA197", sandstone)

        # The visual jambs stay outside the original collision and optical aperture.
        for name,x,y,z,size,tint,material in (
            ("Portal lacquer cheek",4.95,7.32,-31.82,(1.02,7.21,1.04),"813F2F",cedar),
            ("Portal honey outer bead",5.50,7.31,-31.24,(.17,6.76,.13),"C3894E",brass),
            ("Inset portal lacquer lining",3.25,7.29,-32.08,(.10,6.75,1.72),"593525",cedar),
            ("Portal inner reflected bounce",3.20,7.46,-32.42,(.075,5.88,.78),"B46C43",cedar),
            ("Dressed doorway stone cheek",4.95,3.94,-31.75,(1.24,.48,1.28),"98828B",slate),
            ("Honed doorway foot cap",4.95,4.208,-31.75,(1.31,.137,1.34),"BB9889",sandstone),
        ):
            layer(name,(side*x,y,z),size,tint,material)

    # A single broad amber fan is legible across the plaza. The existing lanterns
    # provide light and the center door and display remain fully open.
    base=11.29
    face_z=-31.19
    fan=((-3.37,base),(-2.92,base+.56),(-1.82,base+1.00),(0,base+1.15),
         (1.82,base+1.00),(2.92,base+.56),(3.37,base))
    for i, ((x0,y0),(x1,y1)) in enumerate(zip(fan,fan[1:])):
        shade="FFD18A" if i in (2,3) else "F6AC5B"
        triangle(mass,(0,base-.026,face_z),(x0,y0,face_z),(x1,y1,face_z),shade,
                 name="Amber fan transom pane",thickness=.106,material=neon,shadow=False)
        edge=beam(mass,"Carved cedar transom arch",(x0,y0,face_z+.083),(x1,y1,face_z+.083),
                  .141,"A65F3B")
        prop(edge,"bool","CastShadow",False)
    for x,y in fan[1:-1]:
        rib = beam(mass, "Amber fan transom muntin", (x*.71,base,face_z+.112), (x,y,face_z+.112),
                   .073, "975235")
        prop(rib, "bool", "CastShadow", False)
    layer("Carved entrance lintel front", (0,11.211,face_z+.12), (7.05,.208,.24), "99553A", cedar)
    layer("Bronze threshold highlight", (0,11.334,face_z+.236), (7.11,.066,.092), "C38B51", brass)
