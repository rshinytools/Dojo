"""The open timber gatehouse and processional court at Skywalk Peaks."""


def build_skywalk_gatehouse(town, x, y, z, *, item, prop, part, beam, gate, sign, swept_roof,
                            curved_plaque, marquee_title, festival_lantern, standing_lantern,
                            banner, garden_prop, slate, limestone, wood, metal, neon,
                            cedar_variant, stone_variant, variant_field):
    # Keep the first pair of colliding piers in the original radial-road frame.
    gate(town, x, z, span=18, trim="754956", y=y, lanterns=False, straight_lintel=False)
    model = item(town, "Model", "Skywalk mountain gatehouse")
    prop(model, "token", "ModelStreamingMode", 1)
    prop(model, "token", "LevelOfDetail", 4)
    roof_z = z - 3.77
    rear_z = z - 8.15

    def detail(name, dx, h, dz, size, pigment, material=wood, *, collide=False, shadow=False):
        piece = part(model, name, (x + dx, y + h, z + dz), size, pigment,
                     material=material, collide=collide)
        prop(piece, "bool", "CastShadow", shadow)
        if material == wood:
            prop(piece, "string", variant_field, cedar_variant)
        return piece

    for side in (-1, 1):
        for spacing, depth in ((9.0, 0), (7.6, -8.15)):
            px = spacing * side
            rear = depth != 0
            width = 2.1 if rear else 2.35
            base_depth = 1.55 if rear else 2.35
            detail("Gatehouse pier plinth", px, .55, depth, (width, 1.10, base_depth),
                   "92838B", slate, collide=rear)
            detail("Projecting pier capstone", px, 1.16, depth, (width-.04, .22, base_depth),
                   "AEA0A2", slate)
            detail("Gatehouse cedar shaft", px, 5.92, depth, (1.44, 9.53, 1.51),
                   "975B5B" if rear else "985052", collide=rear, shadow=True)
            for height, thickness, pigment in ((2.20,.20,"C68E5F"), (8.66,.20,"C99664"), (10.47,.26,"B88C5C")):
                detail("Gatehouse bronze pier binding", px, height, depth, (1.59, thickness, 1.60),
                       pigment, metal)
            for tier, width in enumerate((1.77, 2.17, 2.65)):
                detail("Stacked eave bracket", px, 10.73+tier*.22, depth,
                       (width, .28, 1.80+tier*.34), ("7B4D54","886169","9A756F")[tier])
        for h, width, pigment in ((7.96,.28,"A27470"),(9.33,.48,"724956"),(10.50,.38,"A47873")):
            brace = beam(model, "Open gatehouse side tie", (x+side*9, y+h, z),
                         (x+side*7.6, y+h, rear_z), width, pigment)
            prop(brace, "bool", "CastShadow", False)
        for offset in (.18, .38, .59, .80):
            detail("Open side lattice", side*(9-1.4*offset), 8.69, -8.15*offset,
                   (.21, 1.49, .28), "90676F")
        banner(model, x+side*9.65, y+5.67, z+1.01, scale=.77)
        festival_lantern(model, x+side*6.90, y+8.56, z+1.56, .93, light=True,
                         tint="FFBD68", warm_pool=True, light_profile=(.90, 13))
        standing_lantern(model, (x+side*10.60,y+.58,z+3.25), .38,
                         light=False, paper_tint="FFC277")
        for offset, scale in ((1.38,.14),(1.81,.10)):
            garden_prop(model,"meadowCover",(x+side*(10.60+offset),y+.07,z+2.60),scale,39*side,"A5AA69")

    detail("Carved street-facing header beam", 0, 10.66, .15, (19.58, .78, 1.44), "74434E", shadow=True)
    detail("Carved courtyard header beam", 0, 10.37, -8.15, (16.74, .70, 1.43), "734750", shadow=True)
    detail("Rafter-plank ceiling", 0, 11.27, -3.77, (20.21, .46, 10.71), "6A4854", shadow=True)
    for dz in (-7.43, -5.61, -3.79, -1.97, -.15):
        detail("Amber ceiling joist", 0, 11.10, dz, (19.94, .42, .43), "81535F")
    profile = tuple((d, y+10.92-.82*(d/8.7)**2) for d in (-8.7,-5.8,-2.9,0,2.9,5.8,8.7))
    curved_plaque(model, x, z+2.02, profile, 1.94, "77424D", "D7A460", rim_height=.17)
    marquee_title(model, "SKYWALK PEAKS", x, z+2.02, profile, 1.45)
    sign(model, "GRAND DOJO CITY", x, y+10.50, rear_z-.88, 11.13, 1.10, 180,
         "51465F", finished_back=True)

    swept_roof(model, x, y+12.09, roof_z, 24.65, 12.65, 2.95, fine_tiles=False,
               signature=True, corner_sweep=1.04, ridge_finial_scale=.83)
    detail("Raised clerestory cedar frame", 0, 15.68, -3.77, (12.40, 2.64, 6.64),
           "835465", shadow=True)
    for face in (-1, 1):
        for bay in (-4.23, 0, 4.23):
            dz = -3.77 + face*3.33
            detail("Clerestory cassette", bay, 15.80, dz, (3.69, 2.05, .19), "4C405C")
            detail("Amber clerestory paper", bay, 15.85, dz+face*.12, (3.35, 1.68, .06),
                   "E8BD84", neon)
            for dx in (-1.09, 0, 1.09):
                detail("Clerestory mullion", bay+dx, 15.84, dz+face*.19, (.08, 1.73, .13), "6D4B5A")
            detail("Clerestory sash", bay, 15.77, dz+face*.19, (3.39, .10, .13), "6D4B5A")
    swept_roof(model, x, y+17.10, roof_z, 15.94, 8.81, 2.55, fine_tiles=False,
               corner_sweep=1.13)

    # Lay the joint pattern over the existing flat courtyard. Its collisions
    # remain on the original courtyard and stairs.
    tones = ("B19DA2", "B8A7A9", "C0ACAC", "B5A2A8")
    for row in range(8):
        ends = [-4.72, -2.31+.22*(row%2), .06-.28*(row%2), 2.39+.25*(row%2), 4.72]
        for col, (left, right) in enumerate(zip(ends, ends[1:])):
            stone = detail("Wind Court processional flagstone", (left+right)/2, .038, -10.06-row*2.29,
                           (right-left-.053,.022,2.24), tones[(row+3*col)%len(tones)], limestone)
            prop(stone, "string", variant_field, stone_variant)
