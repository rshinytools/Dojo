"""A timber cargo hoist beside the harbor's parcel-to-pier footpath."""


# Measured from Poochiegirl72's free Crate Mesh in a detached Studio trial.
_CRATE_SIZE = (3.87242, 3.85828, 3.87670)
_CRATE_MESH = "rbxassetid://441464479"
_CRATE_TEXTURE = "rbxassetid://441464494"


def build_tideharbor_loading_bay(town, *, item, prop, part, beam, vector, asset,
                                slate, cedar, metal, cedar_variant, variant_field):
    """Ground the loading yard against the storehouse and clear of the pier approach."""
    bay = item(town, "Model", "Tideharbor cargo hoist")
    prop(bay, "token", "ModelStreamingMode", 1)
    prop(bay, "token", "LevelOfDetail", 4)
    x, z, ground = 228.75, 32.52, 3.027

    def detail(name, dx, lift, dz, size, tint, material=cedar, **pose):
        piece = part(bay, name, (x + dx, ground + lift, z + dz), size, tint,
                     material=material, collide=False, **pose)
        prop(piece, "bool", "CastShadow", False)
        if material == cedar:
            prop(piece, "string", variant_field, cedar_variant)
        return piece

    for side in (-1, 1):
        dz = side * 1.79
        detail("Hoist dressed slate foot", 0, .26, dz, (.78, .49, .86), "8D8487", slate)
        detail("Hoist tapered lacquered post", 0, 3.19, dz, (.46, 5.61, .51), "386864")
        detail("Exposed cedar face of post", -.246, 3.10, dz, (.06, 4.83, .24), "558584")
        for lift in (.70, 4.91):
            detail("Hoist brass post band", 0, lift, dz, (.54, .16, .59), "BC935C", metal)
        tie = beam(bay, "Cedar hoist knee", (x, ground + 4.59, z + side * 1.67),
                   (x, ground + 5.73, z + side * .82), .28, "44645C")
        prop(tie, "bool", "CastShadow", False)
        detail("Tied hoist beam end", 0, 5.79, side * 2.17, (.71, .54, .37), "4D7776")

    detail("Cargo crossbeam", 0, 5.82, 0, (.60, .45, 4.66), "416E69")
    detail("Rain cap of crossbeam", 0, 6.13, 0, (.78, .16, 4.48), "304E56")
    detail("Hoist winch axle", -.23, 5.41, .14, (.32, .71, .71), "654B3C", shape=2)
    detail("Winch brass collar", -.414, 5.41, .14, (.095, .55, .55), "AD8C58", metal, shape=2)
    detail("Taut hoist rope", -.51, 4.16, .20, (.063, 2.13, .068), "A98A68")
    detail("Pallet stone clearance", -.30, .07, .04, (2.21, .12, 2.47), "6D6258", slate)
    for index in range(4):
        detail("Loading pallet plank", -.30, .19, -.83 + index * .58,
               (1.98, .14, .52), ("9E7654", "A98059")[index % 2])
    for dx, lift, dz, factor, yaw in ((-.66, .23, .68, .31, 11), (.49, .23, .75, .28, -8),
                                      (-.65, 1.42, .71, .24, 4), (.18, .21, -1.03, .30, 23)):
        size = tuple(dimension * factor for dimension in _CRATE_SIZE)
        crate = part(bay, "Harbor cargo crate", (x + dx, ground + lift + size[1] / 2, z + dz), size,
                     "CFB795", yaw=yaw, material=cedar, collide=False, class_name="MeshPart")
        vector(crate, "Vector3", "InitialSize", ("X", "Y", "Z"), _CRATE_SIZE)
        asset(crate, "MeshContent", _CRATE_MESH)
        asset(crate, "TextureContent", _CRATE_TEXTURE)
        prop(crate, "token", "RenderFidelity", 0)
        prop(crate, "bool", "CastShadow", False)
