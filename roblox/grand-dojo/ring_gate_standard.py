"""Original woven reed standards at the Fighting Ring's entry piers."""

from math import cos, radians, sin


def build_ring_gate_standard(parent, x, z, *, column_x, item, part, prop, beam, triangle,
                             fabric, wood, brass, fabric_variant, variant_field, height_gain):
    standard = item(parent, "Model", "Arena procession standard")
    yaw = -9
    c, s = cos(radians(yaw)), sin(radians(yaw))
    heights = (10.24, 7.66, 4.12)
    columns = (-2.08, -1.68, -.82, .14, 1.13, 1.70, 2.08)
    folds = (
        (.02, .07, -.04, .13, -.06, .055, -.01),
        (.08, .17, -.08, .18, -.105, .10, .055),
        (.07, .15, -.065, .145, -.085, .11, .05),
    )
    dyes = ("71303A", "813239", "763039", "94413E", "81343B", "79313A")

    def mounted_height(y):
        return y + height_gain * (y - 3.14) / (10.51 - 3.14)

    def at(dx, y, depth=0):
        return x + c * dx + s * depth, mounted_height(y), z - s * dx + c * depth

    def cloth(a,b,c,tint,name):
        start = len(standard)
        triangle(standard,a,b,c,tint,name=name,material=fabric,
                 thickness=.062,collide=False,shadow=False)
        for piece in list(standard)[start:]:
            prop(piece,"string",variant_field,fabric_variant)

    grid = [[at(dx, y, depth) for dx, depth in zip(columns, row)]
            for y, row in zip(heights, folds)]
    for upper, lower in zip(grid, grid[1:]):
        for index, (a,b,corner,d) in enumerate(zip(upper,upper[1:],lower,lower[1:])):
            cloth(a,corner,b,dyes[index],"Woven vermilion fold")
            cloth(b,corner,d,dyes[index],"Woven vermilion fold")
    tip = at(.06,3.14,.14)
    for index,(a,b) in enumerate(zip(grid[-1],grid[-1][1:])):
        cloth(a,tip,b,dyes[index],"Folded pointed hem")

    def trim(name, a, b, width, tint):
        piece = beam(standard,name,a,b,width,tint)
        prop(piece,"bool","CastShadow",False)

    for side in (-1,1):
        dx = 1.92 * side
        binding = [at(dx, height, depth) for height,depth in
                   ((10.18,.135),(7.66,.221),(4.21,.19))]
        for a,b in zip(binding,binding[1:]):
            trim("Sewn gilt edge",a,b,.066,"D5A057")
        trim("Sewn gilt hem",binding[-1],at(.055,3.31,.23),.066,"D5A057")
        bracket_x = column_x + side * .52
        trim("Cedar mounting return",(bracket_x,mounted_height(10.48),z-.53),
             at((bracket_x-x)/c,10.51,.064),.16,"A66D44")
        strap = part(standard,"Woven suspension loop",at(side*1.55,10.33,.074),
                     (.19,.31,.19),"9C4032",yaw=yaw,material=fabric,collide=False)
        prop(strap,"string",variant_field,fabric_variant)
        part(standard,"Brass rod finial",at(side*2.19,10.51,.064),
             (.22,.25,.25),"DBAA69",yaw=yaw,material=brass,collide=False)
    part(standard,"Cedar standard rod",at(0,10.51,.064),(4.36,.18,.17),
         "785043",yaw=yaw,material=wood,collide=False)

    # Broad gold stitches stay readable across the courtyard.
    root = at(-.78,4.90,.254)
    for elbow, tip, leaf_roll in (
        ((-.65,6.23),(-.40,7.65),-14),
        ((-.27,6.48),(.31,8.35),-19),
        ((.07,6.31),(1.12,7.80),-36),
    ):
        elbow_x,elbow_y=elbow
        tip_x,tip_y=tip
        trim("Gold reed stitch",root,at(elbow_x,elbow_y,.254),.066,"DAAA63")
        trim("Gold reed stitch",at(elbow_x,elbow_y,.254),at(tip_x,tip_y,.254),
             .055,"E4B96E")
        for step,(length,width,color) in enumerate(((.51,.19,"F4D497"),(.42,.16,"E5B96C"),
                                                    (.30,.13,"D5A15E"))):
            heading = radians(-leaf_roll)
            part(standard,"Embroidered reed seed",
                 at(tip_x-step*.19*sin(heading),tip_y-step*.19*cos(heading),.275),
                 (width,length,.074),color,yaw=yaw,roll=leaf_roll,shape=0,
                 material=fabric,collide=False)
    for piece in standard.findall("Item"):
        if piece.find("Properties/bool[@name='CastShadow']") is None:
            prop(piece,"bool","CastShadow",False)
