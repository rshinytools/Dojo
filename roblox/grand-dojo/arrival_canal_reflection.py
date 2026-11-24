"""Draw the Festival Canal's sunset highlights on its existing water."""

from math import sin


# The brighter lane follows the bridge through the canal bend. The
# strokes spread and break apart as they approach the foreground.
BRIDGE_GLINTS = (
    (-19.05, 37.26, .92, .16), (-18.81, 37.93, 1.38, .23),
    (-18.96, 38.42, .88, .17), (-18.72, 39.24, 1.66, .25),
    (-19.00, 39.80, 1.03, .18), (-18.84, 40.31, 1.52, .23),
    (-18.97, 41.13, .99, .19), (-18.86, 41.73, 1.72, .29),
    (-19.04, 42.44, .98, .22), (-18.98, 43.15, 1.56, .26),
    (-19.13, 43.66, 1.13, .25), (-18.98, 44.94, 1.77, .29),
    (-19.24, 45.44, .74, .19), (-18.76, 46.12, 1.48, .29),
    (-19.18, 46.93, 1.23, .23), (-18.65, 47.21, 1.41, .28),
    (-18.77, 48.03, .88, .19), (-18.41, 48.91, 1.49, .25),
    (-18.67, 49.58, .76, .18), (-18.02, 50.62, 1.29, .22),
)
BOARD_GLINTS = (
    (-16.70, 53.79, .76, .17), (-16.43, 54.41, 1.42, .23),
    (-15.89, 55.07, 2.06, .29), (-15.62, 55.61, 1.41, .20),
    (-15.30, 56.28, 2.26, .33), (-16.06, 57.03, 1.57, .25),
    (-15.72, 57.74, 1.88, .29), (-15.81, 58.36, 1.33, .21),
    (-16.12, 59.04, .63, .18),
)
SIDE_GLINTS = (
    (-17.45, 37.79, .58, .14), (-17.28, 40.11, .47, .15),
    (-17.35, 47.45, .58, .15), (-17.01, 48.56, .40, .13),
    (-20.83, 50.51, .63, .14), (-21.23, 52.07, .68, .17),
    (-21.66, 54.63, .45, .14), (-20.12, 56.20, .67, .17),
)


# The main channel runs beneath the arch. Keep the shallow edges and swim
# steps uncovered so the water still shows changes in depth at the banks.
BLUE_SHEEN = (
    ((-18.62, 28.86, .25), (-18.62, 31.05, 1.63), (-18.58, 34.12, 1.78),
     (-18.58, 37.30, 1.75), (-18.43, 40.18, 1.58), (-18.91, 42.05, 1.40),
     (-18.93, 44.14, 1.41), (-18.94, 46.02, 1.43), (-18.56, 47.45, 1.81),
     (-18.60, 51.16, 2.18), (-18.03, 53.38, 3.83),
     (-17.56, 57.28, 3.02), (-17.46, 61.42, .30)),
    ((-22.61, 50.83, .21), (-23.22, 52.93, 1.12), (-22.91, 55.55, 1.30),
     (-22.29, 58.69, .91), (-22.09, 60.18, .15)),
)


