"""Copper eaves, recessed galleries and pottery displays for Cinder Kiln Hall."""

from math import atan2, degrees, hypot


CENTERPIECE_POTTERY = {
    # Pottery_B and Pottery_C by gageyes00p, Store models 18486941774 and 18486905345.
    -1: ("Dark glazed jar", 18486836957, 18486837273, (32.925354, 28.073526, 32.925415)),
    1: ("Red glazed jar", 18486836419, 18486836733, (49.999962, 45.592098, 50.0)),
}


def build_cinder_workshop_hall(town, x, y, z, *, item, prop, part, beam,
                              festival_lantern, slate, wood, metal, neon, cedar_variant,
                              variant_field, vector, asset):
    hall = item(town, "Model", "Kiln Hall copper workshops")
    prop(hall, "token", "ModelStreamingMode", 1)
    prop(hall, "token", "LevelOfDetail", 4)
    house_z = z - 19

    def world(point):
        px, py, pz = point
        return x + px, y + py, house_z + pz

    def place(parent, label, offset, size, tint, material=wood, *, shadow=False, **pose):
        detail = part(parent, label, world(offset), size, tint, material=material,
                      collide=False, **pose)
        prop(detail, "bool", "CastShadow", shadow)
        if material == wood:
            prop(detail, "string", variant_field, cedar_variant)

    def trim(parent, label, a, b, gauge, tint):
        detail = beam(parent, label, world(a), world(b), gauge, tint)
        prop(detail, "bool", "CastShadow", False)

    def copper_roof(parent, eave_y, z_center, width, depth, rise):
        # Horizontal seams follow the bend while the outer pans sweep up at the corners.
        courses = ((1, 0), (.68, .11), (.40, .36), (.16, .70), (0, 1))
        lanes = ((-1, .30), (-.73, .045), (-.34, 0), (.34, 0), (.73, .045), (1, .30))
        copper = (("A86851", "9D634E", "8B5448", "805047"),
                  ("B67857", "A66A51", "9A604B", "895449"))
        for side in (-1, 1):
            for band, ((outer, low), (inner, high)) in enumerate(zip(courses, courses[1:])):
                run = (outer - inner) * depth / 2
                lift = (high - low) * rise
                pitch = side * degrees(atan2(lift, run))
                for lane, ((start, start_lift), (end, end_lift)) in enumerate(zip(lanes, lanes[1:])):
                    span = (end - start) * width / 2
                    turn = (end_lift - start_lift) * rise * (outer + inner) / 2
                    center = ((start + end) * width / 4,
                              eave_y + rise * ((low + high) / 2 + (start_lift + end_lift) * (outer + inner) / 4),
                              z_center + side * (outer + inner) * depth / 4)
                    place(parent, "Hammered copper roof pan", center,
                          (hypot(span, turn) + .14, .28, hypot(run, lift) + .16),
                          copper[(side + lane) % 2][band], metal, shadow=band == 0,
                          pitch=pitch, roll=degrees(atan2(turn, span)))
                    # Allow the seams to read at street distance with one narrow rib per pan.
                    start_y = eave_y + (low + (start_lift + end_lift) * outer / 2) * rise
                    end_y = eave_y + (high + (start_lift + end_lift) * inner / 2) * rise
                    trim(parent, "Folded standing copper seam",
                         (center[0], start_y + .22, z_center + side * depth * outer / 2),
                         (center[0], end_y + .22, z_center + side * depth * inner / 2), .105, "D29B70")
                    if band == 0:
                        trim(parent, "Turned copper eave lip",
                             (start * width / 2, eave_y + start_lift * rise - .08, z_center + side * depth / 2),
                             (end * width / 2, eave_y + end_lift * rise - .08, z_center + side * depth / 2),
                             .27, "CB8A58")
            for hand in (-1, 1):
                tip = (hand * width / 2, eave_y + .30 * rise, z_center + side * depth / 2)
                trim(parent, "Curved copper eave finial", tip,
                     (tip[0] + hand * .64, tip[1] + .55, tip[2] + side * .11), .27, "DEAA75")
        crest = eave_y + rise
        place(parent, "Sealed copper ridge beam", (0, crest + .12, z_center),
              (width - .34, .46, .79), "9D614C", metal, shadow=True)
        place(parent, "High-lit ridge cap", (0, crest + .40, z_center),
              (width - .45, .13, .59), "C48A64", metal)
        for hand in (-1, 1):
            tip = hand * width / 2
            trim(parent, "Turned ridge crown", (tip - hand * 1.28, crest + .36, z_center),
                 (tip + hand * .19, crest + 1.14, z_center), .35, "DEA370")
            trim(parent, "Ridge crown tip", (tip + hand * .14, crest + 1.10, z_center),
                 (tip + hand * .37, crest + 1.72, z_center), .20, "F0BA84")

    def window(parent, offset, width, height, side, pane, yaw=0):
        px, py, pz = offset
        orientation = {0: (0, side), 90: (side, 0)}[yaw]
        nx, nz = orientation
        tx, tz = nz or 0, -nx
        angle = 90 * side if yaw else 0

        def layer(label, dx, dy, setback, size, tint, material=wood):
            place(parent, label, (px + tx * dx + nx * setback, py + dy, pz + tz * dx + nz * setback),
                  size, tint, material, yaw=angle)

        # The front cap sits over the sides of the smaller inset paper pane.
        layer("Smoke-dark window rebate", 0, 0, .11, (width + .33, height + .38, .25), "4E302E")
        layer("Warm oil-paper pane", 0, 0, .247, (width, height, .036), pane, neon)
        for dx in (-.47, -.225, 0, .225, .47):
            layer("Carved window lattice stile", dx * width, 0, .32, (.10, height, .14), "663D32")
        for dy in (-.44, -.20, .27, .44):
            layer("Carved window lattice rail", 0, dy * height, .32, (width, .092, .14), "704439")
        layer("Copper window drip edge", 0, -height / 2 - .19, .315,
              (width + .40, .13, .46), "B67D4E", metal)

    gallery = item(hall, "Model", "Kiln Hall copper gallery")
    gallery_z = -.75
    for level, width, depth, height, tint in (
        (15.90, 18.18, 11.44, .66, "835951"),
        (16.20, 18.72, 11.80, .18, "AD7C67"),
        (16.40, 18.44, 11.58, .24, "A56952"),
    ):
        place(gallery, "Gallery terrace sill course", (0, level, gallery_z),
              (width, height, depth), tint, slate, shadow=level == 15.90)
    place(gallery, "Paneled workshop gallery", (0, 19.30, gallery_z), (17.90, 5.75, 10.56),
          "8E5140", shadow=True)
    place(gallery, "Cedar gallery fascia", (0, 22.16, gallery_z), (18.66, .51, 11.76),
          "653930", shadow=True)
    place(gallery, "Copper fascia rim", (0, 22.41, gallery_z), (18.90, .11, 11.84), "CD946B", metal)
    for face in (-1, 1):
        wall = gallery_z + face * 5.28
        for bay, px in enumerate((-6.57, -2.19, 2.19, 6.57)):
            window(gallery, (px, 19.48, wall), 3.46, 3.62, face,
                   ("D9975E", "E9AE72", "E7A969", "D18E5F")[bay])
        for px in (-8.73, -4.38, 0, 4.38, 8.73):
            place(gallery, "Gallery cedar pillar", (px, 19.33, wall + .25 * face),
                  (.47, 5.60, .51), "814736", shadow=abs(px) > 8)
            for level in (17.02, 21.75):
                place(gallery, "Pillar copper cuff", (px, level, wall + .30 * face),
                      (.57, .16, .54), "AE7751", metal)
            for level, reach, tint in ((21.70, .65, "865140"), (21.91, .95, "9D5C45"),
                                       (22.11, 1.23, "774437")):
                place(gallery, "Stepped gallery roof bracket", (px, level, wall + .35 * reach * face),
                      (.53 + .21 * reach, .20, reach), tint)
    for side in (-1, 1):
        for pz in (-3.10, 1.60):
            window(gallery, (side * 8.95, 19.52, pz), 3.47, 3.40, side, "D09B6C", yaw=90)
        roof_lantern = world((side * 8.20, 20.57, 5.19))
        festival_lantern(gallery, *roof_lantern, .55, light=False, tint="EBA26B", entrance_paper=True)
    copper_roof(gallery, 22.59, gallery_z, 22.10, 13.76, 3.45)

    crown = item(hall, "Model", "Kiln Hall brass clerestory")
    place(crown, "Clerestory support course", (0, 25.57, gallery_z), (10.72, .54, 6.82),
          "8E6357", slate, shadow=True)
    place(crown, "Clerestory shutter box", (0, 28.02, gallery_z), (10.05, 4.55, 6.03),
          "80513C", shadow=True)
    place(crown, "Clerestory roof frieze", (0, 30.10, gallery_z), (10.54, .42, 6.40),
          "693E31", shadow=True)
    for face in (-1, 1):
        wall = gallery_z + face * 3.015
        for px in (-3.05, 0, 3.05):
            window(crown, (px, 28.20, wall), 2.19, 2.18, face, "E6AC71")
        for px in (-4.78, -1.54, 1.54, 4.78):
            place(crown, "Square cedar crown jamb", (px, 28.08, wall + .22 * face),
                  (.34, 3.99, .43), "965741")
            place(crown, "Burnished crown jamb cap", (px, 29.99, wall + .28 * face),
                  (.46, .16, .47), "C39268", metal)
    for side in (-1, 1):
        window(crown, (side * 5.025, 28.16, gallery_z), 3.47, 2.18, side, "D39B6D", yaw=90)
    copper_roof(crown, 30.50, gallery_z, 12.64, 8.63, 2.26)

    stalls = item(hall, "Model", "Kiln Hall pottery-window bays")
    ceramics = item(town, "Model", "Cinder workshop ceramics")
    prop(ceramics, "token", "ModelStreamingMode", 1)
    for hand in (-1, 1):
        pier = hand * 9.91
        place(stalls, "Carved slate pier shoe", (pier, .90, 7.50), (1.51, 1.58, 1.29),
              "885F57", slate)
        place(stalls, "Pier rim level", (pier, 1.71, 7.62), (1.53, .18, 1.30), "AA7B66", slate)
        place(stalls, "Entry carved cedar face", (pier, 6.70, 8.20), (.58, 10.01, .33), "9D5841")
        for level in (2.71, 10.57):
            place(stalls, "Entry copper strap", (pier, level, 8.33), (.69, .18, .30), "B77C52", metal)
        for level, reach, tint in ((10.92, .44, "794137"), (11.16, .66, "9A5A45"),
                                   (11.39, .95, "A66A4F")):
            place(stalls, "Stacked entry corbel", (pier, level, 8.15), (.56 + reach * .28, .20, reach), tint)

        px = hand * 7.11
        for side in (-1, 1):
            place(stalls, "Workshop inset window stile", (px + side * 2.47, 6.59, 7.81),
                  (.32, 7.34, .41), "733E31")
        place(stalls, "Workshop lower apron", (px, 2.65, 7.74), (4.65, 1.53, .28), "925843")
        place(stalls, "Cedar pottery display sill", (px, 3.47, 7.90), (4.89, .28, 1.09), "A26748")
        place(stalls, "Pounded copper sill strip", (px, 3.60, 8.22), (4.80, .09, .43), "AE7C56", metal)
        place(stalls, "Copper-wrapped window lintel", (px, 10.05, 7.87), (5.17, .37, .61), "805041")
        place(stalls, "Window rain edge", (px, 10.30, 8.04), (5.22, .13, .53), "A46D4A", metal)
        for offset, size, tint, rim in ((-1.57, .77, "BB785A", "DA9870"),
                                        (1.51, .66, "A76751", "C18A66")):
            for level, height, diameter, color in ((.10, .20, .47, tint), (.29, .18, .71, tint),
                                                    (.53, .30, .88, tint), (.75, .15, .71, tint),
                                                    (.87, .11, .50, rim), (.93, .07, .56, rim),
                                                    (.966, .022, .37, "694237")):
                place(stalls, "Glazed pottery on display", (px + offset, 3.61 + level * size, 8.16),
                      (height * size, diameter * size, diameter * size), color, slate, shape=2, roll=90)
        name, mesh_id, texture_id, mesh_size = CENTERPIECE_POTTERY[hand]
        jar_size = tuple(length * (1.26 / mesh_size[0]) for length in mesh_size)
        jar = part(ceramics, name, world((px + .04, 3.645 + jar_size[1] / 2, 8.10)),
                   jar_size, "A3A2A5", yaw=hand*12, collide=False, class_name="MeshPart")
        vector(jar, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        prop(jar, "bool", "CastShadow", False)
        prop(jar, "token", "RenderFidelity", 0)
        asset(jar, "MeshContent", f"rbxassetid://{mesh_id}")
        asset(jar, "TextureContent", f"rbxassetid://{texture_id}")

    place(stalls, "Entry carved cedar lintel", (0, 10.52, 7.68), (6.23, .37, .60), "763F34", shadow=True)
    place(stalls, "Entry narrow copper inlay", (0, 10.54, 8.00), (5.09, .11, .13), "D49A67", metal)

    portico = item(hall, "Model", "Kiln Hall recessed portico")
    # The two inner columns retain the original opening and collision. Their
    # forward faces sit beneath the sign, so the lettering stays unobstructed.
    for side in (-1, 1):
        pier = side * 3.57
        for lift, width, height, depth, tint in (
            (.70, 1.39, .56, 1.41, "6C5150"), (1.08, 1.45, .20, 1.47, "9E7565"),
            (1.50, 1.34, .64, 1.39, "7F5A51"),
        ):
            place(portico, "Kiln entry battered stone shoe", (pier, lift, 7.52),
                  (width, height, depth), tint, slate)
        place(portico, "Oiled entry cedar face", (pier, 6.07, 8.20),
              (1.13, 8.48, .18), "754336")
        for edge in (-.43, .43):
            place(portico, "Carved vertical pillar bead", (pier + edge, 6.12, 8.31),
                  (.105, 8.20, .075), "A36A50")
        for lift in (2.02, 9.78):
            place(portico, "Restrained copper pillar strap", (pier, lift, 8.22),
                  (1.27, .18, .25), "BE885D", metal)
        for index, (lift, reach) in enumerate(((9.71, .64), (9.99, .92), (10.27, 1.33))):
            place(portico, "Stepped porch corbel", (pier, lift, 7.94 + reach * .26),
                  (1.02 + .20 * index, .24, reach), ("5D352F", "874B3A", "A5674C")[index])
        # Side returns layer the storefront eaves without changing the
        # door's walkable height or covering the existing paper lanterns.
        bay = side * 7.09
        place(portico, "Dark pottery bay soffit", (bay, 9.94, 8.18),
              (4.94, .30, 1.10), "5C3934")
        place(portico, "Copper-backed pottery rain lip", (bay, 10.14, 8.70),
              (5.10, .23, .42), "AB744F", metal)

    place(portico, "Recessed porch ceiling", (0, 10.26, 6.46), (6.27, .21, 2.99), "634039")
    place(portico, "Carved shadow header", (0, 10.37, 8.14), (6.08, .31, .27), "603831")
    place(portico, "Sunlit porch copper edge", (0, 10.48, 8.34), (6.12, .093, .095), "D49B6F", metal)
    for runner in (-2.34, -1.17, 0, 1.17, 2.34):
        place(portico, "Inset porch ceiling rafter", (runner, 10.08, 6.48), (.17, .16, 2.92), "84503F")
    # A thin decorative runner picks up the portal and display colors on the
    # existing foundation. The entire middle aisle remains unobstructed.
    for index, (depth, tint) in enumerate(((6.98, "C09579"), (5.10, "AD826D"), (3.22, "987465"),
                                           (1.34, "9D7868"), (-.54, "A6806D"), (-2.42, "977368"))):
        for strip in (-1, 1):
            place(portico, "Kiln threshold terracotta course", (strip * 1.20, .438 + .003 * (index % 2), depth),
                  (2.36, .030, 1.82), tint, slate)

    display = item(hall, "Model", "Kiln Hall interior glaze display")
    # Use the rear plaster as the substrate, then vary depth and warm tones
    # across a low relief that reads through the open hall from the forecourt.
    place(display, "Recessed pottery alcove field", (0, 4.62, -6.43), (13.33, 7.66, .18), "76554C", slate)
    place(display, "Raised glazed alcove panel", (0, 4.74, -6.27), (10.77, 6.29, .15), "9D725B", slate)
    for xoff in (-6.47, -2.84, 2.84, 6.47):
        place(display, "Kiln hall alcove jamb", (xoff, 4.80, -6.17), (.42, 7.72, .44), "653D35")
    for center in (-4.59, 4.59):
        window(display, (center, 5.62, -6.09), 2.63, 3.87, 1, "C8865E")
    for lift, tint in ((1.12, "875B50"), (3.11, "BA855E"), (8.43, "B3815F")):
        place(display, "Kiln display ceramic casing", (0, lift, -6.11), (13.74, .24, .63), tint, slate)
    for lift, width, tint in ((4.08, 1.27, "6D7464"), (4.37, 1.91, "748272"), (4.68, 2.18, "739280"),
                              (5.05, 2.06, "749183"), (5.45, 1.43, "7B9B88"), (5.77, 1.19, "C19670")):
        place(display, "Sgraffito glazed vessel tile", (0, lift, -6.08), (width, .33, .20), tint, slate)

    for hand in (-1, 1):
        center = hand * 4.92
        place(display, "Low adobe display plinth", (center, 1.12, -5.19), (3.45, 1.39, 1.56), "966A57", slate)
        place(display, "Dark cedar display ledge", (center, 1.86, -5.13), (3.55, .21, 1.66), "785044")
        for offset, profile, tint, rim in ((-.78, .60, "778F81", "B8A17A"), (.66, .81, "B4816A", "D29B72")):
            shelf = center + offset * hand
            for rise, height, width, glaze in ((.14, .28, .59, tint), (.42, .29, .90, tint),
                                               (.65, .22, .69, tint), (.79, .13, .42, rim)):
                place(display, "Fired vessel on interior shelf", (shelf, 1.97 + rise * profile, -4.89),
                      (height * profile, width * profile, width * profile), glaze, slate, shape=2, roll=90)

    # Copper seal depicts a round-bellied workshop vessel above the original sign.
    seal = item(hall, "Model", "Kiln Hall potter mark")
    place(seal, "Round potter's seal surround", (0, 23.78, 5.22),
          (.31, 3.64, 3.64), "BC885E", metal, shape=2, yaw=90)
    place(seal, "Dark copper seal field", (0, 23.78, 5.41),
          (.10, 3.20, 3.20), "663E34", metal, shape=2, yaw=90)
    for level, width, thickness in ((23.05, 1.24, .15), (23.27, 1.53, .32), (23.58, 1.79, .33),
                                    (23.88, 1.55, .30), (24.16, .92, .28), (24.36, 1.18, .15)):
        place(seal, "Raised vessel seal", (0, level, 5.50), (width, thickness, .13), "DDA673", metal)
