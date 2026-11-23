"""Planted slate on the north bank between Wind Rest and the Skywalk ascent."""

from math import cos, radians, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height


_LEDGES = (
    ("Creek bank shelf", 36.7, -187.3, 13.2, 12.5, 2.15, -17,
     ((-.12, .04, .66),)),
    ("Skywalk shoulder shelf", 45.6, -196.4, 16.3, 15.8, 7.17, 21,
     ((-.17, .11, .82), (.14, -.09, .71))),
)
_OUTLINE = (
    (-.51, -.11), (-.41, -.45), (.13, -.51),
    (.52, -.28), (.45, .30), (-.19, .51),
)
_CROWN = (.23, -.36, -.08, .31, .08, -.16)
_SLATE = (
    ("756D80", "8A7C8C", "807488"),
    ("9F8992", "897B8C", "918596"),
    ("8D8090", "A0929E", "958390"),
)
_MOSS = ("75845B", "80916A", "8B986D")


def build_windrest_creek_gardens(parent, *, item, prop, part, triangle, garden_prop,
                                rock, grass, cedar, rock_variant, variant_field):
    """Frame the bridge from below while leaving the creek and paths alone."""
    gardens = item(parent, "Folder", "Wind Rest north-bank gardens")

    def cedar_part(group, label, center, size, tint, **rotation):
        material = cedar if label.endswith("trunk") else grass
        tree_part = part(group, label, center, size, tint, material=material,
                         collide=False, **rotation)
        prop(tree_part, "bool", "CastShadow", False)

    for number, (label, x, z, width, depth, top, heading, trees) in enumerate(_LEDGES):
        ledge = item(gardens, "Model", label)
        prop(ledge, "token", "ModelStreamingMode", 1)
        prop(ledge, "token", "LevelOfDetail", 4)
        angle = radians(heading)
        direction = cos(angle), sin(angle)
        faces = []

        def ground(u, v):
            a, b = u * width, v * depth
            c, s = direction
            return x + a * c + b * s, z - a * s + b * c

        def contour(scale, shift, height, uneven):
            points = []
            for (u, v), rise in zip(_OUTLINE, _CROWN, strict=True):
                px, pz = ground(u * scale + shift, v * scale)
                points.append((px, height + rise * uneven, pz))
            return points

        def facet(a, b, c, material, name, tint):
            faces.append((a, b, c))
            previous = len(ledge)
            triangle(ledge, a, b, c, tint, name=name, material=material,
                     thickness=.14, collide=False, shadow=False)
            if material == rock:
                for wedge in ledge[previous:]:
                    prop(wedge, "string", variant_field, rock_variant)

        # Recess the darker toe into the valley floor. The exposed seam at
        # the second ring leaves a break between the slate and the planted cap.
        rings = (
            contour(1.04, -.06, -5.4, .57),
            contour(.96, -.025, top * .40 - 2.57, 2.0),
            contour(.84, .025, top - .69, 1.22),
            contour(.72, .045, top, 1.42),
        )
        perimeter = len(_OUTLINE)
        for band, (low, high) in enumerate(zip(rings, rings[1:])):
            palette = _SLATE[band]
            for i in range(perimeter):
                j = (i + 1) % perimeter
                color_index = (i + band + number) % len(palette)
                facet(low[i], low[j], high[i], rock, "Broken slate bank", palette[color_index])
                facet(high[i], low[j], high[j], rock, "Broken slate bank", palette[(color_index + i % 2) % len(palette)])

        cx, cz = ground(.06, -.025)
        for i, start in enumerate(rings[-1]):
            facet((cx, top + .17, cz), start, rings[-1][(i + 1) % perimeter],
                  grass, "Mossy slate crown", _MOSS[(i + number) % len(_MOSS)])

        def root(u, v):
            px, pz = ground(u, v)
            return px, ridge_surface_height(faces, px, pz) - .14, pz

        for index, (u, v, scale) in enumerate(trees):
            hillside_cedar(cedar_part, ledge, *root(u, v), scale, number * 2 + index)

        for key, u, v, scale, rotation, tint in (
            ("bankRock", -.18, -.18, .32, 37, "A796A1"),
            ("bankRock", .28, .064, .242, -25, "A08C92"),
            ("grassBlade", -.052, .174, .43, 19, "D7BE84"),
            ("meadowCover", .07, .13, .25, 58, "98A96F"),
            ("rockVine", -.29, -.02, .48, 116, "7F9863"),
            ("mossFlowers", .197, -.09, .18, 72, "D7A6B0"),
        ):
            previous = len(ledge)
            garden_prop(ledge, key, root(u, v), scale, heading + rotation, tint)
            for mesh in ledge[previous:]:
                mesh.find("Properties/bool[@name='CastShadow']").text = "false"
