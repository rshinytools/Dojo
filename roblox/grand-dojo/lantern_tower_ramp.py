"""The stair-free route from Garden Lookout to Lantern Tower's balcony."""

from math import atan2, degrees


PATH = (
    (-60.00, 2.42, 36.70),
    (-57.04, 2.42, 36.70),
    (-53.90, 3.56, 33.75),
    (-51.90, 5.32, 28.55),
    (-51.90, 6.56, 22.65),
    (-55.08, 6.56, 22.65),
)
WIDTH = 4.08


def lift(point, height):
    x, y, z = point
    return x, y + height, z


def build_lantern_tower_ramp(parent, *, item, prop, part, triangle, beam, path_edge,
                             sign, lantern, cedar, slate, metal, cedar_variant, variant_field):
    ramp = item(parent, "Model", "Lantern Tower cedar ramp")
    prop(ramp, "token", "ModelStreamingMode", 1)
    prop(ramp, "token", "LevelOfDetail", 4)
    floor = item(ramp, "Model", "Fitted cedar ramp deck")
    left, right = (path_edge(PATH, side * WIDTH / 2) for side in (-1, 1))
    for index, (a, b, c, d) in enumerate(zip(left, right, left[1:], right[1:])):
        start = len(floor)
        for face in ((a, b, c), (b, d, c)):
            triangle(floor, *(lift(point, -.125) for point in face), "A36A4B",
                     name="Lantern Tower ramp deck", thickness=.25, material=cedar, collide=True)
        for piece in list(floor)[start:]:
            prop(piece, "string", variant_field, cedar_variant)
        for edge_start, edge_end in ((a, c), (b, d)):
            beam(ramp, "Deep cedar ramp fascia", lift(edge_start, -.25), lift(edge_end, -.25),
                 .34, "814535")
        if index in (1, 2, 3):
            for fraction in (.28, .68):
                cross_left = tuple(p + (q - p) * fraction for p, q in zip(a, c))
                cross_right = tuple(p + (q - p) * fraction for p, q in zip(b, d))
                beam(ramp, "Cedar deck bearer", lift(cross_left, -.35), lift(cross_right, -.35),
                     .26, "724135")

    for side in (-1, 1):
        rail = path_edge(PATH, side * (WIDTH / 2 - .14))
        # Stop the new rails at the existing guards on the balcony and courtyard.
        rail[0] = (-59.0, rail[0][1], rail[0][2])
        rail[-1] = (-53.65, rail[-1][1], 22.65 + side * 2.02)
        for a, b in zip(rail, rail[1:]):
            for height, width, color in ((.48, .17, "8D4835"), (1.32, .24, "A9583D")):
                beam(ramp, "Lantern Tower ramp guardrail", lift(a, height), lift(b, height),
                     width, color, collide=True)
        for point in rail:
            part(ramp, "Cedar ramp newel", lift(point, .65), (.33, 1.43, .33),
                 "7B4333", material=cedar, collide=False)
            part(ramp, "Brass ramp newel cap", lift(point, 1.39), (.43, .12, .43),
                 "C19455", material=metal, collide=False)

    for x, top, z, yaw in ((-56.39, 2.66, 36.05, 137), (-53.79, 4.04, 31.46, 162),
                            (-51.90, 5.71, 25.65, 180), (-50.70, 6.37, 21.60, 180)):
        part(ramp, "Ramp pier slate plinth", (x, .55, z), (1.34, .88, 1.34),
             "8D7880", yaw=yaw, material=slate, collide=False)
        part(ramp, "Tall cedar ramp pier", (x, (top + .89) / 2, z), (.55, top - .89, .55),
             "894735", yaw=yaw, material=cedar, collide=False)
        part(ramp, "Ramp pier capital", (x, top - .19, z), (.99, .22, .97),
             "AC6245", yaw=yaw, material=cedar, collide=False)

    east = path_edge(PATH, -1.90)
    for index in (2, 4):
        x, y, z = east[index]
        part(ramp, "Cedar lantern upright", (x, y + 1.54, z), (.26, 3.08, .26),
             "864532", material=cedar, collide=False)
        out = (x + .46, y + 3.02, z)
        beam(ramp, "Ramp lantern bracket", (x, y + 3.02, z), out, .14, "834D35")
        lantern(ramp, out[0], y + 2.48, z, .57, light=False)

    # The lower plaque faces players approaching from the garden stairs.
    x, y, z = -59.06, 3.69, 39.09
    yaw = degrees(atan2(-5.9, 4.5))
    part(ramp, "Tower ramp signpost", (x, 3.02, z), (.31, 1.26, .31),
         "884532", yaw=yaw, material=cedar, collide=False)
    sign(ramp, "TOWER RAMP", x, y, z, 3.51, .74, yaw, "77483B")
