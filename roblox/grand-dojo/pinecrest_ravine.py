"""Slate outcrops and conifer terraces beyond the Pinecrest Crossing guardrails."""

from math import cos, radians, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Apron contours rise out of the valley floor under the wooded shelves. The
# east edge remains below the playable trail and the rear runs into the ridge.
APRON = (
    ((-92,-5.4,-258),(-81,-5.4,-256),(-71,-5.5,-260),(-61,-5.6,-261),(-51,-5.5,-266),(-44,-5.5,-271)),
    ((-94,-2.8,-268),(-83,1.0,-266),(-73,2.5,-270),(-62,1.6,-272),(-53,.24,-275),(-45,-5.6,-279)),
    ((-94,2.3,-277),(-82,5.7,-276),(-72,5.4,-278),(-61,4.1,-281),(-55,2.2,-282),(-47,-4.9,-285)),
    ((-96,5.1,-286),(-84,7.1,-283),(-74,7.9,-286),(-62,6.8,-286),(-54,3.2,-286),(-48,-3.6,-289)),
    ((-98,9.3,-295),(-86,11.7,-292),(-76,10.8,-295),(-64,9.2,-294),(-56,5.7,-292),(-49,-3.5,-293)),
    ((-102,15.1,-308),(-90,20.6,-307),(-78,16.7,-305),(-65,12.1,-302),(-57,8.4,-298),(-51,-5.4,-300)),
)
CLIFF_SHELVES = (
    ("Slatepine lower shelf", -64.0, -300.0, 8.1, 4.4, 1.03),
    ("Slatepine upper shelf", -81.0, -303.8, 8.8, 4.9, 1.25),
)
TALUS = ("756576", "827481", "897B87", "80717D")
SHALE = ("817685", "91808B", "8B7888", "928591")
MOSS = ("586D49", "677B51", "76885C", "68794F")

# MichaelAngelist's free Stylized Pine Tree, Creator Store 10581320003.
PINE_MESH = "rbxassetid://6436440031"
PINE_ATLAS = "rbxassetid://6873539704"
PINE_TEXTURE = "rbxassetid://6341718741"
PINE_CROWNS = (
    ((0, 34.585, 0), (38.788, 62.739, 38.790)),
    ((.971, 54.133, -.433), (36.846, 62.739, 31.212)),
)


