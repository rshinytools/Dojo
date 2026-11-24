"""Dressed stone and carved cedar for the Trophy Hall entrance."""

from hall_arrival_mass import hall_portico_box, hall_portico_y


def build_hall_arrival_details(hall, *, item, prop, part, beam, slate, wood, metal,
                               variant_field, ornament_brass):
    detail = item(hall, "Model", "Trophy Hall arrival woodwork and masonry")
    prop(detail, "token", "LevelOfDetail", 4)

    def trim(name, center, size, tint, material=wood, *, shadow=False):
        if material in (wood, metal):
            center, size = hall_portico_box(center, size)
        piece = part(detail, name, center, size, tint, material=material, collide=False)
        prop(piece, "bool", "CastShadow", shadow)
        if material == metal:
            prop(piece, "string", variant_field, ornament_brass)

    for side in (-1, 1):
        x = side * 9.12
        # Encapsulate the old post within its existing slate base. The
        # body casts a shadow, while the strips define the sheltered edges.
        trim("Lacquered portico pier", (x, 7.42, -29.43),
             (1.59, 6.40, 1.55), "8A3B2D", shadow=True)
        trim("Portico pier raised lacquer panel", (x, 7.41, -28.626),
             (1.28, 5.64, .128), "A85538")
        trim("Portico pier sunward bevel", (x + .60, 7.41, -28.547),
             (.12, 5.58, .061), "C47B53")
        trim("Portico pier recessed edge", (x - .59, 7.41, -28.547),
             (.12, 5.58, .061), "68352F")
        trim("Portico pier slate plinth", (x, 3.91, -29.45),
             (1.99, .42, 1.94), "786777", slate)
        trim("Portico pier sandstone band", (x, 4.127, -29.42),
             (1.94, .13, 1.90), "B99884", slate)
        for y in (4.44, 10.29):
            trim("Portico pier brass band", (x, y, -29.39),
                 (1.69, .18, 1.72), "BC844E", metal)

        # Each tier bears on the column or the tier below. The front ends
        # project just past the tie beam and remain below the marquee letters.
        for index, (y, front, width, height, tint) in enumerate((
            (10.36, -28.52, 1.57, .31, "67362D"),
            (10.64, -27.97, 1.86, .33, "A45B3C"),
            (10.92, -27.46, 2.14, .35, "76402F"),
            (11.20, -26.86, 2.47, .32, "A86842"),
        )):
            back = -29.87
            trim("Portico stacked cedar bracket", (x, y, (front + back) / 2),
                 (width, height, front - back), tint)
            face = "C68652" if index % 2 else "6F3D32"
            trim("Bracket exposed end grain", (x, y, front + .025),
                 (width * .78, height * .57, .067), face)
            if index in (1, 3):
                trim("Bracket brass tenon cap", (x, y + .012, front + .064),
                     (.34, .13, .045), "C69357", metal)

        for y, width, height, tint in (
            (10.31, 1.62, .15, "6A3C33"), (10.48, 1.75, .16, "B37C52"),
        ):
            trim("Carved portico capital shoulder", (x, y, -29.46),
                 (width, height, 1.32), tint)

        # Dress the existing stair pier faces without extending into the
        # central 13-stud stair, the western approach, or the garden ramp.
        middle_z = -26.06 if side < 0 else -24.71
        for y, z in ((.91, -21.25), (2.21, middle_z), (3.89, -29.15)):
            x = side * 7.43
            trim("Stair pier split slate face", (x, y - .55, z + .685),
                 (1.37, .88, .14), "887583", slate)
            trim("Stair pier lower slate course", (x, y - .89, z + .755),
                 (1.44, .20, .12), "786674", slate)
            trim("Stair pier hewn slate tablet", (x, y - .49, z + .776),
                 (.83, .39, .056), "9F8688", slate)
            trim("Stair pier warm edge", (x + .43, y - .49, z + .77),
                 (.088, .41, .052), "B29A92", slate)

    # The underside alternates shade and warm exposed ends. Nothing projects
    # upward into the entry title or lowers its original portal clearance.
    trim("Portico shaded soffit recess", (0, 11.38, -29.36),
         (25.67, .15, 3.78), "634034")
    for x in (-12.58, -5.11, -2.57, 2.57, 5.11, 12.58):
        rafter = beam(detail, "Portico exposed soffit rafter", (x, hall_portico_y(11.03), -31.04),
                      (x, hall_portico_y(11.30), -26.88), .29, "8C5137", collide=False)
        prop(rafter, "bool", "CastShadow", False)
        trim("Rafter exposed cedar end", (x, 11.28, -26.73), (.35, .22, .10), "B98256")
