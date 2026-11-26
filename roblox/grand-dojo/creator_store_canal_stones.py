"""The screened mossy Boulder mesh and its material maps."""


def build_canal_store_stones(canal, *, item, part, prop, vector, asset, plastic):
    stones = item(canal, "Model", "Mossy canal stones")
    prop(stones, "token", "ModelStreamingMode", 1)
    prop(stones, "token", "LevelOfDetail", 4)
    # @Robloxyman_isgood's Boulder, Creator Store 13372770550.
    # Use the native mesh proportions. The published model is scaled to 360 studs.
    mesh_size = (6.857651, 5.498016, 6.614761)
    for x, y, z, yaw, scale, isolated in (
        (-26.76, .40, 54.74, 42, .53, False),
        (-9.35, .31, 50.12, 79, .36, True),
    ):
        stone = part(stones, "Mossy waterline boulder", (x, y, z),
                     tuple(d * scale for d in mesh_size), "B6ADA5",
                     yaw=yaw, material=plastic, collide=False, class_name="MeshPart")
        vector(stone, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        prop(stone, "bool", "DoubleSided", True)
        prop(stone, "bool", "CastShadow", False)
        prop(stone, "token", "RenderFidelity", 0)
        asset(stone, "MeshContent", "rbxassetid://5547039389")
        asset(stone, "TextureContent", "rbxassetid://5196955925")
        surface = item(stone, "SurfaceAppearance", "Creator Store moss and stone")
        prop(surface, "token", "AlphaMode", 0)
        for channel, identifier in (
            ("Color", 5196965320),
            ("Normal", 5196969863),
            ("Roughness", 5196970401),
            ("Metalness", 5196976314),
        ):
            asset(surface, f"{channel}MapContent", f"rbxassetid://{identifier}")
        if isolated:
            # Stay inside the inlet stone silhouette and leave the swim stairs clear.
            core = part(stones, "Lotus inlet boulder collision", (x, y, z), (1.72, 1.42, 1.66),
                        yaw=yaw, tint="B6ADA5", shape=0, material=plastic, transparency=1)
            prop(core, "bool", "CastShadow", False)
