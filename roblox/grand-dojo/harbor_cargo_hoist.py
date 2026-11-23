"""Tideharbor's timber lifting rig, in the water gap between its two piers."""


def build_harbor_cargo_hoist(town, *, item, prop, part, beam, triangle, sign,
                            garden_prop, slate, wood, metal, cloth):
    hoist = item(town, "Model", "Harbor cargo hoist")
    prop(hoist, "token", "ModelStreamingMode", 1)
    prop(hoist, "token", "LevelOfDetail", 4)
    x, z = 253.5, 47.5
    cedar, teak, verdigris, brass = "885943", "633E35", "367273", "AD8457"

    def piece(name, position, size, tint, material, **options):
        node = part(hoist, name, position, size, tint, material=material, collide=False, **options)
        prop(node, "bool", "CastShadow", False)

    def timber(name, a, b, gauge, tint):
        node = beam(hoist, name, a, b, gauge, tint)
        prop(node, "bool", "CastShadow", False)

    # The working mechanism sits on its own piles beside the pier railing.
    for dx in (-2.38, 2.38):
        for dz in (-1.69, 1.69):
            px, pz = x + dx, z + dz
            piece("Salt-stained crane piling", (px, .05, pz), (.95, 7.60, .95), "726859", wood)
            piece("Stone tide collar", (px, .72, pz), (1.25, 1.24, 1.22), "8B8790", slate)
            piece("Bronze pile clasp", (px, 3.73, pz), (1.08, .18, 1.08), brass, metal)
    for i in range(8):
        piece("Cedar crane landing board", (x - 2.9 + i * .83, 4.10, z), (.81, .53, 5.89),
              ("A8795D", "90654F", "AD8164", "9C725B")[i % 4], wood)
    piece("Crane deck beam", (x, 3.70, z - 1.55), (6.90, .41, .59), teak, wood)
    piece("Crane deck beam", (x, 3.70, z + 1.55), (6.90, .41, .59), teak, wood)
    for dz in (-1.44, 1.44):
        pz = z + dz
        piece("Teal crane stanchion shoe", (x, 4.58, pz), (1.40, .48, 1.36), verdigris, wood)
        piece("Tapered cedar crane upright", (x, 9.50, pz), (1.08, 10.22, .94), cedar, wood)
        for height in (5.4, 11.58, 14.35):
            piece("Gilt crane band", (x, height, pz), (1.18, .20, 1.09), brass, metal)
        timber("Crane diagonal knee", (x - 2.36, 4.39, pz), (x, 9.15, pz), .45, teak)
        timber("Crane elevated brace", (x, 9.15, pz), (x + 3.98, 13.84, pz), .48, teak)

    beam_end_x = 262.12
    for dz in (-1.28, 1.28):
        pz = z + dz
        timber("Long cedar crane arm", (x - 4.3, 13.60, pz), (beam_end_x, 15.14, pz), .68, cedar)
        timber("Crane stay", (x, 16.32, pz), (beam_end_x - .15, 15.33, pz), .11, "624638")
        timber("Crane backstay", (x, 16.32, pz), (x - 4.0, 13.85, pz), .12, "72503D")
    for dx, y in ((-4.2, 13.60), (-2.0, 13.88), (.15, 14.14), (2.85, 14.45),
                  (5.67, 14.81), (8.58, 15.14)):
        piece("Crane arm tie", (x + dx, y, z), (.38, .44, 3.08), verdigris, wood)
    piece("Crane mast crown", (x, 15.03, z), (.78, 2.89, .76), verdigris, wood)
    piece("Crane mast brass finial", (x, 16.63, z), (.38, .43, .38), brass, metal)
    piece("Tackle axle pin", (beam_end_x - .37, 14.93, z), (.30, .30, 2.90), brass, metal)
    piece("Inset crank pulley", (x + .63, 10.82, z - 1.98), (.46, 2.03, 2.03), teak, wood,
          shape=2, yaw=90)
    piece("Crank pulley brass hub", (x + .63, 10.82, z - 2.25), (.24, .66, .66), brass, metal,
          shape=2, yaw=90)
    for offset in (-.34, .34):
        timber("Rigged cargo rope", (beam_end_x - .35 + offset, 14.64, z),
               (beam_end_x - .35 + offset, 9.13, z + .04), .076, "C9A375")

    crate_x, crate_z = 261.77, 47.55
    piece("Suspended cedar freight crate", (crate_x, 7.66, crate_z), (2.25, 1.7, 2.12), "AD7A50", wood)
    for side in (-1, 1):
        for y in (6.90, 8.38):
            piece("Crate iron edge", (crate_x, y, crate_z + side * 1.07), (2.28, .115, .13), "5D554A", metal)
        timber("Crate diagonal brace", (crate_x - .91, 7.02, crate_z + side * 1.13),
               (crate_x + .91, 8.27, crate_z + side * 1.13), .18, teak)
        timber("Load sling", (crate_x, 9.20, crate_z), (crate_x + side * 1.03, 8.56, crate_z),
               .084, "C7A077")
    for i, brow in enumerate((-.62, 0, .62)):
        piece("Vertical freight stave", (crate_x + brow, 7.69, crate_z - 1.07),
              (.085, 1.32, .095), ("916346", "966447")[i % 2], wood)

    # Teal and cream signal fabric distinguish the rig from the vermilion plaza.
    for length, rise, tint in ((2.00, .87, "4B8C88"), (1.33, .61, "D5A667")):
        start = (x - .28, 16.53 - rise, z - .12)
        middle = (x - length * .62, 16.55 - rise * .83, z + .04)
        tail = (x - length, 16.60 - rise * .95, z + .32)
        triangle(hoist, start, (start[0], start[1] + .43, start[2]), middle, tint,
                 name="Harbor signal cloth", thickness=.058, material=cloth, shadow=False)
        triangle(hoist, (start[0], start[1] + .43, start[2]), tail, middle, tint,
                 name="Harbor signal cloth", thickness=.058, material=cloth, shadow=False)
    sign(hoist, "HARBOR HOIST", x, 5.83, z - 2.69, 4.4, .84, 180, "396E70")
    for i, (dx, dz, size) in enumerate(((-3.15, 3.68, .25), (2.98, 3.53, .22))):
        garden_prop(hoist, "bankRock", (x + dx, -.40, z + dz), size, 47 * i, "938684")
        garden_prop(hoist, "cattails", (x + dx + .38, .30, z + dz + .34), .19, 35 + 39 * i)
