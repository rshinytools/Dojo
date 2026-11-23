"""Two offshore rock meshes from the official Core curriculum library."""

SEA_STACK_VARIANT = "Moss_Strata_Noisy_A"
SEA_STACK_MATERIAL = 1392  # Enum.Material.Salt


def build_tideharbor_sea_stacks(offshore, *, item, part, prop, vector, asset, variant_field):
    group = item(offshore, "Model", "Tideharbor channel sea stacks")
    for name, mesh_id, source_size, center, size, yaw, tint in (
        ("Channel sea arch", 13663762975, (54.652977, 67.429153, 53.071938),
         (529, 22.1, -158), (47, 53, 42), -34, "E9D1CA"),
        ("Channel outer sea stack", 13480034616, (57.800667, 66.999115, 52.680763),
         (572, 12.5, -209), (34, 34, 32), 28, "D1BCC7"),
    ):
        # The nearest mesh edge lies beyond the player swim boundary.
        rock = part(group, name, center, size, tint, yaw=yaw, class_name="MeshPart",
                    material=SEA_STACK_MATERIAL, collide=False)
        vector(rock, "Vector3", "InitialSize", ("X", "Y", "Z"), source_size)
        asset(rock, "MeshContent", f"rbxassetid://{mesh_id}")
        prop(rock, "string", variant_field, SEA_STACK_VARIANT)
        prop(rock, "bool", "CastShadow", False)
        prop(rock, "token", "RenderFidelity", 2)  # Performance
