"""Carved joinery and upper chamber trim for the Wind Court chime hall."""

from math import atan2, degrees, hypot


def build_wind_court_architecture(court, x, z, deck, *, item, prop, part, wood,
                                 slate, metal, fabric, neon, wood_variant,
                                 brass_variant, variant_field):
    architecture = item(court, "Model", "Wind Court carved architecture")
    prop(architecture, "token", "LevelOfDetail", 4)

    def detail(name, u, rise, d, size, tint, material=wood, **orientation):
        piece = part(architecture, name, (x+u, deck+rise, z+d), size, tint,
                     material=material, collide=False, **orientation)
        prop(piece, "bool", "CastShadow", False)
        if material == wood or material == metal:
            variant = wood_variant if material == wood else brass_variant
            prop(piece, "string", variant_field, variant)

    def strut(name, start, end, thickness, depth, tint, material=wood):
        u, h, d = ((a+b)/2 for a, b in zip(start, end))
        span, rise = end[0]-start[0], end[1]-start[1]
        detail(name, u, h, d, (hypot(span, rise)+.05, thickness, depth),
               tint, material, roll=degrees(atan2(rise, span)))

    for side in (-1, 1):
        u = side*9.62
        for d in (-13.08, -19.28, -25.95):
            ramp_join = side < 0 and d == -13.08
            for rise, width, height, tint, material in (
                (.10, 1.82, .20, "746774", slate),
                (.65, 1.62, .24, "AB98A0", slate),
                (1.49, 1.29, .19, "714034", wood),
                (7.76, 1.37, .20, "CF995B", metal),
                (8.18, 1.59, .57, "703D36", wood),
                (8.60, 1.89, .31, "A35743", wood),
                (9.02, 2.14, .52, "76433B", wood),
                (9.34, 2.27, .16, "C99761", metal),
            ):
                if ramp_join and rise < 7:
                    # Hold the interior edge behind the existing column and shoe silhouette.
                    detail("Tiered column joinery", u-.21, rise, d-.36,
                           (width-.50,height,width-.50), tint, material)
                else:
                    detail("Tiered column joinery", u, rise, d, (width,height,width), tint, material)
            if ramp_join:
                detail("Recessed lacquer upright", u-.58, 4.45, d, (.57,5.72,.10), "84392F", yaw=90)
                detail("Cedar upright edge", u-.609, 4.45, d+.35, (.083,5.66,.09), "D19665", yaw=90)
            else:
                detail("Recessed lacquer upright", u, 4.45, d+.58, (.57,5.72,.10), "84392F")
                detail("Cedar upright edge", u-side*.35, 4.45, d+.609, (.083,5.66,.09), "D19665")
            strut("Curving lintel knee", (u,7.13,d+.31), (u-side*.60,8.26,d+.31),
                  .43,.43,"8E4B38")
            strut("Curving lintel knee", (u-side*.60,8.26,d+.31), (u-side*2.09,9.12,d+.31),
                  .43,.43,"A66444")
            strut("Copper knee inlay", (u-side*.58,8.21,d+.55), (u-side*1.81,8.92,d+.55),
                  .09,.07,"D4A16A",metal)

    # Set the curved lip above the original reading plane. It continues into the post capitals.
    points = ((-10.55,9.65),(-8.11,9.43),(-5.48,9.26),(-2.80,9.16),
              (0,9.14),(2.80,9.16),(5.48,9.26),(8.11,9.43),(10.55,9.65))
    for (u0,h0),(u1,h1) in zip(points,points[1:]):
        strut("Swept lacquer fascia", (u0,h0+.31,-11.81), (u1,h1+.31,-11.81),
              .55,.61,"553F60")
        strut("Copper crown edging", (u0,h0+.63,-11.50), (u1,h1+.63,-11.50),
              .13,.12,"CF9C63",metal)
    for side in (-1,1):
        detail("Carved bronze lintel end", side*9.69, 9.03, -11.53, (1.18,.44,.18),
               "C89A66", metal, roll=side*8)
        for offset in (.18,.55,.92):
            detail("Indigo lintel end grain", side*(8.95+offset), 9.01, -11.415,
                   (.10,.21,.08),"4B3B56", fabric, roll=side*11)
        for d in (-24.89,-22.47,-20.05,-17.63,-15.21):
            detail("Exposed cedar eave block", side*10.59, 9.68, d, (1.89,.37,.45), "935441")
            detail("Exposed bronze eave pin", side*11.57, 9.68, d, (.12,.22,.27), "B9865A", metal)
    for u in (-10.98,-8.44,-5.89,-3.34,0,3.34,5.89,8.44,10.98):
        detail("Exposed front rafter", u, 10.15, -10.95, (.46,.45,1.58), "8F4B38")
        detail("Rounded front rafter cap", u, 10.17, -10.11, (.37,.33,.15), "B87851")
    for d in (-16.71,-21.35,-25.88):
        detail("Chime hall ceiling tie", 0, 9.32, d, (19.25,.27,.45), "6D443E")
        detail("Chime hall ceiling bead", 0, 9.17, d+.17, (19.08,.09,.09), "A5714F")

    # The sealed upper chamber is visible from both elevated crossings.
    for rise,height,depth,tint in (
        (13.14,.52,.45,"713F39"),(13.46,.12,.51,"BF9465"),(17.89,.41,.47,"80473E"),
        (18.17,.14,.53,"BB8C61"),(18.68,.24,.43,"704138"),
    ):
        detail("Upper front gallery stringcourse", 0, rise, -14.56, (15.22,height,depth), tint)
    for u in (-7.17,-2.55,2.55,7.17):
        detail("Upper front gallery upright", u, 15.76, -14.55, (.42,5.32,.43), "784137")
        detail("Upper front gallery gold edge", u-.13, 15.71, -14.308,
               (.075,4.92,.08), "B9865D", metal)
    for u in (-5.12,0,5.12):
        detail("Upper front window bronze sill", u, 13.56, -14.15,
               (3.49,.14,.58), "C69462", metal)
    for side in (-1,1):
        u = side*7.48
        for rise,height,tint in ((12.69,.39,"793E36"),(13.08,.14,"C09463"),(18.36,.48,"70403A"),
                                 (18.68,.16,"BA8B5E")):
            detail("Upper chamber stringcourse", u, rise, -20.37, (.38,height,11.67), tint)
        for d in (-25.60,-20.37,-15.15):
            detail("Upper chamber cedar upright", u, 15.69, d, (.37,5.72,.49), "934B3D")
        for d in (-22.96,-17.78):
            detail("Deep side shutter frame", side*7.56, 15.59, d, (.37,3.76,3.73), "683F41")
            detail("Amber side shutter paper", side*7.77, 15.59, d, (.085,3.32,3.30), "DDA774", neon)
            detail("Side shutter bronze sill", side*7.77, 13.72, d, (.42,.16,3.81), "C89863", metal)
            for offset in (-.99,0,.99):
                detail("Side shutter upright", side*7.86, 15.59, d+offset, (.11,3.43,.10), "8E584B")
                detail("Side shutter cross rail", side*7.88, 15.59+offset, d, (.08,.10,3.40), "8E584B")

    for u in (-5.10,0,5.10):
        detail("Rear chamber shutter frame", u, 15.60, -26.13, (3.54,3.75,.28), "713F3D")
        detail("Amber rear shutter paper", u, 15.60, -26.31, (3.23,3.41,.09), "BD8B67", neon)
        for offset in (-.81,0,.81):
            detail("Rear shutter upright", u+offset, 15.60, -26.41, (.10,3.49,.11), "9B6552")
            detail("Rear shutter cross rail", u, 15.60+offset, -26.42, (3.27,.11,.11), "9B6552")

    # The inner faces of the two flanking houses frame the ramp and stairs.
    # These panels project less than half a stud from the existing walls.
    for side, u, depth, height, wall_width in ((-1, -11.50, -10, 9, 13), (1, 10.50, -11, 11, 14)):
        top = height - 3.51
        inward = -side
        for rise, band, tint in ((-3.22, .64, "62566D"), (-1.95, .30, "855C58"),
                                 (-1.63, .095, "BE9166"), (top - .22, .45, "735067"),
                                 (top + .08, .15, "C69D6E")):
            detail("Inner gallery stringcourse", u + inward * .10, rise, depth,
                   (.27, band, wall_width -.55), tint)
        for d in (-wall_width * .44, -2.18, 2.18, wall_width * .44):
            detail("Inner gallery cedar upright", u + inward * .13, (top - 3.11) / 2, depth + d,
                   (.27, top + 3.11, .34), "84585E")
            detail("Inner gallery warm upright edge", u + inward * .28, (top - 3.02) / 2,
                   depth + d - .09, (.075, top + 2.68, .064), "AE7C69")
        for d in (-4.27, 0, 4.27):
            y = (top - 1.35) / 2
            detail("Closed gallery shutter frame", u + inward * .17, y, depth + d,
                   (.24, 3.32, 2.79), "68475A")
            detail("Closed gallery shutter panel", u + inward * .31, y, depth + d,
                   (.07, 3.06, 2.50), "88717B", fabric)
            for stripe in (-.72, 0, .72):
                detail("Closed gallery shutter slat", u + inward * .36, y + stripe, depth + d,
                       (.08, .11, 2.58), "A18B8A")
            detail("Closed gallery shutter sill", u + inward * .29, y - 1.70, depth + d,
                   (.32, .14, 2.96), "B58865")
