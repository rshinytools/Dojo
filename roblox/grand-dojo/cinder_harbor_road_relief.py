"""Terraced clay and slate on the middle Cinder–Tideharbor descent."""

from math import hypot

from south_valley_backdrop import hillside_cedar, ridge_surface_height


# Each section gives its distance along the grade, inner toe, ledge width
# and crest height above the road. The ends tie into the low valley floor.
CLAY_SECTIONS = (
    (.03, 8.9, 15.6, -2.3),
    (.14, 8.2, 19.8, 5.7),
    (.26, 7.9, 23.9, 13.9),
    (.39, 8.5, 22.2, 11.4),
    (.54, 9.3, 18.4, 5.3),
    (.68, 8.1, 20.8, 8.6),
    (.78, 8.6, 19.1, 5.6),
    (.92, 9.1, 15.9, -.7),
)
SLATE_POCKETS = (
    ((.19, 8.9, 7.4, -2.0), (.29, 8.2, 9.5, 2.8), (.38, 8.7, 8.7, 1.8), (.47, 9.3, 7.2, -2.2)),
    ((.53, 9.5, 7.2, -2.4), (.64, 8.6, 10.4, 2.0), (.74, 8.4, 10.1, 1.0), (.86, 9.3, 7.1, -2.3)),
)
CLAY_SHADES = (
    ("755F68", "846871", "8A6C6E"), ("8C6F70", "9A786F", "947672"),
    ("A27B6D", "AE8472", "A57F73"), ("916F6B", "A27D71", "9B7468"),
    ("B18875", "B88D79", "A88274"), ("8D825E", "9A8A65", "887A64"),
)
SLATE_SHADES = (
    ("666877", "74717E", "736D7C"), ("757682", "85848B", "777583"),
    ("818387", "93918D", "84868A"), ("7A8279", "838A7A", "8A8C7E"),
)


def build_cinder_harbor_road_relief(parent, upper, lower, *, item, prop, part, triangle, garden_prop,
                                  rock, sandstone, grass, wood, rock_variant, sandstone_variant,
                                  variant_field):
    """Frame the middle road with cliffs while preserving the road and bay views."""
    dx, dz = lower[0] - upper[0], lower[2] - upper[2]
    length = hypot(dx, dz)
    shoulder_x, shoulder_z = dz / length, -dx / length
    relief = item(parent, "Folder", "Harbor to Cinder roadside relief")

    def world(fraction, lateral, height):
        return (upper[0] + dx * fraction + shoulder_x * lateral, height,
                upper[2] + dz * fraction + shoulder_z * lateral)

    def model(name):
        group = item(relief, "Model", name)
        prop(group, "token", "ModelStreamingMode", 1)
        prop(group, "token", "LevelOfDetail", 4)
        return group

    def layer(group, sections, side, bands, shades, rock_material, variant, label):
        """Join uneven cross sections into layered stone faces."""
        contours = []
        for across, lift, shift in bands:
            contours.append([
                world(fraction + shift * (1 if index % 2 else -.67), side * (toe + width * across),
                      -5.9 + (upper[1] + (lower[1] - upper[1]) * fraction + crest + 5.9) * lift)
                for index, (fraction, toe, width, crest) in enumerate(sections)
            ])
        faces = []

        def facet(points, tint, material):
            faces.append(points)
            before = len(group)
            triangle(group, *points, tint, name=label, material=material,
                     thickness=.19, shadow=False, collide=False)
            if material == rock_material:
                for wedge in group[before:]:
                    prop(wedge, "string", variant_field, variant)

        for band, (front, back) in enumerate(zip(contours, contours[1:])):
            for index, (a, b, c, d) in enumerate(zip(front, front[1:], back[1:], back)):
                rock_face = band < len(shades)
                tint = shades[band] if rock_face else ("687C59", "738364", "677B63")
                material = rock_material if rock_face else grass
                facet((a, b, c), tint[(index + band) % 3], material)
                facet((a, c, d), tint[(index + band + 1) % 3], material)
        for end in (0, -1):
            toe = contours[0][end]
            for index, (front, back) in enumerate(zip(contours[1:], contours[2:])):
                facet((toe, front[end], back[end]), shades[0][index % 3], rock_material)
        return faces

    def grow(group, faces, kind, fraction, offset, scale, turn, color):
        x, _, z = world(fraction, offset, 0)
        y = ridge_surface_height(faces, x, z)
        before = len(group)
        garden_prop(group, kind, (x, y - .09, z), scale, turn, color)
        for addition in group[before:]:
            shadow = addition.find("Properties/bool[@name='CastShadow']")
            if shadow is not None:
                shadow.text = "false"

    landward = model("Terraced Cinder clay cut")
    clay_faces = layer(landward, CLAY_SECTIONS, -1,
                       ((0, 0, 0), (.13, .30, .015), (.21, .48, -.017), (.36, .52, .025),
                        (.46, .79, -.014), (.60, .93, .014), (.75, 1, 0), (1, 0, -.013)),
                       CLAY_SHADES, sandstone, sandstone_variant, "Cinder clay outcrop")

    def cedar_piece(group, name, position, size, tint, **pose):
        piece = part(group, name, position, size, tint, material=wood if name.endswith("trunk") else grass,
                     collide=False, **pose)
        prop(piece, "bool", "CastShadow", False)

    for index, (fraction, offset, scale) in enumerate(((.22, -24.0, .73), (.34, -25.2, .94),
                                                       (.56, -22.0, .63), (.70, -23.6, .83))):
        x, _, z = world(fraction, offset, 0)
        hillside_cedar(cedar_piece, landward, x, ridge_surface_height(clay_faces, x, z) - .17, z, scale, index + 2)
    for kind, fraction, offset, scale, turn, tint in (
        ("bankRock", .14, -12.7, .28, 14, "A07B73"),
        ("meadowGrass", .21, -14.0, .25, 37, "A1A86A"),
        ("rockVine", .28, -14.7, .57, -79, "839853"),
        ("meadowCover", .34, -16.6, .35, 62, "A2AE72"),
        ("bankRock", .44, -13.1, .25, 32, "9D7973"),
        ("rockVine", .51, -14.0, .59, -102, "8E9F68"),
        ("meadowFlowers", .62, -15.4, .30, 72, "DAB48C"),
        ("meadowCover", .73, -16.2, .37, 30, "A5B071"),
        ("meadowGrass", .83, -13.2, .29, 91, "9D9D61"),
    ):
        grow(landward, clay_faces, kind, fraction, offset, scale, turn, tint)

    # Broken benches on the bay side leave openings between the rock shelves.
    for index, sections in enumerate(SLATE_POCKETS):
        seaward = model(("Upper Cinder slate shoulder", "Lower Tideharbor slate shoulder")[index])
        slate_faces = layer(seaward, sections, 1,
                            ((0, 0, 0), (.16, .35, -.015), (.39, .63, .017),
                             (.55, .95, -.016), (.72, 1, 0), (1, 0, .01)),
                            SLATE_SHADES, rock, rock_variant, "Tideharbor slate ledge")
        station = (.31, .68)[index]
        for kind, along, offset, scale, turn, tint in (
            ("bankRock", -.010, 12.6, .25, 33, "87838F"),
            ("meadowGrass", .038, 13.1, .29, 17, "AAB16E"),
            ("meadowCover", -.028, 13.0, .33, 75, "A0AD72"),
            ("grassBlade", .014, 14.4, .41, 43, "C7AF75"),
        ):
            grow(seaward, slate_faces, kind, station + along, offset, scale, turn + 38 * index, tint)
