"""Quiet ridgelines beyond the walkable Grand Dojo skyline."""

from math import sin


# The crest paths open around the sun east of Reedfall. All lower contours
# sit behind the original skyline, leaving the gardens and town roads intact.
FAR_CREST = (
    (-1598, 9, -1048),
    (-1226, 271, -1043), (-1068, 403, -1034), (-943, 467, -1037),
    (-836, 556, -1041), (-717, 521, -1046), (-671, 537, -1062),
    (-587, 578, -1079), (-503, 633, -1076), (-425, 674, -1050),
    (-356, 646, -1026), (-303, 681, -1027), (-236, 643, -1045),
    (-177, 604, -1058), (-77, 554, -1063), (-4, 591, -1068),
    (75, 537, -1071), (160, 443, -1059), (211, 473, -1034),
    (260, 373, -1020), (373, 307, -1035), (493, 304, -1062),
    (583, 341, -1075), (650, 441, -1069), (715, 473, -1059),
    (793, 507, -1053), (869, 455, -1043), (923, 459, -1029),
    (1015, 403, -1029), (1191, 381, -1052), (1448, 295, -1078),
    (1740, 9, -1086),
)

MIDDLE_CREST = (
    (-1234, 5, -835),
    (-980, 147, -840), (-841, 234, -835), (-736, 300, -845),
    (-636, 344, -854), (-555, 433, -861), (-515, 418, -872),
    (-447, 464, -883), (-389, 382, -875), (-312, 392, -847),
    (-253, 353, -827), (-182, 424, -835), (-133, 419, -859),
    (-87, 380, -873), (-35, 387, -873), (21, 364, -871),
    (94, 325, -869), (206, 317, -856), (267, 291, -835),
    (350, 221, -829), (441, 258, -849), (533, 311, -877),
    (629, 353, -886), (689, 366, -872), (750, 329, -857),
    (824, 362, -850), (892, 319, -845), (967, 277, -838),
    (1146, 192, -843), (1401, 5, -843),
)


def ridge_bands(crest, reach):
    shoulder = []
    base = []
    for index, (x, y, z) in enumerate(crest):
        folded = sin(index * 1.08) + .35 * sin(index * 2.41)
        shoulder.append((x + folded * 14, y * .73 + folded * 10, z + reach * .54))
        base.append((x, -66, z + reach))
    return crest, shoulder, base


def ridge_shade(x, band, roll, west, east):
    sunlight = max(0, min(1, (x + 680) / 1330))
    haze = band * 3
    channels = (round(a + (b - a) * sunlight + roll + haze)
                for a, b in zip(west, east))
    return ''.join(f'{channel:02X}' for channel in channels)


def distant_facets(crest, reach, west, east):
    contours = ridge_bands(crest, reach)
    for band, (above, below) in enumerate(zip(contours, contours[1:])):
        for index, (left, right, low_left, low_right) in enumerate(
                zip(above, above[1:], below, below[1:])):
            center = (left[0] + right[0]) * .5
            soft_shadow = round(3.1 * sin(index * 1.27 + band * .2))
            tint = ridge_shade(center, band, soft_shadow, west, east)
            # Share pigment across a quad. The folds in the geometry keep the
            # shoulder legible without putting a sharp color seam in its middle.
            yield (left, low_left, right), tint
            yield (right, low_left, low_right), tint


def fit_to_plaza_view(crest, depth_scale, height_scale):
    """Keep a backdrop's bearing while bringing it inside the local valley."""
    arrival_z = 73
    return tuple((x * depth_scale, y * height_scale, arrival_z + (z - arrival_z) * depth_scale)
                 for x, y, z in crest)


def build_arrival_distant_ridges(landscape, *, item, prop, triangle, smooth):
    for name, crest, depth, height, reach, west, east in (
        ('Rose horizon range', FAR_CREST, .365, .246, 45, (186, 144, 172), (213, 161, 173)),
        ('Mauve saddle range', MIDDLE_CREST, .379, .254, 27, (154, 118, 154), (185, 139, 162)),
    ):
        backdrop = item(landscape, 'Model', name)
        prop(backdrop, 'token', 'ModelStreamingMode', 2)
        prop(backdrop, 'token', 'LevelOfDetail', 4)
        for face, tint in distant_facets(fit_to_plaza_view(crest, depth, height), reach, west, east):
            triangle(backdrop, *face, tint, name='Distant ridge facet', thickness=.28,
                     material=smooth, shadow=False)
