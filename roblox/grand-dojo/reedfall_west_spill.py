"""West overflow from Reedfall's upper basin to the Hall garden spill."""

from math import hypot

from cinder_ravine_terraces import STORE_STONES


def build_reedfall_west_spill(parent, *, item, prop, part, triangle, garden_shelf,
                             garden_prop, horizontal_water_beam, flow_beam, vector, asset,
                             slate, grass, glass, rock, rock_variant, variant_field):
    spill = item(parent, "Model", "Reedfall west overflow")
    prop(spill, "token", "LevelOfDetail", 4)

    # Bend around the rock shoulder before crossing the lip of the basin.
    channel = (
        (29.00, 22.39, -40.00),
        (31.75, 22.34, -37.00),
        (31.75, 22.24, -31.00),
        (31.50, 22.233, -30.75),
        (25.25, 22.23, -30.75),
        (24.92, 21.91, -31.09),
    )
    banks = []
    for index, (x, y, z) in enumerate(channel):
        before, after = channel[max(0, index - 1)], channel[min(index + 1, len(channel) - 1)]
        dx, dz = after[0] - before[0], after[2] - before[2]
        scale = .36 / hypot(dx, dz)
        banks.append(((x - dz * scale, y, z + dx * scale), (x + dz * scale, y, z - dx * scale)))
    # The last bend passes through the rock saddle, so draw only the open run.
    for (left, right), (next_left, next_right) in zip(banks[:3], banks[1:4]):
        for a, b, c in ((left, next_left, right), (right, next_left, next_right)):
            triangle(spill, a, b, c, "94D3E4", name="Reedfall overflow feeder",
                     thickness=.052, shadow=False, transparency=.19)

    # The curtain clears the Hall eave and narrows into the garden spill.
    bands = (
        (24.92, 21.91, -31.09, 2.30),
        (24.90, 20.85, -30.55, 2.28),
        (24.91, 20.10, -29.85, 2.30),
        (24.90, 19.60, -29.32, 2.30),
        (24.90, 19.20, -28.64, 2.32),
        (24.91, 18.80, -27.04, 2.33),
        (24.55, 18.50, -26.89, 3.00),
        (24.53, 16.00, -26.83, 2.99),
        (24.62, 12.00, -26.80, 3.01),
        (24.76, 8.00, -26.75, 2.91),
        (24.98, 7.15, -26.68, 1.73),
    )
    cross_section = ((-.50, -.033, -.08), (-.20, .017, .09),
                     (.16, .031, .14), (.50, -.022, -.05))
    panels = [
        [(x + width * across, y + rise, z + reach)
         for across, rise, reach in cross_section]
        for x, y, z, width in bands
    ]
    for index, (top, bottom) in enumerate(zip(panels, panels[1:])):
        if 2 <= index <= 4:
            # A shallow rock channel is concealed inside the shaped stone lip.
            continue
        for column, (tint, alpha) in enumerate((("528FAD", .26), ("96D4E5", .13), ("70B1CC", .19))):
            a, b = top[column:column + 2]
            c, d = bottom[column:column + 2]
            triangle(spill, a, c, b, tint, name="Reedfall overflow sheet", thickness=.057,
                     shadow=False, transparency=alpha)
            triangle(spill, c, d, b, tint, name="Reedfall overflow sheet", thickness=.057,
                     shadow=False, transparency=alpha)

    # Break the brighter water into short streaks that remain readable
    # on devices where the distant effect stays still.
    for column, contour, tint in (
        (0, ((5,.66,.022),(6,.61,.12),(7,.75,.16),(8,.81,.026)), "C2E7ED"),
        (1, ((5,.45,.042),(6,.30,.19),(7,.37,.14),(8,.44,.22),(9,.55,.049)), "DDF3F2"),
        (1, ((7,.73,.026),(8,.70,.11),(9,.65,.22),(10,.57,.065)), "D6F1F1"),
        (2, ((6,.29,.032),(7,.37,.14),(8,.51,.09),(9,.47,.031)), "BAE5EF"),
    ):
        ribbon = []
        for row, middle, width in contour:
            left, right = panels[row][column:column + 2]
            ribbon.append([
                tuple(a + (b - a) * u + (.085 if axis == 2 else 0)
                      for axis, (a, b) in enumerate(zip(left, right)))
                for u in (middle - width / 2, middle + width / 2)
            ])
        for (a, b), (c, d) in zip(ribbon, ribbon[1:]):
            for face in ((a, c, b), (c, d, b)):
                triangle(spill, *face, tint, name="Whitewater crest streak", thickness=.033,
                         shadow=False, collide=False, transparency=.16)

    # These broken courses continue back into the main cliff. Their front rim
    # remains behind the water and their west edge stays clear of the Hall ramp.
    for x, y, z, width, depth, height in (
        (26.19, 21.23, -33.83, 6.23, 6.80, 2.22),
        (25.97, 18.70, -33.27, 5.82, 6.21, 4.24),
        (26.09, 14.37, -33.08, 5.88, 5.82, 4.60),
        (25.93, 10.31, -32.42, 5.51, 5.25, 3.98),
        (25.47, 7.01, -27.99, 3.73, 3.42, 2.63),
        (25.90, 4.66, -26.96, 3.47, 3.19, 2.81),
        (25.93, 2.47, -25.40, 3.38, 2.93, 2.33),
    ):
        garden_shelf(spill, x, y, z, width, depth, height, "8E7D89", slate, collide=False)
    garden_shelf(spill, 25.38, 19.83, -29.32, 3.19, 2.69, 1.08,
                 "9E8893", slate, collide=False)
    garden_shelf(spill, 25.19, 18.87, -28.35, 2.98, 2.55, .82,
                 "AC9197", slate, collide=False)
    # Use the same screened, texture-free rocks as Cinder, with a slate
    # surface and the broadest faces nestled under the existing landings.
    for name, source, center, size, yaw, tint in (
        ("Overflow shoulder stone", "Cube.008", (27.60, 16.96, -28.86), (2.91, 4.04, 3.06), 19, "82727E"),
        ("Overflow landing stone", "Cube.005", (27.03, 7.21, -26.80), (3.85, 1.33, 2.93), -22, "8D7D87"),
    ):
        mesh_id, mesh_size = STORE_STONES[source]
        stone = part(spill, name, center, size, tint, yaw=yaw, material=rock,
                     collide=False, class_name="MeshPart")
        vector(stone, "Vector3", "InitialSize", ("X", "Y", "Z"), mesh_size)
        asset(stone, "MeshContent", f"rbxassetid://{mesh_id}")
        prop(stone, "string", variant_field, rock_variant)
        prop(stone, "bool", "CastShadow", False)
        prop(stone, "token", "RenderFidelity", 2)
    garden_prop(spill, "meadowCover", (25.94, 19.79, -29.73), .10, 61, "8EA56A")
    for x, y, z, width, depth, yaw in (
        (27.83, 21.95, -32.80, 2.56, 3.00, 43),
        (26.90, 15.09, -31.43, 2.15, 2.12, 67),
        (26.88, 10.34, -30.90, 2.13, 1.95, 11),
    ):
        garden_shelf(spill, x, y - .14, z, width + .32, depth + .30, .61, "A38A94", slate, collide=False)
        garden_shelf(spill, x, y, z - .07, width, depth, .19, "7B9351", grass, collide=False)
        garden_prop(spill, "meadowGrass", (x, y, z), .12, yaw, "A9BC75")
        garden_prop(spill, "rockVine", (x + .15, y - .93, z + depth * .36), .34, yaw, "8BA16A")

    for name, xyz, size, tint, transparency in (
        ("Pale overflow lip", (24.91, 21.91, -31.07), (2.29, .075, .68), "D1EAF0", .21),
        ("Pale overflow landing", (25.10, 7.15, -26.88), (2.12, .065, .93), "AFDEE8", .20),
        ("Overflow foam at garden spill", (25.07, 7.18, -26.62), (1.63, .045, .40), "E2EEF0", .23),
    ):
        water = part(spill, name, xyz, size, tint, material=glass, shape=0,
                     transparency=transparency, collide=False)
        prop(water, "bool", "CastShadow", False)

    horizontal_water_beam(
        spill, "Reedfall outflow foam", (29.15, 22.43, -39.94), (31.59, 22.37, -37.11),
        (.65, .62), "0 .75 .88 .88 0 1 .91 .98 .99 0 ",
        "0 1 0 .27 .51 0 .78 .51 0 1 1 0 ", 2.8,
    )
    flow_beam(spill, (24.61, 18.40, -26.76), (25.05, 7.27, -26.59), 2.23, 1.72, .38, .32)
