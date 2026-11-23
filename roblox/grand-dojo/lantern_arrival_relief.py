"""Layered festival rigging over Lantern Circuit's existing market court."""

from math import hypot


def build_lantern_arrival_relief(town, x, y, z, *, item, prop, part, beam, triangle,
                                 slate, wood, cloth, metal, neon):
    canopy = item(town, "Model", "Lantern Circuit festival canopy")
    prop(canopy, "token", "ModelStreamingMode", 1)
    prop(canopy, "token", "LevelOfDetail", 4)

    def piece(group, name, point, size, tint, material, **options):
        detail = part(group, name, point, size, tint, material=material,
                      collide=False, **options)
        prop(detail, "bool", "CastShadow", False)
        return detail

    def mast(group, point, tint):
        px, crown, pz = point
        shaft = crown - y
        piece(group, "Festival mast slate socket", (px, y + .22, pz),
              (1.39, .46, 1.38), "8D7B8B", slate)
        piece(group, "Mast plinth cap", (px, y + .51, pz),
              (1.17, .17, 1.16), "B39998", slate)
        piece(group, "Festival lacquer mast", (px, y + shaft / 2 + .13, pz),
              (.54, shaft - .25, .56), tint, wood)
        for lift, cap, shade in ((.63, .79, "886073"), (2.75, .66, "BF875F"),
                                 (shaft - 1.06, .68, "B98960")):
            piece(group, "Mast binding", (px, y + lift, pz),
                  (cap, .16, cap), shade, metal)
        piece(group, "Gilt knob", (px, crown + .27, pz),
              (.44, .51, .44), "C78A52", metal, shape=0)

    def lantern(group, anchor, scale, silk):
        px, py, pz = anchor
        center = py - 1.04 * scale
        beam(group, "Braided lantern hanger", anchor, (px, py - scale * .40, pz), .081, "B08059")
        piece(group, "Folded lantern silk", (px, center, pz),
              (.91 * scale, 1.24 * scale, .91 * scale), silk, neon, shape=0)
        for offset, width, height in ((-.48, .61, .065), (0, .95, .033), (.48, .61, .065)):
            piece(group, "Lantern bronze band", (px, center + offset * scale, pz),
                  (height * scale, width * scale, width * scale),
                  "B27B58", metal, shape=2, roll=90)
        piece(group, "Lantern silk tassel", (px, center - .77 * scale, pz),
              (.13 * scale, .36 * scale, .14 * scale), "A65762", cloth, roll=7)

    def pennant(group, anchor, along_x, along_z, hand, tint):
        px, py, pz = anchor
        normal_x, normal_z = along_z * hand, -along_x * hand
        top_left = (px - along_x * .39, py, pz - along_z * .39)
        top_right = (px + along_x * .39, py, pz + along_z * .39)
        seam = (px + normal_x * .13, py - .08, pz + normal_z * .13)
        tip = (px - normal_x * .22, py - .94, pz - normal_z * .22)
        for a, b, color in ((top_left, seam, tint), (seam, top_right, "E1AA6D")):
            triangle(group, a, b, tip, color, name="Festival silk pennant",
                     material=cloth, thickness=.036, shadow=False)

    east = (x + 6.2, y + 10.65, z + 8.5)
    west = (x - 6.8, y + 14.8, z + 8.65)
    north = (x - 7.06, y + 14.8, z - 7.5)
    west_cuff = (west[0], y + 11.85, west[2])
    for anchor, tint in ((east, "87465E"), (west, "754461"), (north, "754461")):
        mast(canopy, anchor, tint)
    piece(canopy, "Lower festoon saddle", west_cuff, (.70, .23, .70), "C38B60", metal)

    # Give the southern walk its own line of lanterns and suspend a higher
    # string farther into the court. A shared west mast carries both.
    for row, (start, end, sag, lamps, pennants, colors) in enumerate((
        (east, west_cuff, 1.18, (.16,.39,.61,.84), (.27,.50,.73), ("F6B868", "F5CE8B", "EAA188")),
        (west, north, 1.93, (.13,.33,.52,.71,.89), (.22,.42,.62,.81), ("F3BA78", "DFA2C8", "A1D0BA")),
    )):
        wires = item(canopy, "Model", "Festival lantern cord")
        length = hypot(end[0] - start[0], end[2] - start[2])
        along_x, along_z = (end[0] - start[0]) / length, (end[2] - start[2]) / length

        def position(t):
            px, py, pz = tuple(a + (b - a) * t for a, b in zip(start, end))
            return px, py - 4 * sag * t * (1 - t), pz

        for i in range(10):
            beam(wires, "Festoon cord", position(i / 10), position((i + 1) / 10),
                 .069, "8E6570")
        for i, t in enumerate(lamps):
            lantern(wires, position(t), (1.0, .87, 1.15, .91, 1.03)[i], colors[i % len(colors)])
        for i, t in enumerate(pennants):
            pennant(wires, position(t), along_x, along_z, -1 if (row + i) % 2 else 1,
                    ("AD6287", "CC7B75", "71668E", "648E89")[i])
        for detail in wires.iter("Item"):
            if detail.get("class") in ("Part", "WedgePart") and detail.find("Properties/bool[@name='CastShadow']") is None:
                prop(detail, "bool", "CastShadow", False)
