"""Draw the Festival Canal's sunset highlights on its existing water."""

from math import sin


# The brighter lane follows the bridge through the canal bend. The
# strokes spread and break apart as they approach the foreground.
BRIDGE_GLINTS = (
    (-20.12, 36.83, .56, .20), (-20.42, 37.42, .91, .22),
    (-20.18, 38.08, 1.38, .27), (-20.30, 38.62, 1.57, .24),
    (-20.05, 39.36, 1.90, .36), (-20.43, 39.89, 1.38, .28),
    (-19.99, 40.57, 2.03, .33), (-20.16, 41.24, 1.42, .29),
    (-19.69, 41.81, 2.22, .35), (-19.93, 42.44, 1.32, .32),
    (-19.47, 43.15, 2.24, .34), (-19.63, 43.79, 1.66, .28),
    (-19.17, 44.52, 2.08, .41), (-19.42, 45.14, 1.12, .29),
    (-18.89, 45.88, 2.35, .45), (-19.12, 46.45, 1.80, .27),
    (-18.74, 47.15, 2.13, .42), (-18.99, 47.86, 1.37, .29),
    (-18.34, 48.49, 1.92, .35), (-18.59, 49.29, 1.11, .30),
    (-18.18, 50.26, 1.55, .29), (-18.42, 51.10, .78, .25),
)
BOARD_GLINTS = (
    (-11.09, 55.93, .71, .19), (-11.31, 56.37, 1.07, .25),
    (-11.08, 56.97, 1.73, .34), (-11.46, 57.54, 1.09, .24),
    (-11.22, 58.15, 1.64, .34), (-11.66, 58.84, 1.43, .35),
    (-11.47, 59.38, 1.25, .26), (-11.72, 59.81, .76, .19),
    (-12.38, 60.29, .72, .20),
)
SIDE_GLINTS = (
    (-22.31, 47.22, .82, .23), (-22.43, 48.18, .57, .24),
    (-22.16, 49.08, .83, .24), (-21.93, 50.34, .62, .22),
    (-21.58, 51.17, .48, .19), (-21.79, 52.24, .59, .22),
)


# Darker teal undertones give the glints room to read. Native water remains
# visible between the soft-edged bands and around the swimming steps.
BLUE_SHEEN = (
    ((-20.40, 38.60, .31), (-20.80, 40.60, 2.01), (-20.67, 44.28, 2.88),
     (-20.36, 47.90, 2.92), (-19.90, 51.22, .41)),
    ((-18.14, 46.86, .38), (-18.01, 50.87, 2.44), (-17.63, 54.89, 2.83),
     (-17.12, 58.31, 2.12), (-16.20, 61.43, .29)),
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
                    (0, .50, "235F72", .74), (.50, .79, "317E8B", .83),
                    (.79, 1, "5295A1", .93),
                ):
                    y = .071
                    corners = (
                        (ax + side * aw * inner, y, az), (ax + side * aw * outer, y, az),
                        (bx + side * bw * outer, y, bz), (bx + side * bw * inner, y, bz),
                    )
                    fade = .045 if index in (0, len(sweep) - 2) else 0
                    draw_quad(corners, tint, alpha + fade, "Dusk blue water fold", smooth)

    def warm_stroke(rx, rz, width, depth, phase, warmth, core):
        y = .138
        depth *= .70
        shift = sin(phase) * depth * .30
        left = rx - width / 2
        right = rx + width / 2
        lip = (left, y, rz - shift)
        shoulder = (rx - width * .12, y, rz - depth * .61)
        tip = (right, y, rz + shift)
        keel = (rx + width * .17, y, rz + depth * .55)
        triangle(surface, lip, shoulder, keel, "DB7D39", name="Soft amber ripple edge",
                 thickness=.012, material=neon, transparency=warmth + .12, shadow=False, collide=False)
        triangle(surface, shoulder, tip, keel, "F6A34C", name="Soft amber ripple edge",
                 thickness=.012, material=neon, transparency=warmth + .08, shadow=False, collide=False)
        if not core:
            return
        y = .152
        bias = sin(phase * 1.24 + .37) * width * .07
        triangle(surface,
                 (rx - width * .38 + bias, y, rz - shift * .44),
                 (rx + width * .35 + bias, y, rz + shift * .62),
                 (rx + width * .13, y, rz + depth * .35),
                 "FFD265" if phase % 3 else "FFE5A7", name="Gold ripple core",
                 material=neon, transparency=warmth - .18,
                 thickness=.012, shadow=False, collide=False)

    for rows, start, end in (
        (BRIDGE_GLINTS, .21, .50), (BOARD_GLINTS, .29, .48), (SIDE_GLINTS, .59, .75),
    ):
        for index, (x, z, width, depth) in enumerate(rows):
            progress = index / (len(rows) - 1)
            warmth = start + (end - start) * progress
            if index in (0, len(rows) - 1):
                warmth += .07
            glint = rows is not SIDE_GLINTS and index % 5 != 4
            warm_stroke(x, z, width, depth, index + 1, warmth, glint)
