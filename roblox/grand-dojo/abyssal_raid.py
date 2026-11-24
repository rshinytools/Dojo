"""Original Abyssal Kraken rig and the Tideharbor storm basin."""

from math import atan2, cos, degrees, hypot, pi, sin


CENTER = (260, -116, 14)
GATE = (211.9, 3.027, 41.9)
ARM_WIDTHS = (3.16, 2.84, 2.46, 2.02, 1.56, 1.02)
ARM_RADII = (3.55, 5.72, 8.08, 10.37, 12.51, 14.26, 15.60)
ARM_HEIGHTS = (1.62, 1.35, 1.02, .64, .65, 1.02, 1.73)


def build_abyssal_raid(harbor, *, item, part, prop, sign, wood, slate, metal, neon, limestone, smooth,
                       color=None):
    brass, brass_light, stone = "97764F", "BD9A66", "47526A"
    sea, deep, teal, chalk = "3F8088", "202D44", "68AEB1", "ADD5D3"
    entry = item(harbor, "Model", "Abyssal Raid Entry")
    gx, gy, gz = GATE
    for side in (-1, 1):
        x = gx + side * 3.38
        part(entry, "Wharf slate footing", (x, gy + .29, gz), (.95, .58, .86), stone, material=slate, collide=False)
        part(entry, "Salt-blue wharf upright", (x, gy + 1.75, gz), (.42, 2.86, .50), sea,
             material=wood, collide=False)
        part(entry, "Pole brass collar", (x, gy + 2.73, gz), (.55, .23, .57), brass_light,
             material=metal, collide=False)
        part(entry, "Sea glass marker", (x, gy + 3.34, gz), (.48, .45, .48), chalk,
             material=neon, collide=False)
        part(entry, "Lantern brass cap", (x, gy + 3.62, gz), (.58, .12, .58), brass,
             material=metal, collide=False)
    sign(entry, "ABYSSAL RAID", gx, gy + 2.97, gz - .05, 6.42, 1.01, 180,
         tint="335F72", single_line=True, reverse_label="ABYSSAL RAID")
    sign(entry, "4 FIGHTERS  •  CO-OP", gx, gy + 1.88, gz - .15, 4.88, .52, 180,
         tint="375464", single_line=True)
    gate = part(entry, "Abyssal Raid Queue", (gx, gy + 1.72, gz - .69), (.2, .2, .2), chalk,
                collide=False, transparency=1)
    prompt = item(gate, "ProximityPrompt", "JoinAbyssalRaidPrompt")
    prop(prompt, "string", "ActionText", "Join or leave queue")
    prop(prompt, "string", "ObjectText", "Abyssal Raid")
    prop(prompt, "bool", "RequiresLineOfSight", False)
    prop(prompt, "float", "MaxActivationDistance", 8)
    prop(prompt, "float", "HoldDuration", .2)
    part(entry, "Raid Return", (gx, gy + 2.30, gz - 3.8), (.2, .2, .2), chalk,
         collide=False, transparency=1)

    court = item(harbor, "Model", "Abyssal Raid Court")
    prop(court, "token", "ModelStreamingMode", 1)
    cx, floor, cz = CENTER

    def piece(parent, name, pos, size, tint, *, material=smooth, collide=False, transparency=0, **pose):
        x, y, z = pos
        obj = part(parent, name, (cx + x, floor + y, cz + z), size, tint, material=material,
                   collide=collide, transparency=transparency, **pose)
        prop(obj, "bool", "CastShadow", False)
        return obj

    def marker(parent, name, pos, size=(.2, .2, .2), *, yaw=0, collide=False):
        return piece(parent, name, pos, size, chalk, yaw=yaw, collide=collide, transparency=1)

    def group(parent, name, pos, yaw=0):
        model = item(parent, "Model", name)
        pivot = marker(model, "Pose Hinge", pos, yaw=yaw)
        prop(model, "Ref", "PrimaryPart", pivot.get("referent"))
        return model

    marker(court, "Bounds", (0, 3.10, 0), (50, 13, 50))
    marker(court, "Floor Origin", (0, 0, 0))
    spawn = item(court, "Folder", "Spawn Marks")
    for index, (x, z, yaw) in enumerate(((-8.4, 13.8, -30), (-2.8, 16.4, -10), (2.8, 16.4, 10), (8.4, 13.8, 30)), 1):
        marker(spawn, f"Seat {index}", (x, 2.30, z), yaw=yaw)

    basin = item(court, "Model", "Tideharbor storm basin")
    piece(basin, "Basin floor collider", (0, -.45, 0), (53.0, .90, 53.0), "53627B",
          material=limestone, collide=True)
    for ix in range(8):
        for iz in range(8):
            perimeter = ix in (0, 7) or iz in (0, 7)
            palette = ("47596E", "526679", "4B6171") if perimeter else ("718798", "6A8295", "748D99", "647E91")
            piece(basin, "Water-worn flagstone", ((ix - 3.5)*6.51, .014, (iz - 3.5)*6.51),
                  (6.45, .028, 6.45), palette[(ix*3 + iz) % len(palette)], material=limestone)
    piece(basin, "Central tide seal", (0, .04, 0), (.036, 13.63, 13.63), "557C8A", material=limestone, shape=2, roll=90)
    for index in range(12):
        angle = index * pi / 6
        piece(basin, "Inlaid copper tide tick", (6.55*sin(angle), .059, 6.55*cos(angle)),
              (.11, .023, .44 if index % 3 else .63), "668689", material=metal, yaw=index*30)

    # The room tapers towards the ceiling. Thin front ribs and deep inset panes
    # give the floor a visible edge on a low combat camera without extra lights.
    for quadrant in range(4):
        yaw = quadrant * 90
        angle = quadrant * pi / 2
        sn, cs = sin(angle), cos(angle)

        def wall(name, across, y, radius, size, tint, material=slate, **pose):
            return piece(basin, name, (across*cs + radius*sn, y, -across*sn + radius*cs),
                         size, tint, material=material, yaw=yaw, **pose)

        wall("Basin exterior stone mass", 0, 8.55, 27.28, (57.0, 17.5, 2.4), deep, collide=True)
        wall("Sunken harbor foundation", 0, 1.12, 26.01, (52.2, 2.25, 1.26), stone)
        wall("Inlaid sea-green sill", 0, 2.29, 25.77, (52.2, .22, 1.01), "497E87", metal)
        wall("Upper aged brass molding", 0, 12.64, 25.97, (52.2, .19, .54), brass, metal)
        wall("Basin cornice", 0, 14.43, 25.72, (52.2, 1.34, 1.22), "3E526B")
        wall("Upper basin shoulder", 0, 16.13, 24.87, (53.0, 1.36, 3.48), "344760", pitch=14)
        for post in (-22.25, -9.25, 9.25, 22.25):
            wall("Engaged indigo pier", post, 7.05, 25.66, (1.17, 10.20, .85), "485A73")
            wall("Indigo pier plinth", post, 2.86, 25.45, (1.84, .78, 1.22), "515F74")
            wall("Indigo pier capital", post, 12.11, 25.55, (1.68, .35, 1.20), "61788A")
        for bay in (-15.75, 0, 15.75):
            window_width = 8.74 if bay else 13.84
            wall("Tideglass bronze frame", bay, 7.50, 25.99, (window_width+.68, 7.74, .52), "507780", metal)
            wall("Tideglass blue depths", bay, 7.50, 25.70, (window_width, 7.17, .13), "254A64", smooth)
            for strip in range(3):
                wall("Waterlight through tideglass", bay, 9.86-strip*1.85, 25.60-strip*.007,
                     (window_width-.17, 1.51, .06), ("578C9E", "356C87", "2A5676")[strip], smooth)
            for mullion in (-1, 0, 1):
                wall("Salt-worn window bars", bay + mullion*window_width*.31, 7.51, 25.48,
                     (.13, 7.15, .25), "386477", metal)
            for offset, lift, diameter in ((-.28, 6.0, .19), (-.12, 7.9, .29), (.20, 9.18, .22)):
                wall("Tideglass light glint", bay+offset*window_width, lift, 25.45,
                     (diameter, diameter, .055), "5E9AA7", smooth, shape=0)
        for side in (-1, 1):
            x = side * 5.50
            wall("Wharf pennant brass hook", x, 12.15, 25.08, (2.28, .12, .54), brass_light, metal)
            wall("Wharf pennant midnight cloth", x, 10.73, 25.00, (1.49, 2.73, .12), "283547", smooth)
            wall("Wharf pennant color field", x, 10.74, 24.91, (1.28, 2.53, .072), "24616B", smooth)
            wall("Wharf pennant stripe", x, 10.0, 24.855, (1.11, .13, .033), "C2985F", metal)
            wall("Wharf pennant knot", x, 11.23, 24.85, (.69, .69, .039), "A0B7A7", smooth, roll=45)

    piece(basin, "Basin roof collider", (0, 18.38, 0), (57, 2.45, 57), "30435A", material=slate, collide=True)
    for offset in (-18, -9, 0, 9, 18):
        piece(basin, "Basin truss", (offset, 16.74, 0), (.67, .78, 51.7), "3E5268", material=metal)
        piece(basin, "Basin truss cross member", (0, 16.34, offset), (51.7, .58, .61), "40546C", material=metal)
    for x, z in ((-15, -13), (15, -13), (-15, 13), (15, 13)):
        piece(basin, "Basin lantern rope", (x, 15.15, z), (.13, 2.43, .13), "475A67", material=metal)
        piece(basin, "Basin lantern brass cap", (x, 13.94, z), (1.62, .22, 1.62), brass_light, material=metal)
        piece(basin, "Basin lantern brass lower ring", (x, 12.83, z), (1.69, .20, 1.69), brass, material=metal)
        lens = piece(basin, "Basin tideglass lantern", (x, 13.40, z), (1.40, .96, 1.40), "ABD9D3", material=neon)
        for dx in (-.71, .71):
            for dz in (-.71, .71):
                piece(basin, "Basin lantern cage", (x+dx, 13.38, z+dz), (.13, 1.13, .13), "567777", material=metal)
        light = item(lens, "PointLight", "Shadow-free basin light")
        prop(light, "float", "Brightness", 1.32 if z > 0 else 1.14)
        prop(light, "float", "Range", 36)
        prop(light, "bool", "Shadows", False)
        if color is not None:
            color(light, "Color", "E1F0EC" if z > 0 else "B9E8FA")
    sign(basin, "TIDEHARBOR STORM BASIN", cx, floor + 13.09, cz - 25.2, 13.1, 1.09,
         tint="355568", single_line=True)

    boss = item(court, "Model", "Abyssal Kraken")
    marker(boss, "Origin", (0, 0, 0), yaw=180)
    marker(boss, "Shell Hit", (0, 2.50, 0), (10.0, 5.0, 10.0), yaw=180)
    marker(boss, "Core Hit", (0, 2.54, 5.22), (2.9, 2.65, 1.95), yaw=180)
    marker(boss, "Shell Collider", (0, 1.80, 0), (8.4, 3.6, 8.4), yaw=180, collide=True)
    item(court, "Folder", "Raid Tells")

    body = group(boss, "Animated Body", (0, 3.75, 0))
    piece(body, "Abyssal collar", (0, 1.47, 0), (1.78, 9.29, 9.29), "49364F", roll=90, shape=2)
    piece(body, "Mantle silhouette", (0, 4.13, -.64), (8.28, 8.28, 8.28), "54446D", shape=0)
    piece(body, "Crown shell", (0, 6.17, -1.07), (5.98, 1.97, 5.60), "735E8A",
          pitch=21, class_name="WedgePart")
    piece(body, "Crown ridge", (0, 7.64, -1.48), (1.90, 1.35, 5.31), "887397",
          pitch=19, class_name="WedgePart")
    piece(body, "Face shield", (0, 4.79, 3.09), (6.79, 3.28, 2.66), "635179", pitch=-10,
          class_name="WedgePart")
    piece(body, "Sculpted beak guard", (0, 1.62, 4.26), (4.34, 1.06, 1.19), "44334F", pitch=-12)
    piece(body, "Mantle collar", (0, 2.57, 4.87), (.68, 2.78, 2.78), "966753", yaw=90, shape=2, material=metal)
    piece(body, "Dark mantle cavity", (0, 2.61, 5.18), (.35, 2.43, 2.43), "291F38", yaw=90, shape=2)
    piece(body, "Mantle Pearl", (0, 2.57, 5.28), (.38, 2.16, 2.16), "4C707F", yaw=90, shape=2)
    piece(body, "Pearl Heart", (0, 2.63, 5.50), (.10, 1.18, 1.18), "628E94", yaw=90, shape=2, material=neon)
    piece(body, "Pearl cut", (0, 2.64, 5.58), (.23, 1.44, .067), "9BDECB", roll=45, material=neon)
    for side, name in ((-1, "Left"), (1, "Right")):
        piece(body, f"{name} mantle fin", (side*4.18, 4.70, -.72), (2.23, 3.42, 4.35), "57436C",
              roll=side*53, yaw=side*28, class_name="WedgePart")
        piece(body, f"{name} fin edge", (side*4.59, 4.53, .16), (.53, 3.21, 3.26), "956F97",
              roll=side*53, yaw=side*28, class_name="WedgePart")
        piece(body, f"{name} cheek shield", (side*3.50, 3.77, 3.18), (2.17, 1.39, 1.47), "4A3E61",
              pitch=-18, yaw=side*38, roll=side*19, class_name="WedgePart")
        piece(body, f"{name} eye socket", (side*2.32, 5.00, 4.21), (2.53, 1.55, .68), "38293F",
              yaw=side*20, roll=side*24)
        piece(body, f"{name} eye", (side*2.29, 4.98, 4.58), (1.80, .79, .22), "EDC695",
              roll=side*21, yaw=side*20)
        piece(body, f"{name} iris", (side*2.13, 4.89, 4.75), (.62, .82, .14), "A05B63",
              roll=side*19, yaw=side*20)
        piece(body, f"{name} pupil", (side*2.12, 4.91, 4.85), (.22, .62, .08), "231D36",
              roll=side*20, yaw=side*20)
        piece(body, f"{name} eye glint", (side*2.24, 5.04, 4.87), (.152, .15, .044), "FFF1CC", roll=45)
        piece(body, f"{name} lower eyelid", (side*2.32, 4.53, 4.66), (2.17, .22, .32), "47354F",
              yaw=side*20, roll=side*20)
        piece(body, f"{name} raised brow plate", (side*2.30, 5.58, 4.47), (2.97, .87, .77), "483353",
              yaw=side*20, roll=side*26, class_name="WedgePart")
        piece(body, f"{name} brow edge", (side*2.31, 5.35, 4.80), (2.25, .25, .31), "936986",
              yaw=side*20, roll=side*26)
        for dx, y, z, radius in ((1.47, 7.31, 1.90, .47), (2.13, 6.80, 2.14, .38), (2.83, 6.36, 2.30, .25),
                                   (3.65, 4.16, 3.50, .34), (3.91, 3.84, 3.13, .25)):
            piece(body, "Coral enamel facet", (side*dx, y, z), (radius, radius*.67, .10), "B68289", roll=45)
        plate = group(body, f"Mantle Plate {name}", (side*.91, 2.66, 5.30))
        piece(plate, "Mantle guard", (side*.80, 2.62, 5.53), (1.67, 2.09, .40), "463653", roll=side*12)
        piece(plate, "Mantle shell bevel", (side*.84, 2.82, 5.74), (1.53, 1.79, .41), "725777",
              roll=side*12, pitch=-18, class_name="WedgePart")
        piece(plate, "Mantle plate blade inlay", (side*.94, 2.68, 5.77), (.17, 1.62, .23), "AC7C68", roll=side*23)
        piece(plate, "Mantle guard brass hinge", (side*1.51, 2.58, 5.49), (.28, .69, .69), "936753", shape=2, yaw=90,
              material=metal)

    # The Visuals module poses these nested parts along six tapered links.
    tentacles = item(boss, "Folder", "Tentacles")
    for arm_index in range(4):
        yaw = 90 * arm_index
        sn, cs = sin(arm_index*pi/2), cos(arm_index*pi/2)
        arm = item(tentacles, "Model", f"Tentacle {arm_index+1}")
        for segment_index, width in enumerate(ARM_WIDTHS):
            first, last = segment_index, segment_index+1
            r = (ARM_RADII[first] + ARM_RADII[last]) / 2
            y = (ARM_HEIGHTS[first] + ARM_HEIGHTS[last]) / 2
            length = hypot(ARM_RADII[last]-ARM_RADII[first], ARM_HEIGHTS[last]-ARM_HEIGHTS[first])
            roll = degrees(atan2(ARM_HEIGHTS[last]-ARM_HEIGHTS[first], ARM_RADII[last]-ARM_RADII[first]))
            segment = item(arm, "Model", f"Link {last}")
            tint = ("5F4670", "674C76", "6F527D", "795987", "87608D", "946893")[first]
            main = piece(segment, "Arm", (r*sn, y, r*cs), (length + width*.47, width, width), tint,
                         shape=2, yaw=yaw-90, roll=roll)
            prop(segment, "Ref", "PrimaryPart", main.get("referent"))
            r0, y0 = ARM_RADII[first], ARM_HEIGHTS[first]
            piece(segment, "Arm joint", (r0*sn, y0, r0*cs), (width*1.018,)*3, tint, shape=0)
            piece(segment, "Dorsal seam", (r*sn, y+width*.43, r*cs), (length*.87, width*.18, width*.18), "946E90",
                  shape=2, yaw=yaw-90, roll=roll)
            for index, side in enumerate((-1, 1), 1):
                px, pz = r*sn+side*cs*width*.39, r*cs-side*sn*width*.39
                piece(segment, f"Sucker rim {index}", (px, y-width*.28, pz), (.16, width*.35, width*.35), "C799A6",
                      shape=2, roll=-side*34, yaw=yaw)
                piece(segment, f"Sucker inset {index}", (px+side*.097*cs, y-width*.30, pz-side*.097*sn),
                      (.055, width*.20, width*.20), "805373", shape=2, roll=-side*34, yaw=yaw)
            if last == len(ARM_WIDTHS):
                r1, y1 = ARM_RADII[last], ARM_HEIGHTS[last]
                piece(segment, "Hooked tip", (r1*sn, y1, r1*cs), (width*.96, width*.60, width*.62), "B27A9F",
                      yaw=yaw-90, roll=roll-37, class_name="WedgePart")
    return court
