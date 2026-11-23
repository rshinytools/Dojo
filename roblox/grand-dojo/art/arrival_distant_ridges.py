"""Layered shoulders and eroded ribs beyond the walkable Grand Dojo skyline."""

from math import hypot, sin


ARRIVAL_EYE = (.776, 5.792, 75.324)


# The crest paths open around the sun east of Reedfall. All lower contours
# sit behind the original skyline, leaving the gardens and town roads intact.
FAR_CREST = (
    (-1598, 9, -1048),
    (-1226, 271, -1043), (-1068, 403, -1034), (-943, 467, -1037),
    (-836, 556, -1041), (-717, 565, -1046), (-671, 598, -1062),
    (-628, 621, -1071), (-587, 613, -1079), (-557, 635, -1060),
    (-503, 633, -1076), (-453, 649, -1061),
    (-425, 674, -1050), (-403, 657, -1037), (-374, 638, -1024),
    (-345, 652, -1037), (-319, 666, -1029), (-303, 681, -1027),
    (-285, 668, -1029), (-265, 635, -1032), (-236, 633, -1045),
    (-177, 604, -1058), (-77, 554, -1063), (-4, 591, -1068),
    (75, 537, -1071), (160, 469, -1059), (211, 490, -1034),
    (236, 523, -1027), (263, 596, -1011), (284, 571, -1006),
    (312, 575, -1018), (339, 548, -1029), (373, 497, -1024),
    (420, 461, -1009), (455, 482, -1022), (493, 511, -1048),
    (545, 492, -1050), (583, 452, -1075), (625, 438, -1076), (650, 448, -1069),
    (687, 459, -1063), (715, 473, -1059), (754, 496, -1057),
    (783, 501, -1052), (809, 495, -1043), (842, 466, -1049),
    (869, 449, -1043), (891, 454, -1037), (923, 451, -1029),
    (1015, 403, -1029), (1191, 381, -1052), (1448, 295, -1078),
    (1740, 9, -1086),
)

MIDDLE_CREST = (
    (-1234, 5, -835),
    (-980, 147, -840), (-841, 234, -835), (-736, 300, -845),
    (-636, 359, -854), (-555, 443, -861), (-515, 428, -872),
    (-447, 464, -883), (-389, 398, -875), (-312, 398, -847),
    (-253, 353, -827), (-219, 380, -831), (-182, 424, -835),
    (-158, 409, -844), (-133, 419, -859), (-114, 408, -865),
    (-87, 380, -873), (-35, 387, -873), (21, 364, -871),
    (94, 325, -869), (206, 317, -856), (267, 291, -835),
    (301, 305, -831), (350, 286, -829), (401, 314, -844),
    (441, 295, -849), (495, 327, -867), (533, 330, -877),
    (603, 332, -885), (629, 353, -886), (655, 370, -875),
    (689, 366, -872), (717, 353, -865), (750, 329, -857),
    (824, 362, -850), (892, 319, -845), (967, 277, -838),
    (1146, 192, -843), (1401, 5, -843),
)

# Lift the west summits above the blossoms and the east shoulder behind the
# ring. The low middle of each profile leaves the painted sun visible.
FAR_RELIEF = ((-1598, 0), (-1050, 27), (-784, 56), (-516, 76),
              (-425, 124), (-356, 116), (-303, 177), (-236, 145),
              (-177, 125), (-77, 177), (-4, 208), (75, 169),
              (160, 112), (211, 96), (283, 31), (340, 0), (497, 12),
              (650, 104), (715, 141), (793, 201), (869, 135),
              (1015, 115), (1448, 29), (1740, 0))
MIDDLE_RELIEF = ((-1234, 0), (-850, 26), (-590, 48), (-447, 98),
                 (-316, 82), (-182, 163), (-133, 146), (-66, 109),
                 (94, 61), (206, 83), (267, 55), (341, 4), (490, 12),
                 (629, 135), (689, 146), (750, 93), (824, 118),
                 (1070, 30), (1401, 0))


def ridge_bands(crest, reach, toe_limit, west_extension):
    """Carry each summit's rock ribs down to broader shoulders and a haze line."""
    ledge, shoulder, spur, base = [], [], [], []
    for index, (x, y, z) in enumerate(crest):
        # The rib is continuous down the slope. Unequal offsets prevent terraces
        # from reading as horizontal stripes at player height.
        fold = sin(index * 1.57) + .29 * sin(index * 2.76)
        cut = sin(index * .77 + .3)
        valley = sin(index * .36 + .55) + .24 * sin(index * .91)
        west = max(0, min(1, (-x - 52) / 32))
        run = min(reach * (.85 + .18 * sin(index * .51) + .12 * sin(index * .19)),
                  (toe_limit + west * west_extension - z) / 1.22)
        previous = crest[max(0, index - 1)][0]
        following = crest[min(len(crest) - 1, index + 1)][0]
        shift_limit = .43 * min(x - previous, following - x)

        def across(offset):
            return x + max(-shift_limit, min(shift_limit, offset))

        ledge.append((across(fold * 8 + cut * 4), y * (.88 + valley * .034), z + run * .21))
        shoulder.append((across(fold * 16 + cut * 10), y * (.67 + valley * .072), z + run * .51 + cut * 4.4))
        spur.append((across(fold * 32 + cut * 14), y * (.39 + valley * .068), z + run * .81 + fold * 5.8))
        base.append((across(cut * 24), -66, z + run * 1.22))
    return crest, ledge, shoulder, spur, base


