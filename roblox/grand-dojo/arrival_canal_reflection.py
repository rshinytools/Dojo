"""Draw the Festival Canal's sunset highlights on its existing water."""

from math import sin


# Each set follows one reflection toward the arrival camera. The larger
# bends pick up the bridge, with a second warmer patch by the near bank.
BRIDGE_GLINTS = (
    (-20.22, 37.94, .42, .16), (-20.38, 38.44, .68, .25),
    (-20.10, 39.04, .90, .30), (-20.35, 39.78, .76, .21),
    (-19.96, 40.34, 1.15, .32), (-20.21, 41.15, 1.01, .31),
    (-19.72, 42.06, .93, .26), (-19.93, 43.27, .77, .24),
    (-19.46, 44.09, 1.14, .33), (-19.58, 45.32, 1.34, .30),
    (-18.83, 46.57, 1.00, .28), (-19.18, 47.56, .87, .22),
    (-18.56, 48.65, .78, .24), (-18.74, 49.82, .57, .18),
)
BOARD_GLINTS = (
    (-11.09, 55.93, .52, .18), (-11.31, 56.37, .86, .27),
    (-11.08, 56.97, 1.38, .35), (-11.46, 57.54, .87, .24),
    (-11.22, 58.15, 1.43, .32), (-11.66, 58.84, 1.17, .32),
    (-11.47, 59.38, 1.10, .26), (-11.72, 59.81, .71, .19),
    (-12.38, 60.29, .65, .20),
)
SIDE_GLINTS = (
    (-22.31, 47.22, .82, .23), (-22.43, 48.18, .57, .24),
    (-22.16, 49.08, .83, .24), (-21.93, 50.34, .62, .22),
    (-21.58, 51.17, .48, .19), (-21.79, 52.24, .59, .22),
)


# Quiet tones on the outer portion of the channel leave gaps for the water
# itself. The second patch stops ahead of the inset swimming steps.
BLUE_SHEEN = (
    ((-21.72, 40.36, .12), (-21.88, 43.15, 1.37),
     (-21.52, 45.76, 1.62), (-21.21, 48.36, 1.49), (-20.95, 50.24, .24)),
    ((-19.98, 50.42, .31), (-19.34, 52.58, 1.48),
     (-18.08, 55.25, 1.94), (-17.02, 58.21, 1.64), (-16.74, 61.30, .20)),
)


def build_arrival_canal_reflection(parent, *, item, triangle, neon, smooth):
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
                    (0, .56, "4B9CAC", .84), (.56, 1, "6CB2B8", .92),
                ):
                    y = .043
                    corners = (
                        (ax + side * aw * inner, y, az), (ax + side * aw * outer, y, az),
                        (bx + side * bw * outer, y, bz), (bx + side * bw * inner, y, bz),
                    )
                    fade = .06 if index in (0, len(sweep) - 2) else 0
                    draw_quad(corners, tint, alpha + fade, "Dusk blue water fold", smooth)

    def warm_stroke(rx, rz, width, depth, phase, warmth, core):
        y = .101
        shift = sin(phase) * depth * .30
        left = rx - width / 2
        right = rx + width / 2
        lip = (left, y, rz - shift)
        shoulder = (rx - width * .12, y, rz - depth * .61)
        tip = (right, y, rz + shift)
        keel = (rx + width * .17, y, rz + depth * .55)
        triangle(surface, lip, shoulder, keel, "C98051", name="Soft amber ripple edge",
                 thickness=.012, material=neon, transparency=warmth + .12, shadow=False, collide=False)
        triangle(surface, shoulder, tip, keel, "D38D50", name="Soft amber ripple edge",
                 thickness=.012, material=neon, transparency=warmth + .08, shadow=False, collide=False)
        if not core:
            return
        y = .114
        bias = sin(phase * 1.24 + .37) * width * .07
        triangle(surface,
                 (rx - width * .29 + bias, y, rz - shift * .44),
                 (rx + width * .30 + bias, y, rz + shift * .62),
                 (rx + width * .13, y, rz + depth * .29),
                 "FFD36C" if phase % 3 else "FFE4A5", name="Gold ripple core",
                 material=neon, transparency=warmth - .20,
                 thickness=.012, shadow=False, collide=False)

    for rows, start, end in (
        (BRIDGE_GLINTS, .31, .61), (BOARD_GLINTS, .34, .48), (SIDE_GLINTS, .59, .75),
    ):
        for index, (x, z, width, depth) in enumerate(rows):
            progress = index / (len(rows) - 1)
            warmth = start + (end - start) * progress
            if index in (0, len(rows) - 1):
                warmth += .07
            warm_stroke(x, z, width, depth, index + 1, warmth, rows is not SIDE_GLINTS)
