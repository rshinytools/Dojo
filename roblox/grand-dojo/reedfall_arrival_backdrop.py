"""Visual-only slate shoulders beside the upper Reedfall curtains."""

from south_valley_backdrop import hillside_cedar


# Stagger the crest from west to east. The noses start behind the waterfall
# sheets and step away from the spring mouth, which stays open to the plaza.
SHOULDERS = (
    ("West spring crag", 21.9, -48.8, 37.4, 49.8, 7.7, 7.4, -.55, "cedar"),
    ("East spring terrace", 36.4, -51.0, 34.1, 46.7, 7.5, 6.2, .60, "cedar"),
    ("Reedfall lower shoulder", 39.2, -41.6, 23.8, 34.4, 6.9, 5.8, .35, "blossom"),
    ("Reedfall far shoulder", 43.4, -53.8, 28.7, 42.6, 10.1, 7.9, .78, "cedar"),
)
OUTLINE = ((-.49, -.23), (-.28, -.51), (.30, -.47), (.50, -.11),
           (.44, .34), (.08, .52), (-.39, .40))
FACE_TONES = ("756575", "796B7B", "857584", "8C7886", "A2878C", "947E88", "827286")
FACE_NOTCHES = (.14, -.07, .09, -.03, .12, -.15, .04)


def build_reedfall_arrival_backdrop(parent, *, item, prop, part, triangle, garden_prop,
                                   cedar_part, slate, rock, grass, rock_variant, variant_field):
    backdrop = item(parent, "Model", "Reedfall arrival shoulders")
    prop(backdrop, "token", "LevelOfDetail", 4)

    def face(model, a, b, c, tint, name, material):
        start = len(model)
        triangle(model, a, b, c, tint, name=name, thickness=.13, material=material,
                 collide=False, shadow=False)
        if material == rock:
            for piece in model[start:]:
                prop(piece, "string", variant_field, rock_variant)

    def block(model, name, xyz, dimensions, tint, *, material, **rotation):
        piece = part(model, name, xyz, dimensions, tint, material=material,
                     collide=False, **rotation)
        prop(piece, "bool", "CastShadow", False)

    for index, (name, x, z, foot, crest, width, depth, shift, tree) in enumerate(SHOULDERS):
        model = item(backdrop, "Model", name)
        ledges = []
        for fraction, span, advance in ((0, .98, .87), (.61, .90, .36),
                                         (.88, .98, .12), (1, .75, -.15)):
            edge = []
            for corner, (across, reach) in enumerate(OUTLINE):
                offset = FACE_NOTCHES[(corner + index) % len(OUTLINE)]
                edge.append((x + width * across * span + shift * fraction,
                             foot + (crest - foot) * fraction + offset,
                             z + depth * reach * span + advance + shift * across * .32))
            ledges.append(edge)

        lower, ledge, shoulder, top = ledges
        for corner, tint in enumerate(FACE_TONES):
            next_corner = (corner + 1) % len(OUTLINE)
            lip_tint = ("AC9298", "96818F", "A58F97")[corner % 3]
            # The back is a continuous stone face. Break only the visible
            # front into an inset weathered course and a lighter overhang.
            courses = ((lower, top, tint),)
            if corner >= 3:
                courses = ((lower, ledge, tint), (ledge, shoulder, "796A79"),
                           (shoulder, top, lip_tint))
            for bottom, upper, shade in courses:
                a, b = bottom[corner], bottom[next_corner]
                d, c = upper[corner], upper[next_corner]
                face(model, a, b, d, shade, "Reedfall fractured shoulder", rock)
                face(model, b, c, d, shade, "Reedfall fractured shoulder", rock)

        moss = ("799451", "839D57", "73904E", "6D894B")[index]
        top_x = x + shift
        top_z = z - .15
        stone_center = (top_x, crest - .04, top_z)
        moss_center = (top_x, crest + .115, top_z)
        moss_edge = [(top_x + (a - top_x) * .79, y + .12, top_z + (b - top_z) * .80)
                     for a, y, b in top]
        for a, b in zip(top, top[1:] + top[:1]):
            face(model, stone_center, a, b, "958390", "Reedfall slate crest", slate)
        for a, b in zip(moss_edge, moss_edge[1:] + moss_edge[:1]):
            face(model, moss_center, a, b, moss, "Reedfall moss cover", grass)

        planting = (
            ("meadowCover", -.19, .09, .14, .23, "9DB267"),
            ("rockVine", .21, -1.37, .34, .59, "869D55"),
            ("meadowGrass", .17, .09, .15, .23, "AAB765"),
        )
        for key, across, rise, reach, scale, tint in planting:
            garden_prop(model, key, (top_x + across * width, crest + rise, top_z + reach * depth),
                        scale, 22 + index * 53, tint)

        if tree == "cedar":
            scale = (.55, .40, 0, .44)[index]
            hillside_cedar(cedar_part, model, top_x - width * .12, crest + .04,
                           top_z - depth * .10, scale, index + 7)
        else:
            block(model, "Reedfall terrace blossom trunk", (top_x, crest + 1.02, top_z),
                  (.35, 2.21, .38), "77534A", material=rock, roll=-11)
            for dx, dy, dz, dimensions, tint in (
                (-.92, 1.93, .12, (2.29, .93, 1.75), "C383A2"),
                (.69, 2.21, .22, (2.37, 1.15, 1.86), "DB93AC"),
                (-.17, 2.58, -.16, (2.44, 1.03, 1.92), "E6A7BC"),
            ):
                block(model, "Reedfall terrace blossom crown", (top_x + dx, crest + dy, top_z + dz),
                      dimensions, tint, material=grass, shape=0, yaw=22)
