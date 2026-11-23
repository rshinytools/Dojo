"""An eroded sea arch and low reefs viewed from Sea Lantern Lookout."""

from math import cos, hypot, radians, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height
from tideharbor_offshore import build_offshore_island


# Each section gives the span, elevation, depth offset and two radii.
ARCH_PROFILE = (
    (-23, -6, 2, 9.5, 9.1), (-21, 5.2, 1.5, 8.5, 8.9),
    (-18, 15.2, .5, 7.4, 7.6), (-12, 24.9, -.7, 6.8, 7.0),
    (-3, 31.8, -2.6, 6.3, 7.9), (7, 29.1, .3, 5.5, 7.0),
    (14, 22.1, .7, 5.3, 6.6), (18, 12.4, 1.0, 6.5, 6.9),
    (21, 3.2, 1.9, 7.6, 8.3), (22, -6, 3.1, 9.2, 9.1),
)
ARCH_TONES = (
    ("9C9294", "7E7480", "726B76", "706574", "786B76", "8E7E83"),
    ("AEA19E", "94868B", "857884", "826D7B", "907E82", "A49392"),
)


def _arch_rings():
    # Align the opening broadside to the lookout. The irregular cross-section
    # keeps the underside darker while the ridge catches the sunset.
    cross, along = .586, .810
    rings = []
    for index, (span, y, drift, radial, deep) in enumerate(ARCH_PROFILE):
        before = ARCH_PROFILE[max(0, index - 1)]
        after = ARCH_PROFILE[min(len(ARCH_PROFILE) - 1, index + 1)]
        dx, dy = after[0] - before[0], after[1] - before[1]
        length = hypot(dx, dy)
        ring = []
        for side, fold in enumerate((.97, .87, 1.04, .92, 1.08, .96)):
            angle = radians(side * 60)
            displacement = cos(angle) * radial * fold
            u = span - dy / length * displacement
            v = drift + sin(angle) * deep * fold
            ring.append((521 + cross * u + along * v, y + dx / length * displacement,
                         156 - along * u + cross * v))
        rings.append(ring)
    return rings


def build_south_channel_arch(offshore, *, item, prop, part, triangle, horizontal_water_beam,
                             slate, grass, wood):
    garden = item(offshore, "Model", "South Channel reefs")
    prop(garden, "token", "LevelOfDetail", 4)
    arch = item(garden, "Model", "Windcut sea arch")
    rings = _arch_rings()
    for index, (previous, current) in enumerate(zip(rings, rings[1:])):
        palette = ARCH_TONES[int(1 < index < 7)]
        for side, tint in enumerate(palette):
            next_side = (side + 1) % len(previous)
            a, b = previous[side], previous[next_side]
            c, d = current[side], current[next_side]
            for face in ((a, b, c), (b, d, c)):
                triangle(arch, *face, tint, name="Windcut slate", thickness=.20,
                         material=slate, collide=False, shadow=False)

    def cedar_piece(group, name, position, size, tint, **orientation):
        piece = part(group, name, position, size, tint, collide=False,
                     material=wood if name.endswith("trunk") else grass, **orientation)
        prop(piece, "bool", "CastShadow", False)

    for section, scale, index in ((3, .77, 0), (4, .74, 3), (6, .89, 1)):
        x, y, z = rings[section][0]
        hillside_cedar(cedar_piece, arch, x, y - .42, z, scale, index)

    reefs = item(garden, "Model", "Low slate reefs")
    for index, (x, z, width, depth, crest, bearing) in enumerate((
        (478, 174, 36, 25, 9.5, -33), (568, 164, 31, 27, 13.4, 25),
        (500, 179, 36, 23, 12.2, -35), (535, 136, 22, 22, 6.9, -29),
    )):
        faces = build_offshore_island(reefs, x, z, width, depth, crest, bearing,
                                      triangle=triangle, slate=slate, distant=True)
        if index == 1:
            peak_x, peak_z = x + width * .11, z - depth * .14
            height = ridge_surface_height(faces, peak_x, peak_z)
            hillside_cedar(cedar_piece, reefs, peak_x, height - .36, peak_z, .69, 2)

    for (x1, z1), (x2, z2), width in (
        ((467.0, 162.9), (477.1, 158.9), 1.6),
        ((503.8, 159.8), (515.7, 168.3), 1.9),
        ((552.9, 154.9), (560.2, 150.8), 1.45),
    ):
        horizontal_water_beam(garden, "Reef tide glint", (x1, .55, z1), (x2, .55, z2),
                              (width * .73, width), "0 .66 .79 .81 0 1 .82 .81 .73 0",
                              "0 1 0 .32 .62 0 .77 .78 0 1 1 0", 5.8)
