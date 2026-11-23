"""A curved, tiled gateway on the existing Lantern Circuit road threshold."""


def build_lantern_town_gate(town, x, y, z, *, item, prop, part, beam, gate, sign,
                            swept_roof, curved_plaque, marquee_title, festival_lantern,
                            banner, slate, wood, brass, wood_variant, variant_field):
    # Retain the original column bases and colliders at this road junction.
    gate(town, x, z, 90, span=15, trim="68477E", y=y,
         lanterns=False, straight_lintel=False)
    portal = item(town, "Model", "Lantern Circuit arched gateway")
    prop(portal, "token", "ModelStreamingMode", 1)
    prop(portal, "token", "LevelOfDetail", 4)

    def finish(name, across, lift, facing, size, tint, material, **options):
        node = part(portal, name, (across, lift, facing), size, tint, material=material,
                    collide=False, **options)
        prop(node, "bool", "CastShadow", False)
        if material == wood:
            prop(node, "string", variant_field, wood_variant)

    for side in (-1, 1):
        post = side * 7.52
        finish("Fan gate slate plinth", post, .31, .01, (2.44, .62, 2.49), "8E758D", slate)
        finish("Honed gate base", post, 1.11, .02, (2.12, .23, 2.28), "B497A2", slate)
        finish("Deep cedar pilaster", post, 5.22, .20, (1.39, 8.28, 1.69), "864258", wood)
        for face in (-1, 1):
            finish("Raised cedar stile", post + side * .44, 5.39, face * .93,
                   (.16, 7.12, .12), "A45963", wood)
            finish("Gilt inlaid stile", post + side * .47, 5.43, face * 1.01,
                   (.052, 6.71, .048), "CAA36A", brass)
        for height, width, size_y, tint, material in (
            (1.56, 1.84, .24, "B58061", brass),
            (2.24, 1.64, .26, "B38261", brass),
            (8.33, 1.62, .25, "C08E65", brass),
            (8.83, 2.10, .43, "72405A", wood),
            (9.23, 2.54, .42, "975664", wood),
        ):
            finish("Stepped gate collar", post, height, .19, (width, size_y, width), tint, material)
        beam(portal, "Raked timber gate bracket", (post - side * .36, 7.91, .28),
             (post - side * 2.09, 9.39, .28), .46, "A36061")
        beam(portal, "Gilded gate bracket toe", (post - side * .77, 8.21, .55),
             (post - side * 1.79, 9.20, .55), .096, "C89565")
        banner(portal, side * 9.29, 5.46, 1.11, scale=.75, vermilion=True)
        festival_lantern(portal, post - side * 2.0, 7.74, 1.34, 1.02, light=True, tint="FFC483")

    profile = tuple((offset, 10.71 - 1.40 * (offset / 9.08) ** 2)
                    for offset in (-9.08, -7.5, -5.8, -3.75, -1.75, 0, 1.75, 3.75, 5.8, 7.5, 9.08))
    curved_plaque(portal, 0, .92, profile, 2.47, "864054", "D3A064", rim_height=.20)
    marquee_title(portal, "LANTERN CIRCUIT", 0, .92, profile, 1.53)
    finish("Return lintel cedar housing", 0, 8.73, -.70, (16.58, .61, .52), "70435C", wood)
    sign(portal, "GRAND DOJO CITY", 0, 8.71, -1.04, 10.35, 1.34, 180, "604756", face_only=True)
    swept_roof(portal, 0, 11.95, .03, 21.3, 6.20, 2.60, fine_tiles=False,
               signature=True, corner_sweep=1.31)

    # The framing helpers build along the local +Z face. Turn the complete
    # scene to face east without changing object-relative surfaces or labels.
    for transform in portal.iter("CoordinateFrame"):
        components = {node.tag: float(node.text) for node in transform}
        components.update(X=x + components["Z"], Y=y + components["Y"], Z=z - components["X"])
        for column in range(3):
            a, b = f"R0{column}", f"R2{column}"
            components[a], components[b] = components[b], -components[a]
        for node in transform:
            node.text = f"{components[node.tag]:.9g}"
