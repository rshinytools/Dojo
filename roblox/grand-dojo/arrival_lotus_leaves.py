"""Small, notched lily pads for the near-bank lotus beds."""

from math import cos, radians, sin


def build_arrival_lotus_leaves(cluster, x, z, scale, yaw, *, item, triangle, material):
    leaves = item(cluster, "Folder", "Folded floating lily leaves")
    for dx, dz, width, twist, palette in (
        (-.87, .44, 1.58, -21, ("63914B", "85A752", "A9BA66")),
        (.69, .72, 1.22, 67, ("7A9846", "9AB756", "B8C970")),
        (.14, -.46, 1.45, 7, ("548849", "739D4A", "A7B963")),
    ):
        ox, oz = x + dx * scale, z + dz * scale
        radius = width * .5 * scale
        heading = radians(yaw + twist)
        sine, cosine = sin(heading), cos(heading)

        def point(u, v, lift=0):
            return (ox + (u * cosine + v * sine) * radius, .174 + lift * scale,
                    oz + (v * cosine - u * sine) * radius)

        outline = []
        for index, angle in enumerate((19, 53, 88, 124, 158, 195, 232, 271, 305, 341)):
            turn = radians(angle)
            ripple = (1.0, .99, 1.025, .962, .993)[index % 5]
            outline.append((sin(turn) * ripple, 1.06 * cos(turn) * ripple,
                            (.023, .042, .033, .019)[index % 4]))
        root = point(0, .14)
        for index, (start, end) in enumerate(zip(outline, outline[1:])):
            triangle(leaves, root, point(*start), point(*end),
                     palette[int(index in (0, 1, 2, 7, 8))], name="Notched lily leaf surface",
                     thickness=.013, material=material, shadow=False)
        # The opening points toward the seed and catches a fine yellow-green light.
        for u, v, lift in (outline[0], outline[-1]):
            vein = point(u * .70, v * .72, lift + .010)
            shoulder = point(u * .61, v * .73, lift + .008)
            triangle(leaves, point(0, .17, .016), vein, shoulder,
                     palette[2], name="Sunlit lily leaf edge", thickness=.008,
                     material=material, shadow=False)
