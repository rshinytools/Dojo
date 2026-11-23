"""Wayfinding and stone trim along the Cascade Lookout switchback."""


def build_reedfall_turning_landings(parent, *, left, right, north, south, level,
                                     item, prop, part, sign, garden_prop,
                                     slate, limestone, cedar, brass):
    detail = item(parent, "Model", "Reedfall switchback wayfinding")
    prop(detail, "token", "ModelStreamingMode", 1)
    prop(detail, "token", "LevelOfDetail", 4)
    middle = (left + right) / 2

    def trim(name, x, y, z, dimensions, tint, material):
        return part(detail, name, (x, y, z), dimensions, tint,
                    material=material, collide=False)

    # The lower and upper ramps approach this landing from the south.
    # The signs face both approaches from behind the north guardrail.
    board = north - .43
    trim("Reedfall cedar route board", middle, level + 2.30, board,
         (7.02, 1.75, .27), "6C4238", cedar)
    trim("Reedfall copper board cap", middle, level + 3.21, board,
         (7.28, .11, .38), "C88D57", brass)
    trim("Reedfall board sill", middle, level + 1.41, board,
         (7.15, .12, .32), "996246", cedar)
    trim("Reedfall copper board divider", middle, level + 2.28, board + .157,
         (6.54, .048, .045), "AF7851", brass)
    for side in (-1, 1):
        post_x = middle + side * 3.37
        trim("Reedfall board post", post_x, level + 1.32, board - .13,
             (.29, 3.68, .30), "8B513B", cedar)
        trim("Reedfall brass post collar", post_x, level + 3.09, board - .13,
             (.39, .14, .38), "C5925A", brass)
        trim("Reedfall board post saddle", post_x, level - .38, board + .07,
             (.46, .27, .48), "9F8B86", slate)

    for label, rise, tint in (
        ("CASCADE LOOKOUT  →", 2.72, "80533D"),
        ("←  REEDFALL GALLERY", 1.88, "40605A"),
    ):
        # The legacy sign fronts use a half-stud transparent mounting Part.
        # Put the back face just proud of the wood without widening the route.
        sign(detail, label, middle, level + rise, board - .09, 6.72, .66,
             tint=tint, face_only=True)
        trim("Reedfall wayfinding enamel", middle, level + rise, board + .11,
             (6.77, .68, .060), tint, cedar)

    # Visible courses sit outside and below the deck edge.
    for edge in (north, south):
        outside = -1 if edge == north else 1
        trim("Reedfall landing sandstone rim", middle, level - .26, edge + outside * .047,
             (right - left + .16, .14, .15), "BBA296", limestone)
        for index in range(6):
            width = (right - left) / 6
            x = left + width * (index + .5)
            trim("Reedfall landing slate facing", x, level - .42, edge + outside * .062,
                 (width - .055, .15, .13), ("8D7680", "98818A", "9C8790")[index % 3], slate)

    # Two exterior pockets draw the eye to the board without occupying the
    # landing. The existing on-deck corner planters continue to frame the turns.
    for side in (-1, 1):
        x = middle + side * 4.32
        z = north - .68
        trim("Reedfall exterior planter bracket", x, level - .31, z + .16,
             (.58, .43, 1.06), "785040", cedar)
        trim("Reedfall exterior slate trough", x, level + .01, z,
             (1.53, .41, 1.04), "8A7580", slate)
        trim("Reedfall sandstone trough rim", x, level + .24, z,
             (1.65, .105, 1.15), "B49D93", limestone)
        garden_prop(detail, "meadowGrass", (x - .16, level + .28, z - .11), .075,
                    31 + side * 18, "A4B16A")
        garden_prop(detail, "mossFlowers", (x + .23, level + .29, z + .03), .075,
                    78 + side * 29, "E7B1BE")

    for node in detail.findall("Item"):
        shadow = node.find("Properties/bool[@name='CastShadow']")
        if shadow is None:
            prop(node, "bool", "CastShadow", False)
        else:
            shadow.text = "false"
