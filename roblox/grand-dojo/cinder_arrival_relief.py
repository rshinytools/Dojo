"""Decorative clay masonry below the two raised approaches to Cinder Square."""

from art.cinder_hillside_layout import hillside_faces, hillside_rings


COURSES = (-7.55, -6.27, -4.99, -3.57, -2.10, -.77)
PALETTES = (
    ("86645F", "936C62", "9D7266"),
    ("9D7363", "A67766", "936A60"),
    ("AC7B65", "B8846C", "A57562"),
    ("9C6C5C", "A87560", "B58268"),
    ("BD927B", "AB7E69", "B98B72"),
)


def _south_depth(triangles, x, y, margin):
    """Project a face point onto the south slope, outside the square's slab."""
    front = margin
    for a, b, c in triangles:
        ux, uy, uz = (q - p for p, q in zip(a, b))
        vx, vy, vz = (q - p for p, q in zip(a, c))
        area = ux * vy - uy * vx
        if abs(area) < 1e-7:
            continue
        rx, ry = x - a[0], y - a[1]
        u, v = (rx * vy - ry * vx) / area, (ux * ry - uy * rx) / area
        if min(u, v, 1 - u - v) >= -1e-6:
            front = max(front, a[2] + u * uz + v * vz)
    return front


def build_cinder_arrival_relief(town, x, y, z, *, item, prop, triangle, sandstone,
                               slate, metal, material_variant_field, sandstone_variant):
    relief = item(town, "Model", "Cinder claywork retaining facade")
    prop(relief, "token", "LevelOfDetail", 4)
    triangles = tuple(face for face, _ in hillside_faces(hillside_rings(x, y, z)))

    def point(lateral, lift, out=0):
        px, py = x + lateral, y + lift
        return (px, py, _south_depth(triangles, px, py, z + 31.03) + .33 + out)

    def quad(label, a, b, c, d, tint, material, thickness):
        triangle(relief, a, c, b, tint, name=label, material=material,
                 thickness=thickness, shadow=False, collide=False)
        triangle(relief, a, d, c, tint, name=label, material=material,
                 thickness=thickness, shadow=False, collide=False)

    def tile(label, left, right, low, high, out, tint, material=sandstone, thickness=.20):
        a, b, c, d = (point(px, py, out) for px, py in
                      ((left, low), (right, low), (right, high), (left, high)))
        quad(label, a, b, c, d, tint, material, thickness)

    # The two road decks merge in the open gap. The approach stonework sits
    # down on their flanks, repeating the square's warm clay and slate colors.
    wings = ((-27.4, -13.55, (-24.9, -15.1)), (23.15, 29.25, (24.55, 28.05)))
    for wing, (left, right, supports) in enumerate(wings):
        for course, (low, high) in enumerate(zip(COURSES, COURSES[1:])):
            tile("Recessed clay masonry bed", left, right, low, high, -.07, "745552", slate, .26)
            count = 4 if wing == 0 else 2
            step = (right - left) / count
            marks = [left, *(left + step * (i + (.16 if course % 2 else -.18))
                            for i in range(1, count)), right]
            for column, (a, b) in enumerate(zip(marks, marks[1:])):
                palette = PALETTES[course]
                tile("Split fired sandstone course", a + .045, b - .045, low + .04, high - .04,
                     .07 + .032 * ((course + column) % 3), palette[(column + course + wing) % len(palette)])

        for support in supports:
            # Widen the foot against the natural slope, then roll the shoulder
            # back under the edge of the existing Cinder Square paving.
            for course, (bottom, top, base, crown) in enumerate((
                (-7.63, -5.45, 1.34, 1.16), (-5.45, -3.18, 1.16, .93), (-3.18, -.81, .93, .73),
            )):
                face = (.66, .48, .31, .20)
                a, b, c, d = (point(support + offset, lift, inset) for offset, lift, inset in (
                    (-base, bottom, face[course]), (base, bottom, face[course]),
                    (crown, top, face[course + 1]), (-crown, top, face[course + 1]),
                ))
                quad("Battered Cinder buttress", a, b, c, d, ("96756D", "AA8272", "B8927B")[course], slate, .33)
                for sign, i, j in ((-1, a, d), (1, b, c)):
                    foot, head = point(support + sign * base, bottom, -.17), point(support + sign * crown, top, -.17)
                    quad("Cinder buttress return", i, foot, head, j, "85625A", slate, .16)

        tile("Layered clay cornice", left - .12, right + .12, -1.08, -.67, .21, "C49A7C", slate, .37)
        tile("Copper cornice inlay", left, right, -.93, -.81, .40, "A87852", metal, .12)

        # Closed incised fired tiles distinguish the walls from walkable storefronts.
        for emblem in ((-21.8, -18.2) if wing == 0 else (26.25,)):
            tile("Kiln fan tile surround", emblem - 1.14, emblem + 1.14, -3.01, -1.46,
                 .31, "D1A887", sandstone, .25)
            tile("Kiln fan tile glaze", emblem - .96, emblem + .96, -2.88, -1.59,
                 .48, "5F7469", sandstone, .18)
            for offset, height in ((-.64, .43), (-.32, .69), (0, .90), (.32, .69), (.64, .43)):
                base = point(emblem + offset * .32, -2.69, .67)
                a = point(emblem + offset - .10, -2.58 + height, .67)
                b = point(emblem + offset + .11, -2.63 + height, .67)
                triangle(relief, base, a, b, "CC9C65", name="Ceramic kiln fan inlay", thickness=.075,
                         material=metal, shadow=False, collide=False)

    for facet in relief.findall("Item"):
        if facet.findtext("Properties/token[@name='Material']") == str(sandstone):
            prop(facet, "string", material_variant_field, sandstone_variant)
