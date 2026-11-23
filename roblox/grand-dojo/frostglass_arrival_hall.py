"""The Ice Garden conservatory above Frostglass's original courtyard house."""


def build_frostglass_arrival_hall(town, x, y, z, *, item, prop, part, beam,
                                 swept_roof, festival_lantern, garden_prop,
                                 slate, wood, metal, neon, cedar_variant,
                                 variant_field):
    hall = item(town, "Model", "Frostglass conservatory")
    prop(hall, "token", "ModelStreamingMode", 1)
    prop(hall, "token", "LevelOfDetail", 4)
    house_z = z - 19
    gallery_z = house_z - .60

    def place(parent, label, offset, size, tint, material=wood, *, shadow=False, **pose):
        px, py, pz = offset
        detail = part(parent, label, (x + px, y + py, house_z + pz), size, tint,
                      material=material, collide=False, **pose)
        prop(detail, "bool", "CastShadow", shadow)
        if material == wood:
            prop(detail, "string", variant_field, cedar_variant)

    def hall_beam(parent, label, a, b, gauge, tint):
        start = (x + a[0], y + a[1], house_z + a[2])
        end = (x + b[0], y + b[1], house_z + b[2])
        member = beam(parent, label, start, end, gauge, tint)
        prop(member, "bool", "CastShadow", False)

    gallery = item(hall, "Model", "Conservatory amber gallery")
    for level, width, depth, height, tint in (
        (15.65, 16.11, 11.35, .65, "6F879A"),
        (16.02, 16.74, 11.70, .21, "A5AFB7"),
        (16.27, 16.45, 11.52, .25, "527484"),
    ):
        place(gallery, "Conservatory encircling weather course", (0, level, -.60),
              (width, height, depth), tint, slate, shadow=level == 15.65)
    place(gallery, "Conservatory painted blue cedar core", (0, 19.10, -.60),
          (15.85, 5.79, 10.48), "527488", shadow=True)
    place(gallery, "Blue-gallery cornice shadow line", (0, 21.97, -.60),
          (16.91, .45, 11.60), "365367", shadow=True)
    place(gallery, "Gallery copper ridge course", (0, 22.17, -.60),
          (16.92, .12, 11.56), "B99663", metal)

    # Slightly recessed amber panes sit within inlaid frames. Frosted lower
    # transoms keep the blue trim legible against the luminous windows.
    for face in (-1, 1):
        wall = -.60 + face * 5.24
        for bay, px in enumerate((-5.67, -1.89, 1.89, 5.67)):
            center_y = 19.26
            place(gallery, "Gallery carved window rebate",
                  (px, center_y, wall + face * .13), (3.37, 4.39, .29), "304C5D")
            place(gallery, "Amber conservatory paper pane",
                  (px, center_y + .08, wall + face * .284), (2.92, 3.63, .036),
                  ("EBA974", "F1BD84", "F2C58A", "DE9F6F")[bay], neon)
            for dx in (-1.42, -.72, 0, .72, 1.42):
                place(gallery, "Gallery pale cedar lattice upright",
                      (px + dx, center_y + .09, wall + face * .342),
                      (.087, 3.68, .093), "405A68")
            for dy in (-1.73, -.66, .62, 1.85):
                place(gallery, "Gallery pale cedar lattice transom",
                      (px, center_y + dy, wall + face * .351),
                      (2.97, .115, .105), "506777")
            place(gallery, "Frost-blue pane apron",
                  (px, center_y - 1.97, wall + face * .27), (3.14, .25, .17), "8DA4AC")
            place(gallery, "Gallery brass rim over stone sill",
                  (px, center_y - 2.16, wall + face * .437), (3.37, .105, .34),
                  "C4A47A", metal)
        for post in (-7.62, -3.78, 0, 3.78, 7.62):
            place(gallery, "Gallery indigo cedar column",
                  (post, 19.10, wall + face * .31), (.51, 5.72, .64), "4C677D",
                  shadow=abs(post) > 7)
            for level in (16.68, 21.20):
                place(gallery, "Gallery copper column cuff",
                      (post, level, wall + face * .38), (.63, .15, .58),
                      "BC9B70", metal)
            for level, projection, color in ((21.24, .68, "577789"),
                                             (21.50, .92, "405F73"),
                                             (21.77, 1.28, "6A899B")):
                place(gallery, "Stacked gallery corbel",
                      (post, level, wall + face * projection * .45),
                      (.56 + projection * .18, .21, projection), color)

    for hand in (-1, 1):
        for pz in (-3.21, 1.89):
            edge = hand * 8.00
            place(gallery, "Gallery side inset window", (edge, 19.28, pz),
                  (4.16, 3.86, .26), "354F5F", yaw=90 * hand)
            place(gallery, "Soft paper side pane",
                  (edge + hand * .15, 19.28, pz), (3.37, 3.25, .05),
                  "D4A57B", neon, yaw=90 * hand)
            for dh in (-.88, 0, .88):
                place(gallery, "Side gallery window lattice",
                      (edge + hand * .21, 19.28, pz + dh), (.087, 3.31, .08),
                      "4A6879", yaw=90 * hand)
            for level in (18.70, 19.89, 20.87):
                place(gallery, "Side gallery window transom",
                      (edge + hand * .22, level, pz), (3.39, .1, .11),
                      "5A7887", yaw=90 * hand)
        festival_lantern(gallery, x + hand * 7.64, y + 20.18, house_z + 5.57, .55,
                         light=False, tint="F0C48C", entrance_paper=True)

    swept_roof(gallery, x, y + 22.39, gallery_z, 20.62, 13.55, 3.45,
               fine_tiles=False, signature=True, corner_sweep=1.18, ridge_finial_scale=.76)

    cupola = item(hall, "Model", "Frostglass clerestory crown")
    place(cupola, "Clerestory granite sill plate", (0, 25.30, -.63), (10.03, .52, 6.65),
          "7D8D9D", slate, shadow=True)
    place(cupola, "Clerestory indigo cedar frame", (0, 27.44, -.63), (9.25, 4, 5.83),
          "4D697D", shadow=True)
    for front in (-1, 1):
        wall = -.63 + front * 2.92
        for px in (-2.88, 0, 2.88):
            place(cupola, "Crown warm recessed clerestory", (px, 27.87, wall + front * .07),
                  (2.40, 2.30, .16), "344D61")
            place(cupola, "Crown pale gold paper", (px, 27.87, wall + front * .17),
                  (2.14, 2.04, .04), "E4BA8E", neon)
            for inset in (-.71, 0, .71):
                place(cupola, "Clerestory narrow lattice", (px + inset, 27.87, wall + front * .225),
                      (.081, 2.04, .084), "547283")
            for level in (27.47, 28.25):
                place(cupola, "Clerestory narrow transom", (px, level, wall + front * .23),
                      (2.16, .075, .099), "547283")
        for dx in (-4.56, -1.47, 1.47, 4.56):
            place(cupola, "Crown painted cedar column", (dx, 27.61, wall + front * .23),
                  (.45, 4.20, .49), "476C83")
            place(cupola, "Crown pale brass column cap", (dx, 29.42, wall + front * .26),
                  (.55, .18, .56), "C0A079", metal)
        place(cupola, "Clerestory horizontal copper cap", (0, 29.60, wall + front * .12),
              (9.77, .16, .38), "C19C66", metal)
    swept_roof(cupola, x, y + 29.84, gallery_z, 12.04, 8.24, 2.33,
               fine_tiles=False, signature=True, corner_sweep=1.24, ridge_finial_scale=.80)

    front = item(hall, "Model", "Conservatory stone and cedar entrance")
    # Fit new trims around the old sign, amber lower windows and open doors.
    # Both posts and the planters sit against the footprint outside the steps.
    for hand in (-1, 1):
        px = hand * 9.90
        place(front, "Entry weathered slate pilaster shoe", (px, .95, 7.46),
              (1.30, 1.37, 1.21), "8295A2", slate)
        place(front, "Entry slate collar", (px, 1.65, 7.62), (1.42, .21, 1.12),
              "A9B4BB", slate)
        place(front, "Carved blue cedar pilaster", (px, 7.15, 8.19), (.55, 10.95, .32),
              "637E8D")
        for level in (2.45, 11.37):
            place(front, "Entry small copper collar", (px, level, 8.28),
                  (.63, .16, .20), "C59F70", metal)
        for level, reach, width, tint in (
            (11.66, .44, .63, "476575"), (11.93, .64, .82, "7893A0"), (12.12, .86, .98, "537284"),
        ):
            place(front, "Entry cornice corbel", (px, level, 8.02 + reach * .13),
                  (width, .18, reach), tint)
        bay_x = hand * 6.45
        place(front, "Ground floor window slate sill", (bay_x, 5.72, 8.07),
              (4.41, .27, .52), "9AA8AD", slate)
        place(front, "Ground floor window bronze rim", (bay_x, 5.88, 8.14),
              (4.10, .075, .37), "BE9A69", metal)
        for offset in (-2.13, 2.13):
            place(front, "Ground floor window carved stile",
                  (bay_x + offset, 7.87, 8.03), (.17, 4.19, .21), "547280")
        place(front, "Ground floor window lintel rebate", (bay_x, 10.02, 8.04),
              (4.40, .26, .38), "446273")
        for offset in (-1.80, 1.80):
            hall_beam(front, "Ground window carved cedar bracket",
                      (bay_x + offset, 5.24, 7.77),
                      (bay_x + offset, 5.65, 8.24), .18, "5D7685")

        planter_x = hand * 8.74
        place(front, "Entry frost-white planter toe", (planter_x, .25, 7.66),
              (1.24, .50, .96), "A0ADB4", slate)
        place(front, "Entry dusty blue planter rim", (planter_x, .53, 7.66),
              (1.37, .13, 1.04), "7E93A1", slate)
        garden_prop(front, "mossFlowers", (x + planter_x - .21, y + .57, house_z + 7.63),
                    .14, 22 + hand * 24, "D5C6D7")
        garden_prop(front, "meadowCover", (x + planter_x + .19, y + .57, house_z + 7.69),
                    .16, 55 + hand * 21, "CBD4CD")

    place(front, "Doorway blue cedar head beam", (0, 10.71, 8.04),
          (6.38, .39, .66), "4F7185", shadow=True)
    place(front, "Fine copper lintel cap", (0, 10.96, 8.20),
          (6.20, .11, .48), "C29E66", metal)
    for px in (-3.05, 3.05):
        for level in (1.11, 9.72):
            place(front, "Blue doorpost sculpted band", (px, level, 8.12),
                  (.60, .23, .38), "7E94A2")
