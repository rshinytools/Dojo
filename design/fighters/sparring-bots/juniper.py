"""Juniper Tortoise, an original jade-armored defensive sparring fighter."""

from math import cos, sin, sqrt, tau


def build(p):
    """Build an articulated neutral guard with the face toward negative Y."""
    torso, head = "Torso", "Head"
    moss = p.material("Juniper olive skin", "7E956A", .76, 84)
    sage = p.material("Warm sage muzzle", "A6AF7D", .74, 89)
    shadow = p.material("Dark olive folds", "425B47", .81, 82)
    eyes = p.material("Warm eye ivory", "FFF0C6", .46)
    amber = p.material("Amber iris", "AD672B", .43)
    ink = p.material("Deep brown pupil and lip", "2A3028", .61)
    jade = p.material("Dyed evergreen cloth", "244B43", .89, 122)
    teal = p.material("Faded jade weave", "467366", .87, 132)
    cream = p.material("Natural cream woven wrap", "E0C999", .9, 149)
    cream_dark = p.material("Wrap seam and piping", "BEA478", .88, 146)
    leather = p.material("Dark copper-brown leather", "5A4030", .85, 107)
    copper = p.material("Antique copper alloy", "B5794B", .56, 42, .51)
    gold = p.material("Burnished copper edge", "D7AA71", .43, 53, .54)
    shell_dark = p.material("Deep evergreen shell seams", "173C34", .76, 68)
    shell_mid = p.material("Forest jade shell plates", "335F4D", .67, 78)
    shell_lit = p.material("Sage green shell grain", "63825C", .65, 73)

    def front_plate(group, name, outline, depth, material, thickness=.045, bevel=.024):
        return p.plate(group, name, [(x, depth, z) for x, z in outline], material,
                       thickness=thickness, bevel=bevel)

    p.loft(torso, "Fitted evergreen fighting vest", (
        (1.38, 0, .10, .57, .37), (1.65, 0, .04, .77, .48),
        (2.24, 0, .07, .91, .53), (2.83, 0, .12, .98, .52),
        (3.12, 0, .16, .77, .39), (3.30, 0, .15, .43, .32),
    ), jade, bevel=.045)
    front_plate(torso, "Copper plastron border",
                ((-.54, 1.88), (.54, 1.88), (.76, 2.60), (.60, 2.93),
                 (.29, 3.08), (-.34, 3.08), (-.60, 2.95), (-.77, 2.58)),
                -.446, copper, thickness=.12, bevel=.034)
    front_plate(torso, "Cream upper plastron inset",
                ((-.63, 2.52), (.63, 2.52), (.59, 2.78), (.40, 2.96),
                 (-.38, 2.96), (-.60, 2.78)), -.485, cream)
    front_plate(torso, "Cream lower plastron inset",
                ((-.43, 1.99), (.43, 1.99), (.60, 2.43), (-.60, 2.43)), -.482, cream_dark)
    p.rounded_box(torso, "Raised plastron divider", (0, -.525, 2.46), (1.23, .065, .075), gold, .022)
    p.tube(torso, "Folded diagonal jade lapel", ((-.71, -.43, 2.97), (-.28, -.52, 2.77),
           (.25, -.51, 2.64), (.72, -.43, 2.43)), (.105, .095, .074, .073), teal, sides=6, aspect=.75)
    p.loft(torso, "Broad tied waist wrap", ((1.48, 0, .055, .67, .44), (1.57, 0, .06, .77, .52),
           (1.75, 0, .07, .81, .50), (1.80, 0, .08, .77, .47)), leather, bevel=.035)
    p.rounded_box(torso, "Copper sash buckle", (0, -.464, 1.65), (.44, .14, .30), copper, .058)
    p.rounded_box(torso, "Jade sash center", (0, -.545, 1.65), (.28, .04, .17), shell_lit, .016)
    p.loft(torso, "Padded neckline", ((3.08, 0, .12, .51, .39), (3.26, 0, .05, .49, .37),
           (3.49, 0, -.02, .40, .33)), teal, bevel=.033)

    shell_sides = 16
    spokes = [(cos(tau * i / shell_sides), sin(tau * i / shell_sides)) for i in range(shell_sides)]

    def back_surface(u, v, offset=0):
        rise = sqrt(max(0, 1 - u * u - v * v))
        return (1.245 * u, .70 + .995 * rise + offset, 2.61 + 1.37 * v)

    def shell_ring(radius, depth=None):
        return [back_surface(radius * u, radius * v) if depth is None
                else (1.245 * radius * u, depth, 2.61 + 1.37 * radius * v) for u, v in spokes]

    def band_faces(rings):
        return [tuple((level * shell_sides + i) for level, i in
                      ((r, i), (r + 1, i), (r + 1, (i + 1) % shell_sides), (r, (i + 1) % shell_sides)))
                for r in range(rings - 1) for i in range(shell_sides)]

    skin_rings = [shell_ring(.87, .24), shell_ring(1, .68), shell_ring(.93), shell_ring(.71), shell_ring(.44)]
    skin_vertices = [point for ring in skin_rings for point in ring] + [back_surface(0, 0)]
    tip = len(skin_vertices) - 1
    shoulder = (len(skin_rings) - 1) * shell_sides
    skin_faces = band_faces(len(skin_rings)) + [(i + shoulder, tip, (i + 1) % shell_sides + shoulder)
                                                   for i in range(shell_sides)]
    p.mesh(torso, "Deep shell dome", skin_vertices, skin_faces + [tuple(range(shell_sides))], shell_dark)
    rim = (shell_ring(.96, .58), shell_ring(1.025, .71), shell_ring(.987, .88), shell_ring(.938, .98))
    p.mesh(torso, "Layered antique copper shell rim", [point for ring in rim for point in ring], band_faces(len(rim)),
           copper, bevel=.016)

    def scute(name, polygon, material):
        u_mid = sum(u for u, _ in polygon) / len(polygon)
        v_mid = sum(v for _, v in polygon) / len(polygon)
        sunk = [back_surface(u, v, -.10) for u, v in polygon]
        outline = [back_surface(u, v, .024) for u, v in polygon]
        inset = [back_surface(u_mid + (u - u_mid) * .86, v_mid + (v - v_mid) * .86, .068)
                 for u, v in polygon]
        vertices = sunk + outline + inset + [back_surface(u_mid, v_mid, .085)]
        n = len(outline)
        faces = [(row + i, row + n + i, row + n + (i + 1) % n, row + (i + 1) % n)
                 for row in (0, n) for i in range(n)]
        faces += [(2 * n + i, 3 * n, 2 * n + (i + 1) % n) for i in range(n)]
        p.mesh(torso, name, vertices, faces, material)

    scute("Raised central hexagon", ((-.27, -.15), (0, -.34), (.27, -.15), (.27, .15),
          (0, .34), (-.27, .15)), shell_lit)
    scute("Lower keel scute", ((-.28, -.65), (0, -.84), (.28, -.65), (.22, -.47), (0, -.39),
          (-.22, -.47)), shell_mid)
    scute("Upper keel scute", ((-.23, .48), (0, .39), (.23, .48), (.28, .64), (0, .84),
          (-.28, .64)), shell_mid)
    for side, name in ((1, "Right"), (-1, "Left")):
        for label, polygon, material in (
            ("shoulder scute", ((.32, .18), (.54, .13), (.77, .29), (.66, .53), (.41, .65), (.31, .35)), shell_mid),
            ("flank scute", ((.32, -.12), (.49, -.23), (.80, -.16), (.89, 0), (.80, .20),
              (.56, .10), (.32, .13)), shell_lit),
            ("lower flank scute", ((.30, -.35), (.41, -.63), (.63, -.53), (.76, -.28),
              (.50, -.27), (.32, -.17)), shell_mid),
        ):
            points = [(side * u, v) for u, v in polygon]
            scute(f"{name} {label}", points if side == 1 else list(reversed(points)), material)
        p.rounded_box(torso, f"{name} shoulder copper clasp", (side * .87, .31, 3.07),
                      (.34, .35, .34), copper, .054, (0, side * .24, 0))

    p.loft(head, "Tortoise neck", ((3.23, 0, -.04, .35, .31), (3.49, 0, -.13, .40, .36),
           (3.71, 0, -.23, .48, .40)), moss, bevel=.043)
    p.loft(head, "Broad tortoise head", ((3.55, 0, -.31, .45, .37), (3.73, 0, -.36, .62, .49),
           (4.04, 0, -.35, .70, .53), (4.28, 0, -.30, .66, .50), (4.49, 0, -.22, .51, .42),
           (4.60, 0, -.17, .31, .30)), moss, bevel=.062)
    p.loft(head, "Tortoise blunt muzzle", ((3.63, 0, -.65, .37, .31), (3.75, 0, -.71, .55, .38),
           (3.90, 0, -.73, .51, .36), (4.04, 0, -.67, .35, .29)), sage, bevel=.058)
    p.loft(head, "Rounded lower jaw", ((3.56, 0, -.62, .34, .32), (3.66, 0, -.65, .50, .39),
           (3.77, 0, -.66, .48, .36)), sage, bevel=.044)
    p.tube(head, "Set mouth", ((-.34, -.995, 3.73), (-.16, -1.060, 3.71), (.12, -1.065, 3.715),
           (.35, -.99, 3.73)), (.023, .020, .020, .021), shadow, sides=6)
    for side, name in ((1, "Right"), (-1, "Left")):
        p.ellipse(head, f"{name} nostril", (side * .154, -1.067, 3.925), (.048, .022, .029), shadow)
        p.rounded_box(head, f"{name} cheek plate", (side * .615, -.676, 3.927), (.27, .24, .26),
                      sage, .079, (0, -side * .23, side * .22))
        p.ellipse(head, f"{name} eye socket", (side * .395, -.816, 4.095), (.252, .141, .167), shadow)
        p.ellipse(head, f"{name} narrow eye", (side * .395, -.898, 4.094), (.184, .095, .103), eyes)
        p.ellipse(head, f"{name} amber iris", (side * .365, -.974, 4.093), (.076, .031, .075), amber)
        p.ellipse(head, f"{name} dark pupil", (side * .363, -.998, 4.095), (.044, .016, .052), ink)
        p.ellipse(head, f"{name} eye catchlight", (side * .365 - .021, -1.012, 4.125), (.019, .010, .019), eyes)
        p.rounded_box(head, f"{name} stern brow", (side * .399, -.868, 4.211), (.45, .25, .115),
                      moss, .050, (0, -side * .25, side * .16))
        front_plate(head, f"{name} temple armor", ((side * .47, 4.28), (side * .64, 4.27),
                    (side * .58, 4.43), (side * .47, 4.49)) if side == 1 else
                    ((side * .47, 4.49), (side * .58, 4.43), (side * .64, 4.27), (side * .47, 4.28)),
                    -.65, teal, thickness=.065, bevel=.018)
    front_plate(head, "Copper brow ridge", ((-.29, 4.38), (0, 4.314), (.29, 4.38), (.19, 4.48),
                (-.20, 4.48)), -.700, copper, thickness=.085)

    pivots = {torso: (0, .06, 2.55), head: (0, -.12, 3.43)}
    for side, name in ((1, "Right"), (-1, "Left")):
        arm, leg = f"{name} Arm", f"{name} Leg"
        lead = 0 if side == 1 else .15
        pivots[arm] = (side * .89, .09, 2.98)
        pivots[leg] = (side * .47, .05, 1.53)
        p.tube(arm, f"{name} bent arm", ((side * .92, .06, 2.98), (side * 1.10, -.15, 2.77),
               (side * 1.18, -.34 + lead, 2.55), (side * 1.14, -.58 + lead, 2.66),
               (side * 1.17, -.80 + lead, 2.83)), (.34, .33, .30, .295, .26), moss, sides=9)
        p.rounded_box(arm, f"{name} raised shoulder armor", (side * .97, -.02, 3.06), (.78, .75, .43),
                      shell_mid, .113, (0, side * .25, side * .10))
        p.rounded_box(arm, f"{name} copper shoulder rim", (side * .98, -.359, 3.04), (.62, .11, .18),
                      copper, .044, (0, side * .22, side * .14))
        p.rounded_box(arm, f"{name} cream forearm bind", (side * 1.16, -.56 + lead, 2.63), (.62, .49, .54),
                      cream, .10, (-.40, side * .05, side * .08))
        for index, shift in enumerate((-.08, .07), 1):
            p.rounded_box(arm, f"{name} forearm wrap band {index}", (side * 1.17, -.56 + shift + lead, 2.65),
                          (.625, .083, .54), cream_dark, .029, (-.40, side * .05, side * .08))
        p.rounded_box(arm, f"{name} jade padded glove", (side * 1.16, -.924 + lead, 2.91), (.75, .72, .70),
                      jade, .152, (-.22, side * .11, side * .10))
        p.rounded_box(arm, f"{name} glove knuckle pad", (side * 1.155, -1.202 + lead, 2.995), (.67, .19, .43),
                      teal, .076, (-.18, side * .11, side * .10))
        p.rounded_box(arm, f"{name} padded thumb", (side * .880, -.968 + lead, 2.835), (.26, .41, .37),
                      jade, .098, (-.27, side * .24, side * .12))
        p.rounded_box(arm, f"{name} leather glove strap", (side * 1.168, -.86 + lead, 2.68), (.69, .22, .14),
                      leather, .053, (-.23, side * .1, side * .1))

        p.loft(leg, f"{name} sturdy leg", ((.34, side * .58, -.14, .29, .31),
               (.65, side * .58, -.08, .31, .33), (.95, side * .54, .01, .35, .35),
               (1.30, side * .49, .05, .38, .36), (1.62, side * .45, .08, .37, .34)), moss, bevel=.055)
        p.rounded_box(leg, f"{name} planted foot", (side * .585, -.275, .22), (.73, .94, .44), moss, .121)
        p.rounded_box(leg, f"{name} foot pad", (side * .585, -.555, .18), (.62, .43, .31), sage, .094)
        for index, offset in enumerate((-.17, 0, .17), 1):
            p.rounded_box(leg, f"{name} short toe {index}", (side * .585 + offset, -.743, .18),
                          (.13, .15, .105), cream_dark, .037)
        p.rounded_box(leg, f"{name} cream ankle wrap", (side * .585, -.125, .57), (.705, .70, .36), cream, .103)
        p.rounded_box(leg, f"{name} ankle binding", (side * .585, -.125, .56), (.71, .705, .065),
                      cream_dark, .028)
        p.rounded_box(leg, f"{name} fitted jade thigh guard", (side * .48, -.077, 1.19), (.79, .77, .74),
                      jade, .093, (0, -side * .08, 0))
        p.rounded_box(leg, f"{name} copper knee cap", (side * .542, -.337, .92), (.52, .24, .40),
                      copper, .074, (0, -side * .12, 0))

    return pivots
