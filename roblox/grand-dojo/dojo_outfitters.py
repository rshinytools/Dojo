"""Build the Reed Market cosmetics shop using native Studio geometry."""


def build_dojo_outfitters(city, *, item, prop, part, sign, townsperson):
    shop = item(city, "Model", "Dojo Outfitters")
    prop(shop, "token", "ModelStreamingMode", 1)
    x, y, z = 73.4, .15, -33.4
    cedar = "803B27"
    dark_wood = "4A2A20"
    brass = "CD8D44"
    jade = "2F7971"
    jade_light = "70A99A"
    roof = "174950"
    slate = 800
    limestone = 820
    wood = 528
    fabric = 1312
    metal = 1088
    clay_tile = 2307

    def piece(name, offset, size, tint, *, material=272, collide=False, shadow=True, **options):
        dx, dy, dz = offset
        obj = part(shop, name, (x + dx, y + dy, z + dz), size, tint,
                   material=material, collide=collide, **options)
        if not shadow:
            prop(obj, "bool", "CastShadow", False)
        return obj

    piece("Limestone foundation", (0, -.06, 0), (9.2, .29, 6.4), "A48271", material=limestone, collide=True)
    piece("Sandstone threshold", (-2.5, .03, 4.35), (4.8, .1, 3.6), "B58E78", material=slate, collide=True)
    piece("Cornerstone apron", (0, .08, 3.05), (8.5, .15, .85), "BA9A82", material=slate, collide=True)
    piece("Cedar floor", (0, .09, -.10), (8.8, .14, 5.75), "9A6748", material=wood, collide=True)

    for side in (-1, 1):
        for depth in (-2.65, 2.62):
            post = side * 4.11
            piece("Cedar column", (post, 2.34, depth), (.46, 4.45, .46), cedar, material=wood, collide=True)
            piece("Carved stone column foot", (post, .34, depth), (.74, .48, .74), "745566", material=slate)
            for height in (.61, 4.2):
                piece("Brass post collar", (post, height, depth), (.53, .13, .53), brass, material=metal)
        piece("Timber eave bracket", (side * 3.79, 4.13, 2.61), (.87, .21, .31), cedar, roll=37 * side)
        piece("Narrow shop pennant", (side * 4.09, 2.59, 2.918), (.48, 1.01, .06), jade, material=fabric)
        piece("Pointed pennant hem", (side * 4.09, 2.11, 2.925), (.338, .338, .06), jade,
              roll=45, material=fabric, shadow=False)
        piece("Pennant stitched clasp", (side * 4.09, 2.65, 2.96), (.16, .16, .035), jade_light,
              roll=45, material=fabric, shadow=False)
        piece("Paper lantern glow", (side * 3.7, 3.55, 3.0), (.72, .62, .62), "FFCC77", shape=2,
              roll=90, material=288, shadow=False)
        for height in (3.16, 3.94):
            piece("Lantern cap", (side * 3.7, height, 3.0), (.12, .65, .65), dark_wood, shape=2, roll=90)
        piece("Lantern hanger", (side * 3.7, 4.12, 3.0), (.11, .28, .11), dark_wood)
        for height in (3.39, 3.55, 3.71):
            piece("Lantern rib", (side * 3.7, height, 3.0), (.025, .635, .635), "E4A463", shape=2,
                  roll=90, shadow=False)

    piece("Planked stockroom wall", (0, 2.31, -2.76), (8.37, 4.28, .21), dark_wood, material=wood, collide=True)
    piece("Stockroom lintel", (0, 4.28, -2.57), (8.44, .25, .27), cedar, material=wood)
    piece("Stockroom wainscot", (0, 1.06, -2.57), (8.28, 1.75, .21), "2C534F", material=wood)
    piece("Stockroom shelf", (0, 1.48, -2.26), (7.85, .19, .84), cedar, material=wood)
    for side in (-1, 1):
        piece("Jade side panel", (side * 4.08, 1.0, -.12), (.28, 1.56, 5.36), jade, material=wood, collide=True)
        piece("Side handrail", (side * 4.08, 1.84, -.12), (.37, .16, 5.36), dark_wood, material=wood)
        piece("Side panel brass line", (side * 4.23, 1.55, -.12), (.06, .14, 5.27), brass, material=metal)
        piece("Outer reed panel", (side * 4.23, 1.04, -.14), (.045, .75, 3.58), "4C8478", material=fabric)

    for index, (cloth, lining) in enumerate((("C16A44", "F4C589"), (jade, "CFD6AD"), ("7C4B6C", "EEB394"))):
        hanger = (index - 1) * 2.25
        piece("Hanging sash rail", (hanger, 3.76, -2.35), (1.74, .11, .12), brass, material=metal)
        piece("Folded sash on display", (hanger, 2.95, -2.21), (1.25, 1.57, .12), cloth, material=fabric)
        piece("Tapered sash end", (hanger, 2.19, -2.196), (.77, .77, .13), cloth, material=fabric, roll=45)
        for edge in (-1, 1):
            piece("Stitched sash edging", (hanger + edge * .48, 2.99, -2.135), (.065, 1.45, .035), lining,
                  material=fabric, shadow=False)
        piece("Embroidered sash diamond", (hanger, 3.05, -2.13), (.38, .38, .035), lining, roll=45,
              material=fabric, shadow=False)

    piece("Shop counter base", (0, .81, 2.24), (6.97, 1.43, 1.07), dark_wood, material=wood, collide=True)
    counter = piece("ShopCounter", (0, 1.57, 2.21), (7.18, .27, 1.33), "B4784D", material=wood, collide=True)
    piece("Counter's brass edge", (0, 1.51, 2.91), (7.12, .085, .075), brass, material=metal)
    for index in (-1, 0, 1):
        piece("Counter front lacquer panel", (index * 2.27, .87, 2.80), (2.12, .87, .09), jade, material=wood)
        piece("Counter front inlay", (index * 2.27, .87, 2.865), (1.85, .55, .06), "245951", material=wood)
        piece("Brass drawer diamond", (index * 2.27, .87, 2.91), (.25, .25, .06), brass, material=metal, roll=45)

    for index, cloth in enumerate(("4C6657", "98A277", "E5A55C")):
        piece("Folded cloth stock", (-2.45, 1.77 + index * .115, 2.26 - index * .09),
              (1.06 - index * .10, .15, .64), cloth, material=fabric, yaw=index * 6 - 10)
    piece("Display stand", (2.35, 1.79, 2.18), (.76, .17, .69), dark_wood, material=wood)
    piece("Woven sash on counter", (2.35, 2.10, 2.18), (.64, .47, .37), jade, material=fabric, roll=-14)
    piece("Shop sample clasp", (2.34, 2.12, 2.385), (.21, .21, .055), brass, material=metal, roll=45)

    piece("Painted shop header", (0, 4.53, 2.55), (8.87, .44, .43), cedar, material=wood)
    piece("Painted fascia shadow", (0, 4.55, 2.80), (8.87, .15, .14), jade, material=wood)
    piece("Cedar roof base", (0, 4.81, -.03), (9.05, .23, 6.43), dark_wood, material=wood)
    for side in (-1, 1):
        piece("Glazed clay roof slope", (0, 5.29, side * 1.76), (9.17, .215, 3.5), roof,
              pitch=side * 20, material=clay_tile)
        piece("Teal eave edge", (0, 4.76, side * 3.39), (9.22, .20, .22), jade)
        for x_offset in (-4.37, -3.48, -2.61, -1.74, -.87, 0, .87, 1.74, 2.61, 3.48, 4.37):
            piece("Roof tile rib", (x_offset, 5.41, side * 1.75), (.17, .16, 3.50), "285D65",
                  pitch=side * 20, shadow=False)
    piece("Ceramic roof ridge", (0, 5.95, 0), (9.48, .35, .65), roof)
    for side in (-1, 1):
        piece("Raised ridge finial", (side * 4.54, 6.03, 0), (.58, .21, .48), jade, roll=side * 28)
        piece("Bronze roof tip", (side * 4.8, 6.14, 0), (.23, .19, .49), brass, material=metal, roll=side * 28)
    sign(shop, "DOJO OUTFITTERS", x, y + 5.18, z + 3.27, 7.38, .92, tint="23514A",
         finished_back=True, single_line=True)

    keeper_x, keeper_y, keeper_z = x - .20, y + .16, z + .95
    keeper = townsperson(shop, "Mika the Shopkeeper", keeper_x, keeper_y, keeper_z,
                       "B95030", "39766B", .61, 180, species="red panda")
    part(keeper, "Tailor's apron", (keeper_x, keeper_y + 1.89, keeper_z + .49),
         (.84, 1.00, .16), "193E48", collide=False)
    for side in (-1, 1):
        part(keeper, "Apron strap", (keeper_x + side * .29, keeper_y + 2.41, keeper_z + .50),
             (.104, .49, .11), "D99956", roll=side * 17, collide=False)
    part(keeper, "Apron pocket", (keeper_x, keeper_y + 1.60, keeper_z + .58),
         (.46, .34, .06), "34666C", collide=False)
    part(keeper, "Reedwork pin", (keeper_x + .21, keeper_y + 2.19, keeper_z + .58),
         (.17, .17, .06), brass, roll=45, collide=False)

    prompt = item(counter, "ProximityPrompt", "ShopPrompt")
    prop(prompt, "string", "ActionText", "Browse apparel")
    prop(prompt, "string", "ObjectText", "Mika · Shopkeeper")
    prop(prompt, "float", "MaxActivationDistance", 7.5)
    prop(prompt, "bool", "RequiresLineOfSight", False)
