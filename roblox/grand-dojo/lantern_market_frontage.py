"""Lantern Circuit's cedar shopfronts above and below the market street."""


def build_lantern_market_frontage(
    town, x, y, z, *, item, prop, part, beam, swept_roof, festival_lantern,
    garden_shelf, garden_prop, slate, wood, cloth, metal, neon,
):
    def frontage(name):
        model = item(town, "Model", name)
        prop(model, "token", "ModelStreamingMode", 1)
        prop(model, "token", "LevelOfDetail", 4)
        return model

    def piece(model, name, pos, size, tint, material, *, shadow=False, **placement):
        detail = part(model, name, pos, size, tint, material=material,
                      collide=False, **placement)
        prop(detail, "bool", "CastShadow", shadow)

    def brace(model, name, start, end, width, tint):
        detail = beam(model, name, start, end, width, tint)
        prop(detail, "bool", "CastShadow", False)

    exchange = frontage("Upper Lantern Exchange")
    cx, floor, cz = x - 19.5, y + 7.27, z - 33.4
    back, face = cz - 8.23, cz - 6.46
    for lift, width, depth, height, tint in (
        (-13.24, 17.48, 3.73, 10.0, "655A72"),
        (-6.26, 18.58, 4.22, 4.01, "7B687D"),
        (-2.47, 19.78, 4.65, 3.9, "736579"),
        (-.48, 21.15, 5.07, .96, "988394"),
    ):
        piece(exchange, "Dressed rear market foundation", (cx, floor + lift, back),
              (width, height, depth), tint, slate)
    piece(exchange, "Recessed cedar behind vendor counters", (cx, floor + 1.80, face),
          (21.30, 3.60, .37), "79505D", wood)
    piece(exchange, "Exchange side and rear walls", (cx, floor + 6.23, back),
          (21.58, 4.18, 3.47), "A5706E", wood, shadow=True)
    piece(exchange, "Cedar lintel above the stalls", (cx, floor + 4.33, face + .11),
          (22.17, .55, .71), "754657", wood, shadow=True)
    piece(exchange, "Brass lintel inlay", (cx, floor + 4.39, face + .49),
          (21.39, .095, .074), "BB8668", metal)
    piece(exchange, "Exchange upper fascia", (cx, floor + 8.52, face + .10),
          (22.52, .54, .92), "754658", wood)

    for i, offset in enumerate((-10.64, -3.59, 3.59, 10.64)):
        px = cx + offset
        piece(exchange, "Plum exchange timber column", (px, floor + 4.21, face + .30),
              (.51, 8.40, .65), ("74435B", "96566D")[i % 2], wood, shadow=i % 3 == 0)
        for h, width, tint in ((.27, .71, "8F7D8E"), (4.25, .68, "BA8D6D"), (8.20, .75, "BD8C65")):
            piece(exchange, "Column plinth and bindings", (px, floor + h, face + .32),
                  (width, .19, .72), tint, slate if h < 1 else metal)
        for tier, delta in enumerate((.65, 1.14)):
            piece(exchange, "Stacked cedar eave corbel",
                  (px, floor + 8.11 + tier * .27, face + delta * .37),
                  (.73 + .20 * tier, .25, delta),
                  ("86546A", "A46B74")[tier], wood)

    for bay, offset in enumerate((-7.10, 0, 7.10)):
        px = cx + offset
        piece(exchange, "Recessed upper window frame", (px, floor + 6.44, face + .12),
              (5.62, 2.77, .41), "613F54", wood)
        piece(exchange, "Warm paper upper window", (px, floor + 6.44, face + .37),
              (5.11, 2.34, .10), ("E6AB79", "D89679", "DDB579")[bay], neon)
        for dx in (-1.72, -.85, 0, .85, 1.72):
            piece(exchange, "Upper window cedar mullion", (px + dx, floor + 6.44, face + .44),
                  (.075, 2.38, .095), "79535C", wood)
        for dy in (-.43, .51):
            piece(exchange, "Upper window cedar crosspiece", (px, floor + 6.44 + dy, face + .45),
                  (5.22, .085, .10), "81545A", wood)
        piece(exchange, "Upper window projecting sill", (px, floor + 5.15, face + .58),
              (5.75, .20, .74), "986375", wood)
        for dx in (-1.14, 1.14):
            brace(exchange, "Sill cedar knee", (px + dx, floor + 4.83, face + .53),
                  (px + dx, floor + 5.12, face + .91), .19, "774A64")

    swept_roof(exchange, cx, floor + 8.83, back + .27, 23.18, 8.25, 4.18,
               fine_tiles=False, signature=True, corner_sweep=1.15)
    for side in (-1, 1):
        px = cx + side * 9.61
        piece(exchange, "Exchange side banner",(px, floor + 5.55, face + .78),
              (.95, 3.02, .12), ("518584" if side > 0 else "9E5977"), cloth, roll=-side * 3)
        piece(exchange, "Banner brass suspension", (px, floor + 7.18, face + .78),
              (1.20, .13, .19), "C79564", metal)
        for dz, sx, plant in ((.23, .26, "mossFlowers"), (-.20, -.26, "meadowCover")):
            garden_prop(exchange, plant,
                        (px + side * .31 + sx, floor + .25, face + .77 + dz),
                        .15, 43 + side * 29, "C492B8" if plant == "mossFlowers" else "A1A773")
        garden_shelf(exchange, px + side * .33, floor + .23, face + .78, 1.52, 1.05, .31,
                     "8B7689", slate, collide=False)

    hall = frontage("Night Market street frontage")
    front = z - 11.50
    for side in (-1, 1):
        px = x + side * 9.91
        piece(hall, "Plum storefront pilaster", (px, y + 5.66, front + .73),
              (.82, 10.05, .30), "925871", wood)
        piece(hall, "Street pilaster slate socket", (px, y + .60, front + .54),
              (1.48, .54, 1.00), "85778E", slate)
        for h, width in ((1.02, 1.27), (9.60, 1.01)):
            piece(hall, "Market pilaster copper band", (px, y + h, front + .78),
                  (width, .16, .39), "BE8A65", metal)
        for step, offset in enumerate((.51, .93, 1.21)):
            piece(hall, "Stepped storefront bracket",
                  (px - side * .18, y + 10.02 + step * .26, front + offset / 2),
                  (1.04 + step * .18, .24, offset + .53),
                  ("875770", "6D475D", "A4666B")[step], wood)
        brace(hall, "Storefront brass lantern hanger", (px + side * .51, y + 10.58, front + .26),
              (px + side * .51, y + 8.92, front + 1.19), .13, "AD7B5E")
        festival_lantern(hall, px + side * .51, y + 8.18, front + 1.19, .72,
                         light=False, tint="DBA274", entrance_paper=True)
        sx = x + side * 7.10
        for h, height, tone in ((3.00, .19, "855365"), (5.59, .13, "A16A70"), (8.38, .22, "805264")):
            piece(hall, "Street screen deep cedar rail", (sx, y + h, front + .20),
                  (5.56, height, .28), tone, wood)
        piece(hall, "Street screen stone sill", (sx, y + 2.77, front + .29),
              (5.45, .27, .55), "A28C91", slate)

    piece(hall, "Recess shade behind the Night Market plaque", (x, y + 11.12, front + .26),
          (18.82, .36, 1.15), "674155", wood, shadow=True)
    piece(hall, "Storefront sign sill copper edge", (x, y + 11.09, front + .87),
          (18.42, .083, .12), "BE8A65", metal)
