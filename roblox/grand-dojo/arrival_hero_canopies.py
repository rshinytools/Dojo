"""Branch-grown blossom sprays and low pine pads for two plaza trees."""

from math import atan2, cos, degrees, hypot, radians, sin, tau

from art.garden_tree_layout import ARRIVAL_BOUGH_LIFT, CROWNS


PINE_TONES = ("738C43", "8AA74B", "799C42", "94AD46", "B0C653")
BLOSSOM_TONES = ("C184A6", "DF9CBB", "ECA8C2", "F3B7CC", "FFD3DA")


def crown_tips(blossom):
    for index, (x, y, z, width, depth) in enumerate(CROWNS):
        if blossom:
            x, z = x * .95 + .21, z * .92 - .17
            y += (-.15, .15, .17, -.20, .30)[index]
        else:
            x, z = x * 1.09, z * .90
            y += (-.28, .07, .04, -.22, .03)[index]
        yield (x, y + ARRIVAL_BOUGH_LIFT[blossom][index], z), width, depth


def crown_pad(index, tip, width, depth, blossom):
    """Yield unequal, shaded bands around one bough tip."""
    x, y, z = tip
    palette = BLOSSOM_TONES if blossom else PINE_TONES
    heading = radians((-17, 23, -31, 17, -9)[index])
    cosine, sine = cos(heading), sin(heading)
    count = 10
    outline = []
    for i in range(count):
        angle = tau * i / count
        phase = tau * i / count + index
        radius = 1 + .13 * sin(3 * phase) + .06 * cos(4 * phase + .5)
        arrow = radius * (.38 if blossom else .53)
        u, v = arrow * width * cos(angle), arrow * depth * sin(angle)
        scallop = (.13 if blossom else .07) * sin(4 * phase + .3)
        outline.append((u * cosine + v * sine, v * cosine - u * sine, scallop))

    def ring(scale, elevation, bias):
        return tuple((x + u * scale + bias, y + elevation + rise, z + v * scale)
                     for u, v, rise in outline)

    skirt = ring(1, .055, -.04)
    # Blossom sprays are open below the petals and wider along the bough.
    # Pine pads overlap in compact tiers with flattened tips facing the plaza.
    upper = ring(.72 if blossom else .82, .46 if blossom else .42, .105)
    crest = (x + .17, y + (.62 if blossom else .52), z - .045)
    root = (x - .11, y - (.38 if blossom else .36), z + .035)
    for j in range(count):
        next_j = (j + 1) % count
        tint = 1 if outline[j][1] < -.16 else 0
        crown_tint = 4 if (j + index * 2) % 7 in (2, 4) else 3
        yield (skirt[j], root, skirt[next_j]), palette[tint]
        yield (skirt[j], skirt[next_j], upper[next_j]), palette[tint + 1]
        yield (skirt[j], upper[next_j], upper[j]), palette[tint + 1]
        yield (upper[j], upper[next_j], crest), palette[crown_tint]

    if blossom:
        return
    # Pine needles break the sunlit edge of each pad.
    for j in range(count):
        if j % 2:
            continue
        next_j = (j + 1) % count
        origin = upper[j]
        outer = skirt[j]
        point = (x + (outer[0] - x) * 1.06, outer[1] + .20 + .04 * sin(j + index),
                 z + (outer[2] - z) * 1.06)
        next_point = skirt[next_j]
        edge = tuple(a + (b - a) * .29 for a, b in zip(outer, next_point))
        peak = tuple(a + (b - a) * .39 for a, b in zip(origin, point))
        peak = (peak[0], peak[1] + .068, peak[2])
        yield (origin, peak, edge), palette[3 + ((j + index) % 3 == 0)]
        yield (peak, point, edge), palette[2 + ((j + index) % 3 == 0)]


def hero_canopy_faces(blossom):
    """Tree-local triangles shared by the place and offline art previews."""
    for index, (tip, width, depth) in enumerate(crown_tips(blossom)):
        yield from crown_pad(index, tip, width, depth, blossom)


def hero_canopy_lobes(blossom):
    """Soft sprays overlap the structural pads and round the lower rims."""
    for index, (tip, width, depth) in enumerate(crown_tips(blossom)):
        x, y, z = tip
        if blossom:
            yield (x - .08, y - .18, z + .08), (.62 * width, .94, .60 * depth), BLOSSOM_TONES[0]
            count = 8
            for i in range(count):
                angle = tau * (i + index * .39) / count
                flare = .34 + .038 * sin(i * 2.3 + index)
                center = (x + width * flare * cos(angle), y + .075 + .23 * sin(i * 2.34 + index),
                          z + depth * flare * sin(angle))
                size = (width * (.32 + .055 * cos(i * 1.6)), .88 + .14 * sin(i + index),
                        depth * (.30 + .05 * sin(i * 1.26)))
                yield center, size, BLOSSOM_TONES[1 + (i + index) % 3]
            for i in range(4):
                a = tau * (i + index * .31) / 4
                center = (x + width * .21 * cos(a), y + .46 + .13 * sin(i * 2.1 + index),
                          z + depth * .21 * sin(a))
                size = (width * .265, .59 + .14 * cos(i * 1.4 + index), depth * .26)
                yield center, size, BLOSSOM_TONES[3 + (i + index) % 2]
        else:
            for offset_x, offset_z, length, depth_fraction, lift, depth_y, tint in (
                (-.26, .11, .44, .47, -.06, .36, 0),
                (.28, .08, .46, .45, -.03, .39, 1),
                (-.04, -.28, .56, .43, .15, .35, 2),
                (.08, .29, .52, .37, .12, .32, 1),
            ):
                yield ((x + width * offset_x, y + lift, z + depth * offset_z),
                       (width * length, depth_y, depth * depth_fraction), PINE_TONES[tint])


def build_arrival_hero_canopy(tree, blossom, *, position, item, prop, part, triangle, leaf,
                              variant_field, variant):
    crown = item(tree, "Folder", "Layered blossom canopy" if blossom else "Layered pine canopy")
    label = "Layered blossom spray" if blossom else "Layered pine needle pad"
    for face, tint in hero_canopy_faces(blossom):
        triangle(crown, *(position(vertex) for vertex in face), tint, name=label,
                 material=leaf, thickness=.029, collide=False, shadow=False)
    origin = position((0, 0, 0))
    height_scale = position((0, 1, 0))[1] - origin[1]
    for center, size, tint in hero_canopy_lobes(blossom):
        world = position(center)
        # Get the horizontal sizing and heading at the lobe height, using the
        # same taper and yaw as its branch and the faceted inner pad.
        plus_x, _, plus_z = position((center[0] + 1, center[1], center[2]))
        delta_x, delta_z = plus_x - world[0], plus_z - world[2]
        scale = hypot(delta_x, delta_z)
        shape = part(crown, "Rounded blossom petal spray" if blossom else "Pine needle fringe", world,
                     (size[0] * scale, size[1] * height_scale, size[2] * scale), tint,
                     yaw=degrees(atan2(-delta_z, delta_x)), shape=0, material=leaf, collide=False)
        prop(shape, "bool", "CastShadow", False)
    for piece in crown.findall("Item"):
        prop(piece, "string", variant_field, variant)
