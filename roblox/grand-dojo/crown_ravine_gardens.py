"""Layered slate and cedar on the Tideharbor side of Crown Crossing."""

from math import cos, radians, sin

from south_valley_backdrop import hillside_cedar, ridge_surface_height


# The three connected shelves bridge the scenery gap between the footings
# of Crown Crossing and the clay cut alongside the Cinder–Tideharbor road.
SHELVES = (
    ("Lower cedar shelf", (123.3, -78.2), (16.8, 12.5), 5.2, -17,
     ((-2.1, .45, .67),)),
    ("Middle shale shelf", (137.8, -91.5), (24.6, 20.2), 8.4, 13,
     ((1.35, -2.8, .64), (4.1, 2.8, .59))),
    ("Tideharbor-facing shelf", (151.0, -80.8), (20.0, 18.4), 9.6, -19,
     ((2.3, -2.2, .74),)),
)

_OUTLINE = (
    (-.49, -.17), (-.29, -.47), (.12, -.52), (.47, -.30),
    (.52, .05), (.29, .43), (-.10, .48), (-.45, .29),
)
_PROFILE = (-.58, -.23, .05, .36, .26, -.01, -.12, -.44)
_SILT = ("706575", "776A76", "84737D")
_SLATE = ("857483", "897887", "97838A", "9F8A90")
_SHALE = ("887783", "9B888D", "AB9697", "9E8C8C")
_MOSS = ("647653", "708253", "778458", "829262")


def build_crown_ravine_gardens(parent, *, item, prop, part, triangle, garden_prop,
                              rock, grass, cedar, rock_variant, variant_field):
    ravine = item(parent, "Folder", "Crown Crossing cedar ravine")

    def cedar_piece(group, name, position, size, tint, **pose):
        body = part(group, name, position, size, tint,
                    material=cedar if name.endswith("trunk") else grass, collide=False, **pose)
        prop(body, "bool", "CastShadow", False)

    for shelf_index, (label, (x, z), (width, depth), top, heading, grove) in enumerate(SHELVES):
        layer = item(ravine, "Model", label)
        prop(layer, "token", "ModelStreamingMode", 1)
        prop(layer, "token", "LevelOfDetail", 4)
        angle = radians(heading)
        cosine, sine = cos(angle), sin(angle)

        def project(local_x, y, local_z):
            return (x + local_x * cosine + local_z * sine, y,
                    z - local_x * sine + local_z * cosine)

        def contour(span, fraction, shift, ripple):
            level = -6.1 + (top + 6.1) * fraction
            return [
                project(width * (u * span + shift), level + ripple * uneven, depth * v * span)
                for (u, v), uneven in zip(_OUTLINE, _PROFILE)
            ]

        # Broken risers separate broad ledges. The bottom course intersects
        # the native valley floor so the shelves stay rooted from the road.
        bands = (
            (1.10, 0, -.035, .22),
            (.95, .44, -.060, .74),
            (.81, .49, -.050, .83),
            (.80, .79, .002, .93),
            (.68, .84, .002, .98),
            (.61, .975, .042, .79),
            (.47, 1, .051, .69),
        )
        rings = [contour(*band) for band in bands]
        surface = []

        def facet(points, name, tint, material):
            surface.append(points)
            if material == rock:
                mark = len(layer)
            triangle(layer, *points, tint, name=name, material=material,
                     thickness=.16, collide=False, shadow=False)
            if material == rock:
                for face in layer[mark:]:
                    prop(face, "string", variant_field, rock_variant)

        for index, (bottom, upper) in enumerate(zip(rings, rings[1:])):
            tones = (_SILT, _SILT, _SLATE, _SHALE, _SLATE, _MOSS)[index]
            material = grass if index == len(rings) - 2 else rock
            for i, low in enumerate(bottom):
                j = (i + 1) % len(bottom)
                side = (shelf_index + i // 2 + index) % len(tones)
                title = "Mossy ravine shoulder" if material == grass else "Layered ravine slate"
                facet((low, bottom[j], upper[i]), title, tones[side], material)
                facet((upper[i], bottom[j], upper[j]), title, tones[(side + (i % 2)) % len(tones)], material)

        plateau = rings[-1]
        center = project(width * .07, top + .11, -depth * .025)
        for index, edge in enumerate(plateau):
            facet((center, edge, plateau[(index + 1) % len(plateau)]),
                  "Ravine grass shelf", _MOSS[(index + shelf_index) % len(_MOSS)], grass)

        def root_at(local_x, local_z):
            px, _, pz = project(local_x, 0, local_z)
            return px, ridge_surface_height(surface, px, pz), pz

        for index, (local_x, local_z, scale) in enumerate(grove):
            px, py, pz = root_at(local_x, local_z)
            hillside_cedar(cedar_piece, layer, px, py - .28, pz, scale, shelf_index * 3 + index)

        for key, local_x, local_z, scale, turn, tint in (
            ("bankRock", -width * .21, depth * .18, .35, 38, "9C8C91"),
            ("bankRock", width * .19, -depth * .22, .28, -31, "A08D8B"),
            ("meadowGrass", -width * .08, depth * .11, .23, 9, "A5AA69"),
            ("meadowCover", width * .16, depth * .12, .29, 80, "8DAD5F"),
            ("rockVine", width * .29, depth * .045, .61, 118, "7D935B"),
            ("grassBlade", -width * .24, -depth * .07, .29, 56, "C6AC76"),
            ("mossFlowers", width * .04, depth * .19, .19, 19, "CB96A0"),
        ):
            px, py, pz = root_at(local_x, local_z)
            mark = len(layer)
            garden_prop(layer, key, (px, py - .11, pz), scale, turn + heading, tint)
            for mesh in layer[mark:]:
                shadow = mesh.find("Properties/bool[@name='CastShadow']")
                if shadow is not None:
                    shadow.text = "false"