def build_arrival_canal_reflection(parent, *, item, prop, triangle, water_beam, neon, smooth, bridge_z):
    surface = item(parent, "Folder", "Arrival sunset water ribbons")

    def draw_quad(corners, tint, transparency, name, material):
        a, b, c, d = corners
        for points in ((a, b, c), (a, c, d)):
            triangle(surface, *points, tint, name=name, thickness=.012,
                     material=material, transparency=transparency,
                     shadow=False, collide=False)

    # Draw the outer feather and inner color side by side. This avoids
    # overlapping transparent facets on the same surface.
    for sweep in BLUE_SHEEN:
        for index, ((ax, az, aw), (bx, bz, bw)) in enumerate(zip(sweep, sweep[1:])):
            for side in (-1, 1):
                for inner, outer, tint, alpha in (
                    (0, .39, "183D59", .43), (.39, .68, "1F4F67", .57),
                    (.68, .86, "2F667C", .73), (.86, 1, "4B8393", .87),
                ):
                    y = .061
                    corners = (
                        (ax + side * aw * inner, y, az), (ax + side * aw * outer, y, az),
                        (bx + side * bw * outer, y, bz), (bx + side * bw * inner, y, bz),
                    )
                    fade = .055 if index in (0, len(sweep) - 2) else 0
                    draw_quad(corners, tint, alpha + fade, "Dusk blue water fold", smooth)

    def warm_stroke(rx, rz, width, depth, phase, warmth, core):
        # Irregular offsets and a break in the longer streaks follow the
        # surface waves without drawing a straight row of solid diamonds.
        y = .094
        depth *= 1.03 + .16 * sin(phase * 2.04)
        shear = sin(phase * 1.63) * depth * .24
        ridge = sin(phase * 2.32) * .09

        def point(u, v, height=y):
            return rx + u * width, height, rz + v * depth + shear * u

        left, fold, tip = point(-.54, -.11), point(-.18, -.52), point(.51, .05)
        seam, lip, tail = point(ridge, -.08), point(.21, .50), point(-.35, .21)
        for corners, pigment, lift in (
            ((left, fold, seam, tail), "C77939", .22),
            ((fold, tip, lip, seam), "EBA250", .03),
            ((tail, seam, lip, point(-.16, .39)), "DC8341", .16),
        ):
            draw_quad(corners, pigment, warmth + lift, "Soft amber ripple edge", neon)
        if not core:
            return
        glints = ((-.40, .02), (.09, .38)) if phase % 3 else ((-.44, .34),)
        for index, (start, end) in enumerate(glints):
            crest = start + (end - start) * .65
            tint = "FFEDC1" if (phase + index) % 3 else "FFD48E"
            draw_quad((point(start, -.11, .108), point(crest, -.25, .108),
                       point(end, -.065, .108), point(crest, .14, .108)),
                      tint, warmth - .09, "Gold ripple core", neon)

    for rows, start, end in (
        (BRIDGE_GLINTS, .35, .50), (BOARD_GLINTS, .58, .37), (SIDE_GLINTS, .70, .79),
    ):
        for index, (x, z, width, depth) in enumerate(rows):
            progress = index / (len(rows) - 1)
            warmth = start + (end - start) * progress
            if index in (0, len(rows) - 1):
                warmth += .07
            glint = rows is not SIDE_GLINTS and index % 5 != 4
            widen = 1 + .13 * sin(index * 2.73 + .72)
            if rows is BRIDGE_GLINTS:
                x += .22 + 1.02 * max(0, (z - 42.9) / 8.0)
                widen *= 1.01 + .19 * progress
                z += bridge_z - 34
            elif rows is BOARD_GLINTS:
                x += 1.23
            warm_stroke(x, z, width * widen, depth, index + 1, warmth, glint)

    # The original canal ripple texture breaks up the amber streaks as they
    # scroll. It shares the existing client distance checks.
    reflected_light = item(surface, "Folder", "Soft lantern reflections")
    lantern_tints = "0 .90 .50 .25 0 .46 1 .72 .37 0 .73 1 .87 .62 0 1 .95 .57 .31 0 "
    for start, end, widths, texture_length, alpha in (
        ((-18.80, .078, bridge_z + 3.30), (-18.08, .084, bridge_z + 10.42), (.78, 1.62), 2.06, .26),
        ((-18.58, .089, bridge_z + 5.01), (-17.54, .081, bridge_z + 12.75), (.48, 1.28), 1.44, .43),
        ((-17.56, .081, bridge_z + 12.12), (-16.80, .088, bridge_z + 16.94), (1.16, 1.87), 2.22, .37),
        ((-15.66, .089, 53.45), (-14.62, .086, 58.31), (.76, 1.68), 1.77, .22),
        ((-15.32, .078, 53.99), (-14.63, .084, 58.61), (.46, 1.41), 1.17, .43),
    ):
        fade = f"0 1 0 .27 {alpha} 0 .66 {alpha} 0 1 1 0 "
        water_beam(reflected_light, "Canal surface ripple", start, end, widths, lantern_tints,
                   fade, texture_length, light_influence=.05, light_emission=.54)
    for anchor in reflected_light.findall("Item[@class='Part']"):
        prop(anchor, "bool", "CastShadow", False)
