"""Dressed stair shoulders and paper lanterns on the original Hall piers."""


def build_hall_stair_court(hall, *, item, part, prop, triangle, lantern_light,
                          garden_prop, slate, sandstone, cedar, brass, neon):
    stonework = item(hall, "Model", "Trophy Hall stair court masonry")
    prop(stonework, "token", "LevelOfDetail", 4)

    def detail(parent, name, position, size, tint, material):
        piece = part(parent,name,position,size,tint,material=material,collide=False)
        prop(piece,"bool","CastShadow",False)
        return piece

    def lantern(x, pier_y, z, scale, lit):
        fixture = item(stonework,"Model","Slate pier paper lantern")
        base = pier_y + .205

        def layer(name, offset, width, thickness, tint, material):
            return detail(fixture,name,(x,base+offset*scale,z),
                          (width*scale,thickness*scale,width*scale),tint,material)

        for name,offset,width,height,tint,material in (
            ("Upper sandstone lantern shoe",.080,1.20,.18,"BB9B8D",sandstone),
            ("Slate lantern shoe rim",.219,1.00,.095,"766474",slate),
            ("Bronze lantern sill",.320,1.04,.11,"986948",brass),
            ("Amber mulberry paper lantern",.870,.837,1.02,"FFC880",neon),
            ("Bronze lantern upper band",1.41,1.067,.115,"A57A50",brass),
            ("Weathered slate lantern eave",1.50,1.42,.121,"554D63",slate),
            ("Slate lantern roof shoulder",1.62,1.17,.140,"695968",slate),
            ("Slate lantern roof ridge",1.76,.86,.140,"6E616F",slate),
            ("Brass roof bead",1.865,.22,.128,"C49758",brass),
        ):
            layer(name,offset,width,height,tint,material)
        for dx in (-.50,.50):
            for dz in (-.50,.50):
                detail(fixture,"Lacquered lantern post",
                       (x+dx*scale,base+.86*scale,z+dz*scale),(.101*scale,1.13*scale,.101*scale),
                       "623D34",cedar)
        for v in (-1,1):
            for y in (.62,1.075):
                detail(fixture,"Cedar lantern lattice",(x,base+y*scale,z+v*.456*scale),
                       (.91*scale,.048*scale,.058*scale),"8A5138",cedar)
                detail(fixture,"Cedar side lattice",(x+v*.456*scale,base+y*scale,z),
                       (.058*scale,.048*scale,.91*scale),"8A5138",cedar)
            detail(fixture,"Cedar lantern mullion",(x,base+.86*scale,z+v*.457*scale),
                   (.052*scale,1.14*scale,.052*scale),"87533D",cedar)
        if lit:
            # Keep the existing local-light position underneath the taller paper body.
            mount = part(fixture,"Stair lantern light socket",(x,pier_y+.70,z),(.13,.13,.13),
                         "FFC880",material=neon,collide=False,transparency=1)
            prop(mount,"bool","CastShadow",False)
            lantern_light(mount,.65,light_profile=(1.08,7.35))

    for direction in (-1,1):
        x = direction * 7.43
        lantern(x,.91,-21.25,1.04,True)
        lantern(x,3.89,-29.15,.93,False)
        # Rock courses follow the outer side of the old coping line. Their tops
        # undulate slightly so the stair reads as a carved rise from the plaza.
        courses = ((-21.17,-24.63,.74,1.99),(-24.77,-29.09,2.00,3.68))
        if direction < 0:
            # Leave the west Jade crossing open between the two courses.
            courses = ((-21.17,-22.88,.74,1.36),(-25.58,-29.09,2.31,3.68))
        for index,(z_front,z_back,y_front,y_back) in enumerate(courses):
            front = (direction*7.06,y_front,z_front)
            back = (direction*7.06,y_back,z_back)
            outside_front = (direction*8.39,y_front-.09,z_front-.12)
            outside_back = (direction*8.29,y_back-.10,z_back+.12)
            lower_front = (direction*8.39,max(.19,y_front-.61),z_front-.30)
            lower_back = (direction*8.29,y_back-.60,z_back+.07)
            for a,b,c in ((front,back,outside_front),(back,outside_back,outside_front)):
                triangle(stonework,a,b,c,("A38B8D","AC9591")[index],
                         name="Dressed slate stair shoulder",material=slate,thickness=.13,
                         shadow=False,collide=False)
            for a,b,c in ((outside_front,outside_back,lower_front),
                          (outside_back,lower_back,lower_front)):
                triangle(stonework,a,b,c,("887782","91808A")[index],
                         name="Recessed stair shoulder face",material=slate,thickness=.13,
                         shadow=False,collide=False)
        for key,dx,y,z,scale,tint in (
            ("meadowCover",9.1,.18,-21.40,.145,"A0AF70"),
            ("meadowFlowers",9.43,.22,-21.90,.19,"E8B29B"),
            ("mossFlowers",9.22,.22,-22.32,.13,"D8A2B5"),
            ("grassBlade",9.43,.23,-23.02,.34,"DDC07D"),
        ):
            garden_prop(stonework,key,(direction*dx,y,z),scale,direction*47,tint)
