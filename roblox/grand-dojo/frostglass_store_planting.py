"""Screened Creator Store winter foliage for Frostglass Gardens."""


def _planting(parent, label, *, item, prop, part, vector, asset):
    planting = item(parent, "Model", label)
    prop(planting, "token", "ModelStreamingMode", 1)

    def mesh(name, x, z, yaw, size, mesh_size, mesh_id, texture_id, floor, *, double_sided=False):
        decoration = part(planting, name, (x, floor + size[1] / 2 - .035, z), size,
                          "A3A2A5", yaw=yaw, material=256, collide=False, class_name="MeshPart")
        vector(decoration, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        prop(decoration, "bool", "DoubleSided", double_sided)
        prop(decoration, "bool", "CastShadow", False)
        prop(decoration, "token", "RenderFidelity", 0)
        asset(decoration, "MeshContent", f"rbxassetid://{mesh_id}")
        asset(decoration, "TextureContent", f"rbxassetid://{texture_id}")
        return decoration

    # Striatp's Small Snowy Pine Tree, Creator Store 76188132698241.
    pine_size = (9.574310, 15.486298, 9.574753)
    def pine(name, x, z, yaw, scale, floor):
        tree = mesh(name, x, z, yaw,
                    tuple(axis * scale for axis in pine_size), pine_size, 6436440031, 6341718741,
                    floor, double_sided=True)
        material = item(tree, "SurfaceAppearance", "Creator Store snowy pine material")
        prop(material, "token", "AlphaMode", 1)
        asset(material, "ColorMapContent", "rbxassetid://6901062953")

    return pine, mesh


def build_frostglass_store_planting(town, *, item, prop, part, vector, asset):
    pine, mesh = _planting(town, "Frostglass winter planting", item=item, prop=prop, part=part,
                           vector=vector, asset=asset)
    floor = 14.027
    for x, z, yaw, scale in ((-216.27, -194.15, 18, .33), (-162.19, -204.20, 53, .37),
                             (-210.21, -204.84, 87, .42)):
        pine("Snow-dusted courtyard pine", x, z, yaw, scale, floor)

    # akmadman7273's Snow Bush, Creator Store 1163700582.
    bush_size = (6.442000, 4.138090, 6.317780)
    for x, z, yaw, scale in ((-198.80, -158.65, 35, .25), (-177.82, -154.29, 64, .21),
                             (-163.66, -204.53, 102, .24)):
        mesh("Frosted garden shrub", x, z, yaw, tuple(axis * scale for axis in bush_size),
             bush_size, 742756209, 1093033181, floor)


def build_frostglass_approach_planting(roads, *, item, prop, part, vector, asset):
    pine, _ = _planting(roads, "Frostglass approach pines", item=item, prop=prop, part=part,
                        vector=vector, asset=asset)
    # Ground heights measured against native Terrain in Studio Play.
    for x, z, yaw, scale, floor in (
        (-219, -123, 18, .41, 7.40),
        (-217, -134, 77, .49, 8.25),
        (-214, -142, 44, .34, 10.73),
        (-199, -119, 32, .33, 7.99),
        (-193, -130, 63, .40, 9.80),
        (-191, -138, 81, .50, 10.54),
    ):
        pine("Snow-dusted roadside pine", x, z, yaw, scale, floor)
