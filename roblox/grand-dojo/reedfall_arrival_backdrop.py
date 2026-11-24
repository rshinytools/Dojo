"""Stepped, planted slate beside the Reedfall curtains."""


# Stagger the crest from west to east. The noses start behind the waterfall
# sheets and step away from the spring mouth, which stays open to the plaza.
SHOULDERS = (
    # name, x, z, foot, crest, width, depth, sweep, tree, scale, turn
    ("West spring crag", 21.7, -48.6, 37.4, 49.8, 8.4, 7.7, -.48, "pine", .66, -63),
    ("East spring terrace", 37.6, -49.4, 34.1, 46.7, 8.7, 6.9, .60, "pine", 1.06, 35),
    ("Reedfall lower shoulder", 42.7, -45.3, 26.5, 34.4, 7.5, 6.4, .35, "blossom", .71, 42),
    ("Reedfall far shoulder", 44.4, -51.4, 28.7, 42.6, 10.1, 7.9, .78, "pine", .67, -11),
    ("Rose bank below the side spill", 39.1, -33.1, 13.65, 16.45, 6.9, 4.65, .39, "blossom", .69, -37),
    ("Low moss bench", 43.0, -31.3, 8.86, 10.37, 6.30, 4.71, -.24, None, 0, 0),
)
OUTLINE = ((-.49, -.23), (-.28, -.51), (.30, -.47), (.50, -.11),
           (.44, .34), (.08, .52), (-.39, .40))
FACE_TONES = ("756575", "796B7B", "857584", "8C7886", "A2878C", "947E88", "827286")
FACE_NOTCHES = (.14, -.07, .09, -.03, .12, -.15, .04)


def build_reedfall_arrival_backdrop(parent, *, item, prop, part, triangle, garden_prop,
                                   showcase_tree, slate, rock, grass, rock_variant, variant_field):
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

    for index, (name, x, z, foot, crest, width, depth, shift, tree, tree_scale, turn) in enumerate(SHOULDERS):
        model = item(backdrop, "Model", name)
        prop(model, "token", "ModelStreamingMode", 1)
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

        moss = ("889F56", "90A957", "819B51")[index % 3]
        top_x = x + shift
        top_z = z - .15
        stone_center = (top_x, crest - .04, top_z)
        moss_center = (top_x, crest + .115, top_z)
        moss_edge = [(top_x + (a - top_x) * .87, y + .12, top_z + (b - top_z) * .89)
                     for a, y, b in top]
        for a, b in zip(top, top[1:] + top[:1]):
            face(model, stone_center, a, b, "958390", "Reedfall slate crest", slate)
        for a, b in zip(moss_edge, moss_edge[1:] + moss_edge[:1]):
            face(model, moss_center, a, b, moss, "Reedfall moss cover", grass)

        for offset, reach, span, tint in (
            (-.23, .29, .31, "90A458"), (.033, .37, .26, "A4B568"),
            (.24, .24, .26, "7D9950"),
        ):
            block(model, "Overhanging cushion of moss",
                  (top_x + offset * width, crest - .10, top_z + reach * depth),
                  (span * width, .58, .26 * depth), tint, material=grass, shape=0, yaw=turn)
        planting = (
            ("meadowCover", -.19, .09, .14, .28, "A9BC6D"),
            ("rockVine", .16, -1.0, .34, .57, "97AC66"),
            ("meadowGrass", .22, .09, .15, .26, "BBC375"),
            ("mossFlowers", -.24, .13, .23, .19, "E1A5A5"),
            ("bankRock", .30, -.22, .16, .20, "A79A9F"),
        )
        for key, across, rise, reach, scale, tint in planting:
            first = len(model)
            garden_prop(model, key, (top_x + across * width, crest + rise, top_z + reach * depth),
                        scale, 22 + index * 53, tint)
            for detail in model[first:]:
                shadow = detail.find("Properties/bool[@name='CastShadow']")
                if shadow is not None:
                    shadow.text = "false"

        if tree:
            showcase_tree(model, top_x - width * .06, top_z + depth * .02, tree == "blossom",
                          tree_scale, turn, crest -.08, compact=True,
                          height_scale=.83 if tree == "blossom" else .70, crown_spread=1.25,
                          hero_crown=index==1)
