"""Sunlit rock and grass details for the Grand Dojo arrival gardens."""

from math import atan2, cos, degrees, hypot, radians, sin


STONE_RIM = ((-.98, -.27), (-.63, -.93), (.24, -.99), (.88, -.68),
             (1.00, .26), (.49, .94), (-.57, .80))
STONE_CROWN = (.75, .85, .92, .86, .70, .68, .64)
STONE_COLORS = (
    ("716559", "77695F", "877567", "6F645A", "756859", "817069", "73675F"),
    ("9C897C", "AB9381", "B89C86", "9A8476", "8D7B70", "A38D81", "998578"),
    ("AE9A86", "BCA38B", "C5AA91", "B09A84", "A68F7D", "B79F89", "B09A87"),
)


def build_bank_stone(parent, center, size, yaw, *, triangle, prop, rock, leaf,
                     stone_variant, variant_field, moss=False):
    """Dark stone at the soil line, a warm crown, and thin moss along sheltered edges."""
    x, y, z = center
    width, height, depth = size
    cosine, sine = cos(radians(yaw)), sin(radians(yaw))

    def point(u, v, lift):
        px, pz = u * width * .5, v * depth * .5
        return x + px * cosine + pz * sine, y + lift * height, z - px * sine + pz * cosine

    rings = tuple(tuple(point(u * spread + shear, v * spread, lift * top)
                        for (u, v), top in zip(STONE_RIM, STONE_CROWN))
                  for lift, spread, shear in ((0, .76, -.04), (.29, 1.0, .025),
                                               (.82, .92, -.075), (1, .69, -.13)))
    mark = len(parent)
    for tones, (lower, upper) in zip(STONE_COLORS, zip(rings, rings[1:])):
        for i, tint in enumerate(tones):
            j = (i + 1) % len(STONE_RIM)
            for face in ((lower[i], lower[j], upper[j]), (lower[i], upper[j], upper[i])):
                triangle(parent, *face, tint, name="Weathered garden stone face", material=rock,
                         thickness=.095, shadow=False)
    crown = rings[-1]
    crest = point(-.21, -.045, .91)
    for i, a in enumerate(crown):
        triangle(parent, crest, a, crown[(i + 1) % len(crown)], STONE_COLORS[-1][(i + 2) % len(crown)],
                 name="Sunlit garden stone cap", material=rock, thickness=.098, shadow=False)
    for face in list(parent)[mark:]:
        prop(face, "string", variant_field, stone_variant)

    if moss:
        for i, tint in zip((4, 5, 6), ("6C7548", "73834D", "87965B")):
            face = (crest, crown[i], crown[(i + 1) % len(crown)])
            moss_points = []
            for weights in ((.40, .52, .08), (.15, .13, .72), (.26, .58, .16)):
                mx, my, mz = (sum(value * weight for value, weight in zip(axis, weights)) for axis in zip(*face))
                moss_points.append((mx, my + .026, mz))
            triangle(parent, *moss_points, tint, name="Stone moss seam",
                     material=leaf, thickness=.035, shadow=False)


def build_golden_plumes(parent, origin, scale, lean, *, part, prop, beam, triangle, grass):
    """Give the backlit sedges tapered stems, feathery blades and coherent silhouettes."""
    x, y, z = origin

    def place(dx, dy, dz):
        return x + dx * scale, y + dy * scale, z + dz * scale

    mark = len(parent)
    for dx, dz, height in ((-.59, -.09, 1.57), (-.39, .12, 2.03), (-.10, -.23, 2.29),
                           (.23, .28, 1.83), (.53, -.13, 1.59)):
        root = place(dx * .27, 0, dz * .33)
        elbow = place(dx * .55 + lean * .09, height * .61, dz * .71)
        neck = place(dx + lean * .30, height * .92, dz - .12)
        beam(parent, "Plaza sedge lower stem", root, elbow, .039 * scale, "7D8847")
        beam(parent, "Plaza sedge upper stem", elbow, neck, .030 * scale, "B7A365")
        for side, tint in ((-.15, "7C8F47"), (.18, "9CA755")):
            leaf = place(dx * .66 + side, height * .32, dz + .26)
            tip = place(dx * .95 + side * 2.4, height * .44, dz + .29)
            start = place(dx * .28, height * .06, dz * .36)
            triangle(parent, start, leaf, tip, tint, name="Tapered plaza sedge leaf", material=grass,
                     thickness=.030, shadow=False)
        plume_end = place(dx + lean * .61, height * 1.08, dz - .31)
        axis = tuple(b - a for a, b in zip(neck, plume_end))
        pitch = degrees(atan2(axis[2], axis[1]))
        roll = -degrees(atan2(axis[0], axis[1]))
        length = hypot(*axis)
        for fraction, width, tint in ((.38, .145, "C4A465"), (.61, .20, "DCC28E"),
                                       (.86, .119, "EED7AA")):
            center = tuple(a + b * fraction for a, b in zip(neck, axis))
            part(parent, "Ivory sedge seed plume", center, (width * scale, length * .74, width * .58 * scale),
                 tint, shape=0, pitch=pitch, roll=roll, collide=False)
        for j, tint in enumerate(("DEC58F", "E8CEA0", "F1DDB4")):
            fraction = .36 + j * .23
            root_feather = tuple(a + b * fraction for a, b in zip(neck, axis))
            for side in (-1, 1):
                end = (root_feather[0] + (side * (.14 - j * .026) + lean * .06) * scale,
                       root_feather[1] + (.12 - j * .015) * scale,
                       root_feather[2] - .052 * scale)
                beam(parent, "Backlit sedge bristle", root_feather, end, (.022 - j * .003) * scale, tint)
    for detail in list(parent)[mark:]:
        prop(detail, "bool", "CastShadow", False)
