"""Decorative skyline and temples for the Cloudbreak Wind Trial."""

from math import cos, radians, sin


LACQUER = "9C4135"
SHADED_LACQUER = "71383A"
CEDAR = "835344"
GOLD = "DFAC61"
JADE = "528477"
DEEP_JADE = "425F67"
ROCK_TONES = ("817488", "8E7F8E", "A095A7", "807890", "9C8B9C", "786C86")


def build_cloudbreak_scenery(course, *, item, prop, part, beam, triangle, swept_roof,
                             festival_lantern, slate, rock, wood, metal, fabric, neon):
    scenery = item(course, "Model", "Cloudbreak sunset scenery")
    prop(scenery, "token", "LevelOfDetail", 4)

    def solid(parent, name, point, size, tint, material, **options):
        return part(parent, name, point, size, tint, material=material, collide=False, **options)

    def line(parent, name, a, b, gauge, tint):
        return beam(parent, name, a, b, gauge, tint, collide=False)

    def face(parent, name, a, b, c, tint, material, thickness=.19):
        triangle(parent, a, b, c, tint, name=name, material=material, thickness=thickness,
                 shadow=False, collide=False)

    def island(parent, x, top, z, width, depth, drop, phase, palette=ROCK_TONES, *, distant=False, sides=6):
        """A broad stone shoulder with split bands tapering below the path."""
        rings = []
        bands = [(0, .78, 0, 0), (.15, 1, .04, -.05), (.54, .64, .16, .02), (1, .16, .12, .06)]
        if distant:
            del bands[2]
        for height, span, dx, dz in bands:
            ring = []
            for i in range(sides):
                angle = radians(phase + i * 360 / sides)
                variation = (1, .84, 1.09, .87, .96, .89)[i]
                ring.append((x + width * (dx + cos(angle) * span * variation / 2),
                             top - drop * height - (i % 3) * (1.1 if height > 0 else .09),
                             z + depth * (dz + sin(angle) * span * variation / 2)))
            rings.append(ring)
        crown = (x, top - .06, z)
        for i in range(sides):
            j = (i + 1) % sides
            face(parent, "Slate island crown", crown, rings[0][i], rings[0][j],
                 palette[(i + 2) % 6], slate, .24)
            for level, (above, below) in enumerate(zip(rings, rings[1:])):
                tone = palette[(i + level * 2) % 6]
                face(parent, "Tapered slate island", above[i], below[i], above[j], tone, rock, .28)
                face(parent, "Tapered slate island", above[j], below[i], below[j],
                     palette[(i + level * 2 + 1) % 6], rock, .25)

    def cloud(parent, x, y, z, width, depth, tint):
        for dx, dy, dz, stretch in ((-.29, -.18, .04, .64), (-.02, .35, -.07, .79),
                                    (.26, -.36, -.02, .65), (.43, -.75, .08, .48)):
            solid(parent, "Low lavender cloud bank", (x + dx * width, y + dy, z + dz * depth),
                  (width * stretch, 3.6 * stretch, depth * stretch), tint, slate,
                  shape=0, transparency=.18)

    def curl(parent, x, y, z, scale, tint, yaw=0):
        # A curling line and a loose trailing stroke, both flush with the plaque.
        swirl = ((-.85, -.16), (-.46, -.25), (.13, -.24), (.53, -.01), (.57, .28),
                 (.37, .48), (.03, .48), (-.17, .32), (-.12, .15), (.09, .14), (.19, .25))
        trail = ((-.83, -.51), (-.18, -.48), (.44, -.36), (.79, -.15))
        c, s = cos(radians(yaw)), sin(radians(yaw))
        for path in (swirl, trail):
            for a, b in zip(path, path[1:]):
                start = (x + a[0] * scale * c, y + a[1] * scale, z - a[0] * scale * s)
                end = (x + b[0] * scale * c, y + b[1] * scale, z - b[0] * scale * s)
                line(parent, "Carved cloud line", start, end, .07 * scale, tint)

    # Profiles are well below the landing faces. Every playable surface is in the course model.
    ridges = item(scenery, "Model", "Slate needles beneath the trial")
    island(ridges, 105.5, 31.34, -268.9, 14.6, 14.3, 24, 13)
    island(ridges, 118.6, 35.5, -289.7, 17.2, 15.1, 27, 32)
    island(ridges, 129.5, 47.85, -315.4, 17.5, 17.6, 32, 8)
    island(ridges, 146.6, 60.86, -350.55, 23, 11.9, 45, 26)
    cloud(ridges, 91, 5, -282, 39, 19, "B2A0BD")
    cloud(ridges, 116, 3, -317, 53, 21, "CEADBD")
    cloud(ridges, 152, 7, -366, 65, 28, "B6A2BF")
    cloud(ridges, 160, .3, -287, 46, 25, "B9ADC7")

    # Small rock shoulders seat both gate fragments outside the landing and approach lanes.
    torii = item(scenery, "Model", "Ruined crimson torii")
    for i, (x, z, top, lean, inward) in enumerate((
        (106, -260.75, 41.5, -.52, -1), (101.45, -280.35, 40.2, .66, 1),
    )):
        foot_y = 31.65
        island(torii, x + .16, 31.16, z + inward * 1.92, 5.24, 9.08, 12.56, 10,
               distant=True, sides=4)
        solid(torii, "Torii slate shoe", (x, foot_y, z), (1.91, 1.08, 1.88), "97899F", slate)
        solid(torii, "Torii foot collar", (x, foot_y + .64, z), (1.56, .31, 1.62), GOLD, metal)
        end = (x + lean, top, z + .20 * inward)
        line(torii, "Weathered red torii upright", (x, foot_y + .48, z), end, 1.21, LACQUER)
        line(torii, "Light along the torii upright", (x - .60, foot_y + .77, z - .29),
             (end[0] - .59, top - .37, end[2] - .29), .10, "C46850")
        for lift, shade in ((2.03, "9A7960"), (2.27, "B0936D"), (2.51, "8D6A54")):
            solid(torii, "Old rope binding", (x + lean * lift / (top - foot_y), foot_y + lift, z),
                  (1.26, .15, 1.26), shade, fabric)
        tip = (end[0] + .12, top - .13, z + inward * (3.37 if i == 0 else 2.44))
        line(torii, "Broken torii crossbeam", (end[0], top - .40, z - inward * 1.31), tip,
             .78, SHADED_LACQUER)
        line(torii, "Gilt torii roof cap", (end[0], top + .26, z - inward * 1.42),
             (tip[0], top + .31, tip[2]), .34, GOLD)
        for split, depth in ((-.24, .48), (.02, .73), (.28, .36)):
            line(torii, "Exposed torn timber", (tip[0] + split, top - .21, tip[2]),
                 (tip[0] + split * .76, top + .12 * (1 - depth), tip[2] + inward * depth),
                 .21, "A86647")
        cloth_z = z + inward * .50
        edge = ((x - .77, top - 1.02, cloth_z), (x + .79, top - .96, cloth_z),
                (x + .66, top - 3.56, cloth_z + .30), (x + .08, top - 3.18, cloth_z + .19),
                (x - .63, top - 3.74, cloth_z + .39))
        for a, b, c in ((0, 1, 3), (1, 2, 3), (0, 3, 4)):
            face(torii, "Torn red gate cloth", edge[a], edge[b], edge[c],
                 ("AE4A43", "9D403A", "B8544B")[a], fabric, .09)
        curl(torii, x, top - 2.05, cloth_z + .22, .55, GOLD)

    # Flanking jade carvings help frame the climb. The jump pads remain clear of the relief.
    carvings = item(scenery, "Model", "Jade cloud carvings")
    for x, y, z, yaw in ((129.9, 37.6, -286.4, -38), (109.1, 43.4, -305.1, 38)):
        base_y = y - 6.65
        c, s = cos(radians(yaw)), sin(radians(yaw))
        solid(carvings, "Carving slate pedestal", (x, base_y - .30, z), (4.85, 1.30, 2.52),
              "8C8296", slate, yaw=yaw)
        solid(carvings, "Weathered jade slab", (x, y, z), (3.40, 13.30, .88), DEEP_JADE,
              slate, yaw=yaw)
        for offset, angle in ((-1.78, -4), (1.78, 4)):
            solid(carvings, "Jade slab gold edge", (x + offset * c, y, z - offset * s),
                  (.22, 12.89, .93), GOLD, metal, yaw=yaw, roll=angle)
        solid(carvings, "Jade slab ridge cap", (x, y + 6.62, z), (4.23, .42, 1.22),
              "82A38D", slate, yaw=yaw)
        # The raised front image follows the slab angle.
        surface_x = x + .51 * s
        surface_z = z + .51 * c
        for lift, shade in ((-3.55, JADE), (0, "668F7D"), (3.55, JADE)):
            solid(carvings, "Jade cloud inset", (surface_x, y + lift, surface_z), (2.95, 2.76, .18),
                  shade, slate, yaw=yaw)
        curl(carvings, x + .63 * s, y + .08, z + .63 * c, 1.54, GOLD, yaw)

    temple = item(scenery, "Model", "Summit bell temple")
    tx, tz, floor = 146.5, -350.15, 62
    for offset in (-8.68, 8.68):
        for depth_offset in (-4.11, 3.47):
            x, z = tx + offset, tz + depth_offset
            solid(temple, "Temple slate pier", (x, floor + .57, z), (1.82, 1.14, 1.82),
                  "908298", slate)
            solid(temple, "Summit lacquer column", (x, floor + 4.98, z), (1.05, 8.0, 1.09),
                  LACQUER, wood)
            for elevation, width in ((1.20, 1.16), (6.66, 1.20), (8.92, 1.35)):
                solid(temple, "Temple brass column cuff", (x, floor + elevation, z), (width, .28, width),
                      GOLD, metal)
            foot = (x, floor + 6.74, z)
            head = (x - offset * .24, floor + 9.17, z)
            line(temple, "Temple carved cloud corbel", foot, head, .65, SHADED_LACQUER)
            line(temple, "Temple corbel gold seam", (foot[0], foot[1], z + .31),
                 (head[0], head[1], z + .31), .10, GOLD)
        line(temple, "Temple side tie", (tx + offset, floor + 9.15, tz - 4.7),
             (tx + offset, floor + 9.15, tz + 4.7), .57, CEDAR)
    for z in (tz - 4.33, tz + 3.65):
        solid(temple, "Vermilion bell temple eave", (tx, floor + 9.42, z), (18.7, .74, .94),
              SHADED_LACQUER, wood)
        solid(temple, "Gilt temple eave face", (tx, floor + 9.48, z + .48), (17.65, .16, .13),
              GOLD, metal)
    for offset in (-5.63, 5.63):
        x = tx + offset
        line(temple, "Hanging lantern hook", (x, floor + 9.08, tz + 4.02),
             (x, floor + 7.18, tz + 4.02), .11, SHADED_LACQUER)
        festival_lantern(temple, x, floor + 6.65, tz + 4.02, .64, light=False)
    swept_roof(temple, tx, floor + 9.81, tz, 20.55, 12.60, 3.58,
               fine_tiles=False, corner_sweep=1.06)
    solid(temple, "Summit roof gilded apex", (tx, floor + 13.83, tz), (.76, .47, .81), GOLD,
          metal, shape=0)

    # Distant islands echo the active cliff without creating alternate routes.
    distant = item(scenery, "Model", "Cloud sea islands")
    muted = ("9A8AA7", "A193AA", "B39EB4", "9A8AAA", "AF9DB4", "8F809F")
    island(distant, 175, 34.1, -403, 33, 30, 28, 28, muted, distant=True)
    island(distant, 194, 42.2, -368, 40, 34, 37, 4, muted, distant=True)
    island(distant, 211, 28.5, -323, 32, 26, 32, 21, muted, distant=True)
    cloud(distant, 193, 4.3, -402, 62, 27, "C4ABC2")
    cloud(distant, 210, 6.2, -353, 54, 23, "D2ADBF")
    for x, top, z in ((194, 40.2, -356.20), (174.7, 32.2, -391.8)):
        for off, width, height, tint in ((0, 2.18, 22, "97B9C9"), (-.66, .73, 18, "C2CFD7"),
                                        (.59, .56, 15, "B4C8D9")):
            solid(distant, "Distant waterfall ribbon", (x + off, top - height / 2, z + .12 * off),
                  (width, height, .12), tint, slate, transparency=.25)
        cloud(distant, x, top - 23.4, z, 14, 5, "C6B6CC")
    for x, y, z in ((193.9, 42.12, -369.3), (174.9, 34.0, -404.8)):
        solid(distant, "Island pagoda pedestal", (x, y + .36, z), (7.4, .76, 4.7), "958599", slate)
        solid(distant, "Island pagoda story", (x, y + 2.47, z), (5.6, 4.0, 3.4), "A26868", wood)
        for side in (-1, 1):
            solid(distant, "Distant pagoda roof plane", (x, y + 4.67, z + side * 1.12),
                  (7.1, .33, 2.64), "6B6687", slate, pitch=side * 21)
            line(distant, "Island pagoda eave", (x - 3.9, y + 4.43, z + side * 2.37),
                 (x + 3.9, y + 4.43, z + side * 2.37), .25, "AC846E")
        solid(distant, "Island pagoda roof crest", (x, y + 5.15, z), (6.34, .26, .32),
              "8B7390", slate)

    # The old lookout frames the opening camera off the playable staging ledge.
    foreground = item(scenery, "Model", "Cloudbreak overlook accents")
    solid(foreground, "Overlook lantern pewter foot", (61.55, 24.69, -270.71), (1.58, 1.24, 1.54),
          "91839B", slate)
    solid(foreground, "Overlook lacquer column", (61.55, 28.44, -270.71), (.61, 6.80, .65),
          LACQUER, wood)
    line(foreground, "Overlook lantern cranked arm", (61.55, 31.64, -270.71),
         (61.68, 31.88, -269.29), .23, SHADED_LACQUER)
    festival_lantern(foreground, 61.68, 30.74, -269.30, .78, light=False, tint="F9B76E")
    for i in range(3):
        solid(foreground, "Gold mast cap", (61.55, 31.87 + i * .21, -270.71),
              (.85 - i * .17, .23, .93 - i * .23), GOLD, neon if i == 2 else metal)
    for a, b in (((61.26, 26.15, -271.70), (63.9, 31.53, -273.38)),
                 ((63.9, 31.53, -273.38), (67.0, 33.85, -271.94)),
                 ((63.9, 31.53, -273.38), (65.0, 34.38, -273.74))):
        line(foreground, "Leaning blossom bough", a, b, .42, "775052")
    for i, (x, y, z, width) in enumerate(((63.9, 32.9, -273.5, 3.66), (65.2, 34.35, -273.72, 4.28),
                                           (67.1, 34.04, -272.04, 3.52), (68.2, 34.57, -272.96, 2.70),
                                           (64.9, 33.35, -271.90, 3.03), (64.1, 34.76, -274.52, 3.18))):
        solid(foreground, "Windward cherry blossom cluster", (x, y, z), (width, width * .47, width * .75),
              ("D894AF", "C7769B", "E6A5B9")[i % 3], slate, shape=0)

    # All scene pieces are ornamental, including pieces emitted by the shared roof and lantern helpers.
    for node in scenery.iter("Item"):
        props = node.find("Properties")
        if props.find("CoordinateFrame[@name='CFrame']") is None:
            continue
        for flag in ("CanCollide", "CanTouch", "CanQuery", "CastShadow"):
            old = props.find(f"bool[@name='{flag}']")
            if old is None:
                prop(node, "bool", flag, False)
            else:
                old.text = "false"
