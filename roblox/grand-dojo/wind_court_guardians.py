"""Scale the screened Creator Store stone guardian to the Wind Court square."""


def build_wind_court_guardians(court, x, z, square, *, item, part, prop, vector, asset,
                              slate, stone_variant, variant_field):
    group = item(court, "Model", "Wind Court stone guardians")
    prop(group, "token", "ModelStreamingMode", 1)
    prop(group, "token", "LevelOfDetail", 4)
    # @Suizei's Lion Dog Statue, Creator Store 4698399766.
    mesh_size = (2.555732, 3.753888, 3.465542)
    scale = .89
    size = tuple(length * scale for length in mesh_size)
    for side in (-1, 1):
        sx, sz = x + side * 13.82, z - 1.48
        for label, lift, size_at_lift, tint in (
            ("Slate guardian plinth", .18, (2.96, .36, 3.66), "897E8C"),
            ("Honed guardian plinth cap", .39, (2.77, .13, 3.49), "A89AA3"),
        ):
            foot = part(group, label, (sx, square + lift, sz), size_at_lift,
                        tint, material=slate, collide=False)
            prop(foot, "bool", "CastShadow", False)
            prop(foot, "string", variant_field, stone_variant)
        statue = part(group, "Wind Court stone guardian",
                      (sx, square + .43 + size[1] / 2, sz), size, "A99DAB",
                      material=slate, yaw=180 + side * 12, collide=False, class_name="MeshPart")
        vector(statue, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        prop(statue, "bool", "CastShadow", False)
        prop(statue, "token", "RenderFidelity", 0)
        asset(statue, "MeshContent", "rbxassetid://3226536251")
