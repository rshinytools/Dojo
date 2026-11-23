"""Screened Creator Store cedars rooted on the new Crown Crossing shelves."""

from math import cos, radians, sin


def build_crown_ravine_cedars(landscape, *, item, part, prop, vector, asset, plastic, smooth):
    trees = item(landscape, "Model", "Crown ravine cedars")
    prop(trees, "token", "ModelStreamingMode", 1)
    prop(trees, "token", "LevelOfDetail", 4)

    # @terizaneYT's Low Poly Cedar, Creator Store 6829202915.
    # Offsets are measured from the native trunk foot rather than the model center.
    for x, y, z, turn, scale, foliage in (
        (126.007, 5.308, -79.359, 22, .46, "7C8B59"),
        (134.337, 8.096, -91.829, 61, .66, "829F62"),
        (147.740, 9.299, -80.548, 113, .59, "779461"),
        (153.629, 9.664, -77.991, 8, .47, "8BA262"),
    ):
        angle = radians(turn)
        for label, mesh_id, mesh_size, size, local_x, local_z, level, pigment, material in (
            ("Cedar trunk", 6829196713, (9.208286, 13.193968, 9.999723),
             (2.259655, 3.237715, 2.453868), -.04667, -.02218, 1.61886, "9B7B65", plastic),
            ("Cedar crown", 6829196812, (28.153000, 37.079510, 30.575943),
             (6.908566, 9.099074, 7.503141), 0, 0, 7.52971, foliage, smooth),
        ):
            px = x + scale * (local_x * cos(angle) + local_z * sin(angle))
            pz = z + scale * (-local_x * sin(angle) + local_z * cos(angle))
            visual = part(trees, label, (px, y - .16 + level * scale, pz),
                          tuple(length * scale for length in size), pigment,
                          yaw=turn, material=material, collide=False, class_name="MeshPart")
            vector(visual, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
            prop(visual, "bool", "CastShadow", False)
            prop(visual, "token", "RenderFidelity", 0)
            asset(visual, "MeshContent", f"rbxassetid://{mesh_id}")
