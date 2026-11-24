"""Original Kilnback raid entrance, kiln chamber, and low ceramic automaton."""

from math import cos, pi, sin


CENTER = (150, -100, -199)
GATE = (144, 10.027, -169.8)


def build_kilnback_raid(cinder, *, item, part, prop, sign, wood, slate, metal, neon, limestone, smooth,
                        color=None):
    brick, dark, brass, gold = "925550", "513638", "B48047", "E8B665"
    entry = item(cinder, "Model", "Kilnback Raid Entry")
    gx, gy, gz = GATE
    for x in (-3.27, 3.27):
        part(entry, "Glazed kiln sign foot", (gx + x, gy + .27, gz), (.75, .54, .77), "86685B",
             material=slate, collide=False)
        part(entry, "Oxide-red kiln sign upright", (gx + x, gy + 1.65, gz), (.34, 2.75, .42), brick,
             material=wood, collide=False)
        part(entry, "Kiln sign brass collar", (gx + x, gy + 2.73, gz), (.52, .24, .49), brass,
             material=metal, collide=False)
    sign(entry, "KILNBACK RAID", gx, gy + 2.94, gz+.16, 6.22, .97,
         tint="9E4A3A", single_line=True)
    sign(entry, "4 FIGHTERS  •  CO-OP", gx, gy + 2.00, gz+.16, 5.03, .50,
         tint="3D635E", single_line=True)
    gate = part(entry, "Kilnback Raid Queue", (gx, gy + 1.75, gz + .68), (.2, .2, .2), gold,
                collide=False, transparency=1)
    prompt = item(gate, "ProximityPrompt", "JoinKilnbackRaidPrompt")
    prop(prompt, "string", "ActionText", "Join or leave queue")
    prop(prompt, "string", "ObjectText", "Kilnback Raid")
    prop(prompt, "bool", "RequiresLineOfSight", False)
    prop(prompt, "float", "MaxActivationDistance", 8)
    prop(prompt, "float", "HoldDuration", .2)
    part(entry, "Raid Return", (gx + 1.8, gy + 2.30, gz + 2.4), (.2, .2, .2), gold,
         collide=False, transparency=1)

    court = item(cinder, "Model", "Kilnback Raid Court")
    prop(court, "token", "ModelStreamingMode", 1)
    cx, floor, cz = CENTER

    def piece(parent, name, pos, size, tint, *, material=smooth, collide=False, transparency=0, **rotation):
        x, y, z = pos
        obj = part(parent, name, (cx + x, floor + y, cz + z), size, tint, material=material,
                   collide=collide, transparency=transparency, **rotation)
        prop(obj, "bool", "CastShadow", False)
        return obj

    def marker(parent, name, pos, size=(.2, .2, .2), *, yaw=0, collide=False):
        return piece(parent, name, pos, size, gold, yaw=yaw, collide=collide, transparency=1)

    marker(court, "Bounds", (0, 3.10, 0), (48, 13, 50))
    marker(court, "Floor Origin", (0, 0, 0))
    spawn = item(court, "Folder", "Spawn Marks")
    for index, (x, z, yaw) in enumerate(((-8.2, 14, -30), (-2.8, 16, -10), (2.8, 16, 10), (8.2, 14, 30)), 1):
        marker(spawn, f"Seat {index}", (x, 2.30, z), yaw=yaw)

    chamber = item(court, "Model", "Cinder kiln chamber")
    piece(chamber, "Chamber floor collider", (0, -.43, 0), (53.5, .86, 54.5), "977C70",
          material=limestone, collide=True)
    for ix in range(7):
        for iz in range(7):
            x, z = (ix-3)*7.52, (iz-3)*7.67
            edge = ix in (0, 6) or iz in (0, 6)
            palette = ("9B6959", "916152", "9F6B58") if edge else ("9B857B", "A68F82", "AA9486", "9A8076")
            piece(chamber, "Honed kiln flagstone", (x, .013, z), (7.46, .022, 7.61),
                  palette[(ix*2+iz) % len(palette)], material=limestone)
    for side in (-1, 1):
        piece(chamber, "Brass track", (side*18.96, .035, 0), (.14, .015, 39.3), brass, material=metal)
        piece(chamber, "Brass track", (0, .035, side*19.7), (38.15, .015, .14), brass, material=metal)
        piece(chamber, "Cinder chamber side backing", (side*27.7, 9, 0), (3.3, 19, 58), "694847",
              material=slate, collide=True)
        piece(chamber, "Cinder chamber end backing", (0, 9, side*28.2), (56, 19, 3.2), "654649",
              material=slate, collide=True)
        marker(chamber, "East west raid barrier", (side*24.66, 4, 0), (.44, 9, 51.5), collide=True)
        marker(chamber, "North south raid barrier", (0, 4, side*25.66), (49.8, 9, .44), collide=True)
        for offset in (-18.8, -6.2, 6.2, 18.8):
            for x, z, yaw in ((side*26.12, offset, 90), (offset, side*26.70, 0)):
                piece(chamber, "Reeded furnace pilaster", (x, 5.0, z), (1.6, 10.5, 1.6),
                      "8B5A4F", material=slate, yaw=yaw)
                piece(chamber, "Pilaster foot", (x, .63, z), (2.1, 1.27, 2.0), "835A56", material=limestone, yaw=yaw)
                piece(chamber, "Pilaster bronze capital", (x, 9.58, z), (2.61, .44, 1.89), "AC754F", material=metal, yaw=yaw)
        for height, tint in ((.43, "8C5C53"), (2.72, "A26957"), (9.62, "886252"), (12.72, "6C4C44")):
            piece(chamber, "Cinder masonry band", (side*26.14, height, 0), (1.22, .36, 55.2), tint, material=slate)
            piece(chamber, "Cinder masonry band", (0, height, side*26.68), (54.0, .36, 1.19), tint, material=slate)
        for along in (-12.5,0,12.5):
            for x,z,yaw in ((side*26.23, along, 90), (along, side*26.80, 0)):
                piece(chamber, "Glazed chamber wall inset", (x, 5.25, z), (9.45, 4.0, .3),
                      "885354", material=limestone, yaw=yaw)
                piece(chamber, "Dull jade leaded kiln panel", (x*.987, 6.2, z*.987), (5.55, .78, .26),
                      "60817A", material=limestone, yaw=yaw)
    for bay in (-12.5, 0, 12.5):
        piece(chamber, "Kiln alcove bronze arched cap", (bay, 6.25, -26.24),
              (.28, 4.64, 4.64), "684539", shape=2, yaw=90, material=metal)
        piece(chamber, "Ceramic kiln alcove interior", (bay, 6.21, -26.06),
              (.20, 3.80, 3.80), "3E4146", shape=2, yaw=90)
        piece(chamber, "Kiln alcove bronze casing", (bay, 4.31, -26.22),
              (4.63, 3.89, .30), "67473A", material=metal)
        piece(chamber, "Kiln alcove shadow recess", (bay, 4.44, -26.05),
              (3.79, 3.66, .24), "3E4146")
        piece(chamber, "Kiln alcove ceramic sill", (bay, 2.43, -25.93),
              (5.07, .34, .55), "90756B", material=limestone)
        piece(chamber, "Low firebrick hearth", (bay, 3.34, -25.89),
              (2.89, .91, .15), "834D35")
        for rib in (-1.0, 0, 1.0):
            piece(chamber, "Kiln alcove wrought grate", (bay+rib, 4.31, -25.72),
                  (.12, 2.94, .11), "6C6053", material=metal)
    for row, y in enumerate((12.02, 14.66)):
        for column in range(6):
            palette = ("8B5C53", "80544F", "784E4A")
            piece(chamber, "Cut firebrick wall course", ((column-2.5)*8.78, y, -26.46),
                  (8.64, 2.4, .37), palette[(column+row) % len(palette)], material=slate)
    piece(chamber, "Kiln chamber roof", (0, 18.9, 0), (58, 2.3, 58.5), "596061", material=slate, collide=True)
    for z in (-20.8, -10.6, 0, 10.6, 20.8):
        piece(chamber, "Kiln roof crossbeam", (0, 17.41, z), (55.1, .94, 1.37), "69483D", material=wood)
        piece(chamber, "Roof brass trim", (0, 17.02, z), (53.4, .14, .22), "BA8751", material=metal)
    for i, (x, z) in enumerate(((-12.8,-12.75),(12.8,-12.75),(-12.8,12.75),(12.8,12.75))):
        piece(chamber, "Kiln lantern bronze mount", (x, 14.80, z), (2.40, .37, 2.4), brass, material=metal)
        piece(chamber, "Kiln lantern bronze suspension", (x, 15.82, z), (.24, 2.1, .24), dark, material=metal)
        lantern = piece(chamber, "Kiln lantern amber lens", (x, 13.98, z), (1.80, 1.25, 1.80),
                        "F0BC82", material=neon)
        piece(chamber, "Kiln lantern base", (x, 13.28, z), (2.08, .29, 2.08), "9A6843", material=metal)
        for dx in (-.94, .94):
            for dz in (-.94, .94):
                piece(chamber, "Lantern corner cage", (x+dx, 14.04, z+dz), (.12, 1.59, .12),
                      brass, material=metal)
        light = item(lantern, "PointLight", "Shadow-free chamber light")
        prop(light, "float", "Brightness", 1.10 if i < 2 else .98)
        prop(light, "float", "Range", 34)
        prop(light, "bool", "Shadows", False)
        if color is not None:
            color(light, "Color", "FFEAD2" if i < 2 else "DDE9F5")
    sign(chamber, "CINDER KILN CHAMBER", cx, floor + 9.0, cz - 25.8, 12.5, 1.15,
         tint="8E4B3E", single_line=True)
    for x in (-20.6,20.6):
        piece(chamber, "Glazed bankside kiln jar", (x, 1.16, -21.8), (2.5, 2.32, 2.50),
              "527A72", shape=0)
        piece(chamber, "Kiln jar brass lip", (x, 2.19, -21.8), (.37, 1.3, 1.3),
              "BF8F53", roll=90, shape=2, material=metal)

    boss = item(court, "Model", "Kilnback Custodian")
    marker(boss, "Origin", (0, 0, 0), yaw=180)
    marker(boss, "Shell Hit", (0, 2.40, 0), (11.0, 4.70, 11.0), yaw=180)
    marker(boss, "Core Hit", (0, 2.68, 5.30), (2.26, 2.36, 1.76), yaw=180)
    marker(boss, "Shell Collider", (0, 1.71, 0), (9.0, 3.42, 9.0), yaw=180, collide=True)
    item(court, "Folder", "Raid Tells")

    def pivot_group(parent, name, pos, yaw=0):
        model = item(parent, "Model", name)
        pivot = marker(model, "Pose Hinge", pos, yaw=yaw)
        prop(model, "Ref", "PrimaryPart", pivot.get("referent"))
        return model

    rig = pivot_group(boss, "Animated Body", (0, 0, 0))
    piece(rig, "Cast brass undercarriage", (0, 1.39, 0), (9.6, 2.34, 9.7), "694E3C", material=metal, shape=0)
    piece(rig, "Low fired ceramic carapace", (0, 2.63, -.43), (10.5, 4.13, 11.0), "235450", shape=0)
    piece(rig, "Glazed dark central dome", (0, 3.39, -.44), (8.88, 2.96, 9.25), "32665F", shape=0)
    for index in range(8):
        angle = index * pi / 4
        ax, az = sin(angle), cos(angle)
        yaw = index * 45
        halo = pivot_group(rig, f"Shell Plate {index+1}", (ax*2.88, 4.17, -.30+az*2.88), yaw)
        ceramic = ("CDBE9E", "A7AF9C", "C2B397", "99A695")[index % 4]
        piece(halo, "Bronze-backed outer shell segment", (ax*3.85, 3.44, -.30+az*3.85),
              (3.20, .45, 2.93), "8C5531", material=metal, yaw=yaw, pitch=25)
        piece(halo, "Octagonal glazed shell segment", (ax*3.83, 3.63, -.30+az*3.83),
              (2.98, .40, 2.73), ceramic, yaw=yaw, pitch=25)
        piece(halo, "Scored glaze outer trim", (ax*4.62, 3.36, -.30+az*4.62),
              (2.47, .12, .19), "BC8B56", material=metal, yaw=yaw, pitch=25)
        for dx in (-.60,.60):
            piece(halo, "Shell plate brass rivet", (ax*4.37+az*dx, 3.58, -.30+az*4.37-ax*dx),
                  (.16,.16,.16), "986536", material=metal, shape=0)
    for yaw, tint in ((0,"92623A"),(45,"92623A")):
        piece(rig, "Brass octagonal crown rim", (0,4.84,-.30), (3.44,.23,3.44), tint, yaw=yaw, material=metal)
    piece(rig, "Sea-green shell crown", (0,4.99,-.30), (3.06,.22,3.08), "4B8275", yaw=45)
    piece(rig, "Kilnmaker's forging stud", (0,5.12,-.30), (.22,.76,.76), gold, roll=90, shape=2, material=metal)
    for side in (-1,1):
        for back in (-1,1):
            x, z = side*3.80, back*3.06
            leg = pivot_group(rig, f"Leg {1+(side+1)+(back+1)//2}", (x, 1.4, z))
            piece(leg, "Axle bead", (x+side*.29, 1.56, z), (.79, 1.24, 1.24),
                  "E3AA60", material=metal, shape=2)
            piece(leg, "Articulated bronze shin", (x+side*.63, .99, z+back*.37),
                  (1.04, 1.52, 1.08), "B67D45", material=metal, roll=side*19)
            piece(leg, "Hammered brass foot", (x+side*.88, .33, z+back*.72),
                  (1.66, .65, 1.52), "AB7848", material=metal)
            for toe in (-.41,.41):
                piece(leg, "Chalk ceramic toe", (x+side*.93+toe, .32, z+back*1.40),
                      (.30, .42, .54), "DDC39D")
        side_name = "Left" if side < 0 else "Right"
        bellows = pivot_group(rig, f"Bellows {side_name}", (side*4.75, 2.10, -.55))
        piece(bellows, "Bellows hide casing", (side*5.11, 1.92, -.73),
              (1.41, 1.56, 2.12), "623D37")
        for fold in range(4):
            piece(bellows, "Bellows ceramic pleat", (side*(4.62+fold*.36), 1.93, -.73),
                  (.11, 1.75-fold*.07, 2.1-fold*.12), "AD754A" if fold%2 else "CE955C", material=metal)
        piece(bellows, "Bronze hot vent rim", (side*5.88, 1.98, -.73), (.18, 1.41, 1.47), "E1A965", material=metal)
        piece(bellows, "Vent Glow", (side*6.0, 1.98, -.73), (.10, 1.05, 1.09), "C37943", material=neon)
        shutter = pivot_group(rig, f"Core Shutter {side_name}", (side*.67, 2.67, 5.55))
        piece(shutter, "Brass core shutter", (side*.62,2.68,5.52), (1.21, 1.45, .36), "9D623E", material=metal)
        piece(shutter, "Ceramic portcullis tile", (side*.60,2.73,5.73), (1.03, 1.25,.18), "835650")
        piece(shutter, "Shutter gold groove", (side*.59,2.71,5.85), (.17, .92,.09), "E6A861", material=metal)
    piece(rig, "Circular bronze core bore", (0, 2.68, 5.38), (.45, 2.08, 2.08), "D99D5B", yaw=90, material=metal, shape=2)
    piece(rig, "Core Glow", (0, 2.68, 5.59), (.24, 1.67, 1.67), "44706B", yaw=90, material=neon, shape=2)
    piece(rig, "Core ceramic seam", (0, 2.67, 5.72), (.10, .90, .90), "76998D", yaw=90, material=neon, shape=2)
    head = pivot_group(rig, "Head", (0, 1.66, 4.69))
    piece(head, "Wrought bronze neck", (0,1.48,5.22), (1.85,1.18,1.65), "A67D55", material=metal, shape=0)
    piece(head, "Jade tortoise head", (0,1.69,6.16), (2.30,1.67,2.39), "51807B", shape=0)
    piece(head, "Terracotta jaw", (0,1.22,6.57), (1.72,.70,1.27), "CCAA82", shape=0)
    piece(head, "Reed cap base", (0,2.43,6.12), (.23,2.38,2.38), "86613D", shape=2, roll=90, material=wood)
    for strip in (-.79,-.40,0,.40,.79):
        piece(head, "Woven reed cap rib", (strip,2.57,6.10), (.17,.115,1.76-abs(strip)*.74),
              "CEA768" if strip else "E2BD7C", material=wood, yaw=12)
    for side in (-1,1):
        piece(head,"Eye bronze recess", (side*.74,1.85,6.86), (.62,.55,.32), "A4714E", material=metal, yaw=side*31)
        piece(head,f"Eye {side}", (side*.77,1.85,7.03), (.40,.22,.13), "FFE7A1", material=neon, yaw=side*31)
    return court
