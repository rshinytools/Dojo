"""Fire Salamander, the agile Magma starter from Cinder Terraces."""

from math import cos, hypot, sin, tau


LORE = (
    "A kiln courier from Cinder Terraces who learned to read a glaze by its color. "
    "The potters taught their runner to keep the heat moving, a lesson carried from the firing yard to the ring."
)
POWERS = {
    "Kiln Step": "A quick diagonal step into a palm strike with a brief ember arc.",
    "Stoke Counter": "Time a low guard, then answer an overextended strike with a short rising heat pulse.",
    "Magma Trail": "Sprint in an arc around the ring, leaving brief, readable patches of magma that pop foes up.",
}


def build(p):
    """Build a low staggered guard facing negative Y with seven articulation groups."""
    torso, head, tail = "Torso", "Head", "Tail"
    charcoal = p.material("Salamander charcoal skin", "383D44", .61, 112)
    smoke = p.material("Warm blue-gray skin planes", "56575D", .67, 104)
    underbelly = p.material("Matte slate underskin", "6C6360", .72, 101)
    ink = p.material("Warm charcoal mouth and eyes", "232326", .62)
    gold = p.material("Gold salamander markings", "F4AD32", .62, 112)
    ochre = p.material("Deep orange salamander markings", "DB8024", .66, 105)
    firelight = p.material("Apricot iris catchlight", "FFE4A5", .43)
    iris = p.material("Deep amber iris", "C27835", .43)
    scarlet = p.material("Kiln-dyed deep scarlet cloth", "713338", .88, 132)
    brick = p.material("Weathered fired-red cloth", "A14F44", .87, 130)
    amber = p.material("Ochre apron canvas", "C48848", .86, 132)
    ochre_light = p.material("Warm ochre twill edging", "E0AA60", .87, 138)
    soot = p.material("Soot-black padded canvas", "303039", .89, 145)
    glaze = p.material("Glazed ember ceramic", "BC5540", .49, 73)
    glaze_edge = p.material("Honey glaze on ceramic ridges", "DE8C50", .47, 76)
    bronze = p.material("Satin kiln bronze fittings", "B58859", .55, 52, .42)

    def front(group, name, outline, y, material, thickness=.055, bevel=.02):
        return p.plate(group, name, [(x, y, z) for x, z in outline], material,
                       thickness=thickness, bevel=bevel)

    p.loft(torso, "Athletic salamander frame", (
        (1.46, 0, .10, .43, .33), (1.76, 0, .12, .54, .40),
        (2.20, 0, .08, .53, .36), (2.69, 0, .05, .65, .38),
        (3.10, 0, .00, .75, .39), (3.30, 0, .015, .61, .32),
        (3.47, 0, .00, .30, .29),
    ), charcoal, bevel=.05)
    p.loft(torso, "Sleeveless kiln-runner jacket", ((1.69, 0, .08, .54, .42), (1.92, 0, .08, .61, .43),
           (2.28, 0, .08, .60, .40), (2.84, 0, .02, .72, .43), (3.22, 0, .012, .68, .35)),
           scarlet, bevel=.037)
    front(torso, "Overlapping ochre jacket front", ((-.35, 1.96), (.27, 1.96), (.49, 2.58),
          (.44, 2.90), (.14, 3.24), (-.37, 3.20), (-.53, 2.82), (-.42, 2.40)),
          -.45, amber, thickness=.14)
    p.tube(torso, "Woven diagonal jacket binding", ((-.49, -.35, 3.20), (-.30, -.465, 3.00),
           (-.03, -.481, 2.72), (.25, -.465, 2.51), (.44, -.38, 2.31)),
           (.072, .061, .06, .057, .055), ochre_light, sides=7, aspect=.83)
    p.tube(torso, "Soot canvas collar", ((-.34, -.22, 3.41), (-.19, -.30, 3.36), (.07, -.324, 3.34),
           (.26, -.291, 3.37), (.34, -.22, 3.41)), (.055, .054, .054, .053, .052), soot, sides=7)
    p.loft(torso, "Wide burnt-red waist wrap", ((1.73, 0, .08, .58, .42), (1.82, 0, .08, .64, .47),
           (2.035, 0, .072, .625, .44), (2.14, 0, .07, .60, .42)), brick, bevel=.04)
    p.rounded_box(torso, "Kiln brass clasp", (0, -.42, 1.965), (.37, .135, .26), bronze, .050)
    p.rounded_box(torso, "Inset fired-clay clasp tile", (0, -.495, 1.968), (.24, .052, .153), glaze, .022)
    front(torso, "Short split kiln apron left panel", ((-.49, 1.38), (-.085, 1.44), (-.085, 1.88),
          (-.47, 1.86)), -.351, amber, thickness=.085, bevel=.034)
    front(torso, "Short split kiln apron right panel", ((.08, 1.45), (.49, 1.34), (.47, 1.85),
          (.08, 1.88)), -.36, soot, thickness=.085, bevel=.034)
    front(torso, "Apron bronze piping left", ((-.44, 1.44), (-.385, 1.454), (-.379, 1.789),
          (-.44, 1.79)), -.394, ochre_light, thickness=.026, bevel=.010)
    front(torso, "Apron bronze piping right", ((.382, 1.441), (.445, 1.421), (.425, 1.784),
          (.369, 1.785)), -.396, ochre_light, thickness=.026, bevel=.010)
    p.tube(torso, "Tied rear jacket cord", ((-.40, .423, 1.91), (-.16, .52, 1.95), (.085, .525, 1.905),
           (.38, .46, 1.925)), (.058, .064, .065, .057), ochre_light, sides=6)

    p.loft(head, "Flattened amphibian skull", ((3.51, 0, -.05, .34, .27), (3.69, 0, -.20, .49, .36),
           (3.93, 0, -.39, .69, .51), (4.16, 0, -.40, .74, .55), (4.34, 0, -.33, .68, .55),
           (4.55, 0, -.28, .61, .45), (4.65, 0, -.266, .49, .36), (4.69, 0, -.25, .37, .29)),
           charcoal, bevel=.065)
    p.loft(head, "Low broad salamander snout", ((3.82, 0, -.64, .38, .29), (3.93, 0, -.71, .50, .44),
           (4.02, 0, -.75, .58, .45), (4.15, 0, -.72, .55, .39), (4.23, 0, -.66, .39, .31)),
           smoke, bevel=.047)
    p.loft(head, "Slate lower jaw", ((3.76, 0, -.665, .30, .31), (3.84, 0, -.725, .46, .37),
           (3.95, 0, -.695, .54, .43)), underbelly, bevel=.037)
    p.tube(head, "Broad neutral mouth line", ((-.50, -.994, 3.945), (-.29, -1.133, 3.952),
           (-.094, -1.17, 3.94), (.14, -1.162, 3.94), (.34, -1.109, 3.955), (.50, -.991, 3.946)),
           (.019, .018, .018, .018, .019, .019), ink, sides=6)

    for side, label in ((1, "Right"), (-1, "Left")):
        p.ellipse(head, f"{label} eye socket", (side * .48, -.786, 4.266), (.223, .13, .168), ink)
        p.ellipse(head, f"{label} amber eye", (side * .48, -.864, 4.261), (.158, .087, .108), iris)
        p.ellipse(head, f"{label} pupil", (side * .447, -.935, 4.26), (.078, .027, .077), ink)
        p.ellipse(head, f"{label} eye glint", (side * .447 - .024, -.960, 4.293), (.026, .011, .024), firelight)
        p.rounded_box(head, f"{label} charcoal brow", (side * .474, -.832, 4.377), (.38, .23, .10),
                      smoke, .046, (0, -side * .28, side * .27))
        p.ellipse(head, f"{label} nostril", (side * .184, -1.155, 4.07), (.054, .024, .029), ink)

    for name, outline, color in (
        ("Broad dorsal crown spot", ((-.31, -.40), (-.16, -.494), (.001, -.45), (.125, -.31),
          (.06, -.129), (-.11, -.069), (-.245, -.147), (-.315, -.285)), gold),
        ("Small right dorsal crown spot", ((.163, -.246), (.279, -.258), (.312, -.16), (.228, -.084),
          (.166, -.12)), ochre),
    ):
        p.plate(head, name, [(x, y, 4.696) for x, y in outline], color,
                thickness=.011, bevel=.004)
    for name, outline, color in (
        ("Irregular left brow marking", ((-.29, 4.40), (-.20, 4.394), (-.114, 4.432),
          (-.121, 4.505), (-.214, 4.535), (-.276, 4.497)), gold),
        ("Irregular right brow marking", ((.13, 4.434), (.221, 4.399), (.301, 4.440),
          (.27, 4.517), (.191, 4.527)), ochre),
    ):
        # Lean the marks along the forehead plane so they read from ring height.
        p.plate(head, name, [(x, -.837 + (z - 4.40) * .70, z) for x, z in outline],
                color, thickness=.052, bevel=.009)

    pivots = {torso: (0, .08, 2.52), head: (0, -.09, 3.43), tail: (0, .34, 1.70)}
    for side, name in ((1, "Right"), (-1, "Left")):
        arm, leg = f"{name} Arm", f"{name} Leg"
        lead = 0 if side == 1 else .19
        hand_raise = 0 if side == 1 else .29
        pivots[arm] = (side * .68, .025, 3.22)
        pivots[leg] = (side * .42, .073, 1.71)
        p.tube(arm, f"{name} bent salamander arm", ((side * .68, .012, 3.21), (side * .82, -.094, 2.91),
               (side * .97, -.225 + lead, 2.63 + hand_raise), (side * .96, -.41 + lead, 2.67 + hand_raise),
               (side * .92, -.72 + lead, 2.84 + hand_raise)), (.253, .239, .218, .193, .157),
               charcoal, sides=9, aspect=.93)
        p.rounded_box(arm, f"{name} ember shoulder panel", (side * .744, -.012, 3.212), (.52, .60, .32),
                      glaze, .105, (0, side * .39, side * .13))
        p.rounded_box(arm, f"{name} shoulder glaze crest", (side * .778, -.231, 3.250), (.43, .15, .115),
                      glaze_edge, .049, (0, side * .39, side * .13))
        p.rounded_box(arm, f"{name} hanging shoulder lining", (side * .80, -.005, 3.073), (.49, .53, .15),
                      soot, .065, (0, side * .36, side * .12))
        p.rounded_box(arm, f"{name} ochre forearm wrap", (side * .953, -.533 + lead, 2.729 + hand_raise),
                      (.421, .425, .421), amber, .089, (-.42, 0, side * .04))
        for index, offset in enumerate((-.11, .05), 1):
            p.rounded_box(arm, f"{name} dark forearm binding {index}",
                          (side * .95, -.533 + offset + lead, 2.729 + hand_raise - offset * .43),
                          (.432, .091, .407), scarlet, .027, (-.42, 0, side * .04))
        p.rounded_box(arm, f"{name} webbed palm", (side * .917, -.826 + lead, 2.85 + hand_raise),
                      (.41, .35, .35), charcoal, .119, (-.25, side * .093, side * .08))
        for index, (offset, lift) in enumerate(((-.15, .07), (-.053, .15), (.055, .165), (.157, .119)), 1):
            finger_x, finger_y, finger_z = side * (.918 + offset), -.922 + lead, 2.93 + hand_raise
            p.tube(arm, f"{name} broad finger {index}", ((finger_x, finger_y + .055, finger_z - .076),
                   (finger_x + side * offset * .18, finger_y - .046, finger_z + lift * .38),
                   (finger_x + side * offset * .31, finger_y - .036, finger_z + lift)),
                   (.084, .075, .061), smoke, sides=7, aspect=.93)

        foot_y = -.27 if side == 1 else .01
        p.loft(leg, f"{name} runner leg", ((.31, side * .53, foot_y, .21, .24),
               (.60, side * .54, foot_y + .052, .245, .27), (1.02, side * .52, foot_y + .106, .29, .29),
               (1.35, side * .47, .053, .345, .34), (1.81, side * .416, .078, .322, .32)),
               soot, bevel=.05)
        p.rounded_box(leg, f"{name} broad grounded foot", (side * .549, foot_y - .18, .165),
                      (.625, .82, .33), charcoal, .106, (0, 0, side * .105))
        p.rounded_box(leg, f"{name} upper instep wrap", (side * .542, foot_y - .09, .34),
                      (.545, .474, .23), amber, .068, (0, 0, side * .105))
        p.rounded_box(leg, f"{name} kilncloth ankle gaiter", (side * .536, foot_y + .024, .531),
                      (.561, .570, .291), scarlet, .075)
        p.rounded_box(leg, f"{name} stance-side knee guard", (side * .521, foot_y - .132, .973),
                      (.48, .235, .325), glaze, .077, (0, side * .10, 0))
        for index, offset in enumerate((-.20, -.10, 0, .10, .20), 1):
            p.rounded_box(leg, f"{name} flattened toe {index}",
                          (side * (.551 + offset), foot_y - .51 + 1.25 * offset * offset, .122),
                          (.104, .22, .13), smoke, .043, (0, 0, side * (.08 + offset)))

    # A thick tail root tapers into a low counterbalance behind the feet.
    tail_layout = (
        (0, .31, 1.70, .362), (.018, .62, 1.60, .333), (.098, .97, 1.39, .302),
        (.24, 1.29, 1.16, .274), (.414, 1.61, .93, .242), (.56, 1.94, .755, .212),
        (.654, 2.28, .625, .179), (.657, 2.56, .564, .148), (.54, 2.81, .533, .114),
        (.36, 3.01, .490, .085), (.14, 3.15, .467, .052), (-.026, 3.207, .448, .016),
    )
    tail_steps, ring_points = len(tail_layout) - 1, 14

    def tail_point(s, angle, lift=0):
        position = s * tail_steps
        row = min(int(position), tail_steps - 1)
        start, end = tail_layout[row:row + 2]
        fraction = position - row
        x, y, z, radius = (a + (b - a) * fraction for a, b in zip(start, end))
        # Centered tangents match across the authored control sections.
        before = tail_layout[max(0, row - 1)]
        after = tail_layout[min(tail_steps, row + 2)]
        dx = (end[0] - before[0]) * (1 - fraction) + (after[0] - start[0]) * fraction
        dy = (end[1] - before[1]) * (1 - fraction) + (after[1] - start[1]) * fraction
        length = hypot(dx, dy)
        width = (radius + lift) * cos(angle)
        return x + dy * width / length, y - dx * width / length, z + (radius * .78 + lift) * sin(angle)

    vertices = [tail_point(row / tail_steps, tau * i / ring_points)
                for row in range(tail_steps + 1) for i in range(ring_points)]
    faces = [tuple(range(ring_points))]
    for row in range(tail_steps):
        for i in range(ring_points):
            next_i = (i + 1) % ring_points
            faces.append((row * ring_points + i, (row + 1) * ring_points + i,
                          (row + 1) * ring_points + next_i, row * ring_points + next_i))
    faces.append(tuple(reversed(range(tail_steps * ring_points, len(vertices)))))
    p.mesh(tail, "Long low salamander tail", vertices, faces, charcoal)

    for index, (s, angle, length, spread) in enumerate((
        (.116, 1.09, .033, .37), (.173, 2.259, .039, .40), (.219, .46, .035, .43),
        (.284, 1.60, .045, .53), (.337, 2.70, .029, .40), (.395, .73, .040, .52),
        (.464, 2.09, .048, .58), (.543, .95, .041, .67), (.608, 2.37, .048, .61),
        (.686, .99, .041, .74), (.773, 1.86, .041, .77), (.876, 1.27, .037, .76),
    ), 1):
        boundary = []
        for step in range(9):
            phase = tau * step / 9
            r = 1 + .16 * sin(3 * phase + .49 * index) + .092 * cos(2 * phase - index)
            boundary.append(tail_point(s + r * length * cos(phase), angle + r * spread * sin(phase), .007))
        spot_vertices = [tail_point(s, angle, .009)] + boundary
        spot_faces = [(0, i + 1, (i + 1) % len(boundary) + 1) for i in range(len(boundary))]
        p.mesh(tail, f"Dorsal tail marking {index}", spot_vertices, spot_faces, gold if index % 3 else ochre)

    return pivots
