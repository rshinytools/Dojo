"""Branch-grown blossom sprays and low pine pads for two plaza trees."""

from math import atan2, cos, degrees, hypot, radians, sin, tau

from art.garden_tree_layout import ARRIVAL_BOUGH_LIFT, CROWNS


PINE_TONES = ("587440", "748E4A", "8AA04D", "9FB358", "BAC974")
BLOSSOM_TONES = ("C184A6", "DF9CBB", "ECA8C2", "F3B7CC", "FFD3DA")
BOUGH_HEADINGS = (-17, 23, -31, 17, -9)


def crown_tips(blossom):
    for index, (x, y, z, width, depth) in enumerate(CROWNS):
        if blossom:
            x, z = x * .95 + .21, z * .92 - .17
            y += (-.15, .15, .17, -.20, .30)[index]
        else:
            x, z = x * 1.09, z * .90
            y += (-.28, .07, .04, -.22, .03)[index]
        yield (x, y + ARRIVAL_BOUGH_LIFT[blossom][index], z), width, depth


def blossom_pad(index, tip, width, depth):
    """Yield shaded bands around a blossom spray."""
    x, y, z = tip
    heading = radians(BOUGH_HEADINGS[index])
    cosine, sine = cos(heading), sin(heading)
    count = 10
    outline = []
    for i in range(count):
        angle = tau * i / count
        phase = tau * i / count + index
        radius = 1 + .13 * sin(3 * phase) + .06 * cos(4 * phase + .5)
        arrow = radius * .38
        u, v = arrow * width * cos(angle), arrow * depth * sin(angle)
        scallop = .13 * sin(4 * phase + .3)
        outline.append((u * cosine + v * sine, v * cosine - u * sine, scallop))

    def ring(scale, elevation, bias):
        return tuple((x + u * scale + bias, y + elevation + rise, z + v * scale)
                     for u, v, rise in outline)

    skirt = ring(1, .055, -.04)
    upper = ring(.72, .46, .105)
    crest = (x + .17, y + .62, z - .045)
    root = (x - .11, y - .38, z + .035)
    for j in range(count):
        next_j = (j + 1) % count
        tint = 1 if outline[j][1] < -.16 else 0
        crown_tint = 4 if (j + index * 2) % 7 in (2, 4) else 3
        yield (skirt[j], root, skirt[next_j]), BLOSSOM_TONES[tint]
        yield (skirt[j], skirt[next_j], upper[next_j]), BLOSSOM_TONES[tint + 1]
        yield (skirt[j], upper[next_j], upper[j]), BLOSSOM_TONES[tint + 1]
        yield (upper[j], upper[next_j], crest), BLOSSOM_TONES[crown_tint]


def pine_bough(index, tip, width, depth):
    """Overlap three irregular needle clusters at different heights on a bough."""
    x, y, z = tip
    heading = radians(BOUGH_HEADINGS[index])
    cosine, sine = cos(heading), sin(heading)

    def point(u, height, v):
        return x + u * cosine + v * sine, y + height, z + v * cosine - u * sine

    for cluster, (offset_x, lift, offset_z, radius_x, radius_z, crown, belly) in enumerate((
        (-.235, -.02, -.08, .31, .33, .36, .30),
        (.205, .11, -.055, .34, .33, .46, .29),
        (-.025, -.07, .255, .35, .27, .31, .27),
    )):
        center_x, center_z = offset_x * width, offset_z * depth
        top = point(center_x + .12, lift + crown, center_z - .09)
        bottom = point(center_x - .11, lift - belly, center_z + .08)
        rim = []
        for step in range(8):
            angle = tau * step / 8 + .17 * index + .25 * cluster
            fan = .98 + .11 * cos(3 * angle + index) + .05 * sin(5 * angle + cluster)
            rim.append(point(center_x + width * radius_x * fan * cos(angle),
                             lift + .10 * sin(2 * angle + cluster),
                             center_z + depth * radius_z * fan * sin(angle)))
        for step, edge in enumerate(rim):
            following = rim[(step + 1) % len(rim)]
            light = cos(tau * (step + .5) / 8 + .17 * index + .25 * cluster + .8)
            underside_tint = 1 if light + .22 * cluster > .12 else 0
            top_tint = 3 if light > -.10 else 2
            yield (bottom, edge, following), PINE_TONES[underside_tint]
            yield (top, following, edge), PINE_TONES[top_tint]


def hero_canopy_faces(blossom):
    """Tree-local triangles shared by the place and offline art previews."""
    layer = blossom_pad if blossom else pine_bough
    for index, (tip, width, depth) in enumerate(crown_tips(blossom)):
        yield from layer(index, tip, width, depth)


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
            heading = radians(BOUGH_HEADINGS[index])
            cosine, sine = cos(heading), sin(heading)
            for offset_x, offset_z, length, depth_fraction, lift, thickness, tint in (
                (-.41, .14, .25, .26, -.15, .39, 1),
                (.44, -.02, .23, .23, .14, .42, 2),
                (.13, -.32, .27, .19, .26, .36, 4),
                (-.14, .38, .26, .22, -.03, .34, 3),
            ):
                u, v = width * offset_x, depth * offset_z
                yield ((x + u * cosine + v * sine, y + lift, z + v * cosine - u * sine),
                       (width * length, thickness, depth * depth_fraction), PINE_TONES[tint])


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
