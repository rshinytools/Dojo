"""Dress Harbor House with a teal ledger tower and framed lower bays."""


def build_harbor_arrival_hall(town, x, y, z, *, item, prop, part, beam, swept_roof,
                              festival_lantern, slate, wood, metal, neon,
                              cedar_variant, variant_field):
    hall = item(town, "Model", "Harbor House ledger tower")
    prop(hall, "token", "ModelStreamingMode", 1)
    prop(hall, "token", "LevelOfDetail", 4)
    house_z = z - 19
    tower_z = house_z - .56

    def trim(parent, label, offset, size, tint, material=wood, *, shadow=False, **pose):
        px, py, pz = offset
        segment = part(parent, label, (x + px, y + py, house_z + pz), size, tint,
                       material=material, collide=False, **pose)
        prop(segment, "bool", "CastShadow", shadow)
        if material == wood:
            prop(segment, "string", variant_field, cedar_variant)

    # The broad lower roof remains the visual transition between the stone
    # storefront and the narrower ledger floor rising through its ridge.
    for height, width, depth, thickness, tint in (
        (15.18, 13.96, 9.75, .57, "426568"),
        (15.68, 14.40, 10.18, .32, "63878A"),
        (16.04, 14.14, 9.91, .25, "A28466"),
    ):
        trim(hall, "Ledger tower weather course", (0, height, -.56),
             (width, thickness, depth), tint, shadow=height == 15.18)
    trim(hall, "Ledger tower painted cedar core", (0, 19.77, -.56),
         (13.40, 7.52, 9.70), "59747A", shadow=True)
    trim(hall, "Ledger tower shaded cornice", (0, 23.45, -.56),
         (14.32, .44, 10.24), "385858", shadow=True)
    trim(hall, "Ledger tower copper cornice", (0, 23.68, -.56),
         (14.08, .11, 10.04), "BB8F61", metal)

    upper_face = 4.30
    for bay, px in enumerate((-4.53, 0, 4.53)):
        trim(hall, "Ledger front inset bay", (px, 19.92, upper_face + .15),
             (4.06, 4.72, .33), "334D51")
        trim(hall, "Ledger paper pane", (px, 20.18, upper_face + .33),
             (3.34, 3.28, .039), ("E7AE78", "F2C591", "DFAB78")[bay], neon)
        for dx in (-1.62, -.81, 0, .81, 1.62):
            trim(hall, "Ledger vertical window lattice", (px + dx, 20.18, upper_face + .40),
                 (.084, 3.30, .10), "406365")
        for dy in (-1.58, -.49, .57, 1.58):
            trim(hall, "Ledger horizontal window lattice", (px, 20.18 + dy, upper_face + .40),
                 (3.32, .088, .11), "406365")
        trim(hall, "Ledger brass sill edge", (px, 18.42, upper_face + .52),
             (3.98, .10, .22), "C89A68", metal)
        trim(hall, "Ledger window apron", (px, 18.19, upper_face + .46),
             (3.62, .38, .18), "567E80")

    for px in (-6.78, -2.25, 2.25, 6.78):
        trim(hall, "Teal ledger gallery post", (px, 19.89, upper_face + .31),
             (.46, 6.85, .61), "306568", shadow=abs(px) > 6)
        for height in (17.07, 22.61):
            trim(hall, "Ledger gallery post binding", (px, height, upper_face + .47),
                 (.58, .16, .52), "BB9668", metal)
        for index, (reach, height) in enumerate(((.56, 22.94), (.85, 23.14), (1.19, 23.34))):
            trim(hall, "Layered ledger eave corbel", (px, height, upper_face + reach / 2),
                 (.61 + .11 * index, .21, reach + .44), ("394F50", "527777", "739493")[index])

    for hand in (-1, 1):
        side_x = hand * 6.78
        for pz in (-3.15, 1.56):
            trim(hall, "Side ledger window recess", (side_x, 20.18, pz),
                 (3.95, 3.68, .32), "344D50", yaw=90 * hand)
            trim(hall, "Side ledger paper pane", (side_x + hand * .19, 20.18, pz),
                 (2.76, 2.87, .055), "DAA674", neon, yaw=90 * hand)
            for dz in (-.94, 0, .94):
                trim(hall, "Side ledger lattice bar", (side_x + hand * .29, 20.18, pz + dz),
                     (.078, 2.90, .12), "416061", yaw=90 * hand)
            for height in (19.67, 20.68):
                trim(hall, "Side ledger window tie", (side_x + hand * .30, height, pz),
                     (2.78, .087, .12), "496A6B", yaw=90 * hand)
            for dz in (-1.61, 1.61):
                trim(hall, "Side ledger teal shutter", (side_x + hand * .26, 20.18, pz + dz),
                     (.49, 3.13, .155), "6C9695", yaw=90 * hand)
                for height in (19.04, 20.18, 21.32):
                    trim(hall, "Side shutter cedar louvre", (side_x + hand * .39, height, pz + dz),
                         (.44, .095, .098), "3C6465", yaw=90 * hand)
        festival_lantern(hall, x + hand * 7.06, y + 22.02, house_z + 5.48, .59,
                         light=False, tint="EFC286", entrance_paper=True)
    swept_roof(hall, x, y + 23.83, tower_z, 17.33, 12.54, 3.32,
               fine_tiles=False, signature=True, corner_sweep=1.15, ridge_finial_scale=.82)

    facade = item(hall, "Model", "Harbor House lower storefront")
    for side in (-1, 1):
        # The west face meets the Cinder road sooner than the east face.
        # Fit that window against the original frame and tuck its stone
        # feet under the corner timber.
        beside_road = side < 0
        front = 7.19 if beside_road else 7.50
        xpost = side * 9.87
        if not beside_road:
            trim(facade, "Storefront slate pier base", (xpost, .95, front + .07),
                 (1.31, 1.05, 1.44), "858890", slate)
            trim(facade, "Storefront slate coping", (xpost, 1.54, front + .15),
                 (1.42, .19, 1.32), "A79D98", slate)
        trim(facade, "Storefront projecting cedar pilaster", (xpost, 7.17, front + .59),
             (.69, 11.17, .36), "528684")
        for height in (2.63, 12.23):
            trim(facade, "Storefront pilaster brass band", (xpost, height, front + .76),
                 (.76, .14, .13), "C29A69", metal)

        bay_x = side * 7.14
        if not beside_road:
            trim(facade, "Ground floor deep cedar window reveal", (bay_x, 6.53, front + .135),
                 (5.28, 7.17, .22), "426265")
            trim(facade, "Ground floor paper pane", (bay_x, 6.57, front + .27),
                 (4.72, 6.53, .026), "BE956A", neon)
            for dx in (-2.28, -1.20, 0, 1.20, 2.28):
                trim(facade, "Ground floor teal lattice stile", (bay_x + dx, 6.57, front + .34),
                     (.14, 6.60, .12), "406D6D")
            for height in (3.37, 4.96, 6.56, 8.16, 9.77):
                trim(facade, "Ground floor lattice transom", (bay_x, height, front + .36),
                     (4.73, .14, .13), "4F7777")
            trim(facade, "Storefront slate sill", (bay_x, 3.09, front + .30),
                 (5.44, .28, .70), "A3918B", slate)
        trim(facade, "Overhanging cyan awning plank", (bay_x, 11.21, front + .68),
             (5.58, .19, 1.45), "416C6C", pitch=12, shadow=True)
        trim(facade, "Awning copper drip edge", (bay_x, 11.07, front + 1.42),
             (5.60, .115, .19), "BB8C62", metal)
        for dx in (-2.22, 2.22):
            px = x + bay_x + dx
            bracket = beam(facade, "Storefront cedar diagonal bracket",
                           (px, y + 10.21, house_z + front + .20),
                           (px, y + 11.11, house_z + front + 1.14), .25, "4A6868")
            prop(bracket, "bool", "CastShadow", False)
