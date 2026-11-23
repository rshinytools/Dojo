"""The Trophy Hall approach from the plaza and the west canal bridge."""

from math import atan2, cos, degrees, hypot


LOWER_FLIGHT = (-15.18, -18.78, (15.2, 14.7, 13.6), (.48, .84, 1.20))
UPPER_FLIGHT = (-24.92, -30.30, (13.0,) * 7,
                (1.55, 1.90, 2.25, 2.60, 2.95, 3.30, 3.65))


def build_hall_split_stair(hall, *, item, prop, part, garden_shelf, garden_prop, standing_lantern,
                           slate, sandstone, grass, variant_field, stone_variant, trim_variant):
    stairs = item(hall, "Model", "Trophy Hall split stair")
    prop(stairs, "token", "ModelStreamingMode", 1)
    prop(stairs, "token", "LevelOfDetail", 4)

    def stone(name, point, size, tint, *, material=slate, variant=stone_variant,
              collide=False, yaw=0, pitch=0):
        piece = part(stairs, name, point, size, tint, material=material,
                     collide=collide, yaw=yaw, pitch=pitch)
        prop(piece, "string", variant_field, variant)
        prop(piece, "bool", "CastShadow", False)
        return piece

    # The courtyard foundation is lower under the center than at its edges.
    # The approach stone gives both sides of the first tread a level start.
    stone("South hall approach slab", (0, .045, -14.23), (15.48, .27, 2.00),
          "B89A8D", material=sandstone, variant=trim_variant, collide=True)
    landing_depth = LOWER_FLIGHT[1] - UPPER_FLIGHT[0]
    landing_z = (LOWER_FLIGHT[1] + UPPER_FLIGHT[0]) / 2
    stone("Trophy Hall garden landing", (0, .545, landing_z), (13.25, 1.31, landing_depth + .07),
          "BFA599", collide=True)
    for band in range(3):
        for column in range(5):
            x = (column-2)*2.57
            z = landing_z + (band-1)*2.04
            stone("Hall landing sandstone flag", (x, 1.212, z),
                  (2.52, .024, 1.97), ("C7AA9C", "C1A193", "CEAEA1")[(band+column)%3],
                  material=sandstone, variant=trim_variant)

    for name, (south, north, widths, tops) in (
        ("Hall lower stair tread", LOWER_FLIGHT), ("Hall upper stair tread", UPPER_FLIGHT),
    ):
        depth = (south-north)/len(tops)
        for index, (width, top) in enumerate(zip(widths, tops)):
            front = south-index*depth
            z = front-depth/2
            shade = ("B79989", "C2A391", "BA9A88", "C6A894")[index%4]
            stone(name, (0, (top-.22)/2, z), (width, top+.22, depth+.06), shade, collide=True)
            for column, (lo, hi) in enumerate(((-.491, -.19), (-.182, .213), (.221, .491))):
                x, span = (lo+hi)*width/2, (hi-lo)*width
                stone("Sunlit hall stair edge", (x, top-.058, front+.048), (span, .103, .041),
                      ("D5B19A", "CFA88F", "DBBDA4")[(index+column)%3],
                      material=sandstone, variant=trim_variant)
                stone("Hewn hall riser panel", (x, top-.193, front+.044), (span, .177, .025),
                      ("907982", "9B827F", "9C8588")[(index+2*column)%3])

    # Meet the low bridge exit at the west edge of the intermediate landing.
    # The short wedge stays within the existing jade approach.
    west, east, bottom, top = -10.43, -6.48, .190, 1.185
    pitch = atan2(top-bottom, east-west)
    ramp_y = (top+bottom)/2-.19*cos(pitch)
    stone("Jade crossing hall ramp", ((west+east)/2, ramp_y, -24.03),
          (2.8, .38, hypot(east-west, top-bottom)+.18), "A78B89", collide=True,
          yaw=90, pitch=-degrees(pitch))

    beds = item(hall, "Model", "Trophy Hall entrance garden tiers")
    prop(beds, "token", "ModelStreamingMode", 1)
    prop(beds, "token", "LevelOfDetail", 4)
    profiles = (
        (-10.25, -15.90, .56, 2.92, 3.75),
        (-10.00, -19.02, 1.10, 3.29, 3.86),
        ( 10.67, -15.26, .68, 4.39, 3.76),
        ( 10.71, -18.33, 1.28, 4.49, 4.38),
        ( 11.10, -21.18, 1.83, 4.05, 3.55),
    )
    for index, (x, z, crest, width, depth) in enumerate(profiles):
        garden_shelf(beds, x, crest, z, width, depth, crest-.10,
                     ("917B84", "A1878B", "997E85")[index%3], slate, collide=False)
        garden_shelf(beds, x, crest+.15, z-.16, width-.41, depth-.42, .22,
                     ("70854E", "7A8E53", "667D4A")[index%3], grass, collide=False)
        for key, dx, dz, scale, tint in (
            ("bankRock", .42, -.51, .20, "9D8A93"),
            ("meadowCover", -.48, .44, .19, "A1BB71"),
            ("meadowGrass", .57, .42, .27, "C4BE7B"),
            ("mossFlowers", -.63, -.66, .18, "DB92B7"),
            ("meadowFlowers", .09, .87, .28, "ECC394"),
            ("grassBlade", -.80, .79, .34, "E7CB85"),
        ):
            garden_prop(beds, key, (x+dx, crest+.12, z+dz), scale, index*41+32, tint)

    for x, y, z in ((-9.66, .66, -15.38), (10.57, .75, -14.69)):
        stone("Lower garden lantern base", (x, y+.19, z), (1.72, .38, 1.75), "8B7680")
        stone("Lower garden lantern cap", (x, y+.43, z), (1.93, .16, 1.96), "C5A08E",
              material=sandstone, variant=trim_variant)
        standing_lantern(beds, (x, y+.51, z), .69, light=False, paper_tint="FFC36A")

    for piece in beds.findall("Item"):
        if piece.get("class") in ("Part", "WedgePart", "MeshPart"):
            shadow = piece.find("Properties/bool[@name='CastShadow']")
            if shadow is None:
                prop(piece, "bool", "CastShadow", False)
            else:
                shadow.text = "false"
