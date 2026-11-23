"""Place the screened Creator Store meshes on existing market surfaces."""


def build_lantern_market_goods(town, x, y, z, *, item, prop, part, vector, asset):
    goods = item(town, "Model", "Lantern Circuit market goods")
    prop(goods, "token", "ModelStreamingMode", 1)

    def place(name, position, display_size, mesh_size, scale, mesh_id, texture_id, *, yaw, pitch=0):
        size = tuple(value * scale for value in display_size)
        px, floor, pz = position
        height = size[2] if pitch else size[1]
        mesh = part(goods, name, (px, floor + height / 2, pz), size, "A3A2A5",
                    yaw=yaw, pitch=pitch, material=256, collide=False, class_name="MeshPart")
        # The serialized mesh bounds differ from the seller's scaled part size.
        vector(mesh, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        prop(mesh, "bool", "CastShadow", False)
        prop(mesh, "token", "RenderFidelity", 0)
        asset(mesh, "MeshContent", f"rbxassetid://{mesh_id}")
        asset(mesh, "TextureContent", f"rbxassetid://{texture_id}")

    # Vell00's Vase, Creator Store 3537726151. The original mesh's Z axis is vertical.
    for offset, depth, scale, yaw in ((-14.12, -36.90, .53, -90),
                                      (-10.23, -37.0, .38, -64)):
        place("Glazed market vase", (x + offset, y + 8.63, z + depth),
              (1.000002, 1.000002, 1.900001), (18.43790, 18.54700, 35.68560),
              scale, 3537715861, 3537716008,
              yaw=yaw, pitch=90)
    # ShanebruvPepper2's grainbag, Creator Store 11110546551.
    for offset, depth, scale, yaw in ((-12.14, -10.46, .37, 115),
                                      (12.05, 14.48, .31, 67)):
        place("Open stall grain sack", (x + offset, y + .027, z + depth),
              (3.563446, 3.325435, 3.493175), (2.651538, 2.474435, 2.599249),
              scale, 921386543, 921386597,
              yaw=yaw)
