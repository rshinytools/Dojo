"""Cloud-pruned foliage for the original plaza arrival trees.

Coordinates are tree-local Roblox studs. The crown layout is shared by the
native place and Blender export, over the original trunk and branch layout.
"""

from math import cos, radians, sin
from random import Random

from .garden_tree_layout import ARRIVAL_BOUGH_LIFT, BLOSSOMS, CROWNS


# Each row has a normalized offset, dimensions, palette index and detail flag.
# The deeper lower lobes catch shade. Shorter upper lobes meet in staggered
# groups, leaving space between the growing tips at distant viewing angles.
PINE_LOBES = (
    (-.15, -.23, .03, .68, .89, .63, 0, False),
    (.18, -.18, -.07, .58, .85, .62, 0, False),
    (-.28, -.09, .13, .35, .71, .37, 1, False),
    (.32, -.04, .05, .29, .68, .33, 1, True),
    (-.06, -.17, .30, .39, .48, .36, 1, True),
)
PINK_LOBES = (
    (-.12, -.20, .07, .79, .91, .75, 0, False),
    (.20, -.11, -.12, .68, .97, .60, 1, False),
    (-.23, .16, -.04, .59, 1.16, .62, 2, False),
    (.16, .23, .14, .60, 1.05, .67, 2, False),
    (.01, .37, -.12, .56, 1.06, .51, 3, False),
    (-.38, .24, .12, .30, .75, .37, 3, True),
    (.38, .21, -.01, .31, .69, .38, 2, True),
    (-.17, .49, .23, .36, .69, .35, 4, True),
    (.13, .45, -.33, .37, .74, .31, 4, True),
    (.24, .26, .33, .36, .69, .33, 3, True),
)

# Both species share the five bough tips but spread differently around them.
# Rotating the overlapping groups changes where scrub and gaps meet the light.
CROWN_HEADINGS = (-13, 19, -31, 14, -22)
PINE_PALETTE = ("3D542F", "546E37", "68833E", "839A48", "9DAC56")

# Broad tips grow partly through the outer lobes. The lifted ridge and
# lower outside corner give a visible break without a full ring of spikes.
# Angle, reach, width, height and sun-facing palette index.
PINK_FANS = ((40, .53, .080, .36, 3), (133, .57, .088, .31, 4),
             (223, .54, .096, .29, 4), (324, .52, .080, .41, 3))

PINE_OUTLINE = ((-.53, -.08), (-.48, -.29), (-.35, -.40), (-.18, -.47),
                (.035, -.41), (.23, -.43), (.41, -.30), (.54, -.08),
                (.48, .14), (.39, .33), (.17, .46), (-.11, .39),
                (-.29, .43), (-.46, .26))


def _branches(blossom):
    for index, (x, y, z, width, depth) in enumerate(CROWNS):
        if blossom:
            x, z = x * .95 + .21, z * .92 - .17
            y += (-.15, .15, .17, -.20, .30)[index]
        else:
            x, z = x * 1.09, z * .90
            y += (-.28, .07, .04, -.22, .03)[index]
        y += ARRIVAL_BOUGH_LIFT[blossom][index]
        yield x, y, z, width, depth


def arrival_canopy(blossom, *, palette=None):
    """Return standard garden leaf tuples: center, size, angles, tint, detail."""
    colors = palette or (BLOSSOMS if blossom else PINE_PALETTE)
    lobes = PINK_LOBES if blossom else PINE_LOBES
    height = 1.34 if blossom else 1.08
    rng = Random(6901 if blossom else 4179)
    foliage = []
    for crown, (x, y, z, width, depth) in enumerate(_branches(blossom)):
        heading = CROWN_HEADINGS[crown]
        c, s = cos(radians(heading)), sin(radians(heading))
        for dx, dy, dz, w, h, d, shade, detail in lobes:
            across = dx * width + rng.uniform(-.16, .16)
            back = dz * depth + rng.uniform(-.14, .14)
            center = (x + across * c + back * s,
                      y + dy * height + rng.uniform(-.10, .10),
                      z + back * c - across * s)
            size = (width * w * rng.uniform(.95, 1.05), height * h,
                    depth * d * rng.uniform(.93, 1.05))
            angles = (heading + rng.uniform(-16, 16), dz * 12 + rng.uniform(-8, 8),
                      dx * 18 + rng.uniform(-7, 7))
            foliage.append((center, size, angles, colors[shade], detail))
    return foliage


def pine_crown_faces(colors, *, lod=False):
    """Shape continuous, uneven needle pads above the darker interior growth."""
    for index, (x, y, z, width, depth) in enumerate(_branches(False)):
        heading = radians(CROWN_HEADINGS[index])
        cosine, sine = cos(heading), sin(heading)
        outline = PINE_OUTLINE[::2] if lod else PINE_OUTLINE

        def point(u, v, lift):
            px, pz = u * width, v * depth
            return x + px * cosine + pz * sine, y + lift, z + pz * cosine - px * sine

        def band(scale, lift, bias):
            return tuple(point(u * scale + bias, v * scale,
                               lift + .075 * sin(j * 1.81 + index * 2.7) + .052 * cos(j * .91))
                         for j, (u, v) in enumerate(outline))

        underside = band(.80, -.33, -.047)
        skirt = band(1.0, .025, -.022)
        terrace = band(.70, .58, .045)
        crest = point(.11 * sin(index * 2), -.065, .79 + .08 * cos(index * 1.41))
        for j in range(len(outline)):
            k = (j + 1) % len(outline)
            sun = 1 if outline[j][1] < -.10 else 0
            yield underside[j], underside[k], skirt[k], colors[sun]
            yield underside[j], skirt[k], skirt[j], colors[sun]
            yield skirt[j], skirt[k], terrace[k], colors[1 + sun]
            yield skirt[j], terrace[k], terrace[j], colors[2 + sun]
            yield terrace[j], terrace[k], crest, colors[3 + sun]


def arrival_canopy_faces(blossom, *, palette=None, lod=False):
    """Yield the canopy's shaped crown and outer tips as tinted triangles."""
    colors = palette or (BLOSSOMS if blossom else PINE_PALETTE)
    if not blossom:
        yield from pine_crown_faces(colors, lod=lod)
        return
    height = 1.34
    for crown, (x, y, z, width, depth) in enumerate(_branches(blossom)):
        for angle, reach, spread, lift, shade in PINK_FANS:
            direction = radians(angle - CROWN_HEADINGS[crown])
            u, v = cos(direction), sin(direction)

            def point(radius, side, dy):
                return (x + width * (radius * u - side * v), y + dy * height,
                        z + depth * (radius * v + side * u))

            root = point(reach - .29, 0, lift + .10)
            left = point(reach - .075, -spread, lift -.04)
            tip = point(reach, .023, lift + .025)
            right = point(reach - .035, spread, lift -.18)
            yield root, left, tip, colors[shade]
            yield root, tip, right, colors[shade - 1]
