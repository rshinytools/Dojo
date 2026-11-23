"""Tailoring and original reed artwork for the Fighting Ring canvas."""

from math import atan2, degrees, hypot


CANVAS_TINT = "D8BBA0"


def build_ring_canvas_detail(parent, *, center, item, part, prop, triangle, fabric):
    """Dress the flat 32-by-26 canvas in ring-local coordinates."""
    canvas = item(parent, "Model", "Fighting Ring canvas tailoring")
    prop(canvas, "token", "LevelOfDetail", 4)
    center_x, floor, center_z = center

    def trim(name, x, z, width, depth, tint, *, height=.020, yaw=0):
        detail = part(canvas, name, (center_x + x, floor + height, center_z + z),
                      (width, .050, depth), tint, yaw=yaw, material=fabric, collide=False)
        prop(detail, "bool", "CastShadow", False)

    def binding(name, x, z, width, tint):
        # Butt the corners to keep adjacent strips on the same plane.
        for side in (-1, 1):
            trim(name, x * side, 0, width, 2 * z + width, tint)
            trim(name, 0, z * side, 2 * x - width, width, tint)

    binding("Canvas bound outer edge", 15.76, 12.76, .16, "81503C")
    binding("Canvas russet binding", 15.43, 12.43, .46, "AB624A")
    binding("Canvas ochre piping", 15.14, 12.14, .08, "C3925D")

    # Sparse visible stitches bring up the hem without adding more court lines.
    for side in (-1, 1):
        for x in range(-12, 13, 3):
            trim("Canvas hem stitch", x, side * 12.43, .36, .064, "E3B58A", height=.028)
        for z in range(-9, 10, 3):
            trim("Canvas hem stitch", side * 15.43, z, .064, .36, "E3B58A", height=.028)

    # The sheaf faces the front steps. It stops east of the bot spar boundary.
    root = (-1.45, 1.87)
    stems = (
        (root, (-1.04, .84), (-1.03, -.14), (-1.16, -1.22)),
        (root, (-.29, .87), (.40, -.25), (.74, -1.76)),
        (root, (-.03, 1.39), (1.02, .55), (1.60, -.35)),
    )
    seed_heads = ((-1.32, -1.79), (.94, -2.41), (2.08, -.96))
    leaf_faces = (
        ((-1.04, .56), (-1.82, -.18), (-1.32, .07), (-.96, .33)),
        ((.10, .27), (1.01, -.22), (.61, .31), (.21, .54)),
        ((1.10, .43), (2.32, .29), (1.87, .63), (1.31, .66)),
    )
    stem_scale, stem_offset = 1.16, .88

    def artwork_point(point):
        x, z = point
        return stem_offset + x * stem_scale, z * stem_scale

    def thread(name, a, b, width, tint):
        ax, az = artwork_point(a)
        bx, bz = artwork_point(b)
        dx, dz = bx - ax, bz - az
        trim(name, (ax + bx) / 2, (az + bz) / 2, width, hypot(dx, dz) + .032, tint,
             yaw=degrees(atan2(dx, dz)))

    for stem, head in zip(stems, seed_heads):
        for index, (a, b) in enumerate(zip(stem, stem[1:])):
            thread("Dyed reed stem", a, b, (.130, .101, .074)[index], "B58A6E")
        thread("Dyed reed seed head", stem[-1], head, .192, "BE9273")

    def leaf_vertex(point):
        x, z = artwork_point(point)
        return center_x + x, floor + .021, center_z + z

    for a, b, c, d in leaf_faces:
        for face in ((a, b, c), (a, c, d)):
            triangle(canvas, *(leaf_vertex(point) for point in face), "BC9176",
                     name="Dyed reed leaf", thickness=.052, material=fabric, shadow=False)
