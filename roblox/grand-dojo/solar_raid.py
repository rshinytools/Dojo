"""Original Solar Phoenix and Lantern Circuit sun observatory assets."""

from math import atan2, cos, degrees, hypot, pi, sin


CENTER = (-248, -104, 28)
GATE = (-235, 6.027, 47)
PERCH = (4.65, .80, 4.10)


def build_solar_raid(lantern, *, item, part, prop, sign, triangle, wood, slate, metal, neon, limestone, smooth,
                     color=None):
    brass, light_brass, ink = "B27B47", "E2B875", "3C394B"
    teal, night, cream = "3F797A", "294456", "FFDD9A"
    entry = item(lantern, "Model", "Solar Raid Entry")
    gx, gy, gz = GATE
    for side in (-1, 1):
        x = gx + side * 3.42
        part(entry, "Dark observatory footing", (x, gy + .18, gz), (.83, .36, .91), ink,
             material=slate, collide=False)
        part(entry, "Lacquered observatory upright", (x, gy + 1.68, gz), (.37, 2.81, .44), teal,
             material=wood, collide=False)
        part(entry, "Brass sunrise collar", (x, gy + 2.78, gz), (.65, .25, .61), light_brass,
             material=metal, collide=False)
        part(entry, "Sunrise pane", (x, gy + 3.28, gz), (.53, .63, .43), cream,
             material=neon, collide=False)
        part(entry, "Lantern copper cap", (x, gy + 3.65, gz), (.66, .11, .56), brass,
             material=metal, collide=False)
    sign(entry, "SOLAR RAID", gx, gy + 2.95, gz - .05, 6.36, 1.02, 180,
         tint="275362", single_line=True, reverse_label="SOLAR RAID")
    sign(entry, "4 FIGHTERS  •  CO-OP", gx, gy + 1.85, gz - .15, 4.90, .48, 180,
         tint="643B53", single_line=True)
    gate = part(entry, "Solar Raid Queue", (gx, gy + 1.72, gz - .69), (.2, .2, .2), cream,
                collide=False, transparency=1)
    prompt = item(gate, "ProximityPrompt", "JoinSolarRaidPrompt")
    prop(prompt, "string", "ActionText", "Join or leave queue")
    prop(prompt, "string", "ObjectText", "Solar Raid")
    prop(prompt, "bool", "RequiresLineOfSight", False)
    prop(prompt, "float", "MaxActivationDistance", 8)
    prop(prompt, "float", "HoldDuration", .2)
    part(entry, "Raid Return", (gx, gy + 2.30, gz - 3.8), (.2, .2, .2), cream,
         collide=False, transparency=1)

    court = item(lantern, "Model", "Solar Raid Court")
    prop(court, "token", "ModelStreamingMode", 1)
    cx, floor, cz = CENTER

    def piece(parent, name, pos, size, tint, *, material=smooth, collide=False, transparency=0, **pose):
        x, y, z = pos
        obj = part(parent, name, (cx + x, floor + y, cz + z), size, tint, material=material,
                   collide=collide, transparency=transparency, **pose)
        prop(obj, "bool", "CastShadow", False)
        return obj

    def marker(parent, name, pos, size=(.2, .2, .2), **kwargs):
        return piece(parent, name, pos, size, cream, transparency=1, **kwargs)

    def group(parent, name, pos):
        model = item(parent, "Model", name)
        pivot = marker(model, "Pose Hinge", pos)
        prop(model, "Ref", "PrimaryPart", pivot.get("referent"))
        return model

    marker(court, "Bounds", (0, 3.10, 0), (50, 13, 50))
    marker(court, "Floor Origin", (0, 0, 0))
    spawn = item(court, "Folder", "Spawn Marks")
    for index, (x, z, yaw) in enumerate(((-8.4, 14.6, -29), (-2.8, 16.8, -10),
                                         (2.8, 16.8, 10), (8.4, 14.6, 29)), 1):
        marker(spawn, f"Seat {index}", (x, 2.30, z), yaw=yaw)

    roof = item(court, "Model", "Dawn Observatory")
    piece(roof, "Observatory floor collider", (0, -.55, 0), (54, 1.10, 54), ink,
          material=limestone, collide=True)
    floor_colors = ("8C797F", "968786", "897F8E", "97838C")
    border_colors = ("49576A", "506073", "465366")
    for x in range(8):
        for z in range(8):
            edge = min(x, z, 7 - x, 7 - z) == 0
            colors = border_colors if edge else floor_colors
            piece(roof, "Cut dawn flagstone", ((x - 3.5)*6.49, .016, (z - 3.5)*6.49),
                  (6.42, .032, 6.42), colors[(x * 3 + z) % len(colors)], material=limestone)
    for y, size, tint in ((.037, 18.75, "625A70"), (.057, 17.82, "AD8A72"),
                          (.075, 17.12, "766B7B"), (.095, 13.1, "837883")):
        piece(roof, "Inlaid solar dial", (0, y, 0), (.020, size, size), tint, material=limestone,
              roll=90, shape=2)
    for index in range(24):
        angle = index*pi/12
        length = .98 if index % 3 == 0 else .58
        piece(roof, "Bronze time mark", (sin(angle)*7.72, .118, cos(angle)*7.72),
              (.14, .02, length), brass, material=metal, yaw=index*15)
        if index % 3 == 0:
            piece(roof, "Sun dial jewel", (sin(angle)*6.45, .12, cos(angle)*6.45),
                  (.34, .021, .34), "C5A380", material=metal, yaw=index*15+45)
    for side in (-1, 1):
        piece(roof, "Side parapet collider", (side*26.23, 1.16, 0), (1.10, 2.32, 53.4), "485568",
              material=slate, collide=True)
        piece(roof, "Front parapet collider", (0, 1.16, side*26.23), (53.4, 2.32, 1.10), "485568",
              material=slate, collide=True)
        marker(roof, "Side leap boundary", (side*26.39, 5.89, 0), (.27, 11.7, 53.8), collide=True)
        marker(roof, "End leap boundary", (0, 5.89, side*26.39), (53.8, 11.7, .27), collide=True)
        piece(roof, "Parapet bronze nose", (side*25.75, 2.41, 0), (.70, .22, 53.3), light_brass,
              material=metal)
        piece(roof, "Parapet bronze nose", (0, 2.41, side*25.75), (53.3, .22, .70), light_brass,
              material=metal)
        for x in (-18.6, -6.2, 6.2, 18.6):
            for px, pz, yaw in ((x, side*25.68, 0), (side*25.68, x, 90)):
                piece(roof, "Parapet teal inset", (px, 1.41, pz),
                      (8.65, 1.10, .20), teal, material=slate, yaw=yaw)
                piece(roof, "Parapet brass trim", (px, 1.41, pz),
                      (5.87, .075, .21), "C39974", material=metal, yaw=yaw)
    for x in (-23.7, 23.7):
        for z in (-23.7, 23.7):
            piece(roof, "Corner sun pillar footing", (x, .21, z), (2.27, .42, 2.27), night,
                  material=slate)
            piece(roof, "Corner sun pillar", (x, 2.22, z), (1.15, 4.17, 1.15), teal,
                  material=wood)
            piece(roof, "Corner sun pillar brass base", (x, .66, z), (1.48, .22, 1.48), brass,
                  material=metal)
            piece(roof, "Corner sun pillar brass cap", (x, 4.13, z), (1.53, .25, 1.52), light_brass,
                  material=metal)
            lamp = piece(roof, "Honey glass observatory lamp", (x, 4.78, z), (1.30, 1.04, 1.27), "F3C788",
                         material=neon)
            light = item(lamp, "PointLight", "Warm roof lamp")
            prop(light, "float", "Brightness", 1.7)
            prop(light, "float", "Range", 35)
            prop(light, "bool", "Shadows", False)
            if color is not None:
                color(light, "Color", "FFEAC7")
            piece(roof, "Copper observatory lantern roof", (x, 5.34, z), (1.64, .26, 1.62), brass,
                  material=metal)
            for dx in (-.68, .68):
                for dz in (-.68, .68):
                    piece(roof, "Lantern post filigree", (x + dx, 4.74, z + dz), (.07, 1.07, .07),
                          ink, material=metal)

    backdrop = item(roof, "Model", "Painted dawn panorama")
    # A painted low skyline wraps every camera angle of this isolated rooftop.
    # The opaque muted plane reaches the horizon so no patch of sky reads as a hole.
    piece(backdrop, "Muted horizon ground", (0, -2.12, 0), (136, .26, 136), "68576D",
          material=smooth)

    def panorama(side, offset, y, distance):
        x, z = ((offset, -distance), (distance, offset), (-offset, distance), (-distance, -offset))[side]
        return cx + x, floor + y, cz + z

    sky = (
        "907287", "9C768A", "A67B8F", "AF8194", "B88698", "C18C9E", "CA92A3",
        "D098A8", "D69EAE", "D5A0B3", "D1A1B7", "CBA1B9", "C4A0B9", "BC9EB6",
        "B39AB2", "AA95AC", "A091A7", "958CA2", "8B859C", "837E97", "7A7691",
    )
    layers = (
        (57.6, 13.1, ("AA8BA6", "AC8CA2", "A78CA7"), 7, 20.9),
        (47.2, 9.7, ("8B778E", "927C92", "86758E"), 8, 18.7),
        (38.4, 5.8, ("6C667E", "766982", "70647C"), 8, 17.9),
    )
    for side in range(4):
        yaw = 0 if side % 2 == 0 else 90
        for index, tint in enumerate(sky):
            point = panorama(side, 0, 1.12 + index*2.65, 66)
            piece(backdrop, "Painted dawn sky", (point[0]-cx, point[1]-floor, point[2]-cz),
                  (132.4, 2.665, .16), tint, material=smooth, yaw=yaw)
        point = panorama(side, 0, 74.46, 66)
        piece(backdrop, "Upper dawn sky", (point[0]-cx, point[1]-floor, point[2]-cz),
              (132.4, 38.02, .16), sky[-1], material=smooth, yaw=yaw)
        point = panorama(side, 0, -8.9, 66)
        piece(backdrop, "Dawn haze under the skyline", (point[0]-cx, point[1]-floor, point[2]-cz),
              (132.4, 17.45, .19), "8E7187", material=smooth, yaw=yaw)
        for layer, (distance, height, colors, count, spacing) in enumerate(layers):
            for j in range(count):
                center = (j - (count-1)/2)*spacing + (layer - 1)*4.4
                spread = spacing * (1.06 + (j % 3)*.095)
                crest = height + ((j*23 + side*9 + layer*13) % 41)*.127
                crest_x = center + ((j*19 + side*7) % 23 - 11)*.42
                depth = distance - (j % 3)*.31
                foot_l = panorama(side, center-spread, -2.11, depth)
                foot_r = panorama(side, center+spread, -2.11, depth)
                peak = panorama(side, crest_x, crest, depth)
                tint = colors[(j + side) % len(colors)]
                triangle(backdrop, foot_l, foot_r, peak, tint, name="Layered dawn ridge",
                         thickness=.12, material=smooth, shadow=False)
                if j % 2 == 0:
                    slope_peak = panorama(side, crest_x, crest*.97, depth-.13)
                    slope_base = panorama(side, crest_x + spread*.18, -2.10, depth-.13)
                    slope_right = panorama(side, center+spread*.94, -2.10, depth-.13)
                    triangle(backdrop, slope_base, slope_right, slope_peak, colors[(j + side + 1) % len(colors)],
                             name="Painted ridge face", thickness=.095, material=smooth, shadow=False)
    for z, size, tint in ((-59.9, 13.65, "D5A798"), (-59.7, 11.55, "EDB991"), (-59.51, 10.35, "F1CA9B")):
        piece(backdrop, "Painted rising sun", (8.1, 23.8, z), (.1, size, size), tint,
              material=neon if size == 10.35 else smooth, yaw=90, shape=2)
    for x, y, width, tint in ((-35, 22.1, 22, "D6A6B2"), (-30, 21.77, 17, "D2A2AE"),
                               (30, 28.06, 26, "CDAAC0"), (39, 27.67, 20, "C8A7BE"),
                               (-4, 32.22, 27, "BFA5BF"), (5, 31.91, 23, "BFA4BC"),
                               (49, 19.41, 13, "D7A5B2")):
        piece(backdrop, "Soft dawn cloud ribbon", (x, y, -62.1), (width, .29, .085), tint,
              material=smooth)

    # The main rear arch marks the observatory and frames the boarding side.
    for side in (-1, 1):
        x = side*13.4
        piece(roof, "Observatory slate pedestal", (x, .43, -22.22), (2.5, .86, 2.45), night,
              material=slate)
        piece(roof, "Tall observatory pillar", (x, 5.75, -22.22), (1.38, 10.77, 1.40), night,
              material=wood)
        piece(roof, "Carved teal pillar front", (x, 5.77, -21.47), (.62, 10.22, .13), teal,
              material=wood)
        for y in (.90, 10.96):
            piece(roof, "Pillar copper band", (x, y, -22.22), (1.70, .27, 1.67), brass, material=metal)
        piece(roof, "Copper observatory cross support", (side*11.5, 9.85, -22.25),
              (.33, 4.20, .41), brass, roll=-side*42, material=metal)
        for j in range(6):
            x = side * (1.1 + 2.16*j)
            y = 13.2 - (j - 2)*.11
            piece(roof, "Fan roof tile", (x, y, -22.31), (2.49, .26, 3.27), "394B65",
                  material=slate, pitch=-7 + j*.95, roll=-side*(j - 1)*2.9)
    piece(roof, "Dark observatory lintel", (0, 11.27, -22.25), (28.25, .83, 1.18),
          night, material=wood)
    piece(roof, "Center roof brass rim", (0, 12.89, -20.68), (28.6, .19, .21), brass,
          material=metal)
    sign(roof, "DAWN OBSERVATORY", cx, floor + 11.27, cz - 21.53, 10.80, 1.08, 0,
         tint="513D54", single_line=True)

    boss = item(court, "Model", "Solar Phoenix")
    marker(boss, "Origin", (0, 0, 0))
    marker(boss, "Shell Hit", (0, 3.17, .24), (5.10, 5.35, 4.95))
    marker(boss, "Core Hit", (0, 2.58, 2.88), (2.70, 2.75, 1.25))
    marker(boss, "Shell Collider", (0, .40, 0), PERCH, collide=True)
    item(court, "Folder", "Raid Tells")
    for y, size, tint in ((.36, (4.67, .70, 4.12), night), (.72, (4.77, .20, 4.22), brass),
                          (.85, (4.52, .08, 3.97), "675772")):
        piece(roof, "Visible sun perch", (0, y, 0), size, tint, material=slate)
    for side in (-1, 1):
        piece(roof, "Perch brass sunrise engraving", (side*.51, .49, 2.077),
              (.15, .35, .04), light_brass, material=metal, roll=-side*36)
    piece(roof, "Perch sunrise bead", (0, .57, 2.09), (.28, .24, .055), cream, material=metal, roll=45)

    rig = group(boss, "Animated Body", (0, 3.64, .12))
    deep_red, red, rust, gold = "6E334F", "AC4F55", "CE6F59", "EFA45B"
    pale, mask, shade = "FFD488", "F4BC6F", "5B3447"
    piece(rig, "Pierced chest keel", (0, 2.89, .53), (4.22, 3.94, 4.19), red, pitch=-12)
    piece(rig, "Back and neck line", (0, 4.35, -.29), (3.60, 2.78, 3.69), deep_red,
          pitch=20, class_name="WedgePart")
    piece(rig, "Keel underside", (0, 2.02, .35), (3.82, 2.24, 3.80), deep_red,
          pitch=-23, class_name="WedgePart")
    piece(rig, "Heart dais edging", (0, 2.57, 2.58), (.28, 2.60, 2.60), shade, yaw=90, shape=2)
    piece(rig, "Sunheart Rim", (0, 2.58, 2.79), (.26, 2.24, 2.24), "B87B55",
          yaw=90, shape=2, material=metal)
    piece(rig, "Sunheart", (0, 2.59, 2.94), (.15, 1.81, 1.81), "CD7C56",
          yaw=90, shape=2, material=neon)
    piece(rig, "Sunheart Spark", (0, 2.58, 3.04), (.81, .81, .13), "DB8551",
          roll=45, material=neon)
    vane = group(rig, "Tail Fan", (0, 2.74, -1.31))
    crest = group(rig, "Crown Fan", (0, 6.80, .67))

    def feather(parent, start, end, width, thickness, tint, tip, *, ridge=True):
        dx, dy, dz = (end[i] - start[i] for i in range(3))
        span = hypot(hypot(dx, dy), dz)
        yaw = degrees(atan2(dx, dz))
        pitch = degrees(atan2(-dy, hypot(dx, dz)))
        def center(f, up=0):
            return tuple(start[i]+(end[i]-start[i])*f+(up if i == 1 else 0) for i in range(3))
        piece(parent, "Layered feather", center(.36), (width, thickness, span*.77), tint, yaw=yaw, pitch=pitch)
        piece(parent, "Tapered feather point", center(.83), (width, thickness, span*.36), tip,
              yaw=yaw, pitch=pitch, class_name="WedgePart")
        if ridge:
            piece(parent, "Raised feather quill", center(.41, thickness*.5), (.117, .095, span*.64), pale,
                  yaw=yaw, pitch=pitch)

    for j in range(-3, 4):
        scale = abs(j)
        feather(vane, (j*.28, 2.72, -1.49), (j*1.43, 2.48 + scale*.25, -10.15+scale*.64),
                1.49 - .12*scale, .23, (gold, rust, red, deep_red)[scale],
                (rust, red, deep_red, shade)[scale])
    for j in range(-2, 3):
        scale = abs(j)
        feather(crest, (j*.30, 6.67, .79), (j*.70, 8.22-scale*.29, -1.42+scale*.32),
                .60, .20, gold if scale == 0 else rust, red, ridge=False)
    piece(rig, "Angular feathered neck", (0, 4.97, .92), (2.48, 3.51, 2.62), rust, pitch=-15)
    piece(rig, "Sun mask skull", (0, 6.24, 1.43), (3.03, 1.99, 2.45), red, pitch=-11)
    piece(rig, "Sun mask forehead", (0, 6.66, 2.19), (2.94, 1.16, 1.26), rust, pitch=-11,
          class_name="WedgePart")
    piece(rig, "Hooked gold beak top", (0, 5.44, 2.94), (1.36, .83, 2.38), mask, pitch=-19,
          class_name="WedgePart")
    piece(rig, "Hooked gold beak point", (0, 5.08, 3.91), (.77, .82, .70), gold,
          pitch=30, class_name="WedgePart")
    piece(rig, "Dark beak seam", (0, 5.03, 3.06), (.95, .11, 1.47), shade, pitch=-16)
    piece(rig, "Lower beak", (0, 4.96, 2.88), (1.06, .34, 1.52), rust,
          pitch=-9, class_name="WedgePart")

    for side, name in ((-1, "Left"), (1, "Right")):
        piece(rig, f"{name} cheek mask", (side*1.23, 5.72, 2.03), (1.55, 1.28, 1.43), mask,
              yaw=side*41, roll=side*23, class_name="WedgePart")
        piece(rig, f"{name} eye backing", (side*1.23, 6.07, 2.45), (1.40, .68, .34), shade,
              yaw=side*37, roll=side*24)
        piece(rig, f"{name} eye", (side*1.31, 6.04, 2.59), (1.07, .44, .15), "FCE2A0",
              yaw=side*37, roll=side*24)
        piece(rig, f"{name} iris", (side*1.28, 6.02, 2.65), (.30, .42, .07), "A95764",
              yaw=side*37, roll=side*24)
        piece(rig, f"{name} pupil", (side*1.245, 6.00, 2.70), (.11, .31, .044), "382A3C",
              yaw=side*37, roll=side*24)
        piece(rig, f"{name} sculpted brow", (side*1.34, 6.38, 2.54), (1.55, .37, .41), shade,
              yaw=side*36, roll=side*26)
        for j in range(3):
            piece(rig, "Gilded bird collar facet", (side*(1.55-j*.14), 4.40-j*.30, 1.97+j*.10),
                  (.58, .20, .12), gold, yaw=side*39, roll=side*24)
        plate = group(rig, f"{name} Heart Plate", (side*.94, 2.60, 3.05))
        piece(plate, "Overlapping heart armor", (side*.64, 2.59, 3.12), (1.55, 2.26, .29), deep_red,
              roll=side*15)
        piece(plate, "Embossed heart plume", (side*.60, 2.72, 3.31), (1.33, 1.98, .22), rust,
              roll=side*15, class_name="WedgePart")
        piece(plate, "Gold armor feather tip", (side*.50, 2.51, 3.48), (.16, 1.42, .11), gold,
              roll=side*22)
        foot = group(rig, f"{name} Talon", (side*1.24, 1.92, .37))
        piece(foot, "Feathered thigh", (side*1.23, 1.97, .27), (1.27, 1.09, 1.54), deep_red,
              pitch=-12)
        piece(foot, "Gold shin", (side*1.20, 1.28, .49), (.43, 1.19, .60), gold, pitch=-15)
        for toe in (-1, 0, 1):
            x = side*1.20 + toe*.29
            piece(foot, "Jointed talon", (x, .99, .98), (.27, .25, .82 - abs(toe)*.09), mask,
                  yaw=toe*14)
            piece(foot, "Hooked claw tip", (x + toe*.10, .93, 1.41), (.22, .18, .42), shade,
                  yaw=toe*15, class_name="WedgePart")
        shoulder = group(rig, f"{name} Wing", (side*1.62, 4.12, -.11))
        piece(shoulder, "Phoenix shoulder armor", (side*2.69, 4.11, -.28), (3.22, 1.22, 3.47), red,
              yaw=side*18)
        piece(shoulder, "Copper wing coverts", (side*4.25, 4.11, -.81), (3.48, .61, 4.40), rust,
              yaw=side*20, class_name="WedgePart")
        piece(shoulder, "Ivory hinge trim", (side*2.55, 4.68, .19), (2.65, .14, .44), gold,
              yaw=side*20)
        for j in range(6):
            start = (side*(2.07+j*.64), 4.06-j*.037, .34-j*.19)
            end = (side*(3.04+j*.86), 3.86-j*.047, -4.39-j*.29)
            feather(shoulder, start, end, 1.07+j*.055, .23, rust if j % 2 else red, deep_red)
        outer = group(shoulder, "Outer Wing", (side*5.65, 4.04, -1.04))
        piece(outer, "Wing wrist gold band", (side*6.20, 4.06, -1.36), (1.90, .80, 2.41), gold,
              yaw=side*18)
        for j in range(8):
            start = (side*(5.45+j*.42), 4.10-j*.038, -.54-j*.20)
            end = (side*(13.21-j*.67), 4.16-j*.10, -4.72-j*.57)
            tint, tip = ((gold, rust), (gold, rust), (mask, rust), (rust, red),
                         (rust, red), (red, deep_red), (red, deep_red), (deep_red, shade))[j]
            feather(outer, start, end, .99+j*.06, .24, tint, tip)
    return court
