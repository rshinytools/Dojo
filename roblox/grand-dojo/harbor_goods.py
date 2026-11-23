"""Screened Creator Store meshes in Tideharbor's waterfront scene."""

from math import cos, radians, sin


def build_harbor_goods(town, *, item, prop, part, vector, asset, beam, triangle, fabric):
    goods = item(town, "Model", "Tideharbor waterfront goods")
    prop(goods, "token", "ModelStreamingMode", 1)

    def place(name, x, floor, z, size, mesh_size, yaw, mesh, texture, tint="A3A2A5", *, parent=goods):
        piece = part(parent, name, (x, floor + size[1] / 2, z), size, tint,
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

    boat = item(town, "Model", "Batten-sail harbor boat")
    prop(boat, "token", "ModelStreamingMode", 1)
    x, z, yaw = 383.8, 47.0, -13
    place("Batten-sail cedar hull", x, .69, z, (6.60, 3.31, 14.26),
          (2.575352, 1.804450, 5.766336), yaw, 8618061922, 8618061992,
          tint="AE9179", parent=boat)
    c, s = cos(radians(yaw)), sin(radians(yaw))

    def point(across, y, length):
        return x + across * c + length * s, y, z - across * s + length * c

    def timber(name, a, b, width, tint):
        spar = beam(boat, name, point(*a), point(*b), width, tint)
        prop(spar, "bool", "CastShadow", False)

    timber("Cedar boat mast", (0, 2.42, -1.12), (0, 14.71, -1.12), .28, "8A6046")
    timber("Forward mast stay", (0, 13.92, -1.12), (0, 3.62, -6.18), .07, "AC8861")
    timber("Aft mast stay", (0, 12.91, -1.12), (0, 3.61, 5.83), .064, "A57E5B")

    # The battens get shorter toward the foot. The canvas bulges away from
    # the mast so its silhouette stays readable across the water.
    courses = (
        (14.08, -1.46, 2.15, .14),
        (12.36, -1.50, 3.51, .31),
        (10.48, -1.47, 4.08, .48),
        (8.61, -1.41, 3.67, .48),
        (6.51, -1.27, 3.19, .33),
        (4.83, -1.10, 2.56, .19),
    )
    rows = [tuple(point(dx, y + rise, start + (end - start) * amount)
                  for dx, rise, amount in ((.02, .12, 0), (bulge, -.12, .52), (.09, -.26, 1)))
            for y, start, end, bulge in courses]
    for index, (upper, lower) in enumerate(zip(rows, rows[1:])):
        tones = ("D29573", "E3AC85") if index in (1, 4) else ("E4BE92", "F0D2A6")
        for column, tint in enumerate(tones):
            upper_left, upper_right = upper[column:column + 2]
            lower_left, lower_right = lower[column:column + 2]
            triangle(boat, upper_left, upper_right, lower_left, tint, name="Battened linen sail", thickness=.09,
                     material=fabric, collide=False, shadow=False)
            triangle(boat, upper_right, lower_right, lower_left, tint, name="Battened linen sail", thickness=.09,
                     material=fabric, collide=False, shadow=False)
    for y, start, end, bulge in courses:
        timber("Bamboo sail batten", (.01, y + .12, start), (bulge, y - .12, (start + end) / 2),
               .073, "A97353")
        timber("Bamboo sail batten", (bulge, y - .12, (start + end) / 2), (.09, y - .26, end),
               .073, "A97353")
