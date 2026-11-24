"""Cinder cedar and tilework for the Clay Lantern overlook."""

from math import atan2, cos, degrees, radians, sin


def build_clay_lantern_shelter(parent, *, point, level, yaw, item, prop, part, beam,
                               swept_roof, festival_lantern, sign, garden_prop, vector, asset,
                               cedar, slate, limestone, brass, cedar_variant,
                               stone_variant, variant_field):
    shelter = item(parent, "Model", "Clay Lantern overlook shelter")
    prop(shelter, "token", "LevelOfDetail", 4)

    middle, center = 28.82, 23.27
    origin = point(middle, center, level)
    east = point(middle, center + 1, level)
    heading = degrees(atan2(east[0] - origin[0], east[2] - origin[2]))

    def timber(label, s, o, rise, size, tint, material):
        node = part(shelter, label, point(s, o, level + rise), size, tint,
                    yaw=heading, material=material, collide=False)
        if material in (cedar, limestone):
            prop(node, "string", variant_field, cedar_variant if material == cedar else stone_variant)

    for s, direction in ((25.78, 1), (31.86, -1)):
        for o in (21.06, 25.61):
            timber("Dark slate column base", s, o, .14, (.98, .28, .95), "77626C", slate)
            timber("Sandstone column collar", s, o, .31, (.79, .13, .77), "BE9B7D", limestone)
            timber("Ochre lacquer column", s, o, 2.76, (.55, 4.79, .55), "A85E40", cedar)
            timber("Copper ferrule", s, o, .53, (.63, .15, .62), "B87C47", brass)
            timber("Cedar capital", s, o, 5.02, (.78, .31, .73), "795343", cedar)
            timber("Copper capital edge", s, o, 5.13, (.84, .079, .80), "C4955C", brass)
            brace = beam(shelter, "Tapered cedar knee", point(s, o, level + 4.22),
                         point(s + direction * .84, o, level + 5.14), .27, "90583C")
            brace.find("Properties/token[@name='Material']").text = str(cedar)
            prop(brace, "string", variant_field, cedar_variant)

    for o in (21.06, 25.61):
        timber("Cedar eave tie", middle, o, 5.20, (6.91, .40, .48), "814B35", cedar)
        timber("Copper edge below the eave", middle, o, 5.37, (7.02, .085, .53), "BC9259", brass)
    for s in (25.78, 27.29, 28.82, 30.35, 31.86):
        timber("Exposed cedar rafter", s, center, 5.38, (.21, .23, 5.76), "8B644B", cedar)

    roof = item(shelter, "Model", "Swept indigo roof")
    swept_roof(roof, 0, level + 5.53, 0, 7.57, 5.71, 1.87,
               fine_tiles=False, corner_sweep=1.15)
    # The common tile builder uses an east-west ridge. Turn its parts as a unit.
    cy, sy = cos(radians(heading)), sin(radians(heading))
    for pose in roof.iter("CoordinateFrame"):
        x, y, z = (float(pose.find(axis).text) for axis in "XYZ")
        world = point(middle + x, center + z, y)
        for axis, value in zip("XYZ", world):
            pose.find(axis).text = f"{value:.7g}"
        for column in range(3):
            east_value, north_value = pose.find(f"R0{column}"), pose.find(f"R2{column}")
            vx, vz = float(east_value.text), float(north_value.text)
            east_value.text = f"{cy * vx + sy * vz:.7g}"
            north_value.text = f"{-sy * vx + cy * vz:.7g}"

    sign(shelter, "CLAY LANTERN", *point(middle, 20.84, level + 5.05),
         4.73, .72, heading + 180, "794737")
    for s in (26.34, 31.30):
        festival_lantern(shelter, *point(s, 20.87, level + 4.72), .49,
                         light=False, tint="FFD196")

    # Keep the seated side against one end bay, out of the coastal view.
    for o in (22.38, 24.18):
        timber("Bench slate foot", 31.60, o, .23, (.64, .46, .32), "81707A", slate)
    timber("Cedar side bench", 31.57, 23.28, .59, (.85, .19, 2.53), "A56E49", cedar)
    timber("Low cedar bench back", 31.93, 23.28, .99, (.16, .31, 2.48), "845338", cedar)

    timber("Low sample ledge", 25.88, 23.67, .25, (1.12, .48, 1.79), "967B70", slate)
    timber("Honed sample shelf", 25.88, 23.67, .49, (1.19, .16, 1.86), "C4A386", limestone)
    # gageyes00p's free Pottery_A_Empty, Creator Store model 18486934506.
    source_size = (3.939850, 3.073517, 3.939820)
    mesh_size = (32.939850, 28.073517, 32.939819)
    jar_size = tuple(extent * .67 / source_size[0] for extent in source_size)
    jar = part(shelter, "Dark clay sample jar", point(25.82, 23.23, level + .57 + jar_size[1] / 2),
               jar_size, "C8B4A9", yaw=heading - 27, collide=False, class_name="MeshPart")
    vector(jar, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
    prop(jar, "token", "RenderFidelity", 0)
    asset(jar, "MeshContent", "rbxassetid://18486837458")
    asset(jar, "TextureContent", "rbxassetid://18486837815")
    part(shelter, "Glazed clay sample", point(26.02, 24.02, level + .805),
         (.343, .469, .343), "67928B", shape=0, yaw=heading, material=limestone, collide=False)
    part(shelter, "Clay vessel rim", point(26.02, 24.02, level + 1.039),
         (.066, .218, .218), "BF9571", shape=2, roll=90, yaw=heading, material=limestone, collide=False)

    for key, s, o, scale, angle, tint in (
        ("meadowCover", 25.53, 24.78, .18, 31, "9BA661"),
        ("mossFlowers", 25.94, 24.65, .14, 62, "D79980"),
        ("grassBlade", 26.40, 24.62, .20, 116, "C5A86A"),
    ):
        garden_prop(shelter, key, point(s, o, level), scale, yaw + angle, tint)

    for node in shelter.iter("Item"):
        if node.get("class") in ("Part", "MeshPart", "WedgePart"):
            flag = node.find("Properties/bool[@name='CastShadow']")
            if flag is None:
                prop(node, "bool", "CastShadow", False)
            else:
                flag.text = "false"
