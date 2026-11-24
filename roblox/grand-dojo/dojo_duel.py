"""Grand Dojo's local 1v1 court, east of the resident Bot Spar mat."""


def build_dojo_duel(ring, floor, ring_offset, *, item, part, prop, sign, wood, metal):
    court = item(ring, "Model", "Duel Court")
    prop(court, "token", "ModelStreamingMode", 1)
    x, z = 41.5 + ring_offset, 4.5
    width, depth = 12, 18.8
    indigo, brass = "425966", "D1A571"

    def detail(name, position, size, tint, **options):
        obj = part(court, name, position, size, tint, collide=False, **options)
        prop(obj, "bool", "CastShadow", False)
        return obj

    def marker(name, position, yaw=0, size=(.2, .2, .2)):
        return detail(name, position, size, brass, yaw=yaw, transparency=1)

    marker("Duel Bounds", (x, floor + 3, z), size=(width, 6, depth))
    for side in (-1, 1):
        detail("Duel court sideline", (x + side * width / 2, floor + .042, z),
               (.11, .027, depth), indigo)
        detail("Duel court endline", (x, floor + .042, z + side * depth / 2),
               (width, .027, .11), indigo)
    for dx, dz, tint in ((-1, 4.55, "874D47"), (1, -4.55, "477083")):
        position = (x + dx, floor + .040, z + dz)
        detail("Duel starting flag", position, (2.28, .027, .79), tint)
        detail("Duel starting flag trim", (position[0], floor + .056, position[2]),
               (1.92, .019, .076), brass)
    detail("Duel medallion", (x, floor + .046, z), (1.04, .028, 1.04), indigo, yaw=45)
    detail("Duel medallion gilt", (x, floor + .062, z), (.62, .018, .62), brass, yaw=45)

    gate_z = 15.82
    for dx in (-2.05, 2.05):
        detail("Duel board cedar post", (x + dx, floor + 1.02, gate_z),
               (.22, 2.04, .29), "664B44", material=wood)
        detail("Duel board clasp", (x + dx, floor + 1.74, gate_z + .13),
               (.29, .17, .076), brass, material=metal)
    sign(court, "1V1 DUEL", x, floor + 2.08, gate_z + .07, 4.70, .66, tint="3C525D", single_line=True)
    sign(court, "CASUAL / SERIES / RANKED", x, floor + 1.46, gate_z + .07, 4.32, .43, tint="4B6066", single_line=True)

    gate = marker("Duel Queue", (x, floor + 1.75, gate_z + .89))
    prompt = item(gate, "ProximityPrompt", "JoinDuelPrompt")
    prop(prompt, "string", "ActionText", "Choose duel format")
    prop(prompt, "string", "ObjectText", "Grand Dojo 1v1 Duel")
    prop(prompt, "float", "MaxActivationDistance", 7.25)
    prop(prompt, "bool", "RequiresLineOfSight", False)
    prop(prompt, "float", "HoldDuration", .20)

    # The two fighters face each other across the empty mat.
    marker("First Spawn", (x, floor + 2.22, z + 4.55))
    marker("Second Spawn", (x, floor + 2.22, z - 4.55), yaw=180)
    marker("First Return", (x - 2.35, floor + 2.22, 14.84), yaw=180)
    marker("Second Return", (x + 2.35, floor + 2.22, 14.84), yaw=180)
    return court
