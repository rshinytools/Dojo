"""Scenic headwaters west of the playable Meltwater creek and bridge."""

from math import hypot

from south_valley_backdrop import hillside_cedar


NAME = "Meltwater headwaters"

# Flow runs east. The outlet meets the western end of the existing native creek
# (x = -252.5, edit surface y = -2.30). Every upstream section is visual only.
# Center x, elevation, center z, water half-width, outer bank reach, bank rise.
SECTIONS = (
    (-338.2, 43.90, -105.0, 2.12, 14.0, 4.3),
    (-329.0, 43.58, -103.5, 3.15, 16.0, 5.1),
    (-320.0, 42.85, -98.0, 2.94, 15.1, 4.9),
    (-313.0, 40.60, -91.8, 3.10, 13.4, 4.5),
    (-308.5, 32.00, -87.5, 3.11, 12.8, 4.9),
    (-302.1, 28.30, -82.6, 3.36, 12.4, 4.8),
    (-296.0, 20.70, -77.7, 2.44, 10.6, 4.2),
    (-290.8, 16.90, -73.0, 2.86,  9.9, 3.6),
    (-283.4, 12.10, -70.9, 2.44,  8.4, 3.3),
    (-279.1, 11.35, -71.3, 1.91,  5.9, 2.8),
    (-276.4,  9.14, -71.95, 1.56,  4.1, 2.2),
    (-269.8,  8.45, -71.82, 1.32,  3.4, 1.6),
    (-262.0,  5.85, -71.5, 1.25, 2.8, 1.1),
    (-257.00, -1.95, -76.0, 1.31, 2.1, .68),
    (-252.2, -2.34, -77.15, 1.57, 1.9, .28),
)

_WATER = ("729AA5", "6D9AA7", "7BABB1", "89B2B4")
_STONE = (("81758A", "908294", "9A8894"), ("787081", "85798B", "90818D"))
_COVER = (("776F7A", "807582", "82817E"), ("685F6B", "756C78", "767778"))


def _cross_sections():
    rows = []
    toe_depths = (29, 24, 13, 10, 9, 8, 10, 14, 18, 16, 13, 12, 9, 2, 1)
    for i, ((x, y, z, water, reach, rise), depth) in enumerate(zip(SECTIONS, toe_depths, strict=True)):
        before = SECTIONS[max(0, i - 1)]
        after = SECTIONS[min(len(SECTIONS) - 1, i + 1)]
        dx, dz = after[0] - before[0], after[2] - before[2]
        length = hypot(dx, dz)
        nx, nz = -dz / length, dx / length
        edges = []
        for side in (-1, 1):
            asymmetry = 1 + side * (.12, -.02, .17, -.09)[i % 4]
            # Cut exposed slate under a broad vegetated shoulder. The final
            # toe folds beneath the existing creek rather than covering it.
            bands = ((water, -.07), (water + reach * .28, rise * .74),
                     (water + reach * .64, rise), (water + reach, -depth))
            edges.append(tuple((x + nx * span * asymmetry * side, y + uplift,
                                z + nz * span * asymmetry * side) for span, uplift in bands))
        rows.append(tuple(edges))
    return rows


def _interpolate(a, b, amount):
    return tuple(x + (y - x) * amount for x, y in zip(a, b))


def build_meltwater_valley_art(parent, *, item, prop, part, triangle, slate, smooth):
    """Mount the ravine without editing native Terrain or playable geometry."""
    valley = item(parent, "Folder", NAME)
    rows = _cross_sections()

    def panel(group, points, tint, label, material, thickness=.14):
        a, b, c, d = points
        for face in ((a, b, c), (b, d, c)):
            triangle(group, *face, tint, name=label, thickness=thickness,
                     material=material, collide=False, shadow=False)

    def block(group, label, position, size, tint, **rotation):
        piece = part(group, label, position, size, tint, material=smooth,
                     collide=False, **rotation)
        prop(piece, "bool", "CastShadow", False)

    def surface(row, fraction, lift=.09):
        x, y, z = _interpolate(row[0][0], row[1][0], fraction)
        return x, y + lift, z

    for name, start, end in (("Cedar headwaters", 0, 4), ("Folded slate ravine", 4, 9),
                             ("Lower creek outlet", 9, 14)):
        reach = item(valley, "Model", name)
        prop(reach, "token", "ModelStreamingMode", 1)
        prop(reach, "token", "LevelOfDetail", 4)
        for i in range(start, end):
            upstream, downstream = rows[i:i + 2]
            panel(reach, (surface(upstream, 0), surface(upstream, 1),
                          surface(downstream, 0), surface(downstream, 1)),
                  _WATER[i % len(_WATER)], "Meltwater current", smooth, .10)

            for side in range(2):
                upper, lower = upstream[side], downstream[side]
                shade = (i + side) % 3
                for band, (label, colors) in enumerate((
                    ("Incised slate channel", _STONE),
                    ("Doubled ravine ledge", _STONE),
                    ("Sage foothill shoulder", _COVER),
                )):
                    panel(reach, (upper[band], upper[band + 1], lower[band], lower[band + 1]),
                          colors[side][(shade + band) % 3], label, slate)

            # Clear ribbons on the fast sections, aligned continuously with
            # the flow. These are layered color, with no emitters or lights.
            if i in (3, 5, 7, 9, 12):
                for position, width, tint in ((.31, .075, "B2CFCC"), (.68, .12, "A0C4C4")):
                    panel(reach, (surface(upstream, position, .19),
                                  surface(upstream, position + width, .19),
                                  surface(downstream, position - .04, .19),
                                  surface(downstream, position + width + .03, .19)),
                          tint, "Falling-water ribbons", smooth, .08)

        # Irregular small stands land directly on the two elevated rock rims.
        for index, side, scale in ((0, 0, .79), (1, 1, .97), (2, 0, .73), (3, 1, .74),
                                   (4, 0, .68), (5, 1, .75), (6, 0, .62), (8, 1, .65)):
            if start <= index < end:
                x, y, z = rows[index][side][2]
                hillside_cedar(block, reach, x, y - .08, z, scale, index)