def build_pinecrest_ravine(parent, ridge_faces, *, item, prop, part, vector, asset, color,
                           triangle, garden_prop, cedar_part, rock, grass, cedar, plastic,
                           rock_variant, variant_field):
    ravine = item(parent, "Folder", "Pinecrest cedar ravine")

    def scenery_model(name):
        model = item(ravine, "Model", name)
        prop(model, "token", "ModelStreamingMode", 1)
        prop(model, "token", "LevelOfDetail", 4)
        return model

    def face(model, points, pigment, *, cover=False):
        first = len(model)
        triangle(model, *points, pigment, material=grass if cover else rock,
                 name="Ravine moss cap" if cover else "Weathered ravine slate",
                 thickness=.22, shadow=False, collide=False)
        if not cover:
            for wedge in model[first:]:
                prop(wedge, "string", variant_field, rock_variant)

    def planting(model, p, key, scale, yaw, color):
        first = len(model)
        garden_prop(model, key, p, scale, yaw, color)
        for mesh in model[first:]:
            shadow = mesh.find("Properties/bool[@name='CastShadow']")
            if shadow is not None:
                shadow.text = "false"

    def stylized_pine(model, x, y, z, height, yaw, tint):
        scale = height / 85.503
        t = radians(yaw)
        c, s = cos(t), sin(t)

        def position(offset):
            a, b, d = offset
            return (x+(a*c+d*s)*scale, y+b*scale, z+(-a*s+d*c)*scale)

        trunk = part(model, "Ravine pine trunk", position((1.433, 32.153, -1.122)),
                     tuple(n*scale for n in (64.305, 4.051, 3.384)), "6C5547",
                     material=cedar, shape=2, yaw=yaw, roll=90, collide=False)
        prop(trunk, "bool", "CastShadow", False)
        for offset, size in PINE_CROWNS:
            foliage = part(model, "Creator Store pine canopy", position(offset),
                           tuple(n*scale for n in size), "A3A2A5", yaw=yaw,
                           material=plastic, collide=False, class_name="MeshPart")
            vector(foliage, "Vector3", "InitialSize", ("X","Y","Z"), (9.5743, 15.4863, 9.5748))
            for key, value in (("CastShadow",False),("DoubleSided",True)):
                prop(foliage, "bool", key, value)
            prop(foliage, "token", "RenderFidelity", 0)
            asset(foliage, "MeshContent", PINE_MESH)
            asset(foliage, "TextureContent", PINE_TEXTURE)
            appearance = item(foliage, "SurfaceAppearance", "Pine needle atlas")
            prop(appearance, "token", "AlphaMode", 1)
            asset(appearance, "ColorMapContent", PINE_ATLAS)
            color(appearance, "Color", tint)

    bank = scenery_model("Wooded ravine apron")
    bank_faces = []
    for band, (near, far) in enumerate(zip(APRON, APRON[1:])):
        for i, (a, b, c, d) in enumerate(zip(near, near[1:], far, far[1:])):
            cover = not (band in (1, 3) and i in (1, 3, 4))
            palette = MOSS if cover else (TALUS if band == 1 else SHALE)
            for offset, vertices in enumerate(((a,b,c),(c,b,d))):
                face(bank, vertices, palette[(band + i//2 + offset) % len(palette)], cover=cover)
                bank_faces.append(vertices)
    for i, (x, z, scale) in enumerate(((-59.1,-279.0,.73),(-63.6,-282.9,.80),
                                       (-72.5,-284.9,.91),(-75.8,-289.3,.98),
                                       (-68.1,-290.2,.66),(-81.1,-291.7,.80))):
        y = ridge_surface_height(bank_faces,x,z)
        if i in (0, 1, 3, 5):
            stylized_pine(bank,x,y-.20,z,10.4*scale,41+i*57,
                          ("B7C09B","C1C995","D0BF9D")[i % 3])
        else:
            hillside_cedar(cedar_part,bank,x,y-.22,z,scale,i)
    for i, (key, x, z, scale, tint) in enumerate((
        ("bankRock",-60.6,-280.6,.52,"988791"),
        ("meadowGrass",-56.7,-277.3,.23,"ABAD69"),
        ("mossFlowers",-57.4,-273.8,.32,"C7A394"),
        ("bankRock",-68.5,-282.4,.59,"B3A0A1"),
        ("meadowCover",-63.3,-280.3,.31,"91A35D"),
        ("meadowFlowers",-65.5,-276.2,.39,"CDBBA1"),
        ("bankRock",-75.1,-287.6,.81,"9F8F9A"),
        ("meadowGrass",-69.4,-287.4,.28,"A8AD69"),
        ("meadowCover",-76.8,-285.9,.35,"93A05D"),
        ("rockVine",-80.7,-293.6,.50,"819A69"),
    )):
        y = ridge_surface_height(bank_faces,x,z)
        planting(bank,(x,y-.08,z),key,scale,27+i*67,tint)

    for index, (name, x, z, width, reach, tree_scale) in enumerate(CLIFF_SHELVES):
        model = scenery_model(name)
        shelf_y = ridge_surface_height(ridge_faces, x, z)
        back = (x, shelf_y+.17, z-.43)
        left = (x-width*.43, shelf_y-.28, z+reach*.54)
        nose = (x+width*.09, shelf_y-.12, z+reach)
        right = (x+width*.49, shelf_y+.14, z+reach*.42)
        rim = (left, nose, right)
        for i, (a, b) in enumerate(((back, left), (left, nose), (nose, right), (right, back))):
            face(model, ((x+.36,shelf_y+.18,z+reach*.48), a, b), MOSS[(index+i) % len(MOSS)], cover=True)
        lower = []
        for px, py, pz in rim:
            foot_z = pz - reach*.71
            ridge_y = ridge_surface_height(ridge_faces, px, foot_z)
            lower.append((px, min(py-1.36, ridge_y-.62), foot_z))
        for i, ((a, b), (c, d)) in enumerate(zip(zip(rim, rim[1:]), zip(lower, lower[1:]))):
            face(model, (a, b, c), SHALE[(index+i) % len(SHALE)])
            face(model, (c, b, d), TALUS[(index+i) % len(TALUS)])
        hillside_cedar(cedar_part, model, x+.34, shelf_y-.08, z+reach*.42, tree_scale, 4+index)
        hillside_cedar(cedar_part, model, x-width*.26, shelf_y-.14, z+reach*.49, tree_scale*.66, 5+index)
        for i, (key, u, v, scale, tint) in enumerate((
            ("bankRock", .27, .53, .26, "AA929B"),
            ("meadowGrass", .14, .72, .19, "A2AD6F"),
            ("rockVine", -.29, .65, .57, "95A366"),
        )):
            planting(model, (x+width*u,shelf_y-.22,z+reach*v), key, scale, 48+53*i, tint)
