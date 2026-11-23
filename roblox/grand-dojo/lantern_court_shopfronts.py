"""Lacquer, slate, and paper lattice for the Lantern Circuit market aisle."""


def build_lantern_court_shopfronts(
    town, x, y, z, *, item, prop, part, slate, wood, metal, neon,
    cedar_variant, brass_variant, variant_field,
):
    court = item(town, "Model", "Lantern Court shopfronts")
    prop(court, "token", "ModelStreamingMode", 1)
    prop(court, "token", "LevelOfDetail", 4)

    def frontage(label, wall_x, center_z, length, height, inward, paper):
        shop = item(court, "Model", label)

        def trim(name, outward, lift, span_at, size, tint, material):
            detail = part(shop, name, (wall_x + outward * inward, y + lift, center_z + span_at),
                          size, tint, material=material, collide=False)
            prop(detail, "bool", "CastShadow", False)
            variant = cedar_variant if material == wood else brass_variant if material == metal else None
            if variant:
                prop(detail, "string", variant_field, variant)

        # Slate and cedar follow the existing wall rather than narrowing the lane.
        top = height + .42
        for name, lift, width, thickness, depth, tint, material in (
            ("Slate shop skirt", .76, .17, .68, length - .42, "786575", slate),
            ("Weathered skirt cap", 1.14, .26, .13, length - .34, "A28A93", slate),
            ("Plum wainscot cap", 2.04, .26, .18, length - .31, "794759", wood),
            ("Copper wainscot inlay", 2.18, .24, .054, length - .39, "C18C62", metal),
            ("Cedar eave stringcourse", top - .74, .34, .38, length - .12, "674458", wood),
            ("Raised bronze eave edge", top - .51, .36, .08, length - .15, "C49068", metal),
        ):
            trim(name, width * .37, lift, 0, (width, thickness, depth), tint, material)

        for span_at in (-length * .438, 0, length * .438):
            trim("Recessed shop timber upright", .12, (top + 1.02) / 2, span_at,
                 (.23, top - 1.36, .40), "78465D", wood)
            trim("Warm upright edge", .255, (top + 1.13) / 2, span_at - .11,
                 (.054, top - 1.84, .061), "A3676E", wood)
            for lift, reach, tint in ((top - 1.23, .28, "88536A"),
                                      (top - .97, .44, "9F656D"),
                                      (top - .71, .53, "A97673")):
                trim("Stepped eave bracket", reach * .39, lift, span_at,
                     (reach, .23, .59), tint, wood)

        panel_width = length * .329
        panel_height = min(3.40, height * .359)
        panel_y = height * .652 + .37
        for sign in (-1, 1):
            bay = length * .224 * sign
            trim("Deep lacquered casement", .129, panel_y, bay,
                 (.24, panel_height + .46, panel_width + .23), "624251", wood)
            trim("Amber paper inside shop lattice", .263, panel_y, bay,
                 (.075, panel_height, panel_width - .12), paper, neon)
            for grid in (-.28, 0, .28):
                trim("Cedar casement mullion", .329, panel_y, bay + panel_width * grid,
                     (.087, panel_height + .015, .078), "865765", wood)
            for lift in (-.24, .24):
                trim("Cedar casement divider", .330, panel_y + panel_height * lift, bay,
                     (.087, .088, panel_width), "906066", wood)
            trim("Projecting bronze casement sill", .245, panel_y - panel_height / 2 - .17, bay,
                 (.35, .135, panel_width + .33), "B78362", metal)
            trim("Carved slate apron", .130, panel_y - panel_height / 2 - .45, bay,
                 (.22, .34, panel_width + .19), "907989", slate)

    frontage("West entry shop", x - 9.5, z + 12, 11, 8, 1, "DF9F74")
    frontage("East entry shop", x + 10, z + 11, 12, 9, -1, "DBA27E")
    frontage("West lantern shop", x - 11.5, z - 10, 13, 9, 1, "E5AA78")
    frontage("East cloth shop", x + 10.5, z - 11, 14, 11, -1, "DB9F86")
