"""Textured foothills behind the Frostglass Gardens pavilion."""

# MountainMesh from Roblox Resources' Core Building and Scripting Library.
# The import's native MeshSize is much larger than its placed Size.
MESH_SIZE = (8186.36328125, 1297.867919921875, 7940.798828125)
MATERIAL_MAPS = {
    "ColorMapContent": 5022438374,
    "NormalMapContent": 5022485191,
    "RoughnessMapContent": 5022438534,
    "MetalnessMapContent": 5004526382,
}


def build_frostglass_snow_ridges(town, *, item, prop, part, vector, asset, color):
    ridges = item(town, "Model", "Frostglass snowy foothills")
    prop(ridges, "token", "ModelStreamingMode", 1)  # Atomic
    for name, center, size, yaw, tint in (
        ("Glacier near snow shoulder", (-257, 9, -274), (113, 29, 92), -24, "B7BCCF"),
        ("Glacier east snow ridge", (-151, 16, -300), (101, 30, 90), 21, "C3C8DA"),
    ):
        ridge = part(ridges, name, center, size, "A3A2A5", yaw=yaw, material=256,
                     collide=False, class_name="MeshPart")
        vector(ridge, "Vector3", "InitialSize", ("X", "Y", "Z"), MESH_SIZE)
        asset(ridge, "MeshContent", "rbxassetid://5547037419")
        asset(ridge, "TextureContent", f"rbxassetid://{MATERIAL_MAPS['ColorMapContent']}")
        prop(ridge, "bool", "CastShadow", False)
        prop(ridge, "token", "RenderFidelity", 2)  # Performance
        appearance = item(ridge, "SurfaceAppearance", "Snow ridge surface")
        prop(appearance, "token", "AlphaMode", 0)  # Overlay
        color(appearance, "Color", tint)
        for channel, asset_id in MATERIAL_MAPS.items():
            asset(appearance, channel, f"rbxassetid://{asset_id}")