def ridge_shade(x, band, roll, west, east):
    sunlight = max(0, min(1, (x + 680) / 1330))
    haze = ((0, 0, 0), (1, 0, 0), (3, 3, 4), (8, 8, 9))[band]
    channels = (round(a + (b - a) * sunlight + roll * light + mist)
                for a, b, light, mist in zip(west, east, (1., .87, .64), haze))
    return ''.join(f'{channel:02X}' for channel in channels)


def face_light(a, b, c):
    """Bake a broad, warm light from the right onto each rock plane."""
    ax, ay, az = (v - u for u, v in zip(a, b))
    bx, by, bz = (v - u for u, v in zip(a, c))
    nx, ny, nz = ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
    length = hypot(nx, ny, nz)
    if length < .01:
        return 0
    facing = 1 if nz >= 0 else -1
    return facing * (nx * .82 + ny * .38) / length


def distant_facets(crest, reach, toe_limit, west_extension, palette_scale, west, east):
    contours = ridge_bands(crest, reach, toe_limit, west_extension)
    for band, (above, below) in enumerate(zip(contours, contours[1:])):
        for index, (left, right, low_left, low_right) in enumerate(
                zip(above, above[1:], below, below[1:])):
            center = (left[0] + right[0]) * .5 / palette_scale
            faces = ((left, low_left, right), (right, low_left, low_right))
            broad_light = sum(face_light(*face) for face in faces) / 2
            rib_light = 5.2 * sin(index * 1.39 + .38) + 2.6 * sin(index * 2.1)
            contrast = (1, .89, .65, .32)[band]
            for face in faces:
                value = ((.78 * broad_light + .22 * face_light(*face)) * 14 + rib_light) * contrast
                yield face, ridge_shade(center, band, value, west, east)


def fit_to_plaza_view(crest, relief, depth_scale, height_scale):
    """Keep the range's bearing and shape the visible crests before scaling."""
    arrival_z = 73
    shoulders = zip(relief, relief[1:])
    (left, low), (right, high) = next(shoulders)
    for x, y, z in crest:
        while x > right:
            (left, low), (right, high) = next(shoulders)
        lift = low + (high - low) * (x - left) / (right - left)
        yield x * depth_scale, (y + lift) * height_scale, arrival_z + (z - arrival_z) * depth_scale


def place_beyond_towns(crest, scale, west_scale, saddle):
    """Recede along arrival sightlines, with a lower notch behind Wind Court."""
    for x, y, z in crest:
        notch = max(0, 1 - abs(x + 15) / 117)
        height = y - saddle * notch ** 1.7
        # Keep the western crest visible to the arrival camera. Its shoulder
        # stays west of the highland routes while the center and east recede.
        blend = max(0, min(1, (x + 94) / 78)) ** 1.6
        depth_scale = west_scale + (scale - west_scale) * blend
        yield tuple(eye + (value - eye) * depth_scale for eye, value in zip(ARRIVAL_EYE, (x, height, z)))


def build_arrival_distant_ridges(landscape, *, item, prop, triangle, smooth):
    for name, crest, relief, depth, height, scale, west_scale, saddle, reach, toe, extension, west, east in (
        ('Rose horizon range', FAR_CREST, FAR_RELIEF, .365, .246, 2.12, 1., 21, 192, -520, 239,
         (149, 121, 143), (195, 145, 145)),
        ('Mauve saddle range', MIDDLE_CREST, MIDDLE_RELIEF, .379, .254, 1.96, 1.96, 34, 144, -447, 0,
         (117, 100, 129), (163, 120, 132)),
    ):
        backdrop = item(landscape, 'Model', name)
        prop(backdrop, 'token', 'ModelStreamingMode', 2)
        prop(backdrop, 'token', 'LevelOfDetail', 4)
        fitted = fit_to_plaza_view(crest, relief, depth, height)
        far_crest = tuple(place_beyond_towns(fitted, scale, west_scale, saddle))
        for face, tint in distant_facets(far_crest, reach, toe, extension, scale, west, east):
            triangle(backdrop, *face, tint, name='Distant ridge facet', thickness=.28,
                     material=smooth, shadow=False)
