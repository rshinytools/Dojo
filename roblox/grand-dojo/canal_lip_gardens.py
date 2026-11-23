"""Low ledges and reeds on either side of the Festival Canal swim stairs."""

from math import atan2, cos, degrees, hypot, radians, sin


STONE_OUTLINE = (
    (-.49, -.18), (-.30, -.47), (.19, -.44), (.48, -.14),
    (.44, .27), (.02, .47), (-.40, .30),
)
STONE_RISE = (.76, .93, 1.0, .88, .70, .79, .89)


def build_canal_lip_gardens(canal, *, item, prop, part, triangle, garden_prop,
                          rock, grass, stone_variant, variant_field):
    gardens = item(canal, "Folder", "Lotus inlet planted stone edges")

    def stone(bank, center, size, yaw, shading):
        x, y, z = center
        width, rise, depth = size
        c, s = cos(radians(yaw)), sin(radians(yaw))

        def ring(scale, offset, level):
            rim = []
            for (dx, dz), height in zip(STONE_OUTLINE, STONE_RISE):
                a, b = width * (dx * scale + offset), depth * dz * scale
                rim.append((x + c * a + s * b, y + level * rise * height, z - s * a + c * b))
            return rim

        base = ring(.98, -.03, 0)
        crown = ring(.77, .08, 1)
        center_cap = (x + .10 * c, y + .94 * rise, z - .10 * s)
        mark = len(bank)
        shaded, middle, lit = shading
        for index, a in enumerate(base):
            j = (index + 1) % len(base)
            side_tint = (shaded, middle, shaded, middle, lit, middle, shaded)[index]
            for face in ((a, base[j], crown[index]), (base[j], crown[j], crown[index])):
                triangle(bank, *face, side_tint, name="Waterline slate break",
                         material=rock, thickness=.065, shadow=False)
            cap_tint = middle if index in (0, 5) else lit
            triangle(bank, center_cap, crown[index], crown[j], cap_tint,
                     name="Warm wet stone cap", material=rock, thickness=.071, shadow=False)
        for piece in list(bank)[mark:]:
            prop(piece, "string", variant_field, stone_variant)

    def reed(bank, root, bearing, height):
        x, y, z = root
        angle = radians(bearing)
        dx, dz = sin(angle), cos(angle)

        def point(along, lift, across=0):
            return x + along * dx + across * dz, y + lift, z + along * dz - across * dx

        elbow, tip = point(.20, height * .65), point(.47, height)
        for a, b, width, tint in ((root, elbow, .037, "9EAA58"),
                                  (elbow, tip, .029, "C5BC78")):
            delta_x, delta_y, delta_z = (end - start for start, end in zip(a, b))
            horizontal = hypot(delta_x, delta_z)
            part(bank, "Curved inlet reed stem", tuple((v + w) * .5 for v, w in zip(a, b)),
                 (width, width, hypot(horizontal, delta_y)), tint,
                 yaw=degrees(atan2(delta_x, delta_z)), pitch=degrees(atan2(-delta_y, horizontal)),
                 collide=False)
        part(bank, "Backlit inlet sedge head", tip, (.12, .27, .115), "E6CF96", shape=0,
             yaw=bearing, roll=-24, collide=False)
        for side, tint in ((-1, "9DAC61"), (1, "B0B66B")):
            triangle(bank, point(.02, .25), point(.13, .35, .12 * side),
                     point(.40, .54, .27 * side), tint, name="Spreading inlet reed leaf",
                     thickness=.026, material=grass, shadow=False)

    for label, stones, plants, reeds, wet_flecks in (
        ("South inlet ledge",
         (((-6.62, -.12, 58.72), (2.30, .57, 1.30), -16, ("867664", "A89079", "C7AF92")),
          ((-7.35, -.17, 59.19), (1.04, .38, .69), 22, ("7C7369", "A28C78", "BFA68F"))),
         (("meadowCover", (-6.21, .33, 58.67), .085, 57, "BBC76D"),
          ("meadowGrass", (-6.92, .25, 58.97), .071, 126, "B1C062"),
          ("mossFlowers", (-6.37, .31, 58.95), .063, 48, "E9AEBC"),
          ("reeds", (-7.28, -.06, 58.16), .097, 65, "A4AE58")),
         (((-6.37, .29, 58.77), -129, 1.15), ((-6.59, .28, 58.92), -100, .92),
          ((-6.26, .31, 58.91), -161, 1.32)),
         ((-7.54, 58.53, .33, -17), (-7.61, 58.82, .25, -13))),
        ("North inlet ledge",
         (((-6.25, -.15, 50.58), (1.81, .59, 1.44), 25, ("8D7B6C", "AA927D", "C9B095")),
          ((-7.19, -.16, 50.37), (1.31, .37, .77), -21, ("8A786C", "AB9583", "C4AD93"))),
         (("meadowCover", (-6.39, .28, 50.60), .086, 35, "B2C66D"),
          ("meadowGrass", (-6.14, .32, 50.95), .068, 94, "A8BC63"),
          ("mossFlowers", (-7.04, .15, 50.40), .068, 81, "E6ABBA"),
          ("reeds", (-7.38, -.05, 50.57), .081, 35, "AFB663")),
         (((-6.32, .30, 50.47), -76, .98), ((-6.09, .30, 50.62), -100, 1.14)),
         ((-7.69, 50.48, .34, 9), (-7.29, 51.08, .24, -24))),
    ):
        bank = item(gardens, "Model", label)
        prop(bank, "token", "ModelStreamingMode", 1)
        prop(bank, "token", "LevelOfDetail", 4)
        for center, size, yaw, shading in stones:
            stone(bank, center, size, yaw, shading)
        for key, position, scale, yaw, tint in plants:
            garden_prop(bank, key, position, scale, yaw, tint)
        for root, yaw, height in reeds:
            reed(bank, root, yaw, height)
        for x, z, length, angle in wet_flecks:
            part(bank, "Quiet inlet reflection", (x, .074, z), (length, .011, .040),
                 "DDCAA0", yaw=angle, shape=0, transparency=.58, collide=False)
        for detail in bank.findall("Item"):
            if detail.find("Properties/bool[@name='CastShadow']") is None:
                prop(detail, "bool", "CastShadow", False)
