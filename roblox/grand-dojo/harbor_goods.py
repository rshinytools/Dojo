"""Screened Creator Store meshes in Tideharbor's waterfront scene."""


def build_harbor_goods(town, *, item, prop, part, vector, asset):
    goods = item(town, "Model", "Tideharbor waterfront goods")
    prop(goods, "token", "ModelStreamingMode", 1)

    def place(name, x, floor, z, size, mesh_size, yaw, mesh, texture, tint="A3A2A5"):
        piece = part(goods, name, (x, floor + size[1] / 2, z), size, tint,
                     yaw=yaw, material=256, collide=False, class_name="MeshPart")
        vector(piece, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        prop(piece, "bool", "CastShadow", False)
        prop(piece, "token", "RenderFidelity", 0)
        asset(piece, "MeshContent", f"rbxassetid://{mesh}")
        asset(piece, "TextureContent", f"rbxassetid://{texture}")

    # Fish Crate Stack by ninyo0403, Creator Store 100881692181403.
    place("Fish crate stack", 248.55, 4.50, 42.42, (2.12, 1.736, 1.56),
          (5.3, 4.34, 3.9), -9, 99009168931797, 72227056050719)

    # Wooden Barrel Low Poly Anime Like by RenanMSV, Creator Store 11646010485.
    barrel_size = (2.828404, 3.290315, 2.828404)
    for x, z, yaw, scale in ((246.1, 42.65, 21, .40), (256.35, 37.34, -45, .51)):
        place("Harbor cargo barrel", x, 4.50, z, tuple(axis * scale for axis in barrel_size),
              barrel_size, yaw, 11646010071, 11646010356)

    # Wooden skiff by MusicZip, Creator Store 8627497756.
    # Keep the authored asset proportions while scaling it to the local boats.
    place("Wooden harbor skiff", 308.40, .98, 49.20, (3.35, 2.028, 6.43),
          (2.575352, 1.804450, 5.766336), 34, 8618061922, 8618061992, tint="80777A")
